import XCTest
@testable import Ambitions

final class OverlayScenesCanonicalOwnershipTests: XCTestCase {
    func testRequiredOverlaySceneFilesExistAtFeatureLocalPaths() throws {
        let root = repoRoot()
        let required = [
            "Native/Ambitions/Composer/Capture/Projection/CaptureStageScene.swift",
            "Native/Ambitions/Stage/Overlays/Projection/SearchStageScene.swift",
            "Native/Ambitions/Stage/Overlays/Projection/ClosureStageScene.swift",
            "Native/Ambitions/Trust/Projection/InspectionStageScene.swift"
        ]

        for path in required {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
        XCTAssertEqual(try swiftFiles(under: root.appendingPathComponent("Native/Ambitions/Projection/OverlayScenes")), [])
    }

    func testOverlaySceneContractsOwnShellBehavior() {
        let contracts = [
            CaptureStageScene.contract,
            SearchStageScene.contract,
            ClosureStageScene.contract,
            InspectionStageScene.contract
        ]

        XCTAssertEqual(contracts.map(\.kind), [.capture, .search, .closure, .inspection])
        XCTAssertEqual(
            contracts.map(\.ownerLayer),
            ["Composer/Capture/Projection", "Stage/Overlays/Projection", "Stage/Overlays/Projection", "Trust/Projection"]
        )
        for contract in contracts {
            XCTAssertTrue(contract.satisfiesFinalCanon, contract.kind.rawValue)
            XCTAssertTrue(contract.routeBoundary.localizedCaseInsensitiveContains("overlay"))
            XCTAssertTrue(contract.motionBehavior.localizedCaseInsensitiveContains("Stage/Motion"))
        }
    }

    func testOverlayScenesProjectLensReportsIntoVisibleStageContracts() {
        let reports = [
            CaptureLens.project(captureReview()),
            SearchLens.project(PreviewFixtures.default.youDashboard.everythingSearch),
            ClosureLens.project(closureReview()),
            InspectionLens.project(ActionReceiptHistoryProjection(records: []).search())
        ]
        let scenes = [
            CaptureStageScene.project(reports[0]),
            SearchStageScene.project(reports[1]),
            ClosureStageScene.project(reports[2]),
            InspectionStageScene.project(reports[3])
        ]

        XCTAssertEqual(scenes.map(\.contract.kind), [.capture, .search, .closure, .inspection])
        for scene in scenes {
            XCTAssertTrue(scene.isProductionReady, scene.contract.kind.rawValue)
            XCTAssertTrue(scene.contract.dockBehavior.localizedCaseInsensitiveContains("root dock"))
            XCTAssertTrue(scene.trustSummary.localizedCaseInsensitiveContains("local"))
        }
    }

    private func captureReview() -> CapturePlacementReviewState {
        Capture(
            id: "capture-overlay-scene",
            createdAt: "2026-06-20T12:00:00Z",
            updatedAt: "2026-06-20T12:00:00Z",
            rawText: "Ask Jordan about Saturday logistics",
            sourceType: .shellComposer,
            status: .needsTriage,
            linkedGoalID: nil,
            triage: CaptureTriageMetadata(destination: .attachToGoal)
        ).placementReviewState
    }

    private func closureReview() -> TodayActionClosureSheetState {
        TodayActionClosureSheetState.step(
            title: "Send the update",
            context: "Today",
            target: TodayActionTarget(goalID: "goal", stepID: "step")
        )
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
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
}
