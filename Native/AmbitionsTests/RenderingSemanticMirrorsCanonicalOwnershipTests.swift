@testable import Ambitions
import XCTest

final class RenderingSemanticMirrorsCanonicalOwnershipTests: XCTestCase {
    func testCanonicalSemanticMirrorFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Rendering/SemanticMirrors/MeridianSemanticModel.swift",
            "Native/Ambitions/Rendering/SemanticMirrors/ConstellationSemanticModel.swift",
            "Native/Ambitions/Rendering/SemanticMirrors/LifeShapeSemanticModel.swift",
            "Native/Ambitions/Rendering/SemanticMirrors/MotionSemanticModel.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical Rendering/SemanticMirrors owner: \(requiredPath)"
            )
        }
    }

    func testStageScenesUseCanonicalSemanticMirrors() {
        let goals = GoalsLens.makeStageScene(for: PreviewGoalsScenarios.overview)
        let timeContract = TimeObjectStagePrimitiveContract.current
        let time = TimeStageScene(
            surface: .time,
            productObject: timeContract.productObject,
            stageName: timeContract.stageName,
            firstViewportStructure: timeContract.firstViewportStructure,
            sourceTrustLineOrder: timeContract.sourceTrustLineOrder,
            currentDateSummary: "Today",
            capacitySummary: "Capacity is steady",
            protectedWindowSummary: "Protected windows are visible",
            pressureSummary: "Pressure is reviewable",
            horizonSummary: "Day, week, month, and year stay inside Time.",
            captureSupportSummary: "Capture routes through the global composer.",
            accessibilityFallbacks: timeContract.accessibilityFallbacks
        )

        XCTAssertTrue(goals.semanticMirror.provesInspectableRelationships)
        XCTAssertTrue(time.semanticMirror.provesTimeObjectSemantics)
        XCTAssertEqual(goals.semanticMirror.stageName, "Life Area Atlas")
        XCTAssertEqual(time.semanticMirror.stageName, "LifeShape Field")
    }

    func testStageMotionAccessibilityCarriesSemanticMirror() {
        let layer = StageMotionLayer.current(
            projection: MotionCurrentProjection.fixture,
            reduceMotionEnabled: true
        )

        XCTAssertTrue(layer.accessibilityPlan.semanticMirror.provesBehaviorNotDestination)
        XCTAssertTrue(layer.accessibilityPlan.semanticMirror.hasRequiredBehaviorConsequences)
        XCTAssertTrue(layer.accessibilityPlan.value.contains(layer.accessibilityPlan.semanticMirror.changeStateSummary))
        XCTAssertTrue(layer.accessibilityPlan.value.contains("Completion keeps saved history visible."))
        XCTAssertTrue(layer.accessibilityPlan.value.contains("Protected boundary names consent before cross-surface change."))
    }
}

private extension RenderingSemanticMirrorsCanonicalOwnershipTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Rendering/SemanticMirrors")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
