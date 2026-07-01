import Foundation

enum RuntimeCommandMutationCommitterError: Error, Sendable, Equatable {
    case commandJournalAppendFailed
}

struct RuntimeCommandMutationCommitter: Sendable {
    let commandJournal: any CommandJournal
    let commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?
    let runtimeEvents: (any RuntimeEventStore)?
    let runtimeTransactionIdempotencyStore: RuntimeIdempotencyStore
    let compiler: CommandCompiler
    let runtimeValidator: RuntimeValidator
    let receiptFactory: CommandReceiptFactory

    init(
        commandJournal: any CommandJournal,
        commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?,
        runtimeEvents: (any RuntimeEventStore)?,
        runtimeTransactionIdempotencyStore: RuntimeIdempotencyStore = RuntimeIdempotencyStore(),
        compiler: CommandCompiler = CommandCompiler(),
        runtimeValidator: RuntimeValidator = RuntimeValidator(),
        receiptFactory: CommandReceiptFactory = CommandReceiptFactory()
    ) {
        self.commandJournal = commandJournal
        self.commandExecutionRecords = commandExecutionRecords
        self.runtimeEvents = runtimeEvents
        self.runtimeTransactionIdempotencyStore = runtimeTransactionIdempotencyStore
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
        let recordID = "command.execution.\(command.id)"
        let transactionResult = await resultByCommittingRuntimeTransaction(
            command: command,
            result: result,
            recordedAt: recordedAt,
            commandRecordID: recordID,
            timestamp: timestamp,
            journalReceipt: journalReceipt
        )
        let commandReceipt = receiptFactory.makeReceipt(
            command: command,
            result: transactionResult,
            compilation: compilation,
            journalReceipt: journalReceipt,
            issuedAt: recordedAt
        )
        let enrichedResult = transactionResult.mergingMetadata(commandReceipt.resultMetadata)
        let record = AmbitionsCommandExecutionRecord(
            id: recordID,
            command: command,
            result: enrichedResult,
            recordedAt: recordedAt
        )
        try? await commandExecutionRecords?.append(record)
        return enrichedResult
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
