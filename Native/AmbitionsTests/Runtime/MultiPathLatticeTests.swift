import XCTest
@testable import Ambitions

final class MultiPathLatticeTests: XCTestCase {
    func testGeneratesMultipleViablePathsButRequiresExplicitSelectionBeforeRuntimeSegmentCanOpen() {
        let input = makeInput(selectedPathID: nil, selectionReceiptID: nil, selectedAt: nil)

        let record = MultiPathLatticeEngine().evaluate(input)

        XCTAssertEqual(record.candidates.map(\.id), ["path.active", "path.alternate", "path.recovery"])
        XCTAssertEqual(record.viablePathIDs, ["path.active", "path.alternate", "path.recovery"])
        XCTAssertTrue(record.canComparePaths)
        XCTAssertEqual(record.selectionState, .awaitingExplicitSelection)
        XCTAssertTrue(record.issues.contains(.explicitSelectionRequired))
        XCTAssertNil(record.selectionReceipt)
        XCTAssertFalse(record.canDrivePathSelectionSegment)
        XCTAssertEqual(record.runtimeCoreSegment.kind, .pathSelection)
        XCTAssertEqual(record.runtimeCoreSegment.state, .blocked)
        XCTAssertTrue(record.runtimeCoreSegment.blocksDownstream)
    }

    func testExplicitSelectionProducesReceiptPersistenceAndReadyRuntimeSegment() throws {
        let input = makeInput(
            selectedPathID: "path.alternate",
            selectionReason: "Preserve proof while reducing capacity load.",
            selectionReceiptID: "Receipt.path.alternate.selection",
            selectedAt: "2026-06-14T14:30:00Z"
        )

        let record = MultiPathLatticeEngine().evaluate(input)

        XCTAssertEqual(record.selectionState, .selected)
        XCTAssertTrue(record.issues.isEmpty)
        XCTAssertTrue(record.canDrivePathSelectionSegment)
        let receipt = try XCTUnwrap(record.selectionReceipt)
        XCTAssertEqual(receipt.selectedPathID, "path.alternate")
        XCTAssertEqual(receipt.rejectedPathIDs, ["path.active", "path.recovery"])
        XCTAssertEqual(receipt.sourceRecordIDs, ["SourceRecord.path.alternate"])
        XCTAssertEqual(receipt.receiptIDs, ["Receipt.path.alternate", "Receipt.path.alternate.selection"])
        XCTAssertEqual(receipt.replayTraceID, "ReplayTrace.path.alternate")
        XCTAssertEqual(receipt.whatAmbitionsKnowsRoute, "you://what-ambitions-knows/path.alternate")
        XCTAssertEqual(record.persistenceSnapshot.selectedPathID, "path.alternate")
        XCTAssertEqual(record.persistenceSnapshot.selectionReceiptID, receipt.id)
        XCTAssertEqual(record.runtimeCoreSegment.state, .ready)
        XCTAssertEqual(record.runtimeCoreSegment.sourceRecordIDs, ["SourceRecord.path.alternate"])
        XCTAssertEqual(record.runtimeCoreSegment.receiptIDs, ["Receipt.path.alternate", "Receipt.path.alternate.selection"])
        XCTAssertEqual(record.runtimeCoreSegment.replayTraceID, "ReplayTrace.path.alternate")
        XCTAssertEqual(record.runtimeCoreSegment.whatAmbitionsKnowsRoute, "you://what-ambitions-knows/path.alternate")
    }

    func testPathComparisonFailsClosedWhenTradeoffsAreMissing() {
        var tradeoffs = defaultTradeoffs()
        tradeoffs["path.recovery"] = []
        let input = makeInput(
            selectedPathID: "path.alternate",
            selectionReceiptID: "Receipt.path.alternate.selection",
            selectedAt: "2026-06-14T14:30:00Z",
            tradeoffsByPathID: tradeoffs
        )

        let record = MultiPathLatticeEngine().evaluate(input)

        XCTAssertFalse(record.canComparePaths)
        XCTAssertFalse(record.canDrivePathSelectionSegment)
        XCTAssertTrue(record.issues.contains(.comparisonNotReady))
        XCTAssertTrue(record.comparisonRows.first(where: { $0.pathID == "path.recovery" })?.issues.contains(.missingComparisonTradeoff) ?? false)
        XCTAssertEqual(record.selectionState, .blocked)
    }

    func testMissingSourceReceiptReplayOrInspectionBlocksSelectedPath() {
        let input = makeInput(
            selectedPathID: "path.alternate",
            selectionReceiptID: "Receipt.path.alternate.selection",
            selectedAt: "2026-06-14T14:30:00Z",
            sourceRecordIDsByPathID: ["path.active": ["SourceRecord.path.active"], "path.recovery": ["SourceRecord.path.recovery"]],
            receiptIDsByPathID: ["path.active": ["Receipt.path.active"], "path.recovery": ["Receipt.path.recovery"]],
            replayTraceIDsByPathID: ["path.active": "ReplayTrace.path.active", "path.recovery": "ReplayTrace.path.recovery"],
            whatAmbitionsKnowsRoutesByPathID: ["path.active": "you://what-ambitions-knows/path.active", "path.recovery": "you://what-ambitions-knows/path.recovery"]
        )

        let record = MultiPathLatticeEngine().evaluate(input)

        let selected = record.candidates.first { $0.id == "path.alternate" }
        XCTAssertTrue(selected?.issues.contains(.missingSourceRecord) ?? false)
        XCTAssertTrue(selected?.issues.contains(.missingReceipt) ?? false)
        XCTAssertTrue(selected?.issues.contains(.missingReplayTrace) ?? false)
        XCTAssertTrue(selected?.issues.contains(.missingInspectionRoute) ?? false)
        XCTAssertTrue(record.issues.contains(.selectedPathBlocked))
        XCTAssertNil(record.selectionReceipt)
        XCTAssertFalse(record.canDrivePathSelectionSegment)
    }

    func testPersistenceFingerprintIsStableAcrossPortfolioOrder() {
        let first = MultiPathLatticeEngine().evaluate(
            makeInput(
                selectedPathID: "path.recovery",
                selectionReceiptID: "Receipt.path.recovery.selection",
                selectedAt: "2026-06-14T14:30:00Z"
            )
        )
        let second = MultiPathLatticeEngine().evaluate(
            makeInput(
                portfolio: makePortfolio(paths: Array(defaultPaths().reversed())),
                selectedPathID: "path.recovery",
                selectionReceiptID: "Receipt.path.recovery.selection",
                selectedAt: "2026-06-14T14:30:00Z"
            )
        )

        XCTAssertEqual(first.candidates.map(\.id), second.candidates.map(\.id))
        XCTAssertEqual(first.comparisonRows, second.comparisonRows)
        XCTAssertEqual(first.persistenceSnapshot, second.persistenceSnapshot)
        XCTAssertEqual(first.id, second.id)
    }

    func testHiddenMutationAndUnsafeProjectionBlockTheLattice() {
        let portfolio = makePortfolio(
            paths: [
                path(id: "path.active", kind: .activePath),
                path(
                    id: "path.sensitive",
                    kind: .alternatePath,
                    privacyClass: .sensitive,
                    externalProjectionRequested: true
                )
            ],
            mutatesLifeGraph: true
        )
        let input = makeInput(
            portfolio: portfolio,
            selectedPathID: "path.sensitive",
            selectionReceiptID: "Receipt.path.sensitive.selection",
            selectedAt: "2026-06-14T14:30:00Z",
            sourceRecordIDsByPathID: [
                "path.active": ["SourceRecord.path.active"],
                "path.sensitive": ["SourceRecord.path.sensitive"]
            ],
            receiptIDsByPathID: [
                "path.active": ["Receipt.path.active"],
                "path.sensitive": ["Receipt.path.sensitive"]
            ],
            replayTraceIDsByPathID: [
                "path.active": "ReplayTrace.path.active",
                "path.sensitive": "ReplayTrace.path.sensitive"
            ],
            whatAmbitionsKnowsRoutesByPathID: [
                "path.active": "you://what-ambitions-knows/path.active",
                "path.sensitive": "you://what-ambitions-knows/path.sensitive"
            ],
            tradeoffsByPathID: [
                "path.active": tradeoffs(pathID: "path.active"),
                "path.sensitive": tradeoffs(pathID: "path.sensitive")
            ]
        )

        let record = MultiPathLatticeEngine().evaluate(input)

        XCTAssertTrue(record.issues.contains(.hiddenMutationRisk))
        XCTAssertTrue(record.issues.contains(.unsafeProjection))
        XCTAssertFalse(record.canDrivePathSelectionSegment)
    }
}

private extension MultiPathLatticeTests {
    func makeInput(
        portfolio: AmbitionsOSPathPortfolio? = nil,
        selectedPathID: String?,
        selectionReason: String? = nil,
        selectionReceiptID: String?,
        selectedAt: String?,
        sourceRecordIDsByPathID: [String: [String]] = [
            "path.active": ["SourceRecord.path.active"],
            "path.alternate": ["SourceRecord.path.alternate"],
            "path.recovery": ["SourceRecord.path.recovery"]
        ],
        receiptIDsByPathID: [String: [String]] = [
            "path.active": ["Receipt.path.active"],
            "path.alternate": ["Receipt.path.alternate"],
            "path.recovery": ["Receipt.path.recovery"]
        ],
        replayTraceIDsByPathID: [String: String] = [
            "path.active": "ReplayTrace.path.active",
            "path.alternate": "ReplayTrace.path.alternate",
            "path.recovery": "ReplayTrace.path.recovery"
        ],
        whatAmbitionsKnowsRoutesByPathID: [String: String] = [
            "path.active": "you://what-ambitions-knows/path.active",
            "path.alternate": "you://what-ambitions-knows/path.alternate",
            "path.recovery": "you://what-ambitions-knows/path.recovery"
        ],
        tradeoffsByPathID: [String: [MultiPathTradeoff]]? = nil
    ) -> MultiPathLatticeInput {
        MultiPathLatticeInput(
            goalReferenceID: "goal.release",
            portfolio: portfolio ?? makePortfolio(paths: defaultPaths()),
            selectedPathID: selectedPathID,
            selectionReason: selectionReason,
            selectionReceiptID: selectionReceiptID,
            selectedAt: selectedAt,
            sourceRecordIDsByPathID: sourceRecordIDsByPathID,
            receiptIDsByPathID: receiptIDsByPathID,
            replayTraceIDsByPathID: replayTraceIDsByPathID,
            whatAmbitionsKnowsRoutesByPathID: whatAmbitionsKnowsRoutesByPathID,
            tradeoffsByPathID: tradeoffsByPathID ?? defaultTradeoffs()
        )
    }

    func makePortfolio(
        paths: [AmbitionsOSAlternatePathCandidate],
        mutatesLifeGraph: Bool = false
    ) -> AmbitionsOSPathPortfolio {
        AmbitionsOSPathPortfolio(
            id: "portfolio.release",
            title: "Music release path portfolio",
            startingPositionSnapshotID: "starting-position.release",
            compiledGoalCandidateID: "compiled-goal.release",
            localGoalPackIDs: ["pack.local.release"],
            paths: paths,
            pathChangeReceipts: [],
            preservesNorthStar: true,
            mutatesLifeGraph: mutatesLifeGraph,
            runtimeBoundary: .valueModelOnly
        )
    }

    func defaultPaths() -> [AmbitionsOSAlternatePathCandidate] {
        [
            path(id: "path.active", title: "Current release path", kind: .activePath),
            path(id: "path.alternate", title: "Smaller release path", kind: .alternatePath),
            path(id: "path.recovery", title: "Recovery-first release path", kind: .backupPath)
        ]
    }

    func path(
        id: String,
        title: String = "Selectable path",
        kind: AmbitionsOSAlternatePathKind,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        externalProjectionRequested: Bool = false
    ) -> AmbitionsOSAlternatePathCandidate {
        AmbitionsOSAlternatePathCandidate(
            id: id,
            title: title,
            kind: kind,
            summary: "Keep this path inspectable before selecting it.",
            requirementSlotIDs: ["requirement.\(id)"],
            transferableProofReceiptIDs: ["ProofReceipt.\(id)"],
            requirementOverlapIDs: ["requirement.\(id)"],
            sourceClaimIDs: ["SourceClaim.\(id)"],
            sourceState: .sourceBacked,
            freshnessState: .current,
            reviewState: .ready,
            privacyClass: privacyClass,
            professionalBoundaryApplies: false,
            claimsGuaranteedOutcome: false,
            externalProjectionRequested: externalProjectionRequested
        )
    }

    func defaultTradeoffs() -> [String: [MultiPathTradeoff]] {
        [
            "path.active": tradeoffs(pathID: "path.active"),
            "path.alternate": tradeoffs(pathID: "path.alternate"),
            "path.recovery": tradeoffs(pathID: "path.recovery")
        ]
    }

    func tradeoffs(pathID: String) -> [MultiPathTradeoff] {
        [
            MultiPathTradeoff(
                id: "\(pathID).capacity",
                dimension: .capacity,
                summary: "Fits the current capacity envelope.",
                weight: 72
            ),
            MultiPathTradeoff(
                id: "\(pathID).proof",
                dimension: .proofContinuity,
                summary: "Carries proof forward without hidden mutation.",
                weight: 83
            )
        ]
    }
}
