import XCTest
@testable import Ambitions

final class ActionClosureReceiptModelsTests: XCTestCase {
    func testResultStateUndoAndCorrectionTaxonomiesCoverBatch80Concepts() {
        XCTAssertEqual(
            Set(ActionReceiptResultState.allCases),
            [
                .created,
                .changed,
                .scheduled,
                .moved,
                .attached,
                .detached,
                .exportedPrepared,
                .draftedPrepared,
                .completed,
                .failedSafely,
                .needsConfirmation,
                .noOp,
                .undoAvailable,
                .undoUnavailable,
                .correctionAvailable
            ]
        )
        XCTAssertEqual(
            Set(ActionReceiptUndoAvailability.allCases),
            [.unavailable, .availableLocal, .requiresConfirmation, .unsafe, .notSupportedYet]
        )
        XCTAssertEqual(
            Set(ActionReceiptCorrectionAvailability.allCases),
            [.unavailable, .available, .availableWithReason, .notSupportedYet]
        )
    }

    func testReceiptNormalizesAffectedObjectsAndProvidesDisplaySummary() {
        let goal = object(.goal, "goal-1", label: "Launch app", sourceDomain: .goals)
        let capture = object(.capture, "capture-1", label: "Release checklist", sourceDomain: .capture)
        let receipt = ActionReceipt(
            id: " receipt-1 ",
            resultState: .attached,
            title: " Capture attached ",
            summary: " Attached release checklist to Launch app. ",
            sourceDomain: .capture,
            occurredAt: "2026-04-26T12:00:00Z",
            affectedObjects: [capture, goal, capture],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact-1",
                    kind: .attachedCaptureToGoal,
                    object: capture,
                    summary: "Attached capture to goal."
                )
            ],
            why: ActionReceiptWhyExplanation(body: "The user chose the goal attachment."),
            nextAction: ActionReceiptNextAction(kind: .reviewGoal, title: "Review goal", destination: .goalDetail),
            correctionAvailability: .availableWithReason,
            undoAvailability: .availableLocal
        )

        XCTAssertTrue(receipt.isWellFormed)
        XCTAssertEqual(receipt.id, "receipt-1")
        XCTAssertEqual(receipt.title, "Capture attached")
        XCTAssertEqual(receipt.summary, "Attached release checklist to Launch app.")
        XCTAssertEqual(receipt.affectedObjects.map(\.id), ["capture-1", "goal-1"])
        XCTAssertEqual(receipt.displaySummary.nextActionTitle, "Review goal")
        XCTAssertEqual(receipt.lifeGraphObjectReference.kind, .receipt)
    }

    func testProjectionRejectsMalformedReceiptsAndDedupesDeterministically() {
        let actionA = object(.action, "action-a", label: "Ship build", sourceDomain: .goalEngine)
        let actionB = object(.action, "action-b", label: "Audit launch copy", sourceDomain: .goalEngine)
        let older = receipt(id: "receipt-a", resultState: .created, title: "A", occurredAt: "2026-04-26T11:00:00Z", affectedObjects: [actionA])
        let newer = receipt(id: "receipt-b", resultState: .completed, title: "B", occurredAt: "2026-04-26T12:00:00Z", affectedObjects: [actionB])
        let duplicateOlder = receipt(id: "receipt-a", resultState: .changed, title: "A copy", occurredAt: "2026-04-26T13:00:00Z", affectedObjects: [actionA])
        let malformed = ActionReceipt(
            id: "bad",
            resultState: .created,
            title: "Bad",
            summary: "Missing affected object.",
            sourceDomain: .system,
            occurredAt: "2026-04-26T14:00:00Z",
            affectedObjects: []
        )

        let projection = ActionReceiptProjection(receipts: [older, malformed, newer, duplicateOlder])

        XCTAssertEqual(projection.receipts.map(\.id), ["receipt-b", "receipt-a"])
        XCTAssertEqual(projection.rejectedReceiptIDs, ["bad", "receipt-a"])
        XCTAssertEqual(projection.displaySummaries(limit: 1).map(\.id), ["receipt-b"])
    }

    func testProjectionListsByObjectResultCorrectionAndUndoAvailability() {
        let goal = object(.goal, "goal-1", label: "Launch app", sourceDomain: .goals)
        let capture = object(.capture, "capture-1", label: "Release checklist", sourceDomain: .capture)
        let created = receipt(
            id: "receipt-created",
            resultState: .created,
            title: "Capture created",
            affectedObjects: [capture],
            correctionAvailability: .available,
            undoAvailability: .availableLocal
        )
        let attached = receipt(
            id: "receipt-attached",
            resultState: .attached,
            title: "Capture attached",
            affectedObjects: [capture, goal],
            correctionAvailability: .unavailable,
            undoAvailability: .unavailable
        )
        let noOp = receipt(
            id: "receipt-no-op",
            resultState: .noOp,
            title: "Nothing changed",
            affectedObjects: [goal],
            correctionAvailability: .unavailable,
            undoAvailability: .notSupportedYet
        )

        let projection = ActionReceiptProjection(receipts: [noOp, attached, created])

        XCTAssertEqual(projection.receipts(for: capture).map(\.id), ["receipt-attached", "receipt-created"])
        XCTAssertEqual(projection.receipts(resultState: .attached).map(\.id), ["receipt-attached"])
        XCTAssertEqual(projection.correctionAvailableReceipts().map(\.id), ["receipt-created"])
        XCTAssertEqual(projection.undoAvailableReceipts().map(\.id), ["receipt-created"])
    }

    func testReceiptsProjectIntoLifeGraphRelationships() {
        let goal = object(.goal, "goal-1", label: "Launch app", sourceDomain: .goals)
        let capture = object(.capture, "capture-1", label: "Release checklist", sourceDomain: .capture)
        let receipt = ActionReceipt(
            id: "receipt-attach",
            resultState: .attached,
            title: "Capture attached",
            summary: "Attached release checklist.",
            sourceDomain: .capture,
            occurredAt: "2026-04-26T12:00:00Z",
            affectedObjects: [capture, goal],
            why: ActionReceiptWhyExplanation(body: "The user confirmed this destination."),
            correctionAvailability: .availableWithReason,
            undoAvailability: .availableLocal,
            sourceObject: capture
        )

        let projection = ActionReceiptProjection(receipts: [receipt])
        let receiptObject = receipt.lifeGraphObjectReference

        XCTAssertEqual(projection.lifeGraphProjection.relatedObjects(from: receiptObject, kind: .explains).map(\.id), ["capture-1", "goal-1"])
        XCTAssertEqual(projection.lifeGraphProjection.relatedObjects(from: receiptObject, kind: .corrects).map(\.id), ["capture-1", "goal-1"])
        XCTAssertEqual(projection.lifeGraphProjection.relatedObjects(from: receiptObject, kind: .createdFrom).map(\.id), ["capture-1"])
        XCTAssertEqual(projection.relationshipProjection(for: goal).relationships.map(\.missionControlLane), [.receipts, .receipts])
    }

    func testSafeFailureRequiresExplicitFailureAndUnchangedFacts() {
        let capture = object(.capture, "capture-1", label: "Release checklist", sourceDomain: .capture)
        let malformed = ActionReceipt(
            id: "receipt-bad-failure",
            resultState: .failedSafely,
            title: "Action failed",
            summary: "Calendar write was not available.",
            sourceDomain: .plan,
            occurredAt: "2026-04-26T12:00:00Z",
            affectedObjects: [capture],
            safetyState: .safeFailure
        )
        let safe = ActionReceipt(
            id: "receipt-safe-failure",
            resultState: .failedSafely,
            title: "Action did not change anything",
            summary: "Calendar write was not available.",
            sourceDomain: .plan,
            occurredAt: "2026-04-26T12:01:00Z",
            affectedObjects: [capture],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact-failed",
                    kind: .failedSafely,
                    object: capture,
                    summary: "No calendar block was written."
                )
            ],
            correctionAvailability: .availableWithReason,
            undoAvailability: .unavailable,
            safetyState: .safeFailure,
            safeFailure: ActionReceiptSafeFailure(
                whatFailed: "Calendar write",
                whyFailed: "Plan-owned writer was unavailable.",
                unchangedFacts: ["No calendar data was changed.", "No plan item was moved."],
                nextSafeAction: ActionReceiptNextAction(kind: .openPlan, title: "Open Plan", destination: .plan)
            )
        )

        let projection = ActionReceiptProjection(receipts: [malformed, safe])

        XCTAssertEqual(projection.receipts.map(\.id), ["receipt-safe-failure"])
        XCTAssertEqual(projection.rejectedReceiptIDs, ["receipt-bad-failure"])
        XCTAssertEqual(safe.safeFailure?.unchangedFacts, ["No calendar data was changed.", "No plan item was moved."])
    }

    func testCommandResultAdapterCreatesTruthfulReceiptWithoutExecutingUndo() {
        let command = AmbitionsCommand(
            id: "command-capture",
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "Release checklist"),
            createdAt: "2026-04-26T12:00:00Z",
            relations: AmbitionsCommandRelations(recommendationExplanationIDs: ["explanation-1"])
        )
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Capture saved through the shared command pipeline.",
            route: .capturesInbox,
            target: AmbitionsCommandTarget(captureID: "capture-1", destination: .capturesInbox),
            eventLedgerEntryIDs: ["ledger-1"]
        )

        let receipt = ActionReceipt.fromCommandResult(
            command: command,
            result: result,
            occurredAt: "2026-04-26T12:01:00Z"
        )

        XCTAssertEqual(receipt.id, "receipt.command.command-capture")
        XCTAssertEqual(receipt.resultState, .created)
        XCTAssertEqual(receipt.affectedObjects.map(\.kind), [.capture])
        XCTAssertEqual(receipt.changedFacts.map(\.kind), [.createdCapture])
        XCTAssertEqual(receipt.undoAvailability, .availableLocal)
        XCTAssertEqual(receipt.correctionAvailability, .availableWithReason)
        XCTAssertEqual(receipt.why?.eventLedgerEntryIDs, ["ledger-1"])
        XCTAssertEqual(receipt.why?.recommendationExplanationIDs, ["explanation-1"])
        XCTAssertEqual(receipt.nextAction?.kind, .dismiss)
    }

    func testCommandResultAdapterConvertsUnsupportedCommandToSafeFailureReceipt() {
        let command = AmbitionsCommand(
            id: "command-schedule",
            kind: .scheduleItem,
            source: .plan,
            target: AmbitionsCommandTarget(captureID: "capture-1"),
            payload: AmbitionsCommandPayload(title: "Schedule work block", metadata: ["calendarWriteIntent": "true"]),
            createdAt: "2026-04-26T12:00:00Z"
        )
        let result = AmbitionsCommandExecutionResult(
            status: .unsupported,
            summary: "Calendar write intents require explicit confirmation.",
            target: command.target,
            metadata: ["blockedBy": "plan_calendar_writer_required"]
        )

        let receipt = ActionReceipt.fromCommandResult(
            command: command,
            result: result,
            occurredAt: "2026-04-26T12:01:00Z"
        )

        XCTAssertTrue(receipt.isWellFormed)
        XCTAssertEqual(receipt.resultState, .failedSafely)
        XCTAssertEqual(receipt.safetyState, .safeFailure)
        XCTAssertEqual(receipt.undoAvailability, .unavailable)
        XCTAssertEqual(receipt.correctionAvailability, .availableWithReason)
        XCTAssertEqual(receipt.safeFailure?.whatFailed, "Action did not change anything")
        XCTAssertEqual(receipt.safeFailure?.whyFailed, "plan_calendar_writer_required")
        XCTAssertEqual(receipt.safeFailure?.unchangedFacts, ["No calendar, export, sync, external surface, or unsupported app data was changed."])
    }
}

private extension ActionClosureReceiptModelsTests {
    func object(
        _ kind: LifeGraphObjectKind,
        _ id: String,
        label: String,
        sourceDomain: LifeGraphSourceDomain? = nil
    ) -> LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: kind,
            id: id,
            label: label,
            sourceDomain: sourceDomain
        )
    }

    func receipt(
        id: String,
        resultState: ActionReceiptResultState,
        title: String,
        occurredAt: String = "2026-04-26T12:00:00Z",
        affectedObjects: [LifeGraphObjectReference],
        correctionAvailability: ActionReceiptCorrectionAvailability = .unavailable,
        undoAvailability: ActionReceiptUndoAvailability = .unavailable
    ) -> ActionReceipt {
        ActionReceipt(
            id: id,
            resultState: resultState,
            title: title,
            summary: "\(title) summary.",
            sourceDomain: .system,
            occurredAt: occurredAt,
            affectedObjects: affectedObjects,
            correctionAvailability: correctionAvailability,
            undoAvailability: undoAvailability
        )
    }
}
