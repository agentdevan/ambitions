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
        eventLedger: (any EventLedgerRepository)? = nil,
        commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)? = nil,
        runtimeEvents: (any RuntimeEventStore)? = InMemoryRuntimeEventStore(),
        commandJournal: any CommandJournal = InMemoryCommandJournal(),
        runtimeTransactionIdempotencyStore: RuntimeIdempotencyStore = RuntimeIdempotencyStore(),
        smartAttachmentService: (any SmartAttachmentRouting)? = DefaultSmartAttachmentService(),
        validator: AmbitionsCommandValidator = AmbitionsCommandValidator(),
        runtimeValidator: RuntimeValidator? = nil,
        compiler: CommandCompiler? = nil,
        receiptFactory: CommandReceiptFactory = CommandReceiptFactory(),
        scheduleStoreFileURL: URL? = nil
    ) {
        self.captureService = captureService
        self.eventLedger = eventLedger
        self.commandExecutionRecords = commandExecutionRecords
        self.runtimeEvents = runtimeEvents
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
        let replayAdapter = CommandReplayAdapter(commandExecutionRecords: commandExecutionRecords)
        switch await replayAdapter.lookup(command) {
        case .record(let replayRecord):
            return replayAdapter.replayResult(for: command, record: replayRecord)
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

        let commandSpineResult = result
            .mergingMetadata(compilation.resultMetadata)
            .mergingMetadata(journalReceipt.resultMetadata)
        return await persistExecution(
            command: command,
            result: commandSpineResult,
            at: context.now,
            compilation: compilation,
            journalReceipt: journalReceipt
        )
    }

}
