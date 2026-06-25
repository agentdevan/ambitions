import Foundation

enum StageMutationTargetSurface: String, Sendable, Equatable, CaseIterable {
    case today = "Today"
    case goals = "Goals"
    case time = "Time"
    case you = "You"
}

enum MutationMotionKind: String, Sendable, Equatable {
    case stageAction
    case closure
    case undo
}

struct MutationMotionEvent: Equatable, Sendable {
    let id: String
    let kind: MutationMotionKind
    let sourceMutationID: String
    let affectedObjectIDs: [String]

    var isTypedEvent: Bool {
        id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            sourceMutationID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            affectedObjectIDs.isEmpty == false
    }
}

struct StageMutation: Equatable, Sendable {
    let runtimeMutationID: String
    let beforeSnapshot: MutationSnapshotReference
    let afterSnapshot: MutationSnapshotReference
    let targetSurface: StageMutationTargetSurface
    let affectedObjectIDs: [String]
    let visibleUserFacingChange: String
    let typedMotionEvent: MutationMotionEvent
    let accessibilityAnnouncement: MutationAccessibilityAnnouncement
    let hapticIntent: String
    let undoAvailability: MutationUndo
    let proofArtifact: MutationProof
    let receipt: MutationReceipt
    let safeFallback: String

    var isCanonComplete: Bool {
        runtimeMutationID.isEmpty == false &&
            beforeSnapshot.isTypedReference &&
            afterSnapshot.isTypedReference &&
            affectedObjectIDs.isEmpty == false &&
            visibleUserFacingChange.isEmpty == false &&
            typedMotionEvent.isTypedEvent &&
            (accessibilityAnnouncement.message.isEmpty == false || accessibilityAnnouncement.reasonIfSilent?.isEmpty == false) &&
            hapticIntent.isEmpty == false &&
            undoAvailability.isTypedContract &&
            proofArtifact.isTypedAvailable &&
            receipt.isTypedSaved &&
            safeFallback.isEmpty == false
    }

    var motionEvent: String {
        typedMotionEvent.id
    }

    var beforeSnapshotSummary: String {
        beforeSnapshot.summary
    }

    var afterSnapshotSummary: String {
        afterSnapshot.summary
    }
}
