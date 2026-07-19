import Foundation

protocol GoalFreshnessUpdateEvaluating: Sendable {
    func evaluate(
        graph: GoalResourceGraph,
        knowledgeContext: GoalUnderstandingKnowledgeContext?,
        referenceNow: String?
    ) -> GoalResourceGraphFreshnessMetadata

    func annotate(
        graph: GoalResourceGraph,
        knowledgeContext: GoalUnderstandingKnowledgeContext?,
        referenceNow: String?
    ) -> GoalResourceGraph
}

struct DefaultGoalFreshnessUpdateService: GoalFreshnessUpdateEvaluating {
    private let agingLeadTime: TimeInterval

    init(agingLeadTime: TimeInterval = 7 * 24 * 60 * 60) {
        self.agingLeadTime = agingLeadTime
    }

    func evaluate(
        graph: GoalResourceGraph,
        knowledgeContext: GoalUnderstandingKnowledgeContext?,
        referenceNow: String?
    ) -> GoalResourceGraphFreshnessMetadata {
        let claims = stableClaims(from: knowledgeContext)
        let claimsByID = Dictionary(uniqueKeysWithValues: claims.map { ($0.id, $0) })
        let sourcesByID = Dictionary(uniqueKeysWithValues: graph.sources.map { ($0.sourceRecordID, $0) })
        let providerAvailability = providerAvailabilityByID(from: knowledgeContext)
        let now = referenceNow.flatMap(DomainTimestamp.date(from:))

        let impacts = graph.resources
            .sorted { $0.id < $1.id }
            .map { resource in
                impact(
                    for: resource,
                    claimsByID: claimsByID,
                    sourcesByID: sourcesByID,
                    providerAvailability: providerAvailability,
                    referenceDate: now
                )
            }

        let candidateSummaries = graph.candidateGraphs
            .sorted { $0.candidateID < $1.candidateID }
            .map { candidate in
                candidateSummary(candidate: candidate, impacts: impacts)
            }

        let lineage = impacts
            .flatMap(\.lineage)
            .sorted(by: lineageOrdering)
        let maxSeverity = impacts
            .map(\.severity)
            .sortedBySeverityDescending()
            .first ?? .none

        return GoalResourceGraphFreshnessMetadata(
            evaluatedAt: referenceNow,
            overallPosture: posture(for: maxSeverity, impacts: impacts),
            updateNeeded: impacts.contains(where: \.updateNeeded),
            maxSeverity: maxSeverity,
            resourceImpacts: impacts,
            candidateSummaries: candidateSummaries,
            lineage: lineage
        )
    }

    func annotate(
        graph: GoalResourceGraph,
        knowledgeContext: GoalUnderstandingKnowledgeContext?,
        referenceNow: String?
    ) -> GoalResourceGraph {
        let metadata = evaluate(
            graph: graph,
            knowledgeContext: knowledgeContext,
            referenceNow: referenceNow
        )
        let flagsByResourceID = Dictionary(uniqueKeysWithValues: metadata.resourceImpacts.map { ($0.resourceID, $0.rankingFlagsAdded) })
        let resources = graph.resources.map { resource in
            guard let additionalFlags = flagsByResourceID[resource.id], additionalFlags.isEmpty == false else {
                return resource
            }
            return resource.withAdditionalRankingFlags(additionalFlags)
        }

        return graph.with(resources: resources, freshness: metadata)
    }
}

private extension DefaultGoalFreshnessUpdateService {
    struct ResourceEvaluation {
        let posture: GoalFreshnessPosture
        let severity: GoalUpdateNeededSeverity
        let flags: [GoalUpdateNeededFlag]
        let rankingImpactScore: Double
        let rankingFlags: [GoalResourceRankingFlag]
        let lineageReasons: [GoalUpdateNeededFlag]
    }

    func stableClaims(from context: GoalUnderstandingKnowledgeContext?) -> [KnowledgeClaim] {
        (context?.claims ?? []).sorted { lhs, rhs in
            if lhs.id != rhs.id {
                return lhs.id < rhs.id
            }
            return lhs.source.id < rhs.source.id
        }
    }

    func providerAvailabilityByID(from context: GoalUnderstandingKnowledgeContext?) -> [String: KnowledgeProviderAvailability] {
        Dictionary(
            uniqueKeysWithValues: (context?.providerStatuses ?? [])
                .sorted { $0.provider.id < $1.provider.id }
                .map { ($0.provider.id, $0.availability) }
        )
    }

    func impact(
        for resource: GoalResourceEntity,
        claimsByID: [String: KnowledgeClaim],
        sourcesByID: [String: GoalResourceSourceEntity],
        providerAvailability: [String: KnowledgeProviderAvailability],
        referenceDate: Date?
    ) -> GoalResourceFreshnessImpact {
        let relatedClaims = resource.claimIDs
            .compactMap { claimsByID[$0] }
            .sorted { $0.id < $1.id }
        let providerIDs = providerIDs(
            resource: resource,
            relatedClaims: relatedClaims,
            sourcesByID: sourcesByID
        )

        let evaluation: ResourceEvaluation
        if providerIDs.contains(where: { providerAvailability[$0].map { $0 != .available } ?? false }) {
            evaluation = ResourceEvaluation(
                posture: .providerUnavailable,
                severity: .blocked,
                flags: [.providerUnavailable],
                rankingImpactScore: -0.30,
                rankingFlags: [.providerUnavailable, .updateRequired],
                lineageReasons: [.providerUnavailable]
            )
        } else if resource.resolutionState == .placeholderOnly ||
            resource.resolutionState == .unresolved ||
            resource.missingResourceState != .none ||
            (resource.claimIDs.isEmpty && resource.sourceRecordIDs.isEmpty) {
            evaluation = ResourceEvaluation(
                posture: .blockedMissingEvidence,
                severity: .blocked,
                flags: [.missingFreshnessEvidence, .noConcreteResource],
                rankingImpactScore: -0.28,
                rankingFlags: [.missingFreshnessEvidence, .updateRequired],
                lineageReasons: [.missingFreshnessEvidence]
            )
        } else {
            evaluation = freshnessEvaluation(
                resource: resource,
                relatedClaims: relatedClaims,
                referenceDate: referenceDate
            )
        }

        let lineage = evaluation.lineageReasons.map { reason in
            GoalFreshnessLineageRef(
                providerID: providerIDs.first,
                sourceRecordID: resource.sourceRecordIDs.sorted().first ?? relatedClaims.first?.source.id,
                claimID: resource.claimIDs.sorted().first,
                resourceID: resource.id,
                candidateID: resource.candidateID,
                stageID: resource.targetStageID,
                reason: reason
            )
        }
        .sorted(by: lineageOrdering)

        return GoalResourceFreshnessImpact(
            resourceID: resource.id,
            posture: evaluation.posture,
            updateNeeded: evaluation.severity != .none,
            severity: evaluation.severity,
            flags: evaluation.flags.sorted { $0.rawValue < $1.rawValue },
            lineage: lineage,
            rankingImpactScore: evaluation.rankingImpactScore,
            rankingFlagsAdded: evaluation.rankingFlags.stableUniqueSorted()
        )
    }

    func providerIDs(
        resource: GoalResourceEntity,
        relatedClaims: [KnowledgeClaim],
        sourcesByID: [String: GoalResourceSourceEntity]
    ) -> [String] {
        let claimProviderIDs = relatedClaims.map(\.providerID)
        let sourceProviderIDs = resource.sourceRecordIDs.compactMap { sourcesByID[$0]?.providerID }
        return Array(Set(claimProviderIDs + sourceProviderIDs)).sorted()
    }

    func freshnessEvaluation(
        resource: GoalResourceEntity,
        relatedClaims: [KnowledgeClaim],
        referenceDate: Date?
    ) -> ResourceEvaluation {
        let freshnessValues = relatedClaims.isEmpty
            ? resource.freshnessState.map { [KnowledgeFreshnessMetadata(retrievedAt: "", publishedAt: nil, staleAfter: nil, expiresAt: nil, state: $0)] } ?? []
            : relatedClaims.map(\.freshness)
        let states = freshnessValues.map { evaluatedState(for: $0, referenceDate: referenceDate) }

        if states.contains(.expired) {
            return ResourceEvaluation(
                posture: .expired,
                severity: .required,
                flags: [.sourceExpired],
                rankingImpactScore: -0.22,
                rankingFlags: [.expiredSource, .updateRequired],
                lineageReasons: [.sourceExpired]
            )
        }
        if states.contains(.stale) {
            return ResourceEvaluation(
                posture: .stale,
                severity: .recommended,
                flags: [.sourceStale],
                rankingImpactScore: -0.12,
                rankingFlags: [.staleSource, .updateRecommended],
                lineageReasons: [.sourceStale]
            )
        }
        if states.contains(.unknown) || freshnessValues.isEmpty {
            return ResourceEvaluation(
                posture: .unknownFreshness,
                severity: .recommended,
                flags: [.unknownFreshness],
                rankingImpactScore: -0.10,
                rankingFlags: [.unknownFreshness, .updateRecommended],
                lineageReasons: [.unknownFreshness]
            )
        }
        if freshnessValues.contains(where: { isAging($0, referenceDate: referenceDate) }) {
            return ResourceEvaluation(
                posture: .aging,
                severity: .monitor,
                flags: [.sourceAging],
                rankingImpactScore: -0.04,
                rankingFlags: [.agingSource],
                lineageReasons: [.sourceAging]
            )
        }
        return ResourceEvaluation(
            posture: .currentEnough,
            severity: .none,
            flags: [],
            rankingImpactScore: 0,
            rankingFlags: [],
            lineageReasons: []
        )
    }

    func evaluatedState(
        for freshness: KnowledgeFreshnessMetadata,
        referenceDate: Date?
    ) -> KnowledgeFreshnessState {
        guard let referenceDate else {
            return freshness.state
        }
        if let expiresAt = freshness.expiresAt.flatMap(DomainTimestamp.date(from:)), expiresAt <= referenceDate {
            return .expired
        }
        if let staleAfter = freshness.staleAfter.flatMap(DomainTimestamp.date(from:)), staleAfter <= referenceDate {
            return .stale
        }
        return freshness.state
    }

    func isAging(
        _ freshness: KnowledgeFreshnessMetadata,
        referenceDate: Date?
    ) -> Bool {
        guard freshness.state == .fresh,
              let referenceDate,
              let staleAfter = freshness.staleAfter.flatMap(DomainTimestamp.date(from:)),
              staleAfter > referenceDate else {
            return false
        }
        return staleAfter.timeIntervalSince(referenceDate) <= agingLeadTime
    }

    func candidateSummary(
        candidate: GoalResourceGraphCandidate,
        impacts: [GoalResourceFreshnessImpact]
    ) -> GoalPathCandidateFreshnessSummary {
        let candidateImpacts = impacts
            .filter { candidate.resourceIDs.contains($0.resourceID) }
            .sorted { $0.resourceID < $1.resourceID }
        let affected = candidateImpacts.filter(\.updateNeeded)
        let maxSeverity = candidateImpacts
            .map(\.severity)
            .sortedBySeverityDescending()
            .first ?? .none

        return GoalPathCandidateFreshnessSummary(
            candidateID: candidate.candidateID,
            affectedResourceIDs: affected.map(\.resourceID),
            posture: posture(for: maxSeverity, impacts: candidateImpacts),
            updateNeeded: affected.isEmpty == false,
            severity: maxSeverity
        )
    }

    func posture(
        for severity: GoalUpdateNeededSeverity,
        impacts: [GoalResourceFreshnessImpact]
    ) -> GoalFreshnessPosture {
        let postures = impacts.map(\.posture)
        switch severity {
        case .blocked:
            return postures.contains(.providerUnavailable) ? .providerUnavailable : .blockedMissingEvidence
        case .required:
            return .expired
        case .recommended:
            return postures.contains(.stale) ? .stale : .unknownFreshness
        case .monitor:
            return .aging
        case .none:
            return .currentEnough
        }
    }

    func lineageOrdering(lhs: GoalFreshnessLineageRef, rhs: GoalFreshnessLineageRef) -> Bool {
        let left = [
            lhs.resourceID ?? "",
            lhs.claimID ?? "",
            lhs.sourceRecordID ?? "",
            lhs.providerID ?? "",
            lhs.reason.rawValue,
        ].joined(separator: "|")
        let right = [
            rhs.resourceID ?? "",
            rhs.claimID ?? "",
            rhs.sourceRecordID ?? "",
            rhs.providerID ?? "",
            rhs.reason.rawValue,
        ].joined(separator: "|")
        return left < right
    }
}

private extension GoalResourceEntity {
    func withAdditionalRankingFlags(_ additionalFlags: [GoalResourceRankingFlag]) -> GoalResourceEntity {
        GoalResourceEntity(
            id: id,
            candidateID: candidateID,
            targetStageID: targetStageID,
            hookID: hookID,
            selectionGroupID: selectionGroupID,
            hookKind: hookKind,
            resourceType: resourceType,
            resourceRole: resourceRole,
            resolutionState: resolutionState,
            originRelation: originRelation,
            optionality: optionality,
            relatedDomains: relatedDomains,
            appliedPackIDs: appliedPackIDs,
            claimIDs: claimIDs,
            sourceRecordIDs: sourceRecordIDs,
            trustLevel: trustLevel,
            freshnessState: freshnessState,
            uncertaintyFlags: uncertaintyFlags,
            missingResourceState: missingResourceState,
            ranking: GoalResourceRankingMetadata(
                rank: ranking.rank,
                totalScore: ranking.totalScore,
                sourceTrustScore: ranking.sourceTrustScore,
                sourceFreshnessScore: ranking.sourceFreshnessScore,
                domainRelevanceScore: ranking.domainRelevanceScore,
                stageRelevanceScore: ranking.stageRelevanceScore,
                readinessRelevanceScore: ranking.readinessRelevanceScore,
                optionalityScore: ranking.optionalityScore,
                tieBreakKey: ranking.tieBreakKey,
                flags: (ranking.flags + additionalFlags).stableUniqueSorted()
            )
        )
    }
}

private extension Array where Element == GoalResourceRankingFlag {
    func stableUniqueSorted() -> [GoalResourceRankingFlag] {
        Array(Set(self)).sorted { $0.rawValue < $1.rawValue }
    }
}
