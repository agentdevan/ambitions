import XCTest
@testable import Ambitions

final class SourceAtlasPublicPackRepositoryBackedRemoteRefreshTests: XCTestCase {
    func testProductionR2Train29FixturePersistsPackAndOfflineNoAccountUsesRepositoryCache() async throws {
        let fixture = try Self.productionR2Train29Fixture()
        let repository = try Self.repository()
        let coordinator = SourceAtlasPublicPackRepositoryBackedRemoteRefreshCoordinator()

        let onlineResolution = await coordinator.resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionManifestRequest,
                targetPackID: fixture.packID,
                environment: "production",
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: false
                ),
                query: SourceAtlasQuery(domainID: "occupation_foundation"),
                checkedAt: Self.checkedAt
            ),
            transport: SourceAtlasStaticPublicPackRemoteTransport(
                objectsByKey: [
                    fixture.currentPointerKey: fixture.currentPointerData,
                    fixture.revocationsKey: fixture.revocationData,
                    fixture.manifestKey: fixture.manifestData,
                    fixture.lkgKey: fixture.lkgData,
                    fixture.packObjectKey: fixture.packData
                ]
            ),
            repository: repository
        )

        XCTAssertEqual(onlineResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(
            onlineResolution.remoteResolution.objectRequests.map(\.kind),
            [.currentPointer, .revocations, .manifest, .lastKnownGood, .lastKnownGoodManifest, .pack]
        )
        XCTAssertEqual(onlineResolution.remoteResolution.pipelineResolution.status, .accepted)
        XCTAssertEqual(onlineResolution.remoteResolution.pipelineResolution.fetchIssues, [])
        XCTAssertEqual(onlineResolution.remoteResolution.pipelineResolution.cacheResolution?.loadResult.selectedSource, .cached)
        XCTAssertEqual(onlineResolution.selectedPack?.id, fixture.packID)
        XCTAssertEqual(onlineResolution.selectedPack?.manifest.domainID, "occupation_foundation")
        XCTAssertEqual(onlineResolution.selectedPack?.starterItems, [])
        XCTAssertEqual(onlineResolution.selectedPack?.composition.ownsIndividualGoalPhrase, false)
        XCTAssertEqual(onlineResolution.cacheJournalRecord.status, .acceptedCurrent)
        XCTAssertTrue(onlineResolution.cacheJournalRecord.canPersistCurrentPack)
        XCTAssertEqual(onlineResolution.cacheCommitResult?.status, .persistedCurrent)
        XCTAssertTrue(onlineResolution.persistedPackPayload)
        XCTAssertEqual(onlineResolution.repositoryIssues, [])
        XCTAssertTrue(onlineResolution.capturedObjectKinds.contains(.manifest))
        XCTAssertTrue(onlineResolution.capturedObjectKinds.contains(.lastKnownGoodManifest))
        XCTAssertTrue(onlineResolution.capturedObjectKinds.contains(.pack))
        XCTAssertEqual(onlineResolution.remoteResolution.egressFindings, [])
        XCTAssertFalse(onlineResolution.coreLocalPlanningBlocked)

        let latestLookup = try XCTUnwrap(try repository.latestManifestLookup(packID: fixture.packID))
        let cachedManifest = try XCTUnwrap(try repository.loadManifest(latestLookup))
        let offlineResolution = await coordinator.resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.productionManifestRequest,
                targetPackID: fixture.packID,
                environment: "production",
                cachedManifest: cachedManifest,
                accessDecision: Self.access(
                    networkReachability: .offline,
                    cachedPublicArtifactAvailable: true,
                    bundledPublicArtifactAvailable: false
                ),
                query: SourceAtlasQuery(domainID: "occupation_foundation"),
                checkedAt: Self.checkedAt
            ),
            transport: SourceAtlasStaticPublicPackRemoteTransport(objectsByKey: [:]),
            repository: SourceAtlasPublicPackCacheFileRepository(rootDirectory: repository.rootDirectory)
        )

        XCTAssertTrue(offlineResolution.repositoryCachedPayloadUsed)
        XCTAssertEqual(offlineResolution.remoteResolution.transportIssues, [.remoteFetchSkipped])
        XCTAssertEqual(offlineResolution.remoteResolution.pipelineResolution.status, .usingLocalFallback)
        XCTAssertTrue(offlineResolution.remoteResolution.pipelineResolution.fetchIssues.contains(.manifestUnavailable))
        XCTAssertEqual(offlineResolution.remoteResolution.pipelineResolution.cacheResolution?.loadResult.selectedSource, .cached)
        XCTAssertEqual(offlineResolution.selectedPack?.id, fixture.packID)
        XCTAssertEqual(offlineResolution.selectedPack?.manifest.domainID, "occupation_foundation")
        XCTAssertEqual(offlineResolution.cacheCommitResult?.status, .recordedOnly)
        XCTAssertFalse(offlineResolution.persistedPackPayload)
        XCTAssertEqual(offlineResolution.repositoryIssues, [])
        XCTAssertEqual(offlineResolution.capturedObjectKinds, [])
        XCTAssertEqual(offlineResolution.remoteResolution.egressFindings, [])
        XCTAssertFalse(offlineResolution.coreLocalPlanningBlocked)
    }

    func testOnlineRemoteFetchPersistsAcceptedPackAndOfflineNoAccountUsesRepositoryCache() async throws {
        let fixture = try Self.remoteNativeFixture()
        let repository = try Self.repository()
        let coordinator = SourceAtlasPublicPackRepositoryBackedRemoteRefreshCoordinator()

        let onlineResolution = await coordinator.resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.sportsManifestRequest,
                targetPackID: fixture.pack.id,
                bundledPayload: try Self.payload(for: Self.pack(id: "pack.bundled"), source: .bundled),
                accessDecision: Self.access(
                    networkReachability: .online,
                    bundledPublicArtifactAvailable: true
                ),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            ),
            transport: SourceAtlasStaticPublicPackRemoteTransport(
                objectsByKey: [
                    fixture.currentPointerKey: fixture.pointerData,
                    fixture.manifestKey: fixture.manifestData,
                    fixture.packObjectKey: fixture.packData
                ]
            ),
            repository: repository
        )

        XCTAssertEqual(onlineResolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(onlineResolution.remoteResolution.pipelineResolution.status, .accepted)
        XCTAssertEqual(onlineResolution.remoteResolution.pipelineResolution.cacheResolution?.loadResult.selectedSource, .cached)
        XCTAssertEqual(onlineResolution.selectedPack?.id, fixture.pack.id)
        XCTAssertEqual(onlineResolution.cacheJournalRecord.status, .acceptedCurrent)
        XCTAssertTrue(onlineResolution.cacheJournalRecord.canPersistCurrentPack)
        XCTAssertEqual(onlineResolution.cacheCommitResult?.status, .persistedCurrent)
        XCTAssertTrue(onlineResolution.persistedPackPayload)
        XCTAssertEqual(onlineResolution.repositoryIssues, [])
        XCTAssertTrue(onlineResolution.capturedObjectKinds.contains(.manifest))
        XCTAssertTrue(onlineResolution.capturedObjectKinds.contains(.pack))
        XCTAssertEqual(onlineResolution.remoteResolution.egressFindings, [])
        XCTAssertFalse(onlineResolution.coreLocalPlanningBlocked)

        let cachedManifest = Self.cachedManifest(for: fixture)
        let offlineResolution = await coordinator.resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.sportsManifestRequest,
                targetPackID: fixture.pack.id,
                cachedManifest: cachedManifest,
                accessDecision: Self.access(
                    networkReachability: .offline,
                    cachedPublicArtifactAvailable: true,
                    bundledPublicArtifactAvailable: false
                ),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            ),
            transport: SourceAtlasStaticPublicPackRemoteTransport(objectsByKey: [:]),
            repository: SourceAtlasPublicPackCacheFileRepository(rootDirectory: repository.rootDirectory)
        )

        XCTAssertTrue(offlineResolution.repositoryCachedPayloadUsed)
        XCTAssertEqual(offlineResolution.remoteResolution.transportIssues, [.remoteFetchSkipped])
        XCTAssertEqual(offlineResolution.remoteResolution.pipelineResolution.status, .usingLocalFallback)
        XCTAssertTrue(offlineResolution.remoteResolution.pipelineResolution.fetchIssues.contains(.manifestUnavailable))
        XCTAssertEqual(offlineResolution.remoteResolution.pipelineResolution.cacheResolution?.loadResult.selectedSource, .cached)
        XCTAssertEqual(offlineResolution.selectedPack?.id, fixture.pack.id)
        XCTAssertEqual(offlineResolution.cacheCommitResult?.status, .recordedOnly)
        XCTAssertFalse(offlineResolution.persistedPackPayload)
        XCTAssertEqual(offlineResolution.repositoryIssues, [])
        XCTAssertEqual(offlineResolution.capturedObjectKinds, [])
        XCTAssertEqual(offlineResolution.remoteResolution.egressFindings, [])
        XCTAssertFalse(offlineResolution.coreLocalPlanningBlocked)
    }

    func testPrivateManifestRequestDoesNotPersistPackPayload() async throws {
        let repository = try Self.repository()
        let unsafeRequest = SourceAtlasPublicManifestRequest(
            domainID: "goal_text",
            channel: "stable",
            schemaVersion: "1.0.0",
            appVersion: "1.0"
        )

        let resolution = await SourceAtlasPublicPackRepositoryBackedRemoteRefreshCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: unsafeRequest,
                targetPackID: "public-pack",
                accessDecision: Self.access(networkReachability: .online),
                checkedAt: Self.checkedAt
            ),
            transport: SourceAtlasStaticPublicPackRemoteTransport(objectsByKey: [:]),
            repository: repository
        )

        XCTAssertEqual(resolution.remoteResolution.transportIssues, [.unsafeManifestRequest, .privateEgressFinding])
        XCTAssertEqual(resolution.remoteResolution.pipelineResolution.status, .quarantined)
        XCTAssertEqual(resolution.capturedObjectKinds, [])
        XCTAssertEqual(resolution.cacheJournalRecord.status, .rejected)
        XCTAssertFalse(resolution.cacheJournalRecord.canPersistCurrentPack)
        XCTAssertEqual(resolution.cacheCommitResult?.status, .rejected)
        XCTAssertFalse(resolution.persistedPackPayload)
        XCTAssertTrue(resolution.remoteResolution.egressFindings.isEmpty == false)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testHashMismatchedRemotePackBytesRecordOnlyAndDoNotPersistCurrentPayload() async throws {
        let fixture = try Self.remoteNativeFixture()
        let repository = try Self.repository()
        let wrongPackData = Data("not the declared public pack".utf8)

        let resolution = await SourceAtlasPublicPackRepositoryBackedRemoteRefreshCoordinator().resolve(
            SourceAtlasPublicPackRemoteFetchInput(
                manifestRequest: Self.sportsManifestRequest,
                targetPackID: fixture.pack.id,
                accessDecision: Self.access(networkReachability: .online),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            ),
            transport: SourceAtlasStaticPublicPackRemoteTransport(
                objectsByKey: [
                    fixture.currentPointerKey: fixture.pointerData,
                    fixture.manifestKey: fixture.manifestData,
                    fixture.packObjectKey: wrongPackData
                ]
            ),
            repository: repository
        )

        XCTAssertEqual(resolution.remoteResolution.transportIssues, [])
        XCTAssertEqual(resolution.remoteResolution.pipelineResolution.status, .unavailable)
        XCTAssertTrue(resolution.cacheJournalRecord.issues.contains(.downloadedPackHashMismatch))
        XCTAssertFalse(resolution.cacheJournalRecord.canPersistCurrentPack)
        XCTAssertEqual(resolution.cacheCommitResult?.status, .recordedOnly)
        XCTAssertFalse(resolution.persistedPackPayload)
        XCTAssertEqual(resolution.repositoryIssues, [])
        XCTAssertTrue(resolution.capturedObjectKinds.contains(.pack))
        XCTAssertNil(
            try repository.loadPayload(
                SourceAtlasPublicPackCachePayloadLookup(
                    packID: fixture.pack.id,
                    manifestVersionID: fixture.manifestKey,
                    declaredSHA256: fixture.packSHA256
                )
            )
        )
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }
}

private extension SourceAtlasPublicPackRepositoryBackedRemoteRefreshTests {
    struct RemoteNativeFixture {
        let currentPointerKey: String
        let manifestKey: String
        let packObjectKey: String
        let pack: SourceAtlasPack
        let packSHA256: String
        let pointerData: Data
        let manifestData: Data
        let packData: Data
    }

    struct ProductionR2Fixture {
        let currentPointerKey: String
        let revocationsKey: String
        let manifestKey: String
        let lkgKey: String
        let packObjectKey: String
        let packID: String
        let currentPointerData: Data
        let revocationData: Data
        let manifestData: Data
        let lkgData: Data
        let packData: Data
    }

    static let checkedAt = Date(timeIntervalSince1970: 1_780_100_000)
    static let productionManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "occupation_foundation",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let sportsManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "sports",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )

    static func repository() throws -> SourceAtlasPublicPackCacheFileRepository {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("source-atlas-repository-backed-refresh-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return SourceAtlasPublicPackCacheFileRepository(rootDirectory: root)
    }

    static func productionR2Train29Fixture() throws -> ProductionR2Fixture {
        let root = repoRoot()
        let packRoot = root.appendingPathComponent("tools/source-atlas/generated/pack-production/train-28-stable-approval-gate")
        let publisherRoot = root.appendingPathComponent("tools/source-atlas/generated/r2-publisher/train-29-production-remote-r2")

        return ProductionR2Fixture(
            currentPointerKey: "source-atlas/v1/production/stable/occupation_foundation/current.json",
            revocationsKey: "source-atlas/v1/production/stable/occupation_foundation/revocations.json",
            manifestKey: "source-atlas/v1/production/stable/occupation_foundation/20260628T000000Z/manifest.json",
            lkgKey: "source-atlas/v1/production/stable/occupation_foundation/lkg.json",
            packObjectKey: "source-atlas/v1/production/stable/occupation_foundation/20260628T000000Z/pack.json",
            packID: "source-atlas/v1/domain/occupation_foundation/20260628T000000Z",
            currentPointerData: try Data(contentsOf: publisherRoot.appendingPathComponent("current-pointer.json")),
            revocationData: try Data(contentsOf: packRoot.appendingPathComponent("revocations.json")),
            manifestData: try Data(contentsOf: packRoot.appendingPathComponent("manifest.json")),
            lkgData: try Data(contentsOf: packRoot.appendingPathComponent("lkg.json")),
            packData: try Data(contentsOf: packRoot.appendingPathComponent("pack.json"))
        )
    }

    static func remoteNativeFixture() throws -> RemoteNativeFixture {
        let currentPointerKey = "source-atlas/v1/staging/stable/sports/current.json"
        let manifestKey = "source-atlas/v1/staging/stable/sports/20260627T000000Z/manifest.json"
        let packObjectKey = "source-atlas/v1/staging/stable/sports/20260627T000000Z/pack.json"
        let pack = pack(id: "source-atlas/v1/domain/sports/20260627T000000Z")
        let packData = try encoded(pack)
        let packSHA256 = SourceAtlasStore.sha256Hex(for: packData)
        let manifestData = publishedManifestData(
            packID: pack.id,
            packObjectKey: packObjectKey,
            packSHA256: packSHA256
        )
        let pointerData = publishedPointerData(
            packID: pack.id,
            manifestKey: manifestKey,
            manifestSHA256: SourceAtlasStore.sha256Hex(for: manifestData),
            packSHA256: packSHA256
        )
        return RemoteNativeFixture(
            currentPointerKey: currentPointerKey,
            manifestKey: manifestKey,
            packObjectKey: packObjectKey,
            pack: pack,
            packSHA256: packSHA256,
            pointerData: pointerData,
            manifestData: manifestData,
            packData: packData
        )
    }

    static func cachedManifest(for fixture: RemoteNativeFixture) -> SourceAtlasFreshnessManifest {
        SourceAtlasFreshnessManifest(
            schemaVersion: 1,
            versionID: fixture.manifestKey,
            publishedAt: checkedAt,
            packIndex: [
                SourceAtlasFreshnessPackEntry(
                    packID: fixture.pack.id,
                    currentSHA256: fixture.packSHA256,
                    currentSignature: "repository-backed-refresh"
                )
            ]
        )
    }

    static func publishedPointerData(
        packID: String,
        manifestKey: String,
        manifestSHA256: String,
        packSHA256: String
    ) -> Data {
        Data(
            """
            {
              "schemaVersion": 1,
              "kind": "ambitions.sourceAtlas.currentPackPointer.v1",
              "createdAt": "2026-06-27T00:00:00Z",
              "environment": "staging",
              "channel": "stable",
              "packID": "\(packID)",
              "packVersion": "20260627T000000Z",
              "manifestKey": "\(manifestKey)",
              "manifestSHA256": "\(manifestSHA256)",
              "packSHA256": "\(packSHA256)",
              "revocationManifestKey": null,
              "lastKnownGoodKey": null,
              "publicReferenceOnly": true,
              "dataClass": "public_freshness",
              "privacyBoundary": "public/reference/freshness only",
              "nonClaims": [
                "not a final user plan, schedule, or Step generator"
              ]
            }
            """.utf8
        )
    }

    static func publishedManifestData(
        packID: String,
        packObjectKey: String,
        packSHA256: String
    ) -> Data {
        Data(
            """
            {
              "kind": "ambitions.sourceAtlas.packManifest.v1",
              "schema_version": "1.0.0",
              "manifest_id": "source_atlas_pack_manifest.repository_backed_refresh_test",
              "pack_id": "\(packID)",
              "created_at": "2026-06-27T00:00:00Z",
              "object_keys": {
                "pack": "\(packObjectKey)"
              },
              "sha256": "\(packSHA256)",
              "freshness_status": "current",
              "publicReferenceOnly": true
            }
            """.utf8
        )
    }

    static func access(
        networkReachability: SourceAtlasNetworkReachability,
        cachedPublicArtifactAvailable: Bool = false,
        bundledPublicArtifactAvailable: Bool = true
    ) -> SourceAtlasAccessDecision {
        SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: networkReachability,
                cachedPublicArtifactAvailable: cachedPublicArtifactAvailable,
                bundledPublicArtifactAvailable: bundledPublicArtifactAvailable
            )
        )
    }

    static func payload(
        for pack: SourceAtlasPack,
        source: SourceAtlasStorePayloadSource
    ) throws -> SourceAtlasStorePayload {
        let data = try encoded(pack)
        return SourceAtlasStorePayload(
            source: source,
            data: data,
            declaredSHA256: SourceAtlasStore.sha256Hex(for: data)
        )
    }

    static func encoded<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
    }

    static func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("tools/source-atlas/generated/pack-production/train-28-stable-approval-gate/pack.json")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }

    static func pack(id: String) -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: id,
                title: "Public Sports Pack",
                kind: .domainPack,
                version: "1.0.0",
                domainID: "sports"
            ),
            sources: [
                SourceAtlasSourceRecord(
                    id: "source.official",
                    title: "Official rules",
                    kind: .official,
                    locator: "https://example.test/rules",
                    retrievedAt: "2026-06-01T12:00:00Z",
                    contentHash: "hash",
                    approvedForOfficialClaims: true
                )
            ],
            claims: [
                SourceAtlasClaim(
                    id: "claim.current",
                    text: "The public rule is current.",
                    state: .official,
                    freshness: .current,
                    riskClass: .sportRules,
                    sourceIDs: ["source.official"],
                    reviewRequired: false
                )
            ],
            requirements: [
                SourceAtlasRequirement(
                    id: "requirement.current",
                    claimID: "claim.current",
                    title: "Use current public rule",
                    kind: .hard,
                    required: true,
                    sourceState: .officialCurrent,
                    freshnessState: .current,
                    riskState: .low,
                    reviewState: .approved
                )
            ],
            starterItems: [
                SourceAtlasStarterItem(
                    id: "starter.current",
                    title: "Review public rule",
                    stepCandidateSeed: "Review the public rule.",
                    storesFinalSchedule: false
                )
            ],
            proofMap: [
                SourceAtlasProofMapEntry(
                    id: "proof.requirement.current",
                    requirementID: "requirement.current",
                    proofDescription: "Public source proof.",
                    privacyClass: .externalRedacted,
                    proofCandidate: .sourceEvidence,
                    proofStrength: .officialCertified,
                    capabilityNodeID: "sports.public.rules",
                    sourceRecordIDs: ["source.official"],
                    sourceClaimIDs: ["claim.current"]
                )
            ],
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection.current",
                    goalIntent: "sports",
                    requiredPackIDs: [id],
                    projectionProfiles: []
                )
            ],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Context needed.",
                reviewRequired: "Review required.",
                notProfessionalAdvice: "Planning support only."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["node.current"],
                overlayDependencyIDs: ["overlay.current"],
                projectionRecipeIDs: ["projection.current"],
                ownsIndividualGoalPhrase: false
            )
        )
    }
}
