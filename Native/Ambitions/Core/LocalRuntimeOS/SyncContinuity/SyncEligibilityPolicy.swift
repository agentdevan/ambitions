import Foundation

enum SyncPrivacyPolicy: String, Codable, Sendable {
    case localOnly = "local_only"
    case privateCloud = "private_cloud"
    case mostRestrictiveWins = "most_restrictive_wins"
}

enum SyncEligibilityOutcome: String, Codable, Sendable, Equatable, Hashable {
    case localOnly = "local_only"
    case queueForReview = "queue_for_review"
    case eligibleForCloudKit = "eligible_for_cloudkit"
    case deniedPrivateGraph = "denied_private_graph"
    case deniedAccountState = "denied_account_state"
    case deniedUserPaused = "denied_user_paused"
}

struct SyncEligibilityCandidate: Sendable, Equatable {
    let id: String
    let envelope: CloudKitContinuityPortableRecordEnvelope
    let privacyPolicy: SyncPrivacyPolicy
    let syncState: CloudKitContinuitySyncState
    let accountStatus: CloudKitContinuityAccountStatus
    let userConfirmed: Bool
    let proofVerified: Bool
    let requestedAt: String

    init(
        id: String,
        envelope: CloudKitContinuityPortableRecordEnvelope,
        privacyPolicy: SyncPrivacyPolicy,
        syncState: CloudKitContinuitySyncState,
        accountStatus: CloudKitContinuityAccountStatus,
        userConfirmed: Bool = false,
        proofVerified: Bool = false,
        requestedAt: String
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines).syncEligibilityNilIfEmpty ?? envelope.id
        self.envelope = envelope
        self.privacyPolicy = privacyPolicy
        self.syncState = syncState
        self.accountStatus = accountStatus
        self.userConfirmed = userConfirmed
        self.proofVerified = proofVerified
        self.requestedAt = requestedAt.trimmingCharacters(in: .whitespacesAndNewlines).syncEligibilityNilIfEmpty ?? "sync-eligibility-evaluation"
    }
}

struct SyncEligibilityDecision: Codable, Sendable, Equatable, Hashable {
    let id: String
    let outcome: SyncEligibilityOutcome
    let operation: CloudKitContinuityOperationKind
    let localWriteAllowed: Bool
    let cloudKitWriteAllowed: Bool
    let requiresUserConfirmation: Bool
    let localStoreRemainsAuthoritative: Bool
    let reasons: [String]
    let evaluatedAt: String

    var shouldQueueOutboxEntry: Bool {
        localWriteAllowed && operation != .noop
    }
}

struct SyncEligibilityPolicy: Sendable, Equatable {
    func evaluate(_ candidate: SyncEligibilityCandidate) -> SyncEligibilityDecision {
        var reasons: [String] = []
        let requiresConfirmation = candidate.privacyPolicy == .localOnly ||
            candidate.privacyPolicy == .mostRestrictiveWins ||
            candidate.envelope.reviewState == .needsReview ||
            candidate.userConfirmed == false

        if candidate.privacyPolicy == .localOnly {
            reasons.append("privacy_policy_local_only")
            return decision(
                candidate,
                outcome: .localOnly,
                operation: .noop,
                cloudKitWriteAllowed: false,
                requiresUserConfirmation: true,
                reasons: reasons
            )
        }

        if candidate.envelope.payloadClass.eligibleForContinuityEnvelope == false {
            reasons.append("payload_class_not_continuity_safe")
            return decision(
                candidate,
                outcome: .deniedPrivateGraph,
                operation: .review,
                cloudKitWriteAllowed: false,
                requiresUserConfirmation: true,
                reasons: reasons
            )
        }

        if candidate.envelope.tombstone?.localOnly == true {
            reasons.append("local_only_tombstone")
            return decision(
                candidate,
                outcome: .localOnly,
                operation: .noop,
                cloudKitWriteAllowed: false,
                requiresUserConfirmation: true,
                reasons: reasons
            )
        }

        switch candidate.syncState {
        case .healthyAfterProof where candidate.accountStatus == .available && candidate.proofVerified:
            reasons.append("proof_backed_available_account")
            return decision(
                candidate,
                outcome: .eligibleForCloudKit,
                operation: candidate.envelope.reviewState == .tombstoned ? .delete : .upsert,
                cloudKitWriteAllowed: candidate.userConfirmed || requiresConfirmation == false,
                requiresUserConfirmation: requiresConfirmation,
                reasons: reasons
            )
        case .paused:
            reasons.append("sync_paused_by_user")
            return decision(
                candidate,
                outcome: .deniedUserPaused,
                operation: .review,
                cloudKitWriteAllowed: false,
                requiresUserConfirmation: true,
                reasons: reasons
            )
        case .accountUnavailable, .restricted, .temporarilyUnavailable, .localOnlyUnavailable, .disabled:
            reasons.append("account_state_\(candidate.syncState.rawValue)")
            return decision(
                candidate,
                outcome: .deniedAccountState,
                operation: .review,
                cloudKitWriteAllowed: false,
                requiresUserConfirmation: requiresConfirmation,
                reasons: reasons
            )
        case .needsReview, .healthyAfterProof:
            reasons.append("continuity_review_required")
            return decision(
                candidate,
                outcome: .queueForReview,
                operation: .review,
                cloudKitWriteAllowed: false,
                requiresUserConfirmation: true,
                reasons: reasons
            )
        }
    }

    private func decision(
        _ candidate: SyncEligibilityCandidate,
        outcome: SyncEligibilityOutcome,
        operation: CloudKitContinuityOperationKind,
        cloudKitWriteAllowed: Bool,
        requiresUserConfirmation: Bool,
        reasons: [String]
    ) -> SyncEligibilityDecision {
        SyncEligibilityDecision(
            id: "sync_eligibility.\(candidate.id)",
            outcome: outcome,
            operation: operation,
            localWriteAllowed: true,
            cloudKitWriteAllowed: cloudKitWriteAllowed,
            requiresUserConfirmation: requiresUserConfirmation,
            localStoreRemainsAuthoritative: true,
            reasons: Array(Set(reasons)).sorted(),
            evaluatedAt: candidate.requestedAt
        )
    }
}

struct LivingPlanContinuitySync: Sendable, Equatable {
    let syncID: String
    let lastSyncedAt: Date
    let pendingChanges: [LivingPlanMutationPermission]
    let isSyncRequired: Bool
    let privacyPolicy: SyncPrivacyPolicy
    
    init(
        syncID: String = UUID().uuidString,
        lastSyncedAt: Date = Date(),
        pendingChanges: [LivingPlanMutationPermission] = [],
        isSyncRequired: Bool = false,
        privacyPolicy: SyncPrivacyPolicy = .mostRestrictiveWins
    ) {
        self.syncID = syncID
        self.lastSyncedAt = lastSyncedAt
        self.pendingChanges = pendingChanges
        self.isSyncRequired = isSyncRequired
        self.privacyPolicy = privacyPolicy
    }
    
    func requiresExplicitConfirmation() -> Bool {
        pendingChanges.contains(where: { $0.requiresExplicitConfirmation }) ||
            privacyPolicy == .localOnly ||
            privacyPolicy == .mostRestrictiveWins
    }
    
    func generateReceipt() -> ActionReceipt {
        let confirmationNeeded = requiresExplicitConfirmation()
        
        return ActionReceipt(
            id: UUID().uuidString,
            resultState: confirmationNeeded ? .needsConfirmation : .noOp,
            title: "Continuity Sync",
            summary: confirmationNeeded ? "Sync paused: review required for privacy/mutation compliance." : "Synchronizing plan continuity across domains.",
            sourceDomain: .time,
            occurredAt: "2026-05-16T00:00:00Z",
            affectedObjects: [],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: UUID().uuidString,
                    kind: confirmationNeeded ? .needsConfirmation : .noChange,
                    summary: "Continuity sync evaluated with \(privacyPolicy.rawValue) policy."
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            safetyState: confirmationNeeded ? .confirmationRequired : .normal
        )
    }
}

private extension String {
    var syncEligibilityNilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
