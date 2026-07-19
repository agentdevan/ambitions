import Foundation

enum StageFocusRestorationTarget: Equatable, Sendable {
    case none
    case rootObject(AmbitionsSurface)
    case rootDock(AmbitionsSurface)
    case drilldownBackButton(AmbitionsSurface)
    case overlay(String)

    var proofID: String {
        switch self {
        case .none:
            "stage.focus.none"
        case let .rootObject(surface):
            "stage.focus.\(surface.rawValue).root-object"
        case let .rootDock(surface):
            "stage.focus.\(surface.rawValue).root-dock"
        case let .drilldownBackButton(surface):
            "stage.focus.\(surface.rawValue).drilldown-back"
        case let .overlay(id):
            "stage.focus.overlay.\(id)"
        }
    }
}

struct StageFocusPlan: Equatable, Sendable {
    let target: StageFocusRestorationTarget
    let accessibilityAnnouncement: String?
    let proofArtifactID: String

    static let idle = StageFocusPlan(
        target: .none,
        accessibilityAnnouncement: nil,
        proofArtifactID: StageFocusRestorationTarget.none.proofID
    )
}

struct StageFocusCoordinator {
    func plan(
        from previousScene: StageScene,
        to nextScene: StageScene,
        transition: StageTransitionSpec,
        effectRun: StageEffectRun
    ) -> StageFocusPlan {
        let target = focusTarget(
            from: previousScene,
            to: nextScene,
            transition: transition
        )
        return StageFocusPlan(
            target: target,
            accessibilityAnnouncement: effectRun.accessibilityAnnouncements.first ?? transition.accessibilityDescription,
            proofArtifactID: target.proofID
        )
    }

    private func focusTarget(
        from previousScene: StageScene,
        to nextScene: StageScene,
        transition: StageTransitionSpec
    ) -> StageFocusRestorationTarget {
        guard transition.kind != .none else { return .none }

        if nextScene.overlay.presentation != .none {
            return .overlay(nextScene.overlay.activeState?.kind.id ?? nextScene.overlay.presentation.rawValue)
        }
        if previousScene.overlay.presentation != .none && nextScene.overlay.presentation == .none {
            return targetForVisibleScene(nextScene)
        }
        if nextScene.routeDepth == .drilldown {
            return .drilldownBackButton(nextScene.surface)
        }
        if transition.kind == .visibleMutation && nextScene.rootDockIsAllowed {
            return .rootDock(nextScene.surface)
        }
        return .rootObject(nextScene.surface)
    }

    private func targetForVisibleScene(_ scene: StageScene) -> StageFocusRestorationTarget {
        scene.routeDepth == .drilldown ? .drilldownBackButton(scene.surface) : .rootObject(scene.surface)
    }
}
