import Foundation
import SwiftData

@Model
final class GoalRecord {
    @Attribute(.unique) var id: String
    var schemaVersion: String
    var revision: Int
    var createdAt: String
    var updatedAt: String
    var stateRaw: String
    var title: String
    var summaryText: String?
    var modeRaw: String
    var relationshipKindRaw: String
    var actorDisplayName: String
    var actorOwnershipRaw: String
    var parentGoalID: String?
    var childGoalIDsData: Data
    var supportGoalIDsData: Data
    var tagsData: Data
    var tempoRaw: String
    var timingTypeRaw: String
    var startsOn: String?
    var dueAt: String?
    var targetBy: String?
    var windowStart: String?
    var windowEnd: String?
    var suggestedNextAt: String?
    var repeatEveryDays: Int?
    var progressReviewCadenceDays: Int?
    var planningStrategyData: Data
    var progressStrategyData: Data
    var snapshotData: Data

    init(
        id: String,
        schemaVersion: String,
        revision: Int,
        createdAt: String,
        updatedAt: String,
        stateRaw: String,
        title: String,
        summaryText: String?,
        modeRaw: String,
        relationshipKindRaw: String,
        actorDisplayName: String,
        actorOwnershipRaw: String,
        parentGoalID: String?,
        childGoalIDsData: Data,
        supportGoalIDsData: Data,
        tagsData: Data,
        tempoRaw: String,
        timingTypeRaw: String,
        startsOn: String?,
        dueAt: String?,
        targetBy: String?,
        windowStart: String?,
        windowEnd: String?,
        suggestedNextAt: String?,
        repeatEveryDays: Int?,
        progressReviewCadenceDays: Int?,
        planningStrategyData: Data,
        progressStrategyData: Data,
        snapshotData: Data
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.revision = revision
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.stateRaw = stateRaw
        self.title = title
        self.summaryText = summaryText
        self.modeRaw = modeRaw
        self.relationshipKindRaw = relationshipKindRaw
        self.actorDisplayName = actorDisplayName
        self.actorOwnershipRaw = actorOwnershipRaw
        self.parentGoalID = parentGoalID
        self.childGoalIDsData = childGoalIDsData
        self.supportGoalIDsData = supportGoalIDsData
        self.tagsData = tagsData
        self.tempoRaw = tempoRaw
        self.timingTypeRaw = timingTypeRaw
        self.startsOn = startsOn
        self.dueAt = dueAt
        self.targetBy = targetBy
        self.windowStart = windowStart
        self.windowEnd = windowEnd
        self.suggestedNextAt = suggestedNextAt
        self.repeatEveryDays = repeatEveryDays
        self.progressReviewCadenceDays = progressReviewCadenceDays
        self.planningStrategyData = planningStrategyData
        self.progressStrategyData = progressStrategyData
        self.snapshotData = snapshotData
    }
}

@Model
final class GoalDraftRecord {
    @Attribute(.unique) var id: String
    var createdAt: String
    var updatedAt: String
    var title: String
    var modeRaw: String
    var resultKindRaw: String?
    var readinessRaw: String?
    var plannedGoalID: String?
    var snapshotData: Data

    init(
        id: String,
        createdAt: String,
        updatedAt: String,
        title: String,
        modeRaw: String,
        resultKindRaw: String?,
        readinessRaw: String?,
        plannedGoalID: String?,
        snapshotData: Data
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.title = title
        self.modeRaw = modeRaw
        self.resultKindRaw = resultKindRaw
        self.readinessRaw = readinessRaw
        self.plannedGoalID = plannedGoalID
        self.snapshotData = snapshotData
    }
}

@Model
final class GoalPlanRecord {
    @Attribute(.unique) var id: String
    var goalID: String
    var version: Int
    var generatedAt: String
    var summaryText: String?
    var strategyData: Data
    var assumptionsData: Data
    var lintData: Data
    var snapshotData: Data

    init(
        id: String,
        goalID: String,
        version: Int,
        generatedAt: String,
        summaryText: String?,
        strategyData: Data,
        assumptionsData: Data,
        lintData: Data,
        snapshotData: Data
    ) {
        self.id = id
        self.goalID = goalID
        self.version = version
        self.generatedAt = generatedAt
        self.summaryText = summaryText
        self.strategyData = strategyData
        self.assumptionsData = assumptionsData
        self.lintData = lintData
        self.snapshotData = snapshotData
    }
}

@Model
final class PlanSectionRecord {
    @Attribute(.unique) var id: String
    var goalID: String
    var planID: String
    var title: String
    var summaryText: String?
    var kindRaw: String
    var orderIndex: Int

    init(
        id: String,
        goalID: String,
        planID: String,
        title: String,
        summaryText: String?,
        kindRaw: String,
        orderIndex: Int
    ) {
        self.id = id
        self.goalID = goalID
        self.planID = planID
        self.title = title
        self.summaryText = summaryText
        self.kindRaw = kindRaw
        self.orderIndex = orderIndex
    }
}

@Model
final class StepRecord {
    @Attribute(.unique) var id: String
    var goalID: String
    var planID: String
    var sectionID: String
    var orderIndex: Int
    var title: String
    var summaryText: String?
    var typeRaw: String
    var stateRaw: String
    var ownerDisplayName: String
    var ownerOwnershipRaw: String
    var tempoRaw: String
    var timingTypeRaw: String
    var startsOn: String?
    var dueAt: String?
    var targetBy: String?
    var windowStart: String?
    var windowEnd: String?
    var suggestedNextAt: String?
    var repeatEveryDays: Int?
    var progressReviewCadenceDays: Int?
    var dependencyStepIDsData: Data
    var successSignalsData: Data
    var actionabilityData: Data
    var isOptional: Bool
    var isRepeatable: Bool
    var evidenceRequired: Bool
    var snapshotData: Data

    init(
        id: String,
        goalID: String,
        planID: String,
        sectionID: String,
        orderIndex: Int,
        title: String,
        summaryText: String?,
        typeRaw: String,
        stateRaw: String,
        ownerDisplayName: String,
        ownerOwnershipRaw: String,
        tempoRaw: String,
        timingTypeRaw: String,
        startsOn: String?,
        dueAt: String?,
        targetBy: String?,
        windowStart: String?,
        windowEnd: String?,
        suggestedNextAt: String?,
        repeatEveryDays: Int?,
        progressReviewCadenceDays: Int?,
        dependencyStepIDsData: Data,
        successSignalsData: Data,
        actionabilityData: Data,
        isOptional: Bool,
        isRepeatable: Bool,
        evidenceRequired: Bool,
        snapshotData: Data
    ) {
        self.id = id
        self.goalID = goalID
        self.planID = planID
        self.sectionID = sectionID
        self.orderIndex = orderIndex
        self.title = title
        self.summaryText = summaryText
        self.typeRaw = typeRaw
        self.stateRaw = stateRaw
        self.ownerDisplayName = ownerDisplayName
        self.ownerOwnershipRaw = ownerOwnershipRaw
        self.tempoRaw = tempoRaw
        self.timingTypeRaw = timingTypeRaw
        self.startsOn = startsOn
        self.dueAt = dueAt
        self.targetBy = targetBy
        self.windowStart = windowStart
        self.windowEnd = windowEnd
        self.suggestedNextAt = suggestedNextAt
        self.repeatEveryDays = repeatEveryDays
        self.progressReviewCadenceDays = progressReviewCadenceDays
        self.dependencyStepIDsData = dependencyStepIDsData
        self.successSignalsData = successSignalsData
        self.actionabilityData = actionabilityData
        self.isOptional = isOptional
        self.isRepeatable = isRepeatable
        self.evidenceRequired = evidenceRequired
        self.snapshotData = snapshotData
    }
}

@Model
final class ProgressEvidenceRecord {
    @Attribute(.unique) var id: String
    var goalID: String
    var stepID: String?
    var capturedAt: String
    var evidenceKindRaw: String
    var sourceRaw: String
    var progressDelta: Double?
    var confidenceDelta: Double?
    var minutesInvested: Int?
    var note: String?
    var snapshotData: Data

    init(
        id: String,
        goalID: String,
        stepID: String?,
        capturedAt: String,
        evidenceKindRaw: String,
        sourceRaw: String,
        progressDelta: Double?,
        confidenceDelta: Double?,
        minutesInvested: Int?,
        note: String?,
        snapshotData: Data
    ) {
        self.id = id
        self.goalID = goalID
        self.stepID = stepID
        self.capturedAt = capturedAt
        self.evidenceKindRaw = evidenceKindRaw
        self.sourceRaw = sourceRaw
        self.progressDelta = progressDelta
        self.confidenceDelta = confidenceDelta
        self.minutesInvested = minutesInvested
        self.note = note
        self.snapshotData = snapshotData
    }
}

@Model
final class FeedbackEventRecord {
    @Attribute(.unique) var id: String
    var goalID: String
    var stepID: String
    var occurredAt: String
    var kindRaw: String
    var note: String?
    var payloadData: Data

    init(
        id: String,
        goalID: String,
        stepID: String,
        occurredAt: String,
        kindRaw: String,
        note: String?,
        payloadData: Data
    ) {
        self.id = id
        self.goalID = goalID
        self.stepID = stepID
        self.occurredAt = occurredAt
        self.kindRaw = kindRaw
        self.note = note
        self.payloadData = payloadData
    }
}

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

@Model
final class EntityRevisionTombstoneRecord {
    @Attribute(.unique) var id: String
    var entityKindRaw: String
    var entityID: String
    var revisionMarker: String
    var reasonRaw: String
    var recordedAt: String
    var recordedAtDate: Date?
    var localOnly: Bool
    var lineageID: String
    var ancestryLineageIDsData: Data
    var lifecycleStateRaw: String
    var privacyClassRaw: String
    var sourceRecordID: String?
    var receiptID: String?
    var replayTraceID: String?
    var schemaVersion: String
    var snapshotData: Data

    init(
        id: String,
        entityKindRaw: String,
        entityID: String,
        revisionMarker: String,
        reasonRaw: String,
        recordedAt: String,
        recordedAtDate: Date? = nil,
        localOnly: Bool,
        lineageID: String,
        ancestryLineageIDsData: Data,
        lifecycleStateRaw: String,
        privacyClassRaw: String,
        sourceRecordID: String?,
        receiptID: String?,
        replayTraceID: String?,
        schemaVersion: String,
        snapshotData: Data
    ) {
        self.id = id
        self.entityKindRaw = entityKindRaw
        self.entityID = entityID
        self.revisionMarker = revisionMarker
        self.reasonRaw = reasonRaw
        self.recordedAt = recordedAt
        self.recordedAtDate = recordedAtDate ?? PersistedTemporalValue.date(from: recordedAt)
        self.localOnly = localOnly
        self.lineageID = lineageID
        self.ancestryLineageIDsData = ancestryLineageIDsData
        self.lifecycleStateRaw = lifecycleStateRaw
        self.privacyClassRaw = privacyClassRaw
        self.sourceRecordID = sourceRecordID
        self.receiptID = receiptID
        self.replayTraceID = replayTraceID
        self.schemaVersion = schemaVersion
        self.snapshotData = snapshotData
    }
}

@Model
final class AppStateRecord {
    @Attribute(.unique) var id: String
    var preferredTabRaw: String
    var userDisplayName: String
    var appearancePreferenceRaw: String
    var accentFamilyRaw: String?
    var hasCompletedBootstrap: Bool
    var lastBootstrapSourceRaw: String?
    var lastBootstrapAt: String?
    var lastSeedVersion: String?
    var lastSeededAt: String?
    var lastOpenedGoalID: String?
    var snapshotData: Data

    init(
        id: String,
        preferredTabRaw: String,
        userDisplayName: String,
        appearancePreferenceRaw: String,
        accentFamilyRaw: String?,
        hasCompletedBootstrap: Bool,
        lastBootstrapSourceRaw: String?,
        lastBootstrapAt: String?,
        lastSeedVersion: String?,
        lastSeededAt: String?,
        lastOpenedGoalID: String?,
        snapshotData: Data
    ) {
        self.id = id
        self.preferredTabRaw = preferredTabRaw
        self.userDisplayName = userDisplayName
        self.appearancePreferenceRaw = appearancePreferenceRaw
        self.accentFamilyRaw = accentFamilyRaw
        self.hasCompletedBootstrap = hasCompletedBootstrap
        self.lastBootstrapSourceRaw = lastBootstrapSourceRaw
        self.lastBootstrapAt = lastBootstrapAt
        self.lastSeedVersion = lastSeedVersion
        self.lastSeededAt = lastSeededAt
        self.lastOpenedGoalID = lastOpenedGoalID
        self.snapshotData = snapshotData
    }
}

@Model
final class ActionReceiptHistoryRecordModel {
    @Attribute(.unique) var id: String
    var schemaVersion: String
    var sourceDomainRaw: String
    var resultStateRaw: String
    var privacyLevelRaw: String
    var proofRelevanceRaw: String
    var undoAvailabilityRaw: String
    var requiresConfirmationBeforeBroaderUse: Bool
    var localOnly: Bool
    var createdAt: String
    var createdAtDate: Date?
    var occurredAt: String
    var occurredAtDate: Date?
    var receiptData: Data
    var proofFreshnessLineageData: Data

    init(
        id: String,
        schemaVersion: String,
        sourceDomainRaw: String,
        resultStateRaw: String,
        privacyLevelRaw: String,
        proofRelevanceRaw: String,
        undoAvailabilityRaw: String,
        requiresConfirmationBeforeBroaderUse: Bool,
        localOnly: Bool,
        createdAt: String,
        createdAtDate: Date? = nil,
        occurredAt: String,
        occurredAtDate: Date? = nil,
        receiptData: Data,
        proofFreshnessLineageData: Data
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.sourceDomainRaw = sourceDomainRaw
        self.resultStateRaw = resultStateRaw
        self.privacyLevelRaw = privacyLevelRaw
        self.proofRelevanceRaw = proofRelevanceRaw
        self.undoAvailabilityRaw = undoAvailabilityRaw
        self.requiresConfirmationBeforeBroaderUse = requiresConfirmationBeforeBroaderUse
        self.localOnly = localOnly
        self.createdAt = createdAt
        self.createdAtDate = createdAtDate ?? PersistedTemporalValue.date(from: createdAt)
        self.occurredAt = occurredAt
        self.occurredAtDate = occurredAtDate ?? PersistedTemporalValue.date(from: occurredAt)
        self.receiptData = receiptData
        self.proofFreshnessLineageData = proofFreshnessLineageData
    }
}

@Model
final class LifeContextBundleRecord {
    @Attribute(.unique) var id: String
    var schemaVersion: String
    var createdAt: String
    var updatedAt: String
    var deletedAt: String?
    var snapshotData: Data

    init(
        id: String,
        schemaVersion: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String? = nil,
        snapshotData: Data
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.snapshotData = snapshotData
    }
}

@Model
final class AmbitionGraphOperationalRecordModel {
    @Attribute(.unique) var id: String
    var schemaVersion: String
    var surfaceRaw: String
    var sourceSnapshotID: String
    var ambitionID: String
    var generatedAt: String
    var localProjectionOnly: Bool
    var privacyClassRaw: String
    var sourceObjectIDsData: Data
    var receiptIDsData: Data
    var replayTraceIDsData: Data
    var sourceFieldsData: Data
    var projectionHash: String
    var checksum: String
    var snapshotData: Data

    init(
        id: String,
        schemaVersion: String,
        surfaceRaw: String,
        sourceSnapshotID: String,
        ambitionID: String,
        generatedAt: String,
        localProjectionOnly: Bool,
        privacyClassRaw: String,
        sourceObjectIDsData: Data,
        receiptIDsData: Data,
        replayTraceIDsData: Data,
        sourceFieldsData: Data,
        projectionHash: String,
        checksum: String,
        snapshotData: Data
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.surfaceRaw = surfaceRaw
        self.sourceSnapshotID = sourceSnapshotID
        self.ambitionID = ambitionID
        self.generatedAt = generatedAt
        self.localProjectionOnly = localProjectionOnly
        self.privacyClassRaw = privacyClassRaw
        self.sourceObjectIDsData = sourceObjectIDsData
        self.receiptIDsData = receiptIDsData
        self.replayTraceIDsData = replayTraceIDsData
        self.sourceFieldsData = sourceFieldsData
        self.projectionHash = projectionHash
        self.checksum = checksum
        self.snapshotData = snapshotData
    }
}

@Model
final class AmbitionGraphProofRecordModel {
    @Attribute(.unique) var id: String
    var schemaVersion: String
    var proofID: String
    var version: Int
    var supersedesProofID: String?
    var sourceSnapshotID: String?
    var ambitionID: String
    var generatedAt: String
    var localProjectionOnly: Bool
    var privacyClassRaw: String
    var sourceObjectIDsData: Data
    var receiptIDsData: Data
    var replayTraceIDsData: Data
    var sourceFieldsData: Data
    var checksum: String
    var snapshotData: Data

    init(
        id: String,
        schemaVersion: String,
        proofID: String,
        version: Int,
        supersedesProofID: String?,
        sourceSnapshotID: String?,
        ambitionID: String,
        generatedAt: String,
        localProjectionOnly: Bool,
        privacyClassRaw: String,
        sourceObjectIDsData: Data,
        receiptIDsData: Data,
        replayTraceIDsData: Data,
        sourceFieldsData: Data,
        checksum: String,
        snapshotData: Data
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.proofID = proofID
        self.version = version
        self.supersedesProofID = supersedesProofID
        self.sourceSnapshotID = sourceSnapshotID
        self.ambitionID = ambitionID
        self.generatedAt = generatedAt
        self.localProjectionOnly = localProjectionOnly
        self.privacyClassRaw = privacyClassRaw
        self.sourceObjectIDsData = sourceObjectIDsData
        self.receiptIDsData = receiptIDsData
        self.replayTraceIDsData = replayTraceIDsData
        self.sourceFieldsData = sourceFieldsData
        self.checksum = checksum
        self.snapshotData = snapshotData
    }
}

@Model
final class AmbitionGraphProjectionRecordModel {
    @Attribute(.unique) var id: String
    var schemaVersion: String
    var surfaceRaw: String
    var sourceSnapshotID: String
    var ambitionID: String
    var generatedAt: String
    var localProjectionOnly: Bool
    var privacyClassRaw: String
    var sourceObjectIDsData: Data
    var receiptIDsData: Data
    var replayTraceIDsData: Data
    var sourceFieldsData: Data
    var projectionHash: String
    var checksum: String
    var invalidationReasonRaw: String
    var snapshotData: Data

    init(
        id: String,
        schemaVersion: String,
        surfaceRaw: String,
        sourceSnapshotID: String,
        ambitionID: String,
        generatedAt: String,
        localProjectionOnly: Bool,
        privacyClassRaw: String,
        sourceObjectIDsData: Data,
        receiptIDsData: Data,
        replayTraceIDsData: Data,
        sourceFieldsData: Data,
        projectionHash: String,
        checksum: String,
        invalidationReasonRaw: String,
        snapshotData: Data
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.surfaceRaw = surfaceRaw
        self.sourceSnapshotID = sourceSnapshotID
        self.ambitionID = ambitionID
        self.generatedAt = generatedAt
        self.localProjectionOnly = localProjectionOnly
        self.privacyClassRaw = privacyClassRaw
        self.sourceObjectIDsData = sourceObjectIDsData
        self.receiptIDsData = receiptIDsData
        self.replayTraceIDsData = replayTraceIDsData
        self.sourceFieldsData = sourceFieldsData
        self.projectionHash = projectionHash
        self.checksum = checksum
        self.invalidationReasonRaw = invalidationReasonRaw
        self.snapshotData = snapshotData
    }
}
