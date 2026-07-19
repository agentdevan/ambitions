import Foundation

struct StageMutationAnimationPlan: Equatable, Sendable {
    let transition: StageTransitionSpec
    let visibleMutationIDs: [String]
    let accessibilityAnnouncements: [String]
    let proofArtifactIDs: [String]
    let focusPlan: StageFocusPlan

    var provesActionFlow: Bool {
        visibleMutationIDs.isEmpty == false &&
            accessibilityAnnouncements.isEmpty == false &&
            proofArtifactIDs.isEmpty == false &&
            focusPlan.target != .none
    }
}

struct StageMutationAnimator {
    private let focusCoordinator = StageFocusCoordinator()

    func plan(
        from previousScene: StageScene,
        to nextScene: StageScene,
        effectRun: StageEffectRun,
        reduceMotionEnabled: Bool
    ) -> StageMutationAnimationPlan {
        let transition = StageTransitionSpec.resolve(
            from: previousScene,
            to: nextScene,
            effectRun: effectRun,
            reduceMotionEnabled: reduceMotionEnabled
        )
        let focusPlan = focusCoordinator.plan(
            from: previousScene,
            to: nextScene,
            transition: transition,
            effectRun: effectRun
        )
        return StageMutationAnimationPlan(
            transition: transition,
            visibleMutationIDs: effectRun.visibleMutationIDs,
            accessibilityAnnouncements: effectRun.accessibilityAnnouncements,
            proofArtifactIDs: effectRun.proofArtifactIDs,
            focusPlan: focusPlan
        )
    }
}
