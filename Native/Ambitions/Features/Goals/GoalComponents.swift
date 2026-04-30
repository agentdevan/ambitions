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

struct GoalsPortfolioMaturityCard: View {
    @Environment(\.ambitionTheme) private var theme

    let summary: GoalPortfolioMaturitySummary

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: summary.title, subtitle: summary.subtitle)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: theme.spacing.sm)], spacing: theme.spacing.sm) {
                    maturitySignal(summary.scopeSignal)
                    maturitySignal(summary.stuckWorkSignal)
                    maturitySignal(summary.proofSignal)
                    maturitySignal(summary.nextStepSignal)
                }

                if summary.archiveLearning.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text("Archive learning")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                        ForEach(summary.archiveLearning, id: \.self) { line in
                            Text(line)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(theme.spacing.sm)
                    .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(summary.accessibilityLabel)
        .accessibilityValue(summary.accessibilityValue)
        .accessibilityHint(summary.accessibilityHint)
        .accessibilityIdentifier("goals.portfolio-maturity")
        .ambitionPanelAccessibility()
    }

    @ViewBuilder
    private func maturitySignal(_ signal: GoalPortfolioMaturitySignal) -> some View {
        let style = theme.stateStyle(for: signal.state)
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(signal.title)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
            Text(signal.detail)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(style.fill))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(style.stroke, lineWidth: 1))
    }
}

struct GoalsLifecycleRailCard: View {
    @Environment(\.ambitionTheme) private var theme

    let segments: [GoalLifecycleRailSegment]

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: "Ambition portfolio", subtitle: "Previous, active, and future goals stay oriented without becoming a spreadsheet.")

                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    ForEach(segments) { segment in
                        VStack(alignment: .leading, spacing: theme.spacing.xs) {
                            HStack(spacing: theme.spacing.xs) {
                                Text(segment.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Spacer(minLength: theme.spacing.xs)
                                Text("\(segment.count)")
                                    .font(theme.typography.section)
                                    .foregroundStyle(theme.stateStyle(for: segment.state).accent)
                            }
                            Text(segment.subtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(theme.spacing.sm)
                        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.stateStyle(for: segment.state).stroke, lineWidth: 1))
                    }
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(segments.map { "\($0.title), \($0.count) goals" }.joined(separator: ". "))
        .accessibilityIdentifier("goals.lifecycle-rail")
        .ambitionPanelAccessibility()
    }
}

struct GoalStateChipsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let chips: [GoalStateChipState]

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                SectionHeader(title: "State signals", subtitle: "Kept in view, waiting, blocked, parked, completed, and cancelled remain distinct.")
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 132), spacing: theme.spacing.xs)], alignment: .leading, spacing: theme.spacing.xs) {
                    ForEach(chips) { chip in
                        TagPill(
                            "\(chip.lifecycleState.title) \(chip.count)",
                            icon: chip.lifecycleState.icon,
                            state: chip.count == 0 ? .default : chip.lifecycleState.visualState
                        )
                        .accessibilityLabel("\(chip.count) \(chip.lifecycleState.title.lowercased()) goals")
                    }
                }
            }
        }
        .accessibilityIdentifier("goals.state-chips")
        .ambitionPanelAccessibility()
    }
}

struct GoalsLifeAreasPanel: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalsLifeAreasOverviewState
    let zoomMode: GoalsSemanticZoomMode
    let onZoomModeChange: (GoalsSemanticZoomMode) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)

                SegmentedFilterBar(
                    items: state.availableZoomModes,
                    selection: Binding(
                        get: { zoomMode },
                        set: onZoomModeChange
                    )
                ) { $0.title }
                .accessibilityIdentifier("goals.semantic-zoom-mode")
                .accessibilityLabel("Life Areas view")
                .accessibilityHint("Switches between map and list presentations.")

                if state.items.isEmpty {
                    EmptyStateCard(
                        title: state.emptyTitle,
                        message: state.emptyMessage,
                        icon: "square.grid.2x2"
                    )
                } else if zoomMode == .map {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 172), spacing: theme.spacing.sm)], alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(state.items) { item in
                            LifeAreaMapTile(item: item)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(state.items) { item in
                            LifeAreaListRow(item: item)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.accessibilityLabel)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityHint(state.accessibilityHint)
        .accessibilityIdentifier("goals.life-areas-panel")
        .ambitionPanelAccessibility()
    }
}

private struct LifeAreaMapTile: View {
    @Environment(\.ambitionTheme) private var theme

    let item: GoalsLifeAreaItemState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.xs) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(2)
                }
                Spacer(minLength: theme.spacing.xs)
                TagPill(item.nextFocus, state: item.state)
                    .lineLimit(2)
            }

            HStack(spacing: theme.spacing.xs) {
                countPill(title: "Goals", count: item.activeGoalCount, state: item.state)
                countPill(title: "North Stars", count: item.northStarCount, state: item.northStarCount > 0 ? .selected : .default)
                countPill(title: "One-Step", count: item.oneStepGoalCount, state: item.oneStepGoalCount > 0 ? .selected : .default)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.stateStyle(for: item.state).stroke, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityValue(item.accessibilityValue)
        .accessibilityHint(item.accessibilityHint)
    }

    @ViewBuilder
    private func countPill(title: String, count: Int, state: AmbitionVisualState) -> some View {
        TagPill("\(title) \(count)", state: count == 0 ? .default : state)
            .accessibilityLabel("\(count) \(title)")
    }
}

private struct LifeAreaListRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: GoalsLifeAreaItemState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.nextFocus)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                Spacer()
                TagPill(item.subtitle, state: item.state)
            }

            if item.goalReferences.isEmpty == false {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    ForEach(item.goalReferences) { goal in
                        HStack(alignment: .top, spacing: theme.spacing.xs) {
                            Image(systemName: "scope")
                                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                .foregroundStyle(theme.stateStyle(for: goal.state).accent)
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(goal.title)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(goal.subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityValue(item.accessibilityValue)
        .accessibilityHint(item.accessibilityHint)
    }
}

struct GoalsNorthStarsRailCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalsNorthStarsRailState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)

                if state.items.isEmpty {
                    EmptyStateCard(
                        title: state.emptyTitle,
                        message: state.emptyMessage,
                        icon: "north.star"
                    )
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            ForEach(state.items) { item in
                                NorthStarRailItem(item: item)
                                    .frame(width: 240)
                            }
                        }
                        .padding(.vertical, 1)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.accessibilityLabel)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityHint(state.accessibilityHint)
        .accessibilityIdentifier("goals.north-stars-rail")
        .ambitionPanelAccessibility()
    }
}

private struct NorthStarRailItem: View {
    @Environment(\.ambitionTheme) private var theme

    let item: GoalsNorthStarRailItemState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .top, spacing: theme.spacing.xs) {
                Image(systemName: "north.star")
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.stateStyle(for: item.state).accent)
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.lifeAreaLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }

            Text(item.subtitle)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(3)

            HStack(spacing: theme.spacing.xs) {
                TagPill(item.postureLabel, state: item.state)
                TagPill(item.readinessLabel, state: item.canBeShaped ? .selected : .default)
            }

            Text(item.canBeShaped ? item.shapeIntoGoalLabel : item.suggestedNextAction)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.stateStyle(for: item.state).stroke, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityValue(item.accessibilityValue)
        .accessibilityHint(item.accessibilityHint)
    }
}

struct GoalsOneStepGoalsPanel: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalsOneStepGoalsPanelState
    let onPromote: (GoalsOneStepGoalPanelItemState) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)

                if state.items.isEmpty {
                    EmptyStateCard(
                        title: state.emptyTitle,
                        message: state.emptyMessage,
                        icon: "checkmark.circle"
                    )
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(state.items) { item in
                            OneStepGoalPanelRow(item: item, onPromote: onPromote)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(state.accessibilityLabel)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityHint(state.accessibilityHint)
        .accessibilityIdentifier("goals.one-step-goals-panel")
        .ambitionPanelAccessibility()
    }
}

private struct OneStepGoalPanelRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: GoalsOneStepGoalPanelItemState
    let onPromote: (GoalsOneStepGoalPanelItemState) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(item.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(item.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: theme.spacing.xxxs) {
                    TagPill(item.statusLabel, state: item.state)
                    Text(item.areaLabel)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }

            HStack(alignment: .center, spacing: theme.spacing.xs) {
                if let timingLabel = item.timingLabel {
                    TagPill(timingLabel, icon: "calendar", state: item.state)
                }
                TagPill(item.suggestedNextAction, state: item.state)
                Spacer(minLength: theme.spacing.xs)
                if item.canPromoteToGoal {
                    Button {
                        onPromote(item)
                    } label: {
                        Label(item.promoteLabel, systemImage: "arrow.up.right.circle")
                            .font(theme.typography.caption)
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .selected))
                    .accessibilityHint("Opens goal creation. No Goal is created automatically.")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.stateStyle(for: item.state).stroke, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityValue(item.accessibilityValue)
        .accessibilityHint(item.accessibilityHint)
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
                        TagPill(card.lifecycleState.title, icon: card.lifecycleState.icon, state: card.lifecycleState.visualState)
                        TagPill(card.weather.title, icon: card.weather.icon, state: card.weather.visualState)
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
                    Text(card.modeLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                    Text(card.timingLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text("Next visible step")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(card.nextVisibleStep.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                if card.nextVisibleStep.detail.isEmpty == false {
                    Text(card.nextVisibleStep.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.spacing.sm)
            .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceSecondary.opacity(0.7)))

            HStack(alignment: .top, spacing: theme.spacing.sm) {
                signalColumn(title: "Proof", headline: card.proofSummary.title, body: card.proofSummary.detail, state: card.proofSummary.visualState)
                signalColumn(title: "Weather", headline: card.weather.title, body: card.weatherSummary, state: card.weather.visualState)
            }

            signalColumn(title: "Momentum", headline: card.momentumIntegrity.title, body: card.momentumIntegrity.detail, state: card.momentumIntegrity.visualState)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
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
        .accessibilityLabel("\(card.title). State \(card.lifecycleState.title). Weather \(card.weather.title), \(card.weatherSummary). Next visible step, \(card.nextVisibleStep.title). Proof, \(card.proofSummary.title). Momentum, \(card.momentumIntegrity.title).")
        .ambitionPanelAccessibility()
    }

    @ViewBuilder
    private func signalColumn(title: String, headline: String, body: String, state: AmbitionVisualState) -> some View {
        let style = theme.stateStyle(for: state)
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
            Text(headline)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
            Text(body)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(style.fill))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(style.stroke, lineWidth: 1))
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

struct GoalAtlasPreviewCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalAtlasPreviewState

    var body: some View {
        AppCard {
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
        .accessibilityLabel("Goal Atlas preview. \(state.groups.map { "\($0.title), \($0.items.count) visible goals" }.joined(separator: ". "))")
        .accessibilityIdentifier("goals.atlas-preview")
        .ambitionPanelAccessibility()
    }
}

struct GoalArchiveSummaryCard: View {
    @Environment(\.ambitionTheme) private var theme

    let summary: GoalPortfolioArchiveSummary

    var body: some View {
        AppCard {
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
        GoalDetailSectionCard(title: "What matters next", subtitle: "One step first, before the rest of the path.") {
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
