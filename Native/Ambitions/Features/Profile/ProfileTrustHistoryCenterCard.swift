import AmbitionsDesignSystem
import SwiftUI

struct ProfileTrustHistoryCenterCard: View {
    @Environment(\.ambitionTheme) private var theme

    let history: ProfileTrustHistoryCenterState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Trust history",
                    title: history.title,
                    subtitle: history.subtitle
                )

                ForEach(ProfileTrustHistoryCategory.allCases, id: \.rawValue) { category in
                    let categoryItems = history.items.filter { $0.category == category }
                    if !categoryItems.isEmpty {
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            Text(category.title)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .accessibilityAddTraits(.isHeader)

                            ForEach(categoryItems) { item in
                                ProfileTrustHistoryItemRow(item: item)
                            }
                        }
                    }
                }

                Text(history.footer)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("profile.trust-history-center-card")
    }
}

private struct ProfileTrustHistoryItemRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: ProfileTrustHistoryItem

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

            Text("\(item.sourceLabel) · \(item.privacyLabel) · \(item.reversibilityLabel)")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.category.title): \(item.title)")
        .accessibilityValue("\(item.reviewLabel). \(item.sourceLabel). \(item.privacyLabel). \(item.reversibilityLabel).")
        .accessibilityHint("Reviews the local trust history boundary without opening raw logs.")
    }
}
