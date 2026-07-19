import Foundation

extension RecommendationTrace {
    enum CodingKeys: String, CodingKey {
        case id
        case recommendationID
        case source
        case reason
        case fit
        case uncertainty
        case control
        case receiptBehavior
        case rejectionLearningInfluences
        case schemaVersion
    }


    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(recommendationID, forKey: .recommendationID)
        try container.encode(source, forKey: .source)
        try container.encode(reason, forKey: .reason)
        try container.encode(fit, forKey: .fit)
        try container.encode(uncertainty, forKey: .uncertainty)
        try container.encode(control, forKey: .control)
        try container.encode(receiptBehavior, forKey: .receiptBehavior)
        try container.encode(rejectionLearningInfluences, forKey: .rejectionLearningInfluences)
        try container.encode(schemaVersion, forKey: .schemaVersion)
    }


    var isComplete: Bool {
        schemaVersion == recommendationTraceSchemaVersion &&
            id.isEmpty == false &&
            recommendationID.isEmpty == false &&
            reason.summary.isEmpty == false &&
            source.localEvidenceCategories.isEmpty == false &&
            uncertainty.uncertaintyIDs.isEmpty == false &&
            control.hasRequiredControl &&
            receiptBehavior.satisfiesTraceContract
    }


    var canDriveRecommendationBehavior: Bool {
        isComplete &&
            source.canSupportRecommendation &&
            fit.canDriveRecommendation &&
            receiptBehavior.state != .receiptMissing &&
            isSuppressedByRejectionLearning == false
    }


    var rejectionLearningRankAdjustment: Int {
        rejectionLearningInfluences
            .map { influence in
                influence.rankAdjustment(
                    for: recommendationID,
                    candidateSignalKeys: rejectionLearningCandidateSignalKeys
                )
            }
            .min() ?? 0
    }


    var isSuppressedByRejectionLearning: Bool {
        rejectionLearningInfluences.contains { influence in
            influence.suppresses(
                candidateRecommendationID: recommendationID,
                candidateSignalKeys: rejectionLearningCandidateSignalKeys
            )
        }
    }


    var hasInspectableRejectionLearning: Bool {
        rejectionLearningInfluences.isEmpty == false &&
            rejectionLearningInfluences.allSatisfy(\.isInspectableAndControllable)
    }


    var personalRuntimeLearningSignals: [RuntimeLearningSignal] {
        rejectionLearningInfluences
    }
}
