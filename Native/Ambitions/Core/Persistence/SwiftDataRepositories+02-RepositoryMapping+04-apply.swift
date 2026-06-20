import AmbitionsDesignSystem
import Foundation
import SwiftData

extension RepositoryMapping {

    static func apply(_ record: SideEffectLedgerRecord, to storage: SideEffectLedgerStorageRecord) throws {
        storage.effectKindRaw = record.effectKind.rawValue
        storage.statusRaw = record.status.rawValue
        storage.boundaryRaw = record.boundary.rawValue
        storage.actionKindRaw = record.actionKind.rawValue
        storage.sourceDomainRaw = record.sourceDomain.rawValue
        storage.commandID = record.commandID
        storage.targetObjectsData = try PersistenceCoding.encode(record.targetObjects)
        storage.requiresConfirmation = record.requiresConfirmation
        storage.externalEffect = record.externalEffect
        storage.reasonsData = try PersistenceCoding.encode(record.reasons)
        storage.blockedFactsData = try PersistenceCoding.encode(record.blockedFacts)
        storage.degradedFactsData = try PersistenceCoding.encode(record.degradedFacts)
        storage.receiptID = record.receiptID
        storage.schemaVersion = record.schemaVersion
        storage.localOnly = record.localOnly
        storage.occurredAt = record.occurredAt
        storage.occurredAtDate = PersistedTemporalValue.date(from: record.occurredAt)
        storage.snapshotData = try PersistenceCoding.encode(record)
    }


    static func sideEffectLedgerRecord(from storage: SideEffectLedgerStorageRecord) throws -> SideEffectLedgerRecord {
        if let snapshot = try? PersistenceCoding.decode(SideEffectLedgerRecord.self, from: storage.snapshotData) {
            return snapshot
        }

        return SideEffectLedgerRecord(
            id: storage.id,
            effectKind: persisted(SideEffectLedgerEffectKind.self, rawValue: storage.effectKindRaw, fallback: .unknown, storedTypeName: "SideEffectLedgerStorageRecord", fieldName: "effectKindRaw"),
            status: persisted(SideEffectLedgerStatus.self, rawValue: storage.statusRaw, fallback: .blocked, storedTypeName: "SideEffectLedgerStorageRecord", fieldName: "statusRaw"),
            boundary: persisted(SideEffectLedgerBoundary.self, rawValue: storage.boundaryRaw, fallback: .unsupported, storedTypeName: "SideEffectLedgerStorageRecord", fieldName: "boundaryRaw"),
            actionKind: persisted(SafeAutomationActionKind.self, rawValue: storage.actionKindRaw, fallback: .noOp, storedTypeName: "SideEffectLedgerStorageRecord", fieldName: "actionKindRaw"),
            sourceDomain: persisted(ActionReceiptSourceDomain.self, rawValue: storage.sourceDomainRaw, fallback: .today, storedTypeName: "SideEffectLedgerStorageRecord", fieldName: "sourceDomainRaw"),
            commandID: storage.commandID,
            targetObjects: (try? PersistenceCoding.decode([LifeGraphObjectReference].self, from: storage.targetObjectsData)) ?? [],
            occurredAt: storage.occurredAt,
            localOnly: storage.localOnly,
            requiresConfirmation: storage.requiresConfirmation,
            externalEffect: storage.externalEffect,
            reasons: (try? PersistenceCoding.decode([SafeAutomationPolicyReason].self, from: storage.reasonsData)) ?? [],
            blockedFacts: (try? PersistenceCoding.decode([String].self, from: storage.blockedFactsData)) ?? [],
            degradedFacts: (try? PersistenceCoding.decode([String].self, from: storage.degradedFactsData)) ?? [],
            receiptID: storage.receiptID,
            schemaVersion: storage.schemaVersion
        )
    }


    static func captureStatus(from rawValue: String) -> CaptureStatus {
        persisted(
            CaptureStatus.self,
            rawValue: rawValue,
            fallback: .actionable,
            storedTypeName: "CaptureRecord",
            fieldName: "statusRaw",
            legacyAliases: [
                "pending": .actionable,
                "processed": .goalBound,
            ]
        )
    }


    static func draftRecord(from draft: PersistedGoalDraft) throws -> GoalDraftRecord {
        GoalDraftRecord(
            id: draft.id,
            createdAt: draft.createdAt,
            updatedAt: draft.updatedAt,
            title: draft.draft.title,
            modeRaw: draft.draft.mode.rawValue,
            resultKindRaw: draft.latestResultKind?.rawValue,
            readinessRaw: draft.clarification?.readiness.rawValue,
            plannedGoalID: draft.plannedGoalID,
            snapshotData: try PersistenceCoding.encode(draft)
        )
    }


    static func storedDraft(from record: GoalDraftRecord) throws -> PersistedGoalDraft {
        try PersistenceCoding.decode(PersistedGoalDraft.self, from: record.snapshotData)
    }


    static func appStateRecord(from state: AppStateSnapshot) throws -> AppStateRecord {
        AppStateRecord(
            id: state.id,
            preferredTabRaw: state.preferredTab.rawValue,
            userDisplayName: state.userDisplayName,
            appearancePreferenceRaw: state.appearancePreference.rawValue,
            accentFamilyRaw: state.accentFamily.rawValue,
            hasCompletedBootstrap: state.hasCompletedBootstrap,
            lastBootstrapSourceRaw: state.lastBootstrapSource?.rawValue,
            lastBootstrapAt: state.lastBootstrapAt,
            lastSeedVersion: state.lastSeedVersion,
            lastSeededAt: state.lastSeededAt,
            lastOpenedGoalID: state.lastOpenedGoalID,
            snapshotData: try PersistenceCoding.encode(state)
        )
    }


    static func appState(from record: AppStateRecord) throws -> AppStateSnapshot {
        if let snapshot = try? PersistenceCoding.decode(AppStateSnapshot.self, from: record.snapshotData) {
            return snapshot
        }

        return AppStateSnapshot(
            id: record.id,
            preferredTab: persisted(AmbitionsSurface.self, rawValue: record.preferredTabRaw, fallback: .today, storedTypeName: "AppStateRecord", fieldName: "preferredTabRaw"),
            userDisplayName: record.userDisplayName,
            appearancePreference: persisted(AppAppearancePreference.self, rawValue: record.appearancePreferenceRaw, fallback: .system, storedTypeName: "AppStateRecord", fieldName: "appearancePreferenceRaw"),
            accentFamily: persistedOptional(AmbitionAccentFamily.self, rawValue: record.accentFamilyRaw, storedTypeName: "AppStateRecord", fieldName: "accentFamilyRaw") ?? .sage,
            reviewCadenceDays: 7,
            localOnlyModeEnabled: true,
            hasCompletedBootstrap: record.hasCompletedBootstrap,
            hasCompletedOnboarding: record.hasCompletedBootstrap,
            onboardingVersion: 1,
            onboardingCompletedAt: record.lastBootstrapAt,
            onboardingEntryChoice: nil,
            lastBootstrapSource: persistedOptional(AppSession.BootstrapSource.self, rawValue: record.lastBootstrapSourceRaw, storedTypeName: "AppStateRecord", fieldName: "lastBootstrapSourceRaw"),
            lastBootstrapAt: record.lastBootstrapAt,
            lastSeedVersion: record.lastSeedVersion,
            lastSeededAt: record.lastSeededAt,
            lastImportSummary: nil,
            lastOpenedGoalID: record.lastOpenedGoalID,
            goalPriorityOrder: []
        )
    }


    static func actionReceiptHistoryRecord(from record: ActionReceiptHistoryRecord) throws -> ActionReceiptHistoryRecordModel {
        ActionReceiptHistoryRecordModel(
            id: record.id,
            schemaVersion: actionClosureReceiptSchemaVersion,
            sourceDomainRaw: record.receipt.sourceDomain.rawValue,
            resultStateRaw: record.receipt.resultState.rawValue,
            privacyLevelRaw: record.privacyLevel.rawValue,
            proofRelevanceRaw: record.proofRelevance.rawValue,
            undoAvailabilityRaw: record.receipt.undoAvailability.rawValue,
            requiresConfirmationBeforeBroaderUse: record.requiresConfirmationBeforeBroaderUse,
            localOnly: record.localOnly,
            createdAt: record.receipt.createdAt,
            createdAtDate: PersistedTemporalValue.date(from: record.receipt.createdAt),
            occurredAt: record.receipt.occurredAt,
            occurredAtDate: PersistedTemporalValue.date(from: record.receipt.occurredAt),
            receiptData: try PersistenceCoding.encode(record.receipt),
            proofFreshnessLineageData: try PersistenceCoding.encode(record.proofFreshnessLineage)
        )
    }


    static func apply(_ record: ActionReceiptHistoryRecord, to persisted: ActionReceiptHistoryRecordModel) throws {
        persisted.schemaVersion = actionClosureReceiptSchemaVersion
        persisted.sourceDomainRaw = record.receipt.sourceDomain.rawValue
        persisted.resultStateRaw = record.receipt.resultState.rawValue
        persisted.privacyLevelRaw = record.privacyLevel.rawValue
        persisted.proofRelevanceRaw = record.proofRelevance.rawValue
        persisted.undoAvailabilityRaw = record.receipt.undoAvailability.rawValue
        persisted.requiresConfirmationBeforeBroaderUse = record.requiresConfirmationBeforeBroaderUse
        persisted.localOnly = record.localOnly
        persisted.createdAt = record.receipt.createdAt
        persisted.createdAtDate = PersistedTemporalValue.date(from: record.receipt.createdAt)
        persisted.occurredAt = record.receipt.occurredAt
        persisted.occurredAtDate = PersistedTemporalValue.date(from: record.receipt.occurredAt)
        persisted.receiptData = try PersistenceCoding.encode(record.receipt)
        persisted.proofFreshnessLineageData = try PersistenceCoding.encode(record.proofFreshnessLineage)
    }


    static func actionReceiptHistoryRecord(from persistedRecord: ActionReceiptHistoryRecordModel) throws -> ActionReceiptHistoryRecord {
        if let receipt = try? PersistenceCoding.decode(ActionReceipt.self, from: persistedRecord.receiptData) {
            let proofFreshnessLineage = (try? PersistenceCoding.decode(ActionReceiptProofFreshnessLineage.self, from: persistedRecord.proofFreshnessLineageData))
            return ActionReceiptHistoryRecord(
                receipt: receipt,
                privacyLevel: RepositoryMapping.persisted(ActionReceiptPrivacyLevel.self, rawValue: persistedRecord.privacyLevelRaw, fallback: .safeToShow, storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "privacyLevelRaw"),
                localOnly: persistedRecord.localOnly,
                proofRelevance: RepositoryMapping.persisted(ActionReceiptProofRelevance.self, rawValue: persistedRecord.proofRelevanceRaw, fallback: .notProof, storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "proofRelevanceRaw"),
                requiresConfirmationBeforeBroaderUse: persistedRecord.requiresConfirmationBeforeBroaderUse,
                proofFreshnessLineage: proofFreshnessLineage
            )
        }

        let fallbackReceipt = ActionReceipt(
            id: persistedRecord.id,
            resultState: RepositoryMapping.persisted(ActionReceiptResultState.self, rawValue: persistedRecord.resultStateRaw, fallback: .changed, storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "resultStateRaw"),
            title: "Recovered receipt",
            summary: "Recovered receipt payload was unavailable.",
            sourceDomain: RepositoryMapping.persisted(ActionReceiptSourceDomain.self, rawValue: persistedRecord.sourceDomainRaw, fallback: .system, storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "sourceDomainRaw"),
            occurredAt: persistedRecord.occurredAt,
            createdAt: persistedRecord.createdAt,
            affectedObjects: [],
            changedFacts: [],
            correctionAvailability: .unavailable,
            undoAvailability: RepositoryMapping.persisted(ActionReceiptUndoAvailability.self, rawValue: persistedRecord.undoAvailabilityRaw, fallback: .unavailable, storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "undoAvailabilityRaw")
        )

        return ActionReceiptHistoryRecord(
            receipt: fallbackReceipt,
            privacyLevel: RepositoryMapping.persisted(ActionReceiptPrivacyLevel.self, rawValue: persistedRecord.privacyLevelRaw, fallback: .safeToShow, storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "privacyLevelRaw"),
            localOnly: persistedRecord.localOnly,
            proofRelevance: RepositoryMapping.persisted(ActionReceiptProofRelevance.self, rawValue: persistedRecord.proofRelevanceRaw, fallback: .notProof, storedTypeName: "ActionReceiptHistoryRecordModel", fieldName: "proofRelevanceRaw"),
            requiresConfirmationBeforeBroaderUse: persistedRecord.requiresConfirmationBeforeBroaderUse,
            proofFreshnessLineage: (try? PersistenceCoding.decode(ActionReceiptProofFreshnessLineage.self, from: persistedRecord.proofFreshnessLineageData))
        )
    }


    static func runtimeSnapshotLedgerRecord(from envelope: RuntimeSnapshotLedgerEnvelope) throws -> RuntimeSnapshotLedgerRecord {
        RuntimeSnapshotLedgerRecord(
            id: envelope.id,
            schemaVersion: envelope.schemaVersion,
            generatedAt: envelope.generatedAt,
            sourceRecordIDsData: try PersistenceCoding.encode(envelope.sourceRecordIDs),
            receiptIDsData: try PersistenceCoding.encode(envelope.receiptIDs),
            replayTraceIDsData: try PersistenceCoding.encode(envelope.replayTraceIDs),
            recommendationInputReferenceIDsData: try PersistenceCoding.encode(envelope.recommendationInputReferenceIDs),
            proofInputReferenceIDsData: try PersistenceCoding.encode(envelope.proofInputReferenceIDs),
            afep02LineageReferenceIDsData: try PersistenceCoding.encode(envelope.afep02LineageReferenceIDs),
            fieldRedactionsData: try PersistenceCoding.encode(envelope.fieldRedactions),
            compatibilityStatusRaw: envelope.compatibilityStatus.rawValue,
            checksum: envelope.checksum,
            provenanceHash: envelope.provenanceHash,
            snapshotData: try PersistenceCoding.encode(envelope)
        )
    }


    static func apply(_ envelope: RuntimeSnapshotLedgerEnvelope, to record: RuntimeSnapshotLedgerRecord) throws {
        record.schemaVersion = envelope.schemaVersion
        record.generatedAt = envelope.generatedAt
        record.sourceRecordIDsData = try PersistenceCoding.encode(envelope.sourceRecordIDs)
        record.receiptIDsData = try PersistenceCoding.encode(envelope.receiptIDs)
        record.replayTraceIDsData = try PersistenceCoding.encode(envelope.replayTraceIDs)
        record.recommendationInputReferenceIDsData = try PersistenceCoding.encode(envelope.recommendationInputReferenceIDs)
        record.proofInputReferenceIDsData = try PersistenceCoding.encode(envelope.proofInputReferenceIDs)
        record.afep02LineageReferenceIDsData = try PersistenceCoding.encode(envelope.afep02LineageReferenceIDs)
        record.fieldRedactionsData = try PersistenceCoding.encode(envelope.fieldRedactions)
        record.compatibilityStatusRaw = envelope.compatibilityStatus.rawValue
        record.checksum = envelope.checksum
        record.provenanceHash = envelope.provenanceHash
        record.snapshotData = try PersistenceCoding.encode(envelope)
    }


    static func runtimeSnapshotLedgerEnvelope(from record: RuntimeSnapshotLedgerRecord) throws -> RuntimeSnapshotLedgerEnvelope {
        if let envelope = try? PersistenceCoding.decode(RuntimeSnapshotLedgerEnvelope.self, from: record.snapshotData),
           envelope.checksum == record.checksum,
           envelope.provenanceHash == record.provenanceHash {
            return envelope
        }

        return RuntimeSnapshotLedgerEnvelope(
            id: record.id,
            schemaVersion: record.schemaVersion,
            generatedAt: record.generatedAt,
            sourceRecordIDs: try PersistenceCoding.decode([String].self, from: record.sourceRecordIDsData),
            receiptIDs: try PersistenceCoding.decode([String].self, from: record.receiptIDsData),
            replayTraceIDs: try PersistenceCoding.decode([String].self, from: record.replayTraceIDsData),
            recommendationInputReferenceIDs: try PersistenceCoding.decode([String].self, from: record.recommendationInputReferenceIDsData),
            proofInputReferenceIDs: try PersistenceCoding.decode([String].self, from: record.proofInputReferenceIDsData),
            afep02LineageReferenceIDs: try PersistenceCoding.decode([String].self, from: record.afep02LineageReferenceIDsData),
            fieldRedactions: (try? PersistenceCoding.decode([RuntimeSnapshotLedgerFieldRedaction].self, from: record.fieldRedactionsData)) ?? []
        )
    }


    static func entityRevisionTombstoneRecord(from record: EntityRevisionTombstone) throws -> EntityRevisionTombstoneRecord {
        EntityRevisionTombstoneRecord(
            id: record.id,
            entityKindRaw: record.entityKind.rawValue,
            entityID: record.entityID,
            revisionMarker: record.revisionMarker,
            reasonRaw: record.reason.rawValue,
            recordedAt: record.recordedAt,
            recordedAtDate: PersistedTemporalValue.date(from: record.recordedAt),
            localOnly: record.localOnly,
            lineageID: record.lineageID,
            ancestryLineageIDsData: try PersistenceCoding.encode(record.ancestryLineageIDs),
            lifecycleStateRaw: record.lifecycleState.rawValue,
            privacyClassRaw: record.privacyClass.rawValue,
            sourceRecordID: record.sourceRecordID,
            receiptID: record.receiptID,
            replayTraceID: record.replayTraceID,
            schemaVersion: record.schemaVersion,
            snapshotData: try PersistenceCoding.encode(record)
        )
    }


    static func apply(_ record: EntityRevisionTombstone, to storage: EntityRevisionTombstoneRecord) throws {
        storage.entityKindRaw = record.entityKind.rawValue
        storage.entityID = record.entityID
        storage.revisionMarker = record.revisionMarker
        storage.reasonRaw = record.reason.rawValue
        storage.recordedAt = record.recordedAt
        storage.recordedAtDate = PersistedTemporalValue.date(from: record.recordedAt)
        storage.localOnly = record.localOnly
        storage.lineageID = record.lineageID
        storage.ancestryLineageIDsData = try PersistenceCoding.encode(record.ancestryLineageIDs)
        storage.lifecycleStateRaw = record.lifecycleState.rawValue
        storage.privacyClassRaw = record.privacyClass.rawValue
        storage.sourceRecordID = record.sourceRecordID
        storage.receiptID = record.receiptID
        storage.replayTraceID = record.replayTraceID
        storage.schemaVersion = record.schemaVersion
        storage.snapshotData = try PersistenceCoding.encode(record)
    }
}
