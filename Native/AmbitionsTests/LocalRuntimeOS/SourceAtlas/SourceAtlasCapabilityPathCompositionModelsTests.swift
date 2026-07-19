import XCTest
@testable import Ambitions

final class SourceAtlasCapabilityPathCompositionModelsTests: XCTestCase {
    func testSameGoalSameLifeContextProducesDeterministicComposition() throws {
        let fixture = makeFixture()
        let first = compose(fixture: fixture, projection: fixture.fieldProjection)
        let second = compose(fixture: fixture, projection: fixture.fieldProjection)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.selectedPath.selectedPathOverlayIDs, ["path.field.access"])
        XCTAssertEqual(first.selectedPath.selectedNodeIDs, ["node.field.practice", "node.field.proof", "node.field.setup"])
        XCTAssertFalse(first.selectedPath.selectedNodeIDs.contains("node.home.setup"))
        XCTAssertFalse(first.selectedPath.selectedNodeIDs.contains("node.eligibility.review"))
        XCTAssertTrue([.comfortablyOnTrack, .onTrack].contains(first.planSkeleton.feasibilityBand))
        XCTAssertFalse(first.pathTradeoffs.isEmpty)
        XCTAssertFalse(first.planSkeleton.proofMoments.isEmpty)
        XCTAssertFalse(first.planSkeleton.recoveryWindows.isEmpty)
    }

    func testSourceAtlasPathCompositionExpandsIntoStepCandidatesWithProvenanceTrace() throws {
        let fixture = makeFixture()
        let composition = compose(fixture: fixture, projection: fixture.fieldProjection)
        let field = SourceAtlasStepCandidateFieldBridge().expand(
            goalID: "make-varsity-football",
            composition: composition,
            pack: fixture.pack,
            generatedAt: "2026-05-23T14:50:55Z",
            lifeContextProjection: fixture.fieldProjection,
            candidateLimit: 80
        )

        XCTAssertGreaterThan(field.candidates.count, 1)
        XCTAssertTrue(field.sourceProvenance.contains(.sourceAtlasPathComposition))
        XCTAssertTrue(field.sourceProvenance.contains(.sourceAtlasPack))
        XCTAssertTrue(field.sourceProvenance.contains(.sourceAtlasStepCandidateSeed))
        XCTAssertFalse(field.sourceAtlasExpansionTrace?.sourceStepCandidateSeeds.isEmpty ?? true)
        XCTAssertFalse(field.sourceAtlasExpansionTrace?.expandedCandidates.isEmpty ?? true)
        XCTAssertTrue(field.sourceAtlasExpansionTrace?.expansionRules.contains(where: { $0.localizedCaseInsensitiveContains("duplicate semantic signatures") }) ?? false)
        XCTAssertTrue(field.candidates.contains(where: { $0.kind == .proofGathering }))
        XCTAssertTrue(field.candidates.contains(where: { $0.kind == .prerequisite }))
        XCTAssertTrue(field.candidates.contains(where: { $0.kind == .recoverySafe }))
    }

    func testSourceAtlasBridgeFallsBackSafelyForUnsupportedGoals() throws {
        let fixture = makeFixture()
        let emptyPack = SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: "pack.empty",
                title: "Empty pack",
                kind: .userMiniPack,
                version: "1.0.0",
                domainID: "unknown"
            ),
            sources: [],
            claims: [],
            requirements: [],
            starterItems: [],
            proofMap: [],
            projections: [],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Context needed.",
                reviewRequired: "Review required.",
                notProfessionalAdvice: "Not professional advice."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: [],
                overlayDependencyIDs: [],
                projectionRecipeIDs: [],
                ownsIndividualGoalPhrase: false
            ),
            domainPacks: [],
            specificDomainPacks: [],
            capabilityGraphs: []
        )
        let emptyMatch = SourceAtlasIntentMatch(
            rawGoalText: "unsupported goal",
            normalizedGoalIntent: "goal-scaffold",
            matchedDomainIDs: [],
            matchedSpecificDomainIDs: [],
            matchedSkillSliceIDs: [],
            matchedRoleIDs: [],
            confidenceBand: .unknown,
            missingClarifications: ["Need one concrete goal domain or outcome."],
            sourceAtlasPackIDs: [],
            rejectedPackIDs: [],
            matchTrace: ["clarify", "missing-source"]
        )
        let emptySelection = SourceAtlasPackSelection(
            selectedPackIDs: [],
            rejectedPackIDs: [],
            rejectionReasons: [:],
            sourceState: .unknown,
            freshnessState: .unknown,
            riskState: .unknown,
            reviewState: .blocked,
            canDriveRuntime: false,
            requiredUserReview: true
        )
        let composition = SourceAtlasCapabilityPathComposer(
            goalID: "unsupported-goal",
            userContextVersion: "life-context.v1",
            sourceAtlasProjectionID: "source-atlas.projection.v1",
            packs: [emptyPack],
            match: emptyMatch,
            selection: emptySelection,
            lifeContextProjection: fixture.fieldProjection
        ).compose()
        let field = SourceAtlasStepCandidateFieldBridge().expand(
            goalID: "unsupported-goal",
            composition: composition,
            pack: emptyPack,
            generatedAt: "2026-05-23T14:50:55Z",
            lifeContextProjection: fixture.fieldProjection
        )

        XCTAssertEqual(field.candidates.count, 1)
        XCTAssertEqual(field.selectedCandidate?.kind, .fallback)
        XCTAssertTrue(field.sourceAtlasExpansionTrace?.expandedCandidates.isEmpty ?? false)
        XCTAssertFalse(field.sourceAtlasExpansionTrace?.sourceStepCandidateSeeds.isEmpty ?? true)
        XCTAssertTrue(field.sourceAtlasExpansionTrace?.rejectedSeeds.isEmpty == false)
        XCTAssertTrue(field.sourceAtlasExpansionTrace?.freshnessWarnings.isEmpty ?? true)
        XCTAssertTrue(field.selectedCandidate?.validity == .fallback || field.selectedCandidate?.validity == .review)
    }

    func testDifferentLifeContextChangesSelectedPath() throws {
        let fixture = makeFixture()
        let fieldComposition = compose(fixture: fixture, projection: fixture.fieldProjection)
        let homeComposition = compose(fixture: fixture, projection: fixture.homeProjection)

        XCTAssertNotEqual(fieldComposition.selectedPath.selectedPathOverlayIDs, homeComposition.selectedPath.selectedPathOverlayIDs)
        XCTAssertEqual(fieldComposition.selectedPath.selectedPathOverlayIDs, ["path.field.access"])
        XCTAssertEqual(homeComposition.selectedPath.selectedPathOverlayIDs, ["path.home.setup"])
        XCTAssertFalse(fieldComposition.selectedPath.selectedNodeIDs.contains("node.home.setup"))
        XCTAssertFalse(homeComposition.selectedPath.selectedNodeIDs.contains("node.field.setup"))
        XCTAssertNotEqual(fieldComposition.planSkeleton.milestones.first?.title, homeComposition.planSkeleton.milestones.first?.title)
    }

    func testMissingEquipmentCreatesSetupFirstPath() throws {
        let fixture = makeFixture()
        let composition = compose(fixture: fixture, projection: fixture.homeProjection)

        XCTAssertEqual(composition.selectedPath.selectedPathOverlayIDs, ["path.home.setup"])
        XCTAssertEqual(composition.planSkeleton.milestones.first?.kind, .setup)
        XCTAssertTrue(composition.planSkeleton.milestones.first?.title.localizedCaseInsensitiveContains("set up") ?? false)
        XCTAssertTrue(composition.planSkeleton.riskFlags.contains(where: { $0.title == "Setup risk" }))
    }

    func testBlockedPrerequisiteMovesSetupBeforeExecution() throws {
        let fixture = makeFixture(fieldSetupBlocked: true)
        let composition = compose(fixture: fixture, projection: fixture.eligibilityProjection)

        XCTAssertEqual(composition.selectedPath.selectedPathOverlayIDs, ["path.eligibility.route"])
        XCTAssertEqual(composition.planSkeleton.milestones.first?.kind, .setup)
        XCTAssertEqual(composition.planSkeleton.phases.first?.title, "Setup")
        XCTAssertTrue(composition.selectedPath.blockedNodes.contains("node.field.setup"))
        XCTAssertTrue(composition.selectedPath.traversalTrace.contains(where: { $0.contains("blocked edge") || $0.contains("node.field.setup") }))
    }

    func testEligibilityPathwayChangesPathAndSupportsLedgerScore() throws {
        let fixture = makeFixture()
        let baseline = compose(fixture: fixture, projection: fixture.eligibilityProjection)
        let influenceSet = makeLocalInfluenceSet(
            id: "eligibility",
            kind: .eligibilityPathway,
            summary: "Eligibility pathway favors the composed path.",
            affectedArea: "eligibility"
        )
        let withInfluence = compose(fixture: fixture, projection: fixture.eligibilityProjection, localInfluenceSet: influenceSet)

        XCTAssertEqual(baseline.selectedPath.selectedPathOverlayIDs, ["path.eligibility.route"])
        XCTAssertEqual(withInfluence.selectedPath.selectedPathOverlayIDs, ["path.eligibility.route"])
        XCTAssertGreaterThanOrEqual(withInfluence.selectedPath.score, baseline.selectedPath.score)
        XCTAssertTrue(withInfluence.explanationProjection.summary.localizedCaseInsensitiveContains("eligibility"))
    }
}

private extension SourceAtlasCapabilityPathCompositionModelsTests {
    struct Fixture {
        let pack: SourceAtlasPack
        let fieldProjection: LifeContextRuntimeProjection
        let homeProjection: LifeContextRuntimeProjection
        let eligibilityProjection: LifeContextRuntimeProjection
        let match: SourceAtlasIntentMatch
        let selection: SourceAtlasPackSelection
    }

    func compose(
        fixture: Fixture,
        projection: LifeContextRuntimeProjection,
        localInfluenceSet: SourceAtlasLocalInfluenceSet? = nil
    ) -> PersonalPathComposition {
        SourceAtlasCapabilityPathComposer(
            goalID: "make-varsity-football",
            userContextVersion: "life-context.v1",
            sourceAtlasProjectionID: "source-atlas.projection.v1",
            packs: [fixture.pack],
            match: fixture.match,
            selection: fixture.selection,
            lifeContextProjection: projection,
            localInfluenceSet: localInfluenceSet
        )
        .compose()
    }

    func makeFixture(fieldSetupBlocked: Bool = false) -> Fixture {
        let source = SourceAtlasSourceRecord(
            id: "source.varsity.1",
            title: "Coach interview",
            kind: .official,
            locator: "https://example.test/source.varsity.1",
            retrievedAt: "2026-05-23T14:50:55Z",
            contentHash: "hash-source-varsity-1",
            approvedForOfficialClaims: true
        )

        let claim = SourceAtlasClaim(
            id: "claim.varsity.1",
            text: "Varsity football path remains source-backed.",
            state: .official,
            freshness: .current,
            riskClass: .sportRules,
            sourceIDs: [source.id],
            reviewRequired: false
        )

        let requirements = [
            SourceAtlasRequirement(
                id: "requirement.field.access",
                claimID: claim.id,
                title: "Field access",
                kind: .equipment,
                required: true,
                sourceState: .officialCurrent,
                freshnessState: .current,
                riskState: .low,
                reviewState: .approved
            ),
            SourceAtlasRequirement(
                id: "requirement.eligibility.review",
                claimID: claim.id,
                title: "Eligibility review",
                kind: .prerequisite,
                required: true,
                sourceState: .officialCurrent,
                freshnessState: .current,
                riskState: .low,
                reviewState: .approved
            ),
            SourceAtlasRequirement(
                id: "requirement.proof.video",
                claimID: claim.id,
                title: "Proof video",
                kind: .proof,
                required: true,
                sourceState: .officialCurrent,
                freshnessState: .current,
                riskState: .low,
                reviewState: .approved
            ),
            SourceAtlasRequirement(
                id: "requirement.recovery.buffer",
                claimID: claim.id,
                title: "Recovery buffer",
                kind: .accelerator,
                required: false,
                sourceState: .officialCurrent,
                freshnessState: .current,
                riskState: .low,
                reviewState: .approved
            )
        ]

        let homeSetupNode = SourceAtlasCapabilityNode(
            id: "node.home.setup",
            capabilityGraphID: "graph.varsity",
            title: "Home equipment setup",
            summary: "Set up equipment at home and keep the path local.",
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: .sportRules,
            reviewRequired: false
        )
        let homePracticeNode = SourceAtlasCapabilityNode(
            id: "node.home.practice",
            capabilityGraphID: "graph.varsity",
            title: "Home practice",
            summary: "Run the practice without travel.",
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: .sportRules,
            reviewRequired: false
        )
        let homeProofNode = SourceAtlasCapabilityNode(
            id: "node.home.proof",
            capabilityGraphID: "graph.varsity",
            title: "Home proof",
            summary: "Capture proof and review at home.",
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: .sportRules,
            reviewRequired: false
        )
        let fieldSetupNode = SourceAtlasCapabilityNode(
            id: "node.field.setup",
            capabilityGraphID: "graph.varsity",
            title: "Field access setup",
            summary: "Confirm field access and travel.",
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: .sportRules,
            reviewRequired: fieldSetupBlocked
        )
        let fieldPracticeNode = SourceAtlasCapabilityNode(
            id: "node.field.practice",
            capabilityGraphID: "graph.varsity",
            title: "Field practice",
            summary: "Train on the field.",
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: .sportRules,
            reviewRequired: false
        )
        let fieldProofNode = SourceAtlasCapabilityNode(
            id: "node.field.proof",
            capabilityGraphID: "graph.varsity",
            title: "Field proof",
            summary: "Capture proof on-site.",
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: .sportRules,
            reviewRequired: false
        )
        let eligibilityNode = SourceAtlasCapabilityNode(
            id: "node.eligibility.review",
            capabilityGraphID: "graph.varsity",
            title: "Eligibility review",
            summary: "Confirm the eligibility pathway before the field route.",
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: .sportRules,
            reviewRequired: false
        )

        let edges = [
            SourceAtlasCapabilityEdge(
                id: "edge.home.setup.practice",
                capabilityGraphID: "graph.varsity",
                sourceNodeID: homeSetupNode.id,
                targetNodeID: homePracticeNode.id,
                kind: .prerequisite,
                state: .official,
                freshness: .current,
                riskClass: .sportRules,
                reviewRequired: false,
                sourceRecordIDs: [source.id]
            ),
            SourceAtlasCapabilityEdge(
                id: "edge.home.practice.proof",
                capabilityGraphID: "graph.varsity",
                sourceNodeID: homePracticeNode.id,
                targetNodeID: homeProofNode.id,
                kind: .unlocks,
                state: .official,
                freshness: .current,
                riskClass: .sportRules,
                reviewRequired: false,
                sourceRecordIDs: [source.id]
            ),
            SourceAtlasCapabilityEdge(
                id: "edge.field.setup.practice",
                capabilityGraphID: "graph.varsity",
                sourceNodeID: fieldSetupNode.id,
                targetNodeID: fieldPracticeNode.id,
                kind: .prerequisite,
                state: .official,
                freshness: .current,
                riskClass: .sportRules,
                reviewRequired: false,
                sourceRecordIDs: [source.id]
            ),
            SourceAtlasCapabilityEdge(
                id: "edge.field.practice.proof",
                capabilityGraphID: "graph.varsity",
                sourceNodeID: fieldPracticeNode.id,
                targetNodeID: fieldProofNode.id,
                kind: .unlocks,
                state: .official,
                freshness: .current,
                riskClass: .sportRules,
                reviewRequired: false,
                sourceRecordIDs: [source.id]
            ),
            SourceAtlasCapabilityEdge(
                id: "edge.eligibility.field",
                capabilityGraphID: "graph.varsity",
                sourceNodeID: eligibilityNode.id,
                targetNodeID: fieldSetupNode.id,
                kind: .reinforces,
                state: .official,
                freshness: .current,
                riskClass: .sportRules,
                reviewRequired: false,
                sourceRecordIDs: [source.id]
            )
        ]

        let roleID = "role.athlete"
        let fieldOverlay = SourceAtlasPathOverlay(
            id: "path.field.access",
            title: "Field access route",
            skillSliceID: "sports.football.varsity",
            capabilityNodeIDs: [fieldSetupNode.id, fieldPracticeNode.id, fieldProofNode.id],
            pathPriority: 4,
            roleID: roleID,
            claimIDs: [claim.id],
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: .sportRules,
            reviewRequired: false
        )
        let homeOverlay = SourceAtlasPathOverlay(
            id: "path.home.setup",
            title: "Home equipment route",
            skillSliceID: "sports.football.varsity",
            capabilityNodeIDs: [homeSetupNode.id, homePracticeNode.id, homeProofNode.id],
            pathPriority: 2,
            roleID: roleID,
            claimIDs: [claim.id],
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: .sportRules,
            reviewRequired: false
        )
        let eligibilityOverlay = SourceAtlasPathOverlay(
            id: "path.eligibility.route",
            title: "Eligibility route",
            skillSliceID: "sports.football.varsity",
            capabilityNodeIDs: [eligibilityNode.id, fieldSetupNode.id, fieldPracticeNode.id, fieldProofNode.id],
            pathPriority: 5,
            roleID: roleID,
            claimIDs: [claim.id],
            sourceRecordIDs: [source.id],
            state: .official,
            freshness: .current,
            riskClass: .sportRules,
            reviewRequired: false
        )

        let graph = SourceAtlasCapabilityGraph(
            id: "graph.varsity",
            title: "Varsity football capability graph",
            domainPackID: "domain.varsity",
            capabilityNodeIDs: [homeSetupNode.id, homePracticeNode.id, homeProofNode.id, fieldSetupNode.id, fieldPracticeNode.id, fieldProofNode.id, eligibilityNode.id],
            capabilityEdgeIDs: edges.map(\.id),
            levelLadderIDs: ["ladder.varsity"],
            roleOverlayIDs: [roleID],
            nodes: [homeSetupNode, homePracticeNode, homeProofNode, fieldSetupNode, fieldPracticeNode, fieldProofNode, eligibilityNode],
            edges: edges,
            ladders: [
                SourceAtlasLevelLadder(
                    id: "ladder.varsity",
                    title: "Varsity ladder",
                    capabilityGraphID: "graph.varsity",
                    pathOverlays: [fieldOverlay, homeOverlay, eligibilityOverlay],
                    levelLabels: ["setup", "practice", "proof"]
                )
            ],
            roleOverlays: [
                SourceAtlasRoleOverlay(
                    id: roleID,
                    roleID: roleID,
                    skillSliceID: "sports.football.varsity",
                    reusableNodeIDs: [homeSetupNode.id, homePracticeNode.id, homeProofNode.id, fieldSetupNode.id, fieldPracticeNode.id, fieldProofNode.id, eligibilityNode.id],
                    state: .official,
                    freshness: .current,
                    riskClass: .sportRules,
                    sourceIDs: [source.id],
                    reviewRequired: false
                )
            ],
            state: .official,
            freshness: .current,
            riskClass: .sportRules,
            reviewRequired: false
        )

        let pack = SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: "pack.varsity",
                title: "Varsity football pack",
                kind: .capabilityGraph,
                version: "1.0.0",
                domainID: "sports",
                specificDomainID: "sports.football.varsity"
            ),
            sources: [source],
            claims: [claim],
            requirements: requirements,
            starterItems: [
                SourceAtlasStarterItem(
                    id: "starter.varsity",
                    title: "Varsity starter",
                    stepCandidateSeed: "Start with the composed path.",
                    storesFinalSchedule: false
                )
            ],
            proofMap: [
                SourceAtlasProofMapEntry(
                    id: "proof.varsity",
                    requirementID: "requirement.proof.video",
                    proofDescription: "Practice proof and review.",
                    privacyClass: .privateLife,
                    proofCandidate: .sourceEvidence,
                    proofStrength: .officialCertified,
                    capabilityNodeID: fieldProofNode.id,
                    sourceRecordIDs: [source.id],
                    sourceClaimIDs: [claim.id],
                    correctionHookIDs: ["hook.correct"],
                    revocationHookIDs: ["hook.revoke"],
                    evidenceLedgerBridgeIDs: ["ledger.varsity"]
                )
            ],
            projections: [
                SourceAtlasGoalProjection(
                    id: "projection.varsity",
                    goalIntent: "make-varsity-football",
                    requiredPackIDs: ["pack.varsity"],
                    projectionProfiles: [
                        SourceAtlasProjectionProfile(
                            id: "projection-profile.varsity",
                            profileTitle: "Varsity football profile",
                            sourceState: .officialCurrent,
                            freshnessState: .current,
                            riskState: .low,
                            reviewState: .approved,
                            producesPersonalPathInstance: true,
                            producesProjectionReceipt: true,
                            optionValueMap: SourceAtlasOptionValueMap(
                                id: "option.varsity",
                                values: ["goal": "make-varsity-football"],
                                sourceState: .officialCurrent,
                                freshnessState: .current,
                                reviewState: .approved,
                                riskState: .low
                            ),
                            personalPathInstances: [
                                SourceAtlasPersonalPathInstance(
                                    id: "path-instance.varsity",
                                    personalPathTemplateID: "template.varsity",
                                    stepCandidateSeeds: [
                                        SourceAtlasStepCandidateSeed(
                                            id: "seed.varsity",
                                            stepCandidate: "Start the selected varsity path."
                                        )
                                    ],
                                    sourceState: .officialCurrent,
                                    freshnessState: .current,
                                    reviewState: .approved,
                                    riskState: .low,
                                    sourceRecordIDs: [source.id]
                                )
                            ]
                        )
                    ]
                )
            ],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Context needed.",
                reviewRequired: "Review required.",
                notProfessionalAdvice: "Not professional advice."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: graph.capabilityNodeIDs,
                overlayDependencyIDs: [roleID],
                projectionRecipeIDs: ["projection.varsity"],
                ownsIndividualGoalPhrase: false
            ),
            domainPacks: [
                SourceAtlasDomainPack(
                    id: "domain.varsity",
                    title: "Varsity football domain pack",
                    domainID: "sports",
                    capabilityGraphIDs: [graph.id],
                    specificDomainPackIDs: ["sports.football.varsity"],
                    reusableNodeIDs: graph.capabilityNodeIDs,
                    sourceSliceIDs: [source.id],
                    state: .official,
                    freshness: .current,
                    riskClass: .sportRules,
                    reviewRequired: false
                )
            ],
            specificDomainPacks: [
                SourceAtlasSpecificDomainPack(
                    id: "sports.football.varsity",
                    title: "Varsity football specific pack",
                    domainPackID: "domain.varsity",
                    capabilityGraphID: graph.id,
                    skillSliceIDs: ["sports.football.varsity"],
                    roleOverlayIDs: [roleID],
                    pathOverlayIDs: [fieldOverlay.id, homeOverlay.id, eligibilityOverlay.id],
                    state: .official,
                    freshness: .current,
                    riskClass: .sportRules,
                    reviewRequired: false,
                    sourceSliceIDs: [source.id]
                )
            ],
            capabilityGraphs: [graph]
        )

        let lifeContextSource = LifeContextSource(
            id: "source.life.1",
            label: "Life context interview",
            kind: .userConfirmed,
            timestamp: "2026-05-23T14:50:55Z",
            visibleExplanation: "Used to seed the runtime projection."
        )

        let baseProfile = LifeContextProfile(
            id: "profile.base",
            exactAgeYears: 17,
            timezone: "America/New_York",
            locale: "en_US",
            generalLocationLabel: "Metro region",
            locationPrecision: .cityRegion,
            sexOrEligibilityContext: "woman",
            lifeStage: .highSchool,
            schoolOrWorkContext: "High school athletics",
            travelRadiusMinutes: 40,
            travelRadiusMiles: 18,
            transportationAccess: .car,
            scheduleAnchors: ["after school"],
            dependencyConstraints: [],
            budgetConstraintBand: .moderate,
            energyPattern: .morning,
            recoveryConstraints: ["Protect recovery after practice."],
            accessibilityNeeds: [],
            userNotes: "Context used by the path composer tests."
        )

        let fieldBundle = LifeContextBundle(
            id: "bundle.field",
            profile: baseProfile,
            eligibilityPathways: [],
            opportunityContexts: [
                OpportunityContext(
                    id: "opportunity.field",
                    facilities: [.field],
                    equipmentAccess: ["field access", "cones"],
                    localOrganizations: ["School athletics"],
                    eventExposureAccess: true,
                    remoteAccess: false,
                    seasonalAvailability: "Fall season",
                    verificationStatus: .verified
                )
            ],
            historicalFacts: [],
            sources: [lifeContextSource],
            createdAt: "2026-05-23T14:50:55Z",
            updatedAt: "2026-05-23T14:50:55Z"
        )

        let homeBundle = LifeContextBundle(
            id: "bundle.home",
            profile: baseProfile.updatedForHomeOnlyContext(),
            eligibilityPathways: [],
            opportunityContexts: [
                OpportunityContext(
                    id: "opportunity.home",
                    facilities: [.home],
                    equipmentAccess: [],
                    localOrganizations: ["Neighborhood training"],
                    eventExposureAccess: false,
                    remoteAccess: true,
                    seasonalAvailability: "Year-round",
                    verificationStatus: .verified
                )
            ],
            historicalFacts: [],
            sources: [lifeContextSource],
            createdAt: "2026-05-23T14:50:55Z",
            updatedAt: "2026-05-23T14:50:55Z"
        )

        let eligibilityBundle = LifeContextBundle(
            id: "bundle.eligibility",
            profile: baseProfile,
            eligibilityPathways: [
                LifeContextEligibilityPathway(
                    id: "eligibility.sport",
                    pathwayType: .sport,
                    eligibilityRulesSummary: "Confirm the sport pathway and league eligibility.",
                    sexLeaguePathway: "Women's league pathway",
                    locationDependent: true,
                    source: lifeContextSource,
                    freshness: .current,
                    userConfirmed: true
                )
            ],
            opportunityContexts: [
                OpportunityContext(
                    id: "opportunity.eligibility",
                    facilities: [.field],
                    equipmentAccess: ["field access", "cones"],
                    localOrganizations: ["School athletics"],
                    eventExposureAccess: true,
                    remoteAccess: false,
                    seasonalAvailability: "Fall season",
                    verificationStatus: .verified
                )
            ],
            historicalFacts: [],
            sources: [lifeContextSource],
            createdAt: "2026-05-23T14:50:55Z",
            updatedAt: "2026-05-23T14:50:55Z"
        )

        let match = SourceAtlasIntentMatch(
            rawGoalText: "Make varsity football",
            normalizedGoalIntent: "make-varsity-football",
            matchedDomainIDs: ["sports"],
            matchedSpecificDomainIDs: ["sports.football.varsity"],
            matchedSkillSliceIDs: ["sports.football.varsity"],
            matchedRoleIDs: ["role.athlete"],
            confidenceBand: .high,
            missingClarifications: [],
            sourceAtlasPackIDs: [pack.id],
            rejectedPackIDs: [],
            matchTrace: ["signals=football,varsity,high-school"]
        )
        let selection = SourceAtlasPackSelection(
            selectedPackIDs: [pack.id],
            rejectedPackIDs: [],
            rejectionReasons: [:],
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved,
            canDriveRuntime: true,
            requiredUserReview: false
        )

        return Fixture(
            pack: pack,
            fieldProjection: fieldBundle.projection(asOf: try! XCTUnwrap(DomainTimestamp.date(from: "2026-05-23T14:50:55Z"))),
            homeProjection: homeBundle.projection(asOf: try! XCTUnwrap(DomainTimestamp.date(from: "2026-05-23T14:50:55Z"))),
            eligibilityProjection: eligibilityBundle.projection(asOf: try! XCTUnwrap(DomainTimestamp.date(from: "2026-05-23T14:50:55Z"))),
            match: match,
            selection: selection
        )
    }

    func makeLocalInfluenceSet(
        id: String,
        kind: SourceAtlasLocalInfluenceKind,
        summary: String,
        affectedArea: String
    ) -> SourceAtlasLocalInfluenceSet {
        SourceAtlasLocalInfluenceSet(
            stableFingerprint: "\(id).fingerprint",
            signals: [
                SourceAtlasLocalInfluenceSignal(
                    id: "signal.\(id)",
                    kind: kind,
                    summary: summary,
                    affectedArea: affectedArea,
                    lastAffectedLabel: summary,
                    fallbackBehavior: "Falls back to the base context.",
                    sourceLabel: summary,
                    weight: 0.8
                )
            ]
        )
    }
}

private extension LifeContextProfile {
    func updatedForHomeOnlyContext() -> LifeContextProfile {
        LifeContextProfile(
            id: id,
            birthdate: birthdate,
            exactAgeYears: exactAgeYears,
            ageSource: ageSource,
            ageLastConfirmedAt: ageLastConfirmedAt,
            timezone: timezone,
            locale: locale,
            generalLocationLabel: generalLocationLabel,
            locationPrecision: locationPrecision,
            sexOrEligibilityContext: sexOrEligibilityContext,
            lifeStage: lifeStage,
            schoolOrWorkContext: schoolOrWorkContext,
            travelRadiusMinutes: travelRadiusMinutes,
            travelRadiusMiles: travelRadiusMiles,
            transportationAccess: .limited,
            scheduleAnchors: scheduleAnchors,
            dependencyConstraints: dependencyConstraints,
            budgetConstraintBand: budgetConstraintBand,
            energyPattern: energyPattern,
            recoveryConstraints: recoveryConstraints,
            accessibilityNeeds: accessibilityNeeds,
            userNotes: userNotes
        )
    }
}
