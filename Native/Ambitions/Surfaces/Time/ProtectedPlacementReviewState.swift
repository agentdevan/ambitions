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
    let priorityDecision: PriorityPlacementDecision

    var accessibilityValue: String {
        [
            "Step: \(stepTitle)",
            "Current placement: \(currentPlacementLabel)",
            "Proposed placement: \(proposedPlacementLabel)",
            "Priority: \(priorityDecision.priority.userFacingLabel)",
            reasonLabel,
            priorityDecision.reviewNote,
            "Available priority choices: Low, Normal, High",
            "Ambitions will not move this without approval"
        ].joined(separator: ". ")
    }

    func updatingPriorityDecision(_ priorityDecision: PriorityPlacementDecision) -> ProtectedPlacementReviewState {
        ProtectedPlacementReviewState(
            id: id,
            action: action,
            selectedMark: selectedMark,
            stepID: stepID,
            stepTitle: stepTitle,
            currentPlacementLabel: currentPlacementLabel,
            proposedPlacementLabel: proposedPlacementLabel,
            reasonLabel: reasonLabel,
            decision: decision,
            priorityDecision: priorityDecision
        )
    }
}
