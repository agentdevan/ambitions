import Foundation

enum ProjectionInvalidationReason: String, Codable, Equatable, Hashable, CaseIterable {
    case eventAppended = "event_appended"
    case schemaChanged = "schema_changed"
    case privacyBoundaryChanged = "privacy_boundary_changed"
    case tombstoneObserved = "tombstone_observed"
    case fullRebuildRequested = "full_rebuild_requested"
}

struct ProjectionInvalidation: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let projectionID: ProjectionID
    let reason: ProjectionInvalidationReason
    let eventID: String?
    let eventKind: RuntimeEventKind?
    let previousCursor: ProjectionCursor?
    let nextCursor: ProjectionCursor
    let occurredAt: String
    let explanation: String

    init(
        projectionID: ProjectionID,
        reason: ProjectionInvalidationReason,
        eventID: String?,
        eventKind: RuntimeEventKind?,
        previousCursor: ProjectionCursor?,
        nextCursor: ProjectionCursor,
        occurredAt: String,
        explanation: String
    ) {
        self.id = [
            "projection.invalidation",
            projectionID.rawValue,
            eventID ?? "rebuild",
            String(nextCursor.sequence),
        ].joined(separator: ".")
        self.projectionID = projectionID
        self.reason = reason
        self.eventID = eventID?.isEmpty == false ? eventID : nil
        self.eventKind = eventKind
        self.previousCursor = previousCursor
        self.nextCursor = nextCursor
        self.occurredAt = occurredAt
        self.explanation = explanation
    }

    var requiresRebuild: Bool {
        switch reason {
        case .schemaChanged, .privacyBoundaryChanged, .fullRebuildRequested:
            return true
        case .eventAppended, .tombstoneObserved:
            return false
        }
    }
}

struct ProjectionDiff: Codable, Equatable, Hashable {
    let projectionID: ProjectionID
    let previousCursor: ProjectionCursor?
    let nextCursor: ProjectionCursor
    let addedEventIDs: [String]
    let checksumChanged: Bool

    init(
        projectionID: ProjectionID,
        previousCursor: ProjectionCursor?,
        nextCursor: ProjectionCursor,
        addedEventIDs: [String]
    ) {
        self.projectionID = projectionID
        self.previousCursor = previousCursor
        self.nextCursor = nextCursor
        self.addedEventIDs = Array(Set(addedEventIDs.filter { $0.isEmpty == false })).sorted()
        checksumChanged = previousCursor?.checksum != nextCursor.checksum
    }
}
