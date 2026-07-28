import AmbitionsRuntimeSQLite
import Foundation
import XCTest
@testable import Ambitions

final class RuntimeAttachmentLifecycleStoreTests: XCTestCase {
    func testLifecycleVersionLifetimeIsIndependentOfBoundedInspectionPageSize() throws {
        XCTAssertEqual(
            try RuntimeAttachmentCodec.nextSQLiteVersion(
                after: UInt64(RuntimeAttachmentLimits.maximumHistoryEntries)
            ),
            UInt64(RuntimeAttachmentLimits.maximumHistoryEntries + 1)
        )
        XCTAssertThrowsError(
            try RuntimeAttachmentCodec.nextSQLiteVersion(
                after: RuntimeAttachmentCodec.maximumSQLiteInteger
            )
        ) { error in
            XCTAssertEqual(error as? RuntimeCanonicalAttachmentError, .lifecycleConflict)
        }
        XCTAssertThrowsError(try RuntimeAttachmentCodec.sqliteInteger(UInt64.max)) { error in
            XCTAssertEqual(error as? RuntimeCanonicalAttachmentError, .invalidRecord)
        }
    }

    func testExpiredQuotaReservationsReleaseLedgerChargeAndPreserveAuthority() async throws {
        let fixture = try await makePersistedFixture("expired-quota-release")
        let reservationID = RuntimeBlobQuotaReservationID(rawValue: "expired-reservation")!
        try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.reserveQuota(
                RuntimeBlobQuotaReservation(
                    version: 1, reservationID: reservationID, privacyDomain: .sensitive,
                    reservedBytes: 1_024, ownerID: "expired-quota-tests",
                    createdAt: XCTAttachmentFixtures.now,
                    expiresAt: XCTAttachmentFixtures.now.addingTimeInterval(60),
                    consumedByBlobID: nil
                ),
                now: XCTAttachmentFixtures.now, database: database
            )
        }
        let releaseTime = XCTAttachmentFixtures.now.addingTimeInterval(61)
        let released = try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.releaseExpiredQuotaReservations(
                limit: 10, now: releaseTime, database: database
            )
        }
        XCTAssertEqual(released, 1)
        let authority = try await fixture.database.transaction(.deferred) { database in
            try database.query(
                """
                SELECT r.released_at_ms, r.consumed_by_blob_id, l.reserved_bytes
                FROM runtime_blob_quota_reservations AS r
                JOIN runtime_blob_quota_ledgers AS l
                  ON l.privacy_domain = r.privacy_domain AND l.owner_id = r.owner_id
                WHERE r.reservation_id = ?
                """,
                bindings: [.text(reservationID.rawValue)]
            )
        }
        XCTAssertEqual(authority.count, 1)
        XCTAssertEqual(authority[0].value(named: "released_at_ms"), .integer(
            Int64(releaseTime.timeIntervalSince1970 * 1_000)
        ))
        XCTAssertEqual(authority[0].value(named: "consumed_by_blob_id"), .null)
        XCTAssertEqual(authority[0].value(named: "reserved_bytes"), .integer(0))
        let repeated = try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.releaseExpiredQuotaReservations(
                limit: 10, now: releaseTime, database: database
            )
        }
        XCTAssertEqual(repeated, 0)
    }

    func testRecoveryOccurrencesCanReopenAcrossCursorCyclesAndResolveByIdentity() async throws {
        let fixture = try await makePersistedFixture("recovery-occurrences")
        let relativeDirectory = fixture.bundle.manifest.opaqueRelativeDirectory
        let first = try CanonicalRuntimeAttachmentStore.recoveryFindingEvidenceFingerprint(
            issue: .referencedBytesMissing, blobID: fixture.bundle.manifest.blobID,
            relativeDirectory: relativeDirectory, cycle: 7
        )
        let second = try CanonicalRuntimeAttachmentStore.recoveryFindingEvidenceFingerprint(
            issue: .referencedBytesMissing, blobID: fixture.bundle.manifest.blobID,
            relativeDirectory: relativeDirectory, cycle: 8
        )
        XCTAssertNotEqual(first, second)
        try await fixture.database.transaction(.immediate) { database in
            for (fingerprint, observedAt) in [
                (first, XCTAttachmentFixtures.now),
                (second, XCTAttachmentFixtures.now.addingTimeInterval(1)),
            ] {
                try CanonicalRuntimeAttachmentStore.recordRecoveryFinding(
                    RuntimeAttachmentRecoveryFinding(
                        issue: .referencedBytesMissing,
                        blobID: fixture.bundle.manifest.blobID,
                        opaqueRelativeDirectory: relativeDirectory,
                        evidenceFingerprint: fingerprint, observedAt: observedAt
                    ),
                    database: database
                )
            }
            try CanonicalRuntimeAttachmentStore.recordRecoveryFinding(
                RuntimeAttachmentRecoveryFinding(
                    issue: .referencedBytesMissing,
                    blobID: fixture.bundle.manifest.blobID,
                    opaqueRelativeDirectory: relativeDirectory,
                    evidenceFingerprint: first,
                    observedAt: XCTAttachmentFixtures.now.addingTimeInterval(1)
                ),
                database: database
            )
        }
        do {
            try await fixture.database.transaction(.immediate) { database in
                try CanonicalRuntimeAttachmentStore.recordRecoveryFinding(
                    RuntimeAttachmentRecoveryFinding(
                        issue: .referencedBytesTampered,
                        blobID: fixture.bundle.manifest.blobID,
                        opaqueRelativeDirectory: relativeDirectory,
                        evidenceFingerprint: first,
                        observedAt: XCTAttachmentFixtures.now.addingTimeInterval(1)
                    ),
                    database: database
                )
            }
            XCTFail("A recovery occurrence fingerprint must not authenticate different evidence")
        } catch let error as RuntimeCanonicalAttachmentError {
            XCTAssertEqual(error, .corruptAuthority)
        }
        let resolved = try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.resolveOpenRecoveryFindings(
                issue: .referencedBytesMissing, blobID: fixture.bundle.manifest.blobID,
                relativeDirectory: relativeDirectory,
                at: XCTAttachmentFixtures.now.addingTimeInterval(2), database: database
            )
        }
        XCTAssertEqual(resolved, 2)
        let occurrences = try await fixture.database.transaction(.deferred) { database in
            try database.query(
                "SELECT resolved_at_ms FROM runtime_attachment_recovery_findings WHERE evidence_fingerprint IN (?, ?)",
                bindings: [.text(first), .text(second)]
            )
        }
        XCTAssertEqual(occurrences.count, 2)
        XCTAssertTrue(occurrences.allSatisfy { $0.value(named: "resolved_at_ms") != .null })
    }

    func testResolvedRecoveryWorkReopensForLaterCorruptionOccurrenceWithFreshBoundedRetryState() async throws {
        let fixture = try await makePersistedFixture("recovery-reopen")
        let authorityID = try CanonicalRuntimeAttachmentStore.recoveryAttemptAuthorityID(
            scan: .authorityGraphs, key: fixture.bundle.manifest.blobID.rawValue
        )
        let firstOccurrence = "scan:authority_graphs:7"
        let secondOccurrence = "scan:authority_graphs:8"
        try await fixture.database.transaction(.immediate) { database in
            XCTAssertTrue(try CanonicalRuntimeAttachmentStore.beginRecoveryAttempt(
                workKind: .authorityGraph, authorityID: authorityID,
                occurrence: firstOccurrence, now: XCTAttachmentFixtures.now, database: database
            ))
            try CanonicalRuntimeAttachmentStore.resolveRecoveryAttempt(
                workKind: .authorityGraph, authorityID: authorityID,
                at: XCTAttachmentFixtures.now, database: database
            )
        }
        let reopened = try await fixture.database.transaction(.immediate) { database in
            XCTAssertFalse(try CanonicalRuntimeAttachmentStore.beginRecoveryAttempt(
                workKind: .authorityGraph, authorityID: authorityID,
                occurrence: firstOccurrence,
                now: XCTAttachmentFixtures.now.addingTimeInterval(1), database: database
            ))
            return try CanonicalRuntimeAttachmentStore.beginRecoveryAttempt(
                workKind: .authorityGraph, authorityID: authorityID,
                occurrence: secondOccurrence,
                now: XCTAttachmentFixtures.now.addingTimeInterval(1), database: database
            )
        }
        XCTAssertTrue(reopened)
        let rows = try await fixture.database.transaction(.deferred) { database in
            (
                try database.query(
                    "SELECT occurrence_fingerprint, attempt_count, resolved_at_ms FROM runtime_attachment_recovery_attempts WHERE work_kind = 'authority_graph' AND authority_id = ?",
                    bindings: [.text(authorityID)]
                ),
                try database.query(
                    "SELECT prior_attempt_count, prior_occurrence_fingerprint, next_occurrence_fingerprint FROM runtime_attachment_recovery_reopen_history WHERE work_kind = 'authority_graph' AND authority_id = ?",
                    bindings: [.text(authorityID)]
                )
            )
        }
        XCTAssertEqual(rows.0.count, 1)
        XCTAssertEqual(rows.0[0].value(named: "attempt_count"), .integer(1))
        XCTAssertEqual(rows.0[0].value(named: "resolved_at_ms"), .null)
        XCTAssertEqual(rows.1.count, 1)
        XCTAssertEqual(rows.1[0].value(named: "prior_attempt_count"), .integer(1))
        XCTAssertNotEqual(
            rows.1[0].value(named: "prior_occurrence_fingerprint"),
            rows.1[0].value(named: "next_occurrence_fingerprint")
        )
    }

    func testStagedExpiryBeginsTransitionsAndResolvesOneRecoveryAttemptExactlyOnce() async throws {
        let fixture = try await makePersistedFixture("staged-expiry-single-resolution")
        let expiryTime = XCTAttachmentFixtures.now.addingTimeInterval(
            RuntimeAttachmentLimits.maximumStagedLifetimeSeconds + 1
        )
        let authorityID = fixture.bundle.manifest.blobID.rawValue
        let occurrence = CanonicalRuntimeAttachmentStore.stagedExpiryOccurrence(
            revisionID: fixture.bundle.revision.revisionID,
            stateVersion: fixture.bundle.lifecycle.stateVersion
        )
        try await fixture.database.transaction(.immediate) { database in
            XCTAssertTrue(try CanonicalRuntimeAttachmentStore.beginRecoveryAttempt(
                workKind: .stagingOrphan, authorityID: authorityID,
                occurrence: occurrence, now: expiryTime, database: database
            ))
            _ = try CanonicalRuntimeAttachmentStore.expireStagedAttachment(
                revisionID: fixture.bundle.revision.revisionID,
                at: expiryTime, database: database
            )
            try CanonicalRuntimeAttachmentStore.resolveRecoveryAttempt(
                workKind: .stagingOrphan, authorityID: authorityID,
                at: expiryTime, database: database
            )
        }
        do {
            try await fixture.database.transaction(.immediate) { database in
                try CanonicalRuntimeAttachmentStore.resolveRecoveryAttempt(
                    workKind: .stagingOrphan, authorityID: authorityID,
                    at: expiryTime, database: database
                )
            }
            XCTFail("A staged-expiry recovery occurrence must resolve exactly once")
        } catch let error as RuntimeCanonicalAttachmentError {
            XCTAssertEqual(error, .lifecycleConflict)
        }
        let rows = try await fixture.database.transaction(.deferred) { database in
            try database.query(
                "SELECT attempt_count, resolved_at_ms FROM runtime_attachment_recovery_attempts WHERE work_kind = 'staging_orphan' AND authority_id = ?",
                bindings: [.text(authorityID)]
            )
        }
        XCTAssertEqual(rows.count, 1)
        XCTAssertEqual(rows[0].value(named: "attempt_count"), .integer(1))
        XCTAssertNotEqual(rows[0].value(named: "resolved_at_ms"), .null)
    }

    func testMultipleReferencesSurviveIndependentUnlinkWithoutFalseFinalization() async throws {
        let fixture = try await makePersistedFixture("multi-reference")
        let first = try await apply(
            intent(bundle: fixture.bundle, action: .linkStaged, version: 1, reference: "reference-a", target: "capture-a"),
            command: "command-link-a", receipt: "receipt-link-a", database: fixture.database
        )
        XCTAssertEqual(first.lifecycle.state, .referenced)
        XCTAssertEqual(first.lifecycle.referenceCount, 1)
        let firstArtifacts = try await fixture.database.transaction(.deferred) { database in
            var budget = RuntimeReceiptDecodedByteBudget(
                maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAttachmentArtifactGraphBytes
            )
            try CanonicalRuntimeAttachmentStore.authenticatedReceiptArtifacts(
                receiptID: RuntimeReceiptID(rawValue: "receipt-link-a")!,
                budget: &budget,
                database: database
            )
        }
        XCTAssertEqual(firstArtifacts.map(\.kind), [.attachmentFinalizationIntent, .attachmentRevision])
        XCTAssertTrue(firstArtifacts.contains { $0.stableID == fixture.bundle.manifest.blobID.rawValue })
        let second = try await apply(
            intent(bundle: fixture.bundle, action: .linkStaged, version: 2, reference: "reference-b", target: "capture-b"),
            command: "command-link-b", receipt: "receipt-link-b", database: fixture.database
        )
        XCTAssertEqual(second.lifecycle.state, .referenced)
        XCTAssertEqual(second.lifecycle.referenceCount, 2)

        let removed = try await apply(
            intent(bundle: fixture.bundle, action: .unlink, version: 3, reference: "reference-a", target: "capture-a"),
            command: "command-unlink-a", receipt: "receipt-unlink-a", database: fixture.database
        )
        XCTAssertEqual(removed.lifecycle.state, .referenced)
        XCTAssertEqual(removed.lifecycle.referenceCount, 1)
        let graph = try await load(fixture.bundle.revision.revisionID, database: fixture.database)
        XCTAssertEqual(graph?.references.filter { $0.state == .active }.map(\.referenceID.rawValue), ["reference-b"])
        XCTAssertEqual(graph?.referenceHistory.count, 3)
        XCTAssertEqual(graph?.history.map(\.stateVersion), [1, 2, 3, 4])
    }

    func testLastUnlinkOrphansBlobAndDeletionCannotBeAuthorizedWhileReferencesRemain() async throws {
        let fixture = try await makePersistedFixture("last-unlink")
        _ = try await apply(
            intent(bundle: fixture.bundle, action: .linkStaged, version: 1, reference: "reference-only", target: "capture-only"),
            command: "command-link-only", receipt: "receipt-link-only", database: fixture.database
        )
        await assertAttachmentError(.referencesRemain) {
            _ = try await self.apply(
                self.intent(bundle: fixture.bundle, action: .authorizeDeletion, version: 2),
                command: "command-delete-early", receipt: "receipt-delete-early", database: fixture.database
            )
        }
        let unlinked = try await apply(
            intent(bundle: fixture.bundle, action: .unlink, version: 2, reference: "reference-only", target: "capture-only"),
            command: "command-unlink-only", receipt: "receipt-unlink-only", database: fixture.database
        )
        XCTAssertEqual(unlinked.lifecycle.state, .orphaned)
        XCTAssertEqual(unlinked.lifecycle.referenceCount, 0)
        let pending = try await apply(
            intent(bundle: fixture.bundle, action: .authorizeDeletion, version: 3),
            command: "command-delete", receipt: "receipt-delete", database: fixture.database
        )
        XCTAssertEqual(pending.lifecycle.state, .deletionPending)
    }

    func testExpectedLifecycleVersionIsCompareAndSwapAuthority() async throws {
        let fixture = try await makePersistedFixture("cas")
        _ = try await apply(
            intent(bundle: fixture.bundle, action: .linkStaged, version: 1, reference: "reference-cas", target: "capture-cas"),
            command: "command-cas-winner", receipt: "receipt-cas-winner", database: fixture.database
        )
        await assertAttachmentError(.lifecycleConflict) {
            _ = try await self.apply(
                self.intent(bundle: fixture.bundle, action: .linkStaged, version: 1, reference: "reference-cas-loser", target: "capture-cas-loser"),
                command: "command-cas-loser", receipt: "receipt-cas-loser", database: fixture.database
            )
        }
        let graph = try await load(fixture.bundle.revision.revisionID, database: fixture.database)
        XCTAssertEqual(graph?.lifecycle.stateVersion, 2)
        XCTAssertEqual(graph?.references.count, 1)
    }

    func testQuarantinePreservesEvidenceUntilZeroReferenceDeletionIsAuthorized() async throws {
        let fixture = try await makePersistedFixture("quarantine")
        _ = try await apply(
            intent(bundle: fixture.bundle, action: .linkStaged, version: 1, reference: "reference-quarantine", target: "capture-quarantine"),
            command: "command-q-link", receipt: "receipt-q-link", database: fixture.database
        )
        let quarantined = try await apply(
            intent(bundle: fixture.bundle, action: .quarantine, version: 2),
            command: "command-quarantine", receipt: "receipt-quarantine", database: fixture.database
        )
        XCTAssertEqual(quarantined.lifecycle.state, .quarantined)
        XCTAssertEqual(quarantined.lifecycle.referenceCount, 1)
        _ = try await apply(
            intent(bundle: fixture.bundle, action: .unlink, version: 3, reference: "reference-quarantine", target: "capture-quarantine"),
            command: "command-q-unlink", receipt: "receipt-q-unlink", database: fixture.database
        )
        let graph = try await load(fixture.bundle.revision.revisionID, database: fixture.database)
        XCTAssertEqual(graph?.lifecycle.state, .quarantined)
        XCTAssertEqual(graph?.lifecycle.referenceCount, 0)
        XCTAssertNotNil(graph?.lifecycle.quarantineReasonCode)
        let pending = try await apply(
            intent(bundle: fixture.bundle, action: .authorizeDeletion, version: 4),
            command: "command-q-delete", receipt: "receipt-q-delete", database: fixture.database
        )
        XCTAssertEqual(pending.lifecycle.state, .deletionPending)
        let unresolvedEvidenceCount = try await fixture.database.transaction(.deferred) { database in
            try database.query(
                "SELECT quarantine_id FROM runtime_blob_quarantine WHERE blob_id = ? AND resolved_at_ms IS NULL",
                bindings: [.text(fixture.bundle.manifest.blobID.rawValue)]
            ).count
        }
        XCTAssertEqual(unresolvedEvidenceCount, 1)
    }

    func testSameBlobRevisionReplacementRebasesExpectedVersionAndPreservesSharedBytes() async throws {
        let fixture = try await makePersistedFixture("same-blob-replace")
        let (loser, _) = try await XCTAttachmentFixtures.stage(
            vault: fixture.vault, root: fixture.root, bytes: fixture.bytes,
            blob: "blob-replace-loser", attachment: fixture.bundle.revision.attachmentID.rawValue,
            revision: "revision-replace-2", revisionNumber: 2
        )
        let persisted = try await persist(loser, database: fixture.database, reservation: "reservation-replace-2")
        guard case let .deduplicated(effectiveRevision, canonicalBlobID, _, _) = persisted else {
            return XCTFail("Equal plaintext in one privacy domain must resolve to canonical blob authority")
        }
        XCTAssertEqual(canonicalBlobID, fixture.bundle.manifest.blobID)
        _ = try await apply(
            intent(bundle: fixture.bundle, action: .linkStaged, version: 1, reference: "reference-replace-old", target: "capture-replace"),
            command: "command-replace-link", receipt: "receipt-replace-link", database: fixture.database
        )
        let replacementBundle = RuntimeAttachmentStageBundle(
            revision: effectiveRevision, manifest: fixture.bundle.manifest,
            envelope: fixture.bundle.envelope, lifecycle: fixture.bundle.lifecycle
        )
        let replacement = try await apply(
            replacementIntent(
                old: fixture.bundle, new: replacementBundle, version: 2,
                oldReference: "reference-replace-old", newReference: "reference-replace-new",
                target: "capture-replace"
            ),
            command: "command-replace", receipt: "receipt-replace", database: fixture.database
        )
        XCTAssertEqual(replacement.lifecycle.state, .referenced)
        XCTAssertEqual(replacement.lifecycle.referenceCount, 1)
        XCTAssertEqual(replacement.reference?.revisionID, effectiveRevision.revisionID)
        XCTAssertEqual(replacement.referenceTransitions.map(\.toState), [.removed, .active])
    }

    func testDedupLoserRemainsDurablyPendingUntilClaimGradeCleanupCompletes() async throws {
        let fixture = try await makePersistedFixture("dedup")
        let (loser, _) = try await XCTAttachmentFixtures.stage(
            vault: fixture.vault, root: fixture.root, bytes: fixture.bytes,
            blob: "blob-dedup-loser", attachment: "attachment-dedup-loser",
            revision: "revision-dedup-loser"
        )
        let result = try await persist(loser, database: fixture.database, reservation: "reservation-dedup-loser")
        guard case let .deduplicated(_, canonicalBlobID, losingManifest, cleanup) = result else {
            return XCTFail("Dedup must return explicit losing-blob cleanup authority")
        }
        XCTAssertEqual(canonicalBlobID, fixture.bundle.manifest.blobID)
        XCTAssertEqual(losingManifest.blobID, loser.manifest.blobID)
        XCTAssertEqual(cleanup, .pending)
        let due = try await fixture.database.transaction(.deferred) { database in
            try CanonicalRuntimeAttachmentStore.dueStagingOrphans(
                limit: 10, now: XCTAttachmentFixtures.now, database: database
            )
        }
        XCTAssertEqual(due.map(\.losingBlobID), [loser.manifest.blobID])
    }

    func testDedupLoserDeletionClaimDurablyCompletesTombstoneOrphanQuotaAndAttempt() async throws {
        let fixture = try await makePersistedFixture("dedup-claim-completion")
        let (loser, _) = try await XCTAttachmentFixtures.stage(
            vault: fixture.vault, root: fixture.root, bytes: fixture.bytes,
            blob: "blob-dedup-claim-loser", attachment: "attachment-dedup-claim-loser",
            revision: "revision-dedup-claim-loser"
        )
        guard case let .deduplicated(_, _, losingManifest, _) = try await persist(
            loser, database: fixture.database, reservation: "reservation-dedup-claim-loser"
        ) else {
            return XCTFail("The fresh physical duplicate must become durable orphan authority")
        }
        let inspection = try await fixture.vault.inspectOwnedManifest(losingManifest)
        let authorityID = RuntimeAttachmentCodec.sha256(Data([
            "ambitions.attachment.dedup-manifest-deletion-authority.v1",
            inspection.manifest.blobID.rawValue, inspection.manifestDigest,
            inspection.manifest.opaqueRelativeDirectory,
        ].joined(separator: "\u{0}").utf8))
        let occurrence = RuntimeAttachmentCodec.sha256(Data([
            "dedup", inspection.manifest.blobID.rawValue, inspection.manifestDigest,
            inspection.manifest.opaqueRelativeDirectory,
            String(inspection.directoryDevice), String(inspection.directoryInode),
        ].joined(separator: "\u{0}").utf8))
        let claim = try await fixture.database.transaction(.immediate) { database in
            XCTAssertTrue(try CanonicalRuntimeAttachmentStore.beginRecoveryAttempt(
                workKind: .manifestDirectory, authorityID: authorityID,
                occurrence: occurrence, now: XCTAttachmentFixtures.now, database: database
            ))
            return try CanonicalRuntimeAttachmentStore.claimUnownedManifestDeletion(
                inspection, recoveryAuthorityID: authorityID,
                now: XCTAttachmentFixtures.now,
                expiresAt: XCTAttachmentFixtures.now.addingTimeInterval(60),
                database: database
            )
        }
        let vaultClaim = try await fixture.vault.prepareUnownedManifestDeletion(
            inspection, claim: claim, now: XCTAttachmentFixtures.now
        )
        let proof = try await fixture.vault.finalizeUnownedManifestDeletion(
            vaultClaim, now: { XCTAttachmentFixtures.now.addingTimeInterval(1) }
        )
        try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.completeUnownedManifestDeletion(
                claim: claim, proof: proof,
                recoveryAuthorityID: authorityID, database: database
            )
        }
        let authority = try await fixture.database.transaction(.deferred) { database in
            (
                try database.query(
                    "SELECT cleaned_at_ms FROM runtime_blob_staging_orphans WHERE losing_blob_id = ?",
                    bindings: [.text(losingManifest.blobID.rawValue)]
                ),
                try database.query(
                    "SELECT claim_id FROM runtime_attachment_manifest_deletion_tombstones WHERE blob_id = ?",
                    bindings: [.text(losingManifest.blobID.rawValue)]
                ),
                try database.query(
                    "SELECT orphan_bytes FROM runtime_blob_quota_ledgers WHERE owner_id = 'attachment-tests'"
                ),
                try database.query(
                    "SELECT resolved_at_ms FROM runtime_attachment_recovery_attempts WHERE work_kind = 'manifest_directory' AND authority_id = ?",
                    bindings: [.text(authorityID)]
                )
            )
        }
        XCTAssertNotEqual(authority.0.first?.value(named: "cleaned_at_ms"), .null)
        XCTAssertEqual(authority.1.count, 1)
        XCTAssertEqual(authority.2.first?.value(named: "orphan_bytes"), .integer(0))
        XCTAssertNotEqual(authority.3.first?.value(named: "resolved_at_ms"), .null)
    }

    func testFreshPhysicalStageCannotReuseCanonicalBlobIdentityAsInsertedReplay() async throws {
        let fixture = try await makePersistedFixture("same-id-fresh-stage")
        let secondVault = try XCTAttachmentFixtures.vault(
            root: fixture.root.appendingPathComponent("vault"), token: "opaque-fresh-stage-token"
        )
        let (fresh, _) = try await XCTAttachmentFixtures.stage(
            vault: secondVault, root: fixture.root, bytes: fixture.bytes,
            blob: fixture.bundle.manifest.blobID.rawValue,
            attachment: "attachment-fresh-same-id", revision: "revision-fresh-same-id"
        )
        XCTAssertNotEqual(
            fresh.manifest.opaqueRelativeDirectory,
            fixture.bundle.manifest.opaqueRelativeDirectory
        )
        await assertAttachmentError(.lifecycleConflict) {
            _ = try await self.persist(
                fresh, database: fixture.database, reservation: "reservation-fresh-same-id"
            )
        }
    }

    func testLifecycleAndReferenceHistoriesAreImmutableDatabaseAuthority() async throws {
        let fixture = try await makePersistedFixture("immutable-history")
        _ = try await apply(
            intent(bundle: fixture.bundle, action: .linkStaged, version: 1, reference: "reference-immutable", target: "capture-immutable"),
            command: "command-immutable", receipt: "receipt-immutable", database: fixture.database
        )
        do {
            try await fixture.database.transaction(.immediate) { database in
                _ = try database.execute("UPDATE runtime_attachment_lifecycle_history SET occurred_at_ms = occurred_at_ms + 1")
            }
            XCTFail("Lifecycle history must reject mutation")
        } catch { XCTAssertTrue(true) }
        do {
            try await fixture.database.transaction(.immediate) { database in
                _ = try database.execute("DELETE FROM runtime_attachment_reference_history")
            }
            XCTFail("Reference history must reject deletion")
            // AMBitionsAllowWeakPattern(reason: "Expected rejection establishes immutable reference history invariant")
        } catch { XCTAssertTrue(true) }
    }

    func testGCLeaseHistoryRecordsExpiryReacquisitionAndRenewalBeforeCurrentAuthority() async throws {
        let fixture = try await makePersistedFixture("gc-recheck")
        _ = try await apply(
            intent(bundle: fixture.bundle, action: .authorizeDeletion, version: 1),
            command: "command-gc-authorize", receipt: "receipt-gc-authorize",
            database: fixture.database
        )
        let leaseID = RuntimeBlobGCLeaseID(rawValue: "lease-recheck")!
        let work = try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.acquireGCLease(
                leaseID: leaseID, ownerID: "gc-tests", now: XCTAttachmentFixtures.now,
                expiresAt: XCTAttachmentFixtures.now.addingTimeInterval(60), database: database
            )
        }
        let unwrappedWork = try XCTUnwrap(work)
        let lease = RuntimeBlobGCLease(
            version: 1, leaseID: leaseID, blobID: unwrappedWork.manifest.blobID,
            expectedStateVersion: unwrappedWork.lifecycle.stateVersion, ownerID: "gc-tests",
            acquiredAt: XCTAttachmentFixtures.now,
            expiresAt: XCTAttachmentFixtures.now.addingTimeInterval(60)
        )
        do {
            _ = try await fixture.database.transaction(.deferred) { database in
                try CanonicalRuntimeAttachmentStore.confirmGCLease(
                    lease, now: XCTAttachmentFixtures.now.addingTimeInterval(61), database: database
                )
            }
            XCTFail("Expired GC lease must not authorize deletion")
        } catch let error as RuntimeCanonicalAttachmentError {
            XCTAssertEqual(error, .invalidLease)
        }
        let expiryTime = XCTAttachmentFixtures.now.addingTimeInterval(61)
        let expiredCount = try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.expireGCLeases(
                limit: 10, now: expiryTime, database: database
            )
        }
        XCTAssertEqual(expiredCount, 1)
        let reacquiredAt = XCTAttachmentFixtures.now.addingTimeInterval(62)
        let reacquiredExpiry = reacquiredAt.addingTimeInterval(60)
        let reacquiredLeaseID = RuntimeBlobGCLeaseID(rawValue: "lease-reacquired")!
        let reacquiredWork = try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.acquireGCLease(
                leaseID: reacquiredLeaseID, ownerID: "gc-tests-reacquired", now: reacquiredAt,
                expiresAt: reacquiredExpiry, database: database
            )
        }
        XCTAssertEqual(reacquiredWork?.manifest.blobID, unwrappedWork.manifest.blobID)
        let reacquiredLease = RuntimeBlobGCLease(
            version: 1, leaseID: reacquiredLeaseID, blobID: unwrappedWork.manifest.blobID,
            expectedStateVersion: unwrappedWork.lifecycle.stateVersion,
            ownerID: "gc-tests-reacquired", acquiredAt: reacquiredAt,
            expiresAt: reacquiredExpiry
        )
        let renewedAt = reacquiredAt.addingTimeInterval(20)
        let renewedExpiry = reacquiredExpiry.addingTimeInterval(20)
        let renewedLease = try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.renewGCLease(
                reacquiredLease, now: renewedAt, expiresAt: renewedExpiry, database: database
            )
        }
        XCTAssertEqual(renewedLease.leaseID, reacquiredLeaseID)
        XCTAssertEqual(renewedLease.acquiredAt, renewedAt)
        XCTAssertEqual(renewedLease.expiresAt, renewedExpiry)
        let history = try await fixture.database.transaction(.deferred) { database in
            try database.query(
                """
                SELECT transition_kind, authority_version, prior_authority_version,
                       transition_digest, history_payload_digest
                FROM runtime_blob_gc_lease_history WHERE blob_id = ?
                ORDER BY authority_version
                """,
                bindings: [.text(unwrappedWork.manifest.blobID.rawValue)]
            )
        }
        XCTAssertEqual(
            history.compactMap { row -> String? in
                guard case let .text(value)? = row.value(named: "transition_kind") else { return nil }
                return value
            },
            ["acquired", "expired", "reacquired", "renewed"]
        )
        XCTAssertEqual(
            history.compactMap { row -> Int64? in
                guard case let .integer(value)? = row.value(named: "authority_version") else {
                    return nil
                }
                return value
            },
            [1, 2, 3, 4]
        )
        for row in history {
            guard case let .text(transitionDigest)? = row.value(named: "transition_digest"),
                  case let .text(payloadDigest)? = row.value(named: "history_payload_digest") else {
                return XCTFail("GC lease history must retain both authenticated digests")
            }
            XCTAssertEqual(transitionDigest.count, 64)
            XCTAssertEqual(payloadDigest.count, 64)
            XCTAssertNotEqual(transitionDigest, payloadDigest)
        }
        do {
            try await fixture.database.transaction(.immediate) { database in
                try database.execute(
                    "UPDATE runtime_blob_gc_leases SET owner_id = 'forged-owner' WHERE blob_id = ?",
                    bindings: [.text(unwrappedWork.manifest.blobID.rawValue)]
                )
            }
            XCTFail("Current GC authority must reject updates without prior immutable history")
            // AMBitionsAllowWeakPattern(reason: "Expected rejection establishes current garbage collection authority invariant")
        } catch { XCTAssertTrue(true) }
    }

    func testGCTombstonePreventsASecondLeaseAfterPhysicalDeletionConfirmation() async throws {
        let fixture = try await makePersistedFixture("gc-tombstone")
        _ = try await apply(
            intent(bundle: fixture.bundle, action: .authorizeDeletion, version: 1),
            command: "command-gc-tombstone-authorize", receipt: "receipt-gc-tombstone-authorize",
            database: fixture.database
        )
        let leaseID = RuntimeBlobGCLeaseID(rawValue: "lease-tombstone")!
        let work = try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.acquireGCLease(
                leaseID: leaseID, ownerID: "gc-tests", now: XCTAttachmentFixtures.now,
                expiresAt: XCTAttachmentFixtures.now.addingTimeInterval(60), database: database
            )
        }
        let unwrappedWork = try XCTUnwrap(work)
        let lease = RuntimeBlobGCLease(
            version: 1, leaseID: leaseID, blobID: unwrappedWork.manifest.blobID,
            expectedStateVersion: unwrappedWork.lifecycle.stateVersion, ownerID: "gc-tests",
            acquiredAt: XCTAttachmentFixtures.now,
            expiresAt: XCTAttachmentFixtures.now.addingTimeInterval(60)
        )
        let deletionClaim = try await fixture.vault.prepareLeaseOwnedDeletion(
            unwrappedWork, lease: lease, now: XCTAttachmentFixtures.now
        )
        let deletionProof = try await fixture.vault.finalizeLeaseOwnedDeletion(
            deletionClaim, now: { XCTAttachmentFixtures.now }
        )
        XCTAssertEqual(deletionProof.disposition, .removedOwnedDirectory)
        XCTAssertNotNil(deletionProof.directoryDevice)
        XCTAssertNotNil(deletionProof.directoryInode)
        let tombstone = try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.recordDeletion(
                work: unwrappedWork, lease: lease,
                tombstoneID: RuntimeBlobTombstoneID(rawValue: "tombstone-gc")!,
                proof: deletionProof, recordedAt: XCTAttachmentFixtures.now,
                database: database
            )
        }
        XCTAssertTrue(tombstone.physicalDeletionConfirmed)
        XCTAssertEqual(tombstone.physicalDeletionDisposition, .removedOwnedDirectory)
        XCTAssertEqual(tombstone.blobID, unwrappedWork.manifest.blobID)
        let transitions = try await fixture.database.transaction(.deferred) { database in
            try database.query(
                "SELECT transition_kind FROM runtime_blob_gc_lease_history WHERE blob_id = ? ORDER BY authority_version",
                bindings: [.text(unwrappedWork.manifest.blobID.rawValue)]
            ).compactMap { row -> String? in
                guard case let .text(value)? = row.value(named: "transition_kind") else { return nil }
                return value
            }
        }
        XCTAssertEqual(transitions, ["acquired", "released"])
        let second = try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.acquireGCLease(
                leaseID: RuntimeBlobGCLeaseID(rawValue: "lease-second")!, ownerID: "gc-tests",
                now: XCTAttachmentFixtures.now,
                expiresAt: XCTAttachmentFixtures.now.addingTimeInterval(60), database: database
            )
        }
        XCTAssertNil(second)
    }

    func testGCAlreadyAbsentProofUsesExplicitDispositionAndDurableTombstoneAuthority() async throws {
        let fixture = try await makePersistedFixture("gc-already-absent")
        _ = try await apply(
            intent(bundle: fixture.bundle, action: .authorizeDeletion, version: 1),
            command: "command-gc-absent-authorize", receipt: "receipt-gc-absent-authorize",
            database: fixture.database
        )
        let leaseID = RuntimeBlobGCLeaseID(rawValue: "lease-gc-already-absent")!
        let optionalWork = try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.acquireGCLease(
                leaseID: leaseID, ownerID: "gc-tests", now: XCTAttachmentFixtures.now,
                expiresAt: XCTAttachmentFixtures.now.addingTimeInterval(60), database: database
            )
        }
        let work = try XCTUnwrap(optionalWork)
        let lease = RuntimeBlobGCLease(
            version: 1, leaseID: leaseID, blobID: work.manifest.blobID,
            expectedStateVersion: work.lifecycle.stateVersion, ownerID: "gc-tests",
            acquiredAt: XCTAttachmentFixtures.now,
            expiresAt: XCTAttachmentFixtures.now.addingTimeInterval(60)
        )
        let ownedDirectory = fixture.root.appendingPathComponent("vault", isDirectory: true)
            .appendingPathComponent(work.manifest.opaqueRelativeDirectory, isDirectory: true)
        try FileManager.default.removeItem(at: ownedDirectory)
        let claim = try await fixture.vault.prepareLeaseOwnedDeletion(
            work, lease: lease, now: XCTAttachmentFixtures.now
        )
        XCTAssertEqual(claim.disposition, .confirmedAlreadyAbsent)
        XCTAssertNil(claim.directoryDevice)
        XCTAssertNil(claim.directoryInode)
        let proof = try await fixture.vault.finalizeLeaseOwnedDeletion(
            claim, now: { XCTAttachmentFixtures.now }
        )
        XCTAssertEqual(proof.disposition, .confirmedAlreadyAbsent)
        XCTAssertNil(proof.directoryDevice)
        XCTAssertNil(proof.directoryInode)
        let tombstone = try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.recordDeletion(
                work: work, lease: lease,
                tombstoneID: RuntimeBlobTombstoneID(rawValue: "tombstone-gc-already-absent")!,
                proof: proof, recordedAt: XCTAttachmentFixtures.now, database: database
            )
        }
        XCTAssertTrue(tombstone.physicalDeletionConfirmed)
        XCTAssertEqual(tombstone.physicalDeletionDisposition, .confirmedAlreadyAbsent)
        let storedDisposition = try await fixture.database.transaction(.deferred) { database in
            try database.query(
                "SELECT physical_deletion_disposition FROM runtime_blob_deletion_tombstones WHERE blob_id = ?",
                bindings: [.text(work.manifest.blobID.rawValue)]
            ).first?.value(named: "physical_deletion_disposition")
        }
        XCTAssertEqual(storedDisposition, .text("confirmed_already_absent"))
    }

    func testFinalizationRecoversAfterMarkerWriteBeforeDatabaseCompletionAndDoesNotRepeat() async throws {
        let fixture = try await makePersistedFixture("finalization-recovery")
        _ = try await apply(
            intent(bundle: fixture.bundle, action: .linkStaged, version: 1, reference: "reference-finalize", target: "capture-finalize"),
            command: "command-finalize", receipt: "receipt-finalize", database: fixture.database
        )
        let due = try await fixture.database.transaction(.deferred) { database in
            try CanonicalRuntimeAttachmentStore.dueFinalizations(
                limit: 10, now: XCTAttachmentFixtures.now, database: database
            )
        }
        let work = try XCTUnwrap(due.first)
        let proof = try await fixture.vault.writeFinalizationMarker(
            manifest: work.manifest, manifestDigest: work.manifestDigest,
            receiptID: work.receiptID, lineage: work.lineage, finalizedAt: XCTAttachmentFixtures.now
        )
        let retryProof = try await fixture.vault.writeFinalizationMarker(
            manifest: work.manifest, manifestDigest: work.manifestDigest,
            receiptID: work.receiptID, lineage: work.lineage,
            finalizedAt: XCTAttachmentFixtures.now.addingTimeInterval(30)
        )
        XCTAssertEqual(retryProof, proof)

        let stillDue = try await fixture.database.transaction(.deferred) { database in
            try CanonicalRuntimeAttachmentStore.dueFinalizations(
                limit: 10, now: XCTAttachmentFixtures.now, database: database
            )
        }
        XCTAssertEqual(stillDue, [work])
        try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.completeFinalization(
                work, proof: proof, database: database
            )
        }
        let after = try await fixture.database.transaction(.deferred) { database in
            try CanonicalRuntimeAttachmentStore.dueFinalizations(
                limit: 10, now: XCTAttachmentFixtures.now, database: database
            )
        }
        XCTAssertTrue(after.isEmpty)
        let graph = try await load(fixture.bundle.revision.revisionID, database: fixture.database)
        XCTAssertEqual(graph?.lifecycle.state, .finalized)
        XCTAssertEqual(graph?.lifecycle.referenceCount, 1)
        let artifacts = try await fixture.database.transaction(.deferred) { database in
            var budget = RuntimeReceiptDecodedByteBudget(
                maximumBytes: RuntimeCommittedReceiptReadBounds.maximumAttachmentArtifactGraphBytes
            )
            try CanonicalRuntimeAttachmentStore.authenticatedReceiptArtifacts(
                receiptID: work.receiptID, budget: &budget, database: database
            )
        }
        XCTAssertEqual(artifacts.map(\.kind), [.attachmentFinalizationIntent, .attachmentRevision])
    }

    func testFinalizedLastUnlinkCanRelinkOnlyThroughAuthenticatedCompletionAuthority() async throws {
        let fixture = try await makePersistedFixture("finalized-orphan-relink")
        _ = try await apply(
            intent(bundle: fixture.bundle, action: .linkStaged, version: 1,
                   reference: "reference-finalized-first", target: "capture-finalized-first"),
            command: "command-finalized-first", receipt: "receipt-finalized-first",
            database: fixture.database
        )
        let work = try await fixture.database.transaction(.deferred) { database in
            try XCTUnwrap(CanonicalRuntimeAttachmentStore.dueFinalizations(
                limit: 1, now: XCTAttachmentFixtures.now, database: database
            ).first)
        }
        let proof = try await fixture.vault.writeFinalizationMarker(
            manifest: work.manifest, manifestDigest: work.manifestDigest,
            receiptID: work.receiptID, lineage: work.lineage,
            finalizedAt: XCTAttachmentFixtures.now
        )
        try await fixture.database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.completeFinalization(
                work, proof: proof, database: database
            )
        }
        let orphaned = try await apply(
            intent(bundle: fixture.bundle, action: .unlink, version: 3,
                   reference: "reference-finalized-first", target: "capture-finalized-first"),
            command: "command-finalized-unlink", receipt: "receipt-finalized-unlink",
            database: fixture.database
        )
        XCTAssertEqual(orphaned.lifecycle.state, .orphaned)
        let relinked = try await apply(
            intent(bundle: fixture.bundle, action: .linkStaged, version: 4,
                   reference: "reference-finalized-second", target: "capture-finalized-second"),
            command: "command-finalized-second", receipt: "receipt-finalized-second",
            database: fixture.database
        )
        XCTAssertEqual(relinked.lifecycle.state, .finalized)
        XCTAssertEqual(relinked.lifecycle.referenceCount, 1)
        let dedup = try await fixture.database.transaction(.deferred) { database in
            try database.query(
                "SELECT canonical_blob_id FROM runtime_blob_dedup_authority WHERE canonical_blob_id = ?",
                bindings: [.text(fixture.bundle.manifest.blobID.rawValue)]
            )
        }
        XCTAssertEqual(dedup.count, 1)
    }

    func testAttachmentReceiptAuthenticationFailsClosedWhenAggregateByteBudgetIsExhausted() async throws {
        let fixture = try await makePersistedFixture("receipt-byte-budget")
        _ = try await apply(
            intent(bundle: fixture.bundle, action: .linkStaged, version: 1, reference: "reference-budget", target: "capture-budget"),
            command: "command-budget", receipt: "receipt-budget", database: fixture.database
        )
        do {
            _ = try await fixture.database.transaction(.deferred) { database in
                var budget = RuntimeReceiptDecodedByteBudget(maximumBytes: 1)
                return try CanonicalRuntimeAttachmentStore.authenticatedReceiptArtifacts(
                    receiptID: RuntimeReceiptID(rawValue: "receipt-budget")!,
                    budget: &budget,
                    database: database
                )
            }
            XCTFail("Receipt attachment authority must share and honor the aggregate decoded-byte budget")
        } catch let error as RuntimeCommittedReceiptQueryError {
            XCTAssertEqual(error, .firstRowExceedsBound)
        }
    }

    func testFinalizationSidecarCannotBeForgedBeforeVaultProofAndCompletedIntent() async throws {
        let fixture = try await makePersistedFixture("sidecar-forging")
        _ = try await apply(
            intent(bundle: fixture.bundle, action: .linkStaged, version: 1, reference: "reference-sidecar", target: "capture-sidecar"),
            command: "command-sidecar", receipt: "receipt-sidecar", database: fixture.database
        )
        let payload = Data([1])
        do {
            try await fixture.database.transaction(.immediate) { database in
                try database.execute(
                    "INSERT INTO runtime_attachment_receipt_links(receipt_id, revision_id, blob_id, manifest_digest, link_kind, artifact_payload, artifact_digest, link_version) VALUES('receipt-sidecar', ?, ?, ?, 'finalization', ?, ?, 1)",
                    bindings: [
                        .text(fixture.bundle.revision.revisionID.rawValue),
                        .text(fixture.bundle.manifest.blobID.rawValue),
                        .text(fixture.bundle.revision.manifestDigest), .blob(payload),
                        .text(RuntimeAttachmentCodec.sha256(payload)),
                    ]
                )
            }
            XCTFail("Caller-manufactured finalization evidence must not become a late receipt sidecar")
            // AMBitionsAllowWeakPattern(reason: "Expected rejection establishes receipt finalization evidence invariant")
        } catch { XCTAssertTrue(true) }
    }

    private typealias Fixture = (
        root: URL, vault: RuntimeAttachmentVault, database: SQLiteDatabase,
        bundle: RuntimeAttachmentStageBundle, bytes: Data
    )

    private func makePersistedFixture(_ label: String) async throws -> Fixture {
        let root = try XCTAttachmentFixtures.directory(label)
        let vault = try XCTAttachmentFixtures.vault(root: root.appendingPathComponent("vault"))
        let bytes = Data((0..<40_000).map { UInt8($0 % 251) })
        let (bundle, _) = try await XCTAttachmentFixtures.stage(vault: vault, root: root, bytes: bytes)
        let database = try SQLiteDatabase(url: root.appendingPathComponent("Runtime.sqlite"))
        try await database.transaction(.exclusive) { database in
            for statement in CanonicalRuntimeAttachmentSchemaPlan.fullGenerationStatements {
                try database.execute(statement)
            }
            try database.execute(
                "INSERT INTO runtime_store_metadata(singleton_id, schema_version, generation_id, created_at_ms) VALUES(1, 8, 'attachment-tests', 0)"
            )
            try database.execute("PRAGMA user_version = 8")
        }
        _ = try await persist(bundle, database: database, reservation: "reservation-blob-test-1")
        return (root, vault, database, bundle, bytes)
    }

    private func persist(
        _ bundle: RuntimeAttachmentStageBundle,
        database: SQLiteDatabase,
        reservation rawReservation: String
    ) async throws -> RuntimeAttachmentStagePersistenceResult {
        let reservationID = RuntimeBlobQuotaReservationID(rawValue: rawReservation)!
        return try await database.transaction(.immediate) { database in
            try CanonicalRuntimeAttachmentStore.reserveQuota(
                RuntimeBlobQuotaReservation(
                    version: 1, reservationID: reservationID,
                    privacyDomain: bundle.manifest.privacyDomain,
                    reservedBytes: bundle.manifest.plaintextByteCount,
                    ownerID: "attachment-tests", createdAt: XCTAttachmentFixtures.now,
                    expiresAt: XCTAttachmentFixtures.now.addingTimeInterval(600), consumedByBlobID: nil
                ),
                now: XCTAttachmentFixtures.now, database: database
            )
            return try CanonicalRuntimeAttachmentStore.persistStage(
                bundle, reservationID: reservationID, now: XCTAttachmentFixtures.now, database: database
            )
        }
    }

    private func apply(
        _ intent: RuntimeAttachmentCommandIntent,
        command: String,
        receipt: String,
        database: SQLiteDatabase
    ) async throws -> RuntimeAttachmentMutationResult {
        try await database.transaction(.immediate) { database in
            let lineage = try seedLineage(command: command, receipt: receipt, database: database)
            return try CanonicalRuntimeAttachmentStore.apply(
                intent, commandID: RuntimeCommandID(rawValue: command)!,
                receiptID: RuntimeReceiptID(rawValue: receipt)!, lineage: lineage,
                targetRevision: 1, at: XCTAttachmentFixtures.now, database: database
            )
        }
    }

    private func seedLineage(
        command: String,
        receipt: String,
        database: isolated SQLiteDatabase
    ) throws -> RuntimeAuthorityLineageReference {
        let digest = RuntimeAttachmentCodec.sha256(Data(command.utf8))
        try database.execute(
            "INSERT OR IGNORE INTO runtime_aggregates(aggregate_kind, aggregate_id, revision, payload_version, payload, payload_checksum) VALUES('capture', ?, 1, 1, X'01', ?)",
            bindings: [.text("aggregate-\(command)"), .text(digest)]
        )
        try database.execute(
            "INSERT INTO runtime_command_idempotency(scope, idempotency_key, command_id, command_fingerprint, claim_version, claim_payload, claimed_at_ms) VALUES('attachment-tests', ?, ?, ?, 1, X'01', 0)",
            bindings: [.text(command), .text(command), .text(digest)]
        )
        try database.execute(
            "INSERT INTO runtime_semantic_events(event_id, command_id, aggregate_kind, aggregate_id, canonical_revision, correlation_id, envelope_version, type_id, payload_version, source_bytes, source_digest, previous_event_hash, event_hash, occurred_at_ms) VALUES(?, ?, 'capture', ?, 1, ?, 1, 'ambitions.attachment.test.v1', 1, X'01', ?, NULL, ?, 0)",
            bindings: [
                .text("event-\(command)"), .text(command), .text("aggregate-\(command)"),
                .text("correlation-\(command)"), .text(RuntimeAttachmentCodec.sha256(Data([1]))), .text(digest),
            ]
        )
        let sequenceRows = try database.query(
            "SELECT sequence FROM runtime_semantic_events WHERE event_id = ? LIMIT 1",
            bindings: [.text("event-\(command)")]
        )
        guard case let .integer(sequence)? = sequenceRows.first?.value(named: "sequence") else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        try database.execute(
            "INSERT INTO runtime_commit_receipts(receipt_id, preparation_id, command_id, terminal_event_sequence, receipt_version, created_at_ms) VALUES(?, ?, ?, ?, 1, 0)",
            bindings: [.text(receipt), .text("preparation-\(command)"), .text(command), .integer(sequence)]
        )
        return RuntimeAuthorityLineageReference(
            eventID: RuntimeEventID(rawValue: "event-\(command)")!,
            eventSequence: UInt64(sequence), eventHash: digest
        )
    }

    private func load(
        _ revisionID: RuntimeAttachmentRevisionID,
        database: SQLiteDatabase
    ) async throws -> RuntimeAttachmentAuthorityGraph? {
        try await database.transaction(.deferred) { database in
            try CanonicalRuntimeAttachmentStore.load(revisionID: revisionID, database: database)
        }
    }

    private func intent(
        bundle: RuntimeAttachmentStageBundle,
        action: RuntimeAttachmentMutationAction,
        version: UInt64,
        reference: String? = nil,
        target: String? = nil
    ) -> RuntimeAttachmentCommandIntent {
        RuntimeAttachmentCommandIntent(
            version: 1, action: action, attachmentID: bundle.revision.attachmentID,
            revisionID: bundle.revision.revisionID, blobID: bundle.manifest.blobID,
            referenceID: reference.flatMap(RuntimeAttachmentReferenceID.init(rawValue:)),
            replacesReferenceID: nil, replacesRevisionID: nil, replacesBlobID: nil,
            target: target.map {
                RuntimeSemanticAggregate(kind: .capture, id: try! RuntimeAggregateID(validating: $0))
            },
            expectedLifecycleVersion: version, expectedReplacedLifecycleVersion: nil,
            manifestDigest: bundle.revision.manifestDigest, replacesManifestDigest: nil,
            quarantineReason: action == .quarantine ? .authenticationFailed : nil,
            quarantineEvidenceFingerprint: action == .quarantine ? String(repeating: "e", count: 64) : nil,
            privacy: bundle.revision.privacy, provenance: bundle.revision.provenance
        )
    }

    private func replacementIntent(
        old: RuntimeAttachmentStageBundle,
        new: RuntimeAttachmentStageBundle,
        version: UInt64,
        oldReference: String,
        newReference: String,
        target: String
    ) -> RuntimeAttachmentCommandIntent {
        RuntimeAttachmentCommandIntent(
            version: 1, action: .replaceRevision, attachmentID: old.revision.attachmentID,
            revisionID: new.revision.revisionID, blobID: new.revision.blobID,
            referenceID: RuntimeAttachmentReferenceID(rawValue: newReference),
            replacesReferenceID: RuntimeAttachmentReferenceID(rawValue: oldReference),
            replacesRevisionID: old.revision.revisionID, replacesBlobID: old.revision.blobID,
            target: RuntimeSemanticAggregate(kind: .capture, id: try! RuntimeAggregateID(validating: target)),
            expectedLifecycleVersion: version, expectedReplacedLifecycleVersion: version,
            manifestDigest: new.revision.manifestDigest,
            replacesManifestDigest: old.revision.manifestDigest,
            quarantineReason: nil, quarantineEvidenceFingerprint: nil,
            privacy: new.revision.privacy, provenance: new.revision.provenance
        )
    }

    private func assertAttachmentError(
        _ expected: RuntimeCanonicalAttachmentError,
        operation: () async throws -> Void
    ) async {
        do { try await operation(); XCTFail("Expected \(expected)") }
        catch let actual as RuntimeCanonicalAttachmentError { XCTAssertEqual(actual, expected) }
        // AMBitionsAllowWeakPattern(reason: "Unexpected error is asserted by shared attachment expectation helper")
        catch { XCTFail("Unexpected error: \(error)") }
    }
}
