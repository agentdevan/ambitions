import Foundation

let searchRebuildPipelineSchemaVersion = "search_recall_rebuild_pipeline.native.v1"

struct SearchRebuildReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let indexReceipt: SearchRebuildIndexReceipt
    let projectionStored: Bool
    let invalidation: ProjectionInvalidation?
    let diff: ProjectionDiff?
    let materializedAt: String
    let updatedAt: String
    let localOnly: Bool
    let schemaVersion: String

    init(
        indexReceipt: SearchRebuildIndexReceipt,
        projectionStored: Bool,
        invalidation: ProjectionInvalidation?,
        diff: ProjectionDiff?,
        materializedAt: String,
        updatedAt: String,
        localOnly: Bool = true,
        schemaVersion: String = searchRebuildPipelineSchemaVersion
    ) {
        id = "search-recall.rebuild.\(indexReceipt.cursor.sequence).\(updatedAt)"
        self.indexReceipt = indexReceipt
        self.projectionStored = projectionStored
        self.invalidation = invalidation
        self.diff = diff
        self.materializedAt = materializedAt
        self.updatedAt = updatedAt
        self.localOnly = localOnly
        self.schemaVersion = schemaVersion
    }
}

struct SearchRebuildPipeline: Sendable {
    let eventStore: any RuntimeEventStore
    let ftsIndex: FTSIndex
    let projectionStore: ProjectionStoreSQLite?

    init(
        eventStore: any RuntimeEventStore,
        ftsIndex: FTSIndex,
        projectionStore: ProjectionStoreSQLite? = nil
    ) {
        self.eventStore = eventStore
        self.ftsIndex = ftsIndex
        self.projectionStore = projectionStore
    }

    func rebuild(
        previousCursors: [ProjectionID: ProjectionCursor] = [:],
        materializedAt: String,
        updatedAt: String
    ) async throws -> SearchRebuildReceipt {
        let batch = try await ProjectionMaterializer(store: eventStore).materializeAll(
            previousCursors: previousCursors,
            materializedAt: materializedAt
        )
        if let projectionStore {
            try await projectionStore.save(batch: batch, updatedAt: updatedAt)
        }
        let indexReceipt = try await ftsIndex.rebuild(from: batch.search, updatedAt: updatedAt)
        return SearchRebuildReceipt(
            indexReceipt: indexReceipt,
            projectionStored: projectionStore != nil,
            invalidation: batch.invalidations.first { $0.projectionID == .search },
            diff: batch.diffs.first { $0.projectionID == .search },
            materializedAt: materializedAt,
            updatedAt: updatedAt
        )
    }

    func rebuild(
        projection: SearchProjection,
        invalidation: ProjectionInvalidation? = nil,
        diff: ProjectionDiff? = nil,
        updatedAt: String
    ) async throws -> SearchRebuildReceipt {
        let indexReceipt = try await ftsIndex.rebuild(from: projection, updatedAt: updatedAt)
        return SearchRebuildReceipt(
            indexReceipt: indexReceipt,
            projectionStored: false,
            invalidation: invalidation,
            diff: diff,
            materializedAt: projection.cursor.materializedAt,
            updatedAt: updatedAt
        )
    }
}
