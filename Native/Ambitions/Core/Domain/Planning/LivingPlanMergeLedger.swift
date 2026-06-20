import Foundation

/// Audit log infrastructure for living plans, providing an immutable-style event ledger.
struct LivingPlanAuditLedgerEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let timestamp: Date
    let kind: AuditEntryKind
    let summary: String
    let receiptID: String?
    let metadata: [String: String]
    
    enum AuditEntryKind: String, Codable, Sendable {
        case mergeResolution = "merge_resolution"
        case schemaMigration = "schema_migration"
        case receiptPin = "receipt_pin"
        case proofExport = "proof_export"
    }
}

struct LivingPlanAuditLedger: Sendable, Equatable {
    private(set) var entries: [LivingPlanAuditLedgerEntry]
    
    init(entries: [LivingPlanAuditLedgerEntry] = []) {
        self.entries = entries
    }
    
    /// Records an entry in the audit ledger.
    mutating func recordEntry(
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
    mutating func pinReceipt(receiptID: String, note: String) -> ActionReceipt {
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
