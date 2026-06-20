import Foundation

let executionResilienceSchemaVersion = "execution_resilience.native.v1"

enum ExecutionDisruptionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missedAction = "missed_action"
    case slippedDeadline = "slipped_deadline"
    case overloadedDay = "overloaded_day"
    case noOpenWindow = "no_open_window"
    case blockedByWaiting = "blocked_by_waiting"
    case priorityConflict = "priority_conflict"
    case lowerPriorityDisplaced = "lower_priority_displaced"
    case passiveGoalCrowding = "passive_goal_crowding"
    case calendarConflict = "calendar_conflict"
    case contextMismatch = "context_mismatch"
    case lowCapacity = "low_capacity"
    case stalePlan = "stale_plan"
    case underdefinedNextStep = "underdefined_next_step"
    case scopeIncrease = "scope_increase"
    case deliverableAdded = "deliverable_added"
    case recoveryAlreadyInProgress = "recovery_already_in_progress"
}

enum ExecutionRecoveryStrategy: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case doSmallestNextStep = "do_smallest_next_step"
    case rescheduleLater = "reschedule_later"
    case splitIntoSmallerStep = "split_into_smaller_step"
    case deferPassiveWork = "defer_passive_work"
    case protectDeadlineWork = "protect_deadline_work"
    case moveToWaiting = "move_to_waiting"
    case clarifyNextStep = "clarify_next_step"
    case reduceScope = "reduce_scope"
    case acceptSlip = "accept_slip"
    case askForDecision = "ask_for_decision"
    case keepAsSomeday = "keep_as_someday"
    case openTime = "open_time"
    case openGoal = "open_goal"
    case openCapture = "open_capture"
}

enum ExecutionRecoveryStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case stable
    case watch
    case needsRecovery = "needs_recovery"
    case atRisk = "at_risk"
    case blocked
    case recovering
}

enum ExecutionRecoveryReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missedAction = "missed_action"
    case deadlineCompression = "deadline_compression"
    case capacityPressure = "capacity_pressure"
    case priorityProtection = "priority_protection"
    case passiveDeferral = "passive_deferral"
    case waitingOrBlocked = "waiting_or_blocked"
    case noOpenWindow = "no_open_window"
    case calendarConflict = "calendar_conflict"
    case contextMismatch = "context_mismatch"
    case underdefinedNextStep = "underdefined_next_step"
    case scopeChanged = "scope_changed"
    case recoveryInProgress = "recovery_in_progress"
    case baselineAssumption = "baseline_assumption"
}

struct ExecutionDisruption: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: ExecutionDisruptionKind
    let title: String
    let summary: String
    let severity: NowPressureLevel
    let relatedGoalID: String?
    let relatedCaptureID: String?
    let relatedTimeID: String?
    let relatedAssessmentID: String?
    let evidenceReferenceIDs: [String]

    init(
        id: String,
        kind: ExecutionDisruptionKind,
        title: String,
        summary: String,
        severity: NowPressureLevel,
        relatedGoalID: String? = nil,
        relatedCaptureID: String? = nil,
        relatedTimeID: String? = nil,
        relatedAssessmentID: String? = nil,
        evidenceReferenceIDs: [String] = []
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.summary = summary
        self.severity = severity
        self.relatedGoalID = relatedGoalID
        self.relatedCaptureID = relatedCaptureID
        self.relatedTimeID = relatedTimeID
        self.relatedAssessmentID = relatedAssessmentID
        self.evidenceReferenceIDs = Self.normalized(evidenceReferenceIDs)
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }
}

struct RecoveryTradeoff: Codable, Sendable, Equatable, Hashable {
    let summary: String
    let protectsHighPriorityWork: Bool
    let defersPassiveOrFlexibleWork: Bool
    let displacesLowerPriorityWork: Bool
    let requiresUserDecision: Bool
}

struct DisplacedWorkSummary: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let relatedGoalID: String?
    let relatedCaptureID: String?
    let reason: ExecutionRecoveryReason
    let pressure: NowPressureLevel
    let isPassiveOrFlexible: Bool
}

struct ProtectedWorkSummary: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let relatedGoalID: String?
    let relatedCaptureID: String?
    let deadline: String?
    let consequence: NowPressureLevel
    let pressure: NowPressureLevel
}

struct ExecutionRecoveryRecommendation: Codable, Sendable, Equatable, Hashable {
    let optionID: String
    let title: String
    let summary: String
    let reason: ExecutionRecoveryReason
    let confidence: RecommendationConfidence
    let explanationID: String?
}

struct ExecutionRecoveryOption: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let strategy: ExecutionRecoveryStrategy
    let expectedEffect: String
    let tradeoff: RecoveryTradeoff
    let urgencyBasis: String
    let deadlineBasis: String?
    let capacityBasis: String
    let protectsHighPriorityWork: Bool
    let defersPassiveOrFlexibleWork: Bool
    let requiresUserConfirmation: Bool
    let relatedCommandKind: AmbitionsCommandKind?
    let relatedExplanationID: String?
    let relatedGoalID: String?
    let relatedCaptureID: String?
    let relatedTimeID: String?
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]

    init(
        id: String,
        title: String,
        summary: String,
        strategy: ExecutionRecoveryStrategy,
        expectedEffect: String,
        tradeoff: RecoveryTradeoff,
        urgencyBasis: String,
        deadlineBasis: String? = nil,
        capacityBasis: String,
        protectsHighPriorityWork: Bool = false,
        defersPassiveOrFlexibleWork: Bool = false,
        requiresUserConfirmation: Bool = true,
        relatedCommandKind: AmbitionsCommandKind? = nil,
        relatedExplanationID: String? = nil,
        relatedGoalID: String? = nil,
        relatedCaptureID: String? = nil,
        relatedTimeID: String? = nil,
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = []
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.strategy = strategy
        self.expectedEffect = expectedEffect
        self.tradeoff = tradeoff
        self.urgencyBasis = urgencyBasis
        self.deadlineBasis = deadlineBasis
        self.capacityBasis = capacityBasis
        self.protectsHighPriorityWork = protectsHighPriorityWork
        self.defersPassiveOrFlexibleWork = defersPassiveOrFlexibleWork
        self.requiresUserConfirmation = requiresUserConfirmation
        self.relatedCommandKind = relatedCommandKind
        self.relatedExplanationID = relatedExplanationID
        self.relatedGoalID = relatedGoalID
        self.relatedCaptureID = relatedCaptureID
        self.relatedTimeID = relatedTimeID
        self.eventLedgerEntryIDs = Self.normalized(eventLedgerEntryIDs)
        self.recommendationExplanationIDs = Self.normalized(recommendationExplanationIDs + [relatedExplanationID].compactMap { $0 })
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }
}

struct ExecutionResilienceInput: Sendable, Equatable {
    let generatedAt: Date
    let activeContextLens: NowContextLens
    let believabilitySnapshot: GoalBelievabilitySnapshot?
    let believabilityAssessments: [GoalBelievabilityAssessment]
    let realitySnapshot: RealitySnapshot?
    let nowState: CanonicalNowState?
    let captures: [Capture]
    let eventLedgerEntries: [EventLedgerEntry]
    let recommendationExplanations: [RecommendationExplanation]
    let commands: [AmbitionsCommand]
    let timeID: String?
    let reviewID: String?

    init(
        generatedAt: Date,
        activeContextLens: NowContextLens = .all,
        believabilitySnapshot: GoalBelievabilitySnapshot? = nil,
        believabilityAssessments: [GoalBelievabilityAssessment] = [],
        realitySnapshot: RealitySnapshot? = nil,
        nowState: CanonicalNowState? = nil,
        captures: [Capture] = [],
        eventLedgerEntries: [EventLedgerEntry] = [],
        recommendationExplanations: [RecommendationExplanation] = [],
        commands: [AmbitionsCommand] = [],
        timeID: String? = nil,
        reviewID: String? = nil
    ) {
        self.generatedAt = generatedAt
        self.activeContextLens = activeContextLens
        self.believabilitySnapshot = believabilitySnapshot
        self.believabilityAssessments = believabilityAssessments
        self.realitySnapshot = realitySnapshot
        self.nowState = nowState
        self.captures = captures
        self.eventLedgerEntries = eventLedgerEntries
        self.recommendationExplanations = recommendationExplanations
        self.commands = commands
        self.timeID = timeID
        self.reviewID = reviewID
    }
}

typealias ExecutionResilienceProjectionInput = ExecutionResilienceInput

struct ExecutionResilienceAssessment: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let generatedAt: String
    let relatedGoalIDs: [String]
    let relatedCaptureIDs: [String]
    let relatedTimeIDs: [String]
    let relatedReviewIDs: [String]
    let relatedBelievabilityAssessmentIDs: [String]
    let relatedRealitySnapshotID: String?
    let relatedNowStateID: String?
    let status: ExecutionRecoveryStatus
    let disruptions: [ExecutionDisruption]
    let recoveryOptions: [ExecutionRecoveryOption]
    let recommendedRecoveryOptionID: String?
    let smallestUsefulNextStep: String?
    let protectedHighPriorityWork: [ProtectedWorkSummary]
    let displacedLowerPriorityWork: [DisplacedWorkSummary]
    let passiveWorkDeferredCalmly: [DisplacedWorkSummary]
    let waitingOrBlockedRemovedFromPressure: [DisplacedWorkSummary]
    let reasons: [ExecutionRecoveryReason]
    let assumptions: [RecommendationExplanationAssumption]
    let correctionSuggestions: [RecommendationExplanationCorrectionActionKind]
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
    let schemaVersion: String

    init(
        id: String,
        generatedAt: String,
        relatedGoalIDs: [String] = [],
        relatedCaptureIDs: [String] = [],
        relatedTimeIDs: [String] = [],
        relatedReviewIDs: [String] = [],
        relatedBelievabilityAssessmentIDs: [String] = [],
        relatedRealitySnapshotID: String? = nil,
        relatedNowStateID: String? = nil,
        status: ExecutionRecoveryStatus,
        disruptions: [ExecutionDisruption],
        recoveryOptions: [ExecutionRecoveryOption],
        recommendedRecoveryOptionID: String? = nil,
        smallestUsefulNextStep: String? = nil,
        protectedHighPriorityWork: [ProtectedWorkSummary] = [],
        displacedLowerPriorityWork: [DisplacedWorkSummary] = [],
        passiveWorkDeferredCalmly: [DisplacedWorkSummary] = [],
        waitingOrBlockedRemovedFromPressure: [DisplacedWorkSummary] = [],
        reasons: [ExecutionRecoveryReason] = [],
        assumptions: [RecommendationExplanationAssumption] = [],
        correctionSuggestions: [RecommendationExplanationCorrectionActionKind] = [],
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = [],
        localOnly: Bool = true,
        privacy: EventLedgerPrivacyClassification = .standard,
        schemaVersion: String = executionResilienceSchemaVersion
    ) {
        self.id = id
        self.generatedAt = generatedAt
        self.relatedGoalIDs = Self.normalized(relatedGoalIDs)
        self.relatedCaptureIDs = Self.normalized(relatedCaptureIDs)
        self.relatedTimeIDs = Self.normalized(relatedTimeIDs)
        self.relatedReviewIDs = Self.normalized(relatedReviewIDs)
        self.relatedBelievabilityAssessmentIDs = Self.normalized(relatedBelievabilityAssessmentIDs)
        self.relatedRealitySnapshotID = relatedRealitySnapshotID
        self.relatedNowStateID = relatedNowStateID
        self.status = status
        self.disruptions = disruptions.sorted { lhs, rhs in
            if lhs.severity != rhs.severity { return Self.rank(lhs.severity) > Self.rank(rhs.severity) }
            return lhs.id < rhs.id
        }
        self.recoveryOptions = recoveryOptions.sorted { lhs, rhs in
            if lhs.requiresUserConfirmation != rhs.requiresUserConfirmation { return lhs.requiresUserConfirmation && !rhs.requiresUserConfirmation }
            return lhs.id < rhs.id
        }
        self.recommendedRecoveryOptionID = recommendedRecoveryOptionID
        self.smallestUsefulNextStep = smallestUsefulNextStep
        self.protectedHighPriorityWork = protectedHighPriorityWork.sorted { $0.id < $1.id }
        self.displacedLowerPriorityWork = displacedLowerPriorityWork.sorted { $0.id < $1.id }
        self.passiveWorkDeferredCalmly = passiveWorkDeferredCalmly.sorted { $0.id < $1.id }
        self.waitingOrBlockedRemovedFromPressure = waitingOrBlockedRemovedFromPressure.sorted { $0.id < $1.id }
        self.reasons = Array(Set(reasons)).sorted { $0.rawValue < $1.rawValue }
        self.assumptions = assumptions.sorted { $0.id < $1.id }
        self.correctionSuggestions = Array(Set(correctionSuggestions)).sorted { $0.rawValue < $1.rawValue }
        self.eventLedgerEntryIDs = Self.normalized(eventLedgerEntryIDs)
        self.recommendationExplanationIDs = Self.normalized(recommendationExplanationIDs)
        self.localOnly = localOnly
        self.privacy = privacy
        self.schemaVersion = schemaVersion
    }

    var recommendedRecoveryOption: ExecutionRecoveryOption? {
        recoveryOptions.first { $0.id == recommendedRecoveryOptionID } ?? recoveryOptions.first
    }

    var recommendation: ExecutionRecoveryRecommendation? {
        guard let option = recommendedRecoveryOption else { return nil }
        return ExecutionRecoveryRecommendation(
            optionID: option.id,
            title: option.title,
            summary: option.summary,
            reason: reasons.first ?? .baselineAssumption,
            confidence: status == .stable ? .high : .medium,
            explanationID: option.relatedExplanationID
        )
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }

    private static func rank(_ level: NowPressureLevel) -> Int {
        switch level {
        case .none: 0
        case .low: 1
        case .moderate: 2
        case .elevated: 3
        case .high: 4
        case .critical: 5
        }
    }
}

struct ExecutionResilienceSnapshot: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let generatedAt: String
    let assessments: [ExecutionResilienceAssessment]
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]
    let relatedRealitySnapshotID: String?
    let relatedNowStateID: String?
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
    let schemaVersion: String

    init(
        id: String,
        generatedAt: String,
        assessments: [ExecutionResilienceAssessment],
        relatedRealitySnapshotID: String? = nil,
        relatedNowStateID: String? = nil,
        localOnly: Bool = true,
        schemaVersion: String = executionResilienceSchemaVersion
    ) {
        self.id = id
        self.generatedAt = generatedAt
        self.assessments = assessments.sorted { $0.id < $1.id }
        self.eventLedgerEntryIDs = Array(Set(assessments.flatMap(\.eventLedgerEntryIDs))).sorted()
        self.recommendationExplanationIDs = Array(Set(assessments.flatMap(\.recommendationExplanationIDs))).sorted()
        self.relatedRealitySnapshotID = relatedRealitySnapshotID
        self.relatedNowStateID = relatedNowStateID
        self.localOnly = localOnly
        self.privacy = assessments.contains { $0.privacy == .privateUserText }
            ? .privateUserText
            : (assessments.contains { $0.privacy == .calendarDerived } ? .calendarDerived : .standard)
        self.schemaVersion = schemaVersion
    }
}

