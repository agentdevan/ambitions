import Foundation

/// Privacy policy for continuity sync, enforcing "most-restrictive-wins" as per LDI17 manifest.
enum SyncPrivacyPolicy: String, Codable, Sendable {
    /// Data never leaves the local device.
    case localOnly = "local_only"
    /// Data is synced to the user's private CloudKit container.
    case privateCloud = "private_cloud"
    /// In case of conflict, the most restrictive policy (local-only) wins.
    case mostRestrictiveWins = "most_restrictive_wins"
}

struct LivingPlanContinuitySync: Sendable, Equatable {
    let syncID: String
    let lastSyncedAt: Date
    let pendingChanges: [LivingPlanMutationPermission]
    let isSyncRequired: Bool
    let privacyPolicy: SyncPrivacyPolicy
    
    init(
        syncID: String = UUID().uuidString,
        lastSyncedAt: Date = Date(),
        pendingChanges: [LivingPlanMutationPermission] = [],
        isSyncRequired: Bool = false,
        privacyPolicy: SyncPrivacyPolicy = .mostRestrictiveWins
    ) {
        self.syncID = syncID
        self.lastSyncedAt = lastSyncedAt
        self.pendingChanges = pendingChanges
        self.isSyncRequired = isSyncRequired
        self.privacyPolicy = privacyPolicy
    }
    
    func requiresExplicitConfirmation() -> Bool {
        // Enforce confirmation if any change requires it OR if policy is most-restrictive
        pendingChanges.contains(where: { $0.requiresExplicitConfirmation }) || privacyPolicy == .localOnly
    }
    
    func generateReceipt() -> ActionReceipt {
        let confirmationNeeded = requiresExplicitConfirmation()
        
        return ActionReceipt(
            id: UUID().uuidString,
            resultState: confirmationNeeded ? .needsConfirmation : .noOp,
            title: "Continuity Sync",
            summary: confirmationNeeded ? "Sync paused: review required for privacy/mutation compliance." : "Synchronizing plan continuity across domains.",
            sourceDomain: .time,
            occurredAt: "2026-05-16T00:00:00Z",
            affectedObjects: [],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: confirmationNeeded ? .needsConfirmation : .noChange,
                    summary: "Continuity sync evaluated with \(privacyPolicy.rawValue) policy."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            safetyState: confirmationNeeded ? .confirmationRequired : .normal
        )
    }
}
