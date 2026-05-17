import XCTest
@testable import Ambitions

final class FeatureEnginePackageBoundaryModelsTests: XCTestCase {
    func testCurrentManifestDefinesFeatureEngineBoundaryWithoutProjectWiringClaim() {
        let manifest = FeatureEnginePackageBoundaryManifest.current

        XCTAssertEqual(manifest.moduleName, "AmbitionsFeatureEngines")
        XCTAssertEqual(manifest.sourceRoot, "Native/Ambitions/Features")
        XCTAssertEqual(manifest.plannedPackageProductName, "AmbitionsFeatureEngines")
        XCTAssertEqual(manifest.userFacingDestinationLabels, ["Capture", "Goals", "Time", "Today", "You"])
        XCTAssertEqual(manifest.activeDestinationSourceRoots, ["Captures", "Goals", "Time", "Today", "You"])
        XCTAssertTrue(manifest.compatibilityRoots.contains("Habits"))
        XCTAssertTrue(manifest.compatibilityRoots.contains("Insights"))
        XCTAssertTrue(manifest.sharedRoots.contains("Shared"))
        XCTAssertTrue(manifest.allowedImports.contains("SwiftUI"))
        XCTAssertTrue(manifest.allowedImports.contains("Observation"))
        XCTAssertTrue(manifest.allowedImports.contains("UIKit"))
        XCTAssertTrue(manifest.preservesActiveDestinationCanon)
        XCTAssertFalse(manifest.packageWiringDeclared)
    }

    func testValidatorAcceptsKnownFeatureRootsWhenWiringDeclared() {
        let manifest = FeatureEnginePackageBoundaryManifest(packageWiringDeclared: true)
        let files = [
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/Today/TodayFeatureService.swift", imports: ["AmbitionsDesignSystem", "Foundation"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/Goals/GoalsFeatureService.swift", imports: ["AmbitionsDesignSystem", "Foundation"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/Captures/CapturesScreen.swift", imports: ["AmbitionsDesignSystem", "SwiftUI"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/Time/TimeFeatureService.swift", imports: ["AmbitionsDesignSystem", "Foundation"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/You/YouScreen.swift", imports: ["AmbitionsDesignSystem", "SwiftUI", "UIKit"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/Shared/FeatureScaffoldView.swift", imports: ["AmbitionsDesignSystem", "SwiftUI"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/Insights/InsightsViewModel.swift", imports: ["Foundation", "Observation"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/Habits/HabitsFeatureService.swift", imports: ["Foundation"])
        ]

        let report = FeatureEnginePackageBoundaryValidator().validate(manifest: manifest, files: files)

        XCTAssertEqual(report.checkedFileCount, 8)
        XCTAssertEqual(report.issues, [])
        XCTAssertEqual(report.offendingPaths, [])
        XCTAssertTrue(report.canMoveFeatureEnginesToPackage)
    }

    func testValidatorBlocksOutOfRootUnknownFeatureForbiddenImportsAndMissingImports() {
        let files = [
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/Today/TodayScreen.swift", imports: ["AmbitionsDesignSystem", "SwiftUI"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/Goals/GoalsScreen.swift", imports: ["AmbitionsDesignSystem", "SwiftUI"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/Captures/CapturesScreen.swift", imports: ["AmbitionsDesignSystem", "SwiftUI"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/Time/TimeFeatureService.swift", imports: ["Foundation"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/You/YouScreen.swift", imports: ["SwiftUI", "UIKit"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/Tasks/TasksScreen.swift", imports: ["SwiftUI"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Runtime/AmbitionsRuntimeServices.swift", imports: ["Foundation"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/Today/BadCloudFeature.swift", imports: ["Foundation", "CloudKit"]),
            FeatureEngineSourceFileBoundary(path: "Native/Ambitions/Features/Shared/MissingImport.swift", imports: [])
        ]

        let report = FeatureEnginePackageBoundaryValidator().validate(
            manifest: .current,
            files: files
        )

        XCTAssertTrue(report.issues.contains(.packageWiringNotDeclared))
        XCTAssertTrue(report.issues.contains(.unknownFeatureRoot))
        XCTAssertTrue(report.issues.contains(.sourceOutsideFeaturesRoot))
        XCTAssertTrue(report.issues.contains(.forbiddenFrameworkImport))
        XCTAssertTrue(report.issues.contains(.missingFeatureImport))
        XCTAssertEqual(
            report.offendingPaths,
            [
                "Native/Ambitions/Features/Shared/MissingImport.swift",
                "Native/Ambitions/Features/Tasks/TasksScreen.swift",
                "Native/Ambitions/Features/Today/BadCloudFeature.swift",
                "Native/Ambitions/Runtime/AmbitionsRuntimeServices.swift"
            ]
        )
        XCTAssertFalse(report.canMoveFeatureEnginesToPackage)
    }
}
