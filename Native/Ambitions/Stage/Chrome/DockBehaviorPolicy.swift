import CoreGraphics
import Foundation

enum DockBehaviorPolicy {
    static func showsRootDock(
        routeDepth: StageRouteDepth,
        overlayPresentation: StageOverlayPresentation
    ) -> Bool {
        routeDepth == .root && overlayPresentation == .none
    }

    static func showsDockBackdrop(
        routeDepth: StageRouteDepth,
        overlayPresentation: StageOverlayPresentation
    ) -> Bool {
        false
    }

    static func dockClearance(dynamicTypeIsAccessibilitySize: Bool) -> CGFloat {
        dynamicTypeIsAccessibilitySize ? 156 : 148
    }
}
