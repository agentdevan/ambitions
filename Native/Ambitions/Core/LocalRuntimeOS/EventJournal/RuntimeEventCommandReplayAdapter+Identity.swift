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

extension AmbitionsCommand {
    func hasSameReplaySemanticIdentity(as other: AmbitionsCommand) -> Bool {
        id == other.id &&
            kind == other.kind &&
            source == other.source &&
            target == other.target &&
            payload == other.payload &&
            validationState == other.validationState &&
            executionStatus == other.executionStatus &&
            result == other.result &&
            actor == other.actor &&
            sourceSurface == other.sourceSurface &&
            relations == other.relations &&
            localOnly == other.localOnly &&
            privacy == other.privacy &&
            schemaVersion == other.schemaVersion
    }
}
