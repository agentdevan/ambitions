import Foundation

struct PlanSection: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let goalID: String
    let title: String
    let summary: String?
    let kind: PlanSectionKind
    let orderIndex: Int
    let steps: [Step]
}

struct PlanAssumption: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let summary: String
    let rationale: String
    let confidence: AssumptionConfidence
    let relatedField: MissingFieldKey?
}

struct PlanLintIssue: Codable, Sendable, Equatable {
    let code: PlanLintIssueCode
    let severity: PlanLintSeverity
    let fieldPath: [String]
    let message: String
    let sectionID: String?
    let stepID: String?
    let suggestedFix: String?

    init(
        code: PlanLintIssueCode,
        severity: PlanLintSeverity,
        fieldPath: [String],
        message: String,
        sectionID: String? = nil,
        stepID: String? = nil,
        suggestedFix: String? = nil
    ) {
        self.code = code
        self.severity = severity
        self.fieldPath = fieldPath
        self.message = message
        self.sectionID = sectionID
        self.stepID = stepID
        self.suggestedFix = suggestedFix
    }
}

struct PlanLintResult: Codable, Sendable, Equatable {
    let goalID: String?
    let planVersion: Int
    let isValid: Bool
    let issueCount: Int
    let issues: [PlanLintIssue]
}

struct GoalPlan: Codable, Sendable, Equatable {
    let id: String
    let goalID: String
    let version: Int
    let generatedAt: String
    let summary: String?
    let strategy: PlanningStrategy
    let sections: [PlanSection]
    let assumptions: [PlanAssumption]
    let lint: PlanLintResult
    let evaluation: PlanningEvaluation?

    init(
        id: String,
        goalID: String,
        version: Int,
        generatedAt: String,
        summary: String?,
        strategy: PlanningStrategy,
        sections: [PlanSection],
        assumptions: [PlanAssumption],
        lint: PlanLintResult,
        evaluation: PlanningEvaluation? = nil
    ) {
        self.id = id
        self.goalID = goalID
        self.version = version
        self.generatedAt = generatedAt
        self.summary = summary
        self.strategy = strategy
        self.sections = sections
        self.assumptions = assumptions
        self.lint = lint
        self.evaluation = evaluation
    }
}

struct GoalDraft: Codable, Sendable, Equatable {
    let schemaVersion: String
    let source: EvidenceSource
    let title: String
    let summary: String?
    let mode: GoalMode
    let relationshipKind: GoalRelationshipKind
    let actor: GoalActor
    let parentGoalID: String?
    let tags: [String]
    let timing: GoalTiming
    let planningStrategy: PlanningStrategy
    let progressStrategy: ProgressStrategy
    let lifeGraph: LifeGraphContext?

    init(
        schemaVersion: String,
        source: EvidenceSource,
        title: String,
        summary: String?,
        mode: GoalMode,
        relationshipKind: GoalRelationshipKind,
        actor: GoalActor,
        parentGoalID: String?,
        tags: [String],
        timing: GoalTiming,
        planningStrategy: PlanningStrategy,
        progressStrategy: ProgressStrategy,
        lifeGraph: LifeGraphContext? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.source = source
        self.title = title
        self.summary = summary
        self.mode = mode
        self.relationshipKind = relationshipKind
        self.actor = actor
        self.parentGoalID = parentGoalID
        self.tags = tags
        self.timing = timing
        self.planningStrategy = planningStrategy
        self.progressStrategy = progressStrategy
        self.lifeGraph = lifeGraph
    }
}

struct Goal: Codable, Sendable, Equatable {
    let schemaVersion: String
    let id: String
    let revision: Int
    let createdAt: String
    let updatedAt: String
    let state: GoalLifecycleState
    let title: String
    let summary: String?
    let mode: GoalMode
    let relationshipKind: GoalRelationshipKind
    let actor: GoalActor
    let parentGoalID: String?
    let childGoalIDs: [String]
    let supportGoalIDs: [String]
    let tags: [String]
    let timing: GoalTiming
    let planningStrategy: PlanningStrategy
    let progressStrategy: ProgressStrategy
    let plan: GoalPlan?
    let lifeGraph: LifeGraphContext?

    init(
        schemaVersion: String,
        id: String,
        revision: Int,
        createdAt: String,
        updatedAt: String,
        state: GoalLifecycleState,
        title: String,
        summary: String?,
        mode: GoalMode,
        relationshipKind: GoalRelationshipKind,
        actor: GoalActor,
        parentGoalID: String?,
        childGoalIDs: [String],
        supportGoalIDs: [String],
        tags: [String],
        timing: GoalTiming,
        planningStrategy: PlanningStrategy,
        progressStrategy: ProgressStrategy,
        plan: GoalPlan?,
        lifeGraph: LifeGraphContext? = nil
    ) {
        self.schemaVersion = schemaVersion
        self.id = id
        self.revision = revision
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.state = state
        self.title = title
        self.summary = summary
        self.mode = mode
        self.relationshipKind = relationshipKind
        self.actor = actor
        self.parentGoalID = parentGoalID
        self.childGoalIDs = childGoalIDs
        self.supportGoalIDs = supportGoalIDs
        self.tags = tags
        self.timing = timing
        self.planningStrategy = planningStrategy
        self.progressStrategy = progressStrategy
        self.plan = plan
        self.lifeGraph = lifeGraph
    }
}

extension Goal {
    var searchFreshness: YouMemoryFreshness {
        switch state {
        case .active:
            return .current
        case .draft, .paused:
            return .mayNeedReview
        case .completed, .archived:
            return .basedOnOlderContext
        }
    }
}

struct ProgressEvidence: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let goalID: String
    let stepID: String?
    let evidenceKind: ProgressEvidenceKind
    let source: EvidenceSource
    let capturedAt: String
    let progressDelta: Double?
    let confidenceDelta: Double?
    let minutesInvested: Int?
    let note: String?
}

struct ClassificationResult: Codable, Sendable, Equatable {
    let rawInput: String
    let normalizedInput: String
    let title: String
    let summary: String?
    let mode: ClassifiedValue<GoalMode>
    let tempo: ClassifiedValue<GoalTempo>
    let relationshipKind: ClassifiedValue<GoalRelationshipKind>
    let executionOwnership: ClassifiedValue<ExecutionOwnership>
    let userRole: ClassifiedValue<UserExecutionRole>
    let strictDeadlinesAppropriate: ClassifiedValue<Bool>
    let planningStrategyID: ClassifiedValue<IntakePlanningStrategyID>
    let progressStrategyID: ClassifiedValue<IntakeProgressStrategyID>
    let readiness: PlanningReadiness
    let clarificationNeeded: Bool
    let starterPlanSafe: Bool
    let missingFields: [MissingField]
    let tags: [String]
    let draft: GoalDraft
}

struct GoalDraftBuildResult: Codable, Sendable, Equatable {
    let classification: ClassificationResult
    let clarification: ClarificationSet
    let draft: GoalDraft
}

struct GoalPlanningBlocker: Codable, Sendable, Equatable {
    let code: String
    let reason: String
    let suggestedQuestion: String?
}

enum GoalPlannerResultKind: String, Codable, Sendable {
    case plan
    case starterPlan = "starter_plan"
    case blocked
}

struct GoalPlannerInput: Codable, Sendable, Equatable {
    let draft: GoalDraft
    let classification: ClassificationResult?
    let clarification: ClarificationSet?
    let clarificationAnalysis: GoalClarificationAnalysis?
    let understanding: GoalUnderstanding?

    init(
        draft: GoalDraft,
        classification: ClassificationResult? = nil,
        clarification: ClarificationSet? = nil,
        clarificationAnalysis: GoalClarificationAnalysis? = nil,
        understanding: GoalUnderstanding? = nil
    ) {
        self.draft = draft
        self.classification = classification
        self.clarification = clarification
        self.clarificationAnalysis = clarificationAnalysis
        self.understanding = understanding
    }
}

struct GoalPlannerOptions: Codable, Sendable, Equatable {
    let goalID: String?
    let now: String?

    init(goalID: String? = nil, now: String? = nil) {
        self.goalID = goalID
        self.now = now
    }
}

enum GoalPlannerResult: Sendable, Equatable {
    case plan(draft: GoalDraft, plan: GoalPlan, lint: PlanLintResult)
    case starterPlan(draft: GoalDraft, plan: GoalPlan, lint: PlanLintResult, assumptions: [PlanAssumption])
    case blocked(draft: GoalDraft, blockers: [GoalPlanningBlocker], clarification: ClarificationSet?)

    var kind: GoalPlannerResultKind {
        switch self {
        case .plan:
            return .plan
        case .starterPlan:
            return .starterPlan
        case .blocked:
            return .blocked
        }
    }
}

enum GoalFeedbackEffortLevel: String, Codable, Sendable {
    case low
    case medium
    case high
}

enum GoalHistoryEventKind: String, Codable, Sendable {
    case completed
    case skipped
    case delayed
    case edited
    case confused
    case tooBig = "too_big"
    case tooEasy = "too_easy"
    case notRelevant = "not_relevant"
    case askedForSmallerVersion = "asked_for_smaller_version"
    case askedWhyThisMatters = "asked_why_this_matters"
}

enum GoalStepSkipReasonCode: String, Codable, Sendable {
    case avoidance
    case tooHard = "too_hard"
    case notNow = "not_now"
    case forgot
    case blockedExternal = "blocked_external"
    case notReady = "not_ready"
}

enum GoalTimingAdjustment: String, Codable, Sendable {
    case laterToday = "later_today"
    case laterThisWeek = "later_this_week"
    case someday
    case removeDeadline = "remove_deadline"
}

enum GoalConfusionType: String, Codable, Sendable {
    case unclearAction = "unclear_action"
    case unclearWhy = "unclear_why"
    case missingContext = "missing_context"
    case missingEvidence = "missing_evidence"
}
