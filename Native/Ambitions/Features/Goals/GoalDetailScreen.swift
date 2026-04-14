import AmbitionsDesignSystem
import SwiftUI

struct GoalDetailScreen: View {
    @Environment(\.appContainer) private var container
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: GoalDetailViewModel

    init(target: GoalRouteTarget, viewModel: GoalDetailViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? GoalDetailViewModel(target: target))
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                switch viewModel.state {
                case .loading:
                    LoadingSkeletonCard(lineCount: 10)
                case let .failed(message):
                    EmptyStateCard(
                        title: "Goal Detail is unavailable",
                        message: message,
                        icon: "exclamationmark.triangle",
                        actionTitle: "Retry"
                    ) {
                        Task { await viewModel.refresh(using: container.goalsService) }
                    }
                case let .loaded(detail):
                    GoalDetailHeroCard(detail: detail)

                    if let inlineMessage = viewModel.inlineMessage {
                        AppCard(state: inlineMessage.state) {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                Text(inlineMessage.title)
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(inlineMessage.body)
                                    .font(theme.typography.body)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                        }
                    }

                    GoalDetailSectionCard(title: "Outcome", subtitle: detail.progressNote) {
                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                            Text(detail.outcome)
                                .font(theme.typography.bodyEmphasized)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(detail.timingNote)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                            Text(detail.progress.evidenceLabel)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textTertiary)
                        }
                    }

                    GoalDetailSectionCard(title: "Action Rail", subtitle: "These controls write back to the real native plan and feedback history.") {
                        GoalActionGrid(actions: detail.actions) { action in
                            Task { await viewModel.perform(action, using: container.goalsService) }
                        }
                    }

                    if detail.assumptions.isEmpty == false {
                        GoalDetailSectionCard(title: "Starter Assumptions", subtitle: "Visible assumptions keep provisional plans honest.") {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                ForEach(detail.assumptions, id: \.self) { assumption in
                                    Label(assumption, systemImage: "leaf.fill")
                                        .font(theme.typography.caption)
                                        .foregroundStyle(theme.colors.textSecondary)
                                }
                            }
                        }
                    }

                    if let clarification = detail.clarification {
                        GoalDetailSectionCard(title: clarification.title, subtitle: clarification.subtitle) {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(clarification.questions) { question in
                                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                        Text(question.prompt)
                                            .font(theme.typography.bodyEmphasized)
                                            .foregroundStyle(theme.colors.textPrimary)
                                        Text(question.rationale)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textSecondary)
                                        Text("Safe default: \(question.gentleDefault)")
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textTertiary)
                                    }
                                    .padding(theme.spacing.sm)
                                    .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                                }
                            }
                        }
                    }

                    if let blocked = detail.blocked {
                        GoalDetailSectionCard(title: blocked.title, subtitle: blocked.subtitle) {
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                ForEach(blocked.blockers, id: \.self) { blocker in
                                    Label(blocker, systemImage: "exclamationmark.triangle.fill")
                                        .font(theme.typography.body)
                                        .foregroundStyle(theme.colors.textSecondary)
                                }
                            }
                        }
                    }

                    GoalDetailSectionCard(
                        title: viewModel.lens == .path ? "Path View" : "Task View",
                        subtitle: viewModel.lens == .path ? "Milestones and workstreams first." : "Section structure and next steps."
                    ) {
                        SegmentedFilterBar(items: GoalDetailLens.allCases, selection: $viewModel.lens) { $0.title }
                            .padding(.bottom, theme.spacing.sm)

                        if viewModel.lens == .path {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(detail.pathStages) { stage in
                                    WidgetCard(state: stage.state) {
                                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                            HStack {
                                                Text(stage.title)
                                                    .font(theme.typography.section)
                                                    .foregroundStyle(theme.colors.textPrimary)
                                                Spacer()
                                                TagPill(stage.stepCountLabel, state: stage.state)
                                            }
                                            Text(stage.summary)
                                                .font(theme.typography.body)
                                                .foregroundStyle(theme.colors.textSecondary)
                                            if let highlight = stage.highlight {
                                                Text(highlight)
                                                    .font(theme.typography.caption)
                                                    .foregroundStyle(theme.colors.textTertiary)
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(detail.sections) { section in
                                    AppCard {
                                        VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                                    Text(section.title)
                                                        .font(theme.typography.section)
                                                        .foregroundStyle(theme.colors.textPrimary)
                                                    Text(section.summary)
                                                        .font(theme.typography.caption)
                                                        .foregroundStyle(theme.colors.textSecondary)
                                                }
                                                Spacer()
                                                TagPill(section.kindLabel, state: .default)
                                            }
                                            ForEach(section.steps) { step in
                                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                                    HStack {
                                                        Text(step.title)
                                                            .font(theme.typography.bodyEmphasized)
                                                            .foregroundStyle(theme.colors.textPrimary)
                                                        Spacer()
                                                        TagPill(step.statusLabel, state: step.state)
                                                    }
                                                    Text(step.summary)
                                                        .font(theme.typography.caption)
                                                        .foregroundStyle(theme.colors.textSecondary)
                                                    Text(step.timingLabel)
                                                        .font(theme.typography.caption)
                                                        .foregroundStyle(theme.colors.textTertiary)
                                                }
                                                .padding(theme.spacing.sm)
                                                .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if detail.suggestions.isEmpty == false {
                        GoalDetailSectionCard(title: "Suggested Next Steps", subtitle: "The calmest moves that still create signal.") {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                ForEach(detail.suggestions) { step in
                                    GoalRowCard(
                                        item: GoalListItem(
                                            id: step.id,
                                            target: detail.target,
                                            title: step.title,
                                            subtitle: step.summary,
                                            mode: .project,
                                            renderState: .active,
                                            progressValue: 0.42,
                                            progressLabel: step.statusLabel,
                                            statusLabel: step.statusLabel,
                                            timingLabel: step.timingLabel,
                                            nextStepHint: step.summary,
                                            modeLabel: "Next step",
                                            supportLabel: nil,
                                            relevanceScore: 0.8,
                                            momentumScore: 0.6,
                                            urgencyScore: 0.6,
                                            manualPriorityRank: 0,
                                            updatedAt: ""
                                        )
                                    )
                                }
                            }
                        }
                    }

                    GoalDetailSectionCard(title: "Evidence and History", subtitle: "Real native evidence, feedback, and replanning context.") {
                        VStack(alignment: .leading, spacing: theme.spacing.md) {
                            if detail.evidence.isEmpty {
                                Text("No evidence logged yet.")
                                    .font(theme.typography.body)
                                    .foregroundStyle(theme.colors.textSecondary)
                            } else {
                                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                    ForEach(detail.evidence) { item in
                                        Label {
                                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                                Text(item.title)
                                                    .font(theme.typography.bodyEmphasized)
                                                Text(item.subtitle)
                                                    .font(theme.typography.caption)
                                                    .foregroundStyle(theme.colors.textSecondary)
                                            }
                                        } icon: {
                                            Image(systemName: "sparkles")
                                                .foregroundStyle(theme.colors.accentPrimary)
                                        }
                                    }
                                }
                            }

                            if detail.history.isEmpty == false {
                                Divider()
                                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                    ForEach(detail.history) { item in
                                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                                            TagPill(item.title, state: item.state)
                                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                                Text(item.subtitle)
                                                    .font(theme.typography.caption)
                                                    .foregroundStyle(theme.colors.textSecondary)
                                                Text(item.timestamp)
                                                    .font(theme.typography.micro)
                                                    .foregroundStyle(theme.colors.textTertiary)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, theme.spacing.lg)
            .padding(.vertical, theme.spacing.md)
        }
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refresh(using: container.goalsService)
        }
        .navigationTitle("Goal")
        .navigationBarTitleDisplayMode(.inline)
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: viewModel.inlineMessage?.title)
        .animation(theme.motion.animation(reduceMotion: reduceMotion), value: viewModel.lens)
        .task {
            await viewModel.load(using: container.goalsService)
        }
    }
}

#Preview("Goal Detail Active") {
    NavigationStack {
        GoalDetailScreen(
            target: PreviewGoalsScenarios.activeTarget,
            viewModel: GoalDetailViewModel(
                target: PreviewGoalsScenarios.activeTarget,
                state: .loaded(PreviewGoalsScenarios.detailScenarios[PreviewGoalsScenarios.activeTarget.id]!)
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Goal Detail Starter") {
    NavigationStack {
        GoalDetailScreen(
            target: PreviewGoalsScenarios.starterTarget,
            viewModel: GoalDetailViewModel(
                target: PreviewGoalsScenarios.starterTarget,
                state: .loaded(PreviewGoalsScenarios.detailScenarios[PreviewGoalsScenarios.starterTarget.id]!),
                lens: .path
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Goal Detail Clarification") {
    NavigationStack {
        GoalDetailScreen(
            target: PreviewGoalsScenarios.clarificationTarget,
            viewModel: GoalDetailViewModel(
                target: PreviewGoalsScenarios.clarificationTarget,
                state: .loaded(PreviewGoalsScenarios.detailScenarios[PreviewGoalsScenarios.clarificationTarget.id]!),
                lens: .path
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Goal Detail Blocked") {
    NavigationStack {
        GoalDetailScreen(
            target: PreviewGoalsScenarios.blockedTarget,
            viewModel: GoalDetailViewModel(
                target: PreviewGoalsScenarios.blockedTarget,
                state: .loaded(PreviewGoalsScenarios.detailScenarios[PreviewGoalsScenarios.blockedTarget.id]!),
                lens: .path
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}

#Preview("Goal Detail Support") {
    NavigationStack {
        GoalDetailScreen(
            target: PreviewGoalsScenarios.supportTarget,
            viewModel: GoalDetailViewModel(
                target: PreviewGoalsScenarios.supportTarget,
                state: .loaded(PreviewGoalsScenarios.detailScenarios[PreviewGoalsScenarios.supportTarget.id]!),
                lens: .path
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
