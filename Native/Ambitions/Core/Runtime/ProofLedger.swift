import Foundation

struct ProofLedger: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let generatedAt: String
    let events: [ProofEvent]
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification

    init(
        id: String,
        generatedAt: String,
        events: [ProofEvent] = [],
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = [],
        localOnly: Bool = true,
        privacy: EventLedgerPrivacyClassification = .standard
    ) {
        self.id = Self.normalized(id, fallback: "runtime.proof-ledger")
        self.generatedAt = Self.normalized(generatedAt, fallback: "unknown")
        self.events = events.sorted { $0.id < $1.id }
        self.eventLedgerEntryIDs = Self.orderedUnique(eventLedgerEntryIDs)
        self.recommendationExplanationIDs = Self.orderedUnique(recommendationExplanationIDs)
        self.localOnly = localOnly
        self.privacy = privacy
    }

    init(
        nowState: CanonicalNowState,
        proofs: [Proof] = []
    ) {
        self.init(
            id: "runtime.proof-ledger.\(nowState.id)",
            generatedAt: nowState.generatedAt,
            events: proofs.map(\.proofEvent),
            eventLedgerEntryIDs: nowState.eventLedgerEntryIDs,
            recommendationExplanationIDs: nowState.recommendationExplanationIDs,
            localOnly: nowState.localOnly,
            privacy: nowState.privacy
        )
    }

    var confirmedEventIDs: [String] {
        events.filter(\.userConfirmed).map(\.id)
    }

    var hasInspectableProof: Bool {
        events.isEmpty == false || eventLedgerEntryIDs.isEmpty == false || recommendationExplanationIDs.isEmpty == false
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }

    private static func normalized(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }
}
