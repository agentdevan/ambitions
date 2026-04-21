import XCTest
@testable import Ambitions

final class AppIntentRoutingTests: XCTestCase {
    func testShortcutDestinationsStayBoundedToCanonicalNavigationRoutes() {
        XCTAssertEqual(Set(AmbitionsAppShortcutDestination.allCases), [.today, .plan, .capturesInbox])
    }

    func testShortcutDestinationsUseCanonicalRouteURLs() {
        XCTAssertEqual(AmbitionsAppShortcutDestination.today.routeURL?.absoluteString, "ambitions://tab/today")
        XCTAssertEqual(AmbitionsAppShortcutDestination.plan.routeURL?.absoluteString, "ambitions://tab/plan")
        XCTAssertEqual(AmbitionsAppShortcutDestination.capturesInbox.routeURL?.absoluteString, "ambitions://captures/inbox")
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
