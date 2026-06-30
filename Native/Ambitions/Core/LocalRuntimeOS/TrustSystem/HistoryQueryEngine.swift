import Foundation

struct HistoryQueryEngine: Sendable {
    func project(
        query: TrustHistoryQuery,
        receiptRecords: [ActionReceiptHistoryRecord],
        eventLedgerEntries: [EventLedgerEntry]
    ) -> TrustHistoryQueryProjection {
        var items: [TrustHistoryQueryResult] = []

        if query.includeReceiptHistory {
            items.append(contentsOf: receiptRecords
                .filter { matches($0, query: query) }
                .map(makeResult(from:)))
        }

        if query.includeEventLedger {
            items.append(contentsOf: eventLedgerEntries
                .filter { matches($0, query: query) }
                .map(makeResult(from:)))
        }

        let sorted = items.sorted {
            let lhsDate = PersistedTemporalValue.date(from: $0.occurredAt)
            let rhsDate = PersistedTemporalValue.date(from: $1.occurredAt)
            if lhsDate != rhsDate { return lhsDate > rhsDate }
            if $0.kind != $1.kind {
                return $0.kind == .actionReceipt && $1.kind == .eventLedger
            }
            return $0.id < $1.id
        }

        let bounded = max(0, query.limit ?? sorted.count)
        let results = Array(sorted.prefix(min(bounded, sorted.count)))

        return TrustHistoryQueryProjection(
            query: query,
            results: results,
            totalMatchCount: sorted.count,
            emptyTitle: "Nothing matched",
            emptyDetail: "Try a different query or relax review and proof filters.",
            localOnly: results.allSatisfy(\.localOnly)
        )
    }

    func makeResult(from record: ActionReceiptHistoryRecord) -> TrustHistoryQueryResult {
        TrustHistoryQueryResult(
            id: "receipt.\(record.receipt.id)",
            kind: .actionReceipt,
            source: record.receipt.sourceDomain.rawValue,
            occurredAt: record.receipt.occurredAt,
            privacy: record.privacyLevel.rawValue,
            proofRelevance: record.proofRelevance,
            trustStatus: record.trustStatus,
            requiresReview: nil,
            userConfirmed: nil,
            proofReferenceKinds: [],
            localOnly: record.localOnly,
            title: record.receipt.title,
            summary: record.receipt.summary,
            proofFreshnessLineage: record.proofFreshnessLineage
        )
    }

    func makeResult(from event: EventLedgerEntry) -> TrustHistoryQueryResult {
        TrustHistoryQueryResult(
            id: "event.\(event.id)",
            kind: .eventLedger,
            source: event.source.rawValue,
            occurredAt: event.occurredAt,
            privacy: event.privacy.rawValue,
            proofRelevance: nil,
            trustStatus: nil,
            requiresReview: event.trust.requiresReview,
            userConfirmed: event.trust.isUserConfirmed,
            proofReferenceKinds: event.evidenceReferences
                .map(\.kind)
                .sorted { $0.rawValue < $1.rawValue },
            localOnly: event.localOnly,
            title: event.title,
            summary: event.summary ?? "",
            proofFreshnessLineage: nil
        )
    }

    func matches(_ record: ActionReceiptHistoryRecord, query: TrustHistoryQuery) -> Bool {
        if query.includeReceiptHistory == false { return false }
        let occurredAtDate = PersistedTemporalValue.date(from: record.receipt.occurredAt)
        if let startDate = query.startDate, occurredAtDate < PersistedTemporalValue.date(from: startDate) { return false }
        if let endDate = query.endDate, occurredAtDate > PersistedTemporalValue.date(from: endDate, fallback: .distantFuture) { return false }
        if query.receiptSourceDomains.isEmpty == false && query.receiptSourceDomains.contains(record.receipt.sourceDomain) == false { return false }
        if query.receiptPrivacyLevels.isEmpty == false && query.receiptPrivacyLevels.contains(record.privacyLevel) == false { return false }
        if query.receiptProofRelevance.isEmpty == false && query.receiptProofRelevance.contains(record.proofRelevance) == false { return false }
        if query.receiptTrustStatuses.isEmpty == false && query.receiptTrustStatuses.contains(record.trustStatus) == false { return false }
        if let requiresFreshnessReview = query.receiptRequiresFreshnessReview,
           record.proofFreshnessLineage.requiresFreshnessReview != requiresFreshnessReview {
            return false
        }
        return true
    }

    func matches(_ event: EventLedgerEntry, query: TrustHistoryQuery) -> Bool {
        if query.includeEventLedger == false { return false }
        let occurredAtDate = PersistedTemporalValue.date(from: event.occurredAt)
        if let startDate = query.startDate, occurredAtDate < PersistedTemporalValue.date(from: startDate) { return false }
        if let endDate = query.endDate, occurredAtDate > PersistedTemporalValue.date(from: endDate, fallback: .distantFuture) { return false }
        if query.eventSources.isEmpty == false && query.eventSources.contains(event.source) == false { return false }
        if query.eventPrivacyLevels.isEmpty == false && query.eventPrivacyLevels.contains(event.privacy) == false { return false }
        if let requiresReview = query.requiresReview, event.trust.requiresReview != requiresReview { return false }
        if let userConfirmed = query.userConfirmed, event.trust.isUserConfirmed != userConfirmed { return false }
        if let requiresProofReferences = query.requiresProofReferences,
           event.evidenceReferences.isEmpty == requiresProofReferences {
            return false
        }
        if query.proofReferenceKinds.isEmpty == false,
           event.evidenceReferences.map(\.kind).contains(where: { query.proofReferenceKinds.contains($0) }) == false {
            return false
        }
        return true
    }
}
