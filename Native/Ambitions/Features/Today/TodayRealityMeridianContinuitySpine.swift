import AmbitionsDesignSystem
import SwiftUI

struct RealityRailContinuitySpine: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: DayRailContinuityState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(state.title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(state.summary)
                    .font(theme.typography.bodySecondary)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    markerViews
                }
            } else {
                HStack(alignment: .top, spacing: theme.spacing.xs) {
                    markerViews
                }
            }

            HStack(spacing: theme.spacing.xs) {
                AmbitionChip(state.pressureLabel, role: .state, semanticState: .caution)
                AmbitionChip(state.noSilentChangesLabel, role: .state, semanticState: .trust)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Rail safeguards")
            .accessibilityValue("\(state.pressureLabel). \(state.noSilentChangesLabel)")
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.68))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(state.title)
        .accessibilityValue(accessibilityValue)
    }

    private var markerViews: some View {
        ForEach(state.markers) { marker in
            RealityRailContinuityMarker(marker: marker)
        }
    }

    private var accessibilityValue: String {
        (state.markers.map { "\($0.title): \($0.summary). \($0.detail)" } + [
            state.noSilentChangesLabel,
        ]).joined(separator: ". ")
    }
}

private struct RealityRailContinuityMarker: View {
    @Environment(\.ambitionTheme) private var theme

    let marker: DayRailContinuityMarkerState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            HStack(alignment: .center, spacing: theme.spacing.xs) {
                DayRailNode(kind: marker.kind, active: marker.id == "rail.continuity.start")
                    .frame(width: 24, height: 32)
                    .accessibilityHidden(true)
                Text(marker.title)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.88)
            }

            Text(marker.summary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(marker.detail)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .fill(theme.semanticStyle(for: marker.semanticState).fill.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .stroke(theme.semanticStyle(for: marker.semanticState).stroke.opacity(0.64), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(marker.title)
        .accessibilityValue("\(marker.summary). \(marker.detail)")
    }
}
