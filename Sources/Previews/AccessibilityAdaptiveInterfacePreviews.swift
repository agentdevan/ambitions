#if canImport(SwiftUI)
import SwiftUI

struct AccessibilityAdaptiveInterfacePreviewGallery: View {
    @Environment(\.ambitionTheme) private var theme

    private let lanes: [AmbitionsAdaptiveReviewLane] = [
        .sourceReview,
        .privacySensitive,
        .professionalBoundary,
        .crisisSupport,
        .overloadedDay,
        .recovery,
        .emptyOrNoData
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                SectionHeader(
                    eyebrow: "SI15",
                    title: "Accessibility Adaptive Interface",
                    subtitle: "Internal evidence matrix for Dynamic Type, VoiceOver, Reduce Motion, privacy-safe exposure, and cognitive load."
                )

                ForEach(lanes) { lane in
                    laneSection(lane)
                }
            }
            .padding(theme.spacing.lg)
        }
        .background(theme.colors.canvas)
    }

    private func laneSection(_ lane: AmbitionsAdaptiveReviewLane) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                AmbitionsStatusSymbol(lane.statusRole, style: .inline)

                Text(lane.cognitiveLoadMode.title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
            .accessibilityElement(children: .combine)

            VStack(spacing: theme.spacing.xs) {
                ForEach(SI15AccessibilityAdaptiveInterfaceReview.requirements(for: lane)) { requirement in
                    AmbitionsAdaptiveRequirementRow(requirement)
                }
            }
        }
    }
}

#Preview("SI15 Accessibility Adaptive Interface") {
    AccessibilityAdaptiveInterfacePreviewGallery()
}

#Preview("SI15 Accessibility Adaptive Dynamic Type") {
    AccessibilityAdaptiveInterfacePreviewGallery()
        .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("SI15 Accessibility Adaptive Static Motion") {
    AccessibilityAdaptiveInterfacePreviewGallery()
}
#endif
