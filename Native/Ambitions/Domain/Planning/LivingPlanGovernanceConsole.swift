import Foundation

public struct LivingPlanGovernanceAction: Sendable, Equatable, Identifiable {
    public let id: String
    public let actionType: String
    public let description: String
    public let requiresConfirmation: Bool
    
    public init(id: String = UUID().uuidString, actionType: String, description: String, requiresConfirmation: Bool) {
        self.id = id
        self.actionType = actionType
        self.description = description
        self.requiresConfirmation = requiresConfirmation
    }
}

public struct LivingPlanGovernanceConsole: Sendable, Equatable {
    public init() {}
    
    public func scanForMaintenance() -> [LivingPlanGovernanceAction] {
        return [
            LivingPlanGovernanceAction(
                actionType: "reconcile_receipts",
                description: "Reconcile detached mutation receipts from previous sync conflicts.",
                requiresConfirmation: true
            ),
            LivingPlanGovernanceAction(
                actionType: "prune_orphans",
                description: "Remove plan steps linked to deleted goals.",
                requiresConfirmation: true
            )
        ]
    }
    
    public func generateReceipt(for action: LivingPlanGovernanceAction) -> ActionReceipt {
        return ActionReceipt(
            id: UUID().uuidString,
            resultState: action.requiresConfirmation ? .needsConfirmation : .completed,
            title: "Governance Maintenance",
            summary: "Requested execution of governance action: \(action.actionType)",
            sourceDomain: .plan,
            occurredAt: "2026-05-15T00:00:00Z",
            affectedObjects: [],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: action.requiresConfirmation ? .needsConfirmation : .changedField,
                    summary: action.requiresConfirmation ? "Requires confirmation before running \(action.actionType)." : "Executed \(action.actionType)."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .requiresConfirmation,
            safetyState: action.requiresConfirmation ? .confirmationRequired : .normal
        )
    }
}
