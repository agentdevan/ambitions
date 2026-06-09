import AmbitionsDesignSystem
import SwiftUI

struct TimeReflowDecisionSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let decision: TimeReflowDecisionState
    let onActivate: (TimeReflowDecisionOptionState, TimeReflowDecisionActionKind) -> Void

    var body: some View {
        QuietReflowPrimitiveStage(
            role: .preview,
            title: decision.title,
            subtitle: decision.subtitle,
            statusLabel: decision.trustLabel,
            visualState: decision.visualState,
            accessibilityIdentifier: "time.reflow-decision"
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                QuietReflowPrimitiveLine(
                    role: .source,
                    title: decision.sourceLabel,
                    subtitle: decision.reasonLabel,
                    systemImage: "iphone",
                    visualState: decision.visualState
                )

                QuietReflowPrimitiveLine(
                    role: .noSilentChange,
                    title: decision.trustLabel,
                    subtitle: decision.recoveryLabel,
                    systemImage: "hand.raised",
                    visualState: decision.visualState
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(decision.options) { option in
                        TimeReflowDecisionOptionRow(option: option, onActivate: onActivate)
                    }
                }

                QuietReflowPrimitiveLine(
                    role: .receipt,
                    title: decision.receiptLabel,
                    systemImage: "doc.text.magnifyingglass"
                )
            }
        }
        .accessibilityElement(children: .contain)
        .ambitionPanelAccessibility()
    }
}

private struct TimeReflowDecisionOptionRow: View {
    @Environment(\.ambitionTheme) private var theme

    let option: TimeReflowDecisionOptionState
    let onActivate: (TimeReflowDecisionOptionState, TimeReflowDecisionActionKind) -> Void

    var body: some View {
        QuietReflowPrimitiveStage(
            role: .option,
            title: option.title,
            subtitle: option.detail,
            statusLabel: option.trustLabel,
            systemImage: option.kind.icon,
            visualState: option.visualState,
            accessibilityIdentifier: "time.reflow-decision.option.\(option.id)"
        ) {
            TimeReflowBeforeAfterPreview(
                preview: option.beforeAfterPreview,
                visualState: option.visualState
            )

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                decisionFact("\(option.impactLabel). \(option.boundaryLabel)", icon: "lock.shield")
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

private struct TimeReflowBeforeAfterPreview: View {
    @Environment(\.ambitionTheme) private var theme

    let preview: TimeReflowBeforeAfterShapePreviewState
    let visualState: AmbitionVisualState

    var body: some View {
        QuietReflowBeforeAfterPrimitive(
            title: preview.title,
            beforeLabel: preview.beforeLabel,
            afterLabel: preview.afterLabel,
            changeLabel: preview.shapeChangeLabel,
            receiptLabel: preview.receiptPreviewLabel,
            visualState: visualState
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(preview.title)
        .accessibilityValue(preview.accessibilityValue)
    }
}
