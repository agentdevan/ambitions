import Foundation

public enum LivingPlanMergeConflictResolution: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case keepLocal = "keep_local"
    case takeRemote = "take_remote"
    case manualMerge = "manual_merge"
}

public struct LivingPlanMergeLedgerEntry: Codable, Sendable, Equatable, Hashable {
    public let id: String
    public let timestamp: Date
    public let resolution: LivingPlanMergeConflictResolution
    public let affectedGoalIDs: [String]
    public let receiptID: String?
    
    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        resolution: LivingPlanMergeConflictResolution,
        affectedGoalIDs: [String],
        receiptID: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.resolution = resolution
        self.affectedGoalIDs = affectedGoalIDs
        self.receiptID = receiptID
    }
}

public struct LivingPlanMergeLedger: Sendable, Equatable {
    public private(set) var entries: [LivingPlanMergeLedgerEntry]
    
    public init(entries: [LivingPlanMergeLedgerEntry] = []) {
        self.entries = entries
    }
    
    public mutating func recordMerge(
        resolution: LivingPlanMergeConflictResolution,
        affectedGoalIDs: [String]
    ) -> ActionReceipt {
        let needsConfirmation = resolution == .manualMerge
        
        let receipt = ActionReceipt(
            id: UUID().uuidString,
            resultState: needsConfirmation ? .needsConfirmation : .completed,
            title: "Multi-Device Merge",
            summary: "Recorded plan merge resolution: \(resolution.rawValue)",
            sourceDomain: .plan,
            occurredAt: "2026-05-15T00:00:00Z",
            affectedObjects: [],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: needsConfirmation ? .needsConfirmation : .changedField,
                    summary: "Merge recorded."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            safetyState: needsConfirmation ? .confirmationRequired : .normal
        )
        
        let entry = LivingPlanMergeLedgerEntry(
            resolution: resolution,
            affectedGoalIDs: affectedGoalIDs,
            receiptID: receipt.id
        )
        entries.append(entry)
        
        return receipt
    }
}
