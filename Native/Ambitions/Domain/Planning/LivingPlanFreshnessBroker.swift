import Foundation

/// Context injection protocol for living plans, as per LDI20 manifest.
struct PlanContextHint: Codable, Sendable, Equatable {
    let key: String
    let value: String
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

struct LivingPlanFreshnessBroker: Sendable, Equatable {
    let lastEvaluatedAt: Date
    let staleGoalIDs: [String]
    let injectedHints: [PlanContextHint]
    
    init(
        lastEvaluatedAt: Date = Date(),
        staleGoalIDs: [String] = [],
        injectedHints: [PlanContextHint] = []
    ) {
        self.lastEvaluatedAt = lastEvaluatedAt
        self.staleGoalIDs = staleGoalIDs
        self.injectedHints = injectedHints
    }
    
    /// Injects dynamic context hints to influence plan recompilation logic.
    func withInjectedContext(_ hints: [PlanContextHint]) -> LivingPlanFreshnessBroker {
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
    
    func evaluateFreshness(for goalIDs: [String], against threshold: TimeInterval) -> LivingPlanFreshnessBroker {
        let newlyStale = goalIDs.filter { !staleGoalIDs.contains($0) }
        
        return LivingPlanFreshnessBroker(
            lastEvaluatedAt: Date(),
            staleGoalIDs: staleGoalIDs + newlyStale,
            injectedHints: injectedHints
        )
    }
    
    func generateReceipt(for newlyStaleIDs: [String]) -> ActionReceipt {
        let needsConfirmation = !newlyStaleIDs.isEmpty
        
        return ActionReceipt(
            id: UUID().uuidString,
            resultState: needsConfirmation ? .needsConfirmation : .noOp,
            title: "Freshness & Context Evaluation",
            summary: "Evaluated plan freshness and \(injectedHints.count) context hints.",
            sourceDomain: .time,
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
