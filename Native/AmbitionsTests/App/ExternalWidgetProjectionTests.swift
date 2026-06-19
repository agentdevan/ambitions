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
                    title: "Today has a next step",
                    detail: "Your next step still looks doable.",
                    privacySummary: "Glance-safe next step only",
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
                    detail: "Progress comes from local proof.",
                    privacySummary: "Goal names stay private here",
                    action: ExternalSurfaceVariantAction(title: "Open Goals", surface: .tab, tab: "goals"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .quiet
                ),
                timeShape: ExternalSurfaceVariantState(
                    kind: .timeShape,
                    title: "Week looks doable",
                    detail: "Open Time to adjust the week from your latest local state.",
                    privacySummary: "Time detail opens in app",
                    action: ExternalSurfaceVariantAction(title: "Open Time", surface: .tab, tab: "time"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .standard
                ),
                currentStep: ExternalSurfaceVariantState(
                    kind: .currentStep,
                    title: "Recommended step ready",
                    detail: "A small focus step is available.",
                    privacySummary: "Step details stay inside Ambitions",
                    action: ExternalSurfaceVariantAction(title: "Open step", surface: .tab, tab: "today"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .elevated
                ),
                todayPressure: ExternalSurfaceVariantState(
                    kind: .todayPressure,
                    title: "Today is steady",
                    detail: "The current Time shape still looks believable.",
                    privacySummary: "Pressure uses local counts only",
                    action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .standard
                ),
                protectedTime: ExternalSurfaceVariantState(
                    kind: .protectedTime,
                    title: "Protected time is calm",
                    detail: "Open Time before adding more to the day.",
                    privacySummary: "Protected-time details open in app",
                    action: ExternalSurfaceVariantAction(title: "Open Time", surface: .tab, tab: "time"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .standard
                ),
                captureEntry: ExternalSurfaceVariantState(
                    kind: .captureEntry,
                    title: "Capture is clear",
                    detail: "Add a thought without exposing it here.",
                    privacySummary: "Capture text never appears here",
                    action: ExternalSurfaceVariantAction(title: "Open Capture", surface: .captureComposer, tab: nil),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .standard
                ),
                recovery: ExternalSurfaceVariantState(
                    kind: .recovery,
                    title: "Recovery stays available",
                    detail: "Close or adjust from the last honest point.",
                    privacySummary: "Recovery context opens in Today",
                    action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .quiet
                )
            )
        )

        let projection = ExternalWidgetProjection(snapshot: snapshot)

        XCTAssertEqual(ExternalSurfaceContractRegistry.contract(for: .widgets).privacyDefault, .detailsHidden)
        XCTAssertEqual(projection.title, "Today has a next step")
        XCTAssertEqual(projection.detail, "Your next step still looks doable.")
        XCTAssertEqual(projection.privacySummary, "Details stay private until you open Ambitions.")
        XCTAssertEqual(projection.primaryURL?.absoluteString, "ambitions://goal/private-goal-id?origin=widget")
        XCTAssertEqual(
            projection.variants.map(\.kind.rawValue).sorted(),
            ["capture_entry", "current_step", "focus", "goal", "protected_time", "recovery", "time_shape", "today", "today_pressure"]
        )
        XCTAssertTrue(projection.variants.contains { $0.kind == .currentStep && $0.actionTitle == "Open step" })
        XCTAssertTrue(projection.variants.contains { $0.kind == .captureEntry && $0.privacySummary == "Capture text never appears here" })
        XCTAssertTrue(projection.variants.contains { $0.kind == .protectedTime && $0.detail == "Open Time before adding more to the day." })
        XCTAssertFalse(projection.accessibilityLabel.contains("Private Therapy Goal"))
        XCTAssertFalse(projection.accessibilityLabel.contains("private-step-id"))
        XCTAssertFalse(projection.privacySummary.localizedCaseInsensitiveContains("travel radius"))
        XCTAssertFalse(projection.privacySummary.localizedCaseInsensitiveContains("injury"))
    }

    func testFocusNowWidgetProjectionPreservesActiveFocusPrimaryReference() throws {
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

        let projection = ExternalWidgetProjection(snapshot: snapshot)

        XCTAssertEqual(projection.primaryURL?.absoluteString, "ambitions://goal/goal-focus?origin=widget")
        XCTAssertEqual(projection.title, "Next step ready")
        XCTAssertEqual(projection.privacySummary, "Details stay private until you open Ambitions.")
    }

    func testD23WidgetProjectionUsesSafeFallbackForMissingSnapshot() {
        let projection = ExternalWidgetProjection(snapshot: nil)

        XCTAssertEqual(projection.title, "Open Ambitions")
        XCTAssertEqual(projection.detail, "Confirm the latest local state in Ambitions.")
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

        XCTAssertEqual(projection.title, "Open Ambitions to refresh")
        XCTAssertEqual(projection.detail, "This may be behind.")
        XCTAssertEqual(projection.lockDetail, "This may be behind. Open Ambitions to refresh.")
        XCTAssertEqual(projection.privacySummary, "This may be behind. Open Ambitions to refresh.")
        XCTAssertEqual(projection.trustSummary, "Local state may be behind · This may be behind")
        XCTAssertEqual(projection.primaryURL?.absoluteString, "ambitions://tab/today?origin=widget")
        XCTAssertFalse(projection.accessibilityLabel.localizedCaseInsensitiveContains("travel radius"))
        XCTAssertFalse(projection.accessibilityLabel.localizedCaseInsensitiveContains("injury"))
    }

    func testPFC14WidgetProjectionSuppressesAmbientRowsWhenSnapshotIsStale() {
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
            ambientState: ExternalSurfaceAmbientState(
                today: ExternalSurfaceVariantState(
                    kind: .today,
                    title: "Private medical task",
                    detail: "Call the clinic",
                    privacySummary: "Sensitive detail",
                    action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .elevated
                ),
                focus: ExternalSurfaceVariantState(
                    kind: .focus,
                    title: "Private focus",
                    detail: "Sensitive focus",
                    privacySummary: "Sensitive detail",
                    action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .standard
                ),
                goal: ExternalSurfaceVariantState(
                    kind: .goal,
                    title: "Private goal",
                    detail: "Sensitive goal",
                    privacySummary: "Sensitive detail",
                    action: ExternalSurfaceVariantAction(title: "Open Goals", surface: .tab, tab: "goals"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .standard
                ),
                timeShape: ExternalSurfaceVariantState(
                    kind: .timeShape,
                    title: "Private Time shape",
                    detail: "Sensitive Time shape",
                    privacySummary: "Sensitive detail",
                    action: ExternalSurfaceVariantAction(title: "Open Time", surface: .tab, tab: "time"),
                    reference: ExternalSurfaceActionReference(goalID: "private-goal-id", stepID: "private-step-id"),
                    prominence: .standard
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

        let projection = ExternalWidgetProjection(snapshot: snapshot)

        XCTAssertEqual(projection.title, "Open Ambitions to refresh")
        XCTAssertEqual(projection.detail, "This may be behind.")
        XCTAssertTrue(projection.variants.isEmpty)
        XCTAssertFalse(projection.accessibilityLabel.contains("Private medical task"))
        XCTAssertFalse(projection.accessibilityLabel.contains("private-goal-id"))
    }
}
