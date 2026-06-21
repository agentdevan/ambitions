import Foundation

enum StageMutationTargetSurface: String, Sendable, Equatable, CaseIterable {
    case today = "Today"
    case goals = "Goals"
    case time = "Time"
    case you = "You"
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
