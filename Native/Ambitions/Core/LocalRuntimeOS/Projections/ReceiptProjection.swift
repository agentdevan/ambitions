import Foundation

struct ReceiptProjectionEntry: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let eventID: String
    let receiptKind: RuntimeEventKind
    let summary: String
    let provenanceIDs: [String]
    let privacy: EventLedgerPrivacyClassification

    init(record: ProjectionEventRecord) {
        id = "receipt.projection.\(record.id)"
        eventID = record.id
        receiptKind = record.kind
        summary = record.summary
        provenanceIDs = record.provenanceIDs
        privacy = record.privacy
    }
}

struct ReceiptProjection: Codable, Equatable, Hashable {
    var id: ProjectionID { .receipt }
    let cursor: ProjectionCursor
    let entries: [ReceiptProjectionEntry]
    let receiptEventIDs: [String]

    init(context: ProjectionBuildContext) throws {
        let receiptRecords = context.records.filter { record in
            record.kind == .commandExecution ||
                record.kind == .closureRecorded ||
                record.kind == .proofAttached ||
                record.kind == .correctionRecorded ||
                record.kind == .tombstoneRecorded
        }
        entries = receiptRecords.map(ReceiptProjectionEntry.init)
        receiptEventIDs = receiptRecords.map(\.id)
        cursor = try context.cursor(payloadFingerprint: ProjectionChecksum.digest(entries))
    }
}
