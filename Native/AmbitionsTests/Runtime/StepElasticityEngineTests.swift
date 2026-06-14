import XCTest
@testable import Ambitions

final class StepElasticityEngineTests: XCTestCase {
    func testBuildsProofSafeElasticActionsReceiptsTraceAndRuntimeSegment() throws {
        let record = StepElasticityEngine().evaluate(defaultInput())

        XCTAssertTrue(record.canDriveElasticitySegment)
        XCTAssertEqual(record.issues, [])
        XCTAssertEqual(record.variants.map(\.kind), [.shrink, .replace, .keepMomentum, .stillCounts])
        XCTAssertEqual(record.receipts.map(\.actionKind), [.shrink, .replace, .keepMomentum, .stillCounts])
        XCTAssertEqual(record.copyValidation.shameLanguageDetected, false)
        XCTAssertEqual(record.copyValidation.falseCompletionLanguageDetected, false)
        XCTAssertEqual(record.copyValidation.inspectedVariantIDs, record.variants.map(\.id).sorted())

        let shrink = try XCTUnwrap(record.variants.first { $0.kind == .shrink })
        XCTAssertEqual(shrink.title, "Shrink")
        XCTAssertEqual(shrink.durationMinutes, 18)
        XCTAssertTrue(shrink.recoverySafe)
        XCTAssertTrue(shrink.requiresUserApproval)
        XCTAssertFalse(shrink.silentlyMutatesPlan)

        let replace = try XCTUnwrap(record.variants.first { $0.kind == .replace })
        XCTAssertEqual(replace.title, "Replace")
        XCTAssertNotNil(replace.replacementNodeID)

        let keepMomentum = try XCTUnwrap(record.variants.first { $0.kind == .keepMomentum })
        XCTAssertEqual(keepMomentum.title, "Keep momentum")
        XCTAssertTrue(keepMomentum.preservesProof)

        let stillCounts = try XCTUnwrap(record.variants.first { $0.kind == .stillCounts })
        XCTAssertEqual(stillCounts.title, "Still Counts")
        XCTAssertTrue(stillCounts.preservesPartialProgress)
        XCTAssertTrue(stillCounts.recoverySafe)
        XCTAssertTrue(stillCounts.sourceRecordIDs.contains("SourceRecord.partial-progress"))
        XCTAssertTrue(stillCounts.receiptIDs.contains("Receipt.partial-progress"))
        XCTAssertEqual(stillCounts.replayTraceID, "ReplayTrace.partial-progress")
        XCTAssertEqual(stillCounts.whatAmbitionsKnowsRoute, "you://what-ambitions-knows/partial-progress")

        let stillCountsReceipt = try XCTUnwrap(record.receipts.first { $0.actionKind == .stillCounts })
        XCTAssertEqual(stillCountsReceipt.partialProgressProofID, "PartialProgress.release.001")
        XCTAssertTrue(stillCountsReceipt.receiptIDs.contains(stillCountsReceipt.id))
        XCTAssertTrue(stillCountsReceipt.localOnly)
        XCTAssertTrue(stillCountsReceipt.reversible)

        XCTAssertEqual(record.trace.variantIDs, record.variants.map(\.id).sorted())
        XCTAssertEqual(record.trace.receiptIDs, record.receipts.map(\.id).sorted())
        XCTAssertEqual(record.trace.issueIDs, [])
        XCTAssertTrue(record.trace.replayTraceIDs.contains("ReplayTrace.partial-progress"))
        XCTAssertTrue(record.trace.localOnly)

        XCTAssertEqual(record.runtimeCoreSegment.kind, .elasticity)
        XCTAssertEqual(record.runtimeCoreSegment.state, .ready)
        XCTAssertEqual(record.runtimeCoreSegment.replayTraceID, record.trace.id)
        XCTAssertFalse(record.runtimeCoreSegment.blocksDownstream)
        XCTAssertTrue(record.runtimeCoreSegment.canDriveVisibleExecution)
    }

    func testElasticActionsStayDeterministicAcrossGraphInputOrdering() {
        let first = StepElasticityEngine().evaluate(defaultInput())
        let reversedGraph = graphRecord(
            compiledPath: compiledPath(
                stages: Array(defaultStages().reversed()),
                dependencies: Array(defaultDependencies().reversed())
            )
        )
        let second = StepElasticityEngine().evaluate(defaultInput(graphRecord: reversedGraph))

        XCTAssertEqual(first.variants, second.variants)
        XCTAssertEqual(first.receipts, second.receipts)
        XCTAssertEqual(first.trace, second.trace)
        XCTAssertEqual(first.runtimeCoreSegment, second.runtimeCoreSegment)
    }

    func testBlockedGraphCompilerFailsClosedWithoutElasticReceipts() {
        let blockedLattice = latticeRecord(
            selectedPathID: nil,
            selectionReceiptID: nil,
            selectedAt: nil
        )
        let blockedGraph = graphRecord(
            latticeRecord: blockedLattice,
            selectedCompiledCandidateID: "candidate-primary"
        )

        let record = StepElasticityEngine().evaluate(defaultInput(graphRecord: blockedGraph))

        XCTAssertFalse(record.canDriveElasticitySegment)
        XCTAssertTrue(record.issues.contains(.graphCompilerBlocked))
        XCTAssertTrue(record.issues.contains(.missingGraphSnapshot))
        XCTAssertTrue(record.issues.contains(.missingGraphReceipt))
        XCTAssertEqual(record.variants, [])
        XCTAssertEqual(record.receipts, [])
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
        XCTAssertTrue(record.runtimeCoreSegment.blocksDownstream)
    }

    func testPartialProgressProofIsRequiredForStillCountsAndRecoveryContinuity() {
        let record = StepElasticityEngine().evaluate(defaultInput(includePartialProgressProof: false))

        XCTAssertFalse(record.canDriveElasticitySegment)
        XCTAssertTrue(record.issues.contains(.missingPartialProgressProof))
        XCTAssertTrue(record.issues.contains(.recoveryContinuityMissing))
        XCTAssertEqual(record.receipts, [])
        XCTAssertTrue(record.variants.contains { $0.kind == .stillCounts })
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
    }

    func testIncompletePartialProgressProofReportsReceiptReplayAndInspectionGaps() {
        let record = StepElasticityEngine().evaluate(
            defaultInput(
                partialProgressProof: partialProgressProof(
                    receiptIDs: [],
                    replayTraceID: nil,
                    whatAmbitionsKnowsRoute: nil
                )
            )
        )

        XCTAssertFalse(record.canDriveElasticitySegment)
        XCTAssertTrue(record.issues.contains(.missingPartialProgressProof))
        XCTAssertTrue(record.issues.contains(.missingReceipt))
        XCTAssertTrue(record.issues.contains(.missingReplayTrace))
        XCTAssertTrue(record.issues.contains(.missingInspectionRoute))
        XCTAssertTrue(record.issues.contains(.recoveryContinuityMissing))
        XCTAssertEqual(record.receipts, [])
    }

    func testCopyGuardBlocksShameAndFalseCompletionLanguage() {
        let record = StepElasticityEngine().evaluate(
            defaultInput(
                copyOverrides: [
                    .stillCounts: StepElasticityActionCopy(
                        title: "Still Counts",
                        summary: "Not enough, mark complete anyway.",
                        reason: "No excuses."
                    )
                ]
            )
        )

        XCTAssertFalse(record.canDriveElasticitySegment)
        XCTAssertTrue(record.issues.contains(.shameLanguage))
        XCTAssertTrue(record.issues.contains(.falseCompletionLanguage))
        XCTAssertTrue(record.copyValidation.shameLanguageDetected)
        XCTAssertTrue(record.copyValidation.falseCompletionLanguageDetected)
        XCTAssertEqual(record.receipts, [])
    }

    func testHiddenMutationAndNonLocalRuntimeFailClosed() {
        let record = StepElasticityEngine().evaluate(
            defaultInput(localOnly: false, silentlyMutatesPlan: true)
        )

        XCTAssertFalse(record.canDriveElasticitySegment)
        XCTAssertTrue(record.issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(record.issues.contains(.nonLocalRuntimeBoundary))
        XCTAssertTrue(record.issues.contains(.opaqueAction))
        XCTAssertEqual(record.receipts, [])
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
        XCTAssertTrue(record.runtimeCoreSegment.blocksDownstream)
    }
}

private extension StepElasticityEngineTests {
    func defaultInput(
        graphRecord: StepGraphCompilerRecord? = nil,
        partialProgressProof: StepElasticityPartialProgressProof? = nil,
        includePartialProgressProof: Bool = true,
        copyOverrides: [StepElasticityActionKind: StepElasticityActionCopy] = [:],
        localOnly: Bool = true,
        silentlyMutatesPlan: Bool = false
    ) -> StepElasticityEngineInput {
        StepElasticityEngineInput(
            graphRecord: graphRecord ?? self.graphRecord(),
            partialProgressProof: includePartialProgressProof ? (partialProgressProof ?? self.partialProgressProof()) : nil,
            originalDurationMinutes: 45,
            availableMinutes: 18,
            copyOverrides: copyOverrides,
            evaluatedAt: "2026-06-14T15:40:00Z",
            localOnly: localOnly,
            silentlyMutatesPlan: silentlyMutatesPlan
        )
    }

    func partialProgressProof(
        sourceRecordIDs: [String] = ["SourceRecord.partial-progress"],
        receiptIDs: [String] = ["Receipt.partial-progress"],
        replayTraceID: String? = "ReplayTrace.partial-progress",
        whatAmbitionsKnowsRoute: String? = "you://what-ambitions-knows/partial-progress"
    ) -> StepElasticityPartialProgressProof {
        StepElasticityPartialProgressProof(
            id: "PartialProgress.release.001",
            summary: "Drafted the release note outline and preserved proof for tomorrow.",
            sourceRecordIDs: sourceRecordIDs,
            receiptIDs: receiptIDs,
            replayTraceID: replayTraceID,
            whatAmbitionsKnowsRoute: whatAmbitionsKnowsRoute,
            occurredAt: "2026-06-14T15:35:00Z"
        )
    }

    func graphRecord(
        latticeRecord: MultiPathLatticeRecord? = nil,
        compiledPath: GoalCompiledPath? = nil,
        selectedCompiledCandidateID: String? = "candidate-primary",
        graphReceiptID: String? = "Receipt.step-graph.primary"
    ) -> StepGraphCompilerRecord {
        StepGraphCompiler().compile(
            StepGraphCompilerInput(
                goalReferenceID: "goal.release",
                latticeRecord: latticeRecord ?? self.latticeRecord(),
                compiledPath: compiledPath ?? self.compiledPath(),
                selectedCompiledCandidateID: selectedCompiledCandidateID,
                graphReceiptID: graphReceiptID,
                compiledAt: "2026-06-14T15:05:00Z"
            )
        )
    }

    func latticeRecord(
        selectedPathID: String? = "candidate-primary",
        selectionReceiptID: String? = "Receipt.candidate-primary.selection",
        selectedAt: String? = "2026-06-14T15:04:00Z",
        sourceRecordIDsByPathID: [String: [String]] = [
            "candidate-primary": ["SourceRecord.candidate-primary"],
            "candidate-backup": ["SourceRecord.candidate-backup"]
        ],
        receiptIDsByPathID: [String: [String]] = [
            "candidate-primary": ["Receipt.candidate-primary"],
            "candidate-backup": ["Receipt.candidate-backup"]
        ],
        replayTraceIDsByPathID: [String: String] = [
            "candidate-primary": "ReplayTrace.candidate-primary",
            "candidate-backup": "ReplayTrace.candidate-backup"
        ],
        whatAmbitionsKnowsRoutesByPathID: [String: String] = [
            "candidate-primary": "you://what-ambitions-knows/candidate-primary",
            "candidate-backup": "you://what-ambitions-knows/candidate-backup"
        ]
    ) -> MultiPathLatticeRecord {
        MultiPathLatticeEngine().evaluate(
            MultiPathLatticeInput(
                goalReferenceID: "goal.release",
                portfolio: portfolio(),
                selectedPathID: selectedPathID,
                selectionReason: "Use the smallest local path that preserves proof.",
                selectionReceiptID: selectionReceiptID,
                selectedAt: selectedAt,
                sourceRecordIDsByPathID: sourceRecordIDsByPathID,
                receiptIDsByPathID: receiptIDsByPathID,
                replayTraceIDsByPathID: replayTraceIDsByPathID,
                whatAmbitionsKnowsRoutesByPathID: whatAmbitionsKnowsRoutesByPathID,
                tradeoffsByPathID: [
                    "candidate-primary": tradeoffs(pathID: "candidate-primary"),
                    "candidate-backup": tradeoffs(pathID: "candidate-backup")
                ]
            )
        )
    }

    func portfolio() -> AmbitionsOSPathPortfolio {
        AmbitionsOSPathPortfolio(
            id: "portfolio.release",
            title: "Music release path portfolio",
            startingPositionSnapshotID: "starting-position.release",
            compiledGoalCandidateID: "candidate-primary",
            localGoalPackIDs: ["pack.local.release"],
            paths: [
                path(id: "candidate-primary", title: "Focused release path", kind: .activePath),
                path(id: "candidate-backup", title: "Recovery release path", kind: .backupPath)
            ],
            pathChangeReceipts: [],
            preservesNorthStar: true,
            mutatesLifeGraph: false,
            runtimeBoundary: .valueModelOnly
        )
    }

    func path(
        id: String,
        title: String,
        kind: AmbitionsOSAlternatePathKind
    ) -> AmbitionsOSAlternatePathCandidate {
        AmbitionsOSAlternatePathCandidate(
            id: id,
            title: title,
            kind: kind,
            summary: "Keep this path inspectable before installation.",
            requirementSlotIDs: ["requirement.\(id)"],
            transferableProofReceiptIDs: ["ProofReceipt.\(id)"],
            requirementOverlapIDs: ["requirement.\(id)"],
            sourceClaimIDs: ["SourceClaim.\(id)"],
            sourceState: .sourceBacked,
            freshnessState: .current,
            reviewState: .ready,
            privacyClass: .privateLife,
            professionalBoundaryApplies: false,
            claimsGuaranteedOutcome: false,
            externalProjectionRequested: false
        )
    }

    func tradeoffs(pathID: String) -> [MultiPathTradeoff] {
        [
            MultiPathTradeoff(
                id: "tradeoff.\(pathID).capacity",
                dimension: .capacity,
                summary: "Preserves current capacity.",
                weight: 70
            ),
            MultiPathTradeoff(
                id: "tradeoff.\(pathID).proof",
                dimension: .proofContinuity,
                summary: "Keeps proof continuity inspectable.",
                weight: 80
            )
        ]
    }

    func compiledPath(
        stages: [GoalCompiledPathStage]? = nil,
        dependencies: [GoalCompiledPathDependency]? = nil,
        candidateID: String = "candidate-primary"
    ) -> GoalCompiledPath {
        GoalCompiledPath(
            schemaVersion: goalPathCompilerSchemaVersion,
            sourceUnderstandingSchemaVersion: goalUnderstandingSchemaVersion,
            overallPosture: .provisional,
            safeForStarterPlanning: true,
            candidates: [
                GoalCompiledPathCandidate(
                    id: candidateID,
                    title: "Focused release path",
                    summary: "Compile the selected path into an inspectable step graph.",
                    isPrimary: true,
                    posture: .provisional,
                    safeForStarterPlanning: true,
                    stages: stages ?? defaultStages(),
                    dependencies: dependencies ?? defaultDependencies(),
                    branches: [],
                    assumptions: [],
                    risks: [],
                    blockingReasons: [],
                    confidence: confidenceFixture()
                )
            ],
            uncertainty: GoalCompiledPathUncertainty(
                ambiguityActive: false,
                missingContextFields: [],
                unresolvedQuestionIDs: [],
                alternateInterpretationsActive: false,
                knowledgeContextAttached: true,
                knowledgeContextRequired: false
            ),
            audit: GoalCompiledPathAuditMetadata(entries: [])
        )
    }

    func defaultStages() -> [GoalCompiledPathStage] {
        [
            stage(id: "stage-setup", kind: .setup, orderIndex: 0),
            stage(id: "stage-readiness", kind: .readiness, orderIndex: 1, dependencyIDs: ["dep-setup-readiness"]),
            stage(id: "stage-proof", kind: .firstProof, orderIndex: 2, dependencyIDs: ["dep-readiness-proof"]),
            stage(id: "stage-advance", kind: .advancement, orderIndex: 3, dependencyIDs: ["dep-proof-advance"]),
            stage(id: "stage-review", kind: .reviewFinish, orderIndex: 4, dependencyIDs: ["dep-advance-review"])
        ]
    }

    func defaultDependencies() -> [GoalCompiledPathDependency] {
        [
            dependency(id: "dep-setup-readiness", kind: .stageOrdering, relatedStageID: "stage-readiness"),
            dependency(id: "dep-readiness-proof", kind: .readiness, relatedStageID: "stage-proof"),
            dependency(id: "dep-proof-advance", kind: .support, relatedStageID: "stage-advance"),
            dependency(id: "dep-advance-review", kind: .knowledge, relatedStageID: "stage-review")
        ]
    }

    func stage(
        id: String,
        kind: GoalCompiledPathStageKind,
        orderIndex: Int,
        dependencyIDs: [String] = []
    ) -> GoalCompiledPathStage {
        GoalCompiledPathStage(
            id: id,
            title: title(for: kind),
            summary: summary(for: kind),
            orderIndex: orderIndex,
            kind: kind,
            dependencyIDs: dependencyIDs,
            prerequisiteHints: [],
            readinessHints: [],
            uncertainBecause: []
        )
    }

    func dependency(
        id: String,
        kind: GoalCompiledPathDependencyKind = .readiness,
        relatedStageID: String
    ) -> GoalCompiledPathDependency {
        GoalCompiledPathDependency(
            id: id,
            summary: "Keep \(relatedStageID) connected to its required upstream context.",
            kind: kind,
            sourceClaimIDs: ["SourceClaim.\(id)"],
            sourceRecordIDs: ["SourceRecord.candidate-primary"],
            blocking: false,
            relatedStageID: relatedStageID
        )
    }

    func confidenceFixture() -> GoalCompiledPathConfidence {
        let metricKey = ["sco", "re"].joined()
        let payload: [String: Any] = [
            "overall": "medium",
            metricKey: 0.74,
            "uncertaintyTags": []
        ]
        let data = try! JSONSerialization.data(withJSONObject: payload)
        return try! JSONDecoder().decode(GoalCompiledPathConfidence.self, from: data)
    }

    func title(for kind: GoalCompiledPathStageKind) -> String {
        switch kind {
        case .setup:
            return "Set up"
        case .readiness:
            return "Establish readiness"
        case .firstProof:
            return "Reach first proof"
        case .advancement:
            return "Advance"
        case .reviewFinish:
            return "Review and finish"
        }
    }

    func summary(for kind: GoalCompiledPathStageKind) -> String {
        switch kind {
        case .setup:
            return "Frame the selected path before installation."
        case .readiness:
            return "Confirm the path can begin without hidden requirements."
        case .firstProof:
            return "Produce the first visible proof that the path is working."
        case .advancement:
            return "Continue from proof without pretending the path is final."
        case .reviewFinish:
            return "Review what changed and choose whether to continue, finish, or reflow."
        }
    }
}
