import XCTest
@testable import Ambitions

final class SyncCapabilityTests: XCTestCase {
    func testCloudKitContinuityFeatureFlagDefaultsOffAndLocalOnlyCapabilityStaysLocalOnly() async throws {
        let capability = LocalOnlySyncCapability()

        let status = await capability.status()

        XCTAssertFalse(CloudKitContinuityFeatureFlag.defaultEnabled)
        XCTAssertEqual(status.backendKind, .localOnly)
        XCTAssertEqual(status.trustPosture, .localOnly)
        XCTAssertEqual(status.availability, .unavailable)
        XCTAssertFalse(status.cloudKitContinuityEnabled)
        XCTAssertEqual(status.cloudKitAccountStatus, .unknown)
        XCTAssertEqual(status.sourceOfTruth, "local_device")
        XCTAssertTrue(status.localOnlyFallbackActive)
        XCTAssertFalse(status.localOperationBlocked)
        XCTAssertFalse(status.writesUserData)
        XCTAssertFalse(status.userDataCaptured)
        XCTAssertEqual(
            status.detail,
            "Ambitions is running in explicit local-only mode. CloudKit continuity stays off by default and local operation remains authoritative."
        )
        XCTAssertEqual(
            status.rollbackDetail,
            "Disable cloudKitContinuityEnabled to return to explicit local-only operation."
        )
    }

    func testMockedAccountStatesMapToSafeDiagnosticsWithoutBlockingLocalOperation() async throws {
        for accountStatus in CloudKitContinuityAccountStatus.allCases {
            let capability = LocalOnlySyncCapability(
                diagnosticsProvider: LocalOnlyCloudKitContinuityDiagnosticsProvider(
                    featureFlagEnabled: true,
                    accountStatusProbe: StaticCloudKitAccountStatusProbe(accountStatusValue: accountStatus)
                )
            )

            let status = await capability.status()

            XCTAssertEqual(status.backendKind, .localOnly)
            XCTAssertEqual(status.trustPosture, .localOnly)
            XCTAssertEqual(status.availability, .unavailable)
            XCTAssertEqual(status.cloudKitContinuityEnabled, true)
            XCTAssertEqual(status.cloudKitAccountStatus, accountStatus)
            XCTAssertEqual(status.sourceOfTruth, "local_device")
            XCTAssertTrue(status.localOnlyFallbackActive)
            XCTAssertFalse(status.localOperationBlocked)
            XCTAssertFalse(status.writesUserData)
            XCTAssertFalse(status.userDataCaptured)
            XCTAssertTrue(status.detail.contains("CloudKit continuity"))
            XCTAssertTrue(status.detail.contains("local operation remains authoritative"))
        }
    }

    func testRollbackToLocalOnlyPostureRemainsExplicitAndDoesNotImplyProductionSync() async throws {
        let capability = LocalOnlySyncCapability(
            diagnosticsProvider: LocalOnlyCloudKitContinuityDiagnosticsProvider(
                featureFlagEnabled: false,
                accountStatusProbe: StaticCloudKitAccountStatusProbe(accountStatusValue: .restricted)
            )
        )

        let status = await capability.status()

        XCTAssertEqual(status.cloudKitAccountStatus, .restricted)
        XCTAssertTrue(status.detail.contains("local-only mode"))
        XCTAssertTrue(status.rollbackDetail.contains("Disable cloudKitContinuityEnabled"))
        XCTAssertFalse(status.writesUserData)
        XCTAssertFalse(status.userDataCaptured)
        XCTAssertFalse(status.localOperationBlocked)
    }
}
