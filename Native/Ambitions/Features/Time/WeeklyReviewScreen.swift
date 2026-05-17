import AmbitionsDesignSystem
import Observation
import SwiftUI

@MainActor
@Observable
final class WeeklyReviewViewModel {
    var state: AsyncViewState<WeeklyReviewDashboard> = .loading
    private var hasLoaded = false

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(dashboard):
            return "loaded:\(dashboard.carryForwardItems.count):\(dashboard.timeframeLabel)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    func load(using service: any TimeServicing, now: Date = .now) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service, now: now)
    }

    func refresh(using service: any TimeServicing, now: Date = .now) async {
        do {
            state = .loaded(try await service.loadWeeklyReviewDashboard(now: now))
        } catch {
            state = .failed("Unable to load Weekly Review: \(error.localizedDescription)")
        }
    }
}

struct WeeklyReviewScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel = WeeklyReviewViewModel()

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    AsyncStateCard(.loading(lines: 8))
                case .failed:
                    DegradedStateCard(
                        state: DegradedStateOrchestrator.unavailable(surface: "Weekly Review"),
                        primaryAccessibilityIdentifier: "weekly-review.retry-button",
                        onPrimaryAction: {
                            Task { await viewModel.refresh(using: container.timeService) }
                        }
                    )
                case let .loaded(dashboard):
                    WeeklyReviewHeroCard(dashboard: dashboard)
                    WeeklyReviewSummaryCard(dashboard: dashboard)

                    if dashboard.carryForwardItems.isEmpty {
                        DegradedStateCard(
                            state: DegradedStateOrchestrator.weeklyReviewEmpty(),
                            primaryAccessibilityIdentifier: "weekly-review.empty.return-plan",
                            onPrimaryAction: {
                                container.navigation.resetTimePath()
                            }
                        )
                    } else {
                        WeeklyReviewCarryForwardCard(items: dashboard.carryForwardItems, onOpenGoal: openGoal)
                    }

                    if let context = dashboard.splitPaneContext {
                        Button {
                            guard let target = context.target else { return }
                            openGoal(target)
                        } label: {
                            WeeklyReviewContextCard(context: context)
                        }
                        .buttonStyle(.plain)
                        .disabled(context.target == nil)
                        .accessibilityIdentifier("weekly-review.split-pane")
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: theme.spacing.md) {
                            SectionHeader(
                                title: "Support systems inside the review",
                                subtitle: "Rituals and captures should change the next week only when they improve how the week holds together."
                            )
                            Text(dashboard.habitSummary)
                                .font(theme.typography.body)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(dashboard.captureSummary)
                                .font(theme.typography.body)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }

                    Button {
                        container.navigation.resetTimePath()
                    } label: {
                        HStack(alignment: .center, spacing: theme.spacing.sm) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(dashboard.returnActionTitle)
                                    .font(theme.typography.bodyEmphasized)
                                Text(dashboard.returnActionSubtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(AmbitionButtonStyle(tier: .hero, state: .selected))
                    .accessibilityIdentifier("shell.plan.back-button")
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Weekly Review")
        .refreshable {
            await viewModel.refresh(using: container.timeService)
        }
        .accessibilityIdentifier("weekly-review.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            await viewModel.load(using: container.timeService)
        }
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }

    private func openGoal(_ target: GoalRouteTarget) {
        container.navigation.openGoalDetail(target)
    }
}

private struct WeeklyReviewHeroCard: View {
    @Environment(\.ambitionTheme) private var theme

    let dashboard: WeeklyReviewDashboard

    var body: some View {
        HeroCard(state: .selected) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(dashboard.hero.eyebrow)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(dashboard.hero.title)
                        .font(theme.typography.hero)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(dashboard.hero.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Text(dashboard.hero.dominantTruth)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(dashboard.hero.contextPills) { pill in
                            TagPill(pill.title, icon: pill.icon, state: pill.state)
                        }
                    }
                }

                Text(dashboard.hero.continuityLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .accessibilityIdentifier("weekly-review.hero-card")
        .ambitionPanelAccessibility()
    }
}

private struct WeeklyReviewSummaryCard: View {
    @Environment(\.ambitionTheme) private var theme

    let dashboard: WeeklyReviewDashboard

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: dashboard.summaryTitle, subtitle: dashboard.summaryDetail)
                Text("The review is meant to explain what the next week should inherit, what should lighten, and what should be left behind.")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }
}

private struct WeeklyReviewCarryForwardCard: View {
    @Environment(\.ambitionTheme) private var theme

    let items: [WeeklyReviewCarryForwardItem]
    let onOpenGoal: (GoalRouteTarget) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Carry forward carefully",
                    subtitle: "Carry forward only the work the next week can still explain. Everything else should lighten, park, or end."
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(items) { item in
                        Button {
                            guard let target = item.goalTarget else { return }
                            onOpenGoal(target)
                        } label: {
                            HStack(alignment: .top, spacing: theme.spacing.sm) {
                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                    TagPill(item.bridgeLabel, state: item.state)
                                    Text(item.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                    Text(item.detail)
                                        .font(theme.typography.body)
                                        .foregroundStyle(theme.colors.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                                if item.goalTarget != nil {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                        .foregroundStyle(theme.colors.textTertiary)
                                }
                            }
                            .padding(theme.spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                    .fill(theme.colors.surfaceOverlay)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                                    .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(item.goalTarget == nil)
                        .accessibilityIdentifier("weekly-review.item.\(item.id)")
                    }
                }
            }
        }
        .accessibilityIdentifier("weekly-review.carry-forward")
        .ambitionPanelAccessibility()
    }
}

private struct WeeklyReviewContextCard: View {
    @Environment(\.ambitionTheme) private var theme

    let context: TimeWindowMagnetismState

    var body: some View {
        AppCard(state: context.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Constrained split view",
                    subtitle: "One dominant carry-forward lane plus one compact context pane keeps Weekly Review legible on iPhone."
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    Text(context.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(context.detail)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(context.dayLabel)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                        Text(context.suggestionTitle)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                    }
                    Spacer()
                    Text(context.suggestionDetail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.trailing)
                }
                .padding(theme.spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .fill(theme.colors.surfaceOverlay)
                )
            }
        }
        .ambitionPanelAccessibility()
    }
}
