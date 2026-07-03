import Foundation
import SwiftData

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
