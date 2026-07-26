import Foundation

struct RuntimeExternalOperationRunSummary: Sendable, Equatable {
    let claimed: Int
    let completed: Int
    let reconciliationRequired: Int
    let retryScheduled: Int
    let permanentlyFailed: Int
}

actor RuntimeExternalOperationExecutor {
    private let store: CanonicalRuntimeStore
    private let providers: RuntimeExternalProviderRegistry
    private let owner: RuntimeExternalLeaseOwner
    private let clock: RuntimeClockClient
    private let tokens: RuntimeExternalTokenClient
    private let jitter: RuntimeExternalJitterClient
    private let retryPolicy: RuntimeExternalRetryPolicy
    private let leaseDuration: TimeInterval
    private let maximumBatchSize: Int
    private var isRunning = false

    init(
        store: CanonicalRuntimeStore,
        providers: RuntimeExternalProviderRegistry,
        owner: RuntimeExternalLeaseOwner,
        clock: RuntimeClockClient,
        tokens: RuntimeExternalTokenClient,
        jitter: RuntimeExternalJitterClient,
        retryPolicy: RuntimeExternalRetryPolicy,
        leaseDuration: TimeInterval,
        maximumBatchSize: Int
    ) throws {
        guard try RuntimeExternalRetryPolicyAuthority.resolve(version: retryPolicy.version) == retryPolicy,
              leaseDuration.isFinite, leaseDuration > 0,
              leaseDuration <= RuntimeExternalOperationLimits.maximumLeaseSeconds,
              maximumBatchSize > 0,
              maximumBatchSize <= RuntimeExternalOperationLimits.maximumPageSize else {
            throw RuntimeCanonicalExternalOperationError.invalidCreation
        }
        self.store = store
        self.providers = providers
        self.owner = owner
        self.clock = clock
        self.tokens = tokens
        self.jitter = jitter
        self.retryPolicy = retryPolicy
        self.leaseDuration = leaseDuration
        self.maximumBatchSize = maximumBatchSize
    }

    func runDueBatch() async throws -> RuntimeExternalOperationRunSummary {
        guard isRunning == false else {
            throw RuntimeCanonicalExternalOperationError.executorAlreadyRunning
        }
        isRunning = true
        defer { isRunning = false }
        var claimed = 0
        var completed = 0
        var reconciliationRequired = 0
        var retryScheduled = 0
        var permanentlyFailed = 0
        for _ in 0..<maximumBatchSize {
            try Task.checkCancellation()
            let claim = try await store.claimNextExternalOperation(
                purpose: .execute,
                owner: owner,
                now: clock.now,
                leaseDuration: leaseDuration,
                tokenClient: tokens
            )
            guard case let .claimed(operation) = claim,
                  let lease = operation.lease else { break }
            claimed += 1
            let attemptID = tokens.nextAttemptID(operation.operationID, operation.attemptCount + 1)
            let work = try await store.beginExternalOperationAttempt(
                operationID: operation.operationID,
                leaseToken: lease.token,
                attemptID: attemptID,
                now: clock.now
            )
            guard work.attempt.purpose == .execute else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
            let provider = try providers.provider(
                for: work.creation.kind,
                expectedID: work.creation.providerID
            )
            // The provider receives no database handle. The attempt start and
            // executing state have committed before this suspension point.
            let outcome: RuntimeExternalAttemptOutcomeRecord
            switch work.creation.payload.action {
            case .create:
                let providerOutcome = await provider.execute(RuntimeExternalProviderExecutionRequest(
                    operationID: work.creation.operationID,
                    attemptID: work.attempt.attemptID,
                    kind: work.creation.kind,
                    payload: work.creation.payload,
                    stableIdempotencyKey: work.creation.stableIdempotencyKey,
                    priorExternalReference: work.current.externalReference
                ))
                outcome = RuntimeExternalOperationCodec.outcome(
                    attemptID: work.attempt.attemptID,
                    operationID: work.creation.operationID,
                    providerID: work.creation.providerID,
                    execution: providerOutcome,
                    at: clock.now
                )
            case .compensateRemoval:
                guard let sourceID = work.creation.payload.sourceOperationID,
                      let sourceReference = work.creation.payload.sourceProviderReference else {
                    throw RuntimeCanonicalExternalOperationError.corruptAuthority
                }
                let providerOutcome = await provider.cancel(RuntimeExternalProviderCancellationRequest(
                    operationID: work.creation.operationID,
                    attemptID: work.attempt.attemptID,
                    kind: work.creation.kind,
                    stableIdempotencyKey: work.creation.stableIdempotencyKey,
                    sourceOperationID: sourceID,
                    sourceExternalReference: sourceReference
                ))
                outcome = RuntimeExternalOperationCodec.outcome(
                    attemptID: work.attempt.attemptID,
                    operationID: work.creation.operationID,
                    providerID: work.creation.providerID,
                    cancellation: providerOutcome,
                    at: clock.now
                )
            }
            let final = try await store.recordExternalOperationOutcome(
                outcome,
                leaseToken: lease.token,
                retryPolicy: retryPolicy,
                jitter: jitter
            )
            switch final.workflowStatus {
            case .succeeded:
                completed += 1
            case .reconciliationRequired:
                reconciliationRequired += 1
            case .retryScheduled:
                retryScheduled += 1
            case .permanentFailure, .operatorRequired:
                permanentlyFailed += 1
            case .pending, .claimed, .executing, .cancelled:
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
        }
        return RuntimeExternalOperationRunSummary(
            claimed: claimed,
            completed: completed,
            reconciliationRequired: reconciliationRequired,
            retryScheduled: retryScheduled,
            permanentlyFailed: permanentlyFailed
        )
    }
}

actor RuntimeExternalOperationReconciler {
    private let store: CanonicalRuntimeStore
    private let providers: RuntimeExternalProviderRegistry
    private let owner: RuntimeExternalLeaseOwner
    private let clock: RuntimeClockClient
    private let tokens: RuntimeExternalTokenClient
    private let jitter: RuntimeExternalJitterClient
    private let retryPolicy: RuntimeExternalRetryPolicy
    private let leaseDuration: TimeInterval
    private let maximumBatchSize: Int
    private var isRunning = false

    init(
        store: CanonicalRuntimeStore,
        providers: RuntimeExternalProviderRegistry,
        owner: RuntimeExternalLeaseOwner,
        clock: RuntimeClockClient,
        tokens: RuntimeExternalTokenClient,
        jitter: RuntimeExternalJitterClient,
        retryPolicy: RuntimeExternalRetryPolicy,
        leaseDuration: TimeInterval,
        maximumBatchSize: Int
    ) throws {
        guard try RuntimeExternalRetryPolicyAuthority.resolve(version: retryPolicy.version) == retryPolicy,
              leaseDuration.isFinite, leaseDuration > 0,
              leaseDuration <= RuntimeExternalOperationLimits.maximumLeaseSeconds,
              maximumBatchSize > 0,
              maximumBatchSize <= RuntimeExternalOperationLimits.maximumPageSize else {
            throw RuntimeCanonicalExternalOperationError.invalidCreation
        }
        self.store = store
        self.providers = providers
        self.owner = owner
        self.clock = clock
        self.tokens = tokens
        self.jitter = jitter
        self.retryPolicy = retryPolicy
        self.leaseDuration = leaseDuration
        self.maximumBatchSize = maximumBatchSize
    }

    func reconcileDueBatch() async throws -> RuntimeExternalOperationRunSummary {
        guard isRunning == false else {
            throw RuntimeCanonicalExternalOperationError.executorAlreadyRunning
        }
        isRunning = true
        defer { isRunning = false }
        var claimed = 0
        var completed = 0
        var unresolved = 0
        var retryScheduled = 0
        var permanentlyFailed = 0
        for _ in 0..<maximumBatchSize {
            try Task.checkCancellation()
            let claim = try await store.claimNextExternalOperation(
                purpose: .reconcile,
                owner: owner,
                now: clock.now,
                leaseDuration: leaseDuration,
                tokenClient: tokens
            )
            guard case let .claimed(operation) = claim,
                  let lease = operation.lease else { break }
            claimed += 1
            let attemptID = tokens.nextAttemptID(operation.operationID, operation.attemptCount + 1)
            let work = try await store.beginExternalOperationAttempt(
                operationID: operation.operationID,
                leaseToken: lease.token,
                attemptID: attemptID,
                now: clock.now
            )
            guard work.attempt.purpose == .reconcile else {
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
            let provider = try providers.provider(
                for: work.creation.kind,
                expectedID: work.creation.providerID
            )
            let providerOutcome = await provider.reconcile(
                RuntimeExternalProviderReconciliationRequest(
                    operationID: work.creation.operationID,
                    attemptID: work.attempt.attemptID,
                    kind: work.creation.kind,
                    stableIdempotencyKey: work.creation.stableIdempotencyKey,
                    externalReference: work.current.externalReference,
                    action: work.creation.payload.action,
                    sourceOperationID: work.creation.payload.sourceOperationID,
                    sourceExternalReference: work.creation.payload.sourceProviderReference
                )
            )
            let outcome = RuntimeExternalOperationCodec.outcome(
                attemptID: work.attempt.attemptID,
                operationID: work.creation.operationID,
                providerID: work.creation.providerID,
                reconciliation: providerOutcome,
                action: work.creation.payload.action,
                at: clock.now
            )
            let final = try await store.recordExternalOperationOutcome(
                outcome,
                leaseToken: lease.token,
                retryPolicy: retryPolicy,
                jitter: jitter
            )
            switch final.workflowStatus {
            case .succeeded:
                completed += 1
            case .reconciliationRequired:
                unresolved += 1
            case .retryScheduled:
                retryScheduled += 1
            case .permanentFailure, .operatorRequired:
                permanentlyFailed += 1
            case .pending, .claimed, .executing, .cancelled:
                throw RuntimeCanonicalExternalOperationError.corruptAuthority
            }
        }
        return RuntimeExternalOperationRunSummary(
            claimed: claimed,
            completed: completed,
            reconciliationRequired: unresolved,
            retryScheduled: retryScheduled,
            permanentlyFailed: permanentlyFailed
        )
    }
}
