import Foundation

let runtimeSnapshotSchemaVersion = "runtime_snapshot.native.v1"

struct RuntimeSnapshot: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let generatedAt: String
    let nowState: CanonicalNowState
    let recommendation: RuntimeRecommendation
    let capacityShape: CapacityShape
    let pressureReading: PressureReading
    let bufferReading: BufferReading
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
        pressureReading: PressureReading? = nil,
        bufferReading: BufferReading? = nil,
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
        self.pressureReading = pressureReading ?? PressureEngine().reading(nowState: nowState, capacityShape: capacityShape)
        self.bufferReading = bufferReading ?? BufferEngine().reading(nowState: nowState, capacityShape: capacityShape)
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

extension RuntimeSnapshot {
    enum CodingKeys: String, CodingKey {
        case id
        case generatedAt
        case nowState
        case recommendation
        case capacityShape
        case pressureReading
        case bufferReading
        case recoveryState
        case proofLedger
        case privacyBoundary
        case changedObjectIDs
        case canUndo
        case requiresConfirmation
        case needsReview
        case localOnly
        case schemaVersion
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nowState = try container.decode(CanonicalNowState.self, forKey: .nowState)
        let recommendation = try container.decode(RuntimeRecommendation.self, forKey: .recommendation)
        let capacityShape = try container.decode(CapacityShape.self, forKey: .capacityShape)
        let pressureReading = try container.decodeIfPresent(PressureReading.self, forKey: .pressureReading)
        let bufferReading = try container.decodeIfPresent(BufferReading.self, forKey: .bufferReading)

        self.init(
            id: try container.decode(String.self, forKey: .id),
            generatedAt: try container.decode(String.self, forKey: .generatedAt),
            nowState: nowState,
            recommendation: recommendation,
            capacityShape: capacityShape,
            pressureReading: pressureReading,
            bufferReading: bufferReading,
            recoveryState: try container.decode(RecoveryState.self, forKey: .recoveryState),
            proofLedger: try container.decode(ProofLedger.self, forKey: .proofLedger),
            privacyBoundary: try container.decode(PrivacyBoundary.self, forKey: .privacyBoundary),
            changedObjectIDs: try container.decodeIfPresent([String].self, forKey: .changedObjectIDs) ?? [],
            canUndo: try container.decodeIfPresent(Bool.self, forKey: .canUndo) ?? false,
            schemaVersion: try container.decodeIfPresent(String.self, forKey: .schemaVersion) ?? runtimeSnapshotSchemaVersion
        )
    }
}
