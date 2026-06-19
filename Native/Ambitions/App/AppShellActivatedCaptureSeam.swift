import AmbitionsDesignSystem
import SwiftUI

struct AppShellActivatedCaptureSeam: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let overlay: ShellOverlayState
    let onDismiss: () -> Void
    let onCreateGoal: (String, String?) -> Void

    @State private var captureText: String = ""
    @State private var saveState: SaveState = .idle
    @State private var selectedDraftRouteType: SmartAttachmentRouteType?
    @State private var routeReceiptMessage: String?
    @State private var dictationStatusMessage: String?

    private let draftRouteService = CaptureDraftRouteService()

    private enum SaveState: Equatable {
        case idle
        case saving
        case saved(String)
        case error(String)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    stateProofStrip
                    composer
                    makeGoalButton
                    sourceTrust
                    statusMessage
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.top, theme.spacing.md)
        .padding(.bottom, theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(maxHeight: seamMaxHeight)
        .background(theme.colors.canvas)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.shell.divider)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.shell.divider.opacity(0.82))
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: saveState)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: routePreview)
        .onAppear {
            captureText = overlay.query
        }
        .onChange(of: captureText) { _, newValue in
            if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                selectedDraftRouteType = nil
                routeReceiptMessage = nil
            }
            dictationStatusMessage = nil
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AppShellCaptureAccessModel.activatedSeamAccessibilityLabel)
        .accessibilityHint(AppShellCaptureAccessModel.activatedSeamAccessibilityHint)
        .accessibilityIdentifier("shell.activated-capture-seam")
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("Open Field")
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text("\(overlay.entrySource.displayTitle) - review before save")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            Spacer(minLength: theme.spacing.sm)

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: theme.icon.smallSize, weight: .semibold))
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.colors.textSecondary)
            .accessibilityLabel("Close Capture")
            .accessibilityIdentifier("shell.activated-capture.close-button")
        }
    }

    private var composer: some View {
        CaptureAtmosphereComposer(
            text: $captureText,
            routePreview: routePreview,
            error: errorText,
            isSubmitEnabled: canSave,
            onSubmit: {
                Task { await saveCapture() }
            },
            onMicrophone: {
                dictationStatusMessage = "Keyboard dictation ready. Use the iOS keyboard microphone; Ambitions does not record audio here."
            },
            onRouteChoice: { routeType in
                selectedDraftRouteType = routeType
                routeReceiptMessage = "Route set to \(routeType.userFacingLabel). Save writes that route locally."
            },
            accessibilityIDs: CaptureAtmosphereComposerAccessibilityIDs(
                root: "shell.activated-capture.composer",
                input: "shell.activated-capture.input",
                dictationButton: "shell.activated-capture.dictation-button",
                submitButton: "shell.activated-capture.save-button",
                error: "shell.activated-capture.error",
                inputAlternatives: "shell.activated-capture.input-alternatives",
                routeRevealStrip: "shell.activated-capture.route-reveal",
                routeChoicePrefix: "shell.activated-capture.route-choice.",
                routeInspectionSummary: "shell.activated-capture.route-inspection"
            ),
            shouldAutoFocus: true
        )
    }

    private var stateProofStrip: some View {
        HStack(spacing: theme.spacing.xs) {
            proofChip(
                title: "Activated",
                systemImage: "sparkles",
                accessibilityIdentifier: "shell.activated-capture.state.activated"
            )
            proofChip(
                title: "Keyboard",
                systemImage: "keyboard",
                accessibilityIdentifier: "shell.activated-capture.state.keyboard"
            )
            proofChip(
                title: "Local read",
                systemImage: "lock",
                accessibilityIdentifier: "shell.activated-capture.state.local-classification"
            )
            if reduceMotion {
                proofChip(
                    title: "Static",
                    systemImage: "figure.walk.motion.trianglebadge.exclamationmark",
                    accessibilityIdentifier: "shell.activated-capture.state.reduce-motion"
                )
            }
        }
        .font(theme.typography.micro.weight(.semibold))
        .foregroundStyle(theme.colors.textSecondary)
        .accessibilityElement(children: .contain)
    }

    private func proofChip(title: String, systemImage: String, accessibilityIdentifier: String) -> some View {
        Label(title, systemImage: systemImage)
            .lineLimit(1)
            .minimumScaleFactor(0.82)
            .padding(.horizontal, theme.spacing.xs)
            .padding(.vertical, theme.spacing.xxxs)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                    .fill(theme.colors.surfaceOverlay.opacity(0.72))
            )
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier(accessibilityIdentifier)
    }

    @ViewBuilder
    private var makeGoalButton: some View {
        if captureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            Button {
                onCreateGoal(captureText, overlay.captureID)
            } label: {
                Label("Open as Goal", systemImage: "target")
                    .frame(minHeight: 42)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            .accessibilityLabel("Open as Goal")
            .accessibilityHint("Opens a goal draft using this Capture text. No goal is created until you confirm.")
            .accessibilityIdentifier("shell.activated-capture.make-goal-button")
        }
    }

    private var sourceTrust: some View {
        Text("Saved on this device. Source, receipt, and route stay inspectable.")
            .font(theme.typography.micro)
            .foregroundStyle(theme.colors.textTertiary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("shell.activated-capture.source-trust")
    }

    @ViewBuilder
    private var statusMessage: some View {
        if let routeReceiptMessage {
            Text(routeReceiptMessage)
                .font(theme.typography.caption)
                .foregroundStyle(theme.semanticAccent(for: .success))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("shell.activated-capture.correction-receipt")
        }

        switch saveState {
        case let .error(message):
            Text(message)
                .font(theme.typography.caption)
                .foregroundStyle(theme.semanticAccent(for: .caution))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("shell.activated-capture.status")
        case let .saved(message):
            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(message)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.semanticAccent(for: .success))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("shell.activated-capture.status")
                Text("Captured locally")
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.semanticAccent(for: .success))
                    .accessibilityIdentifier("shell.activated-capture.state.captured-locally")
            }
        case .saving:
            Text("Saving locally before the receipt is written.")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .accessibilityIdentifier("shell.activated-capture.status")
        case .idle:
            if let dictationStatusMessage {
                Text(dictationStatusMessage)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("shell.activated-capture.dictation-status")
            }
        }
    }

    private var routePreview: CaptureDraftRoutePreview? {
        let rawText = captureText.trimmingCharacters(in: .whitespacesAndNewlines)
        return draftRouteService.makeDraftRoutePreview(
            for: rawText,
            sourceType: sourceType,
            sourceSurface: overlay.entrySource.displayTitle,
            selectedDraftRouteType: selectedDraftRouteType,
            localSourceLabel: "Local source: \(overlay.entrySource.displayTitle)"
        )
    }

    private var errorText: String? {
        if case let .error(message) = saveState {
            return message
        }
        return nil
    }

    private var canSave: Bool {
        captureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && saveState != .saving
    }

    private var sourceType: CaptureSourceType {
        appShellCaptureSourceType(for: overlay.entrySource)
    }

    private var seamMaxHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 540 : 430
    }

    @MainActor
    private func saveCapture() async {
        guard let appContainer else { return }
        let rawText = captureText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard rawText.isEmpty == false else { return }
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
            saveState = .saved("Saved locally as \(capture.route.title). Receipt path stays inspectable.")
            captureText = ""
            selectedDraftRouteType = nil
        } catch {
            saveState = .error(error.localizedDescription)
        }
    }
}
