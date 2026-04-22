import XCTest
@testable import Ambitions

final class AppIntentRoutingTests: XCTestCase {
    func testShortcutDestinationsStayBoundedToCanonicalNavigationRoutes() {
        XCTAssertEqual(Set(AmbitionsAppShortcutDestination.allCases), [.today, .plan, .capturesInbox, .command, .memoryLens, .quickCapture])
    }

    func testShortcutDestinationsUseCanonicalRouteURLs() {
        XCTAssertEqual(AmbitionsAppShortcutDestination.today.routeURL?.absoluteString, "ambitions://tab/today")
        XCTAssertEqual(AmbitionsAppShortcutDestination.plan.routeURL?.absoluteString, "ambitions://tab/plan")
        XCTAssertEqual(AmbitionsAppShortcutDestination.capturesInbox.routeURL?.absoluteString, "ambitions://captures/inbox")
        XCTAssertEqual(AmbitionsAppShortcutDestination.command.routeURL?.absoluteString, "ambitions://overlay/quiet-command-sheet")
        XCTAssertEqual(AmbitionsAppShortcutDestination.memoryLens.routeURL?.absoluteString, "ambitions://overlay/memory-lens?intent=memory_lens")
        XCTAssertEqual(AmbitionsAppShortcutDestination.quickCapture.routeURL?.absoluteString, "ambitions://overlay/quiet-command-sheet?intent=quick_capture")
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
