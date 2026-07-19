import Foundation

let goalPathCompilerSchemaVersion = "goal_path_compiler.native.v1"

enum GoalPathCompilePosture: String, Codable, Sendable, Equatable, Hashable {
    case provisional
    case stronger
    case blocked
}

enum GoalCompiledPathStageKind: String, Codable, Sendable, Equatable, Hashable {
    case setup
    case readiness
    case firstProof = "first_proof"
    case advancement
    case reviewFinish = "review_finish"
}

enum GoalCompiledPathDependencyKind: String, Codable, Sendable, Equatable, Hashable {
    case stageOrdering = "stage_ordering"
    case readiness
    case support
    case timeline
    case knowledge
}

enum GoalCompiledPathBranchType: String, Codable, Sendable, Equatable, Hashable {
    case fallback
    case alternateInterpretation = "alternate_interpretation"
    case blocked
}

enum GoalCompiledPathUncertaintyReason: String, Codable, Sendable, Equatable, Hashable {
    case activeAmbiguity = "active_ambiguity"
    case missingContext = "missing_context"
    case carriedAssumption = "carried_assumption"
    case carriedRisk = "carried_risk"
    case blockedReadiness = "blocked_readiness"
}

enum GoalCompiledPathAuditKind: String, Codable, Sendable, Equatable, Hashable {
    case interpretationSelection = "interpretation_selection"
    case dependencyCarryForward = "dependency_carry_forward"
    case assumptionCarryForward = "assumption_carry_forward"
    case riskCarryForward = "risk_carry_forward"
    case knowledgeEvidence = "knowledge_evidence"
}

enum GoalCompiledPathRequirementKind: String, Codable, Sendable, Equatable, Hashable {
    case externalRequirement = "external_requirement"
    case domainReadiness = "domain_readiness"
}

enum GoalCompiledPathReadinessCriterionKind: String, Codable, Sendable, Equatable, Hashable {
    case confirmation
    case eligibility
}

enum GoalCompiledPathResourceHookKind: String, Codable, Sendable, Equatable, Hashable {
    case requirementReference = "requirement_reference"
    case preparationMaterial = "preparation_material"
}

enum GoalCompiledPathResourceHookPlaceholderState: String, Codable, Sendable, Equatable, Hashable {
    case resourceNeeded = "resource_needed"
}

enum GoalCompiledPathPackAuditContributionKind: String, Codable, Sendable, Equatable, Hashable {
    case requirementHint = "requirement_hint"
    case dependencyHint = "dependency_hint"
    case readinessCriterion = "readiness_criterion"
    case riskHint = "risk_hint"
    case resourceHook = "resource_hook"
    case branchAddition = "branch_addition"
}

struct GoalCompiledPathConfidence: Codable, Sendable, Equatable {
    let overall: RecommendationConfidence
    let score: Double
    let uncertaintyTags: [String]
}

struct GoalCompiledPathBlockingReason: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let field: MissingFieldKey?
}

struct GoalCompiledPathAssumption: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let rationale: String
    let confidence: AssumptionConfidence
    let source: ContractValueSource
    let relatedField: MissingFieldKey?
    let safeForCompilation: Bool
}

struct GoalCompiledPathRisk: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let kind: GoalUnderstandingRiskKind
    let severity: GoalClarificationSeverity
}

struct GoalCompiledPathRequirementHint: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let kind: GoalCompiledPathRequirementKind
    let relatedField: MissingFieldKey?
    let relatedStageID: String?
    let blocking: Bool
}

struct GoalCompiledPathReadinessCriterion: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let kind: GoalCompiledPathReadinessCriterionKind
    let targetStageID: String?
    let token: String
    let blocking: Bool
}

struct GoalCompiledPathResourceHook: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let kind: GoalCompiledPathResourceHookKind
    let targetStageID: String?
    let relatedDomains: [LifeDomainKey]
    let sourceClaimIDs: [String]
    let sourceRecordIDs: [String]
    let optionality: GoalCompiledPathResourceOptionality
    let placeholderState: GoalCompiledPathResourceHookPlaceholderState
}

struct GoalCompiledPathAppliedPack: Codable, Sendable, Equatable, Hashable {
    let packID: String
    let displayName: String
    let matchConfidence: Double
    let matchedDomains: [LifeDomainKey]
    let matchReasons: [String]
    let provisional: Bool
}

struct GoalCompiledPathDependency: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let summary: String
    let kind: GoalCompiledPathDependencyKind
    let sourceClaimIDs: [String]
    let sourceRecordIDs: [String]
    let blocking: Bool
    let relatedStageID: String?
}

struct GoalCompiledPathStage: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let summary: String
    let orderIndex: Int
    let kind: GoalCompiledPathStageKind
    let dependencyIDs: [String]
    let prerequisiteHints: [String]
    let readinessHints: [String]
    let uncertainBecause: [GoalCompiledPathUncertaintyReason]
}

struct GoalCompiledPathBranch: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let branchType: GoalCompiledPathBranchType
    let summary: String
    let condition: String
    let targetCandidateID: String?
    let targetStageID: String?
    let posture: GoalPathCompilePosture
}

struct GoalCompiledPathCandidate: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let summary: String
    let isPrimary: Bool
    let posture: GoalPathCompilePosture
    let safeForStarterPlanning: Bool
    let stages: [GoalCompiledPathStage]
    let dependencies: [GoalCompiledPathDependency]
    let branches: [GoalCompiledPathBranch]
    let assumptions: [GoalCompiledPathAssumption]
    let risks: [GoalCompiledPathRisk]
    let appliedPacks: [GoalCompiledPathAppliedPack]
    let requirementHints: [GoalCompiledPathRequirementHint]
    let readinessCriteria: [GoalCompiledPathReadinessCriterion]
    let resourceHooks: [GoalCompiledPathResourceHook]
    let blockingReasons: [GoalCompiledPathBlockingReason]
    let confidence: GoalCompiledPathConfidence

    init(
        id: String,
        title: String,
        summary: String,
        isPrimary: Bool,
        posture: GoalPathCompilePosture,
        safeForStarterPlanning: Bool,
        stages: [GoalCompiledPathStage],
        dependencies: [GoalCompiledPathDependency],
        branches: [GoalCompiledPathBranch],
        assumptions: [GoalCompiledPathAssumption],
        risks: [GoalCompiledPathRisk],
        appliedPacks: [GoalCompiledPathAppliedPack] = [],
        requirementHints: [GoalCompiledPathRequirementHint] = [],
        readinessCriteria: [GoalCompiledPathReadinessCriterion] = [],
        resourceHooks: [GoalCompiledPathResourceHook] = [],
        blockingReasons: [GoalCompiledPathBlockingReason],
        confidence: GoalCompiledPathConfidence
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.isPrimary = isPrimary
        self.posture = posture
        self.safeForStarterPlanning = safeForStarterPlanning
        self.stages = stages
        self.dependencies = dependencies
        self.branches = branches
        self.assumptions = assumptions
        self.risks = risks
        self.appliedPacks = appliedPacks
        self.requirementHints = requirementHints
        self.readinessCriteria = readinessCriteria
        self.resourceHooks = resourceHooks
        self.blockingReasons = blockingReasons
        self.confidence = confidence
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case summary
        case isPrimary
        case posture
        case safeForStarterPlanning
        case stages
        case dependencies
        case branches
        case assumptions
        case risks
        case appliedPacks
        case requirementHints
        case readinessCriteria
        case resourceHooks
        case blockingReasons
        case confidence
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decode(String.self, forKey: .summary)
        isPrimary = try container.decode(Bool.self, forKey: .isPrimary)
        posture = try container.decode(GoalPathCompilePosture.self, forKey: .posture)
        safeForStarterPlanning = try container.decode(Bool.self, forKey: .safeForStarterPlanning)
        stages = try container.decode([GoalCompiledPathStage].self, forKey: .stages)
        dependencies = try container.decode([GoalCompiledPathDependency].self, forKey: .dependencies)
        branches = try container.decode([GoalCompiledPathBranch].self, forKey: .branches)
        assumptions = try container.decode([GoalCompiledPathAssumption].self, forKey: .assumptions)
        risks = try container.decode([GoalCompiledPathRisk].self, forKey: .risks)
        appliedPacks = try container.decodeIfPresent([GoalCompiledPathAppliedPack].self, forKey: .appliedPacks) ?? []
        requirementHints = try container.decodeIfPresent([GoalCompiledPathRequirementHint].self, forKey: .requirementHints) ?? []
        readinessCriteria = try container.decodeIfPresent([GoalCompiledPathReadinessCriterion].self, forKey: .readinessCriteria) ?? []
        resourceHooks = try container.decodeIfPresent([GoalCompiledPathResourceHook].self, forKey: .resourceHooks) ?? []
        blockingReasons = try container.decode([GoalCompiledPathBlockingReason].self, forKey: .blockingReasons)
        confidence = try container.decode(GoalCompiledPathConfidence.self, forKey: .confidence)
    }
}

struct GoalCompiledPathUncertainty: Codable, Sendable, Equatable {
    let ambiguityActive: Bool
    let missingContextFields: [MissingFieldKey]
    let unresolvedQuestionIDs: [String]
    let alternateInterpretationsActive: Bool
    let knowledgeContextAttached: Bool
    let knowledgeContextRequired: Bool
}

struct GoalCompiledPathAuditEntry: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let kind: GoalCompiledPathAuditKind
    let sourceInterpretationID: String?
    let sourceDependencyID: String?
    let sourceRiskID: String?
    let sourceAssumptionID: String?
    let claimID: String?
    let sourceRecordID: String?
    let summary: String
}

struct GoalCompiledPathPackAuditEntry: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let packID: String
    let contributionKind: GoalCompiledPathPackAuditContributionKind
    let artifactID: String
    let targetCandidateID: String
    let targetStageID: String?
    let summary: String
}

struct GoalCompiledPathAuditMetadata: Codable, Sendable, Equatable {
    let entries: [GoalCompiledPathAuditEntry]
    let packEntries: [GoalCompiledPathPackAuditEntry]

    init(
        entries: [GoalCompiledPathAuditEntry],
        packEntries: [GoalCompiledPathPackAuditEntry] = []
    ) {
        self.entries = entries
        self.packEntries = packEntries
    }

    enum CodingKeys: String, CodingKey {
        case entries
        case packEntries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        entries = try container.decode([GoalCompiledPathAuditEntry].self, forKey: .entries)
        packEntries = try container.decodeIfPresent([GoalCompiledPathPackAuditEntry].self, forKey: .packEntries) ?? []
    }
}

struct GoalCompiledPath: Codable, Sendable, Equatable {
    let schemaVersion: String
    let sourceUnderstandingSchemaVersion: String
    let overallPosture: GoalPathCompilePosture
    let safeForStarterPlanning: Bool
    let candidates: [GoalCompiledPathCandidate]
    let uncertainty: GoalCompiledPathUncertainty
    let audit: GoalCompiledPathAuditMetadata
}

extension GoalCompiledPath {
    static func legacyFallback(from understanding: GoalUnderstanding) -> GoalCompiledPath {
        GoalCompiledPathCompilerCore().compile(understanding: understanding)
    }
}
