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

    var errorDescription: String? {
        switch self {
        case .emptyText:
            return "Capture text cannot be empty."
        }
    }
}

struct SharedExternalCreationStore {
    static let relativeDirectory = "ExternalCreations"
    static let fileName = "external-creations.v1.json"

    var fileManager: FileManager = .default
    var baseURLOverride: URL?

    init(fileManager: FileManager = .default, baseURL: URL? = nil) {
        self.fileManager = fileManager
        self.baseURLOverride = baseURL
    }

    func queueFileURL() -> URL {
        let baseURL = baseURLOverride
            ?? fileManager.containerURL(forSecurityApplicationGroupIdentifier: SharedExternalSnapshotStore.appGroupIdentifier)
            ?? fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory

        return baseURL
            .appendingPathComponent(Self.relativeDirectory, isDirectory: true)
            .appendingPathComponent(Self.fileName)
    }

    func append(_ request: ExternalCreationRequest) throws {
        let trimmed = request.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw SharedExternalCreationStoreError.emptyText
        }

        let url = queueFileURL()
        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        var queue = try loadQueue(from: url)
        queue.requests.append(request)
        let data = try Self.encoder.encode(queue)
        try data.write(to: url, options: [.atomic])
    }

    func drain() throws -> [ExternalCreationRequest] {
        let url = queueFileURL()
        let queue = try loadQueue(from: url)
        guard queue.requests.isEmpty == false else { return [] }
        try? fileManager.removeItem(at: url)
        return queue.requests
    }

    func peek() throws -> [ExternalCreationRequest] {
        try loadQueue(from: queueFileURL()).requests
    }

    private func loadQueue(from url: URL) throws -> ExternalCreationQueue {
        guard fileManager.fileExists(atPath: url.path) else {
            return ExternalCreationQueue()
        }
        let data = try Data(contentsOf: url)
        return try Self.decoder.decode(ExternalCreationQueue.self, from: data)
    }

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()

    private static let decoder = JSONDecoder()
}
