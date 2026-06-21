import XCTest
@testable import Ambitions

final class StageScenesCanonicalOwnershipTests: XCTestCase {
    func testRequiredStageSceneFilesExistAtCanonicalPaths() throws {
        let root = repoRoot()
        let required = [
            "Native/Ambitions/Projection/StageScenes/TodayStageScene.swift",
            "Native/Ambitions/Projection/StageScenes/GoalsStageScene.swift",
            "Native/Ambitions/Projection/StageScenes/TimeStageScene.swift",
            "Native/Ambitions/Projection/StageScenes/YouStageScene.swift"
        ]

        for path in required {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }

        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Projection/StageScenes/TodayStageProjection.swift").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Projection/StageScenes/MotionStageScene.swift").path))
    }

    func testStageSceneSourcesStayLimitedToCanonSurfaceOwners() throws {
        let root = repoRoot()
        let today = try source("Native/Ambitions/Projection/StageScenes/TodayStageScene.swift", root: root)
        let goals = try source("Native/Ambitions/Projection/StageScenes/GoalsStageScene.swift", root: root)
        let time = try source("Native/Ambitions/Projection/StageScenes/TimeStageScene.swift", root: root)
        let you = try source("Native/Ambitions/Projection/StageScenes/YouStageScene.swift", root: root)
        let combined = [today, goals, time, you].joined(separator: "\n")

        XCTAssertTrue(today.contains("struct TodayStageScene"))
        XCTAssertTrue(goals.contains("struct GoalsStageScene"))
        XCTAssertTrue(time.contains("struct TimeStageScene"))
        XCTAssertTrue(you.contains("struct YouStageScene"))
        XCTAssertFalse(combined.contains("MotionStageScene"))
        XCTAssertFalse(combined.contains("CaptureStageScene"))
    }

    func testYouLensCreatesCanonAlignedStageSceneFromDashboard() {
        let dashboard = PreviewFixtures.default.youDashboard

        let scene = YouLens.makeStageScene(for: dashboard)

        XCTAssertTrue(scene.satisfiesArchitectureTree)
        XCTAssertEqual(scene.surface, .you)
        XCTAssertEqual(scene.productObject, "User System Profile")
        XCTAssertEqual(scene.sourceTrustLineOrder, ["profile", "permissions", "privacy", "history", "receipt"])
        XCTAssertTrue(scene.trustSummary.localizedCaseInsensitiveContains("local"))
        XCTAssertFalse(scene.firstViewportStructure.localizedCaseInsensitiveContains("dashboard"))
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
