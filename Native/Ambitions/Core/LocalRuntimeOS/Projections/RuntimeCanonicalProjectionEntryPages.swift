import AmbitionsRuntimeSQLite
import Foundation

extension CanonicalRuntimeStore {
    func cloneCanonicalProjectionEntryPage(
        _ work: RuntimeCanonicalProjectionBuildWork,
        bounds: RuntimeCanonicalProjectionUnitBounds
    ) async throws -> RuntimeCanonicalProjectionUnitResult {
        try Task.checkCancellation()
        return try await withCanonicalImmediateTransaction { database in
            try Self.requireCanonicalProjectionBuildFence(work, phase: .clone, database: database)
            let base = try Self.requireCanonicalCloneBase(work, database: database)
            let baseID = base.generationID
            let baseCursor = base.sourceCursor
            let baseSequence = Int64(baseCursor.sequence)
            let baseEventID = baseCursor.eventID
            let baseEventHash = baseCursor.eventHash
            let baseSourceDigest = base.sourceChainDigest
            guard baseCursor.isWellFormed, baseCursor.sequence <= work.targetCursor.sequence else {
                throw RuntimeCanonicalProjectionPersistenceError.sourceAdvanced
            }
            let limit = try Self.canonicalBoundedProjectionEntryCount(
                generationID: baseID, afterKind: work.afterAggregateKind,
                afterID: work.afterAggregateID, bounds: bounds, database: database
            )
            let rows = try database.query(
                """
                SELECT aggregate_kind, aggregate_id, revision, lifecycle,
                       canonical_state_bytes, canonical_state_digest, privacy, local_only,
                       source_sequence, source_event_id, source_event_hash, entry_digest
                FROM runtime_canonical_projection_entries
                WHERE generation_id = ? AND
                      (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id > ?))
                ORDER BY aggregate_kind, aggregate_id LIMIT ?
                """,
                bindings: [
                    .text(baseID), .text(work.afterAggregateKind),
                    .text(work.afterAggregateKind), .text(work.afterAggregateID),
                    .integer(Int64(limit)),
                ],
                maximumDecodedBytes: bounds.maximumBytes
            )
            var byteCount = 0
            var privacyDelta: [EventLedgerPrivacyClassification: Int] = [:]
            var nonlocalDelta = 0
            for row in rows {
                try Task.checkCancellation()
                let entry = try Self.decodeCanonicalProjectionEntry(row)
                byteCount += entry.canonicalStateBytes.count
                guard byteCount <= bounds.maximumBytes else {
                    throw RuntimeCanonicalProjectionPersistenceError.unitBudgetExceeded
                }
                try Self.insertCanonicalProjectionEntry(
                    generationID: work.generationID, entry: entry, database: database
                )
                privacyDelta[entry.privacy, default: 0] += 1
                if entry.localOnly == false { nonlocalDelta += 1 }
            }
            if let last = rows.last,
               case let .text(kind)? = last.value(named: "aggregate_kind"),
               case let .text(identifier)? = last.value(named: "aggregate_id") {
                try database.execute(
                    """
                    UPDATE runtime_canonical_projection_jobs
                    SET after_aggregate_kind = ?, after_aggregate_id = ?,
                        entry_count = entry_count + ?,
                        privacy_standard_count = privacy_standard_count + ?,
                        privacy_sensitive_count = privacy_sensitive_count + ?,
                        privacy_private_text_count = privacy_private_text_count + ?,
                        privacy_calendar_count = privacy_calendar_count + ?,
                        privacy_sync_count = privacy_sync_count + ?,
                        nonlocal_entry_count = nonlocal_entry_count + ?,
                        updated_at_ms = updated_at_ms + 1
                    WHERE projection_id = ? AND generation_id = ? AND phase = 'clone'
                      AND owner_id = ? AND fence_version = ?
                    """,
                    bindings: [
                        .text(kind), .text(identifier), .integer(Int64(rows.count)),
                        .integer(Int64(privacyDelta[.standard, default: 0])),
                        .integer(Int64(privacyDelta[.sensitive, default: 0])),
                        .integer(Int64(privacyDelta[.privateUserText, default: 0])),
                        .integer(Int64(privacyDelta[.calendarDerived, default: 0])),
                        .integer(Int64(privacyDelta[.syncMetadata, default: 0])),
                        .integer(Int64(nonlocalDelta)),
                        .text(work.projectionID.rawValue),
                        .text(work.generationID), .text(work.lease.ownerID),
                        .integer(Int64(work.lease.version)),
                    ]
                )
                return RuntimeCanonicalProjectionUnitResult(nextPhase: .clone, progressCursor: baseCursor)
            }
            guard work.entryCount == base.entryCount else {
                throw RuntimeCanonicalProjectionPersistenceError.derivedArtifactCorrupt
            }
            let changed = try database.execute(
                """
                UPDATE runtime_canonical_projection_jobs
                SET phase = 'replay', progress_sequence = ?, progress_event_id = ?,
                    progress_event_hash = ?, progress_source_digest = ?,
                    after_aggregate_kind = '', after_aggregate_id = '', updated_at_ms = updated_at_ms + 1
                WHERE projection_id = ? AND generation_id = ? AND phase = 'clone'
                  AND owner_id = ? AND fence_version = ?
                """,
                bindings: [
                    .integer(baseSequence), .text(baseEventID), .text(baseEventHash),
                    .text(baseSourceDigest), .text(work.projectionID.rawValue),
                    .text(work.generationID), .text(work.lease.ownerID),
                    .integer(Int64(work.lease.version)),
                ]
            )
            guard changed.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            return RuntimeCanonicalProjectionUnitResult(nextPhase: .replay, progressCursor: baseCursor)
        }
    }

    /// Re-authenticates the exact base and scrub continuation bound into the
    /// durable clone job. Keeping this transaction-local also gives migration
    /// and corruption tests one authority seam that cannot skip the digest.
    static func requireCanonicalCloneBase(
        _ work: RuntimeCanonicalProjectionBuildWork,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationAuthority {
        guard let boundBaseID = work.baseGenerationID,
              let boundCertificate = work.baseCertificateDigest,
              let boundRoot = work.baseRootDigest,
              let boundCount = work.baseEntryCount,
              let boundScrubCertificate = work.baseScrubCertificateDigest,
              let boundScrubCompletedAt = work.baseScrubCompletedAtMilliseconds else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let base = try requireCanonicalProjectionAuthority(
            definition: work.definition, requireNoPendingInvalidations: false,
            requireAtVerifiedHighWater: false, database: database
        )
        guard base.generationID == boundBaseID,
              base.certificateDigest == boundCertificate,
              base.entryRootDigest == boundRoot,
              base.entryCount == boundCount else {
            throw RuntimeCanonicalProjectionPersistenceError.derivedArtifactCorrupt
        }
        let scrub = try database.query(
            """
            SELECT projection_id, observed_shard_count, observed_posting_count,
                   observed_posting_bytes, completed_at_ms,
                   scrub_certificate_digest
            FROM runtime_canonical_scrub_certificates
            WHERE generation_id = ? AND generation_kind = 'projection'
              AND generation_certificate_digest = ? AND observed_count = ?
              AND root_digest = ? LIMIT 2
            """,
            bindings: [
                .text(boundBaseID), .text(boundCertificate),
                .integer(Int64(boundCount)), .text(boundRoot),
            ]
        )
        guard scrub.count == 1,
              scrub[0].value(named: "projection_id") == .text(work.projectionID.rawValue),
              case let .integer(observedShardCount)? = scrub[0]
                .value(named: "observed_shard_count"), observedShardCount >= 0,
              scrub[0].value(named: "observed_posting_count") == .integer(0),
              scrub[0].value(named: "observed_posting_bytes") == .integer(0),
              scrub[0].value(named: "completed_at_ms") == .integer(boundScrubCompletedAt),
              scrub[0].value(named: "scrub_certificate_digest") == .text(boundScrubCertificate),
              boundScrubCertificate == canonicalScrubCertificateDigest(
                  generationID: boundBaseID, kind: "projection",
                  projectionID: work.projectionID.rawValue,
                  generationCertificate: boundCertificate,
                  observedCount: boundCount,
                  observedShardCount: Int(observedShardCount),
                  observedPostingCount: 0, observedPostingBytes: 0,
                  rootDigest: boundRoot,
                  completedAtMilliseconds: boundScrubCompletedAt
              ) else {
            throw RuntimeCanonicalProjectionPersistenceError.derivedArtifactCorrupt
        }
        return base
    }

    func replayCanonicalProjectionEventPage(
        _ work: RuntimeCanonicalProjectionBuildWork,
        bounds: RuntimeCanonicalProjectionUnitBounds
    ) async throws -> RuntimeCanonicalProjectionUnitResult {
        try Task.checkCancellation()
        return try await withCanonicalImmediateTransaction { database in
            try Self.requireCanonicalProjectionBuildFence(work, phase: .replay, database: database)
            let remaining = work.targetCursor.sequence - (work.progressCursor?.sequence ?? 0)
            guard remaining > 0 else {
                try Self.advanceCanonicalProjectionJobToSealing(work, database: database)
                return RuntimeCanonicalProjectionUnitResult(
                    nextPhase: .sealProjection, progressCursor: work.targetCursor
                )
            }
            let sizeRows = try database.query(
                """
                SELECT length(payload) AS byte_count FROM runtime_semantic_events
                WHERE sequence > ? AND sequence <= ? ORDER BY sequence LIMIT ?
                """,
                bindings: [
                    .integer(Int64(work.progressCursor?.sequence ?? 0)),
                    .integer(Int64(work.targetCursor.sequence)),
                    .integer(Int64(min(bounds.maximumRows, Int(remaining)))),
                ]
            )
            let limit = try Self.canonicalBoundedCount(
                sizeRows: sizeRows, bounds: bounds, perRowOverhead: 4_096
            )
            let page = try CanonicalRuntimeSemanticEventStore.readVerifiedInTransaction(
                from: database, after: work.progressCursor, initialAnchor: nil, limit: limit
            )
            guard page.items.isEmpty == false else {
                throw RuntimeCanonicalProjectionPersistenceError.sourceAdvanced
            }
            guard let priorDigest = try? SHA256Digest(hexadecimal: work.progressSourceDigest) else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            var sourceDigest = priorDigest
            var terminal = work.progressCursor
            var byteCount = 0
            var entryDelta = 0
            var privacyDelta: [EventLedgerPrivacyClassification: Int] = [:]
            var nonlocalDelta = 0
            for inspection in page.items {
                try Task.checkCancellation()
                guard case let .supported(record) = inspection else {
                    throw RuntimeCanonicalProjectionSourceError.unsupportedSource
                }
                guard record.sourcePayloadVersion >= 3 else {
                    throw RuntimeCanonicalProjectionSourceError.blockedHistoricalPrivacy(
                        eventID: record.lineage.eventID.rawValue,
                        payloadVersion: record.sourcePayloadVersion
                    )
                }
                guard
                      let privacy = record.event.mutation.privacy,
                      let localOnly = record.event.mutation.localOnly else {
                    throw RuntimeCanonicalProjectionSourceError.unsupportedSource
                }
                sourceDigest = try RuntimeCanonicalReplaySourceChain.advance(
                    prior: sourceDigest, lineage: record.lineage
                )
                terminal = RuntimeCanonicalReplayCursor(
                    sequence: record.lineage.sequence,
                    eventID: record.lineage.eventID.rawValue,
                    eventHash: record.lineage.eventHash.hexadecimal
                )
                guard work.definition.allowedPrivacyClasses.contains(privacy),
                      work.definition.requiresLocalOnlySource == false || localOnly else {
                    throw RuntimeCanonicalProjectionSourceError.inconsistentSource
                }
                guard work.definition.inputEventTypes.contains(record.event.typeID) else { continue }
                for transition in record.event.mutation.aggregateTransitions {
                    try Task.checkCancellation()
                    byteCount += transition.canonicalStateBytes.count
                    guard byteCount <= bounds.maximumBytes else {
                        throw RuntimeCanonicalProjectionPersistenceError.unitBudgetExceeded
                    }
                    let cursor = RuntimeCanonicalReplayCursor(
                        sequence: record.lineage.sequence,
                        eventID: record.lineage.eventID.rawValue,
                        eventHash: record.lineage.eventHash.hexadecimal
                    )
                    let entry = RuntimeCanonicalProjectionEntry(
                        aggregate: transition.aggregate, revision: transition.resultingRevision,
                        lifecycle: transition.lifecycle,
                        canonicalStateBytes: transition.canonicalStateBytes,
                        canonicalStateDigest: transition.canonicalStateDigest,
                        privacy: privacy, localOnly: localOnly, sourceCursor: cursor
                    )
                    let prior = try database.query(
                        """
                        SELECT privacy, local_only FROM runtime_canonical_projection_entries
                        WHERE generation_id = ? AND aggregate_kind = ? AND aggregate_id = ? LIMIT 2
                        """,
                        bindings: [
                            .text(work.generationID), .text(entry.aggregate.kind.rawValue),
                            .text(entry.aggregate.id.rawValue),
                        ]
                    )
                    guard prior.count <= 1 else {
                        throw RuntimeCanonicalProjectionPersistenceError.derivedArtifactCorrupt
                    }
                    if let old = prior.first {
                        guard case let .text(oldRaw)? = old.value(named: "privacy"),
                              let oldPrivacy = EventLedgerPrivacyClassification(rawValue: oldRaw),
                              case let .integer(oldLocal)? = old.value(named: "local_only") else {
                            throw RuntimeCanonicalProjectionPersistenceError.derivedArtifactCorrupt
                        }
                        if oldPrivacy != entry.privacy {
                            privacyDelta[oldPrivacy, default: 0] -= 1
                            privacyDelta[entry.privacy, default: 0] += 1
                        }
                        nonlocalDelta += (entry.localOnly ? 0 : 1) - (oldLocal == 1 ? 0 : 1)
                    } else {
                        entryDelta += 1
                        privacyDelta[entry.privacy, default: 0] += 1
                        if entry.localOnly == false { nonlocalDelta += 1 }
                    }
                    try Self.upsertCanonicalProjectionEntry(
                        generationID: work.generationID, entry: entry, database: database
                    )
                }
            }
            guard let terminal, terminal.sequence <= work.targetCursor.sequence else {
                throw RuntimeCanonicalProjectionPersistenceError.sourceAdvanced
            }
            let reachedTarget = terminal == work.targetCursor
            if reachedTarget {
                let certificate = try RuntimeCanonicalReplayEngine.verifiedReconstructionCertificate(
                    at: terminal, database: database
                )
                guard certificate.sourceChainDigest == sourceDigest else {
                    throw RuntimeCanonicalProjectionPersistenceError.sourceAdvanced
                }
            }
            let nextPhase: RuntimeCanonicalProjectionBuildPhase = reachedTarget ? .sealProjection : .replay
            let changed = try database.execute(
                """
                UPDATE runtime_canonical_projection_jobs
                SET phase = ?, progress_sequence = ?, progress_event_id = ?, progress_event_hash = ?,
                    progress_source_digest = ?, after_aggregate_kind = '', after_aggregate_id = '',
                    shard_ordinal = 0, rolling_root_digest = ?,
                    entry_count = entry_count + ?,
                    privacy_standard_count = privacy_standard_count + ?,
                    privacy_sensitive_count = privacy_sensitive_count + ?,
                    privacy_private_text_count = privacy_private_text_count + ?,
                    privacy_calendar_count = privacy_calendar_count + ?,
                    privacy_sync_count = privacy_sync_count + ?,
                    nonlocal_entry_count = nonlocal_entry_count + ?,
                    updated_at_ms = updated_at_ms + 1
                WHERE projection_id = ? AND generation_id = ? AND phase = 'replay'
                  AND owner_id = ? AND fence_version = ?
                """,
                bindings: [
                    .text(nextPhase.rawValue), .integer(Int64(terminal.sequence)),
                    .text(terminal.eventID), .text(terminal.eventHash),
                    .text(sourceDigest.hexadecimal),
                    .text(RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal),
                    .integer(Int64(entryDelta)),
                    .integer(Int64(privacyDelta[.standard, default: 0])),
                    .integer(Int64(privacyDelta[.sensitive, default: 0])),
                    .integer(Int64(privacyDelta[.privateUserText, default: 0])),
                    .integer(Int64(privacyDelta[.calendarDerived, default: 0])),
                    .integer(Int64(privacyDelta[.syncMetadata, default: 0])),
                    .integer(Int64(nonlocalDelta)),
                    .text(work.projectionID.rawValue), .text(work.generationID),
                    .text(work.lease.ownerID), .integer(Int64(work.lease.version)),
                ]
            )
            guard changed.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            return RuntimeCanonicalProjectionUnitResult(nextPhase: nextPhase, progressCursor: terminal)
        }
    }

    func sealCanonicalProjectionEntryShard(
        _ work: RuntimeCanonicalProjectionBuildWork,
        bounds: RuntimeCanonicalProjectionUnitBounds
    ) async throws -> RuntimeCanonicalProjectionUnitResult {
        try Task.checkCancellation()
        return try await withCanonicalImmediateTransaction { database in
            try Self.requireCanonicalProjectionBuildFence(work, phase: .sealProjection, database: database)
            let limit = try Self.canonicalBoundedProjectionEntryCount(
                generationID: work.generationID, afterKind: work.afterAggregateKind,
                afterID: work.afterAggregateID, bounds: bounds, database: database
            )
            let rows = try database.query(
                """
                SELECT aggregate_kind, aggregate_id, revision, lifecycle,
                       canonical_state_bytes, canonical_state_digest, privacy, local_only,
                       source_sequence, source_event_id, source_event_hash, entry_digest
                FROM runtime_canonical_projection_entries
                WHERE generation_id = ? AND
                      (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id > ?))
                ORDER BY aggregate_kind, aggregate_id LIMIT ?
                """,
                bindings: [
                    .text(work.generationID), .text(work.afterAggregateKind),
                    .text(work.afterAggregateKind), .text(work.afterAggregateID),
                    .integer(Int64(limit)),
                ], maximumDecodedBytes: bounds.maximumBytes
            )
            if rows.isEmpty {
                guard work.sealedEntryCount == work.entryCount else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
                guard work.privacyCounts.values.reduce(0, +) == work.entryCount,
                      work.nonlocalEntryCount <= work.entryCount else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
                let observedPrivacy = Set(work.privacyCounts.compactMap {
                    $0.value > 0 ? $0.key : nil
                })
                guard observedPrivacy.isSubset(of: Set(work.definition.allowedPrivacyClasses)),
                      work.definition.requiresLocalOnlySource == false || work.nonlocalEntryCount == 0 else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
                let privacy = observedPrivacy.map(\.rawValue).sorted().joined(separator: ",")
                let certificate = Self.canonicalProjectionGenerationCertificateDigest(
                    work: work, entryCount: work.entryCount,
                    shardCount: work.shardOrdinal, rootDigest: work.rollingRootDigest,
                    privacy: privacy, localOnly: work.nonlocalEntryCount == 0
                )
                let generation = try database.execute(
                    """
                    UPDATE runtime_canonical_projection_generations
                    SET entry_count = ?, shard_count = ?, entry_root_digest = ?, privacy = ?,
                        local_only = ?, status = 'sealed', generation_certificate_digest = ?,
                        sealed_at_ms = created_at_ms
                    WHERE generation_id = ? AND status = 'building'
                    """,
                    bindings: [
                        .integer(Int64(work.entryCount)), .integer(Int64(work.shardOrdinal)),
                        .text(work.rollingRootDigest), .text(privacy),
                        .integer(work.nonlocalEntryCount == 0 ? 1 : 0), .text(certificate),
                        .text(work.generationID),
                    ]
                )
                guard generation.changedRowCount == 1 else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
                let next: RuntimeCanonicalProjectionBuildPhase = work.projectionID == .search ? .indexSearch : .ready
                try Self.updateCanonicalProjectionJobPhase(
                    work, nextPhase: next, resetKeyset: true, database: database
                )
                return RuntimeCanonicalProjectionUnitResult(nextPhase: next, progressCursor: work.targetCursor)
            }
            var material: [String] = [
                "runtime.projection.shard.v1", work.generationID,
                String(work.shardOrdinal), work.rollingRootDigest,
            ]
            var byteCount = 0
            for row in rows {
                try Task.checkCancellation()
                let entry = try Self.decodeCanonicalProjectionEntry(row)
                byteCount += entry.canonicalStateBytes.count
                guard byteCount <= bounds.maximumBytes,
                      case let .text(digest)? = row.value(named: "entry_digest") else {
                    throw RuntimeCanonicalProjectionPersistenceError.unitBudgetExceeded
                }
                material += [entry.aggregate.kind.rawValue, entry.aggregate.id.rawValue, digest]
            }
            guard case let .text(firstKind)? = rows.first?.value(named: "aggregate_kind"),
                  case let .text(firstID)? = rows.first?.value(named: "aggregate_id"),
                  case let .text(lastKind)? = rows.last?.value(named: "aggregate_kind"),
                  case let .text(lastID)? = rows.last?.value(named: "aggregate_id") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            let shardDigest = RuntimeTransactionDigest.digest(material)
            try database.execute(
                """
                INSERT INTO runtime_canonical_projection_shards(
                    generation_id, shard_ordinal, first_aggregate_kind, first_aggregate_id,
                    last_aggregate_kind, last_aggregate_id, entry_count,
                    prior_shard_digest, shard_digest
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                bindings: [
                    .text(work.generationID), .integer(Int64(work.shardOrdinal)),
                    .text(firstKind), .text(firstID), .text(lastKind), .text(lastID),
                    .integer(Int64(rows.count)), .text(work.rollingRootDigest), .text(shardDigest),
                ]
            )
            let changed = try database.execute(
                """
                UPDATE runtime_canonical_projection_jobs
                SET after_aggregate_kind = ?, after_aggregate_id = ?, shard_ordinal = ?,
                    rolling_root_digest = ?, sealed_entry_count = sealed_entry_count + ?,
                    updated_at_ms = updated_at_ms + 1
                WHERE projection_id = ? AND generation_id = ? AND phase = 'seal_projection'
                  AND owner_id = ? AND fence_version = ?
                """,
                bindings: [
                    .text(lastKind), .text(lastID), .integer(Int64(work.shardOrdinal + 1)),
                    .text(shardDigest), .integer(Int64(rows.count)),
                    .text(work.projectionID.rawValue),
                    .text(work.generationID), .text(work.lease.ownerID),
                    .integer(Int64(work.lease.version)),
                ]
            )
            guard changed.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            return RuntimeCanonicalProjectionUnitResult(
                nextPhase: .sealProjection, progressCursor: work.targetCursor
            )
        }
    }
}

extension CanonicalRuntimeStore {
    static func canonicalBoundedProjectionEntryCount(
        generationID: String,
        afterKind: String,
        afterID: String,
        bounds: RuntimeCanonicalProjectionUnitBounds,
        database: isolated SQLiteDatabase
    ) throws -> Int {
        let rows = try database.query(
            """
            SELECT length(canonical_state_bytes) AS byte_count
            FROM runtime_canonical_projection_entries
            WHERE generation_id = ? AND
                  (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id > ?))
            ORDER BY aggregate_kind, aggregate_id LIMIT ?
            """,
            bindings: [
                .text(generationID), .text(afterKind), .text(afterKind), .text(afterID),
                .integer(Int64(bounds.maximumRows)),
            ]
        )
        return try canonicalBoundedCount(sizeRows: rows, bounds: bounds, perRowOverhead: 4_096)
    }

    static func canonicalBoundedCount(
        sizeRows: [SQLiteRow],
        bounds: RuntimeCanonicalProjectionUnitBounds,
        perRowOverhead: Int
    ) throws -> Int {
        guard sizeRows.isEmpty == false else { return 1 }
        var count = 0
        var bytes = 0
        for row in sizeRows.prefix(bounds.maximumRows) {
            guard case let .integer(value)? = row.value(named: "byte_count"), value >= 0 else {
                break
            }
            let next = bytes + Int(value) + perRowOverhead
            if next > bounds.maximumBytes {
                if count == 0 {
                    throw RuntimeCanonicalProjectionPersistenceError.unitBudgetExceeded
                }
                break
            }
            bytes = next
            count += 1
        }
        return max(1, count)
    }

    static func requireCanonicalProjectionBuildFence(
        _ work: RuntimeCanonicalProjectionBuildWork,
        phase: RuntimeCanonicalProjectionBuildPhase,
        database: isolated SQLiteDatabase
    ) throws {
        try Task.checkCancellation()
        let rows = try database.query(
            """
            SELECT 1 FROM runtime_canonical_projection_jobs AS job
            JOIN runtime_canonical_projection_leases AS lease
              ON lease.projection_id = job.projection_id
             AND lease.owner_id = job.owner_id
             AND lease.lease_version = job.fence_version
            WHERE job.projection_id = ? AND job.generation_id = ? AND job.phase = ?
              AND job.owner_id = ? AND job.fence_version = ?
              AND lease.expires_at_ms = ? AND lease.expires_at_ms > ?
            LIMIT 2
            """,
            bindings: [
                .text(work.projectionID.rawValue), .text(work.generationID), .text(phase.rawValue),
                .text(work.lease.ownerID), .integer(Int64(work.lease.version)),
                .integer(work.lease.expiresAtMilliseconds),
                .integer(work.operationNowMilliseconds),
            ]
        )
        guard rows.count == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
    }

    static func canonicalProjectionEntryDigest(_ entry: RuntimeCanonicalProjectionEntry) -> String {
        RuntimeTransactionDigest.digest([
            "runtime.projection.entry.v1", entry.aggregate.kind.rawValue,
            entry.aggregate.id.rawValue, String(entry.revision), entry.lifecycle.rawValue,
            entry.canonicalStateDigest, entry.privacy.rawValue, String(entry.localOnly),
            String(entry.sourceCursor.sequence), entry.sourceCursor.eventID,
            entry.sourceCursor.eventHash,
        ])
    }

    static func decodeCanonicalProjectionEntry(_ row: SQLiteRow) throws -> RuntimeCanonicalProjectionEntry {
        guard case let .text(kindRaw)? = row.value(named: "aggregate_kind"),
              let kind = RuntimeSemanticAggregateKind(rawValue: kindRaw),
              case let .text(identifierRaw)? = row.value(named: "aggregate_id"),
              let identifier = RuntimeAggregateID(rawValue: identifierRaw),
              case let .integer(revision)? = row.value(named: "revision"), revision >= 0,
              case let .text(lifecycleRaw)? = row.value(named: "lifecycle"),
              let lifecycle = RuntimeAggregateLifecycle(rawValue: lifecycleRaw),
              case let .blob(bytes)? = row.value(named: "canonical_state_bytes"),
              case let .text(stateDigest)? = row.value(named: "canonical_state_digest"),
              LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == stateDigest,
              case let .text(privacyRaw)? = row.value(named: "privacy"),
              let privacy = EventLedgerPrivacyClassification(rawValue: privacyRaw),
              case let .integer(localOnly)? = row.value(named: "local_only"),
              case let .integer(sequence)? = row.value(named: "source_sequence"), sequence > 0,
              case let .text(eventID)? = row.value(named: "source_event_id"),
              case let .text(eventHash)? = row.value(named: "source_event_hash"),
              case let .text(storedDigest)? = row.value(named: "entry_digest") else {
            throw RuntimeCanonicalProjectionPersistenceError.derivedArtifactCorrupt
        }
        let entry = RuntimeCanonicalProjectionEntry(
            aggregate: RuntimeSemanticAggregate(kind: kind, id: identifier),
            revision: UInt64(revision), lifecycle: lifecycle,
            canonicalStateBytes: bytes, canonicalStateDigest: stateDigest,
            privacy: privacy, localOnly: localOnly == 1,
            sourceCursor: RuntimeCanonicalReplayCursor(
                sequence: UInt64(sequence), eventID: eventID, eventHash: eventHash
            )
        )
        guard entry.sourceCursor.isWellFormed,
              canonicalProjectionEntryDigest(entry) == storedDigest else {
            throw RuntimeCanonicalProjectionPersistenceError.derivedArtifactCorrupt
        }
        return entry
    }

    static func insertCanonicalProjectionEntry(
        generationID: String,
        entry: RuntimeCanonicalProjectionEntry,
        database: isolated SQLiteDatabase
    ) throws {
        try database.execute(
            """
            INSERT INTO runtime_canonical_projection_entries(
                generation_id, aggregate_kind, aggregate_id, revision, lifecycle,
                canonical_state_bytes, canonical_state_digest, privacy, local_only,
                source_sequence, source_event_id, source_event_hash, entry_digest
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: Self.canonicalProjectionEntryBindings(generationID: generationID, entry: entry)
        )
    }

    static func upsertCanonicalProjectionEntry(
        generationID: String,
        entry: RuntimeCanonicalProjectionEntry,
        database: isolated SQLiteDatabase
    ) throws {
        try database.execute(
            """
            INSERT INTO runtime_canonical_projection_entries(
                generation_id, aggregate_kind, aggregate_id, revision, lifecycle,
                canonical_state_bytes, canonical_state_digest, privacy, local_only,
                source_sequence, source_event_id, source_event_hash, entry_digest
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(generation_id, aggregate_kind, aggregate_id) DO UPDATE SET
                revision = excluded.revision, lifecycle = excluded.lifecycle,
                canonical_state_bytes = excluded.canonical_state_bytes,
                canonical_state_digest = excluded.canonical_state_digest,
                privacy = excluded.privacy, local_only = excluded.local_only,
                source_sequence = excluded.source_sequence,
                source_event_id = excluded.source_event_id,
                source_event_hash = excluded.source_event_hash,
                entry_digest = excluded.entry_digest
            WHERE runtime_canonical_projection_entries.source_sequence < excluded.source_sequence
            """,
            bindings: Self.canonicalProjectionEntryBindings(generationID: generationID, entry: entry)
        )
    }

    private static func canonicalProjectionEntryBindings(
        generationID: String,
        entry: RuntimeCanonicalProjectionEntry
    ) -> [SQLiteBinding] {
        [
            .text(generationID), .text(entry.aggregate.kind.rawValue),
            .text(entry.aggregate.id.rawValue), .integer(Int64(entry.revision)),
            .text(entry.lifecycle.rawValue), .blob(entry.canonicalStateBytes),
            .text(entry.canonicalStateDigest), .text(entry.privacy.rawValue),
            .integer(entry.localOnly ? 1 : 0), .integer(Int64(entry.sourceCursor.sequence)),
            .text(entry.sourceCursor.eventID), .text(entry.sourceCursor.eventHash),
            .text(canonicalProjectionEntryDigest(entry)),
        ]
    }

    static func advanceCanonicalProjectionJobToSealing(
        _ work: RuntimeCanonicalProjectionBuildWork,
        database: isolated SQLiteDatabase
    ) throws {
        try updateCanonicalProjectionJobPhase(
            work, nextPhase: .sealProjection, resetKeyset: true, database: database
        )
    }

    static func updateCanonicalProjectionJobPhase(
        _ work: RuntimeCanonicalProjectionBuildWork,
        nextPhase: RuntimeCanonicalProjectionBuildPhase,
        resetKeyset: Bool,
        database: isolated SQLiteDatabase
    ) throws {
        let changed = try database.execute(
            """
            UPDATE runtime_canonical_projection_jobs
            SET phase = ?, after_aggregate_kind = ?, after_aggregate_id = ?,
                shard_ordinal = ?, rolling_root_digest = ?, updated_at_ms = updated_at_ms + 1
            WHERE projection_id = ? AND generation_id = ? AND phase = ?
              AND owner_id = ? AND fence_version = ?
            """,
            bindings: [
                .text(nextPhase.rawValue), .text(resetKeyset ? "" : work.afterAggregateKind),
                .text(resetKeyset ? "" : work.afterAggregateID),
                .integer(Int64(resetKeyset ? 0 : work.shardOrdinal)),
                .text(resetKeyset ? RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal : work.rollingRootDigest),
                .text(work.projectionID.rawValue), .text(work.generationID),
                .text(work.phase.rawValue), .text(work.lease.ownerID),
                .integer(Int64(work.lease.version)),
            ]
        )
        guard changed.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
    }

    static func canonicalProjectionGenerationCertificateDigest(
        work: RuntimeCanonicalProjectionBuildWork,
        entryCount: Int,
        shardCount: Int,
        rootDigest: String,
        privacy: String,
        localOnly: Bool
    ) -> String {
        canonicalProjectionGenerationCertificateDigest(
            generationID: work.generationID,
            projectionID: work.projectionID,
            definitionDigest: work.definition.authorityDigest,
            outputVersion: work.definition.outputVersion,
            sourceCursor: work.targetCursor,
            sourceChainDigest: work.sourceChainDigest,
            entryCount: entryCount,
            shardCount: shardCount,
            rootDigest: rootDigest,
            privacy: privacy,
            localOnly: localOnly,
            invalidationDigest: work.invalidationDigest
        )
    }

    static func canonicalProjectionGenerationCertificateDigest(
        generationID: String,
        projectionID: RuntimeCanonicalProjectionID,
        definitionDigest: String,
        outputVersion: Int,
        sourceCursor: RuntimeCanonicalReplayCursor,
        sourceChainDigest: String,
        entryCount: Int,
        shardCount: Int,
        rootDigest: String,
        privacy: String,
        localOnly: Bool,
        invalidationDigest: String
    ) -> String {
        RuntimeTransactionDigest.digest([
            "runtime.projection.generation-certificate.v1", generationID,
            projectionID.rawValue, definitionDigest,
            String(outputVersion), String(sourceCursor.sequence),
            sourceCursor.eventID, sourceCursor.eventHash,
            sourceChainDigest, String(entryCount), String(shardCount),
            rootDigest, privacy, String(localOnly), invalidationDigest,
        ])
    }
}
