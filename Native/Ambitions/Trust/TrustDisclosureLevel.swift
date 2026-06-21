import Foundation

enum TrustInspectionKind: String, CaseIterable, Identifiable, Sendable {
    case proof
    case source
    case privacy
    case history
    case receipt

    var id: String { rawValue }

    var title: String {
        switch self {
        case .proof:
            "Proof"
        case .source:
            "Source"
        case .privacy:
            "Privacy"
        case .history:
            "History"
        case .receipt:
            "Receipts"
        }
    }
}

enum TrustDisclosureLevel: String, CaseIterable, Identifiable, Sendable {
    case summary
    case evidence
    case sensitive
    case receipt

    var id: String { rawValue }

    var title: String {
        switch self {
        case .summary:
            "Summary"
        case .evidence:
            "Evidence"
        case .sensitive:
            "Private detail"
        case .receipt:
            "Receipt"
        }
    }

    var requiresUserIntent: Bool {
        switch self {
        case .summary:
            false
        case .evidence, .sensitive, .receipt:
            true
        }
    }

    var accessibilitySummary: String {
        switch self {
        case .summary:
            "Shows the shortest reviewable explanation."
        case .evidence:
            "Shows source and proof detail after the user asks."
        case .sensitive:
            "Keeps private detail summarized until explicitly opened."
        case .receipt:
            "Shows what changed, why it changed, and how to review it."
        }
    }
}
