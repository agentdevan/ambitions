import XCTest
@testable import Ambitions

final class PlanningDomainModelsTests: XCTestCase {
    func testGoalBlueprintUsesStableLocalFirstDefaults() {
        let blueprint = GoalBlueprint(title: "Ship native goal intake")

        XCTAssertEqual(blueprint.mode, .project)
        XCTAssertEqual(blueprint.relationshipKind, .independent)
        XCTAssertEqual(blueprint.actor, .localOwner)
        XCTAssertEqual(blueprint.pace, .untimed)
        XCTAssertEqual(blueprint.source, .manual)

        let draft = blueprint.makeDraft()
        XCTAssertEqual(draft.title, "Ship native goal intake")
        XCTAssertEqual(draft.mode, .project)
        XCTAssertEqual(draft.actor.ownership, .self)
        XCTAssertEqual(draft.timing.tempo, .untimed)
        XCTAssertEqual(draft.timing.timingType, .logWhenDone)
        XCTAssertEqual(draft.timing.progressReviewCadenceDays, 7)
    }

    func testPlanningPaceMapsDeterministicallyToExistingTimingContracts() {
        XCTAssertEqual(PlanningPace.untimed.goalTempo, .untimed)
        XCTAssertEqual(PlanningPace.untimed.defaultTimingType, .logWhenDone)

        XCTAssertEqual(PlanningPace.targeted.goalTempo, .targetWindow)
        XCTAssertEqual(PlanningPace.targeted.defaultTimingType, .targetBy)

        XCTAssertEqual(PlanningPace.deadline.goalTempo, .deadlineBased)
        XCTAssertEqual(PlanningPace.deadline.defaultTimingType, .dueAt)

        XCTAssertEqual(PlanningPace.ongoing.goalTempo, .ongoing)
        XCTAssertEqual(PlanningPace.ongoing.defaultTimingType, .repeatWithinWindow)

        XCTAssertEqual(PlanningPace(goalTempo: .untimed), .untimed)
        XCTAssertEqual(PlanningPace(goalTempo: .targetWindow), .targeted)
        XCTAssertEqual(PlanningPace(goalTempo: .deadlineBased), .deadline)
        XCTAssertEqual(PlanningPace(goalTempo: .ongoing), .ongoing)
    }

    func testPlanStepBuildsStableStepWithDefaultActionability() {
        let planStep = PlanStep(
            id: "step-blueprint-1",
            title: "Define draft persistence boundary",
            summary: "Document the smallest write path.",
            pace: .targeted,
            targetDate: "2026-04-21"
        )

        let step = planStep.makeStep(sectionID: "section-1")

        XCTAssertEqual(step.id, "step-blueprint-1")
        XCTAssertEqual(step.sectionID, "section-1")
        XCTAssertEqual(step.type, .actionUnit)
        XCTAssertEqual(step.state, .planned)
        XCTAssertEqual(step.owner, .localOwner)
        XCTAssertEqual(step.timing.tempo, .targetWindow)
        XCTAssertEqual(step.timing.timingType, .targetBy)
        XCTAssertEqual(step.timing.targetBy, "2026-04-21")
        XCTAssertTrue(step.successSignals.contains("Document the smallest write path."))
        XCTAssertEqual(step.actionability.completionDefinition, "Document the smallest write path.")
    }

    func testOngoingBlueprintAndPlanStepUseRepeatCadenceDefaults() {
        let blueprint = GoalBlueprint(
            title: "Weekly planning review",
            mode: .maintenance,
            pace: .ongoing
        )
        let draft = blueprint.makeDraft()

        XCTAssertEqual(draft.timing.tempo, .ongoing)
        XCTAssertEqual(draft.timing.timingType, .repeatWithinWindow)
        XCTAssertEqual(draft.timing.repeatEveryDays, 7)

        let planStep = PlanStep(
            id: "repeat-1",
            title: "Review this week's planning signals",
            type: .recurringRoutine,
            pace: .ongoing
        )
        let step = planStep.makeStep(sectionID: "cadence")

        XCTAssertEqual(step.timing.tempo, .ongoing)
        XCTAssertEqual(step.timing.repeatEveryDays, 7)
        XCTAssertTrue(step.isRepeatable)
    }
}
