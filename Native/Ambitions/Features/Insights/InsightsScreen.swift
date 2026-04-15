import AmbitionsDesignSystem
import AmbitionsWidgetUI
import SwiftUI

struct InsightsScreen: View {
    @Environment(\.appContainer) private var container
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var state: AsyncViewState<InsightsDashboard> = .loading

    var body: some View {
        FeatureScaffoldView(
            eyebrow: "Review",
            title: "Insights",
            subtitle: "Review the patterns behind progress, drift, and useful adaptation without leaving the native planning surface."
        ) {
            switch state {
            case .loading:
                LoadingSkeletonCard(lineCount: 8)
                    .transition(.ambitionPanel)
            case let .failed(message):
                EmptyStateCard(
                    title: "Insights are unavailable",
                    message: message,
                    icon: "chart.line.uptrend.xyaxis",
                    actionTitle: "Retry",
                    actionAccessibilityIdentifier: "insights.retry-button"
                ) {
                    Task { await load() }
                }
                .transition(.ambitionPanel)
            case let .loaded(dashboard):
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    AppCard {
                        SectionHeader(
                            title: dashboard.title,
                            subtitle: dashboard.summary
                        ) {
                            TagPill(dashboard.timeframeLabel, state: .selected)
                        }
                    }
                    .transition(.ambitionPanel)

                    WidgetFeed(items: [
                        WidgetFeedItem(id: "insight-stats", priority: .hero, variant: .expanded) {
                            InsightStatsWidget(viewModel: statsViewModel(dashboard))
                        },
                        WidgetFeedItem(id: "insight-trend", priority: .high, variant: .expanded) {
                            WeeklyTrendWidget(viewModel: trendViewModel(dashboard))
                        },
                        WidgetFeedItem(id: "insight-activity", priority: .standard, variant: .expanded) {
                            RecentActivityWidget(viewModel: activitiesViewModel(dashboard))
                        }
                    ])
                }
            }
        }
        .navigationTitle("Insights")
        .refreshable {
            await load()
        }
        .accessibilityIdentifier("insights.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: stateKey)
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

    private func statsViewModel(_ dashboard: InsightsDashboard) -> InsightStatsWidgetViewModel {
        InsightStatsWidgetViewModel(
            snapshot: WidgetSnapshot(
                metadata: WidgetMetadata(
                    identity: WidgetIdentity(family: .insightStats, instanceID: "primary"),
                    priority: .hero,
                    variant: .expanded,
                    chrome: .appCard,
                    supportedActions: []
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
                        actions: []
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
                    supportedActions: []
                ),
                state: .ready(
                    WeeklyTrendContent(
                        title: dashboard.trendTitle,
                        subtitle: dashboard.trendSubtitle,
                        timeframeLabel: dashboard.timeframeLabel,
                        points: dashboard.trendPoints.map { WidgetTrendPoint(id: $0.id, label: $0.label, value: $0.value) },
                        summary: dashboard.trendSummary,
                        actions: []
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
                    supportedActions: []
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
                        actions: []
                    )
                )
            )
        )
    }

    private var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(dashboard):
            return "loaded:\(dashboard.stats.count):\(dashboard.activities.count)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }
}

#Preview("Insights Light") {
    NavigationStack {
        InsightsScreen()
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.light)
    .preferredColorScheme(.light)
}

#Preview("Insights Dark") {
    NavigationStack {
        InsightsScreen()
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}
