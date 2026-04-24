import Foundation

let eventLedgerSchemaVersion = "event_ledger.native.v1"

enum EventLedgerKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goalCreated = "goal_created"
    case goalUpdated = "goal_updated"
    case goalPaused = "goal_paused"
    case goalCompleted = "goal_completed"
    case goalArchived = "goal_archived"
    case goalScopeItemAdded = "goal_scope_item_added"
    case goalScopeItemRemoved = "goal_scope_item_removed"
    case deliverableAdded = "deliverable_added"
    case deliverableRemoved = "deliverable_removed"
    case planCreated = "plan_created"
    case planUpdated = "plan_updated"
    case planRescheduled = "plan_rescheduled"
    case planRecovered = "plan_recovered"
    case planScheduled = "plan_scheduled"
    case planUnscheduled = "plan_unscheduled"
    case priorityChanged = "priority_changed"
    case urgencyChanged = "urgency_changed"
    case deadlineChanged = "deadline_changed"
    case itemScheduled = "item_scheduled"
    case itemDisplacedByHigherPriority = "item_displaced_by_higher_priority"
    case captureCreated = "capture_created"
    case captureTriaged = "capture_triaged"
    case captureAttachedToGoal = "capture_attached_to_goal"
    case captureArchived = "capture_archived"
    case commitmentCaptured = "commitment_captured"
    case commitmentRouted = "commitment_routed"
    case actionCompleted = "action_completed"
    case actionDelayed = "action_delayed"
    case actionSkipped = "action_skipped"
    case actionMoved = "action_moved"
    case actionSplit = "action_split"
    case recoveryAccepted = "recovery_accepted"
    case recoveryDeclined = "recovery_declined"
    case recoveryDueToPriorityConflict = "recovery_due_to_priority_conflict"
    case userCorrectionAdded = "user_correction_added"
    case reviewCompleted = "review_completed"
    case recommendationShown = "recommendation_shown"
    case recommendationAccepted = "recommendation_accepted"
    case recommendationDismissed = "recommendation_dismissed"
    case calendarContextObserved = "calendar_context_observed"
    case contextLensChanged = "context_lens_changed"
    case contextInferred = "context_inferred"
    case syncConflictDetected = "sync_conflict_detected"
    case accessibilityAuditRecorded = "accessibility_audit_recorded"
    case exportCreated = "export_created"
    case importCompleted = "import_completed"
}

enum EventLedgerSource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case today
    case goals
    case capture
    case plan
    case you
    case memoryLens = "memory_lens"
    case goalEngine = "goal_engine"
    case planner
    case recovery
    case recommendation
    case accessibilityNutrition = "accessibility_nutrition"
    case sync
    case exportImport = "export_import"
    case calendar
    case system
}

enum EventLedgerTone: String, Codable, Sendable, Equatable, Hashable {
    case neutral
    case positive
    case recovering
    case caution
    case correction
}

enum EventLedgerPrivacyClassification: String, Codable, Sendable, Equatable, Hashable {
    case standard
    case sensitive
    case privateUserText = "private_user_text"
    case calendarDerived = "calendar_derived"
    case syncMetadata = "sync_metadata"
}

enum EventLedgerEvidenceKind: String, Codable, Sendable, Equatable, Hashable {
    case goal
    case capture
    case plan
    case review
    case feedbackEvent = "feedback_event"
    case progressEvidence = "progress_evidence"
    case teachingSignal = "teaching_signal"
    case recommendation
    case calendarContext = "calendar_context"
    case accessibilityAudit = "accessibility_audit"
    case syncConflict = "sync_conflict"
    case externalCommand = "external_command"
}

struct EventLedgerEvidenceReference: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: EventLedgerEvidenceKind
    let occurredAt: String?
    let summary: String?

    init(
        id: String,
        kind: EventLedgerEvidenceKind,
        occurredAt: String? = nil,
        summary: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.occurredAt = occurredAt
        self.summary = summary
    }
}

struct EventLedgerTrustMetadata: Codable, Sendable, Equatable, Hashable {
    let confidence: Double?
    let confidenceLabel: RecommendationConfidence?
    let isUserConfirmed: Bool
    let requiresReview: Bool

    init(
        confidence: Double? = nil,
        confidenceLabel: RecommendationConfidence? = nil,
        isUserConfirmed: Bool = false,
        requiresReview: Bool = false
    ) {
        let boundedConfidence = confidence.map { min(max($0, 0), 1) }
        self.confidence = boundedConfidence
        self.confidenceLabel = confidenceLabel ?? boundedConfidence.map(RecommendationConfidence.label(for:))
        self.isUserConfirmed = isUserConfirmed
        self.requiresReview = requiresReview
    }
}

struct EventLedgerEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: EventLedgerKind
    let occurredAt: String
    let source: EventLedgerSource
    let goalID: String?
    let captureID: String?
    let planID: String?
    let planScope: String?
    let reviewID: String?
    let title: String
    let summary: String?
    let semanticState: String?
    let tone: EventLedgerTone
    let trust: EventLedgerTrustMetadata
    let evidenceReferences: [EventLedgerEvidenceReference]
    let metadata: [String: String]
    let payload: [String: String]
    let schemaVersion: String
    let privacy: EventLedgerPrivacyClassification
    let localOnly: Bool
    let createdAt: String
    let updatedAt: String

    init(
        id: String,
        kind: EventLedgerKind,
        occurredAt: String,
        source: EventLedgerSource,
        goalID: String? = nil,
        captureID: String? = nil,
        planID: String? = nil,
        planScope: String? = nil,
        reviewID: String? = nil,
        title: String,
        summary: String? = nil,
        semanticState: String? = nil,
        tone: EventLedgerTone = .neutral,
        trust: EventLedgerTrustMetadata = EventLedgerTrustMetadata(),
        evidenceReferences: [EventLedgerEvidenceReference] = [],
        metadata: [String: String] = [:],
        payload: [String: String] = [:],
        schemaVersion: String = eventLedgerSchemaVersion,
        privacy: EventLedgerPrivacyClassification = .standard,
        localOnly: Bool = true,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.occurredAt = occurredAt
        self.source = source
        self.goalID = goalID
        self.captureID = captureID
        self.planID = planID
        self.planScope = planScope
        self.reviewID = reviewID
        self.title = title
        self.summary = summary
        self.semanticState = semanticState
        self.tone = tone
        self.trust = trust
        self.evidenceReferences = evidenceReferences.sorted { lhs, rhs in
            if lhs.kind.rawValue != rhs.kind.rawValue {
                return lhs.kind.rawValue < rhs.kind.rawValue
            }
            return lhs.id < rhs.id
        }
        self.metadata = metadata
        self.payload = payload
        self.schemaVersion = schemaVersion
        self.privacy = privacy
        self.localOnly = localOnly
        self.createdAt = createdAt ?? occurredAt
        self.updatedAt = updatedAt ?? occurredAt
    }

    func redacted(at timestamp: String) -> EventLedgerEntry {
        EventLedgerEntry(
            id: id,
            kind: kind,
            occurredAt: occurredAt,
            source: source,
            goalID: goalID,
            captureID: captureID,
            planID: planID,
            planScope: planScope,
            reviewID: reviewID,
            title: "Redacted event",
            summary: nil,
            semanticState: semanticState,
            tone: tone,
            trust: trust,
            evidenceReferences: evidenceReferences,
            metadata: metadata.merging(["redacted": "true"], uniquingKeysWith: { _, new in new }),
            payload: [:],
            schemaVersion: schemaVersion,
            privacy: .privateUserText,
            localOnly: localOnly,
            createdAt: createdAt,
            updatedAt: timestamp
        )
    }
}

extension EventLedgerEntry {
    static func fromFeedbackEvent(
        _ event: GoalFeedbackEvent,
        goalID: String,
        source: EventLedgerSource = .goalEngine
    ) -> EventLedgerEntry {
        let kind: EventLedgerKind
        let title: String
        let tone: EventLedgerTone
        switch event {
        case .completed:
            kind = .actionCompleted
            title = "Action completed"
            tone = .positive
        case .skipped:
            kind = .actionSkipped
            title = "Action skipped"
            tone = .recovering
        case .delayed:
            kind = .actionDelayed
            title = "Action delayed"
            tone = .recovering
        case .edited:
            kind = .planUpdated
            title = "Plan wording updated"
            tone = .neutral
        case .confused:
            kind = .userCorrectionAdded
            title = "Clarification signal recorded"
            tone = .correction
        case .tooBig, .askedForSmallerVersion:
            kind = .actionSplit
            title = "Smaller action requested"
            tone = .recovering
        case .tooEasy, .notRelevant, .askedWhyThisMatters:
            kind = .userCorrectionAdded
            title = "User correction recorded"
            tone = .correction
        }

        return EventLedgerEntry(
            id: "ledger.feedback.\(event.base.id)",
            kind: kind,
            occurredAt: event.base.occurredAt,
            source: source,
            goalID: goalID,
            title: title,
            summary: event.base.note,
            semanticState: event.kind.rawValue,
            tone: tone,
            trust: EventLedgerTrustMetadata(isUserConfirmed: true),
            evidenceReferences: [
                EventLedgerEvidenceReference(
                    id: event.base.id,
                    kind: .feedbackEvent,
                    occurredAt: event.base.occurredAt,
                    summary: event.kind.rawValue
                )
            ],
            metadata: [
                "legacyKind": event.kind.rawValue,
                "stepID": event.base.stepID
            ],
            privacy: event.base.note == nil ? .standard : .privateUserText
        )
    }

    static func fromProgressEvidence(
        _ evidence: ProgressEvidence,
        source: EventLedgerSource = .goalEngine
    ) -> EventLedgerEntry {
        EventLedgerEntry(
            id: "ledger.evidence.\(evidence.id)",
            kind: evidence.evidenceKind == .stepCompleted ? .actionCompleted : .goalUpdated,
            occurredAt: evidence.capturedAt,
            source: source,
            goalID: evidence.goalID,
            title: "Progress evidence recorded",
            summary: evidence.note,
            semanticState: evidence.evidenceKind.rawValue,
            tone: .positive,
            trust: EventLedgerTrustMetadata(confidence: evidence.confidenceDelta.map { 0.5 + $0 }),
            evidenceReferences: [
                EventLedgerEvidenceReference(
                    id: evidence.id,
                    kind: .progressEvidence,
                    occurredAt: evidence.capturedAt,
                    summary: evidence.evidenceKind.rawValue
                )
            ],
            metadata: [
                "evidenceKind": evidence.evidenceKind.rawValue,
                "evidenceSource": evidence.source.rawValue,
                "stepID": evidence.stepID ?? ""
            ].filter { $0.value.isEmpty == false },
            privacy: evidence.note == nil ? .standard : .privateUserText
        )
    }

    static func fromTeachingSignal(
        _ signal: GoalTeachingSignal,
        source: EventLedgerSource = .goalEngine
    ) -> EventLedgerEntry {
        EventLedgerEntry(
            id: "ledger.teaching.\(signal.id)",
            kind: .userCorrectionAdded,
            occurredAt: signal.updatedAt,
            source: source,
            goalID: signal.goalID,
            title: "Correction added",
            summary: signal.userNote,
            semanticState: signal.kind.rawValue,
            tone: .correction,
            trust: EventLedgerTrustMetadata(isUserConfirmed: true),
            evidenceReferences: [
                EventLedgerEvidenceReference(
                    id: signal.id,
                    kind: .teachingSignal,
                    occurredAt: signal.updatedAt,
                    summary: signal.kind.rawValue
                )
            ],
            metadata: [
                "teachingKind": signal.kind.rawValue,
                "teachingSource": signal.source.rawValue,
                "applicationKey": signal.applicationKey
            ],
            privacy: signal.userNote == nil ? .standard : .privateUserText
        )
    }
}
