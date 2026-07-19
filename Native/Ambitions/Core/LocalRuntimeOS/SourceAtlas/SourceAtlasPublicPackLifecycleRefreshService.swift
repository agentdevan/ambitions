import Foundation

enum SourceAtlasPublicPackLifecycleRefreshMode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case startup
    case activeLifecycle = "active_lifecycle"
    case background
}

enum SourceAtlasPublicPackLifecycleRefreshIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case cancelled
    case unsafeTarget = "unsafe_target"
    case missingApprovalArtifact = "missing_approval_artifact"
    case privateTargetMetadata = "private_target_metadata"
    case unsafeManifestRequest = "unsafe_manifest_request"
}

struct SourceAtlasPublicPackLifecycleRefreshTarget: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let domainID: String
    let channel: String
    let schemaVersion: String
    let appVersion: String
    let publicLocale: String?
    let targetPackID: String
    let environment: String

    init(
        id: String,
        domainID: String,
        channel: String,
        schemaVersion: String,
        appVersion: String,
        publicLocale: String? = nil,
        targetPackID: String,
        environment: String = "staging"
    ) {
        self.id = Self.trimmed(id)
        self.domainID = Self.trimmed(domainID)
        self.channel = Self.trimmed(channel)
        self.schemaVersion = Self.trimmed(schemaVersion)
        self.appVersion = Self.trimmed(appVersion)
        self.publicLocale = Self.trimmedOptional(publicLocale)
        self.targetPackID = Self.trimmed(targetPackID)
        self.environment = Self.trimmed(environment)
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
        SourceAtlasNoPrivateGraphEgressRecord(
            surface: .requestShape,
            identifier: "source-atlas-lifecycle-refresh-target",
            inspectedValue: [
                "id=\(id)",
                "domain_id=\(domainID)",
                "channel=\(channel)",
                "schema_version=\(schemaVersion)",
                "app_version=\(appVersion)",
                "locale=\(publicLocale ?? "")",
                "target_pack_id=\(targetPackID)",
                "environment=\(environment)",
            ].joined(separator: " ")
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

struct SourceAtlasPublicPackLifecycleRefreshInput: Sendable, Equatable, Hashable {
    let mode: SourceAtlasPublicPackLifecycleRefreshMode
    let networkReachability: SourceAtlasNetworkReachability
    let checkedAt: Date

    init(
        mode: SourceAtlasPublicPackLifecycleRefreshMode,
        networkReachability: SourceAtlasNetworkReachability,
        checkedAt: Date
    ) {
        self.mode = mode
        self.networkReachability = networkReachability
        self.checkedAt = checkedAt
    }
}

struct SourceAtlasPublicPackLifecycleRefreshResolution: Sendable, Equatable, Hashable {
    let mode: SourceAtlasPublicPackLifecycleRefreshMode
    let configuredTargetCount: Int
    let attemptedTargetIDs: [String]
    let issues: [SourceAtlasPublicPackLifecycleRefreshIssue]
    let registryResolution: SourceAtlasPublicPackRefreshTargetRegistryResolution
    let egressFindings: [SourceAtlasNoPrivateGraphEgressFinding]
    let targetResolutions: [SourceAtlasPublicPackBackgroundRefreshTaskResolution]
    let sentPrivateRuntimeContext: Bool
    let scheduledHiddenRuntimeMutation: Bool
    let generatedFinalPlan: Bool
    let generatedFinalSchedule: Bool
    let generatedStepList: Bool

    var selectedPacks: [SourceAtlasPack] {
        targetResolutions.compactMap(\.selectedPack)
    }

    var coreLocalPlanningBlocked: Bool {
        false
    }
}

protocol SourceAtlasPublicPackLifecycleRefreshing: Sendable {
    func refreshPublicSourceAtlasPacks(
        _ input: SourceAtlasPublicPackLifecycleRefreshInput
    ) async -> SourceAtlasPublicPackLifecycleRefreshResolution
}

actor SourceAtlasPublicPackLifecycleRefreshService: SourceAtlasPublicPackLifecycleRefreshing {
    let registry: SourceAtlasPublicPackRefreshTargetRegistry

    private let transport: SourceAtlasPublicPackRemoteTransport
    private let repository: SourceAtlasPublicPackCacheFileRepository
    private let task: SourceAtlasPublicPackBackgroundRefreshTask

    init(
        targets: [SourceAtlasPublicPackLifecycleRefreshTarget] = [],
        transport: SourceAtlasPublicPackRemoteTransport = SourceAtlasStaticPublicPackRemoteTransport(objectsByKey: [:]),
        repository: SourceAtlasPublicPackCacheFileRepository = SourceAtlasPublicPackCacheFileRepository.defaultAppCacheRepository(),
        task: SourceAtlasPublicPackBackgroundRefreshTask = SourceAtlasPublicPackBackgroundRefreshTask()
    ) {
        self.registry = SourceAtlasPublicPackRefreshTargetRegistry(
            entries: targets.map {
                SourceAtlasPublicPackRefreshTargetRegistryEntry(
                    target: $0,
                    allowedModes: Set(SourceAtlasPublicPackLifecycleRefreshMode.allCases),
                    status: .reviewRequired
                )
            }
        )
        self.transport = transport
        self.repository = repository
        self.task = task
    }

    init(
        registry: SourceAtlasPublicPackRefreshTargetRegistry,
        transport: SourceAtlasPublicPackRemoteTransport = SourceAtlasStaticPublicPackRemoteTransport(objectsByKey: [:]),
        repository: SourceAtlasPublicPackCacheFileRepository = SourceAtlasPublicPackCacheFileRepository.defaultAppCacheRepository(),
        task: SourceAtlasPublicPackBackgroundRefreshTask = SourceAtlasPublicPackBackgroundRefreshTask()
    ) {
        self.registry = registry
        self.transport = transport
        self.repository = repository
        self.task = task
    }

    func refreshPublicSourceAtlasPacks(
        _ input: SourceAtlasPublicPackLifecycleRefreshInput
    ) async -> SourceAtlasPublicPackLifecycleRefreshResolution {
        let registryResolution = registry.resolveTargets(for: input.mode)
        var issues = Set(registryResolution.lifecycleIssues)
        var findings = registryResolution.egressFindings
        var attemptedTargetIDs: [String] = []
        var targetResolutions: [SourceAtlasPublicPackBackgroundRefreshTaskResolution] = []

        for target in registryResolution.selectedTargets {
            if Task.isCancelled {
                issues.insert(.cancelled)
                break
            }

            let validation = validate(target)
            findings.append(contentsOf: validation.findings)
            if validation.issues.isEmpty == false {
                issues.formUnion(validation.issues)
                continue
            }

            attemptedTargetIDs.append(target.id)
            let resolution = await task.run(
                SourceAtlasPublicPackBackgroundRefreshTaskRequest(
                    domainID: target.domainID,
                    channel: target.channel,
                    schemaVersion: target.schemaVersion,
                    appVersion: target.appVersion,
                    publicLocale: target.publicLocale,
                    targetPackID: target.targetPackID,
                    environment: target.environment,
                    networkReachability: input.networkReachability,
                    checkedAt: input.checkedAt
                ),
                transport: transport,
                repository: repository
            )
            findings.append(contentsOf: resolution.egressFindings)
            targetResolutions.append(resolution)

            if Task.isCancelled {
                issues.insert(.cancelled)
                break
            }
        }

        return SourceAtlasPublicPackLifecycleRefreshResolution(
            mode: input.mode,
            configuredTargetCount: registryResolution.configuredEntryCount,
            attemptedTargetIDs: attemptedTargetIDs,
            issues: SourceAtlasPublicPackLifecycleRefreshIssue.allCases.filter { issues.contains($0) },
            registryResolution: registryResolution,
            egressFindings: orderedUniqueFindings(findings),
            targetResolutions: targetResolutions,
            sentPrivateRuntimeContext: false,
            scheduledHiddenRuntimeMutation: false,
            generatedFinalPlan: false,
            generatedFinalSchedule: false,
            generatedStepList: false
        )
    }
}

extension SourceAtlasPublicPackCacheFileRepository {
    static func defaultAppCacheRepository(
        fileManager: FileManager = .default
    ) -> SourceAtlasPublicPackCacheFileRepository {
        let root = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return SourceAtlasPublicPackCacheFileRepository(
            rootDirectory: root.appendingPathComponent("AmbitionsSourceAtlas", isDirectory: true),
            fileManager: fileManager
        )
    }
}

private extension SourceAtlasPublicPackLifecycleRefreshService {
    func validate(
        _ target: SourceAtlasPublicPackLifecycleRefreshTarget
    ) -> (issues: Set<SourceAtlasPublicPackLifecycleRefreshIssue>, findings: [SourceAtlasNoPrivateGraphEgressFinding]) {
        var issues: Set<SourceAtlasPublicPackLifecycleRefreshIssue> = []
        var findings = privateTargetMetadataFindings([target.egressRecord])

        if target.id.isEmpty ||
            target.domainID.isEmpty ||
            target.channel.isEmpty ||
            target.schemaVersion.isEmpty ||
            target.appVersion.isEmpty ||
            target.targetPackID.isEmpty ||
            target.environment.isEmpty {
            issues.insert(.unsafeTarget)
        }

        if findings.isEmpty == false {
            issues.insert(.privateTargetMetadata)
        }

        let manifestIssues = target.manifestRequest.validationIssues
        if manifestIssues.isEmpty == false {
            issues.insert(.unsafeManifestRequest)
            findings = orderedUniqueFindings(
                findings + SourceAtlasNoPrivateGraphEgressAudit.validate([target.manifestRequest.egressRecord])
            )
        }

        return (issues, orderedUniqueFindings(findings))
    }

    func privateTargetMetadataFindings(
        _ records: [SourceAtlasNoPrivateGraphEgressRecord]
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        let extraTokens = [
            "account_id",
            "device_id",
            "goal_id",
            "goal_text",
            "capture_text",
            "schedule",
            "calendar",
            "proof_payload",
            "receipt_payload",
            "private_context",
            "private_user_context",
            "life_graph",
            "personalized",
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
