import Foundation

let goalResourceGraphSchemaVersion = "goal_resource_graph.native.v1"

enum GoalCompiledPathResourceOptionality: String, Codable, Sendable, Equatable, Hashable {
    case required
    case optional
}

enum GoalResourceType: String, Codable, Sendable, Equatable, Hashable {
    case reference
    case preparationMaterial = "preparation_material"
}

enum GoalResourceRole: String, Codable, Sendable, Equatable, Hashable {
    case requirementSupport = "requirement_support"
    case preparationSupport = "preparation_support"
}

enum GoalResourceResolutionState: String, Codable, Sendable, Equatable, Hashable {
    case concrete
    case inferred
    case placeholderOnly = "placeholder_only"
    case unresolved
}

enum GoalResourceOriginRelation: String, Codable, Sendable, Equatable, Hashable {
    case packContributed = "pack_contributed"
    case knowledgeDerived = "knowledge_derived"
    case packAndKnowledge = "pack_and_knowledge"
}

enum GoalResourceMissingState: String, Codable, Sendable, Equatable, Hashable {
    case none
    case resourceNeeded = "resource_needed"
    case knowledgeContextUnavailable = "knowledge_context_unavailable"
    case referencedEvidenceMissing = "referenced_evidence_missing"
}

enum GoalResourceRankingFlag: String, Codable, Sendable, Equatable, Hashable {
    case placeholderOnly = "placeholder_only"
    case missingConcreteResource = "missing_concrete_resource"
    case officialSource = "official_source"
    case inferredSource = "inferred_source"
    case agingSource = "aging_source"
    case staleSource = "stale_source"
    case expiredSource = "expired_source"
    case unknownFreshness = "unknown_freshness"
    case missingFreshnessEvidence = "missing_freshness_evidence"
    case providerUnavailable = "provider_unavailable"
    case updateRecommended = "update_recommended"
    case updateRequired = "update_required"
    case lowTrustSource = "low_trust_source"
    case domainAligned = "domain_aligned"
    case stageAligned = "stage_aligned"
    case readinessAligned = "readiness_aligned"
    case optionalResource = "optional_resource"
}

struct GoalResourceRankingMetadata: Codable, Sendable, Equatable, Hashable {
    let rank: Int
    let totalScore: Double
    let sourceTrustScore: Double
    let sourceFreshnessScore: Double
    let domainRelevanceScore: Double
    let stageRelevanceScore: Double
    let readinessRelevanceScore: Double
    let optionalityScore: Double
    let tieBreakKey: String
    let flags: [GoalResourceRankingFlag]
}

struct GoalResourceSourceEntity: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceRecordID: String
    let providerID: String
    let provenanceKind: KnowledgeProvenanceKind
    let isOfficial: Bool
    let publisher: String?
    let locator: String?
}

struct GoalResourceEntity: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let candidateID: String
    let targetStageID: String?
    let hookID: String
    let selectionGroupID: String
    let hookKind: GoalCompiledPathResourceHookKind
    let resourceType: GoalResourceType
    let resourceRole: GoalResourceRole
    let resolutionState: GoalResourceResolutionState
    let originRelation: GoalResourceOriginRelation
    let optionality: GoalCompiledPathResourceOptionality
    let relatedDomains: [LifeDomainKey]
    let appliedPackIDs: [String]
    let claimIDs: [String]
    let sourceRecordIDs: [String]
    let trustLevel: KnowledgeTrustLevel?
    let freshnessState: KnowledgeFreshnessState?
    let uncertaintyFlags: [KnowledgeUncertaintyFlag]
    let missingResourceState: GoalResourceMissingState
    let ranking: GoalResourceRankingMetadata
}

struct GoalResourceGraphCandidate: Codable, Sendable, Equatable, Hashable {
    let candidateID: String
    let isPrimary: Bool
    let posture: GoalPathCompilePosture
    let stageIDs: [String]
    let resourceIDs: [String]
}

struct GoalResourceGraphAuditEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let resourceID: String
    let candidateID: String
    let targetStageID: String?
    let hookID: String
    let packAuditEntryID: String?
    let claimID: String?
    let sourceRecordID: String?
    let rankingFlags: [GoalResourceRankingFlag]
}

struct GoalResourceGraphAuditMetadata: Codable, Sendable, Equatable, Hashable {
    let entries: [GoalResourceGraphAuditEntry]
}

struct GoalResourceGraph: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let sourceCompiledPathSchemaVersion: String
    let overallPosture: GoalPathCompilePosture
    let candidateGraphs: [GoalResourceGraphCandidate]
    let resources: [GoalResourceEntity]
    let sources: [GoalResourceSourceEntity]
    let audit: GoalResourceGraphAuditMetadata

    let freshness: GoalResourceGraphFreshnessMetadata

    init(
        schemaVersion: String,
        sourceCompiledPathSchemaVersion: String,
        overallPosture: GoalPathCompilePosture,
        candidateGraphs: [GoalResourceGraphCandidate],
        resources: [GoalResourceEntity],
        sources: [GoalResourceSourceEntity],
        audit: GoalResourceGraphAuditMetadata,
        freshness: GoalResourceGraphFreshnessMetadata = .unevaluated()
    ) {
        self.schemaVersion = schemaVersion
        self.sourceCompiledPathSchemaVersion = sourceCompiledPathSchemaVersion
        self.overallPosture = overallPosture
        self.candidateGraphs = candidateGraphs
        self.resources = resources
        self.sources = sources
        self.audit = audit
        self.freshness = freshness
    }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case sourceCompiledPathSchemaVersion
        case overallPosture
        case candidateGraphs
        case resources
        case sources
        case audit
        case freshness
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(String.self, forKey: .schemaVersion)
        sourceCompiledPathSchemaVersion = try container.decode(String.self, forKey: .sourceCompiledPathSchemaVersion)
        overallPosture = try container.decode(GoalPathCompilePosture.self, forKey: .overallPosture)
        candidateGraphs = try container.decode([GoalResourceGraphCandidate].self, forKey: .candidateGraphs)
        resources = try container.decode([GoalResourceEntity].self, forKey: .resources)
        sources = try container.decode([GoalResourceSourceEntity].self, forKey: .sources)
        audit = try container.decode(GoalResourceGraphAuditMetadata.self, forKey: .audit)
        freshness = try container.decodeIfPresent(GoalResourceGraphFreshnessMetadata.self, forKey: .freshness)
            ?? .unevaluated()
    }
}

extension GoalResourceGraph {
    static func legacyFallback(
        compiledPath: GoalCompiledPath,
        knowledgeContext: GoalUnderstandingKnowledgeContext?
    ) -> GoalResourceGraph {
        GoalResourceGraphBuilderCore().build(
            compiledPath: compiledPath,
            knowledgeContext: knowledgeContext
        )
    }
}

extension GoalResourceGraph {
    func with(
        resources: [GoalResourceEntity],
        freshness: GoalResourceGraphFreshnessMetadata
    ) -> GoalResourceGraph {
        GoalResourceGraph(
            schemaVersion: schemaVersion,
            sourceCompiledPathSchemaVersion: sourceCompiledPathSchemaVersion,
            overallPosture: overallPosture,
            candidateGraphs: candidateGraphs,
            resources: resources.sorted(by: GoalResourceGraphBuilderCore().resourceOrdering),
            sources: sources,
            audit: GoalResourceGraphAuditMetadata(
                entries: audit.entries.map { entry in
                    guard let resource = resources.first(where: { $0.id == entry.resourceID }) else {
                        return entry
                    }
                    return GoalResourceGraphAuditEntry(
                        id: entry.id,
                        resourceID: entry.resourceID,
                        candidateID: entry.candidateID,
                        targetStageID: entry.targetStageID,
                        hookID: entry.hookID,
                        packAuditEntryID: entry.packAuditEntryID,
                        claimID: entry.claimID,
                        sourceRecordID: entry.sourceRecordID,
                        rankingFlags: resource.ranking.flags
                    )
                }
                .sorted { $0.id < $1.id }
            ),
            freshness: freshness
        )
    }
}

struct GoalResourceGraphBuilderCore {
    func build(
        compiledPath: GoalCompiledPath,
        knowledgeContext: GoalUnderstandingKnowledgeContext?
    ) -> GoalResourceGraph {
        let claims = stableClaims(from: knowledgeContext)
        let sources = stableSources(from: knowledgeContext, claims: claims)
        let sourceEntities = sources.map(projectedSourceEntity).sorted { $0.id < $1.id }
        let packAuditLookup = buildPackAuditLookup(from: compiledPath)

        var builtResources: [GoalResourceEntity] = []
        var builtAuditEntries: [GoalResourceGraphAuditEntry] = []

        for candidate in compiledPath.candidates.sorted(by: candidateOrdering) {
            for hook in candidate.resourceHooks.sorted(by: { $0.id < $1.id }) {
                let resolved = buildResources(
                    for: hook,
                    candidate: candidate,
                    claims: claims,
                    packAuditLookup: packAuditLookup,
                    knowledgeContextAvailable: knowledgeContext != nil
                )
                builtResources.append(contentsOf: resolved.resources)
                builtAuditEntries.append(contentsOf: resolved.auditEntries)
            }
        }

        let rankedResources = rankedResources(from: builtResources)
        let auditByResourceID = Dictionary(uniqueKeysWithValues: builtAuditEntries.map { ($0.resourceID, $0) })
        let finalAuditEntries: [GoalResourceGraphAuditEntry] = rankedResources.compactMap { resource in
            guard let entry = auditByResourceID[resource.id] else { return nil }
            return GoalResourceGraphAuditEntry(
                id: entry.id,
                resourceID: entry.resourceID,
                candidateID: entry.candidateID,
                targetStageID: entry.targetStageID,
                hookID: entry.hookID,
                packAuditEntryID: entry.packAuditEntryID,
                claimID: entry.claimID,
                sourceRecordID: entry.sourceRecordID,
                rankingFlags: resource.ranking.flags
            )
        }
        .sorted(by: { lhs, rhs in lhs.id < rhs.id })

        let candidateGraphs = compiledPath.candidates
            .sorted(by: candidateOrdering)
            .map { candidate in
                let resourceIDs = rankedResources
                    .filter { $0.candidateID == candidate.id }
                    .sorted(by: resourceOrdering)
                    .map(\.id)
                let stageIDs = candidate.stages
                    .sorted { $0.orderIndex < $1.orderIndex }
                    .map(\.id)
                return GoalResourceGraphCandidate(
                    candidateID: candidate.id,
                    isPrimary: candidate.isPrimary,
                    posture: candidate.posture,
                    stageIDs: stageIDs,
                    resourceIDs: resourceIDs
                )
            }

        return GoalResourceGraph(
            schemaVersion: goalResourceGraphSchemaVersion,
            sourceCompiledPathSchemaVersion: compiledPath.schemaVersion,
            overallPosture: compiledPath.overallPosture,
            candidateGraphs: candidateGraphs,
            resources: rankedResources.sorted(by: resourceOrdering),
            sources: sourceEntities,
            audit: GoalResourceGraphAuditMetadata(entries: finalAuditEntries)
        )
    }
}
