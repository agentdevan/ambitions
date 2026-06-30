import Foundation

extension ActionReceipt {

    static func rejectedCandidateSuppressedReceipt(
        id: String,
        candidateID: String,
        sourceStepID: String,
        sourceCandidateID: String?,
        recordedAt: String,
        suppressionReason: String
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
            title: "Rejected candidate suppressed",
            summary: "The rejected candidate will stay out of later local ranking.",
            sourceDomain: .today,
            occurredAt: recordedAt,
            affectedObjects: [stepReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).rejected-candidate-suppressed",
                    kind: .rejectedCandidateSuppressed,
                    object: stepReference,
                    fieldName: "suppressedCandidate",
                    newValueSummary: sourceCandidateID ?? candidateID,
                    summary: suppressionReason
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: LifeGraphObjectReference(
                kind: .step,
                id: sourceCandidateID ?? candidateID,
                label: "Suppressed candidate",
                sourceDomain: .today
            )
        )
    }


    static func preferenceLearnedReceipt(
        id: String,
        candidateID: String,
        sourceStepID: String,
        sourceCandidateID: String?,
        learnedPreferenceSummary: String,
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
            title: "Preference learned",
            summary: learnedPreferenceSummary,
            sourceDomain: .today,
            occurredAt: recordedAt,
            affectedObjects: [stepReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).preference-learned",
                    kind: .preferenceLearned,
                    object: stepReference,
                    fieldName: "preferenceLearning",
                    newValueSummary: sourceCandidateID ?? candidateID,
                    summary: learnedPreferenceSummary
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: LifeGraphObjectReference(
                kind: .step,
                id: sourceCandidateID ?? candidateID,
                label: "Preference learning",
                sourceDomain: .today
            )
        )
    }
}
