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

    var canReadCalendarContext: Bool {
        switch self {
        case .authorized, .fullAccess:
            return true
        case .notDetermined, .denied, .restricted, .writeOnly:
            return false
        }
    }
}

extension CalendarPermissionState {
    init(calendarRemindersState: CalendarRemindersAuthorizationState) {
        switch calendarRemindersState {
        case .notDetermined:
            self = .notDetermined
        case .denied:
            self = .denied
        case .restricted:
            self = .restricted
        case .authorized, .fullAccess:
            self = .readWrite
        case .writeOnly:
            self = .writeOnly
        }
    }
}

enum CalendarSchedulePressure: String, Sendable, Equatable {
    case low
    case moderate
    case high
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
    let nearbyAvailableWindow: DateInterval?
    let pressure: CalendarSchedulePressure

    var hasConflicts: Bool {
        conflicts.isEmpty == false
    }

    var hasNearbyRoom: Bool {
        nearbyAvailableWindow != nil
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

struct CalendarRealityReadRequest: Sendable, Equatable {
    let horizon: DateInterval
    let userInitiatedTimeAction: String
    let minimumWindowMinutes: Int

    init(
        horizon: DateInterval,
        userInitiatedTimeAction: String,
        minimumWindowMinutes: Int = 30
    ) {
        self.horizon = horizon
        self.userInitiatedTimeAction = userInitiatedTimeAction
        self.minimumWindowMinutes = max(15, minimumWindowMinutes)
    }
}

struct CalendarRealityReadResult: Sendable, Equatable {
    let permissionState: CalendarPermissionState
    let derivedBusyWindows: [RealityWindow]
    let calendarContext: CalendarDerivedContext
    let openWindowCandidates: [OpenWindowCandidate]
}

enum CalendarRemindersError: LocalizedError, Equatable {
    case missingEventStartDate
    case authorizationDenied(scope: CalendarRemindersScope)
    case missingDefaultCalendar(scope: CalendarRemindersScope)
    case missingLocalCommitReceipt(scope: CalendarRemindersScope)
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
        case let .missingLocalCommitReceipt(scope):
            switch scope {
            case .reminders:
                return "A local runtime commit receipt is required before creating reminder items."
            case .calendarEvents:
                return "A local runtime commit receipt is required before creating calendar events."
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
    // Reserved for the next calendar read-path pass. The current hook avoids broad churn.
    func detectConflicts(for selection: NextStepSchedulingSelection, durationMinutes: Int, now: Date) async -> CalendarConflictReport?
}

protocol CalendarPermissionServicing: Sendable {
    func calendarPermissionState() async -> CalendarPermissionState
    func requestCalendarReadAccessFromTime(actionName: String) async -> CalendarPermissionState
    func requestCalendarWriteAccessForConfirmedBlock(intent: ScheduledBlockWriteIntent) async -> CalendarPermissionState
}

protocol CalendarRealityServicing: CalendarPermissionServicing {
    func fetchDerivedBusyWindows(for range: DateInterval) async -> [RealityWindow]
    func findOpenWindows(request: CalendarRealityReadRequest) async -> CalendarRealityReadResult
}

protocol CalendarBlockWriting: Sendable {
    func createCalendarBlock(intent: ScheduledBlockWriteIntent, now: Date) async throws -> ScheduledAmbitionsBlock
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

extension StubCalendarRemindersService: CalendarRealityServicing, CalendarBlockWriting {
    func calendarPermissionState() async -> CalendarPermissionState {
        CalendarPermissionState(calendarRemindersState: calendarAuthorizationState)
    }

    func requestCalendarReadAccessFromTime(actionName: String) async -> CalendarPermissionState {
        _ = actionName
        return await calendarPermissionState()
    }

    func requestCalendarWriteAccessForConfirmedBlock(intent: ScheduledBlockWriteIntent) async -> CalendarPermissionState {
        _ = intent
        return await calendarPermissionState()
    }

    func fetchDerivedBusyWindows(for range: DateInterval) async -> [RealityWindow] {
        guard calendarAuthorizationState.canReadCalendarContext else { return [] }
        guard let report = conflictReport else { return [] }
        return report.conflicts.enumerated().map { index, conflict in
            RealityWindow(
                id: "stub.calendar.busy.\(index)",
                kind: .calendarDerivedBusy,
                source: .calendarDerived,
                start: max(conflict.startDate, range.start),
                end: min(conflict.endDate, range.end),
                title: conflict.isAllDay ? "Calendar all-day busy time" : "Calendar busy time",
                contextLens: .all
            )
        }.filter { $0.end > $0.start }
    }

    func findOpenWindows(request: CalendarRealityReadRequest) async -> CalendarRealityReadResult {
        let permission = await calendarPermissionState()
        let busy = await fetchDerivedBusyWindows(for: request.horizon)
        let context = CalendarDerivedContext(
            permissionState: permission,
            observedRangeStart: request.horizon.start,
            observedRangeEnd: request.horizon.end,
            derivedBusyWindowCount: busy.count,
            userInitiatedTimeAction: request.userInitiatedTimeAction,
            explanation: permission.canRead
                ? "Plan used derived calendar busy time locally to find open windows."
                : "Time still works without calendar access; no calendar busy time was read."
        )
        let snapshot = RealityModelProjector().project(
            input: RealityProjectionInput(
                now: request.horizon.start,
                horizon: request.horizon,
                calendarBusyWindows: busy,
                calendarContext: context,
                minimumWindowMinutes: request.minimumWindowMinutes
            )
        )
        return CalendarRealityReadResult(
            permissionState: permission,
            derivedBusyWindows: busy,
            calendarContext: context,
            openWindowCandidates: snapshot.openWindowCandidates
        )
    }

    func createCalendarBlock(intent: ScheduledBlockWriteIntent, now: Date) async throws -> ScheduledAmbitionsBlock {
        _ = now
        guard intent.isExecutable else {
            throw CalendarRemindersError.missingEventStartDate
        }
        guard calendarAuthorizationState.canWrite else {
            throw CalendarRemindersError.authorizationDenied(scope: .calendarEvents)
        }
        return ScheduledAmbitionsBlock(
            id: intent.block.id,
            title: intent.block.title,
            start: intent.block.start,
            end: intent.block.end,
            contextLens: intent.block.contextLens,
            relatedGoalID: intent.block.relatedGoalID,
            relatedCaptureID: intent.block.relatedCaptureID,
            relatedPlanID: intent.block.relatedPlanID,
            isUserConfirmed: true,
            calendarEventIdentifier: calendarResult?.identifier ?? "stub-event"
        )
    }
}
