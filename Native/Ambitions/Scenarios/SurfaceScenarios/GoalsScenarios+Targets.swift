import AmbitionsDesignSystem
import Foundation

extension PreviewGoalsScenarios {
    static let activeTarget = GoalRouteTarget(goalID: "goal-native", draftID: "draft-native")
    static let starterTarget = GoalRouteTarget(goalID: "goal-learning", draftID: "draft-learning")
    static let clarificationTarget = GoalRouteTarget(draftID: "draft-clarify")
    static let blockedTarget = GoalRouteTarget(draftID: "draft-blocked", launchContext: .help)
    static let supportTarget = GoalRouteTarget(goalID: "goal-support", draftID: "draft-support")
    static let completedTarget = GoalRouteTarget(goalID: "goal-detail-completed")
    static let parkedTarget = GoalRouteTarget(goalID: "goal-detail-parked")
    static let cancelledTarget = GoalRouteTarget(goalID: "goal-detail-cancelled")

    static let previewMaturitySummary = GoalPortfolioMaturitySummary(
        title: "Portfolio maturity",
        subtitle: "A qualitative read on scope, proof, stuck work, and what should happen next.",
        scopeSignal: GoalPortfolioMaturitySignal(id: "scope", title: "Scope needs review", detail: "4 live ambitions are active; choose what should stay protected.", state: .warning),
        stuckWorkSignal: GoalPortfolioMaturitySignal(id: "stuck-work", title: "Stuck work is visible", detail: "1 waiting or blocked · 2 crowded or stalled", state: .warning),
        proofSignal: GoalPortfolioMaturitySignal(id: "proof", title: "Proof is thin", detail: "2 live ambitions need a proof point before momentum is easy to trust.", state: .default),
        nextStepSignal: GoalPortfolioMaturitySignal(id: "next-step", title: "Next steps are clear", detail: "Every live ambition has a current next visible step.", state: .selected),
        archiveLearning: [
            "Finish launch checklist: completed with proof visible.",
            "Park the old weekly board: parked so attention can stay honest."
        ],
        accessibilityLabel: "Portfolio maturity",
        accessibilityValue: "Scope needs review. Stuck work is visible. Proof is thin. Next steps are clear.",
        accessibilityHint: "Review scope, stuck work, proof, and next-step clarity before adding more goals."
    )
}
