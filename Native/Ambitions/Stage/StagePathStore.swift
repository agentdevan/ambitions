import CoreGraphics
import Foundation

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
        StageChromePolicy(
            routeDepth: routeDepth,
            overlayPresentation: overlayPresentation,
            dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize,
            showsRootDock: DockBehaviorPolicy.showsRootDock(
                routeDepth: routeDepth,
                overlayPresentation: overlayPresentation
            ),
            showsDockBackdrop: DockBehaviorPolicy.showsDockBackdrop(
                routeDepth: routeDepth,
                overlayPresentation: overlayPresentation
            ),
            dockClearance: DockBehaviorPolicy.dockClearance(dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize),
            dockBackdropHeight: LiquidGlassPolicy.dockBackdropHeight(dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize),
            stageContentBottomClearance: StageSafeAreaPolicy.stageContentBottomClearance(
                routeDepth: routeDepth,
                overlayPresentation: overlayPresentation,
                dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize
            ),
            captureComposerClearance: StageSafeAreaPolicy.captureComposerBottomClearance(
                routeDepth: routeDepth,
                overlayPresentation: overlayPresentation,
                dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize
            ),
            continuityReceiptBottomClearance: StageSafeAreaPolicy.continuityReceiptBottomClearance(
                routeDepth: routeDepth,
                overlayPresentation: overlayPresentation,
                dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize
            )
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
        DockBehaviorPolicy.showsRootDock(routeDepth: routeDepth, overlayPresentation: overlayPresentation)
    }
}
