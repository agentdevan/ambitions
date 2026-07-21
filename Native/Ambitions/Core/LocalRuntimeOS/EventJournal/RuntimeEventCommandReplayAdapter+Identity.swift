extension RuntimeEventCommandReplayAdapter {
    func incompatibleCommandReplayResult(
        recordedCommand: AmbitionsCommand,
        recordedResult: AmbitionsCommandExecutionResult
    ) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: .blocked,
            summary: "A different command already owns this command ID, " +
                "so Ambitions skipped replay to preserve the authoritative record.",
            route: recordedResult.route,
            target: recordedResult.target ?? recordedCommand.target,
            recommendationExplanationIDs: recordedResult.recommendationExplanationIDs,
            metadata: [
                "ledgerRecordKind": LedgerRecordTaxonomyKind.receipt.rawValue,
                "replayDecision": LedgerReplayDecision.lookupUnavailable.rawValue,
                "idempotencyKey": recordedCommand.id,
                "commandIdempotencyKey": recordedCommand.id,
                "doubleApplyDisposition": LedgerDoubleApplyDisposition.skipUnverifiedMutation.rawValue,
                "blockedBy": "runtime_command_identity_conflict",
                "runtimeReplayAuthority": "runtime_event_journal",
                "runtimeReplaySource": "command_record_identity_check"
            ]
        )
    }
}
