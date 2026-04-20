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

    private enum CodingKeys: String, CodingKey {
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

private extension GoalResourceGraphBuilderCore {
    struct BuiltResources {
        let resources: [GoalResourceEntity]
        let auditEntries: [GoalResourceGraphAuditEntry]
    }

    func stableClaims(from context: GoalUnderstandingKnowledgeContext?) -> [KnowledgeClaim] {
        (context?.claims ?? []).sorted { lhs, rhs in
            if lhs.subject != rhs.subject {
                return lhs.subject < rhs.subject
            }
            return lhs.id < rhs.id
        }
    }

    func stableSources(
        from context: GoalUnderstandingKnowledgeContext?,
        claims: [KnowledgeClaim]
    ) -> [KnowledgeSourceRecord] {
        var byID: [String: KnowledgeSourceRecord] = [:]
        for source in (context?.sources ?? []).sorted(by: { $0.id < $1.id }) {
            byID[source.id] = source
        }
        for claim in claims {
            byID[claim.source.id] = claim.source
        }
        return byID.values.sorted { $0.id < $1.id }
    }

    func projectedSourceEntity(from source: KnowledgeSourceRecord) -> GoalResourceSourceEntity {
        GoalResourceSourceEntity(
            id: source.id,
            sourceRecordID: source.id,
            providerID: source.providerID,
            provenanceKind: source.provenanceKind,
            isOfficial: source.isOfficial,
            publisher: source.publisher,
            locator: source.locator
        )
    }

    func buildPackAuditLookup(from compiledPath: GoalCompiledPath) -> [String: String] {
        Dictionary(
            uniqueKeysWithValues: compiledPath.audit.packEntries
                .filter { $0.contributionKind == .resourceHook }
                .map { ("\($0.targetCandidateID)|\($0.artifactID)", $0.id) }
        )
    }

    func buildResources(
        for hook: GoalCompiledPathResourceHook,
        candidate: GoalCompiledPathCandidate,
        claims: [KnowledgeClaim],
        packAuditLookup: [String: String],
        knowledgeContextAvailable: Bool
    ) -> BuiltResources {
        let selectionGroupID = makeSelectionGroupID(candidateID: candidate.id, hook: hook)
        let packAuditEntryID = packAuditLookup["\(candidate.id)|\(hook.id)"]
        let matchedClaims = matchingClaims(for: hook, claims: claims)

        if matchedClaims.isEmpty == false {
            let resources = matchedClaims.map { claim in
                resourceEntity(
                    claim: claim,
                    hook: hook,
                    candidate: candidate,
                    selectionGroupID: selectionGroupID
                )
            }
            let auditEntries = resources.map { resource in
                GoalResourceGraphAuditEntry(
                    id: "audit-\(resource.id)",
                    resourceID: resource.id,
                    candidateID: resource.candidateID,
                    targetStageID: resource.targetStageID,
                    hookID: resource.hookID,
                    packAuditEntryID: packAuditEntryID,
                    claimID: resource.claimIDs.first,
                    sourceRecordID: resource.sourceRecordIDs.first,
                    rankingFlags: []
                )
            }
            return BuiltResources(resources: resources, auditEntries: auditEntries)
        }

        let missingState: GoalResourceMissingState
        let resolutionState: GoalResourceResolutionState

        if hook.sourceClaimIDs.isEmpty && hook.sourceRecordIDs.isEmpty {
            missingState = .resourceNeeded
            resolutionState = .placeholderOnly
        } else if knowledgeContextAvailable == false {
            missingState = .knowledgeContextUnavailable
            resolutionState = .unresolved
        } else {
            missingState = .referencedEvidenceMissing
            resolutionState = .unresolved
        }

        let resource = placeholderResourceEntity(
            hook: hook,
            candidate: candidate,
            selectionGroupID: selectionGroupID,
            resolutionState: resolutionState,
            missingState: missingState
        )
        let auditEntry = GoalResourceGraphAuditEntry(
            id: "audit-\(resource.id)",
            resourceID: resource.id,
            candidateID: resource.candidateID,
            targetStageID: resource.targetStageID,
            hookID: resource.hookID,
            packAuditEntryID: packAuditEntryID,
            claimID: nil,
            sourceRecordID: nil,
            rankingFlags: []
        )
        return BuiltResources(resources: [resource], auditEntries: [auditEntry])
    }

    func matchingClaims(
        for hook: GoalCompiledPathResourceHook,
        claims: [KnowledgeClaim]
    ) -> [KnowledgeClaim] {
        claims.filter { claim in
            hook.sourceClaimIDs.contains(claim.id) ||
                hook.sourceRecordIDs.contains(claim.source.id)
        }
        .sorted { lhs, rhs in
            if lhs.id != rhs.id {
                return lhs.id < rhs.id
            }
            return lhs.source.id < rhs.source.id
        }
    }

    func resourceEntity(
        claim: KnowledgeClaim,
        hook: GoalCompiledPathResourceHook,
        candidate: GoalCompiledPathCandidate,
        selectionGroupID: String
    ) -> GoalResourceEntity {
        let resolutionState: GoalResourceResolutionState =
            claim.source.provenanceKind == .inferred || claim.uncertaintyFlags.contains(.inferred)
            ? .inferred
            : .concrete

        return GoalResourceEntity(
            id: "resource-\(selectionGroupID)-\(normalized(claim.id))-\(normalized(claim.source.id))",
            candidateID: candidate.id,
            targetStageID: hook.targetStageID,
            hookID: hook.id,
            selectionGroupID: selectionGroupID,
            hookKind: hook.kind,
            resourceType: resourceType(for: hook.kind),
            resourceRole: resourceRole(for: hook.kind),
            resolutionState: resolutionState,
            originRelation: candidate.appliedPacks.isEmpty ? .knowledgeDerived : .packAndKnowledge,
            optionality: hook.optionality,
            relatedDomains: hook.relatedDomains.sorted { $0.rawValue < $1.rawValue },
            appliedPackIDs: candidate.appliedPacks.map(\.packID).sorted(),
            claimIDs: [claim.id],
            sourceRecordIDs: [claim.source.id],
            trustLevel: claim.trustLevel,
            freshnessState: claim.freshness.state,
            uncertaintyFlags: Array(claim.uncertaintyFlags).sorted { $0.rawValue < $1.rawValue },
            missingResourceState: .none,
            ranking: GoalResourceRankingMetadata(
                rank: 0,
                totalScore: 0,
                sourceTrustScore: 0,
                sourceFreshnessScore: 0,
                domainRelevanceScore: 0,
                stageRelevanceScore: 0,
                readinessRelevanceScore: 0,
                optionalityScore: 0,
                tieBreakKey: "\(selectionGroupID)-\(claim.id)-\(claim.source.id)",
                flags: []
            )
        )
    }

    func placeholderResourceEntity(
        hook: GoalCompiledPathResourceHook,
        candidate: GoalCompiledPathCandidate,
        selectionGroupID: String,
        resolutionState: GoalResourceResolutionState,
        missingState: GoalResourceMissingState
    ) -> GoalResourceEntity {
        let suffix = resolutionState == .placeholderOnly ? "placeholder" : "unresolved"
        return GoalResourceEntity(
            id: "resource-\(selectionGroupID)-\(suffix)",
            candidateID: candidate.id,
            targetStageID: hook.targetStageID,
            hookID: hook.id,
            selectionGroupID: selectionGroupID,
            hookKind: hook.kind,
            resourceType: resourceType(for: hook.kind),
            resourceRole: resourceRole(for: hook.kind),
            resolutionState: resolutionState,
            originRelation: .packContributed,
            optionality: hook.optionality,
            relatedDomains: hook.relatedDomains.sorted { $0.rawValue < $1.rawValue },
            appliedPackIDs: candidate.appliedPacks.map(\.packID).sorted(),
            claimIDs: [],
            sourceRecordIDs: [],
            trustLevel: nil,
            freshnessState: nil,
            uncertaintyFlags: [],
            missingResourceState: missingState,
            ranking: GoalResourceRankingMetadata(
                rank: 0,
                totalScore: 0,
                sourceTrustScore: 0,
                sourceFreshnessScore: 0,
                domainRelevanceScore: 0,
                stageRelevanceScore: 0,
                readinessRelevanceScore: 0,
                optionalityScore: 0,
                tieBreakKey: "\(selectionGroupID)-\(suffix)",
                flags: []
            )
        )
    }

    func rankedResources(from resources: [GoalResourceEntity]) -> [GoalResourceEntity] {
        let grouped = Dictionary(grouping: resources, by: \.selectionGroupID)
        var result: [GoalResourceEntity] = []

        for selectionGroupID in grouped.keys.sorted() {
            guard let group = grouped[selectionGroupID] else { continue }
            let scored = group.map(scoredResource)
            let ordered = scored.sorted(by: rankedResourceOrdering)
            for (index, scoredResource) in ordered.enumerated() {
                result.append(
                    GoalResourceEntity(
                        id: scoredResource.resource.id,
                        candidateID: scoredResource.resource.candidateID,
                        targetStageID: scoredResource.resource.targetStageID,
                        hookID: scoredResource.resource.hookID,
                        selectionGroupID: scoredResource.resource.selectionGroupID,
                        hookKind: scoredResource.resource.hookKind,
                        resourceType: scoredResource.resource.resourceType,
                        resourceRole: scoredResource.resource.resourceRole,
                        resolutionState: scoredResource.resource.resolutionState,
                        originRelation: scoredResource.resource.originRelation,
                        optionality: scoredResource.resource.optionality,
                        relatedDomains: scoredResource.resource.relatedDomains,
                        appliedPackIDs: scoredResource.resource.appliedPackIDs,
                        claimIDs: scoredResource.resource.claimIDs,
                        sourceRecordIDs: scoredResource.resource.sourceRecordIDs,
                        trustLevel: scoredResource.resource.trustLevel,
                        freshnessState: scoredResource.resource.freshnessState,
                        uncertaintyFlags: scoredResource.resource.uncertaintyFlags,
                        missingResourceState: scoredResource.resource.missingResourceState,
                        ranking: GoalResourceRankingMetadata(
                            rank: index + 1,
                            totalScore: scoredResource.totalScore,
                            sourceTrustScore: scoredResource.sourceTrustScore,
                            sourceFreshnessScore: scoredResource.sourceFreshnessScore,
                            domainRelevanceScore: scoredResource.domainRelevanceScore,
                            stageRelevanceScore: scoredResource.stageRelevanceScore,
                            readinessRelevanceScore: scoredResource.readinessRelevanceScore,
                            optionalityScore: scoredResource.optionalityScore,
                            tieBreakKey: scoredResource.tieBreakKey,
                            flags: scoredResource.flags
                        )
                    )
                )
            }
        }

        return result
    }

    struct ScoredResource {
        let resource: GoalResourceEntity
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

    func scoredResource(from resource: GoalResourceEntity) -> ScoredResource {
        let sourceTrustScore = trustScore(for: resource.trustLevel)
        let sourceFreshnessScore = freshnessScore(for: resource.freshnessState)
        let domainRelevanceScore = resource.relatedDomains.isEmpty ? 0.05 : 0.12
        let stageRelevanceScore = stageScore(for: resource.targetStageID)
        let readinessRelevanceScore = readinessScore(resource: resource)
        let optionalityScore = resource.optionality == .required ? 0.09 : 0.04
        let flags = rankingFlags(for: resource)
        let totalScore = roundToFour(
            resolutionScore(for: resource.resolutionState) +
                sourceTrustScore +
                sourceFreshnessScore +
                domainRelevanceScore +
                stageRelevanceScore +
                readinessRelevanceScore +
                optionalityScore
        )
        return ScoredResource(
            resource: resource,
            totalScore: totalScore,
            sourceTrustScore: sourceTrustScore,
            sourceFreshnessScore: sourceFreshnessScore,
            domainRelevanceScore: domainRelevanceScore,
            stageRelevanceScore: stageRelevanceScore,
            readinessRelevanceScore: readinessRelevanceScore,
            optionalityScore: optionalityScore,
            tieBreakKey: resource.ranking.tieBreakKey,
            flags: flags
        )
    }

    func rankedResourceOrdering(lhs: ScoredResource, rhs: ScoredResource) -> Bool {
        if lhs.totalScore != rhs.totalScore {
            return lhs.totalScore > rhs.totalScore
        }
        if resolutionOrdering(lhs.resource.resolutionState) != resolutionOrdering(rhs.resource.resolutionState) {
            return resolutionOrdering(lhs.resource.resolutionState) < resolutionOrdering(rhs.resource.resolutionState)
        }
        if optionalityOrdering(lhs.resource.optionality) != optionalityOrdering(rhs.resource.optionality) {
            return optionalityOrdering(lhs.resource.optionality) < optionalityOrdering(rhs.resource.optionality)
        }
        if lhs.sourceTrustScore != rhs.sourceTrustScore {
            return lhs.sourceTrustScore > rhs.sourceTrustScore
        }
        if lhs.sourceFreshnessScore != rhs.sourceFreshnessScore {
            return lhs.sourceFreshnessScore > rhs.sourceFreshnessScore
        }
        if lhs.domainRelevanceScore != rhs.domainRelevanceScore {
            return lhs.domainRelevanceScore > rhs.domainRelevanceScore
        }
        if lhs.stageRelevanceScore != rhs.stageRelevanceScore {
            return lhs.stageRelevanceScore > rhs.stageRelevanceScore
        }
        if lhs.readinessRelevanceScore != rhs.readinessRelevanceScore {
            return lhs.readinessRelevanceScore > rhs.readinessRelevanceScore
        }
        return lhs.tieBreakKey < rhs.tieBreakKey
    }

    func resolutionOrdering(_ state: GoalResourceResolutionState) -> Int {
        switch state {
        case .concrete: return 0
        case .inferred: return 1
        case .placeholderOnly: return 2
        case .unresolved: return 3
        }
    }

    func optionalityOrdering(_ optionality: GoalCompiledPathResourceOptionality) -> Int {
        switch optionality {
        case .required: return 0
        case .optional: return 1
        }
    }

    func resolutionScore(for state: GoalResourceResolutionState) -> Double {
        switch state {
        case .concrete: return 0.30
        case .inferred: return 0.22
        case .placeholderOnly: return 0.12
        case .unresolved: return 0.08
        }
    }

    func trustScore(for level: KnowledgeTrustLevel?) -> Double {
        switch level {
        case .high: return 0.30
        case .medium: return 0.20
        case .low: return 0.10
        case .none: return 0
        }
    }

    func freshnessScore(for state: KnowledgeFreshnessState?) -> Double {
        switch state {
        case .fresh: return 0.20
        case .unknown: return 0.03
        case .stale: return 0.01
        case .expired: return 0
        case .none: return 0
        }
    }

    func stageScore(for stageID: String?) -> Double {
        guard let stageID else { return 0.04 }
        if stageID.contains("readiness") { return 0.12 }
        if stageID.contains("first_proof") { return 0.10 }
        if stageID.contains("advancement") { return 0.08 }
        if stageID.contains("review_finish") { return 0.06 }
        if stageID.contains("setup") { return 0.05 }
        return 0.04
    }

    func readinessScore(resource: GoalResourceEntity) -> Double {
        switch resource.hookKind {
        case .requirementReference:
            return resource.targetStageID?.contains("readiness") == true ? 0.12 : 0.09
        case .preparationMaterial:
            return resource.targetStageID?.contains("readiness") == true ? 0.08 : 0.07
        }
    }

    func rankingFlags(for resource: GoalResourceEntity) -> [GoalResourceRankingFlag] {
        var flags: [GoalResourceRankingFlag] = []
        if resource.resolutionState == .placeholderOnly {
            flags.append(.placeholderOnly)
        }
        if resource.missingResourceState != .none {
            flags.append(.missingConcreteResource)
        }
        if resource.optionality == .optional {
            flags.append(.optionalResource)
        }
        if resource.relatedDomains.isEmpty == false {
            flags.append(.domainAligned)
        }
        if resource.targetStageID != nil {
            flags.append(.stageAligned)
        }
        if resource.targetStageID?.contains("readiness") == true && resource.hookKind == .requirementReference {
            flags.append(.readinessAligned)
        }
        if resource.trustLevel == .low || resource.uncertaintyFlags.contains(.lowConfidence) {
            flags.append(.lowTrustSource)
        }
        if resource.freshnessState == .stale {
            flags.append(.staleSource)
        }
        if resource.freshnessState == .expired {
            flags.append(.expiredSource)
        }
        if resource.resolutionState == .inferred {
            flags.append(.inferredSource)
        }
        if resource.sourceRecordIDs.isEmpty == false && resource.uncertaintyFlags.contains(.inferred) {
            flags.append(.inferredSource)
        }
        if resource.sourceRecordIDs.isEmpty == false &&
            resource.resolutionState != .placeholderOnly &&
            resource.resolutionState != .unresolved &&
            resource.uncertaintyFlags.contains(.inferred) == false &&
            resource.trustLevel != nil {
            if resource.uncertaintyFlags.contains(.stale) == false && resource.trustLevel == .high {
                flags.append(.officialSource)
            }
        }
        return Array(Set(flags)).sorted { $0.rawValue < $1.rawValue }
    }

    func resourceOrdering(lhs: GoalResourceEntity, rhs: GoalResourceEntity) -> Bool {
        if lhs.candidateID != rhs.candidateID {
            return lhs.candidateID < rhs.candidateID
        }
        if lhs.selectionGroupID != rhs.selectionGroupID {
            return lhs.selectionGroupID < rhs.selectionGroupID
        }
        if lhs.ranking.rank != rhs.ranking.rank {
            return lhs.ranking.rank < rhs.ranking.rank
        }
        return lhs.id < rhs.id
    }

    func candidateOrdering(lhs: GoalCompiledPathCandidate, rhs: GoalCompiledPathCandidate) -> Bool {
        if lhs.isPrimary != rhs.isPrimary {
            return lhs.isPrimary && !rhs.isPrimary
        }
        return lhs.id < rhs.id
    }

    func resourceType(for hookKind: GoalCompiledPathResourceHookKind) -> GoalResourceType {
        switch hookKind {
        case .requirementReference:
            return .reference
        case .preparationMaterial:
            return .preparationMaterial
        }
    }

    func resourceRole(for hookKind: GoalCompiledPathResourceHookKind) -> GoalResourceRole {
        switch hookKind {
        case .requirementReference:
            return .requirementSupport
        case .preparationMaterial:
            return .preparationSupport
        }
    }

    func makeSelectionGroupID(candidateID: String, hook: GoalCompiledPathResourceHook) -> String {
        let stage = hook.targetStageID ?? "no-stage"
        return "selection-\(normalized(candidateID))-\(normalized(stage))-\(normalized(hook.id))"
    }

    func normalized(_ value: String) -> String {
        let lowered = value.lowercased()
        let scalars = lowered.unicodeScalars.map { scalar -> Character in
            CharacterSet.alphanumerics.contains(scalar) ? Character(scalar) : "-"
        }
        let collapsed = String(scalars)
            .replacingOccurrences(of: "-+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return collapsed
    }

    func roundToFour(_ value: Double) -> Double {
        (value * 10_000).rounded() / 10_000
    }
}
