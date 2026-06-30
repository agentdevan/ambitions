import Foundation

let blobStoreFileSystemSchemaVersion = "blob_store_file_system.native.v1"

enum BlobStoreProtectionClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case completeUntilFirstUserAuthentication = "complete_until_first_user_authentication"
    case complete = "complete"
    case none = "none"
}

struct BlobStoreFileSystemRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let relativePayloadPath: String
    let byteCount: Int
    let sha256: String
    let contentType: String
    let protectionClass: BlobStoreProtectionClass
    let createdAt: String
    let schemaVersion: String
}

struct BlobStoreFileSystemHealth: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let blobCount: Int
    let totalBytes: Int
    let storageTier: LocalRuntimeStorageTier
}

actor BlobStoreFileSystem {
    private let rootDirectory: URL
    private let fileManager = FileManager.default

    init(rootDirectory: URL) {
        self.rootDirectory = rootDirectory
    }

    static func defaultLiveStore() -> BlobStoreFileSystem {
        let fileManager = FileManager.default
        let supportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: "/tmp", isDirectory: true)
        return BlobStoreFileSystem(
            rootDirectory: supportDirectory
                .appendingPathComponent("AmbitionsLocalRuntimeOS", isDirectory: true)
                .appendingPathComponent("BlobStore", isDirectory: true)
        )
    }

    func write(
        id: String,
        data: Data,
        contentType: String,
        protectionClass: BlobStoreProtectionClass,
        createdAt: String
    ) async throws -> BlobStoreFileSystemRecord {
        let cleanID = try validatedIdentifier(id)
        guard data.isEmpty == false else {
            throw LocalRuntimeStorageError.emptyPayload(id: cleanID)
        }
        try ensureRoot()
        let payloadURL = rootDirectory.appendingPathComponent("\(cleanID).blob", isDirectory: false)
        let recordURL = rootDirectory.appendingPathComponent("\(cleanID).metadata.json", isDirectory: false)
        try data.write(to: payloadURL, options: [.atomic])
        try applyProtection(protectionClass, to: payloadURL)
        let record = BlobStoreFileSystemRecord(
            id: cleanID,
            relativePayloadPath: payloadURL.lastPathComponent,
            byteCount: data.count,
            sha256: LocalRuntimeStorageChecksum.sha256Hex(for: data),
            contentType: contentType.trimmingCharacters(in: .whitespacesAndNewlines).storageNilIfEmpty ?? "application/octet-stream",
            protectionClass: protectionClass,
            createdAt: createdAt,
            schemaVersion: blobStoreFileSystemSchemaVersion
        )
        try LocalRuntimeStorageCoding.encode(record).write(to: recordURL, options: [.atomic])
        return record
    }

    func read(id: String) async throws -> Data {
        let record = try await record(id: id)
        let url = try payloadURL(for: record)
        let data = try Data(contentsOf: url)
        guard LocalRuntimeStorageChecksum.sha256Hex(for: data) == record.sha256 else {
            throw LocalRuntimeStorageError.checksumMismatch(id: record.id)
        }
        return data
    }

    func record(id: String) async throws -> BlobStoreFileSystemRecord {
        let cleanID = try validatedIdentifier(id)
        let url = rootDirectory.appendingPathComponent("\(cleanID).metadata.json", isDirectory: false)
        let data = try Data(contentsOf: url)
        let record = try LocalRuntimeStorageCoding.decode(BlobStoreFileSystemRecord.self, from: data)
        guard record.schemaVersion == blobStoreFileSystemSchemaVersion else {
            throw LocalRuntimeStorageError.unsupportedSchema(expected: blobStoreFileSystemSchemaVersion, actual: record.schemaVersion)
        }
        return record
    }

    func delete(id: String) async throws {
        let cleanID = try validatedIdentifier(id)
        let payloadURL = rootDirectory.appendingPathComponent("\(cleanID).blob", isDirectory: false)
        let recordURL = rootDirectory.appendingPathComponent("\(cleanID).metadata.json", isDirectory: false)
        if fileManager.fileExists(atPath: payloadURL.path) {
            try fileManager.removeItem(at: payloadURL)
        }
        if fileManager.fileExists(atPath: recordURL.path) {
            try fileManager.removeItem(at: recordURL)
        }
    }

    func listRecords() async throws -> [BlobStoreFileSystemRecord] {
        try ensureRoot()
        return try fileManager.contentsOfDirectory(at: rootDirectory, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasSuffix(".metadata.json") }
            .map { try LocalRuntimeStorageCoding.decode(BlobStoreFileSystemRecord.self, from: Data(contentsOf: $0)) }
            .sorted { $0.id < $1.id }
    }

    func health() async throws -> BlobStoreFileSystemHealth {
        let records = try await listRecords()
        return BlobStoreFileSystemHealth(
            schemaVersion: blobStoreFileSystemSchemaVersion,
            blobCount: records.count,
            totalBytes: records.reduce(0) { $0 + $1.byteCount },
            storageTier: .blobStoreFileSystem
        )
    }
}

private extension BlobStoreFileSystem {
    func ensureRoot() throws {
        try fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
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

    func payloadURL(for record: BlobStoreFileSystemRecord) throws -> URL {
        guard record.relativePayloadPath.contains("/") == false,
              record.relativePayloadPath.contains("..") == false
        else {
            throw LocalRuntimeStorageError.pathEscape(id: record.id)
        }
        return rootDirectory.appendingPathComponent(record.relativePayloadPath, isDirectory: false)
    }

    func applyProtection(_ protectionClass: BlobStoreProtectionClass, to url: URL) throws {
        #if os(iOS)
        let value: FileProtectionType?
        switch protectionClass {
        case .completeUntilFirstUserAuthentication:
            value = .completeUntilFirstUserAuthentication
        case .complete:
            value = .complete
        case .none:
            value = nil
        }
        if let value {
            try fileManager.setAttributes([.protectionKey: value], ofItemAtPath: url.path)
        }
        #endif
    }
}
