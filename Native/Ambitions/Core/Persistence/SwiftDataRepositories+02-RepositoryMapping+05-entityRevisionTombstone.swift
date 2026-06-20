import AmbitionsDesignSystem
import Foundation
import SwiftData

extension RepositoryMapping {

    static func entityRevisionTombstone(from storage: EntityRevisionTombstoneRecord) throws -> EntityRevisionTombstone {
        if let snapshot = try? PersistenceCoding.decode(EntityRevisionTombstone.self, from: storage.snapshotData) {
            return snapshot
        }

        return EntityRevisionTombstone(
            id: storage.id,
            entityKind: persisted(
                EntityRevisionTombstoneEntityKind.self,
                rawValue: storage.entityKindRaw,
                fallback: .unknown,
                storedTypeName: "EntityRevisionTombstoneRecord",
                fieldName: "entityKindRaw"
            ),
            entityID: storage.entityID,
            revisionMarker: storage.revisionMarker,
            reason: persisted(
                EntityRevisionTombstoneReason.self,
                rawValue: storage.reasonRaw,
                fallback: .unknown,
                storedTypeName: "EntityRevisionTombstoneRecord",
                fieldName: "reasonRaw"
            ),
            recordedAt: storage.recordedAt,
            localOnly: storage.localOnly,
            lineageID: storage.lineageID,
            ancestryLineageIDs: (try? PersistenceCoding.decode([String].self, from: storage.ancestryLineageIDsData)) ?? [],
            lifecycleState: persisted(
                EntityRevisionTombstoneLifecycleState.self,
                rawValue: storage.lifecycleStateRaw,
                fallback: EntityRevisionTombstoneLifecycleState.recoverable,
                storedTypeName: "EntityRevisionTombstoneRecord",
                fieldName: "lifecycleStateRaw"
            ),
            privacyClass: persisted(
                AmbitionPrivacyClass.self,
                rawValue: storage.privacyClassRaw,
                fallback: .privateUserText,
                storedTypeName: "EntityRevisionTombstoneRecord",
                fieldName: "privacyClassRaw"
            ),
            sourceRecordID: storage.sourceRecordID,
            receiptID: storage.receiptID,
            replayTraceID: storage.replayTraceID,
            schemaVersion: storage.schemaVersion
        )
    }


    static func ambitionGraphOperationalRecordModel(
        from record: AmbitionGraphOperationalRecord
    ) throws -> AmbitionGraphOperationalRecordModel {
        AmbitionGraphOperationalRecordModel(
            id: record.id,
            schemaVersion: record.schemaVersion,
            surfaceRaw: record.surface.rawValue,
            sourceSnapshotID: record.sourceSnapshotID,
            ambitionID: record.ambitionID,
            generatedAt: record.generatedAt,
            localProjectionOnly: record.localProjectionOnly,
            privacyClassRaw: record.privacyClass.rawValue,
            sourceObjectIDsData: try PersistenceCoding.encode(record.sourceObjectIDs),
            receiptIDsData: try PersistenceCoding.encode(record.receiptIDs),
            replayTraceIDsData: try PersistenceCoding.encode(record.replayTraceIDs),
            sourceFieldsData: try PersistenceCoding.encode(record.sourceFields),
            projectionHash: record.projectionHash,
            checksum: record.checksum,
            snapshotData: try PersistenceCoding.encode(record)
        )
    }


    static func apply(_ record: AmbitionGraphOperationalRecord, to model: AmbitionGraphOperationalRecordModel) throws {
        model.schemaVersion = record.schemaVersion
        model.surfaceRaw = record.surface.rawValue
        model.sourceSnapshotID = record.sourceSnapshotID
        model.ambitionID = record.ambitionID
        model.generatedAt = record.generatedAt
        model.localProjectionOnly = record.localProjectionOnly
        model.privacyClassRaw = record.privacyClass.rawValue
        model.sourceObjectIDsData = try PersistenceCoding.encode(record.sourceObjectIDs)
        model.receiptIDsData = try PersistenceCoding.encode(record.receiptIDs)
        model.replayTraceIDsData = try PersistenceCoding.encode(record.replayTraceIDs)
        model.sourceFieldsData = try PersistenceCoding.encode(record.sourceFields)
        model.projectionHash = record.projectionHash
        model.checksum = record.checksum
        model.snapshotData = try PersistenceCoding.encode(record)
    }


    static func ambitionGraphOperationalRecord(
        from model: AmbitionGraphOperationalRecordModel
    ) throws -> AmbitionGraphOperationalRecord {
        if let snapshot = try? PersistenceCoding.decode(AmbitionGraphOperationalRecord.self, from: model.snapshotData) {
            return snapshot
        }

        return AmbitionGraphOperationalRecord(
            id: model.id,
            surface: persisted(
                AmbitionGraphProjectionSurface.self,
                rawValue: model.surfaceRaw,
                fallback: .today,
                storedTypeName: "AmbitionGraphOperationalRecordModel",
                fieldName: "surfaceRaw"
            ),
            sourceSnapshotID: model.sourceSnapshotID,
            ambitionID: model.ambitionID,
            generatedAt: model.generatedAt,
            localProjectionOnly: model.localProjectionOnly,
            privacyClass: persisted(
                AmbitionPrivacyClass.self,
                rawValue: model.privacyClassRaw,
                fallback: .systemOwned,
                storedTypeName: "AmbitionGraphOperationalRecordModel",
                fieldName: "privacyClassRaw"
            ),
            sourceObjectIDs: try PersistenceCoding.decode([String].self, from: model.sourceObjectIDsData),
            receiptIDs: try PersistenceCoding.decode([String].self, from: model.receiptIDsData),
            replayTraceIDs: try PersistenceCoding.decode([String].self, from: model.replayTraceIDsData),
            sourceFields: try PersistenceCoding.decode([String].self, from: model.sourceFieldsData),
            projectionHash: model.projectionHash,
            checksum: model.checksum,
            schemaVersion: model.schemaVersion
        )
    }


    static func ambitionGraphProofRecordModel(
        from record: AmbitionGraphProofRecord
    ) throws -> AmbitionGraphProofRecordModel {
        AmbitionGraphProofRecordModel(
            id: record.id,
            schemaVersion: record.schemaVersion,
            proofID: record.proofID,
            version: record.version,
            supersedesProofID: record.supersedesProofID,
            sourceSnapshotID: record.sourceSnapshotID,
            ambitionID: record.ambitionID,
            generatedAt: record.generatedAt,
            localProjectionOnly: record.localProjectionOnly,
            privacyClassRaw: record.privacyClass.rawValue,
            sourceObjectIDsData: try PersistenceCoding.encode(record.sourceObjectIDs),
            receiptIDsData: try PersistenceCoding.encode(record.receiptIDs),
            replayTraceIDsData: try PersistenceCoding.encode(record.replayTraceIDs),
            sourceFieldsData: try PersistenceCoding.encode(record.sourceFields),
            checksum: record.checksum,
            snapshotData: try PersistenceCoding.encode(record)
        )
    }


    static func ambitionGraphProofRecord(from model: AmbitionGraphProofRecordModel) throws -> AmbitionGraphProofRecord {
        if let snapshot = try? PersistenceCoding.decode(AmbitionGraphProofRecord.self, from: model.snapshotData) {
            return snapshot
        }

        return AmbitionGraphProofRecord(
            id: model.id,
            proofID: model.proofID,
            version: model.version,
            supersedesProofID: model.supersedesProofID,
            sourceSnapshotID: model.sourceSnapshotID,
            ambitionID: model.ambitionID,
            generatedAt: model.generatedAt,
            localProjectionOnly: model.localProjectionOnly,
            privacyClass: persisted(
                AmbitionPrivacyClass.self,
                rawValue: model.privacyClassRaw,
                fallback: .privateProof,
                storedTypeName: "AmbitionGraphProofRecordModel",
                fieldName: "privacyClassRaw"
            ),
            sourceObjectIDs: try PersistenceCoding.decode([String].self, from: model.sourceObjectIDsData),
            receiptIDs: try PersistenceCoding.decode([String].self, from: model.receiptIDsData),
            replayTraceIDs: try PersistenceCoding.decode([String].self, from: model.replayTraceIDsData),
            sourceFields: try PersistenceCoding.decode([String].self, from: model.sourceFieldsData),
            checksum: model.checksum,
            schemaVersion: model.schemaVersion
        )
    }


    static func apply(_ record: AmbitionGraphProofRecord, to model: AmbitionGraphProofRecordModel) throws {
        model.schemaVersion = record.schemaVersion
        model.proofID = record.proofID
        model.version = record.version
        model.supersedesProofID = record.supersedesProofID
        model.sourceSnapshotID = record.sourceSnapshotID
        model.ambitionID = record.ambitionID
        model.generatedAt = record.generatedAt
        model.localProjectionOnly = record.localProjectionOnly
        model.privacyClassRaw = record.privacyClass.rawValue
        model.sourceObjectIDsData = try PersistenceCoding.encode(record.sourceObjectIDs)
        model.receiptIDsData = try PersistenceCoding.encode(record.receiptIDs)
        model.replayTraceIDsData = try PersistenceCoding.encode(record.replayTraceIDs)
        model.sourceFieldsData = try PersistenceCoding.encode(record.sourceFields)
        model.checksum = record.checksum
        model.snapshotData = try PersistenceCoding.encode(record)
    }


    static func ambitionGraphProjectionRecordModel(
        from record: AmbitionGraphProjectionRecord
    ) throws -> AmbitionGraphProjectionRecordModel {
        AmbitionGraphProjectionRecordModel(
            id: record.id,
            schemaVersion: record.schemaVersion,
            surfaceRaw: record.surface.rawValue,
            sourceSnapshotID: record.sourceSnapshotID,
            ambitionID: record.ambitionID,
            generatedAt: record.generatedAt,
            localProjectionOnly: record.localProjectionOnly,
            privacyClassRaw: record.privacyClass.rawValue,
            sourceObjectIDsData: try PersistenceCoding.encode(record.sourceObjectIDs),
            receiptIDsData: try PersistenceCoding.encode(record.receiptIDs),
            replayTraceIDsData: try PersistenceCoding.encode(record.replayTraceIDs),
            sourceFieldsData: try PersistenceCoding.encode(record.sourceFields),
            projectionHash: record.projectionHash,
            checksum: record.checksum,
            invalidationReasonRaw: record.invalidationReason.rawValue,
            snapshotData: try PersistenceCoding.encode(record)
        )
    }


    static func apply(_ record: AmbitionGraphProjectionRecord, to model: AmbitionGraphProjectionRecordModel) throws {
        model.schemaVersion = record.schemaVersion
        model.surfaceRaw = record.surface.rawValue
        model.sourceSnapshotID = record.sourceSnapshotID
        model.ambitionID = record.ambitionID
        model.generatedAt = record.generatedAt
        model.localProjectionOnly = record.localProjectionOnly
        model.privacyClassRaw = record.privacyClass.rawValue
        model.sourceObjectIDsData = try PersistenceCoding.encode(record.sourceObjectIDs)
        model.receiptIDsData = try PersistenceCoding.encode(record.receiptIDs)
        model.replayTraceIDsData = try PersistenceCoding.encode(record.replayTraceIDs)
        model.sourceFieldsData = try PersistenceCoding.encode(record.sourceFields)
        model.projectionHash = record.projectionHash
        model.checksum = record.checksum
        model.invalidationReasonRaw = record.invalidationReason.rawValue
        model.snapshotData = try PersistenceCoding.encode(record)
    }


    static func ambitionGraphProjectionRecord(
        from model: AmbitionGraphProjectionRecordModel
    ) throws -> AmbitionGraphProjectionRecord {
        if let snapshot = try? PersistenceCoding.decode(AmbitionGraphProjectionRecord.self, from: model.snapshotData) {
            return snapshot
        }

        return AmbitionGraphProjectionRecord(
            id: model.id,
            surface: persisted(
                AmbitionGraphProjectionSurface.self,
                rawValue: model.surfaceRaw,
                fallback: .today,
                storedTypeName: "AmbitionGraphProjectionRecordModel",
                fieldName: "surfaceRaw"
            ),
            sourceSnapshotID: model.sourceSnapshotID,
            ambitionID: model.ambitionID,
            generatedAt: model.generatedAt,
            localProjectionOnly: model.localProjectionOnly,
            privacyClass: persisted(
                AmbitionPrivacyClass.self,
                rawValue: model.privacyClassRaw,
                fallback: .systemOwned,
                storedTypeName: "AmbitionGraphProjectionRecordModel",
                fieldName: "privacyClassRaw"
            ),
            sourceObjectIDs: try PersistenceCoding.decode([String].self, from: model.sourceObjectIDsData),
            receiptIDs: try PersistenceCoding.decode([String].self, from: model.receiptIDsData),
            replayTraceIDs: try PersistenceCoding.decode([String].self, from: model.replayTraceIDsData),
            sourceFields: try PersistenceCoding.decode([String].self, from: model.sourceFieldsData),
            projectionHash: model.projectionHash,
            checksum: model.checksum,
            invalidationReason: persisted(
                AmbitionGraphStoreSplitInvalidationReason.self,
                rawValue: model.invalidationReasonRaw,
                fallback: .initialMaterialization,
                storedTypeName: "AmbitionGraphProjectionRecordModel",
                fieldName: "invalidationReasonRaw"
            ),
            schemaVersion: model.schemaVersion
        )
    }
}
