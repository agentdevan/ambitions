import Foundation
import SQLite3
import AmbitionsRuntimeCore

public enum RuntimeStoreFailurePoint: String, Sendable, Codable, Equatable {
    case afterStateChanges = "after_state_changes"
    case afterEvents = "after_events"
    case afterProjections = "after_projections"
    case afterReceipt = "after_receipt"
    case afterExternalEffects = "after_external_effects"
}

public enum RuntimeStoreError: Error, Sendable, Equatable {
    case invariant(RuntimeInvariantViolation)
    case revisionConflict(expected: Int64, actual: Int64)
    case injectedFailure(RuntimeStoreFailurePoint)
    case sqlite(String)
}

public struct RuntimeStoreSnapshot: Sendable, Equatable {
    public static let empty = RuntimeStoreSnapshot(
        canonicalRevision: 0,
        stateChanges: [],
        events: [],
        projectionChanges: [],
        receipts: [],
        externalEffects: []
    )

    public let canonicalRevision: Int64
    public let stateChanges: [RuntimeStateChange]
    public let events: [RuntimeEvent]
    public let projectionChanges: [RuntimeProjectionChange]
    public let receipts: [RuntimeReceipt]
    public let externalEffects: [RuntimeExternalEffectEnvelope]

    public init(
        canonicalRevision: Int64,
        stateChanges: [RuntimeStateChange],
        events: [RuntimeEvent],
        projectionChanges: [RuntimeProjectionChange],
        receipts: [RuntimeReceipt],
        externalEffects: [RuntimeExternalEffectEnvelope]
    ) {
        self.canonicalRevision = canonicalRevision
        self.stateChanges = stateChanges
        self.events = events
        self.projectionChanges = projectionChanges
        self.receipts = receipts
        self.externalEffects = externalEffects
    }
}

public actor RuntimeStoreSQLite {
    public let databaseURL: URL
    private let failurePoint: RuntimeStoreFailurePoint?

    public init(
        databaseURL: URL,
        failurePoint: RuntimeStoreFailurePoint? = nil
    ) throws {
        self.databaseURL = databaseURL
        self.failurePoint = failurePoint
        let database = try SQLiteConnection(url: databaseURL)
        try Self.createSchema(database)
    }

    public func commit(
        _ transition: RuntimeTransition,
        idempotencyKey: String
    ) throws -> RuntimeReceipt {
        do {
            try transition.validate()
        } catch let violation as RuntimeInvariantViolation {
            throw RuntimeStoreError.invariant(violation)
        }

        let database = try SQLiteConnection(url: databaseURL)
        try Self.createSchema(database)
        try database.execute("BEGIN IMMEDIATE")
        do {
            if let receipt: RuntimeReceipt = try Self.record(
                RuntimeReceipt.self,
                sql: "SELECT receipt_json FROM runtime_receipts WHERE idempotency_key = ? LIMIT 1",
                bindings: [.text(idempotencyKey)],
                database: database
            ) {
                try database.execute("COMMIT")
                return receipt
            }

            for change in transition.stateChanges {
                let actual = try Self.currentRevision(
                    for: change.aggregate,
                    database: database
                )
                let expected = change.expectedRevision ?? 0
                guard actual == expected else {
                    throw RuntimeStoreError.revisionConflict(
                        expected: expected,
                        actual: actual
                    )
                }
                try Self.execute(
                    """
                    INSERT INTO runtime_state (
                        aggregate_kind, aggregate_id, revision, state_json
                    ) VALUES (?, ?, ?, ?)
                    ON CONFLICT(aggregate_kind, aggregate_id) DO UPDATE SET
                        revision = excluded.revision,
                        state_json = excluded.state_json
                    """,
                    bindings: [
                        .text(change.aggregate.kind),
                        .text(change.aggregate.id),
                        .integer(change.newRevision),
                        .blob(try Self.encode(change))
                    ],
                    database: database
                )
            }
            try failIfRequested(.afterStateChanges)

            for event in transition.events {
                try Self.execute(
                    "INSERT INTO runtime_events (event_id, command_id, event_json) VALUES (?, ?, ?)",
                    bindings: [
                        .text(event.id),
                        .text(transition.commandID),
                        .blob(try Self.encode(event))
                    ],
                    database: database
                )
            }
            try failIfRequested(.afterEvents)

            for projection in transition.projectionChanges {
                try Self.execute(
                    """
                    INSERT INTO runtime_projections (
                        projection_id, cursor, projection_json
                    ) VALUES (?, ?, ?)
                    ON CONFLICT(projection_id) DO UPDATE SET
                        cursor = excluded.cursor,
                        projection_json = excluded.projection_json
                    """,
                    bindings: [
                        .text(projection.projection),
                        .text(projection.cursor),
                        .blob(try Self.encode(projection))
                    ],
                    database: database
                )
            }
            try failIfRequested(.afterProjections)

            try Self.execute(
                """
                INSERT INTO runtime_receipts (
                    command_id, idempotency_key, receipt_id, receipt_json
                ) VALUES (?, ?, ?, ?)
                """,
                bindings: [
                    .text(transition.commandID),
                    .text(idempotencyKey),
                    .text(transition.receipt.id),
                    .blob(try Self.encode(transition.receipt))
                ],
                database: database
            )
            try failIfRequested(.afterReceipt)

            for effect in transition.externalEffects {
                try Self.execute(
                    """
                    INSERT INTO runtime_external_effects (
                        effect_id, command_id, effect_json, status
                    ) VALUES (?, ?, ?, 'pending')
                    """,
                    bindings: [
                        .text(effect.id),
                        .text(transition.commandID),
                        .blob(try Self.encode(effect))
                    ],
                    database: database
                )
            }
            try failIfRequested(.afterExternalEffects)

            try Self.execute(
                """
                INSERT INTO runtime_metadata (key, integer_value)
                VALUES ('canonical_revision', ?)
                ON CONFLICT(key) DO UPDATE SET
                    integer_value = MAX(integer_value, excluded.integer_value)
                """,
                bindings: [.integer(transition.receipt.canonicalRevision)],
                database: database
            )
            try database.execute("COMMIT")
            return transition.receipt
        } catch {
            try? database.execute("ROLLBACK")
            throw error
        }
    }

    public func receipt(forCommandID commandID: String) throws -> RuntimeReceipt? {
        let database = try SQLiteConnection(url: databaseURL)
        try Self.createSchema(database)
        return try Self.record(
            RuntimeReceipt.self,
            sql: "SELECT receipt_json FROM runtime_receipts WHERE command_id = ? LIMIT 1",
            bindings: [.text(commandID)],
            database: database
        )
    }

    public func snapshot() throws -> RuntimeStoreSnapshot {
        let database = try SQLiteConnection(url: databaseURL)
        try Self.createSchema(database)
        return RuntimeStoreSnapshot(
            canonicalRevision: try Self.canonicalRevision(database),
            stateChanges: try Self.records(
                RuntimeStateChange.self,
                sql: "SELECT state_json FROM runtime_state ORDER BY aggregate_kind, aggregate_id",
                database: database
            ),
            events: try Self.records(
                RuntimeEvent.self,
                sql: "SELECT event_json FROM runtime_events ORDER BY rowid",
                database: database
            ),
            projectionChanges: try Self.records(
                RuntimeProjectionChange.self,
                sql: "SELECT projection_json FROM runtime_projections ORDER BY projection_id",
                database: database
            ),
            receipts: try Self.records(
                RuntimeReceipt.self,
                sql: "SELECT receipt_json FROM runtime_receipts ORDER BY rowid",
                database: database
            ),
            externalEffects: try Self.records(
                RuntimeExternalEffectEnvelope.self,
                sql: "SELECT effect_json FROM runtime_external_effects ORDER BY rowid",
                database: database
            )
        )
    }

    private func failIfRequested(_ point: RuntimeStoreFailurePoint) throws {
        if failurePoint == point {
            throw RuntimeStoreError.injectedFailure(point)
        }
    }
}

private extension RuntimeStoreSQLite {
    static func createSchema(_ database: SQLiteConnection) throws {
        try database.execute("PRAGMA journal_mode=WAL")
        try database.execute("PRAGMA foreign_keys=ON")
        try database.execute("PRAGMA synchronous=FULL")
        try database.execute(
            """
            CREATE TABLE IF NOT EXISTS runtime_metadata (
                key TEXT PRIMARY KEY,
                integer_value INTEGER NOT NULL
            );
            CREATE TABLE IF NOT EXISTS runtime_state (
                aggregate_kind TEXT NOT NULL,
                aggregate_id TEXT NOT NULL,
                revision INTEGER NOT NULL,
                state_json BLOB NOT NULL,
                PRIMARY KEY (aggregate_kind, aggregate_id)
            );
            CREATE TABLE IF NOT EXISTS runtime_events (
                event_id TEXT PRIMARY KEY,
                command_id TEXT NOT NULL,
                event_json BLOB NOT NULL
            );
            CREATE TABLE IF NOT EXISTS runtime_projections (
                projection_id TEXT PRIMARY KEY,
                cursor TEXT NOT NULL,
                projection_json BLOB NOT NULL
            );
            CREATE TABLE IF NOT EXISTS runtime_receipts (
                command_id TEXT PRIMARY KEY,
                idempotency_key TEXT NOT NULL UNIQUE,
                receipt_id TEXT NOT NULL UNIQUE,
                receipt_json BLOB NOT NULL
            );
            CREATE TABLE IF NOT EXISTS runtime_external_effects (
                effect_id TEXT PRIMARY KEY,
                command_id TEXT NOT NULL,
                effect_json BLOB NOT NULL,
                status TEXT NOT NULL CHECK(status IN ('pending', 'reconciled', 'failed')),
                FOREIGN KEY(command_id) REFERENCES runtime_receipts(command_id)
            );
            """
        )
    }

    static func currentRevision(
        for aggregate: RuntimeAggregateReference,
        database: SQLiteConnection
    ) throws -> Int64 {
        try integer(
            sql: "SELECT revision FROM runtime_state WHERE aggregate_kind = ? AND aggregate_id = ? LIMIT 1",
            bindings: [.text(aggregate.kind), .text(aggregate.id)],
            database: database
        ) ?? 0
    }

    static func canonicalRevision(_ database: SQLiteConnection) throws -> Int64 {
        try integer(
            sql: "SELECT integer_value FROM runtime_metadata WHERE key = 'canonical_revision' LIMIT 1",
            bindings: [],
            database: database
        ) ?? 0
    }

    static func integer(
        sql: String,
        bindings: [SQLiteBinding],
        database: SQLiteConnection
    ) throws -> Int64? {
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        try bind(bindings, to: statement, database: database)
        let result = sqlite3_step(statement)
        if result == SQLITE_DONE { return nil }
        guard result == SQLITE_ROW else {
            throw RuntimeStoreError.sqlite(database.message)
        }
        return sqlite3_column_int64(statement, 0)
    }

    static func execute(
        _ sql: String,
        bindings: [SQLiteBinding],
        database: SQLiteConnection
    ) throws {
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        try bind(bindings, to: statement, database: database)
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw RuntimeStoreError.sqlite(database.message)
        }
    }

    static func record<Value: Decodable>(
        _ type: Value.Type,
        sql: String,
        bindings: [SQLiteBinding],
        database: SQLiteConnection
    ) throws -> Value? {
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        try bind(bindings, to: statement, database: database)
        let result = sqlite3_step(statement)
        if result == SQLITE_DONE { return nil }
        guard result == SQLITE_ROW else {
            throw RuntimeStoreError.sqlite(database.message)
        }
        return try JSONDecoder().decode(type, from: try blob(statement, column: 0))
    }

    static func records<Value: Decodable>(
        _ type: Value.Type,
        sql: String,
        database: SQLiteConnection
    ) throws -> [Value] {
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        var result: [Value] = []
        while true {
            switch sqlite3_step(statement) {
            case SQLITE_ROW:
                result.append(
                    try JSONDecoder().decode(
                        type,
                        from: try blob(statement, column: 0)
                    )
                )
            case SQLITE_DONE:
                return result
            default:
                throw RuntimeStoreError.sqlite(database.message)
            }
        }
    }

    static func encode<Value: Encodable>(_ value: Value) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
    }

    static func blob(_ statement: OpaquePointer, column: Int32) throws -> Data {
        let count = Int(sqlite3_column_bytes(statement, column))
        guard count > 0, let bytes = sqlite3_column_blob(statement, column) else {
            return Data()
        }
        return Data(bytes: bytes, count: count)
    }

    static func bind(
        _ bindings: [SQLiteBinding],
        to statement: OpaquePointer,
        database: SQLiteConnection
    ) throws {
        for (offset, binding) in bindings.enumerated() {
            let index = Int32(offset + 1)
            let result: Int32
            switch binding {
            case let .integer(value):
                result = sqlite3_bind_int64(statement, index, value)
            case let .text(value):
                result = sqlite3_bind_text(
                    statement,
                    index,
                    value,
                    -1,
                    sqliteTransient
                )
            case let .blob(value):
                result = value.withUnsafeBytes { bytes in
                    sqlite3_bind_blob(
                        statement,
                        index,
                        bytes.baseAddress,
                        Int32(value.count),
                        sqliteTransient
                    )
                }
            }
            guard result == SQLITE_OK else {
                throw RuntimeStoreError.sqlite(database.message)
            }
        }
    }
}

private enum SQLiteBinding {
    case integer(Int64)
    case text(String)
    case blob(Data)
}

private final class SQLiteConnection {
    private(set) var handle: OpaquePointer?

    var message: String {
        handle.map { String(cString: sqlite3_errmsg($0)) } ?? "SQLite unavailable"
    }

    init(url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        guard sqlite3_open_v2(url.path, &handle, flags, nil) == SQLITE_OK,
              handle != nil
        else {
            let error = RuntimeStoreError.sqlite(message)
            if let handle { sqlite3_close(handle) }
            handle = nil
            throw error
        }
        sqlite3_busy_timeout(handle, 5_000)
    }

    deinit {
        if let handle { sqlite3_close(handle) }
    }

    func execute(_ sql: String) throws {
        guard let handle else { throw RuntimeStoreError.sqlite(message) }
        var errorMessage: UnsafeMutablePointer<CChar>?
        guard sqlite3_exec(handle, sql, nil, nil, &errorMessage) == SQLITE_OK else {
            let value = errorMessage.map { String(cString: $0) } ?? message
            sqlite3_free(errorMessage)
            throw RuntimeStoreError.sqlite(value)
        }
    }

    func prepare(_ sql: String) throws -> OpaquePointer {
        guard let handle else { throw RuntimeStoreError.sqlite(message) }
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK,
              let statement
        else {
            throw RuntimeStoreError.sqlite(message)
        }
        return statement
    }

}

private let sqliteTransient = unsafeBitCast(
    -1,
    to: sqlite3_destructor_type.self
)
