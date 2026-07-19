import Foundation

struct StageMorphResult: Equatable, Sendable {
    let previousScene: StageScene
    let nextScene: StageScene
    let animationPlan: StageMutationAnimationPlan

    var transition: StageTransitionSpec {
        animationPlan.transition
    }

    var focusPlan: StageFocusPlan {
        animationPlan.focusPlan
    }

    static func initial(scene: StageScene) -> StageMorphResult {
        StageMorphResult(
            previousScene: scene,
            nextScene: scene,
            animationPlan: StageMutationAnimationPlan(
                transition: .idle,
                visibleMutationIDs: [],
                accessibilityAnnouncements: [],
                proofArtifactIDs: [],
                focusPlan: .idle
            )
        )
    }
}

struct StageMorphCoordinator {
    private let animator = StageMutationAnimator()

    func coordinate(
        from previousScene: StageScene,
        to nextScene: StageScene,
        effectRun: StageEffectRun,
        reduceMotionEnabled: Bool = false
    ) -> StageMorphResult {
        StageMorphResult(
            previousScene: previousScene,
            nextScene: nextScene,
            animationPlan: animator.plan(
                from: previousScene,
                to: nextScene,
                effectRun: effectRun,
                reduceMotionEnabled: reduceMotionEnabled
            )
        )
    }
}
