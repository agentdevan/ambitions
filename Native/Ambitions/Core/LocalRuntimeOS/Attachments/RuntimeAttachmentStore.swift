import AmbitionsRuntimeSQLite
import Foundation

struct RuntimeAttachmentAuthorityGraph: Sendable, Equatable {
    let revision: RuntimeAttachmentRevision
    let manifest: RuntimeBlobManifestAuthority
    let envelope: RuntimeBlobKeyEnvelope
    let lifecycle: RuntimeAttachmentCurrentLifecycle
    let references: [RuntimeAttachmentReference]
    let referenceHistory: [RuntimeAttachmentReferenceHistory]
    let history: [RuntimeAttachmentLifecycleHistory]
    let holds: [RuntimeBlobRetentionHold]
    let tombstone: RuntimeBlobDeletionTombstone?
}

struct RuntimeAttachmentAuthoritySnapshot: Sendable, Equatable {
    let revision: RuntimeAttachmentRevision
    let manifest: RuntimeBlobManifestAuthority
    let envelope: RuntimeBlobKeyEnvelope
    let lifecycle: RuntimeAttachmentCurrentLifecycle
    let tombstone: RuntimeBlobDeletionTombstone?
}

struct RuntimeAttachmentReferencePage: Sendable, Equatable {
    let values: [RuntimeAttachmentReference]
    let nextReferenceID: RuntimeAttachmentReferenceID?
}

struct RuntimeAttachmentLifecycleHistoryPage: Sendable, Equatable {
    let values: [RuntimeAttachmentLifecycleHistory]
    let nextStateVersion: UInt64?
}

struct RuntimeAttachmentReferenceHistoryCursor: Sendable, Equatable, Hashable {
    let occurredAt: Date
    let historyID: RuntimeAttachmentReferenceHistoryID
}

struct RuntimeAttachmentReferenceHistoryPage: Sendable, Equatable {
    let values: [RuntimeAttachmentReferenceHistory]
    let nextCursor: RuntimeAttachmentReferenceHistoryCursor?
}

struct RuntimeAttachmentMutationResult: Sendable, Equatable {
    let intent: RuntimeAttachmentCommandIntent
    let lifecycle: RuntimeAttachmentCurrentLifecycle
    let reference: RuntimeAttachmentReference?
    let history: RuntimeAttachmentLifecycleHistory
    let referenceTransitions: [RuntimeAttachmentReferenceHistory]
    let replacedLifecycle: RuntimeAttachmentCurrentLifecycle?
    let replacedHistory: RuntimeAttachmentLifecycleHistory?
    let receiptArtifacts: [RuntimeCommittedReceiptArtifactLink]
}

private struct RuntimeAttachmentDecodedByteBudget {
    private var remainingBytes: Int

    init(maximumBytes: Int) {
        remainingBytes = max(0, maximumBytes)
    }

    mutating func query(
        _ sql: String,
        bindings: [SQLiteBinding] = [],
        database: isolated SQLiteDatabase
    ) throws -> [SQLiteRow] {
        guard remainingBytes > 0 else {
            throw RuntimeCanonicalAttachmentError.decodedByteBudgetExceeded
        }
        let rows: [SQLiteRow]
        do {
            rows = try database.query(
                sql, bindings: bindings, maximumDecodedBytes: remainingBytes
            )
        } catch is SQLiteQueryBudgetExceeded {
            throw RuntimeCanonicalAttachmentError.decodedByteBudgetExceeded
        }
        let decodedBytes = rows.reduce(0) { total, row in
            total + row.values.reduce(0) { subtotal, value in
                let valueBytes: Int = switch value {
                case .null: 1
                case .integer, .real: 8
                case let .text(value): value.utf8.count
                case let .blob(value): value.count
                }
                return subtotal + valueBytes
            }
        }
        guard decodedBytes <= remainingBytes else {
            throw RuntimeCanonicalAttachmentError.decodedByteBudgetExceeded
        }
        remainingBytes -= decodedBytes
        return rows
    }
}

extension CanonicalRuntimeStore: RuntimeAttachmentQuotaAuthorizing {}

extension CanonicalRuntimeStore {
    func reserveAttachmentQuota(_ reservation: RuntimeBlobQuotaReservation, now: Date) async throws {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            try CanonicalRuntimeAttachmentStore.reserveQuota(reservation, now: now, database: database)
        }
    }

    func authorizeAttachmentIntake(
        reservationID: RuntimeBlobQuotaReservationID,
        privacyDomain: RuntimeAttachmentPrivacyDomain,
        maximumBytes: Int64,
        now: Date
    ) async throws -> RuntimeAttachmentQuotaAuthorization {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.authorizeIntake(
                reservationID: reservationID, privacyDomain: privacyDomain,
                maximumBytes: maximumBytes, now: now, database: database
            )
        }
    }

    func releaseAttachmentIntakeAuthorization(
        _ authorization: RuntimeAttachmentQuotaAuthorization,
        now: Date
    ) async throws {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            try CanonicalRuntimeAttachmentStore.releaseIntakeAuthorization(
                authorization, now: now, database: database
            )
        }
    }

    func releaseExpiredAttachmentQuotaReservations(limit: Int, now: Date) async throws -> Int {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.releaseExpiredQuotaReservations(
                limit: limit, now: now, database: database
            )
        }
    }

    func persistStagedAttachment(
        _ bundle: RuntimeAttachmentStageBundle,
        reservationID: RuntimeBlobQuotaReservationID,
        now: Date
    ) async throws -> RuntimeAttachmentStagePersistenceResult {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.persistStage(
                bundle, reservationID: reservationID, now: now, database: database
            )
        }
    }

    func acquireAttachmentRetentionHold(
        _ hold: RuntimeBlobRetentionHold,
        commandID: RuntimeCommandID,
        receiptID: RuntimeReceiptID,
        lineage: RuntimeAuthorityLineageReference
    ) async throws {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            try CanonicalRuntimeAttachmentStore.acquireHold(
                hold, commandID: commandID, receiptID: receiptID,
                lineage: lineage, database: database
            )
        }
    }

    func acquireAuthenticatedAttachmentReadHold(
        _ hold: RuntimeBlobRetentionHold,
        revisionID: RuntimeAttachmentRevisionID,
        commandID: RuntimeCommandID,
        receiptID: RuntimeReceiptID,
        lineage: RuntimeAuthorityLineageReference
    ) async throws -> RuntimeAttachmentAuthoritySnapshot {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.acquireAuthenticatedReadHold(
                hold, revisionID: revisionID, commandID: commandID,
                receiptID: receiptID, lineage: lineage, database: database
            )
        }
    }

    func releaseAttachmentRetentionHold(
        holdID: RuntimeBlobHoldID,
        blobID: RuntimeBlobID,
        authorityID: String,
        commandID: RuntimeCommandID,
        receiptID: RuntimeReceiptID,
        lineage: RuntimeAuthorityLineageReference,
        at now: Date
    ) async throws {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            try CanonicalRuntimeAttachmentStore.releaseHold(
                holdID: holdID, blobID: blobID, authorityID: authorityID,
                commandID: commandID, receiptID: receiptID,
                lineage: lineage, at: now, database: database
            )
        }
    }

    func attachmentGraph(revisionID: RuntimeAttachmentRevisionID) async throws -> RuntimeAttachmentAuthorityGraph? {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.load(revisionID: revisionID, database: database)
        }
    }

    func attachmentAuthoritySnapshot(
        revisionID: RuntimeAttachmentRevisionID
    ) async throws -> RuntimeAttachmentAuthoritySnapshot? {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.loadSnapshot(
                revisionID: revisionID, database: database
            )
        }
    }

    func attachmentReferencePage(
        revisionID: RuntimeAttachmentRevisionID,
        after referenceID: RuntimeAttachmentReferenceID? = nil,
        limit: Int = 50
    ) async throws -> RuntimeAttachmentReferencePage {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.referencePage(
                revisionID: revisionID, after: referenceID, limit: limit, database: database
            )
        }
    }

    func attachmentLifecycleHistoryPage(
        revisionID: RuntimeAttachmentRevisionID,
        afterStateVersion: UInt64? = nil,
        limit: Int = 50
    ) async throws -> RuntimeAttachmentLifecycleHistoryPage {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.lifecycleHistoryPage(
                revisionID: revisionID, afterStateVersion: afterStateVersion,
                limit: limit, database: database
            )
        }
    }

    func attachmentReferenceHistoryPage(
        revisionID: RuntimeAttachmentRevisionID,
        after cursor: RuntimeAttachmentReferenceHistoryCursor? = nil,
        limit: Int = 50
    ) async throws -> RuntimeAttachmentReferenceHistoryPage {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.referenceHistoryPage(
                revisionID: revisionID, after: cursor, limit: limit, database: database
            )
        }
    }

    func dueAttachmentStagingOrphans(limit: Int, now: Date) async throws -> [RuntimeBlobStagingOrphan] {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.dueStagingOrphans(
                limit: limit, now: now, database: database
            )
        }
    }

    func confirmAttachmentDedupCandidate(
        revisionID: RuntimeAttachmentRevisionID,
        canonicalBlobID: RuntimeBlobID,
        keyedContentAddress: RuntimeAttachmentContentAddress,
        now: Date
    ) async throws -> RuntimeAttachmentAuthoritySnapshot {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.confirmDedupCandidate(
                revisionID: revisionID, canonicalBlobID: canonicalBlobID,
                keyedContentAddress: keyedContentAddress, now: now, database: database
            )
        }
    }

    func dueAttachmentFinalizations(limit: Int, now: Date) async throws -> [RuntimeBlobFinalizationWork] {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.dueFinalizations(
                limit: limit, now: now, database: database
            )
        }
    }

    func beginAttachmentRecoveryAttempt(
        workKind: RuntimeAttachmentRecoveryWorkKind,
        authorityID: String,
        occurrence: String,
        now: Date
    ) async throws -> Bool {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.beginRecoveryAttempt(
                workKind: workKind, authorityID: authorityID,
                occurrence: occurrence, now: now, database: database
            )
        }
    }

    func recordAttachmentRecoveryAttemptFailure(
        workKind: RuntimeAttachmentRecoveryWorkKind,
        authorityID: String,
        errorFingerprint: String
    ) async throws {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            try CanonicalRuntimeAttachmentStore.recordRecoveryAttemptFailure(
                workKind: workKind, authorityID: authorityID,
                errorFingerprint: errorFingerprint, database: database
            )
        }
    }

    func recordAttachmentRecoveryFailureAfterRolledBackAttempt(
        workKind: RuntimeAttachmentRecoveryWorkKind,
        authorityID: String,
        occurrence: String,
        now: Date,
        errorFingerprint: String
    ) async throws {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            guard try CanonicalRuntimeAttachmentStore.beginRecoveryAttempt(
                workKind: workKind, authorityID: authorityID,
                occurrence: occurrence, now: now, database: database
            ) else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            try CanonicalRuntimeAttachmentStore.recordRecoveryAttemptFailure(
                workKind: workKind, authorityID: authorityID,
                errorFingerprint: errorFingerprint, database: database
            )
        }
    }

    func resolveAttachmentRecoveryAttempt(
        workKind: RuntimeAttachmentRecoveryWorkKind,
        authorityID: String,
        at now: Date
    ) async throws {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            try CanonicalRuntimeAttachmentStore.resolveRecoveryAttempt(
                workKind: workKind, authorityID: authorityID, at: now, database: database
            )
        }
    }

    func completeAttachmentFinalization(
        _ work: RuntimeBlobFinalizationWork,
        proof: RuntimeAttachmentFinalizationProof
    ) async throws {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            try CanonicalRuntimeAttachmentStore.completeFinalization(
                work, proof: proof, database: database
            )
            _ = try CanonicalRuntimeAttachmentStore.resolveOpenRecoveryFindings(
                issue: .finalizationMissing, blobID: work.manifest.blobID,
                relativeDirectory: work.manifest.opaqueRelativeDirectory,
                at: proof.finalizedAt, database: database
            )
            try CanonicalRuntimeAttachmentStore.resolveRecoveryAttempt(
                workKind: .finalization, authorityID: work.manifest.blobID.rawValue,
                at: proof.finalizedAt, database: database
            )
        }
    }

    func acquireAttachmentGCLease(
        leaseID: RuntimeBlobGCLeaseID,
        ownerID: String,
        now: Date,
        expiresAt: Date
    ) async throws -> RuntimeBlobGCWork? {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.acquireGCLease(
                leaseID: leaseID, ownerID: ownerID, now: now,
                expiresAt: expiresAt, database: database
            )
        }
    }

    func expireAttachmentGCLeases(limit: Int, now: Date) async throws -> Int {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.expireGCLeases(
                limit: limit, now: now, database: database
            )
        }
    }

    func renewAttachmentGCLease(
        _ lease: RuntimeBlobGCLease,
        now: Date,
        expiresAt: Date
    ) async throws -> RuntimeBlobGCLease {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.renewGCLease(
                lease, now: now, expiresAt: expiresAt, database: database
            )
        }
    }

    func confirmAttachmentGCLease(
        _ lease: RuntimeBlobGCLease,
        now: Date
    ) async throws -> RuntimeBlobGCWork {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.confirmGCLease(
                lease, now: now, database: database
            )
        }
    }

    func recordAttachmentDeletion(
        work: RuntimeBlobGCWork,
        lease: RuntimeBlobGCLease,
        tombstoneID: RuntimeBlobTombstoneID,
        proof: RuntimeAttachmentPhysicalDeletionProof,
        recordedAt: Date
    ) async throws -> RuntimeBlobDeletionTombstone {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            let tombstone = try CanonicalRuntimeAttachmentStore.recordDeletion(
                work: work, lease: lease, tombstoneID: tombstoneID,
                proof: proof, recordedAt: recordedAt, database: database
            )
            _ = try CanonicalRuntimeAttachmentStore.resolveOpenRecoveryFindings(
                issue: .interruptedDeletion, blobID: work.manifest.blobID,
                relativeDirectory: work.manifest.opaqueRelativeDirectory,
                at: proof.deletedAt, database: database
            )
            // Staged expiry remains actionable while deletion is pending, then closes only
            // after the tombstone, quota debit, and lease release commit in this transaction.
            _ = try CanonicalRuntimeAttachmentStore.resolveOpenRecoveryFindings(
                issue: .stagedExpired, blobID: work.manifest.blobID,
                relativeDirectory: work.manifest.opaqueRelativeDirectory,
                at: proof.deletedAt, database: database
            )
            return tombstone
        }
    }

    func attachmentRecoverySnapshots(
        limit: Int,
        afterBlobID: RuntimeBlobID?
    ) async throws -> [RuntimeAttachmentAuthoritySnapshot] {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.recoverySnapshots(
                limit: limit, afterBlobID: afterBlobID, database: database
            )
        }
    }

    func attachmentRecoveryCursor(
        scanKind: RuntimeAttachmentRecoveryScanKind
    ) async throws -> RuntimeAttachmentRecoveryCursor? {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.recoveryCursor(
                scanKind: scanKind, database: database
            )
        }
    }

    func advanceAttachmentRecoveryCursor(
        scanKind: RuntimeAttachmentRecoveryScanKind,
        lastKey: String?,
        wrapped: Bool,
        at now: Date
    ) async throws -> RuntimeAttachmentRecoveryCursor {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.advanceRecoveryCursor(
                scanKind: scanKind, lastKey: lastKey, wrapped: wrapped,
                at: now, database: database
            )
        }
    }

    func resolveOpenAttachmentRecoveryFindings(
        issue: RuntimeAttachmentRecoveryIssue,
        blobID: RuntimeBlobID?,
        relativeDirectory: String,
        at now: Date
    ) async throws -> Int {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.resolveOpenRecoveryFindings(
                issue: issue, blobID: blobID, relativeDirectory: relativeDirectory,
                at: now, database: database
            )
        }
    }

    func claimUnownedAttachmentManifestDeletion(
        _ inspection: RuntimeOwnedAttachmentManifestInspection,
        recoveryAuthorityID: String,
        now: Date,
        expiresAt: Date
    ) async throws -> RuntimeAttachmentManifestDeletionClaim {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.claimUnownedManifestDeletion(
                inspection, recoveryAuthorityID: recoveryAuthorityID,
                now: now, expiresAt: expiresAt, database: database
            )
        }
    }

    func activeUnownedAttachmentManifestDeletionClaims(
        limit: Int,
        afterClaimID: String?,
        now: Date
    ) async throws -> [RuntimeAttachmentManifestDeletionRecoveryWork] {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.activeUnownedManifestDeletionClaims(
                limit: limit, afterClaimID: afterClaimID, now: now, database: database
            )
        }
    }

    func renewUnownedAttachmentManifestDeletionClaim(
        _ claim: RuntimeAttachmentManifestDeletionClaim,
        now: Date,
        expiresAt: Date
    ) async throws -> RuntimeAttachmentManifestDeletionClaim {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.renewUnownedManifestDeletionClaim(
                claim, now: now, expiresAt: expiresAt, database: database
            )
        }
    }

    func completeUnownedAttachmentManifestDeletion(
        claim: RuntimeAttachmentManifestDeletionClaim,
        proof: RuntimeAttachmentManifestDeletionProof,
        recoveryAuthorityID: String
    ) async throws {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            try CanonicalRuntimeAttachmentStore.completeUnownedManifestDeletion(
                claim: claim, proof: proof, recoveryAuthorityID: recoveryAuthorityID,
                database: database
            )
        }
    }

    func dueStagedAttachmentExpirations(
        limit: Int,
        now: Date
    ) async throws -> [RuntimeAttachmentRevisionID] {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.dueStagedExpirations(
                limit: limit, now: now, database: database
            )
        }
    }

    func expireStagedAttachmentDuringRecovery(
        revisionID: RuntimeAttachmentRevisionID,
        recoveryAuthorityID: String,
        at now: Date
    ) async throws -> RuntimeAttachmentRecoveryFinding? {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            guard let graph = try CanonicalRuntimeAttachmentStore.loadSnapshot(
                revisionID: revisionID, database: database
            ), graph.manifest.blobID.rawValue == recoveryAuthorityID else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            let occurrence = CanonicalRuntimeAttachmentStore.stagedExpiryOccurrence(
                revisionID: revisionID, stateVersion: graph.lifecycle.stateVersion
            )
            guard try CanonicalRuntimeAttachmentStore.beginRecoveryAttempt(
                workKind: .stagingOrphan, authorityID: recoveryAuthorityID,
                occurrence: occurrence, now: now, database: database
            ) else { return nil }
            let finding = try CanonicalRuntimeAttachmentStore.expireStagedAttachment(
                revisionID: revisionID, at: now, database: database
            )
            try CanonicalRuntimeAttachmentStore.resolveRecoveryAttempt(
                workKind: .stagingOrphan, authorityID: recoveryAuthorityID,
                at: now, database: database
            )
            return finding
        }
    }

    func recordAttachmentRecoveryFinding(_ finding: RuntimeAttachmentRecoveryFinding) async throws {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            try CanonicalRuntimeAttachmentStore.recordRecoveryFinding(finding, database: database)
        }
    }

    func quarantineAttachmentForRecovery(
        revisionID: RuntimeAttachmentRevisionID,
        reason: RuntimeAttachmentQuarantineReason,
        evidenceFingerprint: String,
        at now: Date
    ) async throws {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            try CanonicalRuntimeAttachmentStore.quarantineForRecovery(
                revisionID: revisionID, reason: reason,
                evidenceFingerprint: evidenceFingerprint, at: now, database: database
            )
        }
    }

    func hasAttachmentBlobAuthority(
        blobID: RuntimeBlobID,
        manifestDigest: String,
        opaqueRelativeDirectory: String
    ) async throws -> Bool {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.hasBlobAuthority(
                blobID: blobID, manifestDigest: manifestDigest,
                opaqueRelativeDirectory: opaqueRelativeDirectory, database: database
            )
        }
    }
}

enum CanonicalRuntimeAttachmentStore {
    static func requireSchema(_ database: isolated SQLiteDatabase) throws {
        try CanonicalRuntimeAttachmentSchemaPlan.requireIntegratedSchema(in: database)
    }

    static func reserveQuota(
        _ reservation: RuntimeBlobQuotaReservation,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws {
        guard reservation.version == runtimeCanonicalAttachmentModelVersion,
              reservation.reservedBytes > 0,
              reservation.reservedBytes <= RuntimeAttachmentLimits.maximumAttachmentBytes,
              reservation.ownerID.isEmpty == false,
              reservation.createdAt <= now,
              reservation.expiresAt > now,
              reservation.expiresAt.timeIntervalSince(reservation.createdAt) <= RuntimeAttachmentLimits.maximumQuotaReservationSeconds,
              reservation.consumedByBlobID == nil else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        try database.execute(
            """
            INSERT INTO runtime_blob_quota_ledgers(
                privacy_domain, owner_id, limit_bytes, reserved_bytes,
                stored_bytes, orphan_bytes, state_version, updated_at_ms
            ) VALUES(?, ?, ?, 0, 0, 0, 1, ?)
            ON CONFLICT(privacy_domain, owner_id) DO NOTHING
            """,
            bindings: [
                .text(reservation.privacyDomain.rawValue),
                .text(reservation.ownerID),
                .integer(RuntimeAttachmentLimits.maximumQuotaBytesPerPrivacyDomain),
                .integer(try milliseconds(now)),
            ]
        )
        let ledgerChanged = try database.execute(
            """
            UPDATE runtime_blob_quota_ledgers
            SET reserved_bytes = reserved_bytes + ?, state_version = state_version + 1,
                updated_at_ms = ?
            WHERE privacy_domain = ? AND owner_id = ?
              AND reserved_bytes + stored_bytes + orphan_bytes + ? <= limit_bytes
              AND state_version < 9223372036854775807
            """,
            bindings: [
                .integer(reservation.reservedBytes), .integer(try milliseconds(now)),
                .text(reservation.privacyDomain.rawValue), .text(reservation.ownerID),
                .integer(reservation.reservedBytes),
            ]
        )
        guard ledgerChanged == 1 else {
            let versionRows = try database.query(
                """
                SELECT state_version FROM runtime_blob_quota_ledgers
                WHERE privacy_domain = ? AND owner_id = ? LIMIT 2
                """,
                bindings: [
                    .text(reservation.privacyDomain.rawValue), .text(reservation.ownerID),
                ]
            )
            guard versionRows.count == 1,
                  case let .integer(stateVersion)? = versionRows[0].value(named: "state_version")
            else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
            if stateVersion == Int64.max {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            throw RuntimeCanonicalAttachmentError.quotaExceeded
        }
        try database.execute(
            """
            INSERT INTO runtime_blob_quota_reservations(
                reservation_id, privacy_domain, reserved_bytes, owner_id,
                created_at_ms, expires_at_ms, consumed_by_blob_id, released_at_ms,
                reservation_version
            ) VALUES(?, ?, ?, ?, ?, ?, NULL, NULL, 1)
            """,
            bindings: [
                .text(reservation.reservationID.rawValue), .text(reservation.privacyDomain.rawValue),
                .integer(reservation.reservedBytes), .text(reservation.ownerID),
                .integer(try milliseconds(reservation.createdAt)), .integer(try milliseconds(reservation.expiresAt)),
            ]
        )
    }

    static func acquireHold(
        _ hold: RuntimeBlobRetentionHold,
        commandID: RuntimeCommandID,
        receiptID: RuntimeReceiptID,
        lineage: RuntimeAuthorityLineageReference,
        database: isolated SQLiteDatabase
    ) throws {
        guard hold.version == runtimeCanonicalAttachmentModelVersion,
              hold.authorityID.isEmpty == false, hold.authorityID.utf8.count <= 1_024,
              hold.retainUntil.map({ $0 > hold.createdAt }) ?? true else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        _ = try RuntimeAttachmentCodec.sqliteInteger(lineage.eventSequence)
        let createdAtMS = try milliseconds(hold.createdAt)
        try requireHoldLineage(
            commandID: commandID, receiptID: receiptID, lineage: lineage,
            database: database
        )
        let eligibility = try database.query(
            """
            SELECT 1 AS eligible
            FROM runtime_attachment_current_lifecycle AS s
            WHERE s.blob_id = ? AND s.lifecycle_state <> 'deletion_pending'
              AND NOT EXISTS (
                  SELECT 1 FROM runtime_blob_deletion_tombstones AS t WHERE t.blob_id = s.blob_id
              )
              AND NOT EXISTS (
                  SELECT 1 FROM runtime_blob_gc_leases AS l
                  WHERE l.blob_id = s.blob_id AND l.lease_state = 'active'
                    AND l.expires_at_ms > ?
              )
            LIMIT 2
            """,
            bindings: [.text(hold.blobID.rawValue), .integer(createdAtMS)]
        )
        guard eligibility.count == 1 else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let count = try database.query(
            """
            SELECT COUNT(*) AS total FROM runtime_blob_retention_holds
            WHERE blob_id = ? AND released_at_ms IS NULL
              AND (retain_until_ms IS NULL OR retain_until_ms > ?)
            """,
            bindings: [.text(hold.blobID.rawValue), .integer(createdAtMS)]
        )
        guard count.count == 1,
              case let .integer(total)? = count[0].value(named: "total"),
              total < Int64(RuntimeAttachmentLimits.maximumHolds) else {
            throw RuntimeCanonicalAttachmentError.retentionHoldActive
        }
        let retainBinding: SQLiteValue
        if let retainUntil = hold.retainUntil {
            retainBinding = .integer(try milliseconds(retainUntil))
        } else {
            retainBinding = .null
        }
        try insertHoldHistory(
            holdID: hold.holdID, blobID: hold.blobID, transition: .acquired,
            authorityID: hold.authorityID, commandID: commandID, receiptID: receiptID,
            lineage: lineage, occurredAt: hold.createdAt, database: database
        )
        try database.execute(
            """
            INSERT INTO runtime_blob_retention_holds(
                hold_id, blob_id, hold_kind, authority_id, retain_until_ms,
                created_at_ms, released_at_ms, hold_version
            ) VALUES(?, ?, ?, ?, ?, ?, NULL, 1)
            """,
            bindings: [
                .text(hold.holdID.rawValue), .text(hold.blobID.rawValue),
                .text(hold.kind.rawValue), .text(hold.authorityID),
                retainBinding,
                .integer(try milliseconds(hold.createdAt)),
            ]
        )
    }

    static func acquireAuthenticatedReadHold(
        _ hold: RuntimeBlobRetentionHold,
        revisionID: RuntimeAttachmentRevisionID,
        commandID: RuntimeCommandID,
        receiptID: RuntimeReceiptID,
        lineage: RuntimeAuthorityLineageReference,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentAuthoritySnapshot {
        var budget = RuntimeAttachmentDecodedByteBudget(
            maximumBytes: RuntimeAttachmentLimits.maximumPageBytes
        )
        guard hold.kind == .receipt || hold.kind == .export,
              let snapshot = try loadSnapshot(
                revisionID: revisionID, budget: &budget, database: database
              ),
              hold.blobID == snapshot.manifest.blobID,
              snapshot.lifecycle.state == .referenced || snapshot.lifecycle.state == .finalized,
              snapshot.lifecycle.quarantineReasonCode == nil,
              snapshot.tombstone == nil else {
            throw RuntimeCanonicalAttachmentError.quarantined
        }
        let rows = try budget.query(
            """
            SELECT a.reference_id, a.revision_id, a.target_family, a.target_object_id,
                   a.target_revision, a.reference_state, a.command_id, a.receipt_id,
                   a.terminal_event_sequence, a.reference_version, a.reference_payload,
                   a.reference_digest, a.created_at_ms, a.removed_at_ms,
                   e.event_id, e.event_hash
            FROM runtime_attachment_references AS a
            JOIN runtime_attachment_receipt_links AS l
              ON l.receipt_id = a.receipt_id AND l.revision_id = a.revision_id
             AND l.blob_id = a.blob_id AND l.link_kind = 'reference'
            JOIN runtime_attachment_current_lifecycle AS s
              ON s.blob_id = a.blob_id AND s.manifest_digest = l.manifest_digest
            JOIN runtime_receipt_artifact_links AS ra
              ON ra.receipt_id = l.receipt_id
             AND ra.artifact_kind = 'attachment_revision'
             AND ra.artifact_id = l.revision_id || '#reference'
             AND ra.artifact_digest = l.artifact_digest
            JOIN runtime_committed_receipt_cores AS c ON c.receipt_id = a.receipt_id
            JOIN runtime_semantic_events AS e ON e.sequence = c.terminal_event_sequence
            WHERE a.revision_id = ? AND a.blob_id = ? AND a.receipt_id = ?
              AND a.command_id = ? AND a.reference_state = 'active'
              AND l.manifest_digest = ?
              AND s.lifecycle_state IN ('referenced','finalized')
              AND s.quarantine_reason IS NULL
              AND c.command_id = ? AND c.terminal_event_sequence = ?
              AND a.terminal_event_sequence = c.terminal_event_sequence
              AND c.terminal_event_id = ? AND c.terminal_event_hash = ?
              AND e.event_id = c.terminal_event_id AND e.event_hash = c.terminal_event_hash
              AND NOT EXISTS (
                  SELECT 1 FROM runtime_blob_quarantine AS q
                  WHERE q.blob_id = a.blob_id AND q.resolved_at_ms IS NULL
              )
              AND NOT EXISTS (
                  SELECT 1 FROM runtime_blob_deletion_tombstones AS t
                  WHERE t.blob_id = a.blob_id
              )
              AND NOT EXISTS (
                  SELECT 1 FROM runtime_blob_gc_leases AS g
                  WHERE g.blob_id = a.blob_id AND g.lease_state = 'active'
              )
            LIMIT 2
            """,
            bindings: [
                .text(revisionID.rawValue), .text(hold.blobID.rawValue),
                .text(receiptID.rawValue), .text(commandID.rawValue),
                .text(snapshot.revision.manifestDigest), .text(commandID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(lineage.eventSequence)), .text(lineage.eventID.rawValue),
                .text(lineage.eventHash),
            ],
            database: database
        )
        guard rows.count == 1,
              try decodeReferenceRow(rows[0]).revisionID == revisionID else {
            throw RuntimeCanonicalAttachmentError.quarantined
        }
        try acquireHold(
            hold, commandID: commandID, receiptID: receiptID,
            lineage: lineage, database: database
        )
        return snapshot
    }

    static func releaseHold(
        holdID: RuntimeBlobHoldID,
        blobID: RuntimeBlobID,
        authorityID: String,
        commandID: RuntimeCommandID,
        receiptID: RuntimeReceiptID,
        lineage: RuntimeAuthorityLineageReference,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws {
        _ = try RuntimeAttachmentCodec.sqliteInteger(lineage.eventSequence)
        try requireHoldLineage(
            commandID: commandID, receiptID: receiptID, lineage: lineage,
            database: database
        )
        let rows = try database.query(
            """
            SELECT 1 AS present FROM runtime_blob_retention_holds
            WHERE hold_id = ? AND blob_id = ? AND authority_id = ?
              AND released_at_ms IS NULL LIMIT 2
            """,
            bindings: [.text(holdID.rawValue), .text(blobID.rawValue), .text(authorityID)]
        )
        guard rows.count == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        try insertHoldHistory(
            holdID: holdID, blobID: blobID, transition: .released,
            authorityID: authorityID, commandID: commandID, receiptID: receiptID,
            lineage: lineage, occurredAt: now, database: database
        )
        let changed = try database.execute(
            """
            UPDATE runtime_blob_retention_holds SET released_at_ms = ?
            WHERE hold_id = ? AND blob_id = ? AND authority_id = ? AND released_at_ms IS NULL
            """,
            bindings: [
                .integer(try milliseconds(now)), .text(holdID.rawValue),
                .text(blobID.rawValue), .text(authorityID),
            ]
        )
        guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
    }

    private static func insertHoldHistory(
        holdID: RuntimeBlobHoldID,
        blobID: RuntimeBlobID,
        transition: RuntimeBlobRetentionHoldTransitionKind,
        authorityID: String,
        commandID: RuntimeCommandID,
        receiptID: RuntimeReceiptID,
        lineage: RuntimeAuthorityLineageReference,
        occurredAt: Date,
        database: isolated SQLiteDatabase
    ) throws {
        let unsigned = RuntimeBlobRetentionHoldHistory(
            version: runtimeCanonicalAttachmentModelVersion, holdID: holdID, blobID: blobID,
            transition: transition, authorityID: authorityID, commandID: commandID,
            receiptID: receiptID, lineage: lineage, occurredAt: occurredAt,
            transitionDigest: String(repeating: "0", count: 64)
        )
        let digest = try RuntimeAttachmentCodec.digest(
            unsigned, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let value = RuntimeBlobRetentionHoldHistory(
            version: unsigned.version, holdID: holdID, blobID: blobID,
            transition: transition, authorityID: authorityID, commandID: commandID,
            receiptID: receiptID, lineage: lineage, occurredAt: occurredAt,
            transitionDigest: digest
        )
        let bytes = try RuntimeAttachmentCodec.encode(
            value, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        try database.execute(
            """
            INSERT INTO runtime_blob_retention_hold_history(
                history_digest, hold_id, blob_id, transition_kind, authority_id,
                command_id, receipt_id, terminal_event_sequence,
                terminal_event_id, terminal_event_hash, history_version,
                history_payload, occurred_at_ms
            ) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)
            """,
            bindings: [
                .text(digest), .text(holdID.rawValue), .text(blobID.rawValue),
                .text(transition.rawValue), .text(authorityID), .text(commandID.rawValue),
                .text(receiptID.rawValue), .integer(try RuntimeAttachmentCodec.sqliteInteger(lineage.eventSequence)),
                .text(lineage.eventID.rawValue), .text(lineage.eventHash),
                .blob(bytes), .integer(try milliseconds(occurredAt)),
            ]
        )
    }

    private static func requireHoldLineage(
        commandID: RuntimeCommandID,
        receiptID: RuntimeReceiptID,
        lineage: RuntimeAuthorityLineageReference,
        database: isolated SQLiteDatabase
    ) throws {
        let rows = try database.query(
            """
            SELECT 1 AS authenticated
            FROM runtime_commit_receipts AS r
            JOIN runtime_committed_receipt_cores AS c ON c.receipt_id = r.receipt_id
            JOIN runtime_semantic_events AS e ON e.sequence = r.terminal_event_sequence
            WHERE r.receipt_id = ? AND r.command_id = ?
              AND c.command_id = ? AND c.terminal_event_sequence = ?
              AND c.terminal_event_id = ? AND c.terminal_event_hash = ?
              AND e.sequence = ? AND e.event_id = ? AND e.event_hash = ?
              AND e.command_id = ?
            LIMIT 2
            """,
            bindings: [
                .text(receiptID.rawValue), .text(commandID.rawValue),
                .text(commandID.rawValue), .integer(try RuntimeAttachmentCodec.sqliteInteger(lineage.eventSequence)),
                .text(lineage.eventID.rawValue), .text(lineage.eventHash),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(lineage.eventSequence)), .text(lineage.eventID.rawValue),
                .text(lineage.eventHash), .text(commandID.rawValue),
            ]
        )
        guard rows.count == 1 else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
    }

    static func authorizeIntake(
        reservationID: RuntimeBlobQuotaReservationID,
        privacyDomain: RuntimeAttachmentPrivacyDomain,
        maximumBytes: Int64,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentQuotaAuthorization {
        guard maximumBytes > 0, maximumBytes <= RuntimeAttachmentLimits.maximumAttachmentBytes else {
            throw RuntimeCanonicalAttachmentError.sizeLimitExceeded
        }
        let rows = try database.query(
            """
            SELECT privacy_domain, reserved_bytes, owner_id, expires_at_ms,
                   consumed_by_blob_id, released_at_ms
            FROM runtime_blob_quota_reservations WHERE reservation_id = ? LIMIT 2
            """,
            bindings: [.text(reservationID.rawValue)]
        )
        guard rows.count == 1,
              rows[0].value(named: "privacy_domain") == .text(privacyDomain.rawValue),
              case let .integer(reservedBytes)? = rows[0].value(named: "reserved_bytes"),
              case let .text(ownerID)? = rows[0].value(named: "owner_id"),
              reservedBytes >= maximumBytes,
              case let .integer(expiresAtMS)? = rows[0].value(named: "expires_at_ms"),
              expiresAtMS > try milliseconds(now),
              rows[0].value(named: "consumed_by_blob_id") == .null,
              rows[0].value(named: "released_at_ms") == .null else {
            throw RuntimeCanonicalAttachmentError.reservationExpired
        }
        let expiresAt = Date(timeIntervalSince1970: Double(expiresAtMS) / 1_000)
        let material = [
            "ambitions.attachment.quota-authorization.v1", reservationID.rawValue,
            privacyDomain.rawValue, ownerID, String(reservedBytes), String(expiresAtMS),
        ].joined(separator: "\u{0}")
        return RuntimeAttachmentQuotaAuthorization(
            reservationID: reservationID, privacyDomain: privacyDomain, ownerID: ownerID,
            reservedBytes: reservedBytes, expiresAt: expiresAt,
            authorizationDigest: RuntimeAttachmentCodec.sha256(Data(material.utf8))
        )
    }

    static func releaseIntakeAuthorization(
        _ authorization: RuntimeAttachmentQuotaAuthorization,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws {
        let expiresAtMS = try milliseconds(authorization.expiresAt)
        let material = [
            "ambitions.attachment.quota-authorization.v1", authorization.reservationID.rawValue,
            authorization.privacyDomain.rawValue, authorization.ownerID,
            String(authorization.reservedBytes), String(expiresAtMS),
        ].joined(separator: "\u{0}")
        guard RuntimeAttachmentCodec.sha256(Data(material.utf8)) == authorization.authorizationDigest else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let rows = try database.query(
            """
            SELECT reserved_bytes, released_at_ms, consumed_by_blob_id
            FROM runtime_blob_quota_reservations
            WHERE reservation_id = ? AND privacy_domain = ? AND owner_id = ? LIMIT 2
            """,
            bindings: [
                .text(authorization.reservationID.rawValue),
                .text(authorization.privacyDomain.rawValue), .text(authorization.ownerID),
            ]
        )
        guard rows.count == 1,
              rows[0].value(named: "consumed_by_blob_id") == .null,
              case let .integer(reservedBytes)? = rows[0].value(named: "reserved_bytes"),
              reservedBytes == authorization.reservedBytes else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        if rows[0].value(named: "released_at_ms") != .null { return }
        let released = try database.execute(
            """
            UPDATE runtime_blob_quota_reservations SET released_at_ms = ?
            WHERE reservation_id = ? AND consumed_by_blob_id IS NULL AND released_at_ms IS NULL
            """,
            bindings: [
                .integer(try milliseconds(now)), .text(authorization.reservationID.rawValue),
            ]
        )
        guard released == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        let ledger = try database.execute(
            """
            UPDATE runtime_blob_quota_ledgers
            SET reserved_bytes = reserved_bytes - ?, state_version = state_version + 1,
                updated_at_ms = ?
            WHERE privacy_domain = ? AND owner_id = ? AND reserved_bytes >= ?
              AND state_version < 9223372036854775807
            """,
            bindings: [
                .integer(reservedBytes), .integer(try milliseconds(now)),
                .text(authorization.privacyDomain.rawValue), .text(authorization.ownerID),
                .integer(reservedBytes),
            ]
        )
        guard ledger == 1 else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
    }

    static func releaseExpiredQuotaReservations(
        limit: Int,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> Int {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let nowMS = try milliseconds(now)
        let rows = try database.query(
            """
            SELECT reservation_id, privacy_domain, reserved_bytes, owner_id,
                   created_at_ms, expires_at_ms
            FROM runtime_blob_quota_reservations
            WHERE consumed_by_blob_id IS NULL AND released_at_ms IS NULL
              AND expires_at_ms <= ?
            ORDER BY expires_at_ms, reservation_id LIMIT ?
            """,
            bindings: [.integer(nowMS), .integer(Int64(limit))]
        )
        var releasedCount = 0
        for row in rows {
            guard case let .text(reservationID)? = row.value(named: "reservation_id"),
                  RuntimeBlobQuotaReservationID(rawValue: reservationID) != nil,
                  case let .text(privacyRaw)? = row.value(named: "privacy_domain"),
                  RuntimeAttachmentPrivacyDomain(rawValue: privacyRaw) != nil,
                  case let .integer(reservedBytes)? = row.value(named: "reserved_bytes"),
                  reservedBytes > 0,
                  case let .text(ownerID)? = row.value(named: "owner_id"),
                  ownerID.isEmpty == false,
                  case let .integer(createdAtMS)? = row.value(named: "created_at_ms"),
                  case let .integer(expiresAtMS)? = row.value(named: "expires_at_ms"),
                  expiresAtMS >= createdAtMS, expiresAtMS <= nowMS else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            let ledgerRows = try database.query(
                """
                SELECT reserved_bytes, state_version FROM runtime_blob_quota_ledgers
                WHERE privacy_domain = ? AND owner_id = ? LIMIT 2
                """,
                bindings: [.text(privacyRaw), .text(ownerID)]
            )
            guard ledgerRows.count == 1,
                  case let .integer(ledgerReserved)? = ledgerRows[0].value(named: "reserved_bytes"),
                  ledgerReserved >= reservedBytes,
                  case let .integer(ledgerVersion)? = ledgerRows[0].value(named: "state_version"),
                  ledgerVersion > 0, ledgerVersion < Int64.max else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            let reservationChanged = try database.execute(
                """
                UPDATE runtime_blob_quota_reservations SET released_at_ms = ?
                WHERE reservation_id = ? AND privacy_domain = ? AND owner_id = ?
                  AND reserved_bytes = ? AND created_at_ms = ? AND expires_at_ms = ?
                  AND consumed_by_blob_id IS NULL AND released_at_ms IS NULL
                """,
                bindings: [
                    .integer(nowMS), .text(reservationID), .text(privacyRaw), .text(ownerID),
                    .integer(reservedBytes), .integer(createdAtMS), .integer(expiresAtMS),
                ]
            )
            guard reservationChanged == 1 else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            let ledgerChanged = try database.execute(
                """
                UPDATE runtime_blob_quota_ledgers
                SET reserved_bytes = ?, state_version = ?, updated_at_ms = ?
                WHERE privacy_domain = ? AND owner_id = ?
                  AND reserved_bytes = ? AND state_version = ?
                """,
                bindings: [
                    .integer(ledgerReserved - reservedBytes), .integer(ledgerVersion + 1),
                    .integer(nowMS), .text(privacyRaw), .text(ownerID),
                    .integer(ledgerReserved), .integer(ledgerVersion),
                ]
            )
            guard ledgerChanged == 1 else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            releasedCount += 1
        }
        return releasedCount
    }

    static func persistStage(
        _ bundle: RuntimeAttachmentStageBundle,
        reservationID: RuntimeBlobQuotaReservationID,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentStagePersistenceResult {
        try RuntimeAttachmentCodec.validate(bundle.revision)
        try RuntimeAttachmentCodec.validate(bundle.manifest)
        try RuntimeAttachmentCodec.validate(bundle.envelope)
        try RuntimeAttachmentCodec.validate(bundle.lifecycle)
        guard bundle.revision.blobID == bundle.manifest.blobID,
              bundle.envelope.blobID == bundle.manifest.blobID,
              bundle.lifecycle.blobID == bundle.manifest.blobID,
              bundle.lifecycle.state == .staged,
              bundle.lifecycle.stateVersion == 1,
              bundle.lifecycle.referenceCount == 0,
              bundle.revision.manifestDigest == bundle.lifecycle.manifestDigest,
              bundle.revision.manifestDigest == try RuntimeAttachmentCodec.digest(
                  bundle.manifest, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
              ),
              bundle.manifest.plaintextByteCount == bundle.revision.classification.byteCount,
              RuntimeAttachmentPrivacyDomain(bundle.revision.privacy) == bundle.manifest.privacyDomain else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let reservation = try database.query(
            """
            SELECT privacy_domain, reserved_bytes, owner_id, expires_at_ms,
                   consumed_by_blob_id, released_at_ms
            FROM runtime_blob_quota_reservations WHERE reservation_id = ? LIMIT 2
            """,
            bindings: [.text(reservationID.rawValue)]
        )
        guard reservation.count == 1,
              reservation[0].value(named: "privacy_domain") == .text(bundle.manifest.privacyDomain.rawValue),
              case let .integer(reservedBytes)? = reservation[0].value(named: "reserved_bytes"),
              reservedBytes >= bundle.manifest.plaintextByteCount,
              case let .text(quotaOwnerID)? = reservation[0].value(named: "owner_id"),
              case let .integer(expiresAt)? = reservation[0].value(named: "expires_at_ms"),
              case .null? = reservation[0].value(named: "released_at_ms") else {
            throw RuntimeCanonicalAttachmentError.reservationExpired
        }
        if case let .text(consumedRaw)? = reservation[0].value(named: "consumed_by_blob_id") {
            guard let consumedBlobID = RuntimeBlobID(rawValue: consumedRaw) else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            return try replayPersistedStage(
                bundle, reservationID: reservationID, consumedBlobID: consumedBlobID,
                quotaOwnerID: quotaOwnerID, database: database
            )
        }
        guard case .null? = reservation[0].value(named: "consumed_by_blob_id"),
              expiresAt > try milliseconds(now) else {
            throw RuntimeCanonicalAttachmentError.reservationExpired
        }
        let completedSourceRotations = try database.query(
            """
            SELECT job_id
            FROM runtime_blob_key_rewrap_jobs
            WHERE source_key_id = ? AND source_key_version = ? AND job_state = 'completed'
            LIMIT 1
            """,
            bindings: [
                .text(bundle.envelope.wrappingKeyID.rawValue),
                .integer(Int64(bundle.envelope.wrappingKeyVersion)),
            ]
        )
        guard completedSourceRotations.isEmpty else {
            throw RuntimeCanonicalAttachmentError.staleWrappingKey
        }

        let existingBlob: [SQLiteRow]
        if bundle.manifest.dedupPolicy == .withinPrivacyDomain {
            existingBlob = try database.query(
                """
                SELECT b.blob_id, b.manifest_digest, b.manifest_payload,
                       (SELECT MIN(v.revision_id) FROM runtime_attachment_revisions AS v
                        WHERE v.blob_id = b.blob_id) AS representative_revision_id
                FROM runtime_blob_dedup_authority AS a
                JOIN runtime_blob_records AS b ON b.blob_id = a.canonical_blob_id
                JOIN runtime_attachment_current_lifecycle AS s ON s.blob_id = b.blob_id
                WHERE a.privacy_domain = ? AND a.keyed_content_address = ?
                  AND a.manifest_version = ? AND a.protection_class = ?
                  AND b.dedup_policy = 'within_privacy_domain'
                  AND s.lifecycle_state IN ('staged','referenced','finalized')
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_blob_quarantine AS q
                      WHERE q.blob_id = b.blob_id AND q.resolved_at_ms IS NULL
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_blob_deletion_tombstones AS t WHERE t.blob_id = b.blob_id
                  )
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_blob_gc_leases AS g
                      WHERE g.blob_id = b.blob_id AND g.lease_state = 'active'
                        AND g.expires_at_ms > ?
                  )
                LIMIT 2
                """,
                bindings: [
                    .text(bundle.manifest.privacyDomain.rawValue),
                    .text(bundle.manifest.keyedContentAddress.rawValue),
                    .integer(Int64(bundle.manifest.formatVersion)),
                    .text(bundle.manifest.protectionClass.rawValue),
                    .integer(try milliseconds(now)),
                ]
            )
        } else {
            existingBlob = []
        }
        if existingBlob.isEmpty == false {
            guard existingBlob.count == 1,
                  case let .text(canonicalBlobRaw)? = existingBlob[0].value(named: "blob_id"),
                  let canonicalBlobID = RuntimeBlobID(rawValue: canonicalBlobRaw),
                  case let .text(canonicalManifestDigest)? = existingBlob[0].value(named: "manifest_digest"),
                  case let .blob(canonicalManifestBytes)? = existingBlob[0].value(named: "manifest_payload"),
                  RuntimeAttachmentCodec.sha256(canonicalManifestBytes) == canonicalManifestDigest,
                  case let .text(representativeRaw)? = existingBlob[0].value(named: "representative_revision_id"),
                  let representativeID = RuntimeAttachmentRevisionID(rawValue: representativeRaw),
                  let candidateGraph = try loadSnapshot(
                    revisionID: representativeID, database: database
                  ),
                  candidateGraph.tombstone == nil,
                  candidateGraph.lifecycle.state == .staged ||
                    candidateGraph.lifecycle.state == .referenced ||
                    candidateGraph.lifecycle.state == .finalized else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            let canonicalManifest = try RuntimeAttachmentCodec.decode(
                RuntimeBlobManifestAuthority.self, bytes: canonicalManifestBytes,
                maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            try RuntimeAttachmentCodec.validate(canonicalManifest)
            guard canonicalManifest.blobID == canonicalBlobID,
                  canonicalManifest.keyedContentAddress == bundle.manifest.keyedContentAddress,
                  canonicalManifest.privacyDomain == bundle.manifest.privacyDomain,
                  canonicalManifest.dedupPolicy == bundle.manifest.dedupPolicy,
                  canonicalManifest.plaintextByteCount == bundle.manifest.plaintextByteCount else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            // An unconsumed reservation proves this is a new physical stage, not replay of the
            // already persisted blob. Reusing its blob identity cannot be represented as a
            // distinct cleanup authority, so fail before accepting any revision or quota change.
            guard canonicalBlobID != bundle.manifest.blobID else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            let effectiveRevision = RuntimeAttachmentRevision(
                version: bundle.revision.version, revisionID: bundle.revision.revisionID,
                attachmentID: bundle.revision.attachmentID, revision: bundle.revision.revision,
                blobID: canonicalBlobID, manifestDigest: canonicalManifestDigest,
                classification: bundle.revision.classification, privacy: bundle.revision.privacy,
                provenance: bundle.revision.provenance, createdAt: bundle.revision.createdAt
            )
            try persistIdentityAndRevision(
                effectiveRevision, reservationID: reservationID, database: database
            )
            let losingManifestBytes = try RuntimeAttachmentCodec.encode(
                bundle.manifest, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            let losingEnvelopeBytes = try RuntimeAttachmentCodec.encode(
                bundle.envelope, maximumBytes: RuntimeAttachmentLimits.maximumEnvelopeBytes
            )
            let insertedOrphan = try database.execute(
                    """
                    INSERT INTO runtime_blob_staging_orphans(
                        losing_blob_id, canonical_blob_id, manifest_version, manifest_payload,
                        manifest_digest, envelope_version, envelope_payload, envelope_digest,
                        opaque_relative_directory, reason_code,
                        quota_owner_id, plaintext_byte_count,
                        recorded_at_ms, cleaned_at_ms, orphan_version
                    ) VALUES(?, ?, 1, ?, ?, 1, ?, ?, ?, 'dedup_collision', ?, ?, ?, NULL, 1)
                    ON CONFLICT(losing_blob_id) DO NOTHING
                    """,
                    bindings: [
                        .text(bundle.manifest.blobID.rawValue), .text(canonicalBlobID.rawValue),
                        .blob(losingManifestBytes), .text(RuntimeAttachmentCodec.sha256(losingManifestBytes)),
                        .blob(losingEnvelopeBytes), .text(bundle.envelope.envelopeDigest),
                        .text(bundle.manifest.opaqueRelativeDirectory), .text(quotaOwnerID),
                        .integer(bundle.manifest.plaintextByteCount),
                        .integer(try milliseconds(bundle.manifest.createdAt)),
                    ]
                )
            if insertedOrphan.changedRowCount == 0 {
                let existingOrphan = try database.query(
                        """
                        SELECT canonical_blob_id, manifest_payload, manifest_digest,
                               envelope_payload, envelope_digest, opaque_relative_directory,
                               reason_code, quota_owner_id, plaintext_byte_count,
                               recorded_at_ms, cleaned_at_ms
                        FROM runtime_blob_staging_orphans
                        WHERE losing_blob_id = ? LIMIT 2
                        """,
                        bindings: [.text(bundle.manifest.blobID.rawValue)]
                    )
                guard existingOrphan.count == 1,
                          existingOrphan[0].value(named: "canonical_blob_id") == .text(canonicalBlobID.rawValue),
                          existingOrphan[0].value(named: "manifest_payload") == .blob(losingManifestBytes),
                          existingOrphan[0].value(named: "manifest_digest") == .text(
                              RuntimeAttachmentCodec.sha256(losingManifestBytes)
                          ),
                          existingOrphan[0].value(named: "envelope_payload") == .blob(losingEnvelopeBytes),
                          existingOrphan[0].value(named: "envelope_digest") == .text(bundle.envelope.envelopeDigest),
                          existingOrphan[0].value(named: "opaque_relative_directory") == .text(
                              bundle.manifest.opaqueRelativeDirectory
                          ),
                          existingOrphan[0].value(named: "reason_code") == .text("dedup_collision"),
                          existingOrphan[0].value(named: "quota_owner_id") == .text(quotaOwnerID),
                          existingOrphan[0].value(named: "plaintext_byte_count") == .integer(
                              bundle.manifest.plaintextByteCount
                          ),
                          existingOrphan[0].value(named: "recorded_at_ms") == .integer(
                              try milliseconds(bundle.manifest.createdAt)
                          ),
                          existingOrphan[0].value(named: "cleaned_at_ms") == .null else {
                    throw RuntimeCanonicalAttachmentError.lifecycleConflict
                }
            }
            try consumeReservation(
                reservationID, blobID: canonicalBlobID, storedBytes: 0,
                orphanBytes: bundle.manifest.plaintextByteCount,
                now: now, database: database
            )
            return .deduplicated(
                effectiveRevision: effectiveRevision, canonicalBlobID: canonicalBlobID,
                losingManifest: bundle.manifest, cleanup: .pending
            )
        }

        let manifestBytes = try RuntimeAttachmentCodec.encode(
            bundle.manifest, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let revisionBytes = try RuntimeAttachmentCodec.encode(
            bundle.revision, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let revisionDigest = RuntimeAttachmentCodec.sha256(revisionBytes)
        let envelopeBytes = try RuntimeAttachmentCodec.encode(
            bundle.envelope, maximumBytes: RuntimeAttachmentLimits.maximumEnvelopeBytes
        )
        let lifecycleBytes = try RuntimeAttachmentCodec.encode(
            bundle.lifecycle, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let lifecycleDigest = RuntimeAttachmentCodec.sha256(lifecycleBytes)
        let createdAt = try milliseconds(bundle.revision.createdAt)

        let retentionBinding: SQLiteValue = if let retentionUntil = bundle.lifecycle.retentionUntil {
            .integer(try milliseconds(retentionUntil))
        } else {
            .null
        }
        try database.execute(
            """
            INSERT INTO runtime_blob_records(
                blob_id, privacy_domain, quota_owner_id, dedup_policy, keyed_content_address,
                manifest_version, manifest_payload, manifest_digest,
                plaintext_byte_count, ciphertext_byte_count, protection_class,
                opaque_relative_directory, created_at_ms
            ) VALUES(?, ?, ?, ?, ?, 1, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(bundle.manifest.blobID.rawValue), .text(bundle.manifest.privacyDomain.rawValue),
                .text(quotaOwnerID), .text(bundle.manifest.dedupPolicy.rawValue),
                .text(bundle.manifest.keyedContentAddress.rawValue),
                .blob(manifestBytes), .text(bundle.revision.manifestDigest),
                .integer(bundle.manifest.plaintextByteCount), .integer(bundle.manifest.ciphertextByteCount),
                .text(bundle.manifest.protectionClass.rawValue), .text(bundle.manifest.opaqueRelativeDirectory),
                .integer(try milliseconds(bundle.manifest.createdAt)),
            ]
        )
        if bundle.manifest.dedupPolicy == .withinPrivacyDomain {
            try database.execute(
                """
                INSERT INTO runtime_blob_dedup_authority(
                    privacy_domain, keyed_content_address, manifest_version,
                    protection_class, canonical_blob_id, authority_version, created_at_ms
                ) VALUES(?, ?, ?, ?, ?, 1, ?)
                """,
                bindings: [
                    .text(bundle.manifest.privacyDomain.rawValue),
                    .text(bundle.manifest.keyedContentAddress.rawValue),
                    .integer(Int64(bundle.manifest.formatVersion)),
                    .text(bundle.manifest.protectionClass.rawValue),
                    .text(bundle.manifest.blobID.rawValue),
                    .integer(try milliseconds(now)),
                ]
            )
        }
        try persistIdentityAndRevision(
            bundle.revision, reservationID: reservationID,
            encodedRevision: revisionBytes, revisionDigest: revisionDigest,
            database: database
        )
        try database.execute(
            """
            INSERT INTO runtime_blob_key_envelopes(
                blob_id, wrapping_key_id, wrapping_key_version, envelope_version,
                algorithm, envelope_payload, envelope_digest, created_at_ms
            ) VALUES(?, ?, ?, 1, ?, ?, ?, ?)
            """,
            bindings: [
                .text(bundle.envelope.blobID.rawValue), .text(bundle.envelope.wrappingKeyID.rawValue),
                .integer(Int64(bundle.envelope.wrappingKeyVersion)), .text(bundle.envelope.algorithm),
                .blob(envelopeBytes), .text(bundle.envelope.envelopeDigest), .integer(createdAt),
            ]
        )
        let initialHistory = try makeHistory(
            blobID: bundle.manifest.blobID, version: 1, from: nil, to: .staged,
            fromCount: nil, toCount: 0, commandID: nil, receiptID: nil,
            lineage: nil, at: bundle.lifecycle.updatedAt
        )
        try insertHistory(initialHistory, database: database)
        try database.execute(
            """
            INSERT INTO runtime_attachment_current_lifecycle(
                blob_id, lifecycle_state, state_version, reference_count, manifest_digest,
                retention_until_ms, quarantine_reason, lifecycle_version,
                lifecycle_payload, lifecycle_digest, updated_at_ms
            ) VALUES(?, 'staged', 1, 0, ?, ?, NULL, 1, ?, ?, ?)
            """,
            bindings: [
                .text(bundle.lifecycle.blobID.rawValue), .text(bundle.lifecycle.manifestDigest),
                retentionBinding,
                .blob(lifecycleBytes), .text(lifecycleDigest), .integer(try milliseconds(bundle.lifecycle.updatedAt)),
            ]
        )
        try consumeReservation(
            reservationID, blobID: bundle.manifest.blobID,
            storedBytes: bundle.manifest.plaintextByteCount, orphanBytes: 0,
            now: now, database: database
        )
        return .inserted(bundle.revision)
    }

    private static func replayPersistedStage(
        _ bundle: RuntimeAttachmentStageBundle,
        reservationID: RuntimeBlobQuotaReservationID,
        consumedBlobID: RuntimeBlobID,
        quotaOwnerID: String,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentStagePersistenceResult {
        let links = try database.query(
            """
            SELECT blob_id, manifest_digest
            FROM runtime_attachment_revisions
            WHERE revision_id = ? AND quota_reservation_id = ? LIMIT 2
            """,
            bindings: [
                .text(bundle.revision.revisionID.rawValue), .text(reservationID.rawValue),
            ]
        )
        guard links.count == 1,
              links[0].value(named: "blob_id") == .text(consumedBlobID.rawValue),
              case let .text(effectiveManifestDigest)? = links[0].value(named: "manifest_digest"),
              let graph = try loadSnapshot(
                revisionID: bundle.revision.revisionID, database: database
              ),
              graph.revision.blobID == consumedBlobID,
              graph.revision.manifestDigest == effectiveManifestDigest,
              graph.revision.attachmentID == bundle.revision.attachmentID,
              graph.revision.revision == bundle.revision.revision,
              graph.revision.classification == bundle.revision.classification,
              graph.revision.privacy == bundle.revision.privacy,
              graph.revision.provenance == bundle.revision.provenance,
              graph.revision.createdAt == bundle.revision.createdAt,
              graph.manifest.blobID == consumedBlobID,
              graph.lifecycle.blobID == consumedBlobID,
              graph.lifecycle.manifestDigest == effectiveManifestDigest else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        if consumedBlobID == bundle.manifest.blobID {
            guard graph.revision == bundle.revision,
                  graph.manifest == bundle.manifest,
                  graph.envelope == bundle.envelope else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            return .inserted(graph.revision)
        }
        guard bundle.manifest.dedupPolicy == .withinPrivacyDomain,
              graph.manifest.dedupPolicy == .withinPrivacyDomain,
              graph.manifest.keyedContentAddress == bundle.manifest.keyedContentAddress,
              graph.manifest.privacyDomain == bundle.manifest.privacyDomain,
              graph.manifest.plaintextByteCount == bundle.manifest.plaintextByteCount else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let orphanRows = try database.query(
            """
            SELECT manifest_payload, manifest_digest, envelope_payload, envelope_digest,
                   quota_owner_id, cleaned_at_ms
            FROM runtime_blob_staging_orphans
            WHERE losing_blob_id = ? AND canonical_blob_id = ? LIMIT 2
            """,
            bindings: [
                .text(bundle.manifest.blobID.rawValue), .text(consumedBlobID.rawValue),
            ]
        )
        guard orphanRows.count == 1,
              case let .blob(manifestBytes)? = orphanRows[0].value(named: "manifest_payload"),
              case let .text(manifestDigest)? = orphanRows[0].value(named: "manifest_digest"),
              RuntimeAttachmentCodec.sha256(manifestBytes) == manifestDigest,
              case let .blob(envelopeBytes)? = orphanRows[0].value(named: "envelope_payload"),
              case let .text(envelopeDigest)? = orphanRows[0].value(named: "envelope_digest"),
              orphanRows[0].value(named: "quota_owner_id") == .text(quotaOwnerID) else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let orphanManifest = try RuntimeAttachmentCodec.decode(
            RuntimeBlobManifestAuthority.self, bytes: manifestBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let orphanEnvelope = try RuntimeAttachmentCodec.decode(
            RuntimeBlobKeyEnvelope.self, bytes: envelopeBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumEnvelopeBytes
        )
        try RuntimeAttachmentCodec.validate(orphanManifest)
        try RuntimeAttachmentCodec.validate(orphanEnvelope)
        guard orphanManifest == bundle.manifest,
              orphanEnvelope == bundle.envelope,
              orphanEnvelope.envelopeDigest == envelopeDigest else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let cleanup: RuntimeAttachmentDedupCleanupState
        switch orphanRows[0].value(named: "cleaned_at_ms") {
        case .integer(_)?: cleanup = .completed
        case .null?: cleanup = .pending
        default: throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return .deduplicated(
            effectiveRevision: graph.revision, canonicalBlobID: consumedBlobID,
            losingManifest: bundle.manifest, cleanup: cleanup
        )
    }

    private static func persistIdentityAndRevision(
        _ revision: RuntimeAttachmentRevision,
        reservationID: RuntimeBlobQuotaReservationID,
        encodedRevision: Data? = nil,
        revisionDigest: String? = nil,
        database: isolated SQLiteDatabase
    ) throws {
        _ = try RuntimeAttachmentCodec.sqliteInteger(revision.revision)
        let createdAt = try milliseconds(revision.createdAt)
        try database.execute(
            """
            INSERT INTO runtime_attachment_identities(
                attachment_id, privacy, local_only, identity_version, created_at_ms
            ) VALUES(?, ?, 1, 1, ?)
            ON CONFLICT(attachment_id) DO NOTHING
            """,
            bindings: [
                .text(revision.attachmentID.rawValue), .text(revision.privacy.rawValue), .integer(createdAt),
            ]
        )
        let identity = try database.query(
            "SELECT privacy, local_only FROM runtime_attachment_identities WHERE attachment_id = ? LIMIT 2",
            bindings: [.text(revision.attachmentID.rawValue)]
        )
        guard identity.count == 1,
              identity[0].value(named: "privacy") == .text(revision.privacy.rawValue),
              identity[0].value(named: "local_only") == .integer(1) else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let bytes: Data
        if let encodedRevision { bytes = encodedRevision }
        else {
            bytes = try RuntimeAttachmentCodec.encode(
                revision, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
        }
        let digest = revisionDigest ?? RuntimeAttachmentCodec.sha256(bytes)
        let existing = try database.query(
            "SELECT content_digest, quota_reservation_id FROM runtime_attachment_revisions WHERE revision_id = ? LIMIT 2",
            bindings: [.text(revision.revisionID.rawValue)]
        )
        if existing.isEmpty == false {
            guard existing.count == 1,
                  existing[0].value(named: "content_digest") == .text(digest),
                  existing[0].value(named: "quota_reservation_id") == .text(reservationID.rawValue) else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            return
        }
        try database.execute(
            """
            INSERT INTO runtime_attachment_revisions(
                revision_id, attachment_id, attachment_revision, quota_reservation_id,
                blob_id, manifest_digest,
                content_version, content_payload, content_digest, created_at_ms
            ) VALUES(?, ?, ?, ?, ?, ?, 1, ?, ?, ?)
            """,
            bindings: [
                .text(revision.revisionID.rawValue), .text(revision.attachmentID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(revision.revision)), .text(reservationID.rawValue),
                .text(revision.blobID.rawValue),
                .text(revision.manifestDigest), .blob(bytes), .text(digest), .integer(createdAt),
            ]
        )
    }

    private static func consumeReservation(
        _ reservationID: RuntimeBlobQuotaReservationID,
        blobID: RuntimeBlobID,
        storedBytes: Int64,
        orphanBytes: Int64,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws {
        let reservation = try database.query(
            """
            SELECT privacy_domain, owner_id, reserved_bytes
            FROM runtime_blob_quota_reservations
            WHERE reservation_id = ? AND consumed_by_blob_id IS NULL AND released_at_ms IS NULL
              AND expires_at_ms > ? LIMIT 2
            """,
            bindings: [
                .text(reservationID.rawValue), .integer(try milliseconds(now)),
            ]
        )
        guard reservation.count == 1,
              case let .text(privacyRaw)? = reservation[0].value(named: "privacy_domain"),
              case let .text(ownerID)? = reservation[0].value(named: "owner_id"),
              case let .integer(reservedBytes)? = reservation[0].value(named: "reserved_bytes"),
              storedBytes >= 0, orphanBytes >= 0,
              storedBytes + orphanBytes <= reservedBytes else {
            throw RuntimeCanonicalAttachmentError.reservationExpired
        }
        let consumed = try database.execute(
            """
            UPDATE runtime_blob_quota_reservations SET consumed_by_blob_id = ?
            WHERE reservation_id = ? AND consumed_by_blob_id IS NULL AND released_at_ms IS NULL
              AND expires_at_ms > ?
            """,
            bindings: [
                .text(blobID.rawValue), .text(reservationID.rawValue), .integer(try milliseconds(now)),
            ]
        )
        guard consumed == 1 else { throw RuntimeCanonicalAttachmentError.reservationExpired }
        let ledger = try database.execute(
            """
            UPDATE runtime_blob_quota_ledgers
            SET reserved_bytes = reserved_bytes - ?, stored_bytes = stored_bytes + ?,
                orphan_bytes = orphan_bytes + ?, state_version = state_version + 1,
                updated_at_ms = ?
            WHERE privacy_domain = ? AND owner_id = ? AND reserved_bytes >= ?
              AND stored_bytes + orphan_bytes + ? + ? <= limit_bytes
              AND state_version < 9223372036854775807
            """,
            bindings: [
                .integer(reservedBytes), .integer(storedBytes), .integer(orphanBytes),
                .integer(try milliseconds(now)), .text(privacyRaw), .text(ownerID),
                .integer(reservedBytes), .integer(storedBytes), .integer(orphanBytes),
            ]
        )
        guard ledger == 1 else { throw RuntimeCanonicalAttachmentError.quotaExceeded }
    }

    private static func markStagingOrphanCleaned(
        blobID: RuntimeBlobID,
        manifestDigest: String,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws {
        let authority = try database.query(
            """
            SELECT o.quota_owner_id, o.plaintext_byte_count, b.privacy_domain
            FROM runtime_blob_staging_orphans AS o
            JOIN runtime_blob_records AS b ON b.blob_id = o.canonical_blob_id
            WHERE o.losing_blob_id = ? AND o.manifest_digest = ?
              AND o.cleaned_at_ms IS NULL LIMIT 2
            """,
            bindings: [.text(blobID.rawValue), .text(manifestDigest)]
        )
        guard authority.count == 1,
              case let .text(ownerID)? = authority[0].value(named: "quota_owner_id"),
              case let .integer(byteCount)? = authority[0].value(named: "plaintext_byte_count"),
              case let .text(privacyRaw)? = authority[0].value(named: "privacy_domain") else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let changed = try database.execute(
            """
            UPDATE runtime_blob_staging_orphans SET cleaned_at_ms = ?
            WHERE losing_blob_id = ? AND manifest_digest = ? AND cleaned_at_ms IS NULL
            """,
            bindings: [
                .integer(try milliseconds(now)), .text(blobID.rawValue), .text(manifestDigest),
            ]
        )
        guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        let ledger = try database.execute(
            """
            UPDATE runtime_blob_quota_ledgers
            SET orphan_bytes = orphan_bytes - ?, state_version = state_version + 1,
                updated_at_ms = ?
            WHERE privacy_domain = ? AND owner_id = ? AND orphan_bytes >= ?
              AND state_version < 9223372036854775807
            """,
            bindings: [
                .integer(byteCount), .integer(try milliseconds(now)),
                .text(privacyRaw), .text(ownerID), .integer(byteCount),
            ]
        )
        guard ledger == 1 else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
    }

    static func confirmDedupCandidate(
        revisionID: RuntimeAttachmentRevisionID,
        canonicalBlobID: RuntimeBlobID,
        keyedContentAddress: RuntimeAttachmentContentAddress,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentAuthoritySnapshot {
        guard let graph = try loadSnapshot(revisionID: revisionID, database: database),
              graph.manifest.blobID == canonicalBlobID,
              graph.manifest.keyedContentAddress == keyedContentAddress,
              graph.manifest.dedupPolicy == .withinPrivacyDomain,
              graph.tombstone == nil,
              graph.lifecycle.state == .staged ||
                graph.lifecycle.state == .referenced ||
                graph.lifecycle.state == .finalized,
              try hasUnresolvedQuarantine(blobID: canonicalBlobID, database: database) == false else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let mapping = try database.query(
            """
            SELECT 1 AS present FROM runtime_blob_dedup_authority
            WHERE privacy_domain = ? AND keyed_content_address = ?
              AND manifest_version = ? AND protection_class = ?
              AND canonical_blob_id = ? LIMIT 2
            """,
            bindings: [
                .text(graph.manifest.privacyDomain.rawValue),
                .text(keyedContentAddress.rawValue),
                .integer(Int64(graph.manifest.formatVersion)),
                .text(graph.manifest.protectionClass.rawValue),
                .text(canonicalBlobID.rawValue),
            ]
        )
        let lease = try database.query(
            """
            SELECT 1 AS present FROM runtime_blob_gc_leases
            WHERE blob_id = ? AND lease_state = 'active' AND expires_at_ms > ? LIMIT 1
            """,
            bindings: [
                .text(canonicalBlobID.rawValue), .integer(try milliseconds(now)),
            ]
        )
        guard mapping.count == 1, lease.isEmpty else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        return graph
    }

    static func dueStagingOrphans(
        limit: Int,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeBlobStagingOrphan] {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let rows = try database.query(
            """
            SELECT losing_blob_id, canonical_blob_id, manifest_payload, manifest_digest, recorded_at_ms
            FROM runtime_blob_staging_orphans AS o
            LEFT JOIN runtime_attachment_recovery_attempts AS a
              ON a.work_kind = 'staging_orphan' AND a.authority_id = o.losing_blob_id
            WHERE o.cleaned_at_ms IS NULL
              AND (a.authority_id IS NULL OR (
                  a.resolved_at_ms IS NULL AND a.attempt_count < ? AND a.next_retry_at_ms <= ?
              ))
            ORDER BY o.recorded_at_ms, o.losing_blob_id LIMIT ?
            """,
            bindings: [
                .integer(Int64(RuntimeAttachmentLimits.maximumRecoveryAttempts)),
                .integer(try milliseconds(now)), .integer(Int64(limit)),
            ]
        )
        return try rows.map { row in
            guard case let .text(losingRaw)? = row.value(named: "losing_blob_id"),
                  let losingBlobID = RuntimeBlobID(rawValue: losingRaw),
                  case let .text(canonicalRaw)? = row.value(named: "canonical_blob_id"),
                  let canonicalBlobID = RuntimeBlobID(rawValue: canonicalRaw),
                  case let .blob(manifestBytes)? = row.value(named: "manifest_payload"),
                  case let .text(manifestDigest)? = row.value(named: "manifest_digest"),
                  RuntimeAttachmentCodec.sha256(manifestBytes) == manifestDigest,
                  case let .integer(recordedAt)? = row.value(named: "recorded_at_ms") else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            let manifest = try RuntimeAttachmentCodec.decode(
                RuntimeBlobManifestAuthority.self, bytes: manifestBytes,
                maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            guard manifest.blobID == losingBlobID else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            return RuntimeBlobStagingOrphan(
                version: runtimeCanonicalAttachmentModelVersion, losingBlobID: losingBlobID,
                canonicalBlobID: canonicalBlobID, manifest: manifest,
                reasonCode: "dedup_collision",
                recordedAt: Date(timeIntervalSince1970: Double(recordedAt) / 1_000), cleanedAt: nil
            )
        }
    }

    static func dueFinalizations(
        limit: Int,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeBlobFinalizationWork] {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let rows = try database.query(
            """
            SELECT (
                       SELECT MIN(l.revision_id) FROM runtime_attachment_receipt_links AS l
                       WHERE l.receipt_id = i.receipt_id AND l.blob_id = i.blob_id
                         AND l.link_kind = 'reference'
                   ) AS revision_id,
                   b.manifest_payload, i.manifest_digest,
                   i.command_id, i.receipt_id, i.terminal_event_sequence,
                   i.expected_state_version, i.intent_digest, i.created_at_ms, e.event_id, e.event_hash
            FROM runtime_blob_finalization_intents AS i
            JOIN runtime_blob_records AS b ON b.blob_id = i.blob_id
            JOIN runtime_attachment_current_lifecycle AS s ON s.blob_id = i.blob_id
            JOIN runtime_semantic_events AS e ON e.sequence = i.terminal_event_sequence
            LEFT JOIN runtime_attachment_recovery_attempts AS a
              ON a.work_kind = 'finalization' AND a.authority_id = i.blob_id
            WHERE i.finalized_at_ms IS NULL AND s.lifecycle_state = 'referenced'
              AND s.state_version >= i.expected_state_version
              AND (a.authority_id IS NULL OR (
                  a.resolved_at_ms IS NULL AND a.attempt_count < ? AND a.next_retry_at_ms <= ?
              ))
            ORDER BY i.created_at_ms, i.blob_id LIMIT ?
            """,
            bindings: [
                .integer(Int64(RuntimeAttachmentLimits.maximumRecoveryAttempts)),
                .integer(try milliseconds(now)), .integer(Int64(limit)),
            ]
        )
        return try rows.map { row in
            guard case let .text(revisionRaw)? = row.value(named: "revision_id"),
                  let revisionID = RuntimeAttachmentRevisionID(rawValue: revisionRaw),
                  case let .blob(manifestBytes)? = row.value(named: "manifest_payload"),
                  case let .text(manifestDigest)? = row.value(named: "manifest_digest"),
                  RuntimeAttachmentCodec.sha256(manifestBytes) == manifestDigest,
                  case let .text(commandRaw)? = row.value(named: "command_id"),
                  let commandID = RuntimeCommandID(rawValue: commandRaw),
                  case let .text(receiptRaw)? = row.value(named: "receipt_id"),
                  let receiptID = RuntimeReceiptID(rawValue: receiptRaw),
                  case let .integer(sequence)? = row.value(named: "terminal_event_sequence"), sequence > 0,
                  case let .integer(expectedVersion)? = row.value(named: "expected_state_version"), expectedVersion > 0,
                  case let .text(intentDigest)? = row.value(named: "intent_digest"),
                  case let .integer(createdAt)? = row.value(named: "created_at_ms"),
                  case let .text(eventRaw)? = row.value(named: "event_id"),
                  let eventID = RuntimeEventID(rawValue: eventRaw),
                  case let .text(eventHash)? = row.value(named: "event_hash"),
                  RuntimeStoreManifestCodec.isSHA256Hex(eventHash) else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            let manifest = try RuntimeAttachmentCodec.decode(
                RuntimeBlobManifestAuthority.self, bytes: manifestBytes,
                maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            let lineage = RuntimeAuthorityLineageReference(
                eventID: eventID, eventSequence: UInt64(sequence), eventHash: eventHash
            )
            let evidence = RuntimeAttachmentFinalizationIntentEvidence(
                version: runtimeCanonicalAttachmentModelVersion, blobID: manifest.blobID,
                manifestDigest: manifestDigest, commandID: commandID, receiptID: receiptID,
                lineage: lineage, expectedStateVersion: UInt64(expectedVersion),
                createdAt: Date(timeIntervalSince1970: Double(createdAt) / 1_000)
            )
            guard try RuntimeAttachmentCodec.digest(
                evidence, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            ) == intentDigest else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            return RuntimeBlobFinalizationWork(
                revisionID: revisionID, manifest: manifest, manifestDigest: manifestDigest,
                commandID: commandID, receiptID: receiptID,
                lineage: lineage,
                expectedStateVersion: UInt64(expectedVersion),
                createdAt: Date(timeIntervalSince1970: Double(createdAt) / 1_000)
            )
        }
    }

    static func completeFinalization(
        _ work: RuntimeBlobFinalizationWork,
        proof: RuntimeAttachmentFinalizationProof,
        database: isolated SQLiteDatabase
    ) throws {
        _ = try RuntimeAttachmentCodec.sqliteInteger(work.lineage.eventSequence)
        _ = try RuntimeAttachmentCodec.sqliteInteger(work.expectedStateVersion)
        let now = proof.finalizedAt
        guard RuntimeStoreManifestCodec.isSHA256Hex(proof.markerDigest),
              RuntimeStoreManifestCodec.isSHA256Hex(proof.proofDigest),
              proof.blobID == work.manifest.blobID,
              proof.manifestDigest == work.manifestDigest,
              proof.receiptID == work.receiptID,
              proof.terminalEventSequence == work.lineage.eventSequence,
              try RuntimeAttachmentCodec.finalizationProofDigest(proof) == proof.proofDigest,
              let graph = try loadSnapshot(revisionID: work.revisionID, database: database),
              graph.manifest == work.manifest,
              graph.revision.manifestDigest == work.manifestDigest,
              graph.lifecycle.state == .referenced,
              graph.lifecycle.stateVersion >= work.expectedStateVersion else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let intentRows = try database.query(
            """
            SELECT 1 AS present FROM runtime_blob_finalization_intents
            WHERE blob_id = ? AND manifest_digest = ? AND command_id = ? AND receipt_id = ?
              AND terminal_event_sequence = ? AND expected_state_version = ?
              AND marker_digest IS NULL AND finalized_at_ms IS NULL LIMIT 2
            """,
            bindings: [
                .text(work.manifest.blobID.rawValue), .text(work.manifestDigest),
                .text(work.commandID.rawValue), .text(work.receiptID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(work.lineage.eventSequence)),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(work.expectedStateVersion)),
            ]
        )
        guard intentRows.count == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        let nextVersion = try RuntimeAttachmentCodec.nextSQLiteVersion(
            after: graph.lifecycle.stateVersion
        )
        let history = try makeHistory(
            blobID: graph.manifest.blobID, version: nextVersion,
            from: .referenced, to: .finalized,
            fromCount: graph.lifecycle.referenceCount, toCount: graph.lifecycle.referenceCount,
            commandID: work.commandID, receiptID: work.receiptID,
            lineage: work.lineage, at: now
        )
        try insertHistory(
            history, finalizationCompletionID: proof.proofDigest, database: database
        )
        let next = RuntimeAttachmentCurrentLifecycle(
            version: runtimeCanonicalAttachmentModelVersion, blobID: graph.manifest.blobID,
            state: .finalized, stateVersion: nextVersion,
            referenceCount: graph.lifecycle.referenceCount,
            manifestDigest: graph.lifecycle.manifestDigest,
            retentionUntil: graph.lifecycle.retentionUntil,
            quarantineReasonCode: nil, updatedAt: now
        )
        let bytes = try RuntimeAttachmentCodec.encode(
            next, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let changed = try database.execute(
            """
            UPDATE runtime_attachment_current_lifecycle SET lifecycle_state = 'finalized',
                state_version = ?, lifecycle_payload = ?, lifecycle_digest = ?, updated_at_ms = ?
            WHERE blob_id = ? AND state_version = ? AND lifecycle_state = 'referenced'
              AND lifecycle_digest = ?
            """,
            bindings: [
                .integer(try RuntimeAttachmentCodec.sqliteInteger(nextVersion)), .blob(bytes), .text(RuntimeAttachmentCodec.sha256(bytes)),
                .integer(try milliseconds(now)), .text(graph.manifest.blobID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(graph.lifecycle.stateVersion)),
                .text(try RuntimeAttachmentCodec.digest(
                    graph.lifecycle, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
                )),
            ]
        )
        guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        let finalized = try database.execute(
            """
            UPDATE runtime_blob_finalization_intents
            SET marker_digest = ?, finalized_at_ms = ?, finalization_completion_id = ?
            WHERE blob_id = ? AND marker_digest IS NULL AND finalized_at_ms IS NULL
            """,
            bindings: [
                .text(proof.markerDigest), .integer(try milliseconds(now)),
                .text(proof.proofDigest), .text(graph.manifest.blobID.rawValue),
            ]
        )
        guard finalized == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        let marker = RuntimeAttachmentFinalizationMarker(
            version: runtimeCanonicalAttachmentModelVersion, blobID: work.manifest.blobID,
            manifestDigest: work.manifestDigest, receiptID: work.receiptID,
            terminalEventSequence: work.lineage.eventSequence, finalizedAt: now
        )
        let markerBytes = try RuntimeAttachmentCodec.encode(
            marker, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        guard RuntimeAttachmentCodec.sha256(markerBytes) == proof.markerDigest else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        try database.execute(
            """
            INSERT INTO runtime_attachment_receipt_links(
                receipt_id, revision_id, blob_id, manifest_digest, link_kind,
                artifact_payload, artifact_digest, finalization_completion_id, link_version
            ) VALUES(?, ?, ?, ?, 'finalization', ?, ?, ?, 1)
            """,
            bindings: [
                .text(work.receiptID.rawValue), .text(work.revisionID.rawValue),
                .text(graph.manifest.blobID.rawValue), .text(work.manifestDigest),
                .blob(markerBytes), .text(proof.markerDigest), .text(proof.proofDigest),
            ]
        )
        try database.execute(
            """
            INSERT INTO runtime_blob_finalization_completions(
                completion_id, blob_id, revision_id, manifest_digest, command_id,
                receipt_id, terminal_event_sequence, final_state_version,
                marker_digest, finalized_at_ms, completion_version
            ) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
            """,
            bindings: [
                .text(proof.proofDigest), .text(work.manifest.blobID.rawValue),
                .text(work.revisionID.rawValue), .text(work.manifestDigest),
                .text(work.commandID.rawValue), .text(work.receiptID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(work.lineage.eventSequence)),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(nextVersion)),
                .text(proof.markerDigest), .integer(try milliseconds(now)),
            ]
        )
    }

    static func authenticatedReceiptArtifacts(
        receiptID: RuntimeReceiptID,
        budget: inout RuntimeReceiptDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeCommittedReceiptArtifactLink] {
        let rows = try budget.query(
            """
            SELECT revision_id, blob_id, manifest_digest, link_kind,
                   artifact_payload, artifact_digest
            FROM runtime_attachment_receipt_links
            WHERE receipt_id = ? AND link_kind <> 'finalization'
            ORDER BY revision_id, link_kind
            LIMIT ?
            """,
            bindings: [
                .text(receiptID.rawValue), .integer(Int64(RuntimeAttachmentLimits.maximumReferences + 1)),
            ],
            database: database
        )
        guard rows.count <= RuntimeAttachmentLimits.maximumReferences else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let revisionRows = try budget.query(
            """
            SELECT DISTINCT v.revision_id, v.blob_id, v.manifest_digest
            FROM runtime_attachment_receipt_links AS a
            JOIN runtime_attachment_revisions AS v
              ON v.revision_id = a.revision_id AND v.blob_id = a.blob_id
             AND v.manifest_digest = a.manifest_digest
            WHERE a.receipt_id = ? AND a.link_kind <> 'finalization'
            LIMIT ?
            """,
            bindings: [
                .text(receiptID.rawValue),
                .integer(Int64(RuntimeAttachmentLimits.maximumReferences + 1)),
            ],
            database: database
        )
        let lifecycleRows = try budget.query(
            """
            SELECT blob_id, history_digest FROM runtime_attachment_lifecycle_history
            WHERE receipt_id = ? ORDER BY blob_id, state_version LIMIT ?
            """,
            bindings: [
                .text(receiptID.rawValue),
                .integer(Int64(RuntimeAttachmentLimits.maximumReferences + 1)),
            ],
            database: database
        )
        let referenceRows = try budget.query(
            """
            SELECT revision_id, blob_id, history_digest
            FROM runtime_attachment_reference_history
            WHERE receipt_id = ? ORDER BY revision_id, blob_id, history_digest LIMIT ?
            """,
            bindings: [
                .text(receiptID.rawValue),
                .integer(Int64(RuntimeAttachmentLimits.maximumReferences * 2 + 1)),
            ],
            database: database
        )
        let finalizationRows = try budget.query(
            """
            SELECT i.blob_id, i.manifest_digest, i.command_id, i.terminal_event_sequence,
                   i.expected_state_version, i.intent_digest, i.created_at_ms,
                   e.event_id, e.event_hash
            FROM runtime_blob_finalization_intents AS i
            JOIN runtime_semantic_events AS e ON e.sequence = i.terminal_event_sequence
            WHERE i.receipt_id = ? ORDER BY i.blob_id LIMIT ?
            """,
            bindings: [
                .text(receiptID.rawValue),
                .integer(Int64(RuntimeAttachmentLimits.maximumReferences + 1)),
            ],
            database: database
        )
        guard revisionRows.count <= RuntimeAttachmentLimits.maximumReferences,
              lifecycleRows.count <= RuntimeAttachmentLimits.maximumReferences,
              referenceRows.count <= RuntimeAttachmentLimits.maximumReferences * 2,
              finalizationRows.count <= RuntimeAttachmentLimits.maximumReferences else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let revisionAuthority = Set(try revisionRows.map { row in
            try authorityKey(row, fields: ["revision_id", "blob_id", "manifest_digest"])
        })
        let lifecycleAuthority = Set(try lifecycleRows.map { row in
            try authorityKey(row, fields: ["blob_id", "history_digest"])
        })
        let referenceAuthority = Set(try referenceRows.map { row in
            try authorityKey(row, fields: ["revision_id", "blob_id", "history_digest"])
        })
        return try rows.map { row in
            guard case let .text(revisionRaw)? = row.value(named: "revision_id"),
                  let revisionID = RuntimeAttachmentRevisionID(rawValue: revisionRaw),
                  case let .text(blobRaw)? = row.value(named: "blob_id"),
                  let blobID = RuntimeBlobID(rawValue: blobRaw),
                  case let .text(manifestDigest)? = row.value(named: "manifest_digest"),
                  case let .text(linkKind)? = row.value(named: "link_kind"),
                  case let .blob(payload)? = row.value(named: "artifact_payload"),
                  case let .text(digest)? = row.value(named: "artifact_digest"),
                  RuntimeAttachmentCodec.sha256(payload) == digest else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            if linkKind == "finalization_intent" {
                let evidence = try RuntimeAttachmentCodec.decode(
                    RuntimeAttachmentFinalizationIntentEvidence.self, bytes: payload,
                    maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
                )
                guard evidence.receiptID == receiptID, evidence.blobID == blobID,
                      evidence.lineage.eventSequence <= RuntimeAttachmentCodec.maximumSQLiteInteger,
                      evidence.expectedStateVersion <= RuntimeAttachmentCodec.maximumSQLiteInteger,
                      evidence.manifestDigest == manifestDigest,
                      try RuntimeAttachmentCodec.digest(
                          evidence, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
                      ) == digest else {
                    throw RuntimeCanonicalAttachmentError.corruptAuthority
                }
                let evidenceCreatedAtMS = try milliseconds(evidence.createdAt)
                let evidenceSequence = try RuntimeAttachmentCodec.sqliteInteger(
                    evidence.lineage.eventSequence
                )
                let evidenceStateVersion = try RuntimeAttachmentCodec.sqliteInteger(
                    evidence.expectedStateVersion
                )
                let authorityMatches = finalizationRows.filter { authority in
                    authority.value(named: "blob_id") == .text(blobID.rawValue) &&
                        authority.value(named: "manifest_digest") == .text(manifestDigest) &&
                        authority.value(named: "command_id") == .text(evidence.commandID.rawValue) &&
                        authority.value(named: "terminal_event_sequence") == .integer(
                            evidenceSequence
                        ) &&
                        authority.value(named: "expected_state_version") == .integer(
                            evidenceStateVersion
                        ) &&
                        authority.value(named: "intent_digest") == .text(digest) &&
                        authority.value(named: "created_at_ms") == .integer(evidenceCreatedAtMS) &&
                        authority.value(named: "event_id") == .text(evidence.lineage.eventID.rawValue) &&
                        authority.value(named: "event_hash") == .text(evidence.lineage.eventHash)
                }
                guard authorityMatches.count == 1 else {
                    throw RuntimeCanonicalAttachmentError.corruptAuthority
                }
                return RuntimeCommittedReceiptArtifactLink(
                    kind: .attachmentFinalizationIntent, stableID: blobID.rawValue, digest: digest
                )
            }
            let evidence = try RuntimeAttachmentCodec.decode(
                RuntimeAttachmentReceiptRevisionEvidence.self, bytes: payload,
                maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            guard evidence.receiptID == receiptID, evidence.revisionID == revisionID,
                  evidence.blobID == blobID, evidence.manifestDigest == manifestDigest,
                  evidence.linkKind == linkKind,
                  try RuntimeAttachmentCodec.digest(
                      evidence, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
                  ) == digest else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            guard revisionAuthority.contains(authorityKey([
                revisionID.rawValue, blobID.rawValue, manifestDigest,
            ])),
            lifecycleAuthority.contains(authorityKey([
                blobID.rawValue, evidence.lifecycleTransitionDigest,
            ])) else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            for transitionDigest in evidence.referenceTransitionDigests {
                guard referenceAuthority.contains(authorityKey([
                    revisionID.rawValue, blobID.rawValue, transitionDigest,
                ])) else {
                    throw RuntimeCanonicalAttachmentError.corruptAuthority
                }
            }
            return RuntimeCommittedReceiptArtifactLink(
                kind: .attachmentRevision,
                stableID: "\(revisionID.rawValue)#\(linkKind)", digest: digest
            )
        }.sorted()
    }

    private static func authorityKey(_ row: SQLiteRow, fields: [String]) throws -> String {
        try authorityKey(fields.map { field in
            guard case let .text(value)? = row.value(named: field) else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            return value
        })
    }

    private static func authorityKey(_ values: [String]) -> String {
        values.joined(separator: "\u{0}")
    }

    static func beginRecoveryAttempt(
        workKind: RuntimeAttachmentRecoveryWorkKind,
        authorityID: String,
        occurrence: String,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> Bool {
        guard RuntimeAttachmentID.validate(authorityID) != nil,
              occurrence.isEmpty == false, occurrence.utf8.count <= 1_024 else {
            throw RuntimeCanonicalAttachmentError.invalidIdentity
        }
        let occurrenceFingerprint = recoveryOccurrenceFingerprint(
            workKind: workKind, authorityID: authorityID, occurrence: occurrence
        )
        let nowMS = try milliseconds(now)
        let rows = try database.query(
            """
            SELECT occurrence_fingerprint, attempt_count, next_retry_at_ms,
                   last_attempt_at_ms, resolved_at_ms, state_version
            FROM runtime_attachment_recovery_attempts
            WHERE work_kind = ? AND authority_id = ? LIMIT 2
            """,
            bindings: [.text(workKind.rawValue), .text(authorityID)]
        )
        guard rows.count <= 1 else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
        guard let row = rows.first else {
            let nextRetryMS = try milliseconds(now.addingTimeInterval(60))
            let changed = try database.execute(
                """
                INSERT INTO runtime_attachment_recovery_attempts(
                    work_kind, authority_id, occurrence_fingerprint,
                    attempt_count, next_retry_at_ms,
                    last_error_fingerprint, last_attempt_at_ms, resolved_at_ms, state_version
                ) VALUES(?, ?, ?, 1, ?, NULL, ?, NULL, 1)
                """,
                bindings: [
                    .text(workKind.rawValue), .text(authorityID), .text(occurrenceFingerprint),
                    .integer(nextRetryMS), .integer(nowMS),
                ]
            )
            guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
            return true
        }
        guard case let .text(storedOccurrence)? = row.value(named: "occurrence_fingerprint"),
              RuntimeStoreManifestCodec.isSHA256Hex(storedOccurrence),
              case let .integer(rawAttempts)? = row.value(named: "attempt_count"), rawAttempts > 0,
              rawAttempts <= Int64(RuntimeAttachmentLimits.maximumRecoveryAttempts),
              case let .integer(nextRetryMS)? = row.value(named: "next_retry_at_ms"),
              case let .integer(lastAttemptMS)? = row.value(named: "last_attempt_at_ms"),
              case let .integer(rawVersion)? = row.value(named: "state_version"), rawVersion > 0 else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        if case let .integer(resolvedAtMS)? = row.value(named: "resolved_at_ms") {
            guard resolvedAtMS >= lastAttemptMS else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            guard storedOccurrence != occurrenceFingerprint else { return false }
            let nextVersion = try RuntimeAttachmentCodec.nextSQLiteVersion(after: UInt64(rawVersion))
            let nextRetryMS = try milliseconds(now.addingTimeInterval(60))
            let reopenID = RuntimeAttachmentCodec.sha256(Data([
                "ambitions.attachment.recovery-reopen.v1", workKind.rawValue, authorityID,
                storedOccurrence, occurrenceFingerprint, String(rawAttempts), String(resolvedAtMS),
                String(nowMS), String(rawVersion), String(nextVersion),
            ].joined(separator: "\u{0}").utf8))
            let inserted = try database.execute(
                """
                INSERT INTO runtime_attachment_recovery_reopen_history(
                    reopen_id, work_kind, authority_id,
                    prior_occurrence_fingerprint, next_occurrence_fingerprint,
                    prior_attempt_count, prior_resolved_at_ms, reopened_at_ms,
                    prior_state_version, next_state_version, history_version
                ) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
                """,
                bindings: [
                    .text(reopenID), .text(workKind.rawValue), .text(authorityID),
                    .text(storedOccurrence), .text(occurrenceFingerprint), .integer(rawAttempts),
                    .integer(resolvedAtMS), .integer(nowMS), .integer(rawVersion),
                    .integer(try RuntimeAttachmentCodec.sqliteInteger(nextVersion)),
                ]
            )
            guard inserted == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
            let reopened = try database.execute(
                """
                UPDATE runtime_attachment_recovery_attempts
                SET occurrence_fingerprint = ?, attempt_count = 1, next_retry_at_ms = ?,
                    last_error_fingerprint = NULL, last_attempt_at_ms = ?,
                    resolved_at_ms = NULL, state_version = ?
                WHERE work_kind = ? AND authority_id = ?
                  AND occurrence_fingerprint = ? AND resolved_at_ms = ? AND state_version = ?
                """,
                bindings: [
                    .text(occurrenceFingerprint), .integer(nextRetryMS), .integer(nowMS),
                    .integer(try RuntimeAttachmentCodec.sqliteInteger(nextVersion)),
                    .text(workKind.rawValue), .text(authorityID), .text(storedOccurrence),
                    .integer(resolvedAtMS), .integer(rawVersion),
                ]
            )
            guard reopened == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
            return true
        }
        guard row.value(named: "resolved_at_ms") == .null else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        guard rawAttempts < Int64(RuntimeAttachmentLimits.maximumRecoveryAttempts),
              nextRetryMS <= nowMS else {
            return false
        }
        let attemptCount = Int(rawAttempts) + 1
        let exponent = min(attemptCount - 1, 10)
        let delaySeconds = min(
            RuntimeAttachmentLimits.maximumRecoveryBackoffSeconds,
            60 * TimeInterval(1 << exponent)
        )
        let retryMS = try milliseconds(now.addingTimeInterval(delaySeconds))
        let changed = try database.execute(
            """
            UPDATE runtime_attachment_recovery_attempts
            SET occurrence_fingerprint = ?, attempt_count = ?, next_retry_at_ms = ?,
                last_error_fingerprint = NULL,
                last_attempt_at_ms = ?, state_version = state_version + 1
            WHERE work_kind = ? AND authority_id = ? AND state_version = ?
              AND resolved_at_ms IS NULL AND next_retry_at_ms <= ?
              AND state_version < 9223372036854775807
            """,
            bindings: [
                .text(occurrenceFingerprint), .integer(Int64(attemptCount)),
                .integer(retryMS), .integer(nowMS),
                .text(workKind.rawValue), .text(authorityID), .integer(rawVersion), .integer(nowMS),
            ]
        )
        guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        return true
    }

    static func recoveryOccurrenceFingerprint(
        workKind: RuntimeAttachmentRecoveryWorkKind,
        authorityID: String,
        occurrence: String
    ) -> String {
        RuntimeAttachmentCodec.sha256(Data([
            "ambitions.attachment.recovery-occurrence.v1",
            workKind.rawValue, authorityID, occurrence,
        ].joined(separator: "\u{0}").utf8))
    }

    static func recoveryAttemptAuthorityID(
        scan: RuntimeAttachmentRecoveryScanKind,
        key: String
    ) throws -> String {
        guard key.isEmpty == false, key.utf8.count <= 1_024 else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        return RuntimeAttachmentCodec.sha256(Data([
            "ambitions.attachment.recovery-work.v4", scan.rawValue, key,
        ].joined(separator: "\u{0}").utf8))
    }

    static func recoveryFindingEvidenceFingerprint(
        issue: RuntimeAttachmentRecoveryIssue,
        blobID: RuntimeBlobID?,
        relativeDirectory: String,
        cycle: UInt64
    ) throws -> String {
        guard relativeDirectory.isEmpty == false, relativeDirectory.utf8.count <= 1_024,
              cycle <= RuntimeAttachmentCodec.maximumSQLiteInteger else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        return RuntimeAttachmentCodec.sha256(Data([
            "ambitions.attachment.recovery-finding.v2", issue.rawValue,
            blobID?.rawValue ?? "", relativeDirectory, String(cycle),
        ].joined(separator: "\u{0}").utf8))
    }

    static func recordRecoveryAttemptFailure(
        workKind: RuntimeAttachmentRecoveryWorkKind,
        authorityID: String,
        errorFingerprint: String,
        database: isolated SQLiteDatabase
    ) throws {
        guard RuntimeAttachmentID.validate(authorityID) != nil,
              RuntimeStoreManifestCodec.isSHA256Hex(errorFingerprint) else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let changed = try database.execute(
            """
            UPDATE runtime_attachment_recovery_attempts
            SET last_error_fingerprint = ?, state_version = state_version + 1
            WHERE work_kind = ? AND authority_id = ? AND resolved_at_ms IS NULL
              AND state_version < 9223372036854775807
            """,
            bindings: [
                .text(errorFingerprint), .text(workKind.rawValue), .text(authorityID),
            ]
        )
        guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
    }

    static func resolveRecoveryAttempt(
        workKind: RuntimeAttachmentRecoveryWorkKind,
        authorityID: String,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws {
        guard RuntimeAttachmentID.validate(authorityID) != nil else {
            throw RuntimeCanonicalAttachmentError.invalidIdentity
        }
        let changed = try database.execute(
            """
            UPDATE runtime_attachment_recovery_attempts
            SET resolved_at_ms = ?, state_version = state_version + 1
            WHERE work_kind = ? AND authority_id = ? AND resolved_at_ms IS NULL
              AND last_attempt_at_ms <= ?
              AND state_version < 9223372036854775807
            """,
            bindings: [
                .integer(try milliseconds(now)), .text(workKind.rawValue),
                .text(authorityID), .integer(try milliseconds(now)),
            ]
        )
        guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
    }

    static func claimUnownedManifestDeletion(
        _ inspection: RuntimeOwnedAttachmentManifestInspection,
        recoveryAuthorityID: String,
        now: Date,
        expiresAt: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentManifestDeletionClaim {
        guard RuntimeStoreManifestCodec.isSHA256Hex(recoveryAuthorityID),
              expiresAt > now,
              expiresAt.timeIntervalSince(now) <= RuntimeAttachmentLimits.maximumLeaseSeconds,
              inspection.directoryDevice <= UInt64(Int64.max),
              inspection.directoryInode > 0,
              inspection.directoryInode <= UInt64(Int64.max),
              RuntimeStoreManifestCodec.isSHA256Hex(inspection.manifestDigest) else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let authority = try database.query(
            """
            SELECT 1 AS present FROM runtime_blob_records
            WHERE blob_id = ? OR opaque_relative_directory = ? LIMIT 1
            """,
            bindings: [
                .text(inspection.manifest.blobID.rawValue),
                .text(inspection.manifest.opaqueRelativeDirectory),
            ]
        )
        guard authority.isEmpty else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        let claimID = RuntimeAttachmentCodec.sha256(Data([
            "ambitions.attachment.manifest-deletion-claim.v1",
            inspection.manifest.blobID.rawValue, inspection.manifestDigest,
            inspection.manifest.opaqueRelativeDirectory,
            String(inspection.directoryDevice), String(inspection.directoryInode),
        ].joined(separator: "\u{0}").utf8))
        let existing = try database.query(
            """
            SELECT claim_payload, claim_digest, claim_state, state_version,
                   recovery_authority_id,
                   claimed_at_ms, expires_at_ms, completed_at_ms
            FROM runtime_attachment_manifest_deletion_claims
            WHERE claim_id = ? LIMIT 2
            """,
            bindings: [.text(claimID)]
        )
        guard existing.count <= 1 else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
        if let row = existing.first {
            guard case let .blob(payload)? = row.value(named: "claim_payload"),
                  case let .text(digest)? = row.value(named: "claim_digest"),
                  RuntimeAttachmentCodec.sha256(payload) == digest,
                  case let .text(state)? = row.value(named: "claim_state"), state == "active",
                  case let .integer(version)? = row.value(named: "state_version"), version > 0,
                  case let .integer(claimedMS)? = row.value(named: "claimed_at_ms"),
                  case let .integer(expiryMS)? = row.value(named: "expires_at_ms"),
                  row.value(named: "recovery_authority_id") == .text(recoveryAuthorityID),
                  case .null? = row.value(named: "completed_at_ms") else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            let decoded = try RuntimeAttachmentCodec.decode(
                RuntimeAttachmentManifestDeletionClaim.self, bytes: payload,
                maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            guard decoded.claimID == claimID,
                  decoded.blobID == inspection.manifest.blobID,
                  decoded.manifestDigest == inspection.manifestDigest,
                  decoded.opaqueRelativeDirectory == inspection.manifest.opaqueRelativeDirectory,
                  decoded.observedDevice == inspection.directoryDevice,
                  decoded.observedInode == inspection.directoryInode,
                  decoded.stateVersion == UInt64(version),
                  try milliseconds(decoded.claimedAt) == claimedMS,
                  try milliseconds(decoded.expiresAt) == expiryMS else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            if decoded.expiresAt > now { return decoded }
            let next = RuntimeAttachmentManifestDeletionClaim(
                claimID: claimID, blobID: decoded.blobID,
                manifestDigest: decoded.manifestDigest,
                opaqueRelativeDirectory: decoded.opaqueRelativeDirectory,
                observedDevice: decoded.observedDevice, observedInode: decoded.observedInode,
                claimedAt: now, expiresAt: expiresAt,
                stateVersion: try RuntimeAttachmentCodec.nextSQLiteVersion(after: decoded.stateVersion)
            )
            let bytes = try RuntimeAttachmentCodec.encode(
                next, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            let changed = try database.execute(
                """
                UPDATE runtime_attachment_manifest_deletion_claims
                SET claimed_at_ms = ?, expires_at_ms = ?, state_version = ?,
                    claim_payload = ?, claim_digest = ?
                WHERE claim_id = ? AND claim_state = 'active' AND state_version = ?
                  AND expires_at_ms <= ?
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_blob_records AS b
                      WHERE b.blob_id = ? OR b.opaque_relative_directory = ?
                  )
                """,
                bindings: [
                    .integer(try milliseconds(now)), .integer(try milliseconds(expiresAt)),
                    .integer(try RuntimeAttachmentCodec.sqliteInteger(next.stateVersion)),
                    .blob(bytes), .text(RuntimeAttachmentCodec.sha256(bytes)), .text(claimID),
                    .integer(version), .integer(try milliseconds(now)),
                    .text(next.blobID.rawValue), .text(next.opaqueRelativeDirectory),
                ]
            )
            guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
            return next
        }
        let claim = RuntimeAttachmentManifestDeletionClaim(
            claimID: claimID, blobID: inspection.manifest.blobID,
            manifestDigest: inspection.manifestDigest,
            opaqueRelativeDirectory: inspection.manifest.opaqueRelativeDirectory,
            observedDevice: inspection.directoryDevice, observedInode: inspection.directoryInode,
            claimedAt: now, expiresAt: expiresAt, stateVersion: 1
        )
        let bytes = try RuntimeAttachmentCodec.encode(
            claim, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        try database.execute(
            """
            INSERT INTO runtime_attachment_manifest_deletion_claims(
                claim_id, blob_id, manifest_digest, opaque_relative_directory,
                observed_device, observed_inode, claimed_at_ms, expires_at_ms,
                recovery_authority_id,
                claim_state, state_version, claim_version, claim_payload, claim_digest,
                completed_at_ms
            ) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, 'active', 1, 1, ?, ?, NULL)
            """,
            bindings: [
                .text(claimID), .text(claim.blobID.rawValue), .text(claim.manifestDigest),
                .text(claim.opaqueRelativeDirectory), .integer(Int64(claim.observedDevice)),
                .integer(Int64(claim.observedInode)), .integer(try milliseconds(claim.claimedAt)),
                .integer(try milliseconds(claim.expiresAt)), .text(recoveryAuthorityID), .blob(bytes),
                .text(RuntimeAttachmentCodec.sha256(bytes)),
            ]
        )
        return claim
    }

    static func activeUnownedManifestDeletionClaims(
        limit: Int,
        afterClaimID: String?,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeAttachmentManifestDeletionRecoveryWork] {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize,
              afterClaimID.map(RuntimeStoreManifestCodec.isSHA256Hex) ?? true else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let rows = try database.query(
            """
            SELECT c.claim_id, c.claim_payload, c.claim_digest, c.recovery_authority_id,
                   c.state_version AS claim_state_version,
                   c.claimed_at_ms, c.expires_at_ms
            FROM runtime_attachment_manifest_deletion_claims AS c
            JOIN runtime_attachment_recovery_attempts AS a
              ON a.work_kind = 'manifest_directory'
             AND a.authority_id = c.recovery_authority_id
            WHERE c.claim_state = 'active' AND (? IS NULL OR c.claim_id > ?)
              AND a.resolved_at_ms IS NULL AND a.attempt_count < ?
              AND a.next_retry_at_ms <= ?
            ORDER BY c.claim_id LIMIT ?
            """,
            bindings: [
                afterClaimID.map(SQLiteBinding.text) ?? .null,
                afterClaimID.map(SQLiteBinding.text) ?? .null,
                .integer(Int64(RuntimeAttachmentLimits.maximumRecoveryAttempts)),
                .integer(try milliseconds(now)), .integer(Int64(limit)),
            ]
        )
        return try rows.map { row in
            guard case let .text(claimID)? = row.value(named: "claim_id"),
                  case let .blob(payload)? = row.value(named: "claim_payload"),
                  case let .text(digest)? = row.value(named: "claim_digest"),
                  RuntimeAttachmentCodec.sha256(payload) == digest,
                  case let .text(authorityID)? = row.value(named: "recovery_authority_id"),
                  RuntimeStoreManifestCodec.isSHA256Hex(authorityID),
                  case let .integer(version)? = row.value(named: "claim_state_version"), version > 0,
                  case let .integer(claimedMS)? = row.value(named: "claimed_at_ms"),
                  case let .integer(expiryMS)? = row.value(named: "expires_at_ms") else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            let claim = try RuntimeAttachmentCodec.decode(
                RuntimeAttachmentManifestDeletionClaim.self, bytes: payload,
                maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            guard claim.claimID == claimID, claim.stateVersion == UInt64(version),
                  try milliseconds(claim.claimedAt) == claimedMS,
                  try milliseconds(claim.expiresAt) == expiryMS else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            return RuntimeAttachmentManifestDeletionRecoveryWork(
                claim: claim, recoveryAuthorityID: authorityID
            )
        }
    }

    static func renewUnownedManifestDeletionClaim(
        _ claim: RuntimeAttachmentManifestDeletionClaim,
        now: Date,
        expiresAt: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentManifestDeletionClaim {
        guard expiresAt > now,
              expiresAt > claim.expiresAt,
              expiresAt.timeIntervalSince(now) <= RuntimeAttachmentLimits.maximumLeaseSeconds else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let next = RuntimeAttachmentManifestDeletionClaim(
            claimID: claim.claimID, blobID: claim.blobID,
            manifestDigest: claim.manifestDigest,
            opaqueRelativeDirectory: claim.opaqueRelativeDirectory,
            observedDevice: claim.observedDevice, observedInode: claim.observedInode,
            claimedAt: now, expiresAt: expiresAt,
            stateVersion: try RuntimeAttachmentCodec.nextSQLiteVersion(after: claim.stateVersion)
        )
        let bytes = try RuntimeAttachmentCodec.encode(
            next, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let changed = try database.execute(
            """
            UPDATE runtime_attachment_manifest_deletion_claims
            SET claimed_at_ms = ?, expires_at_ms = ?, state_version = ?,
                claim_payload = ?, claim_digest = ?
            WHERE claim_id = ? AND claim_state = 'active' AND state_version = ?
              AND claim_digest = ?
              AND NOT EXISTS (
                  SELECT 1 FROM runtime_blob_records AS b
                  WHERE b.blob_id = ? OR b.opaque_relative_directory = ?
              )
            """,
            bindings: [
                .integer(try milliseconds(now)), .integer(try milliseconds(expiresAt)),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(next.stateVersion)),
                .blob(bytes), .text(RuntimeAttachmentCodec.sha256(bytes)), .text(claim.claimID),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(claim.stateVersion)),
                .text(try RuntimeAttachmentCodec.digest(
                    claim, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
                )),
                .text(claim.blobID.rawValue), .text(claim.opaqueRelativeDirectory),
            ]
        )
        guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        return next
    }

    static func completeUnownedManifestDeletion(
        claim: RuntimeAttachmentManifestDeletionClaim,
        proof: RuntimeAttachmentManifestDeletionProof,
        recoveryAuthorityID: String,
        database: isolated SQLiteDatabase
    ) throws {
        guard RuntimeAttachmentID.validate(recoveryAuthorityID) != nil,
              claim.claimID == proof.claimID,
              claim.blobID == proof.blobID,
              claim.manifestDigest == proof.manifestDigest,
              claim.opaqueRelativeDirectory == proof.originalRelativeDirectory,
              claim.observedDevice == proof.directoryDevice,
              claim.observedInode == proof.directoryInode,
              claim.claimedAt <= proof.deletedAt, proof.deletedAt < claim.expiresAt,
              RuntimeStoreManifestCodec.isSHA256Hex(proof.proofDigest),
              try RuntimeAttachmentCodec.manifestDeletionProofDigest(
                  claimID: proof.claimID, blobID: proof.blobID,
                  manifestDigest: proof.manifestDigest,
                  originalRelativeDirectory: proof.originalRelativeDirectory,
                  quarantineRelativeDirectory: proof.quarantineRelativeDirectory,
                  directoryDevice: proof.directoryDevice,
                  directoryInode: proof.directoryInode, deletedAt: proof.deletedAt
              ) == proof.proofDigest else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let rows = try database.query(
            """
            SELECT claim_payload, claim_digest, state_version, claimed_at_ms, expires_at_ms
            FROM runtime_attachment_manifest_deletion_claims
            WHERE claim_id = ? AND claim_state = 'active' LIMIT 2
            """,
            bindings: [.text(claim.claimID)]
        )
        guard rows.count == 1,
              case let .blob(currentPayload)? = rows[0].value(named: "claim_payload"),
              case let .text(currentDigest)? = rows[0].value(named: "claim_digest"),
              RuntimeAttachmentCodec.sha256(currentPayload) == currentDigest,
              case let .integer(version)? = rows[0].value(named: "state_version"),
              version == try RuntimeAttachmentCodec.sqliteInteger(claim.stateVersion),
              rows[0].value(named: "claimed_at_ms") == .integer(try milliseconds(claim.claimedAt)),
              rows[0].value(named: "expires_at_ms") == .integer(try milliseconds(claim.expiresAt)),
              try RuntimeAttachmentCodec.decode(
                  RuntimeAttachmentManifestDeletionClaim.self, bytes: currentPayload,
                  maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
              ) == claim else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let authority = try database.query(
            """
            SELECT 1 AS present FROM runtime_blob_records
            WHERE blob_id = ? OR opaque_relative_directory = ? LIMIT 1
            """,
            bindings: [.text(claim.blobID.rawValue), .text(claim.opaqueRelativeDirectory)]
        )
        guard authority.isEmpty else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        let proofBytes = try RuntimeAttachmentCodec.encode(
            proof, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        try database.execute(
            """
            INSERT INTO runtime_attachment_manifest_deletion_tombstones(
                claim_id, blob_id, manifest_digest, opaque_relative_directory,
                observed_device, observed_inode, quarantine_relative_directory,
                quarantine_device, quarantine_inode, proof_payload, proof_digest,
                deleted_at_ms, tombstone_version
            ) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
            """,
            bindings: [
                .text(claim.claimID), .text(claim.blobID.rawValue), .text(claim.manifestDigest),
                .text(claim.opaqueRelativeDirectory), .integer(Int64(claim.observedDevice)),
                .integer(Int64(claim.observedInode)), .text(proof.quarantineRelativeDirectory),
                .integer(Int64(proof.directoryDevice)), .integer(Int64(proof.directoryInode)),
                .blob(proofBytes), .text(proof.proofDigest),
                .integer(try milliseconds(proof.deletedAt)),
            ]
        )
        let completedClaim = RuntimeAttachmentManifestDeletionClaim(
            claimID: claim.claimID, blobID: claim.blobID,
            manifestDigest: claim.manifestDigest,
            opaqueRelativeDirectory: claim.opaqueRelativeDirectory,
            observedDevice: claim.observedDevice, observedInode: claim.observedInode,
            claimedAt: claim.claimedAt, expiresAt: claim.expiresAt,
            stateVersion: try RuntimeAttachmentCodec.nextSQLiteVersion(after: claim.stateVersion)
        )
        let completedBytes = try RuntimeAttachmentCodec.encode(
            completedClaim, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let changed = try database.execute(
            """
            UPDATE runtime_attachment_manifest_deletion_claims
            SET claim_state = 'completed', state_version = ?, claim_payload = ?,
                claim_digest = ?, completed_at_ms = ?
            WHERE claim_id = ? AND claim_state = 'active' AND state_version = ?
              AND expires_at_ms > ?
            """,
            bindings: [
                .integer(try RuntimeAttachmentCodec.sqliteInteger(completedClaim.stateVersion)),
                .blob(completedBytes), .text(RuntimeAttachmentCodec.sha256(completedBytes)),
                .integer(try milliseconds(proof.deletedAt)), .text(claim.claimID),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(claim.stateVersion)),
                .integer(try milliseconds(proof.deletedAt)),
            ]
        )
        guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        let orphanRows = try database.query(
            """
            SELECT manifest_payload, manifest_digest, opaque_relative_directory
            FROM runtime_blob_staging_orphans
            WHERE losing_blob_id = ? AND manifest_digest = ?
              AND opaque_relative_directory = ? AND cleaned_at_ms IS NULL LIMIT 2
            """,
            bindings: [
                .text(claim.blobID.rawValue), .text(claim.manifestDigest),
                .text(claim.opaqueRelativeDirectory),
            ]
        )
        guard orphanRows.count <= 1 else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        if let orphan = orphanRows.first {
            guard case let .blob(manifestBytes)? = orphan.value(named: "manifest_payload"),
                  orphan.value(named: "manifest_digest") == .text(claim.manifestDigest),
                  RuntimeAttachmentCodec.sha256(manifestBytes) == claim.manifestDigest,
                  orphan.value(named: "opaque_relative_directory") == .text(
                      claim.opaqueRelativeDirectory
                  ) else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            let manifest = try RuntimeAttachmentCodec.decode(
                RuntimeBlobManifestAuthority.self, bytes: manifestBytes,
                maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            try RuntimeAttachmentCodec.validate(manifest)
            guard manifest.blobID == claim.blobID,
                  manifest.opaqueRelativeDirectory == claim.opaqueRelativeDirectory else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            try markStagingOrphanCleaned(
                blobID: claim.blobID, manifestDigest: claim.manifestDigest,
                at: proof.deletedAt, database: database
            )
            _ = try resolveOpenRecoveryFindings(
                issue: .interruptedDeletion, blobID: claim.blobID,
                relativeDirectory: claim.opaqueRelativeDirectory,
                at: proof.deletedAt, database: database
            )
            let stagingAttempts = try database.query(
                """
                SELECT resolved_at_ms FROM runtime_attachment_recovery_attempts
                WHERE work_kind = 'staging_orphan' AND authority_id = ? LIMIT 2
                """,
                bindings: [.text(claim.blobID.rawValue)]
            )
            guard stagingAttempts.count <= 1 else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            if let stagingAttempt = stagingAttempts.first {
                switch stagingAttempt.value(named: "resolved_at_ms") {
                case .null?:
                    try resolveRecoveryAttempt(
                        workKind: .stagingOrphan, authorityID: claim.blobID.rawValue,
                        at: proof.deletedAt, database: database
                    )
                case .integer?:
                    break
                default:
                    throw RuntimeCanonicalAttachmentError.corruptAuthority
                }
            }
        }
        _ = try resolveOpenRecoveryFindings(
            issue: .manifestWithoutRow, blobID: claim.blobID,
            relativeDirectory: claim.opaqueRelativeDirectory,
            at: proof.deletedAt, database: database
        )
        try resolveRecoveryAttempt(
            workKind: .manifestDirectory, authorityID: recoveryAuthorityID,
            at: proof.deletedAt, database: database
        )
    }

    static func recoverySnapshots(
        limit: Int,
        afterBlobID: RuntimeBlobID?,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeAttachmentAuthoritySnapshot] {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        var budget = RuntimeAttachmentDecodedByteBudget(
            maximumBytes: RuntimeAttachmentLimits.maximumPageBytes
        )
        let rows = try budget.query(
            """
            SELECT MIN(v.revision_id) AS revision_id
            FROM runtime_attachment_revisions AS v
            JOIN runtime_attachment_current_lifecycle AS s ON s.blob_id = v.blob_id
            WHERE (? IS NULL OR v.blob_id > ?)
            GROUP BY v.blob_id
            ORDER BY v.blob_id LIMIT ?
            """,
            bindings: [
                afterBlobID.map { .text($0.rawValue) } ?? .null,
                afterBlobID.map { .text($0.rawValue) } ?? .null,
                .integer(Int64(limit)),
            ],
            database: database
        )
        return try rows.map { row in
            guard case let .text(raw)? = row.value(named: "revision_id"),
                  let revisionID = RuntimeAttachmentRevisionID(rawValue: raw),
                  let graph = try loadSnapshot(
                    revisionID: revisionID, budget: &budget, database: database
                  ) else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            return graph
        }
    }

    static func recoveryCursor(
        scanKind: RuntimeAttachmentRecoveryScanKind,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentRecoveryCursor? {
        let rows = try database.query(
            """
            SELECT last_key, cycle, state_version, updated_at_ms
            FROM runtime_attachment_recovery_cursors WHERE scan_kind = ? LIMIT 2
            """,
            bindings: [.text(scanKind.rawValue)]
        )
        guard rows.count <= 1 else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
        guard let row = rows.first else { return nil }
        let lastKey: String?
        switch row.value(named: "last_key") {
        case let .text(value)?:
            guard RuntimeAttachmentID.validate(value) != nil else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            lastKey = value
        case .null?: lastKey = nil
        default: throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        guard case let .integer(rawCycle)? = row.value(named: "cycle"), rawCycle >= 0,
              case let .integer(rawVersion)? = row.value(named: "state_version"), rawVersion > 0,
              case let .integer(updatedAtMS)? = row.value(named: "updated_at_ms"), updatedAtMS >= 0 else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return RuntimeAttachmentRecoveryCursor(
            scanKind: scanKind, lastKey: lastKey, cycle: UInt64(rawCycle),
            stateVersion: UInt64(rawVersion),
            updatedAt: Date(timeIntervalSince1970: Double(updatedAtMS) / 1_000)
        )
    }

    static func advanceRecoveryCursor(
        scanKind: RuntimeAttachmentRecoveryScanKind,
        lastKey: String?,
        wrapped: Bool,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentRecoveryCursor {
        if let lastKey, RuntimeAttachmentID.validate(lastKey) == nil {
            throw RuntimeCanonicalAttachmentError.invalidIdentity
        }
        guard wrapped == (lastKey == nil) else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let existing = try recoveryCursor(scanKind: scanKind, database: database)
        let nowMS = try milliseconds(now)
        if let existing {
            let nextCycle = wrapped
                ? try RuntimeAttachmentCodec.nextSQLiteVersion(after: existing.cycle)
                : existing.cycle
            let nextStateVersion = try RuntimeAttachmentCodec.nextSQLiteVersion(
                after: existing.stateVersion
            )
            let changed = try database.execute(
                """
                UPDATE runtime_attachment_recovery_cursors
                SET last_key = ?, cycle = ?, state_version = ?, updated_at_ms = ?
                WHERE scan_kind = ? AND state_version = ?
                """,
                bindings: [
                    lastKey.map(SQLiteBinding.text) ?? .null,
                    .integer(try RuntimeAttachmentCodec.sqliteInteger(nextCycle)),
                    .integer(try RuntimeAttachmentCodec.sqliteInteger(nextStateVersion)),
                    .integer(nowMS), .text(scanKind.rawValue),
                    .integer(try RuntimeAttachmentCodec.sqliteInteger(existing.stateVersion)),
                ]
            )
            guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        } else {
            let changed = try database.execute(
                """
                INSERT INTO runtime_attachment_recovery_cursors(
                    scan_kind, last_key, cycle, state_version, updated_at_ms
                ) VALUES(?, ?, ?, 1, ?)
                """,
                bindings: [
                    .text(scanKind.rawValue), lastKey.map(SQLiteBinding.text) ?? .null,
                    .integer(wrapped ? 1 : 0), .integer(nowMS),
                ]
            )
            guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        }
        guard let result = try recoveryCursor(scanKind: scanKind, database: database) else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return result
    }

    static func dueStagedExpirations(
        limit: Int,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeAttachmentRevisionID] {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let cutoffMS = try milliseconds(
            now.addingTimeInterval(-RuntimeAttachmentLimits.maximumStagedLifetimeSeconds)
        )
        let nowMS = try milliseconds(now)
        let rows = try database.query(
            """
            SELECT MIN(v.revision_id) AS revision_id
            FROM runtime_attachment_current_lifecycle AS s
            JOIN runtime_attachment_revisions AS v ON v.blob_id = s.blob_id
            LEFT JOIN runtime_attachment_recovery_attempts AS a
              ON a.work_kind = 'staging_orphan' AND a.authority_id = s.blob_id
            WHERE s.lifecycle_state = 'staged' AND s.reference_count = 0
              AND s.updated_at_ms <= ?
              AND (a.authority_id IS NULL OR (
                  a.resolved_at_ms IS NULL AND a.attempt_count < ? AND a.next_retry_at_ms <= ?
              ))
            GROUP BY s.blob_id
            ORDER BY s.updated_at_ms, s.blob_id LIMIT ?
            """,
            bindings: [
                .integer(cutoffMS),
                .integer(Int64(RuntimeAttachmentLimits.maximumRecoveryAttempts)),
                .integer(nowMS), .integer(Int64(limit)),
            ]
        )
        return try rows.map { row in
            guard case let .text(raw)? = row.value(named: "revision_id"),
                  let revisionID = RuntimeAttachmentRevisionID(rawValue: raw) else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            return revisionID
        }
    }

    static func expireStagedAttachment(
        revisionID: RuntimeAttachmentRevisionID,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentRecoveryFinding {
        guard let graph = try loadSnapshot(revisionID: revisionID, database: database),
              graph.lifecycle.state == .staged,
              graph.lifecycle.referenceCount == 0,
              graph.lifecycle.updatedAt.addingTimeInterval(
                  RuntimeAttachmentLimits.maximumStagedLifetimeSeconds
              ) <= now,
              graph.tombstone == nil else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let nextVersion = try RuntimeAttachmentCodec.nextSQLiteVersion(
            after: graph.lifecycle.stateVersion
        )
        let fingerprint = RuntimeAttachmentCodec.sha256(Data(
            "ambitions.attachment.staged-expiry.v1\u{0}\(graph.manifest.blobID.rawValue)\u{0}\(graph.manifest.opaqueRelativeDirectory)".utf8
        ))
        let finding = RuntimeAttachmentRecoveryFinding(
            issue: .stagedExpired, blobID: graph.manifest.blobID,
            opaqueRelativeDirectory: graph.manifest.opaqueRelativeDirectory,
            evidenceFingerprint: fingerprint, observedAt: now
        )
        try recordRecoveryFinding(finding, database: database)
        let history = try makeHistory(
            blobID: graph.manifest.blobID, version: nextVersion,
            from: .staged, to: .deletionPending,
            fromCount: 0, toCount: 0,
            commandID: nil, receiptID: nil, lineage: nil,
            systemAuthority: RuntimeAttachmentSystemTransitionAuthority(
                kind: .stagedExpiry,
                authorityID: graph.manifest.blobID.rawValue,
                evidenceFingerprint: fingerprint
            ),
            at: now
        )
        try insertHistory(history, database: database)
        let next = RuntimeAttachmentCurrentLifecycle(
            version: runtimeCanonicalAttachmentModelVersion,
            blobID: graph.manifest.blobID, state: .deletionPending,
            stateVersion: nextVersion, referenceCount: 0,
            manifestDigest: graph.lifecycle.manifestDigest,
            retentionUntil: graph.lifecycle.retentionUntil,
            quarantineReasonCode: nil, updatedAt: now
        )
        let bytes = try RuntimeAttachmentCodec.encode(
            next, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let changed = try database.execute(
            """
            UPDATE runtime_attachment_current_lifecycle
            SET lifecycle_state = 'deletion_pending', state_version = ?,
                lifecycle_payload = ?, lifecycle_digest = ?, updated_at_ms = ?
            WHERE blob_id = ? AND lifecycle_state = 'staged' AND reference_count = 0
              AND state_version = ? AND lifecycle_digest = ?
            """,
            bindings: [
                .integer(try RuntimeAttachmentCodec.sqliteInteger(nextVersion)), .blob(bytes),
                .text(RuntimeAttachmentCodec.sha256(bytes)), .integer(try milliseconds(now)),
                .text(graph.manifest.blobID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(graph.lifecycle.stateVersion)),
                .text(try RuntimeAttachmentCodec.digest(
                    graph.lifecycle, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
                )),
            ]
        )
        guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        try releaseDedupAuthority(blobID: graph.manifest.blobID, database: database)
        return finding
    }

    static func stagedExpiryOccurrence(
        revisionID: RuntimeAttachmentRevisionID,
        stateVersion: UInt64
    ) -> String {
        "staged-expiry:\(revisionID.rawValue):\(stateVersion)"
    }

    static func hasBlobAuthority(
        blobID: RuntimeBlobID,
        manifestDigest: String,
        opaqueRelativeDirectory: String,
        database: isolated SQLiteDatabase
    ) throws -> Bool {
        let rows = try database.query(
            """
            SELECT 1 AS present FROM runtime_blob_records
            WHERE blob_id = ? AND manifest_digest = ? AND opaque_relative_directory = ? LIMIT 2
            """,
            bindings: [
                .text(blobID.rawValue), .text(manifestDigest), .text(opaqueRelativeDirectory),
            ]
        )
        guard rows.count <= 1 else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
        return rows.count == 1
    }

    static func recordRecoveryFinding(
        _ finding: RuntimeAttachmentRecoveryFinding,
        database: isolated SQLiteDatabase
    ) throws {
        guard RuntimeStoreManifestCodec.isSHA256Hex(finding.evidenceFingerprint),
              finding.opaqueRelativeDirectory.isEmpty == false,
              finding.opaqueRelativeDirectory.utf8.count <= 1_024 else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        try database.execute(
            """
            INSERT INTO runtime_attachment_recovery_findings(
                evidence_fingerprint, issue_code, blob_id, opaque_relative_directory,
                observed_at_ms, resolved_at_ms, finding_version
            ) VALUES(?, ?, ?, ?, ?, NULL, 1)
            ON CONFLICT(evidence_fingerprint) DO NOTHING
            """,
            bindings: [
                .text(finding.evidenceFingerprint), .text(finding.issue.rawValue),
                finding.blobID.map { .text($0.rawValue) } ?? .null,
                .text(finding.opaqueRelativeDirectory), .integer(try milliseconds(finding.observedAt)),
            ]
        )
        let authenticated = try database.query(
            """
            SELECT issue_code, blob_id, opaque_relative_directory, observed_at_ms
            FROM runtime_attachment_recovery_findings
            WHERE evidence_fingerprint = ? LIMIT 2
            """,
            bindings: [.text(finding.evidenceFingerprint)]
        )
        let expectedBlobValue: SQLiteValue = finding.blobID.map {
            .text($0.rawValue)
        } ?? .null
        guard authenticated.count == 1,
              authenticated[0].value(named: "issue_code") == .text(finding.issue.rawValue),
              authenticated[0].value(named: "blob_id") == expectedBlobValue,
              authenticated[0].value(named: "opaque_relative_directory")
                == .text(finding.opaqueRelativeDirectory),
              case let .integer(firstObservedAtMS)? = authenticated[0].value(
                named: "observed_at_ms"
              ),
              firstObservedAtMS <= (try milliseconds(finding.observedAt)) else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
    }

    static func resolveOpenRecoveryFindings(
        issue: RuntimeAttachmentRecoveryIssue,
        blobID: RuntimeBlobID?,
        relativeDirectory: String,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws -> Int {
        guard relativeDirectory.isEmpty == false, relativeDirectory.utf8.count <= 1_024 else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let nowMS = try milliseconds(now)
        let blobBinding = blobID.map { SQLiteBinding.text($0.rawValue) } ?? .null
        let changed = try database.execute(
            """
            UPDATE runtime_attachment_recovery_findings SET resolved_at_ms = ?
            WHERE issue_code = ?
              AND ((? IS NULL AND blob_id IS NULL) OR blob_id = ?)
              AND opaque_relative_directory = ? AND resolved_at_ms IS NULL
              AND observed_at_ms <= ?
            """,
            bindings: [
                .integer(nowMS), .text(issue.rawValue), blobBinding, blobBinding,
                .text(relativeDirectory), .integer(nowMS),
            ]
        )
        return changed
    }

    static func quarantineForRecovery(
        revisionID: RuntimeAttachmentRevisionID,
        reason: RuntimeAttachmentQuarantineReason,
        evidenceFingerprint: String,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws {
        guard RuntimeStoreManifestCodec.isSHA256Hex(evidenceFingerprint),
              let graph = try loadSnapshot(revisionID: revisionID, database: database),
              graph.tombstone == nil else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        if graph.lifecycle.state == .quarantined { return }
        let findings = try database.query(
            """
            SELECT 1 AS present FROM runtime_attachment_recovery_findings
            WHERE evidence_fingerprint = ? AND blob_id = ? AND resolved_at_ms IS NULL LIMIT 2
            """,
            bindings: [
                .text(evidenceFingerprint), .text(graph.manifest.blobID.rawValue),
            ]
        )
        guard findings.count == 1 else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        try database.execute(
            """
            INSERT INTO runtime_blob_quarantine(
                quarantine_id, blob_id, reason_code, evidence_fingerprint,
                observed_at_ms, resolved_at_ms, quarantine_version
            ) VALUES(?, ?, ?, ?, ?, NULL, 1)
            ON CONFLICT(blob_id, evidence_fingerprint) DO NOTHING
            """,
            bindings: [
                .text(evidenceFingerprint), .text(graph.manifest.blobID.rawValue),
                .text(reason.rawValue), .text(evidenceFingerprint), .integer(try milliseconds(now)),
            ]
        )
        let nextVersion = try RuntimeAttachmentCodec.nextSQLiteVersion(
            after: graph.lifecycle.stateVersion
        )
        let history = try makeHistory(
            blobID: graph.manifest.blobID, version: nextVersion,
            from: graph.lifecycle.state, to: .quarantined,
            fromCount: graph.lifecycle.referenceCount, toCount: graph.lifecycle.referenceCount,
            commandID: nil, receiptID: nil, lineage: nil,
            systemAuthority: RuntimeAttachmentSystemTransitionAuthority(
                kind: .recoveryQuarantine, authorityID: evidenceFingerprint,
                evidenceFingerprint: evidenceFingerprint
            ),
            at: now
        )
        try insertHistory(history, database: database)
        let next = RuntimeAttachmentCurrentLifecycle(
            version: runtimeCanonicalAttachmentModelVersion, blobID: graph.manifest.blobID,
            state: .quarantined, stateVersion: nextVersion,
            referenceCount: graph.lifecycle.referenceCount,
            manifestDigest: graph.lifecycle.manifestDigest,
            retentionUntil: graph.lifecycle.retentionUntil,
            quarantineReasonCode: reason, updatedAt: now
        )
        let bytes = try RuntimeAttachmentCodec.encode(
            next, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let changed = try database.execute(
            """
            UPDATE runtime_attachment_current_lifecycle SET
                lifecycle_state = 'quarantined', state_version = ?, quarantine_reason = ?,
                lifecycle_payload = ?, lifecycle_digest = ?, updated_at_ms = ?
            WHERE blob_id = ? AND state_version = ? AND lifecycle_digest = ?
            """,
            bindings: [
                .integer(try RuntimeAttachmentCodec.sqliteInteger(nextVersion)), .text(reason.rawValue), .blob(bytes),
                .text(RuntimeAttachmentCodec.sha256(bytes)), .integer(try milliseconds(now)),
                .text(graph.manifest.blobID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(graph.lifecycle.stateVersion)),
                .text(try RuntimeAttachmentCodec.digest(
                    graph.lifecycle, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
                )),
            ]
        )
        guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        try releaseDedupAuthority(blobID: graph.manifest.blobID, database: database)
    }

    private static func gcLeaseHistoryEvidence(
        blobID: RuntimeBlobID,
        transition: RuntimeBlobGCLeaseTransition,
        leaseID: RuntimeBlobGCLeaseID,
        leaseToken: String,
        ownerID: String,
        expectedStateVersion: UInt64,
        priorLeaseID: RuntimeBlobGCLeaseID?,
        priorLeaseToken: String?,
        priorOwnerID: String?,
        priorAuthorityVersion: UInt64?,
        authorityVersion: UInt64,
        priorAcquiredAt: Date?,
        priorExpiresAt: Date?,
        acquiredAt: Date,
        expiresAt: Date,
        occurredAt: Date
    ) throws -> String {
        RuntimeAttachmentCodec.sha256(Data([
            "ambitions.attachment.gc-lease-history-evidence.v1", blobID.rawValue,
            transition.rawValue, leaseID.rawValue, leaseToken, ownerID,
            String(expectedStateVersion), priorLeaseID?.rawValue ?? "",
            priorLeaseToken ?? "", priorOwnerID ?? "",
            priorAuthorityVersion.map { String($0) } ?? "",
            String(authorityVersion),
            try priorAcquiredAt.map { String(try milliseconds($0)) } ?? "",
            try priorExpiresAt.map { String(try milliseconds($0)) } ?? "",
            String(try milliseconds(acquiredAt)), String(try milliseconds(expiresAt)),
            String(try milliseconds(occurredAt)),
        ].joined(separator: "\u{0}").utf8))
    }

    private static func makeGCLeaseHistory(
        prior: RuntimeBlobGCCurrentLeaseAuthority?,
        current: RuntimeBlobGCCurrentLeaseAuthority,
        transition: RuntimeBlobGCLeaseTransition,
        occurredAt: Date
    ) throws -> RuntimeBlobGCLeaseHistory {
        let evidence = try gcLeaseHistoryEvidence(
            blobID: current.lease.blobID, transition: transition,
            leaseID: current.lease.leaseID, leaseToken: current.leaseToken,
            ownerID: current.lease.ownerID,
            expectedStateVersion: current.lease.expectedStateVersion,
            priorLeaseID: prior?.lease.leaseID, priorLeaseToken: prior?.leaseToken,
            priorOwnerID: prior?.lease.ownerID,
            priorAuthorityVersion: prior?.authorityVersion,
            authorityVersion: current.authorityVersion,
            priorAcquiredAt: prior?.lease.acquiredAt,
            priorExpiresAt: prior?.lease.expiresAt,
            acquiredAt: current.lease.acquiredAt, expiresAt: current.lease.expiresAt,
            occurredAt: occurredAt
        )
        let authority = RuntimeAttachmentSystemTransitionAuthority(
            kind: .garbageCollectionLease, authorityID: current.leaseToken,
            evidenceFingerprint: evidence
        )
        let historyID = RuntimeAttachmentCodec.sha256(Data([
            current.lease.blobID.rawValue, String(current.authorityVersion),
            transition.rawValue, evidence,
        ].joined(separator: "\u{0}").utf8))
        let unsigned = RuntimeBlobGCLeaseHistory(
            version: runtimeCanonicalAttachmentModelVersion, historyID: historyID,
            blobID: current.lease.blobID, transition: transition,
            leaseID: current.lease.leaseID, leaseToken: current.leaseToken,
            ownerID: current.lease.ownerID,
            expectedStateVersion: current.lease.expectedStateVersion,
            priorLeaseID: prior?.lease.leaseID,
            priorLeaseToken: prior?.leaseToken, priorOwnerID: prior?.lease.ownerID,
            priorAuthorityVersion: prior?.authorityVersion,
            authorityVersion: current.authorityVersion,
            priorAcquiredAt: prior?.lease.acquiredAt,
            priorExpiresAt: prior?.lease.expiresAt,
            acquiredAt: current.lease.acquiredAt, expiresAt: current.lease.expiresAt,
            occurredAt: occurredAt, systemAuthority: authority,
            transitionDigest: String(repeating: "0", count: 64)
        )
        let digest = try gcLeaseHistoryDigest(unsigned)
        return RuntimeBlobGCLeaseHistory(
            version: unsigned.version, historyID: unsigned.historyID, blobID: unsigned.blobID,
            transition: unsigned.transition, leaseID: unsigned.leaseID,
            leaseToken: unsigned.leaseToken, ownerID: unsigned.ownerID,
            expectedStateVersion: unsigned.expectedStateVersion,
            priorLeaseID: unsigned.priorLeaseID,
            priorLeaseToken: unsigned.priorLeaseToken, priorOwnerID: unsigned.priorOwnerID,
            priorAuthorityVersion: unsigned.priorAuthorityVersion,
            authorityVersion: unsigned.authorityVersion,
            priorAcquiredAt: unsigned.priorAcquiredAt, priorExpiresAt: unsigned.priorExpiresAt,
            acquiredAt: unsigned.acquiredAt, expiresAt: unsigned.expiresAt,
            occurredAt: unsigned.occurredAt, systemAuthority: unsigned.systemAuthority,
            transitionDigest: digest
        )
    }

    private static func gcLeaseHistoryDigest(
        _ value: RuntimeBlobGCLeaseHistory
    ) throws -> String {
        let unsigned = RuntimeBlobGCLeaseHistory(
            version: value.version, historyID: value.historyID, blobID: value.blobID,
            transition: value.transition, leaseID: value.leaseID,
            leaseToken: value.leaseToken, ownerID: value.ownerID,
            expectedStateVersion: value.expectedStateVersion,
            priorLeaseID: value.priorLeaseID,
            priorLeaseToken: value.priorLeaseToken, priorOwnerID: value.priorOwnerID,
            priorAuthorityVersion: value.priorAuthorityVersion,
            authorityVersion: value.authorityVersion,
            priorAcquiredAt: value.priorAcquiredAt, priorExpiresAt: value.priorExpiresAt,
            acquiredAt: value.acquiredAt, expiresAt: value.expiresAt,
            occurredAt: value.occurredAt, systemAuthority: value.systemAuthority,
            transitionDigest: String(repeating: "0", count: 64)
        )
        return try RuntimeAttachmentCodec.digest(
            unsigned, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
    }

    private static func insertGCLeaseHistory(
        _ value: RuntimeBlobGCLeaseHistory,
        database: isolated SQLiteDatabase
    ) throws {
        let bytes = try RuntimeAttachmentCodec.encode(
            value, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        try database.execute(
            """
            INSERT INTO runtime_blob_gc_lease_history(
                history_id, blob_id, transition_kind, lease_id, lease_token, owner_id,
                expected_state_version, prior_lease_id, prior_lease_token, prior_owner_id,
                prior_authority_version, authority_version,
                prior_acquired_at_ms, prior_expires_at_ms, acquired_at_ms, expires_at_ms,
                occurred_at_ms, system_authority_kind, system_authority_id,
                system_evidence_fingerprint, history_version, history_payload,
                transition_digest, history_payload_digest
            ) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)
            """,
            bindings: [
                .text(value.historyID), .text(value.blobID.rawValue),
                .text(value.transition.rawValue), .text(value.leaseID.rawValue),
                .text(value.leaseToken), .text(value.ownerID),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(value.expectedStateVersion)),
                value.priorLeaseID.map { .text($0.rawValue) } ?? .null,
                value.priorLeaseToken.map { .text($0) } ?? .null,
                value.priorOwnerID.map { .text($0) } ?? .null,
                try value.priorAuthorityVersion.map {
                    .integer(try RuntimeAttachmentCodec.sqliteInteger($0))
                } ?? .null,
                .integer(try RuntimeAttachmentCodec.sqliteInteger(value.authorityVersion)),
                try value.priorAcquiredAt.map { .integer(try milliseconds($0)) } ?? .null,
                try value.priorExpiresAt.map { .integer(try milliseconds($0)) } ?? .null,
                .integer(try milliseconds(value.acquiredAt)),
                .integer(try milliseconds(value.expiresAt)),
                .integer(try milliseconds(value.occurredAt)),
                .text(value.systemAuthority.kind.rawValue),
                .text(value.systemAuthority.authorityID),
                .text(value.systemAuthority.evidenceFingerprint),
                .blob(bytes), .text(value.transitionDigest),
                .text(RuntimeAttachmentCodec.sha256(bytes)),
            ]
        )
    }

    private static func loadGCCurrentLease(
        blobID: RuntimeBlobID,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeBlobGCCurrentLeaseAuthority? {
        let rows = try database.query(
            """
            SELECT lease_id, lease_token, expected_state_version, owner_id,
                   acquired_at_ms, expires_at_ms, lease_state, authority_version,
                   lease_version, lease_payload, lease_digest, released_at_ms
            FROM runtime_blob_gc_leases WHERE blob_id = ? LIMIT 2
            """,
            bindings: [.text(blobID.rawValue)],
            maximumDecodedBytes: RuntimeAttachmentLimits.maximumManifestBytes * 2
        )
        guard rows.count <= 1 else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
        guard let row = rows.first else { return nil }
        guard case let .blob(bytes)? = row.value(named: "lease_payload"),
              case let .text(digest)? = row.value(named: "lease_digest"),
              RuntimeAttachmentCodec.sha256(bytes) == digest else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let value = try RuntimeAttachmentCodec.decode(
            RuntimeBlobGCCurrentLeaseAuthority.self, bytes: bytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        guard value.version == runtimeCanonicalAttachmentModelVersion,
              value.lease.blobID == blobID,
              value.lease.version == runtimeCanonicalAttachmentModelVersion,
              value.lease.expectedStateVersion <= RuntimeAttachmentCodec.maximumSQLiteInteger,
              value.authorityVersion <= RuntimeAttachmentCodec.maximumSQLiteInteger,
              value.leaseToken == (try RuntimeAttachmentCodec.gcLeaseToken(value.lease)),
              row.value(named: "lease_id") == .text(value.lease.leaseID.rawValue),
              row.value(named: "lease_token") == .text(value.leaseToken),
              row.value(named: "expected_state_version") == .integer(
                try RuntimeAttachmentCodec.sqliteInteger(value.lease.expectedStateVersion)
              ),
              row.value(named: "owner_id") == .text(value.lease.ownerID),
              row.value(named: "acquired_at_ms") == .integer(
                try milliseconds(value.lease.acquiredAt)
              ),
              row.value(named: "expires_at_ms") == .integer(
                try milliseconds(value.lease.expiresAt)
              ),
              row.value(named: "lease_state") == .text(value.state.rawValue),
              row.value(named: "authority_version") == .integer(
                try RuntimeAttachmentCodec.sqliteInteger(value.authorityVersion)
              ),
              row.value(named: "lease_version") == .integer(Int64(value.version)) else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        switch (value.releasedAt, row.value(named: "released_at_ms")) {
        case (nil, .null?): break
        case let (date?, .integer(raw)?):
            guard try milliseconds(date) == raw else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
        default: throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let historyRows = try database.query(
            """
            SELECT history_id, transition_kind, lease_id, lease_token, owner_id,
                   expected_state_version, prior_lease_id, prior_lease_token, prior_owner_id,
                   prior_authority_version, authority_version,
                   prior_acquired_at_ms, prior_expires_at_ms, acquired_at_ms, expires_at_ms,
                   occurred_at_ms, system_authority_kind, system_authority_id,
                   system_evidence_fingerprint, history_version, history_payload,
                   transition_digest, history_payload_digest
            FROM runtime_blob_gc_lease_history WHERE blob_id = ?
            ORDER BY authority_version DESC LIMIT 1
            """,
            bindings: [.text(blobID.rawValue)],
            maximumDecodedBytes: RuntimeAttachmentLimits.maximumManifestBytes * 2
        )
        guard historyRows.count == 1,
              case let .blob(historyBytes)? = historyRows[0].value(named: "history_payload"),
              case let .text(payloadDigest)? = historyRows[0].value(named: "history_payload_digest"),
              RuntimeAttachmentCodec.sha256(historyBytes) == payloadDigest else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let history = try RuntimeAttachmentCodec.decode(
            RuntimeBlobGCLeaseHistory.self, bytes: historyBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let h = historyRows[0]
        let expectedEvidence = try gcLeaseHistoryEvidence(
            blobID: history.blobID, transition: history.transition,
            leaseID: history.leaseID, leaseToken: history.leaseToken,
            ownerID: history.ownerID,
            expectedStateVersion: history.expectedStateVersion,
            priorLeaseID: history.priorLeaseID,
            priorLeaseToken: history.priorLeaseToken,
            priorOwnerID: history.priorOwnerID,
            priorAuthorityVersion: history.priorAuthorityVersion,
            authorityVersion: history.authorityVersion,
            priorAcquiredAt: history.priorAcquiredAt,
            priorExpiresAt: history.priorExpiresAt,
            acquiredAt: history.acquiredAt, expiresAt: history.expiresAt,
            occurredAt: history.occurredAt
        )
        let expectedHistoryID = RuntimeAttachmentCodec.sha256(Data([
            history.blobID.rawValue, String(history.authorityVersion),
            history.transition.rawValue, expectedEvidence,
        ].joined(separator: "\u{0}").utf8))
        guard h.value(named: "transition_digest") == .text(history.transitionDigest),
              try gcLeaseHistoryDigest(history) == history.transitionDigest,
              history.version == runtimeCanonicalAttachmentModelVersion,
              history.expectedStateVersion <= RuntimeAttachmentCodec.maximumSQLiteInteger,
              history.authorityVersion <= RuntimeAttachmentCodec.maximumSQLiteInteger,
              history.priorAuthorityVersion.map({
                  $0 <= RuntimeAttachmentCodec.maximumSQLiteInteger
              }) ?? true,
              history.blobID == blobID,
              history.historyID == expectedHistoryID,
              history.systemAuthority.kind == .garbageCollectionLease,
              history.systemAuthority.authorityID == history.leaseToken,
              history.systemAuthority.evidenceFingerprint == expectedEvidence,
              history.authorityVersion == value.authorityVersion,
              history.leaseID == value.lease.leaseID,
              history.leaseToken == value.leaseToken,
              history.ownerID == value.lease.ownerID,
              history.expectedStateVersion == value.lease.expectedStateVersion,
              h.value(named: "history_id") == .text(history.historyID),
              h.value(named: "transition_kind") == .text(history.transition.rawValue),
              h.value(named: "lease_id") == .text(history.leaseID.rawValue),
              h.value(named: "lease_token") == .text(history.leaseToken),
              h.value(named: "owner_id") == .text(history.ownerID),
              h.value(named: "expected_state_version") == .integer(
                try RuntimeAttachmentCodec.sqliteInteger(history.expectedStateVersion)
              ),
              h.value(named: "authority_version") == .integer(
                try RuntimeAttachmentCodec.sqliteInteger(history.authorityVersion)
              ),
              h.value(named: "acquired_at_ms") == .integer(try milliseconds(history.acquiredAt)),
              h.value(named: "expires_at_ms") == .integer(try milliseconds(history.expiresAt)),
              h.value(named: "occurred_at_ms") == .integer(try milliseconds(history.occurredAt)),
              h.value(named: "system_authority_kind") == .text(
                history.systemAuthority.kind.rawValue
              ),
              h.value(named: "system_authority_id") == .text(
                history.systemAuthority.authorityID
              ),
              h.value(named: "system_evidence_fingerprint") == .text(
                history.systemAuthority.evidenceFingerprint
              ),
              h.value(named: "history_version") == .integer(Int64(history.version)) else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let transitionMatchesCurrent: Bool
        switch (history.transition, value.state) {
        case (.acquired, .active), (.renewed, .active), (.reacquired, .active),
             (.expired, .expired), (.released, .released):
            transitionMatchesCurrent = true
        default:
            transitionMatchesCurrent = false
        }
        guard transitionMatchesCurrent,
              history.expiresAt > history.acquiredAt,
              history.authorityVersion == (history.priorAuthorityVersion ?? 0) + 1,
              history.priorAuthorityVersion == nil || (
                  history.priorLeaseID != nil && history.priorLeaseToken != nil
                      && history.priorOwnerID != nil && history.priorAcquiredAt != nil
                      && history.priorExpiresAt != nil
              ) else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        switch (history.priorAuthorityVersion, h.value(named: "prior_authority_version")) {
        case (nil, .null?): break
        case let (version?, .integer(raw)?):
            guard try RuntimeAttachmentCodec.sqliteInteger(version) == raw else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
        default: throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        switch (history.priorLeaseID, h.value(named: "prior_lease_id")) {
        case (nil, .null?): break
        case let (id?, .text(raw)?):
            guard id.rawValue == raw else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
        default: throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        for (value, field) in [
            (history.priorLeaseToken, "prior_lease_token"),
            (history.priorOwnerID, "prior_owner_id"),
        ] {
            switch (value, h.value(named: field)) {
            case (nil, .null?): break
            case let (expected?, .text(raw)?):
                guard expected == raw else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
            default: throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
        }
        for (date, field) in [
            (history.priorAcquiredAt, "prior_acquired_at_ms"),
            (history.priorExpiresAt, "prior_expires_at_ms"),
        ] {
            switch (date, h.value(named: field)) {
            case (nil, .null?): break
            case let (value?, .integer(raw)?):
                guard try milliseconds(value) == raw else {
                    throw RuntimeCanonicalAttachmentError.corruptAuthority
                }
            default: throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
        }
        let coherentTransition: Bool
        switch history.transition {
        case .acquired:
            coherentTransition = history.priorAuthorityVersion == nil
                && history.authorityVersion == 1
                && history.occurredAt == history.acquiredAt
        case .renewed:
            coherentTransition = history.priorLeaseID == history.leaseID
                && history.priorOwnerID == history.ownerID
                && history.priorLeaseToken != history.leaseToken
                && history.priorAcquiredAt.map { history.acquiredAt >= $0 } == true
                && history.priorExpiresAt.map { history.expiresAt > $0 } == true
                && history.occurredAt == history.acquiredAt
        case .reacquired:
            coherentTransition = history.priorLeaseID != history.leaseID
                && history.priorLeaseToken != history.leaseToken
                && history.priorExpiresAt.map { history.acquiredAt >= $0 } == true
                && history.occurredAt == history.acquiredAt
        case .expired:
            coherentTransition = history.priorLeaseID == history.leaseID
                && history.priorLeaseToken == history.leaseToken
                && history.priorOwnerID == history.ownerID
                && history.priorAcquiredAt == history.acquiredAt
                && history.priorExpiresAt == history.expiresAt
                && history.occurredAt >= history.expiresAt
        case .released:
            coherentTransition = history.priorLeaseID == history.leaseID
                && history.priorLeaseToken == history.leaseToken
                && history.priorOwnerID == history.ownerID
                && history.priorAcquiredAt == history.acquiredAt
                && history.priorExpiresAt == history.expiresAt
                && value.releasedAt == history.occurredAt
                && history.occurredAt >= history.acquiredAt
                && history.occurredAt < history.expiresAt
        }
        guard coherentTransition,
              (value.state == .released) == (value.releasedAt != nil) else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return value
    }

    private static func persistGCLeaseAuthority(
        prior: RuntimeBlobGCCurrentLeaseAuthority?,
        current: RuntimeBlobGCCurrentLeaseAuthority,
        transition: RuntimeBlobGCLeaseTransition,
        occurredAt: Date,
        database: isolated SQLiteDatabase
    ) throws {
        _ = try RuntimeAttachmentCodec.sqliteInteger(current.lease.expectedStateVersion)
        _ = try RuntimeAttachmentCodec.sqliteInteger(current.authorityVersion)
        if let prior {
            _ = try RuntimeAttachmentCodec.sqliteInteger(prior.authorityVersion)
        }
        let history = try makeGCLeaseHistory(
            prior: prior, current: current, transition: transition, occurredAt: occurredAt
        )
        try insertGCLeaseHistory(history, database: database)
        let bytes = try RuntimeAttachmentCodec.encode(
            current, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let bindings: [SQLiteBinding] = [
            .text(current.lease.leaseID.rawValue), .text(current.leaseToken),
            .integer(try RuntimeAttachmentCodec.sqliteInteger(current.lease.expectedStateVersion)),
            .text(current.lease.ownerID),
            .integer(try milliseconds(current.lease.acquiredAt)),
            .integer(try milliseconds(current.lease.expiresAt)), .text(current.state.rawValue),
            .integer(try RuntimeAttachmentCodec.sqliteInteger(current.authorityVersion)), .blob(bytes),
            .text(RuntimeAttachmentCodec.sha256(bytes)),
            try current.releasedAt.map { .integer(try milliseconds($0)) } ?? .null,
        ]
        if let prior {
            let changed = try database.execute(
                """
                UPDATE runtime_blob_gc_leases SET
                    lease_id = ?, lease_token = ?, expected_state_version = ?, owner_id = ?,
                    acquired_at_ms = ?, expires_at_ms = ?, lease_state = ?, authority_version = ?,
                    lease_payload = ?, lease_digest = ?, released_at_ms = ?
                WHERE blob_id = ? AND authority_version = ? AND lease_digest = ?
                """,
                bindings: bindings + [
                    .text(current.lease.blobID.rawValue),
                    .integer(try RuntimeAttachmentCodec.sqliteInteger(prior.authorityVersion)),
                    .text(try RuntimeAttachmentCodec.digest(
                        prior, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
                    )),
                ]
            )
            guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        } else {
            try database.execute(
                """
                INSERT INTO runtime_blob_gc_leases(
                    blob_id, lease_id, lease_token, expected_state_version, owner_id,
                    acquired_at_ms, expires_at_ms, lease_state, authority_version,
                    lease_version, lease_payload, lease_digest, released_at_ms
                ) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)
                """,
                bindings: [.text(current.lease.blobID.rawValue)] + bindings
            )
        }
    }

    static func expireGCLeases(
        limit: Int,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> Int {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let rows = try database.query(
            """
            SELECT blob_id FROM runtime_blob_gc_leases
            WHERE lease_state = 'active' AND expires_at_ms <= ?
            ORDER BY expires_at_ms, blob_id LIMIT ?
            """,
            bindings: [.integer(try milliseconds(now)), .integer(Int64(limit))]
        )
        var count = 0
        for row in rows {
            guard case let .text(raw)? = row.value(named: "blob_id"),
                  let blobID = RuntimeBlobID(rawValue: raw),
                  let active = try loadGCCurrentLease(blobID: blobID, database: database),
                  active.state == .active, active.lease.expiresAt <= now else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            let expired = RuntimeBlobGCCurrentLeaseAuthority(
                version: active.version, lease: active.lease, leaseToken: active.leaseToken,
                state: .expired, authorityVersion: try RuntimeAttachmentCodec.nextSQLiteVersion(
                    after: active.authorityVersion
                ),
                releasedAt: nil
            )
            try persistGCLeaseAuthority(
                prior: active, current: expired, transition: .expired,
                occurredAt: now, database: database
            )
            count += 1
        }
        return count
    }

    static func renewGCLease(
        _ lease: RuntimeBlobGCLease,
        now: Date,
        expiresAt: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeBlobGCLease {
        guard let active = try loadGCCurrentLease(blobID: lease.blobID, database: database),
              active.state == .active, active.lease == lease,
              lease.acquiredAt <= now, lease.expiresAt > now,
              expiresAt > lease.expiresAt,
              expiresAt.timeIntervalSince(now) <= RuntimeAttachmentLimits.maximumLeaseSeconds else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let renewedLease = RuntimeBlobGCLease(
            version: lease.version, leaseID: lease.leaseID, blobID: lease.blobID,
            expectedStateVersion: lease.expectedStateVersion, ownerID: lease.ownerID,
            acquiredAt: now, expiresAt: expiresAt
        )
        let renewed = RuntimeBlobGCCurrentLeaseAuthority(
            version: active.version, lease: renewedLease,
            leaseToken: try RuntimeAttachmentCodec.gcLeaseToken(renewedLease), state: .active,
            authorityVersion: try RuntimeAttachmentCodec.nextSQLiteVersion(
                after: active.authorityVersion
            ), releasedAt: nil
        )
        try persistGCLeaseAuthority(
            prior: active, current: renewed, transition: .renewed,
            occurredAt: now, database: database
        )
        _ = try confirmGCLease(renewedLease, now: now, database: database)
        return renewedLease
    }

    static func acquireGCLease(
        leaseID: RuntimeBlobGCLeaseID,
        ownerID: String,
        now: Date,
        expiresAt: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeBlobGCWork? {
        guard ownerID.isEmpty == false, ownerID.utf8.count <= 1_024,
              expiresAt > now,
              expiresAt.timeIntervalSince(now) <= RuntimeAttachmentLimits.maximumLeaseSeconds else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let nowMS = try milliseconds(now)
        let candidates = try database.query(
            """
            SELECT s.blob_id, s.state_version, s.lifecycle_state,
                   (SELECT MIN(v.revision_id) FROM runtime_attachment_revisions AS v
                    WHERE v.blob_id = s.blob_id) AS revision_id
            FROM runtime_attachment_current_lifecycle AS s
            WHERE s.lifecycle_state IN ('orphaned','deletion_pending') AND s.reference_count = 0
              AND (s.retention_until_ms IS NULL OR s.retention_until_ms <= ?)
              AND NOT EXISTS (
                  SELECT 1 FROM runtime_blob_retention_holds AS h
                  WHERE h.blob_id = s.blob_id AND h.released_at_ms IS NULL
                    AND (h.retain_until_ms IS NULL OR h.retain_until_ms > ?)
              )
              AND NOT EXISTS (
                  SELECT 1 FROM runtime_blob_deletion_tombstones AS t WHERE t.blob_id = s.blob_id
              )
              AND NOT EXISTS (
                  SELECT 1 FROM runtime_blob_gc_leases AS l
                  WHERE l.blob_id = s.blob_id AND l.lease_state = 'active'
                    AND l.expires_at_ms > ?
              )
            ORDER BY CASE s.lifecycle_state WHEN 'deletion_pending' THEN 0 ELSE 1 END,
                     s.updated_at_ms, s.blob_id LIMIT 1
            """,
            bindings: [.integer(nowMS), .integer(nowMS), .integer(nowMS)]
        )
        guard let candidate = candidates.first,
              case let .text(blobRaw)? = candidate.value(named: "blob_id"),
              let blobID = RuntimeBlobID(rawValue: blobRaw),
              case let .integer(version)? = candidate.value(named: "state_version"), version > 0,
              case let .text(stateRaw)? = candidate.value(named: "lifecycle_state"),
              let state = RuntimeAttachmentLifecycleState(rawValue: stateRaw),
              case let .text(revisionRaw)? = candidate.value(named: "revision_id"),
              let revisionID = RuntimeAttachmentRevisionID(rawValue: revisionRaw),
              let graph = try loadSnapshot(revisionID: revisionID, database: database) else {
            return nil
        }
        let fencedVersion = try RuntimeAttachmentCodec.nextSQLiteVersion(after: UInt64(version))
        let lease = RuntimeBlobGCLease(
            version: runtimeCanonicalAttachmentModelVersion, leaseID: leaseID, blobID: blobID,
            expectedStateVersion: fencedVersion, ownerID: ownerID,
            acquiredAt: now, expiresAt: expiresAt
        )
        let leaseToken = try RuntimeAttachmentCodec.gcLeaseToken(lease)
        let history = try makeHistory(
            blobID: blobID, version: fencedVersion, from: state,
            to: .deletionPending, fromCount: 0, toCount: 0,
            commandID: nil, receiptID: nil, lineage: nil,
            systemAuthority: RuntimeAttachmentSystemTransitionAuthority(
                kind: .garbageCollectionFence, authorityID: leaseID.rawValue,
                evidenceFingerprint: leaseToken
            ),
            at: now
        )
        try insertHistory(history, database: database)
        let fenced = RuntimeAttachmentCurrentLifecycle(
            version: runtimeCanonicalAttachmentModelVersion, blobID: blobID,
            state: .deletionPending, stateVersion: fencedVersion,
            referenceCount: 0, manifestDigest: graph.lifecycle.manifestDigest,
            retentionUntil: graph.lifecycle.retentionUntil,
            quarantineReasonCode: nil, updatedAt: now
        )
        let bytes = try RuntimeAttachmentCodec.encode(
            fenced, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let changed = try database.execute(
            """
            UPDATE runtime_attachment_current_lifecycle
            SET lifecycle_state = 'deletion_pending', state_version = ?,
                lifecycle_payload = ?, lifecycle_digest = ?, updated_at_ms = ?
            WHERE blob_id = ? AND lifecycle_state = ?
              AND state_version = ? AND reference_count = 0 AND lifecycle_digest = ?
            """,
            bindings: [
                .integer(try RuntimeAttachmentCodec.sqliteInteger(fencedVersion)), .blob(bytes),
                .text(RuntimeAttachmentCodec.sha256(bytes)), .integer(nowMS),
                .text(blobID.rawValue), .text(state.rawValue), .integer(version),
                .text(try RuntimeAttachmentCodec.digest(
                    graph.lifecycle, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
                )),
            ]
        )
        guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        var prior = try loadGCCurrentLease(blobID: blobID, database: database)
        if let active = prior, active.state == .active {
            guard active.lease.expiresAt <= now else {
                throw RuntimeCanonicalAttachmentError.invalidLease
            }
            let expired = RuntimeBlobGCCurrentLeaseAuthority(
                version: active.version, lease: active.lease, leaseToken: active.leaseToken,
                state: .expired, authorityVersion: try RuntimeAttachmentCodec.nextSQLiteVersion(
                    after: active.authorityVersion
                ),
                releasedAt: nil
            )
            try persistGCLeaseAuthority(
                prior: active, current: expired, transition: .expired,
                occurredAt: now, database: database
            )
            prior = expired
        }
        let current = RuntimeBlobGCCurrentLeaseAuthority(
            version: runtimeCanonicalAttachmentModelVersion, lease: lease,
            leaseToken: leaseToken, state: .active,
            authorityVersion: try RuntimeAttachmentCodec.nextSQLiteVersion(
                after: prior?.authorityVersion ?? 0
            ), releasedAt: nil
        )
        try persistGCLeaseAuthority(
            prior: prior, current: current,
            transition: prior == nil ? .acquired : .reacquired,
            occurredAt: now, database: database
        )
        return try confirmGCLease(lease, now: now, database: database)
    }

    static func confirmGCLease(
        _ lease: RuntimeBlobGCLease,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeBlobGCWork {
        guard lease.version == runtimeCanonicalAttachmentModelVersion,
              lease.expectedStateVersion <= RuntimeAttachmentCodec.maximumSQLiteInteger,
              lease.acquiredAt <= now, lease.expiresAt > now else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        guard let current = try loadGCCurrentLease(
            blobID: lease.blobID, database: database
        ), current.state == .active, current.lease == lease,
              current.leaseToken == (try RuntimeAttachmentCodec.gcLeaseToken(lease)) else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let nowMS = try milliseconds(now)
        let rows = try database.query(
            """
            SELECT v.revision_id, b.manifest_payload, b.manifest_digest,
                   s.lifecycle_payload, s.lifecycle_digest,
                   COALESCE((
                       SELECT l.receipt_id FROM runtime_attachment_receipt_links AS l
                       WHERE l.blob_id = b.blob_id AND l.link_kind = 'deletion_authorization'
                       ORDER BY l.receipt_id DESC LIMIT 1
                   ), 'retention-policy:' || b.blob_id) AS deletion_authorization_id
            FROM runtime_blob_gc_leases AS g
            JOIN runtime_blob_records AS b ON b.blob_id = g.blob_id
            JOIN runtime_attachment_current_lifecycle AS s ON s.blob_id = b.blob_id
            JOIN runtime_attachment_revisions AS v ON v.revision_id = (
                SELECT MIN(v2.revision_id) FROM runtime_attachment_revisions AS v2
                WHERE v2.blob_id = b.blob_id
            )
            WHERE g.blob_id = ? AND g.lease_id = ? AND g.expected_state_version = ?
              AND g.lease_token = ? AND g.owner_id = ? AND g.lease_state = 'active'
              AND g.expires_at_ms > ?
              AND s.state_version = g.expected_state_version
              AND s.lifecycle_state IN ('orphaned','deletion_pending') AND s.reference_count = 0
              AND (s.retention_until_ms IS NULL OR s.retention_until_ms <= ?)
              AND NOT EXISTS (
                  SELECT 1 FROM runtime_blob_retention_holds AS h
                  WHERE h.blob_id = g.blob_id AND h.released_at_ms IS NULL
                    AND (h.retain_until_ms IS NULL OR h.retain_until_ms > ?)
              )
              AND NOT EXISTS (
                  SELECT 1 FROM runtime_blob_deletion_tombstones AS t WHERE t.blob_id = g.blob_id
              )
            LIMIT 2
            """,
            bindings: [
                .text(lease.blobID.rawValue), .text(lease.leaseID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(lease.expectedStateVersion)),
                .text(current.leaseToken),
                .text(lease.ownerID),
                .integer(nowMS), .integer(nowMS), .integer(nowMS),
            ]
        )
        guard rows.count == 1,
              case let .text(revisionRaw)? = rows[0].value(named: "revision_id"),
              let revisionID = RuntimeAttachmentRevisionID(rawValue: revisionRaw),
              case let .blob(manifestBytes)? = rows[0].value(named: "manifest_payload"),
              case let .text(manifestDigest)? = rows[0].value(named: "manifest_digest"),
              RuntimeAttachmentCodec.sha256(manifestBytes) == manifestDigest,
              case let .blob(lifecycleBytes)? = rows[0].value(named: "lifecycle_payload"),
              case let .text(lifecycleDigest)? = rows[0].value(named: "lifecycle_digest"),
              RuntimeAttachmentCodec.sha256(lifecycleBytes) == lifecycleDigest,
              case let .text(authorizationID)? = rows[0].value(named: "deletion_authorization_id") else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let manifest = try RuntimeAttachmentCodec.decode(
            RuntimeBlobManifestAuthority.self, bytes: manifestBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let lifecycle = try RuntimeAttachmentCodec.decode(
            RuntimeAttachmentCurrentLifecycle.self, bytes: lifecycleBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        guard manifest.blobID == lease.blobID, lifecycle.blobID == lease.blobID,
              lifecycle.stateVersion == lease.expectedStateVersion else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return RuntimeBlobGCWork(
            revisionID: revisionID, manifest: manifest, manifestDigest: manifestDigest,
            lifecycle: lifecycle, deletionAuthorizationID: authorizationID
        )
    }

    static func recordDeletion(
        work: RuntimeBlobGCWork,
        lease: RuntimeBlobGCLease,
        tombstoneID: RuntimeBlobTombstoneID,
        proof: RuntimeAttachmentPhysicalDeletionProof,
        recordedAt: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeBlobDeletionTombstone {
        let deletedAt = proof.deletedAt
        guard proof.blobID == work.manifest.blobID,
              proof.manifestDigest == work.manifestDigest,
              proof.leaseID == lease.leaseID,
              proof.expectedStateVersion == lease.expectedStateVersion,
              ((proof.disposition == .removedOwnedDirectory &&
                    proof.directoryDevice.map { $0 > 0 } == true &&
                    proof.directoryInode.map { $0 > 0 } == true) ||
                (proof.disposition == .confirmedAlreadyAbsent &&
                    proof.directoryDevice == nil && proof.directoryInode == nil)),
              RuntimeStoreManifestCodec.isSHA256Hex(proof.proofDigest),
              try RuntimeAttachmentCodec.physicalDeletionProofDigest(proof) == proof.proofDigest,
              deletedAt <= recordedAt else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let confirmed = try confirmGCLease(lease, now: recordedAt, database: database)
        guard confirmed == work else { throw RuntimeCanonicalAttachmentError.invalidLease }
        let unsigned = RuntimeBlobDeletionTombstone(
            version: runtimeCanonicalAttachmentModelVersion, tombstoneID: tombstoneID,
            blobID: work.manifest.blobID, manifestDigest: work.manifestDigest,
            finalStateVersion: work.lifecycle.stateVersion,
            deletionAuthorizationID: work.deletionAuthorizationID,
            physicalDeletionConfirmed: true,
            physicalDeletionDisposition: proof.disposition,
            deletedAt: deletedAt,
            tombstoneDigest: String(repeating: "0", count: 64)
        )
        let digest = try RuntimeAttachmentCodec.tombstoneDigest(unsigned)
        let tombstone = RuntimeBlobDeletionTombstone(
            version: unsigned.version, tombstoneID: unsigned.tombstoneID,
            blobID: unsigned.blobID, manifestDigest: unsigned.manifestDigest,
            finalStateVersion: unsigned.finalStateVersion,
            deletionAuthorizationID: unsigned.deletionAuthorizationID,
            physicalDeletionConfirmed: true,
            physicalDeletionDisposition: unsigned.physicalDeletionDisposition,
            deletedAt: unsigned.deletedAt,
            tombstoneDigest: digest
        )
        let bytes = try RuntimeAttachmentCodec.encode(
            tombstone, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        try database.execute(
            """
            INSERT INTO runtime_blob_deletion_tombstones(
                tombstone_id, blob_id, manifest_digest, final_state_version,
                deletion_authorization_id, physical_deletion_confirmed,
                physical_deletion_disposition, tombstone_version,
                tombstone_payload, tombstone_digest, deleted_at_ms
            ) VALUES(?, ?, ?, ?, ?, 1, ?, 1, ?, ?, ?)
            """,
            bindings: [
                .text(tombstoneID.rawValue), .text(work.manifest.blobID.rawValue),
                .text(work.manifestDigest),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(work.lifecycle.stateVersion)),
                .text(work.deletionAuthorizationID), .text(proof.disposition.rawValue),
                .blob(bytes), .text(digest),
                .integer(try milliseconds(deletedAt)),
            ]
        )
        let quota = try database.query(
            """
            SELECT quota_owner_id, privacy_domain, plaintext_byte_count
            FROM runtime_blob_records WHERE blob_id = ? LIMIT 2
            """,
            bindings: [.text(work.manifest.blobID.rawValue)]
        )
        guard quota.count == 1,
              case let .text(ownerID)? = quota[0].value(named: "quota_owner_id"),
              case let .text(privacyRaw)? = quota[0].value(named: "privacy_domain"),
              case let .integer(storedBytes)? = quota[0].value(named: "plaintext_byte_count") else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let ledger = try database.execute(
            """
            UPDATE runtime_blob_quota_ledgers
            SET stored_bytes = stored_bytes - ?, state_version = state_version + 1,
                updated_at_ms = ?
            WHERE privacy_domain = ? AND owner_id = ? AND stored_bytes >= ?
              AND state_version < 9223372036854775807
            """,
            bindings: [
                .integer(storedBytes), .integer(try milliseconds(recordedAt)),
                .text(privacyRaw), .text(ownerID), .integer(storedBytes),
            ]
        )
        guard ledger == 1 else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
        guard let activeLease = try loadGCCurrentLease(
            blobID: lease.blobID, database: database
        ), activeLease.state == .active, activeLease.lease == lease else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let releasedLease = RuntimeBlobGCCurrentLeaseAuthority(
            version: activeLease.version, lease: activeLease.lease,
            leaseToken: activeLease.leaseToken, state: .released,
            authorityVersion: try RuntimeAttachmentCodec.nextSQLiteVersion(
                after: activeLease.authorityVersion
            ), releasedAt: recordedAt
        )
        try persistGCLeaseAuthority(
            prior: activeLease, current: releasedLease, transition: .released,
            occurredAt: recordedAt, database: database
        )
        try releaseDedupAuthority(blobID: work.manifest.blobID, database: database)
        return tombstone
    }

    static func apply(
        _ intent: RuntimeAttachmentCommandIntent,
        commandID: RuntimeCommandID,
        receiptID: RuntimeReceiptID,
        lineage: RuntimeAuthorityLineageReference,
        targetRevision: UInt64,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentMutationResult {
        try RuntimeAttachmentCodec.validate(intent)
        _ = try RuntimeAttachmentCodec.sqliteInteger(targetRevision)
        _ = try RuntimeAttachmentCodec.sqliteInteger(lineage.eventSequence)
        if intent.action == .replaceRevision {
            return try applyReplacement(
                intent, commandID: commandID, receiptID: receiptID, lineage: lineage,
                targetRevision: targetRevision, at: now, database: database
            )
        }
        guard let graph = try loadSnapshot(revisionID: intent.revisionID, database: database),
              graph.revision.attachmentID == intent.attachmentID,
              graph.revision.blobID == intent.blobID,
              graph.revision.manifestDigest == intent.manifestDigest,
              graph.revision.privacy == intent.privacy,
              graph.revision.provenance == intent.provenance,
              graph.lifecycle.stateVersion == intent.expectedLifecycleVersion else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let old = graph.lifecycle
        let newVersion = try RuntimeAttachmentCodec.nextSQLiteVersion(after: old.stateVersion)
        var producedReference: RuntimeAttachmentReference?
        var referenceTransitions: [RuntimeAttachmentReferenceHistory] = []
        let nextState: RuntimeAttachmentLifecycleState
        let nextCount: Int
        let linkKind: String

        switch intent.action {
        case .linkStaged:
            guard old.state == .staged || old.state == .orphaned || old.state == .referenced || old.state == .finalized,
                  let referenceID = intent.referenceID, let target = intent.target,
                  try hasUnresolvedQuarantine(blobID: intent.blobID, database: database) == false else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            let reference = RuntimeAttachmentReference(
                version: runtimeCanonicalAttachmentModelVersion, referenceID: referenceID,
                revisionID: intent.revisionID, target: target, targetRevision: targetRevision,
                state: .active, commandID: commandID, receiptID: receiptID,
                lineage: lineage, createdAt: now, removedAt: nil
            )
            let referenceHistory = try makeReferenceHistory(
                referenceID: reference.referenceID, revisionID: reference.revisionID,
                blobID: intent.blobID, from: nil, to: .active,
                commandID: commandID, receiptID: receiptID, lineage: lineage, at: now
            )
            try insertReferenceHistory(referenceHistory, database: database)
            try insertReference(reference, blobID: intent.blobID, database: database)
            referenceTransitions.append(referenceHistory)
            producedReference = reference
            nextCount = old.referenceCount + 1
            nextState = old.state == .finalized || (try hasAuthenticatedCompletedFinalization(
                blobID: intent.blobID, manifestDigest: intent.manifestDigest, database: database
            )) ? .finalized : .referenced
            if old.state == .orphaned {
                try restoreDedupAuthority(
                    manifest: graph.manifest, at: now, database: database
                )
            }
            linkKind = "reference"
        case .unlink:
            guard old.state == .referenced || old.state == .finalized || old.state == .quarantined,
                  let referenceID = intent.referenceID, let target = intent.target else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            let referenceHistory = try makeReferenceHistory(
                referenceID: referenceID, revisionID: intent.revisionID,
                blobID: intent.blobID, from: .active, to: .removed,
                commandID: commandID, receiptID: receiptID, lineage: lineage, at: now
            )
            try insertReferenceHistory(referenceHistory, database: database)
            let changed = try database.execute(
                """
                UPDATE runtime_attachment_references SET reference_state = 'removed', removed_at_ms = ?
                WHERE reference_id = ? AND revision_id = ? AND blob_id = ?
                  AND target_family = ? AND target_object_id = ? AND reference_state = 'active'
                """,
                bindings: [
                    .integer(try milliseconds(now)), .text(referenceID.rawValue), .text(intent.revisionID.rawValue),
                    .text(intent.blobID.rawValue), .text(target.kind.rawValue), .text(target.id.rawValue),
                ]
            )
            guard changed == 1, old.referenceCount > 0 else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            nextCount = old.referenceCount - 1
            nextState = if nextCount == 0 {
                old.state == .quarantined ? .quarantined : .orphaned
            } else {
                switch old.state {
                case .referenced: .referenced
                case .finalized: .finalized
                case .quarantined: .quarantined
                default: throw RuntimeCanonicalAttachmentError.lifecycleConflict
                }
            }
            linkKind = "unlink"
            referenceTransitions.append(referenceHistory)
        case .replaceRevision:
            throw RuntimeCanonicalAttachmentError.invalidRecord
        case .authorizeDeletion:
            guard old.referenceCount == 0,
                  old.state == .orphaned || old.state == .staged || old.state == .quarantined,
                  try hasActiveHold(blobID: intent.blobID, at: now, database: database) == false else {
                throw RuntimeCanonicalAttachmentError.referencesRemain
            }
            nextCount = 0
            nextState = .deletionPending
            linkKind = "deletion_authorization"
        case .quarantine:
            guard old.state != .quarantined, old.state != .deletionPending else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            guard let reason = intent.quarantineReason,
                  let evidence = intent.quarantineEvidenceFingerprint else {
                throw RuntimeCanonicalAttachmentError.invalidRecord
            }
            try database.execute(
                """
                INSERT INTO runtime_blob_quarantine(
                    quarantine_id, blob_id, reason_code, evidence_fingerprint,
                    observed_at_ms, resolved_at_ms, quarantine_version
                ) VALUES(?, ?, ?, ?, ?, NULL, 1)
                """,
                bindings: [
                    .text(evidence), .text(intent.blobID.rawValue), .text(reason.rawValue),
                    .text(evidence), .integer(try milliseconds(now)),
                ]
            )
            nextCount = old.referenceCount
            nextState = .quarantined
            linkKind = "quarantine"
        }

        let history = try makeHistory(
            blobID: intent.blobID, version: newVersion, from: old.state, to: nextState,
            fromCount: old.referenceCount, toCount: nextCount, commandID: commandID,
            receiptID: receiptID, lineage: lineage, at: now
        )
        try insertHistory(history, database: database)
        let next = RuntimeAttachmentCurrentLifecycle(
            version: runtimeCanonicalAttachmentModelVersion, blobID: intent.blobID,
            state: nextState, stateVersion: newVersion, referenceCount: nextCount,
            manifestDigest: intent.manifestDigest, retentionUntil: old.retentionUntil,
            quarantineReasonCode: intent.action == .quarantine
                ? intent.quarantineReason
                : (nextState == .quarantined ? old.quarantineReasonCode : nil),
            updatedAt: now
        )
        let nextBytes = try RuntimeAttachmentCodec.encode(next, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes)
        let changed = try database.execute(
            """
            UPDATE runtime_attachment_current_lifecycle SET
                lifecycle_state = ?, state_version = ?, reference_count = ?,
                quarantine_reason = ?, lifecycle_payload = ?, lifecycle_digest = ?, updated_at_ms = ?
            WHERE blob_id = ? AND state_version = ? AND lifecycle_digest = ?
            """,
            bindings: [
                .text(next.state.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(next.stateVersion)),
                .integer(Int64(next.referenceCount)),
                next.quarantineReasonCode.map { .text($0.rawValue) } ?? .null,
                .blob(nextBytes), .text(RuntimeAttachmentCodec.sha256(nextBytes)), .integer(try milliseconds(now)),
                .text(intent.blobID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(old.stateVersion)),
                .text(try RuntimeAttachmentCodec.digest(old, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes)),
            ]
        )
        guard changed == 1 else { throw RuntimeCanonicalAttachmentError.lifecycleConflict }
        if next.state == .orphaned || next.state == .quarantined || next.state == .deletionPending {
            try releaseDedupAuthority(blobID: next.blobID, database: database)
        }
        let revisionEvidence = RuntimeAttachmentReceiptRevisionEvidence(
            version: runtimeCanonicalAttachmentModelVersion, receiptID: receiptID,
            revisionID: intent.revisionID, blobID: intent.blobID,
            manifestDigest: intent.manifestDigest, linkKind: linkKind,
            referenceTransitionDigests: referenceTransitions.map(\.transitionDigest).sorted(),
            lifecycleTransitionDigest: history.transitionDigest
        )
        let revisionArtifactDigest = try RuntimeAttachmentCodec.digest(
            revisionEvidence, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let revisionEvidenceBytes = try RuntimeAttachmentCodec.encode(
            revisionEvidence, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        var receiptArtifacts = [RuntimeCommittedReceiptArtifactLink(
            kind: .attachmentRevision,
            stableID: "\(intent.revisionID.rawValue)#\(linkKind)",
            digest: revisionArtifactDigest
        )]
        try database.execute(
            """
            INSERT INTO runtime_attachment_receipt_links(
                receipt_id, revision_id, blob_id, manifest_digest, link_kind,
                artifact_payload, artifact_digest, link_version
            ) VALUES(?, ?, ?, ?, ?, ?, ?, 1)
            """,
            bindings: [
                .text(receiptID.rawValue), .text(intent.revisionID.rawValue), .text(intent.blobID.rawValue),
                .text(intent.manifestDigest), .text(linkKind), .blob(revisionEvidenceBytes),
                .text(revisionArtifactDigest),
            ]
        )
        if nextState == .referenced {
            let finalizationEvidence = RuntimeAttachmentFinalizationIntentEvidence(
                version: runtimeCanonicalAttachmentModelVersion, blobID: intent.blobID,
                manifestDigest: intent.manifestDigest, commandID: commandID,
                receiptID: receiptID, lineage: lineage,
                expectedStateVersion: next.stateVersion, createdAt: now
            )
            let intentDigest = try RuntimeAttachmentCodec.digest(
                finalizationEvidence, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            let intentBytes = try RuntimeAttachmentCodec.encode(
                finalizationEvidence, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            try database.execute(
                """
                INSERT INTO runtime_blob_finalization_intents(
                    blob_id, manifest_digest, command_id, receipt_id, terminal_event_sequence,
                    expected_state_version, intent_digest, marker_digest, finalized_at_ms,
                    intent_version, created_at_ms
                ) VALUES(?, ?, ?, ?, ?, ?, ?, NULL, NULL, 1, ?)
                ON CONFLICT(blob_id) DO NOTHING
                """,
                bindings: [
                    .text(intent.blobID.rawValue), .text(intent.manifestDigest), .text(commandID.rawValue),
                    .text(receiptID.rawValue),
                    .integer(try RuntimeAttachmentCodec.sqliteInteger(lineage.eventSequence)),
                    .integer(try RuntimeAttachmentCodec.sqliteInteger(next.stateVersion)),
                    .text(intentDigest), .integer(try milliseconds(now)),
                ]
            )
            let insertedIntent = try database.query(
                """
                SELECT 1 AS present FROM runtime_blob_finalization_intents
                WHERE blob_id = ? AND receipt_id = ? AND intent_digest = ? LIMIT 2
                """,
                bindings: [
                    .text(intent.blobID.rawValue), .text(receiptID.rawValue), .text(intentDigest),
                ]
            )
            if insertedIntent.count == 1 {
                try database.execute(
                    """
                    INSERT INTO runtime_attachment_receipt_links(
                        receipt_id, revision_id, blob_id, manifest_digest, link_kind,
                        artifact_payload, artifact_digest, link_version
                    ) VALUES(?, ?, ?, ?, 'finalization_intent', ?, ?, 1)
                    """,
                    bindings: [
                        .text(receiptID.rawValue), .text(intent.revisionID.rawValue),
                        .text(intent.blobID.rawValue), .text(intent.manifestDigest),
                        .blob(intentBytes), .text(intentDigest),
                    ]
                )
                receiptArtifacts.append(RuntimeCommittedReceiptArtifactLink(
                    kind: .attachmentFinalizationIntent,
                    stableID: intent.blobID.rawValue,
                    digest: intentDigest
                ))
            }
        }
        return RuntimeAttachmentMutationResult(
            intent: intent, lifecycle: next, reference: producedReference, history: history,
            referenceTransitions: referenceTransitions,
            replacedLifecycle: nil, replacedHistory: nil,
            receiptArtifacts: receiptArtifacts.sorted()
        )
    }

    private static func applyReplacement(
        _ intent: RuntimeAttachmentCommandIntent,
        commandID: RuntimeCommandID,
        receiptID: RuntimeReceiptID,
        lineage: RuntimeAuthorityLineageReference,
        targetRevision: UInt64,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentMutationResult {
        guard let replacedReferenceID = intent.replacesReferenceID,
              let replacedRevisionID = intent.replacesRevisionID,
              let replacedBlobID = intent.replacesBlobID,
              let replacedVersion = intent.expectedReplacedLifecycleVersion,
              let replacedManifestDigest = intent.replacesManifestDigest,
              let target = intent.target else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        guard let replacedGraph = try loadSnapshot(
                revisionID: replacedRevisionID, database: database
              ),
              let replacementGraph = try loadSnapshot(
                revisionID: intent.revisionID, database: database
              ),
              replacedGraph.revision.attachmentID == intent.attachmentID,
              replacedGraph.revision.blobID == replacedBlobID,
              replacedGraph.revision.manifestDigest == replacedManifestDigest,
              replacementGraph.revision.attachmentID == intent.attachmentID,
              replacementGraph.revision.blobID == intent.blobID,
              replacementGraph.revision.manifestDigest == intent.manifestDigest,
              replacementGraph.revision.privacy == intent.privacy,
              replacementGraph.revision.provenance == intent.provenance else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let unlink = RuntimeAttachmentCommandIntent(
            version: intent.version, action: .unlink,
            attachmentID: intent.attachmentID, revisionID: replacedRevisionID,
            blobID: replacedBlobID, referenceID: replacedReferenceID,
            replacesReferenceID: nil, replacesRevisionID: nil, replacesBlobID: nil,
            target: target, expectedLifecycleVersion: replacedVersion,
            expectedReplacedLifecycleVersion: nil, manifestDigest: replacedManifestDigest,
            replacesManifestDigest: nil, quarantineReason: nil,
            quarantineEvidenceFingerprint: nil,
            privacy: replacedGraph.revision.privacy, provenance: replacedGraph.revision.provenance
        )
        let removed = try apply(
            unlink, commandID: commandID, receiptID: receiptID, lineage: lineage,
            targetRevision: targetRevision, at: now, database: database
        )
        let linkExpectedVersion = replacedBlobID == intent.blobID
            ? removed.lifecycle.stateVersion
            : intent.expectedLifecycleVersion
        let link = RuntimeAttachmentCommandIntent(
            version: intent.version, action: .linkStaged,
            attachmentID: intent.attachmentID, revisionID: intent.revisionID,
            blobID: intent.blobID, referenceID: intent.referenceID,
            replacesReferenceID: nil, replacesRevisionID: nil, replacesBlobID: nil,
            target: target, expectedLifecycleVersion: linkExpectedVersion,
            expectedReplacedLifecycleVersion: nil, manifestDigest: intent.manifestDigest,
            replacesManifestDigest: nil, quarantineReason: nil,
            quarantineEvidenceFingerprint: nil,
            privacy: intent.privacy, provenance: intent.provenance
        )
        let linked = try apply(
            link, commandID: commandID, receiptID: receiptID, lineage: lineage,
            targetRevision: targetRevision, at: now, database: database
        )
        return RuntimeAttachmentMutationResult(
            intent: intent, lifecycle: linked.lifecycle, reference: linked.reference,
            history: linked.history,
            referenceTransitions: removed.referenceTransitions + linked.referenceTransitions,
            replacedLifecycle: removed.lifecycle, replacedHistory: removed.history,
            receiptArtifacts: (removed.receiptArtifacts + linked.receiptArtifacts).sorted()
        )
    }

    static func loadSnapshot(
        revisionID: RuntimeAttachmentRevisionID,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentAuthoritySnapshot? {
        var budget = RuntimeAttachmentDecodedByteBudget(
            maximumBytes: RuntimeAttachmentLimits.maximumPageBytes
        )
        return try loadSnapshot(
            revisionID: revisionID, budget: &budget, database: database
        )
    }

    private static func loadSnapshot(
        revisionID: RuntimeAttachmentRevisionID,
        budget: inout RuntimeAttachmentDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentAuthoritySnapshot? {
        let rows = try budget.query(
            """
            SELECT v.attachment_id, v.attachment_revision, v.blob_id,
                   v.content_version, v.content_payload, v.content_digest, v.created_at_ms,
                   i.privacy AS identity_privacy,
                   b.privacy_domain, b.dedup_policy, b.keyed_content_address,
                   b.manifest_version, b.manifest_payload, b.manifest_digest,
                   b.plaintext_byte_count, b.ciphertext_byte_count, b.protection_class,
                   b.opaque_relative_directory, b.created_at_ms AS manifest_created_at_ms,
                   k.wrapping_key_id, k.wrapping_key_version, k.envelope_version,
                   k.algorithm AS envelope_algorithm, k.envelope_payload, k.envelope_digest,
                   s.lifecycle_state, s.state_version, s.reference_count,
                   s.retention_until_ms, s.quarantine_reason, s.lifecycle_version,
                   s.lifecycle_payload, s.lifecycle_digest, s.updated_at_ms
            FROM runtime_attachment_revisions AS v
            JOIN runtime_attachment_identities AS i ON i.attachment_id = v.attachment_id
            JOIN runtime_blob_records AS b
              ON b.blob_id = v.blob_id AND b.manifest_digest = v.manifest_digest
            JOIN runtime_blob_key_envelopes AS k ON k.blob_id = b.blob_id
            JOIN runtime_attachment_current_lifecycle AS s
              ON s.blob_id = b.blob_id AND s.manifest_digest = b.manifest_digest
            WHERE v.revision_id = ? LIMIT 2
            """,
            bindings: [.text(revisionID.rawValue)], database: database
        )
        guard rows.count <= 1 else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
        guard let row = rows.first else { return nil }
        guard case let .blob(revisionBytes)? = row.value(named: "content_payload"),
              case let .text(revisionDigest)? = row.value(named: "content_digest"),
              RuntimeAttachmentCodec.sha256(revisionBytes) == revisionDigest,
              case let .blob(manifestBytes)? = row.value(named: "manifest_payload"),
              case let .text(manifestDigest)? = row.value(named: "manifest_digest"),
              RuntimeAttachmentCodec.sha256(manifestBytes) == manifestDigest,
              case let .blob(envelopeBytes)? = row.value(named: "envelope_payload"),
              case let .text(envelopeDigest)? = row.value(named: "envelope_digest"),
              case let .blob(lifecycleBytes)? = row.value(named: "lifecycle_payload"),
              case let .text(lifecycleDigest)? = row.value(named: "lifecycle_digest"),
              RuntimeAttachmentCodec.sha256(lifecycleBytes) == lifecycleDigest else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let revision = try RuntimeAttachmentCodec.decode(
            RuntimeAttachmentRevision.self, bytes: revisionBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let manifest = try RuntimeAttachmentCodec.decode(
            RuntimeBlobManifestAuthority.self, bytes: manifestBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let envelope = try RuntimeAttachmentCodec.decode(
            RuntimeBlobKeyEnvelope.self, bytes: envelopeBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumEnvelopeBytes
        )
        let lifecycle = try RuntimeAttachmentCodec.decode(
            RuntimeAttachmentCurrentLifecycle.self, bytes: lifecycleBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        try RuntimeAttachmentCodec.validate(revision)
        try RuntimeAttachmentCodec.validate(manifest)
        try RuntimeAttachmentCodec.validate(envelope)
        try RuntimeAttachmentCodec.validate(lifecycle)
        guard revision.revisionID == revisionID,
              row.value(named: "attachment_id") == .text(revision.attachmentID.rawValue),
              row.value(named: "attachment_revision") == .integer(
                try RuntimeAttachmentCodec.sqliteInteger(revision.revision)
              ),
              row.value(named: "blob_id") == .text(revision.blobID.rawValue),
              row.value(named: "content_version") == .integer(Int64(revision.version)),
              row.value(named: "created_at_ms") == .integer(try milliseconds(revision.createdAt)),
              row.value(named: "identity_privacy") == .text(revision.privacy.rawValue),
              row.value(named: "privacy_domain") == .text(manifest.privacyDomain.rawValue),
              row.value(named: "dedup_policy") == .text(manifest.dedupPolicy.rawValue),
              row.value(named: "keyed_content_address") == .text(
                manifest.keyedContentAddress.rawValue
              ),
              row.value(named: "manifest_version") == .integer(Int64(manifest.formatVersion)),
              row.value(named: "plaintext_byte_count") == .integer(manifest.plaintextByteCount),
              row.value(named: "ciphertext_byte_count") == .integer(manifest.ciphertextByteCount),
              row.value(named: "protection_class") == .text(manifest.protectionClass.rawValue),
              row.value(named: "opaque_relative_directory") == .text(
                manifest.opaqueRelativeDirectory
              ),
              row.value(named: "manifest_created_at_ms") == .integer(
                try milliseconds(manifest.createdAt)
              ),
              row.value(named: "wrapping_key_id") == .text(envelope.wrappingKeyID.rawValue),
              row.value(named: "wrapping_key_version") == .integer(
                Int64(envelope.wrappingKeyVersion)
              ),
              row.value(named: "envelope_version") == .integer(Int64(envelope.version)),
              row.value(named: "envelope_algorithm") == .text(envelope.algorithm),
              try lifecycleScalarsMatch(lifecycle, row: row),
              revision.blobID == manifest.blobID,
              envelope.blobID == manifest.blobID,
              lifecycle.blobID == manifest.blobID,
              revision.manifestDigest == manifestDigest,
              lifecycle.manifestDigest == manifestDigest,
              envelope.envelopeDigest == envelopeDigest else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let counts = try budget.query(
            """
            SELECT COUNT(*) AS active_count FROM runtime_attachment_references
            WHERE blob_id = ? AND reference_state = 'active'
            """,
            bindings: [.text(manifest.blobID.rawValue)], database: database
        )
        guard counts.count == 1,
              counts[0].value(named: "active_count") == .integer(
                Int64(lifecycle.referenceCount)
              ) else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let latestRows = try budget.query(
            """
            SELECT h.history_id, h.state_version, h.from_state, h.to_state,
                   h.from_reference_count, h.to_reference_count,
                   h.command_id, h.receipt_id, h.terminal_event_sequence,
                   h.system_authority_kind, h.system_authority_id,
                   h.system_evidence_fingerprint,
                   h.history_version, h.history_payload, h.history_digest,
                   h.occurred_at_ms, e.event_id, e.event_hash,
                   c.receipt_id AS authenticated_receipt_id
            FROM runtime_attachment_lifecycle_history AS h
            LEFT JOIN runtime_semantic_events AS e ON e.sequence = h.terminal_event_sequence
            LEFT JOIN runtime_committed_receipt_cores AS c
              ON c.receipt_id = h.receipt_id AND c.command_id = h.command_id
             AND c.terminal_event_sequence = h.terminal_event_sequence
             AND c.terminal_event_id = e.event_id AND c.terminal_event_hash = e.event_hash
            WHERE h.blob_id = ? ORDER BY h.state_version DESC LIMIT 1
            """,
            bindings: [.text(manifest.blobID.rawValue)], database: database
        )
        guard latestRows.count == 1,
              case let .blob(historyBytes)? = latestRows[0].value(named: "history_payload"),
              case let .text(historyDigest)? = latestRows[0].value(named: "history_digest") else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let latest = try RuntimeAttachmentCodec.decode(
            RuntimeAttachmentLifecycleHistory.self, bytes: historyBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        guard latest.transitionDigest == historyDigest,
              try RuntimeAttachmentCodec.transitionDigest(latest) == historyDigest,
              try lifecycleHistoryScalarsMatch(latest, blobID: manifest.blobID, row: latestRows[0]),
              latest.blobID == manifest.blobID,
              latest.stateVersion == lifecycle.stateVersion,
              latest.toState == lifecycle.state,
              latest.toReferenceCount == lifecycle.referenceCount else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let tombstone = try loadTombstone(
            blobID: manifest.blobID, budget: &budget, database: database
        )
        return RuntimeAttachmentAuthoritySnapshot(
            revision: revision, manifest: manifest, envelope: envelope,
            lifecycle: lifecycle, tombstone: tombstone
        )
    }

    static func load(
        revisionID: RuntimeAttachmentRevisionID,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentAuthorityGraph? {
        var budget = RuntimeAttachmentDecodedByteBudget(
            maximumBytes: RuntimeAttachmentLimits.maximumPageBytes
        )
        return try load(revisionID: revisionID, budget: &budget, database: database)
    }

    private static func load(
        revisionID: RuntimeAttachmentRevisionID,
        budget: inout RuntimeAttachmentDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentAuthorityGraph? {
        let rows = try budget.query(
            """
            SELECT v.attachment_id, v.attachment_revision, v.blob_id,
                   v.content_version, v.content_payload, v.content_digest, v.created_at_ms,
                   i.privacy AS identity_privacy,
                   b.privacy_domain, b.dedup_policy, b.keyed_content_address,
                   b.manifest_version, b.manifest_payload, b.manifest_digest,
                   b.plaintext_byte_count, b.ciphertext_byte_count, b.protection_class,
                   b.opaque_relative_directory, b.created_at_ms AS manifest_created_at_ms,
                   k.wrapping_key_id, k.wrapping_key_version, k.envelope_version,
                   k.algorithm AS envelope_algorithm, k.envelope_payload, k.envelope_digest,
                   s.lifecycle_state, s.state_version, s.reference_count,
                   s.retention_until_ms, s.quarantine_reason, s.lifecycle_version,
                   s.lifecycle_payload, s.lifecycle_digest, s.updated_at_ms
            FROM runtime_attachment_revisions AS v
            JOIN runtime_attachment_identities AS i ON i.attachment_id = v.attachment_id
            JOIN runtime_blob_records AS b
              ON b.blob_id = v.blob_id AND b.manifest_digest = v.manifest_digest
            JOIN runtime_blob_key_envelopes AS k ON k.blob_id = b.blob_id
            JOIN runtime_attachment_current_lifecycle AS s
              ON s.blob_id = b.blob_id AND s.manifest_digest = b.manifest_digest
            WHERE v.revision_id = ? LIMIT 2
            """,
            bindings: [.text(revisionID.rawValue)],
            database: database
        )
        guard rows.count <= 1 else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
        guard let row = rows.first else { return nil }
        guard case let .blob(revisionBytes)? = row.value(named: "content_payload"),
              case let .text(revisionDigest)? = row.value(named: "content_digest"),
              RuntimeAttachmentCodec.sha256(revisionBytes) == revisionDigest,
              case let .blob(manifestBytes)? = row.value(named: "manifest_payload"),
              case let .text(manifestDigest)? = row.value(named: "manifest_digest"),
              RuntimeAttachmentCodec.sha256(manifestBytes) == manifestDigest,
              case let .blob(envelopeBytes)? = row.value(named: "envelope_payload"),
              case let .text(envelopeDigest)? = row.value(named: "envelope_digest"),
              case let .blob(lifecycleBytes)? = row.value(named: "lifecycle_payload"),
              case let .text(lifecycleDigest)? = row.value(named: "lifecycle_digest"),
              RuntimeAttachmentCodec.sha256(lifecycleBytes) == lifecycleDigest else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let revision = try RuntimeAttachmentCodec.decode(
            RuntimeAttachmentRevision.self, bytes: revisionBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let manifest = try RuntimeAttachmentCodec.decode(
            RuntimeBlobManifestAuthority.self, bytes: manifestBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let envelope = try RuntimeAttachmentCodec.decode(
            RuntimeBlobKeyEnvelope.self, bytes: envelopeBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumEnvelopeBytes
        )
        guard envelope.envelopeDigest == envelopeDigest else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let lifecycle = try RuntimeAttachmentCodec.decode(
            RuntimeAttachmentCurrentLifecycle.self, bytes: lifecycleBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        try RuntimeAttachmentCodec.validate(revision)
        try RuntimeAttachmentCodec.validate(manifest)
        try RuntimeAttachmentCodec.validate(envelope)
        try RuntimeAttachmentCodec.validate(lifecycle)
        guard revision.revisionID == revisionID,
              row.value(named: "attachment_id") == .text(revision.attachmentID.rawValue),
              row.value(named: "attachment_revision") == .integer(
                try RuntimeAttachmentCodec.sqliteInteger(revision.revision)
              ),
              row.value(named: "blob_id") == .text(revision.blobID.rawValue),
              row.value(named: "content_version") == .integer(Int64(revision.version)),
              row.value(named: "created_at_ms") == .integer(try milliseconds(revision.createdAt)),
              row.value(named: "identity_privacy") == .text(revision.privacy.rawValue),
              row.value(named: "privacy_domain") == .text(manifest.privacyDomain.rawValue),
              row.value(named: "dedup_policy") == .text(manifest.dedupPolicy.rawValue),
              row.value(named: "keyed_content_address") == .text(manifest.keyedContentAddress.rawValue),
              row.value(named: "manifest_version") == .integer(Int64(manifest.formatVersion)),
              row.value(named: "plaintext_byte_count") == .integer(manifest.plaintextByteCount),
              row.value(named: "ciphertext_byte_count") == .integer(manifest.ciphertextByteCount),
              row.value(named: "protection_class") == .text(manifest.protectionClass.rawValue),
              row.value(named: "opaque_relative_directory") == .text(manifest.opaqueRelativeDirectory),
              row.value(named: "manifest_created_at_ms") == .integer(
                try milliseconds(manifest.createdAt)
              ),
              row.value(named: "wrapping_key_id") == .text(envelope.wrappingKeyID.rawValue),
              row.value(named: "wrapping_key_version") == .integer(
                Int64(envelope.wrappingKeyVersion)
              ),
              row.value(named: "envelope_version") == .integer(Int64(envelope.version)),
              row.value(named: "envelope_algorithm") == .text(envelope.algorithm),
              try lifecycleScalarsMatch(lifecycle, row: row),
              revision.blobID == manifest.blobID,
              lifecycle.blobID == manifest.blobID, revision.manifestDigest == manifestDigest,
              lifecycle.manifestDigest == manifestDigest else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let references = try loadReferences(
            blobID: manifest.blobID, budget: &budget, database: database
        )
        let referenceHistory = try loadReferenceHistory(
            blobID: manifest.blobID, budget: &budget, database: database
        )
        let history = try loadHistory(
            blobID: manifest.blobID, budget: &budget, database: database
        )
        let holds = try loadHolds(
            blobID: manifest.blobID, budget: &budget, database: database
        )
        let tombstone = try loadTombstone(
            blobID: manifest.blobID, budget: &budget, database: database
        )
        guard references.filter({ $0.state == .active }).count == lifecycle.referenceCount,
              references.allSatisfy({ reference in
                  referenceHistory.last(where: { $0.referenceID == reference.referenceID })?.toState == reference.state
              }),
              history.last?.stateVersion == lifecycle.stateVersion,
              history.last?.toState == lifecycle.state,
              history.last?.toReferenceCount == lifecycle.referenceCount else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return RuntimeAttachmentAuthorityGraph(
            revision: revision, manifest: manifest, envelope: envelope, lifecycle: lifecycle,
            references: references, referenceHistory: referenceHistory, history: history, holds: holds,
            tombstone: tombstone
        )
    }

    private static func lifecycleScalarsMatch(
        _ value: RuntimeAttachmentCurrentLifecycle,
        row: SQLiteRow
    ) throws -> Bool {
        guard row.value(named: "lifecycle_state") == .text(value.state.rawValue),
              row.value(named: "state_version") == .integer(
                try RuntimeAttachmentCodec.sqliteInteger(value.stateVersion)
              ),
              row.value(named: "reference_count") == .integer(Int64(value.referenceCount)),
              row.value(named: "lifecycle_version") == .integer(Int64(value.version)),
              row.value(named: "updated_at_ms") == .integer(try milliseconds(value.updatedAt)) else {
            return false
        }
        switch (value.retentionUntil, row.value(named: "retention_until_ms")) {
        case (nil, .null?): break
        case let (date?, .integer(raw)?): guard try milliseconds(date) == raw else { return false }
        default: return false
        }
        switch (value.quarantineReasonCode, row.value(named: "quarantine_reason")) {
        case (nil, .null?): break
        case let (reason?, .text(raw)?): guard reason.rawValue == raw else { return false }
        default: return false
        }
        return true
    }

    private static func insertReference(
        _ value: RuntimeAttachmentReference,
        blobID: RuntimeBlobID,
        database: isolated SQLiteDatabase
    ) throws {
        _ = try RuntimeAttachmentCodec.sqliteInteger(value.targetRevision)
        _ = try RuntimeAttachmentCodec.sqliteInteger(value.lineage.eventSequence)
        let bytes = try RuntimeAttachmentCodec.encode(value, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes)
        try database.execute(
            """
            INSERT INTO runtime_attachment_references(
                reference_id, revision_id, blob_id, target_family, target_object_id,
                target_revision, reference_state, command_id, receipt_id, terminal_event_sequence,
                reference_version, reference_payload, reference_digest, created_at_ms, removed_at_ms
            ) VALUES(?, ?, ?, ?, ?, ?, 'active', ?, ?, ?, 1, ?, ?, ?, NULL)
            """,
            bindings: [
                .text(value.referenceID.rawValue), .text(value.revisionID.rawValue), .text(blobID.rawValue),
                .text(value.target.kind.rawValue), .text(value.target.id.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(value.targetRevision)),
                .text(value.commandID.rawValue), .text(value.receiptID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(value.lineage.eventSequence)),
                .blob(bytes), .text(RuntimeAttachmentCodec.sha256(bytes)),
                .integer(try milliseconds(value.createdAt)),
            ]
        )
    }

    private static func insertReferenceHistory(
        _ value: RuntimeAttachmentReferenceHistory,
        database: isolated SQLiteDatabase
    ) throws {
        _ = try RuntimeAttachmentCodec.sqliteInteger(value.lineage.eventSequence)
        let bytes = try RuntimeAttachmentCodec.encode(
            value, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        try database.execute(
            """
            INSERT INTO runtime_attachment_reference_history(
                history_id, reference_id, revision_id, blob_id, from_state, to_state,
                command_id, receipt_id, terminal_event_sequence, history_version,
                history_payload, history_digest, occurred_at_ms
            ) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)
            """,
            bindings: [
                .text(value.historyID.rawValue), .text(value.referenceID.rawValue),
                .text(value.revisionID.rawValue), .text(value.blobID.rawValue),
                value.fromState.map { .text($0.rawValue) } ?? .null, .text(value.toState.rawValue),
                .text(value.commandID.rawValue), .text(value.receiptID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(value.lineage.eventSequence)), .blob(bytes),
                .text(value.transitionDigest), .integer(try milliseconds(value.occurredAt)),
            ]
        )
    }

    private static func makeReferenceHistory(
        referenceID: RuntimeAttachmentReferenceID,
        revisionID: RuntimeAttachmentRevisionID,
        blobID: RuntimeBlobID,
        from: RuntimeAttachmentReferenceState?,
        to: RuntimeAttachmentReferenceState,
        commandID: RuntimeCommandID,
        receiptID: RuntimeReceiptID,
        lineage: RuntimeAuthorityLineageReference,
        at: Date
    ) throws -> RuntimeAttachmentReferenceHistory {
        let seed = [
            referenceID.rawValue, revisionID.rawValue, blobID.rawValue,
            from?.rawValue ?? "", to.rawValue, commandID.rawValue, receiptID.rawValue,
            lineage.eventHash, String(try milliseconds(at)),
        ].joined(separator: "\u{0}")
        guard let historyID = RuntimeAttachmentReferenceHistoryID(
            rawValue: RuntimeAttachmentCodec.sha256(Data(seed.utf8))
        ) else { throw RuntimeCanonicalAttachmentError.invalidIdentity }
        let unsigned = RuntimeAttachmentReferenceHistory(
            version: runtimeCanonicalAttachmentModelVersion, historyID: historyID,
            referenceID: referenceID, revisionID: revisionID, blobID: blobID,
            fromState: from, toState: to, commandID: commandID, receiptID: receiptID,
            lineage: lineage, occurredAt: at, transitionDigest: String(repeating: "0", count: 64)
        )
        return RuntimeAttachmentReferenceHistory(
            version: unsigned.version, historyID: unsigned.historyID,
            referenceID: unsigned.referenceID, revisionID: unsigned.revisionID,
            blobID: unsigned.blobID, fromState: unsigned.fromState, toState: unsigned.toState,
            commandID: unsigned.commandID, receiptID: unsigned.receiptID,
            lineage: unsigned.lineage, occurredAt: unsigned.occurredAt,
            transitionDigest: try RuntimeAttachmentCodec.referenceTransitionDigest(unsigned)
        )
    }

    private static func insertHistory(
        _ value: RuntimeAttachmentLifecycleHistory,
        finalizationCompletionID: String? = nil,
        database: isolated SQLiteDatabase
    ) throws {
        guard finalizationCompletionID.map(RuntimeStoreManifestCodec.isSHA256Hex) ?? true else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let stateVersion = try RuntimeAttachmentCodec.sqliteInteger(value.stateVersion)
        let eventSequenceBinding: SQLiteBinding = try value.lineage.map {
            .integer(try RuntimeAttachmentCodec.sqliteInteger($0.eventSequence))
        } ?? .null
        let bytes = try RuntimeAttachmentCodec.encode(value, maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes)
        try database.execute(
            """
            INSERT INTO runtime_attachment_lifecycle_history(
                history_id, blob_id, state_version, from_state, to_state,
                from_reference_count, to_reference_count, command_id, receipt_id,
                terminal_event_sequence, finalization_completion_id,
                system_authority_kind, system_authority_id,
                system_evidence_fingerprint, history_version, history_payload,
                history_digest, occurred_at_ms
            ) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?)
            """,
            bindings: [
                .text(value.historyID.rawValue), .text(value.blobID.rawValue), .integer(stateVersion),
                value.fromState.map { .text($0.rawValue) } ?? .null, .text(value.toState.rawValue),
                value.fromReferenceCount.map { .integer(Int64($0)) } ?? .null, .integer(Int64(value.toReferenceCount)),
                value.commandID.map { .text($0.rawValue) } ?? .null,
                value.receiptID.map { .text($0.rawValue) } ?? .null,
                eventSequenceBinding,
                finalizationCompletionID.map(SQLiteBinding.text) ?? .null,
                value.systemAuthority.map { .text($0.kind.rawValue) } ?? .null,
                value.systemAuthority.map { .text($0.authorityID) } ?? .null,
                value.systemAuthority.map { .text($0.evidenceFingerprint) } ?? .null,
                .blob(bytes), .text(value.transitionDigest), .integer(try milliseconds(value.occurredAt)),
            ]
        )
    }

    private static func makeHistory(
        blobID: RuntimeBlobID, version: UInt64,
        from: RuntimeAttachmentLifecycleState?, to: RuntimeAttachmentLifecycleState,
        fromCount: Int?, toCount: Int, commandID: RuntimeCommandID?, receiptID: RuntimeReceiptID?,
        lineage: RuntimeAuthorityLineageReference?,
        systemAuthority: RuntimeAttachmentSystemTransitionAuthority? = nil,
        at: Date
    ) throws -> RuntimeAttachmentLifecycleHistory {
        _ = try RuntimeAttachmentCodec.sqliteInteger(version)
        if let lineage {
            _ = try RuntimeAttachmentCodec.sqliteInteger(lineage.eventSequence)
        }
        guard RuntimeAttachmentCodec.allowsLifecycleTransition(
            from: from, to: to, fromReferenceCount: fromCount,
            toReferenceCount: toCount
        ) else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        guard systemAuthority.map({
            $0.authorityID.isEmpty == false && $0.authorityID.utf8.count <= 1_024 &&
                RuntimeStoreManifestCodec.isSHA256Hex($0.evidenceFingerprint)
        }) ?? true,
              (from == nil
                ? (commandID == nil && receiptID == nil && lineage == nil && systemAuthority == nil)
                : ((commandID != nil && receiptID != nil && lineage != nil) != (systemAuthority != nil))) else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let seed = [
            blobID.rawValue, String(version), from?.rawValue ?? "", to.rawValue,
            fromCount.map(String.init) ?? "", String(toCount), commandID?.rawValue ?? "",
            receiptID?.rawValue ?? "", lineage?.eventHash ?? "",
            systemAuthority?.kind.rawValue ?? "", systemAuthority?.authorityID ?? "",
            systemAuthority?.evidenceFingerprint ?? "", String(try milliseconds(at)),
        ].joined(separator: "\u{0}")
        let historyID = RuntimeAttachmentHistoryID(rawValue: RuntimeAttachmentCodec.sha256(Data(seed.utf8)))!
        let unsigned = RuntimeAttachmentLifecycleHistory(
            version: runtimeCanonicalAttachmentModelVersion, historyID: historyID, blobID: blobID,
            stateVersion: version, fromState: from, toState: to,
            fromReferenceCount: fromCount, toReferenceCount: toCount,
            commandID: commandID, receiptID: receiptID, lineage: lineage,
            systemAuthority: systemAuthority,
            occurredAt: at, transitionDigest: String(repeating: "0", count: 64)
        )
        return RuntimeAttachmentLifecycleHistory(
            version: unsigned.version, historyID: unsigned.historyID, blobID: unsigned.blobID,
            stateVersion: unsigned.stateVersion, fromState: unsigned.fromState, toState: unsigned.toState,
            fromReferenceCount: unsigned.fromReferenceCount, toReferenceCount: unsigned.toReferenceCount,
            commandID: unsigned.commandID, receiptID: unsigned.receiptID, lineage: unsigned.lineage,
            systemAuthority: unsigned.systemAuthority,
            occurredAt: unsigned.occurredAt,
            transitionDigest: try RuntimeAttachmentCodec.transitionDigest(unsigned)
        )
    }

    static func referencePage(
        revisionID: RuntimeAttachmentRevisionID,
        after referenceID: RuntimeAttachmentReferenceID?,
        limit: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentReferencePage {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        var budget = RuntimeAttachmentDecodedByteBudget(
            maximumBytes: RuntimeAttachmentLimits.maximumPageBytes
        )
        guard let snapshot = try loadSnapshot(
            revisionID: revisionID, budget: &budget, database: database
        ) else { throw RuntimeCanonicalAttachmentError.invalidRecord }
        let rows = try budget.query(
            """
            SELECT a.reference_id, a.revision_id, a.target_family, a.target_object_id,
                   a.target_revision, a.reference_state, a.command_id, a.receipt_id,
                   a.terminal_event_sequence, a.reference_version, a.reference_payload,
                   a.reference_digest, a.created_at_ms, a.removed_at_ms,
                   e.event_id, e.event_hash
            FROM runtime_attachment_references AS a
            JOIN runtime_semantic_events AS e ON e.sequence = a.terminal_event_sequence
            JOIN runtime_committed_receipt_cores AS c
              ON c.receipt_id = a.receipt_id AND c.command_id = a.command_id
             AND c.terminal_event_sequence = a.terminal_event_sequence
             AND c.terminal_event_id = e.event_id AND c.terminal_event_hash = e.event_hash
            WHERE a.revision_id = ? AND a.blob_id = ?
              AND (? IS NULL OR a.reference_id > ?)
            ORDER BY a.reference_id LIMIT ?
            """,
            bindings: [
                .text(revisionID.rawValue), .text(snapshot.manifest.blobID.rawValue),
                referenceID.map { .text($0.rawValue) } ?? .null,
                referenceID.map { .text($0.rawValue) } ?? .null,
                .integer(Int64(limit + 1)),
            ],
            database: database
        )
        let hasMore = rows.count > limit
        let values = try rows.prefix(limit).map(decodeReferenceRow)
        return RuntimeAttachmentReferencePage(
            values: values,
            nextReferenceID: hasMore ? values.last?.referenceID : nil
        )
    }

    static func lifecycleHistoryPage(
        revisionID: RuntimeAttachmentRevisionID,
        afterStateVersion: UInt64?,
        limit: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentLifecycleHistoryPage {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize,
              afterStateVersion.map({ $0 <= UInt64(Int64.max) }) ?? true else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        var budget = RuntimeAttachmentDecodedByteBudget(
            maximumBytes: RuntimeAttachmentLimits.maximumPageBytes
        )
        guard let snapshot = try loadSnapshot(
            revisionID: revisionID, budget: &budget, database: database
        ) else { throw RuntimeCanonicalAttachmentError.invalidRecord }
        let after = afterStateVersion.map(Int64.init)
        let rows = try budget.query(
            """
            SELECT h.history_id, h.state_version, h.from_state, h.to_state,
                   h.from_reference_count, h.to_reference_count,
                   h.command_id, h.receipt_id, h.terminal_event_sequence,
                   h.system_authority_kind, h.system_authority_id,
                   h.system_evidence_fingerprint,
                   h.history_version, h.history_payload, h.history_digest,
                   h.occurred_at_ms, e.event_id, e.event_hash,
                   c.receipt_id AS authenticated_receipt_id
            FROM runtime_attachment_lifecycle_history AS h
            LEFT JOIN runtime_semantic_events AS e ON e.sequence = h.terminal_event_sequence
            LEFT JOIN runtime_committed_receipt_cores AS c
              ON c.receipt_id = h.receipt_id AND c.command_id = h.command_id
             AND c.terminal_event_sequence = h.terminal_event_sequence
             AND c.terminal_event_id = e.event_id AND c.terminal_event_hash = e.event_hash
            WHERE h.blob_id = ? AND (? IS NULL OR h.state_version > ?)
            ORDER BY h.state_version LIMIT ?
            """,
            bindings: [
                .text(snapshot.manifest.blobID.rawValue),
                after.map { .integer($0) } ?? .null,
                after.map { .integer($0) } ?? .null,
                .integer(Int64(limit + 1)),
            ],
            database: database
        )
        let hasMore = rows.count > limit
        let values = try rows.prefix(limit).map {
            try decodeLifecycleHistoryRow($0, blobID: snapshot.manifest.blobID)
        }
        return RuntimeAttachmentLifecycleHistoryPage(
            values: values,
            nextStateVersion: hasMore ? values.last?.stateVersion : nil
        )
    }

    static func referenceHistoryPage(
        revisionID: RuntimeAttachmentRevisionID,
        after cursor: RuntimeAttachmentReferenceHistoryCursor?,
        limit: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentReferenceHistoryPage {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        var budget = RuntimeAttachmentDecodedByteBudget(
            maximumBytes: RuntimeAttachmentLimits.maximumPageBytes
        )
        guard let snapshot = try loadSnapshot(
            revisionID: revisionID, budget: &budget, database: database
        ) else { throw RuntimeCanonicalAttachmentError.invalidRecord }
        let occurredAt = try cursor.map { try milliseconds($0.occurredAt) }
        let rows = try budget.query(
            """
            SELECT h.history_id, h.reference_id, h.revision_id, h.from_state, h.to_state,
                   h.command_id, h.receipt_id, h.terminal_event_sequence,
                   h.history_version, h.history_payload, h.history_digest,
                   h.occurred_at_ms, e.event_id, e.event_hash,
                   c.receipt_id AS authenticated_receipt_id
            FROM runtime_attachment_reference_history AS h
            JOIN runtime_semantic_events AS e ON e.sequence = h.terminal_event_sequence
            JOIN runtime_committed_receipt_cores AS c
              ON c.receipt_id = h.receipt_id AND c.command_id = h.command_id
             AND c.terminal_event_sequence = h.terminal_event_sequence
             AND c.terminal_event_id = e.event_id AND c.terminal_event_hash = e.event_hash
            WHERE h.revision_id = ? AND h.blob_id = ?
              AND (? IS NULL OR h.occurred_at_ms > ?
                   OR (h.occurred_at_ms = ? AND h.history_id > ?))
            ORDER BY h.occurred_at_ms, h.history_id LIMIT ?
            """,
            bindings: [
                .text(revisionID.rawValue), .text(snapshot.manifest.blobID.rawValue),
                occurredAt.map { .integer($0) } ?? .null,
                occurredAt.map { .integer($0) } ?? .null,
                occurredAt.map { .integer($0) } ?? .null,
                cursor.map { .text($0.historyID.rawValue) } ?? .null,
                .integer(Int64(limit + 1)),
            ],
            database: database
        )
        let hasMore = rows.count > limit
        let values = try rows.prefix(limit).map {
            try decodeReferenceHistoryRow($0, blobID: snapshot.manifest.blobID)
        }
        let nextCursor = hasMore ? values.last.map {
            RuntimeAttachmentReferenceHistoryCursor(
                occurredAt: $0.occurredAt, historyID: $0.historyID
            )
        } : nil
        return RuntimeAttachmentReferenceHistoryPage(values: values, nextCursor: nextCursor)
    }

    private static func decodeReferenceRow(_ row: SQLiteRow) throws -> RuntimeAttachmentReference {
        guard case let .blob(bytes)? = row.value(named: "reference_payload"),
              case let .text(digest)? = row.value(named: "reference_digest"),
              RuntimeAttachmentCodec.sha256(bytes) == digest,
              case let .text(stateRaw)? = row.value(named: "reference_state"),
              let state = RuntimeAttachmentReferenceState(rawValue: stateRaw),
              case let .text(referenceRaw)? = row.value(named: "reference_id"),
              case let .text(revisionRaw)? = row.value(named: "revision_id"),
              case let .text(targetFamily)? = row.value(named: "target_family"),
              case let .text(targetID)? = row.value(named: "target_object_id"),
              case let .integer(targetRevision)? = row.value(named: "target_revision"),
              targetRevision >= 0,
              case let .text(commandRaw)? = row.value(named: "command_id"),
              case let .text(receiptRaw)? = row.value(named: "receipt_id"),
              case let .integer(sequence)? = row.value(named: "terminal_event_sequence"),
              sequence >= 0,
              case let .integer(version)? = row.value(named: "reference_version"),
              case let .integer(created)? = row.value(named: "created_at_ms"),
              case let .text(eventRaw)? = row.value(named: "event_id"),
              case let .text(eventHash)? = row.value(named: "event_hash") else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let original = try RuntimeAttachmentCodec.decode(
            RuntimeAttachmentReference.self, bytes: bytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        guard Int64(original.version) == version,
              original.referenceID.rawValue == referenceRaw,
              original.revisionID.rawValue == revisionRaw,
              original.target.kind.rawValue == targetFamily,
              original.target.id.rawValue == targetID,
              original.targetRevision == UInt64(targetRevision),
              original.state == state,
              original.commandID.rawValue == commandRaw,
              original.receiptID.rawValue == receiptRaw,
              original.lineage.eventSequence == UInt64(sequence),
              original.lineage.eventID.rawValue == eventRaw,
              original.lineage.eventHash == eventHash,
              try milliseconds(original.createdAt) == created else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        if state == .active {
            guard case .null? = row.value(named: "removed_at_ms"),
                  original.removedAt == nil else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            return original
        }
        guard case let .integer(removed)? = row.value(named: "removed_at_ms"),
              let originalRemoved = original.removedAt,
              try milliseconds(originalRemoved) == removed else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return original
    }

    private static func decodeLifecycleHistoryRow(
        _ row: SQLiteRow,
        blobID: RuntimeBlobID
    ) throws -> RuntimeAttachmentLifecycleHistory {
        guard case let .blob(bytes)? = row.value(named: "history_payload"),
              case let .text(digest)? = row.value(named: "history_digest") else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let value = try RuntimeAttachmentCodec.decode(
            RuntimeAttachmentLifecycleHistory.self, bytes: bytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        guard value.transitionDigest == digest,
              try RuntimeAttachmentCodec.transitionDigest(value) == digest,
              try lifecycleHistoryScalarsMatch(value, blobID: blobID, row: row) else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return value
    }

    private static func decodeReferenceHistoryRow(
        _ row: SQLiteRow,
        blobID: RuntimeBlobID
    ) throws -> RuntimeAttachmentReferenceHistory {
        guard case let .blob(bytes)? = row.value(named: "history_payload"),
              case let .text(digest)? = row.value(named: "history_digest") else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let value = try RuntimeAttachmentCodec.decode(
            RuntimeAttachmentReferenceHistory.self, bytes: bytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        guard value.transitionDigest == digest,
              try RuntimeAttachmentCodec.referenceTransitionDigest(value) == digest,
              value.blobID == blobID,
              value.lineage.eventSequence <= RuntimeAttachmentCodec.maximumSQLiteInteger,
              row.value(named: "history_id") == .text(value.historyID.rawValue),
              row.value(named: "reference_id") == .text(value.referenceID.rawValue),
              row.value(named: "revision_id") == .text(value.revisionID.rawValue),
              row.value(named: "to_state") == .text(value.toState.rawValue),
              row.value(named: "command_id") == .text(value.commandID.rawValue),
              row.value(named: "receipt_id") == .text(value.receiptID.rawValue),
              row.value(named: "terminal_event_sequence") == .integer(
                try RuntimeAttachmentCodec.sqliteInteger(value.lineage.eventSequence)
              ),
              row.value(named: "event_id") == .text(value.lineage.eventID.rawValue),
              row.value(named: "event_hash") == .text(value.lineage.eventHash),
              row.value(named: "authenticated_receipt_id") == .text(value.receiptID.rawValue),
              row.value(named: "history_version") == .integer(Int64(value.version)),
              row.value(named: "occurred_at_ms") == .integer(
                try milliseconds(value.occurredAt)
              ) else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        switch (value.fromState, row.value(named: "from_state")) {
        case (nil, .null?): break
        case let (state?, .text(raw)?):
            guard state.rawValue == raw else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
        default: throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return value
    }

    private static func loadReferences(
        blobID: RuntimeBlobID,
        budget: inout RuntimeAttachmentDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeAttachmentReference] {
        let rows = try budget.query(
            """
            SELECT a.reference_id, a.revision_id, a.target_family, a.target_object_id,
                   a.target_revision, a.reference_state, a.command_id, a.receipt_id,
                   a.terminal_event_sequence, a.reference_version, a.reference_payload,
                   a.reference_digest, a.created_at_ms, a.removed_at_ms,
                   e.event_id, e.event_hash
            FROM runtime_attachment_references AS a
            JOIN runtime_semantic_events AS e ON e.sequence = a.terminal_event_sequence
            JOIN runtime_committed_receipt_cores AS c
              ON c.receipt_id = a.receipt_id AND c.command_id = a.command_id
             AND c.terminal_event_sequence = a.terminal_event_sequence
             AND c.terminal_event_id = e.event_id AND c.terminal_event_hash = e.event_hash
            WHERE a.blob_id = ? ORDER BY a.reference_id
            LIMIT ?
            """,
            bindings: [.text(blobID.rawValue), .integer(Int64(RuntimeAttachmentLimits.maximumReferences + 1))],
            database: database
        )
        guard rows.count <= RuntimeAttachmentLimits.maximumReferences else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return try rows.map { row in
            guard case let .blob(bytes)? = row.value(named: "reference_payload"),
                  case let .text(digest)? = row.value(named: "reference_digest"),
                  RuntimeAttachmentCodec.sha256(bytes) == digest,
                  case let .text(stateRaw)? = row.value(named: "reference_state"),
                  let state = RuntimeAttachmentReferenceState(rawValue: stateRaw),
                  case let .text(referenceRaw)? = row.value(named: "reference_id"),
                  case let .text(revisionRaw)? = row.value(named: "revision_id"),
                  case let .text(targetFamily)? = row.value(named: "target_family"),
                  case let .text(targetID)? = row.value(named: "target_object_id"),
                  case let .integer(targetRevision)? = row.value(named: "target_revision"),
                  case let .text(commandRaw)? = row.value(named: "command_id"),
                  case let .text(receiptRaw)? = row.value(named: "receipt_id"),
                  case let .integer(sequence)? = row.value(named: "terminal_event_sequence"),
                  case let .integer(version)? = row.value(named: "reference_version"),
                  case let .integer(created)? = row.value(named: "created_at_ms"),
                  case let .text(eventRaw)? = row.value(named: "event_id"),
                  case let .text(eventHash)? = row.value(named: "event_hash") else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            let original = try RuntimeAttachmentCodec.decode(
                RuntimeAttachmentReference.self, bytes: bytes,
                maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            guard Int64(original.version) == version,
                  original.referenceID.rawValue == referenceRaw,
                  original.revisionID.rawValue == revisionRaw,
                  original.target.kind.rawValue == targetFamily,
                  original.target.id.rawValue == targetID,
                  original.targetRevision == UInt64(targetRevision),
                  original.state == state,
                  original.commandID.rawValue == commandRaw,
                  original.receiptID.rawValue == receiptRaw,
                  original.lineage.eventSequence == UInt64(sequence),
                  original.lineage.eventID.rawValue == eventRaw,
                  original.lineage.eventHash == eventHash,
                  try milliseconds(original.createdAt) == created else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            if state == .active {
                guard case .null? = row.value(named: "removed_at_ms"),
                      original.removedAt == nil else {
                    throw RuntimeCanonicalAttachmentError.corruptAuthority
                }
                return original
            }
            guard case let .integer(removed)? = row.value(named: "removed_at_ms"),
                  let originalRemoved = original.removedAt,
                  try milliseconds(originalRemoved) == removed else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            return original
        }
    }

    private static func loadHistory(
        blobID: RuntimeBlobID,
        budget: inout RuntimeAttachmentDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeAttachmentLifecycleHistory] {
        let rows = try budget.query(
            """
            SELECT h.history_id, h.state_version, h.from_state, h.to_state,
                   h.from_reference_count, h.to_reference_count,
                   h.command_id, h.receipt_id, h.terminal_event_sequence,
                   h.system_authority_kind, h.system_authority_id,
                   h.system_evidence_fingerprint,
                   h.history_version, h.history_payload, h.history_digest,
                   h.occurred_at_ms, e.event_id, e.event_hash,
                   c.receipt_id AS authenticated_receipt_id
            FROM runtime_attachment_lifecycle_history AS h
            LEFT JOIN runtime_semantic_events AS e ON e.sequence = h.terminal_event_sequence
            LEFT JOIN runtime_committed_receipt_cores AS c
              ON c.receipt_id = h.receipt_id AND c.command_id = h.command_id
             AND c.terminal_event_sequence = h.terminal_event_sequence
             AND c.terminal_event_id = e.event_id AND c.terminal_event_hash = e.event_hash
            WHERE h.blob_id = ? ORDER BY h.state_version LIMIT ?
            """,
            bindings: [.text(blobID.rawValue), .integer(Int64(RuntimeAttachmentLimits.maximumHistoryEntries + 1))],
            database: database
        )
        guard rows.count <= RuntimeAttachmentLimits.maximumHistoryEntries else {
            throw RuntimeCanonicalAttachmentError.decodedByteBudgetExceeded
        }
        return try rows.map { row in
            guard case let .blob(bytes)? = row.value(named: "history_payload"),
                  case let .text(digest)? = row.value(named: "history_digest") else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            let value = try RuntimeAttachmentCodec.decode(
                RuntimeAttachmentLifecycleHistory.self, bytes: bytes,
                maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            guard value.transitionDigest == digest,
                  try RuntimeAttachmentCodec.transitionDigest(value) == digest,
                  try lifecycleHistoryScalarsMatch(
                    value, blobID: blobID, row: row
                  ) else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            return value
        }
    }

    private static func lifecycleHistoryScalarsMatch(
        _ value: RuntimeAttachmentLifecycleHistory,
        blobID: RuntimeBlobID,
        row: SQLiteRow
    ) throws -> Bool {
        guard value.blobID == blobID,
              value.stateVersion <= RuntimeAttachmentCodec.maximumSQLiteInteger,
              case let .text(historyRaw)? = row.value(named: "history_id"),
              value.historyID.rawValue == historyRaw,
              case let .integer(stateVersion)? = row.value(named: "state_version"),
              value.stateVersion == UInt64(stateVersion),
              case let .text(toRaw)? = row.value(named: "to_state"),
              value.toState.rawValue == toRaw,
              case let .integer(toCount)? = row.value(named: "to_reference_count"),
              value.toReferenceCount == Int(toCount),
              case let .integer(version)? = row.value(named: "history_version"),
              Int64(value.version) == version,
              case let .integer(occurred)? = row.value(named: "occurred_at_ms"),
              try milliseconds(value.occurredAt) == occurred else { return false }
        switch (value.fromState, row.value(named: "from_state")) {
        case (nil, .null?): break
        case let (state?, .text(raw)?): guard state.rawValue == raw else { return false }
        default: return false
        }
        switch (value.fromReferenceCount, row.value(named: "from_reference_count")) {
        case (nil, .null?): break
        case let (count?, .integer(raw)?): guard count == Int(raw) else { return false }
        default: return false
        }
        switch (value.commandID, value.receiptID, value.lineage) {
        case (nil, nil, nil):
            guard case .null? = row.value(named: "command_id"),
                  case .null? = row.value(named: "receipt_id"),
                  case .null? = row.value(named: "terminal_event_sequence"),
                  case .null? = row.value(named: "event_id"),
                  case .null? = row.value(named: "event_hash"),
                  case .null? = row.value(named: "authenticated_receipt_id") else { return false }
        case let (command?, receipt?, lineage?):
            guard lineage.eventSequence <= RuntimeAttachmentCodec.maximumSQLiteInteger,
                  row.value(named: "command_id") == .text(command.rawValue),
                  row.value(named: "receipt_id") == .text(receipt.rawValue),
                  row.value(named: "terminal_event_sequence") == .integer(
                    try RuntimeAttachmentCodec.sqliteInteger(lineage.eventSequence)
                  ),
                  row.value(named: "event_id") == .text(lineage.eventID.rawValue),
                  row.value(named: "event_hash") == .text(lineage.eventHash),
                  row.value(named: "authenticated_receipt_id") == .text(receipt.rawValue) else {
                return false
            }
        default: return false
        }
        switch value.systemAuthority {
        case nil:
            guard case .null? = row.value(named: "system_authority_kind"),
                  case .null? = row.value(named: "system_authority_id"),
                  case .null? = row.value(named: "system_evidence_fingerprint") else {
                return false
            }
        case let authority?:
            guard row.value(named: "system_authority_kind") == .text(authority.kind.rawValue),
                  row.value(named: "system_authority_id") == .text(authority.authorityID),
                  row.value(named: "system_evidence_fingerprint") == .text(
                    authority.evidenceFingerprint
                  ) else { return false }
        }
        guard (value.fromState == nil
            ? (value.commandID == nil && value.systemAuthority == nil)
            : ((value.commandID != nil) != (value.systemAuthority != nil))) else { return false }
        return true
    }

    private static func loadReferenceHistory(
        blobID: RuntimeBlobID,
        budget: inout RuntimeAttachmentDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeAttachmentReferenceHistory] {
        let rows = try budget.query(
            """
            SELECT h.history_id, h.reference_id, h.revision_id, h.from_state, h.to_state,
                   h.command_id, h.receipt_id, h.terminal_event_sequence,
                   h.history_version, h.history_payload, h.history_digest,
                   h.occurred_at_ms, e.event_id, e.event_hash,
                   c.receipt_id AS authenticated_receipt_id
            FROM runtime_attachment_reference_history AS h
            JOIN runtime_semantic_events AS e ON e.sequence = h.terminal_event_sequence
            JOIN runtime_committed_receipt_cores AS c
              ON c.receipt_id = h.receipt_id AND c.command_id = h.command_id
             AND c.terminal_event_sequence = h.terminal_event_sequence
             AND c.terminal_event_id = e.event_id AND c.terminal_event_hash = e.event_hash
            WHERE h.blob_id = ? ORDER BY h.occurred_at_ms, h.history_id LIMIT ?
            """,
            bindings: [
                .text(blobID.rawValue), .integer(Int64(RuntimeAttachmentLimits.maximumReferences * 2 + 1)),
            ],
            database: database
        )
        guard rows.count <= RuntimeAttachmentLimits.maximumReferences * 2 else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return try rows.map { row in
            guard case let .blob(bytes)? = row.value(named: "history_payload"),
                  case let .text(digest)? = row.value(named: "history_digest") else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            let value = try RuntimeAttachmentCodec.decode(
                RuntimeAttachmentReferenceHistory.self, bytes: bytes,
                maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
            )
            guard value.transitionDigest == digest,
                  try RuntimeAttachmentCodec.referenceTransitionDigest(value) == digest,
                  value.blobID == blobID,
                  value.lineage.eventSequence <= RuntimeAttachmentCodec.maximumSQLiteInteger,
                  row.value(named: "history_id") == .text(value.historyID.rawValue),
                  row.value(named: "reference_id") == .text(value.referenceID.rawValue),
                  row.value(named: "revision_id") == .text(value.revisionID.rawValue),
                  row.value(named: "to_state") == .text(value.toState.rawValue),
                  row.value(named: "command_id") == .text(value.commandID.rawValue),
                  row.value(named: "receipt_id") == .text(value.receiptID.rawValue),
                  row.value(named: "terminal_event_sequence") == .integer(
                    try RuntimeAttachmentCodec.sqliteInteger(value.lineage.eventSequence)
                  ),
                  row.value(named: "event_id") == .text(value.lineage.eventID.rawValue),
                  row.value(named: "event_hash") == .text(value.lineage.eventHash),
                  row.value(named: "authenticated_receipt_id") == .text(value.receiptID.rawValue),
                  row.value(named: "history_version") == .integer(Int64(value.version)),
                  row.value(named: "occurred_at_ms") == .integer(
                    try milliseconds(value.occurredAt)
                  ) else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            switch (value.fromState, row.value(named: "from_state")) {
            case (nil, .null?): break
            case let (state?, .text(raw)?):
                guard state.rawValue == raw else {
                    throw RuntimeCanonicalAttachmentError.corruptAuthority
                }
            default: throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            return value
        }
    }

    private static func loadHolds(
        blobID: RuntimeBlobID,
        budget: inout RuntimeAttachmentDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeBlobRetentionHold] {
        let rows = try budget.query(
            """
            SELECT hold_id, hold_kind, authority_id, retain_until_ms, created_at_ms
            FROM runtime_blob_retention_holds
            WHERE blob_id = ? AND released_at_ms IS NULL ORDER BY hold_id LIMIT ?
            """,
            bindings: [.text(blobID.rawValue), .integer(Int64(RuntimeAttachmentLimits.maximumHolds + 1))],
            database: database
        )
        guard rows.count <= RuntimeAttachmentLimits.maximumHolds else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return try rows.map { row in
            guard case let .text(idRaw)? = row.value(named: "hold_id"), let id = RuntimeBlobHoldID(rawValue: idRaw),
                  case let .text(kindRaw)? = row.value(named: "hold_kind"), let kind = RuntimeAttachmentHoldKind(rawValue: kindRaw),
                  case let .text(authorityID)? = row.value(named: "authority_id"),
                  case let .integer(created)? = row.value(named: "created_at_ms") else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            let retainUntil: Date? = if case let .integer(value)? = row.value(named: "retain_until_ms") {
                Date(timeIntervalSince1970: Double(value) / 1_000)
            } else { nil }
            return RuntimeBlobRetentionHold(
                version: runtimeCanonicalAttachmentModelVersion, holdID: id, blobID: blobID,
                kind: kind, authorityID: authorityID, retainUntil: retainUntil,
                createdAt: Date(timeIntervalSince1970: Double(created) / 1_000)
            )
        }
    }

    private static func loadTombstone(
        blobID: RuntimeBlobID,
        budget: inout RuntimeAttachmentDecodedByteBudget,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeBlobDeletionTombstone? {
        let rows = try budget.query(
            """
            SELECT tombstone_id, manifest_digest, final_state_version,
                   deletion_authorization_id, physical_deletion_confirmed,
                   physical_deletion_disposition, tombstone_version,
                   tombstone_payload, tombstone_digest, deleted_at_ms
            FROM runtime_blob_deletion_tombstones WHERE blob_id = ? LIMIT 2
            """,
            bindings: [.text(blobID.rawValue)],
            database: database
        )
        guard rows.count <= 1 else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
        guard let row = rows.first else { return nil }
        guard case let .blob(bytes)? = row.value(named: "tombstone_payload"),
              case let .text(digest)? = row.value(named: "tombstone_digest") else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let tombstone = try RuntimeAttachmentCodec.decode(
            RuntimeBlobDeletionTombstone.self, bytes: bytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        guard tombstone.blobID == blobID, tombstone.tombstoneDigest == digest,
              tombstone.finalStateVersion <= RuntimeAttachmentCodec.maximumSQLiteInteger,
              tombstone.physicalDeletionConfirmed,
              row.value(named: "tombstone_id") == .text(tombstone.tombstoneID.rawValue),
              row.value(named: "manifest_digest") == .text(tombstone.manifestDigest),
              row.value(named: "final_state_version") == .integer(
                try RuntimeAttachmentCodec.sqliteInteger(tombstone.finalStateVersion)
              ),
              row.value(named: "deletion_authorization_id") == .text(
                tombstone.deletionAuthorizationID
              ),
              row.value(named: "physical_deletion_confirmed") == .integer(1),
              row.value(named: "physical_deletion_disposition") == .text(
                  tombstone.physicalDeletionDisposition.rawValue
              ),
              row.value(named: "tombstone_version") == .integer(Int64(tombstone.version)),
              row.value(named: "deleted_at_ms") == .integer(try milliseconds(tombstone.deletedAt)),
              try RuntimeAttachmentCodec.tombstoneDigest(tombstone) == digest else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return tombstone
    }

    private static func hasActiveHold(
        blobID: RuntimeBlobID, at now: Date, database: isolated SQLiteDatabase
    ) throws -> Bool {
        try database.query(
            """
            SELECT 1 AS present FROM runtime_blob_retention_holds
            WHERE blob_id = ? AND released_at_ms IS NULL
              AND (retain_until_ms IS NULL OR retain_until_ms > ?) LIMIT 1
            """,
            bindings: [.text(blobID.rawValue), .integer(try milliseconds(now))]
        ).isEmpty == false
    }

    private static func hasUnresolvedQuarantine(
        blobID: RuntimeBlobID,
        database: isolated SQLiteDatabase
    ) throws -> Bool {
        try database.query(
            """
            SELECT 1 AS present FROM runtime_blob_quarantine
            WHERE blob_id = ? AND resolved_at_ms IS NULL LIMIT 1
            """,
            bindings: [.text(blobID.rawValue)]
        ).isEmpty == false
    }

    private static func releaseDedupAuthority(
        blobID: RuntimeBlobID,
        database: isolated SQLiteDatabase
    ) throws {
        _ = try database.execute(
            "DELETE FROM runtime_blob_dedup_authority WHERE canonical_blob_id = ?",
            bindings: [.text(blobID.rawValue)]
        )
    }

    private static func hasAuthenticatedCompletedFinalization(
        blobID: RuntimeBlobID,
        manifestDigest: String,
        database: isolated SQLiteDatabase
    ) throws -> Bool {
        let rows = try database.query(
            """
            SELECT b.manifest_payload, b.manifest_digest,
                   f.marker_digest, f.finalized_at_ms, f.receipt_id,
                   f.terminal_event_sequence, f.finalization_completion_id,
                   c.revision_id, c.final_state_version,
                   l.artifact_payload, l.artifact_digest
            FROM runtime_blob_finalization_intents AS f
            JOIN runtime_blob_finalization_completions AS c
              ON c.completion_id = f.finalization_completion_id
             AND c.blob_id = f.blob_id AND c.manifest_digest = f.manifest_digest
             AND c.command_id = f.command_id AND c.receipt_id = f.receipt_id
             AND c.terminal_event_sequence = f.terminal_event_sequence
             AND c.marker_digest = f.marker_digest AND c.finalized_at_ms = f.finalized_at_ms
            JOIN runtime_attachment_lifecycle_history AS h
              ON h.blob_id = c.blob_id AND h.state_version = c.final_state_version
             AND h.from_state = 'referenced' AND h.to_state = 'finalized'
             AND h.finalization_completion_id = c.completion_id
            JOIN runtime_attachment_receipt_links AS l
              ON l.receipt_id = c.receipt_id AND l.revision_id = c.revision_id
             AND l.blob_id = c.blob_id AND l.manifest_digest = c.manifest_digest
             AND l.link_kind = 'finalization' AND l.artifact_digest = c.marker_digest
             AND l.finalization_completion_id = c.completion_id
            JOIN runtime_blob_records AS b
              ON b.blob_id = c.blob_id AND b.manifest_digest = c.manifest_digest
            WHERE f.blob_id = ? AND f.manifest_digest = ?
              AND f.marker_digest IS NOT NULL AND f.finalized_at_ms IS NOT NULL
            LIMIT 2
            """,
            bindings: [.text(blobID.rawValue), .text(manifestDigest)]
        )
        guard rows.count <= 1 else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
        guard let row = rows.first else { return false }
        guard case let .blob(manifestBytes)? = row.value(named: "manifest_payload"),
              row.value(named: "manifest_digest") == .text(manifestDigest),
              RuntimeAttachmentCodec.sha256(manifestBytes) == manifestDigest,
              case let .text(markerDigest)? = row.value(named: "marker_digest"),
              case let .integer(finalizedAtMS)? = row.value(named: "finalized_at_ms"),
              case let .text(receiptRaw)? = row.value(named: "receipt_id"),
              let receiptID = RuntimeReceiptID(rawValue: receiptRaw),
              case let .integer(sequence)? = row.value(named: "terminal_event_sequence"),
              sequence > 0,
              case let .blob(markerBytes)? = row.value(named: "artifact_payload"),
              row.value(named: "artifact_digest") == .text(markerDigest),
              RuntimeAttachmentCodec.sha256(markerBytes) == markerDigest else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let manifest = try RuntimeAttachmentCodec.decode(
            RuntimeBlobManifestAuthority.self, bytes: manifestBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        let marker = try RuntimeAttachmentCodec.decode(
            RuntimeAttachmentFinalizationMarker.self, bytes: markerBytes,
            maximumBytes: RuntimeAttachmentLimits.maximumManifestBytes
        )
        try RuntimeAttachmentCodec.validate(manifest)
        guard manifest.blobID == blobID,
              marker.version == runtimeCanonicalAttachmentModelVersion,
              marker.blobID == blobID, marker.manifestDigest == manifestDigest,
              marker.receiptID == receiptID,
              marker.terminalEventSequence == UInt64(sequence),
              try milliseconds(marker.finalizedAt) == finalizedAtMS else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return true
    }

    private static func restoreDedupAuthority(
        manifest: RuntimeBlobManifestAuthority,
        at now: Date,
        database: isolated SQLiteDatabase
    ) throws {
        guard manifest.dedupPolicy == .withinPrivacyDomain else { return }
        _ = try database.execute(
            """
            INSERT INTO runtime_blob_dedup_authority(
                privacy_domain, keyed_content_address, manifest_version,
                protection_class, canonical_blob_id, authority_version, created_at_ms
            ) VALUES(?, ?, ?, ?, ?, 1, ?)
            ON CONFLICT DO NOTHING
            """,
            bindings: [
                .text(manifest.privacyDomain.rawValue),
                .text(manifest.keyedContentAddress.rawValue),
                .integer(Int64(manifest.formatVersion)),
                .text(manifest.protectionClass.rawValue),
                .text(manifest.blobID.rawValue), .integer(try milliseconds(now)),
            ]
        )
        let rows = try database.query(
            """
            SELECT canonical_blob_id FROM runtime_blob_dedup_authority
            WHERE privacy_domain = ? AND keyed_content_address = ?
              AND manifest_version = ? AND protection_class = ? LIMIT 2
            """,
            bindings: [
                .text(manifest.privacyDomain.rawValue),
                .text(manifest.keyedContentAddress.rawValue),
                .integer(Int64(manifest.formatVersion)),
                .text(manifest.protectionClass.rawValue),
            ]
        )
        guard rows.count == 1,
              rows[0].value(named: "canonical_blob_id") == .text(manifest.blobID.rawValue) else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
    }

    static func milliseconds(_ date: Date) throws -> Int64 {
        try RuntimeSemanticEventHashing.milliseconds(date)
    }
}
