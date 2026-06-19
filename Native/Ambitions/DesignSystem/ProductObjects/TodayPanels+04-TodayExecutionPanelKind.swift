import AmbitionsDesignSystem
import SwiftUI

extension TodayExecutionPanelKind {
    var eyebrow: String {
        switch self {
        case .contextLens: "Lens"
        case .capture: "Capture"
        case .time: "Time"
        case .todayTime: "Today Time"
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
        case .time: "calendar.badge.clock"
        case .todayTime: "calendar"
        case .oneStepGoals: "checkmark.circle.fill"
        case .priority: "scope"
        case .recovery: "arrow.uturn.backward.circle.fill"
        case .waiting: "hourglass"
        case .friction: "waveform.path.ecg"
        case .closure: "tray.full.fill"
        }
    }
}

struct TodayHeroSurface: View {
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

    var accentColor: Color {
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

struct TodaySupportSurface: View {
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
                    if let timeAction = support.timeAction {
                        TodayActionChip(action: timeAction, handler: onAction)
                    }
                }

                if let stepSession = support.stepSession {
                    TodayStepSessionSurface(state: stepSession, onAction: onAction)
                        .accessibilityIdentifier("today.support.step-session")
                }

                if let recoveryBloom = support.recoveryBloom {
                    TodayRecoveryBloomSurface(state: recoveryBloom, onAction: onAction)
                        .accessibilityIdentifier("today.support.recovery-bloom")
                }

                TodayTimeApertureSurface(state: support.timeAperture, onAction: onAction)
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

struct TodayLowerLaneSurface: View {
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

struct TodayMessageSurface: View {
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

struct TodayHeroLane: View {
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
