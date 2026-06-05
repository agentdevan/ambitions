#if canImport(SwiftUI)
import SwiftUI

struct AccessibilityAdaptiveInterfacePreviewGallery: View {
    @Environment(\.ambitionTheme) private var theme

    private let objects = AmbitionsPrimaryObjectSurface.allCases
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

                SectionHeader(
                    eyebrow: "Object Summary",
                    title: "Primary Surface Accessibility Strategy",
                    subtitle: "Today, Goals, Time, Motion, You, and global Capture summaries for SI15 helper parity."
                )

                ForEach(objects, id: \.self) { surface in
                    objectSummarySection(SI15AccessibilityAdaptiveInterfaceReview.requirement(for: surface))
                }

                ForEach(lanes) { lane in
                    laneSection(lane)
                }
            }
            .padding(theme.spacing.lg)
        }
        .background(theme.colors.canvas)
    }

    private func objectSummarySection(_ summary: AmbitionsPrimaryObjectAccessibilitySummary) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(summary.surface.objectTitle)
                .font(theme.typography.captionStrong)
                .foregroundStyle(theme.colors.textPrimary)

            Text(summary.activeObjectSummary)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)

            Text("Dynamic Type collapse: \(summary.dynamicTypeStrategy)")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)

            Text("Static motion equivalent: \(summary.staticMotionEquivalent)")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)

            Text("Expanded hit areas: \(summary.expandedHitAreaStrategy)")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)

            Text("Contrast/Transparency coordination: \(summary.contrastTransparencyStrategy)")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .padding(.bottom, theme.spacing.xs)
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .strokeBorder(theme.colors.borderPrimary.opacity(0.22), lineWidth: 1)
        )
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.35))
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("si15.primarySurfaceSummary.\(summary.surface.rawValue)")
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

#Preview("SI15 Accessibility Adaptive Dynamic Type Extra Extra Large") {
    AccessibilityAdaptiveInterfacePreviewGallery()
        .environment(\.dynamicTypeSize, .accessibility5)
}

#Preview("SI15 Accessibility Adaptive Static Motion") {
    AccessibilityAdaptiveInterfacePreviewGallery()
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
}

#Preview("SI15 Accessibility Adaptive Reduce Motion") {
    AccessibilityAdaptiveInterfacePreviewGallery()
        .environment(\.accessibilityReduceMotion, true)
}

#Preview("SI15 Accessibility Adaptive Increase Contrast") {
    AccessibilityAdaptiveInterfacePreviewGallery()
        .environment(\.accessibilityContrast, .increased)
}

#Preview("SI15 Accessibility Adaptive Differentiate Without Color") {
    AccessibilityAdaptiveInterfacePreviewGallery()
        .environment(\.accessibilityDifferentiateWithoutColor, true)
}

#Preview("SI15 Accessibility Adaptive Reduce Transparency") {
    AccessibilityAdaptiveInterfacePreviewGallery()
        .environment(\.accessibilityReduceTransparency, true)
}
#endif
