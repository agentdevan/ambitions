import Foundation
import SQLite3
import AmbitionsRuntimeCore

public enum RuntimeStoreFailurePoint: String, Sendable, Codable, Equatable {
    case afterStateChanges = "after_state_changes"
    case afterEvents = "after_events"
    case afterProjections = "after_projections"
    case afterReceipt = "after_receipt"
    case afterExternalEffects = "after_external_effects"
    case afterCommit = "after_commit"
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
                try failIfRequested(.afterCommit)
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
            try failIfRequested(.afterCommit)
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

    public func externalEffectRecords() throws -> [RuntimeExternalEffectRecord] {
        let database = try SQLiteConnection(url: databaseURL)
        try Self.createSchema(database)
        return try Self.externalEffectRecords(database: database)
    }

    public func claimNextExternalEffect(
        claimID: String,
        claimedAt: Date,
        recoveringClaimsAtOrBefore recoveryCutoff: Date? = nil
    ) throws -> RuntimeExternalEffectRecord? {
        let database = try SQLiteConnection(url: databaseURL)
        try Self.createSchema(database)
        try database.execute("BEGIN IMMEDIATE")
        do {
            let effectID: String?
            if let recoveryCutoff {
                effectID = try Self.text(
                    sql: """
                    SELECT effect_id
                    FROM runtime_external_effects
                    WHERE reconciliation_status IN ('pending', 'failed')
                       OR (
                           reconciliation_status = 'claimed'
                           AND claimed_at <= ?
                       )
                    ORDER BY rowid
                    LIMIT 1
                    """,
                    bindings: [
                        .double(recoveryCutoff.timeIntervalSince1970)
                    ],
                    database: database
                )
            } else {
                effectID = try Self.text(
                    sql: """
                    SELECT effect_id
                    FROM runtime_external_effects
                    WHERE reconciliation_status IN ('pending', 'failed')
                    ORDER BY rowid
                    LIMIT 1
                    """,
                    bindings: [],
                    database: database
                )
            }
            guard let effectID else {
                try database.execute("COMMIT")
                return nil
            }

            try Self.execute(
                """
                UPDATE runtime_external_effects
                SET status = 'pending',
                    reconciliation_status = 'claimed',
                    attempt_count = attempt_count + 1,
                    claim_id = ?,
                    claimed_at = ?,
                    failure_description = NULL
                WHERE effect_id = ?
                """,
                bindings: [
                    .text(claimID),
                    .double(claimedAt.timeIntervalSince1970),
                    .text(effectID)
                ],
                database: database
            )
            let record = try Self.externalEffectRecord(
                effectID: effectID,
                database: database
            )
            try database.execute("COMMIT")
            return record
        } catch {
            try? database.execute("ROLLBACK")
            throw error
        }
    }

    public func markExternalEffectFailed(
        effectID: String,
        claimID: String,
        failureDescription: String
    ) throws -> RuntimeExternalEffectRecord {
        try updateClaimedExternalEffect(
            effectID: effectID,
            claimID: claimID,
            status: .failed,
            failureDescription: failureDescription
        )
    }

    public func markExternalEffectReconciled(
        effectID: String,
        claimID: String
    ) throws -> RuntimeExternalEffectRecord {
        try updateClaimedExternalEffect(
            effectID: effectID,
            claimID: claimID,
            status: .reconciled,
            failureDescription: nil
        )
    }

    private func failIfRequested(_ point: RuntimeStoreFailurePoint) throws {
        if failurePoint == point {
            throw RuntimeStoreError.injectedFailure(point)
        }
    }

    private func updateClaimedExternalEffect(
        effectID: String,
        claimID: String,
        status: RuntimeExternalEffectStatus,
        failureDescription: String?
    ) throws -> RuntimeExternalEffectRecord {
        let database = try SQLiteConnection(url: databaseURL)
        try Self.createSchema(database)
        try database.execute("BEGIN IMMEDIATE")
        do {
            guard let current = try Self.externalEffectRecord(
                effectID: effectID,
                database: database
            ) else {
                throw RuntimeExternalEffectError.effectNotFound(
                    effectID: effectID
                )
            }
            if status == .reconciled, current.status == .reconciled {
                try database.execute("COMMIT")
                return current
            }
            guard current.status == .claimed, let claim = current.claim else {
                throw RuntimeExternalEffectError.invalidTransition(
                    effectID: effectID,
                    status: current.status
                )
            }
            guard claim.id == claimID else {
                throw RuntimeExternalEffectError.claimMismatch(
                    effectID: effectID,
                    expectedClaimID: claim.id,
                    actualClaimID: claimID
                )
            }

            let bindings: [SQLiteBinding]
            if let failureDescription {
                bindings = [
                    .text(status.rawValue),
                    .text(status.rawValue),
                    .text(failureDescription),
                    .text(effectID)
                ]
            } else {
                bindings = [
                    .text(status.rawValue),
                    .text(status.rawValue),
                    .null,
                    .text(effectID)
                ]
            }
            try Self.execute(
                """
                UPDATE runtime_external_effects
                SET status = ?,
                    reconciliation_status = ?,
                    claim_id = NULL,
                    claimed_at = NULL,
                    failure_description = ?
                WHERE effect_id = ?
                """,
                bindings: bindings,
                database: database
            )
            guard let updated = try Self.externalEffectRecord(
                effectID: effectID,
                database: database
            ) else {
                throw RuntimeExternalEffectError.effectNotFound(
                    effectID: effectID
                )
            }
            try database.execute("COMMIT")
            return updated
        } catch {
            try? database.execute("ROLLBACK")
            throw error
        }
    }
}

struct RuntimeStoreSQLiteMigrationObservation {
    let snapshot: RuntimeStoreSnapshot
    let outbox: [RuntimeExternalEffectRecord]
    let integrityResult: String
}

extension RuntimeStoreSQLite {
    static func migrationObservation(
        at immutableDatabaseURL: URL
    ) throws -> RuntimeStoreSQLiteMigrationObservation {
        let database = try SQLiteConnection(
            url: immutableDatabaseURL,
            access: .readOnlyImmutable
        )
        try database.execute("BEGIN")
        do {
            let snapshot = RuntimeStoreSnapshot(
                canonicalRevision: try canonicalRevision(database),
                stateChanges: try records(
                    RuntimeStateChange.self,
                    sql: "SELECT state_json FROM runtime_state ORDER BY aggregate_kind, aggregate_id",
                    database: database
                ),
                events: try records(
                    RuntimeEvent.self,
                    sql: "SELECT event_json FROM runtime_events ORDER BY rowid",
                    database: database
                ),
                projectionChanges: try records(
                    RuntimeProjectionChange.self,
                    sql: "SELECT projection_json FROM runtime_projections ORDER BY projection_id",
                    database: database
                ),
                receipts: try records(
                    RuntimeReceipt.self,
                    sql: "SELECT receipt_json FROM runtime_receipts ORDER BY rowid",
                    database: database
                ),
                externalEffects: try records(
                    RuntimeExternalEffectEnvelope.self,
                    sql: "SELECT effect_json FROM runtime_external_effects ORDER BY rowid",
                    database: database
                )
            )
            let outbox = try externalEffectRecords(database: database)
            let integrity = try database.pragmaIntegrityCheck()
            try database.execute("COMMIT")
            return RuntimeStoreSQLiteMigrationObservation(
                snapshot: snapshot,
                outbox: outbox,
                integrityResult: integrity
            )
        } catch {
            try? database.execute("ROLLBACK")
            throw error
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
            """
        )
        try migrateExternalEffectSchema(database)
    }

    static func migrateExternalEffectSchema(
        _ database: SQLiteConnection
    ) throws {
        try database.execute("BEGIN IMMEDIATE")
        do {
            try database.execute(
                """
                CREATE TABLE IF NOT EXISTS runtime_external_effects (
                    effect_id TEXT PRIMARY KEY,
                    command_id TEXT NOT NULL,
                    effect_json BLOB NOT NULL,
                    status TEXT NOT NULL CHECK(
                        status IN ('pending', 'reconciled', 'failed')
                    ),
                    reconciliation_status TEXT NOT NULL DEFAULT 'pending'
                        CHECK(reconciliation_status IN (
                            'pending', 'claimed', 'reconciled', 'failed'
                        )),
                    attempt_count INTEGER NOT NULL DEFAULT 0,
                    claim_id TEXT,
                    claimed_at REAL,
                    failure_description TEXT,
                    FOREIGN KEY(command_id) REFERENCES runtime_receipts(command_id)
                );
                """
            )
            let addedReconciliationStatus = try addExternalEffectColumnIfNeeded(
                "reconciliation_status TEXT NOT NULL DEFAULT 'pending' "
                    + "CHECK(reconciliation_status IN "
                    + "('pending', 'claimed', 'reconciled', 'failed'))",
                named: "reconciliation_status",
                database: database
            )
            _ = try addExternalEffectColumnIfNeeded(
                "attempt_count INTEGER NOT NULL DEFAULT 0",
                named: "attempt_count",
                database: database
            )
            _ = try addExternalEffectColumnIfNeeded(
                "claim_id TEXT",
                named: "claim_id",
                database: database
            )
            _ = try addExternalEffectColumnIfNeeded(
                "claimed_at REAL",
                named: "claimed_at",
                database: database
            )
            _ = try addExternalEffectColumnIfNeeded(
                "failure_description TEXT",
                named: "failure_description",
                database: database
            )
            if addedReconciliationStatus {
                try database.execute(
                    """
                    UPDATE runtime_external_effects
                    SET reconciliation_status = status,
                        failure_description = CASE status
                            WHEN 'failed' THEN 'Legacy failure details are unavailable.'
                            ELSE NULL
                        END
                    """
                )
            }
            try database.execute("COMMIT")
        } catch {
            try? database.execute("ROLLBACK")
            throw error
        }
    }

    static func addExternalEffectColumnIfNeeded(
        _ definition: String,
        named columnName: String,
        database: SQLiteConnection
    ) throws -> Bool {
        guard try !columns(
            in: "runtime_external_effects",
            database: database
        ).contains(columnName) else { return false }
        try database.execute(
            "ALTER TABLE runtime_external_effects ADD COLUMN \(definition)"
        )
        return true
    }

    static func columns(
        in table: String,
        database: SQLiteConnection
    ) throws -> Set<String> {
        let statement = try database.prepare("PRAGMA table_info(\(table))")
        defer { sqlite3_finalize(statement) }
        var result: Set<String> = []
        while true {
            switch sqlite3_step(statement) {
            case SQLITE_ROW:
                guard let value = sqlite3_column_text(statement, 1) else {
                    throw RuntimeStoreError.sqlite(database.message)
                }
                result.insert(String(cString: value))
            case SQLITE_DONE:
                return result
            default:
                throw RuntimeStoreError.sqlite(database.message)
            }
        }
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

    static func text(
        sql: String,
        bindings: [SQLiteBinding],
        database: SQLiteConnection
    ) throws -> String? {
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        try bind(bindings, to: statement, database: database)
        let result = sqlite3_step(statement)
        if result == SQLITE_DONE { return nil }
        guard result == SQLITE_ROW,
              let value = sqlite3_column_text(statement, 0)
        else {
            throw RuntimeStoreError.sqlite(database.message)
        }
        return String(cString: value)
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

    static func externalEffectRecords(
        database: SQLiteConnection
    ) throws -> [RuntimeExternalEffectRecord] {
        let statement = try database.prepare(
            """
            SELECT effect_json, reconciliation_status, attempt_count,
                   claim_id, claimed_at, failure_description
            FROM runtime_external_effects
            ORDER BY rowid
            """
        )
        defer { sqlite3_finalize(statement) }
        var result: [RuntimeExternalEffectRecord] = []
        while true {
            switch sqlite3_step(statement) {
            case SQLITE_ROW:
                result.append(
                    try externalEffectRecord(
                        statement: statement,
                        database: database
                    )
                )
            case SQLITE_DONE:
                return result
            default:
                throw RuntimeStoreError.sqlite(database.message)
            }
        }
    }

    static func externalEffectRecord(
        effectID: String,
        database: SQLiteConnection
    ) throws -> RuntimeExternalEffectRecord? {
        let statement = try database.prepare(
            """
            SELECT effect_json, reconciliation_status, attempt_count,
                   claim_id, claimed_at, failure_description
            FROM runtime_external_effects
            WHERE effect_id = ?
            LIMIT 1
            """
        )
        defer { sqlite3_finalize(statement) }
        try bind([.text(effectID)], to: statement, database: database)
        let result = sqlite3_step(statement)
        if result == SQLITE_DONE { return nil }
        guard result == SQLITE_ROW else {
            throw RuntimeStoreError.sqlite(database.message)
        }
        return try externalEffectRecord(
            statement: statement,
            database: database
        )
    }

    static func externalEffectRecord(
        statement: OpaquePointer,
        database: SQLiteConnection
    ) throws -> RuntimeExternalEffectRecord {
        let envelope = try JSONDecoder().decode(
            RuntimeExternalEffectEnvelope.self,
            from: try blob(statement, column: 0)
        )
        let persistedStatus = try requiredText(
            statement,
            column: 1,
            database: database
        )
        guard let storedStatus = RuntimeExternalEffectStatus(
            rawValue: persistedStatus
        ) else {
            throw RuntimeStoreError.sqlite(
                "Unknown external effect status: \(persistedStatus)"
            )
        }
        let attemptCount = sqlite3_column_int64(statement, 2)
        let claimID = optionalText(statement, column: 3)
        let claim: RuntimeExternalEffectClaim?
        if let claimID {
            guard sqlite3_column_type(statement, 4) != SQLITE_NULL else {
                throw RuntimeStoreError.sqlite(
                    "Claimed external effect is missing its claim date"
                )
            }
            claim = RuntimeExternalEffectClaim(
                id: claimID,
                claimedAt: Date(
                    timeIntervalSince1970: sqlite3_column_double(statement, 4)
                )
            )
        } else {
            claim = nil
        }
        return RuntimeExternalEffectRecord(
            envelope: envelope,
            status: storedStatus,
            attemptCount: attemptCount,
            claim: claim,
            failureDescription: optionalText(statement, column: 5)
        )
    }

    static func requiredText(
        _ statement: OpaquePointer,
        column: Int32,
        database: SQLiteConnection
    ) throws -> String {
        guard let value = sqlite3_column_text(statement, column) else {
            throw RuntimeStoreError.sqlite(database.message)
        }
        return String(cString: value)
    }

    static func optionalText(
        _ statement: OpaquePointer,
        column: Int32
    ) -> String? {
        guard sqlite3_column_type(statement, column) != SQLITE_NULL,
              let value = sqlite3_column_text(statement, column)
        else { return nil }
        return String(cString: value)
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
            case let .double(value):
                result = sqlite3_bind_double(statement, index, value)
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
            case .null:
                result = sqlite3_bind_null(statement, index)
            }
            guard result == SQLITE_OK else {
                throw RuntimeStoreError.sqlite(database.message)
            }
        }
    }
}

private enum SQLiteBinding {
    case integer(Int64)
    case double(Double)
    case text(String)
    case blob(Data)
    case null
}

private final class SQLiteConnection {
    enum Access {
        case createReadWrite
        case readOnlyImmutable
    }

    private(set) var handle: OpaquePointer?

    var message: String {
        handle.map { String(cString: sqlite3_errmsg($0)) } ?? "SQLite unavailable"
    }

    init(
        url: URL,
        access: Access = .createReadWrite
    ) throws {
        let filename: String
        let flags: Int32
        switch access {
        case .createReadWrite:
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            filename = url.path
            flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        case .readOnlyImmutable:
            let escapedPath = url.path.addingPercentEncoding(
                withAllowedCharacters: .urlPathAllowed
            ) ?? url.path
            filename = "file:\(escapedPath)?immutable=1"
            flags = SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_URI
        }
        guard sqlite3_open_v2(filename, &handle, flags, nil) == SQLITE_OK,
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

    func pragmaIntegrityCheck() throws -> String {
        let statement = try prepare("PRAGMA integrity_check")
        defer { sqlite3_finalize(statement) }
        var results: [String] = []
        while true {
            switch sqlite3_step(statement) {
            case SQLITE_ROW:
                guard let value = sqlite3_column_text(statement, 0) else {
                    throw RuntimeStoreError.sqlite(
                        "SQLite integrity check returned an empty result."
                    )
                }
                results.append(String(cString: value))
            case SQLITE_DONE:
                return results.joined(separator: "\n")
            default:
                throw RuntimeStoreError.sqlite(message)
            }
        }
    }

}

private let sqliteTransient = unsafeBitCast(
    -1,
    to: sqlite3_destructor_type.self
)
