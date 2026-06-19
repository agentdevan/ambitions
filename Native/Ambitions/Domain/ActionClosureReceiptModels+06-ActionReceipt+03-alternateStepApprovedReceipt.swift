import Foundation

extension ActionReceipt {

    static func alternateStepApprovedReceipt(
        id: String,
        candidateID: String,
        sourceStepID: String,
        sourceCandidateID: String?,
        approvedStepID: String,
        approvedStepTitle: String,
        timelineImpactSummary: String,
        recordedAt: String,
        needsApproval: Bool = false
    ) -> ActionReceipt {
        let sourceReference = LifeGraphObjectReference(
            kind: .step,
            id: sourceStepID,
            label: "Recommended step",
            sourceDomain: .today
        )
        let approvedReference = LifeGraphObjectReference(
            kind: .step,
            id: approvedStepID,
            label: approvedStepTitle,
            sourceDomain: .today
        )
        return ActionReceipt(
            id: id,
            resultState: needsApproval ? .needsConfirmation : .changed,
            title: "Alternative approved",
            summary: timelineImpactSummary,
            sourceDomain: .today,
            occurredAt: recordedAt,
            affectedObjects: [sourceReference, approvedReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).alternate-step-approved",
                    kind: .alternateStepApproved,
                    object: approvedReference,
                    fieldName: "approvedStep",
                    newValueSummary: approvedStepID,
                    summary: timelineImpactSummary
                )
            ],
            nextAction: needsApproval ? ActionReceiptNextAction(kind: .openTime, title: "Review time", destination: .time) : nil,
            correctionAvailability: .availableWithReason,
            undoAvailability: needsApproval ? .requiresConfirmation : .availableLocal,
            safetyState: needsApproval ? .confirmationRequired : .normal,
            sourceObject: LifeGraphObjectReference(
                kind: .step,
                id: sourceCandidateID ?? candidateID,
                label: "Alternative step",
                sourceDomain: .today
            )
        )
    }


    static func deadlinePressureChangedReceipt(
        id: String,
        candidateID: String,
        sourceStepID: String,
        sourceCandidateID: String?,
        previousPressure: String,
        newPressure: String,
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
            title: "Deadline pressure changed",
            summary: timelineImpactSummary,
            sourceDomain: .today,
            occurredAt: recordedAt,
            affectedObjects: [stepReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).deadline-pressure-changed",
                    kind: .deadlinePressureChanged,
                    object: stepReference,
                    fieldName: "deadlinePressure",
                    previousValueSummary: previousPressure,
                    newValueSummary: newPressure,
                    summary: timelineImpactSummary
                )
            ],
            correctionAvailability: .availableWithReason,
            undoAvailability: .availableLocal,
            sourceObject: LifeGraphObjectReference(
                kind: .step,
                id: sourceCandidateID ?? candidateID,
                label: "Deadline pressure",
                sourceDomain: .today
            )
        )
    }


    static func dependencyBlockedReceipt(
        id: String,
        candidateID: String,
        sourceStepID: String,
        sourceCandidateID: String?,
        dependencyStepIDs: [String],
        blockedBy: String,
        timelineImpactSummary: String,
        recordedAt: String
    ) -> ActionReceipt {
        let stepReference = LifeGraphObjectReference(
            kind: .step,
            id: sourceStepID,
            label: "Recommended step",
            sourceDomain: .today
        )
        let dependencySummary = dependencyStepIDs.isEmpty
            ? blockedBy
            : "\(blockedBy) (\(dependencyStepIDs.joined(separator: ", ")))"
        return ActionReceipt(
            id: id,
            resultState: .needsConfirmation,
            title: "Dependency blocked",
            summary: timelineImpactSummary,
            sourceDomain: .today,
            occurredAt: recordedAt,
            affectedObjects: [stepReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).dependency-blocked",
                    kind: .dependencyBlocked,
                    object: stepReference,
                    fieldName: "dependencyState",
                    previousValueSummary: "clear",
                    newValueSummary: dependencySummary,
                    summary: timelineImpactSummary
                )
            ],
            nextAction: ActionReceiptNextAction(kind: .reviewGoal, title: "Review dependencies", destination: .goalDetail),
            correctionAvailability: .availableWithReason,
            undoAvailability: .requiresConfirmation,
            safetyState: .confirmationRequired,
            sourceObject: LifeGraphObjectReference(
                kind: .step,
                id: sourceCandidateID ?? candidateID,
                label: "Dependency graph",
                sourceDomain: .today
            )
        )
    }


    static func priorityPressureChangedReceipt(
        id: String,
        candidateID: String,
        sourceStepID: String,
        sourceCandidateID: String?,
        previousPressure: String,
        newPressure: String,
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
            title: "Priority pressure changed",
            summary: timelineImpactSummary,
            sourceDomain: .today,
            occurredAt: recordedAt,
            affectedObjects: [stepReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).priority-pressure-changed",
                    kind: .priorityPressureChanged,
                    object: stepReference,
                    fieldName: "priorityPressure",
                    previousValueSummary: previousPressure,
                    newValueSummary: newPressure,
                    summary: timelineImpactSummary
                )
            ],
            correctionAvailability: .availableWithReason,
            undoAvailability: .availableLocal,
            sourceObject: LifeGraphObjectReference(
                kind: .step,
                id: sourceCandidateID ?? candidateID,
                label: "Priority pressure",
                sourceDomain: .today
            )
        )
    }


    static func timelineStillOnTrackReceipt(
        id: String,
        candidateID: String,
        sourceStepID: String,
        sourceCandidateID: String?,
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
            title: "Still on track",
            summary: timelineImpactSummary,
            sourceDomain: .today,
            occurredAt: recordedAt,
            affectedObjects: [stepReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).timeline-still-on-track",
                    kind: .timelineStillOnTrack,
                    object: stepReference,
                    fieldName: "timelineStatus",
                    newValueSummary: "on_track",
                    summary: timelineImpactSummary
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: LifeGraphObjectReference(
                kind: .step,
                id: sourceCandidateID ?? candidateID,
                label: "Timeline status",
                sourceDomain: .today
            )
        )
    }


    static func deadlineAtRiskReceipt(
        id: String,
        candidateID: String,
        sourceStepID: String,
        sourceCandidateID: String?,
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
            resultState: .needsConfirmation,
            title: "Deadline at risk",
            summary: timelineImpactSummary,
            sourceDomain: .today,
            occurredAt: recordedAt,
            affectedObjects: [stepReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).deadline-at-risk",
                    kind: .deadlineAtRisk,
                    object: stepReference,
                    fieldName: "deadlineRisk",
                    newValueSummary: "at_risk",
                    summary: timelineImpactSummary
                )
            ],
            nextAction: ActionReceiptNextAction(kind: .openTime, title: "Adjust time", destination: .time),
            correctionAvailability: .availableWithReason,
            undoAvailability: .requiresConfirmation,
            safetyState: .confirmationRequired,
            sourceObject: LifeGraphObjectReference(
                kind: .step,
                id: sourceCandidateID ?? candidateID,
                label: "Deadline risk",
                sourceDomain: .today
            )
        )
    }


    static func scopeReviewSuggestedReceipt(
        id: String,
        candidateID: String,
        sourceStepID: String,
        sourceCandidateID: String?,
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
            resultState: .needsConfirmation,
            title: "Scope review suggested",
            summary: timelineImpactSummary,
            sourceDomain: .today,
            occurredAt: recordedAt,
            affectedObjects: [stepReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "\(id).scope-review-suggested",
                    kind: .scopeReviewSuggested,
                    object: stepReference,
                    fieldName: "scopeReview",
                    newValueSummary: "suggested",
                    summary: timelineImpactSummary
                )
            ],
            nextAction: ActionReceiptNextAction(kind: .reviewGoal, title: "Review scope", destination: .goalDetail),
            correctionAvailability: .availableWithReason,
            undoAvailability: .requiresConfirmation,
            safetyState: .confirmationRequired,
            sourceObject: LifeGraphObjectReference(
                kind: .step,
                id: sourceCandidateID ?? candidateID,
                label: "Scope review",
                sourceDomain: .today
            )
        )
    }
}
