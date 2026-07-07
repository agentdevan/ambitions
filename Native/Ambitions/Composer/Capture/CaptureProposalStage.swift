import AmbitionsDesignSystem
import SwiftUI

struct CaptureProposalStage: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let preview: CaptureDraftRoutePreview
    let isSaving: Bool
    let onAccept: () -> Void
    let onChangeDestination: (SmartAttachmentRouteType) -> Void
    let onCancel: () -> Void

    var body: some View {
        CaptureStageGroup(state: .active, accessibilityIdentifier: nil) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                proposalHeader
                capturedText
                destinationSummary
                destinationChoices
                resolverDisclosure
                proposalActions
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Capture proposal")
        .accessibilityValue(accessibilityValue)
        .accessibilityHint("Accept, change destination, or cancel without saving.")
    }

    private var proposalHeader: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: theme.icon.smallSize, weight: .semibold))
                .foregroundStyle(theme.colors.accentWarm)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text("Proposal")
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                    .accessibilityIdentifier("capture.proposal")
                Text("Confirm the destination or change it first.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var capturedText: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text("Captured text")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
            Text(preview.originalText)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("capture.proposal.captured-text")
        }
    }

    private var destinationSummary: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            proposalLine(icon: "target", title: "Destination", value: preview.destinationLabel)
            proposalLine(icon: "square.stack.3d.up", title: "Object", value: preview.objectTypeLabel)
            proposalLine(icon: "calendar", title: "Time", value: timeWindowLabel)
            proposalLine(icon: "person.2", title: "Area or goal", value: areaOrGoalLabel)
            proposalLine(icon: "lock.shield", title: "Storage", value: preview.privacyLabel)
        }
    }

    private var destinationChoices: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text("Change destination")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
                .accessibilityIdentifier("capture.proposal.change-destination")
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    choiceButtons
                }
            } else {
                HStack(spacing: theme.spacing.xs) {
                    choiceButtons
                }
            }
        }
    }

    @ViewBuilder
    private var choiceButtons: some View {
        ForEach(preview.choices) { choice in
            Button {
                onChangeDestination(choice.routeType)
            } label: {
                Label(choice.title, systemImage: choice.isSelected ? "checkmark.circle.fill" : "circle")
                    .lineLimit(1)
                    .minimumScaleFactor(0.84)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: choice.isSelected ? .selected : .default))
            .accessibilityIdentifier("capture.proposal.placement-choice.\(choice.routeType.rawValue)")
            .accessibilityLabel(choice.title)
            .accessibilityValue(choice.isSelected ? "Selected" : "Available")
        }
    }

    private var resolverDisclosure: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(preview.resolverWhyLabel)
                Text(preview.routeProofDetail)
            }
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, theme.spacing.xs)
        } label: {
            Label("Resolver", systemImage: "info.circle")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
        }
        .accessibilityIdentifier("capture.proposal.resolver-disclosure")
    }

    private var proposalActions: some View {
        HStack(spacing: theme.spacing.sm) {
            Button {
                onAccept()
            } label: {
                Label(isSaving ? "Saving" : "Accept", systemImage: "checkmark.circle")
                    .frame(minHeight: 44)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: isSaving ? .disabled : .selected))
            .disabled(isSaving)
            .accessibilityIdentifier("capture.proposal.accept")

            Button {
                onCancel()
            } label: {
                Label("Cancel", systemImage: "arrow.uturn.backward")
                    .frame(minHeight: 44)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            .accessibilityIdentifier("capture.proposal.cancel")
        }
    }

    private func proposalLine(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: theme.icon.smallSize, weight: .semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .frame(width: 18)
                .accessibilityHidden(true)
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .frame(width: dynamicTypeSize.isAccessibilitySize ? nil : 94, alignment: .leading)
            Text(value)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var timeWindowLabel: String {
        preview.planInsertionCandidate?.proposedStartLabel ?? "Not set"
    }

    private var areaOrGoalLabel: String {
        if preview.destinationLabel.localizedCaseInsensitiveContains("Goal") {
            return preview.destinationLabel
        }
        if preview.suggestedPlacementLabel.localizedCaseInsensitiveContains("Fitness") {
            return preview.suggestedPlacementLabel
        }
        return "Unplaced item"
    }

    private var accessibilityValue: String {
        [
            preview.originalText,
            preview.destinationLabel,
            preview.objectTypeLabel,
            timeWindowLabel,
            areaOrGoalLabel,
            preview.privacyLabel
        ].joined(separator: ". ")
    }
}
