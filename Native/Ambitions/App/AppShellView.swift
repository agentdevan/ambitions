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
                .accessibilityIdentifier("shell.flagship.chrome.header")
    }

    private var bottomChromeClearance: CGFloat {
        if onBack != nil {
            return dynamicTypeSize.isAccessibilitySize ? 64 : 34
        }
        return 0
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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
                    .contentShape(Circle())
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
                    Label("Actions", systemImage: "ellipsis")
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
        Button {
            AppShellSensoryFeedbackPolicy.emit(.headerAction, reduceMotionEnabled: reduceMotion)
            button.action()
        } label: {
            Label(button.title, systemImage: button.systemImage)
        }
        .accessibilityIdentifier(button.accessibilityIdentifier)
        .accessibilityLabel(button.accessibilityLabel)
        .accessibilityHint(button.accessibilityHint ?? "")
    }

    @ViewBuilder
    private func headerButton(_ button: AppShellHeaderButton) -> some View {
        let base = Button {
            AppShellSensoryFeedbackPolicy.emit(.headerAction, reduceMotionEnabled: reduceMotion)
            button.action()
        } label: {
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
            .fill(Color.clear)
            .frame(height: 0)
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
            return AnyShapeStyle(theme.colors.canvas.opacity(theme.mode == .dark ? 0.28 : 0.22))
        }
        return AnyShapeStyle(theme.colors.canvas.opacity(theme.mode == .dark ? 0.46 : 0.34))
    }

    private var headerShadowColor: Color {
        .clear
    }

    private var headerShadowRadius: CGFloat {
        0
    }

    private var headerTopClearance: CGFloat {
        if onBack == nil {
            return dynamicTypeSize.isAccessibilitySize ? 10 : 6
        }
        return dynamicTypeSize.isAccessibilitySize ? theme.spacing.xl : theme.spacing.lg
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

    let overlay: ShellOverlayState
    let onDismiss: () -> Void

    @State private var selectedIntent: ShellCommandIntent?
    @State private var captureText: String = ""
    @State private var selectedDraftRouteType: SmartAttachmentRouteType?
    @State private var saveState: SaveState = .idle
    @State private var dictationStatusMessage: String?
    @State private var memoryQuery: String = ""
    @State private var memoryResults: [MemoryLensResult] = []
    @State private var isMemorySearchLoading = false
    @State private var memoryStatusMessage: String?

    private let draftRouteService = CaptureDraftRouteService()

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
        .presentationDetents(overlay.kind == .memoryLens ? [.height(560), .large] : [.large])
        .presentationDragIndicator(.hidden)
        .background(theme.colors.canvas)
        .onAppear {
            selectedIntent = overlay.intent
            captureText = overlay.query
            memoryQuery = overlay.query
            if overlay.presentationContext == .recall {
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

    private var quickCaptureRoutePreview: CaptureDraftRoutePreview? {
        let rawText = captureText.trimmingCharacters(in: .whitespacesAndNewlines)
        return draftRouteService.makeDraftRoutePreview(
            for: rawText,
            sourceType: appShellCaptureSourceType(for: overlay.entrySource),
            sourceSurface: overlay.entrySource.displayTitle,
            selectedDraftRouteType: selectedDraftRouteType,
            localSourceLabel: "Local source: \(overlay.entrySource.displayTitle)"
        )
    }

    private var quickCaptureErrorText: String? {
        if case .error(let message) = saveState {
            return message
        }
        return nil
    }

    private var canSaveQuickCapture: Bool {
        captureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && saveState != .saving
    }

    private var fallbackTitle: String {
        switch overlay.kind {
        case .quietCommandSheet: "Quick action"
        case .memoryLens: "Search Ambitions"
        case .createGoal: "Create Goal"
        }
    }

    private var fallbackSubtitle: String {
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
