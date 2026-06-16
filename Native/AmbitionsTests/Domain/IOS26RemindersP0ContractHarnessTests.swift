import XCTest
@testable import Ambitions

final class IOS26RemindersP0ContractHarnessTests: XCTestCase {
    func testHarnessBlocksBroadReplacementClaimsWhileSourceReceiptReplayAndYouEvidenceIsMissing() {
        let harness = RemindersP0ContractHarnessFixture(
            reminderRecurrenceEvidence: false,
            notificationAbstractionEvidence: true,
            sourceRecordEvidence: false,
            receiptEvidence: false,
            replayTraceEvidence: false,
            youInspectionBoundaryEvidence: false,
            unsupportedClaims: RemindersP0ContractHarnessFixture.forbiddenBroadClaims
        )

        XCTAssertEqual(
            harness.missingEvidence,
            [
                "reminder recurrence",
                "source record",
                "receipt",
                "replay trace",
                "You inspection boundary",
            ]
        )
        XCTAssertTrue(harness.blocksBroadReplacementClaims)
        XCTAssertFalse(harness.allEvidencePresent)
        XCTAssertEqual(Set(harness.blockedClaims), Set(RemindersP0ContractHarnessFixture.forbiddenBroadClaims))
    }

    func testReminderReplacementEvidenceStaysLocalAndInspectableThroughNotificationReceiptAndReplaySeams() throws {
        let sourceRecord = KnowledgeSourceRecord(
            id: "source.reminders.1",
            providerID: "provider.local",
            entityTitle: "Tomorrow at 9 reminder",
            publisher: nil,
            locator: "local://reminders/p0",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let reminderObject = LifeGraphObjectReference(
            kind: .step,
            id: "reminder.step.1",
            label: "Tomorrow at 9",
            sourceDomain: .today
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let receipt = ActionReceipt(
            id: "receipt.reminders.1",
            resultState: .completed,
            title: "Reminder completed",
            summary: "Reminder closure stayed local.",
            sourceDomain: .today,
            occurredAt: "2026-05-24T09:00:00Z",
            affectedObjects: [reminderObject],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(
            receipt: receipt,
            proofRelevance: .countsAsProof
        )
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id)
        )
        let parser = NotificationResponsePayloadParser()
        let payload = parser.payload(
            actionIdentifier: AppNotificationConstants.snoozeActionID,
            userInfo: [
                "sourceRecordID": sourceRecord.id,
                "surface": "Search Ambitions",
            ]
        )

        XCTAssertEqual(sourceRecord.provenanceKind, .userProvided)
        XCTAssertEqual(sourceRecord.locator, "local://reminders/p0")
        XCTAssertTrue(sourceRecord.entityTitle.contains("reminder"))
        XCTAssertEqual(receipt.sourceObject?.id, sourceRecord.id)
        XCTAssertEqual(proofLedgerEntry.sourceObjectID, sourceRecord.id)
        XCTAssertEqual(proofLedgerEntry.sourceRecordLabel, "Source record is source-tied")
        XCTAssertEqual(proofLedgerEntry.replayTraceLabel, "Replay trace stays local and inspectable")
        XCTAssertTrue(proofLedgerEntry.hasProofBridge)
        XCTAssertEqual(proofLedgerEntry.proofReference?.id, "proof.receipt.reminders.1")
        XCTAssertEqual(replayTrace.state, .ready)
        XCTAssertTrue(replayTrace.isReplayable)
        XCTAssertTrue(replayTrace.isLocalOnly)
        XCTAssertEqual(replayTrace.recommendation?.receipt.proofReferenceIDs, [proofLedgerEntry.proofReference!.id])
        XCTAssertEqual(replayTrace.decisionReceipt?.sourceRecordIDs, [receipt.id])
        XCTAssertEqual(replayTrace.decisionReceipt?.sourceRecordLabel, "Source record stays local")
        XCTAssertEqual(replayTrace.decisionReceipt?.replayTraceLabel, "Replay trace stays local and inspectable")
        XCTAssertTrue(replayTrace.decisionReceipt?.hasProofBridge ?? false)
        XCTAssertEqual(payload?.action, "snooze")
        XCTAssertEqual(payload?.values["sourceRecordID"], sourceRecord.id)
        XCTAssertEqual(payload?.values["surface"], "Search Ambitions")

        let categories = LocalNotificationFoundation.defaultCategories()
        XCTAssertEqual(categories.first?.identifier, AppNotificationConstants.nextStepCategoryID)
        XCTAssertEqual(categories.first?.actions.map(\.title), ["Open Today", "Not now", "Close the loop"])
    }

    func testReminderInspectionBoundaryUsesTheYouWhatAmbitionsKnowsSurfaceCopy() {
        let surfaceTitle = "Search Ambitions"
        let youBoundary = ReminderYouInspectionBoundary(
            surfaceTitle: surfaceTitle,
            sourceKnowledgeLabel: "Reminder source knowledge",
            allowsRawActivityLog: false
        )

        XCTAssertEqual(youBoundary.surfaceTitle, "Search Ambitions")
        XCTAssertEqual(youBoundary.inspectionLabel, "Search Ambitions")
        XCTAssertTrue(youBoundary.blocksRawActivityLogCopy)
        XCTAssertTrue(youBoundary.isInspectableBoundary)
        XCTAssertFalse(youBoundary.allowsRawActivityLog)
    }

    private func makeReplayTrace(
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
                detail: "Ambitions remains local-only for reminder evidence."
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
            id: "trace.reminders.1",
            recommendationID: "recommendation.reminders.1",
            source: RecommendationTraceSource(
                citedSourceIDs: [sourceRecordID],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth, .memoryEvent],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation.reminders.1",
                summary: "Reminder source, receipt, and replay stay local and inspectable.",
                evidenceCategoryIDs: ["memory_event", "source_truth"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty.reminders.1"],
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

private struct RemindersP0ContractHarnessFixture: Sendable, Equatable {
    static let forbiddenBroadClaims = [
        "forbidden claim fixture: release-ready",
        "forbidden claim fixture: App Store-ready",
        "forbidden claim fixture: TestFlight-ready",
        "forbidden claim fixture: fully accessible",
        "forbidden claim fixture: performance validated",
        "forbidden claim fixture: privacy approved",
        "forbidden claim fixture: Reminder replacement is complete",
    ]

    let reminderRecurrenceEvidence: Bool
    let notificationAbstractionEvidence: Bool
    let sourceRecordEvidence: Bool
    let receiptEvidence: Bool
    let replayTraceEvidence: Bool
    let youInspectionBoundaryEvidence: Bool
    let unsupportedClaims: [String]

    var missingEvidence: [String] {
        var items: [String] = []
        if reminderRecurrenceEvidence == false { items.append("reminder recurrence") }
        if notificationAbstractionEvidence == false { items.append("local notification abstraction") }
        if sourceRecordEvidence == false { items.append("source record") }
        if receiptEvidence == false { items.append("receipt") }
        if replayTraceEvidence == false { items.append("replay trace") }
        if youInspectionBoundaryEvidence == false { items.append("You inspection boundary") }
        return items
    }

    var allEvidencePresent: Bool {
        missingEvidence.isEmpty
    }

    var blocksBroadReplacementClaims: Bool {
        allEvidencePresent == false || unsupportedClaims.isEmpty == false
    }

    var blockedClaims: [String] {
        Array(Set(unsupportedClaims)).sorted()
    }
}

private struct ReminderYouInspectionBoundary: Sendable, Equatable {
    let surfaceTitle: String
    let sourceKnowledgeLabel: String
    let allowsRawActivityLog: Bool

    var inspectionLabel: String {
        surfaceTitle
    }

    var blocksRawActivityLogCopy: Bool {
        allowsRawActivityLog == false
    }

    var isInspectableBoundary: Bool {
        surfaceTitle == "Search Ambitions" && allowsRawActivityLog == false
    }
}
