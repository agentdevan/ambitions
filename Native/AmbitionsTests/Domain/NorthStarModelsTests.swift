import XCTest
@testable import Ambitions

final class NorthStarModelsTests: XCTestCase {
    func testNorthStarPreservesDormantAmbitionSemanticsWithoutCreatingGoal() {
        let northStar = NorthStar(
            id: NorthStarID(rawValue: " astronaut "),
            title: "Become an Astronaut",
            summary: "A long-range direction",
            primaryLifeAreaID: LifeAreaID(domain: .career),
            posture: .dormant,
            horizon: .identityLevel,
            motivationNote: "Who I want to become",
            activationReadiness: .heldWithoutPressure,
            canBeShaped: true,
            suggestedNextAction: "Review later"
        )

        XCTAssertEqual(northStar.id.rawValue, "astronaut")
        XCTAssertEqual(northStar.primaryLifeAreaID, LifeAreaID(domain: .career))
        XCTAssertEqual(northStar.posture.displayName, "Dormant for now")
        XCTAssertTrue(northStar.posture.isDormantDirection)
        XCTAssertEqual(northStar.horizon?.displayName, "Identity-level")
        XCTAssertEqual(northStar.shapeIntoGoalLabel, "This can become a goal later")
        XCTAssertEqual(northStar.suggestedNextAction, "Review later")
        XCTAssertEqual(northStar.linkedGoalIDs, [])
        XCTAssertEqual(northStar.objectReference.kind, .northStar)
    }

    func testRelationshipHooksDeduplicateAndCoverFutureReferenceTypesOnly() {
        let area = LifeGraphObjectReference(kind: .lifeArea, id: "career", label: "Career", sourceDomain: .goals)
        let goal = LifeGraphObjectReference(kind: .goal, id: "goal-1", label: "Goal", sourceDomain: .goals)
        let step = LifeGraphObjectReference(kind: .step, id: "step-1", parentContextID: "goal-1", label: "Step", sourceDomain: .goalEngine)
        let taskHook = LifeGraphObjectReference(kind: .oneStepGoal, id: "future-task", label: "Future One-Step Goal", sourceDomain: .capture)
        let hooks = NorthStarReferenceHooks(
            lifeAreaReference: area,
            linkedGoalReferences: [goal, goal],
            stepReferences: [step],
            futureOneStepGoalReferences: [taskHook]
        )

        XCTAssertEqual(hooks.lifeAreaReference.kind, .lifeArea)
        XCTAssertEqual(hooks.linkedGoalReferences.map(\.id), ["goal-1"])
        XCTAssertEqual(hooks.stepReferences.map(\.id), ["step-1"])
        XCTAssertEqual(hooks.futureOneStepGoalReferences.map(\.kind), [.oneStepGoal])
    }

    func testRedactedSummaryKeepsStructureAndHidesSensitiveDetails() {
        let northStar = NorthStar(
            id: NorthStarID(rawValue: "private-direction"),
            title: "Sensitive direction",
            summary: "Private details",
            primaryLifeAreaID: LifeAreaID(domain: .personalGrowth),
            linkedGoalIDs: ["goal-a", "goal-b"],
            activationReadiness: .readyToShape,
            canBeShaped: true,
            isSensitive: true
        )

        let summary = NorthStarSummary(northStar: northStar, linkedActiveGoalCount: 1, privacyLevel: .redacted)

        XCTAssertEqual(summary.title, "Private North Star")
        XCTAssertEqual(summary.summary, "Detail hidden")
        XCTAssertEqual(summary.linkedActiveGoalCount, 1)
        XCTAssertEqual(summary.objectReference.label, "Private North Star")
        XCTAssertEqual(summary.accessibility.label, "Private North Star")
        XCTAssertTrue(summary.accessibility.hint.contains("No goal is created automatically"))
    }
}
