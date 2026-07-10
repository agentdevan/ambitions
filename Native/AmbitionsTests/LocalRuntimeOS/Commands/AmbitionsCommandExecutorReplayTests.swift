import XCTest
@testable import Ambitions

final class AmbitionsCommandExecutorReplayTests: XCTestCase {
    func testCommandRecordWithoutRuntimeEventBlocksReplayForRepair() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-replay" })
        let ledger = InMemoryEventLedgerRepository()
        let commandRecordRepository = InMemoryAmbitionsCommandExecutionRecordRepository()
        let executor = AmbitionsCommandExecutor.test(
            captureService: captureService,
            eventLedger: ledger,
            commandExecutionRecords: commandRecordRepository
        )
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let command = AmbitionsCommand(
            id: "command-replay",
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "Replay me once"),
            createdAt: DomainTimestamp.string(from: now)
        )
        let storedResult = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Saved to Needs a Place",
            route: .captureInbox,
            target: AmbitionsCommandTarget(captureID: "capture-replay", destination: .captureInbox),
            eventLedgerEntryIDs: ["ledger.command.command-replay"],
            recommendationExplanationIDs: ["explanation-replay"],
            metadata: ["captureID": "capture-replay"]
        )
        let storedRecord = AmbitionsCommandExecutionRecord(
            command: command,
            result: storedResult,
            recordedAt: "2026-04-25T12:01:00Z"
        )

        try await commandRecordRepository.append(storedRecord)

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: now.addingTimeInterval(60))
        )

        let captures = try await captureRepository.listCaptures()
        let events = try await ledger.fetchRecent(limit: 10)
        let fetchedReplayRecord = try await commandRecordRepository.fetchRecord(commandID: command.id)
        let replayedRecord = try XCTUnwrap(fetchedReplayRecord)

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(
            result.summary,
            "Command execution record exists without runtime event replay authority, so Ambitions paused replay for repair before mutation."
        )
        XCTAssertEqual(result.route, .captureInbox)
        XCTAssertEqual(result.target?.captureID, "capture-replay")
        XCTAssertTrue(result.eventLedgerEntryIDs.isEmpty)
        XCTAssertEqual(result.recommendationExplanationIDs, ["explanation-replay"])
        XCTAssertEqual(result.metadata["ledgerRecordKind"], LedgerRecordTaxonomyKind.receipt.rawValue)
        XCTAssertEqual(result.metadata["replayDecision"], LedgerReplayDecision.lookupUnavailable.rawValue)
        XCTAssertEqual(result.metadata["idempotencyKey"], command.id)
        XCTAssertEqual(result.metadata["doubleApplyDisposition"], LedgerDoubleApplyDisposition.skipUnverifiedMutation.rawValue)
        XCTAssertEqual(result.metadata["blockedBy"], "runtime_event_missing_for_command_record")
        XCTAssertEqual(result.metadata["runtimeReplayAuthority"], "runtime_event_journal")
        XCTAssertEqual(result.metadata["runtimeReplaySource"], "command_record_repair_state")
        XCTAssertEqual(captures.count, 0)
        XCTAssertTrue(events.isEmpty)
        XCTAssertEqual(replayedRecord.recordedAt, "2026-04-25T12:01:00Z")
    }

    func testRuntimeEventReplayIsAuthorityAndMaterializesMissingCommandRecord() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-should-not-double-write" })
        let ledger = InMemoryEventLedgerRepository()
        let commandRecordRepository = InMemoryAmbitionsCommandExecutionRecordRepository()
        let runtimeEvents = InMemoryRuntimeEventStore()
        let executor = AmbitionsCommandExecutor.test(
            captureService: captureService,
            eventLedger: ledger,
            commandExecutionRecords: commandRecordRepository,
            runtimeEvents: runtimeEvents
        )
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let command = AmbitionsCommand(
            id: "command-runtime-event-replay",
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "Replay from runtime event"),
            createdAt: DomainTimestamp.string(from: now)
        )
        let storedResult = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Saved to Needs a Place",
            route: .captureInbox,
            target: AmbitionsCommandTarget(captureID: "capture-runtime-event-replay", destination: .captureInbox),
            eventLedgerEntryIDs: ["ledger.command.command-runtime-event-replay"],
            recommendationExplanationIDs: ["explanation-runtime-event-replay"],
            metadata: ["captureID": "capture-runtime-event-replay"]
        )
        _ = try await runtimeEvents.append(
            RuntimeEvent.commandExecution(
                command: command,
                result: storedResult,
                recordedAt: "2026-04-25T12:01:00Z",
                commandRecordID: "command.execution.command-runtime-event-replay"
            )
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: now.addingTimeInterval(60))
        )

        let captures = try await captureRepository.listCaptures()
        let events = try await ledger.fetchRecent(limit: 10)
        let runtimeEventEnvelopes = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)
        let materializedRecord = try await commandRecordRepository.fetchRecord(commandID: command.id)
        let record = try XCTUnwrap(materializedRecord)

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(result.summary, "Replayed runtime event receipt: Saved to Needs a Place")
        XCTAssertEqual(result.route, .captureInbox)
        XCTAssertEqual(result.target?.captureID, "capture-runtime-event-replay")
        XCTAssertEqual(result.eventLedgerEntryIDs, ["ledger.command.command-runtime-event-replay"])
        XCTAssertEqual(result.recommendationExplanationIDs, ["explanation-runtime-event-replay"])
        XCTAssertEqual(result.metadata["ledgerRecordKind"], LedgerRecordTaxonomyKind.event.rawValue)
        XCTAssertEqual(result.metadata["replayDecision"], LedgerReplayDecision.replayExistingReceipt.rawValue)
        XCTAssertEqual(result.metadata["doubleApplyDisposition"], LedgerDoubleApplyDisposition.skipDuplicateMutation.rawValue)
        XCTAssertEqual(result.metadata["runtimeReplayAuthority"], "runtime_event_journal")
        XCTAssertEqual(result.metadata["runtimeReplaySource"], "runtime_event")
        XCTAssertEqual(result.metadata["runtimeReplayCommandRecordMaterialization"], "repaired_from_runtime_event")
        XCTAssertEqual(result.metadata["captureID"], "capture-runtime-event-replay")
        XCTAssertTrue(captures.isEmpty)
        XCTAssertTrue(events.isEmpty)
        XCTAssertEqual(runtimeEventEnvelopes.count, 1)
        XCTAssertEqual(record.result.metadata["ledgerRecordKind"], LedgerRecordTaxonomyKind.event.rawValue)
        XCTAssertEqual(record.recordedAt, "2026-04-25T12:01:00Z")
    }

    func testReplayLookupFailureBlocksMutationInsteadOfDoubleApplying() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-should-not-write" })
        let ledger = InMemoryEventLedgerRepository()
        let commandRecordRepository = ThrowingFetchCommandExecutionRecordRepository()
        let executor = AmbitionsCommandExecutor.test(
            captureService: captureService,
            eventLedger: ledger,
            commandExecutionRecords: commandRecordRepository
        )
        let command = AmbitionsCommand(
            id: "command-replay-fetch-failure",
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "Do not double apply"),
            createdAt: "2026-04-25T12:00:00Z"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: Date(timeIntervalSince1970: 1_777_113_600))
        )

        let captures = try await captureRepository.listCaptures()
        let events = try await ledger.fetchRecent(limit: 10)
        let appendedRecords = await commandRecordRepository.appendedRecordCount

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(
            result.summary,
            "Runtime event replay lookup could not be verified, so Ambitions skipped the mutation to avoid double apply."
        )
        XCTAssertEqual(result.metadata["replayDecision"], LedgerReplayDecision.lookupUnavailable.rawValue)
        XCTAssertEqual(result.metadata["idempotencyKey"], "command-replay-fetch-failure")
        XCTAssertEqual(result.metadata["doubleApplyDisposition"], LedgerDoubleApplyDisposition.skipUnverifiedMutation.rawValue)
        XCTAssertEqual(result.metadata["blockedBy"], "runtime_event_replay_lookup_unavailable")
        XCTAssertEqual(result.metadata["runtimeReplayAuthority"], "runtime_event_journal")
        XCTAssertTrue(captures.isEmpty)
        XCTAssertTrue(events.isEmpty)
        XCTAssertEqual(appendedRecords, 0)
    }

    func testQuickCapturePersistsExecutionRecordWhenEmissionDisabled() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-no-ledger" })
        let ledger = InMemoryEventLedgerRepository()
        let commandRecordRepository = InMemoryAmbitionsCommandExecutionRecordRepository()
        let executor = AmbitionsCommandExecutor.test(
            captureService: captureService,
            eventLedger: ledger,
            commandExecutionRecords: commandRecordRepository
        )
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let command = AmbitionsCommand(
            id: "command-record-no-ledger",
            kind: .quickCapture,
            source: .widget,
            payload: AmbitionsCommandPayload(rawText: "No ledger capture"),
            createdAt: "2026-04-25T12:00:00Z",
            actor: .externalSurface,
            sourceSurface: "widget"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(now: now, allowsEventLedgerEmission: false)
        )

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertTrue(result.eventLedgerEntryIDs.isEmpty)

        let records = try await commandRecordRepository.fetchRecent(limit: 10)
        let record = try XCTUnwrap(records.first)
        XCTAssertEqual(record.result.summary, "Saved to Needs a Place")
        XCTAssertEqual(record.result.eventLedgerEntryIDs, [])
        XCTAssertEqual(record.command.actor, .externalSurface)
    }

    func testQuickCaptureCanExecuteWithoutLedgerEmission() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-no-ledger" })
        let ledger = InMemoryEventLedgerRepository()
        let executor = AmbitionsCommandExecutor.test(captureService: captureService, eventLedger: ledger)
        let command = AmbitionsCommand(
            id: "command-no-ledger",
            kind: .quickCapture,
            source: .capture,
            payload: AmbitionsCommandPayload(rawText: "Raw idea"),
            createdAt: "2026-04-25T12:00:00Z"
        )

        let result = await executor.execute(
            command,
            context: CommandExecutionContext(
                now: Date(timeIntervalSince1970: 1_777_113_600),
                allowsEventLedgerEmission: false
            )
        )

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertTrue(result.eventLedgerEntryIDs.isEmpty)
        let captures = try await captureRepository.listCaptures()
        let events = try await ledger.fetchRecent(limit: 10)
        XCTAssertEqual(captures.count, 1)
        XCTAssertTrue(events.isEmpty)
    }

}

private enum CommandExecutionRecordTestError: Error {
    case fetchUnavailable
}

private actor ThrowingFetchCommandExecutionRecordRepository: AmbitionsCommandExecutionRecordRepository {
    private var appendedRecords: [AmbitionsCommandExecutionRecord] = []

    var appendedRecordCount: Int {
        appendedRecords.count
    }

    func append(_ record: AmbitionsCommandExecutionRecord) async throws {
        appendedRecords.append(record)
    }

    func fetchRecent(limit: Int) async throws -> [AmbitionsCommandExecutionRecord] {
        Array(appendedRecords.prefix(max(0, limit)))
    }

    func fetchRecord(commandID: String) async throws -> AmbitionsCommandExecutionRecord? {
        throw CommandExecutionRecordTestError.fetchUnavailable
    }
}
