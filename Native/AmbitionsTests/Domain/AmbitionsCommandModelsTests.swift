import XCTest
@testable import Ambitions

final class AmbitionsCommandModelsTests: XCTestCase {
    func testCS06FailedTaxonomyRawValuesRemainCompatibilityStable() {
        XCTAssertEqual(AmbitionsCommandExecutionStatus.failed.rawValue, "failed")
        XCTAssertEqual(ActionReceiptResultState.failedSafely.rawValue, "failed_safely")
        XCTAssertEqual(ActionReceiptSafetyState.safeFailure.rawValue, "safe_failure")
        XCTAssertEqual(SmartAttachmentConfidenceBand.unavailableFailed.rawValue, "unavailable_failed")
        XCTAssertEqual(SmartAttachmentResultState.failedSafely.rawValue, "failed_safely")
    }

    func testCommandKindTaxonomyCoversBatch68FoundationAndDataControlExtension() {
        XCTAssertEqual(
            Set(AmbitionsCommandKind.allCases),
            [
                .openDestination,
                .quickCapture,
                .createGoal,
                .updateGoal,
                .attachToGoal,
                .createTimeItem,
                .scheduleItem,
                .placeStepInTime,
                .protectTimeWindow,
                .correctTimeWindow,
                .startStepSession,
                .completeAction,
                .delayAction,
                .splitAction,
                .recoverAction,
                .markWaiting,
                .archiveItem,
                .prepareExport,
                .performExport,
                .deleteObject,
                .forgetMemory,
                .setPriority,
                .setUrgency,
                .setDeadline,
                .setContextLens,
                .clearContextLensOverride,
                .routeCommitment,
                .addDeliverable,
                .removeDeliverable,
                .addGoalScopeItem,
                .removeGoalScopeItem,
                .askWhy,
                .dismissRecommendation
            ]
        )
    }

    func testDataControlCommandsValidateThroughCommandSchema() {
        let validator = AmbitionsCommandValidator()
        let prepareExport = command(kind: .prepareExport)
        let performExport = command(kind: .performExport)
        let deleteObject = command(kind: .deleteObject, target: AmbitionsCommandTarget(goalID: "goal-1"))
        let forgetMemory = command(kind: .forgetMemory, target: AmbitionsCommandTarget(reviewID: "memory-1"))

        XCTAssertEqual(validator.validate(prepareExport), .valid)
        XCTAssertEqual(validator.validate(performExport), .valid)
        XCTAssertEqual(validator.validate(deleteObject), .valid)
        XCTAssertEqual(validator.validate(forgetMemory), .valid)
    }

    func testCommandSourceTaxonomyCoversInternalAndFutureExternalSurfaces() {
        XCTAssertEqual(
            Set(AmbitionsCommandSource.allCases),
            [
                .today,
                .goals,
                .capture,
                .time,
                .you,
                .reviews,
                .goalDetail,
                .widget,
                .liveActivity,
                .appIntent,
                .notification,
                .deepLink,
                .system
            ]
        )
    }

    func testCommandCarriesSchemaRelationsPrivacyAndExecutionFields() {
        let result = AmbitionsCommandExecutionResult(
            status: .queued,
            summary: "Queued for confirmation.",
            route: .time,
            eventLedgerEntryIDs: ["ledger-1"],
            recommendationExplanationIDs: ["explanation-1"]
        )
        let command = AmbitionsCommand(
            id: "command-1",
            kind: .routeCommitment,
            source: .capture,
            target: AmbitionsCommandTarget(captureID: "capture-1", destination: .time),
            payload: AmbitionsCommandPayload(
                rawText: "Create spreadsheet and send it to Kaylee by EOD Tuesday",
                deadlineText: "EOD Tuesday",
                contextLens: .work,
                commitmentKind: .oneTime
            ),
            validationState: .needsConfirmation,
            executionStatus: .queued,
            result: result,
            createdAt: "2026-04-25T12:00:00Z",
            actor: .user,
            sourceSurface: "capture",
            relations: AmbitionsCommandRelations(
                captureIDs: ["capture-1"],
                eventLedgerEntryIDs: ["ledger-1"],
                recommendationExplanationIDs: ["explanation-1"]
            ),
            privacy: .privateUserText
        )

        XCTAssertEqual(command.schemaVersion, ambitionsCommandSchemaVersion)
        XCTAssertEqual(command.content.rawText, "Create spreadsheet and send it to Kaylee by EOD Tuesday")
        XCTAssertEqual(command.content.deadlineText, "EOD Tuesday")
        XCTAssertEqual(command.content.contextLens, .work)
        XCTAssertEqual(command.content.commitmentKind, .oneTime)
        XCTAssertEqual(command.validationState, .needsConfirmation)
        XCTAssertEqual(command.executionStatus, .queued)
        XCTAssertEqual(command.result?.route, .time)
        XCTAssertEqual(command.relations.captureIDs, ["capture-1"])
        XCTAssertEqual(command.relations.eventLedgerEntryIDs, ["ledger-1"])
        XCTAssertEqual(command.relations.recommendationExplanationIDs, ["explanation-1"])
        XCTAssertTrue(command.localOnly)
        XCTAssertEqual(command.privacy, .privateUserText)
    }

    func testCommandExecutionRecordDefaultsRoundTripAndSchemaVersion() throws {
        let command = AmbitionsCommand(
            id: "command-queue",
            kind: .completeAction,
            source: .capture,
            target: AmbitionsCommandTarget(stepID: "step-1"),
            payload: AmbitionsCommandPayload(rawText: "Review the proposal", notes: "After lunch"),
            validationState: .valid,
            executionStatus: .pending,
            createdAt: "2026-04-25T12:00:00Z",
            actor: .user,
            sourceSurface: "capture",
            localOnly: false,
            privacy: .sensitive
        )
        let result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "Done"
        )
        let record = AmbitionsCommandExecutionRecord(
            command: command,
            result: result,
            recordedAt: "2026-04-25T12:01:00Z"
        )

        XCTAssertEqual(record.id, "command.execution.command-queue")
        XCTAssertEqual(record.commandID, "command-queue")
        XCTAssertEqual(record.localOnly, false)
        XCTAssertEqual(record.privacy, .sensitive)
        XCTAssertEqual(record.schemaVersion, ambitionsCommandExecutionRecordSchemaVersion)

        let payload = try JSONEncoder().encode(record)
        let decoded = try JSONDecoder().decode(AmbitionsCommandExecutionRecord.self, from: payload)

        XCTAssertEqual(decoded, record)
        XCTAssertEqual(decoded.recordedAt, "2026-04-25T12:01:00Z")
        XCTAssertEqual(decoded.result.status, .succeeded)
        XCTAssertEqual(decoded.result.summary, "Done")
        XCTAssertEqual(decoded.command.id, "command-queue")
    }

    func testValidationDistinguishesInvalidPayloadAndMissingTargets() {
        let validator = AmbitionsCommandValidator()
        let emptyCapture = command(kind: .quickCapture, payload: AmbitionsCommandPayload(rawText: "   "))
        let openWithoutDestination = command(kind: .openDestination)
        let completeWithoutStep = command(kind: .completeAction, target: AmbitionsCommandTarget(goalID: "goal-1"))

        XCTAssertEqual(validator.validate(emptyCapture), .invalid)
        XCTAssertEqual(validator.validate(openWithoutDestination), .needsMissingTarget)
        XCTAssertEqual(validator.validate(completeWithoutStep), .needsMissingTarget)
    }

    func testPriorityContextAndDeadlineCommandsAreRepresentableAndValidated() {
        let validator = AmbitionsCommandValidator()
        let priority = command(
            kind: .setPriority,
            target: AmbitionsCommandTarget(goalID: "goal-crib"),
            payload: AmbitionsCommandPayload(
                title: "Build crib",
                deadlineText: "Before due date",
                contextLens: .freeTime,
                commitmentKind: .goalSupporting,
                priorityHints: AmbitionsCommandPriorityHints(
                    importance: .high,
                    urgency: .elevated,
                    deadline: .high,
                    consequence: .high,
                    effort: .moderate,
                    contextFit: .high,
                    goalRelationship: .high,
                    capacityHint: .moderate,
                    recoveryState: .watch
                )
            )
        )
        let context = command(
            kind: .setContextLens,
            payload: AmbitionsCommandPayload(contextLens: .deepFocus)
        )
        let deadline = command(
            kind: .setDeadline,
            target: AmbitionsCommandTarget(captureID: "capture-work"),
            payload: AmbitionsCommandPayload(deadlineText: "EOD Tuesday", priorityHints: AmbitionsCommandPriorityHints(deadline: .high))
        )

        XCTAssertEqual(validator.validate(priority), .valid)
        XCTAssertEqual(priority.content.priorityHints.consequence, .high)
        XCTAssertEqual(priority.content.contextLens, .freeTime)
        XCTAssertEqual(validator.validate(context), .valid)
        XCTAssertEqual(validator.validate(deadline), .valid)
    }

    func testTimeMutationCommandsValidateOnlyWithTimeTargetsAndCorrectionKinds() {
        let validator = AmbitionsCommandValidator()
        let placeStep = command(
            kind: .placeStepInTime,
            target: AmbitionsCommandTarget(goalID: "goal-book", timeID: "bucket.open", stepID: "step-outline")
        )
        let protectWindow = command(
            kind: .protectTimeWindow,
            target: AmbitionsCommandTarget(timeID: "bucket.open")
        )
        let correction = command(
            kind: .correctTimeWindow,
            target: AmbitionsCommandTarget(timeID: "bucket.open"),
            payload: AmbitionsCommandPayload(metadata: ["correctionKind": TimeMutationActionKind.keepClear.rawValue])
        )
        let makeTodayLighter = command(
            kind: .correctTimeWindow,
            target: AmbitionsCommandTarget(timeID: "bucket.pressure"),
            payload: AmbitionsCommandPayload(metadata: ["correctionKind": TimeMutationActionKind.makeTodayLighter.rawValue])
        )
        let addBuffer = command(
            kind: .correctTimeWindow,
            target: AmbitionsCommandTarget(timeID: "bucket.buffer"),
            payload: AmbitionsCommandPayload(metadata: ["correctionKind": TimeMutationActionKind.addBuffer.rawValue])
        )
        let missingStep = command(
            kind: .placeStepInTime,
            target: AmbitionsCommandTarget(timeID: "bucket.open")
        )
        let unsupportedCorrection = command(
            kind: .correctTimeWindow,
            target: AmbitionsCommandTarget(timeID: "bucket.open"),
            payload: AmbitionsCommandPayload(metadata: ["correctionKind": TimeMutationActionKind.placeStep.rawValue])
        )

        XCTAssertEqual(validator.validate(placeStep), .valid)
        XCTAssertEqual(validator.validate(protectWindow), .valid)
        XCTAssertEqual(validator.validate(correction), .valid)
        XCTAssertEqual(validator.validate(makeTodayLighter), .valid)
        XCTAssertEqual(validator.validate(addBuffer), .valid)
        XCTAssertEqual(validator.validate(missingStep), .needsMissingTarget)
        XCTAssertEqual(validator.validate(unsupportedCorrection), .invalid)
    }

    func testCommitmentDeliverableAndScopeCommandsAreRepresentable() {
        let validator = AmbitionsCommandValidator()
        let commitment = command(
            kind: .routeCommitment,
            payload: AmbitionsCommandPayload(
                rawText: "Send spreadsheet to Kaylee",
                dueText: "Tuesday EOD",
                contextLens: .work,
                commitmentKind: .oneTime,
                destinationRoute: CaptureRoute.timeSeed.rawValue
            )
        )
        let addDeliverable = command(
            kind: .addDeliverable,
            target: AmbitionsCommandTarget(goalID: "goal-album"),
            payload: AmbitionsCommandPayload(title: "Song 4", commitmentKind: .goalSupporting)
        )
        let removeScope = command(
            kind: .removeGoalScopeItem,
            target: AmbitionsCommandTarget(goalID: "goal-album", scopeItemID: "scope-song-7")
        )

        XCTAssertEqual(validator.validate(commitment), .valid)
        XCTAssertEqual(commitment.content.destinationRoute, .timeSeed)
        XCTAssertEqual(validator.validate(addDeliverable), .valid)
        XCTAssertEqual(addDeliverable.content.title, "Song 4")
        XCTAssertEqual(validator.validate(removeScope), .valid)
    }

    func testNowActionMapsToValidatedCommandWithoutChangingTodayBehavior() {
        let action = NowAction(
            id: "now-action",
            kind: .completeAction,
            state: .ready,
            title: "Complete next step",
            contextLens: .work,
            commitmentKind: .oneTime,
            reference: NowActionReference(goalID: "goal-1", stepID: "step-1"),
            explanationID: "explanation-1",
            eventLedgerEntryIDs: ["ledger-1"]
        )

        let command = AmbitionsCommand.fromNowAction(
            action,
            createdAt: "2026-04-25T12:00:00Z"
        )

        XCTAssertEqual(command.operation, .completeAction)
        XCTAssertEqual(command.validationState, .valid)
        XCTAssertEqual(command.target.goalID, "goal-1")
        XCTAssertEqual(command.target.stepID, "step-1")
        XCTAssertEqual(command.content.contextLens, .work)
        XCTAssertEqual(command.relations.eventLedgerEntryIDs, ["ledger-1"])
        XCTAssertEqual(command.relations.recommendationExplanationIDs, ["explanation-1"])
    }
}

private extension AmbitionsCommandModelsTests {
    func command(
        kind: AmbitionsCommandKind,
        target: AmbitionsCommandTarget = AmbitionsCommandTarget(),
        payload: AmbitionsCommandPayload = AmbitionsCommandPayload()
    ) -> AmbitionsCommand {
        AmbitionsCommand(
            id: "command-\(kind.rawValue)",
            kind: kind,
            source: .system,
            target: target,
            payload: payload,
            createdAt: "2026-04-25T12:00:00Z"
        )
    }
}
