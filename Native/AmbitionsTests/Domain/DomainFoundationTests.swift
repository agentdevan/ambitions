import XCTest
@testable import Ambitions

final class DomainFoundationTests: XCTestCase {
    func testRecommendationConfidenceBucketsNumericConfidence() {
        XCTAssertEqual(RecommendationConfidence.label(for: 0.19), .low)
        XCTAssertEqual(RecommendationConfidence.label(for: 0.55), .medium)
        XCTAssertEqual(RecommendationConfidence.label(for: 0.86), .high)
    }

    func testFeedbackEventExposesStableKindAndDriftCause() {
        let skipped = GoalFeedbackEvent.skipped(
            base: GoalFeedbackEventBase(
                id: "skip-1",
                stepID: "step-1",
                occurredAt: "2026-04-18T12:00:00Z",
                note: nil
            ),
            reasonCode: .blockedExternal
        )
        let confused = GoalFeedbackEvent.confused(
            base: GoalFeedbackEventBase(
                id: "confused-1",
                stepID: "step-1",
                occurredAt: "2026-04-18T12:05:00Z",
                note: nil
            ),
            confusionType: .missingContext
        )
        let smaller = GoalFeedbackEvent.askedForSmallerVersion(
            base: GoalFeedbackEventBase(
                id: "smaller-1",
                stepID: "step-1",
                occurredAt: "2026-04-18T12:10:00Z",
                note: nil
            )
        )

        XCTAssertEqual(skipped.kind, .skipped)
        XCTAssertEqual(skipped.causeOfDrift, .externalDependency)
        XCTAssertEqual(confused.kind, .confused)
        XCTAssertEqual(confused.causeOfDrift, .missingContext)
        XCTAssertEqual(smaller.kind, .askedForSmallerVersion)
        XCTAssertEqual(smaller.causeOfDrift, .oversizedStep)
    }

    func testFeedbackAnalysisSurfacesExecutionModeMomentumAndConfidence() throws {
        let fixture = try XCTUnwrap(GoalEngineFixtures.feedbackFixture(id: "recovery-gentle"))

        let analysis = GoalEngineFeedbackAnalyzer().analyze(input: fixture.input)

        XCTAssertEqual(analysis.signals.executionMode, .recovery)
        XCTAssertEqual(analysis.signals.narrativeMomentum, .recovering)
        XCTAssertEqual(analysis.signals.recommendationConfidence, .medium)
        XCTAssertEqual(analysis.signals.primaryCauseOfDrift, .oversizedStep)
    }

    func testExistingConcreteTypesSatisfyCurrentServiceBoundaries() async throws {
        let planning: any GoalPlanning = GoalPlanner()
        let recovery: any GoalRescheduling = RescheduleEngine()
        let orchestration: any GoalOrchestrating = GoalEngineOrchestrator()
        let sync: any SyncServicing = LocalOnlySyncService()

        let fixture = try XCTUnwrap(GoalEngineFixtures.fixture(id: "clear-timed-self-goal"))
        let intake = GoalEngineIntakeService()
        let build = intake.buildGoalDraft(from: fixture.input, referenceNow: GoalEngineFixtures.fixedNow)
        let clarification = ClarificationSet(
            readiness: build.clarification.readiness,
            questions: build.clarification.questions,
            missingFields: build.clarification.missingFields
        )

        let planningResult = planning.plan(
            input: GoalPlannerInput(
                draft: build.draft,
                classification: build.classification,
                clarification: clarification,
                clarificationAnalysis: nil
            ),
            options: GoalPlannerOptions(now: GoalEngineFixtures.fixedNow)
        )

        switch planningResult {
        case .plan, .starterPlan:
            break
        case .blocked:
            XCTFail("Expected current planner boundary to stay plannable for the fixture.")
        }

        let rescheduleDecision = recovery.decide(
            RescheduleEngineInput(
                stepID: "step-1",
                timing: GoalTiming(
                    tempo: .deadlineBased,
                    timingType: .dueAt,
                    startsOn: nil,
                    dueAt: "2026-04-19T18:00:00Z",
                    targetBy: nil,
                    windowStart: nil,
                    windowEnd: nil,
                    suggestedNextAt: "2026-04-18T14:00:00Z",
                    repeatEveryDays: nil,
                    progressReviewCadenceDays: 7
                ),
                feedbackHistory: [],
                trigger: .delay,
                fallbackMicroStep: "Write one paragraph.",
                now: Date(timeIntervalSince1970: 1_745_280_000)
            )
        )
        XCTAssertEqual(rescheduleDecision.recommendationConfidence, .medium)

        switch orchestration.compileGoal(
            fixture.input,
            context: GoalEngineOrchestrationContext(referenceNow: GoalEngineFixtures.fixedNow)
        ) {
        case .planned, .starterPlanned:
            break
        case .clarificationRequired, .blocked:
            XCTFail("Expected current orchestration boundary to stay usable for the fixture.")
        }

        let syncState = await sync.currentState()
        XCTAssertEqual(syncState.availability, .localOnly)
    }
}
