import Foundation

let projectionCursorSchemaVersion = "runtime_projection_cursor.native.v1"

struct ProjectionCursor: Codable, Equatable, Hashable, Comparable {
    let projectionID: ProjectionID
    let eventCursor: RuntimeEventCursor?
    let checksum: String
    let materializedAt: String
    let schemaVersion: String

    init(
        projectionID: ProjectionID,
        eventCursor: RuntimeEventCursor?,
        checksum: String,
        materializedAt: String,
        schemaVersion: String = projectionCursorSchemaVersion
    ) {
        self.projectionID = projectionID
        self.eventCursor = eventCursor
        self.checksum = checksum
        self.materializedAt = materializedAt
        self.schemaVersion = schemaVersion
    }

    var sequence: Int64 {
        eventCursor?.sequence ?? 0
    }

    static func < (lhs: ProjectionCursor, rhs: ProjectionCursor) -> Bool {
        if lhs.projectionID != rhs.projectionID {
            return lhs.projectionID < rhs.projectionID
        }
        if lhs.sequence != rhs.sequence {
            return lhs.sequence < rhs.sequence
        }
        return lhs.checksum < rhs.checksum
    }
}
