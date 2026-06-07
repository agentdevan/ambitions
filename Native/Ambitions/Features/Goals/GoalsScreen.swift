import AmbitionsDesignSystem
import SwiftUI

struct GoalsScreen: View {
    @Environment(\.appShellCapability) private var appShellCapability
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: GoalsViewModel
    @State private var isCreateGoalPresented = false
    @State private var localCreationMessage: GoalDetailInlineMessage?
    @State private var isDirectionDepthExpanded = false
    private let externalCreationMessage: GoalDetailInlineMessage?
    private let externalRefreshID: Int
    private let showsNavigationChrome: Bool
    private let onCreateGoal: (() -> Void)?

    @MainActor
    init(
        viewModel: GoalsViewModel? = nil,
        creationMessage: GoalDetailInlineMessage? = nil,
        externalCreationMessage: GoalDetailInlineMessage? = nil,
        externalRefreshID: Int = 0,
        showsNavigationChrome: Bool = true,
        onCreateGoal: (() -> Void)? = nil
    ) {
        _viewModel = State(initialValue: viewModel ?? GoalsViewModel())
        _localCreationMessage = State(initialValue: creationMessage)
        self.externalCreationMessage = externalCreationMessage
        self.externalRefreshID = externalRefreshID
        self.showsNavigationChrome = showsNavigationChrome
        self.onCreateGoal = onCreateGoal
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    DegradedStateCard(state: DegradedStateOrchestrator.objectLoading(.missionControlTimeSpine))
                case .failed:
                    DegradedStateCard(
                        state: DegradedStateOrchestrator.objectUnavailable(.missionControlTimeSpine),
                        primaryAccessibilityIdentifier: "goals.retry-button",
                        onPrimaryAction: {
                            Task { await viewModel.refresh(using: featureFactory.goalsService) }
                        }
                    )
                case let .loaded(overview):
                    GoalsConstellationAtlasStage(
                        overview: overview,
                        onPrimaryAction: handlePrimaryAction
                    )
                    .transition(DAVMotionPreset.heroExpansion.transition(reduceMotion: reduceMotion))

                    if let activeCreationMessage {
                        AppCard(state: activeCreationMessage.state) {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                Text(activeCreationMessage.title)
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(activeCreationMessage.body)
                                    .font(theme.typography.body)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                        }
                        .accessibilityIdentifier("goals.creation-message")
                    }

                    if hasVisibleAtlasContent(overview) {
                        GoalsDirectionDepthDisclosure(
                            overview: overview,
                            isExpanded: $isDirectionDepthExpanded,
                            zoomMode: viewModel.semanticZoomMode,
                            onZoomModeChange: { viewModel.semanticZoomMode = $0 },
                            onPromote: handlePromoteOneStepGoal
                        )
                        .transition(.ambitionPanel)
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .accessibilityIdentifier("goals.screen")
        .background {
            LivingSurfaceBackground(context: .goals, state: .active, intensity: 0.72)
                .ignoresSafeArea()
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refresh(using: featureFactory.goalsService)
        }
        .navigationTitle(showsNavigationChrome ? "Goals" : "")
        .toolbar {
            if showsNavigationChrome {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        localCreationMessage = nil
                        if let onCreateGoal {
                            onCreateGoal()
                        } else {
                            isCreateGoalPresented = true
                        }
                    } label: {
                        Label("Create Goal", systemImage: "plus")
                    }
                    .accessibilityIdentifier("goals.create-button")
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { showsNavigationChrome && isCreateGoalPresented },
            set: { isCreateGoalPresented = $0 }
        )) {
            NavigationStack {
                createGoalScreen
            }
        }
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: activeCreationMessage?.title)
        .onChange(of: externalRefreshID) { _, _ in
            guard externalRefreshID > 0 else { return }
            Task {
                await viewModel.refresh(using: featureFactory.goalsService)
            }
        }
        .task {
            await viewModel.load(using: featureFactory.goalsService)
        }
    }

    private func hasVisibleAtlasContent(_ overview: GoalsOverview) -> Bool {
        overview.bands.contains(where: { $0.cards.isEmpty == false }) || overview.lowerPriority.cards.isEmpty == false
    }

    private func handlePrimaryAction(_ action: GoalsAtlasPrimaryAction) {
        switch action.kind {
        case .createGoal:
            localCreationMessage = nil
            if let onCreateGoal {
                onCreateGoal()
            } else {
                isCreateGoalPresented = true
            }
        case .openGoal, .recoverGoal, .refineStrategy:
            guard let target = action.target else { return }
            shell.navigation.openGoalDetail(target)
        }
    }

    private func handlePromoteOneStepGoal(_ item: GoalsOneStepGoalPanelItemState) {
        localCreationMessage = GoalDetailInlineMessage(
            title: "This can become a goal later",
            body: "\(item.title) is still a standalone Task until you confirm a Goal.",
            state: .selected
        )
        if let onCreateGoal {
            onCreateGoal()
        } else {
            isCreateGoalPresented = true
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

    private var createGoalScreen: some View {
        CreateGoalScreen { response in
            let body: String = {
                switch response.resultKind {
                case .planned:
                    return "\(response.blueprint.title) is now in the portfolio with a canonical path."
                case .starterPlanned:
                    return "\(response.blueprint.title) is now in the portfolio with a starter path."
                case .clarificationRequired:
                    return "\(response.blueprint.title) needs one clarification before Ambitions treats it as a live goal."
                case .blocked:
                    return "\(response.blueprint.title) was saved as a blocked draft with the missing constraint visible."
                }
            }()
            localCreationMessage = GoalDetailInlineMessage(
                title: "Goal created",
                body: body,
                state: .success
            )
            Task {
                await viewModel.refresh(using: featureFactory.goalsService)
            }
        }
    }

    private var activeCreationMessage: GoalDetailInlineMessage? {
        externalCreationMessage ?? localCreationMessage
    }
}

private struct GoalsDirectionDepthDisclosure: View {
    @Environment(\.ambitionTheme) private var theme

    let overview: GoalsOverview
    @Binding var isExpanded: Bool
    let zoomMode: GoalsSemanticZoomMode
    let onZoomModeChange: (GoalsSemanticZoomMode) -> Void
    let onPromote: (GoalsOneStepGoalPanelItemState) -> Void

    var body: some View {
        StateDrivenMaterialPanel(context: .goals, state: .calm) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            Text("Direction depth")
                                .font(theme.typography.section)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text("Open proof, pressure, one-step goals, archive, and quieter threads after the direction summary is clear.")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: theme.spacing.sm)

                        Image(systemName: "chevron.down")
                            .font(theme.typography.caption.weight(.semibold))
                            .foregroundStyle(theme.colors.textSecondary)
                            .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("goals.direction-depth-toggle")
                .accessibilityLabel("Direction depth")
                .accessibilityValue(isExpanded ? "Expanded" : "Collapsed")
                .accessibilityHint("Shows proof, pressure, one-step goals, archive, and quieter threads.")

                if isExpanded {
                    VStack(alignment: .leading, spacing: theme.spacing.lg) {
                        GoalsWeekPressureCard(summary: overview.weekPressureSummary)
                        GoalsPortfolioMaturityCard(summary: overview.maturitySummary)
                        if let atlasPreview = overview.atlasPreview {
                            GoalAtlasPreviewCard(state: atlasPreview)
                        }
                        GoalsLifeAreasPanel(
                            state: overview.lifeAreas,
                            zoomMode: zoomMode,
                            onZoomModeChange: onZoomModeChange
                        )
                        GoalsNorthStarsRailCard(state: overview.northStars)
                        GoalLifePathView(overview: overview)
                        GoalsLifecycleRailCard(segments: overview.lifecycleRail)
                        GoalStateChipsCard(chips: overview.stateChips)
                        GoalsOneStepGoalsPanel(state: overview.oneStepGoals, onPromote: onPromote)

                        ForEach(overview.bands) { band in
                            GoalsAtlasBandSection(band: band)
                        }

                        GoalsHorizonLadderCard(state: overview.horizonLadder)
                        GoalArchiveSummaryCard(summary: overview.archiveSummary)
                        GoalsLowerPriorityDisclosureSection(
                            state: overview.lowerPriority,
                            isExpanded: isExpanded,
                            onToggle: { isExpanded.toggle() }
                        )
                    }
                    .padding(.top, theme.spacing.md)
                }
            }
        }
        .accessibilityIdentifier("goals.direction-depth")
    }
}

#if DEBUG
#Preview("Goals Overview") {
    NavigationStack {
        GoalsScreen(viewModel: GoalsViewModel(state: .loaded(PreviewGoalsScenarios.overview)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Goals After Create") {
    NavigationStack {
        GoalsScreen(
            viewModel: GoalsViewModel(state: .loaded(PreviewGoalsScenarios.createdOverview)),
            creationMessage: GoalDetailInlineMessage(
                title: "Goal created",
                body: "Ship the native create goal flow is now in the portfolio with its first 3 steps.",
                state: .success
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Goals Direction Atlas Large Type") {
    NavigationStack {
        GoalsScreen(viewModel: GoalsViewModel(state: .loaded(PreviewGoalsScenarios.overview)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
#endif
