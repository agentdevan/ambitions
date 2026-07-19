import AmbitionsDesignSystem
import Foundation

extension PreviewTodayScenarios {
    static func makeSourceStateScenario(
        from experience: TodayExperience,
        sourceQualityLabel: String,
        freshness: SourceFreshnessState,
        sourceLabels: [DayRailSourceLabelState],
        sourceRecordLabel: String,
        replayTraceLabel: String
    ) -> TodayExperience {
        let baseRail = experience.execution.dayRail
        guard let baseHero = baseRail.heroStep else { return experience }

        let sourceLabel = sourceLabels.first?.label ?? sourceQualityLabel
        let hero = DayRailHeroStepState(
            id: "\(baseHero.id).\(freshness.rawValue)",
            title: baseHero.title,
            subtitle: baseHero.subtitle,
            duration: baseHero.duration,
            fitLabel: freshness == .blocked || freshness == .partial ? "Needs review" : baseHero.fitLabel,
            whySummary: baseHero.whySummary,
            sourceQualityLabel: sourceQualityLabel,
            becauseLine: baseHero.becauseLine,
            receiptLabel: baseHero.receiptLabel,
            proofLabel: baseHero.proofLabel,
            sourceRecordLabel: sourceRecordLabel,
            replayTraceLabel: replayTraceLabel,
            replayInspectionLabel: DayRailHeroStepState.replayInspectionLabel(
                sourceRecordLabel: sourceRecordLabel,
                replayTraceLabel: replayTraceLabel
            ),
            contextEdge: StartHereContextEdgeState(
                title: baseHero.contextEdge.title,
                summary: baseHero.contextEdge.summary,
                sourceLabel: sourceLabel
            ),
            timeFitProof: StartHereTimeFitProofState(
                title: baseHero.timeFitProof.title,
                summary: baseHero.timeFitProof.summary,
                detail: freshness == .blocked || freshness == .partial ? "Review before starting." : baseHero.timeFitProof.detail
            ),
            goalThread: baseHero.goalThread,
            receiptItem: DayRailHeroStepState.receiptItem(
                id: "\(baseHero.receiptItem.id).\(freshness.rawValue)",
                title: baseHero.receiptItem.redactedDetail ?? baseHero.title,
                sourceLabel: sourceLabel,
                freshness: freshness,
                privacyLabel: baseHero.receiptItem.privacyLabel,
                becauseLine: baseHero.receiptItem.whyLabel ?? baseHero.becauseLine
            ),
            primaryAction: baseHero.primaryAction,
            secondaryAction: baseHero.secondaryAction,
            detailTarget: baseHero.detailTarget,
            sourceLabels: sourceLabels
        )

        let rail = AmbitionsDayRailViewState(
            id: "\(baseRail.id).\(freshness.rawValue)",
            mode: baseRail.mode,
            dateTitle: baseRail.dateTitle,
            contextSummary: baseRail.contextSummary,
            heroStep: hero,
            rows: baseRail.rows,
            primaryAction: baseRail.primaryAction,
            rowTapDetailTargetPlaceholder: baseRail.rowTapDetailTargetPlaceholder,
            durationSource: baseRail.durationSource,
            contextLabels: sourceLabels,
            privacyProjection: baseRail.privacyProjection,
            continuity: DayRailContinuityState.make(
                heroStep: hero,
                rows: baseRail.rows,
                closureSlot: baseRail.closureSlot,
                proofSlot: baseRail.proofSlot,
                mode: baseRail.mode,
                pressureLabel: baseRail.continuity.pressureLabel
            ),
            closureSlot: baseRail.closureSlot,
            proofSlot: baseRail.proofSlot
        )

        return TodayExperience(
            mode: experience.mode,
            hero: experience.hero,
            support: experience.support,
            execution: experience.execution.replacingDayRail(rail)
        )
    }
}
