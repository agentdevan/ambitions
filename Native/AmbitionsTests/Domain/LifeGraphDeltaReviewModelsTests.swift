import XCTest
@testable import Ambitions

final class LifeGraphDeltaReviewModelsTests: XCTestCase {
    func testReviewRecordInfersSourcePrivacyAndReviewRisks() {
        let record = LifeGraphDeltaReviewRecord(
            id: "review-1",
            delta: sourceNeededDelta(),
            requestedAt: "2026-05-06T15:10:00Z",
            surface: .goals
        )

        XCTAssertEqual(record.schemaVersion, lifeGraphDeltaReviewSchemaVersion)
        XCTAssertTrue(record.risks.contains(.sourceNeeded))
        XCTAssertTrue(record.risks.contains(.staleSource))
        XCTAssertTrue(record.risks.contains(.privacySensitive))
        XCTAssertTrue(record.requiresHumanReview)
        XCTAssertFalse(record.canProject)
    }

    func testApprovedRecordRequiresReceiptAndNoRisksBeforeProjection() {
        let approvedWithoutReceipt = LifeGraphDeltaReviewRecord(
            id: "review-no-receipt",
            delta: approvedDelta(),
            requestedAt: "2026-05-06T15:10:00Z",
            surface: .you,
            decision: .approvedForProjection,
            risks: []
        )
        let approvedWithReceipt = LifeGraphDeltaReviewRecord(
            id: "review-with-receipt",
            delta: approvedDelta(),
            requestedAt: "2026-05-06T15:11:00Z",
            surface: .you,
            decision: .approvedForProjection,
            receiptIDs: ["receipt-review"],
            risks: []
        )

        XCTAssertFalse(approvedWithoutReceipt.canProject)
        XCTAssertTrue(approvedWithReceipt.canProject)
    }

    func testProjectionStoreSeparatesPendingReviewFromProjectableRecords() {
        let pending = LifeGraphDeltaReviewRecord(
            id: "review-pending",
            delta: sourceNeededDelta(),
            requestedAt: "2026-05-06T15:10:00Z",
            surface: .goals
        )
        let projectable = LifeGraphDeltaReviewRecord(
            id: "review-projectable",
            delta: approvedDelta(),
            requestedAt: "2026-05-06T15:11:00Z",
            surface: .goals,
            decision: .approvedForProjection,
            receiptIDs: ["receipt-review"],
            risks: []
        )

        let store = LifeGraphDeltaReviewProjectionStore(records: [projectable, pending, pending])
        let snapshot = store.projectionSnapshot(
            for: .goals,
            generatedAt: "2026-05-06T15:12:00Z",
            id: "snapshot-goals"
        )

        XCTAssertEqual(store.records.map(\.id), ["review-pending", "review-projectable"])
        XCTAssertEqual(store.pendingRecords(for: .goals).map(\.id), ["review-pending"])
        XCTAssertEqual(store.projectableRecords(for: .goals).map(\.id), ["review-projectable"])
        XCTAssertEqual(snapshot.projectedNodeIDs, ["goal-path-1"])
        XCTAssertEqual(snapshot.reviewRecordIDs, ["review-projectable"])
        XCTAssertFalse(snapshot.isExternalSafe)
    }
}

private extension LifeGraphDeltaReviewModelsTests {
    func sourceNeededDelta() -> HumanProgressGraphDelta {
        let node = HumanProgressGraphNode(
            id: "requirement-1",
            family: .requirement,
            title: "Program deadline",
            privacyClass: .sensitive,
            sourceState: .sourceNeeded,
            freshnessState: .staleCritical,
            reviewState: .needsSourceReview,
            createdAt: "2026-05-06T15:10:00Z"
        )
        return delta(nodes: [node], eventReviewState: .needsSourceReview)
    }

    func approvedDelta() -> HumanProgressGraphDelta {
        let node = HumanProgressGraphNode(
            id: "goal-path-1",
            family: .goalPath,
            title: "Nursing school path",
            sourceState: .sourceBacked,
            freshnessState: .current,
            reviewState: .ready,
            createdAt: "2026-05-06T15:10:00Z"
        )
        return delta(nodes: [node], eventReviewState: .ready)
    }

    func delta(
        nodes: [HumanProgressGraphNode],
        eventReviewState: HumanProgressReviewState
    ) -> HumanProgressGraphDelta {
        let event = LifeGraphEventLogEntry(
            id: "event-\(nodes.first?.id ?? "node")",
            kind: .graphDeltaProposed,
            occurredAt: "2026-05-06T15:10:00Z",
            actor: .user,
            scope: .goals,
            affectedNodeIDs: nodes.map(\.id),
            sourceState: nodes.first?.sourceState ?? .unknown,
            freshnessState: nodes.first?.freshnessState ?? .unknown,
            reviewState: eventReviewState,
            summary: "Review graph delta."
        )
        return HumanProgressGraphDelta(
            id: "delta-\(nodes.first?.id ?? "node")",
            proposedAt: "2026-05-06T15:10:00Z",
            nodesToUpsert: nodes,
            event: event,
            rollbackHint: "Reject the review record before projection."
        )
    }
}
