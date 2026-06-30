import Foundation

enum RuntimeCommandMutationCommitterError: Error, Sendable, Equatable {
    case commandJournalAppendFailed
}

struct RuntimeCommandMutationCommitter: Sendable {
    let commandJournal: any CommandJournal
    let commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?
    let runtimeEvents: (any RuntimeEventStore)?
    let compiler: CommandCompiler
    let runtimeValidator: RuntimeValidator
    let receiptFactory: CommandReceiptFactory

    init(
        commandJournal: any CommandJournal,
        commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?,
        runtimeEvents: (any RuntimeEventStore)?,
        compiler: CommandCompiler = CommandCompiler(),
        runtimeValidator: RuntimeValidator = RuntimeValidator(),
        receiptFactory: CommandReceiptFactory = CommandReceiptFactory()
    ) {
        self.commandJournal = commandJournal
        self.commandExecutionRecords = commandExecutionRecords
        self.runtimeEvents = runtimeEvents
        self.compiler = compiler
        self.runtimeValidator = runtimeValidator
        self.receiptFactory = receiptFactory
    }

    func commit(
        command: AmbitionsCommand,
        context: CommandExecutionContext,
        mutation: () async throws -> AmbitionsCommandExecutionResult
    ) async -> AmbitionsCommandExecutionResult {
        let replayAdapter = CommandReplayAdapter(commandExecutionRecords: commandExecutionRecords)
        switch await replayAdapter.lookup(command) {
        case .record(let record):
            return replayAdapter.replayResult(for: command, record: record)
        case .lookupUnavailable:
            return await persist(
                command: command,
                result: replayAdapter.lookupUnavailableResult(for: command),
                at: context.now
            )
        case .noRecord:
            break
        }

        let validation = runtimeValidator.validate(command).validationState
        let compilation = compiler.compile(command, context: context, validation: validation)
        let journalReceipt: CommandJournalAppendReceipt
        do {
            journalReceipt = try await commandJournal.append(compilation.envelope)
        } catch {
            let result = AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Command journal append failed before mutation, so Ambitions skipped execution to preserve replay safety.",
                target: command.target,
                recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
                metadata: [
                    "blockedBy": "command_journal_append_failed",
                    "commandJournalError": String(describing: error),
                ]
            )
            .mergingMetadata(compilation.resultMetadata)
            return await persist(
                command: command,
                result: result,
                at: context.now,
                compilation: compilation
            )
        }

        guard validation == .valid else {
            let result = blockedResult(for: validation, command: command)
                .mergingMetadata(compilation.resultMetadata)
                .mergingMetadata(journalReceipt.resultMetadata)
            return await persist(
                command: command,
                result: result,
                at: context.now,
                compilation: compilation,
                journalReceipt: journalReceipt
            )
        }

        guard compilation.authorization.isAuthorized else {
            let result = compiler.authorizer.blockedResult(
                command: command,
                authorization: compilation.authorization
            )
            .mergingMetadata(compilation.resultMetadata)
            .mergingMetadata(journalReceipt.resultMetadata)
            return await persist(
                command: command,
                result: result,
                at: context.now,
                compilation: compilation,
                journalReceipt: journalReceipt
            )
        }

        let result: AmbitionsCommandExecutionResult
        do {
            result = try await mutation()
        } catch {
            result = AmbitionsCommandExecutionResult(
                status: .failed,
                summary: error.localizedDescription,
                target: command.target,
                recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
                metadata: ["error": String(describing: error)]
            )
        }

        return await persist(
            command: command,
            result: result
                .mergingMetadata(compilation.resultMetadata)
                .mergingMetadata(journalReceipt.resultMetadata),
            at: context.now,
            compilation: compilation,
            journalReceipt: journalReceipt
        )
    }

    private func persist(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        at timestamp: Date,
        compilation: CommandCompilation? = nil,
        journalReceipt: CommandJournalAppendReceipt? = nil
    ) async -> AmbitionsCommandExecutionResult {
        let recordedAt = DomainTimestamp.string(from: timestamp)
        let commandReceipt = receiptFactory.makeReceipt(
            command: command,
            result: result,
            compilation: compilation,
            journalReceipt: journalReceipt,
            issuedAt: recordedAt
        )
        let enrichedResult = result.mergingMetadata(commandReceipt.resultMetadata)
        let record = AmbitionsCommandExecutionRecord(
            command: command,
            result: enrichedResult,
            recordedAt: recordedAt
        )
        try? await commandExecutionRecords?.append(record)
        if let runtimeEvents {
            let event = RuntimeEvent.commandExecution(
                command: command,
                result: enrichedResult,
                recordedAt: recordedAt,
                commandRecordID: record.id
            )
            _ = try? await runtimeEvents.append(event)
        }
        return enrichedResult
    }

    private func blockedResult(
        for validation: AmbitionsCommandValidationState,
        command: AmbitionsCommand
    ) -> AmbitionsCommandExecutionResult {
        let status: AmbitionsCommandExecutionStatus
        let summary: String
        switch validation {
        case .valid:
            status = .noOp
            summary = "Command is valid."
        case .invalid:
            status = .failed
            summary = "Command input was invalid."
        case .needsConfirmation:
            status = .requiresConfirmation
            summary = "Command needs confirmation before it can mutate local state."
        case .needsMissingTarget:
            status = .blocked
            summary = "Command is missing a required target."
        case .unsupportedInThisBuild:
            status = .unsupported
            summary = "Command is not supported in this build."
        case .blockedByMissingFoundation:
            status = .blocked
            summary = "Command foundation is unavailable."
        }

        return AmbitionsCommandExecutionResult(
            status: status,
            summary: summary,
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: ["validation": validation.rawValue]
        )
    }
}
