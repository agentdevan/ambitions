import XCTest
@testable import Ambitions

final class RuntimeAtomicCommitTests: XCTestCase {
    func testQuickCaptureAuthorityFailureLeavesNoCaptureMaterialization() async throws {
        let repository = PreviewCaptureRepository()
        let service = DefaultCaptureService(repository: repository, idProvider: { "capture.atomic.failure" })
        let executor = AmbitionsCommandExecutor.test(
            captureService: service,
            runtimeEvents: AtomicCommitFailingEventStore()
        )
        let command = AmbitionsCommand(
            id: "command.atomic.capture-failure",
            kind: .quickCapture,
            source: .capture,
            payload: AmbitionsCommandPayload(rawText: "Call Sam"),
            createdAt: "2026-07-10T12:00:00Z"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: try XCTUnwrap(DomainTimestamp.date(from: command.createdAt)))
        )

        XCTAssertEqual(result.status, AmbitionsCommandExecutionStatus.blocked)
        let captures = try await repository.listCaptures()
        XCTAssertTrue(captures.isEmpty)
    }

    func testConcurrentDuplicateCommandAndRestartReturnOneDurableReceipt() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("ambitions-atomic-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let databaseURL = directory.appendingPathComponent("EventStore.sqlite")
        let command = stepCommand(id: "command.atomic.duplicate")
        let occurredAt = try XCTUnwrap(DomainTimestamp.date(from: "2026-07-10T12:00:00Z"))
        let firstStore = EventStoreSQLite(databaseURL: databaseURL, deviceID: "atomic-test")

        let receipts = try await withThrowingTaskGroup(of: RuntimeCommitReceipt.self) { group in
            for _ in 0..<100 {
                group.addTask {
                    try await RuntimeTransactionCoordinator(eventStore: firstStore).commit(
                        command: command,
                        beforeSnapshot: "before",
                        afterSnapshot: "after",
                        targetSurface: .today,
                        occurredAt: occurredAt
                    ).receipt
                }
            }
            return try await group.reduce(into: []) { $0.append($1) }
        }

        XCTAssertEqual(Set(receipts).count, 1)
        let restartedStore = EventStoreSQLite(databaseURL: databaseURL, deviceID: "atomic-test-restarted")
        let replay = try await RuntimeTransactionCoordinator(eventStore: restartedStore).commit(
            command: command,
            beforeSnapshot: "before",
            afterSnapshot: "after",
            targetSurface: .today,
            occurredAt: occurredAt
        )
        XCTAssertEqual(replay.disposition, .replayedExistingReceipt)
        XCTAssertEqual(replay.receipt, receipts[0])
        let restartedEvents = try await restartedStore.fetchEvents(matching: .all, limit: nil)
        XCTAssertEqual(restartedEvents.count, 1)
    }

    func testProjectionFailureAfterAuthorityCommitDoesNotBlockReceipt() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("ambitions-projection-recovery-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let authority = EventStoreSQLite(databaseURL: directory.appendingPathComponent("EventStore.sqlite"))
        let invalidProjectionURL = directory.appendingPathComponent("ProjectionStore.sqlite", isDirectory: true)
        try FileManager.default.createDirectory(at: invalidProjectionURL, withIntermediateDirectories: true)
        let coordinator = RuntimeTransactionCoordinator(
            eventStore: authority,
            projectionStore: ProjectionStoreSQLite(databaseURL: invalidProjectionURL)
        )

        let outcome = try await coordinator.commit(
            command: stepCommand(id: "command.projection.catchup"),
            beforeSnapshot: "before",
            afterSnapshot: "after",
            targetSurface: .today
        )

        XCTAssertEqual(outcome.disposition, .committed)
        XCTAssertNil(outcome.projectionStoreReceipt)
        let persistedReceipt = try await authority.authorityReceipt(commandID: "command.projection.catchup")
        XCTAssertEqual(persistedReceipt, outcome.receipt)
    }

    func testAuthorityTransactionPersistsTypedNonEmptyOutboxProposal() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("ambitions-outbox-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = EventStoreSQLite(databaseURL: directory.appendingPathComponent("EventStore.sqlite"))
        let coordinator = RuntimeTransactionCoordinator(eventStore: store)
        let command = stepCommand(id: "command.outbox.atomic")
        let transaction = try await coordinator.prepare(
            command: command, beforeSnapshot: "before", afterSnapshot: "after", targetSurface: .today
        )
        let intent = RuntimeOutboxIntent(id: "outbox-1", kind: .widgetRefresh, payload: Data("{}".utf8))

        _ = try await store.commitAuthority(
            transaction: transaction,
            semanticEvent: nil,
            outboxIntents: [intent],
            committedAt: transaction.preparedAt
        )

        let storedIntents = try await store.outboxIntents(commandID: command.id)
        XCTAssertEqual(storedIntents, [intent])
    }

    func testCommittedCaptureMaterializationCatchesUpOnReplay() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("ambitions-capture-catchup-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let runtimeEvents = EventStoreSQLite(databaseURL: directory.appendingPathComponent("EventStore.sqlite"))
        let repository = FailFirstCaptureRepository()
        let service = DefaultCaptureService(repository: repository, idProvider: { "unused" })
        let command = AmbitionsCommand(
            id: "command.capture.catchup", kind: .quickCapture, source: .capture,
            payload: AmbitionsCommandPayload(rawText: "Call Sam"), createdAt: "2026-07-10T12:00:00Z"
        )
        let context = CommandExecutionContext(now: try XCTUnwrap(DomainTimestamp.date(from: command.createdAt)))

        let first = await AmbitionsCommandExecutor.test(captureService: service, runtimeEvents: runtimeEvents).execute(command, context: context)
        XCTAssertEqual(first.status, .succeeded)
        XCTAssertEqual(first.metadata["captureMaterialization"], "needs_recovery")
        let capturesAfterFailure = try await repository.listCaptures()
        XCTAssertTrue(capturesAfterFailure.isEmpty)

        let replay = await AmbitionsCommandExecutor.test(captureService: service, runtimeEvents: runtimeEvents).execute(command, context: context)
        let captures = try await repository.listCaptures()
        XCTAssertEqual(replay.status, .succeeded)
        XCTAssertEqual(replay.metadata["captureMaterialization"], "saved")
        XCTAssertEqual(captures.map(\.id), ["capture.command.capture.catchup"])
    }

    func testPublicExecutorRestartReplaysExactAuthorityReceiptAndOneSemanticTransition() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("executor-authority-replay-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let databaseURL = directory.appendingPathComponent("EventStore.sqlite")
        let repository = PreviewCaptureRepository()
        let records = InMemoryAmbitionsCommandExecutionRecordRepository()
        let command = AmbitionsCommand(
            id: "command.executor.authority", kind: .quickCapture, source: .capture,
            payload: AmbitionsCommandPayload(rawText: "Exact replay"), createdAt: "2026-07-10T12:00:00Z"
        )
        let context = CommandExecutionContext(now: try XCTUnwrap(DomainTimestamp.date(from: command.createdAt)))
        let firstStore = EventStoreSQLite(databaseURL: databaseURL)
        let first = await AmbitionsCommandExecutor.test(
            captureService: DefaultCaptureService(repository: repository),
            commandExecutionRecords: records, runtimeEvents: firstStore
        ).execute(command, context: context)
        let restartedStore = EventStoreSQLite(databaseURL: databaseURL)
        let replay = await AmbitionsCommandExecutor.test(
            captureService: DefaultCaptureService(repository: repository),
            commandExecutionRecords: records, runtimeEvents: restartedStore
        ).execute(command, context: context)

        for key in RuntimeTransactionCommitPolicy.requiredEvidenceKeys {
            XCTAssertEqual(replay.metadata[key], first.metadata[key], key)
        }
        XCTAssertEqual(replay.eventLedgerEntryIDs, first.eventLedgerEntryIDs)
        let semantic = try await restartedStore.fetchEvents(matching: .kind(.domainMutation), limit: nil)
        XCTAssertEqual(semantic.count, 1)
    }

    func testSQLiteDiagnosticCommandRowWithoutAuthorityReceiptBlocksWithoutMaterialization() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("orphan-diagnostic-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = EventStoreSQLite(databaseURL: directory.appendingPathComponent("EventStore.sqlite"))
        let captures = PreviewCaptureRepository()
        let ledger = InMemoryEventLedgerRepository()
        let command = AmbitionsCommand(
            id: "command.orphan.diagnostic", kind: .quickCapture, source: .capture,
            payload: AmbitionsCommandPayload(rawText: "Must not materialize"), createdAt: "2026-07-10T12:00:00Z"
        )
        let diagnosticResult = AmbitionsCommandExecutionResult(
            status: .succeeded, summary: "Diagnostic only", route: .captureInbox,
            target: AmbitionsCommandTarget(captureID: "capture.command.orphan.diagnostic")
        )
        _ = try await store.append(RuntimeEvent.commandExecution(
            command: command, result: diagnosticResult, recordedAt: command.createdAt,
            commandRecordID: "command.execution.\(command.id)"
        ))

        let result = await AmbitionsCommandExecutor.test(
            captureService: DefaultCaptureService(repository: captures), eventLedger: ledger,
            runtimeEvents: store
        ).execute(command, context: CommandExecutionContext(
            now: try XCTUnwrap(DomainTimestamp.date(from: command.createdAt))
        ))

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(result.metadata["blockedBy"], "sqlite_diagnostic_without_authority_receipt")
        XCTAssertEqual(result.metadata["runtimeReplayAuthority"], "sqlite_authority_receipt_required")
        let storedCaptures = try await captures.listCaptures()
        let storedLedgerEvents = try await ledger.fetchRecent(limit: 10)
        XCTAssertEqual(storedCaptures.count, 0)
        XCTAssertEqual(storedLedgerEvents.count, 0)
    }

    func testCreateTimeItemMissingSemanticTargetDoesNotMutateCapture() async throws {
        let seed = Capture(
            id: "capture-time", createdAt: "2026-07-10T12:00:00Z", updatedAt: "2026-07-10T12:00:00Z",
            rawText: "Place me", sourceType: .shellComposer, status: .needsTriage, linkedGoalID: nil
        )
        let repository = PreviewCaptureRepository(seedCaptures: [seed])
        let command = AmbitionsCommand(
            id: "command.time.no-semantic", kind: .createTimeItem, source: .time,
            target: AmbitionsCommandTarget(captureID: seed.id), payload: AmbitionsCommandPayload(title: "Place me"),
            createdAt: seed.createdAt
        )
        let before = try await repository.listCaptures()
        let result = await AmbitionsCommandExecutor.test(
            captureService: DefaultCaptureService(repository: repository)
        ).execute(command, context: CommandExecutionContext(now: try XCTUnwrap(DomainTimestamp.date(from: seed.createdAt))))

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(result.metadata["blockedBy"], "missing_semantic_time_target")
        let after = try await repository.listCaptures()
        XCTAssertEqual(after, before)
    }

    func testLedgerFailureAfterCaptureSaveRecoversOnceAndFinalizesCommandRecord() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("ledger-catchup-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = EventStoreSQLite(databaseURL: directory.appendingPathComponent("EventStore.sqlite"))
        let captures = PreviewCaptureRepository()
        let ledger = FailFirstEventLedgerRepository()
        let records = InMemoryAmbitionsCommandExecutionRecordRepository()
        let command = AmbitionsCommand(
            id: "command.ledger.catchup", kind: .quickCapture, source: .capture,
            payload: AmbitionsCommandPayload(rawText: "Recover ledger"), createdAt: "2026-07-10T12:00:00Z"
        )
        let context = CommandExecutionContext(now: try XCTUnwrap(DomainTimestamp.date(from: command.createdAt)))
        let executor = AmbitionsCommandExecutor.test(
            captureService: DefaultCaptureService(repository: captures), eventLedger: ledger,
            commandExecutionRecords: records, runtimeEvents: store
        )

        let first = await executor.execute(command, context: context)
        XCTAssertEqual(first.metadata["eventLedgerEmission"], "needs_recovery")
        let replay = await executor.execute(command, context: context)
        XCTAssertEqual(replay.metadata["eventLedgerEmission"], "saved_post_authority")
        XCTAssertEqual(replay.eventLedgerEntryIDs, ["ledger.command.command.ledger.catchup"])
        let ledgerEvents = try await ledger.fetchRecent(limit: 10)
        XCTAssertEqual(ledgerEvents.count, 1)
        let fetchedRecord = try await records.fetchRecord(commandID: command.id)
        let finalRecord = try XCTUnwrap(fetchedRecord)
        XCTAssertEqual(finalRecord.result.eventLedgerEntryIDs, replay.eventLedgerEntryIDs)
        XCTAssertEqual(finalRecord.result.metadata["eventLedgerEmission"], "saved_post_authority")
    }

    func testProductionTransitionProposalPersistsEmptyAndTypedNonemptyIntents() async throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("proposal-production-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = EventStoreSQLite(databaseURL: directory.appendingPathComponent("EventStore.sqlite"))
        let captureCommand = AmbitionsCommand(
            id: "command.proposal.capture", kind: .quickCapture, source: .capture,
            payload: AmbitionsCommandPayload(rawText: "Proposal"), createdAt: "2026-07-10T12:00:00Z"
        )
        let captureResult = AmbitionsCommandExecutionResult(
            status: .succeeded, summary: "Prepared", target: AmbitionsCommandTarget(captureID: "capture.command.proposal.capture"),
            metadata: ["captureID": "capture.command.proposal.capture", "captureRoute": CaptureRoute.captureInbox.rawValue, "captureKind": CaptureKind.raw.rawValue]
        )
        _ = try await RuntimeTransactionCoordinator(eventStore: store).commit(
            command: captureCommand.resolvedForRuntimeTransaction(result: captureResult), beforeSnapshot: "before", afterSnapshot: "after",
            targetSurface: .today, executionResult: captureResult
        )
        let captureIntents = try await store.outboxIntents(commandID: captureCommand.id)
        XCTAssertEqual(captureIntents, [])

        let timeCommand = AmbitionsCommand(
            id: "command.proposal.time", kind: .createTimeItem, source: .time,
            target: AmbitionsCommandTarget(timeID: "block-1", stepID: "step-1"),
            payload: AmbitionsCommandPayload(title: "Place"), createdAt: "2026-07-10T12:00:00Z"
        )
        let timeResult = AmbitionsCommandExecutionResult(status: .succeeded, summary: "Prepared", target: timeCommand.target)
        _ = try await RuntimeTransactionCoordinator(eventStore: store).commit(
            command: timeCommand, beforeSnapshot: "before", afterSnapshot: "after", targetSurface: .time,
            executionResult: timeResult
        )
        let intents = try await store.outboxIntents(commandID: timeCommand.id)
        XCTAssertEqual(intents.map(\.kind), [.widgetRefresh])
        XCTAssertEqual(intents.map(\.payloadSchemaVersion), [1])
    }

    private func stepCommand(id: String) -> AmbitionsCommand {
        AmbitionsCommand(
            id: id,
            kind: .startStepSession,
            source: .today,
            target: AmbitionsCommandTarget(goalID: "goal-1", stepID: "step-1"),
            payload: AmbitionsCommandPayload(title: "Open step"),
            createdAt: "2026-07-10T12:00:00Z"
        )
    }
}

private actor FailFirstCaptureRepository: CaptureRepository {
    private var shouldFail = true
    private var captures: [Capture] = []
    func listCaptures() async throws -> [Capture] { captures }
    func capture(id: String) async throws -> Capture? { captures.first { $0.id == id } }
    func saveCaptures(_ captures: [Capture]) async throws {
        if shouldFail {
            shouldFail = false
            throw Failure.injected
        }
        self.captures = captures
    }
    enum Failure: Error { case injected }
}

private actor AtomicCommitFailingEventStore: RuntimeEventStore {
    nonisolated let storeKind = RuntimeEventStoreKind.inMemory
    func append(_ event: RuntimeEvent) async throws -> RuntimeEventEnvelope { throw Failure.append }
    func fetchEvents(matching query: RuntimeEventQuery, limit: Int?) async throws -> [RuntimeEventEnvelope] { [] }
    func latestCursor() async throws -> RuntimeEventCursor? { nil }
    enum Failure: Error { case append }
}

private actor FailFirstEventLedgerRepository: EventLedgerRepository {
    private var shouldFail = true
    private var events: [EventLedgerEntry] = []
    func append(_ event: EventLedgerEntry) async throws {
        if shouldFail { shouldFail = false; throw Failure.injected }
        events.removeAll { $0.id == event.id }
        events.append(event)
    }
    func fetchRecent(limit: Int) async throws -> [EventLedgerEntry] { Array(events.prefix(limit)) }
    func fetchEvents(goalID: String) async throws -> [EventLedgerEntry] { events.filter { $0.goalID == goalID } }
    func fetchEvents(captureID: String) async throws -> [EventLedgerEntry] { events.filter { $0.captureID == captureID } }
    func fetchEvents(kind: EventLedgerKind) async throws -> [EventLedgerEntry] { events.filter { $0.kind == kind } }
    func fetchEvents(from start: String, through end: String) async throws -> [EventLedgerEntry] { events.filter { $0.occurredAt >= start && $0.occurredAt <= end } }
    func redactEvent(id: String, at timestamp: String) async throws {
        if let index = events.firstIndex(where: { $0.id == id }) { events[index] = events[index].redacted(at: timestamp) }
    }
    func deleteEvent(id: String) async throws { events.removeAll { $0.id == id } }
    enum Failure: Error { case injected }
}
