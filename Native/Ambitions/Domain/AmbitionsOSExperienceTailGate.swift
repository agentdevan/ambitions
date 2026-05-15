import Foundation

public struct AmbitionsOSExperienceTailGateProof: Sendable, Equatable {
    public let cognitiveLoadProven: Bool
    public let noDashboardProven: Bool
    public let signatureLanguageProven: Bool
    
    public init(
        cognitiveLoadProven: Bool = false,
        noDashboardProven: Bool = false,
        signatureLanguageProven: Bool = false
    ) {
        self.cognitiveLoadProven = cognitiveLoadProven
        self.noDashboardProven = noDashboardProven
        self.signatureLanguageProven = signatureLanguageProven
    }
    
    public var isFullyProven: Bool {
        cognitiveLoadProven && noDashboardProven && signatureLanguageProven
    }
}

public struct AmbitionsOSExperienceTailGate: Sendable, Equatable {
    public init() {}
    
    public func evaluateExperience(proof: AmbitionsOSExperienceTailGateProof) -> ActionReceipt {
        let isProven = proof.isFullyProven
        
        return ActionReceipt(
            id: UUID().uuidString,
            resultState: isProven ? .completed : .needsConfirmation,
            title: "AOS Experience Tail Gate",
            summary: "Evaluated AOS experience obligations.",
            sourceDomain: .you,
            occurredAt: "2026-05-15T00:00:00Z",
            affectedObjects: [],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: isProven ? .noChange : .needsConfirmation,
                    summary: isProven ? "All AOS experience obligations proven." : "AOS experience incomplete. Requires explicit confirmation to proceed."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            safetyState: isProven ? .normal : .confirmationRequired
        )
    }
}
