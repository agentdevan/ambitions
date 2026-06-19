import Foundation

let actionClosureReceiptSchemaVersion = "action_closure_receipt.native.v1"

enum ActionReceiptResultState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case created
    case changed
    case scheduled
    case moved
    case attached
    case detached
    case exportedPrepared = "exported_prepared"
    case draftedPrepared = "drafted_prepared"
    case completed
    case failedSafely = "failed_safely"
    case needsConfirmation = "needs_confirmation"
    case noOp = "no_op"
    case undoAvailable = "undo_available"
    case undoUnavailable = "undo_unavailable"
    case correctionAvailable = "correction_available"
}

enum ActionReceiptUndoAvailability: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unavailable
    case availableLocal = "available_local"
    case requiresConfirmation = "requires_confirmation"
    case unsafe
    case notSupportedYet = "not_supported_yet"

    var isAvailable: Bool {
        switch self {
        case .availableLocal, .requiresConfirmation:
            return true
        case .unavailable, .unsafe, .notSupportedYet:
            return false
        }
    }
}

enum ActionReceiptCorrectionAvailability: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unavailable
    case available
    case availableWithReason = "available_with_reason"
    case notSupportedYet = "not_supported_yet"

    var isAvailable: Bool {
        switch self {
        case .available, .availableWithReason:
            return true
        case .unavailable, .notSupportedYet:
            return false
        }
    }
}

enum ActionReceiptSafetyState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case normal
    case degraded
    case safeFailure = "safe_failure"
    case externalUnavailable = "external_unavailable"
    case confirmationRequired = "confirmation_required"
}

enum ActionReceiptSourceDomain: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case today
    case goals
    case capture
    case time
    case you
    case reviews
    case goalDetail = "goal_detail"
    case commandPipeline = "command_pipeline"
    case eventLedger = "event_ledger"
    case proof
    case resource
    case commitment
    case calendar
    case exportImport = "export_import"
    case externalSurface = "external_surface"
    case system

    var lifeGraphSourceDomain: LifeGraphSourceDomain {
        switch self {
        case .today:
            return .today
        case .goals, .goalDetail:
            return .goals
        case .capture:
            return .capture
        case .time:
            return .time
        case .you, .reviews:
            return .you
        case .commandPipeline:
            return .commandPipeline
        case .eventLedger:
            return .eventLedger
        case .proof:
            return .proof
        case .resource:
            return .resource
        case .commitment:
            return .commitment
        case .calendar, .exportImport, .externalSurface, .system:
            return .system
        }
    }
}

enum ActionReceiptChangedFactKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case createdCapture = "created_capture"
    case attachedCaptureToGoal = "attached_capture_to_goal"
    case createdOneStepGoal = "created_one_step_goal"
    case attachedTaskToGoal = "attached_task_to_goal"
    case promotedTaskToGoal = "promoted_task_to_goal"
    case demotedGoalToTask = "demoted_goal_to_task"
    case movedActionToLater = "moved_action_to_later"
    case completedAction = "completed_action"
    case completedTask = "completed_task"
    case archivedTask = "archived_task"
    case markedWaiting = "marked_waiting"
    case preparedExport = "prepared_export"
    case preparedDraft = "prepared_draft"
    case failedSafely = "failed_safely"
    case needsConfirmation = "needs_confirmation"
    case changedField = "changed_field"
    case noChange = "no_change"
    case lifeContextAdded = "life_context_added"
    case lifeContextCorrected = "life_context_corrected"
    case lifeContextPaused = "life_context_paused"
    case lifeContextDeleted = "life_context_deleted"
    case lifeContextUsedInRecommendation = "life_context_used_in_recommendation"
    case personalizationFactorUsed = "personalization_factor_used"
    case personalizationFactorDisabled = "personalization_factor_disabled"
    case personalizationFactorExpired = "personalization_factor_expired"
    case recommendationChangedDueToContext = "recommendation_changed_due_to_context"
    case staleContextReducedConfidence = "stale_context_reduced_confidence"
    case replayDifferenceDetected = "replay_difference_detected"
    case fallbackReasoningActivated = "fallback_reasoning_activated"
    case demographicFactorRejected = "demographic_factor_rejected"
    case candidateRejectedByConstraint = "candidate_rejected_by_constraint"
    case stepRejected = "step_rejected"
    case rejectionReasonSaved = "rejection_reason_saved"
    case alternateStepGenerated = "alternate_step_generated"
    case alternateStepApproved = "alternate_step_approved"
    case dependencyBlocked = "dependency_blocked"
    case deadlinePressureChanged = "deadline_pressure_changed"
    case priorityPressureChanged = "priority_pressure_changed"
    case timelineStillOnTrack = "timeline_still_on_track"
    case deadlineAtRisk = "deadline_at_risk"
    case scopeReviewSuggested = "scope_review_suggested"
    case rejectedCandidateSuppressed = "rejected_candidate_suppressed"
    case preferenceLearned = "preference_learned"
    case historicalContextImported = "historical_context_imported"
    case historicalContextConfirmed = "historical_context_confirmed"
    case historicalContextMarkedOlder = "historical_context_marked_older"
    case eligibilityPathwayChanged = "eligibility_pathway_changed"
    case travelConstraintChanged = "travel_constraint_changed"
    case facilityAccessChanged = "facility_access_changed"
}

struct ActionReceiptChangedFact: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: ActionReceiptChangedFactKind
    let object: LifeGraphObjectReference?
    let fieldName: String?
    let previousValueSummary: String?
    let newValueSummary: String?
    let summary: String

    init(
        id: String,
        kind: ActionReceiptChangedFactKind,
        object: LifeGraphObjectReference? = nil,
        fieldName: String? = nil,
        previousValueSummary: String? = nil,
        newValueSummary: String? = nil,
        summary: String
    ) {
        self.id = Self.normalizedRequired(id)
        self.kind = kind
        self.object = object
        self.fieldName = Self.normalizedOptional(fieldName)
        self.previousValueSummary = Self.normalizedOptional(previousValueSummary)
        self.newValueSummary = Self.normalizedOptional(newValueSummary)
        self.summary = Self.normalizedRequired(summary)
    }

    var isWellFormed: Bool {
        id.isEmpty == false && summary.isEmpty == false && (object?.isWellFormed ?? true)
    }

    var orderingKey: String {
        [
            object?.stableKey ?? "",
            kind.rawValue,
            fieldName ?? "",
            summary.lowercased(),
            id
        ].joined(separator: ":")
    }

    static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }
}

enum ActionReceiptNextActionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case openToday = "open_today"
    case openTime = "open_time"
    case reviewGoal = "review_goal"
    case correctAssumption = "correct_assumption"
    case undoIfAvailable = "undo_if_available"
    case dismiss
}

struct ActionReceiptNextAction: Codable, Sendable, Equatable, Hashable {
    let kind: ActionReceiptNextActionKind
    let title: String
    let destination: AmbitionsCommandDestination?
    let target: LifeGraphObjectReference?

    init(
        kind: ActionReceiptNextActionKind,
        title: String,
        destination: AmbitionsCommandDestination? = nil,
        target: LifeGraphObjectReference? = nil
    ) {
        self.kind = kind
        self.title = ActionReceiptChangedFact.normalizedRequired(title)
        self.destination = destination
        self.target = target
    }

    var isWellFormed: Bool {
        title.isEmpty == false && (target?.isWellFormed ?? true)
    }
}

struct ActionReceiptWhyExplanation: Codable, Sendable, Equatable, Hashable {
    let body: String?
    let recommendationExplanationIDs: [String]
    let eventLedgerEntryIDs: [String]

    init(
        body: String? = nil,
        recommendationExplanationIDs: [String] = [],
        eventLedgerEntryIDs: [String] = []
    ) {
        self.body = ActionReceiptChangedFact.normalizedOptional(body)
        self.recommendationExplanationIDs = Self.normalizedUnique(recommendationExplanationIDs)
        self.eventLedgerEntryIDs = Self.normalizedUnique(eventLedgerEntryIDs)
    }

    var isEmpty: Bool {
        body == nil && recommendationExplanationIDs.isEmpty && eventLedgerEntryIDs.isEmpty
    }

    static func normalizedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map(ActionReceiptChangedFact.normalizedRequired).filter { $0.isEmpty == false })).sorted()
    }
}

struct ActionReceiptSafeFailure: Codable, Sendable, Equatable, Hashable {
    let whatFailed: String
    let whyFailed: String?
    let unchangedFacts: [String]
    let nextSafeAction: ActionReceiptNextAction?

    init(
        whatFailed: String,
        whyFailed: String? = nil,
        unchangedFacts: [String],
        nextSafeAction: ActionReceiptNextAction? = nil
    ) {
        self.whatFailed = ActionReceiptChangedFact.normalizedRequired(whatFailed)
        self.whyFailed = ActionReceiptChangedFact.normalizedOptional(whyFailed)
        self.unchangedFacts = Array(Set(unchangedFacts.map(ActionReceiptChangedFact.normalizedRequired).filter { $0.isEmpty == false })).sorted()
        self.nextSafeAction = nextSafeAction
    }

    var isWellFormed: Bool {
        whatFailed.isEmpty == false &&
            unchangedFacts.isEmpty == false &&
            (nextSafeAction?.isWellFormed ?? true)
    }
}

struct ActionReceiptDisplaySummary: Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let resultState: ActionReceiptResultState
    let occurredAt: String
    let sourceDomain: ActionReceiptSourceDomain
    let undoAvailability: ActionReceiptUndoAvailability
    let correctionAvailability: ActionReceiptCorrectionAvailability
    let nextActionTitle: String?
    let safetyState: ActionReceiptSafetyState
}

enum ActionReceiptPrivacyLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case safeToShow = "safe_to_show"
    case privateItem = "private"
    case sensitive
    case redacted
    case unavailable

    var requiresRedactionByDefault: Bool {
        switch self {
        case .safeToShow:
            return false
        case .privateItem, .sensitive, .redacted, .unavailable:
            return true
        }
    }
}

enum ActionReceiptProjectionDetail: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fullDetail = "full_detail"
    case redacted
}

enum ActionReceiptTrustStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case safeToShow = "safe_to_show"
    case needsReview = "needs_review"
    case confirmationRequired = "confirmation_required"
    case safeFailure = "safe_failure"
    case missingDetail = "missing_detail"
}

enum ActionReceiptProofRelevance: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notProof = "not_proof"
    case mayCountAsProof = "may_count_as_proof"
    case countsAsProof = "counts_as_proof"
    case needsConfirmation = "needs_confirmation"
}
