import XCTest
@testable import Ambitions

final class TimeFieldMutationCoordinatorTests: XCTestCase {
    private let now = ISO8601DateFormatter().date(from: "2027-02-19T12:20:00Z")!

    func testPlaceStepRequiresRealEligibleStep() throws {
        let state = PreviewTimeScenarios.seeded
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })

        XCTAssertThrowsError(
            try TimeFieldMutationCoordinator.prepareCommand(.placeStep, in: state, selectedMark: mark, now: now)
        ) { error in
            XCTAssertEqual(error as? TimeFieldMutationError, .missingEligibleStep)
        }
    }

    func testPlaceStepFailsClosedUntilTheRuntimeSuppliesAnExactScheduleRevision() throws {
        let state = PreviewTimeScenarios.seeded.withProtectedPlacementReviewCandidate(realPlacementCandidate())
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })

        XCTAssertThrowsError(
            try TimeFieldMutationCoordinator.prepareCommand(
                .placeStep,
                in: state,
                selectedMark: mark,
                now: now
            )
        ) { error in
            XCTAssertEqual(error as? TimeFieldMutationError, .revisionAuthorityUnavailable)
        }
    }

    func testAutomaticProtectedPlacementStopsBeforeCommandExecution() throws {
        let state = PreviewTimeScenarios.seeded.withProtectedPlacementReviewCandidate(realPlacementCandidate())
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })

        XCTAssertThrowsError(
            try TimeFieldMutationCoordinator.prepareCommand(
                .placeStep,
                in: state,
                selectedMark: mark,
                now: now,
                actor: .system,
                explicitProtectedPlacementApproval: false
            )
        ) { error in
            XCTAssertEqual(error as? TimeFieldMutationError, .revisionAuthorityUnavailable)
        }
    }

    func testUserProtectedPlacementRequiresExplicitApproval() throws {
        let state = PreviewTimeScenarios.seeded.withProtectedPlacementReviewCandidate(realPlacementCandidate())
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })

        XCTAssertThrowsError(
            try TimeFieldMutationCoordinator.prepareCommand(
                .placeStep,
                in: state,
                selectedMark: mark,
                now: now,
                actor: .user,
                explicitProtectedPlacementApproval: false
            )
        ) { error in
            XCTAssertEqual(error as? TimeFieldMutationError, .revisionAuthorityUnavailable)
        }
    }

    func testProtectAndCorrectionRefusePresentationDerivedRevisionEvidence() throws {
        let state = PreviewTimeScenarios.seeded
        let protectedMark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .protectedTime })
        let openMark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .executionLanes })

        let cases: [(TimeFieldMutationAction, LifeShapeSemanticMark)] = [
            (.protectWindow, protectedMark),
            (.keepClear, openMark),
        ]
        for (action, mark) in cases {
            XCTAssertThrowsError(
                try TimeFieldMutationCoordinator.prepareCommand(
                    action,
                    in: state,
                    selectedMark: mark,
                    now: now
                )
            ) { error in
                XCTAssertEqual(error as? TimeFieldMutationError, .revisionAuthorityUnavailable)
            }
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
