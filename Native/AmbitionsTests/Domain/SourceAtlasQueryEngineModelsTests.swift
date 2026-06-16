import XCTest
@testable import Ambitions

final class SourceAtlasQueryEngineModelsTests: XCTestCase {
    func testRanksCurrentSourceBackedCandidateBeforeBlockedCandidate() {
        let pack = Self.pack(
            claims: [
                Self.claim(id: "claim-current", state: .official, freshness: .current, sourceIDs: ["source-official"], reviewRequired: false),
                Self.claim(id: "claim-stale", state: .stale, freshness: .stale, sourceIDs: ["source-official"], reviewRequired: false)
            ],
            requirements: [
                Self.requirement(id: "requirement-current", claimID: "claim-current", sourceState: .officialCurrent, freshnessState: .current, reviewState: .approved),
                Self.requirement(id: "requirement-stale", claimID: "claim-stale", sourceState: .stale, freshnessState: .stale, reviewState: .approved)
            ]
        )

        let response = SourceAtlasQueryEngine(packs: [pack]).query(
            SourceAtlasQuery(goalIntent: "starter_goal", domainID: "sports")
        )

        XCTAssertEqual(response.selectedResult.requirementID, "requirement-current")
        XCTAssertEqual(response.selectedResult.sourceState, .officialCurrent)
        XCTAssertEqual(response.selectedResult.freshnessState, .current)
        XCTAssertEqual(response.selectedResult.reviewState, .approved)
        XCTAssertEqual(response.selectedResult.provenanceSourceIDs, ["source-official"])
        XCTAssertNil(response.selectedResult.fallbackReason)
        XCTAssertEqual(response.results.map(\.requirementID), ["requirement-current", "requirement-stale"])
    }

    func testKeepsSourceNeededUnknownStaleContradictedRevokedAndLocalProofDistinct() {
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
                Self.requirement(id: "requirement-local", claimID: "claim-local", sourceState: .locallyProven, reviewState: .approved)
            ]
        )

        let resultsByRequirement = Dictionary(
            uniqueKeysWithValues: SourceAtlasQueryEngine(packs: [pack])
                .results(matching: SourceAtlasQuery(domainID: "sports"))
                .compactMap { result in result.requirementID.map { ($0, result) } }
        )

        XCTAssertEqual(resultsByRequirement["requirement-unknown"]?.sourceState, .unknown)
        XCTAssertEqual(resultsByRequirement["requirement-needed"]?.sourceState, .sourceNeeded)
        XCTAssertEqual(resultsByRequirement["requirement-stale"]?.sourceState, .stale)
        XCTAssertEqual(resultsByRequirement["requirement-contradicted"]?.sourceState, .contradicted)
        XCTAssertEqual(resultsByRequirement["requirement-revoked"]?.sourceState, .revoked)
        XCTAssertEqual(resultsByRequirement["requirement-local"]?.sourceState, .locallyProven)
        XCTAssertEqual(resultsByRequirement["requirement-needed"]?.fallbackReason, .sourceNeeded)
        XCTAssertEqual(resultsByRequirement["requirement-unknown"]?.fallbackReason, .unknown)
        XCTAssertEqual(resultsByRequirement["requirement-stale"]?.fallbackReason, .stale)
        XCTAssertEqual(resultsByRequirement["requirement-contradicted"]?.fallbackReason, .contradicted)
        XCTAssertEqual(resultsByRequirement["requirement-revoked"]?.fallbackReason, .revoked)
        XCTAssertNil(resultsByRequirement["requirement-local"]?.fallbackReason)
        XCTAssertNil(resultsByRequirement["requirement-unknown"]?.sourceNeededDetail)
        XCTAssertNil(resultsByRequirement["requirement-stale"]?.sourceNeededDetail)
        XCTAssertNil(resultsByRequirement["requirement-contradicted"]?.sourceNeededDetail)
        XCTAssertNil(resultsByRequirement["requirement-revoked"]?.sourceNeededDetail)
    }

    func testOfficialCurrentRequiresApprovedSourceFreshnessAndReviewSupport() throws {
        let pack = Self.pack(
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
                Self.claim(id: "claim-official", state: .official, freshness: .current, sourceIDs: ["source-candidate"], reviewRequired: false)
            ],
            requirements: [
                Self.requirement(id: "requirement-official", claimID: "claim-official", sourceState: .officialCurrent, freshnessState: .current, reviewState: .approved)
            ]
        )

        let result = try XCTUnwrap(
            SourceAtlasQueryEngine(packs: [pack])
                .results(matching: SourceAtlasQuery(requirementID: "requirement-official"))
                .first
        )

        XCTAssertEqual(result.sourceState, .official)
        XCTAssertNotEqual(result.sourceState, .officialCurrent)
        XCTAssertEqual(result.fallbackReason, .noCurrentCandidate)
        XCTAssertEqual(result.provenanceSourceIDs, ["source-candidate"])
        XCTAssertEqual(result.sourceNeededDetail?.mode, .starterGuidanceOnly)
        XCTAssertEqual(result.sourceNeededDetail?.fallbackReason, .noCurrentCandidate)
        XCTAssertEqual(result.sourceNeededDetail?.blocksOfficialCurrentClaims, true)
        XCTAssertEqual(result.sourceNeededDetail?.blocksCurrentUse, true)
    }

    func testSourceNeededModeWhenNoLoadedPacksExist() {
        let response = SourceAtlasQueryEngine(packs: []).query(
            SourceAtlasQuery(goalIntent: "starter_goal", domainID: "sports")
        )

        XCTAssertTrue(response.results.isEmpty)
        XCTAssertEqual(response.selectedResult.sourceState, .sourceNeeded)
        XCTAssertEqual(response.selectedResult.freshnessState, .unknown)
        XCTAssertEqual(response.selectedResult.reviewState, .required)
        XCTAssertEqual(response.selectedResult.provenanceSourceIDs, [])
        XCTAssertEqual(response.fallbackReason, .noLoadedPacks)
        XCTAssertEqual(response.selectedResult.sourceNeededDetail?.mode, .noLoadedPacks)
        XCTAssertEqual(response.selectedResult.sourceNeededDetail?.starterGuidance, [])
        XCTAssertEqual(response.selectedResult.sourceNeededDetail?.blocksOfficialCurrentClaims, true)
        XCTAssertEqual(response.selectedResult.sourceNeededDetail?.blocksCurrentUse, true)
        XCTAssertFalse(response.selectedResult.canSupportCurrentUse)
    }

    func testSourceNeededFallbackWhenNoMatchingCandidateExistsIncludesStarterGuidanceOnly() throws {
        let response = SourceAtlasQueryEngine(packs: [Self.pack()]).query(
            SourceAtlasQuery(goalIntent: "missing_goal", domainID: "sports")
        )
        let detail = try XCTUnwrap(response.selectedResult.sourceNeededDetail)

        XCTAssertTrue(response.results.isEmpty)
        XCTAssertEqual(response.selectedResult.sourceState, .sourceNeeded)
        XCTAssertEqual(response.selectedResult.freshnessState, .unknown)
        XCTAssertEqual(response.selectedResult.reviewState, .required)
        XCTAssertEqual(response.selectedResult.provenanceSourceIDs, [])
        XCTAssertEqual(response.fallbackReason, .sourceNeeded)
        XCTAssertEqual(detail.mode, .starterGuidanceOnly)
        XCTAssertEqual(detail.fallbackReason, .sourceNeeded)
        XCTAssertEqual(detail.blocksOfficialCurrentClaims, true)
        XCTAssertEqual(detail.blocksCurrentUse, true)
        XCTAssertEqual(detail.starterGuidance.count, 1)
        XCTAssertEqual(detail.starterGuidance.first?.starterItemID, "starter")
        XCTAssertEqual(detail.starterGuidance.first?.title, "Start")
        XCTAssertEqual(detail.starterGuidance.first?.stepCandidateSeed, "Practice the sourced step.")
        XCTAssertEqual(detail.starterGuidance.first?.storesFinalSchedule, false)
        XCTAssertEqual(detail.starterGuidance.first?.canSupportOfficialCurrentUse, false)
        XCTAssertFalse(response.selectedResult.canSupportCurrentUse)
    }

    func testOfficialCurrentClaimsRemainBlockedWhenProvenanceIsMissing() throws {
        let pack = Self.pack(
            claims: [
                Self.claim(id: "claim-official", state: .official, freshness: .current, reviewRequired: false)
            ],
            requirements: [
                Self.requirement(id: "requirement-official", claimID: "claim-official", sourceState: .officialCurrent, freshnessState: .current, reviewState: .approved)
            ]
        )

        let result = try XCTUnwrap(
            SourceAtlasQueryEngine(packs: [pack])
                .results(matching: SourceAtlasQuery(requirementID: "requirement-official"))
                .first
        )
        let detail = try XCTUnwrap(result.sourceNeededDetail)

        XCTAssertEqual(result.sourceState, .official)
        XCTAssertEqual(result.fallbackReason, .provenanceMissing)
        XCTAssertEqual(result.provenanceSourceIDs, [])
        XCTAssertEqual(detail.mode, .starterGuidanceOnly)
        XCTAssertEqual(detail.blocksOfficialCurrentClaims, true)
        XCTAssertEqual(detail.blocksCurrentUse, true)
        XCTAssertFalse(result.canSupportCurrentUse)
    }

    func testSupportsSourceRiskClaimAndRequirementQueryDimensions() {
        let pack = Self.pack(
            claims: [
                Self.claim(
                    id: "claim-career",
                    state: .official,
                    freshness: .current,
                    riskClass: .careerContext,
                    sourceIDs: ["source-official"],
                    reviewRequired: false
                ),
                Self.claim(
                    id: "claim-health",
                    state: .official,
                    freshness: .current,
                    riskClass: .healthMedical,
                    sourceIDs: ["source-health"],
                    reviewRequired: true
                )
            ],
            requirements: [
                Self.requirement(id: "requirement-career", claimID: "claim-career", sourceState: .officialCurrent, freshnessState: .current, riskState: .low, reviewState: .approved),
                Self.requirement(id: "requirement-health", claimID: "claim-health", sourceState: .officialCurrent, freshnessState: .current, riskState: .high, reviewState: .required)
            ]
        )

        let response = SourceAtlasQueryEngine(packs: [pack]).query(
            SourceAtlasQuery(
                claimID: "claim-career",
                requirementID: "requirement-career",
                sourceState: .officialCurrent,
                freshnessState: .current,
                riskClass: .careerContext,
                sourceID: "source-official"
            )
        )

        XCTAssertEqual(response.results.count, 1)
        XCTAssertEqual(response.selectedResult.claimID, "claim-career")
        XCTAssertEqual(response.selectedResult.requirementID, "requirement-career")
        XCTAssertEqual(response.selectedResult.riskClass, .careerContext)
        XCTAssertNil(response.selectedResult.fallbackReason)
    }

    func testEncodedResultsDoNotExposePercentageLanguage() throws {
        let response = SourceAtlasQueryEngine(packs: [Self.pack()]).query(SourceAtlasQuery(domainID: "sports"))
        let encoded = String(data: try JSONEncoder().encode(response), encoding: .utf8) ?? ""

        XCTAssertFalse(encoded.localizedCaseInsensitiveContains("mo" + "del"))
        XCTAssertFalse(encoded.localizedCaseInsensitiveContains("per" + "cent"))
        XCTAssertFalse(encoded.localizedCaseInsensitiveContains("con" + "fidence"))
    }
}

private extension SourceAtlasQueryEngineModelsTests {
    static func pack(
        sources: [SourceAtlasSourceRecord] = [
            SourceAtlasSourceRecord(
                id: "source-official",
                title: "Official source",
                kind: .official,
                locator: "https://example.test/source",
                retrievedAt: "2026-05-06T20:00:00Z",
                contentHash: "hash",
                approvedForOfficialClaims: true
            ),
            SourceAtlasSourceRecord(
                id: "source-health",
                title: "Health source",
                kind: .official,
                locator: "https://example.test/health",
                retrievedAt: "2026-05-06T20:00:00Z",
                contentHash: "hash-health",
                approvedForOfficialClaims: true
            )
        ],
        claims: [SourceAtlasClaim] = [
            claim(id: "claim-current", state: .official, freshness: .current, sourceIDs: ["source-official"], reviewRequired: false)
        ],
        requirements: [SourceAtlasRequirement] = [
            requirement(id: "requirement-current", claimID: "claim-current", sourceState: .officialCurrent, freshnessState: .current, reviewState: .approved)
        ]
    ) -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: "sports.pickleball.domain",
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
                let sourceIDs = sourceIDs(for: $0.claimID, claims: claims)
                return SourceAtlasProofMapEntry(
                    id: "proof-\($0.id)",
                    requirementID: $0.id,
                    proofDescription: "Requirement source proof.",
                    proofCandidate: .sourceEvidence,
                    proofStrength: .officialCertified,
                    sourceRecordIDs: sourceIDs,
                    sourceClaimIDs: [$0.claimID]
                )
            },
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection-starter",
                    goalIntent: "starter_goal",
                    requiredPackIDs: ["sports.pickleball.domain"],
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
                sourceNeeded: "Context needed.",
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
        riskClass: SourceAtlasRiskClass = .sportRules,
        sourceIDs: [String] = [],
        reviewRequired: Bool = true
    ) -> SourceAtlasClaim {
        SourceAtlasClaim(
            id: id,
            text: "\(id) source claim.",
            state: state,
            freshness: freshness,
            riskClass: riskClass,
            sourceIDs: sourceIDs,
            reviewRequired: reviewRequired
        )
    }

    static func requirement(
        id: String,
        claimID: String,
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState = .current,
        riskState: SourceAtlasRequirementRiskState = .low,
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
            riskState: riskState,
            reviewState: reviewState
        )
    }
}
