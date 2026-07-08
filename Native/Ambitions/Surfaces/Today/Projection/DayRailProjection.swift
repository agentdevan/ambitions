import AmbitionsDesignSystem
import Foundation

extension AmbitionsDayRailViewState {
    static func fromPreviewComposition(
        mode: TodayExperienceMode,
        hero: TodayExecutionHeroState,
        todayPlanLayer: TodayTimeLayerState,
        closure: TodayContractEntryState,
        sourceLabel: String
    ) -> AmbitionsDayRailViewState {
        let privacy = DayRailPrivacyProjectionState(
            classification: .standard,
            isSensitiveProjection: false,
            titleReplacement: nil,
            sourceLabel: "Stored on this device"
        )
        let source = DayRailSourceLabelState(id: "source.plan", label: sourceLabel, source: .standard)
        let detailTarget = DayRailDetailTargetState.from(hero.primaryAction)
        let duration = DayRailDurationState.placeholder(for: hero.primaryAction)
        let heroStep = DayRailHeroStepState(
            id: "day-rail.hero.\(hero.primaryAction.id)",
            title: hero.title,
            subtitle: hero.subtitle,
            duration: duration,
            fitLabel: hero.confidenceLabel,
            whySummary: hero.explanation?.summary ?? hero.subtitle,
            sourceQualityLabel: "Source-backed by the current Time shape",
            becauseLine: "Because \(hero.explanation?.summary ?? hero.subtitle)",
            receiptLabel: "Start here review history",
            proofLabel: "No change has been made yet.",
            sourceRecordLabel: DayRailHeroStepState.sourceRecordLabel(for: [source]),
            replayTraceLabel: DayRailHeroStepState.replayTraceLabel(localOnly: true),
            replayInspectionLabel: DayRailHeroStepState.replayInspectionLabel(
                sourceRecordLabel: DayRailHeroStepState.sourceRecordLabel(for: [source]),
                replayTraceLabel: DayRailHeroStepState.replayTraceLabel(localOnly: true)
            ),
            contextEdge: StartHereContextEdgeState(
                title: "Context edge",
                summary: todayPlanLayer.openWindowLabel,
                sourceLabel: source.label
            ),
            timeFitProof: StartHereTimeFitProofState(
                title: "Time fit",
                summary: duration.label,
                detail: hero.confidenceLabel
            ),
            goalThread: StartHereGoalThreadState(
                title: "Goal thread",
                summary: DayRailHeroStepState.goalThreadSummary(for: detailTarget),
                detail: DayRailHeroStepState.goalThreadDetail(for: detailTarget)
            ),
            receiptItem: DayRailHeroStepState.receiptItem(
                id: "start-here.compat.\(hero.primaryAction.id)",
                title: hero.title,
                sourceLabel: source.label,
                freshness: .fresh,
                privacyLabel: privacy.sourceLabel,
                becauseLine: hero.explanation?.summary ?? hero.subtitle
            ),
            primaryAction: hero.primaryAction,
            secondaryAction: DayRailStepDetailState.placeholderActions(target: hero.primaryAction.target).first,
            detailTarget: detailTarget,
            sourceLabels: [source]
        )
        let rows = DayRailRowState.rows(
            from: todayPlanLayer.items,
            fallbackHero: heroStep,
            privacy: privacy,
            source: source
        )
        let closureSlot = DayRailClosureSlotState(
            title: closure.title,
            subtitle: closure.subtitle,
            reservedForActionClosureSheet: true
        )
        let proofSlot = DayRailProofSlotState(
            title: "Proof saved",
            subtitle: "Start here keeps the review history visible before anything changes.",
            noSilentChanges: true,
            reservedForReceiptPeek: false
        )
        return AmbitionsDayRailViewState(
            id: "day-rail.compat.\(mode.rawValue)",
            mode: mode == .empty ? .empty : .normal,
            dateTitle: "Today",
            contextSummary: todayPlanLayer.openWindowLabel,
            heroStep: mode == .empty ? nil : heroStep,
            rows: rows,
            primaryAction: hero.primaryAction,
            rowTapDetailTargetPlaceholder: mode == .empty ? nil : detailTarget,
            durationSource: duration.source,
            contextLabels: [source],
            privacyProjection: privacy,
            continuity: DayRailContinuityState.make(
                heroStep: mode == .empty ? nil : heroStep,
                rows: rows,
                closureSlot: closureSlot,
                proofSlot: proofSlot,
                mode: mode == .empty ? .empty : .normal,
                pressureLabel: mode == .empty ? "Open" : "Ready"
            ),
            closureSlot: closureSlot,
            proofSlot: proofSlot
        )
    }
}

extension DayRailContinuityState {
    static func make(
        heroStep: DayRailHeroStepState?,
        rows: [DayRailRowState],
        closureSlot: DayRailClosureSlotState,
        proofSlot: DayRailProofSlotState,
        mode: DayRailMode,
        pressureLabel: String
    ) -> DayRailContinuityState {
        var markers: [DayRailContinuityMarkerState] = []
        markers.append(
            DayRailContinuityMarkerState(
                id: "rail.continuity.start",
                kind: heroStep == nil ? .empty : .recommended,
                title: "Start here",
                summary: heroStep?.title ?? "User choice stays available.",
                detail: heroStep?.becauseLine ?? "Today stays open until something real exists.",
                semanticState: heroStep == nil ? .trust : .focus
            )
        )

        for slot in DayRailRowSlot.allCases {
            let row = rows.first { $0.slot == slot }
            markers.append(
                DayRailContinuityMarkerState(
                    id: "rail.continuity.\(slot.rawValue)",
                    kind: row?.nodeKind ?? .empty,
                    title: slot.title,
                    summary: row?.title ?? slot.emptyContinuitySummary,
                    detail: row?.duration.label ?? slot.emptyContinuityDetail,
                    semanticState: row == nil ? .trust : slot.semanticState
                )
            )
        }

        markers.append(
            DayRailContinuityMarkerState(
                id: "rail.continuity.closure",
                kind: .closure,
                title: "Closure knot",
                summary: closureSlot.title,
                detail: closureSlot.subtitle,
                semanticState: .review
            )
        )
        markers.append(
            DayRailContinuityMarkerState(
                id: "rail.continuity.proof",
                kind: .proof,
                title: "Proof marker",
                summary: proofSlot.title,
                detail: proofSlot.subtitle,
                semanticState: .trust
            )
        )
        markers.append(
            DayRailContinuityMarkerState(
                id: "rail.continuity.pressure",
                kind: mode == .overloaded ? .blocked : .protected,
                title: "Pressure",
                summary: pressureLabel,
                detail: mode.pressureContinuityDetail,
                semanticState: mode.pressureSemanticState
            )
        )

        return DayRailContinuityState(
            title: "Reality Meridian continuity",
            summary: "Start here emerges from the active Meridian node; Now, Next, Later, closure, proof, and pressure stay connected.",
            markers: markers,
            pressureLabel: pressureLabel,
            noSilentChangesLabel: proofSlot.noSilentChanges ? "Changes stay reviewable." : "Review before changing."
        )
    }
}

extension DayRailRowState {
    var nodeKind: DayRailNodeKind {
        switch slot {
        case .now:
            return .active
        case .next:
            return .upcoming
        case .later:
            return .flexible
        }
    }
}

extension DayRailRowSlot {
    var semanticState: AmbitionSemanticState {
        switch self {
        case .now:
            return .focus
        case .next:
            return .calendarDerived
        case .later:
            return .trust
        }
    }

    var emptyContinuitySummary: String {
        switch self {
        case .now:
            return "Nothing needs you right now."
        case .next:
            return "No next step is being pulled forward."
        case .later:
            return "Later stays open."
        }
    }

    var emptyContinuityDetail: String {
        switch self {
        case .now:
            return "Open"
        case .next:
            return "Held back"
        case .later:
            return "Flexible"
        }
    }
}

extension DayRailMode {
    var pressureSemanticState: AmbitionSemanticState {
        switch self {
        case .recovery:
            return .recovery
        case .protected:
            return .protected
        case .overloaded:
            return .caution
        case .noSchedule:
            return .calendarDerived
        case .normal, .empty:
            return .trust
        }
    }

    var pressureContinuityDetail: String {
        switch self {
        case .normal:
            return "Pressure is held in context."
        case .recovery:
            return "Recovery stays visible before action."
        case .protected:
            return "Protected time stays visible."
        case .overloaded:
            return "Reduce the ask before adding more."
        case .empty:
            return "No pressure is invented."
        case .noSchedule:
            return "Time owns schedule review."
        }
    }
}
