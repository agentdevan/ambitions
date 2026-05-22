import XCTest
@testable import Ambitions

final class AmbitionsOSVerticalSliceProofModelsTests: XCTestCase {
    func testVerticalSliceProofReportCoversLocalCaptureReceiptTraceAndReplayIdempotency() async throws {
        let captureRepository = PreviewCaptureRepository()
        let eventLedger = InMemoryEventLedgerRepository()
        let commandExecutionRecords = InMemoryAmbitionsCommandExecutionRecordRepository()
        let captureService = DefaultCaptureService(
            repository: captureRepository,
            eventLedger: eventLedger,
            idProvider: { "capture-vertical-slice" }
        )
        let executor = AmbitionsCommandExecutor(
            captureService: captureService,
            eventLedger: eventLedger,
            commandExecutionRecords: commandExecutionRecords
        )
        let now = Date(timeIntervalSince1970: 1_778_000_000)
        let createdAt = DomainTimestamp.string(from: now)
        let command = AmbitionsCommand(
            id: "command-vertical-slice",
            kind: .quickCapture,
            source: .today,
            payload: AmbitionsCommandPayload(rawText: "Capture the vertical slice proof"),
            createdAt: createdAt,
            sourceSurface: "today"
        )

        let firstResult = await executor.execute(command, context: CommandExecutionContext(now: now))
        let replayResult = await executor.execute(command, context: CommandExecutionContext(now: now.addingTimeInterval(60)))

        let captures = try await captureRepository.listCaptures()
        let events = try await eventLedger.fetchRecent(limit: 10)
        let storedRecord = try await commandExecutionRecords.fetchRecord(commandID: command.id)
        let capture = try XCTUnwrap(captures.first)
        let captureEvent = try XCTUnwrap(events.first)
        let record = try XCTUnwrap(storedRecord)
        let commandReceipt = ActionReceipt.fromCommandResult(
            command: command,
            result: firstResult,
            occurredAt: createdAt
        )
        let closureReceipt = ActionReceipt.closureReceipt(
            id: "receipt.closure.\(command.id)",
            occurrence: StepOccurrence(
                stepID: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
                duration: DurationMetadata(plannedDuration: .seconds(900), source: .userSet),
                rigidity: .flexible,
                readiness: .ready,
                closureState: .awaitingClosure
            ),
            outcome: .stillCounts,
            stepTitle: capture.rawText,
            occurredAt: DomainTimestamp.string(from: now.addingTimeInterval(30)),
            why: "The local capture remained inspectable and reversible."
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(
            receipt: closureReceipt,
            proofRelevance: .countsAsProof
        )
        let proofReference = try XCTUnwrap(proofLedgerEntry.proofReference)
        let sourceAtlasResult = SourceAtlasQueryResult(
            id: "source-atlas.vertical-slice",
            packID: "pack.local.vertical-slice",
            domainID: "capture",
            goalIntent: "capture_proof_slice",
            claimID: "claim.vertical-slice",
            requirementID: "requirement.vertical-slice",
            sourceState: .officialCurrent,
            freshnessState: .current,
            riskState: .low,
            riskClass: .careerContext,
            reviewState: .approved,
            provenanceSourceIDs: [capture.id, captureEvent.id],
            proofEntryIDs: [captureEvent.id],
            fallbackReason: SourceAtlasQueryFallbackReason.none,
            sourceNeededDetail: nil
        )
        let sourceClaim = AmbitionsOSStartHereRecommendation.sourceClaim(
            from: sourceAtlasResult,
            text: "The capture is backed by local capture, event, and receipt evidence."
        )
        let controlRequest = AmbitionsOSControlPlaneWorkRequest(
            id: "work.vertical-slice",
            title: "Local capture proof",
            surface: .today,
            requestedAt: createdAt
        )
        let proofTrustReceipt = AmbitionsOSProofTrustReceipt(
            id: "proof-trust.vertical-slice",
            kind: .closure,
            surface: .today,
            occurredAt: closureReceipt.occurredAt,
            affectedObjectIDs: [capture.id],
            actionReceiptIDs: [commandReceipt.id, closureReceipt.id],
            proofReferenceIDs: [proofReference.id],
            sourceClaimIDs: [sourceClaim.id],
            sourcePackIDs: sourceClaim.sourcePackIDs,
            changedFactSummaries: closureReceipt.changedFacts.map(\.summary),
            closureOutcome: .stillCounts,
            sourceState: .sourceBacked,
            freshnessState: .current,
            reviewState: .ready,
            privacyClass: .privateLife,
            reversible: true,
            professionalBoundaryReviewRequired: false
        )
        let recommendation = AmbitionsOSStartHereRecommendation(
            id: "start-here.vertical-slice",
            title: "Review the captured step",
            kind: .startHere,
            surface: .today,
            recommendedObjectID: capture.id,
            sourceLabel: "Local capture and receipt trail",
            sourceClaims: [sourceClaim],
            proofTrustReceipts: [proofTrustReceipt],
            controlClassification: AmbitionsOSControlPlaneClassifier().classify(controlRequest),
            fitState: .fits,
            whyNow: ["The capture is already grounded in a local event and receipt trail."],
            advances: ["Keeps the proof slice inspectable."],
            protects: ["Avoids hidden calendar writes and silent mutation."],
            assumptions: ["The next action stays user-controlled."],
            notChosen: ["No broader planner surface is needed for this slice."],
            controlActions: [.start, .open, .adjust],
            privacyClass: .privateLife,
            runtimeBoundary: .valueModelOnly,
            surfaceLanguageSamples: ["Start here with the local capture trail"]
        )
        let explanation = RecommendationExplanation(
            id: "explanation.vertical-slice",
            type: .whyThis,
            title: "Why this capture is the right local starting point",
            summary: "The capture, event, receipt, and replay trail all stay local and inspectable.",
            recommendationTitle: recommendation.title,
            recommendationSummary: "Start here from the capture trail.",
            confidence: .high,
            evidence: [
                .fromEventLedgerEntry(captureEvent, category: .captureState),
                .fromSourceAtlasQueryResult(sourceAtlasResult)
            ],
            assumptions: [
                RecommendationExplanationAssumption(
                    id: "assumption.vertical-slice",
                    summary: "The user can still adjust the next step."
                )
            ],
            uncertainty: [
                RecommendationExplanationUncertainty(
                    id: "uncertainty.vertical-slice",
                    summary: "The next step may still need a manual adjustment."
                )
            ],
            userCorrectableFields: ["rawText"],
            correctionActions: [
                RecommendationExplanationCorrectionAction(
                    id: "correction.vertical-slice.adjust",
                    kind: .changeRoute,
                    title: "Change route"
                )
            ],
            lastUpdatedAt: createdAt,
            source: .capture,
            relations: RecommendationExplanationRelations(
                captureIDs: [capture.id],
                eventLedgerEntryIDs: [captureEvent.id]
            ),
            privacy: .standard,
            localOnly: true
        )
        let trace = RecommendationTrace(startHere: recommendation, explanation: explanation)
        let report = AmbitionsOSVerticalSliceProofReport(
            command: command,
            capture: capture,
            captureEvent: captureEvent,
            commandResult: firstResult,
            commandReceipt: commandReceipt,
            closureReceipt: closureReceipt,
            sourceClaim: sourceClaim,
            proofTrustReceipt: proofTrustReceipt,
            startHereRecommendation: recommendation,
            startHereTrace: trace,
            replayResult: replayResult
        )

        XCTAssertEqual(firstResult.status, .succeeded)
        XCTAssertEqual(firstResult.target?.captureID, capture.id)
        XCTAssertEqual(replayResult.status, .succeeded)
        XCTAssertEqual(replayResult.metadata["replayDecision"], LedgerReplayDecision.replayExistingReceipt.rawValue)
        XCTAssertEqual(replayResult.metadata["doubleApplyDisposition"], LedgerDoubleApplyDisposition.skipDuplicateMutation.rawValue)
        XCTAssertEqual(captures.count, 1)
        XCTAssertTrue(events.contains { $0.kind == .captureCreated && $0.captureID == capture.id })
        XCTAssertTrue(events.allSatisfy { $0.captureID == capture.id })
        XCTAssertEqual(record.command.id, command.id)
        XCTAssertEqual(commandReceipt.why?.eventLedgerEntryIDs, [captureEvent.id])
        XCTAssertEqual(proofTrustReceipt.actionReceiptIDs, [commandReceipt.id, closureReceipt.id].sorted())
        XCTAssertEqual(proofTrustReceipt.proofReferenceIDs, [proofReference.id])
        XCTAssertTrue(sourceClaim.canDriveSourceSensitiveRecommendation)
        XCTAssertTrue(recommendation.isWellFormed)
        XCTAssertEqual(AmbitionsOSStartHereRecommendationValidator().validate(recommendation), [])
        XCTAssertTrue(trace.isComplete)
        XCTAssertTrue(trace.canDriveRecommendationBehavior)
        XCTAssertTrue(proofTrustReceipt.canCloseProofTrustGate)
        XCTAssertTrue(report.isValidated)
        XCTAssertTrue(report.validation.issues.isEmpty)
        XCTAssertEqual(report.replayOutcome.decision, .replayExistingReceipt)
        XCTAssertEqual(report.replayOutcome.doubleApplyDisposition, .skipDuplicateMutation)
        XCTAssertEqual(report.summaryLines.count, 8)
        XCTAssertTrue(report.summaryLines.last?.contains("no calendar write") == true)

        var replayMetadataMissingDoubleApplyDisposition = replayResult.metadata
        replayMetadataMissingDoubleApplyDisposition.removeValue(forKey: "doubleApplyDisposition")
        let replayResultMissingDoubleApplyDisposition = AmbitionsCommandExecutionResult(
            status: replayResult.status,
            summary: replayResult.summary,
            route: replayResult.route,
            target: replayResult.target,
            eventLedgerEntryIDs: replayResult.eventLedgerEntryIDs,
            recommendationExplanationIDs: replayResult.recommendationExplanationIDs,
            metadata: replayMetadataMissingDoubleApplyDisposition
        )
        let reportWithMissingReplayProofMetadata = AmbitionsOSVerticalSliceProofReport(
            command: command,
            capture: capture,
            captureEvent: captureEvent,
            commandResult: firstResult,
            commandReceipt: commandReceipt,
            closureReceipt: closureReceipt,
            sourceClaim: sourceClaim,
            proofTrustReceipt: proofTrustReceipt,
            startHereRecommendation: recommendation,
            startHereTrace: trace,
            replayResult: replayResultMissingDoubleApplyDisposition
        )

        XCTAssertEqual(reportWithMissingReplayProofMetadata.replayOutcome.doubleApplyDisposition, .skipUnverifiedMutation)
        XCTAssertEqual(reportWithMissingReplayProofMetadata.validation.issues, [.replayNotIdempotent])
    }
}
