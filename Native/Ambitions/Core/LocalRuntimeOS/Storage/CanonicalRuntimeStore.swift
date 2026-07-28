import AmbitionsRuntimeSQLite
import Foundation

struct CanonicalRuntimeStoreMetadata: Sendable, Equatable {
    let schemaVersion: Int
    let generationID: RuntimeStoreGenerationID
    let createdAtMillisecondsSince1970: Int64
}

struct CanonicalRuntimeSchemaInspection: Sendable, Equatable {
    let expectedTables: Set<String>
    let observedRuntimeTables: Set<String>
    let expectedIndexes: Set<String>
    let observedRuntimeIndexes: Set<String>

    var missingTables: Set<String> {
        expectedTables.subtracting(observedRuntimeTables)
    }

    var unexpectedTables: Set<String> {
        observedRuntimeTables.subtracting(expectedTables)
    }

    var isExact: Bool {
        missingTables.isEmpty && unexpectedTables.isEmpty &&
            expectedIndexes == observedRuntimeIndexes
    }
}

struct CanonicalRuntimeStoreHealth: Sendable, Equatable {
    let metadata: CanonicalRuntimeStoreMetadata
    let schema: CanonicalRuntimeSchemaInspection
    let foreignKeysEnabled: Bool
    let usesWriteAheadLogging: Bool
    let usesFullSynchronization: Bool
    let effectiveUserVersion: Int
    let databaseIdentityVerified: Bool
    let pinnedGenerationDirectoryURL: URL

    var isStructurallyHealthy: Bool {
        schema.isExact &&
            foreignKeysEnabled &&
            usesWriteAheadLogging &&
            usesFullSynchronization &&
            effectiveUserVersion == canonicalRuntimeStoreSchemaVersion &&
            databaseIdentityVerified
    }
}

/// The result of an intentionally exhaustive maintenance scan.
///
/// Unlike `health()`, this operation has no latency or row-count bound. It is
/// suitable only for explicit maintenance/recovery workflows that can surface
/// progress and cancellation to the user; it must never be placed on launch or
/// an interactive read path.
struct CanonicalRuntimeStoreFullAudit: Sendable, Equatable {
    let integrity: SQLiteIntegrityResult
    let foreignKeyViolations: [SQLiteForeignKeyViolation]
    let databaseIdentityVerified: Bool

    var isValid: Bool {
        integrity.isOK &&
            foreignKeyViolations.isEmpty &&
            databaseIdentityVerified
    }
}

struct CanonicalRuntimeReadTransaction: Sendable, Equatable {
    let metadata: CanonicalRuntimeStoreMetadata
    let schema: CanonicalRuntimeSchemaInspection
    let foreignKeysEnabled: Bool
    let usesWriteAheadLogging: Bool
    let usesFullSynchronization: Bool
    let effectiveUserVersion: Int
}

struct CanonicalRuntimeEventCursor: Codable, Sendable, Equatable, Hashable {
    let sequence: Int64
    let eventID: String

    init(sequence: Int64, eventID: String) throws {
        guard sequence > 0, eventID.isEmpty == false else {
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }
        self.sequence = sequence
        self.eventID = eventID
    }
}

struct CanonicalRuntimeEventRecord: Sendable, Equatable {
    let sequence: Int64
    let eventID: String
    let commandID: String
    let aggregateKind: String
    let aggregateID: String
    let correlationID: String?
    let causationEventID: String?
    let eventVersion: Int
    let payload: Data
    let payloadChecksum: String
    let previousEventHash: String?
    let eventHash: String

    var cursor: CanonicalRuntimeEventCursor {
        get throws {
            try CanonicalRuntimeEventCursor(
                sequence: sequence,
                eventID: eventID
            )
        }
    }
}

struct CanonicalRuntimeObjectID: Codable, Sendable, Equatable, Hashable {
    let kind: String
    let id: String

    init(kind: String, id: String) throws {
        guard kind.isEmpty == false, id.isEmpty == false else {
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }
        self.kind = kind
        self.id = id
    }
}

struct CanonicalRuntimeTombstoneCursor: Codable, Sendable, Equatable, Hashable {
    let sequence: Int64
    let objectID: CanonicalRuntimeObjectID

    init(sequence: Int64, objectID: CanonicalRuntimeObjectID) throws {
        guard sequence > 0 else {
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }
        self.sequence = sequence
        self.objectID = objectID
    }
}

struct CanonicalRuntimeTombstoneRecord: Sendable, Equatable {
    let objectID: CanonicalRuntimeObjectID
    let revision: Int64
    let causalEventSequence: Int64
    let tombstoneVersion: Int
    let payload: Data
    let checksum: String

    var cursor: CanonicalRuntimeTombstoneCursor {
        get throws {
            try CanonicalRuntimeTombstoneCursor(
                sequence: causalEventSequence,
                objectID: objectID
            )
        }
    }
}

struct CanonicalRuntimePage<Item: Sendable & Equatable, Cursor: Sendable & Equatable>: Sendable, Equatable {
    let items: [Item]
    let nextCursor: Cursor?
}

actor CanonicalRuntimeStore {
    static let maximumPageLimit = 200
    static let defaultPageLimit = 50
    static let maximumSQLiteValueBytes: Int32 = 1_048_576
    static let maximumReadPageBytes = 4_194_304

    static func sqliteConfiguration(
        openMode: SQLiteOpenMode
    ) -> SQLiteConfiguration {
        SQLiteConfiguration(
            synchronousPolicy: .full,
            openMode: openMode,
            maximumValueBytes: maximumSQLiteValueBytes
        )
    }

    let generationID: RuntimeStoreGenerationID
    let pinnedGenerationDirectoryURL: URL
    let databaseURL: URL

    private let database: SQLiteDatabase
    private let pinnedFiles: RuntimeStorePinnedFileSet
    private let expectedDatabaseIdentitySHA256: String

    private init(
        generationID: RuntimeStoreGenerationID,
        pinnedGenerationDirectoryURL: URL,
        databaseURL: URL,
        database: SQLiteDatabase,
        pinnedFiles: RuntimeStorePinnedFileSet,
        expectedDatabaseIdentitySHA256: String
    ) {
        self.generationID = generationID
        self.pinnedGenerationDirectoryURL = pinnedGenerationDirectoryURL
        self.databaseURL = databaseURL
        self.database = database
        self.pinnedFiles = pinnedFiles
        self.expectedDatabaseIdentitySHA256 = expectedDatabaseIdentitySHA256
    }

    /// Grants canonical read subsystems a non-reentrant transaction without
    /// exposing or returning the owned SQLite connection.
    func withCanonicalReadTransaction<Result: Sendable>(
        _ operation: @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Result
    ) async throws -> Result {
        try pinnedFiles.validate(databaseURL: databaseURL)
        do {
            let result = try await database.transaction(.deferred) { database in
                try Task.checkCancellation()
                try Self.requireCompiledIdentity(
                    database, expected: expectedDatabaseIdentitySHA256
                )
                return try operation(database)
            }
            try pinnedFiles.validate(databaseURL: databaseURL)
            return result
        } catch {
            if Self.isCanonicalDerivedDomainError(error) { throw error }
            throw Self.mapSQLiteFailure(error, operation: "canonical_derived_read")
        }
    }

    /// Grants projection/search maintenance one immediate transaction. SQLite
    /// independently denies writes outside the derived-state table capability,
    /// including trigger writes. A canonical fence is compared before commit
    /// so a future schema/allowlist error cannot silently mutate authority.
    func withDerivedImmediateTransaction<Result: Sendable>(
        _ operation: @Sendable (
            _ database: isolated SQLiteDatabase
        ) throws -> Result
    ) async throws -> Result {
        try pinnedFiles.validate(databaseURL: databaseURL)
        do {
            let transactionGenerationID = generationID
            let transactionIdentityDigest = expectedDatabaseIdentitySHA256
            let result = try await database.transaction(
                .immediate,
                writeAuthorization: try RuntimeCanonicalDerivedWriteAuthority.sqlite,
                invariantCapture: { database in
                    try RuntimeGenerationControlCodec.encode(
                        RuntimeGenerationDatabaseAuthority.revisionFenceInTransaction(
                            database: database,
                            generationID: transactionGenerationID,
                            generationDigest: transactionIdentityDigest
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
                try Self.requireCompiledIdentity(
                    database, expected: expectedDatabaseIdentitySHA256
                )
                let value = try operation(database)
                try Task.checkCancellation()
                return value
            }
            // Parity with `withAtomicCommitTransaction`: once COMMIT succeeds,
            // no throwable pin check may convert durable progress into a false
            // failure. The next operation revalidates the pinned files before
            // opening its transaction; read-only transactions remain symmetric
            // because they establish no durable result.
            return result
        } catch {
            if Self.isCanonicalDerivedDomainError(error) { throw error }
            throw Self.mapSQLiteFailure(error, operation: "canonical_derived_write")
        }
    }

    private static func isCanonicalDerivedDomainError(_ error: Error) -> Bool {
        error is RuntimeCanonicalProjectionPersistenceError ||
            error is RuntimeCanonicalSearchError ||
            error is RuntimeCanonicalReplayError ||
            error is RuntimeCanonicalProjectionSourceError ||
            error is RuntimeCommittedReceiptQueryError ||
            error is RuntimeCommittedReceiptAuthorityError ||
            error is RuntimeCommittedReceiptCodecError ||
            error is RuntimeCanonicalExternalOperationError ||
            error is RuntimeAtomicCommitError ||
            error is CancellationError ||
            error is LocalRuntimeStorageError
    }

#if AMBITIONS_LEGACY_RUNTIME_TEST_SUPPORT
    static func openActive(
        using generationManager: RuntimeStoreGenerationManager
    ) async throws -> CanonicalRuntimeStore {
        let generation = try await generationManager.resolveActiveGeneration()
        return try await openPinnedGeneration(generation)
    }
#endif

    static func openPinnedGeneration(
        _ generation: ResolvedRuntimeStoreGeneration
    ) async throws -> CanonicalRuntimeStore {
        try RuntimeStorePathValidation.requireSafeComponent(
            generation.manifest.generationID.pathComponent
        )
        let expectedDatabaseURL = generation.generationDirectoryURL
            .appendingPathComponent("Runtime.sqlite", isDirectory: false)
            .standardizedFileURL
        guard generation.generationDirectoryURL.lastPathComponent ==
                generation.manifest.generationID.pathComponent,
              generation.databaseURL.standardizedFileURL == expectedDatabaseURL
        else {
            throw LocalRuntimeStorageError.canonicalManifestMismatch(
                field: "resolved_generation_path"
            )
        }
        try RuntimeStoreFileDurability.requireDirectory(
            at: generation.generationDirectoryURL,
            artifact: "pinned_generation_directory"
        )
        try RuntimeStoreFileDurability.requireRegularNonSymbolicFile(
            at: generation.databaseURL,
            artifact: "pinned_database"
        )
        try RuntimeStoreFileDurability.requireCompleteProtection(
            at: generation.generationDirectoryURL,
            artifact: "pinned_generation_directory"
        )
        try RuntimeStoreFileDurability.requireCompleteProtection(
            at: generation.databaseURL,
            artifact: "pinned_database"
        )
        let headerSchemaVersion = try RuntimeStoreSQLiteHeader.schemaVersion(
            at: generation.databaseURL
        )
        guard headerSchemaVersion <= canonicalRuntimeStoreSchemaVersion else {
            throw LocalRuntimeStorageError.canonicalFutureDatabaseSchema(
                maximumSupported: canonicalRuntimeStoreSchemaVersion,
                actual: headerSchemaVersion
            )
        }
        guard headerSchemaVersion == canonicalRuntimeStoreSchemaVersion else {
            throw LocalRuntimeStorageError.canonicalUnsupportedDatabaseSchema(
                expected: canonicalRuntimeStoreSchemaVersion,
                actual: headerSchemaVersion
            )
        }

        try generation.pinnedFiles.validate(
            databaseURL: generation.databaseURL
        )
        let database = generation.verifiedDatabase
        do {
            try generation.pinnedFiles.validate(databaseURL: generation.databaseURL)
        } catch {
            throw mapSQLiteFailure(error, operation: "open_pinned_canonical_store")
        }

        let transaction: CanonicalRuntimeReadTransaction
        do {
            transaction = try await database.transaction(.deferred) { database in
                try inspectReadTransaction(database)
            }
        } catch {
            throw mapSQLiteFailure(error, operation: "inspect_canonical_store")
        }
        let expectedCreatedAt = try millisecondsSince1970(
            generation.manifest.activatedAt
        )
        guard transaction.metadata.generationID == generation.manifest.generationID else {
            throw LocalRuntimeStorageError.canonicalManifestMismatch(
                field: "generation_id"
            )
        }
        guard transaction.metadata.schemaVersion == generation.manifest.schemaVersion else {
            throw LocalRuntimeStorageError.canonicalManifestMismatch(
                field: "schema_version"
            )
        }
        guard transaction.effectiveUserVersion <= canonicalRuntimeStoreSchemaVersion else {
            throw LocalRuntimeStorageError.canonicalFutureDatabaseSchema(
                maximumSupported: canonicalRuntimeStoreSchemaVersion,
                actual: transaction.effectiveUserVersion
            )
        }
        guard transaction.effectiveUserVersion == canonicalRuntimeStoreSchemaVersion,
              transaction.effectiveUserVersion == generation.manifest.schemaVersion
        else {
            throw LocalRuntimeStorageError.canonicalUnsupportedDatabaseSchema(
                expected: canonicalRuntimeStoreSchemaVersion,
                actual: transaction.effectiveUserVersion
            )
        }
        guard transaction.metadata.createdAtMillisecondsSince1970 == expectedCreatedAt else {
            throw LocalRuntimeStorageError.canonicalManifestMismatch(
                field: "activated_at"
            )
        }
        guard transaction.schema.isExact,
              transaction.foreignKeysEnabled,
              transaction.usesWriteAheadLogging,
              transaction.usesFullSynchronization
        else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        let observedDatabaseIdentitySHA256: String
        do {
            observedDatabaseIdentitySHA256 = try await databaseIdentitySHA256(
                in: database
            )
        } catch {
            throw mapSQLiteFailure(
                error,
                operation: "verify_canonical_database_identity"
            )
        }
        guard observedDatabaseIdentitySHA256 == generation.manifest.databaseIdentitySHA256 else {
            throw LocalRuntimeStorageError.canonicalManifestUnverified
        }
        let expectedGenerationDigest = RuntimeStoreManifestCodec.generationDigest(
            formatVersion: generation.manifest.formatVersion,
            generationID: generation.manifest.generationID,
            relativeDatabasePath: generation.manifest.relativeDatabasePath,
            schemaVersion: generation.manifest.schemaVersion,
            activatedAtMilliseconds: expectedCreatedAt,
            databaseIdentitySHA256: observedDatabaseIdentitySHA256,
            priorGenerationID: generation.manifest.priorGenerationID,
            priorGenerationDigestSHA256: generation.manifest.priorGenerationDigestSHA256
        )
        guard expectedGenerationDigest == generation.manifest.generationDigestSHA256 else {
            throw LocalRuntimeStorageError.canonicalManifestUnverified
        }

        try applyCompleteProtectionToOpenArtifacts(
            databaseURL: generation.databaseURL,
            generationDirectoryURL: generation.generationDirectoryURL
        )
        try generation.pinnedFiles.validate(databaseURL: generation.databaseURL)
        return CanonicalRuntimeStore(
            generationID: generation.manifest.generationID,
            pinnedGenerationDirectoryURL: generation.generationDirectoryURL,
            databaseURL: generation.databaseURL,
            database: database,
            pinnedFiles: generation.pinnedFiles,
            expectedDatabaseIdentitySHA256: generation.manifest.databaseIdentitySHA256
        )
    }

    func withReadTransaction<Result: Sendable>(
        _ operation: @Sendable (CanonicalRuntimeReadTransaction) throws -> Result
    ) async throws -> Result {
        try pinnedFiles.validate(databaseURL: databaseURL)
        do {
            let result = try await database.transaction(.deferred) { database in
                let transaction = try Self.inspectReadTransaction(database)
                try Self.requireCompiledIdentity(
                    database,
                    expected: expectedDatabaseIdentitySHA256
                )
                return try operation(transaction)
            }
            try pinnedFiles.validate(databaseURL: databaseURL)
            return result
        } catch {
            throw Self.mapSQLiteFailure(
                error,
                operation: "canonical_read_transaction"
            )
        }
    }

    /// The sole composition seam for canonical authority writes. The closure
    /// is synchronous and isolated to the retained SQLite actor, so no handle
    /// escapes and no suspension can split the authority transaction.
    func withAtomicCommitTransaction<Result: Sendable>(
        _ operation: @Sendable (isolated SQLiteDatabase) throws -> Result
    ) async throws -> Result {
        try pinnedFiles.validate(databaseURL: databaseURL)
        do {
            let result = try await database.transaction(
                .immediate,
                writeAuthorization: try CanonicalRuntimeAtomicCommitWriteAuthority.sqlite
            ) { database in
                try Task.checkCancellation()
                return try operation(database)
            }
            // Nothing throwable may run after SQLite reports COMMIT. The
            // finalized result is already authority and must be returned even
            // if cancellation or later maintenance work becomes pending.
            return result
        } catch {
            if error is RuntimeAtomicCommitError ||
                error is CanonicalRuntimeTransactionError ||
                error is CanonicalRuntimeSemanticEventStoreError ||
                error is CancellationError {
                throw error
            }
            throw Self.mapSQLiteFailure(error, operation: "canonical_atomic_commit")
        }
    }

    func health() async throws -> CanonicalRuntimeStoreHealth {
        try pinnedFiles.validate(databaseURL: databaseURL)
        let snapshot: (CanonicalRuntimeReadTransaction, String)
        do {
            snapshot = try await database.transaction(.deferred) { database in
                let transaction = try Self.inspectReadTransaction(database)
                let identity = try Self.databaseIdentitySHA256(from: database)
                return (transaction, identity)
            }
        } catch {
            throw Self.mapSQLiteFailure(error, operation: "canonical_health")
        }
        try pinnedFiles.validate(databaseURL: databaseURL)
        return CanonicalRuntimeStoreHealth(
            metadata: snapshot.0.metadata,
            schema: snapshot.0.schema,
            foreignKeysEnabled: snapshot.0.foreignKeysEnabled,
            usesWriteAheadLogging: snapshot.0.usesWriteAheadLogging,
            usesFullSynchronization: snapshot.0.usesFullSynchronization,
            effectiveUserVersion: snapshot.0.effectiveUserVersion,
            databaseIdentityVerified: snapshot.1 == expectedDatabaseIdentitySHA256,
            pinnedGenerationDirectoryURL: pinnedGenerationDirectoryURL
        )
    }

    /// Performs an unbounded, full-database integrity and foreign-key audit.
    /// Callers must treat this as maintenance work, never as a health probe.
    func fullMaintenanceAudit() async throws -> CanonicalRuntimeStoreFullAudit {
        try pinnedFiles.validate(databaseURL: databaseURL)
        let audit: CanonicalRuntimeStoreFullAudit
        do {
            audit = try await database.transaction(.deferred) { database in
                let integrity = try database.integrityCheck()
                let foreignKeyViolations = try database.foreignKeyCheck()
                let identity = try Self.databaseIdentitySHA256(from: database)
                return CanonicalRuntimeStoreFullAudit(
                    integrity: integrity,
                    foreignKeyViolations: foreignKeyViolations,
                    databaseIdentityVerified:
                        identity == expectedDatabaseIdentitySHA256
                )
            }
        } catch {
            throw Self.mapSQLiteFailure(
                error,
                operation: "canonical_full_maintenance_audit"
            )
        }
        try pinnedFiles.validate(databaseURL: databaseURL)
        return audit
    }

    func events(
        after cursor: CanonicalRuntimeEventCursor? = nil,
        limit: Int = CanonicalRuntimeStore.defaultPageLimit
    ) async throws -> CanonicalRuntimePage<CanonicalRuntimeEventRecord, CanonicalRuntimeEventCursor> {
        try pinnedFiles.validate(databaseURL: databaseURL)
        let boundedLimit = Self.boundedPageLimit(limit)
        do {
            let page = try await database.transaction(.deferred) { database in
                try Self.requireCompiledIdentity(database, expected: expectedDatabaseIdentitySHA256)
                let page = try Self.readEvents(
                    from: database,
                    after: cursor,
                    limit: boundedLimit
                )
                try Self.requireCompiledIdentity(database, expected: expectedDatabaseIdentitySHA256)
                return page
            }
            try pinnedFiles.validate(databaseURL: databaseURL)
            return page
        } catch {
            throw Self.mapSQLiteFailure(error, operation: "read_event_page")
        }
    }

    func tombstones(
        after cursor: CanonicalRuntimeTombstoneCursor? = nil,
        limit: Int = CanonicalRuntimeStore.defaultPageLimit
    ) async throws -> CanonicalRuntimePage<CanonicalRuntimeTombstoneRecord, CanonicalRuntimeTombstoneCursor> {
        try pinnedFiles.validate(databaseURL: databaseURL)
        let boundedLimit = Self.boundedPageLimit(limit)
        do {
            let page = try await database.transaction(.deferred) { database in
                try Self.requireCompiledIdentity(database, expected: expectedDatabaseIdentitySHA256)
                let page = try Self.readTombstones(
                    from: database,
                    after: cursor,
                    limit: boundedLimit
                )
                try Self.requireCompiledIdentity(database, expected: expectedDatabaseIdentitySHA256)
                return page
            }
            try pinnedFiles.validate(databaseURL: databaseURL)
            return page
        } catch {
            throw Self.mapSQLiteFailure(
                error,
                operation: "read_tombstone_page"
            )
        }
    }
}

extension CanonicalRuntimeStore {
    static let expectedRuntimeTables: Set<String> = [
        "runtime_store_metadata",
        "runtime_aggregates",
        "runtime_events",
        "runtime_command_idempotency",
        "runtime_receipts",
        "runtime_projection_checkpoints",
        "runtime_projection_invalidations",
        "runtime_external_operations",
        "runtime_blob_records",
        "runtime_blob_references",
        "runtime_tombstones",
    ]

    static let expectedRuntimeIndexes: Set<String> = [
        "runtime_events_command_sequence_idx",
        "runtime_events_aggregate_sequence_idx",
        "runtime_events_correlation_sequence_idx",
        "runtime_projection_invalidations_projection_id_idx",
        "runtime_external_operations_retry_idx",
        "runtime_blob_references_owner_idx",
        "runtime_tombstones_causal_object_idx",
    ]

    static let schemaStatements: [String] = [
        """
        CREATE TABLE runtime_store_metadata (
            singleton_id INTEGER PRIMARY KEY CHECK (singleton_id = 1),
            schema_version INTEGER NOT NULL CHECK (schema_version > 0),
            generation_id TEXT NOT NULL UNIQUE CHECK (length(generation_id) > 0),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0)
        )
        """,
        """
        CREATE TABLE runtime_aggregates (
            aggregate_kind TEXT NOT NULL CHECK (length(aggregate_kind) > 0),
            aggregate_id TEXT NOT NULL CHECK (length(aggregate_id) > 0),
            revision INTEGER NOT NULL CHECK (revision >= 0),
            payload_version INTEGER NOT NULL CHECK (payload_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            PRIMARY KEY (aggregate_kind, aggregate_id)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_events (
            sequence INTEGER PRIMARY KEY AUTOINCREMENT,
            event_id TEXT NOT NULL UNIQUE CHECK (length(event_id) > 0),
            command_id TEXT NOT NULL CHECK (length(command_id) > 0),
            aggregate_kind TEXT NOT NULL CHECK (length(aggregate_kind) > 0),
            aggregate_id TEXT NOT NULL CHECK (length(aggregate_id) > 0),
            correlation_id TEXT,
            causation_event_id TEXT,
            event_version INTEGER NOT NULL CHECK (event_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            previous_event_hash TEXT CHECK (previous_event_hash IS NULL OR (length(previous_event_hash) = 64 AND previous_event_hash NOT GLOB '*[^0-9a-f]*')),
            event_hash TEXT NOT NULL UNIQUE CHECK (length(event_hash) = 64 AND event_hash NOT GLOB '*[^0-9a-f]*'),
            recorded_at_ms INTEGER NOT NULL CHECK (recorded_at_ms >= 0),
            FOREIGN KEY (aggregate_kind, aggregate_id)
                REFERENCES runtime_aggregates(aggregate_kind, aggregate_id),
            FOREIGN KEY (command_id)
                REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (causation_event_id)
                REFERENCES runtime_events(event_id)
        )
        """,
        "CREATE INDEX runtime_events_command_sequence_idx ON runtime_events(command_id, sequence)",
        "CREATE INDEX runtime_events_aggregate_sequence_idx ON runtime_events(aggregate_kind, aggregate_id, sequence)",
        "CREATE INDEX runtime_events_correlation_sequence_idx ON runtime_events(correlation_id, sequence) WHERE correlation_id IS NOT NULL",
        """
        CREATE TABLE runtime_command_idempotency (
            scope TEXT NOT NULL CHECK (length(scope) > 0),
            idempotency_key TEXT NOT NULL CHECK (length(idempotency_key) > 0),
            command_id TEXT NOT NULL UNIQUE CHECK (length(command_id) > 0),
            command_fingerprint TEXT NOT NULL CHECK (length(command_fingerprint) = 64 AND command_fingerprint NOT GLOB '*[^0-9a-f]*'),
            claim_version INTEGER NOT NULL CHECK (claim_version > 0),
            claim_payload BLOB NOT NULL,
            claimed_at_ms INTEGER NOT NULL CHECK (claimed_at_ms >= 0),
            final_result_version INTEGER CHECK (final_result_version IS NULL OR final_result_version > 0),
            final_result_payload BLOB,
            final_result_checksum TEXT CHECK (final_result_checksum IS NULL OR (length(final_result_checksum) = 64 AND final_result_checksum NOT GLOB '*[^0-9a-f]*')),
            finalized_at_ms INTEGER CHECK (finalized_at_ms IS NULL OR finalized_at_ms >= claimed_at_ms),
            CHECK (
                (final_result_version IS NULL AND final_result_payload IS NULL AND final_result_checksum IS NULL AND finalized_at_ms IS NULL)
                OR
                (final_result_version IS NOT NULL AND final_result_payload IS NOT NULL AND final_result_checksum IS NOT NULL AND finalized_at_ms IS NOT NULL)
            ),
            PRIMARY KEY (scope, idempotency_key)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_receipts (
            receipt_id TEXT PRIMARY KEY CHECK (length(receipt_id) > 0),
            command_id TEXT NOT NULL UNIQUE,
            committed_event_sequence INTEGER NOT NULL CHECK (committed_event_sequence > 0),
            receipt_version INTEGER NOT NULL CHECK (receipt_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            FOREIGN KEY (command_id)
                REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (committed_event_sequence)
                REFERENCES runtime_events(sequence)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_projection_checkpoints (
            projection_id TEXT PRIMARY KEY CHECK (length(projection_id) > 0),
            last_event_sequence INTEGER NOT NULL DEFAULT 0 CHECK (last_event_sequence >= 0),
            cursor_stable_id TEXT NOT NULL CHECK (length(cursor_stable_id) > 0),
            cursor_checksum TEXT NOT NULL CHECK (length(cursor_checksum) = 64 AND cursor_checksum NOT GLOB '*[^0-9a-f]*'),
            projection_version INTEGER NOT NULL CHECK (projection_version > 0),
            updated_at_ms INTEGER NOT NULL CHECK (updated_at_ms >= 0)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_projection_invalidations (
            invalidation_id INTEGER PRIMARY KEY AUTOINCREMENT,
            projection_id TEXT NOT NULL CHECK (length(projection_id) > 0),
            causal_event_sequence INTEGER NOT NULL CHECK (causal_event_sequence > 0),
            reason TEXT NOT NULL CHECK (length(reason) > 0),
            invalidation_version INTEGER NOT NULL CHECK (invalidation_version > 0),
            payload BLOB NOT NULL,
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            FOREIGN KEY (projection_id)
                REFERENCES runtime_projection_checkpoints(projection_id),
            FOREIGN KEY (causal_event_sequence)
                REFERENCES runtime_events(sequence)
        )
        """,
        "CREATE INDEX runtime_projection_invalidations_projection_id_idx ON runtime_projection_invalidations(projection_id, invalidation_id)",
        """
        CREATE TABLE runtime_external_operations (
            operation_id TEXT PRIMARY KEY CHECK (length(operation_id) > 0),
            command_id TEXT NOT NULL,
            receipt_id TEXT,
            operation_kind TEXT NOT NULL CHECK (length(operation_kind) > 0),
            status TEXT NOT NULL CHECK (length(status) > 0),
            operation_version INTEGER NOT NULL CHECK (operation_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            attempt_count INTEGER NOT NULL DEFAULT 0 CHECK (attempt_count >= 0),
            next_retry_at_ms INTEGER CHECK (next_retry_at_ms IS NULL OR next_retry_at_ms >= 0),
            updated_at_ms INTEGER NOT NULL CHECK (updated_at_ms >= 0),
            FOREIGN KEY (command_id)
                REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (receipt_id)
                REFERENCES runtime_receipts(receipt_id)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_external_operations_retry_idx ON runtime_external_operations(status, next_retry_at_ms, operation_id) WHERE next_retry_at_ms IS NOT NULL",
        """
        CREATE TABLE runtime_blob_records (
            blob_id TEXT PRIMARY KEY CHECK (length(blob_id) > 0),
            checksum TEXT NOT NULL UNIQUE CHECK (length(checksum) = 64 AND checksum NOT GLOB '*[^0-9a-f]*'),
            byte_count INTEGER NOT NULL CHECK (byte_count >= 0),
            media_type TEXT,
            protection_class TEXT NOT NULL CHECK (length(protection_class) > 0),
            declared_reference_count INTEGER NOT NULL DEFAULT 0 CHECK (declared_reference_count >= 0),
            created_event_sequence INTEGER NOT NULL CHECK (created_event_sequence > 0),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            FOREIGN KEY (created_event_sequence)
                REFERENCES runtime_events(sequence)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_blob_references (
            blob_id TEXT NOT NULL,
            owner_kind TEXT NOT NULL CHECK (length(owner_kind) > 0),
            owner_id TEXT NOT NULL CHECK (length(owner_id) > 0),
            reference_kind TEXT NOT NULL CHECK (length(reference_kind) > 0),
            created_event_sequence INTEGER NOT NULL CHECK (created_event_sequence > 0),
            PRIMARY KEY (blob_id, owner_kind, owner_id, reference_kind),
            FOREIGN KEY (blob_id)
                REFERENCES runtime_blob_records(blob_id) ON DELETE RESTRICT,
            FOREIGN KEY (created_event_sequence)
                REFERENCES runtime_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_blob_references_owner_idx ON runtime_blob_references(owner_kind, owner_id, blob_id)",
        """
        CREATE TABLE runtime_tombstones (
            object_kind TEXT NOT NULL CHECK (length(object_kind) > 0),
            object_id TEXT NOT NULL CHECK (length(object_id) > 0),
            revision INTEGER NOT NULL CHECK (revision >= 0),
            causal_event_sequence INTEGER NOT NULL CHECK (causal_event_sequence > 0),
            tombstone_version INTEGER NOT NULL CHECK (tombstone_version > 0),
            payload BLOB NOT NULL,
            checksum TEXT NOT NULL CHECK (length(checksum) = 64 AND checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            PRIMARY KEY (object_kind, object_id),
            FOREIGN KEY (causal_event_sequence)
                REFERENCES runtime_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_tombstones_causal_object_idx ON runtime_tombstones(causal_event_sequence, object_kind, object_id)",
    ]

    /// Decode-only legacy import may accept typed v1 rows only after proving the
    /// source has the complete compiled v1 catalog. This intentionally ignores
    /// a source's generation identity while retaining exact table, index,
    /// trigger, metadata-version, and user-version requirements.
    static func requireExactLegacyV1Schema(
        in database: isolated SQLiteDatabase
    ) throws {
        let inspection = try inspectReadTransaction(database)
        guard inspection.schema.isExact,
              inspection.metadata.schemaVersion == 1,
              inspection.effectiveUserVersion == 1,
              inspection.foreignKeysEnabled else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        let rows = try database.query(
            """
            SELECT type, name, sql FROM sqlite_schema
            WHERE name LIKE 'runtime_%'
            ORDER BY type, name LIMIT 256
            """
        )
        guard rows.isEmpty == false, rows.count < 256 else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        let observed = try Set(rows.map {
            normalizedSchemaSQL(try text($0, named: "sql"))
        })
        guard observed == Set(schemaStatements.map(normalizedSchemaSQL)) else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
    }

    static func installSchema(
        in database: SQLiteDatabase,
        generationID: RuntimeStoreGenerationID,
        createdAtMilliseconds: Int64
    ) async throws {
        let authorization = try schemaBootstrapAuthorization(schemaStatements)
        try await database.bootstrapTransaction(.exclusive, authorization: authorization) { database in
            for statement in schemaStatements {
                try database.execute(statement)
            }
            try database.execute(
                """
                INSERT INTO runtime_store_metadata(
                    singleton_id,
                    schema_version,
                    generation_id,
                    created_at_ms
                ) VALUES (?, ?, ?, ?)
                """,
                bindings: [
                    .integer(1),
                    .integer(Int64(canonicalRuntimeStoreSchemaVersion)),
                    .text(generationID.pathComponent),
                    .integer(createdAtMilliseconds),
                ]
            )
            try database.execute(
                "PRAGMA user_version = \(canonicalRuntimeStoreSchemaVersion)"
            )
        }
    }

    static func databaseIdentitySHA256(
        in database: SQLiteDatabase
    ) async throws -> String {
        try await database.transaction(.deferred) { database in
            try databaseIdentitySHA256(from: database)
        }
    }


    static func effectiveUserVersion(in database: SQLiteDatabase) async throws -> Int {
        try await database.transaction(.deferred) { database in
            let value = try pragmaInteger(database, sql: "PRAGMA user_version")
            guard let version = Int(exactly: value) else {
                throw LocalRuntimeStorageError.canonicalIntegrityFailure
            }
            return version
        }
    }

    /// Schema bootstrap is the sole place where the generation's compiled DDL
    /// gets authority. Normal canonical commits receive only table mutation
    /// capabilities and cannot create, alter, or drop schema objects.
    static func schemaBootstrapAuthorization(
        _ statements: [String]
    ) throws -> SQLiteBootstrapAuthorization {
        let names = Set(try statements.map { statement in
            try schemaObjectNameForBootstrap(statement)
        })
        guard names.isEmpty == false, names.count == statements.count else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        return try SQLiteBootstrapAuthorization(allowedSchemaObjects: names)
    }

    private static func schemaObjectNameForBootstrap(
        _ statement: String
    ) throws -> String {
        let tokens = statement.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        guard tokens.first == "CREATE" else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        let name: String?
        if tokens.count > 2,
           tokens[1] == "TABLE" || tokens[1] == "TRIGGER" || tokens[1] == "INDEX" {
            name = tokens[2]
        } else if tokens.count > 3,
                  tokens[1] == "UNIQUE", tokens[2] == "INDEX" {
            name = tokens[3]
        } else {
            name = nil
        }
        guard let name,
              name.isEmpty == false,
              name == name.lowercased() else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        return name
    }
}

/// The exact mutable catalog used by foreground commits, receipt authority,
/// external-effect authority, and attachment authority. The two replay rows
/// below are semantic-event consistency markers written by the event append
/// primitive itself; all other replay, projection, search, and control-plane
/// tables are deliberately absent.
private enum CanonicalRuntimeAtomicCommitWriteAuthority {
    static let tables: Set<String> = [
        "runtime_aggregates",
        "runtime_authority_fence",
        "runtime_command_idempotency",
        "runtime_replay_quarantine_occurrences",
        "runtime_replay_verified_high_water",
    ]
        .union(CanonicalRuntimeSemanticEventSchemaPlan.tables)
        .union(CanonicalRuntimeCommitSchemaPlan.tables)
        .union(CanonicalRuntimeCommittedReceiptSchemaPlan.tables)
        .union(CanonicalRuntimeExternalOperationSchemaPlan.tables)
        .union(CanonicalRuntimeAttachmentSchemaPlan.tables)

    static let readableTables: Set<String> = tables.union([
        "runtime_store_metadata",
        "sqlite_master",
        "sqlite_schema",
    ])

    static var sqlite: SQLiteWriteAuthorization {
        get throws {
            try SQLiteWriteAuthorization(
                allowedTables: tables,
                allowedReadTables: readableTables
            )
        }
    }
}

private extension CanonicalRuntimeStore {
    static func requireCompiledIdentity(
        _ database: isolated SQLiteDatabase,
        expected: String
    ) throws {
        guard try databaseIdentitySHA256(from: database) == expected else {
            throw LocalRuntimeStorageError.canonicalManifestUnverified
        }
    }

    static func databaseIdentitySHA256(
        from database: isolated SQLiteDatabase
    ) throws -> String {
        let inspection = try inspectReadTransaction(database)
        guard inspection.schema.isExact,
              inspection.metadata.schemaVersion == canonicalRuntimeStoreSchemaVersion,
              inspection.effectiveUserVersion == canonicalRuntimeStoreSchemaVersion,
              inspection.metadata.schemaVersion == inspection.effectiveUserVersion
        else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        let schemaRows = try database.query(
            """
            SELECT type, name, sql
            FROM sqlite_schema
            WHERE name LIKE 'runtime_%'
            ORDER BY type ASC, name ASC
            LIMIT 256
            """
        )
        guard schemaRows.isEmpty == false, schemaRows.count < 256 else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        let observedDefinitions = try Set(schemaRows.map {
            normalizedSchemaSQL(try text($0, named: "sql"))
        })
        let compiledDefinitions = Set(schemaStatements.map(normalizedSchemaSQL))
        guard observedDefinitions == compiledDefinitions else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        let compiledFingerprint = LocalRuntimeStorageChecksum.sha256Hex(
            for: compiledDefinitions.sorted().joined(separator: "\n")
        )
        var identityComponents = [
            "canonical-runtime-database-identity-v1",
            String(inspection.metadata.schemaVersion),
            inspection.metadata.generationID.rawValue,
            String(inspection.metadata.createdAtMillisecondsSince1970),
            compiledFingerprint,
        ]
        return LocalRuntimeStorageChecksum.sha256Hex(
            for: identityComponents.joined(separator: "\n")
        )
    }

    static func normalizedSchemaSQL(_ sql: String) -> String {
        sql.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    static func inspectReadTransaction(
        _ database: isolated SQLiteDatabase
    ) throws -> CanonicalRuntimeReadTransaction {
        let metadataRows = try database.query(
            """
            SELECT schema_version, generation_id, created_at_ms
            FROM runtime_store_metadata
            WHERE singleton_id = 1
            LIMIT 2
            """
        )
        guard metadataRows.count == 1 else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        let metadataRow = metadataRows[0]
        let metadata = CanonicalRuntimeStoreMetadata(
            schemaVersion: try int(metadataRow, named: "schema_version"),
            generationID: try RuntimeStoreGenerationID(
                validating: text(metadataRow, named: "generation_id")
            ),
            createdAtMillisecondsSince1970: try int64(
                metadataRow,
                named: "created_at_ms"
            )
        )

        let schemaRows = try database.query(
            """
            SELECT name
            FROM sqlite_schema
            WHERE type = 'table' AND name LIKE 'runtime_%'
            ORDER BY name ASC
            LIMIT 128
            """
        )
        let observedTables = try Set(schemaRows.map {
            try text($0, named: "name")
        })
        let indexRows = try database.query(
            """
            SELECT name
            FROM sqlite_schema
            WHERE type = 'index' AND name LIKE 'runtime_%'
            ORDER BY name ASC
            LIMIT 128
            """
        )
        let observedIndexes = try Set(indexRows.map {
            try text($0, named: "name")
        })
        let foreignKeysEnabled = try pragmaInteger(
            database,
            sql: "PRAGMA foreign_keys"
        ) == 1
        let usesWriteAheadLogging = try pragmaText(
            database,
            sql: "PRAGMA journal_mode"
        ).lowercased() == "wal"
        let usesFullSynchronization = try pragmaInteger(
            database,
            sql: "PRAGMA synchronous"
        ) == 2
        let effectiveUserVersionValue = try pragmaInteger(
            database,
            sql: "PRAGMA user_version"
        )
        guard let effectiveUserVersion = Int(exactly: effectiveUserVersionValue) else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }

        return CanonicalRuntimeReadTransaction(
            metadata: metadata,
            schema: CanonicalRuntimeSchemaInspection(
                expectedTables: expectedRuntimeTables,
                observedRuntimeTables: observedTables,
                expectedIndexes: expectedRuntimeIndexes,
                observedRuntimeIndexes: observedIndexes
            ),
            foreignKeysEnabled: foreignKeysEnabled,
            usesWriteAheadLogging: usesWriteAheadLogging,
            usesFullSynchronization: usesFullSynchronization,
            effectiveUserVersion: effectiveUserVersion
        )
    }

    static func readEvents(
        from database: isolated SQLiteDatabase,
        after cursor: CanonicalRuntimeEventCursor?,
        limit: Int
    ) throws -> CanonicalRuntimePage<CanonicalRuntimeEventRecord, CanonicalRuntimeEventCursor> {
        let sql: String
        let bindings: [SQLiteBinding]
        if let cursor {
            sql = """
                SELECT sequence, event_id, command_id, aggregate_kind,
                       aggregate_id, correlation_id, causation_event_id,
                       event_version, payload, payload_checksum,
                       previous_event_hash, event_hash
                FROM runtime_events
                WHERE sequence > ? OR (sequence = ? AND event_id > ?)
                ORDER BY sequence ASC, event_id ASC
                LIMIT ?
                """
            bindings = [
                .integer(cursor.sequence),
                .integer(cursor.sequence),
                .text(cursor.eventID),
                .integer(Int64(limit + 1)),
            ]
        } else {
            sql = """
                SELECT sequence, event_id, command_id, aggregate_kind,
                       aggregate_id, correlation_id, causation_event_id,
                       event_version, payload, payload_checksum,
                       previous_event_hash, event_hash
                FROM runtime_events
                ORDER BY sequence ASC, event_id ASC
                LIMIT ?
                """
            bindings = [.integer(Int64(limit + 1))]
        }
        let rows = try database.query(
            sql,
            bindings: bindings,
            maximumDecodedBytes: maximumReadPageBytes
        )
        var records = try rows.map {
            try eventRecord(from: $0)
        }
        let hasMore = records.count > limit
        if hasMore {
            records.removeLast(records.count - limit)
        }
        let nextCursor: CanonicalRuntimeEventCursor?
        if hasMore, let lastRecord = records.last {
            nextCursor = try lastRecord.cursor
        } else {
            nextCursor = nil
        }
        return CanonicalRuntimePage(
            items: records,
            nextCursor: nextCursor
        )
    }

    static func readTombstones(
        from database: isolated SQLiteDatabase,
        after cursor: CanonicalRuntimeTombstoneCursor?,
        limit: Int
    ) throws -> CanonicalRuntimePage<CanonicalRuntimeTombstoneRecord, CanonicalRuntimeTombstoneCursor> {
        let sql: String
        let bindings: [SQLiteBinding]
        if let cursor {
            sql = """
                SELECT object_kind, object_id, revision, causal_event_sequence,
                       tombstone_version, payload, checksum
                FROM runtime_tombstones
                WHERE causal_event_sequence > ?
                   OR (
                       causal_event_sequence = ?
                       AND (object_kind > ? OR (object_kind = ? AND object_id > ?))
                   )
                ORDER BY causal_event_sequence ASC, object_kind ASC, object_id ASC
                LIMIT ?
                """
            bindings = [
                .integer(cursor.sequence),
                .integer(cursor.sequence),
                .text(cursor.objectID.kind),
                .text(cursor.objectID.kind),
                .text(cursor.objectID.id),
                .integer(Int64(limit + 1)),
            ]
        } else {
            sql = """
                SELECT object_kind, object_id, revision, causal_event_sequence,
                       tombstone_version, payload, checksum
                FROM runtime_tombstones
                ORDER BY causal_event_sequence ASC, object_kind ASC, object_id ASC
                LIMIT ?
                """
            bindings = [.integer(Int64(limit + 1))]
        }
        let rows = try database.query(
            sql,
            bindings: bindings,
            maximumDecodedBytes: maximumReadPageBytes
        )
        var records = try rows.map {
            try tombstoneRecord(from: $0)
        }
        let hasMore = records.count > limit
        if hasMore {
            records.removeLast(records.count - limit)
        }
        let nextCursor: CanonicalRuntimeTombstoneCursor?
        if hasMore, let lastRecord = records.last {
            nextCursor = try lastRecord.cursor
        } else {
            nextCursor = nil
        }
        return CanonicalRuntimePage(
            items: records,
            nextCursor: nextCursor
        )
    }

    static func eventRecord(from row: SQLiteRow) throws -> CanonicalRuntimeEventRecord {
        CanonicalRuntimeEventRecord(
            sequence: try int64(row, named: "sequence"),
            eventID: try text(row, named: "event_id"),
            commandID: try text(row, named: "command_id"),
            aggregateKind: try text(row, named: "aggregate_kind"),
            aggregateID: try text(row, named: "aggregate_id"),
            correlationID: try optionalText(row, named: "correlation_id"),
            causationEventID: try optionalText(row, named: "causation_event_id"),
            eventVersion: try int(row, named: "event_version"),
            payload: try blob(row, named: "payload"),
            payloadChecksum: try text(row, named: "payload_checksum"),
            previousEventHash: try optionalText(row, named: "previous_event_hash"),
            eventHash: try text(row, named: "event_hash")
        )
    }

    static func tombstoneRecord(from row: SQLiteRow) throws -> CanonicalRuntimeTombstoneRecord {
        CanonicalRuntimeTombstoneRecord(
            objectID: try CanonicalRuntimeObjectID(
                kind: text(row, named: "object_kind"),
                id: text(row, named: "object_id")
            ),
            revision: try int64(row, named: "revision"),
            causalEventSequence: try int64(
                row,
                named: "causal_event_sequence"
            ),
            tombstoneVersion: try int(row, named: "tombstone_version"),
            payload: try blob(row, named: "payload"),
            checksum: try text(row, named: "checksum")
        )
    }

    static func pragmaInteger(
        _ database: isolated SQLiteDatabase,
        sql: String
    ) throws -> Int64 {
        let rows = try database.query(sql)
        guard rows.count == 1, let value = rows[0].values.first,
              case let .integer(integer) = value
        else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        return integer
    }

    static func pragmaText(
        _ database: isolated SQLiteDatabase,
        sql: String
    ) throws -> String {
        let rows = try database.query(sql)
        guard rows.count == 1, let value = rows[0].values.first,
              case let .text(text) = value
        else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        return text
    }

    static func text(_ row: SQLiteRow, named name: String) throws -> String {
        guard let value = row.value(named: name), case let .text(text) = value else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        return text
    }

    static func optionalText(_ row: SQLiteRow, named name: String) throws -> String? {
        guard let value = row.value(named: name) else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        switch value {
        case let .text(text):
            return text
        case .null:
            return nil
        default:
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
    }

    static func int64(_ row: SQLiteRow, named name: String) throws -> Int64 {
        guard let value = row.value(named: name), case let .integer(integer) = value else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        return integer
    }

    static func int(_ row: SQLiteRow, named name: String) throws -> Int {
        let value = try int64(row, named: name)
        guard let result = Int(exactly: value) else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        return result
    }

    static func blob(_ row: SQLiteRow, named name: String) throws -> Data {
        guard let value = row.value(named: name), case let .blob(data) = value else {
            throw LocalRuntimeStorageError.canonicalIntegrityFailure
        }
        return data
    }

    static func boundedPageLimit(_ requested: Int) -> Int {
        min(max(requested, 1), maximumPageLimit)
    }

    static func millisecondsSince1970(_ date: Date) throws -> Int64 {
        let milliseconds = (date.timeIntervalSince1970 * 1_000).rounded()
        guard milliseconds.isFinite,
              milliseconds >= 0,
              milliseconds < Double(Int64.max)
        else {
            throw LocalRuntimeStorageError.canonicalManifestMalformed
        }
        return Int64(milliseconds)
    }

    static func applyCompleteProtectionToOpenArtifacts(
        databaseURL: URL,
        generationDirectoryURL: URL
    ) throws {
        let fileManager = FileManager.default
        for (url, artifact) in [
            (generationDirectoryURL, "active_generation_directory"),
            (databaseURL, "active_database"),
            (URL(fileURLWithPath: databaseURL.path + "-wal"), "active_database_wal"),
            (URL(fileURLWithPath: databaseURL.path + "-shm"), "active_database_shm"),
        ] where fileManager.fileExists(atPath: url.path) {
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: url,
                artifact: artifact
            )
        }
    }

    static func mapSQLiteFailure(
        _ error: Error,
        operation: String
    ) -> LocalRuntimeStorageError {
        if let error = error as? LocalRuntimeStorageError {
            return error
        }
        if let error = error as? SQLiteQueryBudgetExceeded {
            return .canonicalReadPageTooLarge(maximumBytes: error.maximumBytes)
        }
        guard let error = error as? SQLiteError else {
            return .canonicalIOFailure(operation: operation)
        }
        switch error.primaryCode {
        case 13:
            return .canonicalStorageFull(operation: operation)
        case 8, 10, 14:
            return .canonicalIOFailure(operation: operation)
        default:
            return .canonicalSQLiteFailure(
                operation: operation,
                code: error.primaryCode,
                extendedCode: error.extendedCode
            )
        }
    }
}
