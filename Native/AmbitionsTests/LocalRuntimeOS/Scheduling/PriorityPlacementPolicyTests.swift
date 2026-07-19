import XCTest
@testable import Ambitions

final class PriorityPlacementPolicyTests: XCTestCase {
    private let policy = PriorityPlacementPolicy()
    private let protectedPolicy = ProtectedStepPlacementPolicy()
    private let now = Date(timeIntervalSince1970: 1_780_000_000)

    func testP2CAPrioritySupportsLowNormalHighOnly() {
        XCTAssertEqual(PlacementPriority.allCases.map(\.userFacingLabel), ["Low", "Normal", "High"])
        XCTAssertEqual(PlacementPriority.userFacingValue(from: "Low"), .low)
        XCTAssertEqual(PlacementPriority.userFacingValue(from: "Normal"), .normal)
        XCTAssertEqual(PlacementPriority.userFacingValue(from: "High"), .high)
    }

    func testP2CACriticalAndMustFitAreNotValidUserFacingPriorityValues() {
        XCTAssertNil(PlacementPriority.userFacingValue(from: "Critical"))
        XCTAssertNil(PlacementPriority.userFacingValue(from: "Must Fit"))
        XCTAssertNil(PlacementPriority.userFacingValue(from: "urgent score"))
        XCTAssertFalse(PlacementPriority.allCases.map(\.userFacingLabel).contains("Critical"))
        XCTAssertFalse(PlacementPriority.allCases.map(\.userFacingLabel).contains("Must Fit"))
    }

    func testP2CAUserOverrideIsRepresentedWithoutRankOrScore() {
        let decision = policy.evaluate(
            input: PriorityPlacementInput(
                stepID: "step-priority",
                priority: .low,
                source: .userOverride,
                userOverride: .high
            )
        )

        XCTAssertEqual(decision.priority, .high)
        XCTAssertEqual(decision.source, .userOverride)
        XCTAssertEqual(decision.userOverride, .high)
        XCTAssertTrue(decision.isUserOverride)
        XCTAssertFalse(decision.reviewNote.localizedCaseInsensitiveContains("score"))
        XCTAssertFalse(decision.reviewNote.localizedCaseInsensitiveContains("rank"))
        XCTAssertFalse(decision.reviewNote.localizedCaseInsensitiveContains("Critical"))
        XCTAssertFalse(decision.reviewNote.localizedCaseInsensitiveContains("Must Fit"))
    }

    func testP2CAHighPriorityCannotSilentlyBypassProtectedSevenDayPlacement() throws {
        let protectedDecision = protectedPolicy.evaluate(
            now: now,
            stepID: "step-high-protected",
            originalPlacement: try window(daysFromNow: 1),
            proposedPlacement: try window(daysFromNow: 2),
            trigger: .userInitiated,
            explicitUserApproval: false,
            automationPolicy: .notApplicable,
            contextQuality: .sufficient,
            localOnly: true
        )

        let decision = policy.evaluate(
            input: PriorityPlacementInput(
                stepID: "step-high-protected",
                priority: .high,
                source: .userOverride,
                userOverride: .high
            ),
            protectedPlacementDecision: protectedDecision
        )

        XCTAssertEqual(decision.priority, .high)
        XCTAssertEqual(decision.protectedPlacementKind, .requiresExplicitApproval)
        XCTAssertTrue(decision.requiresExplicitApproval)
        XCTAssertFalse(decision.canBypassProtectedApproval)
        XCTAssertTrue(decision.reviewNote.contains("still needs approval"))
    }

    func testP2CALowContextPriorityReturnsPendingReviewInsteadOfFakeConfidence() {
        let decision = policy.evaluate(
            input: PriorityPlacementInput(
                stepID: "step-low-context",
                priority: nil,
                source: .lowContext,
                contextQuality: .lowContext
            )
        )

        XCTAssertEqual(decision.priority, .normal)
        XCTAssertEqual(decision.reviewDisposition, .pendingReview)
        XCTAssertTrue(decision.degradedFacts.contains { $0.localizedCaseInsensitiveContains("Low context") })
        XCTAssertFalse(decision.reviewNote.localizedCaseInsensitiveContains("confidence"))
        XCTAssertFalse(decision.reviewNote.localizedCaseInsensitiveContains("optimized"))
    }

    func testP2CALowPriorityCanSuggestDeferReviewWithoutMakeRoomMutation() {
        let decision = policy.evaluate(
            input: PriorityPlacementInput(
                stepID: "step-low",
                priority: .low,
                source: .userOverride,
                userOverride: .low
            )
        )

        XCTAssertEqual(decision.priority, .low)
        XCTAssertEqual(decision.reviewDisposition, .deferSuggestion)
        XCTAssertTrue(decision.reviewNote.contains("hold this for review"))
        XCTAssertFalse(decision.reviewNote.localizedCaseInsensitiveContains("Make room"))
        XCTAssertFalse(decision.reviewNote.localizedCaseInsensitiveContains("Must Fit"))
    }

    func testP2CACommandHintsCanCreatePriorityContextWithoutScore() {
        let command = AmbitionsCommand(
            id: "command.priority.context",
            kind: .placeStepInTime,
            source: .time,
            target: AmbitionsCommandTarget(timeID: "time.1", stepID: "step.1"),
            payload: AmbitionsCommandPayload(
                priorityHints: AmbitionsCommandPriorityHints(importance: .high),
                metadata: ["contextQuality": "sufficient"]
            ),
            createdAt: "2026-06-25T12:00:00Z"
        )

        let input = PriorityPlacementInput.fromCommand(command)
        let decision = policy.evaluate(input: input)

        XCTAssertEqual(input.priority, .high)
        XCTAssertEqual(input.source, .commandHint)
        XCTAssertEqual(decision.priority, .high)
        XCTAssertFalse(decision.reviewNote.localizedCaseInsensitiveContains("score"))
        XCTAssertFalse(decision.reviewNote.localizedCaseInsensitiveContains("rank"))
    }

    func testP2CAPriorityPlacementStaysLocalOfflineAndAccountFree() {
        let decision = policy.evaluate(
            input: PriorityPlacementInput(
                stepID: "step-network",
                priority: .normal,
                source: .userOverride,
                userOverride: .normal,
                localOnly: false
            )
        )

        XCTAssertEqual(decision.reviewDisposition, .pendingReview)
        XCTAssertTrue(decision.requiresExplicitApproval)
        XCTAssertFalse(decision.localOnly)
        XCTAssertFalse(decision.requiresAccount)
        XCTAssertTrue(decision.blockedFacts.contains { $0.localizedCaseInsensitiveContains("account") })
    }

    private func window(
        daysFromNow: Double,
        durationHours: Double = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> ProtectedStepPlacementWindow {
        let start = now.addingTimeInterval(daysFromNow * 24 * 60 * 60)
        return try XCTUnwrap(
            ProtectedStepPlacementWindow(
                start: start,
                end: start.addingTimeInterval(durationHours * 60 * 60)
            ),
            file: file,
            line: line
        )
    }
}
