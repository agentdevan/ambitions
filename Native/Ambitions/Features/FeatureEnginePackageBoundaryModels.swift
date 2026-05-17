import Foundation

let featureEnginePackageBoundarySchemaVersion = "feature_engine_package_boundary.native.v1"

enum FeatureEnginePackageBoundaryIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedManifest = "malformed_manifest"
    case sourceOutsideFeaturesRoot = "source_outside_features_root"
    case unknownFeatureRoot = "unknown_feature_root"
    case missingRequiredDestinationRoot = "missing_required_destination_root"
    case forbiddenFrameworkImport = "forbidden_framework_import"
    case missingFeatureImport = "missing_feature_import"
    case packageWiringNotDeclared = "package_wiring_not_declared"
    case activeIACanonMismatch = "active_ia_canon_mismatch"
}

struct FeatureEnginePackageBoundaryManifest: Codable, Sendable, Equatable, Hashable {
    let moduleName: String
    let sourceRoot: String
    let plannedPackageProductName: String
    let userFacingDestinationLabels: [String]
    let activeDestinationSourceRoots: [String]
    let compatibilityRoots: [String]
    let sharedRoots: [String]
    let allowedImports: [String]
    let forbiddenImports: [String]
    let packageWiringDeclared: Bool
    let schemaVersion: String

    init(
        moduleName: String = "AmbitionsFeatureEngines",
        sourceRoot: String = "Native/Ambitions/Features",
        plannedPackageProductName: String = "AmbitionsFeatureEngines",
        userFacingDestinationLabels: [String] = ["Capture", "Goals", "Time", "Today", "You"],
        activeDestinationSourceRoots: [String] = ["Captures", "Goals", "Time", "You", "Today"],
        compatibilityRoots: [String] = ["Habits", "Insights", "Onboarding"],
        sharedRoots: [String] = ["Shared"],
        allowedImports: [String] = ["AmbitionsDesignSystem", "Foundation", "Observation", "SwiftUI", "UIKit"],
        forbiddenImports: [String] = ["AppKit", "WidgetKit", "EventKit", "UserNotifications", "CloudKit"],
        packageWiringDeclared: Bool = false,
        schemaVersion: String = featureEnginePackageBoundarySchemaVersion
    ) {
        self.moduleName = moduleName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRoot = sourceRoot.trimmingCharacters(in: .whitespacesAndNewlines)
        self.plannedPackageProductName = plannedPackageProductName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.userFacingDestinationLabels = Self.orderedUnique(userFacingDestinationLabels)
        self.activeDestinationSourceRoots = Self.orderedUnique(activeDestinationSourceRoots)
        self.compatibilityRoots = Self.orderedUnique(compatibilityRoots)
        self.sharedRoots = Self.orderedUnique(sharedRoots)
        self.allowedImports = Self.orderedUnique(allowedImports)
        self.forbiddenImports = Self.orderedUnique(forbiddenImports)
        self.packageWiringDeclared = packageWiringDeclared
        self.schemaVersion = schemaVersion
    }

    var allKnownRoots: [String] {
        Self.orderedUnique(activeDestinationSourceRoots + compatibilityRoots + sharedRoots)
    }

    var preservesActiveDestinationCanon: Bool {
        userFacingDestinationLabels == ["Capture", "Goals", "Time", "Today", "You"] &&
            activeDestinationSourceRoots == ["Captures", "Goals", "Time", "Today", "You"] &&
            compatibilityRoots.contains("Habits") &&
            compatibilityRoots.contains("Insights") &&
            compatibilityRoots.contains("Onboarding")
    }

    var isWellFormed: Bool {
        moduleName.isEmpty == false &&
            sourceRoot.isEmpty == false &&
            plannedPackageProductName.isEmpty == false &&
            userFacingDestinationLabels.isEmpty == false &&
            activeDestinationSourceRoots.isEmpty == false &&
            sharedRoots.isEmpty == false &&
            allowedImports.isEmpty == false &&
            forbiddenImports.isEmpty == false
    }

    static let current = FeatureEnginePackageBoundaryManifest()

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct FeatureEngineSourceFileBoundary: Codable, Sendable, Equatable, Hashable {
    let path: String
    let imports: [String]

    init(path: String, imports: [String]) {
        self.path = path.trimmingCharacters(in: .whitespacesAndNewlines)
        self.imports = Array(Set(imports.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    var featureRoot: String? {
        let components = path.split(separator: "/").map(String.init)
        guard let featuresIndex = components.firstIndex(of: "Features"),
              components.indices.contains(featuresIndex + 1) else {
            return nil
        }
        return components[featuresIndex + 1]
    }
}

struct FeatureEnginePackageBoundaryReport: Codable, Sendable, Equatable, Hashable {
    let manifest: FeatureEnginePackageBoundaryManifest
    let checkedFileCount: Int
    let issues: [FeatureEnginePackageBoundaryIssue]
    let offendingPaths: [String]

    var canMoveFeatureEnginesToPackage: Bool {
        issues.isEmpty
    }
}

struct FeatureEnginePackageBoundaryValidator: Sendable, Equatable, Hashable {
    func validate(
        manifest: FeatureEnginePackageBoundaryManifest,
        files: [FeatureEngineSourceFileBoundary]
    ) -> FeatureEnginePackageBoundaryReport {
        var issues: Set<FeatureEnginePackageBoundaryIssue> = []
        var offendingPaths: Set<String> = []

        if manifest.schemaVersion != featureEnginePackageBoundarySchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if manifest.isWellFormed == false {
            issues.insert(.malformedManifest)
        }
        if manifest.packageWiringDeclared == false {
            issues.insert(.packageWiringNotDeclared)
        }
        if manifest.preservesActiveDestinationCanon == false {
            issues.insert(.activeIACanonMismatch)
        }

        let seenRoots = Set(files.compactMap(\.featureRoot))
        for root in manifest.activeDestinationSourceRoots where seenRoots.contains(root) == false {
            issues.insert(.missingRequiredDestinationRoot)
        }

        for file in files {
            guard file.path.hasPrefix(manifest.sourceRoot + "/") else {
                issues.insert(.sourceOutsideFeaturesRoot)
                offendingPaths.insert(file.path)
                continue
            }

            guard let root = file.featureRoot, manifest.allKnownRoots.contains(root) else {
                issues.insert(.unknownFeatureRoot)
                offendingPaths.insert(file.path)
                continue
            }

            if file.imports.isEmpty {
                issues.insert(.missingFeatureImport)
                offendingPaths.insert(file.path)
            }
            if file.imports.contains(where: { manifest.forbiddenImports.contains($0) }) {
                issues.insert(.forbiddenFrameworkImport)
                offendingPaths.insert(file.path)
            }
        }

        return FeatureEnginePackageBoundaryReport(
            manifest: manifest,
            checkedFileCount: files.count,
            issues: issues.sorted { $0.rawValue < $1.rawValue },
            offendingPaths: offendingPaths.sorted()
        )
    }
}
