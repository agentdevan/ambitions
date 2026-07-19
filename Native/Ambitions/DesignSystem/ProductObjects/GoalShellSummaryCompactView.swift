import AmbitionsDesignSystem
import SwiftUI

struct GoalShellSummaryCompactView: View {
    @Environment(\.ambitionTheme) private var theme

    let summary: GoalShellSummaryState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(summary.explanationSummary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if summary.pathSummary != summary.explanationSummary {
                Text(summary.pathSummary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.xs) {
                    ForEach(summary.indicators) { indicator in
                        TagPill(indicator.title, icon: indicator.systemImage, state: indicator.state)
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(summary.explanationSummary)
        .accessibilityValue(summary.pathSummary)
    }
}
