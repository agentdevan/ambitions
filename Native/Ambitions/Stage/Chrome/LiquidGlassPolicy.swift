import CoreGraphics
import Foundation

enum LiquidGlassPolicy {
    static func dockBackdropHeight(dynamicTypeIsAccessibilitySize: Bool) -> CGFloat {
        DockBehaviorPolicy.dockClearance(dynamicTypeIsAccessibilitySize: dynamicTypeIsAccessibilitySize)
            + (dynamicTypeIsAccessibilitySize ? 48 : 72)
    }

    static func permitsTransparentChrome(reduceTransparencyEnabled: Bool) -> Bool {
        reduceTransparencyEnabled == false
    }
}
