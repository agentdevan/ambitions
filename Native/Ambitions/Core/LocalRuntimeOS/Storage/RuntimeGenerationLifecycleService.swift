import AmbitionsRuntimeSQLite
import CryptoKit
import Foundation

struct RuntimeGenerationActivationResult: Sendable, Equatable {
    let generationID: RuntimeStoreGenerationID
    let selectorFileSHA256: String
    let authorityManifestDigest: String
    let verificationID: String
    let activationIntentID: String
    let restoreBaselinePlanID: String?
    let committedWithCleanupWarning: Bool
    let controlReconciliationRequired: Bool
    let barrierReconciliationRequired: Bool
    let isolationCleanupRequired: Bool
}

struct RuntimeGenerationRecoveryResult: Sendable, Equatable {
    let activation: RuntimeGenerationActivationResult
    let restoreBaselinePlanID: String
    let recoveryAuthorizationID: String
    let recoveryControlReconciliationRequired: Bool
}

struct RuntimeGenerationRollbackResult: Sendable, Equatable {
    let activation: RuntimeGenerationActivationResult
    let rollbackAssessmentID: String
    let restoreBaselinePlanID: String
    let recoveryAuthorizationID: String
    let recoveryControlReconciliationRequired: Bool
}

struct RuntimeGenerationActivationReconciliationResult: Sendable, Equatable {
    let classification: RuntimeGenerationActivationCrashClassification
    let controlReconciliationRequired: Bool
}

struct RuntimeGenerationFreshConnectionVerificationInspection: Sendable, Equatable {
    let report: RuntimeGenerationVerificationReport
    let isDurableActivationAuthority: Bool
}

/// Durable admission evidence for a projection rebuild. Admission reserves a
/// fenced candidate only; it neither copies source bytes nor rebuilds or
/// publishes any derived state.
struct RuntimeGenerationProjectionRebuildAdmission: Sendable, Equatable {
    let recoveryPlan: RuntimeGenerationRecoveryOperationPlan
    let recoveryClaim: RuntimeGenerationRecoveryOperationExecutionClaim
    let quarantine: RuntimeGenerationQuarantineRecord
    let sourceSafetyBackup: RuntimeGenerationBackupRecord
    let reservation: RuntimeGenerationReservation
    let operationLease: RuntimeGenerationOperationLease
    let migrationRun: RuntimeGenerationMigrationRun
    let candidatePreparation: RuntimeGenerationCandidatePreparationRecord
    let admittedTransition: RuntimeGenerationProjectionRebuildLifecycleTransition
    let candidateAuthorityReservation: RuntimeGenerationProjectionRebuildCandidateReservation
}

/// An owned, unpublished projection-rebuild candidate. Possession of this
/// context permits derived writes through the gateway only; it is not a
/// completed rebuild, a verified candidate, or publication authority.
struct RuntimeGenerationProjectionRebuildExecutionContext: Sendable {
    let admission: RuntimeGenerationProjectionRebuildAdmission
    let source: CanonicalRuntimeStoreV8
    let operationLease: RuntimeGenerationOperationLease
    let runningTransition: RuntimeGenerationProjectionRebuildLifecycleTransition
    let sourceSnapshot: RuntimeGenerationSourceBackupSnapshot
    let candidateCreatedAtMilliseconds: Int64
    let candidateDirectoryURL: URL
    let gateway: RuntimeGenerationCandidateDerivedGateway
    let worker: RuntimeCanonicalProjectionWorker
}

/// Immutable suspension state. It can only be resumed through the lifecycle
/// service, which must durably authenticate blocked -> running first.
struct RuntimeGenerationProjectionRebuildBlockedContinuation: Sendable {
    fileprivate let context: RuntimeGenerationProjectionRebuildExecutionContext
    let blockedTransition: RuntimeGenerationProjectionRebuildLifecycleTransition
    let reasonDigest: String
}

/// Immutable certification handoff. It intentionally provides no route back
/// to the bounded worker; a future certification API owns its next phase.
struct RuntimeGenerationProjectionRebuildReadyForCertification: Sendable {
    fileprivate let context: RuntimeGenerationProjectionRebuildExecutionContext
    let readyTransition: RuntimeGenerationProjectionRebuildLifecycleTransition
}

struct RuntimeGenerationProjectionRebuildCertificationResult: Sendable, Equatable {
    let rebuild: RuntimeGenerationRebuildRecord
    let candidateAuthorityCommitment: RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment
}

/// The post-commit handoff is deliberately separate from certification: it
/// authenticates frozen candidate bytes again before creating verification or
/// activation authority.
struct RuntimeGenerationProjectionRebuildContinuationResult: Sendable, Equatable {
    let commitment: RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment
    let verification: RuntimeGenerationVerificationReport
    let activation: RuntimeGenerationActivationResult
}

/// One caller-driven, bounded rebuild advance. `readyToCertify` means the
/// candidate worker found no remaining work; it is deliberately not a
/// verification, activation, receipt, or recovery-consumption result.
enum RuntimeGenerationProjectionRebuildAdvanceOutcome: Sendable {
    /// Another caller currently owns the same migration-run advance gate.
    /// No worker unit or lifecycle transition was attempted by this call.
    case pending(migrationRunID: String)
    case progressed(
        completedUnits: Int,
        lastUnit: RuntimeCanonicalProjectionDrainOutcome
    )
    case blocked(RuntimeGenerationProjectionRebuildBlockedContinuation)
    case readyToCertify(RuntimeGenerationProjectionRebuildReadyForCertification)
}

private struct RuntimeGenerationProjectionRebuildWorkerBlockedError: Error, Sendable {
    let reasonCode: String
}

private struct RuntimeGenerationProjectionRebuildBlockedState: Sendable {
    let transition: RuntimeGenerationProjectionRebuildLifecycleTransition
    let operationLease: RuntimeGenerationOperationLease
}

/// A separately constructed process-local verifier identity. It deliberately
/// claims only fresh-connection separation from the executor, not a restart,
/// process boundary, or independent fault domain.
private struct RuntimeGenerationFreshConnectionVerifier: Sendable {
    let verifierInstanceID: String

    init(verifierInstanceID: String, executorInstanceID: String) throws {
        try RuntimeGenerationControlValidation.requireIdentifier(
            verifierInstanceID, field: "fresh_connection_verifier_id"
        )
        guard verifierInstanceID != executorInstanceID else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        self.verifierInstanceID = verifierInstanceID
    }
}

/// Candidate replay auditing has three materially different outcomes. This
/// transient error preserves a non-successful outcome through the staged
/// generation workflow without manufacturing a verification, rebuild, retry,
/// or recovery-control record that the control plane cannot yet represent.
private enum RuntimeGenerationCandidateReplayAuditOutcome: Error, Sendable, Equatable {
    case blocked(RuntimeCanonicalReplayDivergence)
    case deferred(RuntimeCanonicalReplayDeferredReason)
}

private struct RuntimeGenerationPreservedVaultAuthority: Sendable {
    let observedBackupFence: RuntimeGenerationRevisionFence
    let observedSemanticEquivalenceDigest: String
    let vaultSnapshot: RuntimeGenerationVerifiedVaultSnapshot
}

private struct RuntimeGenerationPreparedDirectoryEvidence: Sendable {
    let identity: RuntimeStoreFileIdentity
    let artifactCount: Int64
    let byteCount: Int64
    let inventoryDigest: String
    let durabilityWitnessDigest: String
}

/// All authority needed after a candidate database has been transformed, but
/// before the candidate is either verified or published.  Keeping this
/// boundary explicit prevents recovery-specific callers from accidentally
/// inheriting selector publication or recovery-consumption authority.
private struct RuntimeGenerationCandidatePostTransformFinalizationInput: Sendable {
    let operationKind: RuntimeGenerationOperationKind
    let reservation: RuntimeGenerationReservation
    let candidatePreparation: RuntimeGenerationCandidatePreparationRecord
    let migrationRun: RuntimeGenerationMigrationRun
    let candidateDirectoryURL: URL
    let candidateCreatedAtMilliseconds: Int64
    /// Candidate semantic baseline; may differ from the manifest lineage
    /// fence for an authorized restore descendant.
    let expectedCandidateSnapshot: RuntimeGenerationSourceBackupSnapshot
    /// Descendants preserve the full copied inventory. A projection rebuild
    /// deliberately changes derived inventory and is certified separately.
    let requiresExactCandidateInventory: Bool
    let manifestSourceFence: RuntimeGenerationRevisionFence
    let sourceGenerationID: RuntimeStoreGenerationID
    let sourceGenerationDigest: String
    let sourceEncryptionScheme: String
    let blobSetDigest: String
    let attachmentManifestSetDigest: String
    let keyIdentityDigest: String
    let verificationID: String
    let activationIntentID: String
    let relativeDatabasePath: String
    let priorGenerationID: RuntimeStoreGenerationID?
    let priorAuthorityManifestDigest: String?
    /// Projection rebuild supplies source equivalence here. Ordinary
    /// descendants preserve their existing later fresh-connection check.
    let expectedReplayStateDigest: String?
    let replayAuditID: String
}

private struct RuntimeGenerationCandidatePostTransformFinalizationOutput: Sendable {
    let operationLease: RuntimeGenerationOperationLease
    let candidate: RuntimeGenerationCandidateRecord
    let candidatePreparationCompletion: RuntimeGenerationCandidatePreparationCompletion
    let replayAudit: RuntimeGenerationCandidateReplayAuditRecord
    let authorityManifestBytes: Data
    let selectorBytes: Data
    let replayStateDigest: String
}

private actor RuntimeGenerationRenewableLeaseState {
    private var current: RuntimeGenerationOperationLease

    init(_ lease: RuntimeGenerationOperationLease) {
        current = lease
    }

    func lease() -> RuntimeGenerationOperationLease { current }
    func replace(with lease: RuntimeGenerationOperationLease) { current = lease }
}

private enum RuntimeGenerationLeaseOperationEvent<Result: Sendable>: Sendable {
    case operation(Result)
    case heartbeatStopped
}

/// Concrete schema-v8 first-install lifecycle. The same journal, verifier,
/// barrier, and publisher are used by migration/restore/import operations;
/// those operations additionally require a source backup and exact final fence.
actor RuntimeGenerationLifecycleService {
    private let controlStore: RuntimeGenerationControlStore
    private let generationManager: RuntimeStoreGenerationManager
    private let barrierAuthority: RuntimeGenerationBarrierAuthority
    private var environment: RuntimeEnvironment
    private let fileManager: FileManager
    private let preparationScanByteLimit: Int64
    private var activeProjectionRebuildAdvances: Set<String> = []

    init(
        controlStore: RuntimeGenerationControlStore,
        generationManager: RuntimeStoreGenerationManager,
        barrierAuthority: RuntimeGenerationBarrierAuthority,
        environment: RuntimeEnvironment,
        fileManager: FileManager = .default,
        preparationScanByteLimit: Int64 = 8 * 1_024 * 1_024 * 1_024
    ) {
        self.controlStore = controlStore
        self.generationManager = generationManager
        self.barrierAuthority = barrierAuthority
        self.environment = environment
        self.fileManager = fileManager
        self.preparationScanByteLimit = preparationScanByteLimit
    }

    func installFirstGeneration(
        keyCustody: any RuntimeAttachmentKeyCustody = KeychainRuntimeAttachmentKeyCustody(),
        reservationLifetimeMilliseconds: Int64 = 15 * 60 * 1_000
    ) async throws -> RuntimeGenerationActivationResult {
        let createdAt = try nowMilliseconds()
        guard reservationLifetimeMilliseconds > 0 else {
            throw RuntimeGenerationControlError.malformed(field: "reservation_lifetime")
        }
        let generationID = try RuntimeStoreGenerationID(validating: nextID())
        let reservationID = nextID()
        let candidatePreparationID = nextID()
        let replayAuditID = nextID()
        let runID = nextID()
        let executorID = nextID()
        let verificationID = nextID()
        let verifierID = nextID()
        let intentID = nextID()
        let stagingToken = nextID()
        let temporaryToken = nextID()
        let rollbackToken = nextID()
        let barrierToken = nextID()
        let locations = await generationManager.locations
        let stagingURL = locations.stagingDirectoryURL(
            for: generationID,
            token: stagingToken
        )

        let reservation = try RuntimeGenerationControlRecordFactory.reservation(
            id: reservationID,
            operationKind: .install,
            candidateGenerationID: generationID,
            sourceGenerationID: nil,
            sourceGenerationDigest: nil,
            expectedActiveManifestDigest: nil,
            createdAtMilliseconds: createdAt
        )
        var operationLease = try await issueInitialOperationLease(
            reservation: reservation,
            ownerInstanceID: executorID,
            requestedLifetimeMilliseconds: reservationLifetimeMilliseconds
        )
        let candidatePreparation = try RuntimeGenerationControlRecordFactory
            .candidatePreparation(
                id: candidatePreparationID,
                reservation: reservation,
                operationLease: operationLease,
                stagingDirectoryName: stagingURL.lastPathComponent
            )
        try await controlStore.recordReservationAndInitialOperationLease(
            reservation: reservation,
            lease: operationLease,
            candidatePreparation: candidatePreparation
        )

        let vaultPreparation = try await withRenewableOperationLease(
            initialLease: operationLease
        ) {
            try await RuntimeGenerationVaultInventoryReader.prepareEmpty(
                rootURL: locations.attachmentVaultURL,
                keyCustody: keyCustody,
                fileManager: self.fileManager
            )
        }
        let vaultInventory = vaultPreparation.result
        operationLease = vaultPreparation.lease
        try RuntimeStorePathValidation.requireContained(stagingURL, in: locations.storesURL)
        try createPinnedPreparationDirectory(
            named: stagingURL.lastPathComponent,
            in: locations.storesURL,
            artifact: "v8_staging_generation"
        )
        let databaseURL = stagingURL.appendingPathComponent("Runtime.sqlite", isDirectory: false)
        let databaseInstallation = try await withRenewableOperationLease(
            initialLease: operationLease
        ) {
            try await RuntimeGenerationDatabaseAuthority.installEmptyV8(
                at: databaseURL,
                generationID: generationID,
                createdAtMilliseconds: createdAt
            )
        }
        let database = databaseInstallation.result
        operationLease = databaseInstallation.lease
        let baselineIdentityDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: "activation-baseline-v1\n\(generationID.rawValue)\n\(createdAt)"
        )
        let databaseState: (
            inventory: (RuntimeGenerationCounts, RuntimeGenerationBoundaries),
            fence: RuntimeGenerationRevisionFence,
            replayStateDigest: String
        )
        let databasePreparation = try await withRenewableOperationLease(
            initialLease: operationLease
        ) {
            do {
                let replayAudit = try await RuntimeCanonicalReplayEngine.auditAndCertifyCandidate(
                    in: database
                )
                let replayStateDigest: String
                switch replayAudit {
                case let .complete(reconstruction):
                    replayStateDigest = reconstruction.stateDigest
                case let .blocked(divergence, _):
                    throw RuntimeGenerationCandidateReplayAuditOutcome.blocked(divergence)
                case let .deferred(reason):
                    throw RuntimeGenerationCandidateReplayAuditOutcome.deferred(reason)
                }
                let checkpoint = try await database.checkpoint(.truncate)
                guard checkpoint.logFrameCount == checkpoint.checkpointedFrameCount else {
                    throw LocalRuntimeStorageError.canonicalIntegrityFailure
                }
                let inventory = try await RuntimeGenerationDatabaseAuthority.manifestInventory(
                    in: database
                )
                let fence = try await RuntimeGenerationDatabaseAuthority.revisionFence(
                    in: database,
                    generationID: generationID,
                    generationDigest: baselineIdentityDigest
                )
                try await database.close()
                return (inventory, fence, replayStateDigest)
            } catch {
                let operationError = error
                do { try await database.close() }
                catch {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "close_first_install_database"
                    )
                }
                throw operationError
            }
        }
        databaseState = databasePreparation.result
        operationLease = databasePreparation.lease
        let inventory = databaseState.inventory
        let activationBaselineFence = databaseState.fence
        let replayAuditRecord = try RuntimeGenerationControlRecordFactory.candidateReplayAudit(
            id: replayAuditID,
            preparation: candidatePreparation,
            operationLease: operationLease,
            outcome: .complete,
            reconstructionDigest: databaseState.replayStateDigest,
            auditedAtMilliseconds: max(operationLease.issuedAtMilliseconds, try nowMilliseconds())
        )
        try await controlStore.recordCandidateReplayAudit(
            replayAuditRecord,
            currentLease: operationLease
        )
        let activationBaseline = try RuntimeGenerationActivationBaseline.make(
            candidateIdentityDigest: baselineIdentityDigest,
            revisionFence: activationBaselineFence
        )
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: databaseURL,
            artifact: "v8_generation_database"
        )
        try RuntimeStoreFileDurability.synchronizeFile(at: databaseURL)
        let databaseArtifact = try RuntimeGenerationDatabaseAuthority.artifact(
            at: databaseURL,
            relativePath: "Runtime.sqlite"
        )
        // A fresh generation has one creation instant shared by metadata,
        // provenance, and immutable manifest authority.
        let completedAt = createdAt
        let provenanceDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: "install-v8\n\(generationID.rawValue)\n\(databaseArtifact.sha256)\n\(vaultInventory.keyIdentityDigest)\n\(vaultInventory.blobSetDigest)"
        )
        operationLease = try await renewOperationLeaseIfNeeded(
            operationLease,
            force: true
        )
        let run = try RuntimeGenerationControlRecordFactory.migrationRun(
            id: runID,
            executorInstanceID: executorID,
            reservationID: reservationID,
            operationLeaseID: operationLease.leaseID,
            operationLeaseEpoch: operationLease.leaseEpoch,
            operationFencingToken: operationLease.fencingToken,
            sourceSafetyBackupID: nil,
            backupID: nil,
            recoveryAuthorizationID: nil,
            recoveryAuthorizationDigest: nil,
            operationKind: .install,
            sourceSchemaVersion: nil,
            candidateGenerationID: generationID,
            transformationVersion: 1,
            provenanceDigest: provenanceDigest,
            startedAtMilliseconds: createdAt,
            completedAtMilliseconds: completedAt
        )
        try await controlStore.recordMigrationRun(run)

        let manifest = try RuntimeGenerationAuthorityManifest.make(
            operationKind: .install,
            generationID: generationID,
            schemaVersion: runtimeCanonicalAttachmentSchemaVersion,
            sourceGenerationID: nil,
            sourceGenerationDigest: nil,
            sourceFence: nil,
            activationBaseline: activationBaseline,
            database: databaseArtifact.semantic,
            sourceWAL: nil,
            blobSetDigest: vaultInventory.blobSetDigest,
            attachmentManifestSetDigest: vaultInventory.manifestSetDigest,
            encryptionScheme: vaultInventory.encryptionScheme,
            keyIdentityDigest: vaultInventory.keyIdentityDigest,
            counts: inventory.0,
            boundaries: inventory.1,
            reservationID: reservationID,
            migrationRunID: runID,
            createdAtMilliseconds: completedAt,
            retentionClass: .staged
        )
        let authorityData = try RuntimeGenerationControlCodec.encode(manifest)
        let authoritySHA = LocalRuntimeStorageChecksum.sha256Hex(for: authorityData)
        let selector = RuntimeGenerationActiveSelector(
            formatVersion: runtimeGenerationActiveSelectorVersion,
            generationID: generationID,
            schemaVersion: runtimeCanonicalAttachmentSchemaVersion,
            relativeDatabasePath: locations.relativeDatabasePath(for: generationID),
            authorityManifestDigest: manifest.manifestDigest,
            authorityManifestFileSHA256: authoritySHA,
            verificationID: verificationID,
            activationIntentID: intentID,
            priorGenerationID: nil,
            priorAuthorityManifestDigest: nil,
            preparedAtMilliseconds: completedAt
        )
        let selectorData = try RuntimeGenerationActiveSelectorCodec.encode(selector)
        let selectorSHA = LocalRuntimeStorageChecksum.sha256Hex(for: selectorData)
        let candidate = try RuntimeGenerationControlRecordFactory.candidate(
            authorityManifest: manifest,
            authorityManifestFileSHA256: authoritySHA,
            selectorFileSHA256: selectorSHA
        )
        try writeImmutable(
            authorityData,
            to: stagingURL.appendingPathComponent("Authority.json"),
            artifact: "v8_authority_manifest"
        )
        try RuntimeStoreFileDurability.synchronizeDirectory(at: stagingURL)
        try await controlStore.recordGeneration(candidate)
        let authorityArtifact = try RuntimeGenerationArtifact(
            relativePath: "Authority.json",
            sha256: authoritySHA,
            byteCount: Int64(authorityData.count),
            protectionClass: "complete"
        )
        let candidateEvidenceWork = try await withRenewableOperationLease(
            initialLease: operationLease
        ) {
            try await self.preparedDirectoryEvidence(
                at: stagingURL,
                artifacts: [databaseArtifact.semantic, authorityArtifact],
                witnessDomain: "candidate-directory-durability-v1"
            )
        }
        let candidateEvidence = candidateEvidenceWork.result
        operationLease = candidateEvidenceWork.lease
        let candidateCompletion = try RuntimeGenerationControlRecordFactory
            .candidatePreparationCompletion(
                preparationID: candidatePreparationID,
                candidateRecordDigest: candidate.recordDigest,
                directoryDevice: candidateEvidence.identity.device,
                directoryInode: candidateEvidence.identity.inode,
                interiorArtifactCount: candidateEvidence.artifactCount,
                interiorByteCount: candidateEvidence.byteCount,
                interiorInventoryDigest: candidateEvidence.inventoryDigest,
                durabilityWitnessDigest: candidateEvidence.durabilityWitnessDigest,
                completedAtMilliseconds: nondecreasingTimestamp(
                    after: operationLease.issuedAtMilliseconds,
                    proposed: try nowMilliseconds()
                )
            )
        try await controlStore.recordCandidatePreparationCompletion(
            candidateCompletion,
            currentLease: operationLease
        )

        operationLease = try await renewOperationLeaseIfNeeded(
            operationLease,
            force: true
        )
        let verification = try await withRenewableOperationLease(
            initialLease: operationLease
        ) {
            try await self.verifyCandidateWithFreshConnections(
                candidate: candidate,
                reservation: reservation,
                run: run,
                databaseURL: databaseURL,
                verificationID: verificationID,
                verifierID: verifierID,
                vaultInventory: vaultInventory,
                vaultRootURL: locations.attachmentVaultURL,
                keyCustody: keyCustody,
                expectedSourceSnapshot: nil,
                sourceManifest: nil,
                vault: nil,
                expectedVaultSnapshot: nil
            )
        }
        let report = verification.result
        operationLease = verification.lease
        operationLease = try await renewOperationLeaseIfNeeded(
            operationLease,
            force: true
        )
        try await controlStore.recordVerification(report)
        let verifiedTransition = try RuntimeGenerationControlRecordFactory.retentionTransition(
            id: nextID(),
            generationID: generationID,
            fromClass: .staged,
            toClass: .freshConnectionVerified,
            reasonCode: "fresh_connection_v8_verification",
            authorityDigest: report.reportDigest,
            occurredAtMilliseconds: report.verifiedAtMilliseconds
        )
        try await controlStore.recordRetentionTransition(verifiedTransition)
        let intentCreatedAt = nondecreasingTimestamp(
            after: report.verifiedAtMilliseconds,
            proposed: try nowMilliseconds()
        )
        let intent = try RuntimeGenerationControlRecordFactory.activationIntent(
            id: intentID,
            reservation: reservation,
            verification: report,
            createdAtMilliseconds: intentCreatedAt,
            expiresAtMilliseconds: try shortActivationIntentExpiry(
                createdAtMilliseconds: intentCreatedAt
            )
        )
        try await controlStore.recordActivationIntent(intent)
        let activeTransitionID = nextID()
        let barrier = try await barrierAuthority.acquireFinalBarrier(
            token: barrierToken,
            expectedGenerationID: nil
        )
        var barrierHeld = true
        var preserveBarrierForRecovery = false
        do {
            try await requireCurrentOperationLease(operationLease)
            let publicationLease = operationLease
            let activation = try await generationManager.publishVerifiedGeneration(
                candidateDirectoryURL: stagingURL,
                candidate: candidate,
                candidatePreparationCompletion: candidateCompletion,
                selectorData: selectorData,
                controlStore: controlStore,
                operationLease: publicationLease,
                activationIntentID: intent.intentID,
                expectedPriorSelectorFileSHA256: nil,
                postCommitJournal: { committedAtMilliseconds in
                    do {
                        let consumedAt = max(
                            intent.createdAtMilliseconds, committedAtMilliseconds
                        )
                        let consumption = try RuntimeGenerationControlRecordFactory
                            .activationConsumption(
                                intent: intent,
                                consumedAtMilliseconds: consumedAt,
                                installedSelectorFileSHA256: selectorSHA,
                                priorGenerationID: nil,
                                priorGenerationDigest: nil
                            )
                        guard verifiedTransition.occurredAtMilliseconds < Int64.max else {
                            return false
                        }
                        let transition = try RuntimeGenerationControlRecordFactory
                            .retentionTransition(
                                id: activeTransitionID,
                                generationID: generationID,
                                fromClass: .freshConnectionVerified,
                                toClass: .active,
                                reasonCode: "selector_consumed",
                                authorityDigest: consumption.consumptionDigest,
                                occurredAtMilliseconds: max(
                                    verifiedTransition.occurredAtMilliseconds + 1,
                                    consumedAt
                                )
                            )
                        let candidateDisposition = try RuntimeGenerationControlRecordFactory
                            .candidatePreparationDisposition(
                                preparationID: candidatePreparationID,
                                operationLeaseID: publicationLease.leaseID,
                                operationFencingToken: publicationLease.fencingToken,
                                kind: .activated,
                                authorityDigest: consumption.consumptionDigest,
                                disposedAtMilliseconds: consumedAt
                            )
                        try await controlStore.finalizeCommittedActivation(
                            consumption: consumption,
                            retentionTransition: transition,
                            predecessorRetentionTransition: nil,
                            recoveryConsumption: nil,
                            candidateDisposition: candidateDisposition,
                            observedIntent: intent,
                            observedVerification: report,
                            nowMilliseconds: consumedAt
                        )
                        return true
                    } catch {
                        return false
                    }
                },
                temporaryToken: temporaryToken,
                rollbackToken: rollbackToken
            )
            if activation.isolationCleanupRequired,
               activation.activationState.isDefinitelyUncommittedOrUnknown {
                preserveBarrierForRecovery = true
                throw LocalRuntimeStorageError.canonicalActivationIsolationIndeterminate
            }
            let warning: Bool
            switch activation.activationState {
            case .committed: warning = false
            case .committedWithCleanupWarning: warning = true
            case let .unchanged(error):
                barrierHeld = false
                try await barrierAuthority.releaseUnchanged(barrier)
                throw error
            case .unknown:
                preserveBarrierForRecovery = true
                throw LocalRuntimeStorageError.canonicalActivationStateUnknown
            }
            // The selector is now durable authority. A failed process-local
            // advance preserves the barrier for reconciliation; it must never
            // release unchanged or relabel the committed selector as failed.
            var barrierReconciliationRequired = false
            do {
                try await barrierAuthority.advance(from: barrier, to: generationID)
                barrierHeld = false
            } catch {
                preserveBarrierForRecovery = true
                barrierReconciliationRequired = true
            }
            return RuntimeGenerationActivationResult(
                generationID: generationID,
                selectorFileSHA256: selectorSHA,
                authorityManifestDigest: manifest.manifestDigest,
                verificationID: verificationID,
                activationIntentID: intentID,
                restoreBaselinePlanID: nil,
                committedWithCleanupWarning: warning,
                controlReconciliationRequired: activation.postCommitJournalSucceeded == false,
                barrierReconciliationRequired: barrierReconciliationRequired,
                isolationCleanupRequired: activation.isolationCleanupRequired
            )
        } catch {
            if barrierHeld && preserveBarrierForRecovery == false {
                try await barrierAuthority.releaseUnchanged(barrier)
            }
            throw error
        }
    }

    /// Creates an immutable schema-v8 descendant from the exact active source
    /// snapshot. This is the production G to G+1 migration/rebuild primitive:
    /// it never mutates G, requires a durable verified backup, independently
    /// reopens and replays G+1, and rejects activation if G advances after the
    /// backup fence was captured.
    func migrateActiveGeneration(
        source: CanonicalRuntimeStoreV8,
        vault: RuntimeAttachmentVault,
        keyCustody: any RuntimeAttachmentKeyCustody = KeychainRuntimeAttachmentKeyCustody(),
        reservationLifetimeMilliseconds: Int64 = 15 * 60 * 1_000
    ) async throws -> RuntimeGenerationActivationResult {
        try await activateActiveDescendant(
            source: source,
            vault: vault,
            keyCustody: keyCustody,
            restorationBackup: nil,
            recoveryAuthorization: nil,
            rollbackAssessment: nil,
            reservationLifetimeMilliseconds: reservationLifetimeMilliseconds
        )
    }

    /// Restores an independently verified, immutable backup as a new
    /// generation. The active generation is preserved first and activation
    /// still uses the current source fence. A later rollback is possible only
    /// while the restored generation remains exactly at its activation floor.
    func restoreVerifiedBackup(
        source: CanonicalRuntimeStoreV8,
        vault: RuntimeAttachmentVault,
        backupID: String,
        recoveryAuthorizationID: String,
        keyCustody: any RuntimeAttachmentKeyCustody = KeychainRuntimeAttachmentKeyCustody(),
        reservationLifetimeMilliseconds: Int64 = 15 * 60 * 1_000
    ) async throws -> RuntimeGenerationRecoveryResult {
        let restorationBackup = try await controlStore.backup(id: backupID)
        let authorization = try await controlStore.recoveryAuthorization(
            id: recoveryAuthorizationID
        )
        let authorizationObservedAt = try nowMilliseconds()
        guard authorization.action == .restoreVerifiedBackup,
              authorization.targetDigest == restorationBackup.backupDigest,
              authorizationObservedAt >= authorization.authorizedAtMilliseconds,
              authorizationObservedAt < authorization.expiresAtMilliseconds else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        let activation = try await activateActiveDescendant(
            source: source,
            vault: vault,
            keyCustody: keyCustody,
            restorationBackup: restorationBackup,
            recoveryAuthorization: authorization,
            rollbackAssessment: nil,
            reservationLifetimeMilliseconds: reservationLifetimeMilliseconds
        )
        guard let restoreBaselinePlanID = activation.restoreBaselinePlanID else {
            throw RuntimeGenerationControlError.rollbackUnsafe
        }
        return RuntimeGenerationRecoveryResult(
            activation: activation,
            restoreBaselinePlanID: restoreBaselinePlanID,
            recoveryAuthorizationID: recoveryAuthorizationID,
            recoveryControlReconciliationRequired:
                activation.controlReconciliationRequired
        )
    }

    /// Records an immutable rollback assessment only when the restored
    /// generation is still byte-semantically at its activation authority
    /// floor. Any post-activation canonical, receipt, external-effect, or
    /// attachment work makes rollback unsafe and is rejected.
    func assessRollback(
        source: CanonicalRuntimeStoreV8,
        restoreBaselinePlanID: String
    ) async throws -> RuntimeGenerationRollbackRecord {
        let plan = try await controlStore.restoreBaselinePlan(id: restoreBaselinePlanID)
        let selector = source.resolved.selector
        let candidate = source.resolved.candidate
        guard selector.generationID == plan.targetGenerationID,
              candidate.authorityManifest.generationID == plan.targetGenerationID,
              candidate.authorityManifest.activationBaseline.baselineDigest ==
                plan.targetActivationBaselineDigest else {
            throw RuntimeGenerationControlError.rollbackUnsafe
        }
        let observed = try await source.currentRevisionFenceForActivation()
        let baseline = candidate.authorityManifest.activationBaseline.revisionFence
        guard observed.generationID == plan.targetGenerationID,
              observed.generationDigest == candidate.authorityManifest.manifestDigest,
              observed.eventSequence == baseline.eventSequence,
              observed.eventID == baseline.eventID,
              observed.eventHash == baseline.eventHash,
              observed.commandCount == baseline.commandCount,
              observed.receiptCount == baseline.receiptCount,
              observed.externalOperationStatusVersionSum ==
                baseline.externalOperationStatusVersionSum,
              observed.attachmentLifecycleVersionSum ==
                baseline.attachmentLifecycleVersionSum,
              observed.canonicalStateDigest == baseline.canonicalStateDigest,
              observed.receiptAuthorityDigest == baseline.receiptAuthorityDigest,
              observed.externalOperationAuthorityDigest ==
                baseline.externalOperationAuthorityDigest,
              observed.attachmentAuthorityDigest ==
                baseline.attachmentAuthorityDigest else {
            throw RuntimeGenerationControlError.rollbackUnsafe
        }
        let record = try RuntimeGenerationControlRecordFactory.rollback(
            id: nextID(),
            restoreBaselinePlanID: plan.planID,
            sourceGenerationID: plan.sourceGenerationID,
            sourceSafetyFenceDigest: plan.sourceSafetyFenceDigest,
            targetGenerationID: plan.targetGenerationID,
            targetVerificationID: plan.targetVerificationID,
            targetObservedFence: observed,
            postActivationEventCount: observed.eventSequence - baseline.eventSequence,
            postActivationCommandCount: observed.commandCount - baseline.commandCount,
            postActivationReceiptCount: observed.receiptCount - baseline.receiptCount,
            postActivationExternalEffectCount:
                observed.externalOperationStatusVersionSum -
                    baseline.externalOperationStatusVersionSum,
            postActivationAttachmentLifecycleCount:
                observed.attachmentLifecycleVersionSum -
                    baseline.attachmentLifecycleVersionSum,
            activatedAtMilliseconds: try nowMilliseconds()
        )
        try await controlStore.recordRollback(record)
        return record
    }

    /// Materializes the reviewed safety snapshot into a fresh generation. The
    /// selector is never moved backward to an old generation directory.
    func rollbackToSafetyBackup(
        source: CanonicalRuntimeStoreV8,
        vault: RuntimeAttachmentVault,
        rollbackAssessmentID: String,
        recoveryAuthorizationID: String,
        keyCustody: any RuntimeAttachmentKeyCustody = KeychainRuntimeAttachmentKeyCustody(),
        reservationLifetimeMilliseconds: Int64 = 15 * 60 * 1_000
    ) async throws -> RuntimeGenerationRollbackResult {
        let assessment = try await controlStore.rollback(id: rollbackAssessmentID)
        let baselinePlan = try await controlStore.restoreBaselinePlan(
            id: assessment.restoreBaselinePlanID
        )
        let safetyBackup = try await controlStore.backup(id: baselinePlan.sourceSafetyBackupID)
        let authorization = try await controlStore.recoveryAuthorization(
            id: recoveryAuthorizationID
        )
        let observedAt = try nowMilliseconds()
        guard assessment.targetGenerationID == source.resolved.selector.generationID,
              baselinePlan.targetGenerationID == assessment.targetGenerationID,
              safetyBackup.backupID == baselinePlan.sourceSafetyBackupID,
              authorization.action == .rollbackToSafetyBackup,
              authorization.targetDigest == assessment.rollbackDigest,
              observedAt >= authorization.authorizedAtMilliseconds,
              observedAt < authorization.expiresAtMilliseconds else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        let activation = try await activateActiveDescendant(
            source: source,
            vault: vault,
            keyCustody: keyCustody,
            restorationBackup: safetyBackup,
            recoveryAuthorization: authorization,
            rollbackAssessment: assessment,
            reservationLifetimeMilliseconds: reservationLifetimeMilliseconds
        )
        guard let newBaselinePlanID = activation.restoreBaselinePlanID else {
            throw RuntimeGenerationControlError.rollbackUnsafe
        }
        return RuntimeGenerationRollbackResult(
            activation: activation,
            rollbackAssessmentID: assessment.rollbackID,
            restoreBaselinePlanID: newBaselinePlanID,
            recoveryAuthorizationID: authorization.authorizationID,
            recoveryControlReconciliationRequired:
                activation.controlReconciliationRequired
        )
    }

    func reconcileUnknownActivation(
        candidateGenerationID: RuntimeStoreGenerationID
    ) async throws -> RuntimeGenerationActivationReconciliationResult {
        let candidate = try await controlStore.generationRecord(
            id: candidateGenerationID
        )
        let run = try await controlStore.migrationRun(
            id: candidate.authorityManifest.migrationRunID
        )
        let reservation = try await controlStore.reservation(id: run.reservationID)
        let intent = try await controlStore.activationIntent(
            candidateGenerationID: candidateGenerationID
        )
        let observedClassification = try await generationManager.classifyActivationAfterCrash(
            candidate: candidate,
            expectedPriorSelectorFileSHA256: reservation.expectedActiveManifestDigest,
            externalAuthorityMayHaveChanged:
                run.operationKind == .restore || run.operationKind == .rollback,
            controlStore: controlStore
        )
        let existingConsumption = try await controlStore.activationConsumption(
            intentID: intent.intentID
        )
        let classification: RuntimeGenerationActivationCrashClassification
        switch observedClassification {
        case let .committed(selector):
            if let existingConsumption,
               (existingConsumption.installedSelectorFileSHA256 !=
                    candidate.selectorFileSHA256 ||
                existingConsumption.priorGenerationID != reservation.sourceGenerationID ||
                existingConsumption.priorGenerationDigest !=
                    reservation.sourceGenerationDigest ||
                selector.activationIntentID != intent.intentID) {
                classification = .splitAuthority
            } else {
                classification = observedClassification
            }
        case .unchanged:
            classification = existingConsumption == nil
                ? observedClassification
                : .splitAuthority
        default:
            classification = observedClassification
        }
        switch classification {
        case let .committed(selector):
            try await barrierAuthority.resolveUnknownActivation(
                expectedSourceGenerationID: reservation.sourceGenerationID,
                resolution: .committed(selector.generationID)
            )
            let report = try await controlStore.verification(id: selector.verificationID)
            var reconciliationRequired = false
            do {
                let consumedAt = max(intent.createdAtMilliseconds, try nowMilliseconds())
                let consumption = existingConsumption ?? (try
                    RuntimeGenerationControlRecordFactory.activationConsumption(
                        intent: intent,
                        consumedAtMilliseconds: consumedAt,
                        installedSelectorFileSHA256: candidate.selectorFileSHA256,
                        priorGenerationID: reservation.sourceGenerationID,
                        priorGenerationDigest: reservation.sourceGenerationDigest
                    ))
                let retention = try await controlStore.currentRetentionClass(
                    generationID: candidateGenerationID
                )
                if retention == .freshConnectionVerified {
                    let transition = try RuntimeGenerationControlRecordFactory
                        .retentionTransition(
                            id: "reconcile-active-\(intent.intentID)",
                            generationID: candidateGenerationID,
                            fromClass: .freshConnectionVerified,
                            toClass: .active,
                            reasonCode: "selector_reconciled",
                            authorityDigest: consumption.consumptionDigest,
                            occurredAtMilliseconds: try monotonicTimestamp(
                                after: report.verifiedAtMilliseconds,
                                proposed: consumption.consumedAtMilliseconds
                            )
                        )
                    let recoveryConsumption: RuntimeGenerationRecoveryAuthorizationConsumption?
                    if run.operationKind == .restore || run.operationKind == .rollback {
                    let plan = try await controlStore.restoreBaselinePlan(
                        targetGenerationID: candidateGenerationID
                    )
                        let authorization = try await controlStore.recoveryAuthorization(
                            id: plan.recoveryAuthorizationID
                        )
                        recoveryConsumption = try RuntimeGenerationControlRecordFactory
                            .recoveryAuthorizationConsumption(
                                authorization: authorization,
                                resultDigest: plan.planDigest,
                                consumedAtMilliseconds: consumedAt
                            )
                    } else {
                        recoveryConsumption = nil
                    }
                    let predecessorTransition: RuntimeGenerationRetentionTransition?
                    if let sourceGenerationID = reservation.sourceGenerationID {
                        predecessorTransition = try RuntimeGenerationControlRecordFactory
                            .retentionTransition(
                                id: "demote-active-\(intent.intentID)",
                                generationID: sourceGenerationID,
                                fromClass: .active,
                                toClass: .verifiedRollback,
                                reasonCode: "superseded_by_selector",
                                authorityDigest: consumption.consumptionDigest,
                                occurredAtMilliseconds: consumption.consumedAtMilliseconds
                            )
                    } else {
                        predecessorTransition = nil
                    }
                    let preparation = try await controlStore.candidatePreparation(
                        generationID: candidateGenerationID
                    )
                    let reconciliationLease = try await takeOverExpiredOperationLease(
                        reservationID: preparation.reservationID
                    )
                    let candidateDisposition = try RuntimeGenerationControlRecordFactory
                        .candidatePreparationDisposition(
                            preparationID: preparation.preparationID,
                            operationLeaseID: reconciliationLease.leaseID,
                            operationFencingToken: reconciliationLease.fencingToken,
                            kind: .activated,
                            authorityDigest: consumption.consumptionDigest,
                            disposedAtMilliseconds: max(
                                consumedAt, reconciliationLease.issuedAtMilliseconds
                            )
                        )
                    try await controlStore.finalizeCommittedActivation(
                        consumption: consumption,
                        retentionTransition: transition,
                        predecessorRetentionTransition: predecessorTransition,
                        recoveryConsumption: recoveryConsumption,
                        candidateDisposition: candidateDisposition,
                        observedIntent: intent,
                        observedVerification: report,
                        nowMilliseconds: consumption.consumedAtMilliseconds
                    )
                } else if retention != .active || existingConsumption == nil {
                    throw RuntimeGenerationControlError.activationAuthorityMismatch
                }
            } catch {
                reconciliationRequired = true
            }
            return RuntimeGenerationActivationReconciliationResult(
                classification: classification,
                controlReconciliationRequired: reconciliationRequired
            )
        case .unchanged:
            try await barrierAuthority.resolveUnknownActivation(
                expectedSourceGenerationID: reservation.sourceGenerationID,
                resolution: .unchanged(reservation.sourceGenerationID)
            )
            return RuntimeGenerationActivationReconciliationResult(
                classification: classification,
                controlReconciliationRequired: false
            )
        case .selectorMissing,
             .selectorCorrupt,
             .selectorFutureVersion,
             .selectorUnavailable,
             .unexpectedSelector,
             .targetAuthorityMissing,
             .targetAuthorityCorrupt,
             .targetAuthorityUnavailable,
             .targetDatabaseMissing,
             .targetDatabaseCorrupt,
             .targetDatabaseUnavailable,
             .controlAuthorityUnavailable,
             .splitAuthority,
             .externalAuthorityAmbiguous:
            return RuntimeGenerationActivationReconciliationResult(
                classification: classification,
                controlReconciliationRequired: true
            )
        }
    }

    func inspectFreshConnectionVerification(
        candidateGenerationID: RuntimeStoreGenerationID,
        vault: RuntimeAttachmentVault,
        keyCustody: any RuntimeAttachmentKeyCustody = KeychainRuntimeAttachmentKeyCustody()
    ) async throws -> RuntimeGenerationFreshConnectionVerificationInspection {
        let candidate = try await controlStore.generationRecord(id: candidateGenerationID)
        let run = try await controlStore.migrationRun(
            id: candidate.authorityManifest.migrationRunID
        )
        let reservation = try await controlStore.reservation(id: run.reservationID)
        let locations = await generationManager.locations
        let databaseURL = locations.databaseURL(for: candidateGenerationID)
        let expectedSnapshot: RuntimeGenerationSourceBackupSnapshot?
        let sourceManifest: RuntimeGenerationAuthorityManifest?
        let vaultSnapshot: RuntimeGenerationVerifiedVaultSnapshot?
        if let backupID = run.backupID {
            let backup = try await controlStore.backup(id: backupID)
            expectedSnapshot = RuntimeGenerationSourceBackupSnapshot(
                fence: backup.sourceFence,
                authorityFenceToken: backup.authorityFenceToken,
                counts: backup.counts,
                boundaries: backup.boundaries,
                semanticEquivalenceDigest: backup.semanticEquivalenceDigest
            )
            sourceManifest = try await controlStore.generation(
                id: backup.sourceGenerationID
            )
            vaultSnapshot = RuntimeGenerationVerifiedVaultSnapshot(
                blobSetDigest: backup.blobSetDigest,
                manifestSetDigest: backup.attachmentManifestSetDigest,
                keyIdentityDigest: backup.keyIdentityDigest,
                artifacts: backup.vaultArtifacts
            )
        } else {
            expectedSnapshot = nil
            sourceManifest = nil
            vaultSnapshot = nil
        }
        let report = try await verifyCandidateWithFreshConnections(
            candidate: candidate,
            reservation: reservation,
            run: run,
            databaseURL: databaseURL,
            verificationID: nextID(),
            verifierID: nextID(),
            vaultInventory: nil,
            vaultRootURL: locations.attachmentVaultURL,
            keyCustody: keyCustody,
            expectedSourceSnapshot: expectedSnapshot,
            sourceManifest: sourceManifest,
            vault: vault,
            expectedVaultSnapshot: vaultSnapshot
        )
        return RuntimeGenerationFreshConnectionVerificationInspection(
            report: report,
            isDurableActivationAuthority: false
        )
    }

    /// Admits, but deliberately does not execute, a recovery-authorized
    /// projection rebuild. A durable pre-existing safety backup is required by
    /// the current migration-run invariant; this method never creates one or
    /// mutates the source store as part of admission.
    func admitProjectionRebuild(
        source: CanonicalRuntimeStoreV8,
        plan: RuntimeGenerationRecoveryOperationPlan,
        claim: RuntimeGenerationRecoveryOperationExecutionClaim,
        quarantine: RuntimeGenerationQuarantineRecord,
        authorization: RuntimeGenerationRecoveryAuthorization,
        sourceSafetyBackupID: String,
        reservationLifetimeMilliseconds: Int64 = 15 * 60 * 1_000
    ) async throws -> RuntimeGenerationProjectionRebuildAdmission {
        let durablePlan = try await controlStore.load(
            RuntimeGenerationRecoveryOperationPlan.self,
            table: "runtime_generation_recovery_operation_plans",
            idColumn: "plan_id",
            id: plan.planID
        )
        let durableClaim = try await controlStore.load(
            RuntimeGenerationRecoveryOperationExecutionClaim.self,
            table: "runtime_generation_recovery_operation_execution_claims",
            idColumn: "claim_id",
            id: claim.claimID
        )
        let durableQuarantine = try await controlStore.quarantine(id: quarantine.quarantineID)
        let durableAuthorization = try await controlStore.recoveryAuthorization(
            id: authorization.authorizationID
        )
        let admittedAt = try nowMilliseconds()
        guard durablePlan == plan,
              durableClaim == claim,
              durableQuarantine == quarantine,
              durableAuthorization == authorization,
              plan.action == .rebuildDerivedState,
              plan.quarantineID == quarantine.quarantineID,
              plan.targetDigest == quarantine.quarantineDigest,
              plan.recoveryAuthorizationID == authorization.authorizationID,
              plan.recoveryAuthorizationDigest == authorization.authorizationDigest,
              claim.planID == plan.planID,
              admittedAt >= plan.preparedAtMilliseconds,
              admittedAt < plan.expiresAtMilliseconds,
              admittedAt >= authorization.authorizedAtMilliseconds,
              admittedAt < authorization.expiresAtMilliseconds,
              admittedAt >= claim.claimedAtMilliseconds,
              admittedAt < claim.expiresAtMilliseconds,
              quarantine.allowedActions.contains(.rebuildDerivedState),
              authorization.action == .rebuildDerivedState,
              authorization.targetDigest == quarantine.quarantineDigest,
              authorization.authorizationDigest == plan.recoveryAuthorizationDigest,
              let quarantinedGenerationID = quarantine.originalGenerationID,
              let quarantinedManifestDigest = quarantine.originalManifestDigest,
              source.resolved.selector.generationID == quarantinedGenerationID,
              source.resolved.candidate.authorityManifest.generationID == quarantinedGenerationID,
              source.resolved.candidate.authorityManifest.manifestDigest == quarantinedManifestDigest,
              source.resolved.selectorFileSHA256 ==
                source.resolved.candidate.selectorFileSHA256,
              reservationLifetimeMilliseconds > 0 else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }

        let sourceSafetyBackup = try await controlStore.backup(id: sourceSafetyBackupID)
        let sourceManifest = source.resolved.candidate.authorityManifest
        guard sourceSafetyBackup.sourceGenerationID == quarantinedGenerationID,
              sourceSafetyBackup.sourceGenerationDigest == sourceManifest.manifestDigest,
              sourceSafetyBackup.createdAtMilliseconds <= admittedAt else {
            throw RuntimeGenerationControlError.restoreSourceUnverified
        }

        let candidateGenerationID = try RuntimeStoreGenerationID(validating: nextID())
        let reservation = try RuntimeGenerationControlRecordFactory.reservation(
            id: nextID(),
            operationKind: .projectionRebuild,
            candidateGenerationID: candidateGenerationID,
            sourceGenerationID: quarantinedGenerationID,
            sourceGenerationDigest: sourceManifest.manifestDigest,
            expectedActiveManifestDigest: source.resolved.selectorFileSHA256,
            createdAtMilliseconds: admittedAt
        )
        let requestedLeaseLifetime = min(
            reservationLifetimeMilliseconds,
            claim.expiresAtMilliseconds - admittedAt
        )
        let operationLease = try await issueInitialOperationLease(
            reservation: reservation,
            ownerInstanceID: claim.executorInstanceID,
            requestedLifetimeMilliseconds: requestedLeaseLifetime
        )
        guard operationLease.expiresAtMilliseconds <= claim.expiresAtMilliseconds else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        let locations = await generationManager.locations
        let candidatePreparation = try RuntimeGenerationControlRecordFactory
            .candidatePreparation(
                id: nextID(),
                reservation: reservation,
                operationLease: operationLease,
                stagingDirectoryName: locations.stagingDirectoryURL(
                    for: candidateGenerationID,
                    token: nextID()
                ).lastPathComponent,
                recoveryExecutionPlanID: plan.planID,
                recoveryExecutionClaimID: claim.claimID,
                recoveryExecutionClaimEpoch: claim.claimEpoch
            )
        let runTimestamp = operationLease.issuedAtMilliseconds
        let run = try RuntimeGenerationControlRecordFactory.migrationRun(
            id: nextID(),
            executorInstanceID: claim.executorInstanceID,
            reservationID: reservation.reservationID,
            operationLeaseID: operationLease.leaseID,
            operationLeaseEpoch: operationLease.leaseEpoch,
            operationFencingToken: operationLease.fencingToken,
            sourceSafetyBackupID: sourceSafetyBackup.backupID,
            backupID: sourceSafetyBackup.backupID,
            recoveryAuthorizationID: nil,
            recoveryAuthorizationDigest: nil,
            recoveryExecutionPlanID: plan.planID,
            recoveryExecutionClaimID: claim.claimID,
            recoveryExecutionClaimEpoch: claim.claimEpoch,
            operationKind: .projectionRebuild,
            sourceSchemaVersion: runtimeCanonicalAttachmentSchemaVersion,
            candidateGenerationID: candidateGenerationID,
            transformationVersion: 1,
            provenanceDigest: LocalRuntimeStorageChecksum.sha256Hex(
                for: "projection-rebuild-admission-v1\n\(plan.planDigest)\n\(claim.claimDigest)\n\(quarantine.quarantineDigest)\n\(sourceSafetyBackup.backupDigest)\n\(reservation.reservationDigest)\n\(candidatePreparation.preparationDigest)"
            ),
            startedAtMilliseconds: runTimestamp,
            completedAtMilliseconds: runTimestamp
        )
        let admissionTransition = try RuntimeGenerationControlRecordFactory
            .projectionRebuildLifecycleTransition(
                id: nextID(), run: run, phase: .admitted,
                priorTransitionDigest: nil,
                reasonDigest: LocalRuntimeStorageChecksum.sha256Hex(
                    for: "projection-rebuild-admitted-v1\n\(run.runDigest)\n\(claim.claimDigest)"
                ),
                occurredAtMilliseconds: runTimestamp
            )
        let candidateAuthorityReservation = try RuntimeGenerationControlRecordFactory
            .projectionRebuildCandidateReservation(
                id: nextID(),
                plan: plan,
                claim: claim,
                migrationRun: run,
                reservation: reservation,
                candidatePreparation: candidatePreparation,
                expectedVerificationID: nextID(),
                expectedActivationIntentID: nextID(),
                reservedAtMilliseconds: runTimestamp
            )
        let admitted = try await controlStore.admitProjectionRebuild(
            RuntimeGenerationProjectionRebuildAdmissionRequest(
                plan: plan,
                claim: claim,
                quarantine: quarantine,
                authorization: authorization,
                sourceSafetyBackup: sourceSafetyBackup,
                reservation: reservation,
                operationLease: operationLease,
                candidatePreparation: candidatePreparation,
                migrationRun: run,
                admittedTransition: admissionTransition,
                candidateAuthorityReservation: candidateAuthorityReservation
            )
        )
        return RuntimeGenerationProjectionRebuildAdmission(
            recoveryPlan: plan,
            recoveryClaim: claim,
            quarantine: quarantine,
            sourceSafetyBackup: sourceSafetyBackup,
            reservation: admitted.reservation,
            operationLease: admitted.operationLease,
            migrationRun: admitted.migrationRun,
            candidatePreparation: admitted.candidatePreparation,
            admittedTransition: admitted.admittedTransition,
            candidateAuthorityReservation: admitted.candidateAuthorityReservation
        )
    }

    /// Creates one unpublished G+1 copy from the active canonical snapshot,
    /// records that the admitted rebuild is running, and opens the
    /// capability-scoped derived gateway. It does not invoke a rebuild worker,
    /// create a candidate manifest, publish a selector, or consume recovery.
    func beginProjectionRebuildExecution(
        source: CanonicalRuntimeStoreV8,
        admission: RuntimeGenerationProjectionRebuildAdmission
    ) async throws -> RuntimeGenerationProjectionRebuildExecutionContext {
        var currentTransition = admission.admittedTransition
        var currentLease = admission.operationLease
        do {
            try await requireCurrentOperationLease(currentLease)
            let sourceManifest = source.resolved.candidate.authorityManifest
            guard source.resolved.selector.generationID == admission.reservation.sourceGenerationID,
                  sourceManifest.generationID == admission.reservation.sourceGenerationID,
                  sourceManifest.manifestDigest == admission.reservation.sourceGenerationDigest,
                  source.resolved.selectorFileSHA256 ==
                    admission.reservation.expectedActiveManifestDigest,
                  admission.candidatePreparation.recoveryExecutionPlanID ==
                    admission.recoveryPlan.planID,
                  admission.candidatePreparation.recoveryExecutionClaimID ==
                    admission.recoveryClaim.claimID,
                  admission.candidatePreparation.recoveryExecutionClaimEpoch ==
                    admission.recoveryClaim.claimEpoch else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            let locations = await generationManager.locations
            let candidateDirectoryURL = locations.storesURL.appendingPathComponent(
                admission.candidatePreparation.stagingDirectoryName,
                isDirectory: true
            )
            try RuntimeStorePathValidation.requireContained(
                candidateDirectoryURL,
                in: locations.storesURL
            )
            try createPinnedPreparationDirectory(
                named: admission.candidatePreparation.stagingDirectoryName,
                in: locations.storesURL,
                artifact: "projection_rebuild_candidate_staging"
            )
            let candidateDatabaseURL = candidateDirectoryURL.appendingPathComponent(
                "Runtime.sqlite",
                isDirectory: false
            )
            let preserved = try await source.createMigrationBackup(
                at: candidateDatabaseURL
            ) { snapshot in
                snapshot
            }
            try RuntimeStoreFileDurability.applyCompleteProtection(
                at: candidateDatabaseURL,
                artifact: "projection_rebuild_candidate_database"
            )
            let candidateCreatedAt = nondecreasingTimestamp(
                after: admission.reservation.createdAtMilliseconds,
                proposed: try nowMilliseconds()
            )
            let candidateDatabase = try SQLiteDatabase(
                url: candidateDatabaseURL,
                configuration: CanonicalRuntimeStore.sqliteConfiguration(openMode: .existingOnly)
            )
            do {
                try await candidateDatabase.transaction(.exclusive) { database in
                    let metadata = try database.query(
                        "SELECT generation_id, created_at_ms FROM runtime_store_metadata WHERE singleton_id = 1 LIMIT 2",
                        maximumDecodedBytes: RuntimeGenerationDatabaseAuthority.pageByteBudget
                    )
                    guard metadata.count == 1,
                          metadata[0].value(named: "generation_id") ==
                            .text(sourceManifest.generationID.rawValue),
                          metadata[0].value(named: "created_at_ms") ==
                            .integer(sourceManifest.createdAtMilliseconds) else {
                        throw RuntimeGenerationControlError.activationAuthorityMismatch
                    }
                    try database.execute(
                        "UPDATE runtime_store_metadata SET generation_id = ?, created_at_ms = ? WHERE singleton_id = 1",
                        bindings: [
                            .text(admission.reservation.candidateGenerationID.rawValue),
                            .integer(candidateCreatedAt),
                        ]
                    )
                    try CanonicalRuntimeAttachmentSchemaPlan.requireIntegratedSchema(
                        in: database
                    )
                }
                let checkpoint = try await candidateDatabase.checkpoint(.truncate)
                guard checkpoint.logFrameCount == checkpoint.checkpointedFrameCount else {
                    throw LocalRuntimeStorageError.canonicalIntegrityFailure
                }
                try await candidateDatabase.close()
            } catch {
                let operationError = error
                do { try await candidateDatabase.close() }
                catch { throw LocalRuntimeStorageError.canonicalIOFailure(operation: "close_projection_rebuild_candidate_database") }
                throw operationError
            }
            try RuntimeStoreFileDurability.synchronizeFile(at: candidateDatabaseURL)

            try await requireCurrentOperationLease(currentLease)
            let runningAt = try nowMilliseconds()
            let runningTransition = try RuntimeGenerationControlRecordFactory
                .projectionRebuildLifecycleTransition(
                    id: nextID(),
                    run: admission.migrationRun,
                    phase: .running,
                    priorTransitionDigest: currentTransition.transitionDigest,
                    reasonDigest: LocalRuntimeStorageChecksum.sha256Hex(
                        for: "projection-rebuild-running-v1\n\(admission.migrationRun.runDigest)\n\(currentLease.leaseDigest)"
                    ),
                    occurredAtMilliseconds: runningAt
                )
            try await controlStore.recordProjectionRebuildLifecycleTransition(
                runningTransition,
                currentOperationLease: currentLease
            )
            currentTransition = runningTransition
            let observedLease = try await controlStore.requireCurrentOperationLease(
                reservationID: admission.reservation.reservationID,
                ownerInstanceID: admission.recoveryClaim.executorInstanceID,
                observedAtMilliseconds: try nowMilliseconds()
            )
            guard observedLease == currentLease else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            let gateway = try await RuntimeGenerationCandidateDerivedGateway.open(
                reservationID: admission.reservation.reservationID,
                migrationRunID: admission.migrationRun.migrationRunID,
                expectedExecutorInstanceID: admission.recoveryClaim.executorInstanceID,
                candidateDirectoryURL: candidateDirectoryURL,
                authorityNowMilliseconds: try nowMilliseconds(),
                generationManager: generationManager,
                controlStore: controlStore
            )
            let worker = RuntimeCanonicalProjectionWorker(
                store: gateway,
                registry: try RuntimeCanonicalProjectionDefinitionRegistry.canonical(),
                ownerID: admission.recoveryClaim.executorInstanceID
            )
            return RuntimeGenerationProjectionRebuildExecutionContext(
                admission: admission,
                source: source,
                operationLease: currentLease,
                runningTransition: currentTransition,
                sourceSnapshot: preserved.databaseSnapshot,
                candidateCreatedAtMilliseconds: candidateCreatedAt,
                candidateDirectoryURL: candidateDirectoryURL,
                gateway: gateway,
                worker: worker
            )
        } catch {
            try await recordProjectionRebuildBlockedIfLive(
                admission: admission,
                lease: currentLease,
                priorTransition: currentTransition,
                error: error
            )
            throw error
        }
    }

    /// Advances at most `maximumUnits` existing projection/search worker
    /// units on an already-open, unpublished candidate. The caller owns all
    /// repetition and scheduling. No selector, verification, receipt, rebuild
    /// record, or recovery-plan consumption is written here.
    func advanceProjectionRebuild(
        _ context: RuntimeGenerationProjectionRebuildExecutionContext,
        maximumUnits: Int = 16
    ) async throws -> RuntimeGenerationProjectionRebuildAdvanceOutcome {
        guard (1 ... 64).contains(maximumUnits) else {
            throw RuntimeGenerationControlError.malformed(
                field: "projection_rebuild_maximum_units"
            )
        }
        let migrationRunID = context.admission.migrationRun.migrationRunID
        guard acquireProjectionRebuildAdvanceGate(migrationRunID) else {
            return .pending(migrationRunID: migrationRunID)
        }
        defer { releaseProjectionRebuildAdvanceGate(migrationRunID) }
        var completedUnits = 0
        var lastUnit: RuntimeCanonicalProjectionDrainOutcome?
        for _ in 0 ..< maximumUnits {
            let unit: RuntimeCanonicalProjectionDrainOutcome
            do {
                try Task.checkCancellation()
                try await requireLiveProjectionRebuildExecution(
                    context,
                    expectedTransition: context.runningTransition,
                    expectedPhase: .running
                )
                unit = try await context.worker.runOneUnit(
                    nowMilliseconds: try nowMilliseconds()
                )
            } catch {
                return try await blockedProjectionRebuildAdvance(
                    context,
                    reasonCode: projectionRebuildFailureReason(error)
                )
            }
            completedUnits += 1
            switch unit {
            case .idle:
                let currentLease = try await requireLiveProjectionRebuildExecution(
                    context,
                    expectedTransition: context.runningTransition,
                    expectedPhase: .running
                )
                if let reasonCode = try await projectionRebuildReadinessBlock(
                    context
                ) {
                    return try await blockedProjectionRebuildAdvance(
                        context,
                        reasonCode: reasonCode
                    )
                }
                return try await readyProjectionRebuildForCertification(
                    context,
                    currentLease: currentLease
                )
            case let .blocked(_, reasonCode):
                return try await blockedProjectionRebuildAdvance(
                    context,
                    reasonCode: reasonCode
                )
            case let .deferred(_, reasonCode):
                return try await blockedProjectionRebuildAdvance(
                    context,
                    reasonCode: reasonCode
                )
            case .restartDeferred:
                return try await blockedProjectionRebuildAdvance(
                    context,
                    reasonCode: "worker_restart_deferred"
                )
            default:
                lastUnit = unit
            }
        }
        guard let lastUnit else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
        return .progressed(completedUnits: completedUnits, lastUnit: lastUnit)
    }

    /// Explicitly resumes an immutable blocked continuation. The exact blocked
    /// transition must still be current; only then is blocked -> running
    /// persisted before a new running context is issued.
    func resumeProjectionRebuild(
        _ continuation: RuntimeGenerationProjectionRebuildBlockedContinuation
    ) async throws -> RuntimeGenerationProjectionRebuildExecutionContext {
        let context = continuation.context
        let blocked = continuation.blockedTransition
        let migrationRunID = context.admission.migrationRun.migrationRunID
        guard migrationRunID == blocked.migrationRunID,
              acquireProjectionRebuildAdvanceGate(migrationRunID) else {
            throw RuntimeGenerationControlError.generationWorkerBarrierBusy
        }
        defer { releaseProjectionRebuildAdvanceGate(migrationRunID) }
        let currentLease = try await requireLiveProjectionRebuildExecution(
            context,
            expectedTransition: blocked,
            expectedPhase: .blockedRetryable,
            requiresExactContextLease: false
        )
        let resumedAt = try nowMilliseconds()
        let transition = try RuntimeGenerationControlRecordFactory
            .projectionRebuildLifecycleTransition(
                id: nextID(),
                run: context.admission.migrationRun,
                phase: .running,
                priorTransitionDigest: blocked.transitionDigest,
                reasonDigest: LocalRuntimeStorageChecksum.sha256Hex(
                    for: "projection-rebuild-resumed-v1\n\(blocked.transitionDigest)\n\(currentLease.leaseDigest)"
                ),
                occurredAtMilliseconds: resumedAt
            )
        try await controlStore.recordProjectionRebuildLifecycleTransition(
            transition,
            currentOperationLease: currentLease
        )
        return RuntimeGenerationProjectionRebuildExecutionContext(
            admission: context.admission,
            source: context.source,
            operationLease: currentLease,
            runningTransition: transition,
            sourceSnapshot: context.sourceSnapshot,
            candidateCreatedAtMilliseconds: context.candidateCreatedAtMilliseconds,
            candidateDirectoryURL: context.candidateDirectoryURL,
            gateway: context.gateway,
            worker: context.worker
        )
    }

    /// Certifies only the candidate's derived-state evidence. It does not
    /// publish a runtime selector, activate a generation, or consume recovery.
    func certifyProjectionRebuild(
        _ ready: RuntimeGenerationProjectionRebuildReadyForCertification
    ) async throws -> RuntimeGenerationProjectionRebuildCertificationResult {
        let context = ready.context
        let migrationRunID = context.admission.migrationRun.migrationRunID
        guard acquireProjectionRebuildAdvanceGate(migrationRunID) else {
            throw RuntimeGenerationControlError.generationWorkerBarrierBusy
        }
        defer { releaseProjectionRebuildAdvanceGate(migrationRunID) }
        let lease = try await requireLiveProjectionRebuildExecution(
            context,
            expectedTransition: ready.readyTransition,
            expectedPhase: .readyForCertification,
            requiresExactContextLease: false
        )
        let sourceReplay = try await context.source.withReadTransaction { database in
            switch try RuntimeCanonicalReplayEngine.reconstructInTransaction(database: database) {
            case let .complete(reconstruction): return reconstruction.stateDigest
            case .blocked: throw RuntimeGenerationControlError.verificationRejected
            }
        }
        let candidateEvidence = try await context.gateway.withDerivedImmediateTransaction {
            database -> (String, String, String, String) in
            switch try RuntimeCanonicalReplayEngine.reconstructInTransaction(database: database) {
            case let .complete(reconstruction):
                let equivalence = try RuntimeGenerationDatabaseAuthority
                    .migrationEquivalenceDigestInTransaction(database: database)
                let inventory = try RuntimeGenerationDatabaseAuthority
                    .manifestInventoryInTransaction(database: database)
                return (
                    reconstruction.stateDigest,
                    equivalence,
                    inventory.1.projectionAuthorityDigest,
                    inventory.1.searchAuthorityDigest
                )
            case .blocked:
                throw RuntimeGenerationControlError.verificationRejected
            }
        }
        guard sourceReplay == candidateEvidence.0,
              candidateEvidence.1 == context.sourceSnapshot.semanticEquivalenceDigest else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        let finalLease = try await requireLiveProjectionRebuildExecution(
            context,
            expectedTransition: ready.readyTransition,
            expectedPhase: .readyForCertification,
            requiresExactContextLease: false
        )
        guard finalLease == lease else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        let equivalenceDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: "projection-rebuild-certification-v1\n\(sourceReplay)\n\(candidateEvidence.1)\n\(candidateEvidence.2)\n\(candidateEvidence.3)\n\(ready.readyTransition.transitionDigest)\n\(lease.leaseDigest)"
        )
        let rebuild = try RuntimeGenerationControlRecordFactory.rebuild(
            id: nextID(),
            migrationRunID: migrationRunID,
            recoveryExecutionPlanID: context.admission.recoveryPlan.planID,
            recoveryExecutionClaimID: context.admission.recoveryClaim.claimID,
            recoveryExecutionClaimEpoch: context.admission.recoveryClaim.claimEpoch,
            candidateGenerationID: context.admission.reservation.candidateGenerationID,
            readyTransitionDigest: ready.readyTransition.transitionDigest,
            sourceGenerationID: context.admission.reservation.sourceGenerationID ?? context.source.resolved.selector.generationID,
            sourceFenceDigest: context.sourceSnapshot.authorityFenceToken.tokenDigest,
            replayReconstructionDigest: candidateEvidence.0,
            projectionGenerationDigest: candidateEvidence.2,
            searchGenerationDigest: candidateEvidence.3,
            equivalenceDigest: equivalenceDigest,
            publishedAtMilliseconds: try nowMilliseconds()
        )
        // The gateway's exclusive ownership is intentionally released before
        // the authority finalizer opens a fresh connection to checkpoint and
        // witness the exact candidate bytes.  Nothing below publishes a
        // selector or consumes recovery authority.
        try await context.gateway.close()
        let sourceManifest = context.source.resolved.candidate.authorityManifest
        let finalized = try await finalizePostTransformCandidate(
            input: RuntimeGenerationCandidatePostTransformFinalizationInput(
                operationKind: .projectionRebuild,
                reservation: context.admission.reservation,
                candidatePreparation: context.admission.candidatePreparation,
                migrationRun: context.admission.migrationRun,
                candidateDirectoryURL: context.candidateDirectoryURL,
                candidateCreatedAtMilliseconds: context.candidateCreatedAtMilliseconds,
                expectedCandidateSnapshot: context.sourceSnapshot,
                requiresExactCandidateInventory: false,
                manifestSourceFence: context.sourceSnapshot.fence,
                sourceGenerationID: sourceManifest.generationID,
                sourceGenerationDigest: sourceManifest.manifestDigest,
                sourceEncryptionScheme: sourceManifest.encryptionScheme,
                blobSetDigest: sourceManifest.blobSetDigest,
                attachmentManifestSetDigest: sourceManifest.attachmentManifestSetDigest,
                keyIdentityDigest: sourceManifest.keyIdentityDigest,
                verificationID: context.admission.candidateAuthorityReservation.expectedVerificationID,
                activationIntentID: context.admission.candidateAuthorityReservation.expectedActivationIntentID,
                relativeDatabasePath: (await generationManager.locations).relativeDatabasePath(
                    for: context.admission.reservation.candidateGenerationID
                ),
                priorGenerationID: context.source.resolved.selector.generationID,
                priorAuthorityManifestDigest: sourceManifest.manifestDigest,
                expectedReplayStateDigest: sourceReplay,
                replayAuditID: nextID()
            ),
            initialLease: finalLease
        )
        let commitment = try RuntimeGenerationControlRecordFactory
            .projectionRebuildCandidateAuthorityCommitment(
                id: nextID(),
                candidateReservation: context.admission.candidateAuthorityReservation,
                candidateRecord: finalized.candidate,
                candidatePreparationCompletion: finalized.candidatePreparationCompletion,
                authorityManifestBytes: finalized.authorityManifestBytes,
                selectorBytes: finalized.selectorBytes,
                replayAudit: finalized.replayAudit,
                rebuild: rebuild,
                committedAtMilliseconds: try nowMilliseconds()
            )
        let committed = try await controlStore.commitProjectionRebuildCandidateAuthority(
            RuntimeGenerationProjectionRebuildCandidateCommitmentRequest(
                commitment: commitment,
                currentOperationLease: finalized.operationLease
            )
        )
        return RuntimeGenerationProjectionRebuildCertificationResult(
            rebuild: rebuild,
            candidateAuthorityCommitment: committed
        )
    }

    /// Verifies and activates the exact candidate frozen by a v10 projection
    /// rebuild commitment. This method never reconstructs candidate authority
    /// from mutable presentation state and refuses to publish a different,
    /// stale, or partially reconciled candidate.
    func continueCommittedProjectionRebuild(
        source: CanonicalRuntimeStoreV8,
        vault: RuntimeAttachmentVault,
        keyCustody: any RuntimeAttachmentKeyCustody,
        plan: RuntimeGenerationRecoveryOperationPlan,
        claim: RuntimeGenerationRecoveryOperationExecutionClaim,
        quarantine: RuntimeGenerationQuarantineRecord,
        authorization: RuntimeGenerationRecoveryAuthorization,
        commitment: RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment
    ) async throws -> RuntimeGenerationProjectionRebuildContinuationResult {
        try RuntimeGenerationControlRecordFactory.validate(commitment)
        let reservation = try await controlStore.reservation(id: commitment.reservationID)
        let run = try await controlStore.migrationRun(id: commitment.migrationRunID)
        let preparation = try await controlStore.candidatePreparation(
            generationID: commitment.candidateGenerationID
        )
        let lease = try await controlStore.load(
            RuntimeGenerationOperationLease.self,
            table: "runtime_generation_operation_leases",
            idColumn: "lease_id",
            id: run.operationLeaseID
        )
        let now = try nowMilliseconds()
        guard plan.action == .rebuildDerivedState,
              plan.planID == commitment.recoveryExecutionPlanID,
              plan.quarantineID == quarantine.quarantineID,
              plan.recoveryAuthorizationID == authorization.authorizationID,
              plan.recoveryAuthorizationDigest == authorization.authorizationDigest,
              claim.claimID == commitment.recoveryExecutionClaimID,
              claim.planID == plan.planID,
              claim.claimEpoch == commitment.recoveryExecutionClaimEpoch,
              authorization.action == .rebuildDerivedState,
              authorization.targetDigest == plan.targetDigest,
              now >= plan.preparedAtMilliseconds,
              now < plan.expiresAtMilliseconds,
              now < claim.expiresAtMilliseconds,
              now < authorization.expiresAtMilliseconds,
              reservation.reservationID == commitment.reservationID,
              reservation.operationKind == .projectionRebuild,
              run.reservationID == reservation.reservationID,
              run.operationLeaseID == lease.leaseID,
              run.operationLeaseEpoch == lease.leaseEpoch,
              lease.reservationID == reservation.reservationID,
              preparation.preparationID == commitment.candidatePreparationID,
              source.resolved.selector.generationID == reservation.sourceGenerationID,
              source.resolved.candidate.authorityManifest.manifestDigest ==
                reservation.sourceGenerationDigest else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        try await requireCurrentOperationLease(lease)
        let locations = await generationManager.locations
        let resolver = RuntimeGenerationResolver(
            rootAuthority: source.resolved.rootAuthority,
            locations: locations,
            controlStore: controlStore,
            barrierAuthority: source.resolved.barrierAuthority,
            environment: environment
        )
        let validated = try await resolver.validateCommittedCandidatePreparation(
            preparation: preparation,
            completion: commitment.candidatePreparationCompletion,
            commitment: commitment
        )
        let candidateDirectoryURL: URL
        switch validated {
        case let .success(reconciliation):
            guard reconciliation.location == .staging else {
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            candidateDirectoryURL = reconciliation.candidateDirectoryURL
        case .integrityMismatch:
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
        let report = try await verifyCandidateWithFreshConnections(
            candidate: commitment.candidateRecord,
            reservation: reservation,
            run: run,
            databaseURL: candidateDirectoryURL.appendingPathComponent("Runtime.sqlite"),
            verificationID: commitment.expectedVerificationID,
            verifierID: nextID(),
            vaultInventory: nil,
            vaultRootURL: locations.attachmentVaultURL,
            keyCustody: keyCustody,
            expectedSourceSnapshot: nil,
            sourceManifest: nil,
            vault: vault,
            expectedVaultSnapshot: nil,
            expectedCandidateReplayStateDigest: commitment.replayReconstructionDigest
        )
        guard report.accepted, report.verificationID == commitment.expectedVerificationID else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        try await controlStore.recordVerification(report)
        let verificationBinding = try RuntimeGenerationControlRecordFactory
            .recoveryOperationVerificationBinding(
                verification: report, plan: plan, claim: claim,
                observedAtMilliseconds: try nowMilliseconds()
            )
        try await controlStore.recordRecoveryOperationVerificationBinding(verificationBinding)
        let verifiedTransition = try RuntimeGenerationControlRecordFactory.retentionTransition(
            id: nextID(), generationID: commitment.candidateGenerationID,
            fromClass: .staged, toClass: .freshConnectionVerified,
            reasonCode: "projection_rebuild_committed_candidate_verification",
            authorityDigest: report.reportDigest,
            occurredAtMilliseconds: report.verifiedAtMilliseconds
        )
        try await controlStore.recordRetentionTransition(verifiedTransition)
        let intentCreatedAt = nondecreasingTimestamp(
            after: report.verifiedAtMilliseconds, proposed: try nowMilliseconds()
        )
        let intent = try RuntimeGenerationControlRecordFactory.activationIntent(
            id: commitment.expectedActivationIntentID,
            reservation: reservation,
            verification: report,
            createdAtMilliseconds: intentCreatedAt,
            expiresAtMilliseconds: try shortActivationIntentExpiry(
                createdAtMilliseconds: intentCreatedAt
            )
        )
        try await controlStore.recordActivationIntent(intent)
        let barrier = try await barrierAuthority.acquireFinalBarrier(
            token: nextID(), expectedGenerationID: source.resolved.selector.generationID
        )
        var barrierHeld = true
        var preserveBarrier = false
        do {
            try await requireCurrentOperationLease(lease)
            let activeTransitionID = nextID()
            let activation = try await generationManager.publishVerifiedGeneration(
                candidateDirectoryURL: candidateDirectoryURL,
                candidate: commitment.candidateRecord,
                candidatePreparationCompletion: commitment.candidatePreparationCompletion,
                selectorData: commitment.selectorBytes,
                controlStore: controlStore,
                operationLease: lease,
                activationIntentID: intent.intentID,
                expectedPriorSelectorFileSHA256: source.resolved.selectorFileSHA256,
                sourceStore: source,
                expectedSourceFence: source.resolved.liveFence,
                temporaryToken: nextID(),
                rollbackToken: nextID(),
                postCommitJournal: { committedAtMilliseconds in
                    do {
                        let consumedAt = max(intent.createdAtMilliseconds, committedAtMilliseconds)
                        let consumption = try RuntimeGenerationControlRecordFactory.activationConsumption(
                            intent: intent, consumedAtMilliseconds: consumedAt,
                            installedSelectorFileSHA256: commitment.selectorBytesSHA256,
                            priorGenerationID: source.resolved.selector.generationID,
                            priorGenerationDigest: source.resolved.candidate.authorityManifest.manifestDigest
                        )
                        let activeTransition = try RuntimeGenerationControlRecordFactory.retentionTransition(
                            id: activeTransitionID,
                            generationID: commitment.candidateGenerationID,
                            fromClass: .freshConnectionVerified, toClass: .active,
                            reasonCode: "projection_rebuild_selector_consumed",
                            authorityDigest: consumption.consumptionDigest,
                            occurredAtMilliseconds: max(verifiedTransition.occurredAtMilliseconds + 1, consumedAt)
                        )
                        let predecessorTransition = try RuntimeGenerationControlRecordFactory.retentionTransition(
                            id: "demote-active-\(intent.intentID)",
                            generationID: source.resolved.selector.generationID,
                            fromClass: .active, toClass: .verifiedRollback,
                            reasonCode: "projection_rebuild_superseded_source",
                            authorityDigest: consumption.consumptionDigest,
                            occurredAtMilliseconds: consumedAt
                        )
                        let disposition = try RuntimeGenerationControlRecordFactory.candidatePreparationDisposition(
                            preparationID: preparation.preparationID,
                            operationLeaseID: lease.leaseID,
                            operationFencingToken: lease.fencingToken,
                            kind: .activated,
                            authorityDigest: consumption.consumptionDigest,
                            disposedAtMilliseconds: consumedAt
                        )
                        try await controlStore.finalizeCommittedActivation(
                            consumption: consumption,
                            retentionTransition: activeTransition,
                            predecessorRetentionTransition: predecessorTransition,
                            recoveryConsumption: nil,
                            candidateDisposition: disposition,
                            observedIntent: intent,
                            observedVerification: report,
                            nowMilliseconds: consumedAt
                        )
                        return true
                    // AMBitionsAllowWeakPattern(reason: "Activation finalization failure is truthfully classified as an uncommitted recovery result.")
                    } catch {
                        return false
                    }
                }
            )
            let cleanupWarning: Bool
            switch activation.activationState {
            case .committed:
                cleanupWarning = false
            case .committedWithCleanupWarning:
                cleanupWarning = true
            case .unchanged, .unknown:
                if activation.activationState.isDefinitelyUncommittedOrUnknown {
                    preserveBarrier = true
                }
                throw RuntimeGenerationControlError.activationAuthorityMismatch
            }
            do {
                try await barrierAuthority.advance(
                    from: barrier, to: commitment.candidateGenerationID
                )
                barrierHeld = false
            } catch { preserveBarrier = true }
            return RuntimeGenerationProjectionRebuildContinuationResult(
                commitment: commitment,
                verification: report,
                activation: RuntimeGenerationActivationResult(
                    generationID: commitment.candidateGenerationID,
                    selectorFileSHA256: commitment.selectorBytesSHA256,
                    authorityManifestDigest: commitment.candidateRecord.authorityManifest.manifestDigest,
                    verificationID: report.verificationID,
                    activationIntentID: intent.intentID,
                    restoreBaselinePlanID: nil,
                    committedWithCleanupWarning: cleanupWarning,
                    controlReconciliationRequired: activation.postCommitJournalSucceeded == false,
                    barrierReconciliationRequired: preserveBarrier,
                    isolationCleanupRequired: activation.isolationCleanupRequired
                )
            )
        } catch {
            if barrierHeld && preserveBarrier == false { try await barrierAuthority.releaseUnchanged(barrier) }
            throw error
        }
    }

    private func blockedProjectionRebuildAdvance(
        _ context: RuntimeGenerationProjectionRebuildExecutionContext,
        reasonCode: String
    ) async throws -> RuntimeGenerationProjectionRebuildAdvanceOutcome {
        guard let state = try await recordProjectionRebuildBlockedIfLive(
            admission: context.admission,
            lease: context.operationLease,
            priorTransition: context.runningTransition,
            error: RuntimeGenerationProjectionRebuildWorkerBlockedError(
                reasonCode: reasonCode
            ),
            reasonMaterial: reasonCode
        ) else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        let contextAtBlock = RuntimeGenerationProjectionRebuildExecutionContext(
            admission: context.admission,
            source: context.source,
            operationLease: state.operationLease,
            runningTransition: context.runningTransition,
            sourceSnapshot: context.sourceSnapshot,
            candidateCreatedAtMilliseconds: context.candidateCreatedAtMilliseconds,
            candidateDirectoryURL: context.candidateDirectoryURL,
            gateway: context.gateway,
            worker: context.worker
        )
        return .blocked(RuntimeGenerationProjectionRebuildBlockedContinuation(
            context: contextAtBlock,
            blockedTransition: state.transition,
            reasonDigest: state.transition.reasonDigest
        ))
    }

    private func readyProjectionRebuildForCertification(
        _ context: RuntimeGenerationProjectionRebuildExecutionContext,
        currentLease: RuntimeGenerationOperationLease
    ) async throws -> RuntimeGenerationProjectionRebuildAdvanceOutcome {
        let readyAt = try nowMilliseconds()
        let transition = try RuntimeGenerationControlRecordFactory
            .projectionRebuildLifecycleTransition(
                id: nextID(),
                run: context.admission.migrationRun,
                phase: .readyForCertification,
                priorTransitionDigest: context.runningTransition.transitionDigest,
                reasonDigest: LocalRuntimeStorageChecksum.sha256Hex(
                    for: "projection-rebuild-ready-for-certification-v1\n\(context.runningTransition.transitionDigest)\n\(currentLease.leaseDigest)"
                ),
                occurredAtMilliseconds: readyAt
            )
        try await controlStore.recordProjectionRebuildLifecycleTransition(
            transition,
            currentOperationLease: currentLease
        )
        return .readyToCertify(
            RuntimeGenerationProjectionRebuildReadyForCertification(
                context: context,
                readyTransition: transition
            )
        )
    }

    private func requireLiveProjectionRebuildExecution(
        _ context: RuntimeGenerationProjectionRebuildExecutionContext,
        expectedTransition: RuntimeGenerationProjectionRebuildLifecycleTransition,
        expectedPhase: RuntimeGenerationProjectionRebuildPhase,
        requiresExactContextLease: Bool = true
    ) async throws -> RuntimeGenerationOperationLease {
        let admission = context.admission
        let observedAt = try nowMilliseconds()
        let latestTransition = try await controlStore
            .latestProjectionRebuildLifecycleTransition(
                migrationRunID: admission.migrationRun.migrationRunID
            )
        let currentLease = try await controlStore.requireCurrentOperationLease(
            reservationID: admission.reservation.reservationID,
            ownerInstanceID: admission.recoveryClaim.executorInstanceID,
            observedAtMilliseconds: observedAt
        )
        let plan = try await controlStore.load(
            RuntimeGenerationRecoveryOperationPlan.self,
            table: "runtime_generation_recovery_operation_plans",
            idColumn: "plan_id",
            id: admission.recoveryPlan.planID
        )
        let claim = try await controlStore.load(
            RuntimeGenerationRecoveryOperationExecutionClaim.self,
            table: "runtime_generation_recovery_operation_execution_claims",
            idColumn: "claim_id",
            id: admission.recoveryClaim.claimID
        )
        let authorization = try await controlStore.recoveryAuthorization(
            id: admission.recoveryPlan.recoveryAuthorizationID
        )
        let existingReceipt = try await controlStore.recoveryOperationExecutionReceipt(
            planID: admission.recoveryPlan.planID
        )
        guard (requiresExactContextLease == false || currentLease == context.operationLease),
              latestTransition == expectedTransition,
              expectedTransition.phase == expectedPhase,
              plan == admission.recoveryPlan,
              claim == admission.recoveryClaim,
              existingReceipt == nil,
              plan.action == .rebuildDerivedState,
              claim.planID == plan.planID,
              authorization.authorizationID == plan.recoveryAuthorizationID,
              authorization.authorizationDigest == plan.recoveryAuthorizationDigest,
              authorization.action == .rebuildDerivedState,
              observedAt >= plan.preparedAtMilliseconds,
              observedAt < plan.expiresAtMilliseconds,
              observedAt >= claim.claimedAtMilliseconds,
              observedAt < claim.expiresAtMilliseconds,
              observedAt >= authorization.authorizedAtMilliseconds,
              observedAt < authorization.expiresAtMilliseconds else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        return currentLease
    }

    private func projectionRebuildFailureReason(_ error: Error) -> String {
        if error is CancellationError { return "cancelled" }
        if let error = error as? RuntimeGenerationControlError {
            switch error {
            case .resourcePolicyExceeded(_, _):
                return "resource_policy_exceeded"
            case .reservationExpired:
                return "operation_lease_expired"
            default:
                return "control_\(String(reflecting: error))"
            }
        }
        return "worker_\(String(reflecting: type(of: error)))"
    }

    private func acquireProjectionRebuildAdvanceGate(_ migrationRunID: String) -> Bool {
        activeProjectionRebuildAdvances.insert(migrationRunID).inserted
    }

    private func releaseProjectionRebuildAdvanceGate(_ migrationRunID: String) {
        precondition(activeProjectionRebuildAdvances.remove(migrationRunID) != nil)
    }

    /// `runOneUnit == .idle` alone is insufficient: a blocked job is not
    /// schedulable by the worker and would otherwise look idle. Readiness
    /// requires every typed projection plus search to have a candidate-local
    /// active authority and no unacknowledged invalidation or build job.
    private func projectionRebuildReadinessBlock(
        _ context: RuntimeGenerationProjectionRebuildExecutionContext
    ) async throws -> String? {
        let registry = try RuntimeCanonicalProjectionDefinitionRegistry.canonical()
        return try await context.gateway.withDerivedImmediateTransaction { database in
            try CanonicalRuntimeProjectionSchemaPlan.requireIntegratedSchema(
                in: database
            )
            for projectionID in registry.definitions.keys.sorted() {
                if try CanonicalRuntimeStore.hasPendingCanonicalInvalidation(
                    projectionID: projectionID,
                    database: database
                ) {
                    return "pending_invalidation_\(projectionID.rawValue)"
                }
                let jobs = try database.query(
                    "SELECT phase FROM runtime_canonical_projection_jobs WHERE projection_id = ? LIMIT 2",
                    bindings: [.text(projectionID.rawValue)]
                )
                guard jobs.count <= 1 else {
                    throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                }
                if let phase = jobs.first?.value(named: "phase") {
                    guard case let .text(rawPhase) = phase else {
                        throw RuntimeCanonicalProjectionPersistenceError.generationMismatch
                    }
                    return "projection_job_\(projectionID.rawValue)_\(rawPhase)"
                }
                let active = try database.query(
                    "SELECT generation_id FROM runtime_canonical_projection_active_generations WHERE projection_id = ? LIMIT 2",
                    bindings: [.text(projectionID.rawValue)]
                )
                guard active.count == 1,
                      case .text = active[0].value(named: "generation_id") else {
                    return "projection_authority_missing_\(projectionID.rawValue)"
                }
            }
            let search = try database.query(
                "SELECT generation_id FROM runtime_canonical_search_active_generation WHERE singleton_id = 1 LIMIT 2"
            )
            guard search.count == 1,
                  case .text = search[0].value(named: "generation_id") else {
                return "search_authority_missing"
            }
            return nil
        }
    }

    private func recordProjectionRebuildBlockedIfLive(
        admission: RuntimeGenerationProjectionRebuildAdmission,
        lease: RuntimeGenerationOperationLease,
        priorTransition: RuntimeGenerationProjectionRebuildLifecycleTransition,
        error: Error,
        reasonMaterial: String? = nil
    ) async throws -> RuntimeGenerationProjectionRebuildBlockedState? {
        do {
            let observedAt = try nowMilliseconds()
            guard observedAt >= admission.recoveryClaim.claimedAtMilliseconds,
                  observedAt < admission.recoveryClaim.expiresAtMilliseconds,
                  observedAt >= admission.recoveryPlan.preparedAtMilliseconds,
                  observedAt < admission.recoveryPlan.expiresAtMilliseconds else {
                return nil
            }
            let current = try await controlStore.requireCurrentOperationLease(
                reservationID: admission.reservation.reservationID,
                ownerInstanceID: lease.ownerInstanceID,
                observedAtMilliseconds: observedAt
            )
            let transition = try RuntimeGenerationControlRecordFactory
                .projectionRebuildLifecycleTransition(
                    id: nextID(),
                    run: admission.migrationRun,
                    phase: .blockedRetryable,
                    priorTransitionDigest: priorTransition.transitionDigest,
                    reasonDigest: LocalRuntimeStorageChecksum.sha256Hex(
                        for: "projection-rebuild-blocked-v1\n\(current.leaseDigest)\n\(reasonMaterial ?? String(reflecting: type(of: error)))"
                    ),
                    occurredAtMilliseconds: observedAt
                )
            try await controlStore.recordProjectionRebuildLifecycleTransition(
                transition,
                currentOperationLease: current
            )
            return RuntimeGenerationProjectionRebuildBlockedState(
                transition: transition,
                operationLease: current
            )
        } catch RuntimeGenerationControlError.reservationExpired,
            RuntimeGenerationControlError.activationAuthorityMismatch,
            RuntimeGenerationControlError.recoveryAuthorizationRequired {
            // The durable admitted/running chain is intentionally retained for
            // reconciliation when lease or recovery authority is no longer live.
            return nil
        }
    }

    private func activateActiveDescendant(
        source: CanonicalRuntimeStoreV8,
        vault: RuntimeAttachmentVault,
        keyCustody: any RuntimeAttachmentKeyCustody,
        restorationBackup: RuntimeGenerationBackupRecord?,
        recoveryAuthorization: RuntimeGenerationRecoveryAuthorization?,
        rollbackAssessment: RuntimeGenerationRollbackRecord?,
        reservationLifetimeMilliseconds: Int64
    ) async throws -> RuntimeGenerationActivationResult {
        guard barrierAuthority === source.resolved.barrierAuthority else {
            throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
        }
        let operationKind: RuntimeGenerationOperationKind
        if restorationBackup == nil {
            operationKind = .migration
        } else if rollbackAssessment == nil {
            operationKind = .restore
        } else {
            operationKind = .rollback
        }
        guard (restorationBackup == nil) == (recoveryAuthorization == nil) else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        if let restorationBackup, let recoveryAuthorization {
            let authorizationMatches: Bool
            if let rollbackAssessment {
                authorizationMatches =
                    recoveryAuthorization.action == .rollbackToSafetyBackup &&
                    recoveryAuthorization.targetDigest == rollbackAssessment.rollbackDigest
            } else {
                authorizationMatches =
                    recoveryAuthorization.action == .restoreVerifiedBackup &&
                    recoveryAuthorization.targetDigest == restorationBackup.backupDigest
            }
            guard authorizationMatches else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
        } else if rollbackAssessment != nil {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        let startedAt = try nowMilliseconds()
        guard reservationLifetimeMilliseconds > 10 else {
            throw RuntimeGenerationControlError.malformed(field: "reservation_lifetime")
        }
        let generationID = try RuntimeStoreGenerationID(validating: nextID())
        let backupID = nextID()
        let backupPreparationID = nextID()
        let candidatePreparationID = nextID()
        let replayAuditID = nextID()
        let backupStagingToken = nextID()
        let reservationID = nextID()
        let runID = nextID()
        let executorID = nextID()
        let verificationID = nextID()
        let verifierID = nextID()
        let intentID = nextID()
        let stagingToken = nextID()
        let temporaryToken = nextID()
        let rollbackToken = nextID()
        let barrierToken = nextID()
        let vaultRestoreQuarantineToken = nextID()
        let vaultSnapshotHoldToken = nextID()
        let restoreBaselinePlanID = restorationBackup == nil ? nil : nextID()
        let sourceManifest = source.resolved.candidate.authorityManifest
        let sourceSelector = source.resolved.selector
        let locations = await generationManager.locations
        let stagingURL = locations.stagingDirectoryURL(
            for: generationID,
            token: stagingToken
        )
        let hiddenBackupDirectoryName =
            ".preparing-backup-\(backupID)-\(backupStagingToken)"
        let reservationCreatedAt = startedAt
        let reservation = try RuntimeGenerationControlRecordFactory.reservation(
            id: reservationID,
            operationKind: operationKind,
            candidateGenerationID: generationID,
            sourceGenerationID: sourceSelector.generationID,
            sourceGenerationDigest: sourceManifest.manifestDigest,
            expectedActiveManifestDigest: source.resolved.selectorFileSHA256,
            createdAtMilliseconds: reservationCreatedAt
        )
        var operationLease = try await issueInitialOperationLease(
            reservation: reservation,
            ownerInstanceID: executorID,
            requestedLifetimeMilliseconds: reservationLifetimeMilliseconds
        )
        let backupPreparation = try RuntimeGenerationControlRecordFactory
            .backupPreparation(
                id: backupPreparationID,
                backupID: backupID,
                reservation: reservation,
                operationLease: operationLease,
                sourceGenerationID: sourceSelector.generationID,
                sourceGenerationDigest: sourceManifest.manifestDigest,
                expectedActiveManifestDigest: source.resolved.selectorFileSHA256,
                hiddenDirectoryName: hiddenBackupDirectoryName,
                createdAtMilliseconds: reservationCreatedAt
            )
        let candidatePreparation = try RuntimeGenerationControlRecordFactory
            .candidatePreparation(
                id: candidatePreparationID,
                reservation: reservation,
                operationLease: operationLease,
                stagingDirectoryName: stagingURL.lastPathComponent
            )
        try await controlStore.recordReservationAndInitialOperationLease(
            reservation: reservation,
            lease: operationLease,
            backupPreparation: backupPreparation,
            candidatePreparation: candidatePreparation
        )

        try ensureProtectedDirectory(
            locations.backupsURL,
            containedIn: locations.rootURL,
            artifact: "generation_backups_root"
        )
        let backupDirectoryURL = locations.backupsURL.appendingPathComponent(
            hiddenBackupDirectoryName,
            isDirectory: true
        )
        try createPinnedPreparationDirectory(
            named: hiddenBackupDirectoryName,
            in: locations.backupsURL,
            artifact: "generation_backup_preparation_directory"
        )
        let backupDatabaseURL = backupDirectoryURL.appendingPathComponent(
            "Runtime.sqlite",
            isDirectory: false
        )
        // Begin before SQLite establishes its read snapshot. The vault's
        // lifetime process lock excludes other owners; this actor-reentrancy
        // hold prevents this process's GC from moving any referenced immutable
        // blob until authentication and protected backup copy both finish.
        try await vault.beginMigrationSnapshotHold(token: vaultSnapshotHoldToken)
        let preservedBackup: RuntimeGenerationPreservedBackup<
            RuntimeGenerationPreservedVaultAuthority
        >
        do {
            let backupWork = try await withRenewableOperationLease(
                initialLease: operationLease
            ) {
                try await source.createMigrationBackup(
                    at: backupDatabaseURL
                ) { sourceSnapshot in
                    try RuntimeStoreFileDurability.applyCompleteProtection(
                        at: backupDatabaseURL,
                        artifact: "generation_backup_database"
                    )
                    try RuntimeStoreFileDurability.synchronizeFile(at: backupDatabaseURL)
                    let verified = try await self.withVerifiedReadOnlyDatabase(
                        at: backupDatabaseURL
                    ) { backupVerification in
                        try await RuntimeGenerationDatabaseAuthority.requireMetadata(
                            in: backupVerification,
                            generationID: sourceSelector.generationID,
                            createdAtMilliseconds: sourceManifest.createdAtMilliseconds
                        )
                        let fence = try await RuntimeGenerationDatabaseAuthority.revisionFence(
                            in: backupVerification,
                            generationID: sourceSelector.generationID,
                            generationDigest: sourceManifest.manifestDigest
                        )
                        let equivalence = try await RuntimeGenerationDatabaseAuthority
                            .migrationEquivalenceDigest(in: backupVerification)
                        let verifiedVault = try await RuntimeGenerationVaultGraphVerifier.verify(
                            database: backupVerification,
                            vault: vault,
                            vaultRootURL: locations.attachmentVaultURL,
                            keyCustody: keyCustody
                        )
                        let copiedVault = try RuntimeGenerationVaultGraphVerifier
                            .copyToProtectedBackup(
                                verifiedVault,
                                sourceRootURL: locations.attachmentVaultURL,
                                backupRootURL: backupDirectoryURL.appendingPathComponent(
                                    "Vault", isDirectory: true
                                )
                            )
                        return (fence, equivalence, copiedVault)
                    }
                    guard verified.0 == sourceSnapshot.fence,
                          verified.1 == sourceSnapshot.semanticEquivalenceDigest else {
                        throw RuntimeGenerationControlError.restoreSourceUnverified
                    }
                    try RuntimeStoreFileDurability.synchronizeDirectory(at: backupDirectoryURL)
                    return RuntimeGenerationPreservedVaultAuthority(
                        observedBackupFence: verified.0,
                        observedSemanticEquivalenceDigest: verified.1,
                        vaultSnapshot: verified.2
                    )
                }
            }
            preservedBackup = backupWork.result
            operationLease = backupWork.lease
        } catch {
            let operationError = error
            do {
                try await vault.endMigrationSnapshotHold(token: vaultSnapshotHoldToken)
            } catch {
                throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
            }
            throw operationError
        }
        try await vault.endMigrationSnapshotHold(token: vaultSnapshotHoldToken)
        let sourceSnapshot = preservedBackup.databaseSnapshot
        if let rollbackAssessment,
           rollbackAssessment.targetObservedFence != sourceSnapshot.fence {
            throw RuntimeGenerationControlError.rollbackUnsafe
        }
        let sourceVaultSnapshot = preservedBackup.preservedAuthority.vaultSnapshot
        let backupArtifact = try RuntimeGenerationDatabaseAuthority.artifact(
            at: backupDatabaseURL,
            relativePath: "Runtime.sqlite"
        )
        guard preservedBackup.preservedAuthority.observedBackupFence == sourceSnapshot.fence,
              preservedBackup.preservedAuthority.observedSemanticEquivalenceDigest ==
                sourceSnapshot.semanticEquivalenceDigest else {
            throw RuntimeGenerationControlError.restoreSourceUnverified
        }
        let backupCreatedAt = nondecreasingTimestamp(
            after: startedAt,
            proposed: try nowMilliseconds()
        )
        let backup = try RuntimeGenerationControlRecordFactory.backup(
            id: backupID,
            sourceGenerationID: sourceSelector.generationID,
            sourceGenerationDigest: sourceManifest.manifestDigest,
            sourceFence: sourceSnapshot.fence,
            authorityFenceToken: sourceSnapshot.authorityFenceToken,
            databaseArtifact: backupArtifact.semantic,
            sourceWALArtifact: nil,
            blobSetDigest: sourceVaultSnapshot.blobSetDigest,
            attachmentManifestSetDigest: sourceVaultSnapshot.manifestSetDigest,
            keyIdentityDigest: sourceVaultSnapshot.keyIdentityDigest,
            vaultArtifacts: sourceVaultSnapshot.artifacts,
            counts: sourceSnapshot.counts,
            boundaries: sourceSnapshot.boundaries,
            semanticEquivalenceDigest: sourceSnapshot.semanticEquivalenceDigest,
            createdAtMilliseconds: backupCreatedAt
        )
        let backupEvidenceWork = try await withRenewableOperationLease(
            initialLease: operationLease
        ) {
            try await self.preparedBackupDirectoryEvidence(
                at: backupDirectoryURL,
                backup: backup
            )
        }
        let backupEvidence = backupEvidenceWork.result
        operationLease = backupEvidenceWork.lease
        let backupCompletionAt = max(
            operationLease.issuedAtMilliseconds,
            try nowMilliseconds()
        )
        let backupCompletion = try RuntimeGenerationControlRecordFactory
            .backupPreparationCompletion(
                preparationID: backupPreparationID,
                backup: backup,
                directoryDevice: backupEvidence.identity.device,
                directoryInode: backupEvidence.identity.inode,
                interiorArtifactCount: backupEvidence.artifactCount,
                interiorByteCount: backupEvidence.byteCount,
                interiorInventoryDigest: backupEvidence.inventoryDigest,
                durabilityWitnessDigest: backupEvidence.durabilityWitnessDigest,
                completedAtMilliseconds: backupCompletionAt
            )
        try await controlStore.recordBackupPreparationCompletion(
            backupCompletion,
            currentLease: operationLease
        )
        let publishedBackupIdentity = try publishPreparedDirectory(
            preparation: backupPreparation,
            expectedIdentity: backupEvidence.identity,
            parentURL: locations.backupsURL
        )
        let consumedBackup = try await controlStore.consumeCompletedBackupPreparation(
            preparationID: backupPreparationID,
            currentLease: operationLease,
            finalDirectoryDevice: publishedBackupIdentity.device,
            finalDirectoryInode: publishedBackupIdentity.inode,
            consumedAtMilliseconds: backupCompletionAt
        )
        guard consumedBackup == backup else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
        let candidateInputBackup = restorationBackup ?? backup
        let candidateSnapshot = RuntimeGenerationSourceBackupSnapshot(
            fence: candidateInputBackup.sourceFence,
            authorityFenceToken: candidateInputBackup.authorityFenceToken,
            counts: candidateInputBackup.counts,
            boundaries: candidateInputBackup.boundaries,
            semanticEquivalenceDigest: candidateInputBackup.semanticEquivalenceDigest
        )
        let candidateVaultSnapshot = RuntimeGenerationVerifiedVaultSnapshot(
            blobSetDigest: candidateInputBackup.blobSetDigest,
            manifestSetDigest: candidateInputBackup.attachmentManifestSetDigest,
            keyIdentityDigest: candidateInputBackup.keyIdentityDigest,
            artifacts: candidateInputBackup.vaultArtifacts
        )
        let candidateBackupDirectoryURL = locations.backupsURL.appendingPathComponent(
            candidateInputBackup.backupID,
            isDirectory: true
        )
        try RuntimeStorePathValidation.requireSafeComponent(candidateInputBackup.backupID)
        try RuntimeStorePathValidation.requireContained(
            candidateBackupDirectoryURL,
            in: locations.backupsURL
        )
        let candidateBackupDatabaseURL = candidateBackupDirectoryURL.appendingPathComponent(
            candidateInputBackup.databaseArtifact.relativePath,
            isDirectory: false
        )
        guard try RuntimeGenerationDatabaseAuthority.artifact(
            at: candidateBackupDatabaseURL,
            relativePath: candidateInputBackup.databaseArtifact.relativePath
        ).semanticallyMatches(candidateInputBackup.databaseArtifact) else {
            throw RuntimeGenerationControlError.restoreSourceUnverified
        }
        let candidateInputRecord = try await controlStore.generationRecord(
            id: candidateInputBackup.sourceGenerationID
        )
        guard candidateInputRecord.authorityManifest.manifestDigest ==
                candidateInputBackup.sourceGenerationDigest else {
            throw RuntimeGenerationControlError.restoreSourceUnverified
        }
        if restorationBackup != nil {
            try await RuntimeGenerationVaultGraphVerifier.verifyProtectedBackup(
                candidateVaultSnapshot,
                backupDirectoryURL: candidateBackupDirectoryURL,
                keyCustody: keyCustody
            )
        }
        try RuntimeStorePathValidation.requireContained(stagingURL, in: locations.storesURL)
        try createPinnedPreparationDirectory(
            named: stagingURL.lastPathComponent,
            in: locations.storesURL,
            artifact: "v8_migration_staging_generation"
        )
        let candidateDatabaseURL = stagingURL.appendingPathComponent(
            "Runtime.sqlite",
            isDirectory: false
        )
        let candidateCopy = try await withRenewableOperationLease(
            initialLease: operationLease
        ) {
            try await self.withVerifiedReadOnlyDatabase(
                at: candidateBackupDatabaseURL
            ) { backupSource in
                try await backupSource.backup(
                    to: candidateDatabaseURL,
                    prepareReservedDestination: { _, _, descriptor in
                        try RuntimeStoreFileDurability.applyCompleteProtection(
                            toOpenFileDescriptor: descriptor,
                            artifact: "v8_migration_candidate_database_reserved"
                        )
                    }
                )
            }
        }
        _ = candidateCopy.result
        operationLease = candidateCopy.lease
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: candidateDatabaseURL,
            artifact: "v8_migration_candidate_database"
        )
        let candidateCreatedAt = nondecreasingTimestamp(
            after: reservationCreatedAt,
            proposed: try nowMilliseconds()
        )
        let candidateDatabase = try SQLiteDatabase(
            url: candidateDatabaseURL,
            configuration: CanonicalRuntimeStore.sqliteConfiguration(openMode: .existingOnly)
        )
        let candidateTransformation = try await withRenewableOperationLease(
            initialLease: operationLease
        ) {
            do {
                try await candidateDatabase.transaction(.exclusive) { database in
                let metadata = try database.query(
                    "SELECT generation_id, created_at_ms FROM runtime_store_metadata WHERE singleton_id = 1 LIMIT 2",
                    maximumDecodedBytes: RuntimeGenerationDatabaseAuthority.pageByteBudget
                )
                guard metadata.count == 1,
                      metadata[0].value(named: "generation_id") ==
                        .text(candidateInputBackup.sourceGenerationID.rawValue),
                      metadata[0].value(named: "created_at_ms") ==
                        .integer(candidateInputRecord.authorityManifest.createdAtMilliseconds) else {
                    throw RuntimeGenerationControlError.restoreSourceUnverified
                }
                try database.execute(
                    "UPDATE runtime_store_metadata SET generation_id = ?, created_at_ms = ? WHERE singleton_id = 1",
                    bindings: [.text(generationID.rawValue), .integer(candidateCreatedAt)]
                )
                try CanonicalRuntimeAttachmentSchemaPlan.requireIntegratedSchema(in: database)
                }
                let checkpoint = try await candidateDatabase.checkpoint(.truncate)
                guard checkpoint.logFrameCount == checkpoint.checkpointedFrameCount else {
                    throw LocalRuntimeStorageError.canonicalIntegrityFailure
                }
                let equivalence = try await RuntimeGenerationDatabaseAuthority
                    .migrationEquivalenceDigest(in: candidateDatabase)
                guard equivalence == candidateSnapshot.semanticEquivalenceDigest else {
                    throw RuntimeGenerationControlError.verificationRejected
                }
                try await candidateDatabase.close()
                return ()
            } catch {
                let operationError = error
                do { try await candidateDatabase.close() }
                catch {
                    throw LocalRuntimeStorageError.canonicalIOFailure(
                        operation: "close_migration_candidate_database"
                    )
                }
                throw operationError
            }
        }
        _ = candidateTransformation.result
        operationLease = candidateTransformation.lease
        try RuntimeStoreFileDurability.synchronizeFile(at: candidateDatabaseURL)
        let candidateArtifact = try RuntimeGenerationDatabaseAuthority.artifact(at: candidateDatabaseURL, relativePath: "Runtime.sqlite")
        let runCompletedAt = nondecreasingTimestamp(
            after: candidateCreatedAt,
            proposed: try nowMilliseconds()
        )
        let provenanceDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: "v8-descendant-v2\n\(operationKind.rawValue)\n\(backup.backupDigest)\n\(candidateInputBackup.backupDigest)\n\(candidateSnapshot.semanticEquivalenceDigest)\n\(candidateArtifact.sha256)"
        )
        operationLease = try await renewOperationLeaseIfNeeded(
            operationLease,
            force: true
        )
        let run = try RuntimeGenerationControlRecordFactory.migrationRun(
            id: runID,
            executorInstanceID: executorID,
            reservationID: reservationID,
            operationLeaseID: operationLease.leaseID,
            operationLeaseEpoch: operationLease.leaseEpoch,
            operationFencingToken: operationLease.fencingToken,
            sourceSafetyBackupID: backupID,
            backupID: candidateInputBackup.backupID,
            recoveryAuthorizationID: recoveryAuthorization?.authorizationID,
            recoveryAuthorizationDigest: recoveryAuthorization?.authorizationDigest,
            operationKind: operationKind,
            sourceSchemaVersion: runtimeCanonicalAttachmentSchemaVersion,
            candidateGenerationID: generationID,
            transformationVersion: 1,
            provenanceDigest: provenanceDigest,
            startedAtMilliseconds: candidateCreatedAt,
            completedAtMilliseconds: runCompletedAt
        )
        try await controlStore.recordMigrationRun(run)
        let finalized = try await finalizePostTransformCandidate(
            input: RuntimeGenerationCandidatePostTransformFinalizationInput(
                operationKind: operationKind, reservation: reservation,
                candidatePreparation: candidatePreparation, migrationRun: run,
                candidateDirectoryURL: stagingURL,
                candidateCreatedAtMilliseconds: candidateCreatedAt,
                expectedCandidateSnapshot: candidateSnapshot,
                requiresExactCandidateInventory: true,
                manifestSourceFence: sourceSnapshot.fence,
                sourceGenerationID: sourceSelector.generationID,
                sourceGenerationDigest: sourceManifest.manifestDigest,
                sourceEncryptionScheme: candidateInputRecord.authorityManifest.encryptionScheme,
                blobSetDigest: candidateVaultSnapshot.blobSetDigest,
                attachmentManifestSetDigest: candidateVaultSnapshot.manifestSetDigest,
                keyIdentityDigest: candidateVaultSnapshot.keyIdentityDigest,
                verificationID: verificationID, activationIntentID: intentID,
                relativeDatabasePath: locations.relativeDatabasePath(for: generationID),
                priorGenerationID: sourceSelector.generationID,
                priorAuthorityManifestDigest: sourceManifest.manifestDigest,
                expectedReplayStateDigest: nil, replayAuditID: replayAuditID
            ), initialLease: operationLease
        )
        operationLease = finalized.operationLease
        let candidate = finalized.candidate
        let candidateCompletion = finalized.candidatePreparationCompletion
        let selectorData = finalized.selectorBytes
        let selectorSHA = candidate.selectorFileSHA256
        let manifest = candidate.authorityManifest
        let candidateReplayAuditStateDigest = finalized.replayStateDigest
        try await controlStore.recordGeneration(candidate)
        try await controlStore.recordCandidatePreparationCompletion(
            candidateCompletion,
            currentLease: operationLease
        )
        operationLease = try await renewOperationLeaseIfNeeded(
            operationLease,
            force: true
        )
        let verification = try await withRenewableOperationLease(
            initialLease: operationLease
        ) {
            try await self.verifyCandidateWithFreshConnections(
                candidate: candidate,
                reservation: reservation,
                run: run,
                databaseURL: candidateDatabaseURL,
                verificationID: verificationID,
                verifierID: verifierID,
                vaultInventory: nil,
                vaultRootURL: locations.attachmentVaultURL,
                keyCustody: keyCustody,
                expectedSourceSnapshot: candidateSnapshot,
                sourceManifest: candidateInputRecord.authorityManifest,
                vault: restorationBackup == nil ? vault : nil,
                expectedVaultSnapshot: candidateVaultSnapshot,
                expectedCandidateReplayStateDigest: candidateReplayAuditStateDigest
            )
        }
        let report = verification.result
        operationLease = verification.lease
        operationLease = try await renewOperationLeaseIfNeeded(
            operationLease,
            force: true
        )
        try await controlStore.recordVerification(report)
        let verifiedTransition = try RuntimeGenerationControlRecordFactory.retentionTransition(
            id: nextID(),
            generationID: generationID,
            fromClass: .staged,
            toClass: .freshConnectionVerified,
            reasonCode: "fresh_connection_v8_descendant_verification",
            authorityDigest: report.reportDigest,
            occurredAtMilliseconds: report.verifiedAtMilliseconds
        )
        try await controlStore.recordRetentionTransition(verifiedTransition)
        let restoreBaselinePlan: RuntimeGenerationRestoreBaselinePlan?
        if let recoveryAuthorization, let restoreBaselinePlanID {
            let preparedAt = nondecreasingTimestamp(
                after: report.verifiedAtMilliseconds,
                proposed: try nowMilliseconds()
            )
            guard preparedAt < recoveryAuthorization.expiresAtMilliseconds else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
            let plan = try RuntimeGenerationControlRecordFactory.restoreBaselinePlan(
                id: restoreBaselinePlanID,
                sourceGenerationID: sourceSelector.generationID,
                sourceGenerationDigest: sourceManifest.manifestDigest,
                sourceSafetyBackupID: backup.backupID,
                sourceSafetyFenceDigest: sourceSnapshot.fence.fenceDigest,
                targetGenerationID: generationID,
                targetVerificationID: report.verificationID,
                targetActivationBaselineDigest: manifest.activationBaseline.baselineDigest,
                recoveryAuthorizationID: recoveryAuthorization.authorizationID,
                recoveryAuthorizationDigest: recoveryAuthorization.authorizationDigest,
                preparedAtMilliseconds: preparedAt
            )
            try await controlStore.recordRestoreBaselinePlan(plan)
            restoreBaselinePlan = plan
        } else {
            guard recoveryAuthorization == nil, restoreBaselinePlanID == nil else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
            restoreBaselinePlan = nil
        }
        let intentCreatedAt = nondecreasingTimestamp(
            after: report.verifiedAtMilliseconds,
            proposed: try nowMilliseconds()
        )
        let intent = try RuntimeGenerationControlRecordFactory.activationIntent(
            id: intentID,
            reservation: reservation,
            verification: report,
            createdAtMilliseconds: intentCreatedAt,
            expiresAtMilliseconds: try shortActivationIntentExpiry(
                createdAtMilliseconds: intentCreatedAt
            )
        )
        try await controlStore.recordActivationIntent(intent)
        let activeTransitionID = nextID()
        let barrier = try await barrierAuthority.acquireFinalBarrier(
            token: barrierToken,
            expectedGenerationID: sourceSelector.generationID
        )
        var barrierHeld = true
        var preserveBarrierForRecovery = false
        do {
            try await requireCurrentOperationLease(operationLease)
            let publicationLease = operationLease
            let activation = try await generationManager.publishVerifiedGeneration(
                candidateDirectoryURL: stagingURL,
                candidate: candidate,
                candidatePreparationCompletion: candidateCompletion,
                selectorData: selectorData,
                controlStore: controlStore,
                operationLease: publicationLease,
                activationIntentID: intent.intentID,
                expectedPriorSelectorFileSHA256: source.resolved.selectorFileSHA256,
                sourceStore: source,
                expectedSourceFence: sourceSnapshot.fence,
                expectedSourceAuthorityFenceToken: sourceSnapshot.authorityFenceToken,
                recoveryAuthorization: recoveryAuthorization,
                recoveryResultDigest: restoreBaselinePlan?.planDigest,
                vaultRestoreRequest: restorationBackup.map { _ in
                    RuntimeGenerationVaultRestoreRequest(
                        snapshot: candidateVaultSnapshot,
                        backupDirectoryURL: candidateBackupDirectoryURL,
                        vaultRootURL: locations.attachmentVaultURL,
                        quarantineRootURL: locations.quarantineURL,
                        quarantineToken: vaultRestoreQuarantineToken
                    )
                },
                postCommitJournal: { committedAtMilliseconds in
                    do {
                        let consumedAt = max(
                            intent.createdAtMilliseconds, committedAtMilliseconds
                        )
                        let consumption = try RuntimeGenerationControlRecordFactory
                            .activationConsumption(
                                intent: intent,
                                consumedAtMilliseconds: consumedAt,
                                installedSelectorFileSHA256: selectorSHA,
                                priorGenerationID: sourceSelector.generationID,
                                priorGenerationDigest: sourceManifest.manifestDigest
                            )
                        guard verifiedTransition.occurredAtMilliseconds < Int64.max else {
                            return false
                        }
                        let activeTransition = try RuntimeGenerationControlRecordFactory
                            .retentionTransition(
                                id: activeTransitionID,
                                generationID: generationID,
                                fromClass: .freshConnectionVerified,
                                toClass: .active,
                                reasonCode: "selector_consumed",
                                authorityDigest: consumption.consumptionDigest,
                                occurredAtMilliseconds: max(
                                    verifiedTransition.occurredAtMilliseconds + 1,
                                    consumedAt
                                )
                            )
                        let predecessorTransition = try RuntimeGenerationControlRecordFactory
                            .retentionTransition(
                                id: "demote-active-\(intent.intentID)",
                                generationID: sourceSelector.generationID,
                                fromClass: .active,
                                toClass: .verifiedRollback,
                                reasonCode: "superseded_by_selector",
                                authorityDigest: consumption.consumptionDigest,
                                occurredAtMilliseconds: consumedAt
                            )
                        let recoveryConsumption: RuntimeGenerationRecoveryAuthorizationConsumption?
                        if let restoreBaselinePlan, let recoveryAuthorization {
                            recoveryConsumption = try RuntimeGenerationControlRecordFactory
                                .recoveryAuthorizationConsumption(
                                    authorization: recoveryAuthorization,
                                    resultDigest: restoreBaselinePlan.planDigest,
                                    consumedAtMilliseconds: consumedAt
                                )
                        } else {
                            recoveryConsumption = nil
                        }
                        let candidateDisposition = try RuntimeGenerationControlRecordFactory
                            .candidatePreparationDisposition(
                                preparationID: candidatePreparationID,
                                operationLeaseID: publicationLease.leaseID,
                                operationFencingToken: publicationLease.fencingToken,
                                kind: .activated,
                                authorityDigest: consumption.consumptionDigest,
                                disposedAtMilliseconds: consumedAt
                            )
                        try await controlStore.finalizeCommittedActivation(
                            consumption: consumption,
                            retentionTransition: activeTransition,
                            predecessorRetentionTransition: predecessorTransition,
                            recoveryConsumption: recoveryConsumption,
                            candidateDisposition: candidateDisposition,
                            observedIntent: intent,
                            observedVerification: report,
                            nowMilliseconds: consumedAt
                        )
                        return true
                    } catch {
                        return false
                    }
                },
                temporaryToken: temporaryToken,
                rollbackToken: rollbackToken
            )
            if activation.isolationCleanupRequired,
               activation.activationState.isDefinitelyUncommittedOrUnknown {
                preserveBarrierForRecovery = true
                throw LocalRuntimeStorageError.canonicalActivationIsolationIndeterminate
            }
            let warning: Bool
            switch activation.activationState {
            case .committed: warning = false
            case .committedWithCleanupWarning: warning = true
            case let .unchanged(error):
                barrierHeld = false
                try await barrierAuthority.releaseUnchanged(barrier)
                throw error
            case .unknown:
                preserveBarrierForRecovery = true
                throw LocalRuntimeStorageError.canonicalActivationStateUnknown
            }
            var barrierReconciliationRequired = false
            do {
                try await barrierAuthority.advance(from: barrier, to: generationID)
                barrierHeld = false
            } catch {
                preserveBarrierForRecovery = true
                barrierReconciliationRequired = true
            }
            return RuntimeGenerationActivationResult(
                generationID: generationID,
                selectorFileSHA256: selectorSHA,
                authorityManifestDigest: manifest.manifestDigest,
                verificationID: verificationID,
                activationIntentID: intentID,
                restoreBaselinePlanID: restoreBaselinePlan?.planID,
                committedWithCleanupWarning: warning,
                controlReconciliationRequired: activation.postCommitJournalSucceeded == false,
                barrierReconciliationRequired: barrierReconciliationRequired,
                isolationCleanupRequired: activation.isolationCleanupRequired
            )
        } catch {
            if barrierHeld && preserveBarrierForRecovery == false {
                try await barrierAuthority.releaseUnchanged(barrier)
            }
            throw error
        }
    }
}

extension RuntimeGenerationLifecycleService {
    func withRenewableOperationLease<Result: Sendable>(
        initialLease: RuntimeGenerationOperationLease,
        operation: @escaping @Sendable () async throws -> Result
    ) async throws -> (result: Result, lease: RuntimeGenerationOperationLease) {
        let state = RuntimeGenerationRenewableLeaseState(initialLease)
        return try await withThrowingTaskGroup(
            of: RuntimeGenerationLeaseOperationEvent<Result>.self
        ) { group in
            group.addTask { [environment] in
                while Task.isCancelled == false {
                    let prior = await state.lease()
                    let observedAt = try self.nowMilliseconds()
                    guard observedAt >= prior.issuedAtMilliseconds,
                          observedAt < prior.expiresAtMilliseconds else {
                        throw RuntimeGenerationControlError.reservationExpired
                    }
                    let remaining = prior.expiresAtMilliseconds - observedAt
                    if remaining <= 3 {
                        let renewed = try await self.renewOperationLeaseIfNeeded(
                            prior,
                            force: true
                        )
                        await state.replace(with: renewed)
                        continue
                    }
                    // Sleep for one third of the *current* lease's remaining
                    // validity. This keeps the wake-up strictly before the
                    // half-open expiry boundary even when the caller requested
                    // an initial lease shorter than the runtime maximum.
                    let delay = max(1, remaining / 3)
                    try await environment.sleeper.sleep(milliseconds: delay)
                    try Task.checkCancellation()
                    let renewed = try await self.renewOperationLeaseIfNeeded(
                        prior,
                        force: true
                    )
                    await state.replace(with: renewed)
                }
                return .heartbeatStopped
            }
            group.addTask {
                .operation(try await operation())
            }
            do {
                guard let first = try await group.next() else {
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
                switch first {
                case let .operation(result):
                    group.cancelAll()
                    do {
                        while try await group.next() != nil {}
                    } catch is CancellationError {
                        // Suppress the heartbeat child's cancellation only.
                        // A cancellation of the owning operation must remain
                        // fail-closed and may not become a successful result.
                        try Task.checkCancellation()
                    }
                    let latest = await state.lease()
                    try await requireCurrentOperationLease(latest)
                    return (result, latest)
                case .heartbeatStopped:
                    group.cancelAll()
                    throw RuntimeGenerationControlError.controlAuthorityUnavailable
                }
            } catch {
                group.cancelAll()
                throw error
            }
        }
    }

    func issueInitialOperationLease(
        reservation: RuntimeGenerationReservation,
        ownerInstanceID: String,
        requestedLifetimeMilliseconds: Int64
    ) async throws -> RuntimeGenerationOperationLease {
        let issuedAt = max(reservation.createdAtMilliseconds, try nowMilliseconds())
        let duration = min(
            requestedLifetimeMilliseconds,
            runtimeGenerationMaximumOperationLeaseMilliseconds
        )
        guard duration > 0, issuedAt <= Int64.max - duration else {
            throw RuntimeGenerationControlError.malformed(field: "operation_lease_lifetime")
        }
        let lease = try RuntimeGenerationControlRecordFactory.operationLease(
            id: nextID(),
            reservationID: reservation.reservationID,
            ownerInstanceID: ownerInstanceID,
            leaseEpoch: 1,
            fencingToken: 1,
            priorLeaseDigest: nil,
            issuedAtMilliseconds: issuedAt,
            expiresAtMilliseconds: issuedAt + duration
        )
        return lease
    }

    func renewOperationLeaseIfNeeded(
        _ lease: RuntimeGenerationOperationLease,
        force: Bool
    ) async throws -> RuntimeGenerationOperationLease {
        let observedAt = try nowMilliseconds()
        let renewalWindow = min(
            2 * 60 * 1_000,
            runtimeGenerationMaximumOperationLeaseMilliseconds / 2
        )
        guard force || lease.expiresAtMilliseconds - observedAt <= renewalWindow else {
            try await requireCurrentOperationLease(lease)
            return lease
        }
        guard observedAt >= lease.issuedAtMilliseconds,
              observedAt < lease.expiresAtMilliseconds,
              lease.leaseEpoch < Int64.max,
              observedAt <= Int64.max - runtimeGenerationMaximumOperationLeaseMilliseconds else {
            throw RuntimeGenerationControlError.reservationExpired
        }
        let renewed = try RuntimeGenerationControlRecordFactory.operationLease(
            id: nextID(),
            reservationID: lease.reservationID,
            ownerInstanceID: lease.ownerInstanceID,
            leaseEpoch: lease.leaseEpoch + 1,
            fencingToken: lease.fencingToken,
            priorLeaseDigest: lease.leaseDigest,
            issuedAtMilliseconds: observedAt,
            expiresAtMilliseconds:
                observedAt + runtimeGenerationMaximumOperationLeaseMilliseconds
        )
        try await controlStore.recordOperationLease(renewed)
        return renewed
    }

    func takeOverExpiredOperationLease(
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
            id: nextID(),
            reservationID: reservationID,
            ownerInstanceID: nextID(),
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

    func requireCurrentOperationLease(
        _ expected: RuntimeGenerationOperationLease
    ) async throws {
        let observed = try await controlStore.requireCurrentOperationLease(
            reservationID: expected.reservationID,
            ownerInstanceID: expected.ownerInstanceID,
            observedAtMilliseconds: try nowMilliseconds()
        )
        guard observed == expected else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
    }

    func shortActivationIntentExpiry(
        createdAtMilliseconds: Int64
    ) throws -> Int64 {
        let lifetime: Int64 = 2 * 60 * 1_000
        guard createdAtMilliseconds >= 0,
              createdAtMilliseconds <= Int64.max - lifetime else {
            throw RuntimeGenerationControlError.malformed(
                field: "activation_intent_lifetime"
            )
        }
        return createdAtMilliseconds + lifetime
    }

    func withVerifiedReadOnlyDatabase<Result: Sendable>(
        at url: URL,
        operation: @Sendable (SQLiteDatabase) async throws -> Result
    ) async throws -> Result {
        let database = try await RuntimeGenerationDatabaseAuthority.verifyExactV8ReadOnly(
            at: url
        )
        let result: Result
        do {
            result = try await operation(database)
            try await database.revalidateReadOnlySourceNamespace()
        } catch {
            let operationError = error
            do {
                try await database.close()
            } catch {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_generation_verification_database"
                )
            }
            throw operationError
        }
        do {
            try await database.close()
        } catch {
            throw LocalRuntimeStorageError.canonicalIOFailure(
                operation: "close_generation_verification_database"
            )
        }
        return result
    }

    func verifyCandidateWithFreshConnections(
        candidate: RuntimeGenerationCandidateRecord,
        reservation: RuntimeGenerationReservation,
        run: RuntimeGenerationMigrationRun,
        databaseURL: URL,
        verificationID: String,
        verifierID: String,
        vaultInventory: RuntimeGenerationVaultInventory?,
        vaultRootURL: URL,
        keyCustody: any RuntimeAttachmentKeyCustody,
        expectedSourceSnapshot: RuntimeGenerationSourceBackupSnapshot?,
        sourceManifest: RuntimeGenerationAuthorityManifest?,
        vault: RuntimeAttachmentVault?,
        expectedVaultSnapshot: RuntimeGenerationVerifiedVaultSnapshot?,
        expectedCandidateReplayStateDigest: String? = nil
    ) async throws -> RuntimeGenerationVerificationReport {
        let ownership = try await generationManager.acquireVerificationCandidateOwnership(
            reservation: reservation,
            run: run,
            candidateDirectoryURL: databaseURL.deletingLastPathComponent(),
            authorityNowMilliseconds: try nowMilliseconds()
        )
        let pinnedFiles = try RuntimeStorePinnedFileSet.capture(databaseURL: databaseURL)
        var ownershipOpen = true
        do {
            let report = try await ownership.withHeldLease(
                pinnedFiles: pinnedFiles
            ) {
                try await verifyCandidateAcrossFreshConnections(
                    candidate: candidate,
                    reservation: reservation,
                    run: run,
                    databaseURL: databaseURL,
                    verificationID: verificationID,
                    verifierID: verifierID,
                    vaultInventory: vaultInventory,
                    vaultRootURL: vaultRootURL,
                    keyCustody: keyCustody,
                    expectedSourceSnapshot: expectedSourceSnapshot,
                    sourceManifest: sourceManifest,
                    vault: vault,
                    expectedVaultSnapshot: expectedVaultSnapshot,
                    expectedCandidateReplayStateDigest: expectedCandidateReplayStateDigest
                )
            }
            ownershipOpen = false
            try await ownership.close()
            return report
        } catch {
            let operationError = error
            if ownershipOpen {
                ownershipOpen = false
                do { try await ownership.close() }
                catch {
                    throw LocalRuntimeStorageError.canonicalActivationLockFailed
                }
            }
            throw operationError
        }
    }

    /// Process-local verification with two separately constructed SQLite
    /// connections. This proves fresh-connection equivalence, not a restart or
    /// independent process/fault domain.
    func verifyCandidateAcrossFreshConnections(
        candidate: RuntimeGenerationCandidateRecord,
        reservation: RuntimeGenerationReservation,
        run: RuntimeGenerationMigrationRun,
        databaseURL: URL,
        verificationID: String,
        verifierID: String,
        vaultInventory: RuntimeGenerationVaultInventory?,
        vaultRootURL: URL,
        keyCustody: any RuntimeAttachmentKeyCustody,
        expectedSourceSnapshot: RuntimeGenerationSourceBackupSnapshot?,
        sourceManifest: RuntimeGenerationAuthorityManifest?,
        vault: RuntimeAttachmentVault?,
        expectedVaultSnapshot: RuntimeGenerationVerifiedVaultSnapshot?,
        expectedCandidateReplayStateDigest: String? = nil
    ) async throws -> RuntimeGenerationVerificationReport {
        let verifier = try RuntimeGenerationFreshConnectionVerifier(
            verifierInstanceID: verifierID,
            executorInstanceID: run.executorInstanceID
        )
        let firstPass = try await withVerifiedReadOnlyDatabase(at: databaseURL) { first in
            try await RuntimeGenerationDatabaseAuthority.requireMetadata(
                in: first,
                generationID: candidate.authorityManifest.generationID,
                createdAtMilliseconds: candidate.authorityManifest.createdAtMilliseconds
            )
            let replay = try await first.transaction(.deferred) { database in
                try RuntimeCanonicalReplayEngine.reconstructInTransaction(database: database)
            }
            let inventory = try await RuntimeGenerationDatabaseAuthority.manifestInventory(
                in: first
            )
            return (replay, inventory)
        }
        let replayStateDigest: String
        switch firstPass.0 {
        case let .complete(reconstruction):
            if expectedSourceSnapshot == nil, reconstruction != .empty {
                throw RuntimeGenerationControlError.verificationRejected
            }
            replayStateDigest = reconstruction.stateDigest
        case .blocked:
            throw RuntimeGenerationControlError.verificationRejected
        }
        if let expectedCandidateReplayStateDigest,
           replayStateDigest != expectedCandidateReplayStateDigest {
            throw RuntimeGenerationControlError.verificationRejected
        }
        let firstInventory = firstPass.1
        let secondPass = try await withVerifiedReadOnlyDatabase(at: databaseURL) { second in
            let inventory = try await RuntimeGenerationDatabaseAuthority.manifestInventory(
                in: second
            )
            let fence = try await RuntimeGenerationDatabaseAuthority.revisionFence(
                in: second,
                generationID: candidate.authorityManifest.generationID,
                generationDigest:
                    candidate.authorityManifest.activationBaseline.candidateIdentityDigest
            )
            let equivalence = try await RuntimeGenerationDatabaseAuthority
                .migrationEquivalenceDigest(in: second)
            let verifiedVault: RuntimeGenerationVerifiedVaultSnapshot?
            if let vault {
                verifiedVault = try await RuntimeGenerationVaultGraphVerifier.verify(
                    database: second,
                    vault: vault,
                    vaultRootURL: vaultRootURL,
                    keyCustody: keyCustody
                )
            } else if expectedSourceSnapshot != nil {
                verifiedVault = expectedVaultSnapshot
            } else {
                verifiedVault = nil
            }
            return (inventory, fence, equivalence, verifiedVault)
        }
        let secondInventory = secondPass.0
        let candidateFence = secondPass.1
        let candidateEquivalenceDigest = secondPass.2
        let verifiedCandidateVault = secondPass.3
        guard firstInventory.0 == candidate.authorityManifest.counts,
              firstInventory.1 == candidate.authorityManifest.boundaries,
              secondInventory.0 == firstInventory.0,
              secondInventory.1 == firstInventory.1,
              try RuntimeGenerationDatabaseAuthority.artifact(
                at: databaseURL,
                relativePath: "Runtime.sqlite"
              ).semanticallyMatches(candidate.authorityManifest.database) else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        let vaultEvidenceMaterial: String
        if let expectedSourceSnapshot {
            guard let sourceManifest,
                  let expectedVaultSnapshot,
                  let verifiedCandidateVault,
                  firstInventory.0 == expectedSourceSnapshot.counts,
                  firstInventory.1 == expectedSourceSnapshot.boundaries,
                  candidateEquivalenceDigest == expectedSourceSnapshot.semanticEquivalenceDigest,
                  candidateFence == candidate.authorityManifest.activationBaseline.revisionFence,
                  candidateFence.eventSequence == expectedSourceSnapshot.fence.eventSequence,
                  candidateFence.eventID == expectedSourceSnapshot.fence.eventID,
                  candidateFence.eventHash == expectedSourceSnapshot.fence.eventHash,
                  candidateFence.commandCount == expectedSourceSnapshot.fence.commandCount,
                  candidateFence.receiptCount == expectedSourceSnapshot.fence.receiptCount,
                  candidateFence.receiptAuthorityDigest == expectedSourceSnapshot.fence.receiptAuthorityDigest,
                  candidateFence.externalOperationAuthorityDigest ==
                    expectedSourceSnapshot.fence.externalOperationAuthorityDigest,
                  candidateFence.attachmentAuthorityDigest ==
                    expectedSourceSnapshot.fence.attachmentAuthorityDigest,
                  candidate.authorityManifest.blobSetDigest ==
                    expectedVaultSnapshot.blobSetDigest,
                  candidate.authorityManifest.attachmentManifestSetDigest ==
                    expectedVaultSnapshot.manifestSetDigest,
                  candidate.authorityManifest.keyIdentityDigest ==
                    expectedVaultSnapshot.keyIdentityDigest,
                  candidate.authorityManifest.encryptionScheme == sourceManifest.encryptionScheme,
                  verifiedCandidateVault.blobSetDigest == expectedVaultSnapshot.blobSetDigest,
                  verifiedCandidateVault.manifestSetDigest == expectedVaultSnapshot.manifestSetDigest,
                  verifiedCandidateVault.keyIdentityDigest == expectedVaultSnapshot.keyIdentityDigest,
                  verifiedCandidateVault.artifacts.map(\.artifactDigest) ==
                    expectedVaultSnapshot.artifacts.map(\.artifactDigest),
                  expectedVaultSnapshot.artifacts.allSatisfy({
                      $0.backupPayloadArtifact != nil &&
                        $0.backupManifestArtifact != nil &&
                        ($0.finalizationArtifact == nil ||
                            $0.backupFinalizationArtifact != nil)
                  }) else {
                throw RuntimeGenerationControlError.verificationRejected
            }
            vaultEvidenceMaterial = "authenticated-source-vault\n\(expectedVaultSnapshot.blobSetDigest)\n\(expectedVaultSnapshot.manifestSetDigest)\n\(expectedVaultSnapshot.keyIdentityDigest)"
        } else {
            // First-install authority is required to be completely empty.
            guard firstInventory.0.orderedValues.allSatisfy({ $0 == 0 }),
                  firstInventory.1.firstEventSequence == nil,
                  firstInventory.1.firstReceiptID == nil,
                  firstInventory.1.firstExternalOperationID == nil,
                  firstInventory.1.firstBlobID == nil else {
                throw RuntimeGenerationControlError.verificationRejected
            }
            if let verifiedCandidateVault {
                guard verifiedCandidateVault.artifacts.isEmpty,
                      candidate.authorityManifest.blobSetDigest ==
                        verifiedCandidateVault.blobSetDigest,
                      candidate.authorityManifest.attachmentManifestSetDigest ==
                        verifiedCandidateVault.manifestSetDigest,
                      candidate.authorityManifest.keyIdentityDigest ==
                        verifiedCandidateVault.keyIdentityDigest else {
                    throw RuntimeGenerationControlError.verificationRejected
                }
                vaultEvidenceMaterial = "\(verifiedCandidateVault.blobSetDigest)\n\(verifiedCandidateVault.manifestSetDigest)\n\(verifiedCandidateVault.keyIdentityDigest)"
            } else {
                guard let vaultInventory else {
                    throw RuntimeGenerationControlError.verificationRejected
                }
                let verifiedVault = try await RuntimeGenerationVaultInventoryReader.verifyEmpty(
                    rootURL: vaultRootURL,
                    expected: vaultInventory,
                    keyCustody: keyCustody,
                    fileManager: fileManager
                )
                vaultEvidenceMaterial = "\(verifiedVault.blobSetDigest)\n\(verifiedVault.manifestSetDigest)\n\(verifiedVault.keyIdentityDigest)"
            }
        }
        let evidenceMaterial: [RuntimeGenerationVerificationCheck: String] = [
            .freshReadOnlyOpen: "fresh-readonly-open-v8",
            .sqliteIntegrity: "integrity-ok",
            .foreignKeys: "foreign-key-check-exact",
            .exactV8Schema: candidate.authorityManifest.manifestDigest,
            .artifactDigests: candidate.authorityManifest.database.sha256,
            .manifestCounts: try RuntimeGenerationControlCodec.digest(firstInventory.0),
            .canonicalReplay: replayStateDigest,
            .replayEquivalence: LocalRuntimeStorageChecksum.sha256Hex(
                for: "\(replayStateDigest)\n\(candidateEquivalenceDigest)\n\(firstInventory.1.projectionAuthorityDigest)\n\(firstInventory.1.searchAuthorityDigest)"
            ),
            .projectionEquivalence: firstInventory.1.projectionAuthorityDigest,
            .searchEquivalence: firstInventory.1.searchAuthorityDigest,
            .receiptAuthority: candidateFence.receiptAuthorityDigest,
            .externalOperationAuthority: firstInventory.1.externalOperationAuthorityDigest,
            .attachmentAuthority: LocalRuntimeStorageChecksum.sha256Hex(
                for: "\(firstInventory.1.attachmentAuthorityDigest)\n\(vaultEvidenceMaterial)"
            ),
            .secondFreshReadOnlyOpen: try RuntimeGenerationControlCodec.digest(
                secondInventory.0
            ),
        ]
        guard Set(evidenceMaterial.keys) == Set(RuntimeGenerationVerificationCheck.allCases) else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        let evidence = try evidenceMaterial.map { check, material in
            try RuntimeGenerationVerificationEvidence(
                check: check,
                evidenceDigest: LocalRuntimeStorageChecksum.sha256Hex(
                    for: "\(check.rawValue)\n\(material)\n\(candidate.recordDigest)"
                )
            )
        }
        return try RuntimeGenerationControlRecordFactory.verification(
            id: verificationID,
            verifierInstanceID: verifier.verifierInstanceID,
            reservation: reservation,
            migrationRunID: run.migrationRunID,
            sourceFenceDigest: candidate.authorityManifest.sourceFence?.fenceDigest,
            candidateAuthorityManifestDigest: candidate.authorityManifest.manifestDigest,
            candidateAuthorityManifestFileSHA256: candidate.authorityManifestFileSHA256,
            candidateSelectorFileSHA256: candidate.selectorFileSHA256,
            evidence: evidence,
            verifiedAtMilliseconds: nondecreasingTimestamp(
                after: run.completedAtMilliseconds,
                proposed: try nowMilliseconds()
            )
        )
    }

    private static func controlReplayAuditDeferredReason(
        _ reason: RuntimeCanonicalReplayDeferredReason
    ) -> RuntimeGenerationCandidateReplayAuditDeferredReason {
        switch reason {
        case let .boundaryCertificateBudget(maximum):
            return .boundaryCertificateBudget(maximum: maximum)
        case let .queryBudget(maximumBytes, maximumRows, maximumVMCallbacks):
            return .queryBudget(
                maximumBytes: maximumBytes,
                maximumRows: maximumRows,
                maximumVMCallbacks: maximumVMCallbacks
            )
        case .cancelled:
            return .cancelled
        }
    }

    private static func candidateReplayCertificateDigest(
        for audit: RuntimeCanonicalReplayCandidateAuditResult,
        database: SQLiteDatabase
    ) async throws -> String? {
        let reconstruction: RuntimeCanonicalReconstruction?
        switch audit {
        case let .complete(value), let .blocked(_, value):
            reconstruction = value
        case .deferred:
            reconstruction = nil
        }
        guard let cursor = reconstruction?.cursor else { return nil }
        return try await database.transaction(.deferred) { database in
            let rows = try database.query(
                "SELECT reconstruction_digest, certificate_digest FROM runtime_canonical_replay_verification_certificates WHERE event_sequence = ? LIMIT 2",
                bindings: [.integer(Int64(cursor.sequence))],
                maximumDecodedBytes: RuntimeGenerationDatabaseAuthority.pageByteBudget
            )
            guard rows.count == 1,
                  rows[0].value(named: "reconstruction_digest") ==
                    .text(reconstruction!.stateDigest),
                  case let .text(certificateDigest)? = rows[0].value(named: "certificate_digest") else {
                throw RuntimeGenerationControlError.verificationRejected
            }
            return certificateDigest
        }
    }

    /// Materializes immutable candidate authority after all caller-owned
    /// database transformations have completed.  This deliberately stops
    /// before verification, selector publication, activation intent creation,
    /// recovery receipt creation, and recovery-plan consumption.
    private func finalizePostTransformCandidate(
        input: RuntimeGenerationCandidatePostTransformFinalizationInput,
        initialLease: RuntimeGenerationOperationLease
    ) async throws -> RuntimeGenerationCandidatePostTransformFinalizationOutput {
        let operationLease = initialLease
        let databaseURL = input.candidateDirectoryURL.appendingPathComponent(
            "Runtime.sqlite", isDirectory: false
        )
        let baselineDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: "activation-baseline-v1\n\(input.reservation.candidateGenerationID.rawValue)\n\(input.expectedCandidateSnapshot.fence.fenceDigest)"
        )
        let stateWork = try await withRenewableOperationLease(initialLease: operationLease) {
            let database = try SQLiteDatabase(
                url: databaseURL,
                configuration: CanonicalRuntimeStore.sqliteConfiguration(openMode: .existingOnly)
            )
            do {
                let replayAuditResult = try await RuntimeCanonicalReplayEngine.auditAndCertifyCandidate(
                    in: database
                )
                let outcome: RuntimeGenerationCandidateReplayAuditOutcomeKind
                let blockedInvariant: RuntimeCanonicalReplayInvariantCode?
                let deferredReason: RuntimeGenerationCandidateReplayAuditDeferredReason?
                let replayStateDigest: String
                switch replayAuditResult {
                case let .complete(reconstruction):
                    outcome = .complete
                    blockedInvariant = nil
                    deferredReason = nil
                    replayStateDigest = reconstruction.stateDigest
                case let .blocked(divergence, reconstruction):
                    outcome = .blocked
                    blockedInvariant = divergence.code
                    deferredReason = nil
                    replayStateDigest = reconstruction.stateDigest
                case let .deferred(reason):
                    outcome = .deferred
                    blockedInvariant = nil
                    deferredReason = Self.controlReplayAuditDeferredReason(reason)
                    replayStateDigest = ""
                }
                let certificateDigest = try await Self.candidateReplayCertificateDigest(
                    for: replayAuditResult, database: database
                )
                let audit = try RuntimeGenerationControlRecordFactory.candidateReplayAudit(
                    id: input.replayAuditID,
                    preparation: input.candidatePreparation,
                    operationLease: operationLease,
                    outcome: outcome,
                    blockedInvariant: blockedInvariant,
                    deferredReason: deferredReason,
                    replayCertificateDigest: certificateDigest,
                    reconstructionDigest: outcome == .deferred ? nil : replayStateDigest,
                    auditedAtMilliseconds: max(operationLease.issuedAtMilliseconds, try nowMilliseconds())
                )
                try await controlStore.recordCandidateReplayAudit(audit, currentLease: operationLease)
                switch replayAuditResult {
                case .complete: break
                case let .blocked(divergence, _):
                    throw RuntimeGenerationCandidateReplayAuditOutcome.blocked(divergence)
                case let .deferred(reason):
                    throw RuntimeGenerationCandidateReplayAuditOutcome.deferred(reason)
                }
                guard input.expectedReplayStateDigest == nil ||
                        replayStateDigest == input.expectedReplayStateDigest else {
                    throw RuntimeGenerationControlError.verificationRejected
                }
                let checkpoint = try await database.checkpoint(.truncate)
                guard checkpoint.logFrameCount == checkpoint.checkpointedFrameCount else {
                    throw LocalRuntimeStorageError.canonicalIntegrityFailure
                }
                let inventory = try await RuntimeGenerationDatabaseAuthority.manifestInventory(in: database)
                let equivalence = try await RuntimeGenerationDatabaseAuthority
                    .migrationEquivalenceDigest(in: database)
                guard equivalence == input.expectedCandidateSnapshot.semanticEquivalenceDigest,
                      input.requiresExactCandidateInventory == false ||
                        (inventory.0 == input.expectedCandidateSnapshot.counts &&
                         inventory.1 == input.expectedCandidateSnapshot.boundaries) else {
                    throw RuntimeGenerationControlError.verificationRejected
                }
                let fence = try await RuntimeGenerationDatabaseAuthority.revisionFence(
                    in: database,
                    generationID: input.reservation.candidateGenerationID,
                    generationDigest: baselineDigest
                )
                try await database.close()
                return (audit, inventory, fence, replayStateDigest)
            } catch {
                let operationError = error
                do { try await database.close() }
                catch { throw LocalRuntimeStorageError.canonicalIOFailure(operation: "close_post_transform_candidate_database") }
                throw operationError
            }
        }
        // The audit is itself lease/fence-bound.  A heartbeat renewal during
        // this tightly bounded certification window would make its immutable
        // audit evidence stale; fail closed rather than attach it to a later
        // lease epoch.
        guard stateWork.lease == operationLease else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
        let state = stateWork.result
        let activationBaseline = try RuntimeGenerationActivationBaseline.make(
            candidateIdentityDigest: baselineDigest, revisionFence: state.2
        )
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: databaseURL, artifact: "post_transform_candidate_database"
        )
        try RuntimeStoreFileDurability.synchronizeFile(at: databaseURL)
        let databaseArtifact = try RuntimeGenerationDatabaseAuthority.artifact(
            at: databaseURL, relativePath: "Runtime.sqlite"
        )
        let manifest = try RuntimeGenerationAuthorityManifest.make(
            operationKind: input.operationKind,
            generationID: input.reservation.candidateGenerationID,
            schemaVersion: runtimeCanonicalAttachmentSchemaVersion,
            sourceGenerationID: input.sourceGenerationID,
            sourceGenerationDigest: input.sourceGenerationDigest,
            sourceFence: input.manifestSourceFence,
            activationBaseline: activationBaseline,
            database: databaseArtifact.semantic,
            sourceWAL: nil,
            blobSetDigest: input.blobSetDigest,
            attachmentManifestSetDigest: input.attachmentManifestSetDigest,
            encryptionScheme: input.sourceEncryptionScheme,
            keyIdentityDigest: input.keyIdentityDigest,
            counts: state.1.0,
            boundaries: state.1.1,
            reservationID: input.reservation.reservationID,
            migrationRunID: input.migrationRun.migrationRunID,
            createdAtMilliseconds: input.candidateCreatedAtMilliseconds,
            retentionClass: .staged
        )
        let authorityManifestBytes = try RuntimeGenerationControlCodec.encode(manifest)
        let authoritySHA = LocalRuntimeStorageChecksum.sha256Hex(for: authorityManifestBytes)
        let selector = RuntimeGenerationActiveSelector(
            formatVersion: runtimeGenerationActiveSelectorVersion,
            generationID: input.reservation.candidateGenerationID,
            schemaVersion: runtimeCanonicalAttachmentSchemaVersion,
            relativeDatabasePath: input.relativeDatabasePath,
            authorityManifestDigest: manifest.manifestDigest,
            authorityManifestFileSHA256: authoritySHA,
            verificationID: input.verificationID,
            activationIntentID: input.activationIntentID,
            priorGenerationID: input.priorGenerationID,
            priorAuthorityManifestDigest: input.priorAuthorityManifestDigest,
            preparedAtMilliseconds: input.migrationRun.completedAtMilliseconds
        )
        let selectorBytes = try RuntimeGenerationActiveSelectorCodec.encode(selector)
        let selectorSHA = LocalRuntimeStorageChecksum.sha256Hex(for: selectorBytes)
        let candidate = try RuntimeGenerationControlRecordFactory.candidate(
            authorityManifest: manifest,
            authorityManifestFileSHA256: authoritySHA,
            selectorFileSHA256: selectorSHA
        )
        try writeImmutable(
            authorityManifestBytes,
            to: input.candidateDirectoryURL.appendingPathComponent("Authority.json"),
            artifact: "post_transform_authority_manifest"
        )
        try RuntimeStoreFileDurability.synchronizeDirectory(at: input.candidateDirectoryURL)
        let authorityArtifact = try RuntimeGenerationArtifact(
            relativePath: "Authority.json", sha256: authoritySHA,
            byteCount: Int64(authorityManifestBytes.count), protectionClass: "complete"
        )
        let evidenceWork = try await withRenewableOperationLease(initialLease: operationLease) {
            try await self.preparedDirectoryEvidence(
                at: input.candidateDirectoryURL,
                artifacts: [databaseArtifact.semantic, authorityArtifact],
                witnessDomain: "candidate-directory-durability-v1"
            )
        }
        guard evidenceWork.lease == operationLease else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
        let evidence = evidenceWork.result
        let completion = try RuntimeGenerationControlRecordFactory.candidatePreparationCompletion(
            preparationID: input.candidatePreparation.preparationID,
            candidateRecordDigest: candidate.recordDigest,
            directoryDevice: evidence.identity.device,
            directoryInode: evidence.identity.inode,
            interiorArtifactCount: evidence.artifactCount,
            interiorByteCount: evidence.byteCount,
            interiorInventoryDigest: evidence.inventoryDigest,
            durabilityWitnessDigest: evidence.durabilityWitnessDigest,
            completedAtMilliseconds: nondecreasingTimestamp(
                after: operationLease.issuedAtMilliseconds, proposed: try nowMilliseconds()
            )
        )
        return RuntimeGenerationCandidatePostTransformFinalizationOutput(
            operationLease: operationLease,
            candidate: candidate,
            candidatePreparationCompletion: completion,
            replayAudit: state.0,
            authorityManifestBytes: authorityManifestBytes,
            selectorBytes: selectorBytes,
            replayStateDigest: state.3
        )
    }

    func writeImmutable(_ data: Data, to url: URL, artifact: String) throws {
        try data.write(to: url, options: [.withoutOverwriting])
        try RuntimeStoreFileDurability.applyCompleteProtection(at: url, artifact: artifact)
        try RuntimeStoreFileDurability.synchronizeFile(at: url)
    }

    func ensureProtectedDirectory(
        _ url: URL,
        containedIn parent: URL,
        artifact: String
    ) throws {
        try RuntimeStorePathValidation.requireContained(url, in: parent)
        if fileManager.fileExists(atPath: url.path) {
            try RuntimeStoreFileDurability.requireDirectory(at: url, artifact: artifact)
        } else {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: false)
            try RuntimeStoreFileDurability.synchronizeDirectory(at: parent)
        }
        try RuntimeStoreFileDurability.applyCompleteProtection(at: url, artifact: artifact)
        let pin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            url,
            createFinalComponentIfMissing: false
        )
        try pin.revalidate()
    }

    func createPinnedPreparationDirectory(
        named name: String,
        in parentURL: URL,
        artifact: String
    ) throws {
        guard (name.hasPrefix(".preparing-backup-") || name.hasPrefix(".staging-")),
              name.contains("/") == false,
              name.contains("\0") == false else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        let parent = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            parentURL,
            createFinalComponentIfMissing: false
        )
        try parent.revalidate()
        guard Darwin.mkdirat(parent.descriptor, name, S_IRWXU) == 0 else {
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "create_backup_preparation_directory"
            )
        }
        let childDescriptor = Darwin.openat(
            parent.descriptor,
            name,
            O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW
        )
        guard childDescriptor >= 0 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        var childOwned = true
        defer { if childOwned { _ = Darwin.close(childDescriptor) } }
        try RuntimeStoreFileDurability.applyCompleteProtection(
            toOpenFileDescriptor: childDescriptor,
            artifact: artifact
        )
        var childStatus = stat()
        guard fstat(childDescriptor, &childStatus) == 0,
              childStatus.st_mode & S_IFMT == S_IFDIR,
              Darwin.fsync(childDescriptor) == 0 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        guard Darwin.fsync(parent.descriptor) == 0 else {
            throw RuntimeStoreErrnoMapper.storageError(
                operation: "synchronize_backup_preparation_parent"
            )
        }
        let directoryURL = parentURL.appendingPathComponent(name, isDirectory: true)
        let child = RuntimeStoreDirectoryPin(
            descriptor: childDescriptor,
            identity: RuntimeStoreFileIdentity(
                device: UInt64(childStatus.st_dev),
                inode: UInt64(childStatus.st_ino)
            ),
            pathURL: directoryURL
        )
        childOwned = false
        try child.revalidate()
        try parent.revalidate()
    }

    func preparedBackupDirectoryEvidence(
        at directoryURL: URL,
        backup: RuntimeGenerationBackupRecord
    ) throws -> RuntimeGenerationPreparedDirectoryEvidence {
        let artifacts = ([backup.databaseArtifact] +
            backup.vaultArtifacts.flatMap { artifact in
                [
                    artifact.backupPayloadArtifact,
                    artifact.backupManifestArtifact,
                    artifact.backupFinalizationArtifact,
                ].compactMap { $0 }
            })
        return try preparedDirectoryEvidence(
            at: directoryURL,
            artifacts: artifacts,
            witnessDomain: "backup-directory-durability-v1"
        )
    }

    func preparedDirectoryEvidence(
        at directoryURL: URL,
        artifacts: [RuntimeGenerationArtifact],
        witnessDomain: String
    ) throws -> RuntimeGenerationPreparedDirectoryEvidence {
        try RuntimeStoreFileDurability.synchronizeDirectory(at: directoryURL)
        let pin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            directoryURL,
            createFinalComponentIfMissing: false
        )
        try pin.revalidate()
        let artifacts = artifacts.sorted { $0.relativePath < $1.relativePath }
        let observedArtifacts = try Self.descriptorRelativeArtifactInventory(
            root: pin,
            maximumTotalBytes: preparationScanByteLimit
        )
        guard observedArtifacts == artifacts else {
            throw RuntimeGenerationControlError.restoreSourceUnverified
        }
        guard artifacts.isEmpty == false,
              Set(artifacts.map(\.relativePath)).count == artifacts.count else {
            throw RuntimeGenerationControlError.restoreSourceUnverified
        }
        var byteCount: Int64 = 0
        for artifact in artifacts {
            guard artifact.byteCount <= Int64.max - byteCount else {
                throw RuntimeGenerationControlError.malformed(
                    field: "backup_preparation_byte_count"
                )
            }
            byteCount += artifact.byteCount
        }
        let inventoryDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: artifacts.map {
                "\($0.relativePath)\n\($0.sha256)\n\($0.byteCount)\n\($0.protectionClass)"
            }.joined(separator: "\n--\n")
        )
        let durabilityWitnessDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: "\(witnessDomain)\n\(pin.identity.device)\n\(pin.identity.inode)\n\(inventoryDigest)\n\(artifacts.count)\n\(byteCount)"
        )
        return RuntimeGenerationPreparedDirectoryEvidence(
            identity: pin.identity,
            artifactCount: Int64(artifacts.count),
            byteCount: byteCount,
            inventoryDigest: inventoryDigest,
            durabilityWitnessDigest: durabilityWitnessDigest
        )
    }

    nonisolated static func descriptorRelativeArtifactInventory(
        root: RuntimeStoreDirectoryPin,
        maximumTotalBytes: Int64
    ) throws -> [RuntimeGenerationArtifact] {
        let maximumDepth = 16
        let maximumEntries: Int64 = 100_000
        guard maximumTotalBytes > 0 else {
            throw RuntimeGenerationControlError.resourcePolicyExceeded(
                resource: "preparation_scan_bytes", maximum: maximumTotalBytes
            )
        }
        var artifacts: [RuntimeGenerationArtifact] = []
        var totalBytes: Int64 = 0
        var entryCount: Int64 = 0

        func walk(descriptor: Int32, prefix: String, depth: Int) throws {
            guard depth <= maximumDepth else {
                throw RuntimeGenerationControlError.resourcePolicyExceeded(
                    resource: "preparation_scan_depth", maximum: Int64(maximumDepth)
                )
            }
            try Task.checkCancellation()
            guard Darwin.fcntl(descriptor, F_GETPROTECTIONCLASS) == PROTECTION_CLASS_A else {
                throw LocalRuntimeStorageError.canonicalFileProtectionFailure(
                    artifact: prefix.isEmpty ? "preparation_root" : prefix
                )
            }
            let duplicate = Darwin.dup(descriptor)
            guard duplicate >= 0, let stream = fdopendir(duplicate) else {
                if duplicate >= 0 { _ = Darwin.close(duplicate) }
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            var streamOpen = true
            defer { if streamOpen { _ = closedir(stream) } }
            var names: [String] = []
            while let entry = readdir(stream) {
                try Task.checkCancellation()
                entryCount += 1
                guard entryCount <= maximumEntries else {
                    throw RuntimeGenerationControlError.resourcePolicyExceeded(
                        resource: "preparation_scan_entries", maximum: maximumEntries
                    )
                }
                let name = withUnsafePointer(to: &entry.pointee.d_name) { pointer in
                    pointer.withMemoryRebound(
                        to: CChar.self,
                        capacity: Int(NAME_MAX) + 1
                    ) { String(cString: $0) }
                }
                if name != "." && name != ".." {
                    guard name.utf8.count <= Int(NAME_MAX) else {
                        throw RuntimeGenerationControlError.resourcePolicyExceeded(
                            resource: "preparation_entry_name_bytes",
                            maximum: Int64(NAME_MAX)
                        )
                    }
                    names.append(name)
                }
            }
            let closeDirectoryResult = closedir(stream)
            streamOpen = false
            guard closeDirectoryResult == 0 else {
                throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
            }
            guard names.count == Set(names).count else {
                throw RuntimeGenerationControlError.restoreSourceUnverified
            }
            for name in names.sorted() {
                guard name.isEmpty == false,
                      name.contains("/") == false,
                      name.contains("\0") == false else {
                    throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                }
                var status = stat()
                guard fstatat(descriptor, name, &status, AT_SYMLINK_NOFOLLOW) == 0,
                      status.st_mode & S_IFMT != S_IFLNK else {
                    throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                }
                let relativePath = prefix.isEmpty ? name : "\(prefix)/\(name)"
                guard relativePath.utf8.count <= 1_024 else {
                    throw RuntimeGenerationControlError.restoreSourceUnverified
                }
                if status.st_mode & S_IFMT == S_IFDIR {
                    let child = Darwin.openat(
                        descriptor,
                        name,
                        O_RDONLY | O_DIRECTORY | O_CLOEXEC | O_NOFOLLOW
                    )
                    guard child >= 0 else {
                        throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                    }
                    do {
                        try walk(descriptor: child, prefix: relativePath, depth: depth + 1)
                    } catch {
                        _ = Darwin.close(child)
                        throw error
                    }
                    guard Darwin.close(child) == 0 else {
                        throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                    }
                } else {
                    guard status.st_mode & S_IFMT == S_IFREG,
                          status.st_nlink == 1,
                          status.st_size >= 0,
                          Int64(artifacts.count) < maximumEntries else {
                        throw RuntimeGenerationControlError.resourcePolicyExceeded(
                            resource: "preparation_scan_artifacts", maximum: maximumEntries
                        )
                    }
                    let byteCount = Int64(status.st_size)
                    guard byteCount <= maximumTotalBytes - totalBytes else {
                        throw RuntimeGenerationControlError.resourcePolicyExceeded(
                            resource: "preparation_scan_bytes", maximum: maximumTotalBytes
                        )
                    }
                    let file = Darwin.openat(
                        descriptor,
                        name,
                        O_RDONLY | O_CLOEXEC | O_NOFOLLOW
                    )
                    guard file >= 0 else {
                        throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
                    }
                    var initialFileStatus = stat()
                    guard fstat(file, &initialFileStatus) == 0,
                          initialFileStatus.st_dev == status.st_dev,
                          initialFileStatus.st_ino == status.st_ino,
                          initialFileStatus.st_size == status.st_size,
                          initialFileStatus.st_nlink == 1 else {
                        _ = Darwin.close(file)
                        throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                            artifact: relativePath
                        )
                    }
                    var hasher = SHA256()
                    var observedBytes: Int64 = 0
                    var buffer = [UInt8](repeating: 0, count: 64 * 1_024)
                    var readFailure = false
                    while observedBytes < byteCount {
                        if Task.isCancelled {
                            _ = Darwin.close(file)
                            throw CancellationError()
                        }
                        let result = buffer.withUnsafeMutableBytes { bytes in
                            Darwin.read(file, bytes.baseAddress, bytes.count)
                        }
                        if result < 0 {
                            readFailure = true
                            break
                        }
                        if result == 0 { break }
                        observedBytes += Int64(result)
                        hasher.update(data: Data(buffer[0..<result]))
                    }
                    var finalDescriptorStatus = stat()
                    var finalPathStatus = stat()
                    let protection = Darwin.fcntl(file, F_GETPROTECTIONCLASS)
                    let descriptorStatResult = fstat(file, &finalDescriptorStatus)
                    let pathStatResult = fstatat(
                        descriptor, name, &finalPathStatus, AT_SYMLINK_NOFOLLOW
                    )
                    let closeResult = Darwin.close(file)
                    guard readFailure == false,
                          observedBytes == byteCount,
                          descriptorStatResult == 0,
                          pathStatResult == 0,
                          finalDescriptorStatus.st_dev == initialFileStatus.st_dev,
                          finalDescriptorStatus.st_ino == initialFileStatus.st_ino,
                          finalDescriptorStatus.st_size == initialFileStatus.st_size,
                          finalDescriptorStatus.st_mtimespec.tv_sec == initialFileStatus.st_mtimespec.tv_sec,
                          finalDescriptorStatus.st_mtimespec.tv_nsec == initialFileStatus.st_mtimespec.tv_nsec,
                          finalDescriptorStatus.st_ctimespec.tv_sec == initialFileStatus.st_ctimespec.tv_sec,
                          finalDescriptorStatus.st_ctimespec.tv_nsec == initialFileStatus.st_ctimespec.tv_nsec,
                          finalDescriptorStatus.st_gen == initialFileStatus.st_gen,
                          finalPathStatus.st_dev == initialFileStatus.st_dev,
                          finalPathStatus.st_ino == initialFileStatus.st_ino,
                          finalPathStatus.st_size == initialFileStatus.st_size,
                          finalPathStatus.st_nlink == 1,
                          finalPathStatus.st_mtimespec.tv_sec == initialFileStatus.st_mtimespec.tv_sec,
                          finalPathStatus.st_mtimespec.tv_nsec == initialFileStatus.st_mtimespec.tv_nsec,
                          finalPathStatus.st_ctimespec.tv_sec == initialFileStatus.st_ctimespec.tv_sec,
                          finalPathStatus.st_ctimespec.tv_nsec == initialFileStatus.st_ctimespec.tv_nsec,
                          finalPathStatus.st_gen == initialFileStatus.st_gen,
                          protection == PROTECTION_CLASS_A,
                          closeResult == 0 else {
                        throw LocalRuntimeStorageError.canonicalFileIdentityChanged(
                            artifact: relativePath
                        )
                    }
                    let digest = hasher.finalize().map {
                        String(format: "%02x", $0)
                    }.joined()
                    artifacts.append(try RuntimeGenerationArtifact(
                        relativePath: relativePath,
                        sha256: digest,
                        byteCount: byteCount,
                        protectionClass: "complete"
                    ))
                    totalBytes += byteCount
                }
            }
        }

        try root.revalidate()
        try walk(descriptor: root.descriptor, prefix: "", depth: 0)
        try root.revalidate()
        return artifacts.sorted { $0.relativePath < $1.relativePath }
    }

    func publishPreparedDirectory(
        preparation: RuntimeGenerationBackupPreparationRecord,
        expectedIdentity: RuntimeStoreFileIdentity,
        parentURL: URL
    ) throws -> RuntimeStoreFileIdentity {
        let parent = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            parentURL,
            createFinalComponentIfMissing: false
        )
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
        ) == expectedIdentity,
        Darwin.renameatx_np(
            parent.descriptor,
            preparation.hiddenDirectoryName,
            parent.descriptor,
            preparation.finalDirectoryName,
            UInt32(RENAME_EXCL)
        ) == 0,
        Darwin.fsync(parent.descriptor) == 0 else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        try parent.revalidate()
        var finalStatus = stat()
        guard fstatat(
            parent.descriptor,
            preparation.finalDirectoryName,
            &finalStatus,
            AT_SYMLINK_NOFOLLOW
        ) == 0,
        finalStatus.st_mode & S_IFMT == S_IFDIR else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        let observed = RuntimeStoreFileIdentity(
            device: UInt64(finalStatus.st_dev),
            inode: UInt64(finalStatus.st_ino)
        )
        guard observed == expectedIdentity else {
            throw LocalRuntimeStorageError.canonicalPathAuthorityDenied
        }
        return observed
    }

    func nextID() -> String {
        environment.uuid.nextUUID().uuidString.lowercased()
    }

    func nowMilliseconds() throws -> Int64 {
        let milliseconds = environment.clock.now.timeIntervalSince1970 * 1_000
        guard milliseconds.isFinite,
              milliseconds >= 0,
              milliseconds <= Double(Int64.max) else {
            throw RuntimeGenerationControlError.malformed(field: "clock")
        }
        return Int64(milliseconds.rounded(.towardZero))
    }

    func monotonicTimestamp(after prior: Int64, proposed: Int64) throws -> Int64 {
        guard prior < Int64.max else {
            throw RuntimeGenerationControlError.malformed(field: "timestamp_overflow")
        }
        return max(prior + 1, proposed)
    }

    func nondecreasingTimestamp(after prior: Int64, proposed: Int64) -> Int64 {
        max(prior, proposed)
    }
}
