import Foundation

enum SourceAtlasPublicPackRequestIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingPackID = "missing_pack_id"
    case missingManifestVersion = "missing_manifest_version"
    case invalidDeclaredHash = "invalid_declared_hash"
    case privatePlanningParameter = "private_planning_parameter"
    case secretParameter = "secret_parameter"
    case privateLocator = "private_locator"
}

struct SourceAtlasPublicPackRequest: Codable, Sendable, Equatable, Hashable {
    let packID: String
    let manifestVersionID: String
    let declaredSHA256: String
    let routePath: String
    let queryItems: [String: String]
    let channel: String?
    let artifactVersionID: String?
    let sourceState: SourceAtlasRequirementSourceState?
    let freshnessState: SourceAtlasRequirementFreshnessState?
    let publicJurisdiction: String?
    let publicLocale: String?

    init(
        packID: String,
        manifestVersionID: String,
        declaredSHA256: String,
        routePath: String = "/source-atlas/public/packs",
        queryItems: [String: String] = [:],
        channel: String? = nil,
        artifactVersionID: String? = nil,
        sourceState: SourceAtlasRequirementSourceState? = nil,
        freshnessState: SourceAtlasRequirementFreshnessState? = nil,
        publicJurisdiction: String? = nil,
        publicLocale: String? = nil
    ) {
        self.packID = packID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.manifestVersionID = manifestVersionID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.declaredSHA256 = declaredSHA256.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.routePath = routePath.trimmingCharacters(in: .whitespacesAndNewlines)
        self.channel = Self.trimmed(channel)
        self.artifactVersionID = Self.trimmed(artifactVersionID)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.publicJurisdiction = Self.trimmed(publicJurisdiction)
        self.publicLocale = Self.trimmed(publicLocale)
        self.queryItems = Dictionary(
            uniqueKeysWithValues: queryItems.map { key, value in
                (
                    key.trimmingCharacters(in: .whitespacesAndNewlines),
                    value.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
        )
    }

    var validationIssues: [SourceAtlasPublicPackRequestIssue] {
        SourceAtlasPublicPackRequestValidator().validate(self)
    }

    var isPrivacySafe: Bool {
        validationIssues.isEmpty
    }

    static func publicPack(
        manifestVersionID: String,
        entry: SourceAtlasFreshnessPackEntry,
        routePath: String = "/source-atlas/public/packs"
    ) -> SourceAtlasPublicPackRequest {
        SourceAtlasPublicPackRequest(
            packID: entry.packID,
            manifestVersionID: manifestVersionID,
            declaredSHA256: entry.currentSHA256,
            routePath: routePath,
            queryItems: [
                "pack_id": entry.packID,
                "manifest_version": manifestVersionID,
                "sha256": entry.currentSHA256
            ]
        )
    }

    static func runtimeArtifact(
        manifestVersionID: String,
        entry: SourceAtlasFreshnessPackEntry,
        channel: String,
        artifactVersionID: String,
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        publicJurisdiction: String? = nil,
        publicLocale: String? = nil
    ) -> SourceAtlasPublicPackRequest {
        SourceAtlasPublicPackRequest(
            packID: entry.packID,
            manifestVersionID: manifestVersionID,
            declaredSHA256: entry.currentSHA256,
            queryItems: [
                "artifact_id": entry.packID,
                "artifact_version": artifactVersionID,
                "channel": channel,
                "freshness_state": freshnessState.rawValue,
                "manifest_version": manifestVersionID,
                "pack_id": entry.packID,
                "sha256": entry.currentSHA256,
                "source_state": sourceState.rawValue
            ],
            channel: channel,
            artifactVersionID: artifactVersionID,
            sourceState: sourceState,
            freshnessState: freshnessState,
            publicJurisdiction: publicJurisdiction,
            publicLocale: publicLocale
        )
    }

    private static func trimmed(_ value: String?) -> String? {
        guard let value else {
            return nil
        }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

enum SourceAtlasLocalPackCacheIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsafePublicRequest = "unsafe_public_request"
    case missingManifestEntry = "missing_manifest_entry"
    case manifestVersionMismatch = "manifest_version_mismatch"
    case manifestHashMismatch = "manifest_hash_mismatch"
    case staleManifest = "stale_manifest"
    case staleCriticalByManifest = "stale_critical_by_manifest"
    case revokedByManifest = "revoked_by_manifest"
    case contradictedByManifest = "contradicted_by_manifest"
    case accessBoundaryUnavailable = "access_boundary_unavailable"
    case noEligiblePack = "no_eligible_pack"
    case localFallbackUsed = "local_fallback_used"
}

struct SourceAtlasLocalPackCachePolicy: Codable, Sendable, Equatable, Hashable {
    let maximumManifestAgeDays: Int
    let allowLastKnownGoodRollback: Bool

    init(
        maximumManifestAgeDays: Int = 30,
        allowLastKnownGoodRollback: Bool = true
    ) {
        self.maximumManifestAgeDays = maximumManifestAgeDays
        self.allowLastKnownGoodRollback = allowLastKnownGoodRollback
    }
}

struct SourceAtlasLocalPackCacheInput: Sendable, Equatable, Hashable {
    let manifest: SourceAtlasFreshnessManifest
    let request: SourceAtlasPublicPackRequest
    let cachedPayload: SourceAtlasStorePayload?
    let bundledPayload: SourceAtlasStorePayload?
    let lastKnownGoodPayload: SourceAtlasStorePayload?
    let query: SourceAtlasQuery
    let checkedAt: Date
    let policy: SourceAtlasLocalPackCachePolicy
    let accessDecision: SourceAtlasAccessDecision?

    init(
        manifest: SourceAtlasFreshnessManifest,
        request: SourceAtlasPublicPackRequest,
        cachedPayload: SourceAtlasStorePayload? = nil,
        bundledPayload: SourceAtlasStorePayload? = nil,
        lastKnownGoodPayload: SourceAtlasStorePayload? = nil,
        query: SourceAtlasQuery = SourceAtlasQuery(),
        checkedAt: Date,
        policy: SourceAtlasLocalPackCachePolicy = SourceAtlasLocalPackCachePolicy(),
        accessDecision: SourceAtlasAccessDecision? = nil
    ) {
        self.manifest = manifest
        self.request = request
        self.cachedPayload = cachedPayload
        self.bundledPayload = bundledPayload
        self.lastKnownGoodPayload = lastKnownGoodPayload
        self.query = query
        self.checkedAt = checkedAt
        self.policy = policy
        self.accessDecision = accessDecision
    }
}

struct SourceAtlasLocalPackCacheFallback: Codable, Sendable, Equatable, Hashable {
    let conditions: [SourceAtlasOfflineFallbackCondition]
    let queryFallbackReason: SourceAtlasQueryFallbackReason
    let selectedSourceState: SourceAtlasRequirementSourceState
    let selectedFreshnessState: SourceAtlasRequirementFreshnessState
    let selectedReviewState: SourceAtlasRequirementReviewState
    let blocksCurrentUse: Bool
}

struct SourceAtlasLocalPackCacheUpdateRecord: Codable, Sendable, Equatable, Hashable {
    let manifestVersionID: String
    let checkedAt: Date
    let selectedPackIDs: [String]
    let fallbackTriggered: Bool
    let quarantinedSourceCount: Int
}

struct SourceAtlasLocalPackCacheResolution: Sendable, Equatable, Hashable {
    let requestIssues: [SourceAtlasPublicPackRequestIssue]
    let cacheIssues: [SourceAtlasLocalPackCacheIssue]
    let loadResult: SourceAtlasStoreLoadResult
    let queryResponse: SourceAtlasQueryResponse
    let fallback: SourceAtlasLocalPackCacheFallback
    let updateRecord: SourceAtlasLocalPackCacheUpdateRecord

    var selectedPack: SourceAtlasPack? {
        loadResult.pack
    }

    var canSupportCurrentUse: Bool {
        requestIssues.isEmpty &&
            cacheIssues.contains(.staleManifest) == false &&
            cacheIssues.contains(.staleCriticalByManifest) == false &&
            cacheIssues.contains(.revokedByManifest) == false &&
            cacheIssues.contains(.contradictedByManifest) == false &&
            cacheIssues.contains(.accessBoundaryUnavailable) == false &&
            cacheIssues.contains(.noEligiblePack) == false &&
            cacheIssues.contains(.localFallbackUsed) == false &&
            fallback.blocksCurrentUse == false &&
            queryResponse.selectedResult.canSupportCurrentUse
    }
}

struct SourceAtlasLocalPackCache: Sendable {
    private let store: SourceAtlasStore

    init(store: SourceAtlasStore = SourceAtlasStore()) {
        self.store = store
    }

    func resolve(_ input: SourceAtlasLocalPackCacheInput) -> SourceAtlasLocalPackCacheResolution {
        let requestIssues = SourceAtlasPublicPackRequestValidator().validate(input.request)
        let manifestEntry = input.manifest.packIndex.first { $0.packID == input.request.packID }
        var cacheIssues: [SourceAtlasLocalPackCacheIssue] = []
        var additionalQuarantines: [SourceAtlasStoreQuarantine] = []

        if requestIssues.isEmpty == false {
            cacheIssues.append(.unsafePublicRequest)
        }
        if input.manifest.versionID != input.request.manifestVersionID {
            cacheIssues.append(.manifestVersionMismatch)
        }
        if manifestEntry == nil {
            cacheIssues.append(.missingManifestEntry)
        }
        if let manifestEntry, normalizedHash(input.request.declaredSHA256) != normalizedHash(manifestEntry.currentSHA256) {
            cacheIssues.append(.manifestHashMismatch)
        }
        if manifestIsStale(input.manifest, checkedAt: input.checkedAt, policy: input.policy) {
            cacheIssues.append(.staleManifest)
        }

        if manifestBlocksUse(input.manifest, entry: manifestEntry, blockedState: .stale) {
            cacheIssues.append(.staleCriticalByManifest)
            additionalQuarantines.append(contentsOf: manifestBlockQuarantines(input, reason: .staleCritical))
        }
        if manifestBlocksUse(input.manifest, entry: manifestEntry, blockedState: .revoked) {
            cacheIssues.append(.revokedByManifest)
            additionalQuarantines.append(contentsOf: manifestBlockQuarantines(input, reason: .revoked))
        }
        if manifestBlocksUse(input.manifest, entry: manifestEntry, blockedState: .contradicted) {
            cacheIssues.append(.contradictedByManifest)
            additionalQuarantines.append(contentsOf: manifestBlockQuarantines(input, reason: .contradicted))
        }
        if input.accessDecision?.route == .unavailable {
            cacheIssues.append(.accessBoundaryUnavailable)
        }

        let canAttemptLoad = requestIssues.isEmpty &&
            manifestEntry != nil &&
            cacheIssues.contains(.manifestVersionMismatch) == false &&
            cacheIssues.contains(.manifestHashMismatch) == false &&
            cacheIssues.contains(.staleCriticalByManifest) == false &&
            cacheIssues.contains(.revokedByManifest) == false &&
            cacheIssues.contains(.contradictedByManifest) == false &&
            cacheIssues.contains(.accessBoundaryUnavailable) == false

        let selectedPayloads = canAttemptLoad
            ? manifestFilteredPayloads(
                input: input,
                entry: manifestEntry,
                additionalQuarantines: &additionalQuarantines
            )
            : (cached: nil, bundled: nil, lastKnownGood: nil)

        let storeResult = store.load(
            bundled: selectedPayloads.bundled,
            cached: selectedPayloads.cached,
            lastKnownGood: selectedPayloads.lastKnownGood
        )
        let mergedLoadResult = SourceAtlasStoreLoadResult(
            pack: storeResult.pack,
            selectedSource: storeResult.selectedSource,
            sourceState: storeResult.sourceState,
            quarantines: orderedQuarantines(additionalQuarantines + storeResult.quarantines)
        )
        if mergedLoadResult.hasPack == false && additionalQuarantines.contains(where: { $0.reason == .hashMismatch }) {
            cacheIssues.append(.manifestHashMismatch)
        }
        let packs = mergedLoadResult.pack.map { [$0] } ?? []
        let queryResponse = SourceAtlasQueryEngine(packs: packs).query(input.query)
        let fallback = SourceAtlasLocalPackCacheFallback(
            conditions: fallbackConditions(loadResult: mergedLoadResult),
            queryFallbackReason: queryResponse.fallbackReason,
            selectedSourceState: queryResponse.selectedResult.sourceState,
            selectedFreshnessState: queryResponse.selectedResult.freshnessState,
            selectedReviewState: queryResponse.selectedResult.reviewState,
            blocksCurrentUse: mergedLoadResult.hasPack == false ||
                mergedLoadResult.sourceState == .stale ||
                queryResponse.selectedResult.canSupportCurrentUse == false
        )

        if mergedLoadResult.hasPack == false {
            cacheIssues.append(.noEligiblePack)
        }
        if fallback.blocksCurrentUse {
            cacheIssues.append(.localFallbackUsed)
        }

        return SourceAtlasLocalPackCacheResolution(
            requestIssues: requestIssues,
            cacheIssues: orderedIssues(cacheIssues),
            loadResult: mergedLoadResult,
            queryResponse: queryResponse,
            fallback: fallback,
            updateRecord: SourceAtlasLocalPackCacheUpdateRecord(
                manifestVersionID: input.manifest.versionID,
                checkedAt: input.checkedAt,
                selectedPackIDs: mergedLoadResult.pack.map { [$0.id] } ?? [],
                fallbackTriggered: fallback.blocksCurrentUse,
                quarantinedSourceCount: mergedLoadResult.quarantines.count
            )
        )
    }
}

private extension SourceAtlasLocalPackCache {
    func manifestFilteredPayloads(
        input: SourceAtlasLocalPackCacheInput,
        entry: SourceAtlasFreshnessPackEntry?,
        additionalQuarantines: inout [SourceAtlasStoreQuarantine]
    ) -> (
        cached: SourceAtlasStorePayload?,
        bundled: SourceAtlasStorePayload?,
        lastKnownGood: SourceAtlasStorePayload?
    ) {
        guard let entry else {
            return (nil, nil, nil)
        }
        let currentHash = normalizedHash(entry.currentSHA256)
        let rollbackHashes = Set(entry.rollbackPointers.values.map(normalizedHash(_:)))
        let accessRoute = input.accessDecision?.route

        return (
            cached: accessRoute == nil || accessRoute == .remotePublicReference || accessRoute == .cachedPublic
                ? payload(
                    input.cachedPayload,
                    expectedHash: currentHash,
                    source: .cached,
                    additionalQuarantines: &additionalQuarantines
                )
                : nil,
            bundled: accessRoute == nil || accessRoute == .remotePublicReference || accessRoute == .bundledLocal
                ? payload(
                    input.bundledPayload,
                    expectedHash: currentHash,
                    source: .bundled,
                    additionalQuarantines: &additionalQuarantines
                )
                : nil,
            lastKnownGood: input.policy.allowLastKnownGoodRollback
                && (accessRoute == nil || accessRoute == .remotePublicReference || accessRoute == .lastKnownGood)
                ? rollbackPayload(
                    input.lastKnownGoodPayload,
                    rollbackHashes: rollbackHashes,
                    additionalQuarantines: &additionalQuarantines
                )
                : nil
        )
    }

    func payload(
        _ candidate: SourceAtlasStorePayload?,
        expectedHash: String,
        source: SourceAtlasStorePayloadSource,
        additionalQuarantines: inout [SourceAtlasStoreQuarantine]
    ) -> SourceAtlasStorePayload? {
        guard let candidate else {
            return nil
        }
        guard normalizedHash(candidate.declaredSHA256) == expectedHash else {
            additionalQuarantines.append(SourceAtlasStoreQuarantine(source: source, reason: .hashMismatch))
            return nil
        }
        return candidate
    }

    func rollbackPayload(
        _ candidate: SourceAtlasStorePayload?,
        rollbackHashes: Set<String>,
        additionalQuarantines: inout [SourceAtlasStoreQuarantine]
    ) -> SourceAtlasStorePayload? {
        guard let candidate else {
            return nil
        }
        guard rollbackHashes.contains(normalizedHash(candidate.declaredSHA256)) else {
            additionalQuarantines.append(SourceAtlasStoreQuarantine(source: .lastKnownGood, reason: .hashMismatch))
            return nil
        }
        return candidate
    }

    func manifestBlocksUse(
        _ manifest: SourceAtlasFreshnessManifest,
        entry: SourceAtlasFreshnessPackEntry?,
        blockedState: SourceAtlasFreshnessBrokerClaimState
    ) -> Bool {
        let entryBuckets = entry?.claimStateBuckets ?? []
        return (manifest.globalClaimStateBuckets + entryBuckets).contains { bucket in
            bucket.state == blockedState && bucket.claimIDs.isEmpty == false
        }
    }

    func manifestBlockQuarantines(
        _ input: SourceAtlasLocalPackCacheInput,
        reason: SourceAtlasStoreQuarantineReason
    ) -> [SourceAtlasStoreQuarantine] {
        [
            input.cachedPayload.map { _ in SourceAtlasStoreQuarantine(source: .cached, reason: reason) },
            input.bundledPayload.map { _ in SourceAtlasStoreQuarantine(source: .bundled, reason: reason) },
            input.lastKnownGoodPayload.map { _ in SourceAtlasStoreQuarantine(source: .lastKnownGood, reason: reason) }
        ]
        .compactMap { $0 }
    }

    func manifestIsStale(
        _ manifest: SourceAtlasFreshnessManifest,
        checkedAt: Date,
        policy: SourceAtlasLocalPackCachePolicy
    ) -> Bool {
        let maxAge = TimeInterval(max(policy.maximumManifestAgeDays, 0) * 24 * 60 * 60)
        return checkedAt.timeIntervalSince(manifest.publishedAt) > maxAge
    }

    func fallbackConditions(loadResult: SourceAtlasStoreLoadResult) -> [SourceAtlasOfflineFallbackCondition] {
        var conditions: [SourceAtlasOfflineFallbackCondition] = []
        if loadResult.selectedSource == .lastKnownGood || loadResult.sourceState == .stale {
            conditions.append(.staleCache)
        }
        if loadResult.hasPack == false {
            conditions.append(.missingPack)
        }
        if loadResult.quarantines.contains(where: \.isSourceAtlasCorruptOrInvalidPack) {
            conditions.append(.corruptInvalidPack)
        }
        return orderedConditions(conditions)
    }

    func orderedIssues(_ issues: [SourceAtlasLocalPackCacheIssue]) -> [SourceAtlasLocalPackCacheIssue] {
        SourceAtlasLocalPackCacheIssue.allCases.filter { issues.contains($0) }
    }

    func orderedConditions(_ conditions: [SourceAtlasOfflineFallbackCondition]) -> [SourceAtlasOfflineFallbackCondition] {
        SourceAtlasOfflineFallbackCondition.allCases.filter { conditions.contains($0) }
    }

    func orderedQuarantines(_ quarantines: [SourceAtlasStoreQuarantine]) -> [SourceAtlasStoreQuarantine] {
        let sourcesWithSpecificQuarantine = Set(
            quarantines
                .filter { $0.reason != .missingPayload }
                .map(\.source)
        )
        var seen: Set<SourceAtlasStoreQuarantine> = []
        return quarantines
            .filter { quarantine in
                quarantine.reason != .missingPayload || sourcesWithSpecificQuarantine.contains(quarantine.source) == false
            }
            .filter { seen.insert($0).inserted }
    }

    func normalizedHash(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

private extension SourceAtlasStoreQuarantine {
    var isSourceAtlasCorruptOrInvalidPack: Bool {
        switch reason {
        case .corruptJSON, .unsupportedSchema, .hashMismatch, .invalidPack:
            return true
        case .missingPayload, .staleCritical, .contradicted, .revoked:
            return false
        }
    }
}
