import AmbitionsDesignSystem
import SwiftUI

extension DayRailHeroStepState {
    var visibleCopy: String {
        (
            [
                title,
                subtitle,
                duration.label,
                fitLabel,
                whySummary,
                sourceQualityLabel,
                becauseLine,
                contextEdge.title,
                contextEdge.summary,
                timeFitProof.title,
                timeFitProof.summary,
                timeFitProof.detail,
                goalThread.title,
                goalThread.summary,
                goalThread.detail,
                receiptItem.title,
                receiptItem.summary,
                receiptItem.sourceLabel,
                receiptItem.privacyLabel,
                primaryAction.title,
                secondaryAction?.title
            ].compactMap { $0 }
        ).joined(separator: " ")
    }
}

extension AmbitionsDayRailViewState {
    func replacingHeroStep(
        _ heroStep: DayRailHeroStepState,
        contextSummary: String,
        pressureLabel: String
    ) -> AmbitionsDayRailViewState {
        AmbitionsDayRailViewState(
            id: id,
            mode: mode,
            dateTitle: dateTitle,
            contextSummary: contextSummary,
            heroStep: heroStep,
            rows: rows,
            primaryAction: heroStep.primaryAction,
            rowTapDetailTargetPlaceholder: rowTapDetailTargetPlaceholder,
            durationSource: durationSource,
            contextLabels: contextLabels,
            privacyProjection: privacyProjection,
            continuity: DayRailContinuityState.make(
                heroStep: heroStep,
                rows: rows,
                closureSlot: closureSlot,
                proofSlot: proofSlot,
                mode: mode,
                pressureLabel: pressureLabel
            ),
            closureSlot: closureSlot,
            proofSlot: proofSlot
        )
    }
}
