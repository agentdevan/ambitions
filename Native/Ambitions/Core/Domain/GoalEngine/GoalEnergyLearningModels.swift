import Foundation

let goalEnergyLearningSchemaVersion = "goal_energy_learning.native.v1"

enum GoalEnergyLearningEvidenceKind: String, Codable, Sendable, Equatable, Hashable {
    case positiveCompletion = "positive_completion"
    case minimumVersionCompletion = "minimum_version_completion"
    case lowEffortCompletion = "low_effort_completion"
    case highEffortCompletion = "high_effort_completion"
    case delayFriction = "delay_friction"
    case skipFriction = "skip_friction"
    case oversizedFriction = "oversized_friction"
    case confusionFriction = "confusion_friction"
    case notRelevantFriction = "not_relevant_friction"
}

enum GoalEnergyLearnedTendencyCode: String, Codable, Sendable, Equatable, Hashable {
    case supportsLightExecution = "supports_light_execution"
    case strainsHighEffort = "strains_high_effort"
    case mixedOrInsufficientHistory = "mixed_or_insufficient_history"
}

enum GoalEnergyLearningReasonCode: String, Codable, Sendable, Equatable, Hashable {
    case missingCanonicalEnergyModel = "missing_canonical_energy_model"
    case insufficientSignals = "insufficient_signals"
    case conflictingHistory = "conflicting_history"
    case noSafeSameGoalMatch = "no_safe_same_goal_match"
    case sameStepPositiveHistory = "same_step_positive_history"
    case sameStepFrictionHistory = "same_step_friction_history"
    case sameGoalSameTypeFallback = "same_goal_same_type_fallback"
    case lowEffortSupport = "low_effort_support"
    case oversizedOrHighEffortStrain = "oversized_or_high_effort_strain"
}

struct GoalEnergyLearningEvidenceReference: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalID: String
    let stepID: String?
    let occurredAt: String
    let kind: GoalEnergyLearningEvidenceKind
}

struct GoalEnergyLearnedTendency: Codable, Sendable, Equatable, Hashable {
    let code: GoalEnergyLearnedTendencyCode
    let confidence: RecommendationConfidence
    let evidenceCount: Int
    let frictionCount: Int
    let evidenceReferences: [GoalEnergyLearningEvidenceReference]
    let reasonCodes: [GoalEnergyLearningReasonCode]
    let summary: String
}

struct PlanningEnergyLearningSummary: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let rankingAdjustment: Double
    let confidence: RecommendationConfidence
    let tendencyCodes: [GoalEnergyLearnedTendencyCode]
    let reasonCodes: [GoalEnergyLearningReasonCode]
    let evidenceCount: Int
    let frictionCount: Int
    let summary: String
}
