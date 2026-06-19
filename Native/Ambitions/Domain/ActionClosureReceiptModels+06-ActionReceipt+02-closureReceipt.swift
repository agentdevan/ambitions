import Foundation

extension ActionReceipt {
    static func closureReceipt(
        id: String,
        occurrence: StepOccurrence,
        outcome: ClosureState,
        stepTitle: String,
        occurredAt: String,
        recordedAt: String? = nil,
        sourceDomain: ActionReceiptSourceDomain = .today,
        why: String? = nil
    ) -> ActionReceipt {
        let stepReference = LifeGraphObjectReference(
            kind: .step,
            id: occurrence.stepID.uuidString,
            label: stepTitle,
            sourceDomain: sourceDomain.lifeGraphSourceDomain
        )
        return ActionReceipt(
            id: id,
            resultState: outcome.actionReceiptResultState,
            title: outcome.receiptTitle(stepTitle: stepTitle),
            summary: outcome.receiptSummary(stepTitle: stepTitle),
            sourceDomain: sourceDomain,
            occurredAt: occurredAt,
            createdAt: recordedAt,
            affectedObjects: [stepReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).closure",
                    kind: outcome.changedFactKind,
                    object: stepReference,
                    fieldName: "closureState",
                    previousValueSummary: occurrence.closureState?.displayLabel,
                    newValueSummary: outcome.displayLabel,
                    summary: outcome.changedFactSummary(stepTitle: stepTitle)
                )
            ],
            why: why.map { ActionReceiptWhyExplanation(body: $0) },
            nextAction: outcome.nextAction,
            correctionAvailability: .available,
            undoAvailability: outcome.undoAvailability,
            safetyState: outcome == .needsReview ? .confirmationRequired : .normal
        )
    }


    static func candidateRejectionReceipt(
        id: String,
        candidateID: String,
        sourceStepID: String,
        sourceCandidateID: String?,
        reason: StepCandidateRejectionReason,
        contextFingerprint: String,
        recordedAt: String,
        customReasonText: String? = nil,
        skippedReason: Bool = false
    ) -> ActionReceipt {
        let stepReference = LifeGraphObjectReference(
            kind: .step,
            id: sourceStepID,
            label: "Recommended step",
            sourceDomain: .today
        )
        let reasonSummary = reason.redactedLabel
        let detailSummary = skippedReason ? "Reason skipped" : reasonSummary
        let changedFact = ActionReceiptChangedFact(
            id: "\(id).candidate-rejection",
            kind: .candidateRejectedByConstraint,
            object: stepReference,
            fieldName: "rejectionReason",
            newValueSummary: reason.storageLabel,
            summary: detailSummary
        )

        return ActionReceipt(
            id: id,
            resultState: .changed,
            title: "Not this",
            summary: "Rejected recommended step · receipt saved",
            sourceDomain: .today,
            occurredAt: recordedAt,
            affectedObjects: [stepReference],
            changedFacts: [
                changedFact,
                ActionReceiptChangedFact(
                    id: "\(id).skip-quality",
                    kind: .candidateRejectedByConstraint,
                    object: stepReference,
                    fieldName: "skippedReason",
                    newValueSummary: skippedReason ? "true" : "false",
                    summary: skippedReason ? "Lower learning quality because the reason was skipped." : "Learning quality remains reason-backed."
                ),
                ActionReceiptChangedFact(
                    id: "\(id).context-fingerprint",
                    kind: .candidateRejectedByConstraint,
                    object: stepReference,
                    fieldName: "contextFingerprint",
                    newValueSummary: contextFingerprint,
                    summary: "Context fingerprint recorded locally"
                )
            ],
            why: ActionReceiptWhyExplanation(
                body: customReasonText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? customReasonText : nil,
                recommendationExplanationIDs: [contextFingerprint]
            ),
            nextAction: skippedReason ? ActionReceiptNextAction(kind: .openToday, title: "Choose a reason", destination: .today) : nil,
            correctionAvailability: skippedReason ? .availableWithReason : .available,
            undoAvailability: .availableLocal,
            safetyState: reason.code.isSensitive ? .confirmationRequired : .normal,
            safeFailure: nil,
            sourceObject: LifeGraphObjectReference(
                kind: .step,
                id: sourceCandidateID ?? candidateID,
                label: reasonSummary,
                sourceDomain: .today
            )
        )
    }


    static func stepRejectedReceipt(
        id: String,
        candidateID: String,
        sourceStepID: String,
        sourceCandidateID: String?,
        reason: StepCandidateRejectionReason,
        contextFingerprint: String,
        recordedAt: String,
        customReasonText: String? = nil,
        skippedReason: Bool = false
    ) -> ActionReceipt {
        let stepReference = LifeGraphObjectReference(
            kind: .step,
            id: sourceStepID,
            label: "Recommended step",
            sourceDomain: .today
        )
        let reasonSummary = reason.redactedLabel
        let detailSummary = skippedReason ? "Reason skipped" : reasonSummary
        let sourceObject = LifeGraphObjectReference(
            kind: .step,
            id: sourceCandidateID ?? candidateID,
            label: reasonSummary,
            sourceDomain: .today
        )

        return ActionReceipt(
            id: id,
            resultState: .changed,
            title: "Not this",
            summary: "Rejected recommended step · receipt saved",
            sourceDomain: .today,
            occurredAt: recordedAt,
            affectedObjects: [stepReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).step-rejected",
                    kind: .stepRejected,
                    object: stepReference,
                    fieldName: "stepDecision",
                    newValueSummary: "rejected",
                    summary: "The current recommendation was rejected locally."
                ),
                ActionReceiptChangedFact(
                    id: "\(id).rejection-reason",
                    kind: .rejectionReasonSaved,
                    object: stepReference,
                    fieldName: "rejectionReason",
                    newValueSummary: reason.storageLabel,
                    summary: detailSummary
                ),
                ActionReceiptChangedFact(
                    id: "\(id).skipped-reason",
                    kind: .rejectionReasonSaved,
                    object: stepReference,
                    fieldName: "skippedReason",
                    newValueSummary: skippedReason ? "true" : "false",
                    summary: skippedReason ? "Lower learning quality because the reason was skipped." : "Learning quality remains reason-backed."
                ),
                ActionReceiptChangedFact(
                    id: "\(id).context-fingerprint",
                    kind: .rejectionReasonSaved,
                    object: stepReference,
                    fieldName: "contextFingerprint",
                    newValueSummary: contextFingerprint,
                    summary: "Context fingerprint recorded locally."
                ),
                ActionReceiptChangedFact(
                    id: "\(id).rejected-candidate-suppressed",
                    kind: .rejectedCandidateSuppressed,
                    object: stepReference,
                    fieldName: "suppressedCandidate",
                    newValueSummary: sourceCandidateID ?? candidateID,
                    summary: "The rejected candidate will be suppressed in later local ranking."
                ),
                ActionReceiptChangedFact(
                    id: "\(id).preference-learned",
                    kind: .preferenceLearned,
                    object: stepReference,
                    fieldName: "preferenceLearning",
                    newValueSummary: reason.code.rawValue,
                    summary: "Future ranking will learn from the rejection reason."
                )
            ],
            why: ActionReceiptWhyExplanation(
                body: customReasonText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? customReasonText : nil,
                recommendationExplanationIDs: [contextFingerprint]
            ),
            nextAction: skippedReason ? ActionReceiptNextAction(kind: .openToday, title: "Choose a reason", destination: .today) : nil,
            correctionAvailability: skippedReason ? .availableWithReason : .available,
            undoAvailability: .availableLocal,
            safetyState: reason.code.isSensitive ? .confirmationRequired : .normal,
            safeFailure: nil,
            sourceObject: sourceObject
        )
    }


    static func rejectionReasonSavedReceipt(
        id: String,
        candidateID: String,
        sourceStepID: String,
        sourceCandidateID: String?,
        reason: StepCandidateRejectionReason,
        contextFingerprint: String,
        recordedAt: String,
        customReasonText: String? = nil
    ) -> ActionReceipt {
        let stepReference = LifeGraphObjectReference(
            kind: .step,
            id: sourceStepID,
            label: "Recommended step",
            sourceDomain: .today
        )
        return ActionReceipt(
            id: id,
            resultState: .changed,
            title: "Reason saved",
            summary: "Rejected step reason saved locally.",
            sourceDomain: .today,
            occurredAt: recordedAt,
            affectedObjects: [stepReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).rejection-reason",
                    kind: .rejectionReasonSaved,
                    object: stepReference,
                    fieldName: "rejectionReason",
                    newValueSummary: reason.storageLabel,
                    summary: "The rejection reason was saved locally."
                ),
                ActionReceiptChangedFact(
                    id: "\(id).preference-learned",
                    kind: .preferenceLearned,
                    object: stepReference,
                    fieldName: "preferenceLearning",
                    newValueSummary: reason.code.rawValue,
                    summary: "Preference learning updated locally."
                ),
                ActionReceiptChangedFact(
                    id: "\(id).context-fingerprint",
                    kind: .rejectionReasonSaved,
                    object: stepReference,
                    fieldName: "contextFingerprint",
                    newValueSummary: contextFingerprint,
                    summary: "Context fingerprint recorded locally."
                )
            ],
            why: ActionReceiptWhyExplanation(
                body: customReasonText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false ? customReasonText : nil,
                recommendationExplanationIDs: [contextFingerprint]
            ),
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            safetyState: reason.code.isSensitive ? .confirmationRequired : .normal,
            sourceObject: LifeGraphObjectReference(
                kind: .step,
                id: sourceCandidateID ?? candidateID,
                label: reason.redactedLabel,
                sourceDomain: .today
            )
        )
    }


    static func alternateStepGeneratedReceipt(
        id: String,
        candidateID: String,
        sourceStepID: String,
        sourceCandidateID: String?,
        alternativeCount: Int,
        timelineImpactSummary: String,
        recordedAt: String
    ) -> ActionReceipt {
        let stepReference = LifeGraphObjectReference(
            kind: .step,
            id: sourceStepID,
            label: "Recommended step",
            sourceDomain: .today
        )
        return ActionReceipt(
            id: id,
            resultState: .changed,
            title: "Alternatives shown",
            summary: "Generated \(max(0, alternativeCount)) local alternatives.",
            sourceDomain: .today,
            occurredAt: recordedAt,
            affectedObjects: [stepReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).alternate-step-generated",
                    kind: .alternateStepGenerated,
                    object: stepReference,
                    fieldName: "alternativeCount",
                    newValueSummary: String(max(0, alternativeCount)),
                    summary: timelineImpactSummary
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: LifeGraphObjectReference(
                kind: .step,
                id: sourceCandidateID ?? candidateID,
                label: "Alternative step",
                sourceDomain: .today
            )
        )
    }
}
