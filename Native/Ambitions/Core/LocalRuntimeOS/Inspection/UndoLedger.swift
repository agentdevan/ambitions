import Foundation

let undoLedgerSchemaVersion = "undo_ledger.native.v1"

enum UndoLedgerAvailability: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unavailable
    case availableLocal = "available_local"
    case requiresConfirmation = "requires_confirmation"
    case unsafe
    case notSupportedYet = "not_supported_yet"

    init(receiptAvailability: ActionReceiptUndoAvailability) {
        switch receiptAvailability {
        case .unavailable:
            self = .unavailable
        case .availableLocal:
            self = .availableLocal
        case .requiresConfirmation:
            self = .requiresConfirmation
        case .unsafe:
            self = .unsafe
        case .notSupportedYet:
            self = .notSupportedYet
        }
    }

    var canUndoWithoutExternalEffect: Bool {
        self == .availableLocal
    }
}

struct UndoLedgerEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let commandID: String
    let receiptID: String
    let targetObjectIDs: [String]
    let availability: UndoLedgerAvailability
    let rollbackSummary: String
    let createdAt: String
    let privacy: EventLedgerPrivacyClassification
    let localOnly: Bool
    let runtimeLineage: RuntimeTrustLineage?
    let schemaVersion: String

    init(
        commandID: String,
        receiptRecord: ActionReceiptHistoryRecord,
        rollbackSummary: String? = nil,
        runtimeLineage: RuntimeTrustLineage? = nil,
        schemaVersion: String = undoLedgerSchemaVersion
    ) {
        self.id = "undo.\(receiptRecord.id)"
        self.commandID = commandID
        self.receiptID = receiptRecord.id
        self.targetObjectIDs = SourceRecordLedgerRecordIDs.objects(from: receiptRecord)
        self.availability = UndoLedgerAvailability(receiptAvailability: receiptRecord.receipt.undoAvailability)
        self.rollbackSummary = rollbackSummary ?? Self.defaultRollbackSummary(receiptRecord)
        self.createdAt = receiptRecord.receipt.occurredAt
        self.privacy = receiptRecord.privacyLevel.eventLedgerPrivacy
        self.localOnly = receiptRecord.localOnly
        self.runtimeLineage = runtimeLineage ?? receiptRecord.runtimeLineage
        self.schemaVersion = schemaVersion
    }

    var canUndoLocally: Bool {
        availability.canUndoWithoutExternalEffect && localOnly
    }

    var runtimeTransactionID: String? {
        runtimeLineage?.runtimeTransactionID
    }

    var runtimeEventID: String? {
        runtimeLineage?.runtimeEventID
    }

    var runtimeRollbackPlanID: String? {
        runtimeLineage?.runtimeRollbackPlanID
    }

    var runtimeReplayTraceID: String? {
        runtimeLineage?.runtimeReplayTraceID
    }

    var hasRuntimeRollbackLineage: Bool {
        runtimeLineage?.hasCompleteTrustTrace == true &&
            runtimeRollbackPlanID?.isEmpty == false &&
            runtimeReplayTraceID?.isEmpty == false
    }

    private static func defaultRollbackSummary(_ receiptRecord: ActionReceiptHistoryRecord) -> String {
        switch receiptRecord.receipt.undoAvailability {
        case .availableLocal:
            return "Undo restores the local state described by receipt \(receiptRecord.id)."
        case .requiresConfirmation:
            return "Undo requires review before changing local state."
        case .unsafe:
            return "Undo is unsafe for this receipt."
        case .notSupportedYet:
            return "Undo is not supported for this receipt yet."
        case .unavailable:
            return "Undo is unavailable for this receipt."
        }
    }
}

struct UndoLedger: Codable, Sendable, Equatable, Hashable {
    let entries: [UndoLedgerEntry]

    init(entries: [UndoLedgerEntry] = []) {
        self.entries = Self.orderedUnique(entries)
    }

    var localUndoEntries: [UndoLedgerEntry] {
        entries.filter(\.canUndoLocally)
    }

    func entry(receiptID: String) -> UndoLedgerEntry? {
        entries.first { $0.receiptID == receiptID }
    }

    func appending(_ entry: UndoLedgerEntry) -> UndoLedger {
        UndoLedger(entries: entries + [entry])
    }

    private static func orderedUnique(_ entries: [UndoLedgerEntry]) -> [UndoLedgerEntry] {
        var seen = Set<String>()
        return entries
            .filter { $0.id.isEmpty == false }
            .filter { seen.insert($0.id).inserted }
            .sorted {
                if $0.createdAt != $1.createdAt {
                    return $0.createdAt < $1.createdAt
                }
                return $0.id < $1.id
            }
    }
}

private enum SourceRecordLedgerRecordIDs {
    static func objects(from receiptRecord: ActionReceiptHistoryRecord) -> [String] {
        var seen = Set<String>()
        return receiptRecord.receipt.affectedObjects
            .map(\.id)
            .filter { $0.isEmpty == false }
            .filter { seen.insert($0).inserted }
    }
}
