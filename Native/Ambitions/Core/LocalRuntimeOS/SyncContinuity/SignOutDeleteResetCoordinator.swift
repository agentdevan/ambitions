import Foundation

enum ContinuityAccountLifecycleEvent: String, Codable, Sendable, Equatable, Hashable {
    case signOut = "sign_out"
    case deleteAccount = "delete_account"
    case resetLocalContinuity = "reset_local_continuity"
    case pause = "pause"
    case resume = "resume"
}

enum ContinuityCleanupAction: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case pauseOutbox = "pause_outbox"
    case clearCloudKitTokens = "clear_cloudkit_tokens"
    case keepLocalStore = "keep_local_store"
    case tombstoneEligibleRemoteRecords = "tombstone_eligible_remote_records"
    case dropPendingExternalWrites = "drop_pending_external_writes"
    case rebuildLocalProjections = "rebuild_local_projections"
    case requireUserConfirmation = "require_user_confirmation"
}

struct ContinuityCleanupRequest: Sendable, Equatable {
    let event: ContinuityAccountLifecycleEvent
    let pendingOutboxCount: Int
    let hasUnreviewedConflicts: Bool
    let requestedAt: String

    init(
        event: ContinuityAccountLifecycleEvent,
        pendingOutboxCount: Int,
        hasUnreviewedConflicts: Bool,
        requestedAt: String
    ) {
        self.event = event
        self.pendingOutboxCount = max(0, pendingOutboxCount)
        self.hasUnreviewedConflicts = hasUnreviewedConflicts
        self.requestedAt = requestedAt.trimmingCharacters(in: .whitespacesAndNewlines).resetNilIfEmpty ?? "continuity-cleanup"
    }
}

struct ContinuityCleanupPlan: Codable, Sendable, Equatable, Hashable {
    let id: String
    let event: ContinuityAccountLifecycleEvent
    let actions: [ContinuityCleanupAction]
    let localDataRetained: Bool
    let remoteAuthorityRevoked: Bool
    let requiresUserConfirmation: Bool
    let localStoreRemainsAuthoritative: Bool
    let reasons: [String]
    let plannedAt: String
}

struct SignOutDeleteResetCoordinator: Sendable, Equatable {
    func plan(_ request: ContinuityCleanupRequest) -> ContinuityCleanupPlan {
        var actions: [ContinuityCleanupAction] = [.keepLocalStore]
        var reasons: [String] = ["local_store_retained"]
        var requiresConfirmation = request.hasUnreviewedConflicts
        var remoteAuthorityRevoked = false

        switch request.event {
        case .signOut:
            actions += [.pauseOutbox, .clearCloudKitTokens, .dropPendingExternalWrites]
            reasons.append("sign_out_revokes_account_continuity")
            remoteAuthorityRevoked = true
        case .deleteAccount:
            actions += [.pauseOutbox, .clearCloudKitTokens, .tombstoneEligibleRemoteRecords, .dropPendingExternalWrites, .requireUserConfirmation]
            reasons.append("delete_account_requires_remote_cleanup_review")
            requiresConfirmation = true
            remoteAuthorityRevoked = true
        case .resetLocalContinuity:
            actions += [.pauseOutbox, .dropPendingExternalWrites, .rebuildLocalProjections, .requireUserConfirmation]
            reasons.append("local_continuity_reset_rebuilds_local_views")
            requiresConfirmation = true
        case .pause:
            actions += [.pauseOutbox]
            reasons.append("user_paused_continuity")
        case .resume:
            actions += [.rebuildLocalProjections]
            reasons.append("resume_requires_local_projection_recheck")
            requiresConfirmation = request.pendingOutboxCount > 0 || request.hasUnreviewedConflicts
        }

        if request.pendingOutboxCount > 0 {
            reasons.append("pending_outbox_entries_\(request.pendingOutboxCount)")
        }
        if request.hasUnreviewedConflicts {
            actions.append(.requireUserConfirmation)
            reasons.append("unreviewed_conflicts")
        }

        return ContinuityCleanupPlan(
            id: "continuity_cleanup.\(request.event.rawValue)",
            event: request.event,
            actions: orderedUnique(actions),
            localDataRetained: true,
            remoteAuthorityRevoked: remoteAuthorityRevoked,
            requiresUserConfirmation: requiresConfirmation,
            localStoreRemainsAuthoritative: true,
            reasons: Array(Set(reasons)).sorted(),
            plannedAt: request.requestedAt
        )
    }

    private func orderedUnique(_ actions: [ContinuityCleanupAction]) -> [ContinuityCleanupAction] {
        var seen = Set<ContinuityCleanupAction>()
        return actions.filter { seen.insert($0).inserted }
    }
}

private extension String {
    var resetNilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
