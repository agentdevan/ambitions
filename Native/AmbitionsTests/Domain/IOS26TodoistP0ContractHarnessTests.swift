import XCTest
@testable import Ambitions

final class IOS26TodoistP0ContractHarnessTests: XCTestCase {
    func testHarnessBlocksBroadReplacementClaimsWhileTodoistEvidenceIsMissing() {
        let harness = TodoistP0ContractHarnessFixture(
            projectEquivalenceEvidence: false,
            taskEquivalenceEvidence: false,
            dueDeadlineEvidence: false,
            dependencyEvidence: false,
            labelsTagsEvidence: false,
            filtersEvidence: false,
            savedViewsEvidence: false,
            recurrenceEvidence: false,
            deterministicSortEvidence: false,
            sourceRecordEvidence: false,
            receiptEvidence: false,
            replayTraceEvidence: false,
            youInspectionBoundaryEvidence: false,
            unsupportedClaims: TodoistP0ContractHarnessFixture.forbiddenBroadClaims
        )

        XCTAssertEqual(
            harness.missingEvidence,
            [
                "project equivalence",
                "task equivalence",
                "due/deadline",
                "dependencies",
                "labels/tags",
                "filters",
                "saved views",
                "recurrence",
                "deterministic sort",
                "source record",
                "receipt",
                "replay trace",
                "You inspection boundary",
            ]
        )
        XCTAssertTrue(harness.blocksBroadReplacementClaims)
        XCTAssertFalse(harness.allEvidencePresent)
        XCTAssertEqual(Set(harness.blockedClaims), Set(TodoistP0ContractHarnessFixture.forbiddenBroadClaims))
    }

    func testTodoistReplacementEvidenceStaysLocalAndInspectableThroughSourceReceiptReplayAndYouSeams() throws {
        let projectThread = GoalThread(
            id: "todoist.project.launch",
            ambitionID: "ambition.todoist.launch",
            name: "Launch backlog",
            goalIDs: ["goal.todoist.launch"],
            isActive: true,
            createdAt: "2026-05-24T12:00:00Z",
            updatedAt: "2026-05-24T12:10:00Z"
        )
        let taskStep = Step(
            id: "todoist.step.1",
            sectionID: "section.todoist.launch",
            title: "Draft launch checklist",
            summary: "Capture the first visible project task locally.",
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
            dependencyStepIDs: ["todoist.step.0"],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["The task is complete and replayable."],
            actionability: StepActionability(
                action: "Draft launch checklist",
                completionDefinition: "The checklist exists locally.",
                evidenceOfCompletion: ["The checklist exists locally."],
                fallbackMicroStep: "Write one bullet point.",
                contextRequirements: ["labels", "filters", "saved views", "replay"]
            )
        )
        let recurringStep = Step(
            id: "todoist.step.2",
            sectionID: "section.todoist.launch",
            title: "Review open work weekly",
            summary: "Keep recurrence local and deterministic.",
            type: .recurringRoutine,
            state: .planned,
            owner: .localOwner,
            timing: GoalTiming(
                tempo: .ongoing,
                timingType: .repeatWithinWindow,
                startsOn: "2026-06-01T12:00:00Z",
                dueAt: nil,
                targetBy: nil,
                windowStart: nil,
                windowEnd: nil,
                suggestedNextAt: nil,
                repeatEveryDays: 7,
                progressReviewCadenceDays: 7
            ),
            dependencyStepIDs: ["todoist.step.1"],
            isOptional: false,
            isRepeatable: true,
            evidenceRequired: true,
            successSignals: ["The recurring task is visible in the local view order."],
            actionability: StepActionability(
                action: "Review open work weekly",
                completionDefinition: "The recurring review is recorded locally.",
                evidenceOfCompletion: ["The recurring review is recorded locally."],
                fallbackMicroStep: "Open the open-work view.",
                contextRequirements: ["recurrence", "deterministic sort"]
            )
        )
        let taskCommitment = Commitment(
            id: "todoist.commitment.1",
            ambitionID: "ambition.todoist.launch",
            goalThreadID: projectThread.id,
            stepID: taskStep.id,
            promisedFor: "2026-06-01",
            expectedEffort: "25 minutes",
            minimumProofDescription: "The checklist exists locally and can be replayed.",
            fitReason: "Matches the current capacity window.",
            recoveryPolicy: "Hold or shorten without silent mutation.",
            status: .open,
            createdAt: "2026-05-24T12:00:00Z",
            updatedAt: "2026-05-24T12:10:00Z"
        )
        let followUpCommitment = Commitment(
            id: "todoist.commitment.2",
            ambitionID: "ambition.todoist.launch",
            goalThreadID: projectThread.id,
            stepID: recurringStep.id,
            promisedFor: "2026-06-08",
            expectedEffort: "10 minutes",
            minimumProofDescription: "The weekly review remains visible and local.",
            fitReason: "Recurrence keeps the project active.",
            recoveryPolicy: "Keep the dependency chain intact.",
            status: .waiting,
            createdAt: "2026-05-24T12:05:00Z",
            updatedAt: "2026-05-24T12:10:00Z"
        )
        let labels = ["work", "launch", "waiting"]
        let filters = [
            "labels/tags",
            "Today",
            "Upcoming",
            "Scheduled",
            "Open",
            "Waiting",
            "Blocked",
            "Held",
            "Someday/Future",
            "Proof Needed",
            "Needs Review",
            "Source Needed"
        ]
        let savedViews = filters
        let sortedCommitments = [followUpCommitment, taskCommitment].sorted {
            if $0.promisedFor != $1.promisedFor {
                return ($0.promisedFor ?? "") < ($1.promisedFor ?? "")
            }
            return $0.id < $1.id
        }
        let sourceRecord = KnowledgeSourceRecord(
            id: "source.todoist.1",
            providerID: "provider.local",
            entityTitle: "Todoist replacement contract",
            publisher: nil,
            locator: "local://todoist/p0",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let taskObject = LifeGraphObjectReference(
            kind: .commitment,
            id: taskCommitment.id,
            label: taskCommitment.stepID ?? "Todoist task",
            sourceDomain: .commitment
        )
        let receipt = ActionReceipt(
            id: "receipt.todoist.1",
            resultState: .completed,
            title: "Todoist replacement contract recorded",
            summary: "Todoist source, receipt, and replay stay local.",
            sourceDomain: .commitment,
            occurredAt: "2026-05-24T12:15:00Z",
            affectedObjects: [taskObject],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let dependencyReceipt = ActionReceipt.dependencyBlockedReceipt(
            id: "receipt.todoist.dependency",
            candidateID: taskCommitment.id,
            sourceStepID: taskStep.id,
            sourceCandidateID: taskCommitment.id,
            dependencyStepIDs: taskStep.dependencyStepIDs,
            blockedBy: "Draft launch checklist waits on the dependency chain",
            timelineImpactSummary: "The project step remains blocked until the prerequisite step is visible.",
            recordedAt: "2026-05-24T12:16:00Z"
        )
        let priorityReceipt = ActionReceipt.priorityPressureChangedReceipt(
            id: "receipt.todoist.priority",
            candidateID: recurringStep.id,
            sourceStepID: recurringStep.id,
            sourceCandidateID: recurringStep.id,
            previousPressure: "moderate",
            newPressure: "high",
            timelineImpactSummary: "The weekly review carries more pressure while staying qualitative.",
            recordedAt: "2026-05-24T12:17:00Z"
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
                "surface": "What Ambitions knows",
            ]
        )
        let youBoundary = TodoistYouInspectionBoundary(
            surfaceTitle: "What Ambitions knows",
            sourceKnowledgeLabel: "Todoist source knowledge",
            allowsRawActivityLog: false
        )

        XCTAssertEqual(projectThread.goalIDs, ["goal.todoist.launch"])
        XCTAssertEqual(taskCommitment.goalThreadID, projectThread.id)
        XCTAssertEqual(taskCommitment.stepID, taskStep.id)
        XCTAssertEqual(taskStep.dependencyStepIDs, ["todoist.step.0"])
        XCTAssertEqual(taskStep.timing.dueAt, "2026-06-01T12:00:00Z")
        XCTAssertEqual(recurringStep.timing.repeatEveryDays, 7)
        XCTAssertEqual(labels, ["work", "launch", "waiting"])
        XCTAssertEqual(filters, [
            "labels/tags",
            "Today",
            "Upcoming",
            "Scheduled",
            "Open",
            "Waiting",
            "Blocked",
            "Held",
            "Someday/Future",
            "Proof Needed",
            "Needs Review",
            "Source Needed"
        ])
        XCTAssertEqual(savedViews, [
            "labels/tags",
            "Today",
            "Upcoming",
            "Scheduled",
            "Open",
            "Waiting",
            "Blocked",
            "Held",
            "Someday/Future",
            "Proof Needed",
            "Needs Review",
            "Source Needed"
        ])
        XCTAssertEqual(sortedCommitments.map(\.id), ["todoist.commitment.1", "todoist.commitment.2"])
        XCTAssertEqual(receipt.sourceObject?.id, sourceRecord.id)
        XCTAssertEqual(dependencyReceipt.changedFacts.first?.kind, .dependencyBlocked)
        XCTAssertEqual(dependencyReceipt.nextAction?.kind, .reviewGoal)
        XCTAssertEqual(priorityReceipt.changedFacts.first?.kind, .priorityPressureChanged)
        XCTAssertEqual(priorityReceipt.sourceObject?.label, "Priority pressure")
        XCTAssertEqual(proofLedgerEntry.sourceObjectID, sourceRecord.id)
        XCTAssertEqual(proofLedgerEntry.sourceRecordLabel, "Source record is source-tied")
        XCTAssertEqual(proofLedgerEntry.replayTraceLabel, "Replay trace stays local and inspectable")
        XCTAssertTrue(proofLedgerEntry.hasProofBridge)
        XCTAssertEqual(proofLedgerEntry.proofReference?.id, "proof.receipt.todoist.1")
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
        XCTAssertEqual(payload?.values["surface"], "What Ambitions knows")
        XCTAssertEqual(youBoundary.surfaceTitle, "What Ambitions knows")
        XCTAssertEqual(youBoundary.inspectionLabel, "What Ambitions knows")
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
                detail: "Todoist replacement evidence remains local-only."
            ),
            knowledgeProviderStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "provider.local",
                        type: .systemFallback,
                        displayName: "Local provider"
                    ),
                    availability: .localOnlyMode,
                    detail: "Todoist evidence stays on device.",
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
            id: "trace.todoist.1",
            recommendationID: "recommendation.todoist.1",
            source: RecommendationTraceSource(
                citedSourceIDs: [sourceRecordID],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth, .memoryEvent],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation.todoist.1",
                summary: "Todoist source, receipt, and replay stay local and inspectable.",
                evidenceCategoryIDs: ["memory_event", "source_truth"]
            ),
            fit: RecommendationTraceFit(
                state: .fits,
                blockReasons: [],
                canDriveRecommendation: true
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty.todoist.1"],
                summaries: ["Todoist source knowledge is reviewed in You."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct.todoist"],
                controlActionIDs: ["open", "review", "complete"],
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
                decisionKey: "todoist.p0.contract",
                goalText: "Replace Todoist project and task management locally.",
                recommendationTrace: recommendationTrace
            )
        )
    }
}

private struct TodoistP0ContractHarnessFixture: Sendable, Equatable {
    static let forbiddenBroadClaims = [
        "forbidden claim fixture: release-ready",
        "forbidden claim fixture: App Store-ready",
        "forbidden claim fixture: TestFlight-ready",
        "forbidden claim fixture: fully accessible",
        "forbidden claim fixture: performance validated",
        "forbidden claim fixture: privacy approved",
        "forbidden claim fixture: Todoist replacement is complete",
        "forbidden claim fixture: Todoist is fully replaced",
    ]

    let projectEquivalenceEvidence: Bool
    let taskEquivalenceEvidence: Bool
    let dueDeadlineEvidence: Bool
    let dependencyEvidence: Bool
    let labelsTagsEvidence: Bool
    let filtersEvidence: Bool
    let savedViewsEvidence: Bool
    let recurrenceEvidence: Bool
    let deterministicSortEvidence: Bool
    let sourceRecordEvidence: Bool
    let receiptEvidence: Bool
    let replayTraceEvidence: Bool
    let youInspectionBoundaryEvidence: Bool
    let unsupportedClaims: [String]

    var missingEvidence: [String] {
        var items: [String] = []
        if projectEquivalenceEvidence == false { items.append("project equivalence") }
        if taskEquivalenceEvidence == false { items.append("task equivalence") }
        if dueDeadlineEvidence == false { items.append("due/deadline") }
        if dependencyEvidence == false { items.append("dependencies") }
        if labelsTagsEvidence == false { items.append("labels/tags") }
        if filtersEvidence == false { items.append("filters") }
        if savedViewsEvidence == false { items.append("saved views") }
        if recurrenceEvidence == false { items.append("recurrence") }
        if deterministicSortEvidence == false { items.append("deterministic sort") }
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

private struct TodoistYouInspectionBoundary: Sendable, Equatable {
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
        surfaceTitle == "What Ambitions knows" && allowsRawActivityLog == false
    }
}
