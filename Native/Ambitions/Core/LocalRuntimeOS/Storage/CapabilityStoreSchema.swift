import Foundation

let capabilityStoreSchemaVersion = "capability_store.native.v1"

/// The additive, local-only persistence boundary for Capability state.  These
/// names deliberately do not overlap Goal, Proof, or public-reference tables.
enum CapabilityStoreTable: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case records = "capability_records"
    case evidenceRelationships = "capability_evidence_relationships"
    case deletionTombstones = "capability_deletion_tombstones"
    case commandReceipts = "capability_command_receipts"
    case projectionCheckpoints = "capability_projection_checkpoints"
    case quarantines = "capability_quarantines"
}

struct CapabilityStoreSchema: Codable, Sendable, Equatable, Hashable {
    let version: String
    let tables: Set<CapabilityStoreTable>
    let localOnly: Bool
    let canonicalRuntimeOwner: String

    init(
        version: String = capabilityStoreSchemaVersion,
        tables: Set<CapabilityStoreTable> = Set(CapabilityStoreTable.allCases),
        localOnly: Bool = true,
        canonicalRuntimeOwner: String = "CanonicalRuntimeStore"
    ) {
        self.version = version.trimmingCharacters(in: .whitespacesAndNewlines)
        self.tables = tables
        self.localOnly = localOnly
        self.canonicalRuntimeOwner = canonicalRuntimeOwner.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isAdditive: Bool {
        version == capabilityStoreSchemaVersion &&
            tables == Set(CapabilityStoreTable.allCases) &&
            localOnly &&
            canonicalRuntimeOwner == "CanonicalRuntimeStore"
    }
}

struct CapabilityStoreQuarantine: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let reason: String
    let observedSchemaVersion: String

    init(id: String, reason: String, observedSchemaVersion: String) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.observedSchemaVersion = observedSchemaVersion.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct CapabilityStoreCheckpoint: Codable, Sendable, Equatable, Hashable {
    let revision: Int
    let replayEventCount: Int

    init(revision: Int, replayEventCount: Int) {
        self.revision = max(0, revision)
        self.replayEventCount = max(0, replayEventCount)
    }
}

struct CapabilityStoreSnapshot: Codable, Sendable, Equatable, Hashable {
    let schema: CapabilityStoreSchema
    let revision: Int
    let records: [CapabilityRecord]
    let evidenceRelationships: [CapabilityEvidenceRelationship]
    let deletionTombstones: [CapabilityDeletionTombstone]
    let quarantines: [CapabilityStoreQuarantine]
    let checkpoint: CapabilityStoreCheckpoint

    init(
        schema: CapabilityStoreSchema = CapabilityStoreSchema(),
        revision: Int = 0,
        records: [CapabilityRecord] = [],
        evidenceRelationships: [CapabilityEvidenceRelationship] = [],
        deletionTombstones: [CapabilityDeletionTombstone] = [],
        quarantines: [CapabilityStoreQuarantine] = [],
        checkpoint: CapabilityStoreCheckpoint? = nil
    ) {
        self.schema = schema
        self.revision = max(0, revision)
        self.records = records.sorted { $0.id.rawValue < $1.id.rawValue }
        self.evidenceRelationships = evidenceRelationships.sorted { $0.id < $1.id }
        self.deletionTombstones = deletionTombstones.sorted { $0.capabilityID.rawValue < $1.capabilityID.rawValue }
        self.quarantines = quarantines.sorted { $0.id < $1.id }
        self.checkpoint = checkpoint ?? CapabilityStoreCheckpoint(revision: revision, replayEventCount: 0)
    }

    static let empty = CapabilityStoreSnapshot()
}

struct CapabilityStoreBackup: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let snapshot: CapabilityStoreSnapshot
    let events: [CapabilityStoreEvent]

    init(snapshot: CapabilityStoreSnapshot, events: [CapabilityStoreEvent]) {
        self.schemaVersion = capabilityStoreSchemaVersion
        self.snapshot = snapshot
        self.events = events.sorted { $0.sequence < $1.sequence }
    }
}
