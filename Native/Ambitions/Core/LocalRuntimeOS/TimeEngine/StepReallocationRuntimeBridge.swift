import Foundation

struct StepReallocationRuntimeBridge: Sendable {
    let sourceAdapter: StepReallocationSourceAdapter
    let runtimeKernel: PrivateLifeRuntimeKernel

    init(
        sourceAdapter: StepReallocationSourceAdapter = StepReallocationSourceAdapter(),
        runtimeKernel: PrivateLifeRuntimeKernel = PrivateLifeRuntimeKernel()
    ) {
        self.sourceAdapter = sourceAdapter
        self.runtimeKernel = runtimeKernel
    }

    func makeRuntimeInput(
        from decision: StepReallocationApprovedDecision,
        runtimeContext: RuntimeContextSnapshot,
        goalText: String? = nil
    ) -> StepReallocationRuntimeInput? {
        guard let event = decision.emitStepReallocationEvent() else {
            return nil
        }

        return sourceAdapter.makeRuntimeInput(
            from: event,
            runtimeContext: runtimeContext,
            goalText: goalText
        )
    }

    func makeReplayableDecisionTrace(
        from decision: StepReallocationApprovedDecision,
        runtimeContext: RuntimeContextSnapshot,
        goalText: String? = nil
    ) -> ReplayTrace? {
        guard let input = makeRuntimeInput(
            from: decision,
            runtimeContext: runtimeContext,
            goalText: goalText
        ) else {
            return nil
        }

        return runtimeKernel.makeReplayableDecisionTrace(input.runtimeInput)
    }

    func makeReplayableDecisionTrace(
        from event: StepReallocationEvent,
        runtimeContext: RuntimeContextSnapshot,
        goalText: String? = nil
    ) -> ReplayTrace {
        let runtimeInput = sourceAdapter.makeRuntimeInput(
            from: event,
            runtimeContext: runtimeContext,
            goalText: goalText
        )
        return runtimeKernel.makeReplayableDecisionTrace(runtimeInput.runtimeInput)
    }
}

