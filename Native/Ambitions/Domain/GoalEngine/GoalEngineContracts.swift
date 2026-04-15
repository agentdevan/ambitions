import Foundation

let goalEngineSchemaVersion = "goal_engine.native.v1"
let goalEnginePlanVersion = 1

enum GoalTempo: String, Codable, Sendable {
    case deadlineBased = "deadline_based"
    case targetWindow = "target_window"
    case ongoing = "ongoing"
    case untimed = "untimed"
}

enum GoalMode: String, Codable, Sendable, Hashable {
    case achievement
    case project
    case habit
    case learning
    case exploration
    case maintenance
    case recovery
    case delegatedSupport = "delegated_support"
}

enum ExecutionOwnership: String, Codable, Sendable {
    case `self`
    case delegated
    case child
    case support
    case observedOnly = "observed_only"
}

enum GoalRelationshipKind: String, Codable, Sendable {
    case independent
    case child
    case support
    case delegated
}

enum UserExecutionRole: String, Codable, Sendable {
    case executor
    case plannerSupporter = "planner_supporter"
}

enum StepType: String, Codable, Sendable {
    case actionUnit = "action_unit"
    case recurringRoutine = "recurring_routine"
    case learningCheckpoint = "learning_checkpoint"
    case explorationExperiment = "exploration_experiment"
    case supportAction = "support_action"
    case observationPrompt = "observation_prompt"
    case reflectionPrompt = "reflection_prompt"
    case resource
}

enum TimingType: String, Codable, Sendable {
    case dueAt = "due_at"
    case targetBy = "target_by"
    case repeatWithinWindow = "repeat_within_window"
    case suggestedNext = "suggested_next"
    case logWhenDone = "log_when_done"
}

enum GoalLifecycleState: String, Codable, Sendable {
    case draft
    case active
    case paused
    case completed
    case archived
}

enum PlanSectionKind: String, Codable, Sendable {
    case overview
    case activeSteps = "active_steps"
    case upcoming
    case review
    case resources
    case supportingWork = "supporting_work"
    case completed
}

enum StepLifecycleState: String, Codable, Sendable {
    case planned
    case active
    case completed
    case blocked
    case cancelled
}

enum PlanningStrategyKind: String, Codable, Sendable {
    case sequential
    case parallel
    case cadence
    case exploratory
    case supportive
    case adaptive
}

enum ProgressMetricKind: String, Codable, Sendable {
    case stepCompletion = "step_completion"
    case evidenceCount = "evidence_count"
    case streak
    case timeInvested = "time_invested"
    case confidenceGain = "confidence_gain"
    case observationLog = "observation_log"
}

enum ProgressRollupMethod: String, Codable, Sendable {
    case sum
    case ratio
    case latest
    case weightedRatio = "weighted_ratio"
    case streakLength = "streak_length"
}

enum ProgressEvidenceKind: String, Codable, Sendable {
    case stepCompleted = "step_completed"
    case habitCompletion = "habit_completion"
    case habitMinimumVersion = "habit_minimum_version"
    case habitQuickLog = "habit_quick_log"
    case sessionLogged = "session_logged"
    case reflectionLogged = "reflection_logged"
    case delegatedUpdate = "delegated_update"
    case observationLogged = "observation_logged"
    case milestoneReached = "milestone_reached"
}

enum EvidenceSource: String, Codable, Sendable {
    case manual
    case migration
    case imported
    case derived
    case aiSuggested = "ai_suggested"
}

enum ContractValueSource: String, Codable, Sendable {
    case manual
    case derivedContract = "derived_contract"
    case defaultStrategy = "default_strategy"
    case contextOverride = "context_override"
}

enum ClassificationConfidence: String, Codable, Sendable {
    case low
    case medium
    case high
}

enum GoalPlanningStrictness: String, Codable, Sendable {
    case strict
    case balanced
    case starterFriendly = "starter_friendly"
}

enum GoalSupportScope: String, Codable, Sendable {
    case supporting
    case coaching
    case tracking
}

enum PlanningReadiness: String, Codable, Sendable {
    case readyForPlanning = "ready_for_planning"
    case needsClarification = "needs_clarification"
    case canPlanWithDefaults = "can_plan_with_defaults"
}

enum MissingFieldKey: String, Codable, Sendable {
    case goalSubject = "goal_subject"
    case goalShape = "goal_shape"
    case executorIdentity = "executor_identity"
    case supportScope = "support_scope"
    case successDefinition = "success_definition"
    case timeHorizon = "time_horizon"
}

enum GoalInputContradictionCode: String, Codable, Sendable {
    case timingConflict = "timing_conflict"
    case goalSubjectGap = "goal_subject_gap"
}

enum IntakePlanningStrategyID: String, Codable, Sendable {
    case milestonePlan = "milestone_plan"
    case routineBuilder = "routine_builder"
    case learningPath = "learning_path"
    case discoveryMap = "discovery_map"
    case stabilizationPath = "stabilization_path"
    case guidedSupport = "guided_support"
    case lightweightTracking = "lightweight_tracking"
}

enum IntakeProgressStrategyID: String, Codable, Sendable {
    case timedExecution = "timed_execution"
    case untimedGrowth = "untimed_growth"
    case learning
    case exploration
    case maintenance
    case delegatedSupport = "delegated_support"
    case observationalProgress = "observational_progress"
}

enum AssumptionConfidence: String, Codable, Sendable {
    case low
    case medium
    case high
}

enum PlanLintSeverity: String, Codable, Sendable {
    case error
    case warning
    case info
}

enum PlanLintIssueCode: String, Codable, Sendable {
    case missingTitle = "missing_title"
    case invalidTiming = "invalid_timing"
    case missingParentForRelationship = "missing_parent_for_relationship"
    case missingPlanSections = "missing_plan_sections"
    case missingStepTitle = "missing_step_title"
    case duplicateSectionID = "duplicate_section_id"
    case duplicateStepID = "duplicate_step_id"
    case invalidDependency = "invalid_dependency"
    case invalidProgressStrategy = "invalid_progress_strategy"
    case invalidDelegatedOwnership = "invalid_delegated_ownership"
    case vagueStep = "vague_step"
    case oversizedStep = "oversized_step"
    case missingStepEvidence = "missing_step_evidence"
    case inappropriateTimingPressure = "inappropriate_timing_pressure"
    case wrongSupportTone = "wrong_support_tone"
    case notSessionCompletable = "not_session_completable"
}

struct InferenceMetadata: Codable, Sendable, Equatable {
    let source: ContractValueSource
    let inferred: Bool
    let confidence: Double
    let label: ClassificationConfidence
    let reason: String
}

struct ClassifiedValue<Value: Codable & Sendable & Equatable>: Codable, Sendable, Equatable {
    let value: Value
    let metadata: InferenceMetadata
}

struct MissingField: Codable, Sendable, Equatable {
    let field: MissingFieldKey
    let reason: String
    let blocksPlanning: Bool
}

struct ClarificationQuestion: Codable, Sendable, Equatable {
    let id: String
    let field: MissingFieldKey
    let prompt: String
    let rationale: String
    let skipSafeDefault: String
}

struct ClarificationSet: Codable, Sendable, Equatable {
    let readiness: PlanningReadiness
    let questions: [ClarificationQuestion]
    let missingFields: [MissingField]
}

struct GoalInputContradiction: Codable, Sendable, Equatable {
    let code: GoalInputContradictionCode
    let reason: String
    let question: ClarificationQuestion
}

struct GoalActor: Codable, Sendable, Equatable {
    let actorID: String
    let displayName: String
    let ownership: ExecutionOwnership
    let roleLabel: String?
    let isPrimary: Bool
}

struct GoalTiming: Codable, Sendable, Equatable {
    let tempo: GoalTempo
    let timingType: TimingType
    let startsOn: String?
    let dueAt: String?
    let targetBy: String?
    let windowStart: String?
    let windowEnd: String?
    let suggestedNextAt: String?
    let repeatEveryDays: Int?
    let progressReviewCadenceDays: Int?
}

struct PlanningStrategy: Codable, Sendable, Equatable {
    let strategyKind: PlanningStrategyKind
    let allowParallelSteps: Bool
    let maxActiveSteps: Int
    let preferredSectionOrder: [PlanSectionKind]
    let defaultStepType: StepType
    let autoGenerateReviewSection: Bool
    let preferShortSteps: Bool
    let revisitCadenceDays: Int?
}

struct ProgressStrategy: Codable, Sendable, Equatable {
    let metricKind: ProgressMetricKind
    let rollupMethod: ProgressRollupMethod
    let targetStepCount: Int?
    let targetEvidenceCount: Int?
    let targetMinutes: Int?
    let supportsUntimedProgress: Bool
    let countsChildGoals: Bool
    let countsSupportGoals: Bool
}

struct StepActionability: Codable, Sendable, Equatable {
    let action: String
    let completionDefinition: String
    let evidenceOfCompletion: [String]
    let fallbackMicroStep: String
    let contextRequirements: [String]
}

struct Step: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let sectionID: String
    let title: String
    let summary: String?
    let type: StepType
    let state: StepLifecycleState
    let owner: GoalActor
    let timing: GoalTiming
    let dependencyStepIDs: [String]
    let isOptional: Bool
    let isRepeatable: Bool
    let evidenceRequired: Bool
    let successSignals: [String]
    let actionability: StepActionability
}

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

struct GoalFeedbackEventBase: Codable, Sendable, Equatable {
    let id: String
    let stepID: String
    let occurredAt: String
    let note: String?
}

enum GoalFeedbackEvent: Sendable, Equatable {
    case completed(base: GoalFeedbackEventBase, actualDuration: Int?, effortLevel: GoalFeedbackEffortLevel, confidenceDelta: Double?)
    case skipped(base: GoalFeedbackEventBase, reasonCode: GoalStepSkipReasonCode)
    case delayed(base: GoalFeedbackEventBase, timingAdjustment: GoalTimingAdjustment, date: String?)
    case edited(base: GoalFeedbackEventBase, rewrittenText: String)
    case confused(base: GoalFeedbackEventBase, confusionType: GoalConfusionType)
    case tooBig(base: GoalFeedbackEventBase)
    case tooEasy(base: GoalFeedbackEventBase)
    case notRelevant(base: GoalFeedbackEventBase)
    case askedForSmallerVersion(base: GoalFeedbackEventBase)
    case askedWhyThisMatters(base: GoalFeedbackEventBase)

    var base: GoalFeedbackEventBase {
        switch self {
        case let .completed(base, _, _, _),
             let .skipped(base, _),
             let .delayed(base, _, _),
             let .edited(base, _),
             let .confused(base, _),
             let .tooBig(base),
             let .tooEasy(base),
             let .notRelevant(base),
             let .askedForSmallerVersion(base),
             let .askedWhyThisMatters(base):
            return base
        }
    }

    var stepID: String { base.stepID }
}

struct GoalFeedbackSignalSnapshot: Codable, Sendable, Equatable {
    enum ConfidenceTrend: String, Codable, Sendable {
        case improving
        case eroding
        case flat
    }

    let avoidanceCount: Int
    let tooBigCount: Int
    let confusedCount: Int
    let notRelevantCount: Int
    let delayedCount: Int
    let askedWhyCount: Int
    let confidenceScore: Double
    let confidenceTrend: ConfidenceTrend
    let frictionScore: Double
    let toneDriftDetected: Bool
    let rigidityDetected: Bool
}

struct WhyStepMattersExplanationHook: Codable, Sendable, Equatable {
    let prompt: String
    let explanation: String
}

enum GoalReplanRecommendationKind: String, Codable, Sendable {
    case noChange = "no_change"
    case reviseStep = "revise_step"
    case shrinkStep = "shrink_step"
    case relaxTiming = "relax_timing"
    case requestReclarification = "request_reclarification"
    case adjustPlanTone = "adjust_plan_tone"
    case suggestMicroStep = "suggest_micro_step"
    case suggestAlternatePath = "suggest_alternate_path"
}

struct GoalEngineOrchestrationContext: Codable, Sendable, Equatable {
    let actorName: String?
    let preferredPlanningStrictness: GoalPlanningStrictness
    let goalOwnerRole: String?
    let supportScope: GoalSupportScope?
    let deadlineHints: [String]
    let existingGoalReferences: [String]
    let sourceScreen: String?
    let sourceFlow: String?
    let clarifiedFields: [MissingFieldKey: String]
    let referenceNow: String?

    init(
        actorName: String? = nil,
        preferredPlanningStrictness: GoalPlanningStrictness = .balanced,
        goalOwnerRole: String? = nil,
        supportScope: GoalSupportScope? = nil,
        deadlineHints: [String] = [],
        existingGoalReferences: [String] = [],
        sourceScreen: String? = nil,
        sourceFlow: String? = nil,
        clarifiedFields: [MissingFieldKey: String] = [:],
        referenceNow: String? = nil
    ) {
        self.actorName = actorName
        self.preferredPlanningStrictness = preferredPlanningStrictness
        self.goalOwnerRole = goalOwnerRole
        self.supportScope = supportScope
        self.deadlineHints = deadlineHints
        self.existingGoalReferences = existingGoalReferences
        self.sourceScreen = sourceScreen
        self.sourceFlow = sourceFlow
        self.clarifiedFields = clarifiedFields
        self.referenceNow = referenceNow
    }
}

struct GoalEngineOrchestrationInputSnapshot: Codable, Sendable, Equatable {
    let rawInput: String
    let normalizedInput: String
}

struct GoalEngineOrchestrationContextSnapshot: Codable, Sendable, Equatable {
    let actorName: String?
    let preferredPlanningStrictness: GoalPlanningStrictness
    let goalOwnerRole: String?
    let supportScope: GoalSupportScope?
    let deadlineHints: [String]
    let existingGoalReferences: [String]
    let sourceScreen: String?
    let sourceFlow: String?
    let clarifiedFields: [String: String]
    let referenceNow: String?
}

struct GoalOrchestrationClarification: Codable, Sendable, Equatable {
    let readiness: PlanningReadiness
    let questions: [ClarificationQuestion]
    let missingFields: [MissingField]
    let contradictions: [GoalInputContradiction]
}

struct GoalOrchestrationInferenceSnapshot: Codable, Sendable, Equatable {
    let mode: ClassifiedValue<GoalMode>
    let tempo: ClassifiedValue<GoalTempo>
    let relationshipKind: ClassifiedValue<GoalRelationshipKind>
    let executionOwnership: ClassifiedValue<ExecutionOwnership>
    let userRole: ClassifiedValue<UserExecutionRole>
    let strictDeadlinesAppropriate: ClassifiedValue<Bool>
    let planningStrategyID: ClassifiedValue<IntakePlanningStrategyID>
    let progressStrategyID: ClassifiedValue<IntakeProgressStrategyID>
    let actorDisplayName: String
    let actorRoleLabel: String?
    let timing: GoalTiming
}

struct GoalOrchestrationPlannerMetadata: Codable, Sendable, Equatable {
    let attempted: Bool
    let resultKind: GoalPlannerResultKind?
    let blockers: [GoalPlanningBlocker]
    let lint: PlanLintResult?
}

struct GoalOrchestrationReasoningMetadata: Codable, Sendable, Equatable {
    let readiness: PlanningReadiness
    let clarificationNeeded: Bool
    let starterPlanSafe: Bool
    let missingFields: [MissingField]
    let contradictions: [GoalInputContradiction]
    let assumptions: [PlanAssumption]
    let inference: [String: InferenceMetadata]
}

struct GoalOrchestrationMetadata: Codable, Sendable, Equatable {
    let input: GoalEngineOrchestrationInputSnapshot
    let context: GoalEngineOrchestrationContextSnapshot
    let inference: GoalOrchestrationInferenceSnapshot
    let clarification: GoalOrchestrationClarification
    let planner: GoalOrchestrationPlannerMetadata
    let reasoning: GoalOrchestrationReasoningMetadata
}

struct GoalClarificationRequiredResult: Sendable, Equatable {
    let draft: GoalDraft
    let clarification: GoalOrchestrationClarification
    let metadata: GoalOrchestrationMetadata
}

struct GoalPlannedResult: Sendable, Equatable {
    let draft: GoalDraft
    let plan: GoalPlan
    let lint: PlanLintResult
    let metadata: GoalOrchestrationMetadata
}

struct GoalStarterPlannedResult: Sendable, Equatable {
    let draft: GoalDraft
    let plan: GoalPlan
    let lint: PlanLintResult
    let assumptions: [PlanAssumption]
    let clarification: GoalOrchestrationClarification
    let metadata: GoalOrchestrationMetadata
}

enum GoalAdaptivePlanResult: Sendable, Equatable {
    case planned(GoalPlannedResult)
    case starterPlanned(GoalStarterPlannedResult)

    var draft: GoalDraft {
        switch self {
        case let .planned(result):
            return result.draft
        case let .starterPlanned(result):
            return result.draft
        }
    }

    var plan: GoalPlan {
        switch self {
        case let .planned(result):
            return result.plan
        case let .starterPlanned(result):
            return result.plan
        }
    }
}

struct GoalAdaptivePlanInput: Sendable, Equatable {
    let currentResult: GoalAdaptivePlanResult
    let selectedStep: Step
    let feedbackHistory: [GoalFeedbackEvent]
}

enum GoalReplanRecommendation: Sendable, Equatable {
    case noChange(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot)
    case reviseStep(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot, rewriteHints: [String], evidenceAdjustments: [String], explanationHook: WhyStepMattersExplanationHook?)
    case shrinkStep(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot, smallerVersion: String, fallbackMicroStep: String)
    case relaxTiming(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot, suggestedTimingType: TimingType, removeDeadline: Bool)
    case requestReclarification(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot, questions: [String])
    case adjustPlanTone(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot, toneGuidance: [String])
    case suggestMicroStep(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot, microStep: String)
    case suggestAlternatePath(stepID: String, rationale: String, confidence: Double, signals: GoalFeedbackSignalSnapshot, alternatePath: String, explanationHook: WhyStepMattersExplanationHook?)

    var kind: GoalReplanRecommendationKind {
        switch self {
        case .noChange:
            return .noChange
        case .reviseStep:
            return .reviseStep
        case .shrinkStep:
            return .shrinkStep
        case .relaxTiming:
            return .relaxTiming
        case .requestReclarification:
            return .requestReclarification
        case .adjustPlanTone:
            return .adjustPlanTone
        case .suggestMicroStep:
            return .suggestMicroStep
        case .suggestAlternatePath:
            return .suggestAlternatePath
        }
    }
}

struct GoalAdaptivePlanAdjustmentPayload: Sendable, Equatable {
    let goal: GoalDraft
    let plan: GoalPlan
    let selectedStep: Step
    let recommendation: GoalReplanRecommendation
    let explanationHook: WhyStepMattersExplanationHook?
}

struct GoalBlockedResult: Sendable, Equatable {
    let draft: GoalDraft
    let blockers: [GoalPlanningBlocker]
    let clarification: GoalOrchestrationClarification?
    let metadata: GoalOrchestrationMetadata
}

enum GoalOrchestrationResultKind: String, Codable, Sendable {
    case clarificationRequired = "clarification_required"
    case planned
    case starterPlanned = "starter_planned"
    case blocked
}

enum GoalOrchestrationResult: Sendable, Equatable {
    case clarificationRequired(GoalClarificationRequiredResult)
    case planned(GoalPlannedResult)
    case starterPlanned(GoalStarterPlannedResult)
    case blocked(GoalBlockedResult)

    var kind: GoalOrchestrationResultKind {
        switch self {
        case .clarificationRequired:
            return .clarificationRequired
        case .planned:
            return .planned
        case .starterPlanned:
            return .starterPlanned
        case .blocked:
            return .blocked
        }
    }

    var draft: GoalDraft {
        switch self {
        case let .clarificationRequired(result):
            return result.draft
        case let .planned(result):
            return result.draft
        case let .starterPlanned(result):
            return result.draft
        case let .blocked(result):
            return result.draft
        }
    }

    var metadata: GoalOrchestrationMetadata {
        switch self {
        case let .clarificationRequired(result):
            return result.metadata
        case let .planned(result):
            return result.metadata
        case let .starterPlanned(result):
            return result.metadata
        case let .blocked(result):
            return result.metadata
        }
    }
}

enum GoalContractValidator {
    static func lint(draft: GoalDraft) -> PlanLintResult {
        var issues: [PlanLintIssue] = []

        if draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(PlanLintIssue(code: .missingTitle, severity: .error, fieldPath: ["title"], message: "Goal title is required."))
        }

        issues.append(contentsOf: lintTiming(draft.timing, fieldPath: ["timing"]))

        return PlanLintResult(goalID: nil, planVersion: 0, isValid: !issues.contains(where: { $0.severity == .error }), issueCount: issues.count, issues: issues)
    }

    static func lint(plan: GoalPlan) -> PlanLintResult {
        var issues: [PlanLintIssue] = []
        var sectionIDs = Set<String>()
        var stepIDs = Set<String>()
        var validStepIDs = Set<String>()

        if plan.sections.isEmpty {
            issues.append(PlanLintIssue(code: .missingPlanSections, severity: .error, fieldPath: ["sections"], message: "Goal plans require at least one section."))
        }

        for section in plan.sections {
            if !sectionIDs.insert(section.id).inserted {
                issues.append(
                    PlanLintIssue(
                        code: .duplicateSectionID,
                        severity: .error,
                        fieldPath: ["sections", section.id],
                        message: "Section identifiers must be unique.",
                        sectionID: section.id
                    )
                )
            }

            for step in section.steps where step.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(PlanLintIssue(code: .missingStepTitle, severity: .error, fieldPath: ["sections", section.id, "steps", step.id, "title"], message: "Step title is required.", sectionID: section.id, stepID: step.id))
            }
            for step in section.steps {
                if !stepIDs.insert(step.id).inserted {
                    issues.append(
                        PlanLintIssue(
                            code: .duplicateStepID,
                            severity: .error,
                            fieldPath: ["sections", section.id, "steps", step.id],
                            message: "Step identifiers must be unique.",
                            sectionID: section.id,
                            stepID: step.id
                        )
                    )
                }
                validStepIDs.insert(step.id)
                issues.append(contentsOf: lintTiming(step.timing, fieldPath: ["sections", section.id, "steps", step.id, "timing"]))
            }
        }

        for section in plan.sections {
            for step in section.steps {
                for dependencyStepID in step.dependencyStepIDs where !validStepIDs.contains(dependencyStepID) {
                    issues.append(
                        PlanLintIssue(
                            code: .invalidDependency,
                            severity: .error,
                            fieldPath: ["sections", section.id, "steps", step.id, "dependencyStepIDs"],
                            message: "Step dependencies must reference a valid step identifier.",
                            sectionID: section.id,
                            stepID: step.id
                        )
                    )
                }
            }
        }

        return PlanLintResult(goalID: plan.goalID, planVersion: plan.version, isValid: !issues.contains(where: { $0.severity == .error }), issueCount: issues.count, issues: issues)
    }

    private static func lintTiming(_ timing: GoalTiming, fieldPath: [String]) -> [PlanLintIssue] {
        switch timing.tempo {
        case .deadlineBased:
            return timing.dueAt == nil ? [PlanLintIssue(code: .invalidTiming, severity: .error, fieldPath: fieldPath, message: "Deadline-based goals require dueAt.")] : []
        case .targetWindow:
            return timing.targetBy == nil && (timing.windowStart == nil || timing.windowEnd == nil)
                ? [PlanLintIssue(code: .invalidTiming, severity: .error, fieldPath: fieldPath, message: "Target-window goals require targetBy or both windowStart and windowEnd.")]
                : []
        case .ongoing:
            return timing.timingType == .repeatWithinWindow && timing.repeatEveryDays == nil
                ? [PlanLintIssue(code: .invalidTiming, severity: .error, fieldPath: fieldPath, message: "Ongoing repeat timing requires repeatEveryDays.")]
                : []
        case .untimed:
            return (timing.dueAt != nil || timing.targetBy != nil || timing.windowStart != nil || timing.windowEnd != nil)
                ? [PlanLintIssue(code: .invalidTiming, severity: .error, fieldPath: fieldPath, message: "Untimed goals cannot carry deadline or target-window dates.")]
                : []
        }
    }
}

extension GoalOrchestrationResult {
    var adaptivePlanResult: GoalAdaptivePlanResult? {
        switch self {
        case let .planned(result):
            return .planned(result)
        case let .starterPlanned(result):
            return .starterPlanned(result)
        case .clarificationRequired, .blocked:
            return nil
        }
    }
}
