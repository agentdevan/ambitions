import XCTest
@testable import Ambitions

final class GoalsObjectStagePrimitiveTests: XCTestCase {
    func testAMB575GoalsObjectStagePrimitiveContractReplacesAtlasLensContainers() throws {
        let contract = GoalsObjectStagePrimitiveContract.current
        let stageSource = try goalsStageSource()

        XCTAssertEqual(contract.primitiveID, "goals-object-stage")
        XCTAssertEqual(contract.ownerSurface, "Goals")
        XCTAssertEqual(contract.productObject, "Direction Atlas")
        XCTAssertEqual(contract.stageName, "Constellation Atlas")
        XCTAssertEqual(contract.screenshotIdentifier, "GoalsObjectStage")
        XCTAssertTrue(contract.avoidsGenericGoalRootOutput)
        XCTAssertTrue(contract.reservesTabBarClearance)
        XCTAssertEqual(contract.sourceTrustLineOrder, ["life area", "source", "proof", "receipt", "Today link"])
        XCTAssertTrue(contract.replacesFirstViewportStructures.contains("rounded Constellation Atlas container"))
        XCTAssertTrue(contract.replacesFirstViewportStructures.contains("rounded Orbital Lens container"))
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Dynamic Type") })
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Differentiate Without Color") })
        XCTAssertTrue(stageSource.contains("GoalsObjectStagePrimitiveContract"))
        XCTAssertTrue(stageSource.contains("atlasRelationshipField"))
        XCTAssertTrue(stageSource.contains("equalWeightLifeAreaGridColumns"))
        XCTAssertTrue(stageSource.contains("atlasLaneGridColumns"))
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
        let modelSource = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Features/Goals/GoalsFeatureModels.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(modelSource.contains("var constellationAtlasFirstViewportTrustSummary: String"))
        XCTAssertTrue(modelSource.contains("var constellationAtlasSourceFirstViewportSummary: String"))
        XCTAssertTrue(modelSource.contains("var constellationAtlasProofFirstViewportSummary: String"))
        XCTAssertTrue(modelSource.contains("\"Source, proof, replay trace, Today link, and You stay visible.\""))
        XCTAssertTrue(modelSource.contains("\"Replay trace and Today link visible.\""))
        XCTAssertTrue(modelSource.contains("\"Proof receipt visible.\""))
        XCTAssertTrue(stageSource.contains("detail: overview.constellationAtlasSourceFirstViewportSummary"))
        XCTAssertTrue(stageSource.contains("? overview.constellationAtlasProofFirstViewportSummary"))
        XCTAssertTrue(stageSource.contains("Text(overview.constellationAtlasFirstViewportTrustSummary)"))
        XCTAssertFalse(stageSource.contains("detail: overview.constellationAtlasCompactInspectionSummary"))
        XCTAssertFalse(stageSource.contains("proof?.latestTitle ?? proof?.detail"))
    }

    func testAMB575GoalsScreenReservesBottomChromeClearanceForObjectStageProof() throws {
        let source = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Features/Goals/GoalsScreen.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains(".safeAreaInset(edge: .bottom"))
        XCTAssertTrue(source.contains("theme.spacing.xxxl + theme.spacing.xxl"))
        XCTAssertTrue(source.contains(".overlay(alignment: .bottom)"))
    }

    func testAMB575PrimitiveRegistryIncludesGoalsObjectStageEntry() throws {
        let registry = try String(
            contentsOf: repoRoot().appendingPathComponent("docs/codex/ambitions_primitive_invention_registry.md"),
            encoding: .utf8
        )

        XCTAssertTrue(registry.contains("| goals-object-stage | Promoted | Goals | Direction Atlas / Constellation Atlas | AMB-575 |"))
        XCTAssertTrue(registry.contains("### goals-object-stage"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/object-stage/AMB-575-goals-object-stage.md"))
    }

    private func goalsStageSource() throws -> String {
        let source = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Features/Goals/GoalComponents.swift"),
            encoding: .utf8
        )
        guard let stageStart = source.range(of: "struct GoalsConstellationAtlasStage: View"),
              let stageEnd = source.range(of: "struct GoalMissionControlLanes: View") else {
            XCTFail("Unable to locate GoalsConstellationAtlasStage source boundaries.")
            return source
        }
        return String(source[stageStart.lowerBound..<stageEnd.lowerBound])
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
