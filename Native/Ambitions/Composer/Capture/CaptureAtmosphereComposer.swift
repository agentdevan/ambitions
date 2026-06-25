import AmbitionsDesignSystem
import SwiftUI

struct CaptureComposerMutationProofContract: Equatable {
    let runtimeMutationID: String
    let visibleObjectMutationID: String
    let affectedObjectIDs: [String]
    let accessibilityAnnouncement: String
    let proofArtifactID: String
    let undoTargetID: String

    var submitHint: String {
        "Review after typing. Saving changes the local Capture object and keeps Undo available."
    }

    static let localSave = CaptureComposerMutationProofContract(
        runtimeMutationID: "capture.local-save",
        visibleObjectMutationID: "capture.object.saved",
        affectedObjectIDs: ["capture.draft", "capture.placement"],
        accessibilityAnnouncement: "Capture saved locally.",
        proofArtifactID: "capture.local-save.proof",
        undoTargetID: "capture.local-save.undo"
    )
}

struct CaptureAtmosphereComposerPresentation: Equatable {
    let isRouteRevealVisible: Bool
    let placementTitle: String
    let destinationLabel: String
    let privacyLabel: String
    let evidenceTitle: String
    let evidenceDetail: String
    let planInsertionTitle: String?
    let planInsertionDetail: String?
    let inputAlternatives: CaptureInputAlternativesPresentation
    let accessibilityValue: String
    let submitLabel: String

    init(
        text: String,
        routePreview: CaptureDraftRoutePreview?,
        error: String?,
        isSubmitEnabled: Bool
    ) {
        isRouteRevealVisible = false
        placementTitle = routePreview?.postInputStateTitle ?? (isSubmitEnabled ? "Ready to place" : "Needs placement")
        destinationLabel = routePreview?.destinationLabel ?? "Private intake"
        privacyLabel = routePreview?.privacyLabel ?? "Stored locally when saved"

        if let error {
            evidenceTitle = "Needs attention"
            evidenceDetail = error
        } else if let routePreview {
            evidenceTitle = routePreview.destinationLabel
            evidenceDetail = routePreview.consequenceLabel
        } else if isSubmitEnabled {
            evidenceTitle = "Ready to review"
            evidenceDetail = "Review opens first."
        } else {
            evidenceTitle = "Ready when you type"
            evidenceDetail = "The field waits without placeholder text or route pressure."
        }

        planInsertionTitle = routePreview?.planInsertionCandidate?.receiptProjection.title
        planInsertionDetail = routePreview?.planInsertionCandidate?.receiptProjection.summary

        inputAlternatives = CaptureInputAlternativesPresentation(
            isRouteRevealVisible: isRouteRevealVisible,
            isSubmitEnabled: isSubmitEnabled
        )
        accessibilityValue = [
            placementTitle,
            destinationLabel,
            privacyLabel,
            routePreview?.understoodLabel,
            routePreview?.suggestedPlacementLabel,
            routePreview?.mayAffectLabel,
            routePreview?.approvalNeededLabel,
            routePreview?.changeableLabels.joined(separator: ". "),
            routePreview?.safeFallbackLabel,
            routePreview?.consequenceLabel,
            planInsertionTitle,
            planInsertionDetail,
            error,
            inputAlternatives.accessibilityValue
        ]
        .compactMap { $0 }
        .joined(separator: ". ")
        submitLabel = isSubmitEnabled ? "Review capture" : "Review unavailable"
    }
}

struct CaptureInputAlternativesPresentation: Equatable {
    let title: String
    let voiceStatusLabel: String
    let voiceStatusDetail: String
    let motorStatusLabel: String
    let motorStatusDetail: String
    let reviewControlLabel: String

    init(isRouteRevealVisible: Bool, isSubmitEnabled: Bool) {
        title = "Input alternatives"
        voiceStatusLabel = "Keyboard dictation only"
        voiceStatusDetail = "Use typing or system dictation from the keyboard. Ambitions does not record audio here."
        motorStatusLabel = "Motor alternative"
        motorStatusDetail = "Use buttons and menus; no drag, swipe, or long press is required."
        if isRouteRevealVisible {
            reviewControlLabel = "After typing: route choices are visible buttons and stay editable."
        } else if isSubmitEnabled {
            reviewControlLabel = "After typing: review opens with visible buttons first."
        } else {
            reviewControlLabel = "Type first; review waits for text."
        }
    }

    var accessibilityValue: String {
        [
            title,
            voiceStatusLabel,
            voiceStatusDetail,
            motorStatusLabel,
            motorStatusDetail,
            reviewControlLabel
        ].joined(separator: ". ")
    }
}


struct CaptureAtmosphereComposerAccessibilityIDs: Equatable {
    let root: String
    let input: String
    let dictationButton: String
    let submitButton: String
    let error: String
    let inputAlternatives: String
    let placementPreviewStrip: String
    let placementChoicePrefix: String
    let placementInspectionSummary: String

    static let quickCapture = CaptureAtmosphereComposerAccessibilityIDs(
        root: "capture.composer",
        input: "capture.quick-input",
        dictationButton: "capture.quick-mic",
        submitButton: "capture.quick-submit",
        error: "capture.quick-error",
        inputAlternatives: "capture.input-alternatives",
        placementPreviewStrip: "capture.placement-preview",
        placementChoicePrefix: "capture.placement-choice.",
        placementInspectionSummary: "capture.placement.inspection-summary"
    )
}

struct CaptureAtmosphereComposer: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding var text: String

    let routePreview: CaptureDraftRoutePreview?
    let error: String?
    let isSubmitEnabled: Bool
    let onSubmit: () -> Void
    let onMicrophone: () -> Void
    let onRouteChoice: (SmartAttachmentRouteType) -> Void
    var mutationProofContract: CaptureComposerMutationProofContract = .localSave
    var accessibilityIDs: CaptureAtmosphereComposerAccessibilityIDs = .quickCapture
    var shouldAutoFocus = false

    private var presentation: CaptureAtmosphereComposerPresentation {
        CaptureAtmosphereComposerPresentation(
            text: text,
            routePreview: routePreview,
            error: error,
            isSubmitEnabled: isSubmitEnabled
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            composerInput

            if let error {
                Text(error)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.warning)
                    .accessibilityIdentifier(accessibilityIDs.error)
            }

            SpatialCaptureTeachingLine(isVisible: text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.top, theme.spacing.md)
        .padding(.bottom, theme.spacing.md)
        .stageMotionAnimation(
            DAVMotionPreset.receiptConfirmation.animation(theme: theme, reduceMotion: reduceMotion),
            value: presentation.isRouteRevealVisible
        )
        .accessibilityElement(children: .contain)
        .accessibilityValue(presentation.accessibilityValue)
    }

    private var inputAlternatives: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Label(presentation.inputAlternatives.title, systemImage: "figure.hand.circle")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)

            Label(
                presentation.inputAlternatives.voiceStatusLabel,
                systemImage: "mic.slash"
            )
            Text(presentation.inputAlternatives.voiceStatusDetail)
                .padding(.leading, 20)

            Label(
                presentation.inputAlternatives.motorStatusLabel,
                systemImage: "hand.tap"
            )
            Text(presentation.inputAlternatives.motorStatusDetail)
                .padding(.leading, 20)

            Label(presentation.inputAlternatives.reviewControlLabel, systemImage: "checkmark.seal")
        }
        .font(theme.typography.caption)
        .foregroundStyle(theme.colors.textSecondary)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(presentation.inputAlternatives.title)
        .accessibilityValue(presentation.inputAlternatives.accessibilityValue)
        .accessibilityIdentifier(accessibilityIDs.inputAlternatives)
    }

    private var composerInput: some View {
        let verticalLayout = dynamicTypeSize.isAccessibilitySize

        return Group {
            if verticalLayout {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    fieldCapsule
                    submitButton
                }
            } else {
                HStack(alignment: .bottom, spacing: theme.spacing.sm) {
                    fieldCapsule
                    submitButton
                }
            }
        }
    }

    private var fieldCapsule: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "text.cursor")
                .font(.system(size: theme.icon.smallSize, weight: .semibold))
                .foregroundStyle(text.isEmpty ? theme.colors.textTertiary : theme.colors.accentWarm)
                .accessibilityHidden(true)

            TextField("", text: $text, axis: .vertical)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4...8 : 2...6)
                .onSubmit {
                    if isSubmitEnabled {
                        onSubmit()
                    }
                }
                .accessibilityIdentifier(accessibilityIDs.input)
                .accessibilityLabel("Capture field")
                .accessibilityHint("Type or use iOS keyboard dictation. Review opens first.")
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? theme.spacing.lg : theme.spacing.md)
        .background(fieldBackground)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(text.isEmpty ? theme.colors.strokeSubtle : theme.colors.accentWarm, lineWidth: text.isEmpty ? 1 : 1.5)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var fieldBackground: some View {
        ZStack {
            ContextAtmosphereLayer(
                context: .capture,
                state: composerState,
                intensity: text.isEmpty ? 0.38 : 0.5
            )
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.92))
        }
    }

    private var submitButton: some View {
        Button(action: onSubmit) {
            Image(systemName: "arrow.right")
                .font(.system(size: theme.icon.smallSize, weight: .bold))
                .frame(width: 42, height: 42)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: isSubmitEnabled ? .selected : .disabled))
        .disabled(isSubmitEnabled == false)
        .accessibilityIdentifier(accessibilityIDs.submitButton)
        .accessibilityLabel(presentation.submitLabel)
        .accessibilityHint(isSubmitEnabled ? mutationProofContract.submitHint : "Type a thought first.")
    }

    private var composerState: LivingVisualState {
        if error != nil { return .stale }
        if routePreview != nil || isSubmitEnabled { return .active }
        return .empty
    }

    private var routeRevealTransition: AnyTransition {
        reduceMotion ? .opacity : .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        )
    }
}

private struct SpatialCaptureTeachingLine: View {
    @Environment(\.ambitionTheme) private var theme
    let isVisible: Bool

    var body: some View {
        if isVisible {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "sparkle.magnifyingglass")
                    .font(.system(size: theme.icon.smallSize, weight: .semibold))
                    .foregroundStyle(theme.colors.textSecondary)
                    .accessibilityHidden(true)
                Text("Type or dictate from the iOS keyboard. Review opens first.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityIdentifier("capture.first-run.spatial-teaching")
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Capture teaching")
            .accessibilityValue("Type or dictate from the iOS keyboard. Review opens first.")
        }
    }
}
