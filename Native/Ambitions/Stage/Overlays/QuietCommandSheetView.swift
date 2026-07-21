import AmbitionsDesignSystem
import SwiftUI

struct QuietCommandSheetView: View {
    @Environment(\.ambitionTheme) var theme

    let overlay: ShellOverlayState
    let actions: ShellOverlayActions
    let onDismiss: () -> Void

    @State var selectedIntent: ShellCommandIntent?
    @State var memoryQuery: String = ""
    @State var memoryResults: [MemoryLensResult] = []
    @State var isMemorySearchLoading = false
    @State var memoryStatusMessage: String?
    @FocusState var isMemoryFieldFocused: Bool

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
            memoryQuery = overlay.query
            if overlay.presentationContext == .recall {
                isMemoryFieldFocused = true
                Task { await refreshMemoryResults() }
            }
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
            captureComposerRedirect
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
                actions.presentCreateGoal(source: overlay.entrySource, seedText: overlay.query, captureID: overlay.captureID)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
            .accessibilityIdentifier("shell.command.action.new_goal")
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
                actions.selectToday(entryContext: .standard)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
            .accessibilityIdentifier("shell.command.action.quick_recovery")
        }
    }

    var focusPrompt: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Today will center the recommended step.")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Button("Start here") {
                onDismiss()
                actions.selectToday(entryContext: .stepSession)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
            .accessibilityIdentifier("shell.command.action.quick_focus")
        }
    }

    var timePrompt: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Open Time to see what the day can hold.")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Button("Open Time") {
                onDismiss()
                actions.route(to: .tab(.time), source: overlay.entrySource)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
            .accessibilityIdentifier("shell.command.action.open_week")
        }
    }

    var neutralPrompt: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Button("Capture") {
                onDismiss()
                actions.presentGlobalCapture(source: overlay.entrySource)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            .accessibilityIdentifier("shell.command.action.quick_capture")
            Button("Create Goal") {
                onDismiss()
                actions.presentCreateGoal(source: overlay.entrySource)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            .accessibilityIdentifier("shell.command.action.new_goal")
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
        case .quickCapture: "Open the full-screen composer."
        case .createGoal: "Open a draft before anything becomes active."
        case .recall: "Search local context."
        case .neutral: "Choose an action."
        case .recovery: "Return to Today without blame or silent changes."
        case .focus: "Center the recommended step."
        case .time: "Open Time."
        }
    }
}
