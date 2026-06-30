import Foundation

struct UnavailableActionReceiptHistoryRepository: ActionReceiptHistoryRepository {
    func save(_ records: [ActionReceiptHistoryRecord]) async throws {
        _ = records
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "ActionReceiptHistoryRepository")
    }

    func fetch(_ query: ActionReceiptSearchQuery) async throws -> ActionReceiptSearchProjection {
        _ = query
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "ActionReceiptHistoryRepository")
    }

    func listRecords() async throws -> [ActionReceiptHistoryRecord] {
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "ActionReceiptHistoryRepository")
    }
}

struct UnavailableExecutionLedgerReplayInspectionRepository: ExecutionLedgerReplayInspectionRepository {
    func fetch(_ query: ExecutionLedgerReplayInspectionQuery) async throws -> ExecutionLedgerReplayInspectionProjection {
        _ = query
        throw UnavailableRepositoryError.intentionallyOutOfScope(repository: "ExecutionLedgerReplayInspectionRepository")
    }
}
