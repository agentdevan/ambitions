import XCTest
@testable import Ambitions

final class EventKitIntegrationServiceTests: XCTestCase {
    func testCreateReminderFailsWhenAuthorizationDenied() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .denied, for: .reminders)
        let service = EventKitIntegrationService(storeClient: store)

        do {
            _ = try await service.createReminder(for: fixtureSelection(), now: fixtureNow())
            XCTFail("Expected denied authorization to throw.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .authorizationDenied(scope: .reminders))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateReminderRequestsAuthorizationAndSavesPayload() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .notDetermined, for: .reminders)
        await store.setAuthorizationResponse(state: .fullAccess, for: .reminders)
        let service = EventKitIntegrationService(storeClient: store)

        let record = try await service.createReminder(for: fixtureSelection(), now: fixtureNow())
        let payload = await store.lastReminderPayload

        XCTAssertEqual(record.identifier, "reminder-1")
        XCTAssertEqual(record.title, "Draft conference abstract")
        XCTAssertEqual(payload?.title, "Draft conference abstract")
        XCTAssertEqual(payload?.dueDate, fixtureSuggestedDate())
        XCTAssertTrue(payload?.notes.contains("Created by Ambitions after an explicit reminder request.") == true)
        XCTAssertTrue(payload?.notes.contains("Ambitions step ID: step-1") == true)
        XCTAssertFalse(payload?.notes.contains("Ship CFP proposal") == true)
        XCTAssertFalse(payload?.notes.contains("First concrete draft") == true)
    }

    func testDetectConflictsReturnsOverlappingEventsAndNearbyRoom() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let overlap = EventKitCalendarEventSnapshot(
            title: "Team standup",
            startDate: fixtureSuggestedDate().addingTimeInterval(-300),
            endDate: fixtureSuggestedDate().addingTimeInterval(1_200),
            isAllDay: false
        )
        let nonOverlap = EventKitCalendarEventSnapshot(
            title: "Evening run",
            startDate: fixtureSuggestedDate().addingTimeInterval(10_800),
            endDate: fixtureSuggestedDate().addingTimeInterval(11_400),
            isAllDay: false
        )
        await store.setEvents([overlap, nonOverlap])
        let service = EventKitIntegrationService(storeClient: store)

        let report = await service.detectConflicts(for: fixtureSelection(), durationMinutes: 45, now: fixtureNow())

        XCTAssertEqual(report?.conflicts.count, 1)
        XCTAssertEqual(report?.conflicts.first?.title, "Team standup")
        XCTAssertEqual(report?.pressure, .low)
        XCTAssertNotNil(report?.nearbyAvailableWindow)
    }

    func testDetectConflictsReturnsNilWithoutCalendarReadContext() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .writeOnly, for: .calendarEvents)
        await store.setEvents([
            EventKitCalendarEventSnapshot(
                title: "Team standup",
                startDate: fixtureSuggestedDate().addingTimeInterval(-300),
                endDate: fixtureSuggestedDate().addingTimeInterval(1_200),
                isAllDay: false
            )
        ])
        let service = EventKitIntegrationService(storeClient: store)

        let report = await service.detectConflicts(for: fixtureSelection(), durationMinutes: 45, now: fixtureNow())

        XCTAssertNil(report)
    }

    func testDetectConflictsDerivesHighPressureWhenDayIsPacked() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let start = fixtureSuggestedDate()
        await store.setEvents([
            EventKitCalendarEventSnapshot(title: "Block 1", startDate: start, endDate: start.addingTimeInterval(2 * 3_600), isAllDay: false),
            EventKitCalendarEventSnapshot(title: "Block 2", startDate: start.addingTimeInterval(2.25 * 3_600), endDate: start.addingTimeInterval(4.25 * 3_600), isAllDay: false),
            EventKitCalendarEventSnapshot(title: "Block 3", startDate: start.addingTimeInterval(4.5 * 3_600), endDate: start.addingTimeInterval(6.5 * 3_600), isAllDay: false)
        ])
        let service = EventKitIntegrationService(storeClient: store)

        let report = await service.detectConflicts(for: fixtureSelection(), durationMinutes: 45, now: fixtureNow())

        XCTAssertEqual(report?.pressure, .high)
    }

    func testCreateCalendarEventFailsWhenStepHasNoSuggestedDate() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let service = EventKitIntegrationService(storeClient: store, sideEffectLedger: sideEffectLedger)
        let selection = NextStepSchedulingSelection(
            goalID: "goal-1",
            goalTitle: "Ship CFP proposal",
            stepID: "step-1",
            stepTitle: "Draft conference abstract",
            stepSummary: "First concrete draft.",
            suggestedDate: nil
        )

        do {
            _ = try await service.createCalendarEvent(for: selection, durationMinutes: 45, now: fixtureNow())
            XCTFail("Expected missing date to throw.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .missingEventStartDate)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(record?.effectKind, .calendar)
        XCTAssertEqual(record?.status, .failedSafely)
        XCTAssertEqual(record?.boundary, .localOnly)
        XCTAssertEqual(record?.actionKind, .writeCalendarBlock)
        XCTAssertTrue(record?.degradedFacts.contains("Calendar event write request lacked a concrete time.") == true)
        XCTAssertFalse(record?.blockedFacts.contains("Draft conference abstract") == true)
    }

    func testCreateCalendarEventSuccessRecordsCalendarSideEffect() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let service = EventKitIntegrationService(storeClient: store, sideEffectLedger: sideEffectLedger)

        let record = try await service.createCalendarEvent(for: fixtureSelection(), durationMinutes: 45, now: fixtureNow())

        let sideEffect = await sideEffectLedger.lastRecord
        XCTAssertEqual(record.identifier, "event-1")
        XCTAssertEqual(sideEffect?.effectKind, .calendar)
        XCTAssertEqual(sideEffect?.status, .recordedLocalOnly)
        XCTAssertEqual(sideEffect?.boundary, .externalEffect)
        XCTAssertEqual(sideEffect?.actionKind, .writeCalendarBlock)
        XCTAssertEqual(sideEffect?.sourceDomain, .time)
        XCTAssertEqual(sideEffect?.requiresConfirmation, false)
        XCTAssertEqual(sideEffect?.externalEffect, true)
        XCTAssertTrue(sideEffect?.reasons.contains(.externalSideEffect) == true)
        XCTAssertFalse(sideEffect?.blockedFacts.contains("Draft conference abstract") == true)
    }

    func testRepeatedCalendarEventSuccessesRecordDistinctLedgerEntries() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let service = EventKitIntegrationService(storeClient: store, sideEffectLedger: sideEffectLedger)

        _ = try await service.createCalendarEvent(for: fixtureSelection(), durationMinutes: 45, now: fixtureNow())
        _ = try await service.createCalendarEvent(for: fixtureSelection(), durationMinutes: 45, now: fixtureNow())

        let records = await sideEffectLedger.records
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(Set(records.map(\.id)).count, 2)
        XCTAssertTrue(records.allSatisfy { $0.effectKind == .calendar })
        XCTAssertTrue(records.allSatisfy { $0.status == .recordedLocalOnly })
        XCTAssertTrue(records.allSatisfy { $0.externalEffect })
    }
}

private extension EventKitIntegrationServiceTests {
    func fixtureNow() -> Date {
        Date(timeIntervalSince1970: 1_713_180_000)
    }

    func fixtureSuggestedDate() -> Date {
        fixtureNow().addingTimeInterval(3_600)
    }

    func fixtureSelection() -> NextStepSchedulingSelection {
        NextStepSchedulingSelection(
            goalID: "goal-1",
            goalTitle: "Ship CFP proposal",
            stepID: "step-1",
            stepTitle: "Draft conference abstract",
            stepSummary: "First concrete draft.",
            suggestedDate: fixtureSuggestedDate()
        )
    }
}

private actor RecordingEventKitStoreClient: EventKitStoreClient {
    private var authorizationByScope: [String: CalendarRemindersAuthorizationState] = [:]
    private var authorizationResponseByScope: [String: CalendarRemindersAuthorizationState] = [:]
    private(set) var lastReminderPayload: EventKitReminderPayload?
    private(set) var lastEventPayload: EventKitEventPayload?
    private var events: [EventKitCalendarEventSnapshot] = []

    func authorizationState(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        authorizationByScope[key(for: scope)] ?? .notDetermined
    }

    func requestAuthorization(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        let response = authorizationResponseByScope[key(for: scope)] ?? .denied
        authorizationByScope[key(for: scope)] = response
        return response
    }

    func requestWriteOnlyAuthorizationForEvents() async -> CalendarRemindersAuthorizationState {
        let response = authorizationResponseByScope[key(for: .calendarEvents)] ?? .denied
        authorizationByScope[key(for: .calendarEvents)] = response
        return response
    }

    func saveReminder(_ payload: EventKitReminderPayload) async throws -> String {
        lastReminderPayload = payload
        return "reminder-1"
    }

    func saveEvent(_ payload: EventKitEventPayload) async throws -> String {
        lastEventPayload = payload
        return "event-1"
    }

    func fetchEvents(in interval: DateInterval) async -> [EventKitCalendarEventSnapshot] {
        events.filter { $0.startDate < interval.end && $0.endDate > interval.start }
    }

    func setAuthorization(state: CalendarRemindersAuthorizationState, for scope: CalendarRemindersScope) {
        authorizationByScope[key(for: scope)] = state
    }

    func setAuthorizationResponse(state: CalendarRemindersAuthorizationState, for scope: CalendarRemindersScope) {
        authorizationResponseByScope[key(for: scope)] = state
    }

    func setEvents(_ events: [EventKitCalendarEventSnapshot]) {
        self.events = events
    }

    private func key(for scope: CalendarRemindersScope) -> String {
        switch scope {
        case .reminders:
            return "reminders"
        case .calendarEvents:
            return "calendar-events"
        }
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
