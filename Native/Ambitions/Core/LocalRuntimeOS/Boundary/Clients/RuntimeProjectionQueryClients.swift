import Foundation

struct RuntimeProjectionQuery: Sendable, Equatable {
    let minimumEventCursor: RuntimeEventCursor?
    let requestedAt: String
}

enum RuntimeQueryTruth<Value: Equatable>: Equatable {
    case available(Value)
    case stale(Value)
    case missing(ProjectionStoreReadRepairReceipt?)
    case unavailable(RuntimeRecovery)
}

func runtimeProjectionQueryTruth<Projection>(
    _ envelope: ProjectionStoreSurfaceReadEnvelope<Projection>
) -> RuntimeQueryTruth<ProjectionStoreSurfaceReadEnvelope<Projection>> where Projection: Codable & Equatable {
    switch envelope.status {
    case .available: .available(envelope)
    case .staleProjection: .stale(envelope)
    case .missingProjection: .missing(envelope.repairReceipt)
    }
}

struct TodayRuntimeQueryClient: Sendable {
    private let read: @Sendable (RuntimeProjectionQuery) async -> RuntimeQueryTruth<ProjectionStoreSurfaceReadEnvelope<TodayProjection>>
    init(read: @escaping @Sendable (RuntimeProjectionQuery) async -> RuntimeQueryTruth<ProjectionStoreSurfaceReadEnvelope<TodayProjection>>) {
        self.read = read
    }
    func query(_ request: RuntimeProjectionQuery) async -> RuntimeQueryTruth<ProjectionStoreSurfaceReadEnvelope<TodayProjection>> {
        await read(request)
    }
}

struct GoalsRuntimeQueryClient: Sendable {
    private let read: @Sendable (RuntimeProjectionQuery) async -> RuntimeQueryTruth<ProjectionStoreSurfaceReadEnvelope<GoalsProjection>>
    init(read: @escaping @Sendable (RuntimeProjectionQuery) async -> RuntimeQueryTruth<ProjectionStoreSurfaceReadEnvelope<GoalsProjection>>) {
        self.read = read
    }
    func query(_ request: RuntimeProjectionQuery) async -> RuntimeQueryTruth<ProjectionStoreSurfaceReadEnvelope<GoalsProjection>> {
        await read(request)
    }
}

struct TimeRuntimeQueryClient: Sendable {
    private let read: @Sendable (RuntimeProjectionQuery) async -> RuntimeQueryTruth<ProjectionStoreSurfaceReadEnvelope<TimeProjection>>
    init(read: @escaping @Sendable (RuntimeProjectionQuery) async -> RuntimeQueryTruth<ProjectionStoreSurfaceReadEnvelope<TimeProjection>>) {
        self.read = read
    }
    func query(_ request: RuntimeProjectionQuery) async -> RuntimeQueryTruth<ProjectionStoreSurfaceReadEnvelope<TimeProjection>> {
        await read(request)
    }
}

struct YouRuntimeQueryClient: Sendable {
    private let read: @Sendable (RuntimeProjectionQuery) async -> RuntimeQueryTruth<ProjectionStoreSurfaceReadEnvelope<YouProjection>>
    init(read: @escaping @Sendable (RuntimeProjectionQuery) async -> RuntimeQueryTruth<ProjectionStoreSurfaceReadEnvelope<YouProjection>>) {
        self.read = read
    }
    func query(_ request: RuntimeProjectionQuery) async -> RuntimeQueryTruth<ProjectionStoreSurfaceReadEnvelope<YouProjection>> {
        await read(request)
    }
}

struct SearchRuntimeQueryClient: Sendable {
    private let read: @Sendable (SearchQuery, RuntimeProjectionQuery) async -> RuntimeQueryTruth<ProjectionBackedSearchReadEnvelope>
    init(read: @escaping @Sendable (SearchQuery, RuntimeProjectionQuery) async -> RuntimeQueryTruth<ProjectionBackedSearchReadEnvelope>) {
        self.read = read
    }
    func query(
        _ query: SearchQuery,
        request: RuntimeProjectionQuery
    ) async -> RuntimeQueryTruth<ProjectionBackedSearchReadEnvelope> {
        await read(query, request)
    }
}
