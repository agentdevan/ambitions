import Foundation

let commandAuthorizationSchemaVersion = "command_authorization.native.v1"

enum CommandAuthorizationState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case authorized
    case denied
}

struct CommandAuthorization: Codable, Sendable, Equatable, Hashable {
    let state: CommandAuthorizationState
    let reasonCodes: [String]
    let sideEffectPolicy: CommandSideEffectPolicy
    let schemaVersion: String

    init(
        state: CommandAuthorizationState,
        reasonCodes: [String] = [],
        sideEffectPolicy: CommandSideEffectPolicy,
        schemaVersion: String = commandAuthorizationSchemaVersion
    ) {
        self.state = state
        self.reasonCodes = Array(Set(reasonCodes.filter { $0.isEmpty == false })).sorted()
        self.sideEffectPolicy = sideEffectPolicy
        self.schemaVersion = schemaVersion
    }

    var isAuthorized: Bool {
        state == .authorized
    }
}

struct CommandAuthorizer: Sendable {
    func authorize(
        command: AmbitionsCommand,
        idempotencyKey: CommandIdempotencyKey,
        validation: AmbitionsCommandValidationState,
        mutationPlan: CommandMutationPlan
    ) -> CommandAuthorization {
        var reasons: [String] = []
        if idempotencyKey.isWellFormed == false {
            reasons.append("idempotency_key_malformed")
        }
        if validation != .valid {
            reasons.append("validation_\(validation.rawValue)")
        }
        if command.localOnly == false && command.privacy != .syncMetadata {
            reasons.append("private_runtime_non_local_execution")
        }
        if mutationPlan.sideEffectPolicy == .prohibited {
            reasons.append("side_effect_policy_prohibited")
        }

        return CommandAuthorization(
            state: reasons.isEmpty ? .authorized : .denied,
            reasonCodes: reasons,
            sideEffectPolicy: mutationPlan.sideEffectPolicy
        )
    }

    func blockedResult(
        command: AmbitionsCommand,
        authorization: CommandAuthorization
    ) -> AmbitionsCommandExecutionResult {
        AmbitionsCommandExecutionResult(
            status: .blocked,
            summary: "Command authorization blocked mutation before local state changed.",
            target: command.target,
            recommendationExplanationIDs: command.relations.recommendationExplanationIDs,
            metadata: [
                "blockedBy": "command_authorization",
                "authorization": authorization.state.rawValue,
                "authorizationReasons": authorization.reasonCodes.joined(separator: ","),
                "sideEffectPolicy": authorization.sideEffectPolicy.rawValue
            ]
        )
    }
}
