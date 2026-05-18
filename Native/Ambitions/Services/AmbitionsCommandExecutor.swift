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
    private let captureService: (any CaptureServicing)?
    private let eventLedger: (any EventLedgerRepository)?
    private let commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?
    private let smartAttachmentService: (any SmartAttachmentRouting)?
    private let validator: AmbitionsCommandValidator

    init(
        captureService: (any CaptureServicing)? = nil,
        eventLedger: (any EventLedgerRepository)? = nil,
        commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)? = nil,
        smartAttachmentService: (any SmartAttachmentRouting)? = DefaultSmartAttachmentService(),
        validator: AmbitionsCommandValidator = AmbitionsCommandValidator()
    ) {
        self.captureService = captureService
        self.eventLedger = eventLedger
        self.commandExecutionRecords = commandExecutionRecords
        self.smartAttachmentService = smartAttachmentService
        self.validator = validator
    }

    func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        validator.validate(command)
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
            result = AmbitionsCommandExecutionResult(
                status: .unsupported,
                summary: "Calendar write intents require the Time-owned calendar block writer and explicit user confirmation; this command path does not write calendar data.",
                target: command.target,
                recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
                metadata: [
                    "blockedBy": "plan_calendar_writer_required",
                    "calendarWriteIntent": "true"
                ]
            )
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

    private func persistExecution(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        at timestamp: Date
    ) async {
        guard let commandExecutionRecords else { return }
        let record = AmbitionsCommandExecutionRecord(
            command: command,
            result: result,
            recordedAt: DomainTimestamp.string(from: timestamp)
        )

        try? await commandExecutionRecords.append(record)
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

private extension AmbitionsCommandExecutor {
    func executeQuickCapture(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        guard let captureService else {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Quick capture is valid, but capture persistence is unavailable in this execution context.",
                target: command.target,
                metadata: ["blockedBy": "missing_capture_service"]
            )
        }
        guard let text = command.payload.primaryText else {
            return blockedResult(for: .invalid, command: command)
        }

        do {
            let smartAttachment = smartAttachmentService?.route(
                SmartAttachmentInput(
                    rawText: text,
                    sourceContext: SmartAttachmentSourceContext(
                        sourceType: captureSourceType(for: command.source),
                        sourceSurface: context.sourceSurface,
                        commandID: command.id
                    )
                ),
                candidates: [],
                maxCandidateCount: 5
            )
            let capture = try await captureService.createCapture(
                CreateCaptureRequest(
                    rawText: text,
                    sourceType: captureSourceType(for: command.source),
                    linkedGoalID: command.target.goalID,
                    triage: nil,
                    revisitAfter: nil,
                    kind: captureKind(for: command.payload.commitmentKind) ?? smartAttachment?.captureKind,
                    route: route(for: command.payload.destinationRoute) ?? smartAttachment?.captureRoute,
                    triageStatus: smartAttachment?.triageStatus,
                    commitmentKind: command.payload.commitmentKind,
                    deadlineText: command.payload.deadlineText ?? command.payload.dueText,
                    deadlineKind: command.payload.deadlineText == nil && command.payload.dueText == nil ? .none : .hard,
                    contextLensHint: command.payload.contextLens,
                    priorityHints: CapturePriorityHints(commandHints: command.payload.priorityHints),
                    assumptionSummary: smartAttachment?.captureAssumptionSummary
                ),
                now: context.now
            )
            var eventIDs: [String] = []
            var metadata: [String: String] = [
                "captureID": capture.id,
                "commandKind": command.kind.rawValue,
                "commandSource": command.source.rawValue
            ]
            if let smartAttachment {
                metadata["smartAttachmentResult"] = smartAttachment.resultState.rawValue
                metadata["smartAttachmentConfidence"] = smartAttachment.confidence.rawValue
                metadata["smartAttachmentReceipt"] = smartAttachment.receiptLine
                metadata["smartAttachmentRoute"] = smartAttachment.selectedCandidate?.target.routeType.rawValue
                metadata["smartAttachmentDestination"] = smartAttachment.selectedCandidate?.target.destinationKind.rawValue
            }

            if context.allowsEventLedgerEmission, let eventLedger {
                let event = EventLedgerEntry.commandCaptureCreated(
                    command: command,
                    capture: capture,
                    occurredAt: DomainTimestamp.string(from: context.now)
                )
                do {
                    try await eventLedger.append(event)
                    eventIDs = [event.id]
                } catch {
                    metadata["eventLedgerEmission"] = "failed"
                }
            }

            return AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: smartAttachment?.receiptLine ?? "Saved to Needs a Place",
                route: .captureInbox,
                target: AmbitionsCommandTarget(
                    goalID: command.target.goalID,
                    captureID: capture.id,
                    destination: .captureInbox
                ),
                eventLedgerEntryIDs: eventIDs,
                recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
                metadata: metadata
            )
        } catch {
            return AmbitionsCommandExecutionResult(
                status: .failed,
                summary: error.localizedDescription,
                target: command.target,
                metadata: ["error": String(describing: error)]
            )
        }
    }

    func executeRouteCommitment(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        guard let captureService else {
            return AmbitionsCommandExecutionResult(status: .blocked, summary: "Commitment routing is unavailable without capture persistence.", target: command.target, metadata: ["blockedBy": "missing_capture_service"])
        }

        do {
            let capture: Capture?
            if let captureID = command.target.captureID {
                capture = try await captureService.markAsOneTimeCommitment(
                    id: captureID,
                    deadlineText: command.payload.deadlineText ?? command.payload.dueText,
                    contextLensHint: command.payload.contextLens,
                    now: context.now
                )
            } else if let text = command.payload.primaryText {
                capture = try await captureService.createCapture(
                    CreateCaptureRequest(
                        rawText: text,
                        sourceType: captureSourceType(for: command.source),
                        kind: .oneTimeCommitment,
                        route: .timeSeed,
                        commitmentKind: .oneTime,
                        deadlineText: command.payload.deadlineText ?? command.payload.dueText,
                        deadlineKind: command.payload.deadlineText == nil && command.payload.dueText == nil ? .none : .hard,
                        contextLensHint: command.payload.contextLens,
                        priorityHints: CapturePriorityHints(commandHints: command.payload.priorityHints),
                        assumptionSummary: "I treated this as a one-time commitment."
                    ),
                    now: context.now
                )
            } else {
                return blockedResult(for: .invalid, command: command)
            }

            guard let capture else {
                return AmbitionsCommandExecutionResult(status: .blocked, summary: "Capture not found for commitment routing.", target: command.target, metadata: ["blockedBy": "missing_capture"])
            }
            return captureResult(command: command, capture: capture, summary: "Commitment represented as a Time-owned planning idea. Scheduling remains deferred to compatibility planning.")
        } catch {
            return AmbitionsCommandExecutionResult(status: .failed, summary: error.localizedDescription, target: command.target, metadata: ["error": String(describing: error)])
        }
    }

    func executeCaptureRoute(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext,
        kind: CaptureKind,
        route: CaptureRoute
    ) async -> AmbitionsCommandExecutionResult {
        guard let captureService else {
            return AmbitionsCommandExecutionResult(status: .blocked, summary: "Capture routing is unavailable without capture persistence.", target: command.target, metadata: ["blockedBy": "missing_capture_service"])
        }
        guard let captureID = command.target.captureID else {
            return blockedResult(for: .needsMissingTarget, command: command)
        }

        do {
            let capture = try await captureService.updateCaptureRoute(
                CaptureRouteUpdateRequest(
                    id: captureID,
                    kind: kind,
                    route: route,
                    deadlineText: command.payload.deadlineText ?? command.payload.dueText,
                    contextLensHint: command.payload.contextLens,
                    priorityHints: CapturePriorityHints(commandHints: command.payload.priorityHints),
                    waitingMetadata: route == .waiting ? CaptureWaitingMetadata(blockedBy: command.payload.notes, waitingOn: command.payload.title) : nil
                ),
                now: context.now
            )
            guard let capture else {
                return AmbitionsCommandExecutionResult(status: .blocked, summary: "Capture not found for routing.", target: command.target, metadata: ["blockedBy": "missing_capture"])
            }
            return captureResult(command: command, capture: capture, summary: "Capture route updated.")
        } catch {
            return AmbitionsCommandExecutionResult(status: .failed, summary: error.localizedDescription, target: command.target, metadata: ["error": String(describing: error)])
        }
    }

    func executeArchive(_ command: AmbitionsCommand, context: CommandExecutionContext) async -> AmbitionsCommandExecutionResult {
        guard let captureService else {
            return AmbitionsCommandExecutionResult(status: .blocked, summary: "Archive is unavailable without capture persistence.", target: command.target, metadata: ["blockedBy": "missing_capture_service"])
        }
        guard let captureID = command.target.captureID else {
            return blockedResult(for: .needsMissingTarget, command: command)
        }

        do {
            guard let capture = try await captureService.markCaptureArchived(id: captureID, now: context.now) else {
                return AmbitionsCommandExecutionResult(status: .blocked, summary: "Capture not found for archive.", target: command.target, metadata: ["blockedBy": "missing_capture"])
            }
            return captureResult(command: command, capture: capture, summary: "Capture archived.")
        } catch {
            return AmbitionsCommandExecutionResult(status: .failed, summary: error.localizedDescription, target: command.target, metadata: ["error": String(describing: error)])
        }
    }

    func executeAttachToGoal(_ command: AmbitionsCommand, context: CommandExecutionContext) async -> AmbitionsCommandExecutionResult {
        guard let captureService else {
            return AmbitionsCommandExecutionResult(status: .blocked, summary: "Goal attachment is unavailable without capture persistence.", target: command.target, metadata: ["blockedBy": "missing_capture_service"])
        }
        guard let captureID = command.target.captureID, let goalID = command.target.goalID else {
            return blockedResult(for: .needsMissingTarget, command: command)
        }

        do {
            guard let binding = try await captureService.attachCaptureToGoal(AttachCaptureToGoalRequest(captureID: captureID, goalID: goalID), now: context.now) else {
                return AmbitionsCommandExecutionResult(status: .blocked, summary: "Capture not found for goal attachment.", target: command.target, metadata: ["blockedBy": "missing_capture"])
            }
            return captureResult(command: command, capture: binding.capture, summary: "Capture attached to goal.")
        } catch {
            return AmbitionsCommandExecutionResult(status: .failed, summary: error.localizedDescription, target: command.target, metadata: ["error": String(describing: error)])
        }
    }

    func executeDeadlineChange(_ command: AmbitionsCommand, context: CommandExecutionContext) async -> AmbitionsCommandExecutionResult {
        guard command.target.captureID != nil else {
            return AmbitionsCommandExecutionResult(status: .unsupported, summary: "Deadline changes are executable for captures only in this build.", target: command.target, metadata: ["blockedBy": "owning_system_not_implemented"])
        }
        return await executeCaptureRoute(command, context: context, kind: command.payload.commitmentKind == .oneTime ? .deadlineTask : .raw, route: .timeSeed)
    }

    func executePriorityChange(_ command: AmbitionsCommand, context: CommandExecutionContext) async -> AmbitionsCommandExecutionResult {
        guard command.target.captureID != nil else {
            return AmbitionsCommandExecutionResult(status: .unsupported, summary: "Priority changes are executable for captures only in this build.", target: command.target, metadata: ["blockedBy": "owning_system_not_implemented"])
        }
        return await executeCaptureRoute(command, context: context, kind: .raw, route: .captureInbox)
    }

    func executePlanSeedRepresentation(_ command: AmbitionsCommand, context: CommandExecutionContext) async -> AmbitionsCommandExecutionResult {
        guard let captureService else {
            return AmbitionsCommandExecutionResult(status: .blocked, summary: "Time-owned planning representation is unavailable without capture persistence.", target: command.target, metadata: ["blockedBy": "missing_capture_service"])
        }
        guard let captureID = command.target.captureID else {
            return AmbitionsCommandExecutionResult(status: .unsupported, summary: "Creating new time items is represented through Capture 2.0 only when a capture target exists.", target: command.target, metadata: ["blockedBy": "plan_2_not_implemented"])
        }
        do {
            guard let capture = try await captureService.routeToTimeSeed(id: captureID, now: context.now) else {
                return AmbitionsCommandExecutionResult(status: .blocked, summary: "Capture not found for time-owned planning routing.", target: command.target, metadata: ["blockedBy": "missing_capture"])
            }
            return captureResult(command: command, capture: capture, summary: "Capture represented as a Time-owned planning idea. Scheduling is not implemented in this build.")
        } catch {
            return AmbitionsCommandExecutionResult(status: .failed, summary: error.localizedDescription, target: command.target, metadata: ["error": String(describing: error)])
        }
    }

    func captureResult(command: AmbitionsCommand, capture: Capture, summary: String) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: summary,
            route: .captureInbox,
            target: AmbitionsCommandTarget(goalID: capture.linkedGoalID ?? command.target.goalID, captureID: capture.id, destination: .captureInbox),
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs + capture.recommendationExplanationIDs,
            metadata: [
                "captureID": capture.id,
                "captureKind": capture.kind.rawValue,
                "captureRoute": capture.route.rawValue
            ]
        )
    }

    func blockedResult(
        for validation: AmbitionsCommandValidationState,
        command: AmbitionsCommand
    ) -> AmbitionsCommandExecutionResult {
        let status: AmbitionsCommandExecutionStatus
        switch validation {
        case .valid:
            status = .noOp
        case .invalid:
            status = .failed
        case .needsConfirmation:
            status = .requiresConfirmation
        case .needsMissingTarget:
            status = .blocked
        case .unsupportedInThisBuild:
            status = .unsupported
        case .blockedByMissingFoundation:
            status = .blocked
        }

        return AmbitionsCommandExecutionResult(
            status: status,
            summary: summary(for: validation),
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: ["validation": validation.rawValue]
        )
    }

    func summary(for validation: AmbitionsCommandValidationState) -> String {
        switch validation {
        case .valid:
            return "Command is valid."
        case .invalid:
            return "Command payload is invalid."
        case .needsConfirmation:
            return "Command needs confirmation before it can execute."
        case .needsMissingTarget:
            return "Command is missing the target needed for safe execution."
        case .unsupportedInThisBuild:
            return "Command is unsupported in this build."
        case .blockedByMissingFoundation:
            return "Command is blocked by missing foundation work."
        }
    }

    func captureSourceType(for source: AmbitionsCommandSource) -> CaptureSourceType {
        switch source {
        case .today:
            return .todayQuickCapture
        case .appIntent:
            return .appIntent
        case .notification:
            return .notification
        default:
            return .todayQuickCapture
        }
    }

    func captureKind(for commitmentKind: NowCommitmentKind?) -> CaptureKind? {
        switch commitmentKind {
        case .oneTime:
            return .oneTimeCommitment
        case .goalSupporting:
            return .goalSupportingTask
        case .waiting:
            return .waitingItem
        case .optionalSomeday:
            return .optionalSomeday
        case .recurring, .scheduledBlock, nil:
            return nil
        }
    }

    func route(for destinationRoute: String?) -> CaptureRoute? {
        guard let destinationRoute else { return nil }
        switch destinationRoute {
        case "plan", "time", CaptureRoute.timeSeed.rawValue:
            return .timeSeed
        case "goal", CaptureRoute.goalSeed.rawValue:
            return .goalSeed
        case CaptureRoute.goalAttachment.rawValue:
            return .goalAttachment
        case CaptureRoute.waiting.rawValue:
            return .waiting
        case CaptureRoute.optionalSomeday.rawValue:
            return .optionalSomeday
        case CaptureRoute.archive.rawValue:
            return .archive
        default:
            return .captureInbox
        }
    }
}

private extension CapturePriorityHints {
    init(commandHints: AmbitionsCommandPriorityHints) {
        self.init(
            importance: commandHints.importance,
            urgency: commandHints.urgency,
            consequence: commandHints.consequence,
            deadline: commandHints.deadline,
            effort: commandHints.effort,
            contextFit: commandHints.contextFit,
            goalSupporting: commandHints.goalRelationship != nil
        )
    }
}

private extension EventLedgerEntry {
    static func commandCaptureCreated(
        command: AmbitionsCommand,
        capture: Capture,
        occurredAt: String
    ) -> EventLedgerEntry {
        EventLedgerEntry(
            id: "ledger.command.\(command.id)",
            kind: .captureCreated,
            occurredAt: occurredAt,
            source: eventSource(for: command.source),
            goalID: command.target.goalID,
            captureID: capture.id,
            title: "Capture created",
            summary: nil,
            semanticState: command.kind.rawValue,
            tone: .neutral,
            trust: EventLedgerTrustMetadata(isUserConfirmed: command.actor == .user),
            evidenceReferences: [
                EventLedgerEvidenceReference(
                    id: command.id,
                    kind: .externalCommand,
                    occurredAt: command.requestedAt,
                    summary: command.kind.rawValue
                ),
                EventLedgerEvidenceReference(
                    id: capture.id,
                    kind: .capture,
                    occurredAt: capture.createdAt,
                    summary: "quick_capture"
                )
            ],
            metadata: [
                "commandKind": command.kind.rawValue,
                "commandSource": command.source.rawValue,
                "sourceSurface": command.sourceSurface ?? ""
            ].filter { $0.value.isEmpty == false },
            payload: [
                "captureID": capture.id,
                "contextLens": command.payload.contextLens?.rawValue ?? "",
                "commitmentKind": command.payload.commitmentKind?.rawValue ?? ""
            ].filter { $0.value.isEmpty == false },
            privacy: .privateUserText
        )
    }

    static func eventSource(for source: AmbitionsCommandSource) -> EventLedgerSource {
        switch source {
        case .today:
            return .today
        case .goals, .goalDetail:
            return .goals
        case .capture:
            return .capture
        case .time:
            return .plan
        case .you:
            return .you
        case .reviews:
            return .you
        case .widget, .liveActivity, .appIntent, .notification, .deepLink, .system:
            return .system
        }
    }
}
