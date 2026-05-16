import AmbitionsDesignSystem
import SwiftUI

extension DayTimelineRail {
    func fusedCurrentTimeCursor() -> some View {
        modifier(TodayRealityMeridianCurrentTimeFusionModifier())
            .accessibilityIdentifier("TodayRealityMeridianFusedRail")
    }
}

private struct TodayRealityMeridianCurrentTimeFusionModifier: ViewModifier {
    @Environment(\.ambitionTheme) private var theme

    func body(content: Content) -> some View {
        content.overlay(alignment: .topLeading) {
            RealityMeridianCurrentTimeCursor()
                .frame(maxWidth: .infinity, minHeight: 168, alignment: .topLeading)
                .padding(.horizontal, theme.spacing.lg)
                .padding(.top, theme.spacing.lg)
                .allowsHitTesting(false)
                .accessibilityIdentifier("TodayRealityMeridianCurrentTimeCursor")
        }
    }
}
