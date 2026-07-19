import AmbitionsDesignSystem
import Foundation

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
    let interactionIntent: TimeInteractionIntent?

    init(
        id: String,
        title: String,
        detail: String,
        suggestion: String,
        visualState: AmbitionVisualState,
        target: GoalRouteTarget?,
        timeRoute: TimeRouteTarget?,
        interactionIntent: TimeInteractionIntent? = nil
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.suggestion = suggestion
        self.visualState = visualState
        self.target = target
        self.timeRoute = timeRoute
        self.interactionIntent = interactionIntent
    }
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
    case overloadedTimeShape = "overloaded_time_shape"
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
        case .overloadedTimeShape: "Week needs relief"
        case .noRecoveryMargin: "No room to recover"
        case .blockedGoal: "Blocked goal"
        case .waitingOnPersonOrResource: "Waiting item"
        case .noNextStep: "No next step"
        case .calendarUnavailableOrDenied: "Calendar unavailable"
        case .tooManyActiveGoals: "Too many active goals"
        case .proofMissing: "Proof missing"
        case .urgentOutsideItem: "Outside item"
        case .lowCapacityFragileDay: "Too much for today"
        case .lowData: "Not enough Time shape yet"
        case .stillBelievable: "Week still looks doable"
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
    case keepTimeUnchanged = "keep_time_unchanged"

    var title: String {
        switch self {
        case .protectOneItem: "Keep this"
        case .shrinkAction: "Make it smaller"
        case .splitAction: "Split it"
        case .moveLocalActionLater: "Adjust shape"
        case .deferGoalOrItem: "Defer this"
        case .dropOptionalWork: "Drop optional work"
        case .parkGoal: "Park goal"
        case .markWaiting: "Mark waiting"
        case .recoverRest: "Recover"
        case .askForConfirmation: "Needs confirmation"
        case .keepTimeUnchanged: "Keep Time unchanged"
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
        case .keepTimeUnchanged: "checkmark.seal"
        }
    }

    var safeAutomationActionKind: SafeAutomationActionKind {
        switch self {
        case .protectOneItem: .changeTimeWindow
        case .shrinkAction: .shrinkAction
        case .splitAction: .splitAction
        case .moveLocalActionLater: .moveActionLater
        case .deferGoalOrItem: .deferAction
        case .dropOptionalWork: .dropAction
        case .parkGoal: .changeTimeWindow
        case .markWaiting: .markWaiting
        case .recoverRest: .noOp
        case .askForConfirmation: .changeTimeWindow
        case .keepTimeUnchanged: .noOp
        }
    }
}

