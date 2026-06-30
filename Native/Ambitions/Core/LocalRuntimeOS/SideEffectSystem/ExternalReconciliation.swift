import Foundation

struct ExternalReconciliationSummary: Sendable, Equatable {
    let queuedCount: Int
    let leasedCount: Int
    let confirmationRequiredCount: Int
    let failedSafelyCount: Int
    let blockedCount: Int
    let nextReviewRecordIDs: [String]

    var requiresUserReview: Bool {
        confirmationRequiredCount > 0 || blockedCount > 0 || failedSafelyCount > 0
    }
}

struct ExternalReconciliation: Sendable {
    private let ledger: any SideEffectLedgerRepository

    init(ledger: any SideEffectLedgerRepository) {
        self.ledger = ledger
    }

    func summarize(limit: Int = 50) async throws -> ExternalReconciliationSummary {
        let records = try await ledger.fetchRecent(limit: limit)
        let reviewStatuses: Set<SideEffectLedgerStatus> = [.confirmationRequired, .failedSafely, .blocked]
        return ExternalReconciliationSummary(
            queuedCount: records.filter { $0.status == .queued }.count,
            leasedCount: records.filter { $0.status == .leased }.count,
            confirmationRequiredCount: records.filter { $0.status == .confirmationRequired }.count,
            failedSafelyCount: records.filter { $0.status == .failedSafely }.count,
            blockedCount: records.filter { $0.status == .blocked }.count,
            nextReviewRecordIDs: records
                .filter { reviewStatuses.contains($0.status) }
                .map(\.id)
        )
    }
}
