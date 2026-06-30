import Foundation

let appGroupSnapshotStoreSchemaVersion = "app_group_snapshot_store.native.v1"

struct AppGroupSnapshotRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let snapshotKind: String
    let createdAt: String
    let privacyClasses: [EventLedgerPrivacyClassification]
    let containsPrivateRuntimeData: Bool
    let payloadChecksum: String
    let payloadData: Data
    let schemaVersion: String

    init(
        id: String,
        snapshotKind: String,
        createdAt: String,
        privacyClasses: [EventLedgerPrivacyClassification],
        containsPrivateRuntimeData: Bool,
        payloadData: Data,
        schemaVersion: String = appGroupSnapshotStoreSchemaVersion
    ) {
        self.id = id
        self.snapshotKind = snapshotKind
        self.createdAt = createdAt
        self.privacyClasses = Array(Set(privacyClasses)).sorted { $0.rawValue < $1.rawValue }
        self.containsPrivateRuntimeData = containsPrivateRuntimeData
        self.payloadChecksum = LocalRuntimeStorageChecksum.sha256Hex(for: payloadData)
        self.payloadData = payloadData
        self.schemaVersion = schemaVersion
    }

    var isSafeForExternalProcess: Bool {
        containsPrivateRuntimeData == false &&
            privacyClasses.contains(.privateUserText) == false &&
            privacyClasses.contains(.sensitive) == false
    }
}

struct AppGroupSnapshotStoreHealth: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let snapshotCount: Int
    let storageTier: LocalRuntimeStorageTier
}

actor AppGroupSnapshotStore {
    static let appGroupIdentifier = "group.com.ambitions.shared"
    static let relativeDirectory = "ExternalSnapshots"

    private let rootDirectory: URL
    private let fileManager = FileManager.default

    init(rootDirectory: URL) {
        self.rootDirectory = rootDirectory
    }

    static func defaultLiveStore() -> AppGroupSnapshotStore {
        let fileManager = FileManager.default
        let root: URL
        if let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            root = groupURL.appendingPathComponent(relativeDirectory, isDirectory: true)
        } else {
            root = (fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: "/tmp", isDirectory: true))
                .appendingPathComponent(relativeDirectory, isDirectory: true)
        }
        return AppGroupSnapshotStore(rootDirectory: root)
    }

    func write(_ record: AppGroupSnapshotRecord) async throws {
        guard record.isSafeForExternalProcess else {
            throw LocalRuntimeStorageError.unsafeExternalSnapshot(id: record.id)
        }
        guard record.payloadData.isEmpty == false else {
            throw LocalRuntimeStorageError.emptyPayload(id: record.id)
        }
        guard LocalRuntimeStorageChecksum.sha256Hex(for: record.payloadData) == record.payloadChecksum else {
            throw LocalRuntimeStorageError.checksumMismatch(id: record.id)
        }
        try ensureRoot()
        let fileURL = try url(for: record.id)
        try LocalRuntimeStorageCoding.encode(record).write(to: fileURL, options: [.atomic])
    }

    func read(id: String) async throws -> AppGroupSnapshotRecord {
        let fileURL = try url(for: id)
        let record = try LocalRuntimeStorageCoding.decode(AppGroupSnapshotRecord.self, from: Data(contentsOf: fileURL))
        guard record.schemaVersion == appGroupSnapshotStoreSchemaVersion else {
            throw LocalRuntimeStorageError.unsupportedSchema(expected: appGroupSnapshotStoreSchemaVersion, actual: record.schemaVersion)
        }
        guard record.isSafeForExternalProcess else {
            throw LocalRuntimeStorageError.unsafeExternalSnapshot(id: record.id)
        }
        guard LocalRuntimeStorageChecksum.sha256Hex(for: record.payloadData) == record.payloadChecksum else {
            throw LocalRuntimeStorageError.checksumMismatch(id: record.id)
        }
        return record
    }

    func listSnapshots() async throws -> [AppGroupSnapshotRecord] {
        try ensureRoot()
        return try fileManager.contentsOfDirectory(at: rootDirectory, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasSuffix(".snapshot.json") }
            .map { try LocalRuntimeStorageCoding.decode(AppGroupSnapshotRecord.self, from: Data(contentsOf: $0)) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func health() async throws -> AppGroupSnapshotStoreHealth {
        let snapshots = try await listSnapshots()
        return AppGroupSnapshotStoreHealth(
            schemaVersion: appGroupSnapshotStoreSchemaVersion,
            snapshotCount: snapshots.count,
            storageTier: .appGroupSnapshotStore
        )
    }
}

private extension AppGroupSnapshotStore {
    func ensureRoot() throws {
        try fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
    }

    func url(for id: String) throws -> URL {
        let cleanID = try validatedIdentifier(id)
        return rootDirectory.appendingPathComponent("\(cleanID).snapshot.json", isDirectory: false)
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
