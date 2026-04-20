import AmbitionsDesignSystem
import SwiftUI

struct PlanScreen: View {
    @Environment(\.appContainer) private var appContainer
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: PlanViewModel

    @MainActor
    init(viewModel: PlanViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? PlanViewModel())
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    LoadingSkeletonCard(lineCount: 8)
                        .transition(.ambitionPanel)
                case let .failed(message):
                    EmptyStateCard(
                        title: "Plan is unavailable",
                        message: message,
                        icon: AppTab.plan.systemImage,
                        actionTitle: "Retry",
                        actionAccessibilityIdentifier: "plan.retry-button"
                    ) {
                        Task { await viewModel.refresh(using: container.planService) }
                    }
                    .transition(.ambitionPanel)
                case let .loaded(dashboard):
                    PlanHeroCard(dashboard: dashboard)

                    if let emptyTitle = dashboard.emptyTitle, let emptyMessage = dashboard.emptyMessage {
                        EmptyStateCard(title: emptyTitle, message: emptyMessage, icon: AppTab.plan.systemImage)
                    }

                    PlanMetricsCard(metrics: dashboard.metrics)

                    PlanFocusCard(items: dashboard.focusItems)

                    PlanPressureCard(items: dashboard.pressureItems)

                    PlanSecondaryDestinationsCard(destinations: dashboard.secondaryDestinations) { destination in
                        if destination.id == "plan-habits" {
                            container.navigation.openHabits()
                        }
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Plan")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    container.navigation.openHabits()
                } label: {
                    Label("Habits", systemImage: AppTab.habits.systemImage)
                }
                .accessibilityIdentifier("plan.open-habits-button")
            }
        }
        .refreshable {
            await viewModel.refresh(using: container.planService)
        }
        .accessibilityIdentifier("plan.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            await viewModel.load(using: container.planService)
        }
    }

    private var container: AppContainer {
        guard let appContainer else {
            preconditionFailure("App container must be injected.")
        }
        return appContainer
    }
}

private struct PlanHeroCard: View {
    @Environment(\.ambitionTheme) private var theme

    let dashboard: PlanDashboard

    var body: some View {
        HeroCard(state: dashboard.posture.visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text("Plan")
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(dashboard.title)
                        .font(theme.typography.hero)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(dashboard.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                HStack(spacing: theme.spacing.xs) {
                    TagPill(dashboard.timeframeLabel, icon: "calendar", state: .default)
                    TagPill(dashboard.posture.label, icon: AppTab.plan.systemImage, state: dashboard.posture.visualState)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(dashboard.posture.title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(dashboard.posture.detail)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
        }
        .ambitionPanelAccessibility()
    }
}

private struct PlanMetricsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let metrics: [MetricSummary]

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: "Weekly shape", subtitle: "A compact read on what the current week is trying to carry.")

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 142), spacing: theme.spacing.sm)], spacing: theme.spacing.sm) {
                    ForEach(metrics) { metric in
                        StatTile(
                            title: metric.title,
                            value: metric.value,
                            detail: metric.detail,
                            icon: metric.icon,
                            state: metric.id == "plan-pressure" && metric.value != "0" ? .warning : .default
                        )
                    }
                }
            }
        }
    }
}

private struct PlanFocusCard: View {
    @Environment(\.ambitionTheme) private var theme

    let items: [PlanFocusItem]

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    title: "Visible work",
                    subtitle: items.isEmpty
                        ? "No current step is pressing into this weekly view."
                        : "The week is anchored by these goal-linked steps."
                )

                if items.isEmpty {
                    Text("Plan is staying quiet because there is no dated or suggested work to promote here.")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(items) { item in
                            if let target = item.target {
                                NavigationLink(value: target) {
                                    PlanFocusRow(item: item)
                                }
                                .buttonStyle(.plain)
                            } else {
                                PlanFocusRow(item: item)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct PlanFocusRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: PlanFocusItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    HStack(spacing: theme.spacing.xs) {
                        TagPill(item.statusLabel, state: item.visualState)
                        TagPill(item.timingLabel, state: .default)
                    }
                    Text(item.title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(item.goalLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
                Spacer(minLength: theme.spacing.sm)
                Image(systemName: "chevron.right")
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility()
    }
}

private struct PlanPressureCard: View {
    @Environment(\.ambitionTheme) private var theme

    let items: [PlanPressureItem]

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: "Planning pressure", subtitle: "Captures, clarity gaps, and friction stay visible before they become daily noise.")

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(items) { item in
                        PlanInfoRow(title: item.title, detail: item.detail, valueLabel: item.valueLabel, icon: item.icon, state: item.visualState)
                    }
                }
            }
        }
    }
}

private struct PlanSecondaryDestinationsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let destinations: [PlanSecondaryDestination]
    let onOpen: (PlanSecondaryDestination) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: "Supporting loops", subtitle: "These remain part of planning without becoming extra top-level tabs.")

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(destinations) { destination in
                        Button {
                            onOpen(destination)
                        } label: {
                            PlanInfoRow(
                                title: destination.title,
                                detail: destination.detail,
                                valueLabel: destination.valueLabel,
                                icon: destination.icon,
                                state: destination.visualState
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("plan.open-\(destination.id)-button")
                    }
                }
            }
        }
    }
}

private struct PlanInfoRow: View {
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
#Preview("Plan Seeded") {
    NavigationStack {
        PlanScreen(viewModel: PlanViewModel(state: .loaded(PreviewPlanScenarios.seeded)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Plan Empty") {
    NavigationStack {
        PlanScreen(viewModel: PlanViewModel(state: .loaded(PreviewPlanScenarios.empty)))
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
#endif
