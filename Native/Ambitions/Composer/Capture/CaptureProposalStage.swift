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
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            proposalHeader
            capturedText
            destinationSummary
            destinationChoices
            resolverDisclosure
            proposalActions
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, theme.spacing.sm)
        .padding(.leading, theme.spacing.sm)
        .background(alignment: .leading) {
            Rectangle()
                .fill(theme.colors.accentWarm.opacity(0.32))
                .frame(width: 2)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Capture proposal")
        .accessibilityValue(accessibilityValue)
        .accessibilityHint("Accept, change destination, or cancel without saving.")
    }

    private var proposalHeader: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: "checklist")
                .font(.system(size: theme.icon.smallSize, weight: .semibold))
                .foregroundStyle(theme.colors.accentWarm)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text("Placement review")
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                    .accessibilityIdentifier("capture.proposal")
                Text("Choose where this goes before saving.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var capturedText: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text("Captured")
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
            proposalLine(icon: "target", title: "Destination", value: displayDestinationLabel)
            proposalLine(icon: "square.stack.3d.up", title: "Object", value: displayObjectTypeLabel)
            proposalLine(icon: "calendar", title: "Time fit", value: timeWindowLabel)
            proposalLine(icon: "person.2", title: "Goal or area", value: areaOrGoalLabel)
            proposalLine(icon: "lock.shield", title: "Local status", value: displayPrivacyLabel)
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
                HStack(spacing: theme.spacing.xs) {
                    Image(systemName: choice.isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: theme.icon.smallSize, weight: .semibold))
                        .foregroundStyle(choice.isSelected ? theme.colors.accentWarm : theme.colors.textTertiary)
                        .accessibilityHidden(true)
                    Text(displayLabel(choice.title))
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.84)
                }
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("capture.proposal.placement-choice.\(choice.routeType.rawValue)")
            .accessibilityLabel(displayLabel(choice.title))
            .accessibilityValue(choice.isSelected ? "Selected" : "Available")
        }
    }

    private var resolverDisclosure: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(displayResolverWhyLabel)
                Text(displayRouteProofDetail)
            }
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, theme.spacing.xs)
        } label: {
            Label("Why this placement", systemImage: "info.circle")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
        }
        .accessibilityIdentifier("capture.proposal.placement-reason-disclosure")
    }

    private var proposalActions: some View {
        HStack(spacing: theme.spacing.sm) {
            Button {
                onAccept()
            } label: {
                Label(isSaving ? "Saving" : "Accept", systemImage: "checkmark.circle.fill")
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .padding(.horizontal, theme.spacing.md)
                    .frame(minHeight: 44)
                    .background(
                        Capsule(style: .continuous)
                            .fill(theme.colors.accentWarm.opacity(0.28))
                    )
            }
            .buttonStyle(.plain)
            .disabled(isSaving)
            .accessibilityIdentifier("capture.proposal.accept")

            Button {
                onCancel()
            } label: {
                Label("Cancel", systemImage: "arrow.uturn.backward")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .frame(minHeight: 44)
            }
            .buttonStyle(.plain)
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
        displayLabel(preview.planInsertionCandidate?.proposedStartLabel ?? "Time not set")
    }

    private var areaOrGoalLabel: String {
        if displayDestinationLabel.localizedCaseInsensitiveContains("Goal") {
            return displayDestinationLabel
        }
        if preview.suggestedPlacementLabel.localizedCaseInsensitiveContains("Fitness") {
            return displayLabel(preview.suggestedPlacementLabel)
        }
        return "Not tied yet"
    }

    private var displayDestinationLabel: String {
        displayLabel(preview.destinationLabel)
    }

    private var displayObjectTypeLabel: String {
        displayLabel(preview.objectTypeLabel)
    }

    private var displayPrivacyLabel: String {
        displayLabel(preview.privacyLabel)
    }

    private var displayResolverWhyLabel: String {
        displayLabel(preview.resolverWhyLabel)
    }

    private var displayRouteProofDetail: String {
        displayLabel(preview.routeProofDetail)
    }

    private func displayLabel(_ rawValue: String) -> String {
        CaptureCopyPolicy.primaryDisplayLabel(rawValue)
    }

    private var accessibilityValue: String {
        [
            preview.originalText,
            displayDestinationLabel,
            displayObjectTypeLabel,
            timeWindowLabel,
            areaOrGoalLabel,
            displayPrivacyLabel
        ].joined(separator: ". ")
    }
}
