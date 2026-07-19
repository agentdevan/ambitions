import XCTest
@testable import Ambitions

final class AFEP009ExecutionLedgerReplayBrowserTests: XCTestCase {
    func testExecutionLedgerReplayBrowserProjectionComposesReadOnlyProofSnapshotAndReplayState() {
        let stepReference = LifeGraphObjectReference(
            kind: .step,
            id: "step-1",
            label: "Recommended step",
            sourceDomain: .today
        )
        let receipt = ActionReceipt(
            id: "receipt-1",
            resultState: .completed,
            title: "Completed step",
            summary: "A step completed locally and saved a receipt.",
            sourceDomain: .today,
            occurredAt: "2026-06-01T08:00:00Z",
            affectedObjects: [stepReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "receipt-1.completed",
                    kind: .completedAction,
                    object: stepReference,
                    fieldName: "stepState",
                    newValueSummary: "completed",
                    summary: "The recommended step completed locally."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal
        )
        let record = ActionReceiptHistoryRecord(
            receipt: receipt,
            privacyLevel: .safeToShow,
            localOnly: true,
            proofRelevance: .countsAsProof
        )
        let proofEntry = ActionReceiptProofLedgerEntry(
            receipt: receipt,
            privacyLevel: .safeToShow,
            localOnly: true,
            visibilityLevels: [.toast, .peek, .trail, .search, .export],
            proofRelevance: .countsAsProof
        )
        let snapshot = RuntimeSnapshotLedgerEnvelope(
            generatedAt: "2026-06-01T08:05:00Z",
            sourceRecordIDs: ["source-record-1"],
            receiptIDs: ["receipt-1"],
            replayTraceIDs: ["trace-1"],
            recommendationInputReferenceIDs: ["recommendation-1"],
            proofInputReferenceIDs: proofEntry.proofReferenceIDs,
            afep02LineageReferenceIDs: ["lineage-1"]
        )
        let replayOutcome = LedgerReplayOutcome(
            idempotencyKey: LedgerIdempotencyKey("command-1"),
            decision: .replayExistingReceipt,
            doubleApplyDisposition: .skipDuplicateMutation,
            receiptSummary: receipt.summary
        )

        let projection = ExecutionLedgerReplayBrowserProjection(
            receiptRecord: record,
            proofLedgerEntry: proofEntry,
            runtimeSnapshotEnvelope: snapshot,
            replayOutcome: replayOutcome
        )

        XCTAssertEqual(projection.sourceRecordIDs, ["receipt-1", "source-record-1"])
        XCTAssertEqual(projection.receiptIDs, ["receipt-1"])
        XCTAssertEqual(projection.replayTraceIDs, ["trace-1"])
        XCTAssertEqual(projection.runtimeSnapshotChecksum, snapshot.checksum)
        XCTAssertEqual(projection.runtimeSnapshotProvenanceHash, snapshot.provenanceHash)
        XCTAssertEqual(projection.runtimeSnapshotValidationReport?.outcome, .valid)
        XCTAssertEqual(projection.runtimeSnapshotValidationReport?.reference.kind, .proofInput)
        XCTAssertEqual(projection.deterministicReplayValidationState, .deterministic)
        XCTAssertTrue(projection.isReadOnly)
        XCTAssertEqual(projection.reviewLabel, "Read-only replay browser")
        XCTAssertEqual(projection.proofImmutabilityLabel, "Proof stays immutable")
        XCTAssertEqual(projection.closureImmutabilityLabel, "Closure remains immutable")
        XCTAssertTrue(projection.summary.contains("Read-only replay browser"))
        XCTAssertTrue(projection.summary.contains("Replay validation: deterministic"))
        XCTAssertTrue(projection.summary.contains("Proof stays immutable"))
        XCTAssertTrue(projection.summary.contains("Closure remains immutable"))
        XCTAssertTrue(projection.summary.contains("Runtime snapshot checksum"), projection.summary)
    }

    func testYouTrustHistoryProjectorSurfacesTheExecutionLedgerAsReadOnlySummaryCopy() {
        let stepReference = LifeGraphObjectReference(
            kind: .step,
            id: "step-2",
            label: "Recommended step",
            sourceDomain: .today
        )
        let receipt = ActionReceipt(
            id: "receipt-2",
            resultState: .completed,
            title: "Completed step",
            summary: "A second receipt for the replay browser surface.",
            sourceDomain: .today,
            occurredAt: "2026-06-01T08:10:00Z",
            affectedObjects: [stepReference],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "receipt-2.completed",
                    kind: .completedAction,
                    object: stepReference,
                    fieldName: "stepState",
                    newValueSummary: "completed",
                    summary: "The second recommended step completed locally."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal
        )
        let proofEntry = ActionReceiptProofLedgerEntry(
            receipt: receipt,
            privacyLevel: .safeToShow,
            localOnly: true,
            visibilityLevels: [.toast, .peek, .trail, .search],
            proofRelevance: .countsAsProof
        )
        let snapshot = RuntimeSnapshotLedgerEnvelope(
            generatedAt: "2026-06-01T08:15:00Z",
            sourceRecordIDs: ["source-record-2"],
            receiptIDs: ["receipt-2"],
            replayTraceIDs: ["trace-2"],
            recommendationInputReferenceIDs: ["recommendation-2"],
            proofInputReferenceIDs: proofEntry.proofReferenceIDs,
            afep02LineageReferenceIDs: ["lineage-2"]
        )
        let browser = ExecutionLedgerReplayBrowserProjection(
            receiptRecord: ActionReceiptHistoryRecord(
                receipt: receipt,
                privacyLevel: .safeToShow,
                localOnly: true,
                proofRelevance: .countsAsProof
            ),
            proofLedgerEntry: proofEntry,
            runtimeSnapshotEnvelope: snapshot,
            replayOutcome: LedgerReplayOutcome(
                idempotencyKey: LedgerIdempotencyKey("command-2"),
                decision: .replayExistingReceipt,
                doubleApplyDisposition: .skipDuplicateMutation,
                receiptSummary: receipt.summary
            )
        )

        let state = YouTrustHistoryProjector().project(
            YouTrustHistoryProjector.Input(
                receipts: [receipt.displaySummary],
                recentEvents: [],
                proofCount: 1,
                sourceReviewCount: 0,
                automationReviewCount: 0,
                permissionSummary: "Notifications allowed; calendar allowed.",
                executionLedgerBrowser: browser
            )
        )

        let executionLedgerItem = state.items.first(where: { $0.id == "trust-history-execution-ledger-receipt-2" })
        XCTAssertNotNil(executionLedgerItem)
        XCTAssertEqual(executionLedgerItem?.category, .proof)
        XCTAssertEqual(executionLedgerItem?.title, "Execution ledger")
        XCTAssertEqual(executionLedgerItem?.reviewLabel, "Read-only replay browser")
        XCTAssertEqual(executionLedgerItem?.privacyLabel, "Local-only and inspectable")
        XCTAssertTrue(executionLedgerItem?.summary.contains("Execution ledger") == false)
        XCTAssertTrue(executionLedgerItem?.summary.contains("Read-only replay browser") == true)
        XCTAssertTrue(executionLedgerItem?.summary.contains("Replay validation: deterministic") == true)
        XCTAssertTrue(executionLedgerItem?.summary.contains("Runtime snapshot checksum") == true)
    }
}
