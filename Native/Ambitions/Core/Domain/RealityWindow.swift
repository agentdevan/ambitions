import Foundation

enum RealityWindowKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case working
    case freeTime = "free_time"
    case protected
    case vacation
    case away
    case blockedBusy = "blocked_busy"
    case flexible
    case scheduledAmbitionsBlock = "scheduled_ambitions_block"
    case calendarDerivedBusy = "calendar_derived_busy"
    case open

    var isAwayLike: Bool {
        self == .vacation || self == .away
    }
}

enum RealityWindowSource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case userDefined = "user_defined"
    case ambitionsPlan = "ambitions_plan"
    case captureSeed = "capture_seed"
    case calendarDerived = "calendar_derived"
    case systemDefault = "system_default"
}

struct RealityWindow: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: RealityWindowKind
    let source: RealityWindowSource
    let start: Date
    let end: Date
    let title: String
    let contextLens: NowContextLens
    let isFlexible: Bool
    let isProtected: Bool
    let isCalendarDerived: Bool
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
    let relatedGoalID: String?
    let relatedCaptureID: String?
    let relatedPlanID: String?
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]

    init(
        id: String,
        kind: RealityWindowKind,
        source: RealityWindowSource,
        start: Date,
        end: Date,
        title: String,
        contextLens: NowContextLens = .all,
        isFlexible: Bool? = nil,
        isProtected: Bool? = nil,
        relatedGoalID: String? = nil,
        relatedCaptureID: String? = nil,
        relatedPlanID: String? = nil,
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = []
    ) {
        self.id = id
        self.kind = kind
        self.source = source
        self.start = start
        self.end = end
        self.title = title
        self.contextLens = contextLens
        self.isFlexible = isFlexible ?? (kind == .flexible || kind == .open)
        self.isProtected = isProtected ?? (kind == .protected)
        self.isCalendarDerived = source == .calendarDerived || kind == .calendarDerivedBusy
        self.localOnly = true
        self.privacy = source == .calendarDerived ? .calendarDerived : .standard
        self.relatedGoalID = relatedGoalID
        self.relatedCaptureID = relatedCaptureID
        self.relatedPlanID = relatedPlanID
        self.eventLedgerEntryIDs = Self.normalized(eventLedgerEntryIDs)
        self.recommendationExplanationIDs = Self.normalized(recommendationExplanationIDs)
    }

    var durationMinutes: Int {
        max(0, Int(end.timeIntervalSince(start) / 60))
    }

    var interval: DateInterval {
        DateInterval(start: start, end: end)
    }

    var isAwayLike: Bool {
        kind.isAwayLike
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }
}
