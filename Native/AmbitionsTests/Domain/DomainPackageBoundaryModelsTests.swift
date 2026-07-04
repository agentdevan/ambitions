import XCTest
@testable import Ambitions

final class DomainPackageBoundaryModelsTests: XCTestCase {
    func testCurrentManifestDefinesDomainPackageBoundaryWithoutProjectWiringClaim() {
        let manifest = DomainPackageBoundaryManifest.current

        XCTAssertEqual(manifest.moduleName, "AmbitionsDomain")
        XCTAssertEqual(manifest.sourceRoot, "Native/Ambitions/Domain")
        XCTAssertEqual(manifest.plannedPackageProductName, "AmbitionsDomain")
        XCTAssertTrue(manifest.allowedImports.contains("Foundation"))
        XCTAssertTrue(manifest.forbiddenImports.contains("SwiftUI"))
        XCTAssertFalse(manifest.packageWiringDeclared)
    }

    func testValidatorAcceptsDomainFoundationOnlyFilesWhenWiringDeclared() {
        let manifest = DomainPackageBoundaryManifest(packageWiringDeclared: true)
        let files = [
            DomainSourceFileBoundary(
                path: "Native/Ambitions/Domain/DomainFoundation.swift",
                imports: ["Foundation"]
            ),
            DomainSourceFileBoundary(
                path: "Native/Ambitions/Domain/GoalEngine/GoalEngineContracts.swift",
                imports: ["Foundation"]
            )
        ]

        let report = DomainPackageBoundaryValidator().validate(manifest: manifest, files: files)

        XCTAssertEqual(report.checkedFileCount, 2)
        XCTAssertEqual(report.issues, [])
        XCTAssertEqual(report.offendingPaths, [])
        XCTAssertTrue(report.canMoveDomainToPackage)
    }

    func testValidatorBlocksForbiddenImportsAndOutOfRootFiles() {
        let files = [
            DomainSourceFileBoundary(
                path: "Native/Ambitions/Domain/BadView.swift",
                imports: ["Foundation", "SwiftUI"]
            ),
            DomainSourceFileBoundary(
                path: "Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService.swift",
                imports: ["Foundation"]
            ),
            DomainSourceFileBoundary(
                path: "Native/Ambitions/Domain/MissingFoundation.swift",
                imports: []
            )
        ]

        let report = DomainPackageBoundaryValidator().validate(
            manifest: .current,
            files: files
        )

        XCTAssertTrue(report.issues.contains(.forbiddenFrameworkImport))
        XCTAssertTrue(report.issues.contains(.sourceOutsideDomainRoot))
        XCTAssertTrue(report.issues.contains(.missingFoundationImport))
        XCTAssertTrue(report.issues.contains(.packageWiringNotDeclared))
        XCTAssertEqual(
            report.offendingPaths,
            [
                "Native/Ambitions/Domain/BadView.swift",
                "Native/Ambitions/Domain/MissingFoundation.swift",
                "Native/Ambitions/Surfaces/Today/Projection/TodayFeatureService.swift"
            ]
        )
        XCTAssertFalse(report.canMoveDomainToPackage)
    }
}
