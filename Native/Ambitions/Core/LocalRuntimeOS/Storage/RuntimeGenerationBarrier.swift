import Foundation

enum RuntimeGenerationUseKind: String, Sendable, Equatable, Hashable {
    case canonicalWriter = "canonical_writer"
    case projectionWorker = "projection_worker"
    case searchWorker = "search_worker"
    case externalOperationWorker = "external_operation_worker"
    case attachmentWorker = "attachment_worker"
    case maintenanceWorker = "maintenance_worker"
    /// Pins the source generation while an immutable database/vault snapshot
    /// is preserved. It coexists with ordinary leases; only final activation
    /// waits for it to end, and the captured authority fence detects writers.
    case migrationSnapshot = "migration_snapshot"
}

struct RuntimeGenerationUseLease: Sendable, Equatable, Hashable {
    let token: String
    let generationID: RuntimeStoreGenerationID
    let kind: RuntimeGenerationUseKind
}

struct RuntimeGenerationFinalBarrier: Sendable, Equatable, Hashable {
    let token: String
    let expectedGenerationID: RuntimeStoreGenerationID?
}

enum RuntimeGenerationUnknownActivationResolution: Sendable, Equatable {
    case committed(RuntimeStoreGenerationID)
    case unchanged(RuntimeStoreGenerationID?)
}

/// Process-local admission control for every generation-sensitive writer and
/// worker. A final activation barrier can be acquired only at an empty lease
/// boundary; after acquisition, new work is rejected until the exact source
/// fence is rechecked and either activation advances the generation or the
/// barrier is released unchanged.
actor RuntimeGenerationBarrierAuthority {
    private var activeGenerationID: RuntimeStoreGenerationID?
    private var leases: [String: RuntimeGenerationUseLease] = [:]
    private var finalBarrier: RuntimeGenerationFinalBarrier?

    init(activeGenerationID: RuntimeStoreGenerationID?) {
        self.activeGenerationID = activeGenerationID
    }

    /// Establishes the process-local active generation exactly once during
    /// canonical-runtime composition. Resolution itself needs the barrier
    /// reference before the active selector can be read, so construction
    /// starts unbound and binds only after that selector was fully resolved.
    /// No worker lease or final activation barrier may exist at this boundary.
    func establishActiveGeneration(_ generationID: RuntimeStoreGenerationID) throws {
        guard activeGenerationID == nil,
              leases.isEmpty,
              finalBarrier == nil else {
            throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
        }
        activeGenerationID = generationID
    }

    func beginUse(
        token: String,
        generationID: RuntimeStoreGenerationID,
        kind: RuntimeGenerationUseKind
    ) throws -> RuntimeGenerationUseLease {
        try RuntimeGenerationControlValidation.requireIdentifier(token, field: "generation_lease_token")
        guard finalBarrier == nil else {
            throw RuntimeGenerationControlError.generationWorkerBarrierBusy
        }
        guard activeGenerationID == generationID, leases[token] == nil else {
            throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
        }
        let lease = RuntimeGenerationUseLease(
            token: token,
            generationID: generationID,
            kind: kind
        )
        leases[token] = lease
        return lease
    }

    func endUse(_ lease: RuntimeGenerationUseLease) throws {
        guard leases.removeValue(forKey: lease.token) == lease else {
            throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
        }
    }

    func acquireFinalBarrier(
        token: String,
        expectedGenerationID: RuntimeStoreGenerationID?
    ) throws -> RuntimeGenerationFinalBarrier {
        try RuntimeGenerationControlValidation.requireIdentifier(token, field: "generation_barrier_token")
        guard finalBarrier == nil, leases.isEmpty else {
            throw RuntimeGenerationControlError.generationWorkerBarrierBusy
        }
        guard activeGenerationID == expectedGenerationID else {
            throw RuntimeGenerationControlError.activationFenceAdvanced
        }
        let barrier = RuntimeGenerationFinalBarrier(
            token: token,
            expectedGenerationID: expectedGenerationID
        )
        finalBarrier = barrier
        return barrier
    }

    func advance(
        from barrier: RuntimeGenerationFinalBarrier,
        to generationID: RuntimeStoreGenerationID
    ) throws {
        guard finalBarrier == barrier,
              activeGenerationID == barrier.expectedGenerationID,
              leases.isEmpty else {
            throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
        }
        activeGenerationID = generationID
        finalBarrier = nil
    }

    func releaseUnchanged(_ barrier: RuntimeGenerationFinalBarrier) throws {
        guard finalBarrier == barrier,
              activeGenerationID == barrier.expectedGenerationID else {
            throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
        }
        finalBarrier = nil
    }

    func currentGenerationID() -> RuntimeStoreGenerationID? {
        activeGenerationID
    }

    /// One resolver authority establishes the initial generation binding.
    /// Thereafter only `advance` under the final barrier may change it.
    func bindResolvedGeneration(_ generationID: RuntimeStoreGenerationID) throws {
        guard finalBarrier == nil, leases.isEmpty,
              activeGenerationID == nil || activeGenerationID == generationID else {
            throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
        }
        activeGenerationID = generationID
    }

    /// Resolves the deliberately preserved in-process barrier after the disk
    /// selector has been classified under the cross-process activation lock.
    /// No caller-supplied token can release an unrelated barrier.
    func resolveUnknownActivation(
        expectedSourceGenerationID: RuntimeStoreGenerationID?,
        resolution: RuntimeGenerationUnknownActivationResolution
    ) throws {
        if finalBarrier == nil {
            let resolvedGenerationID: RuntimeStoreGenerationID?
            switch resolution {
            case let .committed(generationID): resolvedGenerationID = generationID
            case let .unchanged(generationID): resolvedGenerationID = generationID
            }
            guard activeGenerationID == resolvedGenerationID, leases.isEmpty else {
                throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
            }
            return
        }
        guard finalBarrier?.expectedGenerationID == expectedSourceGenerationID,
              activeGenerationID == expectedSourceGenerationID,
              leases.isEmpty else {
            throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
        }
        switch resolution {
        case let .committed(generationID):
            activeGenerationID = generationID
        case let .unchanged(generationID):
            guard generationID == expectedSourceGenerationID else {
                throw RuntimeGenerationControlError.generationWorkerBarrierMismatch
            }
        }
        self.finalBarrier = nil
    }
}
