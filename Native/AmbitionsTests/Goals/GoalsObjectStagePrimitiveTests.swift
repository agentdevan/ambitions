import XCTest
@testable import Ambitions

final class GoalsObjectStagePrimitiveTests: XCTestCase {
    func testAMB575GoalsObjectStagePrimitiveContractReplacesAtlasLensContainers() throws {
        let contract = GoalsObjectStagePrimitiveContract.current
        let stageSource = try goalsStageSource()

        XCTAssertEqual(contract.primitiveID, "goals-object-stage")
        XCTAssertEqual(contract.ownerSurface, "Goals")
        XCTAssertEqual(contract.productObject, "Constellation Atlas + Orbital Lens")
        XCTAssertEqual(contract.stageName, "Constellation Atlas")
        XCTAssertEqual(contract.screenshotIdentifier, "GoalsObjectStage")
        XCTAssertTrue(contract.avoidsGenericGoalRootOutput)
        XCTAssertTrue(contract.reservesTabBarClearance)
        XCTAssertEqual(contract.sourceTrustLineOrder, ["life area", "source", "proof", "receipt", "Today link"])
        XCTAssertTrue(contract.replacesFirstViewportStructures.contains("rounded Constellation Atlas container"))
        XCTAssertTrue(contract.replacesFirstViewportStructures.contains("rounded Orbital Lens container"))
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Dynamic Type") })
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Differentiate Without Color") })
        XCTAssertTrue(stageSource.contains("GoalsLens.makeStageScene(for: overview)"))
        XCTAssertTrue(try goalsLensSource().contains("static let objectStageContract"))
        XCTAssertTrue(stageSource.contains("atlasRelationshipField"))
        XCTAssertTrue(stageSource.contains("equalWeightLifeAreaGridColumns"))
        XCTAssertTrue(stageSource.contains("laneStates.prefix(2)"))
        XCTAssertTrue(stageSource.contains("goals.atlas.inline-trust-depth"))
        XCTAssertTrue(stageSource.contains("atlasLane(lane, isCompact: true)"))
        XCTAssertTrue(stageSource.contains("constellationAtlasFirstViewportTrustSummary"))
        XCTAssertTrue(stageSource.contains("atlasRelationshipTitleLabel(for: item)"))
        XCTAssertTrue(stageSource.contains("atlasRelationshipTraceLabel(for: item)"))
        XCTAssertTrue(stageSource.contains(".lineLimit(3)"))
        XCTAssertTrue(stageSource.contains(".fixedSize(horizontal: false, vertical: true)"))
        XCTAssertTrue(stageSource.contains(".background(atlasObjectTexture)"))
        XCTAssertTrue(stageSource.contains(".overlay(alignment: .leading)"))
        XCTAssertFalse(stageSource.contains("ScrollView(.horizontal, showsIndicators: false)"))
        XCTAssertFalse(stageSource.contains("RoundedRectangle("))
        XCTAssertFalse(stageSource.contains("Capsule(style: .continuous)"))
        XCTAssertFalse(stageSource.contains("HeroCard("))
        XCTAssertFalse(stageSource.contains("AppCard("))
        XCTAssertFalse(stageSource.contains("StateDrivenMaterialPanel("))
        XCTAssertFalse(stageSource.contains("placeholder card"))
        XCTAssertFalse(stageSource.localizedCaseInsensitiveContains("astrology"))
    }

    func testAMB596GoalsFirstViewportTrustDepthUsesVisibleNonTruncatingSummary() throws {
        let stageSource = try goalsStageSource()
        let modelSource = try goalsFeatureModelsSource()

        XCTAssertTrue(modelSource.contains("var constellationAtlasFirstViewportTrustSummary: String"))
        XCTAssertTrue(modelSource.contains("var constellationAtlasSourceFirstViewportSummary: String"))
        XCTAssertTrue(modelSource.contains("var constellationAtlasProofFirstViewportSummary: String"))
        XCTAssertTrue(modelSource.contains("\"Source, proof, reason, Today link, and You stay visible.\""))
        XCTAssertTrue(modelSource.contains("\"Reason and Today link visible.\""))
        XCTAssertTrue(modelSource.contains("\"Proof receipt visible.\""))
        XCTAssertTrue(stageSource.contains("detail: overview.constellationAtlasSourceFirstViewportSummary"))
        XCTAssertTrue(stageSource.contains("? overview.constellationAtlasProofFirstViewportSummary"))
        XCTAssertTrue(stageSource.contains("Text(overview.constellationAtlasFirstViewportTrustSummary)"))
        XCTAssertTrue(stageSource.contains("dynamicTypeSize >= .xxLarge"))
        XCTAssertTrue(stageSource.contains("atlasObjectDetails"))
        XCTAssertTrue(stageSource.contains(".padding(.leading, theme.spacing.md)"))
        XCTAssertFalse(stageSource.contains("detail: overview.constellationAtlasCompactInspectionSummary"))
        XCTAssertFalse(stageSource.contains("proof?.latestTitle ?? proof?.detail"))
    }

    func testAMB575GoalsSurfaceReservesBottomChromeClearanceForObjectStageProof() throws {
        let source = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Surfaces/Goals/GoalsSurface.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains(".safeAreaInset(edge: .bottom"))
        XCTAssertTrue(source.contains("theme.spacing.xxxl"))
        XCTAssertTrue(source.contains(".allowsHitTesting(false)"))
    }

    func testAMB575ArchitectureTreeIncludesGoalsObjectStageEntry() throws {
        let goalsLensSource = try goalsLensSource()
        let stageSceneSource = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Projection/StageScenes/GoalsStageScene.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(goalsLensSource.contains("static let objectStageContract"))
        XCTAssertTrue(goalsLensSource.contains("GoalsStageScene("))
        XCTAssertTrue(stageSceneSource.contains("struct GoalsStageScene: Equatable, Sendable"))
        XCTAssertTrue(stageSceneSource.contains("productObject.localizedCaseInsensitiveContains(\"Constellation Atlas\")"))
        XCTAssertTrue(stageSceneSource.contains("firstViewportStructure.localizedCaseInsensitiveContains(\"life-area\")"))
        XCTAssertTrue(stageSceneSource.contains("sourceTrustLineOrder == [\"life area\", \"source\", \"proof\", \"receipt\", \"Today link\"]"))
        XCTAssertTrue(stageSceneSource.contains("todayRelationshipSummary.localizedCaseInsensitiveContains(\"Today\")"))
        XCTAssertTrue(stageSceneSource.contains("inspectionSummary.localizedCaseInsensitiveContains(\"proof\")"))
    }

    func goalsStageSource() throws -> String {
        let root = repoRoot()
        let sourcePaths = [
            "Native/Ambitions/DesignSystem/ProductObjects/ConstellationAtlasView.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/ConstellationAtlasView+02-overview.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/ConstellationAtlasView+03-atlasRelationshipField.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/ConstellationAtlasView+04-atlasRelationshipTraceLabel.swift"
        ]
        let source = try sourcePaths.map {
            try String(contentsOf: root.appendingPathComponent($0), encoding: .utf8)
        }.joined(separator: "\n")
        guard let stageStart = source.range(of: "struct ConstellationAtlasView: View") else {
            XCTFail("Unable to locate ConstellationAtlasView source boundary.")
            return source
        }
        return String(source[stageStart.lowerBound...])
    }

    func goalsLensSource() throws -> String {
        try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Projection/SurfaceLenses/GoalsLens.swift"),
            encoding: .utf8
        )
    }

    func goalsFeatureModelsSource() throws -> String {
        let root = repoRoot()
        let sourcePaths = [
            "Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureModels.swift",
            "Native/Ambitions/Projection/SurfaceLenses/GoalsFeatureModels+03-GoalsOverview.swift"
        ]
        return try sourcePaths.map {
            try String(contentsOf: root.appendingPathComponent($0), encoding: .utf8)
        }.joined(separator: "\n")
    }

    func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
