import Foundation

let publicReferenceRepositorySchemaVersion = "public_reference_repository.native.v2"

protocol PublicReferenceVerifiedPackProviding: Sendable {
    func verifiedSourceAtlasArtifact(
        matching pointer: PublicReferenceVerifiedReleasePointer?
    ) async -> SourceAtlasPublicReferenceVerifiedArtifact?
}

struct PublicReferenceVerifiedReleasePointer: Codable, Sendable, Equatable, Hashable {
    let artifactID: String
    let manifestVersionID: String
    let manifestSHA256: String
    let packSHA256: String
    let packSource: SourceAtlasStorePayloadSource
    let sourceRevision: String

    init(artifact: PublicReferencePackArtifact, release: PublicReferenceVerifiedRelease) {
        self.artifactID = artifact.verificationEvidence.artifactID
        self.manifestVersionID = artifact.verificationEvidence.manifestVersionID
        self.manifestSHA256 = artifact.verificationEvidence.manifestSHA256
        self.packSHA256 = artifact.verificationEvidence.packSHA256
        self.packSource = artifact.verificationEvidence.packSource
        self.sourceRevision = release.sourceRevision
    }
}

struct PublicReferenceRepositoryPersistedState: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let current: PublicReferenceVerifiedReleasePointer?
    let currentDelivery: PublicReferenceRepositoryDelivery?
    let lastKnownGood: PublicReferenceVerifiedReleasePointer?
    let bundled: PublicReferenceVerifiedReleasePointer?

    static let empty = PublicReferenceRepositoryPersistedState(
        schemaVersion: publicReferenceRepositorySchemaVersion,
        current: nil,
        currentDelivery: nil,
        lastKnownGood: nil,
        bundled: nil
    )
}

protocol PublicReferencePointerStateStoring: Sendable {
    func load() async throws -> PublicReferenceRepositoryPersistedState
    func save(_ state: PublicReferenceRepositoryPersistedState) async throws
}

actor PublicReferenceInMemoryPointerStateStore: PublicReferencePointerStateStoring {
    private var state: PublicReferenceRepositoryPersistedState

    init(state: PublicReferenceRepositoryPersistedState = .empty) {
        self.state = state
    }

    func load() async throws -> PublicReferenceRepositoryPersistedState {
        state
    }

    func save(_ state: PublicReferenceRepositoryPersistedState) async throws {
        self.state = state
    }
}

actor PublicReferenceFilePointerStateStore: PublicReferencePointerStateStoring {
    private let fileURL: URL

    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    func load() async throws -> PublicReferenceRepositoryPersistedState {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: fileURL.path) else { return .empty }
        let data = try Data(contentsOf: fileURL)
        let state = try JSONDecoder().decode(PublicReferenceRepositoryPersistedState.self, from: data)
        guard state.schemaVersion == publicReferenceRepositorySchemaVersion else {
            return .empty
        }
        return state
    }

    func save(_ state: PublicReferenceRepositoryPersistedState) async throws {
        let fileManager = FileManager.default
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        let data = try encoder.encode(state)
        try fileManager.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
    }

    static func defaultAppStore() -> PublicReferenceFilePointerStateStore {
        let cache = SourceAtlasPublicPackCacheFileRepository.defaultAppCacheRepository()
        return PublicReferenceFilePointerStateStore(
            fileURL: cache.absoluteURL(for: "pointers/public-reference-release-state.json")
        )
    }
}

struct PublicReferenceUnavailableVerifiedPackProvider: PublicReferenceVerifiedPackProviding {
    func verifiedSourceAtlasArtifact(
        matching pointer: PublicReferenceVerifiedReleasePointer?
    ) async -> SourceAtlasPublicReferenceVerifiedArtifact? { nil }
}

enum PublicReferenceRepositoryDelivery: String, Codable, Sendable, Equatable, Hashable {
    case bundled
    case cachedVerified = "cached_verified"
    case lastKnownGood = "last_known_good"
    case unavailable
}

enum PublicReferenceRepositoryRefreshResult: Codable, Sendable, Equatable, Hashable {
    case promoted(sourceRevision: String)
    case rolledBack(sourceRevision: String)
    case cancelled
    case unavailable
    case quarantined([PublicReferencePackQuarantine])
    case superseded
    case persistenceFailed
}

struct PublicReferenceRepositorySnapshot: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let delivery: PublicReferenceRepositoryDelivery
    let release: PublicReferenceVerifiedRelease
}

struct PublicReferenceRepositoryMigrationResult: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let didInstallBundledRelease: Bool
    let quarantines: [PublicReferencePackQuarantine]
}

/// The actor is a public-cache boundary. It stages and promotes immutable
/// releases only after the adapter completes; snapshots retain exact claim
/// envelopes and are never mutated after return.
actor PublicReferenceRepository {
    private let adapter: PublicReferencePackAdapter
    private let provider: any PublicReferenceVerifiedPackProviding
    private let bundledProvider: any PublicReferenceVerifiedPackProviding
    private let stateStore: any PublicReferencePointerStateStoring
    private var currentRelease: PublicReferenceVerifiedRelease?
    private var currentDelivery: PublicReferenceRepositoryDelivery?
    private var bundledRelease: PublicReferenceVerifiedRelease?
    private var lastKnownGoodRelease: PublicReferenceVerifiedRelease?
    private var currentPointer: PublicReferenceVerifiedReleasePointer?
    private var bundledPointer: PublicReferenceVerifiedReleasePointer?
    private var lastKnownGoodPointer: PublicReferenceVerifiedReleasePointer?
    private var quarantines: [PublicReferencePackQuarantine] = []
    private var latestStartedRefreshID = 0
    private var didLoadPersistedState = false
    private var isLoadingPersistedState = false

    init(
        adapter: PublicReferencePackAdapter = PublicReferencePackAdapter(),
        provider: any PublicReferenceVerifiedPackProviding = PublicReferenceUnavailableVerifiedPackProvider(),
        bundledProvider: any PublicReferenceVerifiedPackProviding = PublicReferenceUnavailableVerifiedPackProvider(),
        stateStore: any PublicReferencePointerStateStoring = PublicReferenceInMemoryPointerStateStore()
    ) {
        self.adapter = adapter
        self.provider = provider
        self.bundledProvider = bundledProvider
        self.stateStore = stateStore
    }

    func migrateAdditively() async -> PublicReferenceRepositoryMigrationResult {
        await loadPersistedStateIfNeeded()
        guard let verifiedArtifact = await bundledProvider.verifiedSourceAtlasArtifact(matching: nil),
              verifiedArtifact.evidence.packSource == .bundled,
              let artifact = verifiedArtifact.publicReferencePackArtifact()
        else {
            return PublicReferenceRepositoryMigrationResult(
                schemaVersion: publicReferenceRepositorySchemaVersion,
                didInstallBundledRelease: false,
                quarantines: []
            )
        }
        let result = adapter.adapt(artifact)
        guard let release = result.release else {
            quarantines.append(contentsOf: result.quarantines)
            return PublicReferenceRepositoryMigrationResult(
                schemaVersion: publicReferenceRepositorySchemaVersion,
                didInstallBundledRelease: false,
                quarantines: result.quarantines
            )
        }
        guard bundledRelease == nil else {
            return PublicReferenceRepositoryMigrationResult(
                schemaVersion: publicReferenceRepositorySchemaVersion,
                didInstallBundledRelease: false,
                quarantines: []
            )
        }
        bundledRelease = release
        bundledPointer = PublicReferenceVerifiedReleasePointer(artifact: artifact, release: release)
        guard await persistState() else {
            bundledRelease = nil
            bundledPointer = nil
            return PublicReferenceRepositoryMigrationResult(
                schemaVersion: publicReferenceRepositorySchemaVersion,
                didInstallBundledRelease: false,
                quarantines: []
            )
        }
        return PublicReferenceRepositoryMigrationResult(
            schemaVersion: publicReferenceRepositorySchemaVersion,
            didInstallBundledRelease: true,
            quarantines: []
        )
    }

    func refresh() async -> PublicReferenceRepositoryRefreshResult {
        await loadPersistedStateIfNeeded()
        latestStartedRefreshID += 1
        let refreshID = latestStartedRefreshID
        guard Task.isCancelled == false else { return .cancelled }
        guard let verifiedArtifact = await provider.verifiedSourceAtlasArtifact(matching: nil),
              let artifact = verifiedArtifact.publicReferencePackArtifact()
        else { return .unavailable }
        guard Task.isCancelled == false else { return .cancelled }
        return await refresh(artifact, refreshID: refreshID)
    }

    func rollbackToLastKnownGood() async -> PublicReferenceRepositoryRefreshResult {
        await loadPersistedStateIfNeeded()
        latestStartedRefreshID += 1
        let operationID = latestStartedRefreshID
        guard let lastKnownGood = lastKnownGoodRelease,
              let lastKnownGoodPointer
        else { return .unavailable }
        let prospectiveState = persistedState(
            current: lastKnownGoodPointer,
            currentDelivery: .lastKnownGood,
            lastKnownGood: lastKnownGoodPointer,
            bundled: bundledPointer
        )
        guard await persistState(prospectiveState) else {
            return .persistenceFailed
        }
        guard operationID == latestStartedRefreshID, Task.isCancelled == false else {
            _ = await persistState()
            return operationID == latestStartedRefreshID ? .cancelled : .superseded
        }
        currentRelease = lastKnownGood
        currentPointer = lastKnownGoodPointer
        currentDelivery = .lastKnownGood
        return .rolledBack(sourceRevision: lastKnownGood.sourceRevision)
    }

    func currentSnapshot() async -> PublicReferenceRepositorySnapshot? {
        await loadPersistedStateIfNeeded()
        return snapshot(release: currentRelease, delivery: currentDelivery ?? .cachedVerified)
    }

    func offlineSnapshot() async -> PublicReferenceRepositorySnapshot? {
        await loadPersistedStateIfNeeded()
        if let current = snapshot(release: currentRelease, delivery: currentDelivery ?? .cachedVerified) {
            return current
        }
        if let bundled = snapshot(release: bundledRelease, delivery: .bundled) {
            return bundled
        }
        if let lastKnownGood = lastKnownGoodRelease {
            return snapshot(release: lastKnownGood, delivery: .lastKnownGood)
        }
        return nil
    }

    func recordedQuarantines() -> [PublicReferencePackQuarantine] {
        quarantines
    }
}

private extension PublicReferenceRepository {
    func refresh(
        _ artifact: PublicReferencePackArtifact,
        refreshID: Int
    ) async -> PublicReferenceRepositoryRefreshResult {
        guard Task.isCancelled == false else { return .cancelled }
        let result = adapter.adapt(artifact)
        guard Task.isCancelled == false else { return .cancelled }
        guard refreshID == latestStartedRefreshID else { return .superseded }
        guard let release = result.release else {
            quarantines.append(contentsOf: result.quarantines)
            return .quarantined(result.quarantines)
        }
        let previousRelease = currentRelease
        let previousLastKnownGoodRelease = lastKnownGoodRelease
        let previousPointer = currentPointer
        let previousLastKnownGoodPointer = lastKnownGoodPointer
        let nextPointer = PublicReferenceVerifiedReleasePointer(artifact: artifact, release: release)
        let isSameRevision = previousRelease?.sourceRevision == release.sourceRevision
        let nextLastKnownGoodRelease = isSameRevision == false
            ? previousRelease ?? release
            : previousLastKnownGoodRelease
        let nextLastKnownGoodPointer = isSameRevision == false
            ? previousPointer ?? nextPointer
            : previousLastKnownGoodPointer
        let prospectiveState = persistedState(
            current: nextPointer,
            currentDelivery: .cachedVerified,
            lastKnownGood: nextLastKnownGoodPointer,
            bundled: bundledPointer
        )
        guard await persistState(prospectiveState) else {
            return .persistenceFailed
        }
        if Task.isCancelled {
            return await persistState() ? .cancelled : .persistenceFailed
        }
        guard refreshID == latestStartedRefreshID else {
            return await persistState() ? .superseded : .persistenceFailed
        }
        currentRelease = release
        currentDelivery = .cachedVerified
        currentPointer = nextPointer
        lastKnownGoodRelease = nextLastKnownGoodRelease
        lastKnownGoodPointer = nextLastKnownGoodPointer
        return .promoted(sourceRevision: release.sourceRevision)
    }

    func loadPersistedStateIfNeeded() async {
        guard didLoadPersistedState == false else { return }
        if isLoadingPersistedState {
            while didLoadPersistedState == false {
                await Task.yield()
            }
            return
        }
        isLoadingPersistedState = true
        defer {
            isLoadingPersistedState = false
            didLoadPersistedState = true
        }
        guard let state = try? await stateStore.load() else { return }
        currentPointer = state.current
        lastKnownGoodPointer = state.lastKnownGood
        bundledPointer = state.bundled
        currentRelease = await verifiedRelease(matching: state.current)
        currentDelivery = currentRelease == nil ? nil : state.currentDelivery ?? .cachedVerified
        lastKnownGoodRelease = await verifiedRelease(matching: state.lastKnownGood)
        bundledRelease = await verifiedRelease(matching: state.bundled)
    }

    func persistState() async -> Bool {
        await persistState(persistedState(
            current: currentPointer,
            currentDelivery: currentDelivery,
            lastKnownGood: lastKnownGoodPointer,
            bundled: bundledPointer
        ))
    }

    func persistState(_ state: PublicReferenceRepositoryPersistedState) async -> Bool {
        do {
            try await stateStore.save(state)
            return true
        } catch {
            return false
        }
    }

    func persistedState(
        current: PublicReferenceVerifiedReleasePointer?,
        currentDelivery: PublicReferenceRepositoryDelivery?,
        lastKnownGood: PublicReferenceVerifiedReleasePointer?,
        bundled: PublicReferenceVerifiedReleasePointer?
    ) -> PublicReferenceRepositoryPersistedState {
        PublicReferenceRepositoryPersistedState(
            schemaVersion: publicReferenceRepositorySchemaVersion,
            current: current,
            currentDelivery: currentDelivery,
            lastKnownGood: lastKnownGood,
            bundled: bundled
        )
    }

    func verifiedRelease(
        matching pointer: PublicReferenceVerifiedReleasePointer?
    ) async -> PublicReferenceVerifiedRelease? {
        guard let pointer else { return nil }
        let selectedProvider = pointer.packSource == .bundled ? bundledProvider : provider
        guard let verifiedArtifact = await selectedProvider.verifiedSourceAtlasArtifact(matching: pointer),
              verifiedArtifact.evidence.packSource == pointer.packSource,
              let artifact = verifiedArtifact.publicReferencePackArtifact()
        else { return nil }
        let result = adapter.adapt(artifact)
        guard let release = result.release,
              release.sourceRevision == pointer.sourceRevision,
              artifact.verificationEvidence.artifactID == pointer.artifactID,
              artifact.verificationEvidence.manifestVersionID == pointer.manifestVersionID,
              artifact.verificationEvidence.manifestSHA256 == pointer.manifestSHA256,
              artifact.verificationEvidence.packSHA256 == pointer.packSHA256
        else { return nil }
        return release
    }

    func snapshot(
        release: PublicReferenceVerifiedRelease?,
        delivery: PublicReferenceRepositoryDelivery
    ) -> PublicReferenceRepositorySnapshot? {
        guard let release else { return nil }
        return PublicReferenceRepositorySnapshot(
            schemaVersion: publicReferenceRepositorySchemaVersion,
            delivery: delivery,
            release: delivered(release, as: delivery)
        )
    }

    func delivered(
        _ release: PublicReferenceVerifiedRelease,
        as delivery: PublicReferenceRepositoryDelivery
    ) -> PublicReferenceVerifiedRelease {
        PublicReferenceVerifiedRelease(
            artifactID: release.artifactID,
            release: release.release,
            claims: release.claims.map { delivered($0, as: delivery) },
            sourceRevision: release.sourceRevision
        )
    }

    func delivered(
        _ claim: PublicReferenceClaimEnvelope,
        as delivery: PublicReferenceRepositoryDelivery
    ) -> PublicReferenceClaimEnvelope {
        PublicReferenceClaimEnvelope(
            id: claim.id,
            sourceNativeSubjectID: claim.sourceNativeSubjectID,
            predicateID: claim.predicateID,
            value: claim.value,
            sourceRecordID: claim.sourceRecordID,
            authority: claim.authority,
            jurisdiction: claim.jurisdiction,
            release: claim.release,
            retrievedAt: claim.retrievedAt,
            checkedAt: claim.checkedAt,
            deliveryState: claimDelivery(for: delivery),
            semanticReviewState: claim.semanticReviewState,
            freshnessState: claim.freshnessState,
            rightsState: claim.rightsState,
            requiredAttribution: claim.requiredAttribution,
            riskState: claim.riskState,
            conflictIDs: claim.conflictIDs,
            supersedesIDs: claim.supersedesIDs,
            supersededByIDs: claim.supersededByIDs,
            contentHash: claim.contentHash,
            schemaVersion: claim.schemaVersion
        )
    }

    func claimDelivery(
        for delivery: PublicReferenceRepositoryDelivery
    ) -> PublicReferenceDeliveryState {
        switch delivery {
        case .bundled: .bundled
        case .cachedVerified: .cachedVerified
        case .lastKnownGood: .lastKnownGood
        case .unavailable: .unavailable
        }
    }
}
