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

    static func trimmed(_ value: String?) -> String? {
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
    let fallbackReason: SourceAtlasQueryFallbackReason?
    let sourceNeededDetail: SourceAtlasSourceNeededDetail?

    var canSupportCurrentUse: Bool {
        (fallbackReason == nil || fallbackReason == SourceAtlasQueryFallbackReason.none) &&
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
        selectedResult.fallbackReason ?? .none
    }
}

struct SourceAtlasOfflineFallbackRuntimeResult: Codable, Sendable, Equatable, Hashable {
    let availability: SourceAtlasOfflineFallbackAvailability
    let conditions: [SourceAtlasOfflineFallbackCondition]
    let hasLoadedPack: Bool
    let selectedStoreSource: SourceAtlasStorePayloadSource?
    let storeSourceState: SourceAtlasStoreSourceState
    let queryFallbackReason: SourceAtlasQueryFallbackReason
    let selectedSourceState: SourceAtlasRequirementSourceState
    let selectedFreshnessState: SourceAtlasRequirementFreshnessState
    let selectedReviewState: SourceAtlasRequirementReviewState
    let selectedProvenanceSourceIDs: [String]
    let blocksOfficialCurrentClaims: Bool
    let blocksCurrentUse: Bool

    init(
        loadResult: SourceAtlasStoreLoadResult,
        queryResponse: SourceAtlasQueryResponse,
        availability: SourceAtlasOfflineFallbackAvailability = SourceAtlasOfflineFallbackAvailability()
    ) {
        let conditions = Self.conditions(loadResult: loadResult, availability: availability)
        let selectedResult = queryResponse.selectedResult
        let selectedBlocksOfficialCurrent = selectedResult.sourceState != .officialCurrent ||
            selectedResult.freshnessState != .current ||
            selectedResult.reviewState != .approved ||
            selectedResult.provenanceSourceIDs.isEmpty
        let selectedBlocksCurrentUse = selectedResult.canSupportCurrentUse == false

        self.availability = availability
        self.conditions = conditions
        self.hasLoadedPack = loadResult.hasPack
        self.selectedStoreSource = loadResult.selectedSource
        self.storeSourceState = loadResult.sourceState
        self.queryFallbackReason = queryResponse.fallbackReason
        self.selectedSourceState = selectedResult.sourceState
        self.selectedFreshnessState = selectedResult.freshnessState
        self.selectedReviewState = selectedResult.reviewState
        self.selectedProvenanceSourceIDs = selectedResult.provenanceSourceIDs
        self.blocksOfficialCurrentClaims = conditions.isEmpty == false || selectedBlocksOfficialCurrent
        self.blocksCurrentUse = conditions.isEmpty == false || selectedBlocksCurrentUse
    }

    static func conditions(
        loadResult: SourceAtlasStoreLoadResult,
        availability: SourceAtlasOfflineFallbackAvailability
    ) -> [SourceAtlasOfflineFallbackCondition] {
        var conditions: [SourceAtlasOfflineFallbackCondition] = []

        if availability.internetAvailable == false {
            conditions.append(.noInternet)
        }
        if availability.manifestReachable == false {
            conditions.append(.unreachableManifest)
        }
        if availability.downloadSucceeded == false {
            conditions.append(.failedDownload)
        }
        if loadResult.selectedSource == .lastKnownGood || loadResult.sourceState == .stale {
            conditions.append(.staleCache)
        }
        if loadResult.hasPack == false {
            conditions.append(.missingPack)
        }
        if loadResult.quarantines.contains(where: \.isCorruptOrInvalidPack) {
            conditions.append(.corruptInvalidPack)
        }

        return orderedUniqueConditions(conditions)
    }

    static func orderedUniqueConditions(
        _ conditions: [SourceAtlasOfflineFallbackCondition]
    ) -> [SourceAtlasOfflineFallbackCondition] {
        var seen: Set<SourceAtlasOfflineFallbackCondition> = []
        return conditions.filter { seen.insert($0).inserted }
    }
}

extension SourceAtlasStoreQuarantine {
    var isCorruptOrInvalidPack: Bool {
        switch reason {
        case .corruptJSON, .unsupportedSchema, .hashMismatch, .invalidPack:
            return true
        case .missingPayload, .staleCritical, .contradicted, .revoked:
            return false
        }
    }
}
