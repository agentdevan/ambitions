import Foundation

enum RuntimeEventCommandReplayLookupResult: Sendable, Equatable {
    case runtimeEvent(RuntimeCommandReplayProjection, commandRecordMaterialization: String)
    case commandRecordWithoutRuntimeEvent(AmbitionsCommandExecutionRecord)
    case lookupUnavailable
    case noRecord
}

struct RuntimeEventCommandReplayAdapter: Sendable {
    let runtimeEvents: (any RuntimeEventStore)?
    let commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?

    init(
        runtimeEvents: (any RuntimeEventStore)?,
        commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?
    ) {
        self.runtimeEvents = runtimeEvents
        self.commandExecutionRecords = commandExecutionRecords
    }

    func lookup(_ command: AmbitionsCommand) async -> RuntimeEventCommandReplayLookupResult {
        if let runtimeEvents {
            do {
                if let projection = try await RuntimeEventReplay(store: runtimeEvents).replay(commandID: command.id) {
                    let materialization = await materializeCommandRecordIfNeeded(for: command, projection: projection)
                    return .runtimeEvent(projection, commandRecordMaterialization: materialization)
                }
            } catch {
                return .lookupUnavailable
            }
        }

        guard let commandExecutionRecords else { return .noRecord }
        do {
            guard let record = try await commandExecutionRecords.fetchRecord(commandID: command.id) else {
                return .noRecord
            }
            return .commandRecordWithoutRuntimeEvent(record)
        } catch {
            return .lookupUnavailable
        }
    }

    func replayResult(
        for command: AmbitionsCommand,
        projection: RuntimeCommandReplayProjection,
        commandRecordMaterialization: String
    ) -> AmbitionsCommandExecutionResult {
        var metadata = projection.metadata
        metadata["ledgerRecordKind"] = LedgerRecordTaxonomyKind.event.rawValue
        metadata["replayDecision"] = projection.replayOutcome.decision.rawValue
        metadata["idempotencyKey"] = command.id
        metadata["commandIdempotencyKey"] = command.id
        metadata["doubleApplyDisposition"] = projection.replayOutcome.doubleApplyDisposition.rawValue
        metadata["replayedReceiptSummary"] = projection.replayOutcome.receiptSummary
        metadata["runtimeReplayAuthority"] = "runtime_event_journal"
        metadata["runtimeReplaySource"] = "runtime_event"
        metadata["runtimeReplayCommandRecordMaterialization"] = commandRecordMaterialization

        return AmbitionsCommandExecutionResult(
            status: projection.resultStatus,
            summary: "Replayed runtime event receipt: \(projection.resultSummary)",
            route: projection.resultRoute,
            target: projection.target,
            eventLedgerEntryIDs: projection.eventLedgerEntryIDs,
            recommendationExplanationIDs: projection.recommendationExplanationIDs,
            metadata: metadata
        )
    }

    func commandRecordWithoutRuntimeEventResult(
        for command: AmbitionsCommand,
        record: AmbitionsCommandExecutionRecord
    ) -> AmbitionsCommandExecutionResult {
        let key = CommandIdempotencyKey(command: command)
        return AmbitionsCommandExecutionResult(
            status: .blocked,
            summary: "Command execution record exists without runtime event replay authority, so Ambitions paused replay for repair before mutation.",
            route: record.result.route,
            target: record.result.target ?? command.target,
            eventLedgerEntryIDs: [],
            recommendationExplanationIDs: record.result.recommendationExplanationIDs,
            metadata: [
                "ledgerRecordKind": LedgerRecordTaxonomyKind.receipt.rawValue,
                "replayDecision": LedgerReplayDecision.lookupUnavailable.rawValue,
                "idempotencyKey": key.rawValue,
                "commandIdempotencyKey": key.rawValue,
                "doubleApplyDisposition": LedgerDoubleApplyDisposition.skipUnverifiedMutation.rawValue,
                "blockedBy": "runtime_event_missing_for_command_record",
                "runtimeReplayAuthority": "runtime_event_journal",
                "runtimeReplaySource": "command_record_repair_state",
                "replayedRecordID": record.id,
                "replayedRecordedAt": record.recordedAt,
            ]
        )
    }

    func lookupUnavailableResult(for command: AmbitionsCommand) -> AmbitionsCommandExecutionResult {
        let key = CommandIdempotencyKey(command: command)
        return AmbitionsCommandExecutionResult(
            status: .blocked,
            summary: "Runtime event replay lookup could not be verified, so Ambitions skipped the mutation to avoid double apply.",
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "replayDecision": LedgerReplayDecision.lookupUnavailable.rawValue,
                "idempotencyKey": key.rawValue,
                "commandIdempotencyKey": key.rawValue,
                "doubleApplyDisposition": LedgerDoubleApplyDisposition.skipUnverifiedMutation.rawValue,
                "blockedBy": "runtime_event_replay_lookup_unavailable",
                "runtimeReplayAuthority": "runtime_event_journal",
            ]
        )
    }

    private func materializeCommandRecordIfNeeded(
        for command: AmbitionsCommand,
        projection: RuntimeCommandReplayProjection
    ) async -> String {
        guard let commandExecutionRecords else { return "unavailable" }
        do {
            if try await commandExecutionRecords.fetchRecord(commandID: command.id) != nil {
                return "already_materialized"
            }
            try await commandExecutionRecords.append(
                AmbitionsCommandExecutionRecord(
                    id: projection.commandRecordID ?? "command.execution.\(command.id)",
                    command: command,
                    result: replayResult(
                        for: command,
                        projection: projection,
                        commandRecordMaterialization: "repaired_from_runtime_event"
                    ),
                    recordedAt: projection.recordedAt
                )
            )
            return "repaired_from_runtime_event"
        } catch {
            return "repair_failed"
        }
    }
}
