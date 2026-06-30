import XCTest
@testable import Ambitions

final class SourceAtlasRuntimeBridgeReplayTests: XCTestCase {
    func testRuntimeBridgeReplayCapturesRequiredReceiptsAndRedactsSensitiveText() throws {
        let fixture = try makeReplayFixture(
            rawGoalText: "PRIVATE-RAW-TEXT-LEAK-MARKER",
            customCorrectionText: "PRIVATE-CUSTOM-REASON-LEAK-MARKER"
        )

        let replay = SourceAtlasRuntimeBridgeReplay(
            intentMatch: fixture.intentMatch,
            packSelection: fixture.packSelection,
            pathComposition: fixture.composition,
            stepCandidateField: fixture.field,
            factorLedger: fixture.factorLedger,
            correctionInput: fixture.correctionInput,
            generatedAt: fixture.generatedAt,
            localOnly: true
        )
        let encoded = try encodedJSONString(replay)

        XCTAssertEqual(
            replay.receiptKinds,
            [
                .sourceAtlasIntentMatched,
                .sourceAtlasPackSelected,
                .sourceAtlasPackRejected,
                .sourceAtlasPathComposed,
                .sourceAtlasPathRejected,
                .sourceAtlasFreshnessBlocked,
                .sourceAtlasStepCandidatesExpanded,
                .sourceAtlasUserCorrectionApplied,
                .sourceAtlasReplayGenerated
            ]
        )
        XCTAssertEqual(replay.inspectionSurfaceTitle, "Search Ambitions")
        XCTAssertTrue(replay.inspectionSummary.localizedCaseInsensitiveContains("source"))
        XCTAssertTrue(replay.inspectionSummary.localizedCaseInsensitiveContains("reason"))
        XCTAssertTrue(replay.inspectionSummary.localizedCaseInsensitiveContains("receipt"))
        XCTAssertTrue(replay.intent.rawGoalTextWasRedacted)
        XCTAssertEqual(replay.stepCandidateField.selectedCandidateID, fixture.field.selectedCandidateID)
        XCTAssertEqual(replay.selectedRecommendation.candidateID, fixture.field.selectedCandidateID)
        XCTAssertEqual(replay.simulationSummary.candidateID, fixture.field.selectedCandidate?.impactSimulation.candidateID)
        XCTAssertEqual(replay.factorLedgerFingerprint, fixture.factorLedger.replayProjection.stableFingerprint)
        XCTAssertEqual(replay.pathComposition.selectedPath.id, fixture.composition.selectedPath.id)
        XCTAssertEqual(replay.pathComposition.rejectedPaths.first?.id, fixture.composition.rejectedPaths.first?.id)
        XCTAssertEqual(replay.pathTradeoffCount, fixture.composition.pathTradeoffs.count)
        XCTAssertFalse(encoded.contains("PRIVATE-RAW-TEXT-LEAK-MARKER"))
        XCTAssertFalse(encoded.contains("PRIVATE-CUSTOM-REASON-LEAK-MARKER"))
        XCTAssertTrue(encoded.contains("[redacted]"))
        XCTAssertTrue(encoded.contains("inspection-surface"))
        XCTAssertTrue(encoded.contains("path-tradeoff-count"))
    }

    func testPathCorrectionChangesSelectedPathAndCandidateDeterministically() throws {
        let fixture = try makeReplayFixture(
            rawGoalText: "Make varsity football",
            customCorrectionText: nil
        )
        let correctionInput = SourceAtlasBridgeCorrectionInput(rejectedPathIDs: [fixture.composition.selectedPath.id])
        let correctedComposition = correctedComposition(
            from: fixture.composition,
            correctionInput: correctionInput
        )

        let correctedField = SourceAtlasStepCandidateFieldBridge().expand(
            goalID: fixture.goalID,
            composition: correctedComposition,
            pack: fixture.pack,
            generatedAt: fixture.generatedAt,
            factorLedger: fixture.factorLedger,
            candidateLimit: 8,
            localOnly: true
        )

        XCTAssertNotEqual(correctedComposition.selectedPath.id, fixture.composition.selectedPath.id)
        XCTAssertNotEqual(correctedField.selectedCandidateID, fixture.field.selectedCandidateID)
        XCTAssertNotEqual(correctedField.selectedCandidate?.kind, .fallback)
        XCTAssertEqual(
            correctedField,
            SourceAtlasStepCandidateFieldBridge().expand(
                goalID: fixture.goalID,
                composition: correctedComposition,
                pack: fixture.pack,
                generatedAt: fixture.generatedAt,
                factorLedger: fixture.factorLedger,
                candidateLimit: 8,
                localOnly: true
            )
        )
    }
}

private extension SourceAtlasRuntimeBridgeReplayTests {
    struct ReplayFixture {
        let goalID: String
        let generatedAt: String
        let pack: SourceAtlasPack
        let intentMatch: SourceAtlasIntentMatch
        let packSelection: SourceAtlasPackSelection
        let composition: PersonalPathComposition
        let field: StepCandidateField
        let factorLedger: PersonalizationFactorLedger
        let correctionInput: SourceAtlasBridgeCorrectionInput
    }

    func makeReplayFixture(rawGoalText: String, customCorrectionText: String?) throws -> ReplayFixture {
        let generatedAt = "2026-05-22T18:13:20Z"
        let goalID = "goal.source-atlas.runtime-replay"
        let pack = makePack()
        let selectedPath = makeFallbackPath()
        let rejectedPath = makeRejectedPath()
        let alternativePathSet = SourceAtlasAlternativePathSet(
            id: "alternatives.runtime-replay",
            personalPathInstanceIDs: [selectedPath.id, rejectedPath.id],
            sourceState: .officialCurrent,
            freshnessState: .current,
            reviewState: .approved,
            riskState: .low
        )
        let composition = PersonalPathComposition(
            goalID: goalID,
            userContextVersion: "context.v1",
            sourceAtlasProjectionID: "projection.v1",
            pathInstances: [selectedPath, rejectedPath],
            alternativePathSet: alternativePathSet,
            selectedPath: selectedPath,
            rejectedPaths: [rejectedPath],
            pathTradeoffs: [
                SourceAtlasPathTradeoff(
                    id: "tradeoff.path.alternate",
                    pathID: rejectedPath.id,
                    summary: "The alternate path is more specific but stale.",
                    advantages: ["More specific"],
                    drawbacks: ["Stale source"]
                )
            ],
            explanationProjection: SourceAtlasPathCompositionExplanationProjection(
                summary: "Choose the safest local path.",
                sourceLabels: ["Local Source Atlas Pack"],
                whyThisChangesPlans: [
                    "The selected path falls back safely when no source-backed step is available."
                ],
                confidenceLabel: "Tight but possible"
            )
        )
        let intentMatch = SourceAtlasIntentMatch(
            rawGoalText: rawGoalText,
            normalizedGoalIntent: "goal-scaffold",
            matchedDomainIDs: ["sports"],
            matchedSpecificDomainIDs: ["sports.football.high-school"],
            matchedSkillSliceIDs: ["sports.football.varsity"],
            matchedRoleIDs: ["role.athlete"],
            confidenceBand: .unknown,
            missingClarifications: ["Need one concrete goal domain or outcome."],
            sourceAtlasPackIDs: [pack.id, "pack.rejected"],
            rejectedPackIDs: ["pack.rejected"],
            matchTrace: [
                "raw=\(rawGoalText)",
                "normalized=goal-scaffold",
                "input=goal-scaffold",
                "signals=clarify,missing-source",
                "candidate-packs=\(pack.id),pack.rejected",
                "selected=\(pack.id)",
                "reject pack.rejected: stale,review-required",
                "runtime=enabled"
            ]
        )
        let packSelection = SourceAtlasPackSelection(
            selectedPackIDs: [pack.id],
            rejectedPackIDs: ["pack.rejected"],
            rejectionReasons: [
                "pack.rejected": ["stale", "review-required"]
            ],
            sourceState: .official,
            freshnessState: .current,
            riskState: .low,
            reviewState: .approved,
            canDriveRuntime: true,
            requiredUserReview: false
        )
        let factorLedger = PersonalizationFactorLedgerBuilder().build(
            PersonalizationFactorLedgerInput(
                goalID: goalID,
                goalText: "Make varsity football",
                generatedAt: DomainTimestamp.date(from: generatedAt) ?? Date(timeIntervalSince1970: 1_748_000_000),
                userContextVersion: "context.v1"
            )
        )
        let field = SourceAtlasStepCandidateFieldBridge().expand(
            goalID: goalID,
            composition: composition,
            pack: pack,
            generatedAt: generatedAt,
            factorLedger: factorLedger,
            candidateLimit: 8,
            localOnly: true
        )
        let correctionRecord = StepCandidateRejectionRecord(
            candidateID: field.selectedCandidateID,
            sourceCandidateID: field.selectedCandidate?.sourceCandidateID,
            sourceStepID: field.selectedCandidate?.sourceStepID ?? "source-atlas-fallback-step",
            contextFingerprint: "step-candidate-context.runtime-replay",
            reason: StepCandidateRejectionReason(code: .custom, customText: customCorrectionText),
            skippedReason: true,
            recordedAt: generatedAt
        )

        return ReplayFixture(
            goalID: goalID,
            generatedAt: generatedAt,
            pack: pack,
            intentMatch: intentMatch,
            packSelection: packSelection,
            composition: composition,
            field: field,
            factorLedger: factorLedger,
            correctionInput: SourceAtlasBridgeCorrectionInput(
                rejectedPathIDs: [selectedPath.id],
                rejectedCandidateHistory: [correctionRecord]
            )
        )
    }

    func makePack() -> SourceAtlasPack {
        let practiceNode = SourceAtlasCapabilityNode(
            id: "node.field.practice",
            capabilityGraphID: "graph.local.source-atlas",
            title: "Practice drill",
            summary: "A safe local practice node.",
            sourceRecordIDs: ["source.local.practice"],
            state: .official,
            freshness: .current,
            riskClass: .lowRiskSkill,
            reviewRequired: false
        )
        return SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: "pack.local",
                title: "Local Source Atlas Pack",
                kind: .domainPack,
                version: "1",
                domainID: "sports"
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
                reusableNodeIDs: [practiceNode.id],
                overlayDependencyIDs: [],
                projectionRecipeIDs: ["recipe.local"],
                ownsIndividualGoalPhrase: false
            ),
            domainPacks: [],
            specificDomainPacks: [],
            capabilityGraphs: [
                SourceAtlasCapabilityGraph(
                    id: "graph.local.source-atlas",
                    title: "Local Source Atlas Graph",
                    domainPackID: "pack.local",
                    capabilityNodeIDs: [practiceNode.id],
                    capabilityEdgeIDs: [],
                    levelLadderIDs: [],
                    roleOverlayIDs: [],
                    nodes: [practiceNode],
                    edges: [],
                    ladders: [],
                    roleOverlays: [],
                    state: .official,
                    freshness: .current,
                    riskClass: .lowRiskSkill,
                    reviewRequired: false
                )
            ]
        )
    }

    func makeFallbackPath() -> SourceAtlasCapabilityPath {
        SourceAtlasCapabilityPath(
            id: "path.source-atlas.fallback",
            capabilityGraphID: "graph.source-atlas.fallback",
            selectedNodeIDs: [],
            selectedEdgeIDs: [],
            selectedPathOverlayIDs: [],
            selectedRoleOverlayIDs: [],
            traversalTrace: ["Fallback path selected because no source-backed nodes were available."],
            blockedNodes: [],
            staleNodes: [],
            missingSourceNodes: [],
            requirementProjection: SourceAtlasRequirementProjection(
                requirements: [],
                sourceFreshnessSummary: []
            ),
            score: 0.05,
            pathSummary: "Fallback path with no selected graph.",
            planSkeleton: emptyPlanSkeleton()
        )
    }

    func makeRejectedPath() -> SourceAtlasCapabilityPath {
        SourceAtlasCapabilityPath(
            id: "path.source-atlas.alternate",
            capabilityGraphID: "graph.source-atlas.alternate",
            selectedNodeIDs: ["node.field.practice"],
            selectedEdgeIDs: [],
            selectedPathOverlayIDs: ["path.overlay.alternate"],
            selectedRoleOverlayIDs: ["role.athlete"],
            traversalTrace: ["graph.source-atlas.alternate: node node.field.practice Practice"],
            blockedNodes: [],
            staleNodes: ["node.field.practice"],
            missingSourceNodes: [],
            requirementProjection: SourceAtlasRequirementProjection(
                requirements: [],
                sourceFreshnessSummary: []
            ),
            score: 0.85,
            pathSummary: "Alternate path with a stale source node.",
            planSkeleton: emptyPlanSkeleton()
        )
    }

    func emptyPlanSkeleton() -> PlanSkeleton {
        PlanSkeleton(
            milestones: [],
            phases: [],
            weeklyCadence: PlanSkeletonWeeklyCadence(
                summary: "No recurring cadence needed.",
                anchorDays: [],
                proofTouchpoints: [],
                reviewTouchpoints: []
            ),
            proofMoments: [],
            reviewMoments: [],
            recoveryWindows: [],
            riskFlags: [],
            feasibilityBand: .comfortablyOnTrack
        )
    }

    func correctedComposition(
        from composition: PersonalPathComposition,
        correctionInput: SourceAtlasBridgeCorrectionInput
    ) -> PersonalPathComposition {
        guard correctionInput.rejectedPathIDs.contains(composition.selectedPath.id) else {
            return composition
        }

        let remainingPaths = composition.pathInstances.filter { correctionInput.rejectedPathIDs.contains($0.id) == false }
        guard let nextSelected = remainingPaths.first(where: { $0.id != composition.selectedPath.id }) ?? remainingPaths.first else {
            return composition
        }

        let correctedRejectedPaths = Array(
            Set([composition.selectedPath] + composition.rejectedPaths + composition.pathInstances.filter { $0.id != nextSelected.id && $0.id != composition.selectedPath.id })
        )
        .sorted { lhs, rhs in
            if lhs.score != rhs.score {
                return lhs.score > rhs.score
            }
            return lhs.id < rhs.id
        }
        .filter { $0.id != nextSelected.id }

        let pathTradeoffs = correctedRejectedPaths.map { rejectedPath in
            SourceAtlasPathTradeoff(
                id: "tradeoff.\(rejectedPath.id)",
                pathID: rejectedPath.id,
                summary: "Correction prefers \(nextSelected.id) over \(rejectedPath.id).",
                advantages: [nextSelected.pathSummary],
                drawbacks: [rejectedPath.pathSummary]
            )
        }

        return PersonalPathComposition(
            goalID: composition.goalID,
            userContextVersion: composition.userContextVersion,
            sourceAtlasProjectionID: composition.sourceAtlasProjectionID,
            pathInstances: composition.pathInstances,
            alternativePathSet: composition.alternativePathSet,
            selectedPath: nextSelected,
            rejectedPaths: correctedRejectedPaths,
            pathTradeoffs: pathTradeoffs,
            explanationProjection: SourceAtlasPathCompositionExplanationProjection(
                summary: "Correction selected \(nextSelected.id) instead of \(composition.selectedPath.id).",
                sourceLabels: composition.explanationProjection.sourceLabels,
                whyThisChangesPlans: [
                    "The corrected path avoids the rejected fallback."
                ],
                confidenceLabel: composition.explanationProjection.confidenceLabel
            )
        )
    }

    func encodedJSONString<T: Encodable>(_ value: T) throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(value)
        return String(decoding: data, as: UTF8.self)
    }
}
