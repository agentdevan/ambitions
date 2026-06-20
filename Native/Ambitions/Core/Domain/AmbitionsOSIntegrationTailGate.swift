import Foundation

struct AmbitionsOSIntegrationTailGateProof: Sendable, Equatable {
    let uiIntegrationProven: Bool
    let dataIntegrationProven: Bool
    let noSprawlProven: Bool
    
    init(
        uiIntegrationProven: Bool = false,
        dataIntegrationProven: Bool = false,
        noSprawlProven: Bool = false
    ) {
        self.uiIntegrationProven = uiIntegrationProven
        self.dataIntegrationProven = dataIntegrationProven
        self.noSprawlProven = noSprawlProven
    }
    
    var isFullyProven: Bool {
        uiIntegrationProven && dataIntegrationProven && noSprawlProven
    }
}

struct AmbitionsOSIntegrationTailGate: Sendable, Equatable {
    init() {}
    
    func evaluateIntegration(proof: AmbitionsOSIntegrationTailGateProof) -> ActionReceipt {
        let isProven = proof.isFullyProven
        
        return ActionReceipt(
            id: UUID().uuidString,
            resultState: isProven ? .completed : .needsConfirmation,
            title: "AOS Integration Tail Gate Evaluation",
            summary: "Evaluated AOS UI, data, and no-sprawl integration obligations.",
            sourceDomain: .you,
            occurredAt: "2026-05-15T00:00:00Z",
            affectedObjects: [],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: isProven ? .noChange : .needsConfirmation,
                    summary: isProven ? "All AOS integration obligations proven." : "AOS integration incomplete. Requires explicit confirmation to proceed."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            safetyState: isProven ? .normal : .confirmationRequired
        )
    }
}
