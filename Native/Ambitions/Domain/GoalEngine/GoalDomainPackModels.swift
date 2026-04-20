import Foundation

let goalDomainPackSchemaVersion = "goal_domain_pack.native.v1"

struct GoalDomainPackDescriptor: Codable, Sendable, Equatable, Hashable {
    let id: String
    let displayName: String
    let coveredDomains: [LifeDomainKey]
    let supportedModes: [GoalMode]
    let schemaVersion: String

    init(
        id: String,
        displayName: String,
        coveredDomains: [LifeDomainKey],
        supportedModes: [GoalMode],
        schemaVersion: String = goalDomainPackSchemaVersion
    ) {
        self.id = id
        self.displayName = displayName
        self.coveredDomains = coveredDomains
        self.supportedModes = supportedModes
        self.schemaVersion = schemaVersion
    }
}

struct GoalDomainPackMatch: Codable, Sendable, Equatable, Hashable {
    let packID: String
    let confidenceScore: Double
    let matchedDomains: [LifeDomainKey]
    let reasons: [String]
    let provisional: Bool

    static func stableOrdering(_ lhs: GoalDomainPackMatch, _ rhs: GoalDomainPackMatch) -> Bool {
        if lhs.confidenceScore != rhs.confidenceScore {
            return lhs.confidenceScore > rhs.confidenceScore
        }
        return lhs.packID < rhs.packID
    }
}

struct GoalDomainPackTarget: Codable, Sendable, Equatable, Hashable {
    let candidateID: String
    let stageID: String?

    init(candidateID: String, stageID: String? = nil) {
        self.candidateID = candidateID
        self.stageID = stageID
    }

    func makeArtifactID(packID: String, kind: String, semanticKey: String) -> String {
        var parts = [
            "pack",
            packID,
            candidateID
        ]
        if let stageID {
            parts.append(stageID)
        }
        parts.append(kind)
        parts.append(semanticKey)
        return parts.joined(separator: "-")
    }
}

struct GoalDomainPackContribution: Codable, Sendable, Equatable {
    let requirementHints: [GoalCompiledPathRequirementHint]
    let dependencyHints: [GoalCompiledPathDependency]
    let readinessCriteria: [GoalCompiledPathReadinessCriterion]
    let riskHints: [GoalCompiledPathRisk]
    let resourceHooks: [GoalCompiledPathResourceHook]
    let branchAdditions: [GoalCompiledPathBranch]
    let auditEntries: [GoalCompiledPathPackAuditEntry]

    init(
        requirementHints: [GoalCompiledPathRequirementHint] = [],
        dependencyHints: [GoalCompiledPathDependency] = [],
        readinessCriteria: [GoalCompiledPathReadinessCriterion] = [],
        riskHints: [GoalCompiledPathRisk] = [],
        resourceHooks: [GoalCompiledPathResourceHook] = [],
        branchAdditions: [GoalCompiledPathBranch] = [],
        auditEntries: [GoalCompiledPathPackAuditEntry] = []
    ) {
        self.requirementHints = requirementHints
        self.dependencyHints = dependencyHints
        self.readinessCriteria = readinessCriteria
        self.riskHints = riskHints
        self.resourceHooks = resourceHooks
        self.branchAdditions = branchAdditions
        self.auditEntries = auditEntries
    }
}

protocol GoalDomainPack: Sendable {
    var descriptor: GoalDomainPackDescriptor { get }
    func match(understanding: GoalUnderstanding) -> GoalDomainPackMatch?
    func contribute(understanding: GoalUnderstanding, candidate: GoalCompiledPathCandidate) -> GoalDomainPackContribution
}
