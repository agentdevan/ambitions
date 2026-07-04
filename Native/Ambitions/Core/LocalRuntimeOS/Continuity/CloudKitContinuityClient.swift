import CloudKit
import Foundation

extension CloudKitContinuityAccountStatus {
    init(cloudKitStatus: CKAccountStatus) {
        switch cloudKitStatus {
        case .available:
            self = .available
        case .noAccount:
            self = .noAccount
        case .restricted:
            self = .restricted
        case .couldNotDetermine:
            self = .unknown
        case .temporarilyUnavailable:
            self = .temporarilyUnavailable
        @unknown default:
            self = .unknown
        }
    }
}

struct CloudKitContinuityContainerConfiguration: Sendable, Equatable {
    let containerIdentifier: String
    let coreZoneName: String

    static let production = CloudKitContinuityContainerConfiguration(
        containerIdentifier: "iCloud.com.ambitions.ios",
        coreZoneName: "AmbitionsCoreZone"
    )
}

struct CloudKitContinuityZoneSetupResult: Sendable, Equatable {
    let zoneName: String
    let outcome: CloudKitContinuityZoneSetupOutcome
    let detail: String
}

enum CloudKitContinuityZoneSetupOutcome: String, Codable, Sendable, CaseIterable {
    case created
    case alreadyPresent = "already_present"
    case accountUnavailable = "account_unavailable"
    case restricted
    case temporarilyUnavailable = "temporarily_unavailable"
    case paused
    case needsReview = "needs_review"
    case unknown
}

protocol CloudKitContinuityClient: Sendable {
    var configuration: CloudKitContinuityContainerConfiguration { get }

    func accountStatus() async -> CloudKitContinuityAccountStatus
    func ensureCoreZone() async -> CloudKitContinuityZoneSetupResult
}

struct CloudKitContinuityAdapter: Sendable {
    let client: any CloudKitContinuityClient
    let diagnosticsProvider: any CloudKitContinuityDiagnosticsProviding
    let eligibilityPolicy: SyncEligibilityPolicy

    init(
        client: any CloudKitContinuityClient = StaticCloudKitContinuityClient(),
        diagnosticsProvider: any CloudKitContinuityDiagnosticsProviding = LocalOnlyCloudKitContinuityDiagnosticsProvider(),
        eligibilityPolicy: SyncEligibilityPolicy = SyncEligibilityPolicy()
    ) {
        self.client = client
        self.diagnosticsProvider = diagnosticsProvider
        self.eligibilityPolicy = eligibilityPolicy
    }

    func evaluate(_ envelope: CloudKitContinuityPortableRecordEnvelope, requestedAt: String) async -> SyncEligibilityDecision {
        let diagnostics = await diagnosticsProvider.diagnostics()
        let candidate = SyncEligibilityCandidate(
            id: envelope.id,
            envelope: envelope,
            privacyPolicy: .privateCloud,
            syncState: diagnostics.syncState,
            accountStatus: diagnostics.accountStatus,
            userConfirmed: diagnostics.proofVerified,
            proofVerified: diagnostics.proofVerified,
            requestedAt: requestedAt
        )
        return eligibilityPolicy.evaluate(candidate)
    }

    func prepareCoreZoneIfEligible() async -> CloudKitContinuityZoneSetupResult? {
        let diagnostics = await diagnosticsProvider.diagnostics()
        guard diagnostics.syncState == .healthyAfterProof else {
            return nil
        }
        return await client.ensureCoreZone()
    }
}

struct LiveCloudKitAccountStatusProbe: CloudKitAccountStatusProbing {
    let container: CKContainer

    func accountStatus() async -> CloudKitContinuityAccountStatus {
        do {
            return CloudKitContinuityAccountStatus(cloudKitStatus: try await container.accountStatus())
        } catch let error as CKError {
            switch error.code {
            case .notAuthenticated:
                return .noAccount
            case .permissionFailure:
                return .restricted
            case .networkUnavailable, .networkFailure, .serviceUnavailable, .requestRateLimited, .zoneBusy:
                return .temporarilyUnavailable
            default:
                return .unknown
            }
        } catch {
            return .unknown
        }
    }
}

struct StaticCloudKitContinuityClient: CloudKitContinuityClient {
    let configuration: CloudKitContinuityContainerConfiguration
    let accountStatusValue: CloudKitContinuityAccountStatus
    let zoneSetupResult: CloudKitContinuityZoneSetupResult

    init(
        configuration: CloudKitContinuityContainerConfiguration = .production,
        accountStatusValue: CloudKitContinuityAccountStatus = .unknown,
        zoneSetupResult: CloudKitContinuityZoneSetupResult = .init(
            zoneName: CloudKitContinuityContainerConfiguration.production.coreZoneName,
            outcome: .alreadyPresent,
            detail: "Core zone setup is simulated for tests."
        )
    ) {
        self.configuration = configuration
        self.accountStatusValue = accountStatusValue
        self.zoneSetupResult = zoneSetupResult
    }

    func accountStatus() async -> CloudKitContinuityAccountStatus {
        accountStatusValue
    }

    func ensureCoreZone() async -> CloudKitContinuityZoneSetupResult {
        zoneSetupResult
    }
}

struct LiveCloudKitContinuityClient: CloudKitContinuityClient {
    let configuration: CloudKitContinuityContainerConfiguration
    private let container: CKContainer

    init(configuration: CloudKitContinuityContainerConfiguration = .production) {
        self.configuration = configuration
        self.container = CKContainer(identifier: configuration.containerIdentifier)
    }

    func accountStatus() async -> CloudKitContinuityAccountStatus {
        await LiveCloudKitAccountStatusProbe(container: container).accountStatus()
    }

    func ensureCoreZone() async -> CloudKitContinuityZoneSetupResult {
        let accountStatus = await accountStatus()
        guard accountStatus == .available else {
            return CloudKitContinuityZoneSetupResult(
                zoneName: configuration.coreZoneName,
                outcome: outcome(for: accountStatus),
                detail: detail(for: accountStatus, zoneName: configuration.coreZoneName)
            )
        }

        let zoneID = CKRecordZone.ID(zoneName: configuration.coreZoneName, ownerName: CKCurrentUserDefaultName)
        let zone = CKRecordZone(zoneID: zoneID)
        let database = container.privateCloudDatabase

        do {
            _ = try await fetchZone(zoneID, in: database)
            return CloudKitContinuityZoneSetupResult(
                zoneName: configuration.coreZoneName,
                outcome: .alreadyPresent,
                detail: "AmbitionsCoreZone already exists in the private CloudKit database."
            )
        } catch let error as CKError where error.code == .unknownItem {
            do {
                _ = try await saveZone(zone, in: database)
                return CloudKitContinuityZoneSetupResult(
                    zoneName: configuration.coreZoneName,
                    outcome: .created,
                    detail: "AmbitionsCoreZone was created in the private CloudKit database."
                )
            } catch let saveError as CKError {
                return CloudKitContinuityZoneSetupResult(
                    zoneName: configuration.coreZoneName,
                    outcome: outcome(for: saveError),
                    detail: detail(for: saveError, zoneName: configuration.coreZoneName)
                )
            } catch {
                return CloudKitContinuityZoneSetupResult(
                    zoneName: configuration.coreZoneName,
                    outcome: .needsReview,
                    detail: "AmbitionsCoreZone setup needs review: \(error.localizedDescription)"
                )
            }
        } catch let error as CKError {
            return CloudKitContinuityZoneSetupResult(
                zoneName: configuration.coreZoneName,
                outcome: outcome(for: error),
                detail: detail(for: error, zoneName: configuration.coreZoneName)
            )
        } catch {
            return CloudKitContinuityZoneSetupResult(
                zoneName: configuration.coreZoneName,
                outcome: .needsReview,
                detail: "AmbitionsCoreZone setup needs review: \(error.localizedDescription)"
            )
        }
    }

    private func fetchZone(_ zoneID: CKRecordZone.ID, in database: CKDatabase) async throws -> CKRecordZone {
        try await withCheckedThrowingContinuation { continuation in
            database.fetch(withRecordZoneID: zoneID) { zone, error in
                if let zone {
                    continuation.resume(returning: zone)
                    return
                }
                continuation.resume(throwing: error ?? CKError(.unknownItem))
            }
        }
    }

    private func saveZone(_ zone: CKRecordZone, in database: CKDatabase) async throws -> CKRecordZone {
        try await withCheckedThrowingContinuation { continuation in
            database.save(zone) { savedZone, error in
                if let savedZone {
                    continuation.resume(returning: savedZone)
                    return
                }
                continuation.resume(throwing: error ?? CKError(.internalError))
            }
        }
    }

    private func outcome(for accountStatus: CloudKitContinuityAccountStatus) -> CloudKitContinuityZoneSetupOutcome {
        switch accountStatus {
        case .available:
            return .alreadyPresent
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

    private func detail(for accountStatus: CloudKitContinuityAccountStatus, zoneName: String) -> String {
        switch accountStatus {
        case .available:
            return "AmbitionsCoreZone can be prepared in the private CloudKit database."
        case .noAccount:
            return "No iCloud account is available; \(zoneName) stays local-only."
        case .restricted:
            return "CloudKit access is restricted; \(zoneName) stays local-only."
        case .temporarilyUnavailable:
            return "CloudKit is temporarily unavailable; \(zoneName) setup waits without blocking local writes."
        case .unknown:
            return "CloudKit account status needs review before \(zoneName) setup can proceed."
        }
    }

    private func outcome(for error: CKError) -> CloudKitContinuityZoneSetupOutcome {
        switch error.code {
        case .notAuthenticated:
            return .accountUnavailable
        case .quotaExceeded, .permissionFailure, .serverRejectedRequest:
            return .restricted
        case .networkUnavailable, .networkFailure, .serviceUnavailable, .requestRateLimited, .zoneBusy:
            return .temporarilyUnavailable
        case .unknownItem:
            return .needsReview
        default:
            return .unknown
        }
    }

    private func detail(for error: CKError, zoneName: String) -> String {
        switch error.code {
        case .notAuthenticated:
            return "No iCloud account is available; \(zoneName) setup cannot proceed."
        case .quotaExceeded, .permissionFailure, .serverRejectedRequest:
            return "CloudKit rejected \(zoneName) setup; account or policy review is required."
        case .networkUnavailable, .networkFailure, .serviceUnavailable, .requestRateLimited, .zoneBusy:
            return "CloudKit is temporarily unavailable; \(zoneName) setup will retry later."
        case .unknownItem:
            return "\(zoneName) was not found and needs review before it can be created safely."
        default:
            return "\(zoneName) setup needs review: \(error.localizedDescription)"
        }
    }
}

protocol CloudKitContinuityOutboxStoring: Sendable {
    func enqueue(_ entry: CloudKitContinuityOutboxEntry) async
    func pendingEntries() async -> [CloudKitContinuityOutboxEntry]
}

actor InMemoryCloudKitContinuityOutboxStore: CloudKitContinuityOutboxStoring {
    private var entries: [CloudKitContinuityOutboxEntry] = []

    func enqueue(_ entry: CloudKitContinuityOutboxEntry) async {
        entries.append(entry)
    }

    func pendingEntries() async -> [CloudKitContinuityOutboxEntry] {
        entries
    }
}

protocol CloudKitContinuitySyncCoordinating: Sendable {
    func recordLocalChange(_ entry: CloudKitContinuityOutboxEntry) async
    func currentDiagnostics() async -> CloudKitContinuityDiagnostics
    func pendingEntries() async -> [CloudKitContinuityOutboxEntry]
}

struct LocalFirstCloudKitContinuitySyncCoordinator: CloudKitContinuitySyncCoordinating {
    let client: any CloudKitContinuityClient
    let diagnosticsProvider: any CloudKitContinuityDiagnosticsProviding
    let outboxStore: any CloudKitContinuityOutboxStoring
    let continuityBoundary: CloudKitContinuityAdapter

    init(
        client: any CloudKitContinuityClient = StaticCloudKitContinuityClient(),
        diagnosticsProvider: any CloudKitContinuityDiagnosticsProviding = LocalOnlyCloudKitContinuityDiagnosticsProvider(),
        outboxStore: any CloudKitContinuityOutboxStoring = InMemoryCloudKitContinuityOutboxStore()
    ) {
        self.client = client
        self.diagnosticsProvider = diagnosticsProvider
        self.outboxStore = outboxStore
        self.continuityBoundary = CloudKitContinuityAdapter(client: client, diagnosticsProvider: diagnosticsProvider)
    }

    func recordLocalChange(_ entry: CloudKitContinuityOutboxEntry) async {
        await outboxStore.enqueue(entry)
    }

    func currentDiagnostics() async -> CloudKitContinuityDiagnostics {
        await diagnosticsProvider.diagnostics()
    }

    func pendingEntries() async -> [CloudKitContinuityOutboxEntry] {
        await outboxStore.pendingEntries()
    }

    func prepareCoreZoneIfEligible() async -> CloudKitContinuityZoneSetupResult? {
        await continuityBoundary.prepareCoreZoneIfEligible()
    }
}
