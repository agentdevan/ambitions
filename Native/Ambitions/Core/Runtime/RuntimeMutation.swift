import Foundation

struct RuntimeMutation: Sendable, Equatable, Identifiable {
    let id: String
    let command: AmbitionsCommand
    let validation: RuntimeValidationReport
    let stageMutation: StageMutation
    let userVisibleMutation: UserVisibleMutation

    init?(
        command: AmbitionsCommand,
        validation: RuntimeValidationReport,
        beforeSnapshot: String,
        afterSnapshot: String,
        targetSurface: StageMutationTargetSurface
    ) {
        guard validation.canMutate else { return nil }

        let affectedIDs = Self.affectedObjectIDs(command)
        let proof = MutationProof(
            artifactID: "runtime.proof.\(command.id)",
            label: "Proof artifact",
            localOnly: validation.privacyBoundary.localOnly
        )
        let receipt = MutationReceipt(
            receiptID: "runtime.receipt.\(command.id)",
            saved: true,
            inspectionLabel: "Receipt"
        )
        let announcement = MutationAccessibilityAnnouncement(
            message: Self.accessibilityAnnouncement(command),
            reasonIfSilent: nil
        )
        let stageMutation = StageMutation(
            runtimeMutationID: "runtime.mutation.\(command.id)",
            beforeSnapshot: beforeSnapshot,
            afterSnapshot: afterSnapshot,
            targetSurface: targetSurface,
            affectedObjectIDs: affectedIDs,
            visibleUserFacingChange: Self.visibleChange(command),
            motionEvent: Self.motionEvent(command),
            accessibilityAnnouncement: announcement,
            hapticIntent: "confirmation",
            undoAvailability: MutationUndo(isAvailable: true, label: "Undo"),
            proofArtifact: proof,
            receipt: receipt,
            safeFallback: "Keep the previous visible state and show the receipt for inspection."
        )

        self.id = stageMutation.runtimeMutationID
        self.command = command
        self.validation = validation
        self.stageMutation = stageMutation
        self.userVisibleMutation = UserVisibleMutation(
            stageMutation: stageMutation,
            headline: stageMutation.visibleUserFacingChange,
            detail: "Saved locally with proof available."
        )
    }

    var hasCompleteActionFlowProof: Bool {
        validation.canMutate &&
            stageMutation.isCanonComplete &&
            userVisibleMutation.isCanonComplete
    }

    private static func affectedObjectIDs(_ command: AmbitionsCommand) -> [String] {
        Array(Set([
            command.target.goalID,
            command.target.captureID,
            command.target.timeID,
            command.target.reviewID,
            command.target.stepID
        ].compactMap { $0 })).sorted()
    }

    private static func visibleChange(_ command: AmbitionsCommand) -> String {
        switch command.kind {
        case .quickCapture:
            return "Capture saved"
        case .startStepSession:
            return "Step started"
        case .completeAction:
            return "Step completed"
        case .scheduleItem, .createTimeItem:
            return "Time updated"
        case .recoverAction:
            return "Recovery updated"
        default:
            return "Ambitions updated"
        }
    }

    private static func motionEvent(_ command: AmbitionsCommand) -> String {
        "stage.motion.\(command.kind.rawValue)"
    }

    private static func accessibilityAnnouncement(_ command: AmbitionsCommand) -> String {
        "\(visibleChange(command)). Proof is available."
    }
}
