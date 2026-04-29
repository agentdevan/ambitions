import Foundation

let pathIntelligenceSchemaVersion = "path_intelligence.native.v1"

enum PathIntelligenceFamily: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case career
    case learning
    case creativeProject = "creative_project"
    case health
    case finance
    case relationship
    case homeAndLifeAdmin = "home_and_life_admin"
    case personalGrowth = "personal_growth"
    case generalProject = "general_project"
}

enum PathIntelligenceSourceKind: String, Codable, Sendable, Equatable, Hashable {
    case userOwnedGoal = "user_owned_goal"
    case assumption
    case domainPack = "domain_pack"
    case externalKnowledge = "external_knowledge"
    case localProof = "local_proof"
}

enum PathIntelligenceFreshnessLabel: String, Codable, Sendable, Equatable, Hashable {
    case current = "Current"
    case mayNeedReview = "May Need Review"
    case basedOnOlderContext = "Based on Older Context"
}

enum PathIntelligenceHandoffSurface: String, Codable, Sendable, Equatable, Hashable {
    case today
    case goalDetail = "goal_detail"
    case plan
    case proof
}

enum PathIntelligenceScenarioKind: String, Codable, Sendable, Equatable, Hashable {
    case continueCurrentPath = "continue_current_path"
    case smallerFirstMove = "smaller_first_move"
    case fallbackPath = "fallback_path"
    case waitingReview = "waiting_review"
}

struct PathIntelligenceFamilySignal: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let family: PathIntelligenceFamily
    let summary: String
    let sourceKind: PathIntelligenceSourceKind
    let freshnessLabel: PathIntelligenceFreshnessLabel
}

struct PathIntelligenceStageProjection: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let orderIndex: Int
    let kind: GoalCompiledPathStageKind
    let prerequisiteHints: [String]
    let dependencySummaries: [String]
    let readinessHints: [String]
    let waitingStateSummary: String?
}

struct PathIntelligenceAssumptionProjection: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let summary: String
    let rationale: String
    let correctionPrompt: String
    let freshnessLabel: PathIntelligenceFreshnessLabel
}

struct PathIntelligenceProofRequirement: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let stageID: String
    let summary: String
    let proofKind: ProofReferenceKind
    let handoffSurface: PathIntelligenceHandoffSurface
}

struct PathIntelligenceFallbackPath: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let summary: String
    let condition: String
    let targetStageID: String?
    let posture: GoalPathCompilePosture
}

struct PathIntelligenceSourceBoundary: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceKind: PathIntelligenceSourceKind
    let freshnessLabel: PathIntelligenceFreshnessLabel
    let summary: String
    let sourceIDs: [String]
}

struct FutureSelfScenario: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: PathIntelligenceScenarioKind
    let title: String
    let summary: String
    let assumptionIDs: [String]
    let notPredictionLabel: String
    let handoffSurface: PathIntelligenceHandoffSurface
}

struct PathIntelligenceDailyConnection: Codable, Sendable, Equatable, Hashable {
    let stageID: String?
    let nextStepTitle: String
    let owningSurface: PathIntelligenceHandoffSurface
    let proofHint: String?
    let fallbackHint: String?
}

struct PathIntelligenceProjection: Codable, Sendable, Equatable {
    let schemaVersion: String
    let sourceCompiledPathSchemaVersion: String
    let primaryCandidateID: String?
    let overallPosture: GoalPathCompilePosture
    let families: [PathIntelligenceFamilySignal]
    let stages: [PathIntelligenceStageProjection]
    let assumptions: [PathIntelligenceAssumptionProjection]
    let proofRequirements: [PathIntelligenceProofRequirement]
    let fallbackPaths: [PathIntelligenceFallbackPath]
    let sourceBoundaries: [PathIntelligenceSourceBoundary]
    let futureSelfScenarios: [FutureSelfScenario]
    let dailyConnection: PathIntelligenceDailyConnection
}
