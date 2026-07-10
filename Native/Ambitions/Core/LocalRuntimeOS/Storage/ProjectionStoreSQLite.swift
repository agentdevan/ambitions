import Foundation
import SQLite3

let projectionStoreSQLiteSchemaVersion = "projection_store_sqlite.native.v1"

struct StoredProjectionRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: ProjectionID
    let cursor: ProjectionCursor
    let payloadChecksum: String
    let payloadSchemaVersion: String
    let payloadData: Data
    let materializedAt: String
    let updatedAt: String
}

struct ProjectionStoreSQLiteHealth: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let projectionCount: Int
    let storedProjectionIDs: [ProjectionID]
    let storageTier: LocalRuntimeStorageTier
}

struct ProjectionStoreCommitReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let storedProjectionIDs: [ProjectionID]
    let cursorSequencesByProjectionID: [ProjectionID: Int64]
    let cursorChecksumsByProjectionID: [ProjectionID: String]
    let updatedAt: String
    let storageTier: LocalRuntimeStorageTier
    let localOnly: Bool
    let schemaVersion: String

    init(
        records: [StoredProjectionRecord],
        updatedAt: String,
        schemaVersion: String = projectionStoreSQLiteSchemaVersion
    ) {
        storedProjectionIDs = records.map(\.id).sorted()
        cursorSequencesByProjectionID = Dictionary(uniqueKeysWithValues: records.map { ($0.id, $0.cursor.sequence) })
        cursorChecksumsByProjectionID = Dictionary(uniqueKeysWithValues: records.map { ($0.id, $0.cursor.checksum) })
        self.updatedAt = updatedAt
        storageTier = .projectionStoreSQLite
        localOnly = true
        self.schemaVersion = schemaVersion
        id = "projection-store.commit.\(storedProjectionIDs.map(\.rawValue).joined(separator: ".")).\(updatedAt)"
    }
}

actor ProjectionStoreSQLite {
    private let databaseURL: URL

    init(databaseURL: URL) {
        self.databaseURL = databaseURL
    }

    static func defaultLiveStore(fileManager: FileManager = .default) -> ProjectionStoreSQLite {
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: "/tmp", isDirectory: true)
        return ProjectionStoreSQLite(
            databaseURL: supportDirectory
                .appendingPathComponent("AmbitionsLocalRuntimeOS", isDirectory: true)
                .appendingPathComponent("ProjectionStore.sqlite", isDirectory: false)
        )
    }

    func save(batch: ProjectionMaterializationBatch, updatedAt: String) async throws {
        try await save(batch.allStoredRecords(updatedAt: updatedAt))
    }

    func saveWithReceipt(batch: ProjectionMaterializationBatch, updatedAt: String) async throws -> ProjectionStoreCommitReceipt {
        let records = try batch.allStoredRecords(updatedAt: updatedAt)
        try await save(records)
        return ProjectionStoreCommitReceipt(records: records, updatedAt: updatedAt)
    }

    func save(_ records: [StoredProjectionRecord]) async throws {
        let database = try openDatabase()
        try createSchema(database)
        try database.transaction {
            for record in records {
                try upsert(record, database: database)
            }
        }
    }

    func fetchRecord(id: ProjectionID) async throws -> StoredProjectionRecord? {
        let database = try openDatabase()
        try createSchema(database)
        let rows = try selectRecords(sql: "SELECT * FROM projections WHERE projection_id = ?", database: database) {
            try LocalRuntimeSQLite.bind(id.rawValue, to: $0, at: 1, parameter: "projection_id")
        }
        return rows.first
    }

    func fetchCursor(id: ProjectionID) async throws -> ProjectionCursor? {
        try await fetchRecord(id: id)?.cursor
    }

    func fetchAllRecords() async throws -> [StoredProjectionRecord] {
        let database = try openDatabase()
        try createSchema(database)
        return try selectRecords(sql: "SELECT * FROM projections ORDER BY projection_id ASC", database: database)
    }

    func health() async throws -> ProjectionStoreSQLiteHealth {
        let records = try await fetchAllRecords()
        return ProjectionStoreSQLiteHealth(
            schemaVersion: projectionStoreSQLiteSchemaVersion,
            projectionCount: records.count,
            storedProjectionIDs: records.map(\.id).sorted(),
            storageTier: .projectionStoreSQLite
        )
    }
}

extension ProjectionMaterializationBatch {
    func allStoredRecords(updatedAt: String) throws -> [StoredProjectionRecord] {
        try [
            storedRecord(id: .today, payload: today, cursor: today.cursor, updatedAt: updatedAt),
            storedRecord(id: .goals, payload: goals, cursor: goals.cursor, updatedAt: updatedAt),
            storedRecord(id: .time, payload: time, cursor: time.cursor, updatedAt: updatedAt),
            storedRecord(id: .you, payload: you, cursor: you.cursor, updatedAt: updatedAt),
            storedRecord(id: .search, payload: search, cursor: search.cursor, updatedAt: updatedAt),
            storedRecord(id: .widget, payload: widget, cursor: widget.cursor, updatedAt: updatedAt),
            storedRecord(id: .appIntent, payload: appIntent, cursor: appIntent.cursor, updatedAt: updatedAt),
            storedRecord(id: .receipt, payload: receipt, cursor: receipt.cursor, updatedAt: updatedAt),
            storedRecord(id: .privacy, payload: privacy, cursor: privacy.cursor, updatedAt: updatedAt)
        ]
    }

    private func storedRecord<Value: Codable>(
        id: ProjectionID,
        payload: Value,
        cursor: ProjectionCursor,
        updatedAt: String
    ) throws -> StoredProjectionRecord {
        let data = try LocalRuntimeStorageCoding.encode(payload)
        return StoredProjectionRecord(
            id: id,
            cursor: cursor,
            payloadChecksum: LocalRuntimeStorageChecksum.sha256Hex(for: data),
            payloadSchemaVersion: projectionStoreSQLiteSchemaVersion,
            payloadData: data,
            materializedAt: cursor.materializedAt,
            updatedAt: updatedAt
        )
    }
}

private extension ProjectionStoreSQLite {
    func openDatabase() throws -> LocalRuntimeSQLiteDatabase {
        try LocalRuntimeSQLiteDatabase(url: databaseURL)
    }

    func createSchema(_ database: LocalRuntimeSQLiteDatabase) throws {
        try database.execute(
            """
            CREATE TABLE IF NOT EXISTS projections (
                projection_id TEXT PRIMARY KEY,
                event_sequence INTEGER NOT NULL,
                event_id TEXT,
                cursor_checksum TEXT NOT NULL,
                payload_checksum TEXT NOT NULL,
                materialized_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                cursor_json BLOB NOT NULL,
                payload_schema_version TEXT NOT NULL,
                payload_json BLOB NOT NULL
            );
            """
        )
        try database.execute("CREATE INDEX IF NOT EXISTS projections_event_sequence_idx ON projections(event_sequence)")
        try database.execute("CREATE INDEX IF NOT EXISTS projections_materialized_idx ON projections(materialized_at)")
    }

    func upsert(_ record: StoredProjectionRecord, database: LocalRuntimeSQLiteDatabase) throws {
        guard LocalRuntimeStorageChecksum.sha256Hex(for: record.payloadData) == record.payloadChecksum else {
            throw LocalRuntimeStorageError.checksumMismatch(id: record.id.rawValue)
        }
        let cursorData = try LocalRuntimeStorageCoding.encode(record.cursor)
        let sql =
            """
            INSERT INTO projections (
                projection_id, event_sequence, event_id, cursor_checksum, payload_checksum,
                materialized_at, updated_at, cursor_json, payload_schema_version, payload_json
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(projection_id) DO UPDATE SET
                event_sequence = excluded.event_sequence,
                event_id = excluded.event_id,
                cursor_checksum = excluded.cursor_checksum,
                payload_checksum = excluded.payload_checksum,
                materialized_at = excluded.materialized_at,
                updated_at = excluded.updated_at,
                cursor_json = excluded.cursor_json,
                payload_schema_version = excluded.payload_schema_version,
                payload_json = excluded.payload_json
            """
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        try LocalRuntimeSQLite.bind(record.id.rawValue, to: statement, at: 1, parameter: "projection_id")
        try LocalRuntimeSQLite.bind(record.cursor.sequence, to: statement, at: 2, parameter: "event_sequence")
        try LocalRuntimeSQLite.bind(record.cursor.eventCursor?.eventID, to: statement, at: 3, parameter: "event_id")
        try LocalRuntimeSQLite.bind(record.cursor.checksum, to: statement, at: 4, parameter: "cursor_checksum")
        try LocalRuntimeSQLite.bind(record.payloadChecksum, to: statement, at: 5, parameter: "payload_checksum")
        try LocalRuntimeSQLite.bind(record.materializedAt, to: statement, at: 6, parameter: "materialized_at")
        try LocalRuntimeSQLite.bind(record.updatedAt, to: statement, at: 7, parameter: "updated_at")
        try LocalRuntimeSQLite.bind(cursorData, to: statement, at: 8, parameter: "cursor_json")
        try LocalRuntimeSQLite.bind(record.payloadSchemaVersion, to: statement, at: 9, parameter: "payload_schema_version")
        try LocalRuntimeSQLite.bind(record.payloadData, to: statement, at: 10, parameter: "payload_json")
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw LocalRuntimeStorageError.sqliteStepFailed(sql: sql, message: database.sqliteMessage)
        }
    }

    func selectRecords(
        sql: String,
        database: LocalRuntimeSQLiteDatabase,
        binder: ((OpaquePointer) throws -> Void)? = nil
    ) throws -> [StoredProjectionRecord] {
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        try binder?(statement)

        var rows: [StoredProjectionRecord] = []
        while true {
            let result = sqlite3_step(statement)
            if result == SQLITE_ROW {
                let idRaw = try LocalRuntimeSQLite.text(statement, 0, column: "projection_id")
                guard let id = ProjectionID(rawValue: idRaw) else {
                    throw LocalRuntimeStorageError.sqliteCorruptText(column: "projection_id")
                }
                let cursorData = try LocalRuntimeSQLite.blob(statement, 7, column: "cursor_json")
                let payloadData = try LocalRuntimeSQLite.blob(statement, 9, column: "payload_json")
                let payloadChecksum = try LocalRuntimeSQLite.text(statement, 4, column: "payload_checksum")
                guard LocalRuntimeStorageChecksum.sha256Hex(for: payloadData) == payloadChecksum else {
                    throw LocalRuntimeStorageError.checksumMismatch(id: id.rawValue)
                }
                rows.append(StoredProjectionRecord(
                    id: id,
                    cursor: try LocalRuntimeStorageCoding.decode(ProjectionCursor.self, from: cursorData),
                    payloadChecksum: payloadChecksum,
                    payloadSchemaVersion: try LocalRuntimeSQLite.text(statement, 8, column: "payload_schema_version"),
                    payloadData: payloadData,
                    materializedAt: try LocalRuntimeSQLite.text(statement, 5, column: "materialized_at"),
                    updatedAt: try LocalRuntimeSQLite.text(statement, 6, column: "updated_at")
                ))
            } else if result == SQLITE_DONE {
                return rows
            } else {
                throw LocalRuntimeStorageError.sqliteStepFailed(sql: sql, message: database.sqliteMessage)
            }
        }
    }
}
