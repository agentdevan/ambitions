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

    func testReceiptHistorySearchFiltersSortsAndLimitsDeterministically() {
        let goal = object(.goal, "goal-1", label: "Launch app", sourceDomain: .goals)
        let capture = object(.capture, "capture-1", label: "Release checklist", sourceDomain: .capture)
        let planItem = object(.action, "plan-item-1", label: "Finish proof", sourceDomain: .plan)
        let older = receipt(
            id: "receipt-older",
            resultState: .attached,
            title: "Attached",
            occurredAt: "2026-04-26T09:00:00Z",
            affectedObjects: [goal, capture],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact-attached",
                    kind: .attachedCaptureToGoal,
                    object: capture,
                    summary: "Linked to goal."
                )
            ],
            sourceDomain: .capture,
            undoAvailability: .availableLocal
        )
        let matchingNewerB = receipt(
            id: "receipt-b",
            resultState: .completed,
            title: "Finished proof",
            occurredAt: "2026-04-26T12:00:00Z",
            affectedObjects: [goal, planItem],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact-completed-b",
                    kind: .completedAction,
                    object: planItem,
                    summary: "Saved proof for launch."
                )
            ],
            sourceDomain: .plan,
            undoAvailability: .requiresConfirmation
        )
        let matchingNewerA = receipt(
            id: "receipt-a",
            resultState: .completed,
            title: "Finished step",
            occurredAt: "2026-04-26T12:00:00Z",
            affectedObjects: [goal, planItem],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact-completed-a",
                    kind: .completedAction,
                    object: planItem,
                    summary: "Step done."
                )
            ],
            sourceDomain: .plan,
            undoAvailability: .requiresConfirmation
        )

        let projection = ActionReceiptProjection(receipts: [older, matchingNewerB, matchingNewerA])
        let search = projection.searchReceipts(
            ActionReceiptSearchQuery(
                startDate: "2026-04-26T10:00:00Z",
                actionKinds: [.completedAction],
                relatedGoalID: "goal-1",
                relatedPlanItemID: "plan-item-1",
                sourceDomains: [.plan],
                undoAvailability: [.requiresConfirmation],
                searchText: "saved proof",
                limit: 1,
                projectionDetail: .fullDetail
            )
        )

        XCTAssertEqual(search.totalMatchCount, 1)
        XCTAssertEqual(search.results.map(\.receiptID), ["receipt-b"])
        XCTAssertEqual(search.results.first?.title, "Finished proof")
        XCTAssertEqual(search.results.first?.undoLabel, "Undo available")
        XCTAssertEqual(search.results.first?.proofLabel, "Added to proof")
        XCTAssertTrue(search.localOnly)
    }

    func testReceiptHistorySearchUsesStableTieBreakOrdering() {
        let goal = object(.goal, "goal-1", label: "Launch app", sourceDomain: .goals)
        let receiptB = receipt(
            id: "receipt-b",
            resultState: .changed,
            title: "Changed B",
            occurredAt: "2026-04-26T12:00:00Z",
            affectedObjects: [goal],
            changedFacts: [
                ActionReceiptChangedFact(id: "fact-b", kind: .changedField, object: goal, summary: "Changed B.")
            ]
        )
        let receiptA = receipt(
            id: "receipt-a",
            resultState: .changed,
            title: "Changed A",
            occurredAt: "2026-04-26T12:00:00Z",
            affectedObjects: [goal],
            changedFacts: [
                ActionReceiptChangedFact(id: "fact-a", kind: .changedField, object: goal, summary: "Changed A.")
            ]
        )

        let results = ActionReceiptProjection(receipts: [receiptB, receiptA])
            .searchReceipts(ActionReceiptSearchQuery(projectionDetail: .fullDetail))
            .results

        XCTAssertEqual(results.map(\.receiptID), ["receipt-a", "receipt-b"])
    }

    func testReceiptProjectionLabelsOneStepGoalReferencesAsTasks() {
        let task = object(.oneStepGoal, "task-1", label: "Email portfolio", sourceDomain: .goals)
        let receipt = receipt(
            id: "receipt-task",
            resultState: .completed,
            title: "Task done",
            affectedObjects: [task],
            changedFacts: [
                ActionReceiptChangedFact(id: "fact-task-done", kind: .completedTask, object: task, summary: "Completed standalone task.")
            ],
            sourceDomain: .goals
        )

        let result = ActionReceiptProjection(receipts: [receipt])
            .searchReceipts(ActionReceiptSearchQuery(actionKinds: [.completedTask], projectionDetail: .fullDetail))
            .results
            .first

        XCTAssertEqual(result?.relatedObjectLabels, ["Linked to task"])
        XCTAssertEqual(result?.proofLabel, "Added to proof")
    }

    func testReceiptHistoryRedactsPrivateSensitiveAndMissingDetails() {
        let goal = object(.goal, "goal-private", label: "Private launch goal", sourceDomain: .goals)
        let privateReceipt = receipt(
            id: "receipt-private",
            resultState: .changed,
            title: "Private wording changed",
            affectedObjects: [goal],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact-private",
                    kind: .changedField,
                    object: goal,
                    fieldName: "title",
                    previousValueSummary: "Old private wording",
                    newValueSummary: "New private wording",
                    summary: "Private goal wording changed."
                )
            ],
            undoAvailability: .availableLocal
        )
        let missingDetail = receipt(
            id: "receipt-missing",
            resultState: .changed,
            title: "Changed",
            affectedObjects: [goal]
        )

        let projection = ActionReceiptProjection(receipts: [privateReceipt, missingDetail])
        let results = projection.searchReceipts(
            ActionReceiptSearchQuery(projectionDetail: .redacted),
            privacyByReceiptID: [
                "receipt-private": .sensitive,
                "receipt-missing": .unavailable
            ]
        ).results

        let privateResult = results.first { $0.receiptID == "receipt-private" }
        let missingResult = results.first { $0.receiptID == "receipt-missing" }

        XCTAssertEqual(privateResult?.title, "Private item")
        XCTAssertEqual(privateResult?.summary, "Private item")
        XCTAssertEqual(privateResult?.changedFactSummaries, ["Detail hidden"])
        XCTAssertEqual(privateResult?.hiddenDetailLabel, "Detail hidden")
        XCTAssertEqual(privateResult?.privacyLevel, .redacted)
        XCTAssertEqual(privateResult?.safeToShowInExternalSurface, false)
        XCTAssertEqual(missingResult?.title, "Detail hidden")
        XCTAssertEqual(missingResult?.summary, "Detail hidden")
        XCTAssertEqual(missingResult?.trustStatus, .missingDetail)
    }

    func testReceiptHistoryDistinguishesFullDetailFromRedactedProjection() {
        let capture = object(.capture, "capture-1", label: "Release checklist", sourceDomain: .capture)
        let receipt = receipt(
            id: "receipt-safe",
            resultState: .created,
            title: "Saved",
            affectedObjects: [capture],
            changedFacts: [
                ActionReceiptChangedFact(id: "fact-created", kind: .createdCapture, object: capture, summary: "Saved checklist.")
            ],
            sourceDomain: .capture,
            undoAvailability: .availableLocal
        )
        let projection = ActionReceiptProjection(receipts: [receipt])

        let full = projection.searchReceipts(ActionReceiptSearchQuery(projectionDetail: .fullDetail)).results.first
        let redacted = projection.searchReceipts(ActionReceiptSearchQuery(projectionDetail: .redacted)).results.first

        XCTAssertEqual(full?.title, "Saved")
        XCTAssertEqual(full?.summary, "Saved summary.")
        XCTAssertEqual(full?.privacyLevel, .safeToShow)
        XCTAssertEqual(full?.isRedacted, false)
        XCTAssertEqual(redacted?.title, "Private item")
        XCTAssertEqual(redacted?.summary, "Private item")
        XCTAssertEqual(redacted?.privacyLevel, .redacted)
        XCTAssertEqual(redacted?.isRedacted, true)
    }

    func testReceiptHistoryEmptySearchReturnsCalmLocalOnlyFallback() {
        let capture = object(.capture, "capture-1", label: "Release checklist", sourceDomain: .capture)
        let projection = ActionReceiptProjection(receipts: [
            receipt(
                id: "receipt-safe",
                resultState: .created,
                title: "Saved",
                affectedObjects: [capture],
                changedFacts: [
                    ActionReceiptChangedFact(id: "fact-created", kind: .createdCapture, object: capture, summary: "Saved checklist.")
                ]
            )
        ])

        let search = projection.searchReceipts(ActionReceiptSearchQuery(relatedGoalID: "missing-goal"))

        XCTAssertTrue(search.isEmpty)
        XCTAssertEqual(search.emptyTitle, "Nothing matched")
        XCTAssertEqual(search.emptyDetail, "Try a different filter.")
        XCTAssertTrue(search.localOnly)
    }

    func testClosureReceiptUsesNonPunitiveActionClosureLanguage() {
        let stepID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
        let occurrence = StepOccurrence(
            stepID: stepID,
            duration: DurationMetadata(plannedDuration: .seconds(1_800), source: .userSet),
            rigidity: .flexible,
            readiness: .ready,
            closureState: .awaitingClosure
        )

        let stillCounts = ActionReceipt.closureReceipt(
            id: "receipt-still-counts",
            occurrence: occurrence,
            outcome: .stillCounts,
            stepTitle: "Write the chorus",
            occurredAt: "2026-04-29T16:00:00Z",
            recordedAt: "2026-04-29T18:00:00Z",
            why: "User recorded a smaller version after the planned window."
        )
        let rescheduled = ActionReceipt.closureReceipt(
            id: "receipt-rescheduled",
            occurrence: occurrence,
            outcome: .moved,
            stepTitle: "Write the chorus",
            occurredAt: "2026-04-29T16:00:00Z"
        )
        let review = ActionReceipt.closureReceipt(
            id: "receipt-review",
            occurrence: occurrence,
            outcome: .awaitingClosure,
            stepTitle: "Write the chorus",
            occurredAt: "2026-04-29T16:00:00Z"
        )

        XCTAssertTrue(stillCounts.isWellFormed)
        XCTAssertEqual(stillCounts.title, "Still Counts")
        XCTAssertEqual(stillCounts.summary, "Still Counts · smaller version completed")
        XCTAssertEqual(stillCounts.resultState, .completed)
        XCTAssertEqual(stillCounts.undoAvailability, .requiresConfirmation)
        XCTAssertEqual(stillCounts.changedFacts.first?.newValueSummary, "Still Counts")
        XCTAssertEqual(rescheduled.title, "Rescheduled")
        XCTAssertEqual(rescheduled.resultState, .moved)
        XCTAssertEqual(review.title, "Needs a quick check")
        XCTAssertEqual(review.nextAction?.title, "Close the loop")

        let visibleCopy = [stillCounts.title, stillCounts.summary, rescheduled.title, review.title, review.summary].joined(separator: " ")
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("Overdue"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("Failed"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("Missed"))
        XCTAssertFalse(visibleCopy.localizedCaseInsensitiveContains("Behind"))
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
        changedFacts: [ActionReceiptChangedFact] = [],
        sourceDomain: ActionReceiptSourceDomain = .system,
        correctionAvailability: ActionReceiptCorrectionAvailability = .unavailable,
        undoAvailability: ActionReceiptUndoAvailability = .unavailable
    ) -> ActionReceipt {
        ActionReceipt(
            id: id,
            resultState: resultState,
            title: title,
            summary: "\(title) summary.",
            sourceDomain: sourceDomain,
            occurredAt: occurredAt,
            affectedObjects: affectedObjects,
            changedFacts: changedFacts,
            correctionAvailability: correctionAvailability,
            undoAvailability: undoAvailability
        )
    }
}
