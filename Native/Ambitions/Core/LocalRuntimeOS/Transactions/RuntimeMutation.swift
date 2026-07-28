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
            commandPayload: command.typedPayload,
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
        if case .profile = command.typedPayload {
            objectIDs.append(RuntimeTransactionObjectFacts.youPreferencesObjectID)
        }
        return Array(Set(objectIDs)).sorted()
    }

    private static func visibleChange(_ command: AmbitionsCommand) -> String {
        switch command.typedPayload {
        case let .capture(value):
            if case .quickCapture = value.action { return "Capture saved" }
            return "Capture updated"
        case let .step(value):
            switch value.action {
            case .startSession: return "Step started"
            case .complete: return "Step completed"
            case .todayGoalStep: return "Step action recorded"
            case .recover: return "Recovery updated"
            case .delay, .split: return "Step updated"
            }
        case let .schedule(value):
            switch value.action {
            case .placeStep: return "Step placed"
            case .protectWindow: return "Window protected"
            case let .correctWindow(intent):
                if intent.action == .makeTodayLighter { return "Today made lighter" }
                if intent.action == .addBuffer { return "Buffer added" }
                return "Time corrected"
            case .undo: return "Time change undone"
            default: return "Time updated"
            }
        case .repair: return "Recovery updated"
        case .goal, .reminder, .profile, .history, .importDeletion, .externalOperation, .attachment:
            return "Ambitions updated"
        case .compensation:
            return "Canonical compensation required"
        }
    }

    private static func motionEvent(_ command: AmbitionsCommand) -> String {
        "stage.motion.\(command.typedPayload.diagnosticFamily).\(command.typedPayload.diagnosticCase)"
    }

    private static func accessibilityAnnouncement(_ command: AmbitionsCommand) -> String {
        "\(visibleChange(command)). Proof is available."
    }
}
