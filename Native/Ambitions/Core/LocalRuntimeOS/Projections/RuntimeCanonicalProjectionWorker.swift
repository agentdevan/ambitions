import Foundation

enum RuntimeCanonicalProjectionDrainOutcome: Sendable, Equatable {
    case idle
    case progressed(
        projectionID: RuntimeCanonicalProjectionID,
        phase: RuntimeCanonicalProjectionBuildPhase,
        cursor: RuntimeCanonicalReplayCursor,
        target: RuntimeCanonicalReplayCursor
    )
    case published(projectionID: RuntimeCanonicalProjectionID, cursor: RuntimeCanonicalReplayCursor)
    case deferred(projectionID: RuntimeCanonicalProjectionID, reasonCode: String)
    case restartDeferred(projectionID: RuntimeCanonicalProjectionID, generationID: String)
    case maintenance(RuntimeCanonicalGenerationMaintenanceOutcome)
    case bootstrappedEmptyAuthority
    case blocked(projectionID: RuntimeCanonicalProjectionID, reasonCode: String)
}

enum RuntimeCanonicalProjectionPersistenceError: Error, Sendable, Equatable {
    case schemaUnavailable
    case corruptInvalidation
    case sourceAdvanced
    case invalidationAdvanced
    case generationMismatch
    case leaseUnavailable
    case workerAlreadyRunning
    case transientStoreUnavailable
    case unitBudgetExceeded
    case derivedArtifactCorrupt
}

actor RuntimeCanonicalProjectionWorker {
    static let maximumInvalidationBatch = 64
    static let maximumRowsPerUnit = 128
    // One maximum-size canonical state plus bounded row metadata.
    static let maximumBytesPerUnit = 2_097_152

    private let store: any RuntimeCanonicalDerivedTransactionGateway
    private let registry: RuntimeCanonicalProjectionDefinitionRegistry
    private let ownerID: String
    private var inFlight = false
    private var maintenanceTurn = false

    init(
        store: any RuntimeCanonicalDerivedTransactionGateway,
        registry: RuntimeCanonicalProjectionDefinitionRegistry,
        ownerID: String
    ) {
        self.store = store
        self.registry = registry
        self.ownerID = ownerID
    }

    /// Executes exactly one durable, bounded state-machine unit. Scheduling,
    /// repetition and backoff belong to the caller.
    func runOneUnit(nowMilliseconds: Int64) async throws -> RuntimeCanonicalProjectionDrainOutcome {
        guard inFlight == false else {
            throw RuntimeCanonicalProjectionPersistenceError.workerAlreadyRunning
        }
        inFlight = true
        defer { inFlight = false }
        try Task.checkCancellation()

        if try await store.publishCanonicalEmptyAuthoritiesIfNeeded(
            registry: registry, nowMilliseconds: nowMilliseconds
        ) {
            return .bootstrappedEmptyAuthority
        }

        if maintenanceTurn {
            maintenanceTurn = false
            let maintenance = try await store.runOneCanonicalGenerationMaintenanceUnit(
                ownerID: ownerID, nowMilliseconds: nowMilliseconds,
                maximumRows: Self.maximumRowsPerUnit
            )
            if maintenance != .idle { return .maintenance(maintenance) }
        }

        guard let work = try await store.nextCanonicalProjectionWork(
            registry: registry,
            ownerID: ownerID,
            nowMilliseconds: nowMilliseconds,
            invalidationLimit: Self.maximumInvalidationBatch
        ) else {
            let maintenance = try await store.runOneCanonicalGenerationMaintenanceUnit(
                ownerID: ownerID, nowMilliseconds: nowMilliseconds,
                maximumRows: Self.maximumRowsPerUnit
            )
            return maintenance == .idle ? .idle : .maintenance(maintenance)
        }
        maintenanceTurn = true

        let bounds = RuntimeCanonicalProjectionUnitBounds(
            maximumRows: Self.maximumRowsPerUnit,
            maximumBytes: Self.maximumBytesPerUnit
        )
        let result: RuntimeCanonicalProjectionUnitResult
        do {
            switch work.phase {
            case .clone:
                result = try await store.cloneCanonicalProjectionEntryPage(work, bounds: bounds)
            case .replay:
                result = try await store.replayCanonicalProjectionEventPage(work, bounds: bounds)
            case .sealProjection:
                result = try await store.sealCanonicalProjectionEntryShard(work, bounds: bounds)
            case .scrubProjection, .scrubSearch:
                if let advanced = try await store.advanceCanonicalProjectionBuildAfterScrub(work) {
                    return .progressed(
                        projectionID: work.projectionID,
                        phase: advanced.nextPhase,
                        cursor: advanced.progressCursor,
                        target: work.targetCursor
                    )
                }
                let maintenance = try await store.runOneCanonicalGenerationMaintenanceUnit(
                    ownerID: ownerID,
                    nowMilliseconds: nowMilliseconds,
                    maximumRows: Self.maximumRowsPerUnit
                )
                if case .quarantined = maintenance {
                    let scope: RuntimeCanonicalProjectionRecoveryScope =
                        work.phase == .scrubSearch ? .search : .projection
                    try await store.quarantineAndRestartCanonicalProjectionBuild(
                        work, scope: scope, nowMilliseconds: nowMilliseconds
                    )
                    return .restartDeferred(
                        projectionID: work.projectionID,
                        generationID: work.generationID
                    )
                }
                return maintenance == .idle
                    ? .deferred(
                        projectionID: work.projectionID,
                        reasonCode: "awaiting_\(work.phase.rawValue)_certificate"
                    )
                    : .maintenance(maintenance)
            case .indexSearch:
                result = try await store.indexCanonicalSearchDocumentPage(work, bounds: bounds)
            case .sealSearch:
                result = try await store.sealCanonicalSearchDocumentShard(work, bounds: bounds)
            case .ready:
                try await store.activateCanonicalProjectionGeneration(
                    work, nowMilliseconds: nowMilliseconds
                )
                return .published(projectionID: work.projectionID, cursor: work.targetCursor)
            case .blocked:
                return .blocked(
                    projectionID: work.projectionID,
                    reasonCode: work.blockedReasonCode ?? "persisted_projection_build_block"
                )
            }
        } catch RuntimeCanonicalProjectionPersistenceError.derivedArtifactCorrupt {
            let recoveryScope = Self.recoveryScopeForDerivedArtifact(work)
            try await store.quarantineAndRestartCanonicalProjectionBuild(
                work, scope: recoveryScope, nowMilliseconds: nowMilliseconds
            )
            return .restartDeferred(
                projectionID: work.projectionID, generationID: work.generationID
            )
        } catch RuntimeCanonicalSearchError.corruptIndex {
            try await store.quarantineAndRestartCanonicalProjectionBuild(
                work, scope: .search, nowMilliseconds: nowMilliseconds
            )
            return .restartDeferred(
                projectionID: work.projectionID, generationID: work.generationID
            )
        } catch let RuntimeCanonicalSearchError.projectionNotAvailable(health)
            where Self.recoveryScopeForProjectionUnavailable(health, work: work) != nil {
            try await store.quarantineAndRestartCanonicalProjectionBuild(
                work, scope: .baseProjection, nowMilliseconds: nowMilliseconds
            )
            return .restartDeferred(
                projectionID: work.projectionID, generationID: work.generationID
            )
        } catch let error as RuntimeCanonicalProjectionPersistenceError
            where error == .sourceAdvanced || error == .invalidationAdvanced {
            try await store.quarantineAndRestartCanonicalProjectionBuild(
                work, scope: .projection, nowMilliseconds: nowMilliseconds
            )
            return .restartDeferred(
                projectionID: work.projectionID, generationID: work.generationID
            )
        } catch RuntimeCanonicalProjectionPersistenceError.generationMismatch {
            let scope: RuntimeCanonicalProjectionRecoveryScope =
                work.phase == .indexSearch || work.phase == .sealSearch
                    || work.phase == .scrubSearch
                ? .search : .projection
            try await store.quarantineAndRestartCanonicalProjectionBuild(
                work, scope: scope, nowMilliseconds: nowMilliseconds
            )
            return .restartDeferred(
                projectionID: work.projectionID, generationID: work.generationID
            )
        } catch let error as LocalRuntimeStorageError
            where Self.isCanonicalSQLiteCorruption(error) {
            let scope = Self.recoveryScopeForDerivedArtifact(work)
            try await store.quarantineAndRestartCanonicalProjectionBuild(
                work, scope: scope, nowMilliseconds: nowMilliseconds
            )
            return .restartDeferred(
                projectionID: work.projectionID, generationID: work.generationID
            )
        } catch let source as RuntimeCanonicalProjectionSourceError {
            let reason = Self.blockReason(for: source)
            try await store.blockCanonicalProjectionBuild(
                work, reasonCode: reason, nowMilliseconds: nowMilliseconds
            )
            return .blocked(projectionID: work.projectionID, reasonCode: reason)
        } catch RuntimeCanonicalProjectionPersistenceError.unitBudgetExceeded {
            return .deferred(
                projectionID: work.projectionID,
                reasonCode: "source_unit_exceeds_declared_budget"
            )
        } catch RuntimeCanonicalProjectionPersistenceError.transientStoreUnavailable {
            return .deferred(
                projectionID: work.projectionID,
                reasonCode: "derived_store_temporarily_unavailable"
            )
        }
        return .progressed(
            projectionID: work.projectionID,
            phase: result.nextPhase,
            cursor: result.progressCursor,
            target: work.targetCursor
        )
    }

    /// Compatibility spelling for callers that already schedule one bounded
    /// unit. The typed outcome distinguishes durable progress from idle.
    func runOneBatch(nowMilliseconds: Int64) async throws -> RuntimeCanonicalProjectionDrainOutcome {
        try await runOneUnit(nowMilliseconds: nowMilliseconds)
    }

    static func recoveryScopeForDerivedArtifact(
        _ work: RuntimeCanonicalProjectionBuildWork
    ) -> RuntimeCanonicalProjectionRecoveryScope {
        if work.phase == .clone && work.baseGenerationID != nil { return .baseProjection }
        return work.phase == .scrubSearch ? .search : .projection
    }

    static func recoveryScopeForProjectionUnavailable(
        _ health: RuntimeCanonicalProjectionHealth,
        work: RuntimeCanonicalProjectionBuildWork
    ) -> RuntimeCanonicalProjectionRecoveryScope? {
        guard work.phase == .clone, work.baseGenerationID != nil,
              health == .corrupt || health == .blocked else { return nil }
        return .baseProjection
    }

    static func blockReason(for source: RuntimeCanonicalProjectionSourceError) -> String {
        switch source {
        case let .blockedHistoricalPrivacy(eventID, payloadVersion):
            "historical_privacy_missing:\(eventID):v\(payloadVersion)"
        case .unsupportedSource: "source_version_unsupported"
        case .inconsistentSource: "source_definition_incompatible"
        }
    }

    static func isCanonicalSQLiteCorruption(_ error: LocalRuntimeStorageError) -> Bool {
        guard case let .canonicalSQLiteFailure(_, code, _) = error else { return false }
        return [11, 18, 19, 20, 21, 26].contains(Int(code))
    }
}
