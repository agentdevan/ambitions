import Foundation

/// Production-injectable composition root for the schema-v8 recovery path.
/// It owns exactly one control-store lock, one resolved active canonical store,
/// and the matching process-local generation barrier. It deliberately does not
/// adapt the legacy repository runtime: callers must explicitly inject this
/// capability when the application is migrated to schema-v8 authority.
actor RuntimeGenerationRecoveryRuntime {
    private let controlStore: RuntimeGenerationControlStore
    private let source: CanonicalRuntimeStoreV8
    private let recoveryService: RuntimeGenerationRecoveryService
    private var isClosing = false
    private var isClosed = false
    private var inFlightOperations = 0
    private var operationDrainWaiters: [CheckedContinuation<Void, Never>] = []
    private var closeWaiters: [CheckedContinuation<Void, Error>] = []
    private var retirementError: RuntimeGenerationControlError?

    private init(
        controlStore: RuntimeGenerationControlStore,
        source: CanonicalRuntimeStoreV8,
        recoveryService: RuntimeGenerationRecoveryService
    ) {
        self.controlStore = controlStore
        self.source = source
        self.recoveryService = recoveryService
    }

    /// Opens the sole active schema-v8 authority and binds recovery services
    /// to that exact resolved store. Opening a second root in the same process
    /// or another process is rejected by the control-store authority lock.
    static func openActive(
        environment: RuntimeEnvironment = .live,
        fileManager: FileManager = .default
    ) async throws -> RuntimeGenerationRecoveryRuntime {
        let rootAuthority = try RuntimeStoreRootAuthority.appPrivate(
            fileManager: fileManager
        )
        let controlStore = try await RuntimeGenerationControlStore.open(
            rootAuthority: rootAuthority,
            environment: environment,
            fileManager: fileManager
        )
        do {
            return try await openActive(
                rootAuthority: rootAuthority,
                controlStore: controlStore,
                environment: environment,
                fileManager: fileManager
            )
        } catch {
            let openingError = error
            do {
                try await controlStore.close()
            } catch {
                // A failed retirement leaves cross-process authority state
                // indeterminate, so do not disguise it as an ordinary open
                // failure that a caller could safely retry in-process.
                throw RuntimeGenerationControlError.controlAuthorityUnavailable
            }
            throw openingError
        }
    }

    /// Transfers a control-store lock already acquired by the application
    /// authority session into the v8 recovery runtime. The caller owns cleanup
    /// if opening fails; a returned runtime owns terminal retirement.
    static func openActive(
        rootAuthority: any RuntimeStoreRootAuthorityProviding,
        controlStore: RuntimeGenerationControlStore,
        environment: RuntimeEnvironment = .live,
        fileManager: FileManager = .default
    ) async throws -> RuntimeGenerationRecoveryRuntime {
        let generationManager = try RuntimeStoreGenerationManager(
            environment: environment,
            rootAuthority: rootAuthority,
            fileManager: fileManager
        )
        let barrierAuthority = RuntimeGenerationBarrierAuthority(
            activeGenerationID: nil
        )
        let resolver = RuntimeGenerationResolver(
            rootAuthority: rootAuthority,
            locations: await generationManager.locations,
            controlStore: controlStore,
            barrierAuthority: barrierAuthority,
            environment: environment
        )
        let resolved = try await resolver.resolveActive()
        try await barrierAuthority.establishActiveGeneration(
            resolved.selector.generationID
        )
        let source = try await CanonicalRuntimeStoreV8.open(
            resolved: resolved,
            environment: environment
        )
        let lifecycle = RuntimeGenerationLifecycleService(
            controlStore: controlStore,
            generationManager: generationManager,
            barrierAuthority: barrierAuthority,
            environment: environment,
            fileManager: fileManager
        )
        let recoveryService = RuntimeGenerationRecoveryService(
            controlStore: controlStore,
            lifecycle: lifecycle,
            generationManager: generationManager,
            environment: environment,
            fileManager: fileManager
        )
        return RuntimeGenerationRecoveryRuntime(
            controlStore: controlStore,
            source: source,
            recoveryService: recoveryService
        )
    }

    /// Starts only the admission and candidate-opening portion of an approved
    /// derived-state rebuild. This capability cannot publish, finalize, or
    /// consume recovery authority by itself.
    func beginDerivedStateRebuild(
        planID: String
    ) async throws -> RuntimeGenerationDerivedStateRebuildExecutionResult {
        try beginOperation()
        defer { finishOperation() }
        return try await recoveryService.beginDerivedStateRebuild(
            planID: planID,
            source: source
        )
    }

    /// App-lifetime shutdown is explicit because the control store owns a
    /// cross-process authority lock. A caller must not reuse this capability
    /// after retirement.
    func close() async throws {
        if isClosed {
            if let retirementError { throw retirementError }
            return
        }
        if isClosing {
            try await waitForCloseCompletion()
            return
        }
        isClosing = true
        await waitForOperationDrain()

        // Never short-circuit: both authorities must receive one terminal
        // retirement attempt even when the other has already failed.
        var sourceStoreFailed = false
        do {
            try await source.close()
        } catch {
            sourceStoreFailed = true
        }
        var controlStoreFailed = false
        do {
            try await controlStore.close()
        } catch {
            controlStoreFailed = true
        }

        let failure: RuntimeGenerationControlError?
        if sourceStoreFailed || controlStoreFailed {
            failure = .recoveryRuntimeRetirementFailed(
                sourceStoreFailed: sourceStoreFailed,
                controlStoreFailed: controlStoreFailed
            )
        } else {
            failure = nil
        }
        retirementError = failure
        isClosed = true
        isClosing = false
        finishClose(with: failure)
        if let failure {
            throw failure
        }
    }

    private func beginOperation() throws {
        guard isClosing == false, isClosed == false else {
            throw RuntimeGenerationControlError.controlAuthorityUnavailable
        }
        inFlightOperations += 1
    }

    private func finishOperation() {
        precondition(inFlightOperations > 0)
        inFlightOperations -= 1
        guard inFlightOperations == 0 else { return }
        let waiters = operationDrainWaiters
        operationDrainWaiters.removeAll(keepingCapacity: false)
        for waiter in waiters {
            waiter.resume()
        }
    }

    private func waitForOperationDrain() async {
        guard inFlightOperations > 0 else { return }
        await withCheckedContinuation { continuation in
            operationDrainWaiters.append(continuation)
        }
    }

    private func waitForCloseCompletion() async throws {
        try await withCheckedThrowingContinuation { continuation in
            closeWaiters.append(continuation)
        }
    }

    private func finishClose(with failure: RuntimeGenerationControlError?) {
        let waiters = closeWaiters
        closeWaiters.removeAll(keepingCapacity: false)
        for waiter in waiters {
            if let failure {
                waiter.resume(throwing: failure)
            } else {
                waiter.resume()
            }
        }
    }
}
