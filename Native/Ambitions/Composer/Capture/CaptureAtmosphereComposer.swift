import AmbitionsDesignSystem
import SwiftUI

struct CaptureComposerMutationProofContract: Equatable {
    let runtimeMutation: String
    let visibleStageMutation: String
    let accessibilityAnnouncement: String
    let proofArtifact: String

    var submitHint: String {
        [
            runtimeMutation,
            visibleStageMutation,
            accessibilityAnnouncement,
            proofArtifact
        ].joined(separator: ". ")
    }

    static let localSave = CaptureComposerMutationProofContract(
        runtimeMutation: "Saves the capture through the local Capture runtime",
        visibleStageMutation: "Updates the composer stage with the saved route",
        accessibilityAnnouncement: "Announces the saved capture result",
        proofArtifact: "Records a local capture proof artifact"
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
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        isRouteRevealVisible = routePreview != nil && trimmedText.isEmpty == false
        placementTitle = routePreview?.postInputStateTitle ?? (isSubmitEnabled ? "Ready to Place" : "Needs placement")
        destinationLabel = routePreview?.destinationLabel ?? "Private intake"
        privacyLabel = routePreview?.privacyLabel ?? "Stored locally when saved"

        if let error {
            evidenceTitle = "Needs attention"
            evidenceDetail = error
        } else if let routePreview {
            evidenceTitle = routePreview.receiptTitle
            evidenceDetail = routePreview.consequenceLabel
        } else if isSubmitEnabled {
            evidenceTitle = "Ready to Place"
            evidenceDetail = "Ambitions will suggest a route after you save."
        } else {
            evidenceTitle = "Needs placement"
            evidenceDetail = "Type one real thing; no routing pressure is added."
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
        submitLabel = isSubmitEnabled ? "Save capture" : "Save unavailable"
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
            reviewControlLabel = "After typing: save stays separate from route review."
        } else {
            reviewControlLabel = "Type first; placement waits for Save."
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
    let routeRevealStrip: String
    let routeChoicePrefix: String
    let routeInspectionSummary: String

    static let quickCapture = CaptureAtmosphereComposerAccessibilityIDs(
        root: "capture.composer",
        input: "capture.quick-input",
        dictationButton: "capture.quick-mic",
        submitButton: "capture.quick-submit",
        error: "capture.quick-error",
        inputAlternatives: "capture.input-alternatives",
        routeRevealStrip: "capture.route-reveal-strip",
        routeChoicePrefix: "capture.route-choice.",
        routeInspectionSummary: "capture.route-reveal.inspection-summary"
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
            if presentation.isRouteRevealVisible, let routePreview {
                CaptureRouteRevealStrip(
                    preview: routePreview,
                    onRouteChoice: onRouteChoice,
                    accessibilityIDs: accessibilityIDs
                )
                .transition(routeRevealTransition)
            }

            composerInput

            if let error {
                Text(error)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.warning)
                    .accessibilityIdentifier(accessibilityIDs.error)
            }

            if let planInsertionTitle = presentation.planInsertionTitle,
               let planInsertionDetail = presentation.planInsertionDetail {
                EvidenceLabel(
                    planInsertionTitle,
                    detail: planInsertionDetail,
                    source: "Time candidate",
                    state: composerState,
                    context: .capture
                )
            }

            EvidenceLabel(
                presentation.evidenceTitle,
                detail: presentation.evidenceDetail,
                source: "Capture composer",
                state: composerState,
                context: .capture
            )

            inputAlternatives
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.top, theme.spacing.sm)
        .padding(.bottom, theme.spacing.sm)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
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
            TextField("Where can this go?", text: $text, axis: .vertical)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2...5 : 1...3)
                .onSubmit {
                    if isSubmitEnabled {
                        onSubmit()
                    }
                }
                .accessibilityIdentifier(accessibilityIDs.input)
                .accessibilityLabel("Where can this go?")
                .accessibilityHint("Type a thought. Route suggestions appear after input.")

            Button {
                onMicrophone()
            } label: {
                Image(systemName: "mic.fill")
                    .font(.system(size: theme.icon.smallSize, weight: .semibold))
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.colors.textSecondary)
            .accessibilityIdentifier(accessibilityIDs.dictationButton)
            .accessibilityLabel("Keyboard dictation")
            .accessibilityHint("Focuses the field so you can use the iOS keyboard microphone. Ambitions does not record audio here.")
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
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
            Image(systemName: "plus")
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
