import AmbitionsDesignSystem
import Foundation
import XCTest

final class ProductMeaningCanvasEngineTests: XCTestCase {
    func testAMB583ProductMeaningCanvasEngineContract() {
        let contract = ProductMeaningCanvasEngineContract.current

        XCTAssertEqual(contract.primitiveID, "canvas-engines-static-fallbacks")
        XCTAssertEqual(contract.ownerSurfaces, ["Goals", "Time", "Motion"])
        XCTAssertEqual(contract.productObjects, [
            "Constellation Atlas relationship contour",
            "LifeShape pressure contour",
            "Motion proof-thread contour"
        ])
        XCTAssertEqual(contract.screenshotIdentifier, "ProductMeaningCanvasEngine")
        XCTAssertTrue(contract.reuseRequirement.contains("existing contour"))
        XCTAssertTrue(contract.fallbackRequirement.contains("Reduce Motion"))
        XCTAssertTrue(contract.fallbackRequirement.contains("Shape strokes"))
        XCTAssertTrue(contract.performanceNotes.contains("No TimelineView loop is introduced by this engine."))
        XCTAssertTrue(contract.performanceNotes.contains("Canvas layers are non-interactive and accessibility-hidden because adjacent text owns the semantic meaning."))
        XCTAssertTrue(ProductMeaningCanvasRole.goalsRelationship.fallbackSummary.contains("Static relationship curve"))
        XCTAssertTrue(ProductMeaningCanvasRole.timePressure.fallbackSummary.contains("Static pressure strokes"))
        XCTAssertTrue(ProductMeaningCanvasRole.motionProofThread.fallbackSummary.contains("Static proof thread"))
    }

    func testAMB583CanvasEngineSourceIncludesStaticFallbackAndNoTimelineLoop() throws {
        let source = try source("Sources/Components/ProductMeaningCanvasEngine.swift", root: repoRoot())

        XCTAssertTrue(source.contains("public struct ProductMeaningCanvasEngine: View"))
        XCTAssertTrue(source.contains("Canvas { context, size in"))
        XCTAssertTrue(source.contains("if reduceMotion"))
        XCTAssertTrue(source.contains("staticFallback(accent: accent)"))
        XCTAssertTrue(source.contains("ProductMeaningCanvasFallbackStroke: Shape"))
        XCTAssertTrue(source.contains("No TimelineView loop is introduced by this engine."))
        XCTAssertFalse(source.contains("TimelineView("))
    }

    func testAMB583ActiveSurfacesUseSharedCanvasEngine() throws {
        let root = repoRoot()
        let goalsSource = try source("Native/Ambitions/DesignSystem/ProductObjects/GoalComponents.swift", root: root)
        let timeSource = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift", root: root)
        let motionSource = try source("Native/Ambitions/Stage/Motion/StageMotionCurrentView.swift", root: root)

        XCTAssertTrue(goalsSource.contains("ProductMeaningCanvasEngine("))
        XCTAssertTrue(goalsSource.contains("role: .goalsRelationship"))
        XCTAssertTrue(goalsSource.contains("goals.constellation-atlas.relationship-canvas-engine"))
        XCTAssertFalse(goalsSource.contains("Canvas { context, size in"))

        XCTAssertTrue(timeSource.contains("ProductMeaningCanvasEngine("))
        XCTAssertTrue(timeSource.contains("role: .timePressure"))
        XCTAssertTrue(timeSource.contains("ProductMeaningCanvasMark(id: mark.id, intensity: mark.intensity)"))
        XCTAssertTrue(timeSource.contains("time.life-shape-field.pressure-canvas-engine"))
        XCTAssertFalse(timeSource.contains("Canvas { context, size in"))

        XCTAssertTrue(motionSource.contains("ProductMeaningCanvasEngine("))
        XCTAssertTrue(motionSource.contains("role: .motionProofThread"))
        XCTAssertTrue(motionSource.contains("motion.current.proof-thread-canvas-engine"))
        XCTAssertFalse(motionSource.contains("Canvas { context, size in"))
    }

    func testAMB583PrimitiveRegistryIncludesCanvasEngineEntry() throws {
        let registry = try source("docs/codex/ambitions_primitive_invention_registry.md", root: repoRoot())

        XCTAssertTrue(registry.contains("| canvas-engines-static-fallbacks | Promoted | Goals / Time / Motion | Canvas engines / static fallbacks | AMB-583 |"))
        XCTAssertTrue(registry.contains("### canvas-engines-static-fallbacks"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-583-canvas-engines-and-fallbacks.md"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/screenshots/canvas-engines-and-fallbacks-amb-583.png"))
    }

    func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
