import AmbitionsDesignSystem
import SwiftUI

struct HabitsScreen: View {
    @Environment(\.appContainer) private var container
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: HabitsViewModel

    init(viewModel: HabitsViewModel = HabitsViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    HeroCard {
                        SectionHeader(
                            eyebrow: "Habits",
                            title: "Consistency that stays usable",
                            subtitle: "Loading recurring loops, recovery signals, and the lightest valid next actions."
                        )
                    }
                    LoadingSkeletonCard(lineCount: 10)
                case let .failed(message):
                    EmptyStateCard(
                        title: "Habits are unavailable",
                        message: message,
                        icon: "exclamationmark.triangle",
                        actionTitle: "Retry"
                    ) {
                        Task { await viewModel.refresh(using: container.habitsService) }
                    }
                case let .loaded(dashboard):
                    HabitsHeroCard(dashboard: dashboard)

                    if let inlineMessage = viewModel.inlineMessage {
                        TodayMessageCard(
                            message: TodayInlineMessage(
                                title: inlineMessage.title,
                                body: inlineMessage.body,
                                state: inlineMessage.state
                            )
                        )
                    }

                    if let emptyTitle = dashboard.emptyTitle, let emptyMessage = dashboard.emptyMessage {
                        EmptyStateCard(title: emptyTitle, message: emptyMessage, icon: "repeat")
                    } else {
                        if !dashboard.habits.isEmpty {
                            habitsSection(
                                title: "Today",
                                subtitle: "Fast logging keeps recurring behavior lightweight enough to use every day.",
                                habits: dashboard.habits
                            )
                        }

                        if !dashboard.recoveryHabits.isEmpty {
                            habitsSection(
                                title: "Recovery",
                                subtitle: "These loops need a gentler restart, a smaller version, or a habit-plan correction.",
                                habits: dashboard.recoveryHabits
                            )
                        }
                    }

                    HabitsRecoveryCard(streak: dashboard.streak)

                    AppCard {
                        SectionHeader(title: dashboard.guidanceTitle, subtitle: dashboard.guidanceBody)
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refresh(using: container.habitsService)
        }
        .navigationTitle("Habits")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            await viewModel.load(using: container.habitsService)
        }
    }

    private func habitsSection(title: String, subtitle: String, habits: [HabitSummary]) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: title, subtitle: subtitle)
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(habits) { habit in
                        HabitRowCard(habit: habit, onAction: handleAction)
                    }
                }
            }
        }
    }

    private func handleAction(_ action: HabitActionState) {
        if action.kind == .openDetail {
            container.navigation.openGoalDetail(
                goalID: action.target.goalID,
                draftID: action.target.draftID,
                launchContext: .standard
            )
            return
        }

        Task {
            await viewModel.perform(action, using: container.habitsService)
        }
    }
}

#Preview("Habits Active") {
    NavigationStack {
        HabitsScreen(viewModel: HabitsViewModel(state: .loaded(PreviewHabitsScenarios.active)))
    }
    .appContainer(PreviewAppContainerFactory.preview(habitsDashboard: PreviewHabitsScenarios.active))
    .ambitionTheme(.dark)
}

#Preview("Habits Recovery") {
    NavigationStack {
        HabitsScreen(viewModel: HabitsViewModel(state: .loaded(PreviewHabitsScenarios.recovery)))
    }
    .appContainer(PreviewAppContainerFactory.preview(habitsDashboard: PreviewHabitsScenarios.recovery))
    .ambitionTheme(.dark)
}

#Preview("Habits Empty") {
    NavigationStack {
        HabitsScreen(viewModel: HabitsViewModel(state: .loaded(PreviewHabitsScenarios.empty)))
    }
    .appContainer(PreviewAppContainerFactory.preview(habitsDashboard: PreviewHabitsScenarios.empty))
    .ambitionTheme(.dark)
}

#Preview("Habits Seeded") {
    NavigationStack {
        HabitsScreen(viewModel: HabitsViewModel(state: .loaded(PreviewHabitsScenarios.seeded)))
    }
    .appContainer(PreviewAppContainerFactory.preview(habitsDashboard: PreviewHabitsScenarios.seeded))
    .ambitionTheme(.dark)
}
