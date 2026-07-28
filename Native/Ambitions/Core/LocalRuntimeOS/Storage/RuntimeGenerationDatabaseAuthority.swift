import AmbitionsRuntimeSQLite
import CryptoKit
import Darwin
import Foundation

enum RuntimeGenerationDatabaseAuthority {
    static let pageSize = 128
    static let pageByteBudget = 4 * 1_024 * 1_024

    static func installEmptyV8(
        at databaseURL: URL,
        generationID: RuntimeStoreGenerationID,
        createdAtMilliseconds: Int64
    ) async throws -> SQLiteDatabase {
        try RuntimeStorePathValidation.requireSafeComponent(generationID.pathComponent)
        guard createdAtMilliseconds >= 0,
              CanonicalRuntimeAttachmentSchemaPlan.fullGenerationStatements.isEmpty == false
        else { throw RuntimeGenerationControlError.malformed(field: "v8_install") }
        let descriptor = Darwin.open(
            databaseURL.path,
            O_RDWR | O_CREAT | O_EXCL | O_NOFOLLOW | O_CLOEXEC,
            S_IRUSR | S_IWUSR
        )
        guard descriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "reserve_v8_database"
            )
        }
        var status = stat()
        let valid = fstat(descriptor, &status) == 0
            && status.st_mode & S_IFMT == S_IFREG && status.st_nlink == 1
        let closed = Darwin.close(descriptor) == 0
        guard valid, closed else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "pin_v8_database"
            )
        }
        // Protection is established before the first schema or private row is
        // written, not retrofitted after SQLite has already persisted data.
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: databaseURL,
            artifact: "v8_database_reserved"
        )
        let database = try SQLiteDatabase(
            url: databaseURL,
            configuration: CanonicalRuntimeStore.sqliteConfiguration(openMode: .existingOnly)
        )
        do {
            let statements = CanonicalRuntimeAttachmentSchemaPlan.fullGenerationStatements
            let authorization = try CanonicalRuntimeStore.schemaBootstrapAuthorization(statements)
            try await database.bootstrapTransaction(.exclusive, authorization: authorization) { database in
                for statement in statements {
                    try database.execute(statement)
                }
                try database.execute(
                    "INSERT INTO runtime_authority_fence(singleton_id, change_epoch, last_changed_table, last_change_operation) VALUES(1, 0, '', 'bootstrap')"
                )
                try database.execute(
                    "INSERT INTO runtime_store_metadata(singleton_id, schema_version, generation_id, created_at_ms) VALUES(1, ?, ?, ?)",
                    bindings: [
                        .integer(Int64(runtimeCanonicalAttachmentSchemaVersion)),
                        .text(generationID.rawValue),
                        .integer(createdAtMilliseconds),
                    ]
                )
                try database.execute(
                    "PRAGMA user_version = \(runtimeCanonicalAttachmentSchemaVersion)"
                )
                try CanonicalRuntimeAttachmentSchemaPlan.requireIntegratedSchema(in: database)
            }
        } catch {
            let operationError = error
            do { try await database.close() }
            catch {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_failed_v8_install_database"
                )
            }
            throw operationError
        }
        return database
    }

    static func verifyExactV8ReadOnly(at databaseURL: URL) async throws -> SQLiteDatabase {
        try RuntimeStoreFileDurability.requireRegularNonSymbolicFile(
            at: databaseURL,
            artifact: "verification_database"
        )
        let database = try SQLiteDatabase(
            url: databaseURL,
            configuration: CanonicalRuntimeStore.sqliteConfiguration(openMode: .readOnlyExisting)
        )
        do {
            let integrity = try await database.integrityCheck()
            guard integrity.isOK else {
                throw LocalRuntimeStorageError.canonicalIntegrityFailure
            }
            guard try await database.foreignKeyCheck().isEmpty else {
                throw LocalRuntimeStorageError.canonicalForeignKeyFailure
            }
            try await database.transaction(.deferred) { database in
                try CanonicalRuntimeAttachmentSchemaPlan.requireIntegratedSchema(in: database)
            }
        } catch {
            let operationError = error
            do { try await database.close() }
            catch {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_failed_v8_verification_database"
                )
            }
            throw operationError
        }
        return database
    }

    /// Opens active authority only while the caller holds the exact exclusive
    /// activation scope. SQLite is allowed to recover committed WAL state and
    /// checkpoint it to a closed image; immutable/no-sidecar mode is reserved
    /// for unpublished candidates after their writer-excluding lock is held.
    static func openActiveV8ForLockedRecoveryVerification(
        at databaseURL: URL,
        activationLock: RuntimeGenerationActivationLockScope
    ) async throws -> SQLiteDatabase {
        try activationLock.revalidate(requiredMode: .exclusive)
        try RuntimeStoreFileDurability.requireRegularNonSymbolicFile(
            at: databaseURL,
            artifact: "active_recovery_database"
        )
        let database = try SQLiteDatabase(
            url: databaseURL,
            configuration: CanonicalRuntimeStore.sqliteConfiguration(
                openMode: .existingOnly
            )
        )
        do {
            let integrity = try await database.integrityCheck()
            guard integrity.isOK,
                  try await database.foreignKeyCheck().isEmpty else {
                throw LocalRuntimeStorageError.canonicalIntegrityFailure
            }
            try await database.transaction(.deferred) { database in
                try CanonicalRuntimeAttachmentSchemaPlan.requireIntegratedSchema(in: database)
            }
            let checkpoint = try await database.checkpoint(.truncate)
            guard checkpoint.logFrameCount == checkpoint.checkpointedFrameCount else {
                throw LocalRuntimeStorageError.canonicalIntegrityFailure
            }
            try activationLock.revalidate(requiredMode: .exclusive)
        } catch {
            let operationError = error
            do { try await database.close() }
            catch {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_failed_active_recovery_database"
                )
            }
            throw operationError
        }
        return database
    }

    static func requireMetadata(
        in database: SQLiteDatabase,
        generationID: RuntimeStoreGenerationID,
        createdAtMilliseconds: Int64
    ) async throws {
        try await database.transaction(.deferred) { database in
            let rows = try database.query(
                "SELECT singleton_id, schema_version, generation_id, created_at_ms FROM runtime_store_metadata LIMIT 2",
                maximumDecodedBytes: pageByteBudget
            )
            guard rows.count == 1,
                  rows[0].value(named: "singleton_id") == .integer(1),
                  rows[0].value(named: "schema_version") == .integer(
                    Int64(runtimeCanonicalAttachmentSchemaVersion)
                  ),
                  rows[0].value(named: "generation_id") == .text(generationID.rawValue),
                  rows[0].value(named: "created_at_ms") == .integer(createdAtMilliseconds)
            else { throw RuntimeGenerationControlError.verificationRejected }
        }
    }

    static func artifact(
        at url: URL,
        relativePath: String
    ) throws -> RuntimeGenerationObservedArtifact {
        let descriptor = Darwin.open(url.path, O_RDONLY | O_NOFOLLOW | O_CLOEXEC)
        guard descriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalIOFailure(operation: "open_generation_artifact")
        }
        var descriptorOpen = true
        do {
            var initial = stat()
            var initialPath = stat()
            guard fstat(descriptor, &initial) == 0,
                  lstat(url.path, &initialPath) == 0,
                  initial.st_mode & S_IFMT == S_IFREG,
                  initialPath.st_mode & S_IFMT == S_IFREG,
                  initial.st_nlink == 1,
                  initialPath.st_nlink == 1,
                  initial.st_size >= 0,
                  initial.st_dev == initialPath.st_dev,
                  initial.st_ino == initialPath.st_ino,
                  Darwin.fcntl(descriptor, F_GETPROTECTIONCLASS) == PROTECTION_CLASS_A else {
                throw LocalRuntimeStorageError.canonicalIntegrityFailure
            }
            var hasher = SHA256()
            var buffer = [UInt8](repeating: 0, count: 128 * 1_024)
            while true {
                try Task.checkCancellation()
                let readCount = buffer.withUnsafeMutableBytes {
                    Darwin.read(descriptor, $0.baseAddress, $0.count)
                }
                if readCount < 0, errno == EINTR { continue }
                guard readCount >= 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "read_generation_artifact"
                    )
                }
                if readCount == 0 { break }
                hasher.update(data: Data(buffer.prefix(readCount)))
            }
            var final = stat()
            var finalPath = stat()
            guard fstat(descriptor, &final) == 0,
                  lstat(url.path, &finalPath) == 0,
                  initial.st_dev == final.st_dev,
                  initial.st_ino == final.st_ino,
                  initial.st_size == final.st_size,
                  final.st_nlink == 1,
                  final.st_dev == finalPath.st_dev,
                  final.st_ino == finalPath.st_ino,
                  finalPath.st_mode & S_IFMT == S_IFREG,
                  finalPath.st_nlink == 1,
                  Darwin.fcntl(descriptor, F_GETPROTECTIONCLASS) == PROTECTION_CLASS_A else {
                throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                    artifact: "generation_artifact"
                )
            }
            descriptorOpen = false
            guard Darwin.close(descriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_generation_artifact"
                )
            }
            let semantic = try RuntimeGenerationArtifact(
                relativePath: relativePath,
                sha256: hasher.finalize().map { String(format: "%02x", $0) }.joined(),
                byteCount: Int64(initial.st_size),
                protectionClass: "complete"
            )
            return try RuntimeGenerationObservedArtifact(
                semantic: semantic,
                fileIdentity: RuntimeStoreFileIdentity(
                    device: UInt64(initial.st_dev),
                    inode: UInt64(initial.st_ino)
                )
            )
        } catch {
            if descriptorOpen {
                descriptorOpen = false
                guard Darwin.close(descriptor) == 0 else {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "close_failed_generation_artifact"
                    )
                }
            }
            throw error
        }
    }

    static func revisionFence(
        in database: SQLiteDatabase,
        generationID: RuntimeStoreGenerationID,
        generationDigest: String
    ) async throws -> RuntimeGenerationRevisionFence {
        let snapshot = try await authoritySnapshot(in: database)
        return try snapshot.fence(
            generationID: generationID,
            generationDigest: generationDigest
        )
    }

    static func boundedAuthorityFenceToken(
        in database: SQLiteDatabase,
        generationID: RuntimeStoreGenerationID,
        activationLock: RuntimeGenerationActivationLockScope
    ) async throws -> RuntimeGenerationAuthorityFenceToken {
        try activationLock.revalidate(requiredMode: .exclusive)
        try await database.transaction(.deferred) { database in
            try boundedAuthorityFenceTokenInTransaction(
                database: database,
                generationID: generationID
            )
        }
    }

    static func boundedAuthorityFenceTokenInTransaction(
        database: isolated SQLiteDatabase,
        generationID: RuntimeStoreGenerationID
    ) throws -> RuntimeGenerationAuthorityFenceToken {
        let rows = try database.query(
            "SELECT change_epoch, last_changed_table, last_change_operation FROM runtime_authority_fence WHERE singleton_id = 1 LIMIT 2",
            maximumDecodedBytes: pageByteBudget
        )
        guard rows.count == 1,
              case let .integer(epoch)? = rows[0].value(named: "change_epoch"),
              case let .text(table)? = rows[0].value(named: "last_changed_table"),
              case let .text(operation)? = rows[0].value(named: "last_change_operation") else {
            throw RuntimeGenerationControlError.malformed(field: "authority_fence_token")
        }
        return try RuntimeGenerationAuthorityFenceToken.make(
            generationID: generationID,
            changeEpoch: epoch,
            lastChangedTable: table,
            lastChangeOperation: operation
        )
    }

    /// Captures a fence from the caller's already-open transaction. This is
    /// the migration path's primitive for binding a SQLite online backup to
    /// the exact authority snapshot that the backup contains.
    static func revisionFenceInTransaction(
        database: isolated SQLiteDatabase,
        generationID: RuntimeStoreGenerationID,
        generationDigest: String
    ) throws -> RuntimeGenerationRevisionFence {
        try authoritySnapshotInTransaction(database: database).fence(
            generationID: generationID,
            generationDigest: generationDigest
        )
    }

    static func manifestInventory(
        in database: SQLiteDatabase
    ) async throws -> (RuntimeGenerationCounts, RuntimeGenerationBoundaries) {
        let snapshot = try await authoritySnapshot(in: database)
        return (snapshot.counts, snapshot.boundaries)
    }

    static func manifestInventoryInTransaction(
        database: isolated SQLiteDatabase
    ) throws -> (RuntimeGenerationCounts, RuntimeGenerationBoundaries) {
        let snapshot = try authoritySnapshotInTransaction(database: database)
        return (snapshot.counts, snapshot.boundaries)
    }

    static func migrationEquivalenceDigest(
        in database: SQLiteDatabase
    ) async throws -> String {
        try await database.transaction(.deferred) { database in
            try migrationEquivalenceDigestInTransaction(database: database)
        }
    }

    static func migrationEquivalenceDigestInTransaction(
        database: isolated SQLiteDatabase
    ) throws -> String {
        let ownership = try tableOwnership(database: database)
        let semanticTables = ownership.canonical
            .union(ownership.receipts)
            .union(ownership.externalEffects)
            .union(ownership.attachments)
            .union(ownership.projections)
            .union(ownership.search)
            .subtracting(["runtime_store_metadata"])
        return try digest(tables: semanticTables, database: database)
    }

    private static func authoritySnapshot(
        in database: SQLiteDatabase
    ) async throws -> AuthoritySnapshot {
        try await database.transaction(.deferred) { database in
            try authoritySnapshotInTransaction(database: database)
        }
    }

    private static func authoritySnapshotInTransaction(
        database: isolated SQLiteDatabase
    ) throws -> AuthoritySnapshot {
            try Task.checkCancellation()
            try CanonicalRuntimeAttachmentSchemaPlan.requireIntegratedSchema(in: database)
            let ownership = try tableOwnership(database: database)
            let event = try database.query(
                "SELECT sequence, event_id, event_hash FROM runtime_semantic_events ORDER BY sequence DESC LIMIT 1",
                maximumDecodedBytes: pageByteBudget
            ).first
            let canonicalDigest = try digest(tables: ownership.canonical, database: database)
            let receiptDigest = try digest(tables: ownership.receipts, database: database)
            let externalDigest = try digest(tables: ownership.externalEffects, database: database)
            let attachmentDigest = try digest(tables: ownership.attachments, database: database)
            let projectionDigest = try digest(tables: ownership.projections, database: database)
            let searchDigest = try digest(tables: ownership.search, database: database)
            let counts = RuntimeGenerationCounts(
                aggregates: try count("runtime_aggregates", database: database),
                events: try count("runtime_events", database: database),
                semanticEvents: try count("runtime_semantic_events", database: database),
                tombstones: try count("runtime_tombstones", database: database),
                receipts: try count("runtime_commit_receipts", database: database),
                externalOperations: try count("runtime_external_operation_creations", database: database),
                externalOperationAttempts: try count("runtime_external_operation_attempt_starts", database: database),
                attachmentIdentities: try count("runtime_attachment_identities", database: database),
                attachmentRevisions: try count("runtime_attachment_revisions", database: database),
                attachmentReferences: try count("runtime_attachment_references", database: database),
                blobs: try count("runtime_blob_records", database: database),
                projectionGenerations: try count("runtime_canonical_projection_generations", database: database),
                searchGenerations: try count("runtime_canonical_search_generations", database: database)
            )
            let boundaries = RuntimeGenerationBoundaries(
                firstEventSequence: try optionalIntegerAggregate("SELECT MIN(sequence) AS value FROM runtime_semantic_events", database: database),
                lastEventSequence: try optionalIntegerAggregate("SELECT MAX(sequence) AS value FROM runtime_semantic_events", database: database),
                firstReceiptID: try optionalTextAggregate("SELECT MIN(receipt_id) AS value FROM runtime_commit_receipts", database: database),
                lastReceiptID: try optionalTextAggregate("SELECT MAX(receipt_id) AS value FROM runtime_commit_receipts", database: database),
                firstExternalOperationID: try optionalTextAggregate("SELECT MIN(operation_id) AS value FROM runtime_external_operation_creations", database: database),
                lastExternalOperationID: try optionalTextAggregate("SELECT MAX(operation_id) AS value FROM runtime_external_operation_creations", database: database),
                firstBlobID: try optionalTextAggregate("SELECT MIN(blob_id) AS value FROM runtime_blob_records", database: database),
                lastBlobID: try optionalTextAggregate("SELECT MAX(blob_id) AS value FROM runtime_blob_records", database: database),
                projectionAuthorityDigest: projectionDigest,
                searchAuthorityDigest: searchDigest,
                attachmentAuthorityDigest: attachmentDigest,
                externalOperationAuthorityDigest: externalDigest
            )
            try counts.validate(); try boundaries.validate()
            return AuthoritySnapshot(
                eventSequence: try event.map { try int64($0, "sequence") } ?? 0,
                eventID: try event.map { try text($0, "event_id") },
                eventHash: try event.map { try text($0, "event_hash") },
                commandCount: try count("runtime_command_idempotency", database: database),
                receiptCount: counts.receipts,
                externalVersionSum: try integerAggregate("SELECT COALESCE(SUM(status_version), 0) AS value FROM runtime_external_operation_current", database: database),
                attachmentVersionSum: try integerAggregate("SELECT COALESCE(SUM(state_version), 0) AS value FROM runtime_attachment_current_lifecycle", database: database),
                canonicalDigest: canonicalDigest,
                receiptDigest: receiptDigest,
                externalDigest: externalDigest,
                attachmentDigest: attachmentDigest,
                counts: counts,
                boundaries: boundaries
            )
    }

    private static func digest(
        tables: Set<String>,
        database: isolated SQLiteDatabase
    ) throws -> String {
        var rolling = LocalRuntimeStorageChecksum.sha256Hex(for: "runtime-generation-authority-v1")
        for table in tables.sorted() {
            try RuntimeGenerationControlValidation.requireIdentifier(table, field: "authority_table")
            let columns = try primaryKeyOrder(table: table, database: database)
            guard columns.isEmpty == false else {
                throw RuntimeGenerationControlError.malformed(field: "authority_primary_key")
            }
            let schemaRows = try database.query(
                "SELECT sql FROM sqlite_schema WHERE type = 'table' AND name = ? LIMIT 2",
                bindings: [.text(table)], maximumDecodedBytes: pageByteBudget
            )
            guard schemaRows.count == 1 else {
                throw RuntimeGenerationControlError.malformed(field: "authority_schema")
            }
            let rowCount = try count(table, database: database)
            rolling = LocalRuntimeStorageChecksum.sha256Hex(
                for: rolling + "\ntable:\(table)\nschema:\(try text(schemaRows[0], "sql"))\ncount:\(rowCount)"
            )
            var cursor: [SQLiteValue]?
            while true {
                try Task.checkCancellation()
                let predicate = try cursor.map { try keysetPredicate(columns: columns, values: $0) }
                let rows = try database.query(
                    "SELECT * FROM \(table)\(predicate.map { " WHERE \($0.sql)" } ?? "") ORDER BY \(columns.joined(separator: ",")) LIMIT \(pageSize)",
                    bindings: predicate?.bindings ?? [], maximumDecodedBytes: pageByteBudget
                )
                for row in rows {
                    rolling = LocalRuntimeStorageChecksum.sha256Hex(
                        for: rolling + "\n" + table + "\n" + stableRow(row)
                    )
                }
                guard rows.count == pageSize else { break }
                guard let last = rows.last else { break }
                cursor = try columns.map {
                    guard let value = last.value(named: $0) else {
                        throw RuntimeGenerationControlError.malformed(field: "authority_cursor")
                    }
                    return value
                }
            }
        }
        return rolling
    }

    private static func primaryKeyOrder(
        table: String,
        database: isolated SQLiteDatabase
    ) throws -> [String] {
        let rows = try database.query("PRAGMA table_info(\(table))")
        let keyed = try rows.compactMap { row -> (Int64, String)? in
            let position = try int64(row, "pk")
            return position > 0 ? (position, try text(row, "name")) : nil
        }.sorted { $0.0 < $1.0 }.map(\.1)
        if keyed.isEmpty {
            for row in rows {
                if try text(row, "name") == "singleton_id" {
                    return ["singleton_id"]
                }
            }
        }
        return keyed
    }

    private static func count(_ table: String, database: isolated SQLiteDatabase) throws -> Int64 {
        try integerAggregate("SELECT COUNT(*) AS value FROM \(table)", database: database)
    }

    private static func integerAggregate(_ sql: String, database: isolated SQLiteDatabase) throws -> Int64 {
        let rows = try database.query(sql, maximumDecodedBytes: pageByteBudget)
        guard rows.count == 1 else {
            throw RuntimeGenerationControlError.malformed(field: "authority_aggregate")
        }
        return try int64(rows[0], "value")
    }

    private static func optionalIntegerAggregate(
        _ sql: String,
        database: isolated SQLiteDatabase
    ) throws -> Int64? {
        let rows = try database.query(sql, maximumDecodedBytes: pageByteBudget)
        guard rows.count == 1, let value = rows[0].value(named: "value") else {
            throw RuntimeGenerationControlError.malformed(field: "authority_aggregate")
        }
        switch value {
        case .null: return nil
        case let .integer(result): return result
        default: throw RuntimeGenerationControlError.malformed(field: "authority_aggregate")
        }
    }

    private static func optionalTextAggregate(
        _ sql: String,
        database: isolated SQLiteDatabase
    ) throws -> String? {
        let rows = try database.query(sql, maximumDecodedBytes: pageByteBudget)
        guard rows.count == 1, let value = rows[0].value(named: "value") else {
            throw RuntimeGenerationControlError.malformed(field: "authority_aggregate")
        }
        switch value {
        case .null: return nil
        case let .text(result): return result
        default: throw RuntimeGenerationControlError.malformed(field: "authority_aggregate")
        }
    }

    private struct AuthoritySnapshot: Sendable {
        let eventSequence: Int64
        let eventID: String?
        let eventHash: String?
        let commandCount: Int64
        let receiptCount: Int64
        let externalVersionSum: Int64
        let attachmentVersionSum: Int64
        let canonicalDigest: String
        let receiptDigest: String
        let externalDigest: String
        let attachmentDigest: String
        let counts: RuntimeGenerationCounts
        let boundaries: RuntimeGenerationBoundaries

        func fence(
            generationID: RuntimeStoreGenerationID,
            generationDigest: String
        ) throws -> RuntimeGenerationRevisionFence {
            try RuntimeGenerationRevisionFence.make(
                generationID: generationID,
                generationDigest: generationDigest,
                eventSequence: eventSequence,
                eventID: eventID,
                eventHash: eventHash,
                commandCount: commandCount,
                receiptCount: receiptCount,
                externalOperationStatusVersionSum: externalVersionSum,
                attachmentLifecycleVersionSum: attachmentVersionSum,
                canonicalStateDigest: canonicalDigest,
                receiptAuthorityDigest: receiptDigest,
                externalOperationAuthorityDigest: externalDigest,
                attachmentAuthorityDigest: attachmentDigest
            )
        }
    }

    private struct TableOwnership {
        let canonical: Set<String>
        let receipts: Set<String>
        let externalEffects: Set<String>
        let attachments: Set<String>
        let projections: Set<String>
        let search: Set<String>
    }

    private static func tableOwnership(
        database: isolated SQLiteDatabase
    ) throws -> TableOwnership {
        let observed = Set(try database.query(
            "SELECT name FROM sqlite_schema WHERE type = 'table' AND name LIKE 'runtime_%' ORDER BY name",
            maximumDecodedBytes: pageByteBudget
        ).map { try text($0, "name") })
        let expected = Set(CanonicalRuntimeAttachmentSchemaPlan.fullGenerationStatements.compactMap {
            schemaTableName($0)
        })
        guard observed == expected else {
            throw RuntimeGenerationControlError.malformed(field: "authority_table_catalog")
        }
        let removedLegacy: Set<String> = ["runtime_blob_records", "runtime_blob_references"]
        let base = CanonicalRuntimeStore.expectedRuntimeTables.subtracting(removedLegacy)
        let search: Set<String> = [
            "runtime_canonical_search_generations", "runtime_canonical_search_documents",
            "runtime_canonical_search_postings", "runtime_canonical_search_shards",
            "runtime_canonical_search_active_generation",
        ]
        let attachments = CanonicalRuntimeAttachmentSchemaPlan.tables
        let external = CanonicalRuntimeExternalOperationSchemaPlan.tables
            .subtracting(attachments)
        let receipts = CanonicalRuntimeCommittedReceiptSchemaPlan.tables
            .subtracting(attachments).subtracting(external)
        let projections = CanonicalRuntimeProjectionSchemaPlan.tables
            .subtracting(search).subtracting(receipts).subtracting(external)
            .subtracting(attachments)
        let canonical = base
            .union(["runtime_authority_fence"])
            .union(CanonicalRuntimeCommitSchemaPlan.tables)
            .union(CanonicalRuntimeSemanticEventSchemaPlan.tables)
            .union(CanonicalRuntimeReplaySchemaPlan.tables)
            .subtracting(receipts).subtracting(external).subtracting(attachments)
            .subtracting(projections).subtracting(search)
        let groups = [canonical, receipts, external, attachments, projections, search]
        let union = groups.reduce(into: Set<String>()) { $0.formUnion($1) }
        let totalMemberships = groups.reduce(0) { $0 + $1.count }
        guard union == expected, totalMemberships == union.count else {
            throw RuntimeGenerationControlError.malformed(field: "authority_table_ownership")
        }
        return TableOwnership(
            canonical: canonical,
            receipts: receipts,
            externalEffects: external,
            attachments: attachments,
            projections: projections,
            search: search
        )
    }

    private static func schemaTableName(_ statement: String) -> String? {
        let tokens = statement.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        guard tokens.count >= 3, tokens[0].uppercased() == "CREATE",
              tokens[1].uppercased() == "TABLE" else { return nil }
        return tokens[2]
    }

    private static func keysetPredicate(
        columns: [String],
        values: [SQLiteValue]
    ) throws -> (sql: String, bindings: [SQLiteBinding]) {
        guard columns.count == values.count, columns.isEmpty == false else {
            throw RuntimeGenerationControlError.malformed(field: "authority_cursor")
        }
        var clauses: [String] = []
        var bindings: [SQLiteBinding] = []
        for index in columns.indices {
            let equalities = columns[..<index].map { "\($0) = ?" }
            clauses.append("(" + (equalities + ["\(columns[index]) > ?"]).joined(separator: " AND ") + ")")
            for prior in 0..<index { bindings.append(try binding(values[prior])) }
            bindings.append(try binding(values[index]))
        }
        return (clauses.joined(separator: " OR "), bindings)
    }

    private static func binding(_ value: SQLiteValue) throws -> SQLiteBinding {
        switch value {
        case .null:
            throw RuntimeGenerationControlError.malformed(field: "null_authority_primary_key")
        case let .integer(item): return .integer(item)
        case let .real(item): return .real(item)
        case let .text(item): return .text(item)
        case let .blob(item): return .blob(item)
        }
    }

    private static func stableRow(_ row: SQLiteRow) -> String {
        zip(row.columnNames, row.values).map { name, value in
            let encoded: String
            switch value {
            case .null: encoded = "n"
            case let .integer(item): encoded = "i:\(item)"
            case let .real(item): encoded = "r:\(item.bitPattern)"
            case let .text(item): encoded = "t:\(Data(item.utf8).base64EncodedString())"
            case let .blob(item): encoded = "b:\(LocalRuntimeStorageChecksum.sha256Hex(for: item)):\(item.count)"
            }
            return "\(name.utf8.count):\(name)=\(encoded)"
        }.joined(separator: "|")
    }

    private static func text(_ row: SQLiteRow, _ name: String) throws -> String {
        guard case let .text(value)? = row.value(named: name) else {
            throw RuntimeGenerationControlError.malformed(field: "authority_\(name)")
        }
        return value
    }

    private static func int64(_ row: SQLiteRow, _ name: String) throws -> Int64 {
        guard case let .integer(value)? = row.value(named: name) else {
            throw RuntimeGenerationControlError.malformed(field: "authority_\(name)")
        }
        return value
    }
}
