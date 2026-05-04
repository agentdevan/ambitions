import XCTest
@testable import Ambitions

@MainActor
final class ShellCommandRouterTests: XCTestCase {
    func testQuickCaptureCreatesCaptureAndRoutesToTopLevelCapture() async throws {
        let navigation = AppNavigationModel(selectedTab: .today)
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
        XCTAssertEqual(captures.map(\.rawText), ["Capture this idea"])
        XCTAssertEqual(captures.first?.route, .captureInbox)
        XCTAssertEqual(captures.first?.assumptionSummary, "Saved as an Idea so it stays findable without becoming scheduled work.")
        XCTAssertEqual(navigation.selectedTab, .captures)
        XCTAssertTrue(navigation.planPath.isEmpty)
        XCTAssertEqual(result.title, "Saved as Idea")
        XCTAssertEqual(result.destination, .planRoute(.captureInbox))
        XCTAssertEqual(navigation.recentCommandHistory.first?.title, "Saved as Idea")
    }

    func testOpenGoalWithoutIdentifierFallsBackToMemoryLensOverlay() async {
        let navigation = AppNavigationModel(selectedTab: .today)
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
        let navigation = AppNavigationModel(selectedTab: .plan)
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: StubCaptureService(captures: []))

        router.route(to: .goal("goal-123"), source: .shellCompose)

        XCTAssertEqual(navigation.selectedTab, .goals)
        XCTAssertEqual(navigation.goalsPath.first?.goalID, "goal-123")
        XCTAssertEqual(navigation.recentCommandHistory.first?.destinationLabel, "Goal Detail")
    }

    func testExternalSourceRouteCreatesCalmContinuityReceipt() {
        let navigation = AppNavigationModel(selectedTab: .today)
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: StubCaptureService(captures: []))

        router.route(to: .goal("goal-123"), source: .widget)

        XCTAssertEqual(navigation.continuityReceipt?.source, .widget)
        XCTAssertEqual(navigation.continuityReceipt?.destinationLabel, "Goal Detail")
        XCTAssertTrue(navigation.continuityReceipt?.body.contains("source context preserved") == true)
    }

    func testQuickFocusCommandPreservesFocusContextCompatibility() async {
        let navigation = AppNavigationModel(selectedTab: .plan)
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
    }

    func testPresentCreateGoalCarriesSeedTextAndCaptureContext() {
        let navigation = AppNavigationModel(selectedTab: .plan)
        let router = DefaultShellCommandRouter(navigation: navigation, captureService: StubCaptureService(captures: []))

        router.presentCreateGoal(
            source: .capturesScreen,
            seedText: "Turn this capture into a believable goal",
            captureID: "capture-123"
        )

        XCTAssertEqual(navigation.activeOverlay?.kind, .createGoal)
        XCTAssertEqual(navigation.activeOverlay?.entrySource, .capturesScreen)
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
        XCTAssertEqual(quickCapture.destination, .planRoute(.captureInbox))
        XCTAssertTrue(quickCapture.touchesUserText)
        XCTAssertTrue(quickCapture.safetySummary.contains("local capture"))

        let memoryLens = ShellCommandIntent.memoryLens.externalBrainCommandContract
        XCTAssertNil(memoryLens.commandKind)
        XCTAssertEqual(memoryLens.sourceOfTruth, "Life Memory")
        XCTAssertTrue(memoryLens.safetySummary.contains("source-grounded"))

        let plan = ShellCommandIntent.quickPlanPatch.externalBrainCommandContract
        XCTAssertEqual(plan.commandKind, .openDestination)
        XCTAssertEqual(plan.destination, .tab(.plan))
        XCTAssertTrue(plan.safetySummary.contains("without writing calendar"))
    }
}
