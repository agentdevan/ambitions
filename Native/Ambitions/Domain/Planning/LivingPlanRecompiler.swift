import Foundation

public struct LivingPlanRecompilePreview: Sendable, Equatable {
    public let affectedGoalID: String
    public let proposedSteps: [PlanStep]
    public let removedSteps: [String]
    public let receiptPreview: ActionReceipt
    public let isSafeToApply: Bool
    public let mutationPermissionRequired: Bool
    
    public init(
        affectedGoalID: String,
        proposedSteps: [PlanStep],
        removedSteps: [String],
        receiptPreview: ActionReceipt,
        isSafeToApply: Bool,
        mutationPermissionRequired: Bool
    ) {
        self.affectedGoalID = affectedGoalID
        self.proposedSteps = proposedSteps
        self.removedSteps = removedSteps
        self.receiptPreview = receiptPreview
        self.isSafeToApply = isSafeToApply
        self.mutationPermissionRequired = mutationPermissionRequired
    }
}

public struct LivingPlanRecompiler {
    let determinism: DeterministicGoalPlanner
    
    public init(determinism: DeterministicGoalPlanner = DeterministicGoalPlanner()) {
        self.determinism = determinism
    }
    
    public func previewRecompile(
        for goalID: String,
        rawTitle: String,
        currentSteps: [PlanStep],
        sourceUpdates: [String]
    ) -> LivingPlanRecompilePreview {
        let proposed = determinism.plan(for: rawTitle)
        
        let receipt = ActionReceipt(
            id: UUID().uuidString,
            resultState: .needsConfirmation,
            title: "Recompile Preview",
            summary: "Preview plan changes from source updates",
            sourceDomain: .plan,
            occurredAt: "2026-05-15T00:00:00Z", // Using a fixed or generated date string
            affectedObjects: [
                LifeGraphObjectReference(kind: .goal, id: goalID, label: rawTitle)
            ],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: .needsConfirmation,
                    summary: "Requires explicit mutation permission to apply plan updates."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .requiresConfirmation,
            safetyState: .confirmationRequired
        )
        
        return LivingPlanRecompilePreview(
            affectedGoalID: goalID,
            proposedSteps: proposed.steps,
            removedSteps: [], // In a full diff, we would calculate this against currentSteps
            receiptPreview: receipt,
            isSafeToApply: false, // Enforcing explicit UI mutation permission
            mutationPermissionRequired: true
        )
    }
}
