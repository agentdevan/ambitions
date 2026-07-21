import Foundation

enum RuntimeCommandMutationCommitterError: Error, Sendable, Equatable {
    case commandJournalAppendFailed
}

struct RuntimeCommandMaterialization: Sendable {
    let statusMetadataKey: String
    let apply: @Sendable (AmbitionsCommandExecutionResult) async throws -> [String: String]

    init(
        statusMetadataKey: String,
        apply: @escaping @Sendable (AmbitionsCommandExecutionResult) async throws -> [String: String]
    ) {
        precondition(statusMetadataKey.isEmpty == false, "Materialization status metadata key cannot be empty.")
        self.statusMetadataKey = statusMetadataKey
        self.apply = apply
    }
}

private enum RuntimeCommandJournalPreparation {
    case appended(CommandJournalAppendReceipt)
    case blocked(AmbitionsCommandExecutionResult)
}

private struct RuntimeCommandPersistenceInput {
    let command: AmbitionsCommand
    let result: AmbitionsCommandExecutionResult
    let timestamp: Date
    let compilation: CommandCompilation?
    let journalReceipt: CommandJournalAppendReceipt?
    let materialization: RuntimeCommandMaterialization?
}

private struct RuntimeCommandUnreplayedInput {
    let command: AmbitionsCommand
    let context: CommandExecutionContext
    let plannedResult: AmbitionsCommandExecutionResult
    let validation: AmbitionsCommandValidationState
    let compilation: CommandCompilation
    let preparation: RuntimeCommandJournalPreparation
    let materialization: RuntimeCommandMaterialization?
}

struct RuntimeCommandMutationCommitter: Sendable {
    let commandJournal: any CommandJournal
    let commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?
    let runtimeEvents: (any RuntimeEventStore)?
    let projectionStore: ProjectionStoreSQLite?
    let searchIndex: FTSIndex?
    let runtimeTransactionIdempotencyStore: RuntimeIdempotencyStore
    let compiler: CommandCompiler
    let runtimeValidator: RuntimeValidator
    let receiptFactory: CommandReceiptFactory

    init(
        commandJournal: any CommandJournal,
        commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?,
        runtimeEvents: (any RuntimeEventStore)?,
        projectionStore: ProjectionStoreSQLite? = nil,
        searchIndex: FTSIndex? = nil,
        runtimeTransactionIdempotencyStore: RuntimeIdempotencyStore = RuntimeIdempotencyStore(),
        compiler: CommandCompiler = CommandCompiler(),
        runtimeValidator: RuntimeValidator = RuntimeValidator(),
        receiptFactory: CommandReceiptFactory = CommandReceiptFactory()
    ) {
        self.commandJournal = commandJournal
        self.commandExecutionRecords = commandExecutionRecords
        self.runtimeEvents = runtimeEvents
        self.projectionStore = projectionStore
        self.searchIndex = searchIndex
        self.runtimeTransactionIdempotencyStore = runtimeTransactionIdempotencyStore
        self.compiler = compiler
        self.runtimeValidator = runtimeValidator
        self.receiptFactory = receiptFactory
    }

    func commit(
        command: AmbitionsCommand,
        context: CommandExecutionContext,
        plannedResult: AmbitionsCommandExecutionResult,
        materialization: RuntimeCommandMaterialization? = nil
    ) async -> AmbitionsCommandExecutionResult {
        let replayAdapter = RuntimeEventCommandReplayAdapter(
            runtimeEvents: runtimeEvents,
            commandExecutionRecords: commandExecutionRecords
        )
        let lookup = await replayAdapter.lookup(command)
        if let replayResult = await replayResult(
            lookup,
            adapter: replayAdapter,
            command: command,
            context: context,
            materialization: materialization
        ) {
            return replayResult
        }
        let validation = runtimeValidator.validate(command).validationState
        let compilation = compiler.compile(command, context: context, validation: validation)
        let preparation: RuntimeCommandJournalPreparation
        do {
            preparation = .appended(try await commandJournal.append(compilation.envelope))
        } catch {
            preparation = .blocked(journalAppendFailureResult(
                command: command,
                compilation: compilation,
                error: error
            ))
        }
        return await commitUnreplayed(RuntimeCommandUnreplayedInput(
            command: command,
            context: context,
            plannedResult: plannedResult,
            validation: validation,
            compilation: compilation,
            preparation: preparation,
            materialization: materialization
        ))
    }

    private func persist(_ input: RuntimeCommandPersistenceInput) async -> AmbitionsCommandExecutionResult {
        let recordedAt = DomainTimestamp.string(from: input.timestamp)
        let recordID = "command.execution.\(input.command.id)"
        let transactionResult = await RuntimeTransactionCommitPolicy.resultByCommittingRuntimeTransaction(
            command: input.command,
            result: input.result,
            recordedAt: recordedAt,
            commandRecordID: recordID,
            timestamp: input.timestamp,
            runtimeEvents: runtimeEvents,
            projectionStore: projectionStore,
            searchIndex: searchIndex,
            runtimeTransactionIdempotencyStore: runtimeTransactionIdempotencyStore,
            runtimeValidator: runtimeValidator,
            commandJournal: commandJournal,
            journalReceipt: input.journalReceipt
        )
        let materializedResult = await materializeIfCommitted(
            result: transactionResult,
            materialization: input.materialization
        )
        let commandReceipt = receiptFactory.makeReceipt(
            command: input.command,
            result: materializedResult,
            compilation: input.compilation,
            journalReceipt: input.journalReceipt,
            issuedAt: recordedAt
        )
        let enrichedResult = materializedResult.mergingMetadata(commandReceipt.resultMetadata)
        let record = AmbitionsCommandExecutionRecord(
            id: recordID,
            command: input.command,
            result: enrichedResult,
            recordedAt: recordedAt
        )
        if let commandExecutionRecords {
            do {
                try await commandExecutionRecords.append(record)
            } catch {
                return enrichedResult.mergingMetadata([
                    "commandRecordMaterialization": "needs_recovery",
                    "commandRecordMaterializationError": String(describing: error)
                ])
            }
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

private extension RuntimeCommandMutationCommitter {
    func replayResult(
        _ lookup: RuntimeEventCommandReplayLookupResult,
        adapter: RuntimeEventCommandReplayAdapter,
        command: AmbitionsCommand,
        context: CommandExecutionContext,
        materialization: RuntimeCommandMaterialization?
    ) async -> AmbitionsCommandExecutionResult? {
        switch lookup {
        case .runtimeEvent(let projection, let authorityReceipt, let commandRecord, let recordStatus):
            let result = adapter.replayResult(
                for: command,
                projection: projection,
                authorityReceipt: authorityReceipt,
                commandRecord: commandRecord,
                commandRecordMaterialization: recordStatus
            )
            guard RuntimeTransactionCommitPolicy.hasCommittedEvidence(result) else { return result }
            return await materializeAndUpsertReplayIfNeeded(
                command: command,
                result: result,
                materialization: materialization,
                recordedAt: commandRecord?.recordedAt ?? projection.recordedAt
            )
        case .commandRecordWithoutRuntimeEvent(let record):
            return adapter.commandRecordWithoutRuntimeEventResult(for: command, record: record)
        case .sqliteDiagnosticWithoutAuthority(let projection):
            return adapter.sqliteDiagnosticWithoutAuthorityResult(for: command, projection: projection)
        case .lookupUnavailable:
            return await persist(RuntimeCommandPersistenceInput(
                command: command,
                result: adapter.lookupUnavailableResult(for: command),
                timestamp: context.now,
                compilation: nil,
                journalReceipt: nil,
                materialization: nil
            ))
        case .noRecord:
            return nil
        }
    }

    func commitUnreplayed(_ input: RuntimeCommandUnreplayedInput) async -> AmbitionsCommandExecutionResult {
        guard case .appended(let journalReceipt) = input.preparation else {
            guard case .blocked(let result) = input.preparation else { preconditionFailure() }
            return await persist(RuntimeCommandPersistenceInput(
                command: input.command,
                result: result,
                timestamp: input.context.now,
                compilation: input.compilation,
                journalReceipt: nil,
                materialization: nil
            ))
        }
        if let blocked = preAuthorityBlockedResult(
            command: input.command,
            validation: input.validation,
            compilation: input.compilation,
            journalReceipt: journalReceipt
        ) {
            return await persist(RuntimeCommandPersistenceInput(
                command: input.command,
                result: blocked,
                timestamp: input.context.now,
                compilation: input.compilation,
                journalReceipt: journalReceipt,
                materialization: nil
            ))
        }
        let result = input.plannedResult
            .mergingMetadata(input.compilation.resultMetadata)
            .mergingMetadata(journalReceipt.resultMetadata)
        return await persist(RuntimeCommandPersistenceInput(
            command: input.command,
            result: result,
            timestamp: input.context.now,
            compilation: input.compilation,
            journalReceipt: journalReceipt,
            materialization: input.materialization
        ))
    }

    func journalAppendFailureResult(
        command: AmbitionsCommand,
        compilation: CommandCompilation,
        error: any Error
    ) -> AmbitionsCommandExecutionResult {
        let result = AmbitionsCommandExecutionResult(
            status: .blocked,
            summary: "Command journal append failed before mutation, " +
                "so Ambitions skipped execution to preserve replay safety.",
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "blockedBy": "command_journal_append_failed",
                "commandJournalError": String(describing: error)
            ]
        )
        return result.mergingMetadata(compilation.resultMetadata)
    }

    func preAuthorityBlockedResult(
        command: AmbitionsCommand,
        validation: AmbitionsCommandValidationState,
        compilation: CommandCompilation,
        journalReceipt: CommandJournalAppendReceipt
    ) -> AmbitionsCommandExecutionResult? {
        let result: AmbitionsCommandExecutionResult
        if validation != .valid {
            result = blockedResult(for: validation, command: command)
        } else if compilation.authorization.isAuthorized == false {
            result = compiler.authorizer.blockedResult(
                command: command,
                authorization: compilation.authorization
            )
        } else {
            return nil
        }
        return result
            .mergingMetadata(compilation.resultMetadata)
            .mergingMetadata(journalReceipt.resultMetadata)
    }

    func materializeAndUpsertReplayIfNeeded(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        materialization: RuntimeCommandMaterialization?,
        recordedAt: String
    ) async -> AmbitionsCommandExecutionResult {
        guard let materialization,
              result.metadata[materialization.statusMetadataKey] != "saved_post_authority" else {
            return result
        }
        let repairedResult = await materializeIfCommitted(
            result: result,
            materialization: materialization
        )
        guard let commandExecutionRecords else { return repairedResult }
        do {
            try await commandExecutionRecords.append(
                AmbitionsCommandExecutionRecord(
                    id: "command.execution.\(command.id)",
                    command: command,
                    result: repairedResult,
                    recordedAt: recordedAt
                )
            )
            return repairedResult
        } catch {
            return repairedResult.mergingMetadata([
                "commandRecordMaterialization": "needs_recovery",
                "commandRecordMaterializationError": String(describing: error)
            ])
        }
    }

    func materializeIfCommitted(
        result: AmbitionsCommandExecutionResult,
        materialization: RuntimeCommandMaterialization?
    ) async -> AmbitionsCommandExecutionResult {
        guard RuntimeTransactionCommitPolicy.hasCommittedEvidence(result),
              let materialization else {
            return result
        }

        do {
            let evidence = try await materialization.apply(result)
            var metadata = result.metadata
            metadata.merge(evidence) { _, new in new }
            metadata[materialization.statusMetadataKey] = "saved_post_authority"
            metadata.removeValue(forKey: "\(materialization.statusMetadataKey)Error")
            return result.replacingMetadata(metadata)
        } catch {
            return result.mergingMetadata([
                materialization.statusMetadataKey: "needs_recovery",
                "\(materialization.statusMetadataKey)Error": String(describing: error)
            ])
        }
    }
}

private extension AmbitionsCommandExecutionResult {
    func replacingMetadata(_ metadata: [String: String]) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: status,
            summary: summary,
            route: route,
            target: target,
            eventLedgerEntryIDs: eventLedgerEntryIDs,
            recommendationExplanationIDs: recommendationExplanationIDs,
            metadata: metadata
        )
    }
}
