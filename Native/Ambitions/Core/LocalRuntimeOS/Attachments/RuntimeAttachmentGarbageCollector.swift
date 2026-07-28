import Foundation

actor RuntimeAttachmentGarbageCollector {
    private let store: CanonicalRuntimeStore
    private let vault: RuntimeAttachmentVault
    private let ownerID: String
    private let leaseID: @Sendable () -> RuntimeBlobGCLeaseID
    private let tombstoneID: @Sendable () -> RuntimeBlobTombstoneID
    private let clock: @Sendable () -> Date

    init(
        store: CanonicalRuntimeStore,
        vault: RuntimeAttachmentVault,
        ownerID: String,
        leaseID: @escaping @Sendable () -> RuntimeBlobGCLeaseID,
        tombstoneID: @escaping @Sendable () -> RuntimeBlobTombstoneID,
        clock: @escaping @Sendable () -> Date = Date.init
    ) throws {
        guard ownerID.isEmpty == false, ownerID.utf8.count <= 1_024 else {
            throw RuntimeCanonicalAttachmentError.invalidIdentity
        }
        self.store = store
        self.vault = vault
        self.ownerID = ownerID
        self.leaseID = leaseID
        self.tombstoneID = tombstoneID
        self.clock = clock
    }

    func collect(limit: Int, leaseDuration: TimeInterval = 5 * 60) async throws -> Int {
        guard limit > 0, limit <= RuntimeAttachmentLimits.maximumPageSize,
              leaseDuration > 0, leaseDuration <= RuntimeAttachmentLimits.maximumLeaseSeconds else {
            throw RuntimeCanonicalAttachmentError.invalidLease
        }
        _ = try await store.expireAttachmentGCLeases(limit: limit, now: clock())
        var deleted = 0
        for _ in 0..<limit {
            try Task.checkCancellation()
            let acquiredAt = clock()
            let id = leaseID()
            let expiresAt = acquiredAt.addingTimeInterval(leaseDuration / 2)
            guard let work = try await store.acquireAttachmentGCLease(
                leaseID: id, ownerID: ownerID, now: acquiredAt, expiresAt: expiresAt
            ) else { break }
            var lease = RuntimeBlobGCLease(
                version: runtimeCanonicalAttachmentModelVersion, leaseID: id,
                blobID: work.manifest.blobID,
                expectedStateVersion: work.lifecycle.stateVersion, ownerID: ownerID,
                acquiredAt: acquiredAt, expiresAt: expiresAt
            )
            let confirmedAt = clock()
            let confirmed = try await store.confirmAttachmentGCLease(lease, now: confirmedAt)
            guard confirmed == work else { throw RuntimeCanonicalAttachmentError.invalidLease }
            try Task.checkCancellation()
            let renewalAt = clock()
            lease = try await store.renewAttachmentGCLease(
                lease, now: renewalAt,
                expiresAt: renewalAt.addingTimeInterval(leaseDuration)
            )
            let renewedWork = try await store.confirmAttachmentGCLease(lease, now: renewalAt)
            guard renewedWork == work else { throw RuntimeCanonicalAttachmentError.invalidLease }
            let deletionClaim = try await vault.prepareLeaseOwnedDeletion(
                work, lease: lease, now: clock()
            )
            let predeleteAt = clock()
            let predeleteWork = try await store.confirmAttachmentGCLease(lease, now: predeleteAt)
            guard predeleteWork == work else { throw RuntimeCanonicalAttachmentError.invalidLease }
            let proof = try await vault.finalizeLeaseOwnedDeletion(deletionClaim, now: clock)
            let recordedAt = clock()
            guard recordedAt >= proof.deletedAt, recordedAt < lease.expiresAt else {
                throw RuntimeCanonicalAttachmentError.invalidLease
            }
            _ = try await store.recordAttachmentDeletion(
                work: work, lease: lease, tombstoneID: tombstoneID(),
                proof: proof, recordedAt: recordedAt
            )
            deleted += 1
        }
        return deleted
    }
}
