import Foundation

enum ProtectedPlacementReviewOutcome: String, Sendable, Hashable {
    case moved = "Step moved"
    case kept = "Kept as is"
}

struct ProtectedPlacementReviewState: Identifiable, Sendable, Hashable {
    let id: String
    let action: TimeFieldMutationAction
    let selectedMark: LifeShapeSemanticMark?
    let stepID: String
    let stepTitle: String
    let currentPlacementLabel: String
    let proposedPlacementLabel: String
    let reasonLabel: String
    let decision: ProtectedStepPlacementDecision

    var accessibilityValue: String {
        [
            "Step: \(stepTitle)",
            "Current placement: \(currentPlacementLabel)",
            "Proposed placement: \(proposedPlacementLabel)",
            reasonLabel,
            "Ambitions will not move this without approval"
        ].joined(separator: ". ")
    }
}
