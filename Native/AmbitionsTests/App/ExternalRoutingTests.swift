import XCTest
@testable import Ambitions

final class ExternalRoutingTests: XCTestCase {
    func testDeepLinkTranslatorParsesTabRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://tab/goals"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openTab(.goals))
    }

    func testDeepLinkTranslatorPreservesLegacyProfileTabAsYouSurface() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://tab/profile"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openTab(.you))
        XCTAssertEqual(AppTab.you.title, "You")
        XCTAssertEqual(AppTab.you.rawValue, "you")
    }

    @MainActor
    func testShellPresentationModesShareCanonicalRouteDispatch() {
        let modes: [AppShellPresentationMode] = [.nativeFallback, .meridian]

        for mode in modes {
            for tab in AppTab.allCases {
                let navigation = AppNavigationModel(selectedTab: .today)
                let router = DefaultAppExternalRouter(navigation: navigation)

                router.dispatch(.openTab(tab), source: .deepLink)

                XCTAssertEqual(navigation.selectedTab, tab, "Mode \(mode.rawValue) should dispatch \(tab.rawValue)")
                XCTAssertEqual(navigation.lastExternalRoute, .openTab(tab))
                XCTAssertEqual(navigation.lastExternalRouteSource, .deepLink)
            }
        }
    }

    @MainActor
    func testFallbackAndMeridianRouteCompatibilityForLegacyTabs() {
        let modes: [AppShellPresentationMode] = [.nativeFallback, .meridian]

        for mode in modes {
            let habitsNavigation = AppNavigationModel(selectedTab: .today)
            DefaultAppExternalRouter(navigation: habitsNavigation).dispatch(.openTimeRoute(.habits), source: .widgetAction)
            XCTAssertEqual(habitsNavigation.selectedTab, .time, "Mode \(mode.rawValue) should keep habits under Time")
            XCTAssertEqual(habitsNavigation.timePath, [.habits])

            let insightsNavigation = AppNavigationModel(selectedTab: .today)
            DefaultAppExternalRouter(navigation: insightsNavigation).dispatch(.openYouRoute(.history), source: .appIntent)
            XCTAssertEqual(insightsNavigation.selectedTab, .you, "Mode \(mode.rawValue) should keep insights under You")
            XCTAssertEqual(insightsNavigation.youPath, [.history])
        }
    }

    func testDeepLinkTranslatorParsesCanonicalTimeTabRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://tab/plan"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openTab(.time))
    }

    func testDeepLinkTranslatorPreservesLegacyInsightsTabCompatibility() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://tab/insights"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openYouRoute(.history))
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "insights"), .you)
        XCTAssertEqual(AppTab.time.title, "Time")
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("insights"))
    }

    func testDeepLinkTranslatorPreservesLegacyHabitsTabAsTimeRitualRoute() throws {
        let translator = AppExternalRouteTranslator()
        let legacyTabURL = try XCTUnwrap(URL(string: "ambitions://tab/habits"))
        let planRouteURL = try XCTUnwrap(URL(string: "ambitions://plan/habits"))

        XCTAssertEqual(translator.route(fromDeepLink: legacyTabURL), .openTimeRoute(.habits))
        XCTAssertEqual(translator.route(fromDeepLink: planRouteURL), .openTimeRoute(.habits))
        XCTAssertEqual(LegacyIARouteCompatibility.canonicalTab(forRawTab: "habits"), .time)
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("habits"))
    }

    func testDeepLinkTranslatorParsesTodayEntryContextRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://tab/today?context=focus&origin=app_intent"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openToday(.focus))
        XCTAssertEqual(translator.source(fromDeepLink: url), .appIntent)
    }

    func testFocusContextRoutesAndPayloadsRemainCompatibleWithTodayStepPosture() throws {
        let translator = AppExternalRouteTranslator()
        let route = AppExternalRoute.openToday(.focus)
        let deepLink = try XCTUnwrap(translator.deepLinkURL(for: route))
        let routePayload = translator.routePayload(for: route)
        let notificationPayload = translator.notificationPayload(for: route, action: "open")
        let widgetPayload = translator.widgetPayload(for: route, action: "open")

        XCTAssertEqual(deepLink.absoluteString, "ambitions://tab/today?context=focus")
        XCTAssertEqual(translator.route(fromDeepLink: deepLink), .openToday(.focus))
        XCTAssertEqual(routePayload[ExternalSurfaceActionPayload.Key.tab], AppTab.today.rawValue)
        XCTAssertEqual(routePayload["context"], TodayEntryContext.focus.rawValue)
        XCTAssertEqual(notificationPayload.values["context"], TodayEntryContext.focus.rawValue)
        XCTAssertEqual(widgetPayload.values["context"], TodayEntryContext.focus.rawValue)
        XCTAssertEqual(translator.route(fromNotification: notificationPayload), .openTab(.today))
        XCTAssertEqual(translator.route(fromWidget: widgetPayload), .openTab(.today))
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
        let spotlightURL = try XCTUnwrap(URL(string: "ambitions://goal/goal-123?origin=spotlight"))
        let handoffURL = try XCTUnwrap(URL(string: "ambitions://goal/goal-123?origin=handoff"))

        XCTAssertEqual(translator.source(fromDeepLink: widgetURL), .widgetAction)
        XCTAssertEqual(translator.source(fromDeepLink: activityURL), .liveActivity)
        XCTAssertEqual(translator.source(fromDeepLink: shareURL), .shareExtension)
        XCTAssertEqual(translator.source(fromDeepLink: intentURL), .appIntent)
        XCTAssertEqual(translator.source(fromDeepLink: spotlightURL), .spotlight)
        XCTAssertEqual(translator.source(fromDeepLink: handoffURL), .handoff)
    }

    func testDeepLinkTranslatorParsesCapturesInboxRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://captures/inbox"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openTimeRoute(.captureInbox))
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

        XCTAssertEqual(route, .openTimeRoute(.captureInbox))
    }

    func testWidgetTranslatorRoutesCapturesInboxPayload() {
        let translator = AppExternalRouteTranslator()

        let route = translator.route(
            fromWidget: AppWidgetRoutingPayload(
                action: "noop",
                values: ["surface": "captures-inbox"]
            )
        )

        XCTAssertEqual(route, .openTimeRoute(.captureInbox))
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
            .openTab(.capture)
        )
        XCTAssertEqual(
            translator.route(fromWidget: AppWidgetRoutingPayload(action: "open", values: ["tab": "habits"])),
            .openTimeRoute(.habits)
        )
        XCTAssertEqual(
            translator.route(fromNotification: AppNotificationRoutingPayload(action: "open", values: ["tab": "profile"])),
            .openTab(.you)
        )
        XCTAssertEqual(
            translator.route(fromWidget: AppWidgetRoutingPayload(action: "open", values: ["tab": "profile"])),
            .openTab(.you)
        )
        XCTAssertEqual(
            translator.route(fromNotification: AppNotificationRoutingPayload(action: "open", values: ["tab": "insights"])),
            .openYouRoute(.history)
        )
        XCTAssertEqual(
            translator.route(fromWidget: AppWidgetRoutingPayload(action: "open", values: ["tab": "insights"])),
            .openYouRoute(.history)
        )
    }

    func testInsightsPayloadUsesYouCompatibilityTabForYouSurface() {
        let translator = AppExternalRouteTranslator()

        let payload = translator.routePayload(for: .openYouRoute(.history))

        XCTAssertEqual(payload[ExternalSurfaceActionPayload.Key.tab], "you")
        XCTAssertEqual(AppTab.you.title, "You")
    }

    func testLegacyInsightsRoutesAndPayloadsRemainCompatibleWithoutTimeMigrationClaim() throws {
        let translator = AppExternalRouteTranslator()

        let historyURL = try XCTUnwrap(URL(string: "ambitions://insights/history"))
        let monthlyURL = try XCTUnwrap(URL(string: "ambitions://insights/monthly-review"))
        let historyDeepLink = try XCTUnwrap(translator.deepLinkURL(for: .openYouRoute(.history)))
        let monthlyDeepLink = try XCTUnwrap(translator.deepLinkURL(for: .openYouRoute(.monthlyReview)))
        let historyPayload = translator.routePayload(for: .openYouRoute(.history))
        let monthlyPayload = translator.notificationPayload(for: .openYouRoute(.monthlyReview), action: "open")

        XCTAssertEqual(translator.route(fromDeepLink: historyURL), .openYouRoute(.history))
        XCTAssertEqual(translator.route(fromDeepLink: monthlyURL), .openYouRoute(.monthlyReview))
        XCTAssertEqual(historyDeepLink.absoluteString, "ambitions://you/history")
        XCTAssertEqual(monthlyDeepLink.absoluteString, "ambitions://you/monthly-review")
        XCTAssertEqual(historyPayload[ExternalSurfaceActionPayload.Key.tab], AppTab.you.rawValue)
        XCTAssertEqual(historyPayload[ExternalSurfaceActionPayload.Key.surface], YouRouteTarget.history.rawValue)
        XCTAssertEqual(monthlyPayload.values[ExternalSurfaceActionPayload.Key.tab], AppTab.you.rawValue)
        XCTAssertEqual(monthlyPayload.values["youRoute"], YouRouteTarget.monthlyReview.rawValue)
        XCTAssertEqual(AppTab.time.title, "Time")
    }

    func testLegacyHabitsRoutesAndPayloadsRemainCompatibleWithTimeRitualSemantics() throws {
        let translator = AppExternalRouteTranslator()

        let routeURL = try XCTUnwrap(translator.deepLinkURL(for: .openTimeRoute(.habits)))
        let routePayload = translator.routePayload(for: .openTimeRoute(.habits))
        let notificationPayload = translator.notificationPayload(for: .openTimeRoute(.habits), action: "open")
        let widgetPayload = translator.widgetPayload(for: .openTimeRoute(.habits), action: "open")

        XCTAssertEqual(routeURL.absoluteString, "ambitions://time/habits")
        XCTAssertEqual(translator.route(fromDeepLink: routeURL), .openTimeRoute(.habits))
        XCTAssertEqual(routePayload[ExternalSurfaceActionPayload.Key.tab], AppTab.time.rawValue)
        XCTAssertEqual(routePayload["subroute"], TimeRouteTarget.habits.rawValue)
        XCTAssertEqual(notificationPayload.values[ExternalSurfaceActionPayload.Key.tab], AppTab.time.rawValue)
        XCTAssertEqual(notificationPayload.values["subroute"], TimeRouteTarget.habits.rawValue)
        XCTAssertEqual(widgetPayload.values[ExternalSurfaceActionPayload.Key.tab], AppTab.time.rawValue)
        XCTAssertEqual(widgetPayload.values["subroute"], TimeRouteTarget.habits.rawValue)
        XCTAssertEqual(
            translator.route(fromWidget: AppWidgetRoutingPayload(action: "open", values: ["tab": "habits"])),
            .openTimeRoute(.habits)
        )
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Time", "You"])
    }

    func testRouteTranslatorGeneratesDeterministicDeepLinks() throws {
        let translator = AppExternalRouteTranslator()

        let todayURL = try XCTUnwrap(translator.deepLinkURL(for: .openTab(.today)))
        let goalURL = try XCTUnwrap(translator.deepLinkURL(for: .openGoalDetail(goalID: "goal-123")))
        let capturesURL = try XCTUnwrap(translator.deepLinkURL(for: .openTimeRoute(.captureInbox)))
        let memoryURL = try XCTUnwrap(translator.deepLinkURL(for: .presentOverlay(.memoryLens(entrySource: .deepLink))))

        XCTAssertEqual(todayURL.absoluteString, "ambitions://tab/today")
        XCTAssertEqual(goalURL.absoluteString, "ambitions://goal/goal-123")
        XCTAssertEqual(capturesURL.absoluteString, "ambitions://captures/inbox")
        XCTAssertEqual(memoryURL.absoluteString, "ambitions://overlay/memory-lens?intent=memory_lens")
        XCTAssertEqual(translator.route(fromDeepLink: todayURL), .openTab(.today))
        XCTAssertEqual(translator.route(fromDeepLink: goalURL), .openGoalDetail(goalID: "goal-123"))
        XCTAssertEqual(translator.route(fromDeepLink: capturesURL), .openTimeRoute(.captureInbox))
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
        XCTAssertEqual(translator.route(fromNotification: oldCapturesPayload), .openTimeRoute(.captureInbox))
    }

    func testCapturesInboxPayloadUsesCanonicalCaptureTabHint() {
        let translator = AppExternalRouteTranslator()

        let payload = translator.routePayload(for: .openTimeRoute(.captureInbox))

        XCTAssertEqual(payload["surface"], "captures-inbox")
        XCTAssertEqual(payload["tab"], AppTab.capture.rawValue)
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
        let navigation = AppNavigationModel(legacyTabRawValue: "insights")
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.openTimeRoute(.captureInbox), source: .widgetAction)

        XCTAssertEqual(navigation.selectedTab, .capture)
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertEqual(navigation.lastExternalRoute, .openTimeRoute(.captureInbox))
        XCTAssertEqual(navigation.lastExternalRouteSource, .widgetAction)
    }

    @MainActor
    func testRouterDispatchesCaptureTabAndLegacyHabitsTabIntoCanonicalDestinations() {
        let navigation = AppNavigationModel(selectedTab: .today)
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.openTab(.capture), source: .deepLink)
        XCTAssertEqual(navigation.selectedTab, .capture)
        XCTAssertTrue(navigation.timePath.isEmpty)

        router.dispatch(.openTimeRoute(.habits), source: .deepLink)
        XCTAssertEqual(navigation.selectedTab, .time)
        XCTAssertEqual(navigation.timePath, [.habits])
    }

    @MainActor
    func testRouterDispatchesLegacyProfileTabToYouSurface() {
        let navigation = AppNavigationModel(selectedTab: .today)
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.openTab(.you), source: .deepLink)

        XCTAssertEqual(navigation.selectedTab, .you)
        XCTAssertEqual(navigation.lastExternalRoute, .openTab(.you))
        XCTAssertEqual(AppTab.you.title, "You")
    }

    @MainActor
    func testRouterDispatchesInsightsCompatibilityRoutesToYouHistorySupport() {
        let navigation = AppNavigationModel(selectedTab: .today)
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.openYouRoute(.history), source: .deepLink)

        XCTAssertEqual(navigation.selectedTab, .you)
        XCTAssertEqual(navigation.youPath, [.history])
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertEqual(navigation.lastExternalRoute, .openYouRoute(.history))
        XCTAssertEqual(AppTab.time.title, "Time")
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("insights"))

        router.dispatch(.openYouRoute(.monthlyReview), source: .deepLink)

        XCTAssertEqual(navigation.selectedTab, .you)
        XCTAssertEqual(navigation.youPath, [.monthlyReview])
        XCTAssertEqual(navigation.lastExternalRoute, .openYouRoute(.monthlyReview))
    }

    @MainActor
    func testRouterFallsBackToExplicitTodayLandingForUnknownExternalEntries() {
        let navigation = AppNavigationModel(selectedTab: .time)
        navigation.openTimeRoute(.captureInbox)
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
