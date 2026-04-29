import XCTest
@testable import Ambitions

final class ReviewsV1ProjectorTests: XCTestCase {
    func testProjectionIsDeterministicAndUsesExistingLocalSignals() {
        let receipt = ActionReceipt(
            id: "receipt-recovery",
            resultState: .needsConfirmation,
            title: "Recovery prepared",
            summary: "Kept the must-do and left the plan unchanged until confirmation.",
            sourceDomain: .plan,
            occurredAt: "2026-04-27T10:10:00Z",
            affectedObjects: [
                LifeGraphObjectReference(kind: .action, id: "plan-action", sourceDomain: .plan)
            ],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact-recovery",
                    kind: .needsConfirmation,
                    summary: "Suggested, not applied."
                )
            ],
            correctionAvailability: .availableWithReason,
            undoAvailability: .requiresConfirmation,
            safetyState: .confirmationRequired
        )
        let event = EventLedgerEntry(
            id: "ledger-complete",
            kind: .actionCompleted,
            occurredAt: "2026-04-27T10:05:00Z",
            source: .today,
            title: "Completed one protected move",
            summary: "Closed a meaningful local action.",
            tone: .positive
        )
        let input = ReviewsV1ProjectionInput(
            generatedAt: "2026-04-27T12:00:00Z",
            eventLedgerEntries: [event],
            receipts: [receipt],
            proofEvidence: [
                ProgressEvidence(
                    id: "proof-1",
                    goalID: "goal-1",
                    stepID: "step-1",
                    evidenceKind: .stepCompleted,
                    source: .manual,
                    capturedAt: "2026-04-27T10:06:00Z",
                    progressDelta: nil,
                    confidenceDelta: nil,
                    minutesInvested: 20,
                    note: "Proof note"
                )
            ],
            calendarStatusLabel: "Denied"
        )

        let first = ReviewsV1Projector().project(input)
        let second = ReviewsV1Projector().project(input)

        XCTAssertEqual(first, second)
        XCTAssertEqual(first.lifeOSReceipt.statusLabel, "Based on recent actions")
        XCTAssertEqual(first.lifeOSReceipt.receiptHighlights.map(\.valueLabel), ["Needs confirmation"])
        XCTAssertEqual(first.lifeOSReceipt.meaningfulEvents.map(\.valueLabel), ["Completed"])
        XCTAssertTrue(first.carryForward.contains(where: { $0.actionLabel == "Based on recent actions" }))
        XCTAssertTrue(first.unavailableNotes.contains(where: { $0.title == "Calendar changes" && $0.detail.contains("No calendar changes were made") }))
        XCTAssertTrue(first.period.trustWhisper.contains("Stored locally"))
    }

    func testEmptyAndDegradedStatesStayCalmAndTruthful() {
        let projection = ReviewsV1Projector().project(
            ReviewsV1ProjectionInput(
                generatedAt: "2026-04-27T12:00:00Z",
                calendarStatusLabel: "Manual fallback available"
            )
        )

        XCTAssertTrue(projection.isEmpty)
        XCTAssertEqual(projection.period.title, "Nothing to review yet")
        XCTAssertEqual(projection.recovery.statusLabel, "Nothing to review yet")
        XCTAssertEqual(projection.lifeOSReceipt.statusLabel, "No receipt yet")
        XCTAssertEqual(projection.carryForward.map(\.actionLabel), ["Available after more activity"])
        XCTAssertTrue(projection.recovery.boundaryNotes.contains("No calendar changes were made."))
        XCTAssertFalse(projection.period.trustWhisper.localizedCaseInsensitiveContains("synced everywhere"))
        XCTAssertFalse(projection.period.trustWhisper.localizedCaseInsensitiveContains("verified accessible"))
    }
}
