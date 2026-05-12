import XCTest
@testable import Ambitions

final class PolicyGuardedCommandExecutorTests: XCTestCase {
    func testExternalSurfaceMutationIsRecordedAndNotDelegated() async throws {
        let counter = ExecutionCounter()
        let base = RecordingCommandExecutor(counter: counter)
        let ledger = InMemorySideEffectLedgerRepository()
        let executor = PolicyGuardedCommandExecutor(base: base, sideEffectLedger: ledger)
        let command = AmbitionsCommand(
            id: "command-widget-archive",
            kind: .archiveItem,
            source: .widget,
            target: AmbitionsCommandTarget(captureID: "capture-1"),
            createdAt: "2026-05-12T12:00:00Z",
            actor: .externalSurface,
            sourceSurface: "widget"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_778_000_000))
        )

        XCTAssertEqual(result.status, .requiresConfirmation)
        XCTAssertEqual(result.metadata["guardedBy"], "side_effect_policy")
        XCTAssertEqual(result.metadata["permissionLevel"], SafeAutomationPermissionLevel.requiresConfirmation.rawValue)
        XCTAssertEqual(await counter.value(), 0)

        let records = try await ledger.fetchRecent(limit: 10)
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records.first?.commandID, "command-widget-archive")
        XCTAssertEqual(records.first?.status, .confirmationRequired)
        XCTAssertEqual(records.first?.boundary, .externalEffect)
    }

    func testLocalReversibleMutationIsRecordedThenDelegated() async throws {
        let counter = ExecutionCounter()
        let base = RecordingCommandExecutor(counter: counter)
        let ledger = InMemorySideEffectLedgerRepository()
        let executor = PolicyGuardedCommandExecutor(base: base, sideEffectLedger: ledger)
        let command = AmbitionsCommand(
            id: "command-local-archive",
            kind: .archiveItem,
            source: .capture,
            target: AmbitionsCommandTarget(captureID: "capture-1"),
            createdAt: "2026-05-12T12:00:00Z"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_778_000_000))
        )

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(result.metadata["delegated"], "true")
        XCTAssertEqual(await counter.value(), 1)

        let records = try await ledger.fetchRecent(limit: 10)
        XCTAssertEqual(records.first?.status, .recordedLocalOnly)
        XCTAssertEqual(records.first?.boundary, .localOnly)
        XCTAssertEqual(records.first?.mayExecuteWithoutUserConfirmation, true)
    }

    func testDataControlCommandsNeverExecuteWithoutReviewAndDoNotMutateState() async throws {
        let counter = ExecutionCounter()
        let base = RecordingCommandExecutor(counter: counter)
        let ledger = InMemorySideEffectLedgerRepository()
        let executor = PolicyGuardedCommandExecutor(base: base, sideEffectLedger: ledger)

        let prepareExport = AmbitionsCommand(
            id: "command-prepare-export",
            kind: .prepareExport,
            source: .you,
            createdAt: "2026-05-12T12:00:00Z"
        )
        let performExport = AmbitionsCommand(
            id: "command-perform-export",
            kind: .performExport,
            source: .you,
            createdAt: "2026-05-12T12:00:00Z"
        )
        let deleteObject = AmbitionsCommand(
            id: "command-delete-object",
            kind: .deleteObject,
            source: .capture,
            target: AmbitionsCommandTarget(goalID: "goal-1"),
            createdAt: "2026-05-12T12:00:00Z"
        )
        let forgetMemory = AmbitionsCommand(
            id: "command-forget-memory",
            kind: .forgetMemory,
            source: .you,
            target: AmbitionsCommandTarget(reviewID: "memory-1"),
            createdAt: "2026-05-12T12:00:00Z"
        )

        let prepareResult = await executor.execute(
            prepareExport,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_778_000_000))
        )
        let performResult = await executor.execute(
            performExport,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_778_000_100))
        )
        let deleteResult = await executor.execute(
            deleteObject,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_778_000_200))
        )
        let forgetResult = await executor.execute(
            forgetMemory,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_778_000_300))
        )
        let records = try await ledger.fetchRecent(limit: 10)
        let prepareRecord = records.first(where: { $0.commandID == "command-prepare-export" })
        let performRecord = records.first(where: { $0.commandID == "command-perform-export" })
        let deleteRecord = records.first(where: { $0.commandID == "command-delete-object" })
        let forgetRecord = records.first(where: { $0.commandID == "command-forget-memory" })

        XCTAssertEqual(prepareResult.status, .noOp)
        XCTAssertEqual(performResult.status, .requiresConfirmation)
        XCTAssertEqual(deleteResult.status, .blocked)
        XCTAssertEqual(forgetResult.status, .blocked)
        XCTAssertEqual(await counter.value(), 0)
        XCTAssertEqual(records.count, 4)
        XCTAssertEqual(prepareRecord?.status, .preparedDraft)
        XCTAssertEqual(performRecord?.status, .confirmationRequired)
        XCTAssertEqual(deleteRecord?.status, .failedSafely)
        XCTAssertEqual(forgetRecord?.status, .failedSafely)
    }
}

private actor ExecutionCounter {
    private var count = 0

    func increment() {
        count += 1
    }

    func value() -> Int {
        count
    }
}

private struct RecordingCommandExecutor: CommandExecuting {
    let counter: ExecutionCounter

    func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        .valid
    }

    func execute(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        await counter.increment()
        return AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Delegated",
            target: command.target,
            metadata: ["delegated": "true"]
        )
    }
}
