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
        XCTAssertEqual(navigation.selectedTab, .captures)
        XCTAssertTrue(navigation.planPath.isEmpty)
        XCTAssertEqual(result.destination, .planRoute(.capturesInbox))
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
}
