import EventKit
import Foundation

actor EventKitIntegrationService: CalendarRemindersServicing {
    let storeClient: any EventKitStoreClient
    let eventKitOutbox: EventKitOutbox
    let reminderRepository: (any ReminderRepository)?
    let calendar: Calendar

    init(
        storeClient: any EventKitStoreClient = EventKitStoreClientLive(),
        eventKitOutbox: EventKitOutbox = EventKitOutbox(recorder: nil),
        reminderRepository: (any ReminderRepository)? = nil,
        calendar: Calendar = Calendar.current
    ) {
        self.storeClient = storeClient
        self.eventKitOutbox = eventKitOutbox
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
        try await createReminder(for: selection, now: now, localCommit: nil)
    }

    func createReminder(
        for selection: NextStepSchedulingSelection,
        now: Date,
        localCommit: SideEffectLocalCommitEvidence?
    ) async throws -> CreatedReminderRecord {
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
            let attempt = await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .queued,
                boundary: .externalEffect,
                requiresConfirmation: false,
                externalEffect: true,
                reasons: [.externalSideEffect],
                degradedFacts: ["Reminder write queued after explicit user request."],
                localCommit: localCommit
            )
            guard attempt?.mayAttemptExternalWrite == true else {
                throw CalendarRemindersError.missingLocalCommitReceipt(scope: .reminders)
            }
            let identifier = try await storeClient.saveReminder(payload)
            await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .succeeded,
                boundary: .externalEffect,
                requiresConfirmation: false,
                externalEffect: true,
                reasons: [.externalSideEffect],
                degradedFacts: ["Reminder write completed through EventKit side-effect owner."],
                localCommit: localCommit
            )
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
        } catch CalendarRemindersError.missingLocalCommitReceipt(let scope) {
            throw CalendarRemindersError.missingLocalCommitReceipt(scope: scope)
        } catch let error as CalendarRemindersError {
            await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .failedSafely,
                boundary: .externalEffect,
                requiresConfirmation: false,
                externalEffect: true,
                degradedFacts: ["Reminder write could not be completed safely."]
            )
            throw error
        } catch {
            await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .failedSafely,
                boundary: .externalEffect,
                requiresConfirmation: false,
                externalEffect: true,
                degradedFacts: ["Reminder write could not be completed safely."]
            )
            throw CalendarRemindersError.saveFailed(error.localizedDescription)
        }
    }

    func createCalendarEvent(for selection: NextStepSchedulingSelection, durationMinutes: Int, now: Date) async throws -> CreatedCalendarEventRecord {
        try await createCalendarEvent(for: selection, durationMinutes: durationMinutes, now: now, localCommit: nil)
    }

    func createCalendarEvent(
        for selection: NextStepSchedulingSelection,
        durationMinutes: Int,
        now: Date,
        localCommit: SideEffectLocalCommitEvidence?
    ) async throws -> CreatedCalendarEventRecord {
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
            let attempt = await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .queued,
                boundary: .externalEffect,
                requiresConfirmation: false,
                externalEffect: true,
                reasons: [.externalSideEffect],
                degradedFacts: ["Calendar event write queued after explicit user request."],
                localCommit: localCommit
            )
            guard attempt?.mayAttemptExternalWrite == true else {
                throw CalendarRemindersError.missingLocalCommitReceipt(scope: .calendarEvents)
            }
            let identifier = try await storeClient.saveEvent(payload)
            await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .succeeded,
                boundary: .externalEffect,
                requiresConfirmation: false,
                externalEffect: true,
                reasons: [.externalSideEffect],
                degradedFacts: ["Calendar event write completed through EventKit side-effect owner."],
                localCommit: localCommit
            )
            return CreatedCalendarEventRecord(
                identifier: identifier,
                title: selection.stepTitle,
                startDate: interval.start,
                endDate: interval.end
            )
        } catch CalendarRemindersError.missingLocalCommitReceipt(let scope) {
            throw CalendarRemindersError.missingLocalCommitReceipt(scope: scope)
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

    func explicitRequestNotes(
        from selection: NextStepSchedulingSelection,
        itemKind: String
    ) -> String {
        [
            "Created by Ambitions after an explicit \(itemKind) request.",
            "Ambitions step ID: \(selection.stepID)"
        ].joined(separator: "\n")
    }

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

    func analysisWindow(around proposed: DateInterval) -> DateInterval {
        let start = proposed.start.addingTimeInterval(-3_600)
        let end = proposed.start.addingTimeInterval(12 * 3_600)
        return DateInterval(start: start, end: end)
    }

    func makeConflictReport(
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

    func nearbyWindow(
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

    func pressureLevel(
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
