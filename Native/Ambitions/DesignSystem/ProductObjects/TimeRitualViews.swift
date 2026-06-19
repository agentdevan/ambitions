import AmbitionsDesignSystem
import SwiftUI

struct TimeRitualsHeroView: View {
    @Environment(\.ambitionTheme) private var theme

    let dashboard: TimeRitualsDashboard

    var body: some View {
        HeroCard(state: heroState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text("Rituals")
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(dashboard.title)
                        .font(theme.typography.hero)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(dashboard.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text(dashboard.summaryLabel)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(dashboard.summaryDetail)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.sm) {
                        ForEach(dashboard.stats) { metric in
                            TimeRitualMetricChip(metric: metric)
                        }
                    }
                }
            }
        }
        .ambitionPanelAccessibility()
    }

    private var heroState: AmbitionVisualState {
        switch dashboard.mode {
        case .recovery: .warning
        case .seeded: .selected
        case .active: .success
        case .empty: .default
        }
    }
}

private struct TimeRitualMetricChip: View {
    @Environment(\.ambitionTheme) private var theme

    let metric: MetricSummary

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Label(metric.title, systemImage: metric.icon)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
            Text(metric.value)
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)
            if let detail = metric.detail {
                Text(detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .frame(width: 144, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }
}

struct TimeRitualRowView: View {
    @Environment(\.ambitionTheme) private var theme

    let ritual: TimeRitualSummary
    let onAction: (TimeRitualActionState) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    HStack(spacing: theme.spacing.xs) {
                        TagPill(ritual.status.title, state: ritual.status.visualState)
                        TagPill(ritual.cadenceLabel, state: .default)
                    }

                    Text(ritual.title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)

                    Text(ritual.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
                Image(systemName: iconName)
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.stateStyle(for: ritual.status.visualState).accent)
            }

            ProgressRail(
                title: ritual.progressLabel,
                progress: ritual.progress,
                trailingValue: ritual.rhythmLabel,
                state: ritual.status.visualState
            )

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(ritual.note)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(ritual.consistencyLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                if let supportLabel = ritual.supportLabel {
                    Text(supportLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }

            if let minimumVersionLabel = ritual.minimumVersionLabel {
                TimeRitualMinimumVersionSurface(text: minimumVersionLabel, state: ritual.status)
            }

            TimeRitualActionGrid(actions: ritual.actions, onAction: onAction)
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .ambitionPanelAccessibility()
    }

    private var iconName: String {
        switch ritual.status {
        case .completed: "checkmark.circle.fill"
        case .minimumDone: "leaf.circle.fill"
        case .recovery: "arrow.uturn.backward.circle.fill"
        case .needsEasierVersion: "scissors"
        case .notRelevant: "nosign"
        case .supportive: "person.2.fill"
        case .delayed: "clock.arrow.circlepath"
        case .skipped: "forward.fill"
        case .partial: "waveform.path.ecg"
        case .ready: "repeat"
        }
    }
}

private struct TimeRitualMinimumVersionSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let text: String
    let state: TimeRitualState

    var body: some View {
        let style = theme.stateStyle(for: state.visualState)

        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text("Minimum version")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
            Text(text)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textPrimary)
        }
        .padding(theme.spacing.sm)
        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(style.fill.opacity(0.45)))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(style.stroke.opacity(0.6), lineWidth: 1))
    }
}

struct TimeRitualActionGrid: View {
    @Environment(\.ambitionTheme) private var theme

    let actions: [TimeRitualActionState]
    let onAction: (TimeRitualActionState) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 136), spacing: theme.spacing.xs)], spacing: theme.spacing.xs) {
            ForEach(actions) { action in
                Button {
                    onAction(action)
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

struct TimeRitualRecoveryView: View {
    @Environment(\.ambitionTheme) private var theme

    let momentum: TimeRitualMomentumSummary

    var body: some View {
        ClosureRecoveryPrimitiveStage(
            role: .recovery,
            title: "Recovery summary",
            subtitle: "Gentler ritual restart stays visible without a generic card shell.",
            accessibilityIdentifier: "rituals.recovery-summary"
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(title: momentum.title, subtitle: momentum.subtitle)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.sm) {
                        ForEach(momentum.stats) { metric in
                            TimeRitualMetricChip(metric: metric)
                        }
                    }
                }

                Text(momentum.recoveryNote)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .ambitionPanelAccessibility()
    }
}
