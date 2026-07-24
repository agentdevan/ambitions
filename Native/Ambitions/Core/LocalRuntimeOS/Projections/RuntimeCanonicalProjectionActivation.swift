import AmbitionsRuntimeSQLite
import Foundation

extension CanonicalRuntimeStore {
    func activateCanonicalProjectionGeneration(
        _ work: RuntimeCanonicalProjectionBuildWork,
        nowMilliseconds: Int64
    ) async throws {
        try Task.checkCancellation()
        try await withCanonicalImmediateTransaction { database in
            try Self.activateCanonicalProjectionGenerationInTransaction(
                work, nowMilliseconds: nowMilliseconds, database: database
            )
        }
    }

    static func activateCanonicalProjectionGenerationInTransaction(
        _ work: RuntimeCanonicalProjectionBuildWork,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
            try Task.checkCancellation()
            try Self.requireCanonicalProjectionBuildFence(work, phase: .ready, database: database)
            let targetCertificate = try RuntimeCanonicalReplayEngine
                .verifiedReconstructionCertificate(at: work.targetCursor, database: database)
            guard targetCertificate.sourceChainDigest.hexadecimal == work.sourceChainDigest else {
                throw RuntimeCanonicalProjectionPersistenceError.sourceAdvanced
            }
            let generationRows = try database.query(
                """
                SELECT definition_digest, output_version, source_sequence, source_event_id,
                       source_event_hash, source_chain_digest, entry_count, shard_count,
                       entry_root_digest, privacy, local_only, generation_certificate_digest
                FROM runtime_canonical_projection_generations
                WHERE generation_id = ? AND projection_id = ? AND status = 'sealed' LIMIT 2
                """,
                bindings: [.text(work.generationID), .text(work.projectionID.rawValue)]
            )
            guard generationRows.count == 1,
                  generationRows[0].value(named: "definition_digest") == .text(work.definition.authorityDigest),
                  generationRows[0].value(named: "output_version") == .integer(Int64(work.definition.outputVersion)),
                  generationRows[0].value(named: "source_sequence") == .integer(Int64(work.targetCursor.sequence)),
                  generationRows[0].value(named: "source_event_id") == .text(work.targetCursor.eventID),
                  generationRows[0].value(named: "source_event_hash") == .text(work.targetCursor.eventHash),
                  generationRows[0].value(named: "source_chain_digest") == .text(work.sourceChainDigest),
                  case let .integer(entryCount)? = generationRows[0].value(named: "entry_count"), entryCount >= 0,
                  case let .integer(shardCount)? = generationRows[0].value(named: "shard_count"), shardCount >= 0,
                  case let .text(rootDigest)? = generationRows[0].value(named: "entry_root_digest"),
                  case let .text(privacy)? = generationRows[0].value(named: "privacy"),
                  case let .integer(localOnly)? = generationRows[0].value(named: "local_only"),
                  case let .text(certificate)? = generationRows[0].value(named: "generation_certificate_digest") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            let expectedCertificate = Self.canonicalProjectionGenerationCertificateDigest(
                work: work, entryCount: Int(entryCount), shardCount: Int(shardCount),
                rootDigest: rootDigest, privacy: privacy, localOnly: localOnly == 1
            )
            guard certificate == expectedCertificate else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            let invalidations = try Self.authenticatedInvalidations(
                projectionID: work.projectionID,
                limit: RuntimeCanonicalProjectionWorker.maximumInvalidationBatch,
                database: database
            )
            guard let capturedEnd = invalidations.firstIndex(where: {
                $0.id == work.invalidationIDs.last
            }) else {
                throw RuntimeCanonicalProjectionPersistenceError.invalidationAdvanced
            }
            let capturedInvalidations = Array(invalidations[...capturedEnd])
            let observedDigest = RuntimeTransactionDigest.digest(capturedInvalidations.flatMap {
                [$0.id, String($0.sourceCursor.sequence), $0.sourceCursor.eventID, $0.sourceCursor.eventHash]
            })
            guard capturedInvalidations.map(\.id) == work.invalidationIDs,
                  observedDigest == work.invalidationDigest else {
                throw RuntimeCanonicalProjectionPersistenceError.invalidationAdvanced
            }
            if work.projectionID == .search {
                try Self.requireSealedCanonicalSearchGeneration(work, database: database)
            }

            let retiredProjectionRows = try database.query(
                "SELECT generation_id, generation_certificate_digest FROM runtime_canonical_projection_generations WHERE projection_id = ? AND status = 'published' LIMIT 2",
                bindings: [.text(work.projectionID.rawValue)]
            )
            guard retiredProjectionRows.count <= 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            let retiredSearchRows: [SQLiteRow]
            if work.projectionID == .search {
                retiredSearchRows = try database.query(
                    "SELECT generation_id, generation_certificate_digest FROM runtime_canonical_search_generations WHERE status = 'published' LIMIT 2"
                )
                guard retiredSearchRows.count <= 1 else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
            } else { retiredSearchRows = [] }
            try Self.retireCanonicalGenerationScrubJobs(
                rows: retiredSearchRows + retiredProjectionRows, database: database
            )

            try database.execute(
                """
                UPDATE runtime_canonical_projection_generations SET status = 'retired'
                WHERE projection_id = ? AND status = 'published'
                """,
                bindings: [.text(work.projectionID.rawValue)]
            )
            let published = try database.execute(
                "UPDATE runtime_canonical_projection_generations SET status = 'published' WHERE generation_id = ? AND status = 'sealed'",
                bindings: [.text(work.generationID)]
            )
            guard published.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            try database.execute(
                """
                INSERT INTO runtime_canonical_projection_active_generations(
                    projection_id, generation_id, generation_certificate_digest, activated_at_ms
                ) VALUES (?, ?, ?, ?)
                ON CONFLICT(projection_id) DO UPDATE SET
                    generation_id = excluded.generation_id,
                    generation_certificate_digest = excluded.generation_certificate_digest,
                    activated_at_ms = excluded.activated_at_ms
                """,
                bindings: [
                    .text(work.projectionID.rawValue), .text(work.generationID),
                    .text(certificate), .integer(nowMilliseconds),
                ]
            )
            if work.projectionID == .search {
                try Self.activateCanonicalSearchGeneration(work, nowMilliseconds: nowMilliseconds, database: database)
                let searchGenerationID = Self.canonicalSearchGenerationID(work)
                let searchCertificateRows = try database.query(
                    "SELECT generation_certificate_digest FROM runtime_canonical_search_generations WHERE generation_id = ? LIMIT 2",
                    bindings: [.text(searchGenerationID)]
                )
                guard searchCertificateRows.count == 1,
                      case let .text(searchCertificate)? = searchCertificateRows[0]
                        .value(named: "generation_certificate_digest") else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
                try Self.scheduleCanonicalGenerationScrub(
                    generationID: searchGenerationID, kind: "search",
                    certificate: searchCertificate, nowMilliseconds: nowMilliseconds,
                    database: database
                )
            }
            try Self.scheduleCanonicalGenerationScrub(
                generationID: work.generationID, kind: "projection",
                certificate: certificate, nowMilliseconds: nowMilliseconds,
                database: database
            )
            try Self.scheduleCanonicalGenerationGC(
                rows: retiredSearchRows, kind: "search", firstPhase: "postings",
                nowMilliseconds: nowMilliseconds, database: database
            )
            try Self.scheduleCanonicalGenerationGC(
                rows: retiredProjectionRows, kind: "projection", firstPhase: "entries",
                nowMilliseconds: nowMilliseconds, database: database
            )
            for invalidation in capturedInvalidations {
                try database.execute(
                    """
                    INSERT INTO runtime_canonical_projection_invalidation_acks(
                        projection_id, invalidation_id, generation_id, source_sequence,
                        generation_certificate_digest, acknowledged_at_ms
                    ) VALUES (?, ?, ?, ?, ?, ?)
                    """,
                    bindings: [
                        .text(work.projectionID.rawValue), .text(invalidation.id),
                        .text(work.generationID), .integer(Int64(work.targetCursor.sequence)),
                        .text(certificate), .integer(nowMilliseconds),
                    ]
                )
            }
            let deleted = try database.execute(
                "DELETE FROM runtime_canonical_projection_jobs WHERE projection_id = ? AND generation_id = ? AND phase = 'ready' AND owner_id = ? AND fence_version = ?",
                bindings: [
                    .text(work.projectionID.rawValue), .text(work.generationID),
                    .text(work.lease.ownerID), .integer(Int64(work.lease.version)),
                ]
            )
            guard deleted.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            let released = try database.execute(
                "DELETE FROM runtime_canonical_projection_leases WHERE projection_id = ? AND owner_id = ? AND lease_version = ?",
                bindings: [
                    .text(work.projectionID.rawValue), .text(work.lease.ownerID),
                    .integer(Int64(work.lease.version)),
                ]
            )
            guard released.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
            }
    }
}

extension CanonicalRuntimeStore {
    static func requireSealedCanonicalSearchGeneration(
        _ work: RuntimeCanonicalProjectionBuildWork,
        database: isolated SQLiteDatabase
    ) throws {
        let generationID = canonicalSearchGenerationID(work)
        let rows = try database.query(
            """
            SELECT generation_id, projection_generation_id, coverage, definition_digest,
                   source_sequence, source_event_hash, document_count,
                   posting_count, posting_bytes, shard_count,
                   document_root_digest, generation_certificate_digest
            FROM runtime_canonical_search_generations
            WHERE generation_id = ? AND projection_generation_id = ? AND status = 'sealed' LIMIT 2
            """,
            bindings: [.text(generationID), .text(work.generationID)]
        )
        guard rows.count == 1,
              rows[0].value(named: "generation_id") == .text(generationID),
              rows[0].value(named: "projection_generation_id") == .text(work.generationID),
              rows[0].value(named: "coverage") == .text(RuntimeCanonicalSearchCoverage.aggregateMetadataOnly.rawValue),
              rows[0].value(named: "definition_digest") == .text(work.definition.authorityDigest),
              rows[0].value(named: "source_sequence") == .integer(Int64(work.targetCursor.sequence)),
              rows[0].value(named: "source_event_hash") == .text(work.targetCursor.eventHash),
              case let .integer(documentCount)? = rows[0].value(named: "document_count"), documentCount >= 0,
              case let .integer(postingCount)? = rows[0].value(named: "posting_count"), postingCount >= 0,
              case let .integer(postingBytes)? = rows[0].value(named: "posting_bytes"), postingBytes >= 0,
              case let .integer(shardCount)? = rows[0].value(named: "shard_count"), shardCount >= 0,
              case let .text(rootDigest)? = rows[0].value(named: "document_root_digest"),
              case let .text(certificate)? = rows[0].value(named: "generation_certificate_digest"),
              certificate == canonicalSearchGenerationCertificateDigest(
                  generationID: generationID,
                  projectionGenerationID: work.generationID,
                  coverage: .aggregateMetadataOnly,
                  definitionDigest: work.definition.authorityDigest,
                  sourceCursor: work.targetCursor,
                  documentCount: Int(documentCount),
                  postingCount: Int(postingCount), postingBytes: Int(postingBytes),
                  shardCount: Int(shardCount),
                  rootDigest: rootDigest
              ) else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
    }

    static func activateCanonicalSearchGeneration(
        _ work: RuntimeCanonicalProjectionBuildWork,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        let generationID = canonicalSearchGenerationID(work)
        let rows = try database.query(
            "SELECT generation_certificate_digest FROM runtime_canonical_search_generations WHERE generation_id = ? AND status = 'sealed' LIMIT 2",
            bindings: [.text(generationID)]
        )
        guard rows.count == 1,
              case let .text(certificate)? = rows[0].value(named: "generation_certificate_digest") else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        try database.execute(
            "UPDATE runtime_canonical_search_generations SET status = 'retired' WHERE status = 'published'"
        )
        let published = try database.execute(
            "UPDATE runtime_canonical_search_generations SET status = 'published' WHERE generation_id = ? AND status = 'sealed'",
            bindings: [.text(generationID)]
        )
        guard published.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        try database.execute(
            """
            INSERT INTO runtime_canonical_search_active_generation(
                singleton_id, generation_id, generation_certificate_digest, activated_at_ms
            ) VALUES (1, ?, ?, ?)
            ON CONFLICT(singleton_id) DO UPDATE SET
                generation_id = excluded.generation_id,
                generation_certificate_digest = excluded.generation_certificate_digest,
                activated_at_ms = excluded.activated_at_ms
            """,
            bindings: [.text(generationID), .text(certificate), .integer(nowMilliseconds)]
        )
    }

    static func scheduleCanonicalGenerationGC(
        rows: [SQLiteRow],
        kind: String,
        firstPhase: String,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        guard let row = rows.first else { return }
        guard case let .text(generationID)? = row.value(named: "generation_id"),
              case let .text(certificate)? = row.value(named: "generation_certificate_digest") else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let existing = try database.query(
            "SELECT generation_kind, phase, expected_certificate_digest FROM runtime_canonical_generation_gc_jobs WHERE generation_id = ? LIMIT 2",
            bindings: [.text(generationID)]
        )
        if let existingJob = existing.first {
            guard existing.count == 1,
                  existingJob.value(named: "generation_kind") == .text(kind),
                  existingJob.value(named: "phase") == .text(firstPhase),
                  existingJob.value(named: "expected_certificate_digest") == .text(certificate) else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            return
        }
        let serviceTicket = try issueCanonicalServiceTicket(database: database)
        try database.execute(
            """
            INSERT INTO runtime_canonical_generation_gc_jobs(
                generation_id, generation_kind, phase, after_aggregate_kind,
                after_aggregate_id, owner_id, fence_version, expires_at_ms,
                expected_certificate_digest, last_served_at_ms, service_ticket
            ) VALUES (?, ?, ?, '', '', 'unclaimed', 1, ?, ?, ?, ?)
            """,
            bindings: [
                .text(generationID), .text(kind), .text(firstPhase),
                .integer(nowMilliseconds), .text(certificate), .integer(nowMilliseconds),
                .integer(serviceTicket),
            ]
        )
    }

    static func scheduleCanonicalGenerationScrub(
        generationID: String,
        kind: String,
        certificate: String,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        let existing = try database.query(
            "SELECT generation_kind, expected_certificate_digest FROM runtime_canonical_generation_scrub_jobs WHERE generation_id = ? LIMIT 2",
            bindings: [.text(generationID)]
        )
        if let existingJob = existing.first {
            guard existing.count == 1,
                  existingJob.value(named: "generation_kind") == .text(kind),
                  existingJob.value(named: "expected_certificate_digest") == .text(certificate) else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            return
        }
        let serviceTicket = try issueCanonicalServiceTicket(database: database)
        try database.execute(
            """
            INSERT INTO runtime_canonical_generation_scrub_jobs(
                generation_id, generation_kind, phase, shard_ordinal,
                observed_count, observed_posting_count, observed_posting_bytes,
                expected_posting_count, expected_posting_bytes,
                observed_privacy_standard_count, observed_privacy_sensitive_count,
                observed_privacy_private_text_count, observed_privacy_calendar_count,
                observed_privacy_sync_count, observed_nonlocal_count,
                after_posting_token, after_posting_kind, after_posting_id,
                after_posting_field, after_posting_ordinal,
                rolling_root_digest, previous_last_kind, previous_last_id,
                owner_id, fence_version, expires_at_ms,
                expected_certificate_digest, last_served_at_ms, service_ticket
            ) VALUES (?, ?, 'shards', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                      '', '', '', -1, -1, ?, '', '',
                      'unclaimed', 1, ?, ?, ?, ?)
            """,
            bindings: [
                .text(generationID), .text(kind),
                .text(RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal),
                .integer(nowMilliseconds), .text(certificate), .integer(nowMilliseconds),
                .integer(serviceTicket),
            ]
        )
    }
}

extension CanonicalRuntimeStore {
    static func retireCanonicalGenerationScrubJobs(
        rows: [SQLiteRow],
        database: isolated SQLiteDatabase
    ) throws {
        for row in rows {
            guard case let .text(retiredID)? = row.value(named: "generation_id") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            try database.execute(
                "DELETE FROM runtime_canonical_generation_scrub_jobs WHERE generation_id = ?",
                bindings: [.text(retiredID)]
            )
        }
    }
}
