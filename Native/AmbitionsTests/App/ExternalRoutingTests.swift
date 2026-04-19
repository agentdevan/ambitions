import XCTest
@testable import Ambitions

final class ExternalRoutingTests: XCTestCase {
    func testDeepLinkTranslatorParsesTabRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://tab/goals"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openTab(.goals))
    }

    func testDeepLinkTranslatorParsesGoalRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://goal/goal-123"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openGoalDetail(goalID: "goal-123"))
    }

    func testDeepLinkTranslatorParsesCapturesInboxRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://captures/inbox"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openCapturesInbox)
    }

    func testDeepLinkTranslatorFallsBackToGenericExternalEntry() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://future-entry/new-surface?foo=bar"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(
            route,
            .genericExternalEntry(
                kind: "deeplink.future-entry",
                payload: ["foo": "bar", "host": "future-entry", "path": "new-surface"]
            )
        )
    }

    func testNotificationTranslatorRoutesGoalPayloadToGoalDetail() {
        let translator = AppExternalRouteTranslator()

        let route = translator.route(
            fromNotification: AppNotificationRoutingPayload(
                action: "complete",
                values: ["goalID": "goal-123", "stepID": "step-1"]
            )
        )

        XCTAssertEqual(route, .openGoalDetail(goalID: "goal-123"))
    }

    func testNotificationTranslatorRoutesCapturesInboxPayload() {
        let translator = AppExternalRouteTranslator()

        let route = translator.route(
            fromNotification: AppNotificationRoutingPayload(
                action: "open-captures-inbox",
                values: [:]
            )
        )

        XCTAssertEqual(route, .openCapturesInbox)
    }

    func testWidgetTranslatorRoutesCapturesInboxPayload() {
        let translator = AppExternalRouteTranslator()

        let route = translator.route(
            fromWidget: AppWidgetRoutingPayload(
                action: "noop",
                values: ["surface": "captures-inbox"]
            )
        )

        XCTAssertEqual(route, .openCapturesInbox)
    }

    @MainActor
    func testRouterDispatchesGoalDetailToExistingNavigationModel() {
        let navigation = AppNavigationModel(selectedTab: .today)
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.openGoalDetail(goalID: "goal-789"), source: .deepLink)

        XCTAssertEqual(navigation.selectedTab, .goals)
        XCTAssertEqual(navigation.goalsPath.count, 1)
        XCTAssertEqual(navigation.goalsPath.first?.goalID, "goal-789")
        XCTAssertEqual(navigation.lastExternalRoute, .openGoalDetail(goalID: "goal-789"))
        XCTAssertEqual(navigation.lastExternalRouteSource, .deepLink)
    }

    @MainActor
    func testRouterDispatchesCapturesInboxToCapturesTab() {
        let navigation = AppNavigationModel(selectedTab: .insights)
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.openCapturesInbox, source: .widgetAction)

        XCTAssertEqual(navigation.selectedTab, .captures)
        XCTAssertEqual(navigation.lastExternalRoute, .openCapturesInbox)
        XCTAssertEqual(navigation.lastExternalRouteSource, .widgetAction)
    }
}
