extension AmbitionsCommandExecutionResult {
    func replacingMetadata(_ metadata: [String: String]) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: status,
            summary: summary,
            route: route,
            target: target,
            eventLedgerEntryIDs: eventLedgerEntryIDs,
            recommendationExplanationIDs: recommendationExplanationIDs,
            metadata: metadata
        )
    }
}
