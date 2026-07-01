import Foundation

let runtimeMutationContextSchemaVersion = "runtime_mutation_context.native.v1"

struct RuntimeMutationContext: Codable, Sendable, Equatable, Hashable {
    let family: ObjectStateFamily
    let commandID: String
    let transactionID: String
    let eventID: String
    let projectionID: ProjectionID
    let receiptID: String
    let replayTraceID: String
    let actor: AmbitionsCommandActor
    let source: AmbitionsCommandSource
    let privacy: EventLedgerPrivacyClassification
    let occurredAt: String
    let localOnly: Bool
    let rollbackPlanID: String

    init(
        family: ObjectStateFamily,
        commandID: String,
        transactionID: String,
        eventID: String,
        projectionID: ProjectionID,
        receiptID: String,
        replayTraceID: String,
        actor: AmbitionsCommandActor,
        source: AmbitionsCommandSource,
        privacy: EventLedgerPrivacyClassification,
        occurredAt: String,
        localOnly: Bool = true,
        rollbackPlanID: String
    ) {
        self.family = family
        self.commandID = commandID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.transactionID = transactionID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.eventID = eventID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.projectionID = projectionID
        self.receiptID = receiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.replayTraceID = replayTraceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.actor = actor
        self.source = source
        self.privacy = privacy
        self.occurredAt = occurredAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.localOnly = localOnly
        self.rollbackPlanID = rollbackPlanID.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    init(
        family: ObjectStateFamily,
        command: AmbitionsCommand,
        transactionID: String,
        eventEnvelope: RuntimeEventEnvelope,
        projectionID: ProjectionID,
        receiptID: String,
        replayTraceID: String,
        rollbackPlanID: String
    ) {
        self.init(
            family: family,
            commandID: command.id,
            transactionID: transactionID,
            eventID: eventEnvelope.id,
            projectionID: projectionID,
            receiptID: receiptID,
            replayTraceID: replayTraceID,
            actor: command.actor,
            source: command.source,
            privacy: command.privacy,
            occurredAt: eventEnvelope.event.occurredAt,
            localOnly: command.localOnly && eventEnvelope.event.localOnly,
            rollbackPlanID: rollbackPlanID
        )
    }

    func validated(for expectedFamily: ObjectStateFamily) throws {
        guard family == expectedFamily else {
            throw ObjectStateContractError.familyMismatch(expected: expectedFamily, actual: family)
        }
        guard commandID.isEmpty == false else {
            throw ObjectStateContractError.missingCommand(expectedFamily)
        }
        guard transactionID.isEmpty == false else {
            throw ObjectStateContractError.missingTransaction(expectedFamily)
        }
        guard eventID.isEmpty == false else {
            throw ObjectStateContractError.missingEvent(expectedFamily)
        }
        guard receiptID.isEmpty == false else {
            throw ObjectStateContractError.missingReceipt(expectedFamily)
        }
        guard replayTraceID.isEmpty == false else {
            throw ObjectStateContractError.missingReplay(expectedFamily)
        }
        guard rollbackPlanID.isEmpty == false else {
            throw ObjectStateContractError.missingRollback(expectedFamily)
        }
        guard localOnly else {
            throw ObjectStateContractError.nonLocalMutation(expectedFamily)
        }
    }
}
