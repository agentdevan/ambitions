import AmbitionsRuntimeSQLite
import Foundation

/// The complete mutable capability of the projection/search owner. Canonical,
/// receipt, external-effect, attachment, and store-metadata tables are absent
/// by construction. SQLite enforces this allowlist for direct and trigger
/// writes before a statement can execute.
enum RuntimeCanonicalDerivedWriteAuthority {
    static let tables: Set<String> = [
        "runtime_canonical_build_cleanup_jobs",
        "runtime_canonical_generation_gc_jobs",
        "runtime_canonical_generation_scrub_jobs",
        "runtime_canonical_projection_active_generations",
        "runtime_canonical_projection_entries",
        "runtime_canonical_projection_generations",
        "runtime_canonical_projection_invalidation_acks",
        "runtime_canonical_projection_jobs",
        "runtime_canonical_projection_leases",
        "runtime_canonical_projection_quarantine",
        "runtime_canonical_projection_shards",
        "runtime_canonical_repair_incidents",
        "runtime_canonical_repair_requirements",
        "runtime_canonical_scheduler_state",
        "runtime_canonical_scrub_certificates",
        "runtime_canonical_search_active_generation",
        "runtime_canonical_search_documents",
        "runtime_canonical_search_generations",
        "runtime_canonical_search_postings",
        "runtime_canonical_search_shards",
    ]

    static let readableSourceTables: Set<String> = tables.union([
        "sqlite_schema",
        "sqlite_master",
        "runtime_store_metadata",
        "runtime_semantic_events",
        "runtime_semantic_event_quarantine",
        "runtime_commit_projection_invalidations",
        "runtime_commit_receipts",
        "runtime_committed_receipt_cores",
        "runtime_receipt_artifact_links",
        "runtime_command_idempotency",
        "runtime_canonical_replay_verification_certificates",
        "runtime_replay_verified_high_water",
    ])

    static var sqlite: SQLiteWriteAuthorization {
        get throws {
            try SQLiteWriteAuthorization(
                allowedTables: tables,
                allowedReadTables: readableSourceTables
            )
        }
    }
}

/// Capability-scoped transaction owner for derived projection/search state.
/// The isolated SQLite handle remains readable for deterministic derivation,
/// while its writes are independently constrained to the catalog above.
protocol RuntimeCanonicalDerivedTransactionGateway: Actor {
    var derivedGenerationID: RuntimeStoreGenerationID { get }

    func withDerivedImmediateTransaction<Result: Sendable>(
        _ operation: @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Result
    ) async throws -> Result
}

extension CanonicalRuntimeStore: RuntimeCanonicalDerivedTransactionGateway {
    nonisolated var derivedGenerationID: RuntimeStoreGenerationID { generationID }
}

/// Writable gateway used only while one durable, unpublished schema-v8 G+1
/// projection-rebuild candidate is owned by its reservation executor.
actor RuntimeGenerationCandidateDerivedGateway: RuntimeCanonicalDerivedTransactionGateway {
    nonisolated let derivedGenerationID: RuntimeStoreGenerationID

    private let databaseURL: URL
    private let database: SQLiteDatabase
    private let ownership: RuntimeGenerationCandidateOwnership
    private let pinnedFiles: RuntimeStorePinnedFileSet

    private init(
        generationID: RuntimeStoreGenerationID,
        databaseURL: URL,
        database: SQLiteDatabase,
        ownership: RuntimeGenerationCandidateOwnership,
        pinnedFiles: RuntimeStorePinnedFileSet
    ) {
        derivedGenerationID = generationID
        self.databaseURL = databaseURL
        self.database = database
        self.ownership = ownership
        self.pinnedFiles = pinnedFiles
    }

    static func open(
        reservationID: String,
        migrationRunID: String,
        expectedExecutorInstanceID: String,
        candidateDirectoryURL: URL,
        authorityNowMilliseconds: Int64,
        generationManager: RuntimeStoreGenerationManager,
        controlStore: RuntimeGenerationControlStore
    ) async throws -> RuntimeGenerationCandidateDerivedGateway {
        let reservation = try await controlStore.reservation(id: reservationID)
        let run = try await controlStore.migrationRun(id: migrationRunID)
        guard run.executorInstanceID == expectedExecutorInstanceID,
              run.reservationID == reservation.reservationID,
              run.candidateGenerationID == reservation.candidateGenerationID,
              run.operationKind == .projectionRebuild,
              reservation.operationKind == .projectionRebuild else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
        let ownership = try await generationManager.acquireDerivedCandidateOwnership(
            reservation: reservation,
            run: run,
            candidateDirectoryURL: candidateDirectoryURL,
            authorityNowMilliseconds: authorityNowMilliseconds
        )
        let databaseURL = ownership.databaseURL
        let preOpenFiles: RuntimeStorePinnedFileSet
        do {
            try RuntimeStoreFileDurability.requireRegularNonSymbolicFile(
                at: databaseURL,
                artifact: "derived_candidate_database"
            )
            try RuntimeStoreFileDurability.requireCompleteProtection(
                at: databaseURL,
                artifact: "derived_candidate_database"
            )
            preOpenFiles = try RuntimeStorePinnedFileSet.capture(databaseURL: databaseURL)
        } catch {
            try await closeOwnershipAfterFailedOpen(ownership, precedingError: error)
        }

        let database: SQLiteDatabase
        do {
            database = try SQLiteDatabase(
                url: databaseURL,
                configuration: CanonicalRuntimeStore.sqliteConfiguration(
                    openMode: .existingOnly
                )
            )
        } catch {
            try await closeOwnershipAfterFailedOpen(ownership, precedingError: error)
        }

        do {
            for (url, artifact) in [
                (databaseURL, "derived_candidate_database"),
                (URL(fileURLWithPath: databaseURL.path + "-wal"), "derived_candidate_wal"),
                (URL(fileURLWithPath: databaseURL.path + "-shm"), "derived_candidate_shm"),
            ] where FileManager.default.fileExists(atPath: url.path) {
                try RuntimeStoreFileDurability.applyCompleteProtection(
                    at: url, artifact: artifact
                )
                try RuntimeStoreFileDurability.synchronizeFile(at: url)
            }
            let postOpenFiles = try RuntimeStorePinnedFileSet.capture(databaseURL: databaseURL)
            try postOpenFiles.requireCompatiblePreOpenIdentity(preOpenFiles)
            try await ownership.revalidate(pinnedFiles: postOpenFiles)
            try await database.transaction(.deferred) { database in
                try Task.checkCancellation()
                try requireCandidateIdentity(
                    generationID: reservation.candidateGenerationID,
                    database: database
                )
                _ = try RuntimeGenerationDatabaseAuthority
                    .boundedAuthorityFenceTokenInTransaction(
                        database: database,
                        generationID: reservation.candidateGenerationID
                    )
            }
            return RuntimeGenerationCandidateDerivedGateway(
                generationID: reservation.candidateGenerationID,
                databaseURL: databaseURL,
                database: database,
                ownership: ownership,
                pinnedFiles: postOpenFiles
            )
        } catch {
            let precedingError = error
            var closeFailed = false
            do { try await database.close() } catch { closeFailed = true }
            do { try await ownership.close() } catch { closeFailed = true }
            if closeFailed {
                throw RuntimeGenerationControlError.derivedCandidateCloseFailed
            }
            throw precedingError
        }
    }

    func withDerivedImmediateTransaction<Result: Sendable>(
        _ operation: @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Result
    ) async throws -> Result {
        try await ownership.revalidate(pinnedFiles: pinnedFiles)
        let transactionGenerationID = derivedGenerationID
        return try await database.transaction(
            .immediate,
            writeAuthorization: try RuntimeCanonicalDerivedWriteAuthority.sqlite,
            invariantCapture: { database in
                try RuntimeGenerationControlCodec.encode(
                    RuntimeGenerationDatabaseAuthority
                        .boundedAuthorityFenceTokenInTransaction(
                            database: database,
                            generationID: transactionGenerationID
                        )
                )
            },
            validateInvariant: { before, after in
                guard before == after else {
                    throw RuntimeGenerationControlError.derivedCanonicalMutationDenied
                }
            }
        ) { database in
            try Task.checkCancellation()
            try Self.requireCandidateIdentity(
                generationID: derivedGenerationID,
                database: database
            )
            let result = try operation(database)
            try Task.checkCancellation()
            return result
        }
    }

    func close() async throws {
        var closeFailed = false
        do { try await database.close() } catch { closeFailed = true }
        do { try await ownership.close() } catch { closeFailed = true }
        if closeFailed {
            throw RuntimeGenerationControlError.derivedCandidateCloseFailed
        }
    }

    private static func closeOwnershipAfterFailedOpen(
        _ ownership: RuntimeGenerationCandidateOwnership,
        precedingError: Error
    ) async throws -> Never {
        do {
            try await ownership.close()
        } catch {
            throw RuntimeGenerationControlError.derivedCandidateCloseFailed
        }
        throw precedingError
    }

    private static func requireCandidateIdentity(
        generationID: RuntimeStoreGenerationID,
        database: isolated SQLiteDatabase
    ) throws {
        try CanonicalRuntimeAttachmentSchemaPlan.requireIntegratedSchema(in: database)
        let rows = try database.query(
            "SELECT generation_id FROM runtime_store_metadata WHERE singleton_id = 1 LIMIT 2",
            maximumDecodedBytes: RuntimeGenerationDatabaseAuthority.pageByteBudget
        )
        guard rows.count == 1,
              rows[0].value(named: "generation_id") == .text(generationID.rawValue) else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
    }
}
