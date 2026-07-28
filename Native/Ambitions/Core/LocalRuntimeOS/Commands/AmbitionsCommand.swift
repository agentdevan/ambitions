import Foundation

let ambitionsCommandSchemaVersion = "ambitions_command.native.v1"

struct AmbitionsCommandPayload: Codable, Sendable, Equatable, Hashable {
    let rawText: String?
    let title: String?
    let notes: String?
    let dueText: String?
    let deadlineText: String?
    let contextLens: NowContextLens?
    let commitmentKind: NowCommitmentKind?
    let priorityHints: AmbitionsCommandPriorityHints
    let goalRelationship: NowGoalPressureKind?
    let destinationRoute: String?
    let explanationID: String?
    let metadata: [String: String]

    init(
        rawText: String? = nil,
        title: String? = nil,
        notes: String? = nil,
        dueText: String? = nil,
        deadlineText: String? = nil,
        contextLens: NowContextLens? = nil,
        commitmentKind: NowCommitmentKind? = nil,
        priorityHints: AmbitionsCommandPriorityHints = AmbitionsCommandPriorityHints(),
        goalRelationship: NowGoalPressureKind? = nil,
        destinationRoute: String? = nil,
        explanationID: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.rawText = Self.trimmed(rawText)
        self.title = Self.trimmed(title)
        self.notes = Self.trimmed(notes)
        self.dueText = Self.trimmed(dueText)
        self.deadlineText = Self.trimmed(deadlineText)
        self.contextLens = contextLens
        self.commitmentKind = commitmentKind
        self.priorityHints = priorityHints
        self.goalRelationship = goalRelationship
        self.destinationRoute = Self.trimmed(destinationRoute)
        self.explanationID = explanationID
        self.metadata = metadata.filter { $0.key.isEmpty == false && $0.value.isEmpty == false }
    }

    var primaryText: String? {
        rawText ?? title
    }

    private static func trimmed(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

struct AmbitionsCommand: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let source: AmbitionsCommandSource
    let validationState: AmbitionsCommandValidationState
    let executionStatus: AmbitionsCommandExecutionStatus
    let result: AmbitionsCommandExecutionResult?
    let createdAt: String
    let requestedAt: String
    let actor: AmbitionsCommandActor
    let sourceSurface: String?
    let relations: AmbitionsCommandRelations
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification
    let schemaVersion: String
    let expectedRevision: RuntimeExpectedRevision
    let idempotencyKey: CommandIdempotencyKey
    private(set) var typedPayload: RuntimeCommandPayload

    var operation: RuntimeCommandOperation { typedPayload.operation }
    var target: AmbitionsCommandTarget { typedPayload.target }
    var content: RuntimeCommandContent { typedPayload.content }

    init(
        id: String,
        source: AmbitionsCommandSource,
        typedPayload: RuntimeCommandPayload,
        expectedRevision: RuntimeExpectedRevision = .absent,
        idempotencyKey: CommandIdempotencyKey? = nil,
        validationState: AmbitionsCommandValidationState = .valid,
        executionStatus: AmbitionsCommandExecutionStatus = .pending,
        result: AmbitionsCommandExecutionResult? = nil,
        createdAt: String,
        requestedAt: String? = nil,
        actor: AmbitionsCommandActor = .user,
        sourceSurface: String? = nil,
        relations: AmbitionsCommandRelations = AmbitionsCommandRelations(),
        localOnly: Bool = true,
        privacy: EventLedgerPrivacyClassification = .standard,
        schemaVersion: String = ambitionsCommandSchemaVersion
    ) {
        self.id = id
        self.source = source
        self.validationState = validationState
        self.executionStatus = executionStatus
        self.result = result
        self.createdAt = createdAt
        self.requestedAt = requestedAt ?? createdAt
        self.actor = actor
        self.sourceSurface = sourceSurface
        self.relations = relations
        self.localOnly = localOnly
        self.privacy = privacy
        self.schemaVersion = schemaVersion
        self.expectedRevision = expectedRevision
        self.idempotencyKey = idempotencyKey ?? CommandIdempotencyKey(id)
        self.typedPayload = typedPayload
    }

    init(from decoder: Decoder) throws {
        let envelope = try RuntimeCommandV2Envelope(from: decoder)
        guard envelope.schemaVersion == runtimeCommandSchemaVersion else {
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Unsupported runtime command version.")
            )
        }
        self = envelope.command
    }

    func encode(to encoder: Encoder) throws {
        try RuntimeCommandV2Envelope(command: self, payload: typedPayload).encode(to: encoder)
    }

    func validated(as state: AmbitionsCommandValidationState) -> AmbitionsCommand {
        AmbitionsCommand(
            id: id,
            source: source,
            typedPayload: typedPayload,
            expectedRevision: expectedRevision,
            idempotencyKey: idempotencyKey,
            validationState: state,
            executionStatus: executionStatus,
            result: result,
            createdAt: createdAt,
            requestedAt: requestedAt,
            actor: actor,
            sourceSurface: sourceSurface,
            relations: relations,
            localOnly: localOnly,
            privacy: privacy,
            schemaVersion: schemaVersion
        )
    }

}

extension AmbitionsCommand {
    static func fromNowAction(
        _ action: NowAction,
        source: AmbitionsCommandSource = .today,
        id: String = DomainIdentifier.prefixed("command"),
        createdAt: String
    ) -> AmbitionsCommand {
        let route = CommandRouter().route(action)
        let target = AmbitionsCommandTarget(
            goalID: action.reference?.goalID,
            captureID: action.reference?.captureID,
            timeID: action.reference?.timeID,
            reviewID: action.reference?.reviewID,
            stepID: action.reference?.stepID,
            explanationID: action.explanationID,
            destination: route.destination
        )
        let content = AmbitionsCommandPayload(
            title: action.title,
            notes: action.subtitle,
            contextLens: action.contextLens,
            commitmentKind: action.commitmentKind,
            explanationID: action.explanationID
        )
        let typedContent = RuntimeCommandContent(content)
        let typedPayload: RuntimeCommandPayload = switch action.kind {
        case .none, .openGoal, .openTime, .schedule, .capture, .review:
            .history(HistoryCommand(action: .openDestination, target: target, content: typedContent))
        case .focus:
            .step(StepCommand(action: .startSession, target: target, content: typedContent))
        case .completeAction:
            .step(StepCommand(action: .complete, target: target, content: typedContent))
        case .recover:
            .step(StepCommand(action: .recover(RecoveryRecommendationCommand(
                goalID: target.goalID.flatMap(RuntimeCommandObjectID.init(rawValue:)),
                captureID: target.captureID.flatMap(RuntimeCommandObjectID.init(rawValue:)),
                timeID: target.timeID.flatMap(RuntimeCommandObjectID.init(rawValue:)),
                title: typedContent.title,
                explanationID: typedContent.explanationID.flatMap(RuntimeCommandObjectID.init(rawValue:))
            )), target: target, content: typedContent))
        case .wait:
            .capture(CaptureCommand(action: .markWaiting, target: target, content: typedContent))
        case .routeCommitment:
            .capture(CaptureCommand(action: .routeCommitment, target: target, content: typedContent))
        case .explain:
            .history(HistoryCommand(action: .askWhy, target: target, content: typedContent))
        }
        let command = AmbitionsCommand(
            id: id,
            source: source,
            typedPayload: typedPayload,
            createdAt: createdAt,
            relations: AmbitionsCommandRelations(
                goalIDs: [action.reference?.goalID].compactMap { $0 },
                captureIDs: [action.reference?.captureID].compactMap { $0 },
                timeIDs: [action.reference?.timeID].compactMap { $0 },
                reviewIDs: [action.reference?.reviewID].compactMap { $0 },
                eventLedgerEntryIDs: action.eventLedgerEntryIDs,
                recommendationExplanationIDs: [action.explanationID].compactMap { $0 }
            )
        )
        return command.validated(as: AmbitionsCommandValidator().validate(command))
    }
}
