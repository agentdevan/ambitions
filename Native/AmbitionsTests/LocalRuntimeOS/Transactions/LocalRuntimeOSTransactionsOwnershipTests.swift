@testable import Ambitions
import XCTest

final class LocalRuntimeOSTransactionsOwnershipTests: XCTestCase {
    func testTransactionsLeavesBelongToCanonicalOwnerAndOldOwnerIsGone() {
        let root = repoRoot()
        let canonicalPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeTransaction.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeTransactionCoordinator.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeMutationPlan.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeWriteSet.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeReadSet.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeCommitReceipt.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeRollbackPlan.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeConflictDetector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeIdempotencyStore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeMutationContext.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeMutation.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeTransactionFailureReceipt.swift",
        ]
        let retiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeTransaction.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeTransactionCoordinator.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeMutationPlan.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeWriteSet.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeReadSet.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeCommitReceipt.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeRollbackPlan.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeConflictDetector.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeIdempotencyStore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeMutationContext.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeMutation.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/TransactionKernel/RuntimeTransactionFailureReceipt.swift",
            "Native/AmbitionsTests/LocalRuntimeOS/TransactionKernel/LocalRuntimeOSTransactionKernelOwnershipTests.swift",
            removedRuntimeOwnerPath("RuntimeMutation.swift"),
        ]

        for canonicalPath in canonicalPaths {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(canonicalPath).path),
                "Missing canonical Transactions owner: \(canonicalPath)"
            )
        }
        for retiredPath in retiredPaths {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(retiredPath).path),
                "Retired transaction owner still exists: \(retiredPath)"
            )
        }
    }

    func testRuntimeMutationContextCreationIsCoordinatorOwnedInProductionSource() throws {
        let root = repoRoot().resolvingSymlinksInPath()
        let contextPath = "Native/Ambitions/Core/LocalRuntimeOS/Transactions/RuntimeMutationContext.swift"
        let contextURL = root.appendingPathComponent(contextPath)
        let contextSource = try String(contentsOf: contextURL, encoding: .utf8)

        XCTAssertTrue(contextSource.contains("fileprivate init("))
        XCTAssertTrue(contextSource.contains("extension RuntimeTransactionCoordinator"))
        XCTAssertTrue(contextSource.contains("func issueMutationContext("))
        XCTAssertTrue(contextSource.contains("let projectionPlan: [ProjectionID]"))
        XCTAssertTrue(contextSource.contains("projectionPlan.contains(projectionID)"))

        let productionRoot = root.appendingPathComponent("Native/Ambitions")
        let enumerator = FileManager.default.enumerator(at: productionRoot, includingPropertiesForKeys: nil)
        while let fileURL = enumerator?.nextObject() as? URL {
            guard fileURL.pathExtension == "swift" else { continue }
            let canonicalFileURL = fileURL.resolvingSymlinksInPath()
            let relativePath = canonicalFileURL.path.replacingOccurrences(of: root.path + "/", with: "")
            guard canonicalFileURL.path != contextURL.path else { continue }
            let source = try String(contentsOf: canonicalFileURL, encoding: .utf8)
            XCTAssertFalse(source.contains("RuntimeMutationContext("), relativePath)
        }
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
        XCTAssertEqual(Set(outcome.receipt.projectionCursors.map(\.projectionID)), Set(ProjectionID.allCases))
        XCTAssertEqual(outcome.receipt.projectionCursors.count, ProjectionID.allCases.count)
        XCTAssertTrue(outcome.receipt.projectionCursors.allSatisfy { $0.eventCursor == events.first?.cursor })
        XCTAssertTrue(outcome.receipt.projectionCursors.map(\.projectionID).contains(.receipt))
        let context = try coordinator.issueMutationContext(family: .step, projectionID: .today, from: outcome)
        XCTAssertEqual(context.commandID, command.id)
        XCTAssertEqual(context.transactionID, outcome.receipt.transactionID)
        XCTAssertEqual(context.eventID, outcome.receipt.eventID)
        XCTAssertEqual(context.receiptID, outcome.receipt.receiptID)
        XCTAssertEqual(context.rollbackPlanID, outcome.receipt.rollbackPlanID)
        XCTAssertEqual(Set(context.projectionPlan), Set(outcome.receipt.projectionCursors.map(\.projectionID)))
        XCTAssertThrowsError(try coordinator.issueMutationContext(family: .appState, projectionID: .today, from: outcome)) { error in
            guard case RuntimeMutationContextIssuanceError.commitScopeMissingFamily(let family, _) = error else {
                return XCTFail("Unexpected error: \(error)")
            }
            XCTAssertEqual(family, .appState)
        }
        XCTAssertEqual(outcome.replayOutcome.decision, .applyFresh)
        XCTAssertEqual(outcome.replayOutcome.doubleApplyDisposition, .applyOnce)
    }

    func testCommitPersistsProjectionStoreAndRebuildsSearchIndexWhenConfigured() async throws {
        let directory = try scratchDirectory()
        let eventStore = InMemoryRuntimeEventStore()
        let projectionStore = ProjectionStoreSQLite(databaseURL: directory.appendingPathComponent("projections.sqlite"))
        let searchIndex = FTSIndex(store: SearchStoreFTS(databaseURL: directory.appendingPathComponent("search.sqlite")))
        let coordinator = RuntimeTransactionCoordinator(
            eventStore: eventStore,
            projectionStore: projectionStore,
            searchIndex: searchIndex
        )
        let command = stepCommand(id: "command-commit-projections")
        let occurredAt = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-25T12:05:00Z"))

        let outcome = try await coordinator.commit(
            command: command,
            beforeSnapshot: "today.before",
            afterSnapshot: "Open step projected into surface read stores.",
            targetSurface: .today,
            occurredAt: occurredAt
        )

        let storedRecords = try await projectionStore.fetchAllRecords()
        let searchResults = try await searchIndex.search(
            SearchQuery(rawText: "", limit: 10),
            searchedAt: "2026-04-25T12:06:00Z"
        )

        XCTAssertEqual(outcome.projectionStoreReceipt?.storedProjectionIDs, ProjectionID.allCases.sorted())
        XCTAssertEqual(outcome.searchRebuildReceipt?.projectionID, .search)
        XCTAssertEqual(outcome.searchRebuildReceipt?.cursor, outcome.receipt.projectionCursors.first { $0.projectionID == .search })
        XCTAssertEqual(storedRecords.map(\.id).sorted(), ProjectionID.allCases.sorted())
        guard let todayRecord = try await projectionStore.fetchRecord(id: .today) else {
            return XCTFail("Expected persisted Today projection.")
        }
        XCTAssertEqual(todayRecord.cursor.eventCursor, outcome.receipt.eventCursor)
        XCTAssertTrue(searchResults.contains { $0.provenance.eventID == outcome.receipt.eventID })
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
        XCTAssertThrowsError(try coordinator.issueMutationContext(family: .step, projectionID: .today, from: second)) { error in
            guard case RuntimeMutationContextIssuanceError.replayedOutcomeCannotIssueContext(let commandID) = error else {
                return XCTFail("Unexpected error: \(error)")
            }
            XCTAssertEqual(commandID, command.id)
        }
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
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/Transactions")
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

    private func scratchDirectory() throws -> URL {
        let directory = URL(fileURLWithPath: "/tmp", isDirectory: true)
            .appendingPathComponent("ambitions-transaction-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }
        return directory
    }
}
