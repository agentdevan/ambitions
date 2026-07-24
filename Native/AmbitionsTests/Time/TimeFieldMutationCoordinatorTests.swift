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

        XCTAssertEqual(command.operation, .placeStepInTime)
        XCTAssertEqual(command.target.stepID, "step.real-visible")
        XCTAssertEqual(command.target.goalID, "goal.real-visible")
        guard case let .schedule(schedule) = command.typedPayload,
              case let .placeStep(placement) = schedule.action else { return XCTFail("Expected typed placement") }
        XCTAssertEqual(placement?.candidateKind, .goalLinked)
        XCTAssertEqual(placement?.trigger, .userInitiated)
        XCTAssertEqual(placement?.explicitUserApproval, true)
        XCTAssertNotNil(placement?.start)
        XCTAssertNotNil(placement?.end)
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

        XCTAssertEqual(protect.operation, .protectTimeWindow)
        XCTAssertNotNil(protect.timePlacementCommandIntent?.start)
        XCTAssertNotNil(protect.timePlacementCommandIntent?.end)
        XCTAssertEqual(keepClear.operation, .correctTimeWindow)
        XCTAssertEqual(keepClear.timeCorrectionCommandIntent?.action, .keepClear)
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
