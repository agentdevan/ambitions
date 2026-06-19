import Foundation
import SwiftData

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
final class RuntimeSnapshotLedgerRecord {
    @Attribute(.unique) var id: String
    var schemaVersion: String
    var generatedAt: String
    var sourceRecordIDsData: Data
    var receiptIDsData: Data
    var replayTraceIDsData: Data
    var recommendationInputReferenceIDsData: Data
    var proofInputReferenceIDsData: Data
    var afep02LineageReferenceIDsData: Data
    var fieldRedactionsData: Data
    var compatibilityStatusRaw: String
    var checksum: String
    var provenanceHash: String
    var snapshotData: Data

    init(
        id: String,
        schemaVersion: String,
        generatedAt: String,
        sourceRecordIDsData: Data,
        receiptIDsData: Data,
        replayTraceIDsData: Data,
        recommendationInputReferenceIDsData: Data,
        proofInputReferenceIDsData: Data,
        afep02LineageReferenceIDsData: Data,
        fieldRedactionsData: Data,
        compatibilityStatusRaw: String,
        checksum: String,
        provenanceHash: String,
        snapshotData: Data
    ) {
        self.id = id
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.sourceRecordIDsData = sourceRecordIDsData
        self.receiptIDsData = receiptIDsData
        self.replayTraceIDsData = replayTraceIDsData
        self.recommendationInputReferenceIDsData = recommendationInputReferenceIDsData
        self.proofInputReferenceIDsData = proofInputReferenceIDsData
        self.afep02LineageReferenceIDsData = afep02LineageReferenceIDsData
        self.fieldRedactionsData = fieldRedactionsData
        self.compatibilityStatusRaw = compatibilityStatusRaw
        self.checksum = checksum
        self.provenanceHash = provenanceHash
        self.snapshotData = snapshotData
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
