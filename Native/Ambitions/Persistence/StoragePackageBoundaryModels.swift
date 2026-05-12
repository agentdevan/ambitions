import Foundation

let storagePackageBoundarySchemaVersion = "storage_package_boundary.native.v1"

enum StoragePackageBoundaryIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedManifest = "malformed_manifest"
    case sourceOutsideStorageRoot = "source_outside_storage_root"
    case forbiddenFrameworkImport = "forbidden_framework_import"
    case missingFoundationImport = "missing_foundation_import"
    case packageWiringNotDeclared = "package_wiring_not_declared"
    case localFirstOwnerNotDeclared = "local_first_owner_not_declared"
}

struct StoragePackageBoundaryManifest: Codable, Sendable, Equatable, Hashable {
    let moduleName: String
    let sourceRoot: String
    let plannedPackageProductName: String
    let allowedImports: [String]
    let forbiddenImports: [String]
    let declaredPersistenceTechnologies: [String]
    let packageWiringDeclared: Bool
    let localFirstOwnerDeclared: Bool
    let schemaVersion: String

    init(
        moduleName: String = "AmbitionsStorage",
        sourceRoot: String = "Native/Ambitions/Persistence",
        plannedPackageProductName: String = "AmbitionsStorage",
        allowedImports: [String] = ["AmbitionsDesignSystem", "Foundation", "SwiftData"],
        forbiddenImports: [String] = ["SwiftUI", "UIKit", "AppKit", "WidgetKit", "EventKit", "UserNotifications", "CloudKit"],
        declaredPersistenceTechnologies: [String] = ["SwiftData", "PortableSnapshots", "LocalPreferences"],
        packageWiringDeclared: Bool = false,
        localFirstOwnerDeclared: Bool = true,
        schemaVersion: String = storagePackageBoundarySchemaVersion
    ) {
        self.moduleName = moduleName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRoot = sourceRoot.trimmingCharacters(in: .whitespacesAndNewlines)
        self.plannedPackageProductName = plannedPackageProductName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.allowedImports = Self.orderedUnique(allowedImports)
        self.forbiddenImports = Self.orderedUnique(forbiddenImports)
        self.declaredPersistenceTechnologies = Self.orderedUnique(declaredPersistenceTechnologies)
        self.packageWiringDeclared = packageWiringDeclared
        self.localFirstOwnerDeclared = localFirstOwnerDeclared
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        moduleName.isEmpty == false &&
            sourceRoot.isEmpty == false &&
            plannedPackageProductName.isEmpty == false &&
            allowedImports.isEmpty == false &&
            forbiddenImports.isEmpty == false &&
            declaredPersistenceTechnologies.isEmpty == false
    }

    static let current = StoragePackageBoundaryManifest()

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct StorageSourceFileBoundary: Codable, Sendable, Equatable, Hashable {
    let path: String
    let imports: [String]

    init(path: String, imports: [String]) {
        self.path = path.trimmingCharacters(in: .whitespacesAndNewlines)
        self.imports = Array(Set(imports.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct StoragePackageBoundaryReport: Codable, Sendable, Equatable, Hashable {
    let manifest: StoragePackageBoundaryManifest
    let checkedFileCount: Int
    let issues: [StoragePackageBoundaryIssue]
    let offendingPaths: [String]

    var canMoveStorageToPackage: Bool {
        issues.isEmpty
    }
}

struct StoragePackageBoundaryValidator: Sendable, Equatable, Hashable {
    func validate(
        manifest: StoragePackageBoundaryManifest,
        files: [StorageSourceFileBoundary]
    ) -> StoragePackageBoundaryReport {
        var issues: Set<StoragePackageBoundaryIssue> = []
        var offendingPaths: Set<String> = []

        if manifest.schemaVersion != storagePackageBoundarySchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if manifest.isWellFormed == false {
            issues.insert(.malformedManifest)
        }
        if manifest.packageWiringDeclared == false {
            issues.insert(.packageWiringNotDeclared)
        }
        if manifest.localFirstOwnerDeclared == false {
            issues.insert(.localFirstOwnerNotDeclared)
        }

        for file in files {
            if file.path.hasPrefix(manifest.sourceRoot + "/") == false {
                issues.insert(.sourceOutsideStorageRoot)
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

        return StoragePackageBoundaryReport(
            manifest: manifest,
            checkedFileCount: files.count,
            issues: issues.sorted { $0.rawValue < $1.rawValue },
            offendingPaths: offendingPaths.sorted()
        )
    }
}
