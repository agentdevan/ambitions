import AmbitionsDesignSystem
import AmbitionsWidgetUI
import SwiftUI

struct InsightsScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: InsightsViewModel
    private let showsNavigationChrome: Bool

    @MainActor
    init(viewModel: InsightsViewModel? = nil, showsNavigationChrome: Bool = true) {
        _viewModel = State(initialValue: viewModel ?? InsightsViewModel())
        self.showsNavigationChrome = showsNavigationChrome
    }

    var body: some View {
        FeatureScaffoldView(
            eyebrow: "Review",
            title: "Insights",
            subtitle: "Review the patterns behind progress, drift, and useful adaptation without leaving the native planning surface."
        ) {
            switch viewModel.state {
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
                    Task { await viewModel.refresh(using: container.insightsService) }
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

                    InsightsPostureCard(posture: dashboard.posture, summary: dashboard.summary)

                    InsightsChangeCard(items: dashboard.changeSummaries)

                    InsightsGoalStatusCard(items: dashboard.goalStatuses) { target in
                        container.navigation.openGoalDetail(target)
                    }

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
        .navigationTitle(showsNavigationChrome ? "Insights" : "")
        .refreshable {
            await viewModel.refresh(using: container.insightsService)
        }
        .accessibilityIdentifier("insights.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            await viewModel.load(using: container.insightsService)
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

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }
}

private struct InsightsPostureCard: View {
    @Environment(\.ambitionTheme) private var theme

    let posture: InsightsPostureSummary
    let summary: String

    var body: some View {
        AppCard(state: posture.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: posture.title,
                    subtitle: posture.detail
                ) {
                    TagPill(posture.label, state: posture.visualState)
                }
                Text(summary)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("insights.posture-card")
    }
}

private struct InsightsChangeCard: View {
    @Environment(\.ambitionTheme) private var theme

    let items: [InsightsChangeSummary]

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "What is changing",
                    subtitle: "Insights stays useful when it can explain how current signals are changing the plan, not just count them."
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(items) { item in
                        InsightsInfoRow(
                            title: item.title,
                            detail: item.detail,
                            valueLabel: item.valueLabel,
                            icon: item.icon,
                            state: item.visualState
                        )
                    }
                }
            }
        }
        .accessibilityIdentifier("insights.change-card")
    }
}

private struct InsightsGoalStatusCard: View {
    @Environment(\.ambitionTheme) private var theme

    let items: [InsightsGoalStatusItem]
    let onOpen: (GoalRouteTarget) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Goal read",
                    subtitle: items.isEmpty
                        ? "No active goals are producing a useful goal-level read yet."
                        : "These goal-level reads keep Insights connected to the real portfolio instead of floating above it."
                )

                if items.isEmpty {
                    Text("Once active goals produce evidence, corrections, or planning strain, their current posture will stay visible here.")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(items) { item in
                            if let target = item.target {
                                Button {
                                    onOpen(target)
                                } label: {
                                    InsightsGoalStatusRow(item: item)
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("insights.open-goal.\(target.goalID ?? target.draftID ?? item.id)")
                            } else {
                                InsightsGoalStatusRow(item: item)
                            }
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("insights.goal-status-card")
    }
}

private struct InsightsGoalStatusRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: InsightsGoalStatusItem

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                HStack(spacing: theme.spacing.xs) {
                    TagPill(item.statusLabel, state: item.visualState)
                }
                Text(item.title)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(item.summary)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.sm)
            Image(systemName: "chevron.right")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.colors.textTertiary)
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility()
    }
}

private struct InsightsInfoRow: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let detail: String
    let valueLabel: String
    let icon: String
    let state: AmbitionVisualState

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.stateStyle(for: state).accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(detail)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.sm)
            TagPill(valueLabel, state: state)
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility()
    }
}

#if DEBUG
#Preview("Insights Light") {
    NavigationStack {
        InsightsScreen(viewModel: InsightsViewModel(state: .loaded(PreviewFixtures.default.insightsDashboard)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.light)
    .preferredColorScheme(.light)
}

#Preview("Insights Dark") {
    NavigationStack {
        InsightsScreen(viewModel: InsightsViewModel(state: .loaded(PreviewFixtures.default.insightsDashboard)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}
#endif
