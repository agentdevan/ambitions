import AmbitionsRuntimeSQLite
import Foundation

struct RuntimeExternalOperationAuthorityGraph: Sendable, Equatable {
    let creation: RuntimeCanonicalExternalOperationCreation
    let current: RuntimeCanonicalExternalOperation
    let history: [RuntimeExternalOperationHistoryEntry]
    let attempts: [RuntimeExternalAttemptStart]
    let outcomes: [RuntimeExternalAttemptID: RuntimeExternalAttemptOutcomeRecord]
}

struct RuntimeExternalOperationWork: Sendable, Equatable {
    let creation: RuntimeCanonicalExternalOperationCreation
    let current: RuntimeCanonicalExternalOperation
    let attempt: RuntimeExternalAttemptStart
}

enum RuntimeExternalOperationClaimResult: Sendable, Equatable {
    case noneDue
    case claimed(RuntimeCanonicalExternalOperation)
}

enum RuntimeExternalOperationCancellationResult: Sendable, Equatable {
    case cancelled(RuntimeCanonicalExternalOperation)
    case requiresExternalCompensation(RuntimeExternalProviderReference)
    case blockedIndeterminate
    case alreadyTerminal(RuntimeCanonicalExternalOperation)
}

enum RuntimeExternalOperationCreationFactory {
    static func make(
        effect: RuntimeExternalEffectIntent,
        receipt: RuntimeAtomicCommitReceipt,
        command: AmbitionsCommand,
        createdAt: Date
    ) throws -> RuntimeCanonicalExternalOperationCreation? {
        guard case let .outbox(operationID, kind) = effect else { return nil }
        let targets = try receipt.aggregateStates.map { state -> RuntimeExternalOperationTarget in
            guard let objectID = RuntimeDomainObjectID(rawValue: state.aggregate.id.rawValue) else {
                throw RuntimeCanonicalExternalOperationError.invalidCreation
            }
            return RuntimeExternalOperationTarget(family: state.aggregate.kind, objectID: objectID)
        }.sorted()
        guard targets == Array(Set(targets)).sorted(),
              targets.isEmpty == false,
              targets.count <= RuntimeExternalOperationLimits.maximumTargets,
              command.localOnly,
              receipt.aggregateStates.allSatisfy({
                  $0.privacy == command.privacy && $0.localOnly == true
              }) else {
            throw RuntimeCanonicalExternalOperationError.invalidCreation
        }
        let title: RuntimeExternalClassifiedTitle?
        if let rawTitle = command.content.title ?? command.content.rawText {
            guard let classified = RuntimeExternalClassifiedTitle(value: rawTitle, privacy: command.privacy) else {
                throw RuntimeCanonicalExternalOperationError.invalidCreation
            }
            title = classified
        } else {
            title = nil
        }
        let providerID = RuntimeExternalProviderRouting.providerID(for: kind)
        let externalCommand: ExternalOperationCommand? = if case let .externalOperation(value) = command.typedPayload {
            value
        } else {
            nil
        }
        let action: RuntimeCanonicalExternalOperationPayload.Action =
            externalCommand?.effectiveAction == .compensateRemoval ? .compensateRemoval : .create
        let sourceOperationID = externalCommand?.sourceOperationID
        let sourceProviderReference = externalCommand?.sourceProviderReference
        let sourceReceiptID = externalCommand?.sourceReceiptID
        let compensationPlanID = externalCommand?.compensationPlanID
        let compensationPlanDigest = externalCommand?.compensationPlanDigest
        guard (action == .create && sourceOperationID == nil && sourceProviderReference == nil &&
               sourceReceiptID == nil && compensationPlanID == nil && compensationPlanDigest == nil) ||
                (action == .compensateRemoval && sourceOperationID != nil &&
                 sourceProviderReference != nil && sourceReceiptID != nil && compensationPlanID != nil &&
                 compensationPlanDigest.map(RuntimeStoreManifestCodec.isSHA256Hex) == true &&
                 sourceOperationID != operationID) else {
            throw RuntimeCanonicalExternalOperationError.invalidCreation
        }
        let creation = RuntimeCanonicalExternalOperationCreation(
            version: runtimeCanonicalExternalOperationModelVersion,
            operationID: operationID,
            commandID: receipt.commandID,
            receiptID: receipt.receiptID,
            lineage: receipt.lineage,
            kind: kind,
            payload: RuntimeCanonicalExternalOperationPayload(
                version: runtimeCanonicalExternalOperationModelVersion,
                kind: kind,
                target: command.target,
                title: action == .create ? title : nil,
                action: action,
                sourceOperationID: sourceOperationID,
                sourceProviderReference: sourceProviderReference,
                sourceReceiptID: sourceReceiptID,
                compensationPlanID: compensationPlanID,
                compensationPlanDigest: compensationPlanDigest
            ),
            targets: targets,
            privacy: command.privacy,
            localOnly: true,
            providerID: providerID,
            stableIdempotencyKey: .derive(
                operationID: operationID, commandID: receipt.commandID, kind: kind
            ),
            policyVersion: RuntimeExternalRetryPolicyAuthority.currentVersion,
            createdAt: createdAt
        )
        try RuntimeExternalOperationCodec.validate(creation)
        return creation
    }
}

extension CanonicalRuntimeStore {
    func makeCompensatingExternalOperationCommand(
        sourceReceiptID: RuntimeReceiptID,
        sourceOperationID: RuntimeExternalOperationID,
        operationID: RuntimeExternalOperationID,
        target: AmbitionsCommandTarget,
        title: String
    ) async throws -> ExternalOperationCommand {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeExternalOperationStore.requireSchema(database)
            var budget = RuntimeReceiptDecodedByteBudget(
                maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAuthenticatedGraphBudgetBytes
            )
            let receipt = try RuntimeCommittedReceiptAuthority.loadAuthenticatedGraph(
                receiptID: sourceReceiptID, budget: &budget, database: database
            )
            guard let plan = receipt.plan,
                  let summary = receipt.externalOperations.first(where: {
                      $0.operationID == sourceOperationID
                  }),
                  let source = receipt.externalOperationStates[sourceOperationID],
                  source.workflowStatus == .succeeded,
                  source.effectDisposition == .confirmedPresent,
                  let reference = source.externalReference,
                  case let .externalCompensationRequired(operationIDs) =
                    try RuntimeCommittedReceiptAuthority.externalCompensationAuthority(
                        graph: receipt, plan: plan, database: database
                    ),
                  operationIDs.contains(sourceOperationID),
                  operationID != sourceOperationID else {
                throw RuntimeCanonicalExternalOperationError.invalidCreation
            }
            return ExternalOperationCommand(
                operationID: operationID,
                kind: summary.kind,
                target: target,
                title: title,
                action: .compensateRemoval,
                sourceOperationID: sourceOperationID,
                sourceProviderReference: reference,
                sourceReceiptID: sourceReceiptID,
                compensationPlanID: plan.planID,
                compensationPlanDigest: plan.digest
            )
        }
    }

    func externalOperation(
        id: RuntimeExternalOperationID
    ) async throws -> RuntimeExternalOperationAuthorityGraph? {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeExternalOperationStore.requireSchema(database)
            return try CanonicalRuntimeExternalOperationStore.load(id: id, database: database)
        }
    }

    func claimNextExternalOperation(
        purpose: RuntimeExternalAttemptPurpose,
        owner: RuntimeExternalLeaseOwner,
        now: Date,
        leaseDuration: TimeInterval,
        tokenClient: RuntimeExternalTokenClient
    ) async throws -> RuntimeExternalOperationClaimResult {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeExternalOperationStore.requireSchema(database)
            return try CanonicalRuntimeExternalOperationStore.claimNext(
                purpose: purpose,
                owner: owner,
                now: now,
                leaseDuration: leaseDuration,
                tokenClient: tokenClient,
                database: database
            )
        }
    }

    func beginExternalOperationAttempt(
        operationID: RuntimeExternalOperationID,
        leaseToken: RuntimeExternalLeaseToken,
        attemptID: RuntimeExternalAttemptID,
        now: Date
    ) async throws -> RuntimeExternalOperationWork {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeExternalOperationStore.requireSchema(database)
            return try CanonicalRuntimeExternalOperationStore.beginAttempt(
                operationID: operationID,
                leaseToken: leaseToken,
                attemptID: attemptID,
                now: now,
                database: database
            )
        }
    }

    func recordExternalOperationOutcome(
        _ outcome: RuntimeExternalAttemptOutcomeRecord,
        leaseToken: RuntimeExternalLeaseToken,
        retryPolicy: RuntimeExternalRetryPolicy,
        jitter: RuntimeExternalJitterClient
    ) async throws -> RuntimeCanonicalExternalOperation {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeExternalOperationStore.requireSchema(database)
            return try CanonicalRuntimeExternalOperationStore.recordOutcome(
                outcome,
                leaseToken: leaseToken,
                retryPolicy: retryPolicy,
                jitter: jitter,
                database: database
            )
        }
    }

    func cancelExternalOperationBeforeEffect(
        _ operationID: RuntimeExternalOperationID,
        now: Date
    ) async throws -> RuntimeExternalOperationCancellationResult {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeExternalOperationStore.requireSchema(database)
            return try CanonicalRuntimeExternalOperationStore.cancelBeforeEffect(
                operationID, now: now, database: database
            )
        }
    }

    func recoverExpiredExternalOperationLeases(now: Date, limit: Int) async throws -> Int {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeExternalOperationStore.requireSchema(database)
            return try CanonicalRuntimeExternalOperationStore.recoverExpiredLeases(
                now: now, limit: limit, database: database
            )
        }
    }
}

enum CanonicalRuntimeExternalOperationStore {

    static func requireSchema(_ database: isolated SQLiteDatabase) throws {
        try CanonicalRuntimeExternalOperationSchemaPlan.requireIntegratedSchema(in: database)
    }

    static func persistCreation(
        _ creation: RuntimeCanonicalExternalOperationCreation,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalExternalOperation {
        try RuntimeExternalOperationCodec.validate(creation)
        let creationPayload = try RuntimeExternalOperationCodec.encodeCreation(creation)
        let creationDigest = LocalRuntimeStorageChecksum.sha256Hex(for: creationPayload)
        let createdAt = try milliseconds(creation.createdAt)
        if creation.payload.action == .compensateRemoval {
            guard let sourceID = creation.payload.sourceOperationID,
                  let sourceReference = creation.payload.sourceProviderReference,
                  let sourceReceiptID = creation.payload.sourceReceiptID,
                  let planID = creation.payload.compensationPlanID,
                  let planDigest = creation.payload.compensationPlanDigest,
                  let source = try load(id: sourceID, database: database),
                  source.creation.kind == creation.kind,
                  source.creation.providerID == creation.providerID,
                  source.creation.receiptID == sourceReceiptID,
                  source.creation.privacy == creation.privacy,
                  source.creation.localOnly && creation.localOnly,
                  source.current.workflowStatus == .succeeded,
                  source.current.effectDisposition == .confirmedPresent,
                  source.current.externalReference == sourceReference else {
                throw RuntimeCanonicalExternalOperationError.invalidCreation
            }
            let authority = try database.query(
                """
                SELECT 1 FROM runtime_compensation_plans AS p
                JOIN runtime_compensation_plan_external_operations AS po ON po.plan_id = p.plan_id
                WHERE p.plan_id = ? AND p.source_receipt_id = ? AND p.plan_digest = ?
                  AND po.operation_id = ? AND p.expires_at_ms >= ?
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_compensation_consumptions AS consumed
                      WHERE consumed.plan_id = p.plan_id OR consumed.source_receipt_id = p.source_receipt_id
                  ) LIMIT 2
                """,
                bindings: [
                    .text(planID.rawValue), .text(sourceReceiptID.rawValue),
                    .text(planDigest), .text(sourceID.rawValue), .integer(createdAt),
                ]
            )
            guard authority.count == 1 else { throw RuntimeCanonicalExternalOperationError.invalidCreation }
        }
        try database.execute(
            """
            INSERT INTO runtime_external_operation_creations(
                operation_id, command_id, receipt_id, terminal_event_sequence,
                operation_kind, operation_action, source_operation_id, source_provider_reference,
                source_receipt_id, compensation_plan_id, compensation_plan_digest,
                provider_id, stable_idempotency_key, privacy,
                local_only, policy_version, creation_version, creation_payload,
                creation_digest, created_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(creation.operationID.rawValue), .text(creation.commandID.rawValue),
                .text(creation.receiptID.rawValue), .integer(try int64(creation.lineage.eventSequence)),
                .text(creation.kind.rawValue), .text(creation.payload.action.rawValue),
                optionalText(creation.payload.sourceOperationID?.rawValue),
                optionalText(creation.payload.sourceProviderReference?.rawValue),
                optionalText(creation.payload.sourceReceiptID?.rawValue),
                optionalText(creation.payload.compensationPlanID?.rawValue),
                optionalText(creation.payload.compensationPlanDigest),
                .text(creation.providerID.rawValue),
                .text(creation.stableIdempotencyKey.rawValue), .text(creation.privacy.rawValue),
                .integer(Int64(creation.policyVersion)), .integer(Int64(creation.version)),
                .blob(creationPayload), .text(creationDigest), .integer(createdAt),
            ]
        )
        for target in creation.targets {
            try database.execute(
                "INSERT INTO runtime_external_operation_targets(operation_id, family, object_id) VALUES (?, ?, ?)",
                bindings: [
                    .text(creation.operationID.rawValue), .text(target.family.rawValue),
                    .text(target.objectID.rawValue),
                ]
            )
        }
        let current = RuntimeCanonicalExternalOperation(
            operationID: creation.operationID,
            creationDigest: creationDigest,
            providerID: creation.providerID,
            workflowStatus: .pending,
            effectDisposition: .notAttempted,
            statusVersion: 1,
            policyVersion: creation.policyVersion,
            attemptCount: 0,
            nextAttemptAt: nil,
            claimPurpose: nil,
            lease: nil,
            externalReference: nil,
            reasonCode: nil,
            reasonFingerprint: nil,
            createdAt: creation.createdAt,
            updatedAt: creation.createdAt
        )
        try insertCurrent(current, database: database)
        let history = try RuntimeExternalOperationCodec.makeHistory(
            operationID: creation.operationID,
            from: nil,
            to: current,
            attemptID: nil,
            occurredAt: creation.createdAt
        )
        try insertHistory(history, database: database)
        return current
    }

    static func load(
        id: RuntimeExternalOperationID,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeExternalOperationAuthorityGraph? {
        var budget = RuntimeExternalOperationDecodedByteBudget()
        return try RuntimeExternalOperationGraphAuthority.loadAuthenticated(
            operationID: id,
            budget: &budget,
            database: database
        )
    }

    static func claimNext(
        purpose: RuntimeExternalAttemptPurpose,
        owner: RuntimeExternalLeaseOwner,
        now: Date,
        leaseDuration: TimeInterval,
        tokenClient: RuntimeExternalTokenClient,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeExternalOperationClaimResult {
        let nowMS = try milliseconds(now)
        guard leaseDuration.isFinite, leaseDuration > 0,
              leaseDuration <= RuntimeExternalOperationLimits.maximumLeaseSeconds else {
            throw RuntimeCanonicalExternalOperationError.invalidTransition
        }
        guard purpose == .execute || purpose == .reconcile else {
            throw RuntimeCanonicalExternalOperationError.invalidTransition
        }
        let selectionSQL: String
        let selectionBindings: [SQLiteBinding]
        if purpose == .execute {
            selectionSQL = """
            SELECT operation_id FROM runtime_external_operation_current
            WHERE (workflow_status = 'pending')
               OR (workflow_status = 'retry_scheduled' AND next_attempt_at_ms <= ?)
               OR (workflow_status = 'claimed' AND lease_expires_at_ms <= ?
                   AND NOT EXISTS (
                       SELECT 1 FROM runtime_external_operation_attempt_starts AS a
                       WHERE a.operation_id = runtime_external_operation_current.operation_id
                         AND a.source_status_version = runtime_external_operation_current.status_version
                   ))
            ORDER BY CASE workflow_status
                WHEN 'claimed' THEN 0 WHEN 'retry_scheduled' THEN 1 ELSE 2 END,
                COALESCE(next_attempt_at_ms, updated_at_ms), operation_id
            LIMIT 1
            """
            selectionBindings = [.integer(nowMS), .integer(nowMS)]
        } else {
            selectionSQL = """
            SELECT operation_id FROM runtime_external_operation_current
            WHERE workflow_status = 'reconciliation_required'
              AND (lease_expires_at_ms IS NULL OR lease_expires_at_ms <= ?)
            ORDER BY updated_at_ms, operation_id LIMIT 1
            """
            selectionBindings = [.integer(nowMS)]
        }
        let rows = try database.query(
            selectionSQL,
            bindings: selectionBindings,
            maximumDecodedBytes: 4_096
        )
        guard rows.count <= 1 else { throw RuntimeCanonicalExternalOperationError.corruptAuthority }
        guard let row = rows.first,
              case let .text(rawID)? = row.value(named: "operation_id"),
              let id = RuntimeExternalOperationID(rawValue: rawID),
              let graph = try load(id: id, database: database) else { return .noneDue }
        let prior = graph.current
        guard prior.workflowStatus == .pending || prior.workflowStatus == .retryScheduled ||
                prior.workflowStatus == .reconciliationRequired || prior.workflowStatus == .claimed else {
            throw RuntimeCanonicalExternalOperationError.invalidTransition
        }
        let expectedPurpose: RuntimeExternalAttemptPurpose = prior.workflowStatus == .reconciliationRequired ? .reconcile : .execute
        guard expectedPurpose == purpose else {
            throw RuntimeCanonicalExternalOperationError.invalidTransition
        }
        if prior.statusVersion > UInt64(RuntimeExternalOperationLimits.maximumTransitions - 3) {
            let reason = RuntimeExternalReasonCode.transitionBudgetExhausted
            let disposition = prior.effectDisposition
            let terminalStatus: RuntimeExternalWorkflowStatus = disposition == .indeterminate
                ? .operatorRequired : .permanentFailure
            let terminal = copy(
                prior,
                status: terminalStatus,
                disposition: disposition,
                statusVersion: prior.statusVersion + 1,
                attemptCount: prior.attemptCount,
                nextAttemptAt: nil,
                claimPurpose: nil,
                lease: nil,
                externalReference: disposition == .confirmedPresent ? prior.externalReference : nil,
                reasonCode: reason,
                reasonFingerprint: .redacted(code: reason, providerID: prior.providerID),
                updatedAt: now
            )
            try persistTransition(from: prior, to: terminal, attemptID: nil, database: database)
            return .noneDue
        }
        let purposeAttempts = graph.attempts.filter { $0.purpose == purpose }.count
        if purpose == .reconcile,
           purposeAttempts >= RuntimeExternalOperationLimits.maximumReconciliationAttempts {
            let reason = RuntimeExternalReasonCode.retryLimitReached
            let terminal = copy(
                prior,
                status: .operatorRequired,
                disposition: .indeterminate,
                statusVersion: prior.statusVersion + 1,
                attemptCount: prior.attemptCount,
                nextAttemptAt: nil,
                claimPurpose: nil,
                lease: nil,
                externalReference: prior.externalReference,
                reasonCode: reason,
                reasonFingerprint: .redacted(code: reason, providerID: prior.providerID),
                updatedAt: now
            )
            try persistTransition(from: prior, to: terminal, attemptID: nil, database: database)
            return .noneDue
        }
        let durationMSDouble = (leaseDuration * 1_000).rounded()
        guard durationMSDouble >= 1, durationMSDouble < 9_000_000_000_000_000_000 else {
            throw RuntimeCanonicalExternalOperationError.invalidTransition
        }
        let durationMS = Int64(durationMSDouble)
        let (expiresAtMS, overflow) = nowMS.addingReportingOverflow(durationMS)
        guard overflow == false else { throw RuntimeCanonicalExternalOperationError.invalidTransition }
        let lease = RuntimeExternalLease(
            token: tokenClient.nextLeaseToken(id, prior.statusVersion + 1),
            owner: owner,
            acquiredAt: now,
            expiresAt: Date(timeIntervalSince1970: Double(expiresAtMS) / 1_000)
        )
        let next = copy(
            prior,
            status: prior.workflowStatus == .reconciliationRequired ? .reconciliationRequired : .claimed,
            disposition: prior.effectDisposition,
            statusVersion: prior.statusVersion + 1,
            attemptCount: prior.attemptCount,
            nextAttemptAt: nil,
            claimPurpose: expectedPurpose,
            lease: lease,
            externalReference: prior.externalReference,
            reasonCode: prior.workflowStatus == .reconciliationRequired ? prior.reasonCode : nil,
            reasonFingerprint: prior.workflowStatus == .reconciliationRequired ? prior.reasonFingerprint : nil,
            updatedAt: now
        )
        try persistTransition(from: prior, to: next, attemptID: nil, database: database)
        return .claimed(next)
    }

    static func beginAttempt(
        operationID: RuntimeExternalOperationID,
        leaseToken: RuntimeExternalLeaseToken,
        attemptID: RuntimeExternalAttemptID,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeExternalOperationWork {
        guard let graph = try load(id: operationID, database: database),
              let lease = graph.current.lease,
              lease.token == leaseToken,
              lease.expiresAt > now,
              let purpose = graph.current.claimPurpose,
              graph.current.attemptCount < RuntimeExternalOperationLimits.maximumAttempts else {
            throw RuntimeCanonicalExternalOperationError.staleLease
        }
        let prior = graph.current
        guard (prior.workflowStatus == .claimed && purpose == .execute) ||
                (prior.workflowStatus == .reconciliationRequired && purpose == .reconcile) else {
            throw RuntimeCanonicalExternalOperationError.invalidTransition
        }
        let purposeCount = graph.attempts.filter { $0.purpose == purpose }.count
        let purposeLimit = purpose == .execute
            ? RuntimeExternalOperationLimits.maximumExecutionAttempts
            : RuntimeExternalOperationLimits.maximumReconciliationAttempts
        guard purposeCount < purposeLimit else {
            throw RuntimeCanonicalExternalOperationError.retryExhausted
        }
        let attemptNumber = prior.attemptCount + 1
        let requestSeed = [
            operationID.rawValue, attemptID.rawValue, purpose.rawValue,
            String(prior.statusVersion), graph.creation.stableIdempotencyKey.rawValue,
            prior.creationDigest, graph.creation.payload.action.rawValue,
            graph.creation.payload.sourceOperationID?.rawValue ?? "",
            graph.creation.payload.sourceProviderReference?.rawValue ?? "",
        ].joined(separator: "\u{0}")
        let attempt = RuntimeExternalAttemptStart(
            version: runtimeCanonicalExternalOperationModelVersion,
            attemptID: attemptID,
            operationID: operationID,
            attemptNumber: attemptNumber,
            purpose: purpose,
            action: graph.creation.payload.action,
            sourceStatusVersion: prior.statusVersion,
            policyVersion: graph.creation.policyVersion,
            providerID: graph.creation.providerID,
            kind: graph.creation.kind,
            lease: lease,
            stableIdempotencyKey: graph.creation.stableIdempotencyKey,
            requestDigest: LocalRuntimeStorageChecksum.sha256Hex(for: Data(requestSeed.utf8)),
            invocationAuthorizedAt: now,
            startedAt: now
        )
        try insertAttempt(attempt, database: database)
        let next = copy(
            prior,
            status: purpose == .execute ? .executing : .reconciliationRequired,
            disposition: prior.effectDisposition,
            statusVersion: prior.statusVersion + 1,
            attemptCount: attemptNumber,
            nextAttemptAt: nil,
            claimPurpose: purpose,
            lease: lease,
            externalReference: prior.externalReference,
            reasonCode: prior.reasonCode,
            reasonFingerprint: prior.reasonFingerprint,
            updatedAt: now
        )
        try persistTransition(from: prior, to: next, attemptID: attemptID, database: database)
        return RuntimeExternalOperationWork(creation: graph.creation, current: next, attempt: attempt)
    }

    static func recordOutcome(
        _ outcome: RuntimeExternalAttemptOutcomeRecord,
        leaseToken: RuntimeExternalLeaseToken,
        retryPolicy: RuntimeExternalRetryPolicy,
        jitter: RuntimeExternalJitterClient,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalExternalOperation {
        try RuntimeExternalOperationCodec.validate(outcome)
        guard outcome.kind != .leaseExpiredWithoutOutcome else {
            throw RuntimeCanonicalExternalOperationError.invalidTransition
        }
        guard let graph = try load(id: outcome.operationID, database: database),
              let attempt = graph.attempts.last,
              attempt.attemptID == outcome.attemptID,
              graph.outcomes[outcome.attemptID] == nil,
              let lease = graph.current.lease,
              lease.token == leaseToken,
              outcome.recordedAt >= attempt.startedAt,
              outcome.recordedAt <= lease.expiresAt else {
            throw RuntimeCanonicalExternalOperationError.staleLease
        }
        let resolvedRetryPolicy = try RuntimeExternalRetryPolicyAuthority.requireExact(
            retryPolicy,
            persistedVersion: graph.creation.policyVersion
        )
        guard attempt.policyVersion == graph.creation.policyVersion,
              graph.current.policyVersion == graph.creation.policyVersion else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        guard RuntimeExternalOperationCodec.permitsOutcome(
            action: graph.creation.payload.action,
            purpose: attempt.purpose,
            kind: outcome.kind
        ) else {
            throw RuntimeCanonicalExternalOperationError.invalidTransition
        }
        try insertOutcome(outcome, database: database)
        let prior = graph.current
        let destination = try destination(
            after: outcome,
            current: prior,
            providerID: graph.creation.providerID,
            executionAttemptCount: graph.attempts.filter { $0.purpose == .execute }.count,
            reconciliationAttemptCount: graph.attempts.filter { $0.purpose == .reconcile }.count,
            retryPolicy: resolvedRetryPolicy,
            jitter: jitter
        )
        try persistTransition(
            from: prior, to: destination, attemptID: outcome.attemptID, database: database
        )
        return destination
    }

    static func cancelBeforeEffect(
        _ operationID: RuntimeExternalOperationID,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeExternalOperationCancellationResult {
        guard let graph = try load(id: operationID, database: database) else {
            throw RuntimeCanonicalExternalOperationError.corruptAuthority
        }
        guard graph.creation.payload.action == .create else {
            throw RuntimeCanonicalExternalOperationError.explicitExternalCompensationRequired([operationID])
        }
        let prior = graph.current
        if prior.effectDisposition == .confirmedPresent {
            guard let reference = prior.externalReference else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
            return .requiresExternalCompensation(reference)
        }
        if prior.effectDisposition == .indeterminate { return .blockedIndeterminate }
        if prior.workflowStatus.isTerminal { return .alreadyTerminal(prior) }
        guard prior.workflowStatus == .pending || prior.workflowStatus == .retryScheduled else {
            throw RuntimeCanonicalExternalOperationError.invalidTransition
        }
        let reason = RuntimeExternalReasonCode.cancelledBeforeEffect
        let next = copy(
            prior,
            status: .cancelled,
            disposition: prior.effectDisposition,
            statusVersion: prior.statusVersion + 1,
            attemptCount: prior.attemptCount,
            nextAttemptAt: nil,
            claimPurpose: nil,
            lease: nil,
            externalReference: nil,
            reasonCode: reason,
            reasonFingerprint: .redacted(code: reason, providerID: prior.providerID),
            updatedAt: now
        )
        try persistTransition(from: prior, to: next, attemptID: nil, database: database)
        return .cancelled(next)
    }

    /// Called only from the already-open T12 compensation transaction. The
    /// exact authenticated state is rechecked before a CAS transition, so no
    /// separate cancellation transaction can create a compensation TOCTOU.
    static func cancelForCompensation(
        expected: RuntimeCanonicalExternalOperation,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalExternalOperation {
        guard let graph = try load(id: expected.operationID, database: database),
              graph.creation.payload.action == .create,
              graph.current == expected else {
            throw RuntimeCanonicalExternalOperationError.compensationBlocked([
                expected.operationID,
            ])
        }
        guard (expected.workflowStatus == .pending && expected.effectDisposition == .notAttempted) ||
                (expected.workflowStatus == .retryScheduled &&
                 expected.effectDisposition == .confirmedAbsent) else {
            if expected.effectDisposition == .confirmedPresent {
                throw RuntimeCanonicalExternalOperationError.explicitExternalCompensationRequired([
                    expected.operationID,
                ])
            }
            throw RuntimeCanonicalExternalOperationError.compensationBlocked([
                expected.operationID,
            ])
        }
        let reason = RuntimeExternalReasonCode.cancelledBeforeEffect
        let cancelled = copy(
            expected,
            status: .cancelled,
            disposition: expected.effectDisposition,
            statusVersion: expected.statusVersion + 1,
            attemptCount: expected.attemptCount,
            nextAttemptAt: nil,
            claimPurpose: nil,
            lease: nil,
            externalReference: nil,
            reasonCode: reason,
            reasonFingerprint: .redacted(code: reason, providerID: expected.providerID),
            updatedAt: now
        )
        try persistTransition(from: expected, to: cancelled, attemptID: nil, database: database)
        return cancelled
    }

    static func recoverExpiredLeases(
        now: Date,
        limit: Int,
        database: isolated SQLiteDatabase
    ) throws -> Int {
        guard limit > 0, limit <= RuntimeExternalOperationLimits.maximumPageSize else {
            throw RuntimeCanonicalExternalOperationError.firstRowExceedsBound
        }
        let rows = try database.query(
            """
            SELECT operation_id FROM runtime_external_operation_current
            WHERE workflow_status IN ('executing', 'reconciliation_required')
              AND lease_expires_at_ms IS NOT NULL AND lease_expires_at_ms <= ?
            ORDER BY lease_expires_at_ms, operation_id LIMIT ?
            """,
            bindings: [.integer(try milliseconds(now)), .integer(Int64(limit + 1))],
            maximumDecodedBytes: 16_384
        )
        guard rows.count <= limit else { throw RuntimeCanonicalExternalOperationError.firstRowExceedsBound }
        var changed = 0
        for row in rows {
            guard case let .text(rawID)? = row.value(named: "operation_id"),
                  let id = RuntimeExternalOperationID(rawValue: rawID),
                  let graph = try load(id: id, database: database) else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
            guard let attempt = graph.attempts.last,
                  graph.outcomes[attempt.attemptID] == nil else { continue }
            let prior = graph.current
            let reason = RuntimeExternalReasonCode.leaseExpiredAfterAttemptStart
            let inferredOutcome = RuntimeExternalOperationCodec.leaseExpiryOutcome(
                attemptID: attempt.attemptID,
                operationID: id,
                providerID: graph.creation.providerID,
                at: now
            )
            try insertOutcome(inferredOutcome, database: database)
            let next = copy(
                prior,
                status: .reconciliationRequired,
                disposition: .indeterminate,
                statusVersion: prior.statusVersion + 1,
                attemptCount: prior.attemptCount,
                nextAttemptAt: nil,
                claimPurpose: nil,
                lease: nil,
                externalReference: prior.externalReference,
                reasonCode: reason,
                reasonFingerprint: .redacted(code: reason, providerID: prior.providerID),
                updatedAt: now
            )
            try persistTransition(from: prior, to: next, attemptID: attempt.attemptID, database: database)
            changed += 1
        }
        return changed
    }

    private static func destination(
        after outcome: RuntimeExternalAttemptOutcomeRecord,
        current: RuntimeCanonicalExternalOperation,
        providerID: RuntimeExternalProviderID,
        executionAttemptCount: Int,
        reconciliationAttemptCount: Int,
        retryPolicy: RuntimeExternalRetryPolicy,
        jitter: RuntimeExternalJitterClient
    ) throws -> RuntimeCanonicalExternalOperation {
        let status: RuntimeExternalWorkflowStatus
        var disposition = outcome.effectDisposition
        var nextAttemptAt: Date?
        var reason = outcome.reasonCode
        switch outcome.kind {
        case .confirmedSuccess, .confirmedPresence, .confirmedCancellation,
             .reconciledCancellationAbsent:
            status = .succeeded
        case .retryableBeforeEffect, .cancellationRetryableBeforeEffect,
             .cancellationSourceStillPresent, .confirmedAbsence:
            switch retryPolicy.decision(
                afterAttempt: executionAttemptCount,
                now: outcome.recordedAt,
                deterministicUnitInterval: jitter.unitInterval(current.operationID, current.attemptCount)
            ) {
            case let .schedule(due):
                status = .retryScheduled
                nextAttemptAt = due
                reason = .retryableBeforeEffect
            case .exhausted:
                status = .permanentFailure
                reason = .retryLimitReached
            case .invalidInput:
                throw RuntimeCanonicalExternalOperationError.invalidTransition
            }
        case .rejectedBeforeEffect, .cancellationUnsupported, .permissionUnavailableBeforeEffect:
            status = .permanentFailure
        case .indeterminate, .ambiguousReconciliation:
            if outcome.kind == .ambiguousReconciliation,
               reconciliationAttemptCount >= RuntimeExternalOperationLimits.maximumReconciliationAttempts {
                status = .operatorRequired
                disposition = .indeterminate
                reason = .retryLimitReached
            } else {
                status = .reconciliationRequired
                disposition = .indeterminate
            }
        case .leaseExpiredWithoutOutcome:
            status = .reconciliationRequired
            disposition = .indeterminate
        case .incompatibleProviderState:
            status = .permanentFailure
            disposition = .indeterminate
        }
        let fingerprint = reason.map { RuntimeExternalReasonFingerprint.redacted(code: $0, providerID: providerID) }
        let retainedReference: RuntimeExternalProviderReference? = switch status {
        case .cancelled, .retryScheduled: nil
        case .permanentFailure where disposition == .confirmedAbsent || disposition == .notAttempted: nil
        default: outcome.externalReference ?? current.externalReference
        }
        return copy(
            current,
            status: status,
            disposition: disposition,
            statusVersion: current.statusVersion + 1,
            attemptCount: current.attemptCount,
            nextAttemptAt: nextAttemptAt,
            claimPurpose: nil,
            lease: nil,
            externalReference: retainedReference,
            reasonCode: reason,
            reasonFingerprint: fingerprint,
            updatedAt: outcome.recordedAt
        )
    }

    private static func persistTransition(
        from: RuntimeCanonicalExternalOperation,
        to: RuntimeCanonicalExternalOperation,
        attemptID: RuntimeExternalAttemptID?,
        database: isolated SQLiteDatabase
    ) throws {
        try RuntimeExternalOperationCodec.validate(from)
        try RuntimeExternalOperationCodec.validate(to)
        guard from.statusVersion < UInt64(RuntimeExternalOperationLimits.maximumTransitions),
              RuntimeExternalOperationCodec.validTransition(from: from, to: to, attemptID: attemptID) else {
            throw RuntimeCanonicalExternalOperationError.invalidTransition
        }
        let history = try RuntimeExternalOperationCodec.makeHistory(
            operationID: from.operationID,
            from: from,
            to: to,
            attemptID: attemptID,
            occurredAt: to.updatedAt
        )
        try insertHistory(history, database: database)
        try insertTransitionInvalidation(history, database: database)
        let payload = try RuntimeExternalOperationCodec.encodeCurrent(to)
        let result = try database.execute(
            """
            UPDATE runtime_external_operation_current SET
                workflow_status = ?, effect_disposition = ?, status_version = ?,
                policy_version = ?, attempt_count = ?, next_attempt_at_ms = ?, claim_purpose = ?,
                lease_token = ?, lease_owner = ?, lease_acquired_at_ms = ?, lease_expires_at_ms = ?,
                external_reference = ?, reason_code = ?, reason_fingerprint = ?,
                state_payload = ?, state_digest = ?, updated_at_ms = ?
            WHERE operation_id = ? AND status_version = ?
            """,
            bindings: try currentBindings(to, payload: payload) + [
                .text(from.operationID.rawValue), .integer(try int64(from.statusVersion)),
            ]
        )
        guard result.changedRowCount == 1 else { throw RuntimeCanonicalExternalOperationError.staleLease }
    }

    private static func insertCurrent(
        _ value: RuntimeCanonicalExternalOperation,
        database: isolated SQLiteDatabase
    ) throws {
        let payload = try RuntimeExternalOperationCodec.encodeCurrent(value)
        try database.execute(
            """
            INSERT INTO runtime_external_operation_current(
                operation_id, creation_digest, provider_id, workflow_status,
                effect_disposition, status_version, policy_version, attempt_count,
                next_attempt_at_ms, claim_purpose, lease_token, lease_owner,
                lease_acquired_at_ms, lease_expires_at_ms, external_reference,
                reason_code, reason_fingerprint, state_payload, state_digest,
                created_at_ms, updated_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(value.operationID.rawValue), .text(value.creationDigest),
                .text(value.providerID.rawValue),
            ] + (try currentBindings(value, payload: payload)) + [.integer(try milliseconds(value.createdAt))]
        )
    }

    private static func currentBindings(
        _ value: RuntimeCanonicalExternalOperation,
        payload: Data
    ) throws -> [SQLiteBinding] {
        [
            .text(value.workflowStatus.rawValue), .text(value.effectDisposition.rawValue),
            .integer(Int64(value.statusVersion)), .integer(Int64(value.policyVersion)),
            .integer(Int64(value.attemptCount)), try optionalInteger(value.nextAttemptAt),
            optionalText(value.claimPurpose?.rawValue), optionalText(value.lease?.token.rawValue),
            optionalText(value.lease?.owner.rawValue), try optionalInteger(value.lease?.acquiredAt),
            try optionalInteger(value.lease?.expiresAt), optionalText(value.externalReference?.rawValue),
            optionalText(value.reasonCode?.rawValue), optionalText(value.reasonFingerprint?.rawValue),
            .blob(payload), .text(LocalRuntimeStorageChecksum.sha256Hex(for: payload)),
            .integer(try milliseconds(value.updatedAt)),
        ]
    }

    private static func insertHistory(
        _ value: RuntimeExternalOperationHistoryEntry,
        database: isolated SQLiteDatabase
    ) throws {
        let payload = try RuntimeExternalOperationCodec.encodeHistory(value)
        let transition = value.transition
        try database.execute(
            """
            INSERT INTO runtime_external_operation_history(
                history_id, operation_id, status_version, from_workflow_status,
                from_effect_disposition, from_state_digest, to_workflow_status,
                to_effect_disposition, to_state_digest, attempt_id,
                transition_version, transition_payload, transition_payload_digest,
                transition_digest, occurred_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(value.historyID.rawValue), .text(transition.operationID.rawValue),
                .integer(Int64(transition.toState.statusVersion)),
                optionalText(transition.fromState?.workflowStatus.rawValue),
                optionalText(transition.fromState?.effectDisposition.rawValue),
                optionalText(transition.fromStateDigest), .text(transition.toState.workflowStatus.rawValue),
                .text(transition.toState.effectDisposition.rawValue), .text(transition.toStateDigest),
                optionalText(transition.attemptID?.rawValue), .integer(Int64(transition.version)),
                .blob(payload), .text(LocalRuntimeStorageChecksum.sha256Hex(for: payload)),
                .text(value.transitionDigest), .integer(try milliseconds(transition.occurredAt)),
            ]
        )
    }

    private static func insertAttempt(
        _ value: RuntimeExternalAttemptStart,
        database: isolated SQLiteDatabase
    ) throws {
        let payload = try RuntimeExternalOperationCodec.encodeAttemptStart(value)
        try database.execute(
            """
            INSERT INTO runtime_external_operation_attempt_starts(
                attempt_id, operation_id, attempt_number, purpose, operation_action,
                source_status_version,
                policy_version, provider_id, operation_kind, lease_token, lease_owner,
                lease_acquired_at_ms, lease_expires_at_ms, stable_idempotency_key,
                request_digest, start_version, start_payload, start_digest, started_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(value.attemptID.rawValue), .text(value.operationID.rawValue),
                .integer(Int64(value.attemptNumber)), .text(value.purpose.rawValue),
                .text(value.action.rawValue),
                .integer(Int64(value.sourceStatusVersion)), .integer(Int64(value.policyVersion)),
                .text(value.providerID.rawValue), .text(value.kind.rawValue),
                .text(value.lease.token.rawValue), .text(value.lease.owner.rawValue),
                .integer(try milliseconds(value.lease.acquiredAt)),
                .integer(try milliseconds(value.lease.expiresAt)),
                .text(value.stableIdempotencyKey.rawValue), .text(value.requestDigest),
                .integer(Int64(value.version)), .blob(payload),
                .text(LocalRuntimeStorageChecksum.sha256Hex(for: payload)),
                .integer(try milliseconds(value.startedAt)),
            ]
        )
    }

    private static func insertOutcome(
        _ value: RuntimeExternalAttemptOutcomeRecord,
        database: isolated SQLiteDatabase
    ) throws {
        let payload = try RuntimeExternalOperationCodec.encodeOutcome(value)
        try database.execute(
            """
            INSERT INTO runtime_external_operation_attempt_outcomes(
                attempt_id, operation_id, outcome_kind, effect_disposition,
                external_reference, reason_code, reason_fingerprint,
                outcome_version, outcome_payload, outcome_digest, recorded_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(value.attemptID.rawValue), .text(value.operationID.rawValue),
                .text(value.kind.rawValue), .text(value.effectDisposition.rawValue),
                optionalText(value.externalReference?.rawValue), optionalText(value.reasonCode?.rawValue),
                optionalText(value.reasonFingerprint?.rawValue), .integer(Int64(value.version)),
                .blob(payload), .text(LocalRuntimeStorageChecksum.sha256Hex(for: payload)),
                .integer(try milliseconds(value.recordedAt)),
            ]
        )
    }

    private static func insertTransitionInvalidation(
        _ history: RuntimeExternalOperationHistoryEntry,
        database: isolated SQLiteDatabase
    ) throws {
        let stableID = LocalRuntimeStorageChecksum.sha256Hex(
            for: Data("external-transition-invalidation\u{0}\(history.historyID.rawValue)".utf8)
        )
        let payload = try RuntimeExternalOperationCodec.encodeHistory(history)
        try database.execute(
            """
            INSERT INTO runtime_external_operation_transition_invalidations(
                invalidation_id, operation_id, status_version, history_id,
                payload, payload_digest, created_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(stableID), .text(history.transition.operationID.rawValue),
                .integer(Int64(history.transition.toState.statusVersion)),
                .text(history.historyID.rawValue), .blob(payload),
                .text(LocalRuntimeStorageChecksum.sha256Hex(for: payload)),
                .integer(try milliseconds(history.transition.occurredAt)),
            ]
        )
    }

    private static func copy(
        _ value: RuntimeCanonicalExternalOperation,
        status: RuntimeExternalWorkflowStatus,
        disposition: RuntimeExternalEffectDisposition,
        statusVersion: UInt64,
        attemptCount: Int,
        nextAttemptAt: Date?,
        claimPurpose: RuntimeExternalAttemptPurpose?,
        lease: RuntimeExternalLease?,
        externalReference: RuntimeExternalProviderReference?,
        reasonCode: RuntimeExternalReasonCode?,
        reasonFingerprint: RuntimeExternalReasonFingerprint?,
        updatedAt: Date
    ) -> RuntimeCanonicalExternalOperation {
        RuntimeCanonicalExternalOperation(
            operationID: value.operationID,
            creationDigest: value.creationDigest,
            providerID: value.providerID,
            workflowStatus: status,
            effectDisposition: disposition,
            statusVersion: statusVersion,
            policyVersion: value.policyVersion,
            attemptCount: attemptCount,
            nextAttemptAt: nextAttemptAt,
            claimPurpose: claimPurpose,
            lease: lease,
            externalReference: externalReference,
            reasonCode: reasonCode,
            reasonFingerprint: reasonFingerprint,
            createdAt: value.createdAt,
            updatedAt: updatedAt
        )
    }

    private static func optionalText(_ value: String?) -> SQLiteBinding {
        value.map(SQLiteBinding.text) ?? .null
    }

    private static func optionalInteger(_ date: Date?) throws -> SQLiteBinding {
        guard let date else { return .null }
        return .integer(try milliseconds(date))
    }

    private static func milliseconds(_ date: Date) throws -> Int64 {
        let value = date.timeIntervalSince1970 * 1_000
        guard value.isFinite, value >= 0,
              value < 9_000_000_000_000_000_000,
              value.rounded() == value else {
            throw RuntimeCanonicalExternalOperationError.invalidTransition
        }
        return Int64(value)
    }

    private static func int64(_ value: UInt64) throws -> Int64 {
        guard value <= UInt64(Int64.max) else { throw RuntimeCanonicalExternalOperationError.corruptAuthority }
        return Int64(value)
    }
}
