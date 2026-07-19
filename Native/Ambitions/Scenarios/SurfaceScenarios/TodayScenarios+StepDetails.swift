import AmbitionsDesignSystem
import Foundation

extension PreviewTodayScenarios {
    static func makeMissingDurationStepDetail() -> DayRailStepDetailState {
        let rail = stable.execution.dayRail
        let row = DayRailRowState(
            id: "preview.step-detail.missing-duration",
            slot: .later,
            title: "Review launch notes",
            subtitle: "A flexible follow-up if the main block lands.",
            duration: DayRailDurationState(minutes: nil, source: .notSet, label: "Duration not set"),
            detailTarget: DayRailDetailTargetState(
                kind: .stepDetail,
                goalID: "goal-preview",
                stepID: "step-preview",
                draftID: nil,
                placeholderLabel: "Open Step Detail."
            ),
            sourceLabels: [DayRailSourceLabelState(id: "source.preview", label: "Based on your goal path", source: .standard)]
        )
        return row.stepDetail(
            privacy: rail.privacyProjection,
            contextLabel: "Later can stay open."
        )
    }

    static func makeStartHereStepDetail() -> DayRailStepDetailState? {
        guard let baseHero = stable.execution.dayRail.heroStep else { return nil }
        let rail = stable.execution.dayRail
        let hero = DayRailHeroStepState(
            id: "preview.step-detail.start-here",
            title: baseHero.title,
            subtitle: baseHero.subtitle,
            duration: DayRailDurationState(minutes: 25, source: .suggested, label: "25 min suggested"),
            fitLabel: baseHero.fitLabel,
            whySummary: baseHero.whySummary,
            sourceQualityLabel: baseHero.sourceQualityLabel,
            becauseLine: baseHero.becauseLine,
            contextEdge: baseHero.contextEdge,
            timeFitProof: baseHero.timeFitProof,
            goalThread: baseHero.goalThread,
            receiptItem: baseHero.receiptItem,
            primaryAction: DayRailStepDetailState.reservedStartNowAction(target: baseHero.primaryAction.target),
            secondaryAction: baseHero.secondaryAction,
            detailTarget: baseHero.detailTarget,
            sourceLabels: baseHero.sourceLabels
        )
        return hero.stepDetail(
            privacy: rail.privacyProjection,
            contextLabel: rail.contextSummary
        )
    }
}
