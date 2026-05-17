import XCTest
@testable import Ambitions

final class ExternalSurfaceVerificationChecklistTests: XCTestCase {
    func testM04ChecklistCoversEveryRequiredExternalSurfaceWithoutClaimingReadiness() {
        XCTAssertEqual(Set(ExternalSurfaceVerificationChecklist.records.map(\.surface)), [
            .notifications,
            .widgets,
            .liveActivities,
            .appIntents,
            .shortcuts,
            .sharedSnapshotContainer,
        ])

        for record in ExternalSurfaceVerificationChecklist.records {
            XCTAssertFalse(record.automatedEvidence.isEmpty, record.id)
            XCTAssertFalse(record.manualVerificationRequired.isEmpty, record.id)
            XCTAssertFalse(record.privacyRequirements.isEmpty, record.id)
            XCTAssertFalse(record.staleFailureRequirements.isEmpty, record.id)
            XCTAssertFalse(record.routingRequirements.isEmpty, record.id)
            XCTAssertFalse(record.receiptRequirements.isEmpty, record.id)
            XCTAssertTrue(record.requiresDeviceEvidenceBeforeReadinessClaim, record.id)
            XCTAssertTrue(record.readinessClaim.localizedCaseInsensitiveContains("not platform-ready"), record.id)
        }
    }

    func testM04ChecklistConsumesD22ContractsForPlatformSurfaces() throws {
        for record in ExternalSurfaceVerificationChecklist.records where record.contractKind != nil {
            let kind = try XCTUnwrap(record.contractKind)
            let contract = ExternalSurfaceContractRegistry.contract(for: kind)

            XCTAssertTrue(contract.hidesSensitiveDetailsByDefault, record.id)
            XCTAssertTrue(contract.requiresConfirmationForSensitiveExternalDestructiveEffects, record.id)
            XCTAssertFalse(contract.degradedStateLabel.isEmpty, record.id)
            XCTAssertFalse(record.privacyRequirements.isEmpty, record.id)
            XCTAssertFalse(record.staleFailureRequirements.isEmpty, record.id)

            if kind != .focusFilters {
                XCTAssertTrue(contract.requiresSharedCommandPipeline, record.id)
                XCTAssertTrue(contract.requiresReceiptForMutation, record.id)
            }
        }
    }

    func testM04SharedSnapshotContainerMatchesAppGroupAndDoesNotBecomeAReceiptStore() throws {
        let record = ExternalSurfaceVerificationChecklist.record(for: .sharedSnapshotContainer)

        XCTAssertNil(record.contractKind)
        XCTAssertEqual(SharedExternalSnapshotStore.appGroupIdentifier, "group.com.ambitions.shared")
        XCTAssertEqual(SharedExternalSnapshotStore.relativeDirectory, "ExternalSnapshots")
        XCTAssertEqual(SharedExternalSnapshotStore.fileName, "external-snapshot.v1.json")
        XCTAssertTrue(record.receiptRequirements.contains("Shared container does not create a separate mutation or receipt store"))
        XCTAssertTrue(record.privacyRequirements.contains("Store lightweight privacy-safe snapshots only"))

        let appEntitlements = try loadEntitlements(path: "Native/Ambitions/Support/Ambitions.entitlements")
        let widgetEntitlements = try loadEntitlements(path: "Native/AmbitionsWidgetExtension/AmbitionsWidgetExtension.entitlements")
        XCTAssertEqual(appEntitlements["com.apple.security.application-groups"] as? [String], [SharedExternalSnapshotStore.appGroupIdentifier])
        XCTAssertEqual(widgetEntitlements["com.apple.security.application-groups"] as? [String], [SharedExternalSnapshotStore.appGroupIdentifier])
    }

    func testM04ExistingProjectionsCarryStalePrivateAndFallbackBehavior() throws {
        let staleSnapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T11:00:00Z",
            nextAction: ExternalSurfaceNextAction(
                goalID: "goal-private",
                stepID: "step-private",
                display: ExternalSurfaceDisplayMetadata(
                    templateKey: "next_tiny_step",
                    goalMode: .project,
                    stepState: .planned,
                    urgency: .soon,
                    timing: .window
                )
            ),
            continuity: ExternalSurfaceContinuityState(
                lease: ExternalSurfaceNowStateLease(
                    status: .stale,
                    generatedAt: "2026-04-15T11:00:00Z",
                    freshnessLabel: "This may be behind",
                    staleActionLabel: "Open Ambitions to refresh"
                ),
                syncHealth: ExternalSurfaceSyncHealth(
                    state: .stale,
                    label: "Local state may be behind",
                    detail: "Open Ambitions before acting from this surface."
                ),
                receipt: ExternalSurfaceContinuityReceipt(origin: .widget, label: "Opened from widget")
            )
        )
        let widget = ExternalWidgetProjection(snapshot: staleSnapshot)
        let activity = try XCTUnwrap(
            NextStepActivityAttributes.ContentState(
                snapshot: staleSnapshot,
                now: try XCTUnwrap(ISO8601DateFormatter().date(from: "2026-04-15T12:00:00Z"))
            )
        )

        XCTAssertEqual(widget.privacySummary, ExternalSurfacePrivacySnapshotPolicy.safeDefault.staleLabel)
        XCTAssertEqual(widget.primaryURL?.absoluteString, "ambitions://goal/goal-private?origin=widget")
        XCTAssertEqual(activity.privacyLabel, ExternalSurfacePrivacySnapshotPolicy.safeDefault.staleLabel)
        XCTAssertEqual(activity.stateLabel, "Open Ambitions to refresh")

        let missingWidget = ExternalWidgetProjection(snapshot: nil)
        XCTAssertEqual(missingWidget.primaryURL?.absoluteString, "ambitions://tab/today?origin=widget")
        XCTAssertEqual(missingWidget.privacySummary, ExternalSurfacePrivacySnapshotPolicy.safeDefault.unavailableLabel)
    }
}

private extension ExternalSurfaceVerificationChecklistTests {
    func loadEntitlements(path: String) throws -> [String: Any] {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = root.appendingPathComponent(path)
        let data = try Data(contentsOf: url)
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        return try XCTUnwrap(plist as? [String: Any])
    }
}
