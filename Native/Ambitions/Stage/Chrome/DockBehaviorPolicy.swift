import CoreGraphics
import Foundation

enum DockBehaviorPolicy {
    static func showsRootDock(
        routeDepth: StageRouteDepth,
        overlayPresentation: StageOverlayPresentation
    ) -> Bool {
        routeDepth == .root && overlayPresentation != .activatedCaptureComposer
    }

    static func showsDockBackdrop(
        routeDepth: StageRouteDepth,
        overlayPresentation: StageOverlayPresentation
    ) -> Bool {
        showsRootDock(routeDepth: routeDepth, overlayPresentation: overlayPresentation)
    }

    static func dockClearance(dynamicTypeIsAccessibilitySize: Bool) -> CGFloat {
        dynamicTypeIsAccessibilitySize ? 184 : 164
    }
}
