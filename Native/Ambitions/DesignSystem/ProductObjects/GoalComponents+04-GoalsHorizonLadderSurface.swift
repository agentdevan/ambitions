import AmbitionsDesignSystem
import SwiftUI

struct GoalsHorizonLadderSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalsHorizonLadderState

    var body: some View {
        ObjectStageSurface {
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

struct GoalAtlasPreviewSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalAtlasPreviewState

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(state.groups) { group in
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(group.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Spacer()
                                Text(group.subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textTertiary)
                            }

                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                ForEach(group.items) { item in
                                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                                        Circle()
                                            .fill(theme.stateStyle(for: item.state).accent)
                                            .frame(width: 8, height: 8)
                                            .padding(.top, 6)
                                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                            Text(item.title)
                                                .font(theme.typography.caption)
                                                .foregroundStyle(theme.colors.textPrimary)
                                            Text(item.subtitle)
                                                .font(theme.typography.caption)
                                                .foregroundStyle(theme.colors.textSecondary)
                                                .lineLimit(2)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(theme.spacing.sm)
                        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Life areas. \(state.groups.map { "\($0.title), \($0.items.count) visible goals" }.joined(separator: ". "))")
        .accessibilityIdentifier("goals.atlas-preview")
        .ambitionPanelAccessibility()
    }
}

struct GoalArchiveSummarySurface: View {
    @Environment(\.ambitionTheme) private var theme

    let summary: GoalPortfolioArchiveSummary

    var body: some View {
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                SectionHeader(title: summary.title, subtitle: summary.subtitle)
                HStack(spacing: theme.spacing.xs) {
                    ForEach(summary.chips) { chip in
                        TagPill(
                            "\(chip.lifecycleState.title) \(chip.count)",
                            icon: chip.lifecycleState.icon,
                            state: chip.count == 0 ? .default : chip.lifecycleState.visualState
                        )
                        .accessibilityLabel("\(chip.count) \(chip.lifecycleState.title.lowercased()) archive goals")
                    }
                }
            }
        }
        .accessibilityIdentifier("goals.archive-summary")
        .ambitionPanelAccessibility()
    }
}

struct GoalSuggestionSurface: View {
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

struct GoalDetailHeroSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let detail: GoalDetailPresentation

    var body: some View {
        ObjectStageHero(state: detail.headline.renderState.visualState, accent: detail.supportModeActive ? theme.colors.accentWarm : nil) {
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

struct GoalDetailFilmstripSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let stages: [GoalPathStage]

    var body: some View {
        GoalDetailSectionSurface(title: "Lifecycle path", subtitle: "Current position, proof, risk, and horizon stay visible before deeper tactics.") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: theme.spacing.sm) {
                    ForEach(stages) { stage in
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            HStack(alignment: .top, spacing: theme.spacing.xs) {
                                Image(systemName: symbol(for: stage))
                                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                    .foregroundStyle(color(for: stage))
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

                            markerRow(for: stage)

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
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(stage.title)
                        .accessibilityValue(stage.accessibilitySummary)
                        .accessibilityHint("Path stage marker. No color is required to understand this state.")
                    }
                }
                .padding(.vertical, 1)
            }
        }
        .accessibilityIdentifier("goal-detail.path-filmstrip")
    }

    @ViewBuilder
    func markerRow(for stage: GoalPathStage) -> some View {
        HStack(spacing: theme.spacing.xs) {
            Label(stage.lifecycleMarkerLabel, systemImage: symbol(for: stage))
                .labelStyle(.titleAndIcon)
            Text(stage.progressShapeLabel)

            if let proof = stage.proofMarkerLabel {
                Label(proof, systemImage: "checkmark.seal")
                    .labelStyle(.titleAndIcon)
            }

            if let risk = stage.riskMarkerLabel {
                Label(risk, systemImage: "exclamationmark.triangle")
                    .labelStyle(.titleAndIcon)
            }

            if let route = stage.routeIndicatorLabel {
                Label(route, systemImage: "arrow.triangle.branch")
                    .labelStyle(.titleAndIcon)
            }
        }
        .font(theme.typography.micro)
        .foregroundStyle(theme.colors.textTertiary)
        .lineLimit(2)
    }

    func color(for stage: GoalPathStage) -> Color {
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

    func symbol(for stage: GoalPathStage) -> String {
        switch stage.position {
        case .completed:
            "checkmark.seal"
        case .current:
            "scope"
        case .blocked:
            "exclamationmark.triangle"
        case .upcoming:
            "arrow.triangle.branch"
        }
    }
}
