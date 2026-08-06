import XCTest
@testable import Ambitions

final class CalendarWriteIntentExecutorTests: XCTestCase {
    func testScheduleMutationIntentPreservesNormalizedRelatedObjectIDs() throws {
        let start = Date(timeIntervalSince1970: 1_714_000_000)
        let command = AmbitionsCommand(
            id: "calendar-related-object-identities",
            kind: .scheduleItem,
            source: .time,
            target: AmbitionsCommandTarget(timeID: "time-block-preview"),
            payload: AmbitionsCommandPayload(
                title: "Draft proposal",
                metadata: [
                    "calendarWriteIntent": "true",
                    "userConfirmed": "true",
                    "approvedDurationMinutes": "15",
                    "startAt": DomainTimestamp.string(from: start),
                    "endAt": DomainTimestamp.string(from: start.addingTimeInterval(900)),
                    "relatedGoalID": "goal-active",
                    "relatedCaptureID": "capture-active"
                ]
            ),
            createdAt: "2026-04-25T12:00:00Z"
        )

        let intent = try XCTUnwrap(AmbitionsCommandExecutor.test().scheduleMutationIntent(for: command))

        XCTAssertEqual(intent.relatedGoalID, "goal-active")
        XCTAssertEqual(intent.relatedCaptureID, "capture-active")
    }
}
