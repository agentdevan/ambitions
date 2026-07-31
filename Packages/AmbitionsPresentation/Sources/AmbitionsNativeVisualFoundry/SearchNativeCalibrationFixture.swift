import Foundation

public enum SearchNativeCalibrationOwner: String, Equatable, Sendable {
    case time = "Time"
    case goals = "Goals"
}

public enum SearchNativeCalibrationObjectKind: String, Equatable, Sendable {
    case event = "Event"
    case currentMovement = "Current movement"
}

public struct SearchNativeCalibrationResult: Identifiable, Equatable, Sendable {
    public let id: String
    public let identity: String
    public let owner: SearchNativeCalibrationOwner
    public let kind: SearchNativeCalibrationObjectKind
    public let currentTruth: String
    public let matchReason: String
    public let matchReasonIsObvious: Bool
    public let actionTitle: String
    public let source: String?
    public let freshness: String?
    public let boundedExplanation: String
    public let knowledgeLimit: String

    public init(
        id: String,
        identity: String,
        owner: SearchNativeCalibrationOwner,
        kind: SearchNativeCalibrationObjectKind,
        currentTruth: String,
        matchReason: String,
        matchReasonIsObvious: Bool,
        actionTitle: String,
        source: String? = nil,
        freshness: String? = nil,
        boundedExplanation: String,
        knowledgeLimit: String
    ) {
        self.id = id
        self.identity = identity
        self.owner = owner
        self.kind = kind
        self.currentTruth = currentTruth
        self.matchReason = matchReason
        self.matchReasonIsObvious = matchReasonIsObvious
        self.actionTitle = actionTitle
        self.source = source
        self.freshness = freshness
        self.boundedExplanation = boundedExplanation
        self.knowledgeLimit = knowledgeLimit
    }

    public var semanticOrder: [String] {
        [
            identity,
            owner.rawValue,
            currentTruth,
            matchReasonIsObvious ? nil : matchReason,
            actionTitle
        ]
        .compactMap { $0 }
    }
}

public struct SearchNativeCalibrationHandoff: Equatable, Sendable {
    public let targetID: String
    public let targetIdentity: String
    public let currentAcceptedTruth: String
    public let requestedChange: String
    public let owner: SearchNativeCalibrationOwner
    public let consequence: String
    public let limitation: String
    public let actionTitle: String
}

public struct SearchNativeCalibrationPrivacyState: Equatable, Sendable {
    public let query: String
    public let visibleResultIDs: [String]
    public let suppressedMatchCount: Int
    public let hiddenIdentityProbe: String
    public let message: String
    public let limitation: String
}

public struct SearchNativeCalibrationFixture: Equatable, Sendable {
    public static let fixtureID = "search-flagship/owner-routed-semantic-passage/v1"
    public static let representativeQuery = "appointment"
    public static let actionQuery = "move the dentist appointment to 11"
    public static let noResultsQuery = "ceramics invoice"
    public static let privacyQuery = "private appointment"

    public let results: [SearchNativeCalibrationResult]
    public let handoff: SearchNativeCalibrationHandoff
    public let privacy: SearchNativeCalibrationPrivacyState

    public func result(id: String) -> SearchNativeCalibrationResult? {
        results.first { $0.id == id }
    }

    public func results(for query: String) -> [SearchNativeCalibrationResult] {
        let normalized = Self.normalized(query)
        switch normalized {
        case Self.normalized(Self.representativeQuery), Self.normalized(Self.actionQuery):
            return results
        case Self.normalized(privacy.query):
            return results.filter { privacy.visibleResultIDs.contains($0.id) }
        default:
            return []
        }
    }

    public func isActionQuery(_ query: String) -> Bool {
        Self.normalized(query) == Self.normalized(Self.actionQuery)
    }

    public func isPrivacyQuery(_ query: String) -> Bool {
        Self.normalized(query) == Self.normalized(privacy.query)
    }

    public func isNoResultsQuery(_ query: String) -> Bool {
        let normalized = Self.normalized(query)
        return normalized.isEmpty == false && results(for: query).isEmpty && isPrivacyQuery(query) == false
    }

    private static func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

public extension SearchNativeCalibrationFixture {
    static let flagship = SearchNativeCalibrationFixture(
        results: [
            SearchNativeCalibrationResult(
                id: "event.dentist-appointment",
                identity: "Dentist appointment",
                owner: .time,
                kind: .event,
                currentTruth: "Tomorrow · 9:30 AM",
                matchReason: "Direct title match",
                matchReasonIsObvious: true,
                actionTitle: "Inspect",
                source: "Accepted local Event",
                freshness: "Current",
                boundedExplanation: "This result is the accepted Time-owned Event whose title matches appointment.",
                knowledgeLimit: "Search can inspect and open this Event. Time must review any change."
            ),
            SearchNativeCalibrationResult(
                id: "movement.prepare-appointment-questions",
                identity: "Prepare questions for the appointment",
                owner: .goals,
                kind: .currentMovement,
                currentTruth: "Current movement",
                matchReason: "Related appointment context",
                matchReasonIsObvious: false,
                actionTitle: "Inspect",
                source: "Current Goal movement",
                freshness: "Current",
                boundedExplanation: "This current movement is related through its accepted appointment context.",
                knowledgeLimit: "Search can navigate to this movement. Goals owns any change to it."
            )
        ],
        handoff: SearchNativeCalibrationHandoff(
            targetID: "event.dentist-appointment",
            targetIdentity: "Dentist appointment",
            currentAcceptedTruth: "Tomorrow · 9:30 AM",
            requestedChange: "Tomorrow · 11:00 AM",
            owner: .time,
            consequence: "90 minutes later",
            limitation: "Time will check availability and any calendar effects.",
            actionTitle: "Continue to Time"
        ),
        privacy: SearchNativeCalibrationPrivacyState(
            query: SearchNativeCalibrationFixture.privacyQuery,
            visibleResultIDs: ["event.dentist-appointment"],
            suppressedMatchCount: 1,
            hiddenIdentityProbe: "Family medical follow-up",
            message: "Some matching local content is hidden.",
            limitation: "Search cannot show protected matching content in this view."
        )
    )
}
