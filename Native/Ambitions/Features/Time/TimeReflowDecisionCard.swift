import AmbitionsDesignSystem
import SwiftUI

struct PlanReflowDecisionCard: View {
    @Environment(\.ambitionTheme) private var theme

    let decision: PlanReflowDecisionState
    let onActivate: (PlanReflowDecisionOptionState, PlanReflowDecisionActionKind) -> Void

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
                        PlanReflowDecisionOptionRow(option: option, onActivate: onActivate)
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
    let onActivate: (PlanReflowDecisionOptionState, PlanReflowDecisionActionKind) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
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
            }

            PlanReflowBeforeAfterPreview(
                preview: option.beforeAfterPreview,
                visualState: option.visualState
            )

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                decisionFact(option.whatChangedLabel, icon: "arrow.triangle.2.circlepath")
                decisionFact(option.whyChangedLabel, icon: "questionmark.circle")
                decisionFact(option.impactedStepsLabel, icon: "checklist")
                decisionFact(option.capacityImpactLabel, icon: "gauge.medium")
                decisionFact(option.protectedTimeImpactLabel, icon: "clock.badge.checkmark")
            }

            HStack(spacing: theme.spacing.xs) {
                ForEach(option.actions) { action in
                    Button {
                        onActivate(option, action.kind)
                    } label: {
                        Label(action.title, systemImage: action.kind.icon)
                            .font(theme.typography.caption)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                    .buttonStyle(AmbitionButtonStyle(tier: .secondary, state: action.visualState))
                    .disabled(action.isEnabled == false)
                    .accessibilityLabel("\(action.title). \(action.detail)")
                }
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
        .accessibilityLabel(option.title)
        .accessibilityValue(option.accessibilityValue)
    }

    private func decisionFact(_ text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.textTertiary)
                .frame(width: 18)
            Text(text)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct PlanReflowBeforeAfterPreview: View {
    @Environment(\.ambitionTheme) private var theme

    let preview: PlanReflowBeforeAfterShapePreviewState
    let visualState: AmbitionVisualState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Label(preview.title, systemImage: "rectangle.split.2x1")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)

            HStack(alignment: .top, spacing: theme.spacing.xs) {
                previewColumn(preview.beforeLabel, icon: "arrow.left.circle")
                previewColumn(preview.afterLabel, icon: "arrow.right.circle")
            }

            decisionFact(preview.shapeChangeLabel, icon: "point.3.connected.trianglepath.dotted")
            decisionFact(preview.receiptPreviewLabel, icon: "doc.text.magnifyingglass")
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.stateStyle(for: visualState).accent.opacity(0.08))
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(preview.title)
        .accessibilityValue(preview.accessibilityValue)
    }

    private func previewColumn(_ text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.stateStyle(for: visualState).accent)
                .frame(width: 18)
            Text(text)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func decisionFact(_ text: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.textTertiary)
                .frame(width: 18)
            Text(text)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
