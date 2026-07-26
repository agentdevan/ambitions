import Foundation

let runtimeCanonicalExternalOperationSchemaVersion = 7
let runtimeCanonicalExternalOperationModelVersion = 1

enum RuntimeExternalOperationLimits {
    static let maximumTargets = RuntimeCompensationLimits.maximumTargets
    static let maximumOperationsPerReceipt = RuntimeCompensationLimits.maximumExternalOperations
    static let maximumExecutionAttempts = 8
    static let maximumReconciliationAttempts = 8
    static let maximumAttempts = maximumExecutionAttempts + maximumReconciliationAttempts
    // One initial state plus eight execute and eight reconcile lifecycles can
    // consume 49 transitions; three slots remain for bounded recovery/admin.
    static let maximumTransitions = 52
    static let maximumPageSize = 50
    static let maximumCreationBytes = 16_384
    static let maximumCurrentStateBytes = 4_096
    static let maximumHistoryBytes = 12_288
    static let maximumAttemptStartBytes = 8_192
    static let maximumAttemptOutcomeBytes = 4_096
    static let maximumTransitionInvalidationBytes = maximumHistoryBytes
    static let maximumPayloadBytes = maximumCreationBytes
    static let maximumGraphBytesPerOperation = maximumCreationBytes + maximumCurrentStateBytes +
        maximumTransitions * maximumHistoryBytes +
        maximumAttempts * maximumAttemptStartBytes +
        maximumAttempts * maximumAttemptOutcomeBytes +
        (maximumTransitions - 1) * maximumTransitionInvalidationBytes + 32_768
    static let maximumReceiptGraphBytes = maximumOperationsPerReceipt * maximumGraphBytesPerOperation
    static let maximumPageGraphBytes = (maximumPageSize + 1) * maximumGraphBytesPerOperation
    static let maximumTitleBytes = 1_024
    static let maximumProviderReferenceBytes = 512
    static let maximumLeaseSeconds: TimeInterval = 5 * 60
}

private func runtimeExternalNormalizedOpaqueValue(_ value: String, maximumBytes: Int) -> String? {
    guard value.isEmpty == false, value.utf8.count <= maximumBytes,
          value == value.trimmingCharacters(in: .whitespacesAndNewlines),
          value == value.precomposedStringWithCanonicalMapping,
          value.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false else {
        return nil
    }
    return value
}

protocol RuntimeExternalOpaqueIdentity: RawRepresentable, Codable, Sendable, Hashable, Comparable
where RawValue == String {}

extension RuntimeExternalOpaqueIdentity {
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue.utf8.lexicographicallyPrecedes(rhs.rawValue.utf8)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        guard let value = Self(rawValue: raw) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid opaque external-operation identity.")
        }
        self = value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

struct RuntimeExternalProviderID: RuntimeExternalOpaqueIdentity, Equatable {
    let rawValue: String
    init?(rawValue: String) {
        guard let value = runtimeExternalNormalizedOpaqueValue(rawValue, maximumBytes: 128) else { return nil }
        self.rawValue = value
    }
}

struct RuntimeExternalProviderReference: RuntimeExternalOpaqueIdentity, Equatable {
    let rawValue: String
    init?(rawValue: String) {
        guard let value = runtimeExternalNormalizedOpaqueValue(
            rawValue, maximumBytes: RuntimeExternalOperationLimits.maximumProviderReferenceBytes
        ) else { return nil }
        self.rawValue = value
    }
}

struct RuntimeExternalStableIdempotencyKey: RuntimeExternalOpaqueIdentity, Equatable {
    let rawValue: String
    init?(rawValue: String) {
        guard RuntimeStoreManifestCodec.isSHA256Hex(rawValue), rawValue == rawValue.lowercased() else { return nil }
        self.rawValue = rawValue
    }

    static func derive(
        operationID: RuntimeExternalOperationID,
        commandID: RuntimeCommandID,
        kind: RuntimeExternalEffectKind
    ) -> Self {
        let digest = LocalRuntimeStorageChecksum.sha256Hex(
            for: Data("external-operation\u{0}\(operationID.rawValue)\u{0}\(commandID.rawValue)\u{0}\(kind.rawValue)".utf8)
        )
        return Self(validatedDigest: digest)
    }

    private init(validatedDigest: String) { rawValue = validatedDigest }
}

struct RuntimeExternalLeaseToken: RuntimeExternalOpaqueIdentity, Equatable {
    let rawValue: String
    init?(rawValue: String) {
        guard let value = runtimeExternalNormalizedOpaqueValue(rawValue, maximumBytes: 256) else { return nil }
        self.rawValue = value
    }
}

struct RuntimeExternalLeaseOwner: RuntimeExternalOpaqueIdentity, Equatable {
    let rawValue: String
    init?(rawValue: String) {
        guard let value = runtimeExternalNormalizedOpaqueValue(rawValue, maximumBytes: 128) else { return nil }
        self.rawValue = value
    }
}

struct RuntimeExternalAttemptID: RuntimeExternalOpaqueIdentity, Equatable {
    let rawValue: String
    init?(rawValue: String) {
        guard let value = runtimeExternalNormalizedOpaqueValue(rawValue, maximumBytes: 256) else { return nil }
        self.rawValue = value
    }
}

struct RuntimeExternalHistoryID: RuntimeExternalOpaqueIdentity, Equatable {
    let rawValue: String
    init?(rawValue: String) {
        guard RuntimeStoreManifestCodec.isSHA256Hex(rawValue), rawValue == rawValue.lowercased() else { return nil }
        self.rawValue = rawValue
    }

    init(operationID: RuntimeExternalOperationID, statusVersion: UInt64, transitionDigest: String) {
        rawValue = LocalRuntimeStorageChecksum.sha256Hex(
            for: Data("external-history\u{0}\(operationID.rawValue)\u{0}\(statusVersion)\u{0}\(transitionDigest)".utf8)
        )
    }
}

struct RuntimeExternalReasonFingerprint: RuntimeExternalOpaqueIdentity, Equatable {
    let rawValue: String
    init?(rawValue: String) {
        guard RuntimeStoreManifestCodec.isSHA256Hex(rawValue), rawValue == rawValue.lowercased() else { return nil }
        self.rawValue = rawValue
    }

    static func redacted(code: RuntimeExternalReasonCode, providerID: RuntimeExternalProviderID) -> Self {
        Self(validatedDigest: LocalRuntimeStorageChecksum.sha256Hex(
            for: Data("external-reason\u{0}\(code.rawValue)\u{0}\(providerID.rawValue)".utf8)
        ))
    }

    private init(validatedDigest: String) { rawValue = validatedDigest }
}

struct RuntimeExternalClassifiedTitle: Codable, Sendable, Equatable, Hashable {
    let value: String
    let privacy: EventLedgerPrivacyClassification

    init?(value: String, privacy: EventLedgerPrivacyClassification) {
        guard let normalized = runtimeExternalNormalizedOpaqueValue(
            value, maximumBytes: RuntimeExternalOperationLimits.maximumTitleBytes
        ) else { return nil }
        self.value = normalized
        self.privacy = privacy
    }
}

enum RuntimeExternalReasonCode: String, Codable, Sendable, Equatable, Hashable {
    case providerRejected = "provider_rejected"
    case retryableBeforeEffect = "retryable_before_effect"
    case permissionUnavailableBeforeEffect = "permission_unavailable_before_effect"
    case indeterminateAfterInvocation = "indeterminate_after_invocation"
    case reconciliationAbsent = "reconciliation_absent"
    case reconciliationAmbiguous = "reconciliation_ambiguous"
    case incompatibleProviderState = "incompatible_provider_state"
    case providerCancellationUnsupported = "provider_cancellation_unsupported"
    case retryLimitReached = "retry_limit_reached"
    case leaseExpiredAfterAttemptStart = "lease_expired_after_attempt_start"
    case transitionBudgetExhausted = "transition_budget_exhausted"
    case cancelledBeforeEffect = "cancelled_before_effect"
}

enum RuntimeExternalWorkflowStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case pending, claimed, executing, succeeded
    case retryScheduled = "retry_scheduled"
    case permanentFailure = "permanent_failure"
    case reconciliationRequired = "reconciliation_required"
    case operatorRequired = "operator_required"
    case cancelled

    var isTerminal: Bool {
        switch self {
        case .succeeded, .permanentFailure, .operatorRequired, .cancelled: true
        case .pending, .claimed, .executing, .retryScheduled, .reconciliationRequired: false
        }
    }
}

enum RuntimeExternalEffectDisposition: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notAttempted = "not_attempted"
    case confirmedAbsent = "confirmed_absent"
    case confirmedPresent = "confirmed_present"
    case indeterminate
}

enum RuntimeExternalOperationInvariant {
    static func valid(status: RuntimeExternalWorkflowStatus, disposition: RuntimeExternalEffectDisposition) -> Bool {
        switch (status, disposition) {
        case (.pending, .notAttempted), (.claimed, .notAttempted),
             (.claimed, .confirmedAbsent),
             (.executing, .notAttempted), (.executing, .confirmedAbsent),
             (.retryScheduled, .confirmedAbsent), (.retryScheduled, .notAttempted),
             (.reconciliationRequired, .indeterminate),
             (.succeeded, .confirmedPresent), (.succeeded, .confirmedAbsent),
             (.permanentFailure, .notAttempted), (.permanentFailure, .confirmedAbsent),
             (.permanentFailure, .indeterminate),
             (.operatorRequired, .indeterminate),
             (.cancelled, .notAttempted), (.cancelled, .confirmedAbsent):
            true
        default:
            false
        }
    }

    static func compensationBlocked(
        status: RuntimeExternalWorkflowStatus,
        disposition: RuntimeExternalEffectDisposition
    ) -> Bool {
        guard valid(status: status, disposition: disposition) else { return true }
        switch (status, disposition) {
        case (.permanentFailure, .notAttempted), (.permanentFailure, .confirmedAbsent),
             (.succeeded, .confirmedAbsent),
             (.cancelled, .notAttempted), (.cancelled, .confirmedAbsent):
            false
        case (.succeeded, .confirmedPresent), (.permanentFailure, .indeterminate),
             (.operatorRequired, .indeterminate),
             (.pending, .notAttempted), (.claimed, .notAttempted),
             (.claimed, .confirmedAbsent),
             (.executing, .notAttempted), (.executing, .confirmedAbsent),
             (.retryScheduled, .confirmedAbsent), (.retryScheduled, .notAttempted),
             (.reconciliationRequired, .indeterminate):
            true
        default:
            true
        }
    }
}

struct RuntimeExternalOperationTarget: Codable, Sendable, Equatable, Hashable, Comparable {
    let family: RuntimeSemanticAggregateKind
    let objectID: RuntimeDomainObjectID
    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.family.rawValue, lhs.objectID.rawValue) < (rhs.family.rawValue, rhs.objectID.rawValue)
    }
}

struct RuntimeCanonicalExternalOperationPayload: Codable, Sendable, Equatable, Hashable {
    enum Action: String, Codable, Sendable, Equatable, Hashable {
        case create
        case compensateRemoval = "compensate_removal"
    }

    let version: Int
    let kind: RuntimeExternalEffectKind
    let target: AmbitionsCommandTarget
    let title: RuntimeExternalClassifiedTitle?
    let action: Action
    let sourceOperationID: RuntimeExternalOperationID?
    let sourceProviderReference: RuntimeExternalProviderReference?
    let sourceReceiptID: RuntimeReceiptID?
    let compensationPlanID: RuntimeRollbackPlanID?
    let compensationPlanDigest: String?
}

struct RuntimeCanonicalExternalOperationCreation: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let operationID: RuntimeExternalOperationID
    let commandID: RuntimeCommandID
    let receiptID: RuntimeReceiptID
    let lineage: RuntimeAuthorityLineageReference
    let kind: RuntimeExternalEffectKind
    let payload: RuntimeCanonicalExternalOperationPayload
    let targets: [RuntimeExternalOperationTarget]
    let privacy: EventLedgerPrivacyClassification
    let localOnly: Bool
    let providerID: RuntimeExternalProviderID
    let stableIdempotencyKey: RuntimeExternalStableIdempotencyKey
    let policyVersion: Int
    let createdAt: Date
}

struct RuntimeExternalLease: Codable, Sendable, Equatable, Hashable {
    let token: RuntimeExternalLeaseToken
    let owner: RuntimeExternalLeaseOwner
    let acquiredAt: Date
    let expiresAt: Date
}

struct RuntimeCanonicalExternalOperation: Codable, Sendable, Equatable, Hashable {
    let operationID: RuntimeExternalOperationID
    let creationDigest: String
    let providerID: RuntimeExternalProviderID
    let workflowStatus: RuntimeExternalWorkflowStatus
    let effectDisposition: RuntimeExternalEffectDisposition
    let statusVersion: UInt64
    let policyVersion: Int
    let attemptCount: Int
    let nextAttemptAt: Date?
    let claimPurpose: RuntimeExternalAttemptPurpose?
    let lease: RuntimeExternalLease?
    let externalReference: RuntimeExternalProviderReference?
    let reasonCode: RuntimeExternalReasonCode?
    let reasonFingerprint: RuntimeExternalReasonFingerprint?
    let createdAt: Date
    let updatedAt: Date

    var blocksCompensation: Bool {
        RuntimeExternalOperationInvariant.compensationBlocked(
            status: workflowStatus, disposition: effectDisposition
        )
    }
}

enum RuntimeExternalAttemptPurpose: String, Codable, Sendable, Equatable, Hashable {
    case execute, reconcile
}

struct RuntimeExternalAttemptStart: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let attemptID: RuntimeExternalAttemptID
    let operationID: RuntimeExternalOperationID
    let attemptNumber: Int
    let purpose: RuntimeExternalAttemptPurpose
    let action: RuntimeCanonicalExternalOperationPayload.Action
    let sourceStatusVersion: UInt64
    let policyVersion: Int
    let providerID: RuntimeExternalProviderID
    let kind: RuntimeExternalEffectKind
    let lease: RuntimeExternalLease
    let stableIdempotencyKey: RuntimeExternalStableIdempotencyKey
    let requestDigest: String
    /// This durable timestamp is the authorization boundary for provider
    /// invocation. Absence of an outcome after it is uncertain and must be
    /// reconciled; cancellation cannot reinterpret it as "not invoked".
    let invocationAuthorizedAt: Date
    let startedAt: Date
}

enum RuntimeExternalAttemptOutcomeKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case confirmedSuccess = "confirmed_success"
    case confirmedCancellation = "confirmed_cancellation"
    case cancellationRetryableBeforeEffect = "cancellation_retryable_before_effect"
    case cancellationUnsupported = "cancellation_unsupported"
    case cancellationSourceStillPresent = "cancellation_source_still_present"
    case reconciledCancellationAbsent = "reconciled_cancellation_absent"
    case confirmedPresence = "confirmed_presence"
    case confirmedAbsence = "confirmed_absence"
    case rejectedBeforeEffect = "rejected_before_effect"
    case retryableBeforeEffect = "retryable_before_effect"
    case permissionUnavailableBeforeEffect = "permission_unavailable_before_effect"
    case indeterminate
    case leaseExpiredWithoutOutcome = "lease_expired_without_outcome"
    case ambiguousReconciliation = "ambiguous_reconciliation"
    case incompatibleProviderState = "incompatible_provider_state"
}

struct RuntimeExternalAttemptOutcomeRecord: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let attemptID: RuntimeExternalAttemptID
    let operationID: RuntimeExternalOperationID
    let kind: RuntimeExternalAttemptOutcomeKind
    let effectDisposition: RuntimeExternalEffectDisposition
    let externalReference: RuntimeExternalProviderReference?
    let reasonCode: RuntimeExternalReasonCode?
    let reasonFingerprint: RuntimeExternalReasonFingerprint?
    let recordedAt: Date
}

struct RuntimeExternalOperationTransition: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let operationID: RuntimeExternalOperationID
    let fromState: RuntimeCanonicalExternalOperation?
    let fromStateDigest: String?
    let toState: RuntimeCanonicalExternalOperation
    let toStateDigest: String
    let attemptID: RuntimeExternalAttemptID?
    let occurredAt: Date
}

struct RuntimeExternalOperationHistoryEntry: Codable, Sendable, Equatable, Hashable {
    let historyID: RuntimeExternalHistoryID
    let transition: RuntimeExternalOperationTransition
    let transitionDigest: String
}

enum RuntimeExternalProviderExecutionOutcome: Sendable, Equatable {
    case confirmedSuccess(RuntimeExternalProviderReference)
    case rejectedBeforeEffect
    case retryableFailureBeforeEffect
    case permissionUnavailableBeforeEffect
    case indeterminate(RuntimeExternalProviderReference?)
}

enum RuntimeExternalProviderCancellationOutcome: Sendable, Equatable {
    case confirmedCancellation
    case unsupported
    case retryableFailureBeforeEffect
    case permissionUnavailableBeforeEffect
    case indeterminate
}

enum RuntimeExternalProviderReconciliationOutcome: Sendable, Equatable {
    case found(RuntimeExternalProviderReference)
    case confirmedAbsent
    case ambiguous
    case incompatible
}

struct RuntimeExternalProviderExecutionRequest: Sendable, Equatable {
    let operationID: RuntimeExternalOperationID
    let attemptID: RuntimeExternalAttemptID
    let kind: RuntimeExternalEffectKind
    let payload: RuntimeCanonicalExternalOperationPayload
    let stableIdempotencyKey: RuntimeExternalStableIdempotencyKey
    let priorExternalReference: RuntimeExternalProviderReference?
}

struct RuntimeExternalProviderCancellationRequest: Sendable, Equatable {
    let operationID: RuntimeExternalOperationID
    let attemptID: RuntimeExternalAttemptID
    let kind: RuntimeExternalEffectKind
    let stableIdempotencyKey: RuntimeExternalStableIdempotencyKey
    let sourceOperationID: RuntimeExternalOperationID
    let sourceExternalReference: RuntimeExternalProviderReference
}

struct RuntimeExternalProviderReconciliationRequest: Sendable, Equatable {
    let operationID: RuntimeExternalOperationID
    let attemptID: RuntimeExternalAttemptID
    let kind: RuntimeExternalEffectKind
    let stableIdempotencyKey: RuntimeExternalStableIdempotencyKey
    let externalReference: RuntimeExternalProviderReference?
    let action: RuntimeCanonicalExternalOperationPayload.Action
    let sourceOperationID: RuntimeExternalOperationID?
    let sourceExternalReference: RuntimeExternalProviderReference?
}

enum RuntimeCanonicalExternalOperationError: Error, Sendable, Equatable {
    case migrationRequired(expected: Int, actual: Int)
    case corruptAuthority
    case invalidTransition
    case staleLease
    case alreadyTerminal
    case retryExhausted
    case providerUnavailable
    case firstRowExceedsBound
    case invalidCreation
    case executorAlreadyRunning
    case compensationBlocked([RuntimeExternalOperationID])
    case explicitExternalCompensationRequired([RuntimeExternalOperationID])
}
