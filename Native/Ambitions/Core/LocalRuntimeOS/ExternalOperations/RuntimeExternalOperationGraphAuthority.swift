import AmbitionsRuntimeSQLite
import Foundation

protocol RuntimeExternalOperationReadBudget {
    mutating func query(
        _ sql: String,
        bindings: [SQLiteBinding],
        database: isolated SQLiteDatabase
    ) throws -> [SQLiteRow]
}

struct RuntimeExternalOperationDecodedByteBudget: RuntimeExternalOperationReadBudget, Sendable {
    private(set) var remainingBytes: Int

    init(maximumBytes: Int = RuntimeExternalOperationLimits.maximumGraphBytesPerOperation) {
        remainingBytes = max(0, maximumBytes)
    }

    mutating func query(
        _ sql: String,
        bindings: [SQLiteBinding] = [],
        database: isolated SQLiteDatabase
    ) throws -> [SQLiteRow] {
        guard remainingBytes > 0 else { throw RuntimeCanonicalExternalOperationError.firstRowExceedsBound }
        let rows = try database.query(sql, bindings: bindings, maximumDecodedBytes: remainingBytes)
        let decoded = rows.reduce(0) { total, row in
            total + row.values.reduce(0) { subtotal, value in
                subtotal + switch value {
                case .null: 1
                case .integer, .real: 8
                case let .text(text): text.utf8.count
                case let .blob(bytes): bytes.count
                }
            }
        }
        guard decoded <= remainingBytes else {
            throw RuntimeCanonicalExternalOperationError.firstRowExceedsBound
        }
        remainingBytes -= decoded
        return rows
    }
}

enum RuntimeExternalOperationGraphAuthority {
    static func loadAuthenticatedForReceipt<Budget: RuntimeExternalOperationReadBudget>(
        receiptID: RuntimeReceiptID,
        budget: inout Budget,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeExternalOperationAuthorityGraph] {
        let rows = try budget.query(
            """
            SELECT operation_id FROM runtime_external_operation_creations
            WHERE receipt_id = ? ORDER BY operation_id LIMIT ?
            """,
            bindings: [
                .text(receiptID.rawValue),
                .integer(Int64(RuntimeExternalOperationLimits.maximumOperationsPerReceipt + 1)),
            ],
            database: database
        )
        guard rows.count <= RuntimeExternalOperationLimits.maximumOperationsPerReceipt else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        return try rows.map { row in
            try Task.checkCancellation()
            guard case let .text(rawID)? = row.value(named: "operation_id"),
                  let operationID = RuntimeExternalOperationID(rawValue: rawID),
                  let graph = try loadAuthenticated(
                      operationID: operationID, budget: &budget, database: database
                  ),
                  graph.creation.receiptID == receiptID else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
            return graph
        }
    }

    static func loadAuthenticated<Budget: RuntimeExternalOperationReadBudget>(
        operationID: RuntimeExternalOperationID,
        budget: inout Budget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeExternalOperationAuthorityGraph? {
        let rows = try budget.query(
            """
            SELECT operation_id, command_id, receipt_id, terminal_event_sequence,
                   operation_kind, operation_action, source_operation_id,
                   source_provider_reference, source_receipt_id,
                   compensation_plan_id, compensation_plan_digest,
                   provider_id, stable_idempotency_key, privacy,
                   local_only, policy_version, creation_version, creation_payload,
                   creation_digest, created_at_ms
            FROM runtime_external_operation_creations
            WHERE operation_id = ? LIMIT 2
            """,
            bindings: [.text(operationID.rawValue)],
            database: database
        )
        guard rows.count <= 1 else { throw RuntimeCanonicalExternalOperationError.corruptAuthority }
        guard let row = rows.first else { return nil }
        guard case let .blob(bytes)? = row.value(named: "creation_payload"),
              bytes.count <= RuntimeExternalOperationLimits.maximumPayloadBytes,
              case let .text(digest)? = row.value(named: "creation_digest"),
              RuntimeStoreManifestCodec.isSHA256Hex(digest),
              LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == digest else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        let creation = try RuntimeExternalOperationCodec.decodeCreation(bytes)
        guard creation.operationID == operationID,
              row.value(named: "operation_id") == .text(creation.operationID.rawValue),
              row.value(named: "command_id") == .text(creation.commandID.rawValue),
              row.value(named: "receipt_id") == .text(creation.receiptID.rawValue),
              row.value(named: "terminal_event_sequence") == .integer(try int64(creation.lineage.eventSequence)),
              row.value(named: "operation_kind") == .text(creation.kind.rawValue),
              row.value(named: "operation_action") == .text(creation.payload.action.rawValue),
              row.value(named: "source_operation_id") == textValue(creation.payload.sourceOperationID?.rawValue),
              row.value(named: "source_provider_reference") == textValue(creation.payload.sourceProviderReference?.rawValue),
              row.value(named: "source_receipt_id") == textValue(creation.payload.sourceReceiptID?.rawValue),
              row.value(named: "compensation_plan_id") == textValue(creation.payload.compensationPlanID?.rawValue),
              row.value(named: "compensation_plan_digest") == textValue(creation.payload.compensationPlanDigest),
              row.value(named: "provider_id") == .text(creation.providerID.rawValue),
              row.value(named: "stable_idempotency_key") == .text(creation.stableIdempotencyKey.rawValue),
              row.value(named: "privacy") == .text(creation.privacy.rawValue),
              row.value(named: "local_only") == .integer(1),
              row.value(named: "policy_version") == .integer(Int64(creation.policyVersion)),
              row.value(named: "creation_version") == .integer(Int64(creation.version)),
              row.value(named: "created_at_ms") == .integer(try milliseconds(creation.createdAt)) else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        if creation.payload.action == .compensateRemoval {
            guard let sourceID = creation.payload.sourceOperationID,
                  let sourceReference = creation.payload.sourceProviderReference,
                  let sourceReceiptID = creation.payload.sourceReceiptID,
                  let planID = creation.payload.compensationPlanID,
                  let planDigest = creation.payload.compensationPlanDigest else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
            let relationRows = try budget.query(
                """
                SELECT 1 FROM runtime_external_operation_creations AS source
                JOIN runtime_external_operation_current AS current ON current.operation_id = source.operation_id
                JOIN runtime_compensation_plans AS plan ON plan.plan_id = ?
                JOIN runtime_compensation_plan_external_operations AS planned
                  ON planned.plan_id = plan.plan_id AND planned.operation_id = source.operation_id
                WHERE source.operation_id = ? AND source.receipt_id = ?
                  AND source.operation_kind = ? AND source.provider_id = ?
                  AND source.privacy = ? AND source.local_only = 1
                  AND current.workflow_status = 'succeeded'
                  AND current.effect_disposition = 'confirmed_present'
                  AND current.external_reference = ?
                  AND plan.source_receipt_id = ? AND plan.plan_digest = ?
                  AND plan.expires_at_ms >= ? LIMIT 2
                """,
                bindings: [
                    .text(planID.rawValue), .text(sourceID.rawValue),
                    .text(sourceReceiptID.rawValue), .text(creation.kind.rawValue),
                    .text(creation.providerID.rawValue), .text(creation.privacy.rawValue),
                    .text(sourceReference.rawValue), .text(sourceReceiptID.rawValue),
                    .text(planDigest), .integer(try milliseconds(creation.createdAt)),
                ],
                database: database
            )
            guard relationRows.count == 1 else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
        }
        let targets = try loadTargets(operationID, budget: &budget, database: database)
        guard targets == creation.targets else { throw RuntimeCanonicalExternalOperationError.corruptAuthority }
        let current = try loadCurrent(
            creation: creation, creationDigest: digest, budget: &budget, database: database
        )
        let history = try loadHistory(
            operationID: operationID, current: current, budget: &budget, database: database
        )
        let attempts = try loadAttempts(
            creation: creation, budget: &budget, database: database
        )
        let outcomes = try loadOutcomes(
            creation: creation, attempts: attempts, budget: &budget, database: database
        )
        try authenticateSemantics(
            creation: creation,
            current: current,
            history: history,
            attempts: attempts,
            outcomes: outcomes
        )
        try authenticateInvalidations(
            operationID: operationID, history: history, budget: &budget, database: database
        )
        return RuntimeExternalOperationAuthorityGraph(
            creation: creation,
            current: current,
            history: history,
            attempts: attempts,
            outcomes: outcomes
        )
    }

    private static func loadTargets<Budget: RuntimeExternalOperationReadBudget>(
        _ operationID: RuntimeExternalOperationID,
        budget: inout Budget,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeExternalOperationTarget] {
        let rows = try budget.query(
            "SELECT family, object_id FROM runtime_external_operation_targets WHERE operation_id = ? ORDER BY family, object_id LIMIT ?",
            bindings: [
                .text(operationID.rawValue),
                .integer(Int64(RuntimeExternalOperationLimits.maximumTargets + 1)),
            ],
            database: database
        )
        guard rows.count <= RuntimeExternalOperationLimits.maximumTargets else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        return try rows.map { row in
            try Task.checkCancellation()
            guard case let .text(rawFamily)? = row.value(named: "family"),
                  let family = RuntimeSemanticAggregateKind(rawValue: rawFamily),
                  case let .text(rawObjectID)? = row.value(named: "object_id"),
                  let objectID = RuntimeDomainObjectID(rawValue: rawObjectID) else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
            return RuntimeExternalOperationTarget(family: family, objectID: objectID)
        }
    }

    private static func loadCurrent<Budget: RuntimeExternalOperationReadBudget>(
        creation: RuntimeCanonicalExternalOperationCreation,
        creationDigest: String,
        budget: inout Budget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalExternalOperation {
        let rows = try budget.query(
            """
            SELECT creation_digest, provider_id, workflow_status, effect_disposition,
                   status_version, policy_version, attempt_count, next_attempt_at_ms,
                   claim_purpose, lease_token, lease_owner, lease_acquired_at_ms,
                   lease_expires_at_ms, external_reference, reason_code,
                   reason_fingerprint, state_payload, state_digest,
                   created_at_ms, updated_at_ms
            FROM runtime_external_operation_current WHERE operation_id = ? LIMIT 2
            """,
            bindings: [.text(creation.operationID.rawValue)],
            database: database
        )
        guard rows.count == 1, let row = rows.first,
              case let .blob(bytes)? = row.value(named: "state_payload"),
              bytes.count <= RuntimeExternalOperationLimits.maximumPayloadBytes,
              case let .text(digest)? = row.value(named: "state_digest"),
              RuntimeStoreManifestCodec.isSHA256Hex(digest),
              LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == digest else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        let current = try RuntimeExternalOperationCodec.decodeCurrent(bytes)
        guard current.operationID == creation.operationID,
              current.creationDigest == creationDigest,
              current.providerID == creation.providerID,
              current.policyVersion == creation.policyVersion,
              current.createdAt == creation.createdAt,
              row.value(named: "creation_digest") == .text(current.creationDigest),
              row.value(named: "provider_id") == .text(current.providerID.rawValue),
              row.value(named: "workflow_status") == .text(current.workflowStatus.rawValue),
              row.value(named: "effect_disposition") == .text(current.effectDisposition.rawValue),
              row.value(named: "status_version") == .integer(try int64(current.statusVersion)),
              row.value(named: "policy_version") == .integer(Int64(current.policyVersion)),
              row.value(named: "attempt_count") == .integer(Int64(current.attemptCount)),
              row.value(named: "next_attempt_at_ms") == dateValue(current.nextAttemptAt),
              row.value(named: "claim_purpose") == textValue(current.claimPurpose?.rawValue),
              row.value(named: "lease_token") == textValue(current.lease?.token.rawValue),
              row.value(named: "lease_owner") == textValue(current.lease?.owner.rawValue),
              row.value(named: "lease_acquired_at_ms") == dateValue(current.lease?.acquiredAt),
              row.value(named: "lease_expires_at_ms") == dateValue(current.lease?.expiresAt),
              row.value(named: "external_reference") == textValue(current.externalReference?.rawValue),
              row.value(named: "reason_code") == textValue(current.reasonCode?.rawValue),
              row.value(named: "reason_fingerprint") == textValue(current.reasonFingerprint?.rawValue),
              row.value(named: "created_at_ms") == .integer(try milliseconds(current.createdAt)),
              row.value(named: "updated_at_ms") == .integer(try milliseconds(current.updatedAt)),
              current.statusVersion <= UInt64(RuntimeExternalOperationLimits.maximumTransitions),
              expectedFingerprint(current.reasonCode, providerID: creation.providerID) == current.reasonFingerprint else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        return current
    }

    private static func loadHistory<Budget: RuntimeExternalOperationReadBudget>(
        operationID: RuntimeExternalOperationID,
        current: RuntimeCanonicalExternalOperation,
        budget: inout Budget,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeExternalOperationHistoryEntry] {
        let rows = try budget.query(
            """
            SELECT history_id, status_version, from_workflow_status,
                   from_effect_disposition, from_state_digest, to_workflow_status,
                   to_effect_disposition, to_state_digest, attempt_id,
                   transition_version, transition_payload, transition_payload_digest,
                   transition_digest,
                   occurred_at_ms
            FROM runtime_external_operation_history WHERE operation_id = ?
            ORDER BY status_version LIMIT ?
            """,
            bindings: [
                .text(operationID.rawValue),
                .integer(Int64(RuntimeExternalOperationLimits.maximumTransitions + 1)),
            ],
            database: database
        )
        guard rows.count == Int(current.statusVersion),
              rows.count <= RuntimeExternalOperationLimits.maximumTransitions else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        var values: [RuntimeExternalOperationHistoryEntry] = []
        var prior: RuntimeCanonicalExternalOperation?
        for (index, row) in rows.enumerated() {
            try Task.checkCancellation()
            guard case let .blob(bytes)? = row.value(named: "transition_payload"),
                  case let .text(payloadDigest)? = row.value(named: "transition_payload_digest"),
                  case let .text(storedDigest)? = row.value(named: "transition_digest"),
                  RuntimeStoreManifestCodec.isSHA256Hex(payloadDigest),
                  RuntimeStoreManifestCodec.isSHA256Hex(storedDigest),
                  LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == payloadDigest else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
            let entry = try RuntimeExternalOperationCodec.decodeHistory(bytes)
            let transition = entry.transition
            guard transition.operationID == operationID,
                  transition.fromState == prior,
                  transition.toState.statusVersion == UInt64(index + 1),
                  row.value(named: "history_id") == .text(entry.historyID.rawValue),
                  row.value(named: "status_version") == .integer(Int64(index + 1)),
                  row.value(named: "from_workflow_status") == textValue(transition.fromState?.workflowStatus.rawValue),
                  row.value(named: "from_effect_disposition") == textValue(transition.fromState?.effectDisposition.rawValue),
                  row.value(named: "from_state_digest") == textValue(transition.fromStateDigest),
                  row.value(named: "to_workflow_status") == .text(transition.toState.workflowStatus.rawValue),
                  row.value(named: "to_effect_disposition") == .text(transition.toState.effectDisposition.rawValue),
                  row.value(named: "to_state_digest") == .text(transition.toStateDigest),
                  row.value(named: "attempt_id") == textValue(transition.attemptID?.rawValue),
                  row.value(named: "transition_version") == .integer(Int64(transition.version)),
                  storedDigest == entry.transitionDigest,
                  row.value(named: "occurred_at_ms") == .integer(try milliseconds(transition.occurredAt)) else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
            values.append(entry)
            prior = transition.toState
        }
        guard prior == current else { throw RuntimeCanonicalExternalOperationError.corruptAuthority }
        return values
    }

    private static func loadAttempts<Budget: RuntimeExternalOperationReadBudget>(
        creation: RuntimeCanonicalExternalOperationCreation,
        budget: inout Budget,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeExternalAttemptStart] {
        let rows = try budget.query(
            """
            SELECT attempt_id, attempt_number, purpose, operation_action, source_status_version,
                   policy_version, provider_id, operation_kind, lease_token,
                   lease_owner, lease_acquired_at_ms, lease_expires_at_ms,
                   stable_idempotency_key, request_digest, start_version,
                   start_payload, start_digest, started_at_ms
            FROM runtime_external_operation_attempt_starts WHERE operation_id = ?
            ORDER BY attempt_number LIMIT ?
            """,
            bindings: [
                .text(creation.operationID.rawValue),
                .integer(Int64(RuntimeExternalOperationLimits.maximumAttempts + 1)),
            ],
            database: database
        )
        guard rows.count <= RuntimeExternalOperationLimits.maximumAttempts else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        return try rows.enumerated().map { index, row in
            try Task.checkCancellation()
            guard case let .blob(bytes)? = row.value(named: "start_payload"),
                  case let .text(digest)? = row.value(named: "start_digest"),
                  RuntimeStoreManifestCodec.isSHA256Hex(digest),
                  LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == digest else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
            let value = try RuntimeExternalOperationCodec.decodeAttemptStart(bytes)
            let requestSeed = [
                value.operationID.rawValue, value.attemptID.rawValue, value.purpose.rawValue,
                String(value.sourceStatusVersion), value.stableIdempotencyKey.rawValue,
                try RuntimeExternalOperationCodec.creationDigest(creation),
                creation.payload.action.rawValue,
                creation.payload.sourceOperationID?.rawValue ?? "",
                creation.payload.sourceProviderReference?.rawValue ?? "",
            ].joined(separator: "\u{0}")
            guard value.operationID == creation.operationID,
                  value.action == creation.payload.action,
                  value.attemptNumber == index + 1,
                  value.providerID == creation.providerID,
                  value.kind == creation.kind,
                  value.policyVersion == creation.policyVersion,
                  value.stableIdempotencyKey == creation.stableIdempotencyKey,
                  value.requestDigest == LocalRuntimeStorageChecksum.sha256Hex(for: Data(requestSeed.utf8)),
                  row.value(named: "attempt_id") == .text(value.attemptID.rawValue),
                  row.value(named: "attempt_number") == .integer(Int64(value.attemptNumber)),
                  row.value(named: "purpose") == .text(value.purpose.rawValue),
                  row.value(named: "operation_action") == .text(value.action.rawValue),
                  row.value(named: "source_status_version") == .integer(try int64(value.sourceStatusVersion)),
                  row.value(named: "policy_version") == .integer(Int64(value.policyVersion)),
                  row.value(named: "provider_id") == .text(value.providerID.rawValue),
                  row.value(named: "operation_kind") == .text(value.kind.rawValue),
                  row.value(named: "lease_token") == .text(value.lease.token.rawValue),
                  row.value(named: "lease_owner") == .text(value.lease.owner.rawValue),
                  row.value(named: "lease_acquired_at_ms") == .integer(try milliseconds(value.lease.acquiredAt)),
                  row.value(named: "lease_expires_at_ms") == .integer(try milliseconds(value.lease.expiresAt)),
                  row.value(named: "stable_idempotency_key") == .text(value.stableIdempotencyKey.rawValue),
                  row.value(named: "request_digest") == .text(value.requestDigest),
                  row.value(named: "start_version") == .integer(Int64(value.version)),
                  row.value(named: "started_at_ms") == .integer(try milliseconds(value.startedAt)) else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
            return value
        }
    }

    private static func loadOutcomes<Budget: RuntimeExternalOperationReadBudget>(
        creation: RuntimeCanonicalExternalOperationCreation,
        attempts: [RuntimeExternalAttemptStart],
        budget: inout Budget,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeExternalAttemptID: RuntimeExternalAttemptOutcomeRecord] {
        let rows = try budget.query(
            """
            SELECT attempt_id, outcome_kind, effect_disposition, external_reference,
                   reason_code, reason_fingerprint, outcome_version,
                   outcome_payload, outcome_digest, recorded_at_ms
            FROM runtime_external_operation_attempt_outcomes WHERE operation_id = ?
            ORDER BY recorded_at_ms, attempt_id LIMIT ?
            """,
            bindings: [
                .text(creation.operationID.rawValue),
                .integer(Int64(RuntimeExternalOperationLimits.maximumAttempts + 1)),
            ],
            database: database
        )
        guard rows.count <= RuntimeExternalOperationLimits.maximumAttempts else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        var values: [RuntimeExternalAttemptID: RuntimeExternalAttemptOutcomeRecord] = [:]
        for row in rows {
            try Task.checkCancellation()
            guard case let .blob(bytes)? = row.value(named: "outcome_payload"),
                  case let .text(digest)? = row.value(named: "outcome_digest"),
                  RuntimeStoreManifestCodec.isSHA256Hex(digest),
                  LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == digest else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
            let value = try RuntimeExternalOperationCodec.decodeOutcome(bytes)
            guard values.updateValue(value, forKey: value.attemptID) == nil,
                  value.operationID == creation.operationID,
                  let attempt = attempts.first(where: { $0.attemptID == value.attemptID }),
                  value.recordedAt >= attempt.startedAt,
                  RuntimeExternalOperationCodec.permitsOutcome(
                      action: creation.payload.action,
                      purpose: attempt.purpose,
                      kind: value.kind
                  ),
                  expectedFingerprint(value.reasonCode, providerID: creation.providerID) == value.reasonFingerprint,
                  row.value(named: "attempt_id") == .text(value.attemptID.rawValue),
                  row.value(named: "outcome_kind") == .text(value.kind.rawValue),
                  row.value(named: "effect_disposition") == .text(value.effectDisposition.rawValue),
                  row.value(named: "external_reference") == textValue(value.externalReference?.rawValue),
                  row.value(named: "reason_code") == textValue(value.reasonCode?.rawValue),
                  row.value(named: "reason_fingerprint") == textValue(value.reasonFingerprint?.rawValue),
                  row.value(named: "outcome_version") == .integer(Int64(value.version)),
                  row.value(named: "recorded_at_ms") == .integer(try milliseconds(value.recordedAt)) else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
        }
        return values
    }

    private static func authenticateSemantics(
        creation: RuntimeCanonicalExternalOperationCreation,
        current: RuntimeCanonicalExternalOperation,
        history: [RuntimeExternalOperationHistoryEntry],
        attempts: [RuntimeExternalAttemptStart],
        outcomes: [RuntimeExternalAttemptID: RuntimeExternalAttemptOutcomeRecord]
    ) throws {
        guard attempts.count == current.attemptCount else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        guard outcomes.values.allSatisfy({ outcome in
            guard let attempt = attempts.first(where: { $0.attemptID == outcome.attemptID }) else {
                return false
            }
            return RuntimeExternalOperationCodec.permitsOutcome(
                action: creation.payload.action,
                purpose: attempt.purpose,
                kind: outcome.kind
            )
        }),
        (current.workflowStatus != .succeeded || current.effectDisposition != .confirmedAbsent ||
         creation.payload.action == .compensateRemoval) else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        let open = attempts.filter { outcomes[$0.attemptID] == nil }
        guard open.isEmpty || (open.count == 1 && open.first == attempts.last) else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        for attempt in attempts {
            try Task.checkCancellation()
            let linked = history.filter { $0.transition.attemptID == attempt.attemptID }
            guard let begin = linked.first,
                  begin.transition.fromState?.statusVersion == attempt.sourceStatusVersion,
                  begin.transition.toState.statusVersion == attempt.sourceStatusVersion + 1,
                  begin.transition.toState.attemptCount == attempt.attemptNumber,
                  begin.transition.toState.lease == attempt.lease else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
            guard let outcome = outcomes[attempt.attemptID] else {
                guard linked.count == 1 else {
                    throw RuntimeCanonicalExternalOperationError.corruptAuthority
                }
                continue
            }
            guard linked.count == 2,
                  let conclusion = linked.last,
                  conclusion.transition.fromState?.statusVersion == attempt.sourceStatusVersion + 1,
                  conclusion.transition.toState.statusVersion == attempt.sourceStatusVersion + 2,
                  conclusion.transition.toState.updatedAt == outcome.recordedAt,
                  outcomeCoherent(
                      outcome,
                      action: creation.payload.action,
                      purpose: attempt.purpose,
                      state: conclusion.transition.toState
                  ),
                  (outcome.kind == .leaseExpiredWithoutOutcome
                    ? outcome.recordedAt >= attempt.lease.expiresAt
                    : outcome.recordedAt <= attempt.lease.expiresAt) else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
        }
        switch current.workflowStatus {
        case .executing:
            guard open.count == 1, open[0].purpose == .execute,
                  current.lease?.token == open[0].lease.token else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
        case .pending, .claimed, .retryScheduled, .succeeded, .permanentFailure,
             .operatorRequired, .cancelled:
            guard open.isEmpty else { throw RuntimeCanonicalExternalOperationError.corruptAuthority }
        case .reconciliationRequired:
            if let openAttempt = open.first {
                guard open.count == 1, openAttempt.purpose == .reconcile,
                      current.claimPurpose == .reconcile,
                      current.lease?.token == openAttempt.lease.token else {
                    throw RuntimeCanonicalExternalOperationError.corruptAuthority
                }
            } else if current.lease != nil {
                // A reconciliation claim may be durable before its attempt
                // authorization; no open attempt exists in that exact state.
                guard current.claimPurpose == .reconcile else {
                    throw RuntimeCanonicalExternalOperationError.corruptAuthority
                }
            }
        }
        guard history.last?.transition.toState == current,
              creation.targets == Array(Set(creation.targets)).sorted() else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
    }

    private static func authenticateInvalidations<Budget: RuntimeExternalOperationReadBudget>(
        operationID: RuntimeExternalOperationID,
        history: [RuntimeExternalOperationHistoryEntry],
        budget: inout Budget,
        database: isolated SQLiteDatabase
    ) throws {
        let expected = Array(history.dropFirst())
        let rows = try budget.query(
            """
            SELECT invalidation_id, status_version, history_id, payload,
                   payload_digest, created_at_ms
            FROM runtime_external_operation_transition_invalidations
            WHERE operation_id = ? ORDER BY status_version LIMIT ?
            """,
            bindings: [
                .text(operationID.rawValue),
                .integer(Int64(RuntimeExternalOperationLimits.maximumTransitions + 1)),
            ],
            database: database
        )
        guard rows.count == expected.count else { throw RuntimeCanonicalExternalOperationError.corruptAuthority }
        for (row, entry) in zip(rows, expected) {
            try Task.checkCancellation()
            guard case let .blob(bytes)? = row.value(named: "payload"),
                  case let .text(digest)? = row.value(named: "payload_digest"),
                  RuntimeStoreManifestCodec.isSHA256Hex(digest),
                  LocalRuntimeStorageChecksum.sha256Hex(for: bytes) == digest,
                  try RuntimeExternalOperationCodec.decodeHistory(bytes) == entry,
                  row.value(named: "invalidation_id") == .text(LocalRuntimeStorageChecksum.sha256Hex(
                      for: Data("external-transition-invalidation\u{0}\(entry.historyID.rawValue)".utf8)
                  )),
                  row.value(named: "status_version") == .integer(try int64(entry.transition.toState.statusVersion)),
                  row.value(named: "history_id") == .text(entry.historyID.rawValue),
                  row.value(named: "created_at_ms") == .integer(try milliseconds(entry.transition.occurredAt)) else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
        }
    }

    private static func outcomeCoherent(
        _ outcome: RuntimeExternalAttemptOutcomeRecord,
        action: RuntimeCanonicalExternalOperationPayload.Action,
        purpose: RuntimeExternalAttemptPurpose,
        state: RuntimeCanonicalExternalOperation
    ) -> Bool {
        guard RuntimeExternalOperationCodec.permitsOutcome(
            action: action,
            purpose: purpose,
            kind: outcome.kind
        ) else { return false }
        switch outcome.kind {
        case .confirmedSuccess, .confirmedPresence:
            state.workflowStatus == .succeeded && state.effectDisposition == .confirmedPresent
        case .confirmedCancellation, .reconciledCancellationAbsent:
            state.workflowStatus == .succeeded && state.effectDisposition == .confirmedAbsent
        case .cancellationRetryableBeforeEffect, .cancellationSourceStillPresent:
            (state.workflowStatus == .retryScheduled || state.workflowStatus == .permanentFailure) &&
                state.effectDisposition == .notAttempted
        case .cancellationUnsupported:
            state.workflowStatus == .permanentFailure && state.effectDisposition == .notAttempted
        case .retryableBeforeEffect, .confirmedAbsence:
            (state.workflowStatus == .retryScheduled || state.workflowStatus == .permanentFailure) &&
                state.effectDisposition == .confirmedAbsent
        case .rejectedBeforeEffect, .permissionUnavailableBeforeEffect:
            state.workflowStatus == .permanentFailure && state.effectDisposition == .notAttempted
        case .indeterminate, .leaseExpiredWithoutOutcome:
            state.workflowStatus == .reconciliationRequired && state.effectDisposition == .indeterminate
        case .ambiguousReconciliation:
            (state.workflowStatus == .reconciliationRequired || state.workflowStatus == .operatorRequired) &&
                state.effectDisposition == .indeterminate
        case .incompatibleProviderState:
            state.workflowStatus == .permanentFailure && state.effectDisposition == .indeterminate
        }
    }

    private static func expectedFingerprint(
        _ code: RuntimeExternalReasonCode?, providerID: RuntimeExternalProviderID
    ) -> RuntimeExternalReasonFingerprint? {
        code.map { RuntimeExternalReasonFingerprint.redacted(code: $0, providerID: providerID) }
    }

    private static func textValue(_ value: String?) -> SQLiteValue {
        value.map(SQLiteValue.text) ?? .null
    }

    private static func dateValue(_ value: Date?) -> SQLiteValue {
        guard let value else { return .null }
        let raw = value.timeIntervalSince1970 * 1_000
        guard raw.isFinite, raw >= 0, raw < 9_000_000_000_000_000_000,
              raw.rounded() == raw else { return .null }
        return .integer(Int64(raw))
    }

    private static func milliseconds(_ value: Date) throws -> Int64 {
        let raw = value.timeIntervalSince1970 * 1_000
        guard raw.isFinite, raw >= 0, raw < 9_000_000_000_000_000_000,
              raw.rounded() == raw else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        return Int64(raw)
    }

    private static func int64(_ value: UInt64) throws -> Int64 {
        guard value <= UInt64(Int64.max) else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        return Int64(value)
    }
}
