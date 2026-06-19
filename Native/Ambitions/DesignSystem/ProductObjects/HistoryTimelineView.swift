import AmbitionsDesignSystem
import SwiftUI

struct InsightsTimelineSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String
    let items: [InsightsTimelineItem]
    let onOpenItem: (InsightsTimelineItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            SectionHeader(title: title, subtitle: subtitle)

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                ForEach(items) { item in
                    Button {
                        onOpenItem(item)
                    } label: {
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            Image(systemName: item.icon)
                                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                .foregroundStyle(theme.stateStyle(for: item.visualState).accent)
                                .padding(.top, 2)

                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                HStack(spacing: theme.spacing.xs) {
                                    Text(item.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    if let badge = item.badge {
                                        TagPill(badge, state: item.visualState)
                                    }
                                }
                                Text(item.subtitle)
                                    .font(theme.typography.body)
                                    .foregroundStyle(theme.colors.textSecondary)
                                Text(item.timestamp)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                            }

                            Spacer(minLength: theme.spacing.sm)
                            if item.goalTarget != nil || item.timeRoute != nil {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                    .foregroundStyle(theme.colors.textTertiary)
                            }
                        }
                        .padding(theme.spacing.md)
                        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .disabled(item.goalTarget == nil && item.timeRoute == nil)
                }
            }
        }
    }
}
