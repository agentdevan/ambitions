import AmbitionsDesignSystem
import Foundation
import SwiftData

extension RepositoryMapping {

    static func feedbackRecord(from event: GoalFeedbackEvent, goalID: String) throws -> FeedbackEventRecord {
        let stored = StoredGoalFeedbackEvent(event: event)
        return FeedbackEventRecord(
            id: stored.base.id,
            goalID: goalID,
            stepID: stored.base.stepID,
            occurredAt: stored.base.occurredAt,
            kindRaw: stored.kind.rawValue,
            note: stored.base.note,
            payloadData: try PersistenceCoding.encode(stored)
        )
    }


    static func feedback(from record: FeedbackEventRecord) throws -> GoalFeedbackEvent {
        try PersistenceCoding.decode(StoredGoalFeedbackEvent.self, from: record.payloadData).event
    }


    static func captureRecord(from capture: Capture) throws -> CaptureRecord {
        CaptureRecord(
            id: capture.id,
            createdAt: capture.createdAt,
            updatedAt: capture.updatedAt,
            rawText: capture.rawText,
            sourceTypeRaw: capture.sourceType?.rawValue,
            statusRaw: capture.status.rawValue,
            linkedGoalID: capture.linkedGoalID,
            snapshotData: try PersistenceCoding.encode(capture)
        )
    }


    static func capture(from record: CaptureRecord) throws -> Capture {
        if let snapshot = try? PersistenceCoding.decode(Capture.self, from: record.snapshotData) {
            return snapshot
        }

        return Capture(
            id: record.id,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
            rawText: record.rawText,
            sourceType: persistedOptional(CaptureSourceType.self, rawValue: record.sourceTypeRaw, storedTypeName: "CaptureRecord", fieldName: "sourceTypeRaw"),
            status: captureStatus(from: record.statusRaw),
            linkedGoalID: record.linkedGoalID
        )
    }


    static func reminderRecord(from reminder: ReminderTrigger) throws -> ReminderRecord {
        return ReminderRecord(
            id: reminder.id,
            schemaVersion: reminder.schemaVersion,
            createdAt: reminder.createdAt,
            updatedAt: reminder.updatedAt,
            deletedAt: reminder.state == .deleted ? reminder.updatedAt : nil,
            title: reminder.title,
            summaryText: reminder.summary,
            triggerAt: reminder.triggerAt,
            kindRaw: reminder.kind.rawValue,
            stateRaw: reminder.state.rawValue,
            receiptID: reminder.receiptID,
            replayTraceID: reminder.replayTraceID,
            sourceRecordID: reminder.source.sourceRecordID,
            attachedObjectID: reminder.attachedObjectID,
            deliveryPolicyData: try PersistenceCoding.encode(reminder.deliveryPolicy),
            sourceData: try PersistenceCoding.encode(reminder.source),
            attachmentData: try reminder.attachment.map { try PersistenceCoding.encode($0) },
            snapshotData: try PersistenceCoding.encode(reminder)
        )
    }


    static func reminder(from record: ReminderRecord) throws -> ReminderTrigger {
        if let snapshot = try? PersistenceCoding.decode(ReminderTrigger.self, from: record.snapshotData) {
            return snapshot
        }

        let deliveryPolicy = try PersistenceCoding.decode(ReminderDeliveryPolicy.self, from: record.deliveryPolicyData)
        let source = try PersistenceCoding.decode(ReminderSource.self, from: record.sourceData)
        let attachment: ReminderAttachment?
        if let attachmentData = record.attachmentData {
            attachment = try PersistenceCoding.decode(ReminderAttachment.self, from: attachmentData)
        } else {
            attachment = nil
        }

        return ReminderTrigger(
            id: record.id,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
            title: record.title,
            summary: record.summaryText,
            triggerAt: record.triggerAt,
            kind: persisted(
                ReminderTriggerKind.self,
                rawValue: record.kindRaw,
                fallback: .manual,
                storedTypeName: "ReminderRecord",
                fieldName: "kindRaw"
            ),
            state: persisted(
                ReminderState.self,
                rawValue: record.stateRaw,
                fallback: .draft,
                storedTypeName: "ReminderRecord",
                fieldName: "stateRaw"
            ),
            source: source,
            attachment: attachment,
            receiptID: record.receiptID,
            replayTraceID: record.replayTraceID,
            deletedAt: record.deletedAt,
            deliveryPolicy: deliveryPolicy,
            schemaVersion: record.schemaVersion
        )
    }


    static func teachingSignalRecord(from signal: GoalTeachingSignal) throws -> TeachingSignalRecord {
        TeachingSignalRecord(
            id: signal.id,
            goalID: signal.goalID,
            kindRaw: signal.kind.rawValue,
            sourceRaw: signal.source.rawValue,
            dispositionRaw: signal.disposition.rawValue,
            applicationKey: signal.applicationKey,
            createdAt: signal.createdAt,
            updatedAt: signal.updatedAt,
            snapshotData: try PersistenceCoding.encode(signal)
        )
    }


    static func teachingSignal(from record: TeachingSignalRecord) throws -> GoalTeachingSignal {
        if let snapshot = try? PersistenceCoding.decode(GoalTeachingSignal.self, from: record.snapshotData) {
            return snapshot
        }

        throw PersistenceError.invalidStoredValue("Teaching signal snapshots must decode into GoalTeachingSignal.")
    }


    static func eventLedgerRecord(from event: EventLedgerEntry) throws -> EventLedgerRecord {
        EventLedgerRecord(
            id: event.id,
            kindRaw: event.kind.rawValue,
            occurredAt: event.occurredAt,
            occurredAtDate: PersistedTemporalValue.date(from: event.occurredAt),
            sourceRaw: event.source.rawValue,
            goalID: event.goalID,
            captureID: event.captureID,
            planID: event.planID,
            planScope: event.planScope,
            reviewID: event.reviewID,
            title: event.title,
            summaryText: event.summary,
            semanticState: event.semanticState,
            toneRaw: event.tone.rawValue,
            schemaVersion: event.schemaVersion,
            privacyRaw: event.privacy.rawValue,
            localOnly: event.localOnly,
            createdAt: event.createdAt,
            createdAtDate: PersistedTemporalValue.date(from: event.createdAt),
            updatedAt: event.updatedAt,
            updatedAtDate: PersistedTemporalValue.date(from: event.updatedAt),
            evidenceReferencesData: try PersistenceCoding.encode(event.evidenceReferences),
            metadataData: try PersistenceCoding.encode(event.metadata),
            payloadData: try PersistenceCoding.encode(event.payload),
            trustData: try PersistenceCoding.encode(event.trust),
            snapshotData: try PersistenceCoding.encode(event)
        )
    }


    static func apply(_ event: EventLedgerEntry, to record: EventLedgerRecord) throws {
        record.kindRaw = event.kind.rawValue
        record.occurredAt = event.occurredAt
        record.occurredAtDate = PersistedTemporalValue.date(from: event.occurredAt)
        record.sourceRaw = event.source.rawValue
        record.goalID = event.goalID
        record.captureID = event.captureID
        record.planID = event.planID
        record.planScope = event.planScope
        record.reviewID = event.reviewID
        record.title = event.title
        record.summaryText = event.summary
        record.semanticState = event.semanticState
        record.toneRaw = event.tone.rawValue
        record.schemaVersion = event.schemaVersion
        record.privacyRaw = event.privacy.rawValue
        record.localOnly = event.localOnly
        record.createdAt = event.createdAt
        record.createdAtDate = PersistedTemporalValue.date(from: event.createdAt)
        record.updatedAt = event.updatedAt
        record.updatedAtDate = PersistedTemporalValue.date(from: event.updatedAt)
        record.evidenceReferencesData = try PersistenceCoding.encode(event.evidenceReferences)
        record.metadataData = try PersistenceCoding.encode(event.metadata)
        record.payloadData = try PersistenceCoding.encode(event.payload)
        record.trustData = try PersistenceCoding.encode(event.trust)
        record.snapshotData = try PersistenceCoding.encode(event)
    }


    static func eventLedgerEntry(from record: EventLedgerRecord) throws -> EventLedgerEntry {
        if let snapshot = try? PersistenceCoding.decode(EventLedgerEntry.self, from: record.snapshotData) {
            return snapshot
        }

        return EventLedgerEntry(
            id: record.id,
            kind: persisted(EventLedgerKind.self, rawValue: record.kindRaw, fallback: .goalUpdated, storedTypeName: "EventLedgerRecord", fieldName: "kindRaw"),
            occurredAt: record.occurredAt,
            source: persisted(EventLedgerSource.self, rawValue: record.sourceRaw, fallback: .system, storedTypeName: "EventLedgerRecord", fieldName: "sourceRaw"),
            goalID: record.goalID,
            captureID: record.captureID,
            planID: record.planID,
            planScope: record.planScope,
            reviewID: record.reviewID,
            title: record.title,
            summary: record.summaryText,
            semanticState: record.semanticState,
            tone: persisted(EventLedgerTone.self, rawValue: record.toneRaw, fallback: .neutral, storedTypeName: "EventLedgerRecord", fieldName: "toneRaw"),
            trust: (try? PersistenceCoding.decode(EventLedgerTrustMetadata.self, from: record.trustData)) ?? EventLedgerTrustMetadata(),
            evidenceReferences: (try? PersistenceCoding.decode([EventLedgerEvidenceReference].self, from: record.evidenceReferencesData)) ?? [],
            metadata: (try? PersistenceCoding.decode([String: String].self, from: record.metadataData)) ?? [:],
            payload: (try? PersistenceCoding.decode([String: String].self, from: record.payloadData)) ?? [:],
            schemaVersion: record.schemaVersion,
            privacy: persisted(EventLedgerPrivacyClassification.self, rawValue: record.privacyRaw, fallback: .standard, storedTypeName: "EventLedgerRecord", fieldName: "privacyRaw"),
            localOnly: record.localOnly,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt
        )
    }


    static func commandExecutionRecord(from record: AmbitionsCommandExecutionRecord) throws -> CommandExecutionRecord {
        CommandExecutionRecord(
            id: record.id,
            commandID: record.command.id,
            commandKindRaw: record.command.kind.rawValue,
            commandSourceRaw: record.command.source.rawValue,
            actorRaw: record.command.actor.rawValue,
            executionStatusRaw: record.command.executionStatus.rawValue,
            resultStatusRaw: record.result.status.rawValue,
            recordedAt: record.recordedAt,
            recordedAtDate: PersistedTemporalValue.date(from: record.recordedAt),
            schemaVersion: record.schemaVersion,
            localOnly: record.localOnly,
            privacyRaw: record.privacy.rawValue,
            commandData: try PersistenceCoding.encode(record.command),
            resultData: try PersistenceCoding.encode(record.result)
        )
    }


    static func apply(_ record: AmbitionsCommandExecutionRecord, to persisted: CommandExecutionRecord) throws {
        persisted.commandID = record.command.id
        persisted.commandKindRaw = record.command.kind.rawValue
        persisted.commandSourceRaw = record.command.source.rawValue
        persisted.actorRaw = record.command.actor.rawValue
        persisted.executionStatusRaw = record.command.executionStatus.rawValue
        persisted.resultStatusRaw = record.result.status.rawValue
        persisted.recordedAt = record.recordedAt
        persisted.recordedAtDate = PersistedTemporalValue.date(from: record.recordedAt)
        persisted.schemaVersion = record.schemaVersion
        persisted.localOnly = record.localOnly
        persisted.privacyRaw = record.privacy.rawValue
        persisted.commandData = try PersistenceCoding.encode(record.command)
        persisted.resultData = try PersistenceCoding.encode(record.result)
    }


    static func commandExecutionRecord(from record: CommandExecutionRecord) throws -> AmbitionsCommandExecutionRecord {
        let command = try? PersistenceCoding.decode(AmbitionsCommand.self, from: record.commandData)
        let result = try? PersistenceCoding.decode(AmbitionsCommandExecutionResult.self, from: record.resultData)

        let fallbackCommand = AmbitionsCommand(
            id: record.commandID,
            kind: persisted(AmbitionsCommandKind.self, rawValue: record.commandKindRaw, fallback: .openDestination, storedTypeName: "CommandExecutionRecord", fieldName: "commandKindRaw"),
            source: persisted(AmbitionsCommandSource.self, rawValue: record.commandSourceRaw, fallback: .system, storedTypeName: "CommandExecutionRecord", fieldName: "commandSourceRaw"),
            executionStatus: persisted(AmbitionsCommandExecutionStatus.self, rawValue: record.executionStatusRaw, fallback: .blocked, storedTypeName: "CommandExecutionRecord", fieldName: "executionStatusRaw"),
            createdAt: record.recordedAt,
            actor: persisted(AmbitionsCommandActor.self, rawValue: record.actorRaw, fallback: .user, storedTypeName: "CommandExecutionRecord", fieldName: "actorRaw"),
            localOnly: record.localOnly,
            privacy: persisted(EventLedgerPrivacyClassification.self, rawValue: record.privacyRaw, fallback: .standard, storedTypeName: "CommandExecutionRecord", fieldName: "privacyRaw"),
            schemaVersion: ambitionsCommandSchemaVersion
        )
        let fallbackResult = AmbitionsCommandExecutionResult(
            status: persisted(AmbitionsCommandExecutionStatus.self, rawValue: record.resultStatusRaw, fallback: .failed, storedTypeName: "CommandExecutionRecord", fieldName: "resultStatusRaw"),
            summary: "Recovered from durable command execution record."
        )

        return AmbitionsCommandExecutionRecord(
            command: command ?? fallbackCommand,
            result: result ?? fallbackResult,
            recordedAt: record.recordedAt,
            localOnly: record.localOnly,
            privacy: persisted(EventLedgerPrivacyClassification.self, rawValue: record.privacyRaw, fallback: .standard, storedTypeName: "CommandExecutionRecord", fieldName: "privacyRaw"),
            schemaVersion: record.schemaVersion
        )
    }


    static func sideEffectLedgerStorageRecord(from record: SideEffectLedgerRecord) throws -> SideEffectLedgerStorageRecord {
        SideEffectLedgerStorageRecord(
            id: record.id,
            effectKindRaw: record.effectKind.rawValue,
            statusRaw: record.status.rawValue,
            boundaryRaw: record.boundary.rawValue,
            actionKindRaw: record.actionKind.rawValue,
            sourceDomainRaw: record.sourceDomain.rawValue,
            commandID: record.commandID,
            targetObjectsData: try PersistenceCoding.encode(record.targetObjects),
            requiresConfirmation: record.requiresConfirmation,
            externalEffect: record.externalEffect,
            reasonsData: try PersistenceCoding.encode(record.reasons),
            blockedFactsData: try PersistenceCoding.encode(record.blockedFacts),
            degradedFactsData: try PersistenceCoding.encode(record.degradedFacts),
            receiptID: record.receiptID,
            schemaVersion: record.schemaVersion,
            localOnly: record.localOnly,
            occurredAt: record.occurredAt,
            occurredAtDate: PersistedTemporalValue.date(from: record.occurredAt),
            snapshotData: try PersistenceCoding.encode(record)
        )
    }
}
