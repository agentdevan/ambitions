@testable import Ambitions
import Foundation
import XCTest

final class CorePermissionsCanonicalOwnershipTests: XCTestCase {
    func testCanonicalPermissionOwnerFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/Permissions/PermissionState.swift",
            "Native/Ambitions/Core/Permissions/PermissionCoordinator.swift",
            "Native/Ambitions/Core/Permissions/CalendarPermission.swift",
            "Native/Ambitions/Core/Permissions/SpeechPermission.swift",
            "Native/Ambitions/Core/Permissions/NotificationPermission.swift",
            "Native/Ambitions/Core/Permissions/LocalAuthenticationPolicy.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical Core/Permissions owner: \(requiredPath)"
            )
        }
    }

    func testCoordinatorBuildsLocalFirstPermissionSnapshot() {
        let coordinator = PermissionCoordinator()

        let snapshot = coordinator.permissionSnapshot(
            calendarAuthorization: .fullAccess,
            remindersAuthorization: .denied,
            notificationAuthorization: .notDetermined,
            speechStatus: .unavailable,
            localAuthenticationAvailability: .available
        )

        XCTAssertEqual(snapshot.map(\.kind), [
            .calendarRead,
            .remindersWrite,
            .notifications,
            .speechRecognition,
            .localAuthentication,
        ])
        XCTAssertEqual(snapshot.first?.availability, .available)
        XCTAssertEqual(snapshot.first?.canRead, true)
        XCTAssertEqual(snapshot[1].fallbackSummary, "Ambitions keeps reminders inside the local runtime when Reminders access is unavailable.")
        XCTAssertEqual(snapshot[2].canRequest, true)
        XCTAssertTrue(snapshot[3].fallbackSummary.contains("typing"))
        XCTAssertTrue(snapshot[4].inspectionSummary.contains("off-device"))
    }

    func testCalendarPermissionPromptsOnlyFromContextualTimeActions() async {
        let store = PermissionRecordingEventKitStoreClient()
        await store.setAuthorization(.notDetermined, for: .calendarEvents)
        await store.setAuthorizationResponse(.fullAccess, for: .calendarEvents)
        let service = EventKitIntegrationService(storeClient: store)

        let blocked = await service.requestCalendarReadAccessFromTime(actionName: "")
        let firstRequestCount = await store.requestCount

        let requested = await service.requestCalendarReadAccessFromTime(actionName: "Find real open windows")
        let secondRequestCount = await store.requestCount

        XCTAssertEqual(blocked, .notDetermined)
        XCTAssertEqual(firstRequestCount, 0)
        XCTAssertEqual(requested, .readWrite)
        XCTAssertEqual(secondRequestCount, 1)
    }

    func testCalendarWritePermissionRequiresConfirmedBlock() async {
        let store = PermissionRecordingEventKitStoreClient()
        await store.setAuthorization(.notDetermined, for: .calendarEvents)
        await store.setWriteOnlyAuthorizationResponse(.writeOnly)
        let service = EventKitIntegrationService(storeClient: store)
        let now = Date(timeIntervalSince1970: 1_714_000_000)

        let unconfirmed = await service.requestCalendarWriteAccessForConfirmedBlock(
            intent: ScheduledBlockWriteIntent(
                id: "intent-unconfirmed",
                block: ScheduledAmbitionsBlock(
                    id: "block-unconfirmed",
                    title: "Draft proposal",
                    start: now.addingTimeInterval(3_600),
                    end: now.addingTimeInterval(5_400),
                    isUserConfirmed: false
                ),
                requestedAt: now
            )
        )
        let firstWriteRequestCount = await store.writeOnlyRequestCount

        let confirmed = await service.requestCalendarWriteAccessForConfirmedBlock(
            intent: ScheduledBlockWriteIntent(
                id: "intent-confirmed",
                block: ScheduledAmbitionsBlock(
                    id: "block-confirmed",
                    title: "Draft proposal",
                    start: now.addingTimeInterval(3_600),
                    end: now.addingTimeInterval(5_400),
                    isUserConfirmed: true
                ),
                requestedAt: now
            )
        )
        let secondWriteRequestCount = await store.writeOnlyRequestCount

        XCTAssertEqual(unconfirmed, .notDetermined)
        XCTAssertEqual(firstWriteRequestCount, 0)
        XCTAssertEqual(confirmed, .writeOnly)
        XCTAssertEqual(secondWriteRequestCount, 1)
    }

    func testNotificationPermissionBlocksRepeatDeniedPrompt() {
        let decision = NotificationPermission().optInDecision(
            current: .denied,
            context: PermissionRequestContext(
                surface: .you,
                actionName: "Enable notifications"
            )
        )

        XCTAssertFalse(decision.shouldRequestSystemPermission)
        XCTAssertEqual(decision.state.availability, .denied)
        XCTAssertTrue(decision.state.fallbackSummary.contains("in-app reminders"))
    }

    func testNotificationPermissionRequestsOnlyWhenNotDeterminedAndUserInitiated() {
        let decision = NotificationPermission().optInDecision(
            current: .notDetermined,
            context: PermissionRequestContext(
                surface: .you,
                actionName: "Enable notifications"
            )
        )

        XCTAssertTrue(decision.shouldRequestSystemPermission)
        XCTAssertEqual(decision.state.kind, .notifications)
        XCTAssertEqual(decision.state.canRequest, true)
    }
}

private extension CorePermissionsCanonicalOwnershipTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/Permissions")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

private actor PermissionRecordingEventKitStoreClient: EventKitStoreClient {
    private var authorizationByScope: [String: CalendarRemindersAuthorizationState] = [:]
    private var authorizationResponseByScope: [String: CalendarRemindersAuthorizationState] = [:]
    private var writeOnlyResponse: CalendarRemindersAuthorizationState = .denied
    private(set) var requestCount = 0
    private(set) var writeOnlyRequestCount = 0

    func authorizationState(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        authorizationByScope[key(for: scope)] ?? .notDetermined
    }

    func requestAuthorization(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        requestCount += 1
        let response = authorizationResponseByScope[key(for: scope)] ?? .denied
        authorizationByScope[key(for: scope)] = response
        return response
    }

    func requestWriteOnlyAuthorizationForEvents() async -> CalendarRemindersAuthorizationState {
        writeOnlyRequestCount += 1
        authorizationByScope[key(for: .calendarEvents)] = writeOnlyResponse
        return writeOnlyResponse
    }

    func saveReminder(_ payload: EventKitReminderPayload) async throws -> String {
        _ = payload
        return "reminder"
    }

    func saveEvent(_ payload: EventKitEventPayload) async throws -> String {
        _ = payload
        return "event"
    }

    func fetchEvents(in interval: DateInterval) async -> [EventKitCalendarEventSnapshot] {
        _ = interval
        return []
    }

    func setAuthorization(_ state: CalendarRemindersAuthorizationState, for scope: CalendarRemindersScope) {
        authorizationByScope[key(for: scope)] = state
    }

    func setAuthorizationResponse(_ state: CalendarRemindersAuthorizationState, for scope: CalendarRemindersScope) {
        authorizationResponseByScope[key(for: scope)] = state
    }

    func setWriteOnlyAuthorizationResponse(_ state: CalendarRemindersAuthorizationState) {
        writeOnlyResponse = state
    }

    private func key(for scope: CalendarRemindersScope) -> String {
        switch scope {
        case .reminders:
            return "reminders"
        case .calendarEvents:
            return "calendarEvents"
        }
    }
}
