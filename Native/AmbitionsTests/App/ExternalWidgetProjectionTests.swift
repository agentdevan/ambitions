import XCTest
@testable import Ambitions

final class ExternalWidgetProjectionTests: XCTestCase {
    func testD23WidgetProjectionConsumesContractAndHidesPrivateDetails() throws {
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T12:00:00Z",
            nextAction: ExternalSurfaceNextAction(
                goalID: "private-goal-id",
                stepID: "private-step-id",
                display: ExternalSurfaceDisplayMetadata(
                    templateKey: "next_tiny_step",
                    goalMode: .project,
                    stepState: .planned,
                    urgency: .soon,
                    timing: .deadline
                )
            ),
            nowState: ExternalSurfaceNowState(
                todayPosture: .active,
                pressureLevel: .steady,
                bestNextStep: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                activeFocus: nil,
                openCaptureUrgency: .none,
                blockerSummary: ExternalSurfaceBlockerSummary(waitingCount: 0, blockedCount: 0),
                supportedCommands: [
                    ExternalSurfaceCommandDescriptor(kind: .openToday, requiresGoalID: false, requiresStepID: false),
                    ExternalSurfaceCommandDescriptor(kind: .complete, requiresGoalID: true, requiresStepID: true),
                ]
            ),
            ambientState: ExternalSurfaceAmbientState(
                today: ExternalSurfaceVariantState(
                    kind: .today,
                    title: "Today has a next move",
                    detail: "Your next move still looks doable.",
                    privacySummary: "Glance-safe next move only",
                    action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .standard
                ),
                focus: ExternalSurfaceVariantState(
                    kind: .focus,
                    title: "Focus time ready",
                    detail: "A small focus step is available.",
                    privacySummary: "Details stay inside Ambitions",
                    action: ExternalSurfaceVariantAction(title: "Open Focus", surface: .tab, tab: "today"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .elevated
                ),
                goal: ExternalSurfaceVariantState(
                    kind: .goal,
                    title: "1 active goal",
                    detail: "Progress comes from your local plan.",
                    privacySummary: "Goal names stay private here",
                    action: ExternalSurfaceVariantAction(title: "Open Goals", surface: .tab, tab: "goals"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .quiet
                ),
                plan: ExternalSurfaceVariantState(
                    kind: .plan,
                    title: "Week looks doable",
                    detail: "Open Plan to adjust the week from your latest local state.",
                    privacySummary: "Plan detail opens in app",
                    action: ExternalSurfaceVariantAction(title: "Open Plan", surface: .tab, tab: "plan"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .standard
                )
            )
        )

        let projection = ExternalWidgetProjection(snapshot: snapshot)

        XCTAssertEqual(ExternalSurfaceContractRegistry.contract(for: .widgets).privacyDefault, .detailsHidden)
        XCTAssertEqual(projection.title, "Today has a next move")
        XCTAssertEqual(projection.detail, "Your next move still looks doable.")
        XCTAssertEqual(projection.privacySummary, "Details stay private until you open Ambitions.")
        XCTAssertEqual(projection.primaryURL?.absoluteString, "ambitions://goal/private-goal-id?origin=widget")
        XCTAssertEqual(projection.variants.map(\.kind), [.focus, .today, .plan, .goal])
        XCTAssertFalse(projection.accessibilityLabel.contains("Private Therapy Goal"))
        XCTAssertFalse(projection.accessibilityLabel.contains("private-step-id"))
    }

    func testD23WidgetProjectionUsesSafeFallbackForMissingSnapshot() {
        let projection = ExternalWidgetProjection(snapshot: nil)

        XCTAssertEqual(projection.title, "No next step")
        XCTAssertEqual(projection.detail, "Open Ambitions to refresh your plan.")
        XCTAssertEqual(projection.lockDetail, "Open Ambitions to confirm the latest local state.")
        XCTAssertEqual(projection.privacySummary, "Open Ambitions to confirm the latest local state.")
        XCTAssertEqual(projection.primaryURL?.absoluteString, "ambitions://tab/today?origin=widget")
        XCTAssertTrue(projection.variants.isEmpty)
    }

    func testD23WidgetProjectionSurfacesStaleStateWithoutSensitiveDetails() {
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T12:00:00Z",
            nextAction: nil,
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

        let projection = ExternalWidgetProjection(snapshot: snapshot)

        XCTAssertEqual(projection.lockDetail, "This may be behind. Open Ambitions to refresh.")
        XCTAssertEqual(projection.privacySummary, "This may be behind. Open Ambitions to refresh.")
        XCTAssertEqual(projection.trustSummary, "Local state may be behind · This may be behind")
        XCTAssertEqual(projection.primaryURL?.absoluteString, "ambitions://tab/today?origin=widget")
    }
}
