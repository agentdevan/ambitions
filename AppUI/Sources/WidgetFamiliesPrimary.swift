#if canImport(SwiftUI)
import AmbitionsDesignSystem
import SwiftUI

public struct DailyTargetsContent: Sendable {
    public let title: String
    public let subtitle: String
    public let completionLabel: String
    public let targets: [WidgetProgressItem]
    public let actions: [WidgetInlineActionDescriptor]

    public init(title: String, subtitle: String, completionLabel: String, targets: [WidgetProgressItem], actions: [WidgetInlineActionDescriptor]) {
        self.title = title
        self.subtitle = subtitle
        self.completionLabel = completionLabel
        self.targets = targets
        self.actions = actions
    }
}

public struct DailyTargetsWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<DailyTargetsContent>
    public init(snapshot: WidgetSnapshot<DailyTargetsContent>) { self.snapshot = snapshot }
}

public struct DailyTargetsWidget: View {
    private let viewModel: DailyTargetsWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: DailyTargetsWidgetViewModel, onAction: WidgetActionHandler? = nil) {
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
            WidgetFallbackStateView(title: empty.title, message: empty.message, icon: empty.icon, actionTitle: empty.actionTitle, action: makeWidgetAction(identity: identity, kind: .refinePlan, handler: handler))
        case let .error(error):
            WidgetFallbackStateView(title: error.title, message: error.message, icon: "exclamationmark.triangle", actionTitle: error.recoveryTitle, action: makeWidgetAction(identity: identity, kind: .refinePlan, handler: handler))
        case let .ready(content):
            WidgetSurface(chrome: .appCard) {
                VStack(alignment: .leading, spacing: 20) {
                    WidgetTitleBlock(eyebrow: "Today", title: content.title, subtitle: content.subtitle, badge: content.completionLabel, badgeState: .selected)
                    WidgetProgressList(items: content.targets)
                    WidgetActionBar(identity: identity, actions: content.actions, handler: handler)
                }
            }
        }
    }
}

public struct FocusNowContent: Sendable {
    public let headline: String
    public let subtitle: String
    public let reason: String
    public let duration: String
    public let energyLabel: String
    public let progress: Double
    public let supportSteps: [String]
    public let actions: [WidgetInlineActionDescriptor]

    public init(
        headline: String,
        subtitle: String,
        reason: String,
        duration: String,
        energyLabel: String,
        progress: Double,
        supportSteps: [String],
        actions: [WidgetInlineActionDescriptor]
    ) {
        self.headline = headline
        self.subtitle = subtitle
        self.reason = reason
        self.duration = duration
        self.energyLabel = energyLabel
        self.progress = progress
        self.supportSteps = supportSteps
        self.actions = actions
    }
}

public struct FocusNowWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<FocusNowContent>
    public init(snapshot: WidgetSnapshot<FocusNowContent>) { self.snapshot = snapshot }
}

public struct FocusNowWidget: View {
    @Environment(\.ambitionTheme) private var theme

    private let viewModel: FocusNowWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: FocusNowWidgetViewModel, onAction: WidgetActionHandler? = nil) {
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
            WidgetFallbackStateView(title: empty.title, message: empty.message, icon: empty.icon, actionTitle: empty.actionTitle, action: makeWidgetAction(identity: identity, kind: .askForSmallerStep, handler: handler))
        case let .error(error):
            WidgetFallbackStateView(title: error.title, message: error.message, icon: "bolt.badge.clock", actionTitle: error.recoveryTitle, action: makeWidgetAction(identity: identity, kind: .refinePlan, handler: handler))
        case let .ready(content):
            WidgetSurface(chrome: viewModel.variant == .expanded ? .heroCard : .appCard, state: .selected, accent: theme.colors.accentWarm) {
                VStack(alignment: .leading, spacing: 20) {
                    WidgetTitleBlock(eyebrow: "Focus Now", title: content.headline, subtitle: content.subtitle, badge: content.duration, badgeState: .selected)
                    ProgressRail(title: content.energyLabel, progress: content.progress, trailingValue: "\(Int(content.progress * 100))%", state: .selected, accent: theme.colors.accentWarm)
                    Text(content.reason)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)

                    if viewModel.variant == .expanded {
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            ForEach(content.supportSteps, id: \.self) { step in
                                WidgetListRow(title: step, subtitle: "Supporting move", icon: "point.forward.to.point.capsulepath", badge: nil, tap: nil)
                            }
                        }
                    }

                    WidgetActionBar(identity: identity, actions: content.actions, handler: handler)
                }
            }
        }
    }
}

public struct FreeTimeContent: Sendable {
    public let title: String
    public let subtitle: String
    public let availableWindow: String
    public let suggestionTitle: String
    public let suggestionDetail: String
    public let actions: [WidgetInlineActionDescriptor]

    public init(
        title: String,
        subtitle: String,
        availableWindow: String,
        suggestionTitle: String,
        suggestionDetail: String,
        actions: [WidgetInlineActionDescriptor]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.availableWindow = availableWindow
        self.suggestionTitle = suggestionTitle
        self.suggestionDetail = suggestionDetail
        self.actions = actions
    }
}

public struct FreeTimeWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<FreeTimeContent>
    public init(snapshot: WidgetSnapshot<FreeTimeContent>) { self.snapshot = snapshot }
}

public struct FreeTimeWidget: View {
    private let viewModel: FreeTimeWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: FreeTimeWidgetViewModel, onAction: WidgetActionHandler? = nil) {
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
            WidgetFallbackStateView(title: empty.title, message: empty.message, icon: empty.icon, actionTitle: empty.actionTitle, action: makeWidgetAction(identity: identity, kind: .openDetail, handler: handler))
        case let .error(error):
            WidgetFallbackStateView(title: error.title, message: error.message, icon: "calendar.badge.exclamationmark", actionTitle: error.recoveryTitle, action: makeWidgetAction(identity: identity, kind: .refinePlan, handler: handler))
        case let .ready(content):
            WidgetSurface(chrome: .widgetCard) {
                VStack(alignment: .leading, spacing: 16) {
                    WidgetTitleBlock(eyebrow: "Window", title: content.title, subtitle: content.subtitle, badge: content.availableWindow, badgeState: .success)
                    WidgetListRow(title: content.suggestionTitle, subtitle: content.suggestionDetail, icon: "clock.arrow.circlepath", badge: "Suggested", tap: makeWidgetAction(identity: identity, kind: .openDetail, handler: handler))
                    WidgetActionBar(identity: identity, actions: content.actions, handler: handler)
                }
            }
        }
    }
}

public struct GoalsListItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let progressLabel: String
    public let statusLabel: String

    public init(id: String, title: String, subtitle: String, progressLabel: String, statusLabel: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.progressLabel = progressLabel
        self.statusLabel = statusLabel
    }
}

public struct GoalsListContent: Sendable {
    public let title: String
    public let subtitle: String
    public let goals: [GoalsListItem]
    public let actions: [WidgetInlineActionDescriptor]

    public init(title: String, subtitle: String, goals: [GoalsListItem], actions: [WidgetInlineActionDescriptor]) {
        self.title = title
        self.subtitle = subtitle
        self.goals = goals
        self.actions = actions
    }
}

public struct GoalsListWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<GoalsListContent>
    public init(snapshot: WidgetSnapshot<GoalsListContent>) { self.snapshot = snapshot }
}

public struct GoalsListWidget: View {
    @Environment(\.ambitionTheme) private var theme

    private let viewModel: GoalsListWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: GoalsListWidgetViewModel, onAction: WidgetActionHandler? = nil) {
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
            WidgetFallbackStateView(title: empty.title, message: empty.message, icon: empty.icon, actionTitle: empty.actionTitle, action: makeWidgetAction(identity: identity, kind: .refinePlan, handler: handler))
        case let .error(error):
            WidgetFallbackStateView(title: error.title, message: error.message, icon: "target", actionTitle: error.recoveryTitle, action: makeWidgetAction(identity: identity, kind: .openDetail, handler: handler))
        case let .ready(content):
            WidgetSurface(chrome: .appCard) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    WidgetTitleBlock(eyebrow: "Goals", title: content.title, subtitle: content.subtitle)
                    ForEach(content.goals) { goal in
                        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                            WidgetListRow(title: goal.title, subtitle: goal.subtitle, icon: "scope", badge: goal.progressLabel) {
                                handler?(WidgetAction(identity: identity, kind: .openDetail, payload: goal.id))
                            }
                            TagPill(goal.statusLabel, state: .selected)
                        }
                    }
                    WidgetActionBar(identity: identity, actions: content.actions, handler: handler)
                }
            }
        }
    }
}

public struct MilestonePromptContent: Sendable {
    public let title: String
    public let subtitle: String
    public let prompt: String
    public let confidenceLabel: String
    public let actions: [WidgetInlineActionDescriptor]

    public init(title: String, subtitle: String, prompt: String, confidenceLabel: String, actions: [WidgetInlineActionDescriptor]) {
        self.title = title
        self.subtitle = subtitle
        self.prompt = prompt
        self.confidenceLabel = confidenceLabel
        self.actions = actions
    }
}

public struct MilestonePromptWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<MilestonePromptContent>
    public init(snapshot: WidgetSnapshot<MilestonePromptContent>) { self.snapshot = snapshot }
}

public struct MilestonePromptWidget: View {
    @Environment(\.ambitionTheme) private var theme

    private let viewModel: MilestonePromptWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: MilestonePromptWidgetViewModel, onAction: WidgetActionHandler? = nil) {
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
            WidgetFallbackStateView(title: error.title, message: error.message, icon: "flag.pattern.checkered.2.crossed", actionTitle: error.recoveryTitle, action: makeWidgetAction(identity: identity, kind: .refinePlan, handler: handler))
        case let .ready(content):
            WidgetSurface(chrome: viewModel.variant == .expanded ? .heroCard : .appCard, state: .success) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    WidgetTitleBlock(eyebrow: "Milestone", title: content.title, subtitle: content.subtitle, badge: content.confidenceLabel, badgeState: .success)
                    CelebrationBanner(title: "Momentum cue", subtitle: content.prompt, icon: "flag.checkered")
                    WidgetActionBar(identity: identity, actions: content.actions, handler: handler)
                }
            }
        }
    }
}

public struct HabitSummaryContent: Sendable {
    public let title: String
    public let subtitle: String
    public let stats: [WidgetStat]
    public let habits: [WidgetProgressItem]
    public let actions: [WidgetInlineActionDescriptor]

    public init(
        title: String,
        subtitle: String,
        stats: [WidgetStat],
        habits: [WidgetProgressItem],
        actions: [WidgetInlineActionDescriptor]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.stats = stats
        self.habits = habits
        self.actions = actions
    }
}

public struct HabitSummaryWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<HabitSummaryContent>
    public init(snapshot: WidgetSnapshot<HabitSummaryContent>) { self.snapshot = snapshot }
}

public struct HabitSummaryWidget: View {
    @Environment(\.ambitionTheme) private var theme

    private let viewModel: HabitSummaryWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: HabitSummaryWidgetViewModel, onAction: WidgetActionHandler? = nil) {
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
            WidgetFallbackStateView(title: error.title, message: error.message, icon: "repeat", actionTitle: error.recoveryTitle, action: makeWidgetAction(identity: identity, kind: .openDetail, handler: handler))
        case let .ready(content):
            WidgetSurface(chrome: .appCard) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    WidgetTitleBlock(eyebrow: "Rituals", title: content.title, subtitle: content.subtitle)
                    WidgetMetricGrid(stats: content.stats)
                    WidgetProgressList(items: content.habits)
                    WidgetActionBar(identity: identity, actions: content.actions, handler: handler)
                }
            }
        }
    }
}

public struct StreakContent: Sendable {
    public let title: String
    public let subtitle: String
    public let stats: [WidgetStat]
    public let recoveryNote: String
    public let actions: [WidgetInlineActionDescriptor]

    public init(title: String, subtitle: String, stats: [WidgetStat], recoveryNote: String, actions: [WidgetInlineActionDescriptor]) {
        self.title = title
        self.subtitle = subtitle
        self.stats = stats
        self.recoveryNote = recoveryNote
        self.actions = actions
    }
}

public struct StreakWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<StreakContent>
    public init(snapshot: WidgetSnapshot<StreakContent>) { self.snapshot = snapshot }
}

public struct StreakWidget: View {
    @Environment(\.ambitionTheme) private var theme

    private let viewModel: StreakWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: StreakWidgetViewModel, onAction: WidgetActionHandler? = nil) {
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
            WidgetFallbackStateView(title: empty.title, message: empty.message, icon: empty.icon, actionTitle: empty.actionTitle, action: makeWidgetAction(identity: identity, kind: .quickLog, handler: handler))
        case let .error(error):
            WidgetFallbackStateView(title: error.title, message: error.message, icon: "flame", actionTitle: error.recoveryTitle, action: makeWidgetAction(identity: identity, kind: .openDetail, handler: handler))
        case let .ready(content):
            WidgetSurface(chrome: .widgetCard, state: .celebration) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    WidgetTitleBlock(eyebrow: "Streak", title: content.title, subtitle: content.subtitle, badge: "Live", badgeState: .celebration)
                    WidgetMetricGrid(stats: content.stats)
                    Text(content.recoveryNote)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                    WidgetActionBar(identity: identity, actions: content.actions, handler: handler)
                }
            }
        }
    }
}
#endif
