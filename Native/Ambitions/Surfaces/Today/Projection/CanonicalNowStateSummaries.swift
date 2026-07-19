import Foundation

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
            todayPosture: .noTime,
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
