import XCTest
@testable import Ambitions

final class SourceAtlasStoreModelsTests: XCTestCase {
    private let store = SourceAtlasStore()

    func testValidBundledLoadReturnsOfficialCurrentState() throws {
        let pack = Self.validPack()
        let result = store.load(bundled: try Self.payload(for: pack, source: .bundled), cached: nil, lastKnownGood: nil)

        XCTAssertEqual(result.selectedSource, .bundled)
        XCTAssertEqual(result.pack?.id, pack.id)
        XCTAssertEqual(result.sourceState, .officialCurrent)
        XCTAssertTrue(result.quarantines.isEmpty)
    }

    func testValidCachedLoadWinsOverBundledLoad() throws {
        let bundled = Self.validPack(manifestID: "sports.pickleball.bundled")
        let cached = Self.validPack(manifestID: "sports.pickleball.cached")
        let result = store.load(
            bundled: try Self.payload(for: bundled, source: .bundled),
            cached: try Self.payload(for: cached, source: .cached),
            lastKnownGood: nil
        )

        XCTAssertEqual(result.selectedSource, .cached)
        XCTAssertEqual(result.pack?.id, cached.id)
        XCTAssertEqual(result.sourceState, .officialCurrent)
    }

    func testMissingPackReturnsSourceNeededFallback() {
        let result = store.load(bundled: nil, cached: nil, lastKnownGood: nil)

        XCTAssertNil(result.pack)
        XCTAssertNil(result.selectedSource)
        XCTAssertEqual(result.sourceState, .sourceNeeded)
        XCTAssertEqual(Set(result.quarantines.map(\.reason)), [.missingPayload])
    }

    func testCorruptJSONQuarantinesAndFallsBackToSourceNeeded() {
        let data = Data("{not-json".utf8)
        let payload = SourceAtlasStorePayload(
            source: .bundled,
            data: data,
            declaredSHA256: SourceAtlasStore.sha256Hex(for: data)
        )
        let result = store.load(bundled: payload, cached: nil, lastKnownGood: nil)

        XCTAssertNil(result.pack)
        XCTAssertEqual(result.sourceState, .sourceNeeded)
        XCTAssertEqual(result.quarantines, [
            SourceAtlasStoreQuarantine(source: .bundled, reason: .corruptJSON)
        ])
    }

    func testUnsupportedSchemaQuarantinesPayload() throws {
        let result = store.load(
            bundled: try Self.payload(
                for: Self.validPack(
                    manifest: SourceAtlasPackManifest(
                        id: "sports.pickleball.old",
                        title: "Old Pickleball Domain",
                        kind: .domainPack,
                        version: "1.0.0",
                        domainID: "sports",
                        schemaVersion: "source_atlas_pack.native.v0"
                    )
                ),
                source: .bundled
            ),
            cached: nil,
            lastKnownGood: nil
        )

        XCTAssertNil(result.pack)
        XCTAssertEqual(result.sourceState, .sourceNeeded)
        XCTAssertEqual(result.quarantines.first?.reason, .unsupportedSchema)
    }

    func testHashMismatchQuarantinesPayloadBeforeDecode() throws {
        let result = store.load(
            bundled: try Self.payload(for: Self.validPack(), source: .bundled, declaredSHA256: "bad-hash"),
            cached: nil,
            lastKnownGood: nil
        )

        XCTAssertNil(result.pack)
        XCTAssertEqual(result.sourceState, .sourceNeeded)
        XCTAssertEqual(result.quarantines.first?.reason, .hashMismatch)
    }

    func testInvalidPackQuarantinesValidatorIssues() throws {
        let invalid = Self.validPack(
            sources: [
                SourceAtlasSourceRecord(
                    id: "source-candidate",
                    title: "Candidate source",
                    kind: .candidate,
                    locator: "ambitions://candidate",
                    approvedForOfficialClaims: false
                )
            ],
            claims: [
                SourceAtlasClaim(
                    id: "claim-serve",
                    text: "Serve rules require a source-backed rules overlay.",
                    state: .official,
                    freshness: .current,
                    riskClass: .sportRules,
                    sourceIDs: ["source-candidate"],
                    reviewRequired: false
                )
            ]
        )
        let result = store.load(bundled: try Self.payload(for: invalid, source: .bundled), cached: nil, lastKnownGood: nil)

        XCTAssertNil(result.pack)
        XCTAssertEqual(result.sourceState, .sourceNeeded)
        XCTAssertEqual(result.quarantines.first?.reason, .invalidPack)
        XCTAssertEqual(result.quarantines.first?.validationIssues, [.officialClaimWithoutApprovedSource])
    }

    func testLastKnownGoodReturnsStaleFallbackWhenPrimaryIsInvalid() throws {
        let primary = try Self.payload(for: Self.validPack(), source: .bundled, declaredSHA256: "bad-hash")
        let lastKnownGood = Self.validPack(manifestID: "sports.pickleball.last-known-good")
        let result = store.load(
            bundled: primary,
            cached: nil,
            lastKnownGood: try Self.payload(for: lastKnownGood, source: .lastKnownGood)
        )

        XCTAssertEqual(result.selectedSource, .lastKnownGood)
        XCTAssertEqual(result.pack?.id, lastKnownGood.id)
        XCTAssertEqual(result.sourceState, .stale)
        XCTAssertEqual(result.quarantines.first?.reason, .hashMismatch)
    }

    func testRevokedAndContradictedPayloadsAreQuarantinedAsBlockingStates() throws {
        let revoked = Self.validPack(
            claims: [
                SourceAtlasClaim(
                    id: "claim-serve",
                    text: "Serve rule was revoked.",
                    state: .revoked,
                    freshness: .revoked,
                    riskClass: .sportRules,
                    sourceIDs: ["source-official"],
                    reviewRequired: false
                )
            ]
        )
        let contradicted = Self.validPack(
            claims: [
                SourceAtlasClaim(
                    id: "claim-serve",
                    text: "Serve rule is contradicted.",
                    state: .contradicted,
                    freshness: .disputed,
                    riskClass: .sportRules,
                    sourceIDs: ["source-official"],
                    reviewRequired: false
                )
            ]
        )

        let revokedResult = store.load(bundled: try Self.payload(for: revoked, source: .bundled), cached: nil, lastKnownGood: nil)
        let contradictedResult = store.load(bundled: try Self.payload(for: contradicted, source: .bundled), cached: nil, lastKnownGood: nil)

        XCTAssertEqual(revokedResult.quarantines.first?.reason, .revoked)
        XCTAssertEqual(revokedResult.sourceState, .sourceNeeded)
        XCTAssertEqual(contradictedResult.quarantines.first?.reason, .contradicted)
        XCTAssertEqual(contradictedResult.sourceState, .sourceNeeded)
    }

    func testLocallyProvenStateStaysDistinctFromSourceBackedCurrentStates() {
        XCTAssertEqual(SourceAtlasStoreSourceState(requirementSourceState: .locallyProven), .locallyProven)
        XCTAssertNotEqual(SourceAtlasStoreSourceState(requirementSourceState: .locallyProven), .officialCurrent)
        XCTAssertNotEqual(SourceAtlasStoreSourceState(requirementSourceState: .locallyProven), .current)
    }
}

private extension SourceAtlasStoreModelsTests {
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

    static func validPack(
        manifestID: String = "sports.pickleball.domain",
        manifest: SourceAtlasPackManifest? = nil,
        sources: [SourceAtlasSourceRecord]? = nil,
        claims: [SourceAtlasClaim]? = nil,
        requirements: [SourceAtlasRequirement]? = nil
    ) -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: manifest ?? SourceAtlasPackManifest(
                id: manifestID,
                title: "Pickleball Domain",
                kind: .domainPack,
                version: "1.0.0",
                domainID: "sports"
            ),
            sources: sources ?? [
                SourceAtlasSourceRecord(
                    id: "source-official",
                    title: "Official pickleball rules",
                    kind: .official,
                    locator: "https://example.test/rules",
                    retrievedAt: "2026-05-06T20:00:00Z",
                    contentHash: "hash",
                    approvedForOfficialClaims: true
                )
            ],
            claims: claims ?? [
                SourceAtlasClaim(
                    id: "claim-serve",
                    text: "Serve rules require a source-backed rules overlay.",
                    state: .official,
                    freshness: .current,
                    riskClass: .sportRules,
                    sourceIDs: ["source-official"],
                    reviewRequired: false
                )
            ],
            requirements: requirements ?? [
                SourceAtlasRequirement(
                    id: "requirement-serve",
                    claimID: "claim-serve",
                    title: "Understand serve rule",
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
                    id: "starter-serve",
                    title: "Practice a legal serve motion",
                    stepCandidateSeed: "Practice serve form with reviewable rule source.",
                    storesFinalSchedule: false
                )
            ],
            proofMap: [
                SourceAtlasProofMapEntry(
                    id: "proof-serve",
                    requirementID: "requirement-serve",
                    proofDescription: "Video or self-reviewed practice note.",
                    privacyClass: .privateLife,
                    proofCandidate: .sourceEvidence,
                    proofStrength: .officialCertified,
                    capabilityNodeID: "capability-serve",
                    sourceRecordIDs: ["source-official"],
                    sourceClaimIDs: ["claim-serve"],
                    correctionHookIDs: ["hook-correct-proof-serve"],
                    revocationHookIDs: ["hook-revoke-proof-serve"],
                    evidenceLedgerBridgeIDs: ["ledger-proof-serve"]
                )
            ],
            projections: [
                SourceAtlasGoalProjection(
                    id: "recipe-pickleball-starter",
                    goalIntent: "starter_goal",
                    requiredPackIDs: [manifest?.id ?? manifestID],
                    projectionProfiles: [
                        SourceAtlasProjectionProfile(
                            id: "profile-pickleball-starter",
                            profileTitle: "starter_goal-profile",
                            sourceState: .officialCurrent,
                            freshnessState: .current,
                            riskState: .low,
                            reviewState: .approved,
                            producesPersonalPathInstance: true,
                            producesProjectionReceipt: true,
                            optionValueMap: SourceAtlasOptionValueMap(
                                id: "map-profile-pickleball-starter",
                                values: ["cadence": "steady"],
                                sourceState: .officialCurrent,
                                freshnessState: .current,
                                reviewState: .approved,
                                riskState: .low
                            ),
                            personalPathInstances: [
                                SourceAtlasPersonalPathInstance(
                                    id: "path-profile-pickleball-starter",
                                    personalPathTemplateID: "template-profile-pickleball-starter",
                                    stepCandidateSeeds: [
                                        SourceAtlasStepCandidateSeed(
                                            id: "seed-profile-pickleball-starter",
                                            stepCandidate: "Practice a goal-aligned path for starter_goal."
                                        )
                                    ],
                                    sourceState: .officialCurrent,
                                    freshnessState: .current,
                                    reviewState: .approved,
                                    riskState: .low,
                                    sourceRecordIDs: ["source-official"]
                                )
                            ]
                        )
                    ]
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
                sourceNeeded: "Official requirements need a source.",
                reviewRequired: "Review before using this for recommendations.",
                notProfessionalAdvice: "This is planning support, not professional advice."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["pickleball.serve", "pickleball.rules"],
                overlayDependencyIDs: ["sports.pickleball.rules"],
                projectionRecipeIDs: ["recipe-pickleball-starter"],
                ownsIndividualGoalPhrase: false,
                requirementOverlays: []
            )
        )
    }
}
