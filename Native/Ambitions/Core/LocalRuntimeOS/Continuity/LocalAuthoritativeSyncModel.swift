import Foundation

enum SyncBackendKind: String, Codable, Sendable {
    case localOnly = "local_only"
    case cloudKitContinuity = "cloudkit_continuity"
}

enum CloudKitContinuityMode: String, Codable, Sendable, CaseIterable {
    case localOnly = "local_only"
    case continuityEnabled = "continuity_enabled"
}

enum CloudKitContinuitySyncState: String, Codable, Sendable, CaseIterable {
    case localOnlyUnavailable = "local_only_unavailable"
    case disabled
    case accountUnavailable = "account_unavailable"
    case restricted
    case temporarilyUnavailable = "temporarily_unavailable"
    case paused
    case needsReview = "needs_review"
    case healthyAfterProof = "healthy_after_proof"
}

enum SyncCapabilityAvailability: String, Codable, Sendable {
    case unavailable
    case localOnly = "local_only"
    case available
    case noAccount = "no_account"
    case restricted
    case temporarilyUnavailable = "temporarily_unavailable"
    case unknown
}

enum CloudKitContinuityFeatureFlag {
    static let key = "cloudKitContinuityEnabled"
    static let defaultEnabled = false
}

enum CloudKitContinuityAccountStatus: String, Codable, Sendable, CaseIterable {
    case available
    case noAccount = "no_account"
    case restricted
    case temporarilyUnavailable = "temporarily_unavailable"
    case unknown
}

struct CloudKitContinuityDiagnostics: Codable, Sendable, Equatable {
    let syncMode: CloudKitContinuityMode
    let syncState: CloudKitContinuitySyncState
    let featureFlagEnabled: Bool
    let accountStatus: CloudKitContinuityAccountStatus
    let proofVerified: Bool
    let userPausedSync: Bool
    let sourceOfTruth: String
    let localOnlyFallbackActive: Bool
    let localOperationBlocked: Bool
    let writesUserData: Bool
    let userDataCaptured: Bool
    let detail: String
    let rollbackDetail: String
}

protocol CloudKitAccountStatusProbing: Sendable {
    func accountStatus() async -> CloudKitContinuityAccountStatus
}

struct StaticCloudKitAccountStatusProbe: CloudKitAccountStatusProbing {
    let accountStatusValue: CloudKitContinuityAccountStatus

    init(accountStatusValue: CloudKitContinuityAccountStatus) {
        self.accountStatusValue = accountStatusValue
    }

    func accountStatus() async -> CloudKitContinuityAccountStatus {
        accountStatusValue
    }
}

protocol CloudKitContinuityDiagnosticsProviding: Sendable {
    func diagnostics() async -> CloudKitContinuityDiagnostics
}

struct LocalOnlyCloudKitContinuityDiagnosticsProvider: CloudKitContinuityDiagnosticsProviding {
    let featureFlagEnabled: Bool
    let accountStatusProbe: any CloudKitAccountStatusProbing
    let proofVerified: Bool
    let userPausedSync: Bool
    let evaluatedAt: String
    let accountStateMachine: AccountStateMachine

    init(
        featureFlagEnabled: Bool = CloudKitContinuityFeatureFlag.defaultEnabled,
        accountStatusProbe: any CloudKitAccountStatusProbing = StaticCloudKitAccountStatusProbe(accountStatusValue: .unknown),
        proofVerified: Bool = false,
        userPausedSync: Bool = false,
        evaluatedAt: String = "local-sync-evaluation",
        accountStateMachine: AccountStateMachine = AccountStateMachine()
    ) {
        self.featureFlagEnabled = featureFlagEnabled
        self.accountStatusProbe = accountStatusProbe
        self.proofVerified = proofVerified
        self.userPausedSync = userPausedSync
        self.evaluatedAt = evaluatedAt
        self.accountStateMachine = accountStateMachine
    }

    func diagnostics() async -> CloudKitContinuityDiagnostics {
        let accountStatus = await accountStatusProbe.accountStatus()
        return accountStateMachine.evaluate(
            featureFlagEnabled: featureFlagEnabled,
            accountStatus: accountStatus,
            proofVerified: proofVerified,
            userPausedSync: userPausedSync,
            evaluatedAt: evaluatedAt
        )
    }
}

struct SyncCapabilityStatus: Codable, Sendable, Equatable {
    let backendKind: SyncBackendKind
    let trustPosture: PortableTrustPosture
    let availability: SyncCapabilityAvailability
    let syncMode: CloudKitContinuityMode
    let syncState: CloudKitContinuitySyncState
    let cloudKitContinuityEnabled: Bool
    let cloudKitAccountStatus: CloudKitContinuityAccountStatus
    let proofVerified: Bool
    let userPausedSync: Bool
    let sourceOfTruth: String
    let localOnlyFallbackActive: Bool
    let localOperationBlocked: Bool
    let writesUserData: Bool
    let userDataCaptured: Bool
    let detail: String
    let rollbackDetail: String

    init(
        backendKind: SyncBackendKind,
        trustPosture: PortableTrustPosture,
        availability: SyncCapabilityAvailability,
        detail: String,
        syncMode: CloudKitContinuityMode = .localOnly,
        syncState: CloudKitContinuitySyncState = .localOnlyUnavailable,
        cloudKitContinuityEnabled: Bool = CloudKitContinuityFeatureFlag.defaultEnabled,
        cloudKitAccountStatus: CloudKitContinuityAccountStatus = .unknown,
        proofVerified: Bool = false,
        userPausedSync: Bool = false,
        sourceOfTruth: String = "local_device",
        localOnlyFallbackActive: Bool = true,
        localOperationBlocked: Bool = false,
        writesUserData: Bool = false,
        userDataCaptured: Bool = false,
        rollbackDetail: String = "Disable cloudKitContinuityEnabled to return to explicit local-only operation."
    ) {
        self.backendKind = backendKind
        self.trustPosture = trustPosture
        self.availability = availability
        self.syncMode = syncMode
        self.syncState = syncState
        self.cloudKitContinuityEnabled = cloudKitContinuityEnabled
        self.cloudKitAccountStatus = cloudKitAccountStatus
        self.proofVerified = proofVerified
        self.userPausedSync = userPausedSync
        self.sourceOfTruth = sourceOfTruth
        self.localOnlyFallbackActive = localOnlyFallbackActive
        self.localOperationBlocked = localOperationBlocked
        self.writesUserData = writesUserData
        self.userDataCaptured = userDataCaptured
        self.detail = detail
        self.rollbackDetail = rollbackDetail
    }
}

protocol SyncCapability: Sendable {
    func status() async -> SyncCapabilityStatus
}

struct LocalAuthoritativeSyncModel: Sendable, Equatable {
    let backendKind: SyncBackendKind
    let localStoreAuthoritative: Bool
    let continuityOptional: Bool
    let offlineCoreAvailable: Bool
    let accountRequiredForCoreUse: Bool
    let allowsPrivateGraphBackendAuthority: Bool
    let sourceOfTruth: String

    init(
        backendKind: SyncBackendKind = .localOnly,
        localStoreAuthoritative: Bool = true,
        continuityOptional: Bool = true,
        offlineCoreAvailable: Bool = true,
        accountRequiredForCoreUse: Bool = false,
        allowsPrivateGraphBackendAuthority: Bool = false,
        sourceOfTruth: String = "local_device"
    ) {
        self.backendKind = backendKind
        self.localStoreAuthoritative = localStoreAuthoritative
        self.continuityOptional = continuityOptional
        self.offlineCoreAvailable = offlineCoreAvailable
        self.accountRequiredForCoreUse = accountRequiredForCoreUse
        self.allowsPrivateGraphBackendAuthority = allowsPrivateGraphBackendAuthority
        self.sourceOfTruth = sourceOfTruth.trimmingCharacters(in: .whitespacesAndNewlines).syncNilIfEmpty ?? "local_device"
    }

    func status(from diagnostics: CloudKitContinuityDiagnostics) -> SyncCapabilityStatus {
        SyncCapabilityStatus(
            backendKind: backendKind,
            trustPosture: .localOnly,
            availability: AccountStateMachine.availability(for: diagnostics.syncState),
            detail: "Ambitions is running with local-device authority. \(diagnostics.detail)",
            syncMode: diagnostics.syncMode,
            syncState: diagnostics.syncState,
            cloudKitContinuityEnabled: diagnostics.featureFlagEnabled,
            cloudKitAccountStatus: diagnostics.accountStatus,
            proofVerified: diagnostics.proofVerified,
            userPausedSync: diagnostics.userPausedSync,
            sourceOfTruth: sourceOfTruth,
            localOnlyFallbackActive: diagnostics.localOnlyFallbackActive,
            localOperationBlocked: diagnostics.localOperationBlocked,
            writesUserData: diagnostics.writesUserData,
            userDataCaptured: diagnostics.userDataCaptured,
            rollbackDetail: diagnostics.rollbackDetail
        )
    }

    var invariants: [String] {
        [
            "local_store_authoritative=\(localStoreAuthoritative)",
            "continuity_optional=\(continuityOptional)",
            "offline_core_available=\(offlineCoreAvailable)",
            "account_required_for_core_use=\(accountRequiredForCoreUse)",
            "private_graph_backend_authority=\(allowsPrivateGraphBackendAuthority)",
        ]
    }
}

struct LocalOnlySyncCapability: SyncCapability {
    let diagnosticsProvider: any CloudKitContinuityDiagnosticsProviding
    let authority: LocalAuthoritativeSyncModel

    init(
        diagnosticsProvider: any CloudKitContinuityDiagnosticsProviding = LocalOnlyCloudKitContinuityDiagnosticsProvider(),
        authority: LocalAuthoritativeSyncModel = LocalAuthoritativeSyncModel()
    ) {
        self.diagnosticsProvider = diagnosticsProvider
        self.authority = authority
    }

    func status() async -> SyncCapabilityStatus {
        let diagnostics = await diagnosticsProvider.diagnostics()
        return authority.status(from: diagnostics)
    }
}

private extension String {
    var syncNilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
