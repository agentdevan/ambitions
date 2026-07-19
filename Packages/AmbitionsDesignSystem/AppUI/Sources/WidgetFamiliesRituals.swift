#if canImport(SwiftUI)
import AmbitionsDesignSystem
import SwiftUI

public struct RitualSummaryContent: Sendable {
    public let title: String
    public let subtitle: String
    public let stats: [WidgetStat]
    public let rituals: [WidgetProgressItem]
    public let actions: [WidgetInlineActionDescriptor]

    public init(
        title: String,
        subtitle: String,
        stats: [WidgetStat],
        rituals: [WidgetProgressItem],
        actions: [WidgetInlineActionDescriptor]
    ) {
        self.title = title
        self.subtitle = subtitle
        self.stats = stats
        self.rituals = rituals
        self.actions = actions
    }
}

public struct RitualSummaryWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<RitualSummaryContent>
    public init(snapshot: WidgetSnapshot<RitualSummaryContent>) { self.snapshot = snapshot }
}

public struct RitualSummaryWidget: View {
    @Environment(\.ambitionTheme) private var theme

    private let viewModel: RitualSummaryWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: RitualSummaryWidgetViewModel, onAction: WidgetActionHandler? = nil) {
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
                    WidgetProgressList(items: content.rituals)
                    WidgetActionBar(identity: identity, actions: content.actions, handler: handler)
                }
            }
        }
    }
}

public struct RitualRhythmContent: Sendable {
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

public struct RitualRhythmWidgetViewModel: AmbitionsWidgetViewModeling {
    public let snapshot: WidgetSnapshot<RitualRhythmContent>
    public init(snapshot: WidgetSnapshot<RitualRhythmContent>) { self.snapshot = snapshot }
}

public struct RitualRhythmWidget: View {
    @Environment(\.ambitionTheme) private var theme

    private let viewModel: RitualRhythmWidgetViewModel
    private let onAction: WidgetActionHandler?

    public init(viewModel: RitualRhythmWidgetViewModel, onAction: WidgetActionHandler? = nil) {
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
            WidgetFallbackStateView(title: error.title, message: error.message, icon: "waveform.path.ecg", actionTitle: error.recoveryTitle, action: makeWidgetAction(identity: identity, kind: .openDetail, handler: handler))
        case let .ready(content):
            WidgetSurface(chrome: .widgetCard, state: .celebration) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    WidgetTitleBlock(eyebrow: "Rhythm", title: content.title, subtitle: content.subtitle, badge: "Live", badgeState: .celebration)
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
