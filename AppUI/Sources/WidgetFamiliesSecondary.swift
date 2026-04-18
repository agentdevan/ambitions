#if canImport(SwiftUI)
import AmbitionsDesignSystem
import SwiftUI

public struct InsightStatsContent: Sendable {
    public let title: String
    public let subtitle: String
    public let stats: [WidgetStat]
    public let summary: String
    public let actions: [WidgetInlineActionDescriptor]

    public init(title: String, subtitle: String, stats: [WidgetStat], summary: String, actions: [WidgetInlineActionDescriptor]) {
        self.title = title
        self.subtitle = subtitle
        self.stats = stats
        self.summary = summary
        self.actions = actions
    }
}

public struct InsightStatsWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<InsightStatsContent>
    public init(snapshot: WidgetSnapshot<InsightStatsContent>) { self.snapshot = snapshot }
}

public struct InsightStatsWidget: View {
    @Environment(\.ambitionTheme) private var theme

    private let viewModel: InsightStatsWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: InsightStatsWidgetViewModel, onAction: WidgetActionHandler? = nil) {
        self.viewModel = viewModel
        self.onAction = onAction
    }

    public var body: some View {
        let handler: WidgetActionHandler? = onAction
        let identity = viewModel.identity

        switch viewModel.snapshot.state {
        case .loading:
            WidgetLoadingStateView(lineCount: 4)
        case let .empty(empty):
            WidgetFallbackStateView(title: empty.title, message: empty.message, icon: empty.icon, actionTitle: empty.actionTitle, action: makeWidgetAction(identity: identity, kind: .openDetail, handler: handler))
        case let .error(error):
            WidgetFallbackStateView(title: error.title, message: error.message, icon: "waveform.path.ecg", actionTitle: error.recoveryTitle, action: makeWidgetAction(identity: identity, kind: .markHelpful, handler: handler))
        case let .ready(content):
            WidgetSurface(chrome: .appCard) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    WidgetTitleBlock(eyebrow: "Insights", title: content.title, subtitle: content.subtitle)
                    WidgetMetricGrid(stats: content.stats)
                    Text(content.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                    WidgetActionBar(identity: identity, actions: content.actions, handler: handler)
                }
            }
        }
    }
}

public struct WeeklyTrendContent: Sendable {
    public let title: String
    public let subtitle: String
    public let timeframeLabel: String
    public let points: [WidgetTrendPoint]
    public let summary: String
    public let actions: [WidgetInlineActionDescriptor]

    public init(
        title: String,
        subtitle: String,
        timeframeLabel: String,
        points: [WidgetTrendPoint],
        summary: String,
        actions: [WidgetInlineActionDescriptor]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.timeframeLabel = timeframeLabel
        self.points = points
        self.summary = summary
        self.actions = actions
    }
}

public struct WeeklyTrendWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<WeeklyTrendContent>
    public init(snapshot: WidgetSnapshot<WeeklyTrendContent>) { self.snapshot = snapshot }
}

public struct WeeklyTrendWidget: View {
    @Environment(\.ambitionTheme) private var theme

    private let viewModel: WeeklyTrendWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: WeeklyTrendWidgetViewModel, onAction: WidgetActionHandler? = nil) {
        self.viewModel = viewModel
        self.onAction = onAction
    }

    public var body: some View {
        let handler: WidgetActionHandler? = onAction
        let identity = viewModel.identity

        switch viewModel.snapshot.state {
        case .loading:
            WidgetLoadingStateView(lineCount: 4)
        case let .empty(empty):
            WidgetFallbackStateView(title: empty.title, message: empty.message, icon: empty.icon, actionTitle: empty.actionTitle, action: makeWidgetAction(identity: identity, kind: .openDetail, handler: handler))
        case let .error(error):
            WidgetFallbackStateView(title: error.title, message: error.message, icon: "chart.bar", actionTitle: error.recoveryTitle, action: makeWidgetAction(identity: identity, kind: .refinePlan, handler: handler))
        case let .ready(content):
            CompactChartShell(title: content.title, subtitle: content.subtitle) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    WidgetBarChart(points: content.points)
                    HStack {
                        TagPill(content.timeframeLabel, state: .selected)
                        Spacer()
                    }
                    Text(content.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                    WidgetActionBar(identity: identity, actions: content.actions, handler: handler)
                }
            }
        }
    }
}

public struct RecentActivityContent: Sendable {
    public let title: String
    public let subtitle: String
    public let activities: [WidgetActivityItem]
    public let actions: [WidgetInlineActionDescriptor]

    public init(title: String, subtitle: String, activities: [WidgetActivityItem], actions: [WidgetInlineActionDescriptor]) {
        self.title = title
        self.subtitle = subtitle
        self.activities = activities
        self.actions = actions
    }
}

public struct RecentActivityWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<RecentActivityContent>
    public init(snapshot: WidgetSnapshot<RecentActivityContent>) { self.snapshot = snapshot }
}

public struct RecentActivityWidget: View {
    @Environment(\.ambitionTheme) private var theme

    private let viewModel: RecentActivityWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: RecentActivityWidgetViewModel, onAction: WidgetActionHandler? = nil) {
        self.viewModel = viewModel
        self.onAction = onAction
    }

    public var body: some View {
        let handler: WidgetActionHandler? = onAction
        let identity = viewModel.identity

        switch viewModel.snapshot.state {
        case .loading:
            WidgetLoadingStateView(lineCount: 5)
        case let .empty(empty):
            WidgetFallbackStateView(title: empty.title, message: empty.message, icon: empty.icon, actionTitle: empty.actionTitle, action: makeWidgetAction(identity: identity, kind: .quickLog, handler: handler))
        case let .error(error):
            WidgetFallbackStateView(title: error.title, message: error.message, icon: "clock.badge.exclamationmark", actionTitle: error.recoveryTitle, action: makeWidgetAction(identity: identity, kind: .openDetail, handler: handler))
        case let .ready(content):
            WidgetSurface(chrome: .appCard) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    WidgetTitleBlock(eyebrow: "Recent Activity", title: content.title, subtitle: content.subtitle)
                    ForEach(content.activities) { item in
                        WidgetListRow(
                            title: item.title,
                            subtitle: "\(item.subtitle) | \(item.timestamp)",
                            icon: item.icon,
                            badge: item.badge
                        ) {
                            handler?(WidgetAction(identity: identity, kind: .openDetail, payload: item.id))
                        }
                    }
                    WidgetActionBar(identity: identity, actions: content.actions, handler: handler)
                }
            }
        }
    }
}

public struct ProfileSummaryContent: Sendable {
    public let title: String
    public let subtitle: String
    public let initials: String
    public let badges: [String]
    public let stats: [WidgetStat]
    public let actions: [WidgetInlineActionDescriptor]

    public init(
        title: String,
        subtitle: String,
        initials: String,
        badges: [String],
        stats: [WidgetStat],
        actions: [WidgetInlineActionDescriptor]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.initials = initials
        self.badges = badges
        self.stats = stats
        self.actions = actions
    }
}

public struct ProfileSummaryWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<ProfileSummaryContent>
    public init(snapshot: WidgetSnapshot<ProfileSummaryContent>) { self.snapshot = snapshot }
}

public struct ProfileSummaryWidget: View {
    @Environment(\.ambitionTheme) private var theme

    private let viewModel: ProfileSummaryWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: ProfileSummaryWidgetViewModel, onAction: WidgetActionHandler? = nil) {
        self.viewModel = viewModel
        self.onAction = onAction
    }

    public var body: some View {
        let handler: WidgetActionHandler? = onAction
        let identity = viewModel.identity

        switch viewModel.snapshot.state {
        case .loading:
            WidgetLoadingStateView(lineCount: 4)
        case let .empty(empty):
            WidgetFallbackStateView(title: empty.title, message: empty.message, icon: empty.icon, actionTitle: empty.actionTitle, action: makeWidgetAction(identity: identity, kind: .openDetail, handler: handler))
        case let .error(error):
            WidgetFallbackStateView(title: error.title, message: error.message, icon: "person.crop.circle.badge.exclamationmark", actionTitle: error.recoveryTitle, action: makeWidgetAction(identity: identity, kind: .openDetail, handler: handler))
        case let .ready(content):
            WidgetSurface(chrome: .appCard) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    AvatarHeader(title: content.title, subtitle: content.subtitle, initials: content.initials) {
                        HStack(spacing: theme.spacing.xxs) {
                            ForEach(content.badges, id: \.self) { badge in
                                TagPill(badge)
                            }
                        }
                    }
                    WidgetMetricGrid(stats: content.stats)
                    WidgetActionBar(identity: identity, actions: content.actions, handler: handler)
                }
            }
        }
    }
}

public struct CelebrationContent: Sendable {
    public let title: String
    public let subtitle: String
    public let achievements: [String]
    public let actions: [WidgetInlineActionDescriptor]

    public init(title: String, subtitle: String, achievements: [String], actions: [WidgetInlineActionDescriptor]) {
        self.title = title
        self.subtitle = subtitle
        self.achievements = achievements
        self.actions = actions
    }
}

public struct CelebrationWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<CelebrationContent>
    public init(snapshot: WidgetSnapshot<CelebrationContent>) { self.snapshot = snapshot }
}

public struct CelebrationWidget: View {
    @Environment(\.ambitionTheme) private var theme

    private let viewModel: CelebrationWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: CelebrationWidgetViewModel, onAction: WidgetActionHandler? = nil) {
        self.viewModel = viewModel
        self.onAction = onAction
    }

    public var body: some View {
        let handler: WidgetActionHandler? = onAction
        let identity = viewModel.identity

        switch viewModel.snapshot.state {
        case .loading:
            WidgetLoadingStateView(lineCount: 3)
        case let .empty(empty):
            WidgetFallbackStateView(title: empty.title, message: empty.message, icon: empty.icon, actionTitle: empty.actionTitle, action: makeWidgetAction(identity: identity, kind: .dismiss, handler: handler))
        case let .error(error):
            WidgetFallbackStateView(title: error.title, message: error.message, icon: "sparkles", actionTitle: error.recoveryTitle, action: makeWidgetAction(identity: identity, kind: .dismiss, handler: handler))
        case let .ready(content):
            WidgetSurface(chrome: .heroCard, state: .celebration, accent: theme.colors.celebration) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    WidgetTitleBlock(eyebrow: "Celebration", title: content.title, subtitle: content.subtitle, badge: "Lift", badgeState: .celebration)
                    CelebrationBanner(title: content.title, subtitle: content.subtitle)
                    ForEach(content.achievements, id: \.self) { achievement in
                        WidgetListRow(title: achievement, subtitle: "Captured win", icon: "sparkle", badge: nil, tap: nil)
                    }
                    WidgetActionBar(identity: identity, actions: content.actions, handler: handler)
                }
            }
        }
    }
}

public struct SettingsGroupContent: Sendable {
    public let title: String
    public let subtitle: String
    public let items: [WidgetSettingItem]
    public let footer: String?

    public init(title: String, subtitle: String, items: [WidgetSettingItem], footer: String?) {
        self.title = title
        self.subtitle = subtitle
        self.items = items
        self.footer = footer
    }
}

public struct SettingsGroupWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<SettingsGroupContent>
    public init(snapshot: WidgetSnapshot<SettingsGroupContent>) { self.snapshot = snapshot }
}

public struct SettingsGroupWidget: View {
    @Environment(\.ambitionTheme) private var theme

    private let viewModel: SettingsGroupWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: SettingsGroupWidgetViewModel, onAction: WidgetActionHandler? = nil) {
        self.viewModel = viewModel
        self.onAction = onAction
    }

    public var body: some View {
        let handler: WidgetActionHandler? = onAction
        let identity = viewModel.identity

        switch viewModel.snapshot.state {
        case .loading:
            WidgetLoadingStateView(lineCount: 4)
        case let .empty(empty):
            WidgetFallbackStateView(title: empty.title, message: empty.message, icon: empty.icon, actionTitle: empty.actionTitle, action: makeWidgetAction(identity: identity, kind: .openDetail, handler: handler))
        case let .error(error):
            WidgetFallbackStateView(title: error.title, message: error.message, icon: "gearshape.2", actionTitle: error.recoveryTitle, action: makeWidgetAction(identity: identity, kind: .openDetail, handler: handler))
        case let .ready(content):
            WidgetSurface(chrome: .appCard) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    WidgetTitleBlock(eyebrow: "Settings", title: content.title, subtitle: content.subtitle)
                    ForEach(content.items) { item in
                        WidgetListRow(title: item.title, subtitle: item.subtitle, icon: item.icon, badge: item.valueLabel) {
                            handler?(WidgetAction(identity: identity, kind: .openDetail, payload: item.id))
                        }
                    }
                    if let footer = content.footer {
                        Text(footer)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
            }
        }
    }
}
#endif
