import AmbitionsDesignSystem
import SwiftUI

struct CaptureRouteStagePrimitive: View {
    @Environment(\.ambitionTheme) private var theme

    let preview: CaptureDraftRoutePreview
    let onSelect: (SmartAttachmentRouteType) -> Void

    private var visualState: AmbitionVisualState {
        preview.semanticState == SmartAttachmentResultState.needsClarification.rawValue ? .warning : .selected
    }

    var body: some View {
        CaptureStageGroup(state: livingState, accessibilityIdentifier: "capture.placement-preview") {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                routeSummary
                reviewOverview
                stagingOverview
                placementShelf
                resolverFold
                planInsertionFold
                clarificationQuestion
                routeChoices
                routeCommands
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(preview.accessibilityLabel)
        .accessibilityValue(preview.accessibilityValue)
        .accessibilityHint(preview.accessibilityHint ?? "Choose a different placement if this is not right.")
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

    private var reviewOverview: some View {
        CaptureStageGroup(state: livingState, accessibilityIdentifier: "capture.review-overview") {
            SectionHeader(
                eyebrow: "Capture",
                title: "What Ambitions understood",
                    subtitle: "Placement, likely impact, approval, change options, and fallback stay visible before anything is saved."
            )

            placementLine(icon: "sparkles", title: "Understood", value: preview.understoodLabel, state: visualState)
            placementLine(icon: "target", title: "Suggested placement", value: preview.suggestedPlacementLabel, state: .selected)
            placementLine(icon: "arrow.triangle.branch", title: "May affect", value: preview.mayAffectLabel, state: .default)
            placementLine(icon: "lock", title: "Needs approval", value: preview.approvalNeededLabel, state: visualState)
            placementLine(icon: "pencil", title: "Can change", value: preview.changeableLabels.joined(separator: " / "), state: .default)
            placementLine(icon: "arrow.uturn.backward", title: "Safe fallback", value: preview.safeFallbackLabel, state: .default)
        }
        .accessibilityElement(children: .combine)
    }

    private var stagingOverview: some View {
        CaptureStageGroup(state: .calm, accessibilityIdentifier: "capture.staging-overview") {
            SectionHeader(
                eyebrow: "Capture",
                title: "Local input paths",
                subtitle: "Text, voice, image, share, proof, and context each keep a clear local boundary before anything is saved."
            )

            ForEach(preview.stagedInputs) { stagedInput in
                CaptureStageGroup(state: .calm, accessibilityIdentifier: "capture.staged-input.\(stagedInput.id)") {
                    placementLine(icon: "square.grid.2x2", title: stagedInput.kind.title, value: stagedInput.provenanceLabel, state: .default)
                    placementLine(icon: "target", title: "Placement", value: stagedInput.routeCandidateSummary, state: .selected)
                    placementLine(icon: "lock", title: "Privacy", value: stagedInput.privacyLabel, state: .default)
                    placementLine(icon: "arrow.up.doc", title: "Export", value: stagedInput.exportLabel, state: .default)
                    placementLine(icon: "scissors", title: "Redaction", value: stagedInput.redactionLabel, state: .default)
                    placementLine(icon: "clock.arrow.circlepath", title: "Retention", value: stagedInput.retentionLabel, state: .default)
                    Text(stagedInput.accessibilityReviewSummary)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var placementDetails: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            placementLine(icon: "target", title: "Destination", value: preview.destinationLabel, state: .selected)
            placementLine(icon: "square.stack.3d.up", title: "Object", value: preview.objectTypeLabel, state: .default)
            placementLine(icon: "eye", title: "Appearance", value: preview.appearanceLabel, state: .default)
            placementLine(icon: "arrow.triangle.branch", title: "Consequence", value: preview.consequenceLabel, state: visualState)
            placementLine(icon: "lock", title: "Privacy", value: preview.privacyLabel, state: .default)
            placementLine(icon: "doc.text.magnifyingglass", title: "Started", value: preview.localSourceLabel, state: .default)
            placementLine(icon: "pencil", title: "Correction", value: preview.correctionLabel, state: .default)
            placementLine(icon: "checkmark.seal", title: "History", value: preview.receiptSeamLabel, state: visualState)
        }
        .accessibilityElement(children: .combine)
    }

    private var placementShelf: some View {
        CaptureStageGroup(state: livingState, accessibilityIdentifier: "capture.placement-shelf") {
            SectionHeader(
                eyebrow: "Capture",
                title: Self.placementShelfDisplayTitle(for: preview.placementShelfTitle),
                subtitle: "Destination, consequence, privacy, correction, and history stay visible before saving."
            )

            EvidenceLabel(
                preview.postInputStateTitle,
                detail: preview.summary,
                source: preview.destinationLabel,
                state: livingState,
                context: .capture
            )
            EvidenceLabel(
                    "Placement check",
                    detail: preview.routeProofDetail,
                    source: preview.destinationLabel,
                    state: livingState,
                    context: .capture
                )
            placementDetails
        }
    }

    static func placementShelfDisplayTitle(for rawTitle: String) -> String {
        if rawTitle == "Atmosphere Composer" {
            return "Unplaced item"
        }
        return rawTitle
    }

    private var resolverFold: some View {
        CaptureStageGroup(state: livingState, accessibilityIdentifier: "capture.resolver-fold") {
            SectionHeader(
                eyebrow: "Review",
                title: preview.resolverFoldTitle,
                subtitle: "Change placement, keep it out of Goals, decide later, or discard before saving."
            )

            placementLine(
                icon: "lightbulb",
                title: "Reason",
                value: preview.resolverWhyLabel,
                state: visualState
            )
            placementLine(
                icon: "doc.badge.clock",
                title: "History",
                value: preview.correctionReceiptLabel,
                state: .default
            )

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                ForEach(preview.correctionControlLabels, id: \.self) { label in
                    Label(displayCorrectionLabel(label), systemImage: "checkmark.circle")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func displayCorrectionLabel(_ label: String) -> String {
        label.replacingOccurrences(
            of: "move it out of active review",
            with: "take it out of active review"
        )
    }

    @ViewBuilder
    private var planInsertionFold: some View {
        if let candidate = preview.planInsertionCandidate {
            CaptureStageGroup(state: .active, accessibilityIdentifier: "capture.plan-insertion-fold") {
                SectionHeader(
                    eyebrow: "Time",
                    title: candidate.receiptProjection.title,
                    subtitle: "Add to Time stays approval-gated; calendar writes remain separate."
                )

                placementLine(icon: "calendar.badge.plus", title: "Proposed", value: candidate.title, state: .selected)
                placementLine(icon: "clock", title: "Start", value: candidate.proposedStartLabel, state: .default)
                placementLine(icon: "clock.arrow.circlepath", title: "End", value: candidate.proposedEndLabel, state: .default)
                placementLine(icon: "dial.high", title: "Time", value: candidate.timeConfidence.userFacingLabel, state: .default)
                placementLine(icon: "arrow.triangle.branch", title: "Impact", value: candidate.scheduleImpact.userFacingLabel, state: candidate.requiresUserApproval ? .warning : .default)
                placementLine(icon: "exclamationmark.triangle", title: "Conflict", value: candidate.conflictStatus.userFacingLabel, state: candidate.conflictStatus == .none ? .default : .warning)
                placementLine(icon: "lock", title: "Protected time", value: candidate.affectsProtectedTime ? "May be affected" : "Not checked yet", state: candidate.affectsProtectedTime ? .warning : .default)
                placementLine(icon: "calendar", title: "Calendar", value: candidate.requiresCalendarPermission ? "Permission required before any write" : "No calendar write yet", state: candidate.requiresCalendarPermission ? .warning : .default)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(candidate.approvalOptions) { option in
                        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                            Label(option.title, systemImage: "checkmark.circle")
                                .font(theme.typography.caption.weight(.semibold))
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(option.detail)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textTertiary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                EvidenceLabel(
                    candidate.receiptProjection.title,
                    detail: candidate.receiptProjection.summary,
                    source: "Time receipt",
                    state: .active,
                    context: .capture
                )
            }
            .accessibilityElement(children: .combine)
        }
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
                .accessibilityIdentifier("capture.placement-choice.\(choice.routeType.rawValue)")
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
