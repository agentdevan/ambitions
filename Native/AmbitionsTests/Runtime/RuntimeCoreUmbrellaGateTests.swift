import XCTest
@testable import Ambitions

final class RuntimeCoreUmbrellaGateTests: XCTestCase {
    func testCompleteLocalChainCanOpenRuntimeCoreGate() {
        let record = RuntimeCoreUmbrellaGate().evaluate(
            RuntimeCoreUmbrellaGateInput(segments: makeCompleteSegments())
        )

        XCTAssertTrue(record.isLocalOnly)
        XCTAssertTrue(record.canOpenRuntimeCore)
        XCTAssertEqual(record.gateIssues, [])
        XCTAssertEqual(record.blockedSegmentKinds, [])
        XCTAssertEqual(record.rows.map(\.kind), RuntimeCoreChainSegmentKind.requiredOrder)
        XCTAssertTrue(record.rows.allSatisfy(\.canDriveSegment))
        XCTAssertTrue(record.rows.allSatisfy { $0.sourceRecordIDs.isEmpty == false })
        XCTAssertTrue(record.rows.allSatisfy { $0.receiptIDs.isEmpty == false })
        XCTAssertTrue(record.rows.allSatisfy { $0.replayTraceID != nil })
        XCTAssertTrue(record.rows.allSatisfy { $0.whatAmbitionsKnowsRoute != nil })
    }

    func testMissingRequiredSegmentFailsClosedAndBlocksDownstreamRows() {
        let segments = makeCompleteSegments().filter { $0.kind != .graphCompiler }

        let record = RuntimeCoreUmbrellaGate().evaluate(
            RuntimeCoreUmbrellaGateInput(segments: segments)
        )

        XCTAssertFalse(record.canOpenRuntimeCore)
        XCTAssertTrue(record.gateIssues.contains(.missingSegment))
        XCTAssertEqual(record.rows.first(where: { $0.kind == .graphCompiler })?.issues, [.missingSegment])
        XCTAssertTrue(record.rows.first(where: { $0.kind == .elasticity })?.issues.contains(.blockedByUpstream) ?? false)
        XCTAssertEqual(record.blockedSegmentKinds.first, .graphCompiler)
    }

    func testBlockedDownstreamSegmentFailsClosedWithoutMaskingEarlierReadyRows() {
        var segments = makeCompleteSegments()
        segments.replaceSegment(
            makeSegment(
                .highRiskSafety,
                state: .blocked,
                canDriveVisibleExecution: false,
                blocksDownstream: true
            )
        )

        let record = RuntimeCoreUmbrellaGate().evaluate(
            RuntimeCoreUmbrellaGateInput(segments: segments)
        )

        XCTAssertFalse(record.canOpenRuntimeCore)
        XCTAssertTrue(record.rows.first(where: { $0.kind == .pathSelection })?.canDriveSegment ?? false)
        let safetyIssues = record.rows.first(where: { $0.kind == .highRiskSafety })?.issues ?? []
        XCTAssertTrue(safetyIssues.contains(.segmentBlocked))
        XCTAssertTrue(safetyIssues.contains(.cannotDriveVisibleExecution))
        XCTAssertTrue(safetyIssues.contains(.blocksDownstream))
    }

    func testScheduleAndReflowSegmentsMustRemainReversible() {
        var segments = makeCompleteSegments()
        segments.replaceSegment(makeSegment(.scheduleInstall, isReversible: false))
        segments.replaceSegment(makeSegment(.consequenceReflow, isReversible: false))

        let record = RuntimeCoreUmbrellaGate().evaluate(
            RuntimeCoreUmbrellaGateInput(segments: segments)
        )

        XCTAssertFalse(record.canOpenRuntimeCore)
        XCTAssertEqual(
            record.rows.first(where: { $0.kind == .scheduleInstall })?.issues,
            [.irreversibleRequiredSegment]
        )
        XCTAssertEqual(
            record.rows.first(where: { $0.kind == .consequenceReflow })?.issues,
            [.blockedByUpstream, .irreversibleRequiredSegment]
        )
    }

    func testRowsAndGateIdentifierAreStableAcrossInputOrder() {
        let firstRecord = RuntimeCoreUmbrellaGate().evaluate(
            RuntimeCoreUmbrellaGateInput(segments: Array(makeCompleteSegments().reversed()))
        )
        let secondRecord = RuntimeCoreUmbrellaGate().evaluate(
            RuntimeCoreUmbrellaGateInput(segments: makeCompleteSegments().shuffledForDeterministicFixture())
        )

        XCTAssertEqual(firstRecord.rows, secondRecord.rows)
        XCTAssertEqual(firstRecord.id, secondRecord.id)
        XCTAssertEqual(firstRecord.rows.map(\.kind), RuntimeCoreChainSegmentKind.requiredOrder)
    }

    func testNonLocalBoundaryFailsClosedEvenWhenSegmentsAreReady() {
        let record = RuntimeCoreUmbrellaGate().evaluate(
            RuntimeCoreUmbrellaGateInput(
                boundary: nonLocalBoundary(),
                segments: makeCompleteSegments()
            )
        )

        XCTAssertFalse(record.isLocalOnly)
        XCTAssertFalse(record.canOpenRuntimeCore)
        XCTAssertTrue(record.gateIssues.contains(.nonLocalRuntimeBoundary))
        XCTAssertTrue(record.rows.allSatisfy { $0.issues.contains(.nonLocalRuntimeBoundary) })
    }
}

private extension RuntimeCoreUmbrellaGateTests {
    func makeCompleteSegments() -> [RuntimeCoreChainSegment] {
        RuntimeCoreChainSegmentKind.requiredOrder.map { makeSegment($0) }
    }

    func makeSegment(
        _ kind: RuntimeCoreChainSegmentKind,
        state: RuntimeCoreChainSegmentState = .ready,
        isReversible: Bool = true,
        canDriveVisibleExecution: Bool = true,
        blocksDownstream: Bool = false
    ) -> RuntimeCoreChainSegment {
        RuntimeCoreChainSegment(
            kind: kind,
            state: state,
            sourceRecordIDs: ["source.\(kind.rawValue)"],
            receiptIDs: ["receipt.\(kind.rawValue)"],
            replayTraceID: "replay.\(kind.rawValue)",
            whatAmbitionsKnowsRoute: "you://what-ambitions-knows/\(kind.rawValue)",
            isReversible: isReversible,
            canDriveVisibleExecution: canDriveVisibleExecution,
            blocksDownstream: blocksDownstream
        )
    }

    func nonLocalBoundary() -> PrivateLifeRuntimeBoundary {
        PrivateLifeRuntimeBoundary(
            usesSwiftDataPersistence: true,
            usesRepositoryBackedMemory: true,
            syncBackendKind: .cloudKitContinuity,
            hasHostedBackend: false,
            hasRemoteIntelligenceBackend: true,
            hasExternalCloudLLMDependency: false,
            allowsExternalSideEffectsInsideUnitOfWorkBoundaries: false
        )
    }
}

private extension Array where Element == RuntimeCoreChainSegment {
    mutating func replaceSegment(_ segment: RuntimeCoreChainSegment) {
        guard let index = firstIndex(where: { $0.kind == segment.kind }) else {
            append(segment)
            return
        }
        self[index] = segment
    }

    func shuffledForDeterministicFixture() -> [RuntimeCoreChainSegment] {
        [
            self[3],
            self[0],
            self[6],
            self[2],
            self[5],
            self[1],
            self[4]
        ]
    }
}
