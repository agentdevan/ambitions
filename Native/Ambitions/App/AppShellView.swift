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
        .padding(.top, theme.spacing.lg + theme.spacing.lg + theme.spacing.lg)
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
        return "\(subtitle) · \(posture.modeLens.title)"
    }

    private var rootCrownContext: String {
        if dynamicTypeSize.isAccessibilitySize {
            return posture.modeLens.title
        }
        return "· \(headerSubtitle)"
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
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    composerActivationStrip
                    routeProofStrip
                    placementReview
                    correctionFold
                    trustExplanation
                    statusMessage
                }
                .padding(.bottom, 1)
            }
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(maxHeight: seamMaxHeight)
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
                Text("Capture Anything")
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
                reduceMotionProof
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
            subtitle: "Input, source, route basis, and save state stay visible without grouping routes as buckets.",
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
            subtitle: "Global Capture opens as a focused composer before route review.",
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
        let routeSource = correctedRoute == nil ? "Detected locally" : "Corrected locally"
        switch selectedRoute {
        case .needsPlace:
            return "\(routeSource): hold as Needs a Place until review."
        case .readyToPlace:
            return "\(routeSource): concrete action text can be reviewed for Today."
        case .growIntoGoal:
            return "\(routeSource): ambition-shaped text can open a goal draft."
        case .heldForReview:
            return "\(routeSource): ambiguous text waits for manual review."
        }
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
            subtitle: "Local SourceRecord, Receipt, and ReplayTrace stay inspectable from You / What Ambitions knows.",
            accessibilityIdentifier: "shell.activated-capture.source-trust"
        ) {
            CaptureRoutingPrimitiveLine(
                role: .noSilentPlacement,
                title: "No silent placement",
                subtitle: "No cloud classifier and no route mutation happens without user-visible review."
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
            Text("Classifying locally before the receipt is written.")
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
        dynamicTypeSize.isAccessibilitySize ? 620 : 520
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
                title: "Classifying locally",
                detail: "Deterministic placement review uses the text in this field only.",
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
            ? "Route confirmed locally as \(route.title). SourceRecord, Receipt, and ReplayTrace remain inspectable."
            : "Route corrected locally to \(route.title). SourceRecord, Receipt, and ReplayTrace remain inspectable."
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
            "Needs a Place"
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
        let routeSource = isCorrected ? "Corrected locally" : "Detected locally"
        switch self {
        case .needsPlace:
            return "\(routeSource): save first as Needs a Place. No placement happens until you correct or open it."
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
            return "You corrected the route from \(detectedRoute.title) to \(title). That correction is local product data for this seam; SourceRecord, Receipt, ReplayTrace, and You / What Ambitions knows remain the inspection path."
        }

        switch self {
        case .needsPlace:
            return "Ambitions did not find clear time, action, or goal language, so it saves first as Needs a Place."
        case .readyToPlace:
            return "Time or action wording such as today, tomorrow, weekdays, or clock language makes the item ready to place after review."
        case .growIntoGoal:
            return "Goal-shaped language such as goal, ambition, launch, build, learn, career, or milestone routes this toward a goal draft after confirmation."
        case .heldForReview:
            return "Short, question-shaped, or sensitive text is held for review so Capture does not move user data silently."
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
