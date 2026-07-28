import XCTest
import SwiftData
@testable import Ambitions

final class ExecutionLedgerReplayInspectionRepositoryTests: XCTestCase {
    func testSwiftDataRepositoryBuildsReplayInspectionFromCommandReceiptAndSnapshot() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let receiptRepository = SwiftDataActionReceiptHistoryRepository(store: store)
        let snapshotRepository = SwiftDataRuntimeSnapshotLedgerRepository(store: store)
        let commandRepository = SwiftDataAmbitionsCommandExecutionRecordRepository(store: store)
        let inspectionRepository = SwiftDataExecutionLedgerReplayInspectionRepository(store: store)

        let receiptRecord = Self.receiptRecord(
            id: "receipt-command-1",
            title: "Completed recommended step",
            occurredAt: "2026-06-14T08:00:00Z"
        )
        let proofEntry = ActionReceiptProofLedgerEntry(
            receipt: receiptRecord.receipt,
            privacyLevel: receiptRecord.privacyLevel,
            localOnly: receiptRecord.localOnly,
            proofRelevance: receiptRecord.proofRelevance
        )
        let snapshot = RuntimeSnapshotLedgerEnvelope(
            generatedAt: "2026-06-14T08:05:00Z",
            sourceRecordIDs: ["source-record-1"],
            receiptIDs: [receiptRecord.id],
            replayTraceIDs: ["replay-trace-1"],
            recommendationInputReferenceIDs: ["recommendation-input-1"],
            proofInputReferenceIDs: proofEntry.proofReferenceIDs,
            afep02LineageReferenceIDs: ["afep-lineage-1"]
        )
        let command = AmbitionsCommand(
            id: "command-replay-1",
            kind: .completeAction,
            source: .today,
            target: AmbitionsCommandTarget(stepID: "step-1"),
            createdAt: "2026-06-14T07:59:00Z"
        )
        let commandRecord = AmbitionsCommandExecutionRecord(
            command: command,
            result: AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Completed recommended step",
                target: command.target,
                metadata: ["receiptID": receiptRecord.id]
            ),
            recordedAt: "2026-06-14T08:01:00Z"
        )

        try await receiptRepository.save([receiptRecord])
        try await snapshotRepository.append(snapshot)
        try await commandRepository.append(commandRecord)

        let projection = try await inspectionRepository.fetch(
            ExecutionLedgerReplayInspectionQuery(commandID: command.id, limit: 10)
        )

        XCTAssertTrue(projection.localOnly)
        XCTAssertEqual(projection.totalCandidateCount, 1)
        XCTAssertEqual(projection.items.count, 1)
        let item = try XCTUnwrap(projection.items.first)
        XCTAssertEqual(item.commandExecutionRecord?.commandID, command.id)
        XCTAssertEqual(item.receiptRecord.id, receiptRecord.id)
        XCTAssertEqual(item.runtimeSnapshotEnvelope?.id, snapshot.id)
        XCTAssertEqual(item.sourceRecordIDs, ["receipt-command-1", "source-record-1"])
        XCTAssertEqual(item.replayTraceIDs, ["replay-trace-1"])
        XCTAssertEqual(item.replayOutcome.idempotencyKey.rawValue, command.id)
        XCTAssertEqual(item.replayOutcome.decision, .replayExistingReceipt)
        XCTAssertEqual(item.replayOutcome.doubleApplyDisposition, .skipDuplicateMutation)
        XCTAssertEqual(item.deterministicReplayValidationState, .deterministic)
        XCTAssertEqual(item.runtimeSnapshotValidationReport?.outcome, .valid)
        XCTAssertEqual(item.commandSummary, "Command ID: command-replay-1")
    }

    func testSwiftDataRepositoryUsesReceiptFallbackAndBoundedResultLimit() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let receiptRepository = SwiftDataActionReceiptHistoryRepository(store: store)
        let snapshotRepository = SwiftDataRuntimeSnapshotLedgerRepository(store: store)
        let inspectionRepository = SwiftDataExecutionLedgerReplayInspectionRepository(store: store)

        let older = Self.receiptRecord(
            id: "receipt-older",
            title: "Older replay receipt",
            occurredAt: "2026-06-14T07:00:00Z"
        )
        let newer = Self.receiptRecord(
            id: "receipt-newer",
            title: "Newer replay receipt",
            occurredAt: "2026-06-14T09:00:00Z"
        )

        try await receiptRepository.save([older, newer])
        try await snapshotRepository.append(Self.snapshot(for: older, generatedAt: "2026-06-14T07:05:00Z"))
        try await snapshotRepository.append(Self.snapshot(for: newer, generatedAt: "2026-06-14T09:05:00Z"))

        let projection = try await inspectionRepository.fetch(
            ExecutionLedgerReplayInspectionQuery(limit: 1)
        )

        XCTAssertEqual(projection.totalCandidateCount, 2)
        XCTAssertEqual(projection.items.map(\.receiptRecord.id), ["receipt-newer"])
        XCTAssertEqual(projection.items.first?.commandExecutionRecord, nil)
        XCTAssertEqual(projection.items.first?.replayOutcome.decision, .lookupUnavailable)
        XCTAssertEqual(projection.items.first?.deterministicReplayValidationState, .reviewRequired)
        XCTAssertEqual(projection.items.first?.reviewLabel, "Review in owning flow")
        XCTAssertEqual(projection.items.first?.validationLabel, "Replay review required")
    }

    func testSwiftDataRepositoryCanInspectReceiptWithoutSnapshotWhenReceiptIDIsExplicit() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let receiptRepository = SwiftDataActionReceiptHistoryRepository(store: store)
        let inspectionRepository = SwiftDataExecutionLedgerReplayInspectionRepository(store: store)
        let receiptRecord = Self.receiptRecord(
            id: "receipt-direct",
            title: "Direct receipt lookup",
            occurredAt: "2026-06-14T10:00:00Z"
        )

        try await receiptRepository.save([receiptRecord])

        let projection = try await inspectionRepository.fetch(
            ExecutionLedgerReplayInspectionQuery(receiptID: receiptRecord.id, limit: 10)
        )

        XCTAssertEqual(projection.totalCandidateCount, 1)
        XCTAssertEqual(projection.items.first?.receiptRecord.id, receiptRecord.id)
        XCTAssertNil(projection.items.first?.runtimeSnapshotEnvelope)
        XCTAssertEqual(projection.items.first?.deterministicReplayValidationState, .unavailable)
        XCTAssertEqual(projection.items.first?.sourceRecordIDs, [receiptRecord.id])
        XCTAssertEqual(projection.items.first?.commandSummary, "Command record not attached")
    }

    func testQuarantinedCommandBytesAreInspectedAndCannotBeOverwritten() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repository = SwiftDataAmbitionsCommandExecutionRecordRepository(store: store)
        let inspection = SwiftDataExecutionLedgerReplayInspectionRepository(store: store)
        let command = AmbitionsCommand(
            id: "command-quarantined",
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "Original"),
            createdAt: "2026-07-24T12:00:00Z"
        )
        let originalRecord = AmbitionsCommandExecutionRecord(
            command: command,
            result: AmbitionsCommandExecutionResult(status: .succeeded, summary: "Original"),
            recordedAt: "2026-07-24T12:00:01Z"
        )
        try await repository.append(originalRecord)
        let futureBytes = Data("{\"schemaVersion\":99,\"payload\":{}}".utf8)
        try await store.write { context in
            let persisted = try XCTUnwrap(try context.fetch(FetchDescriptor<CommandExecutionRecord>()).first)
            persisted.commandData = futureBytes
        }

        do {
            try await repository.append(AmbitionsCommandExecutionRecord(
                command: command,
                result: AmbitionsCommandExecutionResult(status: .failed, summary: "Replacement"),
                recordedAt: "2026-07-24T12:00:02Z"
            ))
            XCTFail("Quarantined bytes must not be overwritten")
        } catch {
            // Expected fail-closed append.
        }

        let stored = try XCTUnwrap(try await repository.fetchRecord(commandID: command.id))
        guard case let .quarantined(quarantine) = stored else {
            return XCTFail("Expected typed quarantine")
        }
        XCTAssertEqual(quarantine.commandBytes, futureBytes)
        let projection = try await inspection.fetch(ExecutionLedgerReplayInspectionQuery(commandID: command.id, limit: 10))
        XCTAssertEqual(projection.quarantinedCommandRecords.map(\.commandBytes), [futureBytes])
        XCTAssertEqual(projection.totalCandidateCount, 1)
        XCTAssertFalse(projection.isEmpty)
    }
}

private extension ExecutionLedgerReplayInspectionRepositoryTests {
    static func receiptRecord(
        id: String,
        title: String,
        occurredAt: String
    ) -> ActionReceiptHistoryRecord {
        let step = LifeGraphObjectReference(
            kind: .step,
            id: "step-\(id)",
            label: "Recommended step",
            sourceDomain: .today
        )
        let receipt = ActionReceipt(
            id: id,
            resultState: .completed,
            title: title,
            summary: "\(title) with local proof.",
            sourceDomain: .today,
            occurredAt: occurredAt,
            affectedObjects: [step],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact-\(id)",
                    kind: .completedAction,
                    object: step,
                    fieldName: "stepState",
                    newValueSummary: "completed",
                    summary: "The step completed locally."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal
        )
        return ActionReceiptHistoryRecord(
            receipt: receipt,
            privacyLevel: .safeToShow,
            localOnly: true,
            proofRelevance: .countsAsProof
        )
    }

    static func snapshot(
        for receiptRecord: ActionReceiptHistoryRecord,
        generatedAt: String
    ) -> RuntimeSnapshotLedgerEnvelope {
        let proofEntry = ActionReceiptProofLedgerEntry(
            receipt: receiptRecord.receipt,
            privacyLevel: receiptRecord.privacyLevel,
            localOnly: receiptRecord.localOnly,
            proofRelevance: receiptRecord.proofRelevance
        )
        return RuntimeSnapshotLedgerEnvelope(
            generatedAt: generatedAt,
            sourceRecordIDs: ["source-\(receiptRecord.id)"],
            receiptIDs: [receiptRecord.id],
            replayTraceIDs: ["trace-\(receiptRecord.id)"],
            recommendationInputReferenceIDs: ["recommendation-\(receiptRecord.id)"],
            proofInputReferenceIDs: proofEntry.proofReferenceIDs,
            afep02LineageReferenceIDs: ["lineage-\(receiptRecord.id)"]
        )
    }
}
