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
        AppCard(state: visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                routeSummary
                clarificationQuestion
                routeChoices
                routeCommands
            }
            .padding(theme.spacing.md)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(preview.accessibilityLabel)
        .accessibilityValue(preview.accessibilityValue)
        .accessibilityHint(preview.accessibilityHint ?? "Choose a different route if this is not right.")
        .accessibilityIdentifier("captures.smart-attachment-preview")
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
