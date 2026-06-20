import Foundation

let runtimeSnapshotSchemaVersion = "runtime_snapshot.native.v1"

struct RuntimeSnapshot: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let generatedAt: String
    let nowState: CanonicalNowState
    let recommendation: RuntimeRecommendation
    let capacityShape: CapacityShape
    let recoveryState: RecoveryState
    let proofLedger: ProofLedger
    let privacyBoundary: PrivacyBoundary
    let changedObjectIDs: [String]
    let canUndo: Bool
    let requiresConfirmation: Bool
    let needsReview: Bool
    let localOnly: Bool
    let schemaVersion: String

    init(
        id: String,
        generatedAt: String,
        nowState: CanonicalNowState,
        recommendation: RuntimeRecommendation,
        capacityShape: CapacityShape,
        recoveryState: RecoveryState,
        proofLedger: ProofLedger,
        privacyBoundary: PrivacyBoundary,
        changedObjectIDs: [String] = [],
        canUndo: Bool = false,
        schemaVersion: String = runtimeSnapshotSchemaVersion
    ) {
        self.id = id
        self.generatedAt = generatedAt
        self.nowState = nowState
        self.recommendation = recommendation
        self.capacityShape = capacityShape
        self.recoveryState = recoveryState
        self.proofLedger = proofLedger
        self.privacyBoundary = privacyBoundary
        self.changedObjectIDs = Array(Set(changedObjectIDs.filter { $0.isEmpty == false })).sorted()
        self.canUndo = canUndo
        self.requiresConfirmation = recommendation.requiresConfirmation
        self.needsReview = recommendation.needsReview || recoveryState.needsVisibleRecovery || privacyBoundary.isSatisfied == false
        self.localOnly = nowState.localOnly && privacyBoundary.isSatisfied
        self.schemaVersion = schemaVersion
    }

    var recommendedStep: NowAction? {
        recommendation.action
    }

    var proofExists: Bool {
        proofLedger.hasInspectableProof
    }
}
