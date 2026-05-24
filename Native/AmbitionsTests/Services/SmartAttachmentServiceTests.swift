import XCTest
@testable import Ambitions

final class SmartAttachmentServiceTests: XCTestCase {
    func testHighConfidenceProofAttachesToMatchingLocalGoal() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "Finished first mix proof for Music Goal"),
            candidates: [
                SmartAttachmentDestinationCandidate(
                    id: "goal-music",
                    label: "Music Goal",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.goal, .task, .proofItem]
                )
            ],
            maxCandidateCount: 5
        )

        XCTAssertEqual(result.resultState, .attached)
        XCTAssertEqual(result.confidence, .high)
        XCTAssertEqual(result.selectedCandidate?.target.routeType, .proofItem)
        XCTAssertEqual(result.selectedCandidate?.target.destinationID, "goal-music")
        XCTAssertEqual(result.receiptLine, "Attached as Proof · Music Goal")
        XCTAssertEqual(result.actions, [.change, .keepStandalone])
    }

    func testMediumConfidenceTaskSavesStandaloneWithSuggestion() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "Find NASA contacts on LinkedIn later"),
            candidates: [
                SmartAttachmentDestinationCandidate(
                    id: "goal-astronaut",
                    label: "NASA contacts",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.goal, .task, .proofItem],
                    placementLabel: "Become an Astronaut"
                )
            ],
            maxCandidateCount: 5
        )

        XCTAssertEqual(result.resultState, .savedStandalone)
        XCTAssertEqual(result.confidence, .medium)
        XCTAssertEqual(result.selectedCandidate?.target.routeType, .task)
        XCTAssertEqual(result.suggestedCandidate?.target.destinationID, "goal-astronaut")
        XCTAssertEqual(result.receiptLine, "Saved as Task · Today")
        XCTAssertTrue(result.actions.contains(.change))
        XCTAssertTrue(result.actions.contains(.keepStandalone))
        XCTAssertTrue(result.actions.contains(.attach))
    }

    func testLowConfidenceAsksCompactClarificationAndSavesNeedsPlace() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "NASA"),
            candidates: [],
            maxCandidateCount: 5
        )

        XCTAssertEqual(result.resultState, .needsClarification)
        XCTAssertEqual(result.confidence, .needsClarification)
        XCTAssertEqual(result.selectedCandidate?.target.destinationKind, .needsPlace)
        XCTAssertEqual(result.receiptLine, "Saved to Needs a Place")
        XCTAssertEqual(result.clarification?.question, "What should this become?")
        XCTAssertEqual(result.clarification?.choices.map(\.actionLabel), [.task, .goal, .idea])
        XCTAssertEqual(result.clarification?.choices.count, 3)
    }

    func testEB04AmbiguousClassificationAsksOneQuestionWithoutForcingRoute() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "Maybe build launch checklist tomorrow"),
            candidates: [],
            maxCandidateCount: 5
        )

        XCTAssertEqual(result.resultState, .needsClarification)
        XCTAssertEqual(result.confidence, .needsClarification)
        XCTAssertEqual(result.receiptLine, "Saved to Needs a Place")
        XCTAssertEqual(result.explanation, "Saved to Needs a Place because this could become more than one useful thing.")
        XCTAssertEqual(result.clarification?.question, "What should this become first?")
        XCTAssertEqual(result.clarification?.choices.map(\.routeType), [.goal, .idea, .task])
        XCTAssertEqual(result.actions, [.goal, .idea, .task])
        XCTAssertEqual(result.captureRoute, .captureInbox)
    }

    func testEB04ProofClassificationDoesNotAskWhenLocalGoalEvidenceMatches() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "Finished launch proof tomorrow"),
            candidates: [
                SmartAttachmentDestinationCandidate(
                    id: "goal-launch",
                    label: "Launch",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.proofItem]
                )
            ],
            maxCandidateCount: 5
        )

        XCTAssertEqual(result.resultState, .attached)
        XCTAssertNil(result.clarification)
        XCTAssertEqual(result.selectedCandidate?.target.routeType, .proofItem)
    }

    func testEB04AmbiguousManualChoiceStillMapsToCaptureRequest() {
        let adapter = SmartAttachmentCaptureAdapter()

        let decision = adapter.decision(
            rawText: "Maybe build launch checklist tomorrow",
            sourceType: .todayQuickCapture,
            sourceSurface: "Capture",
            selectedRouteType: .task
        )
        let request = decision?.createCaptureRequest(
            rawText: "Maybe build launch checklist tomorrow",
            sourceType: .todayQuickCapture
        )

        XCTAssertEqual(decision?.receiptLine, "Saved as Task · Today")
        XCTAssertEqual(request?.kind, .oneTimeCommitment)
        XCTAssertEqual(request?.route, .timeSeed)
        XCTAssertEqual(request?.triageStatus, .assumedRoute)
    }

    func testEB05AmbiguousCaptureCreatesReviewBundleWithOpenLoopSignal() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "Maybe build launch checklist tomorrow"),
            candidates: [],
            maxCandidateCount: 5
        )
        let bundle = result.reviewBundle

        XCTAssertEqual(bundle.title, "Needs a Place review")
        XCTAssertEqual(bundle.summary, "1 open review loop kept explicit before placement.")
        XCTAssertEqual(bundle.clusters.map(\.title), ["Unplaced capture"])
        XCTAssertEqual(bundle.clusters.first?.summary, "Held safely until the user chooses where it belongs.")
        XCTAssertEqual(bundle.openLoopSignals.map(\.title), ["Route needs a choice"])
        XCTAssertEqual(bundle.openLoopSignals.first?.requiresUserChoice, true)
        XCTAssertTrue(bundle.accessibilitySummary.contains("1 open loop"))
        XCTAssertFalse(bundle.accessibilitySummary.localizedCaseInsensitiveContains("AI"))
    }

    func testEB05SuggestedAttachmentCreatesRouteReviewBundleWithoutPersistenceChange() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "Find NASA contacts on LinkedIn later"),
            candidates: [
                SmartAttachmentDestinationCandidate(
                    id: "goal-astronaut",
                    label: "NASA contacts",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.goal, .task, .proofItem],
                    placementLabel: "Become an Astronaut"
                )
            ],
            maxCandidateCount: 5
        )
        let bundle = result.reviewBundle

        XCTAssertEqual(bundle.title, "Route review")
        XCTAssertEqual(bundle.clusters.map(\.title), ["Task"])
        XCTAssertEqual(bundle.clusters.first?.evidenceLabels, ["contacts", "nasa"])
        XCTAssertEqual(bundle.openLoopSignals.map(\.title), ["Suggested attachment available"])
        XCTAssertEqual(bundle.actionTitles, ["Attach", "Change", "Keep Standalone"])
        XCTAssertEqual(result.captureRoute, .timeSeed)
        XCTAssertEqual(result.triageStatus, .assumedRoute)
    }

    func testEB06ReclassificationProjectionKeepsUndoHonestAndCorrectionVisible() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "Find NASA contacts on LinkedIn later"),
            candidates: [
                SmartAttachmentDestinationCandidate(
                    id: "goal-astronaut",
                    label: "NASA contacts",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.goal, .task, .proofItem],
                    placementLabel: "Become an Astronaut"
                )
            ],
            maxCandidateCount: 5
        )
        let projection = result.reclassificationProjection
        let receipt = result.actionReceipt(captureID: "capture-1", occurredAt: "2026-05-03T23:20:00Z")

        XCTAssertEqual(projection.receiptTitle, "Saved as Task · Today")
        XCTAssertEqual(projection.undoAvailability, .notSupportedYet)
        XCTAssertEqual(projection.correctionAvailability, .availableWithReason)
        XCTAssertEqual(projection.reclassificationActions, ["Attach", "Change", "Keep Standalone"])
        XCTAssertTrue(projection.rollbackSummary.contains("Needs a Place"))
        XCTAssertTrue(projection.accessibilitySummary.contains("Undo not supported yet"))
        XCTAssertEqual(receipt.undoAvailability, .notSupportedYet)
        XCTAssertEqual(receipt.correctionAvailability, .availableWithReason)
    }

    func testEB06FailedCaptureProjectionDoesNotExposeFakeUndoOrCorrection() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "   "),
            candidates: [],
            maxCandidateCount: 5
        )
        let projection = result.reclassificationProjection

        XCTAssertEqual(projection.undoAvailability, .notSupportedYet)
        XCTAssertEqual(projection.correctionAvailability, .unavailable)
        XCTAssertEqual(projection.reclassificationActions, [])
        XCTAssertTrue(projection.undoSummary.contains("not applied automatically"))
        XCTAssertTrue(projection.accessibilitySummary.contains("Undo not supported yet"))
    }

    func testFailureUsesNeedsPlaceAndRetryCopyMetadata() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "   "),
            candidates: [],
            maxCandidateCount: 5
        )

        XCTAssertEqual(result.resultState, .failedSafely)
        XCTAssertEqual(result.confidence, .unavailableFailed)
        XCTAssertEqual(result.receiptLine, "Saved to Needs a Place")
        XCTAssertEqual(result.failureReason, "Empty capture text")
        XCTAssertTrue(result.actions.contains(.retry))
        XCTAssertTrue(result.actions.contains(.copy))
    }

    func testCandidateRankingIsDeterministicAndLimitable() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "finish launch proof"),
            candidates: [
                SmartAttachmentDestinationCandidate(id: "goal-b", label: "Launch proof", destinationKind: .existingGoal, supportedRouteTypes: [.proofItem]),
                SmartAttachmentDestinationCandidate(id: "goal-a", label: "Launch proof", destinationKind: .existingGoal, supportedRouteTypes: [.proofItem]),
                SmartAttachmentDestinationCandidate(id: "goal-c", label: "Launch", destinationKind: .existingGoal, supportedRouteTypes: [.proofItem])
            ],
            maxCandidateCount: 1
        )

        XCTAssertEqual(result.selectedCandidate?.target.destinationID, "goal-a")
        XCTAssertEqual(result.selectedCandidate?.score, 14)
    }

    func testServiceDoesNotRequireNetworkAccountCalendarOrExternalCandidates() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "Schedule proposal tomorrow"),
            candidates: [],
            maxCandidateCount: 5
        )

        XCTAssertEqual(result.resultState, .savedStandalone)
        XCTAssertEqual(result.confidence, .high)
        XCTAssertEqual(result.receiptLine, "Saved as Plan · This Week")
        XCTAssertEqual(result.captureRoute, .timeSeed)
        XCTAssertEqual(result.captureAssumptionSummary, "Saved as a Plan item without scheduling or calendar changes.")
    }

    func testF08PlacementPreviewShowsDestinationConsequenceAndPrivacy() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "Book dentist"),
            candidates: [],
            maxCandidateCount: 5
        )
        let preview = result.placementPreview

        XCTAssertEqual(preview.originalText, "Book dentist")
        XCTAssertEqual(preview.postInputStateTitle, "Ready to Place")
        XCTAssertEqual(preview.suggestedDestination, "Task · Today")
        XCTAssertEqual(preview.objectTypeLabel, "Task")
        XCTAssertEqual(preview.appearanceLabel, "Today")
        XCTAssertTrue(preview.affectsToday)
        XCTAssertEqual(preview.consequenceLabel, "Adds a visible Task to Today after you confirm.")
        XCTAssertEqual(preview.privacyLabel, "Private item")
        XCTAssertEqual(preview.primaryActionTitle, "Place it")
        XCTAssertEqual(preview.changeActionTitle, "Change")
        XCTAssertEqual(preview.safeActionTitle, "Decide later")
    }

    func testF08NeedsPlacePreviewPreservesSafePlacementWithoutForcingStructure() {
        let service = DefaultSmartAttachmentService()

        let result = service.route(
            SmartAttachmentInput(rawText: "NASA"),
            candidates: [],
            maxCandidateCount: 5
        )
        let preview = result.placementPreview

        XCTAssertEqual(preview.postInputStateTitle, "Needs a Place")
        XCTAssertEqual(preview.suggestedDestination, "Needs a Place")
        XCTAssertEqual(preview.objectTypeLabel, "Unplaced capture")
        XCTAssertEqual(preview.appearanceLabel, "Needs a Place")
        XCTAssertFalse(preview.affectsToday)
        XCTAssertEqual(preview.consequenceLabel, "Saved safely without forcing structure.")
    }

    func testD12CaptureAdapterCreatesRequestFromSmartAttachmentDecision() {
        let adapter = SmartAttachmentCaptureAdapter()

        let decision = adapter.decision(
            rawText: "Book dentist",
            sourceType: .todayQuickCapture,
            sourceSurface: "Capture"
        )
        let request = decision?.createCaptureRequest(rawText: "Book dentist", sourceType: .todayQuickCapture)

        XCTAssertEqual(decision?.receiptLine, "Saved as Task · Today")
        XCTAssertEqual(request?.kind, .oneTimeCommitment)
        XCTAssertEqual(request?.route, .timeSeed)
        XCTAssertEqual(request?.triageStatus, .assumedRoute)
        XCTAssertEqual(request?.assumptionSummary, "Saved as a standalone Task because no existing local destination was reliable enough.")
    }

    func testEB03BRouteProofStaysLocalAndAccessible() {
        let adapter = SmartAttachmentCaptureAdapter()

        let decision = adapter.decision(
            rawText: "Finished launch proof",
            sourceType: .todayQuickCapture,
            sourceSurface: "Capture",
            candidates: [
                SmartAttachmentDestinationCandidate(
                    id: "goal-launch",
                    label: "Launch",
                    destinationKind: .existingGoal,
                    supportedRouteTypes: [.proofItem],
                    placementLabel: "Launch Goal"
                )
            ]
        )

        XCTAssertEqual(decision?.receiptLine, "Attached as Proof · Launch")
        XCTAssertEqual(decision?.result.selectedCandidate?.evidenceLabels, ["launch"])
        XCTAssertEqual(decision?.createCaptureRequest(rawText: "Finished launch proof").linkedGoalID, "goal-launch")
        XCTAssertTrue(decision?.accessibilityValue.localizedCaseInsensitiveContains("Route evidence: launch") == true)
        XCTAssertFalse(decision?.accessibilityValue.localizedCaseInsensitiveContains("AI") == true)
        XCTAssertFalse(decision?.accessibilityValue.localizedCaseInsensitiveContains("cloud") == true)
    }

    func testD12CaptureAdapterManualNeedsPlaceChoiceStaysPressureFree() {
        let adapter = SmartAttachmentCaptureAdapter()

        let decision = adapter.decision(
            rawText: "NASA",
            sourceType: .todayQuickCapture,
            sourceSurface: "Capture",
            selectedRouteType: .idea
        )
        let request = decision?.createCaptureRequest(rawText: "NASA", sourceType: .todayQuickCapture)

        XCTAssertEqual(decision?.receiptLine, "Saved to Needs a Place")
        XCTAssertEqual(decision?.summary, "Held without pressure until you choose a clearer route.")
        XCTAssertEqual(request?.kind, .raw)
        XCTAssertEqual(request?.route, .captureInbox)
        XCTAssertEqual(request?.triageStatus, .needsTriage)
    }

    func testSemanticExtractionForAmbiguousClockTimeSurfacesClarificationWithoutScheduling() {
        let adapter = SmartAttachmentCaptureAdapter()

        let decision = adapter.decision(
            rawText: "play pickleball at 8 next Tuesday",
            sourceType: .todayQuickCapture,
            sourceSurface: "Capture"
        )

        XCTAssertEqual(decision?.semanticExtraction.rawText, "play pickleball at 8 next Tuesday")
        XCTAssertEqual(decision?.semanticExtraction.interpretedDateTime?.ambiguity, .amPm)
        XCTAssertEqual(decision?.semanticExtraction.interpretedDateTime?.requiresUserConfirmation, true)
        XCTAssertEqual(decision?.semanticClarificationQuestion, "Do you mean 8 AM or 8 PM?")
        XCTAssertTrue(decision?.semanticExtraction.needsClarification == true)
        XCTAssertNil(decision?.createCaptureRequest(rawText: "play pickleball at 8 next Tuesday").deadlineText)
        XCTAssertTrue(decision?.createCaptureRequest(rawText: "play pickleball at 8 next Tuesday").assumptionSummary?.contains("calendar") == false)
    }
}
