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
        let intent = RuntimeOutboxIntent(id: "outbox-1", kind: "widget_refresh", payload: Data("{}".utf8))

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
