import Foundation
import XCTest
@testable import Ambitions

final class RuntimeAttachmentBoundaryTests: XCTestCase {
    func testSuccessfulRecoveryAtomicallyClosesMatchingOpenFindings() throws {
        let source = try String(contentsOf: attachmentSource("RuntimeAttachmentStore.swift"))
        let orphanStart = try XCTUnwrap(source.range(
            of: "static func completeUnownedManifestDeletion("
        ))
        let orphanEnd = try XCTUnwrap(source.range(
            of: "static func recoverySnapshots(",
            range: orphanStart.upperBound..<source.endIndex
        ))
        let finalizationStart = try XCTUnwrap(source.range(
            of: "func completeAttachmentFinalization("
        ))
        let deletionStart = try XCTUnwrap(source.range(
            of: "func recordAttachmentDeletion(",
            range: finalizationStart.upperBound..<source.endIndex
        ))
        let snapshotsStart = try XCTUnwrap(source.range(
            of: "func attachmentRecoverySnapshots(",
            range: deletionStart.upperBound..<source.endIndex
        ))
        let orphan = String(source[orphanStart.lowerBound..<orphanEnd.lowerBound])
        let finalization = String(source[finalizationStart.lowerBound..<deletionStart.lowerBound])
        let deletion = String(source[deletionStart.lowerBound..<snapshotsStart.lowerBound])

        XCTAssertTrue(orphan.contains("FROM runtime_blob_staging_orphans"))
        XCTAssertTrue(orphan.contains("markStagingOrphanCleaned("))
        XCTAssertTrue(orphan.contains("issue: .interruptedDeletion"))
        XCTAssertTrue(finalization.contains("issue: .finalizationMissing"))
        XCTAssertTrue(deletion.contains("issue: .interruptedDeletion"))
        XCTAssertTrue(deletion.contains("issue: .stagedExpired"))
        XCTAssertTrue(deletion.contains("Staged expiry remains actionable while deletion is pending"))
        XCTAssertTrue(orphan.contains("resolveOpenRecoveryFindings("))
        XCTAssertTrue(orphan.contains("workKind: .stagingOrphan"))
        XCTAssertTrue(finalization.contains("resolveOpenRecoveryFindings("))
        XCTAssertTrue(deletion.contains("resolveOpenRecoveryFindings("))
    }

    func testLifecycleHistoryBoundIsInspectionOnlyAndExpiredHoldsDoNotExhaustAuthority() throws {
        let store = try String(contentsOf: attachmentSource("RuntimeAttachmentStore.swift"))
        let schema = try String(contentsOf: attachmentSource("RuntimeAttachmentSchema.swift"))
        XCTAssertTrue(store.contains("nextSQLiteVersion(after: old.stateVersion)"))
        XCTAssertFalse(store.contains(
            "newVersion <= UInt64(RuntimeAttachmentLimits.maximumHistoryEntries)"
        ))
        XCTAssertFalse(schema.contains(
            "state_version BETWEEN 1 AND \\(RuntimeAttachmentLimits.maximumHistoryEntries)"
        ))
        XCTAssertTrue(store.contains("retain_until_ms IS NULL OR retain_until_ms > ?"))
        XCTAssertTrue(schema.contains("l.expires_at_ms > NEW.created_at_ms"))
    }

    func testKeychainCustodyIsDeviceOnlyNonSynchronizableAndNotAppGroupShared() throws {
        let source = try String(contentsOf: attachmentSource("RuntimeAttachmentKeyCustody.swift"))
        XCTAssertTrue(source.contains("kSecAttrAccessibleWhenUnlockedThisDeviceOnly"))
        XCTAssertTrue(source.contains("kSecAttrSynchronizable as String: kCFBooleanFalse"))
        XCTAssertTrue(source.contains("com.ambitions.runtime.attachments"))
        XCTAssertFalse(source.contains("kSecAttrAccessGroup"))
        XCTAssertFalse(source.contains("group.com.ambitions"))
        XCTAssertFalse(source.contains("kSecAttrSynchronizableAny"))
        XCTAssertFalse(source.contains("kSecAttrAccessibleAfterFirstUnlock"))
    }

    func testKeyCustodyBindsEnvelopeNonceAndRetainsVersionedHistoricalLookup() throws {
        let source = try String(contentsOf: attachmentSource("RuntimeAttachmentKeyCustody.swift"))
        XCTAssertTrue(source.contains("func wrappingKey(id:"))
        XCTAssertTrue(source.contains("func prepareWrappingKeyRotation("))
        XCTAssertTrue(source.contains("func activatePreparedWrappingKey("))
        XCTAssertTrue(source.contains("func rewrap("))
        XCTAssertTrue(source.contains("Data(sealed.nonce) == envelope.nonce"))
        XCTAssertTrue(source.contains("attachment-wrapping-key.active-version"))
        XCTAssertTrue(source.contains("attachment-wrapping-key.v"))
        XCTAssertTrue(source.contains("SecItemUpdate"))
    }

    func testShareExtensionCannotConstructVaultOrKeyCustody() throws {
        let source = try swiftSource(in: repositoryRoot.appendingPathComponent("Native/AmbitionsShareExtension"))
        assertNoPrivateVaultAuthority(source, boundary: "share extension")
        XCTAssertFalse(source.contains("RuntimeAttachmentSubsystem"))
        XCTAssertFalse(source.contains("CanonicalRuntimeAttachmentStore"))
    }

    func testWidgetExtensionCannotReadAttachmentBytesOrKeys() throws {
        let source = try swiftSource(in: repositoryRoot.appendingPathComponent("Native/AmbitionsWidgetExtension"))
        assertNoPrivateVaultAuthority(source, boundary: "widget extension")
        XCTAssertFalse(source.contains("RuntimeAttachmentReadGrant"))
        XCTAssertFalse(source.contains("RuntimeAttachmentPortableExporter"))
    }

    func testAppIntentsCannotReachVaultAndMustCrossTypedRuntimeBoundary() throws {
        let source = try swiftSource(in: repositoryRoot.appendingPathComponent("Native/Ambitions/App/Intents"))
        assertNoPrivateVaultAuthority(source, boundary: "App Intents")
        XCTAssertFalse(source.contains("CanonicalRuntimeAttachmentStore"))
        XCTAssertFalse(source.contains("SQLiteDatabase"))
        XCTAssertFalse(source.contains("FileHandle("))
    }

    func testCompatibilityAndLegacyLayersCannotBecomeAttachmentWriteAuthority() throws {
        let roots = [
            repositoryRoot.appendingPathComponent("Native/Ambitions/Core/Compatibility"),
            repositoryRoot.appendingPathComponent("Native/Ambitions/Core/Legacy"),
            repositoryRoot.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/Boundary"),
        ].filter { FileManager.default.fileExists(atPath: $0.path) }
        let source = try roots.map(swiftSource(in:)).joined(separator: "\n")
        XCTAssertFalse(source.contains("RuntimeAttachmentVault("))
        XCTAssertFalse(source.contains("KeychainRuntimeAttachmentKeyCustody("))
        XCTAssertFalse(source.contains("CanonicalRuntimeAttachmentStore.apply("))
        XCTAssertFalse(source.contains("persistStagedAttachment("))
    }

    func testOnlyMainApplicationSubsystemOwnsDefaultVaultConstruction() throws {
        let attachmentRoot = repositoryRoot
            .appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/Attachments")
        let files = try FileManager.default.contentsOfDirectory(
            at: attachmentRoot, includingPropertiesForKeys: [.isRegularFileKey]
        ).filter { $0.pathExtension == "swift" }
        let constructors = try files.filter {
            try String(contentsOf: $0).contains("KeychainRuntimeAttachmentKeyCustody()")
        }.map(\.lastPathComponent).sorted()
        XCTAssertEqual(constructors, [
            "RuntimeAttachmentSubsystem.swift",
        ])
        let subsystem = try String(contentsOf: attachmentSource("RuntimeAttachmentSubsystem.swift"))
        XCTAssertTrue(subsystem.contains("static func mainApplication("))
        XCTAssertFalse(subsystem.contains("shareExtension"))
        XCTAssertFalse(subsystem.contains("widgetExtension"))
    }

    func testReadGrantIsAuthenticatedOpaqueCapabilityNotAForgeableBlobIdentifier() throws {
        let source = try String(contentsOf: attachmentSource("RuntimeAttachmentQueries.swift"))
        XCTAssertTrue(source.contains("HMAC<SHA256>.authenticationCode"))
        XCTAssertTrue(source.contains("authenticationKey"))
        XCTAssertTrue(source.contains("constantTimeEquals"))
        XCTAssertTrue(source.contains("expiresAt"))
        XCTAssertTrue(source.contains("grant.expiresAt > observedAt"))
        XCTAssertTrue(source.contains("allowedPurpose"))
        XCTAssertTrue(source.contains("private let clock: @Sendable () -> Date"))
        XCTAssertFalse(source.contains("allowedPurpose: RuntimeAttachmentReadPurpose,\n        now:"))
        XCTAssertFalse(source.contains("purpose: RuntimeAttachmentReadPurpose,\n        now:"))
        XCTAssertFalse(source.contains("authorityIssued(") && source.contains("public static func authorityIssued"))
    }

    func testPortableAttachmentExportAuthenticatesAuthorityAndPinsBlobLifetime() throws {
        let source = try String(contentsOf: attachmentSource("RuntimeAttachmentPortableExport.swift"))
        let queries = try String(contentsOf: attachmentSource("RuntimeAttachmentQueries.swift"))
        XCTAssertTrue(source.contains("authenticatedAuthority("))
        XCTAssertTrue(source.contains("allowedPurpose: .userInitiatedExport"))
        XCTAssertTrue(source.contains("kind: .export"))
        XCTAssertTrue(source.contains("acquireAuthenticatedAttachmentReadHold("))
        XCTAssertTrue(source.contains("releaseAttachmentRetentionHold("))
        XCTAssertFalse(source.contains("accessAuthority.authenticates("))
        XCTAssertFalse(source.contains("store.attachmentGraph("))
        XCTAssertTrue(source.contains("if exportError is CancellationError"))
        XCTAssertTrue(source.contains("destination is already atomically installed and synchronized"))
        XCTAssertTrue(queries.contains("Cancellation remains the"))
        XCTAssertTrue(queries.contains("throw CancellationError()"))
    }

    func testPortableAttachmentCustodyRemainsDeviceOnlyAndImportUsesDescriptorAuthority() throws {
        let source = try String(contentsOf: attachmentSource("RuntimeAttachmentPortableExport.swift"))
        XCTAssertTrue(source.contains("kSecAttrAccessibleWhenUnlockedThisDeviceOnly"))
        XCTAssertTrue(source.contains("kSecAttrSynchronizable as String: kCFBooleanFalse"))
        XCTAssertFalse(source.contains("kSecAttrAccessGroup"))
        XCTAssertTrue(source.contains("DeviceLocalRuntimeAttachmentExportCustody"))
        XCTAssertTrue(source.contains("RuntimeAttachmentRecoveryKeyPackageCustody"))
        XCTAssertTrue(source.contains("O_NOFOLLOW"))
        XCTAssertTrue(source.contains("O_EXCL"))
        XCTAssertTrue(source.contains("fstat("))
        XCTAssertTrue(source.contains("RuntimeAttachmentPortableTerminal"))
        let subsystem = try String(contentsOf: attachmentSource("RuntimeAttachmentSubsystem.swift"))
        XCTAssertTrue(subsystem.contains("func portableImportCoordinator("))
        XCTAssertTrue(subsystem.contains("RuntimeAttachmentPortableImporter("))
        XCTAssertTrue(subsystem.contains("RuntimeAttachmentPortableImportCoordinator("))
        XCTAssertTrue(subsystem.contains("AttachmentPortableImport"))
        XCTAssertTrue(source.contains("pendingRecovery"))
    }

    func testPortableContainerExposesOnlyKeySelectionPreambleAndAuthenticatesFrameOrder() throws {
        let source = try String(contentsOf: attachmentSource("RuntimeAttachmentPortableExport.swift"))
        let preambleStart = try XCTUnwrap(source.range(
            of: "private struct RuntimeAttachmentPortablePreamble"
        ))
        let headerStart = try XCTUnwrap(source.range(
            of: "private struct RuntimeAttachmentPortableHeader",
            range: preambleStart.upperBound..<source.endIndex
        ))
        let preamble = String(source[preambleStart.lowerBound..<headerStart.lowerBound])

        XCTAssertTrue(preamble.contains("let format: String"))
        XCTAssertTrue(preamble.contains("let version: Int"))
        XCTAssertTrue(preamble.contains("let challenge: Data"))
        XCTAssertTrue(preamble.contains("let keySelector: String"))
        XCTAssertFalse(preamble.contains("keyIdentifier"))
        XCTAssertFalse(preamble.contains("revisionID"))
        XCTAssertFalse(preamble.contains("manifestDigest"))
        XCTAssertFalse(preamble.contains("privacy"))
        XCTAssertFalse(preamble.contains("classification"))
        XCTAssertFalse(preamble.contains("plaintextByteCount"))
        XCTAssertTrue(source.contains("HMAC<SHA256>.authenticationCode"))
        XCTAssertTrue(source.contains("SecRandomCopyBytes"))
        XCTAssertTrue(source.contains("static let challengeByteCount = 32"))
        XCTAssertTrue(source.contains("portable.key-selector.v2"))
        XCTAssertTrue(source.contains("message.append(challenge)"))
        XCTAssertTrue(source.contains("preamble.challenge.count == RuntimeAttachmentPortableKeySelector.challengeByteCount"))
        XCTAssertTrue(source.contains("RuntimeStoreManifestCodec.isSHA256Hex(preamble.keySelector)"))
        XCTAssertTrue(source.contains("AES.GCM.seal(\n            paddedHeaderBytes"))
        XCTAssertTrue(source.contains("AES.GCM.open(\n                AES.GCM.SealedBox(combined: encryptedHeaderFrame.bytes)"))
        XCTAssertFalse(source.contains("try output.write(contentsOf: headerBytes)"))
        XCTAssertTrue(source.contains("static let plaintextByteCount = RuntimeAttachmentLimits.maximumManifestBytes"))
        XCTAssertTrue(source.contains("value.suffix(from: headerEnd).allSatisfy({ $0 == 0 })"))
        XCTAssertTrue(source.contains("portable.metadata.v2"))
        XCTAssertTrue(source.contains("portable.chunk.v2"))
        XCTAssertTrue(source.contains("portable.terminal.v2"))
        XCTAssertTrue(source.contains("terminal.preambleDigest == preambleDigest"))
        XCTAssertTrue(source.contains("terminal.encryptedHeaderDigest == encryptedHeaderDigest"))
        XCTAssertTrue(source.contains("terminal.orderedCiphertextDigest == orderedDigest"))
    }

    func testLifecycleProofsAreIssuedOnlyByTheVaultBoundary() throws {
        let vault = try String(contentsOf: attachmentSource("RuntimeAttachmentVault.swift"))
        let models = try String(contentsOf: attachmentSource("RuntimeAttachmentModels.swift"))
        XCTAssertTrue(vault.contains("struct RuntimeAttachmentFinalizationProof"))
        XCTAssertTrue(vault.contains("struct RuntimeAttachmentPhysicalDeletionProof"))
        XCTAssertTrue(vault.contains("fileprivate init("))
        XCTAssertTrue(vault.contains("writeFinalizationMarker("))
        XCTAssertTrue(vault.contains("prepareLeaseOwnedDeletion("))
        XCTAssertTrue(vault.contains("finalizeLeaseOwnedDeletion("))
        XCTAssertFalse(vault.contains("deleteOwnedBlobWithProof("))
        XCTAssertFalse(models.contains("struct RuntimeAttachmentFinalizationProof"))
        XCTAssertFalse(models.contains("struct RuntimeAttachmentPhysicalDeletionProof"))
    }

    func testFilesystemRecoveryPagingIsStreamingBoundedAndDeletionIsFailClosed() throws {
        let vault = try String(contentsOf: attachmentSource("RuntimeAttachmentVault.swift"))
        let intake = try String(contentsOf: attachmentSource("RuntimeAttachmentIntake.swift"))

        XCTAssertFalse(vault.contains("contentsOfDirectory("))
        XCTAssertFalse(intake.contains("contentsOfDirectory("))
        XCTAssertTrue(vault.contains("fdopendir("))
        XCTAssertTrue(vault.contains("readdir("))
        XCTAssertTrue(intake.contains("fdopendir("))
        XCTAssertTrue(intake.contains("readdir("))
        XCTAssertTrue(vault.contains("if values.count > limit { values.removeLast() }"))
        XCTAssertTrue(intake.contains("if values.count > limit { values.removeLast() }"))
        XCTAssertTrue(vault.contains("String(format: \"%02x\", shardIndex)"))
        XCTAssertTrue(vault.contains("insertBoundedRawDirectoryEntry(candidate"))
        XCTAssertTrue(intake.contains("insertBoundedRawDirectoryEntry(candidate"))
        XCTAssertTrue(vault.contains("limit: limit + 1"))
        XCTAssertTrue(intake.contains("limit: limit + 1"))
        XCTAssertTrue(vault.contains("nextRawCursor"))
        XCTAssertTrue(intake.contains("nextRawCursor"))
        XCTAssertFalse(vault.contains("telldir("))
        XCTAssertFalse(vault.contains("seekdir("))
        XCTAssertTrue(vault.contains("maximumOwnedTemporaryDirectoryCount = 4_096"))
        XCTAssertTrue(intake.contains("maximumOwnedIntakeLeftoverCount = 4_096"))
        XCTAssertTrue(vault.contains("ensureTemporaryDirectoryCapacity()"))
        XCTAssertTrue(intake.contains("ensureIntakeLeftoverCapacity()"))
        XCTAssertTrue(intake.contains("Plaintext cleanup is part of successful intake"))
        XCTAssertFalse(intake.contains("defer { try? fileManager.removeItem(at: ownedURL) }"))
        XCTAssertTrue(intake.contains("lstat(candidate.path, &after) != 0, errno == ENOENT"))
        XCTAssertTrue(vault.contains("childCount <= maximumChildCount"))
        XCTAssertTrue(vault.contains("validateBoundedAllowlistedChildren("))
        XCTAssertTrue(vault.contains("pathEntryExistsNoFollow(directory) == false"))
        XCTAssertTrue(vault.contains("try synchronizeDirectory(directory.deletingLastPathComponent())"))
        XCTAssertFalse(vault.contains("fileManager.fileExists(atPath: directory.path) == false"))
    }

    func testAttachmentProtectionAndMetadataContractsMatchProducedAuthority() throws {
        let models = try String(contentsOf: attachmentSource("RuntimeAttachmentModels.swift"))
        let codec = try String(contentsOf: attachmentSource("RuntimeAttachmentCodec.swift"))
        let intake = try String(contentsOf: attachmentSource("RuntimeAttachmentIntake.swift"))
        let vault = try String(contentsOf: attachmentSource("RuntimeAttachmentVault.swift"))

        XCTAssertFalse(models.contains("completeUntilFirstUserAuthentication"))
        XCTAssertTrue(codec.contains("value.protectionClass == .complete"))
        XCTAssertTrue(codec.contains("value.classification.signatureVersion == 1"))
        XCTAssertTrue(codec.contains("value.sourceRecordID.utf8.count <= 1_024"))
        XCTAssertTrue(codec.contains("value.sourceApplicationFingerprint.map({ isSHA($0) }) ?? true"))
        XCTAssertTrue(intake.contains("RuntimeAttachmentCodec.validate(part.provenance)"))
        XCTAssertTrue(vault.contains("RuntimeAttachmentCodec.validate(request.provenance)"))
        XCTAssertTrue(models.contains("let sourceDevice: UInt64"))
        XCTAssertTrue(models.contains("let sourceInode: UInt64"))
        XCTAssertTrue(codec.contains("String(proof.sourceDevice)"))
        XCTAssertTrue(codec.contains("String(proof.sourceInode)"))
    }

    func testRecoveryUsesCycleScopedOccurrencesAndQuarantinesUnsafeAuthority() throws {
        let recovery = try String(contentsOf: attachmentSource("RuntimeAttachmentRecovery.swift"))

        XCTAssertTrue(recovery.contains("releaseExpiredAttachmentQuotaReservations("))
        XCTAssertTrue(recovery.contains("expiredQuotaReservationCount"))
        XCTAssertTrue(recovery.contains("let cycle = cursor?.cycle ?? 0"))
        XCTAssertTrue(recovery.contains("recoveryAttemptAuthorityID("))
        XCTAssertTrue(recovery.contains("recoveryFindingEvidenceFingerprint("))
        XCTAssertTrue(recovery.contains("resolveOpenAttachmentRecoveryFindings("))
        XCTAssertFalse(recovery.contains("resolveAttachmentRecoveryFinding("))
        XCTAssertTrue(recovery.contains("graph.lifecycle.state == .referenced || graph.lifecycle.state == .finalized"))
        XCTAssertTrue(recovery.contains("recoveryQuarantineReason(for: error)"))
        XCTAssertTrue(recovery.contains("quarantineAttachmentForRecovery("))
    }

    func testWrappingKeyRotationHasDurableCASProgressAndNoDeletionCapability() throws {
        let schema = try String(contentsOf: attachmentSource("RuntimeAttachmentSchema.swift"))
        let store = try String(contentsOf: attachmentSource("RuntimeAttachmentKeyRotationStore.swift"))
        let coordinator = try String(contentsOf: attachmentSource("RuntimeAttachmentKeyRotation.swift"))
        let attachmentStore = try String(contentsOf: attachmentSource("RuntimeAttachmentStore.swift"))
        let staging = try String(contentsOf: attachmentSource("RuntimeAttachmentStagingCoordinator.swift"))
        XCTAssertTrue(schema.contains("runtime_blob_key_rewrap_jobs"))
        XCTAssertTrue(schema.contains("runtime_blob_key_rewrap_items"))
        XCTAssertTrue(schema.contains("runtime_blob_key_envelopes_authorized_rewrap"))
        XCTAssertTrue(store.contains("expected_envelope_digest"))
        XCTAssertTrue(store.contains("reconcileLateKeyRewrapItems"))
        XCTAssertTrue(store.contains("remainingEnvelopeCount"))
        XCTAssertEqual(store.components(separatedBy: "state_version = state_version + 1").count - 1, 7)
        XCTAssertEqual(store.components(separatedBy: "state_version < ?").count - 1, 7)
        XCTAssertTrue(store.contains("RuntimeAttachmentCodec.sqliteInteger(claim.itemStateVersion)"))
        XCTAssertTrue(store.contains("RuntimeAttachmentCodec.sqliteInteger(job.stateVersion)"))
        XCTAssertFalse(store.contains("Int64(claim.itemStateVersion)"))
        XCTAssertFalse(store.contains("Int64(job.stateVersion)"))
        XCTAssertTrue(coordinator.contains("releaseAttachmentKeyRewrapClaim"))
        XCTAssertTrue(coordinator.contains("catch RuntimeCanonicalAttachmentError.invalidLease"))
        XCTAssertTrue(coordinator.contains("catch RuntimeCanonicalAttachmentError.lifecycleConflict"))
        XCTAssertTrue(coordinator.contains("throw CancellationError()"))
        XCTAssertTrue(coordinator.contains("supportsIrreversibleKeyRetirement"))
        XCTAssertTrue(coordinator.contains("activeAttachmentKeyRewrapJob()"))
        XCTAssertTrue(attachmentStore.contains("RuntimeCanonicalAttachmentError.staleWrappingKey"))
        XCTAssertTrue(staging.contains("keyCustody.rewrap("))
        XCTAssertFalse(coordinator.contains("SecItemDelete"))
    }

    func testPortablePlaintextCleanupIsDurableBeforeDestinationCreationAndStartupOwned() throws {
        let portable = try String(contentsOf: attachmentSource("RuntimeAttachmentPortableExport.swift"))
        let subsystem = try String(contentsOf: attachmentSource("RuntimeAttachmentSubsystem.swift"))
        let recovery = try String(contentsOf: attachmentSource("RuntimeAttachmentRecovery.swift"))

        let persist = try XCTUnwrap(portable.range(of: "try persistCleanupJob("))
        let create = try XCTUnwrap(portable.range(
            of: "O_WRONLY | O_CREAT | O_EXCL",
            range: persist.upperBound..<portable.endIndex
        ))
        XCTAssertLessThan(persist.lowerBound, create.lowerBound)
        XCTAssertTrue(portable.contains("HMAC<SHA256>.isValidAuthenticationCode"))
        XCTAssertTrue(portable.contains("header.keyIdentifier == exportKey.identifier"))
        XCTAssertTrue(portable.contains("lstat(candidate.path, &deleted) != 0, errno == ENOENT"))
        XCTAssertTrue(subsystem.contains("let portableImporter: RuntimeAttachmentPortableImporter"))
        XCTAssertTrue(recovery.contains("portableImporter.recoverInterruptedImports("))
        XCTAssertTrue(portable.contains("forEachRawDirectoryEntry(at: importRoot)"))
        XCTAssertTrue(portable.contains("String(data: rawBytes, encoding: .utf8)"))
        XCTAssertTrue(portable.contains("requiresSingleLink: true"))
        XCTAssertTrue(portable.contains("cleanupRecoveryPage(limit:"))
        XCTAssertTrue(portable.contains("nextRawCursor"))
        XCTAssertTrue(portable.contains("redactedNameDigest"))
        XCTAssertTrue(portable.contains("CleanupRecoveryCursorRecord"))
        XCTAssertTrue(portable.contains("persistCleanupRecoveryCursor("))
        XCTAssertTrue(portable.contains("authenticatedCleanupRecoveryCursor("))
        XCTAssertFalse(portable.contains("ownedCleanupJobNames"))
    }

    func testTerminalVerificationKeepsOriginalDescriptorAndBoundsHeaderBeforeRead() throws {
        let vault = try String(contentsOf: attachmentSource("RuntimeAttachmentVault.swift"))
        XCTAssertTrue(vault.contains("verifyTerminal(\n                handle: handle"))
        XCTAssertTrue(vault.contains("expectedAuthority: openedPayload.authority"))
        XCTAssertTrue(vault.contains("headerLength <= RuntimeAttachmentLimits.maximumManifestBytes"))
        XCTAssertFalse(vault.contains("func verifyTerminal(\n        payloadURL:"))
    }

    func testRecoveryIsolationUsesRedactedRawNameCursorsAndClaimOwnedDeletion() throws {
        let vault = try String(contentsOf: attachmentSource("RuntimeAttachmentVault.swift"))
        let recovery = try String(contentsOf: attachmentSource("RuntimeAttachmentRecovery.swift"))
        let collector = try String(contentsOf: attachmentSource("RuntimeAttachmentGarbageCollector.swift"))

        XCTAssertTrue(vault.contains("RuntimeAttachmentFilesystemMalformedEntry"))
        XCTAssertTrue(vault.contains("redactedNameDigest: RuntimeAttachmentCodec.sha256(rawName)"))
        XCTAssertTrue(vault.contains("String(data: rawBytes, encoding: .utf8)"))
        XCTAssertTrue(recovery.contains("reconcileManifestDeletionClaims("))
        XCTAssertTrue(vault.contains("resumeUnownedManifestDeletion("))
        XCTAssertTrue(vault.contains("finalizeUnownedManifestDeletion("))
        XCTAssertTrue(collector.contains("renewAttachmentGCLease("))
        XCTAssertTrue(collector.contains("prepareLeaseOwnedDeletion("))
        XCTAssertTrue(collector.contains("finalizeLeaseOwnedDeletion("))
    }

    func testDedupCleanupReusesDurableManifestDeletionClaimsAndAtomicCompletion() throws {
        let staging = try String(contentsOf: attachmentSource(
            "RuntimeAttachmentStagingCoordinator.swift"
        ))
        let store = try String(contentsOf: attachmentSource("RuntimeAttachmentStore.swift"))
        let vault = try String(contentsOf: attachmentSource("RuntimeAttachmentVault.swift"))

        XCTAssertTrue(staging.contains("claimUnownedAttachmentManifestDeletion("))
        XCTAssertTrue(staging.contains("prepareUnownedManifestDeletion("))
        XCTAssertTrue(staging.contains("finalizeUnownedManifestDeletion("))
        XCTAssertTrue(staging.contains("completeUnownedAttachmentManifestDeletion("))
        XCTAssertTrue(store.contains("FROM runtime_blob_staging_orphans"))
        XCTAssertTrue(store.contains("private static func markStagingOrphanCleaned("))
        XCTAssertFalse(store.contains("func markAttachmentStagingOrphanCleaned("))
        XCTAssertFalse(store.contains("func markAttachmentStagingOrphanCleanedDuringRecovery("))
        XCTAssertFalse(vault.contains("deleteDedupOwnedBlob("))
    }

    private var repositoryRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func attachmentSource(_ filename: String) -> URL {
        repositoryRoot
            .appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/Attachments")
            .appendingPathComponent(filename)
    }

    private func swiftSource(in root: URL) throws -> String {
        guard FileManager.default.fileExists(atPath: root.path) else { return "" }
        guard let enumerator = FileManager.default.enumerator(
            at: root, includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return "" }
        let urls = enumerator.compactMap { $0 as? URL }
            .filter { $0.pathExtension == "swift" }
            .sorted { $0.path < $1.path }
        return try urls.map { try String(contentsOf: $0) }.joined(separator: "\n")
    }

    private func assertNoPrivateVaultAuthority(
        _ source: String,
        boundary: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        for forbidden in [
            "RuntimeAttachmentVault", "RuntimeAttachmentKeyCustody",
            "KeychainRuntimeAttachmentKeyCustody", "RuntimeAttachmentStageBundle",
            "RuntimeBlobKeyEnvelope", "payload.aead", "manifest.json",
        ] {
            XCTAssertFalse(source.contains(forbidden), "\(boundary) contains \(forbidden)", file: file, line: line)
        }
    }
}
