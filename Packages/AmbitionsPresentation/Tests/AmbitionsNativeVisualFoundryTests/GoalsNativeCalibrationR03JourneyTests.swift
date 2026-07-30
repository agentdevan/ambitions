import XCTest
@testable import AmbitionsNativeVisualFoundry

final class GoalsNativeCalibrationR03JourneyTests: XCTestCase {
    private let content = GoalsNativeCalibrationFixture.preparingForBaby

    func testPathOpensAtCurrentAndJumpsWithoutMutation() {
        var state = focusedState()
        let originalContent = content

        XCTAssertTrue(state.openGoalPath())
        XCTAssertEqual(state.selectedPathNodeID, "pathnode.paint-wall")
        XCTAssertTrue(state.jumpTo(.start))
        XCTAssertEqual(state.selectedPathNodeID, "pathnode.define-ready")
        XCTAssertTrue(state.jumpTo(.now))
        XCTAssertEqual(state.selectedPathNodeID, "pathnode.paint-wall")
        XCTAssertTrue(state.jumpTo(.next))
        XCTAssertEqual(state.selectedPathNodeID, "pathnode.assemble-crib")
        XCTAssertTrue(state.jumpTo(.finish))
        XCTAssertEqual(state.selectedPathNodeID, "pathnode.nursery-ready")
        XCTAssertFalse(state.hasMutation)
        XCTAssertEqual(content, originalContent)
    }

    func testPathEvidenceReturnsToTheExactSelectedNode() {
        var state = focusedState()
        XCTAssertTrue(state.openGoalPath())
        XCTAssertTrue(state.selectPathNode(id: "pathnode.prime-wall-color"))
        XCTAssertTrue(state.openPathEvidence())

        XCTAssertEqual(state.focusAnchor, .pathEvidence)
        XCTAssertEqual(state.navigationPath.last, .pathEvidence(
            pathID: content.goalPath.id,
            nodeID: "pathnode.prime-wall-color"
        ))

        state.reconcileNavigationPath(Array(state.navigationPath.dropLast()))
        XCTAssertEqual(state.selectedPathNodeID, "pathnode.prime-wall-color")
        XCTAssertEqual(state.focusAnchor, .pathNode)
        XCTAssertFalse(state.hasMutation)
    }

    func testPathBackReturnsFocusToCurrentMovement() {
        var state = focusedState()
        XCTAssertTrue(state.openGoalPath())

        state.reconcileNavigationPath(Array(state.navigationPath.dropLast()))

        XCTAssertEqual(state.focusAnchor, .currentMovement)
        XCTAssertFalse(state.hasMutation)
    }

    func testRelationshipBackRestoresRelationshipEntry() {
        var state = focusedState()
        XCTAssertTrue(state.openRelationship())

        state.reconcileNavigationPath(Array(state.navigationPath.dropLast()))

        XCTAssertEqual(state.focusAnchor, .relationshipEntry)
        XCTAssertFalse(state.hasMutation)
    }

    func testRecoveryPathReturnsToInterruptedNodeAndKeepUnresolvedChangesNothing() {
        var state = focusedState()
        let originalContent = content
        XCTAssertTrue(state.openRecovery())
        XCTAssertTrue(state.openRecoveryPath())
        XCTAssertEqual(state.selectedPathNodeID, "pathnode.paint-wall")

        state.reconcileNavigationPath(Array(state.navigationPath.dropLast()))
        XCTAssertEqual(state.focusAnchor, .recoveryState)
        XCTAssertEqual(state.selectedPathNodeID, "pathnode.paint-wall")

        XCTAssertTrue(state.keepRecoveryUnresolved())
        XCTAssertEqual(state.focusAnchor, .recoveryEntry)
        XCTAssertEqual(
            state.navigationPath,
            [
                .lifeArea(id: "life-area.home"),
                .focusedGoal(id: "goal.welcome-baby-home")
            ]
        )
        XCTAssertFalse(state.hasMutation)
        XCTAssertEqual(content, originalContent)
    }

    func testInspectPossibleNextSelectsButDoesNotAcceptAlternative() {
        var state = focusedState()
        XCTAssertTrue(state.openRecovery())
        XCTAssertTrue(state.inspectPossibleNext())

        XCTAssertEqual(state.selectedPathNodeID, "pathnode.assemble-crib")
        XCTAssertEqual(state.focusAnchor, .pathNode)
        XCTAssertFalse(state.hasMutation)
        XCTAssertEqual(
            content.goalPath.currentNodeID,
            "pathnode.paint-wall",
            "Inspection must not accept the alternative as current truth"
        )
    }

    func testClosureHistoryReturnsToClosureWithoutAutoDismissal() {
        var state = focusedState()
        XCTAssertTrue(state.openClosure())
        XCTAssertEqual(state.focusAnchor, .closure)
        XCTAssertTrue(state.openClosureHistory())
        XCTAssertEqual(state.focusAnchor, .closureHistory)

        state.reconcileNavigationPath(Array(state.navigationPath.dropLast()))

        XCTAssertEqual(state.focusAnchor, .closure)
        XCTAssertEqual(state.navigationPath.last, .closure(id: content.closure.id))
        XCTAssertFalse(state.hasMutation)
    }

    private func focusedState() -> GoalsNativeCalibrationJourneyState {
        var state = GoalsNativeCalibrationJourneyState(content: content)
        XCTAssertTrue(state.openLifeArea(id: "life-area.home"))
        XCTAssertTrue(state.openSelectedGoal())
        return state
    }
}
