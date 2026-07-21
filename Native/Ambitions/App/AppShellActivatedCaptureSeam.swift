import AmbitionsDesignSystem
import AmbitionsTimeFoundation
import SwiftUI

struct ActivatedCaptureCommandRequest: Sendable {
    let draftID: String
    let text: String
    let goalID: String?
    let captureID: String?
    let source: ShellCommandEntrySource
    let selectedCaptureRouteType: SmartAttachmentRouteType
}

@MainActor
struct ActivatedCaptureCommand {
    private let commandRouter: any ShellCommandRouting
    private let clock: any AmbitionsClock

    init(commandRouter: any ShellCommandRouting, clock: any AmbitionsClock) {
        self.commandRouter = commandRouter
        self.clock = clock
    }

    func execute(_ request: ActivatedCaptureCommandRequest) async -> ShellCommandExecutionResult {
        await commandRouter.execute(
            intent: .quickCapture,
            text: request.text,
            goalID: request.goalID,
            captureID: request.captureID,
            source: request.source,
            selectedCaptureRouteType: request.selectedCaptureRouteType,
            draftID: request.draftID,
            now: clock.now
        )
    }
}

struct AppShellActivatedCaptureSeam: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let overlay: ShellOverlayState
    let command: ActivatedCaptureCommand
    let onDismiss: () -> Void

    @State private var captureText: String = ""
    @State private var draftID = DomainIdentifier.prefixed("shell.capture.draft")
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
            captureHeader
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
                                updateSelectedDraftRoute(routeType)
                            },
                            onCancel: {
                                isProposalPresented = false
                            }
                        )
                    }
                    statusMessage
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, dynamicTypeSize.isAccessibilitySize ? theme.spacing.sm : theme.spacing.md)
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
            draftID = DomainIdentifier.prefixed("shell.capture.draft")
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

    private var captureHeader: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            Text("Capture")
                .font(theme.typography.titleCompact)
                .foregroundStyle(theme.colors.textPrimary)
            Text("Private field. Review before anything is saved.")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Capture")
        .accessibilityValue("Private field. Review before anything is saved.")
        .accessibilityIdentifier("shell.activated-capture.header")
    }

    private var composer: some View {
        CaptureObjectView(
            text: $captureText,
            input: captureInputModel,
            onSubmit: {
                presentProposal()
            },
            onRouteChoice: { routeType in
                updateSelectedDraftRoute(routeType)
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
            saveStateLabel: saveState.accessibilityLabel.map(CaptureCopyPolicy.primaryDisplayLabel),
            isSaving: saveState == .saving
        )
    }

    @ViewBuilder
    private var statusMessage: some View {
        switch saveState {
        case let .error(message):
            Text(displayCaptureStatus(message))
                .font(theme.typography.caption)
                .foregroundStyle(theme.semanticAccent(for: .caution))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("shell.activated-capture.status")
        case let .saved(message):
            Text(displayCaptureStatus(message))
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
            return displayCaptureStatus(message)
        }
        return nil
    }

    private func displayCaptureStatus(_ message: String) -> String {
        CaptureCopyPolicy.primaryDisplayLabel(message)
    }

    private var sourceType: CaptureSourceType {
        appShellCaptureSourceType(for: overlay.entrySource)
    }

    private func presentProposal() {
        let rawText = captureText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard rawText.isEmpty == false else { return }
        isProposalPresented = routePreview != nil
    }

    private func updateSelectedDraftRoute(_ routeType: SmartAttachmentRouteType) {
        guard routeType != selectedDraftRouteType else { return }
        selectedDraftRouteType = routeType
        draftID = DomainIdentifier.prefixed("shell.capture.draft")
    }

    @MainActor
    private func saveCapture() async {
        let rawText = captureText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard rawText.isEmpty == false else { return }
        let decision = draftRouteService.draftRouteDecision(
            for: rawText,
            sourceType: sourceType,
            sourceSurface: sourceSurfaceLabel,
            selectedDraftRouteType: selectedDraftRouteType
        )
        saveState = .saving
        let result = await command.execute(ActivatedCaptureCommandRequest(
            draftID: draftID,
            text: rawText,
            goalID: overlay.goalID,
            captureID: overlay.captureID,
            source: overlay.entrySource,
            selectedCaptureRouteType: selectedDraftRouteType ?? decision.routeType
        ))

        if let title = result.title, result.createdCaptureID != nil {
            saveState = .saved(title)
            draftID = DomainIdentifier.prefixed("shell.capture.draft")
            selectedDraftRouteType = nil
            isProposalPresented = false
        } else {
            saveState = .error(result.title ?? "Capture could not be saved.")
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
