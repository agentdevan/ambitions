import CryptoKit
import Foundation

enum ExternalCreationSource: String, Codable, Sendable, Equatable {
    case shareExtensionText = "share_extension_text"
    case shareExtensionURL = "share_extension_url"
    case appIntent = "app_intent"

    var captureSourceTypeRawValue: String {
        switch self {
        case .shareExtensionText:
            return "share_extension_text"
        case .shareExtensionURL:
            return "share_extension_url"
        case .appIntent:
            return "app_intent"
        }
    }
}

enum ExternalCreationLanding: String, Codable, Sendable, Equatable {
    case captureComposer = "capture_composer"
    case createGoal = "create_goal"
}

struct ExternalCreationRequest: Identifiable, Codable, Sendable, Equatable {
    static let schemaVersion = 1

    let id: String
    let schemaVersion: Int
    let createdAt: String
    let text: String
    let source: ExternalCreationSource
    let sourceApplication: String?
    let sourceURL: String?
    let landing: ExternalCreationLanding

    init(
        id: String,
        createdAt: String,
        text: String,
        source: ExternalCreationSource,
        sourceApplication: String? = nil,
        sourceURL: String? = nil,
        landing: ExternalCreationLanding = .captureComposer,
        schemaVersion: Int = Self.schemaVersion
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.createdAt = createdAt
        self.text = text
        self.source = source
        self.sourceApplication = sourceApplication
        self.sourceURL = sourceURL
        self.landing = landing
    }
}

/// An immutable row identity for a request in the shared handoff queue. The
/// request ID is command idempotency material; this row ID is queue ownership
/// material and is the only value allowed to delete a queued handoff.
struct ExternalCreationQueueRecord: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let request: ExternalCreationRequest
    let requestDigest: String
    /// Written only by the main-app canonical admission path. This is durable
    /// recovery information for a handoff whose authority receipt exists but
    /// whose capture materialization does not.
    var recovery: ExternalCreationQueueRecoveryState?

    init(request: ExternalCreationRequest) throws {
        let bytes = try ExternalCreationQueueRecord.canonicalBytes(for: request)
        let digest = Self.sha256(bytes)
        self.id = "external-handoff.\(digest)"
        self.request = request
        self.requestDigest = digest
        self.recovery = nil
    }

    func isExactReplay(of request: ExternalCreationRequest) -> Bool {
        guard let bytes = try? Self.canonicalBytes(for: request) else { return false }
        return Self.sha256(bytes) == requestDigest && self.request == request
    }

    func isValid() -> Bool {
        guard let bytes = try? Self.canonicalBytes(for: request) else { return false }
        return id == "external-handoff.\(requestDigest)" &&
            Self.sha256(bytes) == requestDigest
    }

    private static func canonicalBytes(for request: ExternalCreationRequest) throws -> Data {
        try ExternalCreationQueue.canonicalEncoder.encode(request)
    }

    private static func sha256(_ data: Data) -> String {
        SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }
}

struct ExternalCreationQueueRecoveryState: Codable, Sendable, Equatable {
    let commandID: String
    let status: String
    let reason: String
    let recordedAt: String

    init(commandID: String, status: String, reason: String, recordedAt: String) {
        self.commandID = commandID
        self.status = status
        self.reason = reason
        self.recordedAt = recordedAt
    }
}

enum ExternalCreationQueueAdmission: Sendable, Equatable {
    case enqueued(recordID: String)
    case replayedExisting(recordID: String)
}

struct ExternalCreationQueue: Codable, Sendable, Equatable {
    static let schemaVersion = 2

    var schemaVersion: Int = Self.schemaVersion
    var records: [ExternalCreationQueueRecord] = []

    var requests: [ExternalCreationRequest] { records.map(\.request) }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case records
        case requests
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case Self.schemaVersion:
            schemaVersion = version
            records = try container.decode([ExternalCreationQueueRecord].self, forKey: .records)
        case 1:
            // A v1 file can be promoted only if every command identity is
            // unique. Conflicting legacy rows cannot be safely acknowledged or
            // attributed to one canonical command, so they fail closed.
            let legacy = try container.decode([ExternalCreationRequest].self, forKey: .requests)
            guard Set(legacy.map(\.id)).count == legacy.count else {
                throw DecodingError.dataCorruptedError(
                    forKey: .requests,
                    in: container,
                    debugDescription: "Legacy external handoff queue has ambiguous request identities."
                )
            }
            schemaVersion = Self.schemaVersion
            records = try legacy.map { try ExternalCreationQueueRecord(request: $0) }
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unsupported external handoff queue schema."
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Self.schemaVersion, forKey: .schemaVersion)
        try container.encode(records, forKey: .records)
    }

    fileprivate static let canonicalEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()
}

enum SharedExternalCreationStoreError: LocalizedError {
    case emptyText
    case unsupportedSchema
    case invalidRequest
    case duplicateRequestIdentity
    case ambiguousRequestIdentity
    case sharedContainerUnavailable
    case recoveryRequired
    case fileCoordinationFailed
    case queueCapacityExceeded

    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "Capture text cannot be empty."
        case .unsupportedSchema:
            return "External creation data uses an unsupported schema."
        case .invalidRequest:
            return "External creation request identity is invalid."
        case .duplicateRequestIdentity:
            return "A different external creation request already uses this identity."
        case .ambiguousRequestIdentity:
            return "External creation queue contains ambiguous request identities."
        case .sharedContainerUnavailable:
            return "The protected external handoff container is unavailable."
        case .recoveryRequired:
            return "The protected external handoff requires local recovery."
        case .fileCoordinationFailed:
            return "External creation queue file coordination did not complete."
        case .queueCapacityExceeded:
            return "The protected external handoff queue is full. Open Ambitions to finish pending captures."
        }
    }
}

struct SharedExternalCreationStore {
    static let relativeDirectory = "ExternalCreations"
    static let fileName = "external-creations.v1.json"
    static let sideEffectLedgerFileName = "external-side-effects.v1.json"
    static let maximumPendingRecords = 128
    static let maximumQueueBytes = 1_024 * 1_024
    static let maximumRequestIdentifierBytes = 192
    static let maximumCaptureTextBytes = 64 * 1_024
    static let maximumSourceApplicationBytes = 1_024
    static let maximumSourceURLBytes = 8 * 1_024
    static let maximumCreatedAtBytes = 128

    var fileManager: FileManager = .default
    var baseURLOverride: URL?
    let coordinatedMutationDidLoadQueue: (@Sendable () -> Void)?

    init(
        fileManager: FileManager = .default,
        baseURL: URL? = nil,
        coordinatedMutationDidLoadQueue: (@Sendable () -> Void)? = nil
    ) {
        self.fileManager = fileManager
        self.baseURLOverride = baseURL
        self.coordinatedMutationDidLoadQueue = coordinatedMutationDidLoadQueue
    }

    func queueFileURL() throws -> URL {
        let baseURL: URL
        if let baseURLOverride {
            baseURL = baseURLOverride
        } else if let sharedURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: SharedExternalSnapshotStore.appGroupIdentifier
        ) {
            baseURL = sharedURL
        } else {
            throw SharedExternalCreationStoreError.sharedContainerUnavailable
        }

        return baseURL
            .appendingPathComponent(Self.relativeDirectory, isDirectory: true)
            .appendingPathComponent(Self.fileName)
    }

    func sideEffectLedgerFileURL() throws -> URL {
        try queueFileURL()
            .deletingLastPathComponent()
            .appendingPathComponent(Self.sideEffectLedgerFileName)
    }

    @discardableResult
    func enqueueDurableRequest(_ request: ExternalCreationRequest) throws -> ExternalCreationQueueAdmission {
        let trimmed = request.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw SharedExternalCreationStoreError.emptyText
        }
        try validate(request)

        let directoryURL = try queueFileURL().deletingLastPathComponent()
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return try coordinateWriting(directoryURL: directoryURL) { coordinatedDirectoryURL in
            let url = coordinatedDirectoryURL.appendingPathComponent(Self.fileName)
            var queue = try loadQueue(from: url)
            coordinatedMutationDidLoadQueue?()
            if let existing = queue.records.first(where: { $0.request.id == request.id }) {
                guard existing.isExactReplay(of: request) else {
                    throw SharedExternalCreationStoreError.duplicateRequestIdentity
                }
                return .replayedExisting(recordID: existing.id)
            }
            guard queue.records.count < Self.maximumPendingRecords else {
                throw SharedExternalCreationStoreError.queueCapacityExceeded
            }
            let record = try ExternalCreationQueueRecord(request: request)
            queue.records.append(record)
            let encodedQueue = try Self.encoder.encode(queue)
            guard encodedQueue.count <= Self.maximumQueueBytes else {
                throw SharedExternalCreationStoreError.queueCapacityExceeded
            }
            try writeProtectedQueueAtomically(encodedQueue, to: url)
            return .enqueued(recordID: record.id)
        }
    }

    func pendingRequests() throws -> [ExternalCreationRequest] {
        try pendingRecords().map(\.request)
    }

    func pendingRecords() throws -> [ExternalCreationQueueRecord] {
        let directoryURL = try queueFileURL().deletingLastPathComponent()
        guard fileManager.fileExists(atPath: directoryURL.path) else { return [] }
        return try coordinateReading(directoryURL: directoryURL) { coordinatedDirectoryURL in
            try loadQueue(from: coordinatedDirectoryURL.appendingPathComponent(Self.fileName)).records
        }
    }

    /// Compatibility API for callers that still know a request ID. It resolves
    /// exactly one immutable row and rejects ambiguity; it never bulk-deletes.
    func acknowledge(requestIDs: Set<ExternalCreationRequest.ID>) throws {
        guard requestIDs.isEmpty == false else { return }
        let records = try pendingRecords()
        var recordIDs: Set<String> = []
        for requestID in requestIDs {
            let matches = records.filter { $0.request.id == requestID }
            guard matches.count <= 1 else {
                throw SharedExternalCreationStoreError.ambiguousRequestIdentity
            }
            if let match = matches.first {
                recordIDs.insert(match.id)
            }
        }
        try acknowledge(recordIDs: recordIDs)
    }

    func acknowledge(recordIDs: Set<ExternalCreationQueueRecord.ID>) throws {
        guard recordIDs.isEmpty == false else { return }
        let directoryURL = try queueFileURL().deletingLastPathComponent()
        guard fileManager.fileExists(atPath: directoryURL.path) else { return }

        try coordinateWriting(directoryURL: directoryURL) { coordinatedDirectoryURL in
            let url = coordinatedDirectoryURL.appendingPathComponent(Self.fileName)
            var queue = try loadQueue(from: url)
            coordinatedMutationDidLoadQueue?()
            let remainingRecords = queue.records.filter { recordIDs.contains($0.id) == false }
            guard remainingRecords.count != queue.records.count else { return }

            if remainingRecords.isEmpty {
                try fileManager.removeItem(at: url)
            } else {
                queue.records = remainingRecords
                try writeProtectedQueueAtomically(try Self.encoder.encode(queue), to: url)
            }
        }
    }

    /// Records why a canonical admission left this immutable handoff pending.
    /// Failure to write this state never permits acknowledgement; the original
    /// queue row remains durable and retryable.
    func recordRecovery(
        recordID: ExternalCreationQueueRecord.ID,
        recovery: ExternalCreationQueueRecoveryState
    ) throws {
        let directoryURL = try queueFileURL().deletingLastPathComponent()
        guard fileManager.fileExists(atPath: directoryURL.path) else {
            throw SharedExternalCreationStoreError.fileCoordinationFailed
        }
        try coordinateWriting(directoryURL: directoryURL) { coordinatedDirectoryURL in
            let url = coordinatedDirectoryURL.appendingPathComponent(Self.fileName)
            var queue = try loadQueue(from: url)
            coordinatedMutationDidLoadQueue?()
            guard let index = queue.records.firstIndex(where: { $0.id == recordID }) else {
                throw SharedExternalCreationStoreError.fileCoordinationFailed
            }
            queue.records[index].recovery = recovery
            try writeProtectedQueueAtomically(try Self.encoder.encode(queue), to: url)
        }
    }

    func peek() throws -> [ExternalCreationRequest] {
        try pendingRequests()
    }

    private func loadQueue(from url: URL) throws -> ExternalCreationQueue {
        guard fileManager.fileExists(atPath: url.path) else {
            return ExternalCreationQueue()
        }
        try verifyPrivateQueueFileProtection(at: url)
        let data = try Data(contentsOf: url)
        guard data.count <= Self.maximumQueueBytes else {
            throw SharedExternalCreationStoreError.queueCapacityExceeded
        }
        let queue: ExternalCreationQueue
        do {
            queue = try Self.decoder.decode(ExternalCreationQueue.self, from: data)
        } catch {
            throw SharedExternalCreationStoreError.unsupportedSchema
        }
        guard queue.schemaVersion == ExternalCreationQueue.schemaVersion,
              queue.records.count <= Self.maximumPendingRecords,
              Set(queue.records.map(\.id)).count == queue.records.count,
              Set(queue.records.map { $0.request.id }).count == queue.records.count,
              queue.records.allSatisfy({ $0.isValid() })
        else { throw SharedExternalCreationStoreError.ambiguousRequestIdentity }
        try queue.records.map(\.request).forEach(validate)
        return queue
    }

    private func validate(_ request: ExternalCreationRequest) throws {
        let allowed = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-")
        let identifier = request.id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard request.schemaVersion == ExternalCreationRequest.schemaVersion,
              identifier.isEmpty == false,
              identifier.utf8.count <= Self.maximumRequestIdentifierBytes,
              identifier.rangeOfCharacter(from: allowed.inverted) == nil,
              identifier.contains("..") == false,
              request.createdAt.utf8.count <= Self.maximumCreatedAtBytes,
              request.text.utf8.count <= Self.maximumCaptureTextBytes,
              (request.sourceApplication?.utf8.count ?? 0) <= Self.maximumSourceApplicationBytes,
              (request.sourceURL?.utf8.count ?? 0) <= Self.maximumSourceURLBytes
        else {
            throw request.schemaVersion == ExternalCreationRequest.schemaVersion
                ? SharedExternalCreationStoreError.invalidRequest
                : SharedExternalCreationStoreError.unsupportedSchema
        }
    }

    private func applyPrivateQueueFileProtection(to url: URL) throws {
        #if os(iOS)
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.complete],
            ofItemAtPath: url.path
        )
        #else
        _ = url
        #endif
    }

    private func writeProtectedQueueAtomically(_ data: Data, to destination: URL) throws {
        guard data.count <= Self.maximumQueueBytes else {
            throw SharedExternalCreationStoreError.queueCapacityExceeded
        }
        let directory = destination.deletingLastPathComponent()
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        try applyPrivateQueueFileProtection(to: directory)
        let stagingFile = directory.appendingPathComponent(
            ".\(destination.lastPathComponent).\(UUID().uuidString.lowercased()).pending"
        )
        let rollback = directory.appendingPathComponent(
            ".\(destination.lastPathComponent).\(UUID().uuidString.lowercased()).rollback"
        )
        guard fileManager.createFile(atPath: stagingFile.path, contents: nil) else {
            throw CocoaError(.fileWriteUnknown)
        }
        var didActivate = false
        do {
            try applyPrivateQueueFileProtection(to: stagingFile)
            try verifyPrivateQueueFileProtection(at: stagingFile)
            try data.write(to: stagingFile)
            try verifyPrivateQueueFileProtection(at: stagingFile)
            if fileManager.fileExists(atPath: destination.path) {
                _ = try fileManager.replaceItemAt(
                    destination,
                    withItemAt: stagingFile,
                    backupItemName: rollback.lastPathComponent
                )
                didActivate = true
                try verifyPrivateQueueFileProtection(at: rollback)
            } else {
                try fileManager.moveItem(at: stagingFile, to: destination)
                didActivate = true
            }
            try verifyPrivateQueueFileProtection(at: destination)
            try? fileManager.removeItem(at: rollback)
        } catch {
            var recoveryRequired = false
            if didActivate {
                try? fileManager.removeItem(at: destination)
                if fileManager.fileExists(atPath: destination.path) {
                    recoveryRequired = true
                }
                if fileManager.fileExists(atPath: rollback.path) {
                    if (try? verifyPrivateQueueFileProtection(at: rollback)) != nil {
                        if fileManager.fileExists(atPath: destination.path) == false {
                            try? fileManager.copyItem(at: rollback, to: destination)
                        }
                        if (try? verifyPrivateQueueFileProtection(at: destination)) == nil {
                            try? fileManager.removeItem(at: destination)
                            recoveryRequired = true
                        } else {
                            try? fileManager.removeItem(at: rollback)
                        }
                    } else {
                        recoveryRequired = true
                    }
                }
            }
            try? fileManager.removeItem(at: stagingFile)
            if recoveryRequired {
                throw SharedExternalCreationStoreError.recoveryRequired
            }
            throw error
        }
    }

    private func verifyPrivateQueueFileProtection(at url: URL) throws {
        #if os(iOS)
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        guard (attributes[.protectionKey] as? FileProtectionType) == .complete else {
            throw SharedExternalCreationStoreError.fileCoordinationFailed
        }
        #else
        _ = url
        #endif
    }

    private func coordinateReading<ResultValue>(
        directoryURL: URL,
        accessor: @escaping (URL) throws -> ResultValue
    ) throws -> ResultValue {
        let resultBox = FileCoordinationResultBox<ResultValue>()
        var coordinationError: NSError?
        NSFileCoordinator(filePresenter: nil).coordinate(
            readingItemAt: directoryURL,
            options: [],
            error: &coordinationError
        ) { coordinatedDirectoryURL in
            resultBox.result = Result { try accessor(coordinatedDirectoryURL) }
        }
        return try coordinatedValue(from: resultBox, coordinationError: coordinationError)
    }

    private func coordinateWriting<ResultValue>(
        directoryURL: URL,
        accessor: @escaping (URL) throws -> ResultValue
    ) throws -> ResultValue {
        let resultBox = FileCoordinationResultBox<ResultValue>()
        var coordinationError: NSError?
        NSFileCoordinator(filePresenter: nil).coordinate(
            writingItemAt: directoryURL,
            options: [],
            error: &coordinationError
        ) { coordinatedDirectoryURL in
            resultBox.result = Result { try accessor(coordinatedDirectoryURL) }
        }
        return try coordinatedValue(from: resultBox, coordinationError: coordinationError)
    }

    private func coordinatedValue<ResultValue>(
        from resultBox: FileCoordinationResultBox<ResultValue>,
        coordinationError: NSError?
    ) throws -> ResultValue {
        if let coordinationError {
            throw coordinationError
        }
        guard let result = resultBox.result else {
            throw SharedExternalCreationStoreError.fileCoordinationFailed
        }
        return try result.get()
    }

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    private static let decoder = JSONDecoder()
}

private final class FileCoordinationResultBox<Value>: @unchecked Sendable {
    var result: Result<Value, Error>?
}
