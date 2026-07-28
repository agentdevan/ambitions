import AmbitionsRuntimeSQLite
import Foundation

private enum RuntimeCanonicalProjectionBuildSQL {
    static let pendingInvalidations = """
        SELECT i.invalidation_id, i.projection_id, i.terminal_event_sequence,
               i.invalidation_version, e.event_id, e.event_hash, e.type_id,
               i.payload, i.payload_checksum,
               r.receipt_id, r.preparation_id, r.command_id,
               r.receipt_version, r.created_at_ms,
               c.core_version, c.core_digest, c.created_at_ms AS core_created_at_ms,
               authority.artifact_digest,
               finalized.final_result_version, finalized.final_result_checksum
        FROM runtime_commit_projection_invalidations AS i
        LEFT JOIN runtime_semantic_events AS e ON e.sequence = i.terminal_event_sequence
        LEFT JOIN runtime_commit_receipts AS r ON r.terminal_event_sequence = i.terminal_event_sequence
        LEFT JOIN runtime_committed_receipt_cores AS c
          ON c.receipt_id = r.receipt_id
         AND c.command_id = r.command_id
         AND c.terminal_event_sequence = r.terminal_event_sequence
         AND c.created_at_ms = r.created_at_ms
        LEFT JOIN runtime_receipt_artifact_links AS authority
          ON authority.receipt_id = r.receipt_id
         AND authority.artifact_kind = 'projection_invalidation'
         AND authority.artifact_id = i.invalidation_id
         AND authority.artifact_digest = i.payload_checksum
        LEFT JOIN runtime_command_idempotency AS finalized
          ON finalized.command_id = r.command_id
        LEFT JOIN runtime_canonical_projection_invalidation_acks AS a
          ON a.projection_id = i.projection_id AND a.invalidation_id = i.invalidation_id
        WHERE a.invalidation_id IS NULL AND i.projection_id = ?
        ORDER BY i.terminal_event_sequence, i.invalidation_id LIMIT ?
        """
}

private enum RuntimeCanonicalProjectionBuildCodec {
    static func decodeCanonical<Value: Codable>(_ type: Value.Type, bytes: Data) throws -> Value {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let value: Value
        do { value = try decoder.decode(type, from: bytes) }
        catch { throw RuntimeCanonicalProjectionPersistenceError.corruptInvalidation }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        guard try encoder.encode(value) == bytes else {
            throw RuntimeCanonicalProjectionPersistenceError.corruptInvalidation
        }
        return value
    }
}

extension RuntimeCanonicalDerivedTransactionGateway {
    func publishCanonicalEmptyAuthoritiesIfNeeded(
        registry: RuntimeCanonicalProjectionDefinitionRegistry,
        nowMilliseconds: Int64
    ) async throws -> Bool {
        try Task.checkCancellation()
        return try await withDerivedImmediateTransaction { database in
            try CanonicalRuntimeProjectionSchemaPlan.requireIntegratedSchema(in: database)
            let source = try database.query("SELECT 1 FROM runtime_semantic_events LIMIT 1")
            let invalidations = try database.query(
                "SELECT 1 FROM runtime_commit_projection_invalidations LIMIT 1"
            )
            let jobs = try database.query("SELECT 1 FROM runtime_canonical_projection_jobs LIMIT 1")
            guard source.isEmpty, invalidations.isEmpty, jobs.isEmpty else { return false }
            let activeRows = try database.query(
                "SELECT projection_id FROM runtime_canonical_projection_active_generations ORDER BY projection_id LIMIT ?",
                bindings: [.integer(Int64(registry.definitions.count + 1))]
            )
            guard activeRows.count <= registry.definitions.count else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            let activeIDs = try Set(activeRows.map { row -> RuntimeCanonicalProjectionID in
                guard case let .text(raw)? = row.value(named: "projection_id"),
                      let typed = RuntimeCanonicalProjectionID(rawValue: raw),
                      registry.definitions[typed] != nil else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
                return typed
            })
            guard activeIDs.count < registry.definitions.count else { return false }

            let cursor = RuntimeCanonicalReplayCursor.emptySource
            let emptyDigest = RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
            let invalidationDigest = RuntimeTransactionDigest.digest([])
            // Bootstrap publishes already-authenticated empty authorities and
            // certificates directly. It creates no maintenance work and must
            // not initialize or advance the maintenance service-ticket clock.
            for definition in registry.definitions.values.sorted(by: { $0.id < $1.id }) {
                let exists = try database.query(
                    "SELECT 1 FROM runtime_canonical_projection_active_generations WHERE projection_id = ? LIMIT 1",
                    bindings: [.text(definition.id.rawValue)]
                )
                if exists.isEmpty == false { continue }
                let generationID = RuntimeTransactionDigest.digest([
                    "runtime.projection.empty-generation.v1", definition.id.rawValue,
                    definition.authorityDigest, String(definition.outputVersion), emptyDigest,
                ])
                let certificate = Self.canonicalProjectionGenerationCertificateDigest(
                    generationID: generationID, projectionID: definition.id,
                    definitionDigest: definition.authorityDigest,
                    outputVersion: definition.outputVersion, sourceCursor: cursor,
                    sourceChainDigest: emptyDigest, entryCount: 0, shardCount: 0,
                    rootDigest: emptyDigest, privacy: "", localOnly: true,
                    invalidationDigest: invalidationDigest
                )
                try database.execute(
                    """
                    INSERT INTO runtime_canonical_projection_generations(
                        generation_id, projection_id, definition_version, definition_digest,
                        output_version, source_sequence, source_event_id, source_event_hash,
                        source_chain_digest, first_invalidation_id, last_invalidation_id,
                        invalidation_digest, entry_count, shard_count, entry_root_digest,
                        privacy, local_only, status, generation_certificate_digest,
                        created_at_ms, sealed_at_ms
                    ) VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, 'runtime.empty-source',
                              'runtime.empty-source', ?, 0, 0, ?, '', 1, 'published', ?, ?, ?)
                    """,
                    bindings: [
                        .text(generationID), .text(definition.id.rawValue),
                        .integer(Int64(definition.definitionVersion)),
                        .text(definition.authorityDigest), .integer(Int64(definition.outputVersion)),
                        .text(cursor.eventID), .text(cursor.eventHash), .text(emptyDigest),
                        .text(invalidationDigest), .text(emptyDigest), .text(certificate),
                        .integer(nowMilliseconds), .integer(nowMilliseconds),
                    ]
                )
                try database.execute(
                    """
                    INSERT INTO runtime_canonical_projection_active_generations(
                        projection_id, generation_id, generation_certificate_digest, activated_at_ms
                    ) VALUES (?, ?, ?, ?)
                    """,
                    bindings: [
                        .text(definition.id.rawValue), .text(generationID), .text(certificate),
                        .integer(nowMilliseconds),
                    ]
                )
                let projectionScrubCertificate = Self.canonicalScrubCertificateDigest(
                    generationID: generationID, kind: "projection",
                    projectionID: definition.id.rawValue,
                    generationCertificate: certificate, observedCount: 0,
                    observedShardCount: 0,
                    observedPostingCount: 0, observedPostingBytes: 0,
                    rootDigest: emptyDigest,
                    completedAtMilliseconds: nowMilliseconds
                )
                try database.execute(
                    """
                    INSERT INTO runtime_canonical_scrub_certificates(
                        generation_id, generation_kind, projection_id,
                        generation_certificate_digest, observed_count,
                        observed_shard_count, observed_posting_count,
                        observed_posting_bytes, root_digest,
                        completed_at_ms, scrub_certificate_digest
                    ) VALUES (?, 'projection', ?, ?, 0, 0, 0, 0, ?, ?, ?)
                    """,
                    bindings: [
                        .text(generationID), .text(definition.id.rawValue),
                        .text(certificate), .text(emptyDigest), .integer(nowMilliseconds),
                        .text(projectionScrubCertificate),
                    ]
                )
                if definition.id == .search {
                    let searchGenerationID = RuntimeTransactionDigest.digest([
                        "runtime.search.generation.v1", generationID,
                        RuntimeCanonicalSearchCoverage.aggregateKindOnly.rawValue,
                        definition.authorityDigest, "0", cursor.eventHash,
                    ])
                    let searchCertificate = Self.canonicalSearchGenerationCertificateDigest(
                        generationID: searchGenerationID,
                        projectionGenerationID: generationID,
                        coverage: .aggregateKindOnly,
                        definitionDigest: definition.authorityDigest,
                        sourceCursor: cursor, documentCount: 0,
                        postingCount: 0, postingBytes: 0, shardCount: 0,
                        rootDigest: emptyDigest
                    )
                    try database.execute(
                        """
                        INSERT INTO runtime_canonical_search_generations(
                            generation_id, projection_generation_id, coverage,
                            definition_digest, source_sequence, source_event_hash,
                            document_count, posting_count, posting_bytes,
                            shard_count, document_root_digest, status,
                            generation_certificate_digest, created_at_ms
                        ) VALUES (?, ?, 'aggregate_kind_only', ?, 0, ?, 0, 0, 0, 0, ?,
                                  'published', ?, ?)
                        """,
                        bindings: [
                            .text(searchGenerationID), .text(generationID),
                            .text(definition.authorityDigest), .text(cursor.eventHash),
                            .text(emptyDigest), .text(searchCertificate), .integer(nowMilliseconds),
                        ]
                    )
                    try database.execute(
                        """
                        INSERT INTO runtime_canonical_search_active_generation(
                            singleton_id, generation_id, generation_certificate_digest, activated_at_ms
                        ) VALUES (1, ?, ?, ?)
                        """,
                        bindings: [
                            .text(searchGenerationID), .text(searchCertificate),
                            .integer(nowMilliseconds),
                        ]
                    )
                    let searchScrubCertificate = Self.canonicalScrubCertificateDigest(
                        generationID: searchGenerationID, kind: "search",
                        projectionID: definition.id.rawValue,
                        generationCertificate: searchCertificate, observedCount: 0,
                        observedShardCount: 0,
                        observedPostingCount: 0, observedPostingBytes: 0,
                        rootDigest: emptyDigest,
                        completedAtMilliseconds: nowMilliseconds
                    )
                    try database.execute(
                        """
                        INSERT INTO runtime_canonical_scrub_certificates(
                            generation_id, generation_kind, projection_id,
                            generation_certificate_digest, observed_count,
                            observed_shard_count, observed_posting_count,
                            observed_posting_bytes, root_digest,
                            completed_at_ms, scrub_certificate_digest
                        ) VALUES (?, 'search', ?, ?, 0, 0, 0, 0, ?, ?, ?)
                        """,
                        bindings: [
                            .text(searchGenerationID), .text(definition.id.rawValue),
                            .text(searchCertificate), .text(emptyDigest),
                            .integer(nowMilliseconds), .text(searchScrubCertificate),
                        ]
                    )
                }
            }
            return true
        }
    }

    func nextCanonicalProjectionWork(
        registry: RuntimeCanonicalProjectionDefinitionRegistry,
        ownerID: String,
        nowMilliseconds: Int64,
        invalidationLimit: Int
    ) async throws -> RuntimeCanonicalProjectionBuildWork? {
        try Task.checkCancellation()
        return try await withDerivedImmediateTransaction { database in
            try CanonicalRuntimeProjectionSchemaPlan.requireIntegratedSchema(in: database)
            if try Self.retireOneObsoleteBlockedCanonicalProjectionBuild(
                registry: registry, ownerID: ownerID,
                nowMilliseconds: nowMilliseconds, database: database
            ) {
                return nil
            }
            guard let projectionID = try Self.nextCanonicalProjectionID(
                registry: registry, database: database
            ) else {
                return nil
            }
            let serviceTicket = try Self.issueCanonicalServiceTicket(database: database)
            guard let definition = registry.definitions[projectionID] else {
                throw RuntimeCanonicalProjectionPersistenceError.corruptInvalidation
            }
            let lease = try Self.claimCanonicalProjectionLease(
                projectionID: projectionID, ownerID: ownerID,
                nowMilliseconds: nowMilliseconds, database: database
            )
            var jobRows = try database.query(
                "SELECT * FROM runtime_canonical_projection_jobs WHERE projection_id = ? LIMIT 2",
                bindings: [.text(projectionID.rawValue)]
            )
            if let existing = jobRows.first,
               case let .text(existingGenerationID)? = existing.value(named: "generation_id") {
                let authority = try database.query(
                    "SELECT definition_digest, output_version FROM runtime_canonical_projection_generations WHERE generation_id = ? LIMIT 2",
                    bindings: [.text(existingGenerationID)]
                )
                guard authority.count == 1 else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
                if authority[0].value(named: "definition_digest") != .text(definition.authorityDigest)
                    || authority[0].value(named: "output_version") != .integer(Int64(definition.outputVersion)) {
                    try Self.discardObsoleteCanonicalProjectionBuild(
                        projectionID: projectionID, generationID: existingGenerationID,
                        lease: lease, nowMilliseconds: nowMilliseconds,
                        database: database
                    )
                    return nil
                }
            }
            if jobRows.isEmpty {
                let invalidations = try Self.authenticatedInvalidations(
                    projectionID: projectionID, limit: invalidationLimit, database: database
                )
                guard let target = invalidations.last?.sourceCursor else {
                    throw RuntimeCanonicalProjectionPersistenceError.sourceAdvanced
                }
                let targetCertificate = try RuntimeCanonicalReplayEngine
                    .verifiedReconstructionCertificate(at: target, database: database)
                let digest = RuntimeTransactionDigest.digest(invalidations.flatMap {
                    [$0.id, String($0.sourceCursor.sequence), $0.sourceCursor.eventID, $0.sourceCursor.eventHash]
                })
                let generationID = RuntimeTransactionDigest.digest([
                    "runtime.projection.generation.v1", projectionID.rawValue,
                    definition.authorityDigest, String(target.sequence),
                    target.eventID, target.eventHash, digest,
                ])
                let compatibleBase = try Self.compatibleCanonicalProjectionBase(
                    definition: definition, database: database
                )
                try database.execute(
                    """
                    INSERT INTO runtime_canonical_projection_generations(
                        generation_id, projection_id, definition_version, definition_digest,
                        output_version, source_sequence, source_event_id, source_event_hash,
                        source_chain_digest, first_invalidation_id, last_invalidation_id,
                        invalidation_digest, entry_count, shard_count, entry_root_digest,
                        privacy, local_only, status, generation_certificate_digest,
                        created_at_ms, sealed_at_ms
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, 0, ?, '', 1, 'building', NULL, ?, NULL)
                    """,
                    bindings: [
                        .text(generationID), .text(projectionID.rawValue),
                        .integer(Int64(definition.definitionVersion)), .text(definition.authorityDigest),
                        .integer(Int64(definition.outputVersion)), .integer(Int64(target.sequence)),
                        .text(target.eventID), .text(target.eventHash),
                        .text(targetCertificate.sourceChainDigest.hexadecimal),
                        .text(invalidations.first?.id ?? ""), .text(invalidations.last?.id ?? ""),
                        .text(digest),
                        .text(RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal),
                        .integer(nowMilliseconds),
                    ]
                )
                let phase = Self.initialCanonicalProjectionBuildPhase(base: compatibleBase)
                try database.execute(
                    """
                    INSERT INTO runtime_canonical_projection_jobs(
                        projection_id, generation_id, phase, blocked_reason_code,
                        base_generation_id, base_certificate_digest, base_root_digest,
                        base_entry_count, base_scrub_certificate_digest,
                        base_scrub_completed_at_ms, target_sequence, target_event_id,
                        target_event_hash, progress_sequence, progress_event_id, progress_event_hash,
                        progress_source_digest, after_aggregate_kind, after_aggregate_id,
                        shard_ordinal, rolling_root_digest, entry_count, sealed_entry_count,
                        privacy_standard_count, privacy_sensitive_count,
                        privacy_private_text_count, privacy_calendar_count, privacy_sync_count,
                        nonlocal_entry_count, search_document_count,
                        sealed_search_document_count, search_posting_count,
                        search_posting_bytes, first_invalidation_id, last_invalidation_id,
                        invalidation_digest, owner_id, fence_version, service_ticket, updated_at_ms
                    ) VALUES (?, ?, ?, NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0, NULL, NULL, ?, '', '', 0, ?,
                              0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    bindings: [
                        .text(projectionID.rawValue), .text(generationID), .text(phase.rawValue),
                        compatibleBase.map { .text($0.generationID) } ?? .null,
                        compatibleBase.map { .text($0.certificateDigest) } ?? .null,
                        compatibleBase.map { .text($0.rootDigest) } ?? .null,
                        compatibleBase.map { .integer(Int64($0.entryCount)) } ?? .null,
                        compatibleBase.map { .text($0.scrubCertificateDigest) } ?? .null,
                        compatibleBase.map { .integer($0.scrubCompletedAtMilliseconds) } ?? .null,
                        .integer(Int64(target.sequence)), .text(target.eventID),
                        .text(target.eventHash),
                        .text(RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal),
                        .text(RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal),
                        .text(invalidations.first?.id ?? ""), .text(invalidations.last?.id ?? ""),
                        .text(digest), .text(ownerID), .integer(Int64(lease.version)),
                        .integer(serviceTicket), .integer(nowMilliseconds),
                    ]
                )
                jobRows = try database.query(
                    "SELECT * FROM runtime_canonical_projection_jobs WHERE projection_id = ? LIMIT 2",
                    bindings: [.text(projectionID.rawValue)]
                )
            } else {
                try database.execute(
                    """
                    UPDATE runtime_canonical_projection_jobs
                    SET owner_id = ?, fence_version = ?, service_ticket = ?, updated_at_ms = ?
                    WHERE projection_id = ?
                    """,
                    bindings: [
                        .text(ownerID), .integer(Int64(lease.version)),
                        .integer(serviceTicket), .integer(nowMilliseconds),
                        .text(projectionID.rawValue),
                    ]
                )
                jobRows = try database.query(
                    "SELECT * FROM runtime_canonical_projection_jobs WHERE projection_id = ? LIMIT 2",
                    bindings: [.text(projectionID.rawValue)]
                )
            }
            guard jobRows.count == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            do {
                return try Self.decodeBuildWork(
                    jobRows[0], definition: definition, lease: lease,
                    operationNowMilliseconds: nowMilliseconds, database: database
                )
            } catch let error as RuntimeCanonicalProjectionPersistenceError
                where error == .invalidationAdvanced || error == .sourceAdvanced {
                guard case let .text(generationID)? = jobRows[0].value(named: "generation_id") else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
                try Self.scheduleCanonicalProjectionBuildCleanup(
                    projectionID: projectionID.rawValue, generationID: generationID,
                    ownerID: lease.ownerID, fenceVersion: Int64(lease.version),
                    reasonCode: error == .invalidationAdvanced
                        ? "build_invalidation_advanced" : "build_source_advanced",
                    nowMilliseconds: nowMilliseconds, database: database
                )
                return nil
            }
        }
    }

    static func issueCanonicalServiceTicket(
        database: isolated SQLiteDatabase
    ) throws -> Int64 {
        try database.execute(
            "INSERT OR IGNORE INTO runtime_canonical_scheduler_state VALUES (1, 1)"
        )
        let rows = try database.query(
            "SELECT next_service_ticket FROM runtime_canonical_scheduler_state WHERE singleton_id = 1 LIMIT 2"
        )
        guard rows.count == 1,
              case let .integer(ticket)? = rows[0].value(named: "next_service_ticket"),
              ticket > 0, ticket < Int64.max else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let changed = try database.execute(
            "UPDATE runtime_canonical_scheduler_state SET next_service_ticket = ? WHERE singleton_id = 1 AND next_service_ticket = ?",
            bindings: [.integer(ticket + 1), .integer(ticket)]
        )
        guard changed.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        return ticket
    }

    static func initialCanonicalProjectionBuildPhase(
        base: RuntimeCanonicalProjectionBaseBinding?
    ) -> RuntimeCanonicalProjectionBuildPhase {
        base == nil ? .replay : .clone
    }

    static func retireOneObsoleteBlockedCanonicalProjectionBuild(
        registry: RuntimeCanonicalProjectionDefinitionRegistry,
        ownerID: String,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws -> Bool {
        let rows = try database.query(
            """
            SELECT job.projection_id, job.generation_id,
                   generation.definition_digest, generation.output_version
            FROM runtime_canonical_projection_jobs AS job
            JOIN runtime_canonical_projection_generations AS generation
              ON generation.generation_id = job.generation_id
            WHERE job.phase = 'blocked'
            ORDER BY job.service_ticket, job.projection_id LIMIT 65
            """
        )
        guard rows.count <= 64 else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        for row in rows {
            guard case let .text(rawProjectionID)? = row.value(named: "projection_id"),
                  let projectionID = RuntimeCanonicalProjectionID(rawValue: rawProjectionID),
                  case let .text(generationID)? = row.value(named: "generation_id") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            guard let definition = registry.definitions[projectionID] else {
                throw RuntimeCanonicalProjectionPersistenceError.corruptInvalidation
            }
            guard row.value(named: "definition_digest") != .text(definition.authorityDigest)
                    || row.value(named: "output_version") != .integer(Int64(definition.outputVersion)) else {
                continue
            }
            let lease = try claimCanonicalProjectionLease(
                projectionID: projectionID, ownerID: ownerID,
                nowMilliseconds: nowMilliseconds, database: database
            )
            try discardObsoleteCanonicalProjectionBuild(
                projectionID: projectionID, generationID: generationID,
                lease: lease, nowMilliseconds: nowMilliseconds, database: database
            )
            return true
        }
        return false
    }

    static func nextCanonicalProjectionID(
        registry: RuntimeCanonicalProjectionDefinitionRegistry,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalProjectionID? {
        // New work is discovered by probing the finite, typed registry. This
        // keeps scheduler cost independent of invalidation-history size.
        for projectionID in registry.definitions.keys.sorted() {
            let pending = try database.query(
                """
                SELECT 1
                FROM runtime_commit_projection_invalidations AS invalidation
                LEFT JOIN runtime_canonical_projection_invalidation_acks AS ack
                  ON ack.projection_id = invalidation.projection_id
                 AND ack.invalidation_id = invalidation.invalidation_id
                WHERE invalidation.projection_id = ? AND ack.invalidation_id IS NULL
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_canonical_projection_jobs AS job
                      WHERE job.projection_id = invalidation.projection_id
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_canonical_build_cleanup_jobs AS cleanup
                      WHERE cleanup.projection_id = invalidation.projection_id
                  )
                LIMIT 1
                """,
                bindings: [.text(projectionID.rawValue)]
            )
            if pending.isEmpty == false { return projectionID }
        }
        let first = try database.query(
            """
            SELECT projection_id FROM runtime_canonical_projection_jobs
            WHERE phase != 'blocked'
            ORDER BY service_ticket, projection_id LIMIT 1
            """
        )
        guard case let .text(raw)? = first.first?.value(named: "projection_id") else {
            return nil
        }
        guard let typed = RuntimeCanonicalProjectionID(rawValue: raw) else {
            throw RuntimeCanonicalProjectionPersistenceError.corruptInvalidation
        }
        return typed
    }

    static func hasCompatibleCanonicalProjectionBase(
        definition: RuntimeCanonicalProjectionDefinition,
        database: isolated SQLiteDatabase
    ) throws -> Bool {
        try compatibleCanonicalProjectionBase(
            definition: definition, database: database
        ) != nil
    }

    static func compatibleCanonicalProjectionBase(
        definition: RuntimeCanonicalProjectionDefinition,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalProjectionBaseBinding? {
        let rows = try database.query(
            """
            SELECT generation.generation_id, generation.generation_certificate_digest,
                   generation.entry_root_digest, generation.entry_count,
                   generation.shard_count,
                   scrub.observed_posting_count, scrub.observed_posting_bytes,
                   scrub.observed_shard_count,
                   scrub.completed_at_ms, scrub.scrub_certificate_digest
            FROM runtime_canonical_projection_active_generations AS active
            JOIN runtime_canonical_projection_generations AS generation
              ON generation.generation_id = active.generation_id
             AND generation.generation_certificate_digest = active.generation_certificate_digest
            JOIN runtime_canonical_scrub_certificates AS scrub
              ON scrub.generation_id = generation.generation_id
             AND scrub.generation_kind = 'projection'
             AND scrub.projection_id = generation.projection_id
             AND scrub.generation_certificate_digest = generation.generation_certificate_digest
             AND scrub.observed_count = generation.entry_count
             AND scrub.observed_shard_count = generation.shard_count
             AND scrub.root_digest = generation.entry_root_digest
            WHERE active.projection_id = ? AND generation.status = 'published'
              AND generation.definition_digest = ? AND generation.output_version = ?
              AND NOT EXISTS (
                  SELECT 1 FROM runtime_canonical_projection_quarantine AS quarantine
                  WHERE quarantine.generation_id = generation.generation_id
                    AND quarantine.reason_code = 'scrub_authority_mismatch'
              )
              AND NOT EXISTS (
                  SELECT 1 FROM runtime_canonical_repair_requirements AS repair
                  WHERE repair.projection_id = generation.projection_id
                    AND repair.state = 'required'
                    AND (repair.generation_id IS NULL
                         OR repair.generation_id = generation.generation_id)
              ) LIMIT 2
            """,
            bindings: [
                .text(definition.id.rawValue), .text(definition.authorityDigest),
                .integer(Int64(definition.outputVersion)),
            ]
        )
        guard rows.count <= 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        guard let row = rows.first else { return nil }
        guard case let .text(generationID)? = row.value(named: "generation_id"),
              case let .text(certificate)? = row.value(named: "generation_certificate_digest"),
              case let .text(root)? = row.value(named: "entry_root_digest"),
              case let .integer(count)? = row.value(named: "entry_count"), count >= 0,
              case let .integer(shardCount)? = row.value(named: "shard_count"), shardCount >= 0,
              row.value(named: "observed_shard_count") == .integer(shardCount),
              row.value(named: "observed_posting_count") == .integer(0),
              row.value(named: "observed_posting_bytes") == .integer(0),
              case let .integer(completedAt)? = row.value(named: "completed_at_ms"), completedAt >= 0,
              case let .text(scrubCertificate)? = row.value(named: "scrub_certificate_digest"),
              scrubCertificate == canonicalScrubCertificateDigest(
                  generationID: generationID, kind: "projection",
                  projectionID: definition.id.rawValue,
                  generationCertificate: certificate, observedCount: Int(count),
                  observedShardCount: Int(shardCount),
                  observedPostingCount: 0, observedPostingBytes: 0,
                  rootDigest: root, completedAtMilliseconds: completedAt
              ) else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        return RuntimeCanonicalProjectionBaseBinding(
            generationID: generationID, certificateDigest: certificate,
            rootDigest: root, entryCount: Int(count),
            scrubCertificateDigest: scrubCertificate,
            scrubCompletedAtMilliseconds: completedAt
        )
    }

    static func claimCanonicalProjectionLease(
        projectionID: RuntimeCanonicalProjectionID,
        ownerID: String,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalProjectionLease {
        let expires = nowMilliseconds.addingReportingOverflow(30_000)
        guard expires.overflow == false else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        let result = try database.execute(
            """
            INSERT INTO runtime_canonical_projection_leases(projection_id, owner_id, lease_version, expires_at_ms)
            VALUES (?, ?, 1, ?)
            ON CONFLICT(projection_id) DO UPDATE SET
                owner_id = excluded.owner_id,
                lease_version = runtime_canonical_projection_leases.lease_version + 1,
                expires_at_ms = excluded.expires_at_ms
            WHERE runtime_canonical_projection_leases.expires_at_ms <= ?
               OR runtime_canonical_projection_leases.owner_id = excluded.owner_id
            """,
            bindings: [
                .text(projectionID.rawValue), .text(ownerID), .integer(expires.partialValue),
                .integer(nowMilliseconds),
            ]
        )
        guard result.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        let rows = try database.query(
            "SELECT lease_version FROM runtime_canonical_projection_leases WHERE projection_id = ? AND owner_id = ? LIMIT 2",
            bindings: [.text(projectionID.rawValue), .text(ownerID)]
        )
        guard rows.count == 1,
              case let .integer(version)? = rows[0].value(named: "lease_version"), version > 0 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        return RuntimeCanonicalProjectionLease(
            projectionID: projectionID, ownerID: ownerID, version: UInt64(version),
            expiresAtMilliseconds: expires.partialValue
        )
    }

    private static func discardObsoleteCanonicalProjectionBuild(
        projectionID: RuntimeCanonicalProjectionID,
        generationID: String,
        lease: RuntimeCanonicalProjectionLease,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        try scheduleCanonicalProjectionBuildCleanup(
            projectionID: projectionID.rawValue, generationID: generationID,
            ownerID: lease.ownerID, fenceVersion: Int64(lease.version),
            reasonCode: "obsolete_projection_definition",
            nowMilliseconds: nowMilliseconds, database: database
        )
    }

    private static func decodeBuildWork(
        _ row: SQLiteRow,
        definition: RuntimeCanonicalProjectionDefinition,
        lease: RuntimeCanonicalProjectionLease,
        operationNowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalProjectionBuildWork {
        guard case let .text(generationID)? = row.value(named: "generation_id"),
              case let .text(phaseRaw)? = row.value(named: "phase"),
              let phase = RuntimeCanonicalProjectionBuildPhase(rawValue: phaseRaw),
              case let .integer(targetSequence)? = row.value(named: "target_sequence"), targetSequence > 0,
              case let .text(targetEventID)? = row.value(named: "target_event_id"),
              case let .text(targetEventHash)? = row.value(named: "target_event_hash"),
              case let .integer(progressSequence)? = row.value(named: "progress_sequence"), progressSequence >= 0,
              case let .text(progressSourceDigest)? = row.value(named: "progress_source_digest"),
              case let .text(afterKind)? = row.value(named: "after_aggregate_kind"),
              case let .text(afterID)? = row.value(named: "after_aggregate_id"),
              case let .integer(shardOrdinal)? = row.value(named: "shard_ordinal"), shardOrdinal >= 0,
              case let .text(root)? = row.value(named: "rolling_root_digest"),
              case let .integer(entryCount)? = row.value(named: "entry_count"), entryCount >= 0,
              case let .integer(sealedEntryCount)? = row.value(named: "sealed_entry_count"), sealedEntryCount >= 0,
              case let .integer(standardCount)? = row.value(named: "privacy_standard_count"), standardCount >= 0,
              case let .integer(sensitiveCount)? = row.value(named: "privacy_sensitive_count"), sensitiveCount >= 0,
              case let .integer(privateCount)? = row.value(named: "privacy_private_text_count"), privateCount >= 0,
              case let .integer(calendarCount)? = row.value(named: "privacy_calendar_count"), calendarCount >= 0,
              case let .integer(syncCount)? = row.value(named: "privacy_sync_count"), syncCount >= 0,
              case let .integer(nonlocalCount)? = row.value(named: "nonlocal_entry_count"), nonlocalCount >= 0,
              case let .integer(searchDocumentCount)? = row.value(named: "search_document_count"), searchDocumentCount >= 0,
              case let .integer(sealedSearchCount)? = row.value(named: "sealed_search_document_count"), sealedSearchCount >= 0,
              case let .integer(searchPostingCount)? = row.value(named: "search_posting_count"), searchPostingCount >= 0,
              case let .integer(searchPostingBytes)? = row.value(named: "search_posting_bytes"), searchPostingBytes >= 0,
              case let .text(firstID)? = row.value(named: "first_invalidation_id"),
              case let .text(lastID)? = row.value(named: "last_invalidation_id"),
              case let .text(invalidationDigest)? = row.value(named: "invalidation_digest") else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let target = RuntimeCanonicalReplayCursor(
            sequence: UInt64(targetSequence), eventID: targetEventID, eventHash: targetEventHash
        )
        let progress: RuntimeCanonicalReplayCursor?
        if progressSequence == 0 { progress = nil }
        else if case let .text(eventID)? = row.value(named: "progress_event_id"),
                case let .text(eventHash)? = row.value(named: "progress_event_hash") {
            progress = RuntimeCanonicalReplayCursor(
                sequence: UInt64(progressSequence), eventID: eventID, eventHash: eventHash
            )
        } else { throw RuntimeCanonicalProjectionPersistenceError.generationMismatch }
        let invalidations = try authenticatedInvalidations(
            projectionID: definition.id,
            limit: RuntimeCanonicalProjectionWorker.maximumInvalidationBatch,
            database: database
        )
        guard target.isWellFormed,
              progress?.isWellFormed != false,
              invalidations.first?.id == firstID,
              invalidations.contains(where: { $0.id == lastID }) else {
            throw RuntimeCanonicalProjectionPersistenceError.invalidationAdvanced
        }
        let throughLast = Array(invalidations.prefix(through: invalidations.firstIndex(where: { $0.id == lastID })!))
        let observedDigest = RuntimeTransactionDigest.digest(throughLast.flatMap {
            [$0.id, String($0.sourceCursor.sequence), $0.sourceCursor.eventID, $0.sourceCursor.eventHash]
        })
        guard observedDigest == invalidationDigest else {
            throw RuntimeCanonicalProjectionPersistenceError.invalidationAdvanced
        }
        let blockedReason: String?
        if case let .text(value)? = row.value(named: "blocked_reason_code") {
            blockedReason = value
        } else { blockedReason = nil }
        func optionalText(_ name: String) throws -> String? {
            switch row.value(named: name) {
            case .text(let value)?: return value
            case .null?, nil: return nil
            default: throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
        }
        let baseGenerationID = try optionalText("base_generation_id")
        let baseCertificate = try optionalText("base_certificate_digest")
        let baseRoot = try optionalText("base_root_digest")
        let baseScrubCertificate = try optionalText("base_scrub_certificate_digest")
        let baseCount: Int?
        if case let .integer(value)? = row.value(named: "base_entry_count"), value >= 0 {
            baseCount = Int(value)
        } else if row.value(named: "base_entry_count") == .null { baseCount = nil }
        else { throw RuntimeCanonicalProjectionPersistenceError.generationMismatch }
        let baseScrubCompletedAt: Int64?
        if case let .integer(value)? = row.value(named: "base_scrub_completed_at_ms"), value >= 0 {
            baseScrubCompletedAt = value
        } else if row.value(named: "base_scrub_completed_at_ms") == .null {
            baseScrubCompletedAt = nil
        } else { throw RuntimeCanonicalProjectionPersistenceError.generationMismatch }
        guard (baseGenerationID == nil) == (baseCertificate == nil),
              (baseGenerationID == nil) == (baseRoot == nil),
              (baseGenerationID == nil) == (baseCount == nil),
              (baseGenerationID == nil) == (baseScrubCertificate == nil),
              (baseGenerationID == nil) == (baseScrubCompletedAt == nil) else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let generationRows = try database.query(
            "SELECT source_chain_digest FROM runtime_canonical_projection_generations WHERE generation_id = ? AND definition_digest = ? AND output_version = ? LIMIT 2",
            bindings: [
                .text(generationID), .text(definition.authorityDigest),
                .integer(Int64(definition.outputVersion)),
            ]
        )
        guard generationRows.count == 1,
              case let .text(sourceDigest)? = generationRows[0]
                .value(named: "source_chain_digest") else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        return RuntimeCanonicalProjectionBuildWork(
            projectionID: definition.id, generationID: generationID, definition: definition,
            phase: phase, targetCursor: target, progressCursor: progress,
            sourceChainDigest: sourceDigest, progressSourceDigest: progressSourceDigest,
            afterAggregateKind: afterKind,
            afterAggregateID: afterID, shardOrdinal: Int(shardOrdinal),
            rollingRootDigest: root, invalidationIDs: throughLast.map(\.id),
            invalidationDigest: invalidationDigest, lease: lease,
            operationNowMilliseconds: operationNowMilliseconds,
            blockedReasonCode: blockedReason,
            baseGenerationID: baseGenerationID,
            baseCertificateDigest: baseCertificate,
            baseRootDigest: baseRoot, baseEntryCount: baseCount,
            baseScrubCertificateDigest: baseScrubCertificate,
            baseScrubCompletedAtMilliseconds: baseScrubCompletedAt,
            entryCount: Int(entryCount), sealedEntryCount: Int(sealedEntryCount),
            privacyCounts: [
                .standard: Int(standardCount), .sensitive: Int(sensitiveCount),
                .privateUserText: Int(privateCount), .calendarDerived: Int(calendarCount),
                .syncMetadata: Int(syncCount),
            ],
            nonlocalEntryCount: Int(nonlocalCount),
            searchDocumentCount: Int(searchDocumentCount),
            sealedSearchDocumentCount: Int(sealedSearchCount),
            searchPostingCount: Int(searchPostingCount),
            searchPostingBytes: Int(searchPostingBytes)
        )
    }

    static func authenticatedInvalidations(
        projectionID: RuntimeCanonicalProjectionID,
        limit: Int,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeCanonicalProjectionInvalidation] {
        let rows = try database.query(
            RuntimeCanonicalProjectionBuildSQL.pendingInvalidations,
            bindings: [.text(projectionID.rawValue), .integer(Int64(max(1, min(limit, 64))))],
            maximumDecodedBytes: max(1, min(limit, 64)) * 16_384
        )
        return try rows.map { row in
            guard case let .text(id)? = row.value(named: "invalidation_id"),
                  row.value(named: "invalidation_version") == .integer(1),
                  case let .integer(sequence)? = row.value(named: "terminal_event_sequence"), sequence > 0,
                  case let .text(eventID)? = row.value(named: "event_id"),
                  case let .text(eventHash)? = row.value(named: "event_hash"),
                  case let .text(typeRaw)? = row.value(named: "type_id"),
                  let eventType = RuntimeSemanticEventTypeID(rawValue: typeRaw),
                  RuntimeCanonicalProjectionRegistry.projectionIDs(for: eventType).contains(projectionID),
                  case let .blob(payload)? = row.value(named: "payload"),
                  case let .text(payloadChecksum)? = row.value(named: "payload_checksum"),
                  LocalRuntimeStorageChecksum.sha256Hex(for: payload) == payloadChecksum,
                  case let .text(receiptIDRaw)? = row.value(named: "receipt_id"),
                  let receiptID = RuntimeReceiptID(rawValue: receiptIDRaw),
                  case let .text(preparationID)? = row.value(named: "preparation_id"),
                  RuntimePreparationID(rawValue: preparationID) != nil,
                  case let .text(commandID)? = row.value(named: "command_id"),
                  RuntimeCommandID(rawValue: commandID) != nil,
                  row.value(named: "receipt_version") == .integer(Int64(runtimeCommitAnchorVersion)),
                  case let .integer(createdAt)? = row.value(named: "created_at_ms"),
                  createdAt >= 0,
                  row.value(named: "core_version") == .integer(Int64(runtimeCommittedReceiptCoreVersion)),
                  case let .text(coreDigest)? = row.value(named: "core_digest"),
                  RuntimeStoreManifestCodec.isSHA256Hex(coreDigest),
                  row.value(named: "core_created_at_ms") == .integer(createdAt),
                  row.value(named: "artifact_digest") == .text(payloadChecksum),
                  row.value(named: "final_result_version") == .integer(
                      Int64(canonicalIdempotencyFinalResultVersion)
                  ),
                  case let .text(finalChecksum)? = row.value(named: "final_result_checksum"),
                  RuntimeStoreManifestCodec.isSHA256Hex(finalChecksum) else {
                throw RuntimeCanonicalProjectionPersistenceError.corruptInvalidation
            }
            let lineage = try RuntimeCanonicalProjectionBuildCodec.decodeCanonical(
                RuntimeAuthorityLineageReference.self, bytes: payload
            )
            var receiptBudget = RuntimeReceiptDecodedByteBudget(
                maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
            )
            let core: RuntimeCommittedReceiptCore
            let eventEvidence: RuntimeVerifiedExactSemanticEventEvidence
            do {
                core = try RuntimeCommittedReceiptAuthority.loadCore(
                    receiptID: receiptID,
                    budget: &receiptBudget,
                    database: database
                )
                eventEvidence = try CanonicalRuntimeSemanticEventStore
                    .readVerifiedExactInTransaction(
                        sequence: UInt64(sequence),
                        budget: &receiptBudget,
                        database: database
                    )
                let finalized = try receiptBudget.query(
                    """
                    SELECT final_result_version, final_result_payload,
                           final_result_checksum, finalized_at_ms
                    FROM runtime_command_idempotency WHERE command_id = ? LIMIT 2
                    """,
                    bindings: [.text(commandID)],
                    database: database
                )
                guard finalized.count == 1,
                      finalized[0].value(named: "final_result_version") == .integer(
                          Int64(canonicalIdempotencyFinalResultVersion)
                      ),
                      case let .blob(finalBytes)? = finalized[0]
                        .value(named: "final_result_payload"),
                      finalBytes.count <= RuntimeCommittedReceiptReadBounds
                        .maximumFinalizedResultPayloadBytes,
                      case let .text(storedFinalChecksum)? = finalized[0]
                        .value(named: "final_result_checksum"),
                      storedFinalChecksum == finalChecksum,
                      case let .integer(finalizedAt)? = finalized[0]
                        .value(named: "finalized_at_ms"),
                      finalizedAt >= 0 else {
                    throw RuntimeCommittedReceiptAuthorityError.corruptAuthority
                }
                try RuntimeAtomicCommitCoding.requireFinalizedOutcome(
                    finalBytes,
                    storedChecksum: storedFinalChecksum,
                    references: core
                )
            } catch is CancellationError {
                throw CancellationError()
            } catch RuntimeCommittedReceiptQueryError.firstRowExceedsBound {
                throw RuntimeCanonicalProjectionPersistenceError.unitBudgetExceeded
            } catch is SQLiteQueryBudgetExceeded {
                throw RuntimeCanonicalProjectionPersistenceError.unitBudgetExceeded
            } catch RuntimeCommittedReceiptAuthorityError.sourceBlocked(_) {
                throw RuntimeCanonicalProjectionSourceError.unsupportedSource
            } catch {
                throw RuntimeCanonicalProjectionPersistenceError.corruptInvalidation
            }
            let cursor = RuntimeCanonicalReplayCursor(
                sequence: UInt64(sequence), eventID: eventID, eventHash: eventHash
            )
            let expectedArtifact = RuntimeCommittedReceiptArtifactLink(
                kind: .projectionInvalidation,
                stableID: id,
                digest: payloadChecksum
            )
            guard id == "invalidation.\(sequence).\(projectionID.rawValue)", cursor.isWellFormed,
                  lineage.eventID.rawValue == eventID, lineage.eventSequence == UInt64(sequence),
                  lineage.eventHash == eventHash,
                  receiptID.rawValue.isEmpty == false,
                  preparationID.isEmpty == false,
                  commandID.isEmpty == false,
                  createdAt >= 0,
                  core.facts.receiptID == receiptID,
                  core.facts.preparationID.rawValue == preparationID,
                  core.facts.commandID.rawValue == commandID,
                  core.facts.lineage == lineage,
                  core.facts.artifacts.filter({ $0 == expectedArtifact }).count == 1,
                  eventEvidence.terminal.lineage.eventID.rawValue == eventID,
                  eventEvidence.terminal.lineage.eventHash.hexadecimal == eventHash,
                  eventEvidence.terminal.lineage.commandID.rawValue == commandID,
                  eventEvidence.terminal.event.typeID == eventType else {
                throw RuntimeCanonicalProjectionPersistenceError.corruptInvalidation
            }
            return RuntimeCanonicalProjectionInvalidation(
                id: id, projectionID: projectionID, sourceCursor: cursor, lineage: lineage
            )
        }
    }
}
