import XCTest
@testable import Ambitions

final class RescheduleEngineTests: XCTestCase {
    func testSingleDelaySuggestsLaterTodayWithoutScopeReduction() {
        let decision = RescheduleEngine().decide(
            RescheduleEngineInput(
                stepID: "step-1",
                timing: baseTiming,
                feedbackHistory: [],
                trigger: .delay,
                fallbackMicroStep: "Write one paragraph.",
                now: fixedNow
            )
        )

        XCTAssertEqual(decision.deferRecommendation, .laterToday)
        XCTAssertEqual(decision.timingAdjustment, .laterToday)
        XCTAssertNotNil(decision.suggestedTime)
        XCTAssertNil(decision.smallerStep)
    }

    func testRepeatedMissesEscalateToSomedayDeferral() {
        let history: [GoalFeedbackEvent] = [
            .skipped(base: baseEvent(id: "s1", at: "2026-04-12T09:00:00Z"), reasonCode: .notNow),
            .delayed(base: baseEvent(id: "d1", at: "2026-04-13T09:00:00Z"), timingAdjustment: .laterToday, date: nil),
            .skipped(base: baseEvent(id: "s2", at: "2026-04-14T09:00:00Z"), reasonCode: .avoidance),
            .delayed(base: baseEvent(id: "d2", at: "2026-04-15T09:30:00Z"), timingAdjustment: .laterThisWeek, date: nil)
        ]

        let decision = RescheduleEngine().decide(
            RescheduleEngineInput(
                stepID: "step-1",
                timing: baseTiming,
                feedbackHistory: history,
                trigger: .skip,
                fallbackMicroStep: "Write one paragraph.",
                now: fixedNow
            )
        )

        XCTAssertEqual(decision.deferRecommendation, .laterThisWeek)
        XCTAssertEqual(decision.timingAdjustment, .laterThisWeek)
        XCTAssertNotNil(decision.suggestedTime)
    }

    func testStuckTriggerAlwaysProvidesSmallerStepFallback() {
        let history: [GoalFeedbackEvent] = [
            .confused(base: baseEvent(id: "c1", at: "2026-04-15T10:00:00Z"), confusionType: .unclearAction)
        ]

        let decision = RescheduleEngine().decide(
            RescheduleEngineInput(
                stepID: "step-1",
                timing: baseTiming,
                feedbackHistory: history,
                trigger: .stuck,
                fallbackMicroStep: "Write one paragraph.",
                now: fixedNow
            )
        )

        XCTAssertNotNil(decision.smallerStep)
        XCTAssertTrue(decision.smallerStep?.summary.contains("Write one paragraph.") == true)
    }

    func testDecisionIsDeterministicForSameInputAndTime() {
        let history: [GoalFeedbackEvent] = [
            .delayed(base: baseEvent(id: "d2", at: "2026-04-15T09:30:00Z"), timingAdjustment: .laterToday, date: nil),
            .skipped(base: baseEvent(id: "s1", at: "2026-04-12T09:00:00Z"), reasonCode: .notNow),
            .delayed(base: baseEvent(id: "d1", at: "2026-04-13T09:00:00Z"), timingAdjustment: .laterToday, date: nil)
        ]
        let input = RescheduleEngineInput(
            stepID: "step-1",
            timing: baseTiming,
            feedbackHistory: history,
            trigger: .delay,
            fallbackMicroStep: "Write one paragraph.",
            now: fixedNow
        )

        let engine = RescheduleEngine()
        let first = engine.decide(input)
        let second = engine.decide(input)

        XCTAssertEqual(first, second)
    }
}

private extension RescheduleEngineTests {
    var fixedNow: Date {
        Date(timeIntervalSince1970: 1_745_798_400) // 2026-04-28T12:00:00Z
    }

    var baseTiming: GoalTiming {
        GoalTiming(
            tempo: .deadlineBased,
            timingType: .dueAt,
            startsOn: nil,
            dueAt: "2026-04-16T18:00:00Z",
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: "2026-04-15T13:00:00Z",
            repeatEveryDays: nil,
            progressReviewCadenceDays: 7
        )
    }

    func baseEvent(id: String, at occurredAt: String) -> GoalFeedbackEventBase {
        GoalFeedbackEventBase(
            id: id,
            stepID: "step-1",
            occurredAt: occurredAt,
            note: nil
        )
    }
}
