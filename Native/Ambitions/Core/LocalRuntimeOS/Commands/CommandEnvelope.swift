import Foundation

let commandEnvelopeSchemaVersion = "command_envelope.native.v2"
private let legacyCommandEnvelopeSchemaVersion = "command_envelope.native.v1"

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
    private let legacyV1Command: LegacyV1AmbitionsCommand?

    private enum CodingKeys: String, CodingKey {
        case id, command, idempotencyKey, phase, validationState, authorization, mutationPlan
        case actor, source, sourceSurface, target, privacy, localOnly, receivedAt, schemaVersion
    }

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
        legacyV1Command = nil
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        schemaVersion = try values.decode(String.self, forKey: .schemaVersion)
        if schemaVersion == legacyCommandEnvelopeSchemaVersion {
            let historical = try values.decode(LegacyV1AmbitionsCommand.self, forKey: .command)
            let historicalBytes = try JSONEncoder().encode(historical)
            guard case let .supported(upgraded, true) = LegacyV1CommandAdapter().decode(historicalBytes) else {
                throw DecodingError.dataCorruptedError(
                    forKey: .command, in: values, debugDescription: "Historical v1 journal command is unsupported or corrupt."
                )
            }
            command = upgraded
            legacyV1Command = historical
        } else if schemaVersion == commandEnvelopeSchemaVersion {
            command = try values.decode(RuntimeJournalCommandRecord.self, forKey: .command).command
            legacyV1Command = nil
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion, in: values, debugDescription: "Unsupported command envelope version."
            )
        }
        idempotencyKey = try values.decode(CommandIdempotencyKey.self, forKey: .idempotencyKey)
        phase = try values.decode(CommandEnvelopePhase.self, forKey: .phase)
        validationState = try values.decode(AmbitionsCommandValidationState.self, forKey: .validationState)
        authorization = try values.decode(CommandAuthorization.self, forKey: .authorization)
        mutationPlan = try values.decode(CommandMutationPlan.self, forKey: .mutationPlan)
        actor = try values.decode(AmbitionsCommandActor.self, forKey: .actor)
        source = try values.decode(AmbitionsCommandSource.self, forKey: .source)
        sourceSurface = try values.decodeIfPresent(String.self, forKey: .sourceSurface)
        target = try values.decode(AmbitionsCommandTarget.self, forKey: .target)
        privacy = try values.decode(EventLedgerPrivacyClassification.self, forKey: .privacy)
        localOnly = try values.decode(Bool.self, forKey: .localOnly)
        receivedAt = try values.decode(String.self, forKey: .receivedAt)
        guard id == "command.envelope.\(phase.rawValue).\(command.id)",
              command.idempotencyKey == idempotencyKey,
              mutationPlan.commandID == command.id,
              command.actor == actor,
              command.source == source,
              command.sourceSurface == sourceSurface,
              command.target == target,
              command.privacy == privacy,
              command.localOnly == localOnly else {
            throw DecodingError.dataCorruptedError(
                forKey: .command, in: values, debugDescription: "Journal command does not match envelope authority facts."
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(id, forKey: .id)
        switch schemaVersion {
        case legacyCommandEnvelopeSchemaVersion:
            guard let legacyV1Command else {
                throw EncodingError.invalidValue(
                    command,
                    .init(
                        codingPath: encoder.codingPath,
                        debugDescription: "Historical v1 command material is required to encode a v1 envelope."
                    )
                )
            }
            try values.encode(legacyV1Command, forKey: .command)
        case commandEnvelopeSchemaVersion:
            try values.encode(RuntimeJournalCommandRecord(command: command), forKey: .command)
        default:
            throw EncodingError.invalidValue(
                schemaVersion,
                .init(codingPath: encoder.codingPath, debugDescription: "Unsupported command envelope version.")
            )
        }
        try values.encode(idempotencyKey, forKey: .idempotencyKey)
        try values.encode(phase, forKey: .phase)
        try values.encode(validationState, forKey: .validationState)
        try values.encode(authorization, forKey: .authorization)
        try values.encode(mutationPlan, forKey: .mutationPlan)
        try values.encode(actor, forKey: .actor)
        try values.encode(source, forKey: .source)
        try values.encodeIfPresent(sourceSurface, forKey: .sourceSurface)
        try values.encode(target, forKey: .target)
        try values.encode(privacy, forKey: .privacy)
        try values.encode(localOnly, forKey: .localOnly)
        try values.encode(receivedAt, forKey: .receivedAt)
        try values.encode(schemaVersion, forKey: .schemaVersion)
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
