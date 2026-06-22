import Foundation

struct RuntimeProjectionPipeline: Sendable {
    let projector: any NowStateProjecting
    let recommendationEngine: RecommendationEngine
    let capacityEngine: CapacityEngine
    let pressureEngine: PressureEngine
    let recoveryEngine: RecoveryEngine

    init(
        projector: any NowStateProjecting = CanonicalNowStateProjector(),
        recommendationEngine: RecommendationEngine = RecommendationEngine(),
        capacityEngine: CapacityEngine = CapacityEngine(),
        pressureEngine: PressureEngine = PressureEngine(),
        recoveryEngine: RecoveryEngine = RecoveryEngine()
    ) {
        self.projector = projector
        self.recommendationEngine = recommendationEngine
        self.capacityEngine = capacityEngine
        self.pressureEngine = pressureEngine
        self.recoveryEngine = recoveryEngine
    }

    func project(
        input: NowStateProjectionInput,
        proofs: [Proof] = [],
        boundary: PrivateLifeRuntimeBoundary = .localOnly
    ) -> RuntimeSnapshot {
        let nowState = projector.project(input: input)
        let recommendation = recommendationEngine.recommendation(from: nowState)
        let capacity = capacityEngine.capacityShape(from: nowState)
        let pressure = pressureEngine.reading(nowState: nowState, capacityShape: capacity)
        let recovery = recoveryEngine.recoveryState(from: nowState)
        let proofLedger = ProofLedger(nowState: nowState, proofs: proofs)
        let privacyBoundary = PrivacyBoundary(boundary: boundary, privacy: nowState.privacy)

        return RuntimeSnapshot(
            id: "runtime.snapshot.\(nowState.id)",
            generatedAt: nowState.generatedAt,
            nowState: nowState,
            recommendation: recommendation,
            capacityShape: capacity,
            pressureReading: pressure,
            recoveryState: recovery,
            proofLedger: proofLedger,
            privacyBoundary: privacyBoundary,
            changedObjectIDs: changedObjectIDs(nowState: nowState, recommendation: recommendation),
            canUndo: proofLedger.hasInspectableProof
        )
    }

    private func changedObjectIDs(
        nowState: CanonicalNowState,
        recommendation: RuntimeRecommendation
    ) -> [String] {
        Array(Set(
            [recommendation.action?.reference?.goalID,
             recommendation.action?.reference?.stepID,
             recommendation.action?.reference?.captureID,
             recommendation.action?.reference?.timeID].compactMap { $0 } +
            nowState.blockersWaiting.references.flatMap { reference in
                [reference.goalID, reference.stepID, reference.captureID, reference.timeID].compactMap { $0 }
            }
        )).sorted()
    }
}
