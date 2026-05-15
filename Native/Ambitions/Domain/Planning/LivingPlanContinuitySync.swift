import Foundation

public struct LivingPlanContinuitySync: Sendable, Equatable {
    public let syncID: String
    public let lastSyncedAt: Date
    public let pendingChanges: [LivingPlanMutationPermission]
    public let isSyncRequired: Bool
    
    public init(
        syncID: String = UUID().uuidString,
        lastSyncedAt: Date = Date(),
        pendingChanges: [LivingPlanMutationPermission] = [],
        isSyncRequired: Bool = false
    ) {
        self.syncID = syncID
        self.lastSyncedAt = lastSyncedAt
        self.pendingChanges = pendingChanges
        self.isSyncRequired = isSyncRequired
    }
    
    public func requiresExplicitConfirmation() -> Bool {
        pendingChanges.contains(where: { $0.requiresExplicitConfirmation })
    }
    
    public func generateReceipt() -> ActionReceipt {
        ActionReceipt(
            id: UUID().uuidString,
            resultState: requiresExplicitConfirmation() ? .needsConfirmation : .noOp,
            title: "Continuity Sync",
            summary: "Synchronizing plan continuity across domains.",
            sourceDomain: .plan,
            occurredAt: "2026-05-15T00:00:00Z", // Timestamp
            affectedObjects: [],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: requiresExplicitConfirmation() ? .needsConfirmation : .noChange,
                    summary: "Continuity sync evaluated."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            safetyState: requiresExplicitConfirmation() ? .confirmationRequired : .normal
        )
    }
}
