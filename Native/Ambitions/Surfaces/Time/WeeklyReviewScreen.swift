import AmbitionsDesignSystem
import Observation
import SwiftUI

@MainActor
@Observable
final class WeeklyReviewViewModel {
    var state: AsyncViewState<TimeWeeklyReviewState> = .loading
    private var hasLoaded = false

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(timeState):
            return "loaded:\(timeState.carryForwardItems.count):\(timeState.timeframeLabel)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    func load(using service: any TimeServicing, now: Date) async {
        guard hasLoaded == false else { return }
        hasLoaded = true
        await refresh(using: service, now: now)
    }

    func refresh(using service: any TimeServicing, now: Date) async {
        do {
            state = .loaded(try await service.loadTimeWeeklyReviewState(now: now))
        } catch {
            state = .failed("Unable to load Weekly Review: \(error.localizedDescription)")
        }
    }
}

struct WeeklyReviewScreen: View {
    @Environment(\.appShellCapability) private var appShellCapability
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
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
                    DegradedStateSurface(
                        state: DegradedStateOrchestrator.unavailable(surface: "Weekly Review"),
                        primaryAccessibilityIdentifier: "weekly-review.retry-button",
                        onPrimaryAction: {
                            Task { await refresh() }
                        }
                    )
                case let .loaded(timeState):
                    WeeklyReviewHeroSurface(timeState: timeState)
                    WeeklyReviewSummarySurface(timeState: timeState)

                    if timeState.carryForwardItems.isEmpty {
                        DegradedStateSurface(
                            state: DegradedStateOrchestrator.weeklyReviewEmpty(),
                            primaryAccessibilityIdentifier: "weekly-review.empty.return-time",
                            onPrimaryAction: {
                                shell.navigation.resetTimePath()
                            }
                        )
                    } else {
                        WeeklyReviewCarryForwardSurface(items: timeState.carryForwardItems, onOpenGoal: openGoal)
                    }

                    if let context = timeState.splitPaneContext {
                        Button {
                            guard let target = context.target else { return }
                            openGoal(target)
                        } label: {
                            WeeklyReviewContextSurface(context: context)
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
                            Text(timeState.ritualSupportSummary)
                                .font(theme.typography.body)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(timeState.captureSummary)
                                .font(theme.typography.body)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }

                    Button {
                        shell.navigation.resetTimePath()
                    } label: {
                        HStack(alignment: .center, spacing: theme.spacing.sm) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(timeState.returnActionTitle)
                                    .font(theme.typography.bodyEmphasized)
                                Text(timeState.returnActionSubtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(AmbitionButtonStyle(tier: .hero, state: .selected))
                    .accessibilityIdentifier("shell.time.back-button")
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Weekly Review")
        .refreshable {
            await refresh()
        }
        .accessibilityIdentifier("weekly-review.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            await viewModel.load(using: featureFactory.timeService, now: clock.now)
        }
    }

    private var shell: AppShellCapability {
        guard let appShellCapability else {
            preconditionFailure("App shell capability must be injected.")
        }
        return appShellCapability
    }

    private var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }

    private var clock: any AmbitionsClock {
        featureFactory.clock
    }

    private func refresh() async {
        await viewModel.refresh(using: featureFactory.timeService, now: clock.now)
    }

    private func openGoal(_ target: GoalRouteTarget) {
        shell.navigation.openGoalDetail(target)
    }
}

private struct WeeklyReviewHeroSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let timeState: TimeWeeklyReviewState

    var body: some View {
        HeroCard(state: .selected) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(timeState.hero.eyebrow)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(timeState.hero.title)
                        .font(theme.typography.hero)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(timeState.hero.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Text(timeState.hero.dominantTruth)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(timeState.hero.contextPills) { pill in
                            TagPill(pill.title, icon: pill.icon, state: pill.state)
                        }
                    }
                }

                Text(timeState.hero.continuityLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .accessibilityIdentifier("weekly-review.hero-card")
        .ambitionPanelAccessibility()
    }
}

private struct WeeklyReviewSummarySurface: View {
    @Environment(\.ambitionTheme) private var theme

    let timeState: TimeWeeklyReviewState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: timeState.summaryTitle, subtitle: timeState.summaryDetail)
                Text("The review is meant to explain what the next week should inherit, what should lighten, and what should be left behind.")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }
}

private struct WeeklyReviewCarryForwardSurface: View {
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

private struct WeeklyReviewContextSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let context: TimeWindowMagnetismState

    var body: some View {
        AppCard(state: context.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Constrained split view",
                    subtitle: "One dominant carry-forward path plus one compact context pane keeps Weekly Review legible on iPhone."
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
import AmbitionsTimeFoundation
