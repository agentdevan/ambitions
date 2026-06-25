import XCTest
@testable import Ambitions

@MainActor
final class TimeProtectedPlacementReviewTests: XCTestCase {
    private let now = ISO8601DateFormatter().date(from: "2027-02-19T12:20:00Z")!

    func testP2BBTimePlacementShowsProtectedReviewBeforeMutation() throws {
        let state = PreviewTimeScenarios.seeded.withProtectedPlacementReviewCandidate(realPlacementCandidate())
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })
        let viewModel = TimeViewModel(state: .loaded(state))

        viewModel.performLifeShapeMutation(.placeStep, selectedMark: mark, now: now)

        let review = try XCTUnwrap(viewModel.protectedPlacementReview)
        XCTAssertEqual(review.stepTitle, "Draft the real proposal section")
        XCTAssertEqual(review.currentPlacementLabel, "Current placement stays unchanged")
        XCTAssertTrue(review.proposedPlacementLabel.isEmpty == false)
        XCTAssertEqual(review.reasonLabel, "This will move a Step inside the next seven days")
        XCTAssertEqual(review.decision.kind, .requiresExplicitApproval)
        XCTAssertNil(viewModel.visibleTimeMutation)
        XCTAssertNil(viewModel.protectedPlacementReviewOutcome)

        guard case let .loaded(updatedState) = viewModel.state else {
            return XCTFail("Expected Time state to remain loaded.")
        }
        XCTAssertEqual(
            updatedState.lifeSuite.field.reading(for: .week).title,
            state.lifeSuite.field.reading(for: .week).title
        )
    }

    func testP2BBApproveProtectedReviewAppliesPlacementAfterExplicitAction() throws {
        let state = PreviewTimeScenarios.seeded.withProtectedPlacementReviewCandidate(realPlacementCandidate())
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })
        let viewModel = TimeViewModel(state: .loaded(state))

        viewModel.performLifeShapeMutation(.placeStep, selectedMark: mark, now: now)
        XCTAssertNotNil(viewModel.protectedPlacementReview)

        viewModel.approveProtectedPlacementReview(now: now)

        XCTAssertNil(viewModel.protectedPlacementReview)
        XCTAssertEqual(viewModel.protectedPlacementReviewOutcome, .moved)
        XCTAssertEqual(viewModel.visibleTimeMutation?.stageMutation.visibleUserFacingChange, "Step placed")
        guard case let .loaded(updatedState) = viewModel.state else {
            return XCTFail("Expected Time state to remain loaded.")
        }
        XCTAssertNotEqual(
            updatedState.lifeSuite.field.reading(for: .week).title,
            state.lifeSuite.field.reading(for: .week).title
        )
    }

    func testP2BBKeepProtectedReviewLeavesPlacementUnchanged() throws {
        let state = PreviewTimeScenarios.seeded.withProtectedPlacementReviewCandidate(realPlacementCandidate())
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })
        let viewModel = TimeViewModel(state: .loaded(state))

        viewModel.performLifeShapeMutation(.placeStep, selectedMark: mark, now: now)
        XCTAssertNotNil(viewModel.protectedPlacementReview)

        viewModel.keepProtectedPlacementReview()

        XCTAssertNil(viewModel.protectedPlacementReview)
        XCTAssertEqual(viewModel.protectedPlacementReviewOutcome, .kept)
        XCTAssertNil(viewModel.visibleTimeMutation)
        guard case let .loaded(updatedState) = viewModel.state else {
            return XCTFail("Expected Time state to remain loaded.")
        }
        XCTAssertEqual(
            updatedState.lifeSuite.field.reading(for: .week).title,
            state.lifeSuite.field.reading(for: .week).title
        )
    }

    func testP2BBReviewAccessibilityCopyIsPlainAndNonInternal() throws {
        let state = PreviewTimeScenarios.seeded.withProtectedPlacementReviewCandidate(realPlacementCandidate())
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })
        let viewModel = TimeViewModel(state: .loaded(state))

        viewModel.performLifeShapeMutation(.placeStep, selectedMark: mark, now: now)

        let review = try XCTUnwrap(viewModel.protectedPlacementReview)
        let copy = [
            "Review change",
            "This moves a Step inside the next seven days. Ambitions will not move it without approval.",
            "Move it",
            "Keep as is",
            review.accessibilityValue
        ].joined(separator: " ")

        XCTAssertTrue(copy.contains("Draft the real proposal section"))
        XCTAssertTrue(copy.contains("Current placement"))
        XCTAssertTrue(copy.contains("Proposed placement"))
        for forbidden in ["reflow", "runtime", "mutation", "pipeline", "policy", "source unavailable", "proof seam", "route reveal", "blocked-pending-model", "optimization", "AI recommends", "overdue", "failed", "streak", "productivity"] {
            XCTAssertFalse(copy.localizedCaseInsensitiveContains(forbidden), "Review copy should not expose \(forbidden).")
        }
    }

    private func realPlacementCandidate() -> TimePlacementCandidate {
        TimePlacementCandidate(
            id: "time.placement.goal.real-visible.step.real-visible",
            stepID: "step.real-visible",
            goalID: "goal.real-visible",
            title: "Draft the real proposal section",
            detail: "Goal-linked Step selected before placement.",
            durationMinutes: 30,
            sourceLabel: "Visible goal",
            kind: .goalLinked
        )
    }
}
