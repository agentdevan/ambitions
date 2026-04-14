import AmbitionsDesignSystem
import AmbitionsWidgetUI
import SwiftUI

struct TodayScreen: View {
    @Environment(\.appContainer) private var container
    @State private var state: AsyncViewState<TodayDashboard> = .loading

    var body: some View {
        FeatureScaffoldView(
            title: "Today",
            subtitle: "Native-first orchestration for the day, using WidgetUI surfaces as the first production shell."
        ) {
            switch state {
            case .loading:
                ProgressView("Loading today")
                    .frame(maxWidth: .infinity, alignment: .leading)
            case let .failed(message):
                Text(message)
                    .foregroundStyle(.secondary)
            case let .loaded(dashboard):
                WidgetFeed(items: [
                    WidgetFeedItem(id: "today-targets", priority: .hero, variant: .expanded) {
                        DailyTargetsWidget(viewModel: dailyTargetsViewModel(dashboard), onAction: handleAction)
                    },
                    WidgetFeedItem(id: "today-focus", priority: .high, variant: .expanded) {
                        FocusNowWidget(viewModel: focusViewModel(dashboard), onAction: handleAction)
                    },
                    WidgetFeedItem(id: "today-free-time", priority: .standard, variant: .compact) {
                        FreeTimeWidget(viewModel: freeTimeViewModel(dashboard), onAction: handleAction)
                    }
                ])
            }
        }
        .navigationTitle("Today")
        .task {
            guard case .loading = state else { return }
            await load()
        }
    }

    private func load() async {
        do {
            state = .loaded(try await container.todayService.loadTodayDashboard())
        } catch {
            state = .failed("Unable to load Today: \(error.localizedDescription)")
        }
    }

    private func handleAction(_ action: WidgetAction) {
        Task {
            await container.actionRouter.handle(action)
        }
    }

    private func dailyTargetsViewModel(_ dashboard: TodayDashboard) -> DailyTargetsWidgetViewModel {
        DailyTargetsWidgetViewModel(
            snapshot: WidgetSnapshot(
                metadata: WidgetMetadata(
                    identity: WidgetIdentity(family: .dailyTargets, instanceID: "primary"),
                    priority: .hero,
                    variant: .expanded,
                    chrome: .appCard,
                    supportedActions: [.complete, .refinePlan, .openDetail]
                ),
                state: .ready(
                    DailyTargetsContent(
                        title: dashboard.title,
                        subtitle: dashboard.subtitle,
                        completionLabel: dashboard.completionLabel,
                        targets: dashboard.targets.map {
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
                            WidgetInlineActionDescriptor(kind: .complete, title: "Lock focus", icon: "checkmark"),
                            WidgetInlineActionDescriptor(kind: .refinePlan, title: "Adjust plan", icon: "slider.horizontal.3")
                        ]
                    )
                )
            )
        )
    }

    private func focusViewModel(_ dashboard: TodayDashboard) -> FocusNowWidgetViewModel {
        FocusNowWidgetViewModel(
            snapshot: WidgetSnapshot(
                metadata: WidgetMetadata(
                    identity: WidgetIdentity(family: .focusNow, instanceID: "primary"),
                    priority: .high,
                    variant: .expanded,
                    chrome: .heroCard,
                    supportedActions: [.askForSmallerStep, .openDetail]
                ),
                state: .ready(
                    FocusNowContent(
                        headline: dashboard.focus.headline,
                        subtitle: dashboard.focus.subtitle,
                        reason: dashboard.focus.reason,
                        duration: dashboard.focus.durationLabel,
                        energyLabel: dashboard.focus.energyLabel,
                        progress: dashboard.focus.progress,
                        supportSteps: dashboard.focus.supportSteps,
                        actions: [
                            WidgetInlineActionDescriptor(kind: .askForSmallerStep, title: "Smaller step", icon: "scissors"),
                            WidgetInlineActionDescriptor(kind: .openDetail, title: "Open detail", icon: "arrow.right.circle")
                        ]
                    )
                )
            )
        )
    }

    private func freeTimeViewModel(_ dashboard: TodayDashboard) -> FreeTimeWidgetViewModel {
        FreeTimeWidgetViewModel(
            snapshot: WidgetSnapshot(
                metadata: WidgetMetadata(
                    identity: WidgetIdentity(family: .freeTime, instanceID: "primary"),
                    priority: .standard,
                    variant: .compact,
                    chrome: .widgetCard,
                    supportedActions: [.openDetail]
                ),
                state: .ready(
                    FreeTimeContent(
                        title: dashboard.freeTime.title,
                        subtitle: dashboard.freeTime.subtitle,
                        availableWindow: dashboard.freeTime.windowLabel,
                        suggestionTitle: dashboard.freeTime.suggestionTitle,
                        suggestionDetail: dashboard.freeTime.suggestionDetail,
                        actions: [
                            WidgetInlineActionDescriptor(kind: .openDetail, title: "Use window", icon: "clock.badge.plus")
                        ]
                    )
                )
            )
        )
    }
}

#Preview("Today") {
    NavigationStack {
        TodayScreen()
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
