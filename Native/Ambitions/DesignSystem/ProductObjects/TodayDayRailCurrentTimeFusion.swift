import AmbitionsDesignSystem
import SwiftUI

extension RealityMeridianView {
    func fusedCurrentTimeCursor() -> some View {
        modifier(TodayRealityMeridianCurrentTimeFusionModifier())
            .accessibilityIdentifier("TodayRealityMeridianFusedRail")
    }
}

struct TodayRealityMeridianCurrentTimeFusionModifier: ViewModifier {
    @Environment(\.ambitionTheme) private var theme

    func body(content: Content) -> some View {
        let surfaceTheme = theme

        VStack(alignment: .leading, spacing: 0) {
            RealityMeridianTimeBand()
                .padding(.horizontal, surfaceTheme.spacing.xxs)
                .padding(.top, surfaceTheme.spacing.xxs)
                .padding(.bottom, surfaceTheme.spacing.xs)

            content.overlay(alignment: .topLeading) {
                RealityMeridianCurrentTimeCursor(presentation: .railOverlay)
                    .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
                    .padding(.horizontal, surfaceTheme.spacing.lg)
                    .padding(.top, surfaceTheme.spacing.lg)
                    .opacity(0.72)
                    .allowsHitTesting(false)
                    .accessibilityIdentifier("TodayRealityMeridianCurrentTimeCursor")
            }
        }
        .ambitionTheme(surfaceTheme)
        .environment(\.colorScheme, surfaceTheme.mode == .dark ? .dark : .light)
        .background(fusedSurfaceMaterial(for: surfaceTheme))
        .clipShape(RoundedRectangle(cornerRadius: surfaceTheme.radius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: surfaceTheme.radius.xl, style: .continuous)
                .stroke(surfaceTheme.colors.strokeSubtle, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(surfaceTheme.mode == .dark ? 0.42 : 0.10), radius: 28, x: 0, y: 18)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Reality Meridian time band and rail")
        .accessibilityIdentifier("TodayRealityMeridianFusedRail")
    }

    func fusedSurfaceMaterial(for theme: AmbitionTheme) -> LinearGradient {
        switch theme.mode {
        case .dark:
            LinearGradient(
                colors: [
                    Color(red: 0.020, green: 0.024, blue: 0.036),
                    Color(red: 0.010, green: 0.014, blue: 0.024),
                    Color(red: 0.006, green: 0.008, blue: 0.014),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .light:
            LinearGradient(
                colors: [
                    theme.colors.surfacePrimary.opacity(0.98),
                    theme.colors.surfaceSecondary.opacity(0.94),
                    theme.colors.canvasElevated.opacity(0.96),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
