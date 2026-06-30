import Foundation

private final class SourceAtlasPublicPackRefreshTargetRegistryArtifactBundleAnchor: NSObject {}

enum SourceAtlasPublicPackRefreshTargetRegistryArtifactIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case artifactUnavailable = "artifact_unavailable"
    case artifactReadFailed = "artifact_read_failed"
    case artifactDecodeFailed = "artifact_decode_failed"
    case unsupportedSchemaVersion = "unsupported_schema_version"
    case nonPublicArtifact = "non_public_artifact"
    case privateArtifactMetadata = "private_artifact_metadata"
    case unsafeRegistryEntries = "unsafe_registry_entries"
}

struct SourceAtlasPublicPackRefreshTargetRegistryArtifact: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let artifactID: String
    let createdAt: String
    let publicReferenceOnly: Bool
    let registry: SourceAtlasPublicPackRefreshTargetRegistry
    let nonClaims: [String]

    init(
        schemaVersion: String,
        artifactID: String,
        createdAt: String,
        publicReferenceOnly: Bool = true,
        registry: SourceAtlasPublicPackRefreshTargetRegistry,
        nonClaims: [String] = []
    ) {
        self.schemaVersion = schemaVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.artifactID = artifactID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.createdAt = createdAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.publicReferenceOnly = publicReferenceOnly
        self.registry = registry
        self.nonClaims = nonClaims.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false }.sorted()
    }

    var egressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        SourceAtlasNoPrivateGraphEgressRecord(
            surface: .cacheMetadata,
            identifier: "source-atlas-public-refresh-target-registry-artifact",
            inspectedValue: [
                "schema_version=\(schemaVersion)",
                "artifact_id=\(artifactID)",
                "created_at=\(createdAt)",
                "public_reference_only=\(publicReferenceOnly)",
                "non_claims=\(nonClaims.joined(separator: ","))",
            ].joined(separator: " ")
        )
    }
}

struct SourceAtlasPublicPackRefreshTargetRegistryArtifactLoadResolution: Sendable, Equatable, Hashable {
    let registry: SourceAtlasPublicPackRefreshTargetRegistry
    let artifactID: String?
    let issues: [SourceAtlasPublicPackRefreshTargetRegistryArtifactIssue]
    let registryFindings: [SourceAtlasPublicPackRefreshTargetRegistryFinding]
    let egressFindings: [SourceAtlasNoPrivateGraphEgressFinding]
    let usedFallbackEmptyRegistry: Bool
    let sentPrivateRuntimeContext: Bool
    let generatedFinalPlan: Bool
    let generatedFinalSchedule: Bool
    let generatedStepList: Bool

    var coreLocalPlanningBlocked: Bool {
        false
    }
}

enum SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader {
    static let supportedSchemaVersion = "1.0.0"
    static let defaultResourceName = "source-atlas-public-refresh-targets"
    static let defaultResourceExtension = "json"

    static func defaultAppRegistry(
        bundle: Bundle = .main
    ) -> SourceAtlasPublicPackRefreshTargetRegistry {
        loadDefaultAppArtifact(bundle: bundle).registry
    }

    static func loadDefaultAppArtifact(
        bundle: Bundle = .main,
        resourceName: String = defaultResourceName,
        resourceExtension: String = defaultResourceExtension
    ) -> SourceAtlasPublicPackRefreshTargetRegistryArtifactLoadResolution {
        guard let url = defaultArtifactURL(
            bundle: bundle,
            resourceName: resourceName,
            resourceExtension: resourceExtension
        ) else {
            return fallbackResolution(issues: [.artifactUnavailable])
        }

        return loadArtifact(from: url)
    }

    static func loadArtifact(
        from url: URL
    ) -> SourceAtlasPublicPackRefreshTargetRegistryArtifactLoadResolution {
        do {
            return loadArtifact(data: try Data(contentsOf: url))
        } catch {
            return fallbackResolution(issues: [.artifactReadFailed])
        }
    }

    static func loadArtifact(
        data: Data
    ) -> SourceAtlasPublicPackRefreshTargetRegistryArtifactLoadResolution {
        let artifact: SourceAtlasPublicPackRefreshTargetRegistryArtifact
        do {
            artifact = try JSONDecoder().decode(SourceAtlasPublicPackRefreshTargetRegistryArtifact.self, from: data)
        } catch {
            return fallbackResolution(issues: [.artifactDecodeFailed])
        }

        return validate(artifact)
    }
}

private extension SourceAtlasPublicPackRefreshTargetRegistryArtifactLoader {
    static func defaultArtifactURL(
        bundle: Bundle,
        resourceName: String,
        resourceExtension: String
    ) -> URL? {
        if let url = bundle.url(forResource: resourceName, withExtension: resourceExtension) {
            return url
        }

        guard resourceName == defaultResourceName,
              resourceExtension == defaultResourceExtension
        else {
            return nil
        }

        return orderedUniqueBundles(
            [
                Bundle.main,
                Bundle(for: SourceAtlasPublicPackRefreshTargetRegistryArtifactBundleAnchor.self),
            ] + Bundle.allBundles + Bundle.allFrameworks
        )
        .lazy
        .compactMap { candidate in
            candidate.url(forResource: resourceName, withExtension: resourceExtension)
        }
        .first
    }

    static func validate(
        _ artifact: SourceAtlasPublicPackRefreshTargetRegistryArtifact
    ) -> SourceAtlasPublicPackRefreshTargetRegistryArtifactLoadResolution {
        var issues: Set<SourceAtlasPublicPackRefreshTargetRegistryArtifactIssue> = []
        var egressFindings = privateArtifactMetadataFindings([artifact.egressRecord])
        let registryValidation = validateRegistry(artifact.registry)

        if artifact.schemaVersion != supportedSchemaVersion {
            issues.insert(.unsupportedSchemaVersion)
        }

        if artifact.publicReferenceOnly == false {
            issues.insert(.nonPublicArtifact)
        }

        if egressFindings.isEmpty == false {
            issues.insert(.privateArtifactMetadata)
        }

        if registryValidation.hasUnsafeEntries {
            issues.insert(.unsafeRegistryEntries)
        }

        egressFindings = orderedUniqueEgressFindings(egressFindings + registryValidation.egressFindings)

        let orderedIssues = SourceAtlasPublicPackRefreshTargetRegistryArtifactIssue.allCases.filter { issues.contains($0) }
        guard orderedIssues.isEmpty else {
            return SourceAtlasPublicPackRefreshTargetRegistryArtifactLoadResolution(
                registry: SourceAtlasPublicPackRefreshTargetRegistry.defaultAppRegistry(),
                artifactID: artifact.artifactID.isEmpty ? nil : artifact.artifactID,
                issues: orderedIssues,
                registryFindings: registryValidation.findings,
                egressFindings: egressFindings,
                usedFallbackEmptyRegistry: true,
                sentPrivateRuntimeContext: false,
                generatedFinalPlan: false,
                generatedFinalSchedule: false,
                generatedStepList: false
            )
        }

        return SourceAtlasPublicPackRefreshTargetRegistryArtifactLoadResolution(
            registry: artifact.registry,
            artifactID: artifact.artifactID,
            issues: [],
            registryFindings: registryValidation.findings,
            egressFindings: [],
            usedFallbackEmptyRegistry: false,
            sentPrivateRuntimeContext: false,
            generatedFinalPlan: false,
            generatedFinalSchedule: false,
            generatedStepList: false
        )
    }

    static func validateRegistry(
        _ registry: SourceAtlasPublicPackRefreshTargetRegistry
    ) -> (
        findings: [SourceAtlasPublicPackRefreshTargetRegistryFinding],
        egressFindings: [SourceAtlasNoPrivateGraphEgressFinding],
        hasUnsafeEntries: Bool
    ) {
        var findings: [SourceAtlasPublicPackRefreshTargetRegistryFinding] = []
        var egressFindings: [SourceAtlasNoPrivateGraphEgressFinding] = []

        for mode in SourceAtlasPublicPackLifecycleRefreshMode.allCases {
            let resolution = registry.resolveTargets(for: mode)
            findings.append(contentsOf: resolution.findings)
            egressFindings.append(contentsOf: resolution.egressFindings)
        }

        let unsafeIssues: Set<SourceAtlasPublicPackRefreshTargetRegistryIssue> = [
            .duplicateTargetID,
            .unsafeTarget,
            .privateTargetMetadata,
            .unsafeManifestRequest,
        ]
        let uniqueFindings = orderedUniqueRegistryFindings(findings)
        let hasUnsafeEntries = uniqueFindings.contains { unsafeIssues.contains($0.issue) }
        return (
            findings: uniqueFindings,
            egressFindings: orderedUniqueEgressFindings(egressFindings),
            hasUnsafeEntries: hasUnsafeEntries
        )
    }

    static func privateArtifactMetadataFindings(
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
        return orderedUniqueEgressFindings(standardFindings + extraFindings)
    }

    static func fallbackResolution(
        issues: [SourceAtlasPublicPackRefreshTargetRegistryArtifactIssue]
    ) -> SourceAtlasPublicPackRefreshTargetRegistryArtifactLoadResolution {
        SourceAtlasPublicPackRefreshTargetRegistryArtifactLoadResolution(
            registry: SourceAtlasPublicPackRefreshTargetRegistry.defaultAppRegistry(),
            artifactID: nil,
            issues: SourceAtlasPublicPackRefreshTargetRegistryArtifactIssue.allCases.filter { issues.contains($0) },
            registryFindings: [],
            egressFindings: [],
            usedFallbackEmptyRegistry: true,
            sentPrivateRuntimeContext: false,
            generatedFinalPlan: false,
            generatedFinalSchedule: false,
            generatedStepList: false
        )
    }

    static func orderedUniqueRegistryFindings(
        _ findings: [SourceAtlasPublicPackRefreshTargetRegistryFinding]
    ) -> [SourceAtlasPublicPackRefreshTargetRegistryFinding] {
        var seen: Set<SourceAtlasPublicPackRefreshTargetRegistryFinding> = []
        return findings.filter { seen.insert($0).inserted }
    }

    static func orderedUniqueEgressFindings(
        _ findings: [SourceAtlasNoPrivateGraphEgressFinding]
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        var seen: Set<SourceAtlasNoPrivateGraphEgressFinding> = []
        return findings.filter { seen.insert($0).inserted }
    }

    static func orderedUniqueBundles(_ bundles: [Bundle]) -> [Bundle] {
        var seen: Set<URL> = []
        return bundles.filter { seen.insert($0.bundleURL).inserted }
    }
}
