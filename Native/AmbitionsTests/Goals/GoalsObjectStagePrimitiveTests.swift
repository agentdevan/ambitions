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
        XCTAssertTrue(stageSource.contains(".background(atlasObjectTexture)"))
        XCTAssertTrue(stageSource.contains(".overlay(alignment: .leading)"))
        XCTAssertFalse(stageSource.contains("RoundedRectangle("))
        XCTAssertFalse(stageSource.contains("Capsule(style: .continuous)"))
        XCTAssertFalse(stageSource.contains("HeroCard("))
        XCTAssertFalse(stageSource.contains("AppCard("))
        XCTAssertFalse(stageSource.contains("StateDrivenMaterialPanel("))
        XCTAssertFalse(stageSource.contains("placeholder card"))
        XCTAssertFalse(stageSource.localizedCaseInsensitiveContains("astrology"))
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
