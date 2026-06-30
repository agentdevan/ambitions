import Foundation

struct AppIntentProjectionAction: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let eventID: String
    let commandID: String?
    let destination: AmbitionsCommandDestination?
    let title: String
    let canRunFromIntent: Bool
    let blockedReason: String?

    init(record: ProjectionEventRecord) {
        id = "app.intent.action.\(record.id)"
        eventID = record.id
        commandID = record.commandID
        destination = record.route ?? record.target.destination
        title = record.summary
        canRunFromIntent = record.isPrivacySafeForExternalSurface && record.resultStatus != .failed
        blockedReason = canRunFromIntent ? nil : "Requires in-app confirmation or private context."
    }
}

struct AppIntentProjection: Codable, Equatable, Hashable {
    var id: ProjectionID { .appIntent }
    let cursor: ProjectionCursor
    let actions: [AppIntentProjectionAction]
    let blockedEventIDs: [String]

    init(context: ProjectionBuildContext) throws {
        let actionRecords = context.records.filter { record in
            record.source == .appIntent ||
                record.source == .widget ||
                record.route != nil ||
                record.target.destination != nil
        }
        actions = actionRecords.map(AppIntentProjectionAction.init)
        blockedEventIDs = actions.filter { $0.canRunFromIntent == false }.map(\.eventID)
        cursor = try context.cursor(payloadFingerprint: ProjectionChecksum.digest(actions))
    }
}
