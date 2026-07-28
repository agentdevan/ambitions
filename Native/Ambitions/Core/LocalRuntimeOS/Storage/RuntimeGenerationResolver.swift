import AmbitionsRuntimeSQLite
import Darwin
import Foundation

struct ResolvedRuntimeGenerationV8: Sendable {
    let rootAuthority: any RuntimeStoreRootAuthorityProviding
    let selector: RuntimeGenerationActiveSelector
    let selectorFileSHA256: String
    let candidate: RuntimeGenerationCandidateRecord
    let migrationRun: RuntimeGenerationMigrationRun
    let verification: RuntimeGenerationVerificationReport
    let intent: RuntimeGenerationActivationIntent
    let consumption: RuntimeGenerationActivationConsumption
    let liveFence: RuntimeGenerationRevisionFence
    let generationDirectoryURL: URL
    let databaseURL: URL
    let generationDirectoryPin: RuntimeStoreDirectoryPin
    let pinnedFiles: RuntimeStorePinnedFileSet
    let barrierAuthority: RuntimeGenerationBarrierAuthority
    let reconciliation: RuntimeGenerationReconciliationOutcome
}

/// Active resolution can complete while unrelated immutable preparation
/// journals remain. This makes bounded maintenance explicit to the caller
/// instead of implying that every historical preparation was reconciled.
enum RuntimeGenerationReconciliationOutcome: Sendable, Equatable {
    case complete(committedCandidates: [RuntimeGenerationCommittedCandidateReconciliation])
    case pending(
        backupContinuation: RuntimeGenerationPreparationPageCursor?,
        candidateContinuation: RuntimeGenerationPreparationPageCursor?,
        committedCandidates: [RuntimeGenerationCommittedCandidateReconciliation]
    )
}

/// A completed projection-rebuild commitment is terminal candidate authority,
/// not an abandoned staging journal. The resolver reports it separately from
/// work that still needs recovery, without conferring publication authority.
enum RuntimeGenerationCommittedCandidateLocation: String, Sendable, Equatable {
    case staging
    case final
}

struct RuntimeGenerationCommittedCandidateReconciliation: Sendable, Equatable {
    let preparationID: String
    let commitmentID: String
    let candidateGenerationID: RuntimeStoreGenerationID
    let location: RuntimeGenerationCommittedCandidateLocation
    /// The exact pinned directory authenticated during reconciliation. This
    /// is candidate preparation evidence, never selector publication authority.
    let candidateDirectoryURL: URL
}

private struct RuntimeGenerationPreparationReconciliationResult: Sendable {
    let continuation: RuntimeGenerationPreparationPageCursor?
    let hasPendingWork: Bool
    let committedCandidates: [RuntimeGenerationCommittedCandidateReconciliation]
}

struct RuntimeGenerationCommittedCandidateIntegrityMismatch: Sendable {
    let code: RuntimeGenerationCandidatePreparationForensicCode
    let evidence: [String]
}

enum RuntimeGenerationCommittedCandidateValidationOutcome: Sendable {
    case success(RuntimeGenerationCommittedCandidateReconciliation)
    case integrityMismatch(RuntimeGenerationCommittedCandidateIntegrityMismatch)
}

/// Resolves only a completely consumed v8 activation chain. A selector without
/// matching semantic authority, exact file bytes, independent verification,
/// and single-use activation consumption is never opened writable.
struct RuntimeGenerationResolver: Sendable {
    /// Startup reconciliation is intentionally a bounded maintenance slice.
    /// Remaining immutable journals stay pending and are retried by the next
    /// resolver pass; active resolution must never monopolize launch while an
    /// unbounded historical backlog exists.
    private static let maximumPreparationsPerResolution = 64

    let rootAuthority: any RuntimeStoreRootAuthorityProviding
    let locations: RuntimeStoreLocations
    let controlStore: RuntimeGenerationControlStore
    let barrierAuthority: RuntimeGenerationBarrierAuthority
    let environment: RuntimeEnvironment

    func resolveActive() async throws -> ResolvedRuntimeGenerationV8 {
        let coordinatorToken = environment.uuid.nextUUID().uuidString.lowercased()
        try await rootAuthority.activationCoordinator.acquire(token: coordinatorToken)
        let activationLock: RuntimeGenerationActivationLockScope
        do {
            activationLock = try RuntimeGenerationActivationLockScope.acquire(
                rootAuthority: rootAuthority,
                locations: locations,
                mode: .exclusive,
                createIfMissing: false
            )
        } catch {
            try await rootAuthority.activationCoordinator.release(token: coordinatorToken)
            throw RuntimeGenerationControlError.generationWorkerBarrierBusy
        }
        let result: ResolvedRuntimeGenerationV8
        do {
            result = try await resolveActiveWhileActivationLocked(
                activationLock: activationLock
            )
        } catch {
            let operationError = error
            var fileReleased = true
            do { try activationLock.close() } catch { fileReleased = false }
            var coordinatorReleased = true
            do { try await rootAuthority.activationCoordinator.release(token: coordinatorToken) }
            catch { coordinatorReleased = false }
            guard fileReleased, coordinatorReleased else {
                throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
            }
            throw operationError
        }
        var fileReleased = true
        do { try activationLock.close() } catch { fileReleased = false }
        var coordinatorReleased = true
        do { try await rootAuthority.activationCoordinator.release(token: coordinatorToken) }
        catch { coordinatorReleased = false }
        guard fileReleased, coordinatorReleased else {
            throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
        }
        return result
    }

    private func resolveActiveWhileActivationLocked(
        activationLock: RuntimeGenerationActivationLockScope
    ) async throws
        -> ResolvedRuntimeGenerationV8 {
        try activationLock.revalidate(requiredMode: .exclusive)
        try rootAuthority.revalidatePinnedRoot()
        try RuntimeGenerationVaultGraphVerifier.reconcileRestoreDeltaJournals(
            locations: locations
        )
        let backupReconciliation = try await reconcileBackupPreparationsWhileActivationLocked()
        try activationLock.revalidate(requiredMode: .exclusive)
        try rootAuthority.revalidatePinnedRoot()
        guard let selectorData = try RuntimeStoreManifestDescriptorReader.readIfPresent(
            at: locations.activeManifestURL
        ) else { throw LocalRuntimeStorageError.canonicalManifestMissing }
        let selectorSHA = LocalRuntimeStorageChecksum.sha256Hex(for: selectorData)
        let selector = try RuntimeGenerationActiveSelectorCodec.decode(selectorData)
        let candidateReconciliation = try await reconcileInactiveCandidatePreparations(
            activeSelector: selector
        )
        let reconciliation: RuntimeGenerationReconciliationOutcome
        if backupReconciliation.hasPendingWork || candidateReconciliation.hasPendingWork {
            reconciliation = .pending(
                backupContinuation: backupReconciliation.continuation,
                candidateContinuation: candidateReconciliation.continuation,
                committedCandidates: candidateReconciliation.committedCandidates
            )
        } else {
            reconciliation = .complete(
                committedCandidates: candidateReconciliation.committedCandidates
            )
        }
        let candidate = try await controlStore.generationRecord(id: selector.generationID)
        let migrationRun = try await controlStore.migrationRun(
            id: candidate.authorityManifest.migrationRunID
        )
        let verification = try await controlStore.verification(id: selector.verificationID)
        let intent = try await controlStore.activationIntent(id: selector.activationIntentID)
        let existingConsumption = try await controlStore.activationConsumption(
            intentID: selector.activationIntentID
        )
        guard selectorSHA == candidate.selectorFileSHA256,
              selectorSHA == verification.candidateSelectorFileSHA256,
              selectorSHA == intent.candidateSelectorFileSHA256,
              existingConsumption.map({
                selectorSHA == $0.installedSelectorFileSHA256
              }) ?? true,
              selector.authorityManifestDigest == candidate.authorityManifest.manifestDigest,
              selector.authorityManifestFileSHA256 == candidate.authorityManifestFileSHA256,
              verification.candidateAuthorityManifestDigest == selector.authorityManifestDigest,
              verification.candidateAuthorityManifestFileSHA256 == selector.authorityManifestFileSHA256,
              intent.verificationID == verification.verificationID,
              intent.reservationID == verification.reservationID,
              intent.candidateGenerationID == selector.generationID,
              selector.priorGenerationID == candidate.authorityManifest.sourceGenerationID,
              selector.priorAuthorityManifestDigest == candidate.authorityManifest.sourceGenerationDigest,
              intent.expectedSourceGenerationID == selector.priorGenerationID,
              intent.expectedSourceGenerationDigest == selector.priorAuthorityManifestDigest,
              existingConsumption.map({
                $0.priorGenerationID == selector.priorGenerationID &&
                $0.priorGenerationDigest == selector.priorAuthorityManifestDigest
              }) ?? true,
              migrationRun.migrationRunID == candidate.authorityManifest.migrationRunID,
              migrationRun.candidateGenerationID == selector.generationID,
              verification.hasCompleteEvidence else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
        let generationURL = locations.generationDirectoryURL(for: selector.generationID)
        let databaseURL = generationURL.appendingPathComponent("Runtime.sqlite", isDirectory: false)
        let authorityURL = generationURL.appendingPathComponent("Authority.json", isDirectory: false)
        try RuntimeStorePathValidation.requireContained(generationURL, in: locations.storesURL)
        guard selector.relativeDatabasePath == locations.relativeDatabasePath(
            for: selector.generationID
        ) else { throw RuntimeGenerationControlError.activationAuthorityMismatch }
        try RuntimeStoreFileDurability.requireDirectory(
            at: generationURL,
            artifact: "resolved_v8_generation"
        )
        let generationDirectoryPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            generationURL,
            createFinalComponentIfMissing: false
        )
        try generationDirectoryPin.revalidate()
        try RuntimeStoreFileDurability.requireRegularNonSymbolicFile(
            at: authorityURL,
            artifact: "resolved_v8_authority"
        )
        guard let authorityData = try RuntimeStoreManifestDescriptorReader.readIfPresent(
            at: authorityURL
        ) else { throw RuntimeGenerationControlError.activationAuthorityMismatch }
        guard LocalRuntimeStorageChecksum.sha256Hex(for: authorityData) ==
                selector.authorityManifestFileSHA256,
              try RuntimeGenerationControlCodec.decode(
                RuntimeGenerationAuthorityManifest.self,
                from: authorityData
              ) == candidate.authorityManifest else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
        let candidatePreparationAuthority = try await controlStore
            .candidatePreparationAuthority(generationID: selector.generationID)
        let observedDatabaseArtifact = try RuntimeGenerationDatabaseAuthority.artifact(
            at: databaseURL,
            relativePath: "Runtime.sqlite"
        )
        let observedAuthorityArtifact = try RuntimeGenerationArtifact(
            relativePath: "Authority.json",
            sha256: selector.authorityManifestFileSHA256,
            byteCount: Int64(authorityData.count),
            protectionClass: "complete"
        )
        try requireMatchingCandidateCompletion(
            candidatePreparationAuthority.1,
            directory: generationDirectoryPin,
            expectedArtifacts: [
                observedDatabaseArtifact.semantic,
                observedAuthorityArtifact,
            ]
        )
        try await validatePredecessorAuthorityChain(
            startingAt: candidate.authorityManifest
        )
        let database = try await RuntimeGenerationDatabaseAuthority
            .openActiveV8ForLockedRecoveryVerification(
                at: databaseURL,
                activationLock: activationLock
            )
        var databaseClosed = false
        do {
            try await RuntimeGenerationDatabaseAuthority.requireMetadata(
                in: database,
                generationID: selector.generationID,
                createdAtMilliseconds: candidate.authorityManifest.createdAtMilliseconds
            )
            let replay = try await database.transaction(.deferred) { database in
                try RuntimeCanonicalReplayEngine.reconstructInTransaction(database: database)
            }
            guard case .complete = replay else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            let liveFence = try await RuntimeGenerationDatabaseAuthority.revisionFence(
                in: database,
                generationID: selector.generationID,
                generationDigest: candidate.authorityManifest.manifestDigest
            )
            let baseline = candidate.authorityManifest.activationBaseline.revisionFence
            guard liveFence.eventSequence >= baseline.eventSequence,
                  liveFence.commandCount >= baseline.commandCount,
                  liveFence.receiptCount >= baseline.receiptCount,
                  liveFence.externalOperationStatusVersionSum >=
                    baseline.externalOperationStatusVersionSum,
                  liveFence.attachmentLifecycleVersionSum >=
                    baseline.attachmentLifecycleVersionSum else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            if baseline.eventSequence > 0 {
                let anchor = try await database.query(
                    "SELECT event_id, event_hash FROM runtime_semantic_events WHERE sequence = ? LIMIT 2",
                    bindings: [.integer(baseline.eventSequence)],
                    maximumDecodedBytes: RuntimeGenerationDatabaseAuthority.pageByteBudget
                )
                guard anchor.count == 1,
                      anchor[0].value(named: "event_id") == baseline.eventID.map(SQLiteValue.text),
                      anchor[0].value(named: "event_hash") == baseline.eventHash.map(SQLiteValue.text) else {
                    throw RuntimeGenerationControlError.activationAuthorityMismatch
                }
            }
            let pinnedFiles = try RuntimeStorePinnedFileSet.capture(databaseURL: databaseURL)
            try pinnedFiles.validate(databaseURL: databaseURL)
            try generationDirectoryPin.revalidate()
            try rootAuthority.revalidatePinnedRoot()
            try activationLock.revalidate(requiredMode: .exclusive)
            let retention = try await controlStore.currentRetentionClass(
                generationID: selector.generationID
            )
            let consumption: RuntimeGenerationActivationConsumption
            switch (existingConsumption, retention) {
            case let (.some(existing), .active):
                consumption = existing
            case let (existing, .freshConnectionVerified):
                let reconciled = existing ?? (try
                    RuntimeGenerationControlRecordFactory.activationConsumption(
                        intent: intent,
                        consumedAtMilliseconds: try nowMilliseconds(),
                        installedSelectorFileSHA256: selectorSHA,
                        priorGenerationID: selector.priorGenerationID,
                        priorGenerationDigest: selector.priorAuthorityManifestDigest
                    ))
                let transition = try RuntimeGenerationControlRecordFactory
                    .retentionTransition(
                        id: "reconcile-active-\(intent.intentID)",
                        generationID: selector.generationID,
                        fromClass: .freshConnectionVerified,
                        toClass: .active,
                        reasonCode: "postcommit_reconciliation",
                        authorityDigest: reconciled.consumptionDigest,
                        occurredAtMilliseconds: try monotonic(
                            after: verification.verifiedAtMilliseconds,
                            proposed: reconciled.consumedAtMilliseconds
                        )
                    )
                let recoveryConsumption: RuntimeGenerationRecoveryAuthorizationConsumption?
                if migrationRun.operationKind == .restore ||
                    migrationRun.operationKind == .rollback {
                    let plan = try await controlStore.restoreBaselinePlan(
                        targetGenerationID: selector.generationID
                    )
                    let authorization = try await controlStore.recoveryAuthorization(
                        id: plan.recoveryAuthorizationID
                    )
                    recoveryConsumption = try RuntimeGenerationControlRecordFactory
                        .recoveryAuthorizationConsumption(
                            authorization: authorization,
                            resultDigest: plan.planDigest,
                            consumedAtMilliseconds: reconciled.consumedAtMilliseconds
                        )
                } else {
                    recoveryConsumption = nil
                }
                let predecessorTransition: RuntimeGenerationRetentionTransition?
                if let priorGenerationID = selector.priorGenerationID {
                    predecessorTransition = try RuntimeGenerationControlRecordFactory
                        .retentionTransition(
                            id: "demote-active-\(intent.intentID)",
                            generationID: priorGenerationID,
                            fromClass: .active,
                            toClass: .verifiedRollback,
                            reasonCode: "superseded_by_selector",
                            authorityDigest: reconciled.consumptionDigest,
                            occurredAtMilliseconds: reconciled.consumedAtMilliseconds
                        )
                } else {
                    predecessorTransition = nil
                }
                let candidatePreparation = try await controlStore
                    .candidatePreparation(generationID: selector.generationID)
                let reconciliationLease = try await takeOverExpiredOperationLease(
                    reservationID: candidatePreparation.reservationID
                )
                let candidateDisposition = try RuntimeGenerationControlRecordFactory
                    .candidatePreparationDisposition(
                        preparationID: candidatePreparation.preparationID,
                        operationLeaseID: reconciliationLease.leaseID,
                        operationFencingToken: reconciliationLease.fencingToken,
                        kind: .activated,
                        authorityDigest: reconciled.consumptionDigest,
                        disposedAtMilliseconds: max(
                            reconciled.consumedAtMilliseconds,
                            reconciliationLease.issuedAtMilliseconds
                        )
                    )
                try await controlStore.finalizeCommittedActivation(
                    consumption: reconciled,
                    retentionTransition: transition,
                    predecessorRetentionTransition: predecessorTransition,
                    recoveryConsumption: recoveryConsumption,
                    candidateDisposition: candidateDisposition,
                    observedIntent: intent,
                    observedVerification: verification,
                    nowMilliseconds: reconciled.consumedAtMilliseconds
                )
                consumption = reconciled
            default:
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            guard let activeAuthority = try await controlStore.activeAuthority(),
                  activeAuthority.generationID == selector.generationID,
                  activeAuthority.authorityManifestDigest ==
                    selector.authorityManifestDigest,
                  activeAuthority.selectorFileSHA256 == selectorSHA,
                  activeAuthority.activationIntentID == selector.activationIntentID,
                  activeAuthority.activationConsumptionDigest ==
                    consumption.consumptionDigest,
                  activeAuthority.priorGenerationID == selector.priorGenerationID,
                  activeAuthority.priorGenerationDigest ==
                    selector.priorAuthorityManifestDigest else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            try await database.close()
            databaseClosed = true
            try await barrierAuthority.bindResolvedGeneration(selector.generationID)
            return ResolvedRuntimeGenerationV8(
                rootAuthority: rootAuthority,
                selector: selector,
                selectorFileSHA256: selectorSHA,
                candidate: candidate,
                migrationRun: migrationRun,
                verification: verification,
                intent: intent,
                consumption: consumption,
                liveFence: liveFence,
                generationDirectoryURL: generationURL,
                databaseURL: databaseURL,
                generationDirectoryPin: generationDirectoryPin,
                pinnedFiles: pinnedFiles,
                barrierAuthority: barrierAuthority,
                reconciliation: reconciliation
            )
        } catch {
            let operationError = error
            if databaseClosed == false {
                do {
                    try await database.close()
                    databaseClosed = true
                } catch {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "close_failed_resolved_v8_database"
                    )
                }
            }
            throw operationError
        }
    }

    private func nowMilliseconds() throws -> Int64 {
        let value = environment.clock.now.timeIntervalSince1970 * 1_000
        guard value.isFinite, value >= 0, value <= Double(Int64.max) else {
            throw RuntimeGenerationControlError.malformed(field: "resolver_clock")
        }
        return Int64(value.rounded(.towardZero))
    }

    private func takeOverExpiredOperationLease(
        reservationID: String
    ) async throws -> RuntimeGenerationOperationLease {
        guard let prior = try await controlStore.currentOperationLease(
            reservationID: reservationID
        ) else {
            throw RuntimeGenerationControlError.reservationExpired
        }
        let observedAt = try nowMilliseconds()
        guard observedAt >= prior.expiresAtMilliseconds else {
            throw RuntimeGenerationControlError.activationReconciliationPending
        }
        guard observedAt >= prior.expiresAtMilliseconds,
              prior.leaseEpoch < Int64.max,
              prior.fencingToken < Int64.max,
              observedAt <= Int64.max -
                runtimeGenerationMaximumOperationLeaseMilliseconds else {
            throw RuntimeGenerationControlError.reservationExpired
        }
        let takeover = try RuntimeGenerationControlRecordFactory.operationLease(
            id: environment.uuid.nextUUID().uuidString.lowercased(),
            reservationID: reservationID,
            ownerInstanceID: environment.uuid.nextUUID().uuidString.lowercased(),
            leaseEpoch: prior.leaseEpoch + 1,
            fencingToken: prior.fencingToken + 1,
            priorLeaseDigest: prior.leaseDigest,
            issuedAtMilliseconds: observedAt,
            expiresAtMilliseconds:
                observedAt + runtimeGenerationMaximumOperationLeaseMilliseconds
        )
        try await controlStore.recordOperationLease(takeover)
        return takeover
    }

    private func reconcileBackupPreparationsWhileActivationLocked() async throws
        -> RuntimeGenerationPreparationReconciliationResult {
        let page = try await controlStore.unconsumedBackupPreparationsPage(
            after: nil,
            limit: Self.maximumPreparationsPerResolution
        )
        var hasPendingWork = page.nextCursor != nil
        for pending in page.entries {
            let preparation = pending.preparation
            let completion = pending.completion
            try Task.checkCancellation()
            if let currentLease = try await controlStore.currentOperationLease(
                reservationID: preparation.reservationID
            ), try nowMilliseconds() < currentLease.expiresAtMilliseconds {
                hasPendingWork = true
                continue
            }
            // Claim the expired operation before authenticating or mutating its
            // prepared bytes. Otherwise a second resolver could take ownership
            // after this resolver's evidence scan but before publication.
            let lease = try await takeOverExpiredOperationLease(
                reservationID: preparation.reservationID
            )
            let backups = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
                locations.backupsURL,
                createFinalComponentIfMissing: false
            )
            try backups.revalidate()
            let hiddenEntry = try preparationEntryIfPresent(
                parent: backups,
                name: preparation.hiddenDirectoryName,
                role: .backupHidden,
                location: .source
            )
            let finalEntry = try preparationEntryIfPresent(
                parent: backups,
                name: preparation.finalDirectoryName,
                role: .backupFinal,
                location: .source
            )
            let hidden = try preparationDirectoryPinIfPresent(
                parent: backups,
                name: preparation.hiddenDirectoryName
            )
            let final = try preparationDirectoryPinIfPresent(
                parent: backups,
                name: preparation.finalDirectoryName
            )
            if let completion, hidden != nil, final == nil {
                do {
                    let hidden = try requireMatchingBackupCompletion(
                        completion, directory: hidden!
                    )
                    try publishPreparedDirectoryForRecovery(
                        preparation: preparation,
                        expectedIdentity: hidden.identity,
                        parent: backups
                    )
                    _ = try await controlStore.consumeCompletedBackupPreparation(
                        preparationID: preparation.preparationID,
                        currentLease: lease,
                        finalDirectoryDevice: hidden.identity.device,
                        finalDirectoryInode: hidden.identity.inode,
                        consumedAtMilliseconds: max(
                            completion.completedAtMilliseconds,
                            lease.issuedAtMilliseconds
                        )
                    )
                    continue
                } catch RuntimeGenerationControlError.restoreSourceUnverified {
                    // Preserve and classify below under a fenced takeover.
                }
            }
            if let completion, hidden == nil, let final {
                do {
                    let final = try requireMatchingBackupCompletion(
                        completion, directory: final
                    )
                    _ = try await controlStore.consumeCompletedBackupPreparation(
                        preparationID: preparation.preparationID,
                        currentLease: lease,
                        finalDirectoryDevice: final.identity.device,
                        finalDirectoryInode: final.identity.inode,
                        consumedAtMilliseconds: max(
                            completion.completedAtMilliseconds,
                            lease.issuedAtMilliseconds
                        )
                    )
                    continue
                } catch RuntimeGenerationControlError.restoreSourceUnverified {
                    // Preserve and classify below under a fenced takeover.
                }
            }
            let classification: RuntimeGenerationBackupPreparationRecoveryClassification
            if completion == nil, hidden == nil, final == nil {
                classification = .preparedMissing
            } else if completion == nil {
                classification = .quarantinedIncomplete
            } else if hidden != nil, final != nil {
                classification = .quarantinedConflict
            } else if hiddenEntry != nil || finalEntry != nil,
                      hidden == nil && final == nil {
                classification = .quarantinedCorrupt
            } else {
                classification = .quarantinedCorrupt
            }
            let preserved = try quarantinePreparationDirectories(
                preparation: preparation,
                hiddenEntry: hiddenEntry,
                finalEntry: finalEntry,
                backups: backups
            )
            let recoveredAt = max(try nowMilliseconds(), lease.issuedAtMilliseconds)
            let recovery = try RuntimeGenerationControlRecordFactory
                .backupPreparationRecovery(
                    preparationID: preparation.preparationID,
                    operationLease: lease,
                    classification: classification,
                    preservedEntries: preserved,
                    recoveredAtMilliseconds: recoveredAt
                )
            try await controlStore.recordBackupPreparationRecovery(
                recovery,
                currentLease: lease
            )
        }
        return RuntimeGenerationPreparationReconciliationResult(
            continuation: page.nextCursor,
            hasPendingWork: hasPendingWork,
            committedCandidates: []
        )
    }

    private func preparationDirectoryPinIfPresent(
        parent: RuntimeStoreDirectoryPin,
        name: String
    ) throws -> RuntimeStoreDirectoryPin? {
        var status = stat()
        if fstatat(parent.descriptor, name, &status, AT_SYMLINK_NOFOLLOW) != 0 {
            guard errno == ENOENT else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            return nil
        }
        guard status.st_mode & S_IFMT == S_IFDIR else { return nil }
        let descriptor = Darwin.openat(
            parent.descriptor,
            name,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW
        )
        guard descriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        let pin = RuntimeStoreDirectoryPin(
            descriptor: descriptor,
            identity: RuntimeStoreFileIdentity(
                device: UInt64(status.st_dev), inode: UInt64(status.st_ino)
            ),
            pathURL: parent.pathURL.appendingPathComponent(name, isDirectory: true)
        )
        try pin.revalidate()
        return pin
    }

    private func preparationEntryIfPresent(
        parent: RuntimeStoreDirectoryPin,
        name: String,
        role: RuntimeGenerationPreservedPreparationRole,
        location: RuntimeGenerationPreservedPreparationLocation
    ) throws -> RuntimeGenerationPreservedPreparationEntry? {
        var status = stat()
        if fstatat(parent.descriptor, name, &status, AT_SYMLINK_NOFOLLOW) != 0 {
            guard errno == ENOENT else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            return nil
        }
        let kind: RuntimeGenerationPreservedPreparationFileKind
        switch status.st_mode & S_IFMT {
        case S_IFDIR: kind = .directory
        case S_IFREG: kind = .regular
        case S_IFLNK: kind = .symbolicLink
        default: kind = .other
        }
        return RuntimeGenerationPreservedPreparationEntry(
            role: role,
            location: location,
            basename: name,
            fileKind: kind,
            identity: RuntimeStoreFileIdentity(
                device: UInt64(status.st_dev), inode: UInt64(status.st_ino)
            )
        )
    }

    private func requireMatchingBackupCompletion(
        _ completion: RuntimeGenerationBackupPreparationCompletion,
        directory: RuntimeStoreDirectoryPin
    ) throws -> RuntimeStoreDirectoryPin {
        guard directory.identity.device == completion.directoryDevice,
              directory.identity.inode == completion.directoryInode else {
            throw RuntimeGenerationControlError.restoreSourceUnverified
        }
        let expected = ([completion.backup.databaseArtifact] +
            completion.backup.vaultArtifacts.flatMap { artifact in
                [
                    artifact.backupPayloadArtifact,
                    artifact.backupManifestArtifact,
                    artifact.backupFinalizationArtifact,
                ].compactMap { $0 }
            }).sorted { $0.relativePath < $1.relativePath }
        let observed = try RuntimeGenerationLifecycleService
            .descriptorRelativeArtifactInventory(
                root: directory,
                maximumTotalBytes: 8 * 1_024 * 1_024 * 1_024
            )
        var byteCount: Int64 = 0
        for artifact in observed {
            guard artifact.byteCount <= Int64.max - byteCount else {
                throw RuntimeGenerationControlError.resourcePolicyExceeded(
                    resource: "backup_reconciliation_bytes",
                    maximum: 8 * 1_024 * 1_024 * 1_024
                )
            }
            byteCount += artifact.byteCount
        }
        let inventoryDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: observed.map {
                "\($0.relativePath)\n\($0.sha256)\n\($0.byteCount)\n\($0.protectionClass)"
            }.joined(separator: "\n--\n")
        )
        let durabilityDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: "backup-directory-durability-v1\n\(directory.identity.device)\n\(directory.identity.inode)\n\(inventoryDigest)\n\(observed.count)\n\(byteCount)"
        )
        guard observed == expected,
              Int64(observed.count) == completion.interiorArtifactCount,
              byteCount == completion.interiorByteCount,
              inventoryDigest == completion.interiorInventoryDigest,
              durabilityDigest == completion.durabilityWitnessDigest else {
            throw RuntimeGenerationControlError.restoreSourceUnverified
        }
        return directory
    }

    private func requireMatchingCandidateCompletion(
        _ completion: RuntimeGenerationCandidatePreparationCompletion,
        directory: RuntimeStoreDirectoryPin,
        expectedArtifacts: [RuntimeGenerationArtifact]
    ) throws {
        guard completion.directoryDevice == directory.identity.device,
              completion.directoryInode == directory.identity.inode else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
        let expected = expectedArtifacts.sorted { $0.relativePath < $1.relativePath }
        let observed = try RuntimeGenerationLifecycleService
            .descriptorRelativeArtifactInventory(
                root: directory,
                maximumTotalBytes: 8 * 1_024 * 1_024 * 1_024
            )
        var byteCount: Int64 = 0
        for artifact in observed {
            guard artifact.byteCount <= Int64.max - byteCount else {
                throw RuntimeGenerationControlError.resourcePolicyExceeded(
                    resource: "candidate_reconciliation_bytes",
                    maximum: 8 * 1_024 * 1_024 * 1_024
                )
            }
            byteCount += artifact.byteCount
        }
        let inventoryDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: observed.map {
                "\($0.relativePath)\n\($0.sha256)\n\($0.byteCount)\n\($0.protectionClass)"
            }.joined(separator: "\n--\n")
        )
        let durabilityDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: "candidate-directory-durability-v1\n\(directory.identity.device)\n\(directory.identity.inode)\n\(inventoryDigest)\n\(observed.count)\n\(byteCount)"
        )
        guard observed == expected,
              Int64(observed.count) == completion.interiorArtifactCount,
              byteCount == completion.interiorByteCount,
              inventoryDigest == completion.interiorInventoryDigest,
              durabilityDigest == completion.durabilityWitnessDigest else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
    }

    private func publishPreparedDirectoryForRecovery(
        preparation: RuntimeGenerationBackupPreparationRecord,
        expectedIdentity: RuntimeStoreFileIdentity,
        parent: RuntimeStoreDirectoryPin
    ) throws {
        try parent.revalidate()
        var hiddenStatus = stat()
        guard fstatat(
            parent.descriptor,
            preparation.hiddenDirectoryName,
            &hiddenStatus,
            AT_SYMLINK_NOFOLLOW
        ) == 0,
        hiddenStatus.st_mode & S_IFMT == S_IFDIR,
        RuntimeStoreFileIdentity(
            device: UInt64(hiddenStatus.st_dev),
            inode: UInt64(hiddenStatus.st_ino)
        ) == expectedIdentity else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        guard Darwin.renameatx_np(
            parent.descriptor,
            preparation.hiddenDirectoryName,
            parent.descriptor,
            preparation.finalDirectoryName,
            UInt32(RENAME_EXCL)
        ) == 0,
        Darwin.fsync(parent.descriptor) == 0 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        guard let final = try preparationDirectoryPinIfPresent(
            parent: parent, name: preparation.finalDirectoryName
        ), final.identity == expectedIdentity else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
    }

    private func quarantinePreparationDirectories(
        preparation: RuntimeGenerationBackupPreparationRecord,
        hiddenEntry: RuntimeGenerationPreservedPreparationEntry?,
        finalEntry: RuntimeGenerationPreservedPreparationEntry?,
        backups: RuntimeStoreDirectoryPin
    ) throws -> [RuntimeGenerationPreservedPreparationEntry] {
        let quarantine = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            locations.quarantineURL,
            createFinalComponentIfMissing: true
        )
        try RuntimeStoreFileDurability.applyCompleteProtection(
            toOpenFileDescriptor: quarantine.descriptor,
            artifact: "generation_preparation_quarantine"
        )
        var preserved: [RuntimeGenerationPreservedPreparationEntry] = []
        for (sourceEntry, suffix) in [
            (hiddenEntry, "hidden"),
            (finalEntry, "final"),
        ] {
            let destination = "backup-recovery-\(preparation.preparationID)-\(suffix)"
            let role: RuntimeGenerationPreservedPreparationRole =
                suffix == "hidden" ? .backupHidden : .backupFinal
            let existingDestination = try preparationEntryIfPresent(
                parent: quarantine,
                name: destination,
                role: role,
                location: .quarantine
            )
            if let existingDestination {
                preserved.append(existingDestination)
                // If both source and deterministic destination exist, preserve
                // both and fail closed; RENAME_EXCL must never overwrite either.
                if let sourceEntry { preserved.append(sourceEntry) }
                continue
            }
            guard let sourceEntry else { continue }
            var sourceStatus = stat()
            guard fstatat(
                backups.descriptor,
                sourceEntry.basename,
                &sourceStatus,
                AT_SYMLINK_NOFOLLOW
            ) == 0,
            RuntimeStoreFileIdentity(
                device: UInt64(sourceStatus.st_dev),
                inode: UInt64(sourceStatus.st_ino)
            ) == sourceEntry.identity else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            guard Darwin.renameatx_np(
                backups.descriptor,
                sourceEntry.basename,
                quarantine.descriptor,
                destination,
                UInt32(RENAME_EXCL)
            ) == 0 else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            guard let moved = try preparationEntryIfPresent(
                parent: quarantine,
                name: destination,
                role: role,
                location: .quarantine
            ), moved.identity == sourceEntry.identity else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            preserved.append(moved)
        }
        guard Darwin.fsync(backups.descriptor) == 0,
              Darwin.fsync(quarantine.descriptor) == 0 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        try backups.revalidate()
        try quarantine.revalidate()
        return preserved.sorted {
            ($0.role.rawValue, $0.location.rawValue, $0.basename) <
                ($1.role.rawValue, $1.location.rawValue, $1.basename)
        }
    }

    private func reconcileInactiveCandidatePreparations(
        activeSelector: RuntimeGenerationActiveSelector
    ) async throws -> RuntimeGenerationPreparationReconciliationResult {
        let page = try await controlStore.unresolvedCandidatePreparationsPage(
            after: nil,
            limit: Self.maximumPreparationsPerResolution
        )
        var hasPendingWork = page.nextCursor != nil
        var committedCandidates: [RuntimeGenerationCommittedCandidateReconciliation] = []
        for pending in page.entries {
            let preparation = pending.preparation
            var commitmentMismatch: RuntimeGenerationCommittedCandidateIntegrityMismatch?
            if let commitment = pending.committedAuthority {
                let commitmentValidation: RuntimeGenerationCommittedCandidateValidationOutcome
                do {
                    commitmentValidation = try await validateCommittedCandidatePreparation(
                        preparation: preparation,
                        completion: pending.completion,
                        commitment: commitment
                    )
                } catch is CancellationError {
                    throw CancellationError()
                } catch let error as LocalRuntimeStorageError where
                    isRetryableCommittedCandidateRead(error) {
                    hasPendingWork = true
                    continue
                } catch let error as RuntimeGenerationControlError where
                    isRetryableCommittedCandidateControlRead(error) {
                    hasPendingWork = true
                    continue
                }
                switch commitmentValidation {
                case let .success(committed):
                    committedCandidates.append(committed)
                    continue
                case let .integrityMismatch(mismatch):
                    // A commitment has made this candidate a durable forensic
                    // subject. Only a concrete integrity mismatch can enter
                    // quarantine; retryable read/control failures propagate.
                    commitmentMismatch = mismatch
                }
            }
            guard commitmentMismatch != nil ||
                preparation.candidateGenerationID != activeSelector.generationID else {
                hasPendingWork = true
                continue
            }
            if let currentLease = try await controlStore.currentOperationLease(
                reservationID: preparation.reservationID
            ), try nowMilliseconds() < currentLease.expiresAtMilliseconds {
                guard commitmentMismatch == nil else {
                    // A resolver must not take or move an actively owned
                    // candidate. Refusing active resolution is deliberate:
                    // it makes the mismatch visible until a fenced owner (or
                    // a post-expiry reconciler) can produce its disposition.
                    throw RuntimeGenerationControlError.activationReconciliationPending
                }
                hasPendingWork = true
                continue
            }
            let lease = try await takeOverExpiredOperationLease(
                reservationID: preparation.reservationID
            )
            let stores = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
                locations.storesURL,
                createFinalComponentIfMissing: false
            )
            let staging = try preparationDirectoryPinIfPresent(
                parent: stores, name: preparation.stagingDirectoryName
            )
            let finalName = preparation.candidateGenerationID.pathComponent
            let final = try preparationDirectoryPinIfPresent(
                parent: stores, name: finalName
            )
            let stagingEntry = try preparationEntryIfPresent(
                parent: stores,
                name: preparation.stagingDirectoryName,
                role: .candidateStaging,
                location: .source
            )
            let finalEntry = try preparationEntryIfPresent(
                parent: stores,
                name: finalName,
                role: .candidateFinal,
                location: .source
            )
            let quarantine = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
                locations.quarantineURL,
                createFinalComponentIfMissing: true
            )
            try RuntimeStoreFileDurability.applyCompleteProtection(
                toOpenFileDescriptor: quarantine.descriptor,
                artifact: "candidate_preparation_quarantine"
            )
            var evidence: [String] = []
            var preservedEntries: [RuntimeGenerationPreservedPreparationEntry] = []
            for (sourceEntry, suffix) in [
                (stagingEntry, "staging"),
                (finalEntry, "final"),
            ] {
                let destination =
                    "candidate-recovery-\(preparation.preparationID)-\(suffix)"
                let role: RuntimeGenerationPreservedPreparationRole =
                    suffix == "staging" ? .candidateStaging : .candidateFinal
                if let existingDestination = try preparationEntryIfPresent(
                    parent: quarantine,
                    name: destination,
                    role: role,
                    location: .quarantine
                ) {
                    let observedIdentity = existingDestination.identity
                    evidence.append(
                        "\(destination):\(observedIdentity.device):\(observedIdentity.inode)"
                    )
                    preservedEntries.append(existingDestination)
                    if let sourceEntry { preservedEntries.append(sourceEntry) }
                    continue
                }
                guard let sourceEntry else { continue }
                var sourceStatus = stat()
                guard fstatat(
                    stores.descriptor,
                    sourceEntry.basename,
                    &sourceStatus,
                    AT_SYMLINK_NOFOLLOW
                ) == 0,
                RuntimeStoreFileIdentity(
                    device: UInt64(sourceStatus.st_dev),
                    inode: UInt64(sourceStatus.st_ino)
                ) == sourceEntry.identity else {
                    throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                }
                guard Darwin.renameatx_np(
                    stores.descriptor,
                    sourceEntry.basename,
                    quarantine.descriptor,
                    destination,
                    UInt32(RENAME_EXCL)
                ) == 0 else {
                    throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                }
                evidence.append(
                    "\(destination):\(sourceEntry.identity.device):\(sourceEntry.identity.inode)"
                )
                guard let moved = try preparationEntryIfPresent(
                    parent: quarantine,
                    name: destination,
                    role: role,
                    location: .quarantine
                ), moved.identity == sourceEntry.identity else {
                    throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                }
                preservedEntries.append(moved)
            }
            guard Darwin.fsync(stores.descriptor) == 0,
                  Darwin.fsync(quarantine.descriptor) == 0 else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            try stores.revalidate()
            try quarantine.revalidate()
            let recoveredAt = max(try nowMilliseconds(), lease.issuedAtMilliseconds)
            let authorityDigest = LocalRuntimeStorageChecksum.sha256Hex(
                for: ([
                    "candidate-preserved-failure-v3",
                    preparation.preparationDigest,
                    activeSelector.authorityManifestDigest,
                    commitmentMismatch.map { "forensic_code:\($0.code.rawValue)" } ??
                        "no-forensic-code",
                ] + (commitmentMismatch?.evidence ?? ["no-commitment"])
                    + evidence.sorted()).joined(separator: "\n")
            )
            let classification: RuntimeGenerationCandidatePreparationFailureClassification
            if commitmentMismatch != nil ||
                (stagingEntry != nil && staging == nil) ||
                (finalEntry != nil && final == nil) {
                classification = .corrupt
            } else {
                let hasStaging = preservedEntries.contains { $0.role == .candidateStaging }
                let hasFinal = preservedEntries.contains { $0.role == .candidateFinal }
                switch (hasStaging, hasFinal) {
                case (false, false): classification = .preparedMissing
                case (true, true): classification = .conflict
                default: classification = .incomplete
                }
            }
            let disposition = try RuntimeGenerationControlRecordFactory
                .candidatePreparationDisposition(
                    preparationID: preparation.preparationID,
                    operationLeaseID: lease.leaseID,
                    operationFencingToken: lease.fencingToken,
                    kind: .preservedFailure,
                    failureClassification: classification,
                    forensicCode: commitmentMismatch?.code,
                    preservedEntries: preservedEntries,
                    authorityDigest: authorityDigest,
                    disposedAtMilliseconds: recoveredAt
                )
            try await controlStore.recordCandidatePreparationDisposition(
                disposition,
                currentLease: lease
            )
        }
        return RuntimeGenerationPreparationReconciliationResult(
            continuation: page.nextCursor,
            hasPendingWork: hasPendingWork,
            committedCandidates: committedCandidates.sorted {
                ($0.candidateGenerationID.rawValue, $0.preparationID, $0.commitmentID) <
                    ($1.candidateGenerationID.rawValue, $1.preparationID, $1.commitmentID)
            }
        )
    }

    /// Authenticates the exact authority that a v10 projection-rebuild
    /// commitment froze while the candidate was still unpublished. This path
    /// intentionally has no publication, activation, receipt, or recovery
    /// consumption side effect. A failed check is handled by the caller as a
    /// forensic quarantine/disposition rather than being treated as an
    /// unresolved-but-safe staging directory.
    /// Shared exact-byte validation for a committed, unpublished projection
    /// candidate. It has no mutation side effects; the continuation owns any
    /// subsequent verification, intent, activation, or recovery receipt.
    func validateCommittedCandidatePreparation(
        preparation: RuntimeGenerationCandidatePreparationRecord,
        completion: RuntimeGenerationCandidatePreparationCompletion?,
        commitment: RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment
    ) async throws -> RuntimeGenerationCommittedCandidateValidationOutcome {
        let baseEvidence = committedCandidateForensicEvidence(
            preparation: preparation,
            commitment: commitment
        )
        do {
            try RuntimeGenerationControlRecordFactory.validate(commitment)
        } catch {
            return .integrityMismatch(
                RuntimeGenerationCommittedCandidateIntegrityMismatch(
                    code: .commitmentInvariant,
                    evidence: baseEvidence + ["mismatch:commitment_invariant"]
                )
            )
        }
        guard preparation.operationKind == .projectionRebuild,
              preparation.preparationID == commitment.candidatePreparationID,
              preparation.reservationID == commitment.reservationID,
              preparation.candidateGenerationID == commitment.candidateGenerationID,
              preparation.recoveryExecutionPlanID == commitment.recoveryExecutionPlanID,
              preparation.recoveryExecutionClaimID == commitment.recoveryExecutionClaimID,
              preparation.recoveryExecutionClaimEpoch == commitment.recoveryExecutionClaimEpoch,
              completion == commitment.candidatePreparationCompletion else {
            return .integrityMismatch(
                RuntimeGenerationCommittedCandidateIntegrityMismatch(
                    code: .preparationLineage,
                    evidence: baseEvidence + ["mismatch:preparation_lineage"]
                )
            )
        }

        let durableCandidate = try await controlStore.generationRecord(
            id: commitment.candidateGenerationID
        )
        let durableRun = try await controlStore.migrationRun(
            id: commitment.migrationRunID
        )
        let durablePreparationAuthority = try await controlStore
            .candidatePreparationAuthority(generationID: commitment.candidateGenerationID)
        guard durableCandidate == commitment.candidateRecord,
              durablePreparationAuthority.0 == preparation,
              durablePreparationAuthority.1 == commitment.candidatePreparationCompletion,
              durableCandidate.authorityManifest.generationID ==
                commitment.candidateGenerationID,
              durableCandidate.authorityManifest.reservationID ==
                commitment.reservationID,
              durableCandidate.authorityManifest.migrationRunID ==
                commitment.migrationRunID,
              durableCandidate.authorityManifest.operationKind == .projectionRebuild,
              durableRun.migrationRunID == commitment.migrationRunID,
              durableRun.reservationID == commitment.reservationID,
              durableRun.candidateGenerationID == commitment.candidateGenerationID,
              durableRun.operationKind == .projectionRebuild,
              durableRun.recoveryExecutionPlanID == commitment.recoveryExecutionPlanID,
              durableRun.recoveryExecutionClaimID == commitment.recoveryExecutionClaimID,
              durableRun.recoveryExecutionClaimEpoch ==
                commitment.recoveryExecutionClaimEpoch,
              commitment.rebuild.candidateGenerationID == commitment.candidateGenerationID,
              commitment.rebuild.recoveryExecutionPlanID ==
                commitment.recoveryExecutionPlanID,
              commitment.rebuild.recoveryExecutionClaimID ==
                commitment.recoveryExecutionClaimID,
              commitment.rebuild.recoveryExecutionClaimEpoch ==
                commitment.recoveryExecutionClaimEpoch else {
            return .integrityMismatch(
                RuntimeGenerationCommittedCandidateIntegrityMismatch(
                    code: .durableControlLineage,
                    evidence: baseEvidence + ["mismatch:durable_control_lineage"]
                )
            )
        }

        let committedSelector: RuntimeGenerationActiveSelector
        do {
            committedSelector = try RuntimeGenerationActiveSelectorCodec.decode(
                commitment.selectorBytes
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as LocalRuntimeStorageError {
            throw error
        } catch {
            return .integrityMismatch(
                RuntimeGenerationCommittedCandidateIntegrityMismatch(
                    code: .selectorCommitment,
                    evidence: baseEvidence + ["mismatch:selector_decode"]
                )
            )
        }
        guard LocalRuntimeStorageChecksum.sha256Hex(for: commitment.selectorBytes) ==
                commitment.selectorBytesSHA256,
              committedSelector.generationID == commitment.candidateGenerationID,
              committedSelector.relativeDatabasePath == locations.relativeDatabasePath(
                for: commitment.candidateGenerationID
              ),
              committedSelector.authorityManifestDigest ==
                durableCandidate.authorityManifest.manifestDigest,
              committedSelector.authorityManifestFileSHA256 ==
                durableCandidate.authorityManifestFileSHA256,
              committedSelector.verificationID == commitment.expectedVerificationID,
              committedSelector.activationIntentID == commitment.expectedActivationIntentID,
              committedSelector.preparedAtMilliseconds ==
                durableRun.completedAtMilliseconds,
              committedSelector.priorGenerationID ==
                durableCandidate.authorityManifest.sourceGenerationID,
              committedSelector.priorAuthorityManifestDigest ==
                durableCandidate.authorityManifest.sourceGenerationDigest else {
            return .integrityMismatch(
                RuntimeGenerationCommittedCandidateIntegrityMismatch(
                    code: .selectorCommitment,
                    evidence: baseEvidence + ["mismatch:selector_commitment"]
                )
            )
        }

        let stores = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            locations.storesURL,
            createFinalComponentIfMissing: false
        )
        let staging = try preparationDirectoryPinIfPresent(
            parent: stores,
            name: preparation.stagingDirectoryName
        )
        let final = try preparationDirectoryPinIfPresent(
            parent: stores,
            name: preparation.candidateGenerationID.pathComponent
        )
        guard (staging != nil) != (final != nil) else {
            return .integrityMismatch(
                RuntimeGenerationCommittedCandidateIntegrityMismatch(
                    code: .candidateLocation,
                    evidence: baseEvidence + ["mismatch:candidate_location"]
                )
            )
        }
        let location: RuntimeGenerationCommittedCandidateLocation
        let directory: RuntimeStoreDirectoryPin
        if let staging {
            location = .staging
            directory = staging
        } else if let final {
            location = .final
            directory = final
        } else {
            return .integrityMismatch(
                RuntimeGenerationCommittedCandidateIntegrityMismatch(
                    code: .candidateLocation,
                    evidence: baseEvidence + ["mismatch:candidate_location"]
                )
            )
        }
        try stores.revalidate()
        try directory.revalidate()

        let authorityURL = directory.pathURL.appendingPathComponent(
            "Authority.json", isDirectory: false
        )
        let databaseURL = directory.pathURL.appendingPathComponent(
            "Runtime.sqlite", isDirectory: false
        )
        try RuntimeStoreFileDurability.requireRegularNonSymbolicFile(
            at: authorityURL,
            artifact: "committed_candidate_authority"
        )
        guard let authorityBytes = try RuntimeStoreManifestDescriptorReader.readIfPresent(
            at: authorityURL
        ) else {
            return .integrityMismatch(
                RuntimeGenerationCommittedCandidateIntegrityMismatch(
                    code: .authorityManifest,
                    evidence: baseEvidence + ["mismatch:authority_manifest_missing"]
                )
            )
        }
        let decodedAuthority: RuntimeGenerationAuthorityManifest
        do {
            decodedAuthority = try RuntimeGenerationControlCodec.decode(
                RuntimeGenerationAuthorityManifest.self,
                from: authorityBytes
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as LocalRuntimeStorageError {
            throw error
        } catch {
            return .integrityMismatch(
                RuntimeGenerationCommittedCandidateIntegrityMismatch(
                    code: .authorityManifest,
                    evidence: baseEvidence + ["mismatch:authority_manifest_decode"]
                )
            )
        }
        guard authorityBytes == commitment.authorityManifestBytes,
           LocalRuntimeStorageChecksum.sha256Hex(for: authorityBytes) ==
                commitment.authorityManifestBytesSHA256,
           LocalRuntimeStorageChecksum.sha256Hex(for: authorityBytes) ==
                durableCandidate.authorityManifestFileSHA256,
           decodedAuthority == durableCandidate.authorityManifest else {
            return .integrityMismatch(
                RuntimeGenerationCommittedCandidateIntegrityMismatch(
                    code: .authorityManifest,
                    evidence: baseEvidence + ["mismatch:authority_manifest"]
                )
            )
        }
        let databaseArtifact = try RuntimeGenerationDatabaseAuthority.artifact(
            at: databaseURL,
            relativePath: "Runtime.sqlite"
        )
        guard databaseArtifact.semanticallyMatches(
            durableCandidate.authorityManifest.database
        ) else {
            return .integrityMismatch(
                RuntimeGenerationCommittedCandidateIntegrityMismatch(
                    code: .databaseArtifact,
                    evidence: baseEvidence + ["mismatch:database_artifact"]
                )
            )
        }
        let authorityArtifact = try RuntimeGenerationArtifact(
            relativePath: "Authority.json",
            sha256: commitment.authorityManifestBytesSHA256,
            byteCount: Int64(authorityBytes.count),
            protectionClass: "complete"
        )
        do {
            try requireMatchingCandidateCompletion(
                commitment.candidatePreparationCompletion,
                directory: directory,
                expectedArtifacts: [databaseArtifact.semantic, authorityArtifact]
            )
        } catch RuntimeGenerationControlError.activationAuthorityMismatch {
            return .integrityMismatch(
                RuntimeGenerationCommittedCandidateIntegrityMismatch(
                    code: .completionWitness,
                    evidence: baseEvidence + ["mismatch:completion_witness"]
                )
            )
        }
        try directory.revalidate()
        try stores.revalidate()

        return .success(
            RuntimeGenerationCommittedCandidateReconciliation(
                preparationID: preparation.preparationID,
                commitmentID: commitment.commitmentID,
                candidateGenerationID: commitment.candidateGenerationID,
                location: location,
                candidateDirectoryURL: directory.pathURL
            )
        )
    }

    /// Privacy-minimized evidence included in any forensic disposition for a
    /// committed candidate. It deliberately binds all durable authority
    /// digests that identify the candidate without recording user data or raw
    /// selector/manifest bytes.
    private func committedCandidateForensicEvidence(
        preparation: RuntimeGenerationCandidatePreparationRecord,
        commitment: RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment
    ) -> [String] {
        [
            "commitment_id:\(commitment.commitmentID)",
            "commitment_digest:\(commitment.commitmentDigest)",
            "preparation_id:\(preparation.preparationID)",
            "preparation_digest:\(preparation.preparationDigest)",
            "candidate_generation:\(commitment.candidateGenerationID.rawValue)",
            "candidate_record_digest:\(commitment.candidateRecord.recordDigest)",
            "candidate_manifest_digest:\(commitment.candidateRecord.authorityManifest.manifestDigest)",
            "candidate_authority_sha:\(commitment.candidateRecord.authorityManifestFileSHA256)",
            "candidate_selector_sha:\(commitment.candidateRecord.selectorFileSHA256)",
            "completion_digest:\(commitment.candidatePreparationCompletion.completionDigest)",
            "rebuild_digest:\(commitment.rebuild.rebuildDigest)",
            "replay_audit_digest:\(commitment.replayAuditDigest)",
            "replay_reconstruction_digest:\(commitment.replayReconstructionDigest)",
        ].sorted()
    }

    /// Retryable operational faults are not evidence of a corrupt committed
    /// candidate. They remain pending without moving bytes or writing a
    /// disposition; only an authenticated mismatch above can do that.
    private func isRetryableCommittedCandidateRead(
        _ error: LocalRuntimeStorageError
    ) -> Bool {
        switch error {
        case .protectedDataUnavailable,
             .canonicalStorageFull,
             .canonicalIOFailure,
             .canonicalSQLiteFailure,
             .canonicalFileProtectionFailure,
             .canonicalActivationBusy,
             .canonicalActivationLockFailed,
             .canonicalReadPageTooLarge,
             .sqliteOpenFailed,
             .sqlitePrepareFailed,
             .sqliteStepFailed,
             .sqliteBindFailed:
            true
        default:
            false
        }
    }

    private func isRetryableCommittedCandidateControlRead(
        _ error: RuntimeGenerationControlError
    ) -> Bool {
        switch error {
        case .controlAuthorityUnavailable,
             .readBudgetExceeded,
             .resourcePolicyExceeded,
             .activationReconciliationPending,
             .generationWorkerBarrierBusy:
            true
        default:
            false
        }
    }

    /// Authenticates a bounded immutable control lineage. Exact authority bytes
    /// are additionally required while retention says those bytes are owned;
    /// an explicitly pruned `.lineageOnly` ancestor remains digest-authenticated
    /// without making later active resolution depend on deleted files.
    private func validatePredecessorAuthorityChain(
        startingAt manifest: RuntimeGenerationAuthorityManifest
    ) async throws {
        let maximumAncestryDepth = 256
        var descendant = manifest
        var seen = Set<RuntimeStoreGenerationID>()
        var depth = 0
        while let predecessorID = descendant.sourceGenerationID {
            guard let expectedDigest = descendant.sourceGenerationDigest,
                  seen.insert(predecessorID).inserted,
                  depth < maximumAncestryDepth else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            let predecessor = try await controlStore.generationRecord(id: predecessorID)
            guard predecessor.authorityManifest.generationID == predecessorID,
                  predecessor.authorityManifest.manifestDigest == expectedDigest else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            let retention = try await controlStore.currentRetentionClass(
                generationID: predecessorID
            )
            if retention != .lineageOnly {
                let predecessorDirectory = locations.generationDirectoryURL(for: predecessorID)
                let predecessorAuthorityURL = predecessorDirectory.appendingPathComponent(
                    "Authority.json", isDirectory: false
                )
                try RuntimeStorePathValidation.requireContained(
                    predecessorDirectory,
                    in: locations.storesURL
                )
                let predecessorPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
                    predecessorDirectory,
                    createFinalComponentIfMissing: false
                )
                try predecessorPin.revalidate()
                guard let bytes = try RuntimeStoreManifestDescriptorReader.readIfPresent(
                    at: predecessorAuthorityURL
                ),
                LocalRuntimeStorageChecksum.sha256Hex(for: bytes) ==
                    predecessor.authorityManifestFileSHA256,
                try RuntimeGenerationControlCodec.decode(
                    RuntimeGenerationAuthorityManifest.self,
                    from: bytes
                ) == predecessor.authorityManifest else {
                    throw RuntimeGenerationControlError.activationAuthorityMismatch
                }
                try predecessorPin.revalidate()
            }
            descendant = predecessor.authorityManifest
            depth += 1
        }
        guard descendant.sourceGenerationDigest == nil else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
    }

    private func monotonic(after prior: Int64, proposed: Int64) throws -> Int64 {
        guard prior < Int64.max else {
            throw RuntimeGenerationControlError.malformed(field: "resolver_timestamp")
        }
        return max(prior + 1, proposed)
    }
}

enum RuntimeGenerationWriteOutcome<Value: Sendable>: Sendable {
    case committed(Value)
    case committedBarrierDegraded(Value)
    case indeterminate(
        reconciliationToken: String,
        isolationCleanupRequired: Bool,
        barrierCleanupRequired: Bool
    )
}

struct RuntimeGenerationSourceBackupSnapshot: Sendable, Equatable {
    let fence: RuntimeGenerationRevisionFence
    let authorityFenceToken: RuntimeGenerationAuthorityFenceToken
    let counts: RuntimeGenerationCounts
    let boundaries: RuntimeGenerationBoundaries
    let semanticEquivalenceDigest: String
}

struct RuntimeGenerationPreservedBackup<Value: Sendable>: Sendable {
    let databaseSnapshot: RuntimeGenerationSourceBackupSnapshot
    let preservedAuthority: Value
}

/// Actor-owned writable v8 handle. Every write transaction is admitted by the
/// generation barrier, so final activation cannot overlap a local writer.
actor CanonicalRuntimeStoreV8 {
    let resolved: ResolvedRuntimeGenerationV8
    private let database: SQLiteDatabase
    private let barrier: RuntimeGenerationBarrierAuthority
    private var environment: RuntimeEnvironment
    private var isClosing = false
    private var isClosed = false

    private init(
        resolved: ResolvedRuntimeGenerationV8,
        database: SQLiteDatabase,
        barrier: RuntimeGenerationBarrierAuthority,
        environment: RuntimeEnvironment
    ) {
        self.resolved = resolved
        self.database = database
        self.barrier = barrier
        self.environment = environment
    }

    static func open(
        resolved: ResolvedRuntimeGenerationV8,
        environment: RuntimeEnvironment
    ) async throws -> CanonicalRuntimeStoreV8 {
        let activationDescriptor = try acquireSharedGenerationLock(resolved: resolved)
        try resolved.rootAuthority.revalidatePinnedRoot()
        try resolved.generationDirectoryPin.revalidate()
        do {
            try requireBoundActiveSelector(resolved: resolved)
            try resolved.pinnedFiles.validate(databaseURL: resolved.databaseURL)
            try resolved.generationDirectoryPin.revalidate()
            try resolved.rootAuthority.revalidatePinnedRoot()
        } catch {
            guard releaseGenerationLock(activationDescriptor) else {
                throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
            }
            throw error
        }
        let database: SQLiteDatabase
        do {
            database = try SQLiteDatabase(
                url: resolved.databaseURL,
                configuration: CanonicalRuntimeStore.sqliteConfiguration(
                    openMode: .existingOnly
                )
            )
        } catch {
            guard releaseGenerationLock(activationDescriptor) else {
                throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
            }
            throw error
        }
        do {
            try await database.transaction(
                .deferred,
                precommitValidation: { _ in
                    try activationDescriptor.revalidate(requiredMode: .shared)
                    try resolved.rootAuthority.revalidatePinnedRoot()
                    try resolved.generationDirectoryPin.revalidate()
                    try resolved.pinnedFiles.validate(databaseURL: resolved.databaseURL)
                    try requireBoundActiveSelector(resolved: resolved)
                }
            ) { database in
                try CanonicalRuntimeAttachmentSchemaPlan.requireIntegratedSchema(in: database)
            }
            try resolved.pinnedFiles.validate(databaseURL: resolved.databaseURL)
            try resolved.generationDirectoryPin.revalidate()
            try resolved.rootAuthority.revalidatePinnedRoot()
            try requireBoundActiveSelector(resolved: resolved)
        } catch {
            let operationError = error
            var closeFailed = false
            do { try await database.close() } catch { closeFailed = true }
            let lockReleased = releaseGenerationLock(activationDescriptor)
            guard closeFailed == false, lockReleased else {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_failed_v8_runtime_open"
                )
            }
            throw operationError
        }
        guard releaseGenerationLock(activationDescriptor) else {
            do { try await database.close() }
            catch {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_unbound_v8_runtime_open"
                )
            }
            throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
        }
        return CanonicalRuntimeStoreV8(
            resolved: resolved,
            database: database,
            barrier: resolved.barrierAuthority,
            environment: environment
        )
    }

    func withReadTransaction<Result: Sendable>(
        _ operation: @Sendable (_ database: isolated SQLiteDatabase) throws -> Result
    ) async throws -> Result {
        try requireOpen()
        let sharedLock = try acquireSharedGenerationLock()
        let result: Result
        do {
            try resolved.rootAuthority.revalidatePinnedRoot()
            try resolved.generationDirectoryPin.revalidate()
            try resolved.pinnedFiles.validate(databaseURL: resolved.databaseURL)
            try requireBoundActiveSelector()
            result = try await database.transaction(
                .deferred,
                precommitValidation: { _ in
                    try sharedLock.revalidate(requiredMode: .shared)
                    try resolved.rootAuthority.revalidatePinnedRoot()
                    try resolved.generationDirectoryPin.revalidate()
                    try resolved.pinnedFiles.validate(databaseURL: resolved.databaseURL)
                    try Self.requireBoundActiveSelector(resolved: resolved)
                },
                operation
            )
            try resolved.pinnedFiles.validate(databaseURL: resolved.databaseURL)
            try resolved.generationDirectoryPin.revalidate()
            try resolved.rootAuthority.revalidatePinnedRoot()
        } catch {
            let operationError: Error
            if let budget = error as? SQLiteQueryBudgetExceeded {
                operationError = LocalRuntimeStorageError.canonicalReadPageTooLarge(
                    maximumBytes: budget.maximumBytes
                )
            } else {
                operationError = error
            }
            guard releaseSharedGenerationLock(sharedLock) else {
                throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
            }
            throw operationError
        }
        guard releaseSharedGenerationLock(sharedLock) else {
            throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
        }
        return result
    }

    func withWriteTransaction<Result: Sendable>(
        kind: RuntimeGenerationUseKind,
        writeAuthorization: SQLiteWriteAuthorization,
        _ operation: @Sendable (_ database: isolated SQLiteDatabase) throws -> Result
    ) async throws -> RuntimeGenerationWriteOutcome<Result> {
        try requireOpen()
        let token = environment.uuid.nextUUID().uuidString.lowercased()
        let lease = try await barrier.beginUse(
            token: token,
            generationID: resolved.selector.generationID,
            kind: kind
        )
        var sharedLock: RuntimeGenerationActivationLockScope?
        do {
            try resolved.rootAuthority.revalidatePinnedRoot()
            try resolved.generationDirectoryPin.revalidate()
            try resolved.pinnedFiles.validate(databaseURL: resolved.databaseURL)
            sharedLock = try acquireSharedGenerationLock()
            try requireBoundActiveSelector()
            guard let heldLock = sharedLock else {
                throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
            }
            let result = try await database.transaction(
                .immediate,
                writeAuthorization: writeAuthorization,
                precommitValidation: { _ in
                    try heldLock.revalidate(requiredMode: .shared)
                    try resolved.rootAuthority.revalidatePinnedRoot()
                    try resolved.generationDirectoryPin.revalidate()
                    try resolved.pinnedFiles.validate(databaseURL: resolved.databaseURL)
                    try Self.requireBoundActiveSelector(resolved: resolved)
                },
                operation
            )
            var authorityStillPinned = true
            do {
                try resolved.pinnedFiles.validate(databaseURL: resolved.databaseURL)
                try resolved.generationDirectoryPin.revalidate()
                try resolved.rootAuthority.revalidatePinnedRoot()
            } catch {
                authorityStillPinned = false
            }
            let fileReleased = sharedLock.map(releaseSharedGenerationLock) ?? false
            sharedLock = nil
            do {
                try await barrier.endUse(lease)
                return fileReleased && authorityStillPinned
                    ? .committed(result)
                    : .committedBarrierDegraded(result)
            } catch {
                return .committedBarrierDegraded(result)
            }
        } catch {
            let operationError = error
            let fileReleased = sharedLock.map(releaseSharedGenerationLock) ?? true
            sharedLock = nil
            var leaseReleased = true
            do {
                try await barrier.endUse(lease)
            } catch {
                leaseReleased = false
            }
            if operationError is SQLiteTransactionCommitIndeterminateError {
                return .indeterminate(
                    reconciliationToken: token,
                    isolationCleanupRequired: fileReleased == false,
                    barrierCleanupRequired: leaseReleased == false
                )
            }
            guard fileReleased, leaseReleased else {
                throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
            }
            throw operationError
        }
    }

    /// Produces a SQLite online backup from a WAL read snapshot while a shared
    /// generation/admission pin prevents activation. Writers remain admitted;
    /// the bounded authority token captured in the same snapshot is rechecked
    /// under the final exclusive activation barrier and forces retry if G moved.
    func createMigrationBackup<PreservedAuthority: Sendable>(
        at destinationURL: URL,
        preserveBeforeUnlock: @Sendable (
            _ snapshot: RuntimeGenerationSourceBackupSnapshot
        ) async throws -> PreservedAuthority
    ) async throws -> RuntimeGenerationPreservedBackup<PreservedAuthority> {
        try requireOpen()
        let token = environment.uuid.nextUUID().uuidString.lowercased()
        let lease = try await barrier.beginUse(
            token: token,
            generationID: resolved.selector.generationID,
            kind: .migrationSnapshot
        )
        var sharedLock: RuntimeGenerationActivationLockScope?
        var leaseHeld = true
        do {
            try resolved.rootAuthority.revalidatePinnedRoot()
            try resolved.generationDirectoryPin.revalidate()
            try resolved.pinnedFiles.validate(databaseURL: resolved.databaseURL)
            sharedLock = try acquireSharedGenerationLock()
            guard let heldLock = sharedLock else {
                throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
            }
            let snapshot = try await database.transaction(
                .deferred,
                precommitValidation: { _ in
                    try heldLock.revalidate(requiredMode: .shared)
                    try resolved.rootAuthority.revalidatePinnedRoot()
                    try resolved.generationDirectoryPin.revalidate()
                    try resolved.pinnedFiles.validate(databaseURL: resolved.databaseURL)
                    try Self.requireBoundActiveSelector(resolved: resolved)
                }
            ) { database in
                let fence = try RuntimeGenerationDatabaseAuthority.revisionFenceInTransaction(
                    database: database,
                    generationID: resolved.selector.generationID,
                    generationDigest: resolved.candidate.authorityManifest.manifestDigest
                )
                let authorityFenceToken = try RuntimeGenerationDatabaseAuthority
                    .boundedAuthorityFenceTokenInTransaction(
                        database: database,
                        generationID: resolved.selector.generationID
                    )
                let inventory = try RuntimeGenerationDatabaseAuthority.manifestInventoryInTransaction(
                    database: database
                )
                let semanticEquivalenceDigest = try RuntimeGenerationDatabaseAuthority
                    .migrationEquivalenceDigestInTransaction(database: database)
                _ = try database.backup(
                    to: destinationURL,
                    prepareReservedDestination: { _, _, descriptor in
                        try RuntimeStoreFileDurability.applyCompleteProtection(
                            toOpenFileDescriptor: descriptor,
                            artifact: "generation_backup_database_reserved"
                        )
                    }
                )
                return RuntimeGenerationSourceBackupSnapshot(
                    fence: fence,
                    authorityFenceToken: authorityFenceToken,
                    counts: inventory.0,
                    boundaries: inventory.1,
                    semanticEquivalenceDigest: semanticEquivalenceDigest
                )
            }
            try resolved.pinnedFiles.validate(databaseURL: resolved.databaseURL)
            try resolved.generationDirectoryPin.revalidate()
            try resolved.rootAuthority.revalidatePinnedRoot()
            guard sharedLock.map(releaseSharedGenerationLock) == true else {
                sharedLock = nil
                throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
            }
            sharedLock = nil
            // The SQLite snapshot and its authority fence are now immutable at
            // the destination. Content-addressed vault verification/copy can be
            // O(total attachment bytes), so it runs after writer exclusion is
            // released while the generation barrier lease still pins G.
            let preservedAuthority = try await preserveBeforeUnlock(snapshot)
            try resolved.generationDirectoryPin.revalidate()
            try resolved.rootAuthority.revalidatePinnedRoot()
            leaseHeld = false
            try await barrier.endUse(lease)
            return RuntimeGenerationPreservedBackup(
                databaseSnapshot: snapshot,
                preservedAuthority: preservedAuthority
            )
        } catch {
            let operationError = error
            let fileReleased = sharedLock.map(releaseSharedGenerationLock) ?? true
            sharedLock = nil
            var leaseReleased = true
            if leaseHeld {
                do {
                    try await barrier.endUse(lease)
                    leaseHeld = false
                } catch {
                    leaseReleased = false
                }
            }
            guard fileReleased, leaseReleased else {
                throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
            }
            throw operationError
        }
    }

    func currentRevisionFenceForActivation() async throws -> RuntimeGenerationRevisionFence {
        try requireOpen()
        try resolved.rootAuthority.revalidatePinnedRoot()
        try resolved.generationDirectoryPin.revalidate()
        try resolved.pinnedFiles.validate(databaseURL: resolved.databaseURL)
        return try await RuntimeGenerationDatabaseAuthority.revisionFence(
            in: database,
            generationID: resolved.selector.generationID,
            generationDigest: resolved.candidate.authorityManifest.manifestDigest
        )
    }

    func currentAuthorityFenceTokenForActivation(
        activationLock: RuntimeGenerationActivationLockScope
    ) async throws
        -> RuntimeGenerationAuthorityFenceToken {
        try requireOpen()
        try activationLock.revalidate(requiredMode: .exclusive)
        try resolved.rootAuthority.revalidatePinnedRoot()
        try resolved.generationDirectoryPin.revalidate()
        try resolved.pinnedFiles.validate(databaseURL: resolved.databaseURL)
        return try await RuntimeGenerationDatabaseAuthority.boundedAuthorityFenceToken(
            in: database,
            generationID: resolved.selector.generationID,
            activationLock: activationLock
        )
    }

    func close() async throws {
        if isClosed { return }
        guard isClosing == false else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "v8_store_retirement_in_progress"
            )
        }
        isClosing = true
        do {
            try await database.close()
            isClosed = true
            isClosing = false
        } catch {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "close_v8_runtime_store"
            )
        }
    }

    private func requireOpen() throws {
        guard isClosing == false, isClosed == false else {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "v8_runtime_store_closed"
            )
        }
    }


    private func acquireSharedGenerationLock() throws
        -> RuntimeGenerationActivationLockScope {
        try resolved.rootAuthority.revalidatePinnedRoot()
        try resolved.generationDirectoryPin.revalidate()
        return try RuntimeGenerationActivationLockScope.acquire(
            rootAuthority: resolved.rootAuthority,
            locations: RuntimeStoreLocations(
                applicationSupportURL: resolved.rootAuthority.applicationSupportURL
            ),
            mode: .shared,
            createIfMissing: false
        )
    }

    private static func acquireSharedGenerationLock(
        resolved: ResolvedRuntimeGenerationV8
    ) throws -> RuntimeGenerationActivationLockScope {
        try RuntimeGenerationActivationLockScope.acquire(
            rootAuthority: resolved.rootAuthority,
            locations: RuntimeStoreLocations(
                applicationSupportURL: resolved.rootAuthority.applicationSupportURL
            ),
            mode: .shared,
            createIfMissing: false
        )
    }

    private static func releaseGenerationLock(
        _ scope: RuntimeGenerationActivationLockScope
    ) -> Bool {
        do {
            try scope.close()
            return true
        // AMBitionsAllowWeakPattern(reason: "Lock release failure remains an explicit false result for indeterminate isolation handling.")
        } catch {
            return false
        }
    }

    private static func requireBoundActiveSelector(
        resolved: ResolvedRuntimeGenerationV8
    ) throws {
        let rootURL = resolved.generationDirectoryURL.deletingLastPathComponent()
            .deletingLastPathComponent()
        guard let data = try RuntimeStoreManifestDescriptorReader.readIfPresent(
            at: rootURL.appendingPathComponent("active-store.json")
        ),
        LocalRuntimeStorageChecksum.sha256Hex(for: data) == resolved.selectorFileSHA256,
        try RuntimeGenerationActiveSelectorCodec.decode(data) == resolved.selector else {
            throw RuntimeGenerationControlError.activationFenceAdvanced
        }
    }

    private func requireBoundActiveSelector() throws {
        try Self.requireBoundActiveSelector(resolved: resolved)
    }

    private func releaseSharedGenerationLock(
        _ scope: RuntimeGenerationActivationLockScope
    ) -> Bool {
        Self.releaseGenerationLock(scope)
    }
}
