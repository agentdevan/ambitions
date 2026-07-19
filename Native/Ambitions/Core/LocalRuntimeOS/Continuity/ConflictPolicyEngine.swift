import Foundation

enum SyncConflictResolution: String, Codable, Sendable, Equatable, Hashable {
    case keepLocal = "keep_local"
    case acceptRemoteAfterReview = "accept_remote_after_review"
    case tombstoneSupersedes = "tombstone_supersedes"
    case quarantineForReview = "quarantine_for_review"
}

struct SyncConflictCandidate: Sendable, Equatable {
    let mergeDecision: CausalMergeDecision
    let eligibilityDecision: SyncEligibilityDecision
    let userReviewed: Bool
}

struct SyncConflictDecision: Codable, Sendable, Equatable, Hashable {
    let id: String
    let resolution: SyncConflictResolution
    let localStoreRemainsAuthoritative: Bool
    let externalWriteAllowed: Bool
    let quarantine: Bool
    let reasons: [String]
}

struct ConflictPolicyEngine: Sendable, Equatable {
    func decide(_ candidate: SyncConflictCandidate) -> SyncConflictDecision {
        var reasons = candidate.mergeDecision.reasons + candidate.eligibilityDecision.reasons

        if candidate.eligibilityDecision.cloudKitWriteAllowed == false {
            reasons.append("cloudkit_write_not_allowed")
            return decision(
                resolution: .keepLocal,
                externalWriteAllowed: false,
                quarantine: candidate.mergeDecision.requiresReview,
                reasons: reasons
            )
        }

        switch candidate.mergeDecision.outcome {
        case .keepLocal:
            reasons.append("merge_kept_local")
            return decision(resolution: .keepLocal, externalWriteAllowed: true, quarantine: false, reasons: reasons)
        case .acceptRemote:
            reasons.append(candidate.userReviewed ? "remote_user_reviewed" : "remote_requires_review")
            return decision(
                resolution: candidate.userReviewed ? .acceptRemoteAfterReview : .quarantineForReview,
                externalWriteAllowed: candidate.userReviewed,
                quarantine: candidate.userReviewed == false,
                reasons: reasons
            )
        case .tombstoneWins:
            reasons.append("tombstone_wins")
            return decision(resolution: .tombstoneSupersedes, externalWriteAllowed: true, quarantine: false, reasons: reasons)
        case .conflictReview:
            reasons.append("merge_conflict_review")
            return decision(resolution: .quarantineForReview, externalWriteAllowed: false, quarantine: true, reasons: reasons)
        }
    }

    private func decision(
        resolution: SyncConflictResolution,
        externalWriteAllowed: Bool,
        quarantine: Bool,
        reasons: [String]
    ) -> SyncConflictDecision {
        SyncConflictDecision(
            id: "sync_conflict_policy.\(resolution.rawValue)",
            resolution: resolution,
            localStoreRemainsAuthoritative: true,
            externalWriteAllowed: externalWriteAllowed,
            quarantine: quarantine,
            reasons: Array(Set(reasons)).sorted()
        )
    }
}
