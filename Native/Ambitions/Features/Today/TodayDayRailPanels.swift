import AmbitionsDesignSystem
import SwiftUI

/// The Reality Meridian surface for Today - the primary object presenting the daily execution rail.
struct RealityMeridianView: View {
    let state: AmbitionsDayRailViewState
    let onAction: (TodayInlineAction) -> Void
    let onOpenStepDetail: (DayRailStepDetailState) -> Void
    let onShowAnother: (DayRailHeroStepState) -> Void
    let onNotThis: (DayRailHeroStepState) -> Void

    init(
        state: AmbitionsDayRailViewState,
        onAction: @escaping (TodayInlineAction) -> Void,
        onOpenStepDetail: @escaping (DayRailStepDetailState) -> Void = { _ in },
        onShowAnother: @escaping (DayRailHeroStepState) -> Void = { _ in },
        onNotThis: @escaping (DayRailHeroStepState) -> Void = { _ in }
    ) {
        self.state = state
        self.onAction = onAction
        self.onOpenStepDetail = onOpenStepDetail
        self.onShowAnother = onShowAnother
        self.onNotThis = onNotThis
    }

    var body: some View {
        AmbitionsDayRailView(
            state: state,
            onAction: onAction,
            onOpenStepDetail: onOpenStepDetail,
            onShowAnother: onShowAnother,
            onNotThis: onNotThis
        )
    }
}

struct AmbitionsDayRailView: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let state: AmbitionsDayRailViewState
    let onAction: (TodayInlineAction) -> Void
    let onOpenStepDetail: (DayRailStepDetailState) -> Void
    let onShowAnother: (DayRailHeroStepState) -> Void
    let onNotThis: (DayRailHeroStepState) -> Void

    init(
        state: AmbitionsDayRailViewState,
        onAction: @escaping (TodayInlineAction) -> Void,
        onOpenStepDetail: @escaping (DayRailStepDetailState) -> Void = { _ in },
        onShowAnother: @escaping (DayRailHeroStepState) -> Void = { _ in },
        onNotThis: @escaping (DayRailHeroStepState) -> Void = { _ in }
    ) {
        self.state = state
        self.onAction = onAction
        self.onOpenStepDetail = onOpenStepDetail
        self.onShowAnother = onShowAnother
        self.onNotThis = onNotThis
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            if let heroStep = state.heroStep {
                StartHereSurface(
                    step: heroStep,
                    mode: state.mode,
                    privacy: state.privacyProjection,
                    contextLabel: state.contextSummary,
                    onAction: onAction,
                    onOpenStepDetail: onOpenStepDetail,
                    onShowAnother: onShowAnother,
                    onNotThis: onNotThis
                )
            } else {
                DayRailEmptyCard(state: state)
            }

            header
            DayRailRhythmStrip(state: state, semanticState: semanticState)
            MeridianTopologyStrip(state: state, semanticState: semanticState)

            DayRailSection(title: "Now", rows: rows(for: .now), privacy: state.privacyProjection, contextLabel: state.contextSummary, onOpenStepDetail: onOpenStepDetail)
                .accessibilityIdentifier("TodayRealityRailNowSection")
            DayRailSection(title: "Next", rows: rows(for: .next), privacy: state.privacyProjection, contextLabel: state.contextSummary, onOpenStepDetail: onOpenStepDetail)
                .accessibilityIdentifier("TodayRealityRailNextSection")
            DayRailSection(title: "Later", rows: rows(for: .later), privacy: state.privacyProjection, contextLabel: state.contextSummary, onOpenStepDetail: onOpenStepDetail)
                .accessibilityIdentifier("TodayRealityRailLaterSection")

            RealityRailContinuitySpine(state: state.continuity)
                .accessibilityIdentifier("TodayRealityRailContinuitySpine")
        }
        .padding(theme.spacing.lg)
        .background(
            ZStack {
                LivingSurfaceBackground(context: .today, state: livingState, intensity: 0.72)
                RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                    .fill(theme.colors.surfaceSecondary.opacity(0.88))
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(theme.semanticAccent(for: semanticState).opacity(0.26), lineWidth: 1)
        )
        .overlay(alignment: .bottomLeading) {
            PressureGlow(level: pressureLevel, context: .today, label: "Today pressure")
                .padding(.horizontal, theme.spacing.lg)
                .padding(.bottom, theme.spacing.sm)
        }
        .animation(DAVMotionPreset.railProgress.animation(theme: theme, reduceMotion: reduceMotion), value: state.id)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier("TodayRealityRail")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Text(state.dateTitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                AmbitionChip(modeLabel, role: .state, semanticState: semanticState)
                Spacer(minLength: theme.spacing.sm)
            }

            Text(state.contextSummary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            EvidenceLabel(
                modeLabel,
                detail: state.contextSummary,
                source: state.privacyProjection.sourceLabel,
                state: livingState,
                context: .today
            )
        }
    }

    private var modeLabel: String {
        switch state.mode {
        case .normal:
            "Ready"
        case .recovery:
            "Needs review"
        case .protected:
            "Protected"
        case .overloaded:
            "Lighten first"
        case .empty:
            "Open"
        case .noSchedule:
            "Schedule not set"
        }
    }

    private var semanticState: AmbitionSemanticState {
        switch state.mode {
        case .normal:
            .focus
        case .recovery:
            .recovery
        case .protected:
            .protected
        case .overloaded:
            .caution
        case .empty:
            .trust
        case .noSchedule:
            .calendarDerived
        }
    }

    private var livingState: LivingVisualState {
        switch state.mode {
        case .normal:
            .active
        case .recovery:
            .recovery
        case .protected:
            .sensitive
        case .overloaded:
            .pressured
        case .empty:
            .empty
        case .noSchedule:
            .stale
        }
    }

    private var pressureLevel: Double {
        switch state.mode {
        case .normal:
            0.48
        case .recovery:
            0.36
        case .protected:
            0.28
        case .overloaded:
            0.84
        case .empty:
            0.10
        case .noSchedule:
            0.58
        }
    }

    private var accessibilityLabel: String {
        var parts = ["Reality Meridian", state.dateTitle, modeLabel, state.contextSummary]
        if let heroStep = state.heroStep {
            parts.append("Start here")
            parts.append(heroStep.title)
            parts.append(heroStep.duration.label)
            parts.append(heroStep.primaryAction.title)
        } else {
            parts.append("Nothing needs you right now.")
        }
        return parts.joined(separator: ". ")
    }

    private func rows(for slot: DayRailRowSlot) -> [DayRailRowState] {
        state.rows.filter { $0.slot == slot }
    }
}
