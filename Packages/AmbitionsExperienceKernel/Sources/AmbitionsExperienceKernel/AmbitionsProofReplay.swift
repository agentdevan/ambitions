import Foundation

public struct AmbitionsProofReceipt: Equatable, Identifiable, Sendable, Codable {
    public let id: UUID
    public let title: String
    public let sourceQuality: AmbitionsSourceQuality
    public let createdAt: Date
    public let localOnly: Bool
    public let summary: String

    public init(id: UUID = UUID(), title: String, sourceQuality: AmbitionsSourceQuality, createdAt: Date = Date(), localOnly: Bool = true, summary: String) {
        self.id = id
        self.title = title
        self.sourceQuality = sourceQuality
        self.createdAt = createdAt
        self.localOnly = localOnly
        self.summary = summary
    }
}

public enum AmbitionsReplayEventKind: String, CaseIterable, Sendable, Codable {
    case recommendationCompiled
    case proofAttached
    case closureRecorded
    case scheduleAdjusted
    case recoverySuggested
    case userOverride
}

public struct AmbitionsReplayEvent: Equatable, Identifiable, Sendable, Codable {
    public let id: UUID
    public let kind: AmbitionsReplayEventKind
    public let createdAt: Date
    public let beforeDigest: String
    public let afterDigest: String
    public let explanation: String

    public init(id: UUID = UUID(), kind: AmbitionsReplayEventKind, createdAt: Date = Date(), beforeDigest: String, afterDigest: String, explanation: String) {
        self.id = id
        self.kind = kind
        self.createdAt = createdAt
        self.beforeDigest = beforeDigest
        self.afterDigest = afterDigest
        self.explanation = explanation
    }
}

public struct AmbitionsReplayTrace: Equatable, Sendable, Codable {
    public let events: [AmbitionsReplayEvent]

    public init(events: [AmbitionsReplayEvent]) {
        self.events = events
    }

    public var isReplayable: Bool {
        !events.isEmpty && events.allSatisfy { !$0.beforeDigest.isEmpty && !$0.afterDigest.isEmpty }
    }
}
