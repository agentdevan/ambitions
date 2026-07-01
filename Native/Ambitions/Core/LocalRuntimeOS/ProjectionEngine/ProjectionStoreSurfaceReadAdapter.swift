import Foundation

let projectionStoreSurfaceReadAdapterSchemaVersion = "projection_store_surface_read_adapter.native.v1"

enum ProjectionStoreSurfaceReadStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case available
    case staleProjection = "stale_projection"
    case missingProjection = "missing_projection"
}

enum ProjectionStoreFallbackRole: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case rebuildInputOnly = "repository_backed_rebuild_input_only"
}

struct ProjectionStoreReadRepairReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let projectionID: ProjectionID
    let reason: ProjectionStoreSurfaceReadStatus
    let minimumEventSequence: Int64?
    let observedEventSequence: Int64?
    let safeRebuildRequired: Bool
    let fallbackRole: ProjectionStoreFallbackRole
    let rebuildOwners: [String]
    let inspectedAt: String
    let schemaVersion: String

    init(
        projectionID: ProjectionID,
        reason: ProjectionStoreSurfaceReadStatus,
        minimumEventSequence: Int64?,
        observedEventSequence: Int64?,
        inspectedAt: String,
        schemaVersion: String = projectionStoreSurfaceReadAdapterSchemaVersion
    ) {
        self.id = "projection-store.read-repair.\(projectionID.rawValue).\(reason.rawValue).\(inspectedAt)"
        self.projectionID = projectionID
        self.reason = reason
        self.minimumEventSequence = minimumEventSequence
        self.observedEventSequence = observedEventSequence
        self.safeRebuildRequired = true
        self.fallbackRole = .rebuildInputOnly
        self.rebuildOwners = [
            "Core/LocalRuntimeOS/TransactionKernel/RuntimeTransactionCoordinator",
            "Core/LocalRuntimeOS/SearchRecall/SearchRebuildPipeline",
        ]
        self.inspectedAt = inspectedAt
        self.schemaVersion = schemaVersion
    }
}

struct ProjectionStoreSurfaceReadEnvelope<Projection: Codable & Equatable>: Equatable {
    let projectionID: ProjectionID
    let projection: Projection?
    let cursor: ProjectionCursor?
    let payloadChecksum: String?
    let materializedAt: String?
    let updatedAt: String?
    let status: ProjectionStoreSurfaceReadStatus
    let source: LocalRuntimeStorageTier
    let fallbackRole: ProjectionStoreFallbackRole
    let repairReceipt: ProjectionStoreReadRepairReceipt?
    let schemaVersion: String

    var isSurfaceReadable: Bool {
        status == .available && projection != nil
    }
}

struct ProjectionBackedSearchReadEnvelope: Equatable {
    let projectionState: ProjectionStoreSurfaceReadEnvelope<SearchProjection>
    let results: [FindActInspectResult]
    let indexHealth: FTSIndexHealth?
    let source: LocalRuntimeStorageTier
    let fallbackRole: ProjectionStoreFallbackRole
    let searchedAt: String
    let schemaVersion: String

    var isSurfaceReadable: Bool {
        projectionState.isSurfaceReadable
    }
}

struct ProjectionStoreSurfaceReadAdapter {
    let projectionStore: ProjectionStoreSQLite
    let searchIndex: FTSIndex

    init(projectionStore: ProjectionStoreSQLite, searchIndex: FTSIndex) {
        self.projectionStore = projectionStore
        self.searchIndex = searchIndex
    }

    func readToday(
        minimumEventCursor: RuntimeEventCursor? = nil,
        inspectedAt: String
    ) async throws -> ProjectionStoreSurfaceReadEnvelope<TodayProjection> {
        try await readProjection(.today, as: TodayProjection.self, minimumEventCursor: minimumEventCursor, inspectedAt: inspectedAt)
    }

    func readGoals(
        minimumEventCursor: RuntimeEventCursor? = nil,
        inspectedAt: String
    ) async throws -> ProjectionStoreSurfaceReadEnvelope<GoalsProjection> {
        try await readProjection(.goals, as: GoalsProjection.self, minimumEventCursor: minimumEventCursor, inspectedAt: inspectedAt)
    }

    func readTime(
        minimumEventCursor: RuntimeEventCursor? = nil,
        inspectedAt: String
    ) async throws -> ProjectionStoreSurfaceReadEnvelope<TimeProjection> {
        try await readProjection(.time, as: TimeProjection.self, minimumEventCursor: minimumEventCursor, inspectedAt: inspectedAt)
    }

    func readYou(
        minimumEventCursor: RuntimeEventCursor? = nil,
        inspectedAt: String
    ) async throws -> ProjectionStoreSurfaceReadEnvelope<YouProjection> {
        try await readProjection(.you, as: YouProjection.self, minimumEventCursor: minimumEventCursor, inspectedAt: inspectedAt)
    }

    func readSearchProjection(
        minimumEventCursor: RuntimeEventCursor? = nil,
        inspectedAt: String
    ) async throws -> ProjectionStoreSurfaceReadEnvelope<SearchProjection> {
        try await readProjection(.search, as: SearchProjection.self, minimumEventCursor: minimumEventCursor, inspectedAt: inspectedAt)
    }

    func search(
        _ query: SearchRecallQuery,
        minimumEventCursor: RuntimeEventCursor? = nil,
        searchedAt: String
    ) async throws -> ProjectionBackedSearchReadEnvelope {
        let projectionState = try await readSearchProjection(
            minimumEventCursor: minimumEventCursor,
            inspectedAt: searchedAt
        )
        guard projectionState.isSurfaceReadable else {
            return ProjectionBackedSearchReadEnvelope(
                projectionState: projectionState,
                results: [],
                indexHealth: nil,
                source: .searchStoreFTS,
                fallbackRole: .rebuildInputOnly,
                searchedAt: searchedAt,
                schemaVersion: projectionStoreSurfaceReadAdapterSchemaVersion
            )
        }

        return ProjectionBackedSearchReadEnvelope(
            projectionState: projectionState,
            results: try await searchIndex.search(query, searchedAt: searchedAt),
            indexHealth: try await searchIndex.health(),
            source: .searchStoreFTS,
            fallbackRole: .rebuildInputOnly,
            searchedAt: searchedAt,
            schemaVersion: projectionStoreSurfaceReadAdapterSchemaVersion
        )
    }

    private func readProjection<Projection: Codable & Equatable>(
        _ projectionID: ProjectionID,
        as projectionType: Projection.Type,
        minimumEventCursor: RuntimeEventCursor?,
        inspectedAt: String
    ) async throws -> ProjectionStoreSurfaceReadEnvelope<Projection> {
        guard let record = try await projectionStore.fetchRecord(id: projectionID) else {
            return unavailableEnvelope(
                projectionID: projectionID,
                status: .missingProjection,
                minimumEventCursor: minimumEventCursor,
                observedCursor: nil,
                inspectedAt: inspectedAt
            )
        }

        let decoded = try LocalRuntimeStorageCoding.decode(projectionType, from: record.payloadData)
        if let minimumEventCursor, record.cursor.sequence < minimumEventCursor.sequence {
            return ProjectionStoreSurfaceReadEnvelope(
                projectionID: projectionID,
                projection: decoded,
                cursor: record.cursor,
                payloadChecksum: record.payloadChecksum,
                materializedAt: record.materializedAt,
                updatedAt: record.updatedAt,
                status: .staleProjection,
                source: .projectionStoreSQLite,
                fallbackRole: .rebuildInputOnly,
                repairReceipt: ProjectionStoreReadRepairReceipt(
                    projectionID: projectionID,
                    reason: .staleProjection,
                    minimumEventSequence: minimumEventCursor.sequence,
                    observedEventSequence: record.cursor.sequence,
                    inspectedAt: inspectedAt
                ),
                schemaVersion: projectionStoreSurfaceReadAdapterSchemaVersion
            )
        }

        return ProjectionStoreSurfaceReadEnvelope(
            projectionID: projectionID,
            projection: decoded,
            cursor: record.cursor,
            payloadChecksum: record.payloadChecksum,
            materializedAt: record.materializedAt,
            updatedAt: record.updatedAt,
            status: .available,
            source: .projectionStoreSQLite,
            fallbackRole: .rebuildInputOnly,
            repairReceipt: nil,
            schemaVersion: projectionStoreSurfaceReadAdapterSchemaVersion
        )
    }

    private func unavailableEnvelope<Projection: Codable & Equatable>(
        projectionID: ProjectionID,
        status: ProjectionStoreSurfaceReadStatus,
        minimumEventCursor: RuntimeEventCursor?,
        observedCursor: ProjectionCursor?,
        inspectedAt: String
    ) -> ProjectionStoreSurfaceReadEnvelope<Projection> {
        ProjectionStoreSurfaceReadEnvelope(
            projectionID: projectionID,
            projection: nil,
            cursor: observedCursor,
            payloadChecksum: nil,
            materializedAt: observedCursor?.materializedAt,
            updatedAt: nil,
            status: status,
            source: .projectionStoreSQLite,
            fallbackRole: .rebuildInputOnly,
            repairReceipt: ProjectionStoreReadRepairReceipt(
                projectionID: projectionID,
                reason: status,
                minimumEventSequence: minimumEventCursor?.sequence,
                observedEventSequence: observedCursor?.sequence,
                inspectedAt: inspectedAt
            ),
            schemaVersion: projectionStoreSurfaceReadAdapterSchemaVersion
        )
    }
}
