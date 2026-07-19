import Foundation

enum StageTransitionKind: String, Equatable, Sendable {
    case none
    case surfaceMorph
    case drilldownPush
    case rootReturn
    case overlayPresentation
    case overlayDismissal
    case overlayReplacement
    case visibleMutation
}

enum StageTransitionMotion: String, Equatable, Sendable {
    case objectContinuity
    case restrainedCrossfade
    case noMotion
}

struct StageTransitionSpec: Equatable, Sendable {
    let id: String
    let kind: StageTransitionKind
    let motion: StageTransitionMotion
    let animated: Bool
    let accessibilityDescription: String

    static let idle = StageTransitionSpec(
        id: "stage.transition.idle",
        kind: .none,
        motion: .noMotion,
        animated: false,
        accessibilityDescription: "Stage is stable."
    )

    static func resolve(
        from previousScene: StageScene,
        to nextScene: StageScene,
        effectRun: StageEffectRun,
        reduceMotionEnabled: Bool
    ) -> StageTransitionSpec {
        let kind = transitionKind(
            from: previousScene,
            to: nextScene,
            effectRun: effectRun
        )
        guard kind != .none else { return .idle }

        let motion: StageTransitionMotion = reduceMotionEnabled ? .restrainedCrossfade : defaultMotion(for: kind)
        return StageTransitionSpec(
            id: "stage.transition.\(kind.rawValue)",
            kind: kind,
            motion: motion,
            animated: reduceMotionEnabled == false,
            accessibilityDescription: accessibilityDescription(for: kind, nextScene: nextScene)
        )
    }

    private static func transitionKind(
        from previousScene: StageScene,
        to nextScene: StageScene,
        effectRun: StageEffectRun
    ) -> StageTransitionKind {
        if previousScene.overlay.presentation != nextScene.overlay.presentation {
            if previousScene.overlay.presentation == .none {
                return .overlayPresentation
            }
            if nextScene.overlay.presentation == .none {
                return .overlayDismissal
            }
            return .overlayReplacement
        }
        if previousScene.routeDepth == .root && nextScene.routeDepth == .drilldown {
            return .drilldownPush
        }
        if previousScene.routeDepth == .drilldown && nextScene.routeDepth == .root {
            return .rootReturn
        }
        if previousScene.surface != nextScene.surface {
            return .surfaceMorph
        }
        if effectRun.visibleMutationIDs.isEmpty == false {
            return .visibleMutation
        }
        return .none
    }

    private static func defaultMotion(for kind: StageTransitionKind) -> StageTransitionMotion {
        switch kind {
        case .surfaceMorph, .drilldownPush, .rootReturn:
            .objectContinuity
        case .overlayPresentation, .overlayDismissal, .overlayReplacement, .visibleMutation:
            .restrainedCrossfade
        case .none:
            .noMotion
        }
    }

    private static func accessibilityDescription(
        for kind: StageTransitionKind,
        nextScene: StageScene
    ) -> String {
        switch kind {
        case .none:
            "Stage is stable."
        case .surfaceMorph:
            "\(nextScene.surface.title) selected."
        case .drilldownPush:
            "\(nextScene.surface.title) detail opened."
        case .rootReturn:
            "\(nextScene.surface.title) root restored."
        case .overlayPresentation:
            "Overlay opened."
        case .overlayDismissal:
            "Overlay dismissed."
        case .overlayReplacement:
            "Overlay changed."
        case .visibleMutation:
            "\(nextScene.surface.title) updated."
        }
    }
}
