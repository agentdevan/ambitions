import Foundation

extension RuntimeGenerationCandidateRecord {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        try authorityManifest.validate()
        try RuntimeGenerationControlValidation.requireDigest(
            authorityManifestFileSHA256,
            field: "authority_manifest_file_sha256"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            selectorFileSHA256,
            field: "selector_file_sha256"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            recordDigest,
            field: "candidate_record_digest"
        )
        guard LocalRuntimeStorageChecksum.sha256Hex(
            for: try RuntimeGenerationControlCodec.encode(authorityManifest)
        ) == authorityManifestFileSHA256 else {
            throw RuntimeGenerationControlError.recordCorrupt(
                kind: "authority_manifest_file",
                id: authorityManifest.generationID.rawValue
            )
        }
    }
}

extension RuntimeGenerationReservation {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        try RuntimeGenerationControlValidation.requireIdentifier(
            reservationID,
            field: "reservation_id"
        )
        try RuntimeStorePathValidation.requireSafeComponent(
            candidateGenerationID.pathComponent
        )
        try RuntimeGenerationControlValidation.requireDigest(
            reservationDigest,
            field: "reservation_digest"
        )
        guard targetSchemaVersion == runtimeCanonicalAttachmentSchemaVersion,
              createdAtMilliseconds >= 0,
              (sourceGenerationID == nil) == (sourceGenerationDigest == nil)
        else {
            throw RuntimeGenerationControlError.malformed(field: "reservation")
        }
        if let sourceGenerationID {
            try RuntimeStorePathValidation.requireSafeComponent(
                sourceGenerationID.pathComponent
            )
        }
        for (value, field) in [
            (sourceGenerationDigest, "source_generation_digest"),
            (expectedActiveManifestDigest, "expected_active_manifest_digest"),
        ] {
            if let value {
                try RuntimeGenerationControlValidation.requireDigest(value, field: field)
            }
        }
    }
}

extension RuntimeGenerationBackupRecord {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        try RuntimeGenerationControlValidation.requireIdentifier(backupID, field: "backup_id")
        try RuntimeGenerationControlValidation.requireDigest(sourceGenerationDigest, field: "source_generation_digest")
        try RuntimeGenerationControlValidation.requireDigest(blobSetDigest, field: "blob_set_digest")
        try RuntimeGenerationControlValidation.requireDigest(
            attachmentManifestSetDigest,
            field: "attachment_manifest_set_digest"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            keyIdentityDigest,
            field: "backup_key_identity_digest"
        )
        try RuntimeGenerationControlValidation.requireDigest(backupDigest, field: "backup_digest")
        try RuntimeGenerationControlValidation.requireDigest(
            verificationDigest,
            field: "backup_verification_digest"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            semanticEquivalenceDigest,
            field: "backup_semantic_equivalence"
        )
        try counts.validate()
        try boundaries.validate()
        try sourceFence.validate()
        try databaseArtifact.validate()
        try sourceWALArtifact?.validate()
        guard vaultArtifacts == vaultArtifacts.sorted(by: { $0.blobID < $1.blobID }),
              Set(vaultArtifacts.map(\.blobID)).count == vaultArtifacts.count else {
            throw RuntimeGenerationControlError.malformed(field: "backup_vault_artifacts")
        }
        for artifact in vaultArtifacts {
            try RuntimeGenerationControlValidation.requireIdentifier(
                artifact.blobID,
                field: "backup_blob_id"
            )
            try RuntimeGenerationControlValidation.requireDigest(
                artifact.manifestDigest,
                field: "backup_manifest_digest"
            )
            try RuntimeGenerationControlValidation.requireDigest(
                artifact.artifactDigest,
                field: "backup_vault_artifact_digest"
            )
            try artifact.payloadArtifact.validate()
            try artifact.manifestArtifact.validate()
            try artifact.finalizationArtifact?.validate()
            guard let backupPayload = artifact.backupPayloadArtifact,
                  let backupManifest = artifact.backupManifestArtifact,
                  backupPayload.sha256 == artifact.payloadArtifact.sha256,
                  backupPayload.byteCount == artifact.payloadArtifact.byteCount,
                  backupManifest.sha256 == artifact.manifestArtifact.sha256,
                  backupManifest.byteCount == artifact.manifestArtifact.byteCount,
                  (artifact.finalizationArtifact == nil) ==
                    (artifact.backupFinalizationArtifact == nil) else {
                throw RuntimeGenerationControlError.malformed(
                    field: "backup_vault_copy"
                )
            }
            try backupPayload.validate()
            try backupManifest.validate()
            try artifact.backupFinalizationArtifact?.validate()
            if let sourceFinal = artifact.finalizationArtifact,
               let backupFinal = artifact.backupFinalizationArtifact {
                guard sourceFinal.sha256 == backupFinal.sha256,
                      sourceFinal.byteCount == backupFinal.byteCount else {
                    throw RuntimeGenerationControlError.malformed(
                        field: "backup_finalization_copy"
                    )
                }
            }
        }
        guard sourceFence.generationID == sourceGenerationID,
              sourceFence.generationDigest == sourceGenerationDigest,
              verificationMethod ==
                "sqlite-online-backup-consolidated-v1+vault-authenticated-copy-v1",
              createdAtMilliseconds >= 0 else {
            throw RuntimeGenerationControlError.malformed(field: "backup")
        }
    }
}

extension RuntimeGenerationMigrationRun {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        for (value, field) in [
            (migrationRunID, "migration_run_id"),
            (executorInstanceID, "executor_instance_id"),
            (reservationID, "reservation_id"),
        ] {
            try RuntimeGenerationControlValidation.requireIdentifier(value, field: field)
        }
        if let sourceSafetyBackupID {
            try RuntimeGenerationControlValidation.requireIdentifier(
                sourceSafetyBackupID,
                field: "source_safety_backup_id"
            )
        }
        if let backupID {
            try RuntimeGenerationControlValidation.requireIdentifier(backupID, field: "backup_id")
        }
        if let recoveryAuthorizationID {
            try RuntimeGenerationControlValidation.requireIdentifier(
                recoveryAuthorizationID,
                field: "recovery_authorization_id"
            )
        }
        if let recoveryAuthorizationDigest {
            try RuntimeGenerationControlValidation.requireDigest(
                recoveryAuthorizationDigest,
                field: "recovery_authorization_digest"
            )
        }
        try RuntimeStorePathValidation.requireSafeComponent(
            candidateGenerationID.pathComponent
        )
        try RuntimeGenerationControlValidation.requireDigest(provenanceDigest, field: "provenance_digest")
        try RuntimeGenerationControlValidation.requireDigest(runDigest, field: "run_digest")
        guard targetSchemaVersion == runtimeCanonicalAttachmentSchemaVersion,
              sourceSchemaVersion.map({ $0 > 0 && $0 <= targetSchemaVersion }) ?? true,
              transformationVersion > 0,
              startedAtMilliseconds >= 0,
              completedAtMilliseconds >= startedAtMilliseconds,
              (recoveryAuthorizationID == nil) ==
                (recoveryAuthorizationDigest == nil),
              (operationKind == .restore || operationKind == .rollback ||
                recoveryAuthorizationID == nil) else {
            throw RuntimeGenerationControlError.malformed(field: "migration_run")
        }
    }
}

extension RuntimeGenerationProjectionRebuildLifecycleTransition { func validate() throws { try RuntimeGenerationControlRecordFactory.validate(self) } }

extension RuntimeGenerationVerificationReport {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        for (value, field) in [
            (verificationID, "verification_id"),
            (verifierInstanceID, "verifier_instance_id"),
            (reservationID, "reservation_id"),
            (migrationRunID, "migration_run_id"),
        ] {
            try RuntimeGenerationControlValidation.requireIdentifier(value, field: field)
        }
        for (value, field) in [
            (candidateAuthorityManifestDigest, "candidate_authority_manifest_digest"),
            (candidateAuthorityManifestFileSHA256, "candidate_authority_manifest_file_sha256"),
            (candidateSelectorFileSHA256, "candidate_selector_file_sha256"),
            (reportDigest, "report_digest"),
        ] {
            try RuntimeGenerationControlValidation.requireDigest(value, field: field)
        }
        guard expectedSchemaVersion == runtimeCanonicalAttachmentSchemaVersion,
              verifiedAtMilliseconds >= 0,
              accepted,
              hasCompleteEvidence,
              evidence == evidence.sorted(by: { $0.check.rawValue < $1.check.rawValue }),
              (sourceGenerationID == nil) == (sourceGenerationDigest == nil),
              (sourceGenerationID == nil) == (sourceFenceDigest == nil)
        else {
            throw RuntimeGenerationControlError.verificationRejected
        }
        for item in evidence { try item.validate() }
        for (value, field) in [
            (sourceGenerationDigest, "source_generation_digest"),
            (sourceFenceDigest, "source_fence_digest"),
            (expectedActiveManifestDigest, "expected_active_manifest_digest"),
        ] {
            if let value {
                try RuntimeGenerationControlValidation.requireDigest(value, field: field)
            }
        }
    }
}

extension RuntimeGenerationActivationIntent {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        for (value, field) in [
            (intentID, "intent_id"),
            (reservationID, "reservation_id"),
            (verificationID, "verification_id"),
        ] {
            try RuntimeGenerationControlValidation.requireIdentifier(value, field: field)
        }
        for (value, field) in [
            (candidateAuthorityManifestDigest, "candidate_authority_manifest_digest"),
            (candidateAuthorityManifestFileSHA256, "candidate_authority_manifest_file_sha256"),
            (candidateSelectorFileSHA256, "candidate_selector_file_sha256"),
            (intentDigest, "intent_digest"),
        ] {
            try RuntimeGenerationControlValidation.requireDigest(value, field: field)
        }
        guard createdAtMilliseconds >= 0,
              expiresAtMilliseconds > createdAtMilliseconds,
              (expectedSourceGenerationID == nil) == (expectedSourceGenerationDigest == nil),
              (expectedSourceGenerationID == nil) == (expectedSourceFenceDigest == nil)
        else {
            throw RuntimeGenerationControlError.malformed(field: "activation_intent")
        }
        for (value, field) in [
            (expectedSourceGenerationDigest, "expected_source_generation_digest"),
            (expectedSourceFenceDigest, "expected_source_fence_digest"),
            (expectedActiveManifestDigest, "expected_active_manifest_digest"),
        ] {
            if let value {
                try RuntimeGenerationControlValidation.requireDigest(value, field: field)
            }
        }
    }
}

extension RuntimeGenerationActivationConsumption {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        try RuntimeGenerationControlValidation.requireIdentifier(intentID, field: "intent_id")
        try RuntimeGenerationControlValidation.requireDigest(
            installedSelectorFileSHA256,
            field: "installed_selector_file_sha256"
        )
        try RuntimeGenerationControlValidation.requireDigest(consumptionDigest, field: "consumption_digest")
        guard consumedAtMilliseconds >= 0,
              (priorGenerationID == nil) == (priorGenerationDigest == nil) else {
            throw RuntimeGenerationControlError.malformed(field: "activation_consumption")
        }
        if let priorGenerationDigest {
            try RuntimeGenerationControlValidation.requireDigest(
                priorGenerationDigest,
                field: "prior_generation_digest"
            )
        }
    }
}

extension RuntimeGenerationRestoreBaselinePlan {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        for (value, field) in [
            (planID, "restore_baseline_plan_id"),
            (sourceSafetyBackupID, "source_safety_backup_id"),
            (targetVerificationID, "target_verification_id"),
            (recoveryAuthorizationID, "recovery_authorization_id"),
        ] {
            try RuntimeGenerationControlValidation.requireIdentifier(value, field: field)
        }
        for (value, field) in [
            (sourceGenerationDigest, "source_generation_digest"),
            (sourceSafetyFenceDigest, "source_safety_fence_digest"),
            (targetActivationBaselineDigest, "target_activation_baseline_digest"),
            (recoveryAuthorizationDigest, "recovery_authorization_digest"),
            (planDigest, "restore_baseline_plan_digest"),
        ] {
            try RuntimeGenerationControlValidation.requireDigest(value, field: field)
        }
        guard sourceGenerationID != targetGenerationID,
              preparedAtMilliseconds >= 0 else {
            throw RuntimeGenerationControlError.rollbackUnsafe
        }
    }
}

extension RuntimeGenerationRollbackRecord {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        try RuntimeGenerationControlValidation.requireIdentifier(rollbackID, field: "rollback_id")
        try RuntimeGenerationControlValidation.requireIdentifier(
            restoreBaselinePlanID,
            field: "restore_baseline_plan_id"
        )
        try RuntimeGenerationControlValidation.requireIdentifier(
            targetVerificationID,
            field: "target_verification_id"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            sourceSafetyFenceDigest,
            field: "source_safety_fence_digest"
        )
        try RuntimeGenerationControlValidation.requireDigest(rollbackDigest, field: "rollback_digest")
        try targetObservedFence.validate()
        guard sourceGenerationID != targetGenerationID,
              targetObservedFence.generationID == targetGenerationID,
              postActivationEventCount == 0,
              postActivationCommandCount == 0,
              postActivationReceiptCount == 0,
              postActivationExternalEffectCount == 0,
              postActivationAttachmentLifecycleCount == 0,
              activatedAtMilliseconds >= 0
        else {
            throw RuntimeGenerationControlError.rollbackUnsafe
        }
    }
}

extension RuntimeGenerationQuarantineRecord {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        try RuntimeGenerationControlValidation.requireIdentifier(quarantineID, field: "quarantine_id")
        try originalArtifact.validate()
        try RuntimeGenerationControlValidation.requireDigest(diagnosticFingerprint, field: "diagnostic_fingerprint")
        try RuntimeGenerationControlValidation.requireDigest(quarantineDigest, field: "quarantine_digest")
        guard allowedActions.isEmpty == false,
              allowedActions == allowedActions.sorted(by: { $0.rawValue < $1.rawValue }),
              Set(allowedActions).count == allowedActions.count,
              allowedActions != [.explicitlyAuthorizedReset],
              quarantinedAtMilliseconds >= 0 else {
            throw RuntimeGenerationControlError.malformed(field: "quarantine")
        }
    }
}

extension RuntimeGenerationRebuildRecord {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        try RuntimeGenerationControlValidation.requireIdentifier(rebuildID, field: "rebuild_id")
        for (value, field) in [
            (sourceFenceDigest, "source_fence_digest"),
            (replayReconstructionDigest, "replay_reconstruction_digest"),
            (projectionGenerationDigest, "projection_generation_digest"),
            (searchGenerationDigest, "search_generation_digest"),
            (equivalenceDigest, "equivalence_digest"),
            (rebuildDigest, "rebuild_digest"),
        ] {
            try RuntimeGenerationControlValidation.requireDigest(value, field: field)
        }
        guard publishedAtMilliseconds >= 0 else {
            throw RuntimeGenerationControlError.malformed(field: "rebuild")
        }
    }
}

extension RuntimeLegacyImportSource {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        try RuntimeGenerationControlValidation.requireIdentifier(importID, field: "import_id")
        try sourceArtifact.validate()
        for (value, field) in [
            (sourceIdentityDigest, "source_identity_digest"),
            (sourceLocationFingerprint, "source_location_fingerprint"),
            (sourceDigest, "source_digest"),
        ] {
            try RuntimeGenerationControlValidation.requireDigest(value, field: field)
        }
        guard ((sourceKind == .canonicalV1 && sourceSchema == "canonical.sqlite.v1") ||
                (sourceKind == .swiftData && sourceSchema == objectStoreSwiftDataSchemaVersion)),
              sourceSchema.utf8.count <= 256,
              discoveredAtMilliseconds >= 0 else {
            throw RuntimeGenerationControlError.malformed(field: "import_source")
        }
    }
}

extension RuntimeLegacyImportItem {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        try RuntimeGenerationControlValidation.requireIdentifier(importID, field: "import_id")
        try RuntimeGenerationControlValidation.requireIdentifier(sourceRecordID, field: "source_record_id")
        try RuntimeGenerationControlValidation.requireDigest(sourceRecordDigest, field: "source_record_digest")
        try RuntimeGenerationControlValidation.requireDigest(itemDigest, field: "item_digest")
        guard (canonicalFamily == nil) == (canonicalID == nil),
              (canonicalID == nil) == (canonicalPayloadDigest == nil),
              (canonicalPayloadDigest == nil) == (mappedArtifact == nil),
              (disposition == .reviewableDiscovery) == (canonicalPayloadDigest != nil),
              warningCodes == warningCodes.sorted(),
              warningCodes.count <= 64,
              Set(warningCodes).count == warningCodes.count else {
            throw RuntimeGenerationControlError.malformed(field: "import_item")
        }
        if let canonicalPayloadDigest {
            try RuntimeGenerationControlValidation.requireDigest(
                canonicalPayloadDigest,
                field: "canonical_payload_digest"
            )
        }
        if let mappedArtifact {
            try RuntimeGenerationControlRecordFactory.validate(mappedArtifact)
        }
    }
}

extension RuntimeLegacyImportManifest {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        try RuntimeGenerationControlValidation.requireIdentifier(importID, field: "import_id")
        try RuntimeGenerationControlValidation.requireDigest(
            orderedItemSetDigest, field: "ordered_item_set_digest"
        )
        try RuntimeGenerationControlValidation.requireDigest(
            manifestDigest, field: "import_manifest_digest"
        )
        guard itemCount >= 0, itemCount <= RuntimeGenerationLegacyImportService.maximumRecords,
              completedAtMilliseconds >= 0 else {
            throw RuntimeGenerationControlError.malformed(field: "import_manifest")
        }
    }
}

extension RuntimeLegacyImportReviewPage {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        for (value, field) in [
            (pageID, "review_page_id"),
            (reviewID, "review_id"),
            (importID, "import_id"),
            (lastSourceRecordID, "last_source_record_id"),
        ] {
            try RuntimeGenerationControlValidation.requireIdentifier(value, field: field)
        }
        if let afterSourceRecordID {
            try RuntimeGenerationControlValidation.requireIdentifier(
                afterSourceRecordID, field: "after_source_record_id"
            )
        }
        try RuntimeGenerationControlValidation.requireDigest(
            pageDigest, field: "review_page_digest"
        )
        guard pageIndex >= 0,
              entries.isEmpty == false,
              entries.count <= RuntimeGenerationLegacyImportService.pageSize,
              Set(entries.map(\.itemDigest)).count == entries.count else {
            throw RuntimeGenerationControlError.malformed(field: "import_review_page")
        }
        for entry in entries {
            try RuntimeGenerationControlValidation.requireDigest(
                entry.itemDigest, field: "review_item_digest"
            )
        }
    }
}

extension RuntimeLegacyImportReview {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        try RuntimeGenerationControlValidation.requireIdentifier(reviewID, field: "review_id")
        try RuntimeGenerationControlValidation.requireIdentifier(importID, field: "import_id")
        for (value, field) in [
            (sourceDigest, "source_digest"),
            (reviewerConfirmationDigest, "reviewer_confirmation_digest"),
            (reviewDigest, "review_digest"),
        ] {
            try RuntimeGenerationControlValidation.requireDigest(value, field: field)
        }
        for (value, field) in [
            (orderedItemSetDigest, "ordered_item_set_digest"),
            (orderedDecisionSetDigest, "ordered_decision_set_digest"),
        ] {
            try RuntimeGenerationControlValidation.requireDigest(value, field: field)
        }
        let retained = retainedForFutureMigrationItemCount.addingReportingOverflow(
            retainedLossyForFutureMigrationItemCount
        )
        let total = retained.partialValue.addingReportingOverflow(rejectedItemCount)
        guard reviewedAtMilliseconds >= 0,
              itemCount >= 0,
              retainedForFutureMigrationItemCount >= 0,
              retainedLossyForFutureMigrationItemCount >= 0,
              rejectedItemCount >= 0,
              pageCount >= 0,
              retained.overflow == false, total.overflow == false,
              total.partialValue == itemCount,
              (itemCount == 0) == (pageCount == 0) else {
            throw RuntimeGenerationControlError.malformed(field: "import_review")
        }
    }
}

extension RuntimeGenerationRecoveryAuthorization {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        try RuntimeGenerationControlValidation.requireIdentifier(
            authorizationID,
            field: "authorization_id"
        )
        for (value, field) in [
            (targetDigest, "target_digest"),
            (alternativesReviewedDigest, "alternatives_reviewed_digest"),
            (consequenceDigest, "consequence_digest"),
            (authorizationDigest, "authorization_digest"),
        ] {
            try RuntimeGenerationControlValidation.requireDigest(value, field: field)
        }
        guard authorizedAtMilliseconds >= 0,
              expiresAtMilliseconds > authorizedAtMilliseconds else {
            throw RuntimeGenerationControlError.malformed(field: "recovery_authorization")
        }
    }
}

extension RuntimeGenerationRecoveryAuthorizationConsumption {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        try RuntimeGenerationControlValidation.requireIdentifier(
            authorizationID,
            field: "authorization_id"
        )
        for (value, field) in [
            (targetDigest, "target_digest"),
            (resultDigest, "result_digest"),
            (consumptionDigest, "recovery_authorization_consumption_digest"),
        ] {
            try RuntimeGenerationControlValidation.requireDigest(value, field: field)
        }
        guard consumedAtMilliseconds >= 0 else {
            throw RuntimeGenerationControlError.malformed(
                field: "recovery_authorization_consumed_at"
            )
        }
    }
}

extension RuntimeGenerationRecoveryOperationPlan {
    func validate() throws { try RuntimeGenerationControlRecordFactory.validate(self) }
}

extension RuntimeGenerationRecoveryOperationConsumption {
    func validate() throws { try RuntimeGenerationControlRecordFactory.validate(self) }
}

extension RuntimeGenerationRecoveryOperationExecutionClaim {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
    }
}

extension RuntimeGenerationRecoveryOperationExecutionReceipt {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
    }
}

extension RuntimeGenerationRecoveryOperationPlanDisposition { func validate() throws { try RuntimeGenerationControlRecordFactory.validate(self) } }
extension RuntimeGenerationRecoveryOperationPlanSuccession { func validate() throws { try RuntimeGenerationControlRecordFactory.validate(self) } }
extension RuntimeGenerationRecoveryOperationVerificationBinding { func validate() throws { try RuntimeGenerationControlRecordFactory.validate(self) } }

extension RuntimeGenerationRetentionTransition {
    func validate() throws {
        try RuntimeGenerationControlRecordFactory.validate(self)
        try RuntimeGenerationControlValidation.requireIdentifier(transitionID, field: "transition_id")
        try RuntimeGenerationControlValidation.requireIdentifier(reasonCode, field: "retention_reason_code")
        try RuntimeGenerationControlValidation.requireDigest(authorityDigest, field: "retention_authority_digest")
        try RuntimeGenerationControlValidation.requireDigest(transitionDigest, field: "transition_digest")
        guard fromClass != nil,
              fromClass != toClass,
              occurredAtMilliseconds >= 0 else {
            throw RuntimeGenerationControlError.malformed(field: "retention_transition")
        }
    }
}
