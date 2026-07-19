import AmbitionsDesignSystem
import SwiftUI

struct TodayExecutionHeroPanel: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayExecutionViewState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        HeroDecisionPanel(
            AmbitionRichPanelConfiguration(
                kind: .heroDecision,
                eyebrow: state.hero.eyebrow,
                title: state.hero.title,
                subtitle: state.hero.subtitle,
                icon: state.hero.kind == .recovery ? "arrow.uturn.backward.circle.fill" : "scope",
                semanticState: state.hero.semanticState,
                confidenceLabel: state.hero.confidenceLabel,
                accessibilityLabel: state.hero.accessibilityLabel,
                accessibilityHint: "Shows the clearest answer to what to do now.",
                accessibilityValue: state.hero.accessibilityValue
            )
        ) {
            TodayDayStateHeader(state: state)
        } contentSlot: {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                TodayLensRibbon(state: state)
                    .accessibilityIdentifier("today.context-lens")

                TodayContractGrid(entries: [
                    state.protectedMustDo,
                    state.recommendedStep,
                    state.notToday,
                    state.recoveryFallback,
                    state.whyThisMatters,
                    state.actionClosureEntry,
                ], onAction: onAction)
                .accessibilityIdentifier("today.daily-contract")

                TodayPlanLayerStrip(state: state.todayTimeLayer, onAction: onAction)
                    .accessibilityIdentifier("today.plan-layer")

                TodayOneStepGoalsStrip(state: state.oneStepGoalsPanel, onAction: onAction)
                    .accessibilityIdentifier("today.one-step-goals")

                TodayPrimaryActionButton(action: state.hero.primaryAction, handler: onAction)
                    .accessibilityIdentifier("today.hero.primary-action")

                if let saveTheDayAction = state.saveTheDayAction {
                    TodaySaveTheDayStrip(action: saveTheDayAction, onAction: onAction)
                        .accessibilityIdentifier("today.save-the-day")
                }
            }
        }
        .accessibilityIdentifier("today.hero-card")
    }
}

struct TodayExecutionSupportPanels: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayExecutionViewState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        if state.supportingPanels.isEmpty { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                ForEach(state.supportingPanels) { panel in
                    TodayExecutionPanel(panel: panel, onAction: onAction)
                        .accessibilityIdentifier(accessibilityID(for: panel))
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("today.support-panels")
        )
    }

    func accessibilityID(for panel: TodayExecutionPanelState) -> String {
        switch panel.kind {
        case .contextLens:
            "today.support.outside-lens"
        case .capture:
            "today.support.capture-pressure"
        case .time:
            "today.support.time-guidance"
        case .todayTime:
            "today.support.today-time"
        case .oneStepGoals:
            "today.support.one-step-goals"
        case .priority:
            "today.support.priority"
        case .recovery:
            "today.support.recovery"
        case .waiting:
            "today.support.waiting"
        case .friction:
            "today.support.friction"
        case .closure:
            "today.support.closure"
        }
    }
}

struct TodayExecutionDeepDive: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayExecutionViewState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        if state.deeperSections.isEmpty { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                ForEach(Array(state.deeperSections.enumerated()), id: \.element.id) { _, section in
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        SectionHeader(
                            eyebrow: "Detail",
                            title: section.title,
                            subtitle: section.rows.first?.subtitle ?? "More detail"
                        )
                        ForEach(Array(section.rows.enumerated()), id: \.element.id) { _, panel in
                            TodayExecutionPanel(panel: panel, compact: true, onAction: onAction)
                        }
                    }
                    .padding(theme.spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                            .fill(theme.colors.surfaceSecondary)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                            .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                    )
                }
            }
            .accessibilityIdentifier("today.deep-dive")
        )
    }
}

struct TodayPlanLayerStrip: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayTimeLayerState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.semanticAccent(for: .calendarDerived))
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(theme.semanticStyle(for: .calendarDerived).fill))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                        Text(state.title)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                        AmbitionChip(state.calendarSourceLabel, role: .state, semanticState: .calendarDerived)
                    }
                    Text(state.subtitle)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(state.compactTimelineLabel) · \(state.openWindowLabel)")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("today.compact-timeline")
                }
                Spacer(minLength: theme.spacing.sm)
            }

            if state.items.isEmpty {
                Text("No fixed plan yet")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    ForEach(state.items.prefix(2)) { item in
                        TodayPlanLayerItemRow(item: item, onAction: onAction)
                    }
                }
            }

            HStack(spacing: theme.spacing.xs) {
                TodayTinyActionButton(action: state.moveAction, onAction: onAction)
                TodayTinyActionButton(action: state.parkAction, onAction: onAction)
                if let markDoneAction = state.markDoneAction {
                    TodayTinyActionButton(action: markDoneAction, onAction: onAction)
                }
            }
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.74))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.semanticAccent(for: .calendarDerived).opacity(0.18), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(state.accessibilityLabel)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityHint(state.accessibilityHint)
    }
}

struct TodayPlanLayerItemRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: TodayTimeLayerItemState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        Group {
            if let action = item.action {
                Button {
                    onAction(action)
                } label: {
                    rowBody
                }
                .buttonStyle(.plain)
                .modifier(TodayActionAccessibilityHint(action: action))
            } else {
                rowBody
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
        .accessibilityValue("\(item.timingLabel). \(item.sourceLabel). \(item.subtitle)")
    }

    var rowBody: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
            Text(item.timingLabel)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
                .frame(minWidth: 52, alignment: .leading)
            Text(item.title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(1)
            Spacer(minLength: theme.spacing.xs)
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
        }
    }
}

struct TodayOneStepGoalsStrip: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayOneStepGoalsPanelState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(theme.semanticAccent(for: .focus))
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(theme.semanticStyle(for: .focus).fill))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                        Text(state.title)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                        AmbitionChip(state.value, role: .state, semanticState: state.previews.isEmpty ? .trust : .focus)
                    }
                    Text(state.subtitle)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: theme.spacing.sm)
            }

            if state.previews.isEmpty {
                Text(state.emptyMessage)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    ForEach(state.previews.prefix(2)) { preview in
                        TodayOneStepGoalRow(preview: preview, onAction: onAction)
                    }
                }
            }
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.74))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.semanticAccent(for: state.previews.isEmpty ? .trust : .focus).opacity(0.16), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(state.accessibilityLabel)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityHint(state.accessibilityHint)
    }
}

struct TodayOneStepGoalRow: View {
    @Environment(\.ambitionTheme) private var theme

    let preview: TodayOneStepGoalPreviewState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        Group {
            if let action = preview.action {
                Button {
                    onAction(action)
                } label: {
                    rowBody
                }
                .buttonStyle(.plain)
                .modifier(TodayActionAccessibilityHint(action: action))
            } else {
                rowBody
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(preview.title)
        .accessibilityValue("\(preview.statusLabel). \(preview.subtitle)")
    }

    var rowBody: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
            AmbitionChip(preview.statusLabel, role: .state, semanticState: preview.semanticState)
            Text(preview.title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(1)
            Spacer(minLength: theme.spacing.xs)
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
        }
    }
}
