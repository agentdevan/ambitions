import Foundation

/// Typed, local-only commands for the Capability aggregate. The command ledger
/// intentionally has no recommendation, external-authority, or network path.
enum CapabilityCommandOperation: Codable, Sendable, Equatable, Hashable {
    case create(CapabilityRecord)
    case confirm(proposalID: String, record: CapabilityRecord)
    case edit(CapabilityRecord)
    case attachEvidence(CapabilityEvidenceRelationship)
    case detachEvidence(relationshipID: String)
    case setFutureUse(capabilityID: CapabilityID, state: CapabilityFutureUseState)
    case archive(capabilityID: CapabilityID)
    case trash(capabilityID: CapabilityID)
    case restore(capabilityID: CapabilityID)
    case permanentlyDelete(CapabilityDeletionTombstone)
}

struct CapabilityCommand: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let expectedRevision: Int
    let idempotencyKey: String
    let occurredAt: String
    let operation: CapabilityCommandOperation

    init(id: String, expectedRevision: Int, idempotencyKey: String, occurredAt: String, operation: CapabilityCommandOperation) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.expectedRevision = max(0, expectedRevision)
        self.idempotencyKey = idempotencyKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.occurredAt = occurredAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.operation = operation
    }
}

struct CapabilityRuntimeEvent: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let commandID: String
    let sequence: Int
    let operation: CapabilityCommandOperation

    init(commandID: String, sequence: Int, operation: CapabilityCommandOperation) {
        self.commandID = commandID
        self.sequence = sequence
        self.operation = operation
        self.id = "capability-runtime-event-\(sequence)-\(commandID)"
    }
}

struct CapabilityRuntimeReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let commandID: String
    let idempotencyKey: String
    let revision: Int
    let wasDuplicate: Bool

    init(commandID: String, idempotencyKey: String, revision: Int, wasDuplicate: Bool) {
        self.commandID = commandID
        self.idempotencyKey = idempotencyKey
        self.revision = revision
        self.wasDuplicate = wasDuplicate
        self.id = "capability-runtime-receipt-\(idempotencyKey)"
    }
}

struct CapabilityHistoryEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let eventID: String
    let receiptID: String
    let occurredAt: String

    init(eventID: String, receiptID: String, occurredAt: String) {
        self.eventID = eventID
        self.receiptID = receiptID
        self.occurredAt = occurredAt
        self.id = "capability-history-\(eventID)"
    }
}

struct CapabilityReplayEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let eventID: String
    let stateRevision: Int

    init(eventID: String, stateRevision: Int) {
        self.eventID = eventID
        self.stateRevision = stateRevision
        self.id = "capability-replay-\(eventID)"
    }
}

struct CapabilityCommandResult: Codable, Sendable, Equatable, Hashable {
    let storeReceipt: CapabilityStoreAppendReceipt
    let event: CapabilityRuntimeEvent
    let receipt: CapabilityRuntimeReceipt
    let history: CapabilityHistoryEntry
    let replay: CapabilityReplayEntry
}

enum CapabilityCommandServiceError: Error, Sendable, Equatable {
    case invalidConfirmation
    case invalidManualCreate
    case missingCapability(CapabilityID)
}

actor CapabilityCommandService {
    private let store: CapabilityStateStore
    private var resultsByIdempotencyKey: [String: CapabilityCommandResult] = [:]

    init(store: CapabilityStateStore) {
        self.store = store
    }

    func execute(_ command: CapabilityCommand) async throws -> CapabilityCommandResult {
        let key = command.idempotencyKey
        if let result = resultsByIdempotencyKey[key] {
            return duplicate(result)
        }

        let storeOperation = try await operation(for: command.operation)
        let appendReceipt = try await store.append(
            storeOperation,
            expectedRevision: command.expectedRevision,
            idempotencyKey: key
        )
        let event = CapabilityRuntimeEvent(
            commandID: command.id,
            sequence: appendReceipt.replayEventCount,
            operation: command.operation
        )
        let result = CapabilityCommandResult(
            storeReceipt: appendReceipt,
            event: event,
            receipt: CapabilityRuntimeReceipt(
                commandID: command.id,
                idempotencyKey: key,
                revision: appendReceipt.revision,
                wasDuplicate: appendReceipt.wasDuplicate
            ),
            history: CapabilityHistoryEntry(eventID: event.id, receiptID: "capability-runtime-receipt-\(key)", occurredAt: command.occurredAt),
            replay: CapabilityReplayEntry(eventID: event.id, stateRevision: appendReceipt.revision)
        )
        resultsByIdempotencyKey[key] = result
        return result
    }

    private func operation(for command: CapabilityCommandOperation) async throws -> CapabilityStoreOperation {
        switch command {
        case let .create(record):
            guard record.creationKind == .manual else { throw CapabilityCommandServiceError.invalidManualCreate }
            return .create(record)
        case let .confirm(_, record):
            guard record.creationKind == .confirmedProposal else { throw CapabilityCommandServiceError.invalidConfirmation }
            return .create(record)
        case let .edit(record):
            return .replace(record)
        case let .attachEvidence(relationship):
            return .attachEvidence(relationship)
        case let .detachEvidence(relationshipID):
            return .detachEvidence(relationshipID: relationshipID)
        case let .setFutureUse(capabilityID, state):
            let snapshot = await store.currentSnapshot()
            guard let record = snapshot.records.first(where: { $0.id == capabilityID }) else {
                throw CapabilityCommandServiceError.missingCapability(capabilityID)
            }
            return .replace(CapabilityRecord(
                id: record.id, revision: record.revision + 1, createdAt: record.createdAt,
                updatedAt: record.updatedAt, name: record.name, meaning: record.meaning,
                relevantContext: record.relevantContext, lifecycle: record.lifecycle,
                priorValidLifecycle: record.priorValidLifecycle, privacyClassification: record.privacyClassification,
                futureUseState: state, creationKind: record.creationKind,
                evidenceRelationshipIDs: record.evidenceRelationshipIDs,
                consumerBindings: record.consumerBindings, claimCeilings: record.claimCeilings,
                schemaVersion: record.schemaVersion
            ))
        case let .archive(capabilityID): return .archive(capabilityID: capabilityID)
        case let .trash(capabilityID): return .trash(capabilityID: capabilityID)
        case let .restore(capabilityID): return .restore(capabilityID: capabilityID)
        case let .permanentlyDelete(tombstone): return .permanentlyDelete(tombstone)
        }
    }

    private func duplicate(_ result: CapabilityCommandResult) -> CapabilityCommandResult {
        let original = result.storeReceipt
        let receipt = CapabilityStoreAppendReceipt(
            idempotencyKey: original.idempotencyKey, revision: original.revision,
            replayEventCount: original.replayEventCount, operation: original.operation, wasDuplicate: true
        )
        return CapabilityCommandResult(
            storeReceipt: receipt, event: result.event,
            receipt: CapabilityRuntimeReceipt(commandID: result.receipt.commandID, idempotencyKey: result.receipt.idempotencyKey, revision: result.receipt.revision, wasDuplicate: true),
            history: result.history, replay: result.replay
        )
    }
}
