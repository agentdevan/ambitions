import Foundation

/// v9 makes projection-rebuild recovery admission durable on its migration
/// run, including the source safety backup and exact execution claim.
/// Every prior schema remains a recognized, migration-only source and is never
/// opened writable.
/// v10 separates projection-rebuild candidate admission from candidate-byte
/// commitment. A rebuild cannot smuggle a newly invented candidate identity
/// into the final certification transaction.
let runtimeGenerationControlSchemaVersion = 10
let runtimeGenerationAuthorityManifestVersion = 2
let runtimeGenerationMaximumOperationLeaseMilliseconds: Int64 = 15 * 60 * 1_000

enum RuntimeGenerationControlError: Error, Sendable, Equatable {
    case malformed(field: String)
    case unsupportedVersion(expected: Int, actual: Int)
    case futureVersion(maximumSupported: Int, actual: Int)
    case recordConflict(kind: String, id: String)
    case recordMissing(kind: String, id: String)
    case recordCorrupt(kind: String, id: String)
    case readBudgetExceeded(maximumBytes: Int)
    case resourcePolicyExceeded(resource: String, maximum: Int64)
    case reservationExpired
    case reservationConsumed
    /// The selector is durable but its post-commit journal is still owned by
    /// a live lease. Callers must present a degraded/pending state rather than
    /// falsely resolving the generation or stealing that lease early.
    case activationReconciliationPending
    case verificationRejected
    case verificationStale
    case activationIntentConsumed
    case activationIntentExpired
    case activationFenceAdvanced
    case activationAuthorityMismatch
    case rollbackUnsafe
    case restoreSourceUnverified
    case recoveryAuthorizationRequired
    case sourceQuarantined
    case importReviewRequired
    case importLossNotAccepted
    case unsupportedSourceSchema(actual: Int)
    case generationWorkerBarrierBusy
    case generationWorkerBarrierMismatch
    case controlAuthorityUnavailable
    /// Both owned runtime authorities were given a retirement opportunity.
    /// The booleans preserve which close attempt failed without exposing
    /// potentially sensitive SQLite or filesystem error descriptions.
    case recoveryRuntimeRetirementFailed(
        sourceStoreFailed: Bool,
        controlStoreFailed: Bool
    )
    case derivedCandidateCloseFailed
    case derivedCanonicalMutationDenied
}

enum RuntimeGenerationOperationKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case install
    case migration
    case restore
    case rollback
    case projectionRebuild = "projection_rebuild"
    case legacyImport = "legacy_import"
    case swiftDataImport = "swiftdata_import"
}

enum RuntimeGenerationRetentionClass: String, Codable, Sendable, Equatable, Hashable {
    case staged
    case freshConnectionVerified = "fresh_connection_verified"
    case active
    case verifiedRollback = "verified_rollback"
    case verifiedBackup = "verified_backup"
    case failedPreserved = "failed_preserved"
    case quarantinedOriginal = "quarantined_original"
    /// Immutable control/digest ancestry remains, but generation bytes were
    /// deliberately pruned by a separately authorized retention operation.
    case lineageOnly = "lineage_only"

    static func allowsTransition(
        from: RuntimeGenerationRetentionClass?,
        to: RuntimeGenerationRetentionClass
    ) -> Bool {
        switch (from, to) {
        case (nil, .staged),
             (.staged, .freshConnectionVerified),
             (.staged, .failedPreserved),
             (.staged, .quarantinedOriginal),
             (.freshConnectionVerified, .active),
             (.freshConnectionVerified, .failedPreserved),
             (.freshConnectionVerified, .quarantinedOriginal),
             (.active, .verifiedRollback),
             (.active, .verifiedBackup),
             (.active, .lineageOnly),
             (.active, .quarantinedOriginal),
             (.verifiedRollback, .verifiedBackup),
             (.verifiedRollback, .lineageOnly),
             (.verifiedRollback, .quarantinedOriginal),
             (.verifiedBackup, .verifiedRollback),
             (.verifiedBackup, .lineageOnly),
             (.verifiedBackup, .quarantinedOriginal),
             (.failedPreserved, .quarantinedOriginal),
             (.failedPreserved, .lineageOnly),
             (.quarantinedOriginal, .lineageOnly):
            true
        default:
            false
        }
    }
}

struct RuntimeGenerationArtifact: Codable, Sendable, Equatable, Hashable {
    let relativePath: String
    let sha256: String
    let byteCount: Int64
    let protectionClass: String

    init(
        relativePath: String,
        sha256: String,
        byteCount: Int64,
        protectionClass: String
    ) throws {
        try RuntimeGenerationControlValidation.requireRelativePath(relativePath)
        try RuntimeGenerationControlValidation.requireDigest(sha256, field: "artifact_sha256")
        guard byteCount >= 0, protectionClass == "complete" else {
            throw RuntimeGenerationControlError.malformed(field: "artifact")
        }
        self.relativePath = relativePath
        self.sha256 = sha256
        self.byteCount = byteCount
        self.protectionClass = protectionClass
    }

    func validate() throws {
        let rebuilt = try Self(
            relativePath: relativePath,
            sha256: sha256,
            byteCount: byteCount,
            protectionClass: protectionClass
        )
        guard rebuilt == self else {
            throw RuntimeGenerationControlError.malformed(field: "artifact")
        }
    }

    func semanticArtifact() throws -> Self {
        self
    }

    func semanticallyMatches(_ other: Self) -> Bool {
        relativePath == other.relativePath &&
            sha256 == other.sha256 &&
            byteCount == other.byteCount &&
            protectionClass == other.protectionClass
    }
}

/// Installation-local observation of one exact inode. Portable authority uses
/// `RuntimeGenerationArtifact`; this type is used only while proving current
/// path/descriptor ownership and is never embedded in semantic manifests.
struct RuntimeGenerationObservedArtifact: Codable, Sendable, Equatable, Hashable {
    let semantic: RuntimeGenerationArtifact
    let fileIdentity: RuntimeStoreFileIdentity

    var relativePath: String { semantic.relativePath }
    var sha256: String { semantic.sha256 }
    var byteCount: Int64 { semantic.byteCount }
    var protectionClass: String { semantic.protectionClass }

    init(
        semantic: RuntimeGenerationArtifact,
        fileIdentity: RuntimeStoreFileIdentity
    ) throws {
        try semantic.validate()
        self.semantic = semantic
        self.fileIdentity = fileIdentity
    }

    func validate() throws {
        try semantic.validate()
    }

    func semanticArtifact() -> RuntimeGenerationArtifact { semantic }

    func semanticallyMatches(_ other: RuntimeGenerationArtifact) -> Bool {
        semantic == other
    }
}

struct RuntimeGenerationRevisionFence: Codable, Sendable, Equatable, Hashable {
    let generationID: RuntimeStoreGenerationID
    let generationDigest: String
    let eventSequence: Int64
    let eventID: String?
    let eventHash: String?
    let commandCount: Int64
    let receiptCount: Int64
    let externalOperationStatusVersionSum: Int64
    let attachmentLifecycleVersionSum: Int64
    let canonicalStateDigest: String
    let receiptAuthorityDigest: String
    let externalOperationAuthorityDigest: String
    let attachmentAuthorityDigest: String
    let fenceDigest: String

    static func make(
        generationID: RuntimeStoreGenerationID,
        generationDigest: String,
        eventSequence: Int64,
        eventID: String?,
        eventHash: String?,
        commandCount: Int64,
        receiptCount: Int64,
        externalOperationStatusVersionSum: Int64,
        attachmentLifecycleVersionSum: Int64,
        canonicalStateDigest: String,
        receiptAuthorityDigest: String,
        externalOperationAuthorityDigest: String,
        attachmentAuthorityDigest: String
    ) throws -> Self {
        try RuntimeGenerationControlValidation.requireDigest(
            generationDigest,
            field: "generation_digest"
        )
        guard eventSequence >= 0,
              commandCount >= 0,
              receiptCount >= 0,
              externalOperationStatusVersionSum >= 0,
              attachmentLifecycleVersionSum >= 0,
              (eventSequence == 0) == (eventID == nil),
              (eventID == nil) == (eventHash == nil)
        else {
            throw RuntimeGenerationControlError.malformed(field: "revision_fence")
        }
        if let eventID {
            try RuntimeGenerationControlValidation.requireIdentifier(eventID, field: "event_id")
        }
        if let eventHash {
            try RuntimeGenerationControlValidation.requireDigest(eventHash, field: "event_hash")
        }
        for (value, field) in [
            (canonicalStateDigest, "canonical_state_digest"),
            (receiptAuthorityDigest, "receipt_authority_digest"),
            (externalOperationAuthorityDigest, "external_operation_authority_digest"),
            (attachmentAuthorityDigest, "attachment_authority_digest"),
        ] {
            try RuntimeGenerationControlValidation.requireDigest(value, field: field)
        }
        let digest = LocalRuntimeStorageChecksum.sha256Hex(for: [
            "runtime-generation-fence-v1",
            generationID.rawValue,
            generationDigest,
            String(eventSequence),
            eventID ?? "",
            eventHash ?? "",
            String(commandCount),
            String(receiptCount),
            String(externalOperationStatusVersionSum),
            String(attachmentLifecycleVersionSum),
            canonicalStateDigest,
            receiptAuthorityDigest,
            externalOperationAuthorityDigest,
            attachmentAuthorityDigest,
        ].joined(separator: "\n"))
        return Self(
            generationID: generationID,
            generationDigest: generationDigest,
            eventSequence: eventSequence,
            eventID: eventID,
            eventHash: eventHash,
            commandCount: commandCount,
            receiptCount: receiptCount,
            externalOperationStatusVersionSum: externalOperationStatusVersionSum,
            attachmentLifecycleVersionSum: attachmentLifecycleVersionSum,
            canonicalStateDigest: canonicalStateDigest,
            receiptAuthorityDigest: receiptAuthorityDigest,
            externalOperationAuthorityDigest: externalOperationAuthorityDigest,
            attachmentAuthorityDigest: attachmentAuthorityDigest,
            fenceDigest: digest
        )
    }

    func validate() throws {
        let rebuilt = try Self.make(
            generationID: generationID,
            generationDigest: generationDigest,
            eventSequence: eventSequence,
            eventID: eventID,
            eventHash: eventHash,
            commandCount: commandCount,
            receiptCount: receiptCount,
            externalOperationStatusVersionSum: externalOperationStatusVersionSum,
            attachmentLifecycleVersionSum: attachmentLifecycleVersionSum,
            canonicalStateDigest: canonicalStateDigest,
            receiptAuthorityDigest: receiptAuthorityDigest,
            externalOperationAuthorityDigest: externalOperationAuthorityDigest,
            attachmentAuthorityDigest: attachmentAuthorityDigest
        )
        guard rebuilt == self else {
            throw RuntimeGenerationControlError.malformed(field: "fence_digest")
        }
    }
}

struct RuntimeGenerationActivationBaseline: Codable, Sendable, Equatable, Hashable {
    let candidateIdentityDigest: String
    let revisionFence: RuntimeGenerationRevisionFence

    static func make(
        candidateIdentityDigest: String,
        revisionFence: RuntimeGenerationRevisionFence
    ) throws -> Self {
        try RuntimeGenerationControlValidation.requireDigest(
            candidateIdentityDigest,
            field: "candidate_baseline_identity"
        )
        try revisionFence.validate()
        guard revisionFence.generationDigest == candidateIdentityDigest else {
            throw RuntimeGenerationControlError.malformed(
                field: "candidate_baseline_binding"
            )
        }
        return Self(
            candidateIdentityDigest: candidateIdentityDigest,
            revisionFence: revisionFence
        )
    }

    func validate() throws {
        guard try Self.make(
            candidateIdentityDigest: candidateIdentityDigest,
            revisionFence: revisionFence
        ) == self else {
            throw RuntimeGenerationControlError.malformed(
                field: "candidate_baseline"
            )
        }
    }
}

struct RuntimeGenerationAuthorityFenceToken: Codable, Sendable, Equatable, Hashable {
    let generationID: RuntimeStoreGenerationID
    let changeEpoch: Int64
    let lastChangedTable: String
    let lastChangeOperation: String
    let tokenDigest: String

    static func make(
        generationID: RuntimeStoreGenerationID,
        changeEpoch: Int64,
        lastChangedTable: String,
        lastChangeOperation: String
    ) throws -> Self {
        guard changeEpoch >= 0,
              lastChangedTable.utf8.count <= 256,
              ["bootstrap", "insert", "update", "delete"].contains(lastChangeOperation)
        else { throw RuntimeGenerationControlError.malformed(field: "authority_fence_token") }
        let digest = LocalRuntimeStorageChecksum.sha256Hex(
            for: [
                "runtime-authority-fence-v1", generationID.rawValue,
                String(changeEpoch), lastChangedTable, lastChangeOperation,
            ].joined(separator: "\n")
        )
        return Self(
            generationID: generationID,
            changeEpoch: changeEpoch,
            lastChangedTable: lastChangedTable,
            lastChangeOperation: lastChangeOperation,
            tokenDigest: digest
        )
    }

    func validate() throws {
        guard try Self.make(
            generationID: generationID,
            changeEpoch: changeEpoch,
            lastChangedTable: lastChangedTable,
            lastChangeOperation: lastChangeOperation
        ) == self else {
            throw RuntimeGenerationControlError.malformed(field: "authority_fence_token")
        }
    }
}

struct RuntimeGenerationCounts: Codable, Sendable, Equatable, Hashable {
    let aggregates: Int64
    let events: Int64
    let semanticEvents: Int64
    let tombstones: Int64
    let receipts: Int64
    let externalOperations: Int64
    let externalOperationAttempts: Int64
    let attachmentIdentities: Int64
    let attachmentRevisions: Int64
    let attachmentReferences: Int64
    let blobs: Int64
    let projectionGenerations: Int64
    let searchGenerations: Int64

    var orderedValues: [Int64] {
        [
            aggregates, events, semanticEvents, tombstones, receipts,
            externalOperations, externalOperationAttempts,
            attachmentIdentities, attachmentRevisions, attachmentReferences,
            blobs, projectionGenerations, searchGenerations,
        ]
    }

    func validate() throws {
        guard orderedValues.allSatisfy({ $0 >= 0 }) else {
            throw RuntimeGenerationControlError.malformed(field: "generation_counts")
        }
    }
}

struct RuntimeGenerationBoundaries: Codable, Sendable, Equatable, Hashable {
    let firstEventSequence: Int64?
    let lastEventSequence: Int64?
    let firstReceiptID: String?
    let lastReceiptID: String?
    let firstExternalOperationID: String?
    let lastExternalOperationID: String?
    let firstBlobID: String?
    let lastBlobID: String?
    let projectionAuthorityDigest: String
    let searchAuthorityDigest: String
    let attachmentAuthorityDigest: String
    let externalOperationAuthorityDigest: String

    func validate() throws {
        guard (firstEventSequence == nil) == (lastEventSequence == nil),
              firstEventSequence.map({ $0 > 0 }) ?? true,
              lastEventSequence.map({ $0 >= (firstEventSequence ?? 1) }) ?? true
        else {
            throw RuntimeGenerationControlError.malformed(field: "generation_boundaries")
        }
        for (value, field) in [
            (projectionAuthorityDigest, "projection_authority_digest"),
            (searchAuthorityDigest, "search_authority_digest"),
            (attachmentAuthorityDigest, "attachment_authority_digest"),
            (externalOperationAuthorityDigest, "external_operation_authority_digest"),
        ] {
            try RuntimeGenerationControlValidation.requireDigest(value, field: field)
        }
        let identifierPairs = [
            (firstReceiptID, lastReceiptID, "receipt_boundary"),
            (firstExternalOperationID, lastExternalOperationID, "external_operation_boundary"),
            (firstBlobID, lastBlobID, "blob_boundary"),
        ]
        for (first, last, field) in identifierPairs {
            guard (first == nil) == (last == nil) else {
                throw RuntimeGenerationControlError.malformed(field: field)
            }
            if let first { try RuntimeGenerationControlValidation.requireIdentifier(first, field: field) }
            if let last { try RuntimeGenerationControlValidation.requireIdentifier(last, field: field) }
        }
    }
}

struct RuntimeGenerationAuthorityManifest: Codable, Sendable, Equatable {
    let formatVersion: Int
    let operationKind: RuntimeGenerationOperationKind
    let generationID: RuntimeStoreGenerationID
    let schemaVersion: Int
    let sourceGenerationID: RuntimeStoreGenerationID?
    let sourceGenerationDigest: String?
    let sourceFence: RuntimeGenerationRevisionFence?
    let activationBaseline: RuntimeGenerationActivationBaseline
    let database: RuntimeGenerationArtifact
    let sourceWAL: RuntimeGenerationArtifact?
    let blobSetDigest: String
    let attachmentManifestSetDigest: String
    let encryptionScheme: String
    let keyIdentityDigest: String
    let counts: RuntimeGenerationCounts
    let boundaries: RuntimeGenerationBoundaries
    let reservationID: String
    let migrationRunID: String
    let createdAtMilliseconds: Int64
    let retentionClass: RuntimeGenerationRetentionClass
    let manifestDigest: String

    static func make(
        operationKind: RuntimeGenerationOperationKind,
        generationID: RuntimeStoreGenerationID,
        schemaVersion: Int,
        sourceGenerationID: RuntimeStoreGenerationID?,
        sourceGenerationDigest: String?,
        sourceFence: RuntimeGenerationRevisionFence?,
        activationBaseline: RuntimeGenerationActivationBaseline,
        database: RuntimeGenerationArtifact,
        sourceWAL: RuntimeGenerationArtifact?,
        blobSetDigest: String,
        attachmentManifestSetDigest: String,
        encryptionScheme: String,
        keyIdentityDigest: String,
        counts: RuntimeGenerationCounts,
        boundaries: RuntimeGenerationBoundaries,
        reservationID: String,
        migrationRunID: String,
        createdAtMilliseconds: Int64,
        retentionClass: RuntimeGenerationRetentionClass
    ) throws -> Self {
        let semanticDatabase = try database.semanticArtifact()
        let semanticSourceWAL = try sourceWAL?.semanticArtifact()
        guard schemaVersion == runtimeCanonicalAttachmentSchemaVersion,
              createdAtMilliseconds >= 0,
              (sourceGenerationID == nil) == (sourceGenerationDigest == nil),
              (sourceGenerationID == nil) == (sourceFence == nil),
              encryptionScheme == "sqlite-file-protection-complete+attachment-aes-gcm-v1"
        else {
            throw RuntimeGenerationControlError.malformed(field: "generation_manifest")
        }
        if let sourceGenerationDigest {
            try RuntimeGenerationControlValidation.requireDigest(
                sourceGenerationDigest,
                field: "source_generation_digest"
            )
        }
        try sourceFence?.validate()
        try activationBaseline.validate()
        guard activationBaseline.revisionFence.generationID == generationID else {
            throw RuntimeGenerationControlError.malformed(field: "activation_baseline")
        }
        if let sourceFence {
            guard sourceFence.generationID == sourceGenerationID,
                  sourceFence.generationDigest == sourceGenerationDigest else {
                throw RuntimeGenerationControlError.malformed(
                    field: "source_fence_binding"
                )
            }
        }
        try semanticDatabase.validate()
        try semanticSourceWAL?.validate()
        try RuntimeGenerationControlValidation.requireDigest(blobSetDigest, field: "blob_set_digest")
        try RuntimeGenerationControlValidation.requireDigest(
            attachmentManifestSetDigest,
            field: "attachment_manifest_set_digest"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            keyIdentityDigest,
            field: "key_identity_digest"
        )
        try RuntimeGenerationControlValidation.requireIdentifier(reservationID, field: "reservation_id")
        try RuntimeGenerationControlValidation.requireIdentifier(migrationRunID, field: "migration_run_id")
        try counts.validate()
        try boundaries.validate()
        let material = DigestMaterial(
            formatVersion: runtimeGenerationAuthorityManifestVersion,
            operationKind: operationKind,
            generationID: generationID,
            schemaVersion: schemaVersion,
            sourceGenerationID: sourceGenerationID,
            sourceGenerationDigest: sourceGenerationDigest,
            sourceFence: sourceFence,
            activationBaseline: activationBaseline,
            database: semanticDatabase,
            sourceWAL: semanticSourceWAL,
            blobSetDigest: blobSetDigest,
            attachmentManifestSetDigest: attachmentManifestSetDigest,
            encryptionScheme: encryptionScheme,
            keyIdentityDigest: keyIdentityDigest,
            counts: counts,
            boundaries: boundaries,
            reservationID: reservationID,
            migrationRunID: migrationRunID,
            createdAtMilliseconds: createdAtMilliseconds,
            retentionClass: retentionClass
        )
        let digest = try RuntimeGenerationControlCodec.digest(material)
        return Self(
            formatVersion: runtimeGenerationAuthorityManifestVersion,
            operationKind: operationKind,
            generationID: generationID,
            schemaVersion: schemaVersion,
            sourceGenerationID: sourceGenerationID,
            sourceGenerationDigest: sourceGenerationDigest,
            sourceFence: sourceFence,
            activationBaseline: activationBaseline,
            database: semanticDatabase,
            sourceWAL: semanticSourceWAL,
            blobSetDigest: blobSetDigest,
            attachmentManifestSetDigest: attachmentManifestSetDigest,
            encryptionScheme: encryptionScheme,
            keyIdentityDigest: keyIdentityDigest,
            counts: counts,
            boundaries: boundaries,
            reservationID: reservationID,
            migrationRunID: migrationRunID,
            createdAtMilliseconds: createdAtMilliseconds,
            retentionClass: retentionClass,
            manifestDigest: digest
        )
    }

    func validate() throws {
        guard formatVersion <= runtimeGenerationAuthorityManifestVersion else {
            throw RuntimeGenerationControlError.futureVersion(
                maximumSupported: runtimeGenerationAuthorityManifestVersion,
                actual: formatVersion
            )
        }
        guard formatVersion == runtimeGenerationAuthorityManifestVersion else {
            throw RuntimeGenerationControlError.unsupportedVersion(
                expected: runtimeGenerationAuthorityManifestVersion,
                actual: formatVersion
            )
        }
        let rebuilt = try Self.make(
            operationKind: operationKind,
            generationID: generationID,
            schemaVersion: schemaVersion,
            sourceGenerationID: sourceGenerationID,
            sourceGenerationDigest: sourceGenerationDigest,
            sourceFence: sourceFence,
            activationBaseline: activationBaseline,
            database: database,
            sourceWAL: sourceWAL,
            blobSetDigest: blobSetDigest,
            attachmentManifestSetDigest: attachmentManifestSetDigest,
            encryptionScheme: encryptionScheme,
            keyIdentityDigest: keyIdentityDigest,
            counts: counts,
            boundaries: boundaries,
            reservationID: reservationID,
            migrationRunID: migrationRunID,
            createdAtMilliseconds: createdAtMilliseconds,
            retentionClass: retentionClass
        )
        guard rebuilt == self else {
            throw RuntimeGenerationControlError.malformed(field: "manifest_digest")
        }
    }

    private struct DigestMaterial: Codable {
        let formatVersion: Int
        let operationKind: RuntimeGenerationOperationKind
        let generationID: RuntimeStoreGenerationID
        let schemaVersion: Int
        let sourceGenerationID: RuntimeStoreGenerationID?
        let sourceGenerationDigest: String?
        let sourceFence: RuntimeGenerationRevisionFence?
        let activationBaseline: RuntimeGenerationActivationBaseline
        let database: RuntimeGenerationArtifact
        let sourceWAL: RuntimeGenerationArtifact?
        let blobSetDigest: String
        let attachmentManifestSetDigest: String
        let encryptionScheme: String
        let keyIdentityDigest: String
        let counts: RuntimeGenerationCounts
        let boundaries: RuntimeGenerationBoundaries
        let reservationID: String
        let migrationRunID: String
        let createdAtMilliseconds: Int64
        let retentionClass: RuntimeGenerationRetentionClass
    }
}

struct RuntimeGenerationCandidateRecord: Codable, Sendable, Equatable {
    let authorityManifest: RuntimeGenerationAuthorityManifest
    let authorityManifestFileSHA256: String
    let selectorFileSHA256: String
    let recordDigest: String
}

/// Admission-time, immutable reservation of the complete candidate lineage
/// for a projection rebuild. Verification and activation identifiers are
/// allocated before derived work begins so later records cannot attach a
/// different candidate to an otherwise valid recovery claim.
struct RuntimeGenerationProjectionRebuildCandidateReservation: Codable, Sendable, Equatable {
    let candidateReservationID: String
    let recoveryExecutionPlanID: String
    let recoveryExecutionClaimID: String
    let recoveryExecutionClaimEpoch: Int64
    let migrationRunID: String
    let reservationID: String
    let candidatePreparationID: String
    let candidateGenerationID: RuntimeStoreGenerationID
    let expectedVerificationID: String
    let expectedActivationIntentID: String
    let reservedAtMilliseconds: Int64
    let reservationDigest: String
}

/// The second, pre-publication projection-rebuild authority boundary. It
/// durably binds the exact candidate bytes and replay/rebuild evidence before
/// a selector can be published. This record intentionally does not imply
/// selector publication, activation consumption, or recovery-plan completion.
struct RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment: Codable, Sendable, Equatable {
    let commitmentID: String
    let candidateReservationID: String
    let recoveryExecutionPlanID: String
    let recoveryExecutionClaimID: String
    let recoveryExecutionClaimEpoch: Int64
    let migrationRunID: String
    let reservationID: String
    let candidatePreparationID: String
    let candidateGenerationID: RuntimeStoreGenerationID
    let expectedVerificationID: String
    let expectedActivationIntentID: String
    let candidateRecord: RuntimeGenerationCandidateRecord
    let candidatePreparationCompletion: RuntimeGenerationCandidatePreparationCompletion
    let authorityManifestBytes: Data
    let authorityManifestBytesSHA256: String
    let selectorBytes: Data
    let selectorBytesSHA256: String
    let replayAuditID: String
    let replayAuditDigest: String
    let replayReconstructionDigest: String
    let rebuild: RuntimeGenerationRebuildRecord
    let committedAtMilliseconds: Int64
    let commitmentDigest: String
}

struct RuntimeGenerationReservation: Codable, Sendable, Equatable {
    let reservationID: String
    let operationKind: RuntimeGenerationOperationKind
    let candidateGenerationID: RuntimeStoreGenerationID
    let sourceGenerationID: RuntimeStoreGenerationID?
    let sourceGenerationDigest: String?
    let expectedActiveManifestDigest: String?
    let targetSchemaVersion: Int
    let createdAtMilliseconds: Int64
    let reservationDigest: String
}

/// Renewable ownership of one long-running generation operation. This is
/// deliberately distinct from the short, single-use activation intent.
struct RuntimeGenerationOperationLease: Codable, Sendable, Equatable {
    let leaseID: String
    let reservationID: String
    let ownerInstanceID: String
    let leaseEpoch: Int64
    let fencingToken: Int64
    let priorLeaseDigest: String?
    let issuedAtMilliseconds: Int64
    let expiresAtMilliseconds: Int64
    let leaseDigest: String
}

/// Immutable ownership journal written atomically with a reservation and its
/// initial execution lease before any private backup bytes are created.
struct RuntimeGenerationBackupPreparationRecord: Codable, Sendable, Equatable {
    let preparationID: String
    let backupID: String
    let reservationID: String
    let operationLeaseID: String
    let operationFencingToken: Int64
    let sourceGenerationID: RuntimeStoreGenerationID
    let sourceGenerationDigest: String
    let expectedActiveManifestDigest: String
    let hiddenDirectoryName: String
    let finalDirectoryName: String
    let createdAtMilliseconds: Int64
    let preparationDigest: String
}

/// Authenticated result of a completed hidden backup. It is durable before the
/// hidden directory is published and therefore permits startup reconciliation
/// without manufacturing lost in-memory snapshot authority.
struct RuntimeGenerationBackupPreparationCompletion: Codable, Sendable, Equatable {
    let preparationID: String
    let backup: RuntimeGenerationBackupRecord
    let directoryDevice: UInt64
    let directoryInode: UInt64
    let interiorArtifactCount: Int64
    let interiorByteCount: Int64
    let interiorInventoryDigest: String
    let durabilityWitnessDigest: String
    let completedAtMilliseconds: Int64
    let completionDigest: String
}

struct RuntimeGenerationBackupPreparationConsumption: Codable, Sendable, Equatable {
    let preparationID: String
    let backupID: String
    /// The exact current lease that published the hidden directory. This is
    /// distinct from the immutable admission fence on the preparation: crash
    /// recovery legitimately uses a successor fence after expiry.
    let operationLeaseID: String
    let operationFencingToken: Int64
    let finalDirectoryDevice: UInt64
    let finalDirectoryInode: UInt64
    let consumedAtMilliseconds: Int64
    let consumptionDigest: String
}

enum RuntimeGenerationPreservedPreparationRole: String, Codable, Sendable {
    case backupHidden = "backup_hidden"
    case backupFinal = "backup_final"
    case candidateStaging = "candidate_staging"
    case candidateFinal = "candidate_final"
}

enum RuntimeGenerationPreservedPreparationLocation: String, Codable, Sendable {
    case source
    case quarantine
}

enum RuntimeGenerationPreservedPreparationFileKind: String, Codable, Sendable {
    case directory
    case regular
    case symbolicLink = "symbolic_link"
    case other
}

struct RuntimeGenerationPreservedPreparationEntry: Codable, Sendable, Equatable {
    let role: RuntimeGenerationPreservedPreparationRole
    let location: RuntimeGenerationPreservedPreparationLocation
    let basename: String
    let fileKind: RuntimeGenerationPreservedPreparationFileKind
    let identity: RuntimeStoreFileIdentity
}

enum RuntimeGenerationBackupPreparationRecoveryClassification: String, Codable, Sendable {
    case preparedMissing = "prepared_missing"
    case quarantinedIncomplete = "quarantined_incomplete"
    case quarantinedConflict = "quarantined_conflict"
    case quarantinedCorrupt = "quarantined_corrupt"
}

struct RuntimeGenerationBackupPreparationRecovery: Codable, Sendable, Equatable {
    let preparationID: String
    let operationLeaseID: String
    let operationFencingToken: Int64
    let classification: RuntimeGenerationBackupPreparationRecoveryClassification
    let preservedEntries: [RuntimeGenerationPreservedPreparationEntry]
    let recoveredAtMilliseconds: Int64
    let recoveryDigest: String
}

struct RuntimeGenerationCandidatePreparationRecord: Codable, Sendable, Equatable {
    let preparationID: String
    let reservationID: String
    let operationLeaseID: String
    let operationFencingToken: Int64
    let operationKind: RuntimeGenerationOperationKind
    let candidateGenerationID: RuntimeStoreGenerationID
    let sourceGenerationID: RuntimeStoreGenerationID?
    let sourceGenerationDigest: String?
    let expectedActiveManifestDigest: String?
    /// Present only for a projection rebuild admitted by a durable recovery
    /// execution claim. It binds the staged candidate to that exact claim;
    /// it does not indicate that any rebuild work has completed.
    let recoveryExecutionPlanID: String?
    let recoveryExecutionClaimID: String?
    let recoveryExecutionClaimEpoch: Int64?
    let stagingDirectoryName: String
    let createdAtMilliseconds: Int64
    let preparationDigest: String
}

struct RuntimeGenerationCandidatePreparationCompletion: Codable, Sendable, Equatable {
    let preparationID: String
    let candidateRecordDigest: String
    let directoryDevice: UInt64
    let directoryInode: UInt64
    let interiorArtifactCount: Int64
    let interiorByteCount: Int64
    let interiorInventoryDigest: String
    let durabilityWitnessDigest: String
    let completedAtMilliseconds: Int64
    let completionDigest: String
}

enum RuntimeGenerationCandidatePreparationDispositionKind: String, Codable, Sendable {
    case activated
    case preservedFailure = "preserved_failure"
}

enum RuntimeGenerationCandidatePreparationFailureClassification: String, Codable, Sendable {
    case preparedMissing = "prepared_missing"
    case incomplete
    case conflict
    case corrupt
    case resourceDeferred = "resource_deferred"
}

/// Bounded, privacy-minimized reason recorded when a committed candidate is
/// preserved as corrupt. The raw bytes and private payloads remain outside
/// control authority; `authorityDigest` binds the exact diagnostic evidence.
enum RuntimeGenerationCandidatePreparationForensicCode: String, Codable, Sendable {
    case commitmentInvariant = "commitment_invariant"
    case preparationLineage = "preparation_lineage"
    case durableControlLineage = "durable_control_lineage"
    case selectorCommitment = "selector_commitment"
    case candidateLocation = "candidate_location"
    case authorityManifest = "authority_manifest"
    case databaseArtifact = "database_artifact"
    case completionWitness = "completion_witness"
}

struct RuntimeGenerationCandidatePreparationDisposition: Codable, Sendable, Equatable {
    let preparationID: String
    let operationLeaseID: String
    let operationFencingToken: Int64
    let kind: RuntimeGenerationCandidatePreparationDispositionKind
    let failureClassification: RuntimeGenerationCandidatePreparationFailureClassification?
    let forensicCode: RuntimeGenerationCandidatePreparationForensicCode?
    let preservedEntries: [RuntimeGenerationPreservedPreparationEntry]
    let authorityDigest: String
    let disposedAtMilliseconds: Int64
    let dispositionDigest: String
}

/// Immutable evidence of the candidate-scoped replay audit. This is evidence
/// only: it neither authorizes recovery nor implies that an incomplete audit
/// may be retried, rebuilt, reset, or activated.
enum RuntimeGenerationCandidateReplayAuditOutcomeKind: String, Codable, Sendable, Equatable {
    case complete
    case blocked
    case deferred
}

enum RuntimeGenerationCandidateReplayAuditDeferredReason: Codable, Sendable, Equatable {
    case boundaryCertificateBudget(maximum: Int)
    case queryBudget(maximumBytes: Int, maximumRows: Int, maximumVMCallbacks: Int)
    case cancelled
}

struct RuntimeGenerationCandidateReplayAuditRecord: Codable, Sendable, Equatable {
    let auditID: String
    let preparationID: String
    let reservationID: String
    let candidateGenerationID: RuntimeStoreGenerationID
    let operationLeaseID: String
    let operationLeaseEpoch: Int64
    let operationFencingToken: Int64
    let outcome: RuntimeGenerationCandidateReplayAuditOutcomeKind
    let blockedInvariant: RuntimeCanonicalReplayInvariantCode?
    let deferredReason: RuntimeGenerationCandidateReplayAuditDeferredReason?
    let replayCheckpointDigest: String?
    let replayCertificateDigest: String?
    let reconstructionDigest: String?
    let auditedAtMilliseconds: Int64
    let auditDigest: String
}

struct RuntimeGenerationBackupRecord: Codable, Sendable, Equatable {
    let backupID: String
    let sourceGenerationID: RuntimeStoreGenerationID
    let sourceGenerationDigest: String
    let sourceFence: RuntimeGenerationRevisionFence
    let authorityFenceToken: RuntimeGenerationAuthorityFenceToken
    let databaseArtifact: RuntimeGenerationArtifact
    let sourceWALArtifact: RuntimeGenerationArtifact?
    let blobSetDigest: String
    let attachmentManifestSetDigest: String
    let keyIdentityDigest: String
    let vaultArtifacts: [RuntimeGenerationVaultBlobArtifact]
    let counts: RuntimeGenerationCounts
    let boundaries: RuntimeGenerationBoundaries
    let semanticEquivalenceDigest: String
    let verificationMethod: String
    let verificationDigest: String
    let createdAtMilliseconds: Int64
    let backupDigest: String
}

struct RuntimeGenerationMigrationRun: Codable, Sendable, Equatable {
    let migrationRunID: String
    let executorInstanceID: String
    let reservationID: String
    let operationLeaseID: String
    let operationLeaseEpoch: Int64
    let operationFencingToken: Int64
    let sourceSafetyBackupID: String?
    let backupID: String?
    let recoveryAuthorizationID: String?
    let recoveryAuthorizationDigest: String?
    /// Projection-rebuild admission evidence. The claim is intentionally
    /// separate from recovery authorization: it fences one execution attempt.
    let recoveryExecutionPlanID: String?
    let recoveryExecutionClaimID: String?
    let recoveryExecutionClaimEpoch: Int64?
    let operationKind: RuntimeGenerationOperationKind
    let sourceSchemaVersion: Int?
    let targetSchemaVersion: Int
    let transformationVersion: Int
    let candidateGenerationID: RuntimeStoreGenerationID
    let provenanceDigest: String
    let startedAtMilliseconds: Int64
    let completedAtMilliseconds: Int64
    let runDigest: String
}

enum RuntimeGenerationProjectionRebuildPhase: String, Codable, Sendable, Equatable, Hashable {
    case admitted
    case running
    case blockedRetryable = "blocked_retryable"
    /// All bounded derived work is sealed and awaits independent
    /// certification; this is not publication or recovery completion.
    case readyForCertification = "ready_for_certification"
    case failedTerminal = "failed_terminal"
    case completed
}

/// Append-only lifecycle history for a recovery-admitted projection rebuild.
/// The current phase is the latest authenticated transition for its run.
struct RuntimeGenerationProjectionRebuildLifecycleTransition: Codable, Sendable, Equatable {
    let transitionID: String
    let migrationRunID: String
    let recoveryExecutionPlanID: String
    let recoveryExecutionClaimID: String
    let recoveryExecutionClaimEpoch: Int64
    let phase: RuntimeGenerationProjectionRebuildPhase
    let priorTransitionDigest: String?
    let reasonDigest: String
    let occurredAtMilliseconds: Int64
    let transitionDigest: String
}

enum RuntimeGenerationVerificationCheck: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case freshReadOnlyOpen = "fresh_read_only_open"
    case sqliteIntegrity = "sqlite_integrity"
    case foreignKeys = "foreign_keys"
    case exactV8Schema = "exact_v8_schema"
    case artifactDigests = "artifact_digests"
    case manifestCounts = "manifest_counts"
    case canonicalReplay = "canonical_replay"
    case replayEquivalence = "replay_equivalence"
    case projectionEquivalence = "projection_equivalence"
    case searchEquivalence = "search_equivalence"
    case receiptAuthority = "receipt_authority"
    case externalOperationAuthority = "external_operation_authority"
    case attachmentAuthority = "attachment_authority"
    case secondFreshReadOnlyOpen = "second_fresh_read_only_open"
}

struct RuntimeGenerationVerificationEvidence: Codable, Sendable, Equatable, Hashable {
    let check: RuntimeGenerationVerificationCheck
    let evidenceDigest: String

    init(check: RuntimeGenerationVerificationCheck, evidenceDigest: String) throws {
        try RuntimeGenerationControlValidation.requireDigest(
            evidenceDigest,
            field: check.rawValue
        )
        self.check = check
        self.evidenceDigest = evidenceDigest
    }

    func validate() throws {
        let rebuilt = try Self(check: check, evidenceDigest: evidenceDigest)
        guard rebuilt == self else {
            throw RuntimeGenerationControlError.malformed(field: "verification_evidence")
        }
    }
}

struct RuntimeGenerationVerificationReport: Codable, Sendable, Equatable {
    let verificationID: String
    let verifierInstanceID: String
    let reservationID: String
    let migrationRunID: String
    let candidateGenerationID: RuntimeStoreGenerationID
    let candidateAuthorityManifestDigest: String
    let candidateAuthorityManifestFileSHA256: String
    let candidateSelectorFileSHA256: String
    let sourceGenerationID: RuntimeStoreGenerationID?
    let sourceGenerationDigest: String?
    let sourceFenceDigest: String?
    let expectedActiveManifestDigest: String?
    let expectedSchemaVersion: Int
    let evidence: [RuntimeGenerationVerificationEvidence]
    let verifiedAtMilliseconds: Int64
    let accepted: Bool
    let reportDigest: String

    var hasCompleteEvidence: Bool {
        accepted && Set(evidence.map(\.check)) == Set(RuntimeGenerationVerificationCheck.allCases)
            && Set(evidence.map(\.check)).count == evidence.count
    }
}

struct RuntimeGenerationActivationIntent: Codable, Sendable, Equatable {
    let intentID: String
    let reservationID: String
    let verificationID: String
    let candidateGenerationID: RuntimeStoreGenerationID
    let candidateAuthorityManifestDigest: String
    let candidateAuthorityManifestFileSHA256: String
    let candidateSelectorFileSHA256: String
    let expectedSourceGenerationID: RuntimeStoreGenerationID?
    let expectedSourceGenerationDigest: String?
    let expectedSourceFenceDigest: String?
    let expectedActiveManifestDigest: String?
    let createdAtMilliseconds: Int64
    let expiresAtMilliseconds: Int64
    let intentDigest: String
}

struct RuntimeGenerationActivationConsumption: Codable, Sendable, Equatable {
    let intentID: String
    let consumedAtMilliseconds: Int64
    let installedSelectorFileSHA256: String
    let priorGenerationID: RuntimeStoreGenerationID?
    let priorGenerationDigest: String?
    let consumptionDigest: String
}

/// Singleton control-plane truth for the generation named by the durable
/// selector. The epoch advances exactly once with each committed activation.
struct RuntimeGenerationActiveAuthority: Codable, Sendable, Equatable {
    let singletonID: Int
    let activationEpoch: Int64
    let generationID: RuntimeStoreGenerationID
    let authorityManifestDigest: String
    let selectorFileSHA256: String
    let activationIntentID: String
    let activationConsumptionDigest: String
    let priorGenerationID: RuntimeStoreGenerationID?
    let priorGenerationDigest: String?
    let activatedAtMilliseconds: Int64
    let authorityDigest: String
}

/// Durable before selector publication. It binds the current source safety
/// snapshot, the independently verified restore target and its activation
/// baseline, and the single-use recovery authorization. It is the rollback
/// journal floor even if post-commit control reconciliation is interrupted.
struct RuntimeGenerationRestoreBaselinePlan: Codable, Sendable, Equatable {
    let planID: String
    let sourceGenerationID: RuntimeStoreGenerationID
    let sourceGenerationDigest: String
    let sourceSafetyBackupID: String
    let sourceSafetyFenceDigest: String
    let targetGenerationID: RuntimeStoreGenerationID
    let targetVerificationID: String
    let targetActivationBaselineDigest: String
    let recoveryAuthorizationID: String
    let recoveryAuthorizationDigest: String
    let preparedAtMilliseconds: Int64
    let planDigest: String
}

struct RuntimeGenerationRollbackRecord: Codable, Sendable, Equatable {
    let rollbackID: String
    let restoreBaselinePlanID: String
    let sourceGenerationID: RuntimeStoreGenerationID
    let sourceSafetyFenceDigest: String
    let targetGenerationID: RuntimeStoreGenerationID
    let targetVerificationID: String
    let targetObservedFence: RuntimeGenerationRevisionFence
    let postActivationEventCount: Int64
    let postActivationCommandCount: Int64
    let postActivationReceiptCount: Int64
    let postActivationExternalEffectCount: Int64
    let postActivationAttachmentLifecycleCount: Int64
    let activatedAtMilliseconds: Int64
    let rollbackDigest: String
}

struct RuntimeGenerationRetentionTransition: Codable, Sendable, Equatable {
    let transitionID: String
    let generationID: RuntimeStoreGenerationID
    let fromClass: RuntimeGenerationRetentionClass?
    let toClass: RuntimeGenerationRetentionClass
    let reasonCode: String
    let authorityDigest: String
    let occurredAtMilliseconds: Int64
    let transitionDigest: String
}

enum RuntimeGenerationQuarantineReason: String, Codable, Sendable, Equatable, Hashable {
    case corruption
    case futureManifest = "future_manifest"
    case futureDatabaseSchema = "future_database_schema"
    case unknownValue = "unknown_value"
    case digestMismatch = "digest_mismatch"
    case pathReplacement = "path_replacement"
    case failedVerification = "failed_verification"
    case ambiguousImport = "ambiguous_import"
    case unsupportedImport = "unsupported_import"
}

enum RuntimeGenerationRecoveryAction: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case inspectReadOnly = "inspect_read_only"
    case exportOriginal = "export_original"
    case restoreVerifiedBackup = "restore_verified_backup"
    case rollbackToSafetyBackup = "rollback_to_safety_backup"
    case rebuildDerivedState = "rebuild_derived_state"
    case retryFreshConnectionVerification = "retry_fresh_connection_verification"
    case explicitlyAuthorizedReset = "explicitly_authorized_reset"
}

struct RuntimeGenerationQuarantineRecord: Codable, Sendable, Equatable {
    let quarantineID: String
    let reason: RuntimeGenerationQuarantineReason
    let originalArtifact: RuntimeGenerationObservedArtifact
    let originalGenerationID: RuntimeStoreGenerationID?
    let originalManifestDigest: String?
    let diagnosticFingerprint: String
    let allowedActions: [RuntimeGenerationRecoveryAction]
    let quarantinedAtMilliseconds: Int64
    let quarantineDigest: String
}

struct RuntimeGenerationRebuildRecord: Codable, Sendable, Equatable {
    let rebuildID: String
    let migrationRunID: String
    let recoveryExecutionPlanID: String
    let recoveryExecutionClaimID: String
    let recoveryExecutionClaimEpoch: Int64
    let candidateGenerationID: RuntimeStoreGenerationID
    let readyTransitionDigest: String
    let sourceGenerationID: RuntimeStoreGenerationID
    let sourceFenceDigest: String
    let replayReconstructionDigest: String
    let projectionGenerationDigest: String
    let searchGenerationDigest: String
    let equivalenceDigest: String
    let publishedAtMilliseconds: Int64
    let rebuildDigest: String
}

enum RuntimeLegacyImportSourceKind: String, Codable, Sendable, Equatable, Hashable {
    case canonicalV1 = "canonical_v1"
    case swiftData = "swiftdata"
}

struct RuntimeLegacyImportSource: Codable, Sendable, Equatable {
    let importID: String
    let sourceKind: RuntimeLegacyImportSourceKind
    let sourceIdentityDigest: String
    let sourceSchema: String
    let sourceArtifact: RuntimeGenerationObservedArtifact
    let sourceLocationFingerprint: String
    let discoveredAtMilliseconds: Int64
    let sourceDigest: String
}

enum RuntimeLegacyImportPhase: String, Codable, Sendable, Equatable, Hashable {
    case sourcePreserved = "source_preserved"
    case decoding
    case mapped
    case reviewPlanned = "review_planned"
    case reviewAuthorized = "review_authorized"
    case reviewConsumed = "review_consumed"
    case completedNoActivation = "completed_no_activation"
    case abandoned
    case quarantined
}

enum RuntimeLegacyImportCheckpointEvidence: Codable, Sendable, Equatable {
    case sourcePreserved(sourceDigest: String)
    case decoding(cursorDigest: String?)
    case mapped(manifestDigest: String, mappedArtifactSetDigest: String)
    case reviewPlanned(dispositionIntentDigest: String)
    case reviewAuthorized(authorizationDigest: String)
    case reviewConsumed(reviewDigest: String, authorizationDigest: String)
    case completedNoActivation(dispositionIntentDigest: String, reviewDigest: String, authorizationDigest: String)
    case abandoned(reasonCode: String, recoveryActions: [RuntimeGenerationRecoveryAction])
    case quarantined(quarantineDigest: String, recoveryActions: [RuntimeGenerationRecoveryAction])
}

struct RuntimeLegacyImportCheckpoint: Codable, Sendable, Equatable {
    let checkpointID: String
    let importID: String
    let sequence: Int
    let phase: RuntimeLegacyImportPhase
    let priorCheckpointDigest: String?
    let sourceArtifactSHA256: String
    let artifactSetDigest: String
    let lastSourceRecordID: String?
    let processedItemCount: Int
    let occurredAtMilliseconds: Int64
    let evidence: RuntimeLegacyImportCheckpointEvidence
    let checkpointDigest: String
}

struct RuntimeLegacyImportOrphanQuarantine: Codable, Sendable, Equatable {
    let quarantineID: String
    let originalEntryName: String
    let originalEntryIdentity: RuntimeStoreFileIdentity
    let preservedRelativePath: String
    let inventoryDigest: String
    let fileCount: Int
    let totalByteCount: Int64
    let quarantinedAtMilliseconds: Int64
    let quarantineDigest: String
}

/// Immutable pre-move authority for quarantining an unowned Imports entry.
/// The completion record with the same ID consumes this plan after the exact
/// inode has moved and its bounded inventory has been durably observed.
struct RuntimeLegacyImportOrphanQuarantinePlan: Codable, Sendable, Equatable {
    let quarantineID: String
    let originalEntryName: String
    let originalEntryIdentity: RuntimeStoreFileIdentity
    let destinationEntryName: String
    let maximumInventoryFileCount: Int
    let maximumInventoryByteCount: Int64
    let plannedAtMilliseconds: Int64
    let planDigest: String
}

struct RuntimeLegacyMappedArtifactReference: Codable, Sendable, Equatable {
    let formatVersion: Int
    let importID: String
    let sourceRecordID: String
    let sourceRecordDigest: String
    let artifact: RuntimeGenerationArtifact
    let payloadVersion: Int
    let bindingDigest: String
}

enum RuntimeLegacyImportDisposition: String, Codable, Sendable, Equatable, Hashable {
    case reviewableDiscovery = "reviewable_discovery"
    case duplicate
    case ambiguous
    case unsupported
    case malformed
    case quarantined
}

enum RuntimeLegacyImportLossiness: String, Codable, Sendable, Equatable, Hashable {
    case none
    case metadataOnly = "metadata_only"
    case lossyRequiresReview = "lossy_requires_review"
}

struct RuntimeLegacyImportItem: Codable, Sendable, Equatable {
    let importID: String
    let sourceRecordID: String
    let sourceRecordDigest: String
    let canonicalFamily: String?
    let canonicalID: String?
    let canonicalPayloadDigest: String?
    let mappedArtifact: RuntimeLegacyMappedArtifactReference?
    let disposition: RuntimeLegacyImportDisposition
    let warningCodes: [String]
    let lossiness: RuntimeLegacyImportLossiness
    let itemDigest: String
}

enum RuntimeLegacyImportCandidateDisposition: String, Codable, Sendable, Equatable {
    case noActivationAllRejected = "no_activation_all_rejected"
    case noActivationReviewOnly = "no_activation_review_only"
}

struct RuntimeLegacyImportDispositionIntent: Codable, Sendable, Equatable {
    let intentID: String
    let importID: String
    let sourceDigest: String
    let manifestDigest: String
    let orderedItemSetDigest: String
    let orderedDecisionSetDigest: String
    let itemCount: Int
    let retainedForFutureMigrationItemCount: Int
    let retainedLossyForFutureMigrationItemCount: Int
    let rejectedItemCount: Int
    let lossinessConsequenceDigest: String
    let discoveryTransformationVersion: Int
    let reviewContractDigest: String
    let disposition: RuntimeLegacyImportCandidateDisposition
    let plannedAtMilliseconds: Int64
    let intentDigest: String
}

struct RuntimeLegacyImportManifest: Codable, Sendable, Equatable {
    let importID: String
    let itemCount: Int
    let orderedItemSetDigest: String
    let completedAtMilliseconds: Int64
    let manifestDigest: String
}

enum RuntimeLegacyImportReviewDecision: String, Codable, Sendable, Equatable {
    case retainForFutureMigration = "retain_for_future_migration"
    case retainLossyForFutureMigration = "retain_lossy_for_future_migration"
    case reject
}

struct RuntimeLegacyImportReviewDecisionEntry: Codable, Sendable, Equatable {
    let itemDigest: String
    let decision: RuntimeLegacyImportReviewDecision
}

/// Bounded, append-only review input. A review may contain many pages, but no
/// control record or API call carries the complete import corpus in memory.
struct RuntimeLegacyImportReviewPage: Codable, Sendable, Equatable {
    let pageID: String
    let reviewID: String
    let importID: String
    let pageIndex: Int
    let afterSourceRecordID: String?
    let lastSourceRecordID: String
    let entries: [RuntimeLegacyImportReviewDecisionEntry]
    let pageDigest: String
}

struct RuntimeLegacyImportReview: Codable, Sendable, Equatable {
    let reviewID: String
    let importID: String
    let sourceDigest: String
    let itemCount: Int
    let retainedForFutureMigrationItemCount: Int
    let retainedLossyForFutureMigrationItemCount: Int
    let rejectedItemCount: Int
    let pageCount: Int
    let orderedItemSetDigest: String
    let orderedDecisionSetDigest: String
    let reviewerConfirmationDigest: String
    let reviewedAtMilliseconds: Int64
    let reviewDigest: String
}

/// Typed, expiring acknowledgement for one exact reviewed import decision set.
/// Callers cannot supply an unbound digest as consent.
struct RuntimeLegacyImportReviewAuthorization: Codable, Sendable, Equatable {
    let authorizationID: String
    let importID: String
    let sourceDigest: String
    let manifestDigest: String
    let itemCount: Int
    let retainedForFutureMigrationItemCount: Int
    let retainedLossyForFutureMigrationItemCount: Int
    let rejectedItemCount: Int
    let orderedItemSetDigest: String
    let orderedDecisionSetDigest: String
    let lossinessConsequenceDigest: String
    let dispositionIntentDigest: String
    let nonce: String
    let authorizedAtMilliseconds: Int64
    let expiresAtMilliseconds: Int64
    let authorizationDigest: String
}

struct RuntimeGenerationRecoveryAuthorization: Codable, Sendable, Equatable {
    let authorizationID: String
    let action: RuntimeGenerationRecoveryAction
    let targetDigest: String
    let alternativesReviewedDigest: String
    let consequenceDigest: String
    let authorizedAtMilliseconds: Int64
    let expiresAtMilliseconds: Int64
    let authorizationDigest: String
}

/// Immutable proof that an exact destructive activation still had meaningful
/// authorization lifetime at the final selector-publication boundary. It may
/// reconcile that already-committed selector after expiry, but can never grant
/// a later or different commit.
struct RuntimeGenerationRecoveryPrecommitWitness: Codable, Sendable, Equatable {
    let witnessID: String
    let activationIntentID: String
    let migrationRunID: String
    let candidateGenerationID: RuntimeStoreGenerationID
    let candidateSelectorFileSHA256: String
    let recoveryAuthorizationID: String
    let recoveryAuthorizationDigest: String
    let recoveryTargetDigest: String
    let resultDigest: String
    let observedAtMilliseconds: Int64
    let minimumRemainingValidityMilliseconds: Int64
    let witnessDigest: String
}

/// Append-only proof that a destructive recovery authorization was consumed
/// exactly once for the action and target it named.
struct RuntimeGenerationRecoveryAuthorizationConsumption: Codable, Sendable, Equatable {
    let authorizationID: String
    let action: RuntimeGenerationRecoveryAction
    let targetDigest: String
    let resultDigest: String
    let consumedAtMilliseconds: Int64
    let consumptionDigest: String
}

/// A plan authorizes only consumption evidence for one quarantine action. It
/// deliberately does not assert that an execution service exists or succeeded.
struct RuntimeGenerationRecoveryOperationPlan: Codable, Sendable, Equatable {
    let planID: String
    let quarantineID: String
    let action: RuntimeGenerationRecoveryAction
    let targetDigest: String
    let recoveryAuthorizationID: String
    let recoveryAuthorizationDigest: String
    let preparedAtMilliseconds: Int64
    let expiresAtMilliseconds: Int64
    let planDigest: String
}

struct RuntimeGenerationRecoveryOperationConsumption: Codable, Sendable, Equatable {
    let planID: String
    let recoveryAuthorizationID: String
    let action: RuntimeGenerationRecoveryAction
    let targetDigest: String
    let resultDigest: String
    let consumedAtMilliseconds: Int64
    let consumptionDigest: String
}

/// Durable, fenced ownership of one recovery-plan execution. Claims are
/// append-only: an expired claim is recovered by issuing a higher epoch, never
/// by overwriting the prior owner evidence.
struct RuntimeGenerationRecoveryOperationExecutionClaim: Codable, Sendable, Equatable {
    let claimID: String
    let planID: String
    let executorInstanceID: String
    let claimEpoch: Int64
    let claimedAtMilliseconds: Int64
    let expiresAtMilliseconds: Int64
    let claimDigest: String
}

enum RuntimeGenerationRecoveryExecutionAuthorityClassification: String, Codable, Sendable, Equatable, Hashable {
    /// A persisted, accepted fresh-connection verification report is the
    /// authority for the result. This does not itself activate a generation.
    case acceptedFreshConnectionVerification = "accepted_fresh_connection_verification"
    /// Rebuild evidence proves only derived-state equivalence against the
    /// canonical replay; it never manufactures canonical mutation authority.
    case derivedStateEquivalence = "derived_state_equivalence"
    /// The receipt documents a separately authorized reset boundary.
    case explicitlyAuthorizedReset = "explicitly_authorized_reset"
}

/// Typed, immutable outcome of a one-shot recovery plan. It deliberately
/// references the authoritative verification/rebuild records instead of
/// accepting an opaque caller-supplied result digest.
struct RuntimeGenerationRecoveryOperationExecutionReceipt: Codable, Sendable, Equatable {
    let receiptID: String
    let planID: String
    let claimID: String
    let claimEpoch: Int64
    let quarantineID: String
    let candidateGenerationID: RuntimeStoreGenerationID?
    let recoveryAuthorizationID: String
    let recoveryAuthorizationDigest: String
    let action: RuntimeGenerationRecoveryAction
    let targetDigest: String
    let verificationID: String?
    let verificationReportDigest: String?
    let verificationAccepted: Bool?
    let authorityClassification: RuntimeGenerationRecoveryExecutionAuthorityClassification
    let rebuildID: String?
    let rebuildDigest: String?
    let outcomeEvidenceDigest: String
    let executedAtMilliseconds: Int64
    let receiptDigest: String
}

enum RuntimeGenerationRecoveryOperationExecutionClaimResult: Sendable, Equatable {
    case acquired(RuntimeGenerationRecoveryOperationExecutionClaim)
    case held(RuntimeGenerationRecoveryOperationExecutionClaim)
    case completed(RuntimeGenerationRecoveryOperationExecutionReceipt)
}

enum RuntimeGenerationRecoveryOperationPlanDispositionKind: String, Codable, Sendable, Equatable, Hashable {
    case expiredWithoutReceipt = "expired_without_receipt"
    case explicitlyCancelled = "explicitly_cancelled"
}

/// Terminal evidence for an unconsumed plan. The plan itself remains immutable;
/// a successor may be admitted only after this record exists.
struct RuntimeGenerationRecoveryOperationPlanDisposition: Codable, Sendable, Equatable {
    let planID: String
    let kind: RuntimeGenerationRecoveryOperationPlanDispositionKind
    let recoveryAuthorizationID: String?
    let recoveryAuthorizationDigest: String?
    let disposedAtMilliseconds: Int64
    let dispositionDigest: String
}

/// A non-branching successor edge. It makes replacement authorization explicit
/// without erasing a prior plan, claim, or receipt.
struct RuntimeGenerationRecoveryOperationPlanSuccession: Codable, Sendable, Equatable {
    let successorPlanID: String
    let predecessorPlanID: String
    let quarantineID: String
    let action: RuntimeGenerationRecoveryAction
    let predecessorDispositionDigest: String
    let recordedAtMilliseconds: Int64
    let successionDigest: String
}

/// Binds an accepted verification report to the exact live recovery execution
/// claim that observed it. A report from another plan/claim is not reusable.
struct RuntimeGenerationRecoveryOperationVerificationBinding: Codable, Sendable, Equatable {
    let verificationID: String
    let verificationReportDigest: String
    let planID: String
    let claimID: String
    let claimEpoch: Int64
    let candidateGenerationID: RuntimeStoreGenerationID
    let observedAtMilliseconds: Int64
    let bindingDigest: String
}

enum RuntimeGenerationControlCodec {
    static let maximumRecordBytes = 4 * 1_024 * 1_024

    static func encode<Value: Encodable>(_ value: Value) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .millisecondsSince1970
        let data = try encoder.encode(value)
        guard data.isEmpty == false, data.count <= maximumRecordBytes else {
            throw RuntimeGenerationControlError.readBudgetExceeded(
                maximumBytes: maximumRecordBytes
            )
        }
        return data
    }

    static func decode<Value: Codable>(_ type: Value.Type, from data: Data) throws -> Value {
        guard data.isEmpty == false, data.count <= maximumRecordBytes else {
            throw RuntimeGenerationControlError.readBudgetExceeded(
                maximumBytes: maximumRecordBytes
            )
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        let value = try decoder.decode(type, from: data)
        guard try encode(value) == data else {
            throw RuntimeGenerationControlError.malformed(field: "noncanonical_encoding")
        }
        return value
    }

    static func digest<Value: Encodable>(_ value: Value) throws -> String {
        LocalRuntimeStorageChecksum.sha256Hex(for: try encode(value))
    }
}

enum RuntimeGenerationControlValidation {
    static func requireIdentifier(_ value: String, field: String) throws {
        guard value.isEmpty == false,
              value.utf8.count <= 1_024,
              value.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false
        else {
            throw RuntimeGenerationControlError.malformed(field: field)
        }
    }

    static func requireDigest(_ value: String, field: String) throws {
        guard RuntimeStoreManifestCodec.isSHA256Hex(value) else {
            throw RuntimeGenerationControlError.malformed(field: field)
        }
    }

    static func requireRelativePath(_ value: String) throws {
        guard value.isEmpty == false,
              value.utf8.count <= 2_048,
              value.hasPrefix("/") == false,
              value.split(separator: "/").allSatisfy({ $0 != ".." && $0 != "." })
        else {
            throw RuntimeGenerationControlError.malformed(field: "relative_path")
        }
    }
}
