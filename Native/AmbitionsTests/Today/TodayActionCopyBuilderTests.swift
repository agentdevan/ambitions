import XCTest
import AmbitionsDesignSystem
@testable import Ambitions

final class TodayActionCopyBuilderTests: XCTestCase {
    func testBlockedActionCopyCoversEveryValidationStateWithoutInternalTerms() throws {
        let expectedBodies: [AmbitionsCommandValidationState: String] = [
            .valid: "This action is ready.",
            .invalid: "This action needs a clearer request before Ambitions can change anything.",
            .needsConfirmation: "Review this action before Ambitions changes anything.",
            .needsMissingTarget: "This action needs a real Step or source object before Ambitions can change anything.",
            .unsupportedInThisBuild: "This action is not available in this build.",
            .blockedByMissingFoundation: "This action is waiting on required foundation work before it can run."
        ]

        for validation in AmbitionsCommandValidationState.allCases {
            let message = try XCTUnwrap(TodayActionCopyBuilder.blockedActionResponse(for: validation).message)

            XCTAssertEqual(message.title, "Action not available", validation.rawValue)
            XCTAssertEqual(message.body, expectedBodies[validation], validation.rawValue)
            XCTAssertEqual(message.state, .warning, validation.rawValue)
            assertNoFirstLayerImplementationTerms(message, validation.rawValue)
        }
    }

    func testReplayedActionCopyCoversEveryTodayCommandBranchWithoutInternalTerms() throws {
        let cases: [(TodayActionKind, String, String, AmbitionVisualState)] = [
            (.complete, "Completion recorded", "Still counts. Already recorded. No duplicate change was made.", .success),
            (.reschedule, "What changed?", "Move it without blame. Already recorded. No duplicate change was made.", .warning),
            (.defer, "Pressure softened", "Move it without blame. Already recorded. No duplicate change was made.", .selected),
            (.split, "Smaller step kept", "A smaller version is kept. Already recorded. No duplicate change was made.", .selected),
            (.askForHelp, "Support context captured", "Support context is kept. Already recorded. No duplicate change was made.", .warning),
            (.askWhyThisMatters, "Why this matters", "Already recorded. No duplicate change was made.", .selected),
            (.quickLog, "Capture saved", "Already recorded. No duplicate change was made.", .success),
            (.openDetail, "Action already recorded", "Already recorded. No duplicate change was made.", .selected)
        ]

        for (kind, title, body, state) in cases {
            let message = try XCTUnwrap(TodayActionCopyBuilder.replayedActionResponse(for: action(kind)).message)

            XCTAssertEqual(message.title, title, kind.rawValue)
            XCTAssertEqual(message.body, body, kind.rawValue)
            XCTAssertEqual(message.state, state, kind.rawValue)
            assertNoFirstLayerImplementationTerms(message, kind.rawValue)
        }
    }
}

private extension TodayActionCopyBuilderTests {
    func action(_ kind: TodayActionKind) -> TodayInlineAction {
        TodayInlineAction(
            kind: kind,
            title: kind.rawValue,
            systemImage: "circle",
            state: .selected,
            target: TodayActionTarget(goalID: "goal", stepID: "step")
        )
    }

    func assertNoFirstLayerImplementationTerms(
        _ message: TodayInlineMessage,
        _ context: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let text = "\(message.title) \(message.body)".lowercased()
        for forbidden in [
            "runtime",
            "local runtime",
            "receipt",
            "replay trace",
            "rollback",
            "idempotency",
            "transaction",
            "command journal",
            "event ledger",
            "projection cursor"
        ] {
            XCTAssertFalse(text.contains(forbidden), "\(context) leaked \(forbidden)", file: file, line: line)
        }
    }
}
