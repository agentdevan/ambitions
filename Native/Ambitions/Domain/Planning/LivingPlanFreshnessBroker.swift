import Foundation

/// Context injection protocol for living plans, as per LDI20 manifest.
public struct PlanContextHint: Codable, Sendable, Equatable {
    public let key: String
    public let value: String
    
    public init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

public struct LivingPlanFreshnessBroker: Sendable, Equatable {
    public let lastEvaluatedAt: Date
    public let staleGoalIDs: [String]
    public let injectedHints: [PlanContextHint]
    
    public init(
        lastEvaluatedAt: Date = Date(),
        staleGoalIDs: [String] = [],
        injectedHints: [PlanContextHint] = []
    ) {
        self.lastEvaluatedAt = lastEvaluatedAt
        self.staleGoalIDs = staleGoalIDs
        self.injectedHints = injectedHints
    }
    
    /// Injects dynamic context hints to influence plan recompilation logic.
    public func withInjectedContext(_ hints: [PlanContextHint]) -> LivingPlanFreshnessBroker {
        var newHints = injectedHints
        for hint in hints {
            if let index = newHints.firstIndex(where: { $0.key == hint.key }) {
                newHints[index] = hint
            } else {
                newHints.append(hint)
            }
        }
        return LivingPlanFreshnessBroker(
            lastEvaluatedAt: lastEvaluatedAt,
            staleGoalIDs: staleGoalIDs,
            injectedHints: newHints
        )
    }
    
    public func evaluateFreshness(for goalIDs: [String], against threshold: TimeInterval) -> LivingPlanFreshnessBroker {
        let newlyStale = goalIDs.filter { !staleGoalIDs.contains($0) }
        
        return LivingPlanFreshnessBroker(
            lastEvaluatedAt: Date(),
            staleGoalIDs: staleGoalIDs + newlyStale,
            injectedHints: injectedHints
        )
    }
    
    public func generateReceipt(for newlyStaleIDs: [String]) -> ActionReceipt {
        let needsConfirmation = !newlyStaleIDs.isEmpty
        
        return ActionReceipt(
            id: UUID().uuidString,
            resultState: needsConfirmation ? .needsConfirmation : .noOp,
            title: "Freshness & Context Evaluation",
            summary: "Evaluated plan freshness and \(injectedHints.count) context hints.",
            sourceDomain: .plan,
            occurredAt: "2026-05-16T00:00:00Z",
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
