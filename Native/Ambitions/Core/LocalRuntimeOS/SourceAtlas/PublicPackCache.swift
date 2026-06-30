import Foundation

struct PublicPackCacheInput: Sendable, Equatable, Hashable {
    let manifest: SourceAtlasFreshnessManifest
    let request: SourceAtlasPublicPackRequest
    let cachedPayload: SourceAtlasStorePayload?
    let bundledPayload: SourceAtlasStorePayload?
    let lastKnownGoodPayload: SourceAtlasStorePayload?
    let accessDecision: SourceAtlasAccessDecision?
    let query: SourceAtlasQuery
    let checkedAt: Date
    let policy: SourceAtlasLocalPackCachePolicy

    init(
        manifest: SourceAtlasFreshnessManifest,
        request: SourceAtlasPublicPackRequest,
        cachedPayload: SourceAtlasStorePayload? = nil,
        bundledPayload: SourceAtlasStorePayload? = nil,
        lastKnownGoodPayload: SourceAtlasStorePayload? = nil,
        accessDecision: SourceAtlasAccessDecision? = nil,
        query: SourceAtlasQuery = SourceAtlasQuery(),
        checkedAt: Date,
        policy: SourceAtlasLocalPackCachePolicy = SourceAtlasLocalPackCachePolicy()
    ) {
        self.manifest = manifest
        self.request = request
        self.cachedPayload = cachedPayload
        self.bundledPayload = bundledPayload
        self.lastKnownGoodPayload = lastKnownGoodPayload
        self.accessDecision = accessDecision
        self.query = query
        self.checkedAt = checkedAt
        self.policy = policy
    }
}

struct PublicPackCacheResolution: Sendable, Equatable, Hashable {
    let localResolution: SourceAtlasLocalPackCacheResolution
    let freshness: FreshnessEngineVerdict
    let lastKnownGoodSelection: LastKnownGoodSelection?

    var selectedPack: SourceAtlasPack? {
        localResolution.selectedPack
    }

    var canSupportCurrentUse: Bool {
        localResolution.canSupportCurrentUse && freshness.blocksCurrentUse == false
    }
}

struct PublicPackCache: Sendable {
    private let localCache: SourceAtlasLocalPackCache
    private let freshnessEngine: FreshnessEngine
    private let lastKnownGoodStore: LastKnownGoodStore

    init(
        localCache: SourceAtlasLocalPackCache = SourceAtlasLocalPackCache(),
        freshnessEngine: FreshnessEngine = FreshnessEngine(),
        lastKnownGoodStore: LastKnownGoodStore = LastKnownGoodStore()
    ) {
        self.localCache = localCache
        self.freshnessEngine = freshnessEngine
        self.lastKnownGoodStore = lastKnownGoodStore
    }

    func resolve(_ input: PublicPackCacheInput) -> PublicPackCacheResolution {
        let localResolution = localCache.resolve(
            SourceAtlasLocalPackCacheInput(
                manifest: input.manifest,
                request: input.request,
                cachedPayload: input.cachedPayload,
                bundledPayload: input.bundledPayload,
                lastKnownGoodPayload: input.lastKnownGoodPayload,
                query: input.query,
                checkedAt: input.checkedAt,
                policy: input.policy,
                accessDecision: input.accessDecision
            )
        )
        let freshness = freshnessEngine.evaluate(
            manifest: input.manifest,
            packID: input.request.packID,
            checkedAt: input.checkedAt,
            staleAfterDays: input.policy.maximumManifestAgeDays,
            staleCriticalAfterDays: max(input.policy.maximumManifestAgeDays + 1, input.policy.maximumManifestAgeDays * 3)
        )
        let lastKnownGoodSelection = input.manifest.packIndex
            .first(where: { $0.packID == input.request.packID })
            .map { lastKnownGoodStore.select(entry: $0, payload: input.lastKnownGoodPayload) }

        return PublicPackCacheResolution(
            localResolution: localResolution,
            freshness: freshness,
            lastKnownGoodSelection: lastKnownGoodSelection
        )
    }
}
