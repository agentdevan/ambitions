import Foundation

enum RuntimePrivacyBoundaryIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notLocalOnly = "not_local_only"
    case hostedBackend = "hosted_backend"
    case remoteIntelligence = "remote_intelligence"
    case cloudLLM = "cloud_llm"
    case externalSideEffectInsideUnitOfWork = "external_side_effect_inside_unit_of_work"
    case commandNotLocalOnly = "command_not_local_only"
}

struct PrivacyBoundary: Codable, Sendable, Equatable, Hashable {
    let localOnly: Bool
    let usesLocalPersistence: Bool
    let usesRepositoryBackedMemory: Bool
    let hasHostedBackend: Bool
    let hasRemoteIntelligenceBackend: Bool
    let hasExternalCloudLLMDependency: Bool
    let allowsExternalSideEffectsInsideUnitOfWorkBoundaries: Bool
    let privacy: EventLedgerPrivacyClassification
    let issues: [RuntimePrivacyBoundaryIssue]

    init(
        boundary: PrivateLifeRuntimeBoundary = .localOnly,
        privacy: EventLedgerPrivacyClassification = .standard,
        extraIssues: [RuntimePrivacyBoundaryIssue] = []
    ) {
        self.localOnly = boundary.isLocalOnly
        self.usesLocalPersistence = boundary.usesSwiftDataPersistence
        self.usesRepositoryBackedMemory = boundary.usesRepositoryBackedMemory
        self.hasHostedBackend = boundary.hasHostedBackend
        self.hasRemoteIntelligenceBackend = boundary.hasRemoteIntelligenceBackend
        self.hasExternalCloudLLMDependency = boundary.hasExternalCloudLLMDependency
        self.allowsExternalSideEffectsInsideUnitOfWorkBoundaries = boundary.allowsExternalSideEffectsInsideUnitOfWorkBoundaries
        self.privacy = privacy

        var derivedIssues = extraIssues
        if boundary.isLocalOnly == false { derivedIssues.append(.notLocalOnly) }
        if boundary.hasHostedBackend { derivedIssues.append(.hostedBackend) }
        if boundary.hasRemoteIntelligenceBackend { derivedIssues.append(.remoteIntelligence) }
        if boundary.hasExternalCloudLLMDependency { derivedIssues.append(.cloudLLM) }
        if boundary.allowsExternalSideEffectsInsideUnitOfWorkBoundaries {
            derivedIssues.append(.externalSideEffectInsideUnitOfWork)
        }
        self.issues = Self.orderedUnique(derivedIssues)
    }

    var isSatisfied: Bool {
        localOnly &&
            usesLocalPersistence &&
            usesRepositoryBackedMemory &&
            hasHostedBackend == false &&
            hasRemoteIntelligenceBackend == false &&
            hasExternalCloudLLMDependency == false &&
            allowsExternalSideEffectsInsideUnitOfWorkBoundaries == false &&
            issues.isEmpty
    }

    static func forCommand(
        _ command: AmbitionsCommand,
        boundary: PrivateLifeRuntimeBoundary = .localOnly
    ) -> PrivacyBoundary {
        PrivacyBoundary(
            boundary: boundary,
            privacy: command.privacy,
            extraIssues: command.localOnly ? [] : [.commandNotLocalOnly]
        )
    }

    private static func orderedUnique(_ values: [RuntimePrivacyBoundaryIssue]) -> [RuntimePrivacyBoundaryIssue] {
        var seen = Set<RuntimePrivacyBoundaryIssue>()
        return values.filter { seen.insert($0).inserted }
    }
}
