import Foundation

public struct SourceAtlasFreshnessManifest: Codable, Sendable, Equatable, Hashable {
    public let schemaVersion: Int
    public let versionID: String
    public let publishedAt: Date
    public let packIndex: [SourceAtlasFreshnessPackEntry]
    public let globalRevocationList: [String]
    public let globalStaleClaims: [String]
    
    public init(
        schemaVersion: Int,
        versionID: String,
        publishedAt: Date,
        packIndex: [SourceAtlasFreshnessPackEntry],
        globalRevocationList: [String] = [],
        globalStaleClaims: [String] = []
    ) {
        self.schemaVersion = schemaVersion
        self.versionID = versionID
        self.publishedAt = publishedAt
        self.packIndex = packIndex
        self.globalRevocationList = globalRevocationList
        self.globalStaleClaims = globalStaleClaims
    }
}

public struct SourceAtlasFreshnessPackEntry: Codable, Sendable, Equatable, Hashable {
    public let packID: String
    public let currentSHA256: String
    public let currentSignature: String
    public let rollbackPointers: [String: String]
    public let changedClaimIDs: [String]
    public let staleClaimIDs: [String]
    public let revokedClaimIDs: [String]
    
    public init(
        packID: String,
        currentSHA256: String,
        currentSignature: String,
        rollbackPointers: [String: String] = [:],
        changedClaimIDs: [String] = [],
        staleClaimIDs: [String] = [],
        revokedClaimIDs: [String] = []
    ) {
        self.packID = packID
        self.currentSHA256 = currentSHA256
        self.currentSignature = currentSignature
        self.rollbackPointers = rollbackPointers
        self.changedClaimIDs = changedClaimIDs
        self.staleClaimIDs = staleClaimIDs
        self.revokedClaimIDs = revokedClaimIDs
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
