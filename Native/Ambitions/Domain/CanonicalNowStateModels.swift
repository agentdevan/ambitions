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
    case noPlan = "no_plan"
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
    case openPlan = "open_plan"
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
    let planID: String?
    let reviewID: String?

    init(
        goalID: String? = nil,
        stepID: String? = nil,
        captureID: String? = nil,
        planID: String? = nil,
        reviewID: String? = nil
    ) {
        self.goalID = goalID
        self.stepID = stepID
        self.captureID = captureID
        self.planID = planID
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

struct NowOutsideLensItem: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let lens: NowContextLens
    let pressure: NowPressureLevel
    let reference: NowActionReference?
}

struct NowUrgentOutsideLensSummary: Codable, Sendable, Equatable, Hashable {
    let level: NowPressureLevel
    let count: Int
    let summary: String
    let items: [NowOutsideLensItem]

    init(
        level: NowPressureLevel,
        count: Int? = nil,
        summary: String,
        items: [NowOutsideLensItem] = []
    ) {
        self.level = level
        self.count = max(0, count ?? items.count)
        self.summary = summary
        self.items = items.sorted { lhs, rhs in
            if lhs.pressure.rawValue != rhs.pressure.rawValue {
                return lhs.pressure.rawValue > rhs.pressure.rawValue
            }
            return lhs.id < rhs.id
        }
    }
}

struct NowGoalPressureSummary: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: NowGoalPressureKind
    let level: NowPressureLevel
    let goalID: String?
    let title: String
    let summary: String
    let nextAction: NowAction?
    let explanationID: String?
    let eventLedgerEntryIDs: [String]

    init(
        id: String,
        kind: NowGoalPressureKind,
        level: NowPressureLevel,
        goalID: String? = nil,
        title: String,
        summary: String,
        nextAction: NowAction? = nil,
        explanationID: String? = nil,
        eventLedgerEntryIDs: [String] = []
    ) {
        self.id = id
        self.kind = kind
        self.level = level
        self.goalID = goalID
        self.title = title
        self.summary = summary
        self.nextAction = nextAction
        self.explanationID = explanationID
        self.eventLedgerEntryIDs = Array(Set(eventLedgerEntryIDs.filter { $0.isEmpty == false })).sorted()
    }
}

struct NowEvidenceSummary: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String?
    let source: RecommendationExplanationSource?
    let eventLedgerEntryID: String?
    let explanationID: String?
}

struct CanonicalNowState: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let generatedAt: String
    let activeContextLens: NowContextLens
    let lensSource: NowContextLensSource
    let availableContextLenses: [NowContextLens]
    let isManualLensOverrideActive: Bool
    let todayPosture: NowPosture
    let currentAction: NowAction?
    let bestNextAction: NowAction?
    let nextActionConfidence: RecommendationConfidence
    let nextActionExplanationID: String?
    let schedulePressure: NowPressureSummary
    let priorityPressure: NowPriorityRealitySummary
    let deadlinePressure: NowPressureSummary
    let activeFocus: NowActionReference?
    let captureUrgency: NowPressureSummary
    let blockersWaiting: NowBlockersWaitingSummary
    let recoveryState: NowRecoveryState
    let urgentOutsideLens: NowUrgentOutsideLensSummary
    let activeGoalPressure: [NowGoalPressureSummary]
    let passiveGoalPressure: [NowGoalPressureSummary]
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]
    let evidenceSummaries: [NowEvidenceSummary]
    let privacy: EventLedgerPrivacyClassification
    let localOnly: Bool
    let schemaVersion: String

    init(
        id: String,
        generatedAt: String,
        activeContextLens: NowContextLens,
        lensSource: NowContextLensSource,
        availableContextLenses: [NowContextLens] = NowContextLens.allCases,
        isManualLensOverrideActive: Bool = false,
        todayPosture: NowPosture,
        currentAction: NowAction? = nil,
        bestNextAction: NowAction? = nil,
        nextActionConfidence: RecommendationConfidence = .low,
        nextActionExplanationID: String? = nil,
        schedulePressure: NowPressureSummary,
        priorityPressure: NowPriorityRealitySummary,
        deadlinePressure: NowPressureSummary,
        activeFocus: NowActionReference? = nil,
        captureUrgency: NowPressureSummary,
        blockersWaiting: NowBlockersWaitingSummary,
        recoveryState: NowRecoveryState,
        urgentOutsideLens: NowUrgentOutsideLensSummary,
        activeGoalPressure: [NowGoalPressureSummary] = [],
        passiveGoalPressure: [NowGoalPressureSummary] = [],
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = [],
        evidenceSummaries: [NowEvidenceSummary] = [],
        privacy: EventLedgerPrivacyClassification = .standard,
        localOnly: Bool = true,
        schemaVersion: String = canonicalNowStateSchemaVersion
    ) {
        self.id = id
        self.generatedAt = generatedAt
        self.activeContextLens = activeContextLens
        self.lensSource = lensSource
        self.availableContextLenses = Self.normalized(availableContextLenses, fallback: NowContextLens.allCases)
        self.isManualLensOverrideActive = isManualLensOverrideActive
        self.todayPosture = todayPosture
        self.currentAction = currentAction
        self.bestNextAction = bestNextAction
        self.nextActionConfidence = nextActionConfidence
        self.nextActionExplanationID = nextActionExplanationID
        self.schedulePressure = schedulePressure
        self.priorityPressure = priorityPressure
        self.deadlinePressure = deadlinePressure
        self.activeFocus = activeFocus
        self.captureUrgency = captureUrgency
        self.blockersWaiting = blockersWaiting
        self.recoveryState = recoveryState
        self.urgentOutsideLens = urgentOutsideLens
        self.activeGoalPressure = activeGoalPressure.sorted { $0.id < $1.id }
        self.passiveGoalPressure = passiveGoalPressure.sorted { $0.id < $1.id }
        self.eventLedgerEntryIDs = Array(Set(eventLedgerEntryIDs.filter { $0.isEmpty == false })).sorted()
        self.recommendationExplanationIDs = Array(Set(recommendationExplanationIDs.filter { $0.isEmpty == false })).sorted()
        self.evidenceSummaries = evidenceSummaries.sorted { $0.id < $1.id }
        self.privacy = privacy
        self.localOnly = localOnly
        self.schemaVersion = schemaVersion
    }

    static func empty(
        generatedAt: String,
        activeContextLens: NowContextLens = .all,
        lensSource: NowContextLensSource = .systemDefault,
        availableContextLenses: [NowContextLens] = NowContextLens.allCases,
        isManualLensOverrideActive: Bool = false
    ) -> CanonicalNowState {
        CanonicalNowState(
            id: "now.\(generatedAt)",
            generatedAt: generatedAt,
            activeContextLens: activeContextLens,
            lensSource: lensSource,
            availableContextLenses: availableContextLenses,
            isManualLensOverrideActive: isManualLensOverrideActive,
            todayPosture: .noPlan,
            schedulePressure: NowPressureSummary(level: .none, summary: "No local schedule pressure is visible."),
            priorityPressure: NowPriorityRealitySummary(
                overallPressure: .none,
                summary: "No priority pressure is visible yet."
            ),
            deadlinePressure: NowPressureSummary(level: .none, summary: "No deadline pressure is visible."),
            captureUrgency: NowPressureSummary(level: .none, summary: "No open captures are asking for attention."),
            blockersWaiting: NowBlockersWaitingSummary(summary: "No blockers or waiting items are visible."),
            recoveryState: .stable,
            urgentOutsideLens: NowUrgentOutsideLensSummary(level: .none, summary: "No urgent outside-lens items are visible.")
        )
    }

    private static func normalized(_ lenses: [NowContextLens], fallback: [NowContextLens]) -> [NowContextLens] {
        let unique = Array(Set(lenses)).sorted { $0.rawValue < $1.rawValue }
        return unique.isEmpty ? fallback : unique
    }
}
