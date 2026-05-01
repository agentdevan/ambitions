import AmbitionsDesignSystem
import SwiftUI

struct PlanReflowDecisionCard: View {
    @Environment(\.ambitionTheme) private var theme

    let decision: PlanReflowDecisionState
    let onActivate: (PlanReflowDecisionOptionState) -> Void

    var body: some View {
        AppCard(state: decision.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: decision.title, subtitle: decision.subtitle)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        TagPill(decision.sourceLabel, icon: "iphone", state: .default)
                        TagPill(decision.trustLabel, icon: "hand.raised", state: decision.visualState)
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(decision.reasonLabel)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(decision.recoveryLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(decision.options) { option in
                        Button {
                            onActivate(option)
                        } label: {
                            PlanReflowDecisionOptionRow(option: option)
                        }
                        .buttonStyle(.plain)
                        .disabled(option.target == nil && option.planRoute == nil)
                    }
                }

                Text(decision.receiptLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("plan.reflow-decision")
        .accessibilityElement(children: .contain)
        .ambitionPanelAccessibility()
    }
}

private struct PlanReflowDecisionOptionRow: View {
    @Environment(\.ambitionTheme) private var theme

    let option: PlanReflowDecisionOptionState

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: option.kind.icon)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.stateStyle(for: option.visualState).accent)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                HStack(spacing: theme.spacing.xs) {
                    Text(option.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    TagPill(option.trustLabel, state: option.visualState)
                }

                Text(option.detail)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(option.impactLabel). \(option.boundaryLabel)")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.sm)

            if option.target != nil || option.planRoute != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(option.title). \(option.detail). \(option.trustLabel). \(option.boundaryLabel)")
    }
}
