import XCTest
@testable import Ambitions

final class AmbitionGraphLineageModelsTests: XCTestCase {
    func testLineageIDStaysStableAcrossEditedOrMovedTombstones() {
        let initial = EntityRevisionTombstone(
            id: "goal-1-revision-1",
            entityKind: .goal,
            entityID: "goal-1",
            revisionMarker: "rev-1",
            reason: .deleted,
            recordedAt: "2026-05-12T10:00:00Z",
            privacyClass: .sharedReceipt,
            sourceRecordID: "SourceRecord.goal.1",
            receiptID: "Receipt.goal.1",
            replayTraceID: "ReplayTrace.goal.1"
        )
        let moved = EntityRevisionTombstone(
            id: "goal-1-revision-2",
            entityKind: .goal,
            entityID: "goal-1",
            revisionMarker: "rev-2",
            reason: .replaced,
            recordedAt: "2026-05-12T11:00:00Z",
            lineageID: initial.lineageID,
            ancestryLineageIDs: [initial.lineageID],
            lifecycleState: .finalized,
            privacyClass: .sharedReceipt,
            sourceRecordID: "SourceRecord.goal.2",
            receiptID: "Receipt.goal.2",
            replayTraceID: "ReplayTrace.goal.2"
        )

        XCTAssertEqual(initial.lineageID, moved.lineageID)
        XCTAssertEqual(moved.exportSafeLineageView.ancestryLineageIDs, [initial.lineageID])
        XCTAssertTrue(moved.exportSafeLineageView.isFinalized)
        XCTAssertEqual(moved.exportSafeLineageView.receiptID, "Receipt.goal.2")
        XCTAssertEqual(moved.exportSafeLineageView.sourceRecordID, nil)
    }

    func testPrivateTombstoneExportsRedactedLineageView() {
        let tombstone = EntityRevisionTombstone(
            entityKind: .goal,
            entityID: "goal-private",
            revisionMarker: "rev-1",
            reason: .deleted,
            recordedAt: "2026-05-12T12:00:00Z",
            privacyClass: .privateProof,
            sourceRecordID: "SourceRecord.goal.private",
            receiptID: "Receipt.goal.private",
            replayTraceID: "ReplayTrace.goal.private"
        )

        let view = tombstone.exportSafeLineageView

        XCTAssertTrue(tombstone.isRecoverable)
        XCTAssertEqual(view.entityID, nil)
        XCTAssertEqual(view.sourceRecordID, nil)
        XCTAssertEqual(view.receiptID, nil)
        XCTAssertEqual(view.replayTraceID, nil)
        XCTAssertEqual(view.redactionSummary, "Private lineage details are redacted for export.")

        let exportedTombstone = tombstone.exportSafeTombstone

        XCTAssertEqual(exportedTombstone.sourceRecordID, nil)
        XCTAssertEqual(exportedTombstone.receiptID, nil)
        XCTAssertEqual(exportedTombstone.replayTraceID, nil)
        XCTAssertEqual(exportedTombstone.lineageID, tombstone.lineageID)
    }
}
