import AmbitionsRuntimeSQLite
import Foundation

extension CanonicalRuntimeStore: RuntimeAttachmentKeyRewrapPersisting {
    func beginAttachmentKeyRewrap(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        source: RuntimeAttachmentWrappingKey,
        target: RuntimeAttachmentWrappingKey,
        now: Date
    ) async throws -> RuntimeAttachmentKeyRewrapJob {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.beginKeyRewrap(
                jobID: jobID, sourceKeyID: source.id, sourceKeyVersion: source.version,
                targetKeyID: target.id, targetKeyVersion: target.version,
                now: now, database: database
            )
        }
    }

    func attachmentKeyRewrapJob(
        jobID: RuntimeAttachmentKeyRewrapJobID
    ) async throws -> RuntimeAttachmentKeyRewrapJob {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.loadKeyRewrapJob(
                jobID: jobID, database: database
            )
        }
    }

    func activeAttachmentKeyRewrapJob() async throws -> RuntimeAttachmentKeyRewrapJob? {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            let rows = try database.query(
                "SELECT job_id FROM runtime_blob_key_rewrap_jobs WHERE job_state = 'active' ORDER BY created_at_ms, job_id LIMIT 2"
            )
            guard rows.count <= 1 else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
            guard let row = rows.first,
                  case let .text(raw)? = row.value(named: "job_id"),
                  let jobID = RuntimeAttachmentKeyRewrapJobID(rawValue: raw) else {
                if rows.isEmpty { return nil }
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            return try CanonicalRuntimeAttachmentStore.loadKeyRewrapJob(
                jobID: jobID, database: database
            )
        }
    }

    func claimAttachmentKeyRewrapItems(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        ownerID: String,
        leaseToken: String,
        limit: Int,
        now: Date,
        leaseExpiresAt: Date
    ) async throws -> [RuntimeAttachmentKeyRewrapClaim] {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.claimKeyRewrapItems(
                jobID: jobID, ownerID: ownerID, leaseToken: leaseToken,
                limit: limit, now: now, leaseExpiresAt: leaseExpiresAt,
                database: database
            )
        }
    }

    func completeAttachmentKeyRewrapItem(
        _ claim: RuntimeAttachmentKeyRewrapClaim,
        replacementEnvelope: RuntimeBlobKeyEnvelope,
        now: Date
    ) async throws {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            try CanonicalRuntimeAttachmentStore.completeKeyRewrapItem(
                claim, replacementEnvelope: replacementEnvelope,
                now: now, database: database
            )
        }
    }

    func failAttachmentKeyRewrapItem(
        _ claim: RuntimeAttachmentKeyRewrapClaim,
        errorFingerprint: String,
        now: Date
    ) async throws {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            try CanonicalRuntimeAttachmentStore.failKeyRewrapItem(
                claim, errorFingerprint: errorFingerprint, now: now, database: database
            )
        }
    }

    func releaseAttachmentKeyRewrapClaim(
        _ claim: RuntimeAttachmentKeyRewrapClaim,
        now: Date
    ) async throws {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            try CanonicalRuntimeAttachmentStore.releaseKeyRewrapClaim(
                claim, now: now, database: database
            )
        }
    }

    func completeAttachmentKeyRewrapJob(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        now: Date
    ) async throws -> RuntimeAttachmentKeyRewrapJob {
        try await withAtomicCommitTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.completeKeyRewrapJob(
                jobID: jobID, now: now, database: database
            )
        }
    }

    func attachmentKeyRetirementEligibility(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        custodySupportsRetirement: Bool
    ) async throws -> RuntimeAttachmentKeyRetirementEligibility {
        try await withCanonicalReadTransaction { database in
            try CanonicalRuntimeAttachmentStore.requireSchema(database)
            return try CanonicalRuntimeAttachmentStore.keyRetirementEligibility(
                jobID: jobID, custodySupportsRetirement: custodySupportsRetirement,
                database: database
            )
        }
    }
}

extension CanonicalRuntimeAttachmentStore {
    static func beginKeyRewrap(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        sourceKeyID: RuntimeBlobKeyID,
        sourceKeyVersion: Int,
        targetKeyID: RuntimeBlobKeyID,
        targetKeyVersion: Int,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentKeyRewrapJob {
        guard sourceKeyVersion > 0, sourceKeyVersion < Int.max,
              targetKeyVersion == sourceKeyVersion + 1,
              sourceKeyID != targetKeyID else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        if let existing = try optionalKeyRewrapJob(jobID: jobID, database: database) {
            guard existing.sourceKeyID == sourceKeyID,
                  existing.sourceKeyVersion == sourceKeyVersion,
                  existing.targetKeyID == targetKeyID,
                  existing.targetKeyVersion == targetKeyVersion else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            return existing
        }
        let active = try database.query(
            "SELECT COUNT(*) AS total FROM runtime_blob_key_rewrap_jobs WHERE job_state = 'active'"
        )
        guard active.count == 1,
              active[0].value(named: "total") == .integer(0) else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let nowMS = try milliseconds(now)
        let insertedJob = try database.execute(
            """
            INSERT INTO runtime_blob_key_rewrap_jobs(
                job_id, source_key_id, source_key_version, target_key_id, target_key_version,
                job_state, total_envelope_count, completed_envelope_count,
                failed_envelope_count, state_version, created_at_ms, updated_at_ms, completed_at_ms
            ) VALUES(?, ?, ?, ?, ?, 'active', 0, 0, 0, 1, ?, ?, NULL)
            """,
            bindings: [
                .text(jobID.rawValue), .text(sourceKeyID.rawValue),
                .integer(Int64(sourceKeyVersion)), .text(targetKeyID.rawValue),
                .integer(Int64(targetKeyVersion)), .integer(nowMS), .integer(nowMS),
            ]
        )
        guard insertedJob.changedRowCount == 1 else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let inserted = try database.execute(
            """
            INSERT INTO runtime_blob_key_rewrap_items(
                job_id, blob_id, expected_envelope_digest, item_state, state_version,
                attempt_count, next_retry_at_ms, lease_owner_id, lease_token,
                lease_expires_at_ms, last_error_fingerprint, updated_at_ms, completed_at_ms
            )
            SELECT ?, blob_id, envelope_digest, 'pending', 1, 0, ?,
                   NULL, NULL, NULL, NULL, ?, NULL
            FROM runtime_blob_key_envelopes
            WHERE wrapping_key_id = ? AND wrapping_key_version = ?
            ORDER BY blob_id
            """,
            bindings: [
                .text(jobID.rawValue), .integer(nowMS), .integer(nowMS),
                .text(sourceKeyID.rawValue), .integer(Int64(sourceKeyVersion)),
            ]
        )
        let updatedJob = try database.execute(
            """
            UPDATE runtime_blob_key_rewrap_jobs
            SET total_envelope_count = ?, updated_at_ms = ?, state_version = 2
            WHERE job_id = ? AND job_state = 'active' AND state_version = 1
            """,
            bindings: [
                .integer(Int64(inserted.changedRowCount)), .integer(nowMS), .text(jobID.rawValue),
            ]
        )
        guard updatedJob.changedRowCount == 1 else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        return try loadKeyRewrapJob(jobID: jobID, database: database)
    }

    static func claimKeyRewrapItems(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        ownerID: String,
        leaseToken: String,
        limit: Int,
        now: Date,
        leaseExpiresAt: Date,
        database: isolated SQLiteDatabase
    ) throws -> [RuntimeAttachmentKeyRewrapClaim] {
        guard ownerID.isEmpty == false, ownerID.utf8.count <= 1_024,
              leaseToken.isEmpty == false, leaseToken.utf8.count <= 256,
              limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize,
              leaseExpiresAt > now,
              leaseExpiresAt.timeIntervalSince(now) <= RuntimeAttachmentLimits.maximumLeaseSeconds else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let job = try loadKeyRewrapJob(jobID: jobID, database: database)
        guard job.state == .active else { return [] }
        let nowMS = try milliseconds(now)
        let expiresMS = try milliseconds(leaseExpiresAt)
        try reconcileLateKeyRewrapItems(job: job, now: now, database: database)
        let rows = try database.query(
            """
            SELECT i.blob_id, i.expected_envelope_digest, i.state_version,
                   k.envelope_payload, k.envelope_digest
            FROM runtime_blob_key_rewrap_items AS i
            JOIN runtime_blob_key_envelopes AS k ON k.blob_id = i.blob_id
            WHERE i.job_id = ? AND i.attempt_count < ? AND (
                (i.item_state IN ('pending','failed') AND i.next_retry_at_ms <= ?)
                OR (i.item_state = 'in_progress' AND i.lease_expires_at_ms < ?)
            )
              AND k.wrapping_key_id = ? AND k.wrapping_key_version = ?
              AND k.envelope_digest = i.expected_envelope_digest
            ORDER BY i.blob_id LIMIT ?
            """,
            bindings: [
                .text(jobID.rawValue),
                .integer(Int64(RuntimeAttachmentLimits.maximumRecoveryAttempts)),
                .integer(nowMS), .integer(nowMS),
                .text(job.sourceKeyID.rawValue), .integer(Int64(job.sourceKeyVersion)),
                .integer(Int64(limit)),
            ]
        )
        var claims: [RuntimeAttachmentKeyRewrapClaim] = []
        for row in rows {
            guard case let .text(blobRaw)? = row.value(named: "blob_id"),
                  let blobID = RuntimeBlobID(rawValue: blobRaw),
                  case let .text(expectedDigest)? = row.value(named: "expected_envelope_digest"),
                  case let .integer(stateVersion)? = row.value(named: "state_version"),
                  stateVersion > 0,
                  case let .blob(envelopeBytes)? = row.value(named: "envelope_payload"),
                  case let .text(envelopeDigest)? = row.value(named: "envelope_digest"),
                  envelopeDigest == expectedDigest else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            let envelope = try RuntimeAttachmentCodec.decode(
                RuntimeBlobKeyEnvelope.self, bytes: envelopeBytes,
                maximumBytes: RuntimeAttachmentLimits.maximumEnvelopeBytes
            )
            try RuntimeAttachmentCodec.validate(envelope)
            guard envelope.blobID == blobID, envelope.envelopeDigest == expectedDigest,
                  envelope.wrappingKeyID == job.sourceKeyID,
                  envelope.wrappingKeyVersion == job.sourceKeyVersion else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            let changed = try database.execute(
                """
                UPDATE runtime_blob_key_rewrap_items
                SET item_state = 'in_progress', state_version = state_version + 1,
                    attempt_count = attempt_count + 1, lease_owner_id = ?, lease_token = ?,
                    lease_expires_at_ms = ?, updated_at_ms = ?
                WHERE job_id = ? AND blob_id = ? AND state_version = ?
                  AND item_state IN ('pending','failed','in_progress')
                  AND (item_state <> 'in_progress' OR lease_expires_at_ms < ?)
                  AND state_version < ? AND attempt_count < ?
                """,
                bindings: [
                    .text(ownerID), .text(leaseToken), .integer(expiresMS), .integer(nowMS),
                    .text(jobID.rawValue), .text(blobID.rawValue), .integer(stateVersion),
                    .integer(nowMS), .integer(Int64.max), .integer(Int64.max),
                ]
            )
            guard changed.changedRowCount == 1 else {
                throw RuntimeCanonicalAttachmentError.lifecycleConflict
            }
            claims.append(RuntimeAttachmentKeyRewrapClaim(
                jobID: jobID, blobID: blobID, sourceEnvelope: envelope,
                expectedEnvelopeDigest: expectedDigest,
                itemStateVersion: UInt64(stateVersion + 1), leaseOwnerID: ownerID,
                leaseToken: leaseToken, leaseExpiresAt: leaseExpiresAt
            ))
        }
        return claims
    }

    static func completeKeyRewrapItem(
        _ claim: RuntimeAttachmentKeyRewrapClaim,
        replacementEnvelope: RuntimeBlobKeyEnvelope,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws {
        let job = try loadKeyRewrapJob(jobID: claim.jobID, database: database)
        try RuntimeAttachmentCodec.validate(replacementEnvelope)
        guard job.state == .active,
              replacementEnvelope.blobID == claim.blobID,
              replacementEnvelope.wrappingKeyID == job.targetKeyID,
              replacementEnvelope.wrappingKeyVersion == job.targetKeyVersion,
              claim.sourceEnvelope.envelopeDigest == claim.expectedEnvelopeDigest,
              claim.leaseExpiresAt > now else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let envelopeBytes = try RuntimeAttachmentCodec.encode(
            replacementEnvelope, maximumBytes: RuntimeAttachmentLimits.maximumEnvelopeBytes
        )
        let nowMS = try milliseconds(now)
        let changedEnvelope = try database.execute(
            """
            UPDATE runtime_blob_key_envelopes
            SET wrapping_key_id = ?, wrapping_key_version = ?, envelope_version = 1,
                algorithm = ?, envelope_payload = ?, envelope_digest = ?
            WHERE blob_id = ? AND wrapping_key_id = ? AND wrapping_key_version = ?
              AND envelope_digest = ?
            """,
            bindings: [
                .text(replacementEnvelope.wrappingKeyID.rawValue),
                .integer(Int64(replacementEnvelope.wrappingKeyVersion)),
                .text(replacementEnvelope.algorithm), .blob(envelopeBytes),
                .text(replacementEnvelope.envelopeDigest), .text(claim.blobID.rawValue),
                .text(job.sourceKeyID.rawValue), .integer(Int64(job.sourceKeyVersion)),
                .text(claim.expectedEnvelopeDigest),
            ]
        )
        guard changedEnvelope.changedRowCount == 1 else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let changedItem = try database.execute(
            """
            UPDATE runtime_blob_key_rewrap_items
            SET item_state = 'completed', state_version = state_version + 1,
                lease_owner_id = NULL, lease_token = NULL, lease_expires_at_ms = NULL,
                last_error_fingerprint = NULL, updated_at_ms = ?, completed_at_ms = ?
            WHERE job_id = ? AND blob_id = ? AND item_state = 'in_progress'
              AND state_version = ? AND lease_owner_id = ? AND lease_token = ?
              AND lease_expires_at_ms > ?
              AND state_version < ?
            """,
            bindings: [
                .integer(nowMS), .integer(nowMS), .text(claim.jobID.rawValue),
                .text(claim.blobID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(claim.itemStateVersion)),
                .text(claim.leaseOwnerID), .text(claim.leaseToken), .integer(nowMS),
                .integer(Int64.max),
            ]
        )
        guard changedItem.changedRowCount == 1 else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        try refreshKeyRewrapJobCounts(jobID: claim.jobID, now: now, database: database)
    }

    static func failKeyRewrapItem(
        _ claim: RuntimeAttachmentKeyRewrapClaim,
        errorFingerprint: String,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws {
        guard RuntimeStoreManifestCodec.isSHA256Hex(errorFingerprint),
              claim.leaseExpiresAt > now else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        let nowMS = try milliseconds(now)
        let rows = try database.query(
            """
            SELECT attempt_count FROM runtime_blob_key_rewrap_items
            WHERE job_id = ? AND blob_id = ? AND item_state = 'in_progress'
              AND lease_expires_at_ms > ?
              AND state_version = ? AND lease_owner_id = ? AND lease_token = ? LIMIT 2
            """,
            bindings: [
                .text(claim.jobID.rawValue), .text(claim.blobID.rawValue),
                .integer(nowMS),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(claim.itemStateVersion)),
                .text(claim.leaseOwnerID), .text(claim.leaseToken),
            ]
        )
        guard rows.count == 1,
              case let .integer(attempt)? = rows[0].value(named: "attempt_count"),
              attempt > 0 else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let exponent = min(Int(attempt), 16)
        let delay = min(
            TimeInterval(1 << exponent), RuntimeAttachmentLimits.maximumRecoveryBackoffSeconds
        )
        let retryMS = try milliseconds(now.addingTimeInterval(delay))
        let changed = try database.execute(
            """
            UPDATE runtime_blob_key_rewrap_items
            SET item_state = 'failed', state_version = state_version + 1,
                next_retry_at_ms = ?, lease_owner_id = NULL, lease_token = NULL,
                lease_expires_at_ms = NULL, last_error_fingerprint = ?, updated_at_ms = ?
            WHERE job_id = ? AND blob_id = ? AND item_state = 'in_progress'
              AND state_version = ? AND lease_owner_id = ? AND lease_token = ?
              AND lease_expires_at_ms > ?
              AND state_version < ?
            """,
            bindings: [
                .integer(retryMS), .text(errorFingerprint), .integer(nowMS),
                .text(claim.jobID.rawValue), .text(claim.blobID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(claim.itemStateVersion)),
                .text(claim.leaseOwnerID), .text(claim.leaseToken), .integer(nowMS),
                .integer(Int64.max),
            ]
        )
        guard changed.changedRowCount == 1 else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        try refreshKeyRewrapJobCounts(jobID: claim.jobID, now: now, database: database)
    }

    static func releaseKeyRewrapClaim(
        _ claim: RuntimeAttachmentKeyRewrapClaim,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws {
        guard claim.leaseExpiresAt > now else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        let nowMS = try milliseconds(now)
        let changed = try database.execute(
            """
            UPDATE runtime_blob_key_rewrap_items
            SET item_state = 'pending', state_version = state_version + 1,
                next_retry_at_ms = ?, lease_owner_id = NULL, lease_token = NULL,
                lease_expires_at_ms = NULL, updated_at_ms = ?
            WHERE job_id = ? AND blob_id = ? AND item_state = 'in_progress'
              AND state_version = ? AND lease_owner_id = ? AND lease_token = ?
              AND lease_expires_at_ms > ?
              AND state_version < ?
            """,
            bindings: [
                .integer(nowMS), .integer(nowMS),
                .text(claim.jobID.rawValue), .text(claim.blobID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(claim.itemStateVersion)),
                .text(claim.leaseOwnerID), .text(claim.leaseToken), .integer(nowMS),
                .integer(Int64.max),
            ]
        )
        guard changed.changedRowCount == 1 else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
    }

    static func completeKeyRewrapJob(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentKeyRewrapJob {
        var job = try loadKeyRewrapJob(jobID: jobID, database: database)
        if job.state == .active {
            try reconcileLateKeyRewrapItems(job: job, now: now, database: database)
            try refreshKeyRewrapJobCounts(jobID: jobID, now: now, database: database)
            job = try loadKeyRewrapJob(jobID: jobID, database: database)
        }
        if job.state == .completed { return job }
        let remaining = try countEnvelopes(
            keyID: job.sourceKeyID, version: job.sourceKeyVersion, database: database
        )
        guard job.completedEnvelopeCount == job.totalEnvelopeCount,
              job.failedEnvelopeCount == 0, remaining == 0 else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let changed = try database.execute(
            """
            UPDATE runtime_blob_key_rewrap_jobs
            SET job_state = 'completed', state_version = state_version + 1,
                updated_at_ms = ?, completed_at_ms = ?
            WHERE job_id = ? AND job_state = 'active' AND state_version = ?
              AND state_version < ?
            """,
            bindings: [
                .integer(try milliseconds(now)), .integer(try milliseconds(now)),
                .text(jobID.rawValue),
                .integer(try RuntimeAttachmentCodec.sqliteInteger(job.stateVersion)),
                .integer(Int64.max),
            ]
        )
        guard changed.changedRowCount == 1 else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        return try loadKeyRewrapJob(jobID: jobID, database: database)
    }

    static func keyRetirementEligibility(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        custodySupportsRetirement: Bool,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentKeyRetirementEligibility {
        let job = try loadKeyRewrapJob(jobID: jobID, database: database)
        let remaining = try countEnvelopes(
            keyID: job.sourceKeyID, version: job.sourceKeyVersion, database: database
        )
        return RuntimeAttachmentKeyRetirementEligibility(
            jobID: job.jobID, sourceKeyID: job.sourceKeyID,
            sourceKeyVersion: job.sourceKeyVersion,
            remainingEnvelopeCount: remaining, jobCompleted: job.state == .completed,
            custodySupportsRetirement: custodySupportsRetirement
        )
    }

    static func loadKeyRewrapJob(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentKeyRewrapJob {
        guard let job = try optionalKeyRewrapJob(jobID: jobID, database: database) else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        return job
    }

    private static func optionalKeyRewrapJob(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAttachmentKeyRewrapJob? {
        let rows = try database.query(
            """
            SELECT source_key_id, source_key_version, target_key_id, target_key_version,
                   job_state, total_envelope_count, completed_envelope_count,
                   failed_envelope_count, state_version, created_at_ms,
                   updated_at_ms, completed_at_ms
            FROM runtime_blob_key_rewrap_jobs WHERE job_id = ? LIMIT 2
            """,
            bindings: [.text(jobID.rawValue)]
        )
        guard rows.count <= 1 else { throw RuntimeCanonicalAttachmentError.corruptAuthority }
        guard let row = rows.first else { return nil }
        guard case let .text(sourceRaw)? = row.value(named: "source_key_id"),
              let sourceKeyID = RuntimeBlobKeyID(rawValue: sourceRaw),
              case let .integer(sourceVersion)? = row.value(named: "source_key_version"),
              sourceVersion > 0,
              case let .text(targetRaw)? = row.value(named: "target_key_id"),
              let targetKeyID = RuntimeBlobKeyID(rawValue: targetRaw),
              case let .integer(targetVersion)? = row.value(named: "target_key_version"),
              sourceVersion < Int64.max, targetVersion == sourceVersion + 1,
              case let .text(stateRaw)? = row.value(named: "job_state"),
              let state = RuntimeAttachmentKeyRewrapJobState(rawValue: stateRaw),
              case let .integer(total)? = row.value(named: "total_envelope_count"), total >= 0,
              case let .integer(completed)? = row.value(named: "completed_envelope_count"), completed >= 0,
              case let .integer(failed)? = row.value(named: "failed_envelope_count"), failed >= 0,
              completed <= total, failed <= total - completed,
              case let .integer(version)? = row.value(named: "state_version"), version > 0,
              case let .integer(created)? = row.value(named: "created_at_ms"),
              case let .integer(updated)? = row.value(named: "updated_at_ms") else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        let completedAt: Date?
        switch row.value(named: "completed_at_ms") {
        case let .integer(value)?: completedAt = date(milliseconds: value)
        case .null?: completedAt = nil
        default: throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        guard (state == .completed) == (completedAt != nil) else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return RuntimeAttachmentKeyRewrapJob(
            jobID: jobID, sourceKeyID: sourceKeyID, sourceKeyVersion: Int(sourceVersion),
            targetKeyID: targetKeyID, targetKeyVersion: Int(targetVersion), state: state,
            totalEnvelopeCount: Int(total), completedEnvelopeCount: Int(completed),
            failedEnvelopeCount: Int(failed), stateVersion: UInt64(version),
            createdAt: date(milliseconds: created), updatedAt: date(milliseconds: updated),
            completedAt: completedAt
        )
    }

    private static func refreshKeyRewrapJobCounts(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws {
        let changed = try database.execute(
            """
            UPDATE runtime_blob_key_rewrap_jobs
            SET completed_envelope_count = (
                    SELECT COUNT(*) FROM runtime_blob_key_rewrap_items
                    WHERE job_id = ? AND item_state = 'completed'
                ),
                failed_envelope_count = (
                    SELECT COUNT(*) FROM runtime_blob_key_rewrap_items
                    WHERE job_id = ? AND item_state = 'failed'
                ),
                state_version = state_version + 1, updated_at_ms = ?
            WHERE job_id = ? AND job_state = 'active' AND state_version < ?
            """,
            bindings: [
                .text(jobID.rawValue), .text(jobID.rawValue),
                .integer(try milliseconds(now)), .text(jobID.rawValue), .integer(Int64.max),
            ]
        )
        guard changed.changedRowCount == 1 else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
    }

    private static func reconcileLateKeyRewrapItems(
        job: RuntimeAttachmentKeyRewrapJob,
        now: Date,
        database: isolated SQLiteDatabase
    ) throws {
        guard job.state == .active else { return }
        let nowMS = try milliseconds(now)
        _ = try database.execute(
            """
            INSERT INTO runtime_blob_key_rewrap_items(
                job_id, blob_id, expected_envelope_digest, item_state, state_version,
                attempt_count, next_retry_at_ms, lease_owner_id, lease_token,
                lease_expires_at_ms, last_error_fingerprint, updated_at_ms, completed_at_ms
            )
            SELECT ?, k.blob_id, k.envelope_digest, 'pending', 1, 0, ?,
                   NULL, NULL, NULL, NULL, ?, NULL
            FROM runtime_blob_key_envelopes AS k
            WHERE k.wrapping_key_id = ? AND k.wrapping_key_version = ?
              AND NOT EXISTS (
                  SELECT 1 FROM runtime_blob_key_rewrap_items AS i
                  WHERE i.job_id = ? AND i.blob_id = k.blob_id
              )
            ORDER BY k.blob_id
            """,
            bindings: [
                .text(job.jobID.rawValue), .integer(nowMS), .integer(nowMS),
                .text(job.sourceKeyID.rawValue), .integer(Int64(job.sourceKeyVersion)),
                .text(job.jobID.rawValue),
            ]
        )
        let changedJob = try database.execute(
            """
            UPDATE runtime_blob_key_rewrap_jobs
            SET total_envelope_count = (
                    SELECT COUNT(*) FROM runtime_blob_key_rewrap_items WHERE job_id = ?
                ), state_version = state_version + 1, updated_at_ms = ?
            WHERE job_id = ? AND job_state = 'active' AND state_version < ?
            """,
            bindings: [
                .text(job.jobID.rawValue), .integer(nowMS), .text(job.jobID.rawValue),
                .integer(Int64.max),
            ]
        )
        guard changedJob.changedRowCount == 1 else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
    }

    private static func countEnvelopes(
        keyID: RuntimeBlobKeyID,
        version: Int,
        database: isolated SQLiteDatabase
    ) throws -> Int {
        let rows = try database.query(
            """
            SELECT COUNT(*) AS total FROM runtime_blob_key_envelopes
            WHERE wrapping_key_id = ? AND wrapping_key_version = ?
            """,
            bindings: [.text(keyID.rawValue), .integer(Int64(version))]
        )
        guard rows.count == 1,
              case let .integer(total)? = rows[0].value(named: "total"), total >= 0 else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return Int(total)
    }

    private static func date(milliseconds: Int64) -> Date {
        Date(timeIntervalSince1970: Double(milliseconds) / 1_000)
    }
}
