import XCTest
@testable import Ambitions

final class GoalEngineOrchestratorTests: XCTestCase {
    func testClearTimedSelfGoalProducesPlanned() throws {
        let fixture = try unwrapFixture("clear-timed-self-goal")

        guard case let .planned(result) = fixture.result else {
            return XCTFail("Expected planned result.")
        }

        XCTAssertEqual(result.metadata.input.normalizedInput, "Submit my conference talk proposal by 2026-05-15")
        XCTAssertEqual(result.metadata.inference.mode.value, result.draft.mode)
        XCTAssertEqual(result.draft.timing.tempo, .deadlineBased)
        XCTAssertEqual(result.metadata.planner.evaluation, result.plan.evaluation)
        XCTAssertEqual(result.metadata.understanding.mode.goalMode, result.draft.mode)
        XCTAssertEqual(result.metadata.understanding.readiness.decision, result.metadata.clarification.analysis.decision)
        XCTAssertTrue(result.metadata.compiledPath.candidates.isEmpty == false)
    }

    func testUntimedLearningGoalCompilesIntoPlanShapedResult() throws {
        let fixture = try unwrapFixture("untimed-learning-goal")

        switch fixture.result {
        case let .planned(result):
            XCTAssertEqual(result.metadata.inference.tempo.value, result.draft.timing.tempo)
            XCTAssertEqual(result.draft.mode, .learning)
            XCTAssertEqual(result.metadata.planner.evaluation, result.plan.evaluation)
        case let .starterPlanned(result):
            XCTAssertEqual(result.metadata.inference.tempo.value, result.draft.timing.tempo)
            XCTAssertEqual(result.draft.mode, .learning)
            XCTAssertEqual(result.metadata.planner.evaluation, result.plan.evaluation)
        default:
            XCTFail("Expected planned or starter planned result.")
        }
    }

    func testVagueBusinessGoalBecomesStarterPlanWithAssumptions() throws {
        let fixture = try unwrapFixture("exploratory-vague-goal")

        guard case let .starterPlanned(result) = fixture.result else {
            return XCTFail("Expected starter planned result.")
        }

        XCTAssertFalse(result.assumptions.isEmpty)
        XCTAssertEqual(result.metadata.reasoning.assumptions.count, result.assumptions.count)
        XCTAssertGreaterThan(result.clarification.analysis.candidateInterpretations.count, 1)
        XCTAssertFalse(result.metadata.understanding.alternateInterpretations.isEmpty)
        XCTAssertTrue(result.metadata.understanding.clarification.alternateInterpretationsActive)
        XCTAssertEqual(result.metadata.compiledPath.overallPosture, .provisional)
        XCTAssertTrue(result.metadata.compiledPath.safeForStarterPlanning)
    }

    func testDelegatedChildSupportGoalKeepsSupportFraming() throws {
        let fixture = try unwrapFixture("delegated-child-support-goal")

        guard case let .planned(result) = fixture.result else {
            return XCTFail("Expected planned result.")
        }

        XCTAssertEqual(result.draft.actor.displayName, "Maya")
        XCTAssertTrue(result.plan.sections.contains(where: { $0.title == "Support Actions" }))

        let supportLanguage = result.plan.sections
            .flatMap(\.steps)
            .map(\.actionability.action)
            .joined(separator: " ")
            .lowercased()
        XCTAssertFalse(supportLanguage.contains("punish"))
        XCTAssertFalse(supportLanguage.contains("force"))
    }

    func testClarificationRequiredCase() throws {
        let fixture = try unwrapFixture("blocked-requiring-clarification")

        guard case let .clarificationRequired(result) = fixture.result else {
            return XCTFail("Expected clarification required result.")
        }

        XCTAssertTrue(result.clarification.questions.contains(where: { $0.field == .executorIdentity }))
        XCTAssertEqual(result.clarification.analysis.decision, .mustClarifyBeforeCompile)
        XCTAssertEqual(result.metadata.compiledPath.overallPosture, .blocked)
    }

    func testPlannerBlockedCaseSurfacesBlockedResult() {
        struct BlockedPlanner: GoalPlanning {
            let draft: GoalDraft

            func plan(input: GoalPlannerInput, options: GoalPlannerOptions) -> GoalPlannerResult {
                .blocked(
                    draft: draft,
                    blockers: [GoalPlanningBlocker(code: "planner_blocked_for_test", reason: "Synthetic blocked result for orchestration verification.", suggestedQuestion: "What constraint should the planner honor first?")],
                    clarification: input.clarification
                )
            }
        }

        let intake = GoalEngineIntakeService()
        let draftBuild = intake.buildGoalDraft(from: "Learn how to mix vocals", referenceNow: GoalEngineFixtures.fixedNow)
        let orchestrator = GoalEngineOrchestrator(planner: BlockedPlanner(draft: draftBuild.draft))
        let result = orchestrator.compileGoal("Learn how to mix vocals", context: GoalEngineOrchestrationContext(referenceNow: GoalEngineFixtures.fixedNow))

        guard case let .blocked(blocked) = result else {
            return XCTFail("Expected blocked result.")
        }

        XCTAssertEqual(blocked.blockers.first?.code, "planner_blocked_for_test")
    }

    func testContradictoryInputRequiresClarification() throws {
        let fixture = try unwrapFixture("contradictory-input")

        guard case let .clarificationRequired(result) = fixture.result else {
            return XCTFail("Expected clarification required result.")
        }

        XCTAssertFalse(result.clarification.contradictions.isEmpty)
        XCTAssertEqual(result.clarification.analysis.decision, .mustClarifyBeforeCompile)
    }

    func testDontKnowWhereToStartRequiresGoalSubjectClarification() throws {
        let fixture = try unwrapFixture("dont-know-where-to-start")

        guard case let .clarificationRequired(result) = fixture.result else {
            return XCTFail("Expected clarification required result.")
        }

        XCTAssertTrue(result.metadata.reasoning.missingFields.contains(where: { $0.field == .goalSubject }))
        XCTAssertEqual(result.metadata.understanding.readiness.decision, .mustClarifyBeforeCompile)
        XCTAssertFalse(result.metadata.understanding.readiness.safeToCompile)
    }

    func testTargetWindowGoalRetainsFlexibleTiming() throws {
        let fixture = try unwrapFixture("target-window-goal")

        switch fixture.result {
        case let .planned(result):
            XCTAssertEqual(result.draft.timing.tempo, .targetWindow)
            XCTAssertEqual(result.draft.timing.windowEnd, "2026-08-31")
        case let .starterPlanned(result):
            XCTAssertEqual(result.draft.timing.tempo, .targetWindow)
            XCTAssertEqual(result.draft.timing.windowEnd, "2026-08-31")
        default:
            XCTFail("Expected target-window goal to remain plannable.")
        }
    }

    func testStrictPlanningPromotesStarterSafeGoalIntoClarifyFirst() {
        let result = GoalEngineOrchestrator().compileGoal(
            "Launch my business",
            context: GoalEngineOrchestrationContext(
                preferredPlanningStrictness: .strict,
                referenceNow: GoalEngineFixtures.fixedNow
            )
        )

        guard case let .clarificationRequired(required) = result else {
            return XCTFail("Expected strict planning to require clarification.")
        }

        XCTAssertEqual(required.clarification.analysis.decision, .mustClarifyBeforeCompile)
        XCTAssertGreaterThan(required.clarification.analysis.candidateInterpretations.count, 1)
    }

    private func unwrapFixture(_ id: String) throws -> GoalEngineFixture {
        try XCTUnwrap(GoalEngineFixtures.fixture(id: id))
    }
}
