import Foundation

enum CapabilityStoreOperation: Codable, Sendable, Equatable, Hashable {
    case create(CapabilityRecord)
    case replace(CapabilityRecord)
    case attachEvidence(CapabilityEvidenceRelationship)
    case detachEvidence(relationshipID: String)
    case archive(capabilityID: CapabilityID)
    case trash(capabilityID: CapabilityID)
    case restore(capabilityID: CapabilityID)
    case redactEvidence(relationshipID: String)
    case permanentlyDelete(CapabilityDeletionTombstone)
}

struct CapabilityStoreEvent: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sequence: Int
    let idempotencyKey: String
    let operation: CapabilityStoreOperation

    init(sequence: Int, idempotencyKey: String, operation: CapabilityStoreOperation) {
        self.sequence = max(1, sequence)
        self.idempotencyKey = idempotencyKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.operation = operation
        self.id = "capability-event-\(self.sequence)-\(self.idempotencyKey)"
    }
}

struct CapabilityStoreAppendReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let idempotencyKey: String
    let revision: Int
    let replayEventCount: Int
    let operation: CapabilityStoreOperation
    let wasDuplicate: Bool

    init(idempotencyKey: String, revision: Int, replayEventCount: Int, operation: CapabilityStoreOperation, wasDuplicate: Bool) {
        self.idempotencyKey = idempotencyKey.trimmingCharacters(in: .whitespacesAndNewlines)
        self.revision = max(0, revision)
        self.replayEventCount = max(0, replayEventCount)
        self.operation = operation
        self.wasDuplicate = wasDuplicate
        self.id = "capability-receipt-\(self.idempotencyKey)"
    }
}

enum CapabilityStateStoreError: Error, Sendable, Equatable {
    case missingIdempotencyKey
    case staleRevision(expected: Int, actual: Int)
    case missingCapability(CapabilityID)
    case duplicateCapability(CapabilityID)
    case invalidLifecycle(CapabilityLifecycle)
    case missingEvidenceRelationship(String)
    case duplicateEvidenceRelationship(String)
    case permanentlyDeleted(CapabilityID)
}

actor CapabilityStateStore {
    private var snapshot: CapabilityStoreSnapshot
    private var events: [CapabilityStoreEvent]
    private var receiptsByIdempotencyKey: [String: CapabilityStoreAppendReceipt]

    init(snapshot: CapabilityStoreSnapshot = .empty, events: [CapabilityStoreEvent] = []) {
        self.snapshot = snapshot
        self.events = events.sorted { $0.sequence < $1.sequence }
        self.receiptsByIdempotencyKey = [:]
    }

    func currentSnapshot() -> CapabilityStoreSnapshot {
        snapshot
    }

    func backup() -> CapabilityStoreBackup {
        CapabilityStoreBackup(snapshot: snapshot, events: events)
    }

    func append(
        _ operation: CapabilityStoreOperation,
        expectedRevision: Int,
        idempotencyKey: String
    ) throws -> CapabilityStoreAppendReceipt {
        let key = idempotencyKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard key.isEmpty == false else { throw CapabilityStateStoreError.missingIdempotencyKey }
        if let receipt = receiptsByIdempotencyKey[key] {
            return CapabilityStoreAppendReceipt(
                idempotencyKey: receipt.idempotencyKey,
                revision: receipt.revision,
                replayEventCount: receipt.replayEventCount,
                operation: receipt.operation,
                wasDuplicate: true
            )
        }
        guard expectedRevision == snapshot.revision else {
            throw CapabilityStateStoreError.staleRevision(expected: expectedRevision, actual: snapshot.revision)
        }

        var next = snapshot
        try CapabilityStateReducer.apply(operation, to: &next)
        let event = CapabilityStoreEvent(sequence: events.count + 1, idempotencyKey: key, operation: operation)
        let nextRevision = snapshot.revision + 1
        next = CapabilityStateReducer.settingRevision(nextRevision, replayEventCount: event.sequence, for: next)
        snapshot = next
        events.append(event)
        let receipt = CapabilityStoreAppendReceipt(
            idempotencyKey: key,
            revision: nextRevision,
            replayEventCount: event.sequence,
            operation: operation,
            wasDuplicate: false
        )
        receiptsByIdempotencyKey[key] = receipt
        return receipt
    }

    func replay() throws -> CapabilityStoreSnapshot {
        var rebuilt = CapabilityStoreSnapshot.empty
        for event in events {
            try CapabilityStateReducer.apply(event.operation, to: &rebuilt)
            rebuilt = CapabilityStateReducer.settingRevision(event.sequence, replayEventCount: event.sequence, for: rebuilt)
        }
        return rebuilt
    }
}

private enum CapabilityStateReducer {
    static func apply(_ operation: CapabilityStoreOperation, to snapshot: inout CapabilityStoreSnapshot) throws {
        switch operation {
        case let .create(record):
            guard snapshot.deletionTombstones.contains(where: { $0.capabilityID == record.id }) == false else {
                throw CapabilityStateStoreError.permanentlyDeleted(record.id)
            }
            guard snapshot.records.contains(where: { $0.id == record.id }) == false else {
                throw CapabilityStateStoreError.duplicateCapability(record.id)
            }
            snapshot = replacing(records: snapshot.records + [record], in: snapshot)
        case let .replace(record):
            guard let index = snapshot.records.firstIndex(where: { $0.id == record.id }) else {
                throw CapabilityStateStoreError.missingCapability(record.id)
            }
            var records = snapshot.records
            records[index] = record
            snapshot = replacing(records: records, in: snapshot)
        case let .attachEvidence(relationship):
            guard snapshot.records.contains(where: { $0.id == relationship.capabilityID }) else {
                throw CapabilityStateStoreError.missingCapability(relationship.capabilityID)
            }
            guard snapshot.evidenceRelationships.contains(where: { $0.id == relationship.id }) == false else {
                throw CapabilityStateStoreError.duplicateEvidenceRelationship(relationship.id)
            }
            snapshot = replacing(relationships: snapshot.evidenceRelationships + [relationship], in: snapshot)
            try updateRelationshipIDs(
                capabilityID: relationship.capabilityID,
                relationshipIDs: snapshot.evidenceRelationships
                    .filter { $0.capabilityID == relationship.capabilityID }
                    .map(\.id),
                in: &snapshot
            )
        case let .detachEvidence(relationshipID):
            guard let relationship = snapshot.evidenceRelationships.first(where: { $0.id == relationshipID }) else {
                throw CapabilityStateStoreError.missingEvidenceRelationship(relationshipID)
            }
            snapshot = replacing(relationships: snapshot.evidenceRelationships.filter { $0.id != relationshipID }, in: snapshot)
            try updateRelationshipIDs(
                capabilityID: relationship.capabilityID,
                relationshipIDs: snapshot.evidenceRelationships
                    .filter { $0.capabilityID == relationship.capabilityID }
                    .map(\.id),
                in: &snapshot
            )
        case let .archive(capabilityID):
            try transition(capabilityID: capabilityID, to: .archived, in: &snapshot)
        case let .trash(capabilityID):
            try transition(capabilityID: capabilityID, to: .trashed, in: &snapshot)
        case let .restore(capabilityID):
            guard let record = snapshot.records.first(where: { $0.id == capabilityID }) else {
                throw CapabilityStateStoreError.missingCapability(capabilityID)
            }
            guard record.lifecycle == .archived || record.lifecycle == .trashed else {
                throw CapabilityStateStoreError.invalidLifecycle(record.lifecycle)
            }
            try replaceLifecycle(capabilityID: capabilityID, lifecycle: record.priorValidLifecycle ?? .active, prior: nil, in: &snapshot)
        case let .redactEvidence(relationshipID):
            guard let index = snapshot.evidenceRelationships.firstIndex(where: { $0.id == relationshipID }) else {
                throw CapabilityStateStoreError.missingEvidenceRelationship(relationshipID)
            }
            let source = snapshot.evidenceRelationships[index]
            let redacted = CapabilityEvidenceRelationship(
                id: source.id,
                revision: source.revision + 1,
                capabilityID: source.capabilityID,
                source: source.source,
                relationKind: source.relationKind,
                userApprovedContext: nil,
                occurredAt: source.occurredAt,
                freshnessUpdatedAt: source.freshnessUpdatedAt,
                availability: .redacted,
                contradictionState: .needsReview,
                lineageIDs: source.lineageIDs
            )
            var relationships = snapshot.evidenceRelationships
            relationships[index] = redacted
            snapshot = replacing(relationships: relationships, in: snapshot)
        case let .permanentlyDelete(tombstone):
            guard let record = snapshot.records.first(where: { $0.id == tombstone.capabilityID }) else {
                throw CapabilityStateStoreError.missingCapability(tombstone.capabilityID)
            }
            guard record.lifecycle == .trashed else { throw CapabilityStateStoreError.invalidLifecycle(record.lifecycle) }
            snapshot = CapabilityStoreSnapshot(
                schema: snapshot.schema,
                revision: snapshot.revision,
                records: snapshot.records.filter { $0.id != tombstone.capabilityID },
                evidenceRelationships: snapshot.evidenceRelationships.filter { $0.capabilityID != tombstone.capabilityID },
                deletionTombstones: snapshot.deletionTombstones + [tombstone],
                quarantines: snapshot.quarantines,
                checkpoint: snapshot.checkpoint
            )
        }
    }

    static func settingRevision(_ revision: Int, replayEventCount: Int, for snapshot: CapabilityStoreSnapshot) -> CapabilityStoreSnapshot {
        CapabilityStoreSnapshot(
            schema: snapshot.schema,
            revision: revision,
            records: snapshot.records,
            evidenceRelationships: snapshot.evidenceRelationships,
            deletionTombstones: snapshot.deletionTombstones,
            quarantines: snapshot.quarantines,
            checkpoint: CapabilityStoreCheckpoint(revision: revision, replayEventCount: replayEventCount)
        )
    }

    private static func transition(capabilityID: CapabilityID, to lifecycle: CapabilityLifecycle, in snapshot: inout CapabilityStoreSnapshot) throws {
        guard let record = snapshot.records.first(where: { $0.id == capabilityID }) else {
            throw CapabilityStateStoreError.missingCapability(capabilityID)
        }
        guard record.lifecycle == .active || record.lifecycle == .archived else {
            throw CapabilityStateStoreError.invalidLifecycle(record.lifecycle)
        }
        try replaceLifecycle(capabilityID: capabilityID, lifecycle: lifecycle, prior: record.lifecycle, in: &snapshot)
    }

    private static func replaceLifecycle(capabilityID: CapabilityID, lifecycle: CapabilityLifecycle, prior: CapabilityLifecycle?, in snapshot: inout CapabilityStoreSnapshot) throws {
        guard let index = snapshot.records.firstIndex(where: { $0.id == capabilityID }) else {
            throw CapabilityStateStoreError.missingCapability(capabilityID)
        }
        let record = snapshot.records[index]
        let updated = CapabilityRecord(
            id: record.id,
            revision: record.revision + 1,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
            name: record.name,
            meaning: record.meaning,
            relevantContext: record.relevantContext,
            lifecycle: lifecycle,
            priorValidLifecycle: prior,
            privacyClassification: record.privacyClassification,
            futureUseState: record.futureUseState,
            creationKind: record.creationKind,
            evidenceRelationshipIDs: record.evidenceRelationshipIDs,
            consumerBindings: record.consumerBindings,
            claimCeilings: record.claimCeilings,
            schemaVersion: record.schemaVersion
        )
        var records = snapshot.records
        records[index] = updated
        snapshot = replacing(records: records, in: snapshot)
    }

    private static func updateRelationshipIDs(capabilityID: CapabilityID, relationshipIDs: [String], in snapshot: inout CapabilityStoreSnapshot) throws {
        guard let index = snapshot.records.firstIndex(where: { $0.id == capabilityID }) else {
            throw CapabilityStateStoreError.missingCapability(capabilityID)
        }
        let record = snapshot.records[index]
        let updated = CapabilityRecord(
            id: record.id,
            revision: record.revision + 1,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
            name: record.name,
            meaning: record.meaning,
            relevantContext: record.relevantContext,
            lifecycle: record.lifecycle,
            priorValidLifecycle: record.priorValidLifecycle,
            privacyClassification: record.privacyClassification,
            futureUseState: record.futureUseState,
            creationKind: record.creationKind,
            evidenceRelationshipIDs: relationshipIDs,
            consumerBindings: record.consumerBindings,
            claimCeilings: record.claimCeilings,
            schemaVersion: record.schemaVersion
        )
        var records = snapshot.records
        records[index] = updated
        snapshot = replacing(records: records, in: snapshot)
    }

    private static func replacing(records: [CapabilityRecord], in snapshot: CapabilityStoreSnapshot) -> CapabilityStoreSnapshot {
        CapabilityStoreSnapshot(
            schema: snapshot.schema,
            revision: snapshot.revision,
            records: records,
            evidenceRelationships: snapshot.evidenceRelationships,
            deletionTombstones: snapshot.deletionTombstones,
            quarantines: snapshot.quarantines,
            checkpoint: snapshot.checkpoint
        )
    }

    private static func replacing(relationships: [CapabilityEvidenceRelationship], in snapshot: CapabilityStoreSnapshot) -> CapabilityStoreSnapshot {
        CapabilityStoreSnapshot(
            schema: snapshot.schema,
            revision: snapshot.revision,
            records: snapshot.records,
            evidenceRelationships: relationships,
            deletionTombstones: snapshot.deletionTombstones,
            quarantines: snapshot.quarantines,
            checkpoint: snapshot.checkpoint
        )
    }
}
