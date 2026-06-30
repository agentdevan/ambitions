import Foundation

struct WidgetProjectionRow: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let eventID: String
    let title: String
    let detail: String
    let privacySummary: String
    let source: AmbitionsCommandSource

    init(record: ProjectionEventRecord) {
        id = "widget.row.\(record.id)"
        eventID = record.id
        title = record.isPrivacySafeForExternalSurface ? record.summary : "Private update"
        detail = record.isPrivacySafeForExternalSurface ? record.occurredAt : "Open Ambitions"
        privacySummary = record.isPrivacySafeForExternalSurface ? record.privacy.rawValue : "redacted"
        source = record.source
    }
}

struct WidgetProjection: Codable, Equatable, Hashable {
    var id: ProjectionID { .widget }
    let cursor: ProjectionCursor
    let rows: [WidgetProjectionRow]
    let redactedEventIDs: [String]

    init(context: ProjectionBuildContext) throws {
        rows = context.records
            .filter(\.isPrivacySafeForExternalSurface)
            .suffix(8)
            .map(WidgetProjectionRow.init)
        redactedEventIDs = context.records
            .filter { $0.isPrivacySafeForExternalSurface == false }
            .map(\.id)
        cursor = try context.cursor(payloadFingerprint: ProjectionChecksum.digest([
            "rows": rows.map(\.id),
            "redacted": redactedEventIDs,
        ]))
    }
}
