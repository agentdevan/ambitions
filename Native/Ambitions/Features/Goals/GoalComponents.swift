import AmbitionsDesignSystem
import SwiftUI

struct GoalsHeroCard: View {
    @Environment(\.ambitionTheme) private var theme

    let overview: GoalsOverview

    var body: some View {
        HeroCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text("Roadmap")
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(overview.title)
                        .font(theme.typography.hero)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(overview.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(overview.contextPills, id: \.self) { pill in
                            TagPill(pill, state: pill.contains("need care") ? .warning : (pill.contains("Seeded") ? .celebration : .selected))
                        }
                    }
                }
            }
        }
    }
}

struct GoalRowCard: View {
    @Environment(\.ambitionTheme) private var theme

    let item: GoalListItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    HStack(spacing: theme.spacing.xs) {
                        TagPill(item.modeLabel, state: item.renderState.visualState)
                        TagPill(item.statusLabel, state: item.renderState.visualState)
                    }

                    Text(item.title)
                        .font(theme.typography.section)
                        .foregroundStyle(theme.colors.textPrimary)

                    Text(item.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
                Image(systemName: icon(for: item.mode))
                    .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.stateStyle(for: item.renderState.visualState).accent)
            }

            ProgressRail(
                title: item.progressLabel,
                progress: item.progressValue,
                trailingValue: "\(Int(item.progressValue * 100))%",
                state: item.renderState.visualState
            )

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(item.nextStepHint)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(item.timingLabel)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                if let supportLabel = item.supportLabel {
                    Text(supportLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
    }

    private func icon(for mode: GoalMode) -> String {
        switch mode {
        case .achievement: "flag.checkered.2.crossed"
        case .project: "square.stack.3d.up"
        case .habit: "repeat"
        case .learning: "book.pages"
        case .exploration: "sparkle.magnifyingglass"
        case .maintenance: "wrench.and.screwdriver"
        case .recovery: "leaf"
        case .delegatedSupport: "person.2.fill"
        }
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
    }
}
