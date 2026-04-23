import AmbitionsDesignSystem
import SwiftUI

struct GoalsHeroCard: View {
    @Environment(\.ambitionTheme) private var theme

    let overview: GoalsOverview
    let onPrimaryAction: (GoalsBoardPrimaryAction) -> Void

    var body: some View {
        HeroCard(state: overview.heroPrimaryAction.state) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(overview.hero.eyebrow)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(overview.hero.title)
                        .font(theme.typography.hero)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(overview.hero.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(overview.hero.dominantTruth)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(overview.hero.pressureSummary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(overview.hero.contextPills) { pill in
                            TagPill(pill.title, icon: pill.icon, state: pill.state)
                        }
                    }
                }

                if overview.hero.attentionPills.isEmpty == false {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: theme.spacing.xs) {
                            ForEach(overview.hero.attentionPills) { pill in
                                TagPill(pill.title, icon: pill.icon, state: pill.state)
                            }
                        }
                    }
                }

                GoalsHeroPrimaryActionButton(
                    action: overview.heroPrimaryAction,
                    handler: onPrimaryAction
                )
            }
        }
        .accessibilityIdentifier("goals.hero-card")
        .ambitionPanelAccessibility()
    }
}

private struct GoalsHeroPrimaryActionButton: View {
    @Environment(\.ambitionTheme) private var theme

    let action: GoalsBoardPrimaryAction
    let handler: (GoalsBoardPrimaryAction) -> Void

    var body: some View {
        Button {
            handler(action)
        } label: {
            HStack(alignment: .center, spacing: theme.spacing.sm) {
                Image(systemName: action.systemImage)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(action.title)
                        .font(theme.typography.bodyEmphasized)
                    Text(action.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(AmbitionButtonStyle(tier: .hero, state: action.state))
        .accessibilityHint(action.subtitle)
        .accessibilityIdentifier("goals.hero.primary-action")
    }
}

struct GoalsWeekPressureCard: View {
    @Environment(\.ambitionTheme) private var theme

    let summary: GoalsWeekPressureSummary

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(summary.title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(summary.subtitle)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    Spacer()
                    TagPill(summary.pill.title, icon: summary.pill.icon, state: summary.pill.state)
                }

                HStack(spacing: theme.spacing.sm) {
                    metricBlock(title: "Alive", value: summary.leadingMetric)
                    metricBlock(title: "Stretch", value: summary.trailingMetric)
                }
            }
        }
        .accessibilityIdentifier("goals.week-pressure")
        .ambitionPanelAccessibility()
    }

    @ViewBuilder
    private func metricBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
            Text(value)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
    }
}

struct GoalsBoardBandSection: View {
    @Environment(\.ambitionTheme) private var theme

    let band: GoalsBoardBand

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: band.title, subtitle: band.subtitle)

                if band.cards.isEmpty {
                    EmptyStateCard(
                        title: "Nothing to surface here yet",
                        message: band.subtitle,
                        icon: "scope"
                    )
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(band.cards) { card in
                            NavigationLink(value: card.target) {
                                GoalsBoardCardView(card: card)
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("goals.card.open.\(card.target.goalID ?? card.target.draftID ?? card.id)")
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("goals.band.\(band.kind.rawValue)")
        .ambitionPanelAccessibility()
    }
}

struct GoalsBoardCardView: View {
    @Environment(\.ambitionTheme) private var theme

    let card: GoalsBoardCardState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    HStack(spacing: theme.spacing.xs) {
                        TagPill(card.modeLabel, state: card.renderState.visualState)
                        TagPill(card.posture.title, state: card.posture.visualState)
                    }

                    Text(card.title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)

                    Text(card.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)

                VStack(alignment: .trailing, spacing: theme.spacing.xxxs) {
                    Text(card.priorityLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                    Text(card.timingLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            ProgressRail(
                title: card.progressLabel,
                progress: card.progressValue,
                trailingValue: "\(Int(card.progressValue * 100))%",
                state: card.posture.visualState
            )

            HStack(alignment: .top, spacing: theme.spacing.sm) {
                summaryColumn(title: "This week", body: card.weekRelationship)
                summaryColumn(title: "Phase", body: card.phaseSummary)
            }

            HStack(alignment: .top, spacing: theme.spacing.sm) {
                summaryColumn(title: "Milestones", body: card.milestoneSummary)
                summaryColumn(title: "Pressure", body: card.pressureSummary)
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(card.nextStepHint)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)

                if let supportLabel = card.supportLabel {
                    Text(supportLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }

                if let shellSummary = card.shellSummary {
                    GoalShellSummaryCompactView(summary: shellSummary)
                        .padding(.top, theme.spacing.xxxs)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityIdentifier("goals.card.\(card.id)")
        .ambitionPanelAccessibility()
    }

    @ViewBuilder
    private func summaryColumn(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
            Text(body)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceSecondary.opacity(0.7)))
    }
}

struct GoalsLowerPriorityDisclosureSection: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalsLowerPriorityState
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle) {
                    Button(isExpanded ? "Hide" : state.disclosureTitle, action: onToggle)
                        .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                        .accessibilityIdentifier("goals.lower-priority.toggle")
                }

                if isExpanded {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(state.cards) { card in
                            NavigationLink(value: card.target) {
                                GoalsBoardCardView(card: card)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .transition(.ambitionPanel)
                }
            }
        }
        .accessibilityIdentifier("goals.band.lower-priority")
        .ambitionPanelAccessibility()
    }
}

struct GoalsHorizonLadderCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalsHorizonLadderState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)

                if state.rungs.isEmpty {
                    EmptyStateCard(
                        title: "The ladder appears once goals have a visible phase or path.",
                        message: "It stays shallow here so direction stays legible without pulling Goal Detail forward.",
                        icon: "stairs"
                    )
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(state.rungs) { rung in
                            NavigationLink(value: rung.target) {
                                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                            Text(rung.title)
                                                .font(theme.typography.bodyEmphasized)
                                                .foregroundStyle(theme.colors.textPrimary)
                                            Text(rung.summary)
                                                .font(theme.typography.caption)
                                                .foregroundStyle(theme.colors.textSecondary)
                                        }
                                        Spacer()
                                        TagPill(rung.signalLabel, state: rung.state)
                                    }

                                    HStack(spacing: theme.spacing.sm) {
                                        Text(rung.milestoneLabel)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textTertiary)
                                        Text(rung.highlight)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textSecondary)
                                            .lineLimit(2)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(theme.spacing.sm)
                                .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("goals.horizon-ladder")
        .ambitionPanelAccessibility()
    }
}

struct GoalSuggestionCard: View {
    @Environment(\.ambitionTheme) private var theme

    let step: GoalDetailStepItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
    }
}

struct GoalDetailHeroCard: View {
    @Environment(\.ambitionTheme) private var theme

    let detail: GoalDetailPresentation

    var body: some View {
        HeroCard(state: detail.headline.renderState.visualState, accent: detail.supportModeActive ? theme.colors.accentWarm : nil) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                        Text(detail.headline.eyebrow)
                            .font(theme.typography.micro)
                            .foregroundStyle(theme.colors.accentWarm)
                        Text(detail.headline.title)
                            .font(theme.typography.hero)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(detail.headline.subtitle)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    Spacer(minLength: theme.spacing.sm)
                    VStack(alignment: .trailing, spacing: theme.spacing.xs) {
                        TagPill(detail.headline.modeLabel, state: detail.headline.renderState.visualState)
                        TagPill(detail.headline.timingLabel, state: .default)
                    }
                }

                ProgressRail(
                    title: detail.progress.label,
                    progress: detail.progress.value,
                    trailingValue: "\(Int(detail.progress.value * 100))%",
                    state: detail.headline.renderState.visualState
                )

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(detail.strategicStatus.title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(detail.strategicStatus.summary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                    Text(detail.strategicStatus.supportingDetail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(detail.intent)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)

                    if let supportLabel = detail.headline.supportLabel {
                        Text(supportLabel)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
            }
        }
        .accessibilityIdentifier("goal-detail.strategic-header")
        .ambitionPanelAccessibility()
    }
}

struct GoalDetailFilmstripCard: View {
    @Environment(\.ambitionTheme) private var theme

    let stages: [GoalPathStage]

    var body: some View {
        GoalDetailSectionCard(title: "Path filmstrip", subtitle: "Movement stays visible before deeper tactics.") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.sm) {
                    ForEach(stages) { stage in
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            HStack(alignment: .top, spacing: theme.spacing.xs) {
                                Circle()
                                    .fill(color(for: stage))
                                    .frame(width: 10, height: 10)
                                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                    Text(stage.statusLabel)
                                        .font(theme.typography.micro)
                                        .foregroundStyle(theme.colors.textTertiary)
                                    Text(stage.title)
                                        .font(theme.typography.bodyEmphasized)
                                        .foregroundStyle(theme.colors.textPrimary)
                                }
                                Spacer(minLength: theme.spacing.sm)
                                TagPill(stage.stepCountLabel, state: stage.state)
                            }

                            Text(stage.summary)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .lineLimit(3)

                            if let highlight = stage.highlight {
                                Text(highlight)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                                    .lineLimit(2)
                            }
                        }
                        .frame(width: 220, alignment: .leading)
                        .padding(theme.spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                                .fill(theme.colors.surfaceOverlay)
                        )
                        .overlay(alignment: .leading) {
                            Rectangle()
                                .fill(color(for: stage))
                                .frame(width: 3)
                        }
                    }
                }
                .padding(.vertical, 1)
            }
        }
        .accessibilityIdentifier("goal-detail.path-filmstrip")
    }

    private func color(for stage: GoalPathStage) -> Color {
        switch stage.position {
        case .completed:
            return theme.colors.success
        case .current:
            return theme.colors.accentPrimary
        case .blocked:
            return theme.colors.warning
        case .upcoming:
            return theme.colors.textTertiary
        }
    }
}

struct GoalDetailNextMovementCard: View {
    @Environment(\.ambitionTheme) private var theme

    let movement: GoalDetailNextMovement

    var body: some View {
        GoalDetailSectionCard(title: "What matters next", subtitle: "One move first, before the rest of the path.") {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(movement.title)
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(movement.summary)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    Spacer()
                    TagPill(movement.timingLabel, state: movement.state)
                }

                Text(movement.rationale)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .accessibilityIdentifier("goal-detail.next-movement")
    }
}

struct GoalDetailTrajectoryCard: View {
    @Environment(\.ambitionTheme) private var theme

    let trajectory: GoalDetailTrajectoryState

    var body: some View {
        GoalDetailSectionCard(title: "Current phase and momentum", subtitle: "Phase truth stays strategic instead of reading like admin.") {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(trajectory.phaseTitle)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(trajectory.phaseSummary)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    trajectoryLine(title: "Milestone", detail: trajectory.milestoneSummary)
                    trajectoryLine(title: "Momentum", detail: trajectory.momentumSummary)
                    trajectoryLine(title: "Timeline", detail: trajectory.timelineSummary)
                }
            }
        }
    }

    @ViewBuilder
    private func trajectoryLine(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
            Text(detail)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
    }
}

struct GoalDetailRecentMovementCard: View {
    @Environment(\.ambitionTheme) private var theme

    let movement: GoalDetailRecentMovementState

    var body: some View {
        GoalDetailSectionCard(title: movement.title, subtitle: movement.summary) {
            if movement.items.isEmpty {
                Text("No recent movement is visible yet.")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(movement.items) { item in
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
        }
        .accessibilityIdentifier("goal-detail.recent-movement")
    }
}

struct GoalActionGrid: View {
    @Environment(\.ambitionTheme) private var theme

    let actions: [GoalDetailActionState]
    let handler: (GoalDetailActionKind) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: theme.spacing.xs)], spacing: theme.spacing.xs) {
            ForEach(actions) { action in
                Button {
                    handler(action.kind)
                } label: {
                    Label(action.title, systemImage: action.systemImage)
                        .font(theme.typography.caption)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 44)
                        .padding(.vertical, theme.spacing.xs)
                }
                .buttonStyle(AmbitionPressableButtonStyle(state: action.state))
            }
        }
    }
}

struct GoalDetailSectionCard: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let subtitle: String?
    let content: AnyView

    init<Content: View>(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = AnyView(content())
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: title, subtitle: subtitle)
                content
            }
        }
        .ambitionPanelAccessibility()
    }
}
