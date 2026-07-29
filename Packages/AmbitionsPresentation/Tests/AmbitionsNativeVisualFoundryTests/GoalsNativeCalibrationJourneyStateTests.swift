import XCTest
@testable import AmbitionsNativeVisualFoundry

final class GoalsNativeCalibrationJourneyStateTests: XCTestCase {
    private let content = GoalsNativeCalibrationFixture.preparingForBaby

    func testInitialStateExpandsOnlyHomeAndSelectsOneGoalWithoutRanking() {
        let state = GoalsNativeCalibrationJourneyState(content: content)

        XCTAssertEqual(state.selectedLifeAreaID, "life-area.home")
        XCTAssertEqual(state.expandedLifeAreaIDs, ["life-area.home"])
        XCTAssertEqual(state.selectedGoalID, "goal.welcome-baby-home")
        XCTAssertFalse(state.isLinkedLensExpanded)
        XCTAssertTrue(state.navigationPath.isEmpty)
        XCTAssertEqual(state.focusAnchor, .selectedGoal)
    }

    func testSelectingAnotherLifeAreaKeepsExactlyOneExpandedAndClearsGoalSelection() {
        var state = GoalsNativeCalibrationJourneyState(content: content)

        XCTAssertTrue(state.selectLifeArea(id: "life-area.relationships"))

        XCTAssertEqual(state.expandedLifeAreaIDs, ["life-area.relationships"])
        XCTAssertNil(state.selectedGoalID)
        XCTAssertFalse(state.isLinkedLensExpanded)
        XCTAssertEqual(state.focusAnchor, .lifeArea)
    }

    func testSelectingGoalAndOpeningLensAreInspectionOnly() {
        var state = GoalsNativeCalibrationJourneyState(content: content)
        let originalContent = content

        XCTAssertTrue(state.selectGoal(id: "goal.make-home-easier-to-run"))
        XCTAssertEqual(state.selectedGoalID, "goal.make-home-easier-to-run")
        XCTAssertFalse(state.isLinkedLensExpanded)

        XCTAssertTrue(state.selectGoal(id: content.primaryGoal.id))
        XCTAssertTrue(state.openLinkedLens())
        XCTAssertTrue(state.isLinkedLensExpanded)
        XCTAssertEqual(state.focusAnchor, .linkedLens)
        XCTAssertEqual(content, originalContent)
        XCTAssertFalse(state.hasMutation)
    }

    func testOpenGoalUsesTypedStableIdentityAndBackRestoresLens() {
        var state = GoalsNativeCalibrationJourneyState(content: content)
        XCTAssertTrue(state.openLinkedLens())

        XCTAssertTrue(state.openSelectedGoal())
        XCTAssertEqual(state.navigationPath, [.focusedGoal(id: "goal.welcome-baby-home")])
        XCTAssertEqual(state.focusAnchor, .focusedGoal)
        XCTAssertFalse(state.hasMutation)

        state.reconcileNavigationPath([])
        XCTAssertEqual(state.selectedLifeAreaID, "life-area.home")
        XCTAssertEqual(state.selectedGoalID, "goal.welcome-baby-home")
        XCTAssertTrue(state.isLinkedLensExpanded)
        XCTAssertEqual(state.focusAnchor, .linkedLens)
    }

    func testInvalidIdentitiesCannotCreateFixtureRoutes() {
        var state = GoalsNativeCalibrationJourneyState(content: content)

        XCTAssertFalse(state.selectLifeArea(id: "life-area.unknown"))
        XCTAssertFalse(state.selectGoal(id: "goal.unknown"))
        XCTAssertFalse(state.openSelectedGoal(id: "goal.unknown"))
        XCTAssertEqual(state.selectedLifeAreaID, "life-area.home")
        XCTAssertEqual(state.selectedGoalID, "goal.welcome-baby-home")
        XCTAssertTrue(state.navigationPath.isEmpty)
        XCTAssertFalse(state.hasMutation)
    }

    func testRelationshipInspectionIsNonMutatingAndBackRestoresFocusedGoalThenLens() {
        var state = GoalsNativeCalibrationJourneyState(content: content)
        let canonicalContent = content

        XCTAssertTrue(state.openLinkedLens())
        XCTAssertTrue(state.openSelectedGoal())
        XCTAssertTrue(state.openRelationship())
        XCTAssertEqual(
            state.navigationPath,
            [
                .focusedGoal(id: "goal.welcome-baby-home"),
                .relationship(
                    primaryGoalID: "goal.welcome-baby-home",
                    relatedGoalID: "goal.protect-first-weeks-together"
                )
            ]
        )
        XCTAssertFalse(state.hasMutation)
        XCTAssertEqual(content, canonicalContent)

        state.reconcileNavigationPath([.focusedGoal(id: "goal.welcome-baby-home")])
        XCTAssertEqual(state.focusAnchor, .focusedGoal)
        XCTAssertFalse(state.hasMutation)

        state.reconcileNavigationPath([])
        XCTAssertEqual(state.selectedLifeAreaID, "life-area.home")
        XCTAssertEqual(state.selectedGoalID, "goal.welcome-baby-home")
        XCTAssertTrue(state.isLinkedLensExpanded)
        XCTAssertEqual(state.focusAnchor, .linkedLens)
        XCTAssertFalse(state.hasMutation)
        XCTAssertEqual(content, canonicalContent)
    }
}
