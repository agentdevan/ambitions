import Foundation

public struct LivingPlanFreshnessBroker: Sendable, Equatable {
    public let lastEvaluatedAt: Date
    public let staleGoalIDs: [String]
    
    public init(
        lastEvaluatedAt: Date = Date(),
        staleGoalIDs: [String] = []
    ) {
        self.lastEvaluatedAt = lastEvaluatedAt
        self.staleGoalIDs = staleGoalIDs
    }
    
    public func evaluateFreshness(for goalIDs: [String], against threshold: TimeInterval) -> LivingPlanFreshnessBroker {
        // Mock deterministic evaluation: if they aren't already stale, maybe they are now depending on logic
        let newlyStale = goalIDs.filter { !staleGoalIDs.contains($0) }
        
        return LivingPlanFreshnessBroker(
            lastEvaluatedAt: Date(),
            staleGoalIDs: staleGoalIDs + newlyStale
        )
    }
    
    public func generateReceipt(for newlyStaleIDs: [String]) -> ActionReceipt {
        let needsConfirmation = !newlyStaleIDs.isEmpty
        
        return ActionReceipt(
            id: UUID().uuidString,
            resultState: needsConfirmation ? .needsConfirmation : .noOp,
            title: "Freshness Evaluation",
            summary: "Evaluated plan freshness against staleness thresholds.",
            sourceDomain: .plan,
            occurredAt: "2026-05-15T00:00:00Z",
            affectedObjects: [],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: needsConfirmation ? .needsConfirmation : .noChange,
                    summary: needsConfirmation ? "Found \(newlyStaleIDs.count) stale goals requiring update review." : "All goals are fresh."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            safetyState: needsConfirmation ? .confirmationRequired : .normal
        )
    }
}
