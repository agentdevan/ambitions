import AmbitionsRuntimeSQLite
import Foundation

let runtimeCanonicalReplaySchemaVersion = 4
let runtimeCanonicalReplayCheckpointVersion = 1

struct RuntimeCanonicalReplayCursor: Codable, Sendable, Equatable, Hashable {
    let sequence: UInt64
    let eventID: String
    let eventHash: String

    var isWellFormed: Bool {
        self == Self.emptySource || (sequence > 0 &&
            RuntimeEventID(rawValue: eventID)?.rawValue == eventID &&
            RuntimeStoreManifestCodec.isSHA256Hex(eventHash))
    }

    static let emptySource = Self(
        sequence: 0, eventID: "runtime.empty-source",
        eventHash: RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
    )

    var typedEventID: RuntimeEventID? { RuntimeEventID(rawValue: eventID) }
    var typedEventHash: SHA256Digest? { try? SHA256Digest(hexadecimal: eventHash) }

    func matchesSourceAnchor(eventID candidateEventID: String, eventHash candidateEventHash: String) -> Bool {
        RuntimeEventID(rawValue: candidateEventID) == typedEventID &&
            (try? SHA256Digest(hexadecimal: candidateEventHash)) == typedEventHash
    }
}

enum RuntimeCanonicalReplaySourceChain {
    private struct Material: Codable {
        let priorChainDigest: SHA256Digest
        let sequence: UInt64
        let eventID: RuntimeEventID
        let eventHash: SHA256Digest
        let sourceDigest: SHA256Digest
        let previousEventHash: SHA256Digest?
    }

    static let emptyDigest = SHA256Digest.digest(Data("ambitions.runtime.replay.source-chain.v1".utf8))

    static func advance(
        prior: SHA256Digest,
        lineage: RuntimeSemanticEventLineage
    ) throws -> SHA256Digest {
        try advance(
            prior: prior,
            sequence: lineage.sequence,
            eventID: lineage.eventID,
            eventHash: lineage.eventHash,
            sourceDigest: lineage.sourceDigest,
            previousEventHash: lineage.previousEventHash
        )
    }

    static func advance(
        prior: SHA256Digest,
        sequence: UInt64,
        eventID: RuntimeEventID,
        eventHash: SHA256Digest,
        sourceDigest: SHA256Digest,
        previousEventHash: SHA256Digest?
    ) throws -> SHA256Digest {
        try SHA256Digest.digest(canonicalEncoding: Material(
            priorChainDigest: prior,
            sequence: sequence,
            eventID: eventID,
            eventHash: eventHash,
            sourceDigest: sourceDigest,
            previousEventHash: previousEventHash
        ))
    }
}

enum RuntimeCanonicalReplayInvariantCode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sequenceDiscontinuity = "sequence_discontinuity"
    case eventIdentityMismatch = "event_identity_mismatch"
    case sourceDigestMismatch = "source_digest_mismatch"
    case eventDigestMismatch = "event_digest_mismatch"
    case eventHashMismatch = "event_hash_mismatch"
    case predecessorHashMismatch = "predecessor_hash_mismatch"
    case causationMismatch = "causation_mismatch"
    case aggregateRevisionMismatch = "aggregate_revision_mismatch"
    case aggregateStateMismatch = "aggregate_state_mismatch"
    case aggregateMissing = "aggregate_missing"
    case silentIdentityReuse = "silent_identity_reuse"
    case unknownOrCorruptEvent = "unknown_or_corrupt_event"
    case quarantinePresent = "quarantine_present"
    case checkpointCorrupt = "checkpoint_corrupt"
    case liveStateDivergence = "live_state_divergence"
    case liveTombstoneDivergence = "live_tombstone_divergence"
    case tombstoneAuthorityMismatch = "tombstone_authority_mismatch"
    case tombstoneReactivation = "tombstone_reactivation"
    case legacyReplayAmbiguous = "legacy_replay_ambiguous"
}

struct RuntimeCanonicalReplayDivergence: Sendable, Equatable {
    let code: RuntimeCanonicalReplayInvariantCode
    let lastVerifiedCursor: RuntimeCanonicalReplayCursor?
    let divergentEventID: String?
    let divergentSequence: UInt64?
    let expectedHash: String?
    let observedHash: String?
    let expectedRevision: UInt64?
    let observedRevision: UInt64?
    let quarantineReference: String?
    /// Deliberately always nil. Divergence evidence is safe for diagnostics
    /// and never contains event, aggregate, or user payload bytes.
    let privatePayload: String? = nil
}

struct RuntimeCanonicalReplayAggregate: Codable, Sendable, Equatable {
    let state: RuntimeCanonicalAggregateState
    let canonicalBytes: Data
    let stateDigest: String
    let lastEvent: RuntimeCanonicalReplayCursor
}

struct RuntimeCanonicalReplayTombstone: Codable, Sendable, Equatable, Hashable {
    let aggregate: RuntimeSemanticAggregate
    let terminalRevision: UInt64
    let reason: RuntimeCanonicalTombstoneReason
    let causalCursor: RuntimeCanonicalReplayCursor
    let predecessorDigest: String
    let retentionDisposition: RuntimeCanonicalTombstoneRetentionDisposition
    let recoveryDisposition: RuntimeCanonicalTombstoneRecoveryDisposition

    var paritySortKey: String {
        "\(aggregate.kind.rawValue)\u{0}\(aggregate.id.rawValue)"
    }
}

struct RuntimeCanonicalReconstruction: Codable, Sendable, Equatable {
    let cursor: RuntimeCanonicalReplayCursor?
    let lastCorrelationID: String?
    let aggregates: [RuntimeCanonicalReplayAggregate]
    let tombstones: [RuntimeCanonicalReplayTombstone]
    let stateDigest: String

    static let empty = RuntimeCanonicalReconstruction(empty: ())

    private init(empty: Void) {
        cursor = nil
        lastCorrelationID = nil
        aggregates = []
        tombstones = []
        stateDigest = LocalRuntimeStorageChecksum.sha256Hex(for: Data())
    }

    init(
        cursor: RuntimeCanonicalReplayCursor?,
        lastCorrelationID: String? = nil,
        aggregates: [RuntimeCanonicalReplayAggregate],
        tombstones: [RuntimeCanonicalReplayTombstone]
    ) throws {
        if cursor == nil {
            guard lastCorrelationID == nil else { throw RuntimeCanonicalReplayError.corruptAuthority }
        } else {
            guard let lastCorrelationID,
                  (try? RuntimeCorrelationID(validating: lastCorrelationID)) != nil else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
        }
        let orderedAggregates = aggregates.sorted {
            ($0.state.aggregate.kind.rawValue, $0.state.aggregate.id.rawValue) <
                ($1.state.aggregate.kind.rawValue, $1.state.aggregate.id.rawValue)
        }
        let orderedTombstones = tombstones.sorted {
            ($0.aggregate.kind.rawValue, $0.aggregate.id.rawValue) <
                ($1.aggregate.kind.rawValue, $1.aggregate.id.rawValue)
        }
        guard Set(orderedAggregates.map {
            "\($0.state.aggregate.kind.rawValue)\u{0}\($0.state.aggregate.id.rawValue)"
        }).count == orderedAggregates.count,
              Set(orderedTombstones.map {
                  "\($0.aggregate.kind.rawValue)\u{0}\($0.aggregate.id.rawValue)"
              }).count == orderedTombstones.count else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        self.cursor = cursor
        self.lastCorrelationID = lastCorrelationID
        self.aggregates = orderedAggregates
        self.tombstones = orderedTombstones
        stateDigest = try Self.digest(
            cursor: cursor,
            lastCorrelationID: lastCorrelationID,
            aggregates: orderedAggregates,
            tombstones: orderedTombstones
        )
    }

    private static func digest(
        cursor: RuntimeCanonicalReplayCursor?,
        lastCorrelationID: String?,
        aggregates: [RuntimeCanonicalReplayAggregate],
        tombstones: [RuntimeCanonicalReplayTombstone]
    ) throws -> String {
        struct Material: Codable {
            let cursor: RuntimeCanonicalReplayCursor?
            let lastCorrelationID: String?
            let aggregateDigests: [String]
            let tombstones: [RuntimeCanonicalReplayTombstone]
        }
        return try RuntimeCanonicalReplayCoding.digest(Material(
            cursor: cursor,
            lastCorrelationID: lastCorrelationID,
            aggregateDigests: aggregates.map(
                { "\($0.state.aggregate.kind.rawValue):\($0.state.aggregate.id.rawValue):\($0.stateDigest)" }
            ),
            tombstones: tombstones
        ))
    }
}

enum RuntimeCanonicalReplayReduction: Sendable, Equatable {
    case accepted(RuntimeCanonicalReconstruction)
    case blocked(RuntimeCanonicalReplayDivergence, RuntimeCanonicalReconstruction)
}

enum RuntimeCanonicalReplayResult: Sendable, Equatable {
    case complete(RuntimeCanonicalReconstruction)
    case blocked(RuntimeCanonicalReplayDivergence, RuntimeCanonicalReconstruction)
}

enum RuntimeCanonicalReplayError: Error, Sendable, Equatable {
    case migrationRequired(expected: Int, actual: Int)
    case corruptAuthority
    case checkpointMismatch
    case staleCompactionPlan
    case destructivePruneUnavailable
}

extension RuntimeCanonicalReplayError: CustomStringConvertible, LocalizedError {
    var description: String {
        switch self {
        case let .migrationRequired(expected, actual):
            "Canonical replay schema migration is required (expected \(expected), actual \(actual))."
        case .corruptAuthority: "Canonical replay authority is corrupt."
        case .checkpointMismatch: "Canonical replay checkpoint does not match authority."
        case .staleCompactionPlan: "Canonical compaction evidence became stale."
        case .destructivePruneUnavailable: "Destructive compaction is unavailable until downstream retention authority exists."
        }
    }
    var errorDescription: String? { description }
}

struct RuntimeCanonicalReplayReducer: Sendable {
    func apply(
        _ record: CanonicalRuntimeSemanticEventRecord,
        to reconstruction: RuntimeCanonicalReconstruction
    ) -> RuntimeCanonicalReplayReduction {
        do {
            let lineage = record.lineage
            let cursor = RuntimeCanonicalReplayCursor(
                sequence: lineage.sequence,
                eventID: lineage.eventID.rawValue,
                eventHash: lineage.eventHash.hexadecimal
            )
            guard cursor.isWellFormed else {
                return blocked(.eventIdentityMismatch, record: record, reconstruction: reconstruction)
            }
            let expectedSequence = (reconstruction.cursor?.sequence ?? 0) + 1
            guard cursor.sequence == expectedSequence else {
                return blocked(
                    .sequenceDiscontinuity, record: record, reconstruction: reconstruction,
                    expectedRevision: expectedSequence, observedRevision: cursor.sequence
                )
            }
            guard lineage.previousEventHash?.hexadecimal == reconstruction.cursor?.eventHash else {
                return blocked(
                    .predecessorHashMismatch, record: record, reconstruction: reconstruction,
                    expectedHash: reconstruction.cursor?.eventHash,
                    observedHash: lineage.previousEventHash?.hexadecimal
                )
            }
            // The bounded store reader has already proven that any causation
            // points to an earlier event in the same correlation. It may be a
            // non-immediate ancestor, so the reducer must not narrow that model.
            guard SHA256Digest.digest(record.sourceBytes) == lineage.sourceDigest else {
                return blocked(.sourceDigestMismatch, record: record, reconstruction: reconstruction)
            }
            guard try record.recomputedEventHash() == lineage.eventHash else {
                return blocked(.eventHashMismatch, record: record, reconstruction: reconstruction)
            }
            let mutation = record.event.mutation
            guard let primary = mutation.primaryAggregate,
                  mutation.aggregateTransitions.isEmpty == false else {
                return blocked(.legacyReplayAmbiguous, record: record, reconstruction: reconstruction)
            }
            guard mutation.aggregateID == lineage.aggregate.id,
                  primary == lineage.aggregate,
                  mutation.resultingRevision == lineage.canonicalAggregateRevision else {
                return blocked(.eventIdentityMismatch, record: record, reconstruction: reconstruction)
            }
            guard let primaryTransition = mutation.aggregateTransitions.first(where: { $0.aggregate == primary }),
                  primaryTransition.priorRevision == mutation.priorRevision,
                  primaryTransition.resultingRevision == mutation.resultingRevision else {
                return blocked(.eventIdentityMismatch, record: record, reconstruction: reconstruction)
            }
            var aggregates = reconstruction.aggregates
            var tombstones = reconstruction.tombstones
            for transition in mutation.aggregateTransitions {
                let key = aggregateKey(transition.aggregate)
                let prior = aggregates.first { aggregateKey($0.state.aggregate) == key }
                if transition.priorRevision == nil {
                    guard prior == nil,
                          tombstones.contains(where: { aggregateKey($0.aggregate) == key }) == false else {
                        return blocked(.silentIdentityReuse, record: record, reconstruction: reconstruction)
                    }
                } else {
                    guard let prior else {
                        return blocked(.aggregateMissing, record: record, reconstruction: reconstruction)
                    }
                    guard transition.priorRevision == prior.state.revision else {
                        return blocked(
                            .aggregateRevisionMismatch, record: record, reconstruction: reconstruction,
                            expectedRevision: prior.state.revision,
                            observedRevision: transition.priorRevision
                        )
                    }
                    guard prior.state.lifecycle != .tombstoned,
                          tombstones.contains(where: { aggregateKey($0.aggregate) == key }) == false else {
                        return blocked(.tombstoneReactivation, record: record, reconstruction: reconstruction)
                    }
                }
                let state = try RuntimeCanonicalAggregateStateCodec().decode(transition.canonicalStateBytes)
                guard state.aggregate == transition.aggregate,
                      state.revision == transition.resultingRevision,
                      state.lifecycle == transition.lifecycle,
                      state.transition == transition.transition,
                      state.commandPayload == record.event.commandPayload,
                      state.changedObjectIDs == mutation.changedObjectIDs,
                      transition.canonicalStateDigest == LocalRuntimeStorageChecksum.sha256Hex(
                          for: transition.canonicalStateBytes
                      ) else {
                    return blocked(.aggregateStateMismatch, record: record, reconstruction: reconstruction)
                }
                aggregates.removeAll { aggregateKey($0.state.aggregate) == key }
                aggregates.append(RuntimeCanonicalReplayAggregate(
                    state: state,
                    canonicalBytes: transition.canonicalStateBytes,
                    stateDigest: transition.canonicalStateDigest,
                    lastEvent: cursor
                ))
                if transition.lifecycle == .tombstoned {
                    guard let prior, let authority = transition.tombstone else {
                        return blocked(.aggregateMissing, record: record, reconstruction: reconstruction)
                    }
                    guard authority.predecessorDigest == prior.stateDigest else {
                        return blocked(
                            .tombstoneAuthorityMismatch, record: record, reconstruction: reconstruction,
                            expectedHash: prior.stateDigest, observedHash: authority.predecessorDigest
                        )
                    }
                    tombstones.removeAll { aggregateKey($0.aggregate) == key }
                    tombstones.append(RuntimeCanonicalReplayTombstone(
                        aggregate: transition.aggregate,
                        terminalRevision: transition.resultingRevision,
                        reason: authority.reason,
                        causalCursor: cursor,
                        predecessorDigest: authority.predecessorDigest,
                        retentionDisposition: authority.retentionDisposition,
                        recoveryDisposition: authority.recoveryDisposition
                    ))
                } else if transition.tombstone != nil {
                    return blocked(.tombstoneAuthorityMismatch, record: record, reconstruction: reconstruction)
                }
            }
            return .accepted(try RuntimeCanonicalReconstruction(
                cursor: cursor,
                lastCorrelationID: lineage.correlationID.rawValue,
                aggregates: aggregates,
                tombstones: tombstones
            ))
        } catch {
            return blocked(.unknownOrCorruptEvent, record: record, reconstruction: reconstruction)
        }
    }

    private func blocked(
        _ code: RuntimeCanonicalReplayInvariantCode,
        record: CanonicalRuntimeSemanticEventRecord,
        reconstruction: RuntimeCanonicalReconstruction,
        expectedHash: String? = nil,
        observedHash: String? = nil,
        expectedRevision: UInt64? = nil,
        observedRevision: UInt64? = nil
    ) -> RuntimeCanonicalReplayReduction {
        .blocked(RuntimeCanonicalReplayDivergence(
            code: code,
            lastVerifiedCursor: reconstruction.cursor,
            divergentEventID: record.lineage.eventID.rawValue,
            divergentSequence: record.lineage.sequence,
            expectedHash: expectedHash,
            observedHash: observedHash,
            expectedRevision: expectedRevision,
            observedRevision: observedRevision,
            quarantineReference: nil
        ), reconstruction)
    }

    private func aggregateKey(_ aggregate: RuntimeSemanticAggregate) -> String {
        "\(aggregate.kind.rawValue)\u{0}\(aggregate.id.rawValue)"
    }

}

struct RuntimeCanonicalReplayCheckpoint: Codable, Sendable, Equatable {
    let version: Int
    let highWaterCursor: RuntimeCanonicalReplayCursor
    let sourceChainDigest: String
    let lastCorrelationID: String
    let aggregates: [RuntimeCanonicalReplayAggregate]
    let tombstones: [RuntimeCanonicalReplayTombstone]
    let stateDigest: String
    let createdAt: Date
    let manifestDigest: String

    fileprivate static func make(
        reconstruction: RuntimeCanonicalReconstruction,
        sourceChainDigest: String,
        createdAt: Date
    ) throws -> RuntimeCanonicalReplayCheckpoint {
        guard let cursor = reconstruction.cursor, cursor.isWellFormed,
              let lastCorrelationID = reconstruction.lastCorrelationID,
              RuntimeStoreManifestCodec.isSHA256Hex(sourceChainDigest),
              createdAt.timeIntervalSince1970.isFinite,
              createdAt.timeIntervalSince1970 >= 0,
              Date(timeIntervalSince1970: Double(try RuntimeSemanticEventHashing.milliseconds(createdAt)) / 1_000) == createdAt else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let material = ManifestMaterial(
            version: runtimeCanonicalReplayCheckpointVersion,
            highWaterCursor: cursor,
            sourceChainDigest: sourceChainDigest,
            lastCorrelationID: lastCorrelationID,
            aggregates: reconstruction.aggregates,
            tombstones: reconstruction.tombstones,
            stateDigest: reconstruction.stateDigest,
            createdAt: createdAt
        )
        return RuntimeCanonicalReplayCheckpoint(
            version: material.version,
            highWaterCursor: material.highWaterCursor,
            sourceChainDigest: material.sourceChainDigest,
            lastCorrelationID: material.lastCorrelationID,
            aggregates: material.aggregates,
            tombstones: material.tombstones,
            stateDigest: material.stateDigest,
            createdAt: material.createdAt,
            manifestDigest: try RuntimeCanonicalReplayCoding.digest(material)
        )
    }

#if DEBUG
    static func testOnlyMake(
        reconstruction: RuntimeCanonicalReconstruction,
        sourceChainDigest: String,
        createdAt: Date
    ) throws -> RuntimeCanonicalReplayCheckpoint {
        try make(
            reconstruction: reconstruction,
            sourceChainDigest: sourceChainDigest,
            createdAt: createdAt
        )
    }
#endif

    fileprivate struct ManifestMaterial: Codable {
        let version: Int
        let highWaterCursor: RuntimeCanonicalReplayCursor
        let sourceChainDigest: String
        let lastCorrelationID: String
        let aggregates: [RuntimeCanonicalReplayAggregate]
        let tombstones: [RuntimeCanonicalReplayTombstone]
        let stateDigest: String
        let createdAt: Date
    }
}

struct RuntimeCanonicalReplayCheckpointCodec: Sendable {
    func encode(_ checkpoint: RuntimeCanonicalReplayCheckpoint) throws -> Data {
        guard checkpoint.version == runtimeCanonicalReplayCheckpointVersion,
              checkpoint.highWaterCursor.isWellFormed,
              RuntimeStoreManifestCodec.isSHA256Hex(checkpoint.sourceChainDigest),
              RuntimeStoreManifestCodec.isSHA256Hex(checkpoint.stateDigest),
              checkpoint.manifestDigest == try manifestDigest(checkpoint) else {
            throw RuntimeCanonicalReplayError.checkpointMismatch
        }
        return try RuntimeCanonicalReplayCoding.encode(checkpoint)
    }

    func decode(_ bytes: Data) throws -> RuntimeCanonicalReplayCheckpoint {
        let checkpoint: RuntimeCanonicalReplayCheckpoint = try RuntimeCanonicalReplayCoding.decode(bytes)
        guard try encode(checkpoint) == bytes else {
            throw RuntimeCanonicalReplayError.checkpointMismatch
        }
        return checkpoint
    }

    private func manifestDigest(_ checkpoint: RuntimeCanonicalReplayCheckpoint) throws -> String {
        try RuntimeCanonicalReplayCoding.digest(RuntimeCanonicalReplayCheckpoint.ManifestMaterial(
            version: checkpoint.version,
            highWaterCursor: checkpoint.highWaterCursor,
            sourceChainDigest: checkpoint.sourceChainDigest,
            lastCorrelationID: checkpoint.lastCorrelationID,
            aggregates: checkpoint.aggregates,
            tombstones: checkpoint.tombstones,
            stateDigest: checkpoint.stateDigest,
            createdAt: checkpoint.createdAt
        ))
    }
}

enum RuntimeCanonicalRetentionBlocker: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unknownOrCorruptData = "unknown_or_corrupt_data"
    case quarantinePresent = "quarantine_present"
    case unresolvedProjectionWork = "unresolved_projection_work"
    case unresolvedExternalWork = "unresolved_external_work"
    case retainedReceipt = "retained_receipt"
    case retainedIdempotency = "retained_idempotency"
    case retainedLineage = "retained_lineage"
    case recoveryRequired = "recovery_required"
    case explicitHold = "explicit_hold"
    case downstreamAuthorityUnavailable = "downstream_authority_unavailable"
}

struct RuntimeCanonicalRetentionEvidence: Sendable, Equatable {
    let hasUnknownOrCorruptEvents: Bool
    let hasQuarantineOccurrences: Bool
    let hasUnresolvedProjectionWork: Bool
    let hasUnresolvedExternalWork: Bool
    let hasRetainedReceipts: Bool
    let hasRetainedIdempotency: Bool
    let hasRetainedLineage: Bool
    let hasRecoveryNeeds: Bool
    let hasExplicitHolds: Bool
    let downstreamReceiptPolicyAvailable: Bool
    let downstreamExternalPolicyAvailable: Bool
    let downstreamBlobPolicyAvailable: Bool
}

struct RuntimeCanonicalRetentionEligibility: Sendable, Equatable {
    let checkpointAllowed: Bool
    let destructivePruneAllowed: Bool
    let blockers: [RuntimeCanonicalRetentionBlocker]
}

struct RuntimeCanonicalRetentionPolicy: Sendable {
    func evaluate(_ evidence: RuntimeCanonicalRetentionEvidence) -> RuntimeCanonicalRetentionEligibility {
        var blockers: [RuntimeCanonicalRetentionBlocker] = []
        if evidence.hasUnknownOrCorruptEvents { blockers.append(.unknownOrCorruptData) }
        if evidence.hasQuarantineOccurrences { blockers.append(.quarantinePresent) }
        if evidence.hasUnresolvedProjectionWork { blockers.append(.unresolvedProjectionWork) }
        if evidence.hasUnresolvedExternalWork { blockers.append(.unresolvedExternalWork) }
        if evidence.hasRetainedReceipts { blockers.append(.retainedReceipt) }
        if evidence.hasRetainedIdempotency { blockers.append(.retainedIdempotency) }
        if evidence.hasRetainedLineage { blockers.append(.retainedLineage) }
        if evidence.hasRecoveryNeeds { blockers.append(.recoveryRequired) }
        if evidence.hasExplicitHolds { blockers.append(.explicitHold) }
        if evidence.downstreamReceiptPolicyAvailable == false ||
            evidence.downstreamExternalPolicyAvailable == false ||
            evidence.downstreamBlobPolicyAvailable == false {
            blockers.append(.downstreamAuthorityUnavailable)
        }
        blockers = Array(Set(blockers)).sorted { $0.rawValue < $1.rawValue }
        return RuntimeCanonicalRetentionEligibility(
            checkpointAllowed: evidence.hasUnknownOrCorruptEvents == false &&
                evidence.hasQuarantineOccurrences == false,
            destructivePruneAllowed: blockers.isEmpty,
            blockers: blockers
        )
    }
}

enum RuntimeCanonicalCompactionDisposition: String, Codable, Sendable, Equatable, Hashable {
    case blocked
    case checkpointOnly = "checkpoint_only"
    case prune
}

struct RuntimeCanonicalCompactionPlan: Codable, Sendable, Equatable {
    let disposition: RuntimeCanonicalCompactionDisposition
    let revalidationAnchor: RuntimeCanonicalReplayCursor
    let stateDigest: String
    let blockers: [RuntimeCanonicalRetentionBlocker]
    let pruneThroughSequence: UInt64?
}

struct RuntimeCanonicalCompactionPlanner: Sendable {
    func plan(
        verifiedCursor: RuntimeCanonicalReplayCursor,
        stateDigest: String,
        eligibility: RuntimeCanonicalRetentionEligibility
    ) -> RuntimeCanonicalCompactionPlan {
        let disposition: RuntimeCanonicalCompactionDisposition = eligibility.checkpointAllowed
            ? .checkpointOnly
            : .blocked
        // T12-T14 do not yet exist. Even apparently empty evidence cannot
        // prove downstream retention, so T10 never emits a prune plan.
        return RuntimeCanonicalCompactionPlan(
            disposition: disposition,
            revalidationAnchor: verifiedCursor,
            stateDigest: stateDigest,
            blockers: eligibility.blockers,
            pruneThroughSequence: nil
        )
    }
}

enum CanonicalRuntimeReplaySchemaPlan {
    static let sourceSchemaVersion = runtimeAtomicCommitSchemaVersion
    static let targetSchemaVersion = runtimeCanonicalReplaySchemaVersion
    static let tables: Set<String> = [
        "runtime_replay_checkpoints",
        "runtime_replay_checkpoint_aggregates",
        "runtime_replay_checkpoint_tombstones",
        "runtime_replay_retention_holds",
        "runtime_replay_quarantine_occurrences",
        "runtime_replay_verified_high_water",
        "runtime_replay_verified_reconstructions",
    ]
    static let indexes: Set<String> = [
        "runtime_replay_checkpoints_sequence_idx",
        "runtime_replay_checkpoint_aggregates_order_idx",
        "runtime_replay_checkpoint_tombstones_order_idx",
        "runtime_replay_retention_holds_sequence_idx",
        "runtime_replay_quarantine_occurrences_source_idx",
        "runtime_replay_verified_reconstructions_digest_idx",
    ]
    static let statements: [String] = [
        """
        CREATE TABLE runtime_replay_checkpoints (
            checkpoint_id TEXT PRIMARY KEY CHECK (length(checkpoint_id) > 0),
            high_water_sequence INTEGER NOT NULL UNIQUE CHECK (high_water_sequence > 0),
            high_water_event_id TEXT NOT NULL CHECK (length(high_water_event_id) > 0),
            high_water_event_hash TEXT NOT NULL CHECK (length(high_water_event_hash) = 64 AND high_water_event_hash NOT GLOB '*[^0-9a-f]*'),
            source_chain_digest TEXT NOT NULL CHECK (length(source_chain_digest) = 64 AND source_chain_digest NOT GLOB '*[^0-9a-f]*'),
            checkpoint_version INTEGER NOT NULL CHECK (checkpoint_version > 0),
            state_digest TEXT NOT NULL CHECK (length(state_digest) = 64 AND state_digest NOT GLOB '*[^0-9a-f]*'),
            manifest_digest TEXT NOT NULL UNIQUE CHECK (length(manifest_digest) = 64 AND manifest_digest NOT GLOB '*[^0-9a-f]*'),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_replay_checkpoints_sequence_idx ON runtime_replay_checkpoints(high_water_sequence, checkpoint_id)",
        """
        CREATE TABLE runtime_replay_checkpoint_aggregates (
            checkpoint_id TEXT NOT NULL,
            aggregate_kind TEXT NOT NULL,
            aggregate_id TEXT NOT NULL,
            payload BLOB NOT NULL CHECK (length(payload) <= 1048576),
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            PRIMARY KEY (checkpoint_id, aggregate_kind, aggregate_id),
            FOREIGN KEY (checkpoint_id) REFERENCES runtime_replay_checkpoints(checkpoint_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_replay_checkpoint_aggregates_order_idx ON runtime_replay_checkpoint_aggregates(checkpoint_id, aggregate_kind, aggregate_id)",
        """
        CREATE TRIGGER runtime_replay_checkpoint_aggregates_immutable_update
        BEFORE UPDATE ON runtime_replay_checkpoint_aggregates
        BEGIN SELECT RAISE(ABORT, 'immutable replay checkpoint aggregate'); END
        """,
        """
        CREATE TRIGGER runtime_replay_checkpoint_aggregates_immutable_delete
        BEFORE DELETE ON runtime_replay_checkpoint_aggregates
        BEGIN SELECT RAISE(ABORT, 'immutable replay checkpoint aggregate'); END
        """,
        """
        CREATE TABLE runtime_replay_checkpoint_tombstones (
            checkpoint_id TEXT NOT NULL,
            aggregate_kind TEXT NOT NULL,
            aggregate_id TEXT NOT NULL,
            payload BLOB NOT NULL CHECK (length(payload) <= 1048576),
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            PRIMARY KEY (checkpoint_id, aggregate_kind, aggregate_id),
            FOREIGN KEY (checkpoint_id) REFERENCES runtime_replay_checkpoints(checkpoint_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_replay_checkpoint_tombstones_order_idx ON runtime_replay_checkpoint_tombstones(checkpoint_id, aggregate_kind, aggregate_id)",
        """
        CREATE TRIGGER runtime_replay_checkpoint_tombstones_immutable_update
        BEFORE UPDATE ON runtime_replay_checkpoint_tombstones
        BEGIN SELECT RAISE(ABORT, 'immutable replay checkpoint tombstone'); END
        """,
        """
        CREATE TRIGGER runtime_replay_checkpoint_tombstones_immutable_delete
        BEFORE DELETE ON runtime_replay_checkpoint_tombstones
        BEGIN SELECT RAISE(ABORT, 'immutable replay checkpoint tombstone'); END
        """,
        """
        CREATE TRIGGER runtime_replay_checkpoints_immutable_update
        BEFORE UPDATE ON runtime_replay_checkpoints
        BEGIN SELECT RAISE(ABORT, 'immutable replay checkpoint'); END
        """,
        """
        CREATE TRIGGER runtime_replay_checkpoints_immutable_delete
        BEFORE DELETE ON runtime_replay_checkpoints
        BEGIN SELECT RAISE(ABORT, 'immutable replay checkpoint'); END
        """,
        """
        CREATE TABLE runtime_replay_retention_holds (
            hold_id TEXT PRIMARY KEY CHECK (length(hold_id) > 0),
            hold_kind TEXT NOT NULL CHECK (length(hold_kind) > 0),
            through_sequence INTEGER NOT NULL CHECK (through_sequence > 0),
            through_event_id TEXT NOT NULL CHECK (length(through_event_id) > 0),
            through_event_hash TEXT NOT NULL CHECK (length(through_event_hash) = 64 AND through_event_hash NOT GLOB '*[^0-9a-f]*'),
            reason_code TEXT NOT NULL CHECK (length(reason_code) > 0),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            released_at_ms INTEGER CHECK (released_at_ms IS NULL OR released_at_ms >= created_at_ms)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_replay_retention_holds_sequence_idx ON runtime_replay_retention_holds(through_sequence, hold_id)",
        """
        CREATE TABLE runtime_replay_quarantine_occurrences (
            occurrence_id TEXT PRIMARY KEY CHECK (length(occurrence_id) = 64 AND occurrence_id NOT GLOB '*[^0-9a-f]*'),
            quarantine_key TEXT NOT NULL,
            source_event_id TEXT,
            source_event_sequence INTEGER,
            observed_at_ms INTEGER NOT NULL CHECK (observed_at_ms >= 0),
            CHECK (source_event_sequence IS NULL OR source_event_sequence > 0),
            FOREIGN KEY (quarantine_key) REFERENCES runtime_semantic_event_quarantine(quarantine_key)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_replay_quarantine_occurrences_source_idx ON runtime_replay_quarantine_occurrences(source_event_sequence, occurrence_id)",
        """
        CREATE TRIGGER runtime_replay_quarantine_occurrences_immutable_update
        BEFORE UPDATE ON runtime_replay_quarantine_occurrences
        BEGIN SELECT RAISE(ABORT, 'immutable quarantine occurrence'); END
        """,
        """
        CREATE TRIGGER runtime_replay_quarantine_occurrences_immutable_delete
        BEFORE DELETE ON runtime_replay_quarantine_occurrences
        BEGIN SELECT RAISE(ABORT, 'immutable quarantine occurrence'); END
        """,
        """
        CREATE TABLE runtime_replay_verified_high_water (
            singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1),
            event_sequence INTEGER NOT NULL CHECK (event_sequence > 0),
            event_id TEXT NOT NULL CHECK (length(event_id) > 0),
            event_hash TEXT NOT NULL CHECK (length(event_hash) = 64 AND event_hash NOT GLOB '*[^0-9a-f]*'),
            chain_anchor_digest TEXT NOT NULL CHECK (length(chain_anchor_digest) = 64 AND chain_anchor_digest NOT GLOB '*[^0-9a-f]*'),
            reconstruction_digest TEXT CHECK (reconstruction_digest IS NULL OR (length(reconstruction_digest) = 64 AND reconstruction_digest NOT GLOB '*[^0-9a-f]*')),
            verified_at_ms INTEGER NOT NULL CHECK (verified_at_ms >= 0)
        )
        """,
        """
        CREATE TABLE runtime_replay_verified_reconstructions (
            event_sequence INTEGER PRIMARY KEY CHECK (event_sequence > 0),
            event_id TEXT NOT NULL UNIQUE CHECK (length(event_id) > 0),
            event_hash TEXT NOT NULL UNIQUE CHECK (length(event_hash) = 64 AND event_hash NOT GLOB '*[^0-9a-f]*'),
            source_chain_digest TEXT NOT NULL CHECK (length(source_chain_digest) = 64 AND source_chain_digest NOT GLOB '*[^0-9a-f]*'),
            reconstruction_digest TEXT NOT NULL CHECK (length(reconstruction_digest) = 64 AND reconstruction_digest NOT GLOB '*[^0-9a-f]*'),
            verified_at_ms INTEGER NOT NULL CHECK (verified_at_ms >= 0)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_replay_verified_reconstructions_digest_idx ON runtime_replay_verified_reconstructions(reconstruction_digest, event_sequence)",
        """
        CREATE TRIGGER runtime_replay_verified_reconstructions_immutable_update
        BEFORE UPDATE ON runtime_replay_verified_reconstructions
        BEGIN SELECT RAISE(ABORT, 'immutable verified reconstruction'); END
        """,
        """
        CREATE TRIGGER runtime_replay_verified_reconstructions_immutable_delete
        BEFORE DELETE ON runtime_replay_verified_reconstructions
        BEGIN SELECT RAISE(ABORT, 'immutable verified reconstruction'); END
        """,
    ]

    static let stagedIntegratedStatements =
        CanonicalRuntimeCommitSchemaPlan.stagedIntegratedStatements + statements

    static func requireIntegratedSchema(in database: isolated SQLiteDatabase) throws {
        let rows = try database.query("PRAGMA user_version")
        guard case let .integer(version)? = rows.first?.values.first else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        if version == Int64(runtimeCanonicalAttachmentSchemaVersion) {
            try CanonicalRuntimeAttachmentSchemaPlan.requireIntegratedSchema(in: database)
            return
        }
        guard version == Int64(targetSchemaVersion) ||
                version == Int64(runtimeCanonicalProjectionSchemaVersion) ||
                version == Int64(runtimeCommittedReceiptSchemaVersion) else {
            throw RuntimeCanonicalReplayError.migrationRequired(
                expected: targetSchemaVersion,
                actual: Int(version)
            )
        }
        let schema = try database.query(
            """
            SELECT name, type, sql FROM sqlite_schema
            WHERE name LIKE 'runtime_%'
              AND type IN ('table', 'index', 'trigger')
            """
        )
        let includesProjections = version >= Int64(runtimeCanonicalProjectionSchemaVersion)
        let includesReceipts = version >= Int64(runtimeCommittedReceiptSchemaVersion)
        let statements = CanonicalRuntimeStore.schemaStatements + stagedIntegratedStatements +
            (includesProjections ? CanonicalRuntimeProjectionSchemaPlan.statements : []) +
            (includesReceipts ? CanonicalRuntimeCommittedReceiptSchemaPlan.statements : [])
        let expectedCatalog = try exactSchemaCatalog(statements)
        let observedCatalog = try exactObservedSchemaCatalog(schema)
        let expectedTables = CanonicalRuntimeStore.expectedRuntimeTables
            .union(CanonicalRuntimeSemanticEventSchemaPlan.tables)
            .union(CanonicalRuntimeCommitSchemaPlan.tables)
            .union(tables)
            .union(includesProjections ? CanonicalRuntimeProjectionSchemaPlan.tables : [])
            .union(includesReceipts ? CanonicalRuntimeCommittedReceiptSchemaPlan.tables : [])
        let expectedIndexes = CanonicalRuntimeStore.expectedRuntimeIndexes
            .union(CanonicalRuntimeSemanticEventSchemaPlan.indexes)
            .union(CanonicalRuntimeCommitSchemaPlan.indexes)
            .union(indexes)
            .union(includesProjections ? CanonicalRuntimeProjectionSchemaPlan.indexes : [])
            .union(includesReceipts ? CanonicalRuntimeCommittedReceiptSchemaPlan.indexes : [])
        guard Set(expectedCatalog.keys.filter { $0.hasPrefix("table:") }.map { String($0.dropFirst(6)) }) == expectedTables,
              Set(expectedCatalog.keys.filter { $0.hasPrefix("index:") }.map { String($0.dropFirst(6)) }) == expectedIndexes,
              observedCatalog == expectedCatalog else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        try requireExactSQLiteShape(statements: statements, database: database)
    }

    private static func exactSchemaCatalog(
        _ statements: [String]
    ) throws -> [String: String] {
        var result: [String: String] = [:]
        for statement in statements {
            let tokens = statement.split(whereSeparator: { $0.isWhitespace })
            guard tokens.count >= 3, tokens[0].uppercased() == "CREATE" else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
            let isVirtualTable = tokens.count >= 4 &&
                tokens[1].lowercased() == "virtual" && tokens[2].lowercased() == "table"
            let isUniqueIndex = tokens.count >= 4 &&
                tokens[1].lowercased() == "unique" && tokens[2].lowercased() == "index"
            let kind = isVirtualTable ? "table" : (isUniqueIndex ? "index" : tokens[1].lowercased())
            guard kind == "table" || kind == "index" || kind == "trigger" else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
            let name = (isVirtualTable || isUniqueIndex) ? tokens[3] : tokens[2]
            let key = "\(kind):\(name)"
            guard result.updateValue(normalizedSchemaSQL(statement), forKey: key) == nil else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
        }
        return result
    }

    private static func exactObservedSchemaCatalog(
        _ rows: [SQLiteRow]
    ) throws -> [String: String] {
        var result: [String: String] = [:]
        for row in rows {
            guard case let .text(kind)? = row.value(named: "type"),
                  case let .text(name)? = row.value(named: "name"),
                  case let .text(sql)? = row.value(named: "sql"),
                  result.updateValue(normalizedSchemaSQL(sql), forKey: "\(kind):\(name)") == nil else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
        }
        return result
    }

    private static func requireExactSQLiteShape(
        statements: [String],
        database: isolated SQLiteDatabase
    ) throws {
        let catalog = try exactSchemaCatalog(statements)
        let tableSQL = Dictionary(uniqueKeysWithValues: catalog.compactMap { key, sql -> (String, String)? in
            guard key.hasPrefix("table:") else { return nil }
            return (String(key.dropFirst(6)), sql)
        })
        for (table, sql) in tableSQL {
            if sql.contains(" using fts5") { continue }
            try requireSafeSchemaIdentifier(table)
            let columns = try database.query("PRAGMA table_xinfo('\(table)')")
            let expectedColumns = try topLevelDefinitions(sql).filter { definition in
                let upper = definition.uppercased()
                return upper.hasPrefix("PRIMARY KEY") == false &&
                    upper.hasPrefix("FOREIGN KEY") == false &&
                    upper.hasPrefix("UNIQUE") == false &&
                    upper.hasPrefix("CHECK") == false &&
                    upper.hasPrefix("CONSTRAINT") == false
            }
            guard columns.count == expectedColumns.count else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
            let tablePrimaryKey = try tablePrimaryKeyColumns(sql)
            let isWithoutRowID = sql.hasSuffix(" without rowid")
            var observedNames = Set<String>()
            for (offset, row) in columns.enumerated() {
                guard row.value(named: "cid") == .integer(Int64(offset)),
                      case let .text(name)? = row.value(named: "name"),
                      case let .text(type)? = row.value(named: "type"),
                      case let .integer(notNull)? = row.value(named: "notnull"),
                      case let .integer(primaryKeyOrder)? = row.value(named: "pk"),
                      case let .integer(hidden)? = row.value(named: "hidden"), hidden == 0,
                      observedNames.insert(name).inserted else {
                    throw RuntimeCanonicalReplayError.corruptAuthority
                }
                let expectedTokens = expectedColumns[offset].split(whereSeparator: { $0.isWhitespace })
                let expectedName = String(expectedTokens.first ?? "")
                let inlinePrimaryKey = expectedColumns[offset].contains(" primary key")
                let expectedPrimaryKeyOrder = tablePrimaryKey.firstIndex(of: expectedName)
                    .map { Int64($0 + 1) } ?? (inlinePrimaryKey ? 1 : 0)
                let expectedNotNull = expectedColumns[offset].contains(" not null") ||
                    (isWithoutRowID && expectedPrimaryKeyOrder > 0)
                let expectedDefault: SQLiteValue = expectedColumns[offset].contains(" default 0")
                    ? .text("0")
                    : .null
                guard expectedTokens.count >= 2,
                      name.lowercased() == expectedName.lowercased(),
                      type.lowercased() == expectedTokens[1].lowercased(),
                      notNull == (expectedNotNull ? 1 : 0),
                      primaryKeyOrder == expectedPrimaryKeyOrder,
                      row.value(named: "dflt_value") == expectedDefault else {
                    throw RuntimeCanonicalReplayError.corruptAuthority
                }
            }
            let foreignKeys = try database.query("PRAGMA foreign_key_list('\(table)')")
            let expectedForeignKeys = try Set(topLevelDefinitions(sql).flatMap(expectedForeignKeyShapes))
            let observedForeignKeys = try Set(foreignKeys.map { row -> ForeignKeyShape in
                guard case let .text(source)? = row.value(named: "from"),
                      case let .text(targetTable)? = row.value(named: "table"),
                      case let .text(target)? = row.value(named: "to"),
                      case let .integer(sequence)? = row.value(named: "seq"),
                      case let .text(onUpdate)? = row.value(named: "on_update"),
                      case let .text(onDelete)? = row.value(named: "on_delete"),
                      case let .text(match)? = row.value(named: "match"),
                      observedNames.contains(source),
                      tableSQL[targetTable] != nil,
                      try tableColumnNames(targetTable, database: database).contains(target) else {
                    throw RuntimeCanonicalReplayError.corruptAuthority
                }
                return ForeignKeyShape(
                    sequence: sequence,
                    source: source,
                    targetTable: targetTable,
                    target: target,
                    onUpdate: onUpdate.lowercased(),
                    onDelete: onDelete.lowercased(),
                    match: match.lowercased()
                )
            })
            guard observedForeignKeys == expectedForeignKeys else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
        }
        for (key, sql) in catalog where key.hasPrefix("index:") {
            let index = String(key.dropFirst(6))
            try requireSafeSchemaIdentifier(index)
            let expectedColumns = try indexColumnNames(sql)
            let rows = try database.query("PRAGMA index_xinfo('\(index)')")
            let observedColumns = try rows.compactMap { row -> (Int64, String)? in
                guard case let .integer(keyColumn)? = row.value(named: "key") else {
                    throw RuntimeCanonicalReplayError.corruptAuthority
                }
                guard keyColumn == 1 else { return nil }
                guard case let .integer(sequence)? = row.value(named: "seqno"),
                      case let .text(name)? = row.value(named: "name") else {
                    throw RuntimeCanonicalReplayError.corruptAuthority
                }
                return (sequence, name)
            }.sorted { $0.0 < $1.0 }.map(\.1)
            guard observedColumns == expectedColumns else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
        }
    }

    private static func tableColumnNames(
        _ table: String,
        database: isolated SQLiteDatabase
    ) throws -> Set<String> {
        try requireSafeSchemaIdentifier(table)
        return try Set(database.query("PRAGMA table_xinfo('\(table)')").map { row in
            guard case let .text(name)? = row.value(named: "name") else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
            return name
        })
    }

    private struct ForeignKeyShape: Hashable {
        let sequence: Int64
        let source: String
        let targetTable: String
        let target: String
        let onUpdate: String
        let onDelete: String
        let match: String
    }

    private static func expectedForeignKeyShapes(
        _ definition: String
    ) throws -> [ForeignKeyShape] {
        guard definition.uppercased().hasPrefix("FOREIGN KEY") else { return [] }
        guard let firstOpen = definition.firstIndex(of: "("),
              let firstClose = definition[firstOpen...].firstIndex(of: ")") else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let sources = String(definition[definition.index(after: firstOpen)..<firstClose])
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let remainder = String(definition[definition.index(after: firstClose)...])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let prefix = "references "
        guard remainder.lowercased().hasPrefix(prefix),
              let targetOpen = remainder.firstIndex(of: "("),
              let targetClose = remainder[targetOpen...].firstIndex(of: ")") else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let targetTable = String(remainder[
            remainder.index(remainder.startIndex, offsetBy: prefix.count)..<targetOpen
        ]).trimmingCharacters(in: .whitespacesAndNewlines)
        let targets = String(remainder[remainder.index(after: targetOpen)..<targetClose])
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard sources.count == targets.count, sources.isEmpty == false else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let policy = String(remainder[remainder.index(after: targetClose)...]).lowercased()
        let onUpdate = policy.contains("on update cascade") ? "cascade" :
            (policy.contains("on update restrict") ? "restrict" : "no action")
        let onDelete = policy.contains("on delete cascade") ? "cascade" :
            (policy.contains("on delete restrict") ? "restrict" : "no action")
        let match = policy.contains("match full") ? "full" :
            (policy.contains("match partial") ? "partial" : "none")
        return zip(sources, targets).enumerated().map { offset, pair in
            ForeignKeyShape(
                sequence: Int64(offset),
                source: pair.0,
                targetTable: targetTable,
                target: pair.1,
                onUpdate: onUpdate,
                onDelete: onDelete,
                match: match
            )
        }
    }

    private static func tablePrimaryKeyColumns(_ sql: String) throws -> [String] {
        guard let definition = try topLevelDefinitions(sql).first(where: {
            $0.uppercased().hasPrefix("PRIMARY KEY")
        }) else { return [] }
        guard let opening = definition.firstIndex(of: "("),
              let closing = definition[opening...].firstIndex(of: ")") else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        return String(definition[definition.index(after: opening)..<closing])
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }

    private static func requireSafeSchemaIdentifier(_ value: String) throws {
        guard value.isEmpty == false,
              value.unicodeScalars.allSatisfy({ CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_")).contains($0) }) else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
    }

    private static func topLevelDefinitions(_ sql: String) throws -> [String] {
        guard let opening = sql.firstIndex(of: "("),
              let closing = sql.lastIndex(of: ")"), opening < closing else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let body = sql[sql.index(after: opening)..<closing]
        var depth = 0
        var start = body.startIndex
        var result: [String] = []
        var index = body.startIndex
        while index < body.endIndex {
            switch body[index] {
            case "(": depth += 1
            case ")": depth -= 1
            case "," where depth == 0:
                result.append(String(body[start..<index]).trimmingCharacters(in: .whitespacesAndNewlines))
                start = body.index(after: index)
            default: break
            }
            guard depth >= 0 else { throw RuntimeCanonicalReplayError.corruptAuthority }
            index = body.index(after: index)
        }
        guard depth == 0 else { throw RuntimeCanonicalReplayError.corruptAuthority }
        result.append(String(body[start..<body.endIndex]).trimmingCharacters(in: .whitespacesAndNewlines))
        return result.filter { $0.isEmpty == false }
    }

    private static func indexColumnNames(_ sql: String) throws -> [String] {
        try topLevelDefinitions(sql).map { definition in
            let value = definition.trimmingCharacters(in: .whitespacesAndNewlines)
            guard value.isEmpty == false,
                  value.unicodeScalars.allSatisfy({ CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_")).contains($0) }) else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
            return value
        }
    }

    private static func normalizedSchemaSQL(_ sql: String) -> String {
        sql.split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
            .trimmingCharacters(in: CharacterSet(charactersIn: ";"))
            .lowercased()
    }
}

enum RuntimeCanonicalReplayEngine {
#if DEBUG
    static func testOnlyCheckpointHeaderBytes(
        _ checkpoint: RuntimeCanonicalReplayCheckpoint
    ) throws -> Data {
        try RuntimeCanonicalReplayCoding.encode(RuntimeCanonicalReplayCheckpointHeader(
            version: checkpoint.version,
            highWaterCursor: checkpoint.highWaterCursor,
            sourceChainDigest: checkpoint.sourceChainDigest,
            lastCorrelationID: checkpoint.lastCorrelationID,
            stateDigest: checkpoint.stateDigest,
            aggregateCount: checkpoint.aggregates.count,
            tombstoneCount: checkpoint.tombstones.count,
            createdAt: checkpoint.createdAt,
            manifestDigest: checkpoint.manifestDigest
        ))
    }
#endif

    static func loadCheckpointInTransaction(
        checkpointID: String? = nil,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalReplayCheckpoint? {
        try CanonicalRuntimeReplaySchemaPlan.requireIntegratedSchema(in: database)
        let predicate = checkpointID == nil ? "" : "WHERE checkpoint_id = ?"
        let rows = try database.query(
            """
            SELECT checkpoint_id, high_water_sequence, high_water_event_id,
                   high_water_event_hash, source_chain_digest, checkpoint_version, state_digest,
                   manifest_digest, payload, payload_checksum, created_at_ms
            FROM runtime_replay_checkpoints \(predicate)
            ORDER BY high_water_sequence DESC LIMIT 1
            """,
            bindings: checkpointID.map { [SQLiteBinding.text($0)] } ?? [],
            maximumDecodedBytes: 1_048_576
        )
        guard let row = rows.first,
              case let .text(storedID)? = row.value(named: "checkpoint_id"),
              case let .blob(headerBytes)? = row.value(named: "payload"),
              case let .text(headerChecksum)? = row.value(named: "payload_checksum"),
              headerChecksum == LocalRuntimeStorageChecksum.sha256Hex(for: headerBytes) else {
            if rows.isEmpty { return nil }
            throw RuntimeCanonicalReplayError.checkpointMismatch
        }
        let header: RuntimeCanonicalReplayCheckpointHeader = try RuntimeCanonicalReplayCoding.decode(headerBytes)
        guard header.aggregateCount >= 0, header.aggregateCount <= 10_000,
              header.tombstoneCount >= 0, header.tombstoneCount <= 10_000,
              header.highWaterCursor.isWellFormed,
              RuntimeStoreManifestCodec.isSHA256Hex(header.sourceChainDigest),
              header.highWaterCursor.sequence <= UInt64(Int64.max),
              row.value(named: "high_water_sequence") == .integer(Int64(header.highWaterCursor.sequence)),
              row.value(named: "high_water_event_id") == .text(header.highWaterCursor.eventID),
              row.value(named: "high_water_event_hash") == .text(header.highWaterCursor.eventHash),
              row.value(named: "source_chain_digest") == .text(header.sourceChainDigest),
              row.value(named: "checkpoint_version") == .integer(Int64(header.version)),
              row.value(named: "state_digest") == .text(header.stateDigest),
              row.value(named: "manifest_digest") == .text(header.manifestDigest),
              row.value(named: "created_at_ms") == .integer(try RuntimeSemanticEventHashing.milliseconds(header.createdAt)) else {
            throw RuntimeCanonicalReplayError.checkpointMismatch
        }
        let aggregates = try loadCheckpointAggregates(storedID, database: database)
        let tombstones = try loadCheckpointTombstones(storedID, database: database)
        guard aggregates.count == header.aggregateCount,
              tombstones.count == header.tombstoneCount else {
            throw RuntimeCanonicalReplayError.checkpointMismatch
        }
        let reconstruction = try RuntimeCanonicalReconstruction(
            cursor: header.highWaterCursor,
            lastCorrelationID: header.lastCorrelationID,
            aggregates: aggregates,
            tombstones: tombstones
        )
        guard reconstruction.stateDigest == header.stateDigest else {
            throw RuntimeCanonicalReplayError.checkpointMismatch
        }
        let checkpoint = try RuntimeCanonicalReplayCheckpoint.make(
            reconstruction: reconstruction,
            sourceChainDigest: header.sourceChainDigest,
            createdAt: header.createdAt
        )
        guard checkpoint.version == header.version,
              checkpoint.manifestDigest == header.manifestDigest,
              storedID == "checkpoint.\(header.highWaterCursor.sequence).\(header.manifestDigest)" else {
            throw RuntimeCanonicalReplayError.checkpointMismatch
        }
        let anchor = try database.query(
            "SELECT event_id, event_hash FROM runtime_semantic_events WHERE sequence = ? LIMIT 2",
            bindings: [.integer(Int64(header.highWaterCursor.sequence))]
        )
        guard anchor.count == 1,
              case let .text(anchorEventIDRaw)? = anchor[0].value(named: "event_id"),
              case let .text(anchorEventHashRaw)? = anchor[0].value(named: "event_hash"),
              header.highWaterCursor.matchesSourceAnchor(
                  eventID: anchorEventIDRaw,
                  eventHash: anchorEventHashRaw
              ) else {
            throw RuntimeCanonicalReplayError.checkpointMismatch
        }
        do {
            let actualSource = try CanonicalRuntimeSemanticEventStore
                .verifiedSourceChainDigestThrough(
                    header.highWaterCursor.sequence,
                    database: database
                )
            let verified = try verifiedReconstruction(
                at: header.highWaterCursor,
                stateDigest: header.stateDigest,
                database: database
            )
            guard actualSource.hexadecimal == header.sourceChainDigest,
                  verified.sourceChainDigest == actualSource,
                  verified.reconstructionDigest.hexadecimal == header.stateDigest,
                  let highWater = try verifiedHighWaterIntegrity(database: database),
                  highWater.cursor.sequence >= header.highWaterCursor.sequence else {
                throw RuntimeCanonicalReplayError.checkpointMismatch
            }
            if highWater.cursor.sequence == header.highWaterCursor.sequence {
                guard highWater.cursor == header.highWaterCursor,
                      highWater.sourceChainDigest == actualSource,
                      highWater.reconstructionDigest == verified.reconstructionDigest,
                      highWater.verifiedAtMilliseconds == verified.verifiedAtMilliseconds else {
                    throw RuntimeCanonicalReplayError.checkpointMismatch
                }
            }
        } catch {
            throw RuntimeCanonicalReplayError.checkpointMismatch
        }
        return checkpoint
    }

    static func replayInTransaction(
        database: isolated SQLiteDatabase,
        checkpointID: String? = nil
    ) throws -> RuntimeCanonicalReplayResult {
        try Task.checkCancellation()
        try CanonicalRuntimeReplaySchemaPlan.requireIntegratedSchema(in: database)
        var reconstruction: RuntimeCanonicalReconstruction
        var sourceChainDigest: SHA256Digest
        let anchor: RuntimeCanonicalReplayCursor?
        if let checkpointID {
            let checkpoint: RuntimeCanonicalReplayCheckpoint
            do {
                guard let loaded = try loadCheckpointInTransaction(
                    checkpointID: checkpointID,
                    database: database
                ) else {
                    throw RuntimeCanonicalReplayError.checkpointMismatch
                }
                checkpoint = loaded
            } catch RuntimeCanonicalReplayError.checkpointMismatch {
                return .blocked(RuntimeCanonicalReplayDivergence(
                    code: .checkpointCorrupt, lastVerifiedCursor: nil,
                    divergentEventID: nil, divergentSequence: nil,
                    expectedHash: nil, observedHash: nil,
                    expectedRevision: nil, observedRevision: nil,
                    quarantineReference: "checkpoint.\(checkpointID)"
                ), .empty)
            }
            reconstruction = try RuntimeCanonicalReconstruction(
                cursor: checkpoint.highWaterCursor,
                lastCorrelationID: checkpoint.lastCorrelationID,
                aggregates: checkpoint.aggregates,
                tombstones: checkpoint.tombstones
            )
            guard reconstruction.stateDigest == checkpoint.stateDigest else {
                throw RuntimeCanonicalReplayError.checkpointMismatch
            }
            anchor = checkpoint.highWaterCursor
            sourceChainDigest = try SHA256Digest(hexadecimal: checkpoint.sourceChainDigest)
        } else {
            reconstruction = .empty
            anchor = nil
            sourceChainDigest = RuntimeCanonicalReplaySourceChain.emptyDigest
        }

        var cursor: RuntimeCanonicalReplayCursor?
        repeat {
            try Task.checkCancellation()
            let page = try CanonicalRuntimeSemanticEventStore.readVerifiedInTransaction(
                from: database,
                after: cursor,
                initialAnchor: anchor,
                limit: CanonicalRuntimeSemanticEventStore.maximumPageLimit
            )
            for inspection in page.items {
                switch inspection {
                case let .blocked(blocked):
                    return .blocked(RuntimeCanonicalReplayDivergence(
                        code: invariantCode(for: blocked.reason),
                        lastVerifiedCursor: reconstruction.cursor,
                        divergentEventID: blocked.eventID,
                        divergentSequence: blocked.sequence,
                        expectedHash: reconstruction.cursor?.eventHash,
                        observedHash: nil,
                        expectedRevision: nil,
                        observedRevision: nil,
                        quarantineReference: try quarantineOccurrenceReference(
                            eventID: blocked.eventID,
                            sequence: blocked.sequence,
                            database: database
                        )
                    ), reconstruction)
                case let .supported(record):
                    switch RuntimeCanonicalReplayReducer().apply(record, to: reconstruction) {
                    case let .accepted(next):
                        reconstruction = next
                        sourceChainDigest = try RuntimeCanonicalReplaySourceChain.advance(
                            prior: sourceChainDigest,
                            lineage: record.lineage
                        )
                    case let .blocked(evidence, prefix): return .blocked(evidence, prefix)
                    }
                }
            }
            cursor = page.nextCursor
        } while cursor != nil

        if let quarantine = try firstQuarantineOccurrence(database: database) {
            return .blocked(RuntimeCanonicalReplayDivergence(
                code: .quarantinePresent,
                lastVerifiedCursor: reconstruction.cursor,
                divergentEventID: quarantine.eventID,
                divergentSequence: quarantine.sequence,
                expectedHash: reconstruction.cursor?.eventHash,
                observedHash: nil,
                expectedRevision: nil,
                observedRevision: nil,
                quarantineReference: quarantine.reference
            ), reconstruction)
        }
        if let divergence = try firstLiveAggregateDivergence(reconstruction, database: database) {
            return .blocked(divergence, reconstruction)
        }
        if let divergence = try firstLiveTombstoneDivergence(reconstruction, database: database) {
            return .blocked(divergence, reconstruction)
        }
        try recordVerifiedHighWater(
            reconstruction,
            sourceChainDigest: sourceChainDigest,
            database: database
        )
        return .complete(reconstruction)
    }

    private static func checkpointInTransaction(
        _ reconstruction: RuntimeCanonicalReconstruction,
        expectedAnchor: RuntimeCanonicalReplayCursor,
        createdAt: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalReplayCheckpoint {
        try CanonicalRuntimeReplaySchemaPlan.requireIntegratedSchema(in: database)
        guard reconstruction.cursor == expectedAnchor else {
            throw RuntimeCanonicalReplayError.staleCompactionPlan
        }
        let tail = try currentTail(database: database)
        guard tail == expectedAnchor else {
            throw RuntimeCanonicalReplayError.staleCompactionPlan
        }
        let verified = try verifiedReconstruction(
            at: expectedAnchor,
            stateDigest: reconstruction.stateDigest,
            database: database
        )
        let checkpoint = try RuntimeCanonicalReplayCheckpoint.make(
            reconstruction: reconstruction,
            sourceChainDigest: verified.sourceChainDigest.hexadecimal,
            createdAt: createdAt
        )
        guard checkpoint.aggregates.count <= 10_000,
              checkpoint.tombstones.count <= 10_000 else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let checkpointID = "checkpoint.\(checkpoint.highWaterCursor.sequence).\(checkpoint.manifestDigest)"
        let payload = try RuntimeCanonicalReplayCoding.encode(RuntimeCanonicalReplayCheckpointHeader(
            version: checkpoint.version,
            highWaterCursor: checkpoint.highWaterCursor,
            sourceChainDigest: checkpoint.sourceChainDigest,
            lastCorrelationID: checkpoint.lastCorrelationID,
            stateDigest: checkpoint.stateDigest,
            aggregateCount: checkpoint.aggregates.count,
            tombstoneCount: checkpoint.tombstones.count,
            createdAt: checkpoint.createdAt,
            manifestDigest: checkpoint.manifestDigest
        ))
        let checksum = LocalRuntimeStorageChecksum.sha256Hex(for: payload)
        let headerInsert = try database.execute(
            """
            INSERT INTO runtime_replay_checkpoints(
                checkpoint_id, high_water_sequence, high_water_event_id,
                high_water_event_hash, source_chain_digest, checkpoint_version,
                state_digest, manifest_digest, payload, payload_checksum, created_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(checkpointID),
                .integer(Int64(checkpoint.highWaterCursor.sequence)),
                .text(checkpoint.highWaterCursor.eventID),
                .text(checkpoint.highWaterCursor.eventHash),
                .text(checkpoint.sourceChainDigest),
                .integer(Int64(checkpoint.version)),
                .text(checkpoint.stateDigest), .text(checkpoint.manifestDigest),
                .blob(payload), .text(checksum),
                .integer(try RuntimeSemanticEventHashing.milliseconds(createdAt)),
            ]
        )
        guard headerInsert.changedRowCount == 1 else {
            throw RuntimeCanonicalReplayError.checkpointMismatch
        }
        for aggregate in checkpoint.aggregates {
            let record = try RuntimeCanonicalReplayCoding.encode(aggregate)
            guard record.count <= 1_048_576 else { throw RuntimeCanonicalReplayError.corruptAuthority }
            let changed = try database.execute(
                """
                INSERT INTO runtime_replay_checkpoint_aggregates(
                    checkpoint_id, aggregate_kind, aggregate_id, payload, payload_checksum
                ) VALUES (?, ?, ?, ?, ?)
                """,
                bindings: [
                    .text(checkpointID), .text(aggregate.state.aggregate.kind.rawValue),
                    .text(aggregate.state.aggregate.id.rawValue), .blob(record),
                    .text(LocalRuntimeStorageChecksum.sha256Hex(for: record)),
                ]
            )
            guard changed.changedRowCount == 1 else { throw RuntimeCanonicalReplayError.checkpointMismatch }
        }
        for tombstone in checkpoint.tombstones {
            let record = try RuntimeCanonicalReplayCoding.encode(tombstone)
            guard record.count <= 1_048_576 else { throw RuntimeCanonicalReplayError.corruptAuthority }
            let changed = try database.execute(
                """
                INSERT INTO runtime_replay_checkpoint_tombstones(
                    checkpoint_id, aggregate_kind, aggregate_id, payload, payload_checksum
                ) VALUES (?, ?, ?, ?, ?)
                """,
                bindings: [
                    .text(checkpointID), .text(tombstone.aggregate.kind.rawValue),
                    .text(tombstone.aggregate.id.rawValue), .blob(record),
                    .text(LocalRuntimeStorageChecksum.sha256Hex(for: record)),
                ]
            )
            guard changed.changedRowCount == 1 else { throw RuntimeCanonicalReplayError.checkpointMismatch }
        }
        guard try loadCheckpointInTransaction(
            checkpointID: checkpointID,
            database: database
        ) == checkpoint else {
            throw RuntimeCanonicalReplayError.checkpointMismatch
        }
        return checkpoint
    }

    static func retentionEvidenceInTransaction(
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalRetentionEvidence {
        func exists(_ sql: String) throws -> Bool {
            try database.query(sql).isEmpty == false
        }
        return RuntimeCanonicalRetentionEvidence(
            hasUnknownOrCorruptEvents: try verifiedHighWaterMatchesTail(database: database) == false,
            hasQuarantineOccurrences: try exists("SELECT 1 FROM runtime_replay_quarantine_occurrences LIMIT 1"),
            hasUnresolvedProjectionWork: try exists("SELECT 1 FROM runtime_commit_projection_invalidations LIMIT 1"),
            hasUnresolvedExternalWork: try exists(
                """
                SELECT 1 FROM runtime_external_operation_current
                WHERE workflow_status IN (
                    'pending','claimed','executing','retry_scheduled',
                    'reconciliation_required','operator_required'
                ) OR effect_disposition = 'indeterminate'
                LIMIT 1
                """
            ),
            hasRetainedReceipts: try exists("SELECT 1 FROM runtime_commit_receipts LIMIT 1"),
            hasRetainedIdempotency: try exists("SELECT 1 FROM runtime_command_idempotency LIMIT 1"),
            hasRetainedLineage: try exists("SELECT 1 FROM runtime_semantic_events LIMIT 1"),
            hasRecoveryNeeds: try exists("SELECT 1 FROM runtime_commit_tombstones LIMIT 1"),
            hasExplicitHolds: try exists("SELECT 1 FROM runtime_replay_retention_holds WHERE released_at_ms IS NULL LIMIT 1"),
            downstreamReceiptPolicyAvailable: false,
            downstreamExternalPolicyAvailable: false,
            downstreamBlobPolicyAvailable: false
        )
    }

    static func applyCompactionInTransaction(
        _ plan: RuntimeCanonicalCompactionPlan,
        reconstruction: RuntimeCanonicalReconstruction,
        createdAt: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalReplayCheckpoint {
        try Task.checkCancellation()
        guard plan.disposition == .checkpointOnly,
              plan.pruneThroughSequence == nil,
              plan.stateDigest == reconstruction.stateDigest else {
            throw RuntimeCanonicalReplayError.destructivePruneUnavailable
        }
        let verified: RuntimeCanonicalReconstruction
        switch try replayInTransaction(database: database) {
        case let .complete(value):
            verified = value
        case .blocked:
            throw RuntimeCanonicalReplayError.staleCompactionPlan
        }
        guard verified == reconstruction,
              verified.cursor == plan.revalidationAnchor else {
            throw RuntimeCanonicalReplayError.staleCompactionPlan
        }
        let evidence = try retentionEvidenceInTransaction(database: database)
        let eligibility = RuntimeCanonicalRetentionPolicy().evaluate(evidence)
        let refreshed = RuntimeCanonicalCompactionPlanner().plan(
            verifiedCursor: plan.revalidationAnchor,
            stateDigest: verified.stateDigest,
            eligibility: eligibility
        )
        guard eligibility.checkpointAllowed,
              refreshed.disposition == .checkpointOnly,
              refreshed.blockers == plan.blockers,
              refreshed.pruneThroughSequence == nil else {
            throw RuntimeCanonicalReplayError.staleCompactionPlan
        }
        try Task.checkCancellation()
        // Revalidation, policy evidence, and checkpoint insertion share the
        // same writer transaction. No authority row is deleted.
        return try checkpointInTransaction(
            verified,
            expectedAnchor: plan.revalidationAnchor,
            createdAt: createdAt,
            database: database
        )
    }

    /// Constant-time verification for latency-sensitive consumers. The
    /// immutable reconstruction row is a durable authenticated continuation;
    /// full source-chain reconstruction remains owned by the replay audit lane.
    static func verifiedReconstructionCertificate(
        at cursor: RuntimeCanonicalReplayCursor,
        database: isolated SQLiteDatabase
    ) throws -> (
        sourceChainDigest: SHA256Digest,
        reconstructionDigest: SHA256Digest,
        verifiedAtMilliseconds: Int64
    ) {
        guard cursor.isWellFormed, cursor.sequence <= UInt64(Int64.max) else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let rows = try database.query(
            """
            SELECT event_id, event_hash, source_chain_digest,
                   reconstruction_digest, certificate_digest, verified_at_ms
            FROM runtime_canonical_replay_verification_certificates
            WHERE event_sequence = ? LIMIT 2
            """,
            bindings: [.integer(Int64(cursor.sequence))]
        )
        guard rows.count == 1,
              rows[0].value(named: "event_id") == .text(cursor.eventID),
              rows[0].value(named: "event_hash") == .text(cursor.eventHash),
              case let .text(sourceRaw)? = rows[0].value(named: "source_chain_digest"),
              let source = try? SHA256Digest(hexadecimal: sourceRaw),
              case let .text(reconstructionRaw)? = rows[0].value(named: "reconstruction_digest"),
              let reconstruction = try? SHA256Digest(hexadecimal: reconstructionRaw),
              case let .text(verificationDigest)? = rows[0].value(named: "certificate_digest"),
              case let .integer(verifiedAt)? = rows[0].value(named: "verified_at_ms"), verifiedAt >= 0,
              verificationDigest == verificationCertificateDigest(
                cursor: cursor,
                sourceChainDigest: source,
                reconstructionDigest: reconstruction,
                verifiedAtMilliseconds: verifiedAt
              ) else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let anchor = try database.query(
            """
            SELECT event_id, event_hash, occurred_at_ms
            FROM runtime_semantic_events WHERE sequence = ? LIMIT 2
            """,
            bindings: [.integer(Int64(cursor.sequence))]
        )
        guard anchor.count == 1,
              anchor[0].value(named: "event_id") == .text(cursor.eventID),
              anchor[0].value(named: "event_hash") == .text(cursor.eventHash),
              anchor[0].value(named: "occurred_at_ms") == .integer(verifiedAt) else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        return (source, reconstruction, verifiedAt)
    }

    /// Reads the authenticated high-water pointer and its immutable
    /// continuation certificate without scanning prior semantic events.
    static func verifiedHighWaterCertificate(
        database: isolated SQLiteDatabase
    ) throws -> (
        cursor: RuntimeCanonicalReplayCursor,
        sourceChainDigest: SHA256Digest,
        reconstructionDigest: SHA256Digest,
        verifiedAtMilliseconds: Int64
    )? {
        let rows = try database.query(
            """
            SELECT event_sequence, event_id, event_hash, chain_anchor_digest,
                   reconstruction_digest, verified_at_ms
            FROM runtime_replay_verified_high_water
            WHERE singleton_id = 1 LIMIT 2
            """
        )
        guard let row = rows.first else { return nil }
        guard rows.count == 1,
              case let .integer(sequence)? = row.value(named: "event_sequence"), sequence > 0,
              case let .text(eventID)? = row.value(named: "event_id"),
              case let .text(eventHash)? = row.value(named: "event_hash"),
              case let .text(sourceRaw)? = row.value(named: "chain_anchor_digest"),
              let source = try? SHA256Digest(hexadecimal: sourceRaw),
              case let .text(reconstructionRaw)? = row.value(named: "reconstruction_digest"),
              let reconstruction = try? SHA256Digest(hexadecimal: reconstructionRaw),
              case let .integer(verifiedAt)? = row.value(named: "verified_at_ms"), verifiedAt >= 0 else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let cursor = RuntimeCanonicalReplayCursor(
            sequence: UInt64(sequence), eventID: eventID, eventHash: eventHash
        )
        guard cursor.isWellFormed else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let continuation = try verifiedReconstructionCertificate(at: cursor, database: database)
        guard continuation.sourceChainDigest == source,
              continuation.reconstructionDigest == reconstruction,
              continuation.verifiedAtMilliseconds == verifiedAt else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        return (cursor, source, reconstruction, verifiedAt)
    }

    static func verificationCertificateDigest(
        cursor: RuntimeCanonicalReplayCursor,
        sourceChainDigest: SHA256Digest,
        reconstructionDigest: SHA256Digest,
        verifiedAtMilliseconds: Int64
    ) -> String {
        RuntimeTransactionDigest.digest([
            "runtime.replay.verification.v1", String(cursor.sequence), cursor.eventID,
            cursor.eventHash, sourceChainDigest.hexadecimal,
            reconstructionDigest.hexadecimal, String(verifiedAtMilliseconds),
        ])
    }
}

private extension RuntimeCanonicalReplayEngine {
    struct VerifiedReconstruction {
        let sourceChainDigest: SHA256Digest
        let reconstructionDigest: SHA256Digest
        let verifiedAtMilliseconds: Int64
    }

    struct RuntimeCanonicalReplayCheckpointHeader: Codable {
        let version: Int
        let highWaterCursor: RuntimeCanonicalReplayCursor
        let sourceChainDigest: String
        let lastCorrelationID: String
        let stateDigest: String
        let aggregateCount: Int
        let tombstoneCount: Int
        let createdAt: Date
        let manifestDigest: String
    }

    static func loadCheckpointAggregates(
        _ checkpointID: String,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeCanonicalReplayAggregate] {
        var result: [RuntimeCanonicalReplayAggregate] = []
        var kind = ""
        var identifier = ""
        repeat {
            let rows = try database.query(
                """
                SELECT aggregate_kind, aggregate_id, payload, payload_checksum
                FROM runtime_replay_checkpoint_aggregates
                WHERE checkpoint_id = ? AND (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id > ?))
                ORDER BY aggregate_kind, aggregate_id LIMIT 201
                """,
                bindings: [.text(checkpointID), .text(kind), .text(kind), .text(identifier)],
                maximumDecodedBytes: 201 * (1_048_576 + 4_096)
            )
            for row in rows.prefix(200) {
                guard case let .text(rowKind)? = row.value(named: "aggregate_kind"),
                      case let .text(rowID)? = row.value(named: "aggregate_id"),
                      case let .blob(payload)? = row.value(named: "payload"),
                      case let .text(checksum)? = row.value(named: "payload_checksum"),
                      checksum == LocalRuntimeStorageChecksum.sha256Hex(for: payload) else {
                    throw RuntimeCanonicalReplayError.checkpointMismatch
                }
                let value: RuntimeCanonicalReplayAggregate = try RuntimeCanonicalReplayCoding.decode(payload)
                guard value.state.aggregate.kind.rawValue == rowKind,
                      value.state.aggregate.id.rawValue == rowID,
                      value.stateDigest == LocalRuntimeStorageChecksum.sha256Hex(for: value.canonicalBytes),
                      try RuntimeCanonicalAggregateStateCodec().decode(value.canonicalBytes) == value.state else {
                    throw RuntimeCanonicalReplayError.checkpointMismatch
                }
                result.append(value)
                kind = rowKind
                identifier = rowID
            }
            if rows.count <= 200 { break }
            guard result.count <= 10_000 else { throw RuntimeCanonicalReplayError.checkpointMismatch }
        } while true
        return result
    }

    static func recordVerifiedHighWater(
        _ reconstruction: RuntimeCanonicalReconstruction,
        sourceChainDigest: SHA256Digest,
        database: isolated SQLiteDatabase
    ) throws {
        guard let cursor = reconstruction.cursor else { return }
        let tail = try database.query(
            "SELECT occurred_at_ms FROM runtime_semantic_events WHERE sequence = ? AND event_id = ? AND event_hash = ? LIMIT 2",
            bindings: [.integer(Int64(cursor.sequence)), .text(cursor.eventID), .text(cursor.eventHash)]
        )
        guard tail.count == 1,
              case let .integer(verifiedAtMilliseconds)? = tail[0].value(named: "occurred_at_ms"),
              verifiedAtMilliseconds >= 0 else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let actualSourceChainDigest = try CanonicalRuntimeSemanticEventStore
            .verifiedSourceChainDigestThrough(cursor.sequence, database: database)
        guard actualSourceChainDigest == sourceChainDigest else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let reconstructionDigest = try SHA256Digest(hexadecimal: reconstruction.stateDigest)
        let existing = try database.query(
            """
            SELECT event_id, event_hash, source_chain_digest,
                   reconstruction_digest, verified_at_ms
            FROM runtime_replay_verified_reconstructions
            WHERE event_sequence = ? LIMIT 2
            """,
            bindings: [.integer(Int64(cursor.sequence))]
        )
        if existing.isEmpty {
            let inserted = try database.execute(
                """
                INSERT INTO runtime_replay_verified_reconstructions(
                    event_sequence, event_id, event_hash, source_chain_digest,
                    reconstruction_digest, verified_at_ms
                ) VALUES (?, ?, ?, ?, ?, ?)
                """,
                bindings: [
                    .integer(Int64(cursor.sequence)), .text(cursor.eventID),
                    .text(cursor.eventHash), .text(sourceChainDigest.hexadecimal),
                    .text(reconstructionDigest.hexadecimal), .integer(verifiedAtMilliseconds),
                ]
            )
            guard inserted.changedRowCount == 1 else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
        } else {
            guard existing.count == 1,
                  existing[0].value(named: "event_id") == .text(cursor.eventID),
                  existing[0].value(named: "event_hash") == .text(cursor.eventHash),
                  existing[0].value(named: "source_chain_digest") == .text(sourceChainDigest.hexadecimal),
                  existing[0].value(named: "reconstruction_digest") == .text(reconstructionDigest.hexadecimal),
                  existing[0].value(named: "verified_at_ms") == .integer(verifiedAtMilliseconds) else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
        }
        let result = try database.execute(
            """
            INSERT INTO runtime_replay_verified_high_water(
                singleton_id, event_sequence, event_id, event_hash,
                chain_anchor_digest, reconstruction_digest, verified_at_ms
            ) VALUES (1, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(singleton_id) DO UPDATE SET
                event_sequence = excluded.event_sequence,
                event_id = excluded.event_id,
                event_hash = excluded.event_hash,
                chain_anchor_digest = excluded.chain_anchor_digest,
                reconstruction_digest = excluded.reconstruction_digest,
                verified_at_ms = excluded.verified_at_ms
            """,
            bindings: [
                .integer(Int64(cursor.sequence)), .text(cursor.eventID), .text(cursor.eventHash),
                .text(sourceChainDigest.hexadecimal), .text(reconstructionDigest.hexadecimal),
                .integer(verifiedAtMilliseconds),
            ]
        )
        guard result.changedRowCount == 1 else { throw RuntimeCanonicalReplayError.corruptAuthority }

        // v4 replay remains shape-compatible. A v5 authority adds immutable,
        // digest-bound continuation certificates for bounded consumers.
        let certificateTable = try database.query(
            "SELECT 1 FROM sqlite_schema WHERE type = 'table' AND name = 'runtime_canonical_replay_verification_certificates' LIMIT 2"
        )
        if certificateTable.isEmpty == false {
            guard certificateTable.count == 1 else { throw RuntimeCanonicalReplayError.corruptAuthority }
            let certificateDigest = verificationCertificateDigest(
                cursor: cursor,
                sourceChainDigest: sourceChainDigest,
                reconstructionDigest: reconstructionDigest,
                verifiedAtMilliseconds: verifiedAtMilliseconds
            )
            try database.execute(
                """
                INSERT OR IGNORE INTO runtime_canonical_replay_verification_certificates(
                    event_sequence, event_id, event_hash, source_chain_digest,
                    reconstruction_digest, verified_at_ms, certificate_digest
                ) VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                bindings: [
                    .integer(Int64(cursor.sequence)), .text(cursor.eventID), .text(cursor.eventHash),
                    .text(sourceChainDigest.hexadecimal), .text(reconstructionDigest.hexadecimal),
                    .integer(verifiedAtMilliseconds), .text(certificateDigest),
                ]
            )
            let certificate = try database.query(
                """
                SELECT event_id, event_hash, source_chain_digest, reconstruction_digest,
                       verified_at_ms, certificate_digest
                FROM runtime_canonical_replay_verification_certificates
                WHERE event_sequence = ? LIMIT 2
                """,
                bindings: [.integer(Int64(cursor.sequence))]
            )
            guard certificate.count == 1,
                  certificate[0].value(named: "event_id") == .text(cursor.eventID),
                  certificate[0].value(named: "event_hash") == .text(cursor.eventHash),
                  certificate[0].value(named: "source_chain_digest") == .text(sourceChainDigest.hexadecimal),
                  certificate[0].value(named: "reconstruction_digest") == .text(reconstructionDigest.hexadecimal),
                  certificate[0].value(named: "verified_at_ms") == .integer(verifiedAtMilliseconds),
                  certificate[0].value(named: "certificate_digest") == .text(certificateDigest) else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
        }
    }

    static func verifiedHighWaterMatchesTail(
        database: isolated SQLiteDatabase
    ) throws -> Bool {
        let tail = try database.query(
            "SELECT sequence, event_id, event_hash FROM runtime_semantic_events ORDER BY sequence DESC LIMIT 1"
        )
        let highWater: (
            cursor: RuntimeCanonicalReplayCursor,
            sourceChainDigest: SHA256Digest,
            reconstructionDigest: SHA256Digest?,
            verifiedAtMilliseconds: Int64
        )?
        do {
            highWater = try verifiedHighWaterIntegrity(database: database)
        } catch {
            return false
        }
        if tail.isEmpty { return highWater == nil }
        guard tail.count == 1, let highWater else { return false }
        guard case let .integer(sequence)? = tail[0].value(named: "sequence"),
              case let .text(eventID)? = tail[0].value(named: "event_id"),
              case let .text(eventHash)? = tail[0].value(named: "event_hash") else { return false }
        guard sequence > 0,
              let typedEventID = RuntimeEventID(rawValue: eventID),
              let typedEventHash = try? SHA256Digest(hexadecimal: eventHash) else { return false }
        let cursor = RuntimeCanonicalReplayCursor(
            sequence: UInt64(sequence), eventID: typedEventID.rawValue,
            eventHash: typedEventHash.hexadecimal
        )
        return highWater.cursor == cursor && highWater.reconstructionDigest != nil
    }

    static func verifiedHighWaterIntegrity(
        database: isolated SQLiteDatabase
    ) throws -> (
        cursor: RuntimeCanonicalReplayCursor,
        sourceChainDigest: SHA256Digest,
        reconstructionDigest: SHA256Digest?,
        verifiedAtMilliseconds: Int64
    )? {
        let rows = try database.query(
            """
            SELECT event_sequence, event_id, event_hash, chain_anchor_digest,
                   reconstruction_digest, verified_at_ms
            FROM runtime_replay_verified_high_water
            WHERE singleton_id = 1 LIMIT 2
            """
        )
        guard let row = rows.first else { return nil }
        guard rows.count == 1,
              case let .integer(sequence)? = row.value(named: "event_sequence"), sequence > 0,
              case let .text(eventID)? = row.value(named: "event_id"),
              case let .text(eventHash)? = row.value(named: "event_hash"),
              case let .text(chainRaw)? = row.value(named: "chain_anchor_digest"),
              let chain = try? SHA256Digest(hexadecimal: chainRaw),
              case let .integer(verifiedAt)? = row.value(named: "verified_at_ms"), verifiedAt >= 0 else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let cursor = RuntimeCanonicalReplayCursor(
            sequence: UInt64(sequence), eventID: eventID, eventHash: eventHash
        )
        guard cursor.isWellFormed else { throw RuntimeCanonicalReplayError.corruptAuthority }
        let actualSource = try CanonicalRuntimeSemanticEventStore
            .verifiedSourceChainDigestThrough(cursor.sequence, database: database)
        let anchor = try database.query(
            "SELECT event_id, event_hash, occurred_at_ms FROM runtime_semantic_events WHERE sequence = ? LIMIT 2",
            bindings: [.integer(sequence)]
        )
        guard actualSource == chain,
              anchor.count == 1,
              anchor[0].value(named: "event_id") == .text(eventID),
              anchor[0].value(named: "event_hash") == .text(eventHash),
              anchor[0].value(named: "occurred_at_ms") == .integer(verifiedAt) else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let reconstruction: SHA256Digest?
        switch row.value(named: "reconstruction_digest") {
        case let .text(raw)?:
            guard let digest = try? SHA256Digest(hexadecimal: raw) else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
            let verified = try verifiedReconstruction(
                at: cursor,
                stateDigest: digest.hexadecimal,
                database: database
            )
            guard verified.sourceChainDigest == chain,
                  verified.reconstructionDigest == digest,
                  verified.verifiedAtMilliseconds == verifiedAt else {
                throw RuntimeCanonicalReplayError.corruptAuthority
            }
            reconstruction = digest
        case .null?:
            reconstruction = nil
        default:
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        return (cursor, chain, reconstruction, verifiedAt)
    }

    static func verifiedReconstruction(
        at cursor: RuntimeCanonicalReplayCursor,
        stateDigest: String,
        database: isolated SQLiteDatabase
    ) throws -> VerifiedReconstruction {
        guard cursor.isWellFormed,
              cursor.sequence <= UInt64(Int64.max),
              let expectedState = try? SHA256Digest(hexadecimal: stateDigest) else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let rows = try database.query(
            """
            SELECT event_id, event_hash, source_chain_digest,
                   reconstruction_digest, verified_at_ms
            FROM runtime_replay_verified_reconstructions
            WHERE event_sequence = ? LIMIT 2
            """,
            bindings: [.integer(Int64(cursor.sequence))]
        )
        guard rows.count == 1,
              rows[0].value(named: "event_id") == .text(cursor.eventID),
              rows[0].value(named: "event_hash") == .text(cursor.eventHash),
              case let .text(sourceRaw)? = rows[0].value(named: "source_chain_digest"),
              let source = try? SHA256Digest(hexadecimal: sourceRaw),
              rows[0].value(named: "reconstruction_digest") == .text(expectedState.hexadecimal),
              case let .integer(verifiedAt)? = rows[0].value(named: "verified_at_ms"),
              verifiedAt >= 0 else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        let anchorRows = try database.query(
            """
            SELECT event_id, event_hash, occurred_at_ms
            FROM runtime_semantic_events WHERE sequence = ? LIMIT 2
            """,
            bindings: [.integer(Int64(cursor.sequence))]
        )
        let actualSource = try CanonicalRuntimeSemanticEventStore
            .verifiedSourceChainDigestThrough(cursor.sequence, database: database)
        guard anchorRows.count == 1,
              anchorRows[0].value(named: "event_id") == .text(cursor.eventID),
              anchorRows[0].value(named: "event_hash") == .text(cursor.eventHash),
              anchorRows[0].value(named: "occurred_at_ms") == .integer(verifiedAt),
              source == actualSource else {
            throw RuntimeCanonicalReplayError.corruptAuthority
        }
        return VerifiedReconstruction(
            sourceChainDigest: source,
            reconstructionDigest: expectedState,
            verifiedAtMilliseconds: verifiedAt
        )
    }

    static func loadCheckpointTombstones(
        _ checkpointID: String,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeCanonicalReplayTombstone] {
        var result: [RuntimeCanonicalReplayTombstone] = []
        var kind = ""
        var identifier = ""
        repeat {
            let rows = try database.query(
                """
                SELECT aggregate_kind, aggregate_id, payload, payload_checksum
                FROM runtime_replay_checkpoint_tombstones
                WHERE checkpoint_id = ? AND (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id > ?))
                ORDER BY aggregate_kind, aggregate_id LIMIT 201
                """,
                bindings: [.text(checkpointID), .text(kind), .text(kind), .text(identifier)],
                maximumDecodedBytes: 201 * (1_048_576 + 4_096)
            )
            for row in rows.prefix(200) {
                guard case let .text(rowKind)? = row.value(named: "aggregate_kind"),
                      case let .text(rowID)? = row.value(named: "aggregate_id"),
                      case let .blob(payload)? = row.value(named: "payload"),
                      case let .text(checksum)? = row.value(named: "payload_checksum"),
                      checksum == LocalRuntimeStorageChecksum.sha256Hex(for: payload) else {
                    throw RuntimeCanonicalReplayError.checkpointMismatch
                }
                let value: RuntimeCanonicalReplayTombstone = try RuntimeCanonicalReplayCoding.decode(payload)
                guard value.aggregate.kind.rawValue == rowKind,
                      value.aggregate.id.rawValue == rowID else {
                    throw RuntimeCanonicalReplayError.checkpointMismatch
                }
                result.append(value)
                kind = rowKind
                identifier = rowID
            }
            if rows.count <= 200 { break }
            guard result.count <= 10_000 else { throw RuntimeCanonicalReplayError.checkpointMismatch }
        } while true
        return result
    }

    static func currentTail(database: isolated SQLiteDatabase) throws -> RuntimeCanonicalReplayCursor? {
        let rows = try database.query(
            "SELECT sequence, event_id, event_hash FROM runtime_semantic_events ORDER BY sequence DESC LIMIT 1"
        )
        guard let row = rows.first,
              case let .integer(sequence)? = row.value(named: "sequence"), sequence > 0,
              case let .text(eventID)? = row.value(named: "event_id"),
              case let .text(eventHash)? = row.value(named: "event_hash") else { return nil }
        let cursor = RuntimeCanonicalReplayCursor(
            sequence: UInt64(sequence), eventID: eventID, eventHash: eventHash
        )
        guard cursor.isWellFormed else { throw RuntimeCanonicalReplayError.corruptAuthority }
        return cursor
    }

    static func firstQuarantineOccurrence(
        database: isolated SQLiteDatabase
    ) throws -> (eventID: String?, sequence: UInt64?, reference: String)? {
        let rows = try database.query(
            """
            SELECT occurrence_id, source_event_id, source_event_sequence
            FROM runtime_replay_quarantine_occurrences
            ORDER BY observed_at_ms ASC, occurrence_id ASC LIMIT 1
            """
        )
        guard let row = rows.first,
              case let .text(occurrenceID)? = row.value(named: "occurrence_id") else { return nil }
        let eventID: String? = if case let .text(value)? = row.value(named: "source_event_id") { value } else { nil }
        let sequence: UInt64? = if case let .integer(value)? = row.value(named: "source_event_sequence"), value > 0 {
            UInt64(value)
        } else { nil }
        return (eventID, sequence, "quarantine-occurrence.\(occurrenceID)")
    }

    static func quarantineOccurrenceReference(
        eventID: String,
        sequence: UInt64,
        database: isolated SQLiteDatabase
    ) throws -> String? {
        let rows = try database.query(
            """
            SELECT occurrence_id
            FROM runtime_replay_quarantine_occurrences
            WHERE source_event_id = ? AND source_event_sequence = ?
            ORDER BY observed_at_ms DESC, occurrence_id DESC LIMIT 1
            """,
            bindings: [.text(eventID), .integer(Int64(sequence))]
        )
        guard case let .text(value)? = rows.first?.value(named: "occurrence_id") else { return nil }
        return "quarantine-occurrence.\(value)"
    }

    static func invariantCode(
        for reason: CanonicalRuntimeSemanticEventQuarantineReason
    ) -> RuntimeCanonicalReplayInvariantCode {
        switch reason {
        case .sourceDigestMismatch: .sourceDigestMismatch
        case .eventHashMismatch: .eventHashMismatch
        case .sequenceDiscontinuity: .sequenceDiscontinuity
        case .predecessorMismatch, .predecessorBlocked: .predecessorHashMismatch
        case .invalidCausation: .causationMismatch
        case .normalizedColumnsMismatch: .eventIdentityMismatch
        case .envelopeTooLarge, .payloadTooLarge, .malformedEnvelope, .corruptEnvelope,
             .truncatedEnvelope, .futureEnvelopeVersion, .unsupportedEnvelopeVersion,
             .unknownType, .futurePayloadVersion, .unsupportedPayloadVersion, .typeMismatch,
             .invalidPayload, .nonCanonicalBytes, .malformedStoredRow: .unknownOrCorruptEvent
        }
    }

    static func firstLiveAggregateDivergence(
        _ reconstruction: RuntimeCanonicalReconstruction,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalReplayDivergence? {
        let rows = try database.query(
            """
            SELECT aggregate_kind, aggregate_id, revision, payload_version,
                   payload, payload_checksum
            FROM runtime_aggregates ORDER BY aggregate_kind, aggregate_id
            """,
            maximumDecodedBytes: 268_435_456
        )
        let count = max(rows.count, reconstruction.aggregates.count)
        for index in 0..<count {
            let row = index < rows.count ? rows[index] : nil
            let aggregate = index < reconstruction.aggregates.count ? reconstruction.aggregates[index] : nil
            let matches = row != nil && aggregate != nil &&
                row?.value(named: "aggregate_kind") == .text(aggregate!.state.aggregate.kind.rawValue) &&
                row?.value(named: "aggregate_id") == .text(aggregate!.state.aggregate.id.rawValue) &&
                row?.value(named: "revision") == .integer(Int64(aggregate!.state.revision)) &&
                row?.value(named: "payload_version") == .integer(1) &&
                row?.value(named: "payload") == .blob(aggregate!.canonicalBytes) &&
                row?.value(named: "payload_checksum") == .text(aggregate!.stateDigest)
            if matches == false {
                let observedHash: String? = if case let .text(value)? = row?.value(named: "payload_checksum"),
                                               RuntimeStoreManifestCodec.isSHA256Hex(value) {
                    value
                } else if case let .blob(value)? = row?.value(named: "payload") {
                    LocalRuntimeStorageChecksum.sha256Hex(for: value)
                } else { nil }
                let observedRevision: UInt64? = if case let .integer(value)? = row?.value(named: "revision"), value >= 0 {
                    UInt64(value)
                } else { nil }
                return RuntimeCanonicalReplayDivergence(
                    code: .liveStateDivergence,
                    lastVerifiedCursor: reconstruction.cursor,
                    divergentEventID: aggregate?.lastEvent.eventID,
                    divergentSequence: aggregate?.lastEvent.sequence,
                    expectedHash: aggregate?.stateDigest,
                    observedHash: observedHash,
                    expectedRevision: aggregate?.state.revision,
                    observedRevision: observedRevision,
                    quarantineReference: nil
                )
            }
        }
        return nil
    }

    static func firstLiveTombstoneDivergence(
        _ reconstruction: RuntimeCanonicalReconstruction,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalReplayDivergence? {
        let rows = try database.query(
            """
            SELECT object_id, family, terminal_revision, terminal_event_sequence,
                   payload, payload_checksum
            FROM runtime_commit_tombstones ORDER BY family, object_id
            """,
            maximumDecodedBytes: 64 * 1_048_576
        )
        let expected = reconstruction.tombstones.sorted { $0.paritySortKey < $1.paritySortKey }
        let count = max(rows.count, expected.count)
        for index in 0..<count {
            let row = index < rows.count ? rows[index] : nil
            let tombstone = index < expected.count ? expected[index] : nil
            let expectedHash = tombstone.flatMap { try? RuntimeCanonicalReplayCoding.digest($0) }
            guard let row, let tombstone,
                  case let .blob(payload)? = row.value(named: "payload"),
                  case let .text(checksum)? = row.value(named: "payload_checksum"),
                  checksum == LocalRuntimeStorageChecksum.sha256Hex(for: payload),
                  row.value(named: "family") == .text(tombstone.aggregate.kind.rawValue),
                  row.value(named: "object_id") == .text(tombstone.aggregate.id.rawValue),
                  row.value(named: "terminal_revision") == .integer(Int64(tombstone.terminalRevision)),
                  row.value(named: "terminal_event_sequence") == .integer(Int64(tombstone.causalCursor.sequence)) else {
                let observedHash: String? = if case let .text(value)? = row?.value(named: "payload_checksum"),
                                               RuntimeStoreManifestCodec.isSHA256Hex(value) {
                    value
                } else if case let .blob(value)? = row?.value(named: "payload") {
                    LocalRuntimeStorageChecksum.sha256Hex(for: value)
                } else { nil }
                let observedRevision: UInt64? = if case let .integer(value)? = row?.value(named: "terminal_revision"), value >= 0 {
                    UInt64(value)
                } else { nil }
                return RuntimeCanonicalReplayDivergence(
                    code: .liveTombstoneDivergence,
                    lastVerifiedCursor: reconstruction.cursor,
                    divergentEventID: tombstone?.causalCursor.eventID,
                    divergentSequence: tombstone?.causalCursor.sequence,
                    expectedHash: expectedHash,
                    observedHash: observedHash,
                    expectedRevision: tombstone?.terminalRevision,
                    observedRevision: observedRevision,
                    quarantineReference: nil
                )
            }
            let draft: RuntimeCanonicalTombstoneDraft
            do {
                draft = try RuntimeCanonicalReplayCoding.decode(payload)
            } catch {
                return RuntimeCanonicalReplayDivergence(
                    code: .liveTombstoneDivergence,
                    lastVerifiedCursor: reconstruction.cursor,
                    divergentEventID: tombstone.causalCursor.eventID,
                    divergentSequence: tombstone.causalCursor.sequence,
                    expectedHash: expectedHash,
                    observedHash: checksum,
                    expectedRevision: tombstone.terminalRevision,
                    observedRevision: nil,
                    quarantineReference: nil
                )
            }
            guard let expectedObjectID = RuntimeDomainObjectID(rawValue: tombstone.aggregate.id.rawValue),
                  draft.objectID == expectedObjectID,
                  draft.family == tombstone.aggregate.kind.rawValue,
                  draft.terminalRevision == tombstone.terminalRevision,
                  draft.lineage.eventID == tombstone.causalCursor.typedEventID,
                  draft.lineage.eventSequence == tombstone.causalCursor.sequence,
                  draft.lineage.eventHash == tombstone.causalCursor.eventHash,
                  draft.authority.reason == tombstone.reason,
                  draft.authority.predecessorDigest == tombstone.predecessorDigest,
                  draft.authority.retentionDisposition == tombstone.retentionDisposition,
                  draft.authority.recoveryDisposition == tombstone.recoveryDisposition else {
                return RuntimeCanonicalReplayDivergence(
                    code: .liveTombstoneDivergence,
                    lastVerifiedCursor: reconstruction.cursor,
                    divergentEventID: tombstone.causalCursor.eventID,
                    divergentSequence: tombstone.causalCursor.sequence,
                    expectedHash: expectedHash,
                    observedHash: checksum,
                    expectedRevision: tombstone.terminalRevision,
                    observedRevision: draft.terminalRevision,
                    quarantineReference: nil
                )
            }
        }
        return nil
    }
}

private enum RuntimeCanonicalReplayCoding {
    static func encode<Value: Encodable>(_ value: Value) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return try encoder.encode(value)
    }

    static func decode<Value: Decodable>(_ bytes: Data) throws -> Value {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let value = try decoder.decode(Value.self, from: bytes)
        guard try encode(value) == bytes else { throw RuntimeCanonicalReplayError.checkpointMismatch }
        return value
    }

    static func digest<Value: Encodable>(_ value: Value) throws -> String {
        LocalRuntimeStorageChecksum.sha256Hex(for: try encode(value))
    }
}

#if DEBUG
extension RuntimeCanonicalReplayEngine {
    static func testOnlyFirstLiveAggregateDivergence(
        _ reconstruction: RuntimeCanonicalReconstruction,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalReplayDivergence? {
        try firstLiveAggregateDivergence(reconstruction, database: database)
    }

    static func testOnlyFirstLiveTombstoneDivergence(
        _ reconstruction: RuntimeCanonicalReconstruction,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalReplayDivergence? {
        try firstLiveTombstoneDivergence(reconstruction, database: database)
    }
}
#endif
