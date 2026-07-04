import XCTest
@testable import Ambitions

final class StageScenesCanonicalOwnershipTests: XCTestCase {
    func testRequiredStageSceneFilesExistAtFeatureLocalPaths() throws {
        let root = repoRoot()
        let required = [
            "Native/Ambitions/Surfaces/Today/Projection/TodayStageScene.swift",
            "Native/Ambitions/Surfaces/Goals/Projection/GoalsStageScene.swift",
            "Native/Ambitions/Surfaces/Time/Projection/TimeStageScene.swift",
            "Native/Ambitions/Surfaces/You/Projection/YouStageScene.swift"
        ]

        for path in required {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }

        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Surfaces/Today/Projection/TodayStageProjection.swift").path))
        XCTAssertEqual(try swiftFiles(under: root.appendingPathComponent("Native/Ambitions/Projection/StageScenes")), [])
    }

    func testStageSceneSourcesStayLimitedToCanonSurfaceOwners() throws {
        let root = repoRoot()
        let today = try source("Native/Ambitions/Surfaces/Today/Projection/TodayStageScene.swift", root: root)
        let goals = try source("Native/Ambitions/Surfaces/Goals/Projection/GoalsStageScene.swift", root: root)
        let time = try source("Native/Ambitions/Surfaces/Time/Projection/TimeStageScene.swift", root: root)
        let you = try source("Native/Ambitions/Surfaces/You/Projection/YouStageScene.swift", root: root)
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

    private func swiftFiles(under root: URL) throws -> [String] {
        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return try enumerator.compactMap { item in
            guard let url = item as? URL else { return nil }
            let values = try url.resourceValues(forKeys: [.isRegularFileKey])
            return values.isRegularFile == true && url.pathExtension == "swift" ? url.lastPathComponent : nil
        }.sorted()
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
