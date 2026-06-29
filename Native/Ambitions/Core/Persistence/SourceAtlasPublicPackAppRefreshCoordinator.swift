import Foundation

enum SourceAtlasPublicPackAppRefreshMode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case startup
    case background
    case manual
}

enum SourceAtlasPublicPackAppRefreshIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case cachedManifestLookupRejected = "cached_manifest_lookup_rejected"
    case cachedManifestUnavailable = "cached_manifest_unavailable"
    case cachedPayloadUnavailable = "cached_payload_unavailable"
    case repositoryLookupFailed = "repository_lookup_failed"
}

struct SourceAtlasPublicPackAppRefreshInput: Sendable, Equatable, Hashable {
    let mode: SourceAtlasPublicPackAppRefreshMode
    let manifestRequest: SourceAtlasPublicManifestRequest
    let targetPackID: String
    let environment: String
    let cachedManifestLookup: SourceAtlasPublicPackCacheManifestLookup?
    let bundledPayload: SourceAtlasStorePayload?
    let lastKnownGoodPayload: SourceAtlasStorePayload?
    let accountSessionState: SourceAtlasAccountSessionState
    let entitlementState: SourceAtlasReferenceEntitlementState
    let networkReachability: SourceAtlasNetworkReachability
    let query: SourceAtlasQuery
    let checkedAt: Date
    let policy: SourceAtlasLocalPackCachePolicy

    init(
        mode: SourceAtlasPublicPackAppRefreshMode,
        manifestRequest: SourceAtlasPublicManifestRequest,
        targetPackID: String,
        environment: String = "staging",
        cachedManifestLookup: SourceAtlasPublicPackCacheManifestLookup? = nil,
        bundledPayload: SourceAtlasStorePayload? = nil,
        lastKnownGoodPayload: SourceAtlasStorePayload? = nil,
        accountSessionState: SourceAtlasAccountSessionState = .noAccount,
        entitlementState: SourceAtlasReferenceEntitlementState = .bundledOnly,
        networkReachability: SourceAtlasNetworkReachability,
        query: SourceAtlasQuery = SourceAtlasQuery(),
        checkedAt: Date,
        policy: SourceAtlasLocalPackCachePolicy = SourceAtlasLocalPackCachePolicy()
    ) {
        self.mode = mode
        self.manifestRequest = manifestRequest
        self.targetPackID = targetPackID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.environment = environment.trimmingCharacters(in: .whitespacesAndNewlines)
        self.cachedManifestLookup = cachedManifestLookup
        self.bundledPayload = bundledPayload
        self.lastKnownGoodPayload = lastKnownGoodPayload
        self.accountSessionState = accountSessionState
        self.entitlementState = entitlementState
        self.networkReachability = networkReachability
        self.query = query
        self.checkedAt = checkedAt
        self.policy = policy
    }
}

struct SourceAtlasPublicPackAppRefreshResolution: Sendable, Equatable, Hashable {
    let mode: SourceAtlasPublicPackAppRefreshMode
    let accessDecision: SourceAtlasAccessDecision
    let cachedManifestLoadedFromRepository: Bool
    let cachedPayloadLoadedFromRepository: Bool
    let appRefreshIssues: [SourceAtlasPublicPackAppRefreshIssue]
    let refreshResolution: SourceAtlasPublicPackRepositoryBackedRemoteRefreshResolution

    var selectedPack: SourceAtlasPack? {
        refreshResolution.selectedPack
    }

    var persistedPackPayload: Bool {
        refreshResolution.persistedPackPayload
    }

    var coreLocalPlanningBlocked: Bool {
        false
    }
}

struct SourceAtlasPublicPackAppRefreshCoordinator {
    private let accessBoundary: SourceAtlasAccessBoundary
    private let refreshCoordinator: SourceAtlasPublicPackRepositoryBackedRemoteRefreshCoordinator

    init(
        accessBoundary: SourceAtlasAccessBoundary = SourceAtlasAccessBoundary(),
        refreshCoordinator: SourceAtlasPublicPackRepositoryBackedRemoteRefreshCoordinator = SourceAtlasPublicPackRepositoryBackedRemoteRefreshCoordinator()
    ) {
        self.accessBoundary = accessBoundary
        self.refreshCoordinator = refreshCoordinator
    }

    func resolve(
        _ input: SourceAtlasPublicPackAppRefreshInput,
        transport: SourceAtlasPublicPackRemoteTransport,
        repository: SourceAtlasPublicPackCacheFileRepository
    ) async -> SourceAtlasPublicPackAppRefreshResolution {
        var issues: Set<SourceAtlasPublicPackAppRefreshIssue> = []
        let cachedManifest = repositoryCachedManifest(
            for: input.cachedManifestLookup,
            repository: repository,
            issues: &issues
        )
        let cachedPayload = repositoryCachedPayload(
            input: input,
            cachedManifest: cachedManifest,
            repository: repository,
            issues: &issues
        )

        let shouldSkipRemote = issues.contains(.cachedManifestLookupRejected)
        let accessDecision = accessBoundary.resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: input.accountSessionState,
                entitlementState: input.entitlementState,
                networkReachability: shouldSkipRemote ? .offline : input.networkReachability,
                cachedPublicArtifactAvailable: cachedPayload != nil,
                lastKnownGoodAvailable: input.lastKnownGoodPayload != nil,
                bundledPublicArtifactAvailable: input.bundledPayload != nil
            )
        )

        let refreshInput = SourceAtlasPublicPackRemoteFetchInput(
            manifestRequest: input.manifestRequest,
            targetPackID: input.targetPackID,
            environment: input.environment,
            cachedManifest: cachedManifest,
            cachedPayload: cachedPayload,
            bundledPayload: input.bundledPayload,
            lastKnownGoodPayload: input.lastKnownGoodPayload,
            accessDecision: accessDecision,
            query: input.query,
            checkedAt: input.checkedAt,
            policy: input.policy
        )
        let refreshResolution = await refreshCoordinator.resolve(
            refreshInput,
            transport: transport,
            repository: repository
        )

        return SourceAtlasPublicPackAppRefreshResolution(
            mode: input.mode,
            accessDecision: accessDecision,
            cachedManifestLoadedFromRepository: cachedManifest != nil,
            cachedPayloadLoadedFromRepository: cachedPayload != nil,
            appRefreshIssues: SourceAtlasPublicPackAppRefreshIssue.allCases.filter { issues.contains($0) },
            refreshResolution: refreshResolution
        )
    }
}

private extension SourceAtlasPublicPackAppRefreshCoordinator {
    func repositoryCachedManifest(
        for lookup: SourceAtlasPublicPackCacheManifestLookup?,
        repository: SourceAtlasPublicPackCacheFileRepository,
        issues: inout Set<SourceAtlasPublicPackAppRefreshIssue>
    ) -> SourceAtlasFreshnessManifest? {
        guard let lookup else {
            return nil
        }
        guard cachedManifestLookupIsPublicSafe(lookup) else {
            issues.insert(.cachedManifestLookupRejected)
            return nil
        }
        do {
            let manifest = try repository.loadManifest(lookup)
            if manifest == nil {
                issues.insert(.cachedManifestUnavailable)
            }
            return manifest
        } catch {
            issues.insert(.repositoryLookupFailed)
            return nil
        }
    }

    func repositoryCachedPayload(
        input: SourceAtlasPublicPackAppRefreshInput,
        cachedManifest: SourceAtlasFreshnessManifest?,
        repository: SourceAtlasPublicPackCacheFileRepository,
        issues: inout Set<SourceAtlasPublicPackAppRefreshIssue>
    ) -> SourceAtlasStorePayload? {
        guard let cachedManifest,
              let entry = cachedManifest.packIndex.first(where: { $0.packID == input.targetPackID })
        else {
            return nil
        }
        do {
            let payload = try repository.loadPayload(
                SourceAtlasPublicPackCachePayloadLookup(
                    packID: input.targetPackID,
                    manifestVersionID: cachedManifest.versionID,
                    declaredSHA256: entry.currentSHA256
                )
            )
            if payload == nil {
                issues.insert(.cachedPayloadUnavailable)
            }
            return payload
        } catch {
            issues.insert(.repositoryLookupFailed)
            return nil
        }
    }

    func cachedManifestLookupIsPublicSafe(_ lookup: SourceAtlasPublicPackCacheManifestLookup) -> Bool {
        SourceAtlasNoPrivateGraphEgressAudit.validate([lookup.egressRecord]).isEmpty &&
            privateCacheMetadataFindings([lookup.egressRecord]).isEmpty &&
            isSHA256Hex(lookup.declaredPackSHA256)
    }

    func privateCacheMetadataFindings(
        _ records: [SourceAtlasNoPrivateGraphEgressRecord]
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        let extraTokens = [
            "account_id",
            "device_id",
            "goal_id",
            "goal_text",
            "capture_text",
            "schedule",
            "calendar",
            "proof_payload",
            "receipt_payload",
            "private_context",
            "private_user_context",
            "life_graph",
        ]
        return records.flatMap { record in
            let normalized = SourceAtlasNoPrivateGraphEgressAudit.normalize(record.inspectedValue)
            return extraTokens.compactMap { token in
                normalized.contains(token)
                    ? SourceAtlasNoPrivateGraphEgressFinding(
                        surface: record.surface,
                        identifier: record.identifier,
                        forbiddenToken: token
                    )
                    : nil
            }
        }
    }

    func isSHA256Hex(_ value: String) -> Bool {
        value.count == 64 && value.allSatisfy { character in
            character.isNumber || ("a"..."f").contains(character)
        }
    }
}
