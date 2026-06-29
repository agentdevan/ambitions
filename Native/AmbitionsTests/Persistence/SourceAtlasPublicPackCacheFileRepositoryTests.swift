import XCTest
@testable import Ambitions

final class SourceAtlasPublicPackCacheFileRepositoryTests: XCTestCase {
    func testAcceptedJournalPersistsVerifiedPackAndLoadsCachedPayload() throws {
        let fixture = try Self.fixture()
        let journalRecord = try Self.acceptedJournalRecord(fixture: fixture)
        let repository = try Self.repository()

        let result = try repository.commit(
            SourceAtlasPublicPackCacheRepositoryCommitInput(
                journalRecord: journalRecord,
                manifestData: fixture.manifestData,
                packData: fixture.packData
            )
        )

        XCTAssertEqual(result.status, .persistedCurrent)
        XCTAssertTrue(result.persistedPackPayload)
        XCTAssertEqual(result.issues, [])
        XCTAssertEqual(result.egressFindings, [])
        XCTAssertEqual(Set(result.storedArtifacts.map(\.kind)), [.manifest, .pack])
        XCTAssertTrue(result.storedArtifacts.allSatisfy { artifact in
            artifact.relativePath.contains(fixture.pack.id) == false &&
                artifact.relativePath.contains("goal") == false &&
                artifact.sha256 == artifact.readbackSHA256
        })
        XCTAssertNotNil(result.journalRelativePath)
        XCTAssertNotNil(result.packIndexRelativePath)

        let reloadedRepository = SourceAtlasPublicPackCacheFileRepository(rootDirectory: repository.rootDirectory)
        let payload = try reloadedRepository.loadPayload(
            SourceAtlasPublicPackCachePayloadLookup(
                packID: fixture.pack.id,
                manifestVersionID: fixture.manifest.versionID,
                declaredSHA256: fixture.entry.currentSHA256
            )
        )

        XCTAssertEqual(payload?.source, .cached)
        XCTAssertEqual(payload?.declaredSHA256, fixture.entry.currentSHA256)
        XCTAssertEqual(payload?.data, fixture.packData)

        let manifest = try reloadedRepository.loadManifest(
            SourceAtlasPublicPackCacheManifestLookup(
                packID: fixture.pack.id,
                manifestVersionID: fixture.manifest.versionID,
                declaredPackSHA256: fixture.entry.currentSHA256
            )
        )
        XCTAssertEqual(manifest, fixture.manifest)
    }

    func testLatestManifestLookupReturnsLatestVerifiedPublicIndexForPackID() throws {
        let repository = try Self.repository()
        let olderFixture = try Self.fixture(
            packVersion: "1.0.0",
            manifestVersionID: "manifest.older",
            publishedAt: Self.checkedAt.addingTimeInterval(-3_600)
        )
        let newerFixture = try Self.fixture(
            packVersion: "2.0.0",
            manifestVersionID: "manifest.newer",
            publishedAt: Self.checkedAt
        )

        _ = try repository.commit(
            SourceAtlasPublicPackCacheRepositoryCommitInput(
                journalRecord: try Self.acceptedJournalRecord(
                    fixture: olderFixture,
                    committedAt: Self.checkedAt.addingTimeInterval(-3_600)
                ),
                manifestData: olderFixture.manifestData,
                packData: olderFixture.packData
            )
        )
        _ = try repository.commit(
            SourceAtlasPublicPackCacheRepositoryCommitInput(
                journalRecord: try Self.acceptedJournalRecord(fixture: newerFixture),
                manifestData: newerFixture.manifestData,
                packData: newerFixture.packData
            )
        )

        let lookup = try repository.latestManifestLookup(packID: newerFixture.pack.id)

        XCTAssertEqual(lookup?.packID, newerFixture.pack.id)
        XCTAssertEqual(lookup?.manifestVersionID, newerFixture.manifest.versionID)
        XCTAssertEqual(lookup?.declaredPackSHA256, newerFixture.entry.currentSHA256)
        XCTAssertEqual(try repository.loadManifest(try XCTUnwrap(lookup)), newerFixture.manifest)
    }

    func testLatestManifestLookupRejectsPrivatePackIDWithoutReturningCacheMetadata() throws {
        let fixture = try Self.fixture()
        let repository = try Self.repository()
        _ = try repository.commit(
            SourceAtlasPublicPackCacheRepositoryCommitInput(
                journalRecord: try Self.acceptedJournalRecord(fixture: fixture),
                manifestData: fixture.manifestData,
                packData: fixture.packData
            )
        )

        let lookup = try repository.latestManifestLookup(packID: "source-atlas/v1/user_id/private-goal")

        XCTAssertNil(lookup)
    }

    func testHashMismatchJournalRecordsOnlyAndDoesNotPersistPackPayload() throws {
        let fixture = try Self.fixture()
        let journalRecord = try Self.hashMismatchJournalRecord(fixture: fixture)
        let repository = try Self.repository()

        let result = try repository.commit(
            SourceAtlasPublicPackCacheRepositoryCommitInput(
                journalRecord: journalRecord,
                manifestData: fixture.manifestData,
                packData: Data("not the declared pack".utf8)
            )
        )

        XCTAssertEqual(result.status, .recordedOnly)
        XCTAssertFalse(result.persistedPackPayload)
        XCTAssertEqual(result.storedArtifacts, [])
        XCTAssertNotNil(result.journalRelativePath)
        XCTAssertNil(result.packIndexRelativePath)

        let payload = try repository.loadPayload(
            SourceAtlasPublicPackCachePayloadLookup(
                packID: fixture.pack.id,
                manifestVersionID: fixture.manifest.versionID,
                declaredSHA256: fixture.entry.currentSHA256
            )
        )
        XCTAssertNil(payload)
        XCTAssertNil(
            try repository.loadManifest(
                SourceAtlasPublicPackCacheManifestLookup(
                    packID: fixture.pack.id,
                    manifestVersionID: fixture.manifest.versionID,
                    declaredPackSHA256: fixture.entry.currentSHA256
                )
            )
        )
    }

    func testPrivateObjectKeyJournalIsRejectedWithoutWritingArtifactsOrJournal() throws {
        let fixture = try Self.fixture()
        let journalRecord = try Self.privateObjectKeyJournalRecord(fixture: fixture)
        let repository = try Self.repository()

        let result = try repository.commit(
            SourceAtlasPublicPackCacheRepositoryCommitInput(
                journalRecord: journalRecord,
                manifestData: fixture.manifestData,
                packData: fixture.packData
            )
        )

        XCTAssertEqual(result.status, .rejected)
        XCTAssertFalse(result.persistedPackPayload)
        XCTAssertTrue(result.issues.contains(.unsafeJournalRecord))
        XCTAssertEqual(result.storedArtifacts, [])
        XCTAssertNil(result.journalRelativePath)
        XCTAssertNil(result.packIndexRelativePath)
        XCTAssertTrue(result.egressFindings.contains { $0.forbiddenToken == "account_id" })
    }

    func testAcceptedJournalWithWrongPackBytesWritesJournalOnlyAfterHashCheck() throws {
        let fixture = try Self.fixture()
        let journalRecord = try Self.acceptedJournalRecord(fixture: fixture)
        let repository = try Self.repository()

        let result = try repository.commit(
            SourceAtlasPublicPackCacheRepositoryCommitInput(
                journalRecord: journalRecord,
                manifestData: fixture.manifestData,
                packData: Data("wrong public pack data".utf8)
            )
        )

        XCTAssertEqual(result.status, .recordedOnly)
        XCTAssertTrue(result.issues.contains(.packDataHashMismatch))
        XCTAssertEqual(result.storedArtifacts, [])
        XCTAssertNotNil(result.journalRelativePath)
        XCTAssertNil(result.packIndexRelativePath)
        XCTAssertNil(
            try repository.loadPayload(
                SourceAtlasPublicPackCachePayloadLookup(
                    packID: fixture.pack.id,
                    manifestVersionID: fixture.manifest.versionID,
                    declaredSHA256: fixture.entry.currentSHA256
                )
            )
        )
        XCTAssertNil(
            try repository.loadManifest(
                SourceAtlasPublicPackCacheManifestLookup(
                    packID: fixture.pack.id,
                    manifestVersionID: fixture.manifest.versionID,
                    declaredPackSHA256: fixture.entry.currentSHA256
                )
            )
        )
    }

    func testPrivateLookupDoesNotResolveCachedPayload() throws {
        let fixture = try Self.fixture()
        let journalRecord = try Self.acceptedJournalRecord(fixture: fixture)
        let repository = try Self.repository()
        _ = try repository.commit(
            SourceAtlasPublicPackCacheRepositoryCommitInput(
                journalRecord: journalRecord,
                manifestData: fixture.manifestData,
                packData: fixture.packData
            )
        )

        let payload = try repository.loadPayload(
            SourceAtlasPublicPackCachePayloadLookup(
                packID: "source-atlas/v1/user_id/private-goal",
                manifestVersionID: fixture.manifest.versionID,
                declaredSHA256: fixture.entry.currentSHA256
            )
        )

        XCTAssertNil(payload)
        XCTAssertNil(
            try repository.loadManifest(
                SourceAtlasPublicPackCacheManifestLookup(
                    packID: "source-atlas/v1/user_id/private-goal",
                    manifestVersionID: fixture.manifest.versionID,
                    declaredPackSHA256: fixture.entry.currentSHA256
                )
            )
        )
    }

    func testAcceptedJournalWithWrongManifestBytesWritesJournalOnlyAfterHashCheck() throws {
        let fixture = try Self.fixture()
        let journalRecord = try Self.acceptedJournalRecord(fixture: fixture)
        let repository = try Self.repository()

        let result = try repository.commit(
            SourceAtlasPublicPackCacheRepositoryCommitInput(
                journalRecord: journalRecord,
                manifestData: Data("wrong public manifest data".utf8),
                packData: fixture.packData
            )
        )

        XCTAssertEqual(result.status, .recordedOnly)
        XCTAssertTrue(result.issues.contains(.manifestDataHashMismatch))
        XCTAssertTrue(result.storedArtifacts.contains { $0.kind == .pack })
        XCTAssertNil(result.packIndexRelativePath)
        XCTAssertNil(
            try repository.loadManifest(
                SourceAtlasPublicPackCacheManifestLookup(
                    packID: fixture.pack.id,
                    manifestVersionID: fixture.manifest.versionID,
                    declaredPackSHA256: fixture.entry.currentSHA256
                )
            )
        )
    }

    func testPublishedManifestReadbackBridgesToNativeFreshnessManifest() throws {
        let fixture = try Self.publishedFixture()
        let repository = try Self.repository()

        let result = try repository.commit(
            SourceAtlasPublicPackCacheRepositoryCommitInput(
                journalRecord: fixture.journalRecord,
                manifestData: fixture.publishedManifestData,
                packData: fixture.packData
            )
        )

        XCTAssertEqual(result.status, .persistedCurrent)
        XCTAssertTrue(result.persistedPackPayload)

        let manifest = try repository.loadManifest(
            SourceAtlasPublicPackCacheManifestLookup(
                packID: fixture.pack.id,
                manifestVersionID: fixture.manifestVersionID,
                declaredPackSHA256: fixture.packSHA256
            )
        )

        XCTAssertEqual(manifest?.versionID, fixture.manifestVersionID)
        XCTAssertEqual(manifest?.packIndex.first?.packID, fixture.pack.id)
        XCTAssertEqual(manifest?.packIndex.first?.currentSHA256, fixture.packSHA256)
        XCTAssertEqual(manifest?.packIndex.first?.currentSignature, "publisher-pointer:\(fixture.publishedManifestSHA256)")
    }
}

private extension SourceAtlasPublicPackCacheFileRepositoryTests {
    struct Fixture {
        let pack: SourceAtlasPack
        let entry: SourceAtlasFreshnessPackEntry
        let manifest: SourceAtlasFreshnessManifest
        let manifestData: Data
        let packData: Data
    }

    struct PublishedFixture {
        let pack: SourceAtlasPack
        let journalRecord: SourceAtlasPublicPackCacheJournalRecord
        let manifestVersionID: String
        let packSHA256: String
        let publishedManifestSHA256: String
        let publishedManifestData: Data
        let packData: Data
    }

    static let checkedAt = Date(timeIntervalSince1970: 1_780_100_000)
    static let manifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "sports",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )

    static func repository() throws -> SourceAtlasPublicPackCacheFileRepository {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("source-atlas-cache-repository-tests", isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return SourceAtlasPublicPackCacheFileRepository(rootDirectory: root)
    }

    static func fixture(
        packVersion: String = "1.0.0",
        manifestVersionID: String = "manifest.v1",
        publishedAt: Date = Date(timeIntervalSince1970: 1_780_100_000)
    ) throws -> Fixture {
        let pack = Self.pack(version: packVersion)
        let entry = try Self.entry(for: pack)
        let manifest = Self.manifest(
            entry: entry,
            versionID: manifestVersionID,
            publishedAt: publishedAt
        )
        return Fixture(
            pack: pack,
            entry: entry,
            manifest: manifest,
            manifestData: try encoded(manifest),
            packData: try encoded(pack)
        )
    }

    static func publishedFixture() throws -> PublishedFixture {
        let pack = Self.pack(manifestID: "source-atlas/v1/domain/sports/20260627T000000Z")
        let packData = try encoded(pack)
        let packSHA256 = SourceAtlasStore.sha256Hex(for: packData)
        let manifestVersionID = "source-atlas/v1/staging/stable/sports/20260627T000000Z/manifest.json"
        let publishedManifestData = Data(
            """
            {
              "kind": "ambitions.sourceAtlas.packManifest.v1",
              "schema_version": "1.0.0",
              "manifest_id": "source_atlas_pack_manifest.repository_readback_test",
              "pack_id": "\(pack.id)",
              "created_at": "2026-06-27T00:00:00Z",
              "object_keys": {
                "pack": "source-atlas/v1/staging/stable/sports/20260627T000000Z/pack.json"
              },
              "sha256": "\(packSHA256)",
              "freshness_status": "current",
              "publicReferenceOnly": true
            }
            """.utf8
        )
        let publishedManifestSHA256 = SourceAtlasStore.sha256Hex(for: publishedManifestData)
        let nativeManifest = SourceAtlasFreshnessManifest(
            schemaVersion: 1,
            versionID: manifestVersionID,
            publishedAt: checkedAt,
            packIndex: [
                SourceAtlasFreshnessPackEntry(
                    packID: pack.id,
                    currentSHA256: packSHA256,
                    currentSignature: "publisher-pointer:\(publishedManifestSHA256)"
                )
            ]
        )
        let resolution = SourceAtlasPublicPackFetchPipeline().resolve(
            SourceAtlasPublicPackFetchInput(
                manifestRequest: Self.manifestRequest,
                targetPackID: pack.id,
                fetchedManifestData: try encoded(nativeManifest),
                downloadedPackData: packData,
                accessDecision: SourceAtlasAccessBoundary().resolve(
                    SourceAtlasAccessRequest(
                        artifactTier: .publicFreshness,
                        accountSessionState: .noAccount,
                        entitlementState: .bundledOnly,
                        networkReachability: .online
                    )
                ),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: checkedAt
            )
        )
        let journalRecord = SourceAtlasPublicPackCacheJournal().record(
            SourceAtlasPublicPackCacheJournalInput(
                manifestRequest: manifestRequest,
                targetPackID: pack.id,
                objectRequests: [
                    SourceAtlasPublicPackRemoteObjectRequest(
                        kind: .manifest,
                        objectKey: manifestVersionID
                    ),
                    SourceAtlasPublicPackRemoteObjectRequest(
                        kind: .pack,
                        objectKey: "source-atlas/v1/staging/stable/sports/20260627T000000Z/pack.json"
                    )
                ],
                fetchResolution: resolution,
                fetchedManifestData: publishedManifestData,
                downloadedPackData: packData,
                committedAt: checkedAt
            )
        )
        return PublishedFixture(
            pack: pack,
            journalRecord: journalRecord,
            manifestVersionID: manifestVersionID,
            packSHA256: packSHA256,
            publishedManifestSHA256: publishedManifestSHA256,
            publishedManifestData: publishedManifestData,
            packData: packData
        )
    }

    static func acceptedJournalRecord(
        fixture: Fixture,
        committedAt: Date = checkedAt
    ) throws -> SourceAtlasPublicPackCacheJournalRecord {
        let resolution = fetchResolution(
            fixture: fixture,
            downloadedPackData: fixture.packData,
            bundledPayload: try payload(for: Self.pack(manifestID: "pack.bundled"), source: .bundled)
        )
        return SourceAtlasPublicPackCacheJournal().record(
            SourceAtlasPublicPackCacheJournalInput(
                manifestRequest: manifestRequest,
                targetPackID: fixture.pack.id,
                objectRequests: objectRequests(packID: fixture.pack.id),
                fetchResolution: resolution,
                fetchedManifestData: fixture.manifestData,
                downloadedPackData: fixture.packData,
                committedAt: committedAt
            )
        )
    }

    static func hashMismatchJournalRecord(fixture: Fixture) throws -> SourceAtlasPublicPackCacheJournalRecord {
        let resolution = fetchResolution(
            fixture: fixture,
            downloadedPackData: Data("not the declared pack".utf8),
            bundledPayload: try payload(for: fixture.pack, source: .bundled)
        )
        return SourceAtlasPublicPackCacheJournal().record(
            SourceAtlasPublicPackCacheJournalInput(
                manifestRequest: manifestRequest,
                targetPackID: fixture.pack.id,
                objectRequests: objectRequests(packID: fixture.pack.id),
                fetchResolution: resolution,
                fetchedManifestData: fixture.manifestData,
                downloadedPackData: Data("not the declared pack".utf8),
                committedAt: checkedAt
            )
        )
    }

    static func privateObjectKeyJournalRecord(fixture: Fixture) throws -> SourceAtlasPublicPackCacheJournalRecord {
        let resolution = fetchResolution(
            fixture: fixture,
            downloadedPackData: fixture.packData
        )
        return SourceAtlasPublicPackCacheJournal().record(
            SourceAtlasPublicPackCacheJournalInput(
                manifestRequest: manifestRequest,
                targetPackID: fixture.pack.id,
                objectRequests: [
                    SourceAtlasPublicPackRemoteObjectRequest(
                        kind: .pack,
                        objectKey: "source-atlas/v1/stable/sports/account_id/pack.json"
                    )
                ],
                fetchResolution: resolution,
                fetchedManifestData: fixture.manifestData,
                downloadedPackData: fixture.packData,
                committedAt: checkedAt
            )
        )
    }

    static func fetchResolution(
        fixture: Fixture,
        downloadedPackData: Data?,
        bundledPayload: SourceAtlasStorePayload? = nil
    ) -> SourceAtlasPublicPackFetchResolution {
        let access = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .online,
                cachedPublicArtifactAvailable: false,
                bundledPublicArtifactAvailable: bundledPayload != nil
            )
        )
        return SourceAtlasPublicPackFetchPipeline().resolve(
            SourceAtlasPublicPackFetchInput(
                manifestRequest: Self.manifestRequest,
                targetPackID: fixture.pack.id,
                fetchedManifestData: fixture.manifestData,
                downloadedPackData: downloadedPackData,
                bundledPayload: bundledPayload,
                accessDecision: access,
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )
    }

    static func objectRequests(packID: String) -> [SourceAtlasPublicPackRemoteObjectRequest] {
        [
            SourceAtlasPublicPackRemoteObjectRequest(
                kind: .manifest,
                objectKey: "source-atlas/v1/stable/sports/manifest.json"
            ),
            SourceAtlasPublicPackRemoteObjectRequest(
                kind: .pack,
                objectKey: "source-atlas/v1/stable/sports/\(packID)/pack.json"
            )
        ]
    }

    static func manifest(
        entry: SourceAtlasFreshnessPackEntry,
        versionID: String = "manifest.v1",
        publishedAt: Date = Date(timeIntervalSince1970: 1_780_100_000)
    ) -> SourceAtlasFreshnessManifest {
        SourceAtlasFreshnessManifest(
            schemaVersion: 1,
            versionID: versionID,
            publishedAt: publishedAt,
            packIndex: [entry]
        )
    }

    static func entry(for pack: SourceAtlasPack) throws -> SourceAtlasFreshnessPackEntry {
        let data = try encoded(pack)
        return SourceAtlasFreshnessPackEntry(
            packID: pack.id,
            currentSHA256: SourceAtlasStore.sha256Hex(for: data),
            currentSignature: "signature"
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

    static func pack(
        manifestID: String = "pack.current",
        version: String = "1.0.0"
    ) -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: manifestID,
                title: "Public Sports Pack",
                kind: .domainPack,
                version: version,
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
            proofMap: [],
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection.current",
                    goalIntent: "starter_goal",
                    requiredPackIDs: [manifestID],
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
