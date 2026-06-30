import Foundation

let runtimeEventSchemaVersion = "runtime_event.native.v1"

enum RuntimeEventKind: String, Codable, Equatable, Hashable, CaseIterable {
    case commandExecution = "command_execution"
    case closureRecorded = "closure_recorded"
    case correctionRecorded = "correction_recorded"
    case captureRouteDecided = "capture_route_decided"
    case timePlacementProposed = "time_placement_proposed"
    case proofAttached = "proof_attached"
    case tombstoneRecorded = "tombstone_recorded"
    case compactionSnapshot = "compaction_snapshot"
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
