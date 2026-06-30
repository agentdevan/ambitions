import Foundation

struct RuntimeCommandReplayProjection: Equatable, Identifiable {
    let id: String
    let commandID: String
    let eventCursor: RuntimeEventCursor
    let replayOutcome: LedgerReplayOutcome
    let resultStatus: AmbitionsCommandExecutionStatus
    let resultSummary: String
    let target: AmbitionsCommandTarget
    let eventLedgerEntryIDs: [String]
    let metadata: [String: String]

    init(envelope: RuntimeEventEnvelope, payload: RuntimeCommandEventPayload) {
        let commandID = envelope.event.commandID ?? "missing-command-id"
        id = "runtime.event.replay.\(commandID)"
        self.commandID = commandID
        eventCursor = envelope.cursor
        replayOutcome = LedgerReplayOutcome(
            idempotencyKey: LedgerIdempotencyKey(commandID),
            decision: .replayExistingReceipt,
            doubleApplyDisposition: .skipDuplicateMutation,
            receiptSummary: payload.resultSummary
        )
        resultStatus = payload.resultStatus
        resultSummary = payload.resultSummary
        target = envelope.event.target
        eventLedgerEntryIDs = payload.eventLedgerEntryIDs
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
