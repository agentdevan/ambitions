import Foundation

enum CommandReplayLookupResult: Sendable, Equatable {
    case noRecord
    case record(AmbitionsCommandExecutionRecord)
    case lookupUnavailable
}

struct CommandReplayAdapter: Sendable {
    let commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?

    init(commandExecutionRecords: (any AmbitionsCommandExecutionRecordRepository)?) {
        self.commandExecutionRecords = commandExecutionRecords
    }

    func lookup(_ command: AmbitionsCommand) async -> CommandReplayLookupResult {
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
        let key = CommandIdempotencyKey(command: command)
        let outcome = LedgerReplayOutcome(
            idempotencyKey: key.ledgerKey,
            decision: .replayExistingReceipt,
            doubleApplyDisposition: .skipDuplicateMutation,
            receiptSummary: record.result.summary
        )
        var metadata = record.result.metadata
        metadata["ledgerRecordKind"] = LedgerRecordTaxonomyKind.receipt.rawValue
        metadata["replayDecision"] = outcome.decision.rawValue
        metadata["idempotencyKey"] = key.rawValue
        metadata["commandIdempotencyKey"] = key.rawValue
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

    func lookupUnavailableResult(for command: AmbitionsCommand) -> AmbitionsCommandExecutionResult {
        let key = CommandIdempotencyKey(command: command)
        return AmbitionsCommandExecutionResult(
            status: .blocked,
            summary: "Command replay lookup could not be verified, so Ambitions skipped the mutation to avoid double apply.",
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "replayDecision": LedgerReplayDecision.lookupUnavailable.rawValue,
                "idempotencyKey": key.rawValue,
                "commandIdempotencyKey": key.rawValue,
                "doubleApplyDisposition": LedgerDoubleApplyDisposition.skipUnverifiedMutation.rawValue,
                "blockedBy": "command_replay_lookup_unavailable"
            ]
        )
    }
}
