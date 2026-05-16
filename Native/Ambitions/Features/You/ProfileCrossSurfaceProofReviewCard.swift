import AmbitionsDesignSystem
import SwiftUI

struct ProfileCrossSurfaceProofReviewCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: ProfileCrossSurfaceProofReviewState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Proof and review",
                    title: state.title,
                    subtitle: state.subtitle
                )

                ForEach(state.items) { item in
                    ProfileCrossSurfaceProofReviewRow(item: item)
                }

                Text(state.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("profile.cross-surface-proof-review-card")
        .ambitionPanelAccessibility(
            label: state.title,
            value: "\(state.items.count) proof and review connections",
            hint: "Summarizes where proof and receipt review belong."
        )
    }
}

private struct ProfileCrossSurfaceProofReviewRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: ProfileCrossSurfaceProofReviewItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                Text(item.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: theme.spacing.sm)

                TagPill(item.reviewLabel, state: item.state)
            }

            Text(item.summary)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(item.sourceLabel) · \(item.privacyLabel) · \(item.routeLabel)")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
        .accessibilityValue("\(item.reviewLabel). \(item.sourceLabel). \(item.privacyLabel). \(item.routeLabel).")
        .accessibilityHint("Reviews the cross-surface proof boundary without opening raw logs.")
    }
}
