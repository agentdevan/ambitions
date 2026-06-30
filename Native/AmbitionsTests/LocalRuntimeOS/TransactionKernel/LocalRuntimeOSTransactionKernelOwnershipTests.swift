@testable import Ambitions
import XCTest

final class LocalRuntimeOSTransactionKernelOwnershipTests: XCTestCase {
    func testTransactionKernelLeavesBelongToCanonicalOwnerAndOldOwnerIsGone() {
        let root = repoRoot()
        let canonicalPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeTransaction.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeTransactionCoordinator.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeMutationPlan.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeWriteSet.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeReadSet.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeCommitReceipt.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeRollbackPlan.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeConflictDetector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeIdempotencyStore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeMutation.swift",
        ]
        let retiredPath = "Native/Ambitions/Core/Runtime/RuntimeMutation.swift"

        for canonicalPath in canonicalPaths {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(canonicalPath).path),
                "Missing canonical TransactionKernel owner: \(canonicalPath)"
            )
        }
        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent(retiredPath).path),
            "Retired transaction owner still exists: \(retiredPath)"
        )
    }

    func testRuntimeMutationRepresentsVisibleStageMutationAnnouncementAndProof() {
        let runtime = PrivateLifeRuntime()
        let command = AmbitionsCommand(
            id: "command-start-step",
            kind: .startStepSession,
            source: .today,
            target: AmbitionsCommandTarget(goalID: "goal-1", stepID: "step-1"),
            payload: AmbitionsCommandPayload(title: "Open step"),
            createdAt: "2026-04-25T12:00:00Z"
        )

        let mutation = runtime.mutation(
            for: command,
            beforeSnapshot: "today.before",
            afterSnapshot: "today.after",
            targetSurface: .today
        )

        XCTAssertNotNil(mutation)
        XCTAssertTrue(mutation?.hasCompleteActionFlowProof == true)
        XCTAssertEqual(mutation?.stageMutation.affectedObjectIDs, ["goal-1", "step-1"])
        XCTAssertEqual(mutation?.stageMutation.motionEvent, "stage.motion.start_focus")
        XCTAssertEqual(mutation?.stageMutation.accessibilityAnnouncement.message, "Step started. Proof is available.")
        XCTAssertEqual(mutation?.userVisibleMutation.headline, "Step started")
    }

    func testCoordinatorPreparesValidatedTransactionReadSetWriteSetAndRollbackPlan() async throws {
        let coordinator = RuntimeTransactionCoordinator(eventStore: InMemoryRuntimeEventStore())
        let command = stepCommand(id: "command-prepare")
        let occurredAt = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-25T12:00:00Z"))

        let transaction = try await coordinator.prepare(
            command: command,
            beforeSnapshot: "today.before",
            afterSnapshot: "today.after",
            targetSurface: .today,
            occurredAt: occurredAt
        )

        XCTAssertTrue(transaction.isCommittable)
        XCTAssertEqual(transaction.id, "runtime.transaction.command-prepare")
        XCTAssertEqual(transaction.idempotencyKey.rawValue, "command-prepare")
        XCTAssertEqual(transaction.readSet.targetObjectIDs, ["goal-1", "step-1"])
        XCTAssertEqual(transaction.readSet.objectFamilies, [.goalThread, .step])
        XCTAssertTrue(transaction.readSet.isComplete)
        XCTAssertEqual(transaction.writeSet.affectedObjectIDs, ["goal-1", "step-1"])
        XCTAssertTrue(transaction.writeSet.projectionIDs.contains(.today))
        XCTAssertTrue(transaction.writeSet.projectionIDs.contains(.goals))
        XCTAssertTrue(transaction.writeSet.projectionIDs.contains(.receipt))
        XCTAssertTrue(transaction.writeSet.isComplete)
        XCTAssertTrue(transaction.rollbackPlan.isExecutable)
        XCTAssertEqual(transaction.rollbackPlan.restoresSnapshotSummary, "today.before")
        XCTAssertEqual(transaction.mutationPlan.checksum.isEmpty, false)
    }

    func testCommitAppendsRuntimeEventMaterializesProjectionsAndReturnsReplayableReceipt() async throws {
        let eventStore = InMemoryRuntimeEventStore()
        let coordinator = RuntimeTransactionCoordinator(eventStore: eventStore)
        let command = stepCommand(id: "command-commit")
        let occurredAt = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-25T12:00:00Z"))

        let outcome = try await coordinator.commit(
            command: command,
            beforeSnapshot: "today.before",
            afterSnapshot: "today.after",
            targetSurface: .today,
            occurredAt: occurredAt
        )

        let events = try await eventStore.fetchEvents(matching: .all, limit: nil)
        XCTAssertEqual(outcome.disposition, .committed)
        XCTAssertTrue(outcome.appendedNewEvent)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.event.commandID, "command-commit")
        XCTAssertEqual(outcome.receipt.transactionID, "runtime.transaction.command-commit")
        XCTAssertEqual(outcome.receipt.eventID, "runtime.event.1")
        XCTAssertTrue(outcome.receipt.hasReplayableProof)
        XCTAssertEqual(outcome.receipt.rollbackPlanID, "runtime.rollback.command-commit")
        XCTAssertTrue(outcome.receipt.projectionCursors.map(\.projectionID).contains(.receipt))
        XCTAssertEqual(outcome.replayOutcome.decision, .applyFresh)
        XCTAssertEqual(outcome.replayOutcome.doubleApplyDisposition, .applyOnce)
    }

    func testDuplicateCommitReturnsPriorReceiptWithoutAppendingSecondEvent() async throws {
        let eventStore = InMemoryRuntimeEventStore()
        let idempotencyStore = RuntimeIdempotencyStore()
        let coordinator = RuntimeTransactionCoordinator(
            eventStore: eventStore,
            idempotencyStore: idempotencyStore
        )
        let command = stepCommand(id: "command-duplicate")
        let occurredAt = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-25T12:00:00Z"))

        let first = try await coordinator.commit(
            command: command,
            beforeSnapshot: "today.before",
            afterSnapshot: "today.after",
            targetSurface: .today,
            occurredAt: occurredAt
        )
        let second = try await coordinator.commit(
            command: command,
            beforeSnapshot: "today.before",
            afterSnapshot: "today.after",
            targetSurface: .today,
            occurredAt: occurredAt
        )

        let events = try await eventStore.fetchEvents(matching: .all, limit: nil)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(second.disposition, .replayedExistingReceipt)
        XCTAssertFalse(second.appendedNewEvent)
        XCTAssertEqual(second.receipt, first.receipt)
        XCTAssertEqual(second.replayOutcome.decision, .replayExistingReceipt)
        XCTAssertEqual(second.replayOutcome.doubleApplyDisposition, .skipDuplicateMutation)
    }

    func testConflictDetectorBlocksStaleReadSetObjectOverlap() async throws {
        let eventStore = InMemoryRuntimeEventStore()
        let coordinator = RuntimeTransactionCoordinator(eventStore: eventStore)
        let firstCommand = stepCommand(id: "command-first-conflict")
        let secondCommand = stepCommand(id: "command-second-conflict")
        let occurredAt = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-25T12:00:00Z"))
        let staleTransaction = try await coordinator.prepare(
            command: secondCommand,
            beforeSnapshot: "today.before",
            afterSnapshot: "today.after",
            targetSurface: .today,
            occurredAt: occurredAt
        )
        let committed = try await coordinator.commit(
            command: firstCommand,
            beforeSnapshot: "today.before",
            afterSnapshot: "today.after",
            targetSurface: .today,
            occurredAt: occurredAt
        )

        let report = RuntimeConflictDetector().detect(
            transaction: staleTransaction,
            committedReceipts: [committed.receipt]
        )

        XCTAssertTrue(report.hasBlockingConflict)
        XCTAssertEqual(report.conflicts.map(\.kind), [.staleReadSetObjectOverlap])
        XCTAssertEqual(report.conflicts.first?.objectIDs, ["goal-1", "step-1"])
        XCTAssertEqual(report.checkedReceiptIDs, [committed.receipt.id])
    }

    func testInvalidCommandCannotProduceTransaction() async throws {
        let coordinator = RuntimeTransactionCoordinator(eventStore: InMemoryRuntimeEventStore())
        let command = AmbitionsCommand(
            id: "command-invalid",
            kind: .startStepSession,
            source: .today,
            target: AmbitionsCommandTarget(goalID: "goal-1"),
            payload: AmbitionsCommandPayload(title: "Open step"),
            createdAt: "2026-04-25T12:00:00Z"
        )

        do {
            _ = try await coordinator.prepare(
                command: command,
                beforeSnapshot: "today.before",
                afterSnapshot: "today.after",
                targetSurface: .today
            )
            XCTFail("Invalid command produced a transaction")
        } catch RuntimeTransactionError.blockedByValidation(let commandID, let reasons) {
            XCTAssertEqual(commandID, "command-invalid")
            XCTAssertEqual(reasons, [AmbitionsCommandValidationState.needsMissingTarget.rawValue])
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }

    private func stepCommand(id: String) -> AmbitionsCommand {
        AmbitionsCommand(
            id: id,
            kind: .startStepSession,
            source: .today,
            target: AmbitionsCommandTarget(goalID: "goal-1", stepID: "step-1"),
            payload: AmbitionsCommandPayload(title: "Open step"),
            createdAt: "2026-04-25T12:00:00Z"
        )
    }
}
