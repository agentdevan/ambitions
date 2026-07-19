import XCTest
@testable import Ambitions

final class SourceAtlasVerifiedPublicPackProviderTests: XCTestCase {
    func testProviderReturnsVerifiedPublicContextAndKeepsPrivateRuntimeOwnershipExplicit() throws {
        let pack = Self.pack()
        let packData = try Self.encoded(pack)
        let entry = Self.entry(packID: pack.id, data: packData)
        let access = SourceAtlasBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .online,
                cachedPublicArtifactAvailable: false,
                bundledPublicArtifactAvailable: true
            )
        )

        let output = SourceAtlasVerifiedPublicPackProvider().publicPlanningContext(
            SourceAtlasVerifiedPublicPackProviderInput(
                request: Self.request,
                fetchedManifestData: try Self.encoded(Self.manifest(entry: entry)),
                downloadedPackData: packData,
                bundledPayload: Self.payload(data: packData, source: .bundled),
                accessDecision: access,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(output.requestIssues, [])
        XCTAssertEqual(output.fetchIssues, [])
        XCTAssertEqual(output.manifestRequestIssues, [])
        XCTAssertEqual(output.packRequestIssues, [])
        XCTAssertEqual(output.cacheIssues, [])
        XCTAssertEqual(output.storeQuarantines, [])
        XCTAssertEqual(output.egressFindings, [])
        XCTAssertEqual(output.fetchStatus, .accepted)
        let context = try XCTUnwrap(output.context)
        XCTAssertTrue(output.canProvidePublicPlanningContext)
        XCTAssertEqual(context.useMode, .currentReference)
        XCTAssertTrue(context.availability.canSupportCurrentPublicReferenceUse)
        XCTAssertFalse(context.availability.localPlanningBlocked)
        XCTAssertEqual(context.selectedPackID, pack.id)
        XCTAssertEqual(context.requirements.map(\.id), ["requirement-official"])
        XCTAssertEqual(context.requirements.first?.sourceIDs, ["source-official"])
        XCTAssertEqual(context.proofNeeds.map(\.id), ["proof-requirement-official"])
        XCTAssertEqual(context.starterActions.map(\.id), ["starter-public"])
        XCTAssertEqual(context.riskMetadata.first?.riskClass, .lowRiskSkill)
        XCTAssertTrue(context.ownership.privateRuntimeOwnsPersonalization)
        XCTAssertTrue(context.ownership.privateRuntimeOwnsPathing)
        XCTAssertTrue(context.ownership.privateRuntimeOwnsScheduling)
        XCTAssertTrue(context.ownership.privateRuntimeOwnsReceipts)
        XCTAssertFalse(context.ownership.sourceAtlasCreatesFinalSteps)
        XCTAssertFalse(context.ownership.sourceAtlasCreatesUserSchedule)
        XCTAssertFalse(context.ownership.sourceAtlasStoresRuntimeState)
        XCTAssertTrue(context.ownership.localPlanningMustApplyUserContext)
        XCTAssertNil(Self.request.query.goalIntent)
    }

    func testUnsafePublicSelectorFailsClosedBeforePackContextIsExposed() throws {
        let pack = Self.pack()
        let packData = try Self.encoded(pack)
        let entry = Self.entry(packID: pack.id, data: packData)
        let unsafeRequest = SourceAtlasPublicPlanningContextRequest(
            domainID: "goal_text",
            targetPackID: pack.id,
            channel: "stable",
            schemaVersion: "1",
            appVersion: "1.0"
        )
        let access = SourceAtlasBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .online
            )
        )

        let output = SourceAtlasVerifiedPublicPackProvider().publicPlanningContext(
            SourceAtlasVerifiedPublicPackProviderInput(
                request: unsafeRequest,
                fetchedManifestData: try Self.encoded(Self.manifest(entry: entry)),
                downloadedPackData: packData,
                accessDecision: access,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(output.requestIssues, [.unsafePublicSelector])
        XCTAssertEqual(output.fetchStatus, .quarantined)
        XCTAssertEqual(output.fetchIssues, [.privateEgressFinding])
        XCTAssertEqual(output.cacheIssues, [])
        XCTAssertEqual(output.storeQuarantines, [])
        XCTAssertEqual(output.egressFindings.map(\.forbiddenToken), ["goal_text"])
        XCTAssertNil(output.context)
        XCTAssertFalse(output.canProvidePublicPlanningContext)
    }

    func testOfflineLastKnownGoodContextIsExplicitReviewOnlyAndDoesNotBlockLocalPlanning() throws {
        let currentPack = Self.pack(manifestID: Self.currentPackID)
        let lastKnownGoodPack = Self.pack(manifestID: Self.lastKnownGoodPackID)
        let currentPackData = try Self.encoded(currentPack)
        let lastKnownGoodPackData = try Self.encoded(lastKnownGoodPack)
        let currentEntry = Self.entry(packID: currentPack.id, data: currentPackData)
        let lastKnownGoodEntry = Self.entry(packID: lastKnownGoodPack.id, data: lastKnownGoodPackData)
        let manifestEntry = SourceAtlasFreshnessPackEntry(
            packID: currentEntry.packID,
            currentSHA256: currentEntry.currentSHA256,
            currentSignature: "signature",
            rollbackPointers: [
                "previous": lastKnownGoodEntry.currentSHA256
            ]
        )
        let access = SourceAtlasBoundary().resolve(
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

        let output = SourceAtlasVerifiedPublicPackProvider().publicPlanningContext(
            SourceAtlasVerifiedPublicPackProviderInput(
                request: Self.request(targetPackID: currentPack.id),
                cachedManifest: Self.manifest(entry: manifestEntry),
                lastKnownGoodPayload: Self.payload(data: lastKnownGoodPackData, source: .lastKnownGood),
                accessDecision: access,
                checkedAt: Self.checkedAt
            )
        )

        XCTAssertEqual(output.requestIssues, [])
        XCTAssertEqual(output.fetchIssues, [.manifestUnavailable])
        XCTAssertEqual(output.manifestRequestIssues, [])
        XCTAssertEqual(output.packRequestIssues, [])
        XCTAssertEqual(output.cacheIssues, [.localFallbackUsed])
        XCTAssertEqual(output.storeQuarantines.map(\.reason), [.missingPayload, .missingPayload])
        XCTAssertEqual(output.egressFindings, [])
        XCTAssertEqual(output.fetchStatus, .usingLocalFallback)
        let context = try XCTUnwrap(output.context)
        XCTAssertEqual(context.useMode, .reviewOnlyReference)
        XCTAssertEqual(context.availability.selectedStoreSource, .lastKnownGood)
        XCTAssertEqual(context.availability.storeSourceState, .stale)
        XCTAssertEqual(context.availability.fallbackConditions, [.staleCache])
        XCTAssertTrue(context.availability.isLastKnownGood)
        XCTAssertTrue(context.availability.isLocalFallback)
        XCTAssertFalse(context.availability.canSupportCurrentPublicReferenceUse)
        XCTAssertFalse(context.availability.localPlanningBlocked)
        XCTAssertTrue(context.canInformLocalPlanning)
        XCTAssertTrue(context.caveats.map(\.id).contains("caveat.last-known-good"))
        XCTAssertTrue(context.ownership.privateRuntimeOwnsPersonalization)
        XCTAssertFalse(context.ownership.sourceAtlasCreatesFinalSteps)
    }
}

private extension SourceAtlasVerifiedPublicPackProviderTests {
    static let checkedAt = Date(timeIntervalSince1970: 1_780_000_000)
    static let stablePackID = "source-atlas/v1/domain/sports/pack-public-sports"
    static let currentPackID = "source-atlas/v1/domain/sports/pack-public-current"
    static let lastKnownGoodPackID = "source-atlas/v1/domain/sports/pack-public-last-known-good"

    static var request: SourceAtlasPublicPlanningContextRequest {
        request(targetPackID: stablePackID)
    }

    static func request(targetPackID: String) -> SourceAtlasPublicPlanningContextRequest {
        SourceAtlasPublicPlanningContextRequest(
            domainID: "sports",
            targetPackID: targetPackID,
            channel: "stable",
            schemaVersion: "1",
            appVersion: "1.0",
            publicLocale: "en-US",
            requirementID: "requirement-official",
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskClass: .lowRiskSkill
        )
    }

    static func manifest(entry: SourceAtlasFreshnessPackEntry) -> SourceAtlasFreshnessManifest {
        SourceAtlasFreshnessManifest(
            schemaVersion: 1,
            versionID: "source-atlas/v1/domain/sports/manifest-public-sports",
            publishedAt: Date(timeIntervalSince1970: 1_779_900_000),
            packIndex: [entry]
        )
    }

    static func entry(packID: String, data: Data) -> SourceAtlasFreshnessPackEntry {
        return SourceAtlasFreshnessPackEntry(
            packID: packID,
            currentSHA256: SourceAtlasStore.sha256Hex(for: data),
            currentSignature: "signature"
        )
    }

    static func payload(
        data: Data,
        source: SourceAtlasStorePayloadSource
    ) -> SourceAtlasStorePayload {
        return SourceAtlasStorePayload(
            source: source,
            data: data,
            declaredSHA256: SourceAtlasStore.sha256Hex(for: data)
        )
    }

    static func encoded<T: Encodable>(_ value: T) throws -> Data {
        try JSONEncoder().encode(value)
    }

    static func pack(manifestID: String = stablePackID) -> SourceAtlasPack {
        let claim = SourceAtlasClaim(
            id: "claim-official",
            text: "Official public requirements support the starter action.",
            state: .official,
            freshness: .current,
            riskClass: .lowRiskSkill,
            sourceIDs: ["source-official"],
            reviewRequired: false
        )
        let requirement = SourceAtlasRequirement(
            id: "requirement-official",
            claimID: claim.id,
            title: "Follow the public starter requirement.",
            kind: .hard,
            required: true,
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved
        )

        return SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: manifestID,
                title: "Public Sports Pack",
                kind: .domainPack,
                version: "1.0.0",
                domainID: "sports"
            ),
            sources: [
                SourceAtlasSourceRecord(
                    id: "source-official",
                    title: "Official public source",
                    kind: .official,
                    locator: "https://example.test/public-sports",
                    retrievedAt: "2026-07-01T00:00:00Z",
                    contentHash: "hash",
                    approvedForOfficialClaims: true
                )
            ],
            claims: [claim],
            requirements: [requirement],
            starterItems: [
                SourceAtlasStarterItem(
                    id: "starter-public",
                    title: "Review the public requirement",
                    stepCandidateSeed: "Review the public requirement and choose a local next action.",
                    storesFinalSchedule: false
                )
            ],
            proofMap: [
                SourceAtlasProofMapEntry(
                    id: "proof-requirement-official",
                    requirementID: requirement.id,
                    proofDescription: "Public source proof is required before current use.",
                    proofCandidate: .sourceEvidence,
                    proofStrength: .officialCertified,
                    sourceRecordIDs: ["source-official"],
                    sourceClaimIDs: [claim.id]
                )
            ],
            projections: [],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "A public source is needed before using this as current context.",
                reviewRequired: "Review the public reference before using it for current planning.",
                notProfessionalAdvice: "Public reference only; local planning still decides fit."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["node.public"],
                overlayDependencyIDs: ["overlay.public"],
                projectionRecipeIDs: ["projection.public"],
                ownsIndividualGoalPhrase: false
            )
        )
    }
}
