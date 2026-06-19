import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func makeShapingActions(
        summaries: [RepositoryBackedTimeService.GoalWeekSummary],
        missingGoalSummaries: [RepositoryBackedTimeService.GoalWeekSummary],
        pressuredGoalSummary: RepositoryBackedTimeService.GoalWeekSummary?,
        openCaptureCount: Int,
        weekDays: [TimeElasticWeekDayState]
    ) -> [TimeShapingActionState] {
        let firstVisibleBlock = weekDays.flatMap(\.blocks).first
        let firstOpenWindow = weekDays.compactMap(\.openWindow).first(where: { $0.target != nil })
        let noisyDay = weekDays.first(where: { $0.level == .overloaded }) ?? weekDays.first(where: { $0.level == .tight })
        let missingGoalTarget = missingGoalSummaries.first.map { GoalRouteTarget(goalID: $0.goal.id) }
        let pressuredTarget = pressuredGoalSummary.map { GoalRouteTarget(goalID: $0.goal.id) }

        return [
            TimeShapingActionState(
                kind: .edit,
                title: "Edit",
                subtitle: firstVisibleBlock?.title ?? "Edit the week at the block level.",
                recommendation: firstVisibleBlock == nil
                    ? "No dated block is visible yet, so there is nothing to edit directly."
                    : "Start with the clearest existing block instead of redrawing the whole week.",
                systemImage: TimeShapingActionKind.edit.systemImage,
                state: firstVisibleBlock == nil ? .default : .selected,
                goalTarget: firstVisibleBlock?.target,
                timeRoute: nil
            ),
            TimeShapingActionState(
                kind: .patch,
                title: "Patch",
                subtitle: missingGoalSummaries.isEmpty
                    ? "Patch the week without changing its calm shape."
                    : "Give missing goals one believable lane instead of spreading them everywhere.",
                recommendation: missingGoalSummaries.isEmpty
                    ? "Use the cleanest open window or the weakest day and make one small adjustment."
                    : "Patch missing work into the week only where room is actually visible.",
                systemImage: TimeShapingActionKind.patch.systemImage,
                state: missingGoalSummaries.isEmpty ? .selected : .warning,
                goalTarget: missingGoalTarget ?? firstOpenWindow?.target,
                timeRoute: nil
            ),
            TimeShapingActionState(
                kind: .protect,
                title: "Protect",
                subtitle: firstOpenWindow?.title ?? "Protect the parts of the week that already feel believable.",
                recommendation: firstOpenWindow?.suggestionLabel == nil
                    ? "The best protection may be leaving one pocket unfilled."
                    : "Protect the calmest pocket before pressure spills into it.",
                systemImage: TimeShapingActionKind.protect.systemImage,
                state: firstOpenWindow == nil ? .default : .success,
                goalTarget: firstOpenWindow?.target ?? firstVisibleBlock?.target ?? pressuredTarget,
                timeRoute: nil
            ),
            TimeShapingActionState(
                kind: .lighten,
                title: "Lighten",
                subtitle: noisyDay?.highlight ?? "Lighten the loudest part of the week first.",
                recommendation: openCaptureCount > 0
                    ? "Reduce speculative load before trying to force more commitment into the week."
                    : "Shrink or reschedule the heaviest ask before the week starts feeling performative.",
                systemImage: TimeShapingActionKind.lighten.systemImage,
                state: noisyDay == nil ? .default : .warning,
                goalTarget: openCaptureCount > 0 ? nil : pressuredTarget,
                timeRoute: nil,
                interactionIntent: openCaptureCount > 0 ? .openGlobalCapture : nil
            )
        ]
    }

}
