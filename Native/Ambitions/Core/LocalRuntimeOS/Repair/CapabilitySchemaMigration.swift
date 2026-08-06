import Foundation

enum CapabilitySchemaMigrationDisposition: String, Codable, Sendable, Equatable, Hashable {
    case initializedEmpty = "initialized_empty"
    case unchanged
    case quarantined
}

struct CapabilitySchemaMigrationResult: Codable, Sendable, Equatable, Hashable {
    let disposition: CapabilitySchemaMigrationDisposition
    let snapshot: CapabilityStoreSnapshot
    let backup: CapabilityStoreBackup?

    var isSafeForUse: Bool {
        disposition != .quarantined && snapshot.schema.isAdditive && snapshot.quarantines.isEmpty
    }
}

/// The first Capability migration is deliberately additive: it never scans
/// historical Goals, Receipts, or Proof in order to infer a Capability.
struct CapabilitySchemaMigration: Sendable, Equatable, Hashable {
    func migrate(_ existing: CapabilityStoreSnapshot?) -> CapabilitySchemaMigrationResult {
        guard let existing else {
            return CapabilitySchemaMigrationResult(
                disposition: .initializedEmpty,
                snapshot: .empty,
                backup: nil
            )
        }

        guard existing.schema.version == capabilityStoreSchemaVersion, existing.schema.isAdditive else {
            let quarantine = CapabilityStoreQuarantine(
                id: "capability-schema-\(existing.schema.version)",
                reason: "Unsupported Capability schema was quarantined without rewriting content.",
                observedSchemaVersion: existing.schema.version
            )
            let quarantined = CapabilityStoreSnapshot(
                schema: existing.schema,
                revision: existing.revision,
                records: existing.records,
                evidenceRelationships: existing.evidenceRelationships,
                deletionTombstones: existing.deletionTombstones,
                quarantines: existing.quarantines + [quarantine],
                checkpoint: existing.checkpoint
            )
            return CapabilitySchemaMigrationResult(
                disposition: .quarantined,
                snapshot: quarantined,
                backup: CapabilityStoreBackup(snapshot: existing, events: [])
            )
        }

        return CapabilitySchemaMigrationResult(
            disposition: .unchanged,
            snapshot: existing,
            backup: CapabilityStoreBackup(snapshot: existing, events: [])
        )
    }
}
