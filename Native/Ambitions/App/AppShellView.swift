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

    var systemImage: String {
        switch self {
        case .execution: "bolt.fill"
        case .direction: "target"
        case .shaping: "calendar.badge.clock"
        case .reflection: "chart.line.uptrend.xyaxis"
        case .utility: "slider.horizontal.3"
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

    let title: String
    let subtitle: String?
    let posture: AppShellHeaderPosture
    let backButtonAccessibilityIdentifier: String?
    let onBack: (() -> Void)?
    let trailingButtons: [AppShellHeaderButton]

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: theme.spacing.md) {
                HStack(alignment: .center, spacing: theme.spacing.sm) {
                    if let onBack {
                        Button(action: onBack) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: theme.icon.smallSize, weight: .semibold))
                                .foregroundStyle(theme.colors.textPrimary)
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(theme.colors.surfaceOverlay)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier(backButtonAccessibilityIdentifier ?? "shell.header.back-button")
                    }

                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                            .accessibilityIdentifier("shell.header.title")

                        HStack(spacing: theme.spacing.xs) {
                            TagPill(posture.title, icon: posture.systemImage, state: .default)
                            if let subtitle {
                                Text(subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .lineLimit(1)
                                    .accessibilityIdentifier("shell.header.subtitle")
                            }
                        }
                    }
                }

                Spacer(minLength: theme.spacing.sm)

                HStack(spacing: theme.spacing.xs) {
                    ForEach(Array(trailingButtons.enumerated()), id: \.offset) { entry in
                        let button = entry.element
                        Button(action: button.action) {
                            Label(button.title, systemImage: button.systemImage)
                                .labelStyle(.iconOnly)
                                .frame(width: 36, height: 36)
                        }
                        .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                        .accessibilityIdentifier(button.accessibilityIdentifier)
                        .accessibilityLabel(button.title)
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.top, theme.spacing.sm)
            .padding(.bottom, theme.spacing.sm)
            .background(theme.surfaces.overlayGradient.opacity(theme.surfaces.backgroundBlurOpacity))

            Rectangle()
                .fill(theme.colors.strokeSubtle)
                .frame(height: 1)
        }
        .background(theme.surfaces.overlayGradient.opacity(theme.surfaces.backgroundBlurOpacity))
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
    @State private var captureText: String
    @State private var executionMessage: String?

    init(overlay: ShellOverlayState, onDismiss: @escaping () -> Void) {
        self.overlay = overlay
        self.onDismiss = onDismiss
        _selectedIntent = State(initialValue: overlay.intent == .quickCapture ? .quickCapture : nil)
        _captureText = State(initialValue: overlay.query)
    }

    var body: some View {
        NavigationStack {
            FeatureScaffoldView(
                eyebrow: "Command",
                title: "Command",
                subtitle: "One shell-owned place to capture, create, recover, reshape, and open canonical destinations."
            ) {
                if let executionMessage {
                    AppCard(state: .warning) {
                        Text(executionMessage)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textPrimary)
                            .padding(theme.spacing.lg)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .transition(.ambitionTransition(.correction))
                }

                quickCaptureComposer

                AppCard {
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        SectionHeader(
                            title: "Create and shift",
                            subtitle: "Start small, keep routing canonical, and let the shell own the entry."
                        )

                        commandOption(for: .quickCapture)
                        commandOption(for: .newGoal)
                        commandOption(for: .quickPlanPatch)
                        commandOption(for: .quickRecovery)
                        commandOption(for: .quickFocus)
                    }
                    .padding(theme.spacing.lg)
                }

                AppCard {
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        SectionHeader(
                            title: "Open and recall",
                            subtitle: "Open goals, the current week, captures, or the bounded recall surface."
                        )

                        commandOption(for: .openGoal)
                        commandOption(for: .openWeek)
                        commandOption(for: .openCapture)
                        commandOption(for: .memoryLens)
                    }
                    .padding(theme.spacing.lg)
                }

                commandHistoryCard
            }
            .navigationTitle("Command")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: onDismiss)
                        .accessibilityIdentifier("shell.overlay.dismiss-button")
                }
            }
        }
        .animation(.ambitionMotion(.panelEntry, theme: theme, reduceMotion: reduceMotion), value: selectedIntent?.rawValue)
        .task {
            if selectedIntent == .quickCapture {
                isCaptureFieldFocused = true
            }
        }
    }

    @ViewBuilder
    private var commandHistoryCard: some View {
        let history = Array(container.navigation.recentCommandHistory.prefix(3))
        if history.isEmpty == false {
            AppCard {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    SectionHeader(
                        title: "Recent return paths",
                        subtitle: "Small reminders of where command and recall last carried context."
                    )

                    ForEach(history) { entry in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            TagPill(entry.sourceLabel, state: .default)
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(entry.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text("\(entry.subtitle) Returned to \(entry.destinationLabel).")
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                        }
                    }
                }
                .padding(theme.spacing.lg)
            }
            .accessibilityIdentifier("shell.command.history-card")
        }
    }

    @ViewBuilder
    private var quickCaptureComposer: some View {
        if selectedIntent == .quickCapture {
            AppCard(state: .selected) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    SectionHeader(
                        title: "Quick capture",
                        subtitle: "Save one thought into the canonical captures inbox without leaving the shell-owned compose path."
                    )

                    TextField("What needs to be remembered?", text: $captureText)
                        .textFieldStyle(.roundedBorder)
                        .focused($isCaptureFieldFocused)
                        .accessibilityIdentifier("shell.command.capture-field")

                    Button {
                        Task { await submitCapture() }
                    } label: {
                        Text("Capture")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                    .accessibilityIdentifier("shell.command.submit-capture-button")
                }
                .padding(theme.spacing.lg)
            }
            .transition(.ambitionPanel)
        }
    }

    @ViewBuilder
    private func commandOption(for intent: ShellCommandIntent) -> some View {
        Button {
            handleSelection(intent)
        } label: {
            HStack(alignment: .top, spacing: theme.spacing.md) {
                Image(systemName: intent.systemImage)
                    .font(.system(size: theme.icon.mediumSize, weight: .semibold))
                    .foregroundStyle(theme.colors.accentWarm)
                    .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(intent.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(intent.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: theme.spacing.sm)

                Image(systemName: "chevron.right")
                    .font(.system(size: theme.icon.smallSize, weight: .semibold))
                    .foregroundStyle(theme.colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, theme.spacing.xxs)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("shell.command.action.\(intent.rawValue)")
    }

    private func handleSelection(_ intent: ShellCommandIntent) {
        executionMessage = nil

        switch intent {
        case .quickCapture:
            selectedIntent = .quickCapture
            isCaptureFieldFocused = true
        case .newGoal:
            container.commandRouter.presentCreateGoal(source: overlay.entrySource, seedText: "", captureID: nil)
        case .openGoal:
            container.commandRouter.presentMemoryLens(
                intent: .openGoal,
                source: overlay.entrySource,
                presentationContext: .recall,
                query: "",
                goalID: nil,
                captureID: nil
            )
        case .openCapture:
            container.commandRouter.presentMemoryLens(
                intent: .openCapture,
                source: overlay.entrySource,
                presentationContext: .recall,
                query: "",
                goalID: nil,
                captureID: nil
            )
        case .memoryLens:
            container.commandRouter.presentMemoryLens(
                intent: .memoryLens,
                source: overlay.entrySource,
                presentationContext: .recall,
                query: "",
                goalID: nil,
                captureID: nil
            )
        case .quickPlanPatch, .openWeek:
            container.navigation.selectTab(.plan)
        case .quickRecovery:
            container.navigation.queueTodaySelectionAfterOverlayDismiss(entryContext: .recovery)
            onDismiss()
        case .quickFocus:
            container.navigation.queueTodaySelectionAfterOverlayDismiss(entryContext: .focus)
            onDismiss()
        }
    }

    private func submitCapture() async {
        let result = await container.commandRouter.execute(
            intent: .quickCapture,
            text: captureText,
            goalID: nil,
            captureID: nil,
            source: overlay.entrySource,
            now: .now
        )
        if let title = result.title, result.destination == nil {
            executionMessage = title
        }
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }
}

private struct MemoryLensOverlayView: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @FocusState private var isSearchFocused: Bool

    let overlay: ShellOverlayState
    let onDismiss: () -> Void

    @State private var query: String
    @State private var results: [MemoryLensResult] = []

    init(overlay: ShellOverlayState, onDismiss: @escaping () -> Void) {
        self.overlay = overlay
        self.onDismiss = onDismiss
        _query = State(initialValue: overlay.query)
    }

    var body: some View {
        NavigationStack {
            FeatureScaffoldView(
                eyebrow: "Recall",
                title: title,
                subtitle: subtitle
            ) {
                recallContextCard

                AppCard {
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        SectionHeader(
                            title: "Ask what changed",
                            subtitle: "Search across goals, captures, recent plan shifts, corrections, learning, and handoff context."
                        )

                        TextField("Try \"why now\", \"what changed\", or a goal name", text: $query)
                            .textFieldStyle(.roundedBorder)
                            .focused($isSearchFocused)
                            .accessibilityIdentifier("shell.memory-lens.search-field")

                        if results.isEmpty {
                            EmptyStateCard(
                                title: "Nothing matches yet",
                                message: "Try a goal title, a capture phrase, or a recent change you want to reopen.",
                                icon: "magnifyingglass"
                            )
                        } else {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(results) { result in
                                    Button {
                                        container.commandRouter.route(to: result.destination, source: overlay.entrySource)
                                    } label: {
                                        memoryLensResultRow(result)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityIdentifier("shell.memory-lens.result.\(result.id)")
                                }
                            }
                        }
                    }
                    .padding(theme.spacing.lg)
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: onDismiss)
                        .accessibilityIdentifier("shell.overlay.dismiss-button")
                }
            }
        }
        .task(id: searchKey) {
            results = await container.memoryLensService.search(query: query, seedIntent: overlay.intent)
        }
        .task {
            isSearchFocused = true
        }
    }

    private var recallContextCard: some View {
        AppCard(state: overlay.entrySource == .shellUtility || overlay.entrySource == .shellCompose ? .default : .selected) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(spacing: theme.spacing.xs) {
                    TagPill("From \(overlay.entrySource.displayTitle)", icon: "arrow.down.forward", state: .default)
                    TagPill(overlay.presentationContext == .recall ? "Recall" : overlay.presentationContext.rawValue.capitalized, state: .selected)
                }
                Text("Memory Lens explains useful recent context and returns to owning surfaces. It does not expose a raw activity log.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
            .padding(theme.spacing.lg)
        }
        .accessibilityIdentifier("shell.memory-lens.context-card")
    }

    private func memoryLensResultRow(_ result: MemoryLensResult) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.md) {
            Image(systemName: result.systemImage)
                .font(.system(size: theme.icon.mediumSize, weight: .semibold))
                .foregroundStyle(theme.colors.accentWarm)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(spacing: theme.spacing.xs) {
                    TagPill(result.facetTitle, state: result.state)
                    TagPill(result.badgeTitle, state: .default)
                }
                Text(result.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(result.subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.leading)
                Text(result.explanation)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                    .multilineTextAlignment(.leading)
                Text(result.actionTitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.accentPrimary)
            }

            Spacer(minLength: theme.spacing.sm)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, theme.spacing.xs)
    }

    private var searchKey: String {
        "\(overlay.intent?.rawValue ?? "none")|\(query)"
    }

    private var title: String {
        switch overlay.intent {
        case .openGoal:
            return "Open goal"
        case .openCapture:
            return "Open capture"
        case .openWeek:
            return "Open week"
        default:
            return "Memory Lens"
        }
    }

    private var subtitle: String {
        switch overlay.intent {
        case .openGoal:
            return "Find one goal and reopen it inside the canonical Goals destination."
        case .openCapture:
            return "Find the relevant capture context and return to the Plan-owned inbox."
        case .openWeek:
            return "Open the current week without leaving the shell-owned recall path."
        default:
            return "Recall what changed, what was captured, and what still deserves attention without dropping into audit-log depth."
        }
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }
}

struct AppShellPlaceholderRouteView: View {
    let title: String
    let subtitle: String
    let message: String

    var body: some View {
        FeatureScaffoldView(eyebrow: "Owned route", title: title, subtitle: subtitle) {
            AppCard {
                Text(message)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .accessibilityIdentifier("shell.placeholder.\(title.lowercased().replacingOccurrences(of: " ", with: "-"))")
    }
}
