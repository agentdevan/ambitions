import AmbitionsDesignSystem
import SwiftUI

struct TodayHeaderCard: View {
    @Environment(\.ambitionTheme) private var theme

    let header: TodayHeaderState

    var body: some View {
        HeroCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(header.greeting)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.accentWarm)
                    Text(header.title)
                        .font(theme.typography.hero)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(header.subtitle)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: theme.spacing.xs) {
                        ForEach(header.contextPills) { pill in
                            TagPill(pill.title, icon: pill.icon, state: pill.state)
                        }
                    }
                }
            }
        }
        .ambitionPanelAccessibility()
    }
}

struct TodayMessageCard: View {
    @Environment(\.ambitionTheme) private var theme

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
        }
        .ambitionPanelAccessibility()
        .accessibilityLabel("\(message.title). \(message.body)")
        .transition(.ambitionPanel)
    }
}

struct TodayRitualCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayRitualLoopState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        AppCard(state: visualState) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(eyebrow: "1. Ritual Loop", title: state.title, subtitle: state.subtitle) {
                    TagPill(state.stateLabel, state: visualState)
                }

                Text(state.thesis)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)

                if state.signalLabels.isEmpty == false {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: theme.spacing.xs) {
                            ForEach(state.signalLabels, id: \.self) { label in
                                TagPill(label, state: .default)
                            }
                        }
                    }
                }

                if let action = state.action {
                    TodayActionChip(action: action, handler: onAction)
                }
            }
        }
        .ambitionPanelAccessibility()
    }

    private var visualState: AmbitionVisualState {
        switch state.kind {
        case .middayReset:
            return state.stateLabel == "Reset needed" ? .warning : .selected
        case .eveningClose:
            return state.stateLabel == "Progress landed" ? .success : .default
        case .morningSetup, .weeklyReset:
            return .selected
        }
    }
}

struct TodayDailyTargetsCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayDailyTargetsState
    let expanded: Bool
    let toggleExpanded: () -> Void
    let onAction: (TodayInlineAction) -> Void

    private var visibleItems: [TodayTargetItem] {
        expanded ? state.items : Array(state.items.prefix(2))
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(eyebrow: "2. Daily Targets", title: state.title, subtitle: state.subtitle) {
                    Button(action: toggleExpanded) {
                        Label(expanded ? "Collapse" : "Expand", systemImage: expanded ? "chevron.up" : "chevron.down")
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                }

                TagPill(state.completionLabel, state: .selected)

                if let emptyMessage = state.emptyMessage, state.items.isEmpty {
                    Text(emptyMessage)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                } else {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        ForEach(visibleItems) { item in
                            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                                HStack(alignment: .top, spacing: theme.spacing.sm) {
                                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                        Text(item.title)
                                            .font(theme.typography.bodyEmphasized)
                                        Text(item.subtitle)
                                            .font(theme.typography.caption)
                                            .foregroundStyle(theme.colors.textSecondary)
                                    }
                                    Spacer()
                                    TagPill(item.statusLabel, state: item.state)
                                }

                                ProgressRail(title: item.timingLabel, progress: item.progress, trailingValue: "\(Int(item.progress * 100))%", state: item.state)

                                if let shellSummary = item.shellSummary {
                                    GoalShellSummaryCompactView(summary: shellSummary)
                                }

                                HStack(spacing: theme.spacing.xs) {
                                    if let action = item.primaryAction {
                                        TodayActionChip(action: action, handler: onAction)
                                    }
                                    if let action = item.secondaryAction {
                                        TodayActionChip(action: action, handler: onAction)
                                    }
                                }
                            }
                            .padding(theme.spacing.sm)
                            .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                            .overlay(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
                            .ambitionPanelAccessibility()
                            .transition(.ambitionPanel)
                        }
                    }
                }
            }
        }
        .ambitionPanelAccessibility()
    }
}

struct TodayFocusCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayFocusState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        switch state {
        case let .planned(value):
            HeroCard(state: .selected, accent: theme.colors.accentWarm) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    SectionHeader(eyebrow: "3. Focus Now", title: value.title, subtitle: value.subtitle) {
                        TagPill(value.timingLabel, state: .selected)
                    }
                    ProgressRail(title: value.energyLabel, progress: value.progress, trailingValue: "\(Int(value.progress * 100))%", state: .selected, accent: theme.colors.accentWarm)
                    Text(value.reason)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                    if let shellSummary = value.shellSummary {
                        GoalShellSummaryCompactView(summary: shellSummary)
                    }
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        ForEach(value.supportingText, id: \.self) { text in
                            Label(text, systemImage: "sparkle")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                    TodayActionGrid(actions: value.actions, handler: onAction)
                }
            }
            .ambitionPanelAccessibility()
        case let .starter(value):
            HeroCard(state: .selected, accent: theme.colors.accentWarm) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    SectionHeader(eyebrow: "3. Focus Now", title: value.title, subtitle: value.subtitle) {
                        TagPill("Starter plan", state: .selected)
                    }
                    Text(value.reassurance)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                    TagPill(value.timingLabel, state: .default)
                    if let shellSummary = value.shellSummary {
                        GoalShellSummaryCompactView(summary: shellSummary)
                    }
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        ForEach(value.assumptions, id: \.self) { assumption in
                            Label(assumption, systemImage: "leaf.fill")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                    TodayActionGrid(actions: value.actions, handler: onAction)
                }
            }
            .ambitionPanelAccessibility()
        case let .clarification(value):
            HeroCard(state: .warning, accent: theme.colors.warning) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    SectionHeader(eyebrow: "3. Focus Now", title: value.title, subtitle: value.subtitle) {
                        TagPill("Clarification", icon: "questionmark.circle", state: .warning)
                    }
                    ForEach(value.questions) { question in
                        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                            Text(question.prompt)
                                .font(theme.typography.bodyEmphasized)
                            Text(question.rationale)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                            Text("Safe default: \(question.gentleDefault)")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textTertiary)
                        }
                        .padding(theme.spacing.sm)
                        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                    }
                    TodayActionGrid(actions: value.actions, handler: onAction)
                }
            }
            .ambitionPanelAccessibility()
        case let .blocked(value):
            HeroCard(state: .warning, accent: theme.colors.warning) {
                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    SectionHeader(eyebrow: "3. Focus Now", title: value.title, subtitle: value.subtitle) {
                        TagPill("Blocked", icon: "exclamationmark.triangle", state: .warning)
                    }
                    Text(value.blockerSummary)
                        .font(theme.typography.bodyEmphasized)
                    Text(value.nextBestAction)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                    TodayActionGrid(actions: value.actions, handler: onAction)
                }
            }
            .ambitionPanelAccessibility()
        case let .empty(value):
            EmptyStateCard(title: value.title, message: value.message, icon: "moon.zzz")
        }
    }
}

struct TodayFreeTimeCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayFreeTimeState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(eyebrow: "4. Free Time Opportunities", title: state.title, subtitle: state.subtitle)
                if state.opportunities.isEmpty {
                    Text("Free space is allowed to stay free.")
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                } else {
                    ForEach(state.opportunities) { opportunity in
                        HStack(alignment: .top, spacing: theme.spacing.md) {
                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(opportunity.title)
                                    .font(theme.typography.bodyEmphasized)
                                Text(opportunity.subtitle)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                TagPill(opportunity.timingLabel, state: opportunity.state)
                            }
                            Spacer()
                            if let action = opportunity.action {
                                TodayActionChip(action: action, handler: onAction)
                            }
                        }
                        .padding(theme.spacing.sm)
                        .background(RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous).fill(theme.colors.surfaceOverlay))
                    }
                }
            }
        }
        .ambitionPanelAccessibility()
    }
}

struct TodayMilestoneCard: View {
    let state: TodayMilestoneState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        AppCard(state: .success) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(eyebrow: "5. Milestone Prompt", title: state.title, subtitle: state.subtitle) {
                    TagPill(state.confidenceLabel, state: .success)
                }
                Text(state.prompt)
                    .font(.body.weight(.semibold))
                if let shellSummary = state.shellSummary {
                    GoalShellSummaryCompactView(summary: shellSummary)
                }
                if let action = state.action {
                    TodayActionChip(action: action, handler: onAction)
                }
            }
        }
        .ambitionPanelAccessibility()
    }
}

struct TodayMomentumCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayMomentumState

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(eyebrow: "6. Momentum / Progress Summary", title: state.title, subtitle: state.subtitle)
                if state.metrics.isEmpty {
                    Text(state.note)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: theme.spacing.sm) {
                        ForEach(state.metrics) { metric in
                            StatTile(title: metric.title, value: metric.value, detail: metric.detail, icon: metric.icon, state: metric.state)
                        }
                    }
                    Text(state.note)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
        }
        .ambitionPanelAccessibility()
    }
}

struct TodayCelebrationCard: View {
    let state: TodayCelebrationState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        HeroCard(state: .celebration) {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(eyebrow: "7. Celebration", title: state.title, subtitle: state.subtitle) {
                    TagPill("Earned", icon: "sparkles", state: .celebration)
                }
                CelebrationBanner(title: state.title, subtitle: state.subtitle)
                ForEach(state.achievements, id: \.self) { achievement in
                    Label(achievement, systemImage: "checkmark.circle.fill")
                        .font(.body)
                }
                TodayActionGrid(actions: state.actions, handler: onAction)
            }
        }
        .ambitionPanelAccessibility()
        .transition(.ambitionPanel)
    }
}

struct TodayQuickCaptureCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayQuickCaptureState
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(eyebrow: "8. Quick Capture / Ask For Help", title: state.title, subtitle: state.subtitle)
                Text(state.prompt)
                    .font(.body)
                    .foregroundStyle(.secondary)
                Text(state.helpText)
                    .font(.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                TodayActionGrid(actions: state.actions, handler: onAction)
            }
        }
        .ambitionPanelAccessibility()
    }
}

struct TodayReflectionCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: TodayReflectionState
    let expanded: Bool
    let toggleExpanded: () -> Void
    let onAction: (TodayInlineAction) -> Void

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(eyebrow: "9. End-of-Day Reflection", title: state.title, subtitle: state.subtitle) {
                    Button(action: toggleExpanded) {
                        Label(expanded ? "Less" : "More", systemImage: expanded ? "chevron.up" : "chevron.down")
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                }
                Text(state.prompt)
                    .font(theme.typography.bodyEmphasized)
                if expanded, state.highlights.isEmpty == false {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        ForEach(state.highlights, id: \.self) { highlight in
                            Label(highlight, systemImage: "moon.stars.fill")
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                    .transition(.ambitionPanel)
                }
                TodayActionGrid(actions: state.actions, handler: onAction)
            }
        }
        .ambitionPanelAccessibility()
    }
}

struct TodayActionGrid: View {
    @Environment(\.ambitionTheme) private var theme

    let actions: [TodayInlineAction]
    let handler: (TodayInlineAction) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 128), spacing: theme.spacing.xs)], spacing: theme.spacing.xs) {
            ForEach(actions) { action in
                TodayActionChip(action: action, handler: handler)
            }
        }
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
        .modifier(TodayActionAccessibilityHint(action: action))
    }
}

private struct TodayActionAccessibilityHint: ViewModifier {
    let action: TodayInlineAction

    func body(content: Content) -> some View {
        if action.kind == .askWhyThisMatters {
            content.accessibilityHint("Explains why this step is worth doing now.")
        } else {
            content
        }
    }
}
