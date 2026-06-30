import Foundation

let commandCompilationSchemaVersion = "command_compilation.native.v1"

struct CommandCompilation: Codable, Sendable, Equatable, Hashable {
    let command: AmbitionsCommand
    let idempotencyKey: CommandIdempotencyKey
    let validationState: AmbitionsCommandValidationState
    let mutationPlan: CommandMutationPlan
    let authorization: CommandAuthorization
    let envelope: CommandEnvelope
    let schemaVersion: String

    var canProceedToMutation: Bool {
        envelope.canProceedToMutation
    }

    var resultMetadata: [String: String] {
        envelope.resultMetadata.merging([
            "commandCompilationSchemaVersion": schemaVersion,
            "commandMutationPlanID": mutationPlan.id,
            "commandFallbackKind": mutationPlan.fallback.kind,
            "commandUndoKind": mutationPlan.undoShape.kind
        ]) { _, new in new }
    }
}

struct CommandCompiler: Sendable {
    let validator: AmbitionsCommandValidator
    let reducer: CommandReducer
    let authorizer: CommandAuthorizer

    init(
        validator: AmbitionsCommandValidator = AmbitionsCommandValidator(),
        reducer: CommandReducer = CommandReducer(),
        authorizer: CommandAuthorizer = CommandAuthorizer()
    ) {
        self.validator = validator
        self.reducer = reducer
        self.authorizer = authorizer
    }

    func compile(
        _ command: AmbitionsCommand,
        context: CommandExecutionContext,
        validation overrideValidation: AmbitionsCommandValidationState? = nil
    ) -> CommandCompilation {
        let validation = overrideValidation ?? validator.validate(command)
        let idempotencyKey = CommandIdempotencyKey(command: command)
        let mutationPlan = reducer.reduce(command: command, validation: validation)
        let authorization = authorizer.authorize(
            command: command,
            idempotencyKey: idempotencyKey,
            validation: validation,
            mutationPlan: mutationPlan
        )
        let envelope = CommandEnvelope(
            command: command,
            idempotencyKey: idempotencyKey,
            validationState: validation,
            authorization: authorization,
            mutationPlan: mutationPlan,
            receivedAt: DomainTimestamp.string(from: context.now)
        )
        return CommandCompilation(
            command: command,
            idempotencyKey: idempotencyKey,
            validationState: validation,
            mutationPlan: mutationPlan,
            authorization: authorization,
            envelope: envelope,
            schemaVersion: commandCompilationSchemaVersion
        )
    }
}
