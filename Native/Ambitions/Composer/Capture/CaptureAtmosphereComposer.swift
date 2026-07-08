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
        "Review or save after typing. Undo stays available for the local change."
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
    let isPlacementPreviewVisible: Bool
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
        text _: String,
        routePreview: CaptureDraftRoutePreview?,
        error: String?,
        isSubmitEnabled: Bool
    ) {
        isPlacementPreviewVisible = routePreview != nil
        placementTitle = routePreview?.postInputStateTitle ?? (isSubmitEnabled ? "Ready to save" : "Ready when you type")
        destinationLabel = routePreview?.destinationLabel ?? "Open Field"
        privacyLabel = routePreview?.privacyLabel ?? "Stays on this device when saved"

        if let error {
            evidenceTitle = "Needs attention"
            evidenceDetail = error
        } else if let routePreview {
            evidenceTitle = "Where this fits"
            evidenceDetail = routePreview.consequenceLabel
        } else if isSubmitEnabled {
            evidenceTitle = "Ready to save"
            evidenceDetail = "Choose Review when you want to adjust where it belongs."
        } else {
            evidenceTitle = "Ready when you type"
            evidenceDetail = "The field waits without pressure."
        }

        planInsertionTitle = routePreview?.planInsertionCandidate?.receiptProjection.title
        planInsertionDetail = routePreview?.planInsertionCandidate?.receiptProjection.summary

        inputAlternatives = CaptureInputAlternativesPresentation(
            isPlacementPreviewVisible: isPlacementPreviewVisible,
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
            inputAlternatives.accessibilityValue,
        ]
        .compactMap { $0 }
        .joined(separator: ". ")
        submitLabel = isSubmitEnabled ? "Review capture" : "Review unavailable"
    }
}

struct CaptureInputAlternativesPresentation: Equatable {
    let title: String
    let typingStatusLabel: String
    let typingStatusDetail: String
    let motorStatusLabel: String
    let motorStatusDetail: String
    let reviewControlLabel: String

    init(isPlacementPreviewVisible: Bool, isSubmitEnabled: Bool) {
        title = "Input support"
        typingStatusLabel = "Typing"
        typingStatusDetail = "Use the field and standard keyboard tools."
        motorStatusLabel = "Motor alternative"
        motorStatusDetail = "Use buttons and menus; no drag, swipe, or long press is required."
        if isPlacementPreviewVisible {
            reviewControlLabel = "After typing: placement choices are visible buttons and stay editable."
        } else if isSubmitEnabled {
            reviewControlLabel = "After typing: Review opens with visible buttons."
        } else {
            reviewControlLabel = "Type first; Review waits for text."
        }
    }

    var accessibilityValue: String {
        [
            title,
            typingStatusLabel,
            typingStatusDetail,
            motorStatusLabel,
            motorStatusDetail,
            reviewControlLabel,
        ].joined(separator: ". ")
    }
}

struct CaptureAtmosphereComposerAccessibilityIDs: Equatable {
    let root: String
    let input: String
    let submitButton: String
    let error: String
    let inputAlternatives: String
    let placementPreviewStrip: String
    let placementChoicePrefix: String
    let placementInspectionSummary: String

    static let quickCapture = CaptureAtmosphereComposerAccessibilityIDs(
        root: "capture.composer",
        input: "capture.quick-input",
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
    @FocusState private var isInputFocused: Bool

    let routePreview: CaptureDraftRoutePreview?
    let error: String?
    let isSubmitEnabled: Bool
    let onSubmit: () -> Void
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
            value: presentation.isPlacementPreviewVisible
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
                presentation.inputAlternatives.typingStatusLabel,
                systemImage: "keyboard"
            )
            Text(presentation.inputAlternatives.typingStatusDetail)
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
            Image(systemName: "square.and.pencil")
                .font(.system(size: theme.icon.smallSize, weight: .semibold))
                .foregroundStyle(text.isEmpty ? theme.colors.textTertiary : theme.colors.accentWarm)
                .accessibilityHidden(true)

            TextField("", text: $text, axis: .vertical)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 4 ... 8 : 2 ... 6)
                .focused($isInputFocused)
                .submitLabel(.done)
                .onSubmit {
                    isInputFocused = false
                    if isSubmitEnabled {
                        onSubmit()
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isInputFocused = false
                        }
                        .accessibilityIdentifier("capture.keyboard.done")
                    }
                }
                .accessibilityIdentifier(accessibilityIDs.input)
                .accessibilityLabel("Capture field")
                .accessibilityHint("Write one real thing. Review opens before saving.")
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, dynamicTypeSize.isAccessibilitySize ? theme.spacing.lg : theme.spacing.md)
        .background(fieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(text.isEmpty ? theme.colors.strokeSubtle : theme.colors.accentWarm)
                .frame(width: text.isEmpty ? 1 : 2)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(text.isEmpty ? theme.colors.strokeSubtle.opacity(0.72) : theme.colors.accentWarm.opacity(0.72))
                .frame(height: 1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var fieldBackground: some View {
        ZStack {
            ContextAtmosphereLayer(
                context: .capture,
                state: composerState,
                intensity: text.isEmpty ? 0.22 : 0.36
            )
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(text.isEmpty ? 0.58 : 0.72))
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

    private var placementPreviewTransition: AnyTransition {
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
                Image(systemName: "scope")
                    .font(.system(size: theme.icon.smallSize, weight: .semibold))
                    .foregroundStyle(theme.colors.textSecondary)
                    .accessibilityHidden(true)
                Text("Write one real thing. Review opens before saving.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityIdentifier("capture.first-run.spatial-teaching")
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Capture teaching")
            .accessibilityValue("Write one real thing. Review opens before saving.")
        }
    }
}
