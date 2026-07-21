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

struct ExternalCreationQueue: Codable, Sendable, Equatable {
    static let schemaVersion = 1

    var schemaVersion: Int = Self.schemaVersion
    var requests: [ExternalCreationRequest] = []
}

enum SharedExternalCreationStoreError: LocalizedError {
    case emptyText
    case fileCoordinationFailed

    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "Capture text cannot be empty."
        case .fileCoordinationFailed:
            return "External creation queue file coordination did not complete."
        }
    }
}

struct SharedExternalCreationStore {
    static let relativeDirectory = "ExternalCreations"
    static let fileName = "external-creations.v1.json"
    static let sideEffectLedgerFileName = "external-side-effects.v1.json"

    var fileManager: FileManager = .default
    var baseURLOverride: URL?

    init(fileManager: FileManager = .default, baseURL: URL? = nil) {
        self.fileManager = fileManager
        self.baseURLOverride = baseURL
    }

    func queueFileURL() -> URL {
        let baseURL = baseURLOverride
            ?? fileManager.containerURL(
                forSecurityApplicationGroupIdentifier: SharedExternalSnapshotStore.appGroupIdentifier
            )
            ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory

        return baseURL
            .appendingPathComponent(Self.relativeDirectory, isDirectory: true)
            .appendingPathComponent(Self.fileName)
    }

    func sideEffectLedgerFileURL() -> URL {
        queueFileURL()
            .deletingLastPathComponent()
            .appendingPathComponent(Self.sideEffectLedgerFileName)
    }

    func enqueueDurableRequest(_ request: ExternalCreationRequest) throws {
        let trimmed = request.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw SharedExternalCreationStoreError.emptyText
        }

        let directoryURL = queueFileURL().deletingLastPathComponent()
        try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        try coordinateWriting(directoryURL: directoryURL) { coordinatedDirectoryURL in
            let url = coordinatedDirectoryURL.appendingPathComponent(Self.fileName)
            var queue = try loadQueue(from: url)
            queue.requests.append(request)
            let data = try Self.encoder.encode(queue)
            try data.write(to: url, options: [.atomic])
        }
    }

    func pendingRequests() throws -> [ExternalCreationRequest] {
        let directoryURL = queueFileURL().deletingLastPathComponent()
        guard fileManager.fileExists(atPath: directoryURL.path) else { return [] }
        return try coordinateReading(directoryURL: directoryURL) { coordinatedDirectoryURL in
            try loadQueue(from: coordinatedDirectoryURL.appendingPathComponent(Self.fileName)).requests
        }
    }

    func acknowledge(requestIDs: Set<ExternalCreationRequest.ID>) throws {
        guard requestIDs.isEmpty == false else { return }
        let directoryURL = queueFileURL().deletingLastPathComponent()
        guard fileManager.fileExists(atPath: directoryURL.path) else { return }

        try coordinateWriting(directoryURL: directoryURL) { coordinatedDirectoryURL in
            let url = coordinatedDirectoryURL.appendingPathComponent(Self.fileName)
            var queue = try loadQueue(from: url)
            let remainingRequests = queue.requests.filter { requestIDs.contains($0.id) == false }
            guard remainingRequests.count != queue.requests.count else { return }

            if remainingRequests.isEmpty {
                try fileManager.removeItem(at: url)
            } else {
                queue.requests = remainingRequests
                let data = try Self.encoder.encode(queue)
                try data.write(to: url, options: [.atomic])
            }
        }
    }

    func peek() throws -> [ExternalCreationRequest] {
        try pendingRequests()
    }

    private func loadQueue(from url: URL) throws -> ExternalCreationQueue {
        guard fileManager.fileExists(atPath: url.path) else {
            return ExternalCreationQueue()
        }
        let data = try Data(contentsOf: url)
        return try Self.decoder.decode(ExternalCreationQueue.self, from: data)
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
