import Foundation

struct AmbitionsOSCloseoutTailGateProof: Sendable, Equatable {
    let finalReviewProven: Bool
    let legacyDependenciesRetiredProven: Bool
    let completeSignoffProven: Bool
    
    init(
        finalReviewProven: Bool = false,
        legacyDependenciesRetiredProven: Bool = false,
        completeSignoffProven: Bool = false
    ) {
        self.finalReviewProven = finalReviewProven
        self.legacyDependenciesRetiredProven = legacyDependenciesRetiredProven
        self.completeSignoffProven = completeSignoffProven
    }
    
    var isFullyProven: Bool {
        finalReviewProven && legacyDependenciesRetiredProven && completeSignoffProven
    }
}

struct AmbitionsOSCloseoutTailGate: Sendable, Equatable {
    init() {}
    
    func evaluateCloseout(proof: AmbitionsOSCloseoutTailGateProof) -> ActionReceipt {
        let isProven = proof.isFullyProven
        
        return ActionReceipt(
            id: UUID().uuidString,
            resultState: isProven ? .completed : .needsConfirmation,
            title: "AOS Closeout Tail Gate",
            summary: "Evaluated AOS final closeout obligations.",
            sourceDomain: .you,
            occurredAt: "2026-05-15T00:00:00Z",
            affectedObjects: [],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: isProven ? .noChange : .needsConfirmation,
                    summary: isProven ? "All AOS closeout gates proven." : "AOS closeout incomplete. Requires explicit confirmation to proceed."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            safetyState: isProven ? .normal : .confirmationRequired
        )
    }
}
