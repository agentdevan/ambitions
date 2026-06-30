import XCTest
@testable import Ambitions

final class SyncContinuityTests: XCTestCase {
    func testSyncContinuityOwnerFilesExistUnderCanonicalLocalRuntimeOSOwner() throws {
        let root = try repoRoot()
        let requiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/LocalAuthoritativeSyncModel.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/CloudKitContinuityAdapter.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncEligibilityPolicy.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SyncEnvelope.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/CausalMergeEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/ConflictPolicyEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/TombstoneSync.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/AccountStateMachine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/SyncContinuity/SignOutDeleteResetCoordinator.swift",
        ]
        let removedOldOwners = [
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
            CausalMergeCandidate(localEnvelope: local, remoteEnvelope: remote),
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
        XCTAssertTrue(plan.remoteAuthorityRevoked)
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

private extension SyncContinuityTests {
    struct TestPayload: Codable, Sendable, Equatable {
        let value: String
    }

    func makeEnvelope(
        recordName: String,
        family: CloudKitContinuityRecordFamily,
        localRevision: Int = 1,
        updatedAt: String = "2026-06-30T12:00:00Z",
        payloadClass: SyncEnvelopePayloadClass
    ) throws -> CloudKitContinuityPortableRecordEnvelope {
        try CloudKitContinuityPortableRecordCodec.encode(
            TestPayload(value: "\(recordName).\(localRevision)"),
            family: family,
            recordName: recordName,
            schemaVersion: "sync_continuity_test.v1",
            localRevision: localRevision,
            createdAt: "2026-06-30T12:00:00Z",
            updatedAt: updatedAt,
            receiptID: "receipt.\(recordName)",
            replayTraceID: "replay.\(recordName)",
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
        throw NSError(domain: "SyncContinuityTests", code: 1)
    }
}
