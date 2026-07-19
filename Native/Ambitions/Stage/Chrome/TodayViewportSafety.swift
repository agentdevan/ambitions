import CoreGraphics
import SwiftUI

struct TodayViewportSafety: Equatable, Sendable {
    let topChromeClearance: CGFloat
    let rootBottomChromeClearance: CGFloat
    let railBottomContentClearance: CGFloat
    let railMinHeight: CGFloat
    let emptyActionBottomClearance: CGFloat
    let usesStackedAccessibilityRail: Bool
    let showsStageMetrics: Bool

    static func layout(dynamicTypeSize: DynamicTypeSize, showsNavigationChrome: Bool) -> TodayViewportSafety {
        if usesExpandedViewport(dynamicTypeSize: dynamicTypeSize) {
            return TodayViewportSafety(
                topChromeClearance: 72,
                rootBottomChromeClearance: showsNavigationChrome ? 160 : 560,
                railBottomContentClearance: 260,
                railMinHeight: 980,
                emptyActionBottomClearance: 240,
                usesStackedAccessibilityRail: true,
                showsStageMetrics: false
            )
        }

        return TodayViewportSafety(
            topChromeClearance: 40,
            rootBottomChromeClearance: showsNavigationChrome ? 128 : 420,
            railBottomContentClearance: 148,
            railMinHeight: 760,
            emptyActionBottomClearance: 120,
            usesStackedAccessibilityRail: false,
            showsStageMetrics: true
        )
    }

    static func usesExpandedViewport(dynamicTypeSize: DynamicTypeSize) -> Bool {
        dynamicTypeSize >= .xxLarge
    }
}
