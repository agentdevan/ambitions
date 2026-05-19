import AmbitionsDesignSystem
import SwiftUI

/// The Reality Meridian surface for Today — the primary object presenting the daily execution rail.
/// Previously named `DayTimelineRail`; renamed to match product canon.
struct RealityMeridianView: View {
    let state: AmbitionsDayRailViewState
    let onAction: (TodayInlineAction) -> Void
    let onOpenStepDetail: (DayRailStepDetailState) -> Void

    init(
        state: AmbitionsDayRailViewState,
        onAction: @escaping (TodayInlineAction) -> Void,
        onOpenStepDetail: @escaping (DayRailStepDetailState) -> Void = { _ in }
    ) {
        self.state = state
        self.onAction = onAction
        self.onOpenStepDetail = onOpenStepDetail
    }

    var body: some View {
        AmbitionsDayRailView(
            state: state,
            onAction: onAction,
            onOpenStepDetail: onOpenStepDetail
        )
    }
}


struct AmbitionsDayRailView: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let state: AmbitionsDayRailViewState
    let onAction: (TodayInlineAction) -> Void
    let onOpenStepDetail: (DayRailStepDetailState) -> Void

    init(
        state: AmbitionsDayRailViewState,
        onAction: @escaping (TodayInlineAction) -> Void,
        onOpenStepDetail: @escaping (DayRailStepDetailState) -> Void = { _ in }
    ) {
        self.state = state
        self.onAction = onAction
        self.onOpenStepDetail = onOpenStepDetail
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            if let heroStep = state.heroStep {
                StartHereSurface(
                    step: heroStep,
                    privacy: state.privacyProjection,
                    contextLabel: state.contextSummary,
                    onAction: onAction,
                    onOpenStepDetail: onOpenStepDetail
                )
                    .accessibilityIdentifier("TodayRealityRailHero")
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

    private func sourceLabel(_ label: DayRailSourceLabelState) -> String {
        switch label.source {
        case .sensitive, .privateUserText:
            state.privacyProjection.sourceLabel
        case .calendarDerived:
            "Calendar-derived"
        case .standard, .syncMetadata:
            label.label
        }
    }

    private func sourceSemanticState(_ label: DayRailSourceLabelState) -> AmbitionSemanticState {
        switch label.source {
        case .sensitive, .privateUserText:
            .protected
        case .calendarDerived:
            .calendarDerived
        case .standard, .syncMetadata:
            .trust
        }
    }
}

private struct StartHereSurface: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let step: DayRailHeroStepState
    let privacy: DayRailPrivacyProjectionState
    let contextLabel: String
    let onAction: (TodayInlineAction) -> Void
    let onOpenStepDetail: (DayRailStepDetailState) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            Button {
                onOpenStepDetail(step.stepDetail(privacy: privacy, contextLabel: contextLabel))
            } label: {
                HStack(alignment: .top, spacing: theme.spacing.md) {
                    DayRailNode(kind: .recommended, active: true)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        Text("Start here")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .accessibilityIdentifier("TodayRealityRailStartHereTitle")

                        Text(step.title)
                            .font(theme.typography.titleCompact)
                            .foregroundStyle(theme.colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(step.subtitle)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(step.becauseLine)
                            .font(theme.typography.bodySecondary)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .accessibilityIdentifier("TodayStartHereBecauseLine")

                        sourceAndFit

                        startHereFacts
                    }
                    Spacer(minLength: theme.spacing.sm)
                }
            }
            .buttonStyle(.plain)

            ReceiptDrawer(
                title: "Receipt seam",
                subtitle: "What will stay reviewable after action.",
                sections: [
                    ReceiptDrawerSection(
                        id: "start-here",
                        title: "Start Here",
                        subtitle: privacy.isSensitiveProjection ? "Private details stay hidden." : "Source, change, and correction path stay attached.",
                        items: [step.receiptItem]
                    )
                ]
            )
            .accessibilityIdentifier("TodayStartHereReceiptDrawer")

            actionRow
        }
        .padding(theme.spacing.md)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: theme.radius.sm,
                bottomLeadingRadius: theme.radius.sm,
                bottomTrailingRadius: theme.radius.lg,
                topTrailingRadius: theme.radius.lg,
                style: .continuous
            )
            .fill(theme.colors.surfaceOverlay.opacity(0.95))
        )
        .overlay(
            HStack(spacing: 0) {
                Rectangle()
                    .fill(theme.colors.accentWarm.opacity(0.86))
                    .frame(width: 3)
                    .accessibilityHidden(true)
                Spacer(minLength: 0)
            }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue(accessibilityValue)
        .accessibilityHint("Opens Step Detail. Start now opens Step Session. The receipt seam explains what will stay reviewable.")
        .accessibilityIdentifier(privacy.isSensitiveProjection ? "TodayRealityRailPrivateItem" : "TodayStartHereSurface")
        .transition(DAVMotionPreset.heroExpansion.transition(reduceMotion: reduceMotion))
    }

    @ViewBuilder
    private var sourceAndFit: some View {
        let stacksVertically = dynamicTypeSize.isAccessibilitySize
        if stacksVertically {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                sourceAndFitContent
            }
        } else {
            HStack(spacing: theme.spacing.xs) {
                sourceAndFitContent
            }
        }
    }

    @ViewBuilder
    private var sourceAndFitContent: some View {
        AmbitionChip(step.duration.label, role: .time, semanticState: .calendarDerived)
        AmbitionChip(step.fitLabel, role: .state, semanticState: .focus)
        AmbitionChip(step.sourceQualityLabel, role: .state, semanticState: .trust)
    }

    private var startHereFacts: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            StartHereFactRow(
                icon: "point.topleft.down.curvedto.point.bottomright.up",
                title: step.contextEdge.title,
                value: step.contextEdge.summary,
                detail: step.contextEdge.sourceLabel,
                identifier: "TodayStartHereContextEdge"
            )
            StartHereFactRow(
                icon: "clock.badge.checkmark",
                title: step.timeFitProof.title,
                value: step.timeFitProof.summary,
                detail: step.timeFitProof.detail,
                identifier: "TodayStartHereTimeFitProof"
            )
            StartHereFactRow(
                icon: "point.3.connected.trianglepath.dotted",
                title: step.goalThread.title,
                value: step.goalThread.summary,
                detail: step.goalThread.detail,
                identifier: "TodayStartHereGoalThread"
            )
            StartHereFactRow(
                icon: "clock.arrow.circlepath",
                title: "Source freshness",
                value: step.receiptItem.freshness.label,
                detail: step.receiptItem.freshness.detail,
                identifier: "TodayStartHereSourceFreshness"
            )
        }
    }

    @ViewBuilder
    private var actionRow: some View {
        let stacksVertically = dynamicTypeSize.isAccessibilitySize
        if stacksVertically {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                actions
            }
        } else {
            HStack(spacing: theme.spacing.sm) {
                actions
            }
        }
    }

    @ViewBuilder
    private var actions: some View {
        TodayPrimaryActionButton(action: step.primaryAction, handler: onAction)
            .accessibilityIdentifier("TodayRealityRailPrimaryAction")
        if let secondaryAction = step.secondaryAction {
            Button {
                onAction(secondaryAction)
            } label: {
                Label(secondaryAction.title, systemImage: secondaryAction.systemImage)
                    .font(theme.typography.bodyEmphasized)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 48)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            .accessibilityHint("Uses the existing Today action without changing anything silently.")
            .accessibilityIdentifier("TodayStartHereSecondaryAction")
        }
    }

    private var sourceSummary: String {
        if privacy.isSensitiveProjection {
            return privacy.sourceLabel
        }
        let labels = step.sourceLabels.map(\.label).prefix(2)
        return labels.isEmpty ? privacy.sourceLabel : labels.joined(separator: " · ")
    }

    private var accessibilityLabel: String {
        privacy.isSensitiveProjection
            ? "Start here. Private item. Details stay private on Today."
            : "Start here. \(step.title). \(step.subtitle)"
    }

    private var accessibilityValue: String {
        [
            step.duration.label,
            sourceSummary,
            step.receiptItem.freshness.label,
            step.contextEdge.summary,
            step.timeFitProof.summary,
            step.goalThread.summary,
            step.receiptItem.accessibilitySummary
        ].joined(separator: ". ")
    }
}

private struct StartHereFactRow: View {
    @Environment(\.ambitionTheme) private var theme

    let icon: String
    let title: String
    let value: String
    let detail: String
    let identifier: String

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.colors.accentWarm)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(title)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(value)
                    .font(theme.typography.bodySecondary)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(detail)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue("\(value). \(detail)")
        .accessibilityIdentifier(identifier)
    }
}

private struct DayRailSection: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let rows: [DayRailRowState]
    let privacy: DayRailPrivacyProjectionState
    let contextLabel: String
    let onOpenStepDetail: (DayRailStepDetailState) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)

            if rows.isEmpty {
                Text(emptyCopy)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                ForEach(rows) { row in
                    DayRailRow(row: row, privacy: privacy, contextLabel: contextLabel, onOpenStepDetail: onOpenStepDetail)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(title)
    }

    private var emptyCopy: String {
        switch title {
        case "Now":
            "Nothing needs you right now."
        case "Next":
            "No next step is being pulled forward."
        default:
            "Later can stay open."
        }
    }
}

private struct MeridianTopologyStrip: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: AmbitionsDayRailViewState
    let semanticState: AmbitionSemanticState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(state.continuity.title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(state.continuity.summary)
                    .font(theme.typography.bodySecondary)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: dynamicTypeSize.isAccessibilitySize ? 144 : 118), spacing: theme.spacing.xs, alignment: .leading)
                ],
                alignment: .leading,
                spacing: theme.spacing.xs
            ) {
                MeridianTopologyBadge(
                    title: "Start Here",
                    detail: state.heroStep?.title ?? "Nothing needs you right now.",
                    state: state.heroStep == nil ? .trust : .focus
                )

                MeridianTopologyBadge(
                    title: "Now",
                    detail: topologyValue(for: .now),
                    state: topologyState(for: .now)
                )

                MeridianTopologyBadge(
                    title: "Next",
                    detail: topologyValue(for: .next),
                    state: topologyState(for: .next)
                )

                MeridianTopologyBadge(
                    title: "Later",
                    detail: topologyValue(for: .later),
                    state: topologyState(for: .later)
                )

                MeridianTopologyBadge(
                    title: "Source",
                    detail: state.privacyProjection.sourceLabel,
                    state: state.privacyProjection.isSensitiveProjection ? .protected : .trust
                )

                MeridianTopologyBadge(
                    title: "Freshness",
                    detail: state.heroStep?.receiptItem.freshness.label ?? "Freshness stays visible",
                    state: freshnessSemanticState
                )

                MeridianTopologyBadge(
                    title: "Closure",
                    detail: state.closureSlot.subtitle,
                    state: .review
                )

                MeridianTopologyBadge(
                    title: "Proof",
                    detail: state.proofSlot.subtitle,
                    state: .trust
                )

                MeridianTopologyBadge(
                    title: "Pressure",
                    detail: state.continuity.pressureLabel,
                    state: semanticState
                )
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Reality Meridian topology")
        .accessibilityValue(accessibilityValue)
        .accessibilityIdentifier("TodayRealityRailTopologyStrip")
    }

    private var freshnessSemanticState: AmbitionSemanticState {
        switch state.heroStep?.receiptItem.freshness {
        case .some(.fresh), .some(.localOnly):
            return .trust
        case .some(.partial):
            return .waiting
        case .some(.stale), .some(.offline), .some(.denied), .some(.blocked), .some(.unavailable):
            return .caution
        case nil:
            return .trust
        }
    }

    private var accessibilityValue: String {
        [
            "Start Here \(state.heroStep?.title ?? "Nothing needs you right now.")",
            "Now \(topologyValue(for: .now))",
            "Next \(topologyValue(for: .next))",
            "Later \(topologyValue(for: .later))",
            "Source \(state.privacyProjection.sourceLabel)",
            "Freshness \(state.heroStep?.receiptItem.freshness.label ?? "Freshness stays visible")",
            "Closure \(state.closureSlot.subtitle)",
            "Proof \(state.proofSlot.subtitle)",
            "Pressure \(state.continuity.pressureLabel)"
        ].joined(separator: ". ")
    }

    private func topologyValue(for slot: DayRailRowSlot) -> String {
        let rows = state.rows.filter { $0.slot == slot }
        switch slot {
        case .now:
            return state.heroStep == nil && rows.isEmpty ? "Open" : "\(rows.count + (state.heroStep == nil ? 0 : 1)) connected"
        case .next, .later:
            return rows.isEmpty ? "Open" : "\(rows.count) connected"
        }
    }

    private func topologyState(for slot: DayRailRowSlot) -> AmbitionSemanticState {
        switch (slot, state.mode) {
        case (.now, .overloaded):
            return .caution
        case (.now, .recovery):
            return .recovery
        case (.now, .protected):
            return .protected
        case (.now, _):
            return semanticState
        case (.next, _):
            return .waiting
        case (.later, _):
            return .neutral
        }
    }
}

private struct MeridianTopologyBadge: View {
    @Environment(\.ambitionTheme) private var theme

    let title: String
    let detail: String
    let state: AmbitionSemanticState

    var body: some View {
        let style = theme.semanticStyle(for: state)

        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(title)
                .font(theme.typography.micro)
                .foregroundStyle(style.accent)
                .lineLimit(1)
            Text(detail)
                .font(theme.typography.caption)
                .foregroundStyle(style.foreground)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .fill(style.fill.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .stroke(style.stroke.opacity(0.72), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(detail)
    }
}

private struct DayRailRow: View {
    @Environment(\.ambitionTheme) private var theme

    let row: DayRailRowState
    let privacy: DayRailPrivacyProjectionState
    let contextLabel: String
    let onOpenStepDetail: (DayRailStepDetailState) -> Void

    var body: some View {
        Button {
            onOpenStepDetail(row.stepDetail(privacy: privacy, contextLabel: contextLabel))
        } label: {
            HStack(alignment: .top, spacing: theme.spacing.md) {
                DayRailNode(kind: nodeKind, active: row.slot == .now)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                        Text(row.slot.title)
                            .font(theme.typography.micro)
                            .foregroundStyle(theme.colors.textTertiary)
                        AmbitionChip(row.duration.label, role: .time, semanticState: .calendarDerived)
                    }

                    Text(row.title)
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(row.subtitle)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: theme.spacing.sm)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(theme.spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(theme.colors.surfaceSecondary.opacity(0.78))
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(theme.colors.strokeSubtle, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue("\(row.duration.label). \(sourceSummary)")
        .accessibilityHint("Opens Step Detail.")
        .accessibilityIdentifier(privacy.isSensitiveProjection ? "TodayRealityRailPrivateItem" : "TodayRealityRailRow")
    }

    private var nodeKind: DayRailNodeKind {
        switch row.slot {
        case .now:
            .active
        case .next:
            .upcoming
        case .later:
            .flexible
        }
    }

    private var sourceSummary: String {
        if privacy.isSensitiveProjection {
            return privacy.sourceLabel
        }
        return row.sourceLabels.map(\.label).prefix(2).joined(separator: " · ")
    }

    private var accessibilityLabel: String {
        privacy.isSensitiveProjection
            ? "\(row.slot.title). Private item. Details stay private on Today."
            : "\(row.slot.title). \(row.title). \(row.subtitle)"
    }
}

private struct RealityRailContinuitySpine: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let state: DayRailContinuityState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(state.title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                Text(state.summary)
                    .font(theme.typography.bodySecondary)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    markerViews
                }
            } else {
                HStack(alignment: .top, spacing: theme.spacing.xs) {
                    markerViews
                }
            }

            HStack(spacing: theme.spacing.xs) {
                AmbitionChip(state.pressureLabel, role: .state, semanticState: .caution)
                AmbitionChip(state.noSilentChangesLabel, role: .state, semanticState: .trust)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Rail safeguards")
            .accessibilityValue("\(state.pressureLabel). \(state.noSilentChangesLabel)")
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.68))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(state.title)
        .accessibilityValue(accessibilityValue)
    }

    @ViewBuilder
    private var markerViews: some View {
        ForEach(state.markers) { marker in
            RealityRailContinuityMarker(marker: marker)
        }
    }

    private var accessibilityValue: String {
        (state.markers.map { "\($0.title): \($0.summary). \($0.detail)" } + [
            state.noSilentChangesLabel
        ]).joined(separator: ". ")
    }
}

private struct RealityRailContinuityMarker: View {
    @Environment(\.ambitionTheme) private var theme

    let marker: DayRailContinuityMarkerState

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            HStack(alignment: .center, spacing: theme.spacing.xs) {
                DayRailNode(kind: marker.kind, active: marker.id == "rail.continuity.start")
                    .frame(width: 24, height: 32)
                    .accessibilityHidden(true)
                Text(marker.title)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.88)
            }

            Text(marker.summary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(marker.detail)
                .font(theme.typography.micro)
                .foregroundStyle(theme.colors.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(theme.spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .fill(theme.semanticStyle(for: marker.semanticState).fill.opacity(0.72))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                .stroke(theme.semanticStyle(for: marker.semanticState).stroke.opacity(0.64), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(marker.title)
        .accessibilityValue("\(marker.summary). \(marker.detail)")
    }
}

struct TodayStepDetailSheet: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    let detail: DayRailStepDetailState
    let onAction: (TodayInlineAction) -> Void

    init(detail: DayRailStepDetailState, onAction: @escaping (TodayInlineAction) -> Void = { _ in }) {
        self.detail = detail
        self.onAction = onAction
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    header
                    labels
                    whyThis
                    proofReceiptAccess
                    privacyState
                    actions
                }
                .padding(theme.spacing.lg)
            }
            .background(TodayBackgroundView())
            .navigationTitle("Why this?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityIdentifier("TodayStepDetailDismiss")
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Step Detail")
        .accessibilityIdentifier("TodayStepDetail")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(detail.timingBucket)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)

            Text(detail.title)
                .font(theme.typography.titleCompact)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("TodayStepDetailTitle")
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(detail.isPrivateProjection ? "Private step" : detail.title)
    }

    private var labels: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            detailLabel(title: "Duration", value: detail.durationLabel, identifier: "TodayStepDetailDurationLabel")
            detailLabel(title: "Duration source", value: detail.durationSourceLabel, identifier: nil)
            detailLabel(title: "Source", value: detail.sourceLabel, identifier: "TodayStepDetailSourceLabel")
            detailLabel(title: "Context", value: detail.contextLabel, identifier: "TodayStepDetailContextLabel")
            detailLabel(title: "Goal", value: detail.goalLinkLabel, identifier: "TodayStepDetailGoalLinkLabel")
        }
    }

    private func detailLabel(title: String, value: String, identifier: String?) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .frame(width: 112, alignment: .leading)
            Text(value)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: theme.spacing.xs)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(value)
        .accessibilityIdentifier(identifier ?? "")
    }

    private var whyThis: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("Recommended because")
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)

            ForEach(Array(detail.whyBullets.enumerated()), id: \.offset) { _, bullet in
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    Circle()
                        .fill(theme.colors.accentWarm.opacity(0.82))
                        .frame(width: 6, height: 6)
                        .padding(.top, 7)
                        .accessibilityHidden(true)
                    Text(bullet)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Why this?")
        .accessibilityValue(detail.whyBullets.joined(separator: ". "))
        .accessibilityIdentifier("TodayStepDetailWhyThis")
    }

    private var proofReceiptAccess: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(theme.semanticAccent(for: .trust))
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(theme.semanticStyle(for: .trust).fill))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    Text("Proof and receipt")
                        .font(theme.typography.bodyEmphasized)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(detail.proofReceiptLabel)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(detail.receiptBoundaryLabel)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.74))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.semanticStyle(for: .trust).stroke.opacity(0.72), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Proof and receipt")
        .accessibilityValue("\(detail.proofReceiptLabel) \(detail.receiptBoundaryLabel)")
        .accessibilityIdentifier("TodayStepDetailProofReceiptAccess")
    }

    @ViewBuilder
    private var privacyState: some View {
        if let privacyLabel = detail.privacyStateLabel {
            HStack(spacing: theme.spacing.sm) {
                Image(systemName: "lock.shield")
                    .foregroundStyle(theme.semanticAccent(for: .protected))
                    .accessibilityHidden(true)
                Text(privacyLabel)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer(minLength: theme.spacing.sm)
            }
            .padding(theme.spacing.md)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(theme.semanticStyle(for: .protected).fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(theme.semanticStyle(for: .protected).stroke, lineWidth: 1)
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Private state")
            .accessibilityValue(privacyLabel)
            .accessibilityIdentifier("TodayStepDetailPrivateState")
        }
    }

    private var actions: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Button {
                dismiss()
                onAction(detail.primaryAction)
            } label: {
                Label(detail.primaryAction.title, systemImage: detail.primaryAction.systemImage)
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            .disabled(detail.primaryAction.target.goalID == nil && detail.primaryAction.target.stepID == nil && detail.primaryAction.target.draftID == nil)
            .accessibilityValue(detail.stepSessionLabel)
            .accessibilityHint("Starts a bounded Step Session for this step.")
            .accessibilityIdentifier("TodayStepDetailPrimaryAction")

            Button {
                dismiss()
                onAction(detail.closureAction)
            } label: {
                Label(detail.closureAction.title, systemImage: detail.closureAction.systemImage)
                    .font(theme.typography.bodyEmphasized)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 48)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            .accessibilityHint("Opens closure choices for this step without changing anything silently.")
            .accessibilityIdentifier("TodayStepDetailClosureAction")

            HStack(spacing: theme.spacing.sm) {
                ForEach(detail.secondaryActions) { action in
                    Button {
                        dismiss()
                        onAction(action)
                    } label: {
                        Label(action.title, systemImage: action.systemImage)
                            .font(theme.typography.caption)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, theme.spacing.sm)
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                    .accessibilityHint("Uses the existing Today action for this step.")
                }
            }
        }
    }
}

private struct DayRailEmptyCard: View {
    @Environment(\.ambitionTheme) private var theme

    let state: AmbitionsDayRailViewState

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.md) {
            DayRailNode(kind: .empty, active: false)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text("Start here")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .accessibilityIdentifier("TodayRealityRailStartHereTitle")
                Text("Nothing needs you right now.")
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Capture something, choose from a goal, or leave today open.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: theme.spacing.sm)
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Start here. Nothing needs you right now.")
        .accessibilityValue(state.contextSummary)
        .accessibilityIdentifier("TodayRealityRailHero")
    }
}

private struct DayRailNode: View {
    @Environment(\.ambitionTheme) private var theme

    let kind: DayRailNodeKind
    let active: Bool

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(theme.colors.strokeSubtle)
                .frame(width: 1, height: 10)
                .opacity(active ? 0 : 1)
            node
            Rectangle()
                .fill(theme.colors.strokeSubtle)
                .frame(width: 1, height: 28)
        }
        .frame(width: 26)
    }

    @ViewBuilder
    private var node: some View {
        switch kind {
        case .closure:
            Diamond()
                .fill(theme.semanticAccent(for: .review).opacity(active ? 0.92 : 0.28))
                .frame(width: 14, height: 14)
        case .proof:
            Image(systemName: "doc.text")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(theme.semanticAccent(for: .trust))
                .frame(width: 20, height: 20)
        case .protected, .waiting, .blocked, .empty:
            Circle()
                .stroke(theme.colors.textTertiary.opacity(0.7), lineWidth: 1.4)
                .frame(width: 14, height: 14)
        case .recommended, .active:
            Circle()
                .fill(theme.colors.accentWarm)
                .frame(width: 16, height: 16)
                .shadow(color: theme.colors.accentWarm.opacity(0.24), radius: 8)
        case .upcoming, .flexible:
            Circle()
                .stroke(theme.colors.accentWarm.opacity(kind == .upcoming ? 0.78 : 0.48), lineWidth: 1.6)
                .frame(width: kind == .upcoming ? 14 : 11, height: kind == .upcoming ? 14 : 11)
        }
    }
}

private struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
