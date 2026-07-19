import Foundation

struct RuntimeEventCursor: Codable, Equatable, Hashable, Comparable {
    let sequence: Int64
    let eventID: String
    let checksum: String
    let occurredAt: String

    init(sequence: Int64, eventID: String, checksum: String, occurredAt: String) {
        self.sequence = max(0, sequence)
        self.eventID = eventID
        self.checksum = checksum
        self.occurredAt = occurredAt
    }

    static func < (lhs: RuntimeEventCursor, rhs: RuntimeEventCursor) -> Bool {
        if lhs.sequence != rhs.sequence {
            return lhs.sequence < rhs.sequence
        }
        return lhs.eventID < rhs.eventID
    }
}

enum RuntimeEventQuery: Equatable {
    case all
    case after(RuntimeEventCursor)
    case commandID(String)
    case kind(RuntimeEventKind)
}
