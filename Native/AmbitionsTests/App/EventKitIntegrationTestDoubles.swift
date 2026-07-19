import Foundation
@testable import Ambitions

actor RecordingEventKitStoreClient: EventKitStoreClient {
    private var authorizationByScope: [String: CalendarRemindersAuthorizationState] = [:]
    private var authorizationResponseByScope: [String: CalendarRemindersAuthorizationState] = [:]
    private(set) var lastReminderPayload: EventKitReminderPayload?
    private(set) var lastEventPayload: EventKitEventPayload?
    private(set) var saveReminderCount = 0
    private(set) var saveEventCount = 0
    private var reminderSaveFailure: CalendarRemindersError?
    private var eventSaveFailure: CalendarRemindersError?
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
        if let reminderSaveFailure { throw reminderSaveFailure }
        saveReminderCount += 1
        lastReminderPayload = payload
        return "reminder-1"
    }

    func saveEvent(_ payload: EventKitEventPayload) async throws -> String {
        if let eventSaveFailure { throw eventSaveFailure }
        saveEventCount += 1
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

    func setReminderSaveFailure(_ failure: CalendarRemindersError) {
        reminderSaveFailure = failure
    }

    func setEventSaveFailure(_ failure: CalendarRemindersError) {
        eventSaveFailure = failure
    }

    func currentSaveEventCount() -> Int {
        saveEventCount
    }

    func currentSaveReminderCount() -> Int {
        saveReminderCount
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

actor RecordingEventKitSideEffectLedgerRepository: SideEffectLedgerRepository {
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
