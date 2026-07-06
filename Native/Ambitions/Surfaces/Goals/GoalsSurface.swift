import AmbitionsDesignSystem
import SwiftUI

struct GoalsSurface: View {
    @Environment(\.appShellCapability) private var appShellCapability
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: GoalsViewModel
    @State private var localCreationMessage: GoalDetailInlineMessage?
    let externalCreationMessage: GoalDetailInlineMessage?
    let externalRefreshID: Int
    let showsNavigationChrome: Bool
    let screenshotProofState: GoalsScreenshotProofState

    @MainActor
    init(
        viewModel: GoalsViewModel? = nil,
        creationMessage: GoalDetailInlineMessage? = nil,
        externalCreationMessage: GoalDetailInlineMessage? = nil,
        externalRefreshID: Int = 0,
        showsNavigationChrome: Bool = true
    ) {
        _viewModel = State(initialValue: viewModel ?? GoalsViewModel())
        _localCreationMessage = State(initialValue: creationMessage)
        self.externalCreationMessage = externalCreationMessage
        self.externalRefreshID = externalRefreshID
        self.showsNavigationChrome = showsNavigationChrome
        screenshotProofState = GoalsScreenshotProofState.fromLaunchArguments()
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    DegradedStateSurface(state: DegradedStateOrchestrator.objectLoading(.missionControlTimeSpine))
                case .failed:
                    DegradedStateSurface(
                        state: DegradedStateOrchestrator.objectUnavailable(.missionControlTimeSpine),
                        primaryAccessibilityIdentifier: "goals.retry-button",
                        onPrimaryAction: {
                            Task { await viewModel.refresh(using: featureFactory.goalsService) }
                        }
                    )
                case let .loaded(overview):
                    GoalsObjectView(
                        overview: overview,
                        screenshotProofState: screenshotProofState,
                        onPrimaryAction: handlePrimaryAction,
                        onOpenLifeArea: openLifeArea,
                        onCreate: openCapture
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
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .accessibilityIdentifier("goals.screen")
        .background {
            LivingSurfaceBackground(context: .goals, state: .active, intensity: 0.72)
                .stageOwnedIgnoresSafeArea()
        }
        .scrollIndicators(.hidden)
        .stageOwnedSafeAreaInset(edge: .bottom, spacing: 0) {
            Color.clear
                .frame(height: theme.spacing.xxxl)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
        .refreshable {
            await viewModel.refresh(using: featureFactory.goalsService)
        }
        .navigationTitle(showsNavigationChrome ? "Goals" : "")
        .toolbar {
            if showsNavigationChrome {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        localCreationMessage = nil
                        openCapture(kind: .goalSeed, region: nil)
                    } label: {
                        Label("Add in Goals", systemImage: "plus")
                    }
                    .accessibilityIdentifier("goals.create-button")
                }
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

    func handlePrimaryAction(_ action: GoalsAtlasPrimaryAction) {
        let intent = GoalsInteractions.intent(for: action)
        _ = GoalsInteractions.accessibilityAnnouncement(for: intent)
        switch intent {
        case .createGoal:
            localCreationMessage = nil
            openCapture(kind: .goalSeed, region: nil)
        case .openGoal, .recoverGoal, .refineStrategy:
            guard let target = action.target else { return }
            shell.navigation.openGoalDetail(target)
        }
    }

    func openLifeArea(_ region: GoalsLifeAreaAtlasRegion) {
        shell.navigation.openGoalDetail(GoalRouteTarget(lifeAreaID: region.id))
    }

    func openCapture(kind: CaptureTypedRouteKind, region: GoalsLifeAreaAtlasRegion?) {
        localCreationMessage = nil
        shell.navigation.presentTypedCaptureComposer(
            kind: kind,
            source: .goalsCreate,
            lifeAreaID: region?.isOpenField == true ? nil : region?.id
        )
    }

    func handlePromoteOneStepGoal(_ item: GoalsOneStepGoalPanelItemState) {
        localCreationMessage = GoalDetailInlineMessage(
            title: "This can become a goal later",
            body: "\(item.title) can stay as a One-Step Goal until you confirm a fuller Goal.",
            state: .selected
        )
        shell.navigation.presentTypedCaptureComposer(
            kind: .goalSeed,
            source: .goalsCreate,
            lifeAreaID: nil,
            seedText: item.title
        )
    }

    var shell: AppShellCapability {
        guard let appShellCapability else {
            preconditionFailure("App shell capability must be injected.")
        }
        return appShellCapability
    }

    var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }

    var activeCreationMessage: GoalDetailInlineMessage? {
        externalCreationMessage ?? localCreationMessage
    }
}

struct GoalsDirectionDepthDisclosure: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let overview: GoalsOverview
    @Binding var isExpanded: Bool
    let zoomMode: GoalsSemanticZoomMode
    let onZoomModeChange: (GoalsSemanticZoomMode) -> Void
    let onPromote: (GoalsOneStepGoalPanelItemState) -> Void

    var body: some View {
        StateDrivenMaterialPanel(context: .goals, state: .calm) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                Button {
                    withAnimation(theme.motion.animation(reduceMotion: reduceMotion)) {
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
                        GoalsWeekPressureSurface(summary: overview.weekPressureSummary)
                        GoalsPortfolioMaturitySurface(summary: overview.maturitySummary)
                        if let atlasPreview = overview.atlasPreview {
                            GoalAtlasPreviewSurface(state: atlasPreview)
                        }
                        GoalsLifeAreasPanel(
                            state: overview.lifeAreas,
                            zoomMode: zoomMode,
                            onZoomModeChange: onZoomModeChange
                        )
                        GoalsNorthStarsRailSurface(state: overview.northStars)
                        GoalLifePathView(overview: overview)
                        GoalsLifecycleRailSurface(segments: overview.lifecycleRail)
                        GoalStateChipsSurface(chips: overview.stateChips)
                        GoalsOneStepGoalsPanel(state: overview.oneStepGoals, onPromote: onPromote)

                        ForEach(overview.bands) { band in
                            GoalsAtlasBandSection(band: band)
                        }

                        GoalsHorizonLadderSurface(state: overview.horizonLadder)
                        GoalArchiveSummarySurface(summary: overview.archiveSummary)
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
        GoalsSurface(viewModel: GoalsViewModel(state: .loaded(PreviewGoalsScenarios.overview)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Goals After Create") {
    NavigationStack {
        GoalsSurface(
            viewModel: GoalsViewModel(state: .loaded(PreviewGoalsScenarios.createdOverview)),
            creationMessage: GoalDetailInlineMessage(
                title: "Goal created",
                body: "Ship the native create goal flow is now in Your Direction with its first 3 steps.",
                state: .success
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Goals Life Area Atlas Large Type") {
    NavigationStack {
        GoalsSurface(viewModel: GoalsViewModel(state: .loaded(PreviewGoalsScenarios.overview)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
#endif
