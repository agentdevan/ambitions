import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func reflowBoundary(
        for kind: TimeReflowSuggestionKind,
        calendarAwareness: TimeCalendarAwarenessState
    ) -> TimeReflowBoundaryState {
        switch kind {
        case .protectOneItem, .shrinkAction, .splitAction, .recoverRest, .keepTimeUnchanged:
            return TimeReflowBoundaryState(
                actionKind: kind.safeAutomationActionKind,
                confirmationRequirement: .notRequired,
                undoAvailability: .availableLocal,
                safetyLabel: "Safe/local"
            )
        case .moveLocalActionLater, .deferGoalOrItem, .parkGoal, .markWaiting:
            return TimeReflowBoundaryState(
                actionKind: kind.safeAutomationActionKind,
                confirmationRequirement: .requiredForBroadReflow,
                undoAvailability: .requiresConfirmation,
                safetyLabel: "Confirm first"
            )
        case .dropOptionalWork:
            return TimeReflowBoundaryState(
                actionKind: kind.safeAutomationActionKind,
                confirmationRequirement: .requiredForDestructiveChange,
                undoAvailability: .unsafe,
                safetyLabel: "Confirm drop"
            )
        case .askForConfirmation:
            return TimeReflowBoundaryState(
                actionKind: calendarAwareness.status == .calendarAware ? .writeCalendarBlock : .changeTimeWindow,
                confirmationRequirement: calendarAwareness.status == .calendarAware ? .requiredForExternalEffect : .requiredForBroadReflow,
                undoAvailability: .notSupportedYet,
                safetyLabel: calendarAwareness.status == .calendarAware ? "Time action required" : "Confirm first"
            )
        }
    }

    func gradientDetail(for kind: TimeReflowSuggestionKind) -> String {
        switch kind {
        case .protectOneItem: "Keep one must-do defended."
        case .shrinkAction: "Reduce the ask before moving it."
        case .splitAction: "Carry only the first clear part."
        case .moveLocalActionLater: "Reschedule one local item after confirmation."
        case .deferGoalOrItem: "Leave lower-priority work outside this window."
        case .dropOptionalWork: "Remove optional work only with confirmation."
        case .recoverRest: "Protect rest or recovery as real Time material."
        case .parkGoal: "Pause a goal until there is believable room."
        case .markWaiting: "Name the dependency instead of pushing harder."
        case .askForConfirmation: "Confirm before broad or external effects."
        case .keepTimeUnchanged: "Leave Time as-is."
        }
    }

    func goalShapingItems(summaries: [RepositoryBackedTimeService.GoalWeekSummary]) -> [TimeGoalShapingItem] {
        summaries
            .map { summary in
                let represented = summary.contexts.isEmpty == false
                let nextStep = summary.contexts.first?.step.summary ?? summary.contexts.first?.step.actionability.fallbackMicroStep ?? "Add one believable step."
                let pressureLabel: String
                let attentionReason: String
                let relationship: String
                let visualState: AmbitionVisualState

                if represented == false {
                    pressureLabel = "Carryover"
                    attentionReason = "This goal is active but the current week does not yet give it believable room."
                    relationship = "Still outside the week"
                    visualState = .warning
                } else if summary.frictionCount > 0 {
                    pressureLabel = "Needs lighter ask"
                    attentionReason = "Recent friction suggests the current step is heavier than the week can comfortably carry."
                    relationship = "Visible, but straining"
                    visualState = .warning
                } else if summary.evaluation?.feasibilityLevel == .fragile || summary.evaluation?.feasibilityLevel == .notBelievable {
                    pressureLabel = "Fragile"
                    attentionReason = "The underlying fit evaluation is already warning that this goal is stressing the week."
                    relationship = "Present on protected time"
                    visualState = .warning
                } else if summary.evaluation?.feasibilityLevel == .tight {
                    pressureLabel = "Kept in view"
                    attentionReason = "This goal fits, but only if its current room stays protected."
                    relationship = "Visible and narrow"
                    visualState = .selected
                } else {
                    pressureLabel = "Believable"
                    attentionReason = "This goal has a clear lane in the week and does not currently need heavy intervention."
                    relationship = "Holding cleanly"
                    visualState = .success
                }

                return TimeGoalShapingItem(
                    id: "time-goal-\(summary.goal.id)",
                    target: GoalRouteTarget(goalID: summary.goal.id),
                    goalTitle: summary.goal.title,
                    weekRelationship: relationship,
                    pressureLabel: pressureLabel,
                    attentionReason: attentionReason,
                    nextMoveLabel: nextStep,
                    visualState: visualState
                )
            }
            .sorted { lhs, rhs in
                let leftRank = shapingRank(for: lhs.visualState)
                let rightRank = shapingRank(for: rhs.visualState)
                if leftRank == rightRank {
                    return lhs.goalTitle.localizedCaseInsensitiveCompare(rhs.goalTitle) == .orderedAscending
                }
                return leftRank < rightRank
            }
            .prefix(4)
            .map { $0 }
    }

    func pressuredGoalSummary(from summaries: [RepositoryBackedTimeService.GoalWeekSummary]) -> RepositoryBackedTimeService.GoalWeekSummary? {
        summaries.max { lhs, rhs in
            pressureScore(for: lhs) < pressureScore(for: rhs)
        }
    }

    func goalLifecycleState(goal: Goal, evidence: [ProgressEvidence], now: Date) -> GoalPortfolioLifecycleState {
        switch goal.state {
        case .completed:
            return .completed
        case .archived:
            return goal.plan?.sections.flatMap(\.steps).contains(where: { $0.state == .completed }) == true ? .previous : .cancelledDropped
        case .paused:
            return .parked
        case .draft:
            return .future
        case .active:
            break
        }

        let steps = goal.plan?.sections.flatMap(\.steps) ?? []
        if steps.contains(where: { $0.state == .blocked }) {
            return .blocked
        }
        if hasFutureStart(goal.timing, now: now) {
            return .future
        }
        if goal.mode == .delegatedSupport || goal.relationshipKind == .delegated {
            return .waiting
        }
        if goal.mode == .maintenance || goal.mode == .learning || goal.mode == .exploration {
            if evidence.isEmpty && steps.filter({ $0.state != .completed && $0.state != .cancelled }).count <= 1 {
                return .waiting
            }
        }
        if goal.timing.dueAt != nil || goal.timing.targetBy != nil {
            return .protected
        }
        return .active
    }

    func lifecycleSubtitle(for state: GoalPortfolioLifecycleState, count: Int) -> String {
        if count == 0 {
            switch state {
            case .previous: return "No prior pressure"
            case .active: return "No live load"
            case .future: return "Nothing scheduled later"
            case .waiting: return "No waiting goal"
            case .blocked: return "No blocked goal"
            case .parked: return "Nothing parked"
            case .protected: return "Nothing protected"
            case .completed: return "No completion here"
            case .cancelledDropped: return "No dropped goal"
            case .passive: return "No passive goal"
            }
        }

        switch state {
        case .previous: return "Closed, parked, or transformed"
        case .active: return "Currently shaping attention"
        case .future: return "Planned, not active yet"
        case .waiting: return "Waiting on an answer"
        case .blocked: return "Needs unblock"
        case .parked: return "Intentionally outside pressure"
        case .protected: return "Should be defended"
        case .completed: return "Done and preserved"
        case .cancelledDropped: return "Dropped without shame"
        case .passive: return "Quiet support"
        }
    }

    func hasFutureStart(_ timing: GoalTiming, now: Date) -> Bool {
        guard let startsOn = timing.startsOn, let date = parseDate(startsOn) else {
            return false
        }
        return date > now
    }

}
