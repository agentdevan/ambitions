import AmbitionsDesignSystem
import SwiftUI
import UIKit

struct CaptureComposerSurface: View {
    @Environment(\.appShellCapability) private var appShellCapability
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: CaptureViewModel
    @State private var isCaptureDepthExpanded = false
    private let shellMode: CaptureComposerPresentationMode
    private let mutationProofContract = CaptureComposerMutationProofContract.localSave

    @MainActor
    init(shellMode: CaptureComposerPresentationMode = .timeSupport) {
        self.shellMode = shellMode
        _viewModel = State(initialValue: CaptureViewModel())
    }

    init(
        shellMode: CaptureComposerPresentationMode,
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

                    capturePrompt

                    AtmosphereComposerCanvas(
                        inputText: Binding(
                            get: { viewModel.draftText },
                            set: { viewModel.updateDraftText($0) }
                        )
                    ) { text in
                        Task {
                            await viewModel.createQuickCapture(
                                captureService: featureFactory.captureService,
                                goalsService: featureFactory.goalsService
                            )
                        }
                    }

                    switch viewModel.state {
                    case .loading:
                        DegradedStateSurface(state: DegradedStateOrchestrator.objectLoading(.capturePlacementShelf))
                            .transition(.ambitionPanel)
                    case .failed:
                        DegradedStateSurface(
                            state: DegradedStateOrchestrator.objectUnavailable(.capturePlacementShelf),
                            primaryAccessibilityIdentifier: "capture.retry-button",
                            onPrimaryAction: {
                                Task { await load() }
                            }
                        )
                        .transition(.ambitionPanel)
                    case let .loaded(viewState):
                        if viewState.captures.isEmpty,
                           viewModel.draftRoutePreview == nil,
                           viewModel.actionMessage == nil {
                            loadedContent(viewState)
                                .transition(.ambitionPanel)
                        } else {
                            CaptureDepthDisclosureStage(
                                isExpanded: $isCaptureDepthExpanded
                            ) {
                                loadedContent(viewState)
                            }
                            .transition(.ambitionPanel)
                        }
                    }
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.top, theme.spacing.md)
                .padding(.bottom, theme.spacing.xl)
                .flagshipCaptureComposerStage(state: captureLivingState, summary: promptSubtitle)
            }
            .scrollIndicators(.hidden)

            ContextCrownHeader(
                title: "Capture",
                contextPhrase: promptSubtitle
            )
        }
        .navigationTitle("")
        .refreshable {
            await load()
        }
        .accessibilityIdentifier("capture.composer")
        .accessibilityHint(mutationProofContract.submitHint)
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .onChange(of: viewModel.actionMessage) { _, message in
            guard let message else { return }
            UIAccessibility.post(notification: .announcement, argument: message.accessibilityAnnouncement)
        }
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

    private var canSubmitDraft: Bool {
        viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private func load() async {
        await viewModel.load(captureService: featureFactory.captureService, goalsService: featureFactory.goalsService)
    }

    private var capturePrompt: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("Open Field")
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text(promptSubtitle)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            EvidenceLabel(
                "Open Field",
                detail: "Capture stays text-first and route choices stay editable after input.",
                source: "Capture",
                state: captureLivingState,
                context: .capture
            )

            if shellMode == .timeSupport {
                Button {
                    shell.navigation.resetTimePath()
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
            switch shellMode {
            case .timeSupport:
                return "What needs placement? Type one real thing; placement appears only after input."
            case .globalComposer:
                return "Where does this belong? Open Field is the first stop. Move onward to Today, Goals, Time, or You when it is ready."
            }
        }
        return "Needs placement, Ready to Place, and Open as Goal stay editable. Nothing becomes planned work until you save it."
    }

    @ViewBuilder
    private func loadedContent(_ viewState: CaptureViewState) -> some View {
        if let routePreview = viewModel.draftRoutePreview {
            draftRoutePreviewStage(routePreview)
        }

        if let message = viewModel.actionMessage {
            captureReceiptPreview(message)
        }

        if viewState.captures.isEmpty, viewModel.draftRoutePreview == nil, viewModel.actionMessage == nil {
            emptyCaptureState
        } else if viewState.captures.isEmpty == false {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                SectionHeader(
                    eyebrow: "Capture",
                    title: "Continuity lines",
                    subtitle: "Placed, parked, and still-open captures stay in one Atmosphere Composer stage instead of separate buckets."
                )

                ForEach(orderedCaptures(viewState.captures)) { capture in
                    captureStageLine(capture, activeGoalOptions: viewState.activeGoalOptions)
                }
            }
        }
    }

    private struct CaptureDepthDisclosureStage<Content: View>: View {
        @Environment(\.ambitionTheme) private var theme

        @Binding var isExpanded: Bool
        let content: Content

        init(
            isExpanded: Binding<Bool>,
            @ViewBuilder content: () -> Content
        ) {
            _isExpanded = isExpanded
            self.content = content()
        }

        var body: some View {
            CaptureStageGroup(state: .calm, accessibilityIdentifier: "capture.depth-disclosure") {
                DisclosureGroup(isExpanded: $isExpanded) {
                    content
                        .padding(.top, theme.spacing.md)
                } label: {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text("Capture depth")
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text("Open placed items, receipts, and parked capture only after the composer has taken input.")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .accessibilityElement(children: .contain)
        }
    }

    private var emptyCaptureState: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            DegradedStateSurface(
                state: DegradedStateOrchestrator.captureComposerEmpty(),
                primaryAccessibilityIdentifier: "capture.empty.start-here",
                secondaryAccessibilityIdentifier: "capture.empty.create-goal",
                onPrimaryAction: {
                    shell.commandRouter.route(to: .tab(.today), source: .shellCompose)
                },
                onSecondaryAction: {
                    shell.commandRouter.presentCreateGoal(source: .shellCompose)
                }
            )

            if shellMode == .globalComposer {
                CaptureFirstRunGuide()
            }
        }
        .accessibilityIdentifier("capture.empty")
    }

    private func captureReceiptPreview(_ message: CaptureActionMessage) -> some View {
        CaptureStageGroup(state: .proof, accessibilityIdentifier: "capture.receipt-preview") {
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
    }

    private func draftRoutePreviewStage(_ preview: CaptureDraftRoutePreview) -> some View {
        CaptureRouteStagePrimitive(preview: preview) { routeType in
            viewModel.selectDraftRoute(routeType)
        }
    }

    private func orderedCaptures(_ captures: [Capture]) -> [Capture] {
        captures.sorted { lhs, rhs in
            captureStageRank(lhs) < captureStageRank(rhs)
        }
    }

    private func captureStageRank(_ capture: Capture) -> Int {
        switch capture.status {
        case .needsTriage, .actionable:
            return 0
        case .seed, .goalBound, .scheduled, .delegated:
            return 1
        case .waiting, .optionalSomeday, .archived:
            return 2
        }
    }

    private func captureStageLine(_ capture: Capture, activeGoalOptions: [CaptureGoalOption]) -> some View {
        CaptureContinuityLine(
            capture: capture,
            activeGoalOptions: activeGoalOptions,
            mutationProofContract: mutationProofContract,
            onRouteToTime: routeToTime,
            onCreateGoal: presentCreateGoal,
            onSaveToNeedsPlace: saveToNeedsPlace,
            onAttachToGoal: attachToGoal,
            onMarkDeliverableSeed: markDeliverableSeed,
            onMarkWaiting: markWaiting,
            onMarkOptionalSomeday: markOptionalSomeday,
            onArchive: archive
        )
    }

    private func routeToTime(_ capture: Capture) {
        Task {
            await viewModel.routeToTime(id: capture.id, captureService: featureFactory.captureService, goalsService: featureFactory.goalsService)
        }
    }

    private func presentCreateGoal(_ capture: Capture) {
        shell.commandRouter.presentCreateGoal(source: .globalCaptureComposer, seedText: capture.rawText, captureID: capture.id)
    }

    private func saveToNeedsPlace(_ capture: Capture) {
        Task {
            await viewModel.saveToNeedsPlace(id: capture.id, captureService: featureFactory.captureService, goalsService: featureFactory.goalsService)
        }
    }

    private func attachToGoal(_ capture: Capture, option: CaptureGoalOption) {
        Task {
            if let target = await viewModel.attachToGoal(
                captureID: capture.id,
                goalID: option.id,
                goalTitle: option.title,
                captureService: featureFactory.captureService,
                goalsService: featureFactory.goalsService
            ) {
                guard let goalID = target.goalID else { return }
                shell.navigation.openGoalDetail(goalID: goalID, draftID: target.draftID)
            }
        }
    }

    private func markDeliverableSeed(_ capture: Capture) {
        Task {
            await viewModel.markDeliverableSeed(id: capture.id, text: capture.rawText, captureService: featureFactory.captureService, goalsService: featureFactory.goalsService)
        }
    }

    private func markWaiting(_ capture: Capture) {
        Task {
            await viewModel.markWaiting(id: capture.id, captureService: featureFactory.captureService, goalsService: featureFactory.goalsService)
        }
    }

    private func markOptionalSomeday(_ capture: Capture) {
        Task {
            await viewModel.markOptionalSomeday(id: capture.id, captureService: featureFactory.captureService, goalsService: featureFactory.goalsService)
        }
    }

    private func archive(_ capture: Capture) {
        Task {
            await viewModel.archive(id: capture.id, captureService: featureFactory.captureService, goalsService: featureFactory.goalsService)
        }
    }

    private var shell: AppShellCapability {
        guard let appShellCapability else {
            preconditionFailure("App shell capability must be injected.")
        }
        return appShellCapability
    }

    private var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }
}
