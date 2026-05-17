import AmbitionsDesignSystem

extension DayRailHeroStepState {
    func startHereProductKernel(privacy: DayRailPrivacyProjectionState) -> StartHereProductKernel {
        StartHereProductKernel(
            title: privacy.isSensitiveProjection ? "Private step" : title,
            subtitle: privacy.isSensitiveProjection ? "Details stay private on Today." : subtitle,
            becauseLine: privacy.isSensitiveProjection ? privacy.sourceLabel : becauseLine,
            durationLabel: duration.label,
            fitLabel: fitLabel,
            sourceQualityLabel: sourceQualityLabel,
            contextEdge: StartHereProductFact(
                id: "context-edge",
                title: contextEdge.title,
                summary: privacy.isSensitiveProjection ? "Private context" : contextEdge.summary,
                detail: privacy.isSensitiveProjection ? privacy.sourceLabel : contextEdge.sourceLabel
            ),
            timeFitProof: StartHereProductFact(
                id: "time-fit-proof",
                title: timeFitProof.title,
                summary: timeFitProof.summary,
                detail: timeFitProof.detail
            ),
            goalThread: StartHereProductFact(
                id: "goal-thread",
                title: goalThread.title,
                summary: privacy.isSensitiveProjection ? "Private goal thread" : goalThread.summary,
                detail: privacy.isSensitiveProjection ? privacy.sourceLabel : goalThread.detail
            ),
            receiptSummary: receiptItem.accessibilitySummary,
            primaryActionTitle: primaryAction.title,
            secondaryActionTitle: secondaryAction?.title
        )
    }
}
