import Foundation

struct ClosureStageMutation: Equatable, Sendable {
    let id: String
    let record: ClosureMutationRecord
    let policy: ClosureConsequence
    let receiptSaved: Bool
    let visibleChange: String
    let stageMutation: StageMutation
    let userVisibleMutation: UserVisibleMutation

    init(record: ClosureMutationRecord, stepTitle: String, receiptSaved: Bool) {
        let mutationClassification = ClosureOutcome.option(for: record.outcome)?.mutationClassification
        let policy = ClosureEngine().consequence(
            for: record.outcome,
            stepTitle: stepTitle,
            receiptSaved: receiptSaved
        )
        let affectedObjectIDs = [record.goalID, record.stepID].compactMap { $0 }
        let runtimeMutationID = "runtime.closure.\(record.id)"
        let receiptID = "receipt.closure.\(record.id)"
        let proofID = "proof.closure.\(record.id)"
        let targetIDs = affectedObjectIDs.isEmpty ? [record.id] : affectedObjectIDs
        let action = MutationActionReference(
            commandID: "closure.\(record.id)",
            commandKind: .completeAction,
            source: .today,
            targetObjectIDs: targetIDs
        )
        let beforeReference = MutationSnapshotReference(
            id: "snapshot.closure.before.\(record.id)",
            surface: .today,
            summary: "Today before closure \(record.id)"
        )
        let afterReference = MutationSnapshotReference(
            id: "snapshot.closure.after.\(record.id)",
            surface: .today,
            summary: "Today after closure \(record.outcome.rawValue)"
        )
        let proof = receiptSaved
            ? MutationProof(
                artifactID: proofID,
                label: policy.proofArtifactLabel,
                localOnly: true,
                beforeSnapshot: beforeReference,
                action: action,
                afterSnapshot: afterReference
            )
            : MutationProof.unavailable(
                label: policy.proofArtifactLabel,
                localOnly: true,
                beforeSnapshot: beforeReference,
                action: action,
                fallbackReason: "Closure receipt was not saved, so proof remains a local preview."
            )
        let receipt = receiptSaved
            ? MutationReceipt(
                receiptID: receiptID,
                saved: true,
                inspectionLabel: "Local receipt history",
                proofArtifactID: proofID,
                action: action
            )
            : MutationReceipt.unavailable(
                inspectionLabel: "Local receipt preview",
                action: action,
                fallbackReason: "Receipt history was unavailable for this closure."
            )
        let stageMutation = StageMutation(
            runtimeMutationID: runtimeMutationID,
            beforeSnapshot: beforeReference.summary,
            afterSnapshot: afterReference.summary,
            targetSurface: .today,
            affectedObjectIDs: targetIDs,
            visibleUserFacingChange: policy.visibleChange,
            typedMotionEvent: MutationMotionEvent(
                id: "closure.\(record.outcome.rawValue)",
                kind: .closure,
                sourceMutationID: runtimeMutationID,
                affectedObjectIDs: targetIDs
            ),
            accessibilityAnnouncement: MutationAccessibilityAnnouncement(
                message: policy.accessibilityAnnouncement,
                reasonIfSilent: nil
            ),
            hapticIntent: policy.hapticIntent,
            undoAvailability: mutationClassification?.undo.isAvailable == true
                ? MutationUndo(
                    isAvailable: true,
                    label: policy.undoLabel,
                    restoresSnapshot: beforeReference,
                    sourceReceiptID: receiptID
                )
                : .unavailable(label: policy.undoLabel, reason: "This closure outcome requires review instead of direct undo."),
            proofArtifact: proof,
            receipt: receipt,
            safeFallback: policy.safeFallback
        )

        self.id = "today.stage-mutation.\(record.id)"
        self.record = record
        self.policy = policy
        self.receiptSaved = receiptSaved
        self.visibleChange = receiptSaved ? policy.visibleChange : "Closure preview only: \(policy.closureSubtitle)"
        self.stageMutation = stageMutation
        self.userVisibleMutation = UserVisibleMutation(
            stageMutation: stageMutation,
            headline: policy.closureTitle,
            detail: policy.closureSubtitle
        )
    }
}

typealias TodayClosureStageMutation = ClosureStageMutation
