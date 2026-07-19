import CryptoKit
import Foundation

let entityRevisionTombstoneSchemaVersion = "entity_revision_tombstone.native.v2"

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
    let lineageID: String
    let ancestryLineageIDs: [String]
    let lifecycleState: EntityRevisionTombstoneLifecycleState
    let privacyClass: AmbitionPrivacyClass
    let sourceRecordID: String?
    let receiptID: String?
    let replayTraceID: String?
    let schemaVersion: String

    private enum CodingKeys: String, CodingKey {
        case id
        case entityKind
        case entityID
        case revisionMarker
        case reason
        case recordedAt
        case localOnly
        case lineageID
        case ancestryLineageIDs
        case lifecycleState
        case privacyClass
        case sourceRecordID
        case receiptID
        case replayTraceID
        case schemaVersion
    }

    init(
        id: String,
        entityKind: EntityRevisionTombstoneEntityKind,
        entityID: String,
        revisionMarker: String,
        reason: EntityRevisionTombstoneReason,
        recordedAt: String,
        localOnly: Bool = true,
        lineageID: String? = nil,
        ancestryLineageIDs: [String] = [],
        lifecycleState: EntityRevisionTombstoneLifecycleState? = nil,
        privacyClass: AmbitionPrivacyClass = .privateUserText,
        sourceRecordID: String? = nil,
        receiptID: String? = nil,
        replayTraceID: String? = nil,
        schemaVersion: String = entityRevisionTombstoneSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.entityKind = entityKind
        self.entityID = entityID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.revisionMarker = revisionMarker.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reason = reason
        self.recordedAt = recordedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.localOnly = localOnly
        self.lineageID = Self.makeLineageID(entityKind: entityKind, entityID: entityID, lineageID: lineageID)
        self.ancestryLineageIDs = Self.orderedUnique(ancestryLineageIDs)
        self.lifecycleState = lifecycleState ?? Self.defaultLifecycleState(for: reason)
        self.privacyClass = privacyClass
        self.sourceRecordID = Self.normalizedOptional(sourceRecordID)
        self.receiptID = Self.normalizedOptional(receiptID)
        self.replayTraceID = Self.normalizedOptional(replayTraceID)
        self.schemaVersion = schemaVersion
    }

    init(
        entityKind: EntityRevisionTombstoneEntityKind,
        entityID: String,
        revisionMarker: String,
        reason: EntityRevisionTombstoneReason,
        recordedAt: String,
        localOnly: Bool = true,
        lineageID: String? = nil,
        ancestryLineageIDs: [String] = [],
        lifecycleState: EntityRevisionTombstoneLifecycleState? = nil,
        privacyClass: AmbitionPrivacyClass = .privateUserText,
        sourceRecordID: String? = nil,
        receiptID: String? = nil,
        replayTraceID: String? = nil,
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
            lineageID: lineageID,
            ancestryLineageIDs: ancestryLineageIDs,
            lifecycleState: lifecycleState,
            privacyClass: privacyClass,
            sourceRecordID: sourceRecordID,
            receiptID: receiptID,
            replayTraceID: replayTraceID,
            schemaVersion: schemaVersion
        )
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            entityID.isEmpty == false &&
            revisionMarker.isEmpty == false &&
            recordedAt.isEmpty == false &&
            lineageID.isEmpty == false &&
            schemaVersion == entityRevisionTombstoneSchemaVersion
    }

    var isRecoverable: Bool {
        lifecycleState.isRecoverable
    }

    var isFinalized: Bool {
        lifecycleState.isFinalized
    }

    var exportSafeLineageView: EntityRevisionTombstoneLineageView {
        let shouldRedactReferences = privacyClass != .systemOwned && privacyClass != .sharedReceipt
        let shouldRedactSourceRecordID = privacyClass != .systemOwned
        let shouldRedactReceiptID = privacyClass == .privateUserText || privacyClass == .privateProof || privacyClass == .privateConstraint
        let shouldRedactReplayTraceID = privacyClass != .systemOwned
        return EntityRevisionTombstoneLineageView(
            id: lineageID,
            tombstoneID: id,
            lineageID: lineageID,
            entityKind: entityKind,
            entityID: shouldRedactReferences ? nil : entityID,
            revisionMarker: revisionMarker,
            ancestryLineageIDs: shouldRedactReferences ? ancestryLineageIDs : ancestryLineageIDs,
            lifecycleState: lifecycleState,
            privacyClass: privacyClass,
            sourceRecordID: shouldRedactSourceRecordID ? nil : sourceRecordID,
            receiptID: shouldRedactReceiptID ? nil : receiptID,
            replayTraceID: shouldRedactReplayTraceID ? nil : replayTraceID,
            recordedAt: recordedAt,
            localOnly: localOnly,
            redactionSummary: redactionSummary
        )
    }

    var exportSafeTombstone: EntityRevisionTombstone {
        let shouldRedactSourceRecordID = privacyClass != .systemOwned
        let shouldRedactReceiptID = privacyClass == .privateUserText || privacyClass == .privateProof || privacyClass == .privateConstraint
        let shouldRedactReplayTraceID = privacyClass != .systemOwned
        return EntityRevisionTombstone(
            id: id,
            entityKind: entityKind,
            entityID: entityID,
            revisionMarker: revisionMarker,
            reason: reason,
            recordedAt: recordedAt,
            localOnly: localOnly,
            lineageID: lineageID,
            ancestryLineageIDs: ancestryLineageIDs,
            lifecycleState: lifecycleState,
            privacyClass: privacyClass,
            sourceRecordID: shouldRedactSourceRecordID ? nil : sourceRecordID,
            receiptID: shouldRedactReceiptID ? nil : receiptID,
            replayTraceID: shouldRedactReplayTraceID ? nil : replayTraceID,
            schemaVersion: schemaVersion
        )
    }

    var lineage: EntityRevisionTombstoneLineageView {
        exportSafeLineageView
    }

    static func makeID(
        entityKind: EntityRevisionTombstoneEntityKind,
        entityID: String,
        revisionMarker: String
    ) -> String {
        "entity_revision_tombstone.\(entityKind.rawValue).\(entityID.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "_")):\(revisionMarker.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "_"))"
    }

    static func makeLineageID(
        entityKind: EntityRevisionTombstoneEntityKind,
        entityID: String,
        lineageID: String?
    ) -> String {
        if let lineageID = normalizedOptional(lineageID) {
            return lineageID
        }
        let trimmedEntityID = entityID.trimmingCharacters(in: .whitespacesAndNewlines)
        let payload = "\(entityKind.rawValue)|\(trimmedEntityID)"
        let digest = SHA256.hash(data: Data(payload.utf8)).map { String(format: "%02x", $0) }.joined()
        return "entity_revision_lineage.\(entityKind.rawValue).\(digest)"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let entityKind = try container.decode(EntityRevisionTombstoneEntityKind.self, forKey: .entityKind)
        let entityID = try container.decode(String.self, forKey: .entityID)
        let revisionMarker = try container.decode(String.self, forKey: .revisionMarker)
        let reason = try container.decode(EntityRevisionTombstoneReason.self, forKey: .reason)
        let recordedAt = try container.decode(String.self, forKey: .recordedAt)
        let localOnly = try container.decodeIfPresent(Bool.self, forKey: .localOnly) ?? true

        self.init(
            id: try container.decode(String.self, forKey: .id),
            entityKind: entityKind,
            entityID: entityID,
            revisionMarker: revisionMarker,
            reason: reason,
            recordedAt: recordedAt,
            localOnly: localOnly,
            lineageID: try container.decodeIfPresent(String.self, forKey: .lineageID),
            ancestryLineageIDs: try container.decodeIfPresent([String].self, forKey: .ancestryLineageIDs) ?? [],
            lifecycleState: try container.decodeIfPresent(EntityRevisionTombstoneLifecycleState.self, forKey: .lifecycleState),
            privacyClass: try container.decodeIfPresent(AmbitionPrivacyClass.self, forKey: .privacyClass) ?? .privateUserText,
            sourceRecordID: try container.decodeIfPresent(String.self, forKey: .sourceRecordID),
            receiptID: try container.decodeIfPresent(String.self, forKey: .receiptID),
            replayTraceID: try container.decodeIfPresent(String.self, forKey: .replayTraceID),
            schemaVersion: try container.decodeIfPresent(String.self, forKey: .schemaVersion) ?? entityRevisionTombstoneSchemaVersion
        )
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(entityKind, forKey: .entityKind)
        try container.encode(entityID, forKey: .entityID)
        try container.encode(revisionMarker, forKey: .revisionMarker)
        try container.encode(reason, forKey: .reason)
        try container.encode(recordedAt, forKey: .recordedAt)
        try container.encode(localOnly, forKey: .localOnly)
        try container.encode(lineageID, forKey: .lineageID)
        try container.encode(ancestryLineageIDs, forKey: .ancestryLineageIDs)
        try container.encode(lifecycleState, forKey: .lifecycleState)
        try container.encode(privacyClass, forKey: .privacyClass)
        try container.encodeIfPresent(sourceRecordID, forKey: .sourceRecordID)
        try container.encodeIfPresent(receiptID, forKey: .receiptID)
        try container.encodeIfPresent(replayTraceID, forKey: .replayTraceID)
        try container.encode(schemaVersion, forKey: .schemaVersion)
    }

    private static func defaultLifecycleState(for reason: EntityRevisionTombstoneReason) -> EntityRevisionTombstoneLifecycleState {
        switch reason {
        case .deleted, .reset, .conflictRecovered, .unknown:
            return .recoverable
        case .superseded, .replaced:
            return .finalized
        }
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .filter { seen.insert($0).inserted }
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    private var redactionSummary: String {
        switch privacyClass {
        case .systemOwned:
            return "Lineage details are fully visible."
        case .sharedReceipt:
            return "Receipt reference stays visible while private source identifiers are redacted."
        case .privateUserText, .privateProof, .privateConstraint:
            return "Private lineage details are redacted for export."
        }
    }
}
