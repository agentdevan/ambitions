import Foundation

enum SyncBackendKind: String, Codable, Sendable {
    case localOnly = "local_only"
    case cloudKitContinuity = "cloudkit_continuity"
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
    let featureFlagEnabled: Bool
    let accountStatus: CloudKitContinuityAccountStatus
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

    init(
        featureFlagEnabled: Bool = CloudKitContinuityFeatureFlag.defaultEnabled,
        accountStatusProbe: any CloudKitAccountStatusProbing = StaticCloudKitAccountStatusProbe(accountStatusValue: .unknown)
    ) {
        self.featureFlagEnabled = featureFlagEnabled
        self.accountStatusProbe = accountStatusProbe
    }

    func diagnostics() async -> CloudKitContinuityDiagnostics {
        let accountStatus = await accountStatusProbe.accountStatus()
        return CloudKitContinuityDiagnostics(
            featureFlagEnabled: featureFlagEnabled,
            accountStatus: accountStatus,
            sourceOfTruth: "local_device",
            localOnlyFallbackActive: true,
            localOperationBlocked: false,
            writesUserData: false,
            userDataCaptured: false,
            detail: "CloudKit continuity stays off by default and local operation remains authoritative.",
            rollbackDetail: "Disable cloudKitContinuityEnabled to return to explicit local-only operation."
        )
    }
}

struct SyncCapabilityStatus: Codable, Sendable, Equatable {
    let backendKind: SyncBackendKind
    let trustPosture: PortableTrustPosture
    let availability: SyncCapabilityAvailability
    let cloudKitContinuityEnabled: Bool
    let cloudKitAccountStatus: CloudKitContinuityAccountStatus
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
        cloudKitContinuityEnabled: Bool = CloudKitContinuityFeatureFlag.defaultEnabled,
        cloudKitAccountStatus: CloudKitContinuityAccountStatus = .unknown,
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
        self.cloudKitContinuityEnabled = cloudKitContinuityEnabled
        self.cloudKitAccountStatus = cloudKitAccountStatus
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
            cloudKitContinuityEnabled: diagnostics.featureFlagEnabled,
            cloudKitAccountStatus: diagnostics.accountStatus,
            sourceOfTruth: diagnostics.sourceOfTruth,
            localOnlyFallbackActive: diagnostics.localOnlyFallbackActive,
            localOperationBlocked: diagnostics.localOperationBlocked,
            writesUserData: diagnostics.writesUserData,
            userDataCaptured: diagnostics.userDataCaptured,
            rollbackDetail: diagnostics.rollbackDetail
        )
    }
}
