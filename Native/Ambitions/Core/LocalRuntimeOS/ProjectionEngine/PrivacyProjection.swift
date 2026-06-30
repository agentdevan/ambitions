import Foundation

struct PrivacyProjectionBucket: Codable, Equatable, Hashable, Identifiable {
    let id: EventLedgerPrivacyClassification
    let eventCount: Int
    let latestEventID: String?

    init(classification: EventLedgerPrivacyClassification, records: [ProjectionEventRecord]) {
        id = classification
        eventCount = records.count
        latestEventID = records.last?.id
    }
}

struct PrivacyProjection: Codable, Equatable, Hashable {
    var id: ProjectionID { .privacy }
    let cursor: ProjectionCursor
    let buckets: [PrivacyProjectionBucket]
    let redactionRequiredEventIDs: [String]
    let localOnlyEventIDs: [String]

    init(context: ProjectionBuildContext) throws {
        let grouped = Dictionary(grouping: context.records, by: \.privacy)
        buckets = grouped
            .map { classification, records in
                PrivacyProjectionBucket(classification: classification, records: records.sorted { $0.cursor < $1.cursor })
            }
            .sorted { $0.id.rawValue < $1.id.rawValue }
        redactionRequiredEventIDs = context.records
            .filter { $0.privacy == .privateUserText || $0.privacy == .sensitive }
            .map(\.id)
        localOnlyEventIDs = context.records
            .filter { $0.localOnly || $0.privacy == .privateUserText }
            .map(\.id)
        cursor = try context.cursor(payloadFingerprint: ProjectionChecksum.digest([
            "buckets": buckets.map { "\($0.id.rawValue):\($0.eventCount)" },
            "redaction": redactionRequiredEventIDs,
            "localOnly": localOnlyEventIDs,
        ]))
    }
}
