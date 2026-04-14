import AmbitionsDesignSystem
import SwiftUI

struct TodayScreen: View {
    @Environment(\.appContainer) private var container
    @Environment(\.ambitionTheme) private var theme
    @State private var viewModel: TodayViewModel
    @State private var dailyTargetsExpanded = true
    @State private var reflectionExpanded = false

    private let autoLoad: Bool

    init(viewModel: TodayViewModel = TodayViewModel(), autoLoad: Bool = true) {
        _viewModel = State(initialValue: viewModel)
        self.autoLoad = autoLoad
    }

    var body: some View {
        ZStack {
            TodayBackgroundView()

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    switch viewModel.state {
                    case .loading:
                        LoadingSkeletonCard(lineCount: 6)
                    case let .failed(message):
                        EmptyStateCard(
                            title: "Today is unavailable",
                            message: message,
                            icon: "exclamationmark.triangle",
                            actionTitle: "Retry"
                        ) {
                            Task {
                                await viewModel.refresh(using: container.todayService, userDisplayName: container.session.userDisplayName)
                            }
                        }
                    case let .loaded(experience):
                        TodayHeaderCard(header: experience.header)

                        if let transientMessage = viewModel.transientMessage {
                            TodayMessageCard(message: transientMessage)
                        }

                        TodayDailyTargetsCard(
                            state: experience.dailyTargets,
                            expanded: dailyTargetsExpanded,
                            toggleExpanded: { dailyTargetsExpanded.toggle() },
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
                            toggleExpanded: { reflectionExpanded.toggle() },
                            onAction: handleAction
                        )
                    }
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.vertical, theme.spacing.md)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Today")
        .task {
            guard autoLoad else { return }
            await viewModel.load(using: container.todayService, userDisplayName: container.session.userDisplayName)
        }
    }

    private func handleAction(_ action: TodayInlineAction) {
        Task {
            if action.kind == .dismissCelebration {
                viewModel.transientMessage = nil
            }
            await viewModel.handle(action, using: container.todayService, userDisplayName: container.session.userDisplayName)
        }
    }
}

#Preview("Today Seeded") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loaded(PreviewTodayScenarios.seeded)), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.seeded))
    .ambitionTheme(.dark)
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

#Preview("Today Loading") {
    NavigationStack {
        TodayScreen(viewModel: TodayViewModel(state: .loading), autoLoad: false)
    }
    .appContainer(PreviewAppContainerFactory.preview(todayExperience: PreviewTodayScenarios.seeded))
    .ambitionTheme(.dark)
}
