import XCTest
@testable import Ambitions

final class SourceAtlasLocalPackCacheTests: XCTestCase {
    // Guard note: this Persistence boundary does not introduce SourceRecord, Receipt, or ReplayTrace owners.

    func testPrivacySafePublicRequestAndMatchingCachedPackSupportCurrentUse() throws {
        let pack = Self.pack()
        let entry = try Self.entry(for: pack)
        let request = SourceAtlasPublicPackRequest.publicPack(
            manifestVersionID: "manifest.v1",
            entry: entry
        )
        let result = SourceAtlasLocalPackCache().resolve(
            SourceAtlasLocalPackCacheInput(
                manifest: Self.manifest(entry: entry),
                request: request,
                cachedPayload: try Self.payload(for: pack, source: .cached),
                bundledPayload: try Self.payload(for: Self.pack(manifestID: "pack.bundled"), source: .bundled),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertTrue(request.isPrivacySafe)
        XCTAssertEqual(Set(request.queryItems.keys), ["manifest_version", "pack_id", "sha256"])
        XCTAssertEqual(result.loadResult.selectedSource, .cached)
        XCTAssertEqual(result.selectedPack?.id, pack.id)
        XCTAssertTrue(result.requestIssues.isEmpty)
        XCTAssertTrue(result.cacheIssues.isEmpty)
        XCTAssertTrue(result.canSupportCurrentUse)
        XCTAssertEqual(result.queryResponse.selectedResult.sourceState, .officialCurrent)
        XCTAssertEqual(result.updateRecord.selectedPackIDs, [pack.id])
        XCTAssertFalse(result.updateRecord.fallbackTriggered)
    }

    func testRuntimeArtifactRequestAllowsOnlyPublicReferenceFields() throws {
        let pack = Self.pack()
        let entry = try Self.entry(for: pack)
        let request = SourceAtlasPublicPackRequest.runtimeArtifact(
            manifestVersionID: "manifest.v1",
            entry: entry,
            channel: "stable",
            artifactVersionID: "2026-06-public-reference",
            sourceState: .officialCurrent,
            freshnessState: .current,
            publicJurisdiction: "US",
            publicLocale: "en-US"
        )

        XCTAssertTrue(request.isPrivacySafe)
        XCTAssertEqual(request.channel, "stable")
        XCTAssertEqual(request.artifactVersionID, "2026-06-public-reference")
        XCTAssertEqual(request.sourceState, .officialCurrent)
        XCTAssertEqual(request.freshnessState, .current)
        XCTAssertEqual(request.publicJurisdiction, "US")
        XCTAssertEqual(request.publicLocale, "en-US")
        XCTAssertEqual(
            Set(request.queryItems.keys),
            ["artifact_id", "artifact_version", "channel", "freshness_state", "manifest_version", "pack_id", "sha256", "source_state"]
        )
        let encoded = try Self.encodedJSONString(request)
        for allowed in [
            "artifact_id",
            "artifact_version",
            "channel",
            "freshness_state",
            "manifest_version",
            "pack_id",
            "publicJurisdiction",
            "publicLocale",
            "sha256",
            "source_state"
        ] {
            XCTAssertTrue(encoded.contains(allowed), allowed)
        }
        for forbidden in [
            "goalText",
            "captureText",
            "calendar",
            "schedule",
            "capacity",
            "lifeCapital",
            "proofPayload",
            "receiptPayload",
            "privateLifeGraph",
            "accountSecret",
            "userID",
            "inferredPriority"
        ] {
            XCTAssertFalse(encoded.localizedCaseInsensitiveContains(forbidden), forbidden)
        }
    }

    func testManifestHashMismatchQuarantinesPayloadsAndFallsBackLocally() throws {
        let pack = Self.pack()
        let actualEntry = try Self.entry(for: pack)
        let manifestEntry = SourceAtlasFreshnessPackEntry(
            packID: actualEntry.packID,
            currentSHA256: Self.hash("different"),
            currentSignature: "signature"
        )
        let result = SourceAtlasLocalPackCache().resolve(
            SourceAtlasLocalPackCacheInput(
                manifest: Self.manifest(entry: manifestEntry),
                request: SourceAtlasPublicPackRequest.publicPack(
                    manifestVersionID: "manifest.v1",
                    entry: manifestEntry
                ),
                cachedPayload: try Self.payload(for: pack, source: .cached),
                bundledPayload: try Self.payload(for: pack, source: .bundled),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertNil(result.selectedPack)
        XCTAssertEqual(Set(result.loadResult.quarantines.map(\.source)), [.cached, .bundled])
        XCTAssertTrue(result.loadResult.quarantines.allSatisfy { $0.reason == .hashMismatch })
        XCTAssertTrue(result.cacheIssues.contains(.manifestHashMismatch))
        XCTAssertTrue(result.cacheIssues.contains(.noEligiblePack))
        XCTAssertTrue(result.cacheIssues.contains(.localFallbackUsed))
        XCTAssertEqual(result.fallback.conditions, [.missingPack, .corruptInvalidPack])
        XCTAssertFalse(result.canSupportCurrentUse)
    }

    func testManifestRevocationBlocksOtherwiseValidPack() throws {
        let pack = Self.pack()
        let entry = SourceAtlasFreshnessPackEntry(
            packID: pack.id,
            currentSHA256: try Self.entry(for: pack).currentSHA256,
            currentSignature: "signature",
            claimStateBuckets: [
                SourceAtlasFreshnessBrokerClaimStateBucket(
                    state: .revoked,
                    claimIDs: ["claim.current"]
                )
            ]
        )
        let result = SourceAtlasLocalPackCache().resolve(
            SourceAtlasLocalPackCacheInput(
                manifest: Self.manifest(entry: entry),
                request: SourceAtlasPublicPackRequest.publicPack(
                    manifestVersionID: "manifest.v1",
                    entry: entry
                ),
                cachedPayload: try Self.payload(for: pack, source: .cached),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertNil(result.selectedPack)
        XCTAssertTrue(result.cacheIssues.contains(.revokedByManifest))
        XCTAssertTrue(result.cacheIssues.contains(.noEligiblePack))
        XCTAssertTrue(result.loadResult.quarantines.map(\.reason).contains(.revoked))
        XCTAssertEqual(result.queryResponse.fallbackReason, .noLoadedPacks)
        XCTAssertFalse(result.canSupportCurrentUse)
    }

    func testManifestStaleCriticalQuarantinesCurrentAndLastKnownGoodArtifacts() throws {
        let pack = Self.pack()
        let entry = SourceAtlasFreshnessPackEntry(
            packID: pack.id,
            currentSHA256: try Self.entry(for: pack).currentSHA256,
            currentSignature: "signature",
            rollbackPointers: [
                "previous": try Self.entry(for: pack).currentSHA256
            ],
            claimStateBuckets: [
                SourceAtlasFreshnessBrokerClaimStateBucket(
                    state: .stale,
                    claimIDs: ["claim.current"]
                )
            ]
        )
        let result = SourceAtlasLocalPackCache().resolve(
            SourceAtlasLocalPackCacheInput(
                manifest: Self.manifest(entry: entry),
                request: SourceAtlasPublicPackRequest.runtimeArtifact(
                    manifestVersionID: "manifest.v1",
                    entry: entry,
                    channel: "stable",
                    artifactVersionID: "2026-06-public-reference",
                    sourceState: .officialCurrent,
                    freshnessState: .current
                ),
                cachedPayload: try Self.payload(for: pack, source: .cached),
                bundledPayload: try Self.payload(for: pack, source: .bundled),
                lastKnownGoodPayload: try Self.payload(for: pack, source: .lastKnownGood),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertNil(result.selectedPack)
        XCTAssertTrue(result.cacheIssues.contains(.staleCriticalByManifest))
        XCTAssertTrue(result.cacheIssues.contains(.noEligiblePack))
        XCTAssertEqual(
            Set(result.loadResult.quarantines),
            [
                SourceAtlasStoreQuarantine(source: .cached, reason: .staleCritical),
                SourceAtlasStoreQuarantine(source: .bundled, reason: .staleCritical),
                SourceAtlasStoreQuarantine(source: .lastKnownGood, reason: .staleCritical)
            ]
        )
        XCTAssertFalse(result.canSupportCurrentUse)
    }

    func testUnsafeRequestBlocksLoadBeforePayloadInspection() throws {
        let pack = Self.pack()
        let entry = try Self.entry(for: pack)
        let unsafeRequest = SourceAtlasPublicPackRequest(
            packID: entry.packID,
            manifestVersionID: "manifest.v1",
            declaredSHA256: entry.currentSHA256,
            queryItems: [
                "goal_id": "goal.private",
                "api_key": "secret",
                "path": "file:///Users/devan/private/source.json"
            ]
        )
        let result = SourceAtlasLocalPackCache().resolve(
            SourceAtlasLocalPackCacheInput(
                manifest: Self.manifest(entry: entry),
                request: unsafeRequest,
                cachedPayload: try Self.payload(for: pack, source: .cached),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(
            Set(unsafeRequest.validationIssues),
            [.privatePlanningParameter, .secretParameter, .privateLocator]
        )
        XCTAssertNil(result.selectedPack)
        XCTAssertTrue(result.cacheIssues.contains(.unsafePublicRequest))
        XCTAssertTrue(result.cacheIssues.contains(.noEligiblePack))
        XCTAssertFalse(result.canSupportCurrentUse)
    }

    func testRequestContractRejectsPrivateRuntimeEgressMarkers() throws {
        let pack = Self.pack()
        let entry = try Self.entry(for: pack)
        let unsafeRequest = SourceAtlasPublicPackRequest(
            packID: entry.packID,
            manifestVersionID: "manifest.v1",
            declaredSHA256: entry.currentSHA256,
            queryItems: [
                "capture_text": "private capture",
                "life_capital": "relationship",
                "proof_payload": "receipt",
                "schedule_capacity": "tonight",
                "inferred_priority": "high",
                "user_id": "user-123"
            ]
        )

        XCTAssertEqual(unsafeRequest.validationIssues, [.privatePlanningParameter])
    }

    func testLastKnownGoodRollbackLoadsButBlocksCurrentUse() throws {
        let currentPack = Self.pack(manifestID: "pack.current")
        let lastKnownGood = Self.pack(manifestID: "pack.last-known-good")
        let currentEntry = try Self.entry(for: currentPack)
        let lastKnownGoodEntry = try Self.entry(for: lastKnownGood)
        let entry = SourceAtlasFreshnessPackEntry(
            packID: currentEntry.packID,
            currentSHA256: currentEntry.currentSHA256,
            currentSignature: "signature",
            rollbackPointers: [
                "previous": lastKnownGoodEntry.currentSHA256
            ]
        )
        let result = SourceAtlasLocalPackCache().resolve(
            SourceAtlasLocalPackCacheInput(
                manifest: Self.manifest(entry: entry),
                request: SourceAtlasPublicPackRequest.publicPack(
                    manifestVersionID: "manifest.v1",
                    entry: entry
                ),
                cachedPayload: nil,
                bundledPayload: nil,
                lastKnownGoodPayload: try Self.payload(for: lastKnownGood, source: .lastKnownGood),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(result.loadResult.selectedSource, .lastKnownGood)
        XCTAssertEqual(result.loadResult.sourceState, .stale)
        XCTAssertEqual(result.selectedPack?.id, lastKnownGood.id)
        XCTAssertTrue(result.fallback.conditions.contains(.staleCache))
        XCTAssertTrue(result.cacheIssues.contains(.localFallbackUsed))
        XCTAssertFalse(result.cacheIssues.contains(.noEligiblePack))
        XCTAssertFalse(result.canSupportCurrentUse)
    }

    func testDeniedEntitlementCanUseBundledPublicFallbackWithoutRemoteAccess() throws {
        let pack = Self.pack()
        let entry = try Self.entry(for: pack)
        let access = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .entitlementReferencePack,
                accountSessionState: .signedIn,
                entitlementState: .denied,
                networkReachability: .online,
                bundledPublicArtifactAvailable: true
            )
        )
        let result = SourceAtlasLocalPackCache().resolve(
            SourceAtlasLocalPackCacheInput(
                manifest: Self.manifest(entry: entry),
                request: SourceAtlasPublicPackRequest.runtimeArtifact(
                    manifestVersionID: "manifest.v1",
                    entry: entry,
                    channel: "stable",
                    artifactVersionID: "2026-06-public-reference",
                    sourceState: .officialCurrent,
                    freshnessState: .current
                ),
                cachedPayload: try Self.payload(for: pack, source: .cached),
                bundledPayload: try Self.payload(for: pack, source: .bundled),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt,
                accessDecision: access
            )
        )

        XCTAssertEqual(access.route, .bundledLocal)
        XCTAssertFalse(access.permitsRemotePublicReference)
        XCTAssertFalse(access.coreLocalPlanningBlocked)
        XCTAssertEqual(result.loadResult.selectedSource, .bundled)
        XCTAssertEqual(result.selectedPack?.id, pack.id)
        XCTAssertFalse(result.cacheIssues.contains(.accessBoundaryUnavailable))
    }

    func testUnavailableAccessBoundaryFailsClosedForSourceAtlasButNotCorePlanning() throws {
        let pack = Self.pack()
        let entry = try Self.entry(for: pack)
        let access = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .entitlementReferencePack,
                accountSessionState: .noAccount,
                entitlementState: .denied,
                networkReachability: .offline,
                cachedPublicArtifactAvailable: false,
                lastKnownGoodAvailable: false,
                bundledPublicArtifactAvailable: false
            )
        )
        let result = SourceAtlasLocalPackCache().resolve(
            SourceAtlasLocalPackCacheInput(
                manifest: Self.manifest(entry: entry),
                request: SourceAtlasPublicPackRequest.runtimeArtifact(
                    manifestVersionID: "manifest.v1",
                    entry: entry,
                    channel: "stable",
                    artifactVersionID: "2026-06-public-reference",
                    sourceState: .officialCurrent,
                    freshnessState: .current
                ),
                cachedPayload: try Self.payload(for: pack, source: .cached),
                bundledPayload: try Self.payload(for: pack, source: .bundled),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt,
                accessDecision: access
            )
        )

        XCTAssertEqual(access.route, .unavailable)
        XCTAssertTrue(access.issues.contains(.noAccount))
        XCTAssertTrue(access.issues.contains(.entitlementDenied))
        XCTAssertTrue(access.issues.contains(.offline))
        XCTAssertFalse(access.coreLocalPlanningBlocked)
        XCTAssertNil(result.selectedPack)
        XCTAssertTrue(result.cacheIssues.contains(.accessBoundaryUnavailable))
        XCTAssertTrue(result.cacheIssues.contains(.noEligiblePack))
        XCTAssertFalse(result.canSupportCurrentUse)
    }
}

private extension SourceAtlasLocalPackCacheTests {
    static let checkedAt = Date(timeIntervalSince1970: 1_780_000_000)

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

    static func hash(_ value: String) -> String {
        SourceAtlasStore.sha256Hex(for: Data(value.utf8))
    }

    static func encoded(_ pack: SourceAtlasPack) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(pack)
    }

    static func encodedJSONString<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(value)
        return String(data: data, encoding: .utf8) ?? ""
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
