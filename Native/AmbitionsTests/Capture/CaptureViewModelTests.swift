import XCTest
@testable import Ambitions

@MainActor
final class CaptureViewModelTests: XCTestCase {
    func testLoadFetchesCapturesAndActiveGoalOptions() async {
        let captureService = MutableCaptureService(captures: [capture(id: "capture-1", rawText: "First")])
        let goalsService = StaticGoalsService(items: [
            goalItem(id: "goal-active", title: "Active goal", renderState: .active),
            goalItem(id: "goal-on-hold", title: "On hold goal", renderState: .onHold)
        ])
        let viewModel = CaptureViewModel()

        await viewModel.load(captureService: captureService, goalsService: goalsService)

        guard case let .loaded(state) = viewModel.state else {
            return XCTFail("Expected loaded captures state.")
        }
        XCTAssertEqual(state.captures.map(\.id), ["capture-1"])
        XCTAssertEqual(state.activeGoalOptions, [
            CaptureGoalOption(id: "goal-active", title: "Active goal", subtitle: "In motion")
        ])
    }

    func testArchiveAndSaveToNeedsPlaceCallServiceAndRefresh() async {
        let captureService = MutableCaptureService(captures: [capture(id: "capture-1", rawText: "First")])
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CaptureViewModel()

        await viewModel.archive(id: "capture-1", captureService: captureService, goalsService: goalsService, now: fixedNow)
        var stored = await captureService.capture(id: "capture-1")
        XCTAssertEqual(stored?.status, .archived)
        XCTAssertEqual(viewModel.actionMessage?.title, "Archived")

        await captureService.setCaptures([capture(id: "capture-2", rawText: "Second")])
        await viewModel.saveToNeedsPlace(id: "capture-2", captureService: captureService, goalsService: goalsService, now: fixedNow)
        stored = await captureService.capture(id: "capture-2")
        XCTAssertEqual(stored?.status, .needsTriage)
        XCTAssertEqual(stored?.triage?.destination, .needsTriage)
        XCTAssertEqual(stored?.kind, .raw)
        XCTAssertEqual(stored?.route, .captureInbox)
        XCTAssertEqual(viewModel.actionMessage?.title, "Saved to Needs a Place")
    }

    func testCaptureRouteActionsCallServiceAndRefresh() async {
        let captureService = MutableCaptureService(captures: [
            capture(id: "plan", rawText: "Create spreadsheet"),
            capture(id: "waiting", rawText: "Waiting on invoice"),
            capture(id: "someday", rawText: "Learn piano"),
            capture(id: "deliverable", rawText: "Add another song")
        ])
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CaptureViewModel()

        await viewModel.routeToTime(id: "plan", captureService: captureService, goalsService: goalsService, now: fixedNow)
        var stored = await captureService.capture(id: "plan")
        XCTAssertEqual(stored?.kind, .oneTimeCommitment)
        XCTAssertEqual(stored?.route, .timeSeed)
        XCTAssertEqual(stored?.status, .scheduled)
        XCTAssertEqual(viewModel.actionMessage?.title, "Saved as Task · Today")

        await viewModel.markWaiting(id: "waiting", captureService: captureService, goalsService: goalsService, now: fixedNow)
        stored = await captureService.capture(id: "waiting")
        XCTAssertEqual(stored?.kind, .waitingItem)
        XCTAssertEqual(stored?.route, .waiting)
        XCTAssertEqual(stored?.status, .waiting)
        XCTAssertEqual(viewModel.actionMessage?.title, "Saved as Waiting")

        await viewModel.markOptionalSomeday(id: "someday", captureService: captureService, goalsService: goalsService, now: fixedNow)
        stored = await captureService.capture(id: "someday")
        XCTAssertEqual(stored?.kind, .optionalSomeday)
        XCTAssertEqual(stored?.route, .optionalSomeday)
        XCTAssertEqual(stored?.status, .optionalSomeday)
        XCTAssertEqual(viewModel.actionMessage?.title, "Review later")

        await viewModel.markDeliverableSeed(id: "deliverable", text: "Add another song", captureService: captureService, goalsService: goalsService, now: fixedNow)
        stored = await captureService.capture(id: "deliverable")
        XCTAssertEqual(stored?.kind, .deliverableSeed)
        XCTAssertEqual(stored?.route, .deliverableSeed)
        XCTAssertEqual(stored?.status, .seed)
        XCTAssertEqual(viewModel.actionMessage?.title, "Saved as Idea")
    }

    func testD12DraftPreviewUsesSmartAttachmentAndCompactChoices() async {
        let captureService = MutableCaptureService(captures: [])
        let goalsService = StaticGoalsService(items: [
            goalItem(id: "goal-music", title: "Music Goal", renderState: .active)
        ])
        let viewModel = CaptureViewModel()

        await viewModel.load(captureService: captureService, goalsService: goalsService)
        viewModel.updateDraftText("NASA")

        XCTAssertEqual(viewModel.draftRoutePreview?.postInputStateTitle, "Needs a Place")
        XCTAssertEqual(viewModel.draftRoutePreview?.receiptTitle, "Saved to Needs a Place")
        XCTAssertEqual(viewModel.draftRoutePreview?.clarificationQuestion, "What should this become?")
        XCTAssertEqual(viewModel.draftRoutePreview?.choices.map(\.title), ["Task", "Goal", "Needs a Place"])
        XCTAssertEqual(viewModel.draftRoutePreview?.choices.count, 3)
        XCTAssertEqual(viewModel.draftRoutePreview?.routeProofTitle, "Route needs your choice")
        XCTAssertEqual(viewModel.draftRoutePreview?.routeProofDetail, "No safe destination yet; the capture stays private and editable.")

        viewModel.selectDraftRoute(.task)

        XCTAssertEqual(viewModel.draftRoutePreview?.receiptTitle, "Saved as Task · Today")
        XCTAssertEqual(viewModel.draftRoutePreview?.postInputStateTitle, "Ready to Place")
        XCTAssertEqual(viewModel.draftRoutePreview?.choices.first?.isSelected, true)
        XCTAssertEqual(viewModel.draftRoutePreview?.routeProofTitle, "Chosen by you")
        XCTAssertEqual(viewModel.draftRoutePreview?.routeProofDetail, "Chosen route")
    }

    func testSemanticExtractionClarificationQuestionSurfacesInDraftPreview() async {
        let captureService = MutableCaptureService(captures: [])
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CaptureViewModel()

        await viewModel.load(captureService: captureService, goalsService: goalsService)
        viewModel.updateDraftText("play pickleball at 8 next Tuesday")

        XCTAssertEqual(viewModel.draftRoutePreview?.clarificationQuestion, "Do you mean 8 AM or 8 PM?")
        XCTAssertTrue(viewModel.draftRoutePreview?.visibleCopy.localizedCaseInsensitiveContains("8 AM or 8 PM") == true)
    }

    func testPlanInsertionCandidateSurfacesInDraftPreviewWithoutMutationCopy() async {
        let captureService = MutableCaptureService(captures: [])
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CaptureViewModel()

        await viewModel.load(captureService: captureService, goalsService: goalsService)
        viewModel.updateDraftText("play pickleball at 8 next Tuesday")

        let preview = try! XCTUnwrap(viewModel.draftRoutePreview)
        let candidate = try! XCTUnwrap(preview.planInsertionCandidate)

        XCTAssertEqual(candidate.receiptProjection.title, "Add to Time")
        XCTAssertEqual(candidate.scheduleImpact, .timeChangeRecommended)
        XCTAssertEqual(candidate.conflictStatus, .ambiguity)
        XCTAssertEqual(preview.understoodLabel, "Looks like a scheduled activity.")
        XCTAssertEqual(preview.suggestedPlacementLabel, "Add to Time")
        XCTAssertEqual(preview.mayAffectLabel, "May support: Fitness / Social activity / Sports context.")
        XCTAssertEqual(preview.approvalNeededLabel, "Time needs confirmation: Do you mean 8 AM or 8 PM?")
        XCTAssertTrue(preview.changeableLabels.contains("Attach to goal"))
        XCTAssertTrue(preview.changeableLabels.contains("Save as context"))
        XCTAssertTrue(preview.changeableLabels.contains("Do not use for planning"))
        XCTAssertEqual(preview.safeFallbackLabel, "Decide later")
        XCTAssertTrue(preview.visibleCopy.localizedCaseInsensitiveContains("Add to Time"))
        XCTAssertTrue(preview.visibleCopy.localizedCaseInsensitiveContains("Save as context"))
        XCTAssertTrue(preview.visibleCopy.localizedCaseInsensitiveContains("Do not use for planning"))
        XCTAssertTrue(preview.visibleCopy.localizedCaseInsensitiveContains("Time needs confirmation: Do you mean 8 AM or 8 PM?"))
        XCTAssertTrue(preview.accessibilityValue.localizedCaseInsensitiveContains("Looks like a scheduled activity."))
        XCTAssertTrue(preview.accessibilityValue.localizedCaseInsensitiveContains("May support: Fitness / Social activity / Sports context."))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("silent mutation"))
    }

    func testAFI08DraftPreviewUsesApprovedAtmosphereComposerRouteStates() async {
        let captureService = MutableCaptureService(captures: [])
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CaptureViewModel()

        await viewModel.load(captureService: captureService, goalsService: goalsService)
        viewModel.updateDraftText("Maybe start a guitar goal")
        viewModel.selectDraftRoute(.goal)

        let preview = try! XCTUnwrap(viewModel.draftRoutePreview)
        XCTAssertEqual(preview.placementShelfTitle, "Atmosphere Composer")
        XCTAssertEqual(preview.postInputStateTitle, "Grow into Goal")
        XCTAssertTrue(preview.visibleCopy.localizedCaseInsensitiveContains("Needs a Place"))
        XCTAssertTrue(preview.visibleCopy.localizedCaseInsensitiveContains("Ready to Place") == false)
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("Suggested Place"))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("Needs a Decision"))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("inbox"))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("category board"))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("chat"))
    }

    func testF07ComposerPreviewUsesPlacementLanguageWithoutInboxFraming() async {
        let captureService = MutableCaptureService(captures: [])
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CaptureViewModel()

        await viewModel.load(captureService: captureService, goalsService: goalsService)
        viewModel.updateDraftText("Book dentist")

        let preview = try! XCTUnwrap(viewModel.draftRoutePreview)
        XCTAssertEqual(preview.placementShelfTitle, "Atmosphere Composer")
        XCTAssertEqual(preview.postInputStateTitle, "Ready to Place")
        XCTAssertEqual(preview.primaryActionTitle, "Place it")
        XCTAssertEqual(preview.changeActionTitle, "Change")
        XCTAssertEqual(preview.safeActionTitle, "Decide later")
        XCTAssertEqual(preview.objectTypeLabel, "Task")
        XCTAssertEqual(preview.appearanceLabel, "Today")
        XCTAssertEqual(preview.consequenceLabel, "Adds a visible Task to Today after you confirm.")
        XCTAssertEqual(preview.privacyLabel, "Private item")
        XCTAssertEqual(preview.localSourceLabel, "Local source: typed in Capture")
        XCTAssertEqual(preview.correctionLabel, "Correction: change the route before saving")
        XCTAssertEqual(preview.receiptSeamLabel, "Receipt seam: save creates a local capture receipt")
        XCTAssertEqual(preview.resolverFoldTitle, "Resolver Fold")
        XCTAssertEqual(preview.resolverWhyLabel, "What Ambitions thinks: Task based on local text only.")
        XCTAssertTrue(preview.correctionReceiptLabel.localizedCaseInsensitiveContains("recorded locally"))
        XCTAssertTrue(preview.correctionControlLabels.contains("Place somewhere else: choose a route below."))
        XCTAssertTrue(preview.correctionControlLabels.contains("Not now: Decide later keeps it out of Today."))
        XCTAssertTrue(preview.correctionControlLabels.contains("Discard: clear the composer before saving."))
        XCTAssertEqual(preview.routeProofTitle, "Route evidence")
        XCTAssertEqual(preview.routeProofDetail, "Standalone")
        XCTAssertTrue(preview.visibleCopy.localizedCaseInsensitiveContains("Atmosphere Composer"))
        XCTAssertTrue(preview.visibleCopy.localizedCaseInsensitiveContains("Resolver Fold"))
        XCTAssertTrue(preview.visibleCopy.localizedCaseInsensitiveContains("Local source"))
        XCTAssertTrue(preview.visibleCopy.localizedCaseInsensitiveContains("Correction"))
        XCTAssertTrue(preview.visibleCopy.localizedCaseInsensitiveContains("Receipt seam"))
        XCTAssertTrue(preview.visibleCopy.localizedCaseInsensitiveContains("not a goal"))
        XCTAssertTrue(preview.visibleCopy.localizedCaseInsensitiveContains("no hidden memory") == false)
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("inbox"))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("backlog"))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("triage"))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("classify"))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("chat"))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("AI"))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("cloud"))
    }

    func testFCP19ManualRouteSelectionKeepsCorrectionFoldUserOwned() async {
        let captureService = MutableCaptureService(captures: [])
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CaptureViewModel()

        await viewModel.load(captureService: captureService, goalsService: goalsService)
        viewModel.updateDraftText("Maybe start a guitar goal")
        viewModel.selectDraftRoute(.idea)

        let preview = try! XCTUnwrap(viewModel.draftRoutePreview)
        XCTAssertEqual(preview.correctionLabel, "Correction: route chosen by you")
        XCTAssertEqual(preview.resolverWhyLabel, "What Ambitions thinks: use the route you chose.")
        XCTAssertTrue(preview.correctionControlLabels.contains("Not a goal: no Goal is created unless you choose Goal."))
        XCTAssertTrue(preview.correctionControlLabels.contains("Decide later: save to Needs a Place."))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("confidence percentage"))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("fully automated"))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("hidden learning"))
    }

    func testSI09ComposerPresentationRevealsRouteWithoutSilentMutationCopy() async {
        let captureService = MutableCaptureService(captures: [])
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CaptureViewModel()

        await viewModel.load(captureService: captureService, goalsService: goalsService)
        viewModel.updateDraftText("Book dentist")

        let presentation = CaptureAtmosphereComposerPresentation(
            text: viewModel.draftText,
            routePreview: viewModel.draftRoutePreview,
            error: nil,
            isSubmitEnabled: true
        )

        XCTAssertTrue(presentation.isRouteRevealVisible)
        XCTAssertEqual(presentation.placementTitle, "Ready to Place")
        XCTAssertEqual(presentation.destinationLabel, "Task · Today")
        XCTAssertEqual(presentation.privacyLabel, "Private item")
        XCTAssertEqual(presentation.submitLabel, "Save capture")
        XCTAssertTrue(presentation.evidenceDetail.localizedCaseInsensitiveContains("after you confirm"))
        XCTAssertFalse(presentation.accessibilityValue.localizedCaseInsensitiveContains("chat"))
        XCTAssertFalse(presentation.accessibilityValue.localizedCaseInsensitiveContains("calendar event"))
        XCTAssertFalse(presentation.accessibilityValue.localizedCaseInsensitiveContains("AI"))
    }

    func testFCP21ComposerInputAlternativesKeepVoiceUnavailableAndMotorPathsHonest() async {
        let captureService = MutableCaptureService(captures: [])
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CaptureViewModel()

        await viewModel.load(captureService: captureService, goalsService: goalsService)
        viewModel.updateDraftText("Book dentist")

        let presentation = CaptureAtmosphereComposerPresentation(
            text: viewModel.draftText,
            routePreview: viewModel.draftRoutePreview,
            error: nil,
            isSubmitEnabled: true
        )
        let alternatives = presentation.inputAlternatives

        XCTAssertEqual(alternatives.title, "Input alternatives")
        XCTAssertEqual(alternatives.voiceStatusLabel, "Voice capture is not connected yet")
        XCTAssertTrue(alternatives.voiceStatusDetail.localizedCaseInsensitiveContains("system dictation"))
        XCTAssertTrue(alternatives.voiceStatusDetail.localizedCaseInsensitiveContains("does not record audio"))
        XCTAssertTrue(alternatives.motorStatusDetail.localizedCaseInsensitiveContains("buttons and menus"))
        XCTAssertTrue(alternatives.motorStatusDetail.localizedCaseInsensitiveContains("no drag, swipe, or long press"))
        XCTAssertTrue(alternatives.reviewControlLabel.localizedCaseInsensitiveContains("visible buttons"))
        XCTAssertTrue(presentation.accessibilityValue.localizedCaseInsensitiveContains("Input alternatives"))
        XCTAssertFalse(alternatives.accessibilityValue.localizedCaseInsensitiveContains("listening"))
        XCTAssertFalse(alternatives.accessibilityValue.localizedCaseInsensitiveContains("transcript"))
        XCTAssertFalse(alternatives.accessibilityValue.localizedCaseInsensitiveContains("automatically"))
        XCTAssertFalse(alternatives.accessibilityValue.localizedCaseInsensitiveContains("AI confidence"))
    }

    func testFCP21ComposerInputAlternativesKeepEmptyComposerFromImplyingAutoPlacement() {
        let presentation = CaptureAtmosphereComposerPresentation(
            text: "",
            routePreview: nil,
            error: nil,
            isSubmitEnabled: false
        )

        XCTAssertEqual(presentation.inputAlternatives.reviewControlLabel, "Review before saving: type first; placement waits for Save.")
        XCTAssertTrue(presentation.inputAlternatives.accessibilityValue.localizedCaseInsensitiveContains("Voice capture is not connected yet"))
        XCTAssertTrue(presentation.inputAlternatives.accessibilityValue.localizedCaseInsensitiveContains("placement waits for Save"))
        XCTAssertFalse(presentation.inputAlternatives.accessibilityValue.localizedCaseInsensitiveContains("automatically"))
        XCTAssertFalse(presentation.inputAlternatives.accessibilityValue.localizedCaseInsensitiveContains("hidden learning"))
        XCTAssertFalse(presentation.inputAlternatives.accessibilityValue.localizedCaseInsensitiveContains("confidence percentage"))
    }

    func testEB03BRouteProofUsesGoalEvidenceWhenAvailable() async {
        let captureService = MutableCaptureService(captures: [])
        let goalsService = StaticGoalsService(items: [
            goalItem(id: "goal-music", title: "Music Goal", renderState: .active)
        ])
        let viewModel = CaptureViewModel()

        await viewModel.load(captureService: captureService, goalsService: goalsService)
        viewModel.updateDraftText("Finished Music Goal proof")

        let preview = try! XCTUnwrap(viewModel.draftRoutePreview)
        XCTAssertEqual(preview.receiptTitle, "Saved as Proof · Music Goal")
        XCTAssertEqual(preview.routeProofTitle, "Goal attachment needs approval")
        XCTAssertTrue(preview.consequenceLabel.localizedCaseInsensitiveContains("Keeps proof local"))
        XCTAssertEqual(preview.routeProofDetail, "goal, music")
        XCTAssertTrue(preview.visibleCopy.localizedCaseInsensitiveContains("goal, music"))
        XCTAssertFalse(preview.visibleCopy.localizedCaseInsensitiveContains("AI confidence"))
    }

    func testD12QuickCapturePersistsSmartAttachmentReceiptAndRoute() async {
        let captureService = MutableCaptureService(captures: [])
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CaptureViewModel()

        await viewModel.load(captureService: captureService, goalsService: goalsService)
        viewModel.updateDraftText("Book dentist")
        await viewModel.createQuickCapture(captureService: captureService, goalsService: goalsService, now: fixedNow)

        let stored = await captureService.capture(id: "capture-created-0")
        XCTAssertEqual(stored?.kind, .oneTimeCommitment)
        XCTAssertEqual(stored?.route, .timeSeed)
        XCTAssertEqual(stored?.status, .scheduled)
        XCTAssertEqual(stored?.assumptionSummary, "Saved as a standalone Task because no existing local destination was reliable enough.")
        XCTAssertEqual(viewModel.actionMessage?.title, "Saved as Task · Today")
        XCTAssertNil(viewModel.draftRoutePreview)
    }

    func testD12CaptureScreenContractSnapshotSatisfiesImplementationGate() {
        let snapshot = CaptureViewState(
            captures: [],
            activeGoalOptions: []
        ).screenContractSnapshot()
        let contract = try! XCTUnwrap(ScreenContractRegistry.contract(for: .capture))
        let issues = ScreenContractValidator.validate(snapshot: snapshot, against: contract)

        XCTAssertTrue(issues.isEmpty, issues.map(\.message).joined(separator: "\n"))
        XCTAssertTrue(snapshot.copySamples.contains("Start here"))
        XCTAssertTrue(snapshot.copySamples.contains("Create goal"))
        XCTAssertTrue(snapshot.copySamples.contains("Shape time"))
        XCTAssertTrue(snapshot.copySamples.contains("Close with proof"))
        XCTAssertTrue(snapshot.copySamples.contains("Inspect what Ambitions knows"))
    }

    func testQuickCapturePreservesInputWhenCreateFails() async {
        let captureService = MutableCaptureService(captures: [], shouldThrow: true)
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CaptureViewModel()
        viewModel.draftText = "  Keep this thought  "

        await viewModel.createQuickCapture(captureService: captureService, goalsService: goalsService, now: fixedNow)

        XCTAssertEqual(viewModel.draftText, "  Keep this thought  ")
        XCTAssertEqual(viewModel.draftError, "Test capture failure")
    }

    func testAttachReturnsGoalRouteTarget() async {
        let captureService = MutableCaptureService(captures: [capture(id: "capture-attach", rawText: "Attach")])
        let goalsService = StaticGoalsService(items: [goalItem(id: "goal-active", title: "Active goal", renderState: .active)])
        let viewModel = CaptureViewModel()

        let target = await viewModel.attachToGoal(
            captureID: "capture-attach",
            goalID: "goal-active",
            goalTitle: "Active goal",
            captureService: captureService,
            goalsService: goalsService,
            now: fixedNow
        )

        let stored = await captureService.capture(id: "capture-attach")
        XCTAssertEqual(target?.goalID, "goal-active")
        XCTAssertEqual(stored?.status, .goalBound)
        XCTAssertEqual(stored?.linkedGoalID, "goal-active")
        XCTAssertEqual(viewModel.actionMessage?.title, "Attached as Proof · Active goal")
    }

    func testTurnIntoGoalReturnsCreatedGoalRouteTarget() async {
        let captureService = MutableCaptureService(captures: [capture(id: "capture-goal", rawText: "Turn into goal")])
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CaptureViewModel()

        let target = await viewModel.turnIntoGoal(
            captureID: "capture-goal",
            captureService: captureService,
            goalsService: goalsService,
            now: fixedNow
        )

        let stored = await captureService.capture(id: "capture-goal")
        XCTAssertEqual(target?.goalID, "goal-created-capture-goal")
        XCTAssertEqual(stored?.status, .goalBound)
        XCTAssertEqual(stored?.linkedGoalID, "goal-created-capture-goal")
        XCTAssertEqual(viewModel.actionMessage?.title, "Saved as Goal · Creative")
    }

    func testFailuresAreSurfacedWithoutChangingDomainRulesInViewModel() async {
        let captureService = MutableCaptureService(captures: [], shouldThrow: true)
        let goalsService = StaticGoalsService(items: [])
        let viewModel = CaptureViewModel()

        let target = await viewModel.turnIntoGoal(
            captureID: "missing",
            captureService: captureService,
            goalsService: goalsService,
            now: fixedNow
        )

        XCTAssertNil(target)
        XCTAssertEqual(viewModel.actionMessage?.title, "Save did not finish")
        XCTAssertTrue(viewModel.actionMessage?.body.contains("Test capture failure") == true)
    }

    private var fixedNow: Date {
        Date(timeIntervalSince1970: 1_712_692_800)
    }
}

private func capture(id: String, rawText: String, status: CaptureStatus = .actionable) -> Capture {
    Capture(
        id: id,
        createdAt: "2026-04-15T10:00:00Z",
        updatedAt: "2026-04-15T10:00:00Z",
        rawText: rawText,
        sourceType: .todayQuickCapture,
        status: status,
        linkedGoalID: nil
    )
}

private func goalItem(id: String, title: String, renderState: GoalRenderState) -> GoalListItem {
    GoalListItem(
        id: id,
        target: GoalRouteTarget(goalID: id, draftID: nil),
        title: title,
        subtitle: "Goal subtitle",
        mode: .project,
        renderState: renderState,
        progressValue: 0.1,
        progressLabel: "1/3 steps complete",
        statusLabel: renderState.title,
        timingLabel: "Flexible",
        nextStepHint: "Next step",
        modeLabel: GoalMode.project.displayTitle,
        supportLabel: nil,
        relevanceScore: 0.5,
        momentumScore: 0.5,
        urgencyScore: 0.5,
        manualPriorityRank: 1,
        updatedAt: "2026-04-15T10:00:00Z"
    )
}

private actor MutableCaptureService: CaptureServicing {
    private var captures: [String: Capture]
    private let shouldThrow: Bool

    init(captures: [Capture], shouldThrow: Bool = false) {
        self.captures = Dictionary(uniqueKeysWithValues: captures.map { ($0.id, $0) })
        self.shouldThrow = shouldThrow
    }

    func setCaptures(_ captures: [Capture]) {
        self.captures = Dictionary(uniqueKeysWithValues: captures.map { ($0.id, $0) })
    }

    func capture(id: String) -> Capture? {
        captures[id]
    }

    func createCapture(_ request: CreateCaptureRequest, now: Date) async throws -> Capture {
        if shouldThrow { throw TestCaptureError.failure }
        let timestamp = DomainTimestamp.string(from: now)
        let kind = request.kind ?? .raw
        let route = request.route ?? .captureInbox
        let capture = Capture(
            id: "capture-created-\(captures.count)",
            createdAt: timestamp,
            updatedAt: timestamp,
            rawText: request.rawText.trimmingCharacters(in: .whitespacesAndNewlines),
            sourceType: request.sourceType,
            status: route == .captureInbox && kind == .raw ? .needsTriage : status(for: route),
            linkedGoalID: request.linkedGoalID,
            triage: request.triage,
            revisitAfter: request.revisitAfter,
            kind: kind,
            route: route,
            triageStatus: request.triageStatus ?? .needsTriage,
            commitmentKind: request.commitmentKind,
            deadlineText: request.deadlineText,
            deadlineKind: request.deadlineKind,
            contextLensHint: request.contextLensHint,
            priorityHints: request.priorityHints,
            goalRelationship: request.goalRelationship,
            deliverableHint: request.deliverableHint,
            scopeItemHint: request.scopeItemHint,
            waitingMetadata: request.waitingMetadata,
            assumptionSummary: request.assumptionSummary,
            recommendationExplanationIDs: request.recommendationExplanationIDs
        )
        captures[capture.id] = capture
        return capture
    }

    func listCaptures() async throws -> [Capture] {
        captures.values.sorted { $0.updatedAt > $1.updatedAt }
    }

    func updateCaptureState(_ request: CaptureStateUpdateRequest, now: Date) async throws -> Capture? {
        if shouldThrow { throw TestCaptureError.failure }
        guard let existing = captures[request.id] else { return nil }
        let updated = Capture(
            id: existing.id,
            createdAt: existing.createdAt,
            updatedAt: DomainTimestamp.string(from: now),
            rawText: existing.rawText,
            sourceType: existing.sourceType,
            status: request.status,
            linkedGoalID: existing.linkedGoalID,
            triage: request.triage,
            revisitAfter: request.revisitAfter,
            kind: request.kind ?? existing.kind,
            route: request.route ?? existing.route,
            triageStatus: request.triageStatus ?? existing.triageStatus,
            commitmentKind: request.commitmentKind ?? existing.commitmentKind,
            deadlineText: request.deadlineText ?? existing.deadlineText,
            deadlineKind: request.deadlineKind ?? existing.deadlineKind,
            contextLensHint: request.contextLensHint ?? existing.contextLensHint,
            priorityHints: request.priorityHints ?? existing.priorityHints,
            goalRelationship: request.goalRelationship ?? existing.goalRelationship,
            deliverableHint: request.deliverableHint ?? existing.deliverableHint,
            scopeItemHint: request.scopeItemHint ?? existing.scopeItemHint,
            waitingMetadata: request.waitingMetadata ?? existing.waitingMetadata,
            assumptionSummary: request.assumptionSummary ?? existing.assumptionSummary,
            correctionActions: request.correctionActions ?? existing.correctionActions,
            recommendationExplanationIDs: request.recommendationExplanationIDs ?? existing.recommendationExplanationIDs
        )
        captures[request.id] = updated
        return updated
    }

    func updateCaptureRoute(_ request: CaptureRouteUpdateRequest, now: Date) async throws -> Capture? {
        if shouldThrow { throw TestCaptureError.failure }
        guard let existing = captures[request.id] else { return nil }
        let updated = Capture(
            id: existing.id,
            createdAt: existing.createdAt,
            updatedAt: DomainTimestamp.string(from: now),
            rawText: existing.rawText,
            sourceType: existing.sourceType,
            status: status(for: request.route),
            linkedGoalID: request.goalRelationship?.goalID ?? existing.linkedGoalID,
            triage: CaptureTriageMetadata(destination: request.route.triageDestination, hint: request.assumptionSummary),
            revisitAfter: existing.revisitAfter,
            kind: request.kind,
            route: request.route,
            triageStatus: request.userCorrection ? .userCorrected : .assumedRoute,
            commitmentKind: commitmentKind(for: request.kind),
            deadlineText: request.deadlineText ?? existing.deadlineText,
            deadlineKind: request.deadlineText == nil ? existing.deadlineKind : .hard,
            contextLensHint: request.contextLensHint ?? existing.contextLensHint,
            priorityHints: request.priorityHints ?? existing.priorityHints,
            goalRelationship: request.goalRelationship ?? existing.goalRelationship,
            deliverableHint: request.deliverableHint ?? existing.deliverableHint,
            scopeItemHint: request.scopeItemHint ?? existing.scopeItemHint,
            waitingMetadata: request.waitingMetadata ?? existing.waitingMetadata,
            assumptionSummary: request.assumptionSummary ?? existing.assumptionSummary,
            correctionActions: existing.correctionActions,
            recommendationExplanationIDs: existing.recommendationExplanationIDs
        )
        captures[request.id] = updated
        return updated
    }

    func markAsOneTimeCommitment(id: String, deadlineText: String?, contextLensHint: NowContextLens?, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .oneTimeCommitment, route: .timeSeed, deadlineText: deadlineText, contextLensHint: contextLensHint), now: now)
    }

    func markAsDeadlineTask(id: String, deadlineText: String, contextLensHint: NowContextLens?, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .deadlineTask, route: .timeSeed, deadlineText: deadlineText, contextLensHint: contextLensHint), now: now)
    }

    func markAsGoalSeed(id: String, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .goalSeed, route: .goalSeed), now: now)
    }

    func markAsGoalSupportingTask(id: String, goalID: String?, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .goalSupportingTask, route: .goalAttachment, goalRelationship: CaptureGoalRelationship(goalID: goalID, relationshipKind: .nextAction)), now: now)
    }

    func markAsDeliverableSeed(id: String, deliverableHint: String?, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .deliverableSeed, route: .deliverableSeed, deliverableHint: deliverableHint), now: now)
    }

    func markAsWaiting(id: String, waitingMetadata: CaptureWaitingMetadata?, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .waitingItem, route: .waiting, waitingMetadata: waitingMetadata), now: now)
    }

    func markAsOptionalSomeday(id: String, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .optionalSomeday, route: .optionalSomeday, priorityHints: CapturePriorityHints(optionalSomeday: true, passive: true)), now: now)
    }

    func routeToTimeSeed(id: String, now: Date) async throws -> Capture? {
        try await updateCaptureRoute(CaptureRouteUpdateRequest(id: id, kind: .oneTimeCommitment, route: .timeSeed), now: now)
    }

    func attachCaptureToGoal(_ request: AttachCaptureToGoalRequest, now: Date) async throws -> CaptureGoalBinding? {
        guard let updated = try await updateLinkedCapture(id: request.captureID, goalID: request.goalID, now: now) else {
            return nil
        }
        return CaptureGoalBinding(capture: updated, target: GoalRouteTarget(goalID: request.goalID, draftID: nil))
    }

    func turnCaptureIntoGoal(_ request: TurnCaptureIntoGoalRequest, now: Date) async throws -> CaptureGoalBinding? {
        if shouldThrow { throw TestCaptureError.failure }
        let goalID = "goal-created-\(request.captureID)"
        guard let updated = try await updateLinkedCapture(id: request.captureID, goalID: goalID, now: now) else {
            return nil
        }
        return CaptureGoalBinding(capture: updated, target: GoalRouteTarget(goalID: goalID, draftID: "draft-created-\(request.captureID)"))
    }

    func markCaptureProcessed(id: String, now: Date) async throws -> Capture? {
        try await updateCaptureState(CaptureStateUpdateRequest(id: id, status: .goalBound), now: now)
    }

    func markCaptureArchived(id: String, now: Date) async throws -> Capture? {
        try await updateCaptureState(CaptureStateUpdateRequest(id: id, status: .archived), now: now)
    }

    private func updateLinkedCapture(id: String, goalID: String, now: Date) async throws -> Capture? {
        guard let existing = captures[id] else { return nil }
        let updated = Capture(
            id: existing.id,
            createdAt: existing.createdAt,
            updatedAt: DomainTimestamp.string(from: now),
            rawText: existing.rawText,
            sourceType: existing.sourceType,
            status: .goalBound,
            linkedGoalID: goalID,
            triage: existing.triage,
            revisitAfter: existing.revisitAfter,
            kind: .goalSupportingTask,
            route: .goalAttachment,
            triageStatus: .routed,
            commitmentKind: .goalSupporting,
            deadlineText: existing.deadlineText,
            deadlineKind: existing.deadlineKind,
            contextLensHint: existing.contextLensHint,
            priorityHints: CapturePriorityHints(goalSupporting: true),
            goalRelationship: CaptureGoalRelationship(goalID: goalID, relationshipKind: .nextAction),
            deliverableHint: existing.deliverableHint,
            scopeItemHint: existing.scopeItemHint,
            waitingMetadata: existing.waitingMetadata,
            assumptionSummary: existing.assumptionSummary,
            correctionActions: existing.correctionActions,
            recommendationExplanationIDs: existing.recommendationExplanationIDs
        )
        captures[id] = updated
        return updated
    }

    private func status(for route: CaptureRoute) -> CaptureStatus {
        switch route {
        case .captureInbox:
            .actionable
        case .timeSeed:
            .scheduled
        case .goalSeed, .deliverableSeed, .proofItem, .constraintItem:
            .seed
        case .goalAttachment:
            .goalBound
        case .waiting:
            .waiting
        case .optionalSomeday:
            .optionalSomeday
        case .archive:
            .archived
        }
    }

    private func commitmentKind(for kind: CaptureKind) -> NowCommitmentKind? {
        switch kind {
        case .oneTimeCommitment, .deadlineTask:
            .oneTime
        case .goalSupportingTask:
            .goalSupporting
        case .waitingItem:
            .waiting
        case .optionalSomeday:
            .optionalSomeday
        case .raw, .goalSeed, .deliverableSeed, .archiveItem:
            nil
        }
    }
}

private actor StaticGoalsService: GoalsServicing {
    let items: [GoalListItem]

    init(items: [GoalListItem]) {
        self.items = items
    }

    func loadOverview() async throws -> GoalsOverview {
        GoalsOverview(
            hero: GoalsBoardHeroState(
                eyebrow: "Direction Board",
                title: "Goals",
                subtitle: "Test goals",
                dominantTruth: "Test goals",
                pressureSummary: "Test goals",
                contextPills: [],
                attentionPills: []
            ),
            heroPrimaryAction: GoalsBoardPrimaryAction(
                kind: .createGoal,
                title: "Create goal",
                subtitle: "Create goal",
                systemImage: "plus.circle",
                target: nil,
                state: .selected
            ),
            bands: [],
            horizonLadder: GoalsHorizonLadderState(title: "Horizon ladder", subtitle: "Test goals", rungs: []),
            weekPressureSummary: GoalsWeekPressureSummary(
                title: "Calm",
                subtitle: "Calm",
                leadingMetric: "0 active",
                trailingMetric: "0 stretching thin",
                pill: GoalsHeroPillState(title: "Calm", icon: "leaf", state: .success)
            ),
            lowerPriority: GoalsLowerPriorityState(title: "Lower priority", subtitle: "Test goals", disclosureTitle: "Show quieter goals", cards: []),
            lifecycleRail: [
                GoalLifecycleRailSegment(id: "previous", title: "Previous", count: 0, subtitle: "None", state: .default),
                GoalLifecycleRailSegment(id: "active", title: "Active", count: items.count, subtitle: "Test goals", state: .selected),
                GoalLifecycleRailSegment(id: "future", title: "Future", count: 0, subtitle: "None", state: .default),
            ],
            stateChips: [],
            atlasPreview: nil,
            archiveSummary: GoalPortfolioArchiveSummary(title: "Archive is quiet", subtitle: "No archive test goals", chips: [], learningLines: []),
            maturitySummary: .empty,
            items: items,
            isSeeded: false,
            emptyTitle: "No goals",
            emptyMessage: "No goals"
        )
    }

    func loadDetail(target: GoalRouteTarget) async throws -> GoalDetailPresentation {
        _ = target
        fatalError("Not needed for CaptureViewModelTests")
    }

    func createGoal(_ request: CreateGoalRequest, now: Date) async throws -> CreateGoalResponse {
        _ = request
        _ = now
        fatalError("Not needed for CaptureViewModelTests")
    }

    func performAction(_ request: GoalDetailActionRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        fatalError("Not needed for CaptureViewModelTests")
    }

    func submitClarificationAnswer(_ request: GoalClarificationAnswerRequest, now: Date) async throws -> GoalDetailActionResponse {
        _ = request
        _ = now
        fatalError("Not needed for CaptureViewModelTests")
    }
}

private enum TestCaptureError: LocalizedError {
    case failure

    var errorDescription: String? {
        "Test capture failure"
    }
}
