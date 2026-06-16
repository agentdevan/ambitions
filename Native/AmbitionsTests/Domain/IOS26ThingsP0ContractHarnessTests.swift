import Foundation
import XCTest
@testable import Ambitions

final class IOS26ThingsP0ContractHarnessTests: XCTestCase {
    func testHarnessBlocksBroadReplacementClaimsWhileInstantCaptureStartHereTodayUpcomingScheduledOpenHeldLifeAreaGoalThreadClosureSourceReceiptReplayAndYouEvidenceIsMissing() {
        let harness = ThingsP0ContractHarnessFixture(
            instantCaptureEvidence: false,
            startHereEvidence: false,
            todayEvidence: false,
            upcomingEvidence: false,
            scheduledEvidence: false,
            openEvidence: false,
            heldEvidence: false,
            lifeAreaEvidence: false,
            goalThreadEvidence: false,
            lowFrictionClosureEvidence: false,
            sourceRecordEvidence: false,
            receiptEvidence: false,
            replayTraceEvidence: false,
            youInspectionBoundaryEvidence: false,
            unsupportedClaims: ThingsP0ContractHarnessFixture.forbiddenBroadClaims
        )

        XCTAssertEqual(
            harness.missingEvidence,
            [
                "instant capture",
                "Start here",
                "Today",
                "Upcoming",
                "Scheduled",
                "Open",
                "Held",
                "Life Areas",
                "Goal Threads",
                "low-friction closure",
                "source record",
                "receipt",
                "replay trace",
                "You inspection boundary",
            ]
        )
        XCTAssertTrue(harness.blocksBroadReplacementClaims)
        XCTAssertFalse(harness.allEvidencePresent)
        XCTAssertEqual(Set(harness.blockedClaims), Set(ThingsP0ContractHarnessFixture.forbiddenBroadClaims))
    }

    func testThingsReplacementEvidenceStaysLocalAndInspectableThroughSourceReceiptReplayAndYouSeams() throws {
        let lifeAreas = [
            LifeAreaDefinition(domainKey: .home, canonicalOrder: 0),
            LifeAreaDefinition(domainKey: .relationships, canonicalOrder: 1),
        ]
        let projectThread = GoalThread(
            id: "things.project.home-reset",
            ambitionID: "ambition.things.home-reset",
            name: "Reset the apartment",
            goalIDs: ["goal.things.home-reset"],
            isActive: true,
            createdAt: "2026-05-24T12:00:00Z",
            updatedAt: "2026-05-24T12:10:00Z"
        )
        let taskStep = Step(
            id: "things.step.1",
            sectionID: "section.things.home-reset",
            title: "Pack kitchen",
            summary: "Open the first actionable step and keep it local.",
            type: .actionUnit,
            state: .planned,
            owner: .localOwner,
            timing: GoalTiming(
                tempo: .deadlineBased,
                timingType: .dueAt,
                startsOn: nil,
                dueAt: "2026-06-01T12:00:00Z",
                targetBy: nil,
                windowStart: nil,
                windowEnd: nil,
                suggestedNextAt: nil,
                repeatEveryDays: nil,
                progressReviewCadenceDays: 7
            ),
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["The step is visible in Today without needing a dashboard."],
            actionability: StepActionability(
                action: "Open step",
                completionDefinition: "The step is visible locally and can be started now.",
                evidenceOfCompletion: ["The step is visible locally and can be started now."],
                fallbackMicroStep: "Open the next step.",
                contextRequirements: ["Today", "Upcoming", "Scheduled", "Open", "Held"]
            )
        )
        let taskCommitment = Commitment(
            id: "things.commitment.1",
            ambitionID: "ambition.things.home-reset",
            goalThreadID: projectThread.id,
            stepID: taskStep.id,
            promisedFor: "2026-06-01",
            expectedEffort: "20 minutes",
            minimumProofDescription: "The step stays local and replayable.",
            fitReason: "Matches the current open window.",
            recoveryPolicy: "Move, shorten, or hold without silent mutation.",
            status: .open,
            createdAt: "2026-05-24T12:00:00Z",
            updatedAt: "2026-05-24T12:10:00Z"
        )
        let savedViews = ["Start here", "Today", "Upcoming", "Scheduled", "Open", "Held"]
        let sourceRecord = KnowledgeSourceRecord(
            id: "source.things.1",
            providerID: "provider.local",
            entityTitle: "Things 3 replacement contract",
            publisher: nil,
            locator: "local://things/p0",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let stepObject = LifeGraphObjectReference(
            kind: .step,
            id: taskStep.id,
            label: taskStep.title,
            sourceDomain: .today
        )
        let projectObject = LifeGraphObjectReference(
            kind: .goal,
            id: projectThread.id,
            label: projectThread.name,
            sourceDomain: .goals
        )
        let receipt = ActionReceipt(
            id: "receipt.things.1",
            resultState: .completed,
            title: "Things replacement contract recorded",
            summary: "Start here, Today, Upcoming, Scheduled, Open, Held, and local replay stay inspectable.",
            sourceDomain: .today,
            occurredAt: "2026-05-24T12:15:00Z",
            affectedObjects: [stepObject, projectObject],
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
            actionIdentifier: AppNotificationConstants.openActionID,
            userInfo: [
                "sourceRecordID": sourceRecord.id,
                "surface": "Search Ambitions",
            ]
        )
        let youBoundary = ThingsYouInspectionBoundary(
            surfaceTitle: "Search Ambitions",
            sourceKnowledgeLabel: "Things source knowledge",
            allowsRawActivityLog: false
        )

        XCTAssertEqual(lifeAreas.map(\.displayName), ["Home", "Relationships"])
        XCTAssertEqual(projectThread.goalIDs, ["goal.things.home-reset"])
        XCTAssertEqual(taskCommitment.goalThreadID, projectThread.id)
        XCTAssertEqual(taskCommitment.stepID, taskStep.id)
        XCTAssertEqual(taskStep.timing.dueAt, "2026-06-01T12:00:00Z")
        XCTAssertEqual(taskStep.actionability.action, "Open step")
        XCTAssertEqual(savedViews, ["Start here", "Today", "Upcoming", "Scheduled", "Open", "Held"])
        XCTAssertEqual(receipt.sourceObject?.id, sourceRecord.id)
        XCTAssertEqual(proofLedgerEntry.sourceObjectID, sourceRecord.id)
        XCTAssertEqual(proofLedgerEntry.sourceRecordLabel, "Source record is source-tied")
        XCTAssertEqual(proofLedgerEntry.replayTraceLabel, "Replay trace stays local and inspectable")
        XCTAssertTrue(proofLedgerEntry.hasProofBridge)
        XCTAssertEqual(proofLedgerEntry.proofReference?.id, "proof.receipt.things.1")
        XCTAssertEqual(replayTrace.state, .ready)
        XCTAssertTrue(replayTrace.isReplayable)
        XCTAssertTrue(replayTrace.isLocalOnly)
        XCTAssertEqual(replayTrace.recommendation?.receipt.proofReferenceIDs, [proofLedgerEntry.proofReference!.id])
        XCTAssertEqual(replayTrace.decisionReceipt?.sourceRecordIDs, [receipt.id])
        XCTAssertEqual(replayTrace.decisionReceipt?.sourceRecordLabel, "Source record stays local")
        XCTAssertEqual(replayTrace.decisionReceipt?.replayTraceLabel, "Replay trace stays local and inspectable")
        XCTAssertTrue(replayTrace.decisionReceipt?.hasProofBridge ?? false)
        XCTAssertEqual(payload?.action, "open")
        XCTAssertEqual(payload?.values["sourceRecordID"], sourceRecord.id)
        XCTAssertEqual(payload?.values["surface"], "Search Ambitions")
        XCTAssertEqual(youBoundary.surfaceTitle, "Search Ambitions")
        XCTAssertEqual(youBoundary.inspectionLabel, "Search Ambitions")
        XCTAssertTrue(youBoundary.blocksRawActivityLogCopy)
        XCTAssertTrue(youBoundary.isInspectableBoundary)
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
                detail: "Things replacement evidence remains local-only."
            ),
            knowledgeProviderStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "provider.local",
                        type: .systemFallback,
                        displayName: "Local provider"
                    ),
                    availability: .localOnlyMode,
                    detail: "Things evidence stays on device.",
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
            id: "trace.things.1",
            recommendationID: "recommendation.things.1",
            source: RecommendationTraceSource(
                citedSourceIDs: [sourceRecordID],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth, .memoryEvent],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation.things.1",
                summary: "Things source, receipt, and replay stay local and inspectable.",
                evidenceCategoryIDs: ["memory_event", "source_truth"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty.things.1"],
                summaries: ["Things source knowledge is reviewed in You."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct.things"],
                controlActionIDs: ["open", "start", "hold"],
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
                decisionKey: "things.p0.contract",
                goalText: "Replace Things 3 planning locally.",
                recommendationTrace: recommendationTrace
            )
        )
    }
}

private struct ThingsP0ContractHarnessFixture: Sendable, Equatable {
    static let forbiddenBroadClaims = [
        "forbidden claim fixture: release-ready",
        "forbidden claim fixture: App Store-ready",
        "forbidden claim fixture: TestFlight-ready",
        "forbidden claim fixture: fully accessible",
        "forbidden claim fixture: performance validated",
        "forbidden claim fixture: privacy approved",
        "forbidden claim fixture: Things replacement is complete",
        "forbidden claim fixture: Things 3 is fully replaced",
    ]

    let instantCaptureEvidence: Bool
    let startHereEvidence: Bool
    let todayEvidence: Bool
    let upcomingEvidence: Bool
    let scheduledEvidence: Bool
    let openEvidence: Bool
    let heldEvidence: Bool
    let lifeAreaEvidence: Bool
    let goalThreadEvidence: Bool
    let lowFrictionClosureEvidence: Bool
    let sourceRecordEvidence: Bool
    let receiptEvidence: Bool
    let replayTraceEvidence: Bool
    let youInspectionBoundaryEvidence: Bool
    let unsupportedClaims: [String]

    var missingEvidence: [String] {
        var items: [String] = []
        if instantCaptureEvidence == false { items.append("instant capture") }
        if startHereEvidence == false { items.append("Start here") }
        if todayEvidence == false { items.append("Today") }
        if upcomingEvidence == false { items.append("Upcoming") }
        if scheduledEvidence == false { items.append("Scheduled") }
        if openEvidence == false { items.append("Open") }
        if heldEvidence == false { items.append("Held") }
        if lifeAreaEvidence == false { items.append("Life Areas") }
        if goalThreadEvidence == false { items.append("Goal Threads") }
        if lowFrictionClosureEvidence == false { items.append("low-friction closure") }
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

private struct ThingsYouInspectionBoundary: Sendable, Equatable {
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
