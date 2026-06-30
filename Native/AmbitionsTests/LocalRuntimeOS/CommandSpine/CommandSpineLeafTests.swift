import XCTest
@testable import Ambitions

final class CommandSpineLeafTests: XCTestCase {
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
        let executor = AmbitionsCommandExecutor(
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
        XCTAssertEqual(savedCaptures.map(\.id), ["capture-journal-gated"])
        let envelopes = try await commandJournal.fetchEnvelopes(matching: .commandID(command.id), limit: nil)
        XCTAssertEqual(envelopes.count, 1)
        let record = try await commandRecordRepository.fetchRecord(commandID: command.id)
        XCTAssertEqual(record?.result.metadata["commandReceiptID"], "command.receipt.command.journal-gated-capture")
    }

    func testExecutorBlocksMutationWhenCommandJournalAppendFails() async throws {
        let now = Date(timeIntervalSince1970: 1_777_113_600)
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: captureRepository, idProvider: { "capture-should-not-save" })
        let executor = AmbitionsCommandExecutor(
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

private enum CommandSpineLeafTestError: Error {
    case commandJournalMissingBeforeMutation
    case commandJournalUnavailable
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
            throw CommandSpineLeafTestError.commandJournalMissingBeforeMutation
        }
        self.captures = captures
    }
}

private actor FailingCommandJournal: CommandJournal {
    func append(_ envelope: CommandEnvelope) async throws -> CommandJournalAppendReceipt {
        _ = envelope
        throw CommandSpineLeafTestError.commandJournalUnavailable
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
