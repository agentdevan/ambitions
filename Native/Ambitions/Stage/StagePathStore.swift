import CoreGraphics
import Foundation

enum StageRouteDepth: String, Equatable {
    case root
    case drilldown
}

enum StageOverlayPresentation: String, Equatable {
    case none
    case sheet
    case activatedCaptureComposer
    case memoryLens
    case createGoal
}

struct StageChromePolicy: Equatable {
    let routeDepth: StageRouteDepth
    let overlayPresentation: StageOverlayPresentation
    let dynamicTypeIsAccessibilitySize: Bool
    let showsRootDock: Bool
    let showsDockBackdrop: Bool
    let dockClearance: CGFloat
    let dockBackdropHeight: CGFloat
    let stageContentBottomClearance: CGFloat
    let captureComposerClearance: CGFloat
    let continuityReceiptBottomClearance: CGFloat
}

enum StagePathStore {
    static func routeDepth(
        goalsPath: [GoalRouteTarget],
        timePath: [TimeRouteTarget],
        youPath: [YouRouteTarget]
    ) -> StageRouteDepth {
        goalsPath.isEmpty && timePath.isEmpty && youPath.isEmpty ? .root : .drilldown
    }

    static func overlayPresentation(for overlay: ShellOverlayState?) -> StageOverlayPresentation {
        guard let overlay else { return .none }

        if overlay.isActivatedCaptureComposer {
            return .activatedCaptureComposer
        }

        switch overlay.kind {
        case .quietCommandSheet:
            return .sheet
        case .memoryLens:
            return .memoryLens
        case .createGoal:
            return .createGoal
        }
    }

    static func chromePolicy(
        routeDepth: StageRouteDepth,
        overlayPresentation: StageOverlayPresentation,
        dynamicTypeIsAccessibilitySize: Bool
    ) -> StageChromePolicy {
        let showsRootDock = rootDockIsVisible(
            routeDepth: routeDepth,
            overlayPresentation: overlayPresentation
        )
        let dockClearance: CGFloat = dynamicTypeIsAccessibilitySize ? 184 : 164
        let nonDockCaptureClearance: CGFloat = dynamicTypeIsAccessibilitySize ? 36 : 18
        let nonDockReceiptClearance: CGFloat = dynamicTypeIsAccessibilitySize ? 40 : 24
        let backdropExtra: CGFloat = dynamicTypeIsAccessibilitySize ? 48 : 72

        return StageChromePolicy(
            routeDepth: routeDepth,
            overlayPresentation: overlayPresentation,
            dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize,
            showsRootDock: showsRootDock,
            showsDockBackdrop: showsRootDock,
            dockClearance: dockClearance,
            dockBackdropHeight: dockClearance + backdropExtra,
            stageContentBottomClearance: showsRootDock ? dockClearance : 0,
            captureComposerClearance: showsRootDock ? dockClearance : nonDockCaptureClearance,
            continuityReceiptBottomClearance: showsRootDock ? dockClearance : nonDockReceiptClearance
        )
    }

    static func chromePolicy(
        goalsPath: [GoalRouteTarget],
        timePath: [TimeRouteTarget],
        youPath: [YouRouteTarget],
        activeOverlay: ShellOverlayState?,
        dynamicTypeIsAccessibilitySize: Bool
    ) -> StageChromePolicy {
        chromePolicy(
            routeDepth: routeDepth(goalsPath: goalsPath, timePath: timePath, youPath: youPath),
            overlayPresentation: overlayPresentation(for: activeOverlay),
            dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize
        )
    }

    static func rootDockIsVisible(
        routeDepth: StageRouteDepth,
        overlayPresentation: StageOverlayPresentation
    ) -> Bool {
        routeDepth == .root && overlayPresentation != .activatedCaptureComposer
    }
}
