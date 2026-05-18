import Foundation

enum LedgerRecordTaxonomyKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case command
    case event
    case sideEffect = "side_effect"
    case receipt
}

enum LedgerReplayDecision: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case applyFresh = "apply_fresh"
    case replayExistingReceipt = "replay_existing_receipt"
    case lookupUnavailable = "lookup_unavailable"
}

struct LedgerIdempotencyKey: Codable, Sendable, Equatable, Hashable {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    var isWellFormed: Bool {
        rawValue.isEmpty == false
    }
}

enum LedgerDoubleApplyDisposition: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case applyOnce = "apply_once"
    case skipDuplicateMutation = "skip_duplicate_mutation"
    case skipUnverifiedMutation = "skip_unverified_mutation"
}

struct LedgerReplayOutcome: Codable, Sendable, Equatable, Hashable {
    let idempotencyKey: LedgerIdempotencyKey
    let decision: LedgerReplayDecision
    let doubleApplyDisposition: LedgerDoubleApplyDisposition
    let receiptSummary: String

    var isReplay: Bool {
        decision == .replayExistingReceipt
    }
}
