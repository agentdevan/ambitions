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
        XCTAssertFalse(SourceAtlasClaim(
            id: "claim-contradicted",
            text: "Contradicted",
            state: .contradicted,
            freshness: .current,
            riskClass: .hobby,
            sourceIDs: ["source-official"],
            reviewRequired: false
        ).canDriveCurrentRecommendation)
        XCTAssertFalse(SourceAtlasClaim(
            id: "claim-source-changed",
            text: "Source changed",
            state: .sourceChanged,
            freshness: .current,
            riskClass: .hobby,
            sourceIDs: ["source-official"],
            reviewRequired: false
        ).canDriveCurrentRecommendation)
    }

    func testStaleOrUnknownHighRiskClaimsDoNotDriveCurrentRecommendation() {
        let staleCriticalHighRisk = SourceAtlasClaim(
            id: "claim-stale-critical-risk",
            text: "Expired certification requirement",
            state: .official,
            freshness: .staleCritical,
            riskClass: .certificationEligibility,
            sourceIDs: ["source-official"],
            reviewRequired: false
        )
        let unknownHighRisk = SourceAtlasClaim(
            id: "claim-unknown-risk",
            text: "Unknown claim",
            state: .official,
            freshness: .unknown,
            riskClass: .certificationEligibility,
            sourceIDs: ["source-official"],
            reviewRequired: false
        )
        let stalePolicy = SourceAtlasFreshnessPolicy(reviewIntervalDays: 14, staleBlocksHighRiskUse: true)
        let riskPolicy = SourceAtlasRiskPolicy(
            strictReviewRiskClasses: SourceAtlasRiskClass.allCases.filter(\.requiresStrictReview)
        )

        XCTAssertFalse(staleCriticalHighRisk.canDriveCurrentRecommendation(using: stalePolicy, riskPolicy: riskPolicy))
        XCTAssertFalse(unknownHighRisk.canDriveCurrentRecommendation(using: stalePolicy, riskPolicy: riskPolicy))
    }

    func testDisclosureCopyDoesNotImplyReleaseOrCertificationClaims() {
        let pack = Self.validPack()
        let disclosureCopy = pack.disclosureCopy
        let allCopy = [
            disclosureCopy.sourceNeeded,
            disclosureCopy.reviewRequired,
            disclosureCopy.notProfessionalAdvice
        ]

        for phrase in allCopy {
            XCTAssertFalse(phrase.localizedCaseInsensitiveContains("release"))
            XCTAssertFalse(phrase.localizedCaseInsensitiveContains("certification"))
            XCTAssertFalse(phrase.localizedCaseInsensitiveContains("official certification"))
        }
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
        requirements: [SourceAtlasRequirement]? = nil,
        starterItems: [SourceAtlasStarterItem]? = nil,
        proofMap: [SourceAtlasProofMapEntry]? = nil,
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
            starterItems: starterItems ?? [
                SourceAtlasStarterItem(
                    id: "starter-serve",
                    title: "Practice a legal serve motion",
                    stepCandidateSeed: "Practice serve form with reviewable rule source.",
                    storesFinalSchedule: false
                )
            ],
            proofMap: proofMap ?? [
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
                ownsIndividualGoalPhrase: false,
                requirementOverlays: []
            )
        )
    }
}

extension SourceAtlasPackModelsTests {
    func testRequirementKindMetadataBlocksWeakOfficialStatesFromRecommendationDrive() {
        let requirement = SourceAtlasRequirement(
            id: "requirement-weak",
            claimID: "claim-serve",
            title: "Weakly sourced requirement",
            kind: .proof,
            required: true,
            sourceState: .sourceNeeded,
            freshnessState: .stale,
            riskState: .high,
            reviewState: .required
        )
        let weakPack = Self.validPack(
            requirements: [requirement],
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["pickleball.serve", "pickleball.rules"],
                overlayDependencyIDs: ["sports.pickleball.rules"],
                projectionRecipeIDs: ["recipe-pickleball-starter"],
                ownsIndividualGoalPhrase: false,
                requirementOverlays: [
                    SourceAtlasRequirementOverlay(
                        id: "overlay-weak-requirement",
                        sourceAtlasRequirementID: requirement.id,
                        requirementIDs: ["requirement-weak"],
                        summary: "Proof-first requirement",
                        sourceState: .sourceNeeded,
                        freshnessState: .stale,
                        riskState: .high,
                        reviewState: .required
                    )
                ]
            )
        )

        XCTAssertFalse(requirement.canDriveCurrentRecommendation)
        XCTAssertTrue(weakPack.validationIssues.contains(.invalidRequirementOverlay))
    }

    func testRequirementCannotUseOfficialCurrentStateWithoutClaimEvidence() {
        let sourceFreeClaim = SourceAtlasClaim(
            id: "claim-source-free",
            text: "Official requirement without source evidence.",
            state: .official,
            freshness: .current,
            riskClass: .sportRules,
            sourceIDs: [],
            reviewRequired: false
        )
        let requirement = SourceAtlasRequirement(
            id: "requirement-source-free",
            claimID: sourceFreeClaim.id,
            title: "Source-free official requirement",
            kind: .hard,
            required: true,
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved
        )
        let pack = Self.validPack(
            claims: [sourceFreeClaim],
            requirements: [requirement]
        )

        XCTAssertTrue(requirement.canDriveCurrentRecommendation)
        XCTAssertTrue(pack.validationIssues.contains(.officialClaimWithoutApprovedSource))
        XCTAssertTrue(pack.validationIssues.contains(.invalidRequirementOverlay))
    }

    func testProofWithoutSourceOrClaimBindingCannotCertifyCurrentRequirement() {
        let pack = Self.validPack(
            proofMap: [
                SourceAtlasProofMapEntry(
                    id: "proof-local-only",
                    requirementID: "requirement-serve",
                    proofDescription: "Local observation captured from user note.",
                    privacyClass: .privateLife,
                    proofCandidate: .localObservation,
                    proofStrength: .localOnly,
                    sourceRecordIDs: [],
                    sourceClaimIDs: []
                )
            ]
        )

        XCTAssertTrue(pack.validationIssues.contains(.proofCannotSupportCurrentRequirement))
    }

    func testRevokedClaimBlocksProofSupportForCurrentRequirement() {
        let revokedClaim = SourceAtlasClaim(
            id: "claim-revoked-proof",
            text: "This claim was revoked.",
            state: .revoked,
            freshness: .current,
            riskClass: .sportRules,
            sourceIDs: ["source-official"],
            reviewRequired: false
        )
        let claimBoundRequirement = SourceAtlasRequirement(
            id: "requirement-revoked-proof",
            claimID: revokedClaim.id,
            title: "Use revoked proof",
            kind: .hard,
            required: true,
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved
        )
        let stalePack = Self.validPack(
            claims: [revokedClaim],
            requirements: [claimBoundRequirement],
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["pickleball.serve", "pickleball.rules"],
                overlayDependencyIDs: ["sports.pickleball.rules"],
                projectionRecipeIDs: ["recipe-pickleball-starter"],
                ownsIndividualGoalPhrase: false,
                requirementOverlays: []
            ),
            proofMap: [
                SourceAtlasProofMapEntry(
                    id: "proof-revoked",
                    requirementID: claimBoundRequirement.id,
                    proofDescription: "Revoked claim proof candidate.",
                    privacyClass: .privateLife,
                    proofCandidate: .sourceEvidence,
                    proofStrength: .officialCertified,
                    sourceRecordIDs: ["source-official"],
                    sourceClaimIDs: [revokedClaim.id]
                )
            ]
        )

        XCTAssertEqual(stalePack.validationIssues.contains(.proofCannotSupportCurrentRequirement), true)
        XCTAssertEqual(stalePack.validationIssues.contains(.proofRequiresSourceOrClaimBinding), false)
        XCTAssertEqual(stalePack.validationIssues.contains(.invalidRequirementOverlay), true)
    }

    func testSourceNeededClaimCannotSupportCurrentRequirementProof() {
        let sourceNeededClaim = SourceAtlasClaim(
            id: "claim-source-needed-proof",
            text: "This claim still needs a source.",
            state: .sourceNeeded,
            freshness: .unknown,
            riskClass: .sportRules,
            sourceIDs: ["source-official"],
            reviewRequired: true
        )
        let proof = SourceAtlasProofMapEntry(
            id: "proof-source-needed",
            requirementID: "requirement-serve",
            proofDescription: "Candidate proof before source review.",
            privacyClass: .privateLife,
            proofCandidate: .sourceEvidence,
            proofStrength: .high,
            sourceRecordIDs: ["source-official"],
            sourceClaimIDs: [sourceNeededClaim.id]
        )

        XCTAssertFalse(proof.canSupportCurrentRequirement([sourceNeededClaim.id: sourceNeededClaim]))
    }

    func testSensitiveProofEntriesAreNotExternallyProjectable() {
        let sensitiveProof = SourceAtlasProofMapEntry(
            id: "proof-sensitive",
            requirementID: "requirement-serve",
            proofDescription: "Private source sensitive proof.",
            privacyClass: .sensitive,
            proofCandidate: .sourceEvidence,
            proofStrength: .officialCertified,
            sourceRecordIDs: ["source-official"],
            sourceClaimIDs: ["claim-serve"]
        )

        XCTAssertFalse(sensitiveProof.isExternalProjectionSafe)
        XCTAssertTrue(sensitiveProof.canSupportCurrentRequirement(
            [ "claim-serve": SourceAtlasClaim(
                id: "claim-serve",
                text: "Claimed serve rule.",
                state: .official,
                freshness: .current,
                riskClass: .sportRules,
                sourceIDs: ["source-official"],
                reviewRequired: false
            ) ]
        ))
    }

    func testCorrectionAndRevocationProofEntriesRequireBridgeHooks() {
        let pack = Self.validPack(
            proofMap: [
                SourceAtlasProofMapEntry(
                    id: "proof-requires-correction-hook",
                    requirementID: "requirement-serve",
                    proofDescription: "Correction artifact with missing hook.",
                    proofCandidate: .correctionArtifact,
                    proofStrength: .high,
                    sourceRecordIDs: ["source-official"],
                    sourceClaimIDs: ["claim-serve"]
                ),
                SourceAtlasProofMapEntry(
                    id: "proof-requires-revocation-hook",
                    requirementID: "requirement-serve",
                    proofDescription: "Revocation artifact with missing hook.",
                    proofCandidate: .revocationArtifact,
                    proofStrength: .high,
                    sourceRecordIDs: ["source-official"],
                    sourceClaimIDs: ["claim-serve"]
                )
            ]
        )

        XCTAssertTrue(pack.validationIssues.contains(.invalidRequirementOverlay))
    }

    func testLocalProofCannotCertifyExternalSourceTruth() {
        let sourceClaim = SourceAtlasClaim(
            id: "claim-serve",
            text: "Verified source-backed claim.",
            state: .official,
            freshness: .current,
            riskClass: .sportRules,
            sourceIDs: ["source-official"],
            reviewRequired: false
        )
        let localProof = SourceAtlasProofMapEntry(
            id: "proof-local-cert",
            requirementID: "requirement-serve",
            proofDescription: "User provided note.",
            privacyClass: .privateLife,
            proofCandidate: .localObservation,
            proofStrength: .localOnly,
            sourceRecordIDs: ["source-official"],
            sourceClaimIDs: [sourceClaim.id]
        )
        XCTAssertFalse(localProof.canCertifySourceTruth)
        XCTAssertFalse(localProof.canSupportCurrentRequirement(["claim-serve": sourceClaim]))
    }
}
