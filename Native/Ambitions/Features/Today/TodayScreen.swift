import AmbitionsDesignSystem
import SwiftUI

struct TodayScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: TodayViewModel
    @State private var dailyTargetsExpanded = true
    @State private var reflectionExpanded = false

    private let autoLoad: Bool

    @MainActor
    init(viewModel: TodayViewModel? = nil, autoLoad: Bool = true) {
        _viewModel = State(initialValue: viewModel ?? TodayViewModel())
        self.autoLoad = autoLoad
    }

    var body: some View {
        ZStack {
            TodayBackgroundView()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                    switch viewModel.state {
                    case .loading:
                        LoadingSkeletonCard(lineCount: 6)
                            .transition(.ambitionPanel)
                    case let .failed(message):
                        EmptyStateCard(
                            title: "Today is unavailable",
                            message: message,
                            icon: "exclamationmark.triangle",
                            actionTitle: "Retry",
                            actionAccessibilityIdentifier: "today.retry-button"
                        ) {
                            Task {
                                await viewModel.refresh(using: container.todayService, userDisplayName: container.session.userDisplayName)
                            }
                        }
                        .transition(.ambitionPanel)
                    case let .loaded(experience):
                        TodayHeaderCard(header: experience.header)

                        if let transientMessage = viewModel.transientMessage {
                            TodayMessageCard(message: transientMessage)
                                .transition(.ambitionPanel)
                        }

                        TodayDailyTargetsCard(
                            state: experience.dailyTargets,
                            expanded: dailyTargetsExpanded,
                            toggleExpanded: { toggle(&dailyTargetsExpanded) },
                            onAction: handleAction
                        )
                        TodayFocusCard(state: experience.focus, onAction: handleAction)
                        TodayFreeTimeCard(state: experience.freeTime, onAction: handleAction)
                        TodayMilestoneCard(state: experience.milestone, onAction: handleAction)
                        TodayMomentumCard(state: experience.momentum)

                        if let celebration = experience.celebration {
                            TodayCelebrationCard(state: celebration, onAction: handleAction)
                        }

                        TodayQuickCaptureCard(state: experience.quickCapture, onAction: handleAction)
                        TodayReflectionCard(
                            state: experience.reflection,
                            expanded: reflectionExpanded,
                            toggleExpanded: { toggle(&reflectionExpanded) },
                            onAction: handleAction
                        )
                    }
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.vertical, theme.spacing.md)
            }
            .scrollIndicators(.hidden)
            .accessibilityIdentifier("today.screen")
            .refreshable {
                await viewModel.refresh(using: container.todayService, userDisplayName: container.session.userDisplayName)
            }
        }
        .navigationTitle("Today")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: viewModel.transientMessage?.title)
        .onChange(of: container.navigation.selectedTab) { _, selectedTab in
            guard autoLoad, selectedTab == .today else { return }
            Task {
                await viewModel.activate(
                    using: container.todayService,
                    userDisplayName: container.session.userDisplayName
                )
            }
        }
        .task {
            guard autoLoad else { return }
            await viewModel.activate(
                using: container.todayService,
                userDisplayName: container.session.userDisplayName
            )
        }
    }

    private func handleAction(_ action: TodayInlineAction) {
        if action.kind == .openDetail || action.kind == .askForHelp {
            container.navigation.openGoalDetail(
                goalID: action.target.goalID,
                draftID: action.target.draftID,
                launchContext: action.kind == .askForHelp ? .help : .standard
            )
            return
        }

        Task {
            if action.kind == .dismissCelebration {
                viewModel.transientMessage = nil
            }
            await viewModel.handle(action, using: container.todayService, userDisplayName: container.session.userDisplayName)
        }
    }

    private func toggle(_ value: inout Bool) {
        if reduceMotion {
            value.toggle()
        } else {
            withAnimation(theme.motion.animation(reduceMotion: false)) {
                value.toggle()
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

#Preview("Today Seeded Light") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.seeded)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.seeded))
    .ambitionTheme(.light)
    .preferredColorScheme(.light)
}

#Preview("Today Seeded Dark") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.seeded)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.seeded))
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Today Empty") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.empty)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.empty))
    .ambitionTheme(.dark)
}

#Preview("Today Starter") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.starter)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.starter))
    .ambitionTheme(.dark)
}

#Preview("Today Clarification") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.clarification)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.clarification))
    .ambitionTheme(.dark)
}

#Preview("Today Blocked") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.blocked)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.blocked))
    .ambitionTheme(.dark)
}

#Preview("Today Fresh Goal") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.freshGoal)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.freshGoal))
    .ambitionTheme(.dark)
}

#Preview("Today Loading") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loading), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.seeded))
    .ambitionTheme(.dark)
}
