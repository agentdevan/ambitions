import AmbitionsDesignSystem
import SwiftUI

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
                    title: "Fixed, flexible, and momentum",
                    subtitle: "These modules interpret the hero instead of competing with it."
                ) {
                    if let planAction = support.planAction {
                        TodayActionChip(action: planAction, handler: onAction)
                    }
                }

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

private struct TodayPrimaryActionButton: View {
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
        let targetID = action.target.goalID ?? action.target.draftID ?? "none"
        return "today.action.\(action.kind.rawValue).\(targetID)"
    }
}

private struct TodayActionAccessibilityHint: ViewModifier {
    let action: TodayInlineAction

    func body(content: Content) -> some View {
        switch action.kind {
        case .askWhyThisMatters:
            content.accessibilityHint("Explains why this step is worth doing now.")
        case .protectLater:
            content.accessibilityHint("Hands this off to the canonical planning surface.")
        default:
            content
        }
    }
}
