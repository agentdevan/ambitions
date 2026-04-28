import AmbitionsDesignSystem
import Foundation

enum GoalDetailLens: String, CaseIterable, Hashable, Sendable {
    // Compatibility case name retained; this lens displays contained Goal/Path/Plan steps.
    case tasks
    case path

    var title: String {
        switch self {
        case .tasks: "Steps"
        case .path: "Path"
        }
    }
}

enum GoalRenderState: String, Hashable, Sendable {
    case active
    case starter
    case clarification
    case blocked
    case onHold
    case achieved

    var title: String {
        switch self {
        case .active: "In motion"
        case .starter: "Starter path"
        case .clarification: "Needs clarity"
        case .blocked: "Blocked"
        case .onHold: "On hold"
        case .achieved: "Achieved"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .active: .selected
        case .starter: .selected
        case .clarification: .warning
        case .blocked: .warning
        case .onHold: .default
        case .achieved: .success
        }
    }
}

enum GoalsBoardPosture: String, Hashable, Sendable {
    case active
    case stalled
    case crowded
    case atRisk
    case lowerPriority
    case achieved

    var title: String {
        switch self {
        case .active: "Active"
        case .stalled: "Stalled"
        case .crowded: "Crowded"
        case .atRisk: "At Risk"
        case .lowerPriority: "Lower Priority"
        case .achieved: "Achieved"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .active: .selected
        case .stalled: .default
        case .crowded: .warning
        case .atRisk: .warning
        case .lowerPriority: .default
        case .achieved: .success
        }
    }
}

enum GoalsBoardBandKind: String, Hashable, Sendable {
    case activeDirection = "active_direction"
    case pressure
    case recentMovement = "recent_movement"
    case lowerPriority = "lower_priority"
}

enum GoalPortfolioLifecycleState: String, Hashable, Sendable, CaseIterable {
    case active
    case passive
    case waiting
    case blocked
    case parked
    case protected
    case completed
    case cancelledDropped = "cancelled_dropped"
    case previous
    case future

    var title: String {
        switch self {
        case .active: "Active"
        case .passive: "Passive"
        case .waiting: "Waiting"
        case .blocked: "Blocked"
        case .parked: "Parked"
        case .protected: "Protected"
        case .completed: "Completed"
        case .cancelledDropped: "Cancelled"
        case .previous: "Previous"
        case .future: "Future"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .active, .protected: .selected
        case .completed: .success
        case .waiting, .blocked: .warning
        case .cancelledDropped, .parked, .passive, .previous, .future: .default
        }
    }

    var icon: String {
        switch self {
        case .active: "scope"
        case .passive: "moon"
        case .waiting: "hourglass"
        case .blocked: "exclamationmark.triangle"
        case .parked: "pause.circle"
        case .protected: "lock.shield"
        case .completed: "checkmark.circle"
        case .cancelledDropped: "xmark.circle"
        case .previous: "clock.arrow.circlepath"
        case .future: "sparkle"
        }
    }

    var isCurrentPortfolioState: Bool {
        switch self {
        case .active, .passive, .waiting, .blocked, .protected:
            true
        case .parked, .completed, .cancelledDropped, .previous, .future:
            false
        }
    }
}

enum GoalWeatherState: String, Hashable, Sendable {
    case clear
    case cloudy
    case stormy
    case foggy
    case protected

    var title: String {
        switch self {
        case .clear: "Clear"
        case .cloudy: "Cloudy"
        case .stormy: "Stormy"
        case .foggy: "Foggy"
        case .protected: "Protected"
        }
    }

    var icon: String {
        switch self {
        case .clear: "circle.lefthalf.filled"
        case .cloudy: "cloud"
        case .stormy: "cloud.bolt"
        case .foggy: "cloud.fog"
        case .protected: "lock.shield"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .clear, .protected: .selected
        case .cloudy, .foggy: .default
        case .stormy: .warning
        }
    }
}

struct GoalProofSummary: Sendable, Hashable {
    let title: String
    let detail: String
    let count: Int
    let latestTitle: String?
    let visualState: AmbitionVisualState
}

struct GoalNextVisibleStep: Sendable, Hashable {
    let title: String
    let detail: String
    let isAvailable: Bool
}

struct GoalMomentumIntegrity: Sendable, Hashable {
    let title: String
    let detail: String
    let visualState: AmbitionVisualState
}

struct GoalLifecycleRailSegment: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let count: Int
    let subtitle: String
    let state: AmbitionVisualState
}

struct GoalStateChipState: Identifiable, Sendable, Hashable {
    let lifecycleState: GoalPortfolioLifecycleState
    let count: Int

    var id: String { lifecycleState.rawValue }
}

struct GoalPortfolioArchiveSummary: Sendable, Hashable {
    let title: String
    let subtitle: String
    let chips: [GoalStateChipState]
}

struct GoalAtlasPreviewItem: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let state: AmbitionVisualState
}

struct GoalAtlasPreviewGroup: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let items: [GoalAtlasPreviewItem]
}

struct GoalAtlasPreviewState: Sendable, Hashable {
    let title: String
    let subtitle: String
    let groups: [GoalAtlasPreviewGroup]
}

enum GoalsBoardPrimaryActionKind: String, Hashable, Sendable {
    case openGoal = "open_goal"
    case recoverGoal = "recover_goal"
    case refineStrategy = "refine_strategy"
    case createGoal = "create_goal"
}

struct GoalsHeroPillState: Identifiable, Sendable, Hashable {
    let title: String
    let icon: String?
    let state: AmbitionVisualState

    var id: String { [title, icon ?? "", state.rawValue].joined(separator: "|") }
}

struct GoalsBoardHeroState: Sendable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let dominantTruth: String
    let pressureSummary: String
    let contextPills: [GoalsHeroPillState]
    let attentionPills: [GoalsHeroPillState]
}

struct GoalsBoardPrimaryAction: Sendable {
    let kind: GoalsBoardPrimaryActionKind
    let title: String
    let subtitle: String
    let systemImage: String
    let target: GoalRouteTarget?
    let state: AmbitionVisualState
}

struct GoalsWeekPressureSummary: Sendable {
    let title: String
    let subtitle: String
    let leadingMetric: String
    let trailingMetric: String
    let pill: GoalsHeroPillState
}

struct GoalListItem: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget
    let title: String
    let subtitle: String
    let mode: GoalMode
    let renderState: GoalRenderState
    let progressValue: Double
    let progressLabel: String
    let statusLabel: String
    let timingLabel: String
    let nextStepHint: String
    let modeLabel: String
    let supportLabel: String?
    let relevanceScore: Double
    let momentumScore: Double
    let urgencyScore: Double
    let manualPriorityRank: Int
    let updatedAt: String
    let shellSummary: GoalShellSummaryState?

    init(
        id: String,
        target: GoalRouteTarget,
        title: String,
        subtitle: String,
        mode: GoalMode,
        renderState: GoalRenderState,
        progressValue: Double,
        progressLabel: String,
        statusLabel: String,
        timingLabel: String,
        nextStepHint: String,
        modeLabel: String,
        supportLabel: String?,
        relevanceScore: Double,
        momentumScore: Double,
        urgencyScore: Double,
        manualPriorityRank: Int,
        updatedAt: String,
        shellSummary: GoalShellSummaryState? = nil
    ) {
        self.id = id
        self.target = target
        self.title = title
        self.subtitle = subtitle
        self.mode = mode
        self.renderState = renderState
        self.progressValue = progressValue
        self.progressLabel = progressLabel
        self.statusLabel = statusLabel
        self.timingLabel = timingLabel
        self.nextStepHint = nextStepHint
        self.modeLabel = modeLabel
        self.supportLabel = supportLabel
        self.relevanceScore = relevanceScore
        self.momentumScore = momentumScore
        self.urgencyScore = urgencyScore
        self.manualPriorityRank = manualPriorityRank
        self.updatedAt = updatedAt
        self.shellSummary = shellSummary
    }
}

struct GoalsBoardCardState: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget
    let title: String
    let subtitle: String
    let modeLabel: String
    let posture: GoalsBoardPosture
    let renderState: GoalRenderState
    let progressValue: Double
    let progressLabel: String
    let timingLabel: String
    let weekRelationship: String
    let phaseSummary: String
    let milestoneSummary: String
    let pressureSummary: String
    let nextStepHint: String
    let lifecycleState: GoalPortfolioLifecycleState
    let weather: GoalWeatherState
    let weatherSummary: String
    let proofSummary: GoalProofSummary
    let nextVisibleStep: GoalNextVisibleStep
    let momentumIntegrity: GoalMomentumIntegrity
    let supportLabel: String?
    let priorityLabel: String
    let manualPriorityRank: Int
    let shellSummary: GoalShellSummaryState?
}

struct GoalsBoardBand: Identifiable, Sendable {
    let kind: GoalsBoardBandKind
    let title: String
    let subtitle: String
    let cards: [GoalsBoardCardState]

    var id: String { kind.rawValue }
}

struct GoalsHorizonLadderRung: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget
    let title: String
    let summary: String
    let milestoneLabel: String
    let signalLabel: String
    let highlight: String
    let state: AmbitionVisualState
}

struct GoalsHorizonLadderState: Sendable {
    let title: String
    let subtitle: String
    let rungs: [GoalsHorizonLadderRung]
}

struct GoalsLowerPriorityState: Sendable {
    let title: String
    let subtitle: String
    let disclosureTitle: String
    let cards: [GoalsBoardCardState]
}

struct GoalsOverview: Sendable {
    let hero: GoalsBoardHeroState
    let heroPrimaryAction: GoalsBoardPrimaryAction
    let bands: [GoalsBoardBand]
    let horizonLadder: GoalsHorizonLadderState
    let weekPressureSummary: GoalsWeekPressureSummary
    let lowerPriority: GoalsLowerPriorityState
    let lifecycleRail: [GoalLifecycleRailSegment]
    let stateChips: [GoalStateChipState]
    let atlasPreview: GoalAtlasPreviewState?
    let archiveSummary: GoalPortfolioArchiveSummary
    let items: [GoalListItem]
    let isSeeded: Bool
    let emptyTitle: String
    let emptyMessage: String

    init(
        hero: GoalsBoardHeroState,
        heroPrimaryAction: GoalsBoardPrimaryAction,
        bands: [GoalsBoardBand],
        horizonLadder: GoalsHorizonLadderState,
        weekPressureSummary: GoalsWeekPressureSummary,
        lowerPriority: GoalsLowerPriorityState,
        lifecycleRail: [GoalLifecycleRailSegment],
        stateChips: [GoalStateChipState],
        atlasPreview: GoalAtlasPreviewState?,
        archiveSummary: GoalPortfolioArchiveSummary,
        items: [GoalListItem],
        isSeeded: Bool,
        emptyTitle: String,
        emptyMessage: String
    ) {
        self.hero = hero
        self.heroPrimaryAction = heroPrimaryAction
        self.bands = bands
        self.horizonLadder = horizonLadder
        self.weekPressureSummary = weekPressureSummary
        self.lowerPriority = lowerPriority
        self.lifecycleRail = lifecycleRail
        self.stateChips = stateChips
        self.atlasPreview = atlasPreview
        self.archiveSummary = archiveSummary
        self.items = items
        self.isSeeded = isSeeded
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
    }
}

struct CreateGoalRequest: Sendable {
    let title: String
    let mode: GoalMode?
    let entrySource: ShellCommandEntrySource?
    let clarifiedFields: [MissingFieldKey: String]
    let preferredPace: StrategyComposerPaceChoice?
    let targetDateOverride: String?
    let captureID: String?

    init(
        title: String,
        mode: GoalMode? = nil,
        entrySource: ShellCommandEntrySource? = nil,
        clarifiedFields: [MissingFieldKey: String] = [:],
        preferredPace: StrategyComposerPaceChoice? = nil,
        targetDateOverride: String? = nil,
        captureID: String? = nil
    ) {
        self.title = title
        self.mode = mode
        self.entrySource = entrySource
        self.clarifiedFields = clarifiedFields
        self.preferredPace = preferredPace
        self.targetDateOverride = targetDateOverride
        self.captureID = captureID
    }
}

struct CreateGoalResponse: Sendable {
    let target: GoalRouteTarget
    let blueprint: GoalBlueprint
    let resultKind: GoalOrchestrationResultKind
    let planningEvaluation: PlanningEvaluation?

    init(
        target: GoalRouteTarget,
        blueprint: GoalBlueprint,
        resultKind: GoalOrchestrationResultKind = .planned,
        planningEvaluation: PlanningEvaluation? = nil
    ) {
        self.target = target
        self.blueprint = blueprint
        self.resultKind = resultKind
        self.planningEvaluation = planningEvaluation
    }
}

enum StrategyComposerPaceChoice: String, CaseIterable, Identifiable, Sendable {
    case conservative
    case balanced
    case aggressive

    var id: String { rawValue }
}

struct StrategyComposerPaceOptionState: Identifiable, Sendable {
    let choice: StrategyComposerPaceChoice
    let title: String
    let subtitle: String
    let badgeTitle: String
    let state: AmbitionVisualState

    var id: StrategyComposerPaceChoice { choice }
}

struct StrategyComposerFeasibilityState: Sendable {
    let title: String
    let summary: String
    let details: [String]
    let state: AmbitionVisualState
}

struct StrategyComposerDeadlineGuidanceState: Sendable {
    let title: String
    let body: String
    let suggestedDate: String
    let badgeTitle: String
    let state: AmbitionVisualState
}

struct StrategyComposerTrustState: Sendable {
    let title: String
    let lines: [String]
    let badgeTitle: String
    let state: AmbitionVisualState
}

struct CreateGoalPreviewRequest: Sendable {
    let title: String
    let mode: GoalMode?
    let entrySource: ShellCommandEntrySource
    let clarifiedFields: [MissingFieldKey: String]
    let preferredPace: StrategyComposerPaceChoice
    let targetDateOverride: String?
    let captureID: String?

    init(
        title: String,
        mode: GoalMode? = nil,
        entrySource: ShellCommandEntrySource,
        clarifiedFields: [MissingFieldKey: String] = [:],
        preferredPace: StrategyComposerPaceChoice = .balanced,
        targetDateOverride: String? = nil,
        captureID: String? = nil
    ) {
        self.title = title
        self.mode = mode
        self.entrySource = entrySource
        self.clarifiedFields = clarifiedFields
        self.preferredPace = preferredPace
        self.targetDateOverride = targetDateOverride
        self.captureID = captureID
    }
}

struct CreateGoalPreviewState: Sendable {
    let normalizedTitle: String
    let summary: String
    let modeLabel: String
    let resultKind: GoalOrchestrationResultKind
    let renderState: GoalRenderState
    let selectedPace: StrategyComposerPaceChoice
    let paceOptions: [StrategyComposerPaceOptionState]
    let feasibility: StrategyComposerFeasibilityState?
    let deadlineGuidance: StrategyComposerDeadlineGuidanceState?
    let pathStages: [GoalPathStage]
    let milestonePreview: [GoalDetailStepItem]
    let clarification: GoalClarificationState?
    let blocked: GoalBlockedState?
    let trust: StrategyComposerTrustState
    let planningEvaluation: PlanningEvaluation?
}

struct GoalDetailActionState: Identifiable, Sendable {
    let kind: GoalDetailActionKind
    let title: String
    let systemImage: String
    let state: AmbitionVisualState

    var id: String { kind.rawValue }
}

enum GoalDetailActionKind: String, Sendable {
    case complete
    case delay
    case skip
    case createReminder
    case createCalendarEvent
    case askForSmallerStep
    case askWhyThisMatters
    case markNotRelevant
    case breakThisDownSmaller
    case imStuck
    case showPath
    case switchToUntimed
    case showSupportMode
    case raisePriority
    case lowerPriority
}

struct GoalClarificationQuestionState: Identifiable, Sendable {
    let id: String
    let field: MissingFieldKey
    let prompt: String
    let rationale: String
    let gentleDefault: String
    let existingAnswer: String?
}

struct GoalClarificationAnswerRequest: Sendable {
    let target: GoalRouteTarget
    let questionID: String
    let field: MissingFieldKey
    let answer: String
}

struct GoalDetailActionRequest: Sendable {
    let target: GoalRouteTarget
    let kind: GoalDetailActionKind
    let stepID: String?
}

enum GoalExplainabilityCorrectionControlKind: String, Sendable {
    case markSupportNotRelevant = "mark_support_not_relevant"
    case confirmContradiction = "confirm_contradiction"
    case dismissContradiction = "dismiss_contradiction"
    case requestLighterVersion = "request_lighter_version"
}

struct GoalWhyThisState: Sendable {
    let compactSummary: String
    let lines: [String]
}

struct GoalSourceAuditRowState: Identifiable, Sendable {
    let id: String
    let resourceID: String
    let title: String
    let subtitle: String
    let detailLabels: [String]
    let state: AmbitionVisualState
}

struct GoalSourceAuditSectionState: Sendable {
    let rows: [GoalSourceAuditRowState]
}

struct GoalFreshnessState: Sendable {
    let posture: GoalFreshnessPosture
    let postureLabel: String
    let severityLabel: String
    let detailLabels: [String]
}

struct GoalConfidenceState: Sendable {
    let understandingConfidence: RecommendationConfidence
    let pathConfidence: RecommendationConfidence?
    let detailLabels: [String]
}

struct GoalContradictionSummaryState: Identifiable, Sendable {
    let id: String
    let code: GoalContradictionCode
    let title: String
    let summary: String
    let severityLabel: String
    let state: AmbitionVisualState
}

struct GoalCorrectionControlState: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let kind: GoalExplainabilityCorrectionControlKind
    let artifactKind: GoalTeachingArtifactKind
    let teachingSignalKind: GoalTeachingSignalKind
    let payload: GoalTeachingPayload
    let target: GoalTeachingCaptureTarget
    let state: AmbitionVisualState
}

struct GoalAppliedTeachingBadgeState: Identifiable, Sendable {
    let id: String
    let signalID: String
    let title: String
    let subtitle: String
    let state: AmbitionVisualState
}

struct GoalTrustWhisperPillState: Identifiable, Sendable {
    let id: String
    let title: String
    let icon: String
    let state: AmbitionVisualState
}

struct GoalTrustWhisperState: Sendable {
    let title: String
    let subtitle: String
    let pillLine: String
    let pills: [GoalTrustWhisperPillState]
}

struct GoalExplainabilityState: Sendable {
    let whisper: GoalTrustWhisperState
    let whyThis: GoalWhyThisState
    let sourceAudit: GoalSourceAuditSectionState
    let freshness: GoalFreshnessState
    let confidence: GoalConfidenceState
    let contradictions: [GoalContradictionSummaryState]
    let correctionControls: [GoalCorrectionControlState]
    let appliedTeachingBadges: [GoalAppliedTeachingBadgeState]
}

struct GoalExplainabilityCorrectionRequest: Sendable {
    let target: GoalRouteTarget
    let control: GoalCorrectionControlState
}

struct GoalDetailInlineMessage: Identifiable, Sendable {
    let id: String
    let title: String
    let body: String
    let state: AmbitionVisualState

    init(id: String = UUID().uuidString, title: String, body: String, state: AmbitionVisualState) {
        self.id = id
        self.title = title
        self.body = body
        self.state = state
    }
}

struct GoalDetailActionResponse: Sendable {
    let message: GoalDetailInlineMessage?
}

struct GoalDetailHeadline: Sendable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let renderState: GoalRenderState
    let modeLabel: String
    let timingLabel: String
    let supportLabel: String?
}

struct GoalDetailProgress: Sendable {
    let label: String
    let detail: String
    let value: Double
    let evidenceLabel: String
}

struct GoalDetailStrategicStatus: Sendable {
    let title: String
    let summary: String
    let supportingDetail: String
}

enum GoalPathStagePosition: String, Sendable {
    case completed
    case current
    case blocked
    case upcoming

    var title: String {
        switch self {
        case .completed: "Completed"
        case .current: "Current"
        case .blocked: "Blocked"
        case .upcoming: "Upcoming"
        }
    }
}

struct GoalDetailStepItem: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let timingLabel: String
    let statusLabel: String
    let state: AmbitionVisualState
}

struct GoalDetailSectionState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let kindLabel: String
    let steps: [GoalDetailStepItem]
}

struct GoalPathStage: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let stepCountLabel: String
    let position: GoalPathStagePosition
    let statusLabel: String
    let highlight: String?
    let state: AmbitionVisualState
}

struct GoalDetailNextMovement: Sendable {
    let title: String
    let summary: String
    let timingLabel: String
    let rationale: String
    let state: AmbitionVisualState
}

struct GoalDetailTrajectoryState: Sendable {
    let phaseTitle: String
    let phaseSummary: String
    let milestoneSummary: String
    let momentumSummary: String
    let timelineSummary: String
}

struct GoalEvidenceItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: String
    let state: AmbitionVisualState
}

struct GoalFeedbackItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: String
    let state: AmbitionVisualState
}

struct GoalDetailRecentMovementItem: Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let timestamp: String
    let categoryLabel: String
    let state: AmbitionVisualState
}

struct GoalDetailRecentMovementState: Sendable {
    let title: String
    let summary: String
    let items: [GoalDetailRecentMovementItem]
}

enum GoalDetailMissionLaneKind: String, Sendable, CaseIterable {
    case path
    case now
    case proof
    case risk

    var title: String {
        switch self {
        case .path: "Path"
        case .now: "Now"
        case .proof: "Proof"
        case .risk: "Risk"
        }
    }

    var accessibilityIdentifier: String {
        "goal-detail.lane.\(rawValue)"
    }
}

struct GoalDetailMissionLaneState: Identifiable, Sendable {
    let kind: GoalDetailMissionLaneKind
    let title: String
    let headline: String
    let summary: String
    let detail: String
    let badgeTitle: String
    let systemImage: String
    let state: AmbitionVisualState

    var id: String { kind.rawValue }
}

struct GoalDetailBreadcrumbState: Sendable {
    let title: String
    let labels: [String]
    let fallbackUsed: Bool
}

enum GoalDetailTimelineItemKind: String, Sendable {
    case started
    case previous
    case current
    case next
    case proof
    case decision
    case waiting
    case parked
    case completed
    case cancelled

    var title: String {
        switch self {
        case .started: "Started"
        case .previous: "Previous"
        case .current: "Current"
        case .next: "Next"
        case .proof: "Proof"
        case .decision: "Decision"
        case .waiting: "Waiting"
        case .parked: "Parked"
        case .completed: "Completed"
        case .cancelled: "Cancelled"
        }
    }
}

struct GoalDetailTimelineItemState: Identifiable, Sendable {
    let id: String
    let kind: GoalDetailTimelineItemKind
    let title: String
    let summary: String
    let timestamp: String?
    let state: AmbitionVisualState
    let isFuture: Bool
}

struct GoalDetailTimelineState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalDetailTimelineItemState]
}

struct GoalDetailAssumptionState: Identifiable, Sendable {
    let id: String
    let title: String
    let status: String
    let whyItMatters: String
    let correctionLabel: String?
    let state: AmbitionVisualState
}

struct GoalDetailProofRailState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalEvidenceItem]
    let emptyTitle: String
    let emptyMessage: String
}

struct GoalDetailReceiptItemState: Identifiable, Sendable {
    let id: String
    let title: String
    let summary: String
    let timestamp: String
    let state: AmbitionVisualState
}

struct GoalDetailReceiptsState: Sendable {
    let title: String
    let subtitle: String
    let items: [GoalDetailReceiptItemState]
    let emptyTitle: String
    let emptyMessage: String
}

struct GoalDetailMissionControlState: Sendable {
    let currentTruth: String
    let primaryNextMove: GoalNextVisibleStep
    let breadcrumb: GoalDetailBreadcrumbState
    let lanes: [GoalDetailMissionLaneState]
    let timeline: GoalDetailTimelineState
    let assumptions: [GoalDetailAssumptionState]
    let proofRail: GoalDetailProofRailState
    let receipts: GoalDetailReceiptsState
}

struct GoalClarificationState: Sendable {
    let title: String
    let subtitle: String
    let questions: [GoalClarificationQuestionState]
}

struct GoalBlockedState: Sendable {
    let title: String
    let subtitle: String
    let blockers: [String]
}

struct GoalDetailPresentation: Sendable {
    let target: GoalRouteTarget
    let headline: GoalDetailHeadline
    let outcome: String
    let intent: String
    let progress: GoalDetailProgress
    let strategicStatus: GoalDetailStrategicStatus
    let nextMovement: GoalDetailNextMovement?
    let trajectory: GoalDetailTrajectoryState
    let timingNote: String
    let progressNote: String
    let manualPriorityLabel: String
    let assumptions: [String]
    let suggestions: [GoalDetailStepItem]
    let pathStages: [GoalPathStage]
    let sections: [GoalDetailSectionState]
    let clarification: GoalClarificationState?
    let blocked: GoalBlockedState?
    let evidence: [GoalEvidenceItem]
    let history: [GoalFeedbackItem]
    let recentMovement: GoalDetailRecentMovementState
    let actions: [GoalDetailActionState]
    let explainability: GoalExplainabilityState?
    let primaryStepID: String?
    let canSwitchToUntimed: Bool
    let supportModeActive: Bool
    let defaultLens: GoalDetailLens
    let missionControl: GoalDetailMissionControlState?

    init(
        target: GoalRouteTarget,
        headline: GoalDetailHeadline,
        outcome: String,
        intent: String,
        progress: GoalDetailProgress,
        strategicStatus: GoalDetailStrategicStatus,
        nextMovement: GoalDetailNextMovement?,
        trajectory: GoalDetailTrajectoryState,
        timingNote: String,
        progressNote: String,
        manualPriorityLabel: String,
        assumptions: [String],
        suggestions: [GoalDetailStepItem],
        pathStages: [GoalPathStage],
        sections: [GoalDetailSectionState],
        clarification: GoalClarificationState?,
        blocked: GoalBlockedState?,
        evidence: [GoalEvidenceItem],
        history: [GoalFeedbackItem],
        recentMovement: GoalDetailRecentMovementState,
        actions: [GoalDetailActionState],
        explainability: GoalExplainabilityState?,
        primaryStepID: String?,
        canSwitchToUntimed: Bool,
        supportModeActive: Bool,
        defaultLens: GoalDetailLens,
        missionControl: GoalDetailMissionControlState? = nil
    ) {
        self.target = target
        self.headline = headline
        self.outcome = outcome
        self.intent = intent
        self.progress = progress
        self.strategicStatus = strategicStatus
        self.nextMovement = nextMovement
        self.trajectory = trajectory
        self.timingNote = timingNote
        self.progressNote = progressNote
        self.manualPriorityLabel = manualPriorityLabel
        self.assumptions = assumptions
        self.suggestions = suggestions
        self.pathStages = pathStages
        self.sections = sections
        self.clarification = clarification
        self.blocked = blocked
        self.evidence = evidence
        self.history = history
        self.recentMovement = recentMovement
        self.actions = actions
        self.explainability = explainability
        self.primaryStepID = primaryStepID
        self.canSwitchToUntimed = canSwitchToUntimed
        self.supportModeActive = supportModeActive
        self.defaultLens = defaultLens
        self.missionControl = missionControl
    }
}

extension GoalMode {
    var displayTitle: String {
        switch self {
        case .achievement: "Achievement"
        case .project: "Project"
        case .habit: "Ritual"
        case .learning: "Learning"
        case .exploration: "Exploration"
        case .maintenance: "Maintenance"
        case .recovery: "Recovery"
        case .delegatedSupport: "Support"
        }
    }
}
