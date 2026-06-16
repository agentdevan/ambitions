import Foundation
import XCTest
@testable import Ambitions

final class IOS26CrossAppJourneyContractHarnessTests: XCTestCase {
    func testHarnessBlocksBroadCrossAppReplacementClaimsWhileEvidenceIsMissing() {
        let harness = CrossAppJourneyContractHarnessFixture(
            halfMarathonEvidence: false,
            moveApartmentEvidence: false,
            careerGrowthEvidence: false,
            creativeReleaseEvidence: false,
            relationshipBalanceEvidence: false,
            sensitiveContextEvidence: false,
            sourceRecordEvidence: false,
            receiptEvidence: false,
            replayTraceEvidence: false,
            youInspectionBoundaryEvidence: false,
            unsupportedClaims: CrossAppJourneyContractHarnessFixture.forbiddenBroadClaims
        )

        XCTAssertEqual(
            harness.missingEvidence,
            [
                "half-marathon journey",
                "move/apartment journey",
                "career growth journey",
                "creative release journey",
                "relationship/life balance journey",
                "sensitive context journey",
                "SourceRecord",
                "local Receipt",
                "ReplayTrace",
                "You inspection boundary",
            ]
        )
        XCTAssertTrue(harness.blocksBroadReplacementClaims)
        XCTAssertFalse(harness.allEvidencePresent)
        XCTAssertEqual(Set(harness.blockedClaims), Set(CrossAppJourneyContractHarnessFixture.forbiddenBroadClaims))
    }

    func testDownstreamT04FToT04KReplacementClaimsRemainBlockedWithoutProofBoundaries() {
        let downstreamGates = CrossAppDownstreamReplacementClaimHarnessFixture(
            gates: [
                CrossAppDownstreamClaimBoundary(
                    trainID: "IOS26-T04F",
                    sourceKnowledgeEvidence: false,
                    sensitiveLearnedBehaviorEvidence: false,
                    localIntelligenceEvidence: false,
                    sourceRecordEvidence: false,
                    receiptEvidence: false,
                    replayTraceEvidence: false,
                    youInspectionBoundaryEvidence: false
                ),
                CrossAppDownstreamClaimBoundary(
                    trainID: "IOS26-T04G",
                    sourceKnowledgeEvidence: false,
                    sensitiveLearnedBehaviorEvidence: false,
                    localIntelligenceEvidence: false,
                    sourceRecordEvidence: false,
                    receiptEvidence: false,
                    replayTraceEvidence: false,
                    youInspectionBoundaryEvidence: false
                ),
                CrossAppDownstreamClaimBoundary(
                    trainID: "IOS26-T04H",
                    sourceKnowledgeEvidence: false,
                    sensitiveLearnedBehaviorEvidence: false,
                    localIntelligenceEvidence: false,
                    sourceRecordEvidence: false,
                    receiptEvidence: false,
                    replayTraceEvidence: false,
                    youInspectionBoundaryEvidence: false
                ),
                CrossAppDownstreamClaimBoundary(
                    trainID: "IOS26-T04I",
                    sourceKnowledgeEvidence: false,
                    sensitiveLearnedBehaviorEvidence: false,
                    localIntelligenceEvidence: false,
                    sourceRecordEvidence: false,
                    receiptEvidence: false,
                    replayTraceEvidence: false,
                    youInspectionBoundaryEvidence: false
                ),
                CrossAppDownstreamClaimBoundary(
                    trainID: "IOS26-T04K",
                    sourceKnowledgeEvidence: false,
                    sensitiveLearnedBehaviorEvidence: false,
                    localIntelligenceEvidence: false,
                    sourceRecordEvidence: false,
                    receiptEvidence: false,
                    replayTraceEvidence: false,
                    youInspectionBoundaryEvidence: false
                ),
            ],
            unsupportedClaims: CrossAppDownstreamReplacementClaimHarnessFixture.forbiddenBroadClaims
        )

        XCTAssertEqual(
            Set(downstreamGates.blockedClaims),
            Set(CrossAppDownstreamReplacementClaimHarnessFixture.forbiddenBroadClaims)
        )
        XCTAssertTrue(downstreamGates.blocksBroadReplacementClaims)
        XCTAssertFalse(downstreamGates.allEvidencePresent)
        XCTAssertEqual(
            downstreamGates.missingEvidence,
            [
                "IOS26-T04F requires SourceRecord, local Receipt, ReplayTrace, You inspection boundary, source knowledge proof, sensitive learned behavior proof, and local intelligence proof",
                "IOS26-T04G requires SourceRecord, local Receipt, ReplayTrace, You inspection boundary, source knowledge proof, sensitive learned behavior proof, and local intelligence proof",
                "IOS26-T04H requires SourceRecord, local Receipt, ReplayTrace, You inspection boundary, source knowledge proof, sensitive learned behavior proof, and local intelligence proof",
                "IOS26-T04I requires SourceRecord, local Receipt, ReplayTrace, You inspection boundary, source knowledge proof, sensitive learned behavior proof, and local intelligence proof",
                "IOS26-T04K requires SourceRecord, local Receipt, ReplayTrace, You inspection boundary, source knowledge proof, sensitive learned behavior proof, and local intelligence proof",
            ]
        )
    }

    func testHalfMarathonJourneyFixtureIncludesRequiredEvidence() throws {
        let goal = GoalThread(
            id: "journey.half.marathon",
            ambitionID: "ambition.half.marathon",
            name: "Run half marathon",
            goalIDs: ["goal.half.marathon"],
            isActive: true,
            createdAt: "2026-05-24T12:00:00Z",
            updatedAt: "2026-05-24T12:10:00Z"
        )
        let step = Step(
            id: "journey.step.half.marathon.train",
            sectionID: "section.half.marathon",
            title: "Run Thursday interval session",
            summary: "Capture recurring training plan locally.",
            type: .actionUnit,
            state: .planned,
            owner: .localOwner,
            timing: GoalTiming(
                tempo: .recurring,
                timingType: .repeatWithinWindow,
                startsOn: "2026-06-01T12:00:00Z",
                dueAt: nil,
                targetBy: nil,
                windowStart: nil,
                windowEnd: nil,
                suggestedNextAt: nil,
                repeatEveryDays: 3,
                progressReviewCadenceDays: 7
            ),
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: true,
            evidenceRequired: true,
            successSignals: ["The recurring half-marathon step is visible and replayable."],
            actionability: StepActionability(
                action: "Start now",
                completionDefinition: "A local recurring training block exists.",
                evidenceOfCompletion: ["A recurring half-marathon block exists locally."],
                fallbackMicroStep: "Open the step and keep it lightweight.",
                contextRequirements: ["Time", "Start here", "ReplayTrace"]
            )
        )
        let commitment = Commitment(
            id: "journey.commitment.half.marathon",
            ambitionID: "ambition.half.marathon",
            goalThreadID: goal.id,
            stepID: step.id,
            promisedFor: "Every Tue/Thu",
            expectedEffort: "45 minutes",
            minimumProofDescription: "Training recommendation is source-backed and replayable.",
            fitReason: "Current capacity supports the recurring pace.",
            recoveryPolicy: "Move, hold, or shorten without silent use.",
            status: .open,
            createdAt: "2026-05-24T12:00:00Z",
            updatedAt: "2026-05-24T12:10:00Z"
        )
        let sourceRecord = KnowledgeSourceRecord(
            id: "source.journey.half.marathon",
            providerID: "provider.local",
            entityTitle: "Half-marathon training journey",
            publisher: nil,
            locator: "local://journey/half-marathon",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let journeyObject = LifeGraphObjectReference(
            kind: .commitment,
            id: commitment.id,
            label: step.title,
            sourceDomain: .goals
        )
        let receipt = ActionReceipt(
            id: "receipt.journey.half.marathon",
            resultState: .completed,
            title: "Half-marathon fixture recorded",
            summary: "SourceRecord, receipt, and replay remain local.",
            sourceDomain: .goals,
            occurredAt: "2026-05-24T12:15:00Z",
            affectedObjects: [journeyObject],
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
            proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id),
            decisionKey: "journey.half.marathon",
            goalText: "Run twice a week without missing knee-sensitive guidance."
        )
        let parser = NotificationResponsePayloadParser()
        let payload = parser.payload(
            actionIdentifier: AppNotificationConstants.openActionID,
            userInfo: [
                "sourceRecordID": sourceRecord.id,
                "surface": "Search Ambitions",
            ]
        )
        let youBoundary = CrossAppJourneyYouInspectionBoundary(
            surfaceTitle: "Search Ambitions",
            sourceKnowledgeLabel: "Half-marathon source knowledge",
            allowsRawActivityLog: false
        )

        XCTAssertEqual(goal.goalIDs, ["goal.half.marathon"])
        XCTAssertEqual(commitment.goalThreadID, goal.id)
        XCTAssertEqual(commitment.stepID, step.id)
        XCTAssertEqual(step.timing.repeatEveryDays, 3)
        XCTAssertEqual(receipt.sourceObject?.id, sourceRecord.id)
        XCTAssertEqual(proofLedgerEntry.sourceObjectID, sourceRecord.id)
        XCTAssertEqual(proofLedgerEntry.proofReference?.id, "proof.receipt.journey.half.marathon")
        XCTAssertEqual(replayTrace.state, .ready)
        XCTAssertTrue(replayTrace.isReplayable)
        XCTAssertTrue(replayTrace.isLocalOnly)
        XCTAssertEqual(payload?.values["surface"], "Search Ambitions")
        XCTAssertEqual(payload?.values["sourceRecordID"], sourceRecord.id)
        XCTAssertTrue(youBoundary.blocksRawActivityLogCopy)
        XCTAssertEqual(youBoundary.inspectionLabel, "Search Ambitions")
    }

    func testMoveApartmentJourneyFixtureIncludesRequiredEvidence() throws {
        let goal = GoalThread(
            id: "journey.move.apartment",
            ambitionID: "ambition.move.apartment",
            name: "Apartment move",
            goalIDs: ["goal.move.apartment"],
            isActive: true,
            createdAt: "2026-05-24T12:00:00Z",
            updatedAt: "2026-05-24T12:10:00Z"
        )
        let step = Step(
            id: "journey.step.move.apartment",
            sectionID: "section.move.apartment",
            title: "Book utility setup",
            summary: "Protect pre-move weekend and capture setup tasks.",
            type: .actionUnit,
            state: .planned,
            owner: .localOwner,
            timing: GoalTiming(
                tempo: .deadlineBased,
                timingType: .dueAt,
                startsOn: nil,
                dueAt: "2026-07-01",
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
            successSignals: ["Move prep commitments are linked to goals."],
            actionability: StepActionability(
                action: "Open step",
                completionDefinition: "Move tasks are persisted locally.",
                evidenceOfCompletion: ["Move tasks are local and replayable."],
                fallbackMicroStep: "Open goal and hold one step.",
                contextRequirements: ["Time", "Recommended step", "ReplayTrace"]
            )
        )
        let commitment = Commitment(
            id: "journey.commitment.move.apartment",
            ambitionID: "ambition.move.apartment",
            goalThreadID: goal.id,
            stepID: step.id,
            promisedFor: "2026-07-01",
            expectedEffort: "1 hour",
            minimumProofDescription: "Move prep remains deterministic and inspectable.",
            fitReason: "Schedule allows protected weekend windows.",
            recoveryPolicy: "Keep critical tasks and adjust non-critical work.",
            status: .open,
            createdAt: "2026-05-24T12:00:00Z",
            updatedAt: "2026-05-24T12:10:00Z"
        )
        let sourceRecord = KnowledgeSourceRecord(
            id: "source.journey.move.apartment",
            providerID: "provider.local",
            entityTitle: "Move/apartment journey",
            publisher: nil,
            locator: "local://journey/move-apartment",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let journeyObject = LifeGraphObjectReference(
            kind: .goal,
            id: goal.id,
            label: goal.name,
            sourceDomain: .goals
        )
        let receipt = ActionReceipt(
            id: "receipt.journey.move.apartment",
            resultState: .completed,
            title: "Move/apartment fixture recorded",
            summary: "Move journey evidence remains local and replayable.",
            sourceDomain: .goals,
            occurredAt: "2026-05-24T12:15:00Z",
            affectedObjects: [journeyObject],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(receipt: receipt, proofRelevance: .countsAsProof)
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id),
            decisionKey: "journey.move.apartment",
            goalText: "Prepare move tasks and protect weekend."
        )
        let youBoundary = CrossAppJourneyYouInspectionBoundary(
            surfaceTitle: "Search Ambitions",
            sourceKnowledgeLabel: "Move/apartment source knowledge",
            allowsRawActivityLog: false
        )

        XCTAssertEqual(step.timing.dueAt, "2026-07-01")
        XCTAssertEqual(step.timing.tempo, .deadlineBased)
        XCTAssertEqual(commitment.recoveryPolicy, "Keep critical tasks and adjust non-critical work.")
        XCTAssertEqual(proofLedgerEntry.sourceRecordLabel, "Source record is source-tied")
        XCTAssertEqual(replayTrace.decisionReceipt?.sourceRecordIDs, [receipt.id])
        XCTAssertEqual(youBoundary.inspectionLabel, "Search Ambitions")
    }

    func testCareerGrowthJourneyFixtureIncludesRequiredEvidence() throws {
        let step = Step(
            id: "journey.step.career.growth",
            sectionID: "section.career.growth",
            title: "Study PM fundamentals Sunday",
            summary: "Local recurring learning schedule for career growth.",
            type: .actionUnit,
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
                repeatEveryDays: 14,
                progressReviewCadenceDays: 14
            ),
            dependencyStepIDs: [],
            isOptional: false,
            isRepeatable: true,
            evidenceRequired: true,
            successSignals: ["Career growth routine has repeatable local recurrence."],
            actionability: StepActionability(
                action: "Start now",
                completionDefinition: "Study step is scheduled and replayable.",
                evidenceOfCompletion: ["Study session appears in local schedule."],
                fallbackMicroStep: "Open Today and open the career goal thread.",
                contextRequirements: ["Recommended step", "Today", "ReplayTrace"]
            )
        )
        let sourceRecord = KnowledgeSourceRecord(
            id: "source.journey.career.growth",
            providerID: "provider.local",
            entityTitle: "Career growth journey",
            publisher: nil,
            locator: "local://journey/career-growth",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let goalObject = LifeGraphObjectReference(
            kind: .goal,
            id: "goal.career.growth",
            label: "Become PM-ready by Q4",
            sourceDomain: .goals
        )
        let receipt = ActionReceipt(
            id: "receipt.journey.career.growth",
            resultState: .completed,
            title: "Career growth fixture recorded",
            summary: "Career notes and reminders remain local and inspectable.",
            sourceDomain: .goals,
            occurredAt: "2026-05-24T12:15:00Z",
            affectedObjects: [goalObject],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(receipt: receipt, proofRelevance: .countsAsProof)
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id),
            decisionKey: "journey.career.growth",
            goalText: "Study for PM growth and track proof."
        )

        XCTAssertEqual(step.timing.repeatEveryDays, 14)
        XCTAssertEqual(step.timing.tempo, .ongoing)
        XCTAssertEqual(sourceRecord.entityTitle, "Career growth journey")
        XCTAssertEqual(receipt.title, "Career growth fixture recorded")
        XCTAssertTrue(replayTrace.state == .ready)
        XCTAssertEqual(replayTrace.decisionReceipt?.sourceRecordLabel, "Source record stays local")
        XCTAssertEqual(proofLedgerEntry.replayTraceLabel, "Replay trace stays local and inspectable")
        XCTAssertTrue(replayTrace.isReplayable)
    }

    func testCreativeReleaseJourneyFixtureIncludesRequiredEvidence() throws {
        let step = Step(
            id: "journey.step.creative.release",
            sectionID: "section.creative.release",
            title: "Draft release notes",
            summary: "Keep creative release dependencies local and replayable.",
            type: .actionUnit,
            state: .planned,
            owner: .localOwner,
            timing: GoalTiming(
                tempo: .deadlineBased,
                timingType: .dueAt,
                startsOn: nil,
                dueAt: "2026-08-31",
                targetBy: nil,
                windowStart: nil,
                windowEnd: nil,
                suggestedNextAt: nil,
                repeatEveryDays: nil,
                progressReviewCadenceDays: 7
            ),
            dependencyStepIDs: ["creative.step1", "creative.step2"],
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: true,
            successSignals: ["Creative release artifacts are linked to project steps."],
            actionability: StepActionability(
                action: "Open step",
                completionDefinition: "Draft artifact is persisted locally.",
                evidenceOfCompletion: ["Draft artifacts are stored in local context."],
                fallbackMicroStep: "Open project and check dependency list.",
                contextRequirements: ["GoalThread", "ReplayTrace", "Start here"]
            )
        )
        let sourceRecord = KnowledgeSourceRecord(
            id: "source.journey.creative.release",
            providerID: "provider.local",
            entityTitle: "Creative release journey",
            publisher: nil,
            locator: "local://journey/creative-release",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let receipt = ActionReceipt(
            id: "receipt.journey.creative.release",
            resultState: .completed,
            title: "Creative release fixture recorded",
            summary: "Creative release fixture is local, source-backed, and replayable.",
            sourceDomain: .goals,
            occurredAt: "2026-05-24T12:15:00Z",
            affectedObjects: [sourceObject],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(receipt: receipt, proofRelevance: .countsAsProof)
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id),
            decisionKey: "journey.creative.release",
            goalText: "Prepare and release the song."
        )

        XCTAssertEqual(step.dependencyStepIDs, ["creative.step1", "creative.step2"])
        XCTAssertEqual(step.actionability.action, "Open step")
        XCTAssertEqual(step.timing.dueAt, "2026-08-31")
        XCTAssertTrue(step.evidenceRequired)
        XCTAssertEqual(receipt.sourceObject?.id, sourceRecord.id)
        XCTAssertEqual(proofLedgerEntry.sourceRecordLabel, "Source record is source-tied")
        XCTAssertTrue(replayTrace.isReplayable)
    }

    func testRelationshipBalanceJourneyFixtureIncludesRequiredEvidence() throws {
        let sourceRecord = KnowledgeSourceRecord(
            id: "source.journey.relationship.balance",
            providerID: "provider.local",
            entityTitle: "Relationship/life balance journey",
            publisher: nil,
            locator: "local://journey/relationship-balance",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let relationshipBoundary = CrossAppJourneyYouInspectionBoundary(
            surfaceTitle: "Search Ambitions",
            sourceKnowledgeLabel: "Relationship source knowledge",
            allowsRawActivityLog: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let journeyObject = LifeGraphObjectReference(
            kind: .commitment,
            id: "commitment.relationship.balance",
            label: "Protect Wednesday dinner",
            sourceDomain: .today
        )
        let receipt = ActionReceipt(
            id: "receipt.journey.relationship.balance",
            resultState: .completed,
            title: "Relationship/life balance fixture recorded",
            summary: "Protected time and reminders are source-backed.",
            sourceDomain: .today,
            occurredAt: "2026-05-24T12:15:00Z",
            affectedObjects: [journeyObject],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(receipt: receipt, proofRelevance: .countsAsProof)
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id),
            decisionKey: "journey.relationship.balance",
            goalText: "Protect balanced relationship life commitments."
        )

        XCTAssertEqual(relationshipBoundary.surfaceTitle, "Search Ambitions")
        XCTAssertTrue(relationshipBoundary.isInspectableBoundary)
        XCTAssertEqual(proofLedgerEntry.sourceObjectID, sourceRecord.id)
        XCTAssertEqual(replayTrace.recommendation?.receipt.proofReferenceIDs, [proofLedgerEntry.proofReference!.id])
        XCTAssertEqual(replayTrace.decisionReceipt?.replayTraceLabel, "Replay trace stays local and inspectable")
    }

    func testSensitiveContextJourneyFixtureIncludesRequiredEvidence() throws {
        let sourceRecord = KnowledgeSourceRecord(
            id: "source.journey.sensitive.context",
            providerID: "provider.local",
            entityTitle: "Sensitive recovery journey",
            publisher: nil,
            locator: "local://journey/sensitive-context",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let journeyObject = LifeGraphObjectReference(
            kind: .commitment,
            id: "commitment.sensitive.context",
            label: "Review recovery light-load recommendation",
            sourceDomain: .today
        )
        let receipt = ActionReceipt(
            id: "receipt.journey.sensitive.context",
            resultState: .completed,
            title: "Sensitive context fixture recorded",
            summary: "Sensitive context boundary is reviewable in You.",
            sourceDomain: .today,
            occurredAt: "2026-05-24T12:15:00Z",
            affectedObjects: [journeyObject],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(receipt: receipt, proofRelevance: .countsAsProof)
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: try XCTUnwrap(proofLedgerEntry.proofReference?.id),
            decisionKey: "journey.sensitive.context",
            goalText: "Reduce load when knee soreness is detected."
        )
        let boundary = CrossAppJourneyYouInspectionBoundary(
            surfaceTitle: "Search Ambitions",
            sourceKnowledgeLabel: "Sensitive context source knowledge",
            allowsRawActivityLog: false
        )

        XCTAssertEqual(sourceRecord.entityTitle, "Sensitive recovery journey")
        XCTAssertEqual(receipt.resultState, .completed)
        XCTAssertEqual(replayTrace.state, .ready)
        XCTAssertTrue(replayTrace.isLocalOnly)
        XCTAssertTrue(replayTrace.isReplayable)
        XCTAssertEqual(boundary.sourceKnowledgeLabel, "Sensitive context source knowledge")
        XCTAssertTrue(boundary.blocksRawActivityLogCopy)
        XCTAssertEqual(proofLedgerEntry.sourceRecordLabel, "Source record is source-tied")
        XCTAssertEqual(replayTrace.decisionReceipt?.sourceRecordLabel, "Source record stays local")
    }

    private func makeReplayTrace(
        sourceRecordID: String,
        receiptID: String,
        proofReferenceID: String,
        decisionKey: String,
        goalText: String
    ) -> ReplayableDecisionTrace {
        let runtimeContext = RuntimeContextSnapshot(
            clientContext: .iphoneApp,
            capabilities: .currentLocalRuntime,
            syncStatus: SyncCapabilityStatus(
                backendKind: .localOnly,
                trustPosture: .localOnly,
                availability: .unavailable,
                detail: "Journey contract evidence is local-only."
            ),
            knowledgeProviderStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "provider.local",
                        type: .systemFallback,
                        displayName: "Local provider"
                    ),
                    availability: .localOnlyMode,
                    detail: "Journey evidence stays on-device.",
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
            id: "trace.\(decisionKey)",
            recommendationID: "recommendation.\(decisionKey)",
            source: RecommendationTraceSource(
                citedSourceIDs: [sourceRecordID],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth, .memoryEvent],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation.\(decisionKey)",
                summary: "Cross-app journey evidence stays local and inspectable.",
                evidenceCategoryIDs: ["memory_event", "source_truth"]
            ),
            fit: RecommendationTraceFit(state: .fits, blockReasons: [], canDriveRecommendation: true),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty.\(decisionKey)"],
                summaries: ["Evidence is user-owned and reviewable."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct.journey"],
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
                decisionKey: decisionKey,
                goalText: goalText,
                recommendationTrace: recommendationTrace
            )
        )
    }
}

private struct CrossAppJourneyContractHarnessFixture: Sendable, Equatable {
    static let forbiddenBroadClaims = [
        "cross-app replacement is incomplete",
        "source evidence is missing",
        "cannot claim completion yet",
        "runtime claims not fully proven",
        "accessibility proof missing",
        "performance proof missing",
        "privacy approval not demonstrated",
        "release boundary not proven",
        "App Store boundary not validated",
    ]

    let halfMarathonEvidence: Bool
    let moveApartmentEvidence: Bool
    let careerGrowthEvidence: Bool
    let creativeReleaseEvidence: Bool
    let relationshipBalanceEvidence: Bool
    let sensitiveContextEvidence: Bool
    let sourceRecordEvidence: Bool
    let receiptEvidence: Bool
    let replayTraceEvidence: Bool
    let youInspectionBoundaryEvidence: Bool
    let unsupportedClaims: [String]

    var missingEvidence: [String] {
        var items: [String] = []
        if halfMarathonEvidence == false { items.append("half-marathon journey") }
        if moveApartmentEvidence == false { items.append("move/apartment journey") }
        if careerGrowthEvidence == false { items.append("career growth journey") }
        if creativeReleaseEvidence == false { items.append("creative release journey") }
        if relationshipBalanceEvidence == false { items.append("relationship/life balance journey") }
        if sensitiveContextEvidence == false { items.append("sensitive context journey") }
        if sourceRecordEvidence == false { items.append("SourceRecord") }
        if receiptEvidence == false { items.append("local Receipt") }
        if replayTraceEvidence == false { items.append("ReplayTrace") }
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

private struct CrossAppJourneyYouInspectionBoundary: Sendable, Equatable {
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

private struct CrossAppDownstreamReplacementClaimHarnessFixture: Sendable, Equatable {
    static let forbiddenBroadClaims = [
        "T04F source-knowledge replacement claim unsupported",
        "T04G source-knowledge replacement claim unsupported",
        "T04H source-knowledge replacement claim unsupported",
        "T04I source-knowledge replacement claim unsupported",
        "T04K source-knowledge replacement claim unsupported",
        "sensitive learned behavior replacement claim unsupported",
        "local intelligence replacement claim unsupported",
    ]

    let gates: [CrossAppDownstreamClaimBoundary]
    let unsupportedClaims: [String]

    var missingEvidence: [String] {
        gates.flatMap { gate in
            if gate.allEvidencePresent {
                return [] as [String]
            }
            return [
                "\(gate.trainID) requires SourceRecord, local Receipt, ReplayTrace, You inspection boundary, " +
                "source knowledge proof, sensitive learned behavior proof, and local intelligence proof"
            ]
        }.sorted()
    }

    var allEvidencePresent: Bool {
        gates.allSatisfy(\.allEvidencePresent)
    }

    var blocksBroadReplacementClaims: Bool {
        allEvidencePresent == false || unsupportedClaims.isEmpty == false
    }

    var blockedClaims: [String] {
        Array(Set(unsupportedClaims)).sorted()
    }
}

private struct CrossAppDownstreamClaimBoundary: Sendable, Equatable {
    let trainID: String
    let sourceKnowledgeEvidence: Bool
    let sensitiveLearnedBehaviorEvidence: Bool
    let localIntelligenceEvidence: Bool
    let sourceRecordEvidence: Bool
    let receiptEvidence: Bool
    let replayTraceEvidence: Bool
    let youInspectionBoundaryEvidence: Bool

    var allEvidencePresent: Bool {
        sourceKnowledgeEvidence && sensitiveLearnedBehaviorEvidence && localIntelligenceEvidence &&
            sourceRecordEvidence && receiptEvidence && replayTraceEvidence && youInspectionBoundaryEvidence
    }
}
