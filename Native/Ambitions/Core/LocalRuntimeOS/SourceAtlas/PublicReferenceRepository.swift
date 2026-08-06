import Foundation

let publicReferenceRepositorySchemaVersion = "public_reference_repository.native.v1"

protocol PublicReferenceVerifiedPackProviding: Sendable {
    func verifiedPublicReferencePack() async -> PublicReferencePackArtifact?
}

protocol PublicReferenceLastKnownGoodStoring: Sendable {
    func loadLastKnownGood() async -> PublicReferenceVerifiedRelease?
    func saveLastKnownGood(_ release: PublicReferenceVerifiedRelease) async
}

actor PublicReferenceInMemoryLastKnownGoodStore: PublicReferenceLastKnownGoodStoring {
    private var release: PublicReferenceVerifiedRelease?

    init(release: PublicReferenceVerifiedRelease? = nil) {
        self.release = release
    }

    func loadLastKnownGood() async -> PublicReferenceVerifiedRelease? {
        release
    }

    func saveLastKnownGood(_ release: PublicReferenceVerifiedRelease) async {
        self.release = release
    }
}

struct PublicReferenceUnavailableVerifiedPackProvider: PublicReferenceVerifiedPackProviding {
    func verifiedPublicReferencePack() async -> PublicReferencePackArtifact? { nil }
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
    private let lastKnownGoodStore: any PublicReferenceLastKnownGoodStoring
    private var currentRelease: PublicReferenceVerifiedRelease?
    private var bundledRelease: PublicReferenceVerifiedRelease?
    private var quarantines: [PublicReferencePackQuarantine] = []
    private var latestStartedRefreshID = 0

    init(
        adapter: PublicReferencePackAdapter = PublicReferencePackAdapter(),
        provider: any PublicReferenceVerifiedPackProviding = PublicReferenceUnavailableVerifiedPackProvider(),
        lastKnownGoodStore: any PublicReferenceLastKnownGoodStoring = PublicReferenceInMemoryLastKnownGoodStore()
    ) {
        self.adapter = adapter
        self.provider = provider
        self.lastKnownGoodStore = lastKnownGoodStore
    }

    func migrateAdditively(bundled artifact: PublicReferencePackArtifact?) async -> PublicReferenceRepositoryMigrationResult {
        guard let artifact else {
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
        if bundledRelease == nil {
            bundledRelease = release
        }
        return PublicReferenceRepositoryMigrationResult(
            schemaVersion: publicReferenceRepositorySchemaVersion,
            didInstallBundledRelease: true,
            quarantines: []
        )
    }

    func refresh() async -> PublicReferenceRepositoryRefreshResult {
        latestStartedRefreshID += 1
        let refreshID = latestStartedRefreshID
        guard Task.isCancelled == false else { return .cancelled }
        guard let artifact = await provider.verifiedPublicReferencePack() else { return .unavailable }
        guard Task.isCancelled == false else { return .cancelled }
        return await refresh(artifact, refreshID: refreshID)
    }

    func refresh(_ artifact: PublicReferencePackArtifact) async -> PublicReferenceRepositoryRefreshResult {
        latestStartedRefreshID += 1
        return await refresh(artifact, refreshID: latestStartedRefreshID)
    }

    func rollbackToLastKnownGood() async -> PublicReferenceRepositoryRefreshResult {
        guard let lastKnownGood = await lastKnownGoodStore.loadLastKnownGood() else { return .unavailable }
        currentRelease = lastKnownGood
        return .rolledBack(sourceRevision: lastKnownGood.sourceRevision)
    }

    func currentSnapshot() -> PublicReferenceRepositorySnapshot? {
        snapshot(release: currentRelease, delivery: .cachedVerified)
    }

    func offlineSnapshot() async -> PublicReferenceRepositorySnapshot? {
        if let current = snapshot(release: currentRelease, delivery: .cachedVerified) {
            return current
        }
        if let bundled = snapshot(release: bundledRelease, delivery: .bundled) {
            return bundled
        }
        if let lastKnownGood = await lastKnownGoodStore.loadLastKnownGood() {
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
        currentRelease = release
        await lastKnownGoodStore.saveLastKnownGood(previousRelease ?? release)
        return .promoted(sourceRevision: release.sourceRevision)
    }

    func snapshot(
        release: PublicReferenceVerifiedRelease?,
        delivery: PublicReferenceRepositoryDelivery
    ) -> PublicReferenceRepositorySnapshot? {
        guard let release else { return nil }
        return PublicReferenceRepositorySnapshot(
            schemaVersion: publicReferenceRepositorySchemaVersion,
            delivery: delivery,
            release: release
        )
    }
}
