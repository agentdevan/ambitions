import Foundation

let runtimePreparationSchemaVersion = "runtime_preparation.native.v1"

struct RuntimePreparationID: RawRepresentable, Codable, Sendable, Equatable, Hashable {
    let rawValue: String

    init?(rawValue: String) {
        guard rawValue.isEmpty == false,
              rawValue == rawValue.trimmingCharacters(in: .whitespacesAndNewlines),
              rawValue == rawValue.precomposedStringWithCanonicalMapping else { return nil }
        self.rawValue = rawValue
    }
}

struct RuntimeCommandFingerprint: RawRepresentable, Codable, Sendable, Equatable, Hashable {
    let rawValue: String

    init?(rawValue: String) {
        guard rawValue.count == 64,
              rawValue.utf8.allSatisfy({ (48...57).contains($0) || (97...102).contains($0) }) else { return nil }
        self.rawValue = rawValue
    }
}

struct RuntimeConfirmationToken: RawRepresentable, Codable, Sendable, Equatable, Hashable {
    let rawValue: String

    init?(rawValue: String) {
        guard rawValue.isEmpty == false,
              rawValue == rawValue.trimmingCharacters(in: .whitespacesAndNewlines),
              rawValue == rawValue.precomposedStringWithCanonicalMapping else { return nil }
        self.rawValue = rawValue
    }
}

struct RuntimeRollbackPlanID: RawRepresentable, Codable, Sendable, Equatable, Hashable {
    let rawValue: String

    init?(rawValue: String) {
        guard let value = RuntimeDomainObjectID(rawValue: rawValue), value.rawValue == rawValue else { return nil }
        self.rawValue = value.rawValue
    }
}

enum RuntimeRecoveryKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case undo, rollback, retry, reconcile, inspect, restore, none
}

enum RuntimeRecoveryReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case preparedMutation = "prepared_mutation"
    case noMutation = "no_mutation"
    case unsupportedInput = "unsupported_input"
    case missingHandler = "missing_handler"
    case invalidSemanticInput = "invalid_semantic_input"
    case snapshotReadFailed = "snapshot_read_failed"
    case identityMismatch = "identity_mismatch"
    case revisionMismatch = "revision_mismatch"
    case privacyDenied = "privacy_denied"
    case actorDenied = "actor_denied"
    case confirmationRequired = "confirmation_required"
    case confirmationRejected = "confirmation_rejected"
    case confirmationExpired = "confirmation_expired"
    case confirmationMismatch = "confirmation_mismatch"
    case confirmationConsumed = "confirmation_consumed"
    case authorityUnavailable = "authority_unavailable"
    case authorityRejected = "authority_rejected"
    case authorityFailed = "authority_failed"
    case staleAfterPreparation = "stale_after_preparation"
    case projectionDegraded = "projection_degraded"
}

struct RuntimeRecovery: Codable, Sendable, Equatable, Hashable {
    let kind: RuntimeRecoveryKind
    let reason: RuntimeRecoveryReason
    let target: AmbitionsCommandTarget
    let redactedDetail: String?

    static func inspect(_ reason: RuntimeRecoveryReason, target: AmbitionsCommandTarget = AmbitionsCommandTarget()) -> RuntimeRecovery {
        RuntimeRecovery(kind: .inspect, reason: reason, target: target, redactedDetail: nil)
    }

    static func none(_ reason: RuntimeRecoveryReason, target: AmbitionsCommandTarget) -> RuntimeRecovery {
        RuntimeRecovery(kind: .none, reason: reason, target: target, redactedDetail: nil)
    }
}

struct RuntimeReadDependency: Codable, Sendable, Equatable, Hashable {
    let objectID: RuntimeDomainObjectID
    let expectedRevision: RuntimeExpectedRevision
    let observedRevision: RuntimeExpectedRevision
}

struct RuntimeCursorEvidence: Codable, Sendable, Equatable, Hashable {
    enum Kind: String, Codable, Sendable, Equatable, Hashable { case event, projection }
    let kind: Kind
    let ownerID: String
    let cursor: UInt64
}

struct RuntimeMutationReadSet: Codable, Sendable, Equatable, Hashable {
    let objects: [RuntimeReadDependency]
    let cursors: [RuntimeCursorEvidence]
    let privacy: EventLedgerPrivacyClassification

    init(objects: [RuntimeReadDependency], cursors: [RuntimeCursorEvidence], privacy: EventLedgerPrivacyClassification) {
        self.objects = objects.sorted { $0.objectID.rawValue < $1.objectID.rawValue }
        self.cursors = cursors.sorted {
            if $0.kind != $1.kind { return $0.kind.rawValue < $1.kind.rawValue }
            if $0.ownerID != $1.ownerID { return $0.ownerID < $1.ownerID }
            return $0.cursor < $1.cursor
        }
        self.privacy = privacy
    }
}

enum RuntimeObjectTransitionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case create, update, attach, detach, tombstone, restore
}

struct RuntimeObjectTransitionIntent: Codable, Sendable, Equatable, Hashable {
    let objectID: RuntimeDomainObjectID
    let expectedRevision: RuntimeExpectedRevision
    let transition: RuntimeObjectTransitionKind
    let family: String
}

enum RuntimeSemanticEventIntentKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case captureChanged = "capture_changed"
    case goalChanged = "goal_changed"
    case stepChanged = "step_changed"
    case scheduleChanged = "schedule_changed"
    case reminderChanged = "reminder_changed"
    case preferencesChanged = "preferences_changed"
    case historyChanged = "history_changed"
    case repairRequested = "repair_requested"
    case importDeletionRequested = "import_deletion_requested"
    case externalOperationProposed = "external_operation_proposed"
}

struct RuntimeSemanticEventIntent: Codable, Sendable, Equatable, Hashable {
    let id: RuntimeEventID
    let kind: RuntimeSemanticEventIntentKind
    let commandID: RuntimeCommandID
    let target: AmbitionsCommandTarget
    let occurredAt: String
    let privacy: EventLedgerPrivacyClassification
}

enum RuntimeExternalEffectIntent: Codable, Sendable, Equatable, Hashable {
    case none
    case outbox(operationID: RuntimeExternalOperationID, kind: RuntimeExternalEffectKind)
}

enum RuntimeEffectOrdering: String, Codable, Sendable, Equatable, Hashable {
    case notApplicable = "not_applicable"
    case afterLocalAuthorityAcceptance = "after_local_authority_acceptance"
}

struct RuntimeMutationWriteSet: Codable, Sendable, Equatable, Hashable {
    let transitions: [RuntimeObjectTransitionIntent]
    let events: [RuntimeSemanticEventIntent]
    let projectionInvalidations: [String]
    let receiptIntentID: RuntimeReceiptID?
    let rollbackIntentID: RuntimeRollbackPlanID?
    let externalEffect: RuntimeExternalEffectIntent
    let effectOrdering: RuntimeEffectOrdering

    init(
        transitions: [RuntimeObjectTransitionIntent],
        events: [RuntimeSemanticEventIntent],
        projectionInvalidations: [String],
        receiptIntentID: RuntimeReceiptID?,
        rollbackIntentID: RuntimeRollbackPlanID?,
        externalEffect: RuntimeExternalEffectIntent
    ) {
        self.transitions = transitions.sorted { $0.objectID.rawValue < $1.objectID.rawValue }
        self.events = events.sorted { $0.id.rawValue < $1.id.rawValue }
        self.projectionInvalidations = Array(Set(projectionInvalidations.filter { $0.isEmpty == false })).sorted()
        self.receiptIntentID = receiptIntentID
        self.rollbackIntentID = rollbackIntentID
        self.externalEffect = externalEffect
        self.effectOrdering = externalEffect == .none ? .notApplicable : .afterLocalAuthorityAcceptance
    }
}

enum RuntimeReducerDisposition: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case apply, unchanged, blocked, unsupported
}

enum RuntimeConfirmationScope: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case protectedPlacement = "protected_placement"
    case destructiveMutation = "destructive_mutation"
    case export
    case calendarOutbox = "calendar_outbox"
    case reminderOutbox = "reminder_outbox"
    case externalOperation = "external_operation"
    case legacyCalendarCompatibility = "legacy_calendar_compatibility"
}

struct RuntimeReducerDecision: Codable, Sendable, Equatable, Hashable {
    let family: String
    let action: String
    let disposition: RuntimeReducerDisposition
    let readSet: RuntimeMutationReadSet
    let writeSet: RuntimeMutationWriteSet
    let confirmationScope: RuntimeConfirmationScope?
    let reason: RuntimeRecoveryReason?
    let recovery: RuntimeRecovery
}

enum RuntimePreparationAuthorizationState: String, Codable, Sendable, Equatable, Hashable {
    case authorized, denied
}

struct RuntimePreparationAuthorization: Codable, Sendable, Equatable, Hashable {
    let state: RuntimePreparationAuthorizationState
    let actor: AmbitionsCommandActor
    let source: AmbitionsCommandSource
    let expectedRevision: RuntimeExpectedRevision
    let observedRevision: RuntimeExpectedRevision
    let privacyBoundary: PrivacyBoundary
    let sideEffectPolicy: CommandSideEffectPolicy
    let reasonCodes: [RuntimeRecoveryReason]

    var isAuthorized: Bool { state == .authorized }
}

struct RuntimeConfirmationRequest: Codable, Sendable, Equatable, Hashable {
    let token: RuntimeConfirmationToken
    let preparationID: RuntimePreparationID
    let commandID: RuntimeCommandID
    let commandFingerprint: RuntimeCommandFingerprint
    let actor: AmbitionsCommandActor
    let scope: RuntimeConfirmationScope
    let target: AmbitionsCommandTarget
    let decisionDigest: RuntimeCommandFingerprint
    let issuedAt: Date
    let expiresAt: Date
    let oneUse: Bool
}

enum RuntimeConfirmationDecision: String, Codable, Sendable, Equatable, Hashable { case approved, rejected }

struct RuntimeMutationConfirmation: Codable, Sendable, Equatable, Hashable {
    let token: RuntimeConfirmationToken
    let preparationID: RuntimePreparationID
    let commandID: RuntimeCommandID
    let commandFingerprint: RuntimeCommandFingerprint
    let actor: AmbitionsCommandActor
    let scope: RuntimeConfirmationScope
    let target: AmbitionsCommandTarget
    let decisionDigest: RuntimeCommandFingerprint
    let decision: RuntimeConfirmationDecision
    let decidedAt: Date
}

struct RuntimePreparation: Codable, Sendable, Equatable, Hashable, Identifiable {
    var id: String { preparationID.rawValue }
    let preparationID: RuntimePreparationID
    let command: AmbitionsCommand
    let commandID: RuntimeCommandID
    let commandFingerprint: RuntimeCommandFingerprint
    let commandVersion: Int
    let decision: RuntimeReducerDecision
    let decisionDigest: RuntimeCommandFingerprint
    let authorization: RuntimePreparationAuthorization
    let confirmationRequest: RuntimeConfirmationRequest?
    let issuedAt: Date
    let expiresAt: Date
    let schemaVersion: String
}

struct RuntimePreparationFailure: Codable, Sendable, Equatable, Hashable {
    let commandID: String?
    let reason: RuntimeRecoveryReason
    let recovery: RuntimeRecovery
    let originalBytes: Data?
}

enum RuntimePreparationOutcome: Codable, Sendable, Equatable, Hashable {
    case ready(RuntimePreparation)
    case requiresConfirmation(RuntimePreparation)
    case blocked(RuntimePreparationFailure)
    case unsupported(RuntimePreparationFailure)
}

struct RuntimeCommittedMutation: Codable, Sendable, Equatable, Hashable {
    let preparationID: RuntimePreparationID
    let commandID: RuntimeCommandID
    let authorityReceiptID: RuntimeReceiptID
    let projectionDegradation: [String]
}

struct RuntimeTerminalResult: Codable, Sendable, Equatable, Hashable {
    let preparationID: RuntimePreparationID?
    let commandID: String?
    let reason: RuntimeRecoveryReason
    let recovery: RuntimeRecovery
}

enum RuntimeCommandOutcome: Codable, Sendable, Equatable, Hashable {
    case changed(RuntimeCommittedMutation)
    case unchanged(RuntimeTerminalResult)
    case blocked(RuntimeTerminalResult)
    case failed(RuntimeTerminalResult)
    case unsupported(RuntimeTerminalResult)
}

struct RuntimePreparationSnapshot: Codable, Sendable, Equatable, Hashable {
    let observedRevision: RuntimeExpectedRevision
    let objectRevisions: [RuntimeDomainObjectID: RuntimeExpectedRevision]
    let cursors: [RuntimeCursorEvidence]
    let privacy: EventLedgerPrivacyClassification

    static func empty(privacy: EventLedgerPrivacyClassification) -> RuntimePreparationSnapshot {
        RuntimePreparationSnapshot(observedRevision: .absent, objectRevisions: [:], cursors: [], privacy: privacy)
    }
}

struct RuntimePreparationReadRequest: Codable, Sendable, Equatable, Hashable {
    let commandID: RuntimeCommandID
    let targetIDs: [RuntimeDomainObjectID]
    let expectedRevision: RuntimeExpectedRevision
    let privacy: EventLedgerPrivacyClassification
}

protocol RuntimePreparationReading: Sendable {
    func read(_ request: RuntimePreparationReadRequest) async throws -> RuntimePreparationSnapshot
}

struct RuntimePreparationContext: Sendable, Equatable {
    let preparationID: RuntimePreparationID
    let confirmationToken: RuntimeConfirmationToken
    let proposedObjectID: RuntimeDomainObjectID?
    let eventID: RuntimeEventID
    let receiptID: RuntimeReceiptID
    let rollbackPlanID: RuntimeRollbackPlanID
    let externalOperationID: RuntimeExternalOperationID
    let issuedAt: Date
    let expiresAt: Date
    let boundary: PrivateLifeRuntimeBoundary
}

protocol RuntimeMutationPreparing: Sendable {
    func prepare(_ command: AmbitionsCommand, context: RuntimePreparationContext) async -> RuntimePreparationOutcome
}

enum RuntimeAuthorityAcceptance: Sendable, Equatable {
    case committed(RuntimeCommittedMutation)
    case unchanged(RuntimeRecovery)
    case rejected(RuntimeRecovery)
    case failed(RuntimeRecovery)
    case unsupported(RuntimeRecovery)
}

protocol RuntimeMutationAuthorityAccepting: Sendable {
    /// T07/T09 authority must consume confirmation only in the same accepted transaction
    /// that records the mutation, and must replay the original committed result by preparation ID.
    func accept(_ preparation: RuntimePreparation, confirmation: RuntimeMutationConfirmation?) async -> RuntimeAuthorityAcceptance
}

protocol RuntimeMutationSubmitting: Sendable {
    func commit(_ preparation: RuntimePreparation, confirmation: RuntimeMutationConfirmation?) async -> RuntimeCommandOutcome
}
