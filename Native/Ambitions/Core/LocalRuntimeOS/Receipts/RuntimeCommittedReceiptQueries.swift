import AmbitionsRuntimeSQLite
import AmbitionsRuntimeCore
import Foundation

enum RuntimeCommittedReceiptQueryError: Error, Sendable, Equatable {
    case cursorBindingMismatch
    case corruptAuthority
    case firstRowExceedsBound
    case sourceBlocked(RuntimeReceiptSourceBlockedReason)
}

struct RuntimeReceiptKeysetPredicate: Sendable, Equatable {
    let sql: String
    let bindings: [SQLiteBinding]
}

extension CanonicalRuntimeStore {
    private struct ObjectHistoryQueryBinding: Codable {
        let aggregate: RuntimeSemanticAggregate
        let accessPolicyDigest: String
    }

    func committedReceipt(
        receiptID: RuntimeReceiptID,
        access: RuntimeReceiptReadAccess,
        at now: Date
    ) async throws -> RuntimeReceiptAuthorityState {
        try Task.checkCancellation()
        return try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeCommittedReceiptSchemaPlan.requireIntegratedSchema(in: database)
            return try Self.receiptAuthorityState(
                receiptID: receiptID,
                access: access,
                now: now,
                database: database
            )
        }
    }

    func committedReceiptPage(
        access: RuntimeReceiptReadAccess,
        after cursor: RuntimeReceiptCursor? = nil,
        limit: Int = 50,
        at now: Date
    ) async throws -> RuntimeReceiptPage {
        try Task.checkCancellation()
        return try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeCommittedReceiptSchemaPlan.requireIntegratedSchema(in: database)
            return try Self.committedReceiptPageInTransaction(
                access: access,
                after: cursor,
                limit: limit,
                at: now,
                database: database
            )
        }
    }

    static func committedReceiptPageInTransaction(
        access: RuntimeReceiptReadAccess,
        after cursor: RuntimeReceiptCursor? = nil,
        limit: Int = 50,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeReceiptPage {
        var decodedBudget = RuntimeReceiptDecodedByteBudget(maximumBytes: access.maximumBytes)
        let keyset = try receiptKeysetPredicate(after: cursor, access: access)
        let authorization = authorizedReceiptPredicate(
            access: access,
            digestColumn: "c.core_digest",
            privacyColumn: "c.privacy"
        )
        let highWater: UInt64
        if let cursor {
            highWater = cursor.highWaterEventSequence
        } else {
            let rows = try decodedBudget.query(
                """
                SELECT COALESCE(MAX(c.terminal_event_sequence), 0) AS high_water
                FROM runtime_committed_receipt_cores AS c WHERE 1 = 1
                """ + authorization.sql,
                bindings: authorization.bindings,
                database: database
            )
            guard rows.count == 1, let row = rows.first,
                  case let .integer(value)? = row.value(named: "high_water"), value >= 0 else {
                throw RuntimeCommittedReceiptQueryError.corruptAuthority
            }
            highWater = UInt64(value)
        }
        let delivery = max(1, min(limit, access.maximumRows))
        try Task.checkCancellation()
        let readCount = delivery + 1
        var rowBindings: [SQLiteBinding] = [.integer(try receiptInt64(highWater))]
        rowBindings.append(contentsOf: authorization.bindings)
        rowBindings.append(contentsOf: keyset.bindings)
        rowBindings.append(.integer(Int64(readCount)))
        let rowSQL = """
            SELECT c.receipt_id, c.terminal_event_sequence
            FROM runtime_committed_receipt_cores AS c
            WHERE c.terminal_event_sequence <= ?
            """ + authorization.sql + keyset.sql + """
            ORDER BY c.terminal_event_sequence DESC LIMIT ?
            """
        let rows = try decodedBudget.query(
            rowSQL,
            bindings: rowBindings,
            database: database
        )
        var admittedRows: [SQLiteRow] = []
        var states: [RuntimeReceiptAuthorityState] = []
        for row in rows.prefix(delivery) {
            try Task.checkCancellation()
            guard case let .text(rawReceiptID)? = row.value(named: "receipt_id"),
                  let receiptID = RuntimeReceiptID(rawValue: rawReceiptID) else {
                throw RuntimeCommittedReceiptQueryError.corruptAuthority
            }
            var trialBudget = decodedBudget
            do {
                let state = try receiptAuthorityState(
                    receiptID: receiptID,
                    access: access,
                    now: now,
                    budget: &trialBudget,
                    database: database
                )
                decodedBudget = trialBudget
                admittedRows.append(row)
                states.append(state)
            } catch RuntimeCommittedReceiptQueryError.firstRowExceedsBound {
                guard states.isEmpty == false else {
                    throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
                }
                break
            } catch is SQLiteQueryBudgetExceeded {
                guard states.isEmpty == false else {
                    throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
                }
                break
            }
        }
        let hasMore = rows.count > admittedRows.count
        let nextCursor: RuntimeReceiptCursor?
        if hasMore, let last = admittedRows.last,
           case let .integer(sequence)? = last.value(named: "terminal_event_sequence"), sequence >= 0 {
            nextCursor = RuntimeReceiptCursor(
                highWaterEventSequence: highWater,
                eventSequence: UInt64(sequence),
                accessPolicyDigest: access.digest
            )
        } else {
            nextCursor = nil
        }
        return RuntimeReceiptPage(items: states, nextCursor: nextCursor)
    }

    func objectHistoryPage(
        aggregate: RuntimeSemanticAggregate,
        access: RuntimeReceiptReadAccess,
        after cursor: RuntimeObjectHistoryCursor? = nil,
        limit: Int = 50
    ) async throws -> RuntimeObjectHistoryPage {
        try Task.checkCancellation()
        return try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeCommittedReceiptSchemaPlan.requireIntegratedSchema(in: database)
            return try Self.objectHistoryPageInTransaction(
                aggregate: aggregate,
                access: access,
                after: cursor,
                limit: limit,
                database: database
            )
        }
    }

    static func objectHistoryPageInTransaction(
        aggregate: RuntimeSemanticAggregate,
        access: RuntimeReceiptReadAccess,
        after cursor: RuntimeObjectHistoryCursor? = nil,
        limit: Int = 50,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeObjectHistoryPage {
        let queryBindingDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: try RuntimeCommittedReceiptCodec.encode(ObjectHistoryQueryBinding(
                aggregate: aggregate,
                accessPolicyDigest: access.digest
            ))
        )
            var decodedBudget = RuntimeReceiptDecodedByteBudget(maximumBytes: access.maximumBytes)
            let keyset = try Self.objectHistoryKeysetPredicate(
                after: cursor,
                access: access,
                queryBindingDigest: queryBindingDigest
            )
            let authorization = Self.authorizedReceiptPredicate(
                access: access,
                digestColumn: "c.core_digest",
                privacyColumn: "c.privacy"
            )
            let highWater: UInt64
            if let cursor {
                highWater = cursor.highWaterEventSequence
            } else {
                let rows = try decodedBudget.query(
                    """
                    SELECT COALESCE(MAX(h.terminal_event_sequence), 0) AS high_water
                    FROM runtime_object_history AS h
                    JOIN runtime_committed_receipt_cores AS c ON c.receipt_id = h.receipt_id
                    WHERE h.family = ? AND h.object_id = ?
                    """ + authorization.sql,
                    bindings: [
                        .text(aggregate.kind.rawValue), .text(aggregate.id.rawValue),
                    ] + authorization.bindings,
                    database: database
                )
                guard rows.count == 1, let row = rows.first,
                      case let .integer(value)? = row.value(named: "high_water"), value >= 0 else {
                    throw RuntimeCommittedReceiptQueryError.corruptAuthority
                }
                highWater = UInt64(value)
            }
            let delivery = max(1, min(limit, access.maximumRows))
            try Task.checkCancellation()
            let readCount = delivery + 1
            var rowBindings: [SQLiteBinding] = [
                .text(aggregate.kind.rawValue), .text(aggregate.id.rawValue),
                .integer(try Self.receiptInt64(highWater)),
            ]
            rowBindings.append(contentsOf: authorization.bindings)
            rowBindings.append(contentsOf: keyset.bindings)
            rowBindings.append(.integer(Int64(readCount)))
            let rowSQL = """
                SELECT h.history_id, h.receipt_id, h.terminal_event_sequence,
                       h.privacy, h.created_at_ms
                FROM runtime_object_history AS h
                JOIN runtime_committed_receipt_cores AS c ON c.receipt_id = h.receipt_id
                WHERE h.family = ? AND h.object_id = ? AND h.terminal_event_sequence <= ?
                """ + authorization.sql + keyset.sql + """
                ORDER BY h.terminal_event_sequence DESC, h.history_id DESC LIMIT ?
                """
            let rows = try decodedBudget.query(
                rowSQL,
                bindings: rowBindings,
                database: database
            )
            var admittedRows: [SQLiteRow] = []
            var items: [RuntimeObjectHistoryAuthorityState] = []
            for row in rows.prefix(delivery) {
                try Task.checkCancellation()
                var trialBudget = decodedBudget
                do {
                    guard let item = try Self.historyAuthorityState(
                        row: row,
                        access: access,
                        budget: &trialBudget,
                        database: database
                    ) else { continue }
                    decodedBudget = trialBudget
                    admittedRows.append(row)
                    items.append(item)
                } catch RuntimeCommittedReceiptQueryError.firstRowExceedsBound {
                    guard items.isEmpty == false else { throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound }
                    break
                } catch is SQLiteQueryBudgetExceeded {
                    guard items.isEmpty == false else { throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound }
                    break
                }
            }
            let hasMore = rows.count > admittedRows.count
            let nextCursor: RuntimeObjectHistoryCursor?
            if hasMore, let last = admittedRows.last,
               case let .integer(sequence)? = last.value(named: "terminal_event_sequence"), sequence >= 0,
               case let .text(historyID)? = last.value(named: "history_id") {
                nextCursor = RuntimeObjectHistoryCursor(
                    highWaterEventSequence: highWater,
                    eventSequence: UInt64(sequence),
                    historyID: historyID,
                    accessPolicyDigest: access.digest,
                    queryBindingDigest: queryBindingDigest
                )
            } else {
                nextCursor = nil
            }
            return RuntimeObjectHistoryPage(items: items, nextCursor: nextCursor)
    }

    func compensationEligibility(
        receiptID: RuntimeReceiptID,
        access: RuntimeReceiptReadAccess,
        at now: Date
    ) async throws -> RuntimeCompensationEligibility {
        try Task.checkCancellation()
        return try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeCommittedReceiptSchemaPlan.requireIntegratedSchema(in: database)
            return try Self.compensationEligibilityInTransaction(
                receiptID: receiptID, access: access, at: now, database: database
            )
        }
    }

    func compensationOffer(
        receiptID: RuntimeReceiptID,
        access: RuntimeReceiptReadAccess,
        context: RuntimeCompensationOfferContext,
        at now: Date
    ) async throws -> RuntimeCompensationOfferState {
        try Task.checkCancellation()
        return try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeCommittedReceiptSchemaPlan.requireIntegratedSchema(in: database)
            return try Self.compensationOfferInTransaction(
                receiptID: receiptID, access: access, context: context,
                at: now, database: database
            )
        }
    }

    static func compensationEligibilityInTransaction(
        receiptID: RuntimeReceiptID,
        access: RuntimeReceiptReadAccess,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCompensationEligibility {
        var budget = RuntimeReceiptDecodedByteBudget(maximumBytes: access.maximumBytes)
        let authorization = authorizedReceiptPredicate(
            access: access, digestColumn: "core_digest", privacyColumn: "privacy"
        )
        let presence: [SQLiteRow]
        do {
            presence = try budget.query(
                "SELECT core_digest, privacy FROM runtime_committed_receipt_cores WHERE receipt_id = ?" +
                    authorization.sql + "LIMIT 1",
                bindings: [.text(receiptID.rawValue)] + authorization.bindings,
                database: database
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch RuntimeCommittedReceiptQueryError.firstRowExceedsBound {
            throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
        } catch is SQLiteQueryBudgetExceeded {
            throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
        }
        guard presence.count == 1,
              case let .text(authorizedDigest)? = presence[0].value(named: "core_digest"),
              case let .text(rawAuthorizedPrivacy)? = presence[0].value(named: "privacy"),
              let authorizedPrivacy = EventLedgerPrivacyClassification(rawValue: rawAuthorizedPrivacy) else {
            return .unavailable
        }
        let graph: RuntimeAuthenticatedReceiptGraph
        do {
            let core = try RuntimeCommittedReceiptAuthority.loadCore(
                receiptID: receiptID,
                budget: &budget,
                database: database
            )
            guard core.receiptDigest == authorizedDigest,
                  core.facts.privacy.classification == authorizedPrivacy,
                  access.exposure(for: core.receiptDigest, privacy: authorizedPrivacy) == .full else {
                return .unavailable
            }
            graph = try RuntimeCommittedReceiptAuthority.authenticatePersistedCore(
                core,
                coreRowAuthenticated: true,
                budget: &budget,
                database: database
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as RuntimeCommittedReceiptQueryError where error == .firstRowExceedsBound {
            throw error
        } catch is SQLiteQueryBudgetExceeded {
            throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
        } catch {
            let reason = compensationAuthorityFailureReason(error)
            return .sourceBlocked(reason: reason, fingerprint: blockedFingerprint(reason))
        }
        return try compensationEligibility(graph: graph, now: now)
    }

    static func compensationOfferInTransaction(
        receiptID: RuntimeReceiptID,
        access: RuntimeReceiptReadAccess,
        context: RuntimeCompensationOfferContext,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCompensationOfferState {
        var budget = RuntimeReceiptDecodedByteBudget(maximumBytes: access.maximumBytes)
        let authorization = authorizedReceiptPredicate(
            access: access, digestColumn: "core_digest", privacyColumn: "privacy"
        )
        let presence: [SQLiteRow]
        do {
            presence = try budget.query(
                "SELECT core_digest, privacy FROM runtime_committed_receipt_cores WHERE receipt_id = ?" +
                    authorization.sql + "LIMIT 1",
                bindings: [.text(receiptID.rawValue)] + authorization.bindings,
                database: database
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch RuntimeCommittedReceiptQueryError.firstRowExceedsBound {
            throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
        } catch is SQLiteQueryBudgetExceeded {
            throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
        }
        guard presence.count == 1,
              case let .text(authorizedDigest)? = presence[0].value(named: "core_digest"),
              case let .text(rawAuthorizedPrivacy)? = presence[0].value(named: "privacy"),
              let authorizedPrivacy = EventLedgerPrivacyClassification(rawValue: rawAuthorizedPrivacy) else {
            return .unavailable(.unavailable)
        }
        let core: RuntimeCommittedReceiptCore
        let graph: RuntimeAuthenticatedReceiptGraph
        do {
            core = try RuntimeCommittedReceiptAuthority.loadCore(
                receiptID: receiptID,
                budget: &budget,
                database: database
            )
            guard core.receiptDigest == authorizedDigest,
                  core.facts.privacy.classification == authorizedPrivacy,
                  access.exposure(for: core.receiptDigest, privacy: authorizedPrivacy) == .full else {
                return .unavailable(.unavailable)
            }
            graph = try RuntimeCommittedReceiptAuthority.authenticatePersistedCore(
                core,
                coreRowAuthenticated: true,
                budget: &budget,
                database: database
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as RuntimeCommittedReceiptQueryError where error == .firstRowExceedsBound {
            throw error
        } catch is SQLiteQueryBudgetExceeded {
            throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
        } catch {
            let reason = compensationAuthorityFailureReason(error)
            return .unavailable(.sourceBlocked(
                reason: reason,
                fingerprint: blockedFingerprint(reason)
            ))
        }
        let eligibility = try compensationEligibility(graph: graph, now: now)
        guard eligibility == .available || eligibility == .confirmationRequired else {
            return .unavailable(eligibility)
        }
        guard case let .plan(_, digest, expiresAt, requiresConfirmation) = core.facts.compensation else {
            let blocked = RuntimeCompensationEligibility.sourceBlocked(
                reason: .compensationDispositionMismatch,
                fingerprint: blockedFingerprint(.compensationDispositionMismatch)
            )
            return .unavailable(blocked)
        }
        guard let plan = graph.plan else {
            return .unavailable(.sourceBlocked(
                reason: .compensationDispositionMismatch,
                fingerprint: blockedFingerprint(.compensationDispositionMismatch)
            ))
        }
        guard plan.digest == digest,
              plan.expiresAt == expiresAt,
              plan.requiresConfirmation == requiresConfirmation,
              let primary = plan.targets.first(where: {
                  $0.aggregate.kind == plan.action.aggregateKind &&
                      $0.aggregate.id.rawValue == plan.action.primaryObjectID.rawValue
              }) else {
            let blocked = RuntimeCompensationEligibility.sourceBlocked(
                reason: .compensationDispositionMismatch,
                fingerprint: blockedFingerprint(.compensationDispositionMismatch)
            )
            return .unavailable(blocked)
        }
        let payload = RuntimeCompensationCommand(
            sourceReceiptID: receiptID,
            planID: plan.planID,
            planDigest: plan.digest,
            sourceLineage: plan.sourceLineage,
            action: plan.action,
            targets: plan.targets,
            requiresConfirmation: plan.requiresConfirmation,
            target: plan.action.target,
            content: RuntimeCommandContent()
        )
        let command = AmbitionsCommand(
            id: context.commandID.rawValue,
            source: context.source,
            typedPayload: .compensation(payload),
            expectedRevision: .exact(primary.requiredCurrentRevision),
            idempotencyKey: context.idempotencyKey,
            createdAt: DomainTimestamp.string(from: now),
            actor: .user,
            localOnly: true,
            privacy: core.facts.privacy.classification
        )
        guard let featureCommand = RuntimeCompensationFeatureCommand(command) else {
            let blocked = RuntimeCompensationEligibility.sourceBlocked(
                reason: .compensationDispositionMismatch,
                fingerprint: blockedFingerprint(.compensationDispositionMismatch)
            )
            return .unavailable(blocked)
        }
        return .ready(RuntimeCompensationOffer(command: featureCommand, eligibility: eligibility))
    }

    private static func compensationAuthorityFailureReason(
        _ error: Error
    ) -> RuntimeReceiptSourceBlockedReason {
        if let authorityError = error as? RuntimeCommittedReceiptAuthorityError {
            return switch authorityError {
            case let .sourceBlocked(reason): reason
            case .corruptAuthority: .corruptReceiptCore
            }
        }
        if let codecError = error as? RuntimeCommittedReceiptCodecError,
           codecError == .futureVersion {
            return .futureReceiptVersion
        }
        return .corruptReceiptCore
    }

    static func receiptKeysetPredicate(
        after cursor: RuntimeReceiptCursor?,
        access: RuntimeReceiptReadAccess
    ) throws -> RuntimeReceiptKeysetPredicate {
        guard let cursor else {
            return RuntimeReceiptKeysetPredicate(sql: "", bindings: [])
        }
        guard cursor.accessPolicyDigest == access.digest,
              RuntimeStoreManifestCodec.isSHA256Hex(cursor.accessPolicyDigest),
              cursor.accessPolicyDigest == cursor.accessPolicyDigest.lowercased(),
              cursor.eventSequence <= cursor.highWaterEventSequence else {
            throw RuntimeCommittedReceiptQueryError.cursorBindingMismatch
        }
        return RuntimeReceiptKeysetPredicate(
            sql: "AND c.terminal_event_sequence < ?",
            bindings: [.integer(try receiptInt64(cursor.eventSequence))]
        )
    }

    private static func authorizedReceiptPredicate(
        access: RuntimeReceiptReadAccess,
        digestColumn: String,
        privacyColumn: String
    ) -> RuntimeReceiptKeysetPredicate {
        let authorizations = access.authorizations.sorted()
        guard authorizations.isEmpty == false else {
            return RuntimeReceiptKeysetPredicate(sql: " AND 0 ", bindings: [])
        }
        return RuntimeReceiptKeysetPredicate(
            sql: " AND (" + authorizations.map { _ in
                "(\(digestColumn) = ? AND \(privacyColumn) = ?)"
            }.joined(separator: " OR ") + ") ",
            bindings: authorizations.flatMap {
                [.text($0.coreDigest), .text($0.privacy.rawValue)]
            }
        )
    }

    static func objectHistoryKeysetPredicate(
        after cursor: RuntimeObjectHistoryCursor?,
        access: RuntimeReceiptReadAccess,
        queryBindingDigest: String
    ) throws -> RuntimeReceiptKeysetPredicate {
        guard let cursor else {
            return RuntimeReceiptKeysetPredicate(sql: "", bindings: [])
        }
        guard cursor.accessPolicyDigest == access.digest,
              RuntimeStoreManifestCodec.isSHA256Hex(cursor.accessPolicyDigest),
              cursor.accessPolicyDigest == cursor.accessPolicyDigest.lowercased(),
              cursor.queryBindingDigest == queryBindingDigest,
              RuntimeStoreManifestCodec.isSHA256Hex(cursor.queryBindingDigest),
              cursor.queryBindingDigest == cursor.queryBindingDigest.lowercased(),
              cursor.eventSequence <= cursor.highWaterEventSequence,
              RuntimeStoreManifestCodec.isSHA256Hex(cursor.historyID),
              cursor.historyID == cursor.historyID.lowercased() else {
            throw RuntimeCommittedReceiptQueryError.cursorBindingMismatch
        }
        return RuntimeReceiptKeysetPredicate(
            sql: """
                AND (h.terminal_event_sequence < ? OR
                     (h.terminal_event_sequence = ? AND h.history_id < ?))
                """,
            bindings: [
                .integer(try receiptInt64(cursor.eventSequence)),
                .integer(try receiptInt64(cursor.eventSequence)),
                .text(cursor.historyID),
            ]
        )
    }

    static func receiptAuthorityState(
        receiptID: RuntimeReceiptID,
        access: RuntimeReceiptReadAccess,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeReceiptAuthorityState {
        var budget = RuntimeReceiptDecodedByteBudget(maximumBytes: access.maximumBytes)
        return try receiptAuthorityState(
            receiptID: receiptID,
            access: access,
            now: now,
            budget: &budget,
            database: database
        )
    }

    static func receiptAuthorityState(
        receiptID: RuntimeReceiptID,
        access: RuntimeReceiptReadAccess,
        now: Date,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeReceiptAuthorityState {
        let authorization = authorizedReceiptPredicate(
            access: access, digestColumn: "core_digest", privacyColumn: "privacy"
        )
        let presence = try budget.query(
            "SELECT core_digest, privacy FROM runtime_committed_receipt_cores WHERE receipt_id = ?" +
                authorization.sql + "LIMIT 1",
            bindings: [.text(receiptID.rawValue)] + authorization.bindings,
            database: database
        )
        guard presence.count == 1,
              case let .text(authorizedDigest)? = presence[0].value(named: "core_digest"),
              case let .text(rawAuthorizedPrivacy)? = presence[0].value(named: "privacy"),
              let authorizedPrivacy = EventLedgerPrivacyClassification(rawValue: rawAuthorizedPrivacy) else {
            return .unavailable
        }
        let core: RuntimeCommittedReceiptCore
        do {
            core = try RuntimeCommittedReceiptAuthority.loadCore(
                receiptID: receiptID,
                budget: &budget,
                database: database
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch is SQLiteQueryBudgetExceeded {
            throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
        } catch {
            let reason = RuntimeReceiptSourceBlockedReason.corruptReceiptCore
            return .sourceBlocked(reason: reason, fingerprint: blockedFingerprint(reason))
        }
        guard core.receiptDigest == authorizedDigest,
              core.facts.privacy.classification == authorizedPrivacy else { return .unavailable }
        let exposure = access.exposure(for: core.receiptDigest, privacy: authorizedPrivacy)
        guard exposure != .denied else { return .unavailable }
        let graph: RuntimeAuthenticatedReceiptGraph
        do {
            graph = try RuntimeCommittedReceiptAuthority.authenticatePersistedCore(
                core,
                coreRowAuthenticated: true,
                budget: &budget,
                database: database
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as RuntimeCommittedReceiptAuthorityError {
            let reason: RuntimeReceiptSourceBlockedReason = switch error {
            case let .sourceBlocked(reason): reason
            case .corruptAuthority: .corruptReceiptCore
            }
            return .sourceBlocked(reason: reason, fingerprint: Self.blockedFingerprint(reason))
        } catch let error as RuntimeCommittedReceiptCodecError {
            let reason: RuntimeReceiptSourceBlockedReason = error == .futureVersion
                ? .futureReceiptVersion
                : .corruptReceiptCore
            return .sourceBlocked(reason: reason, fingerprint: Self.blockedFingerprint(reason))
        } catch let error as RuntimeCommittedReceiptQueryError {
            if error == .firstRowExceedsBound { throw error }
            return .sourceBlocked(
                reason: .corruptReceiptCore,
                fingerprint: Self.blockedFingerprint(.corruptReceiptCore)
            )
        } catch is SQLiteQueryBudgetExceeded {
            throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
        } catch {
            return .sourceBlocked(
                reason: .corruptReceiptCore,
                fingerprint: Self.blockedFingerprint(.corruptReceiptCore)
            )
        }
        let eligibility = try compensationEligibility(
            graph: graph,
            now: now
        )
        let replayCoverage: RuntimeReceiptReplayCoverage
        do {
            replayCoverage = try replayCoverage(for: core, budget: &budget, database: database)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            let reason = RuntimeReceiptSourceBlockedReason.terminalEventIntegrityMismatch
            return .sourceBlocked(reason: reason, fingerprint: blockedFingerprint(reason))
        }
        if exposure == .full {
            guard let finalized = graph.finalizedIdempotency else {
                let reason = RuntimeReceiptSourceBlockedReason.idempotencyMismatch
                return .sourceBlocked(reason: reason, fingerprint: blockedFingerprint(reason))
            }
            return .available(RuntimeCommittedReceipt(
                core: core,
                finalizedIdempotency: finalized,
                replayCoverage: replayCoverage
            ))
        }
        guard exposure == .redacted else { return .unavailable }
        return .redacted(RuntimeCommittedReceiptRedactedView(
            committedAt: core.facts.committedAt,
            outcome: core.facts.outcome,
            privacy: core.facts.privacy.classification,
            affectedFamilies: Array(Set(core.facts.objects.map { $0.aggregate.kind })).sorted {
                $0.rawValue < $1.rawValue
            },
            compensation: redactedEligibility(eligibility),
            replayCoverage: replayCoverage
        ))
    }

    private static func historyAuthorityState(
        row: SQLiteRow,
        access: RuntimeReceiptReadAccess,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeObjectHistoryAuthorityState? {
        try RuntimeReceiptCancellation.check(.historyTraversal)
        guard case let .text(rawReceiptID)? = row.value(named: "receipt_id"),
              let receiptID = RuntimeReceiptID(rawValue: rawReceiptID),
              case let .text(historyID)? = row.value(named: "history_id"),
              case let .text(storedPrivacy)? = row.value(named: "privacy"),
              case let .integer(createdAt)? = row.value(named: "created_at_ms"), createdAt >= 0 else {
            return .sourceBlocked(
                reason: .objectHistoryMismatch,
                fingerprint: blockedFingerprint(.objectHistoryMismatch)
            )
        }
        let core: RuntimeCommittedReceiptCore
        do {
            core = try RuntimeCommittedReceiptAuthority.loadCore(
                receiptID: receiptID,
                budget: &budget,
                database: database
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch is SQLiteQueryBudgetExceeded {
            throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
        } catch {
            return .sourceBlocked(
                reason: .objectHistoryMismatch,
                fingerprint: blockedFingerprint(.objectHistoryMismatch)
            )
        }
        let exposure = access.exposure(
            for: core.receiptDigest,
            privacy: core.facts.privacy.classification
        )
        guard exposure != .denied else { return nil }
        let graph: RuntimeAuthenticatedReceiptGraph
        do {
            graph = try RuntimeCommittedReceiptAuthority.authenticatePersistedCore(
                core,
                coreRowAuthenticated: true,
                budget: &budget,
                database: database
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as RuntimeCommittedReceiptAuthorityError {
            let reason: RuntimeReceiptSourceBlockedReason = switch error {
            case let .sourceBlocked(reason): reason
            case .corruptAuthority: .objectHistoryMismatch
            }
            return .sourceBlocked(reason: reason, fingerprint: blockedFingerprint(reason))
        } catch let error as RuntimeCommittedReceiptQueryError {
            if error == .firstRowExceedsBound { throw error }
            if case let .sourceBlocked(reason) = error {
                return .sourceBlocked(reason: reason, fingerprint: blockedFingerprint(reason))
            }
            return .sourceBlocked(
                reason: .objectHistoryMismatch,
                fingerprint: blockedFingerprint(.objectHistoryMismatch)
            )
        } catch is SQLiteQueryBudgetExceeded {
            throw RuntimeCommittedReceiptQueryError.firstRowExceedsBound
        } catch {
            return .sourceBlocked(
                reason: .objectHistoryMismatch,
                fingerprint: blockedFingerprint(.objectHistoryMismatch)
            )
        }
        guard let entry = graph.history.first(where: { $0.historyID == historyID }) else {
            return .sourceBlocked(
                reason: .objectHistoryMismatch,
                fingerprint: blockedFingerprint(.objectHistoryMismatch)
            )
        }
        guard entry.historyID == historyID,
              entry.receiptID == receiptID,
              core.facts.objects.contains(entry.object),
              core.facts.lineage == entry.lineage,
              entry.privacy == core.facts.privacy,
              storedPrivacy == entry.privacy.classification.rawValue else {
            return .sourceBlocked(
                reason: .objectHistoryMismatch,
                fingerprint: blockedFingerprint(.objectHistoryMismatch)
            )
        }
        if exposure == .full {
            return .available(entry)
        }
        guard exposure == .redacted else { return nil }
        return .redacted(
            committedAt: Date(timeIntervalSince1970: Double(createdAt) / 1_000),
            family: entry.object.aggregate.kind,
            lifecycle: entry.object.lifecycle,
            transition: entry.object.transition
        )
    }

    private static func compensationEligibility(
        graph: RuntimeAuthenticatedReceiptGraph,
        now: Date
    ) throws -> RuntimeCompensationEligibility {
        try RuntimeReceiptCancellation.check(.eligibilityEvaluation)
        let core = graph.core
        let receiptID = core.facts.receiptID
        switch core.facts.compensation {
        case let .noncompensable(_, evidence):
            guard graph.irreversibilityEvidence == evidence,
                  graph.plan == nil else {
                return .sourceBlocked(
                    reason: .compensationDispositionMismatch,
                    fingerprint: blockedFingerprint(.compensationDispositionMismatch)
                )
            }
            return evidence.permanence == .semantic ? .irreversible(evidence) : .unsupported(evidence)
        case let .plan(planID, digest, expiresAt, requiresConfirmation):
            guard let plan = graph.plan,
                  graph.irreversibilityEvidence == nil,
                  plan.planID == planID,
                  plan.sourceReceiptID == receiptID,
                  plan.digest == digest,
                  plan.expiresAt == expiresAt,
                  plan.requiresConfirmation == requiresConfirmation else {
                return .sourceBlocked(
                    reason: .compensationDispositionMismatch,
                    fingerprint: blockedFingerprint(.compensationDispositionMismatch)
                )
            }
            if let compensationReceiptID = graph.compensationReceiptID {
                return .consumed(compensationReceiptID: compensationReceiptID)
            }
            guard graph.pendingExternalOperations.map(\.operationID) == plan.externalOperationIDs else {
                return .sourceBlocked(
                    reason: .compensationDispositionMismatch,
                    fingerprint: blockedFingerprint(.compensationDispositionMismatch)
                )
            }
            if plan.externalOperationIDs.isEmpty == false {
                return .pendingExternalWork(operationIDs: plan.externalOperationIDs)
            }
            if now > expiresAt { return .expired }
            for target in plan.targets {
                try Task.checkCancellation()
                guard let state = graph.currentTargetStates[target.aggregate] else { return .stale }
                guard state.aggregate == target.aggregate,
                      state.revision == target.requiredCurrentRevision,
                      state.lifecycle == target.requiredLifecycle else {
                    return .stale
                }
            }
            return requiresConfirmation ? .confirmationRequired : .available
        }
    }

    private static func replayCoverage(
        for core: RuntimeCommittedReceiptCore,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeReceiptReplayCoverage {
        try RuntimeReceiptCancellation.check(.replayCoverage)
        let quarantineRows = try budget.query(
            """
            SELECT occurrence_id, quarantine_key, source_event_id, source_event_sequence
            FROM runtime_replay_quarantine_occurrences
            ORDER BY observed_at_ms ASC, occurrence_id ASC LIMIT 1
            """,
            database: database
        )
        guard quarantineRows.count <= 1 else {
            throw RuntimeCommittedReceiptQueryError.corruptAuthority
        }
        if let quarantine = quarantineRows.first {
            let sourceEventIDValid: Bool = switch quarantine.value(named: "source_event_id") {
            case .null?: true
            case let .text(value)?: value.isEmpty == false
            default: false
            }
            let sourceEventSequenceValid: Bool = switch quarantine.value(
                named: "source_event_sequence"
            ) {
            case .null?: true
            case let .integer(value)?: value > 0
            default: false
            }
            guard case let .text(occurrenceID)? = quarantine.value(named: "occurrence_id"),
                  RuntimeStoreManifestCodec.isSHA256Hex(occurrenceID),
                  case let .text(quarantineKey)? = quarantine.value(named: "quarantine_key"),
                  quarantineKey.isEmpty == false,
                  sourceEventIDValid,
                  sourceEventSequenceValid,
                  let fingerprint = RuntimeAuthorityFailureFingerprint(rawValue:
                      LocalRuntimeStorageChecksum.sha256Hex(for: Data(
                          "replay-quarantine\u{0}\(occurrenceID)\u{0}\(quarantineKey)".utf8
                      ))
                  ) else {
                throw RuntimeCommittedReceiptQueryError.corruptAuthority
            }
            return .invalidated(
                reason: .quarantineOccurrence,
                fingerprint: fingerprint
            )
        }
        let highWaterRows = try budget.query(
            """
            SELECT event_sequence, event_id, event_hash, chain_anchor_digest,
                   reconstruction_digest, verified_at_ms
            FROM runtime_replay_verified_high_water
            WHERE singleton_id = 1 LIMIT 2
            """,
            database: database
        )
        guard highWaterRows.count <= 1 else {
            throw RuntimeCommittedReceiptQueryError.corruptAuthority
        }
        guard let row = highWaterRows.first else {
            return .verificationPending
        }
        guard case let .integer(sequence)? = row.value(named: "event_sequence"), sequence > 0,
              case let .text(eventID)? = row.value(named: "event_id"),
              case let .text(eventHash)? = row.value(named: "event_hash"),
              case let .text(sourceDigest)? = row.value(named: "chain_anchor_digest"),
              case let .integer(verifiedAt)? = row.value(named: "verified_at_ms"), verifiedAt >= 0,
              RuntimeStoreManifestCodec.isSHA256Hex(sourceDigest) else {
            throw RuntimeCommittedReceiptQueryError.corruptAuthority
        }
        let cursor = RuntimeCanonicalReplayCursor(
            sequence: UInt64(sequence), eventID: eventID, eventHash: eventHash
        )
        guard cursor.isWellFormed else { throw RuntimeCommittedReceiptQueryError.corruptAuthority }
        try Task.checkCancellation()
        let anchorRows = try budget.query(
            "SELECT event_id, event_hash, occurred_at_ms FROM runtime_semantic_events WHERE sequence = ? LIMIT 2",
            bindings: [.integer(sequence)],
            database: database
        )
        guard anchorRows.count == 1,
              anchorRows[0].value(named: "event_id") == .text(eventID),
              anchorRows[0].value(named: "event_hash") == .text(eventHash),
              anchorRows[0].value(named: "occurred_at_ms") == .integer(verifiedAt) else {
            throw RuntimeCommittedReceiptQueryError.corruptAuthority
        }
        let certificateRows = try budget.query(
            """
            SELECT event_id, event_hash, source_chain_digest,
                   reconstruction_digest, certificate_digest, verified_at_ms
            FROM runtime_canonical_replay_verification_certificates
            WHERE event_sequence = ? LIMIT 2
            """,
            bindings: [.integer(sequence)],
            database: database
        )
        try Task.checkCancellation()
        switch row.value(named: "reconstruction_digest") {
        case .null?:
            guard certificateRows.isEmpty else {
                throw RuntimeCommittedReceiptQueryError.corruptAuthority
            }
            return .verificationPending
        case let .text(reconstructionDigest)?:
            guard RuntimeStoreManifestCodec.isSHA256Hex(reconstructionDigest),
                  certificateRows.count == 1, let certificate = certificateRows.first,
              certificate.value(named: "event_id") == .text(eventID),
              certificate.value(named: "event_hash") == .text(eventHash),
              certificate.value(named: "source_chain_digest") == .text(sourceDigest),
              certificate.value(named: "reconstruction_digest") == .text(reconstructionDigest),
              certificate.value(named: "verified_at_ms") == .integer(verifiedAt),
              case let .text(certificateDigest)? = certificate.value(named: "certificate_digest"),
              let source = try? SHA256Digest(hexadecimal: sourceDigest),
              let reconstruction = try? SHA256Digest(hexadecimal: reconstructionDigest),
              certificateDigest == RuntimeCanonicalReplayEngine.verificationCertificateDigest(
                  cursor: cursor,
                  sourceChainDigest: source,
                  reconstructionDigest: reconstruction,
                  verifiedAtMilliseconds: verifiedAt
              ) else {
                throw RuntimeCommittedReceiptQueryError.corruptAuthority
            }
            guard UInt64(sequence) >= core.facts.lineage.eventSequence else {
                return .verificationPending
            }
            return .verifiedThrough(eventSequence: UInt64(sequence))
        default:
            throw RuntimeCommittedReceiptQueryError.corruptAuthority
        }
    }

    private static func redactedEligibility(
        _ value: RuntimeCompensationEligibility
    ) -> RuntimeRedactedCompensationEligibility {
        switch value {
        case .available: .available
        case .confirmationRequired: .confirmationRequired
        case .expired: .expired
        case .consumed: .consumed
        case .stale: .stale
        case .pendingExternalWork: .pendingExternalWork
        case .irreversible: .irreversible
        case .unsupported: .unsupported
        case .sourceBlocked: .sourceBlocked
        case .unavailable: .unavailable
        }
    }

    private static func decodeCanonical<Value: Codable>(
        _ type: Value.Type,
        bytes: Data
    ) throws -> Value {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let value = try decoder.decode(type, from: bytes)
        guard try RuntimeCommittedReceiptCodec.encode(value) == bytes else {
            throw RuntimeCommittedReceiptQueryError.corruptAuthority
        }
        return value
    }

    private static func blockedFingerprint(
        _ reason: RuntimeReceiptSourceBlockedReason
    ) -> RuntimeAuthorityFailureFingerprint? {
        RuntimeAuthorityFailureFingerprint(
            rawValue: LocalRuntimeStorageChecksum.sha256Hex(for: Data(reason.rawValue.utf8))
        )
    }

    private static func receiptInt64(_ value: UInt64) throws -> Int64 {
        guard value <= UInt64(Int64.max) else {
            throw RuntimeCommittedReceiptQueryError.corruptAuthority
        }
        return Int64(value)
    }
}
