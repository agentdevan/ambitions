import Foundation

struct RuntimeExplanationPolicy: Equatable, Sendable {
    let sourceLevel: TrustDisclosureLevel
    let proofLevel: TrustDisclosureLevel
    let privacyLevel: TrustDisclosureLevel
    let historyLevel: TrustDisclosureLevel
    let receiptLevel: TrustDisclosureLevel
    let localOnlySummary: String
    let correctionSummary: String

    static let rootSummary = RuntimeExplanationPolicy(
        sourceLevel: .summary,
        proofLevel: .summary,
        privacyLevel: .summary,
        historyLevel: .summary,
        receiptLevel: .summary,
        localOnlySummary: "Private life details stay on this iPhone unless the user chooses otherwise.",
        correctionSummary: "Every meaningful change keeps a review path."
    )

    static let detailInspection = RuntimeExplanationPolicy(
        sourceLevel: .evidence,
        proofLevel: .evidence,
        privacyLevel: .sensitive,
        historyLevel: .summary,
        receiptLevel: .receipt,
        localOnlySummary: "Review opens context without turning private data into a feed.",
        correctionSummary: "Review, undo, and correction stay attached to the owning surface."
    )

    func disclosureLevel(for kind: TrustInspectionKind) -> TrustDisclosureLevel {
        switch kind {
        case .proof:
            proofLevel
        case .source:
            sourceLevel
        case .privacy:
            privacyLevel
        case .history:
            historyLevel
        case .receipt:
            receiptLevel
        }
    }

    func explanation(for kind: TrustInspectionKind) -> String {
        switch kind {
        case .proof:
            "Shows why a completed step, correction, or saved detail counts."
        case .source:
            "Shows which local record shaped the recommendation."
        case .privacy:
            localOnlySummary
        case .history:
            "Shows recent changes as reviewable continuity, not an activity feed."
        case .receipt:
            correctionSummary
        }
    }
}
