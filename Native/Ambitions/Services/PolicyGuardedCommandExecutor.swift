import Foundation

struct PolicyGuardedCommandExecutor: CommandExecuting {
    private let base: any CommandExecuting
    private let sideEffectLedger: (any SideEffectLedgerRepository)?
    private let policyEvaluator: SafeAutomationPolicyEvaluator

    init(
        base: any CommandExecuting,
        sideEffectLedger: (any SideEffectLedgerRepository)? = nil,
        policyEvaluator: SafeAutomationPolicyEvaluator = SafeAutomationPolicyEvaluator()
    ) {
        self.base = base
        self.sideEffectLedger = sideEffectLedger
        self.policyEvaluator = policyEvaluator
    }

    func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        base.validate(command)
    }

    func execute(_ command: AmbitionsCommand, context: CommandExecutionContext) async -> AmbitionsCommandExecutionResult {
        let decision = policyEvaluator.evaluate(SafeAutomationProposedAction.fromCommand(command))
        let record = SideEffectLedgerRecord(
            decision: decision,
            commandID: command.id,
            occurredAt: DomainTimestamp.string(from: context.now)
        )
        try? await sideEffectLedger?.append(record)

        guard record.mayExecuteWithoutUserConfirmation || decision.permissionLevel == .executeLocalOnly else {
            return guardedResult(command: command, decision: decision, record: record)
        }

        return await base.execute(command, context: context)
    }

    private func guardedResult(
        command: AmbitionsCommand,
        decision: SafeAutomationPolicyDecision,
        record: SideEffectLedgerRecord
    ) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: executionStatus(for: decision),
            summary: summary(for: decision),
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "sideEffectLedgerID": record.id,
                "policyDecisionID": decision.id,
                "permissionLevel": decision.permissionLevel.rawValue,
                "confirmationRequirement": decision.confirmationRequirement.rawValue,
                "safetyClassification": decision.safetyClassification.rawValue,
                "guardedBy": "side_effect_policy"
            ]
        )
    }

    private func executionStatus(for decision: SafeAutomationPolicyDecision) -> AmbitionsCommandExecutionStatus {
        switch decision.permissionLevel {
        case .requiresConfirmation:
            return .requiresConfirmation
        case .neverAutomate:
            return .blocked
        case .notSupportedYet:
            return .unsupported
        case .suggestOnly, .prepareDraft:
            return .noOp
        case .executeLocalOnly:
            return decision.requiresExplicitUserConfirmation ? .requiresConfirmation : .noOp
        }
    }

    private func summary(for decision: SafeAutomationPolicyDecision) -> String {
        if let firstFact = decision.blockedFacts.first ?? decision.degradedFacts.first {
            return firstFact
        }
        return decision.reasons.map(\.userFacingSummary).joined(separator: " ")
    }
}
