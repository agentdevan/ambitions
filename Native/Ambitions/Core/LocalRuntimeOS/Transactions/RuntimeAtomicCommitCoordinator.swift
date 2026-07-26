import AmbitionsRuntimeSQLite
import Foundation

let runtimeAtomicCommitSchemaVersion = 3
let runtimeCommitAnchorVersion = 1

/// The single canonical aggregate representation used both when committing
/// and when replaying aggregate authority. It deliberately contains semantic
/// command facts, not a repository object or a projection model.
struct RuntimeCanonicalAggregateState: Codable, Sendable, Equatable {
    let aggregate: RuntimeSemanticAggregate
    let revision: UInt64
    let lifecycle: RuntimeAggregateLifecycle
    let transition: RuntimeObjectTransitionKind
    let commandPayload: RuntimeCommandPayload
    let changedObjectIDs: [RuntimeDomainObjectID]
    let privacy: EventLedgerPrivacyClassification?
    let localOnly: Bool?

    init(
        aggregate: RuntimeSemanticAggregate,
        revision: UInt64,
        lifecycle: RuntimeAggregateLifecycle,
        transition: RuntimeObjectTransitionKind,
        commandPayload: RuntimeCommandPayload,
        changedObjectIDs: [RuntimeDomainObjectID],
        privacy: EventLedgerPrivacyClassification = .standard,
        localOnly: Bool = true
    ) {
        self.aggregate = aggregate
        self.revision = revision
        self.lifecycle = lifecycle
        self.transition = transition
        self.commandPayload = commandPayload
        self.changedObjectIDs = changedObjectIDs
        self.privacy = privacy
        self.localOnly = localOnly
    }
}

enum RuntimeCanonicalAggregateStateCodecError: Error, Sendable, Equatable {
    case corrupt
    case futureVersion
    case nonCanonical
    case historicalPrivacyMissing
}

struct RuntimeCanonicalAggregateStateCodec: Sendable {
    private struct Envelope: Codable {
        let version: Int
        let state: RuntimeCanonicalAggregateState
    }

    func encode(_ state: RuntimeCanonicalAggregateState) throws -> Data {
        guard state.privacy != nil, state.localOnly != nil else {
            throw RuntimeCanonicalAggregateStateCodecError.historicalPrivacyMissing
        }
        return try encode(state, version: 2)
    }

    private func encode(_ state: RuntimeCanonicalAggregateState, version: Int) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(Envelope(version: version, state: state))
    }

    func decode(_ bytes: Data) throws -> RuntimeCanonicalAggregateState {
        let decoder = JSONDecoder()
        let envelope: Envelope
        do {
            envelope = try decoder.decode(Envelope.self, from: bytes)
        } catch {
            throw RuntimeCanonicalAggregateStateCodecError.corrupt
        }
        guard envelope.version == 1 || envelope.version == 2 else {
            throw RuntimeCanonicalAggregateStateCodecError.futureVersion
        }
        guard (envelope.version == 1 || (envelope.state.privacy != nil && envelope.state.localOnly != nil)),
              try encode(envelope.state, version: envelope.version) == bytes else {
            throw RuntimeCanonicalAggregateStateCodecError.nonCanonical
        }
        return envelope.state
    }
}

struct RuntimeAuthorityLineageReference: Codable, Sendable, Equatable, Hashable {
    let eventID: RuntimeEventID
    let eventSequence: UInt64
    let eventHash: String
}

struct RuntimeAuthorityUnresolvedWorkReference: Codable, Sendable, Equatable, Hashable {
    enum Kind: String, Codable, Sendable, Equatable, Hashable { case projectionInvalidation, externalOperation }
    let kind: Kind
    let stableID: String
    let lineage: RuntimeAuthorityLineageReference
}

struct RuntimeCanonicalTombstoneDraft: Codable, Sendable, Equatable, Hashable {
    let objectID: RuntimeDomainObjectID
    let family: String
    let terminalRevision: UInt64
    let lineage: RuntimeAuthorityLineageReference
    let authority: RuntimeCanonicalTombstoneAuthority
}

struct RuntimeCanonicalPendingExternalOperation: Codable, Sendable, Equatable, Hashable {
    let operationID: RuntimeExternalOperationID
    let kind: RuntimeExternalEffectKind
    let status: String
    let lineage: RuntimeAuthorityLineageReference
}

enum RuntimeAuthorityUndoability: Codable, Sendable, Equatable, Hashable {
    case typedPlan(RuntimeRollbackPlanID)
    case noncompensable(RuntimeIrreversibilityEvidence)
}

struct RuntimeAuthorityObjectLink: Codable, Sendable, Equatable, Hashable {
    let aggregate: RuntimeSemanticAggregate
    let terminalRevision: UInt64
    let lifecycle: RuntimeAggregateLifecycle
}

struct RuntimeAtomicCommitReceipt: Codable, Sendable, Equatable {
    let receiptID: RuntimeReceiptID
    let preparationID: RuntimePreparationID
    let commandID: RuntimeCommandID
    let lineage: RuntimeAuthorityLineageReference
    let aggregateStates: [RuntimeCanonicalAggregateState]
    let tombstones: [RuntimeCanonicalTombstoneDraft]
    let unresolvedWork: [RuntimeAuthorityUnresolvedWorkReference]
    let objectLinks: [RuntimeAuthorityObjectLink]
    let undoability: RuntimeAuthorityUndoability
    let confirmationToken: RuntimeConfirmationToken?
    let confirmationDecisionDigest: RuntimeCommandFingerprint?
    let committedAt: Date
}

struct RuntimeAtomicCommitFinalOutcome: Codable, Sendable, Equatable {
    let committed: RuntimeCommittedMutation
    let receipt: RuntimeCommittedReceiptCore
    let externalOperationCreations: [RuntimeAtomicExternalOperationCreationEvidence]
}

struct RuntimeAtomicAttachmentCommitOutcome: Sendable, Equatable {
    let commit: RuntimeAtomicCommitFinalOutcome
    let attachment: RuntimeAttachmentAuthoritySnapshot
}

struct RuntimeAtomicExternalOperationCreationEvidence: Codable, Sendable, Equatable, Hashable {
    let operationID: RuntimeExternalOperationID
    let kind: RuntimeExternalEffectKind
    let creationDigest: String
    let receiptID: RuntimeReceiptID
    let lineage: RuntimeAuthorityLineageReference
}

private struct RuntimeAtomicCommitLegacyV6FinalOutcome: Codable {
    let committed: RuntimeCommittedMutation
    let receipt: RuntimeCommittedReceiptCore
    let pendingExternalOperations: [RuntimeCanonicalPendingExternalOperation]
}

private struct RuntimeAtomicCommitLegacyV6FinalOutcomeEnvelope: Codable {
    let outcomeVersion: Int
    let outcome: RuntimeAtomicCommitLegacyV6FinalOutcome
}

private enum RuntimeAtomicCommitLegacyV5UndoabilityReason: String, Codable {
    case missingTypedCompensationContract = "missing_typed_compensation_contract"
}

private enum RuntimeAtomicCommitLegacyV5Undoability: Codable {
    case typedPlan(RuntimeRollbackPlanID)
    case notUndoable(reason: RuntimeAtomicCommitLegacyV5UndoabilityReason)
}

private struct RuntimeAtomicCommitLegacyV5ObjectLink: Codable {
    let aggregate: RuntimeSemanticAggregate
    let terminalRevision: UInt64
    let lifecycle: RuntimeAggregateLifecycle
}

private struct RuntimeAtomicCommitLegacyV5WorkReference: Codable {
    enum Kind: String, Codable { case projectionInvalidation, externalOperation }
    let kind: Kind
    let stableID: String
    let lineage: RuntimeAuthorityLineageReference
}

private struct RuntimeAtomicCommitLegacyV5Receipt: Codable {
    let receiptID: RuntimeReceiptID
    let preparationID: RuntimePreparationID
    let commandID: RuntimeCommandID
    let lineage: RuntimeAuthorityLineageReference
    let aggregateStates: [RuntimeCanonicalAggregateState]
    let tombstones: [RuntimeCanonicalTombstoneDraft]
    let unresolvedWork: [RuntimeAtomicCommitLegacyV5WorkReference]
    let objectLinks: [RuntimeAtomicCommitLegacyV5ObjectLink]
    let undoability: RuntimeAtomicCommitLegacyV5Undoability
    let confirmationToken: RuntimeConfirmationToken?
    let confirmationDecisionDigest: RuntimeCommandFingerprint?
    let committedAt: Date
}

private struct RuntimeAtomicCommitLegacyV5PendingExternalOperation: Codable {
    let operationID: RuntimeExternalOperationID
    let kind: RuntimeExternalEffectKind
    let status: String
    let lineage: RuntimeAuthorityLineageReference
}

private struct RuntimeAtomicCommitLegacyV5FinalOutcome: Codable {
    let committed: RuntimeCommittedMutation
    let receipt: RuntimeAtomicCommitLegacyV5Receipt
    let pendingExternalOperations: [RuntimeAtomicCommitLegacyV5PendingExternalOperation]
}

private struct RuntimeAtomicCommitFinalOutcomeEnvelope: Codable, Sendable, Equatable {
    let outcomeVersion: Int
    let outcome: RuntimeAtomicCommitFinalOutcome
}

enum RuntimeAtomicCommitPhase: Int, Codable, Sendable, Equatable, CaseIterable {
    case claimed, snapshotsLoaded, reduced, aggregatesApplied, eventAppended
    case invalidationsPersisted, receiptPersisted, externalOperationsPersisted
    case receiptCorePersisted, receiptHistoryPersisted
    case compensationDispositionPersisted, receiptGraphAuthenticated
    case compensationConsumed, idempotencyFinalized, confirmationConsumed
}

enum RuntimeAtomicCommitError: Error, Sendable, Equatable {
    case malformedPreparation
    case preparationExpired
    case privacyMismatch
    case confirmationRequired
    case confirmationRejected
    case confirmationMismatch
    case confirmationConsumed
    case stalePreparation
    case reducerMismatch
    case eventQuarantined
    case migrationRequired(expected: Int, actual: Int)
    case corruptAuthority
    case injectedFailure(RuntimeAtomicCommitPhase)
}

extension RuntimeAtomicCommitError: CustomStringConvertible, LocalizedError {
    var description: String {
        switch self {
        case .malformedPreparation: "Prepared mutation is malformed."
        case .preparationExpired: "Prepared mutation expired."
        case .privacyMismatch: "Prepared mutation privacy evidence mismatched."
        case .confirmationRequired: "Bound confirmation is required."
        case .confirmationRejected: "Bound confirmation was rejected."
        case .confirmationMismatch: "Bound confirmation mismatched."
        case .confirmationConsumed: "Bound confirmation was already consumed."
        case .stalePreparation: "Prepared mutation is stale."
        case .reducerMismatch: "Prepared mutation no longer matches its pure reducer."
        case .eventQuarantined: "Semantic event could not establish authority."
        case let .migrationRequired(expected, actual): "Canonical schema migration is required (expected \(expected), actual \(actual))."
        case .corruptAuthority: "Canonical authority is corrupt."
        case .injectedFailure: "Atomic commit fault was injected."
        }
    }
    var errorDescription: String? { description }
}

enum CanonicalRuntimeCommitSchemaPlan {
    static let sourceSchemaVersion = 1
    static let targetSchemaVersion = runtimeAtomicCommitSchemaVersion
    static let currentWritableSchemaVersion = runtimeCanonicalAttachmentSchemaVersion
    static let readableActiveSchemaVersions: Set<Int> = [sourceSchemaVersion]
    static let writableAuthoritySchemaVersions: Set<Int> = [currentWritableSchemaVersion]
    static let tables: Set<String> = [
        "runtime_commit_receipts", "runtime_commit_projection_invalidations",
        "runtime_pending_external_operations", "runtime_confirmation_consumptions",
        "runtime_commit_tombstones",
    ]
    static let indexes: Set<String> = [
        "runtime_commit_projection_invalidations_projection_idx",
        "runtime_pending_external_operations_status_idx",
        "runtime_commit_tombstones_event_idx",
    ]
    static let statements: [String] = [
        """
        CREATE TABLE runtime_commit_receipts (
            receipt_id TEXT PRIMARY KEY CHECK (length(receipt_id) > 0),
            preparation_id TEXT NOT NULL UNIQUE CHECK (length(preparation_id) > 0),
            command_id TEXT NOT NULL UNIQUE CHECK (length(command_id) > 0),
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            receipt_version INTEGER NOT NULL CHECK (receipt_version = 1),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_commit_projection_invalidations (
            invalidation_id TEXT PRIMARY KEY CHECK (length(invalidation_id) > 0),
            projection_id TEXT NOT NULL CHECK (length(projection_id) > 0),
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            invalidation_version INTEGER NOT NULL CHECK (invalidation_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_commit_projection_invalidations_projection_idx ON runtime_commit_projection_invalidations(projection_id, invalidation_id)",
        """
        CREATE TABLE runtime_pending_external_operations (
            operation_id TEXT PRIMARY KEY CHECK (length(operation_id) > 0),
            command_id TEXT NOT NULL,
            receipt_id TEXT NOT NULL,
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            operation_kind TEXT NOT NULL CHECK (length(operation_kind) > 0),
            status TEXT NOT NULL CHECK (status = 'pending'),
            operation_version INTEGER NOT NULL CHECK (operation_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            attempt_count INTEGER NOT NULL CHECK (attempt_count = 0),
            updated_at_ms INTEGER NOT NULL CHECK (updated_at_ms >= 0),
            FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_pending_external_operations_status_idx ON runtime_pending_external_operations(status, operation_id)",
        """
        CREATE TABLE runtime_confirmation_consumptions (
            token TEXT PRIMARY KEY CHECK (length(token) > 0),
            receipt_id TEXT NOT NULL UNIQUE,
            preparation_id TEXT NOT NULL UNIQUE,
            command_id TEXT NOT NULL UNIQUE,
            decision_digest TEXT NOT NULL CHECK (length(decision_digest) = 64 AND decision_digest NOT GLOB '*[^0-9a-f]*'),
            terminal_event_sequence INTEGER NOT NULL UNIQUE CHECK (terminal_event_sequence > 0),
            consumed_at_ms INTEGER NOT NULL CHECK (consumed_at_ms >= 0),
            UNIQUE (receipt_id, token, decision_digest),
            FOREIGN KEY (receipt_id) REFERENCES runtime_commit_receipts(receipt_id),
            FOREIGN KEY (command_id) REFERENCES runtime_command_idempotency(command_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        """
        CREATE TABLE runtime_commit_tombstones (
            object_id TEXT NOT NULL,
            family TEXT NOT NULL,
            terminal_revision INTEGER NOT NULL CHECK (terminal_revision >= 0),
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            tombstone_version INTEGER NOT NULL CHECK (tombstone_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
            created_at_ms INTEGER NOT NULL CHECK (created_at_ms >= 0),
            PRIMARY KEY (family, object_id),
            FOREIGN KEY (terminal_event_sequence) REFERENCES runtime_semantic_events(sequence)
        ) WITHOUT ROWID
        """,
        "CREATE INDEX runtime_commit_tombstones_event_idx ON runtime_commit_tombstones(terminal_event_sequence, family, object_id)",
    ]
    /// T15 may use this deterministic list only while constructing a staged
    /// generation. T09 never applies it to an active schema-v1 store.
    static let stagedIntegratedStatements =
        CanonicalRuntimeSemanticEventSchemaPlan.statements + statements

    static func requireIntegratedSchema(in database: isolated SQLiteDatabase) throws {
        let versionRows = try database.query("PRAGMA user_version")
        guard case let .integer(version)? = versionRows.first?.values.first else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        guard writableAuthoritySchemaVersions.contains(Int(version)) else {
            throw RuntimeAtomicCommitError.migrationRequired(
                expected: currentWritableSchemaVersion,
                actual: Int(version)
            )
        }
        if version == Int64(runtimeCanonicalAttachmentSchemaVersion) {
            try CanonicalRuntimeAttachmentSchemaPlan.requireIntegratedSchema(in: database)
            return
        }
        try CanonicalRuntimeReplaySchemaPlan.requireIntegratedSchema(in: database)
        let rows = try database.query(
            """
            SELECT name, type FROM sqlite_schema
            WHERE name LIKE 'runtime_%'
              AND type IN ('table', 'index')
            """
        )
        let tableNames = Set(rows.compactMap { row -> String? in
            guard row.value(named: "type") == .text("table"),
                  case let .text(name)? = row.value(named: "name") else { return nil }
            return name
        })
        let indexNames = Set(rows.compactMap { row -> String? in
            guard row.value(named: "type") == .text("index"),
                  case let .text(name)? = row.value(named: "name") else { return nil }
            return name
        })
        var expectedTables = CanonicalRuntimeStore.expectedRuntimeTables
            .union(CanonicalRuntimeSemanticEventSchemaPlan.tables)
            .union(tables)
        var expectedIndexes = CanonicalRuntimeStore.expectedRuntimeIndexes
            .union(CanonicalRuntimeSemanticEventSchemaPlan.indexes)
            .union(indexes)
        if version >= Int64(runtimeCanonicalReplaySchemaVersion) {
            expectedTables.formUnion(CanonicalRuntimeReplaySchemaPlan.tables)
            expectedIndexes.formUnion(CanonicalRuntimeReplaySchemaPlan.indexes)
        }
        if version >= Int64(runtimeCanonicalProjectionSchemaVersion) {
            expectedTables.formUnion(CanonicalRuntimeProjectionSchemaPlan.tables)
            expectedIndexes.formUnion(CanonicalRuntimeProjectionSchemaPlan.indexes)
        }
        if version >= Int64(runtimeCommittedReceiptSchemaVersion) {
            expectedTables.formUnion(CanonicalRuntimeCommittedReceiptSchemaPlan.tables)
            expectedIndexes.formUnion(CanonicalRuntimeCommittedReceiptSchemaPlan.indexes)
        }
        guard tableNames == expectedTables, indexNames == expectedIndexes else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let metadataRows = try database.query(
            "SELECT schema_version FROM runtime_store_metadata WHERE singleton_id = 1 LIMIT 2"
        )
        guard metadataRows.count == 1,
              case let .integer(metadataVersion)? = metadataRows.first?.value(named: "schema_version"),
              metadataVersion == version else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
    }
}

struct RuntimeAtomicCommitCoordinator: RuntimeMutationSubmitting, RuntimeMutationAuthorityAccepting, Sendable {
    let store: CanonicalRuntimeStore
    let clock: RuntimeClockClient
    let failAfterPhase: RuntimeAtomicCommitPhase?

    init(
        store: CanonicalRuntimeStore,
        clock: RuntimeClockClient = .live,
        failAfterPhase: RuntimeAtomicCommitPhase? = nil
    ) {
        self.store = store
        self.clock = clock
        self.failAfterPhase = failAfterPhase
    }

    func commit(
        _ preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?
    ) async -> RuntimeCommandOutcome {
        switch await accept(preparation, confirmation: confirmation) {
        case let .committed(value): return .changed(value)
        case let .unchanged(recovery): return .unchanged(terminal(preparation, recovery))
        case let .rejected(recovery): return .blocked(terminal(preparation, recovery))
        case let .failed(recovery): return .failed(terminal(preparation, recovery))
        case let .unsupported(recovery): return .unsupported(terminal(preparation, recovery))
        }
    }

    func accept(
        _ preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?
    ) async -> RuntimeAuthorityAcceptance {
        let submittedAt = clock.now
        do {
            try Task.checkCancellation()
            try RuntimeAtomicCommitValidation.validate(
                preparation: preparation,
                confirmation: confirmation,
                at: submittedAt
            )
            if preparation.decision.disposition == .unchanged {
                return .unchanged(preparation.decision.recovery)
            }
            let outcome = try await store.atomicCommit(
                preparation: preparation,
                confirmation: confirmation,
                submittedAt: submittedAt,
                failAfterPhase: failAfterPhase
            )
            return .committed(outcome.committed)
        } catch {
            let reason = RuntimeAtomicCommitFailureMapping.reason(error)
            let recovery = RuntimeRecovery(
                kind: reason == .migrationRequired ? .inspect : .retry,
                reason: reason,
                target: preparation.command.target,
                redactedDetail: nil
            )
            if let atomic = error as? RuntimeAtomicCommitError {
                switch atomic {
                case .migrationRequired: return .unsupported(recovery)
                case .confirmationRequired, .confirmationRejected, .confirmationMismatch,
                     .confirmationConsumed, .preparationExpired, .privacyMismatch,
                     .stalePreparation:
                    return .rejected(recovery)
                default: break
                }
            }
            if let transaction = error as? CanonicalRuntimeTransactionError {
                switch transaction {
                case .idempotencyCollision, .revisionConflict: return .rejected(recovery)
                default: break
                }
            }
            return .failed(recovery)
        }
    }

    private func terminal(_ preparation: RuntimePreparation, _ recovery: RuntimeRecovery) -> RuntimeTerminalResult {
        RuntimeTerminalResult(
            preparationID: preparation.preparationID,
            commandID: preparation.commandID.rawValue,
            reason: recovery.reason,
            recovery: recovery
        )
    }
}

enum RuntimeAtomicCommitFailureMapping {
    static func reason(_ error: Error) -> RuntimeRecoveryReason {
        if error is CancellationError { return .cancelled }
        if let atomic = error as? RuntimeAtomicCommitError {
            switch atomic {
            case .migrationRequired: return .migrationRequired
            case .preparationExpired: return .confirmationExpired
            case .confirmationRequired: return .confirmationRequired
            case .confirmationRejected: return .confirmationRejected
            case .confirmationMismatch: return .confirmationMismatch
            case .confirmationConsumed: return .confirmationConsumed
            case .privacyMismatch: return .privacyDenied
            case .stalePreparation: return .staleAfterPreparation
            default: break
            }
        }
        if let transaction = error as? CanonicalRuntimeTransactionError,
           case .idempotencyCollision = transaction { return .idempotencyCollision }
        if let value = error as? LocalRuntimeStorageError {
            switch value {
            case .canonicalStorageFull: return .storageFull
            case .canonicalIOFailure: return .storageIO
            case .canonicalSQLiteFailure(_, let code, _) where code == 5 || code == 6: return .storageBusy
            default: return .authorityCorrupt
            }
        }
        return .authorityFailed
    }
}

private enum RuntimeAtomicCommitValidation {
    static func validate(
        preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?,
        at now: Date
    ) throws {
        guard preparation.schemaVersion == runtimePreparationSchemaVersion,
              preparation.commandVersion == runtimeCommandSchemaVersion,
              preparation.command.id == preparation.commandID.rawValue,
              preparation.issuedAt < preparation.expiresAt,
              now >= preparation.issuedAt else {
            throw RuntimeAtomicCommitError.malformedPreparation
        }
        guard now <= preparation.expiresAt else { throw RuntimeAtomicCommitError.preparationExpired }
        do {
            _ = try RuntimeCommandCodec().encode(preparation.command)
        } catch {
            throw RuntimeAtomicCommitError.malformedPreparation
        }
        try Task.checkCancellation()
        guard preparation.authorization.isAuthorized,
              preparation.authorization.reasonCodes.isEmpty,
              preparation.authorization.actor == preparation.command.actor,
              preparation.authorization.source == preparation.command.source,
              preparation.authorization.expectedRevision == preparation.command.expectedRevision,
              preparation.command.localOnly,
              preparation.authorization.privacyBoundary.localOnly,
              preparation.authorization.privacyBoundary.isSatisfied,
              preparation.authorization.privacyBoundary.privacy == preparation.command.privacy,
              preparation.decision.readSet.privacy == preparation.command.privacy else {
            throw RuntimeAtomicCommitError.privacyMismatch
        }
        let feature = RuntimeFeatureMutationRouter().feature(for: preparation.command.typedPayload)
        let expectedPolicy: CommandSideEffectPolicy = preparation.decision.writeSet.externalEffect == .none
            ? .localOnly
            : .outboxRequired
        guard RuntimePreparationAuthorizer().revisionMatches(
                expected: preparation.command.expectedRevision,
                observed: preparation.authorization.observedRevision
              ),
              preparation.authorization.sideEffectPolicy == expectedPolicy,
              preparation.decision.family == feature.rawValue,
              preparation.decision.action == preparation.command.typedPayload.diagnosticCase,
              preparation.decision.readSet.objects.map(\.aggregate) ==
                preparation.command.runtimePreparationAggregateReferences,
              preparation.decision.readSet.objects.allSatisfy({ dependency in
                  let expected = dependency.aggregate == preparation.command.runtimePrimaryPreparationReference
                    ? preparation.command.expectedRevision
                    : dependency.observedRevision
                  return dependency.expectedRevision == expected &&
                    RuntimePreparationAuthorizer().revisionMatches(
                        expected: dependency.expectedRevision,
                        observed: dependency.observedRevision
                    )
              }) else {
            throw RuntimeAtomicCommitError.malformedPreparation
        }
        guard RuntimePreparationDigest.command(preparation.command) == preparation.commandFingerprint,
              let payloadDigest = RuntimePreparationDigest.value(preparation.command.typedPayload),
              RuntimePreparationDigest.decision(
                commandPayloadDigest: payloadDigest,
                decision: preparation.decision,
                preparationID: preparation.preparationID
              ) == preparation.decisionDigest else {
            throw RuntimeAtomicCommitError.malformedPreparation
        }
        switch (preparation.confirmationRequest, confirmation) {
        case (nil, nil): break
        case (nil, .some): throw RuntimeAtomicCommitError.confirmationMismatch
        case (.some, nil): throw RuntimeAtomicCommitError.confirmationRequired
        case let (.some(request), .some(value)):
            guard value.decision == .approved else { throw RuntimeAtomicCommitError.confirmationRejected }
            guard request.oneUse,
                  request.preparationID == preparation.preparationID,
                  request.commandID == preparation.commandID,
                  request.commandFingerprint == preparation.commandFingerprint,
                  request.actor == preparation.command.actor,
                  request.scope == preparation.decision.confirmationScope,
                  request.target == preparation.command.target,
                  request.decisionDigest == preparation.decisionDigest,
                  request.issuedAt == preparation.issuedAt,
                  request.expiresAt == preparation.expiresAt,
                  value.token == request.token,
                  value.preparationID == request.preparationID,
                  value.commandID == request.commandID,
                  value.commandFingerprint == request.commandFingerprint,
                  value.actor == request.actor, value.scope == request.scope,
                  value.target == request.target, value.decisionDigest == request.decisionDigest,
                  value.decidedAt >= request.issuedAt, value.decidedAt <= request.expiresAt else {
                throw RuntimeAtomicCommitError.confirmationMismatch
            }
        }
    }
}

extension CanonicalRuntimeStore {
    func atomicCommit(
        preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?,
        submittedAt: Date,
        failAfterPhase: RuntimeAtomicCommitPhase? = nil
    ) async throws -> RuntimeAtomicCommitFinalOutcome {
        try await withAtomicCommitTransaction { database in
            try Self.atomicCommitInTransaction(
                preparation: preparation,
                confirmation: confirmation,
                submittedAt: submittedAt,
                failAfterPhase: failAfterPhase,
                database: database
            )
        }
    }

    func atomicCommitAttachment(
        preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?,
        submittedAt: Date,
        failAfterPhase: RuntimeAtomicCommitPhase? = nil
    ) async throws -> RuntimeAtomicAttachmentCommitOutcome {
        guard case let .attachment(command) = preparation.command.typedPayload else {
            throw RuntimeAtomicCommitError.malformedPreparation
        }
        let attachmentIntent = command.intent
        try await withAtomicCommitTransaction { database in
            let outcome = try Self.atomicCommitInTransaction(
                preparation: preparation, confirmation: confirmation,
                submittedAt: submittedAt,
                failAfterPhase: failAfterPhase, database: database
            )
            var attachmentReceiptBudget = RuntimeReceiptDecodedByteBudget(
                maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAttachmentArtifactGraphBytes
            )
            let authenticated = try CanonicalRuntimeAttachmentStore.authenticatedReceiptArtifacts(
                receiptID: outcome.receipt.facts.receiptID,
                budget: &attachmentReceiptBudget,
                database: database
            )
            let receiptAttachmentArtifacts = outcome.receipt.facts.artifacts.filter {
                $0.kind == .attachmentRevision || $0.kind == .attachmentFinalizationIntent
            }.sorted()
            guard authenticated == receiptAttachmentArtifacts,
                  authenticated.contains(where: {
                      $0.kind == .attachmentRevision &&
                          $0.stableID.hasPrefix(attachmentIntent.revisionID.rawValue + "#")
                  }),
                  let graph = try CanonicalRuntimeAttachmentStore.loadSnapshot(
                      revisionID: attachmentIntent.revisionID, database: database
                  ),
                  graph.revision.attachmentID == attachmentIntent.attachmentID,
                  graph.revision.blobID == attachmentIntent.blobID,
                  graph.revision.manifestDigest == attachmentIntent.manifestDigest else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            return RuntimeAtomicAttachmentCommitOutcome(commit: outcome, attachment: graph)
        }
    }

    static func atomicCommitInTransaction(
        preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?,
        submittedAt: Date,
        failAfterPhase: RuntimeAtomicCommitPhase? = nil,
        cancelAfterPhase: RuntimeAtomicCommitPhase? = nil,
        semanticEventBytesOverride: Data? = nil,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAtomicCommitFinalOutcome {
            let attachmentIntent: RuntimeAttachmentCommandIntent? = {
                guard case let .attachment(command) = preparation.command.typedPayload else { return nil }
                return command.intent
            }()
            try CanonicalRuntimeAttachmentSchemaPlan.requireIntegratedSchema(in: database)
            try Task.checkCancellation()
            try RuntimeAtomicCommitValidation.validate(
                preparation: preparation,
                confirmation: confirmation,
                at: submittedAt
            )

            let fingerprint = try CanonicalCommandSemanticFingerprint.semanticV2(
                command: preparation.command
            )
            let ownerID = "atomic.commit.\(preparation.preparationID.rawValue)"
            let claimedAt = try RuntimeSemanticEventHashing.milliseconds(submittedAt)
            let claim = try CanonicalIdempotencyClaimRequest(
                scope: "runtime.command",
                key: preparation.command.idempotencyKey.rawValue,
                commandID: preparation.commandID.rawValue,
                fingerprint: fingerprint,
                ownerID: ownerID,
                claimedAtMilliseconds: claimedAt
            )
            switch try Self.claimIdempotency(in: database, request: claim) {
            case let .replay(final):
                let outcome = try RuntimeAtomicCommitCoding.decodeFinalOutcome(
                    final.payload,
                    storedChecksum: final.payloadChecksumSHA256
                )
                try Self.validatePersistedReplay(outcome, database: database)
                return outcome
            case .claimed:
                break
            }
            try RuntimeAtomicCommitFault.check(.claimed, failure: failAfterPhase, cancellation: cancelAfterPhase)
            try Task.checkCancellation()
            if let confirmation {
                let consumed = try database.query(
                    "SELECT 1 AS present FROM runtime_confirmation_consumptions WHERE token = ? LIMIT 1",
                    bindings: [.text(confirmation.token.rawValue)]
                )
                guard consumed.isEmpty else { throw RuntimeAtomicCommitError.confirmationConsumed }
            }

            let plan = try RuntimeAtomicCommitPlan(
                preparation: preparation,
                confirmation: confirmation,
                submittedAt: submittedAt,
                database: database
            )
            try RuntimeAtomicCommitFault.check(.snapshotsLoaded, failure: failAfterPhase, cancellation: cancelAfterPhase)
            try Task.checkCancellation()
            try plan.requireReducerReplay()
            try RuntimeAtomicCommitFault.check(.reduced, failure: failAfterPhase, cancellation: cancelAfterPhase)

            let casResults = try Self.applyAggregateCAS(
                in: database,
                mutations: plan.casMutations
            )
            try RuntimeAtomicCommitFault.check(.aggregatesApplied, failure: failAfterPhase, cancellation: cancelAfterPhase)
            try Task.checkCancellation()
            guard casResults.contains(where: { $0.key == plan.primaryKey }) else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            let correlationID = plan.correlationID
            let states = try plan.states(results: casResults)
            guard let primaryState = plan.state(for: plan.primaryKey) else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            let semanticEvent = try RuntimeAtomicSemanticEventFactory.make(
                command: preparation.command.typedPayload,
                commandPrivacy: preparation.command.privacy,
                commandLocalOnly: preparation.command.localOnly,
                primaryAggregate: primaryState.aggregate,
                primaryPriorRevision: try plan.priorRevision(for: plan.primaryKey),
                primaryResultingRevision: primaryState.revision,
                changedObjectIDs: plan.changedObjectIDs,
                transitionInputs: try plan.semanticTransitionInputs(results: casResults)
            )
            let encoded = try RuntimeSemanticEventCodec().encode(semanticEvent)
            let eventBytes = semanticEventBytesOverride ?? encoded
            let append = try CanonicalRuntimeSemanticEventStore.appendInTransaction(
                try CanonicalRuntimeSemanticEventAppendRequest(
                    eventID: plan.eventIntent.id,
                    commandID: preparation.commandID,
                    aggregate: primaryState.aggregate,
                    canonicalAggregateRevision: primaryState.revision,
                    correlationID: correlationID,
                    causationEventID: plan.causationEventID,
                    occurredAt: plan.occurredAt,
                    canonicalBytes: eventBytes
                ),
                to: database
            )
            guard case let .appended(eventRecord) = append else {
                throw RuntimeAtomicCommitError.eventQuarantined
            }
            try RuntimeAtomicCommitFault.check(.eventAppended, failure: failAfterPhase, cancellation: cancelAfterPhase)
            let lineage = RuntimeAuthorityLineageReference(
                eventID: eventRecord.lineage.eventID,
                eventSequence: eventRecord.lineage.sequence,
                eventHash: eventRecord.lineage.eventHash.hexadecimal
            )
            let tombstones = try plan.tombstoneDrafts(record: eventRecord)

            let unresolved = try Self.persistInvalidations(
                plan.projectionInvalidations,
                lineage: lineage,
                createdAt: claimedAt,
                database: database
            )
            try RuntimeAtomicCommitFault.check(.invalidationsPersisted, failure: failAfterPhase, cancellation: cancelAfterPhase)
            let undoability: RuntimeAuthorityUndoability
            guard let compensationDisposition = preparation.decision.writeSet.compensation else {
                throw RuntimeAtomicCommitError.malformedPreparation
            }
            switch compensationDisposition {
            case let .typedPlan(intent): undoability = .typedPlan(intent.planID)
            case let .noncompensable(evidence): undoability = .noncompensable(evidence)
            }
            let receipt = RuntimeAtomicCommitReceipt(
                receiptID: plan.receiptID,
                preparationID: preparation.preparationID,
                commandID: preparation.commandID,
                lineage: lineage,
                aggregateStates: states,
                tombstones: tombstones,
                unresolvedWork: unresolved + plan.pendingUnresolved(lineage: lineage),
                objectLinks: states.map {
                    RuntimeAuthorityObjectLink(
                        aggregate: $0.aggregate,
                        terminalRevision: $0.revision,
                        lifecycle: $0.lifecycle
                    )
                }.sorted {
                    ($0.aggregate.kind.rawValue, $0.aggregate.id.rawValue) <
                        ($1.aggregate.kind.rawValue, $1.aggregate.id.rawValue)
                },
                undoability: undoability,
                confirmationToken: confirmation?.token,
                confirmationDecisionDigest: confirmation.map { _ in preparation.decisionDigest },
                committedAt: submittedAt
            )
            try Self.persistReceipt(receipt, createdAt: claimedAt, database: database)
            try Self.persistTombstones(tombstones, createdAt: claimedAt, database: database)
            let externalOperationCreations: [RuntimeCanonicalExternalOperationCreation]
            if let creation = try RuntimeExternalOperationCreationFactory.make(
                effect: plan.externalEffect,
                receipt: receipt,
                command: preparation.command,
                createdAt: receipt.committedAt
            ) {
                _ = try CanonicalRuntimeExternalOperationStore.persistCreation(
                    creation,
                    database: database
                )
                externalOperationCreations = [creation]
            } else {
                externalOperationCreations = []
            }
            if let confirmation {
                try Self.consumeConfirmation(
                    confirmation,
                    receiptID: receipt.receiptID,
                    preparation: preparation,
                    lineage: lineage,
                    consumedAt: claimedAt,
                    database: database
                )
            }
            let attachmentArtifacts: [RuntimeCommittedReceiptArtifactLink]
            if let attachmentIntent {
                let targetRevision: UInt64
                if let target = attachmentIntent.target {
                    let targetReference = RuntimePreparationAggregateReference(
                        family: target.kind,
                        objectID: try RuntimeDomainObjectID(validating: target.id.rawValue)
                    )
                    guard let dependency = preparation.decision.readSet.objects.first(where: {
                        $0.aggregate == targetReference
                    }),
                    case let .exact(observedTargetRevision) = dependency.observedRevision,
                    dependency.expectedRevision == dependency.observedRevision else {
                        throw RuntimeAtomicCommitError.corruptAuthority
                    }
                    targetRevision = observedTargetRevision
                } else {
                    targetRevision = 0
                }
                let attachmentMutation = try CanonicalRuntimeAttachmentStore.apply(
                    attachmentIntent, commandID: preparation.commandID,
                    receiptID: receipt.receiptID, lineage: receipt.lineage,
                    targetRevision: targetRevision, at: submittedAt, database: database
                )
                attachmentArtifacts = attachmentMutation.receiptArtifacts
            } else {
                attachmentArtifacts = []
            }
            try RuntimeAtomicCommitFault.check(.confirmationConsumed, failure: failAfterPhase, cancellation: cancelAfterPhase)
            try Task.checkCancellation()
            let compensationConsumption: RuntimeCompensationConsumptionDraft?
            if case let .compensation(command) = preparation.command.typedPayload {
                compensationConsumption = RuntimeCompensationConsumptionDraft(
                    planID: command.planID,
                    sourceReceiptID: command.sourceReceiptID,
                    compensationReceiptID: receipt.receiptID,
                    compensationCommandID: preparation.commandID,
                    terminalEventSequence: lineage.eventSequence,
                    consumedAtMilliseconds: claimedAt
                )
            } else {
                compensationConsumption = nil
            }
            let committedReceiptCore = try RuntimeCommittedReceiptAuthority.persist(
                atomicReceipt: receipt,
                eventRecord: eventRecord,
                correlationID: correlationID,
                dispositionIntent: compensationDisposition,
                externalOperationCreations: externalOperationCreations,
                attachmentArtifacts: attachmentArtifacts,
                compensationConsumption: compensationConsumption,
                createdAtMilliseconds: claimedAt,
                phase: { authorityPhase in
                    let atomicPhase: RuntimeAtomicCommitPhase = switch authorityPhase {
                    case .coreInserted: .receiptCorePersisted
                    case .historyPersisted: .receiptHistoryPersisted
                    case .dispositionPersisted: .compensationDispositionPersisted
                    case .compensationConsumed: .compensationConsumed
                    case .graphAuthenticated: .receiptGraphAuthenticated
                    }
                    try RuntimeAtomicCommitFault.check(
                        atomicPhase,
                        failure: failAfterPhase,
                        cancellation: cancelAfterPhase
                    )
                },
                database: database
            )
            _ = committedReceiptCore
            try RuntimeAtomicCommitFault.check(.receiptPersisted, failure: failAfterPhase, cancellation: cancelAfterPhase)
            try RuntimeAtomicCommitFault.check(.externalOperationsPersisted, failure: failAfterPhase, cancellation: cancelAfterPhase)
            try Task.checkCancellation()

            let committed = RuntimeCommittedMutation(
                preparationID: preparation.preparationID,
                commandID: preparation.commandID,
                authorityReceiptID: plan.receiptID,
                projectionDegradation: []
            )
            let finalOutcome = RuntimeAtomicCommitFinalOutcome(
                committed: committed,
                receipt: committedReceiptCore,
                externalOperationCreations: try externalOperationCreations.map { creation in
                    RuntimeAtomicExternalOperationCreationEvidence(
                        operationID: creation.operationID,
                        kind: creation.kind,
                        creationDigest: try RuntimeExternalOperationCodec.creationDigest(creation),
                        receiptID: creation.receiptID,
                        lineage: creation.lineage
                    )
                }.sorted { $0.operationID < $1.operationID }
            )
            let finalBytes = try RuntimeAtomicCommitCoding.encodeFinalOutcome(finalOutcome)
            _ = try Self.finalizeIdempotency(
                in: database,
                identity: claim.claimIdentity,
                finalization: try CanonicalIdempotencyFinalization(
                    ownerID: ownerID,
                    resultPayload: finalBytes,
                    finalizedAtMilliseconds: claimedAt
                )
            )
            try RuntimeAtomicCommitFault.check(.idempotencyFinalized, failure: failAfterPhase, cancellation: cancelAfterPhase)
            try Task.checkCancellation()
            return finalOutcome
    }
}

private enum RuntimeAtomicCommitFault {
    static func check(
        _ phase: RuntimeAtomicCommitPhase,
        failure: RuntimeAtomicCommitPhase?,
        cancellation: RuntimeAtomicCommitPhase?
    ) throws {
        if phase == failure { throw RuntimeAtomicCommitError.injectedFailure(phase) }
        if phase == cancellation { throw CancellationError() }
    }
}

enum RuntimeAtomicCommitCoding {
    static func encode<Value: Encodable>(_ value: Value) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try encoder.encode(value)
    }

    static func decodeFinalOutcome(
        _ bytes: Data,
        storedChecksum: String
    ) throws -> RuntimeAtomicCommitFinalOutcome {
        guard RuntimeStoreManifestCodec.isSHA256Hex(storedChecksum),
              LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == storedChecksum else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        switch try inspectFinalOutcome(bytes) {
        case let .current(value):
            try validateFinalOutcome(value)
            return value
        case .legacyV5, .legacyV6:
            throw RuntimeAtomicCommitError.migrationRequired(
                expected: runtimeCommittedReceiptSchemaVersion,
                actual: runtimeCanonicalProjectionSchemaVersion
            )
        }
    }

    static func encodeFinalOutcome(_ value: RuntimeAtomicCommitFinalOutcome) throws -> Data {
        try encode(RuntimeAtomicCommitFinalOutcomeEnvelope(outcomeVersion: 3, outcome: value))
    }

    static func requireFinalizedOutcome(
        _ bytes: Data,
        storedChecksum: String,
        references expectedCore: RuntimeCommittedReceiptCore
    ) throws {
        let outcome = try decodeFinalOutcome(bytes, storedChecksum: storedChecksum)
        guard outcome.receipt == expectedCore,
              outcome.committed.preparationID == expectedCore.facts.preparationID,
              outcome.committed.commandID == expectedCore.facts.commandID,
              outcome.committed.authorityReceiptID == expectedCore.facts.receiptID else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
    }

    private enum FinalOutcomeInspection {
        case current(RuntimeAtomicCommitFinalOutcome)
        case legacyV5
        case legacyV6
    }

    private struct FinalOutcomeVersionProbe: Decodable {
        let outcomeVersion: Int
    }

    private static func inspectFinalOutcome(_ bytes: Data) throws -> FinalOutcomeInspection {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let probe: FinalOutcomeVersionProbe?
        do {
            probe = try decoder.decode(FinalOutcomeVersionProbe.self, from: bytes)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            probe = nil
        }
        if let probe {
            guard probe.outcomeVersion <= 3 else {
                throw RuntimeAtomicCommitError.migrationRequired(
                    expected: 3,
                    actual: probe.outcomeVersion
                )
            }
            if probe.outcomeVersion == 2 {
                let envelope: RuntimeAtomicCommitLegacyV6FinalOutcomeEnvelope
                do {
                    envelope = try decoder.decode(
                        RuntimeAtomicCommitLegacyV6FinalOutcomeEnvelope.self, from: bytes
                    )
                } catch {
                    throw RuntimeAtomicCommitError.corruptAuthority
                }
                guard envelope.outcomeVersion == 2, try encode(envelope) == bytes else {
                    throw RuntimeAtomicCommitError.corruptAuthority
                }
                return .legacyV6
            }
            guard probe.outcomeVersion == 3 else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            let envelope: RuntimeAtomicCommitFinalOutcomeEnvelope
            do {
                envelope = try decoder.decode(RuntimeAtomicCommitFinalOutcomeEnvelope.self, from: bytes)
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            guard envelope.outcomeVersion == 3, try encode(envelope) == bytes else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            return .current(envelope.outcome)
        }
        do {
            let legacy = try decoder.decode(RuntimeAtomicCommitLegacyV5FinalOutcome.self, from: bytes)
            guard try encode(legacy) == bytes else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            return .legacyV5
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as RuntimeAtomicCommitError {
            throw error
        } catch {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
    }

    static func decodeCanonical<Value: Codable>(
        _ type: Value.Type,
        from bytes: Data
    ) throws -> Value {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let value: Value
        do {
            value = try decoder.decode(type, from: bytes)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        guard try encode(value) == bytes else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        return value
    }

    static func decodeAggregateState(_ bytes: Data) throws -> RuntimeCanonicalAggregateState {
        do {
            return try RuntimeCanonicalAggregateStateCodec().decode(bytes)
        } catch {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
    }

    private static func validateFinalOutcome(
        _ value: RuntimeAtomicCommitFinalOutcome
    ) throws {
        let receipt = value.receipt
        let facts = receipt.facts
        let lineage = facts.lineage
        let committedAt = facts.committedAt.timeIntervalSince1970
        guard try RuntimeCommittedReceiptCodec.makeCore(facts) == receipt,
              RuntimePreparationID(rawValue: facts.preparationID.rawValue)?.rawValue == facts.preparationID.rawValue,
              RuntimeCommandID(rawValue: facts.commandID.rawValue)?.rawValue == facts.commandID.rawValue,
              RuntimeReceiptID(rawValue: facts.receiptID.rawValue)?.rawValue == facts.receiptID.rawValue,
              RuntimeEventID(rawValue: lineage.eventID.rawValue)?.rawValue == lineage.eventID.rawValue,
              facts.confirmationToken.map({
                  RuntimeConfirmationToken(rawValue: $0.rawValue)?.rawValue == $0.rawValue
              }) ?? true,
              facts.confirmationDecisionDigest.map({
                  RuntimeCommandFingerprint(rawValue: $0.rawValue)?.rawValue == $0.rawValue
              }) ?? true,
              (facts.confirmationToken == nil) == (facts.confirmationDecisionDigest == nil),
              value.committed.preparationID == facts.preparationID,
              value.committed.commandID == facts.commandID,
              value.committed.authorityReceiptID == facts.receiptID,
              value.committed.projectionDegradation.isEmpty,
              lineage.eventSequence > 0,
              RuntimeStoreManifestCodec.isSHA256Hex(lineage.eventHash),
              committedAt.isFinite, committedAt >= 0,
              facts.objects.isEmpty == false,
              facts.privacy.localOnly else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let externalArtifacts = facts.artifacts.filter { $0.kind == .externalOperation }
        let creationIDs = value.externalOperationCreations.map(\.operationID.rawValue)
        guard value.externalOperationCreations.count <= RuntimeExternalOperationLimits.maximumOperationsPerReceipt,
              Set(creationIDs).count == creationIDs.count,
              creationIDs == creationIDs.sorted(),
              externalArtifacts.map(\.stableID).sorted() == creationIDs.sorted(),
              value.externalOperationCreations.allSatisfy({ creation in
                  RuntimeStoreManifestCodec.isSHA256Hex(creation.creationDigest) &&
                    creation.receiptID == facts.receiptID && creation.lineage == lineage &&
                    externalArtifacts.contains(where: {
                        $0.stableID == creation.operationID.rawValue &&
                            $0.digest == creation.creationDigest
                    })
              }) else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
    }

    private static func validStableIdentity(_ value: String) -> Bool {
        value.isEmpty == false && value.utf8.count <= 1_024 &&
            value == value.trimmingCharacters(in: .whitespacesAndNewlines) &&
            value == value.precomposedStringWithCanonicalMapping &&
            value.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false
    }
}

private struct RuntimeAtomicCommitPlan {
    let preparation: RuntimePreparation
    let confirmation: RuntimeMutationConfirmation?
    let submittedAt: Date
    let primaryKey: CanonicalAggregateKey
    let priorRevision: UInt64?
    let eventIntent: RuntimeSemanticEventIntent
    let receiptID: RuntimeReceiptID
    let occurredAt: Date
    let changedObjectIDs: [RuntimeDomainObjectID]
    let projectionInvalidations: [RuntimeCanonicalProjectionID]
    let externalEffect: RuntimeExternalEffectIntent
    let casMutations: [CanonicalAggregateCASMutation]
    let stateByKey: [CanonicalAggregateKey: RuntimeCanonicalAggregateState]
    let priorStateDigestByKey: [CanonicalAggregateKey: String]
    let observedSnapshot: RuntimePreparationSnapshot
    let proposedObjectID: RuntimeDomainObjectID?
    let correlationID: RuntimeCorrelationID
    let causationEventID: RuntimeEventID?

    init(
        preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?,
        submittedAt: Date,
        database: isolated SQLiteDatabase
    ) throws {
        guard preparation.decision.disposition == .apply,
              preparation.decision.writeSet.events.count == 1,
              let eventIntent = preparation.decision.writeSet.events.first,
              let receiptID = preparation.decision.writeSet.receiptIntentID,
              eventIntent.commandID == preparation.commandID,
              eventIntent.privacy == preparation.command.privacy,
              let occurredAt = DomainTimestamp.date(from: eventIntent.occurredAt) else {
            throw RuntimeAtomicCommitError.malformedPreparation
        }
        if case let .schedule(schedule) = preparation.command.typedPayload,
           schedule.action == .undo {
            throw RuntimeAtomicCommitError.malformedPreparation
        }
        let causalAuthority: (correlationID: RuntimeCorrelationID, causationEventID: RuntimeEventID?)
        if case let .compensation(command) = preparation.command.typedPayload {
            causalAuthority = try Self.authenticateCompensationCommand(
                command,
                commandPrivacy: preparation.command.privacy,
                expectedRevision: preparation.command.expectedRevision,
                confirmationScope: preparation.decision.confirmationScope,
                submittedAt: submittedAt,
                database: database
            )
        } else {
            causalAuthority = (
                try RuntimeCorrelationID(validating: "correlation.\(preparation.preparationID.rawValue)"),
                nil
            )
        }
        let semanticType: RuntimeSemanticEventTypeID
        guard case let .mutating(type) = RuntimeSemanticEventClassifier.classify(preparation.command.typedPayload) else {
            throw RuntimeAtomicCommitError.malformedPreparation
        }
        semanticType = type
        guard preparation.decision.writeSet.projectionInvalidations ==
                RuntimeCanonicalProjectionRegistry.projectionIDs(for: semanticType) else {
            throw RuntimeAtomicCommitError.malformedPreparation
        }
        let primaryID = try RuntimeAtomicAggregateIdentity.primaryID(
            command: preparation.command.typedPayload,
            transitions: preparation.decision.writeSet.transitions
        )
        let primaryReference = RuntimePreparationAggregateReference(
            family: semanticType.aggregateKind,
            objectID: try RuntimeDomainObjectID(validating: primaryID.rawValue)
        )
        primaryKey = try CanonicalAggregateKey(
            kind: primaryReference.family.rawValue,
            id: primaryReference.objectID.rawValue
        )
        self.preparation = preparation
        self.confirmation = confirmation
        self.submittedAt = submittedAt
        self.eventIntent = eventIntent
        self.receiptID = receiptID
        self.occurredAt = occurredAt
        correlationID = causalAuthority.correlationID
        causationEventID = causalAuthority.causationEventID
        projectionInvalidations = preparation.decision.writeSet.projectionInvalidations
        externalEffect = preparation.decision.writeSet.externalEffect
        changedObjectIDs = Array(Set(preparation.decision.writeSet.transitions.map(\.objectID))).sorted()
        proposedObjectID = preparation.decision.writeSet.transitions.first(where: {
            return $0.transition == .create &&
                preparation.command.runtimePreparationAggregateReferences.contains($0.aggregate) == false
        })?.objectID

        var transitionsByKey: [CanonicalAggregateKey: RuntimeObjectTransitionIntent] = [:]
        for transition in preparation.decision.writeSet.transitions {
            let key = try CanonicalAggregateKey(
                kind: transition.aggregate.family.rawValue,
                id: transition.aggregate.objectID.rawValue
            )
            guard transitionsByKey[key] == nil else {
                throw RuntimeAtomicCommitError.malformedPreparation
            }
            let isUnobservedProposedCreate = transition.transition == .create &&
                preparation.command.runtimePreparationAggregateReferences.contains(transition.aggregate) == false
            let dependency = preparation.decision.readSet.objects.first(where: {
                $0.aggregate == transition.aggregate
            })
            guard isUnobservedProposedCreate ||
                    (dependency?.expectedRevision == transition.expectedRevision &&
                     dependency?.observedRevision == transition.expectedRevision) else {
                throw RuntimeAtomicCommitError.stalePreparation
            }
            switch (transition.transition, transition.expectedRevision) {
            case (.create, .absent), (.update, .exact),
                 (.attach, .exact), (.detach, .exact), (.tombstone, .exact),
                 (.restore, .exact):
                break
            default:
                throw RuntimeAtomicCommitError.stalePreparation
            }
            transitionsByKey[key] = transition
        }
        guard let primaryIntent = transitionsByKey[primaryKey] else {
            throw RuntimeAtomicCommitError.malformedPreparation
        }
        let primaryExpected = primaryIntent.expectedRevision
        priorRevision = switch primaryExpected {
        case .absent: nil
        case let .exact(value): value
        }
        if semanticType == .attachmentLinked {
            guard primaryIntent.transition == (priorRevision == nil ? .create : .update) else {
                throw RuntimeAtomicCommitError.stalePreparation
            }
        } else if semanticType.isCreation != (priorRevision == nil) {
            throw RuntimeAtomicCommitError.stalePreparation
        }
        let keys = Array(transitionsByKey.keys).sorted()
        var states: [CanonicalAggregateKey: RuntimeCanonicalAggregateState] = [:]
        var priorDigests: [CanonicalAggregateKey: String] = [:]
        var mutations: [CanonicalAggregateCASMutation] = []
        for key in keys {
            guard let stateKind = RuntimeSemanticAggregateKind(rawValue: key.kind) else {
                throw RuntimeAtomicCommitError.malformedPreparation
            }
            guard let intent = transitionsByKey[key] else {
                throw RuntimeAtomicCommitError.malformedPreparation
            }
            let expected = intent.expectedRevision
            let transition = intent.transition
            let resultingRevision = try RuntimeAtomicAggregateIdentity.resultingRevision(expected)
            let lifecycle: RuntimeAggregateLifecycle = transition == .tombstone ? .tombstoned : .active
            let state = RuntimeCanonicalAggregateState(
                aggregate: RuntimeSemanticAggregate(
                    kind: stateKind,
                    id: try RuntimeAggregateID(validating: key.id)
                ),
                revision: resultingRevision,
                lifecycle: lifecycle,
                transition: transition,
                commandPayload: preparation.command.typedPayload,
                changedObjectIDs: changedObjectIDs,
                privacy: preparation.command.privacy,
                localOnly: preparation.command.localOnly
            )
            let bytes = try RuntimeCanonicalAggregateStateCodec().encode(state)
            if case let .exact(expectedRevision) = expected {
                priorDigests[key] = try Self.requireWritableExistingState(
                    key: key,
                    expectedRevision: expectedRevision,
                    transition: transition,
                    database: database
                )
            }
            states[key] = state
            mutations.append(try CanonicalAggregateCASMutation(
                key: key,
                expectedRevision: expected,
                payloadVersion: 1,
                payload: bytes
            ))
        }
        stateByKey = states
        priorStateDigestByKey = priorDigests
        casMutations = mutations

        let observedPrimary = try Self.observedRevision(key: primaryKey, database: database)
        let aggregateObserved = observedPrimary.map { RuntimeExpectedRevision.exact($0) } ?? .absent
        guard let primaryFamily = RuntimeSemanticAggregateKind(rawValue: primaryKey.kind) else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let primaryReference = RuntimePreparationAggregateReference(
            family: primaryFamily,
            objectID: try RuntimeDomainObjectID(validating: primaryKey.id)
        )
        var revisions: [RuntimePreparationAggregateReference: RuntimeExpectedRevision] = [
            primaryReference: aggregateObserved,
        ]
        for dependency in preparation.decision.readSet.objects {
            let key = try CanonicalAggregateKey(kind: dependency.family, id: dependency.objectID.rawValue)
            let observed = try Self.observedRevision(key: key, database: database)
            revisions[dependency.aggregate] = observed.map { .exact($0) } ?? .absent
        }
        observedSnapshot = RuntimePreparationSnapshot(
            aggregateRevisions: revisions,
            cursors: preparation.decision.readSet.cursors,
            privacy: preparation.command.privacy
        )
    }

    private static func authenticateCompensationCommand(
        _ command: RuntimeCompensationCommand,
        commandPrivacy: EventLedgerPrivacyClassification,
        expectedRevision: RuntimeExpectedRevision,
        confirmationScope: RuntimeConfirmationScope?,
        submittedAt: Date,
        database: isolated SQLiteDatabase
    ) throws -> (correlationID: RuntimeCorrelationID, causationEventID: RuntimeEventID?) {
        let core: RuntimeCommittedReceiptCore
        let plan: RuntimeCommittedCompensationPlan
        let graph: RuntimeAuthenticatedReceiptGraph
        do {
            core = try RuntimeCommittedReceiptAuthority.loadCore(
                receiptID: command.sourceReceiptID,
                database: database
            )
            graph = try RuntimeCommittedReceiptAuthority.authenticatePersistedCore(
                core, database: database
            )
            plan = try RuntimeCommittedReceiptAuthority.loadPlan(
                planID: command.planID,
                database: database
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        guard core.facts.receiptID == command.sourceReceiptID,
              core.facts.privacy.localOnly,
              core.facts.privacy.classification == commandPrivacy,
              plan.sourceReceiptID == command.sourceReceiptID,
              plan.sourceLineage == command.sourceLineage,
              plan.sourceLineage == core.facts.lineage,
              plan.sourceCorrelationID == core.facts.correlationID,
              plan.planID == command.planID,
              plan.digest == command.planDigest,
              plan.action == command.action,
              plan.targets == command.targets,
              plan.requiresConfirmation == command.requiresConfirmation,
              submittedAt <= plan.expiresAt,
              command.action.target == command.target,
              command.content == RuntimeCommandContent(),
              confirmationScope == (plan.requiresConfirmation ? .semanticCompensation : nil),
              command.targets.isEmpty == false,
              command.targets.count <= RuntimeCompensationLimits.maximumTargets,
              command.targets == command.targets.sorted(),
              Set(command.targets.map {
                  "\($0.aggregate.kind.rawValue)\u{0}\($0.aggregate.id.rawValue)"
              }).count == command.targets.count,
              command.targets.allSatisfy({
                  if Task.isCancelled { return false }
                  return $0.aggregate.kind == command.action.aggregateKind &&
                      $0.sourcePriorRevision == nil &&
                      $0.sourceTransition == .create &&
                      $0.requiredLifecycle == .active &&
                      $0.inverseTransition == command.action.transition &&
                      $0.requiredCurrentRevision == $0.sourceRevision
              }) else {
            throw RuntimeAtomicCommitError.stalePreparation
        }
        let externalAuthority = try RuntimeCommittedReceiptAuthority
            .prepareExternalOperationsForCompensation(
                graph: graph,
                plan: plan,
                at: submittedAt,
                database: database
            )
        guard externalAuthority == .clear else {
            throw RuntimeAtomicCommitError.stalePreparation
        }
        guard case let .exact(primaryRevision) = expectedRevision,
              command.targets.contains(where: {
                  $0.aggregate.kind == command.action.aggregateKind &&
                      $0.aggregate.id.rawValue == command.action.primaryObjectID.rawValue &&
                      $0.requiredCurrentRevision == primaryRevision
              }) else {
            throw RuntimeAtomicCommitError.stalePreparation
        }

        let sourceEventRows = try database.query(
            """
            SELECT event_id, sequence, event_hash, command_id, correlation_id
            FROM runtime_semantic_events WHERE sequence = ? LIMIT 2
            """,
            bindings: [.integer(try int64(core.facts.lineage.eventSequence))]
        )
        guard sourceEventRows.count == 1, let sourceEvent = sourceEventRows.first,
              sourceEvent.value(named: "event_id") == .text(core.facts.lineage.eventID.rawValue),
              sourceEvent.value(named: "event_hash") == .text(core.facts.lineage.eventHash),
              sourceEvent.value(named: "command_id") == .text(core.facts.commandID.rawValue),
              sourceEvent.value(named: "correlation_id") == .text(core.facts.correlationID.rawValue) else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let quarantine = try database.query(
            """
            SELECT 1 AS present FROM runtime_semantic_event_quarantine
            WHERE source_event_id = ? OR source_event_sequence = ? LIMIT 1
            """,
            bindings: [
                .text(core.facts.lineage.eventID.rawValue),
                .integer(try int64(core.facts.lineage.eventSequence)),
            ]
        )
        guard quarantine.isEmpty else { throw RuntimeAtomicCommitError.corruptAuthority }

        let finalized = try database.query(
            """
            SELECT final_result_version, final_result_payload, final_result_checksum, finalized_at_ms
            FROM runtime_command_idempotency WHERE command_id = ? LIMIT 2
            """,
            bindings: [.text(core.facts.commandID.rawValue)],
            maximumDecodedBytes: RuntimeCommittedReceiptReadBounds.maximumSelectedPayloadRowBytes
        )
        guard finalized.count == 1, let finalizedRow = finalized.first,
              finalizedRow.value(named: "final_result_version") == .integer(
                Int64(canonicalIdempotencyFinalResultVersion)
              ),
              case let .blob(finalBytes)? = finalizedRow.value(named: "final_result_payload"),
              finalBytes.count <= RuntimeCommittedReceiptReadBounds.maximumFinalizedResultPayloadBytes,
              case let .text(finalChecksum)? = finalizedRow.value(named: "final_result_checksum"),
              RuntimeStoreManifestCodec.isSHA256Hex(finalChecksum),
              LocalRuntimeStorageChecksum.sha256Hex(for: finalBytes) == finalChecksum,
              case let .integer(finalizedAt)? = finalizedRow.value(named: "finalized_at_ms"),
              finalizedAt >= 0 else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        try RuntimeAtomicCommitCoding.requireFinalizedOutcome(
            finalBytes,
            storedChecksum: finalChecksum,
            references: core
        )
        let consumed = try database.query(
            "SELECT 1 AS present FROM runtime_compensation_consumptions WHERE plan_id = ? LIMIT 1",
            bindings: [.text(plan.planID.rawValue)]
        )
        guard consumed.isEmpty else { throw RuntimeAtomicCommitError.stalePreparation }

        let targetRows = try database.query(
            """
            SELECT family, object_id, source_prior_revision, source_revision,
                   source_transition_kind, required_current_revision,
                   required_lifecycle, source_state_digest, transition_kind
            FROM runtime_compensation_plan_targets
            WHERE plan_id = ? ORDER BY family, object_id LIMIT ?
            """,
            bindings: [
                .text(plan.planID.rawValue),
                .integer(Int64(RuntimeCompensationLimits.maximumTargets + 1)),
            ],
            maximumDecodedBytes: 262_144
        )
        guard targetRows.count == plan.targets.count else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        for (row, target) in zip(targetRows, plan.targets) {
            try Task.checkCancellation()
            guard row.value(named: "family") == .text(target.aggregate.kind.rawValue),
                  row.value(named: "object_id") == .text(target.aggregate.id.rawValue),
                  row.value(named: "source_prior_revision") == (try target.sourcePriorRevision.map {
                    .integer(try int64($0))
                  } ?? .null),
                  row.value(named: "source_revision") == .integer(try int64(target.sourceRevision)),
                  row.value(named: "source_transition_kind") == .text(target.sourceTransition.rawValue),
                  row.value(named: "required_current_revision") == .integer(try int64(target.requiredCurrentRevision)),
                  row.value(named: "required_lifecycle") == .text(target.requiredLifecycle.rawValue),
                  row.value(named: "source_state_digest") == .text(target.sourceStateDigest),
                  row.value(named: "transition_kind") == .text(target.inverseTransition.rawValue) else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            try authenticateCurrentTarget(target, database: database)
        }
        return (core.facts.correlationID, core.facts.lineage.eventID)
    }

    private static func authenticateCurrentTarget(
        _ target: RuntimeCompensationTargetExpectation,
        database: isolated SQLiteDatabase
    ) throws {
        let rows = try database.query(
            """
            SELECT revision, payload_version, payload, payload_checksum
            FROM runtime_aggregates
            WHERE aggregate_kind = ? AND aggregate_id = ? LIMIT 2
            """,
            bindings: [
                .text(target.aggregate.kind.rawValue),
                .text(target.aggregate.id.rawValue),
            ],
            maximumDecodedBytes: RuntimeCommittedReceiptReadBounds.maximumSelectedPayloadRowBytes
        )
        guard rows.count == 1, let row = rows.first,
              row.value(named: "payload_version") == .integer(1),
              row.value(named: "revision") == .integer(try int64(target.requiredCurrentRevision)),
              case let .blob(bytes)? = row.value(named: "payload"),
              case let .text(checksum)? = row.value(named: "payload_checksum"),
              checksum == target.sourceStateDigest,
              RuntimeStoreManifestCodec.isSHA256Hex(checksum),
              checksum == checksum.lowercased(),
              LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == checksum else {
            throw RuntimeAtomicCommitError.stalePreparation
        }
        let state: RuntimeCanonicalAggregateState
        do { state = try RuntimeCanonicalAggregateStateCodec().decode(bytes) }
        catch is CancellationError { throw CancellationError() }
        catch { throw RuntimeAtomicCommitError.corruptAuthority }
        guard state.aggregate == target.aggregate,
              state.revision == target.requiredCurrentRevision,
              state.lifecycle == target.requiredLifecycle,
              try RuntimeCanonicalAggregateStateCodec().encode(state) == bytes else {
            throw RuntimeAtomicCommitError.stalePreparation
        }
        if target.inverseTransition == .restore {
            guard state.lifecycle == .tombstoned, state.transition == .tombstone else {
                throw RuntimeAtomicCommitError.stalePreparation
            }
            let tombstones = try database.query(
                """
                SELECT h.terminal_revision, h.state_digest, t.payload, t.payload_checksum
                FROM runtime_object_tombstone_history AS t
                JOIN runtime_object_history AS h ON h.history_id = t.history_id
                WHERE t.family = ? AND t.object_id = ?
                ORDER BY t.terminal_event_sequence DESC LIMIT 1
                """,
                bindings: [
                    .text(target.aggregate.kind.rawValue),
                    .text(target.aggregate.id.rawValue),
                ],
                maximumDecodedBytes: RuntimeCommittedReceiptReadBounds.maximumSelectedPayloadRowBytes
            )
            guard tombstones.count == 1, let tombstone = tombstones.first,
                  tombstone.value(named: "terminal_revision") == .integer(try int64(target.requiredCurrentRevision)),
                  tombstone.value(named: "state_digest") == .text(target.sourceStateDigest),
                  case let .blob(tombstoneBytes)? = tombstone.value(named: "payload"),
                  case let .text(tombstoneChecksum)? = tombstone.value(named: "payload_checksum"),
                  LocalRuntimeStorageChecksum.sha256Hex(for: tombstoneBytes) == tombstoneChecksum else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
        } else {
            guard state.lifecycle == .active, state.transition != .tombstone else {
                throw RuntimeAtomicCommitError.stalePreparation
            }
        }
    }

    private static func int64(_ value: UInt64) throws -> Int64 {
        guard value <= UInt64(Int64.max) else { throw RuntimeAtomicCommitError.corruptAuthority }
        return Int64(value)
    }

    func requireReducerReplay() throws {
        if case let .schedule(schedule) = preparation.command.typedPayload,
           schedule.action == .undo {
            throw RuntimeAtomicCommitError.malformedPreparation
        }
        guard let primaryFamily = RuntimeSemanticAggregateKind(rawValue: primaryKey.kind),
              let primaryObjectID = RuntimeDomainObjectID(rawValue: primaryKey.id) else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let primaryReference = RuntimePreparationAggregateReference(
            family: primaryFamily,
            objectID: primaryObjectID
        )
        guard observedSnapshot.aggregateRevisions[primaryReference] == preparation.authorization.observedRevision,
              preparation.decision.readSet.objects.allSatisfy({ dependency in
                  observedSnapshot.aggregateRevisions[dependency.aggregate] == dependency.observedRevision
              }), let compensation = preparation.decision.writeSet.compensation else {
            throw RuntimeAtomicCommitError.stalePreparation
        }
        let rollbackID: RuntimeRollbackPlanID
        switch compensation {
        case let .typedPlan(intent):
            rollbackID = intent.planID
        case .noncompensable:
            guard let placeholder = RuntimeRollbackPlanID(
                rawValue: "noncompensable.\(preparation.preparationID.rawValue)"
            ) else { throw RuntimeAtomicCommitError.malformedPreparation }
            rollbackID = placeholder
        }
        let token: RuntimeConfirmationToken
        if let bound = preparation.confirmationRequest?.token {
            token = bound
        } else {
            guard let placeholder = RuntimeConfirmationToken(
                rawValue: "confirmation.none.\(preparation.preparationID.rawValue)"
            ) else { throw RuntimeAtomicCommitError.malformedPreparation }
            token = placeholder
        }
        let operationID: RuntimeExternalOperationID
        switch externalEffect {
        case let .outbox(boundOperationID, _): operationID = boundOperationID
        case .none:
            guard let placeholder = RuntimeExternalOperationID(
                rawValue: "external.none.\(preparation.preparationID.rawValue)"
            ) else { throw RuntimeAtomicCommitError.malformedPreparation }
            operationID = placeholder
        }
        let context = RuntimePreparationContext(
            preparationID: preparation.preparationID,
            confirmationToken: token,
            proposedObjectID: proposedObjectID,
            eventID: eventIntent.id,
            receiptID: receiptID,
            rollbackPlanID: rollbackID,
            externalOperationID: operationID,
            issuedAt: preparation.issuedAt,
            expiresAt: preparation.expiresAt,
            boundary: .localOnly
        )
        let replayed = RuntimeFeatureMutationRouter().reduce(RuntimeFeatureReducerInput(
            command: preparation.command,
            commandID: preparation.commandID,
            snapshot: observedSnapshot,
            context: context
        ))
        guard replayed == preparation.decision else { throw RuntimeAtomicCommitError.reducerMismatch }
    }

    func states(results: [CanonicalAggregateCASResult]) throws -> [RuntimeCanonicalAggregateState] {
        try results.sorted { $0.key < $1.key }.map { result in
            guard let state = stateByKey[result.key], state.revision == result.revision else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            return state
        }
    }

    func priorRevision(for key: CanonicalAggregateKey) throws -> UInt64? {
        guard let mutation = casMutations.first(where: { $0.key == key }) else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        return switch mutation.expectedRevision {
        case .absent: nil
        case let .exact(value): value
        }
    }

    func state(for key: CanonicalAggregateKey) -> RuntimeCanonicalAggregateState? {
        stateByKey[key]
    }

    func priorStateDigest(for key: CanonicalAggregateKey) -> String? {
        priorStateDigestByKey[key]
    }

    func semanticTransitionInputs(
        results: [CanonicalAggregateCASResult]
    ) throws -> [RuntimeAtomicSemanticTransitionInput] {
        try results.sorted { $0.key < $1.key }.map { result in
            guard let state = stateByKey[result.key], state.revision == result.revision else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            return RuntimeAtomicSemanticTransitionInput(
                state: state,
                priorRevision: try priorRevision(for: result.key),
                predecessorStateDigest: priorStateDigest(for: result.key)
            )
        }
    }

    func tombstoneDrafts(record: CanonicalRuntimeSemanticEventRecord) throws -> [RuntimeCanonicalTombstoneDraft] {
        try record.event.mutation.aggregateTransitions.compactMap { transition in
            guard
                  transition.lifecycle == .tombstoned,
                  let authority = transition.tombstone,
                  let objectID = RuntimeDomainObjectID(rawValue: transition.aggregate.id.rawValue) else { return nil }
            return RuntimeCanonicalTombstoneDraft(
                objectID: objectID,
                family: transition.aggregate.kind.rawValue,
                terminalRevision: transition.resultingRevision,
                lineage: RuntimeAuthorityLineageReference(
                    eventID: record.lineage.eventID,
                    eventSequence: record.lineage.sequence,
                    eventHash: record.lineage.eventHash.hexadecimal
                ),
                authority: authority
            )
        }.sorted { ($0.family, $0.objectID.rawValue) < ($1.family, $1.objectID.rawValue) }
    }

    func pendingUnresolved(lineage: RuntimeAuthorityLineageReference) -> [RuntimeAuthorityUnresolvedWorkReference] {
        guard case let .outbox(operationID, _) = externalEffect else { return [] }
        return [RuntimeAuthorityUnresolvedWorkReference(
            kind: .externalOperation,
            stableID: operationID.rawValue,
            lineage: lineage
        )]
    }

    private static func requireWritableExistingState(
        key: CanonicalAggregateKey,
        expectedRevision: UInt64,
        transition: RuntimeObjectTransitionKind,
        database: isolated SQLiteDatabase
    ) throws -> String {
        let rows = try database.query(
            "SELECT revision, payload_version, payload, payload_checksum FROM runtime_aggregates WHERE aggregate_kind = ? AND aggregate_id = ? LIMIT 2",
            bindings: [.text(key.kind), .text(key.id)]
        )
        guard rows.count == 1, let row = rows.first else {
            throw RuntimeAtomicCommitError.stalePreparation
        }
        guard case .integer(1)? = row.value(named: "payload_version"),
              case let .blob(bytes)? = row.value(named: "payload"),
              case let .text(checksum)? = row.value(named: "payload_checksum"),
              RuntimeStoreManifestCodec.isSHA256Hex(checksum),
              LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == checksum,
              case let .integer(revision)? = row.value(named: "revision"), revision >= 0 else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let state: RuntimeCanonicalAggregateState
        do {
            state = try RuntimeCanonicalAggregateStateCodec().decode(bytes)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        guard state.aggregate.kind.rawValue == key.kind,
              state.aggregate.id.rawValue == key.id,
              state.revision == UInt64(revision) else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        guard state.revision == expectedRevision else {
            throw RuntimeAtomicCommitError.stalePreparation
        }
        let latestHistory = try database.query(
            """
            SELECT resulting_revision, lifecycle, transition_kind, state_digest
            FROM runtime_object_history
            WHERE family = ? AND object_id = ?
            ORDER BY terminal_event_sequence DESC LIMIT 1
            """,
            bindings: [.text(key.kind), .text(key.id)]
        )
        guard latestHistory.count == 1, let history = latestHistory.first,
              history.value(named: "resulting_revision") == .integer(revision),
              history.value(named: "lifecycle") == .text(state.lifecycle.rawValue),
              history.value(named: "transition_kind") == .text(state.transition.rawValue),
              history.value(named: "state_digest") == .text(checksum) else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        if transition == .restore {
            guard state.lifecycle == .tombstoned, state.transition == .tombstone else {
                throw RuntimeAtomicCommitError.stalePreparation
            }
            let tombstone = try database.query(
                """
                SELECT tombstone_history_id, receipt_id, terminal_revision,
                       predecessor_digest, payload, payload_checksum
                FROM runtime_object_tombstone_history
                WHERE family = ? AND object_id = ?
                ORDER BY terminal_event_sequence DESC LIMIT 1
                """,
                bindings: [.text(key.kind), .text(key.id)],
                maximumDecodedBytes: RuntimeCommittedReceiptReadBounds.maximumSelectedPayloadRowBytes
            )
            guard tombstone.count == 1, let row = tombstone.first,
                  row.value(named: "terminal_revision") == .integer(revision),
                  case let .text(predecessorDigest)? = row.value(named: "predecessor_digest"),
                  RuntimeStoreManifestCodec.isSHA256Hex(predecessorDigest),
                  case let .text(tombstoneHistoryID)? = row.value(named: "tombstone_history_id"),
                  case let .text(receiptID)? = row.value(named: "receipt_id"),
                  case let .blob(tombstoneBytes)? = row.value(named: "payload"),
                  case let .text(tombstoneChecksum)? = row.value(named: "payload_checksum"),
                  LocalRuntimeStorageChecksum.sha256Hex(for: tombstoneBytes) == tombstoneChecksum else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            let draft = try RuntimeAtomicCommitCoding.decodeCanonical(
                RuntimeCanonicalTombstoneDraft.self,
                from: tombstoneBytes
            )
            let retained = try database.query(
                """
                SELECT 1 AS present FROM runtime_receipt_retention_references
                WHERE receipt_id = ? AND reference_kind = 'tombstone_history'
                  AND reference_id = ? LIMIT 1
                """,
                bindings: [.text(receiptID), .text(tombstoneHistoryID)]
            )
            guard draft.family == key.kind,
                  draft.objectID.rawValue == key.id,
                  draft.terminalRevision == expectedRevision,
                  draft.authority.predecessorDigest == predecessorDigest,
                  retained.count == 1 else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
        } else {
            guard state.lifecycle == .active, state.transition != .tombstone else {
                throw RuntimeAtomicCommitError.stalePreparation
            }
        }
        return checksum
    }

    private static func observedRevision(
        key: CanonicalAggregateKey,
        database: isolated SQLiteDatabase
    ) throws -> UInt64? {
        let rows = try database.query(
            "SELECT revision FROM runtime_aggregates WHERE aggregate_kind = ? AND aggregate_id = ? LIMIT 2",
            bindings: [.text(key.kind), .text(key.id)]
        )
        guard rows.count <= 1 else { throw RuntimeAtomicCommitError.corruptAuthority }
        guard let row = rows.first else { return nil }
        guard case let .integer(value)? = row.value(named: "revision"), value >= 0 else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        return UInt64(value)
    }
}

private enum RuntimeAtomicAggregateIdentity {
    static func resultingRevision(_ expected: RuntimeExpectedRevision) throws -> UInt64 {
        switch expected {
        case .absent: return 0
        case let .exact(value):
            guard value < UInt64(Int64.max) else { throw RuntimeAtomicCommitError.stalePreparation }
            return value + 1
        }
    }

    static func primaryID(
        command: RuntimeCommandPayload,
        transitions: [RuntimeObjectTransitionIntent]
    ) throws -> RuntimeAggregateID {
        let raw: String? = switch command {
        case let .capture(value): value.target.captureID
        case let .goal(value): value.target.goalID
        case let .step(value): value.target.stepID
        case let .schedule(value): value.target.timeID
        case let .reminder(value): value.target.timeID ?? value.target.goalID
        case .profile: "profile.local"
        case let .history(value): value.target.reviewID ?? value.target.recommendationID
        case let .repair(value): value.target.recommendationID ?? value.target.goalID
        case .importDeletion:
            command.runtimePreparationAggregateReferences.first?.objectID.rawValue
        case let .externalOperation(value): value.operationID.rawValue
        case let .attachment(value): value.intent.attachmentID.rawValue
        case let .compensation(value): value.action.primaryObjectID.rawValue
        }
        guard case let .mutating(typeID) = RuntimeSemanticEventClassifier.classify(command) else {
            throw RuntimeAtomicCommitError.malformedPreparation
        }
        let semanticFamily = typeID.aggregateKind
        let semanticTransitions = transitions.filter { $0.aggregate.family == semanticFamily }
        let value: String
        if let raw {
            value = raw
        } else {
            guard semanticTransitions.count == 1,
                  semanticTransitions[0].transition == .create else {
                throw RuntimeAtomicCommitError.malformedPreparation
            }
            value = semanticTransitions[0].aggregate.objectID.rawValue
        }
        guard semanticTransitions.contains(where: { $0.aggregate.objectID.rawValue == value }),
              let identity = RuntimeAggregateID(rawValue: value) else {
            throw RuntimeAtomicCommitError.malformedPreparation
        }
        return identity
    }

    static func transitionKind(
        for command: RuntimeCommandPayload
    ) -> RuntimeObjectTransitionKind {
        switch command {
        case let .capture(value):
            switch value.action {
            case .quickCapture: return .create
            case .attachToGoal: return .attach
            case .archive: return .tombstone
            case .routeCommitment, .markWaiting: return .update
            }
        case let .goal(value): return value.action == .create ? .create : .update
        case let .schedule(value):
            if case .createItem = value.action { return .create }
            return .update
        case let .reminder(value):
            switch value.action {
            case .create: return .create
            case .delete: return .tombstone
            case .update: return .update
            }
        case let .importDeletion(value):
            switch value.action {
            case .deleteObject, .forgetMemory: return .tombstone
            case .prepareExport, .performExport: return .update
            }
        case let .attachment(value):
            if value.intent.action == .linkStaged { return .update }
            return .update
        case .step, .profile, .history, .repair, .externalOperation:
            return .update
        case let .compensation(value):
            return value.action.transition
        }
    }
}

private extension CanonicalRuntimeStore {
    static func validatePersistedReplay(
        _ outcome: RuntimeAtomicCommitFinalOutcome,
        database: isolated SQLiteDatabase
    ) throws {
        let receipt = outcome.receipt
        let facts = receipt.facts
        guard facts.lineage.eventSequence <= UInt64(Int64.max) else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let sequence = Int64(facts.lineage.eventSequence)
        let sourceGraph: RuntimeAuthenticatedReceiptGraph
        do {
            sourceGraph = try RuntimeCommittedReceiptAuthority.authenticatePersistedCore(
                receipt,
                database: database
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let terminal = sourceGraph.eventEvidence.terminal
        let commandEventRows = try database.query(
            """
            SELECT sequence, event_id, event_hash FROM runtime_semantic_events
            WHERE command_id = ? LIMIT 2
            """,
            bindings: [.text(facts.commandID.rawValue)],
            maximumDecodedBytes: 8_192
        )
        guard commandEventRows.count == 1,
              commandEventRows[0].value(named: "sequence") == .integer(sequence),
              commandEventRows[0].value(named: "event_id") == .text(facts.lineage.eventID.rawValue),
              commandEventRows[0].value(named: "event_hash") == .text(facts.lineage.eventHash),
              terminal.lineage.eventHash.hexadecimal == facts.lineage.eventHash,
              terminal.lineage.correlationID == facts.correlationID,
              terminal.event.mutation.aggregateTransitions.count == facts.objects.count else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        for link in facts.objects {
            guard let sourceTransition = terminal.event.mutation.aggregateTransitions.first(where: {
                $0.aggregate == link.aggregate
            }), sourceTransition.priorRevision == link.priorRevision,
                  sourceTransition.resultingRevision == link.terminalRevision,
                  sourceTransition.lifecycle == link.lifecycle,
                  sourceTransition.transition == link.transition,
                  sourceTransition.canonicalStateDigest == link.stateDigest else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            let rows = try database.query(
                "SELECT revision, payload, payload_checksum FROM runtime_aggregates WHERE aggregate_kind = ? AND aggregate_id = ? LIMIT 2",
                bindings: [.text(link.aggregate.kind.rawValue), .text(link.aggregate.id.rawValue)],
                maximumDecodedBytes: RuntimeCommittedReceiptReadBounds.maximumSelectedPayloadRowBytes
            )
            guard rows.count == 1, let row = rows.first,
                  case let .blob(bytes)? = row.value(named: "payload"),
                  case let .integer(currentRevision)? = row.value(named: "revision"),
                  currentRevision >= 0,
                  UInt64(currentRevision) >= link.terminalRevision else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            try requireArtifactChecksum(row, bytes: bytes)
            let current = try RuntimeAtomicCommitCoding.decodeAggregateState(bytes)
            guard current.aggregate == link.aggregate,
                  current.revision == UInt64(currentRevision) else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            if current.revision == link.terminalRevision {
                guard bytes == sourceTransition.canonicalStateBytes,
                      LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == link.stateDigest else {
                    throw RuntimeAtomicCommitError.corruptAuthority
                }
            } else {
                do {
                    try requireAdvancedStateAuthority(
                        current,
                        canonicalBytes: bytes,
                        afterHistoricalSequence: facts.lineage.eventSequence,
                        database: database
                    )
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    throw RuntimeAtomicCommitError.corruptAuthority
                }
            }
        }

        let expectedInvalidations = facts.artifacts
            .filter { $0.kind == .projectionInvalidation }
            .map(\.stableID).sorted()
        guard expectedInvalidations.count <= RuntimeCommittedReceiptLimits.maximumProjectionInvalidations else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let invalidationRows = try database.query(
            "SELECT invalidation_id, payload, payload_checksum FROM runtime_commit_projection_invalidations WHERE terminal_event_sequence = ? ORDER BY invalidation_id LIMIT ?",
            bindings: [
                .integer(sequence),
                .integer(Int64(expectedInvalidations.count + 1)),
            ]
        )
        guard invalidationRows.compactMap({ row in
            guard case let .text(value)? = row.value(named: "invalidation_id") else { return nil }
            return value
        }) == expectedInvalidations else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        for row in invalidationRows {
            try Task.checkCancellation()
            guard case let .blob(bytes)? = row.value(named: "payload"),
                  try RuntimeAtomicCommitCoding.decodeCanonical(
                    RuntimeAuthorityLineageReference.self,
                    from: bytes
                  ) == facts.lineage else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            try requireArtifactChecksum(row, bytes: bytes)
        }

        guard outcome.externalOperationCreations.count <=
                RuntimeExternalOperationLimits.maximumOperationsPerReceipt else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        var externalBudget = RuntimeExternalOperationDecodedByteBudget(
            maximumBytes: RuntimeExternalOperationLimits.maximumReceiptGraphBytes + 8_192
        )
        let authenticatedExternalOperations = try RuntimeExternalOperationGraphAuthority
            .loadAuthenticatedForReceipt(
                receiptID: facts.receiptID,
                budget: &externalBudget,
                database: database
            )
        guard authenticatedExternalOperations.count == outcome.externalOperationCreations.count else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        for (graph, expected) in zip(
            authenticatedExternalOperations,
            outcome.externalOperationCreations
        ) {
            try Task.checkCancellation()
            guard graph.creation.operationID == expected.operationID,
                  graph.creation.kind == expected.kind,
                  graph.creation.receiptID == expected.receiptID,
                  graph.creation.lineage == expected.lineage,
                  try RuntimeExternalOperationCodec.creationDigest(graph.creation) ==
                    expected.creationDigest else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
        }

    }

    static func requireArtifactChecksum(_ row: SQLiteRow, bytes: Data) throws {
        guard case let .text(checksum)? = row.value(named: "payload_checksum"),
              RuntimeStoreManifestCodec.isSHA256Hex(checksum),
              LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == checksum else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
    }

    static func requireAdvancedStateAuthority(
        _ state: RuntimeCanonicalAggregateState,
        canonicalBytes: Data,
        afterHistoricalSequence: UInt64,
        database: isolated SQLiteDatabase
    ) throws {
        try Task.checkCancellation()
        let highWaterRows = try database.query(
            """
            SELECT terminal_event_sequence FROM runtime_object_history
            WHERE family = ? AND object_id = ?
            ORDER BY terminal_event_sequence DESC LIMIT 1
            """,
            bindings: [
                .text(state.aggregate.kind.rawValue),
                .text(state.aggregate.id.rawValue),
            ],
            maximumDecodedBytes: 4_096
        )
        guard highWaterRows.count == 1,
              case let .integer(rawSequence)? = highWaterRows[0].value(named: "terminal_event_sequence"),
              rawSequence > 0,
              UInt64(rawSequence) > afterHistoricalSequence,
              state.revision > 0 else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let authorityRows = try database.query(
            """
            SELECT receipt_id, resulting_revision, state_digest
            FROM runtime_object_history
            WHERE family = ? AND object_id = ? AND terminal_event_sequence = ? LIMIT 2
            """,
            bindings: [
                .text(state.aggregate.kind.rawValue),
                .text(state.aggregate.id.rawValue),
                .integer(rawSequence),
            ],
            maximumDecodedBytes: 8_192
        )
        guard authorityRows.count == 1,
              let authorityRow = authorityRows.first,
              case let .text(rawReceiptID)? = authorityRow.value(named: "receipt_id"),
              let receiptID = RuntimeReceiptID(rawValue: rawReceiptID),
              authorityRow.value(named: "resulting_revision") == .integer(Int64(state.revision)),
              case let .text(stateDigest)? = authorityRow.value(named: "state_digest"),
              stateDigest == LocalRuntimeStorageChecksum.sha256Hex(for: canonicalBytes) else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        var budget = RuntimeReceiptDecodedByteBudget(
            maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes
        )
        let latestCore = try RuntimeCommittedReceiptAuthority.loadCore(
            receiptID: receiptID,
            budget: &budget,
            database: database
        )
        let graph = try RuntimeCommittedReceiptAuthority.authenticatePersistedCore(
            latestCore,
            budget: &budget,
            database: database
        )
        guard latestCore.facts.lineage.eventSequence == UInt64(rawSequence),
              let history = graph.history.first(where: { $0.object.aggregate == state.aggregate }),
              history.object.terminalRevision == state.revision,
              history.object.stateDigest == stateDigest,
              let storedTransition = graph.eventEvidence.terminal.event.mutation.aggregateTransitions.first(
                  where: { $0.aggregate == state.aggregate }
              ),
              storedTransition.resultingRevision == state.revision,
              storedTransition.canonicalStateDigest == stateDigest,
              storedTransition.canonicalStateBytes == canonicalBytes,
              try RuntimeCanonicalAggregateStateCodec().decode(canonicalBytes) == state,
              try RuntimeCanonicalAggregateStateCodec().encode(state) == canonicalBytes else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
    }

    static func persistInvalidations(
        _ projectionIDs: [RuntimeCanonicalProjectionID],
        lineage: RuntimeAuthorityLineageReference,
        createdAt: Int64,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeAuthorityUnresolvedWorkReference] {
        try projectionIDs.sorted().map { projectionID in
            let stableID = "invalidation.\(lineage.eventSequence).\(projectionID.rawValue)"
            let payload = try RuntimeAtomicCommitCoding.encode(lineage)
            try database.execute(
                """
                INSERT INTO runtime_commit_projection_invalidations(
                    invalidation_id, projection_id, terminal_event_sequence,
                    invalidation_version, payload, payload_checksum, created_at_ms
                ) VALUES (?, ?, ?, 1, ?, ?, ?)
                """,
                bindings: [
                    .text(stableID), .text(projectionID.rawValue), .integer(Int64(lineage.eventSequence)),
                    .blob(payload), .text(LocalRuntimeStorageChecksum.sha256Hex(for: payload)),
                    .integer(createdAt),
                ]
            )
            return RuntimeAuthorityUnresolvedWorkReference(
                kind: .projectionInvalidation,
                stableID: stableID,
                lineage: lineage
            )
        }
    }

    static func persistReceipt(
        _ receipt: RuntimeAtomicCommitReceipt,
        createdAt: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        try database.execute(
            """
            INSERT INTO runtime_commit_receipts(
                receipt_id, preparation_id, command_id, terminal_event_sequence,
                receipt_version, created_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(receipt.receiptID.rawValue), .text(receipt.preparationID.rawValue),
                .text(receipt.commandID.rawValue), .integer(Int64(receipt.lineage.eventSequence)),
                .integer(Int64(runtimeCommitAnchorVersion)), .integer(createdAt),
            ]
        )
    }

    static func persistTombstones(
        _ tombstones: [RuntimeCanonicalTombstoneDraft],
        createdAt: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        for tombstone in tombstones {
            let bytes = try RuntimeAtomicCommitCoding.encode(tombstone)
            try database.execute(
                """
                INSERT INTO runtime_commit_tombstones(
                    object_id, family, terminal_revision, terminal_event_sequence,
                    tombstone_version, payload, payload_checksum, created_at_ms
                ) VALUES (?, ?, ?, ?, 1, ?, ?, ?)
                """,
                bindings: [
                    .text(tombstone.objectID.rawValue), .text(tombstone.family),
                    .integer(Int64(tombstone.terminalRevision)),
                    .integer(Int64(tombstone.lineage.eventSequence)), .blob(bytes),
                    .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes)), .integer(createdAt),
                ]
            )
        }
    }

    static func consumeConfirmation(
        _ confirmation: RuntimeMutationConfirmation,
        receiptID: RuntimeReceiptID,
        preparation: RuntimePreparation,
        lineage: RuntimeAuthorityLineageReference,
        consumedAt: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        let result = try database.execute(
            """
            INSERT INTO runtime_confirmation_consumptions(
                token, receipt_id, preparation_id, command_id, decision_digest,
                terminal_event_sequence, consumed_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(confirmation.token.rawValue), .text(receiptID.rawValue),
                .text(preparation.preparationID.rawValue),
                .text(preparation.commandID.rawValue), .text(preparation.decisionDigest.rawValue),
                .integer(Int64(lineage.eventSequence)), .integer(consumedAt),
            ]
        )
        guard result.changedRowCount == 1 else { throw RuntimeAtomicCommitError.confirmationConsumed }
    }
}

struct RuntimeAtomicSemanticTransitionInput {
    let state: RuntimeCanonicalAggregateState
    let priorRevision: UInt64?
    let predecessorStateDigest: String?
}

enum RuntimeAtomicSemanticEventFactory {
    static func make(
        command: RuntimeCommandPayload,
        commandPrivacy: EventLedgerPrivacyClassification,
        commandLocalOnly: Bool,
        primaryAggregate: RuntimeSemanticAggregate,
        primaryPriorRevision: UInt64?,
        primaryResultingRevision: UInt64,
        changedObjectIDs: [RuntimeDomainObjectID],
        transitionInputs: [RuntimeAtomicSemanticTransitionInput]
    ) throws -> RuntimeSemanticEvent {
        guard case let .mutating(typeID) = RuntimeSemanticEventClassifier.classify(command) else {
            throw RuntimeAtomicCommitError.malformedPreparation
        }
        guard primaryAggregate.kind == typeID.aggregateKind,
              transitionInputs.contains(where: {
                  $0.state.aggregate == primaryAggregate &&
                      $0.priorRevision == primaryPriorRevision &&
                      $0.state.revision == primaryResultingRevision
              }) else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let aggregateTransitions = try transitionInputs.map { input in
            let aggregateState = input.state
            guard aggregateState.privacy == commandPrivacy,
                  aggregateState.localOnly == commandLocalOnly else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            let bytes = try RuntimeCanonicalAggregateStateCodec().encode(aggregateState)
            let tombstone: RuntimeCanonicalTombstoneAuthority?
            if aggregateState.lifecycle == .tombstoned {
                guard aggregateState.transition == .tombstone,
                      let predecessorStateDigest = input.predecessorStateDigest,
                      RuntimeStoreManifestCodec.isSHA256Hex(predecessorStateDigest) else {
                    throw RuntimeAtomicCommitError.corruptAuthority
                }
                tombstone = RuntimeCanonicalTombstoneAuthority(
                    reason: try tombstoneReason(for: typeID),
                    predecessorDigest: predecessorStateDigest,
                    retentionDisposition: .retainedUntilDownstreamPolicy,
                    recoveryDisposition: .explicitTypedRestorationRequired
                )
            } else {
                tombstone = nil
            }
            return RuntimeSemanticAggregateTransition(
                aggregate: aggregateState.aggregate,
                priorRevision: input.priorRevision,
                resultingRevision: aggregateState.revision,
                lifecycle: aggregateState.lifecycle,
                transition: aggregateState.transition,
                canonicalStateBytes: bytes,
                canonicalStateDigest: LocalRuntimeStorageChecksum.sha256Hex(for: bytes),
                privacy: commandPrivacy,
                localOnly: commandLocalOnly,
                tombstone: tombstone
            )
        }.sorted {
            ($0.aggregate.kind.rawValue, $0.aggregate.id.rawValue) <
                ($1.aggregate.kind.rawValue, $1.aggregate.id.rawValue)
        }
        guard Set(aggregateTransitions.map(\.aggregate)).count == aggregateTransitions.count else {
                throw RuntimeAtomicCommitError.corruptAuthority
        }
        let mutation = try RuntimeSemanticMutation(
            semanticType: typeID,
            aggregateID: primaryAggregate.id,
            priorRevision: primaryPriorRevision,
            resultingRevision: primaryResultingRevision,
            changedObjectIDs: changedObjectIDs,
            privacy: commandPrivacy,
            localOnly: commandLocalOnly,
            primaryAggregate: primaryAggregate,
            aggregateTransitions: aggregateTransitions
        )
        switch command {
        case let .capture(value):
            let payload = try RuntimeCaptureMutationPayload(mutation: mutation, facts: value)
            return .capture(switch value.action {
            case .quickCapture: .created(payload)
            case .routeCommitment: .commitmentRouted(payload)
            case .attachToGoal: .attachedToGoal(payload)
            case .markWaiting: .markedWaiting(payload)
            case .archive: .archived(payload)
            })
        case let .goal(value):
            let payload = try RuntimeGoalMutationPayload(mutation: mutation, facts: value)
            return .goal(switch value.action {
            case .create: .created(payload)
            case .update: .updated(payload)
            case .setPriority: .prioritySet(payload)
            case .setUrgency: .urgencySet(payload)
            case .setDeadline: .deadlineSet(payload)
            case .setContextLens: .contextLensSet(payload)
            case .clearContextLens: .contextLensCleared(payload)
            case .addDeliverable: .deliverableAdded(payload)
            case .removeDeliverable: .deliverableRemoved(payload)
            case .addScopeItem: .scopeItemAdded(payload)
            case .removeScopeItem: .scopeItemRemoved(payload)
            })
        case let .step(value):
            let payload = try RuntimeStepMutationPayload(mutation: mutation, facts: value)
            return .step(switch value.action {
            case .startSession: .sessionStarted(payload)
            case .complete: .completed(payload)
            case .delay: .delayed(payload)
            case .split: .split(payload)
            case .recover: .recovered(payload)
            case .todayGoalStep: .todayActionApplied(payload)
            })
        case let .schedule(value):
            let payload = try RuntimeScheduleMutationPayload(mutation: mutation, facts: value)
            return .schedule(switch value.action {
            case .createItem: .itemCreated(payload)
            case .schedule: .itemScheduled(payload)
            case .placeStep: .stepPlaced(payload)
            case .protectWindow: .windowProtected(payload)
            case .correctWindow: .windowCorrected(payload)
            case .undo: .mutationUndone(payload)
            case .ritual: .ritualApplied(payload)
            case .calendarWrite: .calendarWriteCommitted(payload)
            })
        case let .reminder(value):
            let payload = try RuntimeReminderMutationPayload(mutation: mutation, facts: value)
            return .reminder(switch value.action {
            case .create: .created(payload)
            case .update: .updated(payload)
            case .delete: .deleted(payload)
            })
        case let .profile(value):
            return .profile(.preferencesUpdated(try RuntimeProfileMutationPayload(mutation: mutation, facts: value)))
        case let .history(value):
            let payload = try RuntimeHistoryMutationPayload(mutation: mutation, facts: value)
            switch value.action {
            case .dismissRecommendation: return .history(.recommendationDismissed(payload))
            case .todayReceipt: return .history(.todayReceiptRecorded(payload))
            case .openDestination, .askWhy: throw RuntimeAtomicCommitError.malformedPreparation
            }
        case let .repair(value):
            guard value.action == .recover else { throw RuntimeAtomicCommitError.malformedPreparation }
            return .repair(.recovered(try RuntimeRepairMutationPayload(mutation: mutation, facts: value)))
        case let .importDeletion(value):
            let payload = try RuntimeImportDeletionMutationPayload(mutation: mutation, facts: value)
            switch value.action {
            case .deleteObject: return .importDeletion(.objectDeleted(payload))
            case .forgetMemory: return .importDeletion(.memoryForgotten(payload))
            case .prepareExport, .performExport: throw RuntimeAtomicCommitError.malformedPreparation
            }
        case let .externalOperation(value):
            let payload = try RuntimeExternalOperationMutationPayload(mutation: mutation, facts: value)
            return .externalOperation(value.kind == .reminder ? .reminderRequested(payload) : .calendarEventRequested(payload))
        case let .attachment(value):
            let payload = try RuntimeAttachmentMutationPayload(mutation: mutation, facts: value)
            return .attachment(switch value.intent.action {
            case .linkStaged: .linked(payload)
            case .unlink: .unlinked(payload)
            case .replaceRevision: .revisionReplaced(payload)
            case .authorizeDeletion: .deletionAuthorized(payload)
            case .quarantine: .quarantined(payload)
            })
        case let .compensation(value):
            return .compensation(.applied(try RuntimeCompensationMutationPayload(
                mutation: mutation,
                facts: value
            )))
        }
    }

    private static func tombstoneReason(
        for typeID: RuntimeSemanticEventTypeID
    ) throws -> RuntimeCanonicalTombstoneReason {
        switch typeID {
        case .captureArchived:
            return .archived
        case .reminderDeleted:
            return .reminderDeleted
        case .objectDeleted:
            return .objectDeleted
        case .memoryForgotten:
            return .memoryForgotten
        case .captureCreatedCompensated, .goalCreatedCompensated,
             .scheduleCreatedCompensated, .reminderCreatedCompensated:
            return .compensatedCreation
        default:
            throw RuntimeAtomicCommitError.malformedPreparation
        }
    }
}
