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
        let reminder = EKReminder(eventStore: store)
        reminder.title = payload.title
        reminder.notes = payload.notes

        if let dueDate = payload.dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents(
                in: .current,
                from: dueDate
            )
        }

        guard let calendar = store.defaultCalendarForNewReminders() else {
            throw CalendarRemindersError.missingDefaultCalendar(scope: .reminders)
        }
        reminder.calendar = calendar

        do {
            try store.save(reminder, commit: true)
            return reminder.calendarItemIdentifier
        } catch {
            throw CalendarRemindersError.saveFailed(error.localizedDescription)
        }
    }

    func saveEvent(_ payload: EventKitEventPayload) async throws -> String {
        let event = EKEvent(eventStore: store)
        event.title = payload.title
        event.notes = payload.notes
        event.startDate = payload.startDate
        event.endDate = payload.endDate

        guard let calendar = store.defaultCalendarForNewEvents else {
            throw CalendarRemindersError.missingDefaultCalendar(scope: .calendarEvents)
        }
        event.calendar = calendar

        do {
            try store.save(event, span: .thisEvent, commit: true)
            return event.calendarItemIdentifier
        } catch {
            throw CalendarRemindersError.saveFailed(error.localizedDescription)
        }
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
