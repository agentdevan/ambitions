import Foundation

let goalEnergyFitSchemaVersion = "goal_energy_fit.native.v1"

enum EnergyCapacityLevel: String, Codable, Sendable, Equatable, Hashable {
    case unknown
    case assumedNeutral = "assumed_neutral"
    case low
    case moderate
    case high
}

enum EnergyRecoveryState: String, Codable, Sendable, Equatable, Hashable {
    case unknown
    case assumedNeutral = "assumed_neutral"
    case needsRecovery = "needs_recovery"
    case steady
    case stretch
}

enum EnergyCapacityContextSource: String, Codable, Sendable, Equatable, Hashable {
    case unknown
    case assumedNeutral = "assumed_neutral"
    case structuralPlan = "structural_plan"
}

enum EnergyPacingPosture: String, Codable, Sendable, Equatable, Hashable {
    case unknown
    case gentle
    case steady
    case push
}

enum EnergyWorkShape: String, Codable, Sendable, Equatable, Hashable {
    case unknown
    case planning
    case execution
    case deepWork = "deep_work"
    case recovery
    case review
    case support
}

enum EnergyEffortDemand: String, Codable, Sendable, Equatable, Hashable {
    case unknown
    case light
    case moderate
    case high
}

enum EnergyFocusDemand: String, Codable, Sendable, Equatable, Hashable {
    case unknown
    case light
    case moderate
    case high
}

enum EnergyRecoveryCompatibility: String, Codable, Sendable, Equatable, Hashable {
    case unknown
    case compatible
    case neutral
    case strained
}

enum EnergyFitBand: String, Codable, Sendable, Equatable, Hashable {
    case unknown
    case strained
    case constrained
    case sustainable
    case supportive
}

enum GoalEnergyFitTargetKind: String, Codable, Sendable, Equatable, Hashable {
    case pathCandidate = "path_candidate"
    case pathStage = "path_stage"
    case planStep = "plan_step"
}

enum GoalEnergyFitReasonCode: String, Codable, Sendable, Equatable, Hashable {
    case assumedNeutralCapacity = "assumed_neutral_capacity"
    case canonicalMetadata = "canonical_metadata"
    case structuralUnknown = "structural_unknown"
    case candidateBlocked = "candidate_blocked"
    case provisionalPath = "provisional_path"
    case stageProgression = "stage_progression"
    case recoveryCompatible = "recovery_compatible"
    case lowFrictionStep = "low_friction_step"
    case blockedDependency = "blocked_dependency"
    case dependencyLoad = "dependency_load"
    case deadlinePressure = "deadline_pressure"
    case sustainablePacing = "sustainable_pacing"
    case highFocusDemand = "high_focus_demand"
}

enum GoalEnergyFitReasonImpact: String, Codable, Sendable, Equatable, Hashable {
    case negative
    case neutral
    case positive
}

enum PlanningEnergyFitSummarySource: String, Codable, Sendable, Equatable, Hashable {
    case canonicalMetadata = "canonical_metadata"
    case serviceFallback = "service_fallback"
}

struct EnergyCapacityContext: Codable, Sendable, Equatable, Hashable {
    let capacityLevel: EnergyCapacityLevel
    let recoveryState: EnergyRecoveryState
    let pacingPosture: EnergyPacingPosture
    let source: EnergyCapacityContextSource

    static func unknown() -> EnergyCapacityContext {
        EnergyCapacityContext(
            capacityLevel: .unknown,
            recoveryState: .unknown,
            pacingPosture: .unknown,
            source: .unknown
        )
    }

    static func assumedNeutral() -> EnergyCapacityContext {
        EnergyCapacityContext(
            capacityLevel: .assumedNeutral,
            recoveryState: .assumedNeutral,
            pacingPosture: .steady,
            source: .assumedNeutral
        )
    }
}

struct GoalEnergyFitReason: Codable, Sendable, Equatable, Hashable {
    let code: GoalEnergyFitReasonCode
    let targetKind: GoalEnergyFitTargetKind
    let targetID: String
    let relatedStageKind: GoalCompiledPathStageKind?
    let relatedStepType: StepType?
    let impact: GoalEnergyFitReasonImpact
    let summary: String
}

struct GoalEnergyFitEvaluation: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let targetKind: GoalEnergyFitTargetKind
    let targetID: String
    let candidateID: String?
    let stageID: String?
    let stepID: String?
    let workShape: EnergyWorkShape
    let effortDemand: EnergyEffortDemand
    let focusDemand: EnergyFocusDemand
    let recoveryCompatibility: EnergyRecoveryCompatibility
    let pacingPosture: EnergyPacingPosture
    let fitBand: EnergyFitBand
    let score: Double
    let reasons: [GoalEnergyFitReason]
}

struct GoalEnergyCandidateSummary: Codable, Sendable, Equatable, Hashable {
    let candidateID: String
    let fitBand: EnergyFitBand
    let score: Double
    let evaluationIDs: [String]
}

struct GoalEnergyModelAuditEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let targetKind: GoalEnergyFitTargetKind
    let targetID: String
    let reasonCodes: [GoalEnergyFitReasonCode]
}

struct GoalEnergyModelAuditMetadata: Codable, Sendable, Equatable, Hashable {
    let entries: [GoalEnergyModelAuditEntry]
}

struct GoalEnergyModel: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let sourceCompiledPathSchemaVersion: String?
    let capacityContext: EnergyCapacityContext
    let overallBand: EnergyFitBand
    let candidateSummaries: [GoalEnergyCandidateSummary]
    let evaluations: [GoalEnergyFitEvaluation]
    let audit: GoalEnergyModelAuditMetadata

    static func unevaluated() -> GoalEnergyModel {
        GoalEnergyModel(
            schemaVersion: goalEnergyFitSchemaVersion,
            sourceCompiledPathSchemaVersion: nil,
            capacityContext: .unknown(),
            overallBand: .unknown,
            candidateSummaries: [],
            evaluations: [],
            audit: GoalEnergyModelAuditMetadata(entries: [])
        )
    }
}

struct PlanningEnergyFitSummary: Codable, Sendable, Equatable, Hashable {
    let source: PlanningEnergyFitSummarySource
    let fitBand: EnergyFitBand
    let score: Double
    let reasonCodes: [GoalEnergyFitReasonCode]
}
