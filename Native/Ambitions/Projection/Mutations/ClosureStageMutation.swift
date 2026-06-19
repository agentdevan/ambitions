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
        let policy = ClosureEngine().consequence(
            for: record.outcome,
            stepTitle: stepTitle,
            receiptSaved: receiptSaved
        )
        let affectedObjectIDs = [record.goalID, record.stepID].compactMap { $0 }
        let runtimeMutationID = "runtime.closure.\(record.id)"
        let receiptID = "receipt.closure.\(record.id)"
        let proofID = "proof.closure.\(record.id)"
        let stageMutation = StageMutation(
            runtimeMutationID: runtimeMutationID,
            beforeSnapshot: "Today before closure \(record.id)",
            afterSnapshot: "Today after closure \(record.outcome.rawValue)",
            targetSurface: .today,
            affectedObjectIDs: affectedObjectIDs.isEmpty ? [record.id] : affectedObjectIDs,
            visibleUserFacingChange: policy.visibleChange,
            motionEvent: "closure.\(record.outcome.rawValue)",
            accessibilityAnnouncement: MutationAccessibilityAnnouncement(
                message: policy.accessibilityAnnouncement,
                reasonIfSilent: nil
            ),
            hapticIntent: policy.hapticIntent,
            undoAvailability: MutationUndo(
                isAvailable: record.outcome.undoAvailability.isAvailable,
                label: policy.undoLabel
            ),
            proofArtifact: MutationProof(
                artifactID: proofID,
                label: policy.proofArtifactLabel,
                localOnly: true
            ),
            receipt: MutationReceipt(
                receiptID: receiptID,
                saved: receiptSaved,
                inspectionLabel: receiptSaved ? "Local receipt history" : "Local receipt preview"
            ),
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
