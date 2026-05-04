import AmbitionsDesignSystem
import SwiftUI

struct GoalsScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: GoalsViewModel
    @State private var isCreateGoalPresented = false
    @State private var localCreationMessage: GoalDetailInlineMessage?
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
                TopLevelSurfaceCompositionBar(surface: .goals)

                switch viewModel.state {
                case .loading:
                    HeroCard {
                        SectionHeader(
                            eyebrow: "Direction Board",
                            title: "Goals",
                            subtitle: "Loading the current board, direction pressure, and horizon signals."
                        )
                    }
                    AsyncStateCard(.loading(lines: 8))
                case .failed:
                    DegradedStateCard(
                        state: DegradedStateOrchestrator.unavailable(surface: "Goals"),
                        primaryAccessibilityIdentifier: "goals.retry-button",
                        onPrimaryAction: {
                            Task { await viewModel.refresh(using: container.goalsService) }
                        }
                    )
                case let .loaded(overview):
                    GoalMissionControlLanes(
                        overview: overview,
                        onPrimaryAction: handlePrimaryAction
                    )
                    .transition(DAVMotionPreset.heroExpansion.transition(reduceMotion: reduceMotion))

                    GoalLifePathView(overview: overview)
                        .transition(.ambitionPanel)

                    GoalsWeekPressureCard(summary: overview.weekPressureSummary)
                        .transition(.ambitionPanel)
                    GoalsPortfolioMaturityCard(summary: overview.maturitySummary)
                        .transition(.ambitionPanel)
                    GoalsLifecycleRailCard(segments: overview.lifecycleRail)
                        .transition(.ambitionPanel)
                    GoalStateChipsCard(chips: overview.stateChips)
                        .transition(.ambitionPanel)

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

                    GoalsLifeAreasPanel(
                        state: overview.lifeAreas,
                        zoomMode: viewModel.semanticZoomMode,
                        onZoomModeChange: { viewModel.semanticZoomMode = $0 }
                    )
                    .transition(.ambitionPanel)

                    GoalsNorthStarsRailCard(state: overview.northStars)
                        .transition(.ambitionPanel)

                    GoalsOneStepGoalsPanel(
                        state: overview.oneStepGoals,
                        onPromote: handlePromoteOneStepGoal
                    )
                    .transition(.ambitionPanel)

                    if hasVisibleBoardContent(overview) == false {
                        DegradedStateCard(
                            state: DegradedStateOrchestrator.goalsEmpty(),
                            primaryAccessibilityIdentifier: "goals.empty.create-goal",
                            secondaryAccessibilityIdentifier: "goals.empty.capture-first",
                            onPrimaryAction: {
                                localCreationMessage = nil
                                if let onCreateGoal {
                                    onCreateGoal()
                                } else {
                                    isCreateGoalPresented = true
                                }
                            },
                            onSecondaryAction: {
                                container.commandRouter.presentCommandSheet(
                                    intent: .quickCapture,
                                    source: .shellCompose,
                                    presentationContext: .quickCapture
                                )
                            }
                        )
                    } else {
                        ForEach(overview.bands) { band in
                            GoalsBoardBandSection(band: band)
                                .transition(.ambitionPanel)
                        }

                        GoalsHorizonLadderCard(state: overview.horizonLadder)
                            .transition(.ambitionPanel)

                        if let atlasPreview = overview.atlasPreview {
                            GoalAtlasPreviewCard(state: atlasPreview)
                                .transition(.ambitionPanel)
                        }

                        GoalArchiveSummaryCard(summary: overview.archiveSummary)
                            .transition(.ambitionPanel)

                        GoalsLowerPriorityDisclosureSection(
                            state: overview.lowerPriority,
                            isExpanded: viewModel.isLowerPriorityExpanded,
                            onToggle: {
                                viewModel.isLowerPriorityExpanded.toggle()
                            }
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
            await viewModel.refresh(using: container.goalsService)
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
                await viewModel.refresh(using: container.goalsService)
            }
        }
        .task {
            await viewModel.load(using: container.goalsService)
        }
    }

    private func hasVisibleBoardContent(_ overview: GoalsOverview) -> Bool {
        overview.bands.contains(where: { $0.cards.isEmpty == false }) || overview.lowerPriority.cards.isEmpty == false
    }

    private func handlePrimaryAction(_ action: GoalsBoardPrimaryAction) {
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
            container.navigation.openGoalDetail(target)
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

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }

    private var createGoalScreen: some View {
        CreateGoalScreen { response in
            let body: String = {
                switch response.resultKind {
                case .planned:
                    return "\(response.blueprint.title) is now in the portfolio with a canonical plan."
                case .starterPlanned:
                    return "\(response.blueprint.title) is now in the portfolio with a starter plan."
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
                await viewModel.refresh(using: container.goalsService)
            }
        }
    }

    private var activeCreationMessage: GoalDetailInlineMessage? {
        externalCreationMessage ?? localCreationMessage
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

#Preview("Goals Mission Control Large Type") {
    NavigationStack {
        GoalsScreen(viewModel: GoalsViewModel(state: .loaded(PreviewGoalsScenarios.overview)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
#endif
