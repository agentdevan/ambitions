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
        guard Self.requiresTimeTodayCoupling(command) == false || timeMutation?.todayRecompute.recomputedToday == true else {
            return nil
        }

        let affectedIDs = Self.affectedObjectIDs(command, timeMutation: timeMutation)
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
            detail: timeMutation?.todayRecompute.summary ?? "Saved locally with proof available."
        )
        self.timeMutation = timeMutation
    }

    var hasCompleteActionFlowProof: Bool {
        validation.canMutate &&
            stageMutation.isCanonComplete &&
            userVisibleMutation.isCanonComplete
    }

    private static func requiresTimeTodayCoupling(_ command: AmbitionsCommand) -> Bool {
        switch command.kind {
        case .placeStepInTime, .protectTimeWindow, .correctTimeWindow:
            true
        default:
            false
        }
    }

    private static func affectedObjectIDs(_ command: AmbitionsCommand, timeMutation: TimeMutation?) -> [String] {
        Array(Set([
            command.target.goalID,
            command.target.captureID,
            command.target.timeID,
            command.target.reviewID,
            command.target.stepID
        ].compactMap { $0 } + (timeMutation?.affectedBucketIDs ?? []))).sorted()
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
