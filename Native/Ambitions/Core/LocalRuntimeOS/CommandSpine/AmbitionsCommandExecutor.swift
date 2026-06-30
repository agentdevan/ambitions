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
    let smartAttachmentService: (any SmartAttachmentRouting)?
    let validator: AmbitionsCommandValidator
    let runtimeValidator: RuntimeValidator
    let scheduleStoreFileURL: URL?

    init(
        captureService: (any CaptureServicing)? = nil,
        eventLedger: (any EventLedgerRepository)? = nil,
        commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)? = nil,
        runtimeEvents: (any RuntimeEventStore)? = nil,
        smartAttachmentService: (any SmartAttachmentRouting)? = DefaultSmartAttachmentService(),
        validator: AmbitionsCommandValidator = AmbitionsCommandValidator(),
        runtimeValidator: RuntimeValidator? = nil,
        scheduleStoreFileURL: URL? = nil
    ) {
        self.captureService = captureService
        self.eventLedger = eventLedger
        self.commandExecutionRecords = commandExecutionRecords
        self.runtimeEvents = runtimeEvents
        self.smartAttachmentService = smartAttachmentService
        self.validator = validator
        self.runtimeValidator = runtimeValidator ?? RuntimeValidator(commandValidator: validator)
        self.scheduleStoreFileURL = scheduleStoreFileURL
    }

    func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        runtimeValidator.validate(command).validationState
    }

    func execute(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        switch await fetchExistingExecutionRecord(for: command) {
        case .record(let replayRecord):
            return replayResult(for: command, record: replayRecord)
        case .lookupUnavailable:
            return replayLookupUnavailableResult(for: command)
        case .noRecord:
            break
        }

        let validation = validate(command)
        guard validation == .valid else {
            let result = blockedResult(for: validation, command: command)
            await persistExecution(command: command, result: result, at: context.now)
            return result
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

        await persistExecution(command: command, result: result, at: context.now)
        return result
    }

    func persistExecution(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        at timestamp: Date
    ) async {
        let recordedAt = DomainTimestamp.string(from: timestamp)
        let record = AmbitionsCommandExecutionRecord(
            command: command,
            result: result,
            recordedAt: recordedAt
        )

        try? await commandExecutionRecords?.append(record)
        await appendRuntimeEvent(command: command, result: result, recordedAt: recordedAt, commandRecordID: record.id)
    }

    private func appendRuntimeEvent(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        recordedAt: String,
        commandRecordID: String
    ) async {
        guard let runtimeEvents else { return }
        let event = RuntimeEvent.commandExecution(
            command: command,
            result: result,
            recordedAt: recordedAt,
            commandRecordID: commandRecordID
        )
        _ = try? await runtimeEvents.append(event)
    }

    func fetchExistingExecutionRecord(
        for command: AmbitionsCommand
    ) async -> LedgerReplayLookupResult {
        guard let commandExecutionRecords else { return .noRecord }
        do {
            guard let record = try await commandExecutionRecords.fetchRecord(commandID: command.id) else {
                return .noRecord
            }
            return .record(record)
        } catch {
            return .lookupUnavailable
        }
    }

    func replayResult(
        for command: AmbitionsCommand,
        record: AmbitionsCommandExecutionRecord
    ) -> AmbitionsCommandExecutionResult {
        let outcome = LedgerReplayOutcome(
            idempotencyKey: LedgerIdempotencyKey(command.id),
            decision: .replayExistingReceipt,
            doubleApplyDisposition: .skipDuplicateMutation,
            receiptSummary: record.result.summary
        )
        var metadata = record.result.metadata
        metadata["ledgerRecordKind"] = LedgerRecordTaxonomyKind.receipt.rawValue
        metadata["replayDecision"] = outcome.decision.rawValue
        metadata["idempotencyKey"] = outcome.idempotencyKey.rawValue
        metadata["doubleApplyDisposition"] = outcome.doubleApplyDisposition.rawValue
        metadata["replayedReceiptSummary"] = outcome.receiptSummary
        metadata["replayedRecordID"] = record.id
        metadata["replayedRecordedAt"] = record.recordedAt

        return AmbitionsCommandExecutionResult(
            status: record.result.status,
            summary: "Replayed existing command receipt: \(record.result.summary)",
            route: record.result.route,
            target: record.result.target ?? command.target,
            eventLedgerEntryIDs: record.result.eventLedgerEntryIDs,
            recommendationExplanationIDs: record.result.recommendationExplanationIDs,
            metadata: metadata
        )
    }

    func executeConfirmedCalendarWriteIntent(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        guard command.payload.metadata["calendarWriteIntent"] == "true" else {
            return blockedResult(for: .needsMissingTarget, command: command)
        }

        let intent = scheduleMutationIntent(for: command)
        guard let intent else {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Calendar write intent is confirmed but missing or invalid schedule intent metadata.",
                target: command.target,
                recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
                metadata: [
                    "blockedBy": "calendar_write_metadata_missing",
                    "calendarWriteIntent": "true"
                ]
            )
        }

        let destinationStepID = command.target.stepID ?? command.payload.metadata["destinationStepID"]
        let destinationStepTitle = command.payload.metadata["destinationStepTitle"]
        let originalBlockID = command.payload.metadata["originalBlockID"] ?? command.target.timeID
        let displacedDisposition = command.payload.metadata["displacedDisposition"] ?? "not_displaced"
        let destinationStepPressure = command.payload.metadata["destinationStepPressure"]
        let originStepPressure = command.payload.metadata["originStepPressure"]
        let lifeshapeImpact = command.payload.metadata["lifeshapeImpact"] ?? "recalculated_before_commit"

        let scheduleBlock = ScheduledAmbitionsBlock(
            id: intent.blockID,
            title: intent.title,
            start: intent.start,
            end: intent.end,
            contextLens: intent.contextLens,
            relatedGoalID: intent.relatedGoalID ?? command.target.goalID,
            relatedCaptureID: intent.relatedCaptureID ?? command.target.captureID,
            isUserConfirmed: true
        )

        let sourceRecordID = scheduleBlock.localScheduleSourceRecordID
        do {
            let scheduleRepository = FileLocalScheduleBlockRepository(fileURL: scheduleStoreURL())
            _ = try await scheduleRepository.upsertBlock(scheduleBlock)
        } catch {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Calendar write intent could not be written locally.",
                target: command.target,
                recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
                metadata: [
                    "blockedBy": "calendar_write_store_error",
                    "calendarWriteIntent": "true",
                    "error": String(describing: error)
                ]
            )
        }

        var eventLedgerEntryIDs: [String] = []
        let scheduleReceiptID = scheduleBlock.localScheduleReceiptID(action: "save")
        let replayTraceID = scheduleBlock.localScheduleReplayTraceID(action: "save")
        if context.allowsEventLedgerEmission, let eventLedger {
            let event = EventLedgerEntry(
                id: "ledger.schedule.mutation.\(command.id)",
                kind: .planScheduled,
                occurredAt: DomainTimestamp.string(from: context.now),
                source: .plan,
                goalID: command.target.goalID,
                captureID: command.target.captureID,
                planID: command.target.timeID,
                title: "Schedule mutation recorded",
                summary: "Time mutation was confirmed and persisted locally.",
                semanticState: command.kind.rawValue,
                tone: .neutral,
                trust: EventLedgerTrustMetadata(
                    isUserConfirmed: true,
                    requiresReview: false
                ),
                evidenceReferences: [
                    EventLedgerEvidenceReference(
                        id: scheduleBlock.id,
                        kind: .plan,
                        occurredAt: DomainTimestamp.string(from: context.now),
                        summary: "schedule block mutation"
                    )
                ],
                metadata: [
                    "sourceRecordID": sourceRecordID,
                    "receiptID": scheduleReceiptID,
                    "replayTraceID": replayTraceID
                ].merging(intent.metadata, uniquingKeysWith: { _, new in new }),
                payload: [
                    "receipt": scheduleReceiptID,
                    "replayTrace": replayTraceID,
                    "destinationStepID": destinationStepID ?? "",
                    "originalBlockID": originalBlockID ?? "",
                    "displacedDisposition": displacedDisposition,
                    "start": DomainTimestamp.string(from: intent.start),
                    "end": DomainTimestamp.string(from: intent.end),
                    "lifeshapeImpact": lifeshapeImpact
                ].filter { $0.value.isEmpty == false }
            )
            do {
                try await eventLedger.append(event)
                eventLedgerEntryIDs = [event.id]
            } catch {
                // Preserve local safety contract: no mutation without local receipt,
                // but event projection is best-effort when storage is unavailable.
            }
        }

        return AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Schedule mutation was written locally after confirmation.",
            target: AmbitionsCommandTarget(
                goalID: command.target.goalID,
                captureID: command.target.captureID,
                timeID: intent.blockID,
                stepID: destinationStepID,
                destination: .time
            ),
            eventLedgerEntryIDs: eventLedgerEntryIDs,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "commandID": command.id,
                "calendarWriteIntent": "true",
                "approvalState": "confirmed",
                "userConfirmed": command.payload.metadata["userConfirmed"] ?? "true",
                "sourceRecordID": sourceRecordID,
                "receiptID": scheduleReceiptID,
                "replayTraceID": replayTraceID,
                "approvedDurationMinutes": String(intent.approvedDurationMinutes),
                "originalBlockID": originalBlockID ?? "",
                "destinationStepID": destinationStepID ?? "",
                "destinationStepTitle": destinationStepTitle ?? "",
                "destinationStepPressure": destinationStepPressure ?? "",
                "originStepPressure": originStepPressure ?? "",
                "displacedDisposition": displacedDisposition,
                "lifeshapeImpact": lifeshapeImpact
            ].merging(intent.metadata, uniquingKeysWith: { _, new in new })
        )
    }

    func replayLookupUnavailableResult(
        for command: AmbitionsCommand
    ) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: .blocked,
            summary: "Command replay lookup could not be verified, so Ambitions skipped the mutation to avoid double apply.",
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "replayDecision": LedgerReplayDecision.lookupUnavailable.rawValue,
                "idempotencyKey": LedgerIdempotencyKey(command.id).rawValue,
                "doubleApplyDisposition": LedgerDoubleApplyDisposition.skipUnverifiedMutation.rawValue,
                "blockedBy": "command_replay_lookup_unavailable"
            ]
        )
    }
}

enum LedgerReplayLookupResult: Sendable, Equatable {
    case noRecord
    case record(AmbitionsCommandExecutionRecord)
    case lookupUnavailable
}
