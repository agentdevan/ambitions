import AmbitionsDesignSystem
import SwiftUI

enum AppShellHeaderPosture: String, Sendable {
    case execution
    case direction
    case shaping
    case reflection
    case utility

    var title: String {
        switch self {
        case .execution: "Execution"
        case .direction: "Direction"
        case .shaping: "Shaping"
        case .reflection: "Reflection"
        case .utility: "Utility"
        }
    }

    var modeLens: AmbitionModeLens {
        switch self {
        case .execution: .focus
        case .direction: .focus
        case .shaping: .plan
        case .reflection: .review
        case .utility: .focus
        }
    }

    var ambientStatus: AmbitionAmbientStatus {
        switch self {
        case .execution: .protected
        case .direction: .steady
        case .shaping: .tight
        case .reflection: .clear
        case .utility: .steady
        }
    }

    var systemImage: String {
        switch self {
        case .execution: "bolt.fill"
        case .direction: "target"
        case .shaping: "calendar.badge.clock"
        case .reflection: "chart.line.uptrend.xyaxis"
        case .utility: "slider.horizontal.3"
        }
    }

    var continuityMessage: String {
        switch self {
        case .execution:
            "Today keeps one important step in view."
        case .direction:
            "Goals keeps direction connected to the next step."
        case .shaping:
            "Time shapes the week only with confirmation."
        case .reflection:
            "Reviews carry proof forward without changing plans silently."
        case .utility:
            "You keeps controls, memory, and privacy visible."
        }
    }
}

struct AppShellHeaderButton {
    let title: String
    let systemImage: String
    let accessibilityIdentifier: String
    let action: () -> Void
}

struct AppShellScaffold<Content: View>: View {
    let title: String
    let subtitle: String?
    let posture: AppShellHeaderPosture
    let backButtonAccessibilityIdentifier: String?
    let onBack: (() -> Void)?
    let trailingButtons: [AppShellHeaderButton]
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        posture: AppShellHeaderPosture,
        backButtonAccessibilityIdentifier: String? = nil,
        onBack: (() -> Void)? = nil,
        trailingButtons: [AppShellHeaderButton] = [],
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.posture = posture
        self.backButtonAccessibilityIdentifier = backButtonAccessibilityIdentifier
        self.onBack = onBack
        self.trailingButtons = trailingButtons
        self.content = content()
    }

    var body: some View {
        content
            .safeAreaInset(edge: .top, spacing: 0) {
                AppShellHeaderRail(
                    title: title,
                    subtitle: subtitle,
                    posture: posture,
                    backButtonAccessibilityIdentifier: backButtonAccessibilityIdentifier,
                    onBack: onBack,
                    trailingButtons: trailingButtons
                )
            }
            .toolbar(.hidden, for: .navigationBar)
    }
}

private struct AppShellHeaderRail: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let subtitle: String?
    let posture: AppShellHeaderPosture
    let backButtonAccessibilityIdentifier: String?
    let onBack: (() -> Void)?
    let trailingButtons: [AppShellHeaderButton]

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: theme.spacing.md) {
                if let onBack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: theme.icon.smallSize, weight: .semibold))
                            .foregroundStyle(theme.colors.textPrimary)
                            .frame(width: 38, height: 38)
                            .background(Circle().fill(theme.colors.surfaceOverlay))
                            .overlay(Circle().stroke(theme.colors.strokeSubtle, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier(backButtonAccessibilityIdentifier ?? "shell.header.back-button")
                    .accessibilityLabel("Back")
                } else if posture != .execution {
                    Circle()
                        .fill(theme.shell.activeTabBackground)
                        .overlay(
                            Text("A")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.shell.activeTabForeground)
                        )
                        .overlay(
                            Circle()
                                .stroke(theme.shell.activeTabForeground.opacity(0.34), lineWidth: 1)
                        )
                        .frame(width: 38, height: 38)
                        .accessibilityHidden(true)
                }

                if posture != .execution || onBack != nil {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                            .accessibilityIdentifier("shell.header.title")

                        Text(headerSubtitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
                            .truncationMode(.tail)
                            .accessibilityIdentifier("shell.header.subtitle")
                    }
                    .layoutPriority(2)
                } else {
                    Spacer(minLength: 0)
                }

                Spacer(minLength: theme.spacing.sm)

                HStack(spacing: theme.spacing.xs) {
                    ForEach(Array(trailingButtons.enumerated()), id: \.offset) { entry in
                        let button = entry.element
                        Button(action: button.action) {
                            Label(button.title, systemImage: button.systemImage)
                                .labelStyle(.iconOnly)
                                .frame(width: posture == .execution ? 34 : 36, height: posture == .execution ? 34 : 36)
                        }
                        .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                        .accessibilityIdentifier(button.accessibilityIdentifier)
                        .accessibilityLabel(button.title)
                    }
                }
                .layoutPriority(1)
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.top, posture == .execution ? theme.spacing.xs : theme.spacing.sm)
            .padding(.bottom, posture == .execution ? theme.spacing.xs : theme.spacing.sm)
            .background(posture == .execution ? theme.colors.canvas.opacity(0.001) : theme.shell.headerMaterial)

            if posture != .execution {
                AmbitionContinuityRibbon(
                    message: posture.continuityMessage,
                    status: posture.ambientStatus
                )
                .padding(.horizontal, theme.spacing.lg)
                .padding(.bottom, theme.spacing.sm)
                .accessibilityIdentifier("shell.continuity-ribbon")

                Rectangle()
                    .fill(theme.shell.divider)
                    .frame(height: 1)
            }
        }
        .background(posture == .execution ? theme.colors.canvas.opacity(0.001) : theme.shell.headerMaterial)
        .shadow(color: posture == .execution ? .clear : theme.depth.resting.color, radius: theme.mode == .dark ? 14 : 10, x: 0, y: 6)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Shell header")
        .accessibilityIdentifier("shell.header.rail")
    }

    private var headerSubtitle: String {
        guard let subtitle else { return posture.title }
        return "\(subtitle) · \(posture.modeLens.title)"
    }
}

struct AppShellOverlayView: View {
    let overlay: ShellOverlayState
    let onDismiss: () -> Void
    let onGoalCreated: (ShellOverlayState, CreateGoalResponse) -> Void

    var body: some View {
        switch overlay.kind {
        case .quietCommandSheet:
            QuietCommandSheetView(overlay: overlay, onDismiss: onDismiss)
        case .memoryLens:
            MemoryLensOverlayView(overlay: overlay, onDismiss: onDismiss)
        case .createGoal:
            NavigationStack {
                CreateGoalScreen(
                    viewModel: CreateGoalViewModel(
                        title: overlay.query,
                        entrySource: overlay.entrySource,
                        captureID: overlay.captureID
                    )
                ) { response in
                    onGoalCreated(overlay, response)
                }
            }
        }
    }
}

private struct QuietCommandSheetView: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var isCaptureFieldFocused: Bool

    let overlay: ShellOverlayState
    let onDismiss: () -> Void

    @State private var selectedIntent: ShellCommandIntent?
    @State private var captureText: String = ""
    @State private var saveState: SaveState = .idle

    private enum SaveState: Equatable {
        case idle
        case saving
        case saved(String)
        case failed(String)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            Capsule()
                .fill(theme.colors.strokeSubtle)
                .frame(width: 42, height: 5)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)

            HStack(alignment: .top, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(overlay.title)
                        .font(theme.typography.title)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(overlay.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.md)

                Button("Close", action: onDismiss)
                    .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                    .accessibilityIdentifier("shell.overlay.close-button")
            }

            commandContent
        }
        .padding(theme.spacing.xl)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .background(theme.colors.canvas)
        .onAppear {
            selectedIntent = overlay.intent
            captureText = overlay.query
            isCaptureFieldFocused = overlay.kind == .quietCommandSheet
        }
    }

    @ViewBuilder
    private var commandContent: some View {
        switch overlay.presentationContext {
        case .quickCapture:
            quickCaptureComposer
        case .createGoal:
            createGoalPrompt
        case .recall:
            memoryPrompt
        case .neutral:
            neutralPrompt
        }
    }

    private var quickCaptureComposer: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            TextField("Capture one thing…", text: $captureText, axis: .vertical)
                .focused($isCaptureFieldFocused)
                .lineLimit(3...6)
                .textFieldStyle(.plain)
                .font(theme.typography.body)
                .padding(theme.spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .fill(theme.colors.surfaceOverlay)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                )
                .accessibilityIdentifier("shell.overlay.quick-capture-field")

            HStack(spacing: theme.spacing.sm) {
                Button {
                    Task { await saveCapture() }
                } label: {
                    Label(saveButtonTitle, systemImage: "tray.and.arrow.down.fill")
                }
                .disabled(captureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || saveState == .saving)
                .buttonStyle(AmbitionPressableButtonStyle(state: saveState == .saved("Saved") ? .success : .selected))
                .accessibilityIdentifier("shell.overlay.save-capture-button")

                Button("Make Goal") {
                    onDismiss()
                    appContainer?.commandRouter.presentCreateGoal(source: overlay.entrySource, seedText: captureText, captureID: overlay.captureID)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            }

            if case let .failed(message) = saveState {
                Text(message)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.semanticAccent(for: .warning))
                    .fixedSize(horizontal: false, vertical: true)
            } else if case let .saved(message) = saveState {
                Text(message)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.semanticAccent(for: .success))
            }
        }
    }

    private var createGoalPrompt: some View {
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

    private var memoryPrompt: some View {
        Text("Memory Lens is local-first inspection. It shows what Ambitions knows without exposing raw activity logs.")
            .font(theme.typography.body)
            .foregroundStyle(theme.colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var neutralPrompt: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Button("Capture") {
                selectedIntent = .quickCapture
                captureText = ""
                isCaptureFieldFocused = true
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            Button("Create Goal") {
                onDismiss()
                appContainer?.commandRouter.presentCreateGoal(source: overlay.entrySource)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
        }
    }

    private var saveButtonTitle: String {
        switch saveState {
        case .idle:
            "Save"
        case .saving:
            "Saving…"
        case .saved:
            "Saved"
        case .failed:
            "Try again"
        }
    }

    @MainActor
    private func saveCapture() async {
        guard let appContainer else { return }
        let rawText = captureText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard rawText.isEmpty == false else { return }
        saveState = .saving
        do {
            _ = try await appContainer.captureService.createCapture(
                CreateCaptureRequest(rawText: rawText, sourceType: .todayQuickCapture),
                now: .now
            )
            saveState = .saved("Saved to Capture. Nothing else changed.")
            captureText = ""
        } catch {
            saveState = .failed(error.localizedDescription)
        }
    }
}
