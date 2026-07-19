import AmbitionsDesignSystem
import SwiftUI

struct InsightsReviewConstellationSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: InsightsReviewConstellationState
    let onOpenGoal: (GoalRouteTarget) -> Void
    let onOpenTimeRoute: (TimeRouteTarget) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(Array(state.items.enumerated()), id: \.element.id) { index, item in
                        Button {
                            if let goalTarget = item.goalTarget {
                                onOpenGoal(goalTarget)
                            } else if let timeRoute = item.timeRoute {
                                onOpenTimeRoute(timeRoute)
                            }
                        } label: {
                            HStack(alignment: .top, spacing: theme.spacing.sm) {
                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                    TagPill(item.signalLabel, state: item.visualState)
                                    Text(item.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    Text(item.summary)
                                        .font(theme.typography.body)
                                        .foregroundStyle(theme.colors.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
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
                        .accessibilityIdentifier(reviewConstellationIdentifier(item: item, index: index))
                    }
                }
            }
        }
        .accessibilityIdentifier("insights.review-constellation")
        .ambitionPanelAccessibility()
    }

    private func reviewConstellationIdentifier(item: InsightsReviewConstellationItem, index: Int) -> String {
        if item.timeRoute != nil && item.goalTarget == nil {
            return "insights.review-constellation.constellation-plan"
        }
        if item.goalTarget != nil && index == state.items.firstIndex(where: { $0.goalTarget != nil }) {
            return "insights.review-constellation.primary-goal"
        }
        return "insights.review-constellation.\(item.id)"
    }
}
