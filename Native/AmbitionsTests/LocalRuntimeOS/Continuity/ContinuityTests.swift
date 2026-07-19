import XCTest
@testable import Ambitions

final class ContinuityTests: XCTestCase {
    func testContinuityOwnerFilesExistUnderCanonicalLocalRuntimeOSOwner() throws {
        let root = try repoRoot()
        let requiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/Continuity/LocalAuthoritativeSyncModel.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Continuity/CloudKitContinuityClient.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Continuity/ContinuityAuthorityGate.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Continuity/SyncEligibilityPolicy.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Continuity/SyncEnvelope.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Continuity/CausalMergeEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Continuity/ConflictPolicyEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Continuity/TombstoneSync.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Continuity/AccountStateMachine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Continuity/SignOutDeleteResetCoordinator.swift",
        ]
        let removedOldOwners = [
            "Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity",
            "Native/AmbitionsTests/LocalRuntimeOS/SyncContinuity",
            "Native/Ambitions/Core/Persistence/SyncCapabilityContracts.swift",
            "Native/Ambitions/Core/Persistence/CloudKitContinuityModels.swift",
            "Native/Ambitions/Core/Persistence/CloudKitContinuityClient.swift",
            "Native/Ambitions/Core/Domain/Planning/LivingPlanContinuitySync.swift",
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
        for path in removedOldOwners {
            XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
    }

    func testAccountStateMachineKeepsLocalOperationAuthoritativeAcrossUnavailableStates() {
        let machine = AccountStateMachine()

        let noAccount = machine.snapshot(
            featureFlagEnabled: true,
            accountStatus: .noAccount,
            proofVerified: false,
            userPausedSync: false,
            evaluatedAt: "2026-06-30T12:00:00Z"
        )

        XCTAssertEqual(noAccount.syncState, .accountUnavailable)
        XCTAssertEqual(noAccount.transition, .requireAccount)
        XCTAssertFalse(noAccount.localOperationBlocked)
        XCTAssertTrue(noAccount.localOnlyFallbackActive)
        XCTAssertEqual(AccountStateMachine.availability(for: noAccount.syncState), .noAccount)

        let healthy = machine.snapshot(
            featureFlagEnabled: true,
            accountStatus: .available,
            proofVerified: true,
            userPausedSync: false,
            evaluatedAt: "2026-06-30T12:01:00Z"
        )
        XCTAssertEqual(healthy.syncState, .healthyAfterProof)
        XCTAssertEqual(healthy.transition, .proofBackedReady)
        XCTAssertEqual(AccountStateMachine.availability(for: healthy.syncState), .available)
    }

    func testEligibilityAllowsOnlyProofBackedContinuitySafeEnvelopes() throws {
        let safeEnvelope = try makeEnvelope(
            recordName: "receipt.safe",
            family: .receipt,
            payloadClass: .receiptMetadata
        )
        let safeDecision = SyncEligibilityPolicy().evaluate(
            SyncEligibilityCandidate(
                id: "safe",
                envelope: safeEnvelope,
                privacyPolicy: .privateCloud,
                syncState: .healthyAfterProof,
                accountStatus: .available,
                userConfirmed: true,
                proofVerified: true,
                requestedAt: "2026-06-30T12:02:00Z"
            )
        )

        XCTAssertEqual(safeDecision.outcome, .eligibleForCloudKit)
        XCTAssertTrue(safeDecision.localWriteAllowed)
        XCTAssertTrue(safeDecision.cloudKitWriteAllowed)
        XCTAssertTrue(safeDecision.localStoreRemainsAuthoritative)

        let privateEnvelope = try makeEnvelope(
            recordName: "goal.private",
            family: .goal,
            payloadClass: .privateLifeGraphObject
        )
        let deniedDecision = SyncEligibilityPolicy().evaluate(
            SyncEligibilityCandidate(
                id: "private",
                envelope: privateEnvelope,
                privacyPolicy: .privateCloud,
                syncState: .healthyAfterProof,
                accountStatus: .available,
                userConfirmed: true,
                proofVerified: true,
                requestedAt: "2026-06-30T12:03:00Z"
            )
        )

        XCTAssertEqual(deniedDecision.outcome, .deniedPrivateGraph)
        XCTAssertFalse(deniedDecision.cloudKitWriteAllowed)
        XCTAssertEqual(deniedDecision.operation, .review)
    }

    func testAuthorityGateAllowsOnlyRuntimeEventsAndApprovedProjections() throws {
        let runtimeEventEnvelope = try makeEnvelope(
            recordName: "receipt.event-authority",
            family: .receipt,
            payloadClass: .receiptMetadata
        )
        let projectionEnvelope = try makeEnvelope(
            recordName: "projection.privacy",
            family: .syncLedger,
            payloadClass: .syncLedger,
            includeRuntimeLineage: false
        )
        let directObjectEnvelope = try makeEnvelope(
            recordName: "object.direct",
            family: .step,
            payloadClass: .eventEnvelopeMetadata,
            includeRuntimeLineage: false
        )

        let gate = ContinuityAuthorityGate()
        let runtimeEventDecision = gate.evaluate(
            ContinuityAuthorityEvidence(
                envelope: runtimeEventEnvelope,
                sourceAuthority: .runtimeEvent,
                privacyClass: .syncMetadata,
                runtimeEventID: "runtime_event.receipt.event-authority",
                localStoreAuthoritative: true,
                attemptsBackendAuthority: false,
                accountRequiredForCoreUse: false
            )
        )
        let projectionDecision = gate.evaluate(
            ContinuityAuthorityEvidence(
                envelope: projectionEnvelope,
                sourceAuthority: .approvedProjection,
                privacyClass: .systemOwned,
                approvedProjectionID: "Projections.PrivacyProjection.continuity",
                localStoreAuthoritative: true,
                attemptsBackendAuthority: false,
                accountRequiredForCoreUse: false
            )
        )
        let directObjectDecision = gate.evaluate(
            ContinuityAuthorityEvidence(
                envelope: directObjectEnvelope,
                sourceAuthority: .directObjectStore,
                privacyClass: .standard,
                localStoreAuthoritative: true,
                attemptsBackendAuthority: false,
                accountRequiredForCoreUse: false
            )
        )

        XCTAssertTrue(runtimeEventDecision.allowedForCloudKitTransport)
        XCTAssertTrue(projectionDecision.allowedForCloudKitTransport)
        XCTAssertFalse(directObjectDecision.allowedForCloudKitTransport)
        XCTAssertTrue(directObjectDecision.requiresLocalReview)
        XCTAssertTrue(directObjectDecision.issues.contains(.nonRuntimeSource))
        XCTAssertTrue(directObjectDecision.issues.contains(.missingRuntimeLineage))
    }

    func testAuthorityGateDeniesPrivatePrivacyClassesAndBackendAuthority() throws {
        let envelope = try makeEnvelope(
            recordName: "receipt.private-authority",
            family: .receipt,
            payloadClass: .receiptMetadata
        )
        let privatePrivacyDecision = SyncEligibilityPolicy().evaluate(
            SyncEligibilityCandidate(
                id: "private-privacy",
                envelope: envelope,
                privacyPolicy: .privateCloud,
                syncState: .healthyAfterProof,
                accountStatus: .available,
                userConfirmed: true,
                proofVerified: true,
                requestedAt: "2026-07-01T12:00:00Z",
                sourceAuthority: .runtimeEvent,
                privacyClass: .privateUserText,
                runtimeEventID: "runtime_event.receipt.private-authority"
            )
        )
        let backendAuthorityDecision = SyncEligibilityPolicy().evaluate(
            SyncEligibilityCandidate(
                id: "backend-authority",
                envelope: envelope,
                privacyPolicy: .privateCloud,
                syncState: .healthyAfterProof,
                accountStatus: .available,
                userConfirmed: true,
                proofVerified: true,
                requestedAt: "2026-07-01T12:01:00Z",
                sourceAuthority: .remoteBackend,
                privacyClass: .syncMetadata,
                localStoreAuthoritative: false,
                attemptsBackendAuthority: true,
                accountRequiredForCoreUse: true
            )
        )

        XCTAssertEqual(privatePrivacyDecision.outcome, .deniedPrivacyClass)
        XCTAssertFalse(privatePrivacyDecision.cloudKitWriteAllowed)
        XCTAssertTrue(privatePrivacyDecision.localStoreRemainsAuthoritative)
        XCTAssertTrue(privatePrivacyDecision.reasons.contains("privacy_class_private_user_text_cannot_enter_continuity"))

        XCTAssertEqual(backendAuthorityDecision.outcome, .deniedBackendAuthority)
        XCTAssertFalse(backendAuthorityDecision.localWriteAllowed)
        XCTAssertFalse(backendAuthorityDecision.cloudKitWriteAllowed)
        XCTAssertFalse(backendAuthorityDecision.localStoreRemainsAuthoritative)
        XCTAssertTrue(backendAuthorityDecision.reasons.contains("continuity_cannot_become_backend_authority"))
        XCTAssertTrue(backendAuthorityDecision.reasons.contains("offline_core_must_not_require_account"))
    }

    func testNoAccountOfflineCoreStaysLocalAuthoritative() async {
        let authority = LocalAuthoritativeSyncModel()
        let capability = LocalOnlySyncCapability(
            diagnosticsProvider: LocalOnlyCloudKitContinuityDiagnosticsProvider(
                featureFlagEnabled: true,
                accountStatusProbe: StaticCloudKitAccountStatusProbe(accountStatusValue: .noAccount)
            ),
            authority: authority
        )

        let status = await capability.status()

        XCTAssertTrue(authority.localStoreAuthoritative)
        XCTAssertTrue(authority.continuityOptional)
        XCTAssertTrue(authority.offlineCoreAvailable)
        XCTAssertFalse(authority.accountRequiredForCoreUse)
        XCTAssertFalse(authority.allowsPrivateGraphBackendAuthority)
        XCTAssertEqual(status.syncState, .accountUnavailable)
        XCTAssertFalse(status.localOperationBlocked)
        XCTAssertTrue(status.localOnlyFallbackActive)
        XCTAssertFalse(status.writesUserData)
        XCTAssertFalse(status.userDataCaptured)
    }

    func testCausalMergeAndConflictPolicyQuarantineUnreviewedRemoteAcceptance() throws {
        let local = try makeEnvelope(
            recordName: "receipt.merge",
            family: .receipt,
            localRevision: 1,
            updatedAt: "2026-06-30T12:04:00Z",
            payloadClass: .receiptMetadata
        )
        let remote = try makeEnvelope(
            recordName: "receipt.merge",
            family: .receipt,
            localRevision: 2,
            updatedAt: "2026-06-30T12:05:00Z",
            payloadClass: .receiptMetadata
        )

        let merge = CausalMergeEngine().merge(
            CausalMergeCandidate(
                localEnvelope: local,
                remoteEnvelope: remote,
                localDeviceID: "same-device",
                remoteDeviceID: "same-device"
            ),
            createdAt: "2026-06-30T12:06:00Z"
        )

        XCTAssertEqual(merge.outcome, .acceptRemote)
        XCTAssertEqual(merge.selectedEnvelope?.localRevision, 2)

        let eligibility = SyncEligibilityDecision(
            id: "eligibility.accept",
            outcome: .eligibleForCloudKit,
            operation: .upsert,
            localWriteAllowed: true,
            cloudKitWriteAllowed: true,
            requiresUserConfirmation: false,
            localStoreRemainsAuthoritative: true,
            reasons: ["test"],
            evaluatedAt: "2026-06-30T12:07:00Z"
        )
        let conflict = ConflictPolicyEngine().decide(
            SyncConflictCandidate(
                mergeDecision: merge,
                eligibilityDecision: eligibility,
                userReviewed: false
            )
        )

        XCTAssertEqual(conflict.resolution, .quarantineForReview)
        XCTAssertTrue(conflict.quarantine)
        XCTAssertFalse(conflict.externalWriteAllowed)
        XCTAssertTrue(conflict.localStoreRemainsAuthoritative)
    }

    func testSameClockPayloadDriftQueuesLocalReviewInsteadOfSilentOverwrite() throws {
        let local = try makeEnvelope(
            recordName: "receipt.same-clock",
            family: .receipt,
            localRevision: 3,
            updatedAt: "2026-06-30T12:04:00Z",
            payloadClass: .receiptMetadata
        )
        let remote = try makeEnvelope(
            recordName: "receipt.same-clock",
            family: .receipt,
            localRevision: 3,
            updatedAt: "2026-06-30T12:04:00Z",
            payloadClass: .receiptMetadata,
            payloadValue: "remote-drift"
        )

        let merge = CausalMergeEngine().merge(
            CausalMergeCandidate(
                localEnvelope: local,
                remoteEnvelope: remote,
                localDeviceID: "same-device",
                remoteDeviceID: "same-device"
            ),
            createdAt: "2026-06-30T12:06:00Z"
        )
        let eligibility = SyncEligibilityDecision(
            id: "eligibility.same-clock",
            outcome: .eligibleForCloudKit,
            operation: .upsert,
            localWriteAllowed: true,
            cloudKitWriteAllowed: true,
            requiresUserConfirmation: false,
            localStoreRemainsAuthoritative: true,
            reasons: ["test"],
            evaluatedAt: "2026-06-30T12:07:00Z"
        )
        let conflict = ConflictPolicyEngine().decide(
            SyncConflictCandidate(
                mergeDecision: merge,
                eligibilityDecision: eligibility,
                userReviewed: false
            )
        )

        XCTAssertEqual(merge.outcome, .conflictReview)
        XCTAssertEqual(merge.review?.reviewState, .conflict)
        XCTAssertEqual(conflict.resolution, .quarantineForReview)
        XCTAssertTrue(conflict.quarantine)
        XCTAssertFalse(conflict.externalWriteAllowed)
        XCTAssertTrue(conflict.reasons.contains("same_clock_payload_drift"))
    }

    func testTombstoneSyncPropagatesOnlyNonLocalTombstoneMetadata() throws {
        let tombstone = EntityRevisionTombstone(
            entityKind: .goal,
            entityID: "goal.sync",
            revisionMarker: "rev-4",
            reason: .deleted,
            recordedAt: "2026-06-30T12:08:00Z",
            localOnly: false,
            privacyClass: .privateUserText,
            receiptID: "receipt.goal.sync",
            replayTraceID: "replay.goal.sync"
        )

        let envelope = try TombstoneSync().makeEnvelope(
            for: tombstone,
            localRevision: 4,
            updatedAt: "2026-06-30T12:09:00Z"
        )
        let decision = TombstoneSync().evaluate(envelope)

        XCTAssertEqual(envelope.reviewState, .tombstoned)
        XCTAssertEqual(envelope.payloadClass, .tombstoneMetadata)
        XCTAssertTrue(envelope.canEnterCloudKitContinuity)
        XCTAssertTrue(decision.shouldPropagate)
        XCTAssertFalse(decision.shouldQuarantine)
        XCTAssertTrue(decision.localStoreRemainsAuthoritative)
    }

    func testSignOutDeleteResetCoordinatorRetainsLocalDataAndRevokesRemoteAuthority() {
        let plan = SignOutDeleteResetCoordinator().plan(
            ContinuityCleanupRequest(
                event: .deleteAccount,
                pendingOutboxCount: 2,
                hasUnreviewedConflicts: true,
                requestedAt: "2026-06-30T12:10:00Z"
            )
        )

        XCTAssertTrue(plan.localDataRetained)
        XCTAssertTrue(plan.offlineCoreAvailableAfterCleanup)
        XCTAssertTrue(plan.remoteAuthorityRevoked)
        XCTAssertFalse(plan.privateGraphBackendAuthorityAllowed)
        XCTAssertTrue(plan.requiresUserConfirmation)
        XCTAssertTrue(plan.localStoreRemainsAuthoritative)
        XCTAssertTrue(plan.actions.contains(.tombstoneEligibleRemoteRecords))
        XCTAssertTrue(plan.actions.contains(.dropPendingExternalWrites))
        XCTAssertTrue(plan.actions.contains(.keepLocalStore))
    }

    func testCloudKitContinuityAdapterEvaluatesEligibilityWithoutPreparingZoneBeforeProof() async throws {
        let envelope = try makeEnvelope(
            recordName: "receipt.adapter",
            family: .receipt,
            payloadClass: .receiptMetadata
        )
        let adapter = CloudKitContinuityAdapter(
            client: StaticCloudKitContinuityClient(
                zoneSetupResult: CloudKitContinuityZoneSetupResult(
                    zoneName: CloudKitContinuityContainerConfiguration.production.coreZoneName,
                    outcome: .created,
                    detail: "created"
                )
            ),
            diagnosticsProvider: LocalOnlyCloudKitContinuityDiagnosticsProvider(
                featureFlagEnabled: true,
                accountStatusProbe: StaticCloudKitAccountStatusProbe(accountStatusValue: .available),
                proofVerified: false
            )
        )

        let decision = await adapter.evaluate(envelope, requestedAt: "2026-06-30T12:11:00Z")
        let zoneResult = await adapter.prepareCoreZoneIfEligible()

        XCTAssertEqual(decision.outcome, .queueForReview)
        XCTAssertFalse(decision.cloudKitWriteAllowed)
        XCTAssertNil(zoneResult)
    }
}

private extension ContinuityTests {
    struct TestPayload: Codable, Sendable, Equatable {
        let value: String
    }

    func makeEnvelope(
        recordName: String,
        family: CloudKitContinuityRecordFamily,
        localRevision: Int = 1,
        updatedAt: String = "2026-06-30T12:00:00Z",
        payloadClass: SyncEnvelopePayloadClass,
        includeRuntimeLineage: Bool = true,
        payloadValue: String? = nil
    ) throws -> CloudKitContinuityPortableRecordEnvelope {
        try CloudKitContinuityPortableRecordCodec.encode(
            TestPayload(value: payloadValue ?? "\(recordName).\(localRevision)"),
            family: family,
            recordName: recordName,
            schemaVersion: "continuity_test.v1",
            localRevision: localRevision,
            createdAt: "2026-06-30T12:00:00Z",
            updatedAt: updatedAt,
            receiptID: includeRuntimeLineage ? "receipt.\(recordName)" : nil,
            replayTraceID: includeRuntimeLineage ? "replay.\(recordName)" : nil,
            payloadClass: payloadClass
        )
    }

    func repoRoot() throws -> URL {
        var candidate = URL(fileURLWithPath: #filePath)
        while candidate.path != "/" {
            if FileManager.default.fileExists(atPath: candidate.appendingPathComponent("project.yml").path) {
                return candidate
            }
            candidate.deleteLastPathComponent()
        }
        throw NSError(domain: "ContinuityTests", code: 1)
    }
}
