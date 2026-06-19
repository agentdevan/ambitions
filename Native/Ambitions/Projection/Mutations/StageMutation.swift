import Foundation

enum StageMutationTargetSurface: String, Sendable, Equatable {
    case today = "Today"
    case goals = "Goals"
    case time = "Time"
    case you = "You"
}

struct MutationProof: Equatable, Sendable {
    let artifactID: String
    let label: String
    let localOnly: Bool
}

struct MutationReceipt: Equatable, Sendable {
    let receiptID: String
    let saved: Bool
    let inspectionLabel: String
}

struct MutationUndo: Equatable, Sendable {
    let isAvailable: Bool
    let label: String
}

struct MutationAccessibilityAnnouncement: Equatable, Sendable {
    let message: String
    let reasonIfSilent: String?
}

struct StageMutation: Equatable, Sendable {
    let runtimeMutationID: String
    let beforeSnapshot: String
    let afterSnapshot: String
    let targetSurface: StageMutationTargetSurface
    let affectedObjectIDs: [String]
    let visibleUserFacingChange: String
    let motionEvent: String
    let accessibilityAnnouncement: MutationAccessibilityAnnouncement
    let hapticIntent: String
    let undoAvailability: MutationUndo
    let proofArtifact: MutationProof
    let receipt: MutationReceipt
    let safeFallback: String

    var isCanonComplete: Bool {
        runtimeMutationID.isEmpty == false &&
            beforeSnapshot.isEmpty == false &&
            afterSnapshot.isEmpty == false &&
            affectedObjectIDs.isEmpty == false &&
            visibleUserFacingChange.isEmpty == false &&
            motionEvent.isEmpty == false &&
            (accessibilityAnnouncement.message.isEmpty == false || accessibilityAnnouncement.reasonIfSilent?.isEmpty == false) &&
            hapticIntent.isEmpty == false &&
            undoAvailability.label.isEmpty == false &&
            proofArtifact.artifactID.isEmpty == false &&
            receipt.receiptID.isEmpty == false &&
            safeFallback.isEmpty == false
    }
}

struct UserVisibleMutation: Equatable, Sendable {
    let stageMutation: StageMutation
    let headline: String
    let detail: String

    var isCanonComplete: Bool {
        stageMutation.isCanonComplete && headline.isEmpty == false && detail.isEmpty == false
    }
}
