import XCTest
@testable import AmbitionsNativeVisualFoundry

final class GoalsNativeCalibrationPathTests: XCTestCase {
    private let content = GoalsNativeCalibrationFixture.preparingForBaby

    func testPathPreservesExactFixtureOrderAndPostures() {
        XCTAssertEqual(content.goalPath.id, "goalpath.welcome-baby-home.v1")
        XCTAssertEqual(
            content.goalPath.nodes.map(\.id),
            [
                "pathnode.define-ready",
                "pathnode.clear-crib-corner",
                "pathnode.prime-wall-color",
                "pathnode.paint-wall",
                "pathnode.assemble-crib",
                "pathnode.changing-station",
                "pathnode.final-furniture",
                "pathnode.nursery-ready"
            ]
        )
        XCTAssertEqual(
            content.goalPath.nodes.map(\.state),
            [.completed, .completed, .settled, .current, .next, .planned, .conditional, .finish]
        )
    }

    func testOpeningPathAnchorsTheCurrentNodeAndBackRestoresGoalThenLens() {
        var state = GoalsNativeCalibrationJourneyState(content: content, lensExpanded: true)
        XCTAssertTrue(state.openLifeArea(id: "life-area.home"))
        XCTAssertTrue(state.openSelectedGoal())

        XCTAssertTrue(state.openGoalPath())
        XCTAssertEqual(state.selectedPathNodeID, "pathnode.paint-wall")
        XCTAssertEqual(state.focusAnchor, .pathNode)

        state.reconcileNavigationPath([
            .lifeArea(id: "life-area.home"),
            .focusedGoal(id: "goal.welcome-baby-home")
        ])
        XCTAssertEqual(state.focusAnchor, .currentMovement)
        state.reconcileNavigationPath([.lifeArea(id: "life-area.home")])
        XCTAssertEqual(state.selectedLifeAreaID, "life-area.home")
        XCTAssertEqual(state.selectedGoalID, "goal.welcome-baby-home")
        XCTAssertEqual(state.focusAnchor, .selectedGoal)
    }

    func testPathJumpControlsSelectExactFixtureNodesWithoutMutation() {
        var state = GoalsNativeCalibrationJourneyState(content: content, lensExpanded: true)
        let canonicalContent = content
        XCTAssertTrue(state.openLifeArea(id: "life-area.home"))
        XCTAssertTrue(state.openSelectedGoal())
        XCTAssertTrue(state.openGoalPath())

        let expected: [(GoalsNativeCalibrationPathJump, String)] = [
            (.start, "pathnode.define-ready"),
            (.now, "pathnode.paint-wall"),
            (.next, "pathnode.assemble-crib"),
            (.finish, "pathnode.nursery-ready")
        ]

        for (jump, nodeID) in expected {
            XCTAssertTrue(state.jumpTo(jump))
            XCTAssertEqual(state.selectedPathNodeID, nodeID)
            XCTAssertEqual(state.focusAnchor, .pathNode)
        }

        XCTAssertFalse(state.hasMutation)
        XCTAssertEqual(content, canonicalContent)
    }

    func testPathPresentationKeepsOrderedSemanticsProofAndNativeJumpLabels() {
        let presentation = GoalsNativeCalibrationPathPresentation(content: content)

        XCTAssertEqual(presentation.goalID, "goal.welcome-baby-home")
        XCTAssertEqual(presentation.goalTitle, "Welcome our baby home")
        XCTAssertEqual(presentation.lifeAreaTitle, "Home")
        XCTAssertEqual(presentation.currentNodeID, "pathnode.paint-wall")
        XCTAssertEqual(presentation.nextNodeID, "pathnode.assemble-crib")
        XCTAssertEqual(presentation.nodes.count, 8)
        XCTAssertEqual(presentation.jumpTitles, ["Start", "Now", "Next", "Finish"])
        XCTAssertEqual(
            presentation.nodes[1].proof,
            ["Crib corner cleared"]
        )
        XCTAssertEqual(
            presentation.nodes[2].proof,
            ["Paint color confirmed", "Wall primed"]
        )
        XCTAssertEqual(
            presentation.recordedProofMoments,
            ["Crib corner cleared", "Paint color confirmed", "Wall primed"]
        )
        XCTAssertTrue(
            presentation.visibleText.allSatisfy { text in
                ["percent", "score", "rank", "level", "streak", "Start Here", "Later Today"]
                    .allSatisfy { forbidden in
                        text.localizedCaseInsensitiveContains(forbidden) == false
                    }
            }
        )
    }
}
