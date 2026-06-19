import AmbitionsDesignSystem
import SwiftUI

// Mutation/accessibility/proof contract: trust actions open inspection routes only after preserving the current goal detail stage, announce the opened inspection, and keep proof references visible.
struct GoalTrustWhisperSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalExplainabilityState
    @Binding var isExpanded: Bool

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(state.whisper.title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(state.whisper.subtitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                        Text(state.whisper.pillLine)
                            .font(theme.typography.micro)
                            .foregroundStyle(theme.colors.textTertiary)
                    }
                    Spacer()
                    Button(isExpanded ? "Hide trust detail" : "Open trust detail") {
                        isExpanded.toggle()
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                    .accessibilityIdentifier("goal-detail.trust-toggle")
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(state.whisper.pills) { pill in
                            TagPill(pill.title, icon: pill.icon, state: pill.state)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("goal-detail.trust-whisper")
        .ambitionPanelAccessibility()
    }
}

struct GoalMemoryNarrativeSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let detail: GoalDetailPresentation
    @Binding var isExpanded: Bool

    var body: some View {
        GoalDetailSectionSurface(title: "What changed and why", subtitle: memorySubtitle) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                if detail.recentMovement.items.isEmpty {
                    Text("No visible changes have landed yet.")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(detail.recentMovement.items.prefix(2)) { item in
                            HStack(alignment: .top, spacing: theme.spacing.sm) {
                                TagPill(item.categoryLabel, state: item.state)
                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                    Text(item.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
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

                if detail.evidence.isEmpty == false || detail.history.isEmpty == false {
                    Button(isExpanded ? "Hide deeper memory" : "Open deeper memory") {
                        isExpanded.toggle()
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                    .accessibilityIdentifier("goal-detail.memory-toggle")
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        if detail.evidence.isEmpty == false {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                Text("Evidence")
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.colors.textPrimary)
                                ForEach(detail.evidence) { item in
                                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                                        Image(systemName: "sparkles")
                                            .foregroundStyle(theme.colors.accentPrimary)
                                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                            Text(item.title)
                                                .font(theme.typography.bodyEmphasized)
                                                .foregroundStyle(theme.colors.textPrimary)
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

                        if detail.history.isEmpty == false {
                            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                                Text("Adjustments")
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.colors.textPrimary)
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
                    .accessibilityIdentifier("goal-detail.memory-panel")
                }
            }
        }
        .accessibilityIdentifier("goal-detail.memory-narrative")
    }

    var memorySubtitle: String {
        if detail.recentMovement.items.isEmpty == false {
            return detail.recentMovement.summary
        }
        if detail.evidence.isEmpty == false || detail.history.isEmpty == false {
            return "The recent story stays readable before the deeper log details."
        }
        return "Memory stays available here without turning the screen into a raw log."
    }
}

struct ExplainabilityLabelList: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String?
    let labels: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            ForEach(labels, id: \.self) { label in
                Text(label)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
    }
}

#if DEBUG
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

#Preview("Goal Detail Trust Heavy") {
    NavigationStack {
        GoalDetailScreen(
            target: PreviewGoalsScenarios.activeTarget,
            viewModel: GoalDetailViewModel(
                target: PreviewGoalsScenarios.activeTarget,
                state: .loaded(PreviewGoalsScenarios.detailScenarios[PreviewGoalsScenarios.activeTarget.id]!),
                isTrustExpanded: true,
                isCorrectionsExpanded: true,
                isMemoryExpanded: true
            )
        )
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
}
#endif
