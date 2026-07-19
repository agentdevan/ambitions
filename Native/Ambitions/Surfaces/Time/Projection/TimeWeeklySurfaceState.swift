import AmbitionsDesignSystem
import Foundation

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

struct TimeWeeklyReviewState: Sendable {
    let timeframeLabel: String
    let hero: WeeklyReviewHeroState
    let summaryTitle: String
    let summaryDetail: String
    let carryForwardItems: [WeeklyReviewCarryForwardItem]
    let captureSummary: String
    let ritualSupportSummary: String
    let returnActionTitle: String
    let returnActionSubtitle: String
    let returnTimeRoute: TimeRouteTarget?
    let splitPaneContext: TimeWindowMagnetismState?
}

struct TimeSurfaceState: Sendable {
    let mode: TimeSurfaceMode
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
        mode: TimeSurfaceMode,
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
