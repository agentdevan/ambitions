import Foundation

let reminderTriggerSchemaVersion = "reminder_trigger.native.v1"
let reminderRepositoryExportSchemaVersion = "reminder_repository_export.native.v1"

typealias SourceRecord = KnowledgeSourceRecord
typealias Receipt = ActionReceipt
typealias ReplayTrace = ReplayableDecisionTrace

enum ReminderTriggerKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case manual
    case stepAttachment = "step_attachment"
    case commitmentAttachment = "commitment_attachment"
    case imported
    case recurring
}

enum ReminderAttachmentKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case commitment
    case step
}

enum ReminderSourceKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case manual
    case commitment
    case step
    case imported
    case recurring
}

enum ReminderDeliveryPolicy: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localNotification = "local_notification"
    case inApp = "in_app"
    case inAppAndLocalNotification = "in_app_and_local_notification"
    case hybrid

    var usesLocalNotificationDelivery: Bool {
        switch self {
        case .localNotification, .inAppAndLocalNotification, .hybrid:
            return true
        case .inApp:
            return false
        }
    }

    var isLocalOnly: Bool {
        self == .localNotification
    }
}

enum ReminderState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case draft
    case scheduled
    case due
    case snoozed
    case waiting
    case blocked
    case completed
    case stillCounts = "still_counts"
    case notNeeded = "not_needed"
    case needsRecovery = "needs_recovery"
    case deleted

    var isActive: Bool {
        switch self {
        case .draft, .scheduled, .due, .snoozed, .waiting, .blocked:
            return true
        case .completed, .stillCounts, .notNeeded, .needsRecovery, .deleted:
            return false
        }
    }

    var isTerminal: Bool {
        switch self {
        case .completed, .stillCounts, .notNeeded, .needsRecovery, .deleted:
            return true
        case .draft, .scheduled, .due, .snoozed, .waiting, .blocked:
            return false
        }
    }

    var isDeleted: Bool {
        self == .deleted
    }
}

struct ReminderAttachment: Codable, Sendable, Equatable, Hashable {
    let kind: ReminderAttachmentKind
    let object: LifeGraphObjectReference
    let note: String?

    init(
        kind: ReminderAttachmentKind,
        object: LifeGraphObjectReference,
        note: String? = nil
    ) {
        self.kind = kind
        self.object = object
        self.note = Self.normalizedOptional(note)
    }

    var attachedObjectID: String {
        object.id
    }

    var attachedObjectReference: LifeGraphObjectReference {
        object
    }

    var isWellFormed: Bool {
        object.isWellFormed
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }
}

struct ReminderSourceRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let entityTitle: String
    let locator: String
    let provenanceKind: ReminderSourceKind
    let isOfficial: Bool

    init(
        id: String,
        entityTitle: String,
        locator: String,
        provenanceKind: ReminderSourceKind,
        isOfficial: Bool
    ) {
        self.id = Self.normalizedRequired(id)
        self.entityTitle = Self.normalizedRequired(entityTitle)
        self.locator = Self.normalizedRequired(locator)
        self.provenanceKind = provenanceKind
        self.isOfficial = isOfficial
    }

    var sourceRecordLabel: String {
        entityTitle
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct ReminderSource: Codable, Sendable, Equatable, Hashable {
    let record: ReminderSourceRecord
    let sourceObject: LifeGraphObjectReference
    let surfaceTitle: String
    let inspectionSummary: String
    let receipt: Receipt?
    let replayTrace: ReplayTrace?
    let notes: [String]

    init(
        record: ReminderSourceRecord,
        sourceObject: LifeGraphObjectReference,
        surfaceTitle: String,
        inspectionSummary: String,
        receipt: Receipt? = nil,
        replayTrace: ReplayTrace? = nil,
        notes: [String] = []
    ) {
        self.record = record
        self.sourceObject = sourceObject
        self.surfaceTitle = Self.normalizedRequired(surfaceTitle)
        self.inspectionSummary = Self.normalizedRequired(inspectionSummary)
        self.receipt = receipt
        self.replayTrace = replayTrace
        self.notes = Self.normalized(notes)
    }

    var kind: ReminderSourceKind {
        record.provenanceKind
    }

    var sourceRecordID: String {
        record.id
    }

    var sourceRecordLabel: String {
        record.entityTitle
    }

    var sourceSurfaceTitle: String {
        surfaceTitle
    }

    var sourceInspectionSummary: String {
        inspectionSummary
    }

    var receiptID: String? {
        receipt?.id
    }

    var replayTraceID: String? {
        replayTrace?.id
    }

    var localReminderYouInspectionSummary: String {
        "You / Search Ambitions can inspect this source, receipt, and reason."
    }

    var isWellFormed: Bool {
        record.id.isEmpty == false && sourceObject.isWellFormed && surfaceTitle.isEmpty == false && inspectionSummary.isEmpty == false
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

extension ReminderSource {
    var recurrenceRule: String? {
        noteValue(prefixes: ["recurrence: "])
    }

    var waitingOn: String? {
        noteValue(prefixes: ["waiting on: ", "blocked by: "])
    }

    var followUpText: String? {
        noteValue(prefixes: ["follow up: "])
    }

    private func noteValue(prefixes: [String]) -> String? {
        for prefix in prefixes {
            if let note = notes.first(where: { $0.lowercased().hasPrefix(prefix) }) {
                let valueStart = note.index(note.startIndex, offsetBy: prefix.count)
                let value = note[valueStart...].trimmingCharacters(in: .whitespacesAndNewlines)
                if value.isEmpty == false {
                    return value
                }
            }
        }
        return nil
    }
}

struct ReminderTrigger: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let title: String
    let summary: String?
    let triggerAt: String?
    let kind: ReminderTriggerKind
    let deliveryPolicy: ReminderDeliveryPolicy
    let state: ReminderState
    let source: ReminderSource
    let attachment: ReminderAttachment?
    let receiptID: String?
    let replayTraceID: String?
    let deletedAt: String?
    let schemaVersion: String

    init(
        id: String,
        createdAt: String,
        updatedAt: String,
        title: String,
        summary: String? = nil,
        triggerAt: String? = nil,
        kind: ReminderTriggerKind,
        deliveryPolicy: ReminderDeliveryPolicy,
        state: ReminderState,
        source: ReminderSource,
        attachment: ReminderAttachment? = nil,
        receiptID: String? = nil,
        replayTraceID: String? = nil,
        deletedAt: String? = nil,
        schemaVersion: String = reminderTriggerSchemaVersion
    ) {
        self.id = Self.normalizedRequired(id)
        self.createdAt = Self.normalizedRequired(createdAt)
        self.updatedAt = Self.normalizedRequired(updatedAt)
        self.title = Self.normalizedRequired(title)
        self.summary = Self.normalizedOptional(summary)
        self.triggerAt = Self.normalizedOptional(triggerAt)
        self.kind = kind
        self.deliveryPolicy = deliveryPolicy
        self.state = state
        self.source = source
        self.attachment = attachment
        self.receiptID = Self.normalizedOptional(receiptID)
        self.replayTraceID = Self.normalizedOptional(replayTraceID)
        self.deletedAt = Self.normalizedOptional(deletedAt)
        self.schemaVersion = Self.normalizedRequired(schemaVersion)
    }

    init(
        id: String,
        createdAt: String,
        updatedAt: String,
        title: String,
        summary: String? = nil,
        triggerAt: String? = nil,
        kind: ReminderTriggerKind,
        state: ReminderState,
        source: ReminderSource,
        attachment: ReminderAttachment? = nil,
        receiptID: String? = nil,
        replayTraceID: String? = nil,
        deletedAt: String? = nil,
        deliveryPolicy: ReminderDeliveryPolicy,
        schemaVersion: String = reminderTriggerSchemaVersion
    ) {
        self.init(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            title: title,
            summary: summary,
            triggerAt: triggerAt,
            kind: kind,
            deliveryPolicy: deliveryPolicy,
            state: state,
            source: source,
            attachment: attachment,
            receiptID: receiptID,
            replayTraceID: replayTraceID,
            deletedAt: deletedAt,
            schemaVersion: schemaVersion
        )
    }

    var sourceRecordID: String {
        source.sourceRecordID
    }

    var sourceRecordLabel: String {
        source.sourceRecordLabel
    }

    var sourceSurfaceTitle: String {
        source.sourceSurfaceTitle
    }

    var sourceInspectionSummary: String {
        source.sourceInspectionSummary
    }

    var sourceObjectID: String {
        source.sourceObject.id
    }

    var sourceObjectLabel: String? {
        source.sourceObject.label
    }

    var sourceObjectKind: LifeGraphObjectKind {
        source.sourceObject.kind
    }

    var sourceObjectDomain: LifeGraphSourceDomain? {
        source.sourceObject.sourceDomain
    }

    var attachedObjectID: String? {
        attachment?.attachedObjectID
    }

    var recurrenceRule: String? {
        source.recurrenceRule
    }

    var waitingOn: String? {
        source.waitingOn
    }

    var followUpText: String? {
        source.followUpText
    }

    var isRecurringObligation: Bool {
        kind == .recurring || recurrenceRule != nil
    }

    var hasWaitingFollowUp: Bool {
        waitingOn != nil || followUpText != nil || state == .waiting || state == .blocked
    }

    var dueAt: String? {
        triggerAt
    }

    var nextFireAt: String? {
        triggerAt
    }

    func advanceRecurringOccurrence(to nextTriggerAt: String, updatedAt newUpdatedAt: String) -> ReminderTrigger {
        remake(triggerAt: nextTriggerAt, state: .scheduled, updatedAt: newUpdatedAt)
    }

    func rescheduled(to newTriggerAt: String?, updatedAt newUpdatedAt: String) -> ReminderTrigger {
        remake(triggerAt: newTriggerAt, state: .scheduled, updatedAt: newUpdatedAt)
    }

    func snoozed(until newTriggerAt: String, updatedAt newUpdatedAt: String) -> ReminderTrigger {
        remake(triggerAt: newTriggerAt, state: .snoozed, updatedAt: newUpdatedAt)
    }

    func markedMissedTrigger(updatedAt newUpdatedAt: String) -> ReminderTrigger {
        remake(triggerAt: triggerAt, state: .needsRecovery, updatedAt: newUpdatedAt)
    }

    func waitingFollowUp(
        triggerAt newTriggerAt: String? = nil,
        state newState: ReminderState? = nil,
        updatedAt newUpdatedAt: String
    ) -> ReminderTrigger {
        remake(triggerAt: newTriggerAt ?? triggerAt, state: newState ?? state, updatedAt: newUpdatedAt)
    }

    func blockedFollowUp(
        triggerAt newTriggerAt: String? = nil,
        updatedAt newUpdatedAt: String
    ) -> ReminderTrigger {
        remake(triggerAt: newTriggerAt ?? triggerAt, state: .blocked, updatedAt: newUpdatedAt)
    }

    var localReminderSourceRecordID: String {
        "SourceRecord.reminder.\(id)"
    }

    func localReminderReceiptID(action: String) -> String {
        "Receipt.reminder.\(id).\(Self.normalizedRequired(action))"
    }

    func localReminderReplayTraceID(action: String) -> String {
        "ReplayTrace.reminder.\(id).\(Self.normalizedRequired(action))"
    }

    var localReminderYouInspectionSummary: String {
        "You / Search Ambitions can inspect this reminder, source, receipt, and reason."
    }

    var isDeleted: Bool {
        deletedAt != nil || state.isDeleted
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            createdAt.isEmpty == false &&
            updatedAt.isEmpty == false &&
            schemaVersion == reminderTriggerSchemaVersion &&
            source.isWellFormed &&
            (attachment?.isWellFormed ?? true)
    }

    var inspectionBoundary: ReminderYouInspectionBoundary {
        ReminderYouInspectionBoundary(
            surfaceTitle: sourceSurfaceTitle,
            sourceKnowledgeLabel: sourceInspectionSummary,
            allowsRawActivityLog: false
        )
    }

    private func remake(
        triggerAt newTriggerAt: String?,
        state newState: ReminderState?,
        updatedAt newUpdatedAt: String
    ) -> ReminderTrigger {
        ReminderTrigger(
            id: id,
            createdAt: createdAt,
            updatedAt: newUpdatedAt,
            title: title,
            summary: summary,
            triggerAt: newTriggerAt,
            kind: kind,
            deliveryPolicy: deliveryPolicy,
            state: newState ?? state,
            source: source,
            attachment: attachment,
            receiptID: receiptID,
            replayTraceID: replayTraceID,
            deletedAt: deletedAt,
            schemaVersion: schemaVersion
        )
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }
}

struct ReminderRepositoryExport: Codable, Sendable, Equatable {
    let schemaVersion: String
    let exportedAt: String
    let reminders: [ReminderTrigger]
    let localOnly: Bool

    init(
        schemaVersion: String = reminderRepositoryExportSchemaVersion,
        exportedAt: String,
        reminders: [ReminderTrigger],
        localOnly: Bool = true
    ) {
        self.schemaVersion = schemaVersion
        self.exportedAt = exportedAt
        self.reminders = reminders
        self.localOnly = localOnly
    }

    var isWellFormed: Bool {
        schemaVersion == reminderRepositoryExportSchemaVersion &&
            exportedAt.isEmpty == false &&
            reminders.allSatisfy(\.isWellFormed)
    }
}

struct ReminderYouInspectionBoundary: Codable, Sendable, Equatable, Hashable {
    let surfaceTitle: String
    let sourceKnowledgeLabel: String
    let allowsRawActivityLog: Bool

    init(
        surfaceTitle: String,
        sourceKnowledgeLabel: String,
        allowsRawActivityLog: Bool
    ) {
        self.surfaceTitle = Self.normalizedRequired(surfaceTitle)
        self.sourceKnowledgeLabel = Self.normalizedRequired(sourceKnowledgeLabel)
        self.allowsRawActivityLog = allowsRawActivityLog
    }

    var inspectionLabel: String {
        surfaceTitle
    }

    var blocksRawActivityLogCopy: Bool {
        allowsRawActivityLog == false
    }

    var isInspectableBoundary: Bool {
        surfaceTitle == "Search Ambitions" && allowsRawActivityLog == false
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
