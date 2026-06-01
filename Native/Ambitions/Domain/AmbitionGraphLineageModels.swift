import Foundation

enum EntityRevisionTombstoneLifecycleState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case recoverable
    case finalized

    var isRecoverable: Bool {
        self == .recoverable
    }

    var isFinalized: Bool {
        self == .finalized
    }
}

struct EntityRevisionTombstoneLineageView: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let tombstoneID: String
    let lineageID: String
    let entityKind: EntityRevisionTombstoneEntityKind
    let entityID: String?
    let revisionMarker: String
    let ancestryLineageIDs: [String]
    let lifecycleState: EntityRevisionTombstoneLifecycleState
    let privacyClass: AmbitionPrivacyClass
    let sourceRecordID: String?
    let receiptID: String?
    let replayTraceID: String?
    let recordedAt: String
    let localOnly: Bool
    let redactionSummary: String

    var isRecoverable: Bool {
        lifecycleState.isRecoverable
    }

    var isFinalized: Bool {
        lifecycleState.isFinalized
    }
}
