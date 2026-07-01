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
        guard RuntimeTransactionCommitPolicy.requiresCommit(command: command, result: result) else {
            return result
        }
        guard let runtimeEvents else {
            return RuntimeTransactionCommitPolicy.failureResult(
                command: command,
                result: result,
                recordedAt: recordedAt,
                reason: "runtime_events_unavailable"
            )
        }
        guard let request = RuntimeTransactionCommitPolicy.transactionRequest(
            command: command,
            result: result,
            recordedAt: recordedAt
        ) else {
            return RuntimeTransactionCommitPolicy.failureResult(
                command: command,
                result: result,
                recordedAt: recordedAt,
                reason: "runtime_transaction_request_unavailable"
            )
        }

        let coordinator = RuntimeTransactionCoordinator(
            eventStore: runtimeEvents,
            idempotencyStore: runtimeTransactionIdempotencyStore,
            validator: runtimeValidator
        )

        do {
            let outcome = try await coordinator.commit(
                command: request.command,
                beforeSnapshot: request.beforeSnapshot,
                afterSnapshot: request.afterSnapshot,
                targetSurface: request.targetSurface,
                executionResult: result,
                commandRecordID: commandRecordID,
                occurredAt: timestamp
            )
            var runtimeMetadata = [
                "runtimeTransactionDisposition": outcome.disposition.rawValue,
                "runtimeTransactionID": outcome.receipt.transactionID,
                "runtimeEventID": outcome.receipt.eventID,
                "runtimeReceiptID": outcome.receipt.receiptID,
                "runtimeRollbackPlanID": outcome.receipt.rollbackPlanID,
                "runtimeReplayTraceID": outcome.receipt.replayTraceID,
                "runtimeReplayDecision": outcome.replayOutcome.decision.rawValue,
                "runtimeDoubleApplyDisposition": outcome.replayOutcome.doubleApplyDisposition.rawValue,
                "runtimeProjectionCursorCount": String(outcome.receipt.projectionCursors.count),
                "runtimeProjectionIDs": outcome.receipt.projectionCursors.map(\.projectionID.rawValue).sorted().joined(separator: ","),
            ]
            if journalReceipt != nil {
                do {
                    let linkReceipt = try await commandJournal.linkRuntimeCommit(
                        commandID: command.id,
                        runtimeEventID: outcome.receipt.eventID,
                        runtimeReceiptID: outcome.receipt.receiptID,
                        linkedAt: DomainTimestamp.string(from: timestamp)
                    )
                    runtimeMetadata.merge(linkReceipt.resultMetadata) { _, new in new }
                    runtimeMetadata["commandJournalRuntimeLinkStatus"] = "linked"
                } catch {
                    runtimeMetadata["commandJournalRuntimeLinkStatus"] = "failed"
                    runtimeMetadata["commandJournalRuntimeLinkError"] = String(describing: error)
                }
            }
            let committedResult = result.mergingMetadata(runtimeMetadata)
            guard RuntimeTransactionCommitPolicy.hasCommittedEvidence(committedResult) else {
                return RuntimeTransactionCommitPolicy.failureResult(
                    command: command,
                    result: committedResult,
                    recordedAt: recordedAt,
                    reason: "runtime_commit_evidence_missing"
                )
            }
            return committedResult
        } catch {
            let failedResult = result.mergingMetadata([
                "runtimeTransactionDisposition": "not_committed",
                "runtimeTransactionBlockedBy": String(describing: error),
            ])
            return RuntimeTransactionCommitPolicy.failureResult(
                command: command,
                result: failedResult,
                recordedAt: recordedAt,
                reason: "runtime_transaction_commit_failed",
                error: error
            )
        }
    }
}

enum CommandJournalAppendOutcome {
    case appended(CommandJournalAppendReceipt)
    case failed(Error)
}
