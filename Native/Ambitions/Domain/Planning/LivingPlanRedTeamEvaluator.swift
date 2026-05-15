import Foundation

public struct LivingPlanRedTeamIssue: Sendable, Equatable, Identifiable {
    public let id: String
    public let goalID: String
    public let title: String
    public let summary: String
    public let impactLevel: LivingPlanMutationImpactLevel
    
    public init(id: String = UUID().uuidString, goalID: String, title: String, summary: String, impactLevel: LivingPlanMutationImpactLevel) {
        self.id = id
        self.goalID = goalID
        self.title = title
        self.summary = summary
        self.impactLevel = impactLevel
    }
}

public struct LivingPlanRedTeamEvaluator: Sendable, Equatable {
    public init() {}
    
    public func evaluate(goalIDs: [String]) -> [LivingPlanRedTeamIssue] {
        guard !goalIDs.isEmpty else { return [] }
        
        // Mock deterministic structural evaluation returning a generic "Vague Scope" warning
        // In real execution, this evaluates exact plan shape and signals missing boundaries
        return goalIDs.map { goalID in
            LivingPlanRedTeamIssue(
                goalID: goalID,
                title: "Vague Scope",
                summary: "Goal lacks explicitly defined completion boundaries.",
                impactLevel: .medium
            )
        }
    }
    
    public func generateReceipt(for issues: [LivingPlanRedTeamIssue]) -> ActionReceipt {
        let needsConfirmation = !issues.isEmpty
        
        return ActionReceipt(
            id: UUID().uuidString,
            resultState: needsConfirmation ? .needsConfirmation : .noOp,
            title: "Red-Team Evaluation",
            summary: "Evaluated plans for structural weaknesses and vague bounds.",
            sourceDomain: .plan,
            occurredAt: "2026-05-15T00:00:00Z",
            affectedObjects: [],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: needsConfirmation ? .needsConfirmation : .noChange,
                    summary: needsConfirmation ? "Found \(issues.count) potential plan weaknesses." : "No structural issues found."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            safetyState: needsConfirmation ? .confirmationRequired : .normal
        )
    }
}
