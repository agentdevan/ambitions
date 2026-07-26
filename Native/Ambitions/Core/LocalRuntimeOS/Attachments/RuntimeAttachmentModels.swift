import Foundation

let runtimeCanonicalAttachmentSchemaVersion = 8
let runtimeCanonicalAttachmentModelVersion = 1

enum RuntimeAttachmentLimits {
    static let maximumAttachmentBytes: Int64 = 512 * 1_024 * 1_024
    static let maximumChunkBytes = 1_024 * 1_024
    static let minimumChunkBytes = 16 * 1_024
    static let maximumChunks = 32_768
    static let maximumFilenameBytes = 255
    static let maximumContentTypeBytes = 128
    static let maximumSignatureBytes = 64
    static let maximumManifestBytes = 128 * 1_024
    static let maximumEnvelopeBytes = 16 * 1_024
    static let maximumHistoryEntries = 4_096
    static let maximumReferences = 4_096
    static let maximumHolds = 256
    static let maximumPageSize = 200
    static let maximumPageBytes = 4 * 1_024 * 1_024
    static let maximumLeaseSeconds: TimeInterval = 15 * 60
    static let maximumQuotaReservationSeconds: TimeInterval = 60 * 60
    static let maximumQuotaBytesPerPrivacyDomain: Int64 = 8 * 1_024 * 1_024 * 1_024
    static let maximumRecoveryAttempts = 32
    static let maximumRecoveryBackoffSeconds: TimeInterval = 24 * 60 * 60
    static let maximumStagedLifetimeSeconds: TimeInterval = 24 * 60 * 60
}

protocol RuntimeAttachmentIdentity: RawRepresentable, Codable, Sendable, Equatable, Hashable, Comparable
where RawValue == String {
    init?(rawValue: String)
}

extension RuntimeAttachmentIdentity {
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    static func validate(_ raw: String, maximumBytes: Int = 1_024) -> String? {
        guard raw.isEmpty == false,
              raw == raw.trimmingCharacters(in: .whitespacesAndNewlines),
              raw == raw.precomposedStringWithCanonicalMapping,
              raw.utf8.count <= maximumBytes,
              raw.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false else {
            return nil
        }
        return raw
    }
}

struct RuntimeAttachmentID: RuntimeAttachmentIdentity {
    let rawValue: String
    init?(rawValue: String) { guard let value = Self.validate(rawValue) else { return nil }; self.rawValue = value }
}

struct RuntimeAttachmentRevisionID: RuntimeAttachmentIdentity {
    let rawValue: String
    init?(rawValue: String) { guard let value = Self.validate(rawValue) else { return nil }; self.rawValue = value }
}

struct RuntimeBlobID: RuntimeAttachmentIdentity {
    let rawValue: String
    init?(rawValue: String) { guard let value = Self.validate(rawValue) else { return nil }; self.rawValue = value }
}

struct RuntimeAttachmentReferenceID: RuntimeAttachmentIdentity {
    let rawValue: String
    init?(rawValue: String) { guard let value = Self.validate(rawValue) else { return nil }; self.rawValue = value }
}

struct RuntimeBlobKeyID: RuntimeAttachmentIdentity {
    let rawValue: String
    init?(rawValue: String) { guard let value = Self.validate(rawValue, maximumBytes: 256) else { return nil }; self.rawValue = value }
}

struct RuntimeBlobQuotaReservationID: RuntimeAttachmentIdentity {
    let rawValue: String
    init?(rawValue: String) { guard let value = Self.validate(rawValue) else { return nil }; self.rawValue = value }
}

struct RuntimeBlobHoldID: RuntimeAttachmentIdentity {
    let rawValue: String
    init?(rawValue: String) { guard let value = Self.validate(rawValue) else { return nil }; self.rawValue = value }
}

struct RuntimeBlobGCLeaseID: RuntimeAttachmentIdentity {
    let rawValue: String
    init?(rawValue: String) { guard let value = Self.validate(rawValue) else { return nil }; self.rawValue = value }
}

struct RuntimeBlobTombstoneID: RuntimeAttachmentIdentity {
    let rawValue: String
    init?(rawValue: String) { guard let value = Self.validate(rawValue) else { return nil }; self.rawValue = value }
}

struct RuntimeAttachmentHistoryID: RuntimeAttachmentIdentity {
    let rawValue: String
    init?(rawValue: String) { guard let value = Self.validate(rawValue) else { return nil }; self.rawValue = value }
}

struct RuntimeAttachmentReferenceHistoryID: RuntimeAttachmentIdentity {
    let rawValue: String
    init?(rawValue: String) { guard let value = Self.validate(rawValue) else { return nil }; self.rawValue = value }
}

struct RuntimeAttachmentContentAddress: RawRepresentable, Codable, Sendable, Equatable, Hashable {
    let rawValue: String
    init?(rawValue: String) {
        guard RuntimeStoreManifestCodec.isSHA256Hex(rawValue) else { return nil }
        self.rawValue = rawValue
    }
}

enum RuntimeAttachmentPrivacyDomain: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case standard
    case sensitive
    case privateUserText = "private_user_text"
    case calendarDerived = "calendar_derived"
    case syncMetadata = "sync_metadata"

    init?(_ classification: EventLedgerPrivacyClassification) {
        self.init(rawValue: classification.rawValue)
    }
}

enum RuntimeAttachmentDedupPolicy: String, Codable, Sendable, Equatable, Hashable {
    case withinPrivacyDomain = "within_privacy_domain"
    case never
}

enum RuntimeAttachmentLifecycleState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case staged, referenced, finalized, orphaned, quarantined
    case deletionPending = "deletion_pending"
}

enum RuntimeAttachmentReferenceState: String, Codable, Sendable, Equatable, Hashable {
    case active, removed
}

enum RuntimeAttachmentPhysicalDeletionDisposition: String, Codable, Sendable, Equatable, Hashable {
    case removedOwnedDirectory = "removed_owned_directory"
    case confirmedAlreadyAbsent = "confirmed_already_absent"
}

enum RuntimeAttachmentProtectionClass: String, Codable, Sendable, Equatable, Hashable {
    case complete
}

enum RuntimeAttachmentProvenanceKind: String, Codable, Sendable, Equatable, Hashable {
    case capture, files, shareExtension = "share_extension", appIntent = "app_intent"
    case importArchive = "import_archive", recovery
}

struct RuntimeAttachmentProvenance: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let kind: RuntimeAttachmentProvenanceKind
    let sourceRecordID: String
    let receivedAt: Date
    let sourceApplicationFingerprint: String?
}

struct RuntimeAttachmentContentClassification: Codable, Sendable, Equatable, Hashable {
    let normalizedFilename: String
    let declaredContentType: String
    let detectedContentType: String
    let signatureVersion: Int
    let byteCount: Int64
}

/// Ephemeral authority proving that the exact owned plaintext inode admitted by
/// intake is the inode the vault is allowed to encrypt. The keyed authenticator
/// prevents another in-module caller from manufacturing validation evidence.
struct RuntimeAttachmentValidatedIntakeProof: Sendable, Equatable {
    let version: Int
    let revisionID: RuntimeAttachmentRevisionID
    let blobID: RuntimeBlobID
    let ownedFilename: String
    let sourceDevice: UInt64
    let sourceInode: UInt64
    let device: UInt64
    let inode: UInt64
    let byteCount: Int64
    let plaintextDigest: String
    let classification: RuntimeAttachmentContentClassification
    let protectionClass: RuntimeAttachmentProtectionClass
    let issuedAt: Date
    let authenticationCode: Data
}

struct RuntimeBlobManifestAuthority: Codable, Sendable, Equatable, Hashable {
    let formatVersion: Int
    let blobID: RuntimeBlobID
    let privacyDomain: RuntimeAttachmentPrivacyDomain
    let dedupPolicy: RuntimeAttachmentDedupPolicy
    let keyedContentAddress: RuntimeAttachmentContentAddress
    let encryptionAlgorithm: String
    let chunkSize: Int
    let chunkCount: Int
    let plaintextByteCount: Int64
    let ciphertextByteCount: Int64
    let headerDigest: String
    let terminalDigest: String
    let protectionClass: RuntimeAttachmentProtectionClass
    let opaqueRelativeDirectory: String
    let createdAt: Date
}

struct RuntimeBlobKeyEnvelope: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let blobID: RuntimeBlobID
    let wrappingKeyID: RuntimeBlobKeyID
    let wrappingKeyVersion: Int
    let algorithm: String
    let nonce: Data
    let wrappedDataEncryptionKey: Data
    let envelopeDigest: String
}

struct RuntimeAttachmentRevision: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let revisionID: RuntimeAttachmentRevisionID
    let attachmentID: RuntimeAttachmentID
    let revision: UInt64
    let blobID: RuntimeBlobID
    let manifestDigest: String
    let classification: RuntimeAttachmentContentClassification
    let privacy: EventLedgerPrivacyClassification
    let provenance: RuntimeAttachmentProvenance
    let createdAt: Date
}

struct RuntimeAttachmentReference: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let referenceID: RuntimeAttachmentReferenceID
    let revisionID: RuntimeAttachmentRevisionID
    let target: RuntimeSemanticAggregate
    let targetRevision: UInt64
    let state: RuntimeAttachmentReferenceState
    let commandID: RuntimeCommandID
    let receiptID: RuntimeReceiptID
    let lineage: RuntimeAuthorityLineageReference
    let createdAt: Date
    let removedAt: Date?
}

struct RuntimeAttachmentCurrentLifecycle: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let blobID: RuntimeBlobID
    let state: RuntimeAttachmentLifecycleState
    let stateVersion: UInt64
    let referenceCount: Int
    let manifestDigest: String
    let retentionUntil: Date?
    let quarantineReasonCode: RuntimeAttachmentQuarantineReason?
    let updatedAt: Date
}

enum RuntimeAttachmentSystemTransitionKind: String, Codable, Sendable, Equatable, Hashable {
    case stagedExpiry = "staged_expiry"
    case recoveryQuarantine = "recovery_quarantine"
    case garbageCollectionFence = "garbage_collection_fence"
    case garbageCollectionLease = "garbage_collection_lease"
}

struct RuntimeAttachmentSystemTransitionAuthority: Codable, Sendable, Equatable, Hashable {
    let kind: RuntimeAttachmentSystemTransitionKind
    let authorityID: String
    let evidenceFingerprint: String
}

struct RuntimeAttachmentLifecycleHistory: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let historyID: RuntimeAttachmentHistoryID
    let blobID: RuntimeBlobID
    let stateVersion: UInt64
    let fromState: RuntimeAttachmentLifecycleState?
    let toState: RuntimeAttachmentLifecycleState
    let fromReferenceCount: Int?
    let toReferenceCount: Int
    let commandID: RuntimeCommandID?
    let receiptID: RuntimeReceiptID?
    let lineage: RuntimeAuthorityLineageReference?
    let systemAuthority: RuntimeAttachmentSystemTransitionAuthority?
    let occurredAt: Date
    let transitionDigest: String
}

struct RuntimeAttachmentReferenceHistory: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let historyID: RuntimeAttachmentReferenceHistoryID
    let referenceID: RuntimeAttachmentReferenceID
    let revisionID: RuntimeAttachmentRevisionID
    let blobID: RuntimeBlobID
    let fromState: RuntimeAttachmentReferenceState?
    let toState: RuntimeAttachmentReferenceState
    let commandID: RuntimeCommandID
    let receiptID: RuntimeReceiptID
    let lineage: RuntimeAuthorityLineageReference
    let occurredAt: Date
    let transitionDigest: String
}

enum RuntimeAttachmentQuarantineReason: String, Codable, Sendable, Equatable, Hashable {
    case malformedSource = "malformed_source"
    case contentTypeMismatch = "content_type_mismatch"
    case signatureMismatch = "signature_mismatch"
    case sizeLimitExceeded = "size_limit_exceeded"
    case manifestMismatch = "manifest_mismatch"
    case ciphertextMissing = "ciphertext_missing"
    case authenticationFailed = "authentication_failed"
    case protectionInsufficient = "protection_insufficient"
    case pathAuthorityViolation = "path_authority_violation"
    case futureFormat = "future_format"
}

enum RuntimeAttachmentHoldKind: String, Codable, Sendable, Equatable, Hashable {
    case receipt, replay, compensation, backup, migration, export, recovery
}

struct RuntimeBlobQuotaReservation: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let reservationID: RuntimeBlobQuotaReservationID
    let privacyDomain: RuntimeAttachmentPrivacyDomain
    let reservedBytes: Int64
    let ownerID: String
    let createdAt: Date
    let expiresAt: Date
    let consumedByBlobID: RuntimeBlobID?
}

struct RuntimeAttachmentQuotaAuthorization: Sendable, Equatable, Hashable {
    let reservationID: RuntimeBlobQuotaReservationID
    let privacyDomain: RuntimeAttachmentPrivacyDomain
    let ownerID: String
    let reservedBytes: Int64
    let expiresAt: Date
    let authorizationDigest: String
}

protocol RuntimeAttachmentQuotaAuthorizing: Sendable {
    func authorizeAttachmentIntake(
        reservationID: RuntimeBlobQuotaReservationID,
        privacyDomain: RuntimeAttachmentPrivacyDomain,
        maximumBytes: Int64,
        now: Date
    ) async throws -> RuntimeAttachmentQuotaAuthorization

    func releaseAttachmentIntakeAuthorization(
        _ authorization: RuntimeAttachmentQuotaAuthorization,
        now: Date
    ) async throws
}

struct RuntimeBlobRetentionHold: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let holdID: RuntimeBlobHoldID
    let blobID: RuntimeBlobID
    let kind: RuntimeAttachmentHoldKind
    let authorityID: String
    let retainUntil: Date?
    let createdAt: Date
}

struct RuntimeBlobRetentionHoldRelease: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let holdID: RuntimeBlobHoldID
    let blobID: RuntimeBlobID
    let authorityID: String
    let releasedByCommandID: RuntimeCommandID
    let releasedByReceiptID: RuntimeReceiptID
    let lineage: RuntimeAuthorityLineageReference
    let releasedAt: Date
    let releaseDigest: String
}

enum RuntimeBlobRetentionHoldTransitionKind: String, Codable, Sendable, Equatable, Hashable {
    case acquired, released
}

struct RuntimeBlobRetentionHoldHistory: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let holdID: RuntimeBlobHoldID
    let blobID: RuntimeBlobID
    let transition: RuntimeBlobRetentionHoldTransitionKind
    let authorityID: String
    let commandID: RuntimeCommandID
    let receiptID: RuntimeReceiptID
    let lineage: RuntimeAuthorityLineageReference
    let occurredAt: Date
    let transitionDigest: String
}

struct RuntimeBlobGCLease: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let leaseID: RuntimeBlobGCLeaseID
    let blobID: RuntimeBlobID
    let expectedStateVersion: UInt64
    let ownerID: String
    let acquiredAt: Date
    let expiresAt: Date
}

enum RuntimeBlobGCLeaseState: String, Codable, Sendable, Equatable, Hashable {
    case active, expired, released
}

enum RuntimeBlobGCLeaseTransition: String, Codable, Sendable, Equatable, Hashable {
    case acquired, renewed, reacquired, expired, released
}

struct RuntimeBlobGCCurrentLeaseAuthority: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let lease: RuntimeBlobGCLease
    let leaseToken: String
    let state: RuntimeBlobGCLeaseState
    let authorityVersion: UInt64
    let releasedAt: Date?
}

struct RuntimeBlobGCLeaseHistory: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let historyID: String
    let blobID: RuntimeBlobID
    let transition: RuntimeBlobGCLeaseTransition
    let leaseID: RuntimeBlobGCLeaseID
    let leaseToken: String
    let ownerID: String
    let expectedStateVersion: UInt64
    let priorLeaseID: RuntimeBlobGCLeaseID?
    let priorLeaseToken: String?
    let priorOwnerID: String?
    let priorAuthorityVersion: UInt64?
    let authorityVersion: UInt64
    let priorAcquiredAt: Date?
    let priorExpiresAt: Date?
    let acquiredAt: Date
    let expiresAt: Date
    let occurredAt: Date
    let systemAuthority: RuntimeAttachmentSystemTransitionAuthority
    let transitionDigest: String
}

struct RuntimeBlobDeletionTombstone: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let tombstoneID: RuntimeBlobTombstoneID
    let blobID: RuntimeBlobID
    let manifestDigest: String
    let finalStateVersion: UInt64
    let deletionAuthorizationID: String
    let physicalDeletionConfirmed: Bool
    let physicalDeletionDisposition: RuntimeAttachmentPhysicalDeletionDisposition
    let deletedAt: Date
    let tombstoneDigest: String
}

struct RuntimeBlobStagingOrphan: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let losingBlobID: RuntimeBlobID
    let canonicalBlobID: RuntimeBlobID
    let manifest: RuntimeBlobManifestAuthority
    let reasonCode: String
    let recordedAt: Date
    let cleanedAt: Date?
}

struct RuntimeBlobFinalizationWork: Sendable, Equatable {
    let revisionID: RuntimeAttachmentRevisionID
    let manifest: RuntimeBlobManifestAuthority
    let manifestDigest: String
    let commandID: RuntimeCommandID
    let receiptID: RuntimeReceiptID
    let lineage: RuntimeAuthorityLineageReference
    let expectedStateVersion: UInt64
    let createdAt: Date
}

struct RuntimeAttachmentReceiptRevisionEvidence: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let receiptID: RuntimeReceiptID
    let revisionID: RuntimeAttachmentRevisionID
    let blobID: RuntimeBlobID
    let manifestDigest: String
    let linkKind: String
    let referenceTransitionDigests: [String]
    let lifecycleTransitionDigest: String
}

struct RuntimeAttachmentFinalizationIntentEvidence: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let blobID: RuntimeBlobID
    let manifestDigest: String
    let commandID: RuntimeCommandID
    let receiptID: RuntimeReceiptID
    let lineage: RuntimeAuthorityLineageReference
    let expectedStateVersion: UInt64
    let createdAt: Date
}

struct RuntimeBlobGCWork: Sendable, Equatable {
    let revisionID: RuntimeAttachmentRevisionID
    let manifest: RuntimeBlobManifestAuthority
    let manifestDigest: String
    let lifecycle: RuntimeAttachmentCurrentLifecycle
    let deletionAuthorizationID: String
}

enum RuntimeAttachmentRecoveryIssue: String, Codable, Sendable, Equatable, Hashable {
    case temporaryWithoutManifest = "temporary_without_manifest"
    case manifestWithoutRow = "manifest_without_row"
    case finalizationMissing = "finalization_missing"
    case referencedBytesMissing = "referenced_bytes_missing"
    case referencedBytesTampered = "referenced_bytes_tampered"
    case interruptedDeletion = "interrupted_deletion"
    case stagedExpired = "staged_expired"
    case intakeLeftover = "intake_leftover"
}

enum RuntimeAttachmentRecoveryWorkKind: String, Codable, Sendable, Equatable, Hashable {
    case finalization
    case temporaryDirectory = "temporary_directory"
    case intakeLeftover = "intake_leftover"
    case manifestDirectory = "manifest_directory"
    case authorityGraph = "authority_graph"
    case stagingOrphan = "staging_orphan"
}

enum RuntimeAttachmentRecoveryScanKind: String, Codable, Sendable, Equatable, Hashable {
    case temporaryDirectories = "temporary_directories"
    case manifestDirectories = "manifest_directories"
    case authorityGraphs = "authority_graphs"
    case intakeLeftovers = "intake_leftovers"
    case manifestDeletionClaims = "manifest_deletion_claims"
}

struct RuntimeAttachmentManifestDeletionClaim: Codable, Sendable, Equatable, Hashable {
    let claimID: String
    let blobID: RuntimeBlobID
    let manifestDigest: String
    let opaqueRelativeDirectory: String
    let observedDevice: UInt64
    let observedInode: UInt64
    let claimedAt: Date
    let expiresAt: Date
    let stateVersion: UInt64
}

struct RuntimeAttachmentManifestDeletionRecoveryWork: Sendable, Equatable {
    let claim: RuntimeAttachmentManifestDeletionClaim
    let recoveryAuthorityID: String
}

struct RuntimeAttachmentRecoveryCursor: Sendable, Equatable, Hashable {
    let scanKind: RuntimeAttachmentRecoveryScanKind
    let lastKey: String?
    let cycle: UInt64
    let stateVersion: UInt64
    let updatedAt: Date
}

struct RuntimeAttachmentRecoveryAttempt: Sendable, Equatable, Hashable {
    let workKind: RuntimeAttachmentRecoveryWorkKind
    let authorityID: String
    let attemptCount: Int
    let nextRetryAt: Date
    let lastErrorFingerprint: String?
    let lastAttemptAt: Date
    let resolvedAt: Date?
}

struct RuntimeAttachmentRecoveryFinding: Sendable, Equatable {
    let issue: RuntimeAttachmentRecoveryIssue
    let blobID: RuntimeBlobID?
    let opaqueRelativeDirectory: String
    let evidenceFingerprint: String
    let observedAt: Date
}

struct RuntimeAttachmentStageBundle: Sendable, Equatable {
    let revision: RuntimeAttachmentRevision
    let manifest: RuntimeBlobManifestAuthority
    let envelope: RuntimeBlobKeyEnvelope
    let lifecycle: RuntimeAttachmentCurrentLifecycle
}

enum RuntimeAttachmentStagePersistenceResult: Sendable, Equatable {
    case inserted(RuntimeAttachmentRevision)
    case deduplicated(
        effectiveRevision: RuntimeAttachmentRevision,
        canonicalBlobID: RuntimeBlobID,
        losingManifest: RuntimeBlobManifestAuthority,
        cleanup: RuntimeAttachmentDedupCleanupState
    )
}

enum RuntimeAttachmentDedupCleanupState: String, Sendable, Equatable, Hashable {
    case pending
    case completed
    case pendingRecovery = "pending_recovery"
}

enum RuntimeAttachmentMutationAction: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case linkStaged = "link_staged"
    case unlink
    case replaceRevision = "replace_revision"
    case authorizeDeletion = "authorize_deletion"
    case quarantine
}

struct RuntimeAttachmentCommandIntent: Codable, Sendable, Equatable, Hashable {
    let version: Int
    let action: RuntimeAttachmentMutationAction
    let attachmentID: RuntimeAttachmentID
    let revisionID: RuntimeAttachmentRevisionID
    let blobID: RuntimeBlobID
    let referenceID: RuntimeAttachmentReferenceID?
    let replacesReferenceID: RuntimeAttachmentReferenceID?
    let replacesRevisionID: RuntimeAttachmentRevisionID?
    let replacesBlobID: RuntimeBlobID?
    let target: RuntimeSemanticAggregate?
    let expectedLifecycleVersion: UInt64
    let expectedReplacedLifecycleVersion: UInt64?
    let manifestDigest: String
    let replacesManifestDigest: String?
    let quarantineReason: RuntimeAttachmentQuarantineReason?
    let quarantineEvidenceFingerprint: String?
    let privacy: EventLedgerPrivacyClassification
    let provenance: RuntimeAttachmentProvenance
}

struct RuntimeAttachmentCommand: Codable, Sendable, Equatable, Hashable {
    let intent: RuntimeAttachmentCommandIntent
    let target: AmbitionsCommandTarget
    let content: RuntimeCommandContent
}

enum RuntimeCanonicalAttachmentError: Error, Sendable, Equatable {
    case invalidIdentity
    case invalidRecord
    case malformedPayload
    case unsupportedVersion(expected: Int, actual: Int)
    case migrationRequired(expected: Int, actual: Int)
    case corruptAuthority
    case quotaExceeded
    case reservationExpired
    case sizeLimitExceeded
    case contentTypeMismatch
    case signatureMismatch
    case pathAuthorityDenied
    case symbolicLinkDenied
    case fileIdentityChanged
    case protectedDataUnavailable
    case keyCustodyUnavailable
    case keyEnvelopeInvalid
    case staleWrappingKey
    case manifestInvalid
    case chunkAuthenticationFailed
    case lifecycleConflict
    case quarantined
    case referencesRemain
    case retentionHoldActive
    case retentionHoldReleasePending
    case invalidLease
    case cancellation
    case decodedByteBudgetExceeded
}
