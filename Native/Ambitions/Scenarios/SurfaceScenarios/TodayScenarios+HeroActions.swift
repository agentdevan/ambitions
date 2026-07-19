import AmbitionsDesignSystem
import Foundation

extension PreviewTodayScenarios {
    static func makeHeroActionScenario(
        from experience: TodayExperience,
        action: TodayInlineAction
    ) -> TodayExperience {
        let baseRail = experience.execution.dayRail
        guard let baseHero = baseRail.heroStep else { return experience }
        let hero = DayRailHeroStepState(
            id: "\(baseHero.id).\(action.state.rawValue)",
            title: baseHero.title,
            subtitle: baseHero.subtitle,
            duration: baseHero.duration,
            fitLabel: action.state == .disabled ? "Needs review" : baseHero.fitLabel,
            whySummary: action.state == .disabled
                ? "The source is visible, but the next action should wait for review."
                : baseHero.whySummary,
            sourceQualityLabel: action.state == .disabled ? "Source needs review" : baseHero.sourceQualityLabel,
            becauseLine: action.state == .disabled
                ? "Because the source is visible, but the next action should wait for review."
                : baseHero.becauseLine,
            receiptLabel: baseHero.receiptLabel,
            proofLabel: baseHero.proofLabel,
            sourceRecordLabel: baseHero.sourceRecordLabel,
            replayTraceLabel: baseHero.replayTraceLabel,
            replayInspectionLabel: baseHero.replayInspectionLabel,
            contextEdge: baseHero.contextEdge,
            timeFitProof: action.state == .disabled
                ? StartHereTimeFitProofState(title: baseHero.timeFitProof.title, summary: baseHero.timeFitProof.summary, detail: "Review before starting.")
                : baseHero.timeFitProof,
            goalThread: baseHero.goalThread,
            receiptItem: action.state == .disabled
                ? DayRailHeroStepState.receiptItem(
                    id: "\(baseHero.receiptItem.id).needs-review",
                    title: baseHero.title,
                    sourceLabel: baseHero.receiptItem.sourceLabel,
                    freshness: .partial,
                    privacyLabel: baseHero.receiptItem.privacyLabel,
                    becauseLine: "The source is visible, but the next action should wait for review."
                )
                : baseHero.receiptItem,
            primaryAction: action,
            secondaryAction: baseHero.secondaryAction,
            detailTarget: baseHero.detailTarget,
            sourceLabels: baseHero.sourceLabels
        )
        let rail = AmbitionsDayRailViewState(
            id: "\(baseRail.id).hero-\(action.state.rawValue)",
            mode: baseRail.mode,
            dateTitle: baseRail.dateTitle,
            contextSummary: baseRail.contextSummary,
            heroStep: hero,
            rows: baseRail.rows,
            primaryAction: action,
            rowTapDetailTargetPlaceholder: baseRail.rowTapDetailTargetPlaceholder,
            durationSource: baseRail.durationSource,
            contextLabels: baseRail.contextLabels,
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
