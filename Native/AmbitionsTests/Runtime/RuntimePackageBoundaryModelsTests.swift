import XCTest
@testable import Ambitions

final class RuntimePackageBoundaryModelsTests: XCTestCase {
    func testCurrentManifestDefinesRuntimePackageBoundaryWithoutRemoteBackendOrProjectWiringClaim() {
        let manifest = RuntimePackageBoundaryManifest.current

        XCTAssertEqual(manifest.moduleName, "AmbitionsRuntime")
        XCTAssertEqual(manifest.sourceRoot, "Native/Ambitions/Runtime")
        XCTAssertEqual(manifest.plannedPackageProductName, "AmbitionsRuntime")
        XCTAssertTrue(manifest.allowedImports.contains("Foundation"))
        XCTAssertTrue(manifest.allowedImports.contains("AmbitionsDesignSystem"))
        XCTAssertTrue(manifest.forbiddenImports.contains("SwiftUI"))
        XCTAssertTrue(manifest.runtimeCapabilities.contains("RepositoryBackedRuntime"))
        XCTAssertTrue(manifest.localRuntimeOwnerDeclared)
        XCTAssertFalse(manifest.remoteIntelligenceBackendDeclared)
        XCTAssertFalse(manifest.packageWiringDeclared)
    }

    func testValidatorAcceptsRuntimeFilesWhenWiringAndLocalRuntimeAreDeclared() {
        let manifest = RuntimePackageBoundaryManifest(packageWiringDeclared: true)
        let files = [
            RuntimeSourceFileBoundary(
                path: "Native/Ambitions/Runtime/AmbitionsRuntimeContracts.swift",
                imports: ["Foundation"]
            ),
            RuntimeSourceFileBoundary(
                path: "Native/Ambitions/Runtime/AmbitionsRuntimeServices.swift",
                imports: ["AmbitionsDesignSystem", "Foundation"]
            ),
            RuntimeSourceFileBoundary(
                path: "Native/Ambitions/Runtime/DedicatedDevicePrototypeRuntime.swift",
                imports: ["Foundation"]
            )
        ]

        let report = RuntimePackageBoundaryValidator().validate(manifest: manifest, files: files)

        XCTAssertEqual(report.checkedFileCount, 3)
        XCTAssertEqual(report.issues, [])
        XCTAssertEqual(report.offendingPaths, [])
        XCTAssertTrue(report.canMoveRuntimeToPackage)
    }

    func testValidatorBlocksForbiddenImportsOutOfRootFilesAndRemoteRuntimeClaims() {
        let files = [
            RuntimeSourceFileBoundary(
                path: "Native/Ambitions/Runtime/BadRuntimeView.swift",
                imports: ["Foundation", "SwiftUI"]
            ),
            RuntimeSourceFileBoundary(
                path: "Native/Ambitions/Services/RuntimeBridge.swift",
                imports: ["Foundation"]
            ),
            RuntimeSourceFileBoundary(
                path: "Native/Ambitions/Runtime/MissingFoundation.swift",
                imports: ["AmbitionsDesignSystem"]
            )
        ]

        let report = RuntimePackageBoundaryValidator().validate(
            manifest: RuntimePackageBoundaryManifest(
                localRuntimeOwnerDeclared: false,
                remoteIntelligenceBackendDeclared: true
            ),
            files: files
        )

        XCTAssertTrue(report.issues.contains(.forbiddenFrameworkImport))
        XCTAssertTrue(report.issues.contains(.sourceOutsideRuntimeRoot))
        XCTAssertTrue(report.issues.contains(.missingFoundationImport))
        XCTAssertTrue(report.issues.contains(.packageWiringNotDeclared))
        XCTAssertTrue(report.issues.contains(.localRuntimeOwnerNotDeclared))
        XCTAssertTrue(report.issues.contains(.remoteIntelligenceBackendDeclared))
        XCTAssertEqual(
            report.offendingPaths,
            [
                "Native/Ambitions/Runtime/BadRuntimeView.swift",
                "Native/Ambitions/Runtime/MissingFoundation.swift",
                "Native/Ambitions/Services/RuntimeBridge.swift"
            ]
        )
        XCTAssertFalse(report.canMoveRuntimeToPackage)
    }
}
