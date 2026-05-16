import AmbitionsDesignSystem
import SwiftUI

struct PlanLifeShapeDrillDownPanel: View {
    @Environment(\.ambitionTheme) private var theme

    let drillDown: PlanLifeShapeDrillDownState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            header
            itemGrid
            summaryLabels
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfacePrimary)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(drillDown.accessibilityValue)
        .accessibilityIdentifier("plan.life-shape-map.drill-down")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(drillDown.title)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
            Text(drillDown.subtitle)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var itemGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 142), spacing: theme.spacing.xs)],
            alignment: .leading,
            spacing: theme.spacing.xs
        ) {
            ForEach(drillDown.items) { item in
                PlanLifeShapeDrillDownItemCard(item: item)
            }
        }
    }

    private var summaryLabels: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(drillDown.rhythmLabel)
            Text(drillDown.pressureWeeksLabel)
            Text(drillDown.milestoneLabel)
            Text(drillDown.protectedTimeLabel)
            Text(drillDown.freeTimeLabel)
            Text(drillDown.recoverySpaceLabel)
            Text(drillDown.commitmentLoadLabel)
        }
        .font(theme.typography.caption)
        .foregroundStyle(theme.colors.textTertiary)
        .fixedSize(horizontal: false, vertical: true)
    }
}

private struct PlanLifeShapeDrillDownItemCard: View {
    @Environment(\.ambitionTheme) private var theme

    let item: PlanLifeShapeDrillDownItemState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: iconName(for: item.id))
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.stateStyle(for: item.visualState).accent)
                    .frame(width: 18)
                Text(item.title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textPrimary)
            }

            Text(item.value)
                .font(theme.typography.micro)
                .foregroundStyle(theme.stateStyle(for: item.visualState).accent)
            Text(item.detail)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.sm)
        .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.stateStyle(for: item.visualState).stroke.opacity(0.42), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
    }

    private func iconName(for id: String) -> String {
        switch id {
        case "life-areas": "square.grid.2x2"
        case "pressure-weeks": "waveform.path"
        case "milestones": "flag"
        case "protected-time": "clock.badge.checkmark"
        case "free-time": "sun.max"
        case "commitment-load": "gauge.with.dots.needle.bottom.50percent"
        default: "checkmark.circle"
        }
    }
}
