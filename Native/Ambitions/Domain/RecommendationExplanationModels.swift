import Foundation

let recommendationExplanationSchemaVersion = "recommendation_explanation.native.v1"

enum RecommendationExplanationType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case whyThis = "why_this"
    case whyNow = "why_now"
    case whyChanged = "why_changed"
    case whyScheduled = "why_scheduled"
    case whyDeferred = "why_deferred"
    case whyRecovered = "why_recovered"
    case whyPrioritized = "why_prioritized"
    case whyDisplaced = "why_displaced"
    case whyRouted = "why_routed"
    case whyGoalChanged = "why_goal_changed"
    case whyPlanChanged = "why_plan_changed"
    case whyContextLens = "why_context_lens"
    case whyCalendarAware = "why_calendar_aware"
    case whyBelievable = "why_believable"
    case whyNotBelievable = "why_not_believable"
}

enum RecommendationExplanationEvidenceCategory: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case userInput = "user_input"
    case memoryEvent = "memory_event"
    case goalState = "goal_state"
    case captureState = "capture_state"
    case planState = "plan_state"
    case sourceTruth = "source_truth"
    case calendarDerived = "calendar_derived"
    case deadline
    case priority
    case urgency
    case consequence
    case effort
    case contextLens = "context_lens"
    case capacity
    case recovery
    case path
    case deliverable
    case scopeChange = "scope_change"
    case assumption
    case userCorrection = "user_correction"
    case systemDefault = "system_default"
}

enum RecommendationExplanationCorrectionActionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case changeDomainContext = "change_domain_context"
    case changeDeadline = "change_deadline"
    case changeImportance = "change_importance"
    case changeUrgency = "change_urgency"
    case changeConsequence = "change_consequence"
    case changeRoute = "change_route"
    case markGoalSupporting = "mark_goal_supporting"
    case markOneTimeTask = "mark_one_time_task"
    case markOptionalSomeday = "mark_optional_someday"
    case dismissRecommendation = "dismiss_recommendation"
    case explainMore = "explain_more"
}

enum RecommendationExplanationSource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case today
    case goals
    case capture
    case plan
    case you
    case reviews
    case goalDetail = "goal_detail"
    case memoryLens = "memory_lens"
    case goalEngine = "goal_engine"
    case planner
    case recovery
    case recommendation
    case calendar
    case system
}

struct RecommendationExplanationRelations: Codable, Sendable, Equatable, Hashable {
    let goalIDs: [String]
    let captureIDs: [String]
    let planIDs: [String]
    let reviewIDs: [String]
    let eventLedgerEntryIDs: [String]

    init(
        goalIDs: [String] = [],
        captureIDs: [String] = [],
        planIDs: [String] = [],
        reviewIDs: [String] = [],
        eventLedgerEntryIDs: [String] = []
    ) {
        self.goalIDs = Self.normalized(goalIDs)
        self.captureIDs = Self.normalized(captureIDs)
        self.planIDs = Self.normalized(planIDs)
        self.reviewIDs = Self.normalized(reviewIDs)
        self.eventLedgerEntryIDs = Self.normalized(eventLedgerEntryIDs)
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }
}

struct RecommendationExplanationEvidence: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let category: RecommendationExplanationEvidenceCategory
    let title: String
    let summary: String?
    let sourceID: String?
    let eventLedgerEntryID: String?
    let confidence: RecommendationConfidence?
    let isCalendarDerived: Bool
    let isContextLensDerived: Bool
    let isPriorityRelevant: Bool
    let isDeadlineRelevant: Bool
    let isGoalScopeRelevant: Bool
    let metadata: [String: String]

    init(
        id: String,
        category: RecommendationExplanationEvidenceCategory,
        title: String,
        summary: String? = nil,
        sourceID: String? = nil,
        eventLedgerEntryID: String? = nil,
        confidence: RecommendationConfidence? = nil,
        isCalendarDerived: Bool? = nil,
        isContextLensDerived: Bool? = nil,
        isPriorityRelevant: Bool? = nil,
        isDeadlineRelevant: Bool? = nil,
        isGoalScopeRelevant: Bool? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.summary = summary
        self.sourceID = sourceID
        self.eventLedgerEntryID = eventLedgerEntryID
        self.confidence = confidence
        self.isCalendarDerived = isCalendarDerived ?? (category == .calendarDerived)
        self.isContextLensDerived = isContextLensDerived ?? (category == .contextLens)
        self.isPriorityRelevant = isPriorityRelevant ?? [.priority, .urgency, .consequence, .effort, .capacity].contains(category)
        self.isDeadlineRelevant = isDeadlineRelevant ?? (category == .deadline)
        self.isGoalScopeRelevant = isGoalScopeRelevant ?? [.deliverable, .scopeChange, .path].contains(category)
        self.metadata = metadata
    }

    static func fromEventLedgerEntry(
        _ entry: EventLedgerEntry,
        category: RecommendationExplanationEvidenceCategory? = nil
    ) -> RecommendationExplanationEvidence {
        RecommendationExplanationEvidence(
            id: "evidence.ledger.\(entry.id)",
            category: category ?? categoryForLedgerKind(entry.kind),
            title: entry.title,
            summary: entry.summary,
            sourceID: entry.id,
            eventLedgerEntryID: entry.id,
            confidence: entry.trust.confidenceLabel,
            isCalendarDerived: entry.privacy == .calendarDerived || entry.kind == .calendarContextObserved,
            isContextLensDerived: entry.kind == .contextLensChanged || entry.kind == .contextInferred,
            metadata: [
                "ledgerKind": entry.kind.rawValue,
                "ledgerSource": entry.source.rawValue,
                "occurredAt": entry.occurredAt
            ]
        )
    }

    static func fromSourceAtlasQueryResult(
        _ result: SourceAtlasQueryResult,
        title: String = "Source Atlas evidence",
        summary: String? = nil
    ) -> RecommendationExplanationEvidence {
        var metadata = [
            "sourceAtlasPackID": result.packID,
            "sourceAtlasDomainID": result.domainID,
            "sourceAtlasSourceState": result.sourceState.rawValue,
            "sourceAtlasFreshnessState": result.freshnessState.rawValue,
            "sourceAtlasRiskState": result.riskState.rawValue,
            "sourceAtlasReviewState": result.reviewState.rawValue,
            "sourceAtlasFallbackReason": result.fallbackReason.rawValue,
            "sourceAtlasCanSupportCurrentUse": result.canSupportCurrentUse ? "true" : "false"
        ]
        if let claimID = result.claimID {
            metadata["sourceAtlasClaimID"] = claimID
        }
        if let requirementID = result.requirementID {
            metadata["sourceAtlasRequirementID"] = requirementID
        }
        if let riskClass = result.riskClass {
            metadata["sourceAtlasRiskClass"] = riskClass.rawValue
        }
        if result.canSupportCurrentUse == false {
            metadata["sourceAtlasRecommendationBlockReason"] = result.fallbackReason.rawValue
        }

        return RecommendationExplanationEvidence(
            id: "evidence.source-atlas.\(result.id)",
            category: .sourceTruth,
            title: title,
            summary: summary,
            sourceID: result.provenanceSourceIDs.first ?? result.requirementID ?? result.claimID ?? result.id,
            confidence: result.canSupportCurrentUse ? .high : .low,
            metadata: metadata
        )
    }

    private static func categoryForLedgerKind(_ kind: EventLedgerKind) -> RecommendationExplanationEvidenceCategory {
        switch kind {
        case .goalCreated, .goalUpdated, .goalPaused, .goalCompleted, .goalArchived:
            return .goalState
        case .goalScopeItemAdded, .goalScopeItemRemoved:
            return .scopeChange
        case .deliverableAdded, .deliverableRemoved:
            return .deliverable
        case .planCreated, .planUpdated, .planRescheduled, .planScheduled, .planUnscheduled:
            return .planState
        case .planRecovered, .recoveryAccepted, .recoveryDeclined, .recoveryDueToPriorityConflict:
            return .recovery
        case .priorityChanged:
            return .priority
        case .urgencyChanged:
            return .urgency
        case .deadlineChanged:
            return .deadline
        case .itemScheduled:
            return .planState
        case .itemDisplacedByHigherPriority:
            return .priority
        case .captureCreated, .captureTriaged, .captureAttachedToGoal, .captureArchived:
            return .captureState
        case .commitmentCaptured:
            return .userInput
        case .commitmentRouted:
            return .planState
        case .actionCompleted, .actionDelayed, .actionSkipped, .actionMoved, .actionSplit:
            return .memoryEvent
        case .userCorrectionAdded:
            return .userCorrection
        case .reviewCompleted:
            return .memoryEvent
        case .recommendationShown, .recommendationAccepted, .recommendationDismissed:
            return .memoryEvent
        case .calendarContextObserved:
            return .calendarDerived
        case .contextLensChanged, .contextInferred:
            return .contextLens
        case .syncConflictDetected, .accessibilityAuditRecorded, .exportCreated, .importCompleted:
            return .memoryEvent
        }
    }
}

struct RecommendationExplanationAssumption: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let summary: String
    let fieldKey: String?
    let confidence: RecommendationConfidence
    let isUserCorrectable: Bool

    init(
        id: String,
        summary: String,
        fieldKey: String? = nil,
        confidence: RecommendationConfidence = .medium,
        isUserCorrectable: Bool = true
    ) {
        self.id = id
        self.summary = summary
        self.fieldKey = fieldKey
        self.confidence = confidence
        self.isUserCorrectable = isUserCorrectable
    }
}

struct RecommendationExplanationUncertainty: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let summary: String
    let severity: RecommendationConfidence
    let canBeReducedByUser: Bool

    init(
        id: String,
        summary: String,
        severity: RecommendationConfidence = .medium,
        canBeReducedByUser: Bool = true
    ) {
        self.id = id
        self.summary = summary
        self.severity = severity
        self.canBeReducedByUser = canBeReducedByUser
    }
}

struct RecommendationExplanationCorrectionAction: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: RecommendationExplanationCorrectionActionKind
    let title: String
    let targetFieldKey: String?
    let metadata: [String: String]

    init(
        id: String,
        kind: RecommendationExplanationCorrectionActionKind,
        title: String,
        targetFieldKey: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.targetFieldKey = targetFieldKey
        self.metadata = metadata
    }
}

struct RecommendationEvidenceBoundarySummary: Sendable, Equatable, Hashable {
    let evidenceLabel: String
    let inferenceBoundaryLabel: String
    let userControlLabel: String
    let privacyLabel: String
    let citedSourceIDs: [String]
    let isEvidenceLight: Bool
    let hasCorrectableInference: Bool
    let requiresSensitiveReview: Bool
}

enum RecommendationEvidenceStrength: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case evidenceLight = "evidence_light"
    case localEvidence = "local_evidence"
    case citedLocalRecords = "cited_local_records"
    case reviewRequired = "review_required"
}

struct RecommendationEvidenceModel: Codable, Sendable, Equatable, Hashable {
    let explanationID: String
    let source: RecommendationExplanationSource
    let categories: [RecommendationExplanationEvidenceCategory]
    let categoryCounts: [RecommendationExplanationEvidenceCategory: Int]
    let citedSourceIDs: [String]
    let eventLedgerEntryIDs: [String]
    let assumptionIDs: [String]
    let uncertaintyIDs: [String]
    let correctableFieldKeys: [String]
    let strength: RecommendationEvidenceStrength
    let usesCalendarDerivedEvidence: Bool
    let usesContextLensEvidence: Bool
    let usesPriorityRealityEvidence: Bool
    let usesDeadlineEvidence: Bool
    let usesGoalScopeEvidence: Bool
    let usesSourceAtlasEvidence: Bool
    let sourceAtlasBlockReasons: [String]
    let requiresSensitiveReview: Bool
    let canDriveRecommendation: Bool
    let schemaVersion: String

    init(explanation: RecommendationExplanation) {
        let boundary = explanation.evidenceBoundarySummary
        let categoryCounts = Dictionary(grouping: explanation.evidence, by: \.category)
            .mapValues(\.count)
        let eventLedgerEntryIDs = Array(
            Set(explanation.relations.eventLedgerEntryIDs + explanation.evidence.compactMap(\.eventLedgerEntryID))
        ).sorted()
        let correctableFieldKeys = Array(
            Set(explanation.userCorrectableFields + explanation.correctionActions.compactMap(\.targetFieldKey))
        ).filter { $0.isEmpty == false }.sorted()
        let hasReviewableInference = explanation.assumptions.isEmpty == false || explanation.uncertainty.isEmpty == false
        let sourceAtlasBlockReasons = Array(
            Set(explanation.evidence.compactMap { $0.metadata["sourceAtlasRecommendationBlockReason"] })
        ).sorted()

        self.explanationID = explanation.id
        self.source = explanation.source
        self.categories = categoryCounts.keys.sorted { $0.rawValue < $1.rawValue }
        self.categoryCounts = categoryCounts
        self.citedSourceIDs = boundary.citedSourceIDs
        self.eventLedgerEntryIDs = eventLedgerEntryIDs
        self.assumptionIDs = explanation.assumptions.map(\.id).sorted()
        self.uncertaintyIDs = explanation.uncertainty.map(\.id).sorted()
        self.correctableFieldKeys = correctableFieldKeys
        self.usesCalendarDerivedEvidence = explanation.containsCalendarDerivedEvidence
        self.usesContextLensEvidence = explanation.containsContextLensEvidence
        self.usesPriorityRealityEvidence = explanation.containsPriorityRealityEvidence
        self.usesDeadlineEvidence = explanation.containsDeadlineEvidence
        self.usesGoalScopeEvidence = explanation.containsGoalScopeOrDeliverableEvidence
        self.usesSourceAtlasEvidence = explanation.containsSourceTruthEvidence
        self.sourceAtlasBlockReasons = sourceAtlasBlockReasons
        self.requiresSensitiveReview = boundary.requiresSensitiveReview
        self.canDriveRecommendation = boundary.isEvidenceLight == false &&
            explanation.localOnly &&
            boundary.requiresSensitiveReview == false &&
            sourceAtlasBlockReasons.isEmpty &&
            (hasReviewableInference == false || boundary.hasCorrectableInference)
        self.schemaVersion = recommendationExplanationSchemaVersion

        if boundary.requiresSensitiveReview {
            self.strength = .reviewRequired
        } else if eventLedgerEntryIDs.isEmpty == false || explanation.referencesEventLedger {
            self.strength = .citedLocalRecords
        } else if boundary.isEvidenceLight {
            self.strength = .evidenceLight
        } else {
            self.strength = .localEvidence
        }
    }
}

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
