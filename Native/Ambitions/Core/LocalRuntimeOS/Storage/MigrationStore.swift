import Foundation
import SQLite3

let migrationStoreSchemaVersion = "migration_store.native.v1"

enum MigrationStoreRecordKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case dryRun = "dry_run"
    case invariantReport = "invariant_report"
    case backupReference = "backup_reference"
    case rollbackReference = "rollback_reference"
}

struct MigrationStoreRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: MigrationStoreRecordKind
    let createdAt: String
    let sourceLedgerSchemaVersion: String
    let targetLedgerSchemaVersion: String
    let migrationExecutionAllowed: Bool
    let relatedBackupID: String?
    let payloadChecksum: String
    let payloadData: Data
    let schemaVersion: String

    init(
        id: String,
        kind: MigrationStoreRecordKind,
        createdAt: String,
        sourceLedgerSchemaVersion: String,
        targetLedgerSchemaVersion: String,
        migrationExecutionAllowed: Bool,
        relatedBackupID: String?,
        payloadData: Data,
        schemaVersion: String = migrationStoreSchemaVersion
    ) {
        self.id = id
        self.kind = kind
        self.createdAt = createdAt
        self.sourceLedgerSchemaVersion = sourceLedgerSchemaVersion
        self.targetLedgerSchemaVersion = targetLedgerSchemaVersion
        self.migrationExecutionAllowed = migrationExecutionAllowed
        self.relatedBackupID = relatedBackupID?.trimmingCharacters(in: .whitespacesAndNewlines).storageNilIfEmpty
        self.payloadChecksum = LocalRuntimeStorageChecksum.sha256Hex(for: payloadData)
        self.payloadData = payloadData
        self.schemaVersion = schemaVersion
    }
}

struct MigrationStorePlanSummary: Codable, Sendable, Equatable, Hashable {
    let planSchemaVersion: String
    let sourceLedgerSchemaVersion: String
    let targetLedgerSchemaVersion: String
    let mutationEntryCount: Int
    let blockerCount: Int
    let executionAllowed: Bool

    init(plan: MigrationPlan) {
        planSchemaVersion = plan.schemaVersion
        sourceLedgerSchemaVersion = plan.sourceLedgerSchemaVersion
        targetLedgerSchemaVersion = plan.targetLedgerSchemaVersion
        mutationEntryCount = plan.mutationEntries.count
        blockerCount = plan.executionBlockers.count
        executionAllowed = plan.executionAllowed
    }
}

struct MigrationStoreHealth: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let recordCount: Int
    let executionAllowedRecordCount: Int
    let storageTier: LocalRuntimeStorageTier
}

actor MigrationStore {
    private let databaseURL: URL

    init(databaseURL: URL) {
        self.databaseURL = databaseURL
    }

    static func defaultLiveStore(fileManager: FileManager = .default) -> MigrationStore {
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: "/tmp", isDirectory: true)
        return MigrationStore(
            databaseURL: supportDirectory
                .appendingPathComponent("AmbitionsLocalRuntimeOS", isDirectory: true)
                .appendingPathComponent("MigrationStore.sqlite", isDirectory: false)
        )
    }

    func recordDryRun(
        id: String,
        plan: MigrationPlan,
        relatedBackupID: String?,
        createdAt: String
    ) async throws -> MigrationStoreRecord {
        let summary = MigrationStorePlanSummary(plan: plan)
        let payload = try LocalRuntimeStorageCoding.encode(summary)
        let record = MigrationStoreRecord(
            id: id,
            kind: .dryRun,
            createdAt: createdAt,
            sourceLedgerSchemaVersion: plan.sourceLedgerSchemaVersion,
            targetLedgerSchemaVersion: plan.targetLedgerSchemaVersion,
            migrationExecutionAllowed: false,
            relatedBackupID: relatedBackupID,
            payloadData: payload
        )
        try await save(record)
        return record
    }

    func save(_ record: MigrationStoreRecord) async throws {
        guard record.payloadData.isEmpty == false else {
            throw LocalRuntimeStorageError.emptyPayload(id: record.id)
        }
        guard record.migrationExecutionAllowed == false else {
            throw LocalRuntimeStorageError.sqliteStepFailed(sql: "migration_store", message: "MigrationStore records cannot authorize execution")
        }
        guard LocalRuntimeStorageChecksum.sha256Hex(for: record.payloadData) == record.payloadChecksum else {
            throw LocalRuntimeStorageError.checksumMismatch(id: record.id)
        }
        let database = try openDatabase()
        try createSchema(database)
        try upsert(record, database: database)
    }

    func fetch(id: String) async throws -> MigrationStoreRecord? {
        let database = try openDatabase()
        try createSchema(database)
        return try select(sql: "SELECT * FROM migration_records WHERE record_id = ?", database: database) {
            try LocalRuntimeSQLite.bind(id, to: $0, at: 1, parameter: "record_id")
        }.first
    }

    func list(kind: MigrationStoreRecordKind? = nil) async throws -> [MigrationStoreRecord] {
        let database = try openDatabase()
        try createSchema(database)
        if let kind {
            return try select(sql: "SELECT * FROM migration_records WHERE kind = ? ORDER BY created_at DESC", database: database) {
                try LocalRuntimeSQLite.bind(kind.rawValue, to: $0, at: 1, parameter: "kind")
            }
        }
        return try select(sql: "SELECT * FROM migration_records ORDER BY created_at DESC", database: database)
    }

    func health() async throws -> MigrationStoreHealth {
        let records = try await list()
        return MigrationStoreHealth(
            schemaVersion: migrationStoreSchemaVersion,
            recordCount: records.count,
            executionAllowedRecordCount: records.filter(\.migrationExecutionAllowed).count,
            storageTier: .migrationStore
        )
    }
}

private extension MigrationStore {
    func openDatabase() throws -> LocalRuntimeSQLiteDatabase {
        try LocalRuntimeSQLiteDatabase(url: databaseURL)
    }

    func createSchema(_ database: LocalRuntimeSQLiteDatabase) throws {
        try database.execute(
            """
            CREATE TABLE IF NOT EXISTS migration_records (
                record_id TEXT PRIMARY KEY,
                kind TEXT NOT NULL,
                created_at TEXT NOT NULL,
                source_ledger_schema_version TEXT NOT NULL,
                target_ledger_schema_version TEXT NOT NULL,
                migration_execution_allowed INTEGER NOT NULL,
                related_backup_id TEXT,
                payload_checksum TEXT NOT NULL,
                payload_json BLOB NOT NULL,
                schema_version TEXT NOT NULL
            );
            """
        )
        try database.execute("CREATE INDEX IF NOT EXISTS migration_records_kind_idx ON migration_records(kind)")
        try database.execute("CREATE INDEX IF NOT EXISTS migration_records_created_idx ON migration_records(created_at)")
    }

    func upsert(_ record: MigrationStoreRecord, database: LocalRuntimeSQLiteDatabase) throws {
        let sql =
            """
            INSERT INTO migration_records (
                record_id, kind, created_at, source_ledger_schema_version, target_ledger_schema_version,
                migration_execution_allowed, related_backup_id, payload_checksum, payload_json, schema_version
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(record_id) DO UPDATE SET
                kind = excluded.kind,
                created_at = excluded.created_at,
                source_ledger_schema_version = excluded.source_ledger_schema_version,
                target_ledger_schema_version = excluded.target_ledger_schema_version,
                migration_execution_allowed = excluded.migration_execution_allowed,
                related_backup_id = excluded.related_backup_id,
                payload_checksum = excluded.payload_checksum,
                payload_json = excluded.payload_json,
                schema_version = excluded.schema_version
            """
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        try LocalRuntimeSQLite.bind(record.id, to: statement, at: 1, parameter: "record_id")
        try LocalRuntimeSQLite.bind(record.kind.rawValue, to: statement, at: 2, parameter: "kind")
        try LocalRuntimeSQLite.bind(record.createdAt, to: statement, at: 3, parameter: "created_at")
        try LocalRuntimeSQLite.bind(record.sourceLedgerSchemaVersion, to: statement, at: 4, parameter: "source_ledger_schema_version")
        try LocalRuntimeSQLite.bind(record.targetLedgerSchemaVersion, to: statement, at: 5, parameter: "target_ledger_schema_version")
        try LocalRuntimeSQLite.bind(record.migrationExecutionAllowed ? 1 : 0, to: statement, at: 6, parameter: "migration_execution_allowed")
        try LocalRuntimeSQLite.bind(record.relatedBackupID, to: statement, at: 7, parameter: "related_backup_id")
        try LocalRuntimeSQLite.bind(record.payloadChecksum, to: statement, at: 8, parameter: "payload_checksum")
        try LocalRuntimeSQLite.bind(record.payloadData, to: statement, at: 9, parameter: "payload_json")
        try LocalRuntimeSQLite.bind(record.schemaVersion, to: statement, at: 10, parameter: "schema_version")
        guard sqlite3_step(statement) == SQLITE_DONE else {
            throw LocalRuntimeStorageError.sqliteStepFailed(sql: sql, message: database.sqliteMessage)
        }
    }

    func select(
        sql: String,
        database: LocalRuntimeSQLiteDatabase,
        binder: ((OpaquePointer) throws -> Void)? = nil
    ) throws -> [MigrationStoreRecord] {
        let statement = try database.prepare(sql)
        defer { sqlite3_finalize(statement) }
        try binder?(statement)

        var records: [MigrationStoreRecord] = []
        while true {
            let result = sqlite3_step(statement)
            if result == SQLITE_ROW {
                let kindRaw = try LocalRuntimeSQLite.text(statement, 1, column: "kind")
                guard let kind = MigrationStoreRecordKind(rawValue: kindRaw) else {
                    throw LocalRuntimeStorageError.sqliteCorruptText(column: "kind")
                }
                let payload = try LocalRuntimeSQLite.blob(statement, 8, column: "payload_json")
                let checksum = try LocalRuntimeSQLite.text(statement, 7, column: "payload_checksum")
                let id = try LocalRuntimeSQLite.text(statement, 0, column: "record_id")
                guard LocalRuntimeStorageChecksum.sha256Hex(for: payload) == checksum else {
                    throw LocalRuntimeStorageError.checksumMismatch(id: id)
                }
                let record = MigrationStoreRecord(
                    id: id,
                    kind: kind,
                    createdAt: try LocalRuntimeSQLite.text(statement, 2, column: "created_at"),
                    sourceLedgerSchemaVersion: try LocalRuntimeSQLite.text(statement, 3, column: "source_ledger_schema_version"),
                    targetLedgerSchemaVersion: try LocalRuntimeSQLite.text(statement, 4, column: "target_ledger_schema_version"),
                    migrationExecutionAllowed: LocalRuntimeSQLite.int64(statement, 5) != 0,
                    relatedBackupID: LocalRuntimeSQLite.optionalText(statement, 6),
                    payloadData: payload,
                    schemaVersion: try LocalRuntimeSQLite.text(statement, 9, column: "schema_version")
                )
                guard record.schemaVersion == migrationStoreSchemaVersion else {
                    throw LocalRuntimeStorageError.unsupportedSchema(expected: migrationStoreSchemaVersion, actual: record.schemaVersion)
                }
                records.append(record)
            } else if result == SQLITE_DONE {
                return records
            } else {
                throw LocalRuntimeStorageError.sqliteStepFailed(sql: sql, message: database.sqliteMessage)
            }
        }
    }
}
