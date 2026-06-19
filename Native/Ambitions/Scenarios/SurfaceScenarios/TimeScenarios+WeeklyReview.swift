import AmbitionsDesignSystem
import Foundation

extension PreviewTimeScenarios {
    static let weeklyReview = TimeWeeklyReviewState(
        timeframeLabel: "Apr 20-Apr 26",
        hero: WeeklyReviewHeroState(
            eyebrow: "Weekly Review",
            title: "Shape what carries forward",
            subtitle: "Weekly review now continues the same authored week workspace instead of becoming a detached ritual.",
            dominantTruth: "Lighten Tuesday first, then carry forward only the steps the next week can still explain.",
            continuityLabel: "Return to the week with a calmer shape, not a larger list.",
            contextPills: [
                TimeHeroPillState(title: "Apr 20-Apr 26", icon: "calendar", state: .default),
                TimeHeroPillState(title: "Tight", icon: AppTab.time.systemImage, state: .selected),
                TimeHeroPillState(title: "3 carry-forward lanes", icon: "arrow.triangle.branch", state: .selected)
            ]
        ),
        summaryTitle: "Why the next week should look different",
        summaryDetail: "Carryover, capture pressure, and overloaded days need gentler scope before the next week hardens.",
        carryForwardItems: [
            WeeklyReviewCarryForwardItem(id: "review-preview-retention", title: "Retention loop", detail: "Still active, but the current week never gave it a believable lane.", bridgeLabel: "Carry forward carefully", state: .warning, goalTarget: GoalRouteTarget(goalID: "preview-goal-2")),
            WeeklyReviewCarryForwardItem(id: "review-preview-shell", title: "Ship the native shell", detail: "The next week should carry a lighter version so recovery stays believable.", bridgeLabel: "Lighten before it rolls forward", state: .selected, goalTarget: GoalRouteTarget(goalID: "preview-goal-1")),
            WeeklyReviewCarryForwardItem(id: "review-preview-captures", title: "Capture pressure", detail: "2 captures still need a calm decision before they become next-week clutter.", bridgeLabel: "Clear the inbox inside Time", state: .warning, goalTarget: nil)
        ],
        captureSummary: "2 captures still need to be absorbed, attached, or intentionally parked.",
        habitSummary: "1 routine should support the next week without crowding it.",
        returnActionTitle: "Return to Time",
        returnActionSubtitle: "Use the reshaped week, then adjust one goal or support route only if it still needs help.",
        returnTimeRoute: nil,
        splitPaneContext: TimeWindowMagnetismState(
            title: "Window magnetism",
            detail: "Wednesday remains the cleanest place for the next calmer step to dock.",
            dayLabel: "Wed 22",
            suggestionTitle: "Retention loop",
            suggestionDetail: "One believable step still fits without turning the next week dense.",
            target: GoalRouteTarget(goalID: "preview-goal-2"),
            visualState: .success
        )
    )
}
