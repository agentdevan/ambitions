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

    init(
        featureFlagEnabled: Bool = CloudKitContinuityFeatureFlag.defaultEnabled,
        accountStatusProbe: any CloudKitAccountStatusProbing = StaticCloudKitAccountStatusProbe(accountStatusValue: .unknown),
        proofVerified: Bool = false,
        userPausedSync: Bool = false
    ) {
        self.featureFlagEnabled = featureFlagEnabled
        self.accountStatusProbe = accountStatusProbe
        self.proofVerified = proofVerified
        self.userPausedSync = userPausedSync
    }

    func diagnostics() async -> CloudKitContinuityDiagnostics {
        let accountStatus = await accountStatusProbe.accountStatus()
        let syncMode: CloudKitContinuityMode = featureFlagEnabled ? .continuityEnabled : .localOnly
        let syncState: CloudKitContinuitySyncState = Self.syncState(
            featureFlagEnabled: featureFlagEnabled,
            accountStatus: accountStatus,
            proofVerified: proofVerified,
            userPausedSync: userPausedSync
        )
        return CloudKitContinuityDiagnostics(
            syncMode: syncMode,
            syncState: syncState,
            featureFlagEnabled: featureFlagEnabled,
            accountStatus: accountStatus,
            proofVerified: proofVerified,
            userPausedSync: userPausedSync,
            sourceOfTruth: "local_device",
            localOnlyFallbackActive: true,
            localOperationBlocked: false,
            writesUserData: false,
            userDataCaptured: false,
            detail: Self.detail(
                syncMode: syncMode,
                syncState: syncState,
                accountStatus: accountStatus
            ),
            rollbackDetail: "Disable cloudKitContinuityEnabled to return to explicit local-only operation."
        )
    }

    private static func syncState(
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

    private static func detail(
        syncMode _: CloudKitContinuityMode,
        syncState: CloudKitContinuitySyncState,
        accountStatus _: CloudKitContinuityAccountStatus
    ) -> String {
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

struct LocalOnlySyncCapability: SyncCapability {
    let diagnosticsProvider: any CloudKitContinuityDiagnosticsProviding

    init(
        diagnosticsProvider: any CloudKitContinuityDiagnosticsProviding = LocalOnlyCloudKitContinuityDiagnosticsProvider()
    ) {
        self.diagnosticsProvider = diagnosticsProvider
    }

    func status() async -> SyncCapabilityStatus {
        let diagnostics = await diagnosticsProvider.diagnostics()
        return SyncCapabilityStatus(
            backendKind: .localOnly,
            trustPosture: .localOnly,
            availability: .unavailable,
            detail: "Ambitions is running in explicit local-only mode. \(diagnostics.detail)",
            syncMode: diagnostics.syncMode,
            syncState: diagnostics.syncState,
            cloudKitContinuityEnabled: diagnostics.featureFlagEnabled,
            cloudKitAccountStatus: diagnostics.accountStatus,
            proofVerified: diagnostics.proofVerified,
            userPausedSync: diagnostics.userPausedSync,
            sourceOfTruth: diagnostics.sourceOfTruth,
            localOnlyFallbackActive: diagnostics.localOnlyFallbackActive,
            localOperationBlocked: diagnostics.localOperationBlocked,
            writesUserData: diagnostics.writesUserData,
            userDataCaptured: diagnostics.userDataCaptured,
            rollbackDetail: diagnostics.rollbackDetail
        )
    }
}
