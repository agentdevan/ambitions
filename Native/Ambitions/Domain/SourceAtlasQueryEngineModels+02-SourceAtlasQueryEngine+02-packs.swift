import Foundation

extension SourceAtlasQueryEngine {
    func query(_ query: SourceAtlasQuery) -> SourceAtlasQueryResponse {
        let candidates = rankedCandidates(matching: query)
        let selectedResult = candidates.first(where: \.canSupportCurrentUse)
            ?? candidates.first
            ?? Self.fallbackResult(
                for: query,
                reason: packs.isEmpty ? .noLoadedPacks : .noMatchingCandidate,
                sourceNeededDetail: sourceNeededDetail(
                    for: query,
                    reason: packs.isEmpty ? .noLoadedPacks : .noMatchingCandidate
                )
            )

        return SourceAtlasQueryResponse(
            query: query,
            results: candidates,
            selectedResult: selectedResult
        )
    }


    func results(matching query: SourceAtlasQuery) -> [SourceAtlasQueryResult] {
        self.query(query).results
    }


    func rankedCandidates(matching query: SourceAtlasQuery) -> [SourceAtlasQueryResult] {
        packs
            .flatMap { candidates(in: $0, matching: query) }
            .sorted { lhs, rhs in
                let lhsRank = rank(lhs, query: query)
                let rhsRank = rank(rhs, query: query)

                if lhsRank != rhsRank {
                    return lhsRank > rhsRank
                }
                return lhs.id < rhs.id
            }
    }


    func candidates(in pack: SourceAtlasPack, matching query: SourceAtlasQuery) -> [SourceAtlasQueryResult] {
        guard query.domainID == nil || query.domainID == pack.manifest.domainID else {
            return []
        }

        let claimsByID = Dictionary(uniqueKeysWithValues: pack.claims.map { ($0.id, $0) })
        let proofEntriesByRequirementID = Dictionary(grouping: pack.proofMap, by: \.requirementID)
        let matchingGoalIntents = goalIntents(in: pack, matching: query.goalIntent)
        guard query.goalIntent == nil || matchingGoalIntents.isEmpty == false else {
            return []
        }

        return pack.requirements.compactMap { requirement in
            guard query.requirementID == nil || query.requirementID == requirement.id else {
                return nil
            }
            guard query.claimID == nil || query.claimID == requirement.claimID else {
                return nil
            }

            let claim = claimsByID[requirement.claimID]
            guard query.riskClass == nil || query.riskClass == claim?.riskClass else {
                return nil
            }

            let proofEntries = proofEntriesByRequirementID[requirement.id] ?? []
            let provenanceSourceIDs = Self.orderedUnique(
                (claim?.sourceIDs ?? []) + proofEntries.flatMap(\.sourceRecordIDs)
            )
            guard query.sourceID == nil || provenanceSourceIDs.contains(query.sourceID ?? "") else {
                return nil
            }

            let sourceState = normalizedSourceState(
                requirement: requirement,
                claim: claim,
                pack: pack,
                provenanceSourceIDs: provenanceSourceIDs
            )
            let freshnessState = normalizedFreshnessState(requirement: requirement, claim: claim)
            let reviewState = normalizedReviewState(requirement: requirement, claim: claim)
            let riskState = normalizedRiskState(requirement: requirement, claim: claim)
            let fallbackReason = fallbackReason(
                sourceState: sourceState,
                freshnessState: freshnessState,
                riskState: riskState,
                reviewState: reviewState,
                provenanceSourceIDs: provenanceSourceIDs
            )

            guard query.sourceState == nil || query.sourceState == sourceState else {
                return nil
            }
            guard query.freshnessState == nil || query.freshnessState == freshnessState else {
                return nil
            }

            return SourceAtlasQueryResult(
                id: "\(pack.id)::\(requirement.id)",
                packID: pack.id,
                domainID: pack.manifest.domainID,
                goalIntent: matchingGoalIntents.first,
                claimID: claim?.id,
                requirementID: requirement.id,
                sourceState: sourceState,
                freshnessState: freshnessState,
                riskState: riskState,
                riskClass: claim?.riskClass,
                reviewState: reviewState,
                provenanceSourceIDs: provenanceSourceIDs,
                proofEntryIDs: proofEntries.map(\.id).sorted(),
                fallbackReason: fallbackReason,
                sourceNeededDetail: sourceNeededDetail(
                    in: pack,
                    for: query,
                    fallbackReason: fallbackReason
                )
            )
        }
    }


    func goalIntents(in pack: SourceAtlasPack, matching goalIntent: String?) -> [String] {
        let projectionIntents = pack.projections
            .filter { projection in
                projection.requiredPackIDs.contains(pack.id) ||
                    projection.requiredPackIDs.contains(pack.manifest.domainID) ||
                    projection.requiredPackIDs.isEmpty
            }
            .map(\.goalIntent)
            .filter { goalIntent == nil || $0 == goalIntent }

        if goalIntent != nil && projectionIntents.isEmpty {
            return []
        }
        return Self.orderedUnique(projectionIntents)
    }


    func normalizedSourceState(
        requirement: SourceAtlasRequirement,
        claim: SourceAtlasClaim?,
        pack: SourceAtlasPack,
        provenanceSourceIDs: [String]
    ) -> SourceAtlasRequirementSourceState {
        guard let claim else {
            return .unknown
        }

        switch claim.state {
        case .unknown, .unsupported:
            return .unknown
        case .sourceNeeded, .inferred, .ocrDerived, .privateClaim:
            return .sourceNeeded
        case .stale, .staleCritical, .sourceChanged:
            return .stale
        case .contradicted, .disputed:
            return .contradicted
        case .revoked:
            return .revoked
        case .verifiedByLocalProof:
            return .locallyProven
        case .official:
            return canSupportOfficialCurrent(
                requirement: requirement,
                claim: claim,
                pack: pack,
                provenanceSourceIDs: provenanceSourceIDs
            ) ? .officialCurrent : .official
        case .semiOfficial, .expert, .community, .maintainerCurated, .sourced, .userProvided, .userConfirmed, .imported:
            return provenanceSourceIDs.isEmpty ? .sourceNeeded : requirement.sourceState
        }
    }


    func normalizedFreshnessState(
        requirement: SourceAtlasRequirement,
        claim: SourceAtlasClaim?
    ) -> SourceAtlasRequirementFreshnessState {
        guard let claim else {
            return .unknown
        }

        switch claim.freshness {
        case .current:
            return requirement.freshnessState == .current ? .current : requirement.freshnessState
        case .aging, .needsReview, .unknown, .userProvided:
            return .unknown
        case .stale, .staleCritical, .sourceChanged, .disputed, .revoked:
            return .stale
        }
    }


    func normalizedReviewState(
        requirement: SourceAtlasRequirement,
        claim: SourceAtlasClaim?
    ) -> SourceAtlasRequirementReviewState {
        guard let claim else {
            return .required
        }
        return claim.reviewRequired ? .required : requirement.reviewState
    }


    func normalizedRiskState(
        requirement: SourceAtlasRequirement,
        claim: SourceAtlasClaim?
    ) -> SourceAtlasRequirementRiskState {
        guard let claim else {
            return .unknown
        }
        if claim.riskClass.requiresStrictReview && claim.reviewRequired {
            return .high
        }
        return requirement.riskState
    }


    func canSupportOfficialCurrent(
        requirement: SourceAtlasRequirement,
        claim: SourceAtlasClaim,
        pack: SourceAtlasPack,
        provenanceSourceIDs: [String]
    ) -> Bool {
        let approvedSourceIDs = Set(
            pack.sources
                .filter { $0.kind == .official && $0.approvedForOfficialClaims }
                .map(\.id)
        )

        return provenanceSourceIDs.isEmpty == false &&
            Set(provenanceSourceIDs).isDisjoint(with: approvedSourceIDs) == false &&
            claim.freshness == .current &&
            claim.reviewRequired == false &&
            requirement.freshnessState == .current &&
            requirement.reviewState == .approved
    }


    func fallbackReason(
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        riskState: SourceAtlasRequirementRiskState,
        reviewState: SourceAtlasRequirementReviewState,
        provenanceSourceIDs: [String]
    ) -> SourceAtlasQueryFallbackReason? {
        switch sourceState {
        case .sourceNeeded:
            return .sourceNeeded
        case .stale:
            return .stale
        case .contradicted:
            return .contradicted
        case .revoked:
            return .revoked
        case .unknown:
            return .unknown
        case .official:
            return provenanceSourceIDs.isEmpty ? .provenanceMissing : .noCurrentCandidate
        case .officialCurrent, .current, .locallyProven:
            break
        }

        if freshnessState == .stale {
            return .stale
        }
        if freshnessState == .unknown {
            return .unknown
        }
        if reviewState.blocksCurrentProjection {
            return .reviewRequired
        }
        if riskState.blocksCurrentProjection {
            return .reviewRequired
        }
        if provenanceSourceIDs.isEmpty {
            return .provenanceMissing
        }
        return nil
    }
}
