import AmbitionsDesignSystem
import SwiftUI

struct CaptureDraftRoutePreviewCard: View {
    @Environment(\.ambitionTheme) private var theme

    let preview: CaptureDraftRoutePreview
    let onSelect: (SmartAttachmentRouteType) -> Void

    private var visualState: AmbitionVisualState {
        preview.semanticState == SmartAttachmentResultState.needsClarification.rawValue ? .warning : .selected
    }

    var body: some View {
        StateDrivenMaterialPanel(context: .capture, state: livingState) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                routeSummary
                EvidenceLabel(
                    preview.postInputStateTitle,
                    detail: preview.summary,
                    source: preview.destinationLabel,
                    state: livingState,
                    context: .capture
                )
                EvidenceLabel(
                    preview.routeProofTitle,
                    detail: preview.routeProofDetail,
                    source: "Local route proof",
                    state: livingState,
                    context: .capture
                )
                placementDetails
                clarificationQuestion
                routeChoices
                routeCommands
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(preview.accessibilityLabel)
        .accessibilityValue(preview.accessibilityValue)
        .accessibilityHint(preview.accessibilityHint ?? "Choose a different route if this is not right.")
        .accessibilityIdentifier("captures.smart-attachment-preview")
    }

    private var livingState: LivingVisualState {
        visualState == .warning ? .pressured : .active
    }

    private var routeSummary: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: theme.icon.smallSize, weight: .semibold))
                .foregroundStyle(theme.colors.accentWarm)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(preview.postInputStateTitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(preview.receiptTitle)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(preview.summary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                Text(preview.destinationLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var placementDetails: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            Text(preview.objectTypeLabel)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
            Text(preview.appearanceLabel)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
            Text(preview.consequenceLabel)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
            Text(preview.privacyLabel)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var clarificationQuestion: some View {
        if let question = preview.clarificationQuestion {
            Text(question)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
        }
    }

    private var routeChoices: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(preview.choices) { choice in
                Button {
                    onSelect(choice.routeType)
                } label: {
                    Text(choice.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: choice.isSelected ? .selected : .default))
                .accessibilityIdentifier("captures.route-choice.\(choice.routeType.rawValue)")
            }
        }
    }

    private var routeCommands: some View {
        HStack(spacing: theme.spacing.xs) {
            Label(preview.primaryActionTitle, systemImage: "checkmark.circle")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
            Text(preview.changeActionTitle)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
            Text(preview.safeActionTitle)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(preview.primaryActionTitle), \(preview.changeActionTitle), or \(preview.safeActionTitle)")
    }
}
