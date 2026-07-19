import XCTest
@testable import Ambitions

final class CommandsLeafTests: XCTestCase {
    func testMarkedTodayRecommendationRejectionCompilesAsLocalRuntimeMutation() {
        let command = AmbitionsCommand(
            id: "today.rejection.command.reducer-proof",
            kind: .dismissRecommendation,
            source: .today,
            target: AmbitionsCommandTarget(stepID: "step-1", recommendationID: "candidate-1", destination: .today),
            payload: AmbitionsCommandPayload(metadata: [TodayReceiptDomainEvent.mutationMarkerKey: "true"]),
            createdAt: "2027-02-20T09:00:00Z",
            privacy: .privateUserText
        )

        let plan = CommandReducer().reduce(command: command, validation: .valid)

        XCTAssertEqual(plan.mutationKind, .runtimeMutation)
        XCTAssertTrue(plan.canMutate)
        XCTAssertEqual(plan.sideEffectPolicy, .localOnly)
        XCTAssertEqual(plan.fallback.kind, "no_apply")
        XCTAssertEqual(plan.undoShape.kind, "receipt_backed_undo")
        XCTAssertTrue(plan.expectedProjectionIDs.contains(ProjectionID.today.rawValue))
    }

    func testCommandCompilerBuildsEnvelopeWithMutationPlanAndPolicy() {
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let command = quickCaptureCommand(id: "command.compiler.proof", now: now)

        let compilation = CommandCompiler().compile(
            command,
            context: CommandExecutionContext(now: now, sourceSurface: "today")
        )

        XCTAssertEqual(compilation.idempotencyKey.rawValue, "command.compiler.proof")
        XCTAssertTrue(compilation.canProceedToMutation)
        XCTAssertEqual(compilation.envelope.phase, .acceptedBeforeMutation)
        XCTAssertEqual(compilation.envelope.actor, .user)
        XCTAssertEqual(compilation.envelope.source, .today)
        XCTAssertEqual(compilation.envelope.privacy, .privateUserText)
        XCTAssertEqual(compilation.mutationPlan.mutationKind, .runtimeMutation)
        XCTAssertEqual(compilation.mutationPlan.sideEffectPolicy, .localOnly)
        XCTAssertTrue(compilation.mutationPlan.expectedProjectionIDs.contains(ProjectionID.today.rawValue))
        XCTAssertTrue(compilation.mutationPlan.expectedProjectionIDs.contains(ProjectionID.receipt.rawValue))
        XCTAssertEqual(compilation.mutationPlan.undoShape.kind, "receipt_backed_undo")
    }

    func testCommandJournalPersistsAppendOnlyEnvelopesWithChecksums() async throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CommandJournalTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        let journal = FileCommandJournal(fileURL: tempDirectory.appendingPathComponent("CommandJournal.jsonl"))
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let first = CommandCompiler().compile(
            quickCaptureCommand(id: "command.journal.first", now: now),
            context: CommandExecutionContext(now: now)
        )
        let second = CommandCompiler().compile(
            quickCaptureCommand(id: "command.journal.second", now: now.addingTimeInterval(60)),
            context: CommandExecutionContext(now: now.addingTimeInterval(60))
        )

        let firstReceipt = try await journal.append(first.envelope)
        let secondReceipt = try await journal.append(second.envelope)

        let entries = try await journal.fetchEntries(matching: .all, limit: nil)
        XCTAssertEqual(entries.map(\.sequence), [1, 2])
        XCTAssertEqual(firstReceipt.sequence, 1)
        XCTAssertEqual(secondReceipt.sequence, 2)
        XCTAssertEqual(entries[1].previousChecksum, entries[0].checksum)
        XCTAssertTrue(entries.allSatisfy(CommandJournalChecksum.isValid))
        let secondEnvelopes = try await journal.fetchEnvelopes(matching: .commandID("command.journal.second"), limit: nil)
        XCTAssertEqual(secondEnvelopes.first?.id, second.envelope.id)
    }

    func testCommandJournalPersistsRuntimeEventAndReceiptLinks() async throws {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CommandJournalLinkTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: tempDirectory)
        }
        let fileURL = tempDirectory.appendingPathComponent("CommandJournal.jsonl")
        let journal = FileCommandJournal(fileURL: fileURL)
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let compilation = CommandCompiler().compile(
            quickCaptureCommand(id: "command.journal.linked", now: now),
            context: CommandExecutionContext(now: now)
        )

        let appendReceipt = try await journal.append(compilation.envelope)
        let linkReceipt = try await journal.linkRuntimeCommit(
            commandID: compilation.command.id,
            runtimeEventID: "runtime.event.7",
            runtimeReceiptID: "runtime.receipt.command.journal.linked",
            linkedAt: "2026-06-30T23:10:00Z"
        )
        let reloadedJournal = FileCommandJournal(fileURL: fileURL)
        let reloadedEntries = try await reloadedJournal.fetchEntries(matching: .commandID(compilation.command.id), limit: nil)
        let entry = try XCTUnwrap(reloadedEntries.first)
        let link = try XCTUnwrap(entry.runtimeLink)

        XCTAssertEqual(appendReceipt.envelopeID, compilation.envelope.id)
        XCTAssertEqual(link.runtimeEventID, "runtime.event.7")
        XCTAssertEqual(link.runtimeReceiptID, "runtime.receipt.command.journal.linked")
        XCTAssertEqual(link.entryID, entry.id)
        XCTAssertEqual(link.envelopeID, compilation.envelope.id)
        XCTAssertEqual(linkReceipt.runtimeEventID, link.runtimeEventID)
        XCTAssertEqual(linkReceipt.runtimeReceiptID, link.runtimeReceiptID)
        XCTAssertEqual(linkReceipt.resultMetadata["commandJournalRuntimeLinkStatus"], nil)
        XCTAssertTrue(CommandJournalChecksum.isValid(entry))
        XCTAssertTrue(CommandJournalRuntimeLinkChecksum.isValid(link, entry: entry))
    }

    func testCommandAuthorizerDeniesNonLocalPrivateRuntimeCommand() {
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let command = AmbitionsCommand(
            id: "command.authorization.private-egress",
            kind: .quickCapture,
            source: .capture,
            payload: AmbitionsCommandPayload(rawText: "Private local note"),
            createdAt: DomainTimestamp.string(from: now),
            localOnly: false,
            privacy: .privateUserText
        )
        let plan = CommandReducer().reduce(command: command, validation: .valid)

        let authorization = CommandAuthorizer().authorize(
            command: command,
            idempotencyKey: CommandIdempotencyKey(command: command),
            validation: .valid,
            mutationPlan: plan
        )

        XCTAssertEqual(authorization.state, .denied)
        XCTAssertTrue(authorization.reasonCodes.contains("private_runtime_non_local_execution"))
    }

    func testExecutorAppendsCommandJournalBeforeCaptureMutationAndRecordsTypedReceipt() async throws {
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let commandJournal = InMemoryCommandJournal()
        let captureRepository = JournalGatedCaptureRepository(
            commandID: "command.journal-gated-capture",
            commandJournal: commandJournal
        )
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-journal-gated" })
        let commandRecordRepository = InMemoryAmbitionsCommandExecutionRecordRepository()
        let executor = AmbitionsCommandExecutor.test(
            captureService: captureService,
            commandExecutionRecords: commandRecordRepository,
            commandJournal: commandJournal
        )
        let command = quickCaptureCommand(id: "command.journal-gated-capture", now: now)

        let result = await executor.execute(command, context: CommandExecutionContext(now: now))

        XCTAssertEqual(result.status, .succeeded)
        XCTAssertEqual(result.metadata["commandJournalSequence"], "1")
        XCTAssertEqual(result.metadata["commandEnvelopePhase"], CommandEnvelopePhase.acceptedBeforeMutation.rawValue)
        XCTAssertEqual(result.metadata["commandReceiptID"], "command.receipt.command.journal-gated-capture")
        let savedCaptures = try await captureRepository.listCaptures()
        XCTAssertEqual(savedCaptures.map(\.id), ["capture.command.journal-gated-capture"])
        let envelopes = try await commandJournal.fetchEnvelopes(matching: .commandID(command.id), limit: nil)
        XCTAssertEqual(envelopes.count, 1)
        let record = try await commandRecordRepository.fetchRecord(commandID: command.id)
        XCTAssertEqual(record?.result.metadata["commandReceiptID"], "command.receipt.command.journal-gated-capture")
    }

    func testExecutorBlocksMutationWhenCommandJournalAppendFails() async throws {
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-should-not-save" })
        let executor = AmbitionsCommandExecutor.test(
            captureService: captureService,
            commandJournal: FailingCommandJournal()
        )
        let command = quickCaptureCommand(id: "command.journal-failure", now: now)

        let result = await executor.execute(command, context: CommandExecutionContext(now: now))

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(result.metadata["blockedBy"], "command_journal_append_failed")
        let savedCaptures = try await captureRepository.listCaptures()
        XCTAssertTrue(savedCaptures.isEmpty)
    }

    func testExecutorBlocksMeaningfulMutationWhenRuntimeCommitFails() async throws {
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-runtime-failure" })
        let commandRecordRepository = InMemoryAmbitionsCommandExecutionRecordRepository()
        let executor = AmbitionsCommandExecutor.test(
            captureService: captureService,
            commandExecutionRecords: commandRecordRepository,
            runtimeEvents: FailingRuntimeEventStore()
        )
        let command = quickCaptureCommand(id: "command.runtime-failure", now: now)

        let result = await executor.execute(command, context: CommandExecutionContext(now: now))
        let record = try await commandRecordRepository.fetchRecord(commandID: command.id)

        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(result.metadata["blockedBy"], "runtime_transaction_commit_failed")
        XCTAssertEqual(result.metadata["runtimeTransactionDisposition"], "not_committed")
        XCTAssertEqual(result.metadata["runtimeCommitPolicy"], "meaningful_mutation_requires_commit")
        XCTAssertEqual(result.metadata["runtimeCommitEvidence"], "missing")
        XCTAssertEqual(result.metadata["runtimeCommitFailureReceiptID"], "runtime.failure-receipt.command.runtime-failure")
        XCTAssertEqual(record?.result.status, .blocked)
        XCTAssertEqual(record?.result.metadata["commandReceiptStatus"], AmbitionsCommandExecutionStatus.blocked.rawValue)
    }

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
            context: CommandExecutionContext(now: now, sourceSurface: "today")
        ) {
            AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Today closure receipt recorded.",
                route: .today,
                target: closureCommand.target,
                metadata: ["receiptID": "today.receipt.runtime-commit"]
            )
        }

        let preferencesCommand = AmbitionsCommand(
            id: "you.preferences.command.runtime-commit",
            kind: .updateUserPreferences,
            source: .you,
            target: AmbitionsCommandTarget(destination: .you),
            payload: AmbitionsCommandPayload(title: "Update You preferences"),
            createdAt: DomainTimestamp.string(from: now.addingTimeInterval(60)),
            actor: .user,
            sourceSurface: "you"
        )
        let preferencesResult = await committer.commit(
            command: preferencesCommand,
            context: CommandExecutionContext(now: now.addingTimeInterval(60), sourceSurface: "you")
        ) {
            AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "You preferences saved locally.",
                route: .you,
                target: preferencesCommand.target,
                metadata: ["preferredTab": "you"]
            )
        }

        let events = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)

        assertCommittedRuntimeEvidence(closureResult, commandID: closureCommand.id)
        assertCommittedRuntimeEvidence(preferencesResult, commandID: preferencesCommand.id)
        XCTAssertEqual(events.map(\.event.commandID), [closureCommand.id, preferencesCommand.id])
    }

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
        var mutationExecutionCount = 0

        let first = await committer.commit(
            command: command,
            context: CommandExecutionContext(now: now)
        ) {
            mutationExecutionCount += 1
            return AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Saved once.",
                route: .captureInbox,
                target: AmbitionsCommandTarget(captureID: "capture-runtime-event-authority")
            )
        }
        let second = await committer.commit(
            command: command,
            context: CommandExecutionContext(now: now.addingTimeInterval(60))
        ) {
            mutationExecutionCount += 1
            return AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Should not run twice.",
                route: .captureInbox,
                target: AmbitionsCommandTarget(captureID: "capture-runtime-event-authority-duplicate")
            )
        }
        let events = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)
        let record = try await commandRecords.fetchRecord(commandID: command.id)

        XCTAssertEqual(first.status, .succeeded)
        XCTAssertEqual(second.status, .succeeded)
        XCTAssertEqual(second.summary, "Replayed runtime event receipt: Saved once.")
        XCTAssertEqual(mutationExecutionCount, 1)
        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(record?.result.metadata["runtimeReplayDecision"], LedgerReplayDecision.applyFresh.rawValue)
        XCTAssertEqual(second.metadata["ledgerRecordKind"], LedgerRecordTaxonomyKind.event.rawValue)
        XCTAssertEqual(second.metadata["runtimeReplayAuthority"], "runtime_event_journal")
        XCTAssertEqual(second.metadata["runtimeReplaySource"], "runtime_event")
        XCTAssertEqual(second.metadata["runtimeReplayCommandRecordMaterialization"], "already_materialized")
        XCTAssertEqual(second.metadata["doubleApplyDisposition"], LedgerDoubleApplyDisposition.skipDuplicateMutation.rawValue)
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
        var mutationExecuted = false

        let result = await committer.commit(
            command: command,
            context: CommandExecutionContext(now: now.addingTimeInterval(60))
        ) {
            mutationExecuted = true
            return AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Should not execute.",
                target: AmbitionsCommandTarget(captureID: "capture-should-not-write")
            )
        }
        let events = try await runtimeEvents.fetchEvents(matching: .all, limit: nil)

        XCTAssertFalse(mutationExecuted)
        XCTAssertTrue(events.isEmpty)
        XCTAssertEqual(result.status, .blocked)
        XCTAssertEqual(result.metadata["blockedBy"], "runtime_event_missing_for_command_record")
        XCTAssertEqual(result.metadata["runtimeReplayAuthority"], "runtime_event_journal")
        XCTAssertEqual(result.metadata["runtimeReplaySource"], "command_record_repair_state")
        XCTAssertEqual(result.metadata["doubleApplyDisposition"], LedgerDoubleApplyDisposition.skipUnverifiedMutation.rawValue)
    }

    func testCommandReplayAdapterReturnsPriorReceiptWithCommandIdempotencyKey() async throws {
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let repository = InMemoryAmbitionsCommandExecutionRecordRepository()
        let command = quickCaptureCommand(id: "command.replay-adapter", now: now)
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Saved once.",
            target: AmbitionsCommandTarget(captureID: "capture-once")
        )
        try await repository.append(
            AmbitionsCommandExecutionRecord(
                command: command,
                result: result,
                recordedAt: DomainTimestamp.string(from: now)
            )
        )
        let adapter = CommandReplayAdapter(commandExecutionRecords: repository)

        let lookup = await adapter.lookup(command)
        guard case .record(let record) = lookup else {
            return XCTFail("Expected existing command record.")
        }
        let replay = adapter.replayResult(for: command, record: record)

        XCTAssertEqual(replay.status, .succeeded)
        XCTAssertEqual(replay.metadata["replayDecision"], LedgerReplayDecision.replayExistingReceipt.rawValue)
        XCTAssertEqual(replay.metadata["commandIdempotencyKey"], command.id)
        XCTAssertEqual(replay.metadata["doubleApplyDisposition"], LedgerDoubleApplyDisposition.skipDuplicateMutation.rawValue)
    }

    private func assertCommittedRuntimeEvidence(
        _ result: AmbitionsCommandExecutionResult,
        commandID: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(result.status, .succeeded, file: file, line: line)
        XCTAssertEqual(result.metadata["runtimeTransactionDisposition"], RuntimeTransactionCommitDisposition.committed.rawValue, file: file, line: line)
        XCTAssertEqual(result.metadata["runtimeTransactionID"], "runtime.transaction.\(commandID)", file: file, line: line)
        XCTAssertNotNil(result.metadata["runtimeEventID"], file: file, line: line)
        XCTAssertEqual(result.metadata["runtimeReceiptID"], "runtime.receipt.\(commandID)", file: file, line: line)
        XCTAssertEqual(result.metadata["runtimeRollbackPlanID"], "runtime.rollback.\(commandID)", file: file, line: line)
        XCTAssertEqual(result.metadata["runtimeReplayTraceID"], "runtime.replay.\(commandID)", file: file, line: line)
    }

    private func quickCaptureCommand(id: String, now: Date) -> AmbitionsCommand {
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
}

private enum CommandsLeafTestError: Error {
    case commandJournalMissingBeforeMutation
    case commandJournalUnavailable
    case runtimeEventAppendUnavailable
}

private actor JournalGatedCaptureRepository: CaptureRepository {
    private var captures: [Capture] = []
    private let commandID: String
    private let commandJournal: any CommandJournal

    init(commandID: String, commandJournal: any CommandJournal) {
        self.commandID = commandID
        self.commandJournal = commandJournal
    }

    func listCaptures() async throws -> [Capture] {
        captures
    }

    func capture(id: String) async throws -> Capture? {
        captures.first { $0.id == id }
    }

    func saveCaptures(_ captures: [Capture]) async throws {
        let envelopes = try await commandJournal.fetchEnvelopes(matching: .commandID(commandID), limit: nil)
        guard envelopes.isEmpty == false else {
            throw CommandsLeafTestError.commandJournalMissingBeforeMutation
        }
        self.captures = captures
    }
}

private actor FailingCommandJournal: CommandJournal {
    func append(_ envelope: CommandEnvelope) async throws -> CommandJournalAppendReceipt {
        _ = envelope
        throw CommandsLeafTestError.commandJournalUnavailable
    }

    func fetchEntries(matching query: CommandJournalQuery, limit: Int?) async throws -> [CommandJournalEntry] {
        _ = query
        _ = limit
        return []
    }

    func fetchEnvelopes(matching query: CommandJournalQuery, limit: Int?) async throws -> [CommandEnvelope] {
        _ = query
        _ = limit
        return []
    }
}

private actor FailingRuntimeEventStore: RuntimeEventStore {
    nonisolated var storeKind: RuntimeEventStoreKind { .inMemory }

    func append(_ event: RuntimeEvent) async throws -> RuntimeEventEnvelope {
        _ = event
        throw CommandsLeafTestError.runtimeEventAppendUnavailable
    }

    func fetchEvents(matching query: RuntimeEventQuery, limit: Int?) async throws -> [RuntimeEventEnvelope] {
        _ = query
        _ = limit
        return []
    }

    func latestCursor() async throws -> RuntimeEventCursor? {
        nil
    }
}
