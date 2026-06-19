import AmbitionsDesignSystem
import Foundation

extension ReviewsV1Projector {
    func cadenceSummaries(
        input: ReviewsV1ProjectionInput,
        signalCount: Int,
        recoveryCount: Int
    ) -> [ReviewCadenceSummary] {
        [
            ReviewCadenceSummary(
                id: "review.cadence.weekly",
                cadence: .weekly,
                title: "Weekly Review",
                detail: signalCount == 0 ? "Weekly review appears after local actions, proof, receipts, or corrections exist." : "Turns recent local activity into keep, change, carry, and drop decisions.",
                statusLabel: signalCount == 0 ? "Waiting for local activity" : "Ready from local evidence",
                contextLabel: "You and Plan",
                state: signalCount == 0 ? .default : .selected
            ),
            ReviewCadenceSummary(
                id: "review.cadence.monthly",
                cadence: .monthly,
                title: "Monthly Review",
                detail: "Summarizes direction and proof as a calm review.",
                statusLabel: input.proofEvidence.isEmpty ? "Needs proof over time" : "Proof-aware summary",
                contextLabel: "You and Goals",
                state: input.proofEvidence.isEmpty ? .default : .success
            ),
            ReviewCadenceSummary(
                id: "review.cadence.recovery",
                cadence: .recovery,
                title: "Recovery Review",
                detail: recoveryCount == 0 ? "Shows up when a day or week changes shape." : "Names what recovered, what stayed protected, and what still needs a decision.",
                statusLabel: recoveryCount == 0 ? "Available when needed" : "Needs your review",
                contextLabel: "You, Plan, and Today",
                state: recoveryCount == 0 ? .default : .warning
            )
        ]
    }


    func periodSummary(
        input: ReviewsV1ProjectionInput,
        meaningfulCount: Int,
        receiptCount: Int,
        recoveryCount: Int,
        correctionCount: Int
    ) -> ReviewPeriodSummary {
        let signalCount = meaningfulCount + receiptCount + recoveryCount + correctionCount + input.proofEvidence.count
        let title: String
        let dominantTruth: String
        let state: AmbitionVisualState

        if signalCount == 0 {
            title = "Nothing to review yet"
            dominantTruth = "After more local activity, Reviews will summarize what happened in plain language."
            state = .default
        } else if recoveryCount > 0 {
            title = "Ready to review"
            dominantTruth = "Recent recovery and receipt signals are ready for a calm review."
            state = .selected
        } else {
            title = "Recent movement is visible"
            dominantTruth = "Ambitions has local evidence it can summarize into what happened and what should carry forward."
            state = .success
        }

        return ReviewPeriodSummary(
            title: title,
            subtitle: "Reviews turns execution history into trust, learning, and next-step clarity.",
            timeframeLabel: input.timeframeLabel,
            dominantTruth: dominantTruth,
            trustWhisper: "Stored locally. Suggested, not applied. No live sync, account system, calendar write, or accessibility verification claim is made here.",
            state: state
        )
    }


    func recoverySignals(from assessments: [ExecutionResilienceAssessment], events: [EventLedgerEntry]) -> [ReviewSignalItem] {
        let assessmentItems = assessments.flatMap { assessment in
            assessment.recoveryOptions.prefix(2).map { option in
                ReviewSignalItem(
                    id: "review.recovery.option.\(option.id)",
                    kind: .recovery,
                    title: option.title,
                    detail: option.summary,
                    valueLabel: option.requiresUserConfirmation ? "Suggested, not applied" : "Ready",
                    icon: option.strategy == .protectDeadlineWork ? "lock.shield" : "arrow.triangle.branch",
                    state: option.requiresUserConfirmation ? .warning : .selected
                )
            }
        }

        let eventItems = events.filter { [.planRecovered, .recoveryAccepted, .recoveryDeclined, .recoveryDueToPriorityConflict].contains($0.kind) }
            .prefix(3)
            .map { event in
                ReviewSignalItem(
                    id: "review.recovery.event.\(event.id)",
                    kind: .recovery,
                    title: event.title,
                    detail: event.summary ?? "Recovery context was recorded locally.",
                    valueLabel: event.kind == .recoveryDeclined ? "Not applied" : "Recovered",
                    icon: "lifepreserver",
                    state: event.kind == .recoveryDeclined ? .default : .success
                )
            }

        return unique(Array(assessmentItems.prefix(3)) + Array(eventItems))
    }


    func protectedSignals(from assessments: [ExecutionResilienceAssessment], events: [EventLedgerEntry]) -> [ReviewSignalItem] {
        let protected = assessments.flatMap(\.protectedHighPriorityWork).prefix(3).map { item in
            ReviewSignalItem(
                id: "review.protected.\(item.id)",
                kind: .recovery,
                title: item.title,
                detail: item.summary,
                valueLabel: "Safe from silent changes",
                icon: "lock.shield",
                state: .selected
            )
        }

        let displaced = events.filter { [.itemDisplacedByHigherPriority, .actionMoved, .actionDelayed].contains($0.kind) }
            .prefix(2)
            .map { event in
                ReviewSignalItem(
                    id: "review.moved.\(event.id)",
                    kind: .event,
                    title: event.title,
                    detail: event.summary ?? "A local action changed position or priority.",
                    valueLabel: event.kind == .itemDisplacedByHigherPriority ? "Rescheduled to protect priority" : "Rescheduled or deferred",
                    icon: "clock.arrow.circlepath",
                    state: .default
                )
            }

        return unique(Array(protected) + Array(displaced))
    }


    func reviewNeededSignals(
        from assessments: [ExecutionResilienceAssessment],
        events: [EventLedgerEntry],
        explanations: [RecommendationExplanation]
    ) -> [ReviewSignalItem] {
        var items: [ReviewSignalItem] = assessments.filter { [.needsRecovery, .atRisk, .blocked, .recovering].contains($0.status) }
            .prefix(3)
            .map { assessment in
                ReviewSignalItem(
                    id: "review.needs.\(assessment.id)",
                    kind: .recovery,
                    title: assessment.recommendedRecoveryOption?.title ?? "Needs a decision",
                    detail: assessment.recommendedRecoveryOption?.summary ?? "A recovery state needs review before Ambitions changes anything.",
                    valueLabel: "Needs your decision",
                    icon: "hand.tap",
                    state: .warning
                )
            }

        items += explanations.filter { $0.assumptions.isEmpty == false || $0.correctionActions.isEmpty == false }
            .prefix(2)
            .map { explanation in
                ReviewSignalItem(
                    id: "review.assumption.\(explanation.id)",
                    kind: .correction,
                    title: explanation.title,
                    detail: explanation.summary,
                    valueLabel: "Can be corrected",
                    icon: "checkmark.bubble",
                    state: .default
                )
            }

        items += events.filter { $0.trust.requiresReview }
            .prefix(2)
            .map { event in
                ReviewSignalItem(
                    id: "review.trust.\(event.id)",
                    kind: .event,
                    title: event.title,
                    detail: event.summary ?? "This local event asked for review.",
                    valueLabel: "Ready for your review",
                    icon: "exclamationmark.bubble",
                    state: .warning
                )
            }

        return unique(items)
    }


    func receiptSignals(from receipts: [ActionReceipt]) -> [ReviewSignalItem] {
        receipts.prefix(4).map { receipt in
            ReviewSignalItem(
                id: "review.receipt.\(receipt.id)",
                kind: .receipt,
                title: receipt.title,
                detail: receipt.summary,
                valueLabel: receiptLabel(for: receipt),
                icon: receiptIcon(for: receipt.resultState),
                state: receiptState(for: receipt)
            )
        }
    }


    func eventSignals(from events: [EventLedgerEntry]) -> [ReviewSignalItem] {
        events.filter(isMeaningfulForLifeReceipt)
            .prefix(5)
            .map { event in
                ReviewSignalItem(
                    id: "review.event.\(event.id)",
                    kind: .event,
                    title: event.title,
                    detail: event.summary ?? event.kind.reviewDetail,
                    valueLabel: event.kind.reviewLabel,
                    icon: event.kind.reviewIcon,
                    state: event.tone.reviewState
                )
            }
    }


    func proofHighlights(from evidence: [ProgressEvidence]) -> [ReviewProofHighlight] {
        evidence.sorted { lhs, rhs in
            if lhs.capturedAt != rhs.capturedAt { return lhs.capturedAt > rhs.capturedAt }
            return lhs.id < rhs.id
        }
        .prefix(3)
        .map { proof in
            ReviewProofHighlight(
                id: "review.proof.\(proof.id)",
                title: proof.note?.nilIfBlank ?? proof.evidenceKind.reviewTitle,
                detail: proof.evidenceKind.reviewDetail,
                valueLabel: "Proof recorded",
                state: .success
            )
        }
    }


    func correctionPrompts(
        from teachingSignals: [GoalTeachingSignal],
        events: [EventLedgerEntry],
        explanations: [RecommendationExplanation]
    ) -> [ReviewCorrectionPrompt] {
        var prompts = teachingSignals.filter { $0.disposition == .active }
            .prefix(3)
            .map { signal in
                ReviewCorrectionPrompt(
                    id: "review.correction.signal.\(signal.id)",
                    title: "Correction available",
                    detail: signal.userNote?.nilIfBlank ?? "A local teaching signal can shape future recommendations.",
                    actionLabel: "Supported where shown",
                    state: .selected
                )
            }

        prompts += events.filter { $0.kind == .userCorrectionAdded }
            .prefix(2)
            .map { event in
                ReviewCorrectionPrompt(
                    id: "review.correction.event.\(event.id)",
                    title: event.title,
                    detail: event.summary ?? "A correction was recorded locally.",
                    actionLabel: "Can be reviewed",
                    state: .success
                )
            }

        prompts += explanations.filter { $0.correctionActions.isEmpty == false }
            .prefix(2)
            .map { explanation in
                ReviewCorrectionPrompt(
                    id: "review.correction.explanation.\(explanation.id)",
                    title: "Assumption may need attention",
                    detail: explanation.summary,
                    actionLabel: "You can correct this",
                    state: .warning
                )
            }

        return unique(prompts)
    }
}
