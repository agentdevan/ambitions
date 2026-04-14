import XCTest
@testable import Ambitions

final class GoalEngineFeedbackTests: XCTestCase {
    func testRepeatedAvoidanceOnAchievementGoalShrinksStep() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.feedbackFixture(id: "achievement-avoidance"))
        let result = GoalEngineAdaptationService().recommendPlanAdjustment(input: fixture.input)

        guard case .shrinkStep = result.recommendation else {
            return XCTFail("Expected shrink_step recommendation.")
        }
    }

    func testConfusionOnLearningGoalRevisesStep() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.feedbackFixture(id: "learning-confusion"))
        let result = GoalEngineAdaptationService().recommendPlanAdjustment(input: fixture.input)

        guard case let .reviseStep(_, _, _, _, _, evidenceAdjustments, _) = result.recommendation else {
            return XCTFail("Expected revise_step recommendation.")
        }

        XCTAssertFalse(evidenceAdjustments.isEmpty)
        XCTAssertTrue(GoalEngineFeedbackAnalyzer().analyze(input: fixture.input).repeatedConfusion)
    }

    func testTimingPressureOnUntimedGoalRelaxesTiming() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.feedbackFixture(id: "untimed-timing-pressure"))
        let result = GoalEngineAdaptationService().recommendPlanAdjustment(input: fixture.input)

        guard case let .relaxTiming(_, _, _, _, suggestedTimingType, removeDeadline) = result.recommendation else {
            return XCTFail("Expected relax_timing recommendation.")
        }

        XCTAssertEqual(suggestedTimingType, .suggestedNext)
        XCTAssertTrue(removeDeadline)
    }

    func testSupportToneCorrectionOnDelegatedGoal() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.feedbackFixture(id: "delegated-tone-drift"))
        let result = GoalEngineAdaptationService().recommendPlanAdjustment(input: fixture.input)

        guard case let .adjustPlanTone(_, _, _, _, toneGuidance) = result.recommendation else {
            return XCTFail("Expected adjust_plan_tone recommendation.")
        }

        XCTAssertTrue(toneGuidance.contains(where: { $0.contains("supported person") || $0.contains("owner of execution") }))
    }

    func testExplorationGoalBecomingTooRigidRelaxesTiming() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.feedbackFixture(id: "exploration-rigid"))
        let result = GoalEngineAdaptationService().recommendPlanAdjustment(input: fixture.input)

        guard case .relaxTiming = result.recommendation else {
            return XCTFail("Expected relax_timing recommendation.")
        }
    }

    func testRecoveryGoalRequiresGentlerStepSizing() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.feedbackFixture(id: "recovery-gentle"))
        let result = GoalEngineAdaptationService().recommendPlanAdjustment(input: fixture.input)

        guard case let .suggestMicroStep(_, _, _, _, microStep) = result.recommendation else {
            return XCTFail("Expected suggest_micro_step recommendation.")
        }

        XCTAssertFalse(microStep.isEmpty)
    }

    func testNotRelevantFeedbackEscalatesToReclarification() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.feedbackFixture(id: "not-relevant-reclarify"))
        let result = GoalEngineAdaptationService().recommendPlanAdjustment(input: fixture.input)

        guard case let .requestReclarification(_, _, _, _, questions) = result.recommendation else {
            return XCTFail("Expected request_reclarification recommendation.")
        }

        XCTAssertFalse(questions.isEmpty)
    }

    func testAskedWhyThisMattersSurfacesExplanationHook() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.feedbackFixture(id: "why-this-matters"))
        let result = GoalEngineAdaptationService().recommendPlanAdjustment(input: fixture.input)

        XCTAssertEqual(result.explanationHook?.prompt, "Why does this step matter?")
        guard case let .reviseStep(_, _, _, _, rewriteHints, _, explanationHook) = result.recommendation else {
            return XCTFail("Expected revise_step recommendation.")
        }
        XCTAssertFalse(rewriteHints.isEmpty)
        XCTAssertNotNil(explanationHook)
    }
}
