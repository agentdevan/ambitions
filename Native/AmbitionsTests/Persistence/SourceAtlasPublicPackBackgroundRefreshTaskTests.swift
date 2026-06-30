import XCTest
@testable import Ambitions

final class SourceAtlasPublicPackBackgroundRefreshTaskTests: XCTestCase {
    func testOfflineNoAccountBackgroundTaskUsesCachedPublicPackWithoutTransport() async throws {
        let fixture = try Self.remoteNativeFixture()
        let repository = try Self.seededRepository(fixture: fixture)
        let transport = SourceAtlasCountingPublicPackRemoteTransport(objectsByKey: [:])

        let resolution = await SourceAtlasPublicPackBackgroundRefreshTask().run(
            SourceAtlasPublicPackBackgroundRefreshTaskRequest(
                domainID: "sports",
                channel: "stable",
                schemaVersion: "1.0.0",
                appVersion: "1.0",
                publicLocale: "en-US",
                targetPackID: fixture.pack.id,
                cachedManifestLookup: SourceAtlasPublicPackCacheManifestLookup(
                    packID: fixture.pack.id,
                    manifestVersionID: fixture.manifestKey,
                    declaredPackSHA256: fixture.packSHA256
                ),
                networkReachability: .offline,
                checkedAt: Self.checkedAt
            ),
            transport: transport,
            repository: repository
        )

        XCTAssertEqual(resolution.taskIdentifier, SourceAtlasPublicPackBackgroundRefreshTaskIdentifier.publicPackRefresh)
        XCTAssertEqual(resolution.taskIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.manifestRequest.domainID, "sports")
        XCTAssertEqual(resolution.manifestRequest.publicLocale, "en-US")
        XCTAssertEqual(resolution.appRefreshResolution?.mode, .background)
        XCTAssertEqual(resolution.appRefreshResolution?.accessDecision.route, .cachedPublic)
        XCTAssertEqual(resolution.appRefreshResolution?.refreshResolution.remoteResolution.transportIssues, [.remoteFetchSkipped])
        XCTAssertEqual(resolution.appRefreshResolution?.refreshResolution.remoteResolution.objectRequests, [])
        XCTAssertEqual(resolution.selectedPack?.id, fixture.pack.id)
        let requestCount = await transport.requestCount()
        XCTAssertEqual(requestCount, 0)
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testOfflineNoAccountBackgroundTaskDiscoversLatestCachedPublicPackWithoutExplicitLookup() async throws {
        let fixture = try Self.remoteNativeFixture()
        let repository = try Self.seededRepository(fixture: fixture)
        let transport = SourceAtlasCountingPublicPackRemoteTransport(objectsByKey: [:])

        let resolution = await SourceAtlasPublicPackBackgroundRefreshTask().run(
            SourceAtlasPublicPackBackgroundRefreshTaskRequest(
                domainID: "sports",
                channel: "stable",
                schemaVersion: "1.0.0",
                appVersion: "1.0",
                targetPackID: fixture.pack.id,
                networkReachability: .offline,
                checkedAt: Self.checkedAt
            ),
            transport: transport,
            repository: repository
        )

        XCTAssertEqual(resolution.taskIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.appRefreshResolution?.mode, .background)
        XCTAssertEqual(resolution.appRefreshResolution?.accessDecision.route, .cachedPublic)
        XCTAssertTrue(resolution.appRefreshResolution?.cachedManifestLoadedFromRepository == true)
        XCTAssertTrue(resolution.appRefreshResolution?.cachedPayloadLoadedFromRepository == true)
        XCTAssertEqual(resolution.appRefreshResolution?.refreshResolution.remoteResolution.transportIssues, [.remoteFetchSkipped])
        XCTAssertEqual(resolution.selectedPack?.id, fixture.pack.id)
        let requestCount = await transport.requestCount()
        XCTAssertEqual(requestCount, 0)
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testOnlineBackgroundTaskDelegatesToVerifiedRemoteRefreshAndPersistsPack() async throws {
        let fixture = try Self.remoteNativeFixture()
        let repository = try Self.repository()
        let transport = SourceAtlasCountingPublicPackRemoteTransport(
            objectsByKey: [
                fixture.currentPointerKey: fixture.pointerData,
                fixture.manifestKey: fixture.manifestData,
                fixture.packObjectKey: fixture.packData,
            ]
        )

        let resolution = await SourceAtlasPublicPackBackgroundRefreshTask().run(
            SourceAtlasPublicPackBackgroundRefreshTaskRequest(
                domainID: "sports",
                channel: "stable",
                schemaVersion: "1.0.0",
                appVersion: "1.0",
                targetPackID: fixture.pack.id,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            ),
            transport: transport,
            repository: repository
        )

        XCTAssertEqual(resolution.taskIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(
            resolution.appRefreshResolution?.refreshResolution.remoteResolution.objectRequests.map(\.objectKey),
            [fixture.currentPointerKey, fixture.manifestKey, fixture.packObjectKey]
        )
        XCTAssertEqual(resolution.appRefreshResolution?.refreshResolution.remoteResolution.pipelineResolution.status, .accepted)
        XCTAssertEqual(resolution.appRefreshResolution?.refreshResolution.cacheCommitResult?.status, .persistedCurrent)
        XCTAssertTrue(resolution.appRefreshResolution?.persistedPackPayload == true)
        XCTAssertEqual(resolution.selectedPack?.id, fixture.pack.id)
        let requestCount = await transport.requestCount()
        XCTAssertEqual(requestCount, 3)
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testUnsafeTaskIdentifierStopsBeforeTransportOrPersistence() async throws {
        let fixture = try Self.remoteNativeFixture()
        let repository = try Self.repository()
        let transport = SourceAtlasCountingPublicPackRemoteTransport(
            objectsByKey: [
                fixture.currentPointerKey: fixture.pointerData,
                fixture.manifestKey: fixture.manifestData,
                fixture.packObjectKey: fixture.packData,
            ]
        )

        let resolution = await SourceAtlasPublicPackBackgroundRefreshTask().run(
            SourceAtlasPublicPackBackgroundRefreshTaskRequest(
                taskIdentifier: "com.ambitions.source-atlas.user_id.goal_text-refresh",
                domainID: "sports",
                channel: "stable",
                schemaVersion: "1.0.0",
                appVersion: "1.0",
                targetPackID: fixture.pack.id,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            ),
            transport: transport,
            repository: repository
        )

        XCTAssertEqual(resolution.taskIssues, [.unsafeTaskIdentifier, .privateTaskMetadata])
        XCTAssertEqual(Set(resolution.egressFindings.map(\.forbiddenToken)), ["goal_text", "user_id"])
        XCTAssertNil(resolution.appRefreshResolution)
        XCTAssertNil(resolution.selectedPack)
        let requestCount = await transport.requestCount()
        XCTAssertEqual(requestCount, 0)
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.scheduledHiddenRuntimeMutation)
        XCTAssertFalse(resolution.generatedFinalPlan)
        XCTAssertFalse(resolution.generatedFinalSchedule)
        XCTAssertFalse(resolution.generatedStepList)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testPrivateManifestMetadataStopsBeforeTransportOrPersistence() async throws {
        let fixture = try Self.remoteNativeFixture()
        let repository = try Self.repository()
        let transport = SourceAtlasCountingPublicPackRemoteTransport(
            objectsByKey: [
                fixture.currentPointerKey: fixture.pointerData,
                fixture.manifestKey: fixture.manifestData,
                fixture.packObjectKey: fixture.packData,
            ]
        )

        let resolution = await SourceAtlasPublicPackBackgroundRefreshTask().run(
            SourceAtlasPublicPackBackgroundRefreshTaskRequest(
                domainID: "goal_text",
                channel: "stable",
                schemaVersion: "1.0.0",
                appVersion: "1.0",
                targetPackID: fixture.pack.id,
                networkReachability: .online,
                checkedAt: Self.checkedAt
            ),
            transport: transport,
            repository: repository
        )

        XCTAssertEqual(resolution.taskIssues, [.privateTaskMetadata, .unsafeManifestRequest])
        XCTAssertEqual(Set(resolution.egressFindings.map(\.forbiddenToken)), ["goal_text"])
        XCTAssertNil(resolution.appRefreshResolution)
        XCTAssertNil(resolution.selectedPack)
        let requestCount = await transport.requestCount()
        XCTAssertEqual(requestCount, 0)
        XCTAssertFalse(resolution.sentPrivateRuntimeContext)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testPrivateTargetPackMetadataStopsBeforeTransportOrPersistence() async throws {
        let fixture = try Self.remoteNativeFixture()
        let repository = try Self.repository()
        let transport = SourceAtlasCountingPublicPackRemoteTransport(
            objectsByKey: [
                fixture.currentPointerKey: fixture.pointerData,
                fixture.manifestKey: fixture.manifestData,
                fixture.packObjectKey: fixture.packData,
            ]
        )

        let resolution = await SourceAtlasPublicPackBackgroundRefreshTask().run(
            SourceAtlasPublicPackBackgroundRefreshTaskRequest(
                domainID: "sports",
                channel: "stable",
                schemaVersion: "1.0.0",
                appVersion: "1.0",
                targetPackID: "source-atlas/v1/user_id/private-goal",
                networkReachability: .online,
                checkedAt: Self.checkedAt
            ),
            transport: transport,
            repository: repository
        )

        XCTAssertEqual(resolution.taskIssues, [.privateTaskMetadata])
        XCTAssertEqual(Set(resolution.egressFindings.map(\.forbiddenToken)), ["user_id"])
        XCTAssertNil(resolution.appRefreshResolution)
        let requestCount = await transport.requestCount()
        XCTAssertEqual(requestCount, 0)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }
}

private actor SourceAtlasCountingPublicPackRemoteTransport: SourceAtlasPublicPackRemoteTransport {
    private let objectsByKey: [String: Data]
    private var requests: [SourceAtlasPublicPackRemoteObjectRequest] = []

    init(objectsByKey: [String: Data]) {
        self.objectsByKey = objectsByKey
    }

    func fetch(_ request: SourceAtlasPublicPackRemoteObjectRequest) async throws -> Data {
        requests.append(request)
        guard let data = objectsByKey[request.objectKey] else {
            throw SourceAtlasPublicPackRemoteTransportError.missingObject(request.objectKey)
        }
        return data
    }

    func requestCount() -> Int {
        requests.count
    }
}

private extension SourceAtlasPublicPackBackgroundRefreshTaskTests {
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

    static let checkedAt = Date(timeIntervalSince1970: 1_780_100_000)
    static let sportsManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "sports",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )

    static func repository() throws -> SourceAtlasPublicPackCacheFileRepository {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("source-atlas-background-refresh-task-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return SourceAtlasPublicPackCacheFileRepository(rootDirectory: root)
    }

    static func seededRepository(fixture: RemoteNativeFixture) throws -> SourceAtlasPublicPackCacheFileRepository {
        let repository = try repository()
        let onlineResolution = SourceAtlasPublicPackFetchPipeline().resolve(
            SourceAtlasPublicPackFetchInput(
                manifestRequest: sportsManifestRequest,
                targetPackID: fixture.pack.id,
                fetchedCurrentPointerData: fixture.pointerData,
                fetchedManifestData: fixture.manifestData,
                downloadedPackData: fixture.packData,
                accessDecision: access(networkReachability: .online),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: checkedAt
            )
        )
        let journalRecord = SourceAtlasPublicPackCacheJournal().record(
            SourceAtlasPublicPackCacheJournalInput(
                manifestRequest: sportsManifestRequest,
                targetPackID: fixture.pack.id,
                objectRequests: [
                    SourceAtlasPublicPackRemoteObjectRequest(
                        kind: .manifest,
                        objectKey: fixture.manifestKey
                    ),
                    SourceAtlasPublicPackRemoteObjectRequest(
                        kind: .pack,
                        objectKey: fixture.packObjectKey
                    ),
                ],
                fetchResolution: onlineResolution,
                fetchedManifestData: fixture.manifestData,
                downloadedPackData: fixture.packData,
                committedAt: checkedAt
            )
        )
        let result = try repository.commit(
            SourceAtlasPublicPackCacheRepositoryCommitInput(
                journalRecord: journalRecord,
                manifestData: fixture.manifestData,
                packData: fixture.packData
            )
        )
        XCTAssertEqual(result.status, .persistedCurrent)
        return repository
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
              "manifest_id": "source_atlas_pack_manifest.background_refresh_test",
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

    static func access(networkReachability: SourceAtlasNetworkReachability) -> SourceAtlasAccessDecision {
        SourceAtlasBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: networkReachability,
                cachedPublicArtifactAvailable: false,
                bundledPublicArtifactAvailable: false
            )
        )
    }

    static func encoded<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(value)
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
                ),
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
                ),
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
                ),
            ],
            starterItems: [
                SourceAtlasStarterItem(
                    id: "starter.current",
                    title: "Review public rule",
                    stepCandidateSeed: "Review the public rule.",
                    storesFinalSchedule: false
                ),
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
                ),
            ],
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection.current",
                    goalIntent: "sports",
                    requiredPackIDs: [id],
                    projectionProfiles: []
                ),
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
