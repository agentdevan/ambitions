import XCTest
@testable import Ambitions
class RuntimeCommandMutationCommitterTestCase: XCTestCase {
    func assertCommittedRuntimeEvidence(
        _ result: AmbitionsCommandExecutionResult,
        commandID: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(result.status, .succeeded, file: file, line: line)
        XCTAssertEqual(
            result.metadata["runtimeTransactionDisposition"],
            RuntimeTransactionCommitDisposition.committed.rawValue,
            file: file,
            line: line
        )
        XCTAssertEqual(
            result.metadata["runtimeTransactionID"],
            "runtime.transaction.\(commandID)",
            file: file,
            line: line
        )
        XCTAssertNotNil(result.metadata["runtimeEventID"], file: file, line: line)
        XCTAssertEqual(result.metadata["runtimeReceiptID"], "runtime.receipt.\(commandID)", file: file, line: line)
        XCTAssertEqual(
            result.metadata["runtimeRollbackPlanID"],
            "runtime.rollback.\(commandID)",
            file: file,
            line: line
        )
        XCTAssertEqual(result.metadata["runtimeReplayTraceID"], "runtime.replay.\(commandID)", file: file, line: line)
    }
    func quickCaptureCommand(id: String, now: Date) -> AmbitionsCommand {
        AmbitionsCommand(
            id: id,
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "Hold this locally"),
            createdAt: DomainTimestamp.string(from: now),
            actor: .user,
            sourceSurface: "today",
            privacy: .privateUserText
        )
    }
    func preferencesCommand(now: Date) -> AmbitionsCommand {
        AmbitionsCommand(
            id: "you.preferences.command.runtime-commit",
            kind: .updateUserPreferences,
            source: .you,
            target: AmbitionsCommandTarget(destination: .you),
            payload: AmbitionsCommandPayload(title: "Update You preferences"),
            createdAt: DomainTimestamp.string(from: now),
            actor: .user,
            sourceSurface: "you"
        )
    }
    func captureResult(summary: String, captureID: String) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: summary,
            route: .captureInbox,
            target: AmbitionsCommandTarget(captureID: captureID)
        )
    }
}
final class MutationCommitterAuthorityTests: RuntimeCommandMutationCommitterTestCase {
    func testRuntimeCommitterAddsFullCommitEvidenceForTodayClosureAndYouPreferences() async throws {
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let runtimeEvents = InMemoryRuntimeEventStore()
        let commandJournal = InMemoryCommandJournal()
        let commandRecords = InMemoryAmbitionsCommandExecutionRecordRepository()
        let committer = RuntimeCommandMutationCommitter(
            commandJournal: commandJournal,
            commandExecutionRecords: commandRecords,
            runtimeEvents: runtimeEvents
        )
        let closureCommand = AmbitionsCommand(
            id: "today.closure.command.runtime-commit",
            kind: .completeAction,
            source: .today,
            target: AmbitionsCommandTarget(goalID: "goal-runtime", stepID: "step-runtime", destination: .today),
            payload: AmbitionsCommandPayload(title: "Close step"),
            createdAt: DomainTimestamp.string(from: now),
            actor: .user,
            sourceSurface: "today"
        )
        let closureResult = await committer.commit(
            command: closureCommand,
            context: CommandExecutionContext(now: now, sourceSurface: "today"),
            plannedResult: AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Today closure receipt recorded.",
                route: .today,
                target: closureCommand.target,
                metadata: ["receiptID": "today.receipt.runtime-commit"]
            )
        )

        let preferencesCommand = preferencesCommand(now: now.addingTimeInterval(60))
        let preferencesResult = await committer.commit(
            command: preferencesCommand,
            context: CommandExecutionContext(now: now.addingTimeInterval(60), sourceSurface: "you"),
            plannedResult: AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "You preferences saved locally.",
                route: .you,
                target: preferencesCommand.target,
                metadata: ["preferredTab": "you"]
            )
        )

        let events = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)

        assertCommittedRuntimeEvidence(closureResult, commandID: closureCommand.id)
        assertCommittedRuntimeEvidence(preferencesResult, commandID: preferencesCommand.id)
        XCTAssertEqual(events.map(\.event.commandID), [closureCommand.id, preferencesCommand.id])
    }
    func testRuntimeCommitterSkipsMaterializationWhenAuthorityCommitFails() async throws {
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let command = quickCaptureCommand(id: "command.materialization.authority-failure", now: now)
        let materializationProbe = RuntimeCommandMaterializationProbe()
        let committer = RuntimeCommandMutationCommitter(
            commandJournal: InMemoryCommandJournal(),
            commandExecutionRecords: InMemoryAmbitionsCommandExecutionRecordRepository(),
            runtimeEvents: FailingMutationRuntimeEventStore()
        )

        let result = await committer.commit(
            command: command,
            context: CommandExecutionContext(now: now),
            plannedResult: AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Prepared local capture.",
                target: AmbitionsCommandTarget(captureID: "capture-authority-failure")
            ),
            materialization: RuntimeCommandMaterialization(statusMetadataKey: "captureMaterialization") { result in
                try await materializationProbe.apply(result: result)
            }
        )
        let probeSnapshot = await materializationProbe.snapshot

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(result.metadata["runtimeTransactionDisposition"], "not_committed")
        XCTAssertEqual(probeSnapshot.attemptCount, 0)
        XCTAssertEqual(probeSnapshot.state, "unchanged")
        XCTAssertNil(result.metadata["captureMaterialization"])
    }
    func testRuntimeCommitterPreservesCommittedSuccessWhenMaterializationFails() async throws {
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let command = quickCaptureCommand(id: "command.materialization.recoverable", now: now)
        let runtimeEvents = InMemoryRuntimeEventStore()
        let commandRecords = InMemoryAmbitionsCommandExecutionRecordRepository()
        let materializationProbe = RuntimeCommandMaterializationProbe(failuresRemaining: 1)
        let committer = RuntimeCommandMutationCommitter(
            commandJournal: InMemoryCommandJournal(),
            commandExecutionRecords: commandRecords,
            runtimeEvents: runtimeEvents
        )

        let result = await committer.commit(
            command: command,
            context: CommandExecutionContext(now: now),
            plannedResult: AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Capture committed.",
                target: AmbitionsCommandTarget(captureID: "capture-recoverable")
            ),
            materialization: RuntimeCommandMaterialization(statusMetadataKey: "captureMaterialization") { result in
                try await materializationProbe.apply(result: result)
            }
        )
        let events = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)
        let record = try await commandRecords.fetchRecord(commandID: command.id)
        let probeSnapshot = await materializationProbe.snapshot

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertTrue(RuntimeTransactionCommitPolicy.hasCommittedEvidence(result))
        XCTAssertEqual(result.metadata["captureMaterialization"], "needs_recovery")
        XCTAssertNotNil(result.metadata["captureMaterializationError"])
        XCTAssertEqual(probeSnapshot.attemptCount, 1)
        XCTAssertEqual(probeSnapshot.state, "unchanged")
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(record?.result, result)
    }

}

final class MutationCommitterReplayTests: RuntimeCommandMutationCommitterTestCase {
    func testRuntimeCommitterReplaysRuntimeEventBeforeMaterializedCommandRecord() async throws {
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let runtimeEvents = InMemoryRuntimeEventStore()
        let commandRecords = InMemoryAmbitionsCommandExecutionRecordRepository()
        let committer = RuntimeCommandMutationCommitter(
            commandJournal: InMemoryCommandJournal(),
            commandExecutionRecords: commandRecords,
            runtimeEvents: runtimeEvents
        )
        let command = quickCaptureCommand(id: "command.runtime-event-authority", now: now)
        let materializationProbe = RuntimeCommandMaterializationProbe()
        let materialization = RuntimeCommandMaterialization(statusMetadataKey: "captureMaterialization") { result in
            try await materializationProbe.apply(result: result)
        }

        let first = await committer.commit(
            command: command,
            context: CommandExecutionContext(now: now),
            plannedResult: captureResult(
                summary: "Saved once.",
                captureID: "capture-runtime-event-authority"
            ),
            materialization: materialization
        )
        let second = await committer.commit(
            command: command,
            context: CommandExecutionContext(now: now.addingTimeInterval(60)),
            plannedResult: captureResult(
                summary: "Should not run twice.",
                captureID: "capture-runtime-event-authority-duplicate"
            ),
            materialization: materialization
        )
        let events = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)
        let record = try await commandRecords.fetchRecord(commandID: command.id)
        let materializationExecutionCount = await materializationProbe.attemptCount

        XCTAssertEqual(first.status, .succeeded)
        XCTAssertEqual(second.status, .succeeded)
        XCTAssertTrue(RuntimeTransactionCommitPolicy.hasCommittedEvidence(second))
        XCTAssertEqual(second.summary, "Replayed runtime event receipt: Saved once.")
        XCTAssertEqual(materializationExecutionCount, 1)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(record?.result?.metadata["runtimeReplayDecision"], LedgerReplayDecision.applyFresh.rawValue)
        XCTAssertEqual(second.metadata["ledgerRecordKind"], LedgerRecordTaxonomyKind.event.rawValue)
        XCTAssertEqual(second.metadata["runtimeReplayAuthority"], "runtime_event_journal")
        XCTAssertEqual(second.metadata["runtimeReplaySource"], "runtime_event")
        XCTAssertEqual(second.metadata["runtimeReplayCommandRecordMaterialization"], "already_materialized")
        XCTAssertEqual(
            second.metadata["doubleApplyDisposition"],
            LedgerDoubleApplyDisposition.skipDuplicateMutation.rawValue
        )
    }

    func testRuntimeCommitterBlocksCommandRecordReplayWhenRuntimeEventIsMissing() async throws {
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let runtimeEvents = InMemoryRuntimeEventStore()
        let commandRecords = InMemoryAmbitionsCommandExecutionRecordRepository()
        let command = quickCaptureCommand(id: "command.command-record-without-event", now: now)
        try await commandRecords.append(
            AmbitionsCommandExecutionRecord(
                command: command,
                result: AmbitionsCommandExecutionResult(
                    status: .succeeded,
                    summary: "Receipt exists without event.",
                    target: AmbitionsCommandTarget(captureID: "capture-stale-record")
                ),
                recordedAt: DomainTimestamp.string(from: now)
            )
        )
        let committer = RuntimeCommandMutationCommitter(
            commandJournal: InMemoryCommandJournal(),
            commandExecutionRecords: commandRecords,
            runtimeEvents: runtimeEvents
        )
        let materializationProbe = RuntimeCommandMaterializationProbe()

        let result = await committer.commit(
            command: command,
            context: CommandExecutionContext(now: now.addingTimeInterval(60)),
            plannedResult: AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Should not execute.",
                target: AmbitionsCommandTarget(captureID: "capture-should-not-write")
            ),
            materialization: RuntimeCommandMaterialization(statusMetadataKey: "captureMaterialization") { result in
                try await materializationProbe.apply(result: result)
            }
        )
        let events = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)
        let materializationExecutionCount = await materializationProbe.attemptCount

        XCTAssertEqual(materializationExecutionCount, 0)
        XCTAssertTrue(events.isEmpty)
        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(result.metadata["blockedBy"], "runtime_event_missing_for_command_record")
        XCTAssertEqual(result.metadata["runtimeReplayAuthority"], "runtime_event_journal")
        XCTAssertEqual(result.metadata["runtimeReplaySource"], "command_record_repair_state")
        XCTAssertEqual(
            result.metadata["doubleApplyDisposition"],
            LedgerDoubleApplyDisposition.skipUnverifiedMutation.rawValue
        )
    }
    func testRuntimeCommitterReplayRetriesRecoverableMaterializationWithoutSecondEvent() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("RuntimeCommandMaterializationReplay-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock { try? FileManager.default.removeItem(at: directory) }
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let command = quickCaptureCommand(id: "command.materialization.replay-repair", now: now)
        let runtimeEvents = EventStoreSQLite(databaseURL: directory.appendingPathComponent("EventStore.sqlite"))
        let commandRecords = InMemoryAmbitionsCommandExecutionRecordRepository()
        let materializationProbe = RuntimeCommandMaterializationProbe(failuresRemaining: 1)
        let committer = RuntimeCommandMutationCommitter(
            commandJournal: InMemoryCommandJournal(),
            commandExecutionRecords: commandRecords,
            runtimeEvents: runtimeEvents
        )
        let materialization = RuntimeCommandMaterialization(statusMetadataKey: "captureMaterialization") { result in
            try await materializationProbe.apply(result: result)
        }
        let plannedResult = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Capture committed.",
            target: AmbitionsCommandTarget(captureID: "capture-replay-repair")
        )

        let first = await committer.commit(
            command: command,
            context: CommandExecutionContext(now: now),
            plannedResult: plannedResult,
            materialization: materialization
        )
        let firstAuthorityEvents = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)
        let replay = await committer.commit(
            command: command,
            context: CommandExecutionContext(now: now.addingTimeInterval(60)),
            plannedResult: plannedResult,
            materialization: materialization
        )
        let events = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)
        let repairedRecord = try await commandRecords.fetchRecord(commandID: command.id)
        let probeSnapshot = await materializationProbe.snapshot

        XCTAssertEqual(first.status, .succeeded)
        XCTAssertEqual(first.metadata["captureMaterialization"], "needs_recovery")
        XCTAssertEqual(replay.status, .succeeded)
        XCTAssertTrue(RuntimeTransactionCommitPolicy.hasCommittedEvidence(replay))
        XCTAssertEqual(replay.metadata["captureMaterialization"], "saved_post_authority")
        XCTAssertEqual(replay.metadata["materializationState"], "changed")
        XCTAssertNil(replay.metadata["captureMaterializationError"])
        XCTAssertEqual(probeSnapshot.attemptCount, 2)
        XCTAssertEqual(probeSnapshot.state, "changed")
        XCTAssertEqual(repairedRecord?.command, command)
        XCTAssertEqual(events.map(\.id), firstAuthorityEvents.map(\.id))
        XCTAssertEqual(repairedRecord?.result, replay)
    }

}

private enum RuntimeCommandMutationCommitterTestError: Error {
    case materializationUnavailable
    case runtimeEventAppendUnavailable
}

actor RuntimeCommandMaterializationProbe {
    private(set) var attemptCount = 0
    private(set) var state = "unchanged"
    private var failuresRemaining: Int

    init(failuresRemaining: Int = 0) {
        self.failuresRemaining = failuresRemaining
    }

    var snapshot: (attemptCount: Int, state: String) {
        (attemptCount, state)
    }

    func apply(result: AmbitionsCommandExecutionResult) throws -> [String: String] {
        attemptCount += 1
        if failuresRemaining > 0 {
            failuresRemaining -= 1
            throw RuntimeCommandMutationCommitterTestError.materializationUnavailable
        }
        state = "changed"
        return [
            "materializationState": state,
            "materializedResultStatus": result.status.rawValue
        ]
    }
}

private actor FailingMutationRuntimeEventStore: RuntimeEventStore {
    nonisolated var storeKind: RuntimeEventStoreKind { .inMemory }

    func append(_ event: RuntimeEvent) async throws -> RuntimeEventEnvelope {
        _ = event
        throw RuntimeCommandMutationCommitterTestError.runtimeEventAppendUnavailable
    }

    func fetchEvents(
        matching query: RuntimeEventQuery,
        limit: Int?
    ) async throws -> [RuntimeEventEnvelope] {
        _ = query
        _ = limit
        return []
    }

    func latestCursor() async throws -> RuntimeEventCursor? {
        nil
    }
}
