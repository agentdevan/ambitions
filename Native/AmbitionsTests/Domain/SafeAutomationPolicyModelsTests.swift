import XCTest
@testable import Ambitions

final class SafeAutomationPolicyModelsTests: XCTestCase {
    func testTaxonomiesCoverBatch81RequiredConcepts() {
        XCTAssertEqual(
            Set(SafeAutomationActionKind.allCases),
            [
                .createCapture,
                .routeCapture,
                .attachToGoal,
                .detachFromGoal,
                .archiveItem,
                .unarchiveItem,
                .markWaiting,
                .markDone,
                .moveActionLater,
                .changePriority,
                .changeDeadline,
                .changePlanWindow,
                .shrinkAction,
                .splitAction,
                .dropAction,
                .deferAction,
                .prepareCalendarBlock,
                .writeCalendarBlock,
                .prepareExport,
                .performExport,
                .prepareSyncResolution,
                .applySyncResolution,
                .deleteObject,
                .forgetMemory,
                .externalCommand,
                .correctRecommendation,
                .editLocalNote,
                .dismissSuggestion,
                .noOp
            ]
        )
        XCTAssertEqual(
            Set(SafeAutomationPermissionLevel.allCases),
            [.suggestOnly, .prepareDraft, .requiresConfirmation, .executeLocalOnly, .neverAutomate, .notSupportedYet]
        )
        XCTAssertEqual(
            Set(SafeAutomationConfirmationRequirement.allCases),
            [.notRequired, .required, .requiredForExternalEffect, .requiredForDestructiveChange, .requiredForBroadReflow, .notAllowed]
        )
        XCTAssertEqual(
            Set(SafeAutomationSafetyClassification.allCases),
            [.safeLocal, .reversibleLocal, .confirmationGated, .externalEffect, .destructive, .privacySensitive, .broadPlanMutation, .unsupported, .unsafe]
        )
        XCTAssertEqual(
            Set(SafeAutomationUndoRule.allCases),
            [.safeLocalUndo, .confirmationRequiredUndo, .externalUndoUnavailable, .destructiveUndoUnsafe, .notUndoable, .notSupportedYet]
        )
    }

    func testSafeLocalActionAllowsFutureLocalExecutionAndUndoWithoutExecutingAnything() {
        let capture = object(.capture, "capture-1", sourceDomain: .capture)
        let decision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(
                kind: .archiveItem,
                sourceDomain: .capture,
                targetObjects: [capture]
            )
        )

        XCTAssertEqual(decision.permissionLevel, .executeLocalOnly)
        XCTAssertEqual(decision.confirmationRequirement, .notRequired)
        XCTAssertEqual(decision.safetyClassification, .reversibleLocal)
        XCTAssertEqual(decision.undoRule, .safeLocalUndo)
        XCTAssertEqual(decision.receiptRecommendation.undoAvailability, .availableLocal)
        XCTAssertTrue(decision.isAllowedForFutureLocalExecution)
        XCTAssertFalse(decision.mustNeverBeSilent)
        XCTAssertEqual(decision.reasons, [.localReversibleChange])
        XCTAssertEqual(decision.blockedFacts, [])
    }

    func testMissingTargetBlocksMutationAndRecommendsSafeFailureReceipt() {
        let decision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(kind: .attachToGoal, sourceDomain: .capture)
        )

        XCTAssertEqual(decision.permissionLevel, .notSupportedYet)
        XCTAssertEqual(decision.confirmationRequirement, .notAllowed)
        XCTAssertEqual(decision.safetyClassification, .unsupported)
        XCTAssertEqual(decision.undoRule, .notSupportedYet)
        XCTAssertEqual(decision.reasons, [.noTargetObject])
        XCTAssertEqual(decision.blockedFacts, ["No target object was provided."])

        let receipt = decision.recommendedReceipt(occurredAt: "2026-04-26T12:00:00Z")
        XCTAssertTrue(receipt.isWellFormed)
        XCTAssertEqual(receipt.resultState, .failedSafely)
        XCTAssertEqual(receipt.safetyState, .safeFailure)
        XCTAssertEqual(receipt.undoAvailability, .notSupportedYet)
        XCTAssertEqual(receipt.safeFailure?.unchangedFacts, ["No automation ran.", "No calendar, export, sync, external, or destructive data changed.", "No undo ran."])
    }

    func testCalendarWriteIsPlanOwnedConfirmationGatedAndNeverSilent() {
        let block = object(.action, "plan-block-1", sourceDomain: .plan)
        let decision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(
                kind: .writeCalendarBlock,
                sourceDomain: .plan,
                targetObjects: [block]
            )
        )

        XCTAssertEqual(decision.permissionLevel, .requiresConfirmation)
        XCTAssertEqual(decision.confirmationRequirement, .requiredForExternalEffect)
        XCTAssertEqual(decision.safetyClassification, .externalEffect)
        XCTAssertEqual(decision.undoRule, .confirmationRequiredUndo)
        XCTAssertEqual(decision.receiptRecommendation.resultState, .needsConfirmation)
        XCTAssertEqual(decision.receiptRecommendation.safetyState, .confirmationRequired)
        XCTAssertEqual(decision.reasons, [.calendarIsPlanOwned, .externalSideEffect, .confirmationRequired])
        XCTAssertEqual(decision.blockedFacts, ["No calendar data was changed."])
        XCTAssertEqual(decision.suggestedNextSafeAction?.destination, .plan)
        XCTAssertTrue(decision.mustNeverBeSilent)
    }

    func testPrepareCalendarBlockAndPrepareExportAreDraftOnly() {
        let calendarDecision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(kind: .prepareCalendarBlock, sourceDomain: .plan)
        )
        let exportDecision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(kind: .prepareExport, sourceDomain: .you)
        )

        XCTAssertEqual(calendarDecision.permissionLevel, .prepareDraft)
        XCTAssertEqual(calendarDecision.confirmationRequirement, .notRequired)
        XCTAssertEqual(calendarDecision.receiptRecommendation.resultState, .draftedPrepared)
        XCTAssertEqual(calendarDecision.degradedFacts, ["No calendar block is written by this policy."])
        XCTAssertEqual(exportDecision.permissionLevel, .prepareDraft)
        XCTAssertEqual(exportDecision.safetyClassification, .privacySensitive)
        XCTAssertEqual(exportDecision.receiptRecommendation.resultState, .exportedPrepared)
        XCTAssertEqual(exportDecision.degradedFacts, ["No export file is written by this policy."])
    }

    func testPerformExportRequiresConfirmationBeforeAnyExternalEffect() {
        let decision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(kind: .performExport, sourceDomain: .you)
        )

        XCTAssertEqual(decision.permissionLevel, .requiresConfirmation)
        XCTAssertEqual(decision.confirmationRequirement, .requiredForExternalEffect)
        XCTAssertEqual(decision.undoRule, .externalUndoUnavailable)
        XCTAssertEqual(decision.receiptRecommendation.resultState, .needsConfirmation)
        XCTAssertEqual(decision.blockedFacts, ["No export was performed."])
    }

    func testUnsafeAndUnsupportedActionsNeverAutomateOrFailSafely() {
        let deleteDecision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(
                kind: .deleteObject,
                sourceDomain: .goals,
                targetObjects: [object(.goal, "goal-1", sourceDomain: .goals)]
            )
        )
        let syncDecision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(kind: .applySyncResolution, sourceDomain: .you)
        )
        let forgetDecision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(kind: .forgetMemory, sourceDomain: .you)
        )

        XCTAssertEqual(deleteDecision.permissionLevel, .neverAutomate)
        XCTAssertEqual(deleteDecision.confirmationRequirement, .requiredForDestructiveChange)
        XCTAssertEqual(deleteDecision.undoRule, .destructiveUndoUnsafe)
        XCTAssertEqual(deleteDecision.receiptRecommendation.undoAvailability, .unsafe)
        XCTAssertEqual(deleteDecision.receiptRecommendation.resultState, .failedSafely)
        XCTAssertTrue(deleteDecision.mustNeverBeSilent)

        XCTAssertEqual(syncDecision.permissionLevel, .notSupportedYet)
        XCTAssertEqual(syncDecision.confirmationRequirement, .notAllowed)
        XCTAssertEqual(syncDecision.reasons, [.syncConflictRequiresReview, .notSupportedYet])
        XCTAssertEqual(syncDecision.blockedFacts, ["No sync conflict resolution was applied."])

        XCTAssertEqual(forgetDecision.permissionLevel, .neverAutomate)
        XCTAssertEqual(forgetDecision.safetyClassification, .privacySensitive)
        XCTAssertEqual(forgetDecision.reasons, [.privacySensitive, .destructiveAction])
    }

    func testBroadPlanMutationRequiresConfirmation() {
        let decision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(
                kind: .splitAction,
                sourceDomain: .today,
                targetObjects: [object(.step, "step-1", parentContextID: "goal-1", sourceDomain: .goalEngine)]
            )
        )

        XCTAssertEqual(decision.permissionLevel, .requiresConfirmation)
        XCTAssertEqual(decision.confirmationRequirement, .requiredForBroadReflow)
        XCTAssertEqual(decision.safetyClassification, .broadPlanMutation)
        XCTAssertEqual(decision.undoRule, .confirmationRequiredUndo)
        XCTAssertEqual(decision.reasons, [.broadReflowMustBeConfirmed])
        XCTAssertEqual(decision.receiptRecommendation.resultState, .needsConfirmation)
        XCTAssertTrue(decision.mustNeverBeSilent)
    }

    func testExternalCommandSourceIsConfirmationGatedEvenForKnownLocalCommand() {
        let command = AmbitionsCommand(
            id: "command-external-archive",
            kind: .archiveItem,
            source: .appIntent,
            target: AmbitionsCommandTarget(captureID: "capture-1"),
            createdAt: "2026-04-26T12:00:00Z"
        )

        let proposed = SafeAutomationProposedAction.fromCommand(command)
        let decision = SafeAutomationPolicyEvaluator().evaluate(proposed)

        XCTAssertEqual(proposed.kind, .archiveItem)
        XCTAssertEqual(proposed.sourceDomain, .externalSurface)
        XCTAssertEqual(proposed.targetObjects.map(\.id), ["capture-1"])
        XCTAssertEqual(decision.permissionLevel, .requiresConfirmation)
        XCTAssertEqual(decision.confirmationRequirement, .requiredForExternalEffect)
        XCTAssertEqual(decision.undoRule, .externalUndoUnavailable)
        XCTAssertEqual(decision.reasons, [.unsupportedSource, .externalSideEffect])
        XCTAssertTrue(decision.mustNeverBeSilent)
    }

    func testCommandAdapterMapsExistingCommandKindsToPolicyActions() {
        let cases: [(AmbitionsCommandKind, AmbitionsCommandTarget, AmbitionsCommandPayload, SafeAutomationActionKind)] = [
            (.quickCapture, AmbitionsCommandTarget(), AmbitionsCommandPayload(rawText: "Capture this"), .createCapture),
            (.attachToGoal, AmbitionsCommandTarget(goalID: "goal-1", captureID: "capture-1"), AmbitionsCommandPayload(), .attachToGoal),
            (.markWaiting, AmbitionsCommandTarget(captureID: "capture-1"), AmbitionsCommandPayload(), .markWaiting),
            (.archiveItem, AmbitionsCommandTarget(captureID: "capture-1"), AmbitionsCommandPayload(), .archiveItem),
            (.setPriority, AmbitionsCommandTarget(captureID: "capture-1"), AmbitionsCommandPayload(priorityHints: AmbitionsCommandPriorityHints(importance: .high)), .changePriority),
            (.setDeadline, AmbitionsCommandTarget(captureID: "capture-1"), AmbitionsCommandPayload(deadlineText: "Tuesday"), .changeDeadline),
            (.delayAction, AmbitionsCommandTarget(goalID: "goal-1", stepID: "step-1"), AmbitionsCommandPayload(), .moveActionLater),
            (.splitAction, AmbitionsCommandTarget(goalID: "goal-1", stepID: "step-1"), AmbitionsCommandPayload(), .splitAction),
            (.dismissRecommendation, AmbitionsCommandTarget(recommendationID: "rec-1"), AmbitionsCommandPayload(), .dismissSuggestion),
            (.scheduleItem, AmbitionsCommandTarget(planID: "plan-1"), AmbitionsCommandPayload(metadata: ["calendarWriteIntent": "true"]), .writeCalendarBlock),
            (.prepareExport, AmbitionsCommandTarget(), AmbitionsCommandPayload(), .prepareExport),
            (.performExport, AmbitionsCommandTarget(), AmbitionsCommandPayload(), .performExport),
            (.deleteObject, AmbitionsCommandTarget(goalID: "goal-1"), AmbitionsCommandPayload(), .deleteObject),
            (.forgetMemory, AmbitionsCommandTarget(reviewID: "memory-1"), AmbitionsCommandPayload(), .forgetMemory)
        ]

        for (kind, target, payload, expectedAction) in cases {
            let command = AmbitionsCommand(
                id: "command-\(kind.rawValue)",
                kind: kind,
                source: .today,
                target: target,
                payload: payload,
                createdAt: "2026-04-26T12:00:00Z"
            )

            XCTAssertEqual(SafeAutomationProposedAction.fromCommand(command).kind, expectedAction)
        }
    }

    func testDataControlPolicyDecisionsFromCommandsAreAsConfigured() {
        let decisionForCommand: (AmbitionsCommandKind, AmbitionsCommandTarget) -> SafeAutomationPolicyDecision = { kind, target in
            SafeAutomationPolicyEvaluator().evaluate(
                SafeAutomationProposedAction(
                    kind: SafeAutomationActionKind(command: AmbitionsCommand(
                        id: "command-\(kind.rawValue)",
                        kind: kind,
                        source: .you,
                        target: target,
                        createdAt: "2026-04-26T12:00:00Z"
                    )),
                    sourceDomain: .you,
                    targetObjects: LifeGraphObjectReference.commandTargets(
                        AmbitionsCommand(
                            id: "command-\(kind.rawValue)",
                            kind: kind,
                            source: .you,
                            target: target,
                            createdAt: "2026-04-26T12:00:00Z"
                        )
                    )
                )
            )
        }

        let prepareDecision = decisionForCommand(.prepareExport, AmbitionsCommandTarget())
        let performDecision = decisionForCommand(.performExport, AmbitionsCommandTarget())
        let deleteDecision = decisionForCommand(.deleteObject, AmbitionsCommandTarget(goalID: "goal-1"))
        let forgetDecision = decisionForCommand(.forgetMemory, AmbitionsCommandTarget(reviewID: "memory-1"))

        XCTAssertEqual(prepareDecision.permissionLevel, .prepareDraft)
        XCTAssertEqual(performDecision.permissionLevel, .requiresConfirmation)
        XCTAssertEqual(deleteDecision.permissionLevel, .neverAutomate)
        XCTAssertEqual(forgetDecision.permissionLevel, .neverAutomate)
    }

    func testPolicyDecisionIDsAreDeterministicAndTargetsAreSorted() {
        let goal = object(.goal, "goal-1", sourceDomain: .goals)
        let capture = object(.capture, "capture-1", sourceDomain: .capture)
        let evaluator = SafeAutomationPolicyEvaluator()

        let first = evaluator.evaluate(
            SafeAutomationProposedAction(kind: .attachToGoal, sourceDomain: .capture, targetObjects: [goal, capture, goal])
        )
        let second = evaluator.evaluate(
            SafeAutomationProposedAction(kind: .attachToGoal, sourceDomain: .capture, targetObjects: [capture, goal])
        )

        XCTAssertEqual(first.id, second.id)
        XCTAssertEqual(first.targetObjects.map(\.stableKey), second.targetObjects.map(\.stableKey))
        XCTAssertEqual(first.targetObjects.map(\.id), ["capture-1", "goal-1"])
    }

    func testReceiptBridgeUsesActionClosureResultShapeWithoutPersisting() {
        let decision = SafeAutomationPolicyEvaluator().evaluate(
            SafeAutomationProposedAction(
                kind: .writeCalendarBlock,
                sourceDomain: .plan,
                targetObjects: [object(.action, "block-1", sourceDomain: .plan)]
            )
        )

        let receipt = decision.recommendedReceipt(occurredAt: "2026-04-26T12:00:00Z")

        XCTAssertTrue(receipt.isWellFormed)
        XCTAssertEqual(receipt.id, "receipt.policy.\(decision.id)")
        XCTAssertEqual(receipt.resultState, .needsConfirmation)
        XCTAssertEqual(receipt.undoAvailability, .requiresConfirmation)
        XCTAssertEqual(receipt.correctionAvailability, .availableWithReason)
        XCTAssertEqual(receipt.safetyState, .confirmationRequired)
        XCTAssertEqual(receipt.sourceDomain, .plan)
        XCTAssertEqual(receipt.affectedObjects.map(\.id), ["block-1"])
        XCTAssertEqual(receipt.changedFacts.map(\.kind), [.needsConfirmation])
        XCTAssertNil(receipt.safeFailure)
    }
}

private extension SafeAutomationPolicyModelsTests {
    func object(
        _ kind: LifeGraphObjectKind,
        _ id: String,
        parentContextID: String? = nil,
        sourceDomain: LifeGraphSourceDomain
    ) -> LifeGraphObjectReference {
        LifeGraphObjectReference(
            kind: kind,
            id: id,
            parentContextID: parentContextID,
            sourceDomain: sourceDomain
        )
    }
}
