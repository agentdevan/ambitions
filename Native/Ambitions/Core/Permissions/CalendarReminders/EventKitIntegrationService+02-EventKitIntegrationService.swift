import EventKit
import Foundation

actor EventKitIntegrationService: CalendarRemindersServicing {
    let storeClient: any EventKitStoreClient
    let eventKitOutbox: EventKitOutbox
    let reminderRepository: (any ReminderRepository)?
    let pendingOperationStore: (any PendingEventKitOperationStoring)?
    let calendar: Calendar

    init(
        storeClient: any EventKitStoreClient = EventKitStoreClientLive(),
        eventKitOutbox: EventKitOutbox = EventKitOutbox(recorder: nil),
        reminderRepository: (any ReminderRepository)? = nil,
        pendingOperationStore: (any PendingEventKitOperationStoring)? = nil,
        calendar: Calendar = Calendar.current
    ) {
        self.storeClient = storeClient
        self.eventKitOutbox = eventKitOutbox
        self.reminderRepository = reminderRepository
        self.pendingOperationStore = pendingOperationStore
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
        throw CalendarRemindersError.missingLocalCommitReceipt(scope: .reminders)
    }

    func createReminder(
        for selection: NextStepSchedulingSelection,
        now: Date,
        operationID: String,
        localCommit: SideEffectLocalCommitEvidence?
    ) async throws -> CreatedReminderRecord {
        let localCommit = try await requireAuthorityEvidence(
            localCommit,
            operationID: operationID,
            kind: "reminder",
            scope: .reminders,
            now: now
        )
        let state = await requestAuthorizationIfNeeded(for: .reminders)
        guard state.canWrite else {
            let attempt = await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .blocked,
                boundary: .externalEffect,
                requiresConfirmation: true,
                externalEffect: false,
                blockedFacts: ["Reminder write permission was not available for this requested reminder."]
            )
            await recordCalendarResult(
                SideEffectAttemptResult(
                    state: .permissionDenied,
                    degradedFacts: ["Reminder write permission was denied before EventKit save."]
                ),
                for: attempt,
                now: now
            )
            throw CalendarRemindersError.authorizationDenied(scope: .reminders)
        }

        let operation = try await resolveOperationIdentity(
            kind: "reminder",
            selection: selection,
            proposedOperationID: operationID
        )
        let marker = externalEffectMarker(operationID: operation.id)
        let payload = EventKitReminderPayload(
            title: selection.stepTitle,
            notes: explicitRequestNotes(from: selection, itemKind: "reminder") + "\n" + marker,
            dueDate: selection.suggestedDate
        )
        let claim = try await eventKitOutbox.claimCalendarSideEffect(
            requestID: externalEffectRequestID(kind: "reminder", operationID: operation.id),
            operationID: operation.id,
            localCommit: localCommit,
            now: now
        )
        if case .denied = claim {
            throw CalendarRemindersError.missingLocalCommitReceipt(scope: .reminders)
        }
        if case let .terminal(attempt) = claim, let identifier = attempt.ledgerRecord.receiptID {
            return try await completeReminderSuccess(
                identifier: identifier,
                selection: selection,
                operation: operation,
                now: now
            )
        }
        if case let .reconciliationRequired(existing) = claim {
            let reconciled = try await reconcileReminder(
                existing: existing,
                marker: marker,
                selection: selection,
                now: now
            )
            return try await completeReminderSuccess(
                identifier: reconciled.identifier,
                selection: selection,
                operation: operation,
                now: now
            )
        }
        let attempt = claim.attempt
        let identifier: String
        do {
            identifier = try await storeClient.saveReminder(payload)
        } catch let error as CalendarRemindersError {
            try? await recordFailedExternalWrite(for: attempt, item: "Reminder", now: now)
            throw error
        } catch {
            try? await recordFailedExternalWrite(for: attempt, item: "Reminder", now: now)
            throw CalendarRemindersError.saveFailed(error.localizedDescription)
        }
        do {
            try await eventKitOutbox.recordCalendarResultStrict(
                SideEffectAttemptResult(
                    state: .succeeded,
                    externalReceiptID: identifier,
                    degradedFacts: ["Reminder write completed through EventKit side-effect owner."]
                ),
                for: attempt,
                now: now
            )
        } catch {
            throw CalendarRemindersError.resultRecordingIndeterminate(
                scope: .reminders,
                externalIdentifier: identifier
            )
        }
        return try await completeReminderSuccess(
            identifier: identifier,
            selection: selection,
            operation: operation,
            now: now
        )
    }

    func createCalendarEvent(
        for selection: NextStepSchedulingSelection,
        durationMinutes: Int,
        now: Date
    ) async throws -> CreatedCalendarEventRecord {
        throw CalendarRemindersError.missingLocalCommitReceipt(scope: .calendarEvents)
    }

    func createCalendarEvent(
        for selection: NextStepSchedulingSelection,
        durationMinutes: Int,
        now: Date,
        operationID: String,
        localCommit: SideEffectLocalCommitEvidence?
    ) async throws -> CreatedCalendarEventRecord {
        let localCommit = try await requireAuthorityEvidence(
            localCommit,
            operationID: operationID,
            kind: "calendar-event",
            scope: .calendarEvents,
            now: now
        )
        let state = await requestAuthorizationIfNeeded(for: .calendarEvents)
        guard state.canWrite else {
            let attempt = await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .blocked,
                boundary: .externalEffect,
                requiresConfirmation: true,
                externalEffect: false,
                blockedFacts: ["Calendar write permission was not available for this requested calendar event."]
            )
            await recordCalendarResult(
                SideEffectAttemptResult(
                    state: .permissionDenied,
                    degradedFacts: ["Calendar write permission was denied before EventKit save."]
                ),
                for: attempt,
                now: now
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

        let operation = try await resolveOperationIdentity(
            kind: RuntimeExternalEffectKind.calendarEvent.rawValue,
            selection: selection,
            proposedOperationID: operationID
        )
        let marker = externalEffectMarker(operationID: operation.id)
        let payload = EventKitEventPayload(
            title: selection.stepTitle,
            notes: explicitRequestNotes(from: selection, itemKind: "calendar event") + "\n" + marker,
            startDate: interval.start,
            endDate: interval.end
        )
        let claim = try await eventKitOutbox.claimCalendarSideEffect(
            requestID: externalEffectRequestID(kind: "calendar-event", operationID: operation.id),
            operationID: operation.id,
            localCommit: localCommit,
            now: now
        )
        if case .denied = claim {
            throw CalendarRemindersError.missingLocalCommitReceipt(scope: .calendarEvents)
        }
        if case let .terminal(attempt) = claim, let identifier = attempt.ledgerRecord.receiptID {
            try await pendingOperationStore?.complete(fingerprint: operation.fingerprint, operationID: operation.id)
            return CreatedCalendarEventRecord(
                identifier: identifier,
                title: selection.stepTitle,
                startDate: interval.start,
                endDate: interval.end
            )
        }
        if case let .reconciliationRequired(existing) = claim {
            let reconciled = try await reconcileCalendarEvent(
                existing: existing,
                marker: marker,
                selection: selection,
                interval: interval,
                now: now
            )
            try await pendingOperationStore?.complete(
                fingerprint: operation.fingerprint,
                operationID: operation.id
            )
            return reconciled
        }
        let attempt = claim.attempt
        let identifier: String
        do {
            identifier = try await storeClient.saveEvent(payload)
        } catch let error as CalendarRemindersError {
            try? await recordFailedExternalWrite(for: attempt, item: "Calendar event", now: now)
            throw error
        } catch {
            try? await recordFailedExternalWrite(for: attempt, item: "Calendar event", now: now)
            throw CalendarRemindersError.saveFailed(error.localizedDescription)
        }
        do {
            try await eventKitOutbox.recordCalendarResultStrict(
                SideEffectAttemptResult(
                    state: .succeeded,
                    externalReceiptID: identifier,
                    degradedFacts: ["Calendar event write completed through EventKit side-effect owner."]
                ),
                for: attempt,
                now: now
            )
        } catch {
            throw CalendarRemindersError.resultRecordingIndeterminate(
                scope: .calendarEvents,
                externalIdentifier: identifier
            )
        }
        try await pendingOperationStore?.complete(
            fingerprint: operation.fingerprint,
            operationID: operation.id
        )
        return CreatedCalendarEventRecord(
            identifier: identifier,
            title: selection.stepTitle,
            startDate: interval.start,
            endDate: interval.end
        )
    }

    func detectConflicts(
        for selection: NextStepSchedulingSelection,
        durationMinutes: Int,
        now: Date
    ) async -> CalendarConflictReport? {
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

    private func externalEffectRequestID(
        kind: String,
        operationID: String
    ) -> String {
        "calendar.\(kind).\(operationID)"
    }

    private func externalEffectMarker(operationID: String) -> String {
        "Ambitions-Operation-ID: \(operationID)"
    }

    private func reconcileReminder(
        existing: SideEffectAttempt,
        marker: String,
        selection: NextStepSchedulingSelection,
        now: Date
    ) async throws -> CreatedReminderRecord {
        let result = await storeClient.reconcileExternalItem(
            kind: .reminder,
            operationMarker: marker,
            interval: nil
        )
        guard case let .one(identifier) = result else {
            throw CalendarRemindersError.reconciliationRequired(scope: .reminders)
        }
        try await finalizeReconciled(identifier: identifier, existing: existing, now: now)
        return CreatedReminderRecord(identifier: identifier, title: selection.stepTitle)
    }

    private func materializeReminderMirror(
        identifier: String,
        selection: NextStepSchedulingSelection,
        now: Date
    ) async throws {
        guard let reminderRepository else { return }
        do {
            try await reminderRepository.saveReminders([
                makeReminder(identifier: identifier, selection: selection, now: now)
            ])
        } catch {
            throw CalendarRemindersError.mirrorMaterializationPending(
                scope: .reminders,
                externalIdentifier: identifier
            )
        }
    }

    private func completeReminderSuccess(
        identifier: String,
        selection: NextStepSchedulingSelection,
        operation: (id: String, fingerprint: String),
        now: Date
    ) async throws -> CreatedReminderRecord {
        try await materializeReminderMirror(identifier: identifier, selection: selection, now: now)
        try await pendingOperationStore?.complete(
            fingerprint: operation.fingerprint,
            operationID: operation.id
        )
        return CreatedReminderRecord(identifier: identifier, title: selection.stepTitle)
    }

    private func reconcileCalendarEvent(
        existing: SideEffectAttempt,
        marker: String,
        selection: NextStepSchedulingSelection,
        interval: DateInterval,
        now: Date
    ) async throws -> CreatedCalendarEventRecord {
        let result = await storeClient.reconcileExternalItem(
            kind: .calendarEvent,
            operationMarker: marker,
            interval: interval
        )
        guard case let .one(identifier) = result else {
            throw CalendarRemindersError.reconciliationRequired(scope: .calendarEvents)
        }
        try await finalizeReconciled(identifier: identifier, existing: existing, now: now)
        return CreatedCalendarEventRecord(
            identifier: identifier,
            title: selection.stepTitle,
            startDate: interval.start,
            endDate: interval.end
        )
    }

    private func finalizeReconciled(
        identifier: String,
        existing: SideEffectAttempt,
        now: Date
    ) async throws {
        let owned = SideEffectAttempt(
            id: existing.id,
            request: existing.request,
            decision: existing.decision,
            ledgerRecord: existing.ledgerRecord,
            lease: nil,
            claimToken: existing.ledgerRecord.claimToken
        )
        try await eventKitOutbox.recordCalendarResultStrict(
            SideEffectAttemptResult(
                state: .succeeded,
                externalReceiptID: identifier,
                degradedFacts: ["Recovered an EventKit write by exact operation marker."]
            ),
            for: owned,
            now: now
        )
    }

    private func requireAuthorityEvidence(
        _ evidence: SideEffectLocalCommitEvidence?,
        operationID: String,
        kind: String,
        scope: CalendarRemindersScope,
        now: Date
    ) async throws -> SideEffectLocalCommitEvidence {
        let provesCommit = evidence?.provesCommittedLocalMutationWithoutExternalEffects == true &&
            evidence?.authorityCommandID.isEmpty == false
        let lineageMatches = UUID(uuidString: operationID) != nil &&
            evidence?.operationID.caseInsensitiveCompare(operationID) == .orderedSame
        guard let evidence, provesCommit, lineageMatches else {
            var blockedFacts = [
                "External side effect cannot be attempted before a committed local mutation receipt."
            ]
            if provesCommit && lineageMatches == false {
                blockedFacts.append(
                    "External side effect authority evidence does not match the requested command and operation."
                )
            }
            _ = await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .blocked,
                boundary: .externalEffect,
                requiresConfirmation: true,
                externalEffect: true,
                blockedFacts: blockedFacts,
                commandID: evidence?.authorityCommandID,
                operationID: operationID.lowercased(),
                requestID: externalEffectRequestID(kind: kind, operationID: operationID) + ".authority-denied",
                now: now
            )
            throw CalendarRemindersError.missingLocalCommitReceipt(scope: scope)
        }
        return evidence
    }

    private func resolveOperationIdentity(
        kind: String,
        selection: NextStepSchedulingSelection,
        proposedOperationID: String
    ) async throws -> (id: String, fingerprint: String) {
        let fingerprint = FilePendingEventKitOperationStore.fingerprint(
            kind: kind,
            goalID: selection.goalID,
            stepID: selection.stepID
        )
        guard let pendingOperationStore else {
            throw SideEffectOutboxError.missingDurableID
        }
        let operationID = try await pendingOperationStore.resolve(
            fingerprint: fingerprint,
            proposedOperationID: proposedOperationID
        )
        guard UUID(uuidString: operationID) != nil else {
            throw SideEffectOutboxError.missingDurableID
        }
        return (operationID.lowercased(), fingerprint)
    }

    private func recordFailedExternalWrite(
        for attempt: SideEffectAttempt,
        item: String,
        now: Date
    ) async throws {
        try await eventKitOutbox.recordCalendarResultStrict(
            SideEffectAttemptResult(
                state: .failedSafely,
                degradedFacts: ["\(item) write could not be completed safely."]
            ),
            for: attempt,
            now: now
        )
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
            return DateInterval(
                start: fallbackStart,
                end: fallbackStart.addingTimeInterval(TimeInterval(effectiveDuration * 60))
            )
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
