import XCTest
@testable import Ambitions

final class SurfaceLensesCanonicalOwnershipTests: XCTestCase {
    func testCanonicalSurfaceLensRegistryOwnsOnlyFourPersistentSurfaces() {
        XCTAssertEqual(SurfaceLensRegistry.validate(), [])
        XCTAssertEqual(
            SurfaceLensRegistry.canonicalContracts.map(\.surface),
            [.today, .goals, .time, .you]
        )
        XCTAssertEqual(
            SurfaceLensRegistry.canonicalContracts.map(\.primaryObjectTitle),
            ["Reality Meridian", "Constellation Atlas", "LifeShape Field", "User System Profile"]
        )
        XCTAssertFalse(SurfaceLensRegistry.canonicalContracts.map(\.surfaceTitle).contains("Capture"))
        XCTAssertFalse(SurfaceLensRegistry.canonicalContracts.map(\.surfaceTitle).contains("Motion"))
    }

    func testEachSurfaceLensContractIncludesObjectStateActionTrustAndFailureProof() {
        for contract in SurfaceLensRegistry.canonicalContracts {
            XCTAssertTrue(contract.satisfiesFinalCanon, contract.surface.rawValue)
            XCTAssertFalse(contract.primaryActionTitle.isEmpty, contract.surface.rawValue)
            XCTAssertTrue(contract.trustInspectionRequirements.contains("source"), contract.surface.rawValue)
            XCTAssertTrue(contract.trustInspectionRequirements.contains("proof"), contract.surface.rawValue)
            XCTAssertTrue(contract.trustInspectionRequirements.contains("receipt"), contract.surface.rawValue)
            XCTAssertFalse(contract.failureStateRequirements.isEmpty, contract.surface.rawValue)
        }
    }

    func testRequiredSurfaceLensFilesExistAtCanonicalPathsAndTodayMovedOutOfStageSceneOwner() throws {
        let root = repoRoot()
        let required = [
            "Native/Ambitions/Projection/SurfaceLenses/SurfaceLens.swift",
            "Native/Ambitions/Projection/SurfaceLenses/TodayLens.swift",
            "Native/Ambitions/Projection/SurfaceLenses/GoalsLens.swift",
            "Native/Ambitions/Projection/SurfaceLenses/TimeLens.swift",
            "Native/Ambitions/Projection/SurfaceLenses/YouLens.swift"
        ]

        for path in required {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }

        let todayLensSource = try source("Native/Ambitions/Projection/SurfaceLenses/TodayLens.swift", root: root)
        let stageSceneSource = try source("Native/Ambitions/Projection/StageScenes/TodayStageProjection.swift", root: root)

        XCTAssertTrue(todayLensSource.contains("struct TodayLens"))
        XCTAssertTrue(todayLensSource.contains("SurfaceLens"))
        XCTAssertFalse(stageSceneSource.contains("struct TodayLens"))
        XCTAssertTrue(stageSceneSource.contains("struct TodayStageScene"))
    }

    func testRegistryRejectsFifthSurfaceAndIncompleteContract() {
        let incomplete = SurfaceLensContract(
            surface: .today,
            surfaceTitle: "Today",
            primaryObjectTitle: "",
            primaryActionTitle: "",
            runtimeInputs: [],
            firstViewportContract: "",
            accessibilityContract: [],
            trustInspectionRequirements: [],
            failureStateRequirements: []
        )
        var contracts = SurfaceLensRegistry.canonicalContracts
        contracts[0] = incomplete

        let issues = SurfaceLensRegistry.validate(contracts)

        XCTAssertTrue(issues.contains { $0.contains("Today surface lens is missing") })
    }

    private func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
