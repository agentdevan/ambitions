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

    func testDeepLinkTranslatorParsesTodayEntryContextRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://tab/today?context=focus&origin=app_intent"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openToday(.focus))
        XCTAssertEqual(translator.source(fromDeepLink: url), .appIntent)
    }

    func testDeepLinkTranslatorParsesGoalRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://goal/goal-123"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openGoalDetail(goalID: "goal-123"))
    }

    func testDeepLinkTranslatorPreservesExternalOriginSource() throws {
        let translator = AppExternalRouteTranslator()
        let widgetURL = try XCTUnwrap(URL(string: "ambitions://goal/goal-123?origin=widget"))
        let activityURL = try XCTUnwrap(URL(string: "ambitions://goal/goal-123?origin=live_activity"))
        let shareURL = try XCTUnwrap(URL(string: "ambitions://captures/inbox?origin=share_extension"))
        let intentURL = try XCTUnwrap(URL(string: "ambitions://captures/inbox?origin=app_intent"))

        XCTAssertEqual(translator.source(fromDeepLink: widgetURL), .widgetAction)
        XCTAssertEqual(translator.source(fromDeepLink: activityURL), .liveActivity)
        XCTAssertEqual(translator.source(fromDeepLink: shareURL), .shareExtension)
        XCTAssertEqual(translator.source(fromDeepLink: intentURL), .appIntent)
    }

    func testDeepLinkTranslatorParsesCapturesInboxRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://captures/inbox"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openPlanRoute(.capturesInbox))
    }

    func testDeepLinkTranslatorParsesCommandOverlayRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://overlay/quiet-command-sheet?intent=quick_capture"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(
            route,
            .presentOverlay(
                .commandSheet(
                    intent: .quickCapture,
                    entrySource: .deepLink
                )
            )
        )
    }

    func testDeepLinkTranslatorPreservesAppIntentEntrySourceOnOverlayRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://overlay/quiet-command-sheet?intent=quick_focus&origin=app_intent"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(
            route,
            .presentOverlay(
                .commandSheet(
                    intent: .quickFocus,
                    entrySource: .appIntent,
                    presentationContext: .neutral
                )
            )
        )
    }

    func testDeepLinkTranslatorParsesMemoryLensOverlayRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://overlay/memory-lens?intent=open_goal&q=career"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(
            route,
            .presentOverlay(
                .memoryLens(
                    intent: .openGoal,
                    entrySource: .deepLink,
                    presentationContext: .recall,
                    query: "career"
                )
            )
        )
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

        XCTAssertEqual(route, .openPlanRoute(.capturesInbox))
    }

    func testWidgetTranslatorRoutesCapturesInboxPayload() {
        let translator = AppExternalRouteTranslator()

        let route = translator.route(
            fromWidget: AppWidgetRoutingPayload(
                action: "noop",
                values: ["surface": "captures-inbox"]
            )
        )

        XCTAssertEqual(route, .openPlanRoute(.capturesInbox))
    }

    func testWidgetTranslatorRoutesOverlayPayload() {
        let translator = AppExternalRouteTranslator()

        let route = translator.route(
            fromWidget: AppWidgetRoutingPayload(
                action: "open-memory-lens",
                values: ["overlay": "memory-lens", "intent": "memory_lens"]
            )
        )

        XCTAssertEqual(route, .presentOverlay(.memoryLens(entrySource: .widget)))
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
        let capturesURL = try XCTUnwrap(translator.deepLinkURL(for: .openPlanRoute(.capturesInbox)))
        let memoryURL = try XCTUnwrap(translator.deepLinkURL(for: .presentOverlay(.memoryLens(entrySource: .deepLink))))

        XCTAssertEqual(todayURL.absoluteString, "ambitions://tab/today")
        XCTAssertEqual(goalURL.absoluteString, "ambitions://goal/goal-123")
        XCTAssertEqual(capturesURL.absoluteString, "ambitions://captures/inbox")
        XCTAssertEqual(memoryURL.absoluteString, "ambitions://overlay/memory-lens?intent=memory_lens")
        XCTAssertEqual(translator.route(fromDeepLink: todayURL), .openTab(.today))
        XCTAssertEqual(translator.route(fromDeepLink: goalURL), .openGoalDetail(goalID: "goal-123"))
        XCTAssertEqual(translator.route(fromDeepLink: capturesURL), .openPlanRoute(.capturesInbox))
        XCTAssertEqual(translator.route(fromDeepLink: memoryURL), .presentOverlay(.memoryLens(entrySource: .deepLink)))
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
        XCTAssertEqual(translator.route(fromNotification: oldCapturesPayload), .openPlanRoute(.capturesInbox))
    }

    func testCapturesInboxPayloadUsesCanonicalCaptureTabHint() {
        let translator = AppExternalRouteTranslator()

        let payload = translator.routePayload(for: .openPlanRoute(.capturesInbox))

        XCTAssertEqual(payload["surface"], "captures-inbox")
        XCTAssertEqual(payload["tab"], AppTab.captures.rawValue)
    }

    func testOverlayPayloadCarriesIntentForCanonicalNormalization() {
        let translator = AppExternalRouteTranslator()
        let payload = translator.routePayload(for: .presentOverlay(.commandSheet(intent: .quickCapture, entrySource: .appIntent)))

        XCTAssertEqual(payload["surface"], "overlay")
        XCTAssertEqual(payload["overlay"], "quiet-command-sheet")
        XCTAssertEqual(payload["intent"], "quick_capture")
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
    func testRouterDispatchesCapturesInboxToTopLevelCapture() {
        let navigation = AppNavigationModel(selectedTab: .insights)
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.openPlanRoute(.capturesInbox), source: .widgetAction)

        XCTAssertEqual(navigation.selectedTab, .captures)
        XCTAssertTrue(navigation.planPath.isEmpty)
        XCTAssertEqual(navigation.lastExternalRoute, .openPlanRoute(.capturesInbox))
        XCTAssertEqual(navigation.lastExternalRouteSource, .widgetAction)
    }

    @MainActor
    func testRouterDispatchesCaptureTabAndLegacyHabitsTabIntoCanonicalDestinations() {
        let navigation = AppNavigationModel(selectedTab: .today)
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.openTab(.captures), source: .deepLink)
        XCTAssertEqual(navigation.selectedTab, .captures)
        XCTAssertTrue(navigation.planPath.isEmpty)

        router.dispatch(.openTab(.habits), source: .deepLink)
        XCTAssertEqual(navigation.selectedTab, .plan)
        XCTAssertEqual(navigation.planPath, [.habits])
    }

    @MainActor
    func testRouterFallsBackToExplicitTodayLandingForUnknownExternalEntries() {
        let navigation = AppNavigationModel(selectedTab: .plan)
        navigation.openPlanRoute(.capturesInbox)
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.genericExternalEntry(kind: "future", payload: [:]), source: .deepLink)

        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertTrue(navigation.goalsPath.isEmpty)
        XCTAssertEqual(navigation.lastExternalRouteSource, .deepLink)
    }

    @MainActor
    func testRouterDispatchesOverlayIntoStructuredShellState() {
        let navigation = AppNavigationModel(selectedTab: .today)
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.presentOverlay(.memoryLens(entrySource: .appIntent)), source: .deepLink)

        XCTAssertEqual(navigation.activeOverlay?.kind, .memoryLens)
        XCTAssertEqual(navigation.activeOverlay?.intent, .memoryLens)
    }
}
