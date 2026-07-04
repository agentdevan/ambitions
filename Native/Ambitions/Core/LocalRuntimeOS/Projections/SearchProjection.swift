import Foundation

struct SearchProjectionResult: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let eventID: String
    let objectIDs: [String]
    let title: String
    let provenance: String
    let actionValidation: AmbitionsCommandValidationState
    let privacy: EventLedgerPrivacyClassification
    let score: Int

    init(record: ProjectionEventRecord) {
        id = "search.result.\(record.id)"
        eventID = record.id
        objectIDs = record.objectIDs
        title = record.summary
        provenance = "Runtime event \(record.id) at sequence \(record.cursor.sequence)"
        actionValidation = record.objectIDs.isEmpty ? .needsMissingTarget : .valid
        privacy = record.privacy
        score = Self.score(record)
    }

    private static func score(_ record: ProjectionEventRecord) -> Int {
        var value = 10
        if record.kind == .commandExecution { value += 8 }
        if record.kind == .proofAttached { value += 5 }
        if record.kind == .tombstoneRecorded { value -= 4 }
        if record.privacy == .standard { value += 2 }
        return max(0, value)
    }
}

struct SearchProjection: Codable, Equatable, Hashable {
    var id: ProjectionID { .search }
    let cursor: ProjectionCursor
    let results: [SearchProjectionResult]
    let rebuildSourceEventIDs: [String]

    init(context: ProjectionBuildContext) throws {
        let searchable = context.records.filter { $0.kind != .compactionSnapshot }
        results = searchable
            .map(SearchProjectionResult.init)
            .sorted { lhs, rhs in
                if lhs.score != rhs.score {
                    return lhs.score > rhs.score
                }
                return lhs.eventID < rhs.eventID
            }
        rebuildSourceEventIDs = searchable.map(\.id)
        cursor = try context.cursor(payloadFingerprint: ProjectionChecksum.digest(results))
    }
}
