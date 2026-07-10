import Foundation

struct TodayProjection: Codable, Equatable, Hashable {
    var id: ProjectionID { .today }
    let cursor: ProjectionCursor
    let startHereCommandEventIDs: [String]
    let captureRouteEventIDs: [String]
    let closureEventIDs: [String]
    let timePlacementEventIDs: [String]
    let timeMutationEventIDs: [String]
    let recentRecords: [ProjectionEventRecord]

    private enum CodingKeys: String, CodingKey {
        case cursor
        case startHereCommandEventIDs
        case captureRouteEventIDs
        case closureEventIDs
        case timePlacementEventIDs
        case timeMutationEventIDs
        case recentRecords
    }

    init(context: ProjectionBuildContext) throws {
        let todayRecords = context.records.filter { record in
            record.source == .today ||
                record.route == .today ||
                record.route == .captureInbox ||
                record.kind == .captureRouteDecided ||
                record.kind == .closureRecorded ||
                record.kind == .timePlacementProposed ||
                Self.isTodayReceipt(record) ||
                Self.isTimeMutation(record)
        }
        startHereCommandEventIDs = todayRecords
            .filter { $0.kind == .commandExecution }
            .map(\.id)
        captureRouteEventIDs = todayRecords
            .filter { $0.kind == .captureRouteDecided }
            .map(\.id)
        closureEventIDs = todayRecords
            .filter { $0.kind == .closureRecorded }
            .map(\.id)
        timePlacementEventIDs = todayRecords
            .filter { $0.kind == .timePlacementProposed }
            .map(\.id)
        timeMutationEventIDs = todayRecords
            .filter(Self.isTimeMutation)
            .map(\.id)
        recentRecords = Array(todayRecords.suffix(12))
        cursor = try context.cursor(payloadFingerprint: ProjectionChecksum.digest([
            "startHere": startHereCommandEventIDs,
            "captureRoutes": captureRouteEventIDs,
            "closures": closureEventIDs,
            "timePlacements": timePlacementEventIDs,
            "timeMutations": timeMutationEventIDs,
        ]))
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cursor = try container.decode(ProjectionCursor.self, forKey: .cursor)
        startHereCommandEventIDs = try container.decode([String].self, forKey: .startHereCommandEventIDs)
        captureRouteEventIDs = try container.decode([String].self, forKey: .captureRouteEventIDs)
        closureEventIDs = try container.decode([String].self, forKey: .closureEventIDs)
        timePlacementEventIDs = try container.decode([String].self, forKey: .timePlacementEventIDs)
        timeMutationEventIDs = try container.decodeIfPresent([String].self, forKey: .timeMutationEventIDs) ?? []
        recentRecords = try container.decode([ProjectionEventRecord].self, forKey: .recentRecords)
    }

    private static func isTimeMutation(_ record: ProjectionEventRecord) -> Bool {
        guard record.kind == .domainMutation else { return false }
        return record.metadata["domainEventTypeID"]?.hasPrefix("ambitions.time.") == true ||
            (record.metadata["domainEventTypeID"] == "ambitions.mutation.undone" && record.source == .time)
    }

    private static func isTodayReceipt(_ record: ProjectionEventRecord) -> Bool {
        record.kind == .domainMutation &&
            record.metadata["domainEventTypeID"] == "ambitions.today.receipt_recorded"
    }
}
