import Foundation

struct RuntimeAttachmentKeyRewrapJobID: RuntimeAttachmentIdentity {
    let rawValue: String
    init?(rawValue: String) {
        guard let value = Self.validate(rawValue) else { return nil }
        self.rawValue = value
    }
}

enum RuntimeAttachmentKeyRewrapJobState: String, Sendable, Equatable, Hashable {
    case active
    case completed
}

struct RuntimeAttachmentKeyRewrapJob: Sendable, Equatable {
    let jobID: RuntimeAttachmentKeyRewrapJobID
    let sourceKeyID: RuntimeBlobKeyID
    let sourceKeyVersion: Int
    let targetKeyID: RuntimeBlobKeyID
    let targetKeyVersion: Int
    let state: RuntimeAttachmentKeyRewrapJobState
    let totalEnvelopeCount: Int
    let completedEnvelopeCount: Int
    let failedEnvelopeCount: Int
    let stateVersion: UInt64
    let createdAt: Date
    let updatedAt: Date
    let completedAt: Date?
}

struct RuntimeAttachmentKeyRewrapClaim: Sendable, Equatable {
    let jobID: RuntimeAttachmentKeyRewrapJobID
    let blobID: RuntimeBlobID
    let sourceEnvelope: RuntimeBlobKeyEnvelope
    let expectedEnvelopeDigest: String
    let itemStateVersion: UInt64
    let leaseOwnerID: String
    let leaseToken: String
    let leaseExpiresAt: Date
}

struct RuntimeAttachmentKeyRetirementEligibility: Sendable, Equatable {
    let jobID: RuntimeAttachmentKeyRewrapJobID
    let sourceKeyID: RuntimeBlobKeyID
    let sourceKeyVersion: Int
    let remainingEnvelopeCount: Int
    let jobCompleted: Bool
    let custodySupportsRetirement: Bool

    var canRetire: Bool {
        jobCompleted && remainingEnvelopeCount == 0 && custodySupportsRetirement
    }
}

protocol RuntimeAttachmentKeyRewrapPersisting: Sendable {
    func beginAttachmentKeyRewrap(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        source: RuntimeAttachmentWrappingKey,
        target: RuntimeAttachmentWrappingKey,
        now: Date
    ) async throws -> RuntimeAttachmentKeyRewrapJob

    func attachmentKeyRewrapJob(
        jobID: RuntimeAttachmentKeyRewrapJobID
    ) async throws -> RuntimeAttachmentKeyRewrapJob

    func activeAttachmentKeyRewrapJob() async throws -> RuntimeAttachmentKeyRewrapJob?

    func claimAttachmentKeyRewrapItems(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        ownerID: String,
        leaseToken: String,
        limit: Int,
        now: Date,
        leaseExpiresAt: Date
    ) async throws -> [RuntimeAttachmentKeyRewrapClaim]

    func completeAttachmentKeyRewrapItem(
        _ claim: RuntimeAttachmentKeyRewrapClaim,
        replacementEnvelope: RuntimeBlobKeyEnvelope,
        now: Date
    ) async throws

    func failAttachmentKeyRewrapItem(
        _ claim: RuntimeAttachmentKeyRewrapClaim,
        errorFingerprint: String,
        now: Date
    ) async throws

    func releaseAttachmentKeyRewrapClaim(
        _ claim: RuntimeAttachmentKeyRewrapClaim,
        now: Date
    ) async throws

    func completeAttachmentKeyRewrapJob(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        now: Date
    ) async throws -> RuntimeAttachmentKeyRewrapJob

    func attachmentKeyRetirementEligibility(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        custodySupportsRetirement: Bool
    ) async throws -> RuntimeAttachmentKeyRetirementEligibility
}

struct RuntimeAttachmentKeyRotationRunResult: Sendable, Equatable {
    let job: RuntimeAttachmentKeyRewrapJob
    let completedThisRun: Int
    let failedThisRun: Int
    let retirement: RuntimeAttachmentKeyRetirementEligibility
}

actor RuntimeAttachmentKeyRotationCoordinator {
    private let store: any RuntimeAttachmentKeyRewrapPersisting
    private let custody: any RuntimeAttachmentKeyCustody
    private let ownerID: String
    private let jobID: @Sendable () -> RuntimeAttachmentKeyRewrapJobID
    private let leaseToken: @Sendable () -> String
    private let clock: @Sendable () -> Date

    init(
        store: any RuntimeAttachmentKeyRewrapPersisting,
        custody: any RuntimeAttachmentKeyCustody,
        ownerID: String,
        jobID: @escaping @Sendable () -> RuntimeAttachmentKeyRewrapJobID = {
            RuntimeAttachmentKeyRewrapJobID(rawValue: UUID().uuidString.lowercased())!
        },
        leaseToken: @escaping @Sendable () -> String = { UUID().uuidString.lowercased() },
        clock: @escaping @Sendable () -> Date = Date.init
    ) throws {
        guard ownerID.isEmpty == false, ownerID.utf8.count <= 1_024 else {
            throw RuntimeCanonicalAttachmentError.invalidIdentity
        }
        self.store = store
        self.custody = custody
        self.ownerID = ownerID
        self.jobID = jobID
        self.leaseToken = leaseToken
        self.clock = clock
    }

    func beginAndRun(limit: Int) async throws -> RuntimeAttachmentKeyRotationRunResult {
        try validateLimit(limit)
        if let active = try await store.activeAttachmentKeyRewrapJob() {
            return try await run(jobID: active.jobID, limit: limit)
        }
        let source = try await custody.currentWrappingKey()
        let target = try await custody.prepareWrappingKeyRotation(replacing: source)
        let identifier = jobID()
        let job = try await store.beginAttachmentKeyRewrap(
            jobID: identifier, source: source, target: target, now: clock()
        )
        return try await run(jobID: job.jobID, limit: limit)
    }

    func resumeActive(limit: Int) async throws -> RuntimeAttachmentKeyRotationRunResult? {
        try validateLimit(limit)
        guard let job = try await store.activeAttachmentKeyRewrapJob() else { return nil }
        return try await run(jobID: job.jobID, limit: limit)
    }

    func run(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        limit: Int
    ) async throws -> RuntimeAttachmentKeyRotationRunResult {
        try validateLimit(limit)
        try Task.checkCancellation()
        let job = try await store.attachmentKeyRewrapJob(jobID: jobID)
        let source = try await custody.wrappingKey(
            id: job.sourceKeyID, version: job.sourceKeyVersion
        )
        let target = try await custody.wrappingKey(
            id: job.targetKeyID, version: job.targetKeyVersion
        )
        try await custody.activatePreparedWrappingKey(target, replacing: source)
        let now = clock()
        let token = try validatedLeaseToken()
        let claims = try await store.claimAttachmentKeyRewrapItems(
            jobID: jobID, ownerID: ownerID, leaseToken: token,
            limit: limit, now: now, leaseExpiresAt: now.addingTimeInterval(5 * 60)
        )
        var completed = 0
        var failed = 0
        for claim in claims {
            do {
                try Task.checkCancellation()
                let replacement = try await custody.rewrap(
                    claim.sourceEnvelope, using: target
                )
                try await store.completeAttachmentKeyRewrapItem(
                    claim, replacementEnvelope: replacement, now: clock()
                )
                completed += 1
            } catch is CancellationError {
                do {
                    try await store.releaseAttachmentKeyRewrapClaim(claim, now: clock())
                } catch is CancellationError {
                    // The bounded durable lease makes the claim reclaimable.
                } catch RuntimeCanonicalAttachmentError.invalidLease {
                    // Expired or already reclaimed; no live claim remains to release.
                } catch RuntimeCanonicalAttachmentError.lifecycleConflict {
                    // A concurrent exact-CAS completion/reclaim owns the durable state.
                } catch {
                    // Corruption or an unexpected authority failure must remain visible.
                    throw error
                }
                throw CancellationError()
            } catch {
                try await store.failAttachmentKeyRewrapItem(
                    claim,
                    errorFingerprint: Self.errorFingerprint(
                        jobID: jobID, blobID: claim.blobID, error: error
                    ),
                    now: clock()
                )
                failed += 1
            }
        }
        let updated: RuntimeAttachmentKeyRewrapJob
        do {
            updated = try await store.completeAttachmentKeyRewrapJob(
                jobID: jobID, now: clock()
            )
        } catch RuntimeCanonicalAttachmentError.lifecycleConflict {
            updated = try await store.attachmentKeyRewrapJob(jobID: jobID)
        }
        let retirement = try await store.attachmentKeyRetirementEligibility(
            jobID: jobID,
            custodySupportsRetirement: await custody.supportsIrreversibleKeyRetirement
        )
        return RuntimeAttachmentKeyRotationRunResult(
            job: updated, completedThisRun: completed,
            failedThisRun: failed, retirement: retirement
        )
    }

    private func validateLimit(_ limit: Int) throws {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize else {
            throw RuntimeCanonicalAttachmentError.invalidRecord
        }
    }

    private func validatedLeaseToken() throws -> String {
        let token = leaseToken()
        guard token.isEmpty == false, token.utf8.count <= 256,
              token == token.precomposedStringWithCanonicalMapping,
              token.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains) == false else {
            throw RuntimeCanonicalAttachmentError.invalidIdentity
        }
        return token
    }

    private static func errorFingerprint(
        jobID: RuntimeAttachmentKeyRewrapJobID,
        blobID: RuntimeBlobID,
        error: any Error
    ) -> String {
        RuntimeAttachmentCodec.sha256(Data(
            "ambitions.attachment.key-rewrap-error.v1\u{0}\(jobID.rawValue)\u{0}\(blobID.rawValue)\u{0}\(String(reflecting: type(of: error)))".utf8
        ))
    }
}
