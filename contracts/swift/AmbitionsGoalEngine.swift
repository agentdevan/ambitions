import Foundation

// Secondary mirror of the canonical TypeScript contract in
// `src/domain/models/goalEngine.ts`. Keep Swift aligned to TypeScript, and if
// generators are introduced later, derive Swift from the TS contract rather
// than evolving the two surfaces independently.

public enum GoalTempo: String, Codable, Sendable {
    case deadlineBased = "deadline_based"
    case targetWindow = "target_window"
    case ongoing = "ongoing"
    case untimed = "untimed"
}

public enum GoalMode: String, Codable, Sendable {
    case achievement
    case project
    case habit
    case learning
    case exploration
    case maintenance
    case recovery
    case delegatedSupport = "delegated_support"
}

public enum ExecutionOwnership: String, Codable, Sendable {
    case `self`
    case child
    case partner
    case team
    case household
    case observedOnly = "observed_only"
}

public enum StepType: String, Codable, Sendable {
    case actionUnit = "action_unit"
    case recurringRoutine = "recurring_routine"
    case learningCheckpoint = "learning_checkpoint"
    case explorationExperiment = "exploration_experiment"
    case supportAction = "support_action"
    case observationPrompt = "observation_prompt"
    case resource
    case reflectionPrompt = "reflection_prompt"
}

public enum TimingType: String, Codable, Sendable {
    case dueAt = "due_at"
    case targetBy = "target_by"
    case repeatWithinWindow = "repeat_within_window"
    case suggestedNext = "suggested_next"
    case logWhenDone = "log_when_done"
}

public enum GoalLifecycleState: String, Codable, Sendable {
    case draft
    case active
    case paused
    case completed
    case archived
}

public enum GoalRelationshipKind: String, Codable, Sendable {
    case independent
    case child
    case support
    case delegated
}

public enum PlanSectionKind: String, Codable, Sendable {
    case overview = "overview"
    case activeSteps = "active_steps"
    case upcoming
    case review
    case resources
    case supportingWork = "supporting_work"
    case completed
}

public enum StepLifecycleState: String, Codable, Sendable {
    case planned
    case active
    case completed
    case blocked
    case cancelled
}

public enum PlanningStrategyKind: String, Codable, Sendable {
    case sequential
    case parallel
    case cadence
    case exploratory
    case supportive
    case adaptive
}

public enum ProgressMetricKind: String, Codable, Sendable {
    case stepCompletion = "step_completion"
    case evidenceCount = "evidence_count"
    case streak
    case timeInvested = "time_invested"
    case confidenceGain = "confidence_gain"
    case observationLog = "observation_log"
}

public enum ProgressRollupMethod: String, Codable, Sendable {
    case sum
    case ratio
    case latest
    case weightedRatio = "weighted_ratio"
    case streakLength = "streak_length"
}

public enum ProgressEvidenceKind: String, Codable, Sendable {
    case stepCompleted = "step_completed"
    case sessionLogged = "session_logged"
    case reflectionLogged = "reflection_logged"
    case delegatedUpdate = "delegated_update"
    case observationLogged = "observation_logged"
    case milestoneReached = "milestone_reached"
}

public enum EvidenceSource: String, Codable, Sendable {
    case manual
    case migration
    case imported
    case derived
    case aiSuggested = "ai_suggested"
}

public enum FeedbackEventType: String, Codable, Sendable {
    case planAdjusted = "plan_adjusted"
    case blocked
    case confidenceUpdated = "confidence_updated"
    case energyMismatch = "energy_mismatch"
    case delegationUpdate = "delegation_update"
    case reflectionCaptured = "reflection_captured"
}

public enum FeedbackSentiment: String, Codable, Sendable {
    case positive
    case neutral
    case negative
    case mixed
}

public enum PlanLintSeverity: String, Codable, Sendable {
    case error
    case warning
    case info
}

public enum PlanLintIssueCode: String, Codable, Sendable {
    case missingTitle = "missing_title"
    case invalidTiming = "invalid_timing"
    case missingParentForRelationship = "missing_parent_for_relationship"
    case missingPlanSections = "missing_plan_sections"
    case missingStepTitle = "missing_step_title"
    case duplicateSectionId = "duplicate_section_id"
    case duplicateStepId = "duplicate_step_id"
    case invalidDependency = "invalid_dependency"
    case invalidProgressStrategy = "invalid_progress_strategy"
    case invalidDelegatedOwnership = "invalid_delegated_ownership"
}

public struct GoalActor: Codable, Sendable, Equatable {
    public let actorId: String
    public let displayName: String
    public let ownership: ExecutionOwnership
    public let roleLabel: String?
    public let isPrimary: Bool
}

public struct GoalTiming: Codable, Sendable, Equatable {
    public let tempo: GoalTempo
    public let timingType: TimingType
    public let startsOn: String?
    public let dueAt: String?
    public let targetBy: String?
    public let windowStart: String?
    public let windowEnd: String?
    public let suggestedNextAt: String?
    public let repeatEveryDays: Int?
    public let progressReviewCadenceDays: Int?
}

public struct PlanningStrategy: Codable, Sendable, Equatable {
    public let strategyKind: PlanningStrategyKind
    public let allowParallelSteps: Bool
    public let maxActiveSteps: Int
    public let preferredSectionOrder: [PlanSectionKind]
    public let defaultStepType: StepType
    public let autoGenerateReviewSection: Bool
    public let preferShortSteps: Bool
    public let revisitCadenceDays: Int?
}

public struct ProgressStrategy: Codable, Sendable, Equatable {
    public let metricKind: ProgressMetricKind
    public let rollupMethod: ProgressRollupMethod
    public let targetStepCount: Int?
    public let targetEvidenceCount: Int?
    public let targetMinutes: Int?
    public let supportsUntimedProgress: Bool
    public let countsChildGoals: Bool
    public let countsSupportGoals: Bool
}

public struct Step: Codable, Sendable, Equatable {
    public let id: String
    public let sectionId: String
    public let title: String
    public let summary: String?
    public let type: StepType
    public let state: StepLifecycleState
    public let owner: GoalActor
    public let timing: GoalTiming
    public let dependencyStepIds: [String]
    public let isOptional: Bool
    public let isRepeatable: Bool
    public let evidenceRequired: Bool
    public let successSignals: [String]
}

public struct PlanSection: Codable, Sendable, Equatable {
    public let id: String
    public let goalId: String
    public let title: String
    public let summary: String?
    public let kind: PlanSectionKind
    public let orderIndex: Int
    public let steps: [Step]
}

public struct PlanLintIssue: Codable, Sendable, Equatable {
    public let code: PlanLintIssueCode
    public let severity: PlanLintSeverity
    public let fieldPath: [String]
    public let message: String
    public let sectionId: String?
    public let stepId: String?
}

public struct PlanLintResult: Codable, Sendable, Equatable {
    public let goalId: String?
    public let planVersion: Int
    public let isValid: Bool
    public let issueCount: Int
    public let issues: [PlanLintIssue]
}

public struct GoalPlan: Codable, Sendable, Equatable {
    public let id: String
    public let goalId: String
    public let version: Int
    public let generatedAt: String
    public let summary: String?
    public let strategy: PlanningStrategy
    public let sections: [PlanSection]
    public let lint: PlanLintResult
}

public struct ProgressEvidence: Codable, Sendable, Equatable {
    public let id: String
    public let goalId: String
    public let stepId: String?
    public let evidenceKind: ProgressEvidenceKind
    public let source: EvidenceSource
    public let capturedAt: String
    public let progressDelta: Double?
    public let confidenceDelta: Double?
    public let minutesInvested: Int?
    public let note: String?
}

public struct FeedbackEvent: Codable, Sendable, Equatable {
    public let id: String
    public let goalId: String
    public let stepId: String?
    public let eventType: FeedbackEventType
    public let sentiment: FeedbackSentiment
    public let occurredAt: String
    public let confidenceBefore: Double?
    public let confidenceAfter: Double?
    public let blockerPresent: Bool
    public let summary: String
}

public struct GoalDraft: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let source: EvidenceSource
    public let title: String
    public let summary: String?
    public let mode: GoalMode
    public let relationshipKind: GoalRelationshipKind
    public let actor: GoalActor
    public let parentGoalId: String?
    public let tags: [String]
    public let timing: GoalTiming
    public let planningStrategy: PlanningStrategy
    public let progressStrategy: ProgressStrategy
}

public struct Goal: Codable, Sendable, Equatable {
    public let schemaVersion: String
    public let id: String
    public let revision: Int
    public let createdAt: String
    public let updatedAt: String
    public let state: GoalLifecycleState
    public let title: String
    public let summary: String?
    public let mode: GoalMode
    public let relationshipKind: GoalRelationshipKind
    public let actor: GoalActor
    public let parentGoalId: String?
    public let childGoalIds: [String]
    public let supportGoalIds: [String]
    public let tags: [String]
    public let timing: GoalTiming
    public let planningStrategy: PlanningStrategy
    public let progressStrategy: ProgressStrategy
    public let plan: GoalPlan?
}

public enum GoalContractValidator {
    public static func lint(goal: Goal) -> PlanLintResult {
        var issues: [PlanLintIssue] = []

        if goal.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(
                PlanLintIssue(
                    code: .missingTitle,
                    severity: .error,
                    fieldPath: ["title"],
                    message: "Goal title is required.",
                    sectionId: nil,
                    stepId: nil
                )
            )
        }

        if goal.relationshipKind != .independent, goal.parentGoalId == nil {
            issues.append(
                PlanLintIssue(
                    code: .missingParentForRelationship,
                    severity: .error,
                    fieldPath: ["parentGoalId"],
                    message: "Child, support, and delegated goals require parentGoalId.",
                    sectionId: nil,
                    stepId: nil
                )
            )
        }

        if goal.timing.tempo == .deadlineBased, goal.timing.dueAt == nil {
            issues.append(
                PlanLintIssue(
                    code: .invalidTiming,
                    severity: .error,
                    fieldPath: ["timing"],
                    message: "Deadline-based goals require dueAt.",
                    sectionId: nil,
                    stepId: nil
                )
            )
        }

        if goal.mode == .delegatedSupport, goal.actor.ownership == .self {
            issues.append(
                PlanLintIssue(
                    code: .invalidDelegatedOwnership,
                    severity: .warning,
                    fieldPath: ["actor", "ownership"],
                    message: "Delegated support goals usually point at a non-self owner.",
                    sectionId: nil,
                    stepId: nil
                )
            )
        }

        return PlanLintResult(
            goalId: goal.id,
            planVersion: goal.plan?.version ?? 0,
            isValid: !issues.contains(where: { $0.severity == .error }),
            issueCount: issues.count,
            issues: issues
        )
    }
}
