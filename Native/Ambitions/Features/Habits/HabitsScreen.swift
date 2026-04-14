import AmbitionsDesignSystem
import AmbitionsWidgetUI
import SwiftUI

struct HabitsScreen: View {
    @Environment(\.appContainer) private var container
    @State private var state: AsyncViewState<HabitsDashboard> = .loading

    var body: some View {
        FeatureScaffoldView(
            title: "Habits",
            subtitle: "These loops are placeholder-backed today, but the surface contract is native and production-oriented."
        ) {
            switch state {
            case .loading:
                ProgressView("Loading habits")
                    .frame(maxWidth: .infinity, alignment: .leading)
            case let .failed(message):
                Text(message)
                    .foregroundStyle(.secondary)
            case let .loaded(dashboard):
                WidgetFeed(items: [
                    WidgetFeedItem(id: "habit-summary", priority: .hero, variant: .expanded) {
                        HabitSummaryWidget(viewModel: habitsViewModel(dashboard), onAction: handleAction)
                    },
                    WidgetFeedItem(id: "habit-streak", priority: .high, variant: .compact) {
                        StreakWidget(viewModel: streakViewModel(dashboard), onAction: handleAction)
                    }
                ])
            }
        }
        .navigationTitle("Habits")
        .task {
            guard case .loading = state else { return }
            await load()
        }
    }

    private func load() async {
        do {
            state = .loaded(try await container.habitsService.loadHabitsDashboard())
        } catch {
            state = .failed("Unable to load Habits: \(error.localizedDescription)")
        }
    }

    private func handleAction(_ action: WidgetAction) {
        Task {
            await container.actionRouter.handle(action)
        }
    }

    private func habitsViewModel(_ dashboard: HabitsDashboard) -> HabitSummaryWidgetViewModel {
        HabitSummaryWidgetViewModel(
            snapshot: WidgetSnapshot(
                metadata: WidgetMetadata(
                    identity: WidgetIdentity(family: .habitSummary, instanceID: "primary"),
                    priority: .hero,
                    variant: .expanded,
                    chrome: .appCard,
                    supportedActions: [.quickLog, .openDetail]
                ),
                state: .ready(
                    HabitSummaryContent(
                        title: dashboard.title,
                        subtitle: dashboard.subtitle,
                        stats: dashboard.stats.map {
                            WidgetStat(
                                id: $0.id,
                                title: $0.title,
                                value: $0.value,
                                detail: $0.detail,
                                icon: $0.icon
                            )
                        },
                        habits: dashboard.habits.map {
                            WidgetProgressItem(
                                id: $0.id,
                                title: $0.title,
                                detail: $0.detail,
                                progress: $0.progress,
                                trailingValue: $0.trailingValue,
                                statusLabel: $0.statusLabel
                            )
                        },
                        actions: [
                            WidgetInlineActionDescriptor(kind: .quickLog, title: "Quick log", icon: "checkmark.circle"),
                            WidgetInlineActionDescriptor(kind: .openDetail, title: "Open habits", icon: "list.bullet")
                        ]
                    )
                )
            )
        )
    }

    private func streakViewModel(_ dashboard: HabitsDashboard) -> StreakWidgetViewModel {
        StreakWidgetViewModel(
            snapshot: WidgetSnapshot(
                metadata: WidgetMetadata(
                    identity: WidgetIdentity(family: .streak, instanceID: "primary"),
                    priority: .high,
                    variant: .compact,
                    chrome: .widgetCard,
                    supportedActions: [.quickLog]
                ),
                state: .ready(
                    StreakContent(
                        title: dashboard.streak.title,
                        subtitle: dashboard.streak.subtitle,
                        stats: dashboard.streak.stats.map {
                            WidgetStat(
                                id: $0.id,
                                title: $0.title,
                                value: $0.value,
                                detail: $0.detail,
                                icon: $0.icon
                            )
                        },
                        recoveryNote: dashboard.streak.recoveryNote,
                        actions: [
                            WidgetInlineActionDescriptor(kind: .quickLog, title: "Protect streak", icon: "flame")
                        ]
                    )
                )
            )
        )
    }
}

#Preview("Habits") {
    NavigationStack {
        HabitsScreen()
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
