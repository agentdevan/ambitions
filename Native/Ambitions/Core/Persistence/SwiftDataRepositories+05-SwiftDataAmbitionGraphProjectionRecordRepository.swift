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

actor InMemoryEventLedgerRepository: EventLedgerRepository {
    var events: [EventLedgerEntry] = []

    func append(_ event: EventLedgerEntry) async throws {
        events.removeAll { $0.id == event.id }
        events.append(event)
    }

    func fetchRecent(limit: Int) async throws -> [EventLedgerEntry] {
        Array(sorted(events).prefix(max(0, limit)))
    }

    func fetchEvents(goalID: String) async throws -> [EventLedgerEntry] {
        sorted(events.filter { $0.goalID == goalID })
    }

    func fetchEvents(captureID: String) async throws -> [EventLedgerEntry] {
        sorted(events.filter { $0.captureID == captureID })
    }

    func fetchEvents(kind: EventLedgerKind) async throws -> [EventLedgerEntry] {
        sorted(events.filter { $0.kind == kind })
    }

    func fetchEvents(from start: String, through end: String) async throws -> [EventLedgerEntry] {
        let startDate = PersistedTemporalValue.date(from: start)
        let endDate = PersistedTemporalValue.date(from: end, fallback: .distantFuture)
        return sorted(events.filter {
            let occurredAtDate = PersistedTemporalValue.date(from: $0.occurredAt)
            return occurredAtDate >= startDate && occurredAtDate <= endDate
        })
    }

    func redactEvent(id: String, at timestamp: String) async throws {
        events = events.map { event in
            event.id == id ? event.redacted(at: timestamp) : event
        }
    }

    func deleteEvent(id: String) async throws {
        events.removeAll { $0.id == id }
    }

    func sorted(_ events: [EventLedgerEntry]) -> [EventLedgerEntry] {
        events.sorted {
            let lhsDate = PersistedTemporalValue.date(from: $0.occurredAt)
            let rhsDate = PersistedTemporalValue.date(from: $1.occurredAt)
            if lhsDate != rhsDate {
                return lhsDate > rhsDate
            }
            return $0.id > $1.id
        }
    }
}

actor InMemoryAmbitionsCommandExecutionRecordRepository: AmbitionsCommandExecutionRecordRepository {
    var records: [AmbitionsCommandExecutionRecord] = []

    func append(_ record: AmbitionsCommandExecutionRecord) async throws {
        records.removeAll { $0.command.id == record.command.id }
        records.append(record)
    }

    func fetchRecent(limit: Int) async throws -> [AmbitionsCommandExecutionRecord] {
        Array(records.sorted { lhs, rhs in
            let lhsDate = PersistedTemporalValue.date(from: lhs.recordedAt)
            let rhsDate = PersistedTemporalValue.date(from: rhs.recordedAt)
            if lhsDate == rhsDate {
                return lhs.command.id > rhs.command.id
            }
            return lhsDate > rhsDate
        }.prefix(max(0, limit)))
    }

    func fetchRecord(commandID: String) async throws -> AmbitionsCommandExecutionRecord? {
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
    }
}

struct SwiftDataEntityRevisionTombstoneRepository: EntityRevisionTombstoneRepository {
    let store: AmbitionsPersistenceStore

    func append(_ tombstone: EntityRevisionTombstone) async throws {
        guard tombstone.isWellFormed else { return }
        try await store.write { context in
            if let storage = try context.fetch(FetchDescriptor<EntityRevisionTombstoneRecord>())
                .first(where: { $0.id == tombstone.id }) {
                try RepositoryMapping.apply(tombstone, to: storage)
            } else {
                context.insert(try RepositoryMapping.entityRevisionTombstoneRecord(from: tombstone))
            }
        }
    }

    func fetchRecent(limit: Int) async throws -> [EntityRevisionTombstone] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<EntityRevisionTombstoneRecord>())
                .sorted {
                    let lhsDate = PersistedTemporalValue.dateKey(primary: $0.recordedAtDate, rawValue: $0.recordedAt)
                    let rhsDate = PersistedTemporalValue.dateKey(primary: $1.recordedAtDate, rawValue: $1.recordedAt)
                    if lhsDate != rhsDate {
                        return lhsDate > rhsDate
                    }
                    return $0.id > $1.id
                }
                .prefix(max(0, limit))
                .map(RepositoryMapping.entityRevisionTombstone(from:))
        }
    }

    func fetch(for entityID: String) async throws -> [EntityRevisionTombstone] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<EntityRevisionTombstoneRecord>())
                .filter { $0.entityID == entityID }
                .sorted {
                    let lhsDate = PersistedTemporalValue.dateKey(primary: $0.recordedAtDate, rawValue: $0.recordedAt)
                    let rhsDate = PersistedTemporalValue.dateKey(primary: $1.recordedAtDate, rawValue: $1.recordedAt)
                    if lhsDate != rhsDate {
                        return lhsDate > rhsDate
                    }
                    return $0.id > $1.id
                }
                .map(RepositoryMapping.entityRevisionTombstone(from:))
        }
    }

    func fetch(lineageID: String) async throws -> [EntityRevisionTombstone] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<EntityRevisionTombstoneRecord>())
                .filter { $0.lineageID == lineageID }
                .sorted {
                    let lhsDate = PersistedTemporalValue.dateKey(primary: $0.recordedAtDate, rawValue: $0.recordedAt)
                    let rhsDate = PersistedTemporalValue.dateKey(primary: $1.recordedAtDate, rawValue: $1.recordedAt)
                    if lhsDate != rhsDate {
                        return lhsDate > rhsDate
                    }
                    return $0.id > $1.id
                }
                .map(RepositoryMapping.entityRevisionTombstone(from:))
        }
    }

    func fetchRecoverable(limit: Int) async throws -> [EntityRevisionTombstone] {
        try await fetchByLifecycleState(.recoverable, limit: limit)
    }

    func fetchFinalized(limit: Int) async throws -> [EntityRevisionTombstone] {
        try await fetchByLifecycleState(.finalized, limit: limit)
    }

    func fetchByLifecycleState(_ lifecycleState: EntityRevisionTombstoneLifecycleState, limit: Int) async throws -> [EntityRevisionTombstone] {
        try await store.read { context in
            try context.fetch(FetchDescriptor<EntityRevisionTombstoneRecord>())
                .filter { $0.lifecycleStateRaw == lifecycleState.rawValue }
                .sorted {
                    let lhsDate = PersistedTemporalValue.dateKey(primary: $0.recordedAtDate, rawValue: $0.recordedAt)
                    let rhsDate = PersistedTemporalValue.dateKey(primary: $1.recordedAtDate, rawValue: $1.recordedAt)
                    if lhsDate != rhsDate {
                        return lhsDate > rhsDate
                    }
                    return $0.id > $1.id
                }
                .prefix(max(0, limit))
                .map(RepositoryMapping.entityRevisionTombstone(from:))
        }
    }
}
