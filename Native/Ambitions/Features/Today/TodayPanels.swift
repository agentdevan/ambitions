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

                TodayPlanLayerStrip(state: state.todayPlanLayer, onAction: onAction)
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
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            ForEach(state.supportingPanels) { panel in
                TodayExecutionPanel(panel: panel, onAction: onAction)
                    .accessibilityIdentifier(accessibilityID(for: panel))
            }
        }
        .accessibilityIdentifier("today.support-card")
    }

    private func accessibilityID(for panel: TodayExecutionPanelState) -> String {
        switch panel.kind {
        case .contextLens:
            "today.support.outside-lens"
        case .capture:
            "today.support.capture-pressure"
        case .plan:
            "today.support.plan-guidance"
        case .todayPlan:
            "today.support.today-plan"
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
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            ForEach(state.deeperSections) { section in
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    SectionHeader(
                        eyebrow: "Detail",
                        title: section.title,
                        subtitle: "Available when needed."
                    )
                    ForEach(section.rows) { panel in
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
    }
}

private struct TodayPlanLayerStrip: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayPlanLayerState
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

private struct TodayPlanLayerItemRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: TodayPlanLayerItemState
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

    private var rowBody: some View {
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

private struct TodayOneStepGoalsStrip: View {
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

private struct TodayOneStepGoalRow: View {
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

    private var rowBody: some View {
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

private struct TodayTinyActionButton: View {
    @Environment(\.ambitionTheme) private var theme

    let action: TodayInlineAction
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        Button {
            onAction(action)
        } label: {
            Label(action.title, systemImage: action.systemImage)
                .font(theme.typography.caption)
                .lineLimit(1)
                .labelStyle(.titleAndIcon)
                .padding(.horizontal, theme.spacing.sm)
                .padding(.vertical, theme.spacing.xs)
                .background(
                    Capsule()
                        .fill(theme.stateStyle(for: action.state).fill)
                )
                .overlay(
                    Capsule()
                        .stroke(theme.stateStyle(for: action.state).stroke, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .foregroundStyle(theme.colors.textPrimary)
        .modifier(TodayActionAccessibilityHint(action: action))
    }
}

private struct TodayDayStateHeader: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayExecutionViewState

    var body: some View {
        HStack(alignment: .center, spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(theme.semanticStyle(for: state.hero.semanticState).fill)
                Circle()
                    .stroke(theme.semanticAccent(for: state.hero.semanticState).opacity(0.32), lineWidth: 2)
                Image(systemName: state.hero.semanticState.icon)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(theme.semanticAccent(for: state.hero.semanticState))
            }
            .frame(width: 76, height: 76)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                AmbitionChip(state.dayState.rawValue, role: .state, semanticState: state.hero.semanticState)
                    .accessibilityIdentifier("today.ambient-state")
                Text(state.dayStateSummary)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("One agreement for the day.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
            Spacer(minLength: theme.spacing.sm)
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.78))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.semanticAccent(for: state.hero.semanticState).opacity(0.24), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Day state")
        .accessibilityValue("\(state.dayState.rawValue). \(state.dayStateSummary)")
    }
}

private struct TodayContractGrid: View {
    @Environment(\.ambitionTheme) private var theme

    let entries: [TodayContractEntryState]
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            ForEach(entries) { entry in
                TodayContractRow(entry: entry, onAction: onAction)
                    .accessibilityIdentifier("today.contract.\(entry.kind.rawValue)")
            }
        }
    }
}

private struct TodayContractRow: View {
    @Environment(\.ambitionTheme) private var theme

    let entry: TodayContractEntryState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        Group {
            if let action = entry.action {
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
        .accessibilityLabel(entry.title)
        .accessibilityValue("\(entry.subtitle). \(entry.value)")
    }

    private var rowBody: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(theme.semanticAccent(for: entry.semanticState))
                .frame(width: 30, height: 30)
                .background(Circle().fill(theme.semanticStyle(for: entry.semanticState).fill))

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                    Text(entry.title)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                    AmbitionChip(entry.value, role: .state, semanticState: entry.semanticState)
                }
                Text(entry.subtitle)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.xs)
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.74))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.semanticAccent(for: entry.semanticState).opacity(0.16), lineWidth: 1)
        )
    }

    private var icon: String {
        switch entry.kind {
        case .protectedMustDo:
            "lock.shield.fill"
        case .recommendedStep:
            "scope"
        case .notToday:
            "pause.circle.fill"
        case .recoveryFallback:
            "arrow.uturn.backward.circle.fill"
        case .whyThisMatters:
            "questionmark.circle.fill"
        case .actionClosure:
            "tray.full.fill"
        }
    }
}

private struct TodaySaveTheDayStrip: View {
    @Environment(\.ambitionTheme) private var theme

    let action: TodayInlineAction
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        Button {
            onAction(action)
        } label: {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "arrow.uturn.backward.circle.fill")
                    .foregroundStyle(theme.semanticAccent(for: .recovery))
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text("Save the day")
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text("Choose one calmer recovery path. Nothing reschedules silently.")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: theme.spacing.sm)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)
            }
            .padding(theme.spacing.md)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(theme.semanticStyle(for: .recovery).fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(theme.semanticStyle(for: .recovery).stroke, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Save the day")
        .accessibilityHint("Opens the safest recovery path without changing the plan silently.")
        .modifier(TodayActionAccessibilityHint(action: action))
    }
}

private struct TodayLensRibbon: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayExecutionViewState

    var body: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            Image(systemName: state.activeLens.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(theme.semanticAccent(for: state.hero.semanticState))
                .frame(width: 36, height: 36)
                .background(Circle().fill(theme.semanticStyle(for: state.hero.semanticState).fill))
                .overlay(Circle().stroke(theme.semanticStyle(for: state.hero.semanticState).stroke, lineWidth: 1))

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("Lens")
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(state.activeLens.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .accessibilityIdentifier("today.context-lens.active")
                Text(state.lensSummary)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: theme.spacing.sm)

            HStack(spacing: -6) {
                ForEach(state.availableLenses.prefix(4)) { lens in
                    Circle()
                        .fill(lens.isActive ? theme.semanticAccent(for: state.hero.semanticState) : theme.colors.surfaceSecondary)
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(theme.colors.strokeSubtle, lineWidth: 1))
                }
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.semanticAccent(for: state.hero.semanticState).opacity(0.22), lineWidth: 1)
        )
    }
}

private struct TodayHeroVisual: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayExecutionViewState

    var body: some View {
        HStack(alignment: .center, spacing: theme.spacing.md) {
            ZStack {
                Circle()
                    .fill(theme.semanticStyle(for: state.hero.semanticState).fill)
                    .frame(width: 112, height: 112)
                Circle()
                    .stroke(theme.semanticAccent(for: state.hero.semanticState).opacity(0.32), lineWidth: 10)
                    .frame(width: 92, height: 92)
                Circle()
                    .trim(from: 0, to: heroProgress)
                    .stroke(
                        theme.semanticAccent(for: state.hero.semanticState),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 92, height: 92)
                Image(systemName: state.hero.kind == .recovery ? "arrow.uturn.backward" : state.activeLens.icon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(theme.colors.textPrimary)
            }

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                TodayVisualMetric(label: "Now", value: state.activeLens.title, state: state.hero.semanticState)
                TodayMiniRunway(state: state)
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.78))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.semanticAccent(for: state.hero.semanticState).opacity(0.24), lineWidth: 1)
        )
    }

    private var heroProgress: Double {
        switch state.hero.semanticState {
        case .focus, .success, .confidenceHigh:
            0.82
        case .protected, .confidenceMedium, .calendarDerived:
            0.64
        case .recovery, .caution, .risk, .confidenceLow:
            0.42
        case .capture, .waiting:
            0.54
        case .trust, .review, .accessibilityVerified, .accessibilityUnverified, .neutral:
            0.70
        }
    }
}

private struct TodayMiniRunway: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayExecutionViewState

    var body: some View {
        HStack(spacing: theme.spacing.xs) {
            runwaySegment("Now", active: true)
            runwaySegment("Next", active: state.supportingPanels.isEmpty == false)
            runwaySegment(state.hero.kind == .recovery ? "Recover" : "Later", active: state.hero.kind == .recovery)
        }
    }

    private func runwaySegment(_ label: String, active: Bool) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Capsule()
                .fill(active ? theme.semanticAccent(for: state.hero.semanticState) : theme.colors.surfaceOverlay)
                .frame(width: active ? 46 : 28, height: 6)
            Text(label)
                .font(theme.typography.micro)
                .foregroundStyle(active ? theme.colors.textPrimary : theme.colors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct TodayVisualMetric: View {
    @Environment(\.ambitionTheme) private var theme

    let label: String
    let value: String
    let state: AmbitionSemanticState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(label.uppercased())
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
            Text(value)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(1)
            Capsule()
                .fill(theme.semanticAccent(for: state).opacity(0.72))
                .frame(width: 72, height: 5)
        }
    }
}

private struct TodayHeroStepStrip: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let value: String
    let state: AmbitionSemanticState

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "arrow.forward.circle.fill")
                .foregroundStyle(theme.semanticAccent(for: state))
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(value)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(2)
            }
            Spacer(minLength: theme.spacing.sm)
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.82))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.semanticAccent(for: state).opacity(0.18), lineWidth: 1)
        )
    }
}

private struct TodayHeroAffordanceMenu: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayExecutionHeroState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        Menu {
            if let explanation = state.explanation {
                Text(explanation.summary)
            }
            ForEach(state.secondaryActions) { action in
                Button {
                    onAction(action)
                } label: {
                    Label(action.title, systemImage: action.systemImage)
                }
            }
        } label: {
            Label(state.explanation?.title ?? "More", systemImage: "questionmark.circle")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .accessibilityIdentifier("today.hero.more")
    }
}

private struct TodayPanelVisual: View {
    @Environment(\.ambitionTheme) private var theme

    let panel: TodayExecutionPanelState

    var body: some View {
        switch panel.kind {
        case .capture:
            dotCluster
        case .plan, .todayPlan:
            timeRunway
        case .oneStepGoals:
            balanceStrip
        case .priority:
            balanceStrip
        case .recovery:
            recoveryStack
        case .waiting:
            waitingIndicator
        case .contextLens, .friction, .closure:
            contextCapsules
        }
    }

    private var dotCluster: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(0 ..< 5, id: \.self) { index in
                Circle()
                    .fill(index < activeCount ? theme.semanticAccent(for: panel.semanticState) : theme.colors.surfaceOverlay)
                    .frame(width: CGFloat(10 + index * 2), height: CGFloat(10 + index * 2))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var timeRunway: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(spacing: theme.spacing.xs) {
                ForEach(0 ..< 4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(index < activeCount ? theme.semanticAccent(for: panel.semanticState) : theme.colors.surfaceOverlay)
                        .frame(height: index == 0 ? 18 : 12)
                }
            }
            Text("now / next / later")
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
        }
    }

    private var balanceStrip: some View {
        HStack(spacing: theme.spacing.xs) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(theme.semanticAccent(for: panel.semanticState))
                .frame(width: activeWidth, height: 14)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
                .frame(height: 14)
        }
    }

    private var recoveryStack: some View {
        HStack(alignment: .bottom, spacing: theme.spacing.xs) {
            ForEach(0 ..< 3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(index == 0 ? theme.semanticAccent(for: panel.semanticState) : theme.colors.surfaceOverlay)
                    .frame(width: 34, height: CGFloat(18 + index * 10))
            }
        }
    }

    private var waitingIndicator: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(0 ..< 3, id: \.self) { index in
                Capsule()
                    .fill(index == 1 ? theme.semanticAccent(for: panel.semanticState) : theme.colors.surfaceOverlay)
                    .frame(width: 28, height: 8)
            }
        }
    }

    private var contextCapsules: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(0 ..< 3, id: \.self) { index in
                Capsule()
                    .fill(index == 0 ? theme.semanticAccent(for: panel.semanticState) : theme.colors.surfaceOverlay)
                    .frame(width: index == 0 ? 46 : 30, height: 10)
            }
        }
    }

    private var activeCount: Int {
        if panel.value.localizedCaseInsensitiveContains("critical") || panel.value.localizedCaseInsensitiveContains("high") {
            return 5
        }
        if panel.value.localizedCaseInsensitiveContains("elevated") || panel.value.localizedCaseInsensitiveContains("moderate") {
            return 3
        }
        if panel.value.localizedCaseInsensitiveContains("no ") {
            return 1
        }
        return max(1, min(5, Int(String(panel.value.filter(\.isNumber).prefix(1))) ?? 2))
    }

    private var activeWidth: CGFloat {
        CGFloat(28 + activeCount * 14)
    }
}

private struct TodayWhyDisclosure: View {
    @Environment(\.ambitionTheme) private var theme

    let explanation: TodayExplanationAffordanceState

    var body: some View {
        DisclosureGroup {
            Text(explanation.summary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        } label: {
            Label(explanation.title, systemImage: "questionmark.circle")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .tint(theme.colors.textSecondary)
    }
}

private struct TodayExecutionPanel: View {
    @Environment(\.ambitionTheme) private var theme

    let panel: TodayExecutionPanelState
    var compact = false
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        Group {
            if let action = panel.action {
                Button {
                    onAction(action)
                } label: {
                    panelBody
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(action.accessibilityIdentifier)
                .modifier(TodayActionAccessibilityHint(action: action))
            } else {
                panelBody
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(panel.title). \(panel.subtitle)")
        .accessibilityValue(panel.value)
    }

    private var panelBody: some View {
        panelContainer {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                        Text(panel.title)
                            .font(compact ? theme.typography.bodyEmphasized : theme.typography.titleCompact)
                            .foregroundStyle(theme.colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(panel.subtitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .lineLimit(compact ? 2 : 1)
                    }
                    Spacer(minLength: theme.spacing.sm)
                    AmbitionChip(panel.value, role: .state, semanticState: panel.semanticState)
                }

                if let explanation = panel.explanation {
                    TodayWhyDisclosure(explanation: explanation)
                        .accessibilityIdentifier("today.explanation.\(panel.id)")
                }

                if panel.action != nil {
                    HStack(spacing: theme.spacing.xs) {
                        Text("Open")
                            .font(theme.typography.caption)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(theme.semanticAccent(for: panel.semanticState))
                }
            }
        }
    }

    @ViewBuilder
    private func panelContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        switch panel.kind {
        case .capture:
            CapturePanel(configuration, visualSlot: { TodayPanelVisual(panel: panel) }, contentSlot: content)
        case .plan, .todayPlan:
            SchedulePanel(configuration, visualSlot: { TodayPanelVisual(panel: panel) }, contentSlot: content)
        case .oneStepGoals:
            ProgressPanel(configuration, visualSlot: { TodayPanelVisual(panel: panel) }, contentSlot: content)
        case .recovery:
            RecoveryPanel(configuration, visualSlot: { TodayPanelVisual(panel: panel) }, contentSlot: content)
        case .priority:
            ProgressPanel(configuration, visualSlot: { TodayPanelVisual(panel: panel) }, contentSlot: content)
        case .waiting, .contextLens, .friction:
            InsightPanel(configuration, visualSlot: { TodayPanelVisual(panel: panel) }, contentSlot: content)
        case .closure:
            ReviewPanel(configuration, visualSlot: { TodayPanelVisual(panel: panel) }, contentSlot: content)
        }
    }

    private var configuration: AmbitionRichPanelConfiguration {
        AmbitionRichPanelConfiguration(
            kind: panel.richKind,
            eyebrow: panel.kind.eyebrow,
            title: panel.title,
            subtitle: nil,
            icon: panel.kind.icon,
            semanticState: panel.semanticState,
            accessibilityLabel: panel.title,
            accessibilityValue: panel.value
        )
    }
}

private extension TodayExecutionPanelState {
    var richKind: AmbitionPanelKind {
        switch kind {
        case .capture:
            .capture
        case .plan, .todayPlan:
            .schedule
        case .priority, .oneStepGoals:
            .progress
        case .recovery:
            .recovery
        case .waiting, .contextLens, .friction:
            .insight
        case .closure:
            .review
        }
    }
}

private extension TodayExecutionPanelKind {
    var eyebrow: String {
        switch self {
        case .contextLens: "Lens"
        case .capture: "Capture"
        case .plan: "Plan"
        case .todayPlan: "Today Plan"
        case .oneStepGoals: "One-Step Goals"
        case .priority: "Priority"
        case .recovery: "Recovery"
        case .waiting: "Waiting"
        case .friction: "Friction"
        case .closure: "Closure"
        }
    }

    var icon: String {
        switch self {
        case .contextLens: "viewfinder"
        case .capture: "tray.and.arrow.down.fill"
        case .plan: "calendar.badge.clock"
        case .todayPlan: "calendar"
        case .oneStepGoals: "checkmark.circle.fill"
        case .priority: "scope"
        case .recovery: "arrow.uturn.backward.circle.fill"
        case .waiting: "hourglass"
        case .friction: "waveform.path.ecg"
        case .closure: "tray.full.fill"
        }
    }
}

struct TodayHeroCard: View {
    @Environment(\.ambitionTheme) private var theme

    let hero: TodayHeroState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        HeroCard(state: hero.truth.posture.visualState, accent: accentColor) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(hero.truth.greeting)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)

                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                        Text(hero.truth.dominantText)
                            .font(theme.typography.hero)
                            .foregroundStyle(theme.colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: theme.spacing.sm)

                        TagPill(hero.truth.posture.label, state: hero.truth.posture.visualState)
                    }

                    Text(hero.truth.supportingText)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let reentry = hero.reentry {
                    AppCard(state: reentry.state) {
                        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                            Text(reentry.eyebrow.uppercased())
                                .font(theme.typography.micro)
                                .foregroundStyle(theme.colors.textTertiary)
                            Text(reentry.title)
                                .font(theme.typography.bodyEmphasized)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(reentry.detail)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        .padding(theme.spacing.sm)
                        .accessibilityElement(children: .combine)
                        .accessibilityIdentifier("today.hero.reentry")
                    }
                }

                if hero.truth.contextPills.isEmpty == false {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: theme.spacing.xs) {
                            ForEach(hero.truth.contextPills) { pill in
                                TagPill(pill.title, icon: pill.icon, state: pill.state)
                            }
                        }
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    TodayHeroLane(
                        eyebrow: "Now",
                        title: hero.truth.nowTitle,
                        subtitle: hero.truth.nowSubtitle
                    )
                    .accessibilityIdentifier("today.hero.now")

                    if let nextTitle = hero.truth.nextTitle, let nextSubtitle = hero.truth.nextSubtitle {
                        TodayHeroLane(
                            eyebrow: "Next",
                            title: nextTitle,
                            subtitle: nextSubtitle
                        )
                        .accessibilityIdentifier("today.hero.next")
                    }
                }

                if let whisper = hero.truth.trustWhisper {
                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                        Image(systemName: "sparkle.magnifyingglass")
                            .foregroundStyle(theme.colors.textSecondary)
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(whisper.title)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(whisper.detail)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                    .padding(theme.spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .fill(theme.colors.surfaceOverlay)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                    )
                    .accessibilityIdentifier("today.hero.trust-whisper")
                }

                if let shellSummary = hero.truth.shellSummary {
                    GoalShellSummaryCompactView(summary: shellSummary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text(hero.primaryAction.title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(hero.primaryAction.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                    TodayPrimaryActionButton(action: hero.primaryAction.action, handler: onAction)
                        .accessibilityIdentifier("today.hero.primary-action")
                    if hero.primaryAction.supportingActions.isEmpty == false {
                        TodayActionGrid(actions: hero.primaryAction.supportingActions, handler: onAction)
                    }
                }
            }
            .padding(theme.spacing.sm)
        }
        .ambitionPanelAccessibility()
        .accessibilityIdentifier("today.hero-card")
    }

    private var accentColor: Color {
        switch hero.truth.posture {
        case .stable:
            return theme.colors.accentWarm
        case .tight, .recovering:
            return theme.colors.accentWarm
        case .drifted, .overloaded, .lowData, .noPlan:
            return theme.colors.warning
        }
    }
}

struct TodaySupportCard: View {
    @Environment(\.ambitionTheme) private var theme

    let support: TodaySupportLayerState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                SectionHeader(
                    eyebrow: "Support",
                    title: "Time, recovery, and momentum",
                    subtitle: "These systems deepen the hero instead of competing with it."
                ) {
                    if let planAction = support.planAction {
                        TodayActionChip(action: planAction, handler: onAction)
                    }
                }

                if let stepSession = support.stepSession {
                    TodayStepSessionCard(state: stepSession, onAction: onAction)
                        .accessibilityIdentifier("today.support.step-session")
                }

                if let recoveryBloom = support.recoveryBloom {
                    TodayRecoveryBloomCard(state: recoveryBloom, onAction: onAction)
                        .accessibilityIdentifier("today.support.recovery-bloom")
                }

                TodayTimeApertureCard(state: support.timeAperture, onAction: onAction)
                    .accessibilityIdentifier("today.support.time-aperture")

                TodaySupportSection(
                    eyebrow: "Fixed commitments",
                    title: support.fixedCommitments.title,
                    subtitle: support.fixedCommitments.summary,
                    items: support.fixedCommitments.items,
                    emptyMessage: support.fixedCommitments.emptyMessage,
                    onAction: onAction
                )
                .accessibilityIdentifier("today.support.fixed")

                TodaySupportSection(
                    eyebrow: "Flexible room",
                    title: support.flexibleRoom.title,
                    subtitle: support.flexibleRoom.summary,
                    items: support.flexibleRoom.items,
                    emptyMessage: support.flexibleRoom.emptyMessage,
                    onAction: onAction
                )
                .accessibilityIdentifier("today.support.flexible")

                TodayMomentumStrip(state: support.momentum)
                    .accessibilityIdentifier("today.support.momentum")
            }
            .padding(theme.spacing.lg)
        }
        .ambitionPanelAccessibility()
        .accessibilityIdentifier("today.support-card")
    }
}

struct TodayLowerLaneCard: View {
    @Environment(\.ambitionTheme) private var theme

    let support: TodaySupportLayerState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Re-entry",
                    title: support.quickCaptureTitle,
                    subtitle: support.quickCaptureDetail
                )

                if let quickCaptureAction = support.quickCaptureAction {
                    TodayActionChip(action: quickCaptureAction, handler: onAction)
                }

                if let reflectionPrompt = support.reflectionPrompt {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(reflectionPrompt)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)

                        if support.reflectionHighlights.isEmpty == false {
                            ForEach(support.reflectionHighlights.prefix(2), id: \.self) { highlight in
                                Label(highlight, systemImage: "moon.stars.fill")
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                            }
                        }
                    }
                }
            }
            .padding(theme.spacing.lg)
        }
        .ambitionPanelAccessibility()
        .accessibilityIdentifier("today.lower-lane-card")
    }
}

struct TodayMessageCard: View {
    let message: TodayInlineMessage

    var body: some View {
        AppCard(state: message.state) {
            VStack(alignment: .leading, spacing: 10) {
                Text(message.title)
                    .font(.headline.weight(.semibold))
                Text(message.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .ambitionPanelAccessibility()
        .accessibilityLabel("\(message.title). \(message.body)")
        .transition(.ambitionPanel)
        .accessibilityIdentifier("today.inline-message")
    }
}

private struct TodayHeroLane: View {
    @Environment(\.ambitionTheme) private var theme

    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(eyebrow.uppercased())
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textTertiary)
            Text(title)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text(subtitle)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
    }
}

private struct TodaySupportSection: View {
    @Environment(\.ambitionTheme) private var theme

    let eyebrow: String
    let title: String
    let subtitle: String
    let items: [TodaySupportItemState]
    let emptyMessage: String?
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(eyebrow: eyebrow, title: title, subtitle: subtitle)
            if items.isEmpty {
                Text(emptyMessage ?? "Nothing additional needs attention here.")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
            } else {
                ForEach(items.prefix(2)) { item in
                    HStack(alignment: .top, spacing: theme.spacing.md) {
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text(item.title)
                                .font(theme.typography.bodyEmphasized)
                            Text(item.subtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                            TagPill(item.label, state: item.state)
                        }
                        Spacer()
                        if let action = item.action {
                            TodayActionChip(action: action, handler: onAction)
                        }
                    }
                    .padding(theme.spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .fill(theme.colors.surfaceOverlay)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                    )
                }
            }
        }
    }
}

private struct TodayTimeApertureCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayTimeApertureState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            SectionHeader(
                eyebrow: "Open time",
                title: state.title,
                subtitle: state.subtitle
            )

            HStack(alignment: .top, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(state.pressure.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(state.pressure.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
                Spacer(minLength: theme.spacing.sm)
                TagPill(state.pressure.label, state: state.pressure.state)
            }

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                Text("Best use of remaining time")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(state.bestUseTitle)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(state.bestUseDetail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                if let action = state.bestUseAction {
                    TodayActionChip(action: action, handler: onAction)
                }
            }
            .padding(theme.spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(theme.colors.surfaceOverlay)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(theme.colors.strokeSubtle, lineWidth: 1)
            )

            if state.windows.isEmpty {
                Text(state.emptyMessage ?? "No additional open window needs to be filled.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            } else {
                ForEach(state.windows) { window in
                    HStack(alignment: .top, spacing: theme.spacing.md) {
                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            HStack(spacing: theme.spacing.xs) {
                                Text(window.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                TagPill(window.timingLabel, state: window.state)
                            }
                            Text(window.subtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                        Spacer(minLength: theme.spacing.sm)
                        if let action = window.action {
                            TodayActionChip(action: action, handler: onAction)
                        }
                    }
                    .padding(theme.spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .fill(theme.colors.surfaceOverlay)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                            .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                    )
                }
            }

            if let whisper = state.trustWhisper {
                Label {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(whisper.title)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(whisper.detail)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                } icon: {
                    Image(systemName: "sparkle.magnifyingglass")
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .padding(theme.spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .fill(theme.colors.surfaceOverlay)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                )
            }
        }
    }
}

private struct TodayRecoveryBloomCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayRecoveryBloomState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            SectionHeader(
                eyebrow: "Recovery",
                title: state.title,
                subtitle: state.subtitle
            )

            Text(state.explanation)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)

            ForEach(state.options) { option in
                HStack(alignment: .top, spacing: theme.spacing.md) {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(option.title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(option.detail)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    Spacer(minLength: theme.spacing.sm)
                    TodayActionChip(action: option.action, handler: onAction)
                }
                .padding(theme.spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .fill(theme.colors.surfaceOverlay)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                )
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
    }
}

private struct TodayStepSessionCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayStepSessionState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            SectionHeader(
                eyebrow: "Step Session",
                title: state.title,
                subtitle: state.subtitle
            )
            Text(state.detail)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)

            TodayPrimaryActionButton(action: state.primaryAction, handler: onAction)

            if state.secondaryActions.isEmpty == false {
                TodayActionGrid(actions: state.secondaryActions, handler: onAction)
            }

            if let whisper = state.trustWhisper {
                Label {
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text(whisper.title)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(whisper.detail)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                } icon: {
                    Image(systemName: "scope")
                        .foregroundStyle(theme.colors.accentWarm)
                }
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
}

private struct TodayMomentumStrip: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayMomentumStripState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            SectionHeader(eyebrow: "Momentum", title: state.title, subtitle: state.summary)
            if state.metrics.isEmpty == false {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: theme.spacing.sm) {
                    ForEach(state.metrics) { metric in
                        StatTile(title: metric.title, value: metric.value, detail: metric.detail, icon: metric.icon, state: metric.state)
                    }
                }
            }
            if let celebrationLine = state.celebrationLine {
                Text(celebrationLine)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textPrimary)
            }
            Text(state.note)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
    }
}

struct TodayActionGrid: View {
    @Environment(\.ambitionTheme) private var theme

    let actions: [TodayInlineAction]
    let handler: (TodayInlineAction) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 124), spacing: theme.spacing.xs)], spacing: theme.spacing.xs) {
            ForEach(actions) { action in
                TodayActionChip(action: action, handler: handler)
            }
        }
    }
}

private extension TodayInlineAction {
    var accessibilityIdentifier: String {
        let targetID = target.goalID ?? target.draftID ?? "none"
        return "today.action.\(kind.rawValue).\(targetID)"
    }
}

struct TodayPrimaryActionButton: View {
    let action: TodayInlineAction
    let handler: (TodayInlineAction) -> Void

    var body: some View {
        Button {
            handler(action)
        } label: {
            Label(action.title, systemImage: action.systemImage)
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: action.state))
        .accessibilityLabel(action.title)
        .accessibilityIdentifier(accessibilityIdentifier)
        .modifier(TodayActionAccessibilityHint(action: action))
    }

    private var accessibilityIdentifier: String {
        let targetID = action.target.goalID ?? action.target.draftID ?? "none"
        return "today.hero.primary-action.\(action.kind.rawValue).\(targetID)"
    }
}

struct TodayActionChip: View {
    let action: TodayInlineAction
    let handler: (TodayInlineAction) -> Void

    var body: some View {
        Button {
            handler(action)
        } label: {
            Label(action.title, systemImage: action.systemImage)
                .font(.caption.weight(.semibold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 44)
                .padding(.vertical, 10)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: action.state))
        .accessibilityIdentifier(accessibilityIdentifier)
        .modifier(TodayActionAccessibilityHint(action: action))
    }

    private var accessibilityIdentifier: String {
        action.accessibilityIdentifier
    }
}

private struct TodayActionAccessibilityHint: ViewModifier {
    let action: TodayInlineAction

    func body(content: Content) -> some View {
        switch action.kind {
        case .startStepSession:
            content.accessibilityHint("Starts a bounded Step Session for this one step.")
        case .askWhyThisMatters:
            content.accessibilityHint("Explains why this step is worth doing now.")
        case .protectLater:
            content.accessibilityHint("Hands this off to the canonical planning surface.")
        default:
            content
        }
    }
}
