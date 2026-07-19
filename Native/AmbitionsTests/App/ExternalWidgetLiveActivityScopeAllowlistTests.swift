import XCTest
@testable import Ambitions

final class ExternalWidgetLiveActivityScopeAllowlistTests: XCTestCase {
    func testAMB1809WidgetScopeAllowlistInventoriesSupportedFamiliesAndProjectionSurface() {
        let allowlist = ExternalSurfaceScopeAllowlist.nextStepWidget

        XCTAssertEqual(ExternalSurfaceScopeAllowlist.firstAllowedSnapshotSurfaceID, "next-step-widget")
        XCTAssertEqual(allowlist.widgetKind, "AmbitionsNextStepWidget")
        XCTAssertEqual(allowlist.contractKind, .widgets)
        XCTAssertEqual(allowlist.snapshotKind, SharedExternalSnapshotStore.snapshotKind)
        XCTAssertEqual(allowlist.projectionTypeName, "ExternalWidgetProjection")
        XCTAssertTrue(allowlist.consumesSharedSnapshotRecord)
        XCTAssertEqual(
            allowlist.supportedFamilyIdentifiers,
            [.systemSmall, .systemMedium, .systemLarge, .accessoryInline, .accessoryCircular, .accessoryRectangular]
        )
        XCTAssertEqual(
            allowlist.allowedVariantKinds,
            [.currentStep, .todayPressure, .protectedTime, .captureEntry, .recovery, .today, .focus, .goal, .timeShape]
        )
        XCTAssertTrue(allowlist.productionReadinessClaim.localizedCaseInsensitiveContains("not platform-ready"))
    }

    func testAMB1809LiveActivityInventoryStaysCandidateOnlyUntilDeviceLifecycleProofExists() {
        let candidates = ExternalSurfaceScopeAllowlist.liveActivityCandidates
        let candidate = candidates.first

        XCTAssertEqual(candidates.count, 1)
        XCTAssertEqual(candidate?.surfaceID, "next-step-live-activity")
        XCTAssertEqual(candidate?.widgetTypeName, "NextStepLiveActivityWidget")
        XCTAssertEqual(candidate?.attributesTypeName, "NextStepActivityAttributes")
        XCTAssertEqual(candidate?.contractKind, .liveActivities)
        XCTAssertEqual(candidate?.requiresConcreteStep, true)
        XCTAssertEqual(candidate?.requiresUserInitiatedActiveOperation, true)
        XCTAssertEqual(candidate?.hasBoundedEndTime, true)
        XCTAssertEqual(candidate?.isPlatformReady, false)
        XCTAssertTrue(candidate?.productionReadinessClaim.localizedCaseInsensitiveContains("not platform-ready") == true)
    }

    func testAMB1809FirstAllowedWidgetSurfaceConsumesProjectionSafeRedactedSnapshot() async throws {
        let runtimeStore = InMemoryRuntimeEventStore()
        _ = try await runtimeStore.append(commandEvent(
            id: "command-safe-widget",
            summary: "Safe capture update",
            privacy: .standard
        ))
        _ = try await runtimeStore.append(commandEvent(
            id: "command-private-widget",
            summary: "Private Therapy Session",
            privacy: .privateUserText
        ))
        let batch = try await ProjectionMaterializer(store: runtimeStore).materializeAll(
            materializedAt: "2026-07-05T12:00:00Z"
        )
        let snapshot = ExternalSurfaceSnapshotBuilder().makeSnapshot(
            widget: batch.widget,
            privacy: batch.privacy,
            now: Date(timeIntervalSince1970: 1_720_180_800)
        )
        let projection = ExternalWidgetProjection(snapshot: snapshot)
        let payloadJSON = try XCTUnwrap(String(data: PersistenceCoding.encode(snapshot), encoding: .utf8))
        let displayStrings = [
            projection.title,
            projection.detail,
            projection.lockDetail,
            projection.trustSummary,
            projection.privacySummary,
            projection.accessibilityLabel,
        ] + projection.variants.flatMap { [$0.title, $0.detail, $0.privacySummary, $0.actionTitle] }
        let displayText = displayStrings.joined(separator: " ")
        let allowedKinds = Set(ExternalSurfaceScopeAllowlist.nextStepWidget.allowedVariantKinds)

        XCTAssertEqual(ExternalSurfaceScopeAllowlist.firstAllowedSnapshotSurfaceID, ExternalSurfaceScopeAllowlist.nextStepWidget.surfaceID)
        XCTAssertEqual(snapshot.nowState?.blockerSummary.waitingCount, 1)
        XCTAssertTrue(Set(projection.variants.map(\.kind)).isSubset(of: allowedKinds))
        XCTAssertFalse(payloadJSON.contains("Private Therapy Session"))
        XCTAssertFalse(payloadJSON.contains("command-private-widget"))
        XCTAssertFalse(payloadJSON.contains("private_user_text"))
        XCTAssertFalse(displayText.contains("Private Therapy Session"))
        XCTAssertFalse(displayText.contains("command-private-widget"))
        XCTAssertFalse(displayText.contains("private_user_text"))
    }
}

private extension ExternalWidgetLiveActivityScopeAllowlistTests {
    func commandEvent(
        id: String,
        summary: String,
        privacy: EventLedgerPrivacyClassification
    ) -> RuntimeEvent {
        let command = AmbitionsCommand(
            id: id,
            kind: .quickCapture,
            source: .capture,
            target: AmbitionsCommandTarget(captureID: "capture-\(id)", destination: .captureInbox),
            payload: AmbitionsCommandPayload(rawText: summary),
            createdAt: "2026-07-05T12:00:00Z",
            privacy: privacy
        )
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: summary,
            route: .captureInbox,
            target: command.target,
            eventLedgerEntryIDs: ["ledger.\(id)"],
            metadata: ["objectID": "capture-\(id)"]
        )
        return RuntimeEvent.commandExecution(
            command: command,
            result: result,
            recordedAt: "2026-07-05T12:00:00Z",
            commandRecordID: "command.execution.\(id)"
        )
    }
}
