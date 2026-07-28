@testable import Ambitions
import XCTest

final class RuntimeEventJournalTests: XCTestCase {
    func testEventJournalOwnerFilesExistUnderCanonicalTree() throws {
        let root = try repoRoot()
        let requiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEvent.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEventEnvelope.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEventStore.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEventCursor.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEventCompactor.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEventReplay.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeEventChecksum.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeCausalClock.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/EventJournal/RuntimeTombstoneLedger.swift",
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
    }

    func testFileStoreAppendsReloadsAndMaintainsChecksumChain() async throws {
        let fileURL = try temporaryJournalURL()
        let store = FileRuntimeEventStore(fileURL: fileURL, deviceID: "event-journal-test-device")

        let first = try await store.append(makeCorrectionEvent(id: "correction-1", occurredAt: "2026-06-30T05:00:00Z"))
        let second = try await store.append(makeProofEvent(id: "proof-1", occurredAt: "2026-06-30T05:01:00Z"))

        XCTAssertEqual(first.sequence, 1)
        XCTAssertEqual(second.sequence, 2)
        XCTAssertNil(first.previousChecksum)
        XCTAssertEqual(second.previousChecksum, first.checksum)
        XCTAssertTrue(RuntimeEventChecksum.isValid(first))
        XCTAssertTrue(RuntimeEventChecksum.isValid(second))

        let reloadedStore = FileRuntimeEventStore(fileURL: fileURL, deviceID: "event-journal-test-device")
        let reloaded = try await reloadedStore.fetchEvents(matching: .all, limit: nil)
        let latestCursor = try await reloadedStore.latestCursor()
        let eventsAfterFirst = try await reloadedStore.fetchEvents(matching: .after(first.cursor), limit: nil)
        XCTAssertEqual(reloaded.map(\.id), [first.id, second.id])
        XCTAssertEqual(latestCursor, second.cursor)
        XCTAssertEqual(eventsAfterFirst.map(\.id), [second.id])
    }

    func testChecksumDetectsEnvelopeTampering() async throws {
        let store = InMemoryRuntimeEventStore()
        let envelope = try await store.append(makeCorrectionEvent(id: "correction-original", occurredAt: "2026-06-30T05:00:00Z"))
        let tampered = RuntimeEventEnvelope(
            id: envelope.id,
            sequence: envelope.sequence,
            previousChecksum: envelope.previousChecksum,
            causalClock: envelope.causalClock,
            event: makeCorrectionEvent(id: "correction-tampered", occurredAt: "2026-06-30T05:00:00Z"),
            checksum: envelope.checksum,
            schemaVersion: envelope.schemaVersion
        )

        XCTAssertTrue(RuntimeEventChecksum.isValid(envelope))
        XCTAssertFalse(RuntimeEventChecksum.isValid(tampered))
    }

    func testReplayProjectsLatestCommandExecutionEvent() async throws {
        let store = InMemoryRuntimeEventStore()
        let command = makeQuickCaptureCommand(id: "command-runtime-replay", text: "Replay from runtime event")
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Saved to Needs a Place",
            route: .captureInbox,
            target: AmbitionsCommandTarget(captureID: "capture-runtime-replay", destination: .captureInbox),
            eventLedgerEntryIDs: ["ledger.command.command-runtime-replay"],
            metadata: ["captureID": "capture-runtime-replay"]
        )

        let envelope = try await store.append(
            RuntimeEvent.commandExecution(
                command: command,
                result: result,
                recordedAt: "2026-06-30T05:00:00Z",
                commandRecordID: "command.execution.command-runtime-replay"
            )
        )
        let projection = try await RuntimeEventReplay(store: store).replay(commandID: command.id)
        let replay = try XCTUnwrap(projection)

        XCTAssertEqual(replay.commandID, command.id)
        XCTAssertEqual(replay.eventCursor, envelope.cursor)
        XCTAssertEqual(replay.resultStatus, .succeeded)
        XCTAssertEqual(replay.resultSummary, "Saved to Needs a Place")
        XCTAssertEqual(replay.target.captureID, "capture-runtime-replay")
        XCTAssertEqual(replay.replayOutcome.decision, .replayExistingReceipt)
        XCTAssertEqual(replay.replayOutcome.doubleApplyDisposition, .skipDuplicateMutation)
        XCTAssertEqual(replay.metadata["runtimeEventID"], envelope.id)
        XCTAssertEqual(replay.metadata["captureID"], "capture-runtime-replay")
    }

    func testTombstoneLedgerAndCompactorProduceConcreteJournalEvents() async throws {
        let store = InMemoryRuntimeEventStore()
        let tombstoneLedger = RuntimeTombstoneLedger(store: store)
        let tombstoneEnvelope = try await tombstoneLedger.append(
            RuntimeTombstoneEventPayload(
                tombstoneID: "tombstone.capture.1",
                objectFamily: .capture,
                objectID: "capture-1",
                lineageID: "lineage-capture-1",
                reason: "Superseded by capture promotion",
                supersededByObjectID: "step-1"
            ),
            commandID: "command-tombstone",
            actor: .user,
            source: .today,
            privacy: .privateUserText,
            occurredAt: "2026-06-30T05:00:00Z"
        )

        let snapshot = try await RuntimeEventCompactor(store: store).makeSnapshot(createdAt: "2026-06-30T05:02:00Z")

        XCTAssertEqual(tombstoneEnvelope.event.kind, .tombstoneRecorded)
        XCTAssertEqual(snapshot.cursor, tombstoneEnvelope.cursor)
        XCTAssertEqual(snapshot.eventCount, 1)
        XCTAssertEqual(snapshot.tombstoneEventCount, 1)
        XCTAssertEqual(snapshot.eventCountByKind[.tombstoneRecorded], 1)
        XCTAssertEqual(snapshot.checksumHead, tombstoneEnvelope.checksum)
    }

    func testCommandExecutorAppendsRuntimeEventOnceAndReplayDoesNotDuplicateEvent() async throws {
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-runtime-journal" })
        let commandRecords = InMemoryAmbitionsCommandExecutionRecordRepository()
        let runtimeEvents = InMemoryRuntimeEventStore()
        let commandJournal = InMemoryCommandJournal()
        let executor = AmbitionsCommandExecutor.test(
            captureService: captureService,
            eventLedger: InMemoryEventLedgerRepository(),
            commandExecutionRecords: commandRecords,
            runtimeEvents: runtimeEvents,
            commandJournal: commandJournal
        )
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let command = makeQuickCaptureCommand(id: "command-runtime-journal", text: "Capture once")

        let first = await executor.execute(command, context: CommandExecutionContext(now: now))
        let replay = await executor.execute(command, context: CommandExecutionContext(now: now.addingTimeInterval(60)))

        let captures = try await captureRepository.listCaptures()
        let events = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)
        let event = try XCTUnwrap(events.first)
        let commandJournalEntries = try await commandJournal.fetchEntries(matching: .commandID(command.id), limit: nil)
        let commandJournalEntry = try XCTUnwrap(commandJournalEntries.first)
        let runtimeLink = try XCTUnwrap(commandJournalEntry.runtimeLink)
        let fetchedCommandRecord = try await commandRecords.fetchRecord(commandID: command.id)
        let commandRecord = try XCTUnwrap(fetchedCommandRecord)

        XCTAssertEqual(first.status, .succeeded)
        XCTAssertEqual(replay.metadata["replayDecision"], LedgerReplayDecision.replayExistingReceipt.rawValue)
        XCTAssertEqual(captures.count, 1)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(event.event.commandID, command.id)
        XCTAssertEqual(event.event.actor, .user)
        XCTAssertEqual(event.event.source, .today)
        XCTAssertEqual(event.event.privacy, .standard)
        XCTAssertEqual(event.event.metadata["resultStatus"], AmbitionsCommandExecutionStatus.succeeded.rawValue)
        XCTAssertEqual(commandRecord.result?.metadata["runtimeTransactionDisposition"], RuntimeTransactionCommitDisposition.committed.rawValue)
        XCTAssertEqual(commandRecord.result?.metadata["runtimeTransactionID"], "runtime.transaction.command-runtime-journal")
        XCTAssertEqual(commandRecord.result?.metadata["runtimeEventID"], "runtime.event.1")
        XCTAssertEqual(commandRecord.result?.metadata["runtimeReceiptID"], "runtime.receipt.command-runtime-journal")
        XCTAssertEqual(commandRecord.result?.metadata["runtimeRollbackPlanID"], "runtime.rollback.command-runtime-journal")
        XCTAssertEqual(commandRecord.result?.metadata["runtimeReplayDecision"], LedgerReplayDecision.applyFresh.rawValue)
        XCTAssertEqual(commandRecord.result?.metadata["runtimeDoubleApplyDisposition"], LedgerDoubleApplyDisposition.applyOnce.rawValue)
        XCTAssertEqual(commandRecord.result?.metadata["commandJournalRuntimeLinkStatus"], "linked")
        XCTAssertEqual(commandRecord.result?.metadata["commandJournalRuntimeEventID"], event.id)
        XCTAssertEqual(commandRecord.result?.metadata["commandJournalRuntimeReceiptID"], "runtime.receipt.command-runtime-journal")
        XCTAssertEqual(runtimeLink.runtimeEventID, event.id)
        XCTAssertEqual(runtimeLink.runtimeReceiptID, "runtime.receipt.command-runtime-journal")
        XCTAssertEqual(runtimeLink.envelopeID, commandJournalEntry.envelope.id)
        XCTAssertTrue(CommandJournalRuntimeLinkChecksum.isValid(runtimeLink, entry: commandJournalEntry))
        guard case let .commandExecution(payload) = event.event.payload else {
            XCTFail("Expected command execution payload")
            return
        }
        XCTAssertEqual(payload.resultStatus, .succeeded)
        XCTAssertEqual(payload.commandRecordID, "command.execution.command-runtime-journal")
        XCTAssertEqual(payload.resultMetadata["commandJournalEnvelopeID"], commandJournalEntry.envelope.id)
        XCTAssertEqual(payload.resultMetadata["commandJournalReceiptID"], "command.journal.append.command-runtime-journal")
        XCTAssertEqual(payload.resultMetadata["captureID"], "capture-runtime-journal")
        XCTAssertEqual(payload.resultMetadata["receiptID"], "runtime.receipt.command-runtime-journal")
        XCTAssertEqual(payload.resultMetadata["proofArtifactID"], "runtime.proof.command-runtime-journal")
        XCTAssertEqual(payload.resultMetadata["runtimeMutationID"], "runtime.mutation.command-runtime-journal")
    }
}

private extension RuntimeEventJournalTests {
    func makeQuickCaptureCommand(id: String, text: String) -> AmbitionsCommand {
        AmbitionsCommand(
            id: id,
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: text),
            createdAt: "2026-06-30T05:00:00Z"
        )
    }

    func makeCorrectionEvent(id: String, occurredAt: String) -> RuntimeEvent {
        RuntimeEvent(
            commandID: "command-\(id)",
            actor: .user,
            source: .today,
            privacy: .standard,
            occurredAt: occurredAt,
            payload: .correctionRecorded(
                RuntimeCorrectionEventPayload(
                    correctionID: id,
                    objectID: "capture-\(id)",
                    correctionKind: "user_text_correction"
                )
            )
        )
    }

    func makeProofEvent(id: String, occurredAt: String) -> RuntimeEvent {
        RuntimeEvent(
            actor: .system,
            source: .system,
            privacy: .standard,
            occurredAt: occurredAt,
            payload: .proofAttached(
                RuntimeProofAttachmentEventPayload(
                    proofID: id,
                    objectID: "goal-\(id)",
                    sourceRecordIDs: ["source-\(id)"]
                )
            )
        )
    }

    func temporaryJournalURL() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("ambitions-runtime-event-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }
        return directory.appendingPathComponent("RuntimeEventJournal.jsonl")
    }

    func repoRoot() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath)
        while candidate.path != "/" {
            if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("project.yml").path) {
                return candidate
            }
            candidate.deleteLastPathComponent()
        }
        throw NSError(domain: "RuntimeEventJournalTests", code: 1)
    }
}
