import XCTest
@testable import Ambitions

final class EventLedgerModelsTests: XCTestCase {
    func testEventCreationAppliesSchemaPrivacyAndLocalOnlyDefaults() {
        let event = EventLedgerEntry(
            id: "event-goal-created",
            kind: .goalCreated,
            occurredAt: "2026-04-24T10:00:00Z",
            source: .goals,
            goalID: "goal-1",
            title: "Goal created"
        )

        XCTAssertEqual(event.schemaVersion, eventLedgerSchemaVersion)
        XCTAssertEqual(event.privacy, .standard)
        XCTAssertTrue(event.localOnly)
        XCTAssertEqual(event.createdAt, event.occurredAt)
        XCTAssertEqual(event.updatedAt, event.occurredAt)
        XCTAssertEqual(event.trust.isUserConfirmed, false)
    }

    func testEventKindTaxonomyCoversBatch65Foundation() {
        let kinds = Set(EventLedgerKind.allCases)

        XCTAssertTrue(kinds.isSuperset(of: [
            .goalCreated,
            .goalUpdated,
            .goalPaused,
            .goalCompleted,
            .goalArchived,
            .planCreated,
            .planUpdated,
            .planRescheduled,
            .planRecovered,
            .captureCreated,
            .captureTriaged,
            .captureAttachedToGoal,
            .captureArchived,
            .recoveryAccepted,
            .recoveryDeclined,
            .userCorrectionAdded,
            .reviewCompleted,
            .recommendationShown,
            .recommendationAccepted,
            .recommendationDismissed,
            .calendarContextObserved,
            .syncConflictDetected,
            .accessibilityAuditRecorded
        ]))
    }

    func testEventKindTaxonomyCoversFutureRealityAndScopeFoundation() {
        let kinds = Set(EventLedgerKind.allCases)

        XCTAssertTrue(kinds.isSuperset(of: [
            .priorityChanged,
            .urgencyChanged,
            .commitmentCaptured,
            .commitmentRouted,
            .contextLensChanged,
            .contextInferred,
            .goalScopeItemAdded,
            .goalScopeItemRemoved,
            .deliverableAdded,
            .deliverableRemoved,
            .deadlineChanged,
            .itemScheduled,
            .itemDisplacedByHigherPriority,
            .recoveryDueToPriorityConflict
        ]))
    }

    func testFeedbackAdapterMapsExistingHistoryWithoutMutatingIt() {
        let feedback = GoalFeedbackEvent.skipped(
            base: GoalFeedbackEventBase(
                id: "feedback-1",
                stepID: "step-1",
                occurredAt: "2026-04-24T11:00:00Z",
                note: "Not now"
            ),
            reasonCode: .notNow
        )

        let event = EventLedgerEntry.fromFeedbackEvent(feedback, goalID: "goal-1")

        XCTAssertEqual(event.id, "ledger.feedback.feedback-1")
        XCTAssertEqual(event.kind, .actionSkipped)
        XCTAssertEqual(event.goalID, "goal-1")
        XCTAssertEqual(event.metadata["legacyKind"], GoalHistoryEventKind.skipped.rawValue)
        XCTAssertEqual(event.metadata["stepID"], "step-1")
        XCTAssertEqual(event.evidenceReferences.map(\.kind), [.feedbackEvent])
        XCTAssertEqual(event.privacy, .privateUserText)
    }

    func testProgressEvidenceAndTeachingAdaptersPreserveReferences() {
        let evidence = ProgressEvidence(
            id: "evidence-1",
            goalID: "goal-1",
            stepID: "step-1",
            evidenceKind: .stepCompleted,
            source: .manual,
            capturedAt: "2026-04-24T12:00:00Z",
            progressDelta: 0.2,
            confidenceDelta: 0.1,
            minutesInvested: 25,
            note: nil
        )
        let teaching = GoalTeachingSignal(
            id: "teaching-1",
            goalID: "goal-1",
            createdAt: "2026-04-24T12:30:00Z",
            updatedAt: "2026-04-24T12:30:00Z",
            source: .explicitManualCorrection,
            kind: .goalSubjectCorrection,
            disposition: .active,
            anchor: GoalTeachingStableAnchor(
                artifactKind: .goalSubjectField,
                canonicalField: .goalSubject,
                candidateID: nil,
                stageID: nil,
                stepID: nil,
                targetFingerprint: "goal_subject",
                contradictionCode: nil,
                contradictionArtifactRefs: []
            ),
            payload: .goalSubject(GoalTeachingGoalSubjectCorrection(correctedCanonicalIntent: "Finish the draft")),
            applicationKey: "goal-1##goal_subject",
            userNote: nil
        )

        let evidenceEvent = EventLedgerEntry.fromProgressEvidence(evidence)
        let teachingEvent = EventLedgerEntry.fromTeachingSignal(teaching)

        XCTAssertEqual(evidenceEvent.kind, .actionCompleted)
        XCTAssertEqual(evidenceEvent.evidenceReferences.first?.id, evidence.id)
        XCTAssertEqual(evidenceEvent.trust.confidenceLabel, .medium)
        XCTAssertEqual(teachingEvent.kind, .userCorrectionAdded)
        XCTAssertEqual(teachingEvent.evidenceReferences.first?.id, teaching.id)
        XCTAssertEqual(teachingEvent.trust.isUserConfirmed, true)
    }

    func testDiagnosticLedgerDerivesFromEventLedgerInputDeterministically() {
        let unsortedEventLedger: [EventLedgerEntry] = [
            EventLedgerEntry(
                id: "ledger.goal.updated",
                kind: .goalUpdated,
                occurredAt: "2026-05-12T12:10:00Z",
                source: .goals,
                goalID: "goal-1",
                title: "Goal updated"
            ),
            EventLedgerEntry(
                id: "ledger.goal.created",
                kind: .goalCreated,
                occurredAt: "2026-05-12T12:00:00Z",
                source: .goals,
                goalID: "goal-1",
                title: "Goal created"
            )
        ]

        let snapshot = DiagnosticLedgerSnapshot(
            eventLedger: unsortedEventLedger,
            sideEffectLedger: [],
            privacyClassifications: [],
            generatedAt: "2026-05-12T12:30:00Z"
        )

        XCTAssertEqual(snapshot.schemaVersion, diagnosticLedgerSchemaVersion)
        XCTAssertEqual(snapshot.entries.map(\.sourceRecordID), [
            "ledger.goal.created",
            "ledger.goal.updated"
        ])
        XCTAssertEqual(snapshot.entries.first?.signal, .eventLedger)
        XCTAssertEqual(snapshot.entries.first?.isAttentionRequired, false)
        XCTAssertTrue(snapshot.requiresAttention == false)
    }
}
