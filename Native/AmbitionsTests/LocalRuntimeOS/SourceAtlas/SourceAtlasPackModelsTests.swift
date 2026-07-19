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
            projections: pack.projections,
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

    func testProjectionProfilesMustProduceReceipts() {
        let pack = Self.validPack(
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection-no-receipt",
                    goalIntent: "starter_goal",
                    requiredPackIDs: ["sports.pickleball.domain"],
                    projectionProfiles: [
                        SourceAtlasProjectionProfile(
                            id: "profile-no-receipt",
                            profileTitle: "No receipt",
                            sourceState: .officialCurrent,
                            freshnessState: .current,
                            riskState: .low,
                            reviewState: .approved,
                            producesPersonalPathInstance: true,
                            producesProjectionReceipt: false,
                            optionValueMap: SourceAtlasOptionValueMap(
                                id: "no-receipt-map",
                                values: ["pace": "steady"],
                                sourceState: .officialCurrent,
                                freshnessState: .current,
                                reviewState: .approved,
                                riskState: .low
                            ),
                            personalPathInstances: [
                                SourceAtlasPersonalPathInstance(
                                    id: "path-no-receipt",
                                    personalPathTemplateID: "template-no-receipt",
                                    stepCandidateSeeds: [
                                        SourceAtlasStepCandidateSeed(
                                            id: "seed-no-receipt",
                                            stepCandidate: "Rehearse first serve."
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
            ]
        )

        XCTAssertTrue(pack.validationIssues.contains(.projectionRecipeMissingReceipt))
    }

    func testMixedProjectionProfilesStillRequireEveryReceipt() {
        let pack = Self.validPack(
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection-mixed-receipts",
                    goalIntent: "starter_goal",
                    requiredPackIDs: ["sports.pickleball.domain"],
                    projectionProfiles: [
                        Self.makeProjectionProfile(
                            id: "profile-with-receipt",
                            goalIntent: "starter_goal",
                            producesProjectionReceipt: true
                        ),
                        Self.makeProjectionProfile(
                            id: "profile-missing-receipt",
                            goalIntent: "starter_goal",
                            producesProjectionReceipt: false
                        )
                    ]
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

    func testDifferentProfilesCanProduceDifferentPersonalPathInstancesFromSameGraph() {
        let graphProjection = Self.makeSharedGoalProjection(
            id: "projection-shared-graph",
            goalIntent: "fitness_start",
            profileIDs: ["profile-fast", "profile-deliberate"],
            pathInstanceIDs: ["path-fast", "path-deliberate"]
        )

        let profilePathIDs = Set(graphProjection.projectionProfiles.map { $0.personalPathInstances.map(\.id) }.flatMap { $0 })

        XCTAssertEqual(profilePathIDs.count, 2)
        XCTAssertTrue(graphProjection.canDriveCurrentProjection)
    }

    func testSourceNeededAndStaleAndRevokedProjectionStatesBlockCurrentProjection() {
        let optionMap = SourceAtlasOptionValueMap(
            id: "state-map",
            values: ["focus": "core"],
            sourceState: .officialCurrent,
            freshnessState: .current,
            reviewState: .approved,
            riskState: .low
        )
        let blockedSources: [SourceAtlasRequirementSourceState] = [.sourceNeeded, .stale, .revoked]

        for sourceState in blockedSources {
            let profile = SourceAtlasProjectionProfile(
                id: "profile-\(sourceState.rawValue)",
                profileTitle: "Blocked profile",
                sourceState: sourceState,
                freshnessState: .current,
                riskState: .low,
                reviewState: .approved,
                producesPersonalPathInstance: true,
                producesProjectionReceipt: true,
                optionValueMap: optionMap,
                personalPathInstances: [
                    SourceAtlasPersonalPathInstance(
                        id: "path-\(sourceState.rawValue)",
                        personalPathTemplateID: "template-\(sourceState.rawValue)",
                        stepCandidateSeeds: [
                            SourceAtlasStepCandidateSeed(
                                id: "seed-\(sourceState.rawValue)",
                                stepCandidate: "Hold a steady baseline."
                            )
                        ],
                        sourceState: sourceState,
                        freshnessState: .current,
                        reviewState: .approved,
                        riskState: .low,
                        sourceRecordIDs: ["source-official"]
                    )
                ]
            )

            XCTAssertFalse(profile.canDriveCurrentProjection)
        }
    }

    func testProjectionOutputRemainsValueModelOnlyWithConservativeBoundaries() {
        let pack = Self.validPack()

        XCTAssertTrue(pack.runtimeBoundary.isValueModelOnly)
        XCTAssertEqual(pack.validationIssues.contains(.runtimeStoreBehavior), false)
        XCTAssertFalse(
            pack.projections.contains(where: { $0.canDriveCurrentProjection == false })
        )
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
        projections: [SourceAtlasGoalProjection]? = nil,
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
            projections: projections ?? [
                SourceAtlasGoalProjection(
                    id: "recipe-pickleball-starter",
                    goalIntent: "starter_goal",
                    requiredPackIDs: ["sports.pickleball.domain"],
                    projectionProfiles: [
                        Self.makeProjectionProfile(
                            id: "profile-pickleball-starter",
                            goalIntent: "starter_goal"
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

    static func makeProjectionProfile(
        id: String,
        goalIntent: String,
        sourceState: SourceAtlasRequirementSourceState = .officialCurrent,
        freshnessState: SourceAtlasRequirementFreshnessState = .current,
        reviewState: SourceAtlasRequirementReviewState = .approved,
        riskState: SourceAtlasRequirementRiskState = .low,
        producesPersonalPathInstance: Bool = true,
        producesProjectionReceipt: Bool = true,
        pathInstanceID: String? = nil,
        optionValueMapValues: [String: String] = ["cadence": "steady"]
    ) -> SourceAtlasProjectionProfile {
        SourceAtlasProjectionProfile(
            id: id,
            profileTitle: "\(goalIntent)-\(id)",
            sourceState: sourceState,
            freshnessState: freshnessState,
            riskState: riskState,
            reviewState: reviewState,
            producesPersonalPathInstance: producesPersonalPathInstance,
            producesProjectionReceipt: producesProjectionReceipt,
            optionValueMap: SourceAtlasOptionValueMap(
                id: "map-\(id)",
                values: optionValueMapValues,
                sourceState: sourceState,
                freshnessState: freshnessState,
                reviewState: reviewState,
                riskState: riskState
            ),
            personalPathInstances: [
                SourceAtlasPersonalPathInstance(
                    id: pathInstanceID ?? "path-\(id)",
                    personalPathTemplateID: "template-\(id)",
                    stepCandidateSeeds: [
                        SourceAtlasStepCandidateSeed(
                            id: "seed-\(id)",
                            stepCandidate: "Practice a goal-aligned path for \(goalIntent)."
                        )
                    ],
                    sourceState: sourceState,
                    freshnessState: freshnessState,
                    reviewState: reviewState,
                    riskState: riskState,
                    sourceRecordIDs: ["source-official"]
                )
            ]
        )
    }

    static func makeSharedGoalProjection(
        id: String,
        goalIntent: String,
        profileIDs: [String],
        pathInstanceIDs: [String]
    ) -> SourceAtlasGoalProjection {
        SourceAtlasGoalProjection(
            id: id,
            goalIntent: goalIntent,
            requiredPackIDs: ["sports.pickleball.domain"],
            projectionProfiles: zip(profileIDs, pathInstanceIDs).map { profileID, pathInstanceID in
                makeProjectionProfile(
                    id: profileID,
                    goalIntent: goalIntent,
                    pathInstanceID: pathInstanceID
                )
            }
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
            ],
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["pickleball.serve", "pickleball.rules"],
                overlayDependencyIDs: ["sports.pickleball.rules"],
                projectionRecipeIDs: ["recipe-pickleball-starter"],
                ownsIndividualGoalPhrase: false,
                requirementOverlays: []
            )
        )

        XCTAssertEqual(stalePack.validationIssues.contains(SourceAtlasValidationIssue.proofCannotSupportCurrentRequirement), true)
        XCTAssertEqual(stalePack.validationIssues.contains(SourceAtlasValidationIssue.proofRequiresSourceOrClaimBinding), false)
        XCTAssertEqual(stalePack.validationIssues.contains(SourceAtlasValidationIssue.invalidRequirementOverlay), true)
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

    func testNarrowSkillSliceReusesSpecificPathOverlay() {
        let levelLadder = SourceAtlasLevelLadder(
            id: "ladder-serve",
            title: "Serve ladder",
            capabilityGraphID: "graph-serve",
            pathOverlays: [
                SourceAtlasPathOverlay(
                    id: "path-broad",
                    title: "Broad serve path",
                    skillSliceID: "sports.pickleball",
                    pathPriority: 3,
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .current,
                    riskClass: .hobby
                ),
                SourceAtlasPathOverlay(
                    id: "path-narrow",
                    title: "Narrow serve path",
                    skillSliceID: "sports.pickleball.serve",
                    pathPriority: 3,
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .current,
                    riskClass: .hobby
                )
            ]
        )

        XCTAssertEqual(
            levelLadder.highestReusablePathID(
                for: "sports.pickleball.serve",
                roleID: "athlete"
            ),
            "path-narrow"
        )
    }

    func testHighestPriorityPathOverlayIsSelectedForReuse() {
        let levelLadder = SourceAtlasLevelLadder(
            id: "ladder-serve",
            title: "Serve ladder",
            capabilityGraphID: "graph-serve",
            pathOverlays: [
                SourceAtlasPathOverlay(
                    id: "path-low",
                    title: "Lower priority path",
                    skillSliceID: "sports.pickleball.serve",
                    pathPriority: 1,
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .current,
                    riskClass: .hobby
                ),
                SourceAtlasPathOverlay(
                    id: "path-high",
                    title: "Higher priority path",
                    skillSliceID: "sports.pickleball.serve",
                    pathPriority: 9,
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .current,
                    riskClass: .hobby
                )
            ]
        )

        XCTAssertEqual(
            levelLadder.highestReusablePathID(
                for: "sports.pickleball.serve",
                roleID: "athlete"
            ),
            "path-high"
        )
    }

    func testRoleSpecificPathOverlayDoesNotReuseWithoutRoleContext() {
        let levelLadder = SourceAtlasLevelLadder(
            id: "ladder-role",
            title: "Role ladder",
            capabilityGraphID: "graph-serve",
            pathOverlays: [
                SourceAtlasPathOverlay(
                    id: "path-generic",
                    title: "Generic serve path",
                    skillSliceID: "sports.pickleball.serve",
                    pathPriority: 2,
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .current,
                    riskClass: .hobby
                ),
                SourceAtlasPathOverlay(
                    id: "path-coach",
                    title: "Coach serve path",
                    skillSliceID: "sports.pickleball.serve",
                    pathPriority: 9,
                    roleID: "coach",
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .current,
                    riskClass: .hobby
                )
            ]
        )

        XCTAssertEqual(
            levelLadder.highestReusablePathID(for: "sports.pickleball.serve"),
            "path-generic"
        )
        XCTAssertEqual(
            levelLadder.highestReusablePathID(
                for: "sports.pickleball.serve",
                roleID: "coach"
            ),
            "path-coach"
        )
    }

    func testNarrowPathOverlayDoesNotReuseForBroaderSkillSlice() {
        let levelLadder = SourceAtlasLevelLadder(
            id: "ladder-broad",
            title: "Broad ladder",
            capabilityGraphID: "graph-serve",
            pathOverlays: [
                SourceAtlasPathOverlay(
                    id: "path-serve-only",
                    title: "Serve-only path",
                    skillSliceID: "sports.pickleball.serve",
                    pathPriority: 9,
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .current,
                    riskClass: .hobby
                )
            ]
        )

        XCTAssertNil(
            levelLadder.highestReusablePathID(
                for: "sports.pickleball",
                roleID: "athlete"
            )
        )
    }

    func testPickleballSkillAndProPathsReuseMostSpecificProjection() {
        let levelLadder = SourceAtlasLevelLadder(
            id: "ladder-pickleball",
            title: "Pickleball ladder",
            capabilityGraphID: "graph-pickleball",
            pathOverlays: [
                SourceAtlasPathOverlay(
                    id: "path-pickleball-broad",
                    title: "Pickleball baseline",
                    skillSliceID: "sports.pickleball",
                    pathPriority: 1,
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .current,
                    riskClass: .hobby
                ),
                SourceAtlasPathOverlay(
                    id: "path-pickleball-serve",
                    title: "Pickleball serve",
                    skillSliceID: "sports.pickleball.serve",
                    pathPriority: 3,
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .current,
                    riskClass: .hobby
                ),
                SourceAtlasPathOverlay(
                    id: "path-pickleball-pro",
                    title: "Pickleball pro serve",
                    skillSliceID: "sports.pickleball.serve.pro",
                    pathPriority: 9,
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .current,
                    riskClass: .hobby
                )
            ]
        )

        XCTAssertEqual(
            levelLadder.highestReusablePathID(for: "sports.pickleball"),
            "path-pickleball-broad"
        )
        XCTAssertEqual(
            levelLadder.highestReusablePathID(for: "sports.pickleball.serve"),
            "path-pickleball-serve"
        )
        XCTAssertEqual(
            levelLadder.highestReusablePathID(for: "sports.pickleball.serve.pro"),
            "path-pickleball-pro"
        )
    }

    func testFootballVarsityNflAndCommentatorPathsSelectBySpecificityAndRole() {
        let levelLadder = SourceAtlasLevelLadder(
            id: "ladder-football",
            title: "Football ladder",
            capabilityGraphID: "graph-football",
            pathOverlays: [
                SourceAtlasPathOverlay(
                    id: "path-football-varsity",
                    title: "Make varsity football",
                    skillSliceID: "sports.football",
                    pathPriority: 4,
                    roleID: "athlete",
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .current,
                    riskClass: .careerContext
                ),
                SourceAtlasPathOverlay(
                    id: "path-football-nfl",
                    title: "Make it to the NFL",
                    skillSliceID: "sports.football.nfl",
                    pathPriority: 9,
                    roleID: "athlete",
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .current,
                    riskClass: .careerContext
                ),
                SourceAtlasPathOverlay(
                    id: "path-football-commentator",
                    title: "Become football commentator",
                    skillSliceID: "sports.football",
                    pathPriority: 6,
                    roleID: "commentator",
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .current,
                    riskClass: .careerContext
                )
            ]
        )

        XCTAssertEqual(
            levelLadder.highestReusablePathID(
                for: "sports.football.athlete",
                roleID: "athlete"
            ),
            "path-football-varsity"
        )
        XCTAssertEqual(
            levelLadder.highestReusablePathID(
                for: "sports.football.nfl",
                roleID: "athlete"
            ),
            "path-football-nfl"
        )
        XCTAssertEqual(
            levelLadder.highestReusablePathID(
                for: "sports.football",
                roleID: "commentator"
            ),
            "path-football-commentator"
        )
        XCTAssertNil(
            levelLadder.highestReusablePathID(
                for: "sports.pickleball.coach",
                roleID: "coach"
            )
        )
    }

    func testUSPresidentProjectionRequiresStrictSourceOverlay() {
        let levelLadderWithoutSource = SourceAtlasLevelLadder(
            id: "ladder-president",
            title: "President ladder",
            capabilityGraphID: "graph-president",
            pathOverlays: [
                SourceAtlasPathOverlay(
                    id: "path-president-official",
                    title: "President path requires source",
                    skillSliceID: "career.politics.president",
                    pathPriority: 10,
                    sourceRecordIDs: [],
                    state: .official,
                    freshness: .current,
                    riskClass: .careerContext
                )
            ]
        )

        XCTAssertNil(levelLadderWithoutSource.highestReusablePathID(for: "career.politics.president"))

        let levelLadderWithSource = SourceAtlasLevelLadder(
            id: "ladder-president",
            title: "President ladder",
            capabilityGraphID: "graph-president",
            pathOverlays: [
                SourceAtlasPathOverlay(
                    id: "path-president-official",
                    title: "President path requires source",
                    skillSliceID: "career.politics.president",
                    pathPriority: 10,
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .current,
                    riskClass: .careerContext
                )
            ]
        )

        XCTAssertEqual(
            levelLadderWithSource.highestReusablePathID(for: "career.politics.president"),
            "path-president-official"
        )
    }

    func testJobPostingProjectionStaysExampleOnlyUntilSourceGatesClear() {
        let jobPostingProjection = SourceAtlasGoalProjection(
            id: "projection-job-posting",
            goalIntent: "job_posting",
            requiredPackIDs: ["school.job.posting"],
            projectionProfiles: [
                Self.makeProjectionProfile(
                    id: "profile-job-posting-example-only",
                    goalIntent: "job_posting",
                    sourceState: .sourceNeeded,
                    reviewState: .required,
                    pathInstanceID: "path-job-posting-example",
                    optionValueMapValues: ["mode": "example-only"]
                )
            ]
        )

        XCTAssertFalse(jobPostingProjection.canDriveCurrentProjection)
    }

    func testSchoolProgramProjectionRequiresReviewBeforeCurrentUse() {
        let pack = Self.validPack(
            requirements: [
                SourceAtlasRequirement(
                    id: "requirement-school-program",
                    claimID: "claim-serve",
                    title: "Review school program requirements",
                    kind: .hard,
                    required: true,
                    sourceState: .officialCurrent,
                    freshnessState: .current,
                    riskState: .low,
                    reviewState: .approved
                )
            ],
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: ["school.programs", "education.transfer"],
                overlayDependencyIDs: ["education.requirements"],
                projectionRecipeIDs: ["recipe-pickleball-starter"],
                ownsIndividualGoalPhrase: false,
                requirementOverlays: [
                    SourceAtlasRequirementOverlay(
                        id: "overlay-school-program-review",
                        sourceAtlasRequirementID: "requirement-school-program",
                        requirementIDs: ["requirement-school-program"],
                        summary: "School program path requires strict review before use.",
                        sourceState: .officialCurrent,
                        freshnessState: .current,
                        riskState: .low,
                        reviewState: .required
                    )
                ]
            )
        )

        XCTAssertTrue(pack.validationIssues.contains(.invalidRequirementOverlay))
    }

    func testStaleOrUnknownProjectionStatesBlockCurrentReuse() {
        let levelLadder = SourceAtlasLevelLadder(
            id: "ladder-stale",
            title: "Stale ladder",
            capabilityGraphID: "graph-serve",
            pathOverlays: [
                SourceAtlasPathOverlay(
                    id: "path-stale",
                    title: "Stale path",
                    skillSliceID: "sports.pickleball.serve",
                    pathPriority: 10,
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .stale,
                    riskClass: .hobby
                ),
                SourceAtlasPathOverlay(
                    id: "path-unknown",
                    title: "Unknown path",
                    skillSliceID: "sports.pickleball.serve",
                    pathPriority: 10,
                    sourceRecordIDs: ["source-official"],
                    state: .official,
                    freshness: .unknown,
                    riskClass: .hobby
                ),
                SourceAtlasPathOverlay(
                    id: "path-revoked",
                    title: "Revoked path",
                    skillSliceID: "sports.pickleball.serve",
                    pathPriority: 10,
                    sourceRecordIDs: ["source-official"],
                    state: .revoked,
                    freshness: .current,
                    riskClass: .hobby
                )
            ]
        )

        XCTAssertNil(
            levelLadder.highestReusablePathID(
                for: "sports.pickleball.serve",
                roleID: "athlete"
            )
        )
    }

    func testProjectionPathsRequireProvenanceForCurrentRecommendation() {
        let pathMissingProvenance = SourceAtlasPathOverlay(
            id: "path-no-source",
            title: "No source path",
            skillSliceID: "sports.pickleball.serve",
            pathPriority: 10,
            state: .official,
            freshness: .current,
            riskClass: .hobby
        )
        let pathWithSource = SourceAtlasPathOverlay(
            id: "path-with-source",
            title: "With source path",
            skillSliceID: "sports.pickleball.serve",
            pathPriority: 10,
            sourceRecordIDs: ["source-official"],
            state: .official,
            freshness: .current,
            riskClass: .hobby
        )
        let pathWithNoProvenance = SourceAtlasPathOverlay(
            id: "path-user",
            title: "User provided path",
            skillSliceID: "sports.pickleball.serve",
            pathPriority: 8,
            sourceRecordIDs: ["source-official"],
            state: .userProvided,
            freshness: .current,
            riskClass: .hobby
        )

        XCTAssertFalse(
            pathMissingProvenance.canDriveCurrentProjection(
                for: "sports.pickleball.serve",
                roleID: "athlete",
                using: .conservativeFreshness,
                riskPolicy: .conservative
            )
        )
        XCTAssertTrue(
            pathWithSource.canDriveCurrentProjection(
                for: "sports.pickleball.serve",
                roleID: "athlete",
                using: .conservativeFreshness,
                riskPolicy: .conservative
            )
        )
        XCTAssertFalse(
            pathWithNoProvenance.canDriveCurrentProjection(
                for: "sports.pickleball.serve",
                roleID: "athlete",
                using: .conservativeFreshness,
                riskPolicy: .conservative
            )
        )
    }

    func testCapabilityProjectionModelsRemainValueModelOnly() {
        let pack = Self.validPack()
        XCTAssertTrue(pack.runtimeBoundary.isValueModelOnly)
        XCTAssertTrue(
            SourceAtlasRuntimeBoundary(
                storesUserData: false,
                performsNetworkFetches: false,
                mutatesPlans: false,
                writesPersistence: false
            ).isValueModelOnly
        )
        XCTAssertEqual(pack.validationIssues.contains(.runtimeStoreBehavior), false)
    }
}
