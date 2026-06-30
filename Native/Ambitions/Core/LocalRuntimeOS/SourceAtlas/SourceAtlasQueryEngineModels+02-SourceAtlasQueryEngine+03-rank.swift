import Foundation

extension SourceAtlasQueryEngine {

    func rank(_ result: SourceAtlasQueryResult, query: SourceAtlasQuery) -> Int {
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


    static func fallbackResult(
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


    func sourceNeededDetail(
        in pack: SourceAtlasPack,
        for query: SourceAtlasQuery,
        fallbackReason: SourceAtlasQueryFallbackReason?
    ) -> SourceAtlasSourceNeededDetail? {
        guard let fallbackReason else {
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


    func sourceNeededDetail(
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


    func sourceNeededMode(
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


    func starterGuidance(
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


    static func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}
