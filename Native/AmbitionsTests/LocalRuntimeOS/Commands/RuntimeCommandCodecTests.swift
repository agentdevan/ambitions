import Foundation
import XCTest
@testable import Ambitions

final class RuntimeCommandCodecTests: XCTestCase {
    func testEveryTypedFamilyRoundTripsThroughV2Envelope() throws {
        let target = AmbitionsCommandTarget(goalID: "goal-1", captureID: "capture-1", timeID: "time-1", stepID: "step-1")
        let content = RuntimeCommandContent(AmbitionsCommandPayload(title: "Typed command"))
        let recovery = RecoveryRecommendationCommand(
            goalID: RuntimeCommandObjectID(rawValue: "goal-1"),
            captureID: nil,
            timeID: nil,
            title: "Review recovery",
            explanationID: RuntimeCommandObjectID(rawValue: "explanation-1")
        )
        let placement = TimePlacementCommandIntent(
            start: "2026-07-24T12:00:00Z", end: "2026-07-24T12:30:00Z",
            approvedDurationMinutes: 30, contextLens: .work, relatedGoalID: RuntimeCommandObjectID(rawValue: "goal-1"), relatedCaptureID: nil
        )
        let goal = Self.fixtureGoal()
        let capture = Self.fixtureCapture()
        let handoff = CaptureGoalHandoffPlan(
            captureID: capture.id,
            goalID: goal.id,
            expectedCapture: capture,
            expectedGoalIdentity: GoalImmutableIdentity(goal),
            updatedCapture: capture
        )
        let todayPlan = TodayGoalStepActionPlan(
            actionKind: .complete, goalID: goal.id, stepID: "step-1", expectedGoalRevision: goal.revision,
            updatedGoal: goal, writesGoal: true, feedbackEvents: [], evidence: [], capture: nil
        )
        let ritualPlan = TimeRitualActionPlan(
            actionKind: .minimumVersion, goalID: goal.id, stepID: "step-1", expectedGoalRevision: goal.revision,
            updatedGoal: goal, writesGoal: true, feedbackEvents: [], evidence: []
        )
        let receiptEvent = TodayReceiptDomainEvent(
            kind: .closure,
            receipt: ActionReceipt(
                id: "receipt-typed-1", resultState: .completed, title: "Completed", summary: "Completed",
                sourceDomain: .today, occurredAt: "2026-07-24T12:00:00Z",
                affectedObjects: [LifeGraphObjectReference(kind: .step, id: "step-1", sourceDomain: .goalEngine)]
            ),
            privacyLevel: .safeToShow,
            localOnly: true,
            proofRelevance: .notProof,
            requiresConfirmationBeforeBroaderUse: false
        )
        let payloads: [RuntimeCommandPayload] = [
            .capture(CaptureCommand(action: .quickCapture(externalCreation: nil), target: target, content: content)),
            .capture(CaptureCommand(action: .quickCapture(externalCreation: ExternalCreationProvenance(
                requestID: "request-1", source: .appIntent, sourceApplication: "Tests", sourceURL: nil,
                sourceType: .appIntent, landing: .captureComposer, provenanceHint: "fixture"
            )), target: target, content: content)),
            .capture(CaptureCommand(action: .routeCommitment, target: target, content: content)),
            .capture(CaptureCommand(action: .attachToGoal(nil), target: target, content: content)),
            .capture(CaptureCommand(action: .attachToGoal(handoff), target: target, content: content)),
            .capture(CaptureCommand(action: .markWaiting, target: target, content: content)),
            .capture(CaptureCommand(action: .archive, target: target, content: content)),
            .goal(GoalCommand(action: .create, target: target, content: content)),
            .goal(GoalCommand(action: .update, target: target, content: content)),
            .goal(GoalCommand(action: .setPriority, target: target, content: content)),
            .goal(GoalCommand(action: .setUrgency, target: target, content: content)),
            .goal(GoalCommand(action: .setDeadline, target: target, content: content)),
            .goal(GoalCommand(action: .setContextLens, target: target, content: content)),
            .goal(GoalCommand(action: .clearContextLens, target: target, content: content)),
            .goal(GoalCommand(action: .addDeliverable, target: target, content: content)),
            .goal(GoalCommand(action: .removeDeliverable, target: target, content: content)),
            .goal(GoalCommand(action: .addScopeItem, target: target, content: content)),
            .goal(GoalCommand(action: .removeScopeItem, target: target, content: content)),
            .step(StepCommand(action: .startSession, target: target, content: content)),
            .step(StepCommand(action: .complete, target: target, content: content)),
            .step(StepCommand(action: .delay, target: target, content: content)),
            .step(StepCommand(action: .split, target: target, content: content)),
            .step(StepCommand(action: .recover(recovery), target: target, content: content)),
            .step(StepCommand(action: .todayGoalStep(todayPlan), target: target, content: content)),
            .schedule(ScheduleCommand(action: .createItem(placement), target: target, content: content)),
            .schedule(ScheduleCommand(action: .schedule(placement), target: target, content: content)),
            .schedule(ScheduleCommand(action: .placeStep(placement), target: target, content: content)),
            .schedule(ScheduleCommand(action: .protectWindow(placement), target: target, content: content)),
            .schedule(ScheduleCommand(action: .correctWindow(TimeCorrectionCommandIntent(action: .addBuffer, start: placement.start, end: placement.end)), target: target, content: content)),
            .schedule(ScheduleCommand(action: .undo(CommandUndoIntent(originalReceiptID: RuntimeCommandReceiptID(rawValue: "receipt-1")!, expectedProjectionVersion: 1)), target: target, content: content)),
            .schedule(ScheduleCommand(action: .calendarWrite(CalendarWriteCommandIntent(
                operationID: try RuntimeExternalOperationID(validating: "calendar-operation-1"), userConfirmed: true,
                placement: placement, destinationStepID: RuntimeCommandObjectID(rawValue: "step-1"), destinationStepTitle: "Step",
                originalBlockID: RuntimeCommandObjectID(rawValue: "time-1"), displacedDisposition: .notDisplaced,
                destinationStepPressure: nil, originStepPressure: nil, lifeshapeImpact: .recalculatedBeforeCommit,
                scheduleBlockID: RuntimeCommandObjectID(rawValue: "schedule-1")
            )), target: target, content: content)),
            .schedule(ScheduleCommand(action: .ritual(ritualPlan), target: target, content: content)),
            .reminder(ReminderCommand(action: .create, target: target, content: content)),
            .reminder(ReminderCommand(action: .update, target: target, content: content)),
            .reminder(ReminderCommand(action: .delete, target: target, content: content)),
            .profile(ProfileCommand(
                action: .updatePreferences, target: target, content: content,
                preferences: ProfilePreferencesCommandValues(
                    preferredTab: .today, appearancePreference: .system, accentFamily: .sage,
                    reviewCadenceDays: 7, localOnlyModeEnabled: true
                )
            )),
            .history(HistoryCommand(action: .openDestination, target: target, content: content)),
            .history(HistoryCommand(action: .askWhy, target: target, content: content)),
            .history(HistoryCommand(action: .dismissRecommendation, target: target, content: content)),
            .history(HistoryCommand(action: .todayReceipt(receiptEvent), target: target, content: content)),
            .repair(RepairCommand(action: .recover, recommendation: recovery, target: target, content: content)),
            .repair(RepairCommand(action: .openDestination, recommendation: recovery, target: target, content: content)),
            .importDeletion(ImportDeletionCommand(action: .prepareExport, target: target, content: content)),
            .importDeletion(ImportDeletionCommand(action: .performExport, target: target, content: content)),
            .importDeletion(ImportDeletionCommand(action: .deleteObject, target: target, content: content)),
            .importDeletion(ImportDeletionCommand(action: .forgetMemory, target: target, content: content)),
            .externalOperation(ExternalOperationCommand(
                operationID: try RuntimeExternalOperationID(validating: "operation-1"),
                kind: .reminder,
                target: target,
                title: "Create reminder"
            )),
            .externalOperation(ExternalOperationCommand(
                operationID: try RuntimeExternalOperationID(validating: "operation-2"),
                kind: .calendarEvent, target: target, title: "Create event"
            ))
        ]
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let decoder = JSONDecoder()

        for (index, payload) in payloads.enumerated() {
            let command = AmbitionsCommand(
                id: "command.family.\(index)",
                source: .system,
                typedPayload: payload,
                createdAt: "2026-07-24T12:00:00Z"
            )
            let bytes = try encoder.encode(RuntimeCommandV2Envelope(command: command, payload: payload))
            XCTAssertEqual(try decoder.decode(RuntimeCommandV2Envelope.self, from: bytes).payload, payload)
        }
    }

    func testV2EncodingIsTypedDeterministicAndContainsNoInputMetadata() throws {
        let target = AmbitionsCommandTarget(destination: .captureInbox)
        let content = AmbitionsCommandPayload(rawText: "Call the dentist")
        let command = AmbitionsCommand(
            id: "command.codec.v2.capture",
            source: .today,
            typedPayload: .capture(CaptureCommand(
                action: .quickCapture(externalCreation: nil),
                target: target,
                content: RuntimeCommandContent(content),
                sourceType: .todayQuickCapture,
                entryPoint: .todayQuickCapture,
                route: .captureInbox,
                draftID: FlagshipDraftID(rawValue: "draft-1")
            )),
            expectedRevision: .exact(7),
            idempotencyKey: CommandIdempotencyKey("capture-attempt-1"),
            createdAt: "2026-07-24T12:00:00Z",
            actor: .user,
            sourceSurface: "Today",
            privacy: .privateUserText
        )

        let codec = RuntimeCommandCodec()
        let first = try codec.encode(command)
        let second = try codec.encode(command)

        XCTAssertEqual(first, second)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: first) as? [String: Any])
        XCTAssertEqual(object["schemaVersion"] as? Int, 2)
        XCTAssertFalse(try XCTUnwrap(String(data: first, encoding: .utf8)).contains("\"metadata\""))

        guard case let .supported(decoded, upgradedFromV1) = codec.decode(first) else {
            return XCTFail("Expected a supported v2 command")
        }
        XCTAssertFalse(upgradedFromV1)
        XCTAssertEqual(decoded.id, command.id)
        XCTAssertEqual(decoded.expectedRevision, .exact(7))
        XCTAssertEqual(decoded.idempotencyKey.rawValue, "capture-attempt-1")
        XCTAssertEqual(decoded.typedPayload, command.typedPayload)
    }

    func testFixedV1FixtureUpgradesInMemoryWithoutRewritingOriginalBytes() throws {
        let bytes = try XCTUnwrap(Self.legacyOpenDestinationFixture.data(using: .utf8))
        let original = bytes

        guard case let .supported(command, upgradedFromV1) = RuntimeCommandCodec().decode(bytes) else {
            return XCTFail("Expected the fixed v1 fixture to upgrade")
        }

        XCTAssertTrue(upgradedFromV1)
        XCTAssertEqual(bytes, original)
        XCTAssertEqual(command.id, "legacy.command.open-today")
        XCTAssertEqual(command.source, .widget)
        XCTAssertEqual(command.actor, .externalSurface)
        XCTAssertEqual(command.target.destination, .today)
        XCTAssertEqual(command.privacy, .privateUserText)
        XCTAssertFalse(command.localOnly)
        guard case let .history(history) = command.typedPayload else {
            return XCTFail("Expected typed history routing")
        }
        guard case .openDestination = history.action else {
            return XCTFail("Expected open-destination action")
        }
    }

    func testEveryPersistedV1KindUpgradesToExpectedTypedOperation() throws {
        let expected: [(AmbitionsCommandKind, RuntimeCommandOperation)] = [
            (.openDestination, .openDestination), (.quickCapture, .quickCapture), (.createGoal, .createGoal),
            (.updateGoal, .updateGoal), (.attachToGoal, .attachToGoal), (.createTimeItem, .createTimeItem),
            (.scheduleItem, .scheduleItem), (.placeStepInTime, .placeStepInTime), (.protectTimeWindow, .protectTimeWindow),
            (.correctTimeWindow, .correctTimeWindow), (.startStepSession, .startStepSession), (.completeAction, .completeAction),
            (.delayAction, .delayAction), (.splitAction, .splitAction), (.recoverAction, .recoverAction),
            (.markWaiting, .markWaiting), (.archiveItem, .archiveItem), (.prepareExport, .prepareExport),
            (.performExport, .performExport), (.deleteObject, .deleteObject), (.forgetMemory, .forgetMemory),
            (.setPriority, .setPriority), (.setUrgency, .setUrgency), (.setDeadline, .setDeadline),
            (.setContextLens, .setContextLens), (.clearContextLensOverride, .clearContextLensOverride),
            (.updateUserPreferences, .updateUserPreferences), (.routeCommitment, .routeCommitment),
            (.addDeliverable, .addDeliverable), (.removeDeliverable, .removeDeliverable),
            (.addGoalScopeItem, .addGoalScopeItem), (.removeGoalScopeItem, .removeGoalScopeItem),
            (.askWhy, .askWhy), (.dismissRecommendation, .dismissRecommendation)
        ]
        for (kind, operation) in expected {
            let metadata = kind == .correctTimeWindow ? ["correctionKind": TimeMutationActionKind.addBuffer.rawValue] : [:]
            let bytes = try Self.legacyFixture(kind: kind, metadata: metadata)
            guard case let .supported(command, upgraded) = RuntimeCommandCodec().decode(bytes) else {
                return XCTFail("Expected v1 \(kind.rawValue) to upgrade")
            }
            XCTAssertTrue(upgraded)
            XCTAssertEqual(command.operation, operation)
        }
    }

    func testV1AssociatedValueFixturesUpgradeToExactTypedPlans() throws {
        let goal = Self.fixtureGoal()
        let capture = Self.fixtureCapture()
        let handoff = CaptureGoalHandoffPlan(
            captureID: capture.id, goalID: goal.id, expectedCapture: capture,
            expectedGoalIdentity: GoalImmutableIdentity(goal), updatedCapture: capture
        )
        let today = TodayGoalStepActionPlan(
            actionKind: .complete, goalID: goal.id, stepID: "step-1", expectedGoalRevision: goal.revision,
            updatedGoal: goal, writesGoal: true, feedbackEvents: [], evidence: [], capture: nil
        )
        let ritual = TimeRitualActionPlan(
            actionKind: .minimumVersion, goalID: goal.id, stepID: "step-1", expectedGoalRevision: goal.revision,
            updatedGoal: goal, writesGoal: true, feedbackEvents: [], evidence: []
        )
        let receipt = TodayReceiptDomainEvent(
            kind: .closure,
            receipt: ActionReceipt(
                id: "receipt-v1", resultState: .completed, title: "Done", summary: "Done",
                sourceDomain: .today, occurredAt: "2026-07-24T12:00:00Z",
                affectedObjects: [LifeGraphObjectReference(kind: .step, id: "step-1")]
            ),
            privacyLevel: .safeToShow, localOnly: true, proofRelevance: .notProof,
            requiresConfirmationBeforeBroaderUse: false
        )
        let fixtures: [(AmbitionsCommandKind, String, String, String)] = [
            (.attachToGoal, "captureGoalHandoffMutation", "captureGoalHandoffPlan", try Self.base64(handoff)),
            (.completeAction, "todayGoalStepActionMutation", "todayGoalStepActionPlan", try Self.base64(today)),
            (.scheduleItem, "timeRitualActionMutation", "timeRitualActionPlan", try Self.base64(ritual)),
            (.dismissRecommendation, "todayReceiptMutation", "todayReceiptPayload", try Self.base64(receipt))
        ]
        for fixture in fixtures {
            let bytes = try Self.legacyFixture(kind: fixture.0, metadata: [
                fixture.1: "true", fixture.2: fixture.3
            ])
            let original = bytes
            guard case let .supported(command, upgraded) = RuntimeCommandCodec().decode(bytes) else {
                return XCTFail("Expected associated v1 fixture to upgrade")
            }
            XCTAssertTrue(upgraded)
            XCTAssertEqual(bytes, original)
            switch (fixture.0, command.typedPayload) {
            case let (.attachToGoal, .capture(value)):
                guard case let .attachToGoal(decoded) = value.action else { return XCTFail("Expected handoff") }
                XCTAssertEqual(decoded, handoff)
            case let (.completeAction, .step(value)):
                guard case let .todayGoalStep(decoded) = value.action else { return XCTFail("Expected Today plan") }
                XCTAssertEqual(decoded, today)
            case let (.scheduleItem, .schedule(value)):
                guard case let .ritual(decoded) = value.action else { return XCTFail("Expected ritual") }
                XCTAssertEqual(decoded, ritual)
            case let (.dismissRecommendation, .history(value)):
                guard case let .todayReceipt(decoded) = value.action else { return XCTFail("Expected receipt") }
                XCTAssertEqual(decoded, receipt)
            default:
                return XCTFail("Unexpected associated upgrade")
            }
        }
    }

    func testV1BehavioralVariantsUpgradeWithoutFlatteningTypedContent() throws {
        let externalCreation = try Self.legacyFixture(kind: .quickCapture, metadata: [
            ExternalCreationCommandMetadataKey.requestID: "request-v1",
            ExternalCreationCommandMetadataKey.source: ExternalCreationSource.appIntent.rawValue,
            ExternalCreationCommandMetadataKey.sourceType: CaptureSourceType.appIntent.rawValue,
            ExternalCreationCommandMetadataKey.landing: ExternalCreationLanding.captureComposer.rawValue,
            "captureEntryPoint": CaptureCommand.EntryPoint.appIntent.rawValue,
            "captureRoute": CaptureRoute.captureInbox.rawValue,
            "flagshipDraftID": "draft-v1"
        ])
        guard case let .supported(creationCommand, true) = RuntimeCommandCodec().decode(externalCreation),
              case let .capture(creation) = creationCommand.typedPayload,
              case let .quickCapture(provenance) = creation.action else {
            return XCTFail("Expected exact external creation upgrade")
        }
        XCTAssertEqual(provenance?.requestID, "request-v1")
        XCTAssertEqual(provenance?.source, .appIntent)
        XCTAssertEqual(creation.entryPoint, .appIntent)
        XCTAssertEqual(creation.draftID?.rawValue, "draft-v1")

        let externalEffect = try Self.legacyFixture(kind: .scheduleItem, metadata: [
            "externalEffectOperationID": "external-v1", "externalEffectKind": "calendar_event"
        ])
        guard case let .supported(effectCommand, true) = RuntimeCommandCodec().decode(externalEffect),
              case let .externalOperation(effect) = effectCommand.typedPayload else {
            return XCTFail("Expected exact external effect upgrade")
        }
        XCTAssertEqual(effect.operationID.rawValue, "external-v1")
        XCTAssertEqual(effect.kind, .calendarEvent)

        let placementBytes = try Self.legacyFixture(kind: .placeStepInTime, metadata: [
            "startAt": "2026-07-24T12:00:00Z", "endAt": "2026-07-24T12:30:00Z",
            "approvedDurationMinutes": "30", "relatedGoalID": "goal-1",
            "placementCandidateID": "candidate-1", "placementCandidateKind": "goalLinked",
            "placementTrigger": "user_initiated", "explicitUserApproval": "true",
            "automationPolicy": "allowed_by_existing_policy", "contextQuality": "sufficient",
            "placementPriority": "high"
        ])
        guard case let .supported(placementCommand, true) = RuntimeCommandCodec().decode(placementBytes),
              case let .schedule(placementSchedule) = placementCommand.typedPayload,
              case let .placeStep(placement?) = placementSchedule.action else {
            return XCTFail("Expected exact placement upgrade")
        }
        XCTAssertEqual(placement.candidateID?.rawValue, "candidate-1")
        XCTAssertEqual(placement.candidateKind, .goalLinked)
        XCTAssertEqual(placement.trigger, .userInitiated)
        XCTAssertEqual(placement.placementPriority, .high)

        let correctionBytes = try Self.legacyFixture(kind: .correctTimeWindow, metadata: [
            "correctionKind": TimeMutationActionKind.addBuffer.rawValue,
            "startAt": "2026-07-24T12:00:00Z", "endAt": "2026-07-24T12:30:00Z"
        ])
        guard case let .supported(correctionCommand, true) = RuntimeCommandCodec().decode(correctionBytes),
              case let .schedule(correctionSchedule) = correctionCommand.typedPayload,
              case let .correctWindow(correction) = correctionSchedule.action else {
            return XCTFail("Expected exact correction upgrade")
        }
        XCTAssertEqual(correction.action, .addBuffer)

        let undoBytes = try Self.legacyFixture(kind: .correctTimeWindow, metadata: [
            "undoOriginalReceiptID": "receipt-v1", "expectedProjectionVersion": "9"
        ])
        guard case let .supported(undoCommand, true) = RuntimeCommandCodec().decode(undoBytes),
              case let .schedule(undoSchedule) = undoCommand.typedPayload,
              case let .undo(undo) = undoSchedule.action else {
            return XCTFail("Expected exact undo upgrade")
        }
        XCTAssertEqual(undo.originalReceiptID.rawValue, "receipt-v1")
        XCTAssertEqual(undo.expectedProjectionVersion, 9)

        let preferencesBytes = try Self.legacyFixture(kind: .updateUserPreferences, metadata: [
            "preferredTab": AmbitionsSurface.today.rawValue, "appearancePreference": AppAppearancePreference.dark.rawValue,
            "accentFamily": AmbitionAccentFamily.sage.rawValue, "reviewCadenceDays": "14",
            "localOnlyModeEnabled": "true"
        ])
        guard case let .supported(preferencesCommand, true) = RuntimeCommandCodec().decode(preferencesBytes),
              case let .profile(profile) = preferencesCommand.typedPayload else {
            return XCTFail("Expected exact preferences upgrade")
        }
        XCTAssertEqual(profile.preferences?.preferredTab, .today)
        XCTAssertEqual(profile.preferences?.appearancePreference, .dark)
        XCTAssertEqual(profile.preferences?.reviewCadenceDays, 14)
    }

    func testV1CalendarOperationIDDoesNotRequireExternalEffectKind() throws {
        let bytes = try Self.legacyFixture(kind: .scheduleItem, metadata: [
            "calendarWriteIntent": "true",
            "userConfirmed": "true",
            "externalEffectOperationID": "calendar-operation-v1",
            "startAt": "2026-07-24T12:00:00Z",
            "endAt": "2026-07-24T12:30:00Z",
            "scheduleBlockID": "schedule-v1"
        ])

        guard case let .supported(command, upgraded) = RuntimeCommandCodec().decode(bytes),
              case let .schedule(schedule) = command.typedPayload,
              case let .calendarWrite(intent) = schedule.action else {
            return XCTFail("Expected calendar v1 shape to upgrade without external-effect kind")
        }
        XCTAssertTrue(upgraded)
        XCTAssertEqual(intent.operationID?.rawValue, "calendar-operation-v1")
        XCTAssertEqual(intent.scheduleBlockID?.rawValue, "schedule-v1")
        XCTAssertEqual(intent.operationIdentityProvenance, .legacyExplicit)
        XCTAssertEqual(intent.displacedDisposition, .notDisplaced)
        XCTAssertEqual(intent.lifeshapeImpact, .recalculatedBeforeCommit)
        XCTAssertEqual(AmbitionsCommandValidator().validate(command), .needsConfirmation)
        let plan = CommandReducer().reduce(command: command, validation: .valid)
        XCTAssertEqual(plan.mutationKind, .runtimeMutation)
        XCTAssertEqual(plan.sideEffectPolicy, .localOnly)
        XCTAssertThrowsError(try RuntimeCommandCodec().encode(command))
    }

    func testV1CalendarPrecedesGenericExternalMarkersAndDoesNotInventOperationIdentity() throws {
        let bytes = try Self.legacyFixture(kind: .scheduleItem, metadata: [
            "calendarWriteIntent": "true",
            "userConfirmed": "true",
            "externalEffectKind": "calendar_event",
            "operationID": "generic-operation-that-must-not-win",
            "scheduleBlockID": "schedule-v1"
        ])
        guard case let .supported(command, upgraded) = RuntimeCommandCodec().decode(bytes),
              case let .schedule(schedule) = command.typedPayload,
              case let .calendarWrite(intent) = schedule.action else {
            return XCTFail("Calendar marker must own v1 upgrade precedence")
        }
        XCTAssertTrue(upgraded)
        XCTAssertNil(intent.operationID)
        XCTAssertEqual(intent.operationIdentityProvenance, .legacyAbsent)
        XCTAssertEqual(intent.scheduleBlockID?.rawValue, "schedule-v1")
        XCTAssertEqual(AmbitionsCommandValidator().validate(command), .needsConfirmation)
        let plan = CommandReducer().reduce(command: command, validation: .valid)
        XCTAssertEqual(plan.mutationKind, .runtimeMutation)
        XCTAssertEqual(plan.sideEffectPolicy, .localOnly)
        XCTAssertThrowsError(try RuntimeCommandCodec().encode(command))
    }

    func testV1CalendarIdentityVariantsRejectBeforeMutationAndPreserveHistoricalIntent() async throws {
        let fixtures: [(label: String, operationID: String?, provenance: CalendarWriteCommandIntent.OperationIdentityProvenance)] = [
            ("explicit", "calendar-operation-v1", .legacyExplicit),
            ("absent", nil, .legacyAbsent),
        ]

        for fixture in fixtures {
            let root = FileManager.default.temporaryDirectory
                .appendingPathComponent("legacy-calendar-journal-\(fixture.label)-\(UUID().uuidString)")
            let scheduleFileURL = root.appendingPathComponent("local-schedule-blocks.json")
            defer { try? FileManager.default.removeItem(at: root) }

            var metadata = [
                "calendarWriteIntent": "true",
                "userConfirmed": "true",
                "startAt": "2026-07-24T12:00:00Z",
                "endAt": "2026-07-24T12:30:00Z",
                "scheduleBlockID": "legacy-schedule-\(fixture.label)",
            ]
            metadata["externalEffectOperationID"] = fixture.operationID
            let bytes = try Self.legacyFixture(kind: .scheduleItem, metadata: metadata)
            guard case let .supported(command, upgraded) = RuntimeCommandCodec().decode(bytes),
                  case let .schedule(schedule) = command.typedPayload,
                  case let .calendarWrite(intent) = schedule.action else {
                return XCTFail("Expected legacy calendar fixture to upgrade")
            }

            XCTAssertTrue(upgraded)
            XCTAssertEqual(intent.operationIdentityProvenance, fixture.provenance)
            XCTAssertEqual(intent.operationID?.rawValue, fixture.operationID)
            XCTAssertThrowsError(try RuntimeCommandCodec().encode(command))

            let journal = InMemoryCommandJournal(deviceID: "legacy-calendar-journal-tests")
            let executor = AmbitionsCommandExecutor.test(
                commandJournal: journal,
                scheduleStoreFileURL: scheduleFileURL
            )
            let result = await executor.execute(
                command,
                context: CommandExecutionContext(
                    now: Date(timeIntervalSince1970: 1_774_526_400),
                    actor: .system
                )
            )

            XCTAssertEqual(result.status, .requiresConfirmation)
            XCTAssertEqual(result.metadata["validation"], AmbitionsCommandValidationState.needsConfirmation.rawValue)
            XCTAssertFalse(FileManager.default.fileExists(atPath: scheduleFileURL.path))

            let entries = try await journal.fetchEntries(matching: .commandID(command.id), limit: nil)
            XCTAssertEqual(entries.count, 1)
            guard let entry = entries.first else { continue }
            XCTAssertEqual(entry.envelope.phase, .rejectedBeforeMutation)
            XCTAssertTrue(CommandJournalChecksum.isValid(entry))
            let persisted = try JSONDecoder().decode(
                CommandJournalEntry.self,
                from: JSONEncoder().encode(entry)
            )
            XCTAssertTrue(CommandJournalChecksum.isValid(persisted))
            XCTAssertEqual(persisted.envelope.command, command)
            guard case let .schedule(persistedSchedule) = persisted.envelope.command.typedPayload,
                  case let .calendarWrite(persistedIntent) = persistedSchedule.action else {
                return XCTFail("Expected journal replay to retain legacy calendar intent")
            }
            XCTAssertEqual(persistedIntent.operationIdentityProvenance, fixture.provenance)
            XCTAssertEqual(persistedIntent.operationID?.rawValue, fixture.operationID)
            XCTAssertEqual(persistedIntent.scheduleBlockID?.rawValue, "legacy-schedule-\(fixture.label)")
            XCTAssertEqual(persistedIntent.displacedDisposition, .notDisplaced)
            XCTAssertEqual(persistedIntent.lifeshapeImpact, .recalculatedBeforeCommit)
        }
    }

    func testHistoricalV1JournalEntryRetainsChecksumAndExactEncodedMaterial() throws {
        let envelopeFixture = Data(Self.historicalV1CommandEnvelopeFixture.utf8)
        let envelope = try JSONDecoder().decode(CommandEnvelope.self, from: envelopeFixture)
        let entry = try CommandJournalEntry.make(
            sequence: 1,
            previousChecksum: nil,
            envelope: envelope,
            appendedAt: "2025-01-02T03:04:05Z",
            deviceID: "historical-device"
        )
        let terminalFixture = try CommandJournalChecksum.encoder.encode(entry)
        let reloaded = try JSONDecoder().decode(CommandJournalEntry.self, from: terminalFixture)

        XCTAssertEqual(reloaded.schemaVersion, commandJournalEntrySchemaVersion)
        XCTAssertEqual(reloaded.envelope.schemaVersion, "command_envelope.native.v1")
        XCTAssertEqual(reloaded.envelope.command.id, "legacy.command.quick_capture")
        XCTAssertEqual(reloaded.envelope.command.operation, .quickCapture)
        XCTAssertTrue(CommandJournalChecksum.isValid(reloaded))
        XCTAssertEqual(try CommandJournalChecksum.encoder.encode(reloaded), terminalFixture)
        XCTAssertEqual(try CommandJournalChecksum.encoder.encode(reloaded.envelope), envelopeFixture)
        XCTAssertEqual(try CommandJournalChecksum.digest(reloaded.checksumMaterial), reloaded.checksum)
    }

    func testRuntimeCommandEventRoundTripRetainsExactTypedFamilyAndCase() throws {
        let target = AmbitionsCommandTarget(goalID: "goal-1", stepID: "step-1")
        let payload: RuntimeCommandPayload = .step(StepCommand(
            action: .split,
            target: target,
            content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Split precisely"))
        ))
        let event = RuntimeCommandEventPayload(
            phase: .executionRecorded,
            commandPayload: payload,
            validationState: .valid,
            executionStatus: .succeeded,
            resultStatus: .succeeded,
            resultSummary: "Split",
            commandRecordID: "record-1",
            resultRoute: .today,
            eventLedgerEntryIDs: [],
            recommendationExplanationIDs: [],
            resultMetadata: [:]
        )
        let decoded = try JSONDecoder().decode(RuntimeCommandEventPayload.self, from: JSONEncoder().encode(event))
        XCTAssertEqual(decoded.commandPayload, payload)
        XCTAssertEqual(decoded.commandPayload?.diagnosticFamily, "step")
        XCTAssertEqual(decoded.commandPayload?.diagnosticCase, "split")
        XCTAssertNil(decoded.legacyCommandOperation)
    }

    func testFutureAndCorruptBytesAreLosslesslyQuarantined() throws {
        let future = Data("{\"schemaVersion\":3,\"payload\":{}}".utf8)
        guard case let .unsupported(unsupported) = RuntimeCommandCodec().decode(future) else {
            return XCTFail("Expected unsupported future command")
        }
        XCTAssertEqual(unsupported.originalBytes, future)
        XCTAssertEqual(unsupported.reason, .futureVersion)
        XCTAssertEqual(unsupported.recovery, .unsupportedSchema)

        let corrupt = Data([0x00, 0xFF, 0x7B])
        guard case let .corrupt(quarantined) = RuntimeCommandCodec().decode(corrupt) else {
            return XCTFail("Expected corrupt command quarantine")
        }
        XCTAssertEqual(quarantined.originalBytes, corrupt)
        XCTAssertEqual(quarantined.recovery, .corruption)
    }

    func testUnknownV2FamilyFailsClosedWithoutLegacyNavigationFallback() throws {
        let bytes = Data("""
        {
          "schemaVersion": 2,
          "id": "command.unknown-family",
          "expectedRevision": {"kind":"absent"},
          "provenance": {"source":"system","actor":"system"},
          "privacy": {"classification":"standard","localOnly":true},
          "idempotencyKey": {"rawValue":"command.unknown-family","schemaVersion":"command_idempotency_key.native.v1"},
          "targetIdentities": [],
          "payload": {"futureFamily": {}},
          "validationState": "valid",
          "executionStatus": "pending",
          "createdAt": "2026-07-24T12:00:00Z",
          "requestedAt": "2026-07-24T12:00:00Z",
          "relations": {"goalIDs":[],"captureIDs":[],"timeIDs":[],"reviewIDs":[],"eventLedgerEntryIDs":[],"recommendationExplanationIDs":[]}
        }
        """.utf8)

        guard case let .unsupported(quarantined) = RuntimeCommandCodec().decode(bytes) else {
            return XCTFail("Expected unknown family to fail closed")
        }
        XCTAssertEqual(quarantined.originalBytes, bytes)
        XCTAssertEqual(quarantined.reason, .unknownFamilyOrCase)
    }

    func testMalformedIdentityAndTargetIdentityMismatchAreCorrupt() throws {
        let target = AmbitionsCommandTarget(goalID: "goal-1")
        let payload = RuntimeCommandPayload.goal(GoalCommand(
            action: .update,
            target: target,
            content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Goal"))
        ))
        let command = AmbitionsCommand(
            id: "command.identity",
            source: .system,
            typedPayload: payload,
            createdAt: "2026-07-24T12:00:00Z"
        )
        let valid = try RuntimeCommandCodec().encode(command)
        let validText = try XCTUnwrap(String(data: valid, encoding: .utf8))

        let normalizedDifferent = Data(validText.replacingOccurrences(
            of: "\"id\":\"command.identity\"",
            with: "\"id\":\" command.identity \""
        ).utf8)
        guard case .corrupt = RuntimeCommandCodec().decode(normalizedDifferent) else {
            return XCTFail("Normalized-different IDs must be corrupt")
        }

        let mismatchedTargets = Data(validText.replacingOccurrences(
            of: "\"targetIdentities\":[\"goal-1\"]",
            with: "\"targetIdentities\":[\"goal-2\"]"
        ).utf8)
        guard case .corrupt = RuntimeCommandCodec().decode(mismatchedTargets) else {
            return XCTFail("Target identity mismatch must be corrupt")
        }
    }

    func testUnknownLegacyKindIsUnsupportedRatherThanCorrupt() {
        let bytes = Data(Self.legacyOpenDestinationFixture.replacingOccurrences(
            of: "open_destination",
            with: "future_destination"
        ).utf8)
        guard case let .unsupported(command) = RuntimeCommandCodec().decode(bytes) else {
            return XCTFail("Unknown legacy discriminator must be unsupported")
        }
        XCTAssertEqual(command.reason, .unknownFamilyOrCase)
        XCTAssertEqual(command.originalBytes, bytes)
    }

    func testUnknownActionDiscriminatorInEveryRawActionFamilyIsUnsupported() throws {
        let target = AmbitionsCommandTarget(goalID: "goal-1", stepID: "step-1")
        let content = RuntimeCommandContent(AmbitionsCommandPayload(title: "Action"))
        let recovery = RecoveryRecommendationCommand(goalID: RuntimeCommandObjectID(rawValue: "goal-1"), captureID: nil, timeID: nil, title: "Recover", explanationID: nil)
        let payloads: [RuntimeCommandPayload] = [
            .capture(CaptureCommand(action: .routeCommitment, target: target, content: content)),
            .goal(GoalCommand(action: .update, target: target, content: content)),
            .step(StepCommand(action: .complete, target: target, content: content)),
            .schedule(ScheduleCommand(action: .schedule(nil), target: target, content: content)),
            .reminder(ReminderCommand(action: .create, target: target, content: content)),
            .profile(ProfileCommand(action: .updatePreferences, target: target, content: content)),
            .history(HistoryCommand(action: .askWhy, target: target, content: content)),
            .repair(RepairCommand(action: .recover, recommendation: recovery, target: target, content: content)),
            .importDeletion(ImportDeletionCommand(action: .prepareExport, target: target, content: content))
        ]

        for (index, payload) in payloads.enumerated() {
            let command = AmbitionsCommand(
                id: "command.unknown-action.\(index)", source: .system, typedPayload: payload,
                createdAt: "2026-07-24T12:00:00Z"
            )
            var object = try XCTUnwrap(JSONSerialization.jsonObject(with: RuntimeCommandCodec().encode(command)) as? [String: Any])
            XCTAssertTrue(Self.replaceFirstAction(in: &object))
            let bytes = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
            guard case let .unsupported(issue) = RuntimeCommandCodec().decode(bytes) else {
                return XCTFail("Unknown action for payload \(index) must be unsupported")
            }
            XCTAssertEqual(issue.reason, .unknownFamilyOrCase)
            XCTAssertEqual(issue.originalBytes, bytes)
        }
    }

    func testUnknownClosedEnumAtEveryBehavioralNestedLayerIsUnsupported() throws {
        let target = AmbitionsCommandTarget(goalID: "goal-1", captureID: "capture-1", timeID: "time-1", stepID: "step-1")
        let content = RuntimeCommandContent(AmbitionsCommandPayload(
            title: "Nested enums", contextLens: .work, commitmentKind: .oneTime,
            priorityHints: AmbitionsCommandPriorityHints(urgency: .high, recoveryState: .stable),
            goalRelationship: .activeGoal, destinationRoute: CaptureRoute.captureInbox.rawValue
        ))
        let placement = TimePlacementCommandIntent(
            start: "2026-07-24T12:00:00Z", end: "2026-07-24T12:30:00Z",
            approvedDurationMinutes: 30, contextLens: .work,
            relatedGoalID: RuntimeCommandObjectID(rawValue: "goal-1"), relatedCaptureID: nil,
            candidateID: RuntimeCommandObjectID(rawValue: "candidate-1"), candidateKind: .goalLinked,
            sourceLabel: "Goal Step", trigger: .userInitiated, explicitUserApproval: true,
            automationPolicy: .allowedByExistingPolicy, contextQuality: .sufficient, placementPriority: .high
        )
        let capture: RuntimeCommandPayload = .capture(CaptureCommand(
            action: .quickCapture(externalCreation: ExternalCreationProvenance(
                requestID: "request-1", source: .appIntent, sourceApplication: nil, sourceURL: nil,
                sourceType: .appIntent, landing: .captureComposer, provenanceHint: nil
            )),
            target: target, content: content, sourceType: .appIntent, entryPoint: .appIntent,
            route: .captureInbox, flagshipRoute: .task
        ))
        let schedule: RuntimeCommandPayload = .schedule(ScheduleCommand(
            action: .placeStep(placement), target: target, content: content
        ))
        let correction: RuntimeCommandPayload = .schedule(ScheduleCommand(
            action: .correctWindow(TimeCorrectionCommandIntent(action: .addBuffer, start: nil, end: nil)),
            target: target, content: content
        ))
        let calendar: RuntimeCommandPayload = .schedule(ScheduleCommand(
            action: .calendarWrite(CalendarWriteCommandIntent(
                operationID: try RuntimeExternalOperationID(validating: "calendar-op-1"), userConfirmed: true,
                placement: placement, destinationStepID: RuntimeCommandObjectID(rawValue: "step-1"),
                destinationStepTitle: "Step", originalBlockID: RuntimeCommandObjectID(rawValue: "time-1"),
                displacedDisposition: .notDisplaced, destinationStepPressure: nil, originStepPressure: nil,
                lifeshapeImpact: .recalculatedBeforeCommit, scheduleBlockID: RuntimeCommandObjectID(rawValue: "schedule-1")
            )), target: target, content: content
        ))
        let profile: RuntimeCommandPayload = .profile(ProfileCommand(
            action: .updatePreferences, target: target, content: content,
            preferences: ProfilePreferencesCommandValues(
                preferredTab: .today, appearancePreference: .system, accentFamily: .sage,
                reviewCadenceDays: 7, localOnlyModeEnabled: true
            )
        ))
        let receipt: RuntimeCommandPayload = .history(HistoryCommand(
            action: .todayReceipt(TodayReceiptDomainEvent(
                kind: .closure,
                receipt: ActionReceipt(
                    id: "receipt-1", resultState: .completed, title: "Done", summary: "Done",
                    sourceDomain: .today, occurredAt: "2026-07-24T12:00:00Z",
                    affectedObjects: [LifeGraphObjectReference(kind: .step, id: "step-1")]
                ),
                privacyLevel: .safeToShow, localOnly: true, proofRelevance: .notProof,
                requiresConfirmationBeforeBroaderUse: false
            )), target: target, content: content
        ))
        let goal = Self.fixtureGoal()
        let today: RuntimeCommandPayload = .step(StepCommand(
            action: .todayGoalStep(TodayGoalStepActionPlan(
                actionKind: .complete, goalID: goal.id, stepID: "step-1", expectedGoalRevision: goal.revision,
                updatedGoal: goal, writesGoal: true, feedbackEvents: [], evidence: [], capture: nil
            )), target: target, content: content
        ))
        let ritual: RuntimeCommandPayload = .schedule(ScheduleCommand(
            action: .ritual(TimeRitualActionPlan(
                actionKind: .minimumVersion, goalID: goal.id, stepID: "step-1", expectedGoalRevision: goal.revision,
                updatedGoal: goal, writesGoal: true, feedbackEvents: [], evidence: []
            )), target: target, content: content
        ))
        let cases: [(RuntimeCommandPayload, String)] = [
            (capture, "\"entryPoint\":\"appIntent\""),
            (capture, "\"flagshipRoute\":\"task\""),
            (capture, "\"sourceType\":\"app_intent\""),
            (capture, "\"source\":\"app_intent\""),
            (capture, "\"landing\":\"capture_composer\""),
            (capture, "\"route\":\"capture_inbox\""),
            (capture, "\"contextLens\":\"work\""),
            (capture, "\"commitmentKind\":\"one_time\""),
            (capture, "\"urgency\":\"high\""),
            (capture, "\"recoveryState\":\"stable\""),
            (capture, "\"goalRelationship\":\"active_goal\""),
            (capture, "\"destinationRoute\":\"capture_inbox\""),
            (schedule, "\"candidateKind\":\"goalLinked\""),
            (schedule, "\"trigger\":\"user_initiated\""),
            (schedule, "\"automationPolicy\":\"allowed_by_existing_policy\""),
            (schedule, "\"contextQuality\":\"sufficient\""),
            (schedule, "\"placementPriority\":\"high\""),
            (correction, "\"action\":\"add_buffer\""),
            (calendar, "\"displacedDisposition\":\"not_displaced\""),
            (calendar, "\"lifeshapeImpact\":\"recalculated_before_commit\""),
            (profile, "\"preferredTab\":\"today\""),
            (profile, "\"appearancePreference\":\"system\""),
            (profile, "\"accentFamily\":\"sage\""),
            (today, "\"actionKind\":\"complete\""),
            (ritual, "\"actionKind\":\"minimum_version\""),
            (receipt, "\"kind\":\"closure\"")
        ]
        for (index, entry) in cases.enumerated() {
            let command = AmbitionsCommand(
                id: "command.unknown-nested.\(index)", source: .system, typedPayload: entry.0,
                createdAt: "2026-07-24T12:00:00Z"
            )
            let original = try RuntimeCommandCodec().encode(command)
            let text = try XCTUnwrap(String(data: original, encoding: .utf8))
            XCTAssertTrue(text.contains(entry.1))
            let replacementKey = entry.1.split(separator: ":", maxSplits: 1)[0]
            let mutated = Data(text.replacingOccurrences(of: entry.1, with: "\(replacementKey):\"future_case\"").utf8)
            guard case let .unsupported(issue) = RuntimeCommandCodec().decode(mutated) else {
                return XCTFail("Unknown nested enum \(entry.1) must be unsupported")
            }
            XCTAssertEqual(issue.reason, .unknownFamilyOrCase)
            XCTAssertEqual(issue.originalBytes, mutated)
        }
    }

    func testMalformedBehavioralNestedIdentitiesAreCorruptAndCannotEncodeFresh() throws {
        let goal = Self.fixtureGoal()
        let capture = Self.fixtureCapture()
        let target = AmbitionsCommandTarget(goalID: goal.id, captureID: capture.id, stepID: "step-1")
        let content = RuntimeCommandContent(AmbitionsCommandPayload(title: "Identity", explanationID: "explanation-1"))
        let payloads: [(RuntimeCommandPayload, String)] = [
            (.capture(CaptureCommand(
                action: .quickCapture(externalCreation: ExternalCreationProvenance(
                    requestID: "request-1", source: .appIntent, sourceApplication: nil, sourceURL: nil,
                    sourceType: .appIntent, landing: .captureComposer, provenanceHint: nil
                )), target: target, content: content
            )), "request-1"),
            (.capture(CaptureCommand(
                action: .attachToGoal(CaptureGoalHandoffPlan(
                    captureID: capture.id, goalID: goal.id, expectedCapture: capture,
                    expectedGoalIdentity: GoalImmutableIdentity(goal), updatedCapture: capture
                )), target: target, content: content
            )), capture.id),
            (.step(StepCommand(
                action: .todayGoalStep(TodayGoalStepActionPlan(
                    actionKind: .complete, goalID: goal.id, stepID: "step-1", expectedGoalRevision: goal.revision,
                    updatedGoal: goal, writesGoal: true, feedbackEvents: [], evidence: [], capture: nil
                )), target: target, content: content
            )), "step-1"),
            (.schedule(ScheduleCommand(
                action: .ritual(TimeRitualActionPlan(
                    actionKind: .minimumVersion, goalID: goal.id, stepID: "step-1", expectedGoalRevision: goal.revision,
                    updatedGoal: goal, writesGoal: true, feedbackEvents: [], evidence: []
                )), target: target, content: content
            )), goal.id)
        ]
        for (index, entry) in payloads.enumerated() {
            let command = AmbitionsCommand(
                id: "command.nested-id.\(index)", source: .system, typedPayload: entry.0,
                createdAt: "2026-07-24T12:00:00Z"
            )
            let encoded = try RuntimeCommandCodec().encode(command)
            let text = try XCTUnwrap(String(data: encoded, encoding: .utf8))
            let malformed = Data(text.replacingOccurrences(of: "\"\(entry.1)\"", with: "\" \(entry.1) \"").utf8)
            guard case .corrupt = RuntimeCommandCodec().decode(malformed) else {
                return XCTFail("Malformed nested identity must be corrupt")
            }
        }

        let invalidFresh = AmbitionsCommand(
            id: "command.invalid-fresh-nested-id", source: .system,
            typedPayload: .capture(CaptureCommand(
                action: .quickCapture(externalCreation: ExternalCreationProvenance(
                    requestID: " request-1 ", source: .appIntent, sourceApplication: nil, sourceURL: nil,
                    sourceType: .appIntent, landing: .captureComposer, provenanceHint: nil
                )), target: target, content: content
            )),
            createdAt: "2026-07-24T12:00:00Z"
        )
        XCTAssertThrowsError(try RuntimeCommandCodec().encode(invalidFresh))
        let invalidContent = AmbitionsCommand(
            id: "command.invalid-content-explanation", source: .system,
            typedPayload: .goal(GoalCommand(
                action: .update, target: AmbitionsCommandTarget(goalID: goal.id),
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Goal", explanationID: " explanation-1 "))
            )),
            createdAt: "2026-07-24T12:00:00Z"
        )
        XCTAssertThrowsError(try RuntimeCommandCodec().encode(invalidContent))
    }

    func testUnknownExternalOperationKindIsUnsupported() throws {
        let payload = RuntimeCommandPayload.externalOperation(ExternalOperationCommand(
            operationID: try RuntimeExternalOperationID(validating: "operation-unknown-kind"),
            kind: .reminder,
            target: AmbitionsCommandTarget(goalID: "goal-1"),
            title: "Reminder"
        ))
        let command = AmbitionsCommand(
            id: "command.unknown-external-kind", source: .system, typedPayload: payload,
            createdAt: "2026-07-24T12:00:00Z"
        )
        var object = try XCTUnwrap(JSONSerialization.jsonObject(with: RuntimeCommandCodec().encode(command)) as? [String: Any])
        XCTAssertTrue(Self.replaceFirstString(named: "kind", with: "futureExternalKind", in: &object))
        let bytes = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])

        guard case let .unsupported(issue) = RuntimeCommandCodec().decode(bytes) else {
            return XCTFail("Unknown external-operation kinds must be unsupported")
        }
        XCTAssertEqual(issue.reason, .unknownFamilyOrCase)
        XCTAssertEqual(issue.originalBytes, bytes)
    }

    func testMalformedKnownActionIsCorruptAndWhitespaceIdempotencyIsRejected() throws {
        let target = AmbitionsCommandTarget(goalID: "goal-1")
        let payload = RuntimeCommandPayload.goal(GoalCommand(
            action: .update, target: target,
            content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Goal"))
        ))
        let command = AmbitionsCommand(
            id: "command.malformed-known", source: .system, typedPayload: payload,
            createdAt: "2026-07-24T12:00:00Z"
        )
        let valid = try RuntimeCommandCodec().encode(command)
        var malformed = try XCTUnwrap(JSONSerialization.jsonObject(with: valid) as? [String: Any])
        malformed["provenance"] = ["source": "system"]
        let malformedBytes = try JSONSerialization.data(withJSONObject: malformed, options: [.sortedKeys])
        guard case .corrupt = RuntimeCommandCodec().decode(malformedBytes) else {
            return XCTFail("Malformed known action must be corrupt")
        }

        var whitespace = try XCTUnwrap(JSONSerialization.jsonObject(with: valid) as? [String: Any])
        whitespace["idempotencyKey"] = [
            "rawValue": " command.malformed-known ",
            "schemaVersion": commandIdempotencyKeySchemaVersion
        ]
        let whitespaceBytes = try JSONSerialization.data(withJSONObject: whitespace, options: [.sortedKeys])
        guard case .corrupt = RuntimeCommandCodec().decode(whitespaceBytes) else {
            return XCTFail("Whitespace-normalized idempotency keys must be corrupt")
        }

        var decomposed = try XCTUnwrap(JSONSerialization.jsonObject(with: valid) as? [String: Any])
        decomposed["idempotencyKey"] = [
            "rawValue": "e\u{301}",
            "schemaVersion": commandIdempotencyKeySchemaVersion
        ]
        let decomposedBytes = try JSONSerialization.data(withJSONObject: decomposed, options: [.sortedKeys])
        guard case .corrupt = RuntimeCommandCodec().decode(decomposedBytes) else {
            return XCTFail("Unicode-normalized idempotency keys must be corrupt")
        }
    }

    private static let legacyOpenDestinationFixture = """
    {
      "id": "legacy.command.open-today",
      "kind": "open_destination",
      "source": "widget",
      "target": {"destination":"today"},
      "payload": {"priorityHints":{},"metadata":{}},
      "validationState": "valid",
      "executionStatus": "pending",
      "createdAt": "2025-01-02T03:04:05Z",
      "requestedAt": "2025-01-02T03:04:05Z",
      "actor": "external_surface",
      "relations": {"goalIDs":[],"captureIDs":[],"timeIDs":[],"reviewIDs":[],"eventLedgerEntryIDs":[],"recommendationExplanationIDs":[]},
      "localOnly": false,
      "privacy": "private_user_text",
      "schemaVersion": "ambitions_command.native.v1"
    }
    """

    private static func replaceFirstAction(in object: inout [String: Any]) -> Bool {
        if object["action"] is String {
            object["action"] = "futureAction"
            return true
        }
        if object["action"] is [String: Any] {
            object["action"] = ["futureAction": [:]]
            return true
        }
        for key in object.keys {
            guard var nested = object[key] as? [String: Any] else { continue }
            if replaceFirstAction(in: &nested) {
                object[key] = nested
                return true
            }
        }
        return false
    }

    private static func replaceFirstString(
        named key: String,
        with replacement: String,
        in object: inout [String: Any]
    ) -> Bool {
        if object[key] is String {
            object[key] = replacement
            return true
        }
        for nestedKey in object.keys {
            guard var nested = object[nestedKey] as? [String: Any] else { continue }
            if replaceFirstString(named: key, with: replacement, in: &nested) {
                object[nestedKey] = nested
                return true
            }
        }
        return false
    }

    private static func fixtureCapture() -> Capture {
        Capture(
            id: "capture-1", createdAt: "2026-07-24T12:00:00Z", updatedAt: "2026-07-24T12:00:00Z",
            rawText: "Fixture capture", sourceType: .appIntent, status: .needsTriage, linkedGoalID: nil
        )
    }

    private static func base64<Value: Encodable>(_ value: Value) throws -> String {
        try JSONEncoder().encode(value).base64EncodedString()
    }

    private static func fixtureGoal() -> Goal {
        Goal(
            schemaVersion: goalEngineSchemaVersion,
            id: "goal-1",
            revision: 1,
            createdAt: "2026-07-24T12:00:00Z",
            updatedAt: "2026-07-24T12:00:00Z",
            state: .active,
            title: "Fixture goal",
            summary: nil,
            mode: .project,
            relationshipKind: .independent,
            actor: GoalActor(
                actorID: "actor.local", displayName: "Local", ownership: .self,
                roleLabel: nil, isPrimary: true
            ),
            parentGoalID: nil,
            childGoalIDs: [],
            supportGoalIDs: [],
            tags: [],
            timing: GoalTiming(
                tempo: .untimed, timingType: .suggestedNext, startsOn: nil, dueAt: nil,
                targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil,
                repeatEveryDays: nil, progressReviewCadenceDays: nil
            ),
            planningStrategy: PlanningStrategy(
                strategyKind: .adaptive, allowParallelSteps: true, maxActiveSteps: 1,
                preferredSectionOrder: [.activeSteps], defaultStepType: .actionUnit,
                autoGenerateReviewSection: false, preferShortSteps: true, revisitCadenceDays: nil
            ),
            progressStrategy: ProgressStrategy(
                metricKind: .stepCompletion, rollupMethod: .sum, targetStepCount: nil,
                targetEvidenceCount: nil, targetMinutes: nil, supportsUntimedProgress: true,
                countsChildGoals: false, countsSupportGoals: false
            ),
            plan: nil
        )
    }

    private static func legacyFixture(kind: AmbitionsCommandKind, metadata: [String: String]) throws -> Data {
        let object: [String: Any] = [
            "id": "legacy.command.\(kind.rawValue)", "kind": kind.rawValue, "source": "system",
            "target": [
                "goalID": "goal-1", "captureID": "capture-1", "timeID": "time-1", "reviewID": "review-1",
                "stepID": "step-1", "deliverableID": "deliverable-1", "scopeItemID": "scope-1",
                "recommendationID": "recommendation-1", "explanationID": "explanation-1", "destination": "today"
            ],
            "payload": [
                "rawText": "Legacy text", "title": "Legacy title", "deadlineText": "Tomorrow",
                "contextLens": "work", "priorityHints": ["urgency": "high"], "metadata": metadata
            ],
            "validationState": "valid", "executionStatus": "pending",
            "createdAt": "2025-01-02T03:04:05Z", "requestedAt": "2025-01-02T03:04:05Z",
            "actor": "system", "relations": [
                "goalIDs": [], "captureIDs": [], "timeIDs": [], "reviewIDs": [],
                "eventLedgerEntryIDs": [], "recommendationExplanationIDs": []
            ],
            "localOnly": true, "privacy": "standard", "schemaVersion": ambitionsCommandSchemaVersion
        ]
        return try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
    }

    private static let historicalV1CommandEnvelopeFixture = #"{"actor":"system","authorization":{"reasonCodes":[],"schemaVersion":"command_authorization.native.v1","sideEffectPolicy":"local_only","state":"authorized"},"command":{"actor":"system","createdAt":"2025-01-02T03:04:05Z","executionStatus":"pending","id":"legacy.command.quick_capture","kind":"quick_capture","localOnly":true,"payload":{"metadata":{},"priorityHints":{},"title":"Historical capture"},"privacy":"standard","relations":{"captureIDs":[],"eventLedgerEntryIDs":[],"goalIDs":[],"recommendationExplanationIDs":[],"reviewIDs":[],"timeIDs":[]},"requestedAt":"2025-01-02T03:04:05Z","schemaVersion":"ambitions_command.native.v1","source":"system","target":{},"validationState":"valid"},"id":"command.envelope.accepted_before_mutation.legacy.command.quick_capture","idempotencyKey":{"rawValue":"legacy.command.quick_capture","schemaVersion":"command_idempotency_key.native.v1"},"localOnly":true,"mutationPlan":{"canMutate":true,"commandID":"legacy.command.quick_capture","expectedProjectionIDs":[],"fallback":{"kind":"no_apply","summary":"Historical fallback"},"id":"command.mutation-plan.legacy.command.quick_capture","mutationKind":"runtime_mutation","reasonCodes":[],"requiredConfirmation":"not_required","schemaVersion":"command_mutation_plan.native.v1","sideEffectPolicy":"local_only","target":{},"undoShape":{"kind":"none","summary":"Historical undo","target":{}}},"phase":"accepted_before_mutation","privacy":"standard","receivedAt":"2025-01-02T03:04:05Z","schemaVersion":"command_envelope.native.v1","source":"system","target":{},"validationState":"valid"}"#
}
