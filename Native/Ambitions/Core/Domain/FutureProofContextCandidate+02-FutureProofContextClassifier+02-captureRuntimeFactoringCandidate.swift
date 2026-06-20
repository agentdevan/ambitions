import Foundation

extension FutureProofContextClassifier {
    static func captureRuntimeFactoringCandidate(from result: SmartAttachmentResult) -> CaptureRuntimeFactoringCandidate? {
        guard result.goalRelevanceScan?.hasAnyRelevantMatch != true else {
            return nil
        }

        let extraction = result.semanticExtraction
        let normalized = extraction.normalizedText
        let sourceLabel = result.input.sourceContext?.sourceType?.title ?? "Capture"

        if extraction.recoverySignal || containsAny(normalized, ["hurt", "injury", "sore", "recover", "recovery", "rest"]) {
            return makePair(
                captureID: result.id,
                candidateType: .recovery,
                contextCategory: .recoveryConstraint,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: false,
                requiresApproval: true,
                sourceFreshness: .mayNeedReview,
                sensitivity: .sensitive,
                reason: "The capture preserves sensitive recovery context that should stay review-gated before runtime use.",
                rejectedReason: "Sensitive recovery context requires approval before runtime use.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "recovery-aware planning",
                    "approval-gated runtime use"
                ],
                reviewNeeded: true
            ).runtimeCandidate
        }

        if containsAny(normalized, ["trail closed", "closed trail", "mountain bike trail closed"]) ||
            (extraction.blockerSignal && containsAny(normalized, Self.accessConstraintTerms)) {
            return makePair(
                captureID: result.id,
                candidateType: .blocker,
                contextCategory: .accessConstraint,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture records an access constraint that can help future planning avoid the same dead end.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "access constraint review",
                    "future opportunity filtering"
                ],
                reviewNeeded: true
            ).runtimeCandidate
        }

        if extraction.facilityHint != nil,
           containsAny(normalized, ["ymca", "open court", "court", "gym", "field", "trail", "studio", "clinic", "pool", "access confirmed"]) {
            return makePair(
                captureID: result.id,
                candidateType: .facilityAccess,
                contextCategory: .facilityAccess,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture preserves facility access context for future planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "facility access checks",
                    "go / no-go planning"
                ],
                reviewNeeded: false
            ).runtimeCandidate
        } else if extraction.equipmentHint != nil,
                  extraction.recurrenceHint == nil,
                  containsAny(normalized, ["weekly", "every "]) == false {
            return makePair(
                captureID: result.id,
                candidateType: .equipmentAccess,
                contextCategory: .equipmentAccess,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture keeps equipment access visible for future planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "equipment planning",
                    "future step feasibility"
                ],
                reviewNeeded: false
            ).runtimeCandidate
        }

        if extraction.recurrenceHint != nil || containsAny(normalized, ["weekly", "every "]) {
            let category: FutureProofContextCategory = Self.isLearningRecurringContext(extraction: extraction, normalized: normalized) ? .skillContext : .recurringCommitment
            return makePair(
                captureID: result.id,
                candidateType: .recurringCommitment,
                contextCategory: category,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture names a recurring commitment that can stay visible in the local life graph.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "recurring planning",
                    "skill practice context"
                ],
                reviewNeeded: false
            ).runtimeCandidate
        }

        if containsAny(normalized, ["worked late again", "late again", "worked late"]) ||
            (extraction.activity == .work && extraction.blockerSignal && containsAny(normalized, ["late", "over time"])) {
            return makePair(
                captureID: result.id,
                candidateType: .scheduledActivity,
                contextCategory: .scheduleDrift,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture preserves schedule drift and capacity pressure for future planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "capacity-aware planning",
                    "future schedule planning"
                ],
                reviewNeeded: true
            ).runtimeCandidate
        }

        if containsAny(normalized, ["pickleball", "activity history"]) || extraction.activity == .exercise {
            return makePair(
                captureID: result.id,
                candidateType: .historicalContext,
                contextCategory: .activityHistory,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture records an activity history signal that can help future fitness or social planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "future fitness planning",
                    "social context",
                    "activity history"
                ],
                reviewNeeded: false
            ).runtimeCandidate
        }

        if extraction.proofSignal {
            return makePair(
                captureID: result.id,
                candidateType: .proof,
                contextCategory: .historicalContext,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture is proof that can ground future planning.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "proof review",
                    "future planning references"
                ],
                reviewNeeded: false
            ).runtimeCandidate
        }

        if extraction.actionVerb != nil || extraction.object != nil || extraction.goalDomainHints.isEmpty == false {
            return makePair(
                captureID: result.id,
                candidateType: .step,
                contextCategory: .lifeContext,
                suggestedDestination: "What Ambitions Knows",
                runtimeUseAllowed: true,
                requiresApproval: false,
                sourceFreshness: .current,
                sensitivity: .normal,
                reason: "The capture looks like a useful future step or context note.",
                sourceLabel: sourceLabel,
                potentialFutureUses: [
                    "future step planning",
                    "runtime fit checks"
                ],
                reviewNeeded: false
            ).runtimeCandidate
        }

        return makePair(
            captureID: result.id,
            candidateType: .decideLater,
            contextCategory: .decideLater,
            suggestedDestination: "Capture",
            runtimeUseAllowed: false,
            requiresApproval: false,
            sourceFreshness: .basedOnOlderContext,
            sensitivity: .normal,
            reason: "The capture is still useful, but it needs a later review before runtime use.",
            rejectedReason: "Not enough signal yet to promote this capture into future runtime use.",
            sourceLabel: sourceLabel,
            potentialFutureUses: [
                "manual review",
                "later classification"
            ],
            reviewNeeded: true
        ).runtimeCandidate
    }
}
