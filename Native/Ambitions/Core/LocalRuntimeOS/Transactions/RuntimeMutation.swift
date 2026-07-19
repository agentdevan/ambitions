import Foundation

struct RuntimeMutation: Sendable, Equatable, Identifiable {
    let id: String
    let command: AmbitionsCommand
    let validation: RuntimeValidationReport
    let stageMutation: StageMutation
    let userVisibleMutation: UserVisibleMutation
    let timeMutation: TimeMutation?

    init?(
        command: AmbitionsCommand,
        validation: RuntimeValidationReport,
        beforeSnapshot: String,
        afterSnapshot: String,
        targetSurface: StageMutationTargetSurface,
        timeMutation: TimeMutation? = nil
    ) {
        guard validation.canMutate else { return nil }
        let affectedIDs = Self.affectedObjectIDs(command, timeMutation: timeMutation)
        let actionReference = MutationActionReference(
            commandID: command.id,
            commandKind: command.kind,
            source: command.source,
            targetObjectIDs: affectedIDs
        )
        let beforeReference = MutationSnapshotReference(
            id: "snapshot.before.\(command.id)",
            surface: targetSurface,
            summary: beforeSnapshot
        )
        let afterReference = MutationSnapshotReference(
            id: "snapshot.after.\(command.id)",
            surface: targetSurface,
            summary: afterSnapshot
        )
        let proof = MutationProof(
            artifactID: "runtime.proof.\(command.id)",
            label: "Proof artifact",
            localOnly: validation.privacyBoundary.localOnly,
            beforeSnapshot: beforeReference,
            action: actionReference,
            afterSnapshot: afterReference
        )
        let receiptID = "runtime.receipt.\(command.id)"
        let receipt = MutationReceipt(
            receiptID: receiptID,
            saved: true,
            inspectionLabel: "Receipt",
            proofArtifactID: proof.artifactID,
            action: actionReference
        )
        let announcement = MutationAccessibilityAnnouncement(
            message: Self.accessibilityAnnouncement(command),
            reasonIfSilent: nil
        )
        let runtimeMutationID = "runtime.mutation.\(command.id)"
        let stageMutation = StageMutation(
            runtimeMutationID: runtimeMutationID,
            beforeSnapshot: beforeReference,
            afterSnapshot: afterReference,
            targetSurface: targetSurface,
            affectedObjectIDs: affectedIDs,
            visibleUserFacingChange: Self.visibleChange(command),
            typedMotionEvent: MutationMotionEvent(
                id: Self.motionEvent(command),
                kind: .stageAction,
                sourceMutationID: runtimeMutationID,
                affectedObjectIDs: affectedIDs
            ),
            accessibilityAnnouncement: announcement,
            hapticIntent: "confirmation",
            undoAvailability: MutationUndo(
                isAvailable: true,
                label: "Undo",
                restoresSnapshot: beforeReference,
                sourceReceiptID: receiptID
            ),
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
            detail: timeMutation?.todayRecompute.summary ?? "Saved locally with proof available."
        )
        self.timeMutation = timeMutation
    }

    var hasCompleteActionFlowProof: Bool {
        validation.canMutate &&
            stageMutation.isCanonComplete &&
            userVisibleMutation.isCanonComplete
    }

    private static func affectedObjectIDs(_ command: AmbitionsCommand, timeMutation: TimeMutation?) -> [String] {
        var objectIDs = [
            command.target.goalID,
            command.target.captureID,
            command.target.timeID,
            command.target.reviewID,
            command.target.stepID
        ].compactMap { $0 } + (timeMutation?.affectedBucketIDs ?? [])
        if command.kind == .updateUserPreferences {
            objectIDs.append(RuntimeTransactionObjectFacts.youPreferencesObjectID)
        }
        return Array(Set(objectIDs)).sorted()
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
        case .placeStepInTime:
            return "Step placed"
        case .protectTimeWindow:
            return "Window protected"
        case .correctTimeWindow:
            if command.payload.metadata["correctionKind"] == TimeMutationActionKind.makeTodayLighter.rawValue {
                return "Today made lighter"
            }
            if command.payload.metadata["correctionKind"] == TimeMutationActionKind.addBuffer.rawValue {
                return "Buffer added"
            }
            return "Time corrected"
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
