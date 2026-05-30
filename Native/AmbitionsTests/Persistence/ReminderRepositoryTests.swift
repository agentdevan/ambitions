import XCTest
@testable import Ambitions

final class ReminderRepositoryTests: XCTestCase {
    func testSwiftDataRepositoryRoundTripsReminderTriggerSourceAttachmentAndYouInspectionMetadata() async throws {
        let repository = try await makeRepository()
        let reminder = makeReminder(
            id: "reminder-1",
            state: .scheduled,
            triggerKind: .stepAttachment,
            deliveryPolicy: .inAppAndLocalNotification,
            receiptID: "Receipt.reminder.reminder-1.save",
            replayTraceID: "ReplayTrace.reminder.reminder-1.save"
        )

        try await repository.saveReminders([reminder])

        let loadedReminder = try await repository.reminder(id: reminder.id)
        let loaded = try XCTUnwrap(loadedReminder)
        let loadedReminders = try await repository.listReminders()

        XCTAssertEqual(loaded, reminder)
        XCTAssertEqual(loadedReminders, [reminder])
        XCTAssertEqual(loaded.sourceRecordID, reminder.sourceRecordID)
        XCTAssertEqual(loaded.sourceRecordLabel, "Tomorrow at 9 reminder")
        XCTAssertEqual(loaded.sourceSurfaceTitle, "What Ambitions knows")
        XCTAssertEqual(loaded.sourceInspectionSummary, "You / What Ambitions knows can inspect this SourceRecord, Receipt, and ReplayTrace.")
        XCTAssertEqual(loaded.inspectionBoundary.surfaceTitle, "What Ambitions knows")
        XCTAssertTrue(loaded.inspectionBoundary.isInspectableBoundary)
        XCTAssertTrue(loaded.localReminderYouInspectionSummary.contains("What Ambitions knows"))
        XCTAssertEqual(loaded.localReminderSourceRecordID, "SourceRecord.reminder.reminder-1")
        XCTAssertEqual(loaded.localReminderReceiptID(action: "save"), "Receipt.reminder.reminder-1.save")
        XCTAssertEqual(loaded.localReminderReplayTraceID(action: "save"), "ReplayTrace.reminder.reminder-1.save")
        XCTAssertTrue(loaded.deliveryPolicy.usesLocalNotificationDelivery)
        XCTAssertTrue(loaded.state.isActive)
        XCTAssertFalse(loaded.state.isTerminal)
    }

    func testSwiftDataRepositoryRoundTripsRecurringWaitingFollowUpReminderMetadataAndStateHelpers() async throws {
        let repository = try await makeRepository()
        let reminder = makeReminder(
            id: "reminder-recurring",
            state: .blocked,
            triggerKind: .recurring,
            deliveryPolicy: .hybrid,
            receiptID: "Receipt.reminder.reminder-recurring.save",
            replayTraceID: "ReplayTrace.reminder.reminder-recurring.save",
            notes: [
                "recurrence: every Monday",
                "blocked by: approval",
                "follow up: follow up Friday at 9"
            ]
        )

        try await repository.saveReminders([reminder])

        let loadedReminderRecord = try await repository.reminder(id: reminder.id)
        let loadedReminder = try XCTUnwrap(loadedReminderRecord)

        XCTAssertEqual(loadedReminder, reminder)
        XCTAssertEqual(loadedReminder.recurrenceRule, "every Monday")
        XCTAssertEqual(loadedReminder.waitingOn, "approval")
        XCTAssertEqual(loadedReminder.followUpText, "follow up Friday at 9")
        XCTAssertTrue(loadedReminder.isRecurringObligation)
        XCTAssertTrue(loadedReminder.hasWaitingFollowUp)

        let rescheduled = loadedReminder.rescheduled(to: "2026-05-27T09:00:00Z", updatedAt: "2026-05-26T08:30:00Z")
        XCTAssertEqual(rescheduled.triggerAt, "2026-05-27T09:00:00Z")
        XCTAssertEqual(rescheduled.state, .scheduled)
        XCTAssertEqual(rescheduled.recurrenceRule, loadedReminder.recurrenceRule)
        XCTAssertEqual(rescheduled.waitingOn, loadedReminder.waitingOn)
        XCTAssertEqual(rescheduled.followUpText, loadedReminder.followUpText)

        let snoozed = loadedReminder.snoozed(until: "2026-05-26T11:00:00Z", updatedAt: "2026-05-26T10:00:00Z")
        XCTAssertEqual(snoozed.triggerAt, "2026-05-26T11:00:00Z")
        XCTAssertEqual(snoozed.state, .snoozed)

        let missed = loadedReminder.markedMissedTrigger(updatedAt: "2026-05-27T10:00:00Z")
        XCTAssertEqual(missed.state, .needsRecovery)

        let blocked = loadedReminder.blockedFollowUp(triggerAt: "2026-05-27T09:00:00Z", updatedAt: "2026-05-26T10:15:00Z")
        XCTAssertEqual(blocked.state, .blocked)
    }

    func testSwiftDataRepositoryDeletesAttachedRemindersAndKeepsDeletedRecordInExportSnapshot() async throws {
        let repository = try await makeRepository()
        let reminder = makeReminder(id: "reminder-delete", state: .scheduled)

        try await repository.saveReminders([reminder])
        try await repository.deleteReminders(attachedTo: reminder.attachedObjectID ?? "")

        let activeReminders = try await repository.listReminders()
        let deletedReminder = try await repository.reminder(id: reminder.id)
        let export = try await repository.exportReminders()

        XCTAssertTrue(activeReminders.isEmpty)
        XCTAssertNil(deletedReminder)
        XCTAssertEqual(export.schemaVersion, reminderRepositoryExportSchemaVersion)
        XCTAssertEqual(export.reminders.count, 1)
        XCTAssertTrue(export.reminders.first?.isDeleted ?? false)
        XCTAssertEqual(export.reminders.first?.state, .deleted)
    }

    func testSwiftDataRepositoryImportsReminderExportIntoFreshStore() async throws {
        let sourceRepository = try await makeRepository()
        let reminder = makeReminder(
            id: "reminder-import",
            state: .scheduled,
            triggerKind: .stepAttachment,
            deliveryPolicy: .hybrid,
            receiptID: "Receipt.reminder.reminder-import.save",
            replayTraceID: "ReplayTrace.reminder.reminder-import.save"
        )

        try await sourceRepository.saveReminders([reminder])
        let export = try await sourceRepository.exportReminders()

        let importedRepository = try await makeRepository()
        try await importedRepository.importReminders(export)

        let importedReminderRecord = try await importedRepository.reminder(id: reminder.id)
        let importedReminder = try XCTUnwrap(importedReminderRecord)

        XCTAssertEqual(importedReminder, reminder)
        let importedExport = try await importedRepository.exportReminders()
        XCTAssertEqual(importedExport.reminders.first, reminder)
    }
}

private extension ReminderRepositoryTests {
    func makeRepository() async throws -> SwiftDataReminderRepository {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return SwiftDataReminderRepository(store: store)
    }

    func makeReminder(
        id: String,
        state: ReminderState,
        triggerKind: ReminderTriggerKind = .manual,
        deliveryPolicy: ReminderDeliveryPolicy = .inAppAndLocalNotification,
        receiptID: String? = nil,
        replayTraceID: String? = nil,
        notes: [String] = []
    ) -> ReminderTrigger {
        let sourceRecord = ReminderSourceRecord(
            id: "source.reminder.\(id)",
            entityTitle: "Tomorrow at 9 reminder",
            locator: "local://reminders/\(id)",
            provenanceKind: .step,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .step,
            id: "step.\(id)",
            label: "Tomorrow at 9",
            sourceDomain: .today
        )
        let source = ReminderSource(
            record: sourceRecord,
            sourceObject: sourceObject,
            surfaceTitle: "What Ambitions knows",
            inspectionSummary: "You / What Ambitions knows can inspect this SourceRecord, Receipt, and ReplayTrace.",
            notes: notes
        )
        let attachment = ReminderAttachment(
            kind: .step,
            object: sourceObject,
            note: "Attached to the next step"
        )

        return ReminderTrigger(
            id: id,
            createdAt: "2026-05-24T08:00:00Z",
            updatedAt: "2026-05-24T08:05:00Z",
            title: "Tomorrow at 9",
            summary: "Local reminder trigger.",
            triggerAt: "2026-05-25T09:00:00Z",
            kind: triggerKind,
            deliveryPolicy: deliveryPolicy,
            state: state,
            source: source,
            attachment: attachment,
            receiptID: receiptID,
            replayTraceID: replayTraceID
        )
    }
}
