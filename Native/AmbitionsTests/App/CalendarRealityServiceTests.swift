import XCTest
@testable import Ambitions

final class CalendarRealityServiceTests: XCTestCase {
    func testFindOpenWindowsRequestsReadOnlyFromExplicitPlanActionAndDropsRawTitles() async {
        let store = RecordingRealityEventKitStoreClient()
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        await store.setAuthorization(state: .notDetermined, for: .calendarEvents)
        await store.setAuthorizationResponse(state: .fullAccess, for: .calendarEvents)
        await store.setEvents([
            EventKitCalendarEventSnapshot(
                title: "Sensitive appointment title",
                startDate: now.addingTimeInterval(3_600),
                endDate: now.addingTimeInterval(5_400),
                isAllDay: false
            )
        ])
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let service = EventKitIntegrationService(storeClient: store, sideEffectLedger: sideEffectLedger)

        let result = await service.findOpenWindows(
            request: CalendarRealityReadRequest(
                horizon: DateInterval(start: now, end: now.addingTimeInterval(4 * 3_600)),
                userInitiatedTimeAction: "Find real open windows"
            )
        )
        let requestedScopes = await store.requestedScopes

        XCTAssertEqual(requestedScopes, [.calendarEvents])
        XCTAssertEqual(result.permissionState, .readWrite)
        XCTAssertEqual(result.derivedBusyWindows.count, 1)
        XCTAssertEqual(result.derivedBusyWindows.first?.title, "Calendar busy time")
        XCTAssertFalse(result.derivedBusyWindows.contains { $0.title.contains("Sensitive") })
        XCTAssertTrue(result.calendarContext.localOnly)
        XCTAssertEqual(result.calendarContext.privacy, .calendarDerived)
        XCTAssertFalse(result.openWindowCandidates.isEmpty)

        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(record?.effectKind, .calendar)
        XCTAssertEqual(record?.status, .recordedLocalOnly)
        XCTAssertEqual(record?.actionKind, .prepareCalendarBlock)
        XCTAssertEqual(record?.boundary, .localOnly)
        XCTAssertEqual(record?.requiresConfirmation, false)
        XCTAssertFalse(record?.blockedFacts.contains("Sensitive") == true)
    }

    func testDeniedCalendarAccessDegradesWithoutFetchingEvents() async {
        let store = RecordingRealityEventKitStoreClient()
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        await store.setAuthorization(state: .denied, for: .calendarEvents)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let service = EventKitIntegrationService(storeClient: store, sideEffectLedger: sideEffectLedger)

        let result = await service.findOpenWindows(
            request: CalendarRealityReadRequest(
                horizon: DateInterval(start: now, end: now.addingTimeInterval(2 * 3_600)),
                userInitiatedTimeAction: "Make Time calendar-aware"
            )
        )

        XCTAssertEqual(result.permissionState, .denied)
        XCTAssertTrue(result.derivedBusyWindows.isEmpty)
        XCTAssertTrue(result.calendarContext.explanation.contains("Time still works without calendar access"))
        let fetchCount = await store.currentFetchCount()
        XCTAssertEqual(fetchCount, 0)

        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(record?.effectKind, .calendar)
        XCTAssertEqual(record?.status, .blocked)
        XCTAssertEqual(record?.actionKind, .prepareCalendarBlock)
        XCTAssertEqual(record?.boundary, .localOnly)
        XCTAssertEqual(record?.requiresConfirmation, false)
        XCTAssertEqual(record?.externalEffect, false)
        XCTAssertTrue(record?.blockedFacts.contains("Calendar read access was not available for this open-window request.") == true)
    }

    func testConfirmedBlockWriteRequestsWriteAndCreatesAmbitionsBlock() async throws {
        let store = RecordingRealityEventKitStoreClient()
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        await store.setAuthorization(state: .notDetermined, for: .calendarEvents)
        await store.setWriteOnlyAuthorizationResponse(state: .writeOnly)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let service = EventKitIntegrationService(storeClient: store, sideEffectLedger: sideEffectLedger)
        let block = ScheduledAmbitionsBlock(
            id: "block-1",
            title: "Draft proposal",
            start: now.addingTimeInterval(3_600),
            end: now.addingTimeInterval(5_400),
            contextLens: .work,
            relatedPlanID: "plan-1",
            isUserConfirmed: true
        )

        let written = try await service.createCalendarBlock(
            intent: ScheduledBlockWriteIntent(id: "intent-1", block: block, requestedAt: now),
            now: now
        )
        let payload = await store.lastEventPayload
        let writeOnlyRequestCount = await store.currentWriteOnlyRequestCount()

        XCTAssertEqual(written.calendarEventIdentifier, "event-1")
        XCTAssertEqual(writeOnlyRequestCount, 1)
        XCTAssertEqual(payload?.title, "Draft proposal")
        XCTAssertEqual(payload?.notes, "Created by Ambitions after explicit Time confirmation.")

        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(record?.effectKind, .calendar)
        XCTAssertEqual(record?.status, .recordedLocalOnly)
        XCTAssertEqual(record?.actionKind, .writeCalendarBlock)
        XCTAssertEqual(record?.requiresConfirmation, true)
        XCTAssertEqual(record?.externalEffect, true)
    }
}

private actor RecordingRealityEventKitStoreClient: EventKitStoreClient {
    private var authorizationByScope: [String: CalendarRemindersAuthorizationState] = [:]
    private var authorizationResponseByScope: [String: CalendarRemindersAuthorizationState] = [:]
    private var writeOnlyAuthorizationResponse: CalendarRemindersAuthorizationState = .denied
    private var events: [EventKitCalendarEventSnapshot] = []
    private(set) var requestedScopes: [CalendarRemindersScope] = []
    private(set) var writeOnlyRequestCount = 0
    private(set) var fetchCount = 0
    private(set) var lastEventPayload: EventKitEventPayload?

    func authorizationState(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        authorizationByScope[key(for: scope)] ?? .notDetermined
    }

    func requestAuthorization(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        requestedScopes.append(scope)
        let response = authorizationResponseByScope[key(for: scope)] ?? .denied
        authorizationByScope[key(for: scope)] = response
        return response
    }

    func requestWriteOnlyAuthorizationForEvents() async -> CalendarRemindersAuthorizationState {
        writeOnlyRequestCount += 1
        authorizationByScope[key(for: .calendarEvents)] = writeOnlyAuthorizationResponse
        return writeOnlyAuthorizationResponse
    }

    func saveReminder(_ payload: EventKitReminderPayload) async throws -> String {
        _ = payload
        return "reminder-1"
    }

    func saveEvent(_ payload: EventKitEventPayload) async throws -> String {
        lastEventPayload = payload
        return "event-1"
    }

    func fetchEvents(in interval: DateInterval) async -> [EventKitCalendarEventSnapshot] {
        fetchCount += 1
        return events.filter { $0.startDate < interval.end && $0.endDate > interval.start }
    }

    func setAuthorization(state: CalendarRemindersAuthorizationState, for scope: CalendarRemindersScope) {
        authorizationByScope[key(for: scope)] = state
    }

    func setAuthorizationResponse(state: CalendarRemindersAuthorizationState, for scope: CalendarRemindersScope) {
        authorizationResponseByScope[key(for: scope)] = state
    }

    func setWriteOnlyAuthorizationResponse(state: CalendarRemindersAuthorizationState) {
        writeOnlyAuthorizationResponse = state
    }

    func setEvents(_ events: [EventKitCalendarEventSnapshot]) {
        self.events = events
    }

    func currentWriteOnlyRequestCount() -> Int {
        writeOnlyRequestCount
    }

    func currentFetchCount() -> Int {
        fetchCount
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
