import XCTest
@testable import Ambitions

final class EventKitIntegrationServiceTests: XCTestCase {
    func testCreateReminderFailsWhenAuthorizationDenied() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .denied, for: .reminders)
        let service = EventKitIntegrationService(storeClient: store)

        do {
            _ = try await service.createReminder(for: fixtureSelection(), now: fixtureNow())
            XCTFail("Expected denied authorization to throw.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .authorizationDenied(scope: .reminders))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testCreateReminderRequestsAuthorizationAndSavesPayload() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .notDetermined, for: .reminders)
        await store.setAuthorizationResponse(state: .fullAccess, for: .reminders)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        let record = try await service.createReminder(
            for: fixtureSelection(),
            now: fixtureNow(),
            localCommit: runtimeLocalCommitEvidence("reminder")
        )
        let payload = await store.lastReminderPayload

        XCTAssertEqual(record.identifier, "reminder-1")
        XCTAssertEqual(record.title, "Draft conference abstract")
        XCTAssertEqual(payload?.title, "Draft conference abstract")
        XCTAssertEqual(payload?.dueDate, fixtureSuggestedDate())
        XCTAssertTrue(payload?.notes.contains("Created by Ambitions after an explicit reminder request.") == true)
        XCTAssertTrue(payload?.notes.contains("Ambitions step ID: step-1") == true)
        XCTAssertFalse(payload?.notes.contains("Ship CFP proposal") == true)
        XCTAssertFalse(payload?.notes.contains("First concrete draft") == true)
    }

    func testCreateReminderPersistsLocalReminderObjectWhenRepositoryIsAvailable() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .reminders)
        let reminderRepository = try await makeReminderRepository()
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger)),
            reminderRepository: reminderRepository
        )

        let record = try await service.createReminder(
            for: fixtureSelection(),
            now: fixtureNow(),
            localCommit: runtimeLocalCommitEvidence("reminder-persist")
        )
        let loadedReminder = try await reminderRepository.reminder(id: record.identifier)
        let loaded = try XCTUnwrap(loadedReminder)

        XCTAssertEqual(record.identifier, "reminder-1")
        XCTAssertEqual(loaded.title, "Draft conference abstract")
        XCTAssertEqual(loaded.sourceRecordID, "source.reminder.reminder-1")
        XCTAssertEqual(loaded.localReminderSourceRecordID, "SourceRecord.reminder.reminder-1")
        XCTAssertEqual(loaded.sourceSurfaceTitle, "Search Ambitions")
        XCTAssertTrue(loaded.localReminderYouInspectionSummary.contains("Search Ambitions"))
        XCTAssertEqual(loaded.receiptID, "Receipt.reminder.reminder-1.save")
        XCTAssertEqual(loaded.replayTraceID, "ReplayTrace.reminder.reminder-1.save")
        XCTAssertTrue(loaded.state.isActive)
        XCTAssertFalse(loaded.state.isTerminal)
        XCTAssertTrue(loaded.deliveryPolicy.usesLocalNotificationDelivery)
    }

    func testCreateReminderRequiresLocalCommitReceiptBeforeSaving() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .reminders)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        do {
            _ = try await service.createReminder(for: fixtureSelection(), now: fixtureNow())
            XCTFail("Expected missing local commit receipt to throw.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .missingLocalCommitReceipt(scope: .reminders))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let payload = await store.lastReminderPayload
        let record = await sideEffectLedger.lastRecord
        XCTAssertNil(payload)
        XCTAssertEqual(record?.effectKind, .calendar)
        XCTAssertEqual(record?.status, .blocked)
        XCTAssertEqual(record?.boundary, .externalEffect)
        XCTAssertEqual(record?.externalEffect, true)
        XCTAssertTrue(record?.blockedFacts.contains("External side effect cannot be attempted before a committed local mutation receipt.") == true)
    }

    func testDetectConflictsReturnsOverlappingEventsAndNearbyRoom() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let overlap = EventKitCalendarEventSnapshot(
            title: "Team standup",
            startDate: fixtureSuggestedDate().addingTimeInterval(-300),
            endDate: fixtureSuggestedDate().addingTimeInterval(1_200),
            isAllDay: false
        )
        let nonOverlap = EventKitCalendarEventSnapshot(
            title: "Evening run",
            startDate: fixtureSuggestedDate().addingTimeInterval(10_800),
            endDate: fixtureSuggestedDate().addingTimeInterval(11_400),
            isAllDay: false
        )
        await store.setEvents([overlap, nonOverlap])
        let service = EventKitIntegrationService(storeClient: store)

        let report = await service.detectConflicts(for: fixtureSelection(), durationMinutes: 45, now: fixtureNow())

        XCTAssertEqual(report?.conflicts.count, 1)
        XCTAssertEqual(report?.conflicts.first?.title, "Team standup")
        XCTAssertEqual(report?.pressure, .low)
        XCTAssertNotNil(report?.nearbyAvailableWindow)
    }

    func testDetectConflictsReturnsNilWithoutCalendarReadContext() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .writeOnly, for: .calendarEvents)
        await store.setEvents([
            EventKitCalendarEventSnapshot(
                title: "Team standup",
                startDate: fixtureSuggestedDate().addingTimeInterval(-300),
                endDate: fixtureSuggestedDate().addingTimeInterval(1_200),
                isAllDay: false
            )
        ])
        let service = EventKitIntegrationService(storeClient: store)

        let report = await service.detectConflicts(for: fixtureSelection(), durationMinutes: 45, now: fixtureNow())

        XCTAssertNil(report)
    }

    func testDetectConflictsDerivesHighPressureWhenDayIsPacked() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let start = fixtureSuggestedDate()
        await store.setEvents([
            EventKitCalendarEventSnapshot(title: "Block 1", startDate: start, endDate: start.addingTimeInterval(2 * 3_600), isAllDay: false),
            EventKitCalendarEventSnapshot(title: "Block 2", startDate: start.addingTimeInterval(2.25 * 3_600), endDate: start.addingTimeInterval(4.25 * 3_600), isAllDay: false),
            EventKitCalendarEventSnapshot(title: "Block 3", startDate: start.addingTimeInterval(4.5 * 3_600), endDate: start.addingTimeInterval(6.5 * 3_600), isAllDay: false)
        ])
        let service = EventKitIntegrationService(storeClient: store)

        let report = await service.detectConflicts(for: fixtureSelection(), durationMinutes: 45, now: fixtureNow())

        XCTAssertEqual(report?.pressure, .high)
    }

    func testFetchDerivedBusyWindowsNormalizesAllDayEventsForCalendarDayBoundariesAndDSTAwareness() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        guard let timezone = TimeZone(identifier: "America/New_York") else {
            return XCTFail("Missing New York timezone")
        }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timezone
        let allDayStart = calendar.date(
            from: DateComponents(year: 2026, month: 3, day: 8, hour: 10)
        ) ?? Date()
        let allDayEnd = calendar.date(
            from: DateComponents(year: 2026, month: 3, day: 11, hour: 10)
        ) ?? Date()
        await store.setEvents([
            EventKitCalendarEventSnapshot(
                title: "DST-sensitive planning window",
                startDate: allDayStart,
                endDate: allDayEnd,
                isAllDay: true
            )
        ])
        let service = EventKitIntegrationService(storeClient: store, calendar: calendar)
        let queryStart = calendar.startOfDay(for: allDayStart)
        let queryRange = DateInterval(
            start: queryStart,
            end: calendar.date(byAdding: .day, value: 6, to: queryStart) ?? queryStart
        )

        let windows = await service.fetchDerivedBusyWindows(for: queryRange)

        XCTAssertEqual(windows.count, 3)
        let startOfDay = queryStart
        let secondStart = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay
        let thirdStart = calendar.date(byAdding: .day, value: 2, to: startOfDay) ?? startOfDay
        let fourthStart = calendar.date(byAdding: .day, value: 3, to: startOfDay) ?? startOfDay
        XCTAssertEqual(windows[0].start, startOfDay)
        XCTAssertEqual(windows[1].start, secondStart)
        XCTAssertEqual(windows[2].start, thirdStart)
        XCTAssertEqual(windows.last?.end, fourthStart)
        XCTAssertEqual(windows[0].interval.duration, TimeInterval(23 * 60 * 60), accuracy: 0.001)
        XCTAssertTrue(windows.allSatisfy { $0.title == "Calendar all-day busy time" })
    }

    func testCreateCalendarEventFailsWhenStepHasNoSuggestedDate() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )
        let selection = NextStepSchedulingSelection(
            goalID: "goal-1",
            goalTitle: "Ship CFP proposal",
            stepID: "step-1",
            stepTitle: "Draft conference abstract",
            stepSummary: "First concrete draft.",
            suggestedDate: nil
        )

        do {
            _ = try await service.createCalendarEvent(for: selection, durationMinutes: 45, now: fixtureNow())
            XCTFail("Expected missing date to throw.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .missingEventStartDate)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(record?.effectKind, .calendar)
        XCTAssertEqual(record?.status, .failedSafely)
        XCTAssertEqual(record?.boundary, .localOnly)
        XCTAssertEqual(record?.actionKind, .writeCalendarBlock)
        XCTAssertTrue(record?.degradedFacts.contains("Calendar event write request lacked a concrete time.") == true)
        XCTAssertFalse(record?.blockedFacts.contains("Draft conference abstract") == true)
    }

    func testCreateCalendarEventFailsWhenAuthorizationDeniedAndDoesNotSave() async {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .denied, for: .calendarEvents)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        do {
            _ = try await service.createCalendarEvent(for: fixtureSelection(), durationMinutes: 45, now: fixtureNow())
            XCTFail("Expected denied authorization to throw.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .authorizationDenied(scope: .calendarEvents))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let saveCount = await store.currentSaveEventCount()
        XCTAssertEqual(saveCount, 0)

        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(record?.effectKind, .calendar)
        XCTAssertEqual(record?.status, .blocked)
        XCTAssertEqual(record?.boundary, .externalEffect)
        XCTAssertEqual(record?.actionKind, .writeCalendarBlock)
        XCTAssertEqual(record?.requiresConfirmation, true)
        XCTAssertEqual(record?.externalEffect, true)
        XCTAssertTrue(record?.blockedFacts.contains("Calendar write permission was not available for this requested calendar event.") == true)
    }

    func testCreateCalendarEventRequiresLocalCommitReceiptBeforeSaving() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        do {
            _ = try await service.createCalendarEvent(for: fixtureSelection(), durationMinutes: 45, now: fixtureNow())
            XCTFail("Expected missing local commit receipt to throw.")
        } catch let error as CalendarRemindersError {
            XCTAssertEqual(error, .missingLocalCommitReceipt(scope: .calendarEvents))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        let saveCount = await store.currentSaveEventCount()
        let record = await sideEffectLedger.lastRecord
        XCTAssertEqual(saveCount, 0)
        XCTAssertEqual(record?.effectKind, .calendar)
        XCTAssertEqual(record?.status, .blocked)
        XCTAssertEqual(record?.boundary, .externalEffect)
        XCTAssertEqual(record?.externalEffect, true)
        XCTAssertTrue(record?.blockedFacts.contains("External side effect cannot be attempted before a committed local mutation receipt.") == true)
    }

    func testCreateCalendarEventSuccessRecordsCalendarSideEffect() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        let record = try await service.createCalendarEvent(
            for: fixtureSelection(),
            durationMinutes: 45,
            now: fixtureNow(),
            localCommit: runtimeLocalCommitEvidence("calendar-event")
        )

        let records = await sideEffectLedger.records
        let queuedSideEffect = records.first { $0.status == .queued }
        let succeededSideEffect = records.first { $0.status == .succeeded }

        XCTAssertEqual(record.identifier, "event-1")
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(queuedSideEffect?.effectKind, .calendar)
        XCTAssertEqual(queuedSideEffect?.boundary, .externalEffect)
        XCTAssertEqual(queuedSideEffect?.actionKind, .writeCalendarBlock)
        XCTAssertEqual(queuedSideEffect?.sourceDomain, .time)
        XCTAssertEqual(queuedSideEffect?.requiresConfirmation, false)
        XCTAssertEqual(queuedSideEffect?.externalEffect, true)
        XCTAssertTrue(queuedSideEffect?.reasons.contains(.externalSideEffect) == true)
        XCTAssertEqual(succeededSideEffect?.effectKind, .calendar)
        XCTAssertEqual(succeededSideEffect?.boundary, .externalEffect)
        XCTAssertEqual(succeededSideEffect?.actionKind, .writeCalendarBlock)
        XCTAssertEqual(succeededSideEffect?.sourceDomain, .time)
        XCTAssertEqual(succeededSideEffect?.requiresConfirmation, false)
        XCTAssertEqual(succeededSideEffect?.externalEffect, true)
        XCTAssertTrue(succeededSideEffect?.reasons.contains(.externalSideEffect) == true)
        XCTAssertFalse(records.contains { $0.blockedFacts.contains("Draft conference abstract") })
    }

    func testRepeatedCalendarEventSuccessesRecordDistinctLedgerEntries() async throws {
        let store = RecordingEventKitStoreClient()
        await store.setAuthorization(state: .fullAccess, for: .calendarEvents)
        let sideEffectLedger = RecordingSideEffectLedgerRepository()
        let service = EventKitIntegrationService(
            storeClient: store,
            eventKitOutbox: EventKitOutbox(recorder: SideEffectOutbox(ledger: sideEffectLedger))
        )

        _ = try await service.createCalendarEvent(
            for: fixtureSelection(),
            durationMinutes: 45,
            now: fixtureNow(),
            localCommit: runtimeLocalCommitEvidence("calendar-event-repeat-1")
        )
        _ = try await service.createCalendarEvent(
            for: fixtureSelection(),
            durationMinutes: 45,
            now: fixtureNow(),
            localCommit: runtimeLocalCommitEvidence("calendar-event-repeat-2")
        )

        let records = await sideEffectLedger.records
        XCTAssertEqual(records.count, 4)
        XCTAssertEqual(Set(records.map(\.id)).count, 4)
        XCTAssertTrue(records.allSatisfy { $0.effectKind == .calendar })
        XCTAssertEqual(records.filter { $0.status == .queued }.count, 2)
        XCTAssertEqual(records.filter { $0.status == .succeeded }.count, 2)
        XCTAssertTrue(records.allSatisfy { $0.externalEffect })
    }
}

private extension EventKitIntegrationServiceTests {
    func makeReminderRepository() async throws -> SwiftDataReminderRepository {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return SwiftDataReminderRepository(store: store)
    }

    func fixtureNow() -> Date {
        Date(timeIntervalSince1970: 1_713_180_000)
    }

    func fixtureSuggestedDate() -> Date {
        fixtureNow().addingTimeInterval(3_600)
    }

    func fixtureSelection() -> NextStepSchedulingSelection {
        NextStepSchedulingSelection(
            goalID: "goal-1",
            goalTitle: "Ship CFP proposal",
            stepID: "step-1",
            stepTitle: "Draft conference abstract",
            stepSummary: "First concrete draft.",
            suggestedDate: fixtureSuggestedDate()
        )
    }

    func runtimeLocalCommitEvidence(_ suffix: String) -> SideEffectLocalCommitEvidence {
        SideEffectLocalCommitEvidence(
            receiptID: "runtime.commit-receipt.\(suffix)",
            writeScope: .localSwiftDataSingleContext,
            committedAt: "2026-04-16T09:00:00Z",
            didCommitChanges: true,
            sideEffectPolicy: AppUnitOfWorkReceipt.noExternalSideEffects,
            runtimeTransactionID: "runtime.transaction.\(suffix)",
            runtimeEventID: "runtime.event.\(suffix)",
            runtimeReceiptID: "runtime.receipt.\(suffix)",
            rollbackPlanID: "runtime.rollback.\(suffix)"
        )
    }
}

private actor RecordingEventKitStoreClient: EventKitStoreClient {
    private var authorizationByScope: [String: CalendarRemindersAuthorizationState] = [:]
    private var authorizationResponseByScope: [String: CalendarRemindersAuthorizationState] = [:]
    private(set) var lastReminderPayload: EventKitReminderPayload?
    private(set) var lastEventPayload: EventKitEventPayload?
    private(set) var saveEventCount = 0
    private var events: [EventKitCalendarEventSnapshot] = []

    func authorizationState(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        authorizationByScope[key(for: scope)] ?? .notDetermined
    }

    func requestAuthorization(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        let response = authorizationResponseByScope[key(for: scope)] ?? .denied
        authorizationByScope[key(for: scope)] = response
        return response
    }

    func requestWriteOnlyAuthorizationForEvents() async -> CalendarRemindersAuthorizationState {
        let response = authorizationResponseByScope[key(for: .calendarEvents)] ?? .denied
        authorizationByScope[key(for: .calendarEvents)] = response
        return response
    }

    func saveReminder(_ payload: EventKitReminderPayload) async throws -> String {
        lastReminderPayload = payload
        return "reminder-1"
    }

    func saveEvent(_ payload: EventKitEventPayload) async throws -> String {
        saveEventCount += 1
        lastEventPayload = payload
        return "event-1"
    }

    func fetchEvents(in interval: DateInterval) async -> [EventKitCalendarEventSnapshot] {
        events.filter { $0.startDate < interval.end && $0.endDate > interval.start }
    }

    func setAuthorization(state: CalendarRemindersAuthorizationState, for scope: CalendarRemindersScope) {
        authorizationByScope[key(for: scope)] = state
    }

    func setAuthorizationResponse(state: CalendarRemindersAuthorizationState, for scope: CalendarRemindersScope) {
        authorizationResponseByScope[key(for: scope)] = state
    }

    func setEvents(_ events: [EventKitCalendarEventSnapshot]) {
        self.events = events
    }

    func currentSaveEventCount() -> Int {
        saveEventCount
    }

    private func key(for scope: CalendarRemindersScope) -> String {
        switch scope {
        case .reminders:
            return "reminders"
        case .calendarEvents:
            return "calendar-events"
        }
    }
}

private actor RecordingSideEffectLedgerRepository: SideEffectLedgerRepository {
    private(set) var records: [SideEffectLedgerRecord] = []

    var lastRecord: SideEffectLedgerRecord? {
        records.first
    }

    func append(_ record: SideEffectLedgerRecord) async throws {
        records.removeAll { $0.id == record.id }
        records.append(record)
    }

    func fetchRecent(limit: Int) async throws -> [SideEffectLedgerRecord] {
        Array(records.sorted(by: Self.sort).prefix(max(0, limit)))
    }

    func fetchRecords(status: SideEffectLedgerStatus) async throws -> [SideEffectLedgerRecord] {
        records.filter { $0.status == status }.sorted(by: Self.sort)
    }

    func fetchRecord(id: String) async throws -> SideEffectLedgerRecord? {
        records.first { $0.id == id }
    }

    private static func sort(_ lhs: SideEffectLedgerRecord, _ rhs: SideEffectLedgerRecord) -> Bool {
        if lhs.occurredAt != rhs.occurredAt {
            return lhs.occurredAt > rhs.occurredAt
        }
        return lhs.id < rhs.id
    }
}
