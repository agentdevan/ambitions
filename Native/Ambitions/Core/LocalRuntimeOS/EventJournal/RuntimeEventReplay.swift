import Foundation

enum RuntimeDomainEventCodecError: Error, Equatable {
    case unknownTypeID(String)
    case futureSchema(typeID: String, version: Int)
    case typeMismatch(expected: String, actual: String)
}

struct RuntimeDomainEventCodec: Sendable {
    private struct CaptureCreatedV1: Codable {
        let captureID: String
        let rawText: String
        let route: CaptureRoute
        let createdAt: String
    }
    struct WireEnvelope: Codable {
        let typeID: String
        let schemaVersion: Int
        let payload: Data
    }
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        decoder = JSONDecoder()
    }

    func encode(_ event: RuntimeDomainEvent) throws -> Data { try encode(event, schemaVersion: event.schemaVersion) }

    func encode(_ event: RuntimeDomainEvent, schemaVersion: Int) throws -> Data {
        try encoder.encode(WireEnvelope(typeID: event.typeID, schemaVersion: schemaVersion, payload: encoder.encode(event)))
    }

    func decode(_ data: Data) throws -> RuntimeDomainEvent {
        let wire = try decoder.decode(WireEnvelope.self, from: data)
        guard Self.knownTypeIDs.contains(wire.typeID) else { throw RuntimeDomainEventCodecError.unknownTypeID(wire.typeID) }
        guard wire.schemaVersion <= runtimeDomainEventSchemaVersion else {
            throw RuntimeDomainEventCodecError.futureSchema(typeID: wire.typeID, version: wire.schemaVersion)
        }
        if wire.schemaVersion == 1, wire.typeID == "ambitions.capture.created" {
            let old = try decoder.decode(CaptureCreatedV1.self, from: wire.payload)
            return .captureCreated(CaptureCreatedDomainEvent(
                captureID: old.captureID, rawText: old.rawText, route: old.route,
                kind: .raw, createdAt: old.createdAt, linkedGoalID: nil
            ))
        }
        let event = try decoder.decode(RuntimeDomainEvent.self, from: wire.payload)
        guard event.typeID == wire.typeID else {
            throw RuntimeDomainEventCodecError.typeMismatch(expected: wire.typeID, actual: event.typeID)
        }
        return event
    }

    static let knownTypeIDs: Set<String> = [
        "ambitions.capture.created", "ambitions.time.step_placed",
        "ambitions.time.window_protected", "ambitions.time.window_corrected", "ambitions.mutation.undone",
    ]
}

struct RuntimeCommandReplayProjection: Equatable, Identifiable {
    let id: String
    let commandID: String
    let eventCursor: RuntimeEventCursor
    let recordedAt: String
    let commandRecordID: String?
    let replayOutcome: LedgerReplayOutcome
    let resultStatus: AmbitionsCommandExecutionStatus
    let resultSummary: String
    let resultRoute: AmbitionsCommandDestination?
    let target: AmbitionsCommandTarget
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]
    let metadata: [String: String]

    init(envelope: RuntimeEventEnvelope, payload: RuntimeCommandEventPayload) {
        let commandID = envelope.event.commandID ?? "missing-command-id"
        id = "runtime.event.replay.\(commandID)"
        self.commandID = commandID
        eventCursor = envelope.cursor
        recordedAt = envelope.event.occurredAt
        commandRecordID = payload.commandRecordID
        replayOutcome = LedgerReplayOutcome(
            idempotencyKey: LedgerIdempotencyKey(commandID),
            decision: .replayExistingReceipt,
            doubleApplyDisposition: .skipDuplicateMutation,
            receiptSummary: payload.resultSummary
        )
        resultStatus = payload.resultStatus
        resultSummary = payload.resultSummary
        resultRoute = payload.resultRoute
        target = envelope.event.target
        eventLedgerEntryIDs = payload.eventLedgerEntryIDs
        recommendationExplanationIDs = payload.recommendationExplanationIDs
        metadata = payload.resultMetadata.merging([
            "runtimeEventID": envelope.id,
            "runtimeEventSequence": String(envelope.sequence),
            "runtimeEventChecksum": envelope.checksum,
        ], uniquingKeysWith: { _, new in new })
    }
}

struct RuntimeEventReplay {
    let store: any RuntimeEventStore

    func replay(commandID: String) async throws -> RuntimeCommandReplayProjection? {
        let envelopes = try await store.fetchEvents(matching: .commandID(commandID), limit: nil)
        return envelopes
            .reversed()
            .compactMap { envelope -> RuntimeCommandReplayProjection? in
                guard case let .commandExecution(payload) = envelope.event.payload else {
                    return nil
                }
                return RuntimeCommandReplayProjection(envelope: envelope, payload: payload)
            }
            .first
    }
}

struct RuntimeDomainReconstruction: Sendable, Equatable {
    let captures: [CaptureCreatedDomainEvent]
    let timePlacements: [StepPlacedDomainEvent]
    let canonicalChecksum: String
}

struct RuntimeDomainEventReplay: Sendable {
    let store: any RuntimeEventStore

    func reconstruct() async throws -> RuntimeDomainReconstruction {
        let envelopes = try await store.fetchEvents(matching: .kind(.domainMutation), limit: nil)
        let events = envelopes.compactMap { envelope -> RuntimeDomainEvent? in
            guard case let .domainMutation(record) = envelope.event.payload else { return nil }
            return record.event
        }
        let captures = events.compactMap { event -> CaptureCreatedDomainEvent? in
            guard case let .captureCreated(value) = event else { return nil }
            return value
        }.sorted { $0.captureID < $1.captureID }
        let placements = events.compactMap { event -> StepPlacedDomainEvent? in
            guard case let .stepPlaced(value) = event else { return nil }
            return value
        }.sorted { $0.stepID < $1.stepID }
        let canonicalRows = captures.map { "capture|\($0.captureID)|\($0.rawText)|\($0.route.rawValue)|\($0.kind.rawValue)|\($0.createdAt)" }
            + placements.map { "time|\($0.stepID)|\($0.timeBlockID)|\($0.start)|\($0.end)" }
        return RuntimeDomainReconstruction(
            captures: captures,
            timePlacements: placements,
            canonicalChecksum: RuntimeTransactionDigest.digest(canonicalRows.sorted())
        )
    }
}
