import AmbitionsDesignSystem
import SwiftUI

struct HabitsScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: HabitsViewModel

    @MainActor
    init(viewModel: HabitsViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? HabitsViewModel())
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    HeroCard {
                        SectionHeader(
                            eyebrow: "Rituals",
                            title: "Consistency that stays usable",
                            subtitle: "Loading recurring loops, recovery signals, and the lightest valid next actions."
                        )
                    }
                    LoadingSkeletonCard(lineCount: 10)
                case .failed:
                    DegradedStateCard(
                        state: DegradedStateOrchestrator.unavailable(surface: "Rituals"),
                        primaryAccessibilityIdentifier: "habits.retry-button",
                        onPrimaryAction: {
                            Task { await viewModel.refresh(using: container.habitsService) }
                        }
                    )
                case let .loaded(dashboard):
                    HabitsHeroCard(dashboard: dashboard)

                    AppCard {
                        VStack(alignment: .leading, spacing: theme.spacing.md) {
                            SectionHeader(
                                title: "Rituals inside Time",
                                subtitle: "Routines should support week shape, not compete with it."
                            )

                            Text("Use this route to soften, keep, or trim repeatable loops based on what the current week can actually carry.")
                                .font(theme.typography.body)
                                .foregroundStyle(theme.colors.textSecondary)

                            HStack(spacing: theme.spacing.sm) {
                                Button("Return to Time") {
                                    container.navigation.resetPlanPath()
                                }
                                .buttonStyle(.bordered)
                                .accessibilityIdentifier("habits.return-to-plan")

                                Button("Weekly Review") {
                                    container.navigation.openWeeklyReview()
                                }
                                .buttonStyle(.borderedProminent)
                                .accessibilityIdentifier("habits.open-weekly-review")
                            }
                        }
                    }

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
                        DegradedStateCard(
                            state: DegradedStateOrchestrator.habitsEmpty(),
                            primaryAccessibilityIdentifier: "habits.empty.return-plan",
                            onPrimaryAction: {
                                _ = emptyTitle
                                _ = emptyMessage
                                container.navigation.resetPlanPath()
                            }
                        )
                    } else {
                        if !dashboard.habits.isEmpty {
                            habitsSection(
                                title: "Today",
                                subtitle: "Fast logging keeps recurring rituals lightweight enough to use every day.",
                                habits: dashboard.habits
                            )
                        }

                        if !dashboard.recoveryHabits.isEmpty {
                            habitsSection(
                                title: "Recovery",
                                subtitle: "These loops need a gentler restart, a smaller version, or a ritual-plan correction.",
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
        .navigationTitle("Rituals")
        .accessibilityIdentifier("habits.screen")
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

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }
}

#if DEBUG
#Preview("Rituals Active Light") {
    NavigationStack {
        HabitsScreen(viewModel: HabitsViewModel(state: .loaded(PreviewHabitsScenarios.active)))
    }
    .appContainer(PreviewAppContainerFactory.preview(habitsDashboard: PreviewHabitsScenarios.active))
    .ambitionTheme(.light)
    .preferredColorScheme(.light)
}

#Preview("Rituals Active Dark") {
    NavigationStack {
        HabitsScreen(viewModel: HabitsViewModel(state: .loaded(PreviewHabitsScenarios.active)))
    }
    .appContainer(PreviewAppContainerFactory.preview(habitsDashboard: PreviewHabitsScenarios.active))
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Rituals Recovery") {
    NavigationStack {
        HabitsScreen(viewModel: HabitsViewModel(state: .loaded(PreviewHabitsScenarios.recovery)))
    }
    .appContainer(PreviewAppContainerFactory.preview(habitsDashboard: PreviewHabitsScenarios.recovery))
    .ambitionTheme(.dark)
}

#Preview("Rituals Empty") {
    NavigationStack {
        HabitsScreen(viewModel: HabitsViewModel(state: .loaded(PreviewHabitsScenarios.empty)))
    }
    .appContainer(PreviewAppContainerFactory.preview(habitsDashboard: PreviewHabitsScenarios.empty))
    .ambitionTheme(.dark)
}

#Preview("Rituals Seeded") {
    NavigationStack {
        HabitsScreen(viewModel: HabitsViewModel(state: .loaded(PreviewHabitsScenarios.seeded)))
    }
    .appContainer(PreviewAppContainerFactory.preview(habitsDashboard: PreviewHabitsScenarios.seeded))
    .ambitionTheme(.dark)
}
#endif
