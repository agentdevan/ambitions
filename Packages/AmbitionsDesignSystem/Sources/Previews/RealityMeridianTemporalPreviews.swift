#if canImport(SwiftUI)
import SwiftUI

private struct RealityMeridianTemporalPreviewGallery: View {
    @Environment(\.ambitionTheme) private var theme

    private let currentDate = Date(timeIntervalSince1970: 45_300.0)
    private let reduceMotion: Bool

    init(reduceMotion: Bool = false) {
        self.reduceMotion = reduceMotion
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(FE04PrimitiveRole.currentTimeGlow.title)
                        .font(theme.typography.sectionTitle)
                        .foregroundStyle(theme.colors.textPrimary)

                    Text("Reality Meridian temporal primitives")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                StateDrivenMaterialPanel(context: .today, state: .active) {
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        RealityMeridianCurrentTimeCursor(
                            title: FE04PrimitiveRole.currentTimeGlow.title,
                            date: currentDate,
                            showsPulse: reduceMotion == false,
                            presentation: .standalone
                        )
                        .frame(height: 182)

                        RealityMeridianScheduledNode(
                            timeLabel: "10:00 AM",
                            title: "Scheduled step",
                            isActive: false
                        )

                        RealityMeridianScheduledNode(
                            timeLabel: "12:15 PM",
                            title: "Open focus window",
                            isActive: true
                        )
                    }
                }

                StateDrivenMaterialPanel(context: .today, state: .proof) {
                    RealityMeridianCurrentTimeCursor(
                        title: FE04PrimitiveRole.meridianNode.title,
                        date: currentDate,
                        showsPulse: false,
                        presentation: .railOverlay
                    )
                    .frame(height: 160)
                }
            }
            .padding(theme.spacing.lg)
        }
        .background(LivingSurfaceBackground(context: .today, state: .calm).ignoresSafeArea())
        .ambitionTheme(.dark)
    }
}

#if DEBUG
#Preview("Reality Meridian Temporal Primitives") {
    RealityMeridianTemporalPreviewGallery()
}

#Preview("Reality Meridian Temporal Primitives Reduce Motion") {
    RealityMeridianTemporalPreviewGallery(reduceMotion: true)
}

#Preview("Reality Meridian Temporal Primitives Dynamic Type") {
    RealityMeridianTemporalPreviewGallery()
        .environment(\.dynamicTypeSize, .accessibility3)
}
#endif
#endif
