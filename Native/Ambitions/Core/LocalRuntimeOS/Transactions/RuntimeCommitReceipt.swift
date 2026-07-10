import Foundation

let runtimeCommitReceiptSchemaVersion = "runtime_commit_receipt.native.v1"

struct RuntimeCommitReceipt: Sendable, Codable, Equatable, Hashable, Identifiable {
    let id: String
    let transactionID: String
    let commandID: String
    let idempotencyKey: LedgerIdempotencyKey
    let eventCursor: RuntimeEventCursor
    let eventID: String
    let projectionCursors: [ProjectionCursor]
    let receiptID: String
    let proofArtifactID: String
    let rollbackPlanID: String
    let replayTraceID: String
    let affectedObjectIDs: [String]
    let objectFamilies: [ObjectStateFamily]
    let committedAt: String
    let localOnly: Bool
    let checksum: String
    let schemaVersion: String

    init(
        transaction: RuntimeTransaction,
        eventEnvelope: RuntimeEventEnvelope,
        projectionCursors: [ProjectionID: ProjectionCursor],
        committedAt: String,
        schemaVersion: String = runtimeCommitReceiptSchemaVersion
    ) {
        self.id = "runtime.commit-receipt.\(transaction.commandID)"
        self.transactionID = transaction.id
        self.commandID = transaction.commandID
        self.idempotencyKey = transaction.idempotencyKey
        self.eventCursor = eventEnvelope.cursor
        self.eventID = eventEnvelope.id
        self.projectionCursors = projectionCursors.values.sorted()
        self.receiptID = transaction.writeSet.receiptID
        self.proofArtifactID = transaction.writeSet.proofArtifactID
        self.rollbackPlanID = transaction.rollbackPlan.id
        self.replayTraceID = transaction.writeSet.replayTraceID
        self.affectedObjectIDs = transaction.writeSet.affectedObjectIDs
        self.objectFamilies = transaction.writeSet.objectFamilies
        self.committedAt = committedAt
        self.localOnly = transaction.writeSet.localOnly && eventEnvelope.event.localOnly && transaction.rollbackPlan.localOnly
        self.schemaVersion = schemaVersion
        self.checksum = RuntimeTransactionDigest.digest([
            id,
            transactionID,
            commandID,
            idempotencyKey.rawValue,
            eventID,
            String(eventCursor.sequence),
            eventCursor.checksum,
            self.projectionCursors.map { "\($0.projectionID.rawValue):\($0.sequence):\($0.checksum)" }.joined(separator: ","),
            receiptID,
            proofArtifactID,
            rollbackPlanID,
            replayTraceID,
            affectedObjectIDs.joined(separator: ","),
            objectFamilies.map(\.rawValue).joined(separator: ","),
            committedAt,
            String(localOnly),
            schemaVersion,
        ])
    }

    var hasReplayableProof: Bool {
        id.isEmpty == false &&
            transactionID.isEmpty == false &&
            commandID.isEmpty == false &&
            idempotencyKey.isWellFormed &&
            eventID.isEmpty == false &&
            eventCursor.sequence > 0 &&
            projectionCursors.isEmpty == false &&
            receiptID.isEmpty == false &&
            proofArtifactID.isEmpty == false &&
            rollbackPlanID.isEmpty == false &&
            replayTraceID.isEmpty == false &&
            affectedObjectIDs.isEmpty == false &&
            localOnly
    }

    func resultMetadata(disposition: RuntimeTransactionCommitDisposition) -> [String: String] {
        let orderedProjectionCursors = projectionCursors.sorted()
        return [
            "runtimeTransactionDisposition": disposition.rawValue,
            "runtimeTransactionID": transactionID,
            "runtimeEventID": eventID,
            "runtimeReceiptID": receiptID,
            "runtimeRollbackPlanID": rollbackPlanID,
            "runtimeReplayTraceID": replayTraceID,
            "runtimeProjectionCursorCount": String(projectionCursors.count),
            "runtimeProjectionIDs": orderedProjectionCursors.map(\.projectionID.rawValue).joined(separator: ","),
            "runtimeProjectionCursorIDs": orderedProjectionCursors.map(\.projectionID.rawValue).joined(separator: ","),
            "runtimeProjectionCursorSequences": orderedProjectionCursors.map { String($0.sequence) }.joined(separator: ","),
            "runtimeProjectionCursorChecksums": orderedProjectionCursors.map(\.checksum).joined(separator: ","),
        ]
    }
}
