import Foundation

let runtimeEventSchemaVersion = "runtime_event.native.v1"
let runtimeDomainEventSchemaVersion = 2

enum RuntimeDomainEvent: Sendable, Codable, Equatable, Hashable {
    case captureCreated(CaptureCreatedDomainEvent)
    case stepPlaced(StepPlacedDomainEvent)
    case timeWindowProtected(TimeWindowDomainEvent)
    case timeWindowCorrected(TimeWindowDomainEvent)
    case mutationUndone(MutationUndoneDomainEvent)

    var typeID: String {
        switch self {
        case .captureCreated: "ambitions.capture.created"
        case .stepPlaced: "ambitions.time.step_placed"
        case .timeWindowProtected: "ambitions.time.window_protected"
        case .timeWindowCorrected: "ambitions.time.window_corrected"
        case .mutationUndone: "ambitions.mutation.undone"
        }
    }

    var schemaVersion: Int { runtimeDomainEventSchemaVersion }
}

struct CaptureCreatedDomainEvent: Sendable, Codable, Equatable, Hashable {
    let capture: Capture

    var captureID: String { capture.id }
    var rawText: String { capture.rawText }
    var route: CaptureRoute { capture.route }
    var kind: CaptureKind { capture.kind }
    var createdAt: String { capture.createdAt }
    var linkedGoalID: String? { capture.linkedGoalID }

    init(capture: Capture) {
        self.capture = capture
    }

    init(
        captureID: String,
        rawText: String,
        route: CaptureRoute,
        kind: CaptureKind,
        createdAt: String,
        linkedGoalID: String?
    ) {
        capture = Capture(
            id: captureID,
            createdAt: createdAt,
            updatedAt: createdAt,
            rawText: rawText,
            sourceType: nil,
            status: route == .captureInbox ? .needsTriage : .seed,
            linkedGoalID: linkedGoalID,
            triage: CaptureTriageMetadata(destination: route.triageDestination),
            kind: kind,
            route: route,
            triageStatus: route == .captureInbox ? .needsTriage : .assumedRoute
        )
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(capture.id)
        hasher.combine(capture.updatedAt)
        hasher.combine(capture.rawText)
    }
}

struct StepPlacedDomainEvent: Sendable, Codable, Equatable, Hashable {
    let stepID: String
    let timeBlockID: String
    let start: String
    let end: String
    let title: String?
    let goalID: String?

    init(stepID: String, timeBlockID: String, start: String, end: String, title: String? = nil, goalID: String? = nil) {
        self.stepID = stepID
        self.timeBlockID = timeBlockID
        self.start = start
        self.end = end
        self.title = title
        self.goalID = goalID
    }
}

struct TimeWindowDomainEvent: Sendable, Codable, Equatable, Hashable {
    let windowID: String
    let start: String
    let end: String
    let reason: String
}

struct MutationUndoneDomainEvent: Sendable, Codable, Equatable, Hashable {
    let originalReceiptID: String
    let affectedObjectIDs: [String]
}

struct RuntimeDomainEventRecord: Sendable, Codable, Equatable, Hashable {
    let typeID: String
    let schemaVersion: Int
    let encodedPayload: Data

    init(_ event: RuntimeDomainEvent) throws {
        typeID = event.typeID
        schemaVersion = event.schemaVersion
        encodedPayload = try RuntimeDomainEventCodec().encode(event)
    }

    init(typeID: String, schemaVersion: Int, encodedPayload: Data) {
        self.typeID = typeID
        self.schemaVersion = schemaVersion
        self.encodedPayload = encodedPayload
    }

    func decodedEvent() throws -> RuntimeDomainEvent {
        try RuntimeDomainEventCodec().decode(
            encodedPayload,
            expectedTypeID: typeID,
            expectedSchemaVersion: schemaVersion
        )
    }

    private enum CodingKeys: String, CodingKey {
        case typeID, schemaVersion, encodedPayload, event
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        typeID = try container.decode(String.self, forKey: .typeID)
        schemaVersion = try container.decode(Int.self, forKey: .schemaVersion)
        if let bytes = try container.decodeIfPresent(Data.self, forKey: .encodedPayload) {
            encodedPayload = bytes
        } else {
            let legacyEvent = try container.decode(RuntimeDomainEvent.self, forKey: .event)
            encodedPayload = try RuntimeDomainEventCodec().encode(legacyEvent, schemaVersion: schemaVersion)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(typeID, forKey: .typeID)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(encodedPayload, forKey: .encodedPayload)
    }
}

extension RuntimeDomainEvent {
    static func semanticEvent(command: AmbitionsCommand, result: AmbitionsCommandExecutionResult, occurredAt: String) -> RuntimeDomainEvent? {
        switch command.kind {
        case .quickCapture:
            guard let captureID = result.target?.captureID ?? result.metadata["captureID"],
                  let rawText = command.payload.primaryText else { return nil }
            let route = result.metadata["captureRoute"].flatMap(CaptureRoute.init(rawValue:)) ?? .captureInbox
            let kind = result.metadata["captureKind"].flatMap(CaptureKind.init(rawValue:)) ?? .raw
            return .captureCreated(CaptureCreatedDomainEvent(capture: Capture(
                id: captureID,
                createdAt: occurredAt,
                updatedAt: occurredAt,
                rawText: rawText.trimmingCharacters(in: .whitespacesAndNewlines),
                sourceType: result.metadata["captureSourceType"].flatMap(CaptureSourceType.init(rawValue:)),
                status: route == .captureInbox ? .needsTriage : .seed,
                linkedGoalID: command.target.goalID,
                triage: CaptureTriageMetadata(destination: route.triageDestination, hint: result.metadata["smartAttachmentReceipt"]),
                kind: kind,
                route: route,
                triageStatus: route == .captureInbox ? .needsTriage : .assumedRoute,
                commitmentKind: command.payload.commitmentKind,
                deadlineText: command.payload.deadlineText ?? command.payload.dueText,
                deadlineKind: command.payload.deadlineText == nil && command.payload.dueText == nil ? .none : .hard,
                contextLensHint: command.payload.contextLens,
                priorityHints: CapturePriorityHints(commandHints: command.payload.priorityHints),
                assumptionSummary: result.metadata["smartAttachmentReceipt"],
                recommendationExplanationIDs: command.relations.recommendationExplanationIDs
            )))
        case .createTimeItem, .placeStepInTime:
            guard let stepID = command.target.stepID, let timeBlockID = command.target.timeID else { return nil }
            return .stepPlaced(StepPlacedDomainEvent(
                stepID: stepID,
                timeBlockID: timeBlockID,
                start: command.payload.metadata["startAt"] ?? command.payload.metadata["start"] ?? occurredAt,
                end: command.payload.metadata["endAt"] ?? command.payload.metadata["end"] ?? occurredAt,
                title: command.payload.title,
                goalID: command.target.goalID
            ))
        case .protectTimeWindow:
            guard let windowID = command.target.timeID,
                  let start = command.payload.metadata["startAt"] ?? command.payload.metadata["start"],
                  let end = command.payload.metadata["endAt"] ?? command.payload.metadata["end"] else { return nil }
            return .timeWindowProtected(TimeWindowDomainEvent(
                windowID: windowID, start: start, end: end,
                reason: command.payload.notes ?? command.payload.title ?? "user_protected"
            ))
        case .correctTimeWindow:
            if let originalReceiptID = command.payload.metadata["undoOriginalReceiptID"] {
                return .mutationUndone(MutationUndoneDomainEvent(
                    originalReceiptID: originalReceiptID,
                    affectedObjectIDs: [command.target.timeID, command.target.stepID].compactMap { $0 }
                ))
            }
            guard let windowID = command.target.timeID,
                  let start = command.payload.metadata["startAt"] ?? command.payload.metadata["start"],
                  let end = command.payload.metadata["endAt"] ?? command.payload.metadata["end"] else { return nil }
            return .timeWindowCorrected(TimeWindowDomainEvent(
                windowID: windowID, start: start, end: end,
                reason: command.payload.metadata["correctionKind"] ?? "corrected"
            ))
        default:
            return nil
        }
    }
}

enum RuntimeEventKind: String, Codable, Equatable, Hashable, CaseIterable {
    case commandExecution = "command_execution"
    case closureRecorded = "closure_recorded"
    case correctionRecorded = "correction_recorded"
    case captureRouteDecided = "capture_route_decided"
    case timePlacementProposed = "time_placement_proposed"
    case proofAttached = "proof_attached"
    case tombstoneRecorded = "tombstone_recorded"
    case compactionSnapshot = "compaction_snapshot"
    case domainMutation = "domain_mutation"
}

enum RuntimeCommandEventPhase: String, Codable, Equatable, Hashable, CaseIterable {
    case executionRecorded = "execution_recorded"
}

struct RuntimeCommandEventPayload: Codable, Equatable, Hashable {
    let phase: RuntimeCommandEventPhase
    let commandKind: AmbitionsCommandKind
    let validationState: AmbitionsCommandValidationState
    let executionStatus: AmbitionsCommandExecutionStatus
    let resultStatus: AmbitionsCommandExecutionStatus
    let resultSummary: String
    let commandRecordID: String?
    let resultRoute: AmbitionsCommandDestination?
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]
    let resultMetadata: [String: String]

    init(
        phase: RuntimeCommandEventPhase,
        commandKind: AmbitionsCommandKind,
        validationState: AmbitionsCommandValidationState,
        executionStatus: AmbitionsCommandExecutionStatus,
        resultStatus: AmbitionsCommandExecutionStatus,
        resultSummary: String,
        commandRecordID: String?,
        resultRoute: AmbitionsCommandDestination?,
        eventLedgerEntryIDs: [String],
        recommendationExplanationIDs: [String],
        resultMetadata: [String: String]
    ) {
        self.phase = phase
        self.commandKind = commandKind
        self.validationState = validationState
        self.executionStatus = executionStatus
        self.resultStatus = resultStatus
        self.resultSummary = resultSummary
        self.commandRecordID = Self.nonEmpty(commandRecordID)
        self.resultRoute = resultRoute
        self.eventLedgerEntryIDs = Self.normalized(eventLedgerEntryIDs)
        self.recommendationExplanationIDs = Self.normalized(recommendationExplanationIDs)
        self.resultMetadata = resultMetadata.filter { $0.key.isEmpty == false && $0.value.isEmpty == false }
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value, value.isEmpty == false else { return nil }
        return value
    }
}

struct RuntimeClosureEventPayload: Codable, Equatable, Hashable {
    let closureID: String
    let objectID: String
    let closureState: String
    let receiptIDs: [String]

    init(closureID: String, objectID: String, closureState: String, receiptIDs: [String] = []) {
        self.closureID = closureID
        self.objectID = objectID
        self.closureState = closureState
        self.receiptIDs = Array(Set(receiptIDs.filter { $0.isEmpty == false })).sorted()
    }
}

struct RuntimeCorrectionEventPayload: Codable, Equatable, Hashable {
    let correctionID: String
    let objectID: String
    let correctionKind: String
    let supersedesEventID: String?

    init(correctionID: String, objectID: String, correctionKind: String, supersedesEventID: String? = nil) {
        self.correctionID = correctionID
        self.objectID = objectID
        self.correctionKind = correctionKind
        self.supersedesEventID = supersedesEventID?.isEmpty == false ? supersedesEventID : nil
    }
}

struct RuntimeCaptureRouteEventPayload: Codable, Equatable, Hashable {
    let captureID: String
    let route: CaptureRoute
    let kind: CaptureKind
    let decisionSummary: String
}

struct RuntimeTimePlacementEventPayload: Codable, Equatable, Hashable {
    let proposalID: String
    let stepID: String?
    let timeBlockID: String?
    let placementSummary: String
}

struct RuntimeProofAttachmentEventPayload: Codable, Equatable, Hashable {
    let proofID: String
    let objectID: String
    let sourceRecordIDs: [String]

    init(proofID: String, objectID: String, sourceRecordIDs: [String]) {
        self.proofID = proofID
        self.objectID = objectID
        self.sourceRecordIDs = Array(Set(sourceRecordIDs.filter { $0.isEmpty == false })).sorted()
    }
}

enum RuntimeEventPayload: Codable, Equatable, Hashable {
    case commandExecution(RuntimeCommandEventPayload)
    case closureRecorded(RuntimeClosureEventPayload)
    case correctionRecorded(RuntimeCorrectionEventPayload)
    case captureRouteDecided(RuntimeCaptureRouteEventPayload)
    case timePlacementProposed(RuntimeTimePlacementEventPayload)
    case proofAttached(RuntimeProofAttachmentEventPayload)
    case tombstoneRecorded(RuntimeTombstoneEventPayload)
    case compactionSnapshot(RuntimeEventCompactionSnapshot)
    case domainMutation(RuntimeDomainEventRecord)

    var kind: RuntimeEventKind {
        switch self {
        case .commandExecution:
            return .commandExecution
        case .closureRecorded:
            return .closureRecorded
        case .correctionRecorded:
            return .correctionRecorded
        case .captureRouteDecided:
            return .captureRouteDecided
        case .timePlacementProposed:
            return .timePlacementProposed
        case .proofAttached:
            return .proofAttached
        case .tombstoneRecorded:
            return .tombstoneRecorded
        case .compactionSnapshot:
            return .compactionSnapshot
        case .domainMutation:
            return .domainMutation
        }
    }
}

struct RuntimeEvent: Codable, Equatable, Hashable {
    let kind: RuntimeEventKind
    let commandID: String?
    let actor: AmbitionsCommandActor
    let source: AmbitionsCommandSource
    let target: AmbitionsCommandTarget
    let privacy: EventLedgerPrivacyClassification
    let localOnly: Bool
    let occurredAt: String
    let payload: RuntimeEventPayload
    let metadata: [String: String]
    let schemaVersion: String

    init(
        commandID: String? = nil,
        actor: AmbitionsCommandActor,
        source: AmbitionsCommandSource,
        target: AmbitionsCommandTarget = AmbitionsCommandTarget(),
        privacy: EventLedgerPrivacyClassification = .standard,
        localOnly: Bool = true,
        occurredAt: String,
        payload: RuntimeEventPayload,
        metadata: [String: String] = [:],
        schemaVersion: String = runtimeEventSchemaVersion
    ) {
        kind = payload.kind
        self.commandID = Self.nonEmpty(commandID)
        self.actor = actor
        self.source = source
        self.target = target
        self.privacy = privacy
        self.localOnly = localOnly
        self.occurredAt = occurredAt
        self.payload = payload
        self.metadata = metadata.filter { $0.key.isEmpty == false && $0.value.isEmpty == false }
        self.schemaVersion = schemaVersion
    }

    static func commandExecution(
        command: AmbitionsCommand,
        result: AmbitionsCommandExecutionResult,
        recordedAt: String,
        commandRecordID: String?
    ) -> RuntimeEvent {
        RuntimeEvent(
            commandID: command.id,
            actor: command.actor,
            source: command.source,
            target: result.target ?? command.target,
            privacy: command.privacy,
            localOnly: command.localOnly,
            occurredAt: recordedAt,
            payload: .commandExecution(
                RuntimeCommandEventPayload(
                    phase: .executionRecorded,
                    commandKind: command.kind,
                    validationState: command.validationState,
                    executionStatus: command.executionStatus,
                    resultStatus: result.status,
                    resultSummary: result.summary,
                    commandRecordID: commandRecordID,
                    resultRoute: result.route,
                    eventLedgerEntryIDs: result.eventLedgerEntryIDs,
                    recommendationExplanationIDs: result.recommendationExplanationIDs,
                    resultMetadata: result.metadata
                )
            ),
            metadata: [
                "commandSchemaVersion": command.schemaVersion,
                "resultStatus": result.status.rawValue,
            ]
        )
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let value, value.isEmpty == false else { return nil }
        return value
    }
}
