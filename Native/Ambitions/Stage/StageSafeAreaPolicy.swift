import CoreGraphics
import Foundation

enum StageSafeAreaPolicy {
    static func topInsetSpacing(hasBackButton: Bool, dynamicTypeIsAccessibilitySize: Bool) -> CGFloat {
        if hasBackButton {
            return 0
        }
        return dynamicTypeIsAccessibilitySize ? 12 : 8
    }

    static func topContentClearance(
        reservesPrimaryObjectTopClearance: Bool,
        dynamicTypeIsAccessibilitySize: Bool
    ) -> CGFloat {
        guard reservesPrimaryObjectTopClearance else { return 0 }
        return dynamicTypeIsAccessibilitySize ? 132 : 92
    }

    static func stageContentBottomClearance(
        routeDepth: StageRouteDepth,
        overlayPresentation: StageOverlayPresentation,
        dynamicTypeIsAccessibilitySize: Bool
    ) -> CGFloat {
        DockBehaviorPolicy.showsRootDock(routeDepth: routeDepth, overlayPresentation: overlayPresentation)
            ? DockBehaviorPolicy.dockClearance(dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize)
            : 0
    }

    static func captureComposerBottomClearance(
        routeDepth: StageRouteDepth,
        overlayPresentation: StageOverlayPresentation,
        dynamicTypeIsAccessibilitySize: Bool
    ) -> CGFloat {
        if DockBehaviorPolicy.showsRootDock(routeDepth: routeDepth, overlayPresentation: overlayPresentation) {
            return DockBehaviorPolicy.dockClearance(dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize)
        }
        return dynamicTypeIsAccessibilitySize ? 36 : 18
    }

    static func continuityReceiptBottomClearance(
        routeDepth: StageRouteDepth,
        overlayPresentation: StageOverlayPresentation,
        dynamicTypeIsAccessibilitySize: Bool
    ) -> CGFloat {
        if DockBehaviorPolicy.showsRootDock(routeDepth: routeDepth, overlayPresentation: overlayPresentation) {
            return DockBehaviorPolicy.dockClearance(dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize)
        }
        return dynamicTypeIsAccessibilitySize ? 40 : 24
    }

    static func drilldownBottomClearance(dynamicTypeIsAccessibilitySize: Bool) -> CGFloat {
        dynamicTypeIsAccessibilitySize ? 64 : 34
    }

    static func rootSurfaceContentBottomInset(dynamicTypeIsAccessibilitySize: Bool) -> CGFloat {
        stageContentBottomClearance(
            routeDepth: .root,
            overlayPresentation: .none,
            dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize
        ) + (dynamicTypeIsAccessibilitySize ? 28 : 20)
    }
}
