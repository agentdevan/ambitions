import AmbitionsDesignSystem
import Foundation

enum TimeDashboardMode: Sendable {
    case empty
    case active
}

enum TimeWeekPressureLevel: String, Sendable, CaseIterable {
    case open
    case steady
    case tight
    case fragile
    case overloaded

    var title: String {
        switch self {
        case .open: "Open room"
        case .steady: "Steady"
        case .tight: "Tight"
        case .fragile: "Too much planned"
        case .overloaded: "Overloaded"
        }
    }

    var icon: String {
        switch self {
        case .open: "sparkles"
        case .steady: "circle.lefthalf.filled"
        case .tight: "calendar.badge.clock"
        case .fragile: "exclamationmark.triangle"
        case .overloaded: "exclamationmark.triangle.fill"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .open: .success
        case .steady: .selected
        case .tight: .warning
        case .fragile: .warning
        case .overloaded: .warning
        }
    }
}

enum TimeWeekBlockKind: String, Sendable {
    case fixed
    case flexible
    case protected

    var title: String {
        switch self {
        case .fixed: "Fixed"
        case .flexible: "Flexible"
        case .protected: "Time set aside"
        }
    }

    var icon: String {
        switch self {
        case .fixed: "pin.fill"
        case .flexible: "arrow.left.and.right"
        case .protected: "clock.badge.checkmark"
        }
    }
}

enum TimeWeekPrimaryActionKind: String, Sendable {
    case shapeWeek = "shape_week"
    case lightenWeek = "lighten_week"
    case useRoom = "use_room"
    case resolveCarryover = "resolve_carryover"
}

enum TimeShapingActionKind: String, Sendable, CaseIterable {
    case edit
    case patch
    case protect
    case lighten

    var title: String {
        switch self {
        case .edit: "Edit"
        case .patch: "Patch"
        case .protect: "Keep this"
        case .lighten: "Lighten"
        }
    }

    var systemImage: String {
        switch self {
        case .edit: "square.and.pencil"
        case .patch: "wand.and.stars"
        case .protect: "checkmark.circle"
        case .lighten: "sun.max"
        }
    }
}

enum TimeCalendarAwarenessStatus: String, Sendable {
    case unavailable
    case baseline
    case calendarAware
    case denied
    case writeOnly
}

struct TimeCalendarAwarenessState: Sendable {
    let status: TimeCalendarAwarenessStatus
    let title: String
    let detail: String
    let primaryActionTitle: String
    let primaryActionSystemImage: String
    let valueLabel: String
    let sourceLabel: String
    let visualState: AmbitionVisualState
    let canRequestCalendarRead: Bool
}

struct TimeHeroPillState: Identifiable, Sendable, Hashable {
    let title: String
    let icon: String?
    let state: AmbitionVisualState

    var id: String { [title, icon ?? "", state.rawValue].joined(separator: "|") }
}

struct TimeRealityHeroState: Sendable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let dominantTruth: String
    let roomSummary: String
    let pressureSummary: String
    let contextPills: [TimeHeroPillState]
    let trustWhisper: String
}

struct TimeWeekPrimaryAction: Sendable {
    let kind: TimeWeekPrimaryActionKind
    let title: String
    let subtitle: String
    let systemImage: String
    let state: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let timeRoute: TimeRouteTarget?
}

struct TimePressureScrubberPoint: Identifiable, Sendable {
    let id: String
    let weekdayLabel: String
    let dateLabel: String
    let level: TimeWeekPressureLevel
    let pressureValue: Double
    let roomLabel: String
    let summary: String
}

struct TimePressureScrubberState: Sendable {
    let title: String
    let subtitle: String
    let defaultDayID: String
    let points: [TimePressureScrubberPoint]
}

struct TimeWeekBlockState: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget?
    let title: String
    let detail: String
    let goalLabel: String
    let timingLabel: String
    let kind: TimeWeekBlockKind
    let visualState: AmbitionVisualState
}

struct TimeOpenWindowState: Sendable {
    let title: String
    let detail: String
    let suggestionLabel: String?
    let target: GoalRouteTarget?
    let visualState: AmbitionVisualState
}

struct TimeWindowMagnetismState: Sendable {
    let title: String
    let detail: String
    let dayLabel: String
    let suggestionTitle: String
    let suggestionDetail: String
    let target: GoalRouteTarget?
    let visualState: AmbitionVisualState
}

struct TimeElasticWeekDayState: Identifiable, Sendable {
    let id: String
    let weekdayLabel: String
    let dateLabel: String
    let level: TimeWeekPressureLevel
    let intensity: Double
    let roomLabel: String
    let capacityLabel: String
    let highlight: String
    let blocks: [TimeWeekBlockState]
    let overflowCount: Int
    let openWindow: TimeOpenWindowState?
}

struct TimeBelievabilityState: Sendable {
    let title: String
    let detail: String
    let label: String
    let supportLabel: String
    let visualState: AmbitionVisualState
}

struct TimeExecutionResilienceLane: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let recommendation: String
    let state: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let timeRoute: TimeRouteTarget?
}

struct TimeExecutionResilienceState: Sendable {
    let title: String
    let subtitle: String
    let calmExplanation: String
    let focusProtection: String
    let tradeoffFraming: String
    let lanes: [TimeExecutionResilienceLane]
    let windowMagnetism: TimeWindowMagnetismState?
}

struct TimeGoalShapingItem: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget?
    let goalTitle: String
    let weekRelationship: String
    let pressureLabel: String
    let attentionReason: String
    let nextMoveLabel: String
    let visualState: AmbitionVisualState
}

struct TimeShapingActionState: Identifiable, Sendable {
    let kind: TimeShapingActionKind
    let title: String
    let subtitle: String
    let recommendation: String
    let systemImage: String
    let state: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let timeRoute: TimeRouteTarget?

    var id: String { kind.rawValue }
}

struct TimeTreatyState: Sendable {
    let title: String
    let summary: String
    let protectedWork: String
    let flexibleWork: String
    let notTodayWork: String
    let recoveryAllowance: String
    let calendarBoundary: String
    let primaryActionTitle: String
    let primaryActionSubtitle: String
    let visualState: AmbitionVisualState
}

struct TimeCapacityEnvelopeState: Sendable {
    let title: String
    let detail: String
    let label: String
    let availableCapacity: String
    let pressure: String
    let protectedFocus: String
    let recoveryMargin: String
    let visualState: AmbitionVisualState
}

struct TimePressureRecoverySignalState: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let detail: String
    let statusLabel: String
    let boundaryLabel: String
    let visualState: AmbitionVisualState
}

struct TimePressureRecoveryReviewState: Sendable {
    let title: String
    let detail: String
    let pressureFieldLabel: String
    let recoveryLoopLabel: String
    let weekPressureLabel: String
    let overloadedDayLabel: String
    let recoverySpaceLabel: String
    let smallerStepAnchorLabel: String
    let protectedTimeConflictLabel: String
    let lateStartAdjustmentLabel: String
    let recoveryDayReviewLabel: String
    let recoveryReceiptPreviewLabel: String
    let capacityReviewLabel: String
    let signals: [TimePressureRecoverySignalState]
    let visualState: AmbitionVisualState

    static let baseline = TimePressureRecoveryReviewState(
        title: "Pressure and recovery review",
        detail: "Pressure gets explained before the week changes.",
        pressureFieldLabel: "Pressure field: no relief needed.",
        recoveryLoopLabel: "Recovery loop: keep breathing room visible.",
        weekPressureLabel: "Pressure is readable.",
        overloadedDayLabel: "Overloaded day explanation: no day is asking for relief right now.",
        recoverySpaceLabel: "Recovery space: keep breathing room visible.",
        smallerStepAnchorLabel: "Smaller step anchor: keep the next ask believable.",
        protectedTimeConflictLabel: "Protected time conflict: nothing protected is competing loudly.",
        lateStartAdjustmentLabel: "Late-start adjustment: start with the smaller version.",
        recoveryDayReviewLabel: "Recovery-day review: Still counts.",
        recoveryReceiptPreviewLabel: "Recovery receipt preview: nothing changes without review.",
        capacityReviewLabel: "Capacity review: qualitative only.",
        signals: [],
        visualState: .default
    )

    var accessibilityValue: String {
        [
            detail,
            pressureFieldLabel,
            recoveryLoopLabel,
            weekPressureLabel,
            overloadedDayLabel,
            recoverySpaceLabel,
            smallerStepAnchorLabel,
            protectedTimeConflictLabel,
            lateStartAdjustmentLabel,
            recoveryDayReviewLabel,
            recoveryReceiptPreviewLabel,
            capacityReviewLabel,
            signals.map { "\($0.title): \($0.detail)" }.joined(separator: ". ")
        ].joined(separator: ". ")
    }
}

struct TimeGoalLifecycleRailSegment: Identifiable, Sendable, Hashable {
    let lifecycleState: GoalPortfolioLifecycleState
    let count: Int
    let subtitle: String

    var id: String { lifecycleState.rawValue }
}

struct TimeGoalLifecycleRailState: Sendable {
    let title: String
    let subtitle: String
    let segments: [TimeGoalLifecycleRailSegment]
}

enum TimeTimelineItemKind: String, Sendable, Hashable {
    case previous
    case active
    case future
    case outside

    var title: String {
        switch self {
        case .previous: "Previous"
        case .active: "Active"
        case .future: "Future"
        case .outside: "Outside"
        }
    }
}

struct TimeTimelineItemState: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let detail: String
    let timingLabel: String
    let sourceLabel: String
    let kind: TimeTimelineItemKind
    let visualState: AmbitionVisualState
    let target: GoalRouteTarget?
}

struct TimeTimelineStripState: Sendable {
    let title: String
    let subtitle: String
    let items: [TimeTimelineItemState]
}

struct TimeOpportunityWindowItem: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let detail: String
    let modeLabel: String
    let timingLabel: String
    let visualState: AmbitionVisualState
    let target: GoalRouteTarget?
}

struct TimeOpportunityWindowsState: Sendable {
    let title: String
    let subtitle: String
    let windows: [TimeOpportunityWindowItem]
}

struct TimeDecisionItemState: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let detail: String
    let suggestion: String
    let visualState: AmbitionVisualState
    let target: GoalRouteTarget?
    let timeRoute: TimeRouteTarget?
}

struct TimeDecisionDebtState: Sendable {
    let title: String
    let subtitle: String
    let items: [TimeDecisionItemState]
}

struct TimeConflictCourtState: Sendable {
    let title: String
    let subtitle: String
    let conflicts: [TimeDecisionItemState]
}

struct TimeCalendarBoundaryContractState: Sendable {
    let title: String
    let detail: String
    let permissionLabel: String
    let sourceLabel: String
    let manualFallback: String
    let writeBoundary: String
    let visualState: AmbitionVisualState
    let canRequestCalendarRead: Bool
}

struct TimeRecoveryEntryState: Sendable {
    let title: String
    let detail: String
    let suggestions: [TimeDecisionItemState]
    let boundary: String
}

enum TimeRealityBreakReasonKind: String, Sendable, CaseIterable {
    case missedDay = "missed_day"
    case overloadedPlan = "overloaded_plan"
    case noRecoveryMargin = "no_recovery_margin"
    case blockedGoal = "blocked_goal"
    case waitingOnPersonOrResource = "waiting_on_person_or_resource"
    case noNextStep = "no_next_step"
    case calendarUnavailableOrDenied = "calendar_unavailable_or_denied"
    case tooManyActiveGoals = "too_many_active_goals"
    case proofMissing = "proof_missing"
    case urgentOutsideItem = "urgent_outside_item"
    case lowCapacityFragileDay = "low_capacity_fragile_day"
    case lowData = "low_data"
    case stillBelievable = "still_believable"

    var title: String {
        switch self {
        case .missedDay: "Needs Recovery"
        case .overloadedPlan: "Overloaded plan"
        case .noRecoveryMargin: "No room to recover"
        case .blockedGoal: "Blocked goal"
        case .waitingOnPersonOrResource: "Waiting item"
        case .noNextStep: "No next step"
        case .calendarUnavailableOrDenied: "Calendar unavailable"
        case .tooManyActiveGoals: "Too many active goals"
        case .proofMissing: "Proof missing"
        case .urgentOutsideItem: "Outside item"
        case .lowCapacityFragileDay: "Too much for today"
        case .lowData: "Not enough plan data yet"
        case .stillBelievable: "Plan still looks doable"
        }
    }
}

enum TimeReflowSuggestionKind: String, Sendable, CaseIterable {
    case protectOneItem = "protect_one_item"
    case shrinkAction = "shrink_action"
    case splitAction = "split_action"
    case moveLocalActionLater = "move_local_action_later"
    case deferGoalOrItem = "defer_goal_or_item"
    case dropOptionalWork = "drop_optional_work"
    case parkGoal = "park_goal"
    case markWaiting = "mark_waiting"
    case recoverRest = "recover_rest"
    case askForConfirmation = "ask_for_confirmation"
    case keepPlanUnchanged = "keep_plan_unchanged"

    var title: String {
        switch self {
        case .protectOneItem: "Keep this"
        case .shrinkAction: "Make it smaller"
        case .splitAction: "Split it"
        case .moveLocalActionLater: "Adjust plan"
        case .deferGoalOrItem: "Defer this"
        case .dropOptionalWork: "Drop optional work"
        case .parkGoal: "Park goal"
        case .markWaiting: "Mark waiting"
        case .recoverRest: "Recover"
        case .askForConfirmation: "Needs confirmation"
        case .keepPlanUnchanged: "Keep plan unchanged"
        }
    }

    var icon: String {
        switch self {
        case .protectOneItem: "checkmark.circle"
        case .shrinkAction: "arrow.down.right.and.arrow.up.left"
        case .splitAction: "square.split.2x1"
        case .moveLocalActionLater: "clock.arrow.circlepath"
        case .deferGoalOrItem: "tray.and.arrow.down"
        case .dropOptionalWork: "minus.circle"
        case .parkGoal: "pause.circle"
        case .markWaiting: "hourglass"
        case .recoverRest: "sun.max"
        case .askForConfirmation: "hand.tap"
        case .keepPlanUnchanged: "checkmark.seal"
        }
    }

    var safeAutomationActionKind: SafeAutomationActionKind {
        switch self {
        case .protectOneItem: .changePlanWindow
        case .shrinkAction: .shrinkAction
        case .splitAction: .splitAction
        case .moveLocalActionLater: .moveActionLater
        case .deferGoalOrItem: .deferAction
        case .dropOptionalWork: .dropAction
        case .parkGoal: .changePlanWindow
        case .markWaiting: .markWaiting
        case .recoverRest: .noOp
        case .askForConfirmation: .changePlanWindow
        case .keepPlanUnchanged: .noOp
        }
    }
}

struct TimeReflowBoundaryState: Sendable, Hashable {
    let actionKind: SafeAutomationActionKind
    let confirmationRequirement: SafeAutomationConfirmationRequirement
    let undoAvailability: ActionReceiptUndoAvailability
    let safetyLabel: String

    var confirmationLabel: String {
        switch confirmationRequirement {
        case .notRequired: "Safe local suggestion"
        case .required: "Needs confirmation"
        case .requiredForExternalEffect: "External change needs confirmation"
        case .requiredForDestructiveChange: "Drop needs confirmation"
        case .requiredForBroadReflow: "Broad reflow needs confirmation"
        case .notAllowed: "Not supported"
        }
    }

    var undoLabel: String {
        switch undoAvailability {
        case .availableLocal: "Undo can be local"
        case .requiresConfirmation: "Undo needs confirmation"
        case .unavailable: "Undo unavailable"
        case .unsafe: "Undo unsafe"
        case .notSupportedYet: "Undo not supported yet"
        }
    }
}

struct TimeReflowSuggestionState: Identifiable, Sendable, Hashable {
    let id: String
    let kind: TimeReflowSuggestionKind
    let title: String
    let detail: String
    let impactLabel: String
    let boundary: TimeReflowBoundaryState
    let visualState: AmbitionVisualState
    let target: GoalRouteTarget?
    let timeRoute: TimeRouteTarget?
}

struct TimeRealityReflowState: Sendable {
    let title: String
    let detail: String
    let reasonKind: TimeRealityBreakReasonKind
    let reasonDetail: String
    let recommendedAdjustment: String
    let noChangeCopy: String
    let suggestions: [TimeReflowSuggestionState]
    let visualState: AmbitionVisualState
}

struct TimeRecoveryGradientOptionState: Identifiable, Sendable, Hashable {
    let id: String
    let order: Int
    let kind: TimeReflowSuggestionKind
    let title: String
    let detail: String
    let boundary: TimeReflowBoundaryState
    let visualState: AmbitionVisualState
}

struct TimeRecoveryGradientState: Sendable {
    let title: String
    let detail: String
    let options: [TimeRecoveryGradientOptionState]
}

struct TimeSaveTheDayState: Sendable {
    let title: String
    let detail: String
    let oneQuestion: String?
    let protectedItem: String
    let adjustment: String
    let recoveryExplanation: String
    let boundary: String
    let visualState: AmbitionVisualState
}

struct TimeReflowReceiptPreviewState: Sendable {
    let title: String
    let detail: String
    let whatChanged: [String]
    let whatWouldNotChange: [String]
    let confirmationRequired: String
    let undoAvailability: String
    let safeFailureFallback: String
    let visualState: AmbitionVisualState
}

struct TimeRecoveryMaturitySignalState: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let detail: String
    let statusLabel: String
    let boundaryLabel: String
    let visualState: AmbitionVisualState
}

struct TimeRecoveryMaturityState: Sendable {
    let title: String
    let detail: String
    let planFitLabel: String
    let confirmationBoundary: String
    let calendarBoundary: String
    let socialBoundary: String
    let receiptBoundary: String
    let signals: [TimeRecoveryMaturitySignalState]
}

struct TimeSecondaryDestination: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let valueLabel: String
    let icon: String
    let visualState: AmbitionVisualState
    let timeRoute: TimeRouteTarget?
}

struct WeeklyReviewHeroState: Sendable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let dominantTruth: String
    let continuityLabel: String
    let contextPills: [TimeHeroPillState]
}

struct WeeklyReviewCarryForwardItem: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let bridgeLabel: String
    let state: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
}

struct WeeklyReviewDashboard: Sendable {
    let timeframeLabel: String
    let hero: WeeklyReviewHeroState
    let summaryTitle: String
    let summaryDetail: String
    let carryForwardItems: [WeeklyReviewCarryForwardItem]
    let captureSummary: String
    let habitSummary: String
    let returnActionTitle: String
    let returnActionSubtitle: String
    let returnTimeRoute: TimeRouteTarget?
    let splitPaneContext: TimeWindowMagnetismState?
}

struct TimeDashboard: Sendable {
    let mode: TimeDashboardMode
    let timeframeLabel: String
    let hero: TimeRealityHeroState
    let lifeSuite: TimeLifeSuiteState
    let primaryAction: TimeWeekPrimaryAction
    let treaty: TimeTreatyState
    let capacityEnvelope: TimeCapacityEnvelopeState
    let pressureRecoveryReview: TimePressureRecoveryReviewState
    let lifecycleRail: TimeGoalLifecycleRailState
    let timelineStrip: TimeTimelineStripState
    let opportunityWindows: TimeOpportunityWindowsState
    let decisionDebt: TimeDecisionDebtState
    let conflictCourt: TimeConflictCourtState
    let calendarBoundary: TimeCalendarBoundaryContractState
    let recoveryEntry: TimeRecoveryEntryState
    let realityReflow: TimeRealityReflowState
    let reflowDecision: TimeReflowDecisionState
    let recoveryGradient: TimeRecoveryGradientState
    let saveTheDay: TimeSaveTheDayState
    let reflowReceiptPreview: TimeReflowReceiptPreviewState
    let recoveryMaturity: TimeRecoveryMaturityState
    let pressureScrubber: TimePressureScrubberState
    let weekDays: [TimeElasticWeekDayState]
    let believability: TimeBelievabilityState
    let calendarAwareness: TimeCalendarAwarenessState
    let resilience: TimeExecutionResilienceState
    let goalShapingItems: [TimeGoalShapingItem]
    let shapingActions: [TimeShapingActionState]
    let secondaryDestinations: [TimeSecondaryDestination]
    let emptyTitle: String?
    let emptyMessage: String?

    init(
        mode: TimeDashboardMode,
        timeframeLabel: String,
        hero: TimeRealityHeroState,
        lifeSuite: TimeLifeSuiteState,
        primaryAction: TimeWeekPrimaryAction,
        treaty: TimeTreatyState,
        capacityEnvelope: TimeCapacityEnvelopeState,
        pressureRecoveryReview: TimePressureRecoveryReviewState = .baseline,
        lifecycleRail: TimeGoalLifecycleRailState,
        timelineStrip: TimeTimelineStripState,
        opportunityWindows: TimeOpportunityWindowsState,
        decisionDebt: TimeDecisionDebtState,
        conflictCourt: TimeConflictCourtState,
        calendarBoundary: TimeCalendarBoundaryContractState,
        recoveryEntry: TimeRecoveryEntryState,
        realityReflow: TimeRealityReflowState,
        reflowDecision: TimeReflowDecisionState,
        recoveryGradient: TimeRecoveryGradientState,
        saveTheDay: TimeSaveTheDayState,
        reflowReceiptPreview: TimeReflowReceiptPreviewState,
        recoveryMaturity: TimeRecoveryMaturityState,
        pressureScrubber: TimePressureScrubberState,
        weekDays: [TimeElasticWeekDayState],
        believability: TimeBelievabilityState,
        calendarAwareness: TimeCalendarAwarenessState,
        resilience: TimeExecutionResilienceState,
        goalShapingItems: [TimeGoalShapingItem],
        shapingActions: [TimeShapingActionState],
        secondaryDestinations: [TimeSecondaryDestination],
        emptyTitle: String?,
        emptyMessage: String?
    ) {
        self.mode = mode
        self.timeframeLabel = timeframeLabel
        self.hero = hero
        self.lifeSuite = lifeSuite
        self.primaryAction = primaryAction
        self.treaty = treaty
        self.capacityEnvelope = capacityEnvelope
        self.pressureRecoveryReview = pressureRecoveryReview
        self.lifecycleRail = lifecycleRail
        self.timelineStrip = timelineStrip
        self.opportunityWindows = opportunityWindows
        self.decisionDebt = decisionDebt
        self.conflictCourt = conflictCourt
        self.calendarBoundary = calendarBoundary
        self.recoveryEntry = recoveryEntry
        self.realityReflow = realityReflow
        self.reflowDecision = reflowDecision
        self.recoveryGradient = recoveryGradient
        self.saveTheDay = saveTheDay
        self.reflowReceiptPreview = reflowReceiptPreview
        self.recoveryMaturity = recoveryMaturity
        self.pressureScrubber = pressureScrubber
        self.weekDays = weekDays
        self.believability = believability
        self.calendarAwareness = calendarAwareness
        self.resilience = resilience
        self.goalShapingItems = goalShapingItems
        self.shapingActions = shapingActions
        self.secondaryDestinations = secondaryDestinations
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
    }
}
