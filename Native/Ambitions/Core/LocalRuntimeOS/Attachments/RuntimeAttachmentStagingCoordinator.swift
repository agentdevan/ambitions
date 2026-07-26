import Foundation

struct RuntimeAttachmentStagingRecoveryResult: Sendable, Equatable {
    let cleanedCount: Int
    let findings: [RuntimeAttachmentRecoveryFinding]
}

/// Owns the post-encryption persistence boundary. Intake never links objects,
/// and the vault never decides canonical metadata authority.
actor RuntimeAttachmentStagingCoordinator {
    private let store: CanonicalRuntimeStore
    private let vault: RuntimeAttachmentVault
    private let keyCustody: any RuntimeAttachmentKeyCustody
    private let clock: @Sendable () -> Date

    init(
        store: CanonicalRuntimeStore,
        vault: RuntimeAttachmentVault,
        keyCustody: any RuntimeAttachmentKeyCustody,
        clock: @escaping @Sendable () -> Date = Date.init
    ) {
        self.store = store
        self.vault = vault
        self.keyCustody = keyCustody
        self.clock = clock
    }

    func persist(
        _ bundle: RuntimeAttachmentStageBundle,
        reservationID: RuntimeBlobQuotaReservationID,
        now: Date
    ) async throws -> RuntimeAttachmentStagePersistenceResult {
        try Task.checkCancellation()
        var currentBundle = bundle
        var result: RuntimeAttachmentStagePersistenceResult?
        for _ in 0..<RuntimeAttachmentLimits.maximumRecoveryAttempts {
            do {
                result = try await store.persistStagedAttachment(
                    currentBundle, reservationID: reservationID, now: now
                )
                break
            } catch RuntimeCanonicalAttachmentError.staleWrappingKey {
                try Task.checkCancellation()
                let target = try await keyCustody.currentWrappingKey()
                guard target.id != currentBundle.envelope.wrappingKeyID
                        || target.version != currentBundle.envelope.wrappingKeyVersion else {
                    throw RuntimeCanonicalAttachmentError.corruptAuthority
                }
                let envelope = try await keyCustody.rewrap(
                    currentBundle.envelope, using: target
                )
                currentBundle = RuntimeAttachmentStageBundle(
                    revision: currentBundle.revision,
                    manifest: currentBundle.manifest,
                    envelope: envelope,
                    lifecycle: currentBundle.lifecycle
                )
            }
        }
        guard let result else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        if case let .deduplicated(
            effectiveRevision, canonicalBlobID, losingManifest, cleanup
        ) = result {
            if cleanup == .completed { return result }
            do {
                let firstAuthority = try await store.confirmAttachmentDedupCandidate(
                    revisionID: effectiveRevision.revisionID,
                    canonicalBlobID: canonicalBlobID,
                    keyedContentAddress: losingManifest.keyedContentAddress,
                    now: now
                )
                try await vault.verifyAuthenticatedBlob(firstAuthority)
                _ = try await store.confirmAttachmentDedupCandidate(
                    revisionID: effectiveRevision.revisionID,
                    canonicalBlobID: canonicalBlobID,
                    keyedContentAddress: losingManifest.keyedContentAddress,
                    now: now
                )
                _ = try await deleteDeduplicatedOrphan(losingManifest)
                return .deduplicated(
                    effectiveRevision: effectiveRevision,
                    canonicalBlobID: canonicalBlobID,
                    losingManifest: losingManifest,
                    cleanup: .completed
                )
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                // The durable orphan row intentionally remains due for bounded recovery.
                return .deduplicated(
                    effectiveRevision: effectiveRevision,
                    canonicalBlobID: canonicalBlobID,
                    losingManifest: losingManifest,
                    cleanup: .pendingRecovery
                )
            }
        }
        return result
    }

    func reconcileDedupOrphans(
        limit: Int,
        now: Date
    ) async throws -> RuntimeAttachmentStagingRecoveryResult {
        let due = try await store.dueAttachmentStagingOrphans(limit: limit, now: now)
        var cleaned = 0
        var findings: [RuntimeAttachmentRecoveryFinding] = []
        for orphan in due {
            try Task.checkCancellation()
            let authorityID = orphan.losingBlobID.rawValue
            let occurrence = RuntimeAttachmentCodec.sha256(Data([
                "ambitions.attachment.dedup-orphan-occurrence.v1", authorityID,
                orphan.manifest.opaqueRelativeDirectory,
                String(try RuntimeSemanticEventHashing.milliseconds(orphan.recordedAt)),
            ].joined(separator: "\u{0}").utf8))
            guard try await store.beginAttachmentRecoveryAttempt(
                workKind: .stagingOrphan, authorityID: authorityID,
                occurrence: occurrence, now: now
            ) else { continue }
            do {
                _ = try await deleteDeduplicatedOrphan(orphan.manifest)
                cleaned += 1
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                let fingerprint = RuntimeAttachmentFinalizer.errorFingerprint(
                    workKind: .stagingOrphan, authorityID: authorityID, error: error
                )
                try await store.recordAttachmentRecoveryAttemptFailure(
                    workKind: .stagingOrphan, authorityID: authorityID,
                    errorFingerprint: fingerprint
                )
                let finding = RuntimeAttachmentRecoveryFinding(
                    issue: .interruptedDeletion, blobID: orphan.losingBlobID,
                    opaqueRelativeDirectory: orphan.manifest.opaqueRelativeDirectory,
                    evidenceFingerprint: fingerprint, observedAt: now
                )
                try await store.recordAttachmentRecoveryFinding(finding)
                findings.append(finding)
            }
        }
        return RuntimeAttachmentStagingRecoveryResult(
            cleanedCount: cleaned, findings: findings
        )
    }

    private func deleteDeduplicatedOrphan(
        _ manifest: RuntimeBlobManifestAuthority
    ) async throws -> Date {
        let inspection = try await vault.inspectOwnedManifest(manifest)
        let authorityID = RuntimeAttachmentCodec.sha256(Data([
            "ambitions.attachment.dedup-manifest-deletion-authority.v1",
            inspection.manifest.blobID.rawValue, inspection.manifestDigest,
            inspection.manifest.opaqueRelativeDirectory,
        ].joined(separator: "\u{0}").utf8))
        let occurrence = RuntimeAttachmentCodec.sha256(Data([
            "dedup", inspection.manifest.blobID.rawValue,
            inspection.manifestDigest, inspection.manifest.opaqueRelativeDirectory,
            String(inspection.directoryDevice), String(inspection.directoryInode),
        ].joined(separator: "\u{0}").utf8))
        let claimAt = clock()
        guard try await store.beginAttachmentRecoveryAttempt(
            workKind: .manifestDirectory, authorityID: authorityID,
            occurrence: occurrence, now: claimAt
        ) else {
            throw RuntimeCanonicalAttachmentError.lifecycleConflict
        }
        let claim = try await store.claimUnownedAttachmentManifestDeletion(
            inspection, recoveryAuthorityID: authorityID, now: claimAt,
            expiresAt: claimAt.addingTimeInterval(RuntimeAttachmentLimits.maximumLeaseSeconds)
        )
        let vaultClaim = try await vault.prepareUnownedManifestDeletion(
            inspection, claim: claim, now: clock()
        )
        let proof = try await vault.finalizeUnownedManifestDeletion(
            vaultClaim, now: clock
        )
        try await store.completeUnownedAttachmentManifestDeletion(
            claim: claim, proof: proof, recoveryAuthorityID: authorityID
        )
        return proof.deletedAt
    }
}
