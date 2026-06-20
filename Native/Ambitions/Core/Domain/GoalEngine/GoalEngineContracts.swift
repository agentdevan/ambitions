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

extension GoalMode {
    var displayTitle: String {
        switch self {
        case .achievement:
            return "Achievement"
        case .project:
            return "Project"
        case .habit:
            return "Ritual"
        case .learning:
            return "Learning"
        case .exploration:
            return "Exploration"
        case .maintenance:
            return "Maintenance"
        case .recovery:
            return "Recovery"
        case .delegatedSupport:
            return "Delegated support"
        }
    }
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
    case ritualRhythm = "ritual_rhythm"
    case timeInvested = "time_invested"
    case confidenceGain = "confidence_gain"
    case observationLog = "observation_log"
}

enum ProgressRollupMethod: String, Codable, Sendable {
    case sum
    case ratio
    case latest
    case weightedRatio = "weighted_ratio"
    case rhythmLength = "rhythm_length"
}

enum ProgressEvidenceKind: String, Codable, Sendable {
    case stepCompleted = "step_completed"
    case ritualCompletion = "ritual_completion"
    case ritualMinimumVersion = "ritual_minimum_version"
    case ritualQuickLog = "ritual_quick_log"
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
