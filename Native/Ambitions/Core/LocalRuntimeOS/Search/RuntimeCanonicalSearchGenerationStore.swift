import AmbitionsRuntimeSQLite
import Foundation

extension CanonicalRuntimeStore {
    func indexCanonicalSearchDocumentPage(
        _ work: RuntimeCanonicalProjectionBuildWork,
        bounds: RuntimeCanonicalProjectionUnitBounds
    ) async throws -> RuntimeCanonicalProjectionUnitResult {
        try Task.checkCancellation()
        guard work.projectionID == .search else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        return try await withCanonicalImmediateTransaction { database in
            try Self.requireCanonicalProjectionBuildFence(work, phase: .indexSearch, database: database)
            let searchGenerationID = Self.canonicalSearchGenerationID(work)
            try Self.ensureCanonicalSearchGeneration(
                generationID: searchGenerationID, work: work, database: database
            )
            let limit = try Self.canonicalBoundedSearchSourceCount(
                generationID: work.generationID, afterKind: work.afterAggregateKind,
                afterID: work.afterAggregateID, bounds: bounds, database: database
            )
            let rows = try database.query(
                """
                SELECT aggregate_kind, aggregate_id, revision, lifecycle,
                       canonical_state_digest, privacy, local_only,
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
                try Self.updateCanonicalProjectionJobPhase(
                    work, nextPhase: .sealSearch, resetKeyset: true, database: database
                )
                return RuntimeCanonicalProjectionUnitResult(
                    nextPhase: .sealSearch, progressCursor: work.targetCursor
                )
            }
            var addedDocuments = 0
            var addedPostings = 0
            var addedPostingBytes = 0
            for row in rows {
                try Task.checkCancellation()
                let entry = try Self.decodeCanonicalSearchSourceMetadata(row)
                guard entry.lifecycle == .active else { continue }
                let metrics = try Self.insertCanonicalSearchDocument(
                    generationID: searchGenerationID, entry: entry,
                    definition: work.definition, database: database
                )
                addedDocuments += 1
                addedPostings += metrics.postingCount
                addedPostingBytes += metrics.postingBytes
            }
            guard case let .text(lastKind)? = rows.last?.value(named: "aggregate_kind"),
                  case let .text(lastID)? = rows.last?.value(named: "aggregate_id") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            let changed = try database.execute(
                """
                UPDATE runtime_canonical_projection_jobs
                SET after_aggregate_kind = ?, after_aggregate_id = ?,
                    search_document_count = search_document_count + ?,
                    search_posting_count = search_posting_count + ?,
                    search_posting_bytes = search_posting_bytes + ?,
                    updated_at_ms = updated_at_ms + 1
                WHERE projection_id = ? AND generation_id = ? AND phase = 'index_search'
                  AND owner_id = ? AND fence_version = ?
                """,
                bindings: [
                    .text(lastKind), .text(lastID), .integer(Int64(addedDocuments)),
                    .integer(Int64(addedPostings)), .integer(Int64(addedPostingBytes)),
                    .text(work.projectionID.rawValue),
                    .text(work.generationID), .text(work.lease.ownerID),
                    .integer(Int64(work.lease.version)),
                ]
            )
            guard changed.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            return RuntimeCanonicalProjectionUnitResult(
                nextPhase: .indexSearch, progressCursor: work.targetCursor
            )
        }
    }

    func sealCanonicalSearchDocumentShard(
        _ work: RuntimeCanonicalProjectionBuildWork,
        bounds: RuntimeCanonicalProjectionUnitBounds
    ) async throws -> RuntimeCanonicalProjectionUnitResult {
        try Task.checkCancellation()
        return try await withCanonicalImmediateTransaction { database in
            try Self.requireCanonicalProjectionBuildFence(work, phase: .sealSearch, database: database)
            let searchGenerationID = Self.canonicalSearchGenerationID(work)
            let sizeRows = try database.query(
                """
                SELECT length(CAST(title AS BLOB)) + length(CAST(body AS BLOB)) AS byte_count
                FROM runtime_canonical_search_documents
                WHERE generation_id = ? AND
                      (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id > ?))
                ORDER BY aggregate_kind, aggregate_id LIMIT ?
                """,
                bindings: [
                    .text(searchGenerationID), .text(work.afterAggregateKind),
                    .text(work.afterAggregateKind), .text(work.afterAggregateID),
                    .integer(Int64(bounds.maximumRows)),
                ]
            )
            let limit = try Self.canonicalBoundedCount(
                sizeRows: sizeRows, bounds: bounds, perRowOverhead: 2_048
            )
            let rows = try database.query(
                """
                SELECT aggregate_kind, aggregate_id, privacy, local_only, title, body,
                       source_sequence, source_event_id, source_event_hash, document_digest
                FROM runtime_canonical_search_documents
                WHERE generation_id = ? AND
                      (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id > ?))
                ORDER BY aggregate_kind, aggregate_id LIMIT ?
                """,
                bindings: [
                    .text(searchGenerationID), .text(work.afterAggregateKind),
                    .text(work.afterAggregateKind), .text(work.afterAggregateID),
                    .integer(Int64(limit)),
                ], maximumDecodedBytes: bounds.maximumBytes
            )
            if rows.isEmpty {
                guard work.sealedSearchDocumentCount == work.searchDocumentCount else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
                let certificate = Self.canonicalSearchGenerationCertificateDigest(
                    generationID: searchGenerationID,
                    projectionGenerationID: work.generationID,
                    coverage: .aggregateMetadataOnly,
                    definitionDigest: work.definition.authorityDigest,
                    sourceCursor: work.targetCursor,
                    documentCount: work.searchDocumentCount,
                    postingCount: work.searchPostingCount,
                    postingBytes: work.searchPostingBytes,
                    shardCount: work.shardOrdinal,
                    rootDigest: work.rollingRootDigest
                )
                let changed = try database.execute(
                    """
                    UPDATE runtime_canonical_search_generations
                    SET document_count = ?, posting_count = ?, posting_bytes = ?,
                        shard_count = ?, document_root_digest = ?,
                        status = 'sealed', generation_certificate_digest = ?
                    WHERE generation_id = ? AND status = 'building'
                    """,
                    bindings: [
                        .integer(Int64(work.searchDocumentCount)),
                        .integer(Int64(work.searchPostingCount)),
                        .integer(Int64(work.searchPostingBytes)),
                        .integer(Int64(work.shardOrdinal)),
                        .text(work.rollingRootDigest), .text(certificate),
                        .text(searchGenerationID),
                    ]
                )
                guard changed.changedRowCount == 1 else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
                try Self.updateCanonicalProjectionJobPhase(
                    work, nextPhase: .ready, resetKeyset: true, database: database
                )
                return RuntimeCanonicalProjectionUnitResult(
                    nextPhase: .ready, progressCursor: work.targetCursor
                )
            }
            guard case let .text(firstKind)? = rows.first?.value(named: "aggregate_kind"),
                  case let .text(firstID)? = rows.first?.value(named: "aggregate_id"),
                  case let .text(lastKind)? = rows.last?.value(named: "aggregate_kind"),
                  case let .text(lastID)? = rows.last?.value(named: "aggregate_id") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            var material = [
                "runtime.search.shard.v1", searchGenerationID,
                String(work.shardOrdinal), work.rollingRootDigest,
            ]
            for row in rows {
                try Task.checkCancellation()
                let document = try Self.decodeCanonicalSearchDocument(
                    row, generationID: searchGenerationID
                )
                try Self.requireExactCanonicalSearchPostings(
                    document: document, database: database
                )
                material += [
                    document.aggregate.kind.rawValue,
                    document.aggregate.id.rawValue,
                    document.digest,
                ]
            }
            let shardDigest = RuntimeTransactionDigest.digest(material)
            try database.execute(
                """
                INSERT INTO runtime_canonical_search_shards(
                    generation_id, shard_ordinal, first_aggregate_kind, first_aggregate_id,
                    last_aggregate_kind, last_aggregate_id, document_count,
                    prior_shard_digest, shard_digest
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                bindings: [
                    .text(searchGenerationID), .integer(Int64(work.shardOrdinal)),
                    .text(firstKind), .text(firstID), .text(lastKind), .text(lastID),
                    .integer(Int64(rows.count)), .text(work.rollingRootDigest), .text(shardDigest),
                ]
            )
            let changed = try database.execute(
                """
                UPDATE runtime_canonical_projection_jobs
                SET after_aggregate_kind = ?, after_aggregate_id = ?, shard_ordinal = ?,
                    rolling_root_digest = ?,
                    sealed_search_document_count = sealed_search_document_count + ?,
                    updated_at_ms = updated_at_ms + 1
                WHERE projection_id = ? AND generation_id = ? AND phase = 'seal_search'
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
                nextPhase: .sealSearch, progressCursor: work.targetCursor
            )
        }
    }
}

extension CanonicalRuntimeStore {
    static func canonicalBoundedSearchSourceCount(
        generationID: String,
        afterKind: String,
        afterID: String,
        bounds: RuntimeCanonicalProjectionUnitBounds,
        database: isolated SQLiteDatabase
    ) throws -> Int {
        let rows = try database.query(
            """
            SELECT length(CAST(aggregate_kind AS BLOB)) +
                   length(CAST(aggregate_id AS BLOB)) +
                   length(CAST(canonical_state_digest AS BLOB)) +
                   length(CAST(source_event_id AS BLOB)) +
                   length(CAST(source_event_hash AS BLOB)) +
                   length(CAST(entry_digest AS BLOB)) AS byte_count
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
        return try canonicalBoundedCount(sizeRows: rows, bounds: bounds, perRowOverhead: 1_024)
    }

    static func decodeCanonicalSearchSourceMetadata(
        _ row: SQLiteRow
    ) throws -> RuntimeCanonicalProjectionEntry {
        guard case let .text(kindRaw)? = row.value(named: "aggregate_kind"),
              let kind = RuntimeSemanticAggregateKind(rawValue: kindRaw),
              case let .text(idRaw)? = row.value(named: "aggregate_id"),
              let identifier = RuntimeAggregateID(rawValue: idRaw),
              case let .integer(revision)? = row.value(named: "revision"), revision >= 0,
              case let .text(lifecycleRaw)? = row.value(named: "lifecycle"),
              let lifecycle = RuntimeAggregateLifecycle(rawValue: lifecycleRaw),
              case let .text(stateDigest)? = row.value(named: "canonical_state_digest"),
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
            canonicalStateBytes: Data(), canonicalStateDigest: stateDigest,
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

    static func canonicalSearchGenerationID(_ work: RuntimeCanonicalProjectionBuildWork) -> String {
        RuntimeTransactionDigest.digest([
            "runtime.search.generation.v1", work.generationID,
            RuntimeCanonicalSearchCoverage.aggregateMetadataOnly.rawValue,
            work.definition.authorityDigest, String(work.targetCursor.sequence),
            work.targetCursor.eventHash,
        ])
    }

    static func canonicalSearchGenerationCertificateDigest(
        generationID: String,
        projectionGenerationID: String,
        coverage: RuntimeCanonicalSearchCoverage,
        definitionDigest: String,
        sourceCursor: RuntimeCanonicalReplayCursor,
        documentCount: Int,
        postingCount: Int,
        postingBytes: Int,
        shardCount: Int,
        rootDigest: String
    ) -> String {
        RuntimeTransactionDigest.digest([
            "runtime.search.generation-certificate.v1", generationID,
            projectionGenerationID, coverage.rawValue, definitionDigest,
            String(sourceCursor.sequence), sourceCursor.eventHash,
            String(documentCount), String(postingCount), String(postingBytes),
            String(shardCount), rootDigest,
        ])
    }

    static func ensureCanonicalSearchGeneration(
        generationID: String,
        work: RuntimeCanonicalProjectionBuildWork,
        database: isolated SQLiteDatabase
    ) throws {
        try database.execute(
            """
            INSERT OR IGNORE INTO runtime_canonical_search_generations(
                generation_id, projection_generation_id, coverage, definition_digest,
                source_sequence, source_event_hash, document_count, posting_count,
                posting_bytes, shard_count,
                document_root_digest, status, generation_certificate_digest, created_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, 0, 0, 0, 0, ?, 'building', NULL, ?)
            """,
            bindings: [
                .text(generationID), .text(work.generationID),
                .text(RuntimeCanonicalSearchCoverage.aggregateMetadataOnly.rawValue),
                .text(work.definition.authorityDigest),
                .integer(Int64(work.targetCursor.sequence)), .text(work.targetCursor.eventHash),
                .text(RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal),
                .integer(work.operationNowMilliseconds),
            ]
        )
        let rows = try database.query(
            """
            SELECT projection_generation_id, coverage, definition_digest, source_sequence,
                   source_event_hash, status
            FROM runtime_canonical_search_generations WHERE generation_id = ? LIMIT 2
            """,
            bindings: [.text(generationID)]
        )
        guard rows.count == 1,
              rows[0].value(named: "projection_generation_id") == .text(work.generationID),
              rows[0].value(named: "coverage") == .text(RuntimeCanonicalSearchCoverage.aggregateMetadataOnly.rawValue),
              rows[0].value(named: "definition_digest") == .text(work.definition.authorityDigest),
              rows[0].value(named: "source_sequence") == .integer(Int64(work.targetCursor.sequence)),
              rows[0].value(named: "source_event_hash") == .text(work.targetCursor.eventHash),
              rows[0].value(named: "status") == .text("building") else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
    }

    static func insertCanonicalSearchDocument(
        generationID: String,
        entry: RuntimeCanonicalProjectionEntry,
        definition: RuntimeCanonicalProjectionDefinition,
        database: isolated SQLiteDatabase
    ) throws -> (postingCount: Int, postingBytes: Int) {
        let fields = Set(definition.allowedSearchFields)
        let extracted = try RuntimeCanonicalSearchMetadataExtractor.extract(
            entry: entry, allowedFields: fields
        )
        let title = extracted.title
        let body = extracted.body
        let digest = RuntimeTransactionDigest.digest([
            "runtime.search.document.v2", generationID,
            entry.aggregate.kind.rawValue, entry.aggregate.id.rawValue,
            entry.privacy.rawValue, String(entry.localOnly), title, body,
            String(entry.sourceCursor.sequence), entry.sourceCursor.eventID,
            entry.sourceCursor.eventHash,
        ])
        try database.execute(
            """
            INSERT INTO runtime_canonical_search_documents(
                generation_id, aggregate_kind, aggregate_id, privacy, local_only,
                title, body, source_sequence, source_event_id, source_event_hash, document_digest
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(generationID), .text(entry.aggregate.kind.rawValue),
                .text(entry.aggregate.id.rawValue), .text(entry.privacy.rawValue),
                .integer(entry.localOnly ? 1 : 0), .text(title), .text(body),
                .integer(Int64(entry.sourceCursor.sequence)), .text(entry.sourceCursor.eventID),
                .text(entry.sourceCursor.eventHash), .text(digest),
            ]
        )
        var totalPostingCount = 0
        var totalPostingBytes = 0
        for (fieldOrdinal, value) in [title, body].enumerated() {
            let tokens = canonicalSearchTokens(value)
            for (tokenOrdinal, token) in tokens.enumerated() {
                let postingDigest = RuntimeTransactionDigest.digest([
                    "runtime.search.posting.v1", generationID, token,
                    entry.aggregate.kind.rawValue, entry.aggregate.id.rawValue,
                    String(fieldOrdinal), String(tokenOrdinal), digest,
                ])
                try database.execute(
                    """
                    INSERT INTO runtime_canonical_search_postings(
                        generation_id, normalized_token, aggregate_kind, aggregate_id,
                        field_ordinal, token_ordinal, posting_digest
                    ) VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                    bindings: [
                        .text(generationID), .text(token),
                        .text(entry.aggregate.kind.rawValue), .text(entry.aggregate.id.rawValue),
                        .integer(Int64(fieldOrdinal)), .integer(Int64(tokenOrdinal)),
                        .text(postingDigest),
                    ]
                )
                let postingBytes = token.utf8.count + postingDigest.utf8.count +
                    entry.aggregate.kind.rawValue.utf8.count + entry.aggregate.id.rawValue.utf8.count + 16
                totalPostingCount += 1
                totalPostingBytes += postingBytes
            }
        }
        return (totalPostingCount, totalPostingBytes)
    }

    static func canonicalSearchTokens(_ value: String) -> [String] {
        RuntimeCanonicalSearchTokenizer.tokens(
            value, maximumCount: RuntimeCanonicalSearchMetadataExtractor.maximumTokensPerField
        )
    }

    static func decodeCanonicalSearchDocument(
        _ row: SQLiteRow,
        generationID: String
    ) throws -> RuntimeCanonicalSearchDocument {
        guard case let .text(kindRaw)? = row.value(named: "aggregate_kind"),
              let kind = RuntimeSemanticAggregateKind(rawValue: kindRaw),
              case let .text(idRaw)? = row.value(named: "aggregate_id"),
              let identifier = RuntimeAggregateID(rawValue: idRaw),
              case let .text(privacyRaw)? = row.value(named: "privacy"),
              let privacy = EventLedgerPrivacyClassification(rawValue: privacyRaw),
              case let .integer(localOnly)? = row.value(named: "local_only"),
              case let .text(title)? = row.value(named: "title"),
              case let .text(body)? = row.value(named: "body"),
              case let .integer(sequence)? = row.value(named: "source_sequence"), sequence > 0,
              case let .text(eventID)? = row.value(named: "source_event_id"),
              case let .text(eventHash)? = row.value(named: "source_event_hash"),
              case let .text(digest)? = row.value(named: "document_digest") else {
            throw RuntimeCanonicalSearchError.corruptIndex
        }
        let aggregate = RuntimeSemanticAggregate(kind: kind, id: identifier)
        let cursor = RuntimeCanonicalReplayCursor(
            sequence: UInt64(sequence), eventID: eventID, eventHash: eventHash
        )
        let expected = RuntimeCanonicalSearchDocument.authorityDigest(
            generationID: generationID, aggregate: aggregate, privacy: privacy,
            localOnly: localOnly == 1, title: title, body: body, sourceCursor: cursor
        )
        guard cursor.isWellFormed, digest == expected else {
            throw RuntimeCanonicalSearchError.corruptIndex
        }
        return RuntimeCanonicalSearchDocument(
            generationID: generationID, aggregate: aggregate, privacy: privacy,
            localOnly: localOnly == 1, title: title, body: body,
            sourceCursor: cursor, digest: digest
        )
    }

    static func requireExactCanonicalSearchPostings(
        document: RuntimeCanonicalSearchDocument,
        database: isolated SQLiteDatabase
    ) throws {
        let rows = try database.query(
            """
            SELECT normalized_token, field_ordinal, token_ordinal, posting_digest
            FROM runtime_canonical_search_postings
            WHERE generation_id = ? AND aggregate_kind = ? AND aggregate_id = ?
            ORDER BY field_ordinal, token_ordinal, normalized_token
            """,
            bindings: [
                .text(document.generationID), .text(document.aggregate.kind.rawValue),
                .text(document.aggregate.id.rawValue),
            ],
            maximumDecodedBytes: RuntimeCanonicalSearchMetadataExtractor.maximumTokensPerField
                * 2 * 512
        )
        let expected = [document.title, document.body].enumerated().flatMap { field, value in
            canonicalSearchTokens(value).enumerated().map { ordinal, token in
                (token, Int64(field), Int64(ordinal), RuntimeTransactionDigest.digest([
                    "runtime.search.posting.v1", document.generationID, token,
                    document.aggregate.kind.rawValue, document.aggregate.id.rawValue,
                    String(field), String(ordinal), document.digest,
                ]))
            }
        }.sorted {
            if $0.1 != $1.1 { return $0.1 < $1.1 }
            if $0.2 != $1.2 { return $0.2 < $1.2 }
            return $0.0 < $1.0
        }
        guard rows.count == expected.count else { throw RuntimeCanonicalSearchError.corruptIndex }
        for (row, value) in zip(rows, expected) {
            guard row.value(named: "normalized_token") == .text(value.0),
                  row.value(named: "field_ordinal") == .integer(value.1),
                  row.value(named: "token_ordinal") == .integer(value.2),
                  row.value(named: "posting_digest") == .text(value.3) else {
                throw RuntimeCanonicalSearchError.corruptIndex
            }
        }
    }
}

enum RuntimeCanonicalSearchMetadataExtractor {
    static let maximumFieldCharacters = 4_096
    static let maximumDocumentCharacters = 16_384
    static let maximumTokensPerField = 64

    static func extract(
        entry: RuntimeCanonicalProjectionEntry,
        allowedFields: Set<RuntimeCanonicalSearchField>
    ) throws -> (title: String, body: String) {
        var titleParts: [String] = []
        var bodyParts: [String] = []
        if allowedFields.contains(.aggregateKind) { titleParts.append(entry.aggregate.kind.rawValue) }
        if allowedFields.contains(.aggregateID) { bodyParts.append(entry.aggregate.id.rawValue) }
        let all = titleParts + bodyParts
        guard all.allSatisfy({ $0.unicodeScalars.count <= maximumFieldCharacters }) else {
            throw RuntimeCanonicalProjectionPersistenceError.unitBudgetExceeded
        }
        let title = titleParts.joined(separator: " ")
        let body = bodyParts.joined(separator: " ")
        guard title.unicodeScalars.count + body.unicodeScalars.count <= maximumDocumentCharacters else {
            throw RuntimeCanonicalProjectionPersistenceError.unitBudgetExceeded
        }
        let titleTokens = RuntimeCanonicalSearchTokenizer.tokenize(
            title, maximumCount: maximumTokensPerField
        )
        let bodyTokens = RuntimeCanonicalSearchTokenizer.tokenize(
            body, maximumCount: maximumTokensPerField
        )
        guard titleTokens.exceededMaximumCount == false,
              bodyTokens.exceededMaximumCount == false else {
            throw RuntimeCanonicalProjectionPersistenceError.unitBudgetExceeded
        }
        return (title, body)
    }
}
