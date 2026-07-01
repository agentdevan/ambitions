import Foundation

enum RuntimeTransactionCommitDisposition: String, Sendable, Codable, Equatable, Hashable, CaseIterable {
    case committed
    case replayedExistingReceipt = "replayed_existing_receipt"
}

struct RuntimeTransactionCommitOutcome: Sendable, Equatable {
    let disposition: RuntimeTransactionCommitDisposition
    let transaction: RuntimeTransaction?
    let receipt: RuntimeCommitReceipt
    let replayOutcome: LedgerReplayOutcome
    let projectionStoreReceipt: ProjectionStoreCommitReceipt?
    let searchRebuildReceipt: SearchRebuildIndexReceipt?

    var appendedNewEvent: Bool {
        disposition == .committed
    }

    static func committed(
        transaction: RuntimeTransaction,
        receipt: RuntimeCommitReceipt,
        projectionStoreReceipt: ProjectionStoreCommitReceipt?,
        searchRebuildReceipt: SearchRebuildIndexReceipt?
    ) -> RuntimeTransactionCommitOutcome {
        RuntimeTransactionCommitOutcome(
            disposition: .committed,
            transaction: transaction.marked(.committed),
            receipt: receipt,
            replayOutcome: LedgerReplayOutcome(
                idempotencyKey: receipt.idempotencyKey,
                decision: .applyFresh,
                doubleApplyDisposition: .applyOnce,
                receiptSummary: receipt.receiptID
            ),
            projectionStoreReceipt: projectionStoreReceipt,
            searchRebuildReceipt: searchRebuildReceipt
        )
    }

    static func replayed(receipt: RuntimeCommitReceipt) -> RuntimeTransactionCommitOutcome {
        RuntimeTransactionCommitOutcome(
            disposition: .replayedExistingReceipt,
            transaction: nil,
            receipt: receipt,
            replayOutcome: LedgerReplayOutcome(
                idempotencyKey: receipt.idempotencyKey,
                decision: .replayExistingReceipt,
                doubleApplyDisposition: .skipDuplicateMutation,
                receiptSummary: receipt.receiptID
            ),
            projectionStoreReceipt: nil,
            searchRebuildReceipt: nil
        )
    }
}

struct RuntimeTransactionCoordinator: Sendable {
    let eventStore: any RuntimeEventStore
    let idempotencyStore: RuntimeIdempotencyStore
    let validator: RuntimeValidator
    let conflictDetector: RuntimeConflictDetector
    let boundary: PrivateLifeRuntimeBoundary
    let projectionStore: ProjectionStoreSQLite?
    let searchIndex: FTSIndex?

    init(
        eventStore: any RuntimeEventStore = InMemoryRuntimeEventStore(),
        idempotencyStore: RuntimeIdempotencyStore = RuntimeIdempotencyStore(),
        validator: RuntimeValidator = RuntimeValidator(),
        conflictDetector: RuntimeConflictDetector = RuntimeConflictDetector(),
        boundary: PrivateLifeRuntimeBoundary = .localOnly,
        projectionStore: ProjectionStoreSQLite? = nil,
        searchIndex: FTSIndex? = nil
    ) {
        self.eventStore = eventStore
        self.idempotencyStore = idempotencyStore
        self.validator = validator
        self.conflictDetector = conflictDetector
        self.boundary = boundary
        self.projectionStore = projectionStore
        self.searchIndex = searchIndex
    }

    func prepare(
        command: AmbitionsCommand,
        beforeSnapshot: String,
        afterSnapshot: String,
        targetSurface: StageMutationTargetSurface,
        timeMutation: TimeMutation? = nil,
        projectionCursors: [ProjectionID: ProjectionCursor] = [:],
        executionResult: AmbitionsCommandExecutionResult? = nil,
        commandRecordID: String? = nil,
        occurredAt: Date = .now
    ) async throws -> RuntimeTransaction {
        let latestCursor = try await eventStore.latestCursor()
        let timestamp = DomainTimestamp.string(from: occurredAt)
        let validation = validator.validate(command, boundary: boundary)
        let plan = try RuntimeMutationPlan(
            command: command,
            validation: validation,
            latestEventCursor: latestCursor,
            projectionCursors: projectionCursors,
            beforeSnapshot: beforeSnapshot,
            afterSnapshot: afterSnapshot,
            targetSurface: targetSurface,
            timeMutation: timeMutation,
            executionResult: executionResult,
            commandRecordID: commandRecordID,
            plannedAt: timestamp
        )
        let transactionID = "runtime.transaction.\(command.id)"
        let rollbackPlan = RuntimeRollbackPlan(transactionID: transactionID, plan: plan)
        return try RuntimeTransaction(mutationPlan: plan, rollbackPlan: rollbackPlan)
    }

    func commit(
        command: AmbitionsCommand,
        beforeSnapshot: String,
        afterSnapshot: String,
        targetSurface: StageMutationTargetSurface,
        timeMutation: TimeMutation? = nil,
        projectionCursors: [ProjectionID: ProjectionCursor] = [:],
        executionResult: AmbitionsCommandExecutionResult? = nil,
        commandRecordID: String? = nil,
        occurredAt: Date = .now
    ) async throws -> RuntimeTransactionCommitOutcome {
        let key = LedgerIdempotencyKey(command.id)
        guard key.isWellFormed else {
            throw RuntimeTransactionError.idempotencyKeyMalformed(command.id)
        }
        if let existing = await idempotencyStore.receipt(for: key) {
            return .replayed(receipt: existing)
        }

        let transaction = try await prepare(
            command: command,
            beforeSnapshot: beforeSnapshot,
            afterSnapshot: afterSnapshot,
            targetSurface: targetSurface,
            timeMutation: timeMutation,
            projectionCursors: projectionCursors,
            executionResult: executionResult,
            commandRecordID: commandRecordID,
            occurredAt: occurredAt
        )
        let committedReceipts = await idempotencyStore.committedReceipts()
        let conflictReport = conflictDetector.detect(transaction: transaction, committedReceipts: committedReceipts)
        guard conflictReport.hasBlockingConflict == false else {
            throw RuntimeTransactionError.conflictDetected(conflictReport)
        }
        guard transaction.isCommittable else {
            throw RuntimeTransactionError.mutationProofIncomplete(commandID: command.id)
        }

        let committedAt = DomainTimestamp.string(from: occurredAt)
        let envelope = try await eventStore.append(transaction.writeSet.event)
        let materialized = try await ProjectionMaterializer(store: eventStore).materializeAll(
            previousCursors: projectionCursors,
            materializedAt: committedAt
        )
        let projectionStoreReceipt = try await projectionStore?.saveWithReceipt(batch: materialized, updatedAt: committedAt)
        let searchRebuildReceipt = try await searchIndex?.rebuild(from: materialized.search, updatedAt: committedAt)
        let receipt = RuntimeCommitReceipt(
            transaction: transaction,
            eventEnvelope: envelope,
            projectionCursors: materialized.cursors,
            committedAt: committedAt
        )
        _ = try await idempotencyStore.record(receipt, recordedAt: DomainTimestamp.string(from: occurredAt))
        return .committed(
            transaction: transaction,
            receipt: receipt,
            projectionStoreReceipt: projectionStoreReceipt,
            searchRebuildReceipt: searchRebuildReceipt
        )
    }
}
