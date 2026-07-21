import XCTest
@testable import Ambitions

final class MutationReplayIdentityTests: RuntimeCommandMutationCommitterTestCase {
    func testIncompatibleSameIDReplayRetainsOriginalCommandAndSkipsRecovery() async throws {
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let commandID = "command.materialization.replay-identity-conflict"
        let originalCommand = quickCaptureCommand(id: commandID, now: now)
        let retryCommand = incompatibleRetryCommand(id: commandID, now: now)
        let runtimeEvents = InMemoryRuntimeEventStore()
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

        let first = await committer.commit(
            command: originalCommand,
            context: CommandExecutionContext(now: now),
            plannedResult: captureResult(
                summary: "Original capture committed.",
                captureID: "capture-replay-identity-conflict"
            ),
            materialization: materialization
        )
        let fetchedOriginalRecord = try await commandRecords.fetchRecord(commandID: commandID)
        let originalRecord = try XCTUnwrap(fetchedOriginalRecord)
        let firstAuthorityEvents = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)

        let replay = await committer.commit(
            command: retryCommand,
            context: CommandExecutionContext(now: now.addingTimeInterval(60)),
            plannedResult: captureResult(
                summary: "Replacement must not commit.",
                captureID: "capture-replay-identity-replacement"
            ),
            materialization: materialization
        )
        let fetchedRetainedRecord = try await commandRecords.fetchRecord(commandID: commandID)
        let retainedRecord = try XCTUnwrap(fetchedRetainedRecord)
        let events = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)
        let probeSnapshot = await materializationProbe.snapshot

        XCTAssertEqual(first.metadata["captureMaterialization"], "needs_recovery")
        XCTAssertEqual(replay.status, .blocked)
        XCTAssertEqual(replay.metadata["blockedBy"], "runtime_command_identity_conflict")
        XCTAssertEqual(replay.metadata["doubleApplyDisposition"], "skip_unverified_mutation")
        XCTAssertEqual(probeSnapshot.attemptCount, 1)
        XCTAssertEqual(events.map(\.id), firstAuthorityEvents.map(\.id))
        XCTAssertEqual(retainedRecord, originalRecord)
        XCTAssertEqual(retainedRecord.command, originalCommand)
        XCTAssertNotEqual(retainedRecord.command.payload, retryCommand.payload)
        XCTAssertNotEqual(retainedRecord.command.createdAt, retryCommand.createdAt)
    }

    private func incompatibleRetryCommand(id: String, now: Date) -> AmbitionsCommand {
        AmbitionsCommand(
            id: id,
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "Replace the original payload"),
            createdAt: DomainTimestamp.string(from: now.addingTimeInterval(60)),
            actor: .user,
            sourceSurface: "today",
            privacy: .privateUserText
        )
    }
}
