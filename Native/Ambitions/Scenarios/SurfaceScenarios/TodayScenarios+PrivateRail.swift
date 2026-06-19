import AmbitionsDesignSystem
import Foundation

extension PreviewTodayScenarios {
    static func makePrivateRailScenario(from experience: TodayExperience) -> TodayExperience {
        let privacy = DayRailPrivacyProjectionState(classification: .privateUserText)
        let baseRail = experience.execution.dayRail
        let privateHero = baseRail.heroStep.map { hero in
            DayRailHeroStepState(
                id: "\(hero.id).private",
                title: privacy.visibleTitle(hero.title),
                subtitle: privacy.visibleSubtitle(hero.subtitle),
                duration: hero.duration,
                fitLabel: hero.fitLabel,
                whySummary: privacy.visibleSubtitle(hero.whySummary),
                sourceQualityLabel: "Private source",
                becauseLine: privacy.visibleSubtitle(hero.becauseLine),
                contextEdge: StartHereContextEdgeState(
                    title: hero.contextEdge.title,
                    summary: privacy.visibleSubtitle(hero.contextEdge.summary),
                    sourceLabel: privacy.sourceLabel
                ),
                timeFitProof: hero.timeFitProof,
                goalThread: hero.goalThread,
                receiptItem: DayRailHeroStepState.receiptItem(
                    id: "\(hero.receiptItem.id).private",
                    title: "Private item",
                    sourceLabel: privacy.sourceLabel,
                    freshness: .localOnly,
                    privacyLabel: "Private details hidden",
                    becauseLine: "Details stay private on Today."
                ),
                primaryAction: hero.primaryAction,
                secondaryAction: hero.secondaryAction,
                detailTarget: hero.detailTarget,
                sourceLabels: [DayRailSourceLabelState(id: "source.private", label: privacy.sourceLabel, source: .privateUserText)]
            )
        }
        let privateRows = baseRail.rows.map { row in
            DayRailRowState(
                id: "\(row.id).private",
                slot: row.slot,
                title: privacy.visibleTitle(row.title),
                subtitle: privacy.visibleSubtitle(row.subtitle),
                duration: row.duration,
                detailTarget: row.detailTarget,
                sourceLabels: [DayRailSourceLabelState(id: "source.private.\(row.slot.rawValue)", label: privacy.sourceLabel, source: .privateUserText)]
            )
        }
        let privateRail = AmbitionsDayRailViewState(
            id: "\(baseRail.id).private",
            mode: baseRail.mode,
            dateTitle: baseRail.dateTitle,
            contextSummary: privacy.visibleSubtitle(baseRail.contextSummary),
            heroStep: privateHero,
            rows: privateRows,
            primaryAction: baseRail.primaryAction,
            rowTapDetailTargetPlaceholder: baseRail.rowTapDetailTargetPlaceholder,
            durationSource: baseRail.durationSource,
            contextLabels: [DayRailSourceLabelState(id: "source.private", label: privacy.sourceLabel, source: .privateUserText)],
            privacyProjection: privacy,
            continuity: DayRailContinuityState.make(
                heroStep: privateHero,
                rows: privateRows,
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
            execution: experience.execution.replacingDayRail(privateRail)
        )
    }
}
