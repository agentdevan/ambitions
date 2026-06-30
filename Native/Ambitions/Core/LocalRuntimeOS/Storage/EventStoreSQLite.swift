import Foundation
import SQLite3

let eventStoreSQLiteSchemaVersion = "event_store_sqlite.native.v1"

struct EventStoreSQLiteHealth: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let storeKind: RuntimeEventStoreKind
    let eventCount: Int
    let latestCursor: RuntimeEventCursor?
    let checksumHead: String?
    let storageTier: LocalRuntimeStorageTier
}

actor EventStoreSQLite: RuntimeEventStore {
    private let databaseURL: URL
    private let deviceID: String
    private let legacyJSONLImportURL: URL?
    private var legacyJSONLImportAttempted = false

    nonisolated var storeKind: RuntimeEventStoreKind { .sqlite }

    init(
        databaseURL: URL,
        deviceID: String = RuntimeLocalDeviceID.current,
        legacyJSONLImportURL: URL? = nil
    ) {
        self.databaseURL = databaseURL
        self.deviceID = deviceID
        self.legacyJSONLImportURL = legacyJSONLImportURL
    }

    static func defaultLiveStore(fileManager: FileManager = .default) -> EventStoreSQLite {
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: "/tmp", isDirectory: true)
        let runtimeDirectory = supportDirectory
            .appendingPathComponent("AmbitionsLocalRuntimeOS", isDirectory: true)
        return EventStoreSQLite(
            databaseURL: runtimeDirectory.appendingPathComponent("EventStore.sqlite", isDirectory: false),
            legacyJSONLImportURL: runtimeDirectory.appendingPathComponent("RuntimeEventJournal.jsonl", isDirectory: false)
        )
    }

    @discardableResult
    func append(_ event: RuntimeEvent) async throws -> RuntimeEventEnvelope {
        let database = try openDatabase()
        try createSchema(database)
        try importLegacyJSONLIfNeeded(database)
        return try database.transaction {
            let previous = try latestEnvelope(database)
            let envelope = try RuntimeEventEnvelope.make(
                sequence: (previous?.sequence ?? 0) + 1,
                previousChecksum: previous?.checksum,
                event: event,
                deviceID: deviceID
            )
            try validateAppend(envelope, after: previous)
            try insert(envelope, database: database)
            return envelope
        }
    }

    func fetchEvents(matching query: RuntimeEventQuery = .all, limit: Int? = nil) async throws -> [RuntimeEventEnvelope] {
        let database = try openDatabase()
        try createSchema(database)
        try importLegacyJSONLIfNeeded(database)
        let envelopes = try selectEnvelopes(query: query, limit: limit, database: database)
        return try envelopes.map(validateLoaded)
    }

    func latestCursor() async throws -> RuntimeEventCursor? {
        let database = try openDatabase()
        try createSchema(database)
        try importLegacyJSONLIfNeeded(database)
        return try latestEnvelope(database)?.cursor
    }

    func health() async throws -> EventStoreSQLiteHealth {
        let database = try openDatabase()
        try createSchema(database)
        try importLegacyJSONLIfNeeded(database)
        let latest = try latestEnvelope(database)
        let count = try eventCount(database)
        return EventStoreSQLiteHealth(
            schemaVersion: eventStoreSQLiteSchemaVersion,
            storeKind: storeKind,
            eventCount: count,
            latestCursor: latest?.cursor,
            checksumHead: latest?.checksum,
            storageTier: .eventStoreSQLite
        )
    }
}

private extension EventStoreSQLite {
    func openDatabase() throws -> LocalRuntimeSQLiteDatabase {
        try LocalRuntimeSQLiteDatabase(url: databaseURL)
    }

    func createSchema(_ database: LocalRuntimeSQLiteDatabase) throws {
        try database.execute(
            """
            CREATE TABLE IF NOT EXISTS runtime_events (
                sequence INTEGER PRIMARY KEY,
                event_id TEXT NOT NULL UNIQUE,
                command_id TEXT,
                kind TEXT NOT NULL,
                actor TEXT NOT NULL,
                source TEXT NOT NULL,
                privacy TEXT NOT NULL,
                local_only INTEGER NOT NULL,
                occurred_at TEXT NOT NULL,
                checksum TEXT NOT NULL,
                previous_checksum TEXT,
                schema_version TEXT NOT NULL,
                envelope_json BLOB NOT NULL
            );
            """
        )
        try database.execute("CREATE INDEX IF NOT EXISTS runtime_events_command_idx ON runtime_events(command_id)")
        try database.execute("CREATE INDEX IF NOT EXISTS runtime_events_kind_idx ON runtime_events(kind)")
        try database.execute("CREATE INDEX IF NOT EXISTS runtime_events_occurred_idx ON runtime_events(occurred_at)")
    }

    func validateAppend(_ envelope: RuntimeEventEnvelope, after previous: RuntimeEventEnvelope?) throws {
        let expected = (previous?.sequence ?? 0) + 1
        guard envelope.sequence == expected else {
            throw RuntimeEventStoreError.nonAppendOnlySequence(expected: expected, actual: envelope.sequence)
        }
        guard RuntimeEventChecksum.isValid(envelope) else {
            throw RuntimeEventStoreError.checksumMismatch(eventID: envelope.id)
        }
    }

    func validateLoaded(_ envelope: RuntimeEventEnvelope) throws -> RuntimeEventEnvelope {
        guard RuntimeEventChecksum.isValid(envelope) else {
            throw RuntimeEventStoreError.checksumMismatch(eventID: envelope.id)
        }
        return envelope
    }

    func importLegacyJSONLIfNeeded(_ database: LocalRuntimeSQLiteDatabase) throws {
        guard legacyJSONLImportAttempted == false else { return }
        guard let legacyJSONLImportURL,
              FileManager.default.fileExists(atPath: legacyJSONLImportURL.path)
        else {
            legacyJSONLImportAttempted = true
            return
        }
        guard try eventCount(database) == 0 else {
            legacyJSONLImportAttempted = true
            return
        }

        let data = try Data(contentsOf: legacyJSONLImportURL)
        guard data.isEmpty == false else {
            legacyJSONLImportAttempted = true
            return
        }
        guard let raw = String(data: data, encoding: .utf8) else {
            throw RuntimeEventStoreError.invalidUTF8(legacyJSONLImportURL)
        }

        var previous: RuntimeEventEnvelope?
        var validatedEnvelopes: [RuntimeEventEnvelope] = []
        for line in raw.split(separator: "\n", omittingEmptySubsequences: true) {
            let envelope = try JSONDecoder().decode(RuntimeEventEnvelope.self, from: Data(line.utf8))
            let expectedSequence = (previous?.sequence ?? 0) + 1
            guard envelope.sequence == expectedSequence else {
                throw RuntimeEventStoreError.nonAppendOnlySequence(expected: expectedSequence, actual: envelope.sequence)
            }
            guard envelope.previousChecksum == previous?.checksum else {
                throw RuntimeEventStoreError.checksumMismatch(eventID: envelope.id)
            }
            let validatedEnvelope = try validateLoaded(envelope)
            validatedEnvelopes.append(validatedEnvelope)
            previous = validatedEnvelope
        }
        try database.transaction {
            for envelope in validatedEnvelopes {
                try insert(envelope, database: database)
            }
        }
        legacyJSONLImportAttempted = true
    }

    func insert(_ envelope: RuntimeEventEnvelope, database: LocalRuntimeSQLiteDatabase) throws {
        let sql =
            """
            INSERT INTO runtime_events (
                sequence, event_id, command_id, kind, actor, source, privacy, local_only,
                occurred_at, checksum, previous_checksum, schema_version, envelope_json
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }

        let data = try RuntimeEventChecksum.encoder.encode(envelope)
        try LocalRuntimeSQLite.bind(envelope.sequence, to: statement, at: 1, parameter: "sequence")
        try LocalRuntimeSQLite.bind(envelope.id, to: statement, at: 2, parameter: "event_id")
        try LocalRuntimeSQLite.bind(envelope.event.commandID, to: statement, at: 3, parameter: "command_id")
        try LocalRuntimeSQLite.bind(envelope.event.kind.rawValue, to: statement, at: 4, parameter: "kind")
        try LocalRuntimeSQLite.bind(envelope.event.actor.rawValue, to: statement, at: 5, parameter: "actor")
        try LocalRuntimeSQLite.bind(envelope.event.source.rawValue, to: statement, at: 6, parameter: "source")
        try LocalRuntimeSQLite.bind(envelope.event.privacy.rawValue, to: statement, at: 7, parameter: "privacy")
        try LocalRuntimeSQLite.bind(envelope.event.localOnly ? 1 : 0, to: statement, at: 8, parameter: "local_only")
        try LocalRuntimeSQLite.bind(envelope.event.occurredAt, to: statement, at: 9, parameter: "occurred_at")
        try LocalRuntimeSQLite.bind(envelope.checksum, to: statement, at: 10, parameter: "checksum")
        try LocalRuntimeSQLite.bind(envelope.previousChecksum, to: statement, at: 11, parameter: "previous_checksum")
        try LocalRuntimeSQLite.bind(envelope.schemaVersion, to: statement, at: 12, parameter: "schema_version")
        try LocalRuntimeSQLite.bind(data, to: statement, at: 13, parameter: "envelope_json")

        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw LocalRuntimeStorageError.sqliteStepFailed(sql: sql, message: database.sqliteMessage)
        }
    }

    func latestEnvelope(_ database: LocalRuntimeSQLiteDatabase) throws -> RuntimeEventEnvelope? {
        let rows = try selectEnvelopes(sql: "SELECT envelope_json FROM runtime_events ORDER BY sequence DESC LIMIT 1", database: database)
        return rows.first
    }

    func eventCount(_ database: LocalRuntimeSQLiteDatabase) throws -> Int {
        let sql = "SELECT COUNT(*) FROM runtime_events"
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        guard sqlite3_step(statement) == SQLITE_ROW else {
            throw LocalRuntimeStorageError.sqliteStepFailed(sql: sql, message: database.sqliteMessage)
        }
        return Int(LocalRuntimeSQLite.int64(statement, 0))
    }

    func selectEnvelopes(
        query: RuntimeEventQuery,
        limit: Int?,
        database: LocalRuntimeSQLiteDatabase
    ) throws -> [RuntimeEventEnvelope] {
        var sql = "SELECT envelope_json FROM runtime_events"
        var binders: [(OpaquePointer) throws -> Void] = []
        switch query {
        case .all:
            break
        case let .after(cursor):
            sql += " WHERE sequence > ?"
            binders.append { try LocalRuntimeSQLite.bind(cursor.sequence, to: $0, at: 1, parameter: "sequence") }
        case let .commandID(commandID):
            sql += " WHERE command_id = ?"
            binders.append { try LocalRuntimeSQLite.bind(commandID, to: $0, at: 1, parameter: "command_id") }
        case let .kind(kind):
            sql += " WHERE kind = ?"
            binders.append { try LocalRuntimeSQLite.bind(kind.rawValue, to: $0, at: 1, parameter: "kind") }
        }
        sql += " ORDER BY sequence ASC"
        if let limit {
            sql += " LIMIT ?"
            let index = Int32(binders.count + 1)
            binders.append { try LocalRuntimeSQLite.bind(max(0, limit), to: $0, at: index, parameter: "limit") }
        }
        return try selectEnvelopes(sql: sql, binders: binders, database: database)
    }

    func selectEnvelopes(
        sql: String,
        binders: [(OpaquePointer) throws -> Void] = [],
        database: LocalRuntimeSQLiteDatabase
    ) throws -> [RuntimeEventEnvelope] {
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        for binder in binders {
            try binder(statement)
        }

        var rows: [RuntimeEventEnvelope] = []
        while true {
            let result = sqlite3_step(statement)
            if result == SQLITE_ROW {
                let data = try LocalRuntimeSQLite.blob(statement, 0, column: "envelope_json")
                rows.append(try JSONDecoder().decode(RuntimeEventEnvelope.self, from: data))
            } else if result == SQLITE_DONE {
                return rows
            } else {
                throw LocalRuntimeStorageError.sqliteStepFailed(sql: sql, message: database.sqliteMessage)
            }
        }
    }
}
