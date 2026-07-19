import Foundation

struct ProofLedger: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let generatedAt: String
    let events: [ProofEvent]
    let eventLedgerEntryIDs: [String]
    let recommendationExplanationIDs: [String]
    let runtimeLineages: [RuntimeTrustLineage]
    let localOnly: Bool
    let privacy: EventLedgerPrivacyClassification

    init(
        id: String,
        generatedAt: String,
        events: [ProofEvent] = [],
        eventLedgerEntryIDs: [String] = [],
        recommendationExplanationIDs: [String] = [],
        runtimeLineages: [RuntimeTrustLineage] = [],
        localOnly: Bool = true,
        privacy: EventLedgerPrivacyClassification = .standard
    ) {
        self.id = Self.normalized(id, fallback: "runtime.proof-ledger")
        self.generatedAt = Self.normalized(generatedAt, fallback: "unknown")
        self.events = events.sorted { $0.id < $1.id }
        self.eventLedgerEntryIDs = Self.orderedUnique(eventLedgerEntryIDs)
        self.recommendationExplanationIDs = Self.orderedUnique(recommendationExplanationIDs)
        self.runtimeLineages = Self.orderedUnique(runtimeLineages)
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
            runtimeLineages: [],
            localOnly: nowState.localOnly,
            privacy: nowState.privacy
        )
    }

    init(
        proofLedgerEntry: ActionReceiptProofLedgerEntry,
        eventLedgerEntryID: String,
        generatedAt: String
    ) {
        self.init(
            id: "runtime.proof-ledger.\(proofLedgerEntry.receipt.id)",
            generatedAt: generatedAt,
            events: [],
            eventLedgerEntryIDs: [eventLedgerEntryID],
            recommendationExplanationIDs: [],
            runtimeLineages: [proofLedgerEntry.runtimeLineage].compactMap { $0 },
            localOnly: proofLedgerEntry.localOnly,
            privacy: proofLedgerEntry.receiptRecord.privacyLevel.eventLedgerPrivacy
        )
    }

    var confirmedEventIDs: [String] {
        events.filter(\.userConfirmed).map(\.id)
    }

    var hasInspectableProof: Bool {
        events.isEmpty == false || eventLedgerEntryIDs.isEmpty == false || recommendationExplanationIDs.isEmpty == false
    }

    var runtimeTransactionIDs: [String] {
        runtimeLineages.map(\.runtimeTransactionID)
    }

    var runtimeEventIDs: [String] {
        runtimeLineages.map(\.runtimeEventID)
    }

    var runtimeCommitReceiptIDs: [String] {
        runtimeLineages.map(\.runtimeCommitReceiptID)
    }

    var runtimeReplayTraceIDs: [String] {
        runtimeLineages.map(\.runtimeReplayTraceID)
    }

    var hasRuntimeLineage: Bool {
        runtimeLineages.isEmpty == false &&
            runtimeLineages.allSatisfy(\.hasCompleteTrustTrace)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.filter { $0.isEmpty == false })).sorted()
    }

    private static func orderedUnique(_ values: [RuntimeTrustLineage]) -> [RuntimeTrustLineage] {
        var seen = Set<String>()
        return values
            .filter { $0.id.isEmpty == false }
            .filter { seen.insert($0.id).inserted }
            .sorted { $0.id < $1.id }
    }

    private static func normalized(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }
}
