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
    private let validator: AmbitionsCommandValidator

    init(
        captureService: (any CaptureServicing)? = nil,
        eventLedger: (any EventLedgerRepository)? = nil,
        validator: AmbitionsCommandValidator = AmbitionsCommandValidator()
    ) {
        self.captureService = captureService
        self.eventLedger = eventLedger
        self.validator = validator
    }

    func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        validator.validate(command)
    }

    func execute(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        let validation = validate(command)
        guard validation == .valid else {
            return blockedResult(for: validation, command: command)
        }

        switch command.kind {
        case .openDestination:
            guard let destination = command.target.destination else {
                return blockedResult(for: .needsMissingTarget, command: command)
            }
            return AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Open destination command validated.",
                route: destination,
                target: command.target,
                recommendationExplanationIDs: command.relations.recommendationExplanationIDs
            )
        case .quickCapture:
            return await executeQuickCapture(command, context: context)
        default:
            return AmbitionsCommandExecutionResult(
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
    }
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
            let capture = try await captureService.createCapture(
                CreateCaptureRequest(
                    rawText: text,
                    sourceType: captureSourceType(for: command.source),
                    linkedGoalID: command.target.goalID,
                    triage: nil,
                    revisitAfter: nil
                ),
                now: context.now
            )
            var eventIDs: [String] = []
            var metadata: [String: String] = [
                "captureID": capture.id,
                "commandKind": command.kind.rawValue,
                "commandSource": command.source.rawValue
            ]

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
                summary: "Capture saved through the shared command pipeline.",
                route: .capturesInbox,
                target: AmbitionsCommandTarget(
                    goalID: command.target.goalID,
                    captureID: capture.id,
                    destination: .capturesInbox
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
        case .plan:
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
