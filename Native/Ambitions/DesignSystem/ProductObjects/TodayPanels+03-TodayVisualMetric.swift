import AmbitionsDesignSystem
import SwiftUI

struct TodayVisualMetric: View {
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

struct TodayHeroStepStrip: View {
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

struct TodayHeroAffordanceMenu: View {
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

struct TodayPanelVisual: View {
    @Environment(\.ambitionTheme) private var theme

    let panel: TodayExecutionPanelState

    var body: some View {
        switch panel.kind {
        case .capture:
            dotCluster
        case .time, .todayTime:
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

    var dotCluster: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(0 ..< 5, id: \.self) { index in
                Circle()
                    .fill(index < activeCount ? theme.semanticAccent(for: panel.semanticState) : theme.colors.surfaceOverlay)
                    .frame(width: CGFloat(10 + index * 2), height: CGFloat(10 + index * 2))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var timeRunway: some View {
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

    var balanceStrip: some View {
        HStack(spacing: theme.spacing.xs) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(theme.semanticAccent(for: panel.semanticState))
                .frame(width: activeWidth, height: 14)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
                .frame(height: 14)
        }
    }

    var recoveryStack: some View {
        HStack(alignment: .bottom, spacing: theme.spacing.xs) {
            ForEach(0 ..< 3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(index == 0 ? theme.semanticAccent(for: panel.semanticState) : theme.colors.surfaceOverlay)
                    .frame(width: 34, height: CGFloat(18 + index * 10))
            }
        }
    }

    var waitingIndicator: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(0 ..< 3, id: \.self) { index in
                Capsule()
                    .fill(index == 1 ? theme.semanticAccent(for: panel.semanticState) : theme.colors.surfaceOverlay)
                    .frame(width: 28, height: 8)
            }
        }
    }

    var contextCapsules: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(0 ..< 3, id: \.self) { index in
                Capsule()
                    .fill(index == 0 ? theme.semanticAccent(for: panel.semanticState) : theme.colors.surfaceOverlay)
                    .frame(width: index == 0 ? 46 : 30, height: 10)
            }
        }
    }

    var activeCount: Int {
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

    var activeWidth: CGFloat {
        CGFloat(28 + activeCount * 14)
    }
}

struct TodayWhyDisclosure: View {
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

struct TodayExecutionPanel: View {
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

    var panelBody: some View {
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
    func panelContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        switch panel.kind {
        case .capture:
            CapturePanel(configuration, visualSlot: { TodayPanelVisual(panel: panel) }, contentSlot: content)
        case .time, .todayTime:
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

    var configuration: AmbitionRichPanelConfiguration {
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

extension TodayExecutionPanelState {
    var richKind: AmbitionPanelKind {
        switch kind {
        case .capture:
            .capture
        case .time, .todayTime:
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
