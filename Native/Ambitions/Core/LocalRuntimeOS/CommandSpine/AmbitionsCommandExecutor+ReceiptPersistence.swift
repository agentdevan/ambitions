import Foundation

extension AmbitionsCommandExecutor {
    @discardableResult
    func persistExecution(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        at timestamp: Date,
        compilation: CommandCompilation? = nil,
        journalReceipt: CommandJournalAppendReceipt? = nil
    ) async -> AmbitionsCommandExecutionResult {
        let recordedAt = DomainTimestamp.string(from: timestamp)
        let commandRecordID = "command.execution.\(command.id)"
        let transactionResult = await resultByCommittingRuntimeTransaction(
            command: command,
            result: result,
            recordedAt: recordedAt,
            commandRecordID: commandRecordID,
            timestamp: timestamp,
            journalReceipt: journalReceipt
        )
        let receipt = receiptFactory.makeReceipt(
            command: command,
            result: transactionResult,
            compilation: compilation,
            journalReceipt: journalReceipt,
            issuedAt: recordedAt
        )
        let enrichedResult = transactionResult.mergingMetadata(receipt.resultMetadata)
        let record = AmbitionsCommandExecutionRecord(
            id: commandRecordID,
            command: command,
            result: enrichedResult,
            recordedAt: recordedAt
        )

        try? await commandExecutionRecords?.append(record)
        return enrichedResult
    }

    func appendCommandEnvelope(
        _ compilation: CommandCompilation
    ) async -> CommandJournalAppendOutcome {
        do {
            return .appended(try await commandJournal.append(compilation.envelope))
        } catch {
            return .failed(error)
        }
    }

    func commandJournalFailureResult(
        command: AmbitionsCommand,
        compilation: CommandCompilation,
        error: Error
    ) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: .blocked,
            summary: "Command journal append failed before mutation, so Ambitions skipped execution to preserve replay safety.",
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "blockedBy": "command_journal_append_failed",
                "commandJournalError": String(describing: error)
            ]
        )
        .mergingMetadata(compilation.resultMetadata)
    }

    private func resultByCommittingRuntimeTransaction(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        recordedAt: String,
        commandRecordID: String,
        timestamp: Date,
        journalReceipt: CommandJournalAppendReceipt?
    ) async -> AmbitionsCommandExecutionResult {
        await RuntimeTransactionCommitPolicy.resultByCommittingRuntimeTransaction(
            command: command,
            result: result,
            recordedAt: recordedAt,
            commandRecordID: commandRecordID,
            timestamp: timestamp,
            runtimeEvents: runtimeEvents,
            runtimeTransactionIdempotencyStore: runtimeTransactionIdempotencyStore,
            runtimeValidator: runtimeValidator,
            commandJournal: commandJournal,
            journalReceipt: journalReceipt
        )
    }
}

enum CommandJournalAppendOutcome {
    case appended(CommandJournalAppendReceipt)
    case failed(Error)
}
