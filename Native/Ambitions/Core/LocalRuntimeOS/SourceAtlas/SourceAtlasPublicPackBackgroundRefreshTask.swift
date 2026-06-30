import Foundation

enum SourceAtlasPublicPackBackgroundRefreshTaskIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsafeTaskIdentifier = "unsafe_task_identifier"
    case missingTargetPackID = "missing_target_pack_id"
    case privateTaskMetadata = "private_task_metadata"
    case unsafeManifestRequest = "unsafe_manifest_request"
}

enum SourceAtlasPublicPackBackgroundRefreshTaskIdentifier {
    static let publicPackRefresh = "com.ambitions.source-atlas.public-pack-refresh"

    static let allowedTaskIdentifiers: Set<String> = [
        publicPackRefresh,
    ]
}

struct SourceAtlasPublicPackBackgroundRefreshTaskRequest: Sendable, Equatable, Hashable {
    let taskIdentifier: String
    let domainID: String
    let channel: String
    let schemaVersion: String
    let appVersion: String
    let publicLocale: String?
    let targetPackID: String
    let environment: String
    let cachedManifestLookup: SourceAtlasPublicPackCacheManifestLookup?
    let bundledPayload: SourceAtlasStorePayload?
    let lastKnownGoodPayload: SourceAtlasStorePayload?
    let accountSessionState: SourceAtlasAccountSessionState
    let entitlementState: SourceAtlasReferenceEntitlementState
    let networkReachability: SourceAtlasNetworkReachability
    let checkedAt: Date
    let policy: SourceAtlasLocalPackCachePolicy

    init(
        taskIdentifier: String = SourceAtlasPublicPackBackgroundRefreshTaskIdentifier.publicPackRefresh,
        domainID: String,
        channel: String,
        schemaVersion: String,
        appVersion: String,
        publicLocale: String? = nil,
        targetPackID: String,
        environment: String = "staging",
        cachedManifestLookup: SourceAtlasPublicPackCacheManifestLookup? = nil,
        bundledPayload: SourceAtlasStorePayload? = nil,
        lastKnownGoodPayload: SourceAtlasStorePayload? = nil,
        accountSessionState: SourceAtlasAccountSessionState = .noAccount,
        entitlementState: SourceAtlasReferenceEntitlementState = .bundledOnly,
        networkReachability: SourceAtlasNetworkReachability,
        checkedAt: Date,
        policy: SourceAtlasLocalPackCachePolicy = SourceAtlasLocalPackCachePolicy()
    ) {
        self.taskIdentifier = Self.trimmed(taskIdentifier)
        self.domainID = Self.trimmed(domainID)
        self.channel = Self.trimmed(channel)
        self.schemaVersion = Self.trimmed(schemaVersion)
        self.appVersion = Self.trimmed(appVersion)
        self.publicLocale = Self.trimmedOptional(publicLocale)
        self.targetPackID = Self.trimmed(targetPackID)
        self.environment = Self.trimmed(environment)
        self.cachedManifestLookup = cachedManifestLookup
        self.bundledPayload = bundledPayload
        self.lastKnownGoodPayload = lastKnownGoodPayload
        self.accountSessionState = accountSessionState
        self.entitlementState = entitlementState
        self.networkReachability = networkReachability
        self.checkedAt = checkedAt
        self.policy = policy
    }

    var manifestRequest: SourceAtlasPublicManifestRequest {
        SourceAtlasPublicManifestRequest(
            domainID: domainID,
            channel: channel,
            schemaVersion: schemaVersion,
            appVersion: appVersion,
            publicLocale: publicLocale
        )
    }

    var egressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        let values = [
            "task_identifier=\(taskIdentifier)",
            "domain_id=\(domainID)",
            "channel=\(channel)",
            "schema_version=\(schemaVersion)",
            "app_version=\(appVersion)",
            "locale=\(publicLocale ?? "")",
            "target_pack_id=\(targetPackID)",
            "environment=\(environment)",
        ]
        return SourceAtlasNoPrivateGraphEgressRecord(
            surface: .requestShape,
            identifier: "source-atlas-background-refresh-task",
            inspectedValue: values.joined(separator: " ")
        )
    }

    private static func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func trimmedOptional(_ value: String?) -> String? {
        guard let value else {
            return nil
        }
        let trimmed = Self.trimmed(value)
        return trimmed.isEmpty ? nil : trimmed
    }
}

struct SourceAtlasPublicPackBackgroundRefreshTaskResolution: Sendable, Equatable, Hashable {
    let taskIdentifier: String
    let manifestRequest: SourceAtlasPublicManifestRequest
    let taskIssues: [SourceAtlasPublicPackBackgroundRefreshTaskIssue]
    let egressFindings: [SourceAtlasNoPrivateGraphEgressFinding]
    let appRefreshResolution: SourceAtlasPublicPackAppRefreshResolution?
    let sentPrivateRuntimeContext: Bool
    let scheduledHiddenRuntimeMutation: Bool
    let generatedFinalPlan: Bool
    let generatedFinalSchedule: Bool
    let generatedStepList: Bool

    var selectedPack: SourceAtlasPack? {
        appRefreshResolution?.selectedPack
    }

    var coreLocalPlanningBlocked: Bool {
        false
    }
}

struct SourceAtlasPublicPackBackgroundRefreshTask {
    private let appRefreshCoordinator: SourceAtlasPublicPackAppRefreshCoordinator

    init(
        appRefreshCoordinator: SourceAtlasPublicPackAppRefreshCoordinator = SourceAtlasPublicPackAppRefreshCoordinator()
    ) {
        self.appRefreshCoordinator = appRefreshCoordinator
    }

    func run(
        _ request: SourceAtlasPublicPackBackgroundRefreshTaskRequest,
        transport: SourceAtlasPublicPackRemoteTransport,
        repository: SourceAtlasPublicPackCacheFileRepository
    ) async -> SourceAtlasPublicPackBackgroundRefreshTaskResolution {
        let manifestRequest = request.manifestRequest
        let taskValidation = validate(request, manifestRequest: manifestRequest)

        guard taskValidation.issues.isEmpty else {
            return SourceAtlasPublicPackBackgroundRefreshTaskResolution(
                taskIdentifier: request.taskIdentifier,
                manifestRequest: manifestRequest,
                taskIssues: taskValidation.issues,
                egressFindings: taskValidation.findings,
                appRefreshResolution: nil,
                sentPrivateRuntimeContext: false,
                scheduledHiddenRuntimeMutation: false,
                generatedFinalPlan: false,
                generatedFinalSchedule: false,
                generatedStepList: false
            )
        }

        let cachedManifestLookup = request.cachedManifestLookup ?? (try? repository.latestManifestLookup(packID: request.targetPackID))
        let appRefreshResolution = await appRefreshCoordinator.resolve(
            SourceAtlasPublicPackAppRefreshInput(
                mode: .background,
                manifestRequest: manifestRequest,
                targetPackID: request.targetPackID,
                environment: request.environment,
                cachedManifestLookup: cachedManifestLookup,
                bundledPayload: request.bundledPayload,
                lastKnownGoodPayload: request.lastKnownGoodPayload,
                accountSessionState: request.accountSessionState,
                entitlementState: request.entitlementState,
                networkReachability: request.networkReachability,
                query: SourceAtlasQuery(domainID: request.domainID),
                checkedAt: request.checkedAt,
                policy: request.policy
            ),
            transport: transport,
            repository: repository
        )

        let findings = taskValidation.findings + appRefreshResolution.refreshResolution.remoteResolution.egressFindings
        return SourceAtlasPublicPackBackgroundRefreshTaskResolution(
            taskIdentifier: request.taskIdentifier,
            manifestRequest: manifestRequest,
            taskIssues: taskValidation.issues,
            egressFindings: orderedUniqueFindings(findings),
            appRefreshResolution: appRefreshResolution,
            sentPrivateRuntimeContext: false,
            scheduledHiddenRuntimeMutation: false,
            generatedFinalPlan: false,
            generatedFinalSchedule: false,
            generatedStepList: false
        )
    }
}

private extension SourceAtlasPublicPackBackgroundRefreshTask {
    func validate(
        _ request: SourceAtlasPublicPackBackgroundRefreshTaskRequest,
        manifestRequest: SourceAtlasPublicManifestRequest
    ) -> (issues: [SourceAtlasPublicPackBackgroundRefreshTaskIssue], findings: [SourceAtlasNoPrivateGraphEgressFinding]) {
        var issues: Set<SourceAtlasPublicPackBackgroundRefreshTaskIssue> = []
        var findings = privateTaskMetadataFindings([request.egressRecord])

        if SourceAtlasPublicPackBackgroundRefreshTaskIdentifier.allowedTaskIdentifiers.contains(request.taskIdentifier) == false {
            issues.insert(.unsafeTaskIdentifier)
        }
        if request.targetPackID.isEmpty {
            issues.insert(.missingTargetPackID)
        }
        if findings.isEmpty == false {
            issues.insert(.privateTaskMetadata)
        }
        if manifestRequest.validationIssues.isEmpty == false {
            issues.insert(.unsafeManifestRequest)
            findings = orderedUniqueFindings(findings + SourceAtlasNoPrivateGraphEgressAudit.validate([manifestRequest.egressRecord]))
        }

        return (
            SourceAtlasPublicPackBackgroundRefreshTaskIssue.allCases.filter { issues.contains($0) },
            orderedUniqueFindings(findings)
        )
    }

    func privateTaskMetadataFindings(
        _ records: [SourceAtlasNoPrivateGraphEgressRecord]
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        let extraTokens = [
            "account_id",
            "device_id",
            "goal_id",
            "capture_id",
            "schedule",
            "calendar",
            "proof_id",
            "receipt_id",
            "private_context",
            "personalized",
            "profile_id",
            "behavior_pattern",
        ]
        let standardFindings = SourceAtlasNoPrivateGraphEgressAudit.validate(records)
        let extraFindings = records.flatMap { record in
            let normalized = SourceAtlasNoPrivateGraphEgressAudit.normalize(record.inspectedValue)
            return extraTokens.compactMap { token in
                normalized.contains(token)
                    ? SourceAtlasNoPrivateGraphEgressFinding(
                        surface: record.surface,
                        identifier: record.identifier,
                        forbiddenToken: token
                    )
                    : nil
            }
        }
        return orderedUniqueFindings(standardFindings + extraFindings)
    }

    func orderedUniqueFindings(
        _ findings: [SourceAtlasNoPrivateGraphEgressFinding]
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        var seen: Set<SourceAtlasNoPrivateGraphEgressFinding> = []
        return findings.filter { seen.insert($0).inserted }
    }
}
