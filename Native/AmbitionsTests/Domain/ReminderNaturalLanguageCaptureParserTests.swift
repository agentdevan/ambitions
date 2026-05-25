import XCTest
@testable import Ambitions

final class ReminderNaturalLanguageCaptureParserTests: XCTestCase {
    func testParserCoversTheReminderP0PhraseMatrixAndLocalInspectionBoundary() throws {
        let parser = ReminderNaturalLanguageCaptureParser()
        let fixture = makeFixture()

        let parsedTomorrow = try XCTUnwrap(
            parser.parse(
                "tomorrow at 9",
                sourceRecord: fixture.sourceRecord,
                sourceObject: fixture.sourceObject,
                receipt: fixture.receipt,
                replayTrace: fixture.replayTrace
            )
        )

        XCTAssertEqual(parsedTomorrow.rawText, "tomorrow at 9")
        XCTAssertEqual(parsedTomorrow.normalizedText, "tomorrow at 9")
        XCTAssertEqual(parsedTomorrow.title, "tomorrow at 9")
        XCTAssertEqual(parsedTomorrow.semanticKind, .concreteReminder)
        XCTAssertEqual(parsedTomorrow.triggerKind, .manual)
        XCTAssertEqual(parsedTomorrow.state, .scheduled)
        XCTAssertEqual(parsedTomorrow.deliveryPolicy, .localNotification)
        XCTAssertEqual(parsedTomorrow.timingPhrase, "tomorrow at 9")
        XCTAssertNil(parsedTomorrow.recurrencePhrase)
        XCTAssertNil(parsedTomorrow.waitingOn)
        XCTAssertNil(parsedTomorrow.followUpText)
        XCTAssertFalse(parsedTomorrow.needsReview)
        XCTAssertNil(parsedTomorrow.reviewReason)
        XCTAssertEqual(parsedTomorrow.sourceRecordID, fixture.sourceRecord.id)
        XCTAssertEqual(parsedTomorrow.receiptID, fixture.receipt.id)
        XCTAssertEqual(parsedTomorrow.replayTraceID, fixture.replayTrace.id)
        XCTAssertEqual(parsedTomorrow.source.localReminderYouInspectionSummary, "You / What Ambitions knows can inspect this SourceRecord, Receipt, and ReplayTrace.")
        XCTAssertEqual(parsedTomorrow.inspectionBoundary.surfaceTitle, "What Ambitions knows")
        XCTAssertTrue(parsedTomorrow.inspectionBoundary.isInspectableBoundary)
        XCTAssertTrue(parsedTomorrow.source.notes.contains("timing: tomorrow at 9"))
        XCTAssertFalse(parsedTomorrow.source.notes.contains("review: A date was found, but no time of day was supplied."))

        let scenarios: [(input: String, expectation: ExpectedReminderParse)] = [
            (
                input: "tomorrow, at 9",
                expectation: ExpectedReminderParse(
                    semanticKind: .concreteReminder,
                    triggerKind: .manual,
                    state: .scheduled,
                    timingPhraseContains: "tomorrow, at 9",
                    recurrencePhraseContains: nil,
                    waitingOnContains: nil,
                    followUpTextContains: nil,
                    needsReview: false,
                    reviewReasonContains: nil
                )
            ),
            (
                input: "every Monday",
                expectation: ExpectedReminderParse(
                    semanticKind: .recurringReminder,
                    triggerKind: .recurring,
                    state: .draft,
                    timingPhraseContains: nil,
                    recurrencePhraseContains: "every Monday",
                    waitingOnContains: nil,
                    followUpTextContains: nil,
                    needsReview: true,
                    reviewReasonContains: "recurrence"
                )
            ),
            (
                input: "follow up next week",
                expectation: ExpectedReminderParse(
                    semanticKind: .concreteReminder,
                    triggerKind: .manual,
                    state: .draft,
                    timingPhraseContains: "next week",
                    recurrencePhraseContains: nil,
                    waitingOnContains: nil,
                    followUpTextContains: "follow up next week",
                    needsReview: true,
                    reviewReasonContains: "follow-up"
                )
            ),
            (
                input: "waiting on response, follow up next week",
                expectation: ExpectedReminderParse(
                    semanticKind: .waitingReminder,
                    triggerKind: .manual,
                    state: .waiting,
                    timingPhraseContains: "next week",
                    recurrencePhraseContains: nil,
                    waitingOnContains: "response",
                    followUpTextContains: "follow up next week",
                    needsReview: true,
                    reviewReasonContains: "follow-up"
                )
            ),
            (
                input: "blocked by approval, follow up Friday at 9",
                expectation: ExpectedReminderParse(
                    semanticKind: .waitingReminder,
                    triggerKind: .manual,
                    state: .blocked,
                    timingPhraseContains: "Friday at 9",
                    recurrencePhraseContains: nil,
                    waitingOnContains: "approval",
                    followUpTextContains: "follow up Friday at 9",
                    needsReview: false,
                    reviewReasonContains: nil
                )
            ),
            (
                input: "pay rent monthly",
                expectation: ExpectedReminderParse(
                    semanticKind: .recurringReminder,
                    triggerKind: .recurring,
                    state: .draft,
                    timingPhraseContains: nil,
                    recurrencePhraseContains: "monthly",
                    waitingOnContains: nil,
                    followUpTextContains: nil,
                    needsReview: true,
                    reviewReasonContains: "recurrence"
                )
            ),
            (
                input: "call person Friday",
                expectation: ExpectedReminderParse(
                    semanticKind: .concreteReminder,
                    triggerKind: .manual,
                    state: .draft,
                    timingPhraseContains: "Friday",
                    recurrencePhraseContains: nil,
                    waitingOnContains: nil,
                    followUpTextContains: nil,
                    needsReview: true,
                    reviewReasonContains: "time of day"
                )
            ),
            (
                input: "waiting on response",
                expectation: ExpectedReminderParse(
                    semanticKind: .waitingReminder,
                    triggerKind: .manual,
                    state: .waiting,
                    timingPhraseContains: nil,
                    recurrencePhraseContains: nil,
                    waitingOnContains: "response",
                    followUpTextContains: nil,
                    needsReview: false,
                    reviewReasonContains: nil
                )
            )
        ]

        for scenario in scenarios {
            let parsed = try XCTUnwrap(
                parser.parse(
                    scenario.input,
                    sourceRecord: fixture.sourceRecord,
                    sourceObject: fixture.sourceObject
                )
            )
            assertParse(parsed: parsed, matches: scenario.expectation, input: scenario.input)
        }
    }

    func testAmbiguousReminderLanguageStaysInReviewEvenWhenAClockTimeIsPresent() throws {
        let parser = ReminderNaturalLanguageCaptureParser()
        let fixture = makeFixture()

        let parsedMaybeTomorrow = try XCTUnwrap(
            parser.parse(
                "maybe tomorrow at 9",
                sourceRecord: fixture.sourceRecord,
                sourceObject: fixture.sourceObject
            )
        )
        assertParse(
            parsed: parsedMaybeTomorrow,
            matches: ExpectedReminderParse(
                semanticKind: .concreteReminder,
                triggerKind: .manual,
                state: .draft,
                timingPhraseContains: "tomorrow at 9",
                recurrencePhraseContains: nil,
                waitingOnContains: nil,
                followUpTextContains: nil,
                needsReview: true,
                reviewReasonContains: "ambiguous"
            ),
            input: "maybe tomorrow at 9"
        )

        let parsedPlainAmbiguous = try XCTUnwrap(
            parser.parse(
                "maybe remind me",
                sourceRecord: fixture.sourceRecord,
                sourceObject: fixture.sourceObject
            )
        )
        assertParse(
            parsed: parsedPlainAmbiguous,
            matches: ExpectedReminderParse(
                semanticKind: .reviewNeeded,
                triggerKind: .manual,
                state: .draft,
                timingPhraseContains: nil,
                recurrencePhraseContains: nil,
                waitingOnContains: nil,
                followUpTextContains: nil,
                needsReview: true,
                reviewReasonContains: "ambiguous"
            ),
            input: "maybe remind me"
        )
    }
}

private extension ReminderNaturalLanguageCaptureParserTests {
    struct ExpectedReminderParse {
        let semanticKind: ReminderCaptureSemanticKind
        let triggerKind: ReminderTriggerKind
        let state: ReminderState
        let timingPhraseContains: String?
        let recurrencePhraseContains: String?
        let waitingOnContains: String?
        let followUpTextContains: String?
        let needsReview: Bool
        let reviewReasonContains: String?
    }

    func assertParse(
        parsed result: ReminderNaturalLanguageCaptureParseResult,
        matches expectation: ExpectedReminderParse,
        input: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(result.semanticKind, expectation.semanticKind, file: file, line: line)
        XCTAssertEqual(result.triggerKind, expectation.triggerKind, file: file, line: line)
        XCTAssertEqual(result.state, expectation.state, file: file, line: line)
        XCTAssertEqual(result.needsReview, expectation.needsReview, file: file, line: line)

        if let timingPhraseContains = expectation.timingPhraseContains {
            XCTAssertNotNil(result.timingPhrase, file: file, line: line)
            XCTAssertTrue(
                result.timingPhrase?.localizedCaseInsensitiveContains(timingPhraseContains) == true,
                file: file,
                line: line
            )
            XCTAssertTrue(
                result.source.notes.contains(where: {
                    $0.localizedCaseInsensitiveContains("timing:") && $0.localizedCaseInsensitiveContains(timingPhraseContains)
                }),
                file: file,
                line: line
            )
        } else {
            XCTAssertNil(result.timingPhrase, file: file, line: line)
        }

        if let recurrencePhraseContains = expectation.recurrencePhraseContains {
            XCTAssertNotNil(result.recurrencePhrase, file: file, line: line)
            XCTAssertTrue(
                result.recurrencePhrase?.localizedCaseInsensitiveContains(recurrencePhraseContains) == true,
                file: file,
                line: line
            )
            XCTAssertTrue(
                result.source.notes.contains(where: {
                    $0.localizedCaseInsensitiveContains("recurrence:") && $0.localizedCaseInsensitiveContains(recurrencePhraseContains)
                }),
                file: file,
                line: line
            )
        } else {
            XCTAssertNil(result.recurrencePhrase, file: file, line: line)
        }

        if let waitingOnContains = expectation.waitingOnContains {
            XCTAssertNotNil(result.waitingOn, file: file, line: line)
            XCTAssertTrue(
                result.waitingOn?.localizedCaseInsensitiveContains(waitingOnContains) == true,
                file: file,
                line: line
            )
            XCTAssertTrue(
                result.source.notes.contains(where: {
                    ($0.localizedCaseInsensitiveContains("waiting on:") || $0.localizedCaseInsensitiveContains("blocked by:"))
                        && $0.localizedCaseInsensitiveContains(waitingOnContains)
                }),
                file: file,
                line: line
            )
        } else {
            XCTAssertNil(result.waitingOn, file: file, line: line)
        }

        if let followUpTextContains = expectation.followUpTextContains {
            XCTAssertNotNil(result.followUpText, file: file, line: line)
            XCTAssertTrue(
                result.followUpText?.localizedCaseInsensitiveContains(followUpTextContains) == true,
                file: file,
                line: line
            )
            XCTAssertTrue(
                result.source.notes.contains(where: {
                    $0.localizedCaseInsensitiveContains("follow up:") && $0.localizedCaseInsensitiveContains(followUpTextContains)
                }),
                file: file,
                line: line
            )
        } else {
            XCTAssertNil(result.followUpText, file: file, line: line)
        }

        if let reviewReasonContains = expectation.reviewReasonContains {
            XCTAssertNotNil(result.reviewReason, file: file, line: line)
            XCTAssertTrue(
                result.reviewReason?.localizedCaseInsensitiveContains(reviewReasonContains) == true,
                file: file,
                line: line
            )
            XCTAssertTrue(
                result.source.notes.contains(where: { $0.localizedCaseInsensitiveContains("review:") }),
                "Expected \(input) to carry a review note in the local source graph.",
                file: file,
                line: line
            )
        } else {
            XCTAssertNil(result.reviewReason, file: file, line: line)
        }
    }

    func makeFixture() -> ReminderParseFixture {
        let sourceRecord = ReminderSourceRecord(
            id: "source.reminders.p0",
            entityTitle: "Reminder source",
            locator: "local://reminders/p0",
            provenanceKind: .manual,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .step,
            id: "reminder.step.p0",
            label: "Reminder step",
            sourceDomain: .today
        )
        let reminderObject = LifeGraphObjectReference(
            kind: .step,
            id: "reminder.step.p0",
            label: "Reminder step",
            sourceDomain: .today
        )
        let sourceGraphObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let receipt = ActionReceipt(
            id: "receipt.reminders.p0",
            resultState: .completed,
            title: "Reminder captured",
            summary: "Reminder capture stayed local.",
            sourceDomain: .today,
            occurredAt: "2026-05-24T08:00:00Z",
            affectedObjects: [reminderObject],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceGraphObject
        )
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: "proof.receipt.reminders.p0"
        )

        return ReminderParseFixture(
            sourceRecord: sourceRecord,
            sourceObject: sourceObject,
            receipt: receipt,
            replayTrace: replayTrace
        )
    }

    func makeReplayTrace(
        sourceRecordID: String,
        receiptID: String,
        proofReferenceID: String
    ) -> ReplayableDecisionTrace {
        let runtimeContext = RuntimeContextSnapshot(
            clientContext: .iphoneApp,
            capabilities: .currentLocalRuntime,
            syncStatus: SyncCapabilityStatus(
                backendKind: .localOnly,
                trustPosture: .localOnly,
                availability: .unavailable,
                detail: "Reminder evidence stays local-only."
            ),
            knowledgeProviderStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "provider.local",
                        type: .systemFallback,
                        displayName: "Local provider"
                    ),
                    availability: .localOnlyMode,
                    detail: "Reminder evidence stays on device.",
                    runtimeTrustPosture: .localOnly
                )
            ],
            memorySummary: RuntimeMemorySummary(
                memory: RuntimeMemorySnapshot(
                    goals: [],
                    drafts: [],
                    evidence: [],
                    feedback: [],
                    captures: [],
                    appState: .default
                )
            ),
            externalSurfaceSnapshot: nil
        )
        let traceContext = PrivateLifeRuntimeKernelTraceContext(runtimeContext: runtimeContext)
        let recommendationTrace = RecommendationTrace(
            id: "trace.reminders.p0",
            recommendationID: "recommendation.reminders.p0",
            source: RecommendationTraceSource(
                citedSourceIDs: [sourceRecordID],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth, .memoryEvent],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation.reminders.p0",
                summary: "Reminder source, receipt, and replay stay local and inspectable.",
                evidenceCategoryIDs: ["memory_event", "source_truth"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty.reminders.p0"],
                summaries: ["Reminder source knowledge is reviewed in You."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct.reminder"],
                controlActionIDs: ["open", "snooze", "complete"],
                correctableFieldKeys: ["receipt", "replayTrace", "sourceRecord"],
                hasRequiredControl: true
            ),
            receiptBehavior: RecommendationTraceReceiptBehavior.available(
                receiptIDs: [receiptID],
                actionReceiptIDs: [receiptID],
                proofReferenceIDs: [proofReferenceID]
            )
        )

        return PrivateLifeRuntimeKernel().makeReplayableDecisionTrace(
            PrivateLifeRuntimeKernelDecisionInput(
                traceContext: traceContext,
                decisionKey: "reminders.p0.contract",
                goalText: "Remind me tomorrow at 9",
                recommendationTrace: recommendationTrace
            )
        )
    }
}

private struct ReminderParseFixture {
    let sourceRecord: ReminderSourceRecord
    let sourceObject: LifeGraphObjectReference
    let receipt: ActionReceipt
    let replayTrace: ReplayableDecisionTrace
}
