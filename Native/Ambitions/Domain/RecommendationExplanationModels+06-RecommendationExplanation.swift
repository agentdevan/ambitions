import Foundation

struct RecommendationExplanation: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let type: RecommendationExplanationType
    let title: String
    let summary: String
    let recommendationTitle: String
    let recommendationSummary: String?
    let confidence: RecommendationConfidence
    let evidence: [RecommendationExplanationEvidence]
    let assumptions: [RecommendationExplanationAssumption]
    let uncertainty: [RecommendationExplanationUncertainty]
    let userCorrectableFields: [String]
    let correctionActions: [RecommendationExplanationCorrectionAction]
    let lastUpdatedAt: String
    let source: RecommendationExplanationSource
    let relations: RecommendationExplanationRelations
    let privacy: EventLedgerPrivacyClassification
    let localOnly: Bool
    let todaySummaries: [TodayExplanationSummary]
    let schemaVersion: String
    let metadata: [String: String]

    init(
        id: String,
        type: RecommendationExplanationType,
        title: String,
        summary: String,
        recommendationTitle: String,
        recommendationSummary: String? = nil,
        confidence: RecommendationConfidence = .medium,
        evidence: [RecommendationExplanationEvidence] = [],
        assumptions: [RecommendationExplanationAssumption] = [],
        uncertainty: [RecommendationExplanationUncertainty] = [],
        userCorrectableFields: [String] = [],
        correctionActions: [RecommendationExplanationCorrectionAction] = [],
        lastUpdatedAt: String,
        source: RecommendationExplanationSource,
        relations: RecommendationExplanationRelations = RecommendationExplanationRelations(),
        privacy: EventLedgerPrivacyClassification = .standard,
        localOnly: Bool = true,
        todaySummaries: [TodayExplanationSummary] = [],
        schemaVersion: String = recommendationExplanationSchemaVersion,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.summary = summary
        self.recommendationTitle = recommendationTitle
        self.recommendationSummary = recommendationSummary
        self.confidence = confidence
        self.evidence = evidence.sorted { lhs, rhs in
            if lhs.category.rawValue != rhs.category.rawValue {
                return lhs.category.rawValue < rhs.category.rawValue
            }
            return lhs.id < rhs.id
        }
        self.assumptions = assumptions.sorted { $0.id < $1.id }
        self.uncertainty = uncertainty.sorted { $0.id < $1.id }
        self.userCorrectableFields = Array(Set(userCorrectableFields.filter { $0.isEmpty == false })).sorted()
        self.correctionActions = correctionActions.sorted { $0.id < $1.id }
        self.lastUpdatedAt = lastUpdatedAt
        self.source = source
        self.relations = relations
        self.privacy = privacy
        self.localOnly = localOnly
        self.todaySummaries = todaySummaries.sorted { lhs, rhs in
            if lhs.kind.rawValue != rhs.kind.rawValue {
                return lhs.kind.rawValue < rhs.kind.rawValue
            }
            return lhs.id < rhs.id
        }
        self.schemaVersion = schemaVersion
        self.metadata = metadata
    }

    var evidenceCategories: Set<RecommendationExplanationEvidenceCategory> {
        Set(evidence.map(\.category))
    }

    var referencesEventLedger: Bool {
        relations.eventLedgerEntryIDs.isEmpty == false || evidence.contains { $0.eventLedgerEntryID != nil }
    }

    var containsCalendarDerivedEvidence: Bool {
        privacy == .calendarDerived || evidence.contains { $0.isCalendarDerived }
    }

    var containsContextLensEvidence: Bool {
        evidence.contains { $0.isContextLensDerived }
    }

    var containsPriorityRealityEvidence: Bool {
        evidence.contains { $0.isPriorityRelevant }
    }

    var containsDeadlineEvidence: Bool {
        evidence.contains { $0.isDeadlineRelevant }
    }

    var containsGoalScopeOrDeliverableEvidence: Bool {
        evidence.contains { $0.isGoalScopeRelevant }
    }

    var containsSourceTruthEvidence: Bool {
        evidence.contains { $0.category == .sourceTruth }
    }

    var evidenceBoundarySummary: RecommendationEvidenceBoundarySummary {
        let citedSourceIDs = Array(Set(evidence.compactMap(\.sourceID))).sorted()
        let hasEvidence = evidence.isEmpty == false
        let hasCorrectableAssumption = assumptions.contains { $0.isUserCorrectable }
        let hasCorrectiveAction = correctionActions.isEmpty == false || userCorrectableFields.isEmpty == false
        let allAssumptionsCorrectable = assumptions.isEmpty == false && assumptions.allSatisfy(\.isUserCorrectable)
        let hasUncertainty = uncertainty.isEmpty == false

        let evidenceLabel: String
        if referencesEventLedger {
            evidenceLabel = "Cites local records"
        } else if hasEvidence {
            evidenceLabel = "Uses local explanation evidence"
        } else {
            evidenceLabel = "Evidence-light"
        }

        let inferenceBoundaryLabel: String
        if assumptions.isEmpty && hasUncertainty == false {
            inferenceBoundaryLabel = "No stated inference"
        } else if allAssumptionsCorrectable || hasCorrectableAssumption {
            inferenceBoundaryLabel = "Inference stated and correctable"
        } else {
            inferenceBoundaryLabel = "Inference stated with limited correction"
        }

        let userControlLabel: String
        if hasCorrectiveAction {
            userControlLabel = "Correction available"
        } else if hasCorrectableAssumption {
            userControlLabel = "Clarification available"
        } else {
            userControlLabel = "Review only"
        }

        let privacyLabel: String
        if containsCalendarDerivedEvidence {
            privacyLabel = "Calendar-derived"
        } else if localOnly {
            privacyLabel = "Local-only"
        } else {
            privacyLabel = "Needs privacy review"
        }

        return RecommendationEvidenceBoundarySummary(
            evidenceLabel: evidenceLabel,
            inferenceBoundaryLabel: inferenceBoundaryLabel,
            userControlLabel: userControlLabel,
            privacyLabel: privacyLabel,
            citedSourceIDs: citedSourceIDs,
            isEvidenceLight: hasEvidence == false,
            hasCorrectableInference: hasCorrectableAssumption || hasCorrectiveAction,
            requiresSensitiveReview: localOnly == false || privacy != .standard || containsCalendarDerivedEvidence
        )
    }

    var recommendationEvidenceModel: RecommendationEvidenceModel {
        RecommendationEvidenceModel(explanation: self)
    }
}
