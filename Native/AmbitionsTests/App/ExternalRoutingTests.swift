import XCTest
@testable import Ambitions

final class ExternalRoutingTests: XCTestCase {
    func testDeepLinkTranslatorParsesTabRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://tab/goals"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openTab(.goals))
    }

    func testDeepLinkTranslatorParsesCanonicalPlanTabRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://tab/plan"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openTab(.plan))
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

    func testLegacyTabPayloadsStillParseForCompatibility() {
        let translator = AppExternalRouteTranslator()

        XCTAssertEqual(
            translator.route(fromNotification: AppNotificationRoutingPayload(action: "open", values: ["tab": "captures"])),
            .openTab(.captures)
        )
        XCTAssertEqual(
            translator.route(fromWidget: AppWidgetRoutingPayload(action: "open", values: ["tab": "habits"])),
            .openTab(.habits)
        )
    }

    func testRouteTranslatorGeneratesDeterministicDeepLinks() throws {
        let translator = AppExternalRouteTranslator()

        let todayURL = try XCTUnwrap(translator.deepLinkURL(for: .openTab(.today)))
        let goalURL = try XCTUnwrap(translator.deepLinkURL(for: .openGoalDetail(goalID: "goal-123")))
        let capturesURL = try XCTUnwrap(translator.deepLinkURL(for: .openCapturesInbox))

        XCTAssertEqual(todayURL.absoluteString, "ambitions://tab/today")
        XCTAssertEqual(goalURL.absoluteString, "ambitions://goal/goal-123")
        XCTAssertEqual(capturesURL.absoluteString, "ambitions://captures/inbox")
        XCTAssertEqual(translator.route(fromDeepLink: todayURL), .openTab(.today))
        XCTAssertEqual(translator.route(fromDeepLink: goalURL), .openGoalDetail(goalID: "goal-123"))
        XCTAssertEqual(translator.route(fromDeepLink: capturesURL), .openCapturesInbox)
    }

    func testNotificationAndWidgetPayloadsUseSharedRoutePayloadShape() {
        let translator = AppExternalRouteTranslator()
        let route = AppExternalRoute.openGoalDetail(goalID: "goal-123")

        let notification = translator.notificationPayload(for: route, action: "open")
        let widget = translator.widgetPayload(for: route, action: "open")

        XCTAssertEqual(notification.values, widget.values)
        XCTAssertEqual(notification.values["goalID"], "goal-123")
        XCTAssertEqual(notification.values["surface"], "goal-detail")
        XCTAssertEqual(translator.route(fromNotification: notification), route)
        XCTAssertEqual(translator.route(fromWidget: widget), route)
    }

    func testNotificationAndWidgetPayloadsUseCanonicalActionPayloadWithLegacyKeys() {
        let translator = AppExternalRouteTranslator()
        let route = AppExternalRoute.openGoalDetail(goalID: "goal-123")

        let notification = translator.notificationPayload(for: route, action: "complete")
        let widget = translator.widgetPayload(for: route, action: "complete")

        XCTAssertEqual(notification.values, widget.values)
        XCTAssertEqual(notification.values["action"], "complete")
        XCTAssertEqual(notification.values["surface"], "goal-detail")
        XCTAssertEqual(notification.values["goalID"], "goal-123")
        XCTAssertEqual(notification.values["tab"], AppTab.goals.rawValue)
        XCTAssertEqual(translator.route(fromNotification: notification), route)
        XCTAssertEqual(translator.route(fromWidget: widget), route)
    }

    func testOldPayloadKeysStillRouteAfterCanonicalPayloadNormalization() {
        let translator = AppExternalRouteTranslator()

        let oldGoalPayload = AppWidgetRoutingPayload(
            action: "open",
            values: ["goalID": "goal-old", "tab": "goals"]
        )
        let oldCapturesPayload = AppNotificationRoutingPayload(
            action: "noop",
            values: ["surface": "captures-inbox"]
        )

        XCTAssertEqual(translator.route(fromWidget: oldGoalPayload), .openGoalDetail(goalID: "goal-old"))
        XCTAssertEqual(translator.route(fromNotification: oldCapturesPayload), .openCapturesInbox)
    }

    func testCapturesInboxPayloadUsesCanonicalTodayTabHint() {
        let translator = AppExternalRouteTranslator()

        let payload = translator.routePayload(for: .openCapturesInbox)

        XCTAssertEqual(payload["surface"], "captures-inbox")
        XCTAssertEqual(payload["tab"], AppTab.today.rawValue)
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

        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertEqual(navigation.todayPath, [.capturesInbox])
        XCTAssertEqual(navigation.lastExternalRoute, .openCapturesInbox)
        XCTAssertEqual(navigation.lastExternalRouteSource, .widgetAction)
    }

    @MainActor
    func testRouterDispatchesLegacyCapturesAndHabitsTabsIntoSecondaryDestinations() {
        let navigation = AppNavigationModel(selectedTab: .today)
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.openTab(.captures), source: .deepLink)
        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertEqual(navigation.todayPath, [.capturesInbox])

        router.dispatch(.openTab(.habits), source: .deepLink)
        XCTAssertEqual(navigation.selectedTab, .plan)
        XCTAssertEqual(navigation.planPath, [.habits])
    }
}
