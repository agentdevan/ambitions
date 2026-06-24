import XCTest
@testable import Ambitions

@MainActor
final class ShellCommandRouterTests: XCTestCase {
    func testQuickCaptureCreatesCaptureAndRoutesToGlobalCaptureOverlay() async throws {
        let navigation = StageStore(selectedSurface: .today)
        let repository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: repository, idProvider: { "capture-shell" })
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: captureService)

        let result = await router.execute(
            intent: .quickCapture,
            text: "Capture this idea",
            goalID: nil,
            captureID: nil,
            source: .shellCompose,
            now: Date(timeIntervalSince1970: 1_712_692_800)
        )

        let captures = try await repository.listCaptures()
        let expectedDestination = ShellCommandDestination.overlay(
            .commandSheet(
                intent: .quickCapture,
                entrySource: .shellCompose,
                presentationContext: .quickCapture
            )
        )

        XCTAssertEqual(captures.map(\.rawText), ["Capture this idea"])
        XCTAssertEqual(captures.first?.route, .captureInbox)
        XCTAssertEqual(captures.first?.assumptionSummary, "Saved as an Idea so it stays findable without becoming scheduled work.")
        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertEqual(navigation.activeOverlay?.kind, .quietCommandSheet)
        XCTAssertEqual(navigation.activeOverlay?.intent, .quickCapture)
        XCTAssertEqual(navigation.activeOverlay?.presentationContext, .quickCapture)
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertEqual(result.title, "Saved as Idea")
        XCTAssertEqual(result.destination, expectedDestination)
        XCTAssertEqual(result.pipelineTrace?.taxonomy, .productRuntime)
        XCTAssertEqual(result.pipelineTrace?.commandKind, .quickCapture)
        XCTAssertEqual(result.pipelineTrace?.commandValidation.state, .satisfied)
        XCTAssertEqual(result.pipelineTrace?.runtimeMutation.state, .satisfied)
        XCTAssertEqual(result.pipelineTrace?.visibleMutation.state, .satisfied)
        XCTAssertEqual(result.pipelineTrace?.proofReceipt.state, .unavailable)
        XCTAssertEqual(result.pipelineTrace?.accessibilityAnnouncement.state, .satisfied)
        XCTAssertEqual(result.pipelineTrace?.fallbackUndo.state, .satisfied)
        XCTAssertEqual(result.pipelineTrace?.shellRouteChange.state, .notApplicable)
        XCTAssertEqual(result.pipelineTrace?.scopedFlowIDs, ["SCG006-F03"])
        XCTAssertTrue(result.pipelineTrace?.knownIssueIDs.contains("AMB-ISSUE-0003") == true)
        XCTAssertEqual(navigation.recentCommandHistory.first?.title, "Saved as Idea")
        XCTAssertEqual(navigation.recentCommandHistory.first?.destinationLabel, "Capture")
    }

    func testQuickCaptureWithoutTextIsBlockedByProductRuntimePipeline() async throws {
        let navigation = StageStore(selectedSurface: .today)
        let repository = PreviewCaptureRepository()
        let captureService = DefaultCaptureService(repository: repository, idProvider: { "capture-shell" })
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: captureService)

        let result = await router.execute(
            intent: .quickCapture,
            text: "   ",
            goalID: nil,
            captureID: nil,
            source: .shellCompose,
            now: Date(timeIntervalSince1970: 1_712_692_800)
        )

        let captures = try await repository.listCaptures()
        XCTAssertEqual(result.title, "Capture needs text")
        XCTAssertTrue(captures.isEmpty)
        XCTAssertNil(result.destination)
        XCTAssertEqual(result.pipelineTrace?.taxonomy, .productRuntime)
        XCTAssertEqual(result.pipelineTrace?.commandValidation.state, .blocked)
        XCTAssertEqual(result.pipelineTrace?.runtimeMutation.state, .blocked)
        XCTAssertEqual(result.pipelineTrace?.visibleMutation.state, .blocked)
        XCTAssertEqual(result.pipelineTrace?.proofReceipt.state, .unavailable)
        XCTAssertEqual(result.pipelineTrace?.fallbackUndo.state, .satisfied)
    }

    func testRouteToGlobalCaptureComposerUsesGlobalCaptureOverlay() {
        let navigation = StageStore(selectedSurface: .time)
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: StubCaptureService(captures: []))

        router.route(
            to: .overlay(.commandSheet(intent: .quickCapture, entrySource: .deepLink, presentationContext: .quickCapture)),
            source: .deepLink
        )

        XCTAssertEqual(navigation.selectedTab, .time)
        XCTAssertEqual(navigation.activeOverlay?.kind, .quietCommandSheet)
        XCTAssertEqual(navigation.activeOverlay?.intent, .quickCapture)
        XCTAssertEqual(navigation.activeOverlay?.entrySource, .deepLink)
        XCTAssertEqual(navigation.recentCommandHistory.first?.destinationLabel, "Capture")
    }

    func testRouteToGlobalCaptureComposerLeavesRootSurfaceInPlace() {
        let navigation = StageStore(selectedSurface: .goals)
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: StubCaptureService(captures: []))

        router.route(
            to: .overlay(.commandSheet(intent: .quickCapture, entrySource: .shellUtility, presentationContext: .quickCapture)),
            source: .shellUtility
        )

        XCTAssertEqual(navigation.selectedTab, .goals)
        XCTAssertEqual(navigation.activeOverlay?.kind, .quietCommandSheet)
        XCTAssertEqual(navigation.activeOverlay?.intent, .quickCapture)
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertEqual(navigation.recentCommandHistory.first?.destinationLabel, "Capture")
    }

    func testOpenCaptureCommandUsesGlobalCaptureOverlayDestination() async {
        let navigation = StageStore(selectedSurface: .you)
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: StubCaptureService(captures: []))

        let result = await router.execute(
            intent: .openCapture,
            text: "",
            goalID: nil,
            captureID: nil,
            source: .appIntent,
            now: .now
        )

        let expectedDestination = ShellCommandDestination.overlay(
            .commandSheet(
                intent: .quickCapture,
                entrySource: .appIntent,
                presentationContext: .quickCapture
            )
        )
        XCTAssertEqual(navigation.selectedTab, .you)
        XCTAssertEqual(navigation.activeOverlay?.kind, .quietCommandSheet)
        XCTAssertEqual(navigation.activeOverlay?.intent, .quickCapture)
        XCTAssertEqual(navigation.activeOverlay?.entrySource, .appIntent)
        XCTAssertEqual(result.destination, expectedDestination)
        XCTAssertEqual(result.pipelineTrace?.taxonomy, .shellNavigationOverlay)
        XCTAssertTrue(result.pipelineTrace?.isHonestShellNonRuntime == true)
        XCTAssertEqual(result.pipelineTrace?.shellRouteChange.state, .satisfied)
        XCTAssertEqual(result.pipelineTrace?.runtimeMutation.state, .notApplicable)
        XCTAssertEqual(result.pipelineTrace?.proofReceipt.state, .notApplicable)
        XCTAssertEqual(navigation.recentCommandHistory.first?.destinationLabel, "Capture")
    }

    func testOpenGoalWithoutIdentifierFallsBackToMemoryLensOverlay() async {
        let navigation = StageStore(selectedSurface: .today)
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: StubCaptureService(captures: []))

        let result = await router.execute(
            intent: .openGoal,
            text: "",
            goalID: nil,
            captureID: nil,
            source: .shellCompose,
            now: .now
        )

        XCTAssertEqual(navigation.activeOverlay?.kind, .memoryLens)
        XCTAssertEqual(navigation.activeOverlay?.intent, .openGoal)
        XCTAssertEqual(result.destination, .overlay(.memoryLens(intent: .openGoal, entrySource: .shellCompose)))
    }

    func testRouteToGoalUsesCanonicalGoalsDestination() {
        let navigation = StageStore(selectedSurface: .time)
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: StubCaptureService(captures: []))

        router.route(to: .goal("goal-123"), source: .shellCompose)

        XCTAssertEqual(navigation.selectedTab, .goals)
        XCTAssertEqual(navigation.goalsPath.first?.goalID, "goal-123")
        XCTAssertEqual(navigation.recentCommandHistory.first?.destinationLabel, "Goal Detail")
    }

    func testExternalSourceRouteCreatesCalmContinuityReceipt() {
        let navigation = StageStore(selectedSurface: .today)
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: StubCaptureService(captures: []))

        router.route(to: .goal("goal-123"), source: .widget)

        XCTAssertEqual(navigation.continuityReceipt?.source, .widget)
        XCTAssertEqual(navigation.continuityReceipt?.destinationLabel, "Goal Detail")
        XCTAssertTrue(navigation.continuityReceipt?.body.contains("source context preserved") == true)
    }

    func testQuickFocusCommandPreservesExplicitFocusContext() async {
        let navigation = StageStore(selectedSurface: .time)
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: StubCaptureService(captures: []))

        let result = await router.execute(
            intent: .quickFocus,
            text: "",
            goalID: nil,
            captureID: nil,
            source: .appIntent,
            now: .now
        )

        XCTAssertEqual(ShellCommandIntent.quickFocus.rawValue, "quick_focus")
        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertEqual(navigation.todayEntryContext, .focus)
        XCTAssertEqual(navigation.recentCommandHistory.first?.presentationContext, .focus)
        XCTAssertEqual(result.destination, ShellCommandDestination.tab(.today))
        XCTAssertEqual(result.pipelineTrace?.taxonomy, .shellNavigationOverlay)
        XCTAssertTrue(result.pipelineTrace?.isHonestShellNonRuntime == true)
        XCTAssertEqual(result.pipelineTrace?.runtimeMutation.state, .notApplicable)
        XCTAssertEqual(result.pipelineTrace?.visibleMutation.state, .notApplicable)
    }

    func testPresentCreateGoalCarriesSeedTextAndCaptureContext() {
        let navigation = StageStore(selectedSurface: .time)
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: StubCaptureService(captures: []))

        router.presentCreateGoal(
            source: .globalCaptureComposer,
            seedText: "Turn this capture into a believable goal",
            captureID: "capture-123"
        )

        XCTAssertEqual(navigation.activeOverlay?.kind, .createGoal)
        XCTAssertEqual(navigation.activeOverlay?.entrySource, .globalCaptureComposer)
        XCTAssertEqual(navigation.activeOverlay?.query, "Turn this capture into a believable goal")
        XCTAssertEqual(navigation.activeOverlay?.captureID, "capture-123")
    }

    func testEB34ExternalBrainCommandContractsAreSafeAndSourceGrounded() {
        let contracts = ShellCommandIntent.allCases.map(\.externalBrainCommandContract)

        XCTAssertTrue(contracts.allSatisfy(\.isSafeForExternalBrainCommandSurface))
        XCTAssertTrue(contracts.allSatisfy { !$0.sourceOfTruth.isEmpty })
        XCTAssertTrue(contracts.allSatisfy { !$0.safetySummary.isEmpty })
        XCTAssertTrue(contracts.allSatisfy { !$0.fallbackSummary.isEmpty })
        XCTAssertTrue(contracts.allSatisfy { !$0.writesCalendar })
        XCTAssertTrue(contracts.allSatisfy { !$0.createsDurableMemory })

        let quickCapture = ShellCommandIntent.quickCapture.externalBrainCommandContract
        XCTAssertEqual(quickCapture.commandKind, .quickCapture)
        XCTAssertEqual(
            quickCapture.destination,
            .overlay(.commandSheet(intent: .quickCapture, entrySource: .shellCompose, presentationContext: .quickCapture))
        )
        XCTAssertTrue(quickCapture.touchesUserText)
        XCTAssertTrue(quickCapture.safetySummary.contains("local capture"))

        let memoryLens = ShellCommandIntent.memoryLens.externalBrainCommandContract
        XCTAssertNil(memoryLens.commandKind)
        XCTAssertEqual(memoryLens.sourceOfTruth, "Personal context")
        XCTAssertTrue(memoryLens.safetySummary.contains("source-grounded"))

        let timePatch = ShellCommandIntent.quickTimePatch.externalBrainCommandContract
        XCTAssertEqual(timePatch.commandKind, .openDestination)
        XCTAssertEqual(timePatch.destination, .tab(.time))
        XCTAssertTrue(timePatch.safetySummary.contains("without writing calendar"))
    }

    func testAMB1059RoutesMemoryLensGoalResultWithTrustedHandoffContext() {
        let navigation = StageStore(selectedSurface: .today)
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: StubCaptureService(captures: []))
        let result = MemoryLensResult(
            id: "goal-release",
            title: "Release the single",
            subtitle: "Current plan",
            explanation: "Open canonical goal detail.",
            queryText: "release single",
            timestamp: "2026-04-22T10:00:00Z",
            kind: .goal,
            facet: .open,
            actionTitle: "Open goal",
            destination: .goal("goal-release")
        )

        let handoff = router.route(searchResult: result, source: .shellUtility)

        XCTAssertTrue(handoff.isTrusted)
        XCTAssertEqual(handoff.owner, .goals)
        XCTAssertEqual(navigation.selectedTab, .goals)
        XCTAssertEqual(navigation.goalsPath.first?.goalID, "goal-release")
        XCTAssertEqual(navigation.continuityReceipt?.title, "Search opened")
        XCTAssertEqual(navigation.continuityReceipt?.destinationLabel, "Goal Detail")
        XCTAssertTrue(navigation.continuityReceipt?.body.contains("Search") == true)
        XCTAssertTrue(navigation.continuityReceipt?.body.contains("Goals") == true)
    }

    func testAMB1196RoutesSearchCaptureResultToCaptureOverlayNotCaptureTab() {
        let navigation = StageStore(selectedSurface: .today)
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: StubCaptureService(captures: []))
        let result = MemoryLensResult(
            id: "capture-unplaced",
            title: "Book the rehearsal room",
            subtitle: "Needs a Place",
            explanation: "Open Capture.",
            queryText: "book rehearsal room",
            timestamp: "2026-04-22T10:00:00Z",
            kind: .capture,
            facet: .open,
            actionTitle: "Open Capture",
            destination: .overlay(.commandSheet(intent: .quickCapture, entrySource: .shellUtility, presentationContext: .quickCapture))
        )

        let handoff = router.route(searchResult: result, source: .shellUtility)

        XCTAssertTrue(handoff.isTrusted)
        XCTAssertEqual(handoff.owner, .capture)
        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertEqual(navigation.activeOverlay?.kind, .quietCommandSheet)
        XCTAssertEqual(navigation.activeOverlay?.intent, .quickCapture)
        XCTAssertEqual(navigation.activeOverlay?.entrySource, .shellUtility)
        XCTAssertEqual(navigation.continuityReceipt?.destinationLabel, "Capture")
        XCTAssertTrue(navigation.continuityReceipt?.body.contains("Capture") == true)
        XCTAssertFalse(navigation.continuityReceipt?.body.contains("Global Capture") == true)
        XCTAssertFalse(AmbitionsSurface.allCases.map(\.rawValue).contains("capture"))
    }
}
