import CryptoKit
import XCTest
@testable import Ambitions

final class PublicReferenceRepositoryTests: XCTestCase {
    func testAdapterAcceptsOnlyApprovedONETSlice() {
        let accepted = PublicReferencePackAdapter().adapt(Self.artifact())
        XCTAssertTrue(accepted.isVerified)
        XCTAssertEqual(accepted.release?.release.id, "30.3")
        XCTAssertEqual(accepted.release?.claims.map(\.sourceNativeSubjectID), ["15-1252.00"])

        let unsupportedClaim = Self.claim(predicateID: "occupation.salary")
        let rejected = PublicReferencePackAdapter().adapt(Self.artifact(claims: [unsupportedClaim]))
        XCTAssertNil(rejected.release)
        XCTAssertEqual(rejected.quarantines.first?.failures, [.unsupportedPredicate])
    }

    func testAdditiveMigrationLeavesCurrentPointerUnsetAndOfflineReadsBundledRevision() async throws {
        let artifact = try Self.verifiedArtifact(hash: "a", source: .bundled)
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let fileURL = root.appendingPathComponent("public-reference-state.json")
        let provider = StoredProvider(artifacts: [artifact])
        let repository = PublicReferenceRepository(
            bundledProvider: provider,
            stateStore: PublicReferenceFilePointerStateStore(fileURL: fileURL)
        )
        let migration = await repository.migrateAdditively()

        XCTAssertTrue(migration.didInstallBundledRelease)
        let current = await repository.currentSnapshot()
        XCTAssertNil(current)
        let offline = await repository.offlineSnapshot()
        XCTAssertEqual(offline?.delivery, .bundled)
        XCTAssertEqual(offline?.release.claims.first?.deliveryState, .bundled)
        XCTAssertEqual(offline?.release.sourceRevision, Self.sourceRevision(artifact))

        let reopened = PublicReferenceRepository(
            bundledProvider: provider,
            stateStore: PublicReferenceFilePointerStateStore(fileURL: fileURL)
        )
        let reopenedCurrent = await reopened.currentSnapshot()
        XCTAssertNil(reopenedCurrent)
        let reopenedOffline = await reopened.offlineSnapshot()
        XCTAssertEqual(reopenedOffline?.delivery, .bundled)
        XCTAssertEqual(reopenedOffline?.release.claims.first?.deliveryState, .bundled)
        XCTAssertEqual(reopenedOffline?.release.sourceRevision, Self.sourceRevision(artifact))

        let repeatedMigration = await reopened.migrateAdditively()
        XCTAssertFalse(repeatedMigration.didInstallBundledRelease)
    }

    func testPromotionRollbackAndOfflineSnapshotPreserveExactSourceRevision() async throws {
        let store = PublicReferenceInMemoryPointerStateStore()
        let first = try Self.verifiedArtifact(hash: "a")
        let second = try Self.verifiedArtifact(hash: "b")
        let repository = PublicReferenceRepository(
            provider: DelayedProvider(entries: [(first, 0), (second, 0)]),
            stateStore: store
        )

        let firstRefresh = await repository.refresh()
        let secondRefresh = await repository.refresh()
        let current = await repository.currentSnapshot()
        let rollback = await repository.rollbackToLastKnownGood()
        let offline = await repository.offlineSnapshot()
        XCTAssertEqual(firstRefresh, .promoted(sourceRevision: Self.sourceRevision(first)))
        XCTAssertEqual(secondRefresh, .promoted(sourceRevision: Self.sourceRevision(second)))
        XCTAssertEqual(current?.delivery, .cachedVerified)
        XCTAssertEqual(current?.release.claims.first?.deliveryState, .cachedVerified)
        XCTAssertEqual(current?.release.sourceRevision, Self.sourceRevision(second))
        XCTAssertEqual(rollback, .rolledBack(sourceRevision: Self.sourceRevision(first)))
        let rolledBackCurrent = await repository.currentSnapshot()
        XCTAssertEqual(rolledBackCurrent?.delivery, .lastKnownGood)
        XCTAssertEqual(rolledBackCurrent?.release.claims.first?.deliveryState, .lastKnownGood)
        XCTAssertEqual(offline?.delivery, .lastKnownGood)
        XCTAssertEqual(offline?.release.claims.first?.deliveryState, .lastKnownGood)
        XCTAssertEqual(offline?.release.sourceRevision, Self.sourceRevision(first))
    }

    func testRepeatedRefreshPreservesTheRealLastKnownGoodRevision() async throws {
        let first = try Self.verifiedArtifact(hash: "a")
        let second = try Self.verifiedArtifact(hash: "b")
        let repository = PublicReferenceRepository(
            provider: DelayedProvider(entries: [(first, 0), (second, 0), (second, 0)])
        )

        _ = await repository.refresh()
        _ = await repository.refresh()
        _ = await repository.refresh()
        let rollback = await repository.rollbackToLastKnownGood()

        XCTAssertEqual(rollback, .rolledBack(sourceRevision: Self.sourceRevision(first)))
    }

    func testVerifiedCurrentAndLastKnownGoodSurviveRepositoryReopen() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let fileURL = root.appendingPathComponent("public-reference-state.json")

        let firstArtifact = try Self.verifiedArtifact(hash: "a")
        let secondArtifact = try Self.verifiedArtifact(hash: "b")
        let firstRepository = PublicReferenceRepository(
            provider: DelayedProvider(entries: [(firstArtifact, 0), (secondArtifact, 0)]),
            stateStore: PublicReferenceFilePointerStateStore(fileURL: fileURL)
        )
        let firstRefresh = await firstRepository.refresh()
        let secondRefresh = await firstRepository.refresh()
        XCTAssertEqual(firstRefresh, .promoted(sourceRevision: Self.sourceRevision(firstArtifact)))
        XCTAssertEqual(secondRefresh, .promoted(sourceRevision: Self.sourceRevision(secondArtifact)))

        let reopened = PublicReferenceRepository(
            provider: StoredProvider(artifacts: [firstArtifact, secondArtifact]),
            stateStore: PublicReferenceFilePointerStateStore(fileURL: fileURL)
        )
        let reopenedCurrent = await reopened.currentSnapshot()
        let rollback = await reopened.rollbackToLastKnownGood()
        let reopenedOffline = await reopened.offlineSnapshot()
        XCTAssertEqual(reopenedCurrent?.delivery, .cachedVerified)
        XCTAssertEqual(reopenedCurrent?.release.claims.first?.deliveryState, .cachedVerified)
        XCTAssertEqual(reopenedCurrent?.release.sourceRevision, Self.sourceRevision(secondArtifact))
        XCTAssertEqual(rollback, .rolledBack(sourceRevision: Self.sourceRevision(firstArtifact)))
        XCTAssertEqual(reopenedOffline?.delivery, .lastKnownGood)
        XCTAssertEqual(reopenedOffline?.release.claims.first?.deliveryState, .lastKnownGood)
        XCTAssertEqual(reopenedOffline?.release.sourceRevision, Self.sourceRevision(firstArtifact))

        let reopenedAfterRollback = PublicReferenceRepository(
            provider: StoredProvider(artifacts: [firstArtifact, secondArtifact]),
            stateStore: PublicReferenceFilePointerStateStore(fileURL: fileURL)
        )
        let persistedCurrent = await reopenedAfterRollback.currentSnapshot()
        let persistedOffline = await reopenedAfterRollback.offlineSnapshot()
        XCTAssertEqual(persistedCurrent?.delivery, .lastKnownGood)
        XCTAssertEqual(persistedCurrent?.release.claims.first?.deliveryState, .lastKnownGood)
        XCTAssertEqual(persistedOffline?.delivery, .lastKnownGood)
        XCTAssertEqual(persistedOffline?.release.claims.first?.deliveryState, .lastKnownGood)
        XCTAssertEqual(persistedCurrent?.release.sourceRevision, Self.sourceRevision(firstArtifact))
    }

    func testPersistedPointerFailsClosedWhenVerifiedBytesDoNotMatch() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let fileURL = root.appendingPathComponent("public-reference-state.json")
        let original = try Self.verifiedArtifact(hash: "a")
        let repository = PublicReferenceRepository(
            provider: StoredProvider(artifacts: [original]),
            stateStore: PublicReferenceFilePointerStateStore(fileURL: fileURL)
        )
        _ = await repository.refresh()

        let reopened = PublicReferenceRepository(
            provider: StoredProvider(artifacts: [try Self.verifiedArtifact(hash: "b")]),
            stateStore: PublicReferenceFilePointerStateStore(fileURL: fileURL)
        )

        let current = await reopened.currentSnapshot()
        let offline = await reopened.offlineSnapshot()
        XCTAssertNil(current)
        XCTAssertNil(offline)
    }

    func testLifecycleRefreshPromotesVerifiedPublicReferenceCacheProjection() async throws {
        let artifact = try Self.verifiedArtifact(hash: "a")
        let publicReferenceRepository = PublicReferenceRepository(
            provider: StoredProvider(artifacts: [artifact])
        )
        let lifecycle = SourceAtlasPublicPackLifecycleRefreshService(
            registry: .defaultAppRegistry(),
            publicReferenceRepository: publicReferenceRepository
        )

        _ = await lifecycle.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .startup,
                networkReachability: .offline,
                checkedAt: Date(timeIntervalSince1970: 1_780_000_000)
            )
        )

        let current = await publicReferenceRepository.currentSnapshot()
        XCTAssertEqual(current?.release.sourceRevision, Self.sourceRevision(artifact))
    }

    func testCancellationLeavesPointersUntouched() async throws {
        let provider = DelayedProvider(entries: [(try Self.verifiedArtifact(hash: "a"), 500_000_000)])
        let repository = PublicReferenceRepository(provider: provider)
        let task = Task { await repository.refresh() }
        task.cancel()

        let result = await task.value
        let current = await repository.currentSnapshot()
        XCTAssertEqual(result, .cancelled)
        XCTAssertNil(current)
    }

    func testCancellationDuringPointerPersistenceRestoresPreviousState() async throws {
        let artifact = try Self.verifiedArtifact(hash: "persist-cancel")
        let store = DelayedFirstSavePointerStore(delayNanoseconds: 100_000_000)
        let repository = PublicReferenceRepository(
            provider: StoredProvider(artifacts: [artifact]),
            stateStore: store
        )
        let task = Task { await repository.refresh() }
        try await Task.sleep(nanoseconds: 10_000_000)
        task.cancel()

        let result = await task.value
        let current = await repository.currentSnapshot()
        let persisted = try await store.load()
        XCTAssertEqual(result, .cancelled)
        XCTAssertNil(current)
        XCTAssertEqual(persisted, .empty)
    }

    func testLifecycleRefreshReportsUnavailablePublicReferenceProjection() async {
        let repository = PublicReferenceRepository()
        let lifecycle = SourceAtlasPublicPackLifecycleRefreshService(
            registry: .defaultAppRegistry(),
            publicReferenceRepository: repository
        )

        let resolution = await lifecycle.refreshPublicSourceAtlasPacks(
            SourceAtlasPublicPackLifecycleRefreshInput(
                mode: .startup,
                networkReachability: .offline,
                checkedAt: Date(timeIntervalSince1970: 1_780_000_000)
            )
        )

        XCTAssertTrue(resolution.issues.contains(.publicReferenceUnavailable))
    }

    func testConcurrentRefreshDoesNotLetOlderResultOverwriteNewerPromotion() async throws {
        let first = try Self.verifiedArtifact(hash: "a")
        let second = try Self.verifiedArtifact(hash: "b")
        let provider = DelayedProvider(entries: [
            (first, 100_000_000),
            (second, 0)
        ])
        let repository = PublicReferenceRepository(provider: provider)

        async let older = repository.refresh()
        try? await Task.sleep(nanoseconds: 5_000_000)
        async let newer = repository.refresh()
        _ = await (older, newer)

        let current = await repository.currentSnapshot()
        XCTAssertEqual(current?.release.sourceRevision, Self.sourceRevision(second))
    }

    private static func artifact(
        claims: [PublicReferenceClaimEnvelope]? = nil,
        releaseID: String = "30.3",
        hash: String = "abc123"
    ) -> PublicReferencePackArtifact {
        let effectiveClaims = claims ?? [claim(contentHash: hash)]
        return PublicReferencePackArtifact(
            id: "onet-30.3",
            request: SourceAtlasPublicPackRequest(
                packID: "onet-30.3",
                manifestVersionID: releaseID,
                declaredSHA256: String(repeating: "a", count: 64)
            ),
            release: PublicReferenceRelease(id: releaseID),
            publisherID: "onet",
            jurisdiction: PublicReferenceJurisdiction(code: "US", label: "United States"),
            verificationEvidence: verificationEvidence(
                releaseID: releaseID,
                hash: hash,
                claims: effectiveClaims
            ),
            claims: effectiveClaims
        )
    }

    static func verifiedArtifact(
        hash: String,
        source: SourceAtlasStorePayloadSource = .cached
    ) throws -> SourceAtlasPublicReferenceVerifiedArtifact {
        let sourceID = SourceAtlasPublicReferenceVerifiedArtifactProvider.approvedSourceID
        let subjectID = SourceAtlasPublicReferenceVerifiedArtifactProvider.approvedSubjectID
        let predicateID = "occupation.task"
        let claimID = "\(subjectID)::\(predicateID)::task-\(hash)"
        let pack = SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: SourceAtlasPublicReferenceVerifiedArtifactProvider.approvedArtifactID,
                title: "O*NET 30.3 Software Developers",
                kind: .domainPack,
                version: SourceAtlasPublicReferenceVerifiedArtifactProvider.approvedReleaseID,
                domainID: "career",
                specificDomainID: subjectID,
                productionUse: true
            ),
            sources: [
                SourceAtlasSourceRecord(
                    id: sourceID,
                    title: "O*NET Database 30.3",
                    kind: .official,
                    locator: "https://www.onetcenter.org/database.html",
                    retrievedAt: "2026-08-06T00:00:00Z",
                    contentHash: "source-\(hash)",
                    approvedForOfficialClaims: true,
                    licenseIdentifier: SourceAtlasPublicReferenceVerifiedArtifactProvider.approvedLicenseIdentifier,
                    requiredAttribution: SourceAtlasPublicReferenceVerifiedArtifactProvider.approvedAttribution
                )
            ],
            claims: [
                SourceAtlasClaim(
                    id: claimID,
                    text: "Develop software systems \(hash).",
                    state: .official,
                    freshness: .current,
                    riskClass: .careerContext,
                    sourceIDs: [sourceID],
                    reviewRequired: false
                )
            ],
            requirements: [],
            starterItems: [],
            proofMap: [],
            projections: [],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Source needed.",
                reviewRequired: "Review required.",
                notProfessionalAdvice: "Public descriptive reference only."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["onet.\(subjectID)"],
                overlayDependencyIDs: [],
                projectionRecipeIDs: ["public-reference.onet.30.3"],
                ownsIndividualGoalPhrase: false
            )
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let packData = try encoder.encode(pack)
        let packSHA256 = SourceAtlasStore.sha256Hex(for: packData)
        let checkedAt = Date(timeIntervalSince1970: 1_780_000_000)
        let unsignedManifest = SourceAtlasFreshnessManifest(
            schemaVersion: 1,
            versionID: "30.3",
            publishedAt: checkedAt,
            packIndex: [
                SourceAtlasFreshnessPackEntry(
                    packID: "onet-30.3",
                    currentSHA256: packSHA256,
                    currentSignature: ""
                )
            ]
        )
        let privateKey = Curve25519.Signing.PrivateKey()
        let signedData = try ManifestVerifier.signingPayload(for: unsignedManifest)
        let signature = try privateKey.signature(for: signedData).base64EncodedString()
        let manifest = SourceAtlasFreshnessManifest(
            schemaVersion: unsignedManifest.schemaVersion,
            versionID: unsignedManifest.versionID,
            publishedAt: unsignedManifest.publishedAt,
            packIndex: [
                SourceAtlasFreshnessPackEntry(
                    packID: "onet-30.3",
                    currentSHA256: packSHA256,
                    currentSignature: "ed25519:\(signature)"
                )
            ]
        )
        let manifestData = try encoder.encode(manifest)
        let result = SourceAtlasPublicReferenceVerifiedArtifactProvider().verify(
            SourceAtlasPublicReferenceArtifactVerificationInput(
                manifestData: manifestData,
                expectedManifestSHA256: SourceAtlasStore.sha256Hex(for: manifestData),
                packPayload: SourceAtlasStorePayload(
                    source: source,
                    data: packData,
                    declaredSHA256: packSHA256
                ),
                checkedAt: checkedAt,
                ed25519PublicKey: privateKey.publicKey.rawRepresentation
            )
        )
        return try XCTUnwrap(result.artifact)
    }

    private static func verificationEvidence(
        releaseID: String,
        hash: String,
        claims: [PublicReferenceClaimEnvelope]
    ) -> SourceAtlasPublicReferenceArtifactVerificationEvidence {
        SourceAtlasPublicReferenceArtifactVerificationEvidence(
            artifactID: "onet-30.3",
            manifestVersionID: releaseID,
            manifestSHA256: String(repeating: "b", count: 64),
            packSHA256: String(repeating: String(hash.prefix(1)), count: 64),
            packSource: .cached,
            checkedAt: Date(timeIntervalSince1970: 1_780_000_000),
            sourceNativeSubjectID: "15-1252.00",
            predicateIDs: Array(Set(claims.map(\.predicateID))).sorted(),
            sourceIDs: Array(Set(claims.map(\.sourceRecordID))).sorted(),
            signatureResult: SignatureVerificationResult(signature: "test", issues: [])
        )
    }

    private static func sourceRevision(_ artifact: SourceAtlasPublicReferenceVerifiedArtifact) -> String {
        "30.3|\(artifact.evidence.packSHA256)"
    }

    private static func claim(
        predicateID: String = "occupation.task",
        contentHash: String = "abc123"
    ) -> PublicReferenceClaimEnvelope {
        PublicReferenceClaimEnvelope(
            id: PublicReferenceClaimID("claim-software-developers-task"),
            sourceNativeSubjectID: "15-1252.00",
            predicateID: predicateID,
            value: PublicReferenceClaimValue(text: "Develop software systems."),
            sourceRecordID: "onet-30.3-15-1252.00",
            authority: PublicReferenceAuthority(
                publisherID: "onet",
                lane: .description,
                statement: "O*NET owns this descriptive occupation claim."
            ),
            jurisdiction: PublicReferenceJurisdiction(code: "US", label: "United States"),
            release: PublicReferenceRelease(id: "30.3"),
            retrievedAt: "2026-08-06T00:00:00Z",
            checkedAt: "2026-08-06T00:00:00Z",
            deliveryState: .bundled,
            semanticReviewState: .complete,
            freshnessState: .current,
            rightsState: .approvedWithAttribution,
            requiredAttribution: "O*NET 30.3, CC BY 4.0",
            riskState: "descriptive",
            contentHash: contentHash
        )
    }
}

private actor DelayedProvider: PublicReferenceVerifiedPackProviding {
    private var entries: [(SourceAtlasPublicReferenceVerifiedArtifact, UInt64)]

    init(entries: [(SourceAtlasPublicReferenceVerifiedArtifact, UInt64)]) {
        self.entries = entries
    }

    func verifiedSourceAtlasArtifact(
        matching pointer: PublicReferenceVerifiedReleasePointer?
    ) async -> SourceAtlasPublicReferenceVerifiedArtifact? {
        guard pointer == nil else { return nil }
        guard entries.isEmpty == false else { return nil }
        let entry = entries.removeFirst()
        if entry.1 > 0 {
            try? await Task.sleep(nanoseconds: entry.1)
        }
        return entry.0
    }
}

private struct StoredProvider: PublicReferenceVerifiedPackProviding {
    let artifacts: [SourceAtlasPublicReferenceVerifiedArtifact]

    func verifiedSourceAtlasArtifact(
        matching pointer: PublicReferenceVerifiedReleasePointer?
    ) async -> SourceAtlasPublicReferenceVerifiedArtifact? {
        guard let pointer else { return artifacts.last }
        return artifacts.first {
            $0.evidence.artifactID == pointer.artifactID &&
                $0.evidence.manifestVersionID == pointer.manifestVersionID &&
                $0.evidence.manifestSHA256 == pointer.manifestSHA256 &&
                $0.evidence.packSHA256 == pointer.packSHA256
        }
    }
}

private actor DelayedFirstSavePointerStore: PublicReferencePointerStateStoring {
    private let delayNanoseconds: UInt64
    private var state = PublicReferenceRepositoryPersistedState.empty
    private var saveCount = 0

    init(delayNanoseconds: UInt64) {
        self.delayNanoseconds = delayNanoseconds
    }

    func load() async throws -> PublicReferenceRepositoryPersistedState {
        state
    }

    func save(_ state: PublicReferenceRepositoryPersistedState) async throws {
        saveCount += 1
        if saveCount == 1 {
            try? await Task.sleep(nanoseconds: delayNanoseconds)
        }
        self.state = state
    }
}
