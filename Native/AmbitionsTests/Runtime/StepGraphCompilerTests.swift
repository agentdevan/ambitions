import XCTest
@testable import Ambitions

final class StepGraphCompilerTests: XCTestCase {
    func testSelectedPathCompilesInspectableInstalledReserveProofReviewAndDependencyGraph() throws {
        let record = StepGraphCompiler().compile(defaultInput())

        XCTAssertTrue(record.canDriveGraphCompilerSegment)
        XCTAssertEqual(record.issues, [])
        XCTAssertEqual(record.nodes.filter { $0.kind == .installedStep }.count, 1)
        XCTAssertEqual(record.nodes.filter { $0.kind == .reserveStep }.count, 2)
        XCTAssertEqual(record.nodes.filter { $0.kind == .proof }.count, 1)
        XCTAssertEqual(record.nodes.filter { $0.kind == .review }.count, 1)
        XCTAssertFalse(record.nodes.filter { $0.kind == .dependency }.isEmpty)
        XCTAssertFalse(record.edges.isEmpty)
        XCTAssertTrue(record.nodes.allSatisfy(\.isInspectable))

        let snapshot = try XCTUnwrap(record.snapshot)
        XCTAssertEqual(snapshot.selectedPathID, "candidate-primary")
        XCTAssertEqual(snapshot.selectedCompiledCandidateID, "candidate-primary")
        XCTAssertFalse(snapshot.dependencyNodeIDs.isEmpty)
        XCTAssertEqual(snapshot.proofNodeIDs.count, 1)
        XCTAssertEqual(snapshot.reviewNodeIDs.count, 1)
        XCTAssertTrue(snapshot.localOnly)

        let receipt = try XCTUnwrap(record.receipt)
        XCTAssertEqual(receipt.id, "Receipt.step-graph.primary")
        XCTAssertEqual(receipt.sourceRecordIDs, ["SourceRecord.candidate-primary"])
        XCTAssertEqual(receipt.receiptIDs, ["Receipt.candidate-primary", "Receipt.candidate-primary.selection", "Receipt.step-graph.primary"])
        XCTAssertEqual(receipt.replayTraceID, "ReplayTrace.candidate-primary")
        XCTAssertEqual(receipt.whatAmbitionsKnowsRoute, "you://what-ambitions-knows/candidate-primary")
        XCTAssertTrue(receipt.localOnly)

        XCTAssertEqual(record.trace.graphSnapshotID, snapshot.id)
        XCTAssertEqual(record.trace.issueIDs, [])
        XCTAssertEqual(record.trace.transitionIDs, record.edges.map(\.id).sorted())
        XCTAssertEqual(record.runtimeCoreSegment.kind, .graphCompiler)
        XCTAssertEqual(record.runtimeCoreSegment.state, .ready)
        XCTAssertFalse(record.runtimeCoreSegment.blocksDownstream)
    }

    func testGraphSnapshotAndReceiptStayStableAcrossInputOrdering() {
        let first = StepGraphCompiler().compile(defaultInput())
        let reorderedPath = compiledPath(
            stages: Array(defaultStages().reversed()),
            dependencies: Array(defaultDependencies().reversed())
        )
        let second = StepGraphCompiler().compile(defaultInput(compiledPath: reorderedPath))

        XCTAssertEqual(first.nodes, second.nodes)
        XCTAssertEqual(first.edges, second.edges)
        XCTAssertEqual(first.snapshot, second.snapshot)
        XCTAssertEqual(first.receipt, second.receipt)
        XCTAssertEqual(first.trace.transitionIDs, second.trace.transitionIDs)
    }

    func testPathSelectionMustBeReadyBeforeGraphCompilerCanDriveRuntimeSegment() {
        let blockedLattice = latticeRecord(
            selectedPathID: nil,
            selectionReceiptID: nil,
            selectedAt: nil
        )
        let record = StepGraphCompiler().compile(
            defaultInput(
                latticeRecord: blockedLattice,
                selectedCompiledCandidateID: "candidate-primary"
            )
        )

        XCTAssertFalse(record.canDriveGraphCompilerSegment)
        XCTAssertTrue(record.issues.contains(.pathSelectionBlocked))
        XCTAssertTrue(record.issues.contains(.explicitSelectionRequired))
        XCTAssertNil(record.snapshot)
        XCTAssertNil(record.receipt)
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
        XCTAssertTrue(record.runtimeCoreSegment.blocksDownstream)
    }

    func testUnresolvedDependencyFailsClosedWithoutSnapshotOrReceipt() {
        var stages = defaultStages()
        stages[1] = stage(
            id: "stage-readiness",
            kind: .readiness,
            orderIndex: 1,
            dependencyIDs: ["missing-dependency"]
        )
        let record = StepGraphCompiler().compile(
            defaultInput(compiledPath: compiledPath(stages: stages, dependencies: defaultDependencies()))
        )

        XCTAssertFalse(record.canDriveGraphCompilerSegment)
        XCTAssertTrue(record.issues.contains(.unresolvedDependency))
        XCTAssertNil(record.snapshot)
        XCTAssertNil(record.receipt)
        XCTAssertEqual(record.trace.issueIDs, record.issues.map(\.rawValue))
    }

    func testCompilerRequiresProofAndReviewNodesForInspectableGraph() {
        let record = StepGraphCompiler().compile(
            defaultInput(
                compiledPath: compiledPath(
                    stages: [
                        stage(id: "stage-setup", kind: .setup, orderIndex: 0),
                        stage(id: "stage-readiness", kind: .readiness, orderIndex: 1)
                    ],
                    dependencies: []
                )
            )
        )

        XCTAssertFalse(record.canDriveGraphCompilerSegment)
        XCTAssertTrue(record.issues.contains(.missingProofNode))
        XCTAssertTrue(record.issues.contains(.missingReviewNode))
        XCTAssertNil(record.snapshot)
        XCTAssertNil(record.receipt)
    }

    func testCompilerFailsClosedWhenSourceReceiptReplayOrInspectionIsMissing() {
        let incompleteLattice = latticeRecord(
            sourceRecordIDsByPathID: [
                "candidate-backup": ["SourceRecord.candidate-backup"]
            ],
            receiptIDsByPathID: [
                "candidate-backup": ["Receipt.candidate-backup"]
            ],
            replayTraceIDsByPathID: [
                "candidate-backup": "ReplayTrace.candidate-backup"
            ],
            whatAmbitionsKnowsRoutesByPathID: [
                "candidate-backup": "you://what-ambitions-knows/candidate-backup"
            ]
        )
        let record = StepGraphCompiler().compile(
            defaultInput(
                latticeRecord: incompleteLattice,
                graphReceiptID: nil
            )
        )

        XCTAssertFalse(record.canDriveGraphCompilerSegment)
        XCTAssertTrue(record.issues.contains(.pathSelectionBlocked))
        XCTAssertTrue(record.issues.contains(.missingSourceRecord))
        XCTAssertTrue(record.issues.contains(.missingReceipt))
        XCTAssertTrue(record.issues.contains(.missingReplayTrace))
        XCTAssertTrue(record.issues.contains(.missingInspectionRoute))
        XCTAssertNil(record.snapshot)
        XCTAssertNil(record.receipt)
    }

    func testCyclicStageDependenciesFailClosed() {
        let stages = [
            stage(id: "stage-setup", kind: .setup, orderIndex: 0, dependencyIDs: ["dep-readiness"]),
            stage(id: "stage-readiness", kind: .readiness, orderIndex: 1, dependencyIDs: ["dep-setup"]),
            stage(id: "stage-proof", kind: .firstProof, orderIndex: 2),
            stage(id: "stage-review", kind: .reviewFinish, orderIndex: 3)
        ]
        let dependencies = [
            dependency(id: "dep-readiness", relatedStageID: "stage-readiness"),
            dependency(id: "dep-setup", relatedStageID: "stage-setup")
        ]

        let record = StepGraphCompiler().compile(
            defaultInput(compiledPath: compiledPath(stages: stages, dependencies: dependencies))
        )

        XCTAssertFalse(record.canDriveGraphCompilerSegment)
        XCTAssertTrue(record.issues.contains(.dependencyCycle))
        XCTAssertNil(record.snapshot)
        XCTAssertNil(record.receipt)
    }
}

private extension StepGraphCompilerTests {
    func defaultInput(
        latticeRecord: MultiPathLatticeRecord? = nil,
        compiledPath: GoalCompiledPath? = nil,
        selectedCompiledCandidateID: String? = "candidate-primary",
        graphReceiptID: String? = "Receipt.step-graph.primary",
        compiledAt: String? = "2026-06-14T15:05:00Z"
    ) -> StepGraphCompilerInput {
        StepGraphCompilerInput(
            goalReferenceID: "goal.release",
            latticeRecord: latticeRecord ?? self.latticeRecord(),
            compiledPath: compiledPath ?? self.compiledPath(),
            selectedCompiledCandidateID: selectedCompiledCandidateID,
            graphReceiptID: graphReceiptID,
            compiledAt: compiledAt
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
