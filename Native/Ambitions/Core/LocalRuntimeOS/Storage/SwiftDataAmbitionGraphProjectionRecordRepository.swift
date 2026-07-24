import AmbitionsDesignSystem
import Foundation
import SwiftData

struct SwiftDataAmbitionGraphProjectionRecordRepository: AmbitionGraphProjectionRecordRepository {
    let store: AmbitionsPersistenceStore

    func save(_ records: [AmbitionGraphProjectionRecord]) async throws {
        try await store.write { context in
            let persisted = Dictionary(
                uniqueKeysWithValues: try context.fetch(FetchDescriptor<AmbitionGraphProjectionRecordModel>()).map { ($0.id, $0) }
            )

            for record in records {
                if let current = persisted[record.id] {
                    try RepositoryMapping.apply(record, to: current)
                } else {
                    context.insert(try RepositoryMapping.ambitionGraphProjectionRecordModel(from: record))
                }
            }
        }
    }

    func fetchRecords(
        surface: AmbitionGraphProjectionSurface?,
        snapshotID: String?,
        limit: Int?
    ) async throws -> [AmbitionGraphProjectionRecord] {
        try await store.read { context in
            let records = try context.fetch(FetchDescriptor<AmbitionGraphProjectionRecordModel>())
                .filter { model in
                    if let surface, model.surfaceRaw != surface.rawValue {
                        return false
                    }
                    if let snapshotID, model.sourceSnapshotID != snapshotID {
                        return false
                    }
                    return true
                }
                .sorted {
                    if $0.generatedAt != $1.generatedAt {
                        return $0.generatedAt > $1.generatedAt
                    }
                    if $0.surfaceRaw != $1.surfaceRaw {
                        return $0.surfaceRaw < $1.surfaceRaw
                    }
                    return $0.id < $1.id
                }

            let bounded = limit.map { max(0, $0) } ?? records.count
            return try records
                .prefix(bounded)
                .map(RepositoryMapping.ambitionGraphProjectionRecord(from:))
        }
    }
}

actor InMemoryGoalTeachingSignalRepository: GoalTeachingSignalRepository {
    var signals: [GoalTeachingSignal] = []

    func listSignals(goalID: String?) async throws -> [GoalTeachingSignal] {
        signals
            .filter { goalID == nil || $0.goalID == goalID }
            .sorted {
                if $0.updatedAt != $1.updatedAt {
                    return $0.updatedAt > $1.updatedAt
                }
                return $0.id > $1.id
            }
    }

    func saveSignals(_ signals: [GoalTeachingSignal]) async throws {
        let incomingByID = Dictionary(uniqueKeysWithValues: signals.map { ($0.id, $0) })
        self.signals.removeAll { incomingByID[$0.id] != nil }
        self.signals.append(contentsOf: signals)
    }
}

actor InMemoryAmbitionsCommandExecutionRecordRepository: AmbitionsCommandExecutionRecordRepository {
    var records: [AmbitionsCommandExecutionRecord] = []

    func append(_ record: AmbitionsCommandExecutionRecord) async throws {
        records.removeAll { $0.command.id == record.command.id }
        records.append(record)
    }

    func fetchRecent(limit: Int) async throws -> [StoredCommandExecutionRecord] {
        Array(records.sorted { lhs, rhs in
            let lhsDate = PersistedTemporalValue.date(from: lhs.recordedAt)
            let rhsDate = PersistedTemporalValue.date(from: rhs.recordedAt)
            if lhsDate == rhsDate {
                return lhs.command.id > rhs.command.id
            }
            return lhsDate > rhsDate
        }.prefix(max(0, limit))).map(StoredCommandExecutionRecord.supported)
    }

    func fetchRecord(commandID: String) async throws -> StoredCommandExecutionRecord? {
        records
            .sorted {
                let lhsDate = PersistedTemporalValue.date(from: $0.recordedAt)
                let rhsDate = PersistedTemporalValue.date(from: $1.recordedAt)
                if lhsDate == rhsDate {
                    return $0.command.id > $1.command.id
                }
                return lhsDate > rhsDate
            }
            .first(where: { $0.command.id == commandID })
            .map(StoredCommandExecutionRecord.supported)
    }
}
