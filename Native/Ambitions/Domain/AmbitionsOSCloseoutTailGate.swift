import Foundation

public struct AmbitionsOSCloseoutTailGateProof: Sendable, Equatable {
    public let finalReviewProven: Bool
    public let legacyDependenciesRetiredProven: Bool
    public let completeSignoffProven: Bool
    
    public init(
        finalReviewProven: Bool = false,
        legacyDependenciesRetiredProven: Bool = false,
        completeSignoffProven: Bool = false
    ) {
        self.finalReviewProven = finalReviewProven
        self.legacyDependenciesRetiredProven = legacyDependenciesRetiredProven
        self.completeSignoffProven = completeSignoffProven
    }
    
    public var isFullyProven: Bool {
        finalReviewProven && legacyDependenciesRetiredProven && completeSignoffProven
    }
}

public struct AmbitionsOSCloseoutTailGate: Sendable, Equatable {
    public init() {}
    
    public func evaluateCloseout(proof: AmbitionsOSCloseoutTailGateProof) -> ActionReceipt {
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
