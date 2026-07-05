import Foundation

struct PrivacyManifestRuntimeFacts: Codable, Sendable, Equatable {
    let manifestPath: String
    let trackingEnabled: Bool
    let collectedDataTypeCount: Int
    let accessedAPITypeCount: Int
    let runtimeBoundary: PrivateLifeRuntimeBoundary

    init(
        manifestPath: String = "Native/Ambitions/Resources/PrivacyInfo.xcprivacy",
        trackingEnabled: Bool,
        collectedDataTypeCount: Int,
        accessedAPITypeCount: Int,
        runtimeBoundary: PrivateLifeRuntimeBoundary = .localOnly
    ) {
        self.manifestPath = manifestPath.trimmingCharacters(in: .whitespacesAndNewlines)
        self.trackingEnabled = trackingEnabled
        self.collectedDataTypeCount = collectedDataTypeCount
        self.accessedAPITypeCount = accessedAPITypeCount
        self.runtimeBoundary = runtimeBoundary
    }
}

struct PrivacyManifestAccessedAPIEntry: Identifiable, Codable, Sendable, Equatable, Hashable {
    let id: String
    let apiType: String
    let reasonCodes: [String]
    let sourceReferences: [String]
    let localOnlyJustification: String
}

struct PrivacyManifestDataAndAccessedAPIInventory: Codable, Sendable, Equatable, Hashable {
    let manifestPath: String
    let collectedDataTypes: [String]
    let accessedAPITypes: [PrivacyManifestAccessedAPIEntry]
    let trackingEnabled: Bool
    let legalApprovalClaimed: Bool
    let appStoreReadinessClaimed: Bool

    static let current = PrivacyManifestDataAndAccessedAPIInventory(
        manifestPath: PrivacyManifestRuntimeMap.expectedManifestPath,
        collectedDataTypes: [],
        accessedAPITypes: [
            PrivacyManifestAccessedAPIEntry(
                id: "privacy-manifest.accessed-api.file-timestamp.prior-store-sidecar-size",
                apiType: "NSPrivacyAccessedAPICategoryFileTimestamp",
                reasonCodes: ["C617.1"],
                sourceReferences: [
                    "Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftDataLegacyMigration.swift:66"
                ],
                localOnlyJustification: "Reads app-owned prior SwiftData sidecar file metadata inside local/app-group storage to remove empty migrated files; no derived information is sent off-device."
            )
        ],
        trackingEnabled: false,
        legalApprovalClaimed: false,
        appStoreReadinessClaimed: false
    )
}

enum PrivacyManifestRuntimeIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case manifestPathMismatch = "manifest_path_mismatch"
    case trackingEnabled = "tracking_enabled"
    case collectedDataTypesDeclared = "collected_data_types_declared"
    case accessedAPITypeCountMismatch = "accessed_api_type_count_mismatch"
    case nonLocalRuntimeBoundary = "non_local_runtime_boundary"
}

struct PrivacyManifestRuntimeMapDecision: Codable, Sendable, Equatable, Hashable {
    let manifestPath: String
    let localOnlyRuntime: Bool
    let trackingEnabled: Bool
    let collectedDataTypeCount: Int
    let accessedAPITypeCount: Int
    let issues: [PrivacyManifestRuntimeIssue]

    var isSatisfied: Bool {
        issues.isEmpty
    }
}

struct PrivacyManifestRuntimeMap: Sendable, Equatable, Hashable {
    static let expectedManifestPath = "Native/Ambitions/Resources/PrivacyInfo.xcprivacy"

    func evaluate(_ facts: PrivacyManifestRuntimeFacts) -> PrivacyManifestRuntimeMapDecision {
        var issues: [PrivacyManifestRuntimeIssue] = []
        if facts.manifestPath != Self.expectedManifestPath {
            issues.append(.manifestPathMismatch)
        }
        if facts.trackingEnabled {
            issues.append(.trackingEnabled)
        }
        if facts.collectedDataTypeCount > 0 {
            issues.append(.collectedDataTypesDeclared)
        }
        if facts.accessedAPITypeCount != PrivacyManifestDataAndAccessedAPIInventory.current.accessedAPITypes.count {
            issues.append(.accessedAPITypeCountMismatch)
        }
        if facts.runtimeBoundary.isLocalOnly == false {
            issues.append(.nonLocalRuntimeBoundary)
        }

        return PrivacyManifestRuntimeMapDecision(
            manifestPath: facts.manifestPath,
            localOnlyRuntime: facts.runtimeBoundary.isLocalOnly,
            trackingEnabled: facts.trackingEnabled,
            collectedDataTypeCount: facts.collectedDataTypeCount,
            accessedAPITypeCount: facts.accessedAPITypeCount,
            issues: issues
        )
    }
}
