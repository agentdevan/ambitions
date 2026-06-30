import Foundation

enum ContinuityAccountTransition: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case remainLocalOnly = "remain_local_only"
    case pauseContinuity = "pause_continuity"
    case requireAccount = "require_account"
    case requireReview = "require_review"
    case proofBackedReady = "proof_backed_ready"
    case waitTemporarily = "wait_temporarily"
    case restrictContinuity = "restrict_continuity"
}

struct ContinuityAccountSnapshot: Codable, Sendable, Equatable, Hashable {
    let id: String
    let syncMode: CloudKitContinuityMode
    let syncState: CloudKitContinuitySyncState
    let accountStatus: CloudKitContinuityAccountStatus
    let transition: ContinuityAccountTransition
    let evaluatedAt: String
    let localOperationBlocked: Bool
    let localOnlyFallbackActive: Bool
    let detail: String
}

struct AccountStateMachine: Sendable, Equatable {
    func evaluate(
        featureFlagEnabled: Bool,
        accountStatus: CloudKitContinuityAccountStatus,
        proofVerified: Bool,
        userPausedSync: Bool,
        evaluatedAt: String
    ) -> CloudKitContinuityDiagnostics {
        let snapshot = snapshot(
            featureFlagEnabled: featureFlagEnabled,
            accountStatus: accountStatus,
            proofVerified: proofVerified,
            userPausedSync: userPausedSync,
            evaluatedAt: evaluatedAt
        )
        return CloudKitContinuityDiagnostics(
            syncMode: snapshot.syncMode,
            syncState: snapshot.syncState,
            featureFlagEnabled: featureFlagEnabled,
            accountStatus: accountStatus,
            proofVerified: proofVerified,
            userPausedSync: userPausedSync,
            sourceOfTruth: "local_device",
            localOnlyFallbackActive: snapshot.localOnlyFallbackActive,
            localOperationBlocked: snapshot.localOperationBlocked,
            writesUserData: false,
            userDataCaptured: false,
            detail: snapshot.detail,
            rollbackDetail: "Disable cloudKitContinuityEnabled to return to explicit local-only operation."
        )
    }

    func snapshot(
        featureFlagEnabled: Bool,
        accountStatus: CloudKitContinuityAccountStatus,
        proofVerified: Bool,
        userPausedSync: Bool,
        evaluatedAt: String
    ) -> ContinuityAccountSnapshot {
        let syncMode: CloudKitContinuityMode = featureFlagEnabled ? .continuityEnabled : .localOnly
        let syncState = Self.syncState(
            featureFlagEnabled: featureFlagEnabled,
            accountStatus: accountStatus,
            proofVerified: proofVerified,
            userPausedSync: userPausedSync
        )
        let transition = Self.transition(for: syncState)
        return ContinuityAccountSnapshot(
            id: "continuity.account.\(syncState.rawValue)",
            syncMode: syncMode,
            syncState: syncState,
            accountStatus: accountStatus,
            transition: transition,
            evaluatedAt: evaluatedAt.trimmingCharacters(in: .whitespacesAndNewlines).syncContinuityNilIfEmpty ?? "local-sync-evaluation",
            localOperationBlocked: false,
            localOnlyFallbackActive: true,
            detail: Self.detail(syncState: syncState)
        )
    }

    static func syncState(
        featureFlagEnabled: Bool,
        accountStatus: CloudKitContinuityAccountStatus,
        proofVerified: Bool,
        userPausedSync: Bool
    ) -> CloudKitContinuitySyncState {
        guard featureFlagEnabled else {
            return .localOnlyUnavailable
        }

        if userPausedSync {
            return .paused
        }

        switch accountStatus {
        case .available:
            return proofVerified ? .healthyAfterProof : .needsReview
        case .noAccount:
            return .accountUnavailable
        case .restricted:
            return .restricted
        case .temporarilyUnavailable:
            return .temporarilyUnavailable
        case .unknown:
            return .needsReview
        }
    }

    static func availability(for syncState: CloudKitContinuitySyncState) -> SyncCapabilityAvailability {
        switch syncState {
        case .healthyAfterProof:
            return .available
        case .accountUnavailable:
            return .noAccount
        case .restricted:
            return .restricted
        case .temporarilyUnavailable:
            return .temporarilyUnavailable
        case .disabled, .localOnlyUnavailable, .paused, .needsReview:
            return .unavailable
        }
    }

    private static func transition(for syncState: CloudKitContinuitySyncState) -> ContinuityAccountTransition {
        switch syncState {
        case .localOnlyUnavailable, .disabled:
            return .remainLocalOnly
        case .paused:
            return .pauseContinuity
        case .accountUnavailable:
            return .requireAccount
        case .restricted:
            return .restrictContinuity
        case .temporarilyUnavailable:
            return .waitTemporarily
        case .needsReview:
            return .requireReview
        case .healthyAfterProof:
            return .proofBackedReady
        }
    }

    private static func detail(syncState: CloudKitContinuitySyncState) -> String {
        switch syncState {
        case .localOnlyUnavailable:
            return "CloudKit continuity stays off by default and local operation remains authoritative."
        case .disabled:
            return "CloudKit continuity is disabled and local operation remains authoritative."
        case .accountUnavailable:
            return "CloudKit continuity is enabled but no iCloud account is available; local operation remains authoritative."
        case .restricted:
            return "CloudKit continuity is enabled but the account is restricted; local operation remains authoritative."
        case .temporarilyUnavailable:
            return "CloudKit continuity is enabled but temporarily unavailable; local operation remains authoritative."
        case .paused:
            return "CloudKit continuity is paused by the user and local operation remains authoritative."
        case .needsReview:
            return "CloudKit continuity needs review before any continuity path can be considered healthy; local operation remains authoritative."
        case .healthyAfterProof:
            return "CloudKit continuity has proof-backed readiness, but local operation remains authoritative until the sync path is explicitly invoked."
        }
    }
}

private extension String {
    var syncContinuityNilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
