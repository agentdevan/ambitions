import Foundation

public enum SourceAtlasFreshnessBrokerClaimState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unknown
    case sourceNeeded = "source_needed"
    case stale
    case contradicted
    case revoked
    case locallyProven = "locally_proven"
}

public struct SourceAtlasFreshnessBrokerClaimStateBucket: Codable, Sendable, Equatable, Hashable {
    public let state: SourceAtlasFreshnessBrokerClaimState
    public let claimIDs: [String]

    public init(
        state: SourceAtlasFreshnessBrokerClaimState,
        claimIDs: [String] = []
    ) {
        self.state = state
        self.claimIDs = claimIDs
    }
}

public struct SourceAtlasFreshnessManifest: Codable, Sendable, Equatable, Hashable {
    public let schemaVersion: Int
    public let versionID: String
    public let publishedAt: Date
    public let packIndex: [SourceAtlasFreshnessPackEntry]
    public let globalClaimStateBuckets: [SourceAtlasFreshnessBrokerClaimStateBucket]
    
    public init(
        schemaVersion: Int,
        versionID: String,
        publishedAt: Date,
        packIndex: [SourceAtlasFreshnessPackEntry],
        globalClaimStateBuckets: [SourceAtlasFreshnessBrokerClaimStateBucket] = []
    ) {
        self.schemaVersion = schemaVersion
        self.versionID = versionID
        self.publishedAt = publishedAt
        self.packIndex = packIndex
        self.globalClaimStateBuckets = globalClaimStateBuckets
    }
}

public struct SourceAtlasFreshnessPackEntry: Codable, Sendable, Equatable, Hashable {
    public let packID: String
    public let currentSHA256: String
    public let currentSignature: String
    public let rollbackPointers: [String: String]
    public let changedClaimIDs: [String]
    public let claimStateBuckets: [SourceAtlasFreshnessBrokerClaimStateBucket]
    
    public init(
        packID: String,
        currentSHA256: String,
        currentSignature: String,
        rollbackPointers: [String: String] = [:],
        changedClaimIDs: [String] = [],
        claimStateBuckets: [SourceAtlasFreshnessBrokerClaimStateBucket] = []
    ) {
        self.packID = packID
        self.currentSHA256 = currentSHA256
        self.currentSignature = currentSignature
        self.rollbackPointers = rollbackPointers
        self.changedClaimIDs = changedClaimIDs
        self.claimStateBuckets = claimStateBuckets
    }
}

public struct SourceAtlasLocalUpdateReceipt: Codable, Sendable, Equatable, Hashable {
    public let manifestVersionID: String
    public let lastCheckedAt: Date
    public let packsUpdated: [String]
    public let offlineFallbackTriggered: Bool
    
    public init(
        manifestVersionID: String,
        lastCheckedAt: Date,
        packsUpdated: [String] = [],
        offlineFallbackTriggered: Bool = false
    ) {
        self.manifestVersionID = manifestVersionID
        self.lastCheckedAt = lastCheckedAt
        self.packsUpdated = packsUpdated
        self.offlineFallbackTriggered = offlineFallbackTriggered
    }
}
