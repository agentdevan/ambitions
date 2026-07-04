import Foundation

struct ProtectedTimeEvaluation: Codable, Sendable, Equatable, Hashable {
    let protectedPlacementDecision: ProtectedStepPlacementDecision
    let constraintEvaluation: TimeConstraintEvaluation
    let runtimeTrace: SchedulingRuntimeTrace

    var requiresReview: Bool {
        protectedPlacementDecision.kind != .allowed || constraintEvaluation.hasBlockingViolation
    }
}

struct ProtectedTimeEngine: Sendable {
    private let placementPolicy: ProtectedStepPlacementPolicy
    private let constraintEngine: ConstraintEngine

    init(
        placementPolicy: ProtectedStepPlacementPolicy = ProtectedStepPlacementPolicy(),
        constraintEngine: ConstraintEngine = ConstraintEngine()
    ) {
        self.placementPolicy = placementPolicy
        self.constraintEngine = constraintEngine
    }

    func evaluate(request: TimePlacementRequest, graph: TimeBlockGraph) -> ProtectedTimeEvaluation {
        let decision = placementPolicy.evaluate(
            now: request.now,
            stepID: request.stepID,
            originalPlacement: request.originalWindow,
            proposedPlacement: request.proposedWindow,
            trigger: request.trigger,
            explicitUserApproval: request.explicitUserApproval,
            automationPolicy: request.automationPolicy,
            contextQuality: request.contextQuality,
            localOnly: request.localOnly
        )
        let constraintEvaluation = constraintEngine.evaluate(graph: graph, candidate: request.candidateBlock)
        let source = [
            decision.stepID,
            decision.kind.rawValue,
            constraintEvaluation.violations.map(\.id).joined(separator: ","),
            graph.id
        ].joined(separator: "|")
        return ProtectedTimeEvaluation(
            protectedPlacementDecision: decision,
            constraintEvaluation: constraintEvaluation,
            runtimeTrace: SchedulingRuntimeTrace.make(owner: "ProtectedTimeEngine", sourceID: source, localOnly: decision.localOnly && graph.localOnly)
        )
    }
}
