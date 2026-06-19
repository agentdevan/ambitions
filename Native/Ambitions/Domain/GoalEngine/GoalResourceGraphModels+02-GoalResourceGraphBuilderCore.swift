import Foundation

extension GoalResourceGraphBuilderCore {
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
}
