import XCTest
@testable import Ambitions

final class LedgerReplayModelsTests: XCTestCase {
    func testReplayTaxonomyCoversCommandEventSideEffectReceiptAndReplayTerms() {
        XCTAssertEqual(
            Set(LedgerRecordTaxonomyKind.allCases),
            [
                .command,
                .event,
                .sideEffect,
                .receipt
            ]
        )
        XCTAssertEqual(
            Set(LedgerReplayDecision.allCases),
            [
                .applyFresh,
                .replayExistingReceipt,
                .lookupUnavailable
            ]
        )
        XCTAssertEqual(
            Set(LedgerDoubleApplyDisposition.allCases),
            [
                .applyOnce,
                .skipDuplicateMutation,
                .skipUnverifiedMutation
            ]
        )
    }

    func testCommandIdActsAsTheIdempotencyKeyAndReplayOutcomeFlagsReplays() throws {
        let key = LedgerIdempotencyKey("command-ledger-1")
        let outcome = LedgerReplayOutcome(
            idempotencyKey: key,
            decision: .replayExistingReceipt,
            doubleApplyDisposition: .skipDuplicateMutation,
            receiptSummary: "Saved to Needs a Place"
        )

        XCTAssertTrue(key.isWellFormed)
        XCTAssertEqual(key.rawValue, "command-ledger-1")
        XCTAssertTrue(outcome.isReplay)
        XCTAssertEqual(outcome.idempotencyKey, key)
        XCTAssertEqual(outcome.decision, .replayExistingReceipt)
        XCTAssertEqual(outcome.doubleApplyDisposition, .skipDuplicateMutation)
        XCTAssertEqual(outcome.receiptSummary, "Saved to Needs a Place")

        let payload = try JSONEncoder().encode(outcome)
        let decoded = try JSONDecoder().decode(LedgerReplayOutcome.self, from: payload)

        XCTAssertEqual(decoded, outcome)
    }
}
