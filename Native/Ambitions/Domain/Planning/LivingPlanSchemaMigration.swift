import Foundation

/// Schema migration logic for living plans, ensuring deterministic upgrades.
public struct LivingPlanSchemaMigration: Sendable, Equatable {
    public let fromVersion: Int
    public let toVersion: Int
    public let migrationImpact: LivingPlanMutationImpactLevel
    public let affectedGoalIDs: [String]
    /// Indicates if the archive is encrypted as per LDI18 manifest.
    public let isEncryptedArchive: Bool
    
    public init(
        fromVersion: Int,
        toVersion: Int,
        migrationImpact: LivingPlanMutationImpactLevel,
        affectedGoalIDs: [String] = [],
        isEncryptedArchive: Bool = true
    ) {
        self.fromVersion = fromVersion
        self.toVersion = toVersion
        self.migrationImpact = migrationImpact
        self.affectedGoalIDs = affectedGoalIDs
        self.isEncryptedArchive = isEncryptedArchive
    }
    
    public func requiresExplicitConfirmation() -> Bool {
        // Impact Level 4 (Destructive) or Level 5 (Critical) require explicit user confirmation.
        migrationImpact.rawValue >= LivingPlanMutationImpactLevel.level4.rawValue
    }
    
    public func generateReceipt() -> ActionReceipt {
        let confirmationNeeded = requiresExplicitConfirmation()
        
        return ActionReceipt(
            id: UUID().uuidString,
            resultState: confirmationNeeded ? .needsConfirmation : .completed,
            title: "Schema Migration (v\(fromVersion) -> v\(toVersion))",
            summary: confirmationNeeded 
                ? "Migration paused: Destructive changes detected in living plan schema."
                : "Schema migration completed successfully for \(affectedGoalIDs.count) goals.",
            sourceDomain: .system,
            occurredAt: "2026-05-16T00:00:00Z",
            affectedObjects: affectedGoalIDs.map { LifeGraphObjectReference(kind: .goal, id: $0, label: "Goal") },
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: confirmationNeeded ? .needsConfirmation : .changedField,
                    summary: "Schema updated to v\(toVersion) (Encryption: \(isEncryptedArchive ? "ON" : "OFF"))"
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .requiresConfirmation,
            safetyState: confirmationNeeded ? .confirmationRequired : .normal
        )
    }
}
