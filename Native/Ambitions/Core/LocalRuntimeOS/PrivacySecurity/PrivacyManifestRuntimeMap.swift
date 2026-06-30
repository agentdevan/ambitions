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

enum PrivacyManifestRuntimeIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case manifestPathMismatch = "manifest_path_mismatch"
    case trackingEnabled = "tracking_enabled"
    case collectedDataTypesDeclared = "collected_data_types_declared"
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
