import Foundation

public struct LivingPlanSchemaMigration: Sendable, Equatable {
    public let fromVersion: Int
    public let toVersion: Int
    public let migrationImpact: LivingPlanMutationImpactLevel
    public let affectedGoalIDs: [String]
    
    public init(
        fromVersion: Int,
        toVersion: Int,
        migrationImpact: LivingPlanMutationImpactLevel,
        affectedGoalIDs: [String] = []
    ) {
        self.fromVersion = fromVersion
        self.toVersion = toVersion
        self.migrationImpact = migrationImpact
        self.affectedGoalIDs = affectedGoalIDs
    }
    
    public func requiresExplicitConfirmation() -> Bool {
        migrationImpact == .high || migrationImpact == .destructive
    }
    
    public func generateReceipt() -> ActionReceipt {
        ActionReceipt(
            id: UUID().uuidString,
            resultState: requiresExplicitConfirmation() ? .needsConfirmation : .completed,
            title: "Schema Migration",
            summary: "Migrating living plan schema from v\(fromVersion) to v\(toVersion)",
            sourceDomain: .plan,
            occurredAt: "2026-05-15T00:00:00Z",
            affectedObjects: [],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: requiresExplicitConfirmation() ? .needsConfirmation : .changedField,
                    summary: "Schema updated to v\(toVersion)"
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .requiresConfirmation, // Schema migrations usually require care to undo
            safetyState: requiresExplicitConfirmation() ? .confirmationRequired : .normal
        )
    }
}
