import Foundation

struct TimeProjection: Codable, Equatable, Hashable {
    var id: ProjectionID { .time }
    let cursor: ProjectionCursor
    let placementEventIDs: [String]
    let schedulingCommandEventIDs: [String]
    let correctionEventIDs: [String]
    let recordsByTimeID: [String: [String]]

    init(context: ProjectionBuildContext) throws {
        let timeRecords = context.records.filter { record in
            record.target.timeID != nil ||
                record.route == .time ||
                record.kind == .timePlacementProposed ||
                record.metadata["proposalID"] != nil
        }
        placementEventIDs = timeRecords
            .filter { $0.kind == .timePlacementProposed }
            .map(\.id)
        schedulingCommandEventIDs = timeRecords
            .filter { record in
                guard record.kind == .commandExecution else { return false }
                return record.metadata["commandKind"] == AmbitionsCommandKind.scheduleItem.rawValue ||
                    record.metadata["commandKind"] == AmbitionsCommandKind.placeStepInTime.rawValue ||
                    record.metadata["commandKind"] == AmbitionsCommandKind.createTimeItem.rawValue
            }
            .map(\.id)
        correctionEventIDs = timeRecords
            .filter { $0.kind == .correctionRecorded }
            .map(\.id)
        recordsByTimeID = Dictionary(
            grouping: timeRecords.compactMap { record -> (String, String)? in
                guard let timeID = record.target.timeID ?? record.metadata["timeBlockID"] else { return nil }
                return (timeID, record.id)
            },
            by: { $0.0 }
        ).mapValues { pairs in
            pairs.map(\.1).sorted()
        }
        cursor = try context.cursor(payloadFingerprint: ProjectionChecksum.digest([
            "placements": placementEventIDs,
            "scheduling": schedulingCommandEventIDs,
            "corrections": correctionEventIDs,
        ]))
    }
}
