import Darwin
import Foundation

struct RuntimeGenerationVerifiedBackupRecoveryPlan: Sendable, Equatable {
    let backup: RuntimeGenerationBackupRecord
    let authorization: RuntimeGenerationRecoveryAuthorization
}

struct RuntimeGenerationReviewedRollbackPlan: Sendable, Equatable {
    let assessment: RuntimeGenerationRollbackRecord
    let authorization: RuntimeGenerationRecoveryAuthorization
}

struct RuntimeGenerationCrashEvidenceResult: Sendable, Equatable {
    let artifacts: [RuntimeGenerationObservedArtifact]
    let quarantineRecords: [RuntimeGenerationQuarantineRecord]
    let controlSnapshotPreserved: Bool
    let controlSnapshotErrorFingerprint: String?
    let controlJournalUnavailable: Bool
}

enum RuntimeGenerationArtifactInspectionState: Sendable, Equatable {
    case matches
    case missing
    case mismatch(RuntimeGenerationObservedArtifact)
    case unreadable
}

enum RuntimeGenerationCandidateInspectionState: Sendable, Equatable {
    case present(RuntimeGenerationCandidateRecord)
    case missing
    case unavailable
}

struct RuntimeGenerationRecoveryInspection: Sendable, Equatable {
    let quarantine: RuntimeGenerationQuarantineRecord
    let artifact: RuntimeGenerationArtifactInspectionState
    let generation: RuntimeGenerationCandidateInspectionState
}

struct RuntimeGenerationRecoveryReverification: Sendable, Equatable {
    let generationID: RuntimeStoreGenerationID
    let replayReconstructionDigest: String
    let databaseArtifact: RuntimeGenerationObservedArtifact
    let verificationDigest: String
}

struct RuntimeGenerationOriginalExportResult: Sendable, Equatable {
    let quarantineID: String
    let sourceArtifactDigest: String
    let exportedArtifact: RuntimeGenerationObservedArtifact
    let exportedAtMilliseconds: Int64
    let exportReceiptDigest: String
}

/// The recovery executor never presents a held claim as a completed retry.
/// A completed result is the durable receipt returned by the control plane.
enum RuntimeGenerationFreshVerificationRecoveryExecutionResult: Sendable, Equatable {
    case completed(RuntimeGenerationRecoveryOperationExecutionReceipt)
    case pending(RuntimeGenerationRecoveryOperationExecutionClaim)
}

/// Explicit, caller-driven reachability for a derived-state rebuild. Running
/// means only that an unpublished candidate gateway is owned; it is never a
/// claim that projections were rebuilt or that recovery was consumed.
enum RuntimeGenerationDerivedStateRebuildExecutionResult: Sendable {
    case completed(RuntimeGenerationRecoveryOperationExecutionReceipt)
    case pending(RuntimeGenerationRecoveryOperationExecutionClaim)
    case running(RuntimeGenerationProjectionRebuildExecutionContext)
}

/// The committed-candidate continuation never reports completion from an
/// activation attempt. Only the durable recovery receipt is terminal truth.
enum RuntimeGenerationCommittedDerivedStateRebuildExecutionResult: Sendable, Equatable {
    case completed(RuntimeGenerationRecoveryOperationExecutionReceipt)
    case pending(migrationRunID: String?)
    case blocked(migrationRunID: String, reasonDigest: String)
}

/// Explicit recovery boundary. Merely possessing a backup identifier cannot
/// trigger rollback: a caller must durably record the reviewed alternatives
/// and consequences, then present the one-shot authorization to the lifecycle
/// service before its expiry.
actor RuntimeGenerationRecoveryService {
    private let controlStore: RuntimeGenerationControlStore
    private let lifecycle: RuntimeGenerationLifecycleService
    private let generationManager: RuntimeStoreGenerationManager
    private let fileManager: FileManager
    private var environment: RuntimeEnvironment

    init(
        controlStore: RuntimeGenerationControlStore,
        lifecycle: RuntimeGenerationLifecycleService,
        generationManager: RuntimeStoreGenerationManager,
        environment: RuntimeEnvironment,
        fileManager: FileManager = .default
    ) {
        self.controlStore = controlStore
        self.lifecycle = lifecycle
        self.generationManager = generationManager
        self.environment = environment
        self.fileManager = fileManager
    }

    /// Prepares the one-shot operation only from the durable quarantine and
    /// authorization records. The candidate remains derived from quarantine
    /// evidence at execution time; callers cannot substitute a generation.
    func prepareRetryFreshConnectionVerification(
        quarantineID: String,
        recoveryAuthorizationID: String,
        supersedingPlanID: String? = nil
    ) async throws -> RuntimeGenerationRecoveryOperationPlan {
        let quarantine = try await controlStore.quarantine(id: quarantineID)
        let authorization = try await controlStore.recoveryAuthorization(
            id: recoveryAuthorizationID
        )
        guard authorization.action == .retryFreshConnectionVerification,
              authorization.targetDigest == quarantine.quarantineDigest,
              quarantine.allowedActions.contains(.retryFreshConnectionVerification),
              quarantine.originalGenerationID != nil else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        let preparedAt = try nowMilliseconds()
        guard preparedAt >= authorization.authorizedAtMilliseconds,
              preparedAt < authorization.expiresAtMilliseconds else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        if let supersedingPlanID {
            let predecessor = try await controlStore.load(
                RuntimeGenerationRecoveryOperationPlan.self,
                table: "runtime_generation_recovery_operation_plans",
                idColumn: "plan_id",
                id: supersedingPlanID
            )
            guard predecessor.quarantineID == quarantine.quarantineID,
                  predecessor.action == .retryFreshConnectionVerification,
                  predecessor.targetDigest == quarantine.quarantineDigest,
                  predecessor.recoveryAuthorizationID != authorization.authorizationID else {
                throw RuntimeGenerationControlError.recoveryAuthorizationRequired
            }
        }
        let plan = try RuntimeGenerationControlRecordFactory.recoveryOperationPlan(
            id: nextID(), quarantine: quarantine, authorization: authorization,
            preparedAtMilliseconds: preparedAt,
            expiresAtMilliseconds: authorization.expiresAtMilliseconds
        )
        try await controlStore.recordRecoveryOperationPlan(
            plan,
            supersedingPlanID: supersedingPlanID
        )
        return plan
    }

    /// An expired, unconsumed retry plan is terminalized explicitly. Its bytes
    /// remain intact; a replacement must use a fresh authorization and name
    /// this plan as its predecessor when it is prepared.
    func disposeExpiredRetryFreshConnectionVerificationPlan(
        planID: String
    ) async throws -> RuntimeGenerationRecoveryOperationPlanDisposition {
        let plan = try await controlStore.load(
            RuntimeGenerationRecoveryOperationPlan.self,
            table: "runtime_generation_recovery_operation_plans",
            idColumn: "plan_id",
            id: planID
        )
        let disposedAt = try nowMilliseconds()
        guard plan.action == .retryFreshConnectionVerification,
              disposedAt >= plan.expiresAtMilliseconds else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        let disposition = try RuntimeGenerationControlRecordFactory
            .recoveryOperationPlanDisposition(
                plan: plan,
                kind: .expiredWithoutReceipt,
                authorization: nil,
                disposedAtMilliseconds: disposedAt
            )
        try await controlStore.recordRecoveryOperationPlanDisposition(disposition)
        return disposition
    }

    func retryFreshConnectionVerification(
        planID: String,
        vault: RuntimeAttachmentVault,
        keyCustody: any RuntimeAttachmentKeyCustody = KeychainRuntimeAttachmentKeyCustody()
    ) async throws -> RuntimeGenerationFreshVerificationRecoveryExecutionResult {
        // A receipt remains result authority even after its originating plan
        // and authorization expire. It must therefore be discovered before
        // applying any plan-liveness checks.
        if let receipt = try await controlStore.recoveryOperationExecutionReceipt(
            planID: planID
        ) {
            return .completed(receipt)
        }
        let plan = try await controlStore.load(
            RuntimeGenerationRecoveryOperationPlan.self,
            table: "runtime_generation_recovery_operation_plans",
            idColumn: "plan_id", id: planID
        )
        let quarantine = try await controlStore.quarantine(id: plan.quarantineID)
        let authorization = try await controlStore.recoveryAuthorization(
            id: plan.recoveryAuthorizationID
        )
        let now = try nowMilliseconds()
        guard let candidateGenerationID = quarantine.originalGenerationID,
              plan.action == .retryFreshConnectionVerification,
              plan.targetDigest == quarantine.quarantineDigest,
              plan.recoveryAuthorizationDigest == authorization.authorizationDigest,
              quarantine.allowedActions.contains(.retryFreshConnectionVerification),
              authorization.action == .retryFreshConnectionVerification,
              authorization.targetDigest == quarantine.quarantineDigest,
              now >= plan.preparedAtMilliseconds,
              now < plan.expiresAtMilliseconds,
              now >= authorization.authorizedAtMilliseconds,
              now < authorization.expiresAtMilliseconds else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }

        // The claim is the single execution authority. It must be acquired
        // before opening a fresh verification connection, so concurrent
        // callers cannot manufacture competing verification evidence.
        let claimResult = try await controlStore.claimRecoveryOperationExecution(
            planID: plan.planID,
            claimID: nextID(),
            executorInstanceID: nextID(),
            expiresAtMilliseconds: plan.expiresAtMilliseconds
        )
        switch claimResult {
        case let .completed(receipt):
            return .completed(receipt)
        case let .held(claim):
            return .pending(claim)
        case let .acquired(claim):
            return try await executeFreshConnectionVerification(
                plan: plan,
                quarantine: quarantine,
                candidateGenerationID: candidateGenerationID,
                claim: claim,
                vault: vault,
                keyCustody: keyCustody
            )
        }
    }

    /// Begins one explicitly requested derived-state rebuild from a durable
    /// recovery plan. This is intentionally not a scheduler: callers receive
    /// an owned unpublished gateway and must decide whether to do any work.
    func beginDerivedStateRebuild(
        planID: String,
        source: CanonicalRuntimeStoreV8
    ) async throws -> RuntimeGenerationDerivedStateRebuildExecutionResult {
        if let receipt = try await controlStore.recoveryOperationExecutionReceipt(
            planID: planID
        ) {
            return .completed(receipt)
        }
        let plan = try await controlStore.load(
            RuntimeGenerationRecoveryOperationPlan.self,
            table: "runtime_generation_recovery_operation_plans",
            idColumn: "plan_id",
            id: planID
        )
        let quarantine = try await controlStore.quarantine(id: plan.quarantineID)
        let authorization = try await controlStore.recoveryAuthorization(
            id: plan.recoveryAuthorizationID
        )
        let now = try nowMilliseconds()
        guard let sourceGenerationID = quarantine.originalGenerationID,
              let sourceGenerationDigest = quarantine.originalManifestDigest,
              plan.action == .rebuildDerivedState,
              plan.targetDigest == quarantine.quarantineDigest,
              plan.recoveryAuthorizationDigest == authorization.authorizationDigest,
              quarantine.allowedActions.contains(.rebuildDerivedState),
              authorization.action == .rebuildDerivedState,
              authorization.targetDigest == quarantine.quarantineDigest,
              now >= plan.preparedAtMilliseconds,
              now < plan.expiresAtMilliseconds,
              now >= authorization.authorizedAtMilliseconds,
              now < authorization.expiresAtMilliseconds else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        let claimResult = try await controlStore.claimRecoveryOperationExecution(
            planID: plan.planID,
            claimID: nextID(),
            executorInstanceID: nextID(),
            expiresAtMilliseconds: plan.expiresAtMilliseconds
        )
        switch claimResult {
        case let .completed(receipt):
            return .completed(receipt)
        case let .held(claim):
            return .pending(claim)
        case let .acquired(claim):
            let safetyBackup = try await controlStore.latestEligibleBackup(
                sourceGenerationID: sourceGenerationID,
                sourceGenerationDigest: sourceGenerationDigest
            )
            let admission = try await lifecycle.admitProjectionRebuild(
                source: source,
                plan: plan,
                claim: claim,
                quarantine: quarantine,
                authorization: authorization,
                sourceSafetyBackupID: safetyBackup.backupID
            )
            let context = try await lifecycle.beginProjectionRebuildExecution(
                source: source,
                admission: admission
            )
            return .running(context)
        }
    }

    /// Continues only a durably committed v10 candidate. The exact frozen
    /// authority is re-read from control storage by plan lineage and is
    /// independently authenticated from disk by the lifecycle before any
    /// verification or activation side effect.
    func continueCommittedDerivedStateRebuild(
        planID: String,
        source: CanonicalRuntimeStoreV8,
        vault: RuntimeAttachmentVault,
        keyCustody: any RuntimeAttachmentKeyCustody = KeychainRuntimeAttachmentKeyCustody()
    ) async throws -> RuntimeGenerationCommittedDerivedStateRebuildExecutionResult {
        if let receipt = try await controlStore.recoveryOperationExecutionReceipt(planID: planID) {
            return .completed(receipt)
        }
        let plan = try await controlStore.load(
            RuntimeGenerationRecoveryOperationPlan.self,
            table: "runtime_generation_recovery_operation_plans",
            idColumn: "plan_id", id: planID
        )
        let quarantine = try await controlStore.quarantine(id: plan.quarantineID)
        let authorization = try await controlStore.recoveryAuthorization(
            id: plan.recoveryAuthorizationID
        )
        guard plan.action == .rebuildDerivedState,
              plan.targetDigest == quarantine.quarantineDigest,
              plan.recoveryAuthorizationDigest == authorization.authorizationDigest,
              authorization.action == .rebuildDerivedState,
              authorization.targetDigest == quarantine.quarantineDigest else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        guard let commitment = try await controlStore
            .projectionRebuildCandidateAuthorityCommitment(recoveryExecutionPlanID: plan.planID) else {
            return .pending(migrationRunID: nil)
        }
        let claim = try await controlStore.load(
            RuntimeGenerationRecoveryOperationExecutionClaim.self,
            table: "runtime_generation_recovery_operation_execution_claims",
            idColumn: "claim_id", id: commitment.recoveryExecutionClaimID
        )
        guard claim.planID == plan.planID,
              claim.claimEpoch == commitment.recoveryExecutionClaimEpoch else {
            return .blocked(
                migrationRunID: commitment.migrationRunID,
                reasonDigest: LocalRuntimeStorageChecksum.sha256Hex(
                    for: "projection-rebuild-committed-continuation-claim-mismatch\n\(commitment.commitmentDigest)"
                )
            )
        }
        let reservation = try await controlStore.reservation(id: commitment.reservationID)
        let activationClassification = try await generationManager.classifyActivationAfterCrash(
            candidate: commitment.candidateRecord,
            expectedPriorSelectorFileSHA256: reservation.expectedActiveManifestDigest,
            externalAuthorityMayHaveChanged: false,
            controlStore: controlStore
        )
        if case .committed = activationClassification {
            let reconciliation = try await lifecycle.reconcileUnknownActivation(
                candidateGenerationID: commitment.candidateGenerationID
            )
            guard reconciliation.controlReconciliationRequired == false,
                  case .committed = reconciliation.classification else {
                return .blocked(
                    migrationRunID: commitment.migrationRunID,
                    reasonDigest: LocalRuntimeStorageChecksum.sha256Hex(
                        for: "projection-rebuild-committed-continuation-activation-journal-pending\n\(commitment.commitmentDigest)"
                    )
                )
            }
            let verification = try await controlStore.verification(
                id: commitment.expectedVerificationID
            )
            guard verification.accepted else {
                return .blocked(
                    migrationRunID: commitment.migrationRunID,
                    reasonDigest: LocalRuntimeStorageChecksum.sha256Hex(
                        for: "projection-rebuild-committed-continuation-activation-verification-mismatch\n\(commitment.commitmentDigest)"
                    )
                )
            }
            return try await finalizeCommittedDerivedStateRebuild(
                plan: plan, claim: claim, commitment: commitment,
                verification: verification
            )
        }
        guard case .unchanged = activationClassification else {
            return .blocked(
                migrationRunID: commitment.migrationRunID,
                reasonDigest: LocalRuntimeStorageChecksum.sha256Hex(
                    for: "projection-rebuild-committed-continuation-selector-mismatch\n\(commitment.commitmentDigest)"
                )
            )
        }
        let continuation: RuntimeGenerationProjectionRebuildContinuationResult
        do {
            continuation = try await lifecycle.continueCommittedProjectionRebuild(
                source: source, vault: vault, keyCustody: keyCustody,
                plan: plan, claim: claim, quarantine: quarantine,
                authorization: authorization, commitment: commitment
            )
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            return .blocked(
                migrationRunID: commitment.migrationRunID,
                reasonDigest: LocalRuntimeStorageChecksum.sha256Hex(
                    for: "projection-rebuild-committed-continuation-blocked-v1\n\(commitment.commitmentDigest)\n\(String(reflecting: error))"
                )
            )
        }
        guard continuation.activation.controlReconciliationRequired == false,
              continuation.activation.barrierReconciliationRequired == false,
              continuation.activation.isolationCleanupRequired == false else {
            return .blocked(
                migrationRunID: commitment.migrationRunID,
                reasonDigest: LocalRuntimeStorageChecksum.sha256Hex(
                    for: "projection-rebuild-committed-continuation-activation-journal-pending\n\(commitment.commitmentDigest)"
                )
            )
        }
        return try await finalizeCommittedDerivedStateRebuild(
            plan: plan, claim: claim, commitment: commitment,
            verification: continuation.verification
        )
    }

    private func finalizeCommittedDerivedStateRebuild(
        plan: RuntimeGenerationRecoveryOperationPlan,
        claim: RuntimeGenerationRecoveryOperationExecutionClaim,
        commitment: RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment,
        verification: RuntimeGenerationVerificationReport
    ) async throws -> RuntimeGenerationCommittedDerivedStateRebuildExecutionResult {
        guard verification.accepted,
              verification.verificationID == commitment.expectedVerificationID else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        if let receipt = try await controlStore.recoveryOperationExecutionReceipt(planID: plan.planID) {
            return .completed(receipt)
        }
        let executedAt = try nowMilliseconds()
        let evidence = LocalRuntimeStorageChecksum.sha256Hex(
            for: "projection-rebuild-committed-continuation-v1\n\(commitment.commitmentDigest)\n\(verification.reportDigest)\n\(commitment.selectorBytesSHA256)"
        )
        let receipt = try RuntimeGenerationControlRecordFactory.recoveryOperationExecutionReceipt(
            id: nextID(), plan: plan, claim: claim,
            candidateGenerationID: commitment.candidateGenerationID,
            verification: verification,
            authorityClassification: .derivedStateEquivalence,
            rebuild: commitment.rebuild,
            outcomeEvidenceDigest: evidence,
            executedAtMilliseconds: executedAt
        )
        let consumption = try RuntimeGenerationControlRecordFactory.recoveryOperationConsumption(
            plan: plan, resultDigest: receipt.receiptDigest,
            consumedAtMilliseconds: executedAt
        )
        let run = try await controlStore.migrationRun(id: commitment.migrationRunID)
        guard let ready = try await controlStore.latestProjectionRebuildLifecycleTransition(
            migrationRunID: run.migrationRunID
        ), ready.phase == .readyForCertification else {
            return .blocked(
                migrationRunID: commitment.migrationRunID,
                reasonDigest: LocalRuntimeStorageChecksum.sha256Hex(
                    for: "projection-rebuild-committed-continuation-ready-transition-missing\n\(commitment.commitmentDigest)"
                )
            )
        }
        let completedTransition = try RuntimeGenerationControlRecordFactory
            .projectionRebuildLifecycleTransition(
                id: nextID(), run: run, phase: .completed,
                priorTransitionDigest: ready.transitionDigest,
                reasonDigest: evidence,
                occurredAtMilliseconds: max(executedAt, ready.occurredAtMilliseconds)
            )
        try await controlStore.finalizeRecoveryOperationExecution(
            receipt: receipt, consumption: consumption,
            completedProjectionRebuildTransition: completedTransition
        )
        return .completed(receipt)
    }

    private func executeFreshConnectionVerification(
        plan: RuntimeGenerationRecoveryOperationPlan,
        quarantine: RuntimeGenerationQuarantineRecord,
        candidateGenerationID: RuntimeStoreGenerationID,
        claim: RuntimeGenerationRecoveryOperationExecutionClaim,
        vault: RuntimeAttachmentVault,
        keyCustody: any RuntimeAttachmentKeyCustody
    ) async throws -> RuntimeGenerationFreshVerificationRecoveryExecutionResult {
        let inspection = try await lifecycle.inspectFreshConnectionVerification(
            candidateGenerationID: candidateGenerationID,
            vault: vault,
            keyCustody: keyCustody
        )
        guard inspection.report.accepted else {
            throw RuntimeGenerationControlError.verificationRejected
        }

        // The receipt points at a durable verification record; the report is
        // persisted before finalization, while finalization atomically writes
        // the receipt and consumes the operation plan.
        try await controlStore.recordVerification(inspection.report)
        let executedAt = try nowMilliseconds()
        let binding = try RuntimeGenerationControlRecordFactory
            .recoveryOperationVerificationBinding(
                verification: inspection.report,
                plan: plan,
                claim: claim,
                observedAtMilliseconds: executedAt
            )
        try await controlStore.recordRecoveryOperationVerificationBinding(binding)
        let outcomeEvidenceDigest = LocalRuntimeStorageChecksum.sha256Hex(
            for: "recovery-fresh-verification-execution-v1\n\(plan.planDigest)\n\(claim.claimDigest)\n\(quarantine.quarantineDigest)\n\(candidateGenerationID.rawValue)\n\(inspection.report.reportDigest)\n\(inspection.isDurableActivationAuthority)"
        )
        let receipt = try RuntimeGenerationControlRecordFactory
            .recoveryOperationExecutionReceipt(
                id: nextID(),
                plan: plan,
                claim: claim,
                candidateGenerationID: candidateGenerationID,
                verification: inspection.report,
                authorityClassification: .acceptedFreshConnectionVerification,
                rebuild: nil,
                outcomeEvidenceDigest: outcomeEvidenceDigest,
                executedAtMilliseconds: executedAt
            )
        let consumption = try RuntimeGenerationControlRecordFactory
            .recoveryOperationConsumption(
                plan: plan,
                resultDigest: receipt.receiptDigest,
                consumedAtMilliseconds: executedAt
            )
        try await controlStore.finalizeRecoveryOperationExecution(
            receipt: receipt,
            consumption: consumption
        )
        return .completed(receipt)
    }

    func authorizeVerifiedBackupRestore(
        backupID: String,
        alternativesReviewedDigest: String,
        consequenceDigest: String,
        authorizationLifetimeMilliseconds: Int64 = 10 * 60 * 1_000
    ) async throws -> RuntimeGenerationVerifiedBackupRecoveryPlan {
        let backup = try await controlStore.backup(id: backupID)
        let authorizedAt = try nowMilliseconds()
        guard authorizationLifetimeMilliseconds > 0,
              authorizedAt <= Int64.max - authorizationLifetimeMilliseconds else {
            throw RuntimeGenerationControlError.malformed(
                field: "recovery_authorization_lifetime"
            )
        }
        let authorization = try RuntimeGenerationControlRecordFactory
            .recoveryAuthorization(
                id: nextID(),
                action: .restoreVerifiedBackup,
                targetDigest: backup.backupDigest,
                alternativesReviewedDigest: alternativesReviewedDigest,
                consequenceDigest: consequenceDigest,
                authorizedAtMilliseconds: authorizedAt,
                expiresAtMilliseconds: authorizedAt + authorizationLifetimeMilliseconds
            )
        try await controlStore.recordRecoveryAuthorization(authorization)
        return RuntimeGenerationVerifiedBackupRecoveryPlan(
            backup: backup,
            authorization: authorization
        )
    }

    func restore(
        _ plan: RuntimeGenerationVerifiedBackupRecoveryPlan,
        source: CanonicalRuntimeStoreV8,
        vault: RuntimeAttachmentVault,
        keyCustody: any RuntimeAttachmentKeyCustody = KeychainRuntimeAttachmentKeyCustody(),
        reservationLifetimeMilliseconds: Int64 = 15 * 60 * 1_000
    ) async throws -> RuntimeGenerationRecoveryResult {
        let durableBackup = try await controlStore.backup(id: plan.backup.backupID)
        let durableAuthorization = try await controlStore.recoveryAuthorization(
            id: plan.authorization.authorizationID
        )
        guard durableBackup == plan.backup,
              durableAuthorization == plan.authorization,
              durableAuthorization.targetDigest == durableBackup.backupDigest else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        return try await lifecycle.restoreVerifiedBackup(
            source: source,
            vault: vault,
            backupID: durableBackup.backupID,
            recoveryAuthorizationID: durableAuthorization.authorizationID,
            keyCustody: keyCustody,
            reservationLifetimeMilliseconds: reservationLifetimeMilliseconds
        )
    }

    func assessRollback(
        source: CanonicalRuntimeStoreV8,
        restoreBaselinePlanID: String
    ) async throws -> RuntimeGenerationRollbackRecord {
        try await lifecycle.assessRollback(
            source: source,
            restoreBaselinePlanID: restoreBaselinePlanID
        )
    }

    func authorizeRollback(
        rollbackAssessmentID: String,
        alternativesReviewedDigest: String,
        consequenceDigest: String,
        authorizationLifetimeMilliseconds: Int64 = 10 * 60 * 1_000
    ) async throws -> RuntimeGenerationReviewedRollbackPlan {
        let assessment = try await controlStore.rollback(id: rollbackAssessmentID)
        let authorizedAt = try nowMilliseconds()
        guard authorizationLifetimeMilliseconds > 0,
              authorizedAt <= Int64.max - authorizationLifetimeMilliseconds else {
            throw RuntimeGenerationControlError.malformed(
                field: "recovery_authorization_lifetime"
            )
        }
        let authorization = try RuntimeGenerationControlRecordFactory
            .recoveryAuthorization(
                id: nextID(),
                action: .rollbackToSafetyBackup,
                targetDigest: assessment.rollbackDigest,
                alternativesReviewedDigest: alternativesReviewedDigest,
                consequenceDigest: consequenceDigest,
                authorizedAtMilliseconds: authorizedAt,
                expiresAtMilliseconds: authorizedAt + authorizationLifetimeMilliseconds
            )
        try await controlStore.recordRecoveryAuthorization(authorization)
        return RuntimeGenerationReviewedRollbackPlan(
            assessment: assessment,
            authorization: authorization
        )
    }

    func rollback(
        _ plan: RuntimeGenerationReviewedRollbackPlan,
        source: CanonicalRuntimeStoreV8,
        vault: RuntimeAttachmentVault,
        keyCustody: any RuntimeAttachmentKeyCustody = KeychainRuntimeAttachmentKeyCustody(),
        reservationLifetimeMilliseconds: Int64 = 15 * 60 * 1_000
    ) async throws -> RuntimeGenerationRollbackResult {
        let durableAssessment = try await controlStore.rollback(
            id: plan.assessment.rollbackID
        )
        let durableAuthorization = try await controlStore.recoveryAuthorization(
            id: plan.authorization.authorizationID
        )
        guard durableAssessment == plan.assessment,
              durableAuthorization == plan.authorization,
              durableAuthorization.action == .rollbackToSafetyBackup,
              durableAuthorization.targetDigest == durableAssessment.rollbackDigest else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        return try await lifecycle.rollbackToSafetyBackup(
            source: source,
            vault: vault,
            rollbackAssessmentID: durableAssessment.rollbackID,
            recoveryAuthorizationID: durableAuthorization.authorizationID,
            keyCustody: keyCustody,
            reservationLifetimeMilliseconds: reservationLifetimeMilliseconds
        )
    }

    func reconcileUnknownActivation(
        candidateGenerationID: RuntimeStoreGenerationID
    ) async throws -> RuntimeGenerationActivationReconciliationResult {
        try await lifecycle.reconcileUnknownActivation(
            candidateGenerationID: candidateGenerationID
        )
    }

    func preserveCrashEvidence(
        candidateGenerationID: RuntimeStoreGenerationID,
        classification: RuntimeGenerationActivationCrashClassification
    ) async throws -> RuntimeGenerationCrashEvidenceResult {
        let candidate = try await controlStore.generationRecord(id: candidateGenerationID)
        return try await preserveCrashEvidence(
            candidate: candidate,
            classification: classification
        )
    }

    func inspectReadOnly(
        quarantineID: String
    ) async throws -> RuntimeGenerationRecoveryInspection {
        let quarantine = try await controlStore.quarantine(id: quarantineID)
        let locations = await generationManager.locations
        let artifactURL = locations.quarantineURL.appendingPathComponent(
            quarantine.originalArtifact.relativePath
        )
        let artifactState: RuntimeGenerationArtifactInspectionState
        var artifactStatus = stat()
        if lstat(artifactURL.path, &artifactStatus) != 0 {
            artifactState = errno == ENOENT ? .missing : .unreadable
        } else {
            do {
                let observed = try RuntimeGenerationDatabaseAuthority.artifact(
                    at: artifactURL,
                    relativePath: quarantine.originalArtifact.relativePath
                )
                artifactState = observed == quarantine.originalArtifact
                    ? .matches
                    : .mismatch(observed)
            } catch {
                artifactState = .unreadable
            }
        }
        let generationState: RuntimeGenerationCandidateInspectionState
        if let generationID = quarantine.originalGenerationID {
            do {
                generationState = .present(
                    try await controlStore.generationRecord(id: generationID)
                )
            } catch let error as RuntimeGenerationControlError {
                if case .recordMissing = error {
                    generationState = .missing
                } else {
                    generationState = .unavailable
                }
            } catch {
                generationState = .unavailable
            }
        } else {
            generationState = .missing
        }
        return RuntimeGenerationRecoveryInspection(
            quarantine: quarantine,
            artifact: artifactState,
            generation: generationState
        )
    }

    /// Copies the preserved bytes into a new, caller-selected directory without
    /// deleting, rewriting, or marking the quarantine resolved. The export is
    /// accepted only after an exact no-follow copy and digest comparison.
    func exportOriginal(
        quarantineID: String,
        destinationDirectoryURL: URL
    ) async throws -> RuntimeGenerationOriginalExportResult {
        let quarantine = try await controlStore.quarantine(id: quarantineID)
        guard quarantine.allowedActions.contains(.exportOriginal) else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        try RuntimeStoreFileDurability.requireDirectory(
            at: destinationDirectoryURL,
            artifact: "recovery_export_destination"
        )
        let destinationPin = try RuntimeStorePathValidation.openPinnedAppPrivateRoot(
            destinationDirectoryURL,
            createFinalComponentIfMissing: false
        )
        try destinationPin.revalidate()
        let locations = await generationManager.locations
        let sourceURL = locations.quarantineURL.appendingPathComponent(
            quarantine.originalArtifact.relativePath
        )
        let exportID = nextID()
        let exportDirectory = destinationDirectoryURL.appendingPathComponent(
            "Ambitions-Recovery-Export-\(exportID)", isDirectory: true
        )
        try fileManager.createDirectory(
            at: exportDirectory, withIntermediateDirectories: false
        )
        try RuntimeStoreFileDurability.applyCompleteProtection(
            at: exportDirectory, artifact: "recovery_original_export"
        )
        let preservation = try RuntimeGenerationForensicArtifactPreserver.preserve(
            sources: [("original", sourceURL)],
            evidenceDirectoryURL: exportDirectory,
            evidenceDirectoryRelativePath: "Ambitions-Recovery-Export-\(exportID)"
        )
        guard preservation.references.count == 1,
              preservation.references[0].preservation == .copied,
              let exported = preservation.references[0].copiedArtifact,
              exported.sha256 == quarantine.originalArtifact.sha256,
              exported.byteCount == quarantine.originalArtifact.byteCount else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        try destinationPin.revalidate()
        try RuntimeStoreFileDurability.synchronizeDirectory(at: exportDirectory)
        try RuntimeStoreFileDurability.synchronizeDirectory(at: destinationDirectoryURL)
        let exportedAt = try nowMilliseconds()
        return RuntimeGenerationOriginalExportResult(
            quarantineID: quarantineID,
            sourceArtifactDigest: quarantine.originalArtifact.artifactDigest,
            exportedArtifact: exported,
            exportedAtMilliseconds: exportedAt,
            exportReceiptDigest: LocalRuntimeStorageChecksum.sha256Hex(
                for: "recovery-original-export-v1\n\(quarantine.quarantineDigest)\n\(exported.artifactDigest)\n\(exportedAt)"
            )
        )
    }

    func authorizeQuarantineRecoveryAction(
        quarantineID: String,
        action: RuntimeGenerationRecoveryAction,
        alternativesReviewedDigest: String,
        consequenceDigest: String,
        authorizationLifetimeMilliseconds: Int64 = 10 * 60 * 1_000
    ) async throws -> RuntimeGenerationRecoveryAuthorization {
        let quarantine = try await controlStore.quarantine(id: quarantineID)
        guard action == .rebuildDerivedState ||
                action == .retryFreshConnectionVerification ||
                action == .explicitlyAuthorizedReset,
              quarantine.allowedActions.contains(action) else {
            throw RuntimeGenerationControlError.recoveryAuthorizationRequired
        }
        let authorizedAt = try nowMilliseconds()
        guard authorizationLifetimeMilliseconds > 0,
              authorizedAt <= Int64.max - authorizationLifetimeMilliseconds else {
            throw RuntimeGenerationControlError.malformed(
                field: "recovery_authorization_lifetime"
            )
        }
        let authorization = try RuntimeGenerationControlRecordFactory.recoveryAuthorization(
            id: nextID(),
            action: action,
            targetDigest: quarantine.quarantineDigest,
            alternativesReviewedDigest: alternativesReviewedDigest,
            consequenceDigest: consequenceDigest,
            authorizedAtMilliseconds: authorizedAt,
            expiresAtMilliseconds: authorizedAt + authorizationLifetimeMilliseconds
        )
        try await controlStore.recordRecoveryAuthorization(authorization)
        return authorization
    }

    func preliminaryReplayInspectionReadOnly(
        generationID: RuntimeStoreGenerationID
    ) async throws -> RuntimeGenerationRecoveryReverification {
        let candidate = try await controlStore.generationRecord(id: generationID)
        let locations = await generationManager.locations
        let databaseURL = locations.databaseURL(for: generationID)
        let database = try await RuntimeGenerationDatabaseAuthority.verifyExactV8ReadOnly(
            at: databaseURL
        )
        do {
            let replay = try await database.transaction(.deferred) { database in
                try RuntimeCanonicalReplayEngine.reconstructInTransaction(database: database)
            }
            let reconstructionDigest: String
            switch replay {
            case let .complete(reconstruction):
                reconstructionDigest = reconstruction.stateDigest
            case .blocked:
                throw RuntimeGenerationControlError.verificationRejected
            }
            let artifact = try RuntimeGenerationDatabaseAuthority.artifact(
                at: databaseURL,
                relativePath: "Runtime.sqlite"
            )
            guard artifact.semanticallyMatches(candidate.authorityManifest.database) else {
                throw RuntimeGenerationControlError.verificationRejected
            }
            try await database.close()
            return RuntimeGenerationRecoveryReverification(
                generationID: generationID,
                replayReconstructionDigest: reconstructionDigest,
                databaseArtifact: artifact,
                verificationDigest: LocalRuntimeStorageChecksum.sha256Hex(
                    for: "preliminary-replay-inspection-v1\n\(candidate.recordDigest)\n\(reconstructionDigest)\n\(artifact.sha256)"
                )
            )
        } catch {
            let operationError = error
            do {
                try await database.close()
            } catch {
                throw LocalRuntimeStorageError.canonicalIOFailure(
                    operation: "close_preliminary_replay_inspection"
                )
            }
            throw operationError
        }
    }

    func inspectFreshConnectionVerification(
        generationID: RuntimeStoreGenerationID,
        vault: RuntimeAttachmentVault,
        keyCustody: any RuntimeAttachmentKeyCustody = KeychainRuntimeAttachmentKeyCustody()
    ) async throws -> RuntimeGenerationFreshConnectionVerificationInspection {
        try await lifecycle.inspectFreshConnectionVerification(
            candidateGenerationID: generationID,
            vault: vault,
            keyCustody: keyCustody
        )
    }

    func preserveCrashEvidence(
        candidate: RuntimeGenerationCandidateRecord,
        classification: RuntimeGenerationActivationCrashClassification
    ) async throws -> RuntimeGenerationCrashEvidenceResult {
        let candidateGenerationID = candidate.authorityManifest.generationID
        let token = nextID()
        var artifacts = try await generationManager.preserveCrashAuthorityBytes(
            candidate: candidate,
            token: token
        )
        let locations = await generationManager.locations
        let evidenceDirectory = locations.quarantineURL.appendingPathComponent(
            "activation-\(token)",
            isDirectory: true
        )
        var controlSnapshotPreserved = false
        var controlSnapshotErrorFingerprint: String?
        do {
            artifacts.append(try await controlStore.createForensicSnapshot(
                at: evidenceDirectory.appendingPathComponent("Control.sqlite"),
                relativePath: "activation-\(token)/Control.sqlite"
            ))
            controlSnapshotPreserved = true
        } catch {
            // Raw no-follow DB/WAL/SHM copies were already preserved by the
            // manager. A corrupt control store must not erase that evidence.
            controlSnapshotErrorFingerprint = LocalRuntimeStorageChecksum.sha256Hex(
                for: "control_forensic_snapshot_failed\n\(redactedErrorCode(error))"
            )
        }
        try RuntimeStoreFileDurability.synchronizeDirectory(at: evidenceDirectory)
        let disposition = Self.quarantineDisposition(for: classification)
        var records: [RuntimeGenerationQuarantineRecord] = []
        var journalUnavailable = false
        for artifact in artifacts {
            let record = try RuntimeGenerationControlRecordFactory.quarantine(
                id: nextID(),
                reason: disposition.reason,
                originalArtifact: artifact,
                originalGenerationID: candidateGenerationID,
                originalManifestDigest: candidate.authorityManifest.manifestDigest,
                diagnosticFingerprint: LocalRuntimeStorageChecksum.sha256Hex(
                    for: "\(disposition.code)\n\(artifact.sha256)\n\(candidate.recordDigest)"
                ),
                allowedActions: disposition.allowedActions,
                quarantinedAtMilliseconds: try nowMilliseconds()
            )
            do {
                try await controlStore.recordQuarantine(record)
                records.append(record)
            } catch {
                journalUnavailable = true
            }
        }
        return RuntimeGenerationCrashEvidenceResult(
            artifacts: artifacts,
            quarantineRecords: records,
            controlSnapshotPreserved: controlSnapshotPreserved,
            controlSnapshotErrorFingerprint: controlSnapshotErrorFingerprint,
            controlJournalUnavailable: journalUnavailable
        )
    }

    private func nextID() -> String {
        environment.uuid.nextUUID().uuidString.lowercased()
    }

    private func nowMilliseconds() throws -> Int64 {
        let milliseconds = environment.clock.now.timeIntervalSince1970 * 1_000
        guard milliseconds.isFinite,
              milliseconds >= 0,
              milliseconds <= Double(Int64.max) else {
            throw RuntimeGenerationControlError.malformed(field: "clock")
        }
        return Int64(milliseconds.rounded(.towardZero))
    }

    nonisolated private static func quarantineDisposition(
        for classification: RuntimeGenerationActivationCrashClassification
    ) -> (
        reason: RuntimeGenerationQuarantineReason,
        code: String,
        allowedActions: [RuntimeGenerationRecoveryAction]
    ) {
        let readOnly: [RuntimeGenerationRecoveryAction] = [
            .inspectReadOnly,
            .exportOriginal,
        ]
        switch classification {
        case .selectorFutureVersion:
            return (.futureManifest, "selector_future_version", readOnly)
        case .selectorCorrupt, .targetAuthorityCorrupt, .targetDatabaseCorrupt:
            return (
                .corruption,
                "authority_corrupt",
                readOnly + [
                    .retryFreshConnectionVerification,
                    .rebuildDerivedState,
                    .explicitlyAuthorizedReset,
                ]
            )
        case .selectorMissing, .targetAuthorityMissing, .targetDatabaseMissing:
            return (
                .corruption,
                "authority_missing",
                readOnly + [
                    .restoreVerifiedBackup,
                    .rebuildDerivedState,
                    .explicitlyAuthorizedReset,
                ]
            )
        case .selectorUnavailable,
             .targetAuthorityUnavailable,
             .targetDatabaseUnavailable,
             .unexpectedSelector,
             .splitAuthority,
             .externalAuthorityAmbiguous:
            return (.unknownValue, "authority_ambiguous", readOnly)
        case .controlAuthorityUnavailable:
            return (.corruption, "control_authority_unavailable", readOnly)
        case .committed, .unchanged:
            return (.failedVerification, "reconciliation_evidence", readOnly)
        }
    }

    private func redactedErrorCode(_ error: Error) -> String {
        if error is CancellationError { return "cancelled" }
        if error is RuntimeGenerationControlError { return "generation_control" }
        if error is LocalRuntimeStorageError { return "local_runtime_storage" }
        return "unclassified"
    }
}

#if DEBUG
extension RuntimeGenerationRecoveryService {
    nonisolated static func testOnlyQuarantineDisposition(
        for classification: RuntimeGenerationActivationCrashClassification
    ) -> (code: String, actions: [RuntimeGenerationRecoveryAction]) {
        let value = quarantineDisposition(for: classification)
        return (value.code, value.allowedActions)
    }
}
#endif
