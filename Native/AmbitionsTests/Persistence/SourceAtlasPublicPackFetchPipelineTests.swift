import XCTest
@testable import Ambitions

final class SourceAtlasPublicPackFetchPipelineTests: XCTestCase {
    func testOnlinePublicManifestDownloadSelectsVerifiedDownloadedPack() throws {
        let pack = Self.pack()
        let entry = try Self.entry(for: pack)
        let manifest = Self.manifest(entry: entry)
        let access = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .online,
                cachedPublicArtifactAvailable: false,
                bundledPublicArtifactAvailable: true
            )
        )

        let resolution = SourceAtlasPublicPackFetchPipeline().resolve(
            SourceAtlasPublicPackFetchInput(
                manifestRequest: Self.manifestRequest,
                targetPackID: pack.id,
                fetchedManifestData: try Self.encoded(manifest),
                downloadedPackData: try Self.encoded(pack),
                bundledPayload: try Self.payload(for: Self.pack(manifestID: "pack.bundled"), source: .bundled),
                accessDecision: access,
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.status, .accepted)
        XCTAssertEqual(resolution.fetchIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertTrue(resolution.packRequest?.isPrivacySafe == true)
        XCTAssertEqual(resolution.cacheResolution?.loadResult.selectedSource, .cached)
        XCTAssertEqual(resolution.selectedPack?.id, pack.id)
        XCTAssertFalse(access.coreLocalPlanningBlocked)
    }

    func testDownloadedHashMismatchQuarantinesDownloadedPackAndUsesBundledFallback() throws {
        let pack = Self.pack()
        let entry = try Self.entry(for: pack)
        let access = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .online,
                bundledPublicArtifactAvailable: true
            )
        )

        let resolution = SourceAtlasPublicPackFetchPipeline().resolve(
            SourceAtlasPublicPackFetchInput(
                manifestRequest: Self.manifestRequest,
                targetPackID: pack.id,
                fetchedManifestData: try Self.encoded(Self.manifest(entry: entry)),
                downloadedPackData: Data("not the declared pack".utf8),
                bundledPayload: try Self.payload(for: pack, source: .bundled),
                accessDecision: access,
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.status, .usingLocalFallback)
        XCTAssertEqual(resolution.cacheResolution?.loadResult.selectedSource, .bundled)
        XCTAssertTrue(
            resolution.cacheResolution?.loadResult.quarantines.contains(
                SourceAtlasStoreQuarantine(source: .cached, reason: .hashMismatch)
            ) == true
        )
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testPrivateManifestRequestBlocksBeforePackRequestOrCacheLoad() throws {
        let unsafeRequest = SourceAtlasPublicManifestRequest(
            domainID: "goal_text",
            channel: "stable",
            schemaVersion: "1.0.0",
            appVersion: "1.0"
        )
        let access = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                networkReachability: .online
            )
        )

        let resolution = SourceAtlasPublicPackFetchPipeline().resolve(
            SourceAtlasPublicPackFetchInput(
                manifestRequest: unsafeRequest,
                targetPackID: "public-sports",
                fetchedManifestData: try Self.encoded(Self.manifest(entry: Self.entry(for: Self.pack()))),
                downloadedPackData: try Self.encoded(Self.pack()),
                accessDecision: access,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.status, .quarantined)
        XCTAssertEqual(resolution.manifestRequestIssues, [.privateEgressMarker])
        XCTAssertTrue(resolution.fetchIssues.contains(.unsafeManifestRequest))
        XCTAssertTrue(resolution.fetchIssues.contains(.privateEgressFinding))
        XCTAssertNil(resolution.packRequest)
        XCTAssertNil(resolution.cacheResolution)
    }

    func testCachedManifestCanUseLastKnownGoodWhenOfflineWithoutAccount() throws {
        let currentPack = Self.pack(manifestID: "pack.current")
        let lastKnownGood = Self.pack(manifestID: "pack.last-known-good")
        let currentEntry = try Self.entry(for: currentPack)
        let lastKnownGoodEntry = try Self.entry(for: lastKnownGood)
        let manifestEntry = SourceAtlasFreshnessPackEntry(
            packID: currentEntry.packID,
            currentSHA256: currentEntry.currentSHA256,
            currentSignature: "signature",
            rollbackPointers: [
                "previous": lastKnownGoodEntry.currentSHA256
            ]
        )
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
                cachedManifest: Self.manifest(entry: manifestEntry),
                lastKnownGoodPayload: try Self.payload(for: lastKnownGood, source: .lastKnownGood),
                accessDecision: access,
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.status, .usingLocalFallback)
        XCTAssertTrue(resolution.fetchIssues.contains(.manifestUnavailable))
        XCTAssertEqual(access.route, .lastKnownGood)
        XCTAssertEqual(resolution.cacheResolution?.loadResult.selectedSource, .lastKnownGood)
        XCTAssertEqual(resolution.selectedPack?.id, lastKnownGood.id)
        XCTAssertFalse(access.coreLocalPlanningBlocked)
        XCTAssertEqual(resolution.egressFindings, [])
    }

    func testRevokedManifestQuarantinesPackAndDoesNotUseReferenceForCurrentPlanning() throws {
        let pack = Self.pack()
        let currentEntry = try Self.entry(for: pack)
        let revokedEntry = SourceAtlasFreshnessPackEntry(
            packID: currentEntry.packID,
            currentSHA256: currentEntry.currentSHA256,
            currentSignature: "signature",
            claimStateBuckets: [
                SourceAtlasFreshnessBrokerClaimStateBucket(
                    state: .revoked,
                    claimIDs: ["claim.current"]
                )
            ]
        )
        let access = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .online
            )
        )

        let resolution = SourceAtlasPublicPackFetchPipeline().resolve(
            SourceAtlasPublicPackFetchInput(
                manifestRequest: Self.manifestRequest,
                targetPackID: pack.id,
                fetchedManifestData: try Self.encoded(Self.manifest(entry: revokedEntry)),
                downloadedPackData: try Self.encoded(pack),
                accessDecision: access,
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.status, .quarantined)
        XCTAssertTrue(resolution.fetchIssues.contains(.noEligiblePack))
        XCTAssertTrue(resolution.cacheResolution?.cacheIssues.contains(.revokedByManifest) == true)
        XCTAssertTrue(
            resolution.cacheResolution?.loadResult.quarantines.contains(
                SourceAtlasStoreQuarantine(source: .cached, reason: .revoked)
            ) == true
        )
        XCTAssertNil(resolution.selectedPack)
    }

    func testPublisherCurrentPointerVerifiesManifestHashAndLoadsDomainPackAsReviewRequiredReference() throws {
        let fixture = try Self.publisherFixture()
        let access = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .online
            )
        )

        let resolution = SourceAtlasPublicPackFetchPipeline().resolve(
            SourceAtlasPublicPackFetchInput(
                manifestRequest: Self.civicManifestRequest,
                targetPackID: fixture.packID,
                fetchedCurrentPointerData: fixture.pointerData,
                fetchedManifestData: fixture.manifestData,
                downloadedPackData: fixture.packData,
                accessDecision: access,
                query: SourceAtlasQuery(domainID: "public_civic_requirements"),
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.status, .usingLocalFallback)
        XCTAssertEqual(resolution.fetchIssues, [])
        XCTAssertEqual(resolution.egressFindings, [])
        XCTAssertEqual(resolution.packRequest?.manifestVersionID, fixture.manifestKey)
        XCTAssertEqual(resolution.packRequest?.declaredSHA256, fixture.packSHA256)
        XCTAssertEqual(resolution.cacheResolution?.loadResult.selectedSource, .cached)
        XCTAssertEqual(resolution.selectedPack?.id, fixture.packID)
        XCTAssertEqual(resolution.selectedPack?.manifest.domainID, "public_civic_requirements")
        XCTAssertEqual(resolution.cacheResolution?.queryResponse.fallbackReason, .reviewRequired)
        XCTAssertEqual(resolution.cacheResolution?.queryResponse.selectedResult.reviewState, .required)
        XCTAssertFalse(resolution.coreLocalPlanningBlocked)
    }

    func testPublisherManifestHashMismatchQuarantinesBeforeCacheReplacement() throws {
        let fixture = try Self.publisherFixture(manifestSHA256Override: String(repeating: "0", count: 64))
        let access = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .online
            )
        )

        let resolution = SourceAtlasPublicPackFetchPipeline().resolve(
            SourceAtlasPublicPackFetchInput(
                manifestRequest: Self.civicManifestRequest,
                targetPackID: fixture.packID,
                fetchedCurrentPointerData: fixture.pointerData,
                fetchedManifestData: fixture.manifestData,
                downloadedPackData: fixture.packData,
                accessDecision: access,
                query: SourceAtlasQuery(domainID: "public_civic_requirements"),
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.status, .quarantined)
        XCTAssertTrue(resolution.fetchIssues.contains(.manifestHashMismatch))
        XCTAssertNil(resolution.packRequest)
        XCTAssertNil(resolution.cacheResolution)
        XCTAssertEqual(resolution.egressFindings, [])
    }

    func testPublisherCurrentPointerWithPrivateObjectKeyIsRejected() throws {
        let fixture = try Self.publisherFixture(
            manifestKey: "source-atlas/v1/staging/candidate/user_id/private.json"
        )
        let access = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .online
            )
        )

        let resolution = SourceAtlasPublicPackFetchPipeline().resolve(
            SourceAtlasPublicPackFetchInput(
                manifestRequest: Self.civicManifestRequest,
                targetPackID: fixture.packID,
                fetchedCurrentPointerData: fixture.pointerData,
                fetchedManifestData: fixture.manifestData,
                downloadedPackData: fixture.packData,
                accessDecision: access,
                query: SourceAtlasQuery(domainID: "public_civic_requirements"),
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(resolution.status, .quarantined)
        XCTAssertTrue(resolution.fetchIssues.contains(.unsafeCurrentPointer))
        XCTAssertNil(resolution.packRequest)
        XCTAssertNil(resolution.cacheResolution)
    }

    func testReviewedPublicPackLocatorAllowsTravelRelocationWithoutAllowingPrivateLocators() {
        let safeTravelRequest = SourceAtlasPublicPackRequest(
            packID: "source-atlas/v1/domain/travel_relocation/20260628T000000Z",
            manifestVersionID: "source-atlas/v1/production/stable/travel_relocation/20260628T000000Z/manifest.json",
            declaredSHA256: String(repeating: "a", count: 64),
            queryItems: [
                "pack_id": "source-atlas/v1/domain/travel_relocation/20260628T000000Z",
                "manifest_version": "source-atlas/v1/production/stable/travel_relocation/20260628T000000Z/manifest.json",
            ]
        )
        XCTAssertEqual(safeTravelRequest.validationIssues, [])

        let unsafeUserLocator = SourceAtlasPublicPackRequest(
            packID: "source-atlas/v1/domain/user_id/private-goal",
            manifestVersionID: "source-atlas/v1/production/stable/travel_relocation/20260628T000000Z/manifest.json",
            declaredSHA256: String(repeating: "b", count: 64),
            queryItems: [
                "pack_id": "source-atlas/v1/domain/user_id/private-goal",
            ]
        )
        XCTAssertTrue(unsafeUserLocator.validationIssues.contains(.privatePlanningParameter))

        let unsafeAddressParameter = SourceAtlasPublicPackRequest(
            packID: "source-atlas/v1/domain/travel_relocation/20260628T000000Z",
            manifestVersionID: "source-atlas/v1/production/stable/travel_relocation/20260628T000000Z/manifest.json",
            declaredSHA256: String(repeating: "c", count: 64),
            queryItems: [
                "address": "123 main street",
            ]
        )
        XCTAssertTrue(unsafeAddressParameter.validationIssues.contains(.privatePlanningParameter))
    }
}

private extension SourceAtlasPublicPackFetchPipelineTests {
    static let checkedAt = Date(timeIntervalSince1970: 1_780_000_000)
    static let manifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "sports",
        channel: "stable",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )
    static let civicManifestRequest = SourceAtlasPublicManifestRequest(
        domainID: "public_civic_requirements",
        channel: "candidate",
        schemaVersion: "1.0.0",
        appVersion: "1.0",
        publicLocale: "en-US"
    )

    struct PublisherFixture {
        let packID: String
        let manifestKey: String
        let packSHA256: String
        let pointerData: Data
        let manifestData: Data
        let packData: Data
    }

    static func publisherFixture(
        manifestSHA256Override: String? = nil,
        manifestKey: String = "source-atlas/v1/staging/candidate/public_civic_requirements/20260627T000000Z/manifest.json"
    ) throws -> PublisherFixture {
        let packID = "source-atlas/v1/domain/public_civic_requirements/20260627T000000Z"
        let packData = publishedDomainPackData(packID: packID)
        let packSHA256 = SourceAtlasStore.sha256Hex(for: packData)
        let manifestData = publishedManifestData(packID: packID, packSHA256: packSHA256)
        let manifestSHA256 = SourceAtlasStore.sha256Hex(for: manifestData)
        let pointerData = publishedPointerData(
            packID: packID,
            manifestKey: manifestKey,
            manifestSHA256: manifestSHA256Override ?? manifestSHA256,
            packSHA256: packSHA256
        )
        return PublisherFixture(
            packID: packID,
            manifestKey: manifestKey,
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
              "channel": "candidate",
              "packID": "\(packID)",
              "packVersion": "20260627T000000Z",
              "manifestKey": "\(manifestKey)",
              "manifestSHA256": "\(manifestSHA256)",
              "packSHA256": "\(packSHA256)",
              "revocationManifestKey": "source-atlas/v1/staging/candidate/public_civic_requirements/revocations.json",
              "lastKnownGoodKey": "source-atlas/v1/staging/candidate/public_civic_requirements/lkg.json",
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

    static func publishedManifestData(packID: String, packSHA256: String) -> Data {
        Data(
            """
            {
              "kind": "ambitions.sourceAtlas.packManifest.v1",
              "schema_version": "1.0.0",
              "manifest_id": "source_atlas_pack_manifest.test",
              "pack_id": "\(packID)",
              "created_at": "2026-06-27T00:00:00Z",
              "sha256": "\(packSHA256)",
              "freshness_status": "current",
              "publicReferenceOnly": true
            }
            """.utf8
        )
    }

    static func publishedDomainPackData(packID: String) -> Data {
        Data(
            """
            {
              "kind": "ambitions.sourceAtlas.domainPack.v1",
              "schema_version": "1.0.0",
              "pack_id": "\(packID)",
              "frontier_id": "public_civic_requirements",
              "created_at": "2026-06-27T00:00:00Z",
              "publicReferenceOnly": true,
              "manifest": {
                "pack_version": "20260627T000000Z",
                "channel": "candidate",
                "environment": "staging"
              },
              "sources": [
                {
                  "source_id": "nara.constitution.presidency",
                  "source_name": "U.S. Constitution presidential eligibility",
                  "authority_class": "official_government",
                  "review_status": "reviewed",
                  "r2_pack_policy": "pack_allowed_with_attribution"
                }
              ],
              "claims": [
                {
                  "claim_id": "canonical_claim.age",
                  "claim_type": "eligibility_requirement",
                  "predicate": "eligibility_requirement",
                  "object_value": "U.S. presidential eligibility includes a minimum age requirement as a public constitutional reference.",
                  "domain": "public_civic_requirements",
                  "source_id": "nara.constitution.presidency",
                  "authority_class": "official_government",
                  "freshness_status": "current",
                  "review_required": false,
                  "locator": "https://www.archives.gov/founding-docs/constitution-transcript"
                }
              ],
              "non_claims": [
                "not a final user plan, schedule, or Step generator",
                "not legal advice"
              ]
            }
            """.utf8
        )
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
