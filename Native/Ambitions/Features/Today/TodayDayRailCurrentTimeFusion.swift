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
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.shell.elevatedMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.shell.divider.opacity(0.9), lineWidth: 1)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Reality Meridian time band and rail")
        .accessibilityIdentifier("TodayRealityMeridianFusedRail")
    }
}
