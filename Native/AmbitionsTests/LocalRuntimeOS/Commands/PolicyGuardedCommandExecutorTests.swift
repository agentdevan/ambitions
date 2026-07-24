import XCTest
@testable import Ambitions

final class PolicyGuardedCommandExecutorTests: XCTestCase {
    func testExternalSurfaceMutationIsPreparedWithoutPreAuthorityLedgerArtifact() async throws {
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
        XCTAssertEqual(result.metadata["sideEffectLedgerStatus"], "deferred_until_authority_acceptance")
        let executionCount = await counter.value()
        XCTAssertEqual(executionCount, 0)

        let records = try await ledger.fetchRecent(limit: 10)
        XCTAssertTrue(records.isEmpty)
    }

    func testLocalReversibleMutationDelegatesWithoutPreAuthorityLedgerArtifact() async throws {
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
        let executionCount = await counter.value()
        XCTAssertEqual(executionCount, 1)

        let records = try await ledger.fetchRecent(limit: 10)
        XCTAssertTrue(records.isEmpty)
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

        XCTAssertEqual(prepareResult.status, .noOp)
        XCTAssertEqual(performResult.status, .requiresConfirmation)
        XCTAssertEqual(deleteResult.status, .blocked)
        XCTAssertEqual(forgetResult.status, .blocked)
        let executionCount = await counter.value()
        XCTAssertEqual(executionCount, 0)
        XCTAssertTrue(records.isEmpty)
    }

    func testAutomaticProtectedPlacementInsideSevenDaysIsNotDelegated() async throws {
        let now = Date(timeIntervalSince1970: 1_780_000_000)
        let counter = ExecutionCounter()
        let base = RecordingCommandExecutor(counter: counter)
        let executor = PolicyGuardedCommandExecutor(base: base)
        let command = AmbitionsCommand(
            id: "command-auto-protected-step",
            kind: .placeStepInTime,
            source: .system,
            target: AmbitionsCommandTarget(stepID: "step-protected"),
            payload: AmbitionsCommandPayload(
                metadata: [
                    "originalStartAt": iso(now.addingTimeInterval(24 * 60 * 60)),
                    "originalEndAt": iso(now.addingTimeInterval(25 * 60 * 60)),
                    "startAt": iso(now.addingTimeInterval(2 * 24 * 60 * 60)),
                    "endAt": iso(now.addingTimeInterval((2 * 24 + 1) * 60 * 60)),
                    "protectedPlacementAutomationPolicy": ProtectedStepPlacementAutomationPolicy.allowedByExistingPolicy.rawValue
                ]
            ),
            createdAt: iso(now),
            actor: .system
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: now, actor: .system)
        )

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(result.metadata["guardedBy"], "protected_step_placement_policy")
        XCTAssertEqual(result.metadata["protectedPlacementDecision"], ProtectedStepPlacementDecisionKind.blockedFromSilentMovement.rawValue)
        XCTAssertEqual(result.metadata["canApplySilently"], "false")
        let executionCount = await counter.value()
        XCTAssertEqual(executionCount, 0)
    }

    func testMoveItProtectedPlacementWithUserActionPassesProtectedPlacementGuard() async throws {
        let now = Date(timeIntervalSince1970: 1_780_000_000)
        let counter = ExecutionCounter()
        let base = RecordingCommandExecutor(counter: counter)
        let executor = PolicyGuardedCommandExecutor(base: base)
        let command = AmbitionsCommand(
            id: "command-move-it-protected-step",
            kind: .recoverAction,
            source: .today,
            target: AmbitionsCommandTarget(stepID: "step-recovery"),
            payload: AmbitionsCommandPayload(
                metadata: [
                    "missedRecoveryMoveIt": "true",
                    "originalStartAt": iso(now.addingTimeInterval(-24 * 60 * 60)),
                    "originalEndAt": iso(now.addingTimeInterval(-23 * 60 * 60)),
                    "startAt": iso(now.addingTimeInterval(24 * 60 * 60)),
                    "endAt": iso(now.addingTimeInterval(25 * 60 * 60))
                ]
            ),
            createdAt: iso(now),
            actor: .user
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: now)
        )

        XCTAssertNotEqual(result.metadata["guardedBy"], "protected_step_placement_policy")
        XCTAssertNotEqual(result.metadata["protectedPlacementDecision"], ProtectedStepPlacementDecisionKind.blockedFromSilentMovement.rawValue)
        let executionCount = await counter.value()
        XCTAssertEqual(executionCount, 0, "Recover action remains confirmation-gated by existing side-effect policy, but not by protected placement.")
    }
}

private func iso(_ date: Date) -> String {
    DomainTimestamp.string(from: date)
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
