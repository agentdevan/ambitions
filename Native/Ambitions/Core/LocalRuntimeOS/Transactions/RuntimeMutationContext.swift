import Foundation

let runtimeMutationContextSchemaVersion = "runtime_mutation_context.native.v1"

struct RuntimeMutationContext: Codable, Sendable, Equatable, Hashable {
    let family: ObjectStateFamily
    let commandID: String
    let transactionID: String
    let eventID: String
    let projectionID: ProjectionID
    let projectionPlan: [ProjectionID]
    let receiptID: String
    let replayTraceID: String
    let actor: AmbitionsCommandActor
    let source: AmbitionsCommandSource
    let privacy: EventLedgerPrivacyClassification
    let occurredAt: String
    let localOnly: Bool
    let rollbackPlanID: String

    fileprivate init(
        family: ObjectStateFamily,
        commandID: String,
        transactionID: String,
        eventID: String,
        projectionID: ProjectionID,
        projectionPlan: [ProjectionID],
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
        self.projectionPlan = Array(Set(projectionPlan.isEmpty ? [projectionID] : projectionPlan)).sorted()
        self.receiptID = receiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.replayTraceID = replayTraceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.actor = actor
        self.source = source
        self.privacy = privacy
        self.occurredAt = occurredAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.localOnly = localOnly
        self.rollbackPlanID = rollbackPlanID.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    fileprivate init(
        family: ObjectStateFamily,
        command: AmbitionsCommand,
        transactionID: String,
        eventEnvelope: RuntimeEventEnvelope,
        projectionID: ProjectionID,
        projectionPlan: [ProjectionID],
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
            projectionPlan: projectionPlan,
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

    private enum CodingKeys: String, CodingKey {
        case family
        case commandID
        case transactionID
        case eventID
        case projectionID
        case projectionPlan
        case receiptID
        case replayTraceID
        case actor
        case source
        case privacy
        case occurredAt
        case localOnly
        case rollbackPlanID
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let family = try container.decode(ObjectStateFamily.self, forKey: .family)
        let projectionID = try container.decode(ProjectionID.self, forKey: .projectionID)
        self.init(
            family: family,
            commandID: try container.decode(String.self, forKey: .commandID),
            transactionID: try container.decode(String.self, forKey: .transactionID),
            eventID: try container.decode(String.self, forKey: .eventID),
            projectionID: projectionID,
            projectionPlan: try container.decodeIfPresent([ProjectionID].self, forKey: .projectionPlan) ?? [projectionID],
            receiptID: try container.decode(String.self, forKey: .receiptID),
            replayTraceID: try container.decode(String.self, forKey: .replayTraceID),
            actor: try container.decode(AmbitionsCommandActor.self, forKey: .actor),
            source: try container.decode(AmbitionsCommandSource.self, forKey: .source),
            privacy: try container.decode(EventLedgerPrivacyClassification.self, forKey: .privacy),
            occurredAt: try container.decode(String.self, forKey: .occurredAt),
            localOnly: try container.decode(Bool.self, forKey: .localOnly),
            rollbackPlanID: try container.decode(String.self, forKey: .rollbackPlanID)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(family, forKey: .family)
        try container.encode(commandID, forKey: .commandID)
        try container.encode(transactionID, forKey: .transactionID)
        try container.encode(eventID, forKey: .eventID)
        try container.encode(projectionID, forKey: .projectionID)
        try container.encode(projectionPlan, forKey: .projectionPlan)
        try container.encode(receiptID, forKey: .receiptID)
        try container.encode(replayTraceID, forKey: .replayTraceID)
        try container.encode(actor, forKey: .actor)
        try container.encode(source, forKey: .source)
        try container.encode(privacy, forKey: .privacy)
        try container.encode(occurredAt, forKey: .occurredAt)
        try container.encode(localOnly, forKey: .localOnly)
        try container.encode(rollbackPlanID, forKey: .rollbackPlanID)
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
        guard projectionPlan.isEmpty == false && projectionPlan.contains(projectionID) else {
            throw ObjectStateContractError.missingProjection(expectedFamily)
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

enum RuntimeMutationContextIssuanceError: Error, Sendable, Equatable {
    case replayedOutcomeCannotIssueContext(commandID: String)
    case commitScopeMissingFamily(family: ObjectStateFamily, committedFamilies: [ObjectStateFamily])
    case commitScopeMissingProjection(projectionID: ProjectionID, committedProjections: [ProjectionID])
    case transactionReceiptMismatch(transactionID: String, receiptTransactionID: String)
}

extension RuntimeTransactionCoordinator {
    func issueMutationContext(
        family: ObjectStateFamily,
        projectionID: ProjectionID,
        from outcome: RuntimeTransactionCommitOutcome
    ) throws -> RuntimeMutationContext {
        guard let transaction = outcome.transaction else {
            throw RuntimeMutationContextIssuanceError.replayedOutcomeCannotIssueContext(commandID: outcome.receipt.commandID)
        }
        guard transaction.id == outcome.receipt.transactionID else {
            throw RuntimeMutationContextIssuanceError.transactionReceiptMismatch(
                transactionID: transaction.id,
                receiptTransactionID: outcome.receipt.transactionID
            )
        }

        let committedFamilies = outcome.receipt.objectFamilies.sorted { $0.rawValue < $1.rawValue }
        guard committedFamilies.contains(family) else {
            throw RuntimeMutationContextIssuanceError.commitScopeMissingFamily(
                family: family,
                committedFamilies: committedFamilies
            )
        }

        let committedProjections = Array(Set(outcome.receipt.projectionCursors.map(\.projectionID))).sorted()
        guard committedProjections.contains(projectionID) else {
            throw RuntimeMutationContextIssuanceError.commitScopeMissingProjection(
                projectionID: projectionID,
                committedProjections: committedProjections
            )
        }

        return RuntimeMutationContext(
            family: family,
            commandID: transaction.commandID,
            transactionID: outcome.receipt.transactionID,
            eventID: outcome.receipt.eventID,
            projectionID: projectionID,
            projectionPlan: committedProjections,
            receiptID: outcome.receipt.receiptID,
            replayTraceID: outcome.receipt.replayTraceID,
            actor: transaction.mutationPlan.command.actor,
            source: transaction.mutationPlan.command.source,
            privacy: transaction.mutationPlan.command.privacy,
            occurredAt: outcome.receipt.committedAt,
            localOnly: transaction.writeSet.localOnly && outcome.receipt.localOnly,
            rollbackPlanID: outcome.receipt.rollbackPlanID
        )
    }
}
