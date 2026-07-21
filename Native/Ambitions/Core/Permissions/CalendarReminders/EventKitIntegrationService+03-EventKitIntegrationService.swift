import EventKit
import Foundation

extension EventKitIntegrationService {
    func calendarPermissionState() async -> CalendarPermissionState {
        await CalendarPermissionState(calendarRemindersState: authorizationState(for: .calendarEvents))
    }

    func requestCalendarReadAccessFromTime(actionName: String) async -> CalendarPermissionState {
        let authorization = await authorizationState(for: .calendarEvents)
        let decision = CalendarPermission().readDecision(
            current: authorization,
            context: PermissionRequestContext(
                surface: .time,
                actionName: actionName
            )
        )
        guard decision.shouldRequestSystemPermission else {
            return await calendarPermissionState()
        }
        return await CalendarPermissionState(calendarRemindersState: requestAuthorizationIfNeeded(for: .calendarEvents))
    }

    func requestCalendarWriteAccessForConfirmedBlock(intent: ScheduledBlockWriteIntent) async -> CalendarPermissionState {
        let state = await authorizationState(for: .calendarEvents)
        let decision = CalendarPermission().writeDecision(current: state, intent: intent)
        guard decision.shouldRequestSystemPermission else {
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
        try await createCalendarBlock(intent: intent, now: now, localCommit: nil)
    }

    func createCalendarBlock(
        intent: ScheduledBlockWriteIntent,
        now: Date,
        localCommit: SideEffectLocalCommitEvidence?
    ) async throws -> ScheduledAmbitionsBlock {
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
            let attempt = await recordCalendarSideEffect(
                actionKind: .writeCalendarBlock,
                status: .blocked,
                boundary: .externalEffect,
                requiresConfirmation: true,
                externalEffect: false,
                blockedFacts: ["Calendar write permission was not available for the confirmed block."]
            )
            await recordCalendarResult(
                SideEffectAttemptResult(
                    state: .permissionDenied,
                    degradedFacts: ["Calendar block write permission was denied before EventKit save."]
                ),
                for: attempt,
                now: now
            )
            throw CalendarRemindersError.authorizationDenied(scope: .calendarEvents)
        }
        let payload = EventKitEventPayload(
            title: intent.block.title,
            notes: "Created by Ambitions after explicit Time confirmation.",
            startDate: intent.block.start,
            endDate: intent.block.end
        )
        let attempt = await recordCalendarSideEffect(
            actionKind: .writeCalendarBlock,
            status: .queued,
            boundary: .externalEffect,
            requiresConfirmation: true,
            externalEffect: true,
            reasons: [.externalSideEffect],
            localCommit: localCommit
        )
        guard attempt?.mayAttemptExternalWrite == true else {
            throw CalendarRemindersError.missingLocalCommitReceipt(scope: .calendarEvents)
        }
        do {
            let identifier = try await storeClient.saveEvent(payload)
            await recordCalendarResult(
                SideEffectAttemptResult(
                    state: .succeeded,
                    externalReceiptID: identifier,
                    degradedFacts: ["Calendar block write completed through EventKit side-effect owner."]
                ),
                for: attempt,
                now: now
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
            await recordCalendarResult(
                SideEffectAttemptResult(
                    state: .failedSafely,
                    degradedFacts: ["Calendar block write did not complete."]
                ),
                for: attempt,
                now: now
            )
            throw error
        }
    }

    @discardableResult
    func recordCalendarSideEffect(
        actionKind: SafeAutomationActionKind,
        status: SideEffectLedgerStatus,
        boundary: SideEffectLedgerBoundary,
        requiresConfirmation: Bool,
        externalEffect: Bool,
        reasons: [SafeAutomationPolicyReason] = [],
        blockedFacts: [String] = [],
        degradedFacts: [String] = [],
        localCommit: SideEffectLocalCommitEvidence? = nil,
        requestID: String? = nil
    ) async -> SideEffectAttempt? {
        return await eventKitOutbox.recordCalendarSideEffect(
            actionKind: actionKind,
            status: status,
            boundary: boundary,
            requiresConfirmation: requiresConfirmation,
            externalEffect: externalEffect,
            reasons: reasons,
            blockedFacts: blockedFacts,
            degradedFacts: degradedFacts,
            localCommit: localCommit,
            requestID: requestID
        )
    }

    @discardableResult
    func recordCalendarResult(
        _ result: SideEffectAttemptResult,
        for attempt: SideEffectAttempt?,
        now: Date
    ) async -> SideEffectReceipt? {
        await eventKitOutbox.recordCalendarResult(result, for: attempt, now: now)
    }

    func makeReminder(
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

func normalizedBusyWindows(
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
