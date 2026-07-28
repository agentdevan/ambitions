import AmbitionsRuntimeSQLite
import Foundation

enum RuntimeCanonicalGenerationMaintenanceOutcome: Sendable, Equatable {
    case idle
    /// Scrub shards are authenticated atomically and contain at most 128 rows.
    /// A smaller caller budget is rejected before any database query or claim.
    case configurationDeferred(minimumRows: Int)
    case progressed(generationID: String, kind: String, phase: String)
    case completed(generationID: String, kind: String)
    case quarantined(generationID: String, kind: String)
    case deferred(generationID: String, kind: String, reasonCode: String)
}

extension RuntimeCanonicalDerivedTransactionGateway {
    static func canonicalProjectionHasDependentSearchGeneration(
        _ projectionGenerationID: String,
        database: isolated SQLiteDatabase
    ) throws -> Bool {
        try database.query(
            "SELECT 1 FROM runtime_canonical_search_generations WHERE projection_generation_id = ? LIMIT 1",
            bindings: [.text(projectionGenerationID)]
        ).isEmpty == false
    }

    func blockCanonicalProjectionBuild(
        _ work: RuntimeCanonicalProjectionBuildWork,
        reasonCode: String,
        nowMilliseconds: Int64
    ) async throws {
        try await withDerivedImmediateTransaction { database in
            try Self.requireCanonicalProjectionBuildFence(
                work, phase: work.phase, database: database
            )
            let changed = try database.execute(
                """
                UPDATE runtime_canonical_projection_jobs
                SET phase = 'blocked', blocked_reason_code = ?, updated_at_ms = ?
                WHERE projection_id = ? AND generation_id = ? AND phase = ?
                  AND owner_id = ? AND fence_version = ?
                """,
                bindings: [
                    .text(reasonCode), .integer(nowMilliseconds),
                    .text(work.projectionID.rawValue), .text(work.generationID),
                    .text(work.phase.rawValue), .text(work.lease.ownerID),
                    .integer(Int64(work.lease.version)),
                ]
            )
            guard changed.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
            }
            try Self.recordCanonicalRepairRequirement(
                projectionID: work.projectionID.rawValue,
                generationID: work.generationID,
                authorityKind: "build", reasonCode: reasonCode,
                sourceCertificate: nil, nowMilliseconds: nowMilliseconds,
                database: database
            )
        }
    }

    /// Authenticates a persisted blocked result and moves it into bounded cleanup.
    /// Repair orchestration may call this after it has preserved or superseded the failure fact.
    func retireBlockedCanonicalProjectionBuild(
        projectionID: RuntimeCanonicalProjectionID,
        expectedGenerationID: String,
        expectedReasonCode: String,
        ownerID: String,
        nowMilliseconds: Int64
    ) async throws {
        try Task.checkCancellation()
        try await withDerivedImmediateTransaction { database in
            try CanonicalRuntimeProjectionSchemaPlan.requireIntegratedSchema(in: database)
            try Self.retireBlockedCanonicalProjectionBuildInTransaction(
                projectionID: projectionID,
                expectedGenerationID: expectedGenerationID,
                expectedReasonCode: expectedReasonCode,
                ownerID: ownerID, nowMilliseconds: nowMilliseconds,
                database: database
            )
        }
    }

    static func retireBlockedCanonicalProjectionBuildInTransaction(
        projectionID: RuntimeCanonicalProjectionID,
        expectedGenerationID: String,
        expectedReasonCode: String,
        ownerID: String,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        let rows = try database.query(
            """
            SELECT 1 FROM runtime_canonical_projection_jobs
            WHERE projection_id = ? AND generation_id = ? AND phase = 'blocked'
              AND blocked_reason_code = ? LIMIT 2
            """,
            bindings: [
                .text(projectionID.rawValue), .text(expectedGenerationID),
                .text(expectedReasonCode),
            ]
        )
        guard rows.count == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let lease = try Self.claimCanonicalProjectionLease(
            projectionID: projectionID, ownerID: ownerID,
            nowMilliseconds: nowMilliseconds, database: database
        )
        try Self.scheduleCanonicalProjectionBuildCleanup(
            projectionID: projectionID.rawValue,
            generationID: expectedGenerationID,
            ownerID: lease.ownerID,
            fenceVersion: Int64(lease.version),
            reasonCode: "blocked_build_retired:\(expectedReasonCode)",
            nowMilliseconds: nowMilliseconds,
            database: database
        )
    }

    /// Executes one bounded maintenance unit selected by persisted least-recent service.
    func runOneCanonicalGenerationMaintenanceUnit(
        ownerID: String,
        nowMilliseconds: Int64,
        maximumRows: Int = 128
    ) async throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        try Task.checkCancellation()
        guard let rowLimit = Self.canonicalMaintenanceRowLimit(maximumRows: maximumRows) else {
            return .configurationDeferred(minimumRows: 128)
        }
        return try await withDerivedImmediateTransaction { database in
            try Self.runOneCanonicalGenerationMaintenanceUnitInTransaction(
                ownerID: ownerID, nowMilliseconds: nowMilliseconds,
                rowLimit: rowLimit, database: database
            )
        }
    }

    static func canonicalMaintenanceRowLimit(maximumRows: Int) -> Int? {
        guard maximumRows >= 128 else { return nil }
        return min(maximumRows, 128)
    }

    static func runOneCanonicalGenerationMaintenanceUnitInTransaction(
        ownerID: String,
        nowMilliseconds: Int64,
        maximumRows: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        guard let rowLimit = canonicalMaintenanceRowLimit(maximumRows: maximumRows) else {
            return .configurationDeferred(minimumRows: 128)
        }
        return try runOneCanonicalGenerationMaintenanceUnitInTransaction(
            ownerID: ownerID, nowMilliseconds: nowMilliseconds,
            rowLimit: rowLimit, database: database
        )
    }

    static func runOneCanonicalGenerationMaintenanceUnitInTransaction(
        ownerID: String,
        nowMilliseconds: Int64,
        rowLimit: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        try Task.checkCancellation()
        guard let candidate = try Self.nextCanonicalMaintenanceCandidate(
            ownerID: ownerID, nowMilliseconds: nowMilliseconds, database: database
        ) else { return .idle }
        switch candidate.queue {
        case "scrub":
            guard let scrub = try Self.claimCanonicalScrubJob(
                generationID: candidate.generationID, ownerID: ownerID,
                nowMilliseconds: nowMilliseconds, database: database
            ) else { return .idle }
            do {
                return try Self.runCanonicalScrubUnit(
                    scrub, rowLimit: rowLimit, nowMilliseconds: nowMilliseconds,
                    database: database
                )
            } catch RuntimeCanonicalProjectionPersistenceError.generationMismatch {
                return try Self.quarantineCanonicalScrub(
                    scrub, nowMilliseconds: nowMilliseconds, database: database
                )
            } catch RuntimeCanonicalProjectionPersistenceError.derivedArtifactCorrupt {
                return try Self.quarantineCanonicalScrub(
                    scrub, nowMilliseconds: nowMilliseconds, database: database
                )
            } catch RuntimeCanonicalSearchError.corruptIndex {
                return try Self.quarantineCanonicalScrub(
                    scrub, nowMilliseconds: nowMilliseconds, database: database
                )
            } catch let error as SQLiteError
                where Self.isCanonicalSQLiteCorruption(error) {
                return try Self.quarantineCanonicalScrub(
                    scrub, nowMilliseconds: nowMilliseconds, database: database
                )
            } catch is CancellationError {
                throw CancellationError()
            }
        case "gc":
            guard let gc = try Self.claimCanonicalGCJob(
                generationID: candidate.generationID, ownerID: ownerID,
                nowMilliseconds: nowMilliseconds, database: database
            ) else { return .idle }
            do {
                return try Self.runCanonicalGCUnit(gc, rowLimit: rowLimit, database: database)
            } catch let error as SQLiteError where Self.isCanonicalSQLiteCorruption(error) {
                return try Self.quarantineCanonicalMaintenanceFailure(
                    generationID: gc.generationID, kind: gc.kind,
                    expectedCertificate: gc.expectedCertificate,
                    nowMilliseconds: nowMilliseconds, database: database
                )
            }
        case "cleanup":
            guard let cleanup = try Self.claimCanonicalCleanupJob(
                generationID: candidate.generationID, ownerID: ownerID,
                nowMilliseconds: nowMilliseconds, database: database
            ) else { return .idle }
            do {
                return try Self.runCanonicalCleanupUnit(
                    cleanup, rowLimit: rowLimit, database: database
                )
            } catch let error as SQLiteError where Self.isCanonicalSQLiteCorruption(error) {
                return try Self.quarantineCanonicalMaintenanceFailure(
                    generationID: cleanup.generationID, kind: "build",
                    expectedCertificate: nil, projectionID: cleanup.projectionID,
                    nowMilliseconds: nowMilliseconds, database: database
                )
            }
        default:
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
    }

    /// Quarantines authenticated derived corruption and schedules bounded cleanup.
    func quarantineAndRestartCanonicalProjectionBuild(
        _ work: RuntimeCanonicalProjectionBuildWork,
        scope: RuntimeCanonicalProjectionRecoveryScope,
        nowMilliseconds: Int64
    ) async throws {
        try Task.checkCancellation()
        try await withDerivedImmediateTransaction { database in
            try Self.quarantineAndRestartCanonicalProjectionBuildInTransaction(
                work, scope: scope, nowMilliseconds: nowMilliseconds,
                database: database
            )
        }
    }

    static func quarantineAndRestartCanonicalProjectionBuildInTransaction(
        _ work: RuntimeCanonicalProjectionBuildWork,
        scope: RuntimeCanonicalProjectionRecoveryScope,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        try requireCanonicalProjectionBuildFence(
            work, phase: work.phase, database: database
        )
        let marked = try database.execute(
            """
            UPDATE runtime_canonical_projection_jobs SET phase = 'recovering'
            WHERE projection_id = ? AND generation_id = ? AND phase = ?
              AND owner_id = ? AND fence_version = ?
            """,
            bindings: [
                .text(work.projectionID.rawValue), .text(work.generationID),
                .text(work.phase.rawValue), .text(work.lease.ownerID),
                .integer(Int64(work.lease.version)),
            ]
        )
        guard marked.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        let reasonCode: String = switch scope {
        case .baseProjection: "derived_base_authority_mismatch"
        case .projection: "derived_target_authority_mismatch"
        case .search: "derived_search_authority_mismatch"
        }
        let quarantineID = RuntimeTransactionDigest.digest([
            "runtime.projection.build-quarantine.v1", work.projectionID.rawValue,
            work.generationID, scope.rawValue, work.phase.rawValue, reasonCode,
            work.rollingRootDigest,
        ])
        try database.execute(
            """
            INSERT OR IGNORE INTO runtime_canonical_projection_quarantine(
                quarantine_id, projection_id, generation_id, artifact_kind,
                artifact_id, artifact_digest, reason_code, observed_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(quarantineID), .text(work.projectionID.rawValue),
                .text(work.generationID), .text(scope.rawValue),
                .text(work.phase.rawValue), .text(work.rollingRootDigest),
                .text(reasonCode), .integer(nowMilliseconds),
            ]
        )
        if scope == .baseProjection, let baseID = work.baseGenerationID {
            try recordCanonicalRepairRequirement(
                projectionID: work.projectionID.rawValue, generationID: baseID,
                authorityKind: "projection", reasonCode: reasonCode,
                sourceCertificate: work.baseCertificateDigest,
                nowMilliseconds: nowMilliseconds, database: database
            )
        }
        try scheduleCanonicalProjectionBuildCleanup(
            projectionID: work.projectionID.rawValue,
            generationID: work.generationID,
            ownerID: work.lease.ownerID,
            fenceVersion: Int64(work.lease.version),
            reasonCode: reasonCode,
            nowMilliseconds: nowMilliseconds,
            jobAlreadyRecovering: true,
            database: database
        )
    }

    static func scheduleCanonicalProjectionBuildCleanup(
        projectionID: String,
        generationID: String,
        ownerID: String,
        fenceVersion: Int64,
        reasonCode: String,
        nowMilliseconds: Int64,
        jobAlreadyRecovering: Bool = false,
        database: isolated SQLiteDatabase
    ) throws {
        if jobAlreadyRecovering == false {
            let marked = try database.execute(
                """
                UPDATE runtime_canonical_projection_jobs
                SET phase = 'recovering', blocked_reason_code = NULL,
                    owner_id = ?, fence_version = ?, updated_at_ms = ?
                WHERE projection_id = ? AND generation_id = ?
                  AND EXISTS (
                      SELECT 1 FROM runtime_canonical_projection_leases AS lease
                      WHERE lease.projection_id = runtime_canonical_projection_jobs.projection_id
                        AND lease.owner_id = ? AND lease.lease_version = ?
                  )
                """,
                bindings: [
                    .text(ownerID), .integer(fenceVersion), .integer(nowMilliseconds),
                    .text(projectionID), .text(generationID),
                    .text(ownerID), .integer(fenceVersion),
                ]
            )
            guard marked.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
            }
        }
        let searchRows = try database.query(
            "SELECT generation_id FROM runtime_canonical_search_generations WHERE projection_generation_id = ? LIMIT 2",
            bindings: [.text(generationID)]
        )
        guard searchRows.count <= 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let searchGenerationID: String?
        if let row = searchRows.first {
            guard case let .text(value)? = row.value(named: "generation_id") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            searchGenerationID = value
            let abandonedSearch = try database.execute(
                """
                UPDATE runtime_canonical_search_generations
                SET status = 'abandoned', generation_certificate_digest = NULL
                WHERE generation_id = ? AND status IN ('building', 'sealed')
                """,
                bindings: [.text(value)]
            )
            guard abandonedSearch.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
        } else { searchGenerationID = nil }
        let abandonedProjection = try database.execute(
            """
            UPDATE runtime_canonical_projection_generations
            SET status = 'abandoned', generation_certificate_digest = NULL
            WHERE generation_id = ? AND projection_id = ?
              AND status IN ('building', 'sealed')
            """,
            bindings: [.text(generationID), .text(projectionID)]
        )
        guard abandonedProjection.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let firstPhase = searchGenerationID == nil ? "projection_entries" : "search_postings"
        try enqueueCanonicalBuildCleanup(
            generationID: generationID, projectionID: projectionID,
            searchGenerationID: searchGenerationID, firstPhase: firstPhase,
            reasonCode: reasonCode, nowMilliseconds: nowMilliseconds,
            database: database
        )
        let deletedJob = try database.execute(
            """
            DELETE FROM runtime_canonical_projection_jobs
            WHERE projection_id = ? AND generation_id = ? AND phase = 'recovering'
              AND owner_id = ? AND fence_version = ?
            """,
            bindings: [
                .text(projectionID), .text(generationID),
                .text(ownerID), .integer(fenceVersion),
            ]
        )
        guard deletedJob.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        let released = try database.execute(
            """
            DELETE FROM runtime_canonical_projection_leases
            WHERE projection_id = ? AND owner_id = ? AND lease_version = ?
            """,
            bindings: [.text(projectionID), .text(ownerID), .integer(fenceVersion)]
        )
        guard released.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
    }

    static func enqueueCanonicalBuildCleanup(
        generationID: String,
        projectionID: String,
        searchGenerationID: String?,
        firstPhase: String,
        reasonCode: String,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        let existing = try database.query(
            """
            SELECT projection_id, search_generation_id, phase, reason_code
            FROM runtime_canonical_build_cleanup_jobs
            WHERE generation_id = ? LIMIT 2
            """,
            bindings: [.text(generationID)]
        )
        if let existingJob = existing.first {
            guard existing.count == 1,
                  existingJob.value(named: "projection_id") == .text(projectionID),
                  existingJob.value(named: "search_generation_id") ==
                    (searchGenerationID.map(SQLiteValue.text) ?? .null),
                  existingJob.value(named: "phase") == .text(firstPhase),
                  existingJob.value(named: "reason_code") == .text(reasonCode) else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            return
        }
        let serviceTicket = try issueCanonicalServiceTicket(database: database)
        try database.execute(
            """
            INSERT INTO runtime_canonical_build_cleanup_jobs(
                generation_id, projection_id, search_generation_id, phase,
                after_aggregate_kind, after_aggregate_id, reason_code,
                owner_id, fence_version, expires_at_ms, last_served_at_ms,
                service_ticket
            ) VALUES (?, ?, ?, ?, '', '', ?, 'unclaimed', 1, ?, ?, ?)
            """,
            bindings: [
                .text(generationID), .text(projectionID),
                searchGenerationID.map(SQLiteBinding.text) ?? .null,
                .text(firstPhase), .text(reasonCode),
                .integer(nowMilliseconds), .integer(nowMilliseconds),
                .integer(serviceTicket),
            ]
        )
    }

    static func recordCanonicalRepairRequirement(
        projectionID: String,
        generationID: String?,
        authorityKind: String,
        reasonCode: String,
        sourceCertificate: String?,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        let incidentKey = RuntimeTransactionDigest.digest([
            "runtime.canonical.repair-incident.v1", projectionID,
            generationID ?? "", authorityKind, reasonCode, sourceCertificate ?? "",
        ])
        try database.execute(
            """
            INSERT OR IGNORE INTO runtime_canonical_repair_incidents(
                incident_key, projection_id, generation_id, authority_kind,
                reason_code, source_certificate_digest,
                next_occurrence_ordinal, active_requirement_id
            ) VALUES (?, ?, ?, ?, ?, ?, 0, NULL)
            """,
            bindings: [
                .text(incidentKey), .text(projectionID),
                generationID.map(SQLiteBinding.text) ?? .null,
                .text(authorityKind), .text(reasonCode),
                sourceCertificate.map(SQLiteBinding.text) ?? .null,
            ]
        )
        let incidents = try database.query(
            """
            SELECT projection_id, generation_id, authority_kind, reason_code,
                   source_certificate_digest, next_occurrence_ordinal,
                   active_requirement_id
            FROM runtime_canonical_repair_incidents
            WHERE incident_key = ? LIMIT 2
            """,
            bindings: [.text(incidentKey)]
        )
        guard incidents.count == 1,
              incidents[0].value(named: "projection_id") == .text(projectionID),
              incidents[0].value(named: "generation_id") ==
                (generationID.map(SQLiteValue.text) ?? .null),
              incidents[0].value(named: "authority_kind") == .text(authorityKind),
              incidents[0].value(named: "reason_code") == .text(reasonCode),
              incidents[0].value(named: "source_certificate_digest") ==
                (sourceCertificate.map(SQLiteValue.text) ?? .null),
              case let .integer(occurrence)? = incidents[0]
                .value(named: "next_occurrence_ordinal"),
              occurrence >= 0, occurrence < Int64.max else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        if case .text? = incidents[0].value(named: "active_requirement_id") { return }
        guard incidents[0].value(named: "active_requirement_id") == .null else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let requirementID = RuntimeTransactionDigest.digest([
            "runtime.canonical.repair-required.v3", incidentKey, String(occurrence),
        ])
        try database.execute(
            """
            INSERT INTO runtime_canonical_repair_requirements(
                requirement_id, projection_id, generation_id, authority_kind,
                reason_code, source_certificate_digest, state,
                observed_at_ms, resolved_at_ms, resolution_digest
            ) VALUES (?, ?, ?, ?, ?, ?, 'required', ?, NULL, NULL)
            """,
            bindings: [
                .text(requirementID), .text(projectionID),
                generationID.map(SQLiteBinding.text) ?? .null,
                .text(authorityKind), .text(reasonCode),
                sourceCertificate.map(SQLiteBinding.text) ?? .null,
                .integer(nowMilliseconds),
            ]
        )
        let advanced = try database.execute(
            """
            UPDATE runtime_canonical_repair_incidents
            SET next_occurrence_ordinal = ?, active_requirement_id = ?
            WHERE incident_key = ? AND next_occurrence_ordinal = ?
              AND active_requirement_id IS NULL
            """,
            bindings: [
                .integer(occurrence + 1), .text(requirementID),
                .text(incidentKey), .integer(occurrence),
            ]
        )
        guard advanced.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
    }

    static func canonicalScrubCertificateDigest(
        generationID: String,
        kind: String,
        projectionID: String,
        generationCertificate: String,
        observedCount: Int,
        observedShardCount: Int,
        observedPostingCount: Int,
        observedPostingBytes: Int,
        rootDigest: String,
        completedAtMilliseconds: Int64
    ) -> String {
        RuntimeTransactionDigest.digest([
            "runtime.canonical.scrub-certificate.v2", generationID, kind,
            projectionID, generationCertificate, String(observedCount),
            String(observedShardCount), String(observedPostingCount),
            String(observedPostingBytes), rootDigest,
            String(completedAtMilliseconds),
        ])
    }
}

private struct RuntimeCanonicalMaintenanceCandidate: Sendable {
    let queue: String
    let generationID: String
}

private struct RuntimeCanonicalMaintenanceJob: Sendable {
    let generationID: String
    let kind: String
    let phase: String
    let afterKind: String
    let afterID: String
    let shardOrdinal: Int
    let observedCount: Int
    let observedPostingCount: Int
    let observedPostingBytes: Int
    let expectedPostingCount: Int
    let expectedPostingBytes: Int
    let observedPrivacyCounts: [EventLedgerPrivacyClassification: Int]
    let observedNonlocalCount: Int
    let afterPostingToken: String
    let afterPostingKind: String
    let afterPostingID: String
    let afterPostingField: Int
    let afterPostingOrdinal: Int
    let rollingRootDigest: String
    let previousLastKind: String
    let previousLastID: String
    let ownerID: String
    let fenceVersion: Int64
    let expiresAtMilliseconds: Int64
    let expectedCertificate: String
}

private struct RuntimeCanonicalScrubProgress: Sendable {
    let count: Int
    let expectedPostingCount: Int
    let expectedPostingBytes: Int
    let privacyCounts: [EventLedgerPrivacyClassification: Int]
    let nonlocalCount: Int
    let lastKind: String
    let lastID: String
    let rootDigest: String
}

private struct RuntimeCanonicalCleanupJob: Sendable {
    let generationID: String
    let projectionID: String
    let searchGenerationID: String?
    let phase: String
    let afterKind: String
    let afterID: String
    let reasonCode: String
    let ownerID: String
    let fenceVersion: Int64
    let expiresAtMilliseconds: Int64
}

private extension RuntimeCanonicalDerivedTransactionGateway {
    static func nextCanonicalMaintenanceCandidate(
        ownerID: String,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalMaintenanceCandidate? {
        let rows = try database.query(
            """
            SELECT queue, generation_id FROM (
                SELECT 'scrub' AS queue, generation_id, service_ticket
                FROM runtime_canonical_generation_scrub_jobs
                WHERE (expires_at_ms <= ? OR owner_id = ?)
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_canonical_repair_requirements AS repair
                      WHERE repair.generation_id = runtime_canonical_generation_scrub_jobs.generation_id
                        AND repair.state = 'required'
                  )
                UNION ALL
                SELECT 'gc', generation_id, service_ticket
                FROM runtime_canonical_generation_gc_jobs
                WHERE (expires_at_ms <= ? OR owner_id = ?)
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_canonical_repair_requirements AS repair
                      WHERE repair.generation_id = runtime_canonical_generation_gc_jobs.generation_id
                        AND repair.state = 'required'
                  )
                UNION ALL
                SELECT 'cleanup', generation_id, service_ticket
                FROM runtime_canonical_build_cleanup_jobs
                WHERE (expires_at_ms <= ? OR owner_id = ?)
                  AND NOT EXISTS (
                      SELECT 1 FROM runtime_canonical_repair_requirements AS repair
                      WHERE repair.generation_id = runtime_canonical_build_cleanup_jobs.generation_id
                        AND repair.state = 'required'
                  )
            )
            -- Service tickets are globally monotonic in production. The final
            -- keys make preexisting/corrupt duplicate tickets deterministic.
            ORDER BY service_ticket, queue, generation_id LIMIT 1
            """,
            bindings: [
                .integer(nowMilliseconds), .text(ownerID),
                .integer(nowMilliseconds), .text(ownerID),
                .integer(nowMilliseconds), .text(ownerID),
            ]
        )
        guard let row = rows.first else { return nil }
        guard case let .text(queue)? = row.value(named: "queue"),
              case let .text(generationID)? = row.value(named: "generation_id") else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        return RuntimeCanonicalMaintenanceCandidate(queue: queue, generationID: generationID)
    }

    static func claimCanonicalScrubJob(
        generationID: String,
        ownerID: String,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalMaintenanceJob? {
        let expires = nowMilliseconds.addingReportingOverflow(30_000)
        guard expires.overflow == false else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        let serviceTicket = try issueCanonicalServiceTicket(database: database)
        let changed = try database.execute(
            """
            UPDATE runtime_canonical_generation_scrub_jobs
            SET owner_id = ?, fence_version = fence_version + 1, expires_at_ms = ?,
                last_served_at_ms = ?, service_ticket = ?
            WHERE generation_id = ? AND (expires_at_ms <= ? OR owner_id = ?)
            """,
            bindings: [
                .text(ownerID), .integer(expires.partialValue), .integer(nowMilliseconds),
                .integer(serviceTicket),
                .text(generationID),
                .integer(nowMilliseconds), .text(ownerID),
            ]
        )
        guard changed.changedRowCount == 1 else { return nil }
        let rows = try database.query(
            "SELECT * FROM runtime_canonical_generation_scrub_jobs WHERE generation_id = ? LIMIT 2",
            bindings: [.text(generationID)]
        )
        return try decodeCanonicalMaintenanceJob(
            rows: rows, includesKeyset: false, expectedOwner: ownerID,
            expectedExpiry: expires.partialValue
        )
    }

    static func claimCanonicalGCJob(
        generationID: String,
        ownerID: String,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalMaintenanceJob? {
        let expires = nowMilliseconds.addingReportingOverflow(30_000)
        guard expires.overflow == false else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        let serviceTicket = try issueCanonicalServiceTicket(database: database)
        let changed = try database.execute(
            """
            UPDATE runtime_canonical_generation_gc_jobs
            SET owner_id = ?, fence_version = fence_version + 1, expires_at_ms = ?,
                last_served_at_ms = ?, service_ticket = ?
            WHERE generation_id = ? AND (expires_at_ms <= ? OR owner_id = ?)
            """,
            bindings: [
                .text(ownerID), .integer(expires.partialValue), .integer(nowMilliseconds),
                .integer(serviceTicket),
                .text(generationID),
                .integer(nowMilliseconds), .text(ownerID),
            ]
        )
        guard changed.changedRowCount == 1 else { return nil }
        let rows = try database.query(
            "SELECT * FROM runtime_canonical_generation_gc_jobs WHERE generation_id = ? LIMIT 2",
            bindings: [.text(generationID)]
        )
        return try decodeCanonicalMaintenanceJob(
            rows: rows, includesKeyset: true, expectedOwner: ownerID,
            expectedExpiry: expires.partialValue
        )
    }

    static func claimCanonicalCleanupJob(
        generationID: String,
        ownerID: String,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalCleanupJob? {
        let expires = nowMilliseconds.addingReportingOverflow(30_000)
        guard expires.overflow == false else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        let serviceTicket = try issueCanonicalServiceTicket(database: database)
        let changed = try database.execute(
            """
            UPDATE runtime_canonical_build_cleanup_jobs
            SET owner_id = ?, fence_version = fence_version + 1,
                expires_at_ms = ?, last_served_at_ms = ?, service_ticket = ?
            WHERE generation_id = ? AND (expires_at_ms <= ? OR owner_id = ?)
            """,
            bindings: [
                .text(ownerID), .integer(expires.partialValue), .integer(nowMilliseconds),
                .integer(serviceTicket),
                .text(generationID), .integer(nowMilliseconds), .text(ownerID),
            ]
        )
        guard changed.changedRowCount == 1 else { return nil }
        let rows = try database.query(
            "SELECT * FROM runtime_canonical_build_cleanup_jobs WHERE generation_id = ? LIMIT 2",
            bindings: [.text(generationID)]
        )
        guard rows.count == 1,
              case let .text(projectionID)? = rows[0].value(named: "projection_id"),
              case let .text(phase)? = rows[0].value(named: "phase"),
              case let .text(afterKind)? = rows[0].value(named: "after_aggregate_kind"),
              case let .text(afterID)? = rows[0].value(named: "after_aggregate_id"),
              case let .text(reasonCode)? = rows[0].value(named: "reason_code"),
              rows[0].value(named: "owner_id") == .text(ownerID),
              case let .integer(fence)? = rows[0].value(named: "fence_version"), fence > 0,
              rows[0].value(named: "expires_at_ms") == .integer(expires.partialValue) else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        let searchGenerationID: String?
        switch rows[0].value(named: "search_generation_id") {
        case let .text(value)?: searchGenerationID = value
        case .null?, nil: searchGenerationID = nil
        default: throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        return RuntimeCanonicalCleanupJob(
            generationID: generationID, projectionID: projectionID,
            searchGenerationID: searchGenerationID, phase: phase,
            afterKind: afterKind, afterID: afterID, reasonCode: reasonCode,
            ownerID: ownerID, fenceVersion: fence,
            expiresAtMilliseconds: expires.partialValue
        )
    }

    static func decodeCanonicalMaintenanceJob(
        rows: [SQLiteRow],
        includesKeyset: Bool,
        expectedOwner: String,
        expectedExpiry: Int64
    ) throws -> RuntimeCanonicalMaintenanceJob {
        guard rows.count == 1,
              case let .text(generationID)? = rows[0].value(named: "generation_id"),
              case let .text(kind)? = rows[0].value(named: "generation_kind"),
              case let .text(phase)? = rows[0].value(named: "phase"),
              case let .text(owner)? = rows[0].value(named: "owner_id"),
              owner == expectedOwner,
              case let .integer(fence)? = rows[0].value(named: "fence_version"), fence > 0,
              rows[0].value(named: "expires_at_ms") == .integer(expectedExpiry),
              case let .text(certificate)? = rows[0].value(named: "expected_certificate_digest") else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        let afterKind: String
        let afterID: String
        if includesKeyset {
            guard case let .text(kindValue)? = rows[0].value(named: "after_aggregate_kind"),
                  case let .text(idValue)? = rows[0].value(named: "after_aggregate_id") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            afterKind = kindValue
            afterID = idValue
        } else {
            afterKind = ""
            afterID = ""
        }
        let ordinal: Int
        if case let .integer(value)? = rows[0].value(named: "shard_ordinal"), value >= 0 {
            ordinal = Int(value)
        } else { ordinal = 0 }
        func nonnegativeInteger(_ name: String) throws -> Int {
            guard case let .integer(value)? = rows[0].value(named: name), value >= 0 else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            return Int(value)
        }
        func textOrEmpty(_ name: String) throws -> String {
            if case let .text(value)? = rows[0].value(named: name) { return value }
            if includesKeyset { return "" }
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let observedCount: Int
        let observedPostingCount: Int
        let observedPostingBytes: Int
        let expectedPostingCount: Int
        let expectedPostingBytes: Int
        let observedPrivacyCounts: [EventLedgerPrivacyClassification: Int]
        let observedNonlocalCount: Int
        let afterPostingToken: String
        let afterPostingKind: String
        let afterPostingID: String
        let afterPostingField: Int
        let afterPostingOrdinal: Int
        let rollingRoot: String
        let previousLastKind: String
        let previousLastID: String
        if includesKeyset {
            observedCount = 0
            observedPostingCount = 0
            observedPostingBytes = 0
            expectedPostingCount = 0
            expectedPostingBytes = 0
            observedPrivacyCounts = [:]
            observedNonlocalCount = 0
            afterPostingToken = ""
            afterPostingKind = ""
            afterPostingID = ""
            afterPostingField = -1
            afterPostingOrdinal = -1
            rollingRoot = RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal
            previousLastKind = ""
            previousLastID = ""
        } else {
            observedCount = try nonnegativeInteger("observed_count")
            observedPostingCount = try nonnegativeInteger("observed_posting_count")
            observedPostingBytes = try nonnegativeInteger("observed_posting_bytes")
            expectedPostingCount = try nonnegativeInteger("expected_posting_count")
            expectedPostingBytes = try nonnegativeInteger("expected_posting_bytes")
            observedPrivacyCounts = [
                .standard: try nonnegativeInteger("observed_privacy_standard_count"),
                .sensitive: try nonnegativeInteger("observed_privacy_sensitive_count"),
                .privateUserText: try nonnegativeInteger("observed_privacy_private_text_count"),
                .calendarDerived: try nonnegativeInteger("observed_privacy_calendar_count"),
                .syncMetadata: try nonnegativeInteger("observed_privacy_sync_count"),
            ]
            observedNonlocalCount = try nonnegativeInteger("observed_nonlocal_count")
            afterPostingToken = try textOrEmpty("after_posting_token")
            afterPostingKind = try textOrEmpty("after_posting_kind")
            afterPostingID = try textOrEmpty("after_posting_id")
            guard case let .integer(field)? = rows[0].value(named: "after_posting_field"),
                  case let .integer(postingOrdinal)? = rows[0].value(named: "after_posting_ordinal") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            afterPostingField = Int(field)
            afterPostingOrdinal = Int(postingOrdinal)
            rollingRoot = try textOrEmpty("rolling_root_digest")
            previousLastKind = try textOrEmpty("previous_last_kind")
            previousLastID = try textOrEmpty("previous_last_id")
        }
        return RuntimeCanonicalMaintenanceJob(
            generationID: generationID, kind: kind, phase: phase,
            afterKind: afterKind, afterID: afterID, shardOrdinal: ordinal,
            observedCount: observedCount,
            observedPostingCount: observedPostingCount,
            observedPostingBytes: observedPostingBytes,
            expectedPostingCount: expectedPostingCount,
            expectedPostingBytes: expectedPostingBytes,
            observedPrivacyCounts: observedPrivacyCounts,
            observedNonlocalCount: observedNonlocalCount,
            afterPostingToken: afterPostingToken,
            afterPostingKind: afterPostingKind,
            afterPostingID: afterPostingID,
            afterPostingField: afterPostingField,
            afterPostingOrdinal: afterPostingOrdinal,
            rollingRootDigest: rollingRoot,
            previousLastKind: previousLastKind,
            previousLastID: previousLastID,
            ownerID: owner, fenceVersion: fence,
            expiresAtMilliseconds: expectedExpiry, expectedCertificate: certificate
        )
    }

    static func runCanonicalScrubUnit(
        _ job: RuntimeCanonicalMaintenanceJob,
        rowLimit: Int,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        try requireCanonicalScrubAuthority(job, database: database)
        guard job.phase == "shards" || (job.kind == "search" && job.phase == "postings") else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        if job.phase == "postings" {
            return try scrubCanonicalSearchPostingPage(
                job, rowLimit: rowLimit, nowMilliseconds: nowMilliseconds,
                database: database
            )
        }
        let shardTable = job.kind == "search"
            ? "runtime_canonical_search_shards"
            : "runtime_canonical_projection_shards"
        let shards = try database.query(
            "SELECT * FROM \(shardTable) WHERE generation_id = ? AND shard_ordinal = ? LIMIT 2",
            bindings: [.text(job.generationID), .integer(Int64(job.shardOrdinal))]
        )
        if shards.isEmpty {
            // Absence of the next exact ordinal is terminal only when no gap or
            // orphan suffix shard exists at a later ordinal.
            let suffixShard = try database.query(
                "SELECT shard_ordinal FROM \(shardTable) WHERE generation_id = ? AND shard_ordinal >= ? ORDER BY shard_ordinal LIMIT 1",
                bindings: [.text(job.generationID), .integer(Int64(job.shardOrdinal))]
            )
            guard suffixShard.isEmpty else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            if job.kind == "search" {
                let changed = try database.execute(
                    """
                    UPDATE runtime_canonical_generation_scrub_jobs
                    SET phase = 'postings', after_posting_token = '',
                        after_posting_kind = '', after_posting_id = '',
                        after_posting_field = -1, after_posting_ordinal = -1
                    WHERE generation_id = ? AND phase = 'shards'
                      AND owner_id = ? AND fence_version = ? AND expires_at_ms = ?
                    """,
                    bindings: [
                        .text(job.generationID), .text(job.ownerID),
                        .integer(job.fenceVersion), .integer(job.expiresAtMilliseconds),
                    ]
                )
                guard changed.changedRowCount == 1 else {
                    throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
                }
                return .progressed(
                    generationID: job.generationID, kind: job.kind, phase: "postings"
                )
            }
            try completeCanonicalScrub(
                job, nowMilliseconds: nowMilliseconds, database: database
            )
            let deleted = try database.execute(
                "DELETE FROM runtime_canonical_generation_scrub_jobs WHERE generation_id = ? AND owner_id = ? AND fence_version = ?",
                bindings: [
                    .text(job.generationID), .text(job.ownerID),
                    .integer(job.fenceVersion),
                ]
            )
            guard deleted.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
            }
            return .completed(generationID: job.generationID, kind: job.kind)
        }
        guard shards.count == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let progress: RuntimeCanonicalScrubProgress
        if job.kind == "search" {
            progress = try scrubCanonicalSearchShard(
                job, shard: shards[0], rowLimit: rowLimit, database: database
            )
        } else if job.kind == "projection" {
            progress = try scrubCanonicalProjectionShard(
                job, shard: shards[0], rowLimit: rowLimit, database: database
            )
        } else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let changed = try database.execute(
            """
            UPDATE runtime_canonical_generation_scrub_jobs
            SET shard_ordinal = shard_ordinal + 1,
                observed_count = observed_count + ?,
                expected_posting_count = expected_posting_count + ?,
                expected_posting_bytes = expected_posting_bytes + ?,
                observed_privacy_standard_count = observed_privacy_standard_count + ?,
                observed_privacy_sensitive_count = observed_privacy_sensitive_count + ?,
                observed_privacy_private_text_count = observed_privacy_private_text_count + ?,
                observed_privacy_calendar_count = observed_privacy_calendar_count + ?,
                observed_privacy_sync_count = observed_privacy_sync_count + ?,
                observed_nonlocal_count = observed_nonlocal_count + ?,
                rolling_root_digest = ?, previous_last_kind = ?, previous_last_id = ?
            WHERE generation_id = ? AND owner_id = ? AND fence_version = ?
              AND expires_at_ms = ?
            """,
            bindings: [
                .integer(Int64(progress.count)),
                .integer(Int64(progress.expectedPostingCount)),
                .integer(Int64(progress.expectedPostingBytes)),
                .integer(Int64(progress.privacyCounts[.standard, default: 0])),
                .integer(Int64(progress.privacyCounts[.sensitive, default: 0])),
                .integer(Int64(progress.privacyCounts[.privateUserText, default: 0])),
                .integer(Int64(progress.privacyCounts[.calendarDerived, default: 0])),
                .integer(Int64(progress.privacyCounts[.syncMetadata, default: 0])),
                .integer(Int64(progress.nonlocalCount)), .text(progress.rootDigest),
                .text(progress.lastKind), .text(progress.lastID), .text(job.generationID),
                .text(job.ownerID), .integer(job.fenceVersion),
                .integer(job.expiresAtMilliseconds),
            ]
        )
        guard changed.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        return .progressed(generationID: job.generationID, kind: job.kind, phase: "shards")
    }

    static func scrubCanonicalProjectionShard(
        _ job: RuntimeCanonicalMaintenanceJob,
        shard: SQLiteRow,
        rowLimit: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalScrubProgress {
        guard case let .text(firstKind)? = shard.value(named: "first_aggregate_kind"),
              case let .text(firstID)? = shard.value(named: "first_aggregate_id"),
              case let .text(lastKind)? = shard.value(named: "last_aggregate_kind"),
              case let .text(lastID)? = shard.value(named: "last_aggregate_id"),
              case let .integer(count)? = shard.value(named: "entry_count"),
              count > 0, count <= 128,
              case let .text(prior)? = shard.value(named: "prior_shard_digest"),
              case let .text(storedDigest)? = shard.value(named: "shard_digest") else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        guard prior == job.rollingRootDigest else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        guard count <= Int64(rowLimit) else {
            throw RuntimeCanonicalProjectionPersistenceError.unitBudgetExceeded
        }
        try requireCanonicalShardBoundary(
            job, table: "runtime_canonical_projection_entries",
            firstKind: firstKind, firstID: firstID, database: database
        )
        let rows = try database.query(
            """
            SELECT aggregate_kind, aggregate_id, revision, lifecycle,
                   canonical_state_bytes, canonical_state_digest, privacy, local_only,
                   source_sequence, source_event_id, source_event_hash, entry_digest
            FROM runtime_canonical_projection_entries
            WHERE generation_id = ?
              AND (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id >= ?))
              AND (aggregate_kind < ? OR (aggregate_kind = ? AND aggregate_id <= ?))
            ORDER BY aggregate_kind, aggregate_id LIMIT ?
            """,
            bindings: [
                .text(job.generationID), .text(firstKind), .text(firstKind), .text(firstID),
                .text(lastKind), .text(lastKind), .text(lastID), .integer(count + 1),
            ], maximumDecodedBytes: RuntimeCanonicalProjectionWorker.maximumBytesPerUnit
        )
        guard rows.count == Int(count) else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        var material = [
            "runtime.projection.shard.v1", job.generationID,
            String(job.shardOrdinal), prior,
        ]
        var privacyCounts: [EventLedgerPrivacyClassification: Int] = [:]
        var nonlocalCount = 0
        for row in rows {
            try Task.checkCancellation()
            let entry = try decodeCanonicalProjectionEntry(row)
            guard case let .text(digest)? = row.value(named: "entry_digest") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            material += [entry.aggregate.kind.rawValue, entry.aggregate.id.rawValue, digest]
            privacyCounts[entry.privacy, default: 0] += 1
            if entry.localOnly == false { nonlocalCount += 1 }
        }
        guard RuntimeTransactionDigest.digest(material) == storedDigest else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        guard rows.first?.value(named: "aggregate_kind") == .text(firstKind),
              rows.first?.value(named: "aggregate_id") == .text(firstID),
              rows.last?.value(named: "aggregate_kind") == .text(lastKind),
              rows.last?.value(named: "aggregate_id") == .text(lastID) else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        return RuntimeCanonicalScrubProgress(
            count: Int(count), expectedPostingCount: 0, expectedPostingBytes: 0,
            privacyCounts: privacyCounts, nonlocalCount: nonlocalCount,
            lastKind: lastKind, lastID: lastID, rootDigest: storedDigest
        )
    }

    static func scrubCanonicalSearchShard(
        _ job: RuntimeCanonicalMaintenanceJob,
        shard: SQLiteRow,
        rowLimit: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalScrubProgress {
        guard case let .text(firstKind)? = shard.value(named: "first_aggregate_kind"),
              case let .text(firstID)? = shard.value(named: "first_aggregate_id"),
              case let .text(lastKind)? = shard.value(named: "last_aggregate_kind"),
              case let .text(lastID)? = shard.value(named: "last_aggregate_id"),
              case let .integer(count)? = shard.value(named: "document_count"),
              count > 0, count <= 128,
              case let .text(prior)? = shard.value(named: "prior_shard_digest"),
              case let .text(storedDigest)? = shard.value(named: "shard_digest") else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        guard prior == job.rollingRootDigest else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        guard count <= Int64(rowLimit) else {
            throw RuntimeCanonicalProjectionPersistenceError.unitBudgetExceeded
        }
        try requireCanonicalShardBoundary(
            job, table: "runtime_canonical_search_documents",
            firstKind: firstKind, firstID: firstID, database: database
        )
        let rows = try database.query(
            """
            SELECT aggregate_kind, aggregate_id, privacy, local_only, title, body,
                   source_sequence, source_event_id, source_event_hash, document_digest
            FROM runtime_canonical_search_documents
            WHERE generation_id = ?
              AND (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id >= ?))
              AND (aggregate_kind < ? OR (aggregate_kind = ? AND aggregate_id <= ?))
            ORDER BY aggregate_kind, aggregate_id LIMIT ?
            """,
            bindings: [
                .text(job.generationID), .text(firstKind), .text(firstKind), .text(firstID),
                .text(lastKind), .text(lastKind), .text(lastID), .integer(count + 1),
            ], maximumDecodedBytes: RuntimeCanonicalProjectionWorker.maximumBytesPerUnit
        )
        guard rows.count == Int(count) else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        var material = [
            "runtime.search.shard.v1", job.generationID,
            String(job.shardOrdinal), prior,
        ]
        var expectedPostingCount = 0
        var expectedPostingBytes = 0
        for row in rows {
            try Task.checkCancellation()
            let document = try decodeCanonicalSearchDocument(row, generationID: job.generationID)
            for (fieldOrdinal, value) in [document.title, document.body].enumerated() {
                for (tokenOrdinal, token) in canonicalSearchTokens(value).enumerated() {
                    let digest = RuntimeTransactionDigest.digest([
                        "runtime.search.posting.v1", job.generationID, token,
                        document.aggregate.kind.rawValue, document.aggregate.id.rawValue,
                        String(fieldOrdinal), String(tokenOrdinal), document.digest,
                    ])
                    expectedPostingCount += 1
                    expectedPostingBytes += token.utf8.count + digest.utf8.count
                        + document.aggregate.kind.rawValue.utf8.count
                        + document.aggregate.id.rawValue.utf8.count + 16
                }
            }
            material += [
                document.aggregate.kind.rawValue,
                document.aggregate.id.rawValue,
                document.digest,
            ]
        }
        guard RuntimeTransactionDigest.digest(material) == storedDigest else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        guard rows.first?.value(named: "aggregate_kind") == .text(firstKind),
              rows.first?.value(named: "aggregate_id") == .text(firstID),
              rows.last?.value(named: "aggregate_kind") == .text(lastKind),
              rows.last?.value(named: "aggregate_id") == .text(lastID) else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        return RuntimeCanonicalScrubProgress(
            count: Int(count), expectedPostingCount: expectedPostingCount,
            expectedPostingBytes: expectedPostingBytes,
            privacyCounts: [:], nonlocalCount: 0,
            lastKind: lastKind, lastID: lastID, rootDigest: storedDigest
        )
    }

    static func scrubCanonicalSearchPostingPage(
        _ job: RuntimeCanonicalMaintenanceJob,
        rowLimit: Int,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        let rows = try database.query(
            """
            SELECT normalized_token, aggregate_kind, aggregate_id,
                   field_ordinal, token_ordinal, posting_digest
            FROM runtime_canonical_search_postings
            WHERE generation_id = ? AND (
                normalized_token > ? OR
                (normalized_token = ? AND aggregate_kind > ?) OR
                (normalized_token = ? AND aggregate_kind = ? AND aggregate_id > ?) OR
                (normalized_token = ? AND aggregate_kind = ? AND aggregate_id = ?
                 AND field_ordinal > ?) OR
                (normalized_token = ? AND aggregate_kind = ? AND aggregate_id = ?
                 AND field_ordinal = ? AND token_ordinal > ?)
            )
            ORDER BY normalized_token, aggregate_kind, aggregate_id,
                     field_ordinal, token_ordinal LIMIT ?
            """,
            bindings: [
                .text(job.generationID), .text(job.afterPostingToken),
                .text(job.afterPostingToken), .text(job.afterPostingKind),
                .text(job.afterPostingToken), .text(job.afterPostingKind),
                .text(job.afterPostingID), .text(job.afterPostingToken),
                .text(job.afterPostingKind), .text(job.afterPostingID),
                .integer(Int64(job.afterPostingField)), .text(job.afterPostingToken),
                .text(job.afterPostingKind), .text(job.afterPostingID),
                .integer(Int64(job.afterPostingField)),
                .integer(Int64(job.afterPostingOrdinal)), .integer(Int64(rowLimit)),
            ], maximumDecodedBytes: rowLimit * 512
        )
        guard let last = rows.last else {
            guard job.observedPostingCount == job.expectedPostingCount,
                  job.observedPostingBytes == job.expectedPostingBytes else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            try completeCanonicalScrub(
                job, nowMilliseconds: nowMilliseconds, database: database
            )
            let deleted = try database.execute(
                """
                DELETE FROM runtime_canonical_generation_scrub_jobs
                WHERE generation_id = ? AND phase = 'postings'
                  AND owner_id = ? AND fence_version = ?
                """,
                bindings: [
                    .text(job.generationID), .text(job.ownerID), .integer(job.fenceVersion),
                ]
            )
            guard deleted.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
            }
            return .completed(generationID: job.generationID, kind: job.kind)
        }
        var postingBytes = 0
        for row in rows {
            try Task.checkCancellation()
            guard case let .text(token)? = row.value(named: "normalized_token"),
                  case let .text(kind)? = row.value(named: "aggregate_kind"),
                  case let .text(identifier)? = row.value(named: "aggregate_id"),
                  case let .integer(field)? = row.value(named: "field_ordinal"),
                  case let .integer(ordinal)? = row.value(named: "token_ordinal"),
                  case let .text(storedDigest)? = row.value(named: "posting_digest"),
                  field == 0 || field == 1, ordinal >= 0 else {
                throw RuntimeCanonicalSearchError.corruptIndex
            }
            let documents = try database.query(
                """
                SELECT aggregate_kind, aggregate_id, privacy, local_only, title, body,
                       source_sequence, source_event_id, source_event_hash, document_digest
                FROM runtime_canonical_search_documents
                WHERE generation_id = ? AND aggregate_kind = ? AND aggregate_id = ? LIMIT 2
                """,
                bindings: [.text(job.generationID), .text(kind), .text(identifier)],
                maximumDecodedBytes: 40_000
            )
            guard documents.count == 1 else {
                throw RuntimeCanonicalSearchError.corruptIndex
            }
            let document = try decodeCanonicalSearchDocument(
                documents[0], generationID: job.generationID
            )
            let fieldTokens = canonicalSearchTokens(field == 0 ? document.title : document.body)
            guard ordinal < Int64(fieldTokens.count), fieldTokens[Int(ordinal)] == token else {
                throw RuntimeCanonicalSearchError.corruptIndex
            }
            let expectedDigest = RuntimeTransactionDigest.digest([
                "runtime.search.posting.v1", job.generationID, token, kind, identifier,
                String(field), String(ordinal), document.digest,
            ])
            guard expectedDigest == storedDigest else {
                throw RuntimeCanonicalSearchError.corruptIndex
            }
            postingBytes += token.utf8.count + storedDigest.utf8.count
                + kind.utf8.count + identifier.utf8.count + 16
        }
        guard case let .text(lastToken)? = last.value(named: "normalized_token"),
              case let .text(lastKind)? = last.value(named: "aggregate_kind"),
              case let .text(lastID)? = last.value(named: "aggregate_id"),
              case let .integer(lastField)? = last.value(named: "field_ordinal"),
              case let .integer(lastOrdinal)? = last.value(named: "token_ordinal") else {
            throw RuntimeCanonicalSearchError.corruptIndex
        }
        let changed = try database.execute(
            """
            UPDATE runtime_canonical_generation_scrub_jobs
            SET observed_posting_count = observed_posting_count + ?,
                observed_posting_bytes = observed_posting_bytes + ?,
                after_posting_token = ?, after_posting_kind = ?, after_posting_id = ?,
                after_posting_field = ?, after_posting_ordinal = ?
            WHERE generation_id = ? AND phase = 'postings'
              AND owner_id = ? AND fence_version = ? AND expires_at_ms = ?
            """,
            bindings: [
                .integer(Int64(rows.count)), .integer(Int64(postingBytes)),
                .text(lastToken), .text(lastKind), .text(lastID),
                .integer(lastField), .integer(lastOrdinal), .text(job.generationID),
                .text(job.ownerID), .integer(job.fenceVersion),
                .integer(job.expiresAtMilliseconds),
            ]
        )
        guard changed.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        return .progressed(generationID: job.generationID, kind: job.kind, phase: "postings")
    }

    static func requireCanonicalShardBoundary(
        _ job: RuntimeCanonicalMaintenanceJob,
        table: String,
        firstKind: String,
        firstID: String,
        database: isolated SQLiteDatabase
    ) throws {
        let rows = try database.query(
            """
            SELECT aggregate_kind, aggregate_id FROM \(table)
            WHERE generation_id = ? AND
                  (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id > ?))
            ORDER BY aggregate_kind, aggregate_id LIMIT 1
            """,
            bindings: [
                .text(job.generationID), .text(job.previousLastKind),
                .text(job.previousLastKind), .text(job.previousLastID),
            ]
        )
        let orderedAfterPrevious = job.shardOrdinal == 0
            ? (job.previousLastKind.isEmpty && job.previousLastID.isEmpty)
            : (job.previousLastKind < firstKind
               || (job.previousLastKind == firstKind && job.previousLastID < firstID))
        guard rows.count == 1,
              rows[0].value(named: "aggregate_kind") == .text(firstKind),
              rows[0].value(named: "aggregate_id") == .text(firstID),
              orderedAfterPrevious else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
    }

    static func completeCanonicalScrub(
        _ job: RuntimeCanonicalMaintenanceJob,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws {
        let dataTable = job.kind == "search"
            ? "runtime_canonical_search_documents"
            : "runtime_canonical_projection_entries"
        let suffix = try database.query(
            """
            SELECT 1 FROM \(dataTable) WHERE generation_id = ? AND
                (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id > ?))
            LIMIT 1
            """,
            bindings: [
                .text(job.generationID), .text(job.previousLastKind),
                .text(job.previousLastKind), .text(job.previousLastID),
            ]
        )
        guard suffix.isEmpty else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let projectionID: String
        let root: String
        if job.kind == "projection" {
            let rows = try database.query(
                """
                SELECT projection_id, definition_digest, output_version,
                       source_sequence, source_event_id, source_event_hash,
                       source_chain_digest, invalidation_digest,
                       entry_count, shard_count, entry_root_digest,
                       privacy, local_only, generation_certificate_digest
                FROM runtime_canonical_projection_generations
                WHERE generation_id = ? AND status = 'published' LIMIT 2
                """,
                bindings: [.text(job.generationID)]
            )
            guard rows.count == 1,
                  case let .text(rawProjectionID)? = rows[0].value(named: "projection_id"),
                  let typedProjectionID = RuntimeCanonicalProjectionID(rawValue: rawProjectionID),
                  case let .text(definitionDigest)? = rows[0].value(named: "definition_digest"),
                  case let .integer(outputVersion)? = rows[0].value(named: "output_version"),
                  case let .integer(sequence)? = rows[0].value(named: "source_sequence"), sequence >= 0,
                  case let .text(eventID)? = rows[0].value(named: "source_event_id"),
                  case let .text(eventHash)? = rows[0].value(named: "source_event_hash"),
                  case let .text(sourceDigest)? = rows[0].value(named: "source_chain_digest"),
                  case let .text(invalidationDigest)? = rows[0].value(named: "invalidation_digest"),
                  case let .integer(entryCount)? = rows[0].value(named: "entry_count"), entryCount >= 0,
                  rows[0].value(named: "shard_count") == .integer(Int64(job.shardOrdinal)),
                  case let .text(rootDigest)? = rows[0].value(named: "entry_root_digest"),
                  case let .text(privacy)? = rows[0].value(named: "privacy"),
                  case let .integer(localOnly)? = rows[0].value(named: "local_only"),
                  rows[0].value(named: "generation_certificate_digest") == .text(job.expectedCertificate),
                  Int(entryCount) == job.observedCount,
                  job.observedPostingCount == 0, job.observedPostingBytes == 0,
                  job.expectedPostingCount == 0, job.expectedPostingBytes == 0,
                  job.observedPrivacyCounts.values.reduce(0, +) == job.observedCount,
                  job.observedNonlocalCount <= job.observedCount,
                  privacy == job.observedPrivacyCounts.compactMap {
                      $0.value > 0 ? $0.key.rawValue : nil
                  }.sorted().joined(separator: ","),
                  (localOnly == 1) == (job.observedNonlocalCount == 0),
                  rootDigest == job.rollingRootDigest else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            let cursor = RuntimeCanonicalReplayCursor(
                sequence: UInt64(sequence), eventID: eventID, eventHash: eventHash
            )
            let expected = canonicalProjectionGenerationCertificateDigest(
                generationID: job.generationID, projectionID: typedProjectionID,
                definitionDigest: definitionDigest, outputVersion: Int(outputVersion),
                sourceCursor: cursor, sourceChainDigest: sourceDigest,
                entryCount: Int(entryCount), shardCount: job.shardOrdinal,
                rootDigest: rootDigest, privacy: privacy, localOnly: localOnly == 1,
                invalidationDigest: invalidationDigest
            )
            guard cursor.isWellFormed, expected == job.expectedCertificate else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            projectionID = rawProjectionID
            root = rootDigest
        } else {
            guard job.kind == "search" else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            let rows = try database.query(
                """
                SELECT projection.projection_id, search.projection_generation_id,
                       search.coverage, search.definition_digest, search.source_sequence,
                       search.source_event_hash, search.document_count,
                       search.posting_count, search.posting_bytes, search.shard_count,
                       search.document_root_digest, search.generation_certificate_digest,
                       projection.source_event_id
                FROM runtime_canonical_search_generations AS search
                JOIN runtime_canonical_projection_generations AS projection
                  ON projection.generation_id = search.projection_generation_id
                WHERE search.generation_id = ? AND search.status = 'published' LIMIT 2
                """,
                bindings: [.text(job.generationID)]
            )
            guard rows.count == 1,
                  case let .text(rawProjectionID)? = rows[0].value(named: "projection_id"),
                  case let .text(projectionGenerationID)? = rows[0].value(named: "projection_generation_id"),
                  rows[0].value(named: "coverage") == .text(RuntimeCanonicalSearchCoverage.aggregateKindOnly.rawValue),
                  case let .text(definitionDigest)? = rows[0].value(named: "definition_digest"),
                  case let .integer(sequence)? = rows[0].value(named: "source_sequence"), sequence >= 0,
                  case let .text(eventID)? = rows[0].value(named: "source_event_id"),
                  case let .text(eventHash)? = rows[0].value(named: "source_event_hash"),
                  case let .integer(documentCount)? = rows[0].value(named: "document_count"), documentCount >= 0,
                  case let .integer(postingCount)? = rows[0].value(named: "posting_count"), postingCount >= 0,
                  case let .integer(postingBytes)? = rows[0].value(named: "posting_bytes"), postingBytes >= 0,
                  rows[0].value(named: "shard_count") == .integer(Int64(job.shardOrdinal)),
                  case let .text(rootDigest)? = rows[0].value(named: "document_root_digest"),
                  rows[0].value(named: "generation_certificate_digest") == .text(job.expectedCertificate),
                  Int(documentCount) == job.observedCount,
                  Int(postingCount) == job.observedPostingCount,
                  Int(postingBytes) == job.observedPostingBytes,
                  job.expectedPostingCount == job.observedPostingCount,
                  job.expectedPostingBytes == job.observedPostingBytes,
                  job.observedPrivacyCounts.values.allSatisfy({ $0 == 0 }),
                  job.observedNonlocalCount == 0,
                  rootDigest == job.rollingRootDigest else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            let cursor = RuntimeCanonicalReplayCursor(
                sequence: UInt64(sequence), eventID: eventID, eventHash: eventHash
            )
            let expected = canonicalSearchGenerationCertificateDigest(
                generationID: job.generationID,
                projectionGenerationID: projectionGenerationID,
                coverage: .aggregateKindOnly, definitionDigest: definitionDigest,
                sourceCursor: cursor, documentCount: Int(documentCount),
                postingCount: Int(postingCount), postingBytes: Int(postingBytes),
                shardCount: job.shardOrdinal, rootDigest: rootDigest
            )
            guard cursor.isWellFormed, expected == job.expectedCertificate else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            projectionID = rawProjectionID
            root = rootDigest
        }
        guard (job.shardOrdinal == 0)
                == (root == RuntimeCanonicalReplaySourceChain.emptyDigest.hexadecimal),
              job.shardOrdinal == 0 || job.previousLastKind.isEmpty == false else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let scrubDigest = canonicalScrubCertificateDigest(
            generationID: job.generationID, kind: job.kind,
            projectionID: projectionID, generationCertificate: job.expectedCertificate,
            observedCount: job.observedCount,
            observedShardCount: job.shardOrdinal,
            observedPostingCount: job.observedPostingCount,
            observedPostingBytes: job.observedPostingBytes,
            rootDigest: root, completedAtMilliseconds: nowMilliseconds
        )
        try database.execute(
            """
            INSERT INTO runtime_canonical_scrub_certificates(
                generation_id, generation_kind, projection_id,
                generation_certificate_digest, observed_count,
                observed_shard_count, observed_posting_count,
                observed_posting_bytes, root_digest,
                completed_at_ms, scrub_certificate_digest
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(job.generationID), .text(job.kind), .text(projectionID),
                .text(job.expectedCertificate), .integer(Int64(job.observedCount)),
                .integer(Int64(job.shardOrdinal)),
                .integer(Int64(job.observedPostingCount)),
                .integer(Int64(job.observedPostingBytes)), .text(root),
                .integer(nowMilliseconds), .text(scrubDigest),
            ]
        )
    }

    static func quarantineCanonicalScrub(
        _ job: RuntimeCanonicalMaintenanceJob,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        let projectionRows: [SQLiteRow]
        if job.kind == "search" {
            projectionRows = try database.query(
                """
                SELECT projection.projection_id
                FROM runtime_canonical_search_generations AS search
                JOIN runtime_canonical_projection_generations AS projection
                  ON projection.generation_id = search.projection_generation_id
                WHERE search.generation_id = ? LIMIT 2
                """,
                bindings: [.text(job.generationID)]
            )
        } else {
            projectionRows = try database.query(
                "SELECT projection_id FROM runtime_canonical_projection_generations WHERE generation_id = ? LIMIT 2",
                bindings: [.text(job.generationID)]
            )
        }
        guard projectionRows.count == 1,
              case let .text(projectionID)? = projectionRows[0].value(named: "projection_id") else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let quarantineID = RuntimeTransactionDigest.digest([
            "runtime.projection.quarantine.v1", job.kind, job.generationID,
            String(job.shardOrdinal), job.expectedCertificate,
        ])
        try database.execute(
            """
            INSERT OR IGNORE INTO runtime_canonical_projection_quarantine(
                quarantine_id, projection_id, generation_id, artifact_kind,
                artifact_id, artifact_digest, reason_code, observed_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, 'scrub_authority_mismatch', ?)
            """,
            bindings: [
                .text(quarantineID), .text(projectionID),
                .text(job.generationID), .text("\(job.kind)_shard"),
                .text(String(job.shardOrdinal)), .text(job.expectedCertificate),
                .integer(nowMilliseconds),
            ]
        )
        try recordCanonicalRepairRequirement(
            projectionID: projectionID, generationID: job.generationID,
            authorityKind: job.kind, reasonCode: "scrub_authority_mismatch",
            sourceCertificate: job.expectedCertificate,
            nowMilliseconds: nowMilliseconds, database: database
        )
        let deleted = try database.execute(
            "DELETE FROM runtime_canonical_generation_scrub_jobs WHERE generation_id = ? AND owner_id = ? AND fence_version = ?",
            bindings: [
                .text(job.generationID), .text(job.ownerID), .integer(job.fenceVersion),
            ]
        )
        guard deleted.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        return .quarantined(generationID: job.generationID, kind: job.kind)
    }

    static func quarantineCanonicalMaintenanceFailure(
        generationID: String,
        kind: String,
        expectedCertificate: String?,
        projectionID suppliedProjectionID: String? = nil,
        nowMilliseconds: Int64,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        let projectionID: String
        if let suppliedProjectionID {
            projectionID = suppliedProjectionID
        } else if kind == "search" {
            let rows = try database.query(
                """
                SELECT projection.projection_id
                FROM runtime_canonical_search_generations AS search
                JOIN runtime_canonical_projection_generations AS projection
                  ON projection.generation_id = search.projection_generation_id
                WHERE search.generation_id = ? LIMIT 2
                """,
                bindings: [.text(generationID)]
            )
            guard rows.count == 1,
                  case let .text(value)? = rows[0].value(named: "projection_id") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            projectionID = value
        } else {
            let rows = try database.query(
                "SELECT projection_id FROM runtime_canonical_projection_generations WHERE generation_id = ? LIMIT 2",
                bindings: [.text(generationID)]
            )
            guard rows.count == 1,
                  case let .text(value)? = rows[0].value(named: "projection_id") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            projectionID = value
        }
        let reasonCode = "maintenance_authority_constraint"
        let quarantineID = RuntimeTransactionDigest.digest([
            "runtime.projection.maintenance-quarantine.v1", kind,
            generationID, expectedCertificate ?? "", reasonCode,
        ])
        try database.execute(
            """
            INSERT OR IGNORE INTO runtime_canonical_projection_quarantine(
                quarantine_id, projection_id, generation_id, artifact_kind,
                artifact_id, artifact_digest, reason_code, observed_at_ms
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
            bindings: [
                .text(quarantineID), .text(projectionID), .text(generationID),
                .text("\(kind)_maintenance"), .text(generationID),
                expectedCertificate.map(SQLiteBinding.text) ?? .null,
                .text(reasonCode), .integer(nowMilliseconds),
            ]
        )
        try recordCanonicalRepairRequirement(
            projectionID: projectionID, generationID: generationID,
            authorityKind: kind == "build" ? "build" : kind,
            reasonCode: reasonCode, sourceCertificate: expectedCertificate,
            nowMilliseconds: nowMilliseconds, database: database
        )
        return .quarantined(generationID: generationID, kind: kind)
    }

    static func requireCanonicalMaintenanceAuthority(
        _ job: RuntimeCanonicalMaintenanceJob,
        expectedStatus: String,
        database: isolated SQLiteDatabase
    ) throws {
        let table = job.kind == "search"
            ? "runtime_canonical_search_generations"
            : "runtime_canonical_projection_generations"
        guard job.kind == "search" || job.kind == "projection" else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let rows = try database.query(
            "SELECT generation_certificate_digest FROM \(table) WHERE generation_id = ? AND status = ? LIMIT 2",
            bindings: [.text(job.generationID), .text(expectedStatus)]
        )
        guard rows.count == 1,
              rows[0].value(named: "generation_certificate_digest") == .text(job.expectedCertificate) else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let activeTable = job.kind == "search"
            ? "runtime_canonical_search_active_generation"
            : "runtime_canonical_projection_active_generations"
        let active = try database.query(
            "SELECT generation_id FROM \(activeTable) WHERE generation_id = ? LIMIT 2",
            bindings: [.text(job.generationID)]
        )
        if expectedStatus == "published" {
            guard active.count == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
        } else if active.isEmpty == false {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
    }

    static func requireCanonicalScrubAuthority(
        _ job: RuntimeCanonicalMaintenanceJob,
        database: isolated SQLiteDatabase
    ) throws {
        let table = job.kind == "search"
            ? "runtime_canonical_search_generations"
            : "runtime_canonical_projection_generations"
        guard job.kind == "search" || job.kind == "projection" else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let rows = try database.query(
            "SELECT status, generation_certificate_digest FROM \(table) WHERE generation_id = ? AND status IN ('sealed', 'published') LIMIT 2",
            bindings: [.text(job.generationID)]
        )
        guard rows.count == 1,
              case let .text(status)? = rows[0].value(named: "status"),
              rows[0].value(named: "generation_certificate_digest") ==
                .text(job.expectedCertificate) else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let activeTable = job.kind == "search"
            ? "runtime_canonical_search_active_generation"
            : "runtime_canonical_projection_active_generations"
        let active = try database.query(
            "SELECT generation_id FROM \(activeTable) WHERE generation_id = ? LIMIT 2",
            bindings: [.text(job.generationID)]
        )
        guard active.count <= 1,
              (status == "published" && active.count == 1)
                || (status == "sealed" && active.isEmpty) else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
    }

    static func runCanonicalCleanupUnit(
        _ job: RuntimeCanonicalCleanupJob,
        rowLimit: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        let projection = try database.query(
            "SELECT 1 FROM runtime_canonical_projection_generations WHERE generation_id = ? AND projection_id = ? AND status = 'abandoned' LIMIT 2",
            bindings: [.text(job.generationID), .text(job.projectionID)]
        )
        guard projection.count == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        switch job.phase {
        case "search_postings":
            guard let searchID = job.searchGenerationID else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            let rows = try database.query(
                """
                SELECT normalized_token, aggregate_kind, aggregate_id,
                       field_ordinal, token_ordinal
                FROM runtime_canonical_search_postings WHERE generation_id = ?
                ORDER BY normalized_token, aggregate_kind, aggregate_id,
                         field_ordinal, token_ordinal LIMIT ?
                """,
                bindings: [.text(searchID), .integer(Int64(rowLimit))]
            )
            if rows.isEmpty {
                try advanceCanonicalCleanupPhase(
                    job, nextPhase: "search_documents", database: database
                )
                return .progressed(generationID: job.generationID, kind: "cleanup", phase: "search_documents")
            }
            for row in rows {
                try Task.checkCancellation()
                guard case let .text(token)? = row.value(named: "normalized_token"),
                      case let .text(kind)? = row.value(named: "aggregate_kind"),
                      case let .text(identifier)? = row.value(named: "aggregate_id"),
                      case let .integer(field)? = row.value(named: "field_ordinal"),
                      case let .integer(ordinal)? = row.value(named: "token_ordinal") else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
                try database.execute(
                    """
                    DELETE FROM runtime_canonical_search_postings
                    WHERE generation_id = ? AND normalized_token = ?
                      AND aggregate_kind = ? AND aggregate_id = ?
                      AND field_ordinal = ? AND token_ordinal = ?
                    """,
                    bindings: [
                        .text(searchID), .text(token), .text(kind), .text(identifier),
                        .integer(field), .integer(ordinal),
                    ]
                )
            }
        case "search_documents":
            guard let searchID = job.searchGenerationID else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            return try drainCanonicalCleanupKeyedRows(
                job, generationID: searchID,
                table: "runtime_canonical_search_documents",
                nextPhase: "search_shards", rowLimit: rowLimit, database: database
            )
        case "search_shards":
            guard let searchID = job.searchGenerationID else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            return try drainCanonicalCleanupShards(
                job, generationID: searchID,
                table: "runtime_canonical_search_shards", nextPhase: "search_header",
                rowLimit: rowLimit, database: database
            )
        case "search_header":
            guard let searchID = job.searchGenerationID else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            try database.execute(
                "DELETE FROM runtime_canonical_scrub_certificates WHERE generation_id = ?",
                bindings: [.text(searchID)]
            )
            let deleted = try database.execute(
                "DELETE FROM runtime_canonical_search_generations WHERE generation_id = ? AND status = 'abandoned'",
                bindings: [.text(searchID)]
            )
            guard deleted.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            try advanceCanonicalCleanupPhase(
                job, nextPhase: "projection_entries", database: database
            )
            return .progressed(generationID: job.generationID, kind: "cleanup", phase: "projection_entries")
        case "projection_entries":
            return try drainCanonicalCleanupKeyedRows(
                job, generationID: job.generationID,
                table: "runtime_canonical_projection_entries",
                nextPhase: "projection_shards", rowLimit: rowLimit, database: database
            )
        case "projection_shards":
            return try drainCanonicalCleanupShards(
                job, generationID: job.generationID,
                table: "runtime_canonical_projection_shards", nextPhase: "projection_header",
                rowLimit: rowLimit, database: database
            )
        case "projection_header":
            try database.execute(
                "DELETE FROM runtime_canonical_scrub_certificates WHERE generation_id = ?",
                bindings: [.text(job.generationID)]
            )
            let deleted = try database.execute(
                "DELETE FROM runtime_canonical_projection_generations WHERE generation_id = ? AND status = 'abandoned'",
                bindings: [.text(job.generationID)]
            )
            guard deleted.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            let jobDeleted = try database.execute(
                "DELETE FROM runtime_canonical_build_cleanup_jobs WHERE generation_id = ? AND owner_id = ? AND fence_version = ?",
                bindings: [
                    .text(job.generationID), .text(job.ownerID), .integer(job.fenceVersion),
                ]
            )
            guard jobDeleted.changedRowCount == 1 else {
                throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
            }
            return .completed(generationID: job.generationID, kind: "cleanup")
        default:
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        return .progressed(generationID: job.generationID, kind: "cleanup", phase: job.phase)
    }

    static func drainCanonicalCleanupKeyedRows(
        _ job: RuntimeCanonicalCleanupJob,
        generationID: String,
        table: String,
        nextPhase: String,
        rowLimit: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        let rows = try database.query(
            """
            SELECT aggregate_kind, aggregate_id FROM \(table)
            WHERE generation_id = ? AND
                  (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id > ?))
            ORDER BY aggregate_kind, aggregate_id LIMIT ?
            """,
            bindings: [
                .text(generationID), .text(job.afterKind), .text(job.afterKind),
                .text(job.afterID), .integer(Int64(rowLimit)),
            ]
        )
        guard let last = rows.last else {
            try advanceCanonicalCleanupPhase(job, nextPhase: nextPhase, database: database)
            return .progressed(generationID: job.generationID, kind: "cleanup", phase: nextPhase)
        }
        for row in rows {
            try Task.checkCancellation()
            guard case let .text(kind)? = row.value(named: "aggregate_kind"),
                  case let .text(identifier)? = row.value(named: "aggregate_id") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            try database.execute(
                "DELETE FROM \(table) WHERE generation_id = ? AND aggregate_kind = ? AND aggregate_id = ?",
                bindings: [.text(generationID), .text(kind), .text(identifier)]
            )
        }
        guard case let .text(lastKind)? = last.value(named: "aggregate_kind"),
              case let .text(lastID)? = last.value(named: "aggregate_id") else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let changed = try database.execute(
            """
            UPDATE runtime_canonical_build_cleanup_jobs
            SET after_aggregate_kind = ?, after_aggregate_id = ?
            WHERE generation_id = ? AND phase = ? AND owner_id = ?
              AND fence_version = ? AND expires_at_ms = ?
            """,
            bindings: [
                .text(lastKind), .text(lastID), .text(job.generationID), .text(job.phase),
                .text(job.ownerID), .integer(job.fenceVersion),
                .integer(job.expiresAtMilliseconds),
            ]
        )
        guard changed.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        return .progressed(generationID: job.generationID, kind: "cleanup", phase: job.phase)
    }

    static func drainCanonicalCleanupShards(
        _ job: RuntimeCanonicalCleanupJob,
        generationID: String,
        table: String,
        nextPhase: String,
        rowLimit: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        let rows = try database.query(
            "SELECT shard_ordinal FROM \(table) WHERE generation_id = ? ORDER BY shard_ordinal LIMIT ?",
            bindings: [.text(generationID), .integer(Int64(rowLimit))]
        )
        if rows.isEmpty {
            try advanceCanonicalCleanupPhase(job, nextPhase: nextPhase, database: database)
            return .progressed(generationID: job.generationID, kind: "cleanup", phase: nextPhase)
        }
        for row in rows {
            try Task.checkCancellation()
            guard case let .integer(ordinal)? = row.value(named: "shard_ordinal") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            try database.execute(
                "DELETE FROM \(table) WHERE generation_id = ? AND shard_ordinal = ?",
                bindings: [.text(generationID), .integer(ordinal)]
            )
        }
        return .progressed(generationID: job.generationID, kind: "cleanup", phase: job.phase)
    }

    static func advanceCanonicalCleanupPhase(
        _ job: RuntimeCanonicalCleanupJob,
        nextPhase: String,
        database: isolated SQLiteDatabase
    ) throws {
        let changed = try database.execute(
            """
            UPDATE runtime_canonical_build_cleanup_jobs
            SET phase = ?, after_aggregate_kind = '', after_aggregate_id = ''
            WHERE generation_id = ? AND phase = ? AND owner_id = ?
              AND fence_version = ? AND expires_at_ms = ?
            """,
            bindings: [
                .text(nextPhase), .text(job.generationID), .text(job.phase),
                .text(job.ownerID), .integer(job.fenceVersion),
                .integer(job.expiresAtMilliseconds),
            ]
        )
        guard changed.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
    }

    static func runCanonicalGCUnit(
        _ job: RuntimeCanonicalMaintenanceJob,
        rowLimit: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        try requireCanonicalMaintenanceAuthority(job, expectedStatus: "retired", database: database)
        if job.kind == "projection" {
            if try canonicalProjectionHasDependentSearchGeneration(
                job.generationID, database: database
            ) {
                try deferCanonicalGCJob(job, database: database)
                return .deferred(
                    generationID: job.generationID, kind: job.kind,
                    reasonCode: "waiting_for_search_dependency"
                )
            }
        }
        switch (job.kind, job.phase) {
        case ("search", "postings"):
            return try drainCanonicalSearchPostings(job, rowLimit: rowLimit, database: database)
        case ("search", "documents"):
            return try drainCanonicalKeyedRows(
                job, table: "runtime_canonical_search_documents", nextPhase: "shards",
                rowLimit: rowLimit, database: database
            )
        case ("search", "shards"):
            return try drainCanonicalShards(
                job, table: "runtime_canonical_search_shards",
                rowLimit: rowLimit, database: database
            )
        case ("projection", "entries"):
            return try drainCanonicalKeyedRows(
                job, table: "runtime_canonical_projection_entries", nextPhase: "shards",
                rowLimit: rowLimit, database: database
            )
        case ("projection", "shards"):
            return try drainCanonicalShards(
                job, table: "runtime_canonical_projection_shards",
                rowLimit: rowLimit, database: database
            )
        case (_, "header"):
            return try drainCanonicalGenerationHeader(job, database: database)
        default:
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
    }

    static func deferCanonicalGCJob(
        _ job: RuntimeCanonicalMaintenanceJob,
        database: isolated SQLiteDatabase
    ) throws {
        let deferred = job.expiresAtMilliseconds.addingReportingOverflow(30_000)
        guard deferred.overflow == false else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        let changed = try database.execute(
            """
            UPDATE runtime_canonical_generation_gc_jobs
            SET owner_id = 'unclaimed', expires_at_ms = ?, last_served_at_ms = ?
            WHERE generation_id = ? AND owner_id = ? AND fence_version = ?
            """,
            bindings: [
                .integer(deferred.partialValue),
                .integer(max(0, job.expiresAtMilliseconds - 30_000)),
                .text(job.generationID), .text(job.ownerID), .integer(job.fenceVersion),
            ]
        )
        guard changed.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
    }

    static func drainCanonicalSearchPostings(
        _ job: RuntimeCanonicalMaintenanceJob,
        rowLimit: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        let rows = try database.query(
            """
            SELECT normalized_token, aggregate_kind, aggregate_id,
                   field_ordinal, token_ordinal
            FROM runtime_canonical_search_postings
            WHERE generation_id = ?
            ORDER BY normalized_token, aggregate_kind, aggregate_id,
                     field_ordinal, token_ordinal LIMIT ?
            """,
            bindings: [.text(job.generationID), .integer(Int64(rowLimit))]
        )
        guard rows.isEmpty == false else {
            try advanceCanonicalGCPhase(job, nextPhase: "documents", resetKeyset: true, database: database)
            return .progressed(generationID: job.generationID, kind: job.kind, phase: "documents")
        }
        for row in rows {
            try Task.checkCancellation()
            guard case let .text(token)? = row.value(named: "normalized_token"),
                  case let .text(kind)? = row.value(named: "aggregate_kind"),
                  case let .text(identifier)? = row.value(named: "aggregate_id"),
                  case let .integer(field)? = row.value(named: "field_ordinal"),
                  case let .integer(ordinal)? = row.value(named: "token_ordinal") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            try database.execute(
                """
                DELETE FROM runtime_canonical_search_postings
                WHERE generation_id = ? AND normalized_token = ?
                  AND aggregate_kind = ? AND aggregate_id = ?
                  AND field_ordinal = ? AND token_ordinal = ?
                """,
                bindings: [
                    .text(job.generationID), .text(token), .text(kind), .text(identifier),
                    .integer(field), .integer(ordinal),
                ]
            )
        }
        return .progressed(generationID: job.generationID, kind: job.kind, phase: job.phase)
    }

    static func drainCanonicalKeyedRows(
        _ job: RuntimeCanonicalMaintenanceJob,
        table: String,
        nextPhase: String,
        rowLimit: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        let keys = try canonicalGCKeys(job, table: table, rowLimit: rowLimit, database: database)
        guard let last = keys.last else {
            try advanceCanonicalGCPhase(job, nextPhase: nextPhase, resetKeyset: true, database: database)
            return .progressed(generationID: job.generationID, kind: job.kind, phase: nextPhase)
        }
        for key in keys {
            try database.execute(
                "DELETE FROM \(table) WHERE generation_id = ? AND aggregate_kind = ? AND aggregate_id = ?",
                bindings: [.text(job.generationID), .text(key.0), .text(key.1)]
            )
        }
        try updateCanonicalGCKeyset(job, lastKind: last.0, lastID: last.1, database: database)
        return .progressed(generationID: job.generationID, kind: job.kind, phase: job.phase)
    }

    static func canonicalGCKeys(
        _ job: RuntimeCanonicalMaintenanceJob,
        table: String,
        rowLimit: Int,
        database: isolated SQLiteDatabase
    ) throws -> [(String, String)] {
        let rows = try database.query(
            """
            SELECT aggregate_kind, aggregate_id FROM \(table)
            WHERE generation_id = ? AND
                  (aggregate_kind > ? OR (aggregate_kind = ? AND aggregate_id > ?))
            ORDER BY aggregate_kind, aggregate_id LIMIT ?
            """,
            bindings: [
                .text(job.generationID), .text(job.afterKind), .text(job.afterKind),
                .text(job.afterID), .integer(Int64(rowLimit)),
            ]
        )
        return try rows.map {
            guard case let .text(kind)? = $0.value(named: "aggregate_kind"),
                  case let .text(identifier)? = $0.value(named: "aggregate_id") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            return (kind, identifier)
        }
    }

    static func drainCanonicalShards(
        _ job: RuntimeCanonicalMaintenanceJob,
        table: String,
        rowLimit: Int,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        let rows = try database.query(
            "SELECT shard_ordinal FROM \(table) WHERE generation_id = ? ORDER BY shard_ordinal LIMIT ?",
            bindings: [.text(job.generationID), .integer(Int64(rowLimit))]
        )
        if rows.isEmpty {
            try advanceCanonicalGCPhase(job, nextPhase: "header", resetKeyset: true, database: database)
            return .progressed(generationID: job.generationID, kind: job.kind, phase: "header")
        }
        for row in rows {
            try Task.checkCancellation()
            guard case let .integer(ordinal)? = row.value(named: "shard_ordinal") else {
                throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
            }
            try database.execute(
                "DELETE FROM \(table) WHERE generation_id = ? AND shard_ordinal = ?",
                bindings: [.text(job.generationID), .integer(ordinal)]
            )
        }
        return .progressed(generationID: job.generationID, kind: job.kind, phase: job.phase)
    }

    static func drainCanonicalGenerationHeader(
        _ job: RuntimeCanonicalMaintenanceJob,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeCanonicalGenerationMaintenanceOutcome {
        let table = job.kind == "search"
            ? "runtime_canonical_search_generations"
            : "runtime_canonical_projection_generations"
        try database.execute(
            "DELETE FROM runtime_canonical_scrub_certificates WHERE generation_id = ?",
            bindings: [.text(job.generationID)]
        )
        let deleted = try database.execute(
            "DELETE FROM \(table) WHERE generation_id = ? AND status = 'retired' AND generation_certificate_digest = ?",
            bindings: [.text(job.generationID), .text(job.expectedCertificate)]
        )
        guard deleted.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
        }
        let jobDeleted = try database.execute(
            "DELETE FROM runtime_canonical_generation_gc_jobs WHERE generation_id = ? AND owner_id = ? AND fence_version = ?",
            bindings: [.text(job.generationID), .text(job.ownerID), .integer(job.fenceVersion)]
        )
        guard jobDeleted.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
        return .completed(generationID: job.generationID, kind: job.kind)
    }

    static func updateCanonicalGCKeyset(
        _ job: RuntimeCanonicalMaintenanceJob,
        lastKind: String,
        lastID: String,
        database: isolated SQLiteDatabase
    ) throws {
        let changed = try database.execute(
            """
            UPDATE runtime_canonical_generation_gc_jobs
            SET after_aggregate_kind = ?, after_aggregate_id = ?
            WHERE generation_id = ? AND phase = ? AND owner_id = ?
              AND fence_version = ? AND expires_at_ms = ?
            """,
            bindings: [
                .text(lastKind), .text(lastID), .text(job.generationID), .text(job.phase),
                .text(job.ownerID), .integer(job.fenceVersion),
                .integer(job.expiresAtMilliseconds),
            ]
        )
        guard changed.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
    }

    static func advanceCanonicalGCPhase(
        _ job: RuntimeCanonicalMaintenanceJob,
        nextPhase: String,
        resetKeyset: Bool,
        database: isolated SQLiteDatabase
    ) throws {
        let changed = try database.execute(
            """
            UPDATE runtime_canonical_generation_gc_jobs
            SET phase = ?,
                after_aggregate_kind = CASE WHEN ? = 1 THEN '' ELSE after_aggregate_kind END,
                after_aggregate_id = CASE WHEN ? = 1 THEN '' ELSE after_aggregate_id END
            WHERE generation_id = ? AND phase = ? AND owner_id = ?
              AND fence_version = ? AND expires_at_ms = ?
            """,
            bindings: [
                .text(nextPhase), .integer(resetKeyset ? 1 : 0),
                .integer(resetKeyset ? 1 : 0), .text(job.generationID),
                .text(job.phase), .text(job.ownerID), .integer(job.fenceVersion),
                .integer(job.expiresAtMilliseconds),
            ]
        )
        guard changed.changedRowCount == 1 else {
            throw RuntimeCanonicalProjectionPersistenceError.leaseUnavailable
        }
    }
}
