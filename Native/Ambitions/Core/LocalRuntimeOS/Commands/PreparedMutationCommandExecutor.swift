import Foundation

struct PreparedMutationCommandExecutor: CommandExecuting, Sendable {
    let preparer: any RuntimeMutationPreparing
    let validator: AmbitionsCommandValidator
    let lifetime: TimeInterval

    init(
        preparer: any RuntimeMutationPreparing,
        validator: AmbitionsCommandValidator = AmbitionsCommandValidator(),
        lifetime: TimeInterval = 900
    ) {
        self.preparer = preparer
        self.validator = validator
        self.lifetime = lifetime
    }

    func validate(_ command: AmbitionsCommand) -> AmbitionsCommandValidationState {
        validator.validate(command)
    }

    func execute(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext
    ) async -> AmbitionsCommandExecutionResult {
        guard let preparationID = RuntimePreparationID(rawValue: "runtime.preparation.\(command.id)"),
              let confirmationToken = RuntimeConfirmationToken(rawValue: "runtime.confirmation.\(command.id)"),
              let proposedObjectID = RuntimeDomainObjectID(rawValue: "runtime.proposed-object.\(command.id)"),
              let eventID = RuntimeEventID(rawValue: "runtime.prepared-event.\(command.id)"),
              let receiptID = RuntimeReceiptID(rawValue: "runtime.prepared-receipt.\(command.id)"),
              let rollbackPlanID = RuntimeRollbackPlanID(rawValue: "runtime.prepared-rollback.\(command.id)"),
              let externalOperationID = RuntimeExternalOperationID(rawValue: "runtime.prepared-effect.\(command.id)") else {
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Command preparation identity is invalid.",
                target: command.target,
                metadata: ["blockedBy": RuntimeRecoveryReason.identityMismatch.rawValue]
            )
        }
        let outcome = await preparer.prepare(command, context: RuntimePreparationContext(
            preparationID: preparationID,
            confirmationToken: confirmationToken,
            proposedObjectID: proposedObjectID,
            eventID: eventID,
            receiptID: receiptID,
            rollbackPlanID: rollbackPlanID,
            externalOperationID: externalOperationID,
            issuedAt: context.now,
            expiresAt: context.now.addingTimeInterval(lifetime),
            boundary: .localOnly
        ))
        return result(for: outcome, command: command)
    }

    private func result(
        for outcome: RuntimePreparationOutcome,
        command: AmbitionsCommand
    ) -> AmbitionsCommandExecutionResult {
        switch outcome {
        case let .ready(preparation):
            // AMBitionsAllowWeakPattern(reason: "Preparation success truthfully records that no authority transaction was attempted.")
            return AmbitionsCommandExecutionResult(
                status: .noOp,
                summary: "Mutation prepared; no authority transaction was attempted.",
                target: command.target,
                metadata: preparationMetadata(preparation)
            )
        case let .requiresConfirmation(preparation):
            return AmbitionsCommandExecutionResult(
                status: .requiresConfirmation,
                summary: "Mutation preparation requires bound confirmation.",
                target: command.target,
                metadata: preparationMetadata(preparation)
            )
        case let .blocked(failure):
            return AmbitionsCommandExecutionResult(
                status: .blocked,
                summary: "Mutation preparation was blocked.",
                target: command.target,
                metadata: ["blockedBy": failure.reason.rawValue, "recovery": failure.recovery.kind.rawValue]
            )
        case let .unsupported(failure):
            return AmbitionsCommandExecutionResult(
                status: .unsupported,
                summary: "Mutation preparation is unsupported.",
                target: command.target,
                metadata: ["blockedBy": failure.reason.rawValue, "recovery": failure.recovery.kind.rawValue]
            )
        }
    }

    private func preparationMetadata(_ preparation: RuntimePreparation) -> [String: String] {
        [
            "runtimePreparationID": preparation.preparationID.rawValue,
            "runtimeCommandFingerprint": preparation.commandFingerprint.rawValue,
            "runtimePreparationFamily": preparation.decision.family,
            "runtimePreparationAction": preparation.decision.action,
            "runtimePreparationDisposition": preparation.decision.disposition.rawValue,
            "runtimeAuthorityStatus": "not_attempted",
        ]
    }
}
