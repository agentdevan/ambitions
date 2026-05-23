import XCTest
@testable import Ambitions

final class SourceAtlasIntentMatchModelsTests: XCTestCase {
    func testVarsityFootballMatchesSportAndHighSchoolPathwayPacks() {
        let packs = [
            Self.pack(
                id: "sports.football.domain",
                title: "Football domain pack",
                kind: .domainPack,
                domainID: "sports",
                goalIntent: "make-varsity-football",
                specificDomainID: "sports.football.high-school",
                skillSliceID: "sports.football.varsity",
                roleID: "role.athlete"
            ),
            Self.pack(
                id: "sports.football.high-school",
                title: "Football high school pathway pack",
                kind: .specificDomainPack,
                domainID: "sports",
                goalIntent: "make-varsity-football",
                specificDomainID: "sports.football.high-school",
                skillSliceID: "sports.football.varsity",
                roleID: "role.athlete"
            )
        ]

        let matcher = SourceAtlasIntentMatcher(packs: packs)
        let result = matcher.evaluate(rawGoalText: "Make varsity football")

        XCTAssertEqual(result.match.normalizedGoalIntent, "make-varsity-football")
        XCTAssertEqual(result.match.matchedDomainIDs, ["sports"])
        XCTAssertEqual(result.match.matchedSpecificDomainIDs, ["sports.football.high-school"])
        XCTAssertEqual(result.match.matchedSkillSliceIDs, ["sports.football.varsity"])
        XCTAssertEqual(result.match.matchedRoleIDs, ["role.athlete"])
        XCTAssertEqual(result.match.confidenceBand, .high)
        XCTAssertTrue(result.match.missingClarifications.isEmpty)
        XCTAssertEqual(result.match.sourceAtlasPackIDs, ["sports.football.domain", "sports.football.high-school"])
        XCTAssertTrue(result.match.rejectedPackIDs.isEmpty)
        XCTAssertTrue(result.match.matchTrace.contains("signals=football,varsity,high-school"))
        XCTAssertTrue(result.match.matchTrace.contains("runtime=enabled"))
        XCTAssertEqual(result.selection.selectedPackIDs, ["sports.football.domain", "sports.football.high-school"])
        XCTAssertTrue(result.selection.rejectedPackIDs.isEmpty)
        XCTAssertTrue(result.selection.canDriveRuntime)
        XCTAssertFalse(result.selection.requiredUserReview)
    }

    func testMusicReleaseMatchesCreativePackAndStaysRuntimeSafe() {
        let packs = [
            Self.pack(
                id: "creative.music.domain",
                title: "Music domain pack",
                kind: .domainPack,
                domainID: "creative",
                goalIntent: "release-3-songs-by-august",
                specificDomainID: "creative.music.release",
                skillSliceID: "creative.music.release.songs",
                roleID: "role.creator",
                claimRiskClass: .hobby
            ),
            Self.pack(
                id: "creative.music.release",
                title: "Music release pathway pack",
                kind: .specificDomainPack,
                domainID: "creative",
                goalIntent: "release-3-songs-by-august",
                specificDomainID: "creative.music.release",
                skillSliceID: "creative.music.release.songs",
                roleID: "role.creator",
                claimRiskClass: .hobby
            )
        ]

        let matcher = SourceAtlasIntentMatcher(packs: packs)
        let result = matcher.evaluate(rawGoalText: "Release 3 songs by August")

        XCTAssertEqual(result.match.normalizedGoalIntent, "release-3-songs-by-august")
        XCTAssertEqual(result.match.matchedDomainIDs, ["creative"])
        XCTAssertEqual(result.match.matchedSpecificDomainIDs, ["creative.music.release"])
        XCTAssertEqual(result.match.matchedSkillSliceIDs, ["creative.music.release.songs"])
        XCTAssertEqual(result.match.matchedRoleIDs, ["role.creator"])
        XCTAssertEqual(result.match.confidenceBand, .medium)
        XCTAssertTrue(result.match.missingClarifications.isEmpty)
        XCTAssertEqual(result.selection.selectedPackIDs, ["creative.music.domain", "creative.music.release"])
        XCTAssertTrue(result.selection.rejectedPackIDs.isEmpty)
        XCTAssertTrue(result.selection.canDriveRuntime)
        XCTAssertFalse(result.selection.requiredUserReview)
    }

    func testDebtGoalRejectsHighRiskAdviceButKeepsReviewSafePack() {
        let packs = [
            Self.pack(
                id: "financial.debt.admin",
                title: "Debt admin pack",
                kind: .domainPack,
                domainID: "financial",
                goalIntent: "pay-off-5000-debt",
                specificDomainID: "financial.debt.repayment",
                skillSliceID: "financial.debt.repayment.plan",
                roleID: "role.financial-steward",
                claimRiskClass: .careerContext
            ),
            Self.pack(
                id: "financial.debt.advice",
                title: "Debt advice pack",
                kind: .specificDomainPack,
                domainID: "financial",
                goalIntent: "pay-off-5000-debt",
                specificDomainID: "financial.debt.repayment",
                skillSliceID: "financial.debt.repayment.plan",
                roleID: "role.financial-steward",
                claimRiskClass: .financial,
                claimReviewRequired: true,
                requirementReviewState: .required
            )
        ]

        let matcher = SourceAtlasIntentMatcher(packs: packs)
        let result = matcher.evaluate(rawGoalText: "Pay off $5,000 debt")

        XCTAssertEqual(result.match.normalizedGoalIntent, "pay-off-5000-debt")
        XCTAssertEqual(result.match.matchedDomainIDs, ["financial"])
        XCTAssertEqual(result.match.matchedSpecificDomainIDs, ["financial.debt.repayment"])
        XCTAssertEqual(result.match.matchedSkillSliceIDs, ["financial.debt.repayment.plan"])
        XCTAssertEqual(result.match.matchedRoleIDs, ["role.financial-steward"])
        XCTAssertEqual(result.match.confidenceBand, .medium)
        XCTAssertEqual(result.selection.selectedPackIDs, ["financial.debt.admin"])
        XCTAssertEqual(result.selection.rejectedPackIDs, ["financial.debt.advice"])
        XCTAssertEqual(result.selection.rejectionReasons["financial.debt.advice"]?.contains("high-risk"), true)
        XCTAssertEqual(result.selection.rejectionReasons["financial.debt.advice"]?.contains("review-required"), true)
        XCTAssertEqual(result.selection.rejectionReasons["financial.debt.advice"]?.contains("runtime-blocked"), true)
        XCTAssertEqual(result.selection.rejectionReasons["financial.debt.advice"]?.contains("unsupported"), true)
        XCTAssertTrue(result.selection.canDriveRuntime)
        XCTAssertFalse(result.selection.requiredUserReview)
        XCTAssertTrue(result.match.matchTrace.contains(where: {
            $0.contains("reject financial.debt.advice") &&
            $0.contains("high-risk") &&
            $0.contains("review-required") &&
            $0.contains("runtime-blocked") &&
            $0.contains("unsupported")
        }))
    }

    func testUnknownGoalDegradesToGenericScaffoldWithMissingSourceWarning() {
        let matcher = SourceAtlasIntentMatcher(packs: [])
        let result = matcher.evaluate(rawGoalText: "Something later")

        XCTAssertEqual(result.match.normalizedGoalIntent, "goal-scaffold")
        XCTAssertTrue(result.match.matchedDomainIDs.isEmpty)
        XCTAssertTrue(result.match.matchedSpecificDomainIDs.isEmpty)
        XCTAssertTrue(result.match.matchedSkillSliceIDs.isEmpty)
        XCTAssertTrue(result.match.matchedRoleIDs.isEmpty)
        XCTAssertEqual(result.match.confidenceBand, .unknown)
        XCTAssertEqual(result.match.missingClarifications, ["Need one concrete goal domain or outcome."])
        XCTAssertTrue(result.match.sourceAtlasPackIDs.isEmpty)
        XCTAssertTrue(result.match.rejectedPackIDs.isEmpty)
        XCTAssertTrue(result.match.matchTrace.contains("clarify=Need one concrete goal domain or outcome."))
        XCTAssertTrue(result.match.matchTrace.contains("candidate-packs=none"))
        XCTAssertEqual(result.selection.selectedPackIDs, [])
        XCTAssertTrue(result.selection.rejectedPackIDs.isEmpty)
        XCTAssertEqual(result.selection.sourceState, .sourceNeeded)
        XCTAssertEqual(result.selection.freshnessState, .unknown)
        XCTAssertEqual(result.selection.riskState, .unknown)
        XCTAssertEqual(result.selection.reviewState, .required)
        XCTAssertFalse(result.selection.canDriveRuntime)
        XCTAssertTrue(result.selection.requiredUserReview)
    }

    func testStaleAndUnsupportedPacksAreRejectedFromRuntimeUse() {
        let stalePack = Self.pack(
            id: "sports.football.stale",
            title: "Stale football pack",
            kind: .domainPack,
            domainID: "sports",
            goalIntent: "make-varsity-football",
            specificDomainID: "sports.football.high-school",
            skillSliceID: "sports.football.varsity",
            roleID: "role.athlete",
            claimState: .stale,
            claimFreshness: .stale,
            requirementSourceState: .stale,
            requirementFreshnessState: .stale
        )

        let unsupportedPack = Self.pack(
            id: "creative.music.unsupported",
            title: "Unsupported music pack",
            kind: .domainPack,
            domainID: "creative",
            goalIntent: "release-3-songs-by-august",
            specificDomainID: "creative.music.release",
            skillSliceID: "creative.music.release.songs",
            roleID: "role.creator",
            schemaVersion: "source_atlas_pack.native.v0"
        )

        let staleResult = SourceAtlasIntentMatcher(packs: [stalePack]).evaluate(rawGoalText: "Make varsity football")
        let unsupportedResult = SourceAtlasIntentMatcher(packs: [unsupportedPack]).evaluate(rawGoalText: "Release 3 songs by August")

        XCTAssertEqual(staleResult.selection.rejectedPackIDs, ["sports.football.stale"])
        XCTAssertEqual(staleResult.selection.rejectionReasons["sports.football.stale"]?.contains("stale"), true)
        XCTAssertEqual(staleResult.selection.rejectionReasons["sports.football.stale"]?.contains("runtime-blocked"), true)
        XCTAssertEqual(staleResult.selection.rejectionReasons["sports.football.stale"]?.contains("unsupported"), true)
        XCTAssertEqual(staleResult.selection.sourceState, .stale)
        XCTAssertFalse(staleResult.selection.canDriveRuntime)
        XCTAssertTrue(staleResult.selection.requiredUserReview)
        XCTAssertTrue(staleResult.match.matchTrace.contains(where: {
            $0.contains("reject sports.football.stale") &&
            $0.contains("stale") &&
            $0.contains("runtime-blocked") &&
            $0.contains("unsupported")
        }))

        XCTAssertEqual(unsupportedResult.selection.rejectedPackIDs, ["creative.music.unsupported"])
        XCTAssertEqual(unsupportedResult.selection.rejectionReasons["creative.music.unsupported"]?.contains("unsupported"), true)
        XCTAssertEqual(unsupportedResult.selection.rejectionReasons["creative.music.unsupported"]?.contains("runtime-blocked"), true)
        XCTAssertFalse(unsupportedResult.selection.canDriveRuntime)
        XCTAssertTrue(unsupportedResult.selection.requiredUserReview)
        XCTAssertTrue(unsupportedResult.match.matchTrace.contains(where: {
            $0.contains("reject creative.music.unsupported") &&
            $0.contains("unsupported") &&
            $0.contains("runtime-blocked")
        }))
    }
}

private extension SourceAtlasIntentMatchModelsTests {
    static func pack(
        id: String,
        title: String,
        kind: SourceAtlasPackKind,
        domainID: String,
        goalIntent: String,
        specificDomainID: String,
        skillSliceID: String,
        roleID: String,
        claimRiskClass: SourceAtlasRiskClass = .sportRules,
        claimState: SourceAtlasClaimState = .official,
        claimFreshness: SourceAtlasFreshnessState = .current,
        claimReviewRequired: Bool = false,
        requirementSourceState: SourceAtlasRequirementSourceState = .officialCurrent,
        requirementFreshnessState: SourceAtlasRequirementFreshnessState = .current,
        requirementRiskState: SourceAtlasRequirementRiskState = .low,
        requirementReviewState: SourceAtlasRequirementReviewState = .approved,
        schemaVersion: String = sourceAtlasPackSchemaVersion
    ) -> SourceAtlasPack {
        let sourceID = "source.\(id)"
        let claimID = "claim.\(id)"
        let requirementID = "requirement.\(id)"
        let projectionID = "projection.\(id)"
        let graphID = "graph.\(id)"
        let pathOverlayID = "path.\(id)"
        let domainPackID = "domain.\(id)"

        let source = SourceAtlasSourceRecord(
            id: sourceID,
            title: "\(title) source",
            kind: .official,
            locator: "https://example.test/\(id)",
            retrievedAt: "2026-05-23T14:27:19Z",
            contentHash: "hash-\(id)",
            approvedForOfficialClaims: true
        )

        let claim = SourceAtlasClaim(
            id: claimID,
            text: "\(title) claim.",
            state: claimState,
            freshness: claimFreshness,
            riskClass: claimRiskClass,
            sourceIDs: [sourceID],
            reviewRequired: claimReviewRequired
        )

        let requirement = SourceAtlasRequirement(
            id: requirementID,
            claimID: claimID,
            title: "\(title) requirement",
            kind: .hard,
            required: true,
            sourceState: requirementSourceState,
            freshnessState: requirementFreshnessState,
            riskState: requirementRiskState,
            reviewState: requirementReviewState
        )

        let projection = SourceAtlasGoalProjection(
            id: projectionID,
            goalIntent: goalIntent,
            requiredPackIDs: [id],
            projectionProfiles: [
                SourceAtlasProjectionProfile(
                    id: "profile.\(id)",
                    profileTitle: title,
                    sourceState: requirementSourceState,
                    freshnessState: requirementFreshnessState,
                    riskState: requirementRiskState,
                    reviewState: requirementReviewState,
                    producesPersonalPathInstance: true,
                    producesProjectionReceipt: true,
                    optionValueMap: SourceAtlasOptionValueMap(
                        id: "option.\(id)",
                        values: ["goal": goalIntent],
                        sourceState: requirementSourceState,
                        freshnessState: requirementFreshnessState,
                        reviewState: requirementReviewState,
                        riskState: requirementRiskState
                    ),
                    personalPathInstances: [
                        SourceAtlasPersonalPathInstance(
                            id: "path-instance.\(id)",
                            personalPathTemplateID: "template.\(id)",
                            stepCandidateSeeds: [
                                SourceAtlasStepCandidateSeed(
                                    id: "seed.\(id)",
                                    stepCandidate: "Practice the \(goalIntent) path."
                                )
                            ],
                            sourceState: requirementSourceState,
                            freshnessState: requirementFreshnessState,
                            reviewState: requirementReviewState,
                            riskState: requirementRiskState,
                            sourceRecordIDs: [sourceID]
                        )
                    ]
                )
            ]
        )

        let domainPack = SourceAtlasDomainPack(
            id: domainPackID,
            title: "\(title) domain pack",
            domainID: domainID,
            capabilityGraphIDs: [graphID],
            specificDomainPackIDs: [specificDomainID],
            reusableNodeIDs: [skillSliceID],
            sourceSliceIDs: [sourceID],
            state: claimState,
            freshness: claimFreshness,
            riskClass: claimRiskClass,
            reviewRequired: claimReviewRequired
        )

        let specificPack = SourceAtlasSpecificDomainPack(
            id: specificDomainID,
            title: "\(title) specific pack",
            domainPackID: domainPackID,
            capabilityGraphID: graphID,
            skillSliceIDs: [skillSliceID],
            roleOverlayIDs: [roleID],
            pathOverlayIDs: [pathOverlayID],
            state: claimState,
            freshness: claimFreshness,
            riskClass: claimRiskClass,
            reviewRequired: claimReviewRequired,
            sourceSliceIDs: [sourceID]
        )

        return SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: id,
                title: title,
                kind: kind,
                version: "1.0.0",
                domainID: domainID,
                specificDomainID: specificDomainID,
                schemaVersion: schemaVersion
            ),
            sources: [source],
            claims: [claim],
            requirements: [requirement],
            starterItems: [
                SourceAtlasStarterItem(
                    id: "starter.\(id)",
                    title: "\(title) starter",
                    stepCandidateSeed: "Practice the \(goalIntent) starter step.",
                    storesFinalSchedule: false
                )
            ],
            proofMap: [
                SourceAtlasProofMapEntry(
                    id: "proof.\(id)",
                    requirementID: requirementID,
                    proofDescription: "\(title) proof",
                    privacyClass: .privateLife,
                    proofCandidate: .sourceEvidence,
                    proofStrength: .officialCertified,
                    capabilityNodeID: "capability.\(id)",
                    sourceRecordIDs: [sourceID],
                    sourceClaimIDs: [claimID],
                    correctionHookIDs: ["hook.\(id).correct"],
                    revocationHookIDs: ["hook.\(id).revoke"],
                    evidenceLedgerBridgeIDs: ["ledger.\(id)"]
                )
            ],
            projections: [projection],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Source needed.",
                reviewRequired: "Review required.",
                notProfessionalAdvice: "Not professional advice."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: [skillSliceID],
                overlayDependencyIDs: [roleID],
                projectionRecipeIDs: [projectionID],
                ownsIndividualGoalPhrase: false,
                requirementOverlays: []
            ),
            domainPacks: [domainPack],
            specificDomainPacks: [specificPack],
            capabilityGraphs: [
                SourceAtlasCapabilityGraph(
                    id: graphID,
                    title: "\(title) capability graph",
                    domainPackID: domainPackID,
                    capabilityNodeIDs: [skillSliceID],
                    capabilityEdgeIDs: [],
                    levelLadderIDs: [],
                    roleOverlayIDs: [roleID],
                    nodes: [],
                    edges: [],
                    ladders: [],
                    roleOverlays: [
                        SourceAtlasRoleOverlay(
                            id: roleID,
                            roleID: roleID,
                            skillSliceID: skillSliceID,
                            reusableNodeIDs: [skillSliceID],
                            state: claimState,
                            freshness: claimFreshness,
                            riskClass: claimRiskClass
                        )
                    ],
                    state: claimState,
                    freshness: claimFreshness,
                    riskClass: claimRiskClass
                )
            ]
        )
    }
}
