import Foundation

struct RuntimeEventCompactionSnapshot: Codable, Equatable, Hashable {
    let cursor: RuntimeEventCursor
    let eventCount: Int
    let eventCountByKind: [RuntimeEventKind: Int]
    let commandEventCount: Int
    let tombstoneEventCount: Int
    let checksumHead: String
    let createdAt: String

    init(envelopes: [RuntimeEventEnvelope], createdAt: String) throws {
        guard let cursor = envelopes.last?.cursor else {
            throw RuntimeEventCompactorError.emptyJournal
        }
        self.cursor = cursor
        eventCount = envelopes.count
        eventCountByKind = Dictionary(grouping: envelopes.map(\.event.kind), by: { $0 })
            .mapValues(\.count)
        commandEventCount = eventCountByKind[.commandExecution] ?? 0
        tombstoneEventCount = eventCountByKind[.tombstoneRecorded] ?? 0
        checksumHead = cursor.checksum
        self.createdAt = createdAt
    }
}

enum RuntimeEventCompactorError: Error, Equatable {
    case emptyJournal
}

struct RuntimeEventCompactor {
    let store: any RuntimeEventStore

    func makeSnapshot(createdAt: String) async throws -> RuntimeEventCompactionSnapshot {
        let envelopes = try await store.fetchEvents(matching: .all, limit: nil)
        return try RuntimeEventCompactionSnapshot(envelopes: envelopes, createdAt: createdAt)
    }

    @discardableResult
    func appendSnapshotEvent(createdAt: String) async throws -> RuntimeEventEnvelope {
        let snapshot = try await makeSnapshot(createdAt: createdAt)
        return try await store.append(
            RuntimeEvent(
                actor: .system,
                source: .system,
                occurredAt: createdAt,
                payload: .compactionSnapshot(snapshot),
                metadata: [
                    "compactedThroughSequence": String(snapshot.cursor.sequence),
                    "compactedThroughEventID": snapshot.cursor.eventID,
                ]
            )
        )
    }
}
