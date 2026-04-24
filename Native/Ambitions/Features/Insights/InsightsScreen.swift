import AmbitionsDesignSystem
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
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    AsyncStateCard(.loading(lines: 10))
                        .transition(.ambitionPanel)
                case .failed:
                    DegradedStateCard(
                        state: DegradedStateOrchestrator.unavailable(surface: "Insights"),
                        primaryAccessibilityIdentifier: "insights.retry-button",
                        onPrimaryAction: {
                            Task { await viewModel.refresh(using: container.insightsService) }
                        }
                    )
                    .transition(.ambitionPanel)
                case let .loaded(dashboard):
                    InsightsHeroCard(hero: dashboard.hero, onPrimaryAction: handle(heroAction:))

                    if dashboard.isLowHistory {
                        DegradedStateCard(
                            state: DegradedStateOrchestrator.insightsLowHistory(),
                            primaryAccessibilityIdentifier: "insights.low-history.open-today",
                            secondaryAccessibilityIdentifier: "insights.low-history.open-plan",
                            onPrimaryAction: {
                                container.navigation.selectTab(.today)
                            },
                            onSecondaryAction: {
                                container.navigation.selectTab(.plan)
                            }
                        )
                        .transition(.ambitionPanel)
                    }

                    if let ribbon = dashboard.continuityRibbon {
                        InsightsContinuityRibbonCard(ribbon: ribbon, onOpen: handle(ribbon:))
                    }

                    InsightsComparePeriodCard(compare: dashboard.comparePeriod)

                    InsightsPatternTruthCard(items: dashboard.patternClusters, onOpenGoal: openGoal, onOpenPlanRoute: openPlanRoute)

                    InsightsReviewConstellationCard(state: dashboard.reviewConstellation, onOpenGoal: openGoal, onOpenPlanRoute: openPlanRoute)

                    InsightsHistoryLayerCard(
                        history: dashboard.historyLayer,
                        onOpenItem: openTimelineItem,
                        onOpenHistory: { openInsightsRoute(.history) },
                        onOpenReview: { openInsightsRoute(.monthlyReview) }
                    )
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
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

    private func handle(heroAction action: InsightsHeroAction) {
        if let goalTarget = action.goalTarget {
            openGoal(goalTarget)
            return
        }
        if let planRoute = action.planRoute {
            openPlanRoute(planRoute)
            return
        }
        if let route = action.insightsRoute {
            openInsightsRoute(route)
        }
    }

    private func handle(ribbon: InsightsContinuityRibbon) {
        if let goalTarget = ribbon.goalTarget {
            openGoal(goalTarget)
            return
        }
        if let planRoute = ribbon.planRoute {
            openPlanRoute(planRoute)
            return
        }
        if let route = ribbon.insightsRoute {
            openInsightsRoute(route)
        }
    }

    private func openGoal(_ target: GoalRouteTarget) {
        container.navigation.openGoalDetail(target)
    }

    private func openPlanRoute(_ route: PlanRouteTarget) {
        container.navigation.openPlanRoute(route)
    }

    private func openInsightsRoute(_ route: InsightsRouteTarget) {
        container.navigation.openInsightsRoute(route)
    }

    private func openTimelineItem(_ item: InsightsTimelineItem) {
        if let goalTarget = item.goalTarget {
            openGoal(goalTarget)
            return
        }
        if let planRoute = item.planRoute {
            openPlanRoute(planRoute)
        }
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }
}

struct InsightsMonthlyReviewScreen: View {
    var body: some View {
        InsightsReflectionRouteScreen(accessibilityIdentifier: "insights.monthly-review.screen") { dashboard, actions in
            AnyView(VStack(alignment: .leading, spacing: actions.theme.spacing.lg) {
                InsightsRouteHeroCard(
                    eyebrow: "Review",
                    title: "Monthly reflection",
                    subtitle: "Carry the strongest pattern truth into a calmer review layer rather than a report.",
                    dominantTruth: dashboard.hero.editorialSummary,
                    trustWhisper: dashboard.hero.trustWhisper,
                    state: dashboard.hero.visualState
                )

                InsightsComparePeriodCard(compare: dashboard.comparePeriod)

                InsightsReviewConstellationCard(
                    state: dashboard.reviewConstellation,
                    onOpenGoal: actions.openGoal,
                    onOpenPlanRoute: actions.openPlanRoute
                )

                AppCard {
                    VStack(alignment: .leading, spacing: actions.theme.spacing.md) {
                        SectionHeader(
                            title: "Review shaping",
                            subtitle: "Reflection matters when it changes what the next review protects, lightens, or questions."
                        )
                        Text("Use Weekly Review when this pattern truth should reshape the week. Use Goal Detail when the learning belongs to one active path.")
                            .font(actions.theme.typography.body)
                            .foregroundStyle(actions.theme.colors.textSecondary)

                        VStack(alignment: .leading, spacing: actions.theme.spacing.sm) {
                            Button {
                                actions.openPlanRoute(.weeklyReview)
                            } label: {
                                InsightsRouteActionRow(
                                    title: "Open weekly review",
                                    subtitle: "Carry this reflection back into the week without losing context.",
                                    state: .selected
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("insights.monthly-review.open-weekly-review")

                            if let goalTarget = dashboard.reviewConstellation.items.first(where: { $0.goalTarget != nil })?.goalTarget {
                                Button {
                                    actions.openGoal(goalTarget)
                                } label: {
                                    InsightsRouteActionRow(
                                        title: "Open the clearest active goal",
                                        subtitle: "Inspect the path where this reflection is most actionable.",
                                        state: .default
                                    )
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("insights.monthly-review.open-goal")
                            }
                        }
                    }
                }
            })
        }
    }
}

struct InsightsHistoryScreen: View {
    var body: some View {
        InsightsReflectionRouteScreen(accessibilityIdentifier: "insights.history.screen") { dashboard, actions in
            AnyView(VStack(alignment: .leading, spacing: actions.theme.spacing.lg) {
                InsightsRouteHeroCard(
                    eyebrow: "History",
                    title: "Deep history",
                    subtitle: "The summary layer stays fast. This route makes the recent evidence and corrections feel alive and trustworthy.",
                    dominantTruth: dashboard.historyLayer.summaryTitle,
                    trustWhisper: dashboard.historyLayer.summaryDetail,
                    state: dashboard.hero.visualState
                )

                InsightsTimelineCard(
                    title: dashboard.historyLayer.title,
                    subtitle: dashboard.historyLayer.subtitle,
                    items: dashboard.historyLayer.timelineItems,
                    onOpenItem: actions.openTimelineItem
                )

                AppCard {
                    VStack(alignment: .leading, spacing: actions.theme.spacing.md) {
                        SectionHeader(
                            title: "Return with continuity",
                            subtitle: "History should lead somewhere useful, not strand you in recall."
                        )
                        Button {
                            actions.openPlanRoute(.weeklyReview)
                        } label: {
                            InsightsRouteActionRow(
                                title: "Open weekly review",
                                subtitle: "Use the recent timeline to decide what to protect, lighten, or leave behind.",
                                state: .selected
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("insights.history.open-weekly-review")
                    }
                }
            })
        }
    }
}

private struct InsightsReflectionRouteScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel = InsightsViewModel()
    let accessibilityIdentifier: String
    let content: (InsightsDashboard, RouteActions) -> AnyView

    init(
        accessibilityIdentifier: String,
        content: @escaping (InsightsDashboard, RouteActions) -> AnyView
    ) {
        self.accessibilityIdentifier = accessibilityIdentifier
        self.content = content
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    AsyncStateCard(.loading(lines: 8))
                case let .failed(message):
                    AsyncStateCard(
                        .error(title: "Reflection is unavailable", message: message, icon: "chart.line.uptrend.xyaxis", actionTitle: "Retry"),
                        actionAccessibilityIdentifier: "insights.route.retry-button"
                    ) {
                        Task { await viewModel.refresh(using: container.insightsService) }
                    }
                case let .loaded(dashboard):
                    content(dashboard, routeActions)
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refresh(using: container.insightsService)
        }
        .accessibilityIdentifier(accessibilityIdentifier)
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            await viewModel.load(using: container.insightsService)
        }
    }

    private var routeActions: RouteActions {
        RouteActions(
            theme: theme,
            openGoal: { container.navigation.openGoalDetail($0) },
            openPlanRoute: { container.navigation.openPlanRoute($0) },
            openTimelineItem: { item in
                if let goalTarget = item.goalTarget {
                    container.navigation.openGoalDetail(goalTarget)
                } else if let planRoute = item.planRoute {
                    container.navigation.openPlanRoute(planRoute)
                }
            }
        )
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }

    struct RouteActions {
        let theme: AmbitionTheme
        let openGoal: (GoalRouteTarget) -> Void
        let openPlanRoute: (PlanRouteTarget) -> Void
        let openTimelineItem: (InsightsTimelineItem) -> Void
    }
}

private struct InsightsHeroCard: View {
    @Environment(\.ambitionTheme) private var theme

    let hero: InsightsHeroState
    let onPrimaryAction: (InsightsHeroAction) -> Void

    var body: some View {
        HeroCard(state: hero.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(hero.eyebrow)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(hero.title)
                        .font(theme.typography.hero)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(hero.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                TagPill(hero.postureLabel, state: hero.visualState)

                Text(hero.dominantTruth)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)

                Text(hero.editorialSummary)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(hero.contextPills) { pill in
                            TagPill(pill.title, icon: pill.icon, state: pill.visualState)
                        }
                    }
                }

                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    Image(systemName: "sparkle.magnifyingglass")
                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.colors.textTertiary)
                    Text(hero.trustWhisper)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button {
                    onPrimaryAction(hero.primaryAction)
                } label: {
                    HStack(alignment: .center, spacing: theme.spacing.sm) {
                        Image(systemName: hero.primaryAction.systemImage)
                            .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(hero.primaryAction.title)
                                .font(theme.typography.bodyEmphasized)
                            Text(hero.primaryAction.subtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        Spacer()
                        Image(systemName: "arrow.right")
                            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(AmbitionButtonStyle(tier: .hero, state: hero.primaryAction.visualState))
                .accessibilityIdentifier("insights.hero.primary-action")
            }
        }
        .accessibilityIdentifier("insights.hero-card")
        .ambitionPanelAccessibility()
    }
}

private struct InsightsContinuityRibbonCard: View {
    @Environment(\.ambitionTheme) private var theme

    let ribbon: InsightsContinuityRibbon
    let onOpen: (InsightsContinuityRibbon) -> Void

    var body: some View {
        Button {
            onOpen(ribbon)
        } label: {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: ribbon.icon)
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.stateStyle(for: ribbon.visualState).accent)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(ribbon.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(ribbon.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.textTertiary)
            }
            .padding(theme.spacing.md)
            .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
            .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("insights.continuity-ribbon")
    }
}

private struct InsightsComparePeriodCard: View {
    @Environment(\.ambitionTheme) private var theme

    let compare: InsightsComparePeriodState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: compare.title, subtitle: compare.subtitle)

                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    ForEach(compare.metrics) { metric in
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            Text(metric.title)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                            Text(metric.currentLabel)
                                .font(theme.typography.titleCompact)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text("Last week \(metric.previousLabel)")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textTertiary)
                            TagPill(metric.deltaLabel, state: metric.visualState)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(theme.spacing.md)
                        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
                    }
                }

                Text(compare.summary)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("insights.compare-period")
        .ambitionPanelAccessibility()
    }
}

private struct InsightsPatternTruthCard: View {
    @Environment(\.ambitionTheme) private var theme

    let items: [InsightsPatternCluster]
    let onOpenGoal: (GoalRouteTarget) -> Void
    let onOpenPlanRoute: (PlanRouteTarget) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Pattern truth",
                    subtitle: "Charts support reflection here. They stay compact so the narrative remains the primary layer."
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(items) { item in
                        Button {
                            if let goalTarget = item.goalTarget {
                                onOpenGoal(goalTarget)
                            } else if let planRoute = item.planRoute {
                                onOpenPlanRoute(planRoute)
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                HStack(alignment: .top, spacing: theme.spacing.sm) {
                                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                        HStack(spacing: theme.spacing.xs) {
                                            TagPill(item.emphasisLabel, state: item.visualState)
                                            Text(item.deltaLabel)
                                                .font(theme.typography.caption)
                                                .foregroundStyle(theme.colors.textTertiary)
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
                                    if item.goalTarget != nil || item.planRoute != nil {
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                            .foregroundStyle(theme.colors.textTertiary)
                                    }
                                }

                                InsightsMicroChart(points: item.points, state: item.visualState)
                            }
                            .padding(theme.spacing.md)
                            .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                            .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(item.goalTarget == nil && item.planRoute == nil)
                    }
                }
            }
        }
        .accessibilityIdentifier("insights.pattern-truth")
        .ambitionPanelAccessibility()
    }
}

private struct InsightsReviewConstellationCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: InsightsReviewConstellationState
    let onOpenGoal: (GoalRouteTarget) -> Void
    let onOpenPlanRoute: (PlanRouteTarget) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(Array(state.items.enumerated()), id: \.element.id) { index, item in
                        Button {
                            if let goalTarget = item.goalTarget {
                                onOpenGoal(goalTarget)
                            } else if let planRoute = item.planRoute {
                                onOpenPlanRoute(planRoute)
                            }
                        } label: {
                            HStack(alignment: .top, spacing: theme.spacing.sm) {
                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                    TagPill(item.signalLabel, state: item.visualState)
                                    Text(item.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    Text(item.summary)
                                        .font(theme.typography.body)
                                        .foregroundStyle(theme.colors.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer(minLength: theme.spacing.sm)
                                if item.goalTarget != nil || item.planRoute != nil {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                        .foregroundStyle(theme.colors.textTertiary)
                                }
                            }
                            .padding(theme.spacing.md)
                            .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                            .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(item.goalTarget == nil && item.planRoute == nil)
                        .accessibilityIdentifier(reviewConstellationIdentifier(item: item, index: index))
                    }
                }
            }
        }
        .accessibilityIdentifier("insights.review-constellation")
        .ambitionPanelAccessibility()
    }

    private func reviewConstellationIdentifier(item: InsightsReviewConstellationItem, index: Int) -> String {
        if item.planRoute != nil && item.goalTarget == nil {
            return "insights.review-constellation.constellation-plan"
        }
        if item.goalTarget != nil && index == state.items.firstIndex(where: { $0.goalTarget != nil }) {
            return "insights.review-constellation.primary-goal"
        }
        return "insights.review-constellation.\(item.id)"
    }
}

private struct InsightsHistoryLayerCard: View {
    @Environment(\.ambitionTheme) private var theme

    let history: InsightsHistoryLayerState
    let onOpenItem: (InsightsTimelineItem) -> Void
    let onOpenHistory: () -> Void
    let onOpenReview: () -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: history.title, subtitle: history.subtitle)

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(history.summaryTitle)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(history.summaryDetail)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                InsightsTimelineCard(
                    title: "Recent timeline",
                    subtitle: "Summary first, deeper history on demand.",
                    items: history.previewItems,
                    onOpenItem: onOpenItem
                )

                HStack(spacing: theme.spacing.sm) {
                    Button("Open deeper history", action: onOpenHistory)
                        .buttonStyle(AmbitionButtonStyle(tier: .secondary, state: .selected))
                        .accessibilityIdentifier("insights.open-history")

                    Button("Open monthly review", action: onOpenReview)
                        .buttonStyle(AmbitionButtonStyle(tier: .tertiary, state: .default))
                        .accessibilityIdentifier("insights.open-monthly-review")
                }
            }
        }
        .accessibilityIdentifier("insights.history-layer")
        .ambitionPanelAccessibility()
    }
}

private struct InsightsTimelineCard: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String
    let items: [InsightsTimelineItem]
    let onOpenItem: (InsightsTimelineItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            SectionHeader(title: title, subtitle: subtitle)

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                ForEach(items) { item in
                    Button {
                        onOpenItem(item)
                    } label: {
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            Image(systemName: item.icon)
                                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                .foregroundStyle(theme.stateStyle(for: item.visualState).accent)
                                .padding(.top, 2)

                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                HStack(spacing: theme.spacing.xs) {
                                    Text(item.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    if let badge = item.badge {
                                        TagPill(badge, state: item.visualState)
                                    }
                                }
                                Text(item.subtitle)
                                    .font(theme.typography.body)
                                    .foregroundStyle(theme.colors.textSecondary)
                                Text(item.timestamp)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                            }

                            Spacer(minLength: theme.spacing.sm)
                            if item.goalTarget != nil || item.planRoute != nil {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                    .foregroundStyle(theme.colors.textTertiary)
                            }
                        }
                        .padding(theme.spacing.md)
                        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
                        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .disabled(item.goalTarget == nil && item.planRoute == nil)
                }
            }
        }
    }
}

private struct InsightsRouteHeroCard: View {
    @Environment(\.ambitionTheme) private var theme

    let eyebrow: String
    let title: String
    let subtitle: String
    let dominantTruth: String
    let trustWhisper: String
    let state: AmbitionVisualState

    var body: some View {
        HeroCard(state: state) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(eyebrow)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(title)
                        .font(theme.typography.hero)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Text(dominantTruth)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(trustWhisper)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .ambitionPanelAccessibility()
    }
}

private struct InsightsRouteActionRow: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String
    let state: AmbitionVisualState

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(subtitle)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: theme.spacing.sm)
            Image(systemName: "arrow.right")
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.stateStyle(for: state).accent)
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }
}

private struct InsightsMicroChart: View {
    @Environment(\.ambitionTheme) private var theme

    let points: [TrendPoint]
    let state: AmbitionVisualState

    var body: some View {
        GeometryReader { geometry in
            let height = max(geometry.size.height, 1)
            let width = max(geometry.size.width, 1)
            let step = points.count > 1 ? width / CGFloat(points.count - 1) : width
            let accent = theme.stateStyle(for: state).accent

            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(theme.colors.surfaceOverlay)

                Path { path in
                    for (index, point) in points.enumerated() {
                        let x = CGFloat(index) * step
                        let y = height - (CGFloat(point.value) * height)
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                HStack(alignment: .bottom, spacing: theme.spacing.xs) {
                    ForEach(points) { point in
                        VStack(spacing: theme.spacing.xxxs) {
                            Capsule()
                                .fill(accent.opacity(0.25))
                                .frame(height: max(8, CGFloat(point.value) * 36))
                            Text(point.label)
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, theme.spacing.xs)
                .padding(.vertical, theme.spacing.xs)
            }
        }
        .frame(height: 74)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pattern chart")
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

#Preview("Monthly Review Route") {
    NavigationStack {
        InsightsMonthlyReviewScreen()
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}
#endif
