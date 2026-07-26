import Foundation

enum RuntimeExternalOperationCodecError: Error, Sendable, Equatable {
    case corrupt
    case futureVersion
    case nonCanonical
    case boundsExceeded
    case invalidInvariant
}

enum RuntimeExternalOperationCodec {
    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return encoder
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }

    static func encodeCreation(_ value: RuntimeCanonicalExternalOperationCreation) throws -> Data {
        try validate(value)
        return try bounded(encodeCanonical(value), maximum: RuntimeExternalOperationLimits.maximumCreationBytes)
    }

    static func decodeCreation(_ bytes: Data) throws -> RuntimeCanonicalExternalOperationCreation {
        guard bytes.count <= RuntimeExternalOperationLimits.maximumCreationBytes else { throw RuntimeExternalOperationCodecError.boundsExceeded }
        let value: RuntimeCanonicalExternalOperationCreation = try decodeCanonical(bytes)
        try validate(value)
        return value
    }

    static func creationDigest(_ value: RuntimeCanonicalExternalOperationCreation) throws -> String {
        LocalRuntimeStorageChecksum.sha256Hex(for: try encodeCreation(value))
    }

    static func encodeCurrent(_ value: RuntimeCanonicalExternalOperation) throws -> Data {
        try validate(value)
        return try bounded(encodeCanonical(value), maximum: RuntimeExternalOperationLimits.maximumCurrentStateBytes)
    }

    static func decodeCurrent(_ bytes: Data) throws -> RuntimeCanonicalExternalOperation {
        guard bytes.count <= RuntimeExternalOperationLimits.maximumCurrentStateBytes else { throw RuntimeExternalOperationCodecError.boundsExceeded }
        let value: RuntimeCanonicalExternalOperation = try decodeCanonical(bytes)
        try validate(value)
        return value
    }

    static func stateDigest(_ value: RuntimeCanonicalExternalOperation) throws -> String {
        LocalRuntimeStorageChecksum.sha256Hex(for: try encodeCurrent(value))
    }

    static func encodeAttemptStart(_ value: RuntimeExternalAttemptStart) throws -> Data {
        try validate(value)
        return try bounded(encodeCanonical(value), maximum: RuntimeExternalOperationLimits.maximumAttemptStartBytes)
    }

    static func decodeAttemptStart(_ bytes: Data) throws -> RuntimeExternalAttemptStart {
        guard bytes.count <= RuntimeExternalOperationLimits.maximumAttemptStartBytes else { throw RuntimeExternalOperationCodecError.boundsExceeded }
        let value: RuntimeExternalAttemptStart = try decodeCanonical(bytes)
        try validate(value)
        return value
    }

    static func encodeOutcome(_ value: RuntimeExternalAttemptOutcomeRecord) throws -> Data {
        try validate(value)
        return try bounded(encodeCanonical(value), maximum: RuntimeExternalOperationLimits.maximumAttemptOutcomeBytes)
    }

    static func decodeOutcome(_ bytes: Data) throws -> RuntimeExternalAttemptOutcomeRecord {
        guard bytes.count <= RuntimeExternalOperationLimits.maximumAttemptOutcomeBytes else { throw RuntimeExternalOperationCodecError.boundsExceeded }
        let value: RuntimeExternalAttemptOutcomeRecord = try decodeCanonical(bytes)
        try validate(value)
        return value
    }

    static func encodeHistory(_ value: RuntimeExternalOperationHistoryEntry) throws -> Data {
        try validate(value)
        return try bounded(encodeCanonical(value), maximum: RuntimeExternalOperationLimits.maximumHistoryBytes)
    }

    static func decodeHistory(_ bytes: Data) throws -> RuntimeExternalOperationHistoryEntry {
        guard bytes.count <= RuntimeExternalOperationLimits.maximumHistoryBytes else { throw RuntimeExternalOperationCodecError.boundsExceeded }
        let value: RuntimeExternalOperationHistoryEntry = try decodeCanonical(bytes)
        try validate(value)
        return value
    }

    static func validate(_ value: RuntimeCanonicalExternalOperationCreation) throws {
        let retryPolicy = try RuntimeExternalRetryPolicyAuthority.resolve(version: value.policyVersion)
        guard value.version == runtimeCanonicalExternalOperationModelVersion,
              value.payload.version == runtimeCanonicalExternalOperationModelVersion,
              value.payload.kind == value.kind,
              value.targets.isEmpty == false,
              value.targets.count <= RuntimeExternalOperationLimits.maximumTargets,
              value.targets == Array(Set(value.targets)).sorted(),
              value.localOnly,
              value.policyVersion == retryPolicy.version,
              value.providerID == RuntimeExternalProviderRouting.providerID(for: value.kind),
              value.stableIdempotencyKey == .derive(
                  operationID: value.operationID, commandID: value.commandID, kind: value.kind
              ),
              isMillisecondNormalized(value.createdAt),
              value.lineage.eventSequence > 0,
              RuntimeStoreManifestCodec.isSHA256Hex(value.lineage.eventHash),
              value.payload.title.map({ $0.privacy == value.privacy }) ?? true,
              ((value.payload.action == .create && value.payload.sourceOperationID == nil &&
                value.payload.sourceProviderReference == nil && value.payload.sourceReceiptID == nil &&
                value.payload.compensationPlanID == nil && value.payload.compensationPlanDigest == nil) ||
               (value.payload.action == .compensateRemoval &&
                value.payload.sourceOperationID != nil &&
                value.payload.sourceOperationID != value.operationID &&
                value.payload.sourceProviderReference != nil && value.payload.sourceReceiptID != nil &&
                value.payload.compensationPlanID != nil &&
                value.payload.compensationPlanDigest.map(RuntimeStoreManifestCodec.isSHA256Hex) == true)) else {
            throw RuntimeExternalOperationCodecError.invalidInvariant
        }
        let bytes = try encodeCanonical(value.payload)
        guard bytes.count <= RuntimeExternalOperationLimits.maximumPayloadBytes else {
            throw RuntimeExternalOperationCodecError.boundsExceeded
        }
    }

    static func validate(_ value: RuntimeCanonicalExternalOperation) throws {
        guard RuntimeStoreManifestCodec.isSHA256Hex(value.creationDigest),
              RuntimeExternalOperationInvariant.valid(
                  status: value.workflowStatus, disposition: value.effectDisposition
              ),
              value.policyVersion > 0,
              value.attemptCount >= 0,
              value.attemptCount <= RuntimeExternalOperationLimits.maximumAttempts,
              isMillisecondNormalized(value.createdAt),
              isMillisecondNormalized(value.updatedAt),
              value.updatedAt >= value.createdAt,
              value.nextAttemptAt.map(isMillisecondNormalized) ?? true,
              validLease(value.lease, status: value.workflowStatus, updatedAt: value.updatedAt),
              validCurrentShape(value) else {
            throw RuntimeExternalOperationCodecError.invalidInvariant
        }
    }

    static func validate(_ value: RuntimeExternalAttemptStart) throws {
        let leaseDuration = value.lease.expiresAt.timeIntervalSince(value.lease.acquiredAt)
        guard value.version == runtimeCanonicalExternalOperationModelVersion,
              value.attemptNumber > 0,
              value.attemptNumber <= RuntimeExternalOperationLimits.maximumAttempts,
              value.policyVersion > 0,
              RuntimeStoreManifestCodec.isSHA256Hex(value.requestDigest),
              value.startedAt >= value.lease.acquiredAt,
              value.startedAt <= value.lease.expiresAt,
              value.invocationAuthorizedAt == value.startedAt,
              leaseDuration > 0,
              leaseDuration <= RuntimeExternalOperationLimits.maximumLeaseSeconds,
              isMillisecondNormalized(value.startedAt),
              isMillisecondNormalized(value.lease.expiresAt) else {
            throw RuntimeExternalOperationCodecError.invalidInvariant
        }
    }

    static func validate(_ value: RuntimeExternalAttemptOutcomeRecord) throws {
        guard value.version == runtimeCanonicalExternalOperationModelVersion,
              isMillisecondNormalized(value.recordedAt),
              validOutcomeShape(value) else {
            throw RuntimeExternalOperationCodecError.invalidInvariant
        }
    }

    static func validate(_ value: RuntimeExternalOperationHistoryEntry) throws {
        let transition = value.transition
        let bytes = try encodeCanonical(transition)
        let digest = LocalRuntimeStorageChecksum.sha256Hex(for: bytes)
        guard transition.version == runtimeCanonicalExternalOperationModelVersion,
              transition.toState.statusVersion > 0,
              transition.operationID == transition.toState.operationID,
              transition.fromState.map({ $0.operationID == transition.operationID }) ?? true,
              RuntimeStoreManifestCodec.isSHA256Hex(transition.toStateDigest),
              transition.fromStateDigest.map(RuntimeStoreManifestCodec.isSHA256Hex) ?? true,
              (transition.fromState == nil) == (transition.fromStateDigest == nil),
              try transition.fromState.map(stateDigest) == transition.fromStateDigest,
              try stateDigest(transition.toState) == transition.toStateDigest,
              transition.fromState.map({ validTransition(
                  from: $0, to: transition.toState, attemptID: transition.attemptID
              ) }) ?? (transition.toState.workflowStatus == .pending && transition.toState.statusVersion == 1),
              transition.fromState.map({ $0.statusVersion + 1 == transition.toState.statusVersion }) ?? true,
              isMillisecondNormalized(transition.occurredAt),
              digest == value.transitionDigest,
              value.historyID == RuntimeExternalHistoryID(
                  operationID: transition.operationID,
                  statusVersion: transition.toState.statusVersion,
                  transitionDigest: digest
              ) else {
            throw RuntimeExternalOperationCodecError.invalidInvariant
        }
    }

    static func makeHistory(
        operationID: RuntimeExternalOperationID,
        from: RuntimeCanonicalExternalOperation?,
        to: RuntimeCanonicalExternalOperation,
        attemptID: RuntimeExternalAttemptID?,
        occurredAt: Date
    ) throws -> RuntimeExternalOperationHistoryEntry {
        guard to.operationID == operationID else { throw RuntimeExternalOperationCodecError.invalidInvariant }
        let transition = RuntimeExternalOperationTransition(
            version: runtimeCanonicalExternalOperationModelVersion,
            operationID: operationID,
            fromState: from,
            fromStateDigest: try from.map(stateDigest),
            toState: to,
            toStateDigest: try stateDigest(to),
            attemptID: attemptID,
            occurredAt: occurredAt
        )
        let transitionBytes = try encodeCanonical(transition)
        let transitionDigest = LocalRuntimeStorageChecksum.sha256Hex(for: transitionBytes)
        let entry = RuntimeExternalOperationHistoryEntry(
            historyID: RuntimeExternalHistoryID(
                operationID: operationID,
                statusVersion: to.statusVersion,
                transitionDigest: transitionDigest
            ),
            transition: transition,
            transitionDigest: transitionDigest
        )
        try validate(entry)
        return entry
    }

    static func validTransition(
        from: RuntimeCanonicalExternalOperation,
        to: RuntimeCanonicalExternalOperation,
        attemptID: RuntimeExternalAttemptID?
    ) -> Bool {
        guard from.operationID == to.operationID,
              from.creationDigest == to.creationDigest,
              from.providerID == to.providerID,
              from.policyVersion == to.policyVersion,
              from.createdAt == to.createdAt,
              from.statusVersion + 1 == to.statusVersion,
              to.updatedAt >= from.updatedAt else { return false }
        switch (from.workflowStatus, to.workflowStatus) {
        case (.pending, .claimed):
            return attemptID == nil && to.effectDisposition == .notAttempted && to.attemptCount == 0 &&
                to.claimPurpose == .execute && to.lease != nil && to.nextAttemptAt == nil &&
                to.externalReference == nil && to.reasonCode == nil && to.reasonFingerprint == nil
        case (.retryScheduled, .claimed):
            return attemptID == nil && to.effectDisposition == from.effectDisposition &&
                to.attemptCount == from.attemptCount && to.claimPurpose == .execute && to.lease != nil &&
                to.nextAttemptAt == nil && to.externalReference == nil && to.reasonCode == nil && to.reasonFingerprint == nil
        case (.pending, .permanentFailure):
            return attemptID == nil && to.effectDisposition == .notAttempted &&
                to.attemptCount == 0 && terminalClearsLease(to) && to.externalReference == nil &&
                to.reasonCode == .transitionBudgetExhausted && to.reasonFingerprint != nil
        case (.retryScheduled, .permanentFailure):
            return attemptID == nil && to.effectDisposition == from.effectDisposition &&
                to.attemptCount == from.attemptCount && terminalClearsLease(to) &&
                to.externalReference == nil && to.reasonCode == .transitionBudgetExhausted &&
                to.reasonFingerprint != nil
        case (.claimed, .claimed):
            return attemptID == nil && to.effectDisposition == from.effectDisposition &&
                to.attemptCount == from.attemptCount && to.claimPurpose == .execute &&
                from.claimPurpose == .execute && to.lease != nil && to.lease != from.lease &&
                to.nextAttemptAt == nil && to.externalReference == from.externalReference &&
                to.reasonCode == from.reasonCode && to.reasonFingerprint == from.reasonFingerprint
        case (.claimed, .executing):
            return to.effectDisposition == from.effectDisposition && to.attemptCount == from.attemptCount + 1 &&
                attemptID != nil && to.claimPurpose == .execute && to.lease == from.lease &&
                to.nextAttemptAt == nil && to.externalReference == from.externalReference &&
                to.reasonCode == from.reasonCode && to.reasonFingerprint == from.reasonFingerprint
        case (.claimed, .permanentFailure):
            return attemptID == nil && to.effectDisposition == from.effectDisposition &&
                to.attemptCount == from.attemptCount && terminalClearsLease(to) &&
                to.externalReference == nil && to.reasonCode == .transitionBudgetExhausted &&
                to.reasonFingerprint != nil
        case (.executing, .succeeded):
            return attemptID != nil &&
                (to.effectDisposition == .confirmedPresent || to.effectDisposition == .confirmedAbsent) &&
                to.attemptCount == from.attemptCount && terminalClearsLease(to) &&
                (to.effectDisposition == .confirmedPresent ? to.externalReference != nil : to.externalReference == nil) &&
                to.reasonCode == nil && to.reasonFingerprint == nil
        case (.executing, .retryScheduled):
            return attemptID != nil &&
                (to.effectDisposition == .confirmedAbsent || to.effectDisposition == .notAttempted) &&
                to.attemptCount == from.attemptCount && terminalClearsLease(to) &&
                to.nextAttemptAt != nil && to.externalReference == nil &&
                to.reasonCode == .retryableBeforeEffect && to.reasonFingerprint != nil
        case (.executing, .permanentFailure):
            return attemptID != nil &&
                (to.effectDisposition == .notAttempted || to.effectDisposition == .confirmedAbsent) &&
                to.attemptCount == from.attemptCount && terminalClearsLease(to) &&
                to.externalReference == nil && to.reasonCode != nil && to.reasonFingerprint != nil
        case (.executing, .reconciliationRequired):
            return attemptID != nil && to.effectDisposition == .indeterminate &&
                to.attemptCount == from.attemptCount && terminalClearsLease(to) &&
                to.reasonCode != nil && to.reasonFingerprint != nil
        case (.reconciliationRequired, .reconciliationRequired):
            guard to.effectDisposition == .indeterminate,
                  to.externalReference == from.externalReference,
                  to.nextAttemptAt == nil,
                  to.reasonCode != nil, to.reasonFingerprint != nil else { return false }
            if from.lease == nil, to.lease != nil {
                return attemptID == nil && to.claimPurpose == .reconcile &&
                    to.attemptCount == from.attemptCount &&
                    to.reasonCode == from.reasonCode && to.reasonFingerprint == from.reasonFingerprint
            }
            if from.lease != nil, to.lease == from.lease, to.attemptCount == from.attemptCount + 1 {
                return attemptID != nil && from.claimPurpose == .reconcile && to.claimPurpose == .reconcile &&
                    to.reasonCode == from.reasonCode && to.reasonFingerprint == from.reasonFingerprint
            }
            return attemptID != nil && from.lease != nil && to.lease == nil && to.claimPurpose == nil &&
                to.attemptCount == from.attemptCount
        case (.reconciliationRequired, .succeeded):
            return attemptID != nil &&
                (to.effectDisposition == .confirmedPresent || to.effectDisposition == .confirmedAbsent) &&
                to.attemptCount == from.attemptCount && terminalClearsLease(to) &&
                (to.effectDisposition == .confirmedPresent ? to.externalReference != nil : to.externalReference == nil) &&
                to.reasonCode == nil && to.reasonFingerprint == nil
        case (.reconciliationRequired, .retryScheduled):
            return attemptID != nil &&
                (to.effectDisposition == .confirmedAbsent || to.effectDisposition == .notAttempted) &&
                to.attemptCount == from.attemptCount && terminalClearsLease(to) &&
                to.externalReference == nil && to.nextAttemptAt != nil &&
                to.reasonCode == .retryableBeforeEffect && to.reasonFingerprint != nil
        case (.reconciliationRequired, .permanentFailure):
            return attemptID != nil && to.effectDisposition == .indeterminate &&
                to.attemptCount == from.attemptCount && terminalClearsLease(to) &&
                to.reasonCode != nil && to.reasonFingerprint != nil
        case (.reconciliationRequired, .operatorRequired):
            return to.effectDisposition == .indeterminate &&
                to.attemptCount == from.attemptCount && terminalClearsLease(to) &&
                (to.reasonCode == .retryLimitReached ||
                 to.reasonCode == .transitionBudgetExhausted) &&
                to.reasonFingerprint != nil &&
                ((attemptID == nil &&
                  (from.lease.map { to.updatedAt >= $0.expiresAt } ?? true)) ||
                 attemptID != nil)
        case (.reconciliationRequired, .cancelled):
            return attemptID != nil && to.effectDisposition == .confirmedAbsent &&
                to.attemptCount == from.attemptCount && terminalClearsLease(to) &&
                to.externalReference == nil
        case (.pending, .cancelled):
            return attemptID == nil && to.effectDisposition == .notAttempted &&
                to.attemptCount == 0 && terminalClearsLease(to)
        case (.retryScheduled, .cancelled):
            return attemptID == nil && to.effectDisposition == from.effectDisposition &&
                to.attemptCount == from.attemptCount && terminalClearsLease(to)
        default:
            return false
        }
    }

    static func permitsOutcome(
        action: RuntimeCanonicalExternalOperationPayload.Action,
        purpose: RuntimeExternalAttemptPurpose,
        kind: RuntimeExternalAttemptOutcomeKind
    ) -> Bool {
        switch (action, purpose, kind) {
        case (.create, .execute, .confirmedSuccess),
             (.create, .execute, .rejectedBeforeEffect),
             (.create, .execute, .retryableBeforeEffect),
             (.create, .execute, .permissionUnavailableBeforeEffect),
             (.create, .execute, .indeterminate),
             (.create, .execute, .leaseExpiredWithoutOutcome),
             (.create, .reconcile, .confirmedPresence),
             (.create, .reconcile, .confirmedAbsence),
             (.create, .reconcile, .ambiguousReconciliation),
             (.create, .reconcile, .incompatibleProviderState),
             (.create, .reconcile, .leaseExpiredWithoutOutcome),
             (.compensateRemoval, .execute, .confirmedCancellation),
             (.compensateRemoval, .execute, .cancellationRetryableBeforeEffect),
             (.compensateRemoval, .execute, .cancellationUnsupported),
             (.compensateRemoval, .execute, .permissionUnavailableBeforeEffect),
             (.compensateRemoval, .execute, .indeterminate),
             (.compensateRemoval, .execute, .leaseExpiredWithoutOutcome),
             (.compensateRemoval, .reconcile, .cancellationSourceStillPresent),
             (.compensateRemoval, .reconcile, .reconciledCancellationAbsent),
             (.compensateRemoval, .reconcile, .ambiguousReconciliation),
             (.compensateRemoval, .reconcile, .incompatibleProviderState),
             (.compensateRemoval, .reconcile, .leaseExpiredWithoutOutcome):
            true
        default:
            false
        }
    }

    static func outcome(
        attemptID: RuntimeExternalAttemptID,
        operationID: RuntimeExternalOperationID,
        providerID: RuntimeExternalProviderID,
        execution: RuntimeExternalProviderExecutionOutcome,
        at date: Date
    ) -> RuntimeExternalAttemptOutcomeRecord {
        let facts: (RuntimeExternalAttemptOutcomeKind, RuntimeExternalEffectDisposition,
                    RuntimeExternalProviderReference?, RuntimeExternalReasonCode?) = switch execution {
        case let .confirmedSuccess(reference):
            (.confirmedSuccess, .confirmedPresent, reference, nil)
        case .rejectedBeforeEffect:
            (.rejectedBeforeEffect, .notAttempted, nil, .providerRejected)
        case .retryableFailureBeforeEffect:
            (.retryableBeforeEffect, .confirmedAbsent, nil, .retryableBeforeEffect)
        case .permissionUnavailableBeforeEffect:
            (.permissionUnavailableBeforeEffect, .notAttempted, nil, .permissionUnavailableBeforeEffect)
        case let .indeterminate(reference):
            (.indeterminate, .indeterminate, reference, .indeterminateAfterInvocation)
        }
        return makeOutcome(attemptID: attemptID, operationID: operationID, providerID: providerID, facts: facts, at: date)
    }

    static func leaseExpiryOutcome(
        attemptID: RuntimeExternalAttemptID,
        operationID: RuntimeExternalOperationID,
        providerID: RuntimeExternalProviderID,
        at date: Date
    ) -> RuntimeExternalAttemptOutcomeRecord {
        makeOutcome(
            attemptID: attemptID,
            operationID: operationID,
            providerID: providerID,
            facts: (
                .leaseExpiredWithoutOutcome, .indeterminate, nil,
                .leaseExpiredAfterAttemptStart
            ),
            at: date
        )
    }

    static func outcome(
        attemptID: RuntimeExternalAttemptID,
        operationID: RuntimeExternalOperationID,
        providerID: RuntimeExternalProviderID,
        cancellation: RuntimeExternalProviderCancellationOutcome,
        at date: Date
    ) -> RuntimeExternalAttemptOutcomeRecord {
        let facts: (RuntimeExternalAttemptOutcomeKind, RuntimeExternalEffectDisposition,
                    RuntimeExternalProviderReference?, RuntimeExternalReasonCode?) = switch cancellation {
        case .confirmedCancellation:
            (.confirmedCancellation, .confirmedAbsent, nil, nil)
        case .unsupported:
            (.cancellationUnsupported, .notAttempted, nil, .providerCancellationUnsupported)
        case .retryableFailureBeforeEffect:
            (.cancellationRetryableBeforeEffect, .notAttempted, nil, .retryableBeforeEffect)
        case .permissionUnavailableBeforeEffect:
            (.permissionUnavailableBeforeEffect, .notAttempted, nil, .permissionUnavailableBeforeEffect)
        case .indeterminate:
            (.indeterminate, .indeterminate, nil, .indeterminateAfterInvocation)
        }
        return makeOutcome(
            attemptID: attemptID, operationID: operationID,
            providerID: providerID, facts: facts, at: date
        )
    }

    static func outcome(
        attemptID: RuntimeExternalAttemptID,
        operationID: RuntimeExternalOperationID,
        providerID: RuntimeExternalProviderID,
        reconciliation: RuntimeExternalProviderReconciliationOutcome,
        action: RuntimeCanonicalExternalOperationPayload.Action,
        at date: Date
    ) -> RuntimeExternalAttemptOutcomeRecord {
        let facts: (RuntimeExternalAttemptOutcomeKind, RuntimeExternalEffectDisposition,
                    RuntimeExternalProviderReference?, RuntimeExternalReasonCode?) = switch reconciliation {
        case let .found(reference):
            action == .create
                ? (.confirmedPresence, .confirmedPresent, reference, nil)
                : (.cancellationSourceStillPresent, .notAttempted, nil, .retryableBeforeEffect)
        case .confirmedAbsent:
            action == .create
                ? (.confirmedAbsence, .confirmedAbsent, nil, .reconciliationAbsent)
                : (.reconciledCancellationAbsent, .confirmedAbsent, nil, nil)
        case .ambiguous:
            (.ambiguousReconciliation, .indeterminate, nil, .reconciliationAmbiguous)
        case .incompatible:
            (.incompatibleProviderState, .indeterminate, nil, .incompatibleProviderState)
        }
        return makeOutcome(attemptID: attemptID, operationID: operationID, providerID: providerID, facts: facts, at: date)
    }

    private static func makeOutcome(
        attemptID: RuntimeExternalAttemptID,
        operationID: RuntimeExternalOperationID,
        providerID: RuntimeExternalProviderID,
        facts: (RuntimeExternalAttemptOutcomeKind, RuntimeExternalEffectDisposition,
                RuntimeExternalProviderReference?, RuntimeExternalReasonCode?),
        at date: Date
    ) -> RuntimeExternalAttemptOutcomeRecord {
        RuntimeExternalAttemptOutcomeRecord(
            version: runtimeCanonicalExternalOperationModelVersion,
            attemptID: attemptID,
            operationID: operationID,
            kind: facts.0,
            effectDisposition: facts.1,
            externalReference: facts.2,
            reasonCode: facts.3,
            reasonFingerprint: facts.3.map { RuntimeExternalReasonFingerprint.redacted(code: $0, providerID: providerID) },
            recordedAt: date
        )
    }

    private static func validLease(
        _ lease: RuntimeExternalLease?,
        status: RuntimeExternalWorkflowStatus,
        updatedAt: Date
    ) -> Bool {
        let permitsLease = status == .claimed || status == .executing || status == .reconciliationRequired
        guard lease == nil || permitsLease else { return false }
        guard status != .claimed && status != .executing || lease != nil else { return false }
        guard let lease else { return true }
        let duration = lease.expiresAt.timeIntervalSince(lease.acquiredAt)
        return isMillisecondNormalized(lease.acquiredAt) && isMillisecondNormalized(lease.expiresAt) &&
            lease.acquiredAt <= updatedAt && updatedAt <= lease.expiresAt && duration > 0 &&
            duration <= RuntimeExternalOperationLimits.maximumLeaseSeconds
    }

    private static func validCurrentShape(_ value: RuntimeCanonicalExternalOperation) -> Bool {
        switch value.workflowStatus {
        case .pending:
            return value.statusVersion == 1 && value.attemptCount == 0 && value.nextAttemptAt == nil &&
                value.claimPurpose == nil &&
                value.externalReference == nil && value.reasonCode == nil && value.reasonFingerprint == nil
        case .claimed:
            return value.nextAttemptAt == nil && value.claimPurpose != nil &&
                value.reasonCode == nil && value.reasonFingerprint == nil
        case .executing:
            return value.attemptCount > 0 && value.nextAttemptAt == nil && value.claimPurpose != nil
        case .retryScheduled:
            return value.attemptCount > 0 && value.nextAttemptAt != nil && value.claimPurpose == nil && value.externalReference == nil &&
                value.reasonCode == .retryableBeforeEffect && value.reasonFingerprint != nil
        case .reconciliationRequired:
            return value.attemptCount > 0 && value.nextAttemptAt == nil &&
                ((value.lease == nil && value.claimPurpose == nil) ||
                 (value.lease != nil && value.claimPurpose == .reconcile)) &&
                value.reasonCode != nil && value.reasonFingerprint != nil
        case .succeeded:
            return value.attemptCount > 0 && value.nextAttemptAt == nil && value.claimPurpose == nil &&
                ((value.effectDisposition == .confirmedPresent && value.externalReference != nil) ||
                 (value.effectDisposition == .confirmedAbsent && value.externalReference == nil)) &&
                value.reasonCode == nil && value.reasonFingerprint == nil
        case .permanentFailure:
            return value.nextAttemptAt == nil && value.claimPurpose == nil && value.reasonCode != nil && value.reasonFingerprint != nil
        case .operatorRequired:
            return value.effectDisposition == .indeterminate && value.nextAttemptAt == nil &&
                value.claimPurpose == nil && value.lease == nil &&
                (value.reasonCode == .retryLimitReached ||
                 value.reasonCode == .transitionBudgetExhausted) &&
                value.reasonFingerprint != nil
        case .cancelled:
            return value.nextAttemptAt == nil && value.claimPurpose == nil && value.externalReference == nil &&
                value.reasonCode == .cancelledBeforeEffect && value.reasonFingerprint != nil
        }
    }

    private static func validOutcomeShape(_ value: RuntimeExternalAttemptOutcomeRecord) -> Bool {
        let reasonPair = (value.reasonCode == nil) == (value.reasonFingerprint == nil)
        guard reasonPair else { return false }
        switch value.kind {
        case .confirmedSuccess, .confirmedPresence:
            return value.effectDisposition == .confirmedPresent && value.externalReference != nil && value.reasonCode == nil
        case .confirmedCancellation:
            return value.effectDisposition == .confirmedAbsent && value.externalReference == nil && value.reasonCode == nil
        case .cancellationRetryableBeforeEffect:
            return value.effectDisposition == .notAttempted && value.externalReference == nil &&
                value.reasonCode == .retryableBeforeEffect
        case .cancellationUnsupported:
            return value.effectDisposition == .notAttempted && value.externalReference == nil &&
                value.reasonCode == .providerCancellationUnsupported
        case .cancellationSourceStillPresent:
            return value.effectDisposition == .notAttempted && value.externalReference == nil &&
                value.reasonCode == .retryableBeforeEffect
        case .reconciledCancellationAbsent:
            return value.effectDisposition == .confirmedAbsent && value.externalReference == nil &&
                value.reasonCode == nil
        case .confirmedAbsence:
            return value.effectDisposition == .confirmedAbsent && value.externalReference == nil && value.reasonCode == .reconciliationAbsent
        case .rejectedBeforeEffect:
            return value.effectDisposition == .notAttempted && value.externalReference == nil && value.reasonCode == .providerRejected
        case .retryableBeforeEffect:
            return value.effectDisposition == .confirmedAbsent && value.externalReference == nil && value.reasonCode == .retryableBeforeEffect
        case .permissionUnavailableBeforeEffect:
            return value.effectDisposition == .notAttempted && value.externalReference == nil && value.reasonCode == .permissionUnavailableBeforeEffect
        case .indeterminate:
            return value.effectDisposition == .indeterminate && value.reasonCode == .indeterminateAfterInvocation
        case .leaseExpiredWithoutOutcome:
            return value.effectDisposition == .indeterminate && value.externalReference == nil &&
                value.reasonCode == .leaseExpiredAfterAttemptStart
        case .ambiguousReconciliation:
            return value.effectDisposition == .indeterminate && value.externalReference == nil && value.reasonCode == .reconciliationAmbiguous
        case .incompatibleProviderState:
            return value.effectDisposition == .indeterminate && value.externalReference == nil && value.reasonCode == .incompatibleProviderState
        }
    }

    private static func terminalClearsLease(_ value: RuntimeCanonicalExternalOperation) -> Bool {
        value.lease == nil && value.claimPurpose == nil
    }

    private static func isMillisecondNormalized(_ date: Date) -> Bool {
        let milliseconds = date.timeIntervalSince1970 * 1_000
        return milliseconds.isFinite && milliseconds >= 0 && milliseconds.rounded() == milliseconds
    }

    private static func encodeCanonical<Value: Encodable>(_ value: Value) throws -> Data {
        do { return try makeEncoder().encode(value) }
        catch { throw RuntimeExternalOperationCodecError.corrupt }
    }

    private static func bounded(_ bytes: Data, maximum: Int) throws -> Data {
        guard bytes.count <= maximum else { throw RuntimeExternalOperationCodecError.boundsExceeded }
        return bytes
    }

    private static func decodeCanonical<Value: Codable>(_ bytes: Data) throws -> Value {
        guard bytes.count <= RuntimeExternalOperationLimits.maximumPayloadBytes else {
            throw RuntimeExternalOperationCodecError.boundsExceeded
        }
        let value: Value
        do { value = try makeDecoder().decode(Value.self, from: bytes) }
        catch { throw RuntimeExternalOperationCodecError.corrupt }
        guard try encodeCanonical(value) == bytes else { throw RuntimeExternalOperationCodecError.nonCanonical }
        return value
    }
}
