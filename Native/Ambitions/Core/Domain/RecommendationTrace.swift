import Foundation

struct RecommendationTrace: Codable, Sendable, Equatable, Hashable, Identifiable {

    let id: String

    let recommendationID: String

    let source: RecommendationTraceSource

    let reason: RecommendationTraceReason

    let fit: RecommendationTraceFit

    let uncertainty: RecommendationTraceUncertainty

    let control: RecommendationTraceControl

    let receiptBehavior: RecommendationTraceReceiptBehavior

    let rejectionLearningInfluences: [CorrectionFoldRecommendationLearningInfluence]

    let schemaVersion: String

    init(
        id: String,
        recommendationID: String,
        source: RecommendationTraceSource,
        reason: RecommendationTraceReason,
        fit: RecommendationTraceFit,
        uncertainty: RecommendationTraceUncertainty,
        control: RecommendationTraceControl,
        receiptBehavior: RecommendationTraceReceiptBehavior,
        rejectionLearningInfluences: [CorrectionFoldRecommendationLearningInfluence] = [],
        schemaVersion: String = recommendationTraceSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.recommendationID = recommendationID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.source = source
        self.reason = reason
        self.fit = fit
        self.uncertainty = uncertainty
        self.control = control
        self.receiptBehavior = receiptBehavior
        self.rejectionLearningInfluences = rejectionLearningInfluences.sorted { $0.id < $1.id }
        self.schemaVersion = schemaVersion
    }

    init(
        explanation: RecommendationExplanation,
        fitState: RecommendationTraceFitState = .reviewable,
        receiptBehavior: RecommendationTraceReceiptBehavior = .required()
    ) {
        let evidenceModel = explanation.recommendationEvidenceModel
        self.init(
            id: "trace.\(explanation.id)",
            recommendationID: explanation.id,
            source: RecommendationTraceSource(
                citedSourceIDs: evidenceModel.citedSourceIDs,
                sourceAtlasBlockReasons: evidenceModel.sourceAtlasBlockReasons,
                localEvidenceCategories: evidenceModel.categories,
                canSupportRecommendation: evidenceModel.canDriveRecommendation
            ),
            reason: RecommendationTraceReason(
                explanationID: explanation.id,
                summary: explanation.summary,
                evidenceCategoryIDs: evidenceModel.categories.map(\.rawValue)
            ),
            fit: RecommendationTraceFit(
                state: fitState,
                blockReasons: evidenceModel.sourceAtlasBlockReasons,
                canDriveRecommendation: evidenceModel.canDriveRecommendation && fitState.canDriveRecommendation
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: explanation.uncertainty.map(\.id).sorted(),
                summaries: explanation.uncertainty.map(\.summary).sorted()
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: explanation.correctionActions.map(\.id).sorted(),
                controlActionIDs: [],
                correctableFieldKeys: evidenceModel.correctableFieldKeys,
                hasRequiredControl: explanation.correctionActions.isEmpty == false || evidenceModel.correctableFieldKeys.isEmpty == false
            ),
            receiptBehavior: receiptBehavior
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(String.self, forKey: .id),
            recommendationID: try container.decode(String.self, forKey: .recommendationID),
            source: try container.decode(RecommendationTraceSource.self, forKey: .source),
            reason: try container.decode(RecommendationTraceReason.self, forKey: .reason),
            fit: try container.decode(RecommendationTraceFit.self, forKey: .fit),
            uncertainty: try container.decode(RecommendationTraceUncertainty.self, forKey: .uncertainty),
            control: try container.decode(RecommendationTraceControl.self, forKey: .control),
            receiptBehavior: try container.decode(RecommendationTraceReceiptBehavior.self, forKey: .receiptBehavior),
            rejectionLearningInfluences: try container.decodeIfPresent(
                [CorrectionFoldRecommendationLearningInfluence].self,
                forKey: .rejectionLearningInfluences
            ) ?? [],
            schemaVersion: try container.decode(String.self, forKey: .schemaVersion)
        )
    }
}
