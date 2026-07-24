import AmbitionsRuntimeCore
import AmbitionsDesignSystem
import Foundation
@testable import Ambitions
import XCTest

final class RuntimeSemanticEventCodecTests: XCTestCase {
    func testManualRegistryContainsEveryStableTypeAndAggregateMapping() {
        let expected: [(RuntimeSemanticEventTypeID, RuntimeSemanticAggregateKind)] = [
            (.captureCreated, .capture), (.captureCommitmentRouted, .capture),
            (.captureAttachedToGoal, .capture), (.captureMarkedWaiting, .capture),
            (.captureArchived, .capture), (.goalCreated, .goal), (.goalUpdated, .goal),
            (.goalPrioritySet, .goal), (.goalUrgencySet, .goal), (.goalDeadlineSet, .goal),
            (.goalContextLensSet, .goal), (.goalContextLensCleared, .goal),
            (.goalDeliverableAdded, .goal), (.goalDeliverableRemoved, .goal),
            (.goalScopeItemAdded, .goal), (.goalScopeItemRemoved, .goal),
            (.stepSessionStarted, .step), (.stepCompleted, .step), (.stepDelayed, .step),
            (.stepSplit, .step), (.stepRecovered, .step), (.stepTodayActionApplied, .step),
            (.scheduleItemCreated, .schedule), (.scheduleItemScheduled, .schedule),
            (.scheduleStepPlaced, .schedule), (.scheduleWindowProtected, .schedule),
            (.scheduleWindowCorrected, .schedule), (.scheduleMutationUndone, .schedule),
            (.scheduleRitualApplied, .schedule), (.scheduleCalendarWriteCommitted, .schedule),
            (.reminderCreated, .reminder), (.reminderUpdated, .reminder),
            (.reminderDeleted, .reminder), (.profilePreferencesUpdated, .profile),
            (.historyRecommendationDismissed, .history), (.historyTodayReceiptRecorded, .history),
            (.repairRecovered, .repair), (.objectDeleted, .importDeletion),
            (.memoryForgotten, .importDeletion), (.externalReminderRequested, .externalOperation),
            (.externalCalendarEventRequested, .externalOperation),
        ]
        let expectedRawTypeIDs = [
            "ambitions.capture.created", "ambitions.capture.commitment_routed",
            "ambitions.capture.attached_to_goal", "ambitions.capture.marked_waiting",
            "ambitions.capture.archived", "ambitions.goal.created", "ambitions.goal.updated",
            "ambitions.goal.priority_set", "ambitions.goal.urgency_set", "ambitions.goal.deadline_set",
            "ambitions.goal.context_lens_set", "ambitions.goal.context_lens_cleared",
            "ambitions.goal.deliverable_added", "ambitions.goal.deliverable_removed",
            "ambitions.goal.scope_item_added", "ambitions.goal.scope_item_removed",
            "ambitions.step.session_started", "ambitions.step.completed", "ambitions.step.delayed",
            "ambitions.step.split", "ambitions.step.recovered", "ambitions.step.today_action_applied",
            "ambitions.schedule.item_created", "ambitions.schedule.item_scheduled",
            "ambitions.schedule.step_placed", "ambitions.schedule.window_protected",
            "ambitions.schedule.window_corrected", "ambitions.schedule.mutation_undone",
            "ambitions.schedule.ritual_applied", "ambitions.schedule.calendar_write_committed",
            "ambitions.reminder.created", "ambitions.reminder.updated", "ambitions.reminder.deleted",
            "ambitions.profile.preferences_updated", "ambitions.history.recommendation_dismissed",
            "ambitions.history.today_receipt_recorded", "ambitions.repair.recovered",
            "ambitions.object.deleted", "ambitions.memory.forgotten",
            "ambitions.external.reminder_requested", "ambitions.external.calendar_event_requested",
        ]

        XCTAssertEqual(expected.map(\.0), RuntimeSemanticEventTypeID.allCases)
        XCTAssertEqual(expected.map { $0.0.rawValue }, expectedRawTypeIDs)
        XCTAssertEqual(Set(expected.map(\.0)), RuntimeSemanticEventRegistry.allRegisteredTypeIDs)
        XCTAssertEqual(RuntimeSemanticEventRegistry.registeredUpcasterVersions, [.captureCreated: [0]])
        for (typeID, aggregateKind) in expected {
            XCTAssertEqual(typeID.aggregateKind, aggregateKind, typeID.rawValue)
            XCTAssertEqual(typeID.latestPayloadVersion, 2, typeID.rawValue)
        }
    }

    func testGoalCaseSpecificFactsAreCanonicalAndReplayable() throws {
        let deadline = try goalEvent(
            typeID: .goalDeadlineSet,
            action: .setDeadline,
            content: AmbitionsCommandPayload(deadlineText: "2026-08-01")
        )
        let priority = try goalEvent(
            typeID: .goalPrioritySet,
            action: .setPriority,
            content: AmbitionsCommandPayload(priorityHints: AmbitionsCommandPriorityHints(importance: .high))
        )
        let codec = RuntimeSemanticEventCodec()

        for event in [deadline, priority] {
            let first = try codec.encode(event)
            let second = try codec.encode(event)
            XCTAssertEqual(first, second)
            XCTAssertEqual(SHA256Digest.digest(first), SHA256Digest.digest(second))
            XCTAssertEqual(try codec.decode(first).event, event)
        }
    }

    func testFamilyPayloadRejectsCaseMismatchAndRevisionGap() throws {
        let wrongType = try mutation(typeID: .goalPrioritySet, prior: 0, result: 1)
        XCTAssertThrowsError(
            try RuntimeGoalMutationPayload(
                mutation: wrongType,
                facts: GoalCommand(
                    action: .setDeadline,
                    target: AmbitionsCommandTarget(goalID: "goal-1"),
                    content: RuntimeCommandContent(AmbitionsCommandPayload(deadlineText: "tomorrow"))
                )
            )
        )
        let validUpdatePayload = try RuntimeGoalMutationPayload(
            mutation: try mutation(typeID: .goalUpdated, prior: 0, result: 1),
            facts: GoalCommand(
                action: .update,
                target: AmbitionsCommandTarget(goalID: "goal-1"),
                content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Updated"))
            )
        )
        XCTAssertThrowsError(
            try RuntimeSemanticEventCodec().encode(.goal(.created(validUpdatePayload)))
        ) {
            XCTAssertEqual($0 as? RuntimeSemanticEventCodecError, .invalidPayload)
        }
        XCTAssertThrowsError(
            try RuntimeSemanticMutation(
                semanticType: .goalUpdated,
                aggregateID: RuntimeAggregateID(validating: "goal-1"),
                priorRevision: 3,
                resultingRevision: 5,
                changedObjectIDs: []
            )
        )
    }

    func testScheduleReceiptDeleteAndProfileFactsSurviveCanonicalRoundTrip() throws {
        let scheduleMutation = try RuntimeSemanticMutation(
            semanticType: .scheduleStepPlaced,
            aggregateID: RuntimeAggregateID(validating: "schedule-1"),
            priorRevision: 0,
            resultingRevision: 1,
            changedObjectIDs: [RuntimeDomainObjectID(validating: "step-1")]
        )
        let schedule = RuntimeSemanticEvent.schedule(.stepPlaced(
            try RuntimeScheduleMutationPayload(
                mutation: scheduleMutation,
                facts: ScheduleCommand(
                    action: .placeStep(TimePlacementCommandIntent(
                        start: "2026-08-01T09:00:00Z",
                        end: "2026-08-01T10:00:00Z",
                        approvedDurationMinutes: 60,
                        contextLens: nil,
                        relatedGoalID: RuntimeCommandObjectID(rawValue: "goal-1"),
                        relatedCaptureID: nil
                    )),
                    target: AmbitionsCommandTarget(timeID: "schedule-1", stepID: "step-1"),
                    content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Deep work"))
                )
            )
        ))
        let receipt = ActionReceipt(
            id: "receipt-1",
            resultState: .completed,
            title: "Step closed",
            summary: "The committed step was completed.",
            sourceDomain: .today,
            occurredAt: "2026-08-01T10:00:00Z",
            affectedObjects: [LifeGraphObjectReference(kind: .step, id: "step-1")]
        )
        let historyMutation = try RuntimeSemanticMutation(
            semanticType: .historyTodayReceiptRecorded,
            aggregateID: RuntimeAggregateID(validating: "history-1"),
            priorRevision: 0,
            resultingRevision: 1,
            changedObjectIDs: [RuntimeDomainObjectID(validating: "receipt-1")]
        )
        let history = RuntimeSemanticEvent.history(.todayReceiptRecorded(
            try RuntimeHistoryMutationPayload(
                mutation: historyMutation,
                facts: HistoryCommand(
                    action: .todayReceipt(TodayReceiptDomainEvent(
                        kind: .closure,
                        receipt: receipt,
                        privacyLevel: .safeToShow,
                        localOnly: true,
                        proofRelevance: .notProof,
                        requiresConfirmationBeforeBroaderUse: false
                    )),
                    target: AmbitionsCommandTarget(reviewID: "history-1"),
                    content: RuntimeCommandContent()
                )
            )
        ))
        let deletionMutation = try RuntimeSemanticMutation(
            semanticType: .objectDeleted,
            aggregateID: RuntimeAggregateID(validating: "deletion-1"),
            priorRevision: 0,
            resultingRevision: 1,
            changedObjectIDs: [RuntimeDomainObjectID(validating: "goal-1")]
        )
        let deletion = RuntimeSemanticEvent.importDeletion(.objectDeleted(
            try RuntimeImportDeletionMutationPayload(
                mutation: deletionMutation,
                facts: ImportDeletionCommand(
                    action: .deleteObject,
                    target: AmbitionsCommandTarget(goalID: "goal-1"),
                    content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Deleted goal"))
                )
            )
        ))
        let profileMutation = try RuntimeSemanticMutation(
            semanticType: .profilePreferencesUpdated,
            aggregateID: RuntimeAggregateID(validating: "profile-1"),
            priorRevision: 0,
            resultingRevision: 1,
            changedObjectIDs: [RuntimeDomainObjectID(validating: "profile-1")]
        )
        let profile = RuntimeSemanticEvent.profile(.preferencesUpdated(
            try RuntimeProfileMutationPayload(
                mutation: profileMutation,
                facts: ProfileCommand(
                    action: .updatePreferences,
                    target: AmbitionsCommandTarget(),
                    content: RuntimeCommandContent(),
                    preferences: ProfilePreferencesCommandValues(
                        preferredTab: .today,
                        appearancePreference: .dark,
                        accentFamily: .sage,
                        reviewCadenceDays: 7,
                        localOnlyModeEnabled: true
                    )
                )
            )
        ))

        for event in [schedule, history, deletion, profile] {
            let bytes = try RuntimeSemanticEventCodec().encode(event)
            XCTAssertEqual(try RuntimeSemanticEventCodec().decode(bytes).event, event)
        }
    }

    func testFixedLiteralV0CaptureFixtureUpcastsWithoutSourceRewrite() throws {
        let source = Data(
            #"{"envelope_version":1,"payload":"eyJhIjoiYSIsImIiOiJhIiwiciI6MCwidCI6IngifQ==","payload_version":0,"type_id":"ambitions.capture.created"}"#.utf8
        )

        let decoded = try RuntimeSemanticEventCodec().decode(source)

        XCTAssertEqual(decoded.event.typeID, .captureCreated)
        XCTAssertEqual(decoded.event.mutation.aggregateID.rawValue, "a")
        XCTAssertNil(decoded.event.mutation.priorRevision)
        XCTAssertEqual(decoded.event.mutation.resultingRevision, 0)
        XCTAssertEqual(decoded.sourceBytes, source)
        XCTAssertEqual(decoded.sourcePayloadVersion, 0)
        XCTAssertTrue(decoded.wasUpcast)
        let rewritten = try RuntimeSemanticEventCodec().encode(decoded.event)
        XCTAssertNotEqual(rewritten, source)
        XCTAssertEqual(try RuntimeSemanticEventCodec().inspectHeader(rewritten).payloadVersion, 1)
    }

    func testUnknownFutureCorruptMismatchNoncanonicalAndOversizeAreDistinct() throws {
        let canonical = try RuntimeSemanticEventCodec().encode(
            goalEvent(typeID: .goalUpdated, action: .update)
        )
        let unknown = canonical.replacingUTF8("ambitions.goal.updated", with: "ambitions.goal.future")
        let futureEnvelope = canonical.replacingUTF8("\"envelope_version\":1", with: "\"envelope_version\":2")
        let futurePayload = canonical.replacingUTF8("\"payload_version\":1", with: "\"payload_version\":999")
        let mismatch = canonical.replacingUTF8("ambitions.goal.updated", with: "ambitions.goal.created", maximumReplacementCount: 1)

        assertCodecError(.unknownType, bytes: unknown)
        assertCodecError(.futureEnvelopeVersion, bytes: futureEnvelope)
        assertCodecError(.futurePayloadVersion, bytes: futurePayload)
        assertCodecError(.typeMismatch, bytes: mismatch)
        assertCodecError(.truncatedEnvelope, bytes: Data(canonical.dropLast()))
        assertCodecError(.corruptEnvelope, bytes: Data("not-json".utf8))
        assertCodecError(.nonCanonicalBytes, bytes: Data(" ".utf8) + canonical)
        assertCodecError(
            .envelopeTooLarge,
            bytes: Data(repeating: 0x41, count: 33),
            codec: RuntimeSemanticEventCodec(limits: .init(maximumEnvelopeBytes: 32, maximumPayloadBytes: 32))
        )
    }

    func testEveryClassifierOutcomeIsManuallyAccountedFor() {
        XCTAssertEqual(
            RuntimeSemanticEventClassifier.allMutationTypeIDs,
            Set([
                .captureCreated, .captureCommitmentRouted, .captureAttachedToGoal, .captureMarkedWaiting,
                .captureArchived, .goalCreated, .goalUpdated, .goalPrioritySet, .goalUrgencySet,
                .goalDeadlineSet, .goalContextLensSet, .goalContextLensCleared, .goalDeliverableAdded,
                .goalDeliverableRemoved, .goalScopeItemAdded, .goalScopeItemRemoved, .stepSessionStarted,
                .stepCompleted, .stepDelayed, .stepSplit, .stepRecovered, .stepTodayActionApplied,
                .scheduleItemCreated, .scheduleItemScheduled, .scheduleStepPlaced, .scheduleWindowProtected,
                .scheduleWindowCorrected, .scheduleMutationUndone, .scheduleRitualApplied,
                .scheduleCalendarWriteCommitted, .reminderCreated, .reminderUpdated, .reminderDeleted,
                .profilePreferencesUpdated, .historyRecommendationDismissed, .historyTodayReceiptRecorded,
                .repairRecovered, .objectDeleted, .memoryForgotten, .externalReminderRequested,
                .externalCalendarEventRequested,
            ])
        )
        XCTAssertEqual(
            RuntimeSemanticEventClassifier.explicitNonMutatingClassifications,
            Set([.navigation, .inspection, .exportPreparation, .exportExecution])
        )
    }

    func testCodecErrorsDoNotRenderPrivateSource() {
        let sentinel = "private deadline and profile values"
        XCTAssertThrowsError(try RuntimeSemanticEventCodec().decode(Data(sentinel.utf8))) { error in
            XCTAssertFalse(String(describing: error).contains(sentinel))
            XCTAssertFalse(error.localizedDescription.contains(sentinel))
        }
    }

    private func goalEvent(
        typeID: RuntimeSemanticEventTypeID,
        action: GoalCommand.Action,
        content: AmbitionsCommandPayload = AmbitionsCommandPayload()
    ) throws -> RuntimeSemanticEvent {
        let payload = try RuntimeGoalMutationPayload(
            mutation: mutation(typeID: typeID, prior: 0, result: 1),
            facts: GoalCommand(
                action: action,
                target: AmbitionsCommandTarget(goalID: "goal-1"),
                content: RuntimeCommandContent(content)
            )
        )
        return switch typeID {
        case .goalCreated: .goal(.created(payload))
        case .goalUpdated: .goal(.updated(payload))
        case .goalPrioritySet: .goal(.prioritySet(payload))
        case .goalUrgencySet: .goal(.urgencySet(payload))
        case .goalDeadlineSet: .goal(.deadlineSet(payload))
        case .goalContextLensSet: .goal(.contextLensSet(payload))
        case .goalContextLensCleared: .goal(.contextLensCleared(payload))
        case .goalDeliverableAdded: .goal(.deliverableAdded(payload))
        case .goalDeliverableRemoved: .goal(.deliverableRemoved(payload))
        case .goalScopeItemAdded: .goal(.scopeItemAdded(payload))
        case .goalScopeItemRemoved: .goal(.scopeItemRemoved(payload))
        default: throw RuntimeSemanticEventCodecError.typeMismatch
        }
    }

    private func mutation(
        typeID: RuntimeSemanticEventTypeID,
        prior: UInt64?,
        result: UInt64
    ) throws -> RuntimeSemanticMutation {
        try RuntimeSemanticMutation(
            semanticType: typeID,
            aggregateID: RuntimeAggregateID(validating: "goal-1"),
            priorRevision: prior,
            resultingRevision: result,
            changedObjectIDs: [
                RuntimeDomainObjectID(validating: "goal-1"),
                RuntimeDomainObjectID(validating: "goal-1"),
            ]
        )
    }

    private func assertCodecError(
        _ expected: RuntimeSemanticEventCodecError,
        bytes: Data,
        codec: RuntimeSemanticEventCodec = RuntimeSemanticEventCodec(),
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertThrowsError(try codec.decode(bytes), file: file, line: line) {
            XCTAssertEqual($0 as? RuntimeSemanticEventCodecError, expected, file: file, line: line)
        }
    }
}

private extension Data {
    func replacingUTF8(_ source: String, with replacement: String, maximumReplacementCount: Int = .max) -> Data {
        let value = String(decoding: self, as: UTF8.self)
        var remaining = value[...]
        var result = ""
        var count = 0
        while count < maximumReplacementCount, let range = remaining.range(of: source) {
            result += remaining[..<range.lowerBound]
            result += replacement
            remaining = remaining[range.upperBound...]
            count += 1
        }
        result += remaining
        return Data(result.utf8)
    }
}
