import XCTest
@testable import Ambitions

@MainActor
final class TimeProtectedPlacementReviewTests: XCTestCase {
    private let now = ISO8601DateFormatter().date(from: "2027-02-19T12:20:00Z")!

    func testP2BBTimePlacementShowsProtectedReviewBeforeMutation() async throws {
        let state = PreviewTimeScenarios.seeded.withProtectedPlacementReviewCandidate(realPlacementCandidate())
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })
        let viewModel = TimeViewModel(state: .loaded(state))

        await requestProtectedPlacement(viewModel, mark: mark)

        let review = try XCTUnwrap(viewModel.protectedPlacementReview)
        XCTAssertEqual(review.stepTitle, "Draft the real proposal section")
        XCTAssertEqual(review.currentPlacementLabel, "Current placement stays unchanged")
        XCTAssertTrue(review.proposedPlacementLabel.isEmpty == false)
        XCTAssertEqual(review.reasonLabel, "This will move a Step inside the next seven days")
        XCTAssertEqual(review.decision.kind, .requiresExplicitApproval)
        XCTAssertEqual(review.priorityDecision.priority, .normal)
        XCTAssertTrue(review.priorityDecision.requiresExplicitApproval)
        XCTAssertFalse(review.priorityDecision.canBypassProtectedApproval)
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

    func testP2BBApproveProtectedReviewAppliesPlacementAfterExplicitAction() async throws {
        let state = PreviewTimeScenarios.seeded.withProtectedPlacementReviewCandidate(realPlacementCandidate())
        let committedState = PreviewTimeScenarios.seeded.withCommittedScheduledRow()
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })
        let viewModel = TimeViewModel(state: .loaded(state))

        await requestProtectedPlacement(viewModel, mark: mark)
        XCTAssertNotNil(viewModel.protectedPlacementReview)

        await viewModel.approveProtectedPlacementReview(
            now: now,
            runtimeClient: committedRuntimeClient(),
            service: StubTimeService(timeState: committedState, weeklyReviewState: PreviewTimeScenarios.weeklyReview),
            calendar: utcCalendar,
            timeZone: utcCalendar.timeZone
        )

        XCTAssertNil(viewModel.protectedPlacementReview)
        XCTAssertEqual(viewModel.protectedPlacementReviewOutcome, .moved)
        XCTAssertEqual(viewModel.visibleTimeMutation?.stageMutation.visibleUserFacingChange, "Step placed")
        XCTAssertEqual(viewModel.visibleTimeMutation?.stageMutation.receipt.receiptID, "runtime.receipt.time-placement")
        XCTAssertTrue(viewModel.visibleTimeMutation?.stageMutation.undoAvailability.isAvailable == true)
        XCTAssertFalse(viewModel.visibleTimeMutation?.stageMutation.accessibilityAnnouncement.message.isEmpty ?? true)
        guard case let .loaded(updatedState) = viewModel.state else {
            return XCTFail("Expected Time state to remain loaded.")
        }
        XCTAssertEqual(updatedState.lifeSuite.field.reading(for: .week).title, committedState.lifeSuite.field.reading(for: .week).title)
        XCTAssertEqual(updatedState.lifeSuite.field.placementCandidate?.id, committedState.lifeSuite.field.placementCandidate?.id)
        let scheduledRow = try XCTUnwrap(updatedState.lifeSuite.field.calendarRows.first { $0.kind == .scheduledStep })
        let committedScheduledRow = try XCTUnwrap(committedState.lifeSuite.field.calendarRows.first { $0.kind == .scheduledStep })
        XCTAssertEqual(scheduledRow.detail, committedScheduledRow.detail)
        XCTAssertEqual(scheduledRow.isOperational, committedScheduledRow.isOperational)
    }

    func testP2CBPriorityChangeUpdatesReviewStateWithoutApprovingPlacement() async throws {
        let state = PreviewTimeScenarios.seeded.withProtectedPlacementReviewCandidate(realPlacementCandidate())
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })
        let viewModel = TimeViewModel(state: .loaded(state))

        await requestProtectedPlacement(viewModel, mark: mark)
        XCTAssertEqual(viewModel.protectedPlacementReview?.priorityDecision.priority, .normal)

        viewModel.updateProtectedPlacementPriority(.high)

        let review = try XCTUnwrap(viewModel.protectedPlacementReview)
        XCTAssertEqual(review.priorityDecision.priority, .high)
        XCTAssertEqual(review.priorityDecision.userOverride, .high)
        XCTAssertTrue(review.priorityDecision.isUserOverride)
        XCTAssertTrue(review.priorityDecision.requiresExplicitApproval)
        XCTAssertFalse(review.priorityDecision.canBypassProtectedApproval)
        XCTAssertNil(viewModel.visibleTimeMutation)
        XCTAssertNil(viewModel.protectedPlacementReviewOutcome)
        XCTAssertTrue(review.priorityDecision.reviewNote.contains("still needs approval"))

        guard case let .loaded(updatedState) = viewModel.state else {
            return XCTFail("Expected Time state to remain loaded.")
        }
        XCTAssertEqual(
            updatedState.lifeSuite.field.reading(for: .week).title,
            state.lifeSuite.field.reading(for: .week).title
        )
    }

    func testP2BBKeepProtectedReviewLeavesPlacementUnchanged() async throws {
        let state = PreviewTimeScenarios.seeded.withProtectedPlacementReviewCandidate(realPlacementCandidate())
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })
        let viewModel = TimeViewModel(state: .loaded(state))

        await requestProtectedPlacement(viewModel, mark: mark)
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

    func testP2BBReviewAccessibilityCopyIsPlainAndNonInternal() async throws {
        let state = PreviewTimeScenarios.seeded.withProtectedPlacementReviewCandidate(realPlacementCandidate())
        let mark = try XCTUnwrap(state.lifeSuite.field.semanticMarks.first { $0.kind == .freeTimeQuality })
        let viewModel = TimeViewModel(state: .loaded(state))

        await requestProtectedPlacement(viewModel, mark: mark)

        let review = try XCTUnwrap(viewModel.protectedPlacementReview)
        let copy = [
            "Review change",
            "This moves a Step inside the next seven days. Ambitions will not move it without approval.",
            "Priority",
            "Low",
            "Normal",
            "High",
            "Move it",
            "Keep as is",
            review.accessibilityValue
        ].joined(separator: " ")

        XCTAssertTrue(copy.contains("Draft the real proposal section"))
        XCTAssertTrue(copy.contains("Current placement"))
        XCTAssertTrue(copy.contains("Proposed placement"))
        XCTAssertTrue(copy.contains("Priority: Normal"))
        XCTAssertTrue(copy.contains("Available priority choices: Low, Normal, High"))
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

    private var utcCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    private func requestProtectedPlacement(_ viewModel: TimeViewModel, mark: LifeShapeSemanticMark) async {
        await viewModel.performLifeShapeMutation(
            .placeStep,
            selectedMark: mark,
            now: now,
            runtimeClient: committedRuntimeClient(),
            service: StubTimeService(timeState: PreviewTimeScenarios.seeded, weeklyReviewState: PreviewTimeScenarios.weeklyReview),
            calendar: utcCalendar,
            timeZone: utcCalendar.timeZone
        )
    }

    private func committedRuntimeClient() -> RuntimeCommandClient {
        RuntimeCommandClient(
            execute: { command, _ in
                AmbitionsCommandExecutionResult(
                    status: .succeeded,
                    summary: "Step placed in Time.",
                    route: .time,
                    target: command.target,
                    metadata: [
                        "runtimeReceiptID": "runtime.receipt.time-placement",
                        "runtimeProjectionStoreStatus": "saved",
                        "timeMaterialization": "saved_post_authority",
                        "runtimeMaterializedProjectionCursorIDs": "time",
                        "runtimeMaterializedProjectionCursorSequences": "7",
                        "runtimeMaterializedProjectionCursorChecksums": "checksum-time-7",
                    ]
                )
            },
            projection: { request in
                guard request == .time else { throw RuntimeProjectionClientError.projectionUnavailable(request) }
                return RuntimeProjectionSnapshot(
                    projectionID: "time",
                    payload: Data("{}".utf8),
                    eventSequence: 7,
                    cursorChecksum: "checksum-time-7",
                    payloadChecksum: "checksum-time-7",
                    materializedAt: "2027-02-19T12:20:00Z"
                )
            }
        )
    }
}

private extension TimeSurfaceState {
    func withCommittedScheduledRow() -> TimeSurfaceState {
        let scheduledRow = TimeCalendarRow(
            id: "time.calendar.scheduled-step",
            kind: .scheduledStep,
            title: "Scheduled Step",
            value: "Scheduled, 1:00 PM",
            detail: "Draft the real proposal section. Saved locally in Life Calendar.",
            visualState: .selected,
            isOperational: true
        )
        let field = LifeShapeFieldState(
            defaultHorizon: lifeSuite.field.defaultHorizon,
            capacityFit: lifeSuite.field.capacityFit,
            segments: lifeSuite.field.segments,
            semanticMarks: lifeSuite.field.semanticMarks,
            renderState: lifeSuite.field.renderState,
            readings: lifeSuite.field.readings,
            placementCandidate: nil,
            placementUnavailableReason: lifeSuite.field.placementUnavailableReason,
            calendarRows: lifeSuite.field.calendarRows.filter { $0.kind != .scheduledStep } + [scheduledRow],
            sourceState: lifeSuite.field.sourceState,
            reflowProposal: lifeSuite.field.reflowProposal,
            receipt: lifeSuite.field.receipt,
            continuityDockItems: lifeSuite.field.continuityDockItems
        )
        let suite = TimeLifeSuiteState(
            title: lifeSuite.title,
            subtitle: lifeSuite.subtitle,
            shapes: lifeSuite.shapes,
            field: field,
            drillDown: lifeSuite.drillDown,
            calendarBoundaryLabel: lifeSuite.calendarBoundaryLabel,
            manualFallbackLabel: lifeSuite.manualFallbackLabel,
            trustLabel: lifeSuite.trustLabel
        )
        return replacing(lifeSuite: suite)
    }
}
