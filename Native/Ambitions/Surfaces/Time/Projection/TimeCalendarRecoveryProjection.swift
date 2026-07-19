import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func makeCalendarBoundaryContract(_ calendarAwareness: TimeCalendarAwarenessState) -> TimeCalendarBoundaryContractState {
        TimeCalendarBoundaryContractState(
            title: "Calendar stays optional",
            detail: calendarAwareness.detail,
            permissionLabel: calendarAwareness.valueLabel,
            sourceLabel: calendarAwareness.sourceLabel,
            manualFallback: calendarAwareness.status == .calendarAware
                ? "Time can use derived busy time after your action."
                : "Manual shaping still works without calendar access.",
            writeBoundary: calendarAwareness.status == .baseline
                ? "Time writes or reschedules calendar blocks only after explicit confirmation."
                : "Time never silently writes or reschedules calendar blocks.",
            visualState: calendarAwareness.visualState,
            canRequestCalendarRead: calendarAwareness.canRequestCalendarRead
        )
    }

    func makeRecoveryEntry(
        weekDays: [TimeElasticWeekDayState],
        missingGoalSummaries: [RepositoryBackedTimeService.GoalWeekSummary],
        openCaptures: [Capture],
        pressuredGoalSummary: RepositoryBackedTimeService.GoalWeekSummary?
    ) -> TimeRecoveryEntryState {
        let overloaded = weekDays.contains(where: { $0.level == .overloaded || $0.level == .fragile })
        var suggestions: [TimeDecisionItemState] = []

        if overloaded, let pressuredGoalSummary {
            suggestions.append(TimeDecisionItemState(
                id: "recovery-shrink-\(pressuredGoalSummary.goal.id)",
                title: "Shrink one step",
                detail: "\(pressuredGoalSummary.goal.title) is the clearest place to reduce pressure.",
                suggestion: "Make the next step smaller before moving anything else.",
                visualState: .warning,
                target: GoalRouteTarget(goalID: pressuredGoalSummary.goal.id),
                timeRoute: nil
            ))
        }

        if let missing = missingGoalSummaries.first {
            suggestions.append(TimeDecisionItemState(
                id: "recovery-defer-\(missing.goal.id)",
                title: "Defer what has no room",
                detail: "\(missing.goal.title) is active but outside the current week.",
                suggestion: "Leave it not today unless a real open window appears.",
                visualState: .default,
                target: GoalRouteTarget(goalID: missing.goal.id),
                timeRoute: nil
            ))
        }

        if openCaptures.isEmpty == false {
            suggestions.append(TimeDecisionItemState(
                id: "recovery-held-input",
                title: "Park capture pressure",
                detail: "\(openCaptures.count) capture\(openCaptures.count == 1 ? "" : "s") can wait outside Time.",
                suggestion: "Attach, park, or archive only after opening Capture.",
                visualState: .warning,
                target: nil,
                timeRoute: nil,
                interactionIntent: .openGlobalCapture
            ))
        }

        if suggestions.isEmpty {
            suggestions.append(TimeDecisionItemState(
                id: "recovery-protect-room",
                title: "Protect recovery room",
                detail: "The safest choice is keeping an open pocket unfilled.",
                suggestion: "Recovery room is part of Time, not a failure to optimize.",
                visualState: .success,
                target: nil,
                timeRoute: nil
            ))
        }

        return TimeRecoveryEntryState(
            title: "Recovery room",
            detail: "Save the Day stays suggestion-only here. Wide Time changes wait for confirmed recovery tools.",
            suggestions: Array(suggestions.prefix(3)),
            boundary: "No schedule changes happen from this card."
        )
    }

}
