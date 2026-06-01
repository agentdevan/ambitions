import XCTest
@testable import Ambitions

final class CloudKitContinuityFoundationTests: XCTestCase {
    func testDefaultLocalOnlyDiagnosticsStayLocalOnlyAndUnready() async throws {
        let capability = LocalOnlySyncCapability()

        let status = await capability.status()

        XCTAssertEqual(status.syncMode, .localOnly)
        XCTAssertEqual(status.syncState, .localOnlyUnavailable)
        XCTAssertFalse(status.proofVerified)
        XCTAssertFalse(status.userPausedSync)
        XCTAssertTrue(status.detail.contains("local operation remains authoritative"))
        XCTAssertTrue(status.rollbackDetail.contains("Disable cloudKitContinuityEnabled"))
    }

    func testDiagnosticsMapAccountStatesAndProofStatesWithoutBlockingLocalOperation() async throws {
        let pausedCapability = LocalOnlySyncCapability(
            diagnosticsProvider: LocalOnlyCloudKitContinuityDiagnosticsProvider(
                featureFlagEnabled: true,
                accountStatusProbe: StaticCloudKitAccountStatusProbe(accountStatusValue: .available),
                proofVerified: false,
                userPausedSync: true
            )
        )
        let pausedStatus = await pausedCapability.status()
        XCTAssertEqual(pausedStatus.syncState, .paused)
        XCTAssertTrue(pausedStatus.detail.contains("paused by the user"))

        let needsReviewCapability = LocalOnlySyncCapability(
            diagnosticsProvider: LocalOnlyCloudKitContinuityDiagnosticsProvider(
                featureFlagEnabled: true,
                accountStatusProbe: StaticCloudKitAccountStatusProbe(accountStatusValue: .available),
                proofVerified: false
            )
        )
        let needsReviewStatus = await needsReviewCapability.status()
        XCTAssertEqual(needsReviewStatus.syncState, .needsReview)
        XCTAssertTrue(needsReviewStatus.detail.contains("needs review"))

        let healthyCapability = LocalOnlySyncCapability(
            diagnosticsProvider: LocalOnlyCloudKitContinuityDiagnosticsProvider(
                featureFlagEnabled: true,
                accountStatusProbe: StaticCloudKitAccountStatusProbe(accountStatusValue: .available),
                proofVerified: true
            )
        )
        let healthyStatus = await healthyCapability.status()
        XCTAssertEqual(healthyStatus.syncState, .healthyAfterProof)
        XCTAssertTrue(healthyStatus.detail.contains("proof-backed readiness"))

        let unavailableStates: [(CloudKitContinuityAccountStatus, CloudKitContinuitySyncState)] = [
            (.noAccount, .accountUnavailable),
            (.restricted, .restricted),
            (.temporarilyUnavailable, .temporarilyUnavailable),
            (.unknown, .needsReview)
        ]

        for (accountStatus, expectedState) in unavailableStates {
            let capability = LocalOnlySyncCapability(
                diagnosticsProvider: LocalOnlyCloudKitContinuityDiagnosticsProvider(
                    featureFlagEnabled: true,
                    accountStatusProbe: StaticCloudKitAccountStatusProbe(accountStatusValue: accountStatus)
                )
            )
            let status = await capability.status()
            XCTAssertEqual(status.syncState, expectedState)
            XCTAssertTrue(status.detail.contains("local operation remains authoritative"))
        }
    }

    func testPortableRecordCodecRoundTripsApprovedFamiliesAndPreservesTombstoneMetadata() throws {
        XCTAssertEqual(Set(CloudKitContinuityRecordFamily.approvedFamilies), Set(CloudKitContinuityRecordFamily.allCases))

        let tombstone = EntityRevisionTombstone(
            entityKind: .goal,
            entityID: "goal.1",
            revisionMarker: "rev-3",
            reason: .deleted,
            recordedAt: "2026-06-01T22:18:25Z",
            sourceRecordID: "SourceRecord.goal.1",
            receiptID: "Receipt.goal.1",
            replayTraceID: "ReplayTrace.goal.1"
        )
        let tombstoneEnvelope = try CloudKitContinuityPortableRecordCodec.encode(
            tombstone,
            family: .tombstone,
            recordName: tombstone.id,
            schemaVersion: tombstone.schemaVersion,
            localRevision: 3,
            createdAt: tombstone.recordedAt,
            updatedAt: tombstone.recordedAt,
            sourceRecordID: tombstone.sourceRecordID,
            receiptID: tombstone.receiptID,
            replayTraceID: tombstone.replayTraceID,
            tombstone: CloudKitContinuityTombstoneMetadata(
                entityKind: "goal",
                entityID: "goal.1",
                reason: "deleted",
                recordedAt: tombstone.recordedAt,
                localOnly: tombstone.localOnly
            )
        )
        let decodedTombstone = try CloudKitContinuityPortableRecordCodec.decode(
            tombstoneEnvelope,
            as: EntityRevisionTombstone.self,
            family: .tombstone
        )
        XCTAssertEqual(decodedTombstone, tombstone)
        XCTAssertEqual(tombstoneEnvelope.reviewState, .ready)
        XCTAssertEqual(tombstoneEnvelope.tombstone?.entityID, "goal.1")

        let preferences = AppStateSnapshot.default
        let preferenceEnvelope = try CloudKitContinuityPortableRecordCodec.encode(
            preferences,
            family: .preference,
            recordName: preferences.id,
            schemaVersion: "app_state_snapshot.cloudkit.v1",
            localRevision: 1,
            createdAt: "2026-06-01T22:18:25Z",
            updatedAt: "2026-06-01T22:18:25Z"
        )
        let decodedPreferences = try CloudKitContinuityPortableRecordCodec.decode(
            preferenceEnvelope,
            as: AppStateSnapshot.self,
            family: .preference
        )
        XCTAssertEqual(decodedPreferences, preferences)

        let ledger = CloudKitContinuitySyncLedgerSnapshot(
            deviceID: "device.local",
            schemaVersion: "sync_ledger.cloudkit.v1",
            lastProcessedRevision: 9,
            lastSyncedAt: nil,
            pendingRecordCount: 2,
            reviewRecordCount: 1,
            syncState: .needsReview
        )
        let ledgerEnvelope = try CloudKitContinuityPortableRecordCodec.encode(
            ledger,
            family: .syncLedger,
            recordName: "sync-ledger.local",
            schemaVersion: ledger.schemaVersion,
            localRevision: ledger.lastProcessedRevision,
            createdAt: "2026-06-01T22:18:25Z",
            updatedAt: "2026-06-01T22:18:25Z"
        )
        let decodedLedger = try CloudKitContinuityPortableRecordCodec.decode(
            ledgerEnvelope,
            as: CloudKitContinuitySyncLedgerSnapshot.self,
            family: .syncLedger
        )
        XCTAssertEqual(decodedLedger, ledger)
    }

    func testLocalFirstCoordinatorQueuesChangesWithoutBlockingLocalWrites() async throws {
        let outboxStore = InMemoryCloudKitContinuityOutboxStore()
        let diagnosticsProvider = LocalOnlyCloudKitContinuityDiagnosticsProvider(
            featureFlagEnabled: true,
            accountStatusProbe: StaticCloudKitAccountStatusProbe(accountStatusValue: .available),
            proofVerified: false
        )
        let coordinator = LocalFirstCloudKitContinuitySyncCoordinator(
            client: StaticCloudKitContinuityClient(
                zoneSetupResult: .init(
                    zoneName: CloudKitContinuityContainerConfiguration.production.coreZoneName,
                    outcome: .alreadyPresent,
                    detail: "Simulated zone setup."
                )
            ),
            diagnosticsProvider: diagnosticsProvider,
            outboxStore: outboxStore
        )

        let preferenceEnvelope = try CloudKitContinuityPortableRecordCodec.encode(
            AppStateSnapshot.default,
            family: .preference,
            recordName: "app_state.default",
            schemaVersion: "app_state_snapshot.cloudkit.v1",
            localRevision: 1,
            createdAt: "2026-06-01T22:18:25Z",
            updatedAt: "2026-06-01T22:18:25Z"
        )
        let outboxEntry = CloudKitContinuityOutboxEntry(
            id: "outbox.app_state.default",
            envelope: preferenceEnvelope,
            operation: .upsert,
            syncMode: .continuityEnabled,
            syncState: .needsReview,
            queuedAt: "2026-06-01T22:18:25Z",
            detail: "Queued locally while sync waits for proof."
        )

        await coordinator.recordLocalChange(outboxEntry)

        let pendingEntries = await coordinator.pendingEntries()
        XCTAssertEqual(pendingEntries, [outboxEntry])
        let diagnostics = await coordinator.currentDiagnostics()
        XCTAssertEqual(diagnostics.syncState, .needsReview)
        let currentZoneResult = await coordinator.prepareCoreZoneIfEligible()
        XCTAssertNil(currentZoneResult)

        let proofBackedCoordinator = LocalFirstCloudKitContinuitySyncCoordinator(
            client: StaticCloudKitContinuityClient(
                zoneSetupResult: .init(
                    zoneName: CloudKitContinuityContainerConfiguration.production.coreZoneName,
                    outcome: .alreadyPresent,
                    detail: "Simulated proof-backed zone setup."
                )
            ),
            diagnosticsProvider: LocalOnlyCloudKitContinuityDiagnosticsProvider(
                featureFlagEnabled: true,
                accountStatusProbe: StaticCloudKitAccountStatusProbe(accountStatusValue: .available),
                proofVerified: true
            ),
            outboxStore: InMemoryCloudKitContinuityOutboxStore()
        )

        let zoneResult = await proofBackedCoordinator.prepareCoreZoneIfEligible()
        XCTAssertEqual(zoneResult?.outcome, .alreadyPresent)
    }
}
