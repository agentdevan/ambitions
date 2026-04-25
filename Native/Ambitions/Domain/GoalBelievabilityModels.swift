import Foundation

let goalBelievabilitySchemaVersion = "goal_believability.native.v1"

enum GoalHealthStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case believable
    case tight
    case atRisk = "at_risk"
    case unrealistic
    case blocked
    case underdefined
    case passive
    case optionalSomeday = "optional_someday"
    case waiting
}

enum GoalHealthSignal: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case enoughCapacity = "enough_capacity"
    case limitedCapacity = "limited_capacity"
    case noOpenWindow = "no_open_window"
    case deadlineClose = "deadline_close"
    case hardDeadline = "hard_deadline"
    case highConsequence = "high_consequence"
    case lowConsequence = "low_consequence"
    case highEffort = "high_effort"
    case passiveFlexible = "passive_flexible"
    case activePriority = "active_priority"
    case contextMismatch = "context_mismatch"
    case calendarDerivedConflict = "calendar_derived_conflict"
    case missingDeadline = "missing_deadline"
    case missingEffort = "missing_effort"
    case missingPriority = "missing_priority"
    case blockedByWaiting = "blocked_by_waiting"
    case scopeIncreased = "scope_increased"
    case deliverableAdded = "deliverable_added"
    case recoveryNeeded = "recovery_needed"
}

enum GoalBelievabilitySubjectKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goal
    case goalNextAction = "goal_next_action"
    case captureCommitment = "capture_commitment"
    case planSeed = "plan_seed"
    case deliverableSeed = "deliverable_seed"
    case scopeChangeSeed = "scope_change_seed"
}

enum GoalPosture: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case active
    case passive
    case optionalSomeday = "optional_someday"
    case waiting
    case blocked
    case underdefined
}

struct GoalCapacityFit: Codable, Sendable, Equatable, Hashable {
    let level: NowPressureLevel
    let requiredMinutes: Int?
    let availableOpenMinutes: Int
    let openWindowCount: Int
    let openWindowFit: NowPressureLevel
    let hasEnoughCapacity: Bool
    let summary: String

    init(
        level: NowPressureLevel,
        requiredMinutes: Int? = nil,
        availableOpenMinutes: Int = 0,
        openWindowCount: Int = 0,
        openWindowFit: NowPressureLevel,
        hasEnoughCapacity: Bool,
        summary: String
    ) {
        self.level = level
        self.requiredMinutes = requiredMinutes
        self.availableOpenMinutes = max(0, availableOpenMinutes)
        self.openWindowCount = max(0, openWindowCount)
        self.openWindowFit = openWindowFit
        self.hasEnoughCapacity = hasEnoughCapacity
        self.summary = summary
    }
}

struct GoalDeadlineRisk: Codable, Sendable, Equatable, Hashable {
    let level: NowPressureLevel
    let deadline: Date?
    let deadlineText: String?
    let deadlineKind: CaptureDeadlineKind?
    let daysUntilDeadline: Int?
    let openMinutesBeforeDeadline: Int
    let isDeadlineBound: Bool
    let isHardDeadline: Bool
    let summary: String

    init(
        level: NowPressureLevel,
        deadline: Date? = nil,
        deadlineText: String? = nil,
        deadlineKind: CaptureDeadlineKind? = nil,
        daysUntilDeadline: Int? = nil,
        openMinutesBeforeDeadline: Int = 0,
        isDeadlineBound: Bool = false,
        isHardDeadline: Bool = false,
        summary: String
    ) {
        self.level = level
        self.deadline = deadline
        self.deadlineText = deadlineText
        self.deadlineKind = deadlineKind
        self.daysUntilDeadline = daysUntilDeadline
        self.openMinutesBeforeDeadline = max(0, openMinutesBeforeDeadline)
        self.isDeadlineBound = isDeadlineBound
        self.isHardDeadline = isHardDeadline
        self.summary = summary
    }
}

struct GoalPriorityRealityAssessment: Codable, Sendable, Equatable, Hashable {
    let importance: NowPressureLevel
    let urgency: NowPressureLevel
    let deadline: NowPressureLevel
    let consequence: NowPressureLevel
    let effort: NowPressureLevel
    let contextFit: NowPressureLevel
    let goalRelationship: NowPressureLevel
    let userPreference: NowPressureLevel
    let capacity: NowPressureLevel
    let recoveryState: NowRecoveryState
    let overallPressure: NowPressureLevel
    let summary: String

    init(
        importance: NowPressureLevel = .none,
        urgency: NowPressureLevel = .none,
        deadline: NowPressureLevel = .none,
        consequence: NowPressureLevel = .none,
        effort: NowPressureLevel = .none,
        contextFit: NowPressureLevel = .none,
        goalRelationship: NowPressureLevel = .none,
        userPreference: NowPressureLevel = .none,
        capacity: NowPressureLevel = .none,
        recoveryState: NowRecoveryState = .stable,
        overallPressure: NowPressureLevel,
        summary: String
    ) {
        self.importance = importance
        self.urgency = urgency
        self.deadline = deadline
        self.consequence = consequence
        self.effort = effort
        self.contextFit = contextFit
        self.goalRelationship = goalRelationship
        self.userPreference = userPreference
        self.capacity = capacity
        self.recoveryState = recoveryState
        self.overallPressure = overallPressure
        self.summary = summary
    }
}

struct GoalBelievabilityReason: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let signal: GoalHealthSignal?
    let summary: String
    let evidenceCategory: RecommendationExplanationEvidenceCategory?

    init(
        id: String,
        signal: GoalHealthSignal? = nil,
        summary: String,
        evidenceCategory: RecommendationExplanationEvidenceCategory? = nil
    ) {
        self.id = id
        self.signal = signal
        self.summary = summary
        self.evidenceCategory = evidenceCategory
    }
}

struct GoalBelievabilityRecommendation: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let correctionAction: RecommendationExplanationCorrectionActionKind?

    init(
        id: String,
        title: String,
        summary: String,
        correctionAction: RecommendationExplanationCorrectionActionKind? = nil
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.correctionAction = correctionAction
    }
}

struct GoalBelievabilityAssumption: Codable, Sendable, Equatable, Hashable, Identifiable {
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

struct GoalBelievabilityInput: Sendable, Equatable {
    let subjectKind: GoalBelievabilitySubjectKind
    let goal: Goal?
    let step: Step?
    let capture: Capture?
    let planID: String?
    let generatedAt: Date
    let activeContextLens: NowContextLens
    let realitySnapshot: RealitySnapshot?
    let eventLedgerEntries: [EventLedgerEntry]
    let recommendationExplanations: [RecommendationExplanation]
    let effortMinutes: Int?
    let consequence: NowPressureLevel?
    let importance: NowPressureLevel?
    let userPreference: NowPressureLevel?
    let recoveryState: NowRecoveryState

    init(
        subjectKind: GoalBelievabilitySubjectKind,
        goal: Goal? = nil,
        step: Step? = nil,
        capture: Capture? = nil,
        planID: String? = nil,
        generatedAt: Date,
        activeContextLens: NowContextLens = .all,
        realitySnapshot: RealitySnapshot? = nil,
        eventLedgerEntries: [EventLedgerEntry] = [],
        recommendationExplanations: [RecommendationExplanation] = [],
        effortMinutes: Int? = nil,
        consequence: NowPressureLevel? = nil,
        importance: NowPressureLevel? = nil,
        userPreference: NowPressureLevel? = nil,
        recoveryState: NowRecoveryState = .stable
    ) {
        self.subjectKind = subjectKind
        self.goal = goal
        self.step = step
        self.capture = capture
        self.planID = planID
        self.generatedAt = generatedAt
        self.activeContextLens = activeContextLens
        self.realitySnapshot = realitySnapshot
        self.eventLedgerEntries = eventLedgerEntries
        self.recommendationExplanations = recommendationExplanations
        self.effortMinutes = effortMinutes
        self.consequence = consequence
        self.importance = importance
        self.userPreference = userPreference
        self.recoveryState = recoveryState
    }
}

typealias BelievabilityProjectionInput = GoalBelievabilityInput

struct GoalBelievabilityAssessment: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalID: String?
    let captureID: String?
    let planID: String?
    let stepID: String?
    let subjectKind: GoalBelievabilitySubjectKind
    let generatedAt: String
    let status: GoalHealthStatus
    let confidence: RecommendationConfidence
    let posture: GoalPosture
    let priorityReality: GoalPriorityRealityAssessment
    let deadlineRisk: GoalDeadlineRisk
    let consequenceLevel: NowPressureLevel
    let effortLevel: NowPressureLevel
    let effortMinutes: Int?
    let contextLens: NowContextLens
    let contextFit: NowPressureLevel
    let capacityFit: GoalCapacityFit
    let signals: [GoalHealthSignal]
    let reasons: [GoalBelievabilityReason]
    let recommendations: [GoalBelievabilityRecommendation]
    let assumptions: [GoalBelievabilityAssumption]
    let correctionSuggestions: [RecommendationExplanationCorrectionActionKind]
    let hasCalendarDerivedEvidence: Bool
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
    let relatedRealitySnapshotID: String?
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]
    let schemaVersion: String

    init(
        id: String,
        goalID: String? = nil,
        captureID: String? = nil,
        planID: String? = nil,
        stepID: String? = nil,
        subjectKind: GoalBelievabilitySubjectKind,
        generatedAt: String,
        status: GoalHealthStatus,
        confidence: RecommendationConfidence,
        posture: GoalPosture,
        priorityReality: GoalPriorityRealityAssessment,
        deadlineRisk: GoalDeadlineRisk,
        consequenceLevel: NowPressureLevel,
        effortLevel: NowPressureLevel,
        effortMinutes: Int? = nil,
        contextLens: NowContextLens,
        contextFit: NowPressureLevel,
        capacityFit: GoalCapacityFit,
        signals: [GoalHealthSignal],
        reasons: [GoalBelievabilityReason],
        recommendations: [GoalBelievabilityRecommendation],
        assumptions: [GoalBelievabilityAssumption],
        correctionSuggestions: [RecommendationExplanationCorrectionActionKind],
        hasCalendarDerivedEvidence: Bool,
        privacy: EventLedgerPrivacyClassification,
        relatedRealitySnapshotID: String? = nil,
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = [],
        localOnly: Bool = true,
        schemaVersion: String = goalBelievabilitySchemaVersion
    ) {
        self.id = id
        self.goalID = Self.nonEmpty(goalID)
        self.captureID = Self.nonEmpty(captureID)
        self.planID = Self.nonEmpty(planID)
        self.stepID = Self.nonEmpty(stepID)
        self.subjectKind = subjectKind
        self.generatedAt = generatedAt
        self.status = status
        self.confidence = confidence
        self.posture = posture
        self.priorityReality = priorityReality
        self.deadlineRisk = deadlineRisk
        self.consequenceLevel = consequenceLevel
        self.effortLevel = effortLevel
        self.effortMinutes = effortMinutes.map { max(0, $0) }
        self.contextLens = contextLens
        self.contextFit = contextFit
        self.capacityFit = capacityFit
        self.signals = Array(Set(signals)).sorted { $0.rawValue < $1.rawValue }
        self.reasons = reasons.sorted { $0.id < $1.id }
        self.recommendations = recommendations.sorted { $0.id < $1.id }
        self.assumptions = assumptions.sorted { $0.id < $1.id }
        self.correctionSuggestions = Array(Set(correctionSuggestions)).sorted { $0.rawValue < $1.rawValue }
        self.hasCalendarDerivedEvidence = hasCalendarDerivedEvidence
        self.localOnly = localOnly
        self.privacy = privacy
        self.relatedRealitySnapshotID = relatedRealitySnapshotID
        self.eventLedgerEntryIDs = Array(Set(eventLedgerEntryIDs.filter { $0.isEmpty == false })).sorted()
        self.recommendationExplanationIDs = Array(Set(recommendationExplanationIDs.filter { $0.isEmpty == false })).sorted()
        self.schemaVersion = schemaVersion
    }

    var summary: GoalBelievabilitySummary {
        GoalBelievabilitySummary(
            id: "summary.\(id)",
            status: status,
            confidence: confidence,
            posture: posture,
            headline: headline,
            reasonSummaries: reasons.map(\.summary),
            signals: signals,
            hasCalendarDerivedEvidence: hasCalendarDerivedEvidence,
            relatedAssessmentID: id
        )
    }

    private var headline: String {
        switch status {
        case .believable:
            return "This looks believable."
        case .tight:
            return "This is believable but tight."
        case .atRisk:
            return "This is at risk."
        case .unrealistic:
            return "This does not look realistic yet."
        case .blocked:
            return "This is blocked."
        case .underdefined:
            return "This needs more definition."
        case .passive:
            return "This can move slowly."
        case .optionalSomeday:
            return "This belongs in optional someday."
        case .waiting:
            return "This is waiting on something."
        }
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value, value.isEmpty == false else { return nil }
        return value
    }
}

struct GoalBelievabilitySnapshot: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let generatedAt: String
    let assessments: [GoalBelievabilityAssessment]
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]
    let relatedRealitySnapshotID: String?
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
    let schemaVersion: String

    init(
        id: String,
        generatedAt: String,
        assessments: [GoalBelievabilityAssessment],
        relatedRealitySnapshotID: String? = nil,
        localOnly: Bool = true,
        schemaVersion: String = goalBelievabilitySchemaVersion
    ) {
        self.id = id
        self.generatedAt = generatedAt
        self.assessments = assessments.sorted { $0.id < $1.id }
        self.eventLedgerEntryIDs = Array(Set(assessments.flatMap(\.eventLedgerEntryIDs))).sorted()
        self.recommendationExplanationIDs = Array(Set(assessments.flatMap(\.recommendationExplanationIDs))).sorted()
        self.relatedRealitySnapshotID = relatedRealitySnapshotID
        self.localOnly = localOnly
        self.privacy = assessments.contains { $0.privacy == .calendarDerived } ? .calendarDerived : .standard
        self.schemaVersion = schemaVersion
    }
}

struct GoalBelievabilitySummary: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let status: GoalHealthStatus
    let confidence: RecommendationConfidence
    let posture: GoalPosture
    let headline: String
    let reasonSummaries: [String]
    let signals: [GoalHealthSignal]
    let hasCalendarDerivedEvidence: Bool
    let relatedAssessmentID: String
}
