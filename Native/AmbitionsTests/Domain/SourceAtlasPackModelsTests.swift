import XCTest
@testable import Ambitions

final class SourceAtlasPackModelsTests: XCTestCase {
    func testSamplePackDecodesAndValidates() throws {
        let data = try JSONEncoder().encode(Self.validPack())
        let decoded = try JSONDecoder().decode(SourceAtlasPack.self, from: data)

        XCTAssertEqual(decoded.manifest.schemaVersion, sourceAtlasPackSchemaVersion)
        XCTAssertTrue(decoded.validationIssues.isEmpty)
        XCTAssertTrue(decoded.isValidForRuntimeUse)
        XCTAssertNoThrow(try decoded.validatedForUse())
        XCTAssertEqual(decoded.claims.first?.canDriveCurrentRecommendation, true)
    }

    func testUnsupportedSchemaIsRejectedByValidator() {
        var pack = Self.validPack()
        pack = SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: pack.manifest.id,
                title: pack.manifest.title,
                kind: pack.manifest.kind,
                version: pack.manifest.version,
                domainID: pack.manifest.domainID,
                schemaVersion: "source_atlas_pack.native.v0"
            ),
            sources: pack.sources,
            claims: pack.claims,
            requirements: pack.requirements,
            starterItems: pack.starterItems,
            proofMap: pack.proofMap,
            projectionRecipes: pack.projectionRecipes,
            freshnessPolicy: pack.freshnessPolicy,
            riskPolicy: pack.riskPolicy,
            disclosureCopy: pack.disclosureCopy,
            runtimeBoundary: pack.runtimeBoundary,
            composition: pack.composition
        )

        XCTAssertTrue(pack.validationIssues.contains(.unsupportedSchema))
        XCTAssertFalse(pack.isValidForRuntimeUse)
        XCTAssertThrowsError(try pack.validatedForUse()) { error in
            XCTAssertEqual(
                (error as? SourceAtlasPackValidator.ValidationError)?.issues,
                [.unsupportedSchema]
            )
        }
    }

    func testOfficialClaimRequiresApprovedOfficialSource() {
        let pack = Self.validPack(
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
                    id: "claim-official",
                    text: "Official claim without approved source.",
                    state: .official,
                    freshness: .current,
                    riskClass: .sportRules,
                    sourceIDs: ["source-candidate"],
                    reviewRequired: false
                )
            ]
        )

        XCTAssertTrue(pack.validationIssues.contains(.officialClaimWithoutApprovedSource))
    }

    func testHighRiskClaimCannotSkipReview() {
        let pack = Self.validPack(
            claims: [
                SourceAtlasClaim(
                    id: "claim-certification",
                    text: "Certification eligibility claim.",
                    state: .official,
                    freshness: .current,
                    riskClass: .certificationEligibility,
                    sourceIDs: ["source-official"],
                    reviewRequired: false
                )
            ]
        )

        XCTAssertTrue(pack.validationIssues.contains(.highRiskClaimWithoutReview))
    }

    func testCompositionRejectsOnePackPerGoalAndUniversalSchedules() {
        let pack = Self.validPack(
            starterItems: [
                SourceAtlasStarterItem(
                    id: "scheduled-step",
                    title: "Do this every Monday at 8",
                    stepCandidateSeed: "Universal schedule",
                    storesFinalSchedule: true
                )
            ],
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: [],
                overlayDependencyIDs: [],
                projectionRecipeIDs: [],
                ownsIndividualGoalPhrase: true
            )
        )

        XCTAssertTrue(pack.validationIssues.contains(.onePackPerGoalRisk))
        XCTAssertTrue(pack.validationIssues.contains(.missingCompositionContract))
        XCTAssertTrue(pack.validationIssues.contains(.universalScheduledStep))
    }

    func testProjectionRecipesMustProduceReceipts() {
        let pack = Self.validPack(
            projectionRecipes: [
                SourceAtlasProjectionRecipe(
                    id: "recipe-no-receipt",
                    goalIntent: "starter_goal",
                    requiredPackIDs: ["sports.pickleball.domain"],
                    producesPersonalPathInstance: true,
                    producesProjectionReceipt: false
                )
            ]
        )

        XCTAssertTrue(pack.validationIssues.contains(.projectionRecipeMissingReceipt))
    }

    func testRuntimeStoreBehaviorIsRejected() {
        let pack = Self.validPack(
            runtimeBoundary: SourceAtlasRuntimeBoundary(
                storesUserData: true,
                performsNetworkFetches: false,
                mutatesPlans: false,
                writesPersistence: true
            )
        )

        XCTAssertTrue(pack.validationIssues.contains(.runtimeStoreBehavior))
        XCTAssertFalse(pack.isValidForRuntimeUse)
    }

    func testTransitionToConfidenceStateRequiresProvenanceAndLocalProofEvidence() {
        let claim = SourceAtlasClaim(
            id: "claim-locked",
            text: "Candidate claim waiting for source.",
            state: .sourceNeeded,
            freshness: .current,
            riskClass: .hobby,
            sourceIDs: []
        )

        XCTAssertFalse(claim.canTransition(to: .official))
        XCTAssertTrue(claim.canTransition(to: .sourced))
        XCTAssertFalse(claim.canTransition(to: .verifiedByLocalProof))

        let claimWithEvidence = SourceAtlasClaim(
            id: "claim-upgraded",
            text: "Candidate claim waiting for source.",
            state: .sourced,
            freshness: .current,
            riskClass: .hobby,
            sourceIDs: ["source-official"]
        )
        XCTAssertTrue(claimWithEvidence.canTransition(to: .official))
        XCTAssertTrue(
            claimWithEvidence.canTransition(
                to: .verifiedByLocalProof,
                hasProvenanceEvidence: true,
                hasLocalProofEvidence: true
            )
        )
    }

    func testStaleAndDefaultStatesDoNotDriveCurrentRecommendation() {
        let staleClaim = SourceAtlasClaim(
            id: "claim-stale",
            text: "Outdated",
            state: .stale,
            freshness: .stale,
            riskClass: .hobby
        )
        let unknownClaim = SourceAtlasClaim(
            id: "claim-unknown",
            text: "Needs evidence",
            state: .unknown,
            freshness: .unknown,
            riskClass: .hobby
        )
        let userProvided = SourceAtlasClaim(
            id: "claim-user",
            text: "User provided.",
            state: .userProvided,
            freshness: .current,
            riskClass: .hobby,
            reviewRequired: false
        )
        let inferred = SourceAtlasClaim(
            id: "claim-inferred",
            text: "Inferred",
            state: .inferred,
            freshness: .current,
            riskClass: .hobby,
            reviewRequired: false
        )
        let ocrDerived = SourceAtlasClaim(
            id: "claim-ocr",
            text: "OCR derived",
            state: .ocrDerived,
            freshness: .current,
            riskClass: .hobby,
            reviewRequired: false
        )

        XCTAssertFalse(staleClaim.canDriveCurrentRecommendation)
        XCTAssertFalse(unknownClaim.canDriveCurrentRecommendation)
        XCTAssertFalse(userProvided.canDriveCurrentRecommendation)
        XCTAssertFalse(inferred.canDriveCurrentRecommendation)
        XCTAssertFalse(ocrDerived.canDriveCurrentRecommendation)
        XCTAssertFalse(SourceAtlasClaim(
            id: "claim-revoked",
            text: "Revoked",
            state: .revoked,
            freshness: .current,
            riskClass: .hobby,
            sourceIDs: ["source-official"],
            reviewRequired: false
        ).canDriveCurrentRecommendation)
        XCTAssertFalse(SourceAtlasClaim(
            id: "claim-disputed",
            text: "Disputed",
            state: .disputed,
            freshness: .current,
            riskClass: .hobby,
            sourceIDs: ["source-official"],
            reviewRequired: false
        ).canDriveCurrentRecommendation)
    }

    func testCanonIntegrationIsRequired() {
        let pack = Self.validPack(
            manifest: SourceAtlasPackManifest(
                id: "sports.pickleball.domain",
                title: "Pickleball Domain",
                kind: .domainPack,
                version: "1.0.0",
                domainID: "sports",
                canonDocumentIDs: ["docs/canon/Ambitions_Source_Atlas.md"]
            )
        )

        XCTAssertTrue(pack.validationIssues.contains(.missingCanonIntegration))
    }
}

private extension SourceAtlasPackModelsTests {
    static func validPack(
        manifest: SourceAtlasPackManifest? = nil,
        sources: [SourceAtlasSourceRecord]? = nil,
        claims: [SourceAtlasClaim]? = nil,
        starterItems: [SourceAtlasStarterItem]? = nil,
        projectionRecipes: [SourceAtlasProjectionRecipe]? = nil,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        composition: SourceAtlasCompositionContract? = nil
    ) -> SourceAtlasPack {
        SourceAtlasPack(
            manifest: manifest ?? SourceAtlasPackManifest(
                id: "sports.pickleball.domain",
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
            requirements: [
                SourceAtlasRequirement(
                    id: "requirement-serve",
                    claimID: "claim-serve",
                    title: "Understand serve rule",
                    kind: "rule",
                    required: true
                )
            ],
            starterItems: starterItems ?? [
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
                    privacyClass: .privateLife
                )
            ],
            projectionRecipes: projectionRecipes ?? [
                SourceAtlasProjectionRecipe(
                    id: "recipe-pickleball-starter",
                    goalIntent: "starter_goal",
                    requiredPackIDs: ["sports.pickleball.domain"],
                    producesPersonalPathInstance: true,
                    producesProjectionReceipt: true
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
            runtimeBoundary: runtimeBoundary,
            composition: composition ?? SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["pickleball.serve", "pickleball.rules"],
                overlayDependencyIDs: ["sports.pickleball.rules"],
                projectionRecipeIDs: ["recipe-pickleball-starter"],
                ownsIndividualGoalPhrase: false
            )
        )
    }
}
