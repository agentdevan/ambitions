import AmbitionsDesignSystem
import SwiftUI

extension RealityMeridianView {
    func fusedCurrentTimeCursor() -> some View {
        modifier(TodayRealityMeridianCurrentTimeFusionModifier())
            .accessibilityIdentifier("TodayRealityMeridianFusedRail")
    }
}

private struct TodayRealityMeridianCurrentTimeFusionModifier: ViewModifier {
    @Environment(\.ambitionTheme) private var theme

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            RealityMeridianTimeBand()

            content.overlay(alignment: .topLeading) {
                RealityMeridianCurrentTimeCursor(presentation: .railOverlay)
                    .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
                    .padding(.horizontal, theme.spacing.lg)
                    .padding(.top, theme.spacing.lg)
                    .allowsHitTesting(false)
                    .accessibilityIdentifier("TodayRealityMeridianCurrentTimeCursor")
            }
        }
        .accessibilityElement(children: .contain)
    }
}
