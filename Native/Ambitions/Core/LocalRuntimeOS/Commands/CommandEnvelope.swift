import Foundation

let commandEnvelopeSchemaVersion = "command_envelope.native.v1"

enum CommandEnvelopePhase: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case acceptedBeforeMutation = "accepted_before_mutation"
    case rejectedBeforeMutation = "rejected_before_mutation"
}

struct CommandEnvelope: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let command: AmbitionsCommand
    let idempotencyKey: CommandIdempotencyKey
    let phase: CommandEnvelopePhase
    let validationState: AmbitionsCommandValidationState
    let authorization: CommandAuthorization
    let mutationPlan: CommandMutationPlan
    let actor: AmbitionsCommandActor
    let source: AmbitionsCommandSource
    let sourceSurface: String?
    let target: AmbitionsCommandTarget
    let privacy: EventLedgerPrivacyClassification
    let localOnly: Bool
    let receivedAt: String
    let schemaVersion: String

    init(
        command: AmbitionsCommand,
        idempotencyKey: CommandIdempotencyKey,
        validationState: AmbitionsCommandValidationState,
        authorization: CommandAuthorization,
        mutationPlan: CommandMutationPlan,
        receivedAt: String,
        schemaVersion: String = commandEnvelopeSchemaVersion
    ) {
        let phase: CommandEnvelopePhase = validationState == .valid && authorization.isAuthorized
            ? .acceptedBeforeMutation
            : .rejectedBeforeMutation
        self.id = "command.envelope.\(phase.rawValue).\(command.id)"
        self.command = command
        self.idempotencyKey = idempotencyKey
        self.phase = phase
        self.validationState = validationState
        self.authorization = authorization
        self.mutationPlan = mutationPlan
        self.actor = command.actor
        self.source = command.source
        self.sourceSurface = command.sourceSurface
        self.target = command.target
        self.privacy = command.privacy
        self.localOnly = command.localOnly
        self.receivedAt = receivedAt
        self.schemaVersion = schemaVersion
    }

    var commandID: String {
        command.id
    }

    var canProceedToMutation: Bool {
        phase == .acceptedBeforeMutation &&
            validationState == .valid &&
            authorization.isAuthorized
    }

    var resultMetadata: [String: String] {
        [
            "commandEnvelopeID": id,
            "commandEnvelopePhase": phase.rawValue,
            "commandValidation": validationState.rawValue,
            "commandAuthorization": authorization.state.rawValue,
            "commandAuthorizationReasons": authorization.reasonCodes.joined(separator: ","),
            "commandSideEffectPolicy": mutationPlan.sideEffectPolicy.rawValue,
            "commandMutationKind": mutationPlan.mutationKind.rawValue,
            "commandExpectedProjectionIDs": mutationPlan.expectedProjectionIDs.joined(separator: ","),
            "commandIdempotencyKey": idempotencyKey.rawValue
        ].filter { $0.value.isEmpty == false }
    }
}
