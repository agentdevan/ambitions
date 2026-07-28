import Foundation

enum RuntimeGenerationControlRecordFactory {
    static func candidate(
        authorityManifest: RuntimeGenerationAuthorityManifest,
        authorityManifestFileSHA256: String,
        selectorFileSHA256: String
    ) throws -> RuntimeGenerationCandidateRecord {
        try authorityManifest.validate()
        let draft = RuntimeGenerationCandidateRecord(
            authorityManifest: authorityManifest,
            authorityManifestFileSHA256: authorityManifestFileSHA256,
            selectorFileSHA256: selectorFileSHA256,
            recordDigest: ""
        )
        return RuntimeGenerationCandidateRecord(
            authorityManifest: draft.authorityManifest,
            authorityManifestFileSHA256: draft.authorityManifestFileSHA256,
            selectorFileSHA256: draft.selectorFileSHA256,
            recordDigest: try semanticDigest(draft, removing: "recordDigest")
        )
    }

    static func projectionRebuildCandidateReservation(
        id: String,
        plan: RuntimeGenerationRecoveryOperationPlan,
        claim: RuntimeGenerationRecoveryOperationExecutionClaim,
        migrationRun: RuntimeGenerationMigrationRun,
        reservation: RuntimeGenerationReservation,
        candidatePreparation: RuntimeGenerationCandidatePreparationRecord,
        expectedVerificationID: String,
        expectedActivationIntentID: String,
        reservedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationProjectionRebuildCandidateReservation {
        let draft = RuntimeGenerationProjectionRebuildCandidateReservation(
            candidateReservationID: id,
            recoveryExecutionPlanID: plan.planID,
            recoveryExecutionClaimID: claim.claimID,
            recoveryExecutionClaimEpoch: claim.claimEpoch,
            migrationRunID: migrationRun.migrationRunID,
            reservationID: reservation.reservationID,
            candidatePreparationID: candidatePreparation.preparationID,
            candidateGenerationID: reservation.candidateGenerationID,
            expectedVerificationID: expectedVerificationID,
            expectedActivationIntentID: expectedActivationIntentID,
            reservedAtMilliseconds: reservedAtMilliseconds,
            reservationDigest: ""
        )
        try validate(draft, allowEmptyDigest: true)
        return RuntimeGenerationProjectionRebuildCandidateReservation(
            candidateReservationID: draft.candidateReservationID,
            recoveryExecutionPlanID: draft.recoveryExecutionPlanID,
            recoveryExecutionClaimID: draft.recoveryExecutionClaimID,
            recoveryExecutionClaimEpoch: draft.recoveryExecutionClaimEpoch,
            migrationRunID: draft.migrationRunID,
            reservationID: draft.reservationID,
            candidatePreparationID: draft.candidatePreparationID,
            candidateGenerationID: draft.candidateGenerationID,
            expectedVerificationID: draft.expectedVerificationID,
            expectedActivationIntentID: draft.expectedActivationIntentID,
            reservedAtMilliseconds: draft.reservedAtMilliseconds,
            reservationDigest: try semanticDigest(draft, removing: "reservationDigest")
        )
    }

    static func projectionRebuildCandidateAuthorityCommitment(
        id: String,
        candidateReservation: RuntimeGenerationProjectionRebuildCandidateReservation,
        candidateRecord: RuntimeGenerationCandidateRecord,
        candidatePreparationCompletion: RuntimeGenerationCandidatePreparationCompletion,
        authorityManifestBytes: Data,
        selectorBytes: Data,
        replayAudit: RuntimeGenerationCandidateReplayAuditRecord,
        rebuild: RuntimeGenerationRebuildRecord,
        committedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment {
        let draft = RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment(
            commitmentID: id,
            candidateReservationID: candidateReservation.candidateReservationID,
            recoveryExecutionPlanID: candidateReservation.recoveryExecutionPlanID,
            recoveryExecutionClaimID: candidateReservation.recoveryExecutionClaimID,
            recoveryExecutionClaimEpoch: candidateReservation.recoveryExecutionClaimEpoch,
            migrationRunID: candidateReservation.migrationRunID,
            reservationID: candidateReservation.reservationID,
            candidatePreparationID: candidateReservation.candidatePreparationID,
            candidateGenerationID: candidateReservation.candidateGenerationID,
            expectedVerificationID: candidateReservation.expectedVerificationID,
            expectedActivationIntentID: candidateReservation.expectedActivationIntentID,
            candidateRecord: candidateRecord,
            candidatePreparationCompletion: candidatePreparationCompletion,
            authorityManifestBytes: authorityManifestBytes,
            authorityManifestBytesSHA256: LocalRuntimeStorageChecksum.sha256Hex(for: authorityManifestBytes),
            selectorBytes: selectorBytes,
            selectorBytesSHA256: LocalRuntimeStorageChecksum.sha256Hex(for: selectorBytes),
            replayAuditID: replayAudit.auditID,
            replayAuditDigest: replayAudit.auditDigest,
            replayReconstructionDigest: replayAudit.reconstructionDigest ?? "",
            rebuild: rebuild,
            committedAtMilliseconds: committedAtMilliseconds,
            commitmentDigest: ""
        )
        try validate(draft, allowEmptyDigest: true)
        return RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment(
            commitmentID: draft.commitmentID,
            candidateReservationID: draft.candidateReservationID,
            recoveryExecutionPlanID: draft.recoveryExecutionPlanID,
            recoveryExecutionClaimID: draft.recoveryExecutionClaimID,
            recoveryExecutionClaimEpoch: draft.recoveryExecutionClaimEpoch,
            migrationRunID: draft.migrationRunID,
            reservationID: draft.reservationID,
            candidatePreparationID: draft.candidatePreparationID,
            candidateGenerationID: draft.candidateGenerationID,
            expectedVerificationID: draft.expectedVerificationID,
            expectedActivationIntentID: draft.expectedActivationIntentID,
            candidateRecord: draft.candidateRecord,
            candidatePreparationCompletion: draft.candidatePreparationCompletion,
            authorityManifestBytes: draft.authorityManifestBytes,
            authorityManifestBytesSHA256: draft.authorityManifestBytesSHA256,
            selectorBytes: draft.selectorBytes,
            selectorBytesSHA256: draft.selectorBytesSHA256,
            replayAuditID: draft.replayAuditID,
            replayAuditDigest: draft.replayAuditDigest,
            replayReconstructionDigest: draft.replayReconstructionDigest,
            rebuild: draft.rebuild,
            committedAtMilliseconds: draft.committedAtMilliseconds,
            commitmentDigest: try semanticDigest(draft, removing: "commitmentDigest")
        )
    }

    static func validate(
        _ record: RuntimeGenerationProjectionRebuildCandidateReservation,
        allowEmptyDigest: Bool = false
    ) throws {
        for (value, field) in [
            (record.candidateReservationID, "projection_candidate_reservation_id"),
            (record.recoveryExecutionPlanID, "projection_candidate_plan_id"),
            (record.recoveryExecutionClaimID, "projection_candidate_claim_id"),
            (record.migrationRunID, "projection_candidate_run_id"),
            (record.reservationID, "projection_candidate_runtime_reservation_id"),
            (record.candidatePreparationID, "projection_candidate_preparation_id"),
            (record.expectedVerificationID, "projection_candidate_verification_id"),
            (record.expectedActivationIntentID, "projection_candidate_activation_intent_id"),
        ] { try RuntimeGenerationControlValidation.requireIdentifier(value, field: field) }
        guard record.recoveryExecutionClaimEpoch > 0,
              record.reservedAtMilliseconds >= 0,
              record.expectedVerificationID != record.expectedActivationIntentID,
              allowEmptyDigest ||
                try semanticDigest(record, removing: "reservationDigest") == record.reservationDigest
        else { throw corrupt("projection_rebuild_candidate_reservation", record.candidateReservationID) }
        if !allowEmptyDigest {
            try RuntimeGenerationControlValidation.requireDigest(record.reservationDigest, field: "projection_candidate_reservation_digest")
        }
    }

    static func validate(
        _ record: RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment,
        allowEmptyDigest: Bool = false
    ) throws {
        for (value, field) in [
            (record.commitmentID, "projection_candidate_commitment_id"),
            (record.candidateReservationID, "projection_candidate_commitment_reservation_id"),
            (record.recoveryExecutionPlanID, "projection_candidate_commitment_plan_id"),
            (record.recoveryExecutionClaimID, "projection_candidate_commitment_claim_id"),
            (record.migrationRunID, "projection_candidate_commitment_run_id"),
            (record.reservationID, "projection_candidate_commitment_runtime_reservation_id"),
            (record.candidatePreparationID, "projection_candidate_commitment_preparation_id"),
            (record.expectedVerificationID, "projection_candidate_commitment_verification_id"),
            (record.expectedActivationIntentID, "projection_candidate_commitment_intent_id"),
            (record.replayAuditID, "projection_candidate_commitment_audit_id"),
        ] { try RuntimeGenerationControlValidation.requireIdentifier(value, field: field) }
        for (value, field) in [
            (record.authorityManifestBytesSHA256, "projection_candidate_commitment_authority_bytes_sha"),
            (record.selectorBytesSHA256, "projection_candidate_commitment_selector_bytes_sha"),
            (record.replayAuditDigest, "projection_candidate_commitment_audit_digest"),
            (record.replayReconstructionDigest, "projection_candidate_commitment_reconstruction_digest"),
        ] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        try record.candidateRecord.validate()
        try validate(record.candidatePreparationCompletion)
        try validate(record.rebuild)
        guard record.recoveryExecutionClaimEpoch > 0,
              record.committedAtMilliseconds >= 0,
              record.authorityManifestBytes.count > 0,
              record.selectorBytes.count > 0,
              LocalRuntimeStorageChecksum.sha256Hex(for: record.authorityManifestBytes) == record.authorityManifestBytesSHA256,
              LocalRuntimeStorageChecksum.sha256Hex(for: record.selectorBytes) == record.selectorBytesSHA256,
              record.authorityManifestBytesSHA256 == record.candidateRecord.authorityManifestFileSHA256,
              record.selectorBytesSHA256 == record.candidateRecord.selectorFileSHA256,
              try RuntimeGenerationControlCodec.encode(record.candidateRecord.authorityManifest) == record.authorityManifestBytes,
              try projectionRebuildCandidateSelector(record).generationID == record.candidateGenerationID,
              record.candidatePreparationCompletion.candidateRecordDigest == record.candidateRecord.recordDigest,
              record.candidateRecord.authorityManifest.generationID == record.candidateGenerationID,
              record.rebuild.candidateGenerationID == record.candidateGenerationID,
              record.rebuild.recoveryExecutionPlanID == record.recoveryExecutionPlanID,
              record.rebuild.recoveryExecutionClaimID == record.recoveryExecutionClaimID,
              record.rebuild.recoveryExecutionClaimEpoch == record.recoveryExecutionClaimEpoch,
              record.rebuild.replayReconstructionDigest == record.replayReconstructionDigest,
              allowEmptyDigest || try semanticDigest(record, removing: "commitmentDigest") == record.commitmentDigest
        else { throw corrupt("projection_rebuild_candidate_commitment", record.commitmentID) }
        if !allowEmptyDigest {
            try RuntimeGenerationControlValidation.requireDigest(record.commitmentDigest, field: "projection_candidate_commitment_digest")
        }
    }

    /// Decodes and binds the staged selector to the immutable candidate
    /// authority.  A projection-rebuild commitment is only preparation
    /// evidence: this deliberately does not write or publish the selector.
    static func projectionRebuildCandidateSelector(
        _ record: RuntimeGenerationProjectionRebuildCandidateAuthorityCommitment
    ) throws -> RuntimeGenerationActiveSelector {
        let selector = try RuntimeGenerationActiveSelectorCodec.decode(record.selectorBytes)
        let manifest = record.candidateRecord.authorityManifest
        let expectedRelativeDatabasePath =
            "Stores/\(record.candidateGenerationID.pathComponent)/Runtime.sqlite"
        guard try RuntimeGenerationActiveSelectorCodec.encode(selector) == record.selectorBytes,
              selector.formatVersion == runtimeGenerationActiveSelectorVersion,
              selector.generationID == record.candidateGenerationID,
              selector.generationID == manifest.generationID,
              selector.schemaVersion == runtimeCanonicalAttachmentSchemaVersion,
              selector.relativeDatabasePath == expectedRelativeDatabasePath,
              selector.authorityManifestDigest == manifest.manifestDigest,
              selector.authorityManifestFileSHA256 == record.candidateRecord.authorityManifestFileSHA256,
              selector.verificationID == record.expectedVerificationID,
              selector.activationIntentID == record.expectedActivationIntentID,
              selector.priorGenerationID == manifest.sourceGenerationID,
              selector.priorAuthorityManifestDigest == manifest.sourceGenerationDigest,
              selector.preparedAtMilliseconds >= manifest.createdAtMilliseconds,
              selector.preparedAtMilliseconds <= record.committedAtMilliseconds else {
            throw corrupt("projection_rebuild_candidate_selector", record.commitmentID)
        }
        return selector
    }

    static func reservation(
        id: String,
        operationKind: RuntimeGenerationOperationKind,
        candidateGenerationID: RuntimeStoreGenerationID,
        sourceGenerationID: RuntimeStoreGenerationID?,
        sourceGenerationDigest: String?,
        expectedActiveManifestDigest: String?,
        createdAtMilliseconds: Int64
    ) throws -> RuntimeGenerationReservation {
        let draft = RuntimeGenerationReservation(
            reservationID: id,
            operationKind: operationKind,
            candidateGenerationID: candidateGenerationID,
            sourceGenerationID: sourceGenerationID,
            sourceGenerationDigest: sourceGenerationDigest,
            expectedActiveManifestDigest: expectedActiveManifestDigest,
            targetSchemaVersion: runtimeCanonicalAttachmentSchemaVersion,
            createdAtMilliseconds: createdAtMilliseconds,
            reservationDigest: ""
        )
        return RuntimeGenerationReservation(
            reservationID: draft.reservationID,
            operationKind: draft.operationKind,
            candidateGenerationID: draft.candidateGenerationID,
            sourceGenerationID: draft.sourceGenerationID,
            sourceGenerationDigest: draft.sourceGenerationDigest,
            expectedActiveManifestDigest: draft.expectedActiveManifestDigest,
            targetSchemaVersion: draft.targetSchemaVersion,
            createdAtMilliseconds: draft.createdAtMilliseconds,
            reservationDigest: try semanticDigest(draft, removing: "reservationDigest")
        )
    }

    static func operationLease(
        id: String,
        reservationID: String,
        ownerInstanceID: String,
        leaseEpoch: Int64,
        fencingToken: Int64,
        priorLeaseDigest: String?,
        issuedAtMilliseconds: Int64,
        expiresAtMilliseconds: Int64
    ) throws -> RuntimeGenerationOperationLease {
        guard leaseEpoch > 0, fencingToken > 0,
              issuedAtMilliseconds >= 0,
              expiresAtMilliseconds > issuedAtMilliseconds,
              expiresAtMilliseconds - issuedAtMilliseconds <=
                runtimeGenerationMaximumOperationLeaseMilliseconds,
              (leaseEpoch == 1) == (priorLeaseDigest == nil) else {
            throw RuntimeGenerationControlError.malformed(field: "operation_lease")
        }
        try RuntimeGenerationControlValidation.requireIdentifier(id, field: "lease_id")
        try RuntimeGenerationControlValidation.requireIdentifier(
            reservationID, field: "lease_reservation_id"
        )
        try RuntimeGenerationControlValidation.requireIdentifier(
            ownerInstanceID, field: "lease_owner_instance_id"
        )
        if let priorLeaseDigest {
            try RuntimeGenerationControlValidation.requireDigest(
                priorLeaseDigest, field: "prior_lease_digest"
            )
        }
        let draft = RuntimeGenerationOperationLease(
            leaseID: id,
            reservationID: reservationID,
            ownerInstanceID: ownerInstanceID,
            leaseEpoch: leaseEpoch,
            fencingToken: fencingToken,
            priorLeaseDigest: priorLeaseDigest,
            issuedAtMilliseconds: issuedAtMilliseconds,
            expiresAtMilliseconds: expiresAtMilliseconds,
            leaseDigest: ""
        )
        return RuntimeGenerationOperationLease(
            leaseID: draft.leaseID,
            reservationID: draft.reservationID,
            ownerInstanceID: draft.ownerInstanceID,
            leaseEpoch: draft.leaseEpoch,
            fencingToken: draft.fencingToken,
            priorLeaseDigest: draft.priorLeaseDigest,
            issuedAtMilliseconds: draft.issuedAtMilliseconds,
            expiresAtMilliseconds: draft.expiresAtMilliseconds,
            leaseDigest: try semanticDigest(draft, removing: "leaseDigest")
        )
    }

    static func backupPreparation(
        id: String,
        backupID: String,
        reservation: RuntimeGenerationReservation,
        operationLease: RuntimeGenerationOperationLease,
        sourceGenerationID: RuntimeStoreGenerationID,
        sourceGenerationDigest: String,
        expectedActiveManifestDigest: String,
        hiddenDirectoryName: String,
        createdAtMilliseconds: Int64
    ) throws -> RuntimeGenerationBackupPreparationRecord {
        let draft = RuntimeGenerationBackupPreparationRecord(
            preparationID: id,
            backupID: backupID,
            reservationID: reservation.reservationID,
            operationLeaseID: operationLease.leaseID,
            operationFencingToken: operationLease.fencingToken,
            sourceGenerationID: sourceGenerationID,
            sourceGenerationDigest: sourceGenerationDigest,
            expectedActiveManifestDigest: expectedActiveManifestDigest,
            hiddenDirectoryName: hiddenDirectoryName,
            finalDirectoryName: backupID,
            createdAtMilliseconds: createdAtMilliseconds,
            preparationDigest: ""
        )
        return RuntimeGenerationBackupPreparationRecord(
            preparationID: draft.preparationID,
            backupID: draft.backupID,
            reservationID: draft.reservationID,
            operationLeaseID: draft.operationLeaseID,
            operationFencingToken: draft.operationFencingToken,
            sourceGenerationID: draft.sourceGenerationID,
            sourceGenerationDigest: draft.sourceGenerationDigest,
            expectedActiveManifestDigest: draft.expectedActiveManifestDigest,
            hiddenDirectoryName: draft.hiddenDirectoryName,
            finalDirectoryName: draft.finalDirectoryName,
            createdAtMilliseconds: draft.createdAtMilliseconds,
            preparationDigest: try semanticDigest(draft, removing: "preparationDigest")
        )
    }

    static func backupPreparationCompletion(
        preparationID: String,
        backup: RuntimeGenerationBackupRecord,
        directoryDevice: UInt64,
        directoryInode: UInt64,
        interiorArtifactCount: Int64,
        interiorByteCount: Int64,
        interiorInventoryDigest: String,
        durabilityWitnessDigest: String,
        completedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationBackupPreparationCompletion {
        let draft = RuntimeGenerationBackupPreparationCompletion(
            preparationID: preparationID,
            backup: backup,
            directoryDevice: directoryDevice,
            directoryInode: directoryInode,
            interiorArtifactCount: interiorArtifactCount,
            interiorByteCount: interiorByteCount,
            interiorInventoryDigest: interiorInventoryDigest,
            durabilityWitnessDigest: durabilityWitnessDigest,
            completedAtMilliseconds: completedAtMilliseconds,
            completionDigest: ""
        )
        return RuntimeGenerationBackupPreparationCompletion(
            preparationID: draft.preparationID,
            backup: draft.backup,
            directoryDevice: draft.directoryDevice,
            directoryInode: draft.directoryInode,
            interiorArtifactCount: draft.interiorArtifactCount,
            interiorByteCount: draft.interiorByteCount,
            interiorInventoryDigest: draft.interiorInventoryDigest,
            durabilityWitnessDigest: draft.durabilityWitnessDigest,
            completedAtMilliseconds: draft.completedAtMilliseconds,
            completionDigest: try semanticDigest(draft, removing: "completionDigest")
        )
    }

    static func backupPreparationConsumption(
        preparationID: String,
        backupID: String,
        operationLease: RuntimeGenerationOperationLease,
        finalDirectoryDevice: UInt64,
        finalDirectoryInode: UInt64,
        consumedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationBackupPreparationConsumption {
        let draft = RuntimeGenerationBackupPreparationConsumption(
            preparationID: preparationID,
            backupID: backupID,
            operationLeaseID: operationLease.leaseID,
            operationFencingToken: operationLease.fencingToken,
            finalDirectoryDevice: finalDirectoryDevice,
            finalDirectoryInode: finalDirectoryInode,
            consumedAtMilliseconds: consumedAtMilliseconds,
            consumptionDigest: ""
        )
        return RuntimeGenerationBackupPreparationConsumption(
            preparationID: draft.preparationID,
            backupID: draft.backupID,
            operationLeaseID: draft.operationLeaseID,
            operationFencingToken: draft.operationFencingToken,
            finalDirectoryDevice: draft.finalDirectoryDevice,
            finalDirectoryInode: draft.finalDirectoryInode,
            consumedAtMilliseconds: draft.consumedAtMilliseconds,
            consumptionDigest: try semanticDigest(draft, removing: "consumptionDigest")
        )
    }

    static func candidatePreparation(
        id: String,
        reservation: RuntimeGenerationReservation,
        operationLease: RuntimeGenerationOperationLease,
        stagingDirectoryName: String,
        recoveryExecutionPlanID: String? = nil,
        recoveryExecutionClaimID: String? = nil,
        recoveryExecutionClaimEpoch: Int64? = nil
    ) throws -> RuntimeGenerationCandidatePreparationRecord {
        let draft = RuntimeGenerationCandidatePreparationRecord(
            preparationID: id,
            reservationID: reservation.reservationID,
            operationLeaseID: operationLease.leaseID,
            operationFencingToken: operationLease.fencingToken,
            operationKind: reservation.operationKind,
            candidateGenerationID: reservation.candidateGenerationID,
            sourceGenerationID: reservation.sourceGenerationID,
            sourceGenerationDigest: reservation.sourceGenerationDigest,
            expectedActiveManifestDigest: reservation.expectedActiveManifestDigest,
            recoveryExecutionPlanID: recoveryExecutionPlanID,
            recoveryExecutionClaimID: recoveryExecutionClaimID,
            recoveryExecutionClaimEpoch: recoveryExecutionClaimEpoch,
            stagingDirectoryName: stagingDirectoryName,
            createdAtMilliseconds: reservation.createdAtMilliseconds,
            preparationDigest: ""
        )
        return RuntimeGenerationCandidatePreparationRecord(
            preparationID: draft.preparationID,
            reservationID: draft.reservationID,
            operationLeaseID: draft.operationLeaseID,
            operationFencingToken: draft.operationFencingToken,
            operationKind: draft.operationKind,
            candidateGenerationID: draft.candidateGenerationID,
            sourceGenerationID: draft.sourceGenerationID,
            sourceGenerationDigest: draft.sourceGenerationDigest,
            expectedActiveManifestDigest: draft.expectedActiveManifestDigest,
            recoveryExecutionPlanID: draft.recoveryExecutionPlanID,
            recoveryExecutionClaimID: draft.recoveryExecutionClaimID,
            recoveryExecutionClaimEpoch: draft.recoveryExecutionClaimEpoch,
            stagingDirectoryName: draft.stagingDirectoryName,
            createdAtMilliseconds: draft.createdAtMilliseconds,
            preparationDigest: try semanticDigest(draft, removing: "preparationDigest")
        )
    }

    static func backupPreparationRecovery(
        preparationID: String,
        operationLease: RuntimeGenerationOperationLease,
        classification: RuntimeGenerationBackupPreparationRecoveryClassification,
        preservedEntries: [RuntimeGenerationPreservedPreparationEntry],
        recoveredAtMilliseconds: Int64
    ) throws -> RuntimeGenerationBackupPreparationRecovery {
        let orderedEntries = preservedEntries.sorted {
            ($0.role.rawValue, $0.location.rawValue, $0.basename) <
                ($1.role.rawValue, $1.location.rawValue, $1.basename)
        }
        let draft = RuntimeGenerationBackupPreparationRecovery(
            preparationID: preparationID,
            operationLeaseID: operationLease.leaseID,
            operationFencingToken: operationLease.fencingToken,
            classification: classification,
            preservedEntries: orderedEntries,
            recoveredAtMilliseconds: recoveredAtMilliseconds,
            recoveryDigest: ""
        )
        return RuntimeGenerationBackupPreparationRecovery(
            preparationID: draft.preparationID,
            operationLeaseID: draft.operationLeaseID,
            operationFencingToken: draft.operationFencingToken,
            classification: draft.classification,
            preservedEntries: draft.preservedEntries,
            recoveredAtMilliseconds: draft.recoveredAtMilliseconds,
            recoveryDigest: try semanticDigest(draft, removing: "recoveryDigest")
        )
    }

    static func candidatePreparationCompletion(
        preparationID: String,
        candidateRecordDigest: String,
        directoryDevice: UInt64,
        directoryInode: UInt64,
        interiorArtifactCount: Int64,
        interiorByteCount: Int64,
        interiorInventoryDigest: String,
        durabilityWitnessDigest: String,
        completedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationCandidatePreparationCompletion {
        let draft = RuntimeGenerationCandidatePreparationCompletion(
            preparationID: preparationID,
            candidateRecordDigest: candidateRecordDigest,
            directoryDevice: directoryDevice,
            directoryInode: directoryInode,
            interiorArtifactCount: interiorArtifactCount,
            interiorByteCount: interiorByteCount,
            interiorInventoryDigest: interiorInventoryDigest,
            durabilityWitnessDigest: durabilityWitnessDigest,
            completedAtMilliseconds: completedAtMilliseconds,
            completionDigest: ""
        )
        return RuntimeGenerationCandidatePreparationCompletion(
            preparationID: draft.preparationID,
            candidateRecordDigest: draft.candidateRecordDigest,
            directoryDevice: draft.directoryDevice,
            directoryInode: draft.directoryInode,
            interiorArtifactCount: draft.interiorArtifactCount,
            interiorByteCount: draft.interiorByteCount,
            interiorInventoryDigest: draft.interiorInventoryDigest,
            durabilityWitnessDigest: draft.durabilityWitnessDigest,
            completedAtMilliseconds: draft.completedAtMilliseconds,
            completionDigest: try semanticDigest(draft, removing: "completionDigest")
        )
    }

    static func candidatePreparationDisposition(
        preparationID: String,
        operationLeaseID: String,
        operationFencingToken: Int64,
        kind: RuntimeGenerationCandidatePreparationDispositionKind,
        failureClassification: RuntimeGenerationCandidatePreparationFailureClassification? = nil,
        forensicCode: RuntimeGenerationCandidatePreparationForensicCode? = nil,
        preservedEntries: [RuntimeGenerationPreservedPreparationEntry] = [],
        authorityDigest: String,
        disposedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationCandidatePreparationDisposition {
        let draft = RuntimeGenerationCandidatePreparationDisposition(
            preparationID: preparationID,
            operationLeaseID: operationLeaseID,
            operationFencingToken: operationFencingToken,
            kind: kind,
            failureClassification: failureClassification,
            forensicCode: forensicCode,
            preservedEntries: preservedEntries.sorted {
                ($0.role.rawValue, $0.location.rawValue, $0.basename) <
                    ($1.role.rawValue, $1.location.rawValue, $1.basename)
            },
            authorityDigest: authorityDigest,
            disposedAtMilliseconds: disposedAtMilliseconds,
            dispositionDigest: ""
        )
        return RuntimeGenerationCandidatePreparationDisposition(
            preparationID: draft.preparationID,
            operationLeaseID: draft.operationLeaseID,
            operationFencingToken: draft.operationFencingToken,
            kind: draft.kind,
            failureClassification: draft.failureClassification,
            forensicCode: draft.forensicCode,
            preservedEntries: draft.preservedEntries,
            authorityDigest: draft.authorityDigest,
            disposedAtMilliseconds: draft.disposedAtMilliseconds,
            dispositionDigest: try semanticDigest(draft, removing: "dispositionDigest")
        )
    }

    static func candidateReplayAudit(
        id: String,
        preparation: RuntimeGenerationCandidatePreparationRecord,
        operationLease: RuntimeGenerationOperationLease,
        outcome: RuntimeGenerationCandidateReplayAuditOutcomeKind,
        blockedInvariant: RuntimeCanonicalReplayInvariantCode? = nil,
        deferredReason: RuntimeGenerationCandidateReplayAuditDeferredReason? = nil,
        replayCheckpointDigest: String? = nil,
        replayCertificateDigest: String? = nil,
        reconstructionDigest: String? = nil,
        auditedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationCandidateReplayAuditRecord {
        let draft = RuntimeGenerationCandidateReplayAuditRecord(
            auditID: id,
            preparationID: preparation.preparationID,
            reservationID: preparation.reservationID,
            candidateGenerationID: preparation.candidateGenerationID,
            operationLeaseID: operationLease.leaseID,
            operationLeaseEpoch: operationLease.leaseEpoch,
            operationFencingToken: operationLease.fencingToken,
            outcome: outcome,
            blockedInvariant: blockedInvariant,
            deferredReason: deferredReason,
            replayCheckpointDigest: replayCheckpointDigest,
            replayCertificateDigest: replayCertificateDigest,
            reconstructionDigest: reconstructionDigest,
            auditedAtMilliseconds: auditedAtMilliseconds,
            auditDigest: ""
        )
        try validate(draft, allowEmptyDigest: true)
        return RuntimeGenerationCandidateReplayAuditRecord(
            auditID: draft.auditID,
            preparationID: draft.preparationID,
            reservationID: draft.reservationID,
            candidateGenerationID: draft.candidateGenerationID,
            operationLeaseID: draft.operationLeaseID,
            operationLeaseEpoch: draft.operationLeaseEpoch,
            operationFencingToken: draft.operationFencingToken,
            outcome: draft.outcome,
            blockedInvariant: draft.blockedInvariant,
            deferredReason: draft.deferredReason,
            replayCheckpointDigest: draft.replayCheckpointDigest,
            replayCertificateDigest: draft.replayCertificateDigest,
            reconstructionDigest: draft.reconstructionDigest,
            auditedAtMilliseconds: draft.auditedAtMilliseconds,
            auditDigest: try semanticDigest(draft, removing: "auditDigest")
        )
    }

    static func backup(
        id: String,
        sourceGenerationID: RuntimeStoreGenerationID,
        sourceGenerationDigest: String,
        sourceFence: RuntimeGenerationRevisionFence,
        authorityFenceToken: RuntimeGenerationAuthorityFenceToken,
        databaseArtifact: RuntimeGenerationArtifact,
        sourceWALArtifact: RuntimeGenerationArtifact?,
        blobSetDigest: String,
        attachmentManifestSetDigest: String,
        keyIdentityDigest: String,
        vaultArtifacts: [RuntimeGenerationVaultBlobArtifact],
        counts: RuntimeGenerationCounts,
        boundaries: RuntimeGenerationBoundaries,
        semanticEquivalenceDigest: String,
        createdAtMilliseconds: Int64
    ) throws -> RuntimeGenerationBackupRecord {
        let semanticDatabaseArtifact = try databaseArtifact.semanticArtifact()
        let semanticSourceWALArtifact = try sourceWALArtifact?.semanticArtifact()
        let orderedArtifacts = try vaultArtifacts.map { artifact in
            RuntimeGenerationVaultBlobArtifact(
                blobID: artifact.blobID,
                manifestDigest: artifact.manifestDigest,
                opaqueRelativeDirectory: artifact.opaqueRelativeDirectory,
                payloadArtifact: try artifact.payloadArtifact.semanticArtifact(),
                manifestArtifact: try artifact.manifestArtifact.semanticArtifact(),
                finalizationArtifact: try artifact.finalizationArtifact?.semanticArtifact(),
                envelopeDigest: artifact.envelopeDigest,
                wrappingKeyID: artifact.wrappingKeyID,
                wrappingKeyVersion: artifact.wrappingKeyVersion,
                artifactDigest: artifact.artifactDigest,
                backupPayloadArtifact: try artifact.backupPayloadArtifact?.semanticArtifact(),
                backupManifestArtifact: try artifact.backupManifestArtifact?.semanticArtifact(),
                backupFinalizationArtifact: try artifact.backupFinalizationArtifact?
                    .semanticArtifact()
            )
        }.sorted { $0.blobID < $1.blobID }
        try authorityFenceToken.validate()
        guard authorityFenceToken.generationID == sourceGenerationID else {
            throw RuntimeGenerationControlError.malformed(field: "backup_fence_token")
        }
        let verificationMethod =
            "sqlite-online-backup-consolidated-v1+vault-authenticated-copy-v1"
        let verificationDigest = LocalRuntimeStorageChecksum.sha256Hex(for: ([
            verificationMethod,
            sourceFence.fenceDigest,
            authorityFenceToken.tokenDigest,
            semanticDatabaseArtifact.sha256,
            blobSetDigest,
            attachmentManifestSetDigest,
            keyIdentityDigest,
            semanticEquivalenceDigest,
        ] + orderedArtifacts.flatMap { artifact in
            [
                artifact.artifactDigest,
                artifact.backupPayloadArtifact?.sha256 ?? "",
                artifact.backupManifestArtifact?.sha256 ?? "",
                artifact.backupFinalizationArtifact?.sha256 ?? "",
            ]
        }).joined(separator: "\n"))
        let draft = RuntimeGenerationBackupRecord(
            backupID: id,
            sourceGenerationID: sourceGenerationID,
            sourceGenerationDigest: sourceGenerationDigest,
            sourceFence: sourceFence,
            authorityFenceToken: authorityFenceToken,
            databaseArtifact: semanticDatabaseArtifact,
            sourceWALArtifact: semanticSourceWALArtifact,
            blobSetDigest: blobSetDigest,
            attachmentManifestSetDigest: attachmentManifestSetDigest,
            keyIdentityDigest: keyIdentityDigest,
            vaultArtifacts: orderedArtifacts,
            counts: counts,
            boundaries: boundaries,
            semanticEquivalenceDigest: semanticEquivalenceDigest,
            verificationMethod: verificationMethod,
            verificationDigest: verificationDigest,
            createdAtMilliseconds: createdAtMilliseconds,
            backupDigest: ""
        )
        return RuntimeGenerationBackupRecord(
            backupID: draft.backupID,
            sourceGenerationID: draft.sourceGenerationID,
            sourceGenerationDigest: draft.sourceGenerationDigest,
            sourceFence: draft.sourceFence,
            authorityFenceToken: draft.authorityFenceToken,
            databaseArtifact: draft.databaseArtifact,
            sourceWALArtifact: draft.sourceWALArtifact,
            blobSetDigest: draft.blobSetDigest,
            attachmentManifestSetDigest: draft.attachmentManifestSetDigest,
            keyIdentityDigest: draft.keyIdentityDigest,
            vaultArtifacts: draft.vaultArtifacts,
            counts: draft.counts,
            boundaries: draft.boundaries,
            semanticEquivalenceDigest: draft.semanticEquivalenceDigest,
            verificationMethod: draft.verificationMethod,
            verificationDigest: draft.verificationDigest,
            createdAtMilliseconds: draft.createdAtMilliseconds,
            backupDigest: try semanticDigest(draft, removing: "backupDigest")
        )
    }

    static func migrationRun(
        id: String,
        executorInstanceID: String,
        reservationID: String,
        operationLeaseID: String,
        operationLeaseEpoch: Int64,
        operationFencingToken: Int64,
        sourceSafetyBackupID: String?,
        backupID: String?,
        recoveryAuthorizationID: String?,
        recoveryAuthorizationDigest: String?,
        recoveryExecutionPlanID: String? = nil,
        recoveryExecutionClaimID: String? = nil,
        recoveryExecutionClaimEpoch: Int64? = nil,
        operationKind: RuntimeGenerationOperationKind,
        sourceSchemaVersion: Int?,
        candidateGenerationID: RuntimeStoreGenerationID,
        transformationVersion: Int,
        provenanceDigest: String,
        startedAtMilliseconds: Int64,
        completedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationMigrationRun {
        guard operationLeaseEpoch > 0,
              operationFencingToken > 0,
              startedAtMilliseconds >= 0,
              completedAtMilliseconds >= startedAtMilliseconds else {
            throw RuntimeGenerationControlError.malformed(field: "migration_run")
        }
        try RuntimeGenerationControlValidation.requireIdentifier(
            operationLeaseID, field: "migration_operation_lease_id"
        )
        let draft = RuntimeGenerationMigrationRun(
            migrationRunID: id,
            executorInstanceID: executorInstanceID,
            reservationID: reservationID,
            operationLeaseID: operationLeaseID,
            operationLeaseEpoch: operationLeaseEpoch,
            operationFencingToken: operationFencingToken,
            sourceSafetyBackupID: sourceSafetyBackupID,
            backupID: backupID,
            recoveryAuthorizationID: recoveryAuthorizationID,
            recoveryAuthorizationDigest: recoveryAuthorizationDigest,
            recoveryExecutionPlanID: recoveryExecutionPlanID,
            recoveryExecutionClaimID: recoveryExecutionClaimID,
            recoveryExecutionClaimEpoch: recoveryExecutionClaimEpoch,
            operationKind: operationKind,
            sourceSchemaVersion: sourceSchemaVersion,
            targetSchemaVersion: runtimeCanonicalAttachmentSchemaVersion,
            transformationVersion: transformationVersion,
            candidateGenerationID: candidateGenerationID,
            provenanceDigest: provenanceDigest,
            startedAtMilliseconds: startedAtMilliseconds,
            completedAtMilliseconds: completedAtMilliseconds,
            runDigest: ""
        )
        return RuntimeGenerationMigrationRun(
            migrationRunID: draft.migrationRunID,
            executorInstanceID: draft.executorInstanceID,
            reservationID: draft.reservationID,
            operationLeaseID: draft.operationLeaseID,
            operationLeaseEpoch: draft.operationLeaseEpoch,
            operationFencingToken: draft.operationFencingToken,
            sourceSafetyBackupID: draft.sourceSafetyBackupID,
            backupID: draft.backupID,
            recoveryAuthorizationID: draft.recoveryAuthorizationID,
            recoveryAuthorizationDigest: draft.recoveryAuthorizationDigest,
            recoveryExecutionPlanID: draft.recoveryExecutionPlanID,
            recoveryExecutionClaimID: draft.recoveryExecutionClaimID,
            recoveryExecutionClaimEpoch: draft.recoveryExecutionClaimEpoch,
            operationKind: draft.operationKind,
            sourceSchemaVersion: draft.sourceSchemaVersion,
            targetSchemaVersion: draft.targetSchemaVersion,
            transformationVersion: draft.transformationVersion,
            candidateGenerationID: draft.candidateGenerationID,
            provenanceDigest: draft.provenanceDigest,
            startedAtMilliseconds: draft.startedAtMilliseconds,
            completedAtMilliseconds: draft.completedAtMilliseconds,
            runDigest: try semanticDigest(draft, removing: "runDigest")
        )
    }

    static func projectionRebuildLifecycleTransition(
        id: String, run: RuntimeGenerationMigrationRun,
        phase: RuntimeGenerationProjectionRebuildPhase,
        priorTransitionDigest: String?, reasonDigest: String,
        occurredAtMilliseconds: Int64
    ) throws -> RuntimeGenerationProjectionRebuildLifecycleTransition {
        guard let planID = run.recoveryExecutionPlanID,
              let claimID = run.recoveryExecutionClaimID,
              let claimEpoch = run.recoveryExecutionClaimEpoch else {
            throw RuntimeGenerationControlError.activationAuthorityMismatch
        }
        let draft = RuntimeGenerationProjectionRebuildLifecycleTransition(
            transitionID: id, migrationRunID: run.migrationRunID,
            recoveryExecutionPlanID: planID, recoveryExecutionClaimID: claimID,
            recoveryExecutionClaimEpoch: claimEpoch, phase: phase,
            priorTransitionDigest: priorTransitionDigest, reasonDigest: reasonDigest,
            occurredAtMilliseconds: occurredAtMilliseconds, transitionDigest: ""
        )
        return RuntimeGenerationProjectionRebuildLifecycleTransition(
            transitionID: draft.transitionID, migrationRunID: draft.migrationRunID,
            recoveryExecutionPlanID: draft.recoveryExecutionPlanID,
            recoveryExecutionClaimID: draft.recoveryExecutionClaimID,
            recoveryExecutionClaimEpoch: draft.recoveryExecutionClaimEpoch,
            phase: draft.phase, priorTransitionDigest: draft.priorTransitionDigest,
            reasonDigest: draft.reasonDigest,
            occurredAtMilliseconds: draft.occurredAtMilliseconds,
            transitionDigest: try semanticDigest(draft, removing: "transitionDigest")
        )
    }

    static func validate(_ record: RuntimeGenerationProjectionRebuildLifecycleTransition) throws {
        for (value, field) in [(record.transitionID, "projection_rebuild_transition_id"), (record.migrationRunID, "projection_rebuild_run_id"), (record.recoveryExecutionPlanID, "projection_rebuild_plan_id"), (record.recoveryExecutionClaimID, "projection_rebuild_claim_id")] { try RuntimeGenerationControlValidation.requireIdentifier(value, field: field) }
        for (value, field) in [(record.reasonDigest, "projection_rebuild_reason_digest"), (record.transitionDigest, "projection_rebuild_transition_digest")] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        if let prior = record.priorTransitionDigest { try RuntimeGenerationControlValidation.requireDigest(prior, field: "projection_rebuild_prior_transition_digest") }
        guard record.recoveryExecutionClaimEpoch > 0, record.occurredAtMilliseconds >= 0, try semanticDigest(record, removing: "transitionDigest") == record.transitionDigest else { throw corrupt("projection_rebuild_transition", record.transitionID) }
    }

    static func verification(
        id: String,
        verifierInstanceID: String,
        reservation: RuntimeGenerationReservation,
        migrationRunID: String,
        sourceFenceDigest: String?,
        candidateAuthorityManifestDigest: String,
        candidateAuthorityManifestFileSHA256: String,
        candidateSelectorFileSHA256: String,
        evidence: [RuntimeGenerationVerificationEvidence],
        verifiedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationVerificationReport {
        let orderedEvidence = evidence.sorted { $0.check.rawValue < $1.check.rawValue }
        guard Set(orderedEvidence.map(\.check)) == Set(RuntimeGenerationVerificationCheck.allCases),
              Set(orderedEvidence.map(\.check)).count == orderedEvidence.count
        else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        let draft = RuntimeGenerationVerificationReport(
            verificationID: id,
            verifierInstanceID: verifierInstanceID,
            reservationID: reservation.reservationID,
            migrationRunID: migrationRunID,
            candidateGenerationID: reservation.candidateGenerationID,
            candidateAuthorityManifestDigest: candidateAuthorityManifestDigest,
            candidateAuthorityManifestFileSHA256: candidateAuthorityManifestFileSHA256,
            candidateSelectorFileSHA256: candidateSelectorFileSHA256,
            sourceGenerationID: reservation.sourceGenerationID,
            sourceGenerationDigest: reservation.sourceGenerationDigest,
            sourceFenceDigest: sourceFenceDigest,
            expectedActiveManifestDigest: reservation.expectedActiveManifestDigest,
            expectedSchemaVersion: runtimeCanonicalAttachmentSchemaVersion,
            evidence: orderedEvidence,
            verifiedAtMilliseconds: verifiedAtMilliseconds,
            accepted: true,
            reportDigest: ""
        )
        return RuntimeGenerationVerificationReport(
            verificationID: draft.verificationID,
            verifierInstanceID: draft.verifierInstanceID,
            reservationID: draft.reservationID,
            migrationRunID: draft.migrationRunID,
            candidateGenerationID: draft.candidateGenerationID,
            candidateAuthorityManifestDigest: draft.candidateAuthorityManifestDigest,
            candidateAuthorityManifestFileSHA256: draft.candidateAuthorityManifestFileSHA256,
            candidateSelectorFileSHA256: draft.candidateSelectorFileSHA256,
            sourceGenerationID: draft.sourceGenerationID,
            sourceGenerationDigest: draft.sourceGenerationDigest,
            sourceFenceDigest: draft.sourceFenceDigest,
            expectedActiveManifestDigest: draft.expectedActiveManifestDigest,
            expectedSchemaVersion: draft.expectedSchemaVersion,
            evidence: draft.evidence,
            verifiedAtMilliseconds: draft.verifiedAtMilliseconds,
            accepted: draft.accepted,
            reportDigest: try semanticDigest(draft, removing: "reportDigest")
        )
    }

    static func activationIntent(
        id: String,
        reservation: RuntimeGenerationReservation,
        verification: RuntimeGenerationVerificationReport,
        createdAtMilliseconds: Int64,
        expiresAtMilliseconds: Int64
    ) throws -> RuntimeGenerationActivationIntent {
        guard verification.hasCompleteEvidence,
              verification.reservationID == reservation.reservationID,
              verification.candidateGenerationID == reservation.candidateGenerationID
        else { throw RuntimeGenerationControlError.verificationRejected }
        let draft = RuntimeGenerationActivationIntent(
            intentID: id,
            reservationID: reservation.reservationID,
            verificationID: verification.verificationID,
            candidateGenerationID: reservation.candidateGenerationID,
            candidateAuthorityManifestDigest: verification.candidateAuthorityManifestDigest,
            candidateAuthorityManifestFileSHA256: verification.candidateAuthorityManifestFileSHA256,
            candidateSelectorFileSHA256: verification.candidateSelectorFileSHA256,
            expectedSourceGenerationID: reservation.sourceGenerationID,
            expectedSourceGenerationDigest: reservation.sourceGenerationDigest,
            expectedSourceFenceDigest: verification.sourceFenceDigest,
            expectedActiveManifestDigest: reservation.expectedActiveManifestDigest,
            createdAtMilliseconds: createdAtMilliseconds,
            expiresAtMilliseconds: expiresAtMilliseconds,
            intentDigest: ""
        )
        return RuntimeGenerationActivationIntent(
            intentID: draft.intentID,
            reservationID: draft.reservationID,
            verificationID: draft.verificationID,
            candidateGenerationID: draft.candidateGenerationID,
            candidateAuthorityManifestDigest: draft.candidateAuthorityManifestDigest,
            candidateAuthorityManifestFileSHA256: draft.candidateAuthorityManifestFileSHA256,
            candidateSelectorFileSHA256: draft.candidateSelectorFileSHA256,
            expectedSourceGenerationID: draft.expectedSourceGenerationID,
            expectedSourceGenerationDigest: draft.expectedSourceGenerationDigest,
            expectedSourceFenceDigest: draft.expectedSourceFenceDigest,
            expectedActiveManifestDigest: draft.expectedActiveManifestDigest,
            createdAtMilliseconds: draft.createdAtMilliseconds,
            expiresAtMilliseconds: draft.expiresAtMilliseconds,
            intentDigest: try semanticDigest(draft, removing: "intentDigest")
        )
    }

    static func activationConsumption(
        intent: RuntimeGenerationActivationIntent,
        consumedAtMilliseconds: Int64,
        installedSelectorFileSHA256: String,
        priorGenerationID: RuntimeStoreGenerationID?,
        priorGenerationDigest: String?
    ) throws -> RuntimeGenerationActivationConsumption {
        let draft = RuntimeGenerationActivationConsumption(
            intentID: intent.intentID,
            consumedAtMilliseconds: consumedAtMilliseconds,
            installedSelectorFileSHA256: installedSelectorFileSHA256,
            priorGenerationID: priorGenerationID,
            priorGenerationDigest: priorGenerationDigest,
            consumptionDigest: ""
        )
        return RuntimeGenerationActivationConsumption(
            intentID: draft.intentID,
            consumedAtMilliseconds: draft.consumedAtMilliseconds,
            installedSelectorFileSHA256: draft.installedSelectorFileSHA256,
            priorGenerationID: draft.priorGenerationID,
            priorGenerationDigest: draft.priorGenerationDigest,
            consumptionDigest: try semanticDigest(draft, removing: "consumptionDigest")
        )
    }

    static func activeAuthority(
        activationEpoch: Int64,
        generationID: RuntimeStoreGenerationID,
        authorityManifestDigest: String,
        selectorFileSHA256: String,
        activationIntentID: String,
        activationConsumptionDigest: String,
        priorGenerationID: RuntimeStoreGenerationID?,
        priorGenerationDigest: String?,
        activatedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationActiveAuthority {
        guard activationEpoch > 0,
              activatedAtMilliseconds >= 0,
              (priorGenerationID == nil) == (priorGenerationDigest == nil) else {
            throw RuntimeGenerationControlError.malformed(field: "active_authority")
        }
        try RuntimeGenerationControlValidation.requireDigest(
            authorityManifestDigest, field: "active_manifest_digest"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            selectorFileSHA256, field: "active_selector_digest"
        )
        try RuntimeGenerationControlValidation.requireIdentifier(
            activationIntentID, field: "active_intent_id"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            activationConsumptionDigest, field: "active_consumption_digest"
        )
        if let priorGenerationDigest {
            try RuntimeGenerationControlValidation.requireDigest(
                priorGenerationDigest, field: "active_prior_generation_digest"
            )
        }
        let draft = RuntimeGenerationActiveAuthority(
            singletonID: 1,
            activationEpoch: activationEpoch,
            generationID: generationID,
            authorityManifestDigest: authorityManifestDigest,
            selectorFileSHA256: selectorFileSHA256,
            activationIntentID: activationIntentID,
            activationConsumptionDigest: activationConsumptionDigest,
            priorGenerationID: priorGenerationID,
            priorGenerationDigest: priorGenerationDigest,
            activatedAtMilliseconds: activatedAtMilliseconds,
            authorityDigest: ""
        )
        return RuntimeGenerationActiveAuthority(
            singletonID: draft.singletonID,
            activationEpoch: draft.activationEpoch,
            generationID: draft.generationID,
            authorityManifestDigest: draft.authorityManifestDigest,
            selectorFileSHA256: draft.selectorFileSHA256,
            activationIntentID: draft.activationIntentID,
            activationConsumptionDigest: draft.activationConsumptionDigest,
            priorGenerationID: draft.priorGenerationID,
            priorGenerationDigest: draft.priorGenerationDigest,
            activatedAtMilliseconds: draft.activatedAtMilliseconds,
            authorityDigest: try semanticDigest(draft, removing: "authorityDigest")
        )
    }

    static func restoreBaselinePlan(
        id: String,
        sourceGenerationID: RuntimeStoreGenerationID,
        sourceGenerationDigest: String,
        sourceSafetyBackupID: String,
        sourceSafetyFenceDigest: String,
        targetGenerationID: RuntimeStoreGenerationID,
        targetVerificationID: String,
        targetActivationBaselineDigest: String,
        recoveryAuthorizationID: String,
        recoveryAuthorizationDigest: String,
        preparedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationRestoreBaselinePlan {
        let draft = RuntimeGenerationRestoreBaselinePlan(
            planID: id,
            sourceGenerationID: sourceGenerationID,
            sourceGenerationDigest: sourceGenerationDigest,
            sourceSafetyBackupID: sourceSafetyBackupID,
            sourceSafetyFenceDigest: sourceSafetyFenceDigest,
            targetGenerationID: targetGenerationID,
            targetVerificationID: targetVerificationID,
            targetActivationBaselineDigest: targetActivationBaselineDigest,
            recoveryAuthorizationID: recoveryAuthorizationID,
            recoveryAuthorizationDigest: recoveryAuthorizationDigest,
            preparedAtMilliseconds: preparedAtMilliseconds,
            planDigest: ""
        )
        return RuntimeGenerationRestoreBaselinePlan(
            planID: draft.planID,
            sourceGenerationID: draft.sourceGenerationID,
            sourceGenerationDigest: draft.sourceGenerationDigest,
            sourceSafetyBackupID: draft.sourceSafetyBackupID,
            sourceSafetyFenceDigest: draft.sourceSafetyFenceDigest,
            targetGenerationID: draft.targetGenerationID,
            targetVerificationID: draft.targetVerificationID,
            targetActivationBaselineDigest: draft.targetActivationBaselineDigest,
            recoveryAuthorizationID: draft.recoveryAuthorizationID,
            recoveryAuthorizationDigest: draft.recoveryAuthorizationDigest,
            preparedAtMilliseconds: draft.preparedAtMilliseconds,
            planDigest: try semanticDigest(draft, removing: "planDigest")
        )
    }

    static func rollback(
        id: String,
        restoreBaselinePlanID: String,
        sourceGenerationID: RuntimeStoreGenerationID,
        sourceSafetyFenceDigest: String,
        targetGenerationID: RuntimeStoreGenerationID,
        targetVerificationID: String,
        targetObservedFence: RuntimeGenerationRevisionFence,
        postActivationEventCount: Int64,
        postActivationCommandCount: Int64,
        postActivationReceiptCount: Int64,
        postActivationExternalEffectCount: Int64,
        postActivationAttachmentLifecycleCount: Int64,
        activatedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationRollbackRecord {
        let draft = RuntimeGenerationRollbackRecord(
            rollbackID: id,
            restoreBaselinePlanID: restoreBaselinePlanID,
            sourceGenerationID: sourceGenerationID,
            sourceSafetyFenceDigest: sourceSafetyFenceDigest,
            targetGenerationID: targetGenerationID,
            targetVerificationID: targetVerificationID,
            targetObservedFence: targetObservedFence,
            postActivationEventCount: postActivationEventCount,
            postActivationCommandCount: postActivationCommandCount,
            postActivationReceiptCount: postActivationReceiptCount,
            postActivationExternalEffectCount: postActivationExternalEffectCount,
            postActivationAttachmentLifecycleCount: postActivationAttachmentLifecycleCount,
            activatedAtMilliseconds: activatedAtMilliseconds,
            rollbackDigest: ""
        )
        return RuntimeGenerationRollbackRecord(
            rollbackID: draft.rollbackID,
            restoreBaselinePlanID: draft.restoreBaselinePlanID,
            sourceGenerationID: draft.sourceGenerationID,
            sourceSafetyFenceDigest: draft.sourceSafetyFenceDigest,
            targetGenerationID: draft.targetGenerationID,
            targetVerificationID: draft.targetVerificationID,
            targetObservedFence: draft.targetObservedFence,
            postActivationEventCount: draft.postActivationEventCount,
            postActivationCommandCount: draft.postActivationCommandCount,
            postActivationReceiptCount: draft.postActivationReceiptCount,
            postActivationExternalEffectCount: draft.postActivationExternalEffectCount,
            postActivationAttachmentLifecycleCount:
                draft.postActivationAttachmentLifecycleCount,
            activatedAtMilliseconds: draft.activatedAtMilliseconds,
            rollbackDigest: try semanticDigest(draft, removing: "rollbackDigest")
        )
    }

    static func recoveryAuthorization(
        id: String,
        action: RuntimeGenerationRecoveryAction,
        targetDigest: String,
        alternativesReviewedDigest: String,
        consequenceDigest: String,
        authorizedAtMilliseconds: Int64,
        expiresAtMilliseconds: Int64
    ) throws -> RuntimeGenerationRecoveryAuthorization {
        let draft = RuntimeGenerationRecoveryAuthorization(
            authorizationID: id,
            action: action,
            targetDigest: targetDigest,
            alternativesReviewedDigest: alternativesReviewedDigest,
            consequenceDigest: consequenceDigest,
            authorizedAtMilliseconds: authorizedAtMilliseconds,
            expiresAtMilliseconds: expiresAtMilliseconds,
            authorizationDigest: ""
        )
        return RuntimeGenerationRecoveryAuthorization(
            authorizationID: draft.authorizationID,
            action: draft.action,
            targetDigest: draft.targetDigest,
            alternativesReviewedDigest: draft.alternativesReviewedDigest,
            consequenceDigest: draft.consequenceDigest,
            authorizedAtMilliseconds: draft.authorizedAtMilliseconds,
            expiresAtMilliseconds: draft.expiresAtMilliseconds,
            authorizationDigest: try semanticDigest(draft, removing: "authorizationDigest")
        )
    }

    static func recoveryAuthorizationConsumption(
        authorization: RuntimeGenerationRecoveryAuthorization,
        resultDigest: String,
        consumedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationRecoveryAuthorizationConsumption {
        let draft = RuntimeGenerationRecoveryAuthorizationConsumption(
            authorizationID: authorization.authorizationID,
            action: authorization.action,
            targetDigest: authorization.targetDigest,
            resultDigest: resultDigest,
            consumedAtMilliseconds: consumedAtMilliseconds,
            consumptionDigest: ""
        )
        return RuntimeGenerationRecoveryAuthorizationConsumption(
            authorizationID: draft.authorizationID,
            action: draft.action,
            targetDigest: draft.targetDigest,
            resultDigest: draft.resultDigest,
            consumedAtMilliseconds: draft.consumedAtMilliseconds,
            consumptionDigest: try semanticDigest(draft, removing: "consumptionDigest")
        )
    }

    static func recoveryOperationPlan(
        id: String,
        quarantine: RuntimeGenerationQuarantineRecord,
        authorization: RuntimeGenerationRecoveryAuthorization,
        preparedAtMilliseconds: Int64,
        expiresAtMilliseconds: Int64
    ) throws -> RuntimeGenerationRecoveryOperationPlan {
        let draft = RuntimeGenerationRecoveryOperationPlan(
            planID: id, quarantineID: quarantine.quarantineID, action: authorization.action,
            targetDigest: authorization.targetDigest,
            recoveryAuthorizationID: authorization.authorizationID,
            recoveryAuthorizationDigest: authorization.authorizationDigest,
            preparedAtMilliseconds: preparedAtMilliseconds,
            expiresAtMilliseconds: expiresAtMilliseconds,
            planDigest: ""
        )
        return RuntimeGenerationRecoveryOperationPlan(
            planID: draft.planID, quarantineID: draft.quarantineID, action: draft.action,
            targetDigest: draft.targetDigest,
            recoveryAuthorizationID: draft.recoveryAuthorizationID,
            recoveryAuthorizationDigest: draft.recoveryAuthorizationDigest,
            preparedAtMilliseconds: draft.preparedAtMilliseconds,
            expiresAtMilliseconds: draft.expiresAtMilliseconds,
            planDigest: try semanticDigest(draft, removing: "planDigest")
        )
    }

    static func recoveryOperationConsumption(
        plan: RuntimeGenerationRecoveryOperationPlan,
        resultDigest: String,
        consumedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationRecoveryOperationConsumption {
        let draft = RuntimeGenerationRecoveryOperationConsumption(
            planID: plan.planID, recoveryAuthorizationID: plan.recoveryAuthorizationID,
            action: plan.action, targetDigest: plan.targetDigest, resultDigest: resultDigest,
            consumedAtMilliseconds: consumedAtMilliseconds, consumptionDigest: ""
        )
        return RuntimeGenerationRecoveryOperationConsumption(
            planID: draft.planID, recoveryAuthorizationID: draft.recoveryAuthorizationID,
            action: draft.action, targetDigest: draft.targetDigest, resultDigest: draft.resultDigest,
            consumedAtMilliseconds: draft.consumedAtMilliseconds,
            consumptionDigest: try semanticDigest(draft, removing: "consumptionDigest")
        )
    }

    static func validate(_ record: RuntimeGenerationRecoveryOperationPlan) throws {
        for (value, field) in [
            (record.planID, "recovery_operation_plan_id"),
            (record.quarantineID, "recovery_operation_quarantine_id"),
            (record.recoveryAuthorizationID, "recovery_operation_authorization_id"),
        ] { try RuntimeGenerationControlValidation.requireIdentifier(value, field: field) }
        for (value, field) in [
            (record.targetDigest, "recovery_operation_target_digest"),
            (record.recoveryAuthorizationDigest, "recovery_operation_authorization_digest"),
            (record.planDigest, "recovery_operation_plan_digest"),
        ] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        guard [RuntimeGenerationRecoveryAction.rebuildDerivedState,
               .retryFreshConnectionVerification, .explicitlyAuthorizedReset].contains(record.action),
              record.preparedAtMilliseconds >= 0,
              record.expiresAtMilliseconds > record.preparedAtMilliseconds,
              try semanticDigest(record, removing: "planDigest") == record.planDigest else {
            throw corrupt("recovery_operation_plan", record.planID)
        }
    }

    static func validate(_ record: RuntimeGenerationRecoveryOperationConsumption) throws {
        for (value, field) in [
            (record.planID, "recovery_operation_consumption_plan_id"),
            (record.recoveryAuthorizationID, "recovery_operation_consumption_authorization_id"),
        ] { try RuntimeGenerationControlValidation.requireIdentifier(value, field: field) }
        for (value, field) in [
            (record.targetDigest, "recovery_operation_consumption_target_digest"),
            (record.resultDigest, "recovery_operation_result_digest"),
            (record.consumptionDigest, "recovery_operation_consumption_digest"),
        ] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        guard [RuntimeGenerationRecoveryAction.rebuildDerivedState,
               .retryFreshConnectionVerification, .explicitlyAuthorizedReset].contains(record.action),
              record.consumedAtMilliseconds >= 0,
              try semanticDigest(record, removing: "consumptionDigest") == record.consumptionDigest else {
            throw corrupt("recovery_operation_consumption", record.planID)
        }
    }

    static func recoveryOperationExecutionClaim(
        id: String,
        planID: String,
        executorInstanceID: String,
        claimEpoch: Int64,
        claimedAtMilliseconds: Int64,
        expiresAtMilliseconds: Int64
    ) throws -> RuntimeGenerationRecoveryOperationExecutionClaim {
        let draft = RuntimeGenerationRecoveryOperationExecutionClaim(
            claimID: id, planID: planID, executorInstanceID: executorInstanceID,
            claimEpoch: claimEpoch, claimedAtMilliseconds: claimedAtMilliseconds,
            expiresAtMilliseconds: expiresAtMilliseconds, claimDigest: ""
        )
        return RuntimeGenerationRecoveryOperationExecutionClaim(
            claimID: draft.claimID, planID: draft.planID,
            executorInstanceID: draft.executorInstanceID, claimEpoch: draft.claimEpoch,
            claimedAtMilliseconds: draft.claimedAtMilliseconds,
            expiresAtMilliseconds: draft.expiresAtMilliseconds,
            claimDigest: try semanticDigest(draft, removing: "claimDigest")
        )
    }

    static func recoveryOperationExecutionReceipt(
        id: String,
        plan: RuntimeGenerationRecoveryOperationPlan,
        claim: RuntimeGenerationRecoveryOperationExecutionClaim,
        candidateGenerationID: RuntimeStoreGenerationID?,
        verification: RuntimeGenerationVerificationReport?,
        authorityClassification: RuntimeGenerationRecoveryExecutionAuthorityClassification,
        rebuild: RuntimeGenerationRebuildRecord?,
        outcomeEvidenceDigest: String,
        executedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationRecoveryOperationExecutionReceipt {
        let draft = RuntimeGenerationRecoveryOperationExecutionReceipt(
            receiptID: id, planID: plan.planID, claimID: claim.claimID,
            claimEpoch: claim.claimEpoch, quarantineID: plan.quarantineID,
            candidateGenerationID: candidateGenerationID,
            recoveryAuthorizationID: plan.recoveryAuthorizationID,
            recoveryAuthorizationDigest: plan.recoveryAuthorizationDigest,
            action: plan.action, targetDigest: plan.targetDigest,
            verificationID: verification?.verificationID,
            verificationReportDigest: verification?.reportDigest,
            verificationAccepted: verification?.accepted,
            authorityClassification: authorityClassification,
            rebuildID: rebuild?.rebuildID, rebuildDigest: rebuild?.rebuildDigest,
            outcomeEvidenceDigest: outcomeEvidenceDigest,
            executedAtMilliseconds: executedAtMilliseconds, receiptDigest: ""
        )
        return RuntimeGenerationRecoveryOperationExecutionReceipt(
            receiptID: draft.receiptID, planID: draft.planID, claimID: draft.claimID,
            claimEpoch: draft.claimEpoch, quarantineID: draft.quarantineID,
            candidateGenerationID: draft.candidateGenerationID,
            recoveryAuthorizationID: draft.recoveryAuthorizationID,
            recoveryAuthorizationDigest: draft.recoveryAuthorizationDigest,
            action: draft.action, targetDigest: draft.targetDigest,
            verificationID: draft.verificationID,
            verificationReportDigest: draft.verificationReportDigest,
            verificationAccepted: draft.verificationAccepted,
            authorityClassification: draft.authorityClassification,
            rebuildID: draft.rebuildID, rebuildDigest: draft.rebuildDigest,
            outcomeEvidenceDigest: draft.outcomeEvidenceDigest,
            executedAtMilliseconds: draft.executedAtMilliseconds,
            receiptDigest: try semanticDigest(draft, removing: "receiptDigest")
        )
    }

    static func validate(_ record: RuntimeGenerationRecoveryOperationExecutionClaim) throws {
        for (value, field) in [
            (record.claimID, "recovery_execution_claim_id"),
            (record.planID, "recovery_execution_claim_plan_id"),
            (record.executorInstanceID, "recovery_execution_claim_executor_id"),
        ] { try RuntimeGenerationControlValidation.requireIdentifier(value, field: field) }
        try RuntimeGenerationControlValidation.requireDigest(
            record.claimDigest, field: "recovery_execution_claim_digest"
        )
        guard record.claimEpoch > 0,
              record.claimedAtMilliseconds >= 0,
              record.expiresAtMilliseconds > record.claimedAtMilliseconds,
              try semanticDigest(record, removing: "claimDigest") == record.claimDigest else {
            throw corrupt("recovery_execution_claim", record.claimID)
        }
    }

    static func validate(_ record: RuntimeGenerationRecoveryOperationExecutionReceipt) throws {
        for (value, field) in [
            (record.receiptID, "recovery_execution_receipt_id"),
            (record.planID, "recovery_execution_receipt_plan_id"),
            (record.claimID, "recovery_execution_receipt_claim_id"),
            (record.quarantineID, "recovery_execution_receipt_quarantine_id"),
            (record.recoveryAuthorizationID, "recovery_execution_receipt_authorization_id"),
        ] { try RuntimeGenerationControlValidation.requireIdentifier(value, field: field) }
        for (value, field) in [
            (record.recoveryAuthorizationDigest, "recovery_execution_receipt_authorization_digest"),
            (record.targetDigest, "recovery_execution_receipt_target_digest"),
            (record.outcomeEvidenceDigest, "recovery_execution_receipt_outcome_evidence_digest"),
            (record.receiptDigest, "recovery_execution_receipt_digest"),
        ] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        if let verificationID = record.verificationID {
            try RuntimeGenerationControlValidation.requireIdentifier(verificationID, field: "recovery_execution_receipt_verification_id")
        }
        if let verificationReportDigest = record.verificationReportDigest {
            try RuntimeGenerationControlValidation.requireDigest(verificationReportDigest, field: "recovery_execution_receipt_verification_report_digest")
        }
        if let rebuildID = record.rebuildID {
            try RuntimeGenerationControlValidation.requireIdentifier(rebuildID, field: "recovery_execution_receipt_rebuild_id")
        }
        if let rebuildDigest = record.rebuildDigest {
            try RuntimeGenerationControlValidation.requireDigest(rebuildDigest, field: "recovery_execution_receipt_rebuild_digest")
        }
        let isRetry = record.action == .retryFreshConnectionVerification
        let isRebuild = record.action == .rebuildDerivedState
        let isReset = record.action == .explicitlyAuthorizedReset
        guard record.claimEpoch > 0, record.executedAtMilliseconds >= 0,
              (record.verificationID == nil) == (record.verificationReportDigest == nil),
              (record.verificationID == nil) == (record.verificationAccepted == nil),
              (record.rebuildID == nil) == (record.rebuildDigest == nil),
              (isRetry && record.candidateGenerationID != nil && record.verificationID != nil &&
                record.rebuildID == nil && record.authorityClassification == .acceptedFreshConnectionVerification) ||
              (isRebuild && record.candidateGenerationID != nil && record.verificationID == nil &&
                record.rebuildID != nil && record.authorityClassification == .derivedStateEquivalence) ||
              (isReset && record.candidateGenerationID == nil && record.verificationID == nil &&
                record.rebuildID == nil && record.authorityClassification == .explicitlyAuthorizedReset),
              try semanticDigest(record, removing: "receiptDigest") == record.receiptDigest else {
            throw corrupt("recovery_execution_receipt", record.receiptID)
        }
    }

    static func recoveryOperationPlanDisposition(
        plan: RuntimeGenerationRecoveryOperationPlan,
        kind: RuntimeGenerationRecoveryOperationPlanDispositionKind,
        authorization: RuntimeGenerationRecoveryAuthorization?,
        disposedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationRecoveryOperationPlanDisposition {
        let draft = RuntimeGenerationRecoveryOperationPlanDisposition(
            planID: plan.planID, kind: kind,
            recoveryAuthorizationID: authorization?.authorizationID,
            recoveryAuthorizationDigest: authorization?.authorizationDigest,
            disposedAtMilliseconds: disposedAtMilliseconds, dispositionDigest: ""
        )
        return RuntimeGenerationRecoveryOperationPlanDisposition(
            planID: draft.planID, kind: draft.kind,
            recoveryAuthorizationID: draft.recoveryAuthorizationID,
            recoveryAuthorizationDigest: draft.recoveryAuthorizationDigest,
            disposedAtMilliseconds: draft.disposedAtMilliseconds,
            dispositionDigest: try semanticDigest(draft, removing: "dispositionDigest")
        )
    }

    static func recoveryOperationPlanSuccession(
        successor: RuntimeGenerationRecoveryOperationPlan,
        predecessor: RuntimeGenerationRecoveryOperationPlan,
        disposition: RuntimeGenerationRecoveryOperationPlanDisposition,
        recordedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationRecoveryOperationPlanSuccession {
        let draft = RuntimeGenerationRecoveryOperationPlanSuccession(
            successorPlanID: successor.planID, predecessorPlanID: predecessor.planID,
            quarantineID: successor.quarantineID, action: successor.action,
            predecessorDispositionDigest: disposition.dispositionDigest,
            recordedAtMilliseconds: recordedAtMilliseconds, successionDigest: ""
        )
        return RuntimeGenerationRecoveryOperationPlanSuccession(
            successorPlanID: draft.successorPlanID, predecessorPlanID: draft.predecessorPlanID,
            quarantineID: draft.quarantineID, action: draft.action,
            predecessorDispositionDigest: draft.predecessorDispositionDigest,
            recordedAtMilliseconds: draft.recordedAtMilliseconds,
            successionDigest: try semanticDigest(draft, removing: "successionDigest")
        )
    }

    static func recoveryOperationVerificationBinding(
        verification: RuntimeGenerationVerificationReport,
        plan: RuntimeGenerationRecoveryOperationPlan,
        claim: RuntimeGenerationRecoveryOperationExecutionClaim,
        observedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationRecoveryOperationVerificationBinding {
        let draft = RuntimeGenerationRecoveryOperationVerificationBinding(
            verificationID: verification.verificationID,
            verificationReportDigest: verification.reportDigest, planID: plan.planID,
            claimID: claim.claimID, claimEpoch: claim.claimEpoch,
            candidateGenerationID: verification.candidateGenerationID,
            observedAtMilliseconds: observedAtMilliseconds, bindingDigest: ""
        )
        return RuntimeGenerationRecoveryOperationVerificationBinding(
            verificationID: draft.verificationID,
            verificationReportDigest: draft.verificationReportDigest,
            planID: draft.planID, claimID: draft.claimID, claimEpoch: draft.claimEpoch,
            candidateGenerationID: draft.candidateGenerationID,
            observedAtMilliseconds: draft.observedAtMilliseconds,
            bindingDigest: try semanticDigest(draft, removing: "bindingDigest")
        )
    }

    static func validate(_ record: RuntimeGenerationRecoveryOperationPlanDisposition) throws {
        try RuntimeGenerationControlValidation.requireIdentifier(record.planID, field: "recovery_plan_disposition_plan_id")
        if let id = record.recoveryAuthorizationID { try RuntimeGenerationControlValidation.requireIdentifier(id, field: "recovery_plan_disposition_authorization_id") }
        if let digest = record.recoveryAuthorizationDigest { try RuntimeGenerationControlValidation.requireDigest(digest, field: "recovery_plan_disposition_authorization_digest") }
        try RuntimeGenerationControlValidation.requireDigest(record.dispositionDigest, field: "recovery_plan_disposition_digest")
        guard record.disposedAtMilliseconds >= 0,
              (record.recoveryAuthorizationID == nil) == (record.recoveryAuthorizationDigest == nil),
              (record.kind == .expiredWithoutReceipt && record.recoveryAuthorizationID == nil) ||
              (record.kind == .explicitlyCancelled && record.recoveryAuthorizationID != nil),
              try semanticDigest(record, removing: "dispositionDigest") == record.dispositionDigest else { throw corrupt("recovery_plan_disposition", record.planID) }
    }

    static func validate(_ record: RuntimeGenerationRecoveryOperationPlanSuccession) throws {
        for (value, field) in [(record.successorPlanID, "recovery_plan_successor_id"), (record.predecessorPlanID, "recovery_plan_predecessor_id"), (record.quarantineID, "recovery_plan_successor_quarantine_id")] { try RuntimeGenerationControlValidation.requireIdentifier(value, field: field) }
        for (value, field) in [(record.predecessorDispositionDigest, "recovery_plan_predecessor_disposition_digest"), (record.successionDigest, "recovery_plan_succession_digest")] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        guard record.successorPlanID != record.predecessorPlanID, record.recordedAtMilliseconds >= 0, try semanticDigest(record, removing: "successionDigest") == record.successionDigest else { throw corrupt("recovery_plan_succession", record.successorPlanID) }
    }

    static func validate(_ record: RuntimeGenerationRecoveryOperationVerificationBinding) throws {
        for (value, field) in [(record.verificationID, "recovery_verification_binding_id"), (record.planID, "recovery_verification_binding_plan_id"), (record.claimID, "recovery_verification_binding_claim_id")] { try RuntimeGenerationControlValidation.requireIdentifier(value, field: field) }
        for (value, field) in [(record.verificationReportDigest, "recovery_verification_binding_report_digest"), (record.bindingDigest, "recovery_verification_binding_digest")] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        guard record.claimEpoch > 0, record.observedAtMilliseconds >= 0, try semanticDigest(record, removing: "bindingDigest") == record.bindingDigest else { throw corrupt("recovery_verification_binding", record.verificationID) }
    }

    static func recoveryPrecommitWitness(
        activationIntent: RuntimeGenerationActivationIntent,
        migrationRunID: String,
        authorization: RuntimeGenerationRecoveryAuthorization,
        resultDigest: String,
        observedAtMilliseconds: Int64,
        minimumRemainingValidityMilliseconds: Int64
    ) throws -> RuntimeGenerationRecoveryPrecommitWitness {
        let draft = RuntimeGenerationRecoveryPrecommitWitness(
            witnessID: activationIntent.intentID,
            activationIntentID: activationIntent.intentID,
            migrationRunID: migrationRunID,
            candidateGenerationID: activationIntent.candidateGenerationID,
            candidateSelectorFileSHA256: activationIntent.candidateSelectorFileSHA256,
            recoveryAuthorizationID: authorization.authorizationID,
            recoveryAuthorizationDigest: authorization.authorizationDigest,
            recoveryTargetDigest: authorization.targetDigest,
            resultDigest: resultDigest,
            observedAtMilliseconds: observedAtMilliseconds,
            minimumRemainingValidityMilliseconds: minimumRemainingValidityMilliseconds,
            witnessDigest: ""
        )
        return RuntimeGenerationRecoveryPrecommitWitness(
            witnessID: draft.witnessID,
            activationIntentID: draft.activationIntentID,
            migrationRunID: draft.migrationRunID,
            candidateGenerationID: draft.candidateGenerationID,
            candidateSelectorFileSHA256: draft.candidateSelectorFileSHA256,
            recoveryAuthorizationID: draft.recoveryAuthorizationID,
            recoveryAuthorizationDigest: draft.recoveryAuthorizationDigest,
            recoveryTargetDigest: draft.recoveryTargetDigest,
            resultDigest: draft.resultDigest,
            observedAtMilliseconds: draft.observedAtMilliseconds,
            minimumRemainingValidityMilliseconds: draft.minimumRemainingValidityMilliseconds,
            witnessDigest: try semanticDigest(draft, removing: "witnessDigest")
        )
    }

    static func quarantine(
        id: String,
        reason: RuntimeGenerationQuarantineReason,
        originalArtifact: RuntimeGenerationObservedArtifact,
        originalGenerationID: RuntimeStoreGenerationID?,
        originalManifestDigest: String?,
        diagnosticFingerprint: String,
        allowedActions: [RuntimeGenerationRecoveryAction],
        quarantinedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationQuarantineRecord {
        let orderedActions = allowedActions.sorted { $0.rawValue < $1.rawValue }
        let draft = RuntimeGenerationQuarantineRecord(
            quarantineID: id,
            reason: reason,
            originalArtifact: originalArtifact,
            originalGenerationID: originalGenerationID,
            originalManifestDigest: originalManifestDigest,
            diagnosticFingerprint: diagnosticFingerprint,
            allowedActions: orderedActions,
            quarantinedAtMilliseconds: quarantinedAtMilliseconds,
            quarantineDigest: ""
        )
        return RuntimeGenerationQuarantineRecord(
            quarantineID: draft.quarantineID,
            reason: draft.reason,
            originalArtifact: draft.originalArtifact,
            originalGenerationID: draft.originalGenerationID,
            originalManifestDigest: draft.originalManifestDigest,
            diagnosticFingerprint: draft.diagnosticFingerprint,
            allowedActions: draft.allowedActions,
            quarantinedAtMilliseconds: draft.quarantinedAtMilliseconds,
            quarantineDigest: try semanticDigest(draft, removing: "quarantineDigest")
        )
    }

    static func rebuild(
        id: String,
        migrationRunID: String,
        recoveryExecutionPlanID: String,
        recoveryExecutionClaimID: String,
        recoveryExecutionClaimEpoch: Int64,
        candidateGenerationID: RuntimeStoreGenerationID,
        readyTransitionDigest: String,
        sourceGenerationID: RuntimeStoreGenerationID,
        sourceFenceDigest: String,
        replayReconstructionDigest: String,
        projectionGenerationDigest: String,
        searchGenerationDigest: String,
        equivalenceDigest: String,
        publishedAtMilliseconds: Int64
    ) throws -> RuntimeGenerationRebuildRecord {
        let draft = RuntimeGenerationRebuildRecord(
            rebuildID: id,
            migrationRunID: migrationRunID,
            recoveryExecutionPlanID: recoveryExecutionPlanID,
            recoveryExecutionClaimID: recoveryExecutionClaimID,
            recoveryExecutionClaimEpoch: recoveryExecutionClaimEpoch,
            candidateGenerationID: candidateGenerationID,
            readyTransitionDigest: readyTransitionDigest,
            sourceGenerationID: sourceGenerationID,
            sourceFenceDigest: sourceFenceDigest,
            replayReconstructionDigest: replayReconstructionDigest,
            projectionGenerationDigest: projectionGenerationDigest,
            searchGenerationDigest: searchGenerationDigest,
            equivalenceDigest: equivalenceDigest,
            publishedAtMilliseconds: publishedAtMilliseconds,
            rebuildDigest: ""
        )
        return RuntimeGenerationRebuildRecord(
            rebuildID: draft.rebuildID,
            migrationRunID: draft.migrationRunID,
            recoveryExecutionPlanID: draft.recoveryExecutionPlanID,
            recoveryExecutionClaimID: draft.recoveryExecutionClaimID,
            recoveryExecutionClaimEpoch: draft.recoveryExecutionClaimEpoch,
            candidateGenerationID: draft.candidateGenerationID,
            readyTransitionDigest: draft.readyTransitionDigest,
            sourceGenerationID: draft.sourceGenerationID,
            sourceFenceDigest: draft.sourceFenceDigest,
            replayReconstructionDigest: draft.replayReconstructionDigest,
            projectionGenerationDigest: draft.projectionGenerationDigest,
            searchGenerationDigest: draft.searchGenerationDigest,
            equivalenceDigest: draft.equivalenceDigest,
            publishedAtMilliseconds: draft.publishedAtMilliseconds,
            rebuildDigest: try semanticDigest(draft, removing: "rebuildDigest")
        )
    }

    static func importSource(
        id: String,
        sourceKind: RuntimeLegacyImportSourceKind,
        sourceIdentityDigest: String,
        sourceSchema: String,
        sourceArtifact: RuntimeGenerationObservedArtifact,
        sourceLocationFingerprint: String,
        discoveredAtMilliseconds: Int64
    ) throws -> RuntimeLegacyImportSource {
        let draft = RuntimeLegacyImportSource(
            importID: id,
            sourceKind: sourceKind,
            sourceIdentityDigest: sourceIdentityDigest,
            sourceSchema: sourceSchema,
            sourceArtifact: sourceArtifact,
            sourceLocationFingerprint: sourceLocationFingerprint,
            discoveredAtMilliseconds: discoveredAtMilliseconds,
            sourceDigest: ""
        )
        return RuntimeLegacyImportSource(
            importID: draft.importID,
            sourceKind: draft.sourceKind,
            sourceIdentityDigest: draft.sourceIdentityDigest,
            sourceSchema: draft.sourceSchema,
            sourceArtifact: draft.sourceArtifact,
            sourceLocationFingerprint: draft.sourceLocationFingerprint,
            discoveredAtMilliseconds: draft.discoveredAtMilliseconds,
            sourceDigest: try semanticDigest(draft, removing: "sourceDigest")
        )
    }

    static func importItem(
        importID: String,
        sourceRecordID: String,
        sourceRecordDigest: String,
        canonicalFamily: String?,
        canonicalID: String?,
        canonicalPayloadDigest: String?,
        mappedArtifact: RuntimeLegacyMappedArtifactReference? = nil,
        disposition: RuntimeLegacyImportDisposition,
        warningCodes: [String],
        lossiness: RuntimeLegacyImportLossiness
    ) throws -> RuntimeLegacyImportItem {
        if let mappedArtifact {
            try validate(mappedArtifact)
            guard mappedArtifact.importID == importID,
                  mappedArtifact.sourceRecordID == sourceRecordID,
                  mappedArtifact.sourceRecordDigest == sourceRecordDigest,
                  mappedArtifact.artifact.sha256 == canonicalPayloadDigest else {
                throw corrupt("import_item_artifact_binding", sourceRecordID)
            }
        }
        guard (canonicalPayloadDigest == nil) == (mappedArtifact == nil) else {
            throw corrupt("import_item_artifact_presence", sourceRecordID)
        }
        let warnings = Array(Set(warningCodes)).sorted()
        let draft = RuntimeLegacyImportItem(
            importID: importID,
            sourceRecordID: sourceRecordID,
            sourceRecordDigest: sourceRecordDigest,
            canonicalFamily: canonicalFamily,
            canonicalID: canonicalID,
            canonicalPayloadDigest: canonicalPayloadDigest,
            mappedArtifact: mappedArtifact,
            disposition: disposition,
            warningCodes: warnings,
            lossiness: lossiness,
            itemDigest: ""
        )
        return RuntimeLegacyImportItem(
            importID: draft.importID,
            sourceRecordID: draft.sourceRecordID,
            sourceRecordDigest: draft.sourceRecordDigest,
            canonicalFamily: draft.canonicalFamily,
            canonicalID: draft.canonicalID,
            canonicalPayloadDigest: draft.canonicalPayloadDigest,
            mappedArtifact: draft.mappedArtifact,
            disposition: draft.disposition,
            warningCodes: draft.warningCodes,
            lossiness: draft.lossiness,
            itemDigest: try semanticDigest(draft, removing: "itemDigest")
        )
    }

    static func importCheckpoint(
        id: String, importID: String, sequence: Int,
        phase: RuntimeLegacyImportPhase, priorCheckpointDigest: String?,
        sourceArtifactSHA256: String, artifactSetDigest: String,
        lastSourceRecordID: String?, processedItemCount: Int,
        occurredAtMilliseconds: Int64,
        evidence: RuntimeLegacyImportCheckpointEvidence
    ) throws -> RuntimeLegacyImportCheckpoint {
        let draft = RuntimeLegacyImportCheckpoint(
            checkpointID: id, importID: importID, sequence: sequence, phase: phase,
            priorCheckpointDigest: priorCheckpointDigest,
            sourceArtifactSHA256: sourceArtifactSHA256,
            artifactSetDigest: artifactSetDigest,
            lastSourceRecordID: lastSourceRecordID,
            processedItemCount: processedItemCount,
            occurredAtMilliseconds: occurredAtMilliseconds,
            evidence: evidence, checkpointDigest: ""
        )
        return RuntimeLegacyImportCheckpoint(
            checkpointID: draft.checkpointID, importID: draft.importID,
            sequence: draft.sequence, phase: draft.phase,
            priorCheckpointDigest: draft.priorCheckpointDigest,
            sourceArtifactSHA256: draft.sourceArtifactSHA256,
            artifactSetDigest: draft.artifactSetDigest,
            lastSourceRecordID: draft.lastSourceRecordID,
            processedItemCount: draft.processedItemCount,
            occurredAtMilliseconds: draft.occurredAtMilliseconds,
            evidence: draft.evidence,
            checkpointDigest: try semanticDigest(draft, removing: "checkpointDigest")
        )
    }

    static func mappedArtifactReference(
        importID: String, sourceRecordID: String, sourceRecordDigest: String,
        artifact: RuntimeGenerationArtifact, formatVersion: Int, payloadVersion: Int
    ) throws -> RuntimeLegacyMappedArtifactReference {
        let semanticArtifact = try artifact.semanticArtifact()
        let draft = RuntimeLegacyMappedArtifactReference(
            formatVersion: formatVersion, importID: importID,
            sourceRecordID: sourceRecordID, sourceRecordDigest: sourceRecordDigest,
            artifact: semanticArtifact, payloadVersion: payloadVersion, bindingDigest: ""
        )
        return RuntimeLegacyMappedArtifactReference(
            formatVersion: draft.formatVersion, importID: draft.importID,
            sourceRecordID: draft.sourceRecordID,
            sourceRecordDigest: draft.sourceRecordDigest, artifact: draft.artifact,
            payloadVersion: draft.payloadVersion,
            bindingDigest: try semanticDigest(draft, removing: "bindingDigest")
        )
    }

    static func importOrphanQuarantine(
        id: String, originalEntryName: String,
        originalEntryIdentity: RuntimeStoreFileIdentity,
        preservedRelativePath: String, inventoryDigest: String,
        fileCount: Int, totalByteCount: Int64,
        quarantinedAtMilliseconds: Int64
    ) throws -> RuntimeLegacyImportOrphanQuarantine {
        let draft = RuntimeLegacyImportOrphanQuarantine(
            quarantineID: id, originalEntryName: originalEntryName,
            originalEntryIdentity: originalEntryIdentity,
            preservedRelativePath: preservedRelativePath,
            inventoryDigest: inventoryDigest, fileCount: fileCount,
            totalByteCount: totalByteCount,
            quarantinedAtMilliseconds: quarantinedAtMilliseconds,
            quarantineDigest: ""
        )
        return RuntimeLegacyImportOrphanQuarantine(
            quarantineID: draft.quarantineID,
            originalEntryName: draft.originalEntryName,
            originalEntryIdentity: draft.originalEntryIdentity,
            preservedRelativePath: draft.preservedRelativePath,
            inventoryDigest: draft.inventoryDigest, fileCount: draft.fileCount,
            totalByteCount: draft.totalByteCount,
            quarantinedAtMilliseconds: draft.quarantinedAtMilliseconds,
            quarantineDigest: try semanticDigest(draft, removing: "quarantineDigest")
        )
    }

    static func importOrphanQuarantinePlan(
        id: String,
        originalEntryName: String,
        originalEntryIdentity: RuntimeStoreFileIdentity,
        destinationEntryName: String,
        maximumInventoryFileCount: Int,
        maximumInventoryByteCount: Int64,
        plannedAtMilliseconds: Int64
    ) throws -> RuntimeLegacyImportOrphanQuarantinePlan {
        let draft = RuntimeLegacyImportOrphanQuarantinePlan(
            quarantineID: id,
            originalEntryName: originalEntryName,
            originalEntryIdentity: originalEntryIdentity,
            destinationEntryName: destinationEntryName,
            maximumInventoryFileCount: maximumInventoryFileCount,
            maximumInventoryByteCount: maximumInventoryByteCount,
            plannedAtMilliseconds: plannedAtMilliseconds,
            planDigest: ""
        )
        return RuntimeLegacyImportOrphanQuarantinePlan(
            quarantineID: draft.quarantineID,
            originalEntryName: draft.originalEntryName,
            originalEntryIdentity: draft.originalEntryIdentity,
            destinationEntryName: draft.destinationEntryName,
            maximumInventoryFileCount: draft.maximumInventoryFileCount,
            maximumInventoryByteCount: draft.maximumInventoryByteCount,
            plannedAtMilliseconds: draft.plannedAtMilliseconds,
            planDigest: try semanticDigest(draft, removing: "planDigest")
        )
    }

    static func importDispositionIntent(
        id: String, importID: String, sourceDigest: String, manifestDigest: String,
        orderedItemSetDigest: String, orderedDecisionSetDigest: String,
        itemCount: Int, retainedForFutureMigrationItemCount: Int,
        retainedLossyForFutureMigrationItemCount: Int,
        rejectedItemCount: Int, lossinessConsequenceDigest: String,
        discoveryTransformationVersion: Int,
        reviewContractDigest: String,
        disposition: RuntimeLegacyImportCandidateDisposition,
        plannedAtMilliseconds: Int64
    ) throws -> RuntimeLegacyImportDispositionIntent {
        let draft = RuntimeLegacyImportDispositionIntent(
            intentID: id, importID: importID, sourceDigest: sourceDigest,
            manifestDigest: manifestDigest, orderedItemSetDigest: orderedItemSetDigest,
            orderedDecisionSetDigest: orderedDecisionSetDigest, itemCount: itemCount,
            retainedForFutureMigrationItemCount: retainedForFutureMigrationItemCount,
            retainedLossyForFutureMigrationItemCount: retainedLossyForFutureMigrationItemCount,
            rejectedItemCount: rejectedItemCount,
            lossinessConsequenceDigest: lossinessConsequenceDigest,
            discoveryTransformationVersion: discoveryTransformationVersion,
            reviewContractDigest: reviewContractDigest,
            disposition: disposition, plannedAtMilliseconds: plannedAtMilliseconds,
            intentDigest: ""
        )
        return RuntimeLegacyImportDispositionIntent(
            intentID: draft.intentID, importID: draft.importID,
            sourceDigest: draft.sourceDigest, manifestDigest: draft.manifestDigest,
            orderedItemSetDigest: draft.orderedItemSetDigest,
            orderedDecisionSetDigest: draft.orderedDecisionSetDigest,
            itemCount: draft.itemCount,
            retainedForFutureMigrationItemCount: draft.retainedForFutureMigrationItemCount,
            retainedLossyForFutureMigrationItemCount:
                draft.retainedLossyForFutureMigrationItemCount,
            rejectedItemCount: draft.rejectedItemCount,
            lossinessConsequenceDigest: draft.lossinessConsequenceDigest,
            discoveryTransformationVersion: draft.discoveryTransformationVersion,
            reviewContractDigest: draft.reviewContractDigest,
            disposition: draft.disposition, plannedAtMilliseconds: draft.plannedAtMilliseconds,
            intentDigest: try semanticDigest(draft, removing: "intentDigest")
        )
    }

    static func importManifest(
        importID: String,
        itemCount: Int,
        orderedItemSetDigest: String,
        completedAtMilliseconds: Int64
    ) throws -> RuntimeLegacyImportManifest {
        let draft = RuntimeLegacyImportManifest(
            importID: importID,
            itemCount: itemCount,
            orderedItemSetDigest: orderedItemSetDigest,
            completedAtMilliseconds: completedAtMilliseconds,
            manifestDigest: ""
        )
        return RuntimeLegacyImportManifest(
            importID: draft.importID,
            itemCount: draft.itemCount,
            orderedItemSetDigest: draft.orderedItemSetDigest,
            completedAtMilliseconds: draft.completedAtMilliseconds,
            manifestDigest: try semanticDigest(draft, removing: "manifestDigest")
        )
    }

    static func importReviewPage(
        id: String,
        reviewID: String,
        importID: String,
        pageIndex: Int,
        afterSourceRecordID: String?,
        lastSourceRecordID: String,
        entries: [RuntimeLegacyImportReviewDecisionEntry]
    ) throws -> RuntimeLegacyImportReviewPage {
        let draft = RuntimeLegacyImportReviewPage(
            pageID: id,
            reviewID: reviewID,
            importID: importID,
            pageIndex: pageIndex,
            afterSourceRecordID: afterSourceRecordID,
            lastSourceRecordID: lastSourceRecordID,
            entries: entries,
            pageDigest: ""
        )
        return RuntimeLegacyImportReviewPage(
            pageID: draft.pageID,
            reviewID: draft.reviewID,
            importID: draft.importID,
            pageIndex: draft.pageIndex,
            afterSourceRecordID: draft.afterSourceRecordID,
            lastSourceRecordID: draft.lastSourceRecordID,
            entries: draft.entries,
            pageDigest: try semanticDigest(draft, removing: "pageDigest")
        )
    }

    static func importReview(
        id: String,
        importID: String,
        sourceDigest: String,
        itemCount: Int,
        retainedForFutureMigrationItemCount: Int,
        retainedLossyForFutureMigrationItemCount: Int,
        rejectedItemCount: Int,
        pageCount: Int,
        orderedItemSetDigest: String,
        orderedDecisionSetDigest: String,
        reviewerConfirmationDigest: String,
        reviewedAtMilliseconds: Int64
    ) throws -> RuntimeLegacyImportReview {
        let draft = RuntimeLegacyImportReview(
            reviewID: id,
            importID: importID,
            sourceDigest: sourceDigest,
            itemCount: itemCount,
            retainedForFutureMigrationItemCount: retainedForFutureMigrationItemCount,
            retainedLossyForFutureMigrationItemCount:
                retainedLossyForFutureMigrationItemCount,
            rejectedItemCount: rejectedItemCount,
            pageCount: pageCount,
            orderedItemSetDigest: orderedItemSetDigest,
            orderedDecisionSetDigest: orderedDecisionSetDigest,
            reviewerConfirmationDigest: reviewerConfirmationDigest,
            reviewedAtMilliseconds: reviewedAtMilliseconds,
            reviewDigest: ""
        )
        return RuntimeLegacyImportReview(
            reviewID: draft.reviewID,
            importID: draft.importID,
            sourceDigest: draft.sourceDigest,
            itemCount: draft.itemCount,
            retainedForFutureMigrationItemCount: draft.retainedForFutureMigrationItemCount,
            retainedLossyForFutureMigrationItemCount:
                draft.retainedLossyForFutureMigrationItemCount,
            rejectedItemCount: draft.rejectedItemCount,
            pageCount: draft.pageCount,
            orderedItemSetDigest: draft.orderedItemSetDigest,
            orderedDecisionSetDigest: draft.orderedDecisionSetDigest,
            reviewerConfirmationDigest: draft.reviewerConfirmationDigest,
            reviewedAtMilliseconds: draft.reviewedAtMilliseconds,
            reviewDigest: try semanticDigest(draft, removing: "reviewDigest")
        )
    }

    static func importReviewAuthorization(
        id: String,
        importID: String,
        sourceDigest: String,
        manifestDigest: String,
        itemCount: Int,
        retainedForFutureMigrationItemCount: Int,
        retainedLossyForFutureMigrationItemCount: Int,
        rejectedItemCount: Int,
        orderedItemSetDigest: String,
        orderedDecisionSetDigest: String,
        lossinessConsequenceDigest: String,
        dispositionIntentDigest: String,
        nonce: String,
        authorizedAtMilliseconds: Int64,
        expiresAtMilliseconds: Int64
    ) throws -> RuntimeLegacyImportReviewAuthorization {
        let draft = RuntimeLegacyImportReviewAuthorization(
            authorizationID: id, importID: importID,
            sourceDigest: sourceDigest, manifestDigest: manifestDigest,
            itemCount: itemCount,
            retainedForFutureMigrationItemCount: retainedForFutureMigrationItemCount,
            retainedLossyForFutureMigrationItemCount:
                retainedLossyForFutureMigrationItemCount,
            rejectedItemCount: rejectedItemCount,
            orderedItemSetDigest: orderedItemSetDigest,
            orderedDecisionSetDigest: orderedDecisionSetDigest,
            lossinessConsequenceDigest: lossinessConsequenceDigest,
            dispositionIntentDigest: dispositionIntentDigest, nonce: nonce,
            authorizedAtMilliseconds: authorizedAtMilliseconds,
            expiresAtMilliseconds: expiresAtMilliseconds,
            authorizationDigest: ""
        )
        return RuntimeLegacyImportReviewAuthorization(
            authorizationID: draft.authorizationID, importID: draft.importID,
            sourceDigest: draft.sourceDigest, manifestDigest: draft.manifestDigest,
            itemCount: draft.itemCount,
            retainedForFutureMigrationItemCount: draft.retainedForFutureMigrationItemCount,
            retainedLossyForFutureMigrationItemCount:
                draft.retainedLossyForFutureMigrationItemCount,
            rejectedItemCount: draft.rejectedItemCount,
            orderedItemSetDigest: draft.orderedItemSetDigest,
            orderedDecisionSetDigest: draft.orderedDecisionSetDigest,
            lossinessConsequenceDigest: draft.lossinessConsequenceDigest,
            dispositionIntentDigest: draft.dispositionIntentDigest, nonce: draft.nonce,
            authorizedAtMilliseconds: draft.authorizedAtMilliseconds,
            expiresAtMilliseconds: draft.expiresAtMilliseconds,
            authorizationDigest: try semanticDigest(draft, removing: "authorizationDigest")
        )
    }

    static func validate(_ record: RuntimeLegacyImportReviewAuthorization) throws {
        for (value, field) in [(record.authorizationID, "authorization_id"),
                               (record.importID, "import_id"),
                               (record.nonce, "authorization_nonce")] {
            try RuntimeGenerationControlValidation.requireIdentifier(value, field: field)
        }
        for (value, field) in [
            (record.sourceDigest, "source_digest"),
            (record.manifestDigest, "manifest_digest"),
            (record.orderedItemSetDigest, "ordered_item_set_digest"),
            (record.orderedDecisionSetDigest, "ordered_decision_set_digest"),
            (record.lossinessConsequenceDigest, "lossiness_consequence_digest"),
            (record.authorizationDigest, "authorization_digest"),
        ] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        try RuntimeGenerationControlValidation.requireDigest(
            record.dispositionIntentDigest, field: "disposition_intent_digest"
        )
        let (retained, retainedOverflow) = record.retainedForFutureMigrationItemCount
            .addingReportingOverflow(
                record.retainedLossyForFutureMigrationItemCount
            )
        let (total, totalOverflow) = retained.addingReportingOverflow(record.rejectedItemCount)
        guard record.itemCount >= 0, record.retainedForFutureMigrationItemCount >= 0,
              record.retainedLossyForFutureMigrationItemCount >= 0,
              record.rejectedItemCount >= 0,
              retainedOverflow == false, totalOverflow == false,
              total == record.itemCount,
              record.authorizedAtMilliseconds >= 0,
              record.expiresAtMilliseconds > record.authorizedAtMilliseconds,
              try semanticDigest(record, removing: "authorizationDigest") ==
                record.authorizationDigest else {
            throw RuntimeGenerationControlError.importLossNotAccepted
        }
    }

    static func retentionTransition(
        id: String,
        generationID: RuntimeStoreGenerationID,
        fromClass: RuntimeGenerationRetentionClass?,
        toClass: RuntimeGenerationRetentionClass,
        reasonCode: String,
        authorityDigest: String,
        occurredAtMilliseconds: Int64
    ) throws -> RuntimeGenerationRetentionTransition {
        guard RuntimeGenerationRetentionClass.allowsTransition(
            from: fromClass,
            to: toClass
        ), occurredAtMilliseconds >= 0 else {
            throw RuntimeGenerationControlError.malformed(
                field: "retention_transition"
            )
        }
        try RuntimeGenerationControlValidation.requireIdentifier(
            reasonCode, field: "retention_reason_code"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            authorityDigest, field: "retention_authority_digest"
        )
        let draft = RuntimeGenerationRetentionTransition(
            transitionID: id,
            generationID: generationID,
            fromClass: fromClass,
            toClass: toClass,
            reasonCode: reasonCode,
            authorityDigest: authorityDigest,
            occurredAtMilliseconds: occurredAtMilliseconds,
            transitionDigest: ""
        )
        return RuntimeGenerationRetentionTransition(
            transitionID: draft.transitionID,
            generationID: draft.generationID,
            fromClass: draft.fromClass,
            toClass: draft.toClass,
            reasonCode: draft.reasonCode,
            authorityDigest: draft.authorityDigest,
            occurredAtMilliseconds: draft.occurredAtMilliseconds,
            transitionDigest: try semanticDigest(draft, removing: "transitionDigest")
        )
    }

    static func validate(_ record: RuntimeGenerationReservation) throws {
        let rebuilt = try reservation(
            id: record.reservationID,
            operationKind: record.operationKind,
            candidateGenerationID: record.candidateGenerationID,
            sourceGenerationID: record.sourceGenerationID,
            sourceGenerationDigest: record.sourceGenerationDigest,
            expectedActiveManifestDigest: record.expectedActiveManifestDigest,
            createdAtMilliseconds: record.createdAtMilliseconds
        )
        guard rebuilt == record else { throw corrupt("reservation", record.reservationID) }
    }

    static func validate(_ record: RuntimeGenerationOperationLease) throws {
        let rebuilt = try operationLease(
            id: record.leaseID,
            reservationID: record.reservationID,
            ownerInstanceID: record.ownerInstanceID,
            leaseEpoch: record.leaseEpoch,
            fencingToken: record.fencingToken,
            priorLeaseDigest: record.priorLeaseDigest,
            issuedAtMilliseconds: record.issuedAtMilliseconds,
            expiresAtMilliseconds: record.expiresAtMilliseconds
        )
        guard rebuilt == record else { throw corrupt("operation_lease", record.leaseID) }
    }

    static func validate(_ record: RuntimeGenerationBackupPreparationRecord) throws {
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.preparationID, field: "backup_preparation_id"
        )
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.backupID, field: "backup_preparation_backup_id"
        )
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.reservationID, field: "backup_preparation_reservation_id"
        )
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.operationLeaseID, field: "backup_preparation_lease_id"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            record.sourceGenerationDigest, field: "backup_preparation_source_digest"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            record.expectedActiveManifestDigest, field: "backup_preparation_active_digest"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            record.preparationDigest, field: "backup_preparation_digest"
        )
        guard record.operationFencingToken > 0,
              record.createdAtMilliseconds >= 0,
              record.finalDirectoryName == record.backupID,
              record.hiddenDirectoryName.hasPrefix(".preparing-backup-") else {
            throw corrupt("backup_preparation", record.preparationID)
        }
        try RuntimeStorePathValidation.requireSafeComponent(record.finalDirectoryName)
        guard try semanticDigest(record, removing: "preparationDigest") ==
                record.preparationDigest else {
            throw corrupt("backup_preparation", record.preparationID)
        }
    }

    static func validate(_ record: RuntimeGenerationBackupPreparationCompletion) throws {
        try validate(record.backup)
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.preparationID, field: "backup_completion_preparation_id"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            record.completionDigest, field: "backup_completion_digest"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            record.interiorInventoryDigest, field: "backup_completion_inventory_digest"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            record.durabilityWitnessDigest, field: "backup_completion_durability_digest"
        )
        guard record.directoryDevice > 0,
              record.directoryInode > 0,
              record.interiorArtifactCount > 0,
              record.interiorByteCount >= 0,
              record.completedAtMilliseconds >= record.backup.createdAtMilliseconds,
              try semanticDigest(record, removing: "completionDigest") ==
                record.completionDigest else {
            throw corrupt("backup_preparation_completion", record.preparationID)
        }
    }

    static func validate(_ record: RuntimeGenerationBackupPreparationConsumption) throws {
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.preparationID, field: "backup_consumption_preparation_id"
        )
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.backupID, field: "backup_consumption_backup_id"
        )
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.operationLeaseID, field: "backup_consumption_lease_id"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            record.consumptionDigest, field: "backup_consumption_digest"
        )
        guard record.operationFencingToken > 0,
              record.finalDirectoryDevice > 0,
              record.finalDirectoryInode > 0,
              record.consumedAtMilliseconds >= 0,
              try semanticDigest(record, removing: "consumptionDigest") ==
                record.consumptionDigest else {
            throw corrupt("backup_preparation_consumption", record.preparationID)
        }
    }

    static func validate(_ record: RuntimeGenerationCandidatePreparationRecord) throws {
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.preparationID, field: "candidate_preparation_id"
        )
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.reservationID, field: "candidate_preparation_reservation_id"
        )
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.operationLeaseID, field: "candidate_preparation_lease_id"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            record.preparationDigest, field: "candidate_preparation_digest"
        )
        if let recoveryExecutionPlanID = record.recoveryExecutionPlanID {
            try RuntimeGenerationControlValidation.requireIdentifier(
                recoveryExecutionPlanID, field: "candidate_preparation_recovery_plan_id"
            )
        }
        if let recoveryExecutionClaimID = record.recoveryExecutionClaimID {
            try RuntimeGenerationControlValidation.requireIdentifier(
                recoveryExecutionClaimID, field: "candidate_preparation_recovery_claim_id"
            )
        }
        guard record.operationFencingToken > 0,
              record.createdAtMilliseconds >= 0,
              record.stagingDirectoryName.hasPrefix(".staging-"),
              record.stagingDirectoryName.contains("/") == false,
              (record.sourceGenerationID == nil) ==
                (record.sourceGenerationDigest == nil),
              (record.recoveryExecutionPlanID == nil) ==
                (record.recoveryExecutionClaimID == nil),
              (record.recoveryExecutionPlanID == nil) ==
                (record.recoveryExecutionClaimEpoch == nil),
              record.recoveryExecutionClaimEpoch.map({ $0 > 0 }) ?? true,
              record.recoveryExecutionPlanID == nil ||
                record.operationKind == .projectionRebuild,
              try semanticDigest(record, removing: "preparationDigest") ==
                record.preparationDigest else {
            throw corrupt("candidate_preparation", record.preparationID)
        }
    }

    static func validate(_ record: RuntimeGenerationBackupPreparationRecovery) throws {
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.operationLeaseID, field: "backup_recovery_lease_id"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            record.recoveryDigest, field: "backup_recovery_digest"
        )
        guard record.operationFencingToken > 0,
              record.recoveredAtMilliseconds >= 0,
              record.preservedEntries.allSatisfy({ entry in
                  entry.role == .backupHidden || entry.role == .backupFinal
              }),
              try validatePreservedPreparationEntries(record.preservedEntries),
              try semanticDigest(record, removing: "recoveryDigest") ==
                record.recoveryDigest else {
            throw corrupt("backup_preparation_recovery", record.preparationID)
        }
    }

    static func validate(_ record: RuntimeGenerationCandidatePreparationCompletion) throws {
        for (value, field) in [
            (record.candidateRecordDigest, "candidate_completion_record_digest"),
            (record.interiorInventoryDigest, "candidate_completion_inventory_digest"),
            (record.durabilityWitnessDigest, "candidate_completion_durability_digest"),
            (record.completionDigest, "candidate_completion_digest"),
        ] {
            try RuntimeGenerationControlValidation.requireDigest(value, field: field)
        }
        guard record.directoryDevice > 0,
              record.directoryInode > 0,
              record.interiorArtifactCount == 2,
              record.interiorByteCount >= 0,
              record.completedAtMilliseconds >= 0,
              try semanticDigest(record, removing: "completionDigest") ==
                record.completionDigest else {
            throw corrupt("candidate_preparation_completion", record.preparationID)
        }
    }

    static func validate(_ record: RuntimeGenerationCandidatePreparationDisposition) throws {
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.operationLeaseID, field: "candidate_disposition_lease_id"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            record.authorityDigest, field: "candidate_disposition_authority_digest"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            record.dispositionDigest, field: "candidate_disposition_digest"
        )
        guard record.operationFencingToken > 0,
              record.disposedAtMilliseconds >= 0,
              record.preservedEntries.allSatisfy({ entry in
                  entry.role == .candidateStaging || entry.role == .candidateFinal
              }),
              try validatePreservedPreparationEntries(record.preservedEntries),
              (record.kind == .activated
                ? (record.failureClassification == nil &&
                   record.forensicCode == nil &&
                   record.preservedEntries.isEmpty)
                : (record.failureClassification != nil &&
                   (record.forensicCode == nil ||
                    record.failureClassification == .corrupt))),
              try semanticDigest(record, removing: "dispositionDigest") ==
                record.dispositionDigest else {
            throw corrupt("candidate_preparation_disposition", record.preparationID)
        }
    }

    static func validate(
        _ record: RuntimeGenerationCandidateReplayAuditRecord,
        allowEmptyDigest: Bool = false
    ) throws {
        for (value, field) in [
            (record.auditID, "candidate_replay_audit_id"),
            (record.preparationID, "candidate_replay_audit_preparation_id"),
            (record.reservationID, "candidate_replay_audit_reservation_id"),
            (record.operationLeaseID, "candidate_replay_audit_lease_id"),
        ] {
            try RuntimeGenerationControlValidation.requireIdentifier(value, field: field)
        }
        for (value, field) in [
            (record.replayCheckpointDigest, "candidate_replay_audit_checkpoint_digest"),
            (record.replayCertificateDigest, "candidate_replay_audit_certificate_digest"),
            (record.reconstructionDigest, "candidate_replay_audit_reconstruction_digest"),
        ] where value != nil {
            try RuntimeGenerationControlValidation.requireDigest(value!, field: field)
        }
        if allowEmptyDigest == false {
            try RuntimeGenerationControlValidation.requireDigest(
                record.auditDigest, field: "candidate_replay_audit_digest"
            )
        }
        let outcomeIsCoherent: Bool
        switch record.outcome {
        case .complete:
            outcomeIsCoherent = record.blockedInvariant == nil &&
                record.deferredReason == nil && record.reconstructionDigest != nil
        case .blocked:
            outcomeIsCoherent = record.blockedInvariant != nil &&
                record.deferredReason == nil && record.reconstructionDigest != nil
        case .deferred:
            outcomeIsCoherent = record.blockedInvariant == nil &&
                record.deferredReason != nil && record.reconstructionDigest == nil &&
                record.replayCheckpointDigest == nil && record.replayCertificateDigest == nil
        }
        let deferredReasonIsBounded: Bool
        switch record.deferredReason {
        case let .boundaryCertificateBudget(maximum):
            deferredReasonIsBounded = maximum > 0
        case let .queryBudget(maximumBytes, maximumRows, maximumVMCallbacks):
            deferredReasonIsBounded = maximumBytes > 0 && maximumRows > 0 &&
                maximumVMCallbacks > 0
        case .cancelled, nil:
            deferredReasonIsBounded = true
        }
        let digestMatches = allowEmptyDigest ||
            (try semanticDigest(record, removing: "auditDigest") == record.auditDigest)
        guard record.operationLeaseEpoch > 0,
              record.operationFencingToken > 0,
              record.auditedAtMilliseconds >= 0,
              outcomeIsCoherent,
              deferredReasonIsBounded,
              digestMatches else {
            throw corrupt("candidate_replay_audit", record.auditID)
        }
    }

    /// Recovery evidence is deliberately typed and bounded. A source entry is
    /// retained only to describe a RENAME_EXCL collision; a successfully
    /// quarantined entry is represented by its deterministic quarantine name.
    /// This prevents a malformed journal from claiming arbitrary paths or
    /// silently treating a filesystem object as a recoverable directory.
    private static func validatePreservedPreparationEntries(
        _ entries: [RuntimeGenerationPreservedPreparationEntry]
    ) throws -> Bool {
        guard entries.count <= 4,
              Set(entries.map {
                  "\($0.role.rawValue):\($0.location.rawValue):\($0.basename)"
              }).count == entries.count else {
            return false
        }
        for entry in entries {
            try RuntimeStorePathValidation.requireSafeComponent(entry.basename)
            guard entry.identity.device > 0,
                  entry.identity.inode > 0 else {
                return false
            }
            switch entry.location {
            case .source:
                // Source evidence exists only when a deterministic quarantine
                // target was already occupied. It is not an authority to use
                // the original path again.
                break
            case .quarantine:
                guard entry.basename.hasPrefix("backup-recovery-") ||
                        entry.basename.hasPrefix("candidate-recovery-") else {
                    return false
                }
            }
        }
        return true
    }

    static func validate(_ record: RuntimeGenerationCandidateRecord) throws {
        let rebuilt = try candidate(
            authorityManifest: record.authorityManifest,
            authorityManifestFileSHA256: record.authorityManifestFileSHA256,
            selectorFileSHA256: record.selectorFileSHA256
        )
        guard rebuilt == record else {
            throw corrupt("generation_candidate", record.authorityManifest.generationID.rawValue)
        }
    }

    static func validate(_ record: RuntimeGenerationBackupRecord) throws {
        let rebuilt = try backup(
            id: record.backupID,
            sourceGenerationID: record.sourceGenerationID,
            sourceGenerationDigest: record.sourceGenerationDigest,
            sourceFence: record.sourceFence,
            authorityFenceToken: record.authorityFenceToken,
            databaseArtifact: record.databaseArtifact,
            sourceWALArtifact: record.sourceWALArtifact,
            blobSetDigest: record.blobSetDigest,
            attachmentManifestSetDigest: record.attachmentManifestSetDigest,
            keyIdentityDigest: record.keyIdentityDigest,
            vaultArtifacts: record.vaultArtifacts,
            counts: record.counts,
            boundaries: record.boundaries,
            semanticEquivalenceDigest: record.semanticEquivalenceDigest,
            createdAtMilliseconds: record.createdAtMilliseconds
        )
        guard rebuilt == record else { throw corrupt("backup", record.backupID) }
    }

    static func validate(_ record: RuntimeGenerationMigrationRun) throws {
        let rebuilt = try migrationRun(
            id: record.migrationRunID,
            executorInstanceID: record.executorInstanceID,
            reservationID: record.reservationID,
            operationLeaseID: record.operationLeaseID,
            operationLeaseEpoch: record.operationLeaseEpoch,
            operationFencingToken: record.operationFencingToken,
            sourceSafetyBackupID: record.sourceSafetyBackupID,
            backupID: record.backupID,
            recoveryAuthorizationID: record.recoveryAuthorizationID,
            recoveryAuthorizationDigest: record.recoveryAuthorizationDigest,
            recoveryExecutionPlanID: record.recoveryExecutionPlanID,
            recoveryExecutionClaimID: record.recoveryExecutionClaimID,
            recoveryExecutionClaimEpoch: record.recoveryExecutionClaimEpoch,
            operationKind: record.operationKind,
            sourceSchemaVersion: record.sourceSchemaVersion,
            candidateGenerationID: record.candidateGenerationID,
            transformationVersion: record.transformationVersion,
            provenanceDigest: record.provenanceDigest,
            startedAtMilliseconds: record.startedAtMilliseconds,
            completedAtMilliseconds: record.completedAtMilliseconds
        )
        let hasRecoveryExecutionBinding = record.recoveryExecutionPlanID != nil
        if let recoveryExecutionPlanID = record.recoveryExecutionPlanID {
            try RuntimeGenerationControlValidation.requireIdentifier(
                recoveryExecutionPlanID, field: "migration_recovery_plan_id"
            )
        }
        if let recoveryExecutionClaimID = record.recoveryExecutionClaimID {
            try RuntimeGenerationControlValidation.requireIdentifier(
                recoveryExecutionClaimID, field: "migration_recovery_claim_id"
            )
        }
        guard rebuilt == record,
              hasRecoveryExecutionBinding == (record.recoveryExecutionClaimID != nil),
              hasRecoveryExecutionBinding == (record.recoveryExecutionClaimEpoch != nil),
              record.recoveryExecutionClaimEpoch.map({ $0 > 0 }) ?? true,
              hasRecoveryExecutionBinding == false ||
                record.operationKind == .projectionRebuild else {
            throw corrupt("migration_run", record.migrationRunID)
        }
    }

    static func validate(_ record: RuntimeGenerationVerificationReport) throws {
        let evidence = record.evidence.sorted { $0.check.rawValue < $1.check.rawValue }
        guard record.accepted,
              record.hasCompleteEvidence,
              evidence == record.evidence,
              try semanticDigest(record, removing: "reportDigest") == record.reportDigest else {
            throw corrupt("verification", record.verificationID)
        }
    }

    static func validate(_ record: RuntimeGenerationActivationIntent) throws {
        guard try semanticDigest(record, removing: "intentDigest") == record.intentDigest else {
            throw corrupt("activation_intent", record.intentID)
        }
    }

    static func validate(_ record: RuntimeGenerationActivationConsumption) throws {
        guard try semanticDigest(record, removing: "consumptionDigest") == record.consumptionDigest else {
            throw corrupt("activation_consumption", record.intentID)
        }
    }

    static func validate(_ record: RuntimeGenerationRestoreBaselinePlan) throws {
        let rebuilt = try restoreBaselinePlan(
            id: record.planID,
            sourceGenerationID: record.sourceGenerationID,
            sourceGenerationDigest: record.sourceGenerationDigest,
            sourceSafetyBackupID: record.sourceSafetyBackupID,
            sourceSafetyFenceDigest: record.sourceSafetyFenceDigest,
            targetGenerationID: record.targetGenerationID,
            targetVerificationID: record.targetVerificationID,
            targetActivationBaselineDigest: record.targetActivationBaselineDigest,
            recoveryAuthorizationID: record.recoveryAuthorizationID,
            recoveryAuthorizationDigest: record.recoveryAuthorizationDigest,
            preparedAtMilliseconds: record.preparedAtMilliseconds
        )
        guard rebuilt == record else { throw corrupt("restore_baseline", record.planID) }
    }

    static func validate(_ record: RuntimeGenerationRollbackRecord) throws {
        let rebuilt = try rollback(
            id: record.rollbackID,
            restoreBaselinePlanID: record.restoreBaselinePlanID,
            sourceGenerationID: record.sourceGenerationID,
            sourceSafetyFenceDigest: record.sourceSafetyFenceDigest,
            targetGenerationID: record.targetGenerationID,
            targetVerificationID: record.targetVerificationID,
            targetObservedFence: record.targetObservedFence,
            postActivationEventCount: record.postActivationEventCount,
            postActivationCommandCount: record.postActivationCommandCount,
            postActivationReceiptCount: record.postActivationReceiptCount,
            postActivationExternalEffectCount: record.postActivationExternalEffectCount,
            postActivationAttachmentLifecycleCount:
                record.postActivationAttachmentLifecycleCount,
            activatedAtMilliseconds: record.activatedAtMilliseconds
        )
        guard rebuilt == record else { throw corrupt("rollback", record.rollbackID) }
    }

    static func validate(_ record: RuntimeGenerationQuarantineRecord) throws {
        let rebuilt = try quarantine(
            id: record.quarantineID,
            reason: record.reason,
            originalArtifact: record.originalArtifact,
            originalGenerationID: record.originalGenerationID,
            originalManifestDigest: record.originalManifestDigest,
            diagnosticFingerprint: record.diagnosticFingerprint,
            allowedActions: record.allowedActions,
            quarantinedAtMilliseconds: record.quarantinedAtMilliseconds
        )
        guard rebuilt == record else { throw corrupt("quarantine", record.quarantineID) }
    }

    static func validate(_ record: RuntimeGenerationRebuildRecord) throws {
        for (value, field) in [
            (record.rebuildID, "rebuild_id"),
            (record.migrationRunID, "rebuild_migration_run_id"),
            (record.recoveryExecutionPlanID, "rebuild_recovery_plan_id"),
            (record.recoveryExecutionClaimID, "rebuild_recovery_claim_id"),
        ] {
            try RuntimeGenerationControlValidation.requireIdentifier(value, field: field)
        }
        try RuntimeGenerationControlValidation.requireDigest(
            record.readyTransitionDigest,
            field: "rebuild_ready_transition_digest"
        )
        guard record.recoveryExecutionClaimEpoch > 0 else {
            throw corrupt("rebuild", record.rebuildID)
        }
        let rebuilt = try rebuild(
            id: record.rebuildID,
            migrationRunID: record.migrationRunID,
            recoveryExecutionPlanID: record.recoveryExecutionPlanID,
            recoveryExecutionClaimID: record.recoveryExecutionClaimID,
            recoveryExecutionClaimEpoch: record.recoveryExecutionClaimEpoch,
            candidateGenerationID: record.candidateGenerationID,
            readyTransitionDigest: record.readyTransitionDigest,
            sourceGenerationID: record.sourceGenerationID,
            sourceFenceDigest: record.sourceFenceDigest,
            replayReconstructionDigest: record.replayReconstructionDigest,
            projectionGenerationDigest: record.projectionGenerationDigest,
            searchGenerationDigest: record.searchGenerationDigest,
            equivalenceDigest: record.equivalenceDigest,
            publishedAtMilliseconds: record.publishedAtMilliseconds
        )
        guard rebuilt == record else { throw corrupt("rebuild", record.rebuildID) }
    }

    static func validate(_ record: RuntimeLegacyImportSource) throws {
        let rebuilt = try importSource(
            id: record.importID,
            sourceKind: record.sourceKind,
            sourceIdentityDigest: record.sourceIdentityDigest,
            sourceSchema: record.sourceSchema,
            sourceArtifact: record.sourceArtifact,
            sourceLocationFingerprint: record.sourceLocationFingerprint,
            discoveredAtMilliseconds: record.discoveredAtMilliseconds
        )
        guard rebuilt == record else { throw corrupt("import_source", record.importID) }
    }

    static func validate(_ record: RuntimeLegacyImportItem) throws {
        if let mappedArtifact = record.mappedArtifact {
            try validate(mappedArtifact)
            guard mappedArtifact.importID == record.importID,
                  mappedArtifact.sourceRecordID == record.sourceRecordID,
                  mappedArtifact.sourceRecordDigest == record.sourceRecordDigest,
                  mappedArtifact.artifact.sha256 == record.canonicalPayloadDigest else {
                throw corrupt("import_item_artifact_binding", record.sourceRecordID)
            }
        }
        guard (record.canonicalPayloadDigest == nil) == (record.mappedArtifact == nil) else {
            throw corrupt("import_item_artifact_binding", record.sourceRecordID)
        }
        let rebuilt = try importItem(
            importID: record.importID,
            sourceRecordID: record.sourceRecordID,
            sourceRecordDigest: record.sourceRecordDigest,
            canonicalFamily: record.canonicalFamily,
            canonicalID: record.canonicalID,
            canonicalPayloadDigest: record.canonicalPayloadDigest,
            mappedArtifact: record.mappedArtifact,
            disposition: record.disposition,
            warningCodes: record.warningCodes,
            lossiness: record.lossiness
        )
        guard rebuilt == record else { throw corrupt("import_item", record.sourceRecordID) }
    }

    static func validate(_ record: RuntimeLegacyImportCheckpoint) throws {
        for (value, field) in [(record.checkpointID, "checkpoint_id"),
                               (record.importID, "import_id")] {
            try RuntimeGenerationControlValidation.requireIdentifier(value, field: field)
        }
        for (value, field) in [
            (record.sourceArtifactSHA256, "source_artifact_sha256"),
            (record.artifactSetDigest, "artifact_set_digest"),
            (record.checkpointDigest, "checkpoint_digest"),
        ] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        if let prior = record.priorCheckpointDigest {
            try RuntimeGenerationControlValidation.requireDigest(prior, field: "prior_checkpoint")
        }
        try validateCheckpointEvidence(record.evidence, for: record.phase)
        guard record.sequence >= 0, record.processedItemCount >= 0,
              record.occurredAtMilliseconds >= 0,
              try semanticDigest(record, removing: "checkpointDigest") ==
                record.checkpointDigest else {
            throw corrupt("import_checkpoint", record.checkpointID)
        }
    }

    private static func validateCheckpointEvidence(
        _ evidence: RuntimeLegacyImportCheckpointEvidence,
        for phase: RuntimeLegacyImportPhase
    ) throws {
        func digest(_ value: String, _ field: String) throws {
            try RuntimeGenerationControlValidation.requireDigest(value, field: field)
        }
        switch (phase, evidence) {
        case let (.sourcePreserved, .sourcePreserved(value)):
            try digest(value, "checkpoint_source_digest")
        case let (.decoding, .decoding(cursor)):
            if let cursor { try digest(cursor, "checkpoint_cursor_digest") }
        case let (.mapped, .mapped(manifest, artifacts)):
            try digest(manifest, "checkpoint_manifest_digest")
            try digest(artifacts, "checkpoint_artifact_set_digest")
        case let (.reviewPlanned, .reviewPlanned(value)):
            try digest(value, "checkpoint_disposition_intent")
        case let (.reviewAuthorized, .reviewAuthorized(value)):
            try digest(value, "checkpoint_review_authorization")
        case let (.reviewConsumed, .reviewConsumed(review, authorization)):
            try digest(review, "checkpoint_review")
            try digest(authorization, "checkpoint_review_authorization")
        case let (.completedNoActivation, .completedNoActivation(intent, review, authorization)):
            try digest(intent, "checkpoint_disposition_intent")
            try digest(review, "checkpoint_review")
            try digest(authorization, "checkpoint_review_authorization")
        case let (.abandoned, .abandoned(reason, actions)):
            try RuntimeGenerationControlValidation.requireIdentifier(reason, field: "abandonment_reason")
            guard actions.isEmpty == false, Set(actions).count == actions.count,
                  actions == actions.sorted(by: { $0.rawValue < $1.rawValue }) else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
        case let (.quarantined, .quarantined(value, actions)):
            try digest(value, "checkpoint_quarantine")
            guard actions.isEmpty == false, Set(actions).count == actions.count,
                  actions == actions.sorted(by: { $0.rawValue < $1.rawValue }) else {
                throw RuntimeGenerationControlError.importReviewRequired
            }
        default:
            throw RuntimeGenerationControlError.importReviewRequired
        }
    }

    static func validate(_ record: RuntimeLegacyMappedArtifactReference) throws {
        try record.artifact.validate()
        try RuntimeGenerationControlValidation.requireIdentifier(record.importID, field: "import_id")
        try RuntimeGenerationControlValidation.requireIdentifier(record.sourceRecordID, field: "source_record_id")
        try RuntimeGenerationControlValidation.requireDigest(record.sourceRecordDigest, field: "source_record_digest")
        try RuntimeGenerationControlValidation.requireDigest(record.bindingDigest, field: "artifact_binding_digest")
        guard (record.formatVersion == 1 || record.formatVersion == 2),
              record.payloadVersion > 0,
              try semanticDigest(record, removing: "bindingDigest") == record.bindingDigest else {
            throw corrupt("mapped_artifact", record.sourceRecordID)
        }
    }

    static func validate(_ record: RuntimeLegacyImportOrphanQuarantine) throws {
        try RuntimeGenerationControlValidation.requireIdentifier(record.quarantineID, field: "orphan_quarantine_id")
        try RuntimeStorePathValidation.requireSafeComponent(record.originalEntryName)
        try RuntimeGenerationControlValidation.requireRelativePath(record.preservedRelativePath)
        try RuntimeGenerationControlValidation.requireDigest(record.inventoryDigest, field: "orphan_inventory_digest")
        try RuntimeGenerationControlValidation.requireDigest(record.quarantineDigest, field: "orphan_quarantine_digest")
        guard record.fileCount >= 0, record.totalByteCount >= 0,
              record.originalEntryIdentity.inode > 0,
              record.quarantinedAtMilliseconds >= 0,
              try semanticDigest(record, removing: "quarantineDigest") == record.quarantineDigest else {
            throw corrupt("import_orphan_quarantine", record.quarantineID)
        }
    }

    static func validate(_ record: RuntimeLegacyImportOrphanQuarantinePlan) throws {
        try RuntimeGenerationControlValidation.requireIdentifier(
            record.quarantineID,
            field: "orphan_quarantine_plan_id"
        )
        try RuntimeStorePathValidation.requireSafeComponent(record.originalEntryName)
        try RuntimeGenerationControlValidation.requireRelativePath(
            record.destinationEntryName
        )
        try RuntimeGenerationControlValidation.requireDigest(
            record.planDigest,
            field: "orphan_quarantine_plan_digest"
        )
        guard record.destinationEntryName.contains("/") == false,
              record.destinationEntryName == "orphan-import-\(record.quarantineID)",
              record.originalEntryIdentity.inode > 0,
              record.maximumInventoryFileCount > 0,
              record.maximumInventoryByteCount > 0,
              record.plannedAtMilliseconds >= 0,
              try semanticDigest(record, removing: "planDigest") == record.planDigest else {
            throw corrupt("import_orphan_quarantine_plan", record.quarantineID)
        }
    }

    static func validate(_ record: RuntimeLegacyImportDispositionIntent) throws {
        try RuntimeGenerationControlValidation.requireIdentifier(record.intentID, field: "import_disposition_intent_id")
        try RuntimeGenerationControlValidation.requireIdentifier(record.importID, field: "import_id")
        for (value, field) in [
            (record.sourceDigest, "source_digest"),
            (record.manifestDigest, "manifest_digest"),
            (record.orderedItemSetDigest, "ordered_item_set_digest"),
            (record.orderedDecisionSetDigest, "ordered_decision_set_digest"),
            (record.lossinessConsequenceDigest, "lossiness_consequence_digest"),
            (record.reviewContractDigest, "review_contract_digest"),
            (record.intentDigest, "import_disposition_intent_digest"),
        ] { try RuntimeGenerationControlValidation.requireDigest(value, field: field) }
        let (retained, retainedOverflow) = record.retainedForFutureMigrationItemCount
            .addingReportingOverflow(record.retainedLossyForFutureMigrationItemCount)
        let (total, totalOverflow) = retained.addingReportingOverflow(record.rejectedItemCount)
        let dispositionCountsAreValid =
            (record.disposition == .noActivationAllRejected &&
                retained == 0 && record.rejectedItemCount == record.itemCount) ||
            (record.disposition == .noActivationReviewOnly && retained > 0)
        guard record.itemCount >= 0, record.retainedForFutureMigrationItemCount >= 0,
              record.retainedLossyForFutureMigrationItemCount >= 0,
              record.rejectedItemCount >= 0,
              retainedOverflow == false, totalOverflow == false,
              total == record.itemCount,
              record.discoveryTransformationVersion > 0,
              record.plannedAtMilliseconds >= 0,
              dispositionCountsAreValid,
              try semanticDigest(record, removing: "intentDigest") == record.intentDigest else {
            throw corrupt("import_disposition_intent", record.intentID)
        }
    }

    static func validate(_ record: RuntimeLegacyImportManifest) throws {
        let rebuilt = try importManifest(
            importID: record.importID,
            itemCount: record.itemCount,
            orderedItemSetDigest: record.orderedItemSetDigest,
            completedAtMilliseconds: record.completedAtMilliseconds
        )
        guard rebuilt == record else { throw corrupt("import_manifest", record.importID) }
    }

    static func validate(_ record: RuntimeLegacyImportReviewPage) throws {
        let rebuilt = try importReviewPage(
            id: record.pageID,
            reviewID: record.reviewID,
            importID: record.importID,
            pageIndex: record.pageIndex,
            afterSourceRecordID: record.afterSourceRecordID,
            lastSourceRecordID: record.lastSourceRecordID,
            entries: record.entries
        )
        guard rebuilt == record else { throw corrupt("import_review_page", record.pageID) }
    }

    static func validate(_ record: RuntimeLegacyImportReview) throws {
        let rebuilt = try importReview(
            id: record.reviewID,
            importID: record.importID,
            sourceDigest: record.sourceDigest,
            itemCount: record.itemCount,
            retainedForFutureMigrationItemCount: record.retainedForFutureMigrationItemCount,
            retainedLossyForFutureMigrationItemCount:
                record.retainedLossyForFutureMigrationItemCount,
            rejectedItemCount: record.rejectedItemCount,
            pageCount: record.pageCount,
            orderedItemSetDigest: record.orderedItemSetDigest,
            orderedDecisionSetDigest: record.orderedDecisionSetDigest,
            reviewerConfirmationDigest: record.reviewerConfirmationDigest,
            reviewedAtMilliseconds: record.reviewedAtMilliseconds
        )
        guard rebuilt == record else { throw corrupt("import_review", record.reviewID) }
    }

    static func validate(_ record: RuntimeGenerationRecoveryAuthorization) throws {
        let rebuilt = try recoveryAuthorization(
            id: record.authorizationID,
            action: record.action,
            targetDigest: record.targetDigest,
            alternativesReviewedDigest: record.alternativesReviewedDigest,
            consequenceDigest: record.consequenceDigest,
            authorizedAtMilliseconds: record.authorizedAtMilliseconds,
            expiresAtMilliseconds: record.expiresAtMilliseconds
        )
        guard rebuilt == record else { throw corrupt("recovery_authorization", record.authorizationID) }
    }

    static func validate(
        _ record: RuntimeGenerationRecoveryAuthorizationConsumption
    ) throws {
        guard try semanticDigest(record, removing: "consumptionDigest") == record.consumptionDigest else {
            throw RuntimeGenerationControlError.malformed(
                field: "recovery_authorization_consumption_digest"
            )
        }
    }

    static func validate(_ record: RuntimeGenerationRecoveryPrecommitWitness) throws {
        for (value, field) in [
            (record.witnessID, "witness_id"),
            (record.activationIntentID, "activation_intent_id"),
            (record.migrationRunID, "migration_run_id"),
            (record.recoveryAuthorizationID, "recovery_authorization_id"),
        ] {
            try RuntimeGenerationControlValidation.requireIdentifier(value, field: field)
        }
        for (value, field) in [
            (record.candidateSelectorFileSHA256, "candidate_selector_file_sha256"),
            (record.recoveryAuthorizationDigest, "recovery_authorization_digest"),
            (record.recoveryTargetDigest, "recovery_target_digest"),
            (record.resultDigest, "result_digest"),
            (record.witnessDigest, "witness_digest"),
        ] {
            try RuntimeGenerationControlValidation.requireDigest(value, field: field)
        }
        guard record.witnessID == record.activationIntentID,
              record.observedAtMilliseconds >= 0,
              record.minimumRemainingValidityMilliseconds > 0,
              record.observedAtMilliseconds <=
                Int64.max - record.minimumRemainingValidityMilliseconds,
              try semanticDigest(record, removing: "witnessDigest") == record.witnessDigest else {
            throw corrupt("recovery_precommit_witness", record.witnessID)
        }
    }

    static func validate(_ record: RuntimeGenerationRetentionTransition) throws {
        let rebuilt = try retentionTransition(
            id: record.transitionID,
            generationID: record.generationID,
            fromClass: record.fromClass,
            toClass: record.toClass,
            reasonCode: record.reasonCode,
            authorityDigest: record.authorityDigest,
            occurredAtMilliseconds: record.occurredAtMilliseconds
        )
        guard rebuilt == record else { throw corrupt("retention_transition", record.transitionID) }
    }

    static func validate(_ record: RuntimeGenerationActiveAuthority) throws {
        let rebuilt = try activeAuthority(
            activationEpoch: record.activationEpoch,
            generationID: record.generationID,
            authorityManifestDigest: record.authorityManifestDigest,
            selectorFileSHA256: record.selectorFileSHA256,
            activationIntentID: record.activationIntentID,
            activationConsumptionDigest: record.activationConsumptionDigest,
            priorGenerationID: record.priorGenerationID,
            priorGenerationDigest: record.priorGenerationDigest,
            activatedAtMilliseconds: record.activatedAtMilliseconds
        )
        guard record.singletonID == 1,
              record.activationEpoch > 0,
              (record.priorGenerationID == nil) ==
                (record.priorGenerationDigest == nil),
              rebuilt == record else {
            throw corrupt("active_authority", record.generationID.rawValue)
        }
    }

    private static func corrupt(_ kind: String, _ id: String) -> RuntimeGenerationControlError {
        .recordCorrupt(kind: kind, id: id)
    }

    /// Hashes the canonical JSON object after removing exactly the record's
    /// semantic digest field. This binds every remaining scalar and nested
    /// field without maintaining a parallel hand-written field list.
    private static func semanticDigest<Value: Encodable>(
        _ value: Value,
        removing digestKey: String
    ) throws -> String {
        let encoded = try RuntimeGenerationControlCodec.encode(value)
        guard var object = try JSONSerialization.jsonObject(with: encoded) as? [String: Any],
              object.removeValue(forKey: digestKey) != nil else {
            throw RuntimeGenerationControlError.malformed(field: "semantic_digest_material")
        }
        let canonical = try JSONSerialization.data(
            withJSONObject: object,
            options: [.sortedKeys, .withoutEscapingSlashes]
        )
        return LocalRuntimeStorageChecksum.sha256Hex(for: canonical)
    }

    static func digest(_ components: [String]) throws -> String {
        guard components.allSatisfy({
            $0.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false
                || $0 == ""
        }) else {
            throw RuntimeGenerationControlError.malformed(field: "digest_material")
        }
        return LocalRuntimeStorageChecksum.sha256Hex(
            for: components.joined(separator: "\n")
        )
    }
}
