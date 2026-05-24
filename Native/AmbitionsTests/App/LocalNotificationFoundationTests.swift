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
        XCTAssertEqual(categories.first?.actions.last?.title, "Close the loop")
        XCTAssertEqual(categories.first?.actions.last?.opensApp, true)
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
        XCTAssertEqual(request?.title, "Next step ready")
        XCTAssertEqual(request?.body, "Details stay private until you open Ambitions.")
        XCTAssertEqual(request?.userInfo["origin"], "notification")
        XCTAssertEqual(request?.userInfo["continuity"], "local_first")
        XCTAssertEqual(request?.userInfo["lease"], "current")
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
        XCTAssertEqual(request?.body, "A smaller next step is ready. Details stay private until you open Ambitions.")
        XCTAssertEqual(request?.userInfo["action"], "open")
        XCTAssertEqual(request?.userInfo["surface"], "goal-detail")
        XCTAssertEqual(request?.userInfo["goalID"], "goal-123")
        XCTAssertEqual(request?.userInfo["stepID"], "step-456")
    }

    func testPFC20NotificationCopyDoesNotExposeAmbientFocusDetails() async {
        let center = RecordingNotificationCenterClient()
        await center.setAuthorizationState(.authorized)
        let snapshot = ExternalSurfaceSnapshot(
            generatedAt: "2026-04-15T13:00:00Z",
            nextAction: ExternalSurfaceNextAction(
                goalID: "goal-private",
                stepID: "step-private",
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
                    title: "Private tax appointment",
                    detail: "Call advisor with account number",
                    privacySummary: "Sensitive detail",
                    action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                    reference: ExternalSurfaceActionReference(goalID: "goal-private", stepID: "step-private"),
                    prominence: .elevated
                ),
                focus: ExternalSurfaceVariantState(
                    kind: .focus,
                    title: "Private tax appointment",
                    detail: "Call advisor with account number",
                    privacySummary: "Sensitive detail",
                    action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                    reference: ExternalSurfaceActionReference(goalID: "goal-private", stepID: "step-private"),
                    prominence: .elevated
                ),
                goal: ExternalSurfaceVariantState(
                    kind: .goal,
                    title: "Private goal",
                    detail: "Sensitive goal",
                    privacySummary: "Sensitive detail",
                    action: ExternalSurfaceVariantAction(title: "Open Goals", surface: .tab, tab: "goals"),
                    reference: ExternalSurfaceActionReference(goalID: "goal-private", stepID: "step-private"),
                    prominence: .standard
                ),
                plan: ExternalSurfaceVariantState(
                    kind: .plan,
                    title: "Private plan",
                    detail: "Sensitive plan",
                    privacySummary: "Sensitive detail",
                    action: ExternalSurfaceVariantAction(title: "Open Time", surface: .tab, tab: "time"),
                    reference: ExternalSurfaceActionReference(goalID: "goal-private", stepID: "step-private"),
                    prominence: .standard
                )
            )
        )
        let foundation = LocalNotificationFoundation(
            centerClient: center,
            snapshotReader: StaticSnapshotReader(snapshot: snapshot)
        )

        await foundation.refreshSchedule(now: Date(timeIntervalSince1970: 1_712_779_200))

        let request = await center.replacedRequest
        XCTAssertEqual(request?.title, "Next step ready")
        XCTAssertEqual(request?.body, "Details stay private until you open Ambitions.")
        XCTAssertFalse(request?.title.contains("tax") == true)
        XCTAssertFalse(request?.body.contains("advisor") == true)
        XCTAssertFalse(request?.body.contains("account") == true)
    }

    func testAuthorizedRefreshRecordsScheduledNotificationInSideEffectLedger() async {
        let center = RecordingNotificationCenterClient()
        await center.setAuthorizationState(.authorized)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
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
        let scheduleDate = Date(timeIntervalSince1970: 1_712_779_200)
        let now = DomainTimestamp.string(from: scheduleDate)
        let foundation = LocalNotificationFoundation(
            centerClient: center,
            snapshotReader: StaticSnapshotReader(snapshot: snapshot),
            sideEffectLedger: sideEffectLedger
        )

        await foundation.refreshSchedule(now: scheduleDate)

        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(record?.id, "notification.scheduled.1712779200")
        XCTAssertEqual(record?.effectKind, .notification)
        XCTAssertEqual(record?.status, .recordedLocalOnly)
        XCTAssertEqual(record?.boundary, .localOnly)
        XCTAssertEqual(record?.sourceDomain, .system)
        XCTAssertEqual(record?.occurredAt, now)
    }

    func testDeniedAuthorizationRefreshRecordsBlockedNotificationOutcome() async {
        let center = RecordingNotificationCenterClient()
        await center.setAuthorizationState(.denied)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let foundation = LocalNotificationFoundation(
            centerClient: center,
            snapshotReader: StaticSnapshotReader(snapshot: nil),
            sideEffectLedger: sideEffectLedger
        )

        await foundation.refreshSchedule(now: Date(timeIntervalSince1970: 1_712_779_200))

        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(record?.id, "notification.authorizationMissing.1712779200")
        XCTAssertEqual(record?.status, .blocked)
        XCTAssertEqual(record?.requiresConfirmation, true)
        XCTAssertEqual(record?.blockedFacts, ["Notification authorization is required to refresh local reminders."])
    }

    func testSnapshotLoadFailureRefreshRecordsFailedNotificationOutcome() async {
        let center = RecordingNotificationCenterClient()
        await center.setAuthorizationState(.authorized)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let foundation = LocalNotificationFoundation(
            centerClient: center,
            snapshotReader: ThrowingSnapshotReader(),
            sideEffectLedger: sideEffectLedger
        )
        let scheduleDate = Date(timeIntervalSince1970: 1_712_779_200)
        let now = DomainTimestamp.string(from: scheduleDate)

        await foundation.refreshSchedule(now: scheduleDate)

        let request = await center.replacedRequest
        XCTAssertNil(request)
        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(record?.id, "notification.refreshFailed.1712779200")
        XCTAssertEqual(record?.status, .failedSafely)
        XCTAssertEqual(record?.degradedFacts, ["Notification snapshot could not be loaded; no schedule refresh was applied."])
        XCTAssertEqual(record?.occurredAt, now)
    }

    func testNoNextActionRecordsNotificationCleared() async {
        let center = RecordingNotificationCenterClient()
        await center.setAuthorizationState(.authorized)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let foundation = LocalNotificationFoundation(
            centerClient: center,
            snapshotReader: StaticSnapshotReader(snapshot: ExternalSurfaceSnapshot(generatedAt: "2026-04-15T12:00:00Z", nextAction: nil)),
            sideEffectLedger: sideEffectLedger
        )
        let scheduleDate = Date(timeIntervalSince1970: 1_712_779_200)
        let now = DomainTimestamp.string(from: scheduleDate)

        await foundation.refreshSchedule(now: scheduleDate)

        let replacedRequest = await center.replacedRequest
        XCTAssertNil(replacedRequest)
        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(record?.id, "notification.cleared.1712779200")
        XCTAssertEqual(record?.status, .recordedLocalOnly)
        XCTAssertEqual(record?.occurredAt, now)
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

private struct ThrowingSnapshotReader: ExternalSurfaceSnapshotReading {
    struct SnapshotLoadError: Error {}

    func loadSnapshot() async throws -> ExternalSurfaceSnapshot? {
        throw SnapshotLoadError()
    }
}

private actor RecordingSideEffectLedgerRepository: SideEffectLedgerRepository {
    private(set) var records: [SideEffectLedgerRecord] = []

    var lastRecord: SideEffectLedgerRecord? {
        records.first
    }

    func append(_ record: SideEffectLedgerRecord) async throws {
        records.removeAll { $0.id == record.id }
        records.append(record)
    }

    func fetchRecent(limit: Int) async throws -> [SideEffectLedgerRecord] {
        Array(records.sorted(by: Self.sort).prefix(max(0, limit)))
    }

    func fetchRecords(status: SideEffectLedgerStatus) async throws -> [SideEffectLedgerRecord] {
        records.filter { $0.status == status }.sorted(by: Self.sort)
    }

    func fetchRecord(id: String) async throws -> SideEffectLedgerRecord? {
        records.first { $0.id == id }
    }

    private static func sort(_ lhs: SideEffectLedgerRecord, _ rhs: SideEffectLedgerRecord) -> Bool {
        if lhs.occurredAt != rhs.occurredAt {
            return lhs.occurredAt > rhs.occurredAt
        }
        return lhs.id < rhs.id
    }
}
