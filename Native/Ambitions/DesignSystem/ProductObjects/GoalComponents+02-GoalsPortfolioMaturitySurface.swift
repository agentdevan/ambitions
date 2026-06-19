import AmbitionsDesignSystem
import SwiftUI

struct GoalsPortfolioMaturitySurface: View {
    @Environment(\.ambitionTheme) private var theme

    let summary: GoalPortfolioMaturitySummary

    var body: some View {
        ObjectStageSurface {
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
    func maturitySignal(_ signal: GoalPortfolioMaturitySignal) -> some View {
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

struct GoalsLifecycleRailSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let segments: [GoalLifecycleRailSegment]

    var body: some View {
        ObjectStageSurface {
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

struct GoalStateChipsSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let chips: [GoalStateChipState]

    var body: some View {
        ObjectStageSurface {
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
        ObjectStageSurface {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: state.title, subtitle: state.subtitle)
                Text(state.equalWeightSummary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("goals.life-areas.equal-weight-summary")

                if state.controls.isEmpty == false {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: theme.spacing.xs) {
                            ForEach(state.controls) { control in
                                Label(control.title, systemImage: control.systemImage)
                                    .font(theme.typography.caption.weight(.semibold))
                                    .foregroundStyle(theme.colors.textPrimary)
                                    .padding(.horizontal, theme.spacing.sm)
                                    .padding(.vertical, theme.spacing.xs)
                                    .background(
                                        Capsule(style: .continuous)
                                            .fill(theme.colors.surfaceOverlay.opacity(0.54))
                                    )
                                    .overlay(
                                        Capsule(style: .continuous)
                                            .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                                    )
                                    .accessibilityHint(control.accessibilityHint)
                                    .accessibilityIdentifier("goals.life-areas.control.\(control.id)")
                            }
                        }
                        .padding(.vertical, 1)
                    }
                    .accessibilityIdentifier("goals.life-areas.controls")
                }

                SegmentedFilterBar(
                    items: state.availableZoomModes,
                    selection: Binding(
                        get: { zoomMode },
                        set: { newZoomMode in
                            onZoomModeChange(newZoomMode)
                        }
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

struct LifeAreaMapTile: View {
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
    func countPill(title: String, count: Int, state: AmbitionVisualState) -> some View {
        TagPill("\(title) \(count)", state: count == 0 ? .default : state)
            .accessibilityLabel("\(count) \(title)")
    }
}

struct LifeAreaListRow: View {
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

struct GoalsNorthStarsRailSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: GoalsNorthStarsRailState

    var body: some View {
        ObjectStageSurface {
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
