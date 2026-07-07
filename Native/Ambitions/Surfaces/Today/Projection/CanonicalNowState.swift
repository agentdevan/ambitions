import Foundation

let canonicalNowStateSchemaVersion = "canonical_now_state.native.v1"

enum NowContextLens: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case work
    case personal
    case freeTime = "free_time"
    case admin
    case creative
    case recovery
    case deepFocus = "deep_focus"
    case all
}

enum NowContextLensSource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case manual
    case schedule
    case calendar
    case domain
    case deadline
    case recovery
    case systemDefault = "system_default"
}

enum NowPosture: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case noTime = "no_time"
    case open
    case steady
    case tight
    case overloaded
    case recovering
    case waiting
    case lowData = "low_data"
}

enum NowPressureLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case low
    case moderate
    case elevated
    case high
    case critical
}

enum NowActionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case focus
    case completeAction = "complete_action"
    case openGoal = "open_goal"
    case openTime = "open_time"
    case capture
    case schedule
    case recover
    case review
    case wait
    case routeCommitment = "route_commitment"
    case explain
}

enum NowActionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unavailable
    case ready
    case active
    case scheduled
    case blocked
    case waiting
    case deferred
    case completed
}

enum NowGoalPressureKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case activeGoal = "active_goal"
    case passiveGoal = "passive_goal"
    case deliverable
    case scopeChange = "scope_change"
    case deadline
    case nextAction = "next_action"
    case blocked
}

enum NowCommitmentKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case oneTime = "one_time"
    case recurring
    case goalSupporting = "goal_supporting"
    case scheduledBlock = "scheduled_block"
    case waiting
    case optionalSomeday = "optional_someday"
}

enum NowRecoveryState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case stable
    case watch
    case needsRecovery = "needs_recovery"
    case recovering
    case blocked
}

struct NowActionReference: Codable, Sendable, Equatable, Hashable {
    let goalID: String?
    let stepID: String?
    let captureID: String?
    let timeID: String?
    let reviewID: String?

    init(
        goalID: String? = nil,
        stepID: String? = nil,
        captureID: String? = nil,
        timeID: String? = nil,
        reviewID: String? = nil
    ) {
        self.goalID = goalID
        self.stepID = stepID
        self.captureID = captureID
        self.timeID = timeID
        self.reviewID = reviewID
    }
}

struct NowAction: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: NowActionKind
    let state: NowActionState
    let title: String
    let subtitle: String?
    let contextLens: NowContextLens
    let commitmentKind: NowCommitmentKind?
    let reference: NowActionReference?
    let explanationID: String?
    let eventLedgerEntryIDs: [String]

    init(
        id: String,
        kind: NowActionKind,
        state: NowActionState,
        title: String,
        subtitle: String? = nil,
        contextLens: NowContextLens = .all,
        commitmentKind: NowCommitmentKind? = nil,
        reference: NowActionReference? = nil,
        explanationID: String? = nil,
        eventLedgerEntryIDs: [String] = []
    ) {
        self.id = id
        self.kind = kind
        self.state = state
        self.title = title
        self.subtitle = subtitle
        self.contextLens = contextLens
        self.commitmentKind = commitmentKind
        self.reference = reference
        self.explanationID = explanationID
        self.eventLedgerEntryIDs = Self.normalized(eventLedgerEntryIDs)
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }
}

struct NowPressureSummary: Codable, Sendable, Equatable, Hashable {
    let level: NowPressureLevel
    let itemCount: Int
    let summary: String
    let evidenceReferenceIDs: [String]

    init(
        level: NowPressureLevel,
        itemCount: Int = 0,
        summary: String,
        evidenceReferenceIDs: [String] = []
    ) {
        self.level = level
        self.itemCount = max(0, itemCount)
        self.summary = summary
        self.evidenceReferenceIDs = Array(Set(evidenceReferenceIDs.filter { $0.isEmpty == false })).sorted()
    }
}

struct NowPriorityRealitySummary: Codable, Sendable, Equatable, Hashable {
    let overallPressure: NowPressureLevel
    let importance: NowPressureLevel
    let urgency: NowPressureLevel
    let deadline: NowPressureLevel
    let consequence: NowPressureLevel
    let effort: NowPressureLevel
    let contextFit: NowPressureLevel
    let goalRelationship: NowPressureLevel
    let userPreference: NowPressureLevel
    let capacity: NowPressureLevel
    let recoveryState: NowRecoveryState
    let summary: String

    init(
        overallPressure: NowPressureLevel,
        importance: NowPressureLevel = .none,
        urgency: NowPressureLevel = .none,
        deadline: NowPressureLevel = .none,
        consequence: NowPressureLevel = .none,
        effort: NowPressureLevel = .none,
        contextFit: NowPressureLevel = .none,
        goalRelationship: NowPressureLevel = .none,
        userPreference: NowPressureLevel = .none,
        capacity: NowPressureLevel = .none,
        recoveryState: NowRecoveryState = .stable,
        summary: String
    ) {
        self.overallPressure = overallPressure
        self.importance = importance
        self.urgency = urgency
        self.deadline = deadline
        self.consequence = consequence
        self.effort = effort
        self.contextFit = contextFit
        self.goalRelationship = goalRelationship
        self.userPreference = userPreference
        self.capacity = capacity
        self.recoveryState = recoveryState
        self.summary = summary
    }
}

struct NowBlockersWaitingSummary: Codable, Sendable, Equatable, Hashable {
    let blockedCount: Int
    let waitingCount: Int
    let summary: String
    let references: [NowActionReference]

    init(
        blockedCount: Int = 0,
        waitingCount: Int = 0,
        summary: String,
        references: [NowActionReference] = []
    ) {
        self.blockedCount = max(0, blockedCount)
        self.waitingCount = max(0, waitingCount)
        self.summary = summary
        self.references = references
    }
}
