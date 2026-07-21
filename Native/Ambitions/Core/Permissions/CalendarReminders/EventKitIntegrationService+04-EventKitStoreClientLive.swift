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
        try await saveReminderThroughExternalWrites(payload)
    }

    func saveEvent(_ payload: EventKitEventPayload) async throws -> String {
        try await saveEventThroughExternalWrites(payload)
    }

    func reconcileExternalItem(
        kind: EventKitExternalItemKind,
        operationMarker: String,
        interval: DateInterval?
    ) async -> EventKitReconciliationResult {
        let scope: CalendarRemindersScope = kind == .reminder ? .reminders : .calendarEvents
        let state = await authorizationState(for: scope)
        guard state == .fullAccess || state == .authorized else { return .unavailable }
        let identifiers: [String]
        switch kind {
        case .reminder:
            let predicate = store.predicateForReminders(in: nil)
            identifiers = await withCheckedContinuation { continuation in
                store.fetchReminders(matching: predicate) { reminders in
                    let identifiers = (reminders ?? []).compactMap { reminder in
                        reminder.notes?.split(whereSeparator: \.isNewline)
                            .contains(where: { String($0) == operationMarker }) == true
                            ? reminder.calendarItemIdentifier
                            : nil
                    }
                    continuation.resume(returning: identifiers)
                }
            }
        case .calendarEvent:
            guard let interval else { return .unavailable }
            let predicate = store.predicateForEvents(
                withStart: interval.start.addingTimeInterval(-86_400),
                end: interval.end.addingTimeInterval(86_400),
                calendars: nil
            )
            identifiers = store.events(matching: predicate).compactMap { event in
                hasExactMarker(event.notes, marker: operationMarker) ? event.calendarItemIdentifier : nil
            }
        }
        let unique = Array(Set(identifiers))
        if unique.isEmpty { return .none }
        if unique.count == 1, let identifier = unique.first { return .one(identifier) }
        return .ambiguous
    }

    private func hasExactMarker(_ notes: String?, marker: String) -> Bool {
        notes?.split(whereSeparator: \.isNewline).contains { String($0) == marker } == true
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
