import XCTest
@testable import Ambitions

final class AppIntentRoutingTests: XCTestCase {
    func testShortcutDestinationsStayBoundedToCanonicalNavigationRoutes() {
        XCTAssertEqual(Set(AmbitionsAppShortcutDestination.allCases), [.today, .plan, .capturesInbox, .command, .memoryLens, .quickCapture, .quickRecovery, .quickFocus, .quickPlanPatch])
    }

    func testShortcutDestinationsUseCanonicalRouteURLs() {
        XCTAssertEqual(AmbitionsAppShortcutDestination.today.routeURL?.absoluteString, "ambitions://tab/today?origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.plan.routeURL?.absoluteString, "ambitions://tab/plan?origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.capturesInbox.routeURL?.absoluteString, "ambitions://captures/inbox?origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.command.routeURL?.absoluteString, "ambitions://overlay/quiet-command-sheet?origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.memoryLens.routeURL?.absoluteString, "ambitions://overlay/memory-lens?intent=memory_lens&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.quickCapture.routeURL?.absoluteString, "ambitions://overlay/quiet-command-sheet?intent=quick_capture&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.quickRecovery.routeURL?.absoluteString, "ambitions://tab/today?context=recovery&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.quickFocus.routeURL?.absoluteString, "ambitions://tab/today?context=focus&origin=app_intent")
        XCTAssertEqual(AmbitionsAppShortcutDestination.quickPlanPatch.routeURL?.absoluteString, "ambitions://tab/plan?origin=app_intent")
    }

    @MainActor
    func testIntentLaunchRouterQueuesAndConsumesOnePendingURL() throws {
        let router = AppIntentLaunchRouter.shared
        let url = try XCTUnwrap(URL(string: "ambitions://tab/plan"))

        router.queue(url)

        XCTAssertEqual(router.consumePendingURL(), url)
        XCTAssertNil(router.consumePendingURL())
    }
}
