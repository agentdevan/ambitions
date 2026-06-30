import Foundation

struct TodayProjection: Codable, Equatable, Hashable {
    var id: ProjectionID { .today }
    let cursor: ProjectionCursor
    let startHereCommandEventIDs: [String]
    let captureRouteEventIDs: [String]
    let closureEventIDs: [String]
    let timePlacementEventIDs: [String]
    let recentRecords: [ProjectionEventRecord]

    init(context: ProjectionBuildContext) throws {
        let todayRecords = context.records.filter { record in
            record.source == .today ||
                record.route == .today ||
                record.route == .captureInbox ||
                record.kind == .captureRouteDecided ||
                record.kind == .closureRecorded ||
                record.kind == .timePlacementProposed
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
        recentRecords = Array(todayRecords.suffix(12))
        cursor = try context.cursor(payloadFingerprint: ProjectionChecksum.digest([
            "startHere": startHereCommandEventIDs,
            "captureRoutes": captureRouteEventIDs,
            "closures": closureEventIDs,
            "timePlacements": timePlacementEventIDs,
        ]))
    }
}
