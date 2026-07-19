import Foundation

enum CausalMergeOutcome: String, Codable, Sendable, Equatable, Hashable {
    case keepLocal = "keep_local"
    case acceptRemote = "accept_remote"
    case tombstoneWins = "tombstone_wins"
    case conflictReview = "conflict_review"
}

struct SyncCausalClock: Codable, Sendable, Equatable, Hashable, Comparable {
    let localRevision: Int
    let deviceID: String
    let updatedAt: String

    init(localRevision: Int, deviceID: String, updatedAt: String) {
        self.localRevision = max(0, localRevision)
        self.deviceID = deviceID.trimmingCharacters(in: .whitespacesAndNewlines).syncMergeNilIfEmpty ?? RuntimeLocalDeviceID.current
        self.updatedAt = updatedAt.trimmingCharacters(in: .whitespacesAndNewlines).syncMergeNilIfEmpty ?? "unknown-time"
    }

    static func < (lhs: SyncCausalClock, rhs: SyncCausalClock) -> Bool {
        if lhs.localRevision != rhs.localRevision {
            return lhs.localRevision < rhs.localRevision
        }
        if lhs.updatedAt != rhs.updatedAt {
            return lhs.updatedAt < rhs.updatedAt
        }
        return lhs.deviceID < rhs.deviceID
    }
}

struct CausalMergeCandidate: Sendable, Equatable {
    let localEnvelope: CloudKitContinuityPortableRecordEnvelope?
    let remoteEnvelope: CloudKitContinuityPortableRecordEnvelope?
    let localClock: SyncCausalClock?
    let remoteClock: SyncCausalClock?

    init(
        localEnvelope: CloudKitContinuityPortableRecordEnvelope?,
        remoteEnvelope: CloudKitContinuityPortableRecordEnvelope?,
        localDeviceID: String = RuntimeLocalDeviceID.current,
        remoteDeviceID: String = "remote-device"
    ) {
        self.localEnvelope = localEnvelope
        self.remoteEnvelope = remoteEnvelope
        self.localClock = localEnvelope.map {
            SyncCausalClock(localRevision: $0.localRevision, deviceID: localDeviceID, updatedAt: $0.updatedAt)
        }
        self.remoteClock = remoteEnvelope.map {
            SyncCausalClock(localRevision: $0.localRevision, deviceID: remoteDeviceID, updatedAt: $0.updatedAt)
        }
    }
}

struct CausalMergeDecision: Sendable, Equatable {
    let outcome: CausalMergeOutcome
    let selectedEnvelope: CloudKitContinuityPortableRecordEnvelope?
    let review: CloudKitContinuityConflictReview?
    let reasons: [String]

    var requiresReview: Bool {
        outcome == .conflictReview || review != nil
    }
}

struct CausalMergeEngine: Sendable, Equatable {
    func merge(_ candidate: CausalMergeCandidate, createdAt: String) -> CausalMergeDecision {
        guard let local = candidate.localEnvelope else {
            return CausalMergeDecision(
                outcome: .acceptRemote,
                selectedEnvelope: candidate.remoteEnvelope,
                review: nil,
                reasons: ["local_missing"]
            )
        }
        guard let remote = candidate.remoteEnvelope else {
            return CausalMergeDecision(
                outcome: .keepLocal,
                selectedEnvelope: local,
                review: nil,
                reasons: ["remote_missing"]
            )
        }

        guard local.family == remote.family, local.recordName == remote.recordName else {
            return conflict(local: local, remote: remote, createdAt: createdAt, reason: "record_identity_mismatch")
        }

        if local.reviewState == .conflict || remote.reviewState == .conflict {
            return conflict(local: local, remote: remote, createdAt: createdAt, reason: "existing_conflict_marker")
        }

        if local.tombstone != nil || remote.tombstone != nil {
            return tombstoneDecision(local: local, remote: remote, createdAt: createdAt)
        }

        guard let localClock = candidate.localClock, let remoteClock = candidate.remoteClock else {
            return conflict(local: local, remote: remote, createdAt: createdAt, reason: "missing_causal_clock")
        }

        if localClock == remoteClock, local.payloadData != remote.payloadData {
            return conflict(local: local, remote: remote, createdAt: createdAt, reason: "same_clock_payload_drift")
        }

        if remoteClock > localClock {
            return CausalMergeDecision(
                outcome: .acceptRemote,
                selectedEnvelope: remote,
                review: nil,
                reasons: ["remote_clock_newer"]
            )
        }

        return CausalMergeDecision(
            outcome: .keepLocal,
            selectedEnvelope: local,
            review: nil,
            reasons: ["local_clock_newer_or_equal"]
        )
    }

    private func tombstoneDecision(
        local: CloudKitContinuityPortableRecordEnvelope,
        remote: CloudKitContinuityPortableRecordEnvelope,
        createdAt: String
    ) -> CausalMergeDecision {
        if local.tombstone?.localOnly == true {
            return CausalMergeDecision(
                outcome: .keepLocal,
                selectedEnvelope: local,
                review: nil,
                reasons: ["local_only_tombstone_kept_local"]
            )
        }
        if remote.tombstone?.localOnly == true {
            return conflict(local: local, remote: remote, createdAt: createdAt, reason: "remote_local_only_tombstone")
        }
        let selected = [local, remote].max { lhs, rhs in
            SyncCausalClock(localRevision: lhs.localRevision, deviceID: lhs.id, updatedAt: lhs.updatedAt) <
                SyncCausalClock(localRevision: rhs.localRevision, deviceID: rhs.id, updatedAt: rhs.updatedAt)
        }
        return CausalMergeDecision(
            outcome: .tombstoneWins,
            selectedEnvelope: selected,
            review: nil,
            reasons: ["tombstone_supersedes_live_revision"]
        )
    }

    private func conflict(
        local: CloudKitContinuityPortableRecordEnvelope,
        remote: CloudKitContinuityPortableRecordEnvelope,
        createdAt: String,
        reason: String
    ) -> CausalMergeDecision {
        let review = CloudKitContinuityConflictReview(
            id: "sync_conflict.\(local.recordName).\(reason)",
            family: local.family,
            recordName: local.recordName,
            localEnvelope: local,
            remoteEnvelope: remote,
            reviewState: .conflict,
            createdAt: createdAt,
            detail: "Sync continuity requires local review: \(reason)."
        )
        return CausalMergeDecision(
            outcome: .conflictReview,
            selectedEnvelope: local,
            review: review,
            reasons: [reason]
        )
    }
}

private extension String {
    var syncMergeNilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
