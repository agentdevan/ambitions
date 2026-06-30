import Foundation

enum LocalOnlyModeIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localPersistenceMissing = "local_persistence_missing"
    case repositoryBackedMemoryMissing = "repository_backed_memory_missing"
    case nonLocalSyncBackend = "non_local_sync_backend"
    case hostedPrivateLifeBackend = "hosted_private_life_backend"
    case remoteIntelligenceBackend = "remote_intelligence_backend"
    case externalCloudLLMDependency = "external_cloud_llm_dependency"
    case externalSideEffectInsideUnitOfWork = "external_side_effect_inside_unit_of_work"
}

struct LocalOnlyMode: Codable, Sendable, Equatable, Hashable {
    let offlineCoreAvailable: Bool
    let accountRequiredForCoreValue: Bool
    let permitsHostedPrivateLifeGraph: Bool
    let permitsRemoteIntelligenceBackend: Bool
    let permitsExternalCloudLLMDependency: Bool
    let permitsExternalSideEffectsInsideUnitOfWork: Bool
    let issues: [LocalOnlyModeIssue]

    init(
        offlineCoreAvailable: Bool,
        accountRequiredForCoreValue: Bool,
        permitsHostedPrivateLifeGraph: Bool,
        permitsRemoteIntelligenceBackend: Bool,
        permitsExternalCloudLLMDependency: Bool,
        permitsExternalSideEffectsInsideUnitOfWork: Bool,
        issues: [LocalOnlyModeIssue]
    ) {
        self.offlineCoreAvailable = offlineCoreAvailable
        self.accountRequiredForCoreValue = accountRequiredForCoreValue
        self.permitsHostedPrivateLifeGraph = permitsHostedPrivateLifeGraph
        self.permitsRemoteIntelligenceBackend = permitsRemoteIntelligenceBackend
        self.permitsExternalCloudLLMDependency = permitsExternalCloudLLMDependency
        self.permitsExternalSideEffectsInsideUnitOfWork = permitsExternalSideEffectsInsideUnitOfWork
        self.issues = Self.orderedUnique(issues)
    }

    init(boundary: PrivateLifeRuntimeBoundary) {
        var issues: [LocalOnlyModeIssue] = []
        if boundary.usesSwiftDataPersistence == false { issues.append(.localPersistenceMissing) }
        if boundary.usesRepositoryBackedMemory == false { issues.append(.repositoryBackedMemoryMissing) }
        if boundary.syncBackendKind != .localOnly { issues.append(.nonLocalSyncBackend) }
        if boundary.hasHostedBackend { issues.append(.hostedPrivateLifeBackend) }
        if boundary.hasRemoteIntelligenceBackend { issues.append(.remoteIntelligenceBackend) }
        if boundary.hasExternalCloudLLMDependency { issues.append(.externalCloudLLMDependency) }
        if boundary.allowsExternalSideEffectsInsideUnitOfWorkBoundaries {
            issues.append(.externalSideEffectInsideUnitOfWork)
        }

        self.init(
            offlineCoreAvailable: issues.isEmpty,
            accountRequiredForCoreValue: false,
            permitsHostedPrivateLifeGraph: false,
            permitsRemoteIntelligenceBackend: false,
            permitsExternalCloudLLMDependency: false,
            permitsExternalSideEffectsInsideUnitOfWork: false,
            issues: issues
        )
    }

    var isSatisfied: Bool {
        offlineCoreAvailable &&
            accountRequiredForCoreValue == false &&
            permitsHostedPrivateLifeGraph == false &&
            permitsRemoteIntelligenceBackend == false &&
            permitsExternalCloudLLMDependency == false &&
            permitsExternalSideEffectsInsideUnitOfWork == false &&
            issues.isEmpty
    }

    private static func orderedUnique(_ values: [LocalOnlyModeIssue]) -> [LocalOnlyModeIssue] {
        var seen = Set<LocalOnlyModeIssue>()
        return values.filter { seen.insert($0).inserted }
    }
}
