import XCTest
@testable import AmbitionsNativeVisualFoundry

final class GoalsNativeCalibrationJourneyStateTests: XCTestCase {
    private let content = GoalsNativeCalibrationFixture.preparingForBaby

    func testInitialStateBeginsAtStrictLifeAreaRootWithoutMutation() {
        let state = GoalsNativeCalibrationJourneyState(content: content)

        XCTAssertEqual(state.selectedLifeAreaID, "life-area.home")
        XCTAssertEqual(state.selectedGoalID, "goal.welcome-baby-home")
        XCTAssertFalse(state.isLinkedLensExpanded)
        XCTAssertTrue(state.navigationPath.isEmpty)
        XCTAssertEqual(state.focusAnchor, .lifeArea)
        XCTAssertFalse(state.hasMutation)
    }

    func testOpeningHomeCreatesCanonicalLifeAreaDepth() {
        var state = GoalsNativeCalibrationJourneyState(content: content)

        XCTAssertTrue(state.openLifeArea(id: "life-area.home"))

        XCTAssertEqual(state.navigationPath, [.lifeArea(id: "life-area.home")])
        XCTAssertEqual(state.selectedLifeAreaID, "life-area.home")
        XCTAssertEqual(state.focusAnchor, .lifeArea)
        XCTAssertFalse(state.hasMutation)
    }

    func testOpeningGoalRequiresHomeAndPreservesCanonicalParentPath() {
        var state = GoalsNativeCalibrationJourneyState(content: content)
        let originalContent = content

        XCTAssertFalse(state.openSelectedGoal())
        XCTAssertTrue(state.openLifeArea(id: "life-area.home"))

        XCTAssertTrue(state.openSelectedGoal())
        XCTAssertEqual(
            state.navigationPath,
            [
                .lifeArea(id: "life-area.home"),
                .focusedGoal(id: "goal.welcome-baby-home")
            ]
        )
        XCTAssertEqual(state.focusAnchor, .focusedGoal)
        XCTAssertFalse(state.hasMutation)
        XCTAssertEqual(content, originalContent)
    }

    func testBackRestoresSelectedGoalThenHomeAtRoot() {
        var state = GoalsNativeCalibrationJourneyState(content: content)
        XCTAssertTrue(state.openLifeArea(id: "life-area.home"))
        XCTAssertTrue(state.openSelectedGoal())

        state.reconcileNavigationPath([.lifeArea(id: "life-area.home")])
        XCTAssertEqual(state.focusAnchor, .selectedGoal)
        XCTAssertEqual(state.selectedLifeAreaID, "life-area.home")
        XCTAssertEqual(state.selectedGoalID, "goal.welcome-baby-home")

        state.reconcileNavigationPath([])
        XCTAssertEqual(state.focusAnchor, .lifeArea)
        XCTAssertEqual(state.selectedLifeAreaID, "life-area.home")
        XCTAssertEqual(state.selectedGoalID, "goal.welcome-baby-home")
        XCTAssertFalse(state.hasMutation)
    }

    func testInvalidIdentitiesCannotCreateFixtureRoutes() {
        var state = GoalsNativeCalibrationJourneyState(content: content)

        XCTAssertFalse(state.openLifeArea(id: "life-area.unknown"))
        XCTAssertFalse(state.openSelectedGoal(id: "goal.unknown"))
        XCTAssertEqual(state.selectedLifeAreaID, "life-area.home")
        XCTAssertEqual(state.selectedGoalID, "goal.welcome-baby-home")
        XCTAssertTrue(state.navigationPath.isEmpty)
        XCTAssertFalse(state.hasMutation)
    }

    func testRelationshipInspectionIsNonMutatingAndBackRestoresFocusedGoalThenLens() {
        var state = GoalsNativeCalibrationJourneyState(content: content)
        let canonicalContent = content

        XCTAssertTrue(state.openLifeArea(id: "life-area.home"))
        XCTAssertTrue(state.openSelectedGoal())
        XCTAssertTrue(state.openRelationship())
        XCTAssertEqual(
            state.navigationPath,
            [
                .lifeArea(id: "life-area.home"),
                .focusedGoal(id: "goal.welcome-baby-home"),
                .relationship(
                    primaryGoalID: "goal.welcome-baby-home",
                    relatedGoalID: "goal.protect-first-weeks-together"
                )
            ]
        )
        XCTAssertFalse(state.hasMutation)
        XCTAssertEqual(content, canonicalContent)

        state.reconcileNavigationPath([
            .lifeArea(id: "life-area.home"),
            .focusedGoal(id: "goal.welcome-baby-home")
        ])
        XCTAssertEqual(state.focusAnchor, .focusedGoal)
        XCTAssertFalse(state.hasMutation)

        state.reconcileNavigationPath([.lifeArea(id: "life-area.home")])
        XCTAssertEqual(state.selectedLifeAreaID, "life-area.home")
        XCTAssertEqual(state.selectedGoalID, "goal.welcome-baby-home")
        XCTAssertEqual(state.focusAnchor, .selectedGoal)
        XCTAssertFalse(state.hasMutation)
        XCTAssertEqual(content, canonicalContent)
    }
}
