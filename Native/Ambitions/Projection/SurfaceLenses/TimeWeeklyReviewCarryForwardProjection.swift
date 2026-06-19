import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func makeWeeklyReviewCarryForwardItems(
        summaries: [RepositoryBackedTimeService.GoalWeekSummary],
        missingGoalSummaries: [RepositoryBackedTimeService.GoalWeekSummary],
        pressuredGoalSummary: RepositoryBackedTimeService.GoalWeekSummary?,
        openCaptureCount: Int
    ) -> [WeeklyReviewCarryForwardItem] {
        let carryoverItems = missingGoalSummaries.prefix(2).map { summary in
            WeeklyReviewCarryForwardItem(
                id: "weekly-review-carry-\(summary.goal.id)",
                title: summary.goal.title,
                detail: "Still active, but the current week never gave it a believable lane.",
                bridgeLabel: "Carry forward carefully",
                state: .warning,
                goalTarget: GoalRouteTarget(goalID: summary.goal.id)
            )
        }
        let strainedItem = pressuredGoalSummary.map { summary in
            WeeklyReviewCarryForwardItem(
                id: "weekly-review-strain-\(summary.goal.id)",
                title: summary.goal.title,
                detail: "The next week should carry a lighter version so recovery stays believable.",
                bridgeLabel: "Lighten before it rolls forward",
                state: .selected,
                goalTarget: GoalRouteTarget(goalID: summary.goal.id)
            )
        }
        let captureItem: WeeklyReviewCarryForwardItem? = openCaptureCount > 0 ? WeeklyReviewCarryForwardItem(
            id: "weekly-review-captures",
            title: "Capture pressure",
            detail: "\(openCaptureCount) capture\(openCaptureCount == 1 ? "" : "s") still need a decision before they become next-week clutter.",
            bridgeLabel: "Open Capture composer",
            state: .warning,
            goalTarget: nil
        ) : nil

        return Array((carryoverItems + [strainedItem, captureItem].compactMap { $0 }).prefix(4))
    }

}
