import XCTest
@testable import Ambitions

final class SourceAtlasOfflineFallbackRuntimeModelsTests: XCTestCase {
    func testNoLoadedPacksReturnMissingPackFallbackThatBlocksClaims() {
        let loadResult = SourceAtlasStore().load(bundled: nil, cached: nil, lastKnownGood: nil)
        let queryResponse = SourceAtlasQueryEngine(packs: []).query(SourceAtlasQuery(domainID: "sports"))
        let runtime = SourceAtlasOfflineFallbackRuntimeResult(
            loadResult: loadResult,
            queryResponse: queryResponse
        )

        XCTAssertEqual(runtime.conditions, [.missingPack])
        XCTAssertFalse(runtime.hasLoadedPack)
        XCTAssertNil(runtime.selectedStoreSource)
        XCTAssertEqual(runtime.storeSourceState, .sourceNeeded)
        XCTAssertEqual(runtime.queryFallbackReason, .noLoadedPacks)
        XCTAssertEqual(runtime.selectedSourceState, .sourceNeeded)
        XCTAssertEqual(runtime.selectedFreshnessState, .unknown)
        XCTAssertEqual(runtime.selectedReviewState, .required)
        XCTAssertEqual(runtime.selectedProvenanceSourceIDs, [])
        XCTAssertTrue(runtime.blocksOfficialCurrentClaims)
        XCTAssertTrue(runtime.blocksCurrentUse)
    }

    func testNoInternetUnreachableManifestAndFailedDownloadRemainExplicit() throws {
        let pack = Self.pack()
        let loadResult = try Self.loadedResult(for: pack)
        let queryResponse = SourceAtlasQueryEngine(packs: [pack]).query(SourceAtlasQuery(domainID: "sports"))
        let runtime = SourceAtlasOfflineFallbackRuntimeResult(
            loadResult: loadResult,
            queryResponse: queryResponse,
            availability: SourceAtlasOfflineFallbackAvailability(
                internetAvailable: false,
                manifestReachable: false,
                downloadSucceeded: false
            )
        )

        XCTAssertEqual(runtime.conditions, [.noInternet, .unreachableManifest, .failedDownload])
        XCTAssertEqual(runtime.selectedSourceState, .officialCurrent)
        XCTAssertEqual(runtime.selectedFreshnessState, .current)
        XCTAssertEqual(runtime.selectedReviewState, .approved)
        XCTAssertEqual(runtime.selectedProvenanceSourceIDs, ["source-official"])
        XCTAssertTrue(runtime.blocksOfficialCurrentClaims)
        XCTAssertTrue(runtime.blocksCurrentUse)
    }

    func testStaleLastKnownGoodCacheBlocksOfficialCurrentAndCurrentUse() throws {
        let currentPack = Self.pack(manifestID: "sports.current.domain")
        let lastKnownGoodPack = Self.pack(manifestID: "sports.last-known-good.domain")
        let invalidPrimary = try Self.payload(for: currentPack, source: .bundled, declaredSHA256: "bad-hash")
        let loadResult = SourceAtlasStore().load(
            bundled: invalidPrimary,
            cached: nil,
            lastKnownGood: try Self.payload(for: lastKnownGoodPack, source: .lastKnownGood)
        )
        let queryResponse = SourceAtlasQueryEngine(packs: [lastKnownGoodPack]).query(SourceAtlasQuery(domainID: "sports"))
        let runtime = SourceAtlasOfflineFallbackRuntimeResult(
            loadResult: loadResult,
            queryResponse: queryResponse
        )

        XCTAssertEqual(runtime.selectedStoreSource, .lastKnownGood)
        XCTAssertEqual(runtime.storeSourceState, .stale)
        XCTAssertTrue(runtime.conditions.contains(.staleCache))
        XCTAssertTrue(runtime.conditions.contains(.corruptInvalidPack))
        XCTAssertTrue(runtime.blocksOfficialCurrentClaims)
        XCTAssertTrue(runtime.blocksCurrentUse)
    }

    func testMissingPackConditionDoesNotCollapseIntoCorruptPack() {
        let loadResult = SourceAtlasStore().load(bundled: nil, cached: nil, lastKnownGood: nil)
        let queryResponse = SourceAtlasQueryEngine(packs: []).query(SourceAtlasQuery(domainID: "sports"))
        let runtime = SourceAtlasOfflineFallbackRuntimeResult(
            loadResult: loadResult,
            queryResponse: queryResponse
        )

        XCTAssertEqual(runtime.conditions, [.missingPack])
        XCTAssertFalse(runtime.conditions.contains(.corruptInvalidPack))
    }

    func testCorruptOrInvalidPackConditionIsDistinctFromMissingPack() {
        let data = Data("{not-json".utf8)
        let loadResult = SourceAtlasStore().load(
            bundled: SourceAtlasStorePayload(
                source: .bundled,
                data: data,
                declaredSHA256: SourceAtlasStore.sha256Hex(for: data)
            ),
            cached: nil,
            lastKnownGood: nil
        )
        let queryResponse = SourceAtlasQueryEngine(packs: []).query(SourceAtlasQuery(domainID: "sports"))
        let runtime = SourceAtlasOfflineFallbackRuntimeResult(
            loadResult: loadResult,
            queryResponse: queryResponse
        )

        XCTAssertTrue(runtime.conditions.contains(.missingPack))
        XCTAssertTrue(runtime.conditions.contains(.corruptInvalidPack))
        XCTAssertEqual(loadResult.quarantines.first?.reason, .corruptJSON)
    }

    func testRuntimePreservesDistinctSourceAndFreshnessStates() {
        let pack = Self.pack(
            claims: [
                Self.claim(id: "claim-unknown", state: .unknown, freshness: .unknown),
                Self.claim(id: "claim-needed", state: .sourceNeeded, freshness: .current),
                Self.claim(id: "claim-stale", state: .stale, freshness: .stale, sourceIDs: ["source-official"], reviewRequired: false),
                Self.claim(id: "claim-contradicted", state: .contradicted, freshness: .current, sourceIDs: ["source-official"], reviewRequired: false),
                Self.claim(id: "claim-revoked", state: .revoked, freshness: .revoked, sourceIDs: ["source-official"], reviewRequired: false),
                Self.claim(id: "claim-local", state: .verifiedByLocalProof, freshness: .current, sourceIDs: ["source-official"], reviewRequired: false)
            ],
            requirements: [
                Self.requirement(id: "requirement-unknown", claimID: "claim-unknown", sourceState: .unknown, freshnessState: .unknown),
                Self.requirement(id: "requirement-needed", claimID: "claim-needed", sourceState: .sourceNeeded),
                Self.requirement(id: "requirement-stale", claimID: "claim-stale", sourceState: .stale, freshnessState: .stale),
                Self.requirement(id: "requirement-contradicted", claimID: "claim-contradicted", sourceState: .contradicted),
                Self.requirement(id: "requirement-revoked", claimID: "claim-revoked", sourceState: .revoked, freshnessState: .stale),
                Self.requirement(id: "requirement-local", claimID: "claim-local", sourceState: .locallyProven)
            ]
        )
        let loadResult = SourceAtlasStoreLoadResult(
            pack: pack,
            selectedSource: .bundled,
            sourceState: .unknown,
            quarantines: []
        )

        XCTAssertEqual(Self.runtimeSourceState("requirement-unknown", pack: pack, loadResult: loadResult), .unknown)
        XCTAssertEqual(Self.runtimeSourceState("requirement-needed", pack: pack, loadResult: loadResult), .sourceNeeded)
        XCTAssertEqual(Self.runtimeSourceState("requirement-stale", pack: pack, loadResult: loadResult), .stale)
        XCTAssertEqual(Self.runtimeSourceState("requirement-contradicted", pack: pack, loadResult: loadResult), .contradicted)
        XCTAssertEqual(Self.runtimeSourceState("requirement-revoked", pack: pack, loadResult: loadResult), .revoked)
        XCTAssertEqual(Self.runtimeSourceState("requirement-local", pack: pack, loadResult: loadResult), .locallyProven)
    }
}

private extension SourceAtlasOfflineFallbackRuntimeModelsTests {
    static func runtimeSourceState(
        _ requirementID: String,
        pack: SourceAtlasPack,
        loadResult: SourceAtlasStoreLoadResult
    ) -> SourceAtlasRequirementSourceState {
        SourceAtlasOfflineFallbackRuntimeResult(
            loadResult: loadResult,
            queryResponse: SourceAtlasQueryEngine(packs: [pack]).query(SourceAtlasQuery(requirementID: requirementID))
        ).selectedSourceState
    }

    static func loadedResult(for pack: SourceAtlasPack) throws -> SourceAtlasStoreLoadResult {
        SourceAtlasStore().load(
            bundled: try payload(for: pack, source: .bundled),
            cached: nil,
            lastKnownGood: nil
        )
    }

    static func payload(
        for pack: SourceAtlasPack,
        source: SourceAtlasStorePayloadSource,
        declaredSHA256: String? = nil
    ) throws -> SourceAtlasStorePayload {
        let data = try JSONEncoder().encode(pack)
        return SourceAtlasStorePayload(
            source: source,
            data: data,
            declaredSHA256: declaredSHA256 ?? SourceAtlasStore.sha256Hex(for: data)
        )
    }

    static func pack(
        manifestID: String = "sports.pickleball.domain",
        sources: [SourceAtlasSourceRecord] = [
            SourceAtlasSourceRecord(
                id: "source-official",
                title: "Official source",
                kind: .official,
                locator: "https://example.test/source",
                retrievedAt: "2026-05-06T20:00:00Z",
                contentHash: "hash",
                approvedForOfficialClaims: true
            )
        ],
        claims: [SourceAtlasClaim] = [
            claim(id: "claim-current", state: .official, freshness: .current, sourceIDs: ["source-official"], reviewRequired: false)
        ],
        requirements: [SourceAtlasRequirement] = [
            requirement(id: "requirement-current", claimID: "claim-current", sourceState: .officialCurrent, reviewState: .approved)
        ]
    ) -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: manifestID,
                title: "Pickleball Domain",
                kind: .domainPack,
                version: "1.0.0",
                domainID: "sports"
            ),
            sources: sources,
            claims: claims,
            requirements: requirements,
            starterItems: [
                SourceAtlasStarterItem(
                    id: "starter",
                    title: "Start",
                    stepCandidateSeed: "Practice the sourced step.",
                    storesFinalSchedule: false
                )
            ],
            proofMap: requirements.map {
                SourceAtlasProofMapEntry(
                    id: "proof-\($0.id)",
                    requirementID: $0.id,
                    proofDescription: "Requirement source proof.",
                    proofCandidate: .sourceEvidence,
                    proofStrength: .officialCertified,
                    sourceRecordIDs: sourceIDs(for: $0.claimID, claims: claims),
                    sourceClaimIDs: [$0.claimID]
                )
            },
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection-starter",
                    goalIntent: "starter_goal",
                    requiredPackIDs: [manifestID],
                    projectionProfiles: []
                )
            ],
            freshnessPolicy: SourceAtlasFreshnessPolicy(
                reviewIntervalDays: 180,
                staleBlocksHighRiskUse: true
            ),
            riskPolicy: SourceAtlasRiskPolicy(
                strictReviewRiskClasses: SourceAtlasRiskClass.allCases.filter(\.requiresStrictReview)
            ),
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Source needed.",
                reviewRequired: "Review required.",
                notProfessionalAdvice: "Planning support only."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["node"],
                overlayDependencyIDs: ["overlay"],
                projectionRecipeIDs: ["projection-starter"],
                ownsIndividualGoalPhrase: false
            )
        )
    }

    static func sourceIDs(for claimID: String, claims: [SourceAtlasClaim]) -> [String] {
        claims.first(where: { $0.id == claimID })?.sourceIDs ?? []
    }

    static func claim(
        id: String,
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        sourceIDs: [String] = [],
        reviewRequired: Bool = true
    ) -> SourceAtlasClaim {
        SourceAtlasClaim(
            id: id,
            text: "\(id) source claim.",
            state: state,
            freshness: freshness,
            riskClass: .sportRules,
            sourceIDs: sourceIDs,
            reviewRequired: reviewRequired
        )
    }

    static func requirement(
        id: String,
        claimID: String,
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState = .current,
        reviewState: SourceAtlasRequirementReviewState = .approved
    ) -> SourceAtlasRequirement {
        SourceAtlasRequirement(
            id: id,
            claimID: claimID,
            title: "\(id) requirement",
            kind: .hard,
            required: true,
            sourceState: sourceState,
            freshnessState: freshnessState,
            riskState: .low,
            reviewState: reviewState
        )
    }
}
