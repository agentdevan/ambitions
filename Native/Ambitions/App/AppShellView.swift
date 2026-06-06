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
    let accessibilityLabel: String
    let accessibilityHint: String?
    let keyboardShortcut: AppShellHeaderKeyboardShortcut?
    let action: () -> Void

    init(
        title: String,
        systemImage: String,
        accessibilityIdentifier: String,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        keyboardShortcut: AppShellHeaderKeyboardShortcut? = nil,
        action: @escaping () -> Void
    ) {
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
            headerRow
            divider
        }
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
        .padding(.top, theme.spacing.xs)
        .padding(.bottom, theme.spacing.xs)
        .background(headerMaterial)
    }

    @ViewBuilder
    private var leadingControl: some View {
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
        }
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
        HStack(spacing: theme.spacing.xs) {
            ForEach(Array(trailingButtons.enumerated()), id: \.offset) { entry in
                headerButton(entry.element)
            }
        }
        .layoutPriority(1)
    }

    @ViewBuilder
    private func headerButton(_ button: AppShellHeaderButton) -> some View {
        let base = Button(action: button.action) {
            Label(button.title, systemImage: button.systemImage)
                .labelStyle(.iconOnly)
                .frame(width: posture == .execution ? 34 : 36, height: posture == .execution ? 34 : 36)
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
        posture != .execution || onBack != nil
    }

    private var headerSubtitle: String {
        guard let subtitle else { return posture.title }
        return "\(subtitle) · \(posture.modeLens.title)"
    }

    private var headerMaterial: AnyShapeStyle {
        if onBack == nil {
            return AnyShapeStyle(theme.colors.canvas.opacity(0.001))
        }
        return AnyShapeStyle(theme.shell.headerMaterial)
    }

    private var headerShadowColor: Color {
        onBack == nil ? .clear : theme.depth.resting.color
    }

    private var headerShadowRadius: CGFloat {
        onBack == nil ? 0 : (theme.mode == .dark ? 14 : 10)
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .background(theme.colors.canvas)
        .onAppear {
            selectedIntent = overlay.intent
            captureText = overlay.query
            isCaptureFieldFocused = overlay.kind == .quietCommandSheet && overlay.presentationContext == .quickCapture
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
        Text("Memory Lens is local-first inspection. It shows what Ambitions knows without exposing raw activity logs.")
            .font(theme.typography.body)
            .foregroundStyle(theme.colors.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
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
        case .quickCapture: "Save what needs a place with a local receipt."
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
            statusMessage
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.shell.receiptMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.shell.divider, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous))
        .shadow(color: theme.depth.overlay.color, radius: theme.depth.overlay.radius, x: theme.depth.overlay.x, y: theme.depth.overlay.y)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: saveState)
        .onAppear {
            captureText = overlay.query
            isFocused = true
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(AppShellCaptureAccessModel.activatedSeamAccessibilityLabel)
        .accessibilityHint(AppShellCaptureAccessModel.activatedSeamAccessibilityHint)
        .accessibilityIdentifier("shell.activated-capture-seam")
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(AppShellCaptureAccessModel.toolbarTitle)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text("From \(overlay.entrySource.displayTitle)")
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
            }
        } else {
            HStack(alignment: .bottom, spacing: theme.spacing.sm) {
                captureField
                actionRow
            }
        }
    }

    private var captureField: some View {
        TextField("What needs a place?", text: $captureText, axis: .vertical)
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
            .padding(theme.spacing.md)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(theme.colors.surfaceOverlay)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(isFocused ? theme.colors.accentWarm : theme.colors.strokeSubtle, lineWidth: isFocused ? 1.5 : 1)
            )
            .accessibilityLabel("What needs a place?")
            .accessibilityHint("Type a thought. Save keeps it local and editable.")
            .accessibilityIdentifier("shell.activated-capture.input")
    }

    private var actionRow: some View {
        HStack(spacing: theme.spacing.xs) {
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

            Button {
                onCreateGoal(captureText, overlay.captureID)
            } label: {
                makeGoalButtonLabel
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            .accessibilityLabel("Make Goal")
            .accessibilityHint("Opens a goal draft using this Capture text.")
            .accessibilityIdentifier("shell.activated-capture.make-goal-button")
        }
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
            Label("Make Goal", systemImage: "target")
                .labelStyle(.titleAndIcon)
                .frame(minHeight: 42)
        } else {
            Label("Make Goal", systemImage: "target")
                .labelStyle(.iconOnly)
                .frame(minWidth: 42, minHeight: 42)
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

    private var canSave: Bool {
        captureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && saveState != .saving
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
