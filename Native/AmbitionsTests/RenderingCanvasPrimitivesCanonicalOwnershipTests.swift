@testable import Ambitions
import AmbitionsDesignSystem
import CoreGraphics
import XCTest

final class RenderingCanvasPrimitivesCanonicalOwnershipTests: XCTestCase {
    func testCanonicalCanvasPrimitiveFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Rendering/CanvasPrimitives/MeridianRenderer.swift",
            "Native/Ambitions/Rendering/CanvasPrimitives/ConstellationRenderer.swift",
            "Native/Ambitions/Rendering/CanvasPrimitives/LifeShapeRenderer.swift",
            "Native/Ambitions/Rendering/CanvasPrimitives/MotionCurrentRenderer.swift",
            "Native/Ambitions/Rendering/CanvasPrimitives/MorphGeometry.swift",
            "Native/Ambitions/Rendering/CanvasPrimitives/RenderPerformanceProbe.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical Rendering/CanvasPrimitives owner: \(requiredPath)"
            )
        }
    }

    func testSemanticMirrorsUseCanonicalCanvasRenderPlans() {
        let goals = GoalsLens.makeStageScene(for: PreviewGoalsScenarios.overview)
        let time = TimeStageScene(
            surface: .time,
            productObject: UserFacingLanguage.Object.lifeShapeField,
            stageName: UserFacingLanguage.Object.lifeShapeField,
            firstViewportStructure: "capacity, protected windows, pressure",
            sourceTrustLineOrder: ["current date", "now marker", "fixed points", "capacity", "protected windows", "pressure", "horizon", "Capture"],
            currentDateSummary: "Today",
            capacitySummary: "Capacity is steady",
            protectedWindowSummary: "Protected windows are visible",
            pressureSummary: "Pressure is reviewable",
            horizonSummary: "Day, week, month, and year stay inside Time.",
            captureSupportSummary: "Capture routes through the global composer.",
            accessibilityFallbacks: ["Reduce Motion", "Dynamic Type"]
        )
        let today = TodayStageScene(execution: PreviewTodayScenarios.empty.execution, generatedAt: Date(timeIntervalSince1970: 1_800))

        XCTAssertEqual(goals.semanticMirror.renderPlan.objectRole, .constellation)
        XCTAssertEqual(goals.semanticMirror.renderPlan.engineRole, .goalsRelationship)
        XCTAssertTrue(goals.semanticMirror.renderPlan.performanceReport.isWithinBudget)

        XCTAssertEqual(time.semanticMirror.renderPlan.objectRole, .lifeShape)
        XCTAssertEqual(time.semanticMirror.renderPlan.engineRole, .timePressure)
        XCTAssertTrue(time.semanticMirror.renderPlan.performanceReport.isWithinBudget)

        XCTAssertEqual(today.meridian.renderPlan.objectRole, .meridian)
        XCTAssertEqual(today.meridian.renderPlan.engineRole, .timePressure)
        XCTAssertTrue(today.meridian.renderPlan.performanceReport.isWithinBudget)
    }

    func testRenderPerformanceProbeRejectsOverBudgetPlans() {
        let plan = CanvasPrimitiveRenderPlan(
            id: "over-budget-test-plan",
            objectRole: .meridian,
            engineRole: .timePressure,
            marks: (0..<8).map { ProductMeaningCanvasMark(id: "mark-\($0)", intensity: 1) },
            visualState: .selected,
            geometry: MorphGeometry.meridian(mode: .overloaded, semanticElementCount: 8),
            accessibilitySummary: "Reality Meridian",
            performanceBudget: RenderPerformanceProbe.budget(for: .meridian)
        )

        XCTAssertFalse(plan.performanceReport.isWithinBudget)
        XCTAssertEqual(plan.performanceReport.markCount, 8)
        XCTAssertTrue(plan.performanceReport.semanticMirrorPresent)
    }

    func testMorphGeometryProducesDeterministicBoundedPoints() {
        let geometry = MorphGeometry.constellation(relationshipCount: 5, hasProof: true)
        let first = geometry.point(in: CGSize(width: 320, height: 240), at: 0.50)
        let second = geometry.point(in: CGSize(width: 320, height: 240), at: 0.50)
        let clamped = geometry.point(in: CGSize(width: 320, height: 240), at: 2.0)

        XCTAssertEqual(first, second)
        XCTAssertGreaterThanOrEqual(first.x, 0)
        XCTAssertLessThanOrEqual(first.x, 320)
        XCTAssertGreaterThanOrEqual(first.y, 0)
        XCTAssertLessThanOrEqual(first.y, 240)
        XCTAssertEqual(clamped, geometry.point(in: CGSize(width: 320, height: 240), at: 1.0))
    }

    func testProductObjectCanvasCallSitesRemainBackedBySharedEngine() throws {
        let root = repoRoot()
        let goalsSource = try source("Native/Ambitions/DesignSystem/ProductObjects/ConstellationAtlasView+02-overview.swift", root: root)
        let timeSource = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldCanvas.swift", root: root)
        let motionSource = try source("Native/Ambitions/Rendering/CanvasPrimitives/MotionCurrentRenderer.swift", root: root)

        XCTAssertTrue(goalsSource.contains("ProductMeaningCanvasEngine("))
        XCTAssertTrue(goalsSource.contains("role: .goalsRelationship"))
        XCTAssertTrue(timeSource.contains("ProductMeaningCanvasEngine("))
        XCTAssertTrue(timeSource.contains("role: .timePressure"))
        XCTAssertTrue(motionSource.contains("ProductMeaningCanvasEngine("))
        XCTAssertTrue(motionSource.contains("role: .motionProofThread"))
    }
}

private extension RenderingCanvasPrimitivesCanonicalOwnershipTests {
    func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Rendering/CanvasPrimitives")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
