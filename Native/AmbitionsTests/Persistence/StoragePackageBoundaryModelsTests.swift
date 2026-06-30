import XCTest
@testable import Ambitions

final class StoragePackageBoundaryModelsTests: XCTestCase {
    func testCurrentManifestDefinesStoragePackageBoundaryWithoutProjectWiringClaim() {
        let manifest = StoragePackageBoundaryManifest.current

        XCTAssertEqual(manifest.moduleName, "AmbitionsStorage")
        XCTAssertEqual(manifest.sourceRoot, "Native/Ambitions/Persistence")
        XCTAssertEqual(manifest.plannedPackageProductName, "AmbitionsStorage")
        XCTAssertTrue(manifest.allowedImports.contains("Foundation"))
        XCTAssertTrue(manifest.allowedImports.contains("SwiftData"))
        XCTAssertTrue(manifest.allowedImports.contains("AmbitionsDesignSystem"))
        XCTAssertTrue(manifest.forbiddenImports.contains("SwiftUI"))
        XCTAssertTrue(manifest.declaredPersistenceTechnologies.contains("SwiftData"))
        XCTAssertTrue(manifest.localFirstOwnerDeclared)
        XCTAssertFalse(manifest.packageWiringDeclared)
    }

    func testValidatorAcceptsPersistenceFilesWhenWiringAndLocalOwnershipAreDeclared() {
        let manifest = StoragePackageBoundaryManifest(packageWiringDeclared: true)
        let files = [
            StorageSourceFileBoundary(
                path: "Native/Ambitions/Persistence/SwiftDataModels.swift",
                imports: ["Foundation", "SwiftData"]
            ),
            StorageSourceFileBoundary(
                path: "Native/Ambitions/Persistence/PortableSnapshotService.swift",
                imports: ["Foundation"]
            ),
            StorageSourceFileBoundary(
                path: "Native/Ambitions/Persistence/StoreHealthCheck.swift",
                imports: ["Foundation"]
            )
        ]

        let report = StoragePackageBoundaryValidator().validate(manifest: manifest, files: files)

        XCTAssertEqual(report.checkedFileCount, 3)
        XCTAssertEqual(report.issues, [])
        XCTAssertEqual(report.offendingPaths, [])
        XCTAssertTrue(report.canMoveStorageToPackage)
    }

    func testValidatorBlocksForbiddenImportsOutOfRootFilesAndUnownedStorage() {
        let files = [
            StorageSourceFileBoundary(
                path: "Native/Ambitions/Persistence/BadStorageView.swift",
                imports: ["Foundation", "SwiftUI"]
            ),
            StorageSourceFileBoundary(
                path: "Native/Ambitions/Services/GoalService.swift",
                imports: ["Foundation"]
            ),
            StorageSourceFileBoundary(
                path: "Native/Ambitions/Persistence/MissingFoundation.swift",
                imports: ["SwiftData"]
            )
        ]

        let report = StoragePackageBoundaryValidator().validate(
            manifest: StoragePackageBoundaryManifest(localFirstOwnerDeclared: false),
            files: files
        )

        XCTAssertTrue(report.issues.contains(.forbiddenFrameworkImport))
        XCTAssertTrue(report.issues.contains(.sourceOutsideStorageRoot))
        XCTAssertTrue(report.issues.contains(.missingFoundationImport))
        XCTAssertTrue(report.issues.contains(.packageWiringNotDeclared))
        XCTAssertTrue(report.issues.contains(.localFirstOwnerNotDeclared))
        XCTAssertEqual(
            report.offendingPaths,
            [
                "Native/Ambitions/Persistence/BadStorageView.swift",
                "Native/Ambitions/Persistence/MissingFoundation.swift",
                "Native/Ambitions/Services/GoalService.swift"
            ]
        )
        XCTAssertFalse(report.canMoveStorageToPackage)
    }
}
