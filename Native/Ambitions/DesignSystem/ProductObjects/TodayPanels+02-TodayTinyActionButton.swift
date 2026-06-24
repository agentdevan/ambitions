import AmbitionsDesignSystem
import SwiftUI

struct TodayTinyActionButton: View {
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
        .accessibilityLabel(action.title)
        .accessibilityIdentifier(action.accessibilityIdentifier)
        .modifier(TodayActionAccessibilityHint(action: action))
    }
}

struct TodayDayStateHeader: View {
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

struct TodayContractGrid: View {
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

struct TodayContractRow: View {
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

    var rowBody: some View {
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

    var icon: String {
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

struct TodaySaveTheDayStrip: View {
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

struct TodayLensRibbon: View {
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

struct TodayHeroVisual: View {
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

    var heroProgress: Double {
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

struct TodayMiniRunway: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayExecutionViewState

    var body: some View {
        HStack(spacing: theme.spacing.xs) {
            runwaySegment("Now", active: true)
            runwaySegment("Next", active: state.supportingPanels.isEmpty == false)
            runwaySegment(state.hero.kind == .recovery ? "Recover" : "Later", active: state.hero.kind == .recovery)
        }
    }

    func runwaySegment(_ label: String, active: Bool) -> some View {
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
