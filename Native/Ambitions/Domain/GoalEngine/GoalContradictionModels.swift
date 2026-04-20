import Foundation

let goalContradictionSchemaVersion = "goal_contradiction.native.v1"

enum GoalContradictionCode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case inputTimingConflict = "input_timing_conflict"
    case inputGoalSubjectGap = "input_goal_subject_gap"
    case requiredKnowledgeClaimConflict = "required_knowledge_claim_conflict"
    case requiredResourceMissingSupport = "required_resource_missing_support"
    case requiredResourceProviderUnavailable = "required_resource_provider_unavailable"
    case requiredResourceStaleSupport = "required_resource_stale_support"
    case blockingReadinessMissingSupport = "blocking_readiness_missing_support"
    case starterAssumptionVsBlockingRequirement = "starter_assumption_vs_blocking_requirement"
    case blockedStepHasCompletionEvidence = "blocked_step_has_completion_evidence"
    case plannedStepMarkedNotRelevant = "planned_step_marked_not_relevant"
    case energyFitVsSameGoalBehaviorFriction = "energy_fit_vs_same_goal_behavior_friction"
    case energyFitVsSameGoalBehaviorSupport = "energy_fit_vs_same_goal_behavior_support"
}

enum GoalContradictionCategory: String, Codable, Sendable, Equatable, Hashable {
    case goalInput = "goal_input"
    case knowledgeRequirement = "knowledge_requirement"
    case assumptionRequirement = "assumption_requirement"
    case observedBehavior = "observed_behavior"
    case energyBehavior = "energy_behavior"
}

enum GoalContradictionSeverity: String, Codable, Sendable, Equatable, Hashable {
    case informational
    case important
    case blocking

    var sortRank: Int {
        switch self {
        case .blocking: return 3
        case .important: return 2
        case .informational: return 1
        }
    }
}

enum GoalContradictionArtifactKind: String, Codable, Sendable, Equatable, Hashable {
    case inputContradiction = "input_contradiction"
    case clarificationQuestion = "clarification_question"
    case understandingConstraint = "understanding_constraint"
    case compiledPathRequirement = "compiled_path_requirement"
    case compiledPathReadinessCriterion = "compiled_path_readiness_criterion"
    case compiledPathAssumption = "compiled_path_assumption"
    case resource = "resource"
    case knowledgeClaim = "knowledge_claim"
    case knowledgeProvider = "knowledge_provider"
    case planStep = "plan_step"
    case progressEvidence = "progress_evidence"
    case feedbackEvent = "feedback_event"
    case energyEvaluation = "energy_evaluation"
}

struct GoalContradictionArtifactRef: Codable, Sendable, Equatable, Hashable {
    let kind: GoalContradictionArtifactKind
    let id: String
    let candidateID: String?
    let stageID: String?
}

struct GoalContradictionRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let code: GoalContradictionCode
    let category: GoalContradictionCategory
    let severity: GoalContradictionSeverity
    let confidence: RecommendationConfidence
    let summary: String
    let candidateID: String?
    let stageID: String?
    let artifactRefs: [GoalContradictionArtifactRef]
}

struct GoalContradictionReport: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let records: [GoalContradictionRecord]

    static func empty(
        schemaVersion: String = goalContradictionSchemaVersion
    ) -> GoalContradictionReport {
        GoalContradictionReport(schemaVersion: schemaVersion, records: [])
    }
}

extension GoalContradictionArtifactRef {
    var normalizedIdentity: String {
        [
            kind.rawValue,
            id,
            candidateID ?? "",
            stageID ?? ""
        ].joined(separator: "::")
    }
}

extension GoalContradictionRecord {
    var normalizedArtifactRefs: [GoalContradictionArtifactRef] {
        artifactRefs.sorted { lhs, rhs in
            if lhs.kind.rawValue != rhs.kind.rawValue {
                return lhs.kind.rawValue < rhs.kind.rawValue
            }
            if lhs.id != rhs.id {
                return lhs.id < rhs.id
            }
            if lhs.candidateID != rhs.candidateID {
                return (lhs.candidateID ?? "") < (rhs.candidateID ?? "")
            }
            return (lhs.stageID ?? "") < (rhs.stageID ?? "")
        }
    }

    var deduplicationKey: String {
        let artifactKey = normalizedArtifactRefs.map(\.normalizedIdentity).joined(separator: "|")
        return [
            code.rawValue,
            candidateID ?? "",
            stageID ?? "",
            artifactKey
        ].joined(separator: "##")
    }
}

