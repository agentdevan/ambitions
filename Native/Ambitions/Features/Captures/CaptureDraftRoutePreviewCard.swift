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
                placementShelf
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
            placementLine(icon: "target", title: "Destination", value: preview.destinationLabel, state: .selected)
            placementLine(icon: "square.stack.3d.up", title: "Object", value: preview.objectTypeLabel, state: .default)
            placementLine(icon: "eye", title: "Appearance", value: preview.appearanceLabel, state: .default)
            placementLine(icon: "arrow.triangle.branch", title: "Consequence", value: preview.consequenceLabel, state: visualState)
            placementLine(icon: "lock", title: "Privacy", value: preview.privacyLabel, state: .default)
            placementLine(icon: "doc.text.magnifyingglass", title: "Source", value: preview.localSourceLabel, state: .default)
            placementLine(icon: "pencil", title: "Correction", value: preview.correctionLabel, state: .default)
            placementLine(icon: "checkmark.seal", title: "Receipt", value: preview.receiptSeamLabel, state: visualState)
        }
        .accessibilityElement(children: .combine)
    }

    private var placementShelf: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(
                eyebrow: "Capture",
                title: preview.placementShelfTitle,
                subtitle: "Destination, consequence, privacy, source, correction, and receipt stay visible before saving."
            )

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
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityIdentifier("captures.placement-shelf")
    }

    private func placementLine(
        icon: String,
        title: String,
        value: String,
        state: AmbitionVisualState
    ) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: theme.icon.smallSize, weight: .semibold))
                .foregroundStyle(theme.stateStyle(for: state).accent)
                .frame(width: 16)
                .accessibilityHidden(true)

            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .frame(width: 78, alignment: .leading)

            Text(value)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
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
