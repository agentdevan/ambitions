import Foundation

let entityRevisionTombstoneSchemaVersion = "entity_revision_tombstone.native.v1"

enum EntityRevisionTombstoneEntityKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goal
    case goalDraft = "goal_draft"
    case progressEvidence = "progress_evidence"
    case goalFeedbackEvent = "goal_feedback_event"
    case capture
    case teachingSignal = "teaching_signal"
    case eventLedger = "event_ledger"
    case commandExecution = "command_execution"
    case actionReceipt = "action_receipt"
    case appState = "app_state"
    case unknown
}

enum EntityRevisionTombstoneReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case deleted
    case superseded
    case replaced
    case reset
    case conflictRecovered = "conflict_recovered"
    case unknown
}

struct EntityRevisionTombstone: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let entityKind: EntityRevisionTombstoneEntityKind
    let entityID: String
    let revisionMarker: String
    let reason: EntityRevisionTombstoneReason
    let recordedAt: String
    let localOnly: Bool
    let schemaVersion: String

    init(
        id: String,
        entityKind: EntityRevisionTombstoneEntityKind,
        entityID: String,
        revisionMarker: String,
        reason: EntityRevisionTombstoneReason,
        recordedAt: String,
        localOnly: Bool = true,
        schemaVersion: String = entityRevisionTombstoneSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.entityKind = entityKind
        self.entityID = entityID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.revisionMarker = revisionMarker.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reason = reason
        self.recordedAt = recordedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.localOnly = localOnly
        self.schemaVersion = schemaVersion
    }

    init(
        entityKind: EntityRevisionTombstoneEntityKind,
        entityID: String,
        revisionMarker: String,
        reason: EntityRevisionTombstoneReason,
        recordedAt: String,
        localOnly: Bool = true,
        schemaVersion: String = entityRevisionTombstoneSchemaVersion
    ) {
        self.init(
            id: Self.makeID(entityKind: entityKind, entityID: entityID, revisionMarker: revisionMarker),
            entityKind: entityKind,
            entityID: entityID,
            revisionMarker: revisionMarker,
            reason: reason,
            recordedAt: recordedAt,
            localOnly: localOnly,
            schemaVersion: schemaVersion
        )
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            entityID.isEmpty == false &&
            revisionMarker.isEmpty == false &&
            recordedAt.isEmpty == false &&
            schemaVersion == entityRevisionTombstoneSchemaVersion
    }

    static func makeID(
        entityKind: EntityRevisionTombstoneEntityKind,
        entityID: String,
        revisionMarker: String
    ) -> String {
        "entity_revision_tombstone.\(entityKind.rawValue).\(entityID.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "_")):\(revisionMarker.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "_"))"
    }
}
