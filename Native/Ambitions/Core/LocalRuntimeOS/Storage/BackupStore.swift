import CryptoKit
import Foundation

let backupStoreSchemaVersion = "backup_store.native.v1"

enum BackupStorePackageKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case preMigration = "pre_migration"
    case userExport = "user_export"
    case restorePoint = "restore_point"
}

struct BackupStoreRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: BackupStorePackageKind
    let createdAt: String
    let encryptedByteCount: Int
    let encryptedSHA256: String
    let plaintextSHA256: String
    let keyID: String
    let relativePackagePath: String
    let schemaVersion: String
}

struct BackupStorePackage: Codable, Sendable, Equatable, Hashable {
    let record: BackupStoreRecord
    let encryptedData: Data
}

struct BackupStoreHealth: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let packageCount: Int
    let packageIDs: [String]
    let storageTier: LocalRuntimeStorageTier
}

actor BackupStore {
    private let rootDirectory: URL
    private let fileManager = FileManager.default

    init(rootDirectory: URL) {
        self.rootDirectory = rootDirectory
    }

    static func defaultLiveStore() -> BackupStore {
        let fileManager = FileManager.default
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: "/tmp", isDirectory: true)
        return BackupStore(
            rootDirectory: supportDirectory
                .appendingPathComponent("AmbitionsLocalRuntimeOS", isDirectory: true)
                .appendingPathComponent("BackupStore", isDirectory: true)
        )
    }

    func saveEncryptedPackage(
        id: String,
        kind: BackupStorePackageKind,
        plaintext: Data,
        key: SymmetricKey,
        keyID: String,
        createdAt: String
    ) async throws -> BackupStoreRecord {
        let cleanID = try validatedIdentifier(id)
        guard plaintext.isEmpty == false else {
            throw LocalRuntimeStorageError.emptyPayload(id: cleanID)
        }
        try ensureRoot()
        let sealedBox = try AES.GCM.seal(plaintext, using: key)
        guard let encrypted = sealedBox.combined else {
            throw LocalRuntimeStorageError.emptyPayload(id: cleanID)
        }
        let encryptedURL = rootDirectory.appendingPathComponent("\(cleanID).backup.bin", isDirectory: false)
        let recordURL = rootDirectory.appendingPathComponent("\(cleanID).backup.json", isDirectory: false)
        try encrypted.write(to: encryptedURL, options: [.atomic])
        let record = BackupStoreRecord(
            id: cleanID,
            kind: kind,
            createdAt: createdAt,
            encryptedByteCount: encrypted.count,
            encryptedSHA256: LocalRuntimeStorageChecksum.sha256Hex(for: encrypted),
            plaintextSHA256: LocalRuntimeStorageChecksum.sha256Hex(for: plaintext),
            keyID: keyID.trimmingCharacters(in: .whitespacesAndNewlines).storageNilIfEmpty ?? "local-user-key",
            relativePackagePath: encryptedURL.lastPathComponent,
            schemaVersion: backupStoreSchemaVersion
        )
        try LocalRuntimeStorageCoding.encode(record).write(to: recordURL, options: [.atomic])
        return record
    }

    func loadEncryptedPackage(id: String) async throws -> BackupStorePackage {
        let record = try await record(id: id)
        let encrypted = try Data(contentsOf: try packageURL(for: record))
        guard LocalRuntimeStorageChecksum.sha256Hex(for: encrypted) == record.encryptedSHA256 else {
            throw LocalRuntimeStorageError.checksumMismatch(id: record.id)
        }
        return BackupStorePackage(record: record, encryptedData: encrypted)
    }

    func decryptPackage(id: String, key: SymmetricKey) async throws -> Data {
        let package = try await loadEncryptedPackage(id: id)
        let sealedBox = try AES.GCM.SealedBox(combined: package.encryptedData)
        let plaintext = try AES.GCM.open(sealedBox, using: key)
        guard LocalRuntimeStorageChecksum.sha256Hex(for: plaintext) == package.record.plaintextSHA256 else {
            throw LocalRuntimeStorageError.checksumMismatch(id: package.record.id)
        }
        return plaintext
    }

    func record(id: String) async throws -> BackupStoreRecord {
        let cleanID = try validatedIdentifier(id)
        let url = rootDirectory.appendingPathComponent("\(cleanID).backup.json", isDirectory: false)
        let record = try LocalRuntimeStorageCoding.decode(BackupStoreRecord.self, from: Data(contentsOf: url))
        guard record.schemaVersion == backupStoreSchemaVersion else {
            throw LocalRuntimeStorageError.unsupportedSchema(expected: backupStoreSchemaVersion, actual: record.schemaVersion)
        }
        return record
    }

    func listRecords() async throws -> [BackupStoreRecord] {
        try ensureRoot()
        return try fileManager.contentsOfDirectory(at: rootDirectory, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasSuffix(".backup.json") }
            .map { try LocalRuntimeStorageCoding.decode(BackupStoreRecord.self, from: Data(contentsOf: $0)) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func health() async throws -> BackupStoreHealth {
        let records = try await listRecords()
        return BackupStoreHealth(
            schemaVersion: backupStoreSchemaVersion,
            packageCount: records.count,
            packageIDs: records.map(\.id).sorted(),
            storageTier: .backupStore
        )
    }
}

private extension BackupStore {
    func ensureRoot() throws {
        try fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
    }

    func packageURL(for record: BackupStoreRecord) throws -> URL {
        guard record.relativePackagePath.contains("/") == false,
              record.relativePackagePath.contains("..") == false
        else {
            throw LocalRuntimeStorageError.pathEscape(id: record.id)
        }
        return rootDirectory.appendingPathComponent(record.relativePackagePath, isDirectory: false)
    }

    func validatedIdentifier(_ id: String) throws -> String {
        let trimmed = id.trimmingCharacters(in: .whitespacesAndNewlines)
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-")
        guard trimmed.isEmpty == false,
              trimmed.rangeOfCharacter(from: allowed.inverted) == nil,
              trimmed.contains("..") == false,
              trimmed.contains("/") == false
        else {
            throw LocalRuntimeStorageError.pathEscape(id: id)
        }
        return trimmed
    }
}
