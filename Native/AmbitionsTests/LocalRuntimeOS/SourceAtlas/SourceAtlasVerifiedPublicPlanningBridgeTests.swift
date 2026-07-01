import XCTest
@testable import Ambitions

final class SourceAtlasVerifiedPublicPlanningBridgeTests: XCTestCase {
    func testVerifiedPublicContextExpandsCandidatesWithLocalReceiptsAndDeterministicReplay() throws {
        let fixture = Self.fixture()

        let output = SourceAtlasStepCandidateFieldBridge().expandVerifiedPublicPlanningContext(
            providerOutput: fixture.providerOutput,
            composition: fixture.composition,
            pack: fixture.pack,
            generatedAt: fixture.generatedAt,
            goalID: fixture.goalID,
            candidateLimit: 12
        )
        let repeated = SourceAtlasStepCandidateFieldBridge().expandVerifiedPublicPlanningContext(
            providerOutput: fixture.providerOutput,
            composition: fixture.composition,
            pack: fixture.pack,
            generatedAt: fixture.generatedAt,
            goalID: fixture.goalID,
            candidateLimit: 12
        )
        let encoded = try String(data: JSONEncoder().encode(output), encoding: .utf8) ?? ""

        XCTAssertEqual(output.issues, [])
        XCTAssertTrue(output.canUseSourceAtlasCandidates)
        XCTAssertEqual(output.field, repeated.field)
        XCTAssertEqual(output.deterministicReplayFingerprint, repeated.deterministicReplayFingerprint)
        XCTAssertEqual(output.receipts.map(\.kind), [.sourceAtlasPublicContextVerified, .sourceAtlasPublicContextApplied])
        XCTAssertEqual(output.shardInfluence?.sourceIDs, ["source-public-varsity"])
        XCTAssertEqual(output.shardInfluence?.claimIDs, ["claim-public-varsity"])
        XCTAssertEqual(output.shardInfluence?.requirementIDs, ["requirement-public-proof"])
        XCTAssertEqual(output.shardInfluence?.proofNeedIDs, ["proof-public-varsity"])
        XCTAssertEqual(output.shardInfluence?.starterActionIDs, ["starter-public-varsity"])
        XCTAssertTrue(output.field.sourceProvenance.contains(.sourceAtlasPathComposition))
        XCTAssertTrue(output.field.sourceProvenance.contains(.sourceAtlasPack))
        XCTAssertTrue(output.field.sourceProvenance.contains(.sourceAtlasStepCandidateSeed))
        XCTAssertFalse(output.field.sourceAtlasExpansionTrace?.expandedCandidates.isEmpty ?? true)
        XCTAssertTrue(output.field.sourceAtlasExpansionTrace?.expansionRules.contains {
            $0.localizedCaseInsensitiveContains("Verified public planning context filters")
        } ?? false)
        let receiptDetails = output.receipts.flatMap(\.details)
        XCTAssertTrue(receiptDetails.contains("source-atlas-final-step-owner=false"))
        XCTAssertTrue(receiptDetails.contains("source-atlas-final-schedule-owner=false"))
        XCTAssertTrue(receiptDetails.contains("r2-artifact=false"))
        XCTAssertFalse(encoded.contains("PRIVATE-GOAL-TEXT"))
        XCTAssertFalse(encoded.contains("account_id"))
        XCTAssertFalse(encoded.contains("device_id"))
    }

    func testPackMismatchFailsClosedToLocalFallbackWithoutSourceAtlasCandidateProvenance() throws {
        let fixture = Self.fixture()
        let mismatchedPack = SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: "source-atlas/v1/domain/sports/pack-public-other",
                title: "Other Public Sports Pack",
                kind: .domainPack,
                version: "1.0.0",
                domainID: "sports"
            ),
            sources: fixture.pack.sources,
            claims: fixture.pack.claims,
            requirements: fixture.pack.requirements,
            starterItems: fixture.pack.starterItems,
            proofMap: fixture.pack.proofMap,
            projections: [],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: fixture.pack.disclosureCopy,
            runtimeBoundary: .valueModelOnly,
            composition: fixture.pack.composition,
            capabilityGraphs: fixture.pack.capabilityGraphs
        )

        let output = SourceAtlasStepCandidateFieldBridge().expandVerifiedPublicPlanningContext(
            providerOutput: fixture.providerOutput,
            composition: fixture.composition,
            pack: mismatchedPack,
            generatedAt: fixture.generatedAt,
            goalID: fixture.goalID,
            candidateLimit: 12
        )

        XCTAssertEqual(output.issues, [.selectedPackMismatch])
        XCTAssertFalse(output.canUseSourceAtlasCandidates)
        XCTAssertNil(output.shardInfluence)
        XCTAssertNil(output.field.sourceAtlasExpansionTrace)
        XCTAssertFalse(output.field.sourceProvenance.contains(.sourceAtlasPack))
        XCTAssertEqual(output.field.selectedCandidate?.kind, .fallback)
        XCTAssertEqual(output.receipts.map(\.kind), [.sourceAtlasPublicContextRejected])
        let receiptDetails = output.receipts.flatMap(\.details)
        XCTAssertTrue(receiptDetails.contains("fallback=local-private-runtime"))
        XCTAssertTrue(receiptDetails.contains("r2-artifact=false"))
    }
}

private extension SourceAtlasVerifiedPublicPlanningBridgeTests {
    struct Fixture {
        let generatedAt: String
        let goalID: String
        let pack: SourceAtlasPack
        let composition: PersonalPathComposition
        let providerOutput: SourceAtlasVerifiedPublicPackProviderOutput
    }

    static func fixture() -> Fixture {
        let generatedAt = "2026-07-01T12:00:00Z"
        let goalID = "goal.local.varsity.bridge"
        let pack = pack()
        let composition = composition(
            goalID: goalID,
            pack: pack
        )
        let providerOutput = providerOutput(
            pack: pack,
            generatedAt: generatedAt
        )
        return Fixture(
            generatedAt: generatedAt,
            goalID: goalID,
            pack: pack,
            composition: composition,
            providerOutput: providerOutput
        )
    }

    static func providerOutput(
        pack: SourceAtlasPack,
        generatedAt: String
    ) -> SourceAtlasVerifiedPublicPackProviderOutput {
        SourceAtlasVerifiedPublicPackProviderOutput(
            schemaVersion: sourceAtlasVerifiedPublicPackProviderSchemaVersion,
            requestIssues: [],
            fetchStatus: .accepted,
            fetchIssues: [],
            manifestRequestIssues: [],
            packRequestIssues: [],
            cacheIssues: [],
            storeQuarantines: [],
            egressFindings: [],
            context: SourceAtlasPublicPlanningContext(
                schemaVersion: sourceAtlasVerifiedPublicPackProviderSchemaVersion,
                id: "context.public.varsity",
                requestDomainID: "sports",
                selectedPackID: pack.id,
                selectedPackDomainID: pack.manifest.domainID,
                manifestVersionID: "manifest.public.varsity",
                useMode: .currentReference,
                availability: SourceAtlasPublicPlanningContextAvailability(
                    fetchStatus: .accepted,
                    selectedStoreSource: .bundled,
                    storeSourceState: .officialCurrent,
                    fallbackConditions: [],
                    canSupportCurrentPublicReferenceUse: true,
                    localPlanningBlocked: false,
                    isLastKnownGood: false,
                    isLocalFallback: false
                ),
                requirements: [
                    SourceAtlasPublicRequirementContext(
                        id: "requirement-public-proof",
                        claimID: "claim-public-varsity",
                        title: "Confirm public eligibility proof.",
                        kind: .proof,
                        required: true,
                        sourceState: .officialCurrent,
                        freshnessState: .current,
                        riskState: .low,
                        reviewState: .approved,
                        sourceIDs: ["source-public-varsity"],
                        proofEntryIDs: ["proof-public-varsity"]
                    )
                ],
                proofNeeds: [
                    SourceAtlasPublicProofNeedContext(
                        id: "proof-public-varsity",
                        requirementID: "requirement-public-proof",
                        proofCandidate: .sourceEvidence,
                        proofStrength: .officialCertified,
                        privacyClass: .externalRedacted,
                        sourceRecordIDs: ["source-public-varsity"],
                        sourceClaimIDs: ["claim-public-varsity"]
                    )
                ],
                starterActions: [
                    SourceAtlasPublicStarterActionContext(
                        id: "starter-public-varsity",
                        title: "Review public eligibility",
                        stepCandidateSeed: "Review the public eligibility rule.",
                        storesFinalSchedule: false
                    )
                ],
                sourceIDs: ["source-public-varsity"],
                claimIDs: ["claim-public-varsity"],
                caveats: [
                    SourceAtlasPublicCaveatContext(
                        id: "caveat.public-reference-only",
                        message: "Public reference only.",
                        relatedIDs: [pack.id]
                    )
                ],
                riskMetadata: [
                    SourceAtlasPublicRiskMetadataContext(
                        id: "risk.requirement-public-proof",
                        riskClass: .lowRiskSkill,
                        riskState: .low,
                        reviewState: .approved,
                        strictReviewRequired: false,
                        sourceBacked: true
                    )
                ],
                ownership: .publicReferenceOnly
            )
        )
    }

    static func pack() -> SourceAtlasPack {
        let source = SourceAtlasSourceRecord(
            id: "source-public-varsity",
            title: "Public varsity requirements",
            kind: .official,
            locator: "https://example.test/varsity",
            retrievedAt: "2026-07-01T00:00:00Z",
            contentHash: "hash-public-varsity",
            approvedForOfficialClaims: true
        )
        let claim = SourceAtlasClaim(
            id: "claim-public-varsity",
            text: "Public eligibility proof can inform a local candidate.",
            state: .official,
            freshness: .current,
            riskClass: .lowRiskSkill,
            sourceIDs: [source.id],
            reviewRequired: false
        )
        let requirement = SourceAtlasRequirement(
            id: "requirement-public-proof",
            claimID: claim.id,
            title: "Confirm public eligibility proof.",
            kind: .proof,
            required: true,
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved
        )
        let node = SourceAtlasCapabilityNode(
            id: "node.public.varsity",
            capabilityGraphID: "graph.public.varsity",
            title: "Eligibility review",
            summary: "Review official public eligibility context.",
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: .lowRiskSkill,
            reviewRequired: false
        )
        let graph = SourceAtlasCapabilityGraph(
            id: "graph.public.varsity",
            title: "Public Varsity Graph",
            domainPackID: "domain.public.varsity",
            capabilityNodeIDs: [node.id],
            capabilityEdgeIDs: [],
            levelLadderIDs: [],
            roleOverlayIDs: [],
            nodes: [node],
            edges: [],
            ladders: [],
            roleOverlays: [],
            state: .official,
            freshness: .current,
            riskClass: .lowRiskSkill
        )

        return SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: "source-atlas/v1/domain/sports/pack-public-varsity",
                title: "Public Varsity Pack",
                kind: .domainPack,
                version: "1.0.0",
                domainID: "sports"
            ),
            sources: [source],
            claims: [claim],
            requirements: [requirement],
            starterItems: [
                SourceAtlasStarterItem(
                    id: "starter-public-varsity",
                    title: "Review public eligibility",
                    stepCandidateSeed: "Review the public eligibility rule.",
                    storesFinalSchedule: false
                )
            ],
            proofMap: [
                SourceAtlasProofMapEntry(
                    id: "proof-public-varsity",
                    requirementID: requirement.id,
                    proofDescription: "Official public eligibility source should be reviewed.",
                    privacyClass: .externalRedacted,
                    proofCandidate: .sourceEvidence,
                    proofStrength: .officialCertified,
                    capabilityNodeID: node.id,
                    sourceRecordIDs: [source.id],
                    sourceClaimIDs: [claim.id]
                )
            ],
            projections: [],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "A public source is needed.",
                reviewRequired: "Review the public reference.",
                notProfessionalAdvice: "Public reference only."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: [node.id],
                overlayDependencyIDs: [],
                projectionRecipeIDs: ["projection.public.varsity"],
                ownsIndividualGoalPhrase: false
            ),
            domainPacks: [
                SourceAtlasDomainPack(
                    id: "domain.public.varsity",
                    title: "Public Varsity Domain",
                    domainID: "sports",
                    capabilityGraphIDs: [graph.id],
                    reusableNodeIDs: [node.id],
                    sourceSliceIDs: [source.id],
                    state: .official,
                    freshness: .current,
                    riskClass: .lowRiskSkill
                )
            ],
            capabilityGraphs: [graph]
        )
    }

    static func composition(
        goalID: String,
        pack: SourceAtlasPack
    ) -> PersonalPathComposition {
        let requirements = pack.requirements
        let requirementProjection = SourceAtlasRequirementProjection(
            requirements: requirements,
            sourceFreshnessSummary: []
        )
        let path = SourceAtlasCapabilityPath(
            id: "path.public.varsity",
            capabilityGraphID: "graph.public.varsity",
            selectedNodeIDs: ["node.public.varsity"],
            selectedEdgeIDs: [],
            selectedPathOverlayIDs: ["overlay.public.varsity"],
            selectedRoleOverlayIDs: [],
            traversalTrace: ["selected public varsity node"],
            blockedNodes: [],
            staleNodes: [],
            missingSourceNodes: [],
            requirementProjection: requirementProjection,
            score: 0.91,
            pathSummary: "Use public eligibility context as a local planning input.",
            planSkeleton: PlanSkeleton(
                milestones: [
                    PlanSkeletonMilestone(
                        id: "path.public.varsity.milestone.proof",
                        title: "Review public proof",
                        detail: "Confirm the public eligibility reference.",
                        orderIndex: 0,
                        kind: .proof,
                        requirementIDs: ["requirement-public-proof"],
                        nodeIDs: ["node.public.varsity"],
                        proofRequired: true,
                        reviewRequired: false
                    )
                ],
                phases: [
                    PlanSkeletonPhase(
                        id: "path.public.varsity.phase.proof",
                        title: "Proof",
                        detail: "Review public context before local execution.",
                        orderIndex: 0,
                        milestoneIDs: ["path.public.varsity.milestone.proof"],
                        pathNodeIDs: ["node.public.varsity"],
                        riskFlagIDs: []
                    )
                ],
                weeklyCadence: PlanSkeletonWeeklyCadence(
                    summary: "Keep one public-reference check before local action.",
                    anchorDays: ["midweek"],
                    proofTouchpoints: ["Review public proof"],
                    reviewTouchpoints: []
                ),
                proofMoments: [
                    PlanSkeletonProofMoment(
                        id: "path.public.varsity.proof",
                        title: "Collect source proof",
                        detail: "Use the public source as reference evidence.",
                        orderIndex: 0,
                        requirementIDs: ["requirement-public-proof"],
                        nodeIDs: ["node.public.varsity"]
                    )
                ],
                reviewMoments: [],
                recoveryWindows: [],
                riskFlags: [
                    PlanSkeletonRiskFlag(
                        id: "path.public.varsity.risk",
                        title: "Public source risk",
                        detail: "Public context informs but does not schedule the Step.",
                        severity: 0,
                        relatedNodeIDs: ["node.public.varsity"],
                        relatedRequirementIDs: ["requirement-public-proof"]
                    )
                ],
                feasibilityBand: .comfortablyOnTrack
            )
        )

        return PersonalPathComposition(
            goalID: goalID,
            userContextVersion: "local-context.v1",
            sourceAtlasProjectionID: "source-atlas.public.varsity.projection",
            pathInstances: [path],
            alternativePathSet: nil,
            selectedPath: path,
            rejectedPaths: [],
            pathTradeoffs: [],
            explanationProjection: SourceAtlasPathCompositionExplanationProjection(
                summary: "Local runtime applies public reference context.",
                sourceLabels: ["Public Source Atlas Pack"],
                whyThisChangesPlans: ["Public proof needs inform candidate generation."],
                confidenceLabel: "Public reference current"
            )
        )
    }
}
