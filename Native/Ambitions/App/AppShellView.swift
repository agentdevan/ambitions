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

    var headerLensTitle: String {
        switch self {
        case .shaping:
            "Capacity"
        default:
            modeLens.title
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
    let kind: AppShellContextualToolbarAction.Kind?
    let title: String
    let systemImage: String
    let accessibilityIdentifier: String
    let accessibilityLabel: String
    let accessibilityHint: String?
    let keyboardShortcut: AppShellHeaderKeyboardShortcut?
    let action: () -> Void

    init(
        kind: AppShellContextualToolbarAction.Kind? = nil,
        title: String,
        systemImage: String,
        accessibilityIdentifier: String,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        keyboardShortcut: AppShellHeaderKeyboardShortcut? = nil,
        action: @escaping () -> Void
    ) {
        self.kind = kind
        self.title = title
        self.systemImage = systemImage
        self.accessibilityIdentifier = accessibilityIdentifier
        self.accessibilityLabel = accessibilityLabel ?? title
        self.accessibilityHint = accessibilityHint
        self.keyboardShortcut = keyboardShortcut
        self.action = action
    }
}

struct AppShellHeaderKeyboardShortcut {
    let key: KeyEquivalent
    let modifiers: EventModifiers
}

enum AppShellGeometry {
    static func topInsetSpacing(hasBackButton: Bool, dynamicTypeIsAccessibilitySize: Bool) -> CGFloat {
        0
    }

    static func topContentClearance(
        reservesPrimaryObjectTopClearance: Bool,
        dynamicTypeIsAccessibilitySize: Bool
    ) -> CGFloat {
        guard reservesPrimaryObjectTopClearance else { return 0 }
        return dynamicTypeIsAccessibilitySize ? 132 : 92
    }
}

struct AppShellScaffold<Content: View>: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let title: String
    let subtitle: String?
    let posture: AppShellHeaderPosture
    let backButtonAccessibilityIdentifier: String?
    let onBack: (() -> Void)?
    let trailingButtons: [AppShellHeaderButton]
    let reservesPrimaryObjectTopClearance: Bool
    let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        posture: AppShellHeaderPosture,
        backButtonAccessibilityIdentifier: String? = nil,
        onBack: (() -> Void)? = nil,
        trailingButtons: [AppShellHeaderButton] = [],
        reservesPrimaryObjectTopClearance: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.posture = posture
        self.backButtonAccessibilityIdentifier = backButtonAccessibilityIdentifier
        self.onBack = onBack
        self.trailingButtons = trailingButtons
        self.reservesPrimaryObjectTopClearance = reservesPrimaryObjectTopClearance
        self.content = content()
    }

    var body: some View {
        scaffoldedContent
            .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private var scaffoldedContent: some View {
        content
            .padding(.top, topContentClearance)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear
                    .frame(height: bottomChromeClearance)
                    .accessibilityHidden(true)
            }
            .safeAreaInset(edge: .top, spacing: topInsetSpacing) {
                headerRail
                    .hidden()
                    .accessibilityHidden(true)
            }
            .overlay(alignment: .top) {
                headerRail
                    .safeAreaPadding(.top)
                    .zIndex(1)
            }
    }

    private var headerRail: some View {
                AppShellHeaderRail(
                    title: title,
                    subtitle: subtitle,
                    posture: posture,
                    backButtonAccessibilityIdentifier: backButtonAccessibilityIdentifier,
                    onBack: onBack,
                    trailingButtons: trailingButtons
                )
    }

    private var bottomChromeClearance: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 128 : 124
    }

    private var topInsetSpacing: CGFloat {
        AppShellGeometry.topInsetSpacing(
            hasBackButton: onBack != nil,
            dynamicTypeIsAccessibilitySize: dynamicTypeSize.isAccessibilitySize
        )
    }

    private var topContentClearance: CGFloat {
        AppShellGeometry.topContentClearance(
            reservesPrimaryObjectTopClearance: reservesPrimaryObjectTopClearance,
            dynamicTypeIsAccessibilitySize: dynamicTypeSize.isAccessibilitySize
        )
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
            headerRow
            divider
        }
        .frame(maxWidth: .infinity)
        .background(headerMaterial)
        .shadow(color: headerShadowColor, radius: headerShadowRadius, x: 0, y: 6)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityIdentifier("shell.header.rail")
    }

    private var headerRow: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            leadingControl

            if shouldShowTitleBlock {
                titleBlock
            } else {
                Spacer(minLength: 0)
            }

            Spacer(minLength: theme.spacing.sm)
            trailingControls
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.top, headerTopClearance)
        .padding(.bottom, headerBottomClearance)
        .frame(maxWidth: .infinity)
        .background(headerMaterial)
    }

    @ViewBuilder
    private var leadingControl: some View {
        if let onBack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: theme.icon.smallSize, weight: .semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                    .frame(width: theme.panel.minimumTapTarget, height: theme.panel.minimumTapTarget)
                    .background(Circle().fill(theme.colors.surfaceOverlay))
                    .overlay(Circle().stroke(theme.colors.strokeSubtle, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(backButtonAccessibilityIdentifier ?? "shell.header.back-button")
            .accessibilityLabel("Back")
        } else {
            rootContextCrown
        }
    }

    private var rootContextCrown: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
            Circle()
                .fill(rootCrownAccent)
                .frame(width: 5, height: 5)
                .accessibilityHidden(true)

            Text(title.uppercased())
                .font(theme.typography.micro.weight(.bold))
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(rootCrownContext)
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
                .truncationMode(.tail)
        }
        .layoutPriority(2)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("shell.header.context-crown")
    }

    private var titleBlock: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .accessibilityIdentifier("shell.header.title")

            Text(headerSubtitle)
                .font(theme.typography.micro.weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .truncationMode(.tail)
                .accessibilityIdentifier("shell.header.subtitle")
        }
        .layoutPriority(2)
    }

    private var trailingControls: some View {
        Group {
            if AppShellContextualToolbarCatalog.shouldCompressActions(
                dynamicTypeIsAccessibilitySize: dynamicTypeSize.isAccessibilitySize,
                actionCount: trailingButtons.count
            ) {
                Menu {
                    ForEach(Array(trailingButtons.enumerated()), id: \.offset) { entry in
                        menuButton(entry.element)
                    }
                } label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                        .labelStyle(.iconOnly)
                        .frame(width: theme.panel.minimumTapTarget, height: theme.panel.minimumTapTarget)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                .accessibilityIdentifier("shell.header.action-cluster-menu")
                .accessibilityLabel("Actions")
                .accessibilityHint("Shows contextual actions for this surface, including Capture.")
            } else {
                HStack(spacing: theme.spacing.xs) {
                    ForEach(Array(trailingButtons.enumerated()), id: \.offset) { entry in
                        headerButton(entry.element)
                    }
                }
            }
        }
        .layoutPriority(1)
    }

    private func menuButton(_ button: AppShellHeaderButton) -> some View {
        Button(action: button.action) {
            Label(button.title, systemImage: button.systemImage)
        }
        .accessibilityIdentifier(button.accessibilityIdentifier)
        .accessibilityLabel(button.accessibilityLabel)
        .accessibilityHint(button.accessibilityHint ?? "")
    }

    @ViewBuilder
    private func headerButton(_ button: AppShellHeaderButton) -> some View {
        let base = Button(action: button.action) {
            Label(button.title, systemImage: button.systemImage)
                .labelStyle(.iconOnly)
                .frame(width: theme.panel.minimumTapTarget, height: theme.panel.minimumTapTarget)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: .default))
        .accessibilityIdentifier(button.accessibilityIdentifier)
        .accessibilityLabel(button.accessibilityLabel)
        .accessibilityHint(button.accessibilityHint ?? "")

        if let shortcut = button.keyboardShortcut {
            base.keyboardShortcut(shortcut.key, modifiers: shortcut.modifiers)
        } else {
            base
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(theme.shell.divider)
            .frame(height: 1)
    }

    private var shouldShowTitleBlock: Bool {
        onBack != nil
    }

    private var headerSubtitle: String {
        guard let subtitle else { return posture.title }
        return "\(subtitle) · \(posture.headerLensTitle)"
    }

    private var rootCrownContext: String {
        if dynamicTypeSize.isAccessibilitySize {
            return posture.headerLensTitle
        }
        return "· \(subtitle ?? posture.title)"
    }

    private var rootCrownAccent: Color {
        switch posture.ambientStatus {
        case .clear: theme.shell.statusClear
        case .steady: theme.shell.statusSteady
        case .tight: theme.shell.statusTight
        case .fragile: theme.shell.statusFragile
        case .atRisk: theme.shell.statusAtRisk
        case .recovered: theme.shell.statusRecovered
        case .protected: theme.shell.statusProtected
        }
    }

    private var headerMaterial: AnyShapeStyle {
        if onBack == nil {
            return AnyShapeStyle(theme.colors.canvas.opacity(theme.mode == .dark ? 0.96 : 0.92))
        }
        return AnyShapeStyle(theme.shell.headerMaterial)
    }

    private var headerShadowColor: Color {
        onBack == nil ? .clear : theme.depth.resting.color
    }

    private var headerShadowRadius: CGFloat {
        onBack == nil ? 0 : (theme.mode == .dark ? 14 : 10)
    }

    private var headerTopClearance: CGFloat {
        if onBack == nil {
            return dynamicTypeSize.isAccessibilitySize ? 10 : 6
        }
        return theme.spacing.lg + theme.spacing.lg + theme.spacing.lg
    }

    private var headerBottomClearance: CGFloat {
        if onBack == nil {
            return dynamicTypeSize.isAccessibilitySize ? 6 : 4
        }
        return theme.spacing.xs
    }

    private var accessibilitySummary: String {
        [
            "Shell context crown",
            title,
            headerSubtitle,
            posture.continuityMessage
        ].joined(separator: ". ")
    }
}

struct AppShellOverlayView: View {
    let overlay: ShellOverlayState
    let onDismiss: () -> Void
    let onGoalCreated: (ShellOverlayState, CreateGoalResponse) -> Void

    var body: some View {
        switch overlay.kind {
        case .quietCommandSheet, .memoryLens:
            QuietCommandSheetView(overlay: overlay, onDismiss: onDismiss)
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
    @FocusState private var isCaptureFieldFocused: Bool

    let overlay: ShellOverlayState
    let onDismiss: () -> Void

    @State private var selectedIntent: ShellCommandIntent?
    @State private var captureText: String = ""
    @State private var saveState: SaveState = .idle
    @State private var memoryQuery: String = ""
    @State private var memoryResults: [MemoryLensResult] = []
    @State private var isMemorySearchLoading = false
    @State private var memoryStatusMessage: String?

    private enum SaveState: Equatable {
        case idle
        case saving
        case saved(String)
        case error(String)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            dragHandle
            header
            commandContent
        }
        .padding(theme.spacing.xl)
        .presentationDetents(overlay.kind == .memoryLens ? [.height(560), .large] : [.medium, .large])
        .presentationDragIndicator(.hidden)
        .background(theme.colors.canvas)
        .onAppear {
            selectedIntent = overlay.intent
            captureText = overlay.query
            memoryQuery = overlay.query
            isCaptureFieldFocused = overlay.kind == .quietCommandSheet && overlay.presentationContext == .quickCapture
            if overlay.presentationContext == .recall {
                Task { await refreshMemoryResults() }
            }
        }
        .onChange(of: memoryQuery) { _, _ in
            guard overlay.presentationContext == .recall else { return }
            Task { await refreshMemoryResults() }
        }
    }

    private var dragHandle: some View {
        Capsule()
            .fill(theme.colors.strokeSubtle)
            .frame(width: 42, height: 5)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }

    private var header: some View {
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
        case .recovery:
            recoveryPrompt
        case .focus:
            focusPrompt
        case .time:
            timePrompt
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
                .buttonStyle(AmbitionPressableButtonStyle(state: saveButtonState))
                .accessibilityIdentifier("shell.overlay.save-capture-button")

                Button("Make Goal") {
                    onDismiss()
                    appContainer?.commandRouter.presentCreateGoal(source: overlay.entrySource, seedText: captureText, captureID: overlay.captureID)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            }

            statusMessage
        }
    }

    @ViewBuilder
    private var statusMessage: some View {
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
        case .idle, .saving:
            EmptyView()
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
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Search stays local. Results open with source context and the owning surface.")
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: theme.spacing.sm) {
                TextField("Search context", text: $memoryQuery)
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
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await refreshMemoryResults() }
                    }
                    .accessibilityIdentifier("shell.memory-lens.search-field")

                Button {
                    Task { await refreshMemoryResults() }
                } label: {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                .accessibilityIdentifier("shell.memory-lens.search-button")
            }

            if isMemorySearchLoading {
                ProgressView()
                    .accessibilityIdentifier("shell.memory-lens.loading")
            }

            if let memoryStatusMessage {
                Text(memoryStatusMessage)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("shell.memory-lens.status")
            }

            if memoryResults.isEmpty && isMemorySearchLoading == false {
                Text("No matching context yet. Try a goal, Capture phrase, correction, or handoff source.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("shell.memory-lens.empty-state")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(memoryResults) { result in
                            memoryResultButton(result)
                        }
                    }
                    .padding(.vertical, theme.spacing.xs)
                }
                .frame(maxHeight: 360)
                .accessibilityIdentifier("shell.memory-lens.results")
            }
        }
    }

    private func memoryResultButton(_ result: MemoryLensResult) -> some View {
        let handoff = result.trustedSearchHandoff(source: overlay.entrySource)
        return Button {
            onDismiss()
            let routedHandoff = appContainer?.commandRouter.route(searchResult: result, source: overlay.entrySource)
            memoryStatusMessage = routedHandoff?.body ?? handoff.body
        } label: {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: result.systemImage)
                    .font(.system(size: theme.icon.smallSize, weight: .semibold))
                    .foregroundStyle(theme.stateStyle(for: result.state).accent)
                    .frame(width: 24, height: 24)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                        Text(result.badgeTitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.stateStyle(for: result.state).accent)
                        Text(handoff.owner.title)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                        Spacer(minLength: theme.spacing.xs)
                        Text(result.actionTitle)
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textPrimary)
                    }

                    Text(result.title)
                        .font(theme.typography.body.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.86)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(result.contextRetrievalSummary)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(theme.spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(theme.colors.surfaceOverlay)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(theme.colors.strokeSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(result.title), \(handoff.owner.accessibilityLabel), \(result.actionTitle)")
        .accessibilityHint("Opens this source-grounded result without changing saved memory.")
        .accessibilityIdentifier("shell.memory-lens.result.\(result.id)")
        .disabled(handoff.isTrusted == false)
    }

    private var recoveryPrompt: some View {
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

    private var focusPrompt: some View {
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

    private var timePrompt: some View {
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

    private var overlayTitle: String {
        overlay.intent?.title ?? fallbackTitle
    }

    private var overlaySubtitle: String {
        overlay.intent?.subtitle ?? fallbackSubtitle
    }

    private var fallbackTitle: String {
        switch overlay.kind {
        case .quietCommandSheet: "Quiet Command"
        case .memoryLens: "What Ambitions knows"
        case .createGoal: "Create Goal"
        }
    }

    private var fallbackSubtitle: String {
        switch overlay.presentationContext {
        case .quickCapture: "Save what needs placement with a local receipt."
        case .createGoal: "Open a draft before anything becomes active."
        case .recall: "Inspect source-grounded context locally."
        case .neutral: "Choose a safe local action."
        case .recovery: "Return to Today without shame or silent changes."
        case .focus: "Center the recommended step."
        case .time: "Open Time as the scheduling source of truth."
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
        case .error:
            "Try again"
        }
    }

    private var saveButtonState: AmbitionVisualState {
        switch saveState {
        case .saved:
            .success
        default:
            .selected
        }
    }

    @MainActor
    private func refreshMemoryResults() async {
        guard let appContainer else {
            memoryResults = []
            memoryStatusMessage = "Search is unavailable without the app container."
            return
        }
        let query = memoryQuery
        isMemorySearchLoading = true
        let results = await appContainer.memoryLensService.search(
            query: query,
            seedIntent: overlay.intent ?? .memoryLens
        )
        guard query == memoryQuery else {
            isMemorySearchLoading = false
            return
        }
        memoryResults = results.filter { result in
            result.trustedSearchHandoff(source: overlay.entrySource).isTrusted
        }
        memoryStatusMessage = results.isEmpty ? "No local context matched this search." : "\(memoryResults.count) trusted result\(memoryResults.count == 1 ? "" : "s")"
        isMemorySearchLoading = false
    }

    @MainActor
    private func saveCapture() async {
        guard let appContainer else { return }
        let rawText = captureText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard rawText.isEmpty == false else { return }
        saveState = .saving
        do {
            _ = try await appContainer.captureService.createCapture(
                CreateCaptureRequest(rawText: rawText, sourceType: appShellCaptureSourceType(for: overlay.entrySource)),
                now: .now
            )
            saveState = .saved("Saved to Capture. Nothing else changed.")
            captureText = ""
        } catch {
            saveState = .error(error.localizedDescription)
        }
    }
}

struct AppShellActivatedCaptureSeam: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var isFocused: Bool

    let overlay: ShellOverlayState
    let onDismiss: () -> Void
    let onCreateGoal: (String, String?) -> Void

    @State private var captureText: String = ""
    @State private var saveState: SaveState = .idle
    @State private var isDictationNoticeVisible = false
    @State private var isWhyThisExpanded = false
    @State private var correctedRoute: ActivatedCaptureRouteState?
    @State private var correctionReceiptMessage: String?

    private enum SaveState: Equatable {
        case idle
        case saving
        case saved(String)
        case error(String)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            header
            inputRow
            if trimmedCaptureText.isEmpty == false {
                activatedRouteReveal
            }
            statusMessage
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
        .onAppear {
            captureText = overlay.query
            isFocused = true
        }
        .onChange(of: captureText) { _, _ in
            correctedRoute = nil
            correctionReceiptMessage = nil
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

    @ViewBuilder
    private var inputRow: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                captureField
                actionRow
                reduceMotionProof
            }
        } else {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                captureField
                actionRow
            }
        }
    }

    private var captureField: some View {
        TextField("Capture", text: $captureText, axis: .vertical)
            .focused($isFocused)
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2...5 : 1...3)
            .submitLabel(.done)
            .onSubmit {
                if canSave {
                    Task { await saveCapture() }
                }
            }
            .font(theme.typography.body)
            .foregroundStyle(theme.colors.textPrimary)
            .padding(theme.spacing.sm)
            .background(theme.colors.surfaceOverlay.opacity(isFocused ? 0.70 : 0.42))
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(isFocused ? theme.colors.accentWarm : theme.colors.strokeSubtle)
                    .frame(width: isFocused ? 3 : 1)
                    .accessibilityHidden(true)
            }
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(isFocused ? theme.colors.accentWarm : theme.colors.strokeSubtle)
                    .frame(height: isFocused ? 1.5 : 1)
                    .accessibilityHidden(true)
            }
            .accessibilityLabel("What needs placement?")
            .accessibilityHint("Type a thought. Save keeps it local and editable.")
            .accessibilityIdentifier("shell.activated-capture.input")
    }

    private var actionRow: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    saveButton
                    makeGoalButton
                    dictationButton
                }
            } else {
                HStack(spacing: theme.spacing.xs) {
                    saveButton
                    makeGoalButton
                    dictationButton
                }
            }
        }
    }

    private var saveButton: some View {
        Button {
            Task { await saveCapture() }
        } label: {
            saveButtonLabel
        }
        .disabled(canSave == false)
        .buttonStyle(AmbitionPressableButtonStyle(state: canSave ? .selected : .disabled))
        .accessibilityLabel(saveButtonTitle)
        .accessibilityHint(canSave ? "Saves the capture and keeps it editable." : "Type a thought first.")
        .accessibilityIdentifier("shell.activated-capture.save-button")
    }

    private var makeGoalButton: some View {
        Button {
            onCreateGoal(captureText, overlay.captureID)
        } label: {
            makeGoalButtonLabel
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: .default))
        .accessibilityLabel("Grow into Goal")
        .accessibilityHint("Opens a goal draft using this Capture text. No goal is created until you confirm.")
        .accessibilityIdentifier("shell.activated-capture.make-goal-button")
    }

    private var dictationButton: some View {
        Button {
            isFocused = true
            isDictationNoticeVisible = true
        } label: {
            dictationButtonLabel
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: .default))
        .accessibilityLabel("Dictation")
        .accessibilityHint("Focuses the field so the iOS keyboard microphone can be used. Ambitions does not record audio here.")
        .accessibilityIdentifier("shell.activated-capture.dictation-button")
    }

    @ViewBuilder
    private var saveButtonLabel: some View {
        if dynamicTypeSize.isAccessibilitySize {
            Label(saveButtonTitle, systemImage: "tray.and.arrow.down.fill")
                .labelStyle(.titleAndIcon)
                .frame(minHeight: 42)
        } else {
            Label(saveButtonTitle, systemImage: "tray.and.arrow.down.fill")
                .labelStyle(.iconOnly)
                .frame(minWidth: 42, minHeight: 42)
        }
    }

    @ViewBuilder
    private var makeGoalButtonLabel: some View {
        if dynamicTypeSize.isAccessibilitySize {
            Label("Grow into Goal", systemImage: "target")
                .labelStyle(.titleAndIcon)
                .frame(minHeight: 42)
        } else {
            Label("Grow into Goal", systemImage: "target")
                .labelStyle(.iconOnly)
                .frame(minWidth: 42, minHeight: 42)
        }
    }

    @ViewBuilder
    private var dictationButtonLabel: some View {
        if dynamicTypeSize.isAccessibilitySize {
            Label("Dictation", systemImage: "mic")
                .labelStyle(.titleAndIcon)
                .frame(minHeight: 42)
        } else {
            Label("Dictation", systemImage: "mic")
                .labelStyle(.iconOnly)
                .frame(minWidth: 42, minHeight: 42)
        }
    }

    private var stateOverview: some View {
        CaptureRoutingPrimitiveStage(
            role: .inputPolicy,
            title: "Composer state",
            subtitle: "Text, source, route basis, and save state stay visible without grouping routes as buckets.",
            accessibilityIdentifier: "shell.activated-capture.state-overview"
        ) {
            ForEach(stateRows) { row in
                composerStateRow(row)
            }
        }
    }

    private var composerActivationStrip: some View {
        CaptureRoutingPrimitiveStage(
            role: .inputPolicy,
            title: "Atmosphere Composer",
            subtitle: "Capture starts with a focused composer before route review.",
            accessibilityIdentifier: "shell.activated-capture.activation-strip"
        ) {
            CaptureRoutingPrimitiveLine(
                role: .inputPolicy,
                title: trimmedCaptureText.isEmpty ? "Ready for typing" : "Typing",
                subtitle: trimmedCaptureText.isEmpty
                    ? "No object exists until text is saved locally."
                    : "Text stays editable while route labels update locally.",
                systemImage: trimmedCaptureText.isEmpty ? "keyboard" : "text.cursor",
                visualState: trimmedCaptureText.isEmpty ? .default : .selected,
                isSelected: trimmedCaptureText.isEmpty == false,
                accessibilityIdentifier: "shell.activated-capture.state.typing-compact"
            )

            CaptureRoutingPrimitiveLine(
                role: .routeReveal,
                title: selectedRoute.routeBasisTitle,
                subtitle: compactRouteRevealSummary,
                systemImage: "point.topleft.down.curvedto.point.bottomright.up",
                visualState: selectedRoute.isDirectRoute ? .selected : .default,
                isSelected: selectedRoute.isDirectRoute,
                accessibilityIdentifier: "shell.activated-capture.route-basis-compact"
            )

            CaptureRoutingPrimitiveLine(
                role: .noSilentPlacement,
                title: reduceMotion ? "Reduce Motion active" : "Reduce Motion ready",
                subtitle: "Static route labels keep placement meaning visible without animation.",
                systemImage: "figure.walk.motion.trianglebadge.exclamationmark",
                accessibilityIdentifier: "shell.activated-capture.reduce-motion-compact"
            )
        }
    }

    private var compactRouteRevealSummary: String {
        let routeSource = correctedRoute == nil ? "Read locally" : "Corrected locally"
        switch selectedRoute {
        case .needsPlace:
            return "\(routeSource): hold this until you choose where it belongs."
        case .readyToPlace:
            return "\(routeSource): this can become a step for Today."
        case .growIntoGoal:
            return "\(routeSource): this can start a goal draft."
        case .heldForReview:
            return "\(routeSource): keep this for review."
        }
    }

    private var activatedRouteReveal: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Text("Suggested path")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)

                Spacer(minLength: theme.spacing.xs)

                Text(selectedRoute.routeBasisTitle)
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Text(compactRouteRevealSummary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                .fixedSize(horizontal: false, vertical: true)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: theme.spacing.xs),
                    GridItem(.flexible(), spacing: theme.spacing.xs)
                ],
                alignment: .leading,
                spacing: theme.spacing.xs
            ) {
                ForEach(ActivatedCaptureRouteState.allCases) { route in
                    correctionButton(route)
                }
            }

            Text("Saved on this device until you choose a place.")
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("shell.activated-capture.source-trust")

            if let correctionReceiptMessage {
                Text(correctionReceiptMessage)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.semanticAccent(for: .success))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("shell.activated-capture.correction-receipt")
            }
        }
        .padding(.vertical, theme.spacing.xs)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.58))
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("shell.activated-capture.route-reveal")
    }

    private var placementReview: some View {
        CaptureRoutingPrimitiveStage(
            role: .placementReview,
            title: "Local placement review",
            subtitle: "Route basis is deterministic and correction stays before save.",
            statusLabel: selectedRoute.routeBasisTitle,
            accessibilityIdentifier: "shell.activated-capture.placement-review"
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(ActivatedCaptureRouteState.allCases) { route in
                    routeStateRow(route)
                }
            }
        }
    }

    private var correctionFold: some View {
        CaptureRoutingPrimitiveStage(
            role: .correction,
            title: "Correction fold",
            subtitle: "Change the route before anything is saved or placed.",
            accessibilityIdentifier: "shell.activated-capture.correction-fold"
        ) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Label("Why this route?", systemImage: "questionmark.circle")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textPrimary)

                Spacer(minLength: theme.spacing.xs)

                Button {
                    isWhyThisExpanded.toggle()
                } label: {
                    Text("Why this?")
                        .font(theme.typography.caption.weight(.semibold))
                }
                .buttonStyle(.plain)
                .foregroundStyle(theme.colors.accentWarm)
                .accessibilityLabel("Why this route?")
                .accessibilityHint("Explains the local route basis and correction behavior.")
                .accessibilityIdentifier("shell.activated-capture.why-this-button")
            }

            Text(selectedRoute.revealSummary(isCorrected: correctedRoute != nil, detectedRoute: detectedRoute))
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("shell.activated-capture.route-reveal-summary")

            if isWhyThisExpanded {
                Text(selectedRoute.whyThisExplanation(detectedRoute: detectedRoute, isCorrected: correctedRoute != nil))
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("shell.activated-capture.why-this-explanation")
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(ActivatedCaptureRouteState.allCases) { route in
                    correctionButton(route)
                }
            }
            .accessibilityIdentifier("shell.activated-capture.correction-options")

            if let correctionReceiptMessage {
                Text(correctionReceiptMessage)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.semanticAccent(for: .success))
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("shell.activated-capture.correction-receipt")
            }
        }
    }

    private var routeProofStrip: some View {
        CaptureRoutingPrimitiveStage(
            role: .routeReveal,
            title: selectedRoute.title,
            subtitle: selectedRoute.revealSummary(isCorrected: correctedRoute != nil, detectedRoute: detectedRoute),
            statusLabel: selectedRoute.routeBasisTitle,
            accessibilityIdentifier: "shell.activated-capture.route-proof-strip"
        ) {
            if dynamicTypeSize.isAccessibilitySize == false {
                reduceMotionProof
            }

            ForEach(ActivatedCaptureRouteState.allCases) { route in
                CaptureRoutingPrimitiveLine(
                    role: .routeOption,
                    title: route.title,
                    subtitle: route.detail(isSelected: route == selectedRoute, isEmpty: trimmedCaptureText.isEmpty),
                    statusLabel: route == selectedRoute ? "Selected" : nil,
                    systemImage: route.systemImage,
                    visualState: route == selectedRoute ? .selected : .default,
                    isSelected: route == selectedRoute,
                    accessibilityIdentifier: route.accessibilityIdentifier
                )
            }
        }
    }

    private var reduceMotionProof: some View {
        Text(reduceMotion ? "Reduce Motion active" : "Reduce Motion ready")
            .font(theme.typography.caption)
            .foregroundStyle(theme.colors.textSecondary)
            .accessibilityIdentifier("shell.activated-capture.state.reduce-motion")
    }

    private func correctionButton(_ route: ActivatedCaptureRouteState) -> some View {
        let isSelected = route == selectedRoute
        return Button {
            applyRouteCorrection(route)
        } label: {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: route.systemImage)
                    .font(.system(size: theme.icon.smallSize, weight: .semibold))
                Text(route.title)
                    .font(theme.typography.caption.weight(isSelected ? .semibold : .regular))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: isSelected ? .selected : .default))
        .accessibilityLabel("Set route to \(route.title)")
        .accessibilityHint(route.correctionHint)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("\(route.accessibilityIdentifier).correction")
    }

    private var trustExplanation: some View {
        CaptureRoutingPrimitiveStage(
            role: .source,
            title: "Source and trust",
            subtitle: "Local source, receipt, and reason stay inspectable from You / What Ambitions knows.",
            accessibilityIdentifier: "shell.activated-capture.source-trust"
        ) {
            CaptureRoutingPrimitiveLine(
                role: .noSilentPlacement,
                title: "No silent placement",
                subtitle: "No cloud handoff and no route mutation happens without user-visible review."
            )
        }
        .accessibilityElement(children: .combine)
    }

    private func composerStateRow(_ row: ActivatedCaptureComposerStateRow) -> some View {
        CaptureRoutingPrimitiveLine(
            role: .inputPolicy,
            title: row.title,
            subtitle: row.detail,
            systemImage: row.systemImage,
            visualState: row.visualState,
            isSelected: row.visualState == .selected,
            accessibilityIdentifier: row.id
        )
    }

    private func routeStateRow(_ route: ActivatedCaptureRouteState) -> some View {
        let isSelected = route == selectedRoute
        return CaptureRoutingPrimitiveLine(
            role: .routeOption,
            title: route.title,
            subtitle: route.detail(isSelected: isSelected, isEmpty: trimmedCaptureText.isEmpty),
            statusLabel: isSelected ? "Selected" : route.reviewLabel,
            systemImage: route.systemImage,
            visualState: isSelected ? .selected : .default,
            isSelected: isSelected,
            accessibilityIdentifier: "\(route.accessibilityIdentifier).detail"
        )
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private var statusMessage: some View {
        switch saveState {
        case .error(let message):
            Text(message)
                .font(theme.typography.caption)
                .foregroundStyle(theme.semanticAccent(for: .caution))
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("shell.activated-capture.status")
        case .saved(let message):
            Text(message)
                .font(theme.typography.caption)
                .foregroundStyle(theme.semanticAccent(for: .success))
                .accessibilityIdentifier("shell.activated-capture.status")
        case .saving:
            Text("Saving locally before the receipt is written.")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .accessibilityIdentifier("shell.activated-capture.status")
        case .idle:
            EmptyView()
        }
    }

    private var canSave: Bool {
        trimmedCaptureText.isEmpty == false && saveState != .saving
    }

    private var trimmedCaptureText: String {
        captureText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var selectedRoute: ActivatedCaptureRouteState {
        correctedRoute ?? detectedRoute
    }

    private var detectedRoute: ActivatedCaptureRouteState {
        ActivatedCaptureRouteState.selectedRoute(for: trimmedCaptureText)
    }

    private var seamMaxHeight: CGFloat {
        dynamicTypeSize.isAccessibilitySize ? 420 : 318
    }

    private var stateRows: [ActivatedCaptureComposerStateRow] {
        var rows: [ActivatedCaptureComposerStateRow] = [
            ActivatedCaptureComposerStateRow(
                id: "shell.activated-capture.state.activated",
                title: "Activated",
                detail: "Bottom seam opened from \(overlay.entrySource.displayTitle).",
                systemImage: "sparkles",
                visualState: .selected
            ),
            ActivatedCaptureComposerStateRow(
                id: "shell.activated-capture.state.keyboard",
                title: isFocused ? "Keyboard visible" : "Keyboard ready",
                detail: "The field receives focus when Capture opens.",
                systemImage: "keyboard",
                visualState: .default
            ),
            ActivatedCaptureComposerStateRow(
                id: "shell.activated-capture.state.dictation",
                title: isDictationNoticeVisible ? "Dictation handoff" : "Dictation available",
                detail: "Use the iOS keyboard microphone; Ambitions does not record audio.",
                systemImage: "mic",
                visualState: .default
            )
        ]

        rows.append(
            ActivatedCaptureComposerStateRow(
                id: "shell.activated-capture.state.local-classification",
                title: "Reading locally",
                detail: "Placement review uses the text in this field only.",
                systemImage: "wand.and.stars.inverse",
                visualState: .default
            )
        )

        if trimmedCaptureText.isEmpty {
            rows.append(
                ActivatedCaptureComposerStateRow(
                    id: "shell.activated-capture.state.empty",
                    title: "Empty quiet field",
                    detail: "Hidden until activation; no item exists yet.",
                    systemImage: "circle.dotted",
                    visualState: .default
                )
            )
        } else {
            rows.append(
                ActivatedCaptureComposerStateRow(
                    id: "shell.activated-capture.state.typing",
                    title: "Typing",
                    detail: "Held Object text is editable before save.",
                    systemImage: "text.cursor",
                    visualState: .selected
                )
            )
        }

        rows.append(
            ActivatedCaptureComposerStateRow(
                id: selectedRoute.routeBasisIdentifier,
                title: selectedRoute.routeBasisTitle,
                detail: correctedRoute == nil
                    ? "Route language is deterministic and correctable."
                    : "User correction is stored locally in the active seam.",
                systemImage: "point.topleft.down.curvedto.point.bottomright.up",
                visualState: selectedRoute.isDirectRoute ? .selected : .default
            )
        )

        rows.append(contentsOf: ActivatedCaptureRouteState.allCases.map { route in
            ActivatedCaptureComposerStateRow(
                id: route.accessibilityIdentifier,
                title: route.title,
                detail: route.detail(isSelected: route == selectedRoute, isEmpty: trimmedCaptureText.isEmpty),
                systemImage: route.systemImage,
                visualState: route == selectedRoute ? .selected : .default
            )
        })

        if let correctedRoute {
            rows.append(
                ActivatedCaptureComposerStateRow(
                    id: "shell.activated-capture.state.user-correction",
                    title: "User correction",
                    detail: "Route set to \(correctedRoute.title). Local learning copy stays inspectable.",
                    systemImage: "arrow.triangle.branch",
                    visualState: .success
                )
            )
        }

        switch saveState {
        case .saved:
            rows.append(
                ActivatedCaptureComposerStateRow(
                    id: "shell.activated-capture.state.captured-locally",
                    title: "Captured locally",
                    detail: "Saved through the local Capture service with no extra route mutation.",
                    systemImage: "checkmark.seal",
                    visualState: .success
                )
            )
        case .error:
            rows.append(
                ActivatedCaptureComposerStateRow(
                    id: "shell.activated-capture.state.save-error",
                    title: "Save error",
                    detail: "The composer keeps the text editable and does not place it silently.",
                    systemImage: "exclamationmark.triangle",
                    visualState: .warning
                )
            )
        case .saving:
            rows.append(
                ActivatedCaptureComposerStateRow(
                    id: "shell.activated-capture.state.saving",
                    title: "Saving locally",
                    detail: "The local receipt is being written.",
                    systemImage: "tray.and.arrow.down",
                    visualState: .selected
                )
            )
        case .idle:
            break
        }

        rows.append(
            ActivatedCaptureComposerStateRow(
                id: "shell.activated-capture.state.reduce-motion",
                title: reduceMotion ? "Reduce Motion active" : "Reduce Motion ready",
                detail: "Static state labels preserve route meaning without animation.",
                systemImage: "figure.walk.motion.trianglebadge.exclamationmark",
                visualState: .default
            )
        )

        return rows
    }

    private var saveButtonTitle: String {
        switch saveState {
        case .idle:
            "Save"
        case .saving:
            "Saving..."
        case .saved:
            "Saved"
        case .error:
            "Try again"
        }
    }

    @MainActor
    private func applyRouteCorrection(_ route: ActivatedCaptureRouteState) {
        correctedRoute = route
        correctionReceiptMessage = route == detectedRoute
            ? "Route confirmed locally as \(route.title). Source, receipt, and reason remain inspectable."
            : "Route corrected locally to \(route.title). Source, receipt, and reason remain inspectable."
    }

    @MainActor
    private func saveCapture() async {
        guard let appContainer else { return }
        let rawText = trimmedCaptureText
        guard rawText.isEmpty == false else { return }
        let routeAtSave = selectedRoute
        saveState = .saving
        do {
            _ = try await appContainer.captureService.createCapture(
                CreateCaptureRequest(rawText: rawText, sourceType: appShellCaptureSourceType(for: overlay.entrySource)),
                now: .now
            )
            saveState = .saved("Captured locally as \(routeAtSave.title). Receipt path stays inspectable.")
            captureText = ""
        } catch {
            saveState = .error(error.localizedDescription)
        }
    }
}

private struct ActivatedCaptureComposerStateRow: Identifiable {
    let id: String
    let title: String
    let detail: String
    let systemImage: String
    let visualState: AmbitionVisualState
}

private enum ActivatedCaptureRouteState: String, CaseIterable, Identifiable {
    case needsPlace
    case readyToPlace
    case growIntoGoal
    case heldForReview

    var id: String { rawValue }

    var title: String {
        switch self {
        case .needsPlace:
            "Needs placement"
        case .readyToPlace:
            "Ready to Place"
        case .growIntoGoal:
            "Grow into Goal"
        case .heldForReview:
            "Held for Review"
        }
    }

    var systemImage: String {
        switch self {
        case .needsPlace:
            "tray"
        case .readyToPlace:
            "checkmark.circle"
        case .growIntoGoal:
            "target"
        case .heldForReview:
            "eye"
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .needsPlace:
            "shell.activated-capture.route.needs-place"
        case .readyToPlace:
            "shell.activated-capture.route.ready-to-place"
        case .growIntoGoal:
            "shell.activated-capture.route.grow-into-goal"
        case .heldForReview:
            "shell.activated-capture.route.held-for-review"
        }
    }

    var routeBasisTitle: String {
        switch self {
        case .readyToPlace, .growIntoGoal:
            "Route ready after review"
        case .needsPlace, .heldForReview:
            "Needs review before placement"
        }
    }

    var routeBasisIdentifier: String {
        switch self {
        case .readyToPlace, .growIntoGoal:
            "shell.activated-capture.route.ready-after-review"
        case .needsPlace, .heldForReview:
            "shell.activated-capture.route.needs-review"
        }
    }

    var isDirectRoute: Bool {
        switch self {
        case .readyToPlace, .growIntoGoal:
            true
        case .needsPlace, .heldForReview:
            false
        }
    }

    var reviewLabel: String {
        switch self {
        case .needsPlace:
            "Hold"
        case .readyToPlace:
            "Review"
        case .growIntoGoal:
            "Draft"
        case .heldForReview:
            "Ask"
        }
    }

    var correctionHint: String {
        switch self {
        case .needsPlace:
            "Saves the capture as a held item until you choose a place."
        case .readyToPlace:
            "Marks the capture as ready for placement after review."
        case .growIntoGoal:
            "Treats the capture as goal-shaped and opens a draft only after confirmation."
        case .heldForReview:
            "Keeps the capture held for manual review."
        }
    }

    func revealSummary(isCorrected: Bool, detectedRoute: ActivatedCaptureRouteState) -> String {
        let routeSource = isCorrected ? "Corrected locally" : "Read locally"
        switch self {
        case .needsPlace:
            return "\(routeSource): save first as Needs placement. No placement happens until you correct or open it."
        case .readyToPlace:
            return "\(routeSource): Ready to Place because the text looks concrete enough to review."
        case .growIntoGoal:
            return "\(routeSource): Grow into Goal because the text reads like an ambition thread."
        case .heldForReview:
            return "\(routeSource): Held for Review because Ambitions should ask before interpreting it."
        }
    }

    func whyThisExplanation(detectedRoute: ActivatedCaptureRouteState, isCorrected: Bool) -> String {
        if isCorrected {
            return "You corrected the route from \(detectedRoute.title) to \(title). That correction stays local; source, receipt, reason, and You / What Ambitions knows remain the inspection path."
        }

        switch self {
        case .needsPlace:
            return "Ambitions did not find clear time, action, or goal language, so it saves first as Needs placement."
        case .readyToPlace:
            return "Time or action wording such as today, tomorrow, weekdays, or clock language makes the item ready to place after review."
        case .growIntoGoal:
            return "Goal-shaped language such as goal, ambition, launch, build, learn, career, or milestone routes this toward a goal draft after confirmation."
        case .heldForReview:
            return "Short, question-shaped, or sensitive text is kept for review so Capture does not move user data silently."
        }
    }

    func detail(isSelected: Bool, isEmpty: Bool) -> String {
        let prefix = isSelected ? "Selected: " : ""
        switch self {
        case .needsPlace:
            return prefix + (isEmpty ? "empty or unclear text stays unplaced." : "save first when the route is not clear.")
        case .readyToPlace:
            return prefix + "concrete time or action wording can be placed after review."
        case .growIntoGoal:
            return prefix + "goal-shaped intent opens a draft only after confirmation."
        case .heldForReview:
            return prefix + "ambiguous or sensitive text waits for manual review."
        }
    }

    static func selectedRoute(for rawText: String) -> ActivatedCaptureRouteState {
        let text = rawText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard text.isEmpty == false else { return .needsPlace }

        let goalTerms = ["goal", "ambition", "launch", "build", "learn", "career", "milestone"]
        if goalTerms.contains(where: { text.contains($0) }) {
            return .growIntoGoal
        }

        let placementTerms = ["today", "tomorrow", "next ", " at ", "am", "pm", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
        if placementTerms.contains(where: { text.contains($0) }) {
            return .readyToPlace
        }

        if text.count < 12 || text.contains("?") {
            return .heldForReview
        }

        return .needsPlace
    }
}

private func appShellCaptureSourceType(for source: ShellCommandEntrySource) -> CaptureSourceType? {
    switch source {
    case .todayQuickCapture:
        return .todayQuickCapture
    case .appIntent:
        return .appIntent
    case .notification:
        return .notification
    case .shareExtension:
        return .shareExtensionText
    case .shellCompose, .shellUtility, .goalsCreate, .goalsQuickCapture, .timeQuickCapture, .motionQuickCapture, .youQuickCapture, .capturesScreen, .deepLink, .widget, .external:
        return nil
    }
}
