import AmbitionsDesignSystem
import SwiftUI

enum CaptureScreenShellMode: Equatable {
    case timeSupport
    case topLevelCapture
}

struct CaptureScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: CaptureViewModel
    private let shellMode: CaptureScreenShellMode

    @MainActor
    init(shellMode: CaptureScreenShellMode = .timeSupport) {
        self.shellMode = shellMode
        _viewModel = State(initialValue: CaptureViewModel())
    }

    init(
        shellMode: CaptureScreenShellMode,
        viewModel: CaptureViewModel
    ) {
        self.shellMode = shellMode
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .top) {
            LivingSurfaceBackground(context: .capture, state: captureLivingState, intensity: 0.68)
                .ignoresSafeArea()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                    Spacer()
                        .frame(height: 60)

                    AtmosphereComposerCanvas(
                        inputText: Binding(
                            get: { viewModel.draftText },
                            set: { viewModel.updateDraftText($0) }
                        )
                    ) { text in
                        Task {
                            await viewModel.createQuickCapture(
                                captureService: container.captureService,
                                goalsService: container.goalsService
                            )
                        }
                    }

                    switch viewModel.state {
                    case .loading:
                        DegradedStateCard(state: DegradedStateOrchestrator.objectLoading(.capturePlacementShelf))
                            .transition(.ambitionPanel)
                    case .failed:
                        DegradedStateCard(
                            state: DegradedStateOrchestrator.objectUnavailable(.capturePlacementShelf),
                            primaryAccessibilityIdentifier: "capture.retry-button",
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

            ContextCrownHeader(
                title: "Capture",
                contextPhrase: promptSubtitle
            )
            .ignoresSafeArea(edges: .top)
        }
        .navigationTitle("")
        .refreshable {
            await load()
        }
        .accessibilityIdentifier("capture.screen")
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
            Text("Capture Anything")
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text(promptSubtitle)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            EvidenceLabel(
                "Atmosphere Composer",
                detail: "Capture stays text-first and route choices stay editable after input.",
                source: "Capture",
                state: captureLivingState,
                context: .capture
            )

            if shellMode == .timeSupport {
                Button {
                    container.navigation.resetTimePath()
                } label: {
                    Label("Time", systemImage: "calendar")
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("capture.return-to-time")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("capture.prompt")
    }

    private var promptSubtitle: String {
        let draftIsEmpty = viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if draftIsEmpty {
            return "What needs a place? Type one real thing; placement appears only after input."
        }
        return "Needs a Place, Ready to Place, and Grow into Goal stay editable. Nothing becomes planned work until you save it."
    }

    @ViewBuilder
    private func loadedContent(_ viewState: CaptureViewState) -> some View {
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
        .accessibilityIdentifier("capture.empty")
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
        .accessibilityIdentifier("capture.receipt-preview")
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
            CaptureGroup(title: "Placed", subtitle: "Items with a visible destination but no Time scheduling here.", captures: routed),
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
                    .accessibilityIdentifier("capture.metadata.\(capture.id)")

                if let assumption = capture.assumptionSummary {
                    TrustSeamExplainer(
                        title: "Suggested Route Alignment",
                        reason: assumption,
                        confidence: 0.86,
                        source: capture.sourceType?.title ?? "Local System",
                        onOverride: {
                            // Custom override action hook
                        },
                        onAccept: {
                            // Confirm recommendation action hook
                        }
                    )
                }

                placementReview(capture.placementReviewState, correction: capture.correctionReviewState)
                if canPromoteCaptureToGoal(capture) {
                    goalSeedIncubator(capture.goalSeedIncubatorState)
                }

                captureActions(for: capture, activeGoalOptions: activeGoalOptions)
            }
        }
    }

    private func placementReview(
        _ review: CapturePlacementReviewState,
        correction: CaptureCorrectionReviewState
    ) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Divider()

            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Label(review.title, systemImage: "tray.and.arrow.down")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer()
                TagPill(review.placementStateTitle, state: review.state)
            }

            Label(review.destinationLabel, systemImage: "arrow.triangle.branch")
            Label(review.consequenceLabel, systemImage: "checkmark.seal")
            Label(review.privacyLabel, systemImage: "lock.shield")
            Label(review.confirmationLabel, systemImage: "hand.raised")
            Label(review.archiveLabel, systemImage: "archivebox")

            Label(correction.title, systemImage: "arrow.uturn.backward")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
            Label(correction.routeCorrectionLabel, systemImage: "arrow.triangle.branch")
            Label(correction.notGoalLabel, systemImage: "target")
            Label(correction.notNowLabel, systemImage: "moon")
            Label(correction.receiptLabel, systemImage: "doc.text.magnifyingglass")
            Label(correction.learningBoundaryLabel, systemImage: "hand.raised")
        }
        .font(theme.typography.caption)
        .foregroundStyle(theme.colors.textSecondary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(review.title)
        .accessibilityValue([review.accessibilityValue, correction.accessibilityValue].joined(separator: ". "))
        .accessibilityIdentifier("capture.placement-review.\(review.id)")
    }

    private func goalSeedIncubator(_ state: CaptureGoalSeedIncubatorState) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Divider()

            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Label(state.title, systemImage: "seedling")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer()
                TagPill("Confirm first", state: state.state)
            }

            Label(state.whyGoalLabel, systemImage: "questionmark.circle")
            Label(state.startingPositionProofLabel, systemImage: "location")
            Label(state.firstMilestoneAnchorLabel, systemImage: "flag")
            Label(state.firstStepLabel, systemImage: "arrow.forward.circle")
            Label(state.proofSourceSeedLabel, systemImage: "doc.text.magnifyingglass")
            Label(state.promotionConfirmationLabel, systemImage: "hand.raised")
        }
        .font(theme.typography.caption)
        .foregroundStyle(theme.colors.textSecondary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(state.title)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityIdentifier("capture.goal-seed-incubator.\(state.id)")
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
                        await viewModel.routeToTime(
                            id: capture.id,
                            captureService: container.captureService,
                            goalsService: container.goalsService
                        )
                    }
                } label: {
                    Label("Ready to Place", systemImage: "checkmark.circle")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .scheduled) == false)

                Button {
                    container.commandRouter.presentCreateGoal(
                        source: .captureScreen,
                        seedText: capture.rawText,
                        captureID: capture.id
                    )
                } label: {
                    Label("Grow into Goal", systemImage: "target")
                }
                .buttonStyle(.borderedProminent)
                .disabled(canPromoteCaptureToGoal(capture) == false)
                .accessibilityIdentifier("capture.new-goal.\(capture.id)")
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

private extension CaptureScreenShellMode {
    var eyebrow: String {
        switch self {
        case .timeSupport: "Time support"
        case .topLevelCapture: "Top-level intake"
        }
    }

    var title: String {
        switch self {
        case .timeSupport: "Capture"
        case .topLevelCapture: "Capture"
        }
    }

    var subtitle: String {
        switch self {
        case .timeSupport:
            "Absorb raw inputs into the current week without turning Capture into a feed, inbox, or category board."
        case .topLevelCapture:
            "Capture Anything stays calm until a thought is ready to place, grow into a goal, or hold as Needs a Place."
        }
    }
}

#if DEBUG
#Preview("Capture Empty") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.empty())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Route Suggestions") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Needs a Place") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.needsPlace())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Manual Route") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.manualRoute())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Dynamic Type") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility2)
}

#Preview("Capture Reduce Motion") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Receipt") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.receipt())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Light") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.light)
    .preferredColorScheme(.light)
}

@MainActor
private enum CapturePreviewFactory {
    static func empty() -> CaptureViewModel {
        CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [])))
    }

    static func routeSuggestions() -> CaptureViewModel {
        let viewModel = CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [
            CaptureGoalOption(id: "goal-music", title: "Music Goal", subtitle: "Creative")
        ])))
        viewModel.updateDraftText("Finish lyrics before rehearsal")
        return viewModel
    }

    static func needsPlace() -> CaptureViewModel {
        let viewModel = CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [])))
        viewModel.updateDraftText("NASA")
        return viewModel
    }

    static func manualRoute() -> CaptureViewModel {
        let viewModel = CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [])))
        viewModel.updateDraftText("NASA")
        viewModel.selectDraftRoute(.task)
        return viewModel
    }

    static func receipt() -> CaptureViewModel {
        let viewModel = CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [])))
        viewModel.actionMessage = CaptureActionMessage(
            title: "Saved as Task · Today",
            body: "This can become plan work later; no calendar event was created."
        )
        return viewModel
    }
}
#endif
