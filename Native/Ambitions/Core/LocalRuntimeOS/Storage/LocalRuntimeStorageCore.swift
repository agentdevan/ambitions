import CryptoKit
import Foundation
import SQLite3

let localRuntimeStorageCoreSchemaVersion = "local_runtime_storage_core.native.v1"

enum LocalRuntimeStorageTier: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case canonicalRuntimeStoreGeneration = "canonical_runtime_store_generation"
    case eventStoreSQLite = "event_store_sqlite"
    case objectStoreSwiftData = "object_store_swiftdata"
    case projectionStoreSQLite = "projection_store_sqlite"
    case searchStoreFTS = "search_store_fts"
    case blobStoreFileSystem = "blob_store_file_system"
    case appGroupSnapshotStore = "app_group_snapshot_store"
    case backupStore = "backup_store"
    case migrationStore = "migration_store"
}

enum LocalRuntimeStoragePrivacyScope: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case privateRuntime = "private_runtime"
    case redactedExternalSnapshot = "redacted_external_snapshot"
    case publicReference = "public_reference"
    case migrationMetadata = "migration_metadata"
}

struct LocalRuntimeStorageTierDescriptor: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: LocalRuntimeStorageTier
    let rootPath: String
    let privacyScope: LocalRuntimeStoragePrivacyScope
    let authoritativeFor: [String]
    let excludedResponsibilities: [String]
    let schemaVersion: String

    init(
        id: LocalRuntimeStorageTier,
        rootPath: String,
        privacyScope: LocalRuntimeStoragePrivacyScope,
        authoritativeFor: [String],
        excludedResponsibilities: [String],
        schemaVersion: String = localRuntimeStorageCoreSchemaVersion
    ) {
        self.id = id
        self.rootPath = rootPath
        self.privacyScope = privacyScope
        self.authoritativeFor = Self.orderedUnique(authoritativeFor)
        self.excludedResponsibilities = Self.orderedUnique(excludedResponsibilities)
        self.schemaVersion = schemaVersion
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct LocalRuntimeStorageManifest: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let tiers: [LocalRuntimeStorageTierDescriptor]
    let commandEventProjectionReceiptReplayRequired: Bool
    let swiftDataIsOnlyObjectStore: Bool

    static let current = LocalRuntimeStorageManifest(
        tiers: [
            LocalRuntimeStorageTierDescriptor(
                id: .canonicalRuntimeStoreGeneration,
                rootPath: "Core/LocalRuntimeOS/Storage/CanonicalRuntimeStore",
                privacyScope: .privateRuntime,
                authoritativeFor: [
                    "canonical generation identity",
                    "runtime authority schema",
                    "atomic active-store selection",
                ],
                excludedResponsibilities: [
                    "central runtime wiring before cutover",
                    "extension access",
                    "migration authorization",
                    "semantic command policy",
                ]
            ),
            LocalRuntimeStorageTierDescriptor(
                id: .eventStoreSQLite,
                rootPath: "Core/LocalRuntimeOS/Storage/EventStoreSQLite",
                privacyScope: .privateRuntime,
                authoritativeFor: ["runtime event envelopes", "append ordering", "event checksum chain", "causal cursors"],
                excludedResponsibilities: ["SwiftData object graph", "projection payload ownership", "external side effects"]
            ),
            LocalRuntimeStorageTierDescriptor(
                id: .objectStoreSwiftData,
                rootPath: "Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData",
                privacyScope: .privateRuntime,
                authoritativeFor: ["app-facing object records", "repository mapped domain snapshots", "bounded object queries"],
                excludedResponsibilities: ["event journal authority", "FTS index authority", "blob vault authority", "migration execution approval"]
            ),
            LocalRuntimeStorageTierDescriptor(
                id: .projectionStoreSQLite,
                rootPath: "Core/LocalRuntimeOS/Storage/ProjectionStoreSQLite",
                privacyScope: .privateRuntime,
                authoritativeFor: ["materialized projection payloads", "projection cursors", "projection checksums"],
                excludedResponsibilities: ["domain object mutation", "command validation", "external snapshots"]
            ),
            LocalRuntimeStorageTierDescriptor(
                id: .searchStoreFTS,
                rootPath: "Core/LocalRuntimeOS/Storage/SearchStoreFTS",
                privacyScope: .privateRuntime,
                authoritativeFor: ["local FTS rows", "search result provenance", "index rebuild cursor"],
                excludedResponsibilities: ["semantic cloud search", "private graph egress", "domain mutation"]
            ),
            LocalRuntimeStorageTierDescriptor(
                id: .blobStoreFileSystem,
                rootPath: "Core/LocalRuntimeOS/Storage/BlobStoreFileSystem",
                privacyScope: .privateRuntime,
                authoritativeFor: ["large opaque payloads", "attachment checksums", "file-protection class records"],
                excludedResponsibilities: ["queryable domain columns", "event ordering", "migration approval"]
            ),
            LocalRuntimeStorageTierDescriptor(
                id: .appGroupSnapshotStore,
                rootPath: "Core/LocalRuntimeOS/Storage/AppGroupSnapshotStore",
                privacyScope: .redactedExternalSnapshot,
                authoritativeFor: ["sanitized widget snapshots", "sanitized share-extension handoff snapshots"],
                excludedResponsibilities: ["full private graph access", "extension-side mutation", "private text exposure"]
            ),
            LocalRuntimeStorageTierDescriptor(
                id: .backupStore,
                rootPath: "Core/LocalRuntimeOS/Storage/BackupStore",
                privacyScope: .privateRuntime,
                authoritativeFor: ["encrypted backup package slots", "backup manifests", "backup checksums"],
                excludedResponsibilities: ["migration execution", "CloudKit authority", "public reference packs"]
            ),
            LocalRuntimeStorageTierDescriptor(
                id: .migrationStore,
                rootPath: "Core/LocalRuntimeOS/Storage/MigrationStore",
                privacyScope: .migrationMetadata,
                authoritativeFor: ["migration dry-run receipts", "invariant summaries", "rollback references"],
                excludedResponsibilities: ["destructive migration execution without gates", "object mutation", "backup payload storage"]
            )
        ]
    )

    init(
        schemaVersion: String = localRuntimeStorageCoreSchemaVersion,
        tiers: [LocalRuntimeStorageTierDescriptor],
        commandEventProjectionReceiptReplayRequired: Bool = true,
        swiftDataIsOnlyObjectStore: Bool = true
    ) {
        self.schemaVersion = schemaVersion
        self.tiers = tiers.sorted { $0.id.rawValue < $1.id.rawValue }
        self.commandEventProjectionReceiptReplayRequired = commandEventProjectionReceiptReplayRequired
        self.swiftDataIsOnlyObjectStore = swiftDataIsOnlyObjectStore
    }

    func descriptor(for tier: LocalRuntimeStorageTier) -> LocalRuntimeStorageTierDescriptor? {
        tiers.first { $0.id == tier }
    }
}

enum LocalRuntimeStorageError: Error, Sendable, Equatable {
    case protectedDataUnavailable
    case canonicalManifestMissing
    case canonicalManifestMalformed
    case canonicalManifestMismatch(field: String)
    case canonicalManifestUnverified
    case canonicalFutureManifestSchema(maximumSupported: Int, actual: Int)
    case canonicalUnsupportedManifestSchema(expected: Int, actual: Int)
    case canonicalFutureDatabaseSchema(maximumSupported: Int, actual: Int)
    case canonicalUnsupportedDatabaseSchema(expected: Int, actual: Int)
    case canonicalGenerationAlreadyExists(id: String)
    case canonicalGenerationMissing(id: String)
    case canonicalStorageFull(operation: String)
    case canonicalIOFailure(operation: String)
    case canonicalSQLiteFailure(operation: String, code: Int32, extendedCode: Int32)
    case canonicalIntegrityFailure
    case canonicalForeignKeyFailure
    case canonicalFileProtectionFailure(artifact: String)
    case canonicalPathAuthorityDenied
    case canonicalActivationBusy
    case canonicalActivationLockFailed
    case canonicalFileIdentityChanged(artifact: String)
    case canonicalReadPageTooLarge(maximumBytes: Int)
    case canonicalActivationFailed
    case canonicalActivationStateUnknown
    case canonicalActivationSucceededWithCleanupFailure
    case canonicalStagingCleanupFailed
    case sqliteOpenFailed(path: String, message: String)
    case sqlitePrepareFailed(sql: String, message: String)
    case sqliteStepFailed(sql: String, message: String)
    case sqliteBindFailed(parameter: String, message: String)
    case sqliteMissingRow(table: String, id: String)
    case sqliteCorruptText(column: String)
    case sqliteCorruptBlob(column: String)
    case unsupportedSchema(expected: String, actual: String)
    case checksumMismatch(id: String)
    case unsafeExternalSnapshot(id: String)
    case emptyPayload(id: String)
    case pathEscape(id: String)
}

enum LocalRuntimeStorageChecksum {
    static func sha256Hex(for data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    static func sha256Hex(for string: String) -> String {
        sha256Hex(for: Data(string.utf8))
    }
}

enum LocalRuntimeStorageCoding {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    static let decoder = JSONDecoder()

    static func encode<Value: Encodable>(_ value: Value) throws -> Data {
        try encoder.encode(value)
    }

    static func decode<Value: Decodable>(_ type: Value.Type, from data: Data) throws -> Value {
        try decoder.decode(type, from: data)
    }
}

extension String {
    var storageNilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

final class LocalRuntimeSQLiteDatabase {
    private var handle: OpaquePointer?
    private let url: URL

    init(url: URL) throws {
        self.url = url
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        var db: OpaquePointer?
        let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        guard sqlite3_open_v2(url.path, &db, flags, nil) == SQLITE_OK, let db else {
            let message = db.flatMap { sqlite3_errmsg($0) }.map { String(cString: $0) } ?? "unknown"
            if let db {
                sqlite3_close(db)
            }
            throw LocalRuntimeStorageError.sqliteOpenFailed(path: url.path, message: message)
        }
        handle = db
        try execute("PRAGMA journal_mode = WAL")
        try execute("PRAGMA foreign_keys = ON")
        try execute("PRAGMA synchronous = FULL")
    }

    deinit {
        if let handle {
            sqlite3_close(handle)
        }
    }

    func execute(_ sql: String) throws {
        guard let handle else {
            throw LocalRuntimeStorageError.sqliteOpenFailed(path: url.path, message: "database closed")
        }
        var errorMessage: UnsafeMutablePointer<Int8>?
        let result = sqlite3_exec(handle, sql, nil, nil, &errorMessage)
        if result != SQLITE_OK {
            let message = errorMessage.map { String(cString: $0) } ?? sqliteMessage
            sqlite3_free(errorMessage)
            throw LocalRuntimeStorageError.sqliteStepFailed(sql: sql, message: message)
        }
    }

    func transaction<Value>(_ body: () throws -> Value) throws -> Value {
        try execute("BEGIN IMMEDIATE TRANSACTION")
        do {
            let value = try body()
            try execute("COMMIT")
            return value
        } catch {
            try? execute("ROLLBACK")
            throw error
        }
    }

    func prepare(_ sql: String) throws -> OpaquePointer {
        guard let handle else {
            throw LocalRuntimeStorageError.sqliteOpenFailed(path: url.path, message: "database closed")
        }
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(handle, sql, -1, &statement, nil) == SQLITE_OK, let statement else {
            throw LocalRuntimeStorageError.sqlitePrepareFailed(sql: sql, message: sqliteMessage)
        }
        return statement
    }

    var sqliteMessage: String {
        guard let handle, let message = sqlite3_errmsg(handle) else { return "unknown" }
        return String(cString: message)
    }
}

enum LocalRuntimeSQLite {
    static func bind(_ value: String?, to statement: OpaquePointer, at index: Int32, parameter: String) throws {
        let result: Int32
        if let value {
            result = sqlite3_bind_text(statement, index, value, -1, SQLITE_TRANSIENT)
        } else {
            result = sqlite3_bind_null(statement, index)
        }
        guard result == SQLITE_OK else {
            throw LocalRuntimeStorageError.sqliteBindFailed(parameter: parameter, message: "sqlite bind failed")
        }
    }

    static func bind(_ value: Int64, to statement: OpaquePointer, at index: Int32, parameter: String) throws {
        guard sqlite3_bind_int64(statement, index, value) == SQLITE_OK else {
            throw LocalRuntimeStorageError.sqliteBindFailed(parameter: parameter, message: "sqlite bind failed")
        }
    }

    static func bind(_ value: Int, to statement: OpaquePointer, at index: Int32, parameter: String) throws {
        try bind(Int64(value), to: statement, at: index, parameter: parameter)
    }

    static func bind(_ value: Data, to statement: OpaquePointer, at index: Int32, parameter: String) throws {
        let result = value.withUnsafeBytes { buffer in
            sqlite3_bind_blob(statement, index, buffer.baseAddress, Int32(value.count), SQLITE_TRANSIENT)
        }
        guard result == SQLITE_OK else {
            throw LocalRuntimeStorageError.sqliteBindFailed(parameter: parameter, message: "sqlite bind failed")
        }
    }

    static func text(_ statement: OpaquePointer, _ index: Int32, column: String) throws -> String {
        guard let pointer = sqlite3_column_text(statement, index) else {
            throw LocalRuntimeStorageError.sqliteCorruptText(column: column)
        }
        return String(cString: pointer)
    }

    static func optionalText(_ statement: OpaquePointer, _ index: Int32) -> String? {
        guard sqlite3_column_type(statement, index) != SQLITE_NULL,
              let pointer = sqlite3_column_text(statement, index)
        else { return nil }
        return String(cString: pointer)
    }

    static func int64(_ statement: OpaquePointer, _ index: Int32) -> Int64 {
        sqlite3_column_int64(statement, index)
    }

    static func blob(_ statement: OpaquePointer, _ index: Int32, column: String) throws -> Data {
        guard sqlite3_column_type(statement, index) != SQLITE_NULL,
              let bytes = sqlite3_column_blob(statement, index)
        else {
            throw LocalRuntimeStorageError.sqliteCorruptBlob(column: column)
        }
        return Data(bytes: bytes, count: Int(sqlite3_column_bytes(statement, index)))
    }
}

private let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
