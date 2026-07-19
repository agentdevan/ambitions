#if canImport(SwiftUI)
import SwiftUI

private enum RealityMeridianRichnessMode: Equatable {
    case normal
    case overloaded
}

private struct RealityMeridianRichnessPreviewGallery: View {
    @Environment(\.ambitionTheme) private var theme

    private let currentDate = Date(timeIntervalSince1970: 45_300.0)
    private let mode: RealityMeridianRichnessMode
    private let reduceMotion: Bool

    init(mode: RealityMeridianRichnessMode, reduceMotion: Bool = false) {
        self.mode = mode
        self.reduceMotion = reduceMotion
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(mode == .overloaded ? "Reality Meridian overloaded" : "Reality Meridian normal")
                        .font(theme.typography.sectionTitle)
                        .foregroundStyle(theme.colors.textPrimary)

                    Text("The time band, current-time glow, scheduled nodes, and execution pressure stay connected.")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                StateDrivenMaterialPanel(context: .today, state: mode == .overloaded ? .pressured : .active) {
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        RealityMeridianTimeBand(date: currentDate)

                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            RealityMeridianCurrentTimeCursor(
                            title: "Current time",
                            date: currentDate,
                            showsPulse: reduceMotion == false && mode != .overloaded,
                            presentation: .railOverlay
                        )
                            .frame(height: mode == .overloaded ? 148 : 160)

                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                RealityMeridianScheduledNode(
                                    timeLabel: "10:00 AM",
                                    title: "Start here",
                                    isActive: false
                                )

                                RealityMeridianScheduledNode(
                                    timeLabel: "10:45 AM",
                                    title: mode == .overloaded ? "Now compresses" : "Open focus window",
                                    isActive: true
                                )

                                if mode == .overloaded {
                                    RealityMeridianScheduledNode(
                                        timeLabel: "11:15 AM",
                                        title: "Next step queued",
                                        isActive: false
                                    )

                                    RealityMeridianScheduledNode(
                                        timeLabel: "11:45 AM",
                                        title: "Later stays open",
                                        isActive: false
                                    )
                                }
                            }
                        }
                    }
                }
            }
            .padding(theme.spacing.lg)
        }
        .background(LivingSurfaceBackground(context: .today, state: mode == .overloaded ? .pressured : .calm).ignoresSafeArea())
        .ambitionTheme(.dark)
    }
}

#if DEBUG
#Preview("Reality Meridian Richness Normal") {
    RealityMeridianRichnessPreviewGallery(mode: .normal)
}

#Preview("Reality Meridian Richness Overloaded") {
    RealityMeridianRichnessPreviewGallery(mode: .overloaded)
}

#Preview("Reality Meridian Richness Reduce Motion") {
    RealityMeridianRichnessPreviewGallery(mode: .normal, reduceMotion: true)
}

#Preview("Reality Meridian Richness Dynamic Type") {
    RealityMeridianRichnessPreviewGallery(mode: .overloaded)
        .environment(\.dynamicTypeSize, .accessibility3)
}
#endif
#endif
