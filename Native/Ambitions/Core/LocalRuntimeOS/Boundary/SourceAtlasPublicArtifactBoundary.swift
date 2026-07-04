import Foundation

struct SourceAtlasPublicArtifactObjectKey: Codable, Sendable, Equatable, Hashable {
    let channel: String
    let packID: String
    let versionID: String
    let sha256: String

    var value: String {
        "source-atlas/public/\(channel)/\(packID)/\(versionID)/\(sha256).json"
    }

    var egressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        SourceAtlasNoPrivateGraphEgressRecord(
            surface: .objectKey,
            identifier: "source-atlas-object-key",
            inspectedValue: value
        )
    }
}

struct SourceAtlasPublicArtifactLogRecord: Codable, Sendable, Equatable, Hashable {
    let event: String
    let packID: String
    let manifestVersionID: String
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let selectedSource: SourceAtlasStorePayloadSource?

    var line: String {
        [
            "event=\(event)",
            "pack_id=\(packID)",
            "manifest_version=\(manifestVersionID)",
            "source_state=\(sourceState.rawValue)",
            "freshness_state=\(freshnessState.rawValue)",
            "selected_source=\(selectedSource?.rawValue ?? "none")",
        ].joined(separator: " ")
    }

    var egressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        SourceAtlasNoPrivateGraphEgressRecord(
            surface: .logLine,
            identifier: event,
            inspectedValue: line
        )
    }
}

struct SourceAtlasPublicArtifactCacheMetadata: Codable, Sendable, Equatable, Hashable {
    let cacheNamespace: String
    let packID: String
    let manifestVersionID: String
    let selectedSource: SourceAtlasStorePayloadSource?
    let selectedSourceState: SourceAtlasRequirementSourceState
    let selectedFreshnessState: SourceAtlasRequirementFreshnessState
    let quarantinedSourceCount: Int
    let fallbackTriggered: Bool

    var serializedSummary: String {
        [
            "cache_namespace=\(cacheNamespace)",
            "pack_id=\(packID)",
            "manifest_version=\(manifestVersionID)",
            "selected_source=\(selectedSource?.rawValue ?? "none")",
            "source_state=\(selectedSourceState.rawValue)",
            "freshness_state=\(selectedFreshnessState.rawValue)",
            "quarantined_count=\(quarantinedSourceCount)",
            "fallback=\(fallbackTriggered)",
        ].joined(separator: " ")
    }

    var egressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        SourceAtlasNoPrivateGraphEgressRecord(
            surface: .cacheMetadata,
            identifier: "source-atlas-cache-metadata",
            inspectedValue: serializedSummary
        )
    }

    static func make(
        packID: String,
        resolution: SourceAtlasLocalPackCacheResolution
    ) -> SourceAtlasPublicArtifactCacheMetadata {
        SourceAtlasPublicArtifactCacheMetadata(
            cacheNamespace: SourceAtlasLocalStorageBoundaryProof.publicReferenceCacheNamespace,
            packID: packID,
            manifestVersionID: resolution.updateRecord.manifestVersionID,
            selectedSource: resolution.loadResult.selectedSource,
            selectedSourceState: resolution.fallback.selectedSourceState,
            selectedFreshnessState: resolution.fallback.selectedFreshnessState,
            quarantinedSourceCount: resolution.updateRecord.quarantinedSourceCount,
            fallbackTriggered: resolution.updateRecord.fallbackTriggered
        )
    }
}

struct SourceAtlasLocalStorageBoundaryProof: Codable, Sendable, Equatable, Hashable {
    static let publicReferenceCacheNamespace = "source_atlas_public_reference_cache"
    static let privateRuntimeNamespace = "private_life_runtime_store"
    static let privacyManifestPath = "Native/Ambitions/Resources/PrivacyInfo.xcprivacy"

    let sourceAtlasCacheNamespace: String
    let privateRuntimeNamespace: String
    let privacyManifestPath: String
    let cacheStoresOnlyPublicReferenceArtifacts: Bool
    let privateRuntimeStorageSeparated: Bool
    let noPrivateGraphInPublicManifest: Bool

    static let current = SourceAtlasLocalStorageBoundaryProof(
        sourceAtlasCacheNamespace: publicReferenceCacheNamespace,
        privateRuntimeNamespace: privateRuntimeNamespace,
        privacyManifestPath: privacyManifestPath,
        cacheStoresOnlyPublicReferenceArtifacts: true,
        privateRuntimeStorageSeparated: true,
        noPrivateGraphInPublicManifest: true
    )

    var validationFailures: [String] {
        var failures: [String] = []
        if sourceAtlasCacheNamespace == privateRuntimeNamespace {
            failures.append("Source Atlas public reference cache must not share the private runtime namespace.")
        }
        if cacheStoresOnlyPublicReferenceArtifacts == false {
            failures.append("Source Atlas cache must store only public/reference artifacts.")
        }
        if privateRuntimeStorageSeparated == false {
            failures.append("Private runtime storage must remain separated from Source Atlas cache storage.")
        }
        if noPrivateGraphInPublicManifest == false {
            failures.append("Public manifests must not carry private life graph data.")
        }
        if privacyManifestPath != Self.privacyManifestPath {
            failures.append("Privacy manifest path changed without updating the Source Atlas storage boundary proof.")
        }
        return failures
    }
}

enum SourceAtlasAccountBoundaryAction: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case prepareExport = "prepare_export"
    case resetLocalRuntime = "reset_local_runtime"
    case signOut = "sign_out"
    case deleteAccount = "delete_account"
}

struct SourceAtlasAccountCacheBoundaryDecision: Codable, Sendable, Equatable, Hashable {
    let action: SourceAtlasAccountBoundaryAction
    let exportsPrivateRuntimeData: Bool
    let deletesPrivateRuntimeData: Bool
    let deletesAccountSecrets: Bool
    let preservesPublicReferenceCache: Bool
    let requiresAccountProviderFlow: Bool
    let accountReadinessClaimAllowed: Bool
    let summary: String

    static func decision(for action: SourceAtlasAccountBoundaryAction) -> SourceAtlasAccountCacheBoundaryDecision {
        switch action {
        case .prepareExport:
            SourceAtlasAccountCacheBoundaryDecision(
                action: action,
                exportsPrivateRuntimeData: true,
                deletesPrivateRuntimeData: false,
                deletesAccountSecrets: false,
                preservesPublicReferenceCache: true,
                requiresAccountProviderFlow: false,
                accountReadinessClaimAllowed: false,
                summary: "Export prepares local private data separately from public reference cache metadata."
            )
        case .resetLocalRuntime:
            SourceAtlasAccountCacheBoundaryDecision(
                action: action,
                exportsPrivateRuntimeData: false,
                deletesPrivateRuntimeData: true,
                deletesAccountSecrets: false,
                preservesPublicReferenceCache: true,
                requiresAccountProviderFlow: false,
                accountReadinessClaimAllowed: false,
                summary: "Local reset removes private runtime data without treating public reference cache as account data."
            )
        case .signOut:
            SourceAtlasAccountCacheBoundaryDecision(
                action: action,
                exportsPrivateRuntimeData: false,
                deletesPrivateRuntimeData: false,
                deletesAccountSecrets: true,
                preservesPublicReferenceCache: true,
                requiresAccountProviderFlow: true,
                accountReadinessClaimAllowed: false,
                summary: "Sign out clears account credentials while keeping offline local planning and public reference cache separate."
            )
        case .deleteAccount:
            SourceAtlasAccountCacheBoundaryDecision(
                action: action,
                exportsPrivateRuntimeData: false,
                deletesPrivateRuntimeData: false,
                deletesAccountSecrets: true,
                preservesPublicReferenceCache: true,
                requiresAccountProviderFlow: true,
                accountReadinessClaimAllowed: false,
                summary: "Delete-account proof is a boundary contract only; provider deletion flow readiness is not claimed."
            )
        }
    }

    var validationFailures: [String] {
        var failures: [String] = []
        if accountReadinessClaimAllowed {
            failures.append("Account cache boundary proof must not claim account readiness.")
        }
        if preservesPublicReferenceCache == false {
            failures.append("Account actions must not treat public reference cache as private account storage.")
        }
        if summary.localizedCaseInsensitiveContains("ready") {
            failures.append("Account cache boundary summary must avoid readiness wording.")
        }
        return failures
    }
}
