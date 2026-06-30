import EventKit
import Foundation

actor EventKitStoreClientLive: EventKitStoreClient {
    let store: EKEventStore

    init(store: EKEventStore = EKEventStore()) {
        self.store = store
    }

    func authorizationState(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        switch scope {
        case .reminders:
            return Self.mapAuthorizationState(EKEventStore.authorizationStatus(for: .reminder))
        case .calendarEvents:
            return Self.mapAuthorizationState(EKEventStore.authorizationStatus(for: .event))
        }
    }

    func requestAuthorization(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        switch scope {
        case .reminders:
            _ = try? await request { completion in
                store.requestFullAccessToReminders(completion: completion)
            }
        case .calendarEvents:
            _ = try? await request { completion in
                store.requestFullAccessToEvents(completion: completion)
            }
        }
        return await authorizationState(for: scope)
    }

    func requestWriteOnlyAuthorizationForEvents() async -> CalendarRemindersAuthorizationState {
        _ = try? await request { completion in
            store.requestWriteOnlyAccessToEvents(completion: completion)
        }
        return await authorizationState(for: .calendarEvents)
    }

    func saveReminder(_ payload: EventKitReminderPayload) async throws -> String {
        try await saveReminderThroughSideEffectSystem(payload)
    }

    func saveEvent(_ payload: EventKitEventPayload) async throws -> String {
        try await saveEventThroughSideEffectSystem(payload)
    }

    func fetchEvents(in interval: DateInterval) async -> [EventKitCalendarEventSnapshot] {
        let predicate = store.predicateForEvents(withStart: interval.start, end: interval.end, calendars: nil)
        return store.events(matching: predicate).flatMap { event in
            var eventCalendar = Calendar.current
            if let timeZone = event.timeZone {
                eventCalendar.timeZone = timeZone
            }
            let snapshot = EventKitCalendarEventSnapshot(
                title: event.title,
                startDate: event.startDate,
                endDate: event.endDate,
                isAllDay: event.isAllDay
            )
            return normalizedBusyWindows(from: snapshot, calendar: eventCalendar)
        }
    }

    func request(
        _ action: (@escaping @Sendable (Bool, Error?) -> Void) -> Void
    ) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            action { granted, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    static func mapAuthorizationState(_ status: EKAuthorizationStatus) -> CalendarRemindersAuthorizationState {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .restricted:
            return .restricted
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .writeOnly:
            return .writeOnly
        case .fullAccess:
            return .fullAccess
        @unknown default:
            return .denied
        }
    }
}
