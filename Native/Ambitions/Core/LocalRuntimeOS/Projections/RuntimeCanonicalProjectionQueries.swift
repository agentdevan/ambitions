import AmbitionsRuntimeSQLite
import Foundation

struct RuntimeCanonicalSearchAuthority: Sendable {
    let projection: RuntimeCanonicalGenerationAuthority
    let generationID: String
    let coverage: RuntimeCanonicalSearchCoverage
    let certificateDigest: String
    let fingerprint: String
}

extension CanonicalRuntimeStore {
    func canonicalProjectionEntryPage(
        definition: RuntimeCanonicalProjectionDefinition,
        access: RuntimeCanonicalProjectionAccessPolicy,
        after cursor: RuntimeCanonicalProjectionEntryCursor?,
        limit: Int = 50
    ) async throws -> RuntimeCanonicalProjectionEntryPage {
        try Task.checkCancellation()
        guard access.allowedPrivacy.isEmpty == false,
              access.allowedPrivacy.isSubset(of: Set(definition.allowedPrivacyClasses)) else {
            throw RuntimeCanonicalSearchError.unauthorizedPrivacyFilter
        }
        return try await withCanonicalReadTransaction { database in
            let authority = try Self.requireCanonicalProjectionAuthority(
                definition: definition, requireNoPendingInvalidations: false,
                requireAtVerifiedHighWater: false, database: database
            )
            if let cursor {
                guard cursor.generationID == authority.generationID,
                      cursor.certificateDigest == authority.certificateDigest,
                      cursor.accessPolicyDigest == access.digest else {
                    throw RuntimeCanonicalSearchError.cursorBindingMismatch
                }
            }
            let truth = try Self.canonicalProjectionReadTruth(
                authority: authority, definition: definition, database: database
            )
            guard truth.authority != nil else {
                throw RuntimeCanonicalSearchError.projectionNotAvailable(truth.state)
            }
            let page = try Self.readCanonicalProjectionEntryPage(
                authority: authority, access: access, after: cursor,
                limit: limit, database: database
            )
            return RuntimeCanonicalProjectionEntryPage(
                authority: authority, entries: page.entries,
                nextCursor: page.nextCursor, truth: truth
            )
        }
    }

    static func readCanonicalProjectionEntryPage(
        authority: RuntimeCanonicalGenerationAuthority,
        access: RuntimeCanonicalProjectionAccessPolicy,
        after cursor: RuntimeCanonicalProjectionEntryCursor?,
        limit: Int,
        database: isolated SQLiteDatabase
    ) throws -> (
        entries: [RuntimeCanonicalProjectionEntry],
        nextCursor: RuntimeCanonicalProjectionEntryCursor?
    ) {
            if let cursor {
                guard cursor.generationID == authority.generationID,
                      cursor.certificateDigest == authority.certificateDigest,
                      cursor.accessPolicyDigest == access.digest else {
                    throw RuntimeCanonicalSearchError.cursorBindingMismatch
                }
            }
            let privacy = access.allowedPrivacy.map(\.rawValue).sorted()
            guard privacy.isEmpty == false else {
                throw RuntimeCanonicalSearchError.unauthorizedPrivacyFilter
            }
            let placeholders = Array(repeating: "?", count: privacy.count).joined(separator: ",")
            let delivery = max(1, min(limit, 50))
            var predicateBindings: [SQLiteBinding] = [.text(authority.generationID)]
            predicateBindings += privacy.map(SQLiteBinding.text)
            predicateBindings += [
                .integer(access.requiresLocalOnly ? 1 : 0),
                .text(cursor?.aggregateKind.rawValue ?? ""),
                .text(cursor?.aggregateKind.rawValue ?? ""),
                .text(cursor?.aggregateID.rawValue ?? ""),
            ]
            let sizeRows = try database.query(
                """
                SELECT length(canonical_state_bytes) AS byte_count
                FROM runtime_canonical_projection_entries
                WHERE generation_id = ? AND privacy IN (\(placeholders))
                  AND (? = 0 OR local_only = 1)
                  AND (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id > ?))
                ORDER BY aggregate_kind, aggregate_id LIMIT ?
                """,
                bindings: predicateBindings + [.integer(Int64(delivery + 1))]
            )
            let readCount = min(
                delivery,
                try Self.canonicalBoundedCount(
                    sizeRows: sizeRows,
                    bounds: RuntimeCanonicalProjectionUnitBounds(
                        maximumRows: delivery,
                        maximumBytes: RuntimeCanonicalProjectionWorker.maximumBytesPerUnit
                    ),
                    perRowOverhead: 4_096
                )
            )
            let rows = try database.query(
                """
                SELECT aggregate_kind, aggregate_id, revision, lifecycle,
                       canonical_state_bytes, canonical_state_digest, privacy, local_only,
                       source_sequence, source_event_id, source_event_hash, entry_digest
                FROM runtime_canonical_projection_entries
                WHERE generation_id = ? AND privacy IN (\(placeholders))
                  AND (? = 0 OR local_only = 1)
                  AND (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id > ?))
                ORDER BY aggregate_kind, aggregate_id LIMIT ?
                """,
                bindings: predicateBindings + [.integer(Int64(readCount))],
                maximumDecodedBytes: RuntimeCanonicalProjectionWorker.maximumBytesPerUnit
            )
            let entries = try rows.map(Self.decodeCanonicalProjectionEntry)
            let next: RuntimeCanonicalProjectionEntryCursor?
            if sizeRows.count > rows.count, let last = entries.last {
                next = RuntimeCanonicalProjectionEntryCursor(
                    generationID: authority.generationID,
                    certificateDigest: authority.certificateDigest,
                    accessPolicyDigest: access.digest,
                    aggregateKind: last.aggregate.kind, aggregateID: last.aggregate.id
                )
            } else { next = nil }
            return (entries, next)
    }

    func canonicalProjectionEntry(
        _ aggregate: RuntimeSemanticAggregate,
        definition: RuntimeCanonicalProjectionDefinition,
        access: RuntimeCanonicalProjectionAccessPolicy
    ) async throws -> RuntimeCanonicalProjectionEntryRead {
        guard access.allowedPrivacy.isEmpty == false,
              access.allowedPrivacy.isSubset(of: Set(definition.allowedPrivacyClasses)) else {
            throw RuntimeCanonicalSearchError.unauthorizedPrivacyFilter
        }
        return try await withCanonicalReadTransaction { database in
            let authority = try Self.requireCanonicalProjectionAuthority(
                definition: definition, requireNoPendingInvalidations: false,
                requireAtVerifiedHighWater: false, database: database
            )
            let truth = try Self.canonicalProjectionReadTruth(
                authority: authority, definition: definition, database: database
            )
            guard truth.authority != nil else {
                throw RuntimeCanonicalSearchError.projectionNotAvailable(truth.state)
            }
            let rows = try database.query(
                """
                SELECT aggregate_kind, aggregate_id, revision, lifecycle,
                       canonical_state_bytes, canonical_state_digest, privacy, local_only,
                       source_sequence, source_event_id, source_event_hash, entry_digest
                FROM runtime_canonical_projection_entries
                WHERE generation_id = ? AND aggregate_kind = ? AND aggregate_id = ? LIMIT 2
                """,
                bindings: [
                    .text(authority.generationID), .text(aggregate.kind.rawValue),
                    .text(aggregate.id.rawValue),
                ], maximumDecodedBytes: 1_100_000
            )
            guard let row = rows.first else {
                return RuntimeCanonicalProjectionEntryRead(entry: nil, truth: truth)
            }
            guard rows.count == 1 else { throw RuntimeCanonicalSearchError.corruptIndex }
            let entry = try Self.decodeCanonicalProjectionEntry(row)
            guard access.allowedPrivacy.contains(entry.privacy),
                  access.requiresLocalOnly == false || entry.localOnly else {
                throw RuntimeCanonicalSearchError.unauthorizedPrivacyFilter
            }
            return RuntimeCanonicalProjectionEntryRead(entry: entry, truth: truth)
        }
    }

    static func requireCanonicalProjectionEntryActionAuthority(
        _ token: RuntimeCanonicalProjectionEntryActionToken,
        definition: RuntimeCanonicalProjectionDefinition,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalProjectionEntry {
        let authority = try requireCanonicalProjectionAuthority(
            definition: definition, requireNoPendingInvalidations: true,
            requireAtVerifiedHighWater: true, database: database
        )
        guard token.accessPolicy.allowedPrivacy.isEmpty == false,
              token.accessPolicy.allowedPrivacy
                .isSubset(of: Set(definition.allowedPrivacyClasses)),
              authority.generationID == token.generationID,
              authority.certificateDigest == token.certificateDigest,
              authority.fingerprint == token.authorityFingerprint else {
            throw RuntimeCanonicalSearchError.actionSourceChanged
        }
        let rows = try database.query(
            """
            SELECT aggregate_kind, aggregate_id, revision, lifecycle,
                   canonical_state_bytes, canonical_state_digest, privacy, local_only,
                   source_sequence, source_event_id, source_event_hash, entry_digest
            FROM runtime_canonical_projection_entries
            WHERE generation_id = ? AND aggregate_kind = ? AND aggregate_id = ? LIMIT 2
            """,
            bindings: [
                .text(token.generationID), .text(token.aggregate.kind.rawValue),
                .text(token.aggregate.id.rawValue),
            ], maximumDecodedBytes: 1_100_000
        )
        guard rows.count == 1,
              case let .text(storedDigest)? = rows[0].value(named: "entry_digest") else {
            throw RuntimeCanonicalSearchError.actionSourceChanged
        }
        let entry = try decodeCanonicalProjectionEntry(rows[0])
        guard entry.aggregate == token.aggregate, entry.revision == token.revision,
              entry.sourceCursor == token.sourceCursor, storedDigest == token.entryDigest,
              token.accessPolicy.allowedPrivacy.contains(entry.privacy),
              token.accessPolicy.requiresLocalOnly == false || entry.localOnly else {
            throw RuntimeCanonicalSearchError.actionSourceChanged
        }
        return entry
    }

    func canonicalProjectionTruth(
        for definition: RuntimeCanonicalProjectionDefinition
    ) async -> RuntimeCanonicalProjectionTruth {
        do {
            return try await withCanonicalReadTransaction { database in
                try CanonicalRuntimeProjectionSchemaPlan.requireIntegratedSchema(in: database)
                if let blocked = try Self.historicalPrivacyBlock(database: database) {
                    return RuntimeCanonicalProjectionTruth(
                        state: .blocked, authority: nil,
                        expectedDefinitionVersion: definition.definitionVersion,
                        sourceCursor: nil, digest: nil, repairEligible: false,
                        reasonCode: "historical_privacy_missing:\(blocked.eventID):v\(blocked.payloadVersion)"
                    )
                }
                let active = try database.query(
                    "SELECT 1 FROM runtime_canonical_projection_active_generations WHERE projection_id = ? LIMIT 2",
                    bindings: [.text(definition.id.rawValue)]
                )
                if active.isEmpty {
                    if let jobTruth = try Self.canonicalProjectionJobTruth(
                        projectionID: definition.id,
                        expectedDefinitionVersion: definition.definitionVersion,
                        database: database
                    ) {
                        return jobTruth
                    }
                    return RuntimeCanonicalProjectionTruth(
                        state: .missing, authority: nil,
                        expectedDefinitionVersion: definition.definitionVersion,
                        sourceCursor: nil, digest: nil, repairEligible: false,
                        reasonCode: "generation_missing"
                    )
                }
                let authority = try Self.requireCanonicalProjectionAuthority(
                    definition: definition, requireNoPendingInvalidations: false,
                    requireAtVerifiedHighWater: false, database: database
                )
                return try Self.canonicalProjectionReadTruth(
                    authority: authority, definition: definition, database: database
                )
            }
        } catch let error as RuntimeCanonicalReplayError {
            let state: RuntimeCanonicalProjectionHealth
            if case .migrationRequired = error { state = .unavailable } else { state = .corrupt }
            return RuntimeCanonicalProjectionTruth(
                state: state, authority: nil,
                expectedDefinitionVersion: definition.definitionVersion,
                sourceCursor: nil, digest: nil, repairEligible: false,
                reasonCode: state == .unavailable ? "schema_v5_unavailable" : "authority_corrupt"
            )
        } catch let error as SQLiteError {
            let corruption = Self.isCanonicalSQLiteCorruption(error)
            return RuntimeCanonicalProjectionTruth(
                state: corruption ? .corrupt : .unavailable, authority: nil,
                expectedDefinitionVersion: definition.definitionVersion,
                sourceCursor: nil, digest: nil, repairEligible: false,
                reasonCode: corruption ? "sqlite_authority_corrupt" : "store_temporarily_unavailable"
            )
        } catch is CancellationError {
            return RuntimeCanonicalProjectionTruth(
                state: .unavailable, authority: nil,
                expectedDefinitionVersion: definition.definitionVersion,
                sourceCursor: nil, digest: nil, repairEligible: false,
                reasonCode: "query_cancelled"
            )
        } catch {
            return RuntimeCanonicalProjectionTruth(
                state: .corrupt, authority: nil,
                expectedDefinitionVersion: definition.definitionVersion,
                sourceCursor: nil, digest: nil, repairEligible: false,
                reasonCode: "authority_corrupt"
            )
        }
    }

    static func canonicalProjectionJobTruth(
        projectionID: RuntimeCanonicalProjectionID,
        expectedDefinitionVersion: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalProjectionTruth? {
        let jobs = try database.query(
            "SELECT phase, blocked_reason_code FROM runtime_canonical_projection_jobs WHERE projection_id = ? LIMIT 2",
            bindings: [.text(projectionID.rawValue)]
        )
        guard let row = jobs.first else { return nil }
        guard jobs.count == 1, case let .text(phase)? = row.value(named: "phase") else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let blocked = phase == RuntimeCanonicalProjectionBuildPhase.blocked.rawValue
        let reason: String?
        if case let .text(value)? = row.value(named: "blocked_reason_code") {
            reason = value
        } else { reason = nil }
        guard blocked == (reason != nil) else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        return RuntimeCanonicalProjectionTruth(
            state: blocked ? .blocked : .rebuilding, authority: nil,
            expectedDefinitionVersion: expectedDefinitionVersion,
            sourceCursor: nil, digest: nil, repairEligible: false,
            reasonCode: blocked ? reason : "generation_job_pending"
        )
    }

    static func canonicalProjectionReadTruth(
        authority: RuntimeCanonicalGenerationAuthority,
        definition: RuntimeCanonicalProjectionDefinition,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalProjectionTruth {
        let repair = try database.query(
            """
            SELECT reason_code FROM runtime_canonical_repair_requirements
            WHERE projection_id = ? AND state = 'required'
              AND (generation_id IS NULL OR generation_id = ?)
            ORDER BY observed_at_ms, requirement_id LIMIT 2
            """,
            bindings: [.text(definition.id.rawValue), .text(authority.generationID)]
        )
        if let row = repair.first {
            guard case let .text(reason)? = row.value(named: "reason_code") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            return RuntimeCanonicalProjectionTruth(
                state: .corrupt, authority: nil,
                expectedDefinitionVersion: definition.definitionVersion,
                sourceCursor: nil, digest: nil, repairEligible: false,
                reasonCode: "repair_required:\(reason)"
            )
        }
        let quarantine = try database.query(
            """
            SELECT 1 FROM runtime_canonical_projection_quarantine
            WHERE generation_id = ? AND reason_code = 'scrub_authority_mismatch' LIMIT 1
            """,
            bindings: [.text(authority.generationID)]
        )
        if quarantine.isEmpty == false {
            return RuntimeCanonicalProjectionTruth(
                state: .corrupt, authority: nil,
                expectedDefinitionVersion: definition.definitionVersion,
                sourceCursor: nil, digest: nil, repairEligible: false,
                reasonCode: "generation_scrub_quarantined"
            )
        }
        let jobs = try database.query(
            "SELECT phase, blocked_reason_code FROM runtime_canonical_projection_jobs WHERE projection_id = ? LIMIT 2",
            bindings: [.text(definition.id.rawValue)]
        )
        guard jobs.count <= 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        if let row = jobs.first {
            guard case let .text(phase)? = row.value(named: "phase") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            let blocked = phase == RuntimeCanonicalProjectionBuildPhase.blocked.rawValue
            let reason: String?
            if case let .text(value)? = row.value(named: "blocked_reason_code") {
                reason = value
            } else { reason = nil }
            guard blocked == (reason != nil) else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            return RuntimeCanonicalProjectionTruth(
                state: blocked ? .blocked : .rebuilding, authority: authority,
                expectedDefinitionVersion: definition.definitionVersion,
                sourceCursor: authority.sourceCursor, digest: authority.certificateDigest,
                repairEligible: false,
                reasonCode: blocked ? reason : "generation_job_pending"
            )
        }
        let pending = try hasPendingCanonicalInvalidation(
            projectionID: definition.id, database: database
        )
        return RuntimeCanonicalProjectionTruth(
            state: pending ? .stale : .available, authority: authority,
            expectedDefinitionVersion: definition.definitionVersion,
            sourceCursor: authority.sourceCursor, digest: authority.certificateDigest,
            repairEligible: false,
            reasonCode: pending ? "invalidation_pending" : nil
        )
    }

    func canonicalSearch(
        _ query: RuntimeCanonicalSearchQuery,
        after cursor: RuntimeCanonicalSearchCursor?,
        definition: RuntimeCanonicalProjectionDefinition
    ) async throws -> RuntimeCanonicalSearchPage {
        try Task.checkCancellation()
        guard query.allowedPrivacy.isEmpty == false else {
            throw RuntimeCanonicalSearchError.emptyPrivacyFilter
        }
        guard query.allowedPrivacy.isSubset(of: Set(definition.allowedPrivacyClasses)) else {
            throw RuntimeCanonicalSearchError.unauthorizedPrivacyFilter
        }
        let tokens = query.normalizedTokens
        guard query.inputIsSupported, tokens.isEmpty == false, tokens.count <= 16 else {
            throw RuntimeCanonicalSearchError.unsupportedQuery
        }
        do {
            return try await withCanonicalReadTransaction { database in
                try CanonicalRuntimeProjectionSchemaPlan.requireIntegratedSchema(in: database)
                let authority = try Self.requireCanonicalSearchAuthority(
                    definition: definition, database: database
                )
                if let cursor, cursor.isBound(to: authority.generationID, query: query) == false {
                    throw RuntimeCanonicalSearchError.cursorBindingMismatch
                }
                let truth = try Self.canonicalProjectionReadTruth(
                    authority: authority.projection,
                    definition: definition, database: database
                )
                guard truth.authority != nil else {
                    throw RuntimeCanonicalSearchError.projectionNotAvailable(truth.state)
                }
                let rows = try Self.readCanonicalSearchRows(
                    authority: authority, query: query, tokens: tokens,
                    cursor: cursor, database: database
                )
                let delivered = rows.prefix(query.deliveryCount)
                let results = try delivered.map { row -> RuntimeCanonicalSearchResult in
                    let document = try Self.decodeCanonicalSearchDocument(
                        row, generationID: authority.generationID
                    )
                    try Self.requireExactCanonicalSearchPostings(
                        document: document, database: database
                    )
                    return RuntimeCanonicalSearchResult(document: document)
                }
                let next: RuntimeCanonicalSearchCursor?
                if rows.count > query.deliveryCount, let last = results.last {
                    next = RuntimeCanonicalSearchCursor(
                        generationID: authority.generationID,
                        queryDigest: query.queryDigest, filterDigest: query.filterDigest,
                        aggregateKind: last.document.aggregate.kind,
                        aggregateID: last.document.aggregate.id
                    )
                } else { next = nil }
                return RuntimeCanonicalSearchPage(
                    generationID: authority.generationID,
                    coverage: authority.coverage,
                    projectionCursor: authority.projection.sourceCursor,
                    projectionDigest: authority.projection.certificateDigest,
                    results: results, nextCursor: next, truth: truth,
                    authorityFingerprint: authority.fingerprint
                )
            }
        } catch let error as RuntimeCanonicalSearchError { throw error }
        catch is CancellationError { throw CancellationError() }
        catch let error as SQLiteError {
            if Self.isCanonicalSQLiteCorruption(error) { throw RuntimeCanonicalSearchError.corruptIndex }
            throw RuntimeCanonicalSearchError.temporarilyUnavailable
        } catch let error as RuntimeCanonicalReplayError {
            if case .migrationRequired = error {
                throw RuntimeCanonicalSearchError.projectionNotAvailable(.unavailable)
            }
            throw RuntimeCanonicalSearchError.corruptIndex
        } catch {
            throw RuntimeCanonicalSearchError.corruptIndex
        }
    }

    /// Advisory only. Mutation owners must call the isolated verifier below
    /// from the same immediate transaction that performs the selected action.
    func revalidateCanonicalSearchAction(_ token: RuntimeCanonicalSearchActionToken) async throws {
        guard let definition = try? RuntimeCanonicalProjectionDefinitionRegistry
            .canonical().definitions[.search] else {
            throw RuntimeCanonicalSearchError.actionSourceChanged
        }
        try await withCanonicalReadTransaction { database in
            _ = try Self.requireCanonicalSearchActionAuthority(
                token, definition: definition, database: database
            )
        }
    }

    static func requireCanonicalSearchActionAuthority(
        _ token: RuntimeCanonicalSearchActionToken,
        definition: RuntimeCanonicalProjectionDefinition,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalSearchDocument {
        try Task.checkCancellation()
        let expectedAccess = RuntimeTransactionDigest.digest([
            "runtime.search.access-policy.v1",
            token.allowedPrivacy.map(\.rawValue).sorted().joined(separator: ","),
            String(token.requiresLocalOnly), token.families.map(\.rawValue).sorted().joined(separator: ","),
        ])
        guard token.definitionDigest == definition.authorityDigest,
              token.coverage == .aggregateKindOnly,
              token.allowedPrivacy.isEmpty == false,
              token.allowedPrivacy.isSubset(of: Set(definition.allowedPrivacyClasses)),
              token.accessPolicyDigest == expectedAccess else {
            throw RuntimeCanonicalSearchError.actionSourceChanged
        }
        let authority = try requireCanonicalSearchAuthority(
            definition: definition, database: database
        )
        guard authority.generationID == token.generationID,
              authority.fingerprint == token.authorityFingerprint else {
            throw RuntimeCanonicalSearchError.actionSourceChanged
        }
        let rows = try database.query(
            """
            SELECT aggregate_kind, aggregate_id, privacy, local_only, title, body,
                   source_sequence, source_event_id, source_event_hash, document_digest
            FROM runtime_canonical_search_documents
            WHERE generation_id = ? AND aggregate_kind = ? AND aggregate_id = ? LIMIT 2
            """,
            bindings: [
                .text(token.generationID), .text(token.aggregate.kind.rawValue),
                .text(token.aggregate.id.rawValue),
            ]
        )
        guard rows.count == 1 else { throw RuntimeCanonicalSearchError.actionSourceChanged }
        let document = try decodeCanonicalSearchDocument(rows[0], generationID: token.generationID)
        guard document.aggregate == token.aggregate,
              document.sourceCursor == token.sourceCursor,
              document.digest == token.documentDigest,
              token.allowedPrivacy.contains(document.privacy),
              token.requiresLocalOnly == false || document.localOnly,
              token.families.isEmpty || token.families.contains(document.aggregate.kind) else {
            throw RuntimeCanonicalSearchError.actionSourceChanged
        }
        return document
    }
}

extension CanonicalRuntimeStore {
    static func requireCanonicalProjectionAuthority(
        definition: RuntimeCanonicalProjectionDefinition,
        requireNoPendingInvalidations: Bool,
        requireAtVerifiedHighWater: Bool,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationAuthority {
        if requireNoPendingInvalidations,
           try hasPendingCanonicalInvalidation(projectionID: definition.id, database: database) {
            throw RuntimeCanonicalSearchError.projectionNotAvailable(.stale)
        }
        let rows = try database.query(
            """
            SELECT generation.generation_id, generation.definition_version,
                   generation.definition_digest, generation.output_version,
                   generation.source_sequence, generation.source_event_id,
                   generation.source_event_hash, generation.source_chain_digest,
                   generation.first_invalidation_id, generation.last_invalidation_id,
                   generation.invalidation_digest, generation.entry_count,
                   generation.shard_count, generation.entry_root_digest,
                   generation.privacy, generation.local_only,
                   generation.generation_certificate_digest
            FROM runtime_canonical_projection_active_generations AS active
            JOIN runtime_canonical_projection_generations AS generation
              ON generation.generation_id = active.generation_id
             AND generation.generation_certificate_digest = active.generation_certificate_digest
             AND generation.status = 'published'
            WHERE active.projection_id = ? LIMIT 2
            """,
            bindings: [.text(definition.id.rawValue)]
        )
        guard rows.count == 1,
              case let .text(generationID)? = rows[0].value(named: "generation_id"),
              rows[0].value(named: "definition_version") == .integer(Int64(definition.definitionVersion)),
              rows[0].value(named: "definition_digest") == .text(definition.authorityDigest),
              rows[0].value(named: "output_version") == .integer(Int64(definition.outputVersion)),
              case let .integer(sequence)? = rows[0].value(named: "source_sequence"), sequence >= 0,
              case let .text(eventID)? = rows[0].value(named: "source_event_id"),
              case let .text(eventHash)? = rows[0].value(named: "source_event_hash"),
              case let .text(sourceDigest)? = rows[0].value(named: "source_chain_digest"),
              case let .text(firstInvalidationID)? = rows[0].value(named: "first_invalidation_id"),
              case let .text(lastInvalidationID)? = rows[0].value(named: "last_invalidation_id"),
              case let .text(invalidationDigest)? = rows[0].value(named: "invalidation_digest"),
              case let .integer(entryCount)? = rows[0].value(named: "entry_count"), entryCount >= 0,
              case let .integer(shardCount)? = rows[0].value(named: "shard_count"), shardCount >= 0,
              case let .text(rootDigest)? = rows[0].value(named: "entry_root_digest"),
              case let .text(privacyRaw)? = rows[0].value(named: "privacy"),
              case let .integer(localOnly)? = rows[0].value(named: "local_only"),
              case let .text(certificate)? = rows[0].value(named: "generation_certificate_digest") else {
            throw RuntimeCanonicalSearchError.projectionNotAvailable(.corrupt)
        }
        let quarantined = try database.query(
            """
            SELECT 1 FROM runtime_canonical_projection_quarantine
            WHERE generation_id = ? AND reason_code = 'scrub_authority_mismatch' LIMIT 1
            """,
            bindings: [.text(generationID)]
        )
        guard quarantined.isEmpty else {
            throw RuntimeCanonicalSearchError.projectionNotAvailable(.corrupt)
        }
        let repair = try database.query(
            """
            SELECT 1 FROM runtime_canonical_repair_requirements
            WHERE projection_id = ? AND state = 'required'
              AND (generation_id IS NULL OR generation_id = ?) LIMIT 1
            """,
            bindings: [.text(definition.id.rawValue), .text(generationID)]
        )
        guard repair.isEmpty else {
            throw RuntimeCanonicalSearchError.projectionNotAvailable(.corrupt)
        }
        let cursor = RuntimeCanonicalReplayCursor(
            sequence: UInt64(sequence), eventID: eventID, eventHash: eventHash
        )
        let privacy: [EventLedgerPrivacyClassification]
        if privacyRaw.isEmpty { privacy = [] }
        else {
            privacy = try privacyRaw.split(separator: ",").map {
                guard let value = EventLedgerPrivacyClassification(rawValue: String($0)) else {
                    throw RuntimeCanonicalSearchError.projectionNotAvailable(.corrupt)
                }
                return value
            }
        }
        let expectedCertificate = canonicalProjectionGenerationCertificateDigest(
            generationID: generationID, projectionID: definition.id,
            definitionDigest: definition.authorityDigest,
            outputVersion: definition.outputVersion, sourceCursor: cursor,
            sourceChainDigest: sourceDigest, entryCount: Int(entryCount),
            shardCount: Int(shardCount), rootDigest: rootDigest,
            privacy: privacyRaw, localOnly: localOnly == 1,
            invalidationDigest: invalidationDigest
        )
        guard cursor.isWellFormed, certificate == expectedCertificate,
              Set(privacy).isSubset(of: Set(definition.allowedPrivacyClasses)),
              definition.requiresLocalOnlySource == false || localOnly == 1 else {
            throw RuntimeCanonicalSearchError.projectionNotAvailable(.corrupt)
        }
        try requireCanonicalPublishedScrubCertificate(
            generationID: generationID,
            kind: "projection",
            projectionID: definition.id.rawValue,
            generationCertificate: certificate,
            observedCount: Int(entryCount),
            observedShardCount: Int(shardCount),
            observedPostingCount: 0,
            observedPostingBytes: 0,
            rootDigest: rootDigest,
            database: database
        )
        if cursor == .emptySource {
            guard firstInvalidationID == "runtime.empty-source",
                  lastInvalidationID == "runtime.empty-source",
                  invalidationDigest == RuntimeTransactionDigest.digest([]),
                  entryCount == 0, shardCount == 0,
                  rootDigest == RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal,
                  privacy.isEmpty, localOnly == 1 else {
                throw RuntimeCanonicalSearchError.projectionNotAvailable(.corrupt)
            }
            if requireNoPendingInvalidations,
               try database.query(
                   "SELECT 1 FROM runtime_commit_projection_invalidations WHERE projection_id = ? LIMIT 1",
                   bindings: [.text(definition.id.rawValue)]
               ).isEmpty == false {
                throw RuntimeCanonicalSearchError.projectionNotAvailable(.stale)
            }
            if requireAtVerifiedHighWater,
               try RuntimeCanonicalReplayEngine.verifiedHighWaterCertificate(database: database) != nil {
                throw RuntimeCanonicalSearchError.projectionNotAvailable(.stale)
            }
            let fingerprint = RuntimeTransactionDigest.digest([
                "runtime.projection.authority-fingerprint.v1", definition.id.rawValue,
                generationID, certificate, definition.authorityDigest, "0",
                cursor.eventID, cursor.eventHash,
            ])
            return RuntimeCanonicalGenerationAuthority(
                projectionID: definition.id, generationID: generationID,
                definitionDigest: definition.authorityDigest,
                outputVersion: definition.outputVersion, sourceCursor: cursor,
                sourceChainDigest: sourceDigest, entryCount: 0,
                entryRootDigest: rootDigest, privacyClasses: [], localOnly: true,
                certificateDigest: certificate, fingerprint: fingerprint
            )
        }
        let generationAcks = try database.query(
            """
            SELECT ack.invalidation_id, invalidation.terminal_event_sequence,
                   event.event_id, event.event_hash, ack.generation_id,
                   ack.source_sequence, ack.generation_certificate_digest
            FROM runtime_canonical_projection_invalidation_acks AS ack
            JOIN runtime_commit_projection_invalidations AS invalidation
              ON invalidation.invalidation_id = ack.invalidation_id
             AND invalidation.projection_id = ack.projection_id
            JOIN runtime_semantic_events AS event
              ON event.sequence = invalidation.terminal_event_sequence
            WHERE ack.projection_id = ? AND ack.generation_id = ?
            ORDER BY invalidation.terminal_event_sequence, ack.invalidation_id LIMIT 65
            """,
            bindings: [.text(definition.id.rawValue), .text(generationID)]
        )
        let latest = try database.query(
            """
            SELECT invalidation_id FROM runtime_commit_projection_invalidations
            WHERE projection_id = ? AND terminal_event_sequence <= ?
            ORDER BY terminal_event_sequence DESC, invalidation_id DESC LIMIT 1
            """,
            bindings: [.text(definition.id.rawValue), .integer(sequence)]
        )
        guard generationAcks.isEmpty == false, generationAcks.count <= 64,
              generationAcks.first?.value(named: "invalidation_id") == .text(firstInvalidationID),
              generationAcks.last?.value(named: "invalidation_id") == .text(lastInvalidationID),
              generationAcks.allSatisfy({
                  $0.value(named: "generation_id") == .text(generationID)
                      && $0.value(named: "source_sequence") == .integer(sequence)
                      && $0.value(named: "generation_certificate_digest") == .text(certificate)
              }),
              (requireNoPendingInvalidations == false || (
                  latest.count == 1 &&
                  latest[0].value(named: "invalidation_id") == .text(lastInvalidationID)
              )) else {
            throw RuntimeCanonicalSearchError.projectionNotAvailable(.corrupt)
        }
        guard case let .integer(firstSequence)? = generationAcks.first?
                .value(named: "terminal_event_sequence"),
              case let .integer(lastSequence)? = generationAcks.last?
                .value(named: "terminal_event_sequence") else {
            throw RuntimeCanonicalSearchError.projectionNotAvailable(.corrupt)
        }
        let declaredRange = try database.query(
            """
            SELECT invalidation_id FROM runtime_commit_projection_invalidations
            WHERE projection_id = ? AND terminal_event_sequence BETWEEN ? AND ?
            ORDER BY terminal_event_sequence, invalidation_id LIMIT 65
            """,
            bindings: [
                .text(definition.id.rawValue), .integer(firstSequence), .integer(lastSequence),
            ]
        )
        guard declaredRange.map({ $0.value(named: "invalidation_id") }) ==
                generationAcks.map({ $0.value(named: "invalidation_id") }) else {
            throw RuntimeCanonicalSearchError.projectionNotAvailable(.corrupt)
        }
        let authenticatedInvalidationDigest = RuntimeTransactionDigest.digest(
            try generationAcks.flatMap { ack -> [String] in
                guard case let .text(identifier)? = ack.value(named: "invalidation_id"),
                      case let .integer(eventSequence)? = ack.value(named: "terminal_event_sequence"),
                      case let .text(ackEventID)? = ack.value(named: "event_id"),
                      case let .text(ackEventHash)? = ack.value(named: "event_hash") else {
                    throw RuntimeCanonicalSearchError.projectionNotAvailable(.corrupt)
                }
                return [identifier, String(eventSequence), ackEventID, ackEventHash]
            }
        )
        guard authenticatedInvalidationDigest == invalidationDigest else {
            throw RuntimeCanonicalSearchError.projectionNotAvailable(.corrupt)
        }
        let verified = try RuntimeCanonicalReplayEngine.verifiedReconstructionCertificate(
            at: cursor, database: database
        )
        guard verified.sourceChainDigest.hexadecimal == sourceDigest else {
            throw RuntimeCanonicalSearchError.projectionNotAvailable(.corrupt)
        }
        if requireAtVerifiedHighWater {
            guard let highWater = try RuntimeCanonicalReplayEngine
                .verifiedHighWaterCertificate(database: database),
                  highWater.cursor == cursor,
                  highWater.sourceChainDigest.hexadecimal == sourceDigest else {
                throw RuntimeCanonicalSearchError.projectionNotAvailable(.corrupt)
            }
        }
        let fingerprint = RuntimeTransactionDigest.digest([
            "runtime.projection.authority-fingerprint.v1", definition.id.rawValue,
            generationID, certificate, definition.authorityDigest,
            String(sequence), eventID, eventHash,
        ])
        return RuntimeCanonicalGenerationAuthority(
            projectionID: definition.id, generationID: generationID,
            definitionDigest: definition.authorityDigest,
            outputVersion: definition.outputVersion, sourceCursor: cursor,
            sourceChainDigest: sourceDigest, entryCount: Int(entryCount),
            entryRootDigest: rootDigest, privacyClasses: privacy,
            localOnly: localOnly == 1, certificateDigest: certificate,
            fingerprint: fingerprint
        )
    }
}

extension CanonicalRuntimeStore {
    static func requireCanonicalSearchAuthority(
        definition: RuntimeCanonicalProjectionDefinition,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalSearchAuthority {
        guard definition.id == .search else { throw RuntimeCanonicalSearchError.corruptIndex }
        let projection = try requireCanonicalProjectionAuthority(
            definition: definition, requireNoPendingInvalidations: true,
            requireAtVerifiedHighWater: true, database: database
        )
        let rows = try database.query(
            """
            SELECT generation.generation_id, generation.projection_generation_id,
                   generation.coverage, generation.definition_digest, generation.source_sequence,
                   generation.source_event_hash, generation.document_count,
                   generation.posting_count, generation.posting_bytes,
                   generation.shard_count, generation.document_root_digest,
                   generation.generation_certificate_digest
            FROM runtime_canonical_search_active_generation AS active
            JOIN runtime_canonical_search_generations AS generation
              ON generation.generation_id = active.generation_id
             AND generation.generation_certificate_digest = active.generation_certificate_digest
             AND generation.status = 'published'
            WHERE active.singleton_id = 1 LIMIT 2
            """
        )
        guard rows.count == 1,
              case let .text(generationID)? = rows[0].value(named: "generation_id"),
              rows[0].value(named: "projection_generation_id") == .text(projection.generationID),
              case let .text(coverageRaw)? = rows[0].value(named: "coverage"),
              let coverage = RuntimeCanonicalSearchCoverage(rawValue: coverageRaw),
              coverage == .aggregateKindOnly,
              rows[0].value(named: "definition_digest") == .text(definition.authorityDigest),
              rows[0].value(named: "source_sequence") == .integer(Int64(projection.sourceCursor.sequence)),
              rows[0].value(named: "source_event_hash") == .text(projection.sourceCursor.eventHash),
              case let .integer(documentCount)? = rows[0].value(named: "document_count"), documentCount >= 0,
              case let .integer(postingCount)? = rows[0].value(named: "posting_count"), postingCount >= 0,
              case let .integer(postingBytes)? = rows[0].value(named: "posting_bytes"), postingBytes >= 0,
              case let .integer(shardCount)? = rows[0].value(named: "shard_count"), shardCount >= 0,
              case let .text(rootDigest)? = rows[0].value(named: "document_root_digest"),
              case let .text(certificate)? = rows[0].value(named: "generation_certificate_digest") else {
            throw RuntimeCanonicalSearchError.corruptIndex
        }
        let searchQuarantine = try database.query(
            """
            SELECT 1 FROM runtime_canonical_projection_quarantine
            WHERE generation_id = ? AND reason_code = 'scrub_authority_mismatch' LIMIT 1
            """,
            bindings: [.text(generationID)]
        )
        guard searchQuarantine.isEmpty else {
            throw RuntimeCanonicalSearchError.corruptIndex
        }
        let searchRepair = try database.query(
            """
            SELECT 1 FROM runtime_canonical_repair_requirements
            WHERE projection_id = ? AND state = 'required'
              AND generation_id = ? LIMIT 1
            """,
            bindings: [.text(definition.id.rawValue), .text(generationID)]
        )
        guard searchRepair.isEmpty else {
            throw RuntimeCanonicalSearchError.corruptIndex
        }
        let expectedID = RuntimeTransactionDigest.digest([
            "runtime.search.generation.v1", projection.generationID,
            coverage.rawValue,
            definition.authorityDigest, String(projection.sourceCursor.sequence),
            projection.sourceCursor.eventHash,
        ])
        let expectedCertificate = canonicalSearchGenerationCertificateDigest(
            generationID: generationID,
            projectionGenerationID: projection.generationID,
            coverage: coverage,
            definitionDigest: definition.authorityDigest,
            sourceCursor: projection.sourceCursor,
            documentCount: Int(documentCount),
            postingCount: Int(postingCount), postingBytes: Int(postingBytes),
            shardCount: Int(shardCount),
            rootDigest: rootDigest
        )
        guard generationID == expectedID, certificate == expectedCertificate else {
            throw RuntimeCanonicalSearchError.corruptIndex
        }
        try requireCanonicalPublishedScrubCertificate(
            generationID: generationID,
            kind: "search",
            projectionID: definition.id.rawValue,
            generationCertificate: certificate,
            observedCount: Int(documentCount),
            observedShardCount: Int(shardCount),
            observedPostingCount: Int(postingCount),
            observedPostingBytes: Int(postingBytes),
            rootDigest: rootDigest,
            database: database
        )
        let fingerprint = RuntimeTransactionDigest.digest([
            "runtime.search.authority-fingerprint.v2", projection.fingerprint,
            generationID, coverage.rawValue, certificate, definition.authorityDigest,
        ])
        return RuntimeCanonicalSearchAuthority(
            projection: projection, generationID: generationID, coverage: coverage,
            certificateDigest: certificate, fingerprint: fingerprint
        )
    }

    static func requireCanonicalPublishedScrubCertificate(
        generationID: String,
        kind: String,
        projectionID: String,
        generationCertificate: String,
        observedCount: Int,
        observedShardCount: Int,
        observedPostingCount: Int,
        observedPostingBytes: Int,
        rootDigest: String,
        database: isolated SQLiteDatabase
    ) throws {
        let rows = try database.query(
            """
            SELECT generation_kind, projection_id, generation_certificate_digest,
                   observed_count, observed_shard_count, observed_posting_count,
                   observed_posting_bytes, root_digest, completed_at_ms,
                   scrub_certificate_digest
            FROM runtime_canonical_scrub_certificates
            WHERE generation_id = ? LIMIT 2
            """,
            bindings: [.text(generationID)]
        )
        guard rows.count == 1,
              rows[0].value(named: "generation_kind") == .text(kind),
              rows[0].value(named: "projection_id") == .text(projectionID),
              rows[0].value(named: "generation_certificate_digest") ==
                .text(generationCertificate),
              rows[0].value(named: "observed_count") == .integer(Int64(observedCount)),
              rows[0].value(named: "observed_shard_count") ==
                .integer(Int64(observedShardCount)),
              rows[0].value(named: "observed_posting_count") ==
                .integer(Int64(observedPostingCount)),
              rows[0].value(named: "observed_posting_bytes") ==
                .integer(Int64(observedPostingBytes)),
              rows[0].value(named: "root_digest") == .text(rootDigest),
              case let .integer(completedAt)? = rows[0].value(named: "completed_at_ms"),
              completedAt >= 0,
              case let .text(scrubCertificate)? = rows[0]
                .value(named: "scrub_certificate_digest"),
              scrubCertificate == canonicalScrubCertificateDigest(
                  generationID: generationID,
                  kind: kind,
                  projectionID: projectionID,
                  generationCertificate: generationCertificate,
                  observedCount: observedCount,
                  observedShardCount: observedShardCount,
                  observedPostingCount: observedPostingCount,
                  observedPostingBytes: observedPostingBytes,
                  rootDigest: rootDigest,
                  completedAtMilliseconds: completedAt
              ) else {
            if kind == "search" { throw RuntimeCanonicalSearchError.corruptIndex }
            throw RuntimeCanonicalSearchError.projectionNotAvailable(.corrupt)
        }
    }

    static func readCanonicalSearchRows(
        authority: RuntimeCanonicalSearchAuthority,
        query: RuntimeCanonicalSearchQuery,
        tokens: [String],
        cursor: RuntimeCanonicalSearchCursor?,
        database: isolated SQLiteDatabase
    ) throws -> [SQLiteRow] {
        let privacy = query.allowedPrivacy.map(\.rawValue).sorted()
        let families = query.families.map(\.rawValue).sorted()
        let privacyPlaceholders = Array(repeating: "?", count: privacy.count).joined(separator: ",")
        let familyPredicate = families.isEmpty
            ? "1 = 1"
            : "document.aggregate_kind IN (\(Array(repeating: "?", count: families.count).joined(separator: ",")))"
        var intersection: Set<String>?
        var identities: [String: (String, String)] = [:]
        var firstTokenOrder: [String] = []
        var postingWork = 0
        for token in tokens {
            var bindings: [SQLiteBinding] = [
                .text(authority.generationID), .text(token),
            ]
            bindings += privacy.map(SQLiteBinding.text)
            bindings.append(.integer(query.requiresLocalOnly ? 1 : 0))
            bindings += families.map(SQLiteBinding.text)
            bindings += [
                .text(cursor?.aggregateKind.rawValue ?? ""),
                .text(cursor?.aggregateKind.rawValue ?? ""),
                .text(cursor?.aggregateID.rawValue ?? ""),
                .integer(Int64(
                    RuntimeCanonicalSearchQuery.maximumPostingWork - postingWork + 1
                )),
            ]
            // Bound the raw posting relation before SQLite grouping or Swift
            // aggregation. At most one sentinel row beyond the remaining work
            // budget is decoded.
            let postings = try database.query(
                """
                SELECT posting.aggregate_kind, posting.aggregate_id
                FROM runtime_canonical_search_postings AS posting
                JOIN runtime_canonical_search_documents AS document
                  ON document.generation_id = posting.generation_id
                 AND document.aggregate_kind = posting.aggregate_kind
                 AND document.aggregate_id = posting.aggregate_id
                WHERE posting.generation_id = ? AND posting.normalized_token = ?
                  AND document.privacy IN (\(privacyPlaceholders))
                  AND (? = 0 OR document.local_only = 1)
                  AND (\(familyPredicate))
                  AND (document.aggregate_kind > ? OR
                       (document.aggregate_kind = ? AND document.aggregate_id > ?))
                ORDER BY posting.aggregate_kind, posting.aggregate_id,
                         posting.field_ordinal, posting.token_ordinal LIMIT ?
                """,
                bindings: bindings,
                maximumDecodedBytes:
                    (RuntimeCanonicalSearchQuery.maximumPostingWork - postingWork + 1) * 512
            )
            let remainingPostingWork = RuntimeCanonicalSearchQuery.maximumPostingWork - postingWork
            guard postings.count <= remainingPostingWork else {
                throw RuntimeCanonicalSearchError.queryTooBroad
            }
            var tokenSet: Set<String> = []
            for row in postings {
                guard case let .text(kind)? = row.value(named: "aggregate_kind"),
                      case let .text(identifier)? = row.value(named: "aggregate_id") else {
                    throw RuntimeCanonicalSearchError.corruptIndex
                }
                postingWork += 1
                let key = kind + "\u{0}" + identifier
                let inserted = tokenSet.insert(key).inserted
                guard tokenSet.count <= RuntimeCanonicalSearchQuery.maximumCandidateCount else {
                    throw RuntimeCanonicalSearchError.queryTooBroad
                }
                identities[key] = (kind, identifier)
                if intersection == nil, inserted { firstTokenOrder.append(key) }
            }
            intersection = intersection.map { $0.intersection(tokenSet) } ?? tokenSet
            if intersection?.isEmpty == true { return [] }
        }
        let selected = firstTokenOrder.lazy.filter {
            intersection?.contains($0) == true
        }.prefix(query.deliveryCount + 1)
        var rows: [SQLiteRow] = []
        for key in selected {
            guard let identity = identities[key] else {
                throw RuntimeCanonicalSearchError.corruptIndex
            }
            let found = try database.query(
                """
                SELECT aggregate_kind, aggregate_id, privacy, local_only, title, body,
                       source_sequence, source_event_id, source_event_hash, document_digest
                FROM runtime_canonical_search_documents
                WHERE generation_id = ? AND aggregate_kind = ? AND aggregate_id = ? LIMIT 2
                """,
                bindings: [
                    .text(authority.generationID), .text(identity.0), .text(identity.1),
                ], maximumDecodedBytes: 40_000
            )
            guard found.count == 1 else { throw RuntimeCanonicalSearchError.corruptIndex }
            rows.append(found[0])
        }
        return rows
    }

    static func hasPendingCanonicalInvalidation(
        projectionID: RuntimeCanonicalProjectionID,
        database: isolated SQLiteDatabase
    ) throws -> Bool {
        try database.query(
            """
            SELECT 1 FROM runtime_commit_projection_invalidations AS invalidation
            LEFT JOIN runtime_canonical_projection_invalidation_acks AS ack
              ON ack.projection_id = invalidation.projection_id
             AND ack.invalidation_id = invalidation.invalidation_id
            WHERE invalidation.projection_id = ? AND ack.invalidation_id IS NULL LIMIT 1
            """,
            bindings: [.text(projectionID.rawValue)]
        ).isEmpty == false
    }

    static func historicalPrivacyBlock(
        database: isolated SQLiteDatabase
    ) throws -> (eventID: String, payloadVersion: Int)? {
        let rows = try database.query(
            "SELECT event_id, payload_version FROM runtime_semantic_events WHERE payload_version < 3 ORDER BY sequence LIMIT 1"
        )
        if case let .text(eventID)? = rows.first?.value(named: "event_id"),
           case let .integer(version)? = rows.first?.value(named: "payload_version") {
            return (eventID, Int(version))
        }
        return nil
    }

    static func isCanonicalSQLiteCorruption(_ error: SQLiteError) -> Bool {
        [11, 18, 19, 20, 21, 26].contains(Int(error.primaryCode))
    }
}
