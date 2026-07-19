import AmbitionsDesignSystem
import SwiftUI

struct InsightsComparePeriodSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let compare: InsightsComparePeriodState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: compare.title, subtitle: compare.subtitle)

                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    ForEach(compare.metrics) { metric in
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            Text(metric.title)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                            Text(metric.currentLabel)
                                .font(theme.typography.titleCompact)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text("Last week \(metric.previousLabel)")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textTertiary)
                            TagPill(metric.deltaLabel, state: metric.visualState)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(theme.spacing.md)
                        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
                    }
                }

                Text(compare.summary)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("insights.compare-period")
        .ambitionPanelAccessibility()
    }
}
