import Foundation
@testable import Ambitions

extension AmbitionsCommand {
    /// Test-only construction for historical fixtures. Product senders must supply typed payloads.
    init(
        id: String,
        kind: AmbitionsCommandKind,
        source: AmbitionsCommandSource,
        target: AmbitionsCommandTarget = AmbitionsCommandTarget(),
        payload: AmbitionsCommandPayload = AmbitionsCommandPayload(),
        expectedRevision: RuntimeExpectedRevision = .absent,
        idempotencyKey: CommandIdempotencyKey? = nil,
        validationState: AmbitionsCommandValidationState = .valid,
        executionStatus: AmbitionsCommandExecutionStatus = .pending,
        result: AmbitionsCommandExecutionResult? = nil,
        createdAt: String,
        requestedAt: String? = nil,
        actor: AmbitionsCommandActor = .user,
        sourceSurface: String? = nil,
        relations: AmbitionsCommandRelations = AmbitionsCommandRelations(),
        localOnly: Bool = true,
        privacy: EventLedgerPrivacyClassification = .standard,
        schemaVersion: String = ambitionsCommandSchemaVersion
    ) {
        self.init(
            id: id,
            source: source,
            typedPayload: RuntimeCommandPayload(upgrading: LegacyRuntimeCommandInput(
                id: id, kind: kind, target: target, payload: payload
            )),
            expectedRevision: expectedRevision,
            idempotencyKey: idempotencyKey,
            validationState: validationState,
            executionStatus: executionStatus,
            result: result,
            createdAt: createdAt,
            requestedAt: requestedAt,
            actor: actor,
            sourceSurface: sourceSurface,
            relations: relations,
            localOnly: localOnly,
            privacy: privacy,
            schemaVersion: schemaVersion
        )
    }
}
