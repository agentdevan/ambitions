import Foundation

enum LifeCalendarStoreError: Error, Equatable {
    case invalidSnapshot(String)
    case persistenceFailed(String)
}

struct LifeCalendarStoreReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let action: String
    let blockIDs: [String]
    let graphID: String
    let persisted: Bool
    let occurredAt: String
    let runtimeTrace: SchedulingRuntimeTrace

    init(action: String, blockIDs: [String], graph: TimeBlockGraph, persisted: Bool, occurredAt: Date) {
        self.action = SchedulingStableID.required(action)
        self.blockIDs = SchedulingStableID.unique(blockIDs)
        graphID = graph.id
        self.persisted = persisted
        self.occurredAt = TemporalMath.string(from: occurredAt)
        runtimeTrace = SchedulingRuntimeTrace.make(
            owner: "LifeCalendarStore",
            sourceID: [self.action, self.blockIDs.joined(separator: ","), graph.id, self.occurredAt].joined(separator: "|"),
            localOnly: graph.localOnly
        )
        id = SchedulingStableID.make(prefix: "life-calendar.receipt", components: [self.action, graph.id, self.occurredAt])
    }
}

private struct LifeCalendarStoreSnapshot: Codable, Sendable, Equatable {
    let schemaVersion: String
    let savedAt: String
    let blocks: [TimeBlock]
}

actor LifeCalendarStore {
    private let fileURL: URL?
    private var blocksByID: [String: TimeBlock]

    init(blocks: [TimeBlock] = [], fileURL: URL? = nil) {
        self.fileURL = fileURL
        blocksByID = Dictionary(uniqueKeysWithValues: blocks.map { ($0.id, $0) })
    }

    func loadFromDisk() throws -> LifeCalendarStoreReceipt? {
        guard let fileURL else { return nil }
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return LifeCalendarStoreReceipt(action: "load-empty", blockIDs: [], graph: graph(), persisted: true, occurredAt: .now)
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let snapshot = try decoder.decode(LifeCalendarStoreSnapshot.self, from: data)
            guard snapshot.schemaVersion == "life_calendar_store.native.v1" else {
                throw LifeCalendarStoreError.invalidSnapshot("Unsupported LifeCalendarStore schema \(snapshot.schemaVersion).")
            }
            blocksByID = Dictionary(uniqueKeysWithValues: snapshot.blocks.map { ($0.id, $0) })
            return LifeCalendarStoreReceipt(action: "load", blockIDs: snapshot.blocks.map(\.id), graph: graph(), persisted: true, occurredAt: .now)
        } catch let error as LifeCalendarStoreError {
            throw error
        } catch {
            throw LifeCalendarStoreError.persistenceFailed(error.localizedDescription)
        }
    }

    func save(_ block: TimeBlock, occurredAt: Date = .now) throws -> LifeCalendarStoreReceipt {
        blocksByID[block.id] = block
        try persistIfNeeded(savedAt: occurredAt)
        return LifeCalendarStoreReceipt(action: "save", blockIDs: [block.id], graph: graph(), persisted: fileURL != nil, occurredAt: occurredAt)
    }

    func save(_ blocks: [TimeBlock], occurredAt: Date = .now) throws -> LifeCalendarStoreReceipt {
        for block in blocks {
            blocksByID[block.id] = block
        }
        try persistIfNeeded(savedAt: occurredAt)
        return LifeCalendarStoreReceipt(action: "save-many", blockIDs: blocks.map(\.id), graph: graph(), persisted: fileURL != nil, occurredAt: occurredAt)
    }

    func delete(blockID: String, occurredAt: Date = .now) throws -> LifeCalendarStoreReceipt {
        blocksByID[blockID] = nil
        try persistIfNeeded(savedAt: occurredAt)
        return LifeCalendarStoreReceipt(action: "delete", blockIDs: [blockID], graph: graph(), persisted: fileURL != nil, occurredAt: occurredAt)
    }

    func fetch(blockID: String) -> TimeBlock? {
        blocksByID[blockID]
    }

    func graph() -> TimeBlockGraph {
        TimeBlockGraph(blocks: Array(blocksByID.values))
    }

    func graph(in window: ProtectedStepPlacementWindow) -> TimeBlockGraph {
        TimeBlockGraph(blocks: blocksByID.values.filter { $0.intersects(window) })
    }

    func objectStateRecords() -> [TimeBlockObjectState] {
        blocksByID.values.sorted { $0.id < $1.id }.map { block in
            TimeBlockObjectState(
                id: block.id,
                title: block.title,
                startsAt: TemporalMath.string(from: block.start),
                endsAt: TemporalMath.string(from: block.end),
                privacyClass: block.privacyClass
            )
        }
    }

    private func persistIfNeeded(savedAt: Date) throws {
        guard let fileURL else { return }
        do {
            let directory = fileURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            let snapshot = LifeCalendarStoreSnapshot(
                schemaVersion: "life_calendar_store.native.v1",
                savedAt: TemporalMath.string(from: savedAt),
                blocks: graph().blocks
            )
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.sortedKeys]
            let data = try encoder.encode(snapshot)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            throw LifeCalendarStoreError.persistenceFailed(error.localizedDescription)
        }
    }
}
