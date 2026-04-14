import AmbitionsDesignSystem
import AmbitionsWidgetUI
import SwiftUI

struct InsightsScreen: View {
    @Environment(\.appContainer) private var container
    @State private var state: AsyncViewState<InsightsDashboard> = .loading

    var body: some View {
        FeatureScaffoldView(
            title: "Insights",
            subtitle: "The screen shape is native now; the analytics backend still needs real persistence and event ingestion."
        ) {
            switch state {
            case .loading:
                ProgressView("Loading insights")
                    .frame(maxWidth: .infinity, alignment: .leading)
            case let .failed(message):
                Text(message)
                    .foregroundStyle(.secondary)
            case let .loaded(dashboard):
                WidgetFeed(items: [
                    WidgetFeedItem(id: "insight-stats", priority: .hero, variant: .expanded) {
                        InsightStatsWidget(viewModel: statsViewModel(dashboard), onAction: handleAction)
                    },
                    WidgetFeedItem(id: "insight-trend", priority: .high, variant: .expanded) {
                        WeeklyTrendWidget(viewModel: trendViewModel(dashboard), onAction: handleAction)
                    },
                    WidgetFeedItem(id: "insight-activity", priority: .standard, variant: .expanded) {
                        RecentActivityWidget(viewModel: activitiesViewModel(dashboard), onAction: handleAction)
                    }
                ])
            }
        }
        .navigationTitle("Insights")
        .task {
            guard case .loading = state else { return }
            await load()
        }
    }

    private func load() async {
        do {
            state = .loaded(try await container.insightsService.loadInsightsDashboard())
        } catch {
            state = .failed("Unable to load Insights: \(error.localizedDescription)")
        }
    }

    private func handleAction(_ action: WidgetAction) {
        Task {
            await container.actionRouter.handle(action)
        }
    }

    private func statsViewModel(_ dashboard: InsightsDashboard) -> InsightStatsWidgetViewModel {
        InsightStatsWidgetViewModel(
            snapshot: WidgetSnapshot(
                metadata: WidgetMetadata(
                    identity: WidgetIdentity(family: .insightStats, instanceID: "primary"),
                    priority: .hero,
                    variant: .expanded,
                    chrome: .appCard,
                    supportedActions: [.openDetail]
                ),
                state: .ready(
                    InsightStatsContent(
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
                        summary: dashboard.summary,
                        actions: [
                            WidgetInlineActionDescriptor(kind: .openDetail, title: "Inspect drivers", icon: "magnifyingglass")
                        ]
                    )
                )
            )
        )
    }

    private func trendViewModel(_ dashboard: InsightsDashboard) -> WeeklyTrendWidgetViewModel {
        WeeklyTrendWidgetViewModel(
            snapshot: WidgetSnapshot(
                metadata: WidgetMetadata(
                    identity: WidgetIdentity(family: .weeklyTrend, instanceID: "primary"),
                    priority: .high,
                    variant: .expanded,
                    chrome: .appCard,
                    supportedActions: [.openDetail]
                ),
                state: .ready(
                    WeeklyTrendContent(
                        title: dashboard.trendTitle,
                        subtitle: dashboard.trendSubtitle,
                        timeframeLabel: dashboard.timeframeLabel,
                        points: dashboard.trendPoints.map { WidgetTrendPoint(id: $0.id, label: $0.label, value: $0.value) },
                        summary: dashboard.trendSummary,
                        actions: [
                            WidgetInlineActionDescriptor(kind: .openDetail, title: "Trend detail", icon: "chart.bar.xaxis")
                        ]
                    )
                )
            )
        )
    }

    private func activitiesViewModel(_ dashboard: InsightsDashboard) -> RecentActivityWidgetViewModel {
        RecentActivityWidgetViewModel(
            snapshot: WidgetSnapshot(
                metadata: WidgetMetadata(
                    identity: WidgetIdentity(family: .recentActivity, instanceID: "primary"),
                    priority: .standard,
                    variant: .expanded,
                    chrome: .appCard,
                    supportedActions: [.openDetail]
                ),
                state: .ready(
                    RecentActivityContent(
                        title: dashboard.activitiesTitle,
                        subtitle: dashboard.activitiesSubtitle,
                        activities: dashboard.activities.map {
                            WidgetActivityItem(
                                id: $0.id,
                                title: $0.title,
                                subtitle: $0.subtitle,
                                timestamp: $0.timestamp,
                                icon: $0.icon,
                                badge: $0.badge
                            )
                        },
                        actions: [
                            WidgetInlineActionDescriptor(kind: .openDetail, title: "Open history", icon: "clock.arrow.circlepath")
                        ]
                    )
                )
            )
        )
    }
}

#Preview("Insights") {
    NavigationStack {
        InsightsScreen()
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
