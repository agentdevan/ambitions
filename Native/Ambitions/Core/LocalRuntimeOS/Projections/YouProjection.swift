import Foundation

struct YouProjection: Codable, Equatable, Hashable {
    var id: ProjectionID { .you }
    let cursor: ProjectionCursor
    let trustEventIDs: [String]
    let correctionEventIDs: [String]
    let proofEventIDs: [String]
    let tombstoneEventIDs: [String]
    let privacyCounts: [EventLedgerPrivacyClassification: Int]

    init(context: ProjectionBuildContext) throws {
        let youRecords = context.records.filter { record in
            record.source == .you ||
                record.route == .you ||
                record.kind == .proofAttached ||
                record.kind == .correctionRecorded ||
                record.kind == .tombstoneRecorded ||
                record.kind == .compactionSnapshot
        }
        trustEventIDs = youRecords.map(\.id)
        correctionEventIDs = youRecords.filter { $0.kind == .correctionRecorded }.map(\.id)
        proofEventIDs = youRecords.filter { $0.kind == .proofAttached }.map(\.id)
        tombstoneEventIDs = youRecords.filter { $0.kind == .tombstoneRecorded }.map(\.id)
        privacyCounts = Dictionary(grouping: youRecords.map(\.privacy), by: { $0 })
            .mapValues(\.count)
        cursor = try context.cursor(payloadFingerprint: ProjectionChecksum.digest([
            "trustEventIDs": trustEventIDs,
            "corrections": correctionEventIDs,
            "proof": proofEventIDs,
            "tombstones": tombstoneEventIDs,
        ]))
    }
}
