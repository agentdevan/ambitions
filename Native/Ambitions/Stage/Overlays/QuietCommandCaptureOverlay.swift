import AmbitionsDesignSystem
import SwiftUI

extension QuietCommandSheetView {
    var quickCaptureComposer: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            CaptureAtmosphereComposer(
                text: $captureText,
                routePreview: quickCaptureRoutePreview,
                error: quickCaptureErrorText,
                isSubmitEnabled: canSaveQuickCapture,
                onSubmit: {
                    Task { await saveCapture() }
                },
                onMicrophone: {
                    dictationStatusMessage = "Keyboard dictation ready. Use the iOS keyboard microphone; Ambitions does not record audio here."
                },
                onRouteChoice: { routeType in
                    selectedDraftRouteType = routeType
                },
                accessibilityIDs: CaptureAtmosphereComposerAccessibilityIDs(
                    root: "shell.overlay.quick-capture.composer",
                    input: "shell.overlay.quick-capture-field",
                    dictationButton: "shell.overlay.quick-capture.dictation-button",
                    submitButton: "shell.overlay.save-capture-button",
                    error: "shell.overlay.quick-capture.error",
                    inputAlternatives: "shell.overlay.quick-capture.input-alternatives",
                    routeRevealStrip: "shell.overlay.quick-capture.route-reveal",
                    routeChoicePrefix: "shell.overlay.quick-capture.route-choice.",
                    routeInspectionSummary: "shell.overlay.quick-capture.route-inspection"
                ),
                shouldAutoFocus: overlay.kind == .quietCommandSheet && overlay.presentationContext == .quickCapture
            )

            if captureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                Button("Open as Goal") {
                    onDismiss()
                    appContainer?.commandRouter.presentCreateGoal(source: overlay.entrySource, seedText: captureText, captureID: overlay.captureID)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                .accessibilityIdentifier("shell.overlay.open-as-goal-button")
            }

            statusMessage
        }
    }

    @ViewBuilder
    var statusMessage: some View {
        switch saveState {
        case .error(let message):
            Text(message)
                .font(theme.typography.caption)
                .foregroundStyle(theme.semanticAccent(for: .caution))
                .fixedSize(horizontal: false, vertical: true)
        case .saved(let message):
            Text(message)
                .font(theme.typography.caption)
                .foregroundStyle(theme.semanticAccent(for: .success))
        case .saving:
            Text("Saving locally.")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .accessibilityIdentifier("shell.overlay.quick-capture.status")
        case .idle:
            if let dictationStatusMessage {
                Text(dictationStatusMessage)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("shell.overlay.quick-capture.dictation-status")
            }
        }
    }

    var quickCaptureRoutePreview: CaptureDraftRoutePreview? {
        let rawText = captureText.trimmingCharacters(in: .whitespacesAndNewlines)
        return draftRouteService.makeDraftRoutePreview(
            for: rawText,
            sourceType: appShellCaptureSourceType(for: overlay.entrySource),
            sourceSurface: overlay.entrySource.displayTitle,
            selectedDraftRouteType: selectedDraftRouteType,
            localSourceLabel: "Local source: \(overlay.entrySource.displayTitle)"
        )
    }

    var quickCaptureErrorText: String? {
        if case .error(let message) = saveState {
            return message
        }
        return nil
    }

    var canSaveQuickCapture: Bool {
        captureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && saveState != .saving
    }

    @MainActor
    func saveCapture() async {
        guard let appContainer else { return }
        let rawText = captureText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard rawText.isEmpty == false else { return }
        let sourceType = appShellCaptureSourceType(for: overlay.entrySource)
        let decision = draftRouteService.draftRouteDecision(
            for: rawText,
            sourceType: sourceType,
            sourceSurface: overlay.entrySource.displayTitle,
            selectedDraftRouteType: selectedDraftRouteType
        )
        saveState = .saving
        do {
            let capture = try await appContainer.captureService.createCapture(
                decision.createCaptureRequest(rawText: rawText, sourceType: sourceType),
                now: .now
            )
            saveState = .saved("Saved locally as \(capture.route.title). Place it when ready.")
            captureText = ""
            selectedDraftRouteType = nil
        } catch {
            saveState = .error(error.localizedDescription)
        }
    }
}
