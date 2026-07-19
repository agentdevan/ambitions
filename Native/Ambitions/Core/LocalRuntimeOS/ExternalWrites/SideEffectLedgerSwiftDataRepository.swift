import Foundation
import SwiftData

struct SwiftDataSideEffectLedgerRepository: SideEffectLedgerRepository {
    let store: AmbitionsPersistenceStore

    func append(_ record: SideEffectLedgerRecord) async throws {
        guard record.isWellFormed else { return }
        try await store.write { context in
            if let storage = try context.fetch(FetchDescriptor<SideEffectLedgerStorageRecord>())
                .first(where: { $0.id == record.id }) {
                try RepositoryMapping.apply(record, to: storage)
            } else {
                context.insert(try RepositoryMapping.sideEffectLedgerStorageRecord(from: record))
            }
        }
    }

    func fetchRecent(limit: Int) async throws -> [SideEffectLedgerRecord] {
        Array(try await fetchAll { _ in true }.prefix(max(0, limit)))
    }

    func fetchRecords(status: SideEffectLedgerStatus) async throws -> [SideEffectLedgerRecord] {
        try await fetchAll { $0.statusRaw == status.rawValue }
    }

    func fetchRecord(id: String) async throws -> SideEffectLedgerRecord? {
        try await store.read { context in
            try context.fetch(FetchDescriptor<SideEffectLedgerStorageRecord>())
                .first(where: { $0.id == id })
                .map(RepositoryMapping.sideEffectLedgerRecord(from:))
        }
    }

    private func fetchAll(where isIncluded: @escaping @Sendable (SideEffectLedgerStorageRecord) -> Bool) async throws -> [SideEffectLedgerRecord] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<SideEffectLedgerStorageRecord>())
                .filter(isIncluded)
                .sorted {
                    let lhsDate = PersistedTemporalValue.dateKey(primary: $0.occurredAtDate, rawValue: $0.occurredAt)
                    let rhsDate = PersistedTemporalValue.dateKey(primary: $1.occurredAtDate, rawValue: $1.occurredAt)
                    if lhsDate != rhsDate {
                        return lhsDate > rhsDate
                    }
                    return $0.id < $1.id
                }
                .map(RepositoryMapping.sideEffectLedgerRecord(from:))
        }
    }
}
