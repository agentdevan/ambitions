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
    @State private var isProposalPresented = false

    private let draftRouteService = CaptureDraftRouteService()

    private enum SaveState: Equatable {
        case idle
        case saving
        case saved(String)
        case error(String)

        var accessibilityLabel: String? {
            switch self {
            case .idle:
                nil
            case .saving:
                "Saving locally"
            case let .saved(message), let .error(message):
                message
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            closeRow
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    composer
                    if isProposalPresented, let routePreview {
                        CaptureProposalStage(
                            preview: routePreview,
                            isSaving: saveState == .saving,
                            onAccept: {
                                Task { await saveCapture() }
                            },
                            onChangeDestination: { routeType in
                                selectedDraftRouteType = routeType
                            },
                            onCancel: {
                                isProposalPresented = false
                            }
                        )
                    }
                    firstRunTeaching
                    statusMessage
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, dynamicTypeSize.isAccessibilitySize ? theme.spacing.sm : theme.spacing.xl)
                .padding(.bottom, theme.spacing.xxl)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.top, theme.spacing.md)
        .padding(.bottom, theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(theme.colors.canvas)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: saveState)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: routePreview)
        .onAppear {
            captureText = overlay.query
            selectedDraftRouteType = overlay.typedCaptureRoute?.kind.smartAttachmentRouteType
        }
        .onChange(of: captureText) { _, newValue in
            if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                selectedDraftRouteType = nil
                isProposalPresented = false
            }
            saveState = .idle
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AppShellCaptureAccessModel.activatedSeamAccessibilityLabel)
        .accessibilityHint(AppShellCaptureAccessModel.activatedSeamAccessibilityHint)
        .accessibilityAction(named: "Dismiss Capture") {
            onDismiss()
        }
        .accessibilityIdentifier("shell.activated-capture-seam")
    }

    private var closeRow: some View {
        HStack {
            Spacer()
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
        CaptureObjectView(
            text: $captureText,
            input: captureInputModel,
            onSubmit: {
                presentProposal()
            },
            onRouteChoice: { routeType in
                selectedDraftRouteType = routeType
                isProposalPresented = true
            },
            accessibilityIDs: CaptureAtmosphereComposerAccessibilityIDs(
                root: "shell.activated-capture.composer",
                input: "shell.activated-capture.input",
                submitButton: "shell.activated-capture.save-button",
                error: "shell.activated-capture.error",
                inputAlternatives: "shell.activated-capture.input-alternatives",
                placementPreviewStrip: "shell.activated-capture.placement-preview",
                placementChoicePrefix: "shell.activated-capture.placement-choice.",
                placementInspectionSummary: "shell.activated-capture.placement-inspection"
            ),
            shouldAutoFocus: true
        )
    }

    private var captureInputModel: CaptureInputModel {
        CaptureInputModel(
            text: captureText,
            routePreview: isProposalPresented ? routePreview : nil,
            error: errorText,
            presentationMode: .globalComposer,
            saveStateLabel: saveState.accessibilityLabel,
            isSaving: saveState == .saving
        )
    }

    @ViewBuilder
    private var firstRunTeaching: some View {
        if captureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "text.cursor")
                    .font(.system(size: theme.icon.smallSize, weight: .semibold))
                    .foregroundStyle(theme.colors.textSecondary)
                    .accessibilityHidden(true)
                Text("Start with the field. Review opens first.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityIdentifier("shell.activated-capture.first-run-teaching")
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Capture teaching")
            .accessibilityValue("Start with the field. Review opens first.")
        }
    }

    @ViewBuilder
    private var statusMessage: some View {
        switch saveState {
        case let .error(message):
            Text(message)
                .font(theme.typography.caption)
                .foregroundStyle(theme.semanticAccent(for: .caution))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("shell.activated-capture.status")
        case let .saved(message):
            Text(message)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.semanticAccent(for: .success))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("shell.activated-capture.status")
        case .saving:
            Text("Saving locally.")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .accessibilityIdentifier("shell.activated-capture.status")
        case .idle:
            EmptyView()
        }
    }

    private var routePreview: CaptureDraftRoutePreview? {
        let rawText = captureText.trimmingCharacters(in: .whitespacesAndNewlines)
        return draftRouteService.makeDraftRoutePreview(
            for: rawText,
            sourceType: sourceType,
            sourceSurface: sourceSurfaceLabel,
            selectedDraftRouteType: selectedDraftRouteType,
            localSourceLabel: "Started from \(overlay.entrySource.displayTitle)"
        )
    }

    private var errorText: String? {
        if case let .error(message) = saveState {
            return message
        }
        return nil
    }

    private var sourceType: CaptureSourceType {
        appShellCaptureSourceType(for: overlay.entrySource)
    }

    private func presentProposal() {
        let rawText = captureText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard rawText.isEmpty == false else { return }
        isProposalPresented = routePreview != nil
    }

    @MainActor
    private func saveCapture() async {
        guard let appContainer else { return }
        let rawText = captureText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard rawText.isEmpty == false else { return }
        let decision = draftRouteService.draftRouteDecision(
            for: rawText,
            sourceType: sourceType,
            sourceSurface: sourceSurfaceLabel,
            selectedDraftRouteType: selectedDraftRouteType
        )
        saveState = .saving
        do {
            _ = try await appContainer.captureService.createCapture(
                decision.createCaptureRequest(rawText: rawText, sourceType: sourceType),
                now: appContainer.clock.now
            )
            saveState = .saved("Saved locally.")
            selectedDraftRouteType = nil
            isProposalPresented = false
        } catch {
            saveState = .error(error.localizedDescription)
        }
    }

    private var sourceSurfaceLabel: String {
        guard let typedRoute = overlay.typedCaptureRoute else {
            return overlay.entrySource.displayTitle
        }

        var parts = [overlay.entrySource.displayTitle, typedRoute.kind.accessibleDestinationLabel]
        if let lifeAreaID = typedRoute.context.lifeAreaID {
            parts.append("area \(lifeAreaID)")
        }
        if let goalID = typedRoute.context.goalID {
            parts.append("goal \(goalID)")
        }
        return parts.joined(separator: " / ")
    }
}
