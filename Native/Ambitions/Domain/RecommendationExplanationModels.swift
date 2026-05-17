import Foundation

let recommendationExplanationSchemaVersion = "recommendation_explanation.native.v1"
let recommendationTraceSchemaVersion = "recommendation_trace.native.v1"

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

enum RecommendationTraceFitState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fits
    case reviewable
    case sourceNeeded = "source_needed"
    case proofNeeded = "proof_needed"
    case blocked
}

enum RecommendationTraceReceiptBehaviorState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case receiptAvailable = "receipt_available"
    case receiptRequired = "receipt_required"
    case receiptMissing = "receipt_missing"
    case notApplicable = "not_applicable"
}

struct RecommendationTraceSource: Codable, Sendable, Equatable, Hashable {
    let citedSourceIDs: [String]
    let sourceAtlasBlockReasons: [String]
    let localEvidenceCategories: [RecommendationExplanationEvidenceCategory]
    let canSupportRecommendation: Bool
}

struct RecommendationTraceReason: Codable, Sendable, Equatable, Hashable {
    let explanationID: String
    let summary: String
    let evidenceCategoryIDs: [String]
}

struct RecommendationTraceFit: Codable, Sendable, Equatable, Hashable {
    let state: RecommendationTraceFitState
    let blockReasons: [String]
    let canDriveRecommendation: Bool
}

struct RecommendationTraceUncertainty: Codable, Sendable, Equatable, Hashable {
    let uncertaintyIDs: [String]
    let summaries: [String]
}

struct RecommendationTraceControl: Codable, Sendable, Equatable, Hashable {
    let correctionActionIDs: [String]
    let controlActionIDs: [String]
    let correctableFieldKeys: [String]
    let hasRequiredControl: Bool
}

struct RecommendationTraceReceiptBehavior: Codable, Sendable, Equatable, Hashable {
    let state: RecommendationTraceReceiptBehaviorState
    let receiptIDs: [String]
    let actionReceiptIDs: [String]
    let proofReferenceIDs: [String]
    let requiresReceiptBeforeBehaviorChange: Bool

    var satisfiesTraceContract: Bool {
        switch state {
        case .receiptAvailable:
            return receiptIDs.isEmpty == false ||
                actionReceiptIDs.isEmpty == false ||
                proofReferenceIDs.isEmpty == false
        case .receiptRequired:
            return requiresReceiptBeforeBehaviorChange
        case .notApplicable:
            return requiresReceiptBeforeBehaviorChange == false
        case .receiptMissing:
            return false
        }
    }

    static func available(
        receiptIDs: [String] = [],
        actionReceiptIDs: [String] = [],
        proofReferenceIDs: [String] = []
    ) -> RecommendationTraceReceiptBehavior {
        RecommendationTraceReceiptBehavior(
            state: .receiptAvailable,
            receiptIDs: orderedUnique(receiptIDs),
            actionReceiptIDs: orderedUnique(actionReceiptIDs),
            proofReferenceIDs: orderedUnique(proofReferenceIDs),
            requiresReceiptBeforeBehaviorChange: false
        )
    }

    static func required() -> RecommendationTraceReceiptBehavior {
        RecommendationTraceReceiptBehavior(
            state: .receiptRequired,
            receiptIDs: [],
            actionReceiptIDs: [],
            proofReferenceIDs: [],
            requiresReceiptBeforeBehaviorChange: true
        )
    }

    static func missing() -> RecommendationTraceReceiptBehavior {
        RecommendationTraceReceiptBehavior(
            state: .receiptMissing,
            receiptIDs: [],
            actionReceiptIDs: [],
            proofReferenceIDs: [],
            requiresReceiptBeforeBehaviorChange: true
        )
    }

    static func notApplicable() -> RecommendationTraceReceiptBehavior {
        RecommendationTraceReceiptBehavior(
            state: .notApplicable,
            receiptIDs: [],
            actionReceiptIDs: [],
            proofReferenceIDs: [],
            requiresReceiptBeforeBehaviorChange: false
        )
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

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

    private enum CodingKeys: String, CodingKey {
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

    private var rejectionLearningCandidateSignalKeys: [String] {
        Self.orderedUnique(
            source.localEvidenceCategories.map(\.rawValue) +
                source.sourceAtlasBlockReasons +
                reason.evidenceCategoryIDs +
                fit.blockReasons +
                control.correctableFieldKeys
        )
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

enum RecommendationTrustSeamSectionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case ready
    case reviewNeeded = "review_needed"
    case blocked
    case missing
    case notApplicable = "not_applicable"
}

enum RecommendationTrustSeamSectionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case source
    case reason
    case fit
    case uncertainty
    case controls
    case receiptBehavior = "receipt_behavior"
}

struct RecommendationTrustSeamSection: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: RecommendationTrustSeamSectionKind
    let title: String
    let summary: String
    let state: RecommendationTrustSeamSectionState
    let referenceIDs: [String]
}

struct RecommendationTrustSeamState: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let traceID: String
    let recommendationID: String
    let sections: [RecommendationTrustSeamSection]
    let canProceed: Bool
    let needsReview: Bool
    let localOnlyLabel: String

    init(trace: RecommendationTrace) {
        let sections = [
            Self.sourceSection(trace.source),
            Self.reasonSection(trace.reason),
            Self.fitSection(trace.fit),
            Self.uncertaintySection(trace.uncertainty),
            Self.controlsSection(trace.control),
            Self.receiptSection(trace.receiptBehavior)
        ]
        self.id = "trust-seam.\(trace.id)"
        self.traceID = trace.id
        self.recommendationID = trace.recommendationID
        self.sections = sections
        self.canProceed = trace.canDriveRecommendationBehavior
        self.needsReview = trace.canDriveRecommendationBehavior == false ||
            sections.contains { $0.state != .ready && $0.state != .notApplicable }
        self.localOnlyLabel = "Local-only"
    }

    var sectionKinds: [RecommendationTrustSeamSectionKind] {
        sections.map(\.kind)
    }

    var visibleCopy: [String] {
        sections.flatMap { [$0.title, $0.summary] } + [localOnlyLabel]
    }

    var hasVisibleCopyGuardrailViolation: Bool {
        visibleCopy.contains { text in
            let lowercased = text.lowercased()
            return lowercased.contains("ai ") ||
                lowercased.contains("assistant") ||
                lowercased.contains("confidence") ||
                lowercased.contains("best next move") ||
                lowercased.contains("next best move") ||
                lowercased.contains("dashboard") ||
                text.contains("%")
        }
    }

    func section(_ kind: RecommendationTrustSeamSectionKind) -> RecommendationTrustSeamSection? {
        sections.first { $0.kind == kind }
    }

    private static func sourceSection(_ source: RecommendationTraceSource) -> RecommendationTrustSeamSection {
        let references = orderedUnique(source.citedSourceIDs + source.localEvidenceCategories.map(\.rawValue))
        let state: RecommendationTrustSeamSectionState
        let summary: String
        if source.canSupportRecommendation && source.localEvidenceCategories.isEmpty == false {
            state = .ready
            summary = source.citedSourceIDs.isEmpty ? "Uses local source context." : "Cites local source context."
        } else if source.sourceAtlasBlockReasons.isEmpty == false {
            state = .blocked
            summary = "Needs source review before this can guide behavior."
        } else {
            state = .missing
            summary = "Needs local source context before this can guide behavior."
        }

        return RecommendationTrustSeamSection(
            id: "trust-seam.source",
            kind: .source,
            title: "Source",
            summary: summary,
            state: state,
            referenceIDs: references
        )
    }

    private static func reasonSection(_ reason: RecommendationTraceReason) -> RecommendationTrustSeamSection {
        let hasReason = reason.summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        return RecommendationTrustSeamSection(
            id: "trust-seam.reason",
            kind: .reason,
            title: "Reason",
            summary: hasReason ? reason.summary : "Needs a stated reason.",
            state: hasReason ? .ready : .missing,
            referenceIDs: orderedUnique([reason.explanationID] + reason.evidenceCategoryIDs)
        )
    }

    private static func fitSection(_ fit: RecommendationTraceFit) -> RecommendationTrustSeamSection {
        let state: RecommendationTrustSeamSectionState
        let summary: String
        switch fit.state {
        case .fits:
            state = fit.canDriveRecommendation ? .ready : .reviewNeeded
            summary = fit.canDriveRecommendation ? "Fits the current recommendation context." : "Fit needs review before behavior changes."
        case .reviewable:
            state = .reviewNeeded
            summary = "Needs review before behavior changes."
        case .sourceNeeded:
            state = .missing
            summary = "Needs source review before behavior changes."
        case .proofNeeded:
            state = .missing
            summary = "Needs proof before behavior changes."
        case .blocked:
            state = .blocked
            summary = "Blocked until the recommendation context changes."
        }

        return RecommendationTrustSeamSection(
            id: "trust-seam.fit",
            kind: .fit,
            title: "Fit",
            summary: summary,
            state: state,
            referenceIDs: orderedUnique(fit.blockReasons)
        )
    }

    private static func uncertaintySection(_ uncertainty: RecommendationTraceUncertainty) -> RecommendationTrustSeamSection {
        let references = orderedUnique(uncertainty.uncertaintyIDs)
        return RecommendationTrustSeamSection(
            id: "trust-seam.uncertainty",
            kind: .uncertainty,
            title: "Uncertainty",
            summary: uncertainty.summaries.isEmpty ? "No stated uncertainty." : uncertainty.summaries.joined(separator: " "),
            state: uncertainty.summaries.isEmpty ? .notApplicable : .reviewNeeded,
            referenceIDs: references
        )
    }

    private static func controlsSection(_ control: RecommendationTraceControl) -> RecommendationTrustSeamSection {
        let references = orderedUnique(control.correctionActionIDs + control.controlActionIDs + control.correctableFieldKeys)
        return RecommendationTrustSeamSection(
            id: "trust-seam.controls",
            kind: .controls,
            title: "Controls",
            summary: control.hasRequiredControl ? "Correction or review control is available." : "Needs a correction or review control.",
            state: control.hasRequiredControl ? .ready : .missing,
            referenceIDs: references
        )
    }

    private static func receiptSection(_ receiptBehavior: RecommendationTraceReceiptBehavior) -> RecommendationTrustSeamSection {
        let references = orderedUnique(receiptBehavior.receiptIDs + receiptBehavior.actionReceiptIDs + receiptBehavior.proofReferenceIDs)
        let state: RecommendationTrustSeamSectionState
        let summary: String
        switch receiptBehavior.state {
        case .receiptAvailable:
            state = receiptBehavior.satisfiesTraceContract ? .ready : .missing
            summary = receiptBehavior.satisfiesTraceContract ? "Receipt or proof reference is available." : "Needs a receipt or proof reference."
        case .receiptRequired:
            state = .reviewNeeded
            summary = "Behavior change must create a receipt."
        case .receiptMissing:
            state = .missing
            summary = "Needs a receipt before behavior changes."
        case .notApplicable:
            state = .notApplicable
            summary = "No receipt is needed for this review."
        }

        return RecommendationTrustSeamSection(
            id: "trust-seam.receipt",
            kind: .receiptBehavior,
            title: "Receipt",
            summary: summary,
            state: state,
            referenceIDs: references
        )
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

private extension RecommendationTraceFitState {
    var canDriveRecommendation: Bool {
        switch self {
        case .fits:
            return true
        case .reviewable, .sourceNeeded, .proofNeeded, .blocked:
            return false
        }
    }
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
