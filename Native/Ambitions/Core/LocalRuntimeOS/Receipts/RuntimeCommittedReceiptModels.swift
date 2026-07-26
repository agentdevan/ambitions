import Foundation
import LocalAuthentication

let runtimeCommittedReceiptCoreVersion = 2
let runtimeCompensationPlanVersion = 1
let runtimeCompensationPolicyVersion = 1

enum RuntimeCompensationLimits {
    static let maximumTargets = 8
    static let maximumExternalOperations = 8
}

enum RuntimeCommittedReceiptLimits {
    static let maximumObjects = 8
    static let maximumArtifacts = 64
    static let maximumPresentationFacts = 32
    static let maximumRetentionReferences = 32
    static let maximumProjectionInvalidations = 32
    static let maximumPendingExternalOperations = RuntimeCompensationLimits.maximumExternalOperations
    static let maximumHistoryEntries = maximumObjects
    static let maximumObjectLinks = maximumObjects
    static let maximumTombstones = maximumObjects
}

enum RuntimeReceiptCancellationCheckpoint: Sendable, Equatable {
    case graphTraversal
    case terminalEventRead
    case replayCoverage
    case historyTraversal
    case eligibilityEvaluation
}

enum RuntimeReceiptCancellation {
#if DEBUG
    @TaskLocal static var injectedCheck: (@Sendable (
        RuntimeReceiptCancellationCheckpoint
    ) throws -> Void)?
#endif

    static func check(_ checkpoint: RuntimeReceiptCancellationCheckpoint) throws {
        try Task.checkCancellation()
#if DEBUG
        try injectedCheck?(checkpoint)
#else
        _ = checkpoint
#endif
    }
}

enum RuntimeReceiptExposure: String, Sendable, Equatable, Hashable {
    case full
    case redacted
    case denied
}

struct RuntimeReceiptReadAuthorization: Sendable, Equatable, Hashable, Comparable {
    let coreDigest: String
    let privacy: EventLedgerPrivacyClassification
    let exposure: RuntimeReceiptExposure

    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.coreDigest, lhs.privacy.rawValue, lhs.exposure.rawValue) <
            (rhs.coreDigest, rhs.privacy.rawValue, rhs.exposure.rawValue)
    }
}

enum RuntimeCommittedReceiptReadBounds {
    static let minimumAccessBytes = 65_536
    static let maximumPersistedPayloadBytes = 1_048_576
    static let maximumDispositionPayloadBytes = 262_144
    static let maximumEvidencePayloadBytes = 262_144
    static let maximumFinalizedResultPayloadBytes = 1_048_576
    static let selectedRowMetadataAllowanceBytes = 16_384
    static let maximumSelectedPayloadRowBytes =
        maximumPersistedPayloadBytes + selectedRowMetadataAllowanceBytes
    static let maximumCoreRowBytes = maximumSelectedPayloadRowBytes
    static let maximumPlanRowBytes = maximumSelectedPayloadRowBytes
    static let defaultAccessBytes = 4 * 1_048_576
    static let maximumAccessBudgetBytes = 16 * 1_048_576
    static let maximumAuthenticatedGraphBudgetBytes = 32 * 1_048_576

    static func authenticatedGraphBudgetBytes(baseBytes: Int) -> Int {
        let boundedBase = max(minimumAccessBytes, min(baseBytes, maximumAccessBudgetBytes))
        let (requiredBytes, overflow) = boundedBase.addingReportingOverflow(
            RuntimeExternalOperationLimits.maximumReceiptGraphBytes
        )
        return min(
            overflow ? maximumAuthenticatedGraphBudgetBytes : requiredBytes,
            maximumAuthenticatedGraphBudgetBytes
        )
    }

    static func maximumSelectedPayloadRowsBytes(expectedRows: Int) -> Int {
        let rowCount = max(0, expectedRows)
        let detectionRowCount = rowCount == Int.max ? Int.max : rowCount + 1
        let (bytes, overflow) = detectionRowCount.multipliedReportingOverflow(
            by: maximumSelectedPayloadRowBytes
        )
        return overflow ? Int.max : max(maximumSelectedPayloadRowBytes, bytes)
    }
}

struct RuntimeReceiptReadAccess: Sendable, Equatable, Hashable {
    let surface: SensitiveSurface
    let authorizations: Set<RuntimeReceiptReadAuthorization>
    let maximumRows: Int
    let maximumBytes: Int
    let digest: String

    private init(
        surface: SensitiveSurface,
        authorizations: Set<RuntimeReceiptReadAuthorization>,
        maximumRows: Int = 50,
        maximumBytes: Int = RuntimeCommittedReceiptReadBounds.defaultAccessBytes
    ) {
        self.surface = surface
        self.authorizations = authorizations
        self.maximumRows = max(1, min(maximumRows, 50))
        self.maximumBytes = max(
            RuntimeCommittedReceiptReadBounds.minimumAccessBytes,
            min(maximumBytes, RuntimeCommittedReceiptReadBounds.maximumAccessBudgetBytes)
        )
        let identity = [
            surface.rawValue,
            authorizations.sorted().map {
                "\($0.coreDigest):\($0.privacy.rawValue):\($0.exposure.rawValue)"
            }.joined(separator: ","),
            String(self.maximumRows),
            String(self.maximumBytes),
        ].joined(separator: "\u{0}")
        digest = LocalRuntimeStorageChecksum.sha256Hex(for: Data(identity.utf8))
    }

    fileprivate static func authorityIssued(
        surface: SensitiveSurface,
        authorizations: Set<RuntimeReceiptReadAuthorization>,
        maximumRows: Int,
        maximumBytes: Int
    ) -> Self {
        Self(
            surface: surface,
            authorizations: authorizations,
            maximumRows: maximumRows,
            maximumBytes: maximumBytes
        )
    }

    var authorizedReceiptDigests: Set<String> {
        Set(authorizations.map(\.coreDigest))
    }

    var fullReceiptDigests: Set<String> {
        Set(authorizations.filter { $0.exposure == .full }.map(\.coreDigest))
    }

    var redactedReceiptDigests: Set<String> {
        Set(authorizations.filter { $0.exposure == .redacted }.map(\.coreDigest))
    }

    func exposure(
        for receiptDigest: String,
        privacy: EventLedgerPrivacyClassification
    ) -> RuntimeReceiptExposure {
        authorizations.first {
            $0.coreDigest == receiptDigest && $0.privacy == privacy
        }?.exposure ?? .denied
    }
}

struct RuntimeReceiptAccessSubject: Sendable, Equatable, Hashable {
    let coreDigest: String
    let privacy: EventLedgerPrivacyClassification
}

enum RuntimeReceiptAccessPurpose: String, Sendable, Equatable, Hashable {
    case interactiveInspection = "interactive_inspection"
    case systemPresentation = "system_presentation"
}

struct RuntimeReceiptAccessRequest: Sendable, Equatable, Hashable {
    let surface: SensitiveSurface
    let purpose: RuntimeReceiptAccessPurpose
    let subjects: [RuntimeReceiptAccessSubject]
    let maximumRows: Int
    let maximumBytes: Int

    init(
        surface: SensitiveSurface,
        purpose: RuntimeReceiptAccessPurpose,
        subjects: [RuntimeReceiptAccessSubject],
        maximumRows: Int = 50,
        maximumBytes: Int = RuntimeCommittedReceiptReadBounds.defaultAccessBytes
    ) {
        self.surface = surface
        self.purpose = purpose
        self.subjects = subjects
        self.maximumRows = maximumRows
        self.maximumBytes = maximumBytes
    }
}

enum RuntimeReceiptPlatformAuthenticationOutcome: Sendable, Equatable {
    case authenticated
    case denied
    case unavailable
}

struct RuntimeReceiptPlatformAuthenticationRequest: Sendable, Equatable, Hashable {
    let challengeID: String
    let surface: SensitiveSurface
    let privacy: EventLedgerPrivacyClassification
}

actor RuntimeReceiptPlatformAuthenticationAuthority {
    func authenticate(
        _ request: RuntimeReceiptPlatformAuthenticationRequest
    ) async throws -> RuntimeReceiptPlatformAuthenticationOutcome {
        try Task.checkCancellation()
        guard request.surface == .localInspection else { return .denied }
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            return .unavailable
        }
        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Authenticate to inspect private Ambitions history."
            ) ? .authenticated : .denied
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return .denied
        }
    }
}

enum RuntimeReceiptDurableReviewOutcome: Sendable, Equatable {
    case reviewed
    case denied
    case unavailable
}

struct RuntimeReceiptDurableReviewRequest: Sendable, Equatable, Hashable {
    let subject: RuntimeReceiptAccessSubject
    let surface: SensitiveSurface
    let purpose: RuntimeReceiptAccessPurpose
}

/// Release behavior remains deny-only until T27/T31 supplies a durable,
/// authenticated review-grant store and production construction path.
actor RuntimeReceiptDurableReviewGrantAuthority {
    func authorize(
        _ request: RuntimeReceiptDurableReviewRequest
    ) async throws -> RuntimeReceiptDurableReviewOutcome {
        try Task.checkCancellation()
        _ = request
        return .unavailable
    }
}

/// The sole issuer of bounded receipt-read capabilities. Surface code submits
/// typed subjects; policy, review, and device authentication are evaluated here.
actor RuntimeReceiptAccessAuthority {
    private let authenticate: @Sendable (
        RuntimeReceiptPlatformAuthenticationRequest
    ) async throws -> RuntimeReceiptPlatformAuthenticationOutcome
    private let review: @Sendable (
        RuntimeReceiptDurableReviewRequest
    ) async throws -> RuntimeReceiptDurableReviewOutcome
    private let policy = SensitiveSurfacePolicy()

    init(
        authenticationAuthority: RuntimeReceiptPlatformAuthenticationAuthority,
        reviewAuthority: RuntimeReceiptDurableReviewGrantAuthority
    ) {
        authenticate = { request in
            try await authenticationAuthority.authenticate(request)
        }
        review = { request in
            try await reviewAuthority.authorize(request)
        }
    }

#if DEBUG
    init(
        testingAuthentication: @escaping @Sendable (
            RuntimeReceiptPlatformAuthenticationRequest
        ) async throws -> RuntimeReceiptPlatformAuthenticationOutcome,
        testingReview: @escaping @Sendable (
            RuntimeReceiptDurableReviewRequest
        ) async throws -> RuntimeReceiptDurableReviewOutcome = { _ in .unavailable }
    ) {
        authenticate = testingAuthentication
        review = testingReview
    }
#endif

    func issue(_ request: RuntimeReceiptAccessRequest) async throws -> RuntimeReceiptReadAccess? {
        try Task.checkCancellation()
        guard request.surface != .encryptedVault,
              request.subjects.count <= 50,
              Set(request.subjects).count == request.subjects.count,
              Set(request.subjects.map(\.coreDigest)).count == request.subjects.count else {
            return nil
        }
        var authorizations: Set<RuntimeReceiptReadAuthorization> = []
        for subject in request.subjects {
            try Task.checkCancellation()
            guard RuntimeStoreManifestCodec.isSHA256Hex(subject.coreDigest),
                  subject.coreDigest == subject.coreDigest.lowercased() else {
                return nil
            }
            let object = PrivacyClassifier().classifyEvent(
                id: subject.coreDigest,
                family: "runtime_receipt",
                title: "Committed receipt",
                privacy: subject.privacy
            )
            var localAuthenticationSatisfied = false
            var userReviewed = false
            var decision = policy.decision(for: object, surface: request.surface)
            if decision.requiresLocalAuthentication {
                let outcome = try await authenticate(RuntimeReceiptPlatformAuthenticationRequest(
                    challengeID: LocalRuntimeStorageChecksum.sha256Hex(for: Data(
                        "\(subject.coreDigest)\u{0}\(request.surface.rawValue)".utf8
                    )),
                    surface: request.surface,
                    privacy: subject.privacy
                ))
                localAuthenticationSatisfied = outcome == .authenticated
            }
            if decision.requiresUserReview {
                let outcome = try await review(RuntimeReceiptDurableReviewRequest(
                    subject: subject,
                    surface: request.surface,
                    purpose: request.purpose
                ))
                userReviewed = outcome == .reviewed
            }
            decision = policy.decision(
                for: object,
                surface: request.surface,
                userReviewed: userReviewed,
                localAuthenticationSatisfied: localAuthenticationSatisfied
            )
            guard decision.allowed,
                  decision.issues.contains(.reviewRequired) == false,
                  decision.issues.contains(.localAuthenticationRequired) == false else {
                continue
            }
            authorizations.insert(RuntimeReceiptReadAuthorization(
                coreDigest: subject.coreDigest,
                privacy: subject.privacy,
                exposure: decision.requiresRedaction ? .redacted : .full
            ))
        }
        return .authorityIssued(
            surface: request.surface,
            authorizations: authorizations,
            maximumRows: request.maximumRows,
            maximumBytes: request.maximumBytes
        )
    }
}

enum RuntimeCommittedReceiptOutcome: String, Codable, Sendable, Equatable, Hashable {
    case changed
}

struct RuntimeCommittedReceiptPrivacy: Codable, Sendable, Equatable, Hashable {
    let classification: EventLedgerPrivacyClassification
    let localOnly: Bool
}

struct RuntimeCommittedReceiptObjectLink: Codable, Sendable, Equatable, Hashable, Comparable {
    let aggregate: RuntimeSemanticAggregate
    let priorRevision: UInt64?
    let terminalRevision: UInt64
    let lifecycle: RuntimeAggregateLifecycle
    let transition: RuntimeObjectTransitionKind
    let stateDigest: String

    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.aggregate.kind.rawValue, lhs.aggregate.id.rawValue) <
            (rhs.aggregate.kind.rawValue, rhs.aggregate.id.rawValue)
    }
}

enum RuntimeCommittedReceiptArtifactKind: String, Codable, Sendable, Equatable, Hashable {
    case terminalEvent = "terminal_event"
    case projectionInvalidation = "projection_invalidation"
    case tombstoneHistory = "tombstone_history"
    case externalOperation = "external_operation"
    case compensationPlan = "compensation_plan"
    case irreversibilityEvidence = "irreversibility_evidence"
}

struct RuntimeCommittedReceiptArtifactLink: Codable, Sendable, Equatable, Hashable, Comparable {
    let kind: RuntimeCommittedReceiptArtifactKind
    let stableID: String
    let digest: String?

    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.kind.rawValue, lhs.stableID) < (rhs.kind.rawValue, rhs.stableID)
    }
}

enum RuntimeCommittedReceiptPresentationFact: Codable, Sendable, Equatable, Hashable, Comparable {
    case objectChanged(family: RuntimeSemanticAggregateKind, lifecycle: RuntimeAggregateLifecycle)
    case externalWorkPending(kind: RuntimeExternalEffectKind)
    case compensationPlanRecorded
    case compensationUnavailable

    private var canonicalKey: String {
        switch self {
        case let .objectChanged(family, lifecycle):
            "object_changed\u{0}\(family.rawValue)\u{0}\(lifecycle.rawValue)"
        case let .externalWorkPending(kind):
            "external_work_pending\u{0}\(kind.rawValue)"
        case .compensationPlanRecorded:
            "compensation_plan_recorded"
        case .compensationUnavailable:
            "compensation_unavailable"
        }
    }

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.canonicalKey < rhs.canonicalKey }
}

enum RuntimeReceiptRetentionReferenceKind: String, Codable, Sendable, Equatable, Hashable {
    case objectHistory = "object_history"
    case tombstoneHistory = "tombstone_history"
    case compensationSource = "compensation_source"
    case externalOperation = "external_operation"
}

struct RuntimeReceiptRetentionReference: Codable, Sendable, Equatable, Hashable, Comparable {
    let kind: RuntimeReceiptRetentionReferenceKind
    let stableID: String
    let retainUntil: Date?

    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.kind.rawValue, lhs.stableID) < (rhs.kind.rawValue, rhs.stableID)
    }
}

enum RuntimeSemanticCompensationAction: Codable, Sendable, Equatable, Hashable {
    case discardCreatedCapture(RuntimeDomainObjectID)
    case discardCreatedGoal(RuntimeDomainObjectID)
    case discardCreatedSchedule(RuntimeDomainObjectID)
    case discardCreatedReminder(RuntimeDomainObjectID)

    var aggregateKind: RuntimeSemanticAggregateKind {
        switch self {
        case .discardCreatedCapture: .capture
        case .discardCreatedGoal: .goal
        case .discardCreatedSchedule: .schedule
        case .discardCreatedReminder: .reminder
        }
    }

    var transition: RuntimeObjectTransitionKind {
        switch self {
        case .discardCreatedCapture, .discardCreatedGoal, .discardCreatedSchedule, .discardCreatedReminder:
            .tombstone
        }
    }

    var primaryObjectID: RuntimeDomainObjectID {
        switch self {
        case let .discardCreatedCapture(id), let .discardCreatedGoal(id),
             let .discardCreatedSchedule(id), let .discardCreatedReminder(id): id
        }
    }

    var target: AmbitionsCommandTarget {
        switch self {
        case let .discardCreatedCapture(id):
            AmbitionsCommandTarget(captureID: id.rawValue)
        case let .discardCreatedGoal(id):
            AmbitionsCommandTarget(goalID: id.rawValue)
        case let .discardCreatedSchedule(id):
            AmbitionsCommandTarget(timeID: id.rawValue)
        case let .discardCreatedReminder(id):
            AmbitionsCommandTarget(timeID: id.rawValue)
        }
    }
}

enum RuntimeIrreversibilityPermanence: String, Codable, Sendable, Equatable, Hashable {
    case semantic
    case currentRuntimeUnsupported = "current_runtime_unsupported"
}

enum RuntimeIrreversibilityReason: String, Codable, Sendable, Equatable, Hashable {
    case destructiveErasure = "destructive_erasure"
    case missingPriorSemanticValue = "missing_prior_semantic_value"
    case externalEffectConstraint = "external_effect_constraint"
    case legacyProjectionAuthority = "legacy_projection_authority"
    case compensationOfCompensation = "compensation_of_compensation"
    case unsupportedSemanticInverse = "unsupported_semantic_inverse"
}

struct RuntimeIrreversibilityEvidence: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let permanence: RuntimeIrreversibilityPermanence
    let reason: RuntimeIrreversibilityReason
    let commandFamily: String
    let commandAction: String
}

struct RuntimeCompensationPlanIntent: Codable, Sendable, Equatable, Hashable {
    let planID: RuntimeRollbackPlanID
    let action: RuntimeSemanticCompensationAction
    let policyVersion: Int
    let expiresAt: Date
    let requiresConfirmation: Bool
}

enum RuntimeCompensationDispositionIntent: Codable, Sendable, Equatable, Hashable {
    case typedPlan(RuntimeCompensationPlanIntent)
    case noncompensable(RuntimeIrreversibilityEvidence)
}

struct RuntimeCompensationTargetExpectation: Codable, Sendable, Equatable, Hashable, Comparable {
    let aggregate: RuntimeSemanticAggregate
    let sourcePriorRevision: UInt64?
    let sourceRevision: UInt64
    let sourceTransition: RuntimeObjectTransitionKind
    let requiredCurrentRevision: UInt64
    let requiredLifecycle: RuntimeAggregateLifecycle
    let sourceStateDigest: String
    /// The exact transition the compensation command must apply. This is not
    /// the transition recorded by the source receipt.
    let inverseTransition: RuntimeObjectTransitionKind

    static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.aggregate.kind.rawValue, lhs.aggregate.id.rawValue) <
            (rhs.aggregate.kind.rawValue, rhs.aggregate.id.rawValue)
    }
}

struct RuntimeCommittedCompensationPlan: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let planID: RuntimeRollbackPlanID
    let sourceReceiptID: RuntimeReceiptID
    let sourceLineage: RuntimeAuthorityLineageReference
    let sourceCorrelationID: RuntimeCorrelationID
    let action: RuntimeSemanticCompensationAction
    let targets: [RuntimeCompensationTargetExpectation]
    let externalOperationIDs: [RuntimeExternalOperationID]
    let privacy: RuntimeCommittedReceiptPrivacy
    let policyVersion: Int
    let expiresAt: Date
    let requiresConfirmation: Bool
    let digest: String
}

enum RuntimeCommittedCompensationDisposition: Codable, Sendable, Equatable, Hashable {
    case plan(planID: RuntimeRollbackPlanID, digest: String, expiresAt: Date, requiresConfirmation: Bool)
    case noncompensable(evidenceDigest: String, evidence: RuntimeIrreversibilityEvidence)
}

struct RuntimeCommittedReceiptCoreFacts: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let receiptID: RuntimeReceiptID
    let preparationID: RuntimePreparationID
    let commandID: RuntimeCommandID
    let lineage: RuntimeAuthorityLineageReference
    let correlationID: RuntimeCorrelationID
    let outcome: RuntimeCommittedReceiptOutcome
    let committedAt: Date
    let privacy: RuntimeCommittedReceiptPrivacy
    let objects: [RuntimeCommittedReceiptObjectLink]
    let artifacts: [RuntimeCommittedReceiptArtifactLink]
    let presentationFacts: [RuntimeCommittedReceiptPresentationFact]
    let compensation: RuntimeCommittedCompensationDisposition
    let retention: [RuntimeReceiptRetentionReference]
    let confirmationToken: RuntimeConfirmationToken?
    let confirmationDecisionDigest: RuntimeCommandFingerprint?
}

struct RuntimeCommittedReceiptCore: Codable, Sendable, Equatable, Hashable {
    let facts: RuntimeCommittedReceiptCoreFacts
    let receiptDigest: String
}

struct RuntimeFinalizedIdempotencyReference: Codable, Sendable, Equatable, Hashable {
    let resultVersion: Int
    let resultChecksum: String
    let finalizedAt: Date
}

struct RuntimeCommittedReceiptConfirmationReference: Sendable, Equatable, Hashable {
    let receiptID: RuntimeReceiptID
    let preparationID: RuntimePreparationID
    let commandID: RuntimeCommandID
    let token: RuntimeConfirmationToken
    let decisionDigest: RuntimeCommandFingerprint
    let terminalEventSequence: UInt64
    let consumedAt: Date
}

/// Privacy-safe current truth derived only after the complete external-operation
/// authority graph has authenticated. Provider references, request payloads,
/// leases, titles, and failure evidence deliberately do not cross this boundary.
struct RuntimeAuthenticatedExternalOperationSummary: Sendable, Equatable, Hashable {
    let operationID: RuntimeExternalOperationID
    let kind: RuntimeExternalEffectKind
    let workflowStatus: RuntimeExternalWorkflowStatus
    let effectDisposition: RuntimeExternalEffectDisposition
    /// Nil for schema-v6 compatibility rows, which did not persist normalized
    /// workflow revisions or attempt authority.
    let statusVersion: UInt64?
    let attemptCount: Int?
}

enum RuntimeExternalCompensationAuthority: Sendable, Equatable, Hashable {
    case clear
    case unresolved(operationIDs: [RuntimeExternalOperationID])
    case externalCompensationRequired(operationIDs: [RuntimeExternalOperationID])
}

enum RuntimeReceiptReplayInvalidationReason: String, Codable, Sendable, Equatable, Hashable {
    case quarantineOccurrence = "quarantine_occurrence"
}

enum RuntimeReceiptReplayCoverage: Sendable, Equatable, Hashable {
    case verifiedThrough(eventSequence: UInt64)
    case verificationPending
    case invalidated(
        reason: RuntimeReceiptReplayInvalidationReason,
        fingerprint: RuntimeAuthorityFailureFingerprint
    )
}

struct RuntimeCommittedReceipt: Sendable, Equatable, Hashable, Identifiable {
    var id: String { core.facts.receiptID.rawValue }
    let core: RuntimeCommittedReceiptCore
    let finalizedIdempotency: RuntimeFinalizedIdempotencyReference
    let replayCoverage: RuntimeReceiptReplayCoverage
    let externalOperations: [RuntimeAuthenticatedExternalOperationSummary]
}

struct RuntimeCompensationCommand: Codable, Sendable, Equatable, Hashable {
    let sourceReceiptID: RuntimeReceiptID
    let planID: RuntimeRollbackPlanID
    let planDigest: String
    let sourceLineage: RuntimeAuthorityLineageReference
    let action: RuntimeSemanticCompensationAction
    let targets: [RuntimeCompensationTargetExpectation]
    let requiresConfirmation: Bool
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
}

enum RuntimeReceiptSourceBlockedReason: String, Codable, Sendable, Equatable, Hashable {
    case corruptReceiptCore = "corrupt_receipt_core"
    case futureReceiptVersion = "future_receipt_version"
    case futureCompensationPlanVersion = "future_compensation_plan_version"
    case idempotencyMismatch = "idempotency_mismatch"
    case terminalEventMissing = "terminal_event_missing"
    case terminalEventQuarantined = "terminal_event_quarantined"
    case eventDependencyQuarantined = "event_dependency_quarantined"
    case terminalEventIntegrityMismatch = "terminal_event_integrity_mismatch"
    case objectHistoryMismatch = "object_history_mismatch"
    case compensationDispositionMismatch = "compensation_disposition_mismatch"
    case privacyDenied = "privacy_denied"
}

struct RuntimeAuthorityFailureFingerprint: RawRepresentable, Codable, Sendable, Equatable, Hashable {
    let rawValue: String

    init?(rawValue: String) {
        guard RuntimeStoreManifestCodec.isSHA256Hex(rawValue), rawValue == rawValue.lowercased() else {
            return nil
        }
        self.rawValue = rawValue
    }
}

enum RuntimeCompensationEligibility: Codable, Sendable, Equatable, Hashable {
    case available
    case confirmationRequired
    case expired
    case consumed(compensationReceiptID: RuntimeReceiptID)
    case stale
    /// Schema-v6 compatibility result. Schema-v7 authority uses
    /// `unresolvedExternalWork` so a terminal confirmed-present effect is never
    /// misleadingly described as pending.
    case pendingExternalWork(operationIDs: [RuntimeExternalOperationID])
    case unresolvedExternalWork(operationIDs: [RuntimeExternalOperationID])
    case externalCompensationRequired(operationIDs: [RuntimeExternalOperationID])
    case irreversible(RuntimeIrreversibilityEvidence)
    case unsupported(RuntimeIrreversibilityEvidence)
    case sourceBlocked(
        reason: RuntimeReceiptSourceBlockedReason,
        fingerprint: RuntimeAuthorityFailureFingerprint?
    )
    case unavailable
}

struct RuntimeCompensationOfferContext: Sendable, Equatable, Hashable {
    let commandID: RuntimeCommandID
    let idempotencyKey: CommandIdempotencyKey
    let source: AmbitionsCommandSource

    init?(
        commandID: RuntimeCommandID,
        idempotencyKey: CommandIdempotencyKey,
        source: AmbitionsCommandSource
    ) {
        let allowedSources: Set<AmbitionsCommandSource> = [
            .today, .goals, .capture, .time, .you, .reviews, .goalDetail,
        ]
        guard allowedSources.contains(source),
              idempotencyKey.isWellFormed,
              idempotencyKey.schemaVersion == commandIdempotencyKeySchemaVersion,
              idempotencyKey.rawValue.utf8.count <= 256,
              idempotencyKey.rawValue == idempotencyKey.rawValue
                .trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }
        self.commandID = commandID
        self.idempotencyKey = idempotencyKey
        self.source = source
    }
}

struct RuntimeCompensationOffer: Sendable, Equatable {
    let command: RuntimeCompensationFeatureCommand
    let eligibility: RuntimeCompensationEligibility
}

enum RuntimeCompensationOfferState: Sendable, Equatable {
    case ready(RuntimeCompensationOffer)
    case unavailable(RuntimeCompensationEligibility)
}

struct RuntimeReceiptCursor: Codable, Sendable, Equatable, Hashable {
    let highWaterEventSequence: UInt64
    let eventSequence: UInt64
    let accessPolicyDigest: String
}

struct RuntimeObjectHistoryCursor: Codable, Sendable, Equatable, Hashable {
    let highWaterEventSequence: UInt64
    let eventSequence: UInt64
    let historyID: String
    let accessPolicyDigest: String
    let queryBindingDigest: String
}

enum RuntimeReceiptAuthorityState: Sendable, Equatable {
    case available(RuntimeCommittedReceipt)
    case redacted(RuntimeCommittedReceiptRedactedView)
    case sourceBlocked(reason: RuntimeReceiptSourceBlockedReason, fingerprint: RuntimeAuthorityFailureFingerprint?)
    case unavailable
}

struct RuntimeCommittedReceiptRedactedView: Sendable, Equatable {
    let committedAt: Date
    let outcome: RuntimeCommittedReceiptOutcome
    let privacy: EventLedgerPrivacyClassification
    let affectedFamilies: [RuntimeSemanticAggregateKind]
    let compensation: RuntimeRedactedCompensationEligibility
    let replayCoverage: RuntimeReceiptReplayCoverage
}

enum RuntimeRedactedCompensationEligibility: String, Codable, Sendable, Equatable, Hashable {
    case available
    case confirmationRequired = "confirmation_required"
    case expired
    case consumed
    case stale
    case pendingExternalWork = "pending_external_work"
    case unresolvedExternalWork = "unresolved_external_work"
    case externalCompensationRequired = "external_compensation_required"
    case irreversible
    case unsupported
    case sourceBlocked = "source_blocked"
    case unavailable
}

struct RuntimeReceiptPage: Sendable, Equatable {
    let items: [RuntimeReceiptAuthorityState]
    let nextCursor: RuntimeReceiptCursor?
}

struct RuntimeObjectHistoryEntry: Codable, Sendable, Equatable, Hashable {
    let historyID: String
    let receiptID: RuntimeReceiptID
    let lineage: RuntimeAuthorityLineageReference
    let object: RuntimeCommittedReceiptObjectLink
    let privacy: RuntimeCommittedReceiptPrivacy
}

struct RuntimeObjectHistoryPage: Sendable, Equatable {
    let items: [RuntimeObjectHistoryAuthorityState]
    let nextCursor: RuntimeObjectHistoryCursor?
}

enum RuntimeObjectHistoryAuthorityState: Sendable, Equatable {
    case available(RuntimeObjectHistoryEntry)
    case redacted(
        committedAt: Date,
        family: RuntimeSemanticAggregateKind,
        lifecycle: RuntimeAggregateLifecycle,
        transition: RuntimeObjectTransitionKind
    )
    case sourceBlocked(
        reason: RuntimeReceiptSourceBlockedReason,
        fingerprint: RuntimeAuthorityFailureFingerprint?
    )
}
