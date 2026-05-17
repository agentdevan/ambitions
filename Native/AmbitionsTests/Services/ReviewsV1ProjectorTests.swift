import XCTest
@testable import Ambitions

final class ReviewsV1ProjectorTests: XCTestCase {
    func testProjectionIsDeterministicAndUsesExistingLocalSignals() {
        let receipt = ActionReceipt(
            id: "receipt-recovery",
            resultState: .needsConfirmation,
            title: "Recovery prepared",
            summary: "Kept the must-do and left the plan unchanged until confirmation.",
            sourceDomain: .time,
            occurredAt: "2026-04-27T10:10:00Z",
            affectedObjects: [
                LifeGraphObjectReference(kind: .action, id: "plan-action", sourceDomain: .time)
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

    func testM09ReviewsMatureCadenceProgressReceiptAndSafePlanningHandoff() {
        let recoveryEvent = EventLedgerEntry(
            id: "ledger-recovery",
            kind: .recoveryDueToPriorityConflict,
            occurredAt: "2026-04-28T09:00:00Z",
            source: .plan,
            title: "Protected the must-do",
            summary: "Rescheduled lower-stakes work so the important promise stayed visible.",
            tone: .recovering
        )
        let correctionEvent = EventLedgerEntry(
            id: "ledger-correction",
            kind: .userCorrectionAdded,
            occurredAt: "2026-04-28T08:00:00Z",
            source: .you,
            title: "Corrected review wording",
            summary: "The user corrected what should carry forward.",
            tone: .correction
        )
        let receipt = ActionReceipt(
            id: "receipt-plan",
            resultState: .needsConfirmation,
            title: "Plan handoff prepared",
            summary: "Review suggested the next planning move without changing the plan.",
            sourceDomain: .reviews,
            occurredAt: "2026-04-28T09:05:00Z",
            affectedObjects: [
                LifeGraphObjectReference(kind: .review, id: "review-week", sourceDomain: .time)
            ],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact-confirm",
                    kind: .needsConfirmation,
                    summary: "Requires confirmation before any plan change."
                )
            ],
            correctionAvailability: .availableWithReason,
            undoAvailability: .requiresConfirmation,
            safetyState: .confirmationRequired
        )

        let projection = ReviewsV1Projector().project(
            ReviewsV1ProjectionInput(
                generatedAt: "2026-04-28T12:00:00Z",
                timeframeLabel: "This week",
                eventLedgerEntries: [correctionEvent, recoveryEvent],
                receipts: [receipt],
                proofEvidence: [
                    ProgressEvidence(
                        id: "proof-week",
                        goalID: "goal-1",
                        stepID: "step-1",
                        evidenceKind: .milestoneReached,
                        source: .manual,
                        capturedAt: "2026-04-28T09:10:00Z",
                        progressDelta: nil,
                        confidenceDelta: nil,
                        minutesInvested: 45,
                        note: "Milestone proof"
                    )
                ],
                calendarStatusLabel: "Manual fallback available"
            )
        )

        XCTAssertEqual(projection.cadences.map { $0.cadence }, [ReviewCadenceKind.weekly, .monthly, .recovery])
        XCTAssertTrue(projection.cadences.contains(where: { $0.contextLabel == "You and Plan" && $0.statusLabel == "Ready from local evidence" }))
        XCTAssertTrue(projection.cadences.contains(where: { $0.contextLabel == "You and Goals" && $0.statusLabel == "Proof-aware summary" }))
        XCTAssertTrue(projection.progressLines.contains(where: { $0.title == "What changed" && $0.privacyLabel == "Local event" }))
        XCTAssertTrue(projection.progressLines.contains(where: { $0.title == "Proof" && $0.privacyLabel == "Sensitive detail hidden" }))
        XCTAssertTrue(projection.progressLines.contains(where: { $0.title == "Carry forward" && $0.privacyLabel == "Needs confirmation" }))
        XCTAssertTrue(projection.planningHandoffs.contains(where: { $0.destinationLabel == "Carry into Plan" && $0.safetyLabel == "Suggested, not applied" }))
        XCTAssertFalse(projection.period.dominantTruth.localizedCaseInsensitiveContains("insights dashboard"))
        XCTAssertFalse(projection.progressLines.map(\.detail).joined(separator: " ").localizedCaseInsensitiveContains("analytics dashboard"))
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
