import XCTest
@testable import AmbitionsNativeVisualFoundry

final class GoalsNativeCalibrationFixtureTests: XCTestCase {
    private let content = GoalsNativeCalibrationFixture.preparingForBaby

    func testFixturePreservesExactLivingPursuitIdentityAndTruth() {
        XCTAssertEqual(content.familyID, "goals-flagship/home/welcome-baby-home/v1")
        XCTAssertTrue(content.isSynthetic)
        XCTAssertEqual(content.selectedLifeAreaID, "life-area.home")
        XCTAssertEqual(content.selectedGoalID, "goal.welcome-baby-home")

        XCTAssertEqual(content.primaryGoal.title, "Welcome our baby home")
        XCTAssertEqual(content.primaryGoal.lifeAreaTitle, "Home")
        XCTAssertEqual(
            content.primaryGoal.currentDirection,
            "Make the home ready for the baby without consuming the time and energy the family needs now."
        )
        XCTAssertEqual(
            content.primaryGoal.currentAcceptedTruth,
            "The wall is primed, the color is confirmed, and the crib corner is clear."
        )
        XCTAssertEqual(content.primaryGoal.activeThread, "Finish the nursery.")
        XCTAssertEqual(content.primaryGoal.nextMeaningfulMovement, "Paint the nursery wall.")
        XCTAssertEqual(content.primaryGoal.followingMovement, "Assemble the crib.")
        XCTAssertEqual(
            content.primaryGoal.materialConsequence,
            "Finishing the room now reduces last-minute setup while protecting family time."
        )
        XCTAssertEqual(
            content.primaryGoal.scheduleFit,
            "The next movement currently fits before protected family time."
        )
    }

    func testFixtureHasOneExpandedLifeAreaAndEqualCompactPeers() throws {
        XCTAssertEqual(content.lifeAreas.map(\.id), [
            "life-area.home",
            "life-area.relationships",
            "life-area.career"
        ])
        XCTAssertEqual(
            content.lifeAreas.filter { $0.id == content.selectedLifeAreaID }.count,
            1
        )

        let home = try XCTUnwrap(content.lifeAreas.first { $0.id == "life-area.home" })
        XCTAssertEqual(home.goals.map(\.id), [
            "goal.welcome-baby-home",
            "goal.make-home-easier-to-run",
            "goal.finish-essential-move-in-work"
        ])
        XCTAssertNil(content.lifeAreas.first { $0.id == "life-area.relationships" }?.rank)
        XCTAssertNil(content.lifeAreas.first { $0.id == "life-area.career" }?.rank)
    }

    func testLinkedLensIsAttachedAndIntentionallyBounded() {
        XCTAssertEqual(content.linkedLens.goalID, content.primaryGoal.id)
        XCTAssertEqual(content.linkedLens.currentTruth, content.primaryGoal.currentAcceptedTruth)
        XCTAssertEqual(content.linkedLens.activeThread, "Finish the nursery.")
        XCTAssertEqual(content.linkedLens.nextMovement, "Paint the nursery wall.")
        XCTAssertEqual(content.linkedLens.proofPosture, [
            "Crib corner cleared",
            "Paint color confirmed",
            "Wall primed"
        ])
        XCTAssertEqual(content.linkedLens.openActionTitle, "Open Goal")
    }

    func testRelationshipAndPathKeepExactStableIdentities() {
        XCTAssertEqual(content.relationship.primaryGoalID, "goal.welcome-baby-home")
        XCTAssertEqual(content.relationship.relatedGoalID, "goal.protect-first-weeks-together")
        XCTAssertEqual(content.relationship.ownerLifeAreaID, "life-area.home")
        XCTAssertEqual(content.relationship.relatedLifeAreaID, "life-area.relationships")
        XCTAssertEqual(
            content.relationship.meaning,
            "A ready nursery lowers pressure during the first days at home."
        )
        XCTAssertEqual(
            content.relationship.practicalConsequence,
            "Home setup should support the family’s first-week plan rather than consume it."
        )

        XCTAssertEqual(content.goalPath.id, "goalpath.welcome-baby-home.v1")
        XCTAssertEqual(content.goalPath.nodes.count, 8)
        XCTAssertEqual(content.goalPath.nodes.map(\.id), [
            "pathnode.define-ready",
            "pathnode.clear-crib-corner",
            "pathnode.prime-wall-color",
            "pathnode.paint-wall",
            "pathnode.assemble-crib",
            "pathnode.changing-station",
            "pathnode.final-furniture",
            "pathnode.nursery-ready"
        ])
        XCTAssertEqual(content.goalPath.currentNodeID, "pathnode.paint-wall")
        XCTAssertEqual(content.goalPath.nextNodeID, "pathnode.assemble-crib")
    }

    func testVisibleFixtureContentDoesNotLeakTodayOrGamificationGrammar() {
        let visibleText = content.visibleEvaluationText.joined(separator: " ")
        for prohibited in [
            "Start Here",
            "Later Today",
            "View Full Day",
            "Still Counts",
            "Receipt",
            "rank",
            "%",
            "score"
        ] {
            XCTAssertFalse(visibleText.localizedCaseInsensitiveContains(prohibited))
        }
    }
}
