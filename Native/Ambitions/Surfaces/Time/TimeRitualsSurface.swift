import AmbitionsDesignSystem
import SwiftUI
import UIKit

struct TimeRitualsSurface: View {
    @Environment(\.appShellCapability) private var appShellCapability
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: TimeRitualsViewModel

    @MainActor
    init(viewModel: TimeRitualsViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? TimeRitualsViewModel())
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
                    DegradedStateSurface(
                        state: DegradedStateOrchestrator.unavailable(surface: "Rituals"),
                        primaryAccessibilityIdentifier: "habits.retry-button",
                        onPrimaryAction: {
                            Task { await refresh() }
                        }
                    )
                case let .loaded(dashboard):
                    TimeRitualsHeroView(dashboard: dashboard)

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
                                    viewModel.recordStageRouteMutation(label: "Returning to Time", routeID: "time")
                                    shell.navigation.resetTimePath()
                                }
                                .buttonStyle(.bordered)
                                .accessibilityIdentifier("habits.return-to-plan")

                                Button("Weekly Review") {
                                    viewModel.recordStageRouteMutation(label: "Opening Weekly Review", routeID: "weekly-review")
                                    shell.navigation.openWeeklyReview()
                                }
                                .buttonStyle(.borderedProminent)
                                .accessibilityIdentifier("habits.open-weekly-review")
                            }
                        }
                    }

                    if let inlineMessage = viewModel.inlineMessage {
                        TodayMessageSurface(
                            message: TodayInlineMessage(
                                title: inlineMessage.title,
                                body: inlineMessage.body,
                                state: inlineMessage.state
                            )
                        )
                    }

                    if let emptyTitle = dashboard.emptyTitle, let emptyMessage = dashboard.emptyMessage {
                        DegradedStateSurface(
                            state: DegradedStateOrchestrator.habitsEmpty(),
                            primaryAccessibilityIdentifier: "habits.empty.return-time",
                            onPrimaryAction: {
                                _ = emptyTitle
                                _ = emptyMessage
                                shell.navigation.resetTimePath()
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

                    TimeRitualRecoveryView(streak: dashboard.streak)

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
            await refresh()
        }
        .navigationTitle("Rituals")
        .accessibilityIdentifier("time.rituals.surface")
        .accessibilityElement(children: .contain)
        .accessibilityLabel(viewModel.accessibilitySummary)
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .onChange(of: viewModel.mutationProof?.id) { _, _ in
            postMutationAccessibilityAnnouncement()
        }
        .task {
            await viewModel.load(using: featureFactory.habitsService, now: clock.now)
        }
    }

    private func habitsSection(title: String, subtitle: String, habits: [HabitSummary]) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: title, subtitle: subtitle)
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(habits) { habit in
                        TimeRitualRowView(habit: habit, onAction: handleAction)
                    }
                }
            }
        }
    }

    private func handleAction(_ action: HabitActionState) {
        if action.kind == .openDetail {
            viewModel.recordStageRouteMutation(action: action)
            shell.navigation.openGoalDetail(
                goalID: action.target.goalID,
                draftID: action.target.draftID,
                launchContext: .standard
            )
            return
        }

        Task {
            await viewModel.perform(action, using: featureFactory.habitsService, now: clock.now)
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

    private var clock: any AmbitionsClock {
        featureFactory.clock
    }

    private func refresh() async {
        await viewModel.refresh(using: featureFactory.habitsService, now: clock.now)
    }

    private func postMutationAccessibilityAnnouncement() {
        guard let announcement = viewModel.mutationProof?.accessibilityAnnouncement else { return }
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }
}

#if DEBUG
#Preview("Rituals Active Light") {
    NavigationStack {
        TimeRitualsSurface(viewModel: TimeRitualsViewModel(state: .loaded(PreviewHabitsScenarios.active)))
    }
    .appContainer(PreviewAppContainerFactory.preview(habitsDashboard: PreviewHabitsScenarios.active))
    .ambitionTheme(.light)
    .preferredColorScheme(.light)
}

#Preview("Rituals Active Dark") {
    NavigationStack {
        TimeRitualsSurface(viewModel: TimeRitualsViewModel(state: .loaded(PreviewHabitsScenarios.active)))
    }
    .appContainer(PreviewAppContainerFactory.preview(habitsDashboard: PreviewHabitsScenarios.active))
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Rituals Recovery") {
    NavigationStack {
        TimeRitualsSurface(viewModel: TimeRitualsViewModel(state: .loaded(PreviewHabitsScenarios.recovery)))
    }
    .appContainer(PreviewAppContainerFactory.preview(habitsDashboard: PreviewHabitsScenarios.recovery))
    .ambitionTheme(.dark)
}

#Preview("Rituals Empty") {
    NavigationStack {
        TimeRitualsSurface(viewModel: TimeRitualsViewModel(state: .loaded(PreviewHabitsScenarios.empty)))
    }
    .appContainer(PreviewAppContainerFactory.preview(habitsDashboard: PreviewHabitsScenarios.empty))
    .ambitionTheme(.dark)
}

#Preview("Rituals Seeded") {
    NavigationStack {
        TimeRitualsSurface(viewModel: TimeRitualsViewModel(state: .loaded(PreviewHabitsScenarios.seeded)))
    }
    .appContainer(PreviewAppContainerFactory.preview(habitsDashboard: PreviewHabitsScenarios.seeded))
    .ambitionTheme(.dark)
}
#endif
