import AmbitionsDesignSystem
import Foundation

enum PlanDashboardMode: Sendable {
    case empty
    case active
}

enum PlanWeekPressureLevel: String, Sendable, CaseIterable {
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

enum PlanWeekBlockKind: String, Sendable {
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

enum PlanWeekPrimaryActionKind: String, Sendable {
    case shapeWeek = "shape_week"
    case lightenWeek = "lighten_week"
    case useRoom = "use_room"
    case resolveCarryover = "resolve_carryover"
}

enum PlanShapingActionKind: String, Sendable, CaseIterable {
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

enum PlanCalendarAwarenessStatus: String, Sendable {
    case unavailable
    case baseline
    case calendarAware
    case denied
    case writeOnly
}

struct PlanCalendarAwarenessState: Sendable {
    let status: PlanCalendarAwarenessStatus
    let title: String
    let detail: String
    let primaryActionTitle: String
    let primaryActionSystemImage: String
    let valueLabel: String
    let sourceLabel: String
    let visualState: AmbitionVisualState
    let canRequestCalendarRead: Bool
}

struct PlanHeroPillState: Identifiable, Sendable, Hashable {
    let title: String
    let icon: String?
    let state: AmbitionVisualState

    var id: String { [title, icon ?? "", state.rawValue].joined(separator: "|") }
}

struct PlanRealityHeroState: Sendable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let dominantTruth: String
    let roomSummary: String
    let pressureSummary: String
    let contextPills: [PlanHeroPillState]
    let trustWhisper: String
}

struct PlanWeekPrimaryAction: Sendable {
    let kind: PlanWeekPrimaryActionKind
    let title: String
    let subtitle: String
    let systemImage: String
    let state: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let planRoute: PlanRouteTarget?
}

struct PlanPressureScrubberPoint: Identifiable, Sendable {
    let id: String
    let weekdayLabel: String
    let dateLabel: String
    let level: PlanWeekPressureLevel
    let pressureValue: Double
    let roomLabel: String
    let summary: String
}

struct PlanPressureScrubberState: Sendable {
    let title: String
    let subtitle: String
    let defaultDayID: String
    let points: [PlanPressureScrubberPoint]
}

struct PlanWeekBlockState: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget?
    let title: String
    let detail: String
    let goalLabel: String
    let timingLabel: String
    let kind: PlanWeekBlockKind
    let visualState: AmbitionVisualState
}

struct PlanOpenWindowState: Sendable {
    let title: String
    let detail: String
    let suggestionLabel: String?
    let target: GoalRouteTarget?
    let visualState: AmbitionVisualState
}

struct PlanWindowMagnetismState: Sendable {
    let title: String
    let detail: String
    let dayLabel: String
    let suggestionTitle: String
    let suggestionDetail: String
    let target: GoalRouteTarget?
    let visualState: AmbitionVisualState
}

struct PlanElasticWeekDayState: Identifiable, Sendable {
    let id: String
    let weekdayLabel: String
    let dateLabel: String
    let level: PlanWeekPressureLevel
    let intensity: Double
    let roomLabel: String
    let capacityLabel: String
    let highlight: String
    let blocks: [PlanWeekBlockState]
    let overflowCount: Int
    let openWindow: PlanOpenWindowState?
}

struct PlanBelievabilityState: Sendable {
    let title: String
    let detail: String
    let label: String
    let supportLabel: String
    let visualState: AmbitionVisualState
}

struct PlanExecutionResilienceLane: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let recommendation: String
    let state: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let planRoute: PlanRouteTarget?
}

struct PlanExecutionResilienceState: Sendable {
    let title: String
    let subtitle: String
    let calmExplanation: String
    let focusProtection: String
    let tradeoffFraming: String
    let lanes: [PlanExecutionResilienceLane]
    let windowMagnetism: PlanWindowMagnetismState?
}

struct PlanGoalShapingItem: Identifiable, Sendable {
    let id: String
    let target: GoalRouteTarget?
    let goalTitle: String
    let weekRelationship: String
    let pressureLabel: String
    let attentionReason: String
    let nextMoveLabel: String
    let visualState: AmbitionVisualState
}

struct PlanShapingActionState: Identifiable, Sendable {
    let kind: PlanShapingActionKind
    let title: String
    let subtitle: String
    let recommendation: String
    let systemImage: String
    let state: AmbitionVisualState
    let goalTarget: GoalRouteTarget?
    let planRoute: PlanRouteTarget?

    var id: String { kind.rawValue }
}

struct PlanTreatyState: Sendable {
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

struct PlanCapacityEnvelopeState: Sendable {
    let title: String
    let detail: String
    let label: String
    let availableCapacity: String
    let pressure: String
    let protectedFocus: String
    let recoveryMargin: String
    let visualState: AmbitionVisualState
}

struct PlanGoalLifecycleRailSegment: Identifiable, Sendable, Hashable {
    let lifecycleState: GoalPortfolioLifecycleState
    let count: Int
    let subtitle: String

    var id: String { lifecycleState.rawValue }
}

struct PlanGoalLifecycleRailState: Sendable {
    let title: String
    let subtitle: String
    let segments: [PlanGoalLifecycleRailSegment]
}

enum PlanTimelineItemKind: String, Sendable, Hashable {
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

struct PlanTimelineItemState: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let detail: String
    let timingLabel: String
    let sourceLabel: String
    let kind: PlanTimelineItemKind
    let visualState: AmbitionVisualState
    let target: GoalRouteTarget?
}

struct PlanTimelineStripState: Sendable {
    let title: String
    let subtitle: String
    let items: [PlanTimelineItemState]
}

struct PlanOpportunityWindowItem: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let detail: String
    let modeLabel: String
    let timingLabel: String
    let visualState: AmbitionVisualState
    let target: GoalRouteTarget?
}

struct PlanOpportunityWindowsState: Sendable {
    let title: String
    let subtitle: String
    let windows: [PlanOpportunityWindowItem]
}

struct PlanDecisionItemState: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let detail: String
    let suggestion: String
    let visualState: AmbitionVisualState
    let target: GoalRouteTarget?
    let planRoute: PlanRouteTarget?
}

struct PlanDecisionDebtState: Sendable {
    let title: String
    let subtitle: String
    let items: [PlanDecisionItemState]
}

struct PlanConflictCourtState: Sendable {
    let title: String
    let subtitle: String
    let conflicts: [PlanDecisionItemState]
}

struct PlanCalendarBoundaryContractState: Sendable {
    let title: String
    let detail: String
    let permissionLabel: String
    let sourceLabel: String
    let manualFallback: String
    let writeBoundary: String
    let visualState: AmbitionVisualState
    let canRequestCalendarRead: Bool
}

struct PlanRecoveryEntryState: Sendable {
    let title: String
    let detail: String
    let suggestions: [PlanDecisionItemState]
    let boundary: String
}

enum PlanRealityBreakReasonKind: String, Sendable, CaseIterable {
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
        case .missedDay: "Missed day"
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

enum PlanReflowSuggestionKind: String, Sendable, CaseIterable {
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
        case .moveLocalActionLater: "Move this later"
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

struct PlanReflowBoundaryState: Sendable, Hashable {
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

struct PlanReflowSuggestionState: Identifiable, Sendable, Hashable {
    let id: String
    let kind: PlanReflowSuggestionKind
    let title: String
    let detail: String
    let impactLabel: String
    let boundary: PlanReflowBoundaryState
    let visualState: AmbitionVisualState
    let target: GoalRouteTarget?
    let planRoute: PlanRouteTarget?
}

struct PlanRealityReflowState: Sendable {
    let title: String
    let detail: String
    let reasonKind: PlanRealityBreakReasonKind
    let reasonDetail: String
    let recommendedAdjustment: String
    let noChangeCopy: String
    let suggestions: [PlanReflowSuggestionState]
    let visualState: AmbitionVisualState
}

struct PlanRecoveryGradientOptionState: Identifiable, Sendable, Hashable {
    let id: String
    let order: Int
    let kind: PlanReflowSuggestionKind
    let title: String
    let detail: String
    let boundary: PlanReflowBoundaryState
    let visualState: AmbitionVisualState
}

struct PlanRecoveryGradientState: Sendable {
    let title: String
    let detail: String
    let options: [PlanRecoveryGradientOptionState]
}

struct PlanSaveTheDayState: Sendable {
    let title: String
    let detail: String
    let oneQuestion: String?
    let protectedItem: String
    let adjustment: String
    let recoveryExplanation: String
    let boundary: String
    let visualState: AmbitionVisualState
}

struct PlanReflowReceiptPreviewState: Sendable {
    let title: String
    let detail: String
    let whatChanged: [String]
    let whatWouldNotChange: [String]
    let confirmationRequired: String
    let undoAvailability: String
    let safeFailureFallback: String
    let visualState: AmbitionVisualState
}

struct PlanSecondaryDestination: Identifiable, Sendable {
    let id: String
    let title: String
    let detail: String
    let valueLabel: String
    let icon: String
    let visualState: AmbitionVisualState
    let planRoute: PlanRouteTarget?
}

struct WeeklyReviewHeroState: Sendable {
    let eyebrow: String
    let title: String
    let subtitle: String
    let dominantTruth: String
    let continuityLabel: String
    let contextPills: [PlanHeroPillState]
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
    let returnPlanRoute: PlanRouteTarget?
    let splitPaneContext: PlanWindowMagnetismState?
}

struct PlanDashboard: Sendable {
    let mode: PlanDashboardMode
    let timeframeLabel: String
    let hero: PlanRealityHeroState
    let primaryAction: PlanWeekPrimaryAction
    let treaty: PlanTreatyState
    let capacityEnvelope: PlanCapacityEnvelopeState
    let lifecycleRail: PlanGoalLifecycleRailState
    let timelineStrip: PlanTimelineStripState
    let opportunityWindows: PlanOpportunityWindowsState
    let decisionDebt: PlanDecisionDebtState
    let conflictCourt: PlanConflictCourtState
    let calendarBoundary: PlanCalendarBoundaryContractState
    let recoveryEntry: PlanRecoveryEntryState
    let realityReflow: PlanRealityReflowState
    let recoveryGradient: PlanRecoveryGradientState
    let saveTheDay: PlanSaveTheDayState
    let reflowReceiptPreview: PlanReflowReceiptPreviewState
    let pressureScrubber: PlanPressureScrubberState
    let weekDays: [PlanElasticWeekDayState]
    let believability: PlanBelievabilityState
    let calendarAwareness: PlanCalendarAwarenessState
    let resilience: PlanExecutionResilienceState
    let goalShapingItems: [PlanGoalShapingItem]
    let shapingActions: [PlanShapingActionState]
    let secondaryDestinations: [PlanSecondaryDestination]
    let emptyTitle: String?
    let emptyMessage: String?
}

extension PlanDashboard {
    func screenContractSnapshot(
        topLevelTabTitles: [String] = ScreenContractValidator.canonicalTopLevelTabs
    ) -> ScreenContractImplementationSnapshot {
        ScreenContractImplementationSnapshot(
            screenID: .plan,
            firstScreenContent: [
                "Week fit",
                "Weekly Plan Strip",
                "Rich Timeline Widget",
                "Rituals",
                "Scheduling",
                "Open windows"
            ],
            panels: [.heroDecision, .schedule, .timeline, .weeklyPlanStrip, .recovery, .trust],
            actions: [.makeCalendarAware, .findWindows, .move, .protect, .saveTheWeek],
            drillDowns: ["Calendar mode", "Rituals", "Review archive", "Receipts"],
            copySamples: [
                hero.title,
                hero.subtitle,
                treaty.title,
                capacityEnvelope.title,
                timelineStrip.title,
                calendarAwareness.sourceLabel,
                calendarBoundary.writeBoundary,
                recoveryEntry.title,
                saveTheDay.title
            ] + timelineStrip.items.map(\.sourceLabel),
            topLevelTabTitles: topLevelTabTitles,
            supportsDensityBehavior: true,
            supportsPanelSizeBehavior: true,
            hasAccessibilitySummary: true,
            hasPrivacySafeState: true,
            hasGestureAlternative: true
        )
    }
}
