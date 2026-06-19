import AmbitionsDesignSystem
import SwiftUI

struct TodaySupportSection: View {
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

struct TodayTimeApertureSurface: View {
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

struct TodayRecoveryBloomSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayRecoveryBloomState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        ClosureRecoveryPrimitiveStage(
            role: .recovery,
            eyebrow: "Recovery",
            title: state.title,
            subtitle: state.subtitle,
            accessibilityIdentifier: "TodayRecoveryBloomPrimitive"
        ) {
            Text(state.explanation)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                TodayRecoveryProofRow(label: "Pressure field", value: state.pressureFieldLabel, state: .warning)
                TodayRecoveryProofRow(label: "Recovery loop", value: state.recoveryLoopLabel, state: .selected)
                TodayRecoveryProofRow(label: "Smaller step", value: state.smallerStepAnchorLabel, state: .selected)
                TodayRecoveryProofRow(label: "Receipt", value: state.recoveryReceiptPreviewLabel, state: .default)
            }

            ForEach(state.options) { option in
                ClosureRecoveryPrimitiveLine(
                    role: .recovery,
                    title: option.title,
                    subtitle: option.detail,
                    systemImage: "arrow.uturn.backward.circle",
                    accessibilityIdentifier: "TodayRecoveryBloomOption.\(option.id)"
                ) {
                    TodayActionChip(action: option.action, handler: onAction)
                }
            }
        }
    }
}

struct TodayRecoveryProofRow: View {
    @Environment(\.ambitionTheme) private var theme

    let label: String
    let value: String
    let state: AmbitionVisualState

    var body: some View {
        let style = theme.stateStyle(for: state)
        ClosureRecoveryPrimitiveLine(
            role: state == .warning ? .closure : .recovery,
            title: label,
            subtitle: value,
            systemImage: state == .warning ? "exclamationmark.triangle" : "arrow.triangle.2.circlepath"
        ) {
            EmptyView()
        }
        .tint(style.accent)
    }
}

struct TodayStepSessionSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayStepSessionState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            SectionHeader(
                eyebrow: "Step session",
                title: state.title,
                subtitle: state.subtitle
            )
            Text(state.detail)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                stepSessionLine(icon: "scope", title: "Focus", value: state.contextReminderLabel)
                stepSessionLine(icon: "link", title: "Goal", value: state.goalConnectionLabel)
                stepSessionLine(icon: "timer", title: "Timer", value: state.timerLabel)
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("TodayStepSessionContext")

            TodayPrimaryActionButton(action: state.primaryAction, handler: onAction)

            if state.sessionControlActions.isEmpty == false {
                TodayActionGrid(actions: state.sessionControlActions, handler: onAction)
                    .accessibilityIdentifier("TodayStepSessionControls")
            }

            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                stepSessionLine(icon: "checkmark.seal", title: "Receipt", value: state.receiptGenerationLabel)
                stepSessionLine(icon: "arrow.uturn.left", title: "Exit", value: state.exitBoundaryLabel)
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("TodayStepSessionReceiptBoundary")

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

    func stepSessionLine(icon: String, title: String, value: String) -> some View {
        Label {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Text(value)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(theme.colors.accentWarm)
        }
    }
}

struct TodayMomentumStrip: View {
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

extension TodayInlineAction {
    var accessibilityIdentifier: String {
        let targetID = target.goalID ?? target.draftID ?? "none"
        return "today.action.\(kind.rawValue).\(targetID)"
    }
}
