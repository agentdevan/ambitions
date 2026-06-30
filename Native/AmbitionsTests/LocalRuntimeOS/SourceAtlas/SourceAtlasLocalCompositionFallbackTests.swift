import XCTest
@testable import Ambitions

final class SourceAtlasLocalCompositionFallbackTests: XCTestCase {
    func testCurrentPublicReferenceContextDoesNotOwnFinalStepsOrSchedule() throws {
        let pack = Self.pack()
        let entry = try Self.entry(for: pack)
        let resolution = SourceAtlasLocalPackCache().resolve(
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
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        let fallback = SourceAtlasLocalCompositionFallback().evaluate(cacheResolution: resolution)

        XCTAssertEqual(fallback.mode, .publicReferenceAvailable)
        XCTAssertEqual(fallback.publicReferencePackIDs, [pack.id])
        XCTAssertTrue(fallback.runtimeOwnsFitTimingPriorityProof)
        XCTAssertFalse(fallback.sourceAtlasOwnsFinalUserSteps)
        XCTAssertFalse(fallback.createsFinalSchedule)
        XCTAssertFalse(fallback.blocksCoreLocalPlanning)
    }

    func testLastKnownGoodCreatesLocalFallbackCaveatWithoutCurrentUseClaim() throws {
        let currentPack = Self.pack(id: "pack.current")
        let lastKnownGood = Self.pack(id: "pack.last-known-good")
        let currentEntry = try Self.entry(for: currentPack)
        let lastKnownGoodEntry = try Self.entry(for: lastKnownGood)
        let entry = SourceAtlasFreshnessPackEntry(
            packID: currentEntry.packID,
            currentSHA256: currentEntry.currentSHA256,
            currentSignature: "signature",
            rollbackPointers: ["previous": lastKnownGoodEntry.currentSHA256]
        )
        let resolution = SourceAtlasLocalPackCache().resolve(
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
                lastKnownGoodPayload: try Self.payload(for: lastKnownGood, source: .lastKnownGood),
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt
            )
        )

        let fallback = SourceAtlasLocalCompositionFallback().evaluate(cacheResolution: resolution)

        XCTAssertEqual(fallback.mode, .localFallbackWithCaveat)
        XCTAssertTrue(fallback.caveats.contains("Source freshness needs review."))
        XCTAssertFalse(resolution.canSupportCurrentUse)
        XCTAssertFalse(fallback.sourceAtlasOwnsFinalUserSteps)
        XCTAssertFalse(fallback.createsFinalSchedule)
    }

    func testNoAccountOfflineUnavailableSourceAtlasStillAllowsLocalStarterPlanning() throws {
        let pack = Self.pack()
        let entry = try Self.entry(for: pack)
        let access = SourceAtlasBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .entitlementReferencePack,
                accountSessionState: .noAccount,
                entitlementState: .denied,
                networkReachability: .offline,
                bundledPublicArtifactAvailable: false
            )
        )
        let resolution = SourceAtlasLocalPackCache().resolve(
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
                query: SourceAtlasQuery(domainID: "sports"),
                checkedAt: Self.checkedAt,
                accessDecision: access
            )
        )

        let fallback = SourceAtlasLocalCompositionFallback().evaluate(
            cacheResolution: resolution,
            accessDecision: access
        )

        XCTAssertEqual(fallback.mode, .localStarterOnly)
        XCTAssertTrue(fallback.caveats.contains("Live reference update is unavailable."))
        XCTAssertTrue(fallback.caveats.contains("Local planning remains available."))
        XCTAssertFalse(access.coreLocalPlanningBlocked)
        XCTAssertFalse(fallback.blocksCoreLocalPlanning)
        XCTAssertFalse(fallback.sourceAtlasOwnsFinalUserSteps)
        XCTAssertFalse(fallback.createsFinalSchedule)
    }
}

private extension SourceAtlasLocalCompositionFallbackTests {
    static let checkedAt = Date(timeIntervalSince1970: 1_780_000_000)

    static func manifest(entry: SourceAtlasFreshnessPackEntry) -> SourceAtlasFreshnessManifest {
        SourceAtlasFreshnessManifest(
            schemaVersion: 1,
            versionID: "manifest.v1",
            publishedAt: checkedAt,
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

    static func payload(for pack: SourceAtlasPack, source: SourceAtlasStorePayloadSource) throws -> SourceAtlasStorePayload {
        let data = try encoded(pack)
        return SourceAtlasStorePayload(
            source: source,
            data: data,
            declaredSHA256: SourceAtlasStore.sha256Hex(for: data)
        )
    }

    static func encoded(_ pack: SourceAtlasPack) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(pack)
    }

    static func pack(id: String = "pack.current") -> SourceAtlasPack {
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
            proofMap: [],
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection.current",
                    goalIntent: "starter_goal",
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
