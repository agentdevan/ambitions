import AmbitionsDesignSystem
import SwiftUI

struct QuietCommandSheetView: View {
    @Environment(\.appContainer) var appContainer
    @Environment(\.ambitionTheme) var theme

    let overlay: ShellOverlayState
    let onDismiss: () -> Void

    @State var selectedIntent: ShellCommandIntent?
    @State var captureText: String = ""
    @State var selectedDraftRouteType: SmartAttachmentRouteType?
    @State var saveState: QuietCommandSaveState = .idle
    @State var dictationStatusMessage: String?
    @State var memoryQuery: String = ""
    @State var memoryResults: [MemoryLensResult] = []
    @State var isMemorySearchLoading = false
    @State var memoryStatusMessage: String?
    @FocusState var isMemoryFieldFocused: Bool

    let draftRouteService = CaptureDraftRouteService()

    var body: some View {
        Group {
            if overlay.kind == .memoryLens {
                memoryLensBody
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    dragHandle
                    header
                    commandContent
                }
                .padding(theme.spacing.xl)
            }
        }
        .presentationDetents(overlay.kind == .memoryLens ? [.height(560), .large] : [.large])
        .presentationDragIndicator(.hidden)
        .background(theme.colors.canvas)
        .onAppear {
            selectedIntent = overlay.intent
            captureText = overlay.query
            memoryQuery = overlay.query
            if overlay.presentationContext == .recall {
                isMemoryFieldFocused = true
                Task { await refreshMemoryResults() }
            }
        }
        .onChange(of: captureText) { _, newValue in
            if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                selectedDraftRouteType = nil
            }
            dictationStatusMessage = nil
        }
        .onChange(of: memoryQuery) { _, _ in
            guard overlay.presentationContext == .recall else { return }
            Task { await refreshMemoryResults() }
        }
    }

    var dragHandle: some View {
        Capsule()
            .fill(theme.colors.strokeSubtle)
            .frame(width: 42, height: 5)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }

    var header: some View {
        HStack(alignment: .top, spacing: theme.spacing.md) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(overlayTitle)
                    .font(theme.typography.title)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(overlaySubtitle)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.md)

            Button("Close", action: onDismiss)
                .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                .accessibilityIdentifier("shell.overlay.close-button")
        }
    }

    @ViewBuilder
    var commandContent: some View {
        switch overlay.presentationContext {
        case .quickCapture:
            quickCaptureComposer
        case .createGoal:
            createGoalPrompt
        case .recall:
            memoryPrompt
        case .neutral:
            neutralPrompt
        case .recovery:
            recoveryPrompt
        case .focus:
            focusPrompt
        case .time:
            timePrompt
        }
    }

    var createGoalPrompt: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Goals opens with your seed text and keeps the draft inspectable before anything becomes active.")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Button("Continue to Goal draft") {
                onDismiss()
                appContainer?.commandRouter.presentCreateGoal(source: overlay.entrySource, seedText: overlay.query, captureID: overlay.captureID)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
        }
    }

    var recoveryPrompt: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Return to Today with recovery visible. Nothing is moved or closed silently.")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Button("Open Today") {
                onDismiss()
                appContainer?.navigation.selectToday(entryContext: .standard)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
        }
    }

    var focusPrompt: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Today will center the recommended step and keep proof visible.")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Button("Start here") {
                onDismiss()
                appContainer?.navigation.selectToday(entryContext: .stepSession)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
        }
    }

    var timePrompt: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Open Time to inspect capacity, protected blocks, and schedule context.")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Button("Open Time") {
                onDismiss()
                appContainer?.commandRouter.route(to: .tab(.time), source: overlay.entrySource)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
        }
    }

    var neutralPrompt: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Button("Capture") {
                selectedIntent = .quickCapture
                captureText = ""
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            Button("Create Goal") {
                onDismiss()
                appContainer?.commandRouter.presentCreateGoal(source: overlay.entrySource)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
        }
    }

    var overlayTitle: String {
        overlay.intent?.title ?? fallbackTitle
    }

    var overlaySubtitle: String {
        overlay.intent?.subtitle ?? fallbackSubtitle
    }

    var fallbackTitle: String {
        switch overlay.kind {
        case .quietCommandSheet: "Quick action"
        case .memoryLens: "Search Ambitions"
        case .createGoal: "Create Goal"
        }
    }

    var fallbackSubtitle: String {
        switch overlay.presentationContext {
        case .quickCapture: "Write one thing. Save it here, place it when ready."
        case .createGoal: "Open a draft before anything becomes active."
        case .recall: "Inspect source-grounded context locally."
        case .neutral: "Choose a safe local action."
        case .recovery: "Return to Today without shame or silent changes."
        case .focus: "Center the recommended step."
        case .time: "Open Time as the scheduling source of truth."
        }
    }
}

enum QuietCommandSaveState: Equatable {
    case idle
    case saving
    case saved(String)
    case error(String)
}
