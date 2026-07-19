import Foundation
import SwiftData

@Model
final class CaptureRecord {
    @Attribute(.unique) var id: String
    var createdAt: String
    var updatedAt: String
    var rawText: String
    var sourceTypeRaw: String?
    var statusRaw: String
    var linkedGoalID: String?
    var snapshotData: Data

    init(
        id: String,
        createdAt: String,
        updatedAt: String,
        rawText: String,
        sourceTypeRaw: String?,
        statusRaw: String,
        linkedGoalID: String?,
        snapshotData: Data
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.rawText = rawText
        self.sourceTypeRaw = sourceTypeRaw
        self.statusRaw = statusRaw
        self.linkedGoalID = linkedGoalID
        self.snapshotData = snapshotData
    }
}

@Model
final class ReminderRecord {
    @Attribute(.unique) var id: String
    var schemaVersion: String
    var createdAt: String
    var updatedAt: String
    var deletedAt: String?
    var title: String
    var summaryText: String?
    var triggerAt: String?
    var kindRaw: String
    var stateRaw: String
    var receiptID: String?
    var replayTraceID: String?
    var sourceRecordID: String?
    var attachedObjectID: String?
    var deliveryPolicyData: Data
    var sourceData: Data
    var attachmentData: Data?
    var snapshotData: Data

    init(
        id: String,
        schemaVersion: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        title: String,
        summaryText: String?,
        triggerAt: String?,
        kindRaw: String,
        stateRaw: String,
        receiptID: String?,
        replayTraceID: String?,
        sourceRecordID: String?,
        attachedObjectID: String?,
        deliveryPolicyData: Data,
        sourceData: Data,
        attachmentData: Data?,
        snapshotData: Data
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.title = title
        self.summaryText = summaryText
        self.triggerAt = triggerAt
        self.kindRaw = kindRaw
        self.stateRaw = stateRaw
        self.receiptID = receiptID
        self.replayTraceID = replayTraceID
        self.sourceRecordID = sourceRecordID
        self.attachedObjectID = attachedObjectID
        self.deliveryPolicyData = deliveryPolicyData
        self.sourceData = sourceData
        self.attachmentData = attachmentData
        self.snapshotData = snapshotData
    }
}

@Model
final class TeachingSignalRecord {
    @Attribute(.unique) var id: String
    var goalID: String
    var kindRaw: String
    var sourceRaw: String
    var dispositionRaw: String
    var applicationKey: String
    var createdAt: String
    var updatedAt: String
    var snapshotData: Data

    init(
        id: String,
        goalID: String,
        kindRaw: String,
        sourceRaw: String,
        dispositionRaw: String,
        applicationKey: String,
        createdAt: String,
        updatedAt: String,
        snapshotData: Data
    ) {
        self.id = id
        self.goalID = goalID
        self.kindRaw = kindRaw
        self.sourceRaw = sourceRaw
        self.dispositionRaw = dispositionRaw
        self.applicationKey = applicationKey
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.snapshotData = snapshotData
    }
}

@Model
final class EventLedgerRecord {
    @Attribute(.unique) var id: String
    var kindRaw: String
    var occurredAt: String
    var occurredAtDate: Date?
    var sourceRaw: String
    var goalID: String?
    var captureID: String?
    var planID: String?
    var planScope: String?
    var reviewID: String?
    var title: String
    var summaryText: String?
    var semanticState: String?
    var toneRaw: String
    var schemaVersion: String
    var privacyRaw: String
    var localOnly: Bool
    var createdAt: String
    var createdAtDate: Date?
    var updatedAt: String
    var updatedAtDate: Date?
    var evidenceReferencesData: Data
    var metadataData: Data
    var payloadData: Data
    var trustData: Data
    var snapshotData: Data

    init(
        id: String,
        kindRaw: String,
        occurredAt: String,
        occurredAtDate: Date? = nil,
        sourceRaw: String,
        goalID: String?,
        captureID: String?,
        planID: String?,
        planScope: String?,
        reviewID: String?,
        title: String,
        summaryText: String?,
        semanticState: String?,
        toneRaw: String,
        schemaVersion: String,
        privacyRaw: String,
        localOnly: Bool,
        createdAt: String,
        createdAtDate: Date? = nil,
        updatedAt: String,
        updatedAtDate: Date? = nil,
        evidenceReferencesData: Data,
        metadataData: Data,
        payloadData: Data,
        trustData: Data,
        snapshotData: Data
    ) {
        self.id = id
        self.kindRaw = kindRaw
        self.occurredAt = occurredAt
        self.occurredAtDate = occurredAtDate ?? PersistedTemporalValue.date(from: occurredAt)
        self.sourceRaw = sourceRaw
        self.goalID = goalID
        self.captureID = captureID
        self.planID = planID
        self.planScope = planScope
        self.reviewID = reviewID
        self.title = title
        self.summaryText = summaryText
        self.semanticState = semanticState
        self.toneRaw = toneRaw
        self.schemaVersion = schemaVersion
        self.privacyRaw = privacyRaw
        self.localOnly = localOnly
        self.createdAt = createdAt
        self.createdAtDate = createdAtDate ?? PersistedTemporalValue.date(from: createdAt)
        self.updatedAt = updatedAt
        self.updatedAtDate = updatedAtDate ?? PersistedTemporalValue.date(from: updatedAt)
        self.evidenceReferencesData = evidenceReferencesData
        self.metadataData = metadataData
        self.payloadData = payloadData
        self.trustData = trustData
        self.snapshotData = snapshotData
    }
}

@Model
final class CommandExecutionRecord {
    @Attribute(.unique) var id: String
    var commandID: String
    var commandKindRaw: String
    var commandSourceRaw: String
    var actorRaw: String
    var executionStatusRaw: String
    var resultStatusRaw: String
    var recordedAt: String
    var recordedAtDate: Date?
    var schemaVersion: String
    var localOnly: Bool
    var privacyRaw: String
    var commandData: Data
    var resultData: Data

    init(
        id: String,
        commandID: String,
        commandKindRaw: String,
        commandSourceRaw: String,
        actorRaw: String,
        executionStatusRaw: String,
        resultStatusRaw: String,
        recordedAt: String,
        recordedAtDate: Date? = nil,
        schemaVersion: String,
        localOnly: Bool,
        privacyRaw: String,
        commandData: Data,
        resultData: Data
    ) {
        self.id = id
        self.commandID = commandID
        self.commandKindRaw = commandKindRaw
        self.commandSourceRaw = commandSourceRaw
        self.actorRaw = actorRaw
        self.executionStatusRaw = executionStatusRaw
        self.resultStatusRaw = resultStatusRaw
        self.recordedAt = recordedAt
        self.recordedAtDate = recordedAtDate ?? PersistedTemporalValue.date(from: recordedAt)
        self.schemaVersion = schemaVersion
        self.localOnly = localOnly
        self.privacyRaw = privacyRaw
        self.commandData = commandData
        self.resultData = resultData
    }
}

@Model
final class SideEffectLedgerStorageRecord {
    @Attribute(.unique) var id: String
    var effectKindRaw: String
    var statusRaw: String
    var boundaryRaw: String
    var actionKindRaw: String
    var sourceDomainRaw: String
    var commandID: String?
    var targetObjectsData: Data
    var requiresConfirmation: Bool
    var externalEffect: Bool
    var reasonsData: Data
    var blockedFactsData: Data
    var degradedFactsData: Data
    var receiptID: String?
    var schemaVersion: String
    var localOnly: Bool
    var occurredAt: String
    var occurredAtDate: Date?
    var snapshotData: Data

    init(
        id: String,
        effectKindRaw: String,
        statusRaw: String,
        boundaryRaw: String,
        actionKindRaw: String,
        sourceDomainRaw: String,
        commandID: String?,
        targetObjectsData: Data,
        requiresConfirmation: Bool,
        externalEffect: Bool,
        reasonsData: Data,
        blockedFactsData: Data,
        degradedFactsData: Data,
        receiptID: String?,
        schemaVersion: String,
        localOnly: Bool,
        occurredAt: String,
        occurredAtDate: Date? = nil,
        snapshotData: Data
    ) {
        self.id = id
        self.effectKindRaw = effectKindRaw
        self.statusRaw = statusRaw
        self.boundaryRaw = boundaryRaw
        self.actionKindRaw = actionKindRaw
        self.sourceDomainRaw = sourceDomainRaw
        self.commandID = commandID
        self.targetObjectsData = targetObjectsData
        self.requiresConfirmation = requiresConfirmation
        self.externalEffect = externalEffect
        self.reasonsData = reasonsData
        self.blockedFactsData = blockedFactsData
        self.degradedFactsData = degradedFactsData
        self.receiptID = receiptID
        self.schemaVersion = schemaVersion
        self.localOnly = localOnly
        self.occurredAt = occurredAt
        self.occurredAtDate = occurredAtDate ?? PersistedTemporalValue.date(from: occurredAt)
        self.snapshotData = snapshotData
    }
}
