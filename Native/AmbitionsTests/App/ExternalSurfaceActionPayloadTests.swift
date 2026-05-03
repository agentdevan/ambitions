import XCTest
@testable import Ambitions

final class ExternalSurfaceActionPayloadTests: XCTestCase {
    func testCanonicalCommandPayloadPreservesLegacyKeysAndRedactsUserText() throws {
        let payload = ExternalSurfaceActionPayload.commandPayload(
            action: .complete,
            surface: .goalDetail,
            goalID: "goal-private-id",
            stepID: "step-private-id",
            tab: "goals"
        )

        XCTAssertEqual(payload["action"], "complete")
        XCTAssertEqual(payload["surface"], "goal-detail")
        XCTAssertEqual(payload["goalID"], "goal-private-id")
        XCTAssertEqual(payload["stepID"], "step-private-id")
        XCTAssertEqual(payload["tab"], "goals")

        let json = try XCTUnwrap(String(data: JSONEncoder().encode(payload), encoding: .utf8))
        XCTAssertFalse(json.contains("Private Therapy Goal"))
        XCTAssertFalse(json.contains("Call my therapist about the notes"))
        XCTAssertFalse(json.contains("capture text"))
    }

    func testCanonicalURLsUseStableRoutesOnly() throws {
        let goalURL = try XCTUnwrap(ExternalSurfaceActionPayload.deepLinkURL(surface: .goalDetail, goalID: "goal-123"))
        let todayURL = try XCTUnwrap(ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: "today"))
        let capturesURL = try XCTUnwrap(ExternalSurfaceActionPayload.deepLinkURL(surface: .captureInbox))
        let widgetURL = try XCTUnwrap(ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: "today", origin: .widget))
        let fallbackURL = try XCTUnwrap(ExternalSurfaceActionPayload.safeDeepLinkURL(surface: .goalDetail, goalID: nil, origin: .widget))

        XCTAssertEqual(goalURL.absoluteString, "ambitions://goal/goal-123")
        XCTAssertEqual(todayURL.absoluteString, "ambitions://tab/today")
        XCTAssertEqual(capturesURL.absoluteString, "ambitions://captures/inbox")
        XCTAssertEqual(widgetURL.absoluteString, "ambitions://tab/today?origin=widget")
        XCTAssertEqual(fallbackURL.absoluteString, "ambitions://tab/today?origin=widget")
        XCTAssertFalse(goalURL.absoluteString.contains("Private"))
    }

    func testD22ExternalSurfaceContractsCoverCanonSurfaces() {
        let contracts = ExternalSurfaceContractRegistry.contracts

        XCTAssertEqual(Set(contracts.map(\.kind)), Set(ExternalSurfaceKind.allCases))
        XCTAssertEqual(contracts.count, ExternalSurfaceKind.allCases.count)

        for contract in contracts {
            XCTAssertFalse(contract.allowedContent.isEmpty, "\(contract.kind) must name allowed content.")
            XCTAssertFalse(contract.forbiddenContent.isEmpty, "\(contract.kind) must name forbidden content.")
            XCTAssertTrue(contract.hidesSensitiveDetailsByDefault, "\(contract.kind) must hide sensitive details by default.")
            XCTAssertFalse(contract.allowedActions.isEmpty, "\(contract.kind) must name allowed actions.")
            XCTAssertFalse(contract.snapshotRule.isEmpty)
            XCTAssertFalse(contract.degradedStateLabel.isEmpty)
            XCTAssertFalse(contract.accessibilityRequirement.isEmpty)
        }
    }

    func testD22ContractsGateCommandsReceiptsAndSensitiveEffects() {
        let mutatingKinds: Set<ExternalSurfaceKind> = [.notifications, .widgets, .liveActivities, .appIntents, .shortcuts]

        for kind in mutatingKinds {
            let contract = ExternalSurfaceContractRegistry.contract(for: kind)

            XCTAssertTrue(contract.requiresSharedCommandPipeline, "\(kind) must use the shared command pipeline.")
            XCTAssertTrue(contract.requiresReceiptForMutation, "\(kind) must require receipts for mutations.")
            XCTAssertTrue(contract.requiresConfirmationForSensitiveExternalDestructiveEffects, "\(kind) must gate sensitive/external/destructive effects.")
        }

        let focusFilters = ExternalSurfaceContractRegistry.contract(for: .focusFilters)
        XCTAssertFalse(focusFilters.requiresSharedCommandPipeline)
        XCTAssertFalse(focusFilters.requiresReceiptForMutation)
        XCTAssertTrue(focusFilters.requiresConfirmationForSensitiveExternalDestructiveEffects)
    }

    func testGlanceStatePrefersNowStateAndFallsBackToOldNextActionSnapshots() throws {
        let oldNextAction = ExternalSurfaceNextAction(
            goalID: "goal-old",
            stepID: "step-old",
            display: ExternalSurfaceDisplayMetadata(
                templateKey: "next_tiny_step",
                goalMode: .project,
                stepState: .planned,
                urgency: .normal,
                timing: .deadline
            )
        )
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T12:00:00Z",
            nextAction: oldNextAction,
            nowState: ExternalSurfaceNowState(
                todayPosture: .waiting,
                pressureLevel: .elevated,
                bestNextStep: ExternalSurfaceActionReference(goalID: "goal-now", stepID: "step-now"),
                activeFocus: nil,
                openCaptureUrgency: .low,
                blockerSummary: ExternalSurfaceBlockerSummary(waitingCount: 1, blockedCount: 2),
                supportedCommands: [
                    ExternalSurfaceCommandDescriptor(kind: .openToday, requiresGoalID: false, requiresStepID: false),
                ]
            )
        )

        let glance = ExternalSurfaceGlanceState(snapshot: snapshot)

        XCTAssertEqual(glance.primaryReference?.goalID, "goal-now")
        XCTAssertEqual(glance.primaryReference?.stepID, "step-now")
        XCTAssertEqual(glance.todayPosture, .waiting)
        XCTAssertEqual(glance.pressureLevel, .elevated)
        XCTAssertEqual(glance.openCaptureUrgency, .low)
        XCTAssertEqual(glance.continuity.syncHealth.label, "Local-first and stable")

        let legacy = ExternalSurfaceGlanceState(
            snapshot: ExternalSurfaceSnapshot(
                generatedAt: "2026-04-15T12:00:00Z",
                nextAction: oldNextAction
            )
        )

        XCTAssertEqual(legacy.primaryReference?.goalID, "goal-old")
        XCTAssertEqual(legacy.primaryReference?.stepID, "step-old")
        XCTAssertEqual(legacy.todayPosture, .active)
        XCTAssertEqual(legacy.pressureLevel, .steady)
    }

    func testGlanceStatePreservesActiveFocusPriorityOverBestNextStep() throws {
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T12:00:00Z",
            nextAction: nil,
            nowState: ExternalSurfaceNowState(
                todayPosture: .active,
                pressureLevel: .steady,
                bestNextStep: ExternalSurfaceActionReference(goalID: "goal-best", stepID: "step-best"),
                activeFocus: ExternalSurfaceActionReference(goalID: "goal-focus", stepID: "step-focus"),
                openCaptureUrgency: .none,
                blockerSummary: ExternalSurfaceBlockerSummary(waitingCount: 0, blockedCount: 0),
                supportedCommands: [
                    ExternalSurfaceCommandDescriptor(kind: .openToday, requiresGoalID: false, requiresStepID: false),
                ]
            )
        )

        let glance = ExternalSurfaceGlanceState(snapshot: snapshot)

        XCTAssertEqual(glance.primaryReference?.goalID, "goal-focus")
        XCTAssertEqual(glance.primaryReference?.stepID, "step-focus")
    }

    func testGlanceStateUsesCalmUnavailableLanguageWhenSnapshotIsMissing() throws {
        let glance = ExternalSurfaceGlanceState(snapshot: nil)

        XCTAssertEqual(glance.continuity.lease.status, .unavailable)
        XCTAssertEqual(glance.continuity.lease.freshnessLabel, "Open Ambitions to refresh")
        XCTAssertEqual(glance.continuity.syncHealth.state, .unavailable)
        XCTAssertEqual(glance.continuity.syncHealth.label, "This surface may be behind")
        XCTAssertEqual(glance.continuity.syncHealth.detail, "Local app truth is available when Ambitions opens")
        XCTAssertEqual(glance.primaryURL?.absoluteString, "ambitions://tab/today?origin=widget")
    }
}
