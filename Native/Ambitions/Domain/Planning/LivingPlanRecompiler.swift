import Foundation

public struct LivingPlanRecompilePreview: Sendable, Equatable {
    public let affectedGoalID: String
    public let proposedSteps: [PlanStep]
    public let removedSteps: [String]
    public let receiptPreview: ActionReceipt
    public let isSafeToApply: Bool
    public let mutationPermissionRequired: Bool
    public let claimImpacts: [String: SourceAtlasClaimState]
    
    public init(
        affectedGoalID: String,
        proposedSteps: [PlanStep],
        removedSteps: [String],
        receiptPreview: ActionReceipt,
        isSafeToApply: Bool,
        mutationPermissionRequired: Bool,
        claimImpacts: [String: SourceAtlasClaimState] = [:]
    ) {
        self.affectedGoalID = affectedGoalID
        self.proposedSteps = proposedSteps
        self.removedSteps = removedSteps
        self.receiptPreview = receiptPreview
        self.isSafeToApply = isSafeToApply
        self.mutationPermissionRequired = mutationPermissionRequired
        self.claimImpacts = claimImpacts
    }
}

public struct LivingPlanRecompiler {
    let determinism: DeterministicGoalPlanner
    
    public init(determinism: DeterministicGoalPlanner = DeterministicGoalPlanner()) {
        self.determinism = determinism
    }
    
    /// Previews a plan recompile based on goal title and potentially updated source claims.
    public func previewRecompile(
        for goalID: String,
        rawTitle: String,
        currentSteps: [PlanStep],
        sourceClaims: [SourceAtlasClaim] = []
    ) -> LivingPlanRecompilePreview {
        let proposed = determinism.plan(for: rawTitle)
        
        // Detect blast radius from source claims
        var impacts: [String: SourceAtlasClaimState] = [:]
        var blastRadiusSummary = ""
        
        for claim in sourceClaims {
            impacts[claim.id] = claim.state
            if claim.state.isBlockingState {
                blastRadiusSummary += "Claim '\(claim.text)' is now in blocking state (\(claim.state.rawValue)). "
            }
        }
        
        let receipt = ActionReceipt(
            id: UUID().uuidString,
            resultState: .needsConfirmation,
            title: "Plan Recompile Preview",
            summary: blastRadiusSummary.isEmpty ? "Preview plan changes for '\(rawTitle)'" : "Source updates detected: \(blastRadiusSummary)",
            sourceDomain: .plan,
            occurredAt: "2026-05-16T00:00:00Z",
            affectedObjects: [
                LifeGraphObjectReference(kind: .goal, id: goalID, label: rawTitle)
            ],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: .needsConfirmation,
                    summary: "Plan recompile required due to \(sourceClaims.count) source claim updates."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .requiresConfirmation,
            safetyState: .confirmationRequired
        )
        
        // Detect removed steps (naive ID-based check for this manifest contract)
        let proposedIDs = Set(proposed.steps.map(\.id))
        let removedIDs = currentSteps.map(\.id).filter { !proposedIDs.contains($0) }
        
        return LivingPlanRecompilePreview(
            affectedGoalID: goalID,
            proposedSteps: proposed.steps,
            removedSteps: removedIDs,
            receiptPreview: receipt,
            isSafeToApply: false,
            mutationPermissionRequired: true,
            claimImpacts: impacts
        )
    }
}
