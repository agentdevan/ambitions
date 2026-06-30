import EventKit
import Foundation

extension EventKitStoreClientLive {
    func saveReminderThroughSideEffectSystem(_ payload: EventKitReminderPayload) async throws -> String {
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

    func saveEventThroughSideEffectSystem(_ payload: EventKitEventPayload) async throws -> String {
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
}
