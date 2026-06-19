import Foundation

let goalIntentCompilerSchemaVersion = "goal_intent_compiler.native.v1"
let goalIntentDayCompilerSchemaVersion = "goal_intent_day_compiler.native.v1"

enum GoalIntentDayCompilerStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case clear
    case ambiguous
    case blocked

    var allowsExecution: Bool {
        self != .blocked
    }
}

enum GoalIntentSourceSurface: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case capture
    case goals
    case time
    case today
    case you
    case manual
    case command
    case path
    case plan
}

enum GoalPrivacyClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localOnly = "local_only"
    case privateLife = "private_life"
    case sensitive
    case shared
}

enum GoalSourceState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case rawInput = "raw_input"
    case draft
    case path
    case plan
    case blocked
}

enum GoalContextSignalKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case age
    case currentSkill = "current_skill"
    case currentAccess = "current_access"
    case timeline
    case budget
    case capacity
    case healthSensitiveSignal = "health_sensitive_signal"
    case relationshipSensitiveSignal = "relationship_sensitive_signal"
    case financialRiskSignal = "financial_risk_signal"
    case legalSourceSignal = "legal_source_signal"
    case professionalReviewSignal = "professional_review_signal"
    case custom
}

enum GoalIntentBlockedReasonKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingContext = "missing_context"
    case clarificationNeeded = "clarification_needed"
    case blockedPath = "blocked_path"
    case proofGap = "proof_gap"
    case runtimeBoundary = "runtime_boundary"
    case other
}

struct GoalContextSignal: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let kind: GoalContextSignalKind
    let summary: String
    let detail: String?
    let isKnown: Bool

    init(
        id: String,
        kind: GoalContextSignalKind,
        summary: String,
        detail: String? = nil,
        isKnown: Bool = true
    ) {
        self.id = normalizedRequired(id)
        self.kind = kind
        self.summary = normalizedRequired(summary)
        self.detail = normalizedOptional(detail)
        self.isKnown = isKnown
    }
}

struct GoalIntent: Codable, Sendable, Equatable, Identifiable, Hashable {
    let schemaVersion: String
    let id: String
    let rawStatement: String
    let createdAt: String
    let sourceSurface: GoalIntentSourceSurface
    let userKnownContext: [GoalContextSignal]
    let privacyClass: GoalPrivacyClass
    let sourceState: GoalSourceState

    init(
        schemaVersion: String = goalIntentCompilerSchemaVersion,
        id: String,
        rawStatement: String,
        createdAt: String,
        sourceSurface: GoalIntentSourceSurface,
        userKnownContext: [GoalContextSignal] = [],
        privacyClass: GoalPrivacyClass = .localOnly,
        sourceState: GoalSourceState = .rawInput
    ) {
        self.schemaVersion = schemaVersion
        self.id = normalizedRequired(id)
        self.rawStatement = normalizedRequired(rawStatement)
        self.createdAt = normalizedRequired(createdAt)
        self.sourceSurface = sourceSurface
        self.userKnownContext = userKnownContext
        self.privacyClass = privacyClass
        self.sourceState = sourceState
    }

    var isLocalOnly: Bool {
        privacyClass == .localOnly
    }
}

struct GoalIntentMissingField: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let fieldRawValue: String?
    let reason: String
    let blocksCompilation: Bool

    init(
        id: String,
        field: MissingFieldKey? = nil,
        reason: String,
        blocksCompilation: Bool
    ) {
        self.id = normalizedRequired(id)
        self.fieldRawValue = field?.rawValue
        self.reason = normalizedRequired(reason)
        self.blocksCompilation = blocksCompilation
    }

    var field: MissingFieldKey? {
        fieldRawValue.flatMap(MissingFieldKey.init(rawValue:))
    }
}

struct GoalIntentClarificationQuestion: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let prompt: String
    let rationale: String
    let targetFieldRawValue: String?
    let severity: GoalClarificationSeverity
    let blocking: Bool
    let skipSafeDefault: String

    init(
        id: String,
        prompt: String,
        rationale: String,
        targetField: MissingFieldKey? = nil,
        severity: GoalClarificationSeverity,
        blocking: Bool,
        skipSafeDefault: String
    ) {
        self.id = normalizedRequired(id)
        self.prompt = normalizedRequired(prompt)
        self.rationale = normalizedRequired(rationale)
        self.targetFieldRawValue = targetField?.rawValue
        self.severity = severity
        self.blocking = blocking
        self.skipSafeDefault = normalizedRequired(skipSafeDefault)
    }

    var targetField: MissingFieldKey? {
        targetFieldRawValue.flatMap(MissingFieldKey.init(rawValue:))
    }
}

struct GoalIntentAssumption: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let rationale: String
    let confidenceRawValue: String
    let sourceRawValue: String
    let relatedFieldRawValue: String?
    let safeForCompilation: Bool

    init(
        id: String,
        summary: String,
        rationale: String,
        confidence: AssumptionConfidence,
        source: ContractValueSource,
        relatedField: MissingFieldKey? = nil,
        safeForCompilation: Bool
    ) {
        self.id = normalizedRequired(id)
        self.summary = normalizedRequired(summary)
        self.rationale = normalizedRequired(rationale)
        self.confidenceRawValue = confidence.rawValue
        self.sourceRawValue = source.rawValue
        self.relatedFieldRawValue = relatedField?.rawValue
        self.safeForCompilation = safeForCompilation
    }

    var confidence: AssumptionConfidence {
        AssumptionConfidence(rawValue: confidenceRawValue) ?? .medium
    }

    var source: ContractValueSource {
        ContractValueSource(rawValue: sourceRawValue) ?? .manual
    }

    var relatedField: MissingFieldKey? {
        relatedFieldRawValue.flatMap(MissingFieldKey.init(rawValue:))
    }
}

struct GoalIntentBlockedReason: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let kind: GoalIntentBlockedReasonKind
    let summary: String
    let fieldRawValue: String?
    let severity: GoalClarificationSeverity

    init(
        id: String,
        kind: GoalIntentBlockedReasonKind,
        summary: String,
        field: MissingFieldKey? = nil,
        severity: GoalClarificationSeverity = .blocking
    ) {
        self.id = normalizedRequired(id)
        self.kind = kind
        self.summary = normalizedRequired(summary)
        self.fieldRawValue = field?.rawValue
        self.severity = severity
    }

    var field: MissingFieldKey? {
        fieldRawValue.flatMap(MissingFieldKey.init(rawValue:))
    }
}

struct GoalIntentClarification: Codable, Sendable, Equatable, Hashable {
    let status: GoalIntentDayCompilerStatus
    let readinessRawValue: String
    let questions: [GoalIntentClarificationQuestion]
    let missingFields: [GoalIntentMissingField]

    init(
        status: GoalIntentDayCompilerStatus,
        readiness: PlanningReadiness,
        questions: [GoalIntentClarificationQuestion] = [],
        missingFields: [GoalIntentMissingField] = []
    ) {
        self.status = status
        self.readinessRawValue = readiness.rawValue
        self.questions = questions
        self.missingFields = missingFields
    }

    var readiness: PlanningReadiness {
        PlanningReadiness(rawValue: readinessRawValue) ?? .canPlanWithDefaults
    }
}

struct GoalIntentCapacityWindow: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let availableMinutes: Int
    let isProtected: Bool
    let reasonCodes: [GoalEnergyFitReasonCode]

    init(
        id: String,
        title: String,
        summary: String,
        availableMinutes: Int,
        isProtected: Bool,
        reasonCodes: [GoalEnergyFitReasonCode] = []
    ) {
        self.id = normalizedRequired(id)
        self.title = normalizedRequired(title)
        self.summary = normalizedRequired(summary)
        self.availableMinutes = max(0, availableMinutes)
        self.isProtected = isProtected
        self.reasonCodes = reasonCodes
    }
}
