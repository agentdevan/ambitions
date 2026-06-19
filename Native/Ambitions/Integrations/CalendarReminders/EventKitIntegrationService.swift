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

actor EventKitIntegrationService: CalendarRemindersServicing {
    private let storeClient: any EventKitStoreClient
    private let sideEffectLedger: (any SideEffectLedgerRepository)?
    private let reminderRepository: (any ReminderRepository)?
    private let calendar: Calendar

    init(
        storeClient: any EventKitStoreClient = EventKitStoreClientLive(),
        sideEffectLedger: (any SideEffectLedgerRepository)? = nil,
        reminderRepository: (any ReminderRepository)? = nil,
        calendar: Calendar = Calendar.current
    ) {
        self.storeClient = storeClient
        self.sideEffectLedger = sideEffectLedger
        self.reminderRepository = reminderRepository
        self.calendar = calendar
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
            notes: explicitRequestNotes(from: selection, itemKind: "reminder"),
            dueDate: selection.suggestedDate
        )
        do {
            let identifier = try await storeClient.saveReminder(payload)
            if let reminderRepository {
                try await reminderRepository.saveReminders([
                    makeReminder(
                        identifier: identifier,
                        selection: selection,
                        now: now
                    )
                ])
            }
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
            await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .blocked,
                boundary: .externalEffect,
                requiresConfirmation: true,
                externalEffect: true,
                blockedFacts: ["Calendar write permission was not available for this requested calendar event."]
            )
            throw CalendarRemindersError.authorizationDenied(scope: .calendarEvents)
        }

        guard let interval = proposedInterval(for: selection, durationMinutes: durationMinutes, now: now) else {
            await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .failedSafely,
                boundary: .localOnly,
                requiresConfirmation: false,
                externalEffect: false,
                degradedFacts: ["Calendar event write request lacked a concrete time."]
            )
            throw CalendarRemindersError.missingEventStartDate
        }

        let payload = EventKitEventPayload(
            title: selection.stepTitle,
            notes: explicitRequestNotes(from: selection, itemKind: "calendar event"),
            startDate: interval.start,
            endDate: interval.end
        )
        do {
            let identifier = try await storeClient.saveEvent(payload)
            await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .recordedLocalOnly,
                boundary: .externalEffect,
                requiresConfirmation: false,
                externalEffect: true,
                reasons: [.externalSideEffect]
            )
            return CreatedCalendarEventRecord(
                identifier: identifier,
                title: selection.stepTitle,
                startDate: interval.start,
                endDate: interval.end
            )
        } catch let error as CalendarRemindersError {
            await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .failedSafely,
                boundary: .externalEffect,
                requiresConfirmation: false,
                externalEffect: true,
                degradedFacts: ["Calendar event write could not be completed safely."]
            )
            throw error
        } catch {
            await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .failedSafely,
                boundary: .externalEffect,
                requiresConfirmation: false,
                externalEffect: true,
                degradedFacts: ["Calendar event write could not be completed safely."]
            )
            throw CalendarRemindersError.saveFailed(error.localizedDescription)
        }
    }

    func detectConflicts(for selection: NextStepSchedulingSelection, durationMinutes: Int, now: Date) async -> CalendarConflictReport? {
        let authorization = await authorizationState(for: .calendarEvents)
        guard authorization.canReadCalendarContext else {
            return nil
        }
        guard let interval = proposedInterval(for: selection, durationMinutes: durationMinutes, now: now) else {
            return nil
        }
        let analysis = analysisWindow(around: interval)
        let events = await storeClient.fetchEvents(in: analysis)
            .flatMap { normalizedBusyWindows(from: $0, calendar: calendar) }
            .sorted { lhs, rhs in
                if lhs.startDate == rhs.startDate {
                    return lhs.endDate < rhs.endDate
                }
                return lhs.startDate < rhs.startDate
            }
        return makeConflictReport(events: events, proposed: interval)
    }

    private func explicitRequestNotes(
        from selection: NextStepSchedulingSelection,
        itemKind: String
    ) -> String {
        [
            "Created by Ambitions after an explicit \(itemKind) request.",
            "Ambitions step ID: \(selection.stepID)"
        ].joined(separator: "\n")
    }

    private func proposedInterval(
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

    private func analysisWindow(around proposed: DateInterval) -> DateInterval {
        let start = proposed.start.addingTimeInterval(-3_600)
        let end = proposed.start.addingTimeInterval(12 * 3_600)
        return DateInterval(start: start, end: end)
    }

    private func makeConflictReport(
        events: [EventKitCalendarEventSnapshot],
        proposed: DateInterval
    ) -> CalendarConflictReport {
        let sortedEvents = events.sorted { lhs, rhs in
            if lhs.startDate == rhs.startDate {
                return lhs.endDate < rhs.endDate
            }
            return lhs.startDate < rhs.startDate
        }
        let conflicts = sortedEvents
            .filter { event in
                event.startDate < proposed.end && event.endDate > proposed.start
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
            conflicts: conflicts,
            nearbyAvailableWindow: nearbyWindow(from: sortedEvents, proposed: proposed),
            pressure: pressureLevel(for: sortedEvents, proposed: proposed)
        )
    }

    private func nearbyWindow(
        from events: [EventKitCalendarEventSnapshot],
        proposed: DateInterval
    ) -> DateInterval? {
        let duration = proposed.duration
        var candidateStart = proposed.start
        let horizon = proposed.start.addingTimeInterval(8 * 3_600)

        for event in events {
            if event.endDate <= candidateStart {
                continue
            }
            if event.startDate >= horizon {
                break
            }
            let candidateEnd = candidateStart.addingTimeInterval(duration)
            if candidateEnd <= event.startDate {
                return DateInterval(start: candidateStart, duration: duration)
            }
            if event.startDate < candidateEnd && event.endDate > candidateStart {
                candidateStart = max(candidateStart, event.endDate)
            }
        }

        let fallbackEnd = candidateStart.addingTimeInterval(duration)
        guard candidateStart > proposed.start, fallbackEnd <= horizon else { return nil }
        return DateInterval(start: candidateStart, end: fallbackEnd)
    }

    private func pressureLevel(
        for events: [EventKitCalendarEventSnapshot],
        proposed: DateInterval
    ) -> CalendarSchedulePressure {
        let window = DateInterval(start: proposed.start, end: proposed.start.addingTimeInterval(8 * 3_600))
        let occupied = events.reduce(0.0) { partial, event in
            let overlapStart = max(event.startDate, window.start)
            let overlapEnd = min(event.endDate, window.end)
            guard overlapEnd > overlapStart else { return partial }
            return partial + overlapEnd.timeIntervalSince(overlapStart)
        }
        let occupancy = occupied / window.duration
        if occupancy >= 0.7 {
            return .high
        }
        if occupancy >= 0.4 {
            return .moderate
        }
        return .low
    }
}

extension EventKitIntegrationService: CalendarRealityServicing, CalendarBlockWriting {
    func calendarPermissionState() async -> CalendarPermissionState {
        await CalendarPermissionState(calendarRemindersState: authorizationState(for: .calendarEvents))
    }

    func requestCalendarReadAccessFromTime(actionName: String) async -> CalendarPermissionState {
        guard actionName.isEmpty == false else {
            return await calendarPermissionState()
        }
        return await CalendarPermissionState(calendarRemindersState: requestAuthorizationIfNeeded(for: .calendarEvents))
    }

    func requestCalendarWriteAccessForConfirmedBlock(intent: ScheduledBlockWriteIntent) async -> CalendarPermissionState {
        guard intent.isExecutable else {
            return await calendarPermissionState()
        }
        let state = await authorizationState(for: .calendarEvents)
        guard state == .notDetermined else {
            return CalendarPermissionState(calendarRemindersState: state)
        }
        return await CalendarPermissionState(calendarRemindersState: storeClient.requestWriteOnlyAuthorizationForEvents())
    }

    func fetchDerivedBusyWindows(for range: DateInterval) async -> [RealityWindow] {
        let authorization = await authorizationState(for: .calendarEvents)
        guard authorization.canReadCalendarContext else { return [] }
        let events = await storeClient.fetchEvents(in: range)
            .flatMap { normalizedBusyWindows(from: $0, calendar: calendar) }
            .sorted { lhs, rhs in
                if lhs.startDate == rhs.startDate {
                    return lhs.endDate < rhs.endDate
                }
                return lhs.startDate < rhs.startDate
            }
        return events.enumerated().compactMap { index, event in
            let start = max(event.startDate, range.start)
            let end = min(event.endDate, range.end)
            guard end > start else { return nil }
            return RealityWindow(
                id: "calendar.busy.\(index).\(Int(start.timeIntervalSince1970))",
                kind: .calendarDerivedBusy,
                source: .calendarDerived,
                start: start,
                end: end,
                title: event.isAllDay ? "Calendar all-day busy time" : "Calendar busy time",
                contextLens: .all
            )
        }
    }

    func findOpenWindows(request: CalendarRealityReadRequest) async -> CalendarRealityReadResult {
        let permission = await requestCalendarReadAccessFromTime(actionName: request.userInitiatedTimeAction)
        let busy: [RealityWindow]
        if permission.canRead {
            busy = await fetchDerivedBusyWindows(for: request.horizon)
        } else {
            await recordCalendarSideEffect(
                actionKind: .prepareCalendarBlock,
                status: .blocked,
                boundary: .localOnly,
                requiresConfirmation: false,
                externalEffect: false,
                blockedFacts: ["Calendar read access was not available for this open-window request."]
            )
            busy = []
        }
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
        if permission.canRead {
            await recordCalendarSideEffect(
                actionKind: .prepareCalendarBlock,
                status: .recordedLocalOnly,
                boundary: .localOnly,
                requiresConfirmation: false,
                externalEffect: false,
                reasons: [.noChangeNeeded]
            )
        }
        return CalendarRealityReadResult(
            permissionState: permission,
            derivedBusyWindows: busy,
            calendarContext: context,
            openWindowCandidates: snapshot.openWindowCandidates
        )
    }

    func createCalendarBlock(intent: ScheduledBlockWriteIntent, now: Date) async throws -> ScheduledAmbitionsBlock {
        guard intent.isExecutable else {
            await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .blocked,
                boundary: .externalEffect,
                requiresConfirmation: true,
                externalEffect: true,
                blockedFacts: ["Calendar block write request was missing required timing details."]
            )
            throw CalendarRemindersError.missingEventStartDate
        }
        let permission = await requestCalendarWriteAccessForConfirmedBlock(intent: intent)
        guard permission.canWrite else {
            await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .blocked,
                boundary: .externalEffect,
                requiresConfirmation: true,
                externalEffect: true,
                blockedFacts: ["Calendar write permission was not available for the confirmed block."]
            )
            throw CalendarRemindersError.authorizationDenied(scope: .calendarEvents)
        }
        let payload = EventKitEventPayload(
            title: intent.block.title,
            notes: "Created by Ambitions after explicit Time confirmation.",
            startDate: intent.block.start,
            endDate: intent.block.end
        )
        do {
            let identifier = try await storeClient.saveEvent(payload)
            await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .recordedLocalOnly,
                boundary: .externalEffect,
                requiresConfirmation: true,
                externalEffect: true,
                reasons: [.externalSideEffect]
            )
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
                calendarEventIdentifier: identifier
            )
        } catch {
            await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .failedSafely,
                boundary: .externalEffect,
                requiresConfirmation: true,
                externalEffect: true,
                degradedFacts: ["Calendar block write did not complete."]
            )
            throw error
        }
    }

    private func recordCalendarSideEffect(
        actionKind: SafeAutomationActionKind,
        status: SideEffectLedgerStatus,
        boundary: SideEffectLedgerBoundary,
        requiresConfirmation: Bool,
        externalEffect: Bool,
        reasons: [SafeAutomationPolicyReason] = [],
        blockedFacts: [String] = [],
        degradedFacts: [String] = []
    ) async {
        guard let sideEffectLedger else {
            return
        }

        let now = Date()
        let record = SideEffectLedgerRecord(
            id: "calendar.\(actionKind.rawValue).\(status.rawValue).\(UUID().uuidString.lowercased())",
            effectKind: .calendar,
            status: status,
            boundary: boundary,
            actionKind: actionKind,
            sourceDomain: .time,
            occurredAt: DomainTimestamp.string(from: now),
            localOnly: boundary == .localOnly,
            requiresConfirmation: requiresConfirmation,
            externalEffect: externalEffect,
            reasons: reasons,
            blockedFacts: blockedFacts,
            degradedFacts: degradedFacts
        )

        do {
            try await sideEffectLedger.append(record)
        } catch {}
    }

    private func makeReminder(
        identifier: String,
        selection: NextStepSchedulingSelection,
        now: Date
    ) -> ReminderTrigger {
        let formatter = ISO8601DateFormatter()
        let timestamp = formatter.string(from: now)
        let triggerAt = selection.suggestedDate.map { formatter.string(from: $0) }
        let sourceRecord = ReminderSourceRecord(
            id: "source.reminder.\(identifier)",
            entityTitle: selection.stepTitle,
            locator: "local://reminders/\(identifier)",
            provenanceKind: .step,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .step,
            id: selection.stepID,
            label: selection.stepTitle,
            sourceDomain: .today
        )
        let source = ReminderSource(
            record: sourceRecord,
            sourceObject: sourceObject,
            surfaceTitle: "Search Ambitions",
            inspectionSummary: "You / Search Ambitions can inspect this source, receipt, and reason."
        )
        let attachment = ReminderAttachment(
            kind: .step,
            object: sourceObject,
            note: "Created from an explicit reminder request."
        )
        return ReminderTrigger(
            id: identifier,
            createdAt: timestamp,
            updatedAt: timestamp,
            title: selection.stepTitle,
            summary: selection.stepSummary,
            triggerAt: triggerAt,
            kind: triggerAt == nil ? .manual : .stepAttachment,
            deliveryPolicy: .inAppAndLocalNotification,
            state: triggerAt == nil ? .draft : .scheduled,
            source: source,
            attachment: attachment,
            receiptID: "Receipt.reminder.\(identifier).save",
            replayTraceID: "ReplayTrace.reminder.\(identifier).save"
        )
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
    func requestWriteOnlyAuthorizationForEvents() async -> CalendarRemindersAuthorizationState
    func saveReminder(_ payload: EventKitReminderPayload) async throws -> String
    func saveEvent(_ payload: EventKitEventPayload) async throws -> String
    // Reserved for future calendar read-path work. The current integration does not call this.
    func fetchEvents(in interval: DateInterval) async -> [EventKitCalendarEventSnapshot]
}

private func normalizedBusyWindows(
    from snapshot: EventKitCalendarEventSnapshot,
    calendar: Calendar = Calendar.current
) -> [EventKitCalendarEventSnapshot] {
    guard snapshot.endDate > snapshot.startDate else { return [] }
    if snapshot.isAllDay == false {
        return [snapshot]
    }
    let dayStart = calendar.startOfDay(for: snapshot.startDate)
    let rawEndDayStart = calendar.startOfDay(for: snapshot.endDate)
    let dayEnd = rawEndDayStart > dayStart ? rawEndDayStart : (calendar.date(byAdding: .day, value: 1, to: dayStart) ?? snapshot.endDate)

    var result: [EventKitCalendarEventSnapshot] = []
    var cursor = dayStart
    while cursor < dayEnd {
        let next = calendar.date(byAdding: .day, value: 1, to: cursor) ?? dayEnd
        let segmentEnd = min(next, dayEnd)
        result.append(
            EventKitCalendarEventSnapshot(
                title: snapshot.title,
                startDate: cursor,
                endDate: segmentEnd,
                isAllDay: true
            )
        )
        cursor = segmentEnd
    }
    return result
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

    private func request(
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
