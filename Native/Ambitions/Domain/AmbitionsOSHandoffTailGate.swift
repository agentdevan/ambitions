import Foundation

public struct AmbitionsOSHandoffTailGateProof: Sendable, Equatable {
    public let sourceAtlasDependenciesProven: Bool
    public let intelligenceDataControlProven: Bool
    public let crossTrainGatesProven: Bool
    
    public init(
        sourceAtlasDependenciesProven: Bool = false,
        intelligenceDataControlProven: Bool = false,
        crossTrainGatesProven: Bool = false
    ) {
        self.sourceAtlasDependenciesProven = sourceAtlasDependenciesProven
        self.intelligenceDataControlProven = intelligenceDataControlProven
        self.crossTrainGatesProven = crossTrainGatesProven
    }
    
    public var isFullyProven: Bool {
        sourceAtlasDependenciesProven && intelligenceDataControlProven && crossTrainGatesProven
    }
}

public struct AmbitionsOSHandoffTailGate: Sendable, Equatable {
    public init() {}
    
    public func evaluateHandoff(proof: AmbitionsOSHandoffTailGateProof) -> ActionReceipt {
        let isProven = proof.isFullyProven
        
        return ActionReceipt(
            id: UUID().uuidString,
            resultState: isProven ? .completed : .needsConfirmation,
            title: "AOS Handoff Tail Gate",
            summary: "Evaluated AOS handoff dependencies and cross-train gates.",
            sourceDomain: .you,
            occurredAt: "2026-05-15T00:00:00Z",
            affectedObjects: [],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: isProven ? .noChange : .needsConfirmation,
                    summary: isProven ? "All AOS handoff gates proven." : "AOS handoff incomplete. Requires explicit confirmation to proceed."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            safetyState: isProven ? .normal : .confirmationRequired
        )
    }
}
