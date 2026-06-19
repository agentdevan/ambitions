import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func makeExecutionResilience(
        posture: TimeBelievabilityState,
        weekDays: [TimeElasticWeekDayState],
        missingGoalSummaries: [RepositoryBackedTimeService.GoalWeekSummary],
        pressuredGoalSummary: RepositoryBackedTimeService.GoalWeekSummary?,
        habitGoals: [Goal],
        openCaptures: [Capture]
    ) -> TimeExecutionResilienceState {
        let overloadedDays = weekDays.filter { $0.level == .overloaded }.count
        let laneState: AmbitionVisualState = overloadedDays > 0 || missingGoalSummaries.isEmpty == false || openCaptures.isEmpty == false
            ? .warning
            : posture.visualState

        return TimeExecutionResilienceState(
            title: "Execution resilience",
            subtitle: "Carryover, overload, and recovery shaping stay explainable by keeping one smaller lane obvious at a time.",
            calmExplanation: missingGoalSummaries.isEmpty
                ? "This week holds together best when open room stays visible and only the loudest pressure gets reshaped."
                : "\(missingGoalSummaries.count) active goal\(missingGoalSummaries.count == 1 ? "" : "s") still need a believable carryover lane instead of diffuse pressure.",
            focusProtection: overloadedDays > 0
                ? "Protect the clearest focus window before moving anything else. Relief works better than adding another organizing layer."
                : "Focus windows already exist in the week. Protect them before turning rituals or captures into extra structure.",
            tradeoffFraming: openCaptures.isEmpty
                ? "Every new ask should either reuse visible room or trade off against the loudest loaded day."
                : "Open captures should compete with the week honestly. Absorb them, park them, or let them wait.",
            lanes: [
                TimeExecutionResilienceLane(
                    id: "carryover",
                    title: "Carryover",
                    detail: missingGoalSummaries.isEmpty
                        ? "No active goal is currently floating outside the week."
                        : "Resolve carryover by giving only the missing goal a believable lane instead of widening the whole week.",
                    recommendation: missingGoalSummaries.first.map { "\($0.goal.title) is the cleanest carry-forward candidate." } ?? "Carry only what the next week can explain calmly.",
                    state: missingGoalSummaries.isEmpty ? .success : .warning,
                    goalTarget: missingGoalSummaries.first.map { GoalRouteTarget(goalID: $0.goal.id) },
                    timeRoute: nil
                ),
                TimeExecutionResilienceLane(
                    id: "overload",
                    title: "Overload",
                    detail: overloadedDays == 0
                        ? "No day is visibly overloaded right now."
                        : "\(overloadedDays) day\(overloadedDays == 1 ? "" : "s") are carrying more than the week can explain without relief.",
                    recommendation: pressuredGoalSummary.map { "Lighten \($0.goal.title) before adding anything new." } ?? "Lighten the loudest lane first.",
                    state: overloadedDays == 0 ? .selected : .warning,
                    goalTarget: pressuredGoalSummary.map { GoalRouteTarget(goalID: $0.goal.id) },
                    timeRoute: nil
                ),
                TimeExecutionResilienceLane(
                    id: "rituals",
                    title: "Rituals",
                    detail: habitGoals.isEmpty
                        ? "No recurring loop is currently shaping the week."
                        : "\(habitGoals.count) routine\(habitGoals.count == 1 ? "" : "s") should support the week shape instead of competing with it.",
                    recommendation: habitGoals.isEmpty
                        ? "Keep the week dominant until a repeatable loop is truly needed."
                        : "Use the routines route to soften or trim loops that are crowding the week.",
                    state: habitGoals.isEmpty ? .default : .selected,
                    goalTarget: nil,
                    timeRoute: .rituals
                ),
                TimeExecutionResilienceLane(
                    id: "held-input",
                    title: "Capture",
                    detail: openCaptures.isEmpty
                        ? "No open captures are pushing on this week."
                        : "\(openCaptures.count) open capture\(openCaptures.count == 1 ? "" : "s") still need to be absorbed or parked.",
                    recommendation: openCaptures.isEmpty
                        ? "Let the week stay quiet."
                        : "Attach or park capture pressure before trying to polish the schedule.",
                    state: openCaptures.isEmpty ? .default : .warning,
                    goalTarget: nil,
                    timeRoute: nil,
                    interactionIntent: .openGlobalCapture
                ),
                TimeExecutionResilienceLane(
                    id: "review",
                    title: "Weekly review",
                    detail: "Use review as a shaping continuation so next week inherits the right amount of carry-forward truth.",
                    recommendation: "Close the week by shaping what should continue, not by creating more cleanup.",
                    state: laneState,
                    goalTarget: nil,
                    timeRoute: .weeklyReview
                )
            ],
            windowMagnetism: makeWindowMagnetism(
                weekDays: weekDays,
                missingGoalSummaries: missingGoalSummaries,
                pressuredGoalSummary: pressuredGoalSummary
            )
        )
    }

    func makeWindowMagnetism(
        weekDays: [TimeElasticWeekDayState],
        missingGoalSummaries: [RepositoryBackedTimeService.GoalWeekSummary],
        pressuredGoalSummary: RepositoryBackedTimeService.GoalWeekSummary?
    ) -> TimeWindowMagnetismState? {
        guard let candidateDay = weekDays.first(where: { $0.level == .open && $0.openWindow?.target != nil }) ??
                weekDays.first(where: { $0.level == .steady && $0.openWindow?.target != nil }),
              let openWindow = candidateDay.openWindow else {
            return nil
        }

        let suggestedGoalTitle = openWindow.suggestionLabel ?? missingGoalSummaries.first?.goal.title ?? pressuredGoalSummary?.goal.title ?? "the next lighter step"

        return TimeWindowMagnetismState(
            title: "Window magnetism",
            detail: "When the week has one believable opening, suggestions should dock there calmly instead of making the whole schedule feel reactive.",
            dayLabel: "\(candidateDay.weekdayLabel) \(candidateDay.dateLabel)",
            suggestionTitle: suggestedGoalTitle,
            suggestionDetail: openWindow.detail,
            target: openWindow.target,
            visualState: openWindow.visualState
        )
    }

}
