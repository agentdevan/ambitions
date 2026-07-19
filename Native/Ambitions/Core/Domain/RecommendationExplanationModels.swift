import Foundation

let recommendationExplanationSchemaVersion = "recommendation_explanation.native.v1"
let recommendationTraceSchemaVersion = "recommendation_trace.native.v1"
let recommendationTraceReasonGraphSchemaVersion = "recommendation_trace_reason_graph.native.v1"
let recommendationTraceCounterfactualDiffSchemaVersion = "recommendation_trace_counterfactual_diff.native.v1"

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

enum TodayExplanationSummaryKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case used
    case needsReview = "needs_review"
    case notUsed = "not_used"

    var title: String {
        switch self {
        case .used:
            return "Used"
        case .needsReview:
            return "Needs review"
        case .notUsed:
            return "Not used"
        }
    }
}

struct TodayExplanationSummary: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: TodayExplanationSummaryKind
    let summary: String
    let detail: String?
    let sourceLabel: String

    init(
        id: String,
        kind: TodayExplanationSummaryKind,
        summary: String,
        detail: String? = nil,
        sourceLabel: String
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.detail = detail?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceLabel = sourceLabel.trimmingCharacters(in: .whitespacesAndNewlines)
    }
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

    static func normalized(_ values: [String]) -> [String] {
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
            "sourceAtlasFallbackReason": (result.fallbackReason ?? .none).rawValue,
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
            metadata["sourceAtlasRecommendationBlockReason"] = (result.fallbackReason ?? .none).rawValue
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

    static func categoryForLedgerKind(_ kind: EventLedgerKind) -> RecommendationExplanationEvidenceCategory {
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
