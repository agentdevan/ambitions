import Foundation

struct GoalsProjection: Codable, Equatable, Hashable {
    var id: ProjectionID { .goals }
    let cursor: ProjectionCursor
    let goalEventIDs: [String]
    let proofEventIDs: [String]
    let closureEventIDs: [String]
    let tombstoneEventIDs: [String]
    let recordsByGoalID: [String: [String]]

    init(context: ProjectionBuildContext) throws {
        let goalRecords = context.records.filter { record in
            record.target.goalID != nil ||
                record.route == .goals ||
                record.route == .goalDetail ||
                record.kind == .proofAttached ||
                record.kind == .closureRecorded
        }
        goalEventIDs = goalRecords.map(\.id)
        proofEventIDs = goalRecords.filter { $0.kind == .proofAttached }.map(\.id)
        closureEventIDs = goalRecords.filter { $0.kind == .closureRecorded }.map(\.id)
        tombstoneEventIDs = goalRecords.filter { $0.kind == .tombstoneRecorded }.map(\.id)
        recordsByGoalID = Dictionary(
            grouping: goalRecords.compactMap { record -> (String, String)? in
                guard let goalID = record.target.goalID else { return nil }
                return (goalID, record.id)
            },
            by: { $0.0 }
        ).mapValues { pairs in
            pairs.map(\.1).sorted()
        }
        cursor = try context.cursor(payloadFingerprint: ProjectionChecksum.digest([
            "goalEventIDs": goalEventIDs,
            "proofEventIDs": proofEventIDs,
            "closureEventIDs": closureEventIDs,
            "tombstoneEventIDs": tombstoneEventIDs,
        ]))
    }
}
