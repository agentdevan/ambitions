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

    func testPlaceStepPreparesDurableRuntimeCommandFromRealCandidate() throws {
        let state = PreviewTimeScenarios.seeded.withProtectedPlacementReviewCandidate(realPlacementCandidate())
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })

        let command = try TimeFieldMutationCoordinator.prepareCommand(
            .placeStep,
            in: state,
            selectedMark: mark,
            now: now
        )

        XCTAssertEqual(command.kind, .placeStepInTime)
        XCTAssertEqual(command.target.stepID, "step.real-visible")
        XCTAssertEqual(command.target.goalID, "goal.real-visible")
        XCTAssertEqual(command.payload.metadata["placementCandidateKind"], TimePlacementCandidateKind.goalLinked.rawValue)
        XCTAssertEqual(command.payload.metadata["placementTrigger"], ProtectedStepPlacementTrigger.userInitiated.rawValue)
        XCTAssertEqual(command.payload.metadata["explicitUserApproval"], "true")
        XCTAssertNotNil(command.payload.metadata["startAt"])
        XCTAssertNotNil(command.payload.metadata["endAt"])
        XCTAssertEqual(command.validationState, .valid)
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
            guard case let .protectedPlacementRequiresApproval(decision) = error as? TimeFieldMutationError else {
                return XCTFail("Expected protected placement decision, got \(error)")
            }
            XCTAssertEqual(decision.kind, .blockedFromSilentMovement)
            XCTAssertEqual(decision.trigger, .automatic)
            XCTAssertFalse(decision.canApplySilently)
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
            guard case let .protectedPlacementRequiresApproval(decision) = error as? TimeFieldMutationError else {
                return XCTFail("Expected protected placement decision, got \(error)")
            }
            XCTAssertEqual(decision.kind, .requiresExplicitApproval)
            XCTAssertTrue(decision.requiresExplicitApproval)
            XCTAssertFalse(decision.canApplyWithExplicitAction)
        }
    }

    func testProtectAndCorrectionCommandsCarryExactRuntimeSemantics() throws {
        let state = PreviewTimeScenarios.seeded
        let protectedMark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .protectedTime })
        let openMark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .executionLanes })

        let protect = try TimeFieldMutationCoordinator.prepareCommand(
            .protectWindow,
            in: state,
            selectedMark: protectedMark,
            now: now
        )
        let keepClear = try TimeFieldMutationCoordinator.prepareCommand(
            .keepClear,
            in: state,
            selectedMark: openMark,
            now: now
        )

        XCTAssertEqual(protect.kind, .protectTimeWindow)
        XCTAssertNotNil(protect.payload.metadata["startAt"])
        XCTAssertNotNil(protect.payload.metadata["endAt"])
        XCTAssertEqual(keepClear.kind, .correctTimeWindow)
        XCTAssertEqual(keepClear.payload.metadata["correctionKind"], TimeMutationActionKind.keepClear.rawValue)
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
