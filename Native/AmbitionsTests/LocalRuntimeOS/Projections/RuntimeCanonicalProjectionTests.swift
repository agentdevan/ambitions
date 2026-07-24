import Foundation
import AmbitionsRuntimeSQLite
@testable import Ambitions
import XCTest

final class RuntimeCanonicalProjectionTests: XCTestCase, @unchecked Sendable {
    func testRegistryOwnsEverySemanticEventDeterministically() throws {
        XCTAssertTrue(RuntimeCanonicalProjectionRegistry.validateExhaustiveOwnership())
        XCTAssertEqual(
            RuntimeCanonicalProjectionRegistry.allEventTypeIDs,
            Set(RuntimeSemanticEventTypeID.allCases)
        )
        for typeID in RuntimeSemanticEventTypeID.allCases {
            let owners = RuntimeCanonicalProjectionRegistry.projectionIDs(for: typeID)
            XCTAssertEqual(owners, Array(Set(owners)).sorted())
            XCTAssertTrue(owners.contains(.aggregateState))
            XCTAssertTrue(owners.contains(.search))
        }
    }

    func testDefinitionRegistryIsExhaustiveAndSearchCoverageIsTruthful() throws {
        let registry = try RuntimeCanonicalProjectionDefinitionRegistry.canonical()
        XCTAssertEqual(Set(registry.definitions.keys), Set(RuntimeCanonicalProjectionID.allCases))
        let search = try XCTUnwrap(registry.definitions[.search])
        XCTAssertEqual(search.allowedSearchFields, [.aggregateID, .aggregateKind])
        XCTAssertEqual(
            RuntimeCanonicalSearchCoverage.aggregateMetadataOnly.rawValue,
            "aggregate_metadata_only"
        )

        let duplicate = registry.definitions.values.sorted { $0.id < $1.id }
        XCTAssertThrowsError(
            try RuntimeCanonicalProjectionDefinitionRegistry(
                definitions: duplicate + [duplicate[0]]
            )
        ) {
            XCTAssertEqual(
                $0 as? RuntimeCanonicalProjectionDefinitionRegistryError,
                .duplicateProjectionID(duplicate[0].id)
            )
        }
    }

    func testProjectionEntryDigestBindsStatePrivacyAndFullSourceCursor() throws {
        let entry = try makeEntry()
        let original = CanonicalRuntimeStore.canonicalProjectionEntryDigest(entry)
        let changedCursor = RuntimeCanonicalProjectionEntry(
            aggregate: entry.aggregate, revision: entry.revision,
            lifecycle: entry.lifecycle, canonicalStateBytes: entry.canonicalStateBytes,
            canonicalStateDigest: entry.canonicalStateDigest, privacy: entry.privacy,
            localOnly: entry.localOnly,
            sourceCursor: RuntimeCanonicalReplayCursor(
                sequence: entry.sourceCursor.sequence,
                eventID: "event-other", eventHash: entry.sourceCursor.eventHash
            )
        )
        let changedPrivacy = RuntimeCanonicalProjectionEntry(
            aggregate: entry.aggregate, revision: entry.revision,
            lifecycle: entry.lifecycle, canonicalStateBytes: entry.canonicalStateBytes,
            canonicalStateDigest: entry.canonicalStateDigest, privacy: .sensitive,
            localOnly: entry.localOnly, sourceCursor: entry.sourceCursor
        )
        XCTAssertNotEqual(original, CanonicalRuntimeStore.canonicalProjectionEntryDigest(changedCursor))
        XCTAssertNotEqual(original, CanonicalRuntimeStore.canonicalProjectionEntryDigest(changedPrivacy))
    }

    func testGenerationCertificateBindsInvalidationAuthorityAndShardRoot() throws {
        let definition = try XCTUnwrap(
            RuntimeCanonicalProjectionDefinitionRegistry.canonical().definitions[.search]
        )
        let cursor = makeCursor()
        let first = CanonicalRuntimeStore.canonicalProjectionGenerationCertificateDigest(
            generationID: String(repeating: "a", count: 64), projectionID: .search,
            definitionDigest: definition.authorityDigest,
            outputVersion: definition.outputVersion, sourceCursor: cursor,
            sourceChainDigest: String(repeating: "b", count: 64), entryCount: 1,
            shardCount: 1, rootDigest: String(repeating: "c", count: 64),
            privacy: EventLedgerPrivacyClassification.standard.rawValue,
            localOnly: true, invalidationDigest: String(repeating: "d", count: 64)
        )
        let changedInvalidation = CanonicalRuntimeStore.canonicalProjectionGenerationCertificateDigest(
            generationID: String(repeating: "a", count: 64), projectionID: .search,
            definitionDigest: definition.authorityDigest,
            outputVersion: definition.outputVersion, sourceCursor: cursor,
            sourceChainDigest: String(repeating: "b", count: 64), entryCount: 1,
            shardCount: 1, rootDigest: String(repeating: "c", count: 64),
            privacy: EventLedgerPrivacyClassification.standard.rawValue,
            localOnly: true, invalidationDigest: String(repeating: "e", count: 64)
        )
        XCTAssertNotEqual(first, changedInvalidation)
        let scrubWithoutShard = CanonicalRuntimeStore.canonicalScrubCertificateDigest(
            generationID: String(repeating: "a", count: 64), kind: "projection",
            projectionID: RuntimeCanonicalProjectionID.search.rawValue,
            generationCertificate: first, observedCount: 1, observedShardCount: 0,
            observedPostingCount: 0, observedPostingBytes: 0,
            rootDigest: String(repeating: "c", count: 64),
            completedAtMilliseconds: 1
        )
        let scrubWithShard = CanonicalRuntimeStore.canonicalScrubCertificateDigest(
            generationID: String(repeating: "a", count: 64), kind: "projection",
            projectionID: RuntimeCanonicalProjectionID.search.rawValue,
            generationCertificate: first, observedCount: 1, observedShardCount: 1,
            observedPostingCount: 0, observedPostingBytes: 0,
            rootDigest: String(repeating: "c", count: 64),
            completedAtMilliseconds: 1
        )
        XCTAssertNotEqual(scrubWithoutShard, scrubWithShard)
    }

    func testTruthStatesCarryGenerationAuthorityInsteadOfSnapshotBytes() throws {
        let authority = RuntimeCanonicalGenerationAuthority(
            projectionID: .search, generationID: String(repeating: "a", count: 64),
            definitionDigest: String(repeating: "b", count: 64), outputVersion: 1,
            sourceCursor: makeCursor(), sourceChainDigest: String(repeating: "c", count: 64),
            entryCount: 0, entryRootDigest: String(repeating: "d", count: 64),
            privacyClasses: [], localOnly: true,
            certificateDigest: String(repeating: "e", count: 64),
            fingerprint: String(repeating: "f", count: 64)
        )
        for state in RuntimeCanonicalProjectionHealth.allCases {
            let readable = state == .available || state == .stale
                || state == .rebuilding || state == .blocked
            let truth = RuntimeCanonicalProjectionTruth(
                state: state, authority: readable ? authority : nil,
                expectedDefinitionVersion: 1,
                sourceCursor: readable ? authority.sourceCursor : nil,
                digest: readable ? authority.certificateDigest : nil,
                repairEligible: false,
                reasonCode: state.rawValue
            )
            XCTAssertEqual(truth.authority != nil, readable)
            XCTAssertFalse(truth.repairEligible)
        }
    }

    func testV5SchemaOwnsShardedGenerationsMaintenanceAndRecoveryFences() {
        XCTAssertEqual(CanonicalRuntimeProjectionSchemaPlan.sourceSchemaVersion, 4)
        XCTAssertEqual(CanonicalRuntimeProjectionSchemaPlan.targetSchemaVersion, 5)
        let sql = CanonicalRuntimeProjectionSchemaPlan.statements.joined(separator: "\n")
        for table in CanonicalRuntimeProjectionSchemaPlan.tables {
            XCTAssertTrue(sql.contains(table), table)
        }
        XCTAssertTrue(sql.contains("runtime_canonical_projection_shards"))
        XCTAssertTrue(sql.contains("runtime_canonical_search_postings"))
        XCTAssertTrue(sql.contains("runtime_canonical_generation_scrub_jobs"))
        XCTAssertTrue(sql.contains("runtime_canonical_generation_gc_jobs"))
        XCTAssertTrue(sql.contains("runtime_canonical_build_cleanup_jobs"))
        XCTAssertTrue(sql.contains("runtime_canonical_scrub_certificates"))
        XCTAssertTrue(sql.contains("runtime_canonical_repair_requirements"))
        XCTAssertTrue(sql.contains("runtime_canonical_repair_incidents"))
        XCTAssertTrue(sql.contains("observed_shard_count"))
        XCTAssertTrue(sql.contains("base_scrub_certificate_digest"))
        XCTAssertTrue(sql.contains("service_ticket"))
        XCTAssertEqual(
            sql.components(separatedBy:
                "service_ticket INTEGER NOT NULL CHECK (service_ticket > 0)"
            ).count - 1,
            3
        )
        XCTAssertTrue(sql.contains("SELECT next_service_ticket - 1"))
        XCTAssertTrue(sql.contains("runtime_canonical_projection_jobs_valid_insert"))
        XCTAssertTrue(sql.contains("runtime_canonical_generation_gc_jobs_fenced_delete"))
        XCTAssertTrue(sql.contains("runtime_canonical_build_cleanup_jobs_fenced_delete"))
        XCTAssertTrue(sql.contains("observed_posting_bytes"))
        XCTAssertTrue(sql.contains("phase = 'recovering'"))
        XCTAssertTrue(sql.contains("active projection authority cannot be deleted"))
        XCTAssertTrue(sql.contains("immutable projection invalidation acknowledgement"))
        XCTAssertFalse(sql.contains("runtime_canonical_projection_candidates"))
        XCTAssertFalse(sql.contains("CREATE VIRTUAL TABLE"))
        XCTAssertFalse(sql.contains(" DEFAULT "))
    }

    func testWorkerAndMaintenanceUnitsHaveExplicitBoundsAndOutcomes() {
        XCTAssertEqual(RuntimeCanonicalProjectionWorker.maximumInvalidationBatch, 64)
        XCTAssertEqual(RuntimeCanonicalProjectionWorker.maximumRowsPerUnit, 128)
        XCTAssertEqual(RuntimeCanonicalProjectionWorker.maximumBytesPerUnit, 2_097_152)
        XCTAssertEqual(RuntimeCanonicalProjectionPersistenceError.derivedArtifactCorrupt,
                       .derivedArtifactCorrupt)
        XCTAssertEqual(RuntimeCanonicalGenerationMaintenanceOutcome.idle, .idle)
        XCTAssertTrue(RuntimeCanonicalProjectionWorker.isCanonicalSQLiteCorruption(
            .canonicalSQLiteFailure(operation: "read", code: 11, extendedCode: 11)
        ))
        XCTAssertFalse(RuntimeCanonicalProjectionWorker.isCanonicalSQLiteCorruption(
            .canonicalSQLiteFailure(operation: "read", code: 5, extendedCode: 5)
        ))
    }

    func testFrozenV4CatalogRemainsValidMigrationInput() async throws {
        let database = try SQLiteDatabase(
            url: temporaryDatabaseURL("frozen-v4")
        )
        try await database.transaction(.exclusive) { isolated in
            for statement in RuntimeCanonicalV4CatalogSnapshot.statements {
                try isolated.execute(statement)
            }
            try isolated.execute("PRAGMA user_version = 4")
            try CanonicalRuntimeReplaySchemaPlan.requireIntegratedSchema(in: isolated)
            let expectedTables: Set<String> = [
                "runtime_store_metadata", "runtime_aggregates", "runtime_events",
                "runtime_command_idempotency", "runtime_receipts",
                "runtime_projection_checkpoints", "runtime_projection_invalidations",
                "runtime_external_operations", "runtime_blob_records",
                "runtime_blob_references", "runtime_tombstones",
                "runtime_semantic_events", "runtime_semantic_event_quarantine",
                "runtime_commit_receipts", "runtime_commit_projection_invalidations",
                "runtime_pending_external_operations", "runtime_confirmation_consumptions",
                "runtime_commit_tombstones", "runtime_replay_checkpoints",
                "runtime_replay_checkpoint_aggregates",
                "runtime_replay_checkpoint_tombstones", "runtime_replay_retention_holds",
                "runtime_replay_quarantine_occurrences", "runtime_replay_verified_high_water",
                "runtime_replay_verified_reconstructions",
            ]
            let expectedIndexes: Set<String> = [
                "runtime_events_command_sequence_idx",
                "runtime_events_aggregate_sequence_idx",
                "runtime_events_correlation_sequence_idx",
                "runtime_projection_invalidations_projection_id_idx",
                "runtime_external_operations_retry_idx",
                "runtime_blob_references_owner_idx",
                "runtime_tombstones_causal_object_idx",
                "runtime_semantic_events_command_sequence_idx",
                "runtime_semantic_events_aggregate_sequence_idx",
                "runtime_semantic_events_correlation_sequence_idx",
                "runtime_semantic_event_quarantine_sequence_idx",
                "runtime_commit_projection_invalidations_projection_idx",
                "runtime_pending_external_operations_status_idx",
                "runtime_commit_tombstones_event_idx",
                "runtime_replay_checkpoints_sequence_idx",
                "runtime_replay_checkpoint_aggregates_order_idx",
                "runtime_replay_checkpoint_tombstones_order_idx",
                "runtime_replay_retention_holds_sequence_idx",
                "runtime_replay_quarantine_occurrences_source_idx",
                "runtime_replay_verified_reconstructions_digest_idx",
            ]
            let tableRows = try isolated.query(
                "SELECT name FROM sqlite_schema WHERE type = 'table' AND name LIKE 'runtime_%'"
            )
            let indexRows = try isolated.query(
                "SELECT name FROM sqlite_schema WHERE type = 'index' AND name LIKE 'runtime_%'"
            )
            let tables = try Set(tableRows.map { row -> String in
                guard case let .text(name)? = row.value(named: "name") else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
                return name
            })
            let indexes = try Set(indexRows.map { row -> String in
                guard case let .text(name)? = row.value(named: "name") else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
                return name
            })
            XCTAssertEqual(tables, expectedTables)
            XCTAssertEqual(indexes, expectedIndexes)
        }
        XCTAssertFalse(
            CanonicalRuntimeCommitSchemaPlan.statements.joined(separator: "\n")
                .contains("runtime_commit_projection_invalidations_lineage_idx")
        )
    }

    func testV5CatalogAndPersistedEmptyAuthorityAuthenticateInDatabase() async throws {
        let database = try SQLiteDatabase(
            url: temporaryDatabaseURL("empty-v5")
        )
        try await database.transaction(.exclusive) { isolated in
            for statement in CanonicalRuntimeStore.schemaStatements +
                CanonicalRuntimeProjectionSchemaPlan.stagedIntegratedStatements {
                try isolated.execute(statement)
            }
            try isolated.execute("PRAGMA user_version = 5")
            try CanonicalRuntimeProjectionSchemaPlan.requireIntegratedSchema(in: isolated)
            let definition = try XCTUnwrap(
                RuntimeCanonicalProjectionDefinitionRegistry.canonical()
                    .definitions[.aggregateState]
            )
            let cursor = RuntimeCanonicalReplayCursor.emptySource
            let empty = RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
            let invalidationDigest = RuntimeTransactionDigest.digest([])
            let generationID = RuntimeTransactionDigest.digest([
                "runtime.projection.empty-generation.v1", definition.id.rawValue,
                definition.authorityDigest, String(definition.outputVersion), empty,
            ])
            let certificate = CanonicalRuntimeStore
                .canonicalProjectionGenerationCertificateDigest(
                    generationID: generationID, projectionID: definition.id,
                    definitionDigest: definition.authorityDigest,
                    outputVersion: definition.outputVersion, sourceCursor: cursor,
                    sourceChainDigest: empty, entryCount: 0, shardCount: 0,
                    rootDigest: empty, privacy: "", localOnly: true,
                    invalidationDigest: invalidationDigest
                )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_projection_generations VALUES (
                    ?, ?, 1, ?, 1, 0, ?, ?, ?, 'runtime.empty-source',
                    'runtime.empty-source', ?, 0, 0, ?, '', 1, 'published', ?, 1, 1
                )
                """,
                bindings: [
                    .text(generationID), .text(definition.id.rawValue),
                    .text(definition.authorityDigest), .text(cursor.eventID),
                    .text(cursor.eventHash), .text(empty), .text(invalidationDigest),
                    .text(empty), .text(certificate),
                ]
            )
            try isolated.execute(
                "INSERT INTO runtime_canonical_projection_active_generations VALUES (?, ?, ?, 1)",
                bindings: [
                    .text(definition.id.rawValue), .text(generationID), .text(certificate),
                ]
            )
            let authority = try CanonicalRuntimeStore.requireCanonicalProjectionAuthority(
                definition: definition, requireNoPendingInvalidations: true,
                requireAtVerifiedHighWater: true, database: isolated
            )
            XCTAssertEqual(authority.sourceCursor, .emptySource)
            XCTAssertEqual(authority.entryCount, 0)
            let indexes = try isolated.query(
                """
                SELECT name FROM sqlite_schema WHERE type = 'index' AND name IN (
                    'runtime_commit_projection_invalidations_lineage_idx',
                    'runtime_semantic_events_payload_version_idx',
                    'runtime_canonical_projection_entries_order_idx',
                    'runtime_canonical_search_postings_document_idx',
                    'runtime_canonical_generation_gc_jobs_eligibility_idx',
                    'runtime_canonical_generation_scrub_jobs_eligibility_idx'
                ) ORDER BY name
                """
            )
            XCTAssertEqual(indexes.count, 6)
        }
    }

    func testActivationPublishesCapturedPrefixWhileLaterAppendRemainsPending() async throws {
        let database = try await makeV5Database("prefix-publication")
        let definition = try projectionDefinition(.aggregateState)
        let fixture = try await seedActivationFixture(
            definition: definition, capturedCount: 64, totalCount: 65,
            entries: [], database: database
        )
        try await database.transaction(.immediate) { isolated in
            try CanonicalRuntimeStore.activateCanonicalProjectionGenerationInTransaction(
                fixture.work, nowMilliseconds: 200, database: isolated
            )
            let authority = try CanonicalRuntimeStore.requireCanonicalProjectionAuthority(
                definition: definition, requireNoPendingInvalidations: false,
                requireAtVerifiedHighWater: false, database: isolated
            )
            XCTAssertEqual(authority.sourceCursor.sequence, 64)
            XCTAssertTrue(try CanonicalRuntimeStore.hasPendingCanonicalInvalidation(
                projectionID: definition.id, database: isolated
            ))
            let acks = try isolated.query(
                "SELECT invalidation_id FROM runtime_canonical_projection_invalidation_acks WHERE projection_id = ? ORDER BY invalidation_id",
                bindings: [.text(definition.id.rawValue)]
            )
            XCTAssertEqual(acks.count, 64)
            XCTAssertThrowsError(
                try CanonicalRuntimeStore.requireCanonicalProjectionAuthority(
                    definition: definition, requireNoPendingInvalidations: true,
                    requireAtVerifiedHighWater: false, database: isolated
                )
            )
            XCTAssertThrowsError(try isolated.execute(
                """
                INSERT INTO runtime_canonical_projection_invalidation_acks VALUES (?, ?, ?, 64, ?, 201)
                """,
                bindings: [
                    .text(definition.id.rawValue),
                    .text("invalidation.65.\(definition.id.rawValue)"),
                    .text(fixture.work.generationID),
                    .text(authority.certificateDigest),
                ]
            ))
        }
    }

    func testCompatibleBaseRejectsDefinitionMismatchAndScrubQuarantine() async throws {
        let database = try await makeV5Database("base-compatibility")
        let definition = try projectionDefinition(.aggregateState)
        let fixture = try await seedActivationFixture(
            definition: definition, capturedCount: 1, totalCount: 1,
            entries: [], database: database
        )
        try await database.transaction(.immediate) { isolated in
            try CanonicalRuntimeStore.activateCanonicalProjectionGenerationInTransaction(
                fixture.work, nowMilliseconds: 20, database: isolated
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "scrub-worker", nowMilliseconds: 21,
                    rowLimit: 128, database: isolated
                ),
                .completed(
                    generationID: fixture.work.generationID, kind: "projection"
                )
            )
            XCTAssertTrue(try CanonicalRuntimeStore.hasCompatibleCanonicalProjectionBase(
                definition: definition, database: isolated
            ))
            let binding = try XCTUnwrap(try CanonicalRuntimeStore
                .compatibleCanonicalProjectionBase(definition: definition, database: isolated))
            let cloneWork = replacingWork(
                fixture.work, phase: .clone,
                baseGenerationID: binding.generationID,
                baseCertificate: binding.certificateDigest,
                baseRoot: binding.rootDigest, baseEntryCount: binding.entryCount,
                baseScrubCertificate: binding.scrubCertificateDigest,
                baseScrubCompletedAt: binding.scrubCompletedAtMilliseconds
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.requireCanonicalCloneBase(
                    cloneWork, database: isolated
                ).generationID,
                binding.generationID
            )
            let forgedDigest = replacingWork(
                cloneWork, phase: .clone,
                baseGenerationID: binding.generationID,
                baseCertificate: binding.certificateDigest,
                baseRoot: binding.rootDigest, baseEntryCount: binding.entryCount,
                baseScrubCertificate: String(repeating: "f", count: 64),
                baseScrubCompletedAt: binding.scrubCompletedAtMilliseconds
            )
            XCTAssertThrowsError(try CanonicalRuntimeStore.requireCanonicalCloneBase(
                forgedDigest, database: isolated
            )) {
                XCTAssertEqual(
                    $0 as? RuntimeCanonicalProjectionPersistenceError,
                    .derivedArtifactCorrupt
                )
            }
            let staleCompletion = replacingWork(
                cloneWork, phase: .clone,
                baseGenerationID: binding.generationID,
                baseCertificate: binding.certificateDigest,
                baseRoot: binding.rootDigest, baseEntryCount: binding.entryCount,
                baseScrubCertificate: binding.scrubCertificateDigest,
                baseScrubCompletedAt: binding.scrubCompletedAtMilliseconds + 1
            )
            XCTAssertThrowsError(try CanonicalRuntimeStore.requireCanonicalCloneBase(
                staleCompletion, database: isolated
            ))
            let incompatible = RuntimeCanonicalProjectionDefinition(
                id: definition.id, definitionVersion: definition.definitionVersion,
                outputVersion: definition.outputVersion + 1,
                inputEventTypes: Array(definition.inputEventTypes),
                stableOrdering: definition.stableOrdering,
                allowedSearchFields: definition.allowedSearchFields,
                allowedPrivacyClasses: definition.allowedPrivacyClasses,
                requiresLocalOnlySource: definition.requiresLocalOnlySource
            )
            XCTAssertFalse(try CanonicalRuntimeStore.hasCompatibleCanonicalProjectionBase(
                definition: incompatible, database: isolated
            ))
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_projection_quarantine VALUES (
                    ?, ?, ?, 'projection', 'shard-0', ?, 'scrub_authority_mismatch', 21
                )
                """,
                bindings: [
                    .text(RuntimeTransactionDigest.digest(["base-quarantine"])),
                    .text(definition.id.rawValue), .text(fixture.work.generationID),
                    .text(RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal),
                ]
            )
            XCTAssertFalse(try CanonicalRuntimeStore.hasCompatibleCanonicalProjectionBase(
                definition: definition, database: isolated
            ))
        }
    }

    func testFirstMutationRetainsScrubCertifiedHistoricalEmptyBaseForClone() async throws {
        let database = try await makeV5Database("empty-base-clone")
        let definition = try projectionDefinition(.aggregateState)
        let empty = RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
        let emptyGenerationID = RuntimeTransactionDigest.digest([
            "historical-empty-base", definition.id.rawValue,
        ])
        let invalidationDigest = RuntimeTransactionDigest.digest([])
        let emptyCertificate = CanonicalRuntimeStore
            .canonicalProjectionGenerationCertificateDigest(
                generationID: emptyGenerationID, projectionID: definition.id,
                definitionDigest: definition.authorityDigest,
                outputVersion: definition.outputVersion, sourceCursor: .emptySource,
                sourceChainDigest: empty, entryCount: 0, shardCount: 0,
                rootDigest: empty, privacy: "", localOnly: true,
                invalidationDigest: invalidationDigest
            )
        let scrubDigest = CanonicalRuntimeStore.canonicalScrubCertificateDigest(
            generationID: emptyGenerationID, kind: "projection",
            projectionID: definition.id.rawValue,
            generationCertificate: emptyCertificate, observedCount: 0,
            observedShardCount: 0, observedPostingCount: 0,
            observedPostingBytes: 0, rootDigest: empty,
            completedAtMilliseconds: 0
        )
        try await database.transaction(.immediate) { isolated in
            try insertProjectionGeneration(
                generationID: emptyGenerationID, definition: definition,
                cursor: .emptySource, sourceDigest: empty,
                invalidationIDs: ["runtime.empty-source"],
                invalidationDigest: invalidationDigest, entryCount: 0, shardCount: 0,
                rootDigest: empty, status: "published",
                certificate: emptyCertificate, database: isolated
            )
            try isolated.execute(
                "INSERT INTO runtime_canonical_projection_active_generations VALUES (?, ?, ?, 0)",
                bindings: [
                    .text(definition.id.rawValue), .text(emptyGenerationID),
                    .text(emptyCertificate),
                ]
            )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_scrub_certificates VALUES (
                    ?, 'projection', ?, ?, 0, 0, 0, 0, ?, 0, ?
                )
                """,
                bindings: [
                    .text(emptyGenerationID), .text(definition.id.rawValue),
                    .text(emptyCertificate), .text(empty), .text(scrubDigest),
                ]
            )
        }
        let firstMutation = try await seedActivationFixture(
            definition: definition, capturedCount: 1, totalCount: 1,
            entries: [], database: database
        )
        try await database.transaction(.deferred) { isolated in
            XCTAssertTrue(try CanonicalRuntimeStore.hasPendingCanonicalInvalidation(
                projectionID: definition.id, database: isolated
            ))
            let base = try XCTUnwrap(try CanonicalRuntimeStore
                .compatibleCanonicalProjectionBase(definition: definition, database: isolated))
            XCTAssertEqual(base.generationID, emptyGenerationID)
            XCTAssertEqual(base.entryCount, 0)
            XCTAssertEqual(
                CanonicalRuntimeStore.initialCanonicalProjectionBuildPhase(base: base), .clone
            )
            let cloneWork = replacingWork(
                firstMutation.work, phase: .clone,
                baseGenerationID: base.generationID,
                baseCertificate: base.certificateDigest,
                baseRoot: base.rootDigest, baseEntryCount: base.entryCount,
                baseScrubCertificate: base.scrubCertificateDigest,
                baseScrubCompletedAt: base.scrubCompletedAtMilliseconds
            )
            XCTAssertEqual(try CanonicalRuntimeStore.requireCanonicalCloneBase(
                cloneWork, database: isolated
            ).sourceCursor, .emptySource)
        }
    }

    func testBlockedJobIsExcludedAndTruthFailsClosed() async throws {
        let database = try await makeV5Database("blocked-job")
        let definition = try projectionDefinition(.aggregateState)
        let fixture = try await seedActivationFixture(
            definition: definition, capturedCount: 1, totalCount: 1,
            entries: [], database: database, phase: .blocked,
            blockedReason: "historical_privacy_missing"
        )
        try await database.transaction(.deferred) { isolated in
            XCTAssertNil(try CanonicalRuntimeStore.nextCanonicalProjectionID(database: isolated))
            let truth = try XCTUnwrap(CanonicalRuntimeStore.canonicalProjectionJobTruth(
                projectionID: definition.id,
                expectedDefinitionVersion: definition.definitionVersion,
                database: isolated
            ))
            XCTAssertEqual(truth.state, .blocked)
            XCTAssertNil(truth.authority)
            XCTAssertFalse(truth.repairEligible)
            XCTAssertEqual(truth.reasonCode, "historical_privacy_missing")
            let rows = try isolated.query(
                "SELECT phase FROM runtime_canonical_projection_jobs WHERE generation_id = ?",
                bindings: [.text(fixture.work.generationID)]
            )
            XCTAssertEqual(rows.first?.value(named: "phase"), .text("blocked"))
        }
    }

    func testHistoricalPrivacyBlockNamesExactEventAndPayloadVersion() {
        XCTAssertEqual(
            RuntimeCanonicalProjectionWorker.blockReason(for: .blockedHistoricalPrivacy(
                eventID: "event-v2", payloadVersion: 2
            )),
            "historical_privacy_missing:event-v2:v2"
        )
        XCTAssertNotEqual(
            RuntimeCanonicalProjectionWorker.blockReason(for: .blockedHistoricalPrivacy(
                eventID: "event-v1", payloadVersion: 1
            )),
            RuntimeCanonicalProjectionWorker.blockReason(for: .unsupportedSource)
        )
    }

    func testBlockedBuildCanBeAuthenticatedIntoBoundedCleanup() async throws {
        let database = try await makeV5Database("blocked-retirement")
        let definition = try projectionDefinition(.aggregateState)
        let fixture = try await seedActivationFixture(
            definition: definition, capturedCount: 1, totalCount: 1,
            entries: [], database: database, phase: .blocked,
            blockedReason: "source_version_unsupported"
        )
        try await database.transaction(.immediate) { isolated in
            try CanonicalRuntimeStore.recordCanonicalRepairRequirement(
                projectionID: definition.id.rawValue,
                generationID: fixture.work.generationID, authorityKind: "build",
                reasonCode: "source_version_unsupported", sourceCertificate: nil,
                nowMilliseconds: 10, database: isolated
            )
        }
        try await database.transaction(.immediate) { isolated in
            try CanonicalRuntimeStore.retireBlockedCanonicalProjectionBuildInTransaction(
                projectionID: definition.id,
                expectedGenerationID: fixture.work.generationID,
                expectedReasonCode: "source_version_unsupported",
                ownerID: "worker", nowMilliseconds: 20, database: isolated
            )
        }
        try await database.transaction(.deferred) { isolated in
            XCTAssertEqual(
                try isolated.query(
                    "SELECT status FROM runtime_canonical_projection_generations WHERE generation_id = ?",
                    bindings: [.text(fixture.work.generationID)]
                ).first?.value(named: "status"), .text("abandoned")
            )
            XCTAssertEqual(
                try isolated.query(
                    "SELECT phase FROM runtime_canonical_build_cleanup_jobs WHERE generation_id = ?",
                    bindings: [.text(fixture.work.generationID)]
                ).first?.value(named: "phase"), .text("projection_entries")
            )
        }
    }

    func testTargetRecoveryDoesNotPoisonBoundBaseAndSealedAbandonRequiresFence() async throws {
        let database = try await makeV5Database("repair-provenance")
        let definition = try projectionDefinition(.aggregateState)
        let fixture = try await seedActivationFixture(
            definition: definition, capturedCount: 1, totalCount: 1,
            entries: [], database: database
        )
        try await database.transaction(.immediate) { isolated in
            XCTAssertThrowsError(try isolated.execute(
                """
                UPDATE runtime_canonical_projection_generations
                SET status = 'abandoned', generation_certificate_digest = NULL
                WHERE generation_id = ?
                """,
                bindings: [.text(fixture.work.generationID)]
            ))
        }
        let work = replacingBase(
            fixture.work, generationID: String(repeating: "f", count: 64),
            certificate: String(repeating: "e", count: 64),
            root: RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal,
            entryCount: 0
        )
        XCTAssertEqual(
            RuntimeCanonicalProjectionWorker.recoveryScopeForDerivedArtifact(work),
            .projection
        )
        let cloneWork = replacingPhase(work, phase: .clone)
        XCTAssertEqual(
            RuntimeCanonicalProjectionWorker.recoveryScopeForDerivedArtifact(cloneWork),
            .baseProjection
        )
    }

    func testUnavailableCloneBaseCreatesRepairAndBoundedTargetCleanupBeforeFullReplay() async throws {
        let database = try await makeV5Database("clone-base-recovery")
        let definition = try projectionDefinition(.aggregateState)
        let fixture = try await seedActivationFixture(
            definition: definition, capturedCount: 1, totalCount: 1,
            entries: [], database: database
        )
        let empty = RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
        try await database.transaction(.immediate) { isolated in
            try CanonicalRuntimeStore.activateCanonicalProjectionGenerationInTransaction(
                fixture.work, nowMilliseconds: 20, database: isolated
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "base-scrub", nowMilliseconds: 21,
                    rowLimit: 128, database: isolated
                ),
                .completed(generationID: fixture.work.generationID, kind: "projection")
            )
            let base = try XCTUnwrap(try CanonicalRuntimeStore
                .compatibleCanonicalProjectionBase(definition: definition, database: isolated))
            let targetID = RuntimeTransactionDigest.digest(["clone-recovery-target"])
            let invalidationID = "invalidation.clone-recovery"
            let invalidationDigest = RuntimeTransactionDigest.digest([
                invalidationID, String(fixture.work.targetCursor.sequence),
                fixture.work.targetCursor.eventID, fixture.work.targetCursor.eventHash,
            ])
            try insertProjectionGeneration(
                generationID: targetID, definition: definition,
                cursor: fixture.work.targetCursor,
                sourceDigest: fixture.work.sourceChainDigest,
                invalidationIDs: [invalidationID], invalidationDigest: invalidationDigest,
                entryCount: 0, shardCount: 0, rootDigest: empty,
                status: "building", certificate: nil, database: isolated
            )
            try isolated.execute(
                "INSERT INTO runtime_canonical_projection_leases VALUES (?, 'recovery-worker', 1, 30000)",
                bindings: [.text(definition.id.rawValue)]
            )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_projection_jobs(
                    projection_id, generation_id, phase, blocked_reason_code,
                    base_generation_id, base_certificate_digest, base_root_digest,
                    base_entry_count, base_scrub_certificate_digest,
                    base_scrub_completed_at_ms,
                    target_sequence, target_event_id, target_event_hash,
                    progress_sequence, progress_event_id, progress_event_hash,
                    progress_source_digest, after_aggregate_kind, after_aggregate_id,
                    shard_ordinal, rolling_root_digest, entry_count, sealed_entry_count,
                    privacy_standard_count, privacy_sensitive_count,
                    privacy_private_text_count, privacy_calendar_count,
                    privacy_sync_count, nonlocal_entry_count,
                    search_document_count, sealed_search_document_count,
                    search_posting_count, search_posting_bytes,
                    first_invalidation_id, last_invalidation_id, invalidation_digest,
                    owner_id, fence_version, service_ticket, updated_at_ms
                ) VALUES (?, ?, 'clone', NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                          0, NULL, NULL, ?, '', '', 0, ?,
                          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                          ?, ?, ?, 'recovery-worker', 1, 1, 22)
                """,
                bindings: [
                    .text(definition.id.rawValue), .text(targetID),
                    .text(base.generationID), .text(base.certificateDigest),
                    .text(base.rootDigest), .integer(Int64(base.entryCount)),
                    .text(base.scrubCertificateDigest),
                    .integer(base.scrubCompletedAtMilliseconds),
                    .integer(Int64(fixture.work.targetCursor.sequence)),
                    .text(fixture.work.targetCursor.eventID),
                    .text(fixture.work.targetCursor.eventHash), .text(empty), .text(empty),
                    .text(invalidationID), .text(invalidationID), .text(invalidationDigest),
                ]
            )
            let cloneWork = RuntimeCanonicalProjectionBuildWork(
                projectionID: definition.id, generationID: targetID,
                definition: definition, phase: .clone,
                targetCursor: fixture.work.targetCursor, progressCursor: nil,
                sourceChainDigest: fixture.work.sourceChainDigest,
                progressSourceDigest: empty, afterAggregateKind: "", afterAggregateID: "",
                shardOrdinal: 0, rollingRootDigest: empty,
                invalidationIDs: [invalidationID], invalidationDigest: invalidationDigest,
                lease: RuntimeCanonicalProjectionLease(
                    projectionID: definition.id, ownerID: "recovery-worker", version: 1,
                    expiresAtMilliseconds: 30_000
                ), operationNowMilliseconds: 22, blockedReasonCode: nil,
                baseGenerationID: base.generationID,
                baseCertificateDigest: base.certificateDigest,
                baseRootDigest: base.rootDigest, baseEntryCount: base.entryCount,
                baseScrubCertificateDigest: base.scrubCertificateDigest,
                baseScrubCompletedAtMilliseconds: base.scrubCompletedAtMilliseconds,
                entryCount: 0, sealedEntryCount: 0, privacyCounts: [:],
                nonlocalEntryCount: 0, searchDocumentCount: 0,
                sealedSearchDocumentCount: 0, searchPostingCount: 0,
                searchPostingBytes: 0
            )
            for health in [RuntimeCanonicalProjectionHealth.corrupt, .blocked] {
                XCTAssertEqual(
                    RuntimeCanonicalProjectionWorker.recoveryScopeForProjectionUnavailable(
                        health, work: cloneWork
                    ),
                    .baseProjection
                )
            }
            XCTAssertNil(RuntimeCanonicalProjectionWorker
                .recoveryScopeForProjectionUnavailable(.stale, work: cloneWork))
            try CanonicalRuntimeStore.quarantineAndRestartCanonicalProjectionBuildInTransaction(
                cloneWork, scope: .baseProjection,
                nowMilliseconds: 23, database: isolated
            )
            XCTAssertEqual(try isolated.query(
                "SELECT state FROM runtime_canonical_repair_requirements WHERE generation_id = ? AND reason_code = 'derived_base_authority_mismatch'",
                bindings: [.text(base.generationID)]
            ).first?.value(named: "state"), .text("required"))
            XCTAssertEqual(try isolated.query(
                "SELECT status FROM runtime_canonical_projection_generations WHERE generation_id = ?",
                bindings: [.text(targetID)]
            ).first?.value(named: "status"), .text("abandoned"))
            XCTAssertEqual(try isolated.query(
                "SELECT phase FROM runtime_canonical_build_cleanup_jobs WHERE generation_id = ?",
                bindings: [.text(targetID)]
            ).first?.value(named: "phase"), .text("projection_entries"))
            XCTAssertNil(try CanonicalRuntimeStore.compatibleCanonicalProjectionBase(
                definition: definition, database: isolated
            ))
            XCTAssertEqual(
                CanonicalRuntimeStore.initialCanonicalProjectionBuildPhase(base: nil), .replay
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "cleanup", nowMilliseconds: 24,
                    rowLimit: 128, database: isolated
                ),
                .progressed(generationID: targetID, kind: "cleanup", phase: "projection_shards")
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "cleanup", nowMilliseconds: 25,
                    rowLimit: 128, database: isolated
                ),
                .progressed(generationID: targetID, kind: "cleanup", phase: "projection_header")
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "cleanup", nowMilliseconds: 26,
                    rowLimit: 128, database: isolated
                ),
                .completed(generationID: targetID, kind: "cleanup")
            )
            XCTAssertTrue(try isolated.query(
                "SELECT 1 FROM runtime_canonical_projection_generations WHERE generation_id = ?",
                bindings: [.text(targetID)]
            ).isEmpty)
        }
    }

    func testProjectionScrubAuthenticatesPrivacyAndLocalSummary() async throws {
        let database = try await makeV5Database("projection-scrub-summary")
        let definition = try projectionDefinition(.aggregateState)
        let entry = try makeEntry(
            id: "goal-private", privacy: .privateUserText, cursor: fixtureCursor(1)
        )
        let fixture = try await seedActivationFixture(
            definition: definition, capturedCount: 1, totalCount: 1,
            entries: [entry], database: database
        )
        try await database.transaction(.immediate) { isolated in
            try CanonicalRuntimeStore.activateCanonicalProjectionGenerationInTransaction(
                fixture.work, nowMilliseconds: 20, database: isolated
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "scrub", nowMilliseconds: 21, rowLimit: 128, database: isolated
                ),
                .progressed(
                    generationID: fixture.work.generationID,
                    kind: "projection", phase: "shards"
                )
            )
            let progress = try isolated.query(
                """
                SELECT observed_count, observed_privacy_private_text_count,
                       observed_nonlocal_count
                FROM runtime_canonical_generation_scrub_jobs WHERE generation_id = ?
                """,
                bindings: [.text(fixture.work.generationID)]
            )
            XCTAssertEqual(progress.first?.value(named: "observed_count"), .integer(1))
            XCTAssertEqual(
                progress.first?.value(named: "observed_privacy_private_text_count"), .integer(1)
            )
            XCTAssertEqual(progress.first?.value(named: "observed_nonlocal_count"), .integer(0))
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "scrub", nowMilliseconds: 22, rowLimit: 128, database: isolated
                ),
                .completed(generationID: fixture.work.generationID, kind: "projection")
            )
            XCTAssertEqual(try isolated.query(
                "SELECT observed_shard_count FROM runtime_canonical_scrub_certificates WHERE generation_id = ?",
                bindings: [.text(fixture.work.generationID)]
            ).first?.value(named: "observed_shard_count"), .integer(1))
        }
    }

    func testProjectionScrubDefersUndersizedConfigurationBeforeClaim() async throws {
        let database = try await makeV5Database("projection-scrub-budget")
        let definition = try projectionDefinition(.aggregateState)
        let entries = try [
            makeEntry(id: "goal-a", privacy: .standard, cursor: fixtureCursor(1)),
            makeEntry(id: "goal-b", privacy: .standard, cursor: fixtureCursor(1)),
        ]
        let fixture = try await seedActivationFixture(
            definition: definition, capturedCount: 1, totalCount: 1,
            entries: entries, database: database
        )
        try await database.transaction(.immediate) { isolated in
            try CanonicalRuntimeStore.activateCanonicalProjectionGenerationInTransaction(
                fixture.work, nowMilliseconds: 20, database: isolated
            )
            XCTAssertNil(CanonicalRuntimeStore.canonicalMaintenanceRowLimit(maximumRows: 1))
            XCTAssertEqual(
                CanonicalRuntimeStore.canonicalMaintenanceRowLimit(maximumRows: 128), 128
            )
            let before = try isolated.query(
                "SELECT owner_id, fence_version, service_ticket FROM runtime_canonical_generation_scrub_jobs"
            )
            XCTAssertEqual(before.first?.value(named: "owner_id"), .text("unclaimed"))
            XCTAssertEqual(before.first?.value(named: "fence_version"), .integer(1))
            XCTAssertEqual(before.first?.value(named: "service_ticket"), .integer(1))
            XCTAssertEqual(before.count, 1)
            let schedulerBefore = try isolated.query(
                "SELECT next_service_ticket FROM runtime_canonical_scheduler_state WHERE singleton_id = 1"
            )
            XCTAssertEqual(
                schedulerBefore.first?.value(named: "next_service_ticket"), .integer(2)
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "must-not-claim", nowMilliseconds: 21,
                    maximumRows: 1, database: isolated
                ),
                .configurationDeferred(minimumRows: 128)
            )
            let after = try isolated.query(
                "SELECT owner_id, fence_version, service_ticket FROM runtime_canonical_generation_scrub_jobs"
            )
            XCTAssertEqual(after.first?.value(named: "owner_id"), before.first?.value(named: "owner_id"))
            XCTAssertEqual(after.first?.value(named: "fence_version"), before.first?.value(named: "fence_version"))
            XCTAssertEqual(after.first?.value(named: "service_ticket"), before.first?.value(named: "service_ticket"))
            XCTAssertEqual(try isolated.query(
                "SELECT next_service_ticket FROM runtime_canonical_scheduler_state WHERE singleton_id = 1"
            ).first?.value(named: "next_service_ticket"), .integer(2))
        }
    }

    func testDurableMaintenanceAndProjectionFSMRejectsSkippedOrRegressingWrites() async throws {
        let database = try await makeV5Database("durable-fsm")
        let definition = try projectionDefinition(.aggregateState)
        let entry = try makeEntry(
            id: "goal-fsm", privacy: .standard, cursor: fixtureCursor(1)
        )
        let fixture = try await seedActivationFixture(
            definition: definition, capturedCount: 1, totalCount: 1,
            entries: [entry], database: database, phase: .sealProjection
        )
        let empty = RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
        try await database.transaction(.immediate) { isolated in
            XCTAssertThrowsError(try isolated.execute(
                "UPDATE runtime_canonical_projection_jobs SET phase = 'index_search' WHERE projection_id = ?",
                bindings: [.text(definition.id.rawValue)]
            ))
            try isolated.execute(
                "UPDATE runtime_canonical_projection_jobs SET after_aggregate_kind = 'goal', after_aggregate_id = 'z' WHERE projection_id = ?",
                bindings: [.text(definition.id.rawValue)]
            )
            XCTAssertThrowsError(try isolated.execute(
                "UPDATE runtime_canonical_projection_jobs SET after_aggregate_id = 'a' WHERE projection_id = ?",
                bindings: [.text(definition.id.rawValue)]
            ))

            try CanonicalRuntimeStore.updateCanonicalProjectionJobPhase(
                fixture.work, nextPhase: .ready, resetKeyset: true, database: isolated
            )
            try CanonicalRuntimeStore.activateCanonicalProjectionGenerationInTransaction(
                replacingPhase(fixture.work, phase: .ready),
                nowMilliseconds: 20, database: isolated
            )
            XCTAssertThrowsError(try isolated.execute(
                "UPDATE runtime_canonical_generation_scrub_jobs SET phase = 'postings' WHERE generation_id = ?",
                bindings: [.text(fixture.work.generationID)]
            ))

            let retiredID = String(repeating: "4", count: 64)
            let retiredCertificate = String(repeating: "5", count: 64)
            try insertProjectionGeneration(
                generationID: retiredID, definition: definition, cursor: .emptySource,
                sourceDigest: empty, invalidationIDs: ["runtime.empty-source"],
                invalidationDigest: RuntimeTransactionDigest.digest([]),
                entryCount: 0, shardCount: 0, rootDigest: empty,
                status: "retired", certificate: retiredCertificate, database: isolated
            )
            let invalidGCTicket = try CanonicalRuntimeStore.issueCanonicalServiceTicket(
                database: isolated
            )
            XCTAssertThrowsError(try isolated.execute(
                """
                INSERT INTO runtime_canonical_generation_gc_jobs VALUES (
                    ?, 'projection', 'header', '', '', 'unclaimed', 1, 20, ?, 20, ?
                )
                """,
                bindings: [
                    .text(retiredID), .text(retiredCertificate),
                    .integer(invalidGCTicket),
                ]
            ))

            let abandonedID = String(repeating: "6", count: 64)
            try insertProjectionGeneration(
                generationID: abandonedID, definition: definition, cursor: .emptySource,
                sourceDigest: empty, invalidationIDs: ["runtime.empty-source"],
                invalidationDigest: RuntimeTransactionDigest.digest([]),
                entryCount: 0, shardCount: 0, rootDigest: empty,
                status: "abandoned", certificate: nil, database: isolated
            )
            let invalidCleanupTicket = try CanonicalRuntimeStore.issueCanonicalServiceTicket(
                database: isolated
            )
            XCTAssertThrowsError(try isolated.execute(
                """
                INSERT INTO runtime_canonical_build_cleanup_jobs VALUES (
                    ?, ?, NULL, 'projection_header', '', '', 'forged_skip',
                    'unclaimed', 1, 20, 20, ?
                )
                """,
                bindings: [
                    .text(abandonedID), .text(definition.id.rawValue),
                    .integer(invalidCleanupTicket),
                ]
            ))
        }
    }

    func testOldBuildRepairDoesNotHideActiveAuthorityButCurrentRepairFailsClosed() async throws {
        let database = try await makeV5Database("repair-truth-scope")
        let definition = try projectionDefinition(.aggregateState)
        let fixture = try await seedActivationFixture(
            definition: definition, capturedCount: 1, totalCount: 1,
            entries: [], database: database
        )
        try await database.transaction(.immediate) { isolated in
            try CanonicalRuntimeStore.activateCanonicalProjectionGenerationInTransaction(
                fixture.work, nowMilliseconds: 20, database: isolated
            )
            try CanonicalRuntimeStore.recordCanonicalRepairRequirement(
                projectionID: definition.id.rawValue,
                generationID: String(repeating: "d", count: 64), authorityKind: "build",
                reasonCode: "old_build_failure", sourceCertificate: nil,
                nowMilliseconds: 21, database: isolated
            )
        }
        try await database.transaction(.deferred) { isolated in
            let authority = try CanonicalRuntimeStore.requireCanonicalProjectionAuthority(
                definition: definition, requireNoPendingInvalidations: false,
                requireAtVerifiedHighWater: false, database: isolated
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.canonicalProjectionReadTruth(
                    authority: authority, definition: definition, database: isolated
                ).state,
                .available
            )
        }
        try await database.transaction(.immediate) { isolated in
            try CanonicalRuntimeStore.recordCanonicalRepairRequirement(
                projectionID: definition.id.rawValue,
                generationID: fixture.work.generationID, authorityKind: "projection",
                reasonCode: "active_authority_failure", sourceCertificate: nil,
                nowMilliseconds: 22, database: isolated
            )
        }
        try await database.transaction(.deferred) { isolated in
            XCTAssertThrowsError(try CanonicalRuntimeStore.requireCanonicalProjectionAuthority(
                definition: definition, requireNoPendingInvalidations: false,
                requireAtVerifiedHighWater: false, database: isolated
            ))
        }
    }

    func testProjectionScrubQuarantinesShardGapSuffixOverlapAndHeaderMismatches() async throws {
        let definition = try projectionDefinition(.aggregateState)
        let empty = RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
        for defect in ["gap_suffix", "overlap", "header_count", "header_root"] {
            let database = try await makeV5Database("scrub-\(defect)")
            let generationID = RuntimeTransactionDigest.digest(["scrub-defect", defect])
            let first = try makeEntry(
                id: "goal-a", privacy: .standard, cursor: fixtureCursor(1)
            )
            let second = try makeEntry(
                id: "goal-b", privacy: .standard, cursor: fixtureCursor(1)
            )
            try await database.transaction(.immediate) { isolated in
                try insertProjectionGeneration(
                    generationID: generationID, definition: definition,
                    cursor: fixtureCursor(1), sourceDigest: String(repeating: "a", count: 64),
                    invalidationIDs: ["invalidation.scrub.\(defect)"],
                    invalidationDigest: RuntimeTransactionDigest.digest([defect]),
                    entryCount: 0, shardCount: 0, rootDigest: empty,
                    status: "building", certificate: nil, database: isolated
                )
                for entry in [first, second] {
                    try CanonicalRuntimeStore.insertCanonicalProjectionEntry(
                        generationID: generationID, entry: entry, database: isolated
                    )
                }
                func shardDigest(
                    ordinal: Int, prior: String,
                    entries: [RuntimeCanonicalProjectionEntry]
                ) -> String {
                    var material = [
                        "runtime.projection.shard.v1", generationID,
                        String(ordinal), prior,
                    ]
                    for entry in entries {
                        material += [
                            entry.aggregate.kind.rawValue, entry.aggregate.id.rawValue,
                            CanonicalRuntimeStore.canonicalProjectionEntryDigest(entry),
                        ]
                    }
                    return RuntimeTransactionDigest.digest(material)
                }
                func insertShard(
                    ordinal: Int, prior: String,
                    entries: [RuntimeCanonicalProjectionEntry]
                ) throws -> String {
                    let digest = shardDigest(ordinal: ordinal, prior: prior, entries: entries)
                    try isolated.execute(
                        """
                        INSERT INTO runtime_canonical_projection_shards VALUES (
                            ?, ?, ?, ?, ?, ?, ?, ?, ?
                        )
                        """,
                        bindings: [
                            .text(generationID), .integer(Int64(ordinal)),
                            .text(entries[0].aggregate.kind.rawValue),
                            .text(entries[0].aggregate.id.rawValue),
                            .text(entries[entries.count - 1].aggregate.kind.rawValue),
                            .text(entries[entries.count - 1].aggregate.id.rawValue),
                            .integer(Int64(entries.count)), .text(prior), .text(digest),
                        ]
                    )
                    return digest
                }

                let declaredEntryCount: Int
                let declaredShardCount: Int
                let declaredRoot: String
                switch defect {
                case "gap_suffix":
                    let shard0 = try insertShard(ordinal: 0, prior: empty, entries: [first])
                    declaredRoot = try insertShard(
                        ordinal: 2, prior: shard0, entries: [second]
                    )
                    declaredEntryCount = 2
                    declaredShardCount = 2
                case "overlap":
                    let shard0 = try insertShard(
                        ordinal: 0, prior: empty, entries: [first, second]
                    )
                    declaredRoot = try insertShard(
                        ordinal: 1, prior: shard0, entries: [second]
                    )
                    declaredEntryCount = 3
                    declaredShardCount = 2
                case "header_count":
                    declaredRoot = try insertShard(
                        ordinal: 0, prior: empty, entries: [first, second]
                    )
                    declaredEntryCount = 2
                    declaredShardCount = 2
                default:
                    _ = try insertShard(ordinal: 0, prior: empty, entries: [first, second])
                    declaredEntryCount = 2
                    declaredShardCount = 1
                    declaredRoot = String(repeating: "e", count: 64)
                }
                let certificate = CanonicalRuntimeStore
                    .canonicalProjectionGenerationCertificateDigest(
                        generationID: generationID, projectionID: definition.id,
                        definitionDigest: definition.authorityDigest,
                        outputVersion: definition.outputVersion,
                        sourceCursor: fixtureCursor(1),
                        sourceChainDigest: String(repeating: "a", count: 64),
                        entryCount: declaredEntryCount, shardCount: declaredShardCount,
                        rootDigest: declaredRoot, privacy: "standard", localOnly: true,
                        invalidationDigest: RuntimeTransactionDigest.digest([defect])
                    )
                try isolated.execute(
                    """
                    UPDATE runtime_canonical_projection_generations
                    SET entry_count = ?, shard_count = ?, entry_root_digest = ?,
                        privacy = 'standard', status = 'sealed',
                        generation_certificate_digest = ?, sealed_at_ms = 1
                    WHERE generation_id = ?
                    """,
                    bindings: [
                        .integer(Int64(declaredEntryCount)),
                        .integer(Int64(declaredShardCount)), .text(declaredRoot),
                        .text(certificate), .text(generationID),
                    ]
                )
                try isolated.execute(
                    "UPDATE runtime_canonical_projection_generations SET status = 'published' WHERE generation_id = ?",
                    bindings: [.text(generationID)]
                )
                try isolated.execute(
                    "INSERT INTO runtime_canonical_projection_active_generations VALUES (?, ?, ?, 1)",
                    bindings: [
                        .text(definition.id.rawValue), .text(generationID), .text(certificate),
                    ]
                )
                try CanonicalRuntimeStore.scheduleCanonicalGenerationScrub(
                    generationID: generationID, kind: "projection",
                    certificate: certificate, nowMilliseconds: 1, database: isolated
                )
                var terminal: RuntimeCanonicalGenerationMaintenanceOutcome = .idle
                for instant in 2...5 {
                    terminal = try CanonicalRuntimeStore
                        .runOneCanonicalGenerationMaintenanceUnitInTransaction(
                            ownerID: "scrub-defect", nowMilliseconds: Int64(instant),
                            rowLimit: 128, database: isolated
                        )
                    if case .quarantined = terminal { break }
                }
                XCTAssertEqual(
                    terminal, .quarantined(generationID: generationID, kind: "projection"),
                    defect
                )
                XCTAssertEqual(try isolated.query(
                    "SELECT 1 FROM runtime_canonical_repair_requirements WHERE generation_id = ? AND state = 'required'",
                    bindings: [.text(generationID)]
                ).count, 1, defect)
                XCTAssertTrue(try isolated.query(
                    "SELECT 1 FROM runtime_canonical_scrub_certificates WHERE generation_id = ?",
                    bindings: [.text(generationID)]
                ).isEmpty, defect)
            }
        }
    }

    func testRecurringRepairFailureCreatesNewRequiredOccurrenceAfterResolution() async throws {
        let database = try await makeV5Database("repair-recurrence")
        let definition = try projectionDefinition(.aggregateState)
        let generationID = String(repeating: "9", count: 64)
        try await database.transaction(.immediate) { isolated in
            try CanonicalRuntimeStore.recordCanonicalRepairRequirement(
                projectionID: definition.id.rawValue, generationID: generationID,
                authorityKind: "projection", reasonCode: "scrub_authority_mismatch",
                sourceCertificate: String(repeating: "8", count: 64),
                nowMilliseconds: 1, database: isolated
            )
            let first = try XCTUnwrap(try isolated.query(
                "SELECT requirement_id FROM runtime_canonical_repair_requirements"
            ).first)
            guard case let .text(firstID)? = first.value(named: "requirement_id") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            try isolated.execute(
                """
                UPDATE runtime_canonical_repair_requirements
                SET state = 'resolved', resolved_at_ms = 2, resolution_digest = ?
                WHERE requirement_id = ?
                """,
                bindings: [
                    .text(String(repeating: "7", count: 64)), .text(firstID),
                ]
            )
            try CanonicalRuntimeStore.recordCanonicalRepairRequirement(
                projectionID: definition.id.rawValue, generationID: generationID,
                authorityKind: "projection", reasonCode: "scrub_authority_mismatch",
                sourceCertificate: String(repeating: "8", count: 64),
                nowMilliseconds: 3, database: isolated
            )
            XCTAssertEqual(try isolated.query(
                "SELECT 1 FROM runtime_canonical_repair_requirements"
            ).count, 2)
            XCTAssertEqual(try isolated.query(
                "SELECT 1 FROM runtime_canonical_repair_requirements WHERE state = 'required'"
            ).count, 1)
        }
    }

    func testRetiredScrubCancellationAndProjectionGCDependencyArePersisted() async throws {
        let database = try await makeV5Database("maintenance-dependency")
        let definition = try projectionDefinition(.aggregateState)
        let projectionID = String(repeating: "a", count: 64)
        let searchID = String(repeating: "b", count: 64)
        let certificate = String(repeating: "c", count: 64)
        try await database.transaction(.immediate) { isolated in
            try insertProjectionGeneration(
                generationID: projectionID, definition: definition,
                cursor: .emptySource,
                sourceDigest: RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal,
                invalidationIDs: ["runtime.empty-source"],
                invalidationDigest: RuntimeTransactionDigest.digest([]),
                entryCount: 0, shardCount: 0,
                rootDigest: RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal,
                status: "published", certificate: certificate, database: isolated
            )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_projection_active_generations(
                    projection_id, generation_id, generation_certificate_digest, activated_at_ms
                ) VALUES (?, ?, ?, 0)
                """,
                bindings: [
                    .text(definition.id.rawValue), .text(projectionID), .text(certificate),
                ]
            )
            try CanonicalRuntimeStore.scheduleCanonicalGenerationScrub(
                generationID: projectionID, kind: "projection", certificate: certificate,
                nowMilliseconds: 0, database: isolated
            )
            let retiring = try isolated.query(
                "SELECT generation_id FROM runtime_canonical_generation_scrub_jobs"
            )
            try CanonicalRuntimeStore.retireCanonicalGenerationScrubJobs(
                rows: retiring, database: isolated
            )
            XCTAssertTrue(try isolated.query(
                "SELECT 1 FROM runtime_canonical_generation_scrub_jobs"
            ).isEmpty)
            try isolated.execute(
                "UPDATE runtime_canonical_projection_generations SET status = 'retired' WHERE generation_id = ?",
                bindings: [.text(projectionID)]
            )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_search_generations VALUES (
                    ?, ?, 'aggregate_metadata_only', ?, 0, ?, 0, 0, 0, 0, ?,
                    'building', NULL, 1
                )
                """,
                bindings: [
                    .text(searchID), .text(projectionID), .text(definition.authorityDigest),
                    .text(RuntimeCanonicalReplayCursor.emptySource.eventHash),
                    .text(RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal),
                ]
            )
            XCTAssertTrue(try CanonicalRuntimeStore
                .canonicalProjectionHasDependentSearchGeneration(
                    projectionID, database: isolated
                ))
            try CanonicalRuntimeStore.scheduleCanonicalGenerationGC(
                rows: try isolated.query(
                    "SELECT generation_id, generation_certificate_digest FROM runtime_canonical_projection_generations WHERE generation_id = ?",
                    bindings: [.text(projectionID)]
                ),
                kind: "projection", firstPhase: "entries", nowMilliseconds: 0,
                database: isolated
            )
            let outcome = try CanonicalRuntimeStore
                .runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "gc-worker", nowMilliseconds: 10, rowLimit: 8,
                    database: isolated
                )
            XCTAssertEqual(outcome, .deferred(
                generationID: projectionID, kind: "projection",
                reasonCode: "waiting_for_search_dependency"
            ))
            XCTAssertFalse(try isolated.query(
                "SELECT 1 FROM runtime_canonical_projection_generations WHERE generation_id = ?",
                bindings: [.text(projectionID)]
            ).isEmpty)
        }
    }

    func testMaintenanceSchedulerUsesEnqueueFIFOThenRotatesAheadOfLaterArrival() async throws {
        let database = try await makeV5Database("maintenance-fairness")
        let definition = try projectionDefinition(.aggregateState)
        let searchDefinition = try projectionDefinition(.search)
        let empty = RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
        let invalidationDigest = RuntimeTransactionDigest.digest([])
        let searchProjectionID = String(repeating: "e", count: 64)
        let scrubID = String(repeating: "f", count: 64)
        let cleanupID = String(repeating: "1", count: 64)
        let gcID = String(repeating: "8", count: 64)
        let laterScrubID = String(repeating: "0", count: 64)
        let gcCertificate = String(repeating: "b", count: 64)
        try await database.transaction(.immediate) { isolated in
            // Empty authorities themselves are durable certificates, not queued
            // maintenance, and therefore do not consume service tickets.
            try insertProjectionGeneration(
                generationID: searchProjectionID, definition: searchDefinition,
                cursor: .emptySource,
                sourceDigest: empty, invalidationIDs: ["runtime.empty-source"],
                invalidationDigest: invalidationDigest, entryCount: 0, shardCount: 0,
                rootDigest: empty, status: "published",
                certificate: String(repeating: "c", count: 64),
                database: isolated
            )
            let scrubCertificate = CanonicalRuntimeStore
                .canonicalSearchGenerationCertificateDigest(
                    generationID: scrubID,
                    projectionGenerationID: searchProjectionID,
                    coverage: .aggregateMetadataOnly,
                    definitionDigest: searchDefinition.authorityDigest,
                    sourceCursor: .emptySource, documentCount: 0,
                    postingCount: 0, postingBytes: 0, shardCount: 0,
                    rootDigest: empty
                )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_search_generations VALUES (
                    ?, ?, 'aggregate_metadata_only', ?, 0, ?, 0, 0, 0, 0, ?,
                    'published', ?, 10
                )
                """,
                bindings: [
                    .text(scrubID), .text(searchProjectionID),
                    .text(searchDefinition.authorityDigest),
                    .text(RuntimeCanonicalReplayCursor.emptySource.eventHash),
                    .text(empty), .text(scrubCertificate),
                ]
            )
            try isolated.execute(
                "INSERT INTO runtime_canonical_search_active_generation VALUES (1, ?, ?, 10)",
                bindings: [.text(scrubID), .text(scrubCertificate)]
            )
            XCTAssertTrue(try isolated.query(
                "SELECT 1 FROM runtime_canonical_scheduler_state"
            ).isEmpty)

            // Enqueue order is deliberately the reverse of the scheduler's
            // queue-name tie order and is not generation-ID lexical order.
            try CanonicalRuntimeStore.scheduleCanonicalGenerationScrub(
                generationID: scrubID, kind: "search", certificate: scrubCertificate,
                nowMilliseconds: 10, database: isolated
            )
            try CanonicalRuntimeStore.scheduleCanonicalGenerationScrub(
                generationID: scrubID, kind: "search", certificate: scrubCertificate,
                nowMilliseconds: 10, database: isolated
            )
            XCTAssertEqual(try isolated.query(
                "SELECT next_service_ticket FROM runtime_canonical_scheduler_state"
            ).first?.value(named: "next_service_ticket"), .integer(2))

            try insertProjectionGeneration(
                generationID: cleanupID, definition: definition, cursor: .emptySource,
                sourceDigest: empty, invalidationIDs: ["runtime.empty-source"],
                invalidationDigest: invalidationDigest, entryCount: 0, shardCount: 0,
                rootDigest: empty, status: "abandoned", certificate: nil,
                database: isolated
            )
            try CanonicalRuntimeStore.enqueueCanonicalBuildCleanup(
                generationID: cleanupID, projectionID: definition.id.rawValue,
                searchGenerationID: nil, firstPhase: "projection_entries",
                reasonCode: "fixture_cleanup", nowMilliseconds: 10,
                database: isolated
            )
            try CanonicalRuntimeStore.enqueueCanonicalBuildCleanup(
                generationID: cleanupID, projectionID: definition.id.rawValue,
                searchGenerationID: nil, firstPhase: "projection_entries",
                reasonCode: "fixture_cleanup", nowMilliseconds: 10,
                database: isolated
            )
            try insertProjectionGeneration(
                generationID: gcID, definition: definition, cursor: .emptySource,
                sourceDigest: empty, invalidationIDs: ["runtime.empty-source"],
                invalidationDigest: invalidationDigest, entryCount: 0, shardCount: 0,
                rootDigest: empty, status: "retired", certificate: gcCertificate,
                database: isolated
            )
            let retiredRows = try isolated.query(
                "SELECT generation_id, generation_certificate_digest FROM runtime_canonical_projection_generations WHERE generation_id = ?",
                bindings: [.text(gcID)]
            )
            try CanonicalRuntimeStore.scheduleCanonicalGenerationGC(
                rows: retiredRows, kind: "projection", firstPhase: "entries",
                nowMilliseconds: 10, database: isolated
            )
            try CanonicalRuntimeStore.scheduleCanonicalGenerationGC(
                rows: retiredRows, kind: "projection", firstPhase: "entries",
                nowMilliseconds: 10, database: isolated
            )
            XCTAssertEqual(try isolated.query(
                "SELECT service_ticket FROM runtime_canonical_generation_scrub_jobs WHERE generation_id = ?",
                bindings: [.text(scrubID)]
            ).first?.value(named: "service_ticket"), .integer(1))
            XCTAssertEqual(try isolated.query(
                "SELECT service_ticket FROM runtime_canonical_build_cleanup_jobs WHERE generation_id = ?",
                bindings: [.text(cleanupID)]
            ).first?.value(named: "service_ticket"), .integer(2))
            XCTAssertEqual(try isolated.query(
                "SELECT service_ticket FROM runtime_canonical_generation_gc_jobs WHERE generation_id = ?",
                bindings: [.text(gcID)]
            ).first?.value(named: "service_ticket"), .integer(3))
            XCTAssertEqual(try isolated.query(
                "SELECT next_service_ticket FROM runtime_canonical_scheduler_state"
            ).first?.value(named: "next_service_ticket"), .integer(4))

            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "fairness", nowMilliseconds: 100, rowLimit: 128,
                    database: isolated
                ),
                .progressed(generationID: scrubID, kind: "search", phase: "postings")
            )
            XCTAssertEqual(try isolated.query(
                "SELECT service_ticket FROM runtime_canonical_generation_scrub_jobs WHERE generation_id = ?",
                bindings: [.text(scrubID)]
            ).first?.value(named: "service_ticket"), .integer(4))

            let laterCertificate = CanonicalRuntimeStore
                .canonicalProjectionGenerationCertificateDigest(
                    generationID: laterScrubID, projectionID: definition.id,
                    definitionDigest: definition.authorityDigest,
                    outputVersion: definition.outputVersion, sourceCursor: .emptySource,
                    sourceChainDigest: empty, entryCount: 0, shardCount: 0,
                    rootDigest: empty, privacy: "", localOnly: true,
                    invalidationDigest: invalidationDigest
                )
            try insertProjectionGeneration(
                generationID: laterScrubID, definition: definition, cursor: .emptySource,
                sourceDigest: empty, invalidationIDs: ["runtime.empty-source"],
                invalidationDigest: invalidationDigest, entryCount: 0, shardCount: 0,
                rootDigest: empty, status: "published", certificate: laterCertificate,
                database: isolated
            )
            try isolated.execute(
                "INSERT INTO runtime_canonical_projection_active_generations VALUES (?, ?, ?, 11)",
                bindings: [
                    .text(definition.id.rawValue), .text(laterScrubID),
                    .text(laterCertificate),
                ]
            )
            try CanonicalRuntimeStore.scheduleCanonicalGenerationScrub(
                generationID: laterScrubID, kind: "projection",
                certificate: laterCertificate, nowMilliseconds: 11,
                database: isolated
            )
            XCTAssertEqual(try isolated.query(
                "SELECT service_ticket FROM runtime_canonical_generation_scrub_jobs WHERE generation_id = ?",
                bindings: [.text(laterScrubID)]
            ).first?.value(named: "service_ticket"), .integer(5))
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "fairness", nowMilliseconds: 100, rowLimit: 128,
                    database: isolated
                ),
                .progressed(
                    generationID: cleanupID, kind: "cleanup", phase: "projection_shards"
                )
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "fairness", nowMilliseconds: 100, rowLimit: 128,
                    database: isolated
                ),
                .progressed(generationID: gcID, kind: "projection", phase: "shards")
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "fairness", nowMilliseconds: 100, rowLimit: 128,
                    database: isolated
                ),
                .completed(generationID: scrubID, kind: "search")
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "fairness", nowMilliseconds: 100, rowLimit: 128,
                    database: isolated
                ),
                .completed(generationID: laterScrubID, kind: "projection")
            )
        }
    }

    func testAbandonedBuildUsesBoundedCleanupInsteadOfSynchronousDeletion() async throws {
        let database = try await makeV5Database("bounded-build-cleanup")
        let definition = try projectionDefinition(.aggregateState)
        let cursor = RuntimeCanonicalReplayCursor(
            sequence: 1, eventID: "event-1",
            eventHash: String(repeating: "a", count: 64)
        )
        let entry = try makeEntry(id: "goal-cleanup", privacy: .standard, cursor: cursor)
        let fixture = try await seedActivationFixture(
            definition: definition, capturedCount: 1, totalCount: 1,
            entries: [entry], database: database
        )
        try await database.transaction(.immediate) { isolated in
            try CanonicalRuntimeStore.scheduleCanonicalProjectionBuildCleanup(
                projectionID: definition.id.rawValue,
                generationID: fixture.work.generationID,
                ownerID: fixture.work.lease.ownerID,
                fenceVersion: Int64(fixture.work.lease.version),
                reasonCode: "test_bounded_cleanup", nowMilliseconds: 30,
                database: isolated
            )
            XCTAssertEqual(
                try isolated.query(
                    "SELECT status FROM runtime_canonical_projection_generations WHERE generation_id = ?",
                    bindings: [.text(fixture.work.generationID)]
                ).first?.value(named: "status"),
                .text("abandoned")
            )
            XCTAssertEqual(
                try isolated.query(
                    "SELECT phase FROM runtime_canonical_build_cleanup_jobs WHERE generation_id = ?",
                    bindings: [.text(fixture.work.generationID)]
                ).first?.value(named: "phase"),
                .text("projection_entries")
            )
            XCTAssertEqual(
                try isolated.query(
                    "SELECT 1 FROM runtime_canonical_projection_entries WHERE generation_id = ?",
                    bindings: [.text(fixture.work.generationID)]
                ).count,
                1
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "cleanup-worker", nowMilliseconds: 31,
                    rowLimit: 1, database: isolated
                ),
                .progressed(
                    generationID: fixture.work.generationID,
                    kind: "cleanup", phase: "projection_entries"
                )
            )
            XCTAssertTrue(try isolated.query(
                "SELECT 1 FROM runtime_canonical_projection_entries WHERE generation_id = ?",
                bindings: [.text(fixture.work.generationID)]
            ).isEmpty)
            XCTAssertFalse(try isolated.query(
                "SELECT 1 FROM runtime_canonical_projection_generations WHERE generation_id = ?",
                bindings: [.text(fixture.work.generationID)]
            ).isEmpty)
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "cleanup-worker", nowMilliseconds: 32,
                    rowLimit: 1, database: isolated
                ),
                .progressed(
                    generationID: fixture.work.generationID,
                    kind: "cleanup", phase: "projection_shards"
                )
            )
            _ = try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                ownerID: "cleanup-worker", nowMilliseconds: 33,
                rowLimit: 1, database: isolated
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "cleanup-worker", nowMilliseconds: 34,
                    rowLimit: 1, database: isolated
                ),
                .progressed(
                    generationID: fixture.work.generationID,
                    kind: "cleanup", phase: "projection_header"
                )
            )
            XCTAssertEqual(
                try CanonicalRuntimeStore.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                    ownerID: "cleanup-worker", nowMilliseconds: 35,
                    rowLimit: 1, database: isolated
                ),
                .completed(generationID: fixture.work.generationID, kind: "cleanup")
            )
            XCTAssertTrue(try isolated.query(
                "SELECT 1 FROM runtime_canonical_projection_generations WHERE generation_id = ?",
                bindings: [.text(fixture.work.generationID)]
            ).isEmpty)
            XCTAssertTrue(try isolated.query(
                "SELECT 1 FROM runtime_canonical_build_cleanup_jobs WHERE generation_id = ?",
                bindings: [.text(fixture.work.generationID)]
            ).isEmpty)
        }
    }

    func testAbandonedSearchBuildDrainsEveryDerivedPhaseBeforeProjectionHeader() async throws {
        let database = try await makeV5Database("full-search-cleanup")
        let definition = try projectionDefinition(.search)
        let entry = try makeEntry(
            id: "goal-search-cleanup", privacy: .standard, cursor: fixtureCursor(1)
        )
        let fixture = try await seedActivationFixture(
            definition: definition, capturedCount: 1, totalCount: 1,
            entries: [entry], database: database, phase: .sealProjection
        )
        let searchID = CanonicalRuntimeStore.canonicalSearchGenerationID(fixture.work)
        let empty = RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
        try await database.transaction(.immediate) { isolated in
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_search_generations VALUES (
                    ?, ?, 'aggregate_metadata_only', ?, 1, ?, 0, 0, 0, 0, ?,
                    'building', NULL, 10
                )
                """,
                bindings: [
                    .text(searchID), .text(fixture.work.generationID),
                    .text(definition.authorityDigest),
                    .text(fixture.work.targetCursor.eventHash), .text(empty),
                ]
            )
            let metadata = try RuntimeCanonicalSearchMetadataExtractor.extract(
                entry: entry, allowedFields: definition.allowedSearchFields
            )
            let documentDigest = RuntimeCanonicalSearchDocument.authorityDigest(
                generationID: searchID, aggregate: entry.aggregate,
                privacy: entry.privacy, localOnly: entry.localOnly,
                title: metadata.title, body: metadata.body,
                sourceCursor: entry.sourceCursor
            )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_search_documents VALUES (
                    ?, ?, ?, ?, 1, ?, ?, 1, ?, ?, ?
                )
                """,
                bindings: [
                    .text(searchID), .text(entry.aggregate.kind.rawValue),
                    .text(entry.aggregate.id.rawValue), .text(entry.privacy.rawValue),
                    .text(metadata.title), .text(metadata.body),
                    .text(entry.sourceCursor.eventID), .text(entry.sourceCursor.eventHash),
                    .text(documentDigest),
                ]
            )
            var postingCount = 0
            for (field, value) in [metadata.title, metadata.body].enumerated() {
                for (ordinal, token) in CanonicalRuntimeStore
                    .canonicalSearchTokens(value).enumerated() {
                    let postingDigest = RuntimeTransactionDigest.digest([
                        "runtime.search.posting.v1", searchID, token,
                        entry.aggregate.kind.rawValue, entry.aggregate.id.rawValue,
                        String(field), String(ordinal), documentDigest,
                    ])
                    try isolated.execute(
                        "INSERT INTO runtime_canonical_search_postings VALUES (?, ?, ?, ?, ?, ?, ?)",
                        bindings: [
                            .text(searchID), .text(token),
                            .text(entry.aggregate.kind.rawValue),
                            .text(entry.aggregate.id.rawValue), .integer(Int64(field)),
                            .integer(Int64(ordinal)), .text(postingDigest),
                        ]
                    )
                    postingCount += 1
                }
            }
            let shardDigest = RuntimeTransactionDigest.digest([
                "runtime.search.shard.v1", searchID, "0", empty,
                entry.aggregate.kind.rawValue, entry.aggregate.id.rawValue, documentDigest,
            ])
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_search_shards VALUES (
                    ?, 0, ?, ?, ?, ?, 1, ?, ?
                )
                """,
                bindings: [
                    .text(searchID), .text(entry.aggregate.kind.rawValue),
                    .text(entry.aggregate.id.rawValue),
                    .text(entry.aggregate.kind.rawValue),
                    .text(entry.aggregate.id.rawValue), .text(empty), .text(shardDigest),
                ]
            )
            XCTAssertGreaterThan(postingCount, 0)
            try CanonicalRuntimeStore.quarantineAndRestartCanonicalProjectionBuildInTransaction(
                fixture.work, scope: .search,
                nowMilliseconds: 20, database: isolated
            )
            var observedPhases: Set<String> = []
            var terminal: RuntimeCanonicalGenerationMaintenanceOutcome = .idle
            for instant in 21...40 {
                terminal = try CanonicalRuntimeStore
                    .runOneCanonicalGenerationMaintenanceUnitInTransaction(
                        ownerID: "search-cleanup", nowMilliseconds: Int64(instant),
                        rowLimit: 128, database: isolated
                    )
                if case let .progressed(_, _, phase) = terminal {
                    observedPhases.insert(phase)
                }
                if case .completed = terminal { break }
            }
            XCTAssertEqual(
                terminal,
                .completed(generationID: fixture.work.generationID, kind: "cleanup")
            )
            XCTAssertTrue(Set([
                "search_postings", "search_documents", "search_shards", "search_header",
                "projection_entries", "projection_shards", "projection_header",
            ]).isSubset(of: observedPhases))
            for table in [
                "runtime_canonical_search_postings", "runtime_canonical_search_documents",
                "runtime_canonical_search_shards", "runtime_canonical_search_generations",
                "runtime_canonical_projection_entries", "runtime_canonical_projection_shards",
                "runtime_canonical_projection_generations",
            ] {
                XCTAssertTrue(try isolated.query(
                    "SELECT 1 FROM \(table) WHERE generation_id = ? LIMIT 1",
                    bindings: [.text(table.contains("search_") ? searchID : fixture.work.generationID)]
                ).isEmpty, table)
            }
        }
    }

    func testPrivacyFilteredKeysetReadsAndTransactionLocalActionVerification() async throws {
        let database = try await makeV5Database("entry-access")
        let definition = try projectionDefinition(.aggregateState)
        let entries = try [
            makeEntry(id: "goal-a", privacy: .standard, cursor: fixtureCursor(1)),
            makeEntry(id: "goal-b", privacy: .sensitive, cursor: fixtureCursor(1)),
            makeEntry(id: "goal-c", privacy: .standard, cursor: fixtureCursor(1)),
        ]
        let fixture = try await seedActivationFixture(
            definition: definition, capturedCount: 1, totalCount: 1,
            entries: entries, database: database
        )
        try await database.transaction(.immediate) { isolated in
            try CanonicalRuntimeStore.activateCanonicalProjectionGenerationInTransaction(
                fixture.work, nowMilliseconds: 30, database: isolated
            )
            let authority = try CanonicalRuntimeStore.requireCanonicalProjectionAuthority(
                definition: definition, requireNoPendingInvalidations: true,
                requireAtVerifiedHighWater: false, database: isolated
            )
            let reconstruction = RuntimeTransactionDigest.digest([
                "fixture-reconstruction", "1", authority.sourceCursor.eventHash,
            ])
            try isolated.execute(
                """
                INSERT INTO runtime_replay_verified_high_water VALUES (
                    1, 1, ?, ?, ?, ?, 1
                )
                """,
                bindings: [
                    .text(authority.sourceCursor.eventID),
                    .text(authority.sourceCursor.eventHash),
                    .text(authority.sourceChainDigest), .text(reconstruction),
                ]
            )
            let access = RuntimeCanonicalProjectionAccessPolicy(
                allowedPrivacy: [.standard], requiresLocalOnly: true
            )
            let first = try CanonicalRuntimeStore.readCanonicalProjectionEntryPage(
                authority: authority, access: access, after: nil, limit: 1,
                database: isolated
            )
            XCTAssertEqual(first.entries.map(\.aggregate.id.rawValue), ["goal-a"])
            let second = try CanonicalRuntimeStore.readCanonicalProjectionEntryPage(
                authority: authority, access: access,
                after: try XCTUnwrap(first.nextCursor), limit: 1, database: isolated
            )
            XCTAssertEqual(second.entries.map(\.aggregate.id.rawValue), ["goal-c"])
            XCTAssertNil(second.nextCursor)
            let page = RuntimeCanonicalProjectionEntryPage(
                authority: authority, entries: first.entries,
                nextCursor: first.nextCursor,
                truth: RuntimeCanonicalProjectionTruth(
                    state: .available, authority: authority,
                    expectedDefinitionVersion: definition.definitionVersion,
                    sourceCursor: authority.sourceCursor,
                    digest: authority.certificateDigest,
                    repairEligible: false, reasonCode: nil
                )
            )
            let token = try page.actionToken(for: entries[0], access: access)
            XCTAssertEqual(
                try CanonicalRuntimeStore.requireCanonicalProjectionEntryActionAuthority(
                    token, definition: definition, database: isolated
                ), entries[0]
            )
            let stale = RuntimeCanonicalProjectionEntryActionToken(
                generationID: token.generationID,
                certificateDigest: token.certificateDigest,
                authorityFingerprint: token.authorityFingerprint,
                accessPolicy: token.accessPolicy, aggregate: token.aggregate,
                revision: token.revision + 1, entryDigest: token.entryDigest,
                sourceCursor: token.sourceCursor
            )
            XCTAssertThrowsError(try CanonicalRuntimeStore
                .requireCanonicalProjectionEntryActionAuthority(
                    stale, definition: definition, database: isolated
                ))
        }
    }

    func testProjectionEntryBudgetRejectsOversizedFirstRowInsteadOfForcingProgress() async throws {
        let database = try await makeV5Database("first-row-budget")
        let definition = try projectionDefinition(.aggregateState)
        let generationID = String(repeating: "7", count: 64)
        let empty = RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
        try await database.transaction(.immediate) { isolated in
            try insertProjectionGeneration(
                generationID: generationID, definition: definition,
                cursor: fixtureCursor(1), sourceDigest: String(repeating: "a", count: 64),
                invalidationIDs: ["invalidation.first-row"],
                invalidationDigest: RuntimeTransactionDigest.digest(["first-row"]),
                entryCount: 0, shardCount: 0, rootDigest: empty,
                status: "building", certificate: nil, database: isolated
            )
            try CanonicalRuntimeStore.insertCanonicalProjectionEntry(
                generationID: generationID,
                entry: makeEntry(
                    id: "goal-first-row", privacy: .standard, cursor: fixtureCursor(1)
                ), database: isolated
            )
            XCTAssertThrowsError(try CanonicalRuntimeStore.canonicalBoundedProjectionEntryCount(
                generationID: generationID, afterKind: "", afterID: "",
                bounds: RuntimeCanonicalProjectionUnitBounds(
                    maximumRows: 128, maximumBytes: 4_096
                ), database: isolated
            )) {
                XCTAssertEqual(
                    $0 as? RuntimeCanonicalProjectionPersistenceError,
                    .unitBudgetExceeded
                )
            }
        }
    }

    func testLeaseFenceRejectsStaleOwnerAndCancellation() async throws {
        let database = try await makeV5Database("lease-fence")
        let definition = try projectionDefinition(.aggregateState)
        let fixture = try await seedActivationFixture(
            definition: definition, capturedCount: 1, totalCount: 1,
            entries: [], database: database
        )
        try await database.transaction(.deferred) { isolated in
            try CanonicalRuntimeStore.requireCanonicalProjectionBuildFence(
                fixture.work, phase: .ready, database: isolated
            )
            let staleLease = RuntimeCanonicalProjectionLease(
                projectionID: definition.id, ownerID: "other-owner", version: 99,
                expiresAtMilliseconds: fixture.work.lease.expiresAtMilliseconds
            )
            let stale = replacingLease(fixture.work, lease: staleLease)
            XCTAssertThrowsError(try CanonicalRuntimeStore.requireCanonicalProjectionBuildFence(
                stale, phase: .ready, database: isolated
            ))
        }
        let cancelled = await Task { () -> Bool in
            withUnsafeCurrentTask { $0?.cancel() }
            do {
                try await database.transaction(.deferred) { isolated in
                    try CanonicalRuntimeStore.requireCanonicalProjectionBuildFence(
                        fixture.work, phase: .ready, database: isolated
                    )
                }
                return false
            } catch is CancellationError { return true }
            catch { return false }
        }.value
        XCTAssertTrue(cancelled)
    }

    private struct ActivationFixture: Sendable {
        let work: RuntimeCanonicalProjectionBuildWork
    }

    private func projectionDefinition(
        _ id: RuntimeCanonicalProjectionID
    ) throws -> RuntimeCanonicalProjectionDefinition {
        try XCTUnwrap(
            RuntimeCanonicalProjectionDefinitionRegistry.canonical().definitions[id]
        )
    }

    private func makeV5Database(_ label: String) async throws -> SQLiteDatabase {
        let database = try SQLiteDatabase(url: temporaryDatabaseURL(label))
        try await database.transaction(.exclusive) { isolated in
            for statement in CanonicalRuntimeStore.schemaStatements +
                CanonicalRuntimeProjectionSchemaPlan.stagedIntegratedStatements {
                try isolated.execute(statement)
            }
            try isolated.execute("PRAGMA user_version = 5")
            try CanonicalRuntimeProjectionSchemaPlan.requireIntegratedSchema(in: isolated)
        }
        return database
    }

    private func fixtureCursor(_ sequence: Int) -> RuntimeCanonicalReplayCursor {
        RuntimeCanonicalReplayCursor(
            sequence: UInt64(sequence), eventID: "event-\(sequence)",
            eventHash: RuntimeTransactionDigest.digest(["fixture-event", String(sequence)])
        )
    }

    private func seedActivationFixture(
        definition: RuntimeCanonicalProjectionDefinition,
        capturedCount: Int,
        totalCount: Int,
        entries: [RuntimeCanonicalProjectionEntry],
        database: SQLiteDatabase,
        phase: RuntimeCanonicalProjectionBuildPhase = .ready,
        blockedReason: String? = nil
    ) async throws -> ActivationFixture {
        try await database.transaction(.immediate) { isolated in
            let empty = RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
            let sourceBytes = Data("semantic-source".utf8)
            let sourceChecksum = LocalRuntimeStorageChecksum.sha256Hex(for: sourceBytes)
            try isolated.execute(
                """
                INSERT INTO runtime_aggregates VALUES (
                    'goal', 'fixture-goal', ?, 1, ?, ?
                )
                """,
                bindings: [
                    .integer(Int64(totalCount)), .blob(Data("aggregate".utf8)),
                    .text(RuntimeTransactionDigest.digest(["aggregate"])),
                ]
            )
            for sequence in 1...totalCount {
                let cursor = fixtureCursor(sequence)
                let commandID = "command-\(sequence)"
                try isolated.execute(
                    """
                    INSERT INTO runtime_command_idempotency(
                        scope, idempotency_key, command_id, command_fingerprint,
                        claim_version, claim_payload, claimed_at_ms
                    ) VALUES ('fixture', ?, ?, ?, 1, ?, ?)
                    """,
                    bindings: [
                        .text("key-\(sequence)"), .text(commandID),
                        .text(RuntimeTransactionDigest.digest(["command", String(sequence)])),
                        .blob(Data("claim".utf8)), .integer(Int64(sequence)),
                    ]
                )
                try isolated.execute(
                    """
                    INSERT INTO runtime_semantic_events(
                        sequence, event_id, command_id, aggregate_kind, aggregate_id,
                        canonical_revision, correlation_id, causation_event_id,
                        envelope_version, type_id, payload_version, source_bytes,
                        source_digest, previous_event_hash, event_hash, occurred_at_ms
                    ) VALUES (?, ?, ?, 'goal', 'fixture-goal', ?, ?, NULL,
                              1, ?, 3, ?, ?, ?, ?, ?)
                    """,
                    bindings: [
                        .integer(Int64(sequence)), .text(cursor.eventID), .text(commandID),
                        .integer(Int64(sequence)), .text("correlation-\(sequence)"),
                        .text(RuntimeSemanticEventTypeID.goalUpdated.rawValue),
                        .blob(sourceBytes), .text(sourceChecksum),
                        sequence == 1 ? .null : .text(fixtureCursor(sequence - 1).eventHash),
                        .text(cursor.eventHash), .integer(Int64(sequence)),
                    ]
                )
                let invalidationID = "invalidation.\(sequence).\(definition.id.rawValue)"
                let lineage = RuntimeAuthorityLineageReference(
                    eventID: try RuntimeEventID(validating: cursor.eventID),
                    eventSequence: UInt64(sequence), eventHash: cursor.eventHash
                )
                let lineageBytes = try canonicalJSON(lineage)
                try isolated.execute(
                    """
                    INSERT INTO runtime_commit_projection_invalidations VALUES (
                        ?, ?, ?, 1, ?, ?, ?
                    )
                    """,
                    bindings: [
                        .text(invalidationID), .text(definition.id.rawValue),
                        .integer(Int64(sequence)), .blob(lineageBytes),
                        .text(LocalRuntimeStorageChecksum.sha256Hex(for: lineageBytes)),
                        .integer(Int64(sequence)),
                    ]
                )
                let receipt = RuntimeAtomicCommitReceipt(
                    receiptID: try RuntimeReceiptID(validating: "receipt-\(sequence)"),
                    preparationID: try XCTUnwrap(RuntimePreparationID(rawValue: "preparation-\(sequence)")),
                    commandID: try RuntimeCommandID(validating: commandID),
                    lineage: lineage, aggregateStates: [], tombstones: [],
                    unresolvedWork: [RuntimeAuthorityUnresolvedWorkReference(
                        kind: .projectionInvalidation, stableID: invalidationID,
                        lineage: lineage
                    )], objectLinks: [],
                    undoability: .notUndoable(reason: .missingTypedCompensationContract),
                    confirmationToken: nil, confirmationDecisionDigest: nil,
                    committedAt: Date(timeIntervalSince1970: Double(sequence) / 1_000)
                )
                let receiptBytes = try canonicalJSON(receipt)
                try isolated.execute(
                    """
                    INSERT INTO runtime_commit_receipts VALUES (
                        ?, ?, ?, ?, ?, ?, ?, ?
                    )
                    """,
                    bindings: [
                        .text(receipt.receiptID.rawValue),
                        .text(receipt.preparationID.rawValue), .text(commandID),
                        .integer(Int64(sequence)), .integer(Int64(runtimeAtomicCommitReceiptVersion)),
                        .blob(receiptBytes),
                        .text(LocalRuntimeStorageChecksum.sha256Hex(for: receiptBytes)),
                        .integer(Int64(sequence)),
                    ]
                )
            }
            let target = fixtureCursor(capturedCount)
            let sourceDigest = RuntimeTransactionDigest.digest([
                "fixture-source-chain", String(capturedCount), target.eventHash,
            ])
            let reconstruction = RuntimeTransactionDigest.digest([
                "fixture-reconstruction", String(capturedCount), target.eventHash,
            ])
            let sourceSHA = try SHA256Digest(hexadecimal: sourceDigest)
            let reconstructionSHA = try SHA256Digest(hexadecimal: reconstruction)
            let replayCertificate = RuntimeCanonicalReplayEngine.verificationCertificateDigest(
                cursor: target, sourceChainDigest: sourceSHA,
                reconstructionDigest: reconstructionSHA,
                verifiedAtMilliseconds: Int64(capturedCount)
            )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_replay_verification_certificates VALUES (
                    ?, ?, ?, ?, ?, ?, ?
                )
                """,
                bindings: [
                    .integer(Int64(capturedCount)), .text(target.eventID),
                    .text(target.eventHash), .text(sourceDigest), .text(reconstruction),
                    .integer(Int64(capturedCount)), .text(replayCertificate),
                ]
            )
            let invalidationIDs = (1...capturedCount).map {
                "invalidation.\($0).\(definition.id.rawValue)"
            }
            let invalidationDigest = RuntimeTransactionDigest.digest(
                (1...capturedCount).flatMap { sequence in
                    let cursor = fixtureCursor(sequence)
                    return [
                        "invalidation.\(sequence).\(definition.id.rawValue)",
                        String(sequence), cursor.eventID, cursor.eventHash,
                    ]
                }
            )
            let generationID = RuntimeTransactionDigest.digest([
                "fixture-generation", definition.id.rawValue, String(capturedCount),
                invalidationDigest,
            ])
            try insertProjectionGeneration(
                generationID: generationID, definition: definition, cursor: target,
                sourceDigest: sourceDigest, invalidationIDs: invalidationIDs,
                invalidationDigest: invalidationDigest, entryCount: 0, shardCount: 0,
                rootDigest: empty, status: "building", certificate: nil,
                database: isolated
            )
            let lease = RuntimeCanonicalProjectionLease(
                projectionID: definition.id, ownerID: "worker", version: 1,
                expiresAtMilliseconds: 30_000
            )
            try isolated.execute(
                "INSERT INTO runtime_canonical_projection_leases VALUES (?, 'worker', 1, 30000)",
                bindings: [.text(definition.id.rawValue)]
            )
            try isolated.execute(
                """
                INSERT INTO runtime_canonical_projection_jobs(
                    projection_id, generation_id, phase, blocked_reason_code,
                    base_generation_id, base_certificate_digest, base_root_digest,
                    base_entry_count, base_scrub_certificate_digest,
                    base_scrub_completed_at_ms,
                    target_sequence, target_event_id, target_event_hash,
                    progress_sequence, progress_event_id, progress_event_hash,
                    progress_source_digest, after_aggregate_kind, after_aggregate_id,
                    shard_ordinal, rolling_root_digest, entry_count, sealed_entry_count,
                    privacy_standard_count, privacy_sensitive_count,
                    privacy_private_text_count, privacy_calendar_count,
                    privacy_sync_count, nonlocal_entry_count,
                    search_document_count, sealed_search_document_count,
                    search_posting_count, search_posting_bytes,
                    first_invalidation_id, last_invalidation_id, invalidation_digest,
                    owner_id, fence_version, service_ticket, updated_at_ms
                ) VALUES (?, ?, 'replay', NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                          ?, ?, ?, 0, NULL, NULL, ?, '', '', 0, ?,
                          0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                          ?, ?, ?, 'worker', 1, 1, 1)
                """,
                bindings: [
                    .text(definition.id.rawValue), .text(generationID),
                    .integer(Int64(target.sequence)), .text(target.eventID),
                    .text(target.eventHash), .text(empty), .text(empty),
                    .text(invalidationIDs[0]),
                    .text(invalidationIDs[invalidationIDs.count - 1]),
                    .text(invalidationDigest),
                ]
            )
            for entry in entries {
                try CanonicalRuntimeStore.insertCanonicalProjectionEntry(
                    generationID: generationID, entry: entry, database: isolated
                )
            }
            let shardCount: Int
            let rootDigest: String
            if entries.isEmpty {
                shardCount = 0
                rootDigest = empty
            } else {
                let ordered = entries.sorted {
                    ($0.aggregate.kind.rawValue, $0.aggregate.id.rawValue) <
                        ($1.aggregate.kind.rawValue, $1.aggregate.id.rawValue)
                }
                var material = ["runtime.projection.shard.v1", generationID, "0", empty]
                for entry in ordered {
                    material += [
                        entry.aggregate.kind.rawValue, entry.aggregate.id.rawValue,
                        CanonicalRuntimeStore.canonicalProjectionEntryDigest(entry),
                    ]
                }
                rootDigest = RuntimeTransactionDigest.digest(material)
                shardCount = 1
                try isolated.execute(
                    """
                    INSERT INTO runtime_canonical_projection_shards VALUES (
                        ?, 0, ?, ?, ?, ?, ?, ?, ?
                    )
                    """,
                    bindings: [
                        .text(generationID), .text(ordered[0].aggregate.kind.rawValue),
                        .text(ordered[0].aggregate.id.rawValue),
                        .text(ordered[ordered.count - 1].aggregate.kind.rawValue),
                        .text(ordered[ordered.count - 1].aggregate.id.rawValue),
                        .integer(Int64(ordered.count)), .text(empty), .text(rootDigest),
                    ]
                )
            }
            let privacy = Set(entries.map(\.privacy)).map(\.rawValue).sorted()
                .joined(separator: ",")
            let certificate = CanonicalRuntimeStore
                .canonicalProjectionGenerationCertificateDigest(
                    generationID: generationID, projectionID: definition.id,
                    definitionDigest: definition.authorityDigest,
                    outputVersion: definition.outputVersion, sourceCursor: target,
                    sourceChainDigest: sourceDigest, entryCount: entries.count,
                    shardCount: shardCount, rootDigest: rootDigest, privacy: privacy,
                    localOnly: entries.allSatisfy(\.localOnly),
                    invalidationDigest: invalidationDigest
                )
            try isolated.execute(
                """
                UPDATE runtime_canonical_projection_generations
                SET entry_count = ?, shard_count = ?, entry_root_digest = ?,
                    privacy = ?, local_only = ?, status = 'sealed',
                    generation_certificate_digest = ?, sealed_at_ms = 10
                WHERE generation_id = ?
                """,
                bindings: [
                    .integer(Int64(entries.count)), .integer(Int64(shardCount)),
                    .text(rootDigest), .text(privacy),
                    .integer(entries.allSatisfy(\.localOnly) ? 1 : 0),
                    .text(certificate), .text(generationID),
                ]
            )
            try isolated.execute(
                """
                UPDATE runtime_canonical_projection_jobs
                SET progress_sequence = ?, progress_event_id = ?, progress_event_hash = ?,
                    progress_source_digest = ?, shard_ordinal = ?, rolling_root_digest = ?,
                    entry_count = ?, sealed_entry_count = ?,
                    privacy_standard_count = ?, privacy_sensitive_count = ?,
                    privacy_private_text_count = ?, privacy_calendar_count = ?,
                    privacy_sync_count = ?, nonlocal_entry_count = ?, updated_at_ms = 2
                WHERE projection_id = ? AND generation_id = ? AND phase = 'replay'
                """,
                bindings: [
                    .integer(Int64(target.sequence)), .text(target.eventID),
                    .text(target.eventHash), .text(sourceDigest),
                    .integer(Int64(shardCount)), .text(rootDigest),
                    .integer(Int64(entries.count)), .integer(Int64(entries.count)),
                    .integer(Int64(entries.filter { $0.privacy == .standard }.count)),
                    .integer(Int64(entries.filter { $0.privacy == .sensitive }.count)),
                    .integer(Int64(entries.filter { $0.privacy == .privateUserText }.count)),
                    .integer(Int64(entries.filter { $0.privacy == .calendarDerived }.count)),
                    .integer(Int64(entries.filter { $0.privacy == .syncMetadata }.count)),
                    .integer(Int64(entries.filter { $0.localOnly == false }.count)),
                    .text(definition.id.rawValue), .text(generationID),
                ]
            )
            let phasePath: [RuntimeCanonicalProjectionBuildPhase]
            switch phase {
            case .clone:
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            case .replay:
                phasePath = []
            case .sealProjection:
                phasePath = [.sealProjection]
            case .indexSearch:
                phasePath = [.sealProjection, .indexSearch]
            case .sealSearch:
                phasePath = [.sealProjection, .indexSearch, .sealSearch]
            case .ready:
                phasePath = definition.id == .search
                    ? [.sealProjection, .indexSearch, .sealSearch, .ready]
                    : [.sealProjection, .ready]
            case .blocked:
                phasePath = [.blocked]
            }
            var priorPhase = RuntimeCanonicalProjectionBuildPhase.replay
            for nextPhase in phasePath {
                try isolated.execute(
                    """
                    UPDATE runtime_canonical_projection_jobs
                    SET phase = ?, blocked_reason_code = ?, updated_at_ms = updated_at_ms + 1
                    WHERE projection_id = ? AND generation_id = ? AND phase = ?
                    """,
                    bindings: [
                        .text(nextPhase.rawValue),
                        nextPhase == .blocked
                            ? .text(blockedReason ?? "fixture_blocked") : .null,
                        .text(definition.id.rawValue), .text(generationID),
                        .text(priorPhase.rawValue),
                    ]
                )
                priorPhase = nextPhase
            }
            return ActivationFixture(work: RuntimeCanonicalProjectionBuildWork(
                projectionID: definition.id, generationID: generationID,
                definition: definition, phase: phase, targetCursor: target,
                progressCursor: target, sourceChainDigest: sourceDigest,
                progressSourceDigest: sourceDigest, afterAggregateKind: "",
                afterAggregateID: "", shardOrdinal: shardCount,
                rollingRootDigest: rootDigest, invalidationIDs: invalidationIDs,
                invalidationDigest: invalidationDigest, lease: lease,
                operationNowMilliseconds: 10, blockedReasonCode: blockedReason,
                baseGenerationID: nil, baseCertificateDigest: nil,
                baseRootDigest: nil, baseEntryCount: nil,
                baseScrubCertificateDigest: nil,
                baseScrubCompletedAtMilliseconds: nil,
                entryCount: entries.count, sealedEntryCount: entries.count,
                privacyCounts: [
                    .standard: entries.filter { $0.privacy == .standard }.count,
                    .sensitive: entries.filter { $0.privacy == .sensitive }.count,
                    .privateUserText: entries.filter { $0.privacy == .privateUserText }.count,
                    .calendarDerived: entries.filter { $0.privacy == .calendarDerived }.count,
                    .syncMetadata: entries.filter { $0.privacy == .syncMetadata }.count,
                ],
                nonlocalEntryCount: entries.filter { $0.localOnly == false }.count,
                searchDocumentCount: 0, sealedSearchDocumentCount: 0,
                searchPostingCount: 0, searchPostingBytes: 0
            ))
        }
    }

    private func insertProjectionGeneration(
        generationID: String,
        definition: RuntimeCanonicalProjectionDefinition,
        cursor: RuntimeCanonicalReplayCursor,
        sourceDigest: String,
        invalidationIDs: [String],
        invalidationDigest: String,
        entryCount: Int,
        shardCount: Int,
        rootDigest: String,
        status: String,
        certificate: String?,
        database: isolated SQLiteDatabase
    ) throws {
        try database.execute(
            """
            INSERT INTO runtime_canonical_projection_generations VALUES (
                ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '', 1, ?, ?, 1, ?
            )
            """,
            bindings: [
                .text(generationID), .text(definition.id.rawValue),
                .integer(Int64(definition.definitionVersion)),
                .text(definition.authorityDigest), .integer(Int64(definition.outputVersion)),
                .integer(Int64(cursor.sequence)), .text(cursor.eventID),
                .text(cursor.eventHash), .text(sourceDigest),
                .text(invalidationIDs[0]),
                .text(invalidationIDs[invalidationIDs.count - 1]),
                .text(invalidationDigest), .integer(Int64(entryCount)),
                .integer(Int64(shardCount)), .text(rootDigest), .text(status),
                certificate.map(SQLiteBinding.text) ?? .null,
                certificate == nil ? .null : .integer(1),
            ]
        )
    }

    private func canonicalJSON<Value: Encodable>(_ value: Value) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(value)
    }

    private func makeEntry(
        id: String,
        privacy: EventLedgerPrivacyClassification,
        cursor: RuntimeCanonicalReplayCursor
    ) throws -> RuntimeCanonicalProjectionEntry {
        let bytes = Data("state-\(id)".utf8)
        return RuntimeCanonicalProjectionEntry(
            aggregate: RuntimeSemanticAggregate(
                kind: .goal, id: try RuntimeAggregateID(validating: id)
            ), revision: 1, lifecycle: .active,
            canonicalStateBytes: bytes,
            canonicalStateDigest: LocalRuntimeStorageChecksum.sha256Hex(for: bytes),
            privacy: privacy, localOnly: true, sourceCursor: cursor
        )
    }

    private func replacingLease(
        _ work: RuntimeCanonicalProjectionBuildWork,
        lease: RuntimeCanonicalProjectionLease
    ) -> RuntimeCanonicalProjectionBuildWork {
        RuntimeCanonicalProjectionBuildWork(
            projectionID: work.projectionID, generationID: work.generationID,
            definition: work.definition, phase: work.phase,
            targetCursor: work.targetCursor, progressCursor: work.progressCursor,
            sourceChainDigest: work.sourceChainDigest,
            progressSourceDigest: work.progressSourceDigest,
            afterAggregateKind: work.afterAggregateKind,
            afterAggregateID: work.afterAggregateID,
            shardOrdinal: work.shardOrdinal,
            rollingRootDigest: work.rollingRootDigest,
            invalidationIDs: work.invalidationIDs,
            invalidationDigest: work.invalidationDigest, lease: lease,
            operationNowMilliseconds: work.operationNowMilliseconds,
            blockedReasonCode: work.blockedReasonCode,
            baseGenerationID: work.baseGenerationID,
            baseCertificateDigest: work.baseCertificateDigest,
            baseRootDigest: work.baseRootDigest, baseEntryCount: work.baseEntryCount,
            baseScrubCertificateDigest: work.baseScrubCertificateDigest,
            baseScrubCompletedAtMilliseconds: work.baseScrubCompletedAtMilliseconds,
            entryCount: work.entryCount, sealedEntryCount: work.sealedEntryCount,
            privacyCounts: work.privacyCounts,
            nonlocalEntryCount: work.nonlocalEntryCount,
            searchDocumentCount: work.searchDocumentCount,
            sealedSearchDocumentCount: work.sealedSearchDocumentCount,
            searchPostingCount: work.searchPostingCount,
            searchPostingBytes: work.searchPostingBytes
        )
    }

    private func makeCursor() -> RuntimeCanonicalReplayCursor {
        RuntimeCanonicalReplayCursor(
            sequence: 4, eventID: "event-4",
            eventHash: String(repeating: "a", count: 64)
        )
    }

    private func temporaryDatabaseURL(_ label: String) -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("runtime-canonical-\(label)-\(UUID().uuidString).sqlite")
    }

    private func makeEntry() throws -> RuntimeCanonicalProjectionEntry {
        let bytes = Data("state".utf8)
        return RuntimeCanonicalProjectionEntry(
            aggregate: RuntimeSemanticAggregate(
                kind: .goal, id: try RuntimeAggregateID(validating: "goal-1")
            ), revision: 3, lifecycle: .active, canonicalStateBytes: bytes,
            canonicalStateDigest: LocalRuntimeStorageChecksum.sha256Hex(for: bytes),
            privacy: .standard, localOnly: true, sourceCursor: makeCursor()
        )
    }

    private func replacingBase(
        _ work: RuntimeCanonicalProjectionBuildWork,
        generationID: String,
        certificate: String,
        root: String,
        entryCount: Int
    ) -> RuntimeCanonicalProjectionBuildWork {
        replacingWork(
            work, phase: work.phase,
            baseGenerationID: generationID, baseCertificate: certificate,
            baseRoot: root, baseEntryCount: entryCount
        )
    }

    private func replacingPhase(
        _ work: RuntimeCanonicalProjectionBuildWork,
        phase: RuntimeCanonicalProjectionBuildPhase
    ) -> RuntimeCanonicalProjectionBuildWork {
        replacingWork(
            work, phase: phase,
            baseGenerationID: work.baseGenerationID,
            baseCertificate: work.baseCertificateDigest,
            baseRoot: work.baseRootDigest, baseEntryCount: work.baseEntryCount,
            baseScrubCertificate: work.baseScrubCertificateDigest,
            baseScrubCompletedAt: work.baseScrubCompletedAtMilliseconds
        )
    }

    private func replacingWork(
        _ work: RuntimeCanonicalProjectionBuildWork,
        phase: RuntimeCanonicalProjectionBuildPhase,
        baseGenerationID: String?,
        baseCertificate: String?,
        baseRoot: String?,
        baseEntryCount: Int?,
        baseScrubCertificate: String? = nil,
        baseScrubCompletedAt: Int64? = nil
    ) -> RuntimeCanonicalProjectionBuildWork {
        RuntimeCanonicalProjectionBuildWork(
            projectionID: work.projectionID, generationID: work.generationID,
            definition: work.definition, phase: phase,
            targetCursor: work.targetCursor, progressCursor: work.progressCursor,
            sourceChainDigest: work.sourceChainDigest,
            progressSourceDigest: work.progressSourceDigest,
            afterAggregateKind: work.afterAggregateKind,
            afterAggregateID: work.afterAggregateID,
            shardOrdinal: work.shardOrdinal,
            rollingRootDigest: work.rollingRootDigest,
            invalidationIDs: work.invalidationIDs,
            invalidationDigest: work.invalidationDigest, lease: work.lease,
            operationNowMilliseconds: work.operationNowMilliseconds,
            blockedReasonCode: work.blockedReasonCode,
            baseGenerationID: baseGenerationID,
            baseCertificateDigest: baseCertificate,
            baseRootDigest: baseRoot, baseEntryCount: baseEntryCount,
            baseScrubCertificateDigest: baseScrubCertificate,
            baseScrubCompletedAtMilliseconds: baseScrubCompletedAt,
            entryCount: work.entryCount, sealedEntryCount: work.sealedEntryCount,
            privacyCounts: work.privacyCounts,
            nonlocalEntryCount: work.nonlocalEntryCount,
            searchDocumentCount: work.searchDocumentCount,
            sealedSearchDocumentCount: work.sealedSearchDocumentCount,
            searchPostingCount: work.searchPostingCount,
            searchPostingBytes: work.searchPostingBytes
        )
    }
}
