import Foundation

enum SourceAtlasProjectionStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case available
    case localFallback = "local_fallback"
    case quarantined
    case unavailable
}

struct SourceAtlasProjectionRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let packID: String
    let status: SourceAtlasProjectionStatus
    let selectedSource: SourceAtlasStorePayloadSource?
    let fallbackReason: SourceAtlasQueryFallbackReason
    let freshnessStatus: FreshnessEngineStatus
    let proofEntryIDs: [String]
    let provenanceSourceIDs: [String]
    let blocksCurrentUse: Bool
}

struct SourceAtlasProjection: Sendable, Equatable, Hashable {
    func materialize(
        compilation: PublicPackRequestCompilation,
        cacheResolution: PublicPackCacheResolution?
    ) -> SourceAtlasProjectionRecord {
        let selectedResult = cacheResolution?.localResolution.queryResponse.selectedResult
        let selectedSource = cacheResolution?.localResolution.loadResult.selectedSource
        let packID = compilation.selectedEntry?.packID ?? compilation.packRequest?.packID ?? "source-atlas-pack"
        let status: SourceAtlasProjectionStatus

        if cacheResolution?.canSupportCurrentUse == true {
            status = .available
        } else if cacheResolution?.localResolution.cacheIssues.contains(.localFallbackUsed) == true ||
            cacheResolution?.localResolution.fallback.conditions.isEmpty == false {
            status = .localFallback
        } else if cacheResolution?.localResolution.loadResult.quarantines.isEmpty == false {
            status = .quarantined
        } else {
            status = .unavailable
        }

        return SourceAtlasProjectionRecord(
            id: "source-atlas.projection.\(packID).\(compilation.manifestRequest.channel)",
            packID: packID,
            status: status,
            selectedSource: selectedSource,
            fallbackReason: selectedResult?.fallbackReason ?? SourceAtlasQueryFallbackReason.none,
            freshnessStatus: cacheResolution?.freshness.status ?? .missing,
            proofEntryIDs: selectedResult?.proofEntryIDs ?? [],
            provenanceSourceIDs: selectedResult?.provenanceSourceIDs ?? [],
            blocksCurrentUse: cacheResolution?.canSupportCurrentUse == false || compilation.canFetchRemotePublicReference == false
        )
    }
}
