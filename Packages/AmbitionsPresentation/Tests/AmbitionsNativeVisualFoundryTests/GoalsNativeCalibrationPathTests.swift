import XCTest
@testable import AmbitionsNativeVisualFoundry

final class GoalsNativeCalibrationPathTests: XCTestCase {
    private let content = GoalsNativeCalibrationFixture.preparingForBaby

    func testPathPreservesExactFixtureOrderAndPostures() {
        XCTAssertEqual(content.goalPath.id, "goalpath.welcome-baby-home.v1")
        XCTAssertEqual(
            content.goalPath.nodes.map(\.id),
            [
                "goalpath-node.define-ready",
                "goalpath-node.clear-crib-corner",
                "goalpath-node.prime-wall",
                "goalpath-node.paint-wall",
                "goalpath-node.assemble-crib",
                "goalpath-node.changing-station",
                "goalpath-node.final-furniture",
                "goalpath-node.nursery-ready"
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
        XCTAssertEqual(state.selectedPathNodeID, "goalpath-node.paint-wall")
        XCTAssertEqual(state.focusAnchor, .pathNode)

        state.reconcileNavigationPath([
            .lifeArea(id: "life-area.home"),
            .focusedGoal(id: "goal.welcome-baby-home")
        ])
        XCTAssertEqual(state.focusAnchor, .focusedGoal)
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
            (.start, "goalpath-node.define-ready"),
            (.now, "goalpath-node.paint-wall"),
            (.next, "goalpath-node.assemble-crib"),
            (.finish, "goalpath-node.nursery-ready")
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
        XCTAssertEqual(presentation.currentNodeID, "goalpath-node.paint-wall")
        XCTAssertEqual(presentation.nextNodeID, "goalpath-node.assemble-crib")
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
