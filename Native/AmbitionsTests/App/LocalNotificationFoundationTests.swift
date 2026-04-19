import XCTest
@testable import Ambitions

final class LocalNotificationFoundationTests: XCTestCase {
    func testCategoryRegistrationRegistersOpenSnoozeCompleteActions() async {
        let center = RecordingNotificationCenterClient()
        let foundation = LocalNotificationFoundation(
            centerClient: center,
            snapshotReader: StaticSnapshotReader(snapshot: nil)
        )

        await foundation.registerCategories()

        let categories = await center.registeredCategories
        XCTAssertEqual(categories.count, 1)
        XCTAssertEqual(categories.first?.identifier, AppNotificationConstants.nextStepCategoryID)
        XCTAssertEqual(categories.first?.actions.map(\.identifier), [
            AppNotificationConstants.openActionID,
            AppNotificationConstants.snoozeActionID,
            AppNotificationConstants.completeActionID,
        ])
    }

    func testSchedulingBuildsDeterministicRequestFromNextActionSnapshot() async {
        let center = RecordingNotificationCenterClient()
        await center.setAuthorizationState(.authorized)
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T12:00:00Z",
            nextAction: ExternalSurfaceNextAction(
                goalID: "goal-123",
                stepID: "step-456",
                display: ExternalSurfaceDisplayMetadata(
                    templateKey: "next_tiny_step",
                    goalMode: .project,
                    stepState: .planned,
                    urgency: .soon,
                    timing: .deadline
                )
            )
        )
        let foundation = LocalNotificationFoundation(
            centerClient: center,
            snapshotReader: StaticSnapshotReader(snapshot: snapshot)
        )

        await foundation.refreshSchedule(now: Date(timeIntervalSince1970: 1_712_779_200))

        let request = await center.replacedRequest
        XCTAssertEqual(request?.identifier, AppNotificationConstants.nextStepRequestID)
        XCTAssertEqual(request?.categoryIdentifier, AppNotificationConstants.nextStepCategoryID)
        XCTAssertEqual(request?.userInfo["action"], "open")
        XCTAssertEqual(request?.userInfo["surface"], "goal-detail")
        XCTAssertEqual(request?.userInfo["tab"], "goals")
        XCTAssertEqual(request?.userInfo["goalID"], "goal-123")
        XCTAssertEqual(request?.userInfo["stepID"], "step-456")
        XCTAssertEqual(request?.timeInterval, 300)
        XCTAssertEqual(request?.title, "Ambitions reminder")
        XCTAssertEqual(request?.body, "Your next step is ready.")
    }

    func testSchedulingClearsPendingWhenNoNextActionExists() async {
        let center = RecordingNotificationCenterClient()
        await center.setAuthorizationState(.authorized)
        let foundation = LocalNotificationFoundation(
            centerClient: center,
            snapshotReader: StaticSnapshotReader(snapshot: ExternalSurfaceSnapshot(generatedAt: "2026-04-15T12:00:00Z", nextAction: nil))
        )

        await foundation.refreshSchedule(now: .now)

        let replacedRequest = await center.replacedRequest
        XCTAssertNil(replacedRequest)
    }

    func testSchedulingUsesGenericRitualCopyWithoutChangingPayload() async {
        let center = RecordingNotificationCenterClient()
        await center.setAuthorizationState(.authorized)
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T13:00:00Z",
            nextAction: ExternalSurfaceNextAction(
                goalID: "goal-123",
                stepID: "step-456",
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
                pressureLevel: .elevated,
                bestNextStep: ExternalSurfaceActionReference(goalID: "goal-123", stepID: "step-456"),
                activeFocus: nil,
                openCaptureUrgency: .none,
                blockerSummary: ExternalSurfaceBlockerSummary(waitingCount: 0, blockedCount: 0),
                ritualCue: ExternalSurfaceRitualCue(
                    kind: .middayReset,
                    templateKey: "ritual_midday_reset",
                    progressState: .needsReset,
                    primaryReference: ExternalSurfaceActionReference(goalID: "goal-123", stepID: "step-456")
                ),
                supportedCommands: []
            )
        )
        let foundation = LocalNotificationFoundation(
            centerClient: center,
            snapshotReader: StaticSnapshotReader(snapshot: snapshot)
        )

        await foundation.refreshSchedule(now: Date(timeIntervalSince1970: 1_712_779_200))

        let request = await center.replacedRequest
        XCTAssertEqual(request?.title, "Midday reset")
        XCTAssertEqual(request?.body, "A smaller next move is ready.")
        XCTAssertEqual(request?.userInfo["action"], "open")
        XCTAssertEqual(request?.userInfo["surface"], "goal-detail")
        XCTAssertEqual(request?.userInfo["goalID"], "goal-123")
        XCTAssertEqual(request?.userInfo["stepID"], "step-456")
    }
}

private actor RecordingNotificationCenterClient: LocalNotificationCenterClient {
    private(set) var authorizationState: NotificationAuthorizationState = .notDetermined
    private(set) var registeredCategories: [LocalNotificationCategoryDescriptor] = []
    private(set) var replacedRequest: LocalNotificationScheduleRequest?

    func currentAuthorizationState() async -> NotificationAuthorizationState {
        authorizationState
    }

    func requestAuthorization() async throws -> Bool {
        authorizationState = .authorized
        return true
    }

    func setCategories(_ categories: [LocalNotificationCategoryDescriptor]) async {
        registeredCategories = categories
    }

    func replacePendingRequest(_ request: LocalNotificationScheduleRequest?) async {
        replacedRequest = request
    }

    func setAuthorizationState(_ state: NotificationAuthorizationState) {
        authorizationState = state
    }
}

private struct StaticSnapshotReader: ExternalSurfaceSnapshotReading {
    let snapshot: ExternalSurfaceSnapshot?

    func loadSnapshot() async throws -> ExternalSurfaceSnapshot? {
        snapshot
    }
}
