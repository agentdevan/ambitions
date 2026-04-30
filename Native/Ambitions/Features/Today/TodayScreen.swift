import AmbitionsDesignSystem
import SwiftUI

struct TodayScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: TodayViewModel

    private let autoLoad: Bool
    private let showsNavigationChrome: Bool

    @MainActor
    init(viewModel: TodayViewModel? = nil, autoLoad: Bool = true, showsNavigationChrome: Bool = true) {
        _viewModel = State(initialValue: viewModel ?? TodayViewModel())
        self.autoLoad = autoLoad
        self.showsNavigationChrome = showsNavigationChrome
    }

    var body: some View {
        ZStack {
            TodayBackgroundView()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                    switch viewModel.state {
                    case .loading:
                        AsyncStateCard(.loading(lines: 6))
                            .transition(.ambitionPanel)
                    case .failed:
                        DegradedStateCard(
                            state: DegradedStateOrchestrator.unavailable(surface: "Today"),
                            primaryAccessibilityIdentifier: "today.retry-button",
                            onPrimaryAction: {
                                Task {
                                    await refresh()
                                }
                            }
                        )
                        .transition(.ambitionPanel)
                    case let .loaded(experience):
                        TodayExecutionHeroPanel(state: experience.execution, onAction: handleAction)

                        if experience.mode == .empty {
                            DegradedStateCard(
                                state: DegradedStateOrchestrator.todayEmpty(),
                                primaryAccessibilityIdentifier: "today.empty.create-goal",
                                secondaryAccessibilityIdentifier: "today.empty.capture-first",
                                onPrimaryAction: {
                                    container.commandRouter.presentCreateGoal(source: .shellCompose)
                                },
                                onSecondaryAction: {
                                    container.commandRouter.presentCommandSheet(
                                        intent: .quickCapture,
                                        source: .todayQuickCapture,
                                        presentationContext: .quickCapture
                                    )
                                }
                            )
                            .transition(.ambitionPanel)
                        }

                        if let transientMessage = viewModel.transientMessage {
                            TodayMessageCard(message: transientMessage)
                                .transition(.ambitionPanel)
                        }

                        TodayExecutionSupportPanels(state: experience.execution, onAction: handleAction)
                        TodayExecutionDeepDive(state: experience.execution, onAction: handleAction)
                    }
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.vertical, theme.spacing.md)
            }
            .scrollIndicators(.hidden)
            .accessibilityIdentifier("today.screen")
            .refreshable {
                await refresh()
            }
        }
        .navigationTitle(showsNavigationChrome ? "Today" : "")
        .toolbar {
            if showsNavigationChrome {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        container.commandRouter.route(to: .planRoute(.capturesInbox), source: .shellUtility)
                    } label: {
                        Label("Capture", systemImage: AppTab.captures.systemImage)
                    }
                    .accessibilityIdentifier("today.open-captures-button")
                }
            }
        }
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: viewModel.transientMessage?.title)
        .onChange(of: container.navigation.selectedTab) { _, selectedTab in
            guard autoLoad, selectedTab == .today else { return }
            Task {
                await activate()
            }
        }
        .onChange(of: container.navigation.todayEntryContext) { _, entryContext in
            guard autoLoad, container.navigation.selectedTab == .today, entryContext != .standard else { return }
            Task {
                await activate()
            }
        }
        .task {
            guard autoLoad else { return }
            await activate()
        }
    }

    private func activate() async {
        await viewModel.activate(
            using: container.todayService,
            userDisplayName: container.session.userDisplayName,
            entryContext: container.navigation.takeTodayEntryContext()
        )
    }

    private func refresh() async {
        await viewModel.refresh(
            using: container.todayService,
            userDisplayName: container.session.userDisplayName,
            entryContext: container.navigation.takeTodayEntryContext()
        )
    }

    private func handleAction(_ action: TodayInlineAction) {
        switch action.kind {
        case .startFocus:
            container.navigation.selectToday(entryContext: .focus)
        case .openDetail, .askForHelp:
            container.navigation.openGoalDetail(
                goalID: action.target.goalID,
                draftID: action.target.draftID,
                launchContext: action.kind == .askForHelp ? .help : .standard
            )
        case .quickLog:
            container.commandRouter.presentCommandSheet(
                intent: .quickCapture,
                source: .todayQuickCapture,
                presentationContext: .quickCapture
            )
        case .openPlan:
            container.commandRouter.route(to: .tab(.plan), source: .shellUtility)
        case .protectLater:
            container.commandRouter.route(to: .tab(.plan), source: .shellUtility)
            viewModel.transientMessage = TodayInlineMessage(
                title: "Opened Plan",
                body: "Today handed this off to the canonical planning surface instead of creating a second recovery system here.",
                state: .selected
            )
        default:
            Task {
                await viewModel.handle(
                    action,
                    using: container.todayService,
                    userDisplayName: container.session.userDisplayName,
                    entryContext: .standard
                )
            }
        }
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }
}

#if DEBUG
#Preview("Today Stable") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.stable)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.stable))
    .ambitionTheme(.dark)
}

#Preview("Today Tight") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.tight)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.tight))
    .ambitionTheme(.dark)
}

#Preview("Today Recovery") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.recovery)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.recovery))
    .ambitionTheme(.dark)
}

#Preview("Today Drifted") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.drifted)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.drifted))
    .ambitionTheme(.dark)
}

#Preview("Today Overloaded") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.overloaded)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.overloaded))
    .ambitionTheme(.dark)
}

#Preview("Today Low Data") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.lowData)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.lowData))
    .ambitionTheme(.dark)
}

#Preview("Today No Plan") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.noPlan)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.noPlan))
    .ambitionTheme(.dark)
}
#endif
