import Foundation

struct AmbitionsOSRuntimeTailGateProof: Sendable, Equatable {
    let runtimeProven: Bool
    let privacyProven: Bool
    let evaluationProven: Bool
    let experienceProven: Bool
    
    init(
        runtimeProven: Bool = false,
        privacyProven: Bool = false,
        evaluationProven: Bool = false,
        experienceProven: Bool = false
    ) {
        self.runtimeProven = runtimeProven
        self.privacyProven = privacyProven
        self.evaluationProven = evaluationProven
        self.experienceProven = experienceProven
    }
    
    var isFullyProven: Bool {
        runtimeProven && privacyProven && evaluationProven && experienceProven
    }
}

struct AmbitionsOSRuntimeTailGate: Sendable, Equatable {
    init() {}
    
    func evaluateObligations(proof: AmbitionsOSRuntimeTailGateProof) -> ActionReceipt {
        let isProven = proof.isFullyProven
        
        return ActionReceipt(
            id: UUID().uuidString,
            resultState: isProven ? .completed : .needsConfirmation,
            title: "AOS Runtime Tail Gate Evaluation",
            summary: "Evaluated AOS runtime obligations for privacy, evaluation, and experience.",
            sourceDomain: .you,
            occurredAt: "2026-05-15T00:00:00Z",
            affectedObjects: [],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: isProven ? .noChange : .needsConfirmation,
                    summary: isProven ? "All AOS obligations proven." : "AOS obligations incomplete. Requires explicit confirmation to proceed."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            safetyState: isProven ? .normal : .confirmationRequired
        )
    }
}
