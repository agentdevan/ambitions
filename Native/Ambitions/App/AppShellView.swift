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
                } else {
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
                .layoutPriority(1)
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.top, theme.spacing.sm)
            .padding(.bottom, theme.spacing.sm)
            .background(theme.shell.headerMaterial)

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
        .background(theme.shell.headerMaterial)
        .shadow(color: theme.depth.resting.color, radius: theme.mode == .dark ? 14 : 10, x: 0, y: 6)
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
                eyebrow: "Quiet Command Sheet",
                title: "Quiet Command Sheet",
                subtitle: "Capture, route, recover, or open the right place without turning this into chat."
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
                            subtitle: "Open goals, the current week, Capture, or the bounded recall surface."
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
            .navigationTitle("Quiet Command Sheet")
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
                        subtitle: "Small reminders of where quick actions and recall last carried context."
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
                        title: "What needs a place?",
                        subtitle: "Ambitions suggests a place, saves a receipt, and keeps the route easy to change."
                    )

                    TextField("What needs a place?", text: $captureText)
                        .textFieldStyle(.roundedBorder)
                        .focused($isCaptureFieldFocused)
                        .accessibilityIdentifier("shell.command.capture-field")
                        .accessibilityLabel("What needs a place?")

                    Button {
                        Task { await submitCapture() }
                    } label: {
                        Text("Save")
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
        if let title = result.title {
            executionMessage = title
        }
        if result.createdCaptureID != nil {
            captureText = ""
            onDismiss()
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
                Text("What Ambitions knows explains useful recent context and returns to owning surfaces. It does not expose a raw activity log.")
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
            return "What Ambitions knows"
        }
    }

    private var subtitle: String {
        switch overlay.intent {
        case .openGoal:
            return "Find one goal and reopen it inside the canonical Goals destination."
        case .openCapture:
            return "Find the relevant capture context and return to the Time-owned inbox."
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

