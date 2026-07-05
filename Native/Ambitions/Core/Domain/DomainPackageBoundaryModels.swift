import Foundation

let domainPackageBoundarySchemaVersion = "domain_package_boundary.native.v1"

enum DomainPackageBoundaryIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedManifest = "malformed_manifest"
    case sourceOutsideDomainRoot = "source_outside_domain_root"
    case forbiddenFrameworkImport = "forbidden_framework_import"
    case missingFoundationImport = "missing_foundation_import"
    case packageWiringNotDeclared = "package_wiring_not_declared"
}

struct DomainPackageBoundaryManifest: Codable, Sendable, Equatable, Hashable {
    let moduleName: String
    let sourceRoot: String
    let plannedPackageProductName: String
    let allowedImports: [String]
    let forbiddenImports: [String]
    let packageWiringDeclared: Bool
    let schemaVersion: String

    init(
        moduleName: String = "AmbitionsDomain",
        sourceRoot: String = "Native/Ambitions/Core/Domain",
        plannedPackageProductName: String = "AmbitionsDomain",
        allowedImports: [String] = ["Foundation"],
        forbiddenImports: [String] = ["SwiftUI", "UIKit", "AppKit", "WidgetKit", "EventKit", "UserNotifications", "CloudKit"],
        packageWiringDeclared: Bool = false,
        schemaVersion: String = domainPackageBoundarySchemaVersion
    ) {
        self.moduleName = moduleName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRoot = sourceRoot.trimmingCharacters(in: .whitespacesAndNewlines)
        self.plannedPackageProductName = plannedPackageProductName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.allowedImports = Self.orderedUnique(allowedImports)
        self.forbiddenImports = Self.orderedUnique(forbiddenImports)
        self.packageWiringDeclared = packageWiringDeclared
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        moduleName.isEmpty == false &&
            sourceRoot.isEmpty == false &&
            plannedPackageProductName.isEmpty == false &&
            allowedImports.isEmpty == false &&
            forbiddenImports.isEmpty == false
    }

    static let current = DomainPackageBoundaryManifest()

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct DomainSourceFileBoundary: Codable, Sendable, Equatable, Hashable {
    let path: String
    let imports: [String]

    init(path: String, imports: [String]) {
        self.path = path.trimmingCharacters(in: .whitespacesAndNewlines)
        self.imports = Array(Set(imports.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct DomainPackageBoundaryReport: Codable, Sendable, Equatable, Hashable {
    let manifest: DomainPackageBoundaryManifest
    let checkedFileCount: Int
    let issues: [DomainPackageBoundaryIssue]
    let offendingPaths: [String]

    var canMoveDomainToPackage: Bool {
        issues.isEmpty
    }
}

struct DomainPackageBoundaryValidator: Sendable, Equatable, Hashable {
    func validate(
        manifest: DomainPackageBoundaryManifest,
        files: [DomainSourceFileBoundary]
    ) -> DomainPackageBoundaryReport {
        var issues: Set<DomainPackageBoundaryIssue> = []
        var offendingPaths: Set<String> = []

        if manifest.schemaVersion != domainPackageBoundarySchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if manifest.isWellFormed == false {
            issues.insert(.malformedManifest)
        }
        if manifest.packageWiringDeclared == false {
            issues.insert(.packageWiringNotDeclared)
        }

        for file in files {
            if file.path.hasPrefix(manifest.sourceRoot + "/") == false {
                issues.insert(.sourceOutsideDomainRoot)
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

        return DomainPackageBoundaryReport(
            manifest: manifest,
            checkedFileCount: files.count,
            issues: issues.sorted { $0.rawValue < $1.rawValue },
            offendingPaths: offendingPaths.sorted()
        )
    }
}
