import Foundation

let runtimePackageBoundarySchemaVersion = "runtime_package_boundary.native.v1"

enum RuntimePackageBoundaryIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedManifest = "malformed_manifest"
    case sourceOutsideRuntimeRoot = "source_outside_runtime_root"
    case forbiddenFrameworkImport = "forbidden_framework_import"
    case missingFoundationImport = "missing_foundation_import"
    case packageWiringNotDeclared = "package_wiring_not_declared"
    case localRuntimeOwnerNotDeclared = "local_runtime_owner_not_declared"
    case remoteIntelligenceBackendDeclared = "remote_intelligence_backend_declared"
}

struct RuntimePackageBoundaryManifest: Codable, Sendable, Equatable, Hashable {
    let moduleName: String
    let sourceRoot: String
    let plannedPackageProductName: String
    let allowedImports: [String]
    let forbiddenImports: [String]
    let runtimeCapabilities: [String]
    let packageWiringDeclared: Bool
    let localRuntimeOwnerDeclared: Bool
    let remoteIntelligenceBackendDeclared: Bool
    let schemaVersion: String

    init(
        moduleName: String = "AmbitionsRuntime",
        sourceRoot: String = "Native/Ambitions/Runtime",
        plannedPackageProductName: String = "AmbitionsRuntime",
        allowedImports: [String] = ["AmbitionsDesignSystem", "Foundation"],
        forbiddenImports: [String] = ["SwiftUI", "UIKit", "AppKit", "WidgetKit", "EventKit", "UserNotifications", "CloudKit"],
        runtimeCapabilities: [String] = ["LocalMemoryContext", "RepositoryBackedRuntime", "ExternalActionCommandBoundary", "DedicatedDevicePrototypeBoundary"],
        packageWiringDeclared: Bool = false,
        localRuntimeOwnerDeclared: Bool = true,
        remoteIntelligenceBackendDeclared: Bool = false,
        schemaVersion: String = runtimePackageBoundarySchemaVersion
    ) {
        self.moduleName = moduleName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRoot = sourceRoot.trimmingCharacters(in: .whitespacesAndNewlines)
        self.plannedPackageProductName = plannedPackageProductName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.allowedImports = Self.orderedUnique(allowedImports)
        self.forbiddenImports = Self.orderedUnique(forbiddenImports)
        self.runtimeCapabilities = Self.orderedUnique(runtimeCapabilities)
        self.packageWiringDeclared = packageWiringDeclared
        self.localRuntimeOwnerDeclared = localRuntimeOwnerDeclared
        self.remoteIntelligenceBackendDeclared = remoteIntelligenceBackendDeclared
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        moduleName.isEmpty == false &&
            sourceRoot.isEmpty == false &&
            plannedPackageProductName.isEmpty == false &&
            allowedImports.isEmpty == false &&
            forbiddenImports.isEmpty == false &&
            runtimeCapabilities.isEmpty == false
    }

    static let current = RuntimePackageBoundaryManifest()

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct RuntimeSourceFileBoundary: Codable, Sendable, Equatable, Hashable {
    let path: String
    let imports: [String]

    init(path: String, imports: [String]) {
        self.path = path.trimmingCharacters(in: .whitespacesAndNewlines)
        self.imports = Array(Set(imports.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct RuntimePackageBoundaryReport: Codable, Sendable, Equatable, Hashable {
    let manifest: RuntimePackageBoundaryManifest
    let checkedFileCount: Int
    let issues: [RuntimePackageBoundaryIssue]
    let offendingPaths: [String]

    var canMoveRuntimeToPackage: Bool {
        issues.isEmpty
    }
}

struct RuntimePackageBoundaryValidator: Sendable, Equatable, Hashable {
    func validate(
        manifest: RuntimePackageBoundaryManifest,
        files: [RuntimeSourceFileBoundary]
    ) -> RuntimePackageBoundaryReport {
        var issues: Set<RuntimePackageBoundaryIssue> = []
        var offendingPaths: Set<String> = []

        if manifest.schemaVersion != runtimePackageBoundarySchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if manifest.isWellFormed == false {
            issues.insert(.malformedManifest)
        }
        if manifest.packageWiringDeclared == false {
            issues.insert(.packageWiringNotDeclared)
        }
        if manifest.localRuntimeOwnerDeclared == false {
            issues.insert(.localRuntimeOwnerNotDeclared)
        }
        if manifest.remoteIntelligenceBackendDeclared {
            issues.insert(.remoteIntelligenceBackendDeclared)
        }

        for file in files {
            if file.path.hasPrefix(manifest.sourceRoot + "/") == false {
                issues.insert(.sourceOutsideRuntimeRoot)
                offendingPaths.insert(file.path)
            }
            if file.imports.contains("Foundation") == false {
                issues.insert(.missingFoundationImport)
                offendingPaths.insert(file.path)
            }
            if file.imports.contains(where: { manifest.forbiddenImports.contains($0) }) {
                issues.insert(.forbiddenFrameworkImport)
                offendingPaths.insert(file.path)
            }
        }

        return RuntimePackageBoundaryReport(
            manifest: manifest,
            checkedFileCount: files.count,
            issues: issues.sorted { $0.rawValue < $1.rawValue },
            offendingPaths: offendingPaths.sorted()
        )
    }
}
