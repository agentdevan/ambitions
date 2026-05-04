import AmbitionsDesignSystem
import SwiftUI

struct DayTimelineRail: View {
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
            header
            DayRailRhythmStrip(state: state, semanticState: semanticState)

            if let heroStep = state.heroStep {
                DayRailHeroStepCard(
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

            DayRailSection(title: "Now", rows: rows(for: .now), privacy: state.privacyProjection, contextLabel: state.contextSummary, onOpenStepDetail: onOpenStepDetail)
                .accessibilityIdentifier("TodayRealityRailNowSection")
            DayRailSection(title: "Next", rows: rows(for: .next), privacy: state.privacyProjection, contextLabel: state.contextSummary, onOpenStepDetail: onOpenStepDetail)
                .accessibilityIdentifier("TodayRealityRailNextSection")
            DayRailSection(title: "Later", rows: rows(for: .later), privacy: state.privacyProjection, contextLabel: state.contextSummary, onOpenStepDetail: onOpenStepDetail)
                .accessibilityIdentifier("TodayRealityRailLaterSection")

            DayRailReservedSlots(closureSlot: state.closureSlot, proofSlot: state.proofSlot)
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
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                Text(state.dateTitle)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                AmbitionChip(modeLabel, role: .state, semanticState: semanticState)
                Spacer(minLength: theme.spacing.sm)
            }

            Text(state.contextSummary)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            if state.contextLabels.isEmpty == false {
                HStack(spacing: theme.spacing.xs) {
                    ForEach(state.contextLabels.prefix(3)) { label in
                        AmbitionChip(sourceLabel(label), role: .state, semanticState: sourceSemanticState(label))
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Source context")
                .accessibilityValue(state.contextLabels.prefix(3).map(sourceLabel).joined(separator: ", "))
            }

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
        var parts = ["Reality Rail", state.dateTitle, modeLabel, state.contextSummary]
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

private struct DayRailHeroStepCard: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let step: DayRailHeroStepState
    let privacy: DayRailPrivacyProjectionState
    let contextLabel: String
    let onAction: (TodayInlineAction) -> Void
    let onOpenStepDetail: (DayRailStepDetailState) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Button {
                onOpenStepDetail(step.stepDetail(privacy: privacy, contextLabel: contextLabel))
            } label: {
                HStack(alignment: .top, spacing: theme.spacing.md) {
                    DayRailNode(kind: .recommended, active: true)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
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

                        HStack(spacing: theme.spacing.xs) {
                            AmbitionChip(step.duration.label, role: .time, semanticState: .calendarDerived)
                            AmbitionChip(step.fitLabel, role: .state, semanticState: .focus)
                        }

                        if step.sourceLabels.isEmpty == false {
                            Text(sourceSummary)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textTertiary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        HStack(alignment: .center, spacing: theme.spacing.sm) {
                            EvidenceLabel(
                                "Why this now",
                                detail: step.whySummary,
                                source: sourceSummary,
                                state: .proof,
                                context: .today
                            )
                            ProofPulse(isActive: true, label: "Today proof available")
                        }
                    }
                    Spacer(minLength: theme.spacing.sm)
                }
            }
            .buttonStyle(.plain)

            TodayPrimaryActionButton(action: step.primaryAction, handler: onAction)
                .accessibilityIdentifier("TodayRealityRailPrimaryAction")
        }
        .padding(theme.spacing.md)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.accentWarm.opacity(0.28), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityValue("\(step.duration.label). \(sourceSummary)")
        .accessibilityHint("Opens Step Detail. Start now opens Step Session.")
        .accessibilityIdentifier(privacy.isSensitiveProjection ? "TodayRealityRailPrivateItem" : "TodayRealityRailHeroCard")
        .transition(DAVMotionPreset.heroExpansion.transition(reduceMotion: reduceMotion))
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

private struct DayRailReservedSlots: View {
    @Environment(\.ambitionTheme) private var theme

    let closureSlot: DayRailClosureSlotState
    let proofSlot: DayRailProofSlotState

    var body: some View {
        HStack(alignment: .top, spacing: theme.spacing.sm) {
            Image(systemName: "lock.shield")
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textTertiary)
                .accessibilityHidden(true)
            Text(reservedCopy)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: theme.spacing.sm)
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.68))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Reserved rail slots")
        .accessibilityValue(reservedCopy)
    }

    private var reservedCopy: String {
        var parts: [String] = []
        if closureSlot.reservedForActionClosureSheet {
            parts.append("Close the loop stays reserved for F05.")
        }
        if proofSlot.reservedForReceiptPeek {
            parts.append("Proof and receipts stay reserved for F06.")
        }
        if proofSlot.noSilentChanges {
            parts.append("No silent changes.")
        }
        return parts.joined(separator: " ")
    }
}

struct TodayStepDetailSheet: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    let detail: DayRailStepDetailState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    header
                    labels
                    whyThis
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
            Button {} label: {
                Label(detail.primaryAction.title, systemImage: detail.primaryAction.systemImage)
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
            }
            .buttonStyle(AmbitionPressableButtonStyle(state: .default))
            .disabled(true)
            .accessibilityHint("Starts a bounded Step Session for this step.")
            .accessibilityIdentifier("TodayStepDetailPrimaryAction")

            HStack(spacing: theme.spacing.sm) {
                ForEach(detail.secondaryActions) { action in
                    Button {} label: {
                        Label(action.title, systemImage: action.systemImage)
                            .font(theme.typography.caption)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, theme.spacing.sm)
                    }
                    .buttonStyle(AmbitionPressableButtonStyle(state: .default))
                    .disabled(true)
                    .accessibilityHint("Reserved placeholder. No plan changes happen from Step Detail in F03.")
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
