import Foundation

/// Audit log infrastructure for living plans, providing an immutable-style event ledger.
public struct LivingPlanAuditLedgerEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let id: String
    public let timestamp: Date
    public let kind: AuditEntryKind
    public let summary: String
    public let receiptID: String?
    public let metadata: [String: String]
    
    public enum AuditEntryKind: String, Codable, Sendable {
        case mergeResolution = "merge_resolution"
        case schemaMigration = "schema_migration"
        case receiptPin = "receipt_pin"
        case proofExport = "proof_export"
    }
}

public struct LivingPlanAuditLedger: Sendable, Equatable {
    public private(set) var entries: [LivingPlanAuditLedgerEntry]
    
    public init(entries: [LivingPlanAuditLedgerEntry] = []) {
        self.entries = entries
    }
    
    /// Records an entry in the audit ledger.
    public mutating func recordEntry(
        kind: LivingPlanAuditLedgerEntry.AuditEntryKind,
        summary: String,
        receiptID: String? = nil,
        metadata: [String: String] = [:]
    ) {
        let entry = LivingPlanAuditLedgerEntry(
            id: UUID().uuidString,
            timestamp: Date(),
            kind: kind,
            summary: summary,
            receiptID: receiptID,
            metadata: metadata
        )
        entries.append(entry)
    }
    
    /// Pins a receipt to the audit ledger with a specific note, as per LDI19 manifest.
    public mutating func pinReceipt(receiptID: String, note: String) -> ActionReceipt {
        let summary = "Pinned receipt \(receiptID): \(note)"
        recordEntry(kind: .receiptPin, summary: summary, receiptID: receiptID)
        
        return ActionReceipt(
            id: UUID().uuidString,
            resultState: .completed,
            title: "Receipt Pinned",
            summary: summary,
            sourceDomain: .proof,
            occurredAt: "2026-05-16T00:00:00Z",
            affectedObjects: [],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: .attachedCaptureToGoal, // closest match or generic
                    summary: "Receipt \(receiptID) pinned to ledger."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            safetyState: .normal
        )
    }
}
