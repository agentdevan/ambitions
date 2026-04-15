import EventKit
import Foundation

enum CalendarRemindersScope: Sendable {
    case reminders
    case calendarEvents
}

enum CalendarRemindersAuthorizationState: Sendable, Equatable {
    case notDetermined
    case denied
    case restricted
    case authorized
    case writeOnly
    case fullAccess

    var canWrite: Bool {
        switch self {
        case .authorized, .writeOnly, .fullAccess:
            return true
        case .notDetermined, .denied, .restricted:
            return false
        }
    }
}

struct NextStepSchedulingSelection: Sendable, Equatable {
    let goalID: String
    let goalTitle: String
    let stepID: String
    let stepTitle: String
    let stepSummary: String?
    let suggestedDate: Date?
}

struct CalendarConflict: Sendable, Equatable {
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
}

struct CalendarConflictReport: Sendable, Equatable {
    let proposedStartDate: Date
    let proposedEndDate: Date
    let conflicts: [CalendarConflict]

    var hasConflicts: Bool {
        conflicts.isEmpty == false
    }
}

struct CreatedReminderRecord: Sendable, Equatable {
    let identifier: String
    let title: String
}

struct CreatedCalendarEventRecord: Sendable, Equatable {
    let identifier: String
    let title: String
    let startDate: Date
    let endDate: Date
}

enum CalendarRemindersError: LocalizedError, Equatable {
    case missingEventStartDate
    case authorizationDenied(scope: CalendarRemindersScope)
    case missingDefaultCalendar(scope: CalendarRemindersScope)
    case saveFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingEventStartDate:
            return "This step does not have a concrete suggested time yet."
        case let .authorizationDenied(scope):
            switch scope {
            case .reminders:
                return "Reminders permission is required before creating reminder items."
            case .calendarEvents:
                return "Calendar permission is required before creating calendar events."
            }
        case let .missingDefaultCalendar(scope):
            switch scope {
            case .reminders:
                return "No default reminders list is available on this device."
            case .calendarEvents:
                return "No writable default calendar is available on this device."
            }
        case let .saveFailed(message):
            return "Unable to save to EventKit: \(message)"
        }
    }
}

protocol CalendarRemindersServicing: Sendable {
    func authorizationState(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState
    func requestAuthorizationIfNeeded(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState
    func createReminder(for selection: NextStepSchedulingSelection, now: Date) async throws -> CreatedReminderRecord
    func createCalendarEvent(for selection: NextStepSchedulingSelection, durationMinutes: Int, now: Date) async throws -> CreatedCalendarEventRecord
    func detectConflicts(for selection: NextStepSchedulingSelection, durationMinutes: Int, now: Date) async -> CalendarConflictReport?
}

struct StubCalendarRemindersService: CalendarRemindersServicing {
    var reminderAuthorizationState: CalendarRemindersAuthorizationState = .notDetermined
    var calendarAuthorizationState: CalendarRemindersAuthorizationState = .notDetermined
    var reminderResult: CreatedReminderRecord?
    var calendarResult: CreatedCalendarEventRecord?
    var conflictReport: CalendarConflictReport?
    var failure: CalendarRemindersError?

    func authorizationState(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        switch scope {
        case .reminders:
            return reminderAuthorizationState
        case .calendarEvents:
            return calendarAuthorizationState
        }
    }

    func requestAuthorizationIfNeeded(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        await authorizationState(for: scope)
    }

    func createReminder(for selection: NextStepSchedulingSelection, now: Date) async throws -> CreatedReminderRecord {
        _ = selection
        _ = now
        if let failure {
            throw failure
        }
        return reminderResult ?? CreatedReminderRecord(identifier: "stub-reminder", title: "Stub reminder")
    }

    func createCalendarEvent(for selection: NextStepSchedulingSelection, durationMinutes: Int, now: Date) async throws -> CreatedCalendarEventRecord {
        _ = selection
        _ = durationMinutes
        if let failure {
            throw failure
        }
        return calendarResult ?? CreatedCalendarEventRecord(
            identifier: "stub-event",
            title: "Stub event",
            startDate: now,
            endDate: now.addingTimeInterval(3_600)
        )
    }

    func detectConflicts(for selection: NextStepSchedulingSelection, durationMinutes: Int, now: Date) async -> CalendarConflictReport? {
        _ = selection
        _ = durationMinutes
        _ = now
        return conflictReport
    }
}

actor EventKitIntegrationService: CalendarRemindersServicing {
    private let storeClient: any EventKitStoreClient
    private let planner: CalendarConflictPlanner

    init(
        storeClient: any EventKitStoreClient = EventKitStoreClientLive(),
        planner: CalendarConflictPlanner = CalendarConflictPlanner()
    ) {
        self.storeClient = storeClient
        self.planner = planner
    }

    func authorizationState(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        await storeClient.authorizationState(for: scope)
    }

    func requestAuthorizationIfNeeded(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        let state = await storeClient.authorizationState(for: scope)
        guard state == .notDetermined else { return state }
        return await storeClient.requestAuthorization(for: scope)
    }

    func createReminder(for selection: NextStepSchedulingSelection, now: Date) async throws -> CreatedReminderRecord {
        let state = await requestAuthorizationIfNeeded(for: .reminders)
        guard state.canWrite else {
            throw CalendarRemindersError.authorizationDenied(scope: .reminders)
        }

        let payload = EventKitReminderPayload(
            title: selection.stepTitle,
            notes: reminderNotes(from: selection),
            dueDate: selection.suggestedDate
        )
        do {
            let identifier = try await storeClient.saveReminder(payload)
            return CreatedReminderRecord(identifier: identifier, title: selection.stepTitle)
        } catch let error as CalendarRemindersError {
            throw error
        } catch {
            throw CalendarRemindersError.saveFailed(error.localizedDescription)
        }
    }

    func createCalendarEvent(for selection: NextStepSchedulingSelection, durationMinutes: Int, now: Date) async throws -> CreatedCalendarEventRecord {
        let state = await requestAuthorizationIfNeeded(for: .calendarEvents)
        guard state.canWrite else {
            throw CalendarRemindersError.authorizationDenied(scope: .calendarEvents)
        }

        guard let interval = planner.proposedInterval(for: selection, durationMinutes: durationMinutes, now: now) else {
            throw CalendarRemindersError.missingEventStartDate
        }

        let payload = EventKitEventPayload(
            title: selection.stepTitle,
            notes: reminderNotes(from: selection),
            startDate: interval.start,
            endDate: interval.end
        )
        do {
            let identifier = try await storeClient.saveEvent(payload)
            return CreatedCalendarEventRecord(
                identifier: identifier,
                title: selection.stepTitle,
                startDate: interval.start,
                endDate: interval.end
            )
        } catch let error as CalendarRemindersError {
            throw error
        } catch {
            throw CalendarRemindersError.saveFailed(error.localizedDescription)
        }
    }

    func detectConflicts(for selection: NextStepSchedulingSelection, durationMinutes: Int, now: Date) async -> CalendarConflictReport? {
        guard let interval = planner.proposedInterval(for: selection, durationMinutes: durationMinutes, now: now) else {
            return nil
        }
        let events = await storeClient.fetchEvents(in: interval)
        return planner.makeConflictReport(events: events, proposed: interval)
    }

    private func reminderNotes(from selection: NextStepSchedulingSelection) -> String {
        var lines = [
            "Goal: \(selection.goalTitle)"
        ]
        if let stepSummary = selection.stepSummary, stepSummary.isEmpty == false {
            lines.append(stepSummary)
        }
        lines.append("Ambitions IDs: goal=\(selection.goalID), step=\(selection.stepID)")
        return lines.joined(separator: "\n")
    }
}

struct EventKitReminderPayload: Sendable, Equatable {
    let title: String
    let notes: String
    let dueDate: Date?
}

struct EventKitEventPayload: Sendable, Equatable {
    let title: String
    let notes: String
    let startDate: Date
    let endDate: Date
}

struct EventKitCalendarEventSnapshot: Sendable, Equatable {
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
}

protocol EventKitStoreClient: Sendable {
    func authorizationState(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState
    func requestAuthorization(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState
    func saveReminder(_ payload: EventKitReminderPayload) async throws -> String
    func saveEvent(_ payload: EventKitEventPayload) async throws -> String
    func fetchEvents(in interval: DateInterval) async -> [EventKitCalendarEventSnapshot]
}

actor EventKitStoreClientLive: EventKitStoreClient {
    private let store: EKEventStore

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
            if #available(iOS 17.0, *) {
                _ = try? await request { completion in
                    store.requestFullAccessToReminders(completion: completion)
                }
            } else {
                _ = try? await request { completion in
                    store.requestAccess(to: .reminder, completion: completion)
                }
            }
        case .calendarEvents:
            if #available(iOS 17.0, *) {
                _ = try? await request { completion in
                    store.requestFullAccessToEvents(completion: completion)
                }
            } else {
                _ = try? await request { completion in
                    store.requestAccess(to: .event, completion: completion)
                }
            }
        }
        return await authorizationState(for: scope)
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
        return store.events(matching: predicate).map {
            EventKitCalendarEventSnapshot(
                title: $0.title,
                startDate: $0.startDate,
                endDate: $0.endDate,
                isAllDay: $0.isAllDay
            )
        }
    }

    private func request(
        _ action: (@escaping (Bool, Error?) -> Void) -> Void
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

    private static func mapAuthorizationState(_ status: EKAuthorizationStatus) -> CalendarRemindersAuthorizationState {
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

struct CalendarConflictPlanner: Sendable {
    func proposedInterval(
        for selection: NextStepSchedulingSelection,
        durationMinutes: Int,
        now: Date
    ) -> DateInterval? {
        guard let start = selection.suggestedDate else { return nil }
        let effectiveDuration = max(durationMinutes, 15)
        let end = start.addingTimeInterval(TimeInterval(effectiveDuration * 60))
        if end <= now {
            let fallbackStart = now.addingTimeInterval(1_800)
            return DateInterval(start: fallbackStart, end: fallbackStart.addingTimeInterval(TimeInterval(effectiveDuration * 60)))
        }
        return DateInterval(start: start, end: end)
    }

    func makeConflictReport(
        events: [EventKitCalendarEventSnapshot],
        proposed: DateInterval
    ) -> CalendarConflictReport {
        let conflicts = events
            .filter { event in
                event.startDate < proposed.end && event.endDate > proposed.start
            }
            .sorted { lhs, rhs in
                lhs.startDate < rhs.startDate
            }
            .map {
                CalendarConflict(
                    title: $0.title,
                    startDate: $0.startDate,
                    endDate: $0.endDate,
                    isAllDay: $0.isAllDay
                )
            }

        return CalendarConflictReport(
            proposedStartDate: proposed.start,
            proposedEndDate: proposed.end,
            conflicts: conflicts
        )
    }
}
