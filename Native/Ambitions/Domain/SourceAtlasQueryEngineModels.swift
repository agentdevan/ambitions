import Foundation

struct SourceAtlasQuery: Codable, Sendable, Equatable, Hashable {
    let goalIntent: String?
    let domainID: String?
    let claimID: String?
    let requirementID: String?
    let sourceState: SourceAtlasRequirementSourceState?
    let freshnessState: SourceAtlasRequirementFreshnessState?
    let riskClass: SourceAtlasRiskClass?
    let sourceID: String?

    init(
        goalIntent: String? = nil,
        domainID: String? = nil,
        claimID: String? = nil,
        requirementID: String? = nil,
        sourceState: SourceAtlasRequirementSourceState? = nil,
        freshnessState: SourceAtlasRequirementFreshnessState? = nil,
        riskClass: SourceAtlasRiskClass? = nil,
        sourceID: String? = nil
    ) {
        self.goalIntent = Self.trimmed(goalIntent)
        self.domainID = Self.trimmed(domainID)
        self.claimID = Self.trimmed(claimID)
        self.requirementID = Self.trimmed(requirementID)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.riskClass = riskClass
        self.sourceID = Self.trimmed(sourceID)
    }

    private static func trimmed(_ value: String?) -> String? {
        guard let value else {
            return nil
        }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}

enum SourceAtlasQueryFallbackReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case sourceNeeded = "source_needed"
    case stale
    case contradicted
    case revoked
    case unknown
    case reviewRequired = "review_required"
    case provenanceMissing = "provenance_missing"
    case noLoadedPacks = "no_loaded_packs"
    case noMatchingCandidate = "no_matching_candidate"
    case noCurrentCandidate = "no_current_candidate"
}

enum SourceAtlasSourceNeededMode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case noLoadedPacks = "no_loaded_packs"
    case noMatchingCandidate = "no_matching_candidate"
    case noCurrentCandidate = "no_current_candidate"
    case provenanceMissing = "provenance_missing"
    case starterGuidanceOnly = "starter_guidance_only"
}

struct SourceAtlasSourceNeededStarterGuidance: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let packID: String
    let domainID: String
    let starterItemID: String
    let title: String
    let stepCandidateSeed: String
    let storesFinalSchedule: Bool
    let canSupportOfficialCurrentUse: Bool
}

struct SourceAtlasSourceNeededDetail: Codable, Sendable, Equatable, Hashable {
    let mode: SourceAtlasSourceNeededMode
    let fallbackReason: SourceAtlasQueryFallbackReason
    let starterGuidance: [SourceAtlasSourceNeededStarterGuidance]
    let blocksOfficialCurrentClaims: Bool
    let blocksCurrentUse: Bool
}

struct SourceAtlasQueryResult: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let packID: String
    let domainID: String
    let goalIntent: String?
    let claimID: String?
    let requirementID: String?
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let riskState: SourceAtlasRequirementRiskState
    let riskClass: SourceAtlasRiskClass?
    let reviewState: SourceAtlasRequirementReviewState
    let provenanceSourceIDs: [String]
    let proofEntryIDs: [String]
    let fallbackReason: SourceAtlasQueryFallbackReason
    let sourceNeededDetail: SourceAtlasSourceNeededDetail?

    var canSupportCurrentUse: Bool {
        fallbackReason == .none &&
            sourceState.blocksCurrentProjection == false &&
            freshnessState.blocksCurrentProjection == false &&
            riskState.blocksCurrentProjection == false &&
            reviewState.blocksCurrentProjection == false &&
            provenanceSourceIDs.isEmpty == false
    }
}

struct SourceAtlasQueryResponse: Codable, Sendable, Equatable, Hashable {
    let query: SourceAtlasQuery
    let results: [SourceAtlasQueryResult]
    let selectedResult: SourceAtlasQueryResult

    var fallbackReason: SourceAtlasQueryFallbackReason {
        selectedResult.fallbackReason
    }
}

struct SourceAtlasQueryEngine: Sendable, Equatable, Hashable {
    let packs: [SourceAtlasPack]

    init(packs: [SourceAtlasPack]) {
        self.packs = packs
    }

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

    private func rankedCandidates(matching query: SourceAtlasQuery) -> [SourceAtlasQueryResult] {
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

    private func candidates(in pack: SourceAtlasPack, matching query: SourceAtlasQuery) -> [SourceAtlasQueryResult] {
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

    private func goalIntents(in pack: SourceAtlasPack, matching goalIntent: String?) -> [String] {
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

    private func normalizedSourceState(
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

    private func normalizedFreshnessState(
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

    private func normalizedReviewState(
        requirement: SourceAtlasRequirement,
        claim: SourceAtlasClaim?
    ) -> SourceAtlasRequirementReviewState {
        guard let claim else {
            return .required
        }
        return claim.reviewRequired ? .required : requirement.reviewState
    }

    private func normalizedRiskState(
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

    private func canSupportOfficialCurrent(
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

    private func fallbackReason(
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        riskState: SourceAtlasRequirementRiskState,
        reviewState: SourceAtlasRequirementReviewState,
        provenanceSourceIDs: [String]
    ) -> SourceAtlasQueryFallbackReason {
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
        return .none
    }

    private func rank(_ result: SourceAtlasQueryResult, query: SourceAtlasQuery) -> Int {
        var rank = 0

        if result.canSupportCurrentUse {
            rank += 1_000
        }
        if query.goalIntent != nil && query.goalIntent == result.goalIntent {
            rank += 100
        }
        if query.domainID != nil && query.domainID == result.domainID {
            rank += 80
        }
        if query.claimID != nil && query.claimID == result.claimID {
            rank += 60
        }
        if query.requirementID != nil && query.requirementID == result.requirementID {
            rank += 60
        }
        if query.sourceID != nil && result.provenanceSourceIDs.contains(query.sourceID ?? "") {
            rank += 40
        }

        switch result.sourceState {
        case .officialCurrent:
            rank += 30
        case .current, .official, .locallyProven:
            rank += 20
        case .sourceNeeded:
            rank += 5
        case .unknown, .stale, .contradicted, .revoked:
            rank += 0
        }

        return rank
    }

    private static func fallbackResult(
        for query: SourceAtlasQuery,
        reason: SourceAtlasQueryFallbackReason,
        sourceNeededDetail: SourceAtlasSourceNeededDetail?
    ) -> SourceAtlasQueryResult {
        SourceAtlasQueryResult(
            id: "source-atlas-query-fallback",
            packID: query.domainID ?? "unknown-pack",
            domainID: query.domainID ?? "unknown-domain",
            goalIntent: query.goalIntent,
            claimID: query.claimID,
            requirementID: query.requirementID,
            sourceState: .sourceNeeded,
            freshnessState: .unknown,
            riskState: .unknown,
            riskClass: query.riskClass,
            reviewState: .required,
            provenanceSourceIDs: [],
            proofEntryIDs: [],
            fallbackReason: reason == .noLoadedPacks ? .noLoadedPacks : .sourceNeeded,
            sourceNeededDetail: sourceNeededDetail
        )
    }

    private func sourceNeededDetail(
        in pack: SourceAtlasPack,
        for query: SourceAtlasQuery,
        fallbackReason: SourceAtlasQueryFallbackReason
    ) -> SourceAtlasSourceNeededDetail? {
        guard fallbackReason != .none else {
            return nil
        }

        switch fallbackReason {
        case .sourceNeeded, .provenanceMissing, .noCurrentCandidate:
            return SourceAtlasSourceNeededDetail(
                mode: sourceNeededMode(for: fallbackReason, hasStarterGuidance: pack.starterItems.isEmpty == false),
                fallbackReason: fallbackReason,
                starterGuidance: starterGuidance(in: pack, matching: query),
                blocksOfficialCurrentClaims: true,
                blocksCurrentUse: true
            )
        case .none, .unknown, .stale, .contradicted, .revoked, .reviewRequired, .noLoadedPacks, .noMatchingCandidate:
            return nil
        }
    }

    private func sourceNeededDetail(
        for query: SourceAtlasQuery,
        reason: SourceAtlasQueryFallbackReason
    ) -> SourceAtlasSourceNeededDetail {
        let guidance = packs
            .filter { query.domainID == nil || $0.manifest.domainID == query.domainID }
            .flatMap { starterGuidance(in: $0, matching: query) }

        return SourceAtlasSourceNeededDetail(
            mode: sourceNeededMode(for: reason, hasStarterGuidance: guidance.isEmpty == false),
            fallbackReason: reason == .noLoadedPacks ? .noLoadedPacks : .sourceNeeded,
            starterGuidance: guidance,
            blocksOfficialCurrentClaims: true,
            blocksCurrentUse: true
        )
    }

    private func sourceNeededMode(
        for reason: SourceAtlasQueryFallbackReason,
        hasStarterGuidance: Bool
    ) -> SourceAtlasSourceNeededMode {
        if hasStarterGuidance {
            return .starterGuidanceOnly
        }

        switch reason {
        case .noLoadedPacks:
            return .noLoadedPacks
        case .noMatchingCandidate, .sourceNeeded:
            return .noMatchingCandidate
        case .provenanceMissing:
            return .provenanceMissing
        case .noCurrentCandidate:
            return .noCurrentCandidate
        case .none, .unknown, .stale, .contradicted, .revoked, .reviewRequired:
            return .noCurrentCandidate
        }
    }

    private func starterGuidance(
        in pack: SourceAtlasPack,
        matching query: SourceAtlasQuery
    ) -> [SourceAtlasSourceNeededStarterGuidance] {
        guard query.domainID == nil || query.domainID == pack.manifest.domainID else {
            return []
        }

        return pack.starterItems.map { starterItem in
            SourceAtlasSourceNeededStarterGuidance(
                id: "\(pack.id)::\(starterItem.id)",
                packID: pack.id,
                domainID: pack.manifest.domainID,
                starterItemID: starterItem.id,
                title: starterItem.title,
                stepCandidateSeed: starterItem.stepCandidateSeed,
                storesFinalSchedule: starterItem.storesFinalSchedule,
                canSupportOfficialCurrentUse: false
            )
        }
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}
