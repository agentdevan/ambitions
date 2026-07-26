import Foundation

struct RuntimeAttachmentRecoveryResult: Sendable, Equatable {
    let findings: [RuntimeAttachmentRecoveryFinding]
    let finalizedCount: Int
    let cleanedDedupOrphanCount: Int
    let expiredStagedCount: Int
    let cleanedTemporaryCount: Int
    let cleanedIntakeLeftoverCount: Int
    let cleanedPortableImportCount: Int
    let expiredQuotaReservationCount: Int
    let rewrappedKeyEnvelopeCount: Int
    let completedManifestDeletionCount: Int
}

actor RuntimeAttachmentRecovery {
    private let store: CanonicalRuntimeStore
    private let vault: RuntimeAttachmentVault
    private let intake: RuntimeAttachmentIntake
    private let staging: RuntimeAttachmentStagingCoordinator
    private let finalizer: RuntimeAttachmentFinalizer
    private let keyRotation: RuntimeAttachmentKeyRotationCoordinator
    private let portableImporter: RuntimeAttachmentPortableImporter
    private let clock: @Sendable () -> Date

    init(
        store: CanonicalRuntimeStore,
        vault: RuntimeAttachmentVault,
        intake: RuntimeAttachmentIntake,
        staging: RuntimeAttachmentStagingCoordinator,
        finalizer: RuntimeAttachmentFinalizer,
        keyRotation: RuntimeAttachmentKeyRotationCoordinator,
        portableImporter: RuntimeAttachmentPortableImporter,
        clock: @escaping @Sendable () -> Date = Date.init
    ) {
        self.store = store
        self.vault = vault
        self.intake = intake
        self.staging = staging
        self.finalizer = finalizer
        self.keyRotation = keyRotation
        self.portableImporter = portableImporter
        self.clock = clock
    }

    func reconcile(limit: Int, now: Date) async throws -> RuntimeAttachmentRecoveryResult {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
        try Task.checkCancellation()
        let cleanedPortableImportCount = try await portableImporter.recoverInterruptedImports(
            limit: 4_096
        )
        let stagingResult = try await staging.reconcileDedupOrphans(limit: limit, now: now)
        let finalizationResult = try await finalizer.finalizeDue(limit: limit, now: now)
        let keyRotationResult = try await keyRotation.resumeActive(limit: limit)
        let expiredQuotaReservationCount = try await store.releaseExpiredAttachmentQuotaReservations(
            limit: limit, now: now
        )
        var findings = stagingResult.findings + finalizationResult.findings
        let staged = try await reconcileExpiredStaging(limit: limit, now: now)
        findings.append(contentsOf: staged.findings)
        let temporary = try await reconcileTemporaryDirectories(limit: limit, now: now)
        findings.append(contentsOf: temporary.findings)
        let intakeLeftovers = try await reconcileIntakeLeftovers(limit: limit, now: now)
        findings.append(contentsOf: intakeLeftovers.findings)
        let manifestDeletion = try await reconcileManifestDeletionClaims(limit: limit, now: now)
        findings.append(contentsOf: manifestDeletion.findings)
        findings.append(contentsOf: try await reconcileManifestDirectories(limit: limit, now: now))
        findings.append(contentsOf: try await reconcileAuthorityGraphs(limit: limit, now: now))
        return RuntimeAttachmentRecoveryResult(
            findings: findings,
            finalizedCount: finalizationResult.completedCount,
            cleanedDedupOrphanCount: stagingResult.cleanedCount,
            expiredStagedCount: staged.count,
            cleanedTemporaryCount: temporary.count,
            cleanedIntakeLeftoverCount: intakeLeftovers.count,
            cleanedPortableImportCount: cleanedPortableImportCount,
            expiredQuotaReservationCount: expiredQuotaReservationCount,
            rewrappedKeyEnvelopeCount: keyRotationResult?.completedThisRun ?? 0,
            completedManifestDeletionCount: manifestDeletion.count
        )
    }

    private func reconcileExpiredStaging(
        limit: Int,
        now: Date
    ) async throws -> (count: Int, findings: [RuntimeAttachmentRecoveryFinding]) {
        let due = try await store.dueStagedAttachmentExpirations(limit: limit, now: now)
        var count = 0
        var findings: [RuntimeAttachmentRecoveryFinding] = []
        for revisionID in due {
            try Task.checkCancellation()
            guard let graph = try await store.attachmentAuthoritySnapshot(
                revisionID: revisionID
            ) else { continue }
            let authorityID = graph.manifest.blobID.rawValue
            let occurrence = CanonicalRuntimeAttachmentStore.stagedExpiryOccurrence(
                revisionID: revisionID, stateVersion: graph.lifecycle.stateVersion
            )
            do {
                guard let finding = try await store.expireStagedAttachmentDuringRecovery(
                    revisionID: revisionID, recoveryAuthorityID: authorityID, at: now
                ) else { continue }
                findings.append(finding)
                count += 1
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                let fingerprint = RuntimeAttachmentFinalizer.errorFingerprint(
                    workKind: .stagingOrphan, authorityID: authorityID, error: error
                )
                try await store.recordAttachmentRecoveryFailureAfterRolledBackAttempt(
                    workKind: .stagingOrphan, authorityID: authorityID,
                    occurrence: occurrence, now: now, errorFingerprint: fingerprint
                )
                let finding = RuntimeAttachmentRecoveryFinding(
                    issue: .stagedExpired, blobID: graph.manifest.blobID,
                    opaqueRelativeDirectory: graph.manifest.opaqueRelativeDirectory,
                    evidenceFingerprint: fingerprint, observedAt: now
                )
                try await store.recordAttachmentRecoveryFinding(finding)
                findings.append(finding)
            }
        }
        return (count, findings)
    }

    private func reconcileTemporaryDirectories(
        limit: Int,
        now: Date
    ) async throws -> (count: Int, findings: [RuntimeAttachmentRecoveryFinding]) {
        let scan: RuntimeAttachmentRecoveryScanKind = .temporaryDirectories
        let cursor = try await store.attachmentRecoveryCursor(scanKind: scan)
        let cycle = cursor?.cycle ?? 0
        let page = try await vault.ownedTemporaryDirectories(
            limit: limit, afterCursorKey: cursor?.lastKey
        )
        var count = 0
        var findings: [RuntimeAttachmentRecoveryFinding] = []
        for entry in page.entries {
            try Task.checkCancellation()
            let key = entry.cursorKey
            let authorityID = try recurringAuthorityID(scan: scan, key: key)
            if try await store.beginAttachmentRecoveryAttempt(
                workKind: .temporaryDirectory, authorityID: authorityID,
                occurrence: "scan:\(scan.rawValue):\(cycle)", now: now
            ) {
                do {
                    guard case let .owned(_, temporary) = entry else {
                        guard case let .malformed(malformed) = entry else {
                            throw RuntimeCanonicalAttachmentError.corruptAuthority
                        }
                        throw malformed.error
                    }
                    let finding = try makeFinding(
                        issue: .temporaryWithoutManifest, blobID: nil,
                        relativeDirectory: temporary.lastPathComponent, cycle: cycle, now: now
                    )
                    try await store.recordAttachmentRecoveryFinding(finding)
                    try await vault.removeOwnedTemporaryDirectory(temporary)
                    _ = try await store.resolveOpenAttachmentRecoveryFindings(
                        issue: finding.issue, blobID: finding.blobID,
                        relativeDirectory: finding.opaqueRelativeDirectory, at: now
                    )
                    try await store.resolveAttachmentRecoveryAttempt(
                        workKind: .temporaryDirectory, authorityID: authorityID, at: now
                    )
                    findings.append(finding)
                    count += 1
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    let relativeDirectory: String = switch entry {
                    case let .owned(_, url): url.lastPathComponent
                    case let .malformed(value): "redacted-\(value.redactedNameDigest)"
                    }
                    findings.append(try await recordFailure(
                        workKind: .temporaryDirectory, authorityID: authorityID,
                        issue: .temporaryWithoutManifest, blobID: nil,
                        relativeDirectory: relativeDirectory, cycle: cycle, now: now, error: error
                    ))
                }
            }
        }
        if page.exhausted {
            _ = try await store.advanceAttachmentRecoveryCursor(
                scanKind: scan, lastKey: nil, wrapped: true, at: now
            )
        } else if let nextCursorKey = page.nextCursorKey {
            _ = try await store.advanceAttachmentRecoveryCursor(
                scanKind: scan, lastKey: nextCursorKey, wrapped: false, at: now
            )
        } else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return (count, findings)
    }

    private func reconcileIntakeLeftovers(
        limit: Int,
        now: Date
    ) async throws -> (count: Int, findings: [RuntimeAttachmentRecoveryFinding]) {
        let scan: RuntimeAttachmentRecoveryScanKind = .intakeLeftovers
        let cursor = try await store.attachmentRecoveryCursor(scanKind: scan)
        let cycle = cursor?.cycle ?? 0
        let page = try await intake.ownedIntakeLeftovers(
            limit: limit, afterCursorKey: cursor?.lastKey
        )
        var count = 0
        var findings: [RuntimeAttachmentRecoveryFinding] = []
        for entry in page.entries {
            try Task.checkCancellation()
            let key = entry.cursorKey
            let authorityID = try recurringAuthorityID(scan: scan, key: key)
            if try await store.beginAttachmentRecoveryAttempt(
                workKind: .intakeLeftover, authorityID: authorityID,
                occurrence: "scan:\(scan.rawValue):\(cycle)", now: now
            ) {
                do {
                    guard case let .owned(_, leftover) = entry else {
                        guard case let .malformed(malformed) = entry else {
                            throw RuntimeCanonicalAttachmentError.corruptAuthority
                        }
                        throw malformed.error
                    }
                    let finding = try makeFinding(
                        issue: .intakeLeftover, blobID: nil,
                        relativeDirectory: leftover.lastPathComponent, cycle: cycle, now: now
                    )
                    try await store.recordAttachmentRecoveryFinding(finding)
                    try await intake.removeOwnedIntakeLeftover(leftover)
                    _ = try await store.resolveOpenAttachmentRecoveryFindings(
                        issue: finding.issue, blobID: finding.blobID,
                        relativeDirectory: finding.opaqueRelativeDirectory, at: now
                    )
                    try await store.resolveAttachmentRecoveryAttempt(
                        workKind: .intakeLeftover, authorityID: authorityID, at: now
                    )
                    findings.append(finding)
                    count += 1
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    let relativeDirectory: String = switch entry {
                    case let .owned(_, url): url.lastPathComponent
                    case let .malformed(value): "redacted-\(value.redactedNameDigest)"
                    }
                    findings.append(try await recordFailure(
                        workKind: .intakeLeftover, authorityID: authorityID,
                        issue: .intakeLeftover, blobID: nil,
                        relativeDirectory: relativeDirectory,
                        cycle: cycle, now: now, error: error
                    ))
                }
            }
        }
        if page.exhausted {
            _ = try await store.advanceAttachmentRecoveryCursor(
                scanKind: scan, lastKey: nil, wrapped: true, at: now
            )
        } else if let nextCursorKey = page.nextCursorKey {
            _ = try await store.advanceAttachmentRecoveryCursor(
                scanKind: scan, lastKey: nextCursorKey, wrapped: false, at: now
            )
        } else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return (count, findings)
    }

    private func reconcileManifestDirectories(
        limit: Int,
        now: Date
    ) async throws -> [RuntimeAttachmentRecoveryFinding] {
        let scan: RuntimeAttachmentRecoveryScanKind = .manifestDirectories
        let cursor = try await store.attachmentRecoveryCursor(scanKind: scan)
        let cycle = cursor?.cycle ?? 0
        let page = try await vault.ownedManifestDirectories(
            limit: limit, afterCursorKey: cursor?.lastKey
        )
        var findings: [RuntimeAttachmentRecoveryFinding] = []
        for entry in page.entries {
            try Task.checkCancellation()
            let key = entry.cursorKey
            let authorityID = try recurringAuthorityID(scan: scan, key: key)
            if try await store.beginAttachmentRecoveryAttempt(
                workKind: .manifestDirectory, authorityID: authorityID,
                occurrence: "scan:\(scan.rawValue):\(cycle)", now: now
            ) {
                do {
                    guard case let .owned(_, directory) = entry else {
                        guard case let .malformed(malformed) = entry else {
                            throw RuntimeCanonicalAttachmentError.corruptAuthority
                        }
                        throw malformed.error
                    }
                    let inspection = try await vault.inspectOwnedManifestDirectory(directory)
                    let hasAuthority = try await store.hasAttachmentBlobAuthority(
                        blobID: inspection.manifest.blobID,
                        manifestDigest: inspection.manifestDigest,
                        opaqueRelativeDirectory: inspection.manifest.opaqueRelativeDirectory
                    )
                    if hasAuthority == false {
                        let finding = try makeFinding(
                            issue: .manifestWithoutRow, blobID: inspection.manifest.blobID,
                            relativeDirectory: inspection.manifest.opaqueRelativeDirectory,
                            cycle: cycle, now: now
                        )
                        try await store.recordAttachmentRecoveryFinding(finding)
                        findings.append(finding)
                        if inspection.manifest.createdAt.addingTimeInterval(
                            RuntimeAttachmentLimits.maximumStagedLifetimeSeconds
                        ) <= now {
                            let authorityAppeared = try await store.hasAttachmentBlobAuthority(
                                blobID: inspection.manifest.blobID,
                                manifestDigest: inspection.manifestDigest,
                                opaqueRelativeDirectory: inspection.manifest.opaqueRelativeDirectory
                            )
                            if authorityAppeared == false {
                                let claim = try await store.claimUnownedAttachmentManifestDeletion(
                                    inspection, recoveryAuthorityID: authorityID, now: now,
                                    expiresAt: now.addingTimeInterval(
                                        RuntimeAttachmentLimits.maximumLeaseSeconds
                                    )
                                )
                                let vaultClaim = try await vault.prepareUnownedManifestDeletion(
                                    inspection, claim: claim, now: clock()
                                )
                                let proof = try await vault.finalizeUnownedManifestDeletion(
                                    vaultClaim, now: clock
                                )
                                try await store.completeUnownedAttachmentManifestDeletion(
                                    claim: claim, proof: proof,
                                    recoveryAuthorityID: authorityID
                                )
                            }
                            if authorityAppeared {
                                _ = try await store.resolveOpenAttachmentRecoveryFindings(
                                    issue: finding.issue, blobID: finding.blobID,
                                    relativeDirectory: finding.opaqueRelativeDirectory, at: now
                                )
                                try await store.resolveAttachmentRecoveryAttempt(
                                    workKind: .manifestDirectory, authorityID: authorityID, at: now
                                )
                            }
                        } else {
                            try await store.recordAttachmentRecoveryAttemptFailure(
                                workKind: .manifestDirectory, authorityID: authorityID,
                                errorFingerprint: finding.evidenceFingerprint
                            )
                        }
                    } else {
                        try await resolveFindingIfPresent(
                            issue: .manifestWithoutRow, blobID: inspection.manifest.blobID,
                            relativeDirectory: inspection.manifest.opaqueRelativeDirectory,
                            now: now
                        )
                        try await store.resolveAttachmentRecoveryAttempt(
                            workKind: .manifestDirectory, authorityID: authorityID, at: now
                        )
                    }
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    let relativeDirectory: String = switch entry {
                    case let .owned(_, url): url.pathComponents.suffix(3).joined(separator: "/")
                    case let .malformed(value): "redacted-\(value.redactedNameDigest)"
                    }
                    findings.append(try await recordFailure(
                        workKind: .manifestDirectory, authorityID: authorityID,
                        issue: .referencedBytesTampered, blobID: nil,
                        relativeDirectory: relativeDirectory, cycle: cycle, now: now, error: error
                    ))
                }
            }
        }
        if page.exhausted {
            _ = try await store.advanceAttachmentRecoveryCursor(
                scanKind: scan, lastKey: nil, wrapped: true, at: now
            )
        } else if let nextCursorKey = page.nextCursorKey {
            _ = try await store.advanceAttachmentRecoveryCursor(
                scanKind: scan, lastKey: nextCursorKey, wrapped: false, at: now
            )
        } else {
            throw RuntimeCanonicalAttachmentError.corruptAuthority
        }
        return findings
    }

    private func reconcileManifestDeletionClaims(
        limit: Int,
        now: Date
    ) async throws -> (count: Int, findings: [RuntimeAttachmentRecoveryFinding]) {
        let scan: RuntimeAttachmentRecoveryScanKind = .manifestDeletionClaims
        let cursor = try await store.attachmentRecoveryCursor(scanKind: scan)
        let cycle = cursor?.cycle ?? 0
        let page = try await store.activeUnownedAttachmentManifestDeletionClaims(
            limit: limit, afterClaimID: cursor?.lastKey, now: now
        )
        var count = 0
        var findings: [RuntimeAttachmentRecoveryFinding] = []
        for work in page {
            try Task.checkCancellation()
            let renewed = try await store.renewUnownedAttachmentManifestDeletionClaim(
                work.claim, now: now,
                expiresAt: now.addingTimeInterval(RuntimeAttachmentLimits.maximumLeaseSeconds)
            )
            guard let vaultClaim = try await vault.resumeUnownedManifestDeletion(
                renewed, now: clock()
            ) else {
                _ = try await store.advanceAttachmentRecoveryCursor(
                    scanKind: scan, lastKey: renewed.claimID, wrapped: false, at: now
                )
                continue
            }
            if try await store.beginAttachmentRecoveryAttempt(
                workKind: .manifestDirectory,
                authorityID: work.recoveryAuthorityID,
                occurrence: "scan:\(scan.rawValue):\(cycle):\(renewed.claimID)",
                now: now
            ) {
                do {
                    let proof = try await vault.finalizeUnownedManifestDeletion(
                        vaultClaim, now: clock
                    )
                    try await store.completeUnownedAttachmentManifestDeletion(
                        claim: renewed, proof: proof,
                        recoveryAuthorityID: work.recoveryAuthorityID
                    )
                    count += 1
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    findings.append(try await recordFailure(
                        workKind: .manifestDirectory,
                        authorityID: work.recoveryAuthorityID,
                        issue: .manifestWithoutRow, blobID: renewed.blobID,
                        relativeDirectory: renewed.opaqueRelativeDirectory,
                        now: now, error: error
                    ))
                }
            }
            _ = try await store.advanceAttachmentRecoveryCursor(
                scanKind: scan, lastKey: renewed.claimID, wrapped: false, at: now
            )
        }
        if page.count < limit {
            _ = try await store.advanceAttachmentRecoveryCursor(
                scanKind: scan, lastKey: nil, wrapped: true, at: now
            )
        }
        return (count, findings)
    }

    private func reconcileAuthorityGraphs(
        limit: Int,
        now: Date
    ) async throws -> [RuntimeAttachmentRecoveryFinding] {
        let scan: RuntimeAttachmentRecoveryScanKind = .authorityGraphs
        let cursor = try await store.attachmentRecoveryCursor(scanKind: scan)
        let cycle = cursor?.cycle ?? 0
        let afterBlobID = try cursor?.lastKey.map { raw in
            guard let blobID = RuntimeBlobID(rawValue: raw) else {
                throw RuntimeCanonicalAttachmentError.corruptAuthority
            }
            return blobID
        }
        let page = try await store.attachmentRecoverySnapshots(
            limit: limit, afterBlobID: afterBlobID
        )
        var findings: [RuntimeAttachmentRecoveryFinding] = []
        for graph in page {
            try Task.checkCancellation()
            let key = graph.manifest.blobID.rawValue
            let authorityID = try recurringAuthorityID(scan: scan, key: key)
            if try await store.beginAttachmentRecoveryAttempt(
                workKind: .authorityGraph, authorityID: authorityID,
                occurrence: "scan:\(scan.rawValue):\(cycle)", now: now
            ) {
                do {
                    if graph.tombstone == nil {
                        let exists = try await vault.ownedBlobExists(graph.manifest)
                        if exists == false {
                            let issue: RuntimeAttachmentRecoveryIssue =
                                graph.lifecycle.state == .deletionPending || graph.lifecycle.state == .orphaned
                                ? .interruptedDeletion : .referencedBytesMissing
                            let finding = try makeFinding(
                                issue: issue, blobID: graph.manifest.blobID,
                                relativeDirectory: graph.manifest.opaqueRelativeDirectory,
                                cycle: cycle, now: now
                            )
                            try await store.recordAttachmentRecoveryFinding(finding)
                            if issue == .referencedBytesMissing {
                                try await store.quarantineAttachmentForRecovery(
                                    revisionID: graph.revision.revisionID,
                                    reason: .ciphertextMissing,
                                    evidenceFingerprint: finding.evidenceFingerprint, at: now
                                )
                            }
                            findings.append(finding)
                        } else {
                            try await resolveFindingIfPresent(
                                issue: .referencedBytesMissing, blobID: graph.manifest.blobID,
                                relativeDirectory: graph.manifest.opaqueRelativeDirectory, now: now
                            )
                            try await resolveFindingIfPresent(
                                issue: .interruptedDeletion, blobID: graph.manifest.blobID,
                                relativeDirectory: graph.manifest.opaqueRelativeDirectory, now: now
                            )
                            if graph.lifecycle.referenceCount > 0 && graph.lifecycle.state != .quarantined {
                                do {
                                    try await vault.verifyAuthenticatedBlob(graph)
                                    try await resolveFindingIfPresent(
                                        issue: .referencedBytesTampered, blobID: graph.manifest.blobID,
                                        relativeDirectory: graph.manifest.opaqueRelativeDirectory, now: now
                                    )
                                } catch is CancellationError {
                                    throw CancellationError()
                                } catch {
                                    let finding = try makeFinding(
                                        issue: .referencedBytesTampered, blobID: graph.manifest.blobID,
                                        relativeDirectory: graph.manifest.opaqueRelativeDirectory,
                                        cycle: cycle, now: now
                                    )
                                    try await store.recordAttachmentRecoveryFinding(finding)
                                    try await store.quarantineAttachmentForRecovery(
                                        revisionID: graph.revision.revisionID,
                                        reason: .authenticationFailed,
                                        evidenceFingerprint: finding.evidenceFingerprint, at: now
                                    )
                                    findings.append(finding)
                                }
                            }
                        }
                    } else {
                        try await resolveFindingIfPresent(
                            issue: .interruptedDeletion, blobID: graph.manifest.blobID,
                            relativeDirectory: graph.manifest.opaqueRelativeDirectory, now: now
                        )
                    }
                    try await store.resolveAttachmentRecoveryAttempt(
                        workKind: .authorityGraph, authorityID: authorityID, at: now
                    )
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    let finding = try await recordFailure(
                        workKind: .authorityGraph, authorityID: authorityID,
                        issue: .referencedBytesTampered, blobID: graph.manifest.blobID,
                        relativeDirectory: graph.manifest.opaqueRelativeDirectory,
                        cycle: cycle, now: now, error: error
                    )
                    if graph.lifecycle.referenceCount > 0,
                       (graph.lifecycle.state == .referenced || graph.lifecycle.state == .finalized),
                       let reason = recoveryQuarantineReason(for: error) {
                        try await store.quarantineAttachmentForRecovery(
                            revisionID: graph.revision.revisionID, reason: reason,
                            evidenceFingerprint: finding.evidenceFingerprint, at: now
                        )
                    }
                    findings.append(finding)
                }
            }
            _ = try await store.advanceAttachmentRecoveryCursor(
                scanKind: scan, lastKey: key, wrapped: false, at: now
            )
        }
        if page.count < limit {
            _ = try await store.advanceAttachmentRecoveryCursor(
                scanKind: scan, lastKey: nil, wrapped: true, at: now
            )
        }
        return findings
    }

    private func recordFailure(
        workKind: RuntimeAttachmentRecoveryWorkKind,
        authorityID: String,
        issue: RuntimeAttachmentRecoveryIssue,
        blobID: RuntimeBlobID?,
        relativeDirectory: String,
        cycle: UInt64 = 0,
        now: Date,
        error: any Error
    ) async throws -> RuntimeAttachmentRecoveryFinding {
        let fingerprint = RuntimeAttachmentFinalizer.errorFingerprint(
            workKind: workKind, authorityID: authorityID, error: error
        )
        try await store.recordAttachmentRecoveryAttemptFailure(
            workKind: workKind, authorityID: authorityID, errorFingerprint: fingerprint
        )
        let evidence = try CanonicalRuntimeAttachmentStore.recoveryFindingEvidenceFingerprint(
            issue: issue, blobID: blobID,
            relativeDirectory: relativeDirectory, cycle: cycle
        )
        let finding = RuntimeAttachmentRecoveryFinding(
            issue: issue, blobID: blobID, opaqueRelativeDirectory: relativeDirectory,
            evidenceFingerprint: evidence, observedAt: now
        )
        try await store.recordAttachmentRecoveryFinding(finding)
        return finding
    }

    private func recurringAuthorityID(
        scan: RuntimeAttachmentRecoveryScanKind,
        key: String
    ) throws -> String {
        try CanonicalRuntimeAttachmentStore.recoveryAttemptAuthorityID(scan: scan, key: key)
    }

    private func resolveFindingIfPresent(
        issue: RuntimeAttachmentRecoveryIssue,
        blobID: RuntimeBlobID?,
        relativeDirectory: String,
        now: Date
    ) async throws {
        _ = try await store.resolveOpenAttachmentRecoveryFindings(
            issue: issue, blobID: blobID,
            relativeDirectory: relativeDirectory, at: now
        )
    }

    private func makeFinding(
        issue: RuntimeAttachmentRecoveryIssue,
        blobID: RuntimeBlobID?,
        relativeDirectory: String,
        cycle: UInt64,
        now: Date
    ) throws -> RuntimeAttachmentRecoveryFinding {
        let evidence = try CanonicalRuntimeAttachmentStore.recoveryFindingEvidenceFingerprint(
            issue: issue, blobID: blobID,
            relativeDirectory: relativeDirectory, cycle: cycle
        )
        return RuntimeAttachmentRecoveryFinding(
            issue: issue, blobID: blobID, opaqueRelativeDirectory: relativeDirectory,
            evidenceFingerprint: evidence, observedAt: now
        )
    }

    private func recoveryQuarantineReason(
        for error: any Error
    ) -> RuntimeAttachmentQuarantineReason? {
        guard let error = error as? RuntimeCanonicalAttachmentError else { return nil }
        return switch error {
        case .pathAuthorityDenied, .symbolicLinkDenied, .fileIdentityChanged:
            .pathAuthorityViolation
        case .protectedDataUnavailable:
            .protectionInsufficient
        case .manifestInvalid, .malformedPayload:
            .manifestMismatch
        case .chunkAuthenticationFailed, .keyEnvelopeInvalid:
            .authenticationFailed
        default:
            nil
        }
    }
}
