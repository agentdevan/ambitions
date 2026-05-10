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
    var updatedAt: String
    var evidenceReferencesData: Data
    var metadataData: Data
    var payloadData: Data
    var trustData: Data
    var snapshotData: Data

    init(
        id: String,
        kindRaw: String,
        occurredAt: String,
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
        updatedAt: String,
        evidenceReferencesData: Data,
        metadataData: Data,
        payloadData: Data,
        trustData: Data,
        snapshotData: Data
    ) {
        self.id = id
        self.kindRaw = kindRaw
        self.occurredAt = occurredAt
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
        self.updatedAt = updatedAt
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
        self.schemaVersion = schemaVersion
        self.localOnly = localOnly
        self.privacyRaw = privacyRaw
        self.commandData = commandData
        self.resultData = resultData
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
