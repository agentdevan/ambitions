import AmbitionsDesignSystem
import SwiftUI

enum CapturesScreenShellMode: Equatable {
    case planSupport
    case topLevelCapture
}

struct CapturesScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: CapturesViewModel
    private let shellMode: CapturesScreenShellMode

    @MainActor
    init(shellMode: CapturesScreenShellMode = .planSupport) {
        self.shellMode = shellMode
        _viewModel = State(initialValue: CapturesViewModel())
    }

    init(
        shellMode: CapturesScreenShellMode,
        viewModel: CapturesViewModel
    ) {
        self.shellMode = shellMode
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            LivingSurfaceBackground(context: .capture, state: captureLivingState, intensity: 0.68)
                .ignoresSafeArea()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                    TopLevelSurfaceCompositionBar(surface: .capture, state: captureCompositionState)

                    capturePrompt

                    switch viewModel.state {
                    case .loading:
                        LoadingSkeletonCard(lineCount: 4)
                            .transition(.ambitionPanel)
                    case .failed:
                        DegradedStateCard(
                            state: DegradedStateOrchestrator.unavailable(surface: "Capture"),
                            primaryAccessibilityIdentifier: "captures.retry-button",
                            onPrimaryAction: {
                                Task { await load() }
                            }
                        )
                        .transition(.ambitionPanel)
                    case let .loaded(viewState):
                        loadedContent(viewState)
                            .transition(.ambitionPanel)
                    }
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.top, theme.spacing.md)
                .padding(.bottom, theme.spacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CaptureAtmosphereComposer(
                text: Binding(
                    get: { viewModel.draftText },
                    set: { viewModel.updateDraftText($0) }
                ),
                routePreview: viewModel.draftRoutePreview,
                error: viewModel.draftError,
                isSubmitEnabled: canSubmitDraft,
                onSubmit: {
                    Task {
                        await viewModel.createQuickCapture(
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                },
                onMicrophone: {
                    viewModel.draftError = "Voice capture is not connected yet. Type it here for now."
                },
                onRouteChoice: { routeType in
                    viewModel.selectDraftRoute(routeType)
                }
            )
        }
        .navigationTitle(shellMode.title)
        .refreshable {
            await load()
        }
        .accessibilityIdentifier("captures.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            guard case .loading = viewModel.state else { return }
            await load()
        }
    }

    private var captureLivingState: LivingVisualState {
        if viewModel.actionMessage != nil {
            return .proof
        }
        if viewModel.draftRoutePreview != nil {
            return .active
        }
        if canSubmitDraft {
            return .active
        }
        return .empty
    }

    private var captureCompositionState: AmbitionVisualState {
        if viewModel.actionMessage != nil {
            return .success
        }
        if viewModel.draftRoutePreview != nil || canSubmitDraft {
            return .selected
        }
        return .default
    }

    private var canSubmitDraft: Bool {
        viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private func load() async {
        await viewModel.load(captureService: container.captureService, goalsService: container.goalsService)
    }

    private var capturePrompt: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("What needs a place?")
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text(promptSubtitle)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            EvidenceLabel(
                "Composer first",
                detail: "Capture stays low-friction and route suggestions stay editable.",
                source: "Capture",
                state: captureLivingState,
                context: .capture
            )

            if shellMode == .planSupport {
                Button {
                    container.navigation.resetPlanPath()
                } label: {
                    Label("Plan", systemImage: "calendar")
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("captures.return-to-plan")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("captures.prompt")
    }

    private var promptSubtitle: String {
        let draftIsEmpty = viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if draftIsEmpty {
            return "Capture one real thing. Ambitions can suggest where it belongs after you type."
        }
        return "Route suggestions stay editable. Nothing becomes plan work until you save it."
    }

    @ViewBuilder
    private func loadedContent(_ viewState: CapturesViewState) -> some View {
        if let routePreview = viewModel.draftRoutePreview {
            draftRoutePreviewCard(routePreview)
        }

        if let message = viewModel.actionMessage {
            captureReceiptPreview(message)
        }

        if viewState.captures.isEmpty, viewModel.draftRoutePreview == nil, viewModel.actionMessage == nil {
            emptyCaptureState
        } else if viewState.captures.isEmpty == false {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                ForEach(groupedCaptures(viewState.captures), id: \.title) { group in
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        SectionHeader(title: group.title, subtitle: group.subtitle)
                        ForEach(group.captures) { capture in
                            captureCard(capture, activeGoalOptions: viewState.activeGoalOptions)
                        }
                    }
                }
            }
        }
    }

    private var emptyCaptureState: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Label("Ready when something needs a place", systemImage: "tray.and.arrow.down")
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
            Text("Use the composer below. This screen stays quiet until there is something to route.")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .padding(.vertical, theme.spacing.sm)
        .accessibilityIdentifier("captures.empty")
    }

    private func captureReceiptPreview(_ message: CaptureActionMessage) -> some View {
        StateDrivenMaterialPanel(context: .capture, state: .proof) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    ProofPulse(isActive: true, label: "Capture receipt saved")
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(message.title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(message.body)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
                EvidenceLabel(
                    "Receipt",
                    detail: message.body,
                    source: "Capture action",
                    state: .proof,
                    context: .capture
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityIdentifier("captures.receipt-preview")
    }

    private func draftRoutePreviewCard(_ preview: CaptureDraftRoutePreview) -> some View {
        CaptureDraftRoutePreviewCard(preview: preview) { routeType in
            viewModel.selectDraftRoute(routeType)
        }
    }

    private func metadataText(for capture: Capture) -> String {
        var parts = [capture.kind.title, capture.route.title, capture.triageStatus.title]
        if let sourceType = capture.sourceType {
            parts.append(sourceLabel(for: sourceType))
        }
        if let deadlineText = capture.deadlineText { parts.append("Deadline \(deadlineText)") }
        if let contextLensHint = capture.contextLensHint { parts.append(contextLensHint.displayTitle) }
        if let revisitAfter = capture.revisitAfter {
            parts.append("Revisit after \(revisitAfter)")
        }
        parts.append(capture.updatedAt)
        return parts.joined(separator: " • ")
    }

    private func sourceLabel(for sourceType: CaptureSourceType) -> String {
        sourceType.title
    }

    private func groupedCaptures(_ captures: [Capture]) -> [CaptureGroup] {
        let active = captures.filter { [.needsTriage, .actionable].contains($0.status) }
        let routed = captures.filter { [.seed, .goalBound, .scheduled, .delegated].contains($0.status) }
        let parked = captures.filter { [.waiting, .optionalSomeday, .archived].contains($0.status) }
        return [
            CaptureGroup(title: "Needs a Place", subtitle: "Raw thoughts and assumptions that should stay correctable.", captures: active),
            CaptureGroup(title: "Placed", subtitle: "Items with a visible destination but no Plan scheduling here.", captures: routed),
            CaptureGroup(title: "Parked", subtitle: "Waiting, someday, and archived items stay findable without crowding the day.", captures: parked)
        ].filter { $0.captures.isEmpty == false }
    }

    private func captureCard(_ capture: Capture, activeGoalOptions: [CaptureGoalOption]) -> some View {
        AppCard(state: state(for: capture)) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                Text(capture.rawText)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(metadataText(for: capture))
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("captures.metadata.\(capture.id)")

                if let assumption = capture.assumptionSummary {
                    Text(assumption)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                captureActions(for: capture, activeGoalOptions: activeGoalOptions)
            }
        }
    }

    private func state(for capture: Capture) -> AmbitionVisualState {
        switch capture.status {
        case .waiting:
            return .warning
        case .archived, .optionalSomeday:
            return .disabled
        case .goalBound, .scheduled:
            return .success
        case .needsTriage:
            return .selected
        case .seed, .actionable, .delegated:
            return .default
        }
    }

    @ViewBuilder
    private func captureActions(for capture: Capture, activeGoalOptions: [CaptureGoalOption]) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(spacing: theme.spacing.sm) {
                Button {
                    Task {
                        await viewModel.routeToPlan(
                            id: capture.id,
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                } label: {
                    Label("Task", systemImage: "checkmark.circle")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .scheduled) == false)

                Button {
                    container.commandRouter.presentCreateGoal(
                        source: .capturesScreen,
                        seedText: capture.rawText,
                        captureID: capture.id
                    )
                } label: {
                    Label("Grow into Goal", systemImage: "target")
                }
                .buttonStyle(.borderedProminent)
                .disabled(canPromoteCaptureToGoal(capture) == false)
                .accessibilityIdentifier("captures.new-goal.\(capture.id)")
            }

            HStack(spacing: theme.spacing.sm) {
                Button {
                    Task {
                        await viewModel.saveToNeedsPlace(
                            id: capture.id,
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                } label: {
                    Label("Keep here", systemImage: "tray.full")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .needsTriage) == false)

                Menu("Attach proof") {
                    if activeGoalOptions.isEmpty {
                        Text("No active goals")
                    } else {
                        ForEach(activeGoalOptions) { option in
                            Button(option.title) {
                                Task {
                                    if let target = await viewModel.attachToGoal(
                                        captureID: capture.id,
                                        goalID: option.id,
                                        goalTitle: option.title,
                                        captureService: container.captureService,
                                        goalsService: container.goalsService
                                    ) {
                                        openGoal(target)
                                    }
                                }
                            }
                        }
                    }
                }
                .disabled(capture.status.canTransition(to: .goalBound) == false || activeGoalOptions.isEmpty)
            }

            HStack(spacing: theme.spacing.sm) {
                Button {
                    Task {
                        await viewModel.markDeliverableSeed(
                            id: capture.id,
                            text: capture.rawText,
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                } label: {
                    Label("Idea", systemImage: "lightbulb")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .seed) == false)

                Button {
                    Task {
                        await viewModel.markWaiting(
                            id: capture.id,
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                } label: {
                    Label("Waiting", systemImage: "hourglass")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .waiting) == false)
            }

            HStack(spacing: theme.spacing.sm) {
                Button {
                    Task {
                        await viewModel.markOptionalSomeday(
                            id: capture.id,
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                } label: {
                    Label("Review later", systemImage: "moon")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .optionalSomeday) == false)

                Button {
                    Task {
                        await viewModel.archive(
                            id: capture.id,
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .archived) == false)
            }
        }
        .font(theme.typography.caption)
    }

    private func openGoal(_ target: GoalRouteTarget) {
        guard let goalID = target.goalID else { return }
        container.navigation.openGoalDetail(goalID: goalID, draftID: target.draftID)
    }

    private func canPromoteCaptureToGoal(_ capture: Capture) -> Bool {
        switch capture.status {
        case .needsTriage, .seed, .actionable:
            return true
        case .goalBound, .scheduled, .delegated, .archived:
            return false
        case .waiting, .optionalSomeday:
            return false
        }
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }
}

private struct CaptureGroup {
    let title: String
    let subtitle: String
    let captures: [Capture]
}

private extension NowContextLens {
    var displayTitle: String {
        switch self {
        case .work: "Work"
        case .personal: "Personal"
        case .freeTime: "Free Time"
        case .admin: "Admin"
        case .creative: "Creative"
        case .recovery: "Recovery"
        case .deepFocus: "Deep Focus"
        case .all: "All"
        }
    }
}

private extension CapturesScreenShellMode {
    var eyebrow: String {
        switch self {
        case .planSupport: "Plan support"
        case .topLevelCapture: "Top-level intake"
        }
    }

    var title: String {
        switch self {
        case .planSupport: "Capture"
        case .topLevelCapture: "Capture"
        }
    }

    var subtitle: String {
        switch self {
        case .planSupport:
            "Absorb raw inputs into the current week so captures feel like part of the operating system, not a separate holding bin."
        case .topLevelCapture:
            "Hold raw inputs in one calm place until they are ready to become a goal, plan adjustment, proof, or decision."
        }
    }
}

#if DEBUG
#Preview("Capture Empty") {
    NavigationStack {
        CapturesScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.empty())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Route Suggestions") {
    NavigationStack {
        CapturesScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Needs a Place") {
    NavigationStack {
        CapturesScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.needsPlace())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Manual Route") {
    NavigationStack {
        CapturesScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.manualRoute())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Dynamic Type") {
    NavigationStack {
        CapturesScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility2)
}

#Preview("Capture Reduce Motion") {
    NavigationStack {
        CapturesScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Receipt") {
    NavigationStack {
        CapturesScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.receipt())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Light") {
    NavigationStack {
        CapturesScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.light)
    .preferredColorScheme(.light)
}

@MainActor
private enum CapturePreviewFactory {
    static func empty() -> CapturesViewModel {
        CapturesViewModel(state: .loaded(CapturesViewState(captures: [], activeGoalOptions: [])))
    }

    static func routeSuggestions() -> CapturesViewModel {
        let viewModel = CapturesViewModel(state: .loaded(CapturesViewState(captures: [], activeGoalOptions: [
            CaptureGoalOption(id: "goal-music", title: "Music Goal", subtitle: "Creative")
        ])))
        viewModel.updateDraftText("Finish lyrics before rehearsal")
        return viewModel
    }

    static func needsPlace() -> CapturesViewModel {
        let viewModel = CapturesViewModel(state: .loaded(CapturesViewState(captures: [], activeGoalOptions: [])))
        viewModel.updateDraftText("NASA")
        return viewModel
    }

    static func manualRoute() -> CapturesViewModel {
        let viewModel = CapturesViewModel(state: .loaded(CapturesViewState(captures: [], activeGoalOptions: [])))
        viewModel.updateDraftText("NASA")
        viewModel.selectDraftRoute(.task)
        return viewModel
    }

    static func receipt() -> CapturesViewModel {
        let viewModel = CapturesViewModel(state: .loaded(CapturesViewState(captures: [], activeGoalOptions: [])))
        viewModel.actionMessage = CaptureActionMessage(
            title: "Saved as Task · Today",
            body: "This can become plan work later; no calendar event was created."
        )
        return viewModel
    }
}
#endif
