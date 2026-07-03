import AmbitionsDesignSystem
import Foundation
import SwiftData

struct SwiftDataReminderRepository: ReminderRepository {
    let store: AmbitionsPersistenceStore

    func listReminders() async throws -> [ReminderTrigger] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<ReminderRecord>())
                .filter { $0.deletedAt == nil && $0.stateRaw != ReminderState.deleted.rawValue }
                .sorted {
                    if $0.updatedAt != $1.updatedAt {
                        return $0.updatedAt > $1.updatedAt
                    }
                    return $0.id < $1.id
                }
                .bounded(to: RepositoryQueryBudget.maxReminderListResults)
                .map(RepositoryMapping.reminder(from:))
        }
    }

    func reminder(id: String) async throws -> ReminderTrigger? {
        try await store.read { context in
            try context.fetch(FetchDescriptor<ReminderRecord>())
                .first(where: { $0.id == id && $0.deletedAt == nil && $0.stateRaw != ReminderState.deleted.rawValue })
                .map(RepositoryMapping.reminder(from:))
        }
    }

    func saveReminders(_ reminders: [ReminderTrigger]) async throws {
        try await store.write { context in
            let existing = Dictionary(
                uniqueKeysWithValues: try context.fetch(FetchDescriptor<ReminderRecord>()).map { ($0.id, $0) }
            )

            for reminder in reminders {
                if let persisted = existing[reminder.id] {
                    try apply(reminder, to: persisted)
                } else {
                    context.insert(try RepositoryMapping.reminderRecord(from: reminder))
                }
            }
        }
    }

    func deleteReminder(id: String, at timestamp: String) async throws {
        try await store.write { context in
            guard let record = try context.fetch(FetchDescriptor<ReminderRecord>()).first(where: { $0.id == id }) else {
                return
            }

            if let reminder = try? RepositoryMapping.reminder(from: record) {
                let deleted = ReminderTrigger(
                    id: reminder.id,
                    createdAt: reminder.createdAt,
                    updatedAt: timestamp,
                    title: reminder.title,
                    summary: reminder.summary,
                    triggerAt: reminder.triggerAt,
                    kind: reminder.kind,
                    deliveryPolicy: reminder.deliveryPolicy,
                    state: .deleted,
                    source: reminder.source,
                    attachment: reminder.attachment,
                    receiptID: reminder.receiptID,
                    replayTraceID: reminder.replayTraceID,
                    deletedAt: timestamp,
                    schemaVersion: reminder.schemaVersion
                )
                try apply(deleted, to: record)
                record.deletedAt = timestamp
            } else {
                record.deletedAt = timestamp
                record.stateRaw = ReminderState.deleted.rawValue
                record.updatedAt = timestamp
            }
        }
    }

    func deleteReminders(attachedTo objectID: String) async throws {
        try await store.write { context in
            let records = try context.fetch(FetchDescriptor<ReminderRecord>())
            for record in records where record.attachedObjectID == objectID && record.deletedAt == nil {
                if let reminder = try? RepositoryMapping.reminder(from: record) {
                    let deleted = ReminderTrigger(
                        id: reminder.id,
                        createdAt: reminder.createdAt,
                        updatedAt: reminder.updatedAt,
                        title: reminder.title,
                        summary: reminder.summary,
                        triggerAt: reminder.triggerAt,
                        kind: reminder.kind,
                        deliveryPolicy: reminder.deliveryPolicy,
                        state: .deleted,
                        source: reminder.source,
                        attachment: reminder.attachment,
                        receiptID: reminder.receiptID,
                        replayTraceID: reminder.replayTraceID,
                        deletedAt: reminder.updatedAt,
                        schemaVersion: reminder.schemaVersion
                    )
                    try apply(deleted, to: record)
                    record.deletedAt = reminder.updatedAt
                } else {
                    let now = record.updatedAt
                    record.deletedAt = now
                    record.stateRaw = ReminderState.deleted.rawValue
                    record.updatedAt = now
                }
            }
        }
    }

    func exportReminders() async throws -> ReminderRepositoryExport {
        try await store.read { context in
            let reminders = try context.fetch(FetchDescriptor<ReminderRecord>())
                .sorted {
                    if $0.updatedAt != $1.updatedAt {
                        return $0.updatedAt > $1.updatedAt
                    }
                    return $0.id > $1.id
                }
                .compactMap { try? RepositoryMapping.reminder(from: $0) }

            return ReminderRepositoryExport(
                exportedAt: ISO8601DateFormatter().string(from: .now),
                reminders: reminders
            )
        }
    }

    func importReminders(_ export: ReminderRepositoryExport) async throws {
        try await saveReminders(export.reminders)
    }

    func apply(_ reminder: ReminderTrigger, to record: ReminderRecord) throws {
        let reminderRecord = try RepositoryMapping.reminderRecord(from: reminder)
        record.schemaVersion = reminderRecord.schemaVersion
        record.createdAt = reminderRecord.createdAt
        record.updatedAt = reminderRecord.updatedAt
        record.deletedAt = reminderRecord.deletedAt
        record.title = reminderRecord.title
        record.summaryText = reminderRecord.summaryText
        record.triggerAt = reminderRecord.triggerAt
        record.kindRaw = reminderRecord.kindRaw
        record.stateRaw = reminderRecord.stateRaw
        record.receiptID = reminderRecord.receiptID
        record.replayTraceID = reminderRecord.replayTraceID
        record.sourceRecordID = reminderRecord.sourceRecordID
        record.attachedObjectID = reminderRecord.attachedObjectID
        record.deliveryPolicyData = reminderRecord.deliveryPolicyData
        record.sourceData = reminderRecord.sourceData
        record.attachmentData = reminderRecord.attachmentData
        record.snapshotData = reminderRecord.snapshotData
    }
}
