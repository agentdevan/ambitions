import AmbitionsRuntimeSQLite
import Foundation

let runtimeAtomicCommitSchemaVersion = 3
let runtimeAtomicCommitReceiptVersion = 1

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

enum RuntimeAuthorityUndoabilityReason: String, Codable, Sendable, Equatable, Hashable {
    case missingTypedCompensationContract = "missing_typed_compensation_contract"
}

enum RuntimeAuthorityUndoability: Codable, Sendable, Equatable, Hashable {
    case typedPlan(RuntimeRollbackPlanID)
    case notUndoable(reason: RuntimeAuthorityUndoabilityReason)
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
    let receipt: RuntimeAtomicCommitReceipt
    let pendingExternalOperations: [RuntimeCanonicalPendingExternalOperation]
}

enum RuntimeAtomicCommitPhase: Int, Codable, Sendable, Equatable, CaseIterable {
    case claimed, snapshotsLoaded, reduced, aggregatesApplied, eventAppended
    case invalidationsPersisted, receiptPersisted, externalOperationsPersisted
    case idempotencyFinalized, confirmationConsumed
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
    static let currentWritableSchemaVersion = runtimeCanonicalProjectionSchemaVersion
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
            receipt_version INTEGER NOT NULL CHECK (receipt_version > 0),
            payload BLOB NOT NULL,
            payload_checksum TEXT NOT NULL CHECK (length(payload_checksum) = 64 AND payload_checksum NOT GLOB '*[^0-9a-f]*'),
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
            preparation_id TEXT NOT NULL,
            command_id TEXT NOT NULL,
            decision_digest TEXT NOT NULL CHECK (length(decision_digest) = 64 AND decision_digest NOT GLOB '*[^0-9a-f]*'),
            terminal_event_sequence INTEGER NOT NULL CHECK (terminal_event_sequence > 0),
            consumed_at_ms INTEGER NOT NULL CHECK (consumed_at_ms >= 0),
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
        if version == Int64(runtimeCanonicalProjectionSchemaVersion) {
            expectedTables.formUnion(CanonicalRuntimeProjectionSchemaPlan.tables)
            expectedIndexes.formUnion(CanonicalRuntimeProjectionSchemaPlan.indexes)
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

    static func atomicCommitInTransaction(
        preparation: RuntimePreparation,
        confirmation: RuntimeMutationConfirmation?,
        submittedAt: Date,
        failAfterPhase: RuntimeAtomicCommitPhase? = nil,
        cancelAfterPhase: RuntimeAtomicCommitPhase? = nil,
        semanticEventBytesOverride: Data? = nil,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAtomicCommitFinalOutcome {
            try CanonicalRuntimeCommitSchemaPlan.requireIntegratedSchema(in: database)
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
            let correlationID = try RuntimeCorrelationID(
                validating: "correlation.\(preparation.preparationID.rawValue)"
            )
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
                    causationEventID: nil,
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
                undoability: .notUndoable(reason: .missingTypedCompensationContract),
                confirmationToken: confirmation?.token,
                confirmationDecisionDigest: confirmation.map { _ in preparation.decisionDigest },
                committedAt: submittedAt
            )
            try Self.persistReceipt(receipt, createdAt: claimedAt, database: database)
            try Self.persistTombstones(tombstones, createdAt: claimedAt, database: database)
            try RuntimeAtomicCommitFault.check(.receiptPersisted, failure: failAfterPhase, cancellation: cancelAfterPhase)
            let pending = try Self.persistPendingExternalOperation(
                plan.externalEffect,
                receipt: receipt,
                createdAt: claimedAt,
                database: database
            )
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
                receipt: receipt,
                pendingExternalOperations: pending
            )
            let finalBytes = try RuntimeAtomicCommitCoding.encode(finalOutcome)
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
            if let confirmation {
                try Self.consumeConfirmation(
                    confirmation,
                    preparation: preparation,
                    lineage: lineage,
                    consumedAt: claimedAt,
                    database: database
                )
            }
            try RuntimeAtomicCommitFault.check(.confirmationConsumed, failure: failAfterPhase, cancellation: cancelAfterPhase)
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

private enum RuntimeAtomicCommitCoding {
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
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let value: RuntimeAtomicCommitFinalOutcome
        do {
            value = try decoder.decode(RuntimeAtomicCommitFinalOutcome.self, from: bytes)
        } catch {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        guard try encode(value) == bytes else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let stateCodec = RuntimeCanonicalAggregateStateCodec()
        for state in value.receipt.aggregateStates {
            guard try stateCodec.decode(stateCodec.encode(state)) == state else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
        }
        try validateFinalOutcome(value)
        return value
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
        let lineage = receipt.lineage
        let committedAt = receipt.committedAt.timeIntervalSince1970
        guard RuntimePreparationID(rawValue: receipt.preparationID.rawValue)?.rawValue == receipt.preparationID.rawValue,
              RuntimeCommandID(rawValue: receipt.commandID.rawValue)?.rawValue == receipt.commandID.rawValue,
              RuntimeReceiptID(rawValue: receipt.receiptID.rawValue)?.rawValue == receipt.receiptID.rawValue,
              RuntimeEventID(rawValue: lineage.eventID.rawValue)?.rawValue == lineage.eventID.rawValue,
              receipt.confirmationToken.map({
                  RuntimeConfirmationToken(rawValue: $0.rawValue)?.rawValue == $0.rawValue
              }) ?? true,
              receipt.confirmationDecisionDigest.map({
                  RuntimeCommandFingerprint(rawValue: $0.rawValue)?.rawValue == $0.rawValue
              }) ?? true,
              (receipt.confirmationToken == nil) == (receipt.confirmationDecisionDigest == nil),
              value.committed.preparationID == receipt.preparationID,
              value.committed.commandID == receipt.commandID,
              value.committed.authorityReceiptID == receipt.receiptID,
              value.committed.projectionDegradation.isEmpty,
              lineage.eventSequence > 0,
              RuntimeStoreManifestCodec.isSHA256Hex(lineage.eventHash),
              committedAt.isFinite, committedAt >= 0,
              receipt.aggregateStates.isEmpty == false else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }

        let states = receipt.aggregateStates
        let sortedStates = states.sorted {
            ($0.aggregate.kind.rawValue, $0.aggregate.id.rawValue) <
                ($1.aggregate.kind.rawValue, $1.aggregate.id.rawValue)
        }
        let stateKeys = states.map { "\($0.aggregate.kind.rawValue)\u{0}\($0.aggregate.id.rawValue)" }
        guard states == sortedStates, Set(stateKeys).count == states.count,
              states.allSatisfy({ state in
                  RuntimeAggregateID(rawValue: state.aggregate.id.rawValue)?.rawValue == state.aggregate.id.rawValue &&
                    state.changedObjectIDs.allSatisfy({
                        RuntimeDomainObjectID(rawValue: $0.rawValue)?.rawValue == $0.rawValue
                    }) &&
                    state.changedObjectIDs == Array(Set(state.changedObjectIDs)).sorted()
              }),
              states.dropFirst().allSatisfy({ $0.commandPayload == states[0].commandPayload }),
              receipt.undoability == .notUndoable(reason: .missingTypedCompensationContract) else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let expectedLinks = states.map {
            RuntimeAuthorityObjectLink(
                aggregate: $0.aggregate,
                terminalRevision: $0.revision,
                lifecycle: $0.lifecycle
            )
        }.sorted {
            ($0.aggregate.kind.rawValue, $0.aggregate.id.rawValue) <
                ($1.aggregate.kind.rawValue, $1.aggregate.id.rawValue)
        }
        guard receipt.objectLinks == expectedLinks else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }

        let expectedTombstoneKeys = Set(states.filter { $0.lifecycle == .tombstoned }.map {
            "\($0.aggregate.kind.rawValue)\u{0}\($0.aggregate.id.rawValue)\u{0}\($0.revision)"
        })
        let tombstoneKeys = receipt.tombstones.map {
            "\($0.family)\u{0}\($0.objectID.rawValue)\u{0}\($0.terminalRevision)"
        }
        guard Set(tombstoneKeys) == expectedTombstoneKeys,
              receipt.tombstones.allSatisfy({ tombstone in
                  RuntimeDomainObjectID(rawValue: tombstone.objectID.rawValue)?.rawValue == tombstone.objectID.rawValue &&
                    tombstone.lineage.eventSequence <= lineage.eventSequence &&
                    RuntimeStoreManifestCodec.isSHA256Hex(tombstone.lineage.eventHash) &&
                    states.contains(where: { state in
                      state.aggregate.kind.rawValue == tombstone.family &&
                        state.aggregate.id.rawValue == tombstone.objectID.rawValue &&
                        state.revision == tombstone.terminalRevision &&
                        state.lifecycle == .tombstoned
                  })
              }) else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }

        let unresolvedKeys = receipt.unresolvedWork.map { "\($0.kind.rawValue)\u{0}\($0.stableID)" }
        let pendingIDs = value.pendingExternalOperations.map(\.operationID.rawValue)
        guard Set(unresolvedKeys).count == unresolvedKeys.count,
              Set(pendingIDs).count == pendingIDs.count,
              receipt.unresolvedWork.allSatisfy({
                  validStableIdentity($0.stableID) && $0.lineage == lineage
              }),
              value.pendingExternalOperations.allSatisfy({ pending in
                  RuntimeExternalOperationID(rawValue: pending.operationID.rawValue)?.rawValue == pending.operationID.rawValue &&
                    pending.status == "pending" && pending.lineage == lineage &&
                    receipt.unresolvedWork.contains(where: {
                        $0.kind == .externalOperation && $0.stableID == pending.operationID.rawValue
                    })
              }),
              receipt.unresolvedWork.filter({ $0.kind == .externalOperation }).count == pendingIDs.count else {
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
                 (.attach, .exact), (.detach, .exact), (.tombstone, .exact):
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
        if semanticType.isCreation != (priorRevision == nil) {
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

    func requireReducerReplay() throws {
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
              }),
              let rollbackID = preparation.decision.writeSet.rollbackIntentID else {
            throw RuntimeAtomicCommitError.stalePreparation
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
        } catch {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        guard state.aggregate.kind.rawValue == key.kind,
              state.aggregate.id.rawValue == key.id,
              state.revision == UInt64(revision),
              state.lifecycle == .active,
              state.transition != .tombstone,
              transition != .restore else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        guard state.revision == expectedRevision else {
            throw RuntimeAtomicCommitError.stalePreparation
        }
        let durableTombstone = try database.query(
            "SELECT terminal_revision FROM runtime_commit_tombstones WHERE family = ? AND object_id = ? LIMIT 2",
            bindings: [.text(key.kind), .text(key.id)]
        )
        guard durableTombstone.isEmpty else {
            throw RuntimeAtomicCommitError.corruptAuthority
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
        case .step, .profile, .history, .repair, .externalOperation:
            return .update
        }
    }
}

private extension CanonicalRuntimeStore {
    static func validatePersistedReplay(
        _ outcome: RuntimeAtomicCommitFinalOutcome,
        database: isolated SQLiteDatabase
    ) throws {
        let receipt = outcome.receipt
        let sequence = Int64(receipt.lineage.eventSequence)
        let semanticEventRecords = try verifiedSemanticEventRecords(database: database)
        try requirePersistedCommandEventChain(
            receipt,
            records: semanticEventRecords
        )

        for state in receipt.aggregateStates {
            let rows = try database.query(
                "SELECT revision, payload, payload_checksum FROM runtime_aggregates WHERE aggregate_kind = ? AND aggregate_id = ? LIMIT 2",
                bindings: [.text(state.aggregate.kind.rawValue), .text(state.aggregate.id.rawValue)]
            )
            guard rows.count == 1, let row = rows.first,
                  case let .blob(bytes)? = row.value(named: "payload"),
                  case let .integer(currentRevision)? = row.value(named: "revision"),
                  currentRevision >= 0,
                  UInt64(currentRevision) >= state.revision else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            try requireArtifactChecksum(row, bytes: bytes)
            let current = try RuntimeAtomicCommitCoding.decodeAggregateState(bytes)
            guard current.aggregate == state.aggregate,
                  current.revision == UInt64(currentRevision) else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            if current.revision == state.revision {
                guard current == state else {
                    throw RuntimeAtomicCommitError.corruptAuthority
                }
            } else {
                try requireAdvancedStateAuthority(
                    current,
                    canonicalBytes: bytes,
                    afterHistoricalSequence: receipt.lineage.eventSequence,
                    records: semanticEventRecords
                )
            }
        }

        let receiptRows = try database.query(
            "SELECT preparation_id, command_id, terminal_event_sequence, payload, payload_checksum FROM runtime_commit_receipts WHERE receipt_id = ? LIMIT 2",
            bindings: [.text(receipt.receiptID.rawValue)]
        )
        guard receiptRows.count == 1, let receiptRow = receiptRows.first,
              receiptRow.value(named: "preparation_id") == .text(receipt.preparationID.rawValue),
              receiptRow.value(named: "command_id") == .text(receipt.commandID.rawValue),
              receiptRow.value(named: "terminal_event_sequence") == .integer(sequence),
              case let .blob(receiptBytes)? = receiptRow.value(named: "payload"),
              try RuntimeAtomicCommitCoding.decodeCanonical(
                RuntimeAtomicCommitReceipt.self,
                from: receiptBytes
              ) == receipt else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        try requireArtifactChecksum(receiptRow, bytes: receiptBytes)

        let invalidationRows = try database.query(
            "SELECT invalidation_id, payload, payload_checksum FROM runtime_commit_projection_invalidations WHERE terminal_event_sequence = ? ORDER BY invalidation_id",
            bindings: [.integer(sequence)]
        )
        let expectedInvalidations = receipt.unresolvedWork
            .filter { $0.kind == .projectionInvalidation }
            .map(\.stableID).sorted()
        guard invalidationRows.compactMap({ row in
            guard case let .text(value)? = row.value(named: "invalidation_id") else { return nil }
            return value
        }) == expectedInvalidations else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        for row in invalidationRows {
            guard case let .blob(bytes)? = row.value(named: "payload"),
                  try RuntimeAtomicCommitCoding.decodeCanonical(
                    RuntimeAuthorityLineageReference.self,
                    from: bytes
                  ) == receipt.lineage else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            try requireArtifactChecksum(row, bytes: bytes)
        }

        let operationRows = try database.query(
            "SELECT operation_id, payload, payload_checksum FROM runtime_pending_external_operations WHERE receipt_id = ? ORDER BY operation_id",
            bindings: [.text(receipt.receiptID.rawValue)]
        )
        guard operationRows.count == outcome.pendingExternalOperations.count else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        for (row, expected) in zip(operationRows, outcome.pendingExternalOperations.sorted(by: {
            $0.operationID < $1.operationID
        })) {
            guard row.value(named: "operation_id") == .text(expected.operationID.rawValue),
                  case let .blob(bytes)? = row.value(named: "payload"),
                  try RuntimeAtomicCommitCoding.decodeCanonical(
                    RuntimeCanonicalPendingExternalOperation.self,
                    from: bytes
                  ) == expected else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            try requireArtifactChecksum(row, bytes: bytes)
        }

        let tombstoneRows = try database.query(
            "SELECT object_id, family, payload, payload_checksum FROM runtime_commit_tombstones WHERE terminal_event_sequence = ? ORDER BY family, object_id",
            bindings: [.integer(sequence)]
        )
        guard tombstoneRows.count == receipt.tombstones.count else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        for (row, expected) in zip(tombstoneRows, receipt.tombstones) {
            guard row.value(named: "object_id") == .text(expected.objectID.rawValue),
                  row.value(named: "family") == .text(expected.family),
                  case let .blob(bytes)? = row.value(named: "payload"),
                  try RuntimeAtomicCommitCoding.decodeCanonical(
                    RuntimeCanonicalTombstoneDraft.self,
                    from: bytes
                  ) == expected else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
            try requireArtifactChecksum(row, bytes: bytes)
        }

        let confirmationRows = try database.query(
            "SELECT token, preparation_id, command_id, decision_digest, terminal_event_sequence FROM runtime_confirmation_consumptions WHERE terminal_event_sequence = ?",
            bindings: [.integer(sequence)]
        )
        if let token = receipt.confirmationToken,
           let decisionDigest = receipt.confirmationDecisionDigest {
            guard confirmationRows.count == 1, let row = confirmationRows.first,
                  row.value(named: "token") == .text(token.rawValue),
                  row.value(named: "preparation_id") == .text(receipt.preparationID.rawValue),
                  row.value(named: "command_id") == .text(receipt.commandID.rawValue),
                  row.value(named: "terminal_event_sequence") == .integer(sequence),
                  row.value(named: "decision_digest") == .text(decisionDigest.rawValue) else {
                throw RuntimeAtomicCommitError.corruptAuthority
            }
        } else if confirmationRows.isEmpty == false {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
    }

    static func requireArtifactChecksum(_ row: SQLiteRow, bytes: Data) throws {
        guard case let .text(checksum)? = row.value(named: "payload_checksum"),
              RuntimeStoreManifestCodec.isSHA256Hex(checksum),
              LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == checksum else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
    }

    static func requirePersistedCommandEventChain(
        _ receipt: RuntimeAtomicCommitReceipt,
        records: [CanonicalRuntimeSemanticEventRecord]
    ) throws {
        let states = receipt.aggregateStates
        let commandRecords = records.filter { $0.lineage.commandID == receipt.commandID }
        guard commandRecords.count == 1,
              let terminal = commandRecords.first,
              terminal.lineage.eventID == receipt.lineage.eventID,
              terminal.lineage.sequence == receipt.lineage.eventSequence,
              terminal.lineage.eventHash.hexadecimal == receipt.lineage.eventHash else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }

        let transitionIntents = try states.map { state in
            RuntimeObjectTransitionIntent(
                aggregate: RuntimePreparationAggregateReference(
                    family: state.aggregate.kind,
                    objectID: try RuntimeDomainObjectID(validating: state.aggregate.id.rawValue)
                ),
                expectedRevision: state.revision == 0 ? .absent : .exact(state.revision - 1),
                transition: state.transition
            )
        }
        guard let command = states.first?.commandPayload else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let primaryID = try RuntimeAtomicAggregateIdentity.primaryID(
            command: command,
            transitions: transitionIntents
        )
        let primaryKind = command.runtimePrimaryPreparationReference?.family ?? terminal.event.typeID.aggregateKind
        guard let primary = states.first(where: {
            $0.aggregate.id == primaryID && $0.aggregate.kind == primaryKind
        }) else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let correlationID = try RuntimeCorrelationID(
            validating: "correlation.\(receipt.preparationID.rawValue)"
        )
        let inputs = try states.map { state in
            let stored = terminal.event.mutation.aggregateTransitions.first {
                $0.aggregate == state.aggregate
            }
            guard let stored else { throw RuntimeAtomicCommitError.corruptAuthority }
            return RuntimeAtomicSemanticTransitionInput(
                state: state,
                priorRevision: stored.priorRevision,
                predecessorStateDigest: stored.tombstone?.predecessorDigest
            )
        }
        guard let privacy = primary.privacy, let localOnly = primary.localOnly else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        let expectedEvent = try RuntimeAtomicSemanticEventFactory.make(
            command: command,
            commandPrivacy: privacy,
            commandLocalOnly: localOnly,
            primaryAggregate: primary.aggregate,
            primaryPriorRevision: terminal.event.mutation.priorRevision,
            primaryResultingRevision: primary.revision,
            changedObjectIDs: primary.changedObjectIDs,
            transitionInputs: inputs
        )
        guard terminal.lineage.aggregate == primary.aggregate,
              terminal.lineage.canonicalAggregateRevision == primary.revision,
              terminal.lineage.correlationID == correlationID,
              terminal.lineage.causationEventID == nil,
              terminal.event == expectedEvent else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
    }

    static func requireAdvancedStateAuthority(
        _ state: RuntimeCanonicalAggregateState,
        canonicalBytes: Data,
        afterHistoricalSequence: UInt64,
        records: [CanonicalRuntimeSemanticEventRecord]
    ) throws {
        let aggregateRecords = records.filter { record in
            record.event.mutation.aggregateTransitions.contains { $0.aggregate == state.aggregate }
        }
        guard let latest = aggregateRecords.max(by: {
            $0.lineage.sequence < $1.lineage.sequence
        }),
              latest.lineage.sequence > afterHistoricalSequence,
              state.revision > 0 else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
        guard let storedTransition = latest.event.mutation.aggregateTransitions.first(where: {
            $0.aggregate == state.aggregate
        }) else { throw RuntimeAtomicCommitError.corruptAuthority }
        let storedState = try RuntimeCanonicalAggregateStateCodec().decode(
            storedTransition.canonicalStateBytes
        )
        guard storedState == state,
              storedState.aggregate == storedTransition.aggregate,
              storedState.revision == storedTransition.resultingRevision,
              storedState.lifecycle == storedTransition.lifecycle,
              storedState.transition == storedTransition.transition,
              storedTransition.resultingRevision == state.revision,
              storedTransition.canonicalStateBytes == canonicalBytes,
              try RuntimeCanonicalAggregateStateCodec().encode(storedState) == canonicalBytes else {
            throw RuntimeAtomicCommitError.corruptAuthority
        }
    }

    static func verifiedSemanticEventRecords(
        database: isolated SQLiteDatabase
    ) throws -> [CanonicalRuntimeSemanticEventRecord] {
        var cursor: RuntimeCanonicalReplayCursor?
        var records: [CanonicalRuntimeSemanticEventRecord] = []
        repeat {
            let page = try CanonicalRuntimeSemanticEventStore.readVerifiedInTransaction(
                from: database,
                after: cursor,
                initialAnchor: nil,
                limit: CanonicalRuntimeSemanticEventStore.maximumPageLimit
            )
            for inspection in page.items {
                guard case let .supported(record) = inspection else {
                    throw RuntimeAtomicCommitError.corruptAuthority
                }
                records.append(record)
            }
            cursor = page.nextCursor
        } while cursor != nil
        return records
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
        let bytes = try RuntimeAtomicCommitCoding.encode(receipt)
        try database.execute(
            """
            INSERT INTO runtime_commit_receipts(
                receipt_id, preparation_id, command_id, terminal_event_sequence,
                receipt_version, payload, payload_checksum, created_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(receipt.receiptID.rawValue), .text(receipt.preparationID.rawValue),
                .text(receipt.commandID.rawValue), .integer(Int64(receipt.lineage.eventSequence)),
                .integer(Int64(runtimeAtomicCommitReceiptVersion)), .blob(bytes),
                .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes)), .integer(createdAt),
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

    static func persistPendingExternalOperation(
        _ effect: RuntimeExternalEffectIntent,
        receipt: RuntimeAtomicCommitReceipt,
        createdAt: Int64,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeCanonicalPendingExternalOperation] {
        guard case let .outbox(operationID, kind) = effect else { return [] }
        let record = RuntimeCanonicalPendingExternalOperation(
            operationID: operationID,
            kind: kind,
            status: "pending",
            lineage: receipt.lineage
        )
        let bytes = try RuntimeAtomicCommitCoding.encode(record)
        try database.execute(
            """
            INSERT INTO runtime_pending_external_operations(
                operation_id, command_id, receipt_id, terminal_event_sequence,
                operation_kind, status, operation_version, payload,
                payload_checksum, attempt_count, updated_at_ms
            ) VALUES (?, ?, ?, ?, ?, 'pending', 1, ?, ?, 0, ?)
            """,
            bindings: [
                .text(operationID.rawValue), .text(receipt.commandID.rawValue),
                .text(receipt.receiptID.rawValue), .integer(Int64(receipt.lineage.eventSequence)),
                .text(kind.rawValue), .blob(bytes),
                .text(LocalRuntimeStorageChecksum.sha256Hex(for: bytes)), .integer(createdAt),
            ]
        )
        return [record]
    }

    static func consumeConfirmation(
        _ confirmation: RuntimeMutationConfirmation,
        preparation: RuntimePreparation,
        lineage: RuntimeAuthorityLineageReference,
        consumedAt: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        let result = try database.execute(
            """
            INSERT INTO runtime_confirmation_consumptions(
                token, preparation_id, command_id, decision_digest,
                terminal_event_sequence, consumed_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(confirmation.token.rawValue), .text(preparation.preparationID.rawValue),
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
        default:
            throw RuntimeAtomicCommitError.malformedPreparation
        }
    }
}
