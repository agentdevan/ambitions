import XCTest
@testable import Ambitions

final class PlanningEngineV2Tests: XCTestCase {
    func testFeasibilityIsComfortableForRealisticPlan() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "untimed-learning-goal"))
        guard case let .planned(result) = fixture.result else {
            return XCTFail("Expected planned result.")
        }

        let evaluation = try XCTUnwrap(result.plan.evaluation)
        XCTAssertEqual(evaluation.feasibilityLevel, .comfortable)
        XCTAssertEqual(evaluation.pressureLevel, .low)
        XCTAssertEqual(evaluation.effortPosture, .gentle)
        XCTAssertFalse(evaluation.reasons.isEmpty)
    }

    func testDeadlinePressureWithManyStepsBecomesFragileOrNotBelievable() throws {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let timing = GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: "2026-04-15T12:00:00Z", dueAt: "2026-04-17T12:00:00Z", targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 5)
        let draft = GoalDraft(schemaVersion: goalEngineSchemaVersion, source: .manual, title: "Ship a risky plan", summary: nil, mode: .project, relationshipKind: .independent, actor: actor, parentGoalID: nil, tags: [], timing: timing, planningStrategy: PlanningStrategy(strategyKind: .sequential, allowParallelSteps: false, maxActiveSteps: 3, preferredSectionOrder: [.activeSteps], defaultStepType: .actionUnit, autoGenerateReviewSection: false, preferShortSteps: true, revisitCadenceDays: 5), progressStrategy: ProgressStrategy(metricKind: .stepCompletion, rollupMethod: .ratio, targetStepCount: nil, targetEvidenceCount: nil, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false))
        let steps = (1...8).map { index in
            Step(id: "step-\(index)", sectionID: "section-1", title: "Step \(index)", summary: nil, type: .actionUnit, state: .planned, owner: actor, timing: timing, dependencyStepIDs: [], isOptional: false, isRepeatable: false, evidenceRequired: true, successSignals: ["Done"], actionability: StepActionability(action: "Do step \(index)", completionDefinition: "Done", evidenceOfCompletion: ["Done"], fallbackMicroStep: "Start", contextRequirements: []))
        }
        let plan = GoalPlan(id: "plan-1", goalID: "goal-1", version: goalEnginePlanVersion, generatedAt: "2026-04-15T12:00:00Z", summary: nil, strategy: draft.planningStrategy, sections: [PlanSection(id: "section-1", goalID: "goal-1", title: "Active", summary: nil, kind: .activeSteps, orderIndex: 0, steps: steps)], assumptions: [], lint: PlanLintResult(goalID: "goal-1", planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: []))

        let evaluation = PlanningEvaluator().evaluate(draft: draft, plan: plan, inference: ["mode": InferenceMetadata(source: .derivedContract, inferred: true, confidence: 0.62, label: .medium, reason: "Test")])

        XCTAssertEqual(evaluation.pressureLevel, .high)
        XCTAssertTrue([PlanningFeasibilityLevel.fragile, .notBelievable].contains(evaluation.feasibilityLevel))
        XCTAssertEqual(evaluation.effortPosture, .push)
    }

    func testStarterAssumptionsLowerConfidenceAndRaiseFragility() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "exploratory-vague-goal"))
        guard case let .starterPlanned(result) = fixture.result else {
            return XCTFail("Expected starter plan.")
        }

        let evaluation = try XCTUnwrap(result.plan.evaluation)
        XCTAssertFalse(result.assumptions.isEmpty)
        XCTAssertNotEqual(evaluation.fragilityLevel, .low)
        XCTAssertNotEqual(evaluation.recommendationConfidence, .high)
        XCTAssertEqual(evaluation.effortPosture, .gentle)
    }

    func testNextStepSelectorIsDeterministic() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let goalSoon = try makeGoal(id: "goal-soon", stepID: "step-soon", dueAt: "2026-04-16T12:00:00Z")
        let goalLater = try makeGoal(id: "goal-later", stepID: "step-later", dueAt: "2026-05-01T12:00:00Z")

        let selection = PlanningNextStepSelector().bestSelection(goals: [goalLater, goalSoon], now: now)

        XCTAssertEqual(selection?.goal.id, "goal-soon")
        XCTAssertEqual(selection?.step.id, "step-soon")
    }

    func testEvaluationMetadataRoundTripsAndOldPlanSnapshotsDecode() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "clear-timed-self-goal"))
        guard case let .planned(result) = fixture.result else {
            return XCTFail("Expected planned result.")
        }

        let data = try PersistenceCoding.encode(result.plan)
        let decoded = try PersistenceCoding.decode(GoalPlan.self, from: data)
        XCTAssertEqual(decoded.evaluation, result.plan.evaluation)

        let oldJSON = """
        {"id":"plan-old","goalID":"goal-old","version":1,"generatedAt":"2026-04-15T12:00:00Z","summary":null,"strategy":{"strategyKind":"sequential","allowParallelSteps":false,"maxActiveSteps":3,"preferredSectionOrder":["active_steps"],"defaultStepType":"action_unit","autoGenerateReviewSection":false,"preferShortSteps":true,"revisitCadenceDays":null},"sections":[],"assumptions":[],"lint":{"goalID":"goal-old","planVersion":1,"isValid":true,"issueCount":0,"issues":[]}}
        """
        let oldDecoded = try PersistenceCoding.decode(GoalPlan.self, from: Data(oldJSON.utf8))
        XCTAssertNil(oldDecoded.evaluation)
    }
}

private extension PlanningEngineV2Tests {
    func makeGoal(id: String, stepID: String, dueAt: String) throws -> Goal {
        let actor = GoalActor(actorID: "self", displayName: "You", ownership: .self, roleLabel: "Primary owner", isPrimary: true)
        let timing = GoalTiming(tempo: .deadlineBased, timingType: .dueAt, startsOn: nil, dueAt: dueAt, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: 7)
        let step = Step(id: stepID, sectionID: "section-\(id)", title: "Do the next thing", summary: nil, type: .actionUnit, state: .planned, owner: actor, timing: timing, dependencyStepIDs: [], isOptional: false, isRepeatable: false, evidenceRequired: true, successSignals: ["Done"], actionability: StepActionability(action: "Do it", completionDefinition: "Done", evidenceOfCompletion: ["Done"], fallbackMicroStep: "Start", contextRequirements: []))
        let strategy = PlanningStrategy(strategyKind: .sequential, allowParallelSteps: false, maxActiveSteps: 3, preferredSectionOrder: [.activeSteps], defaultStepType: .actionUnit, autoGenerateReviewSection: false, preferShortSteps: true, revisitCadenceDays: 7)
        let progress = ProgressStrategy(metricKind: .stepCompletion, rollupMethod: .ratio, targetStepCount: nil, targetEvidenceCount: nil, targetMinutes: nil, supportsUntimedProgress: true, countsChildGoals: false, countsSupportGoals: false)
        let plan = GoalPlan(id: "plan-\(id)", goalID: id, version: goalEnginePlanVersion, generatedAt: "2026-04-15T12:00:00Z", summary: nil, strategy: strategy, sections: [PlanSection(id: "section-\(id)", goalID: id, title: "Active", summary: nil, kind: .activeSteps, orderIndex: 0, steps: [step])], assumptions: [], lint: PlanLintResult(goalID: id, planVersion: goalEnginePlanVersion, isValid: true, issueCount: 0, issues: []))
        return Goal(schemaVersion: goalEngineSchemaVersion, id: id, revision: 1, createdAt: "2026-04-15T12:00:00Z", updatedAt: "2026-04-15T12:00:00Z", state: .active, title: id, summary: nil, mode: .project, relationshipKind: .independent, actor: actor, parentGoalID: nil, childGoalIDs: [], supportGoalIDs: [], tags: [], timing: timing, planningStrategy: strategy, progressStrategy: progress, plan: plan)
    }
}
