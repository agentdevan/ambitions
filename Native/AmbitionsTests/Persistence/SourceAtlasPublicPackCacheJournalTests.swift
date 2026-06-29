import XCTest
@testable import Ambitions

final class SourceAtlasPublicPackCacheJournalTests: XCTestCase {
    func testAcceptedDownloadedPackProducesPersistablePublicCacheJournalRecord() throws {
        let fixture = try Self.fixture()
        let resolution = Self.fetchResolution(
            fixture: fixture,
            downloadedPackData: fixture.packData,
            bundledPayload: try Self.payload(for: Self.pack(manifestID: "pack.bundled"), source: .bundled)
        )

        let record = SourceAtlasPublicPackCacheJournal().record(
            SourceAtlasPublicPackCacheJournalInput(
                manifestRequest: Self.manifestRequest,
                targetPackID: fixture.pack.id,
                objectRequests: Self.objectRequests(packID: fixture.pack.id),
                fetchResolution: resolution,
                fetchedManifestData: fixture.manifestData,
                downloadedPackData: fixture.packData,
                committedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(record.status, .acceptedCurrent)
        XCTAssertTrue(record.canPersistCurrentPack)
        XCTAssertEqual(record.cacheNamespace, SourceAtlasLocalStorageBoundaryProof.publicReferenceCacheNamespace)
        XCTAssertEqual(record.selectedPackIDs, [fixture.pack.id])
        XCTAssertEqual(record.selectedSource, .cached)
        XCTAssertFalse(record.fallbackTriggered)
        XCTAssertFalse(record.coreLocalPlanningBlocked)
        XCTAssertEqual(record.egressFindings, [])
        XCTAssertEqual(record.issues, [])
        XCTAssertEqual(Set(record.artifacts.map(\.kind)), [.manifest, .pack])
        XCTAssertEqual(record.artifacts.first { $0.kind == .pack }?.sha256, fixture.entry.currentSHA256)
        XCTAssertEqual(record.artifacts.first { $0.kind == .pack }?.byteCount, fixture.packData.count)
        XCTAssertTrue(record.nonClaims.contains("not private graph storage"))
        _ = try JSONEncoder().encode(record)
    }

    func testDownloadedHashMismatchRecordsQuarantineAndDoesNotPersistCurrentPack() throws {
        let fixture = try Self.fixture()
        let resolution = Self.fetchResolution(
            fixture: fixture,
            downloadedPackData: Data("not the declared pack".utf8),
            bundledPayload: try Self.payload(for: fixture.pack, source: .bundled)
        )

        let record = SourceAtlasPublicPackCacheJournal().record(
            SourceAtlasPublicPackCacheJournalInput(
                manifestRequest: Self.manifestRequest,
                targetPackID: fixture.pack.id,
                objectRequests: Self.objectRequests(packID: fixture.pack.id),
                fetchResolution: resolution,
                fetchedManifestData: fixture.manifestData,
                downloadedPackData: Data("not the declared pack".utf8),
                committedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(record.status, .localFallback)
        XCTAssertFalse(record.canPersistCurrentPack)
        XCTAssertTrue(record.issues.contains(.downloadedPackHashMismatch))
        XCTAssertEqual(record.selectedSource, .bundled)
        XCTAssertEqual(
            record.quarantines,
            [
                SourceAtlasPublicPackCacheQuarantineRecord(
                    quarantine: SourceAtlasStoreQuarantine(source: .cached, reason: .hashMismatch),
                    recordedAt: Self.checkedAt
                )
            ]
        )
        XCTAssertFalse(record.artifacts.contains { $0.kind == .pack })
        XCTAssertFalse(record.coreLocalPlanningBlocked)
    }

    func testPrivateObjectKeyBlocksCacheCommitBeforeArtifactsArePersistable() throws {
        let fixture = try Self.fixture()
        let resolution = Self.fetchResolution(
            fixture: fixture,
            downloadedPackData: fixture.packData
        )
        let unsafeRequests = [
            SourceAtlasPublicPackRemoteObjectRequest(
                kind: .pack,
                objectKey: "source-atlas/v1/stable/sports/account_id/device_id/pack.json"
            )
        ]

        let record = SourceAtlasPublicPackCacheJournal().record(
            SourceAtlasPublicPackCacheJournalInput(
                manifestRequest: Self.manifestRequest,
                targetPackID: fixture.pack.id,
                objectRequests: unsafeRequests,
                fetchResolution: resolution,
                fetchedManifestData: fixture.manifestData,
                downloadedPackData: fixture.packData,
                committedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(record.status, .rejected)
        XCTAssertFalse(record.canPersistCurrentPack)
        XCTAssertTrue(record.issues.contains(.privateEgressFinding))
        XCTAssertTrue(record.egressFindings.contains { $0.forbiddenToken == "account_id" })
        XCTAssertTrue(record.egressFindings.contains { $0.forbiddenToken == "device_id" })
        XCTAssertEqual(record.artifacts, [])
        XCTAssertFalse(record.coreLocalPlanningBlocked)
    }

    func testOfflineLastKnownGoodRecordsLocalFallbackWithoutBlockingCorePlanning() throws {
        let currentPack = Self.pack(manifestID: "pack.current")
        let lastKnownGoodPack = Self.pack(manifestID: "pack.last-known-good")
        let currentEntry = try Self.entry(for: currentPack)
        let lastKnownGoodEntry = try Self.entry(for: lastKnownGoodPack)
        let manifestEntry = SourceAtlasFreshnessPackEntry(
            packID: currentEntry.packID,
            currentSHA256: currentEntry.currentSHA256,
            currentSignature: "signature",
            rollbackPointers: ["previous": lastKnownGoodEntry.currentSHA256]
        )
        let manifest = Self.manifest(entry: manifestEntry)
        let access = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .offline,
                cachedPublicArtifactAvailable: false,
                lastKnownGoodAvailable: true,
                bundledPublicArtifactAvailable: false
            )
        )
        let resolution = SourceAtlasPublicPackFetchPipeline().resolve(
            SourceAtlasPublicPackFetchInput(
                manifestRequest: Self.manifestRequest,
                targetPackID: currentPack.id,
                cachedManifest: manifest,
                lastKnownGoodPayload: try Self.payload(for: lastKnownGoodPack, source: .lastKnownGood),
                accessDecision: access,
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        let record = SourceAtlasPublicPackCacheJournal().record(
            SourceAtlasPublicPackCacheJournalInput(
                manifestRequest: Self.manifestRequest,
                targetPackID: currentPack.id,
                objectRequests: [],
                fetchResolution: resolution,
                committedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(record.status, .localFallback)
        XCTAssertFalse(record.canPersistCurrentPack)
        XCTAssertEqual(record.selectedSource, .lastKnownGood)
        XCTAssertEqual(record.selectedPackIDs, [lastKnownGoodPack.id])
        XCTAssertEqual(record.egressFindings, [])
        XCTAssertFalse(record.coreLocalPlanningBlocked)
        XCTAssertTrue(record.nonClaims.contains("not production R2 readiness"))
    }
}

private extension SourceAtlasPublicPackCacheJournalTests {
    struct Fixture {
        let pack: SourceAtlasPack
        let entry: SourceAtlasFreshnessPackEntry
        let manifest: SourceAtlasFreshnessManifest
        let manifestData: Data
        let packData: Data
    }

    static let checkedAt = Date(timeIntervalSince1970: 1_780_000_000)
    static let manifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "sports",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )

    static func fixture() throws -> Fixture {
        let pack = Self.pack()
        let entry = try Self.entry(for: pack)
        let manifest = Self.manifest(entry: entry)
        return Fixture(
            pack: pack,
            entry: entry,
            manifest: manifest,
            manifestData: try encoded(manifest),
            packData: try encoded(pack)
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
        publishedAt: Date = Date(timeIntervalSince1970: 1_780_000_000)
    ) -> SourceAtlasFreshnessManifest {
        SourceAtlasFreshnessManifest(
            schemaVersion: 1,
            versionID: "manifest.v1",
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

    static func pack(manifestID: String = "pack.current") -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: manifestID,
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
