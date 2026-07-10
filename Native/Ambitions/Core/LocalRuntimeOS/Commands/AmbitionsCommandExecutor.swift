import Foundation

struct CommandExecutionContext: Sendable {
    let now: Date
    let actor: AmbitionsCommandActor
    let sourceSurface: String?
    let allowsEventLedgerEmission: Bool

    init(
        now: Date,
        actor: AmbitionsCommandActor = .user,
        sourceSurface: String? = nil,
        allowsEventLedgerEmission: Bool = true
    ) {
        self.now = now
        self.actor = actor
        self.sourceSurface = sourceSurface
        self.allowsEventLedgerEmission = allowsEventLedgerEmission
    }
}

protocol CommandExecuting: Sendable {
    func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState
    func execute(_ command: AmbitionsCommand, context: CommandExecutionContext) async -> AmbitionsCommandExecutionResult
}

struct AmbitionsCommandExecutor: CommandExecuting {
    let captureService: (any CaptureServicing)?
    let eventLedger: (any EventLedgerRepository)?
    let commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?
    let runtimeEvents: (any RuntimeEventStore)?
    let projectionStore: ProjectionStoreSQLite?
    let searchIndex: FTSIndex?
    let commandJournal: any CommandJournal
    let runtimeTransactionIdempotencyStore: RuntimeIdempotencyStore
    let smartAttachmentService: (any SmartAttachmentRouting)?
    let validator: AmbitionsCommandValidator
    let runtimeValidator: RuntimeValidator
    let compiler: CommandCompiler
    let receiptFactory: CommandReceiptFactory
    let scheduleStoreFileURL: URL?

    init(
        captureService: (any CaptureServicing)? = nil,
        eventLedger: (any EventLedgerRepository)?,
        commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?,
        runtimeEvents: (any RuntimeEventStore)?,
        projectionStore: ProjectionStoreSQLite?,
        searchIndex: FTSIndex? = nil,
        commandJournal: any CommandJournal,
        runtimeTransactionIdempotencyStore: RuntimeIdempotencyStore,
        smartAttachmentService: (any SmartAttachmentRouting)? = DefaultSmartAttachmentService(),
        validator: AmbitionsCommandValidator = AmbitionsCommandValidator(),
        runtimeValidator: RuntimeValidator? = nil,
        compiler: CommandCompiler? = nil,
        receiptFactory: CommandReceiptFactory,
        scheduleStoreFileURL: URL? = nil
    ) {
        self.captureService = captureService
        self.eventLedger = eventLedger
        self.commandExecutionRecords = commandExecutionRecords
        self.runtimeEvents = runtimeEvents
        self.projectionStore = projectionStore
        self.searchIndex = searchIndex
        self.commandJournal = commandJournal
        self.runtimeTransactionIdempotencyStore = runtimeTransactionIdempotencyStore
        self.smartAttachmentService = smartAttachmentService
        self.validator = validator
        self.runtimeValidator = runtimeValidator ?? RuntimeValidator(commandValidator: validator)
        self.compiler = compiler ?? CommandCompiler(validator: validator)
        self.receiptFactory = receiptFactory
        self.scheduleStoreFileURL = scheduleStoreFileURL
    }

    func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        runtimeValidator.validate(command).validationState
    }

    func execute(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        let replayAdapter = RuntimeEventCommandReplayAdapter(
            runtimeEvents: runtimeEvents,
            commandExecutionRecords: commandExecutionRecords
        )
        switch await replayAdapter.lookup(command) {
        case .runtimeEvent(let projection, let authorityReceipt, let commandRecord, let commandRecordMaterialization):
            let replayed = replayAdapter.replayResult(
                for: command,
                projection: projection,
                authorityReceipt: authorityReceipt,
                commandRecord: commandRecord,
                commandRecordMaterialization: commandRecordMaterialization
            )
            if command.kind == .quickCapture, authorityReceipt != nil {
                let materialized = await materializeQuickCapture(command, context: context, committedResult: replayed)
                return await persistFinalMaterialization(command: command, result: materialized, at: context.now)
            }
            if command.kind.isTimeMutation, authorityReceipt != nil {
                let materialized = await materializeTime(command, context: context, committedResult: replayed)
                return await persistFinalMaterialization(command: command, result: materialized, at: context.now)
            }
            return replayed
        case .commandRecordWithoutRuntimeEvent(let record):
            return replayAdapter.commandRecordWithoutRuntimeEventResult(for: command, record: record)
        case .sqliteDiagnosticWithoutAuthority(let projection):
            return replayAdapter.sqliteDiagnosticWithoutAuthorityResult(for: command, projection: projection)
        case .lookupUnavailable:
            return replayAdapter.lookupUnavailableResult(for: command)
        case .noRecord:
            break
        }

        let validation = validate(command)
        let compilation = compiler.compile(command, context: context, validation: validation)
        let journalReceipt: CommandJournalAppendReceipt
        switch await appendCommandEnvelope(compilation) {
        case .appended(let receipt):
            journalReceipt = receipt
        case .failed(let error):
            let result = commandJournalFailureResult(
                command: command,
                compilation: compilation,
                error: error
            )
            return await persistExecution(
                command: command,
                result: result,
                at: context.now,
                compilation: compilation,
                journalReceipt: nil
            )
        }

        guard validation == .valid else {
            let result = blockedResult(for: validation, command: command)
                .mergingMetadata(compilation.resultMetadata)
                .mergingMetadata(journalReceipt.resultMetadata)
            return await persistExecution(
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
            return await persistExecution(
                command: command,
                result: result,
                at: context.now,
                compilation: compilation,
                journalReceipt: journalReceipt
            )
        }

        let result: AmbitionsCommandExecutionResult

        switch command.kind {
        case .openDestination:
            guard let destination = command.target.destination else {
                result = blockedResult(for: .needsMissingTarget, command: command)
                break
            }
            result = AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Open destination command validated.",
                route: destination,
                target: command.target,
                recommendationExplanationIDs: command.relations.recommendationExplanationIDs
            )
        case .quickCapture:
            result = await executeQuickCapture(command, context: context)
        case .routeCommitment:
            result = await executeRouteCommitment(command, context: context)
        case .markWaiting:
            result = await executeCaptureRoute(command, context: context, kind: .waitingItem, route: .waiting)
        case .archiveItem:
            result = await executeArchive(command, context: context)
        case .attachToGoal:
            result = await executeAttachToGoal(command, context: context)
        case .setDeadline:
            result = await executeDeadlineChange(command, context: context)
        case .setPriority, .setUrgency:
            result = await executePriorityChange(command, context: context)
        case .scheduleItem where command.payload.metadata["calendarWriteIntent"] == "true":
            result = await executeConfirmedCalendarWriteIntent(command, context: context)
        case .createTimeItem, .scheduleItem:
            result = await executePlanSeedRepresentation(command, context: context)
        case .placeStepInTime, .protectTimeWindow, .correctTimeWindow:
            result = await executeTimeCommand(command)
        default:
            result = AmbitionsCommandExecutionResult(
                status: .unsupported,
                summary: "\(command.kind.rawValue) is represented by the shared command model, but its owning foundation is not executable in this build.",
                target: command.target,
                recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
                metadata: [
                    "validation": validation.rawValue,
                    "blockedBy": "owning_system_not_implemented"
                ]
            )
        }

        let commandsResult = result
            .mergingMetadata(compilation.resultMetadata)
            .mergingMetadata(journalReceipt.resultMetadata)
        let persistedResult = await persistExecution(
            command: command,
            result: commandsResult,
            at: context.now,
            compilation: compilation,
            journalReceipt: journalReceipt
        )
        if command.kind == .quickCapture,
           persistedResult.status == .succeeded,
           RuntimeTransactionCommitPolicy.hasCommittedEvidence(persistedResult) {
            let materialized = await materializeQuickCapture(command, context: context, committedResult: persistedResult)
            return await persistFinalMaterialization(command: command, result: materialized, at: context.now)
        }
        if command.kind.isTimeMutation,
           persistedResult.status == .succeeded,
           RuntimeTransactionCommitPolicy.hasCommittedEvidence(persistedResult) {
            let materialized = await materializeTime(command, context: context, committedResult: persistedResult)
            return await persistFinalMaterialization(command: command, result: materialized, at: context.now)
        }
        return persistedResult
    }

}
