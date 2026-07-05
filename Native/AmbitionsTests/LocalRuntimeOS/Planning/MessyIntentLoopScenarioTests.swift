@testable import Ambitions
import XCTest

final class MessyIntentLoopScenarioTests: XCTestCase {
    func testMessyIntentTravelsThroughCapturePlanTimeFitAndProofInspection() async throws {
        let now = Date(timeIntervalSince1970: 1_783_512_000)
        let capturedAt = DomainTimestamp.string(from: now)
        let inspectedAt = DomainTimestamp.string(from: now.addingTimeInterval(60))
        let captureRepository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(
            repository: captureRepository,
            idProvider: { "capture-messy-intent-proof" }
        )
        let eventLedger = InMemoryEventLedgerRepository()
        let commandRecords = InMemoryAmbitionsCommandExecutionRecordRepository()
        let runtimeEvents = InMemoryRuntimeEventStore()
        let executor = AmbitionsCommandExecutor(
            captureService: captureService,
            eventLedger: eventLedger,
            commandExecutionRecords: commandRecords,
            runtimeEvents: runtimeEvents
        )
        let command = AmbitionsCommand(
            id: "command-messy-intent-proof",
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(
                rawText: "  Need to prep the board update, ask Maya for numbers, and protect pickup before Friday.  ",
                deadlineText: "Friday",
                contextLens: .work,
                commitmentKind: .oneTime,
                priorityHints: AmbitionsCommandPriorityHints(importance: .high, urgency: .high, deadline: .high)
            ),
            createdAt: capturedAt,
            sourceSurface: "today"
        )

        let captureResult = await executor.execute(
            command,
            context: CommandExecutionContext(now: now, sourceSurface: "Today")
        )

        let fetchedCapture = try await captureRepository.capture(id: "capture-messy-intent-proof")
        let fetchedCommandRecord = try await commandRecords.fetchRecord(commandID: command.id)
        let fetchedRuntimeEvents = try await runtimeEvents.fetchEvents(matching: .commandID(command.id), limit: 1)
        let capture = try XCTUnwrap(fetchedCapture)
        let commandRecord = try XCTUnwrap(fetchedCommandRecord)
        let captureRuntimeEvent = try XCTUnwrap(fetchedRuntimeEvents.first)
        XCTAssertEqual(captureResult.status, .succeeded)
        XCTAssertEqual(capture.route, .captureInbox)
        XCTAssertEqual(capture.kind, .oneTimeCommitment)
        XCTAssertEqual(capture.rawText, "Need to prep the board update, ask Maya for numbers, and protect pickup before Friday.")
        XCTAssertEqual(captureResult.metadata["captureRoute"], CaptureRoute.captureInbox.rawValue)
        XCTAssertEqual(commandRecord.result.eventLedgerEntryIDs, ["ledger.command.command-messy-intent-proof"])
        XCTAssertEqual(captureRuntimeEvent.event.commandID, command.id)
        XCTAssertEqual(captureRuntimeEvent.event.kind, .commandExecution)

        let routeCommand = AmbitionsCommand(
            id: "command-messy-intent-proof-route-time",
            kind: .routeCommitment,
            source: .capture,
            target: AmbitionsCommandTarget(captureID: capture.id),
            payload: AmbitionsCommandPayload(
                deadlineText: "Friday",
                contextLens: .work,
                commitmentKind: .oneTime,
                priorityHints: AmbitionsCommandPriorityHints(importance: .high, urgency: .high, deadline: .high)
            ),
            createdAt: DomainTimestamp.string(from: now.addingTimeInterval(30))
        )
        let routeResult = await executor.execute(
            routeCommand,
            context: CommandExecutionContext(now: now.addingTimeInterval(30), sourceSurface: "Capture")
        )
        let fetchedRoutedCapture = try await captureRepository.capture(id: capture.id)
        let fetchedRouteCommandRecord = try await commandRecords.fetchRecord(commandID: routeCommand.id)
        let fetchedRouteRuntimeEvents = try await runtimeEvents.fetchEvents(matching: .commandID(routeCommand.id), limit: 1)
        let routedCapture = try XCTUnwrap(fetchedRoutedCapture)
        let routeCommandRecord = try XCTUnwrap(fetchedRouteCommandRecord)
        let routeRuntimeEvent = try XCTUnwrap(fetchedRouteRuntimeEvents.first)
        XCTAssertEqual(routeResult.status, .succeeded)
        XCTAssertEqual(routeResult.metadata["captureRoute"], CaptureRoute.timeSeed.rawValue)
        XCTAssertEqual(routedCapture.route, .timeSeed)
        XCTAssertEqual(routedCapture.kind, .oneTimeCommitment)
        XCTAssertEqual(routedCapture.deadlineText, "Friday")
        XCTAssertEqual(routeCommandRecord.command.id, routeCommand.id)
        XCTAssertEqual(routeRuntimeEvent.event.commandID, routeCommand.id)
        XCTAssertEqual(routeRuntimeEvent.event.kind, .commandExecution)

        let plan = GoalPathPlanner().plan(
            goalID: "goal-board-update-proof",
            title: routedCapture.rawText,
            steps: [
                PlanStep(
                    id: "step-request-maya-numbers",
                    title: "Ask Maya for the missing numbers",
                    summary: "Turn the dependency into a concrete request before drafting.",
                    type: .actionUnit,
                    pace: .untimed,
                    targetDate: "2026-07-08",
                    repeatEveryDays: 12,
                    evidenceHint: "Request sent to Maya.",
                    contextRequirements: ["Maya", "board update"]
                ),
                PlanStep(
                    id: "step-draft-board-update",
                    title: "Draft the board update",
                    summary: "Use the numbers and keep pickup protected.",
                    type: .actionUnit,
                    pace: .untimed,
                    targetDate: "2026-07-09",
                    repeatEveryDays: 25,
                    evidenceHint: "Draft saved for review.",
                    contextRequirements: ["numbers", "pickup protected"]
                ),
            ],
            generatedAt: capturedAt,
            deadlineTargetDate: "2026-07-10",
            proofBearingStepIDs: ["step-request-maya-numbers"]
        )
        let selectedStep = try XCTUnwrap(plan.selectedCandidate)
        XCTAssertTrue(plan.localOnly)
        XCTAssertTrue(plan.isReplayReady)
        XCTAssertEqual(plan.planningGraph.nodeIDs, ["step-request-maya-numbers", "step-draft-board-update"])
        XCTAssertTrue(plan.candidateField.sourceProvenance.contains(.goalIntentCompiler))
        XCTAssertEqual(plan.candidateField.deadlineTargetDate, "2026-07-10")

        let proposedStart = now.addingTimeInterval(2 * 24 * 60 * 60)
        let proposedWindow = try XCTUnwrap(ProtectedStepPlacementWindow(
            start: proposedStart,
            end: proposedStart.addingTimeInterval(25 * 60)
        ))
        let placementDecision = PlacementEngine().evaluate(
            request: TimePlacementRequest(
                commandID: command.id,
                now: now,
                stepID: selectedStep.id,
                title: selectedStep.title,
                originalWindow: nil,
                proposedWindow: proposedWindow,
                trigger: .automatic,
                explicitUserApproval: false,
                automationPolicy: .notMature,
                contextQuality: .sufficient,
                localOnly: true,
                priorityInput: PriorityPlacementInput(
                    stepID: selectedStep.id,
                    priority: .high,
                    source: .commandHint,
                    contextQuality: .sufficient,
                    localOnly: true
                )
            )
        )
        XCTAssertEqual(placementDecision.protectedPlacementDecision.kind, .blockedFromSilentMovement)
        XCTAssertTrue(placementDecision.requiresReviewBeforeMutation)
        XCTAssertFalse(placementDecision.canCommit)
        XCTAssertTrue(placementDecision.runtimeTrace.satisfiesRuntimeSpine)

        let inspectionCommand = AmbitionsCommand(
            id: "command-messy-intent-proof-inspection",
                kind: .completeAction,
                source: .today,
                target: AmbitionsCommandTarget(
                    goalID: plan.goalID,
                    captureID: routedCapture.id,
                    stepID: selectedStep.id,
                    destination: .today
                ),
                payload: AmbitionsCommandPayload(
                    title: "Request sent to Maya",
                    metadata: [
                        "originCommandID": command.id,
                        "routeCommandID": routeCommand.id,
                        "captureID": routedCapture.id,
                        "planID": plan.id,
                        "placementTraceID": placementDecision.runtimeTrace.id,
                    ]
            ),
            createdAt: inspectedAt,
            relations: AmbitionsCommandRelations(
                goalIDs: [plan.goalID],
                captureIDs: [routedCapture.id],
                eventLedgerEntryIDs: captureResult.eventLedgerEntryIDs
            )
        )
        let inspectionResult = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Messy intent produced an inspected proof-bearing step without moving protected time.",
            route: .today,
            target: inspectionCommand.target,
            eventLedgerEntryIDs: commandRecord.result.eventLedgerEntryIDs,
            metadata: [
                "originCommandID": command.id,
                "routeCommandID": routeCommand.id,
                "captureRoute": routedCapture.route.rawValue,
                "planID": plan.id,
                "placementDecision": placementDecision.protectedPlacementDecision.kind.rawValue,
            ]
        )
        let inspectionStore = InMemoryRuntimeEventStore()
        let outcome = try await RuntimeTransactionCoordinator(eventStore: inspectionStore).commit(
            command: inspectionCommand,
            beforeSnapshot: "messy-intent.captured.planned.placement-review",
            afterSnapshot: "messy-intent.proof-attached.protected-time-unchanged",
            targetSurface: .today,
            executionResult: inspectionResult,
            commandRecordID: "command.execution.\(inspectionCommand.id)",
            occurredAt: now.addingTimeInterval(60)
        )
        let fetchedInspectionEvents = try await inspectionStore.fetchEvents(matching: .commandID(inspectionCommand.id), limit: 1)
        let inspectionEvent = try XCTUnwrap(fetchedInspectionEvents.first)
        let receipt = ActionReceipt(
            id: outcome.receipt.receiptID,
            resultState: .attached,
            title: "Proof attached",
            summary: "Request sent to Maya; protected pickup time stayed unchanged for review.",
            sourceDomain: .today,
            occurredAt: inspectedAt,
            affectedObjects: [
                LifeGraphObjectReference(
                    kind: .step,
                    id: selectedStep.id,
                    parentContextID: plan.goalID,
                    label: selectedStep.title,
                    sourceDomain: .today
                ),
            ],
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact-proof-attached",
                    kind: .completedAction,
                    object: LifeGraphObjectReference(
                        kind: .step,
                        id: selectedStep.id,
                        parentContextID: plan.goalID,
                        label: selectedStep.title,
                        sourceDomain: .today
                    ),
                    summary: "Proof was attached to the selected step."
                ),
                ActionReceiptChangedFact(
                    id: "fact-protected-time-review",
                    kind: .noChange,
                    summary: "Protected pickup time was not silently moved."
                ),
            ],
            why: ActionReceiptWhyExplanation(
                body: "The messy intent was captured, routed to Time, planned into two local steps, held protected time for review, and attached proof locally.",
                eventLedgerEntryIDs: commandRecord.result.eventLedgerEntryIDs
            ),
            nextAction: ActionReceiptNextAction(
                kind: .openToday,
                title: "Open step",
                destination: .today
            ),
            undoAvailability: .availableLocal,
            sourceObject: LifeGraphObjectReference(
                kind: .capture,
                id: routedCapture.id,
                label: "Messy intent capture",
                sourceDomain: .capture
            )
        )
        let inspectionPlan = try InspectionCommitPlanner().plan(
            InspectionCommitInput(
                commandRecord: AmbitionsCommandExecutionRecord(
                    id: "command.execution.\(inspectionCommand.id)",
                    command: inspectionCommand,
                    result: inspectionResult.mergingMetadata(RuntimeTrustLineage(runtimeCommitReceipt: outcome.receipt).metadata),
                    recordedAt: inspectedAt
                ),
                runtimeEventEnvelope: inspectionEvent,
                runtimeCommitReceipt: outcome.receipt,
                receipt: receipt,
                proofRelevance: .countsAsProof
            ),
            plannedAt: inspectedAt
        )

        XCTAssertTrue(inspectionPlan.hasCompleteCommandEventProjectionReceiptReplayFlow)
        XCTAssertTrue(inspectionPlan.proofLedger.hasInspectableProof)
        XCTAssertTrue(inspectionPlan.proofLedger.hasRuntimeLineage)
        XCTAssertEqual(inspectionPlan.proofLedgerEntry.proofReference?.attachedObject.id, selectedStep.id)
        XCTAssertEqual(inspectionPlan.undoLedger.entry(receiptID: receipt.id)?.canUndoLocally, true)
        XCTAssertEqual(inspectionPlan.replayOutcome.decision, .replayExistingReceipt)
        XCTAssertTrue(inspectionPlan.sourceRecordLedger.separationReport.isSeparated)
    }
}
