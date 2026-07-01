import Foundation

let auditTrailSchemaVersion = "audit_trail.native.v1"

enum AuditTrailEntryKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case commandAccepted = "command_accepted"
    case eventAppended = "event_appended"
    case receiptRecorded = "receipt_recorded"
    case proofLinked = "proof_linked"
    case sourceRecordsIndexed = "source_records_indexed"
    case undoIndexed = "undo_indexed"
    case historyProjected = "history_projected"
}

struct AuditTrailEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: AuditTrailEntryKind
    let commandID: String?
    let eventLedgerEntryID: String?
    let receiptID: String?
    let proofReferenceIDs: [String]
    let sourceRecordIDs: [String]
    let undoEntryID: String?
    let occurredAt: String
    let summary: String
    let privacy: EventLedgerPrivacyClassification
    let localOnly: Bool
    let runtimeLineage: RuntimeTrustLineage?
    let schemaVersion: String

    init(
        id: String,
        kind: AuditTrailEntryKind,
        commandID: String?,
        eventLedgerEntryID: String?,
        receiptID: String?,
        proofReferenceIDs: [String] = [],
        sourceRecordIDs: [String] = [],
        undoEntryID: String? = nil,
        occurredAt: String,
        summary: String,
        privacy: EventLedgerPrivacyClassification,
        localOnly: Bool = true,
        runtimeLineage: RuntimeTrustLineage? = nil,
        schemaVersion: String = auditTrailSchemaVersion
    ) {
        self.id = Self.normalized(id, fallback: "audit.\(kind.rawValue)")
        self.kind = kind
        self.commandID = Self.normalizedOptional(commandID)
        self.eventLedgerEntryID = Self.normalizedOptional(eventLedgerEntryID)
        self.receiptID = Self.normalizedOptional(receiptID)
        self.proofReferenceIDs = Self.orderedUnique(proofReferenceIDs)
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.undoEntryID = Self.normalizedOptional(undoEntryID)
        self.occurredAt = Self.normalized(occurredAt, fallback: "unknown")
        self.summary = Self.normalized(summary, fallback: kind.rawValue)
        self.privacy = privacy
        self.localOnly = localOnly
        self.runtimeLineage = runtimeLineage
        self.schemaVersion = schemaVersion
    }

    var hasRuntimeLineage: Bool {
        runtimeLineage?.hasCompleteTrustTrace == true
    }

    private static func normalized(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .filter { seen.insert($0).inserted }
    }
}

struct AuditTrail: Codable, Sendable, Equatable, Hashable {
    let entries: [AuditTrailEntry]

    init(entries: [AuditTrailEntry] = []) {
        self.entries = Self.orderedUnique(entries)
    }

    var localOnly: Bool {
        entries.allSatisfy(\.localOnly)
    }

    func entries(commandID: String) -> [AuditTrailEntry] {
        entries.filter { $0.commandID == commandID }
    }

    func hasCompleteCommandEventReceiptHistoryFlow(commandID: String, receiptID: String) -> Bool {
        let scoped = entries(commandID: commandID)
        return scoped.contains { $0.kind == .commandAccepted } &&
            scoped.contains { $0.kind == .eventAppended } &&
            scoped.contains { $0.kind == .receiptRecorded && $0.receiptID == receiptID } &&
            scoped.contains { $0.kind == .historyProjected }
    }

    func hasCompleteRuntimeLineage(commandID: String, receiptID: String) -> Bool {
        let scoped = entries(commandID: commandID).filter {
            $0.receiptID == nil || $0.receiptID == receiptID
        }
        return scoped.isEmpty == false &&
            scoped.allSatisfy(\.hasRuntimeLineage)
    }

    static func forCommit(
        commandRecord: AmbitionsCommandExecutionRecord,
        eventLedgerEntry: EventLedgerEntry,
        receiptRecord: ActionReceiptHistoryRecord,
        proofLedgerEntry: ActionReceiptProofLedgerEntry,
        sourceRecordLedger: SourceRecordLedger,
        undoEntry: UndoLedgerEntry,
        historyProjection: TrustHistoryQueryProjection,
        occurredAt: String,
        runtimeLineage: RuntimeTrustLineage? = nil
    ) -> AuditTrail {
        let commandID = commandRecord.commandID
        let proofIDs = proofLedgerEntry.proofReferenceIDs
        let sourceRecordIDs = sourceRecordLedger.records.map(\.id)
        let entries = [
            AuditTrailEntry(
                id: "audit.command.\(commandID)",
                kind: .commandAccepted,
                commandID: commandID,
                eventLedgerEntryID: nil,
                receiptID: nil,
                occurredAt: occurredAt,
                summary: "Command accepted into TrustSystem.",
                privacy: commandRecord.privacy,
                localOnly: commandRecord.localOnly,
                runtimeLineage: runtimeLineage
            ),
            AuditTrailEntry(
                id: "audit.event.\(eventLedgerEntry.id)",
                kind: .eventAppended,
                commandID: commandID,
                eventLedgerEntryID: eventLedgerEntry.id,
                receiptID: receiptRecord.id,
                sourceRecordIDs: sourceRecordIDs,
                occurredAt: eventLedgerEntry.occurredAt,
                summary: "Event ledger entry appended from runtime event.",
                privacy: eventLedgerEntry.privacy,
                localOnly: eventLedgerEntry.localOnly,
                runtimeLineage: runtimeLineage
            ),
            AuditTrailEntry(
                id: "audit.receipt.\(receiptRecord.id)",
                kind: .receiptRecorded,
                commandID: commandID,
                eventLedgerEntryID: eventLedgerEntry.id,
                receiptID: receiptRecord.id,
                proofReferenceIDs: proofIDs,
                sourceRecordIDs: sourceRecordIDs,
                occurredAt: receiptRecord.receipt.occurredAt,
                summary: "Action receipt history recorded.",
                privacy: receiptRecord.privacyLevel.eventLedgerPrivacy,
                localOnly: receiptRecord.localOnly,
                runtimeLineage: runtimeLineage
            ),
            AuditTrailEntry(
                id: "audit.proof.\(receiptRecord.id)",
                kind: .proofLinked,
                commandID: commandID,
                eventLedgerEntryID: eventLedgerEntry.id,
                receiptID: receiptRecord.id,
                proofReferenceIDs: proofIDs,
                sourceRecordIDs: sourceRecordIDs,
                occurredAt: receiptRecord.receipt.occurredAt,
                summary: proofIDs.isEmpty ? "Receipt did not create proof reference." : "Proof reference linked to receipt.",
                privacy: receiptRecord.privacyLevel.eventLedgerPrivacy,
                localOnly: receiptRecord.localOnly,
                runtimeLineage: runtimeLineage
            ),
            AuditTrailEntry(
                id: "audit.source-records.\(receiptRecord.id)",
                kind: .sourceRecordsIndexed,
                commandID: commandID,
                eventLedgerEntryID: eventLedgerEntry.id,
                receiptID: receiptRecord.id,
                sourceRecordIDs: sourceRecordIDs,
                occurredAt: occurredAt,
                summary: "Source records indexed with public/private boundary separation.",
                privacy: .standard,
                localOnly: true,
                runtimeLineage: runtimeLineage
            ),
            AuditTrailEntry(
                id: "audit.undo.\(undoEntry.id)",
                kind: .undoIndexed,
                commandID: commandID,
                eventLedgerEntryID: eventLedgerEntry.id,
                receiptID: receiptRecord.id,
                undoEntryID: undoEntry.id,
                occurredAt: undoEntry.createdAt,
                summary: "Undo ledger entry indexed from receipt.",
                privacy: undoEntry.privacy,
                localOnly: undoEntry.localOnly,
                runtimeLineage: runtimeLineage
            ),
            AuditTrailEntry(
                id: "audit.history.\(receiptRecord.id).\(historyProjection.totalMatchCount)",
                kind: .historyProjected,
                commandID: commandID,
                eventLedgerEntryID: eventLedgerEntry.id,
                receiptID: receiptRecord.id,
                occurredAt: occurredAt,
                summary: "History projection materialized from receipt and event ledgers.",
                privacy: .standard,
                localOnly: historyProjection.localOnly,
                runtimeLineage: runtimeLineage
            ),
        ]
        return AuditTrail(entries: entries)
    }

    private static func orderedUnique(_ entries: [AuditTrailEntry]) -> [AuditTrailEntry] {
        var seen = Set<String>()
        return entries
            .filter { $0.id.isEmpty == false }
            .filter { seen.insert($0.id).inserted }
            .sorted {
                if $0.occurredAt != $1.occurredAt {
                    return $0.occurredAt < $1.occurredAt
                }
                return $0.id < $1.id
            }
    }
}
