import XCTest
@testable import Ambitions

final class ExternalRoutingTests: XCTestCase {
    func testDeepLinkTranslatorParsesTabRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://tab/goals"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openTab(.goals))
    }

    func testCanonicalRootTabPayloadsStayAlignedWithGoalsAndYou() {
        let translator = AppExternalRouteTranslator()

        let goalsRoute = AppExternalRoute.openTab(.goals)
        let youRoute = AppExternalRoute.openTab(.you)

        XCTAssertEqual(translator.deepLinkURL(for: goalsRoute)?.absoluteString, "ambitions://tab/goals")
        XCTAssertEqual(translator.deepLinkURL(for: youRoute)?.absoluteString, "ambitions://tab/you")
        XCTAssertEqual(translator.routePayload(for: goalsRoute)[ExternalSurfaceActionPayload.Key.tab], AppTab.goals.rawValue)
        XCTAssertEqual(translator.routePayload(for: youRoute)[ExternalSurfaceActionPayload.Key.tab], AppTab.you.rawValue)
        XCTAssertEqual(translator.route(fromNotification: translator.notificationPayload(for: goalsRoute, action: "open")), goalsRoute)
        XCTAssertEqual(translator.route(fromWidget: translator.widgetPayload(for: youRoute, action: "open")), youRoute)
    }

    func testDeepLinkTranslatorRejectsProfileAliasInsteadOfMappingItToYou() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://tab/profile"))

        let route = try XCTUnwrap(translator.route(fromDeepLink: url))

        assertGenericExternalEntry(route, expectedKind: "deeplink.tab")
        XCTAssertEqual(AppTab.you.title, "You")
        XCTAssertEqual(AppTab.you.rawValue, "you")
    }

    @MainActor
    func testStageShellSharesCanonicalRouteDispatch() {
        for tab in AppTab.allCases {
            let navigation = AppNavigationModel(selectedTab: .today)
            let router = DefaultAppExternalRouter(navigation: navigation)

            router.dispatch(.openTab(tab), source: .deepLink)

            XCTAssertEqual(navigation.selectedTab, tab, "Stage shell should dispatch \(tab.rawValue)")
            XCTAssertEqual(navigation.lastExternalRoute, .openTab(tab))
            XCTAssertEqual(navigation.lastExternalRouteSource, .deepLink)
        }
    }

    @MainActor
    func testBackgroundAndRelaunchRouteSourcesStayDeterministic() {
        let navigation = AppNavigationModel(selectedTab: .today)
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.openTab(.today), source: .background)
        XCTAssertEqual(navigation.lastExternalRoute, .openTab(.today))
        XCTAssertEqual(navigation.lastExternalRouteSource, .background)

        router.dispatch(.openTab(.goals), source: .relaunch)
        XCTAssertEqual(navigation.lastExternalRoute, .openTab(.goals))
        XCTAssertEqual(navigation.lastExternalRouteSource, .relaunch)
    }

    @MainActor
    func testStageRouteDispatchesCurrentNestedRoutes() {
        let ritualsNavigation = AppNavigationModel(selectedTab: .today)
        DefaultAppExternalRouter(navigation: ritualsNavigation).dispatch(.openTimeRoute(.rituals), source: .widgetAction)
        XCTAssertEqual(ritualsNavigation.selectedTab, .time, "Stage shell should keep rituals under Time")
        XCTAssertEqual(ritualsNavigation.timePath, [.rituals])

        let historyNavigation = AppNavigationModel(selectedTab: .today)
        DefaultAppExternalRouter(navigation: historyNavigation).dispatch(.openYouRoute(.history), source: .appIntent)
        XCTAssertEqual(historyNavigation.selectedTab, .you, "Stage shell should keep History under You")
        XCTAssertEqual(historyNavigation.youPath, [.history])
    }

    func testDeepLinkTranslatorParsesCanonicalTimeTabRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://tab/time"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openTab(.time))
    }

    func testDeepLinkTranslatorRejectsRetiredTabAliases() throws {
        let translator = AppExternalRouteTranslator()

        for alias in ["capture", "captures", "motion", "pulse", "plan", "profile", "habits", "insights"] {
            let url = try XCTUnwrap(URL(string: "ambitions://tab/\(alias)"))
            guard case .genericExternalEntry = translator.route(fromDeepLink: url) else {
                XCTFail("Retired tab alias \(alias) must not be translated into a current destination.")
                return
            }
        }
    }

    func testDeepLinkTranslatorParsesCurrentTimeRitualsRoute() throws {
        let translator = AppExternalRouteTranslator()
        let timeRouteURL = try XCTUnwrap(URL(string: "ambitions://time/rituals"))

        XCTAssertEqual(translator.route(fromDeepLink: timeRouteURL), .openTimeRoute(.rituals))
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("habits"))
    }

    func testDeepLinkTranslatorUsesComposerOverlayForCapture() throws {
        let translator = AppExternalRouteTranslator()
        let overlayURL = try XCTUnwrap(URL(string: "ambitions://overlay/quiet-command-sheet?intent=quick_capture"))
        let generatedURL = try XCTUnwrap(translator.deepLinkURL(for: .openCaptureComposer))
        let generatedPayload = translator.routePayload(for: .openCaptureComposer)

        XCTAssertEqual(translator.route(fromDeepLink: overlayURL), .openCaptureComposer)
        XCTAssertEqual(generatedURL.absoluteString, "ambitions://overlay/quiet-command-sheet?intent=quick_capture")
        XCTAssertEqual(generatedPayload["surface"], "overlay")
        XCTAssertEqual(generatedPayload["overlay"], "quiet-command-sheet")
        XCTAssertEqual(generatedPayload["intent"], "quick_capture")
        XCTAssertEqual(generatedPayload["tab"], AppTab.today.rawValue)
        XCTAssertNil(AppTab(rawValue: "capture"))
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("capture"))
    }

    func testDeepLinkTranslatorParsesTodayEntryContextRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://tab/today?context=focus&origin=app_intent"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openToday(.focus))
        XCTAssertEqual(translator.source(fromDeepLink: url), .appIntent)
    }

    func testFocusContextRoutesAndPayloadsStayAlignedWithTodayStepPosture() throws {
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
        XCTAssertEqual(translator.route(fromNotification: notificationPayload), .openToday(.focus))
        XCTAssertEqual(translator.route(fromWidget: widgetPayload), .openToday(.focus))
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
        let shareURL = try XCTUnwrap(URL(string: "ambitions://overlay/quiet-command-sheet?intent=quick_capture&origin=share_extension"))
        let intentURL = try XCTUnwrap(URL(string: "ambitions://overlay/quiet-command-sheet?intent=quick_capture&origin=app_intent"))
        let spotlightURL = try XCTUnwrap(URL(string: "ambitions://goal/goal-123?origin=spotlight"))
        let handoffURL = try XCTUnwrap(URL(string: "ambitions://goal/goal-123?origin=handoff"))

        XCTAssertEqual(translator.source(fromDeepLink: widgetURL), .widgetAction)
        XCTAssertEqual(translator.source(fromDeepLink: activityURL), .liveActivity)
        XCTAssertEqual(translator.source(fromDeepLink: shareURL), .shareExtension)
        XCTAssertEqual(translator.source(fromDeepLink: intentURL), .appIntent)
        XCTAssertEqual(translator.source(fromDeepLink: spotlightURL), .spotlight)
        XCTAssertEqual(translator.source(fromDeepLink: handoffURL), .handoff)
    }

    func testDeepLinkTranslatorParsesCaptureComposerRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://overlay/quiet-command-sheet?intent=quick_capture"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(route, .openCaptureComposer)
    }

    func testDeepLinkTranslatorParsesCommandOverlayRoute() throws {
        let translator = AppExternalRouteTranslator()
        let url = try XCTUnwrap(URL(string: "ambitions://overlay/quiet-command-sheet"))

        let route = translator.route(fromDeepLink: url)

        XCTAssertEqual(
            route,
            .presentOverlay(
                .commandSheet(
                    intent: nil,
                    entrySource: .deepLink,
                    presentationContext: .neutral
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

    func testNotificationTranslatorRoutesCompletionPayloadToTodayRecovery() {
        let translator = AppExternalRouteTranslator()

        let route = translator.route(
            fromNotification: AppNotificationRoutingPayload(
                action: "complete",
                values: ["goalID": "goal-123", "stepID": "step-1"]
            )
        )

        XCTAssertEqual(route, .openToday(.recovery))
    }

    func testNotificationTranslatorRoutesCaptureComposerPayload() {
        let translator = AppExternalRouteTranslator()

        let route = translator.route(
            fromNotification: AppNotificationRoutingPayload(
                action: "open-capture-composer",
                values: [:]
            )
        )

        XCTAssertEqual(route, .openCaptureComposer)
    }

    func testWidgetTranslatorRoutesCaptureComposerPayload() {
        let translator = AppExternalRouteTranslator()

        let route = translator.route(
            fromWidget: AppWidgetRoutingPayload(
                action: "noop",
                values: ["surface": "capture-composer"]
            )
        )

        XCTAssertEqual(route, .openCaptureComposer)
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

    func testRetiredTabPayloadsFallBackToGenericExternalEntries() {
        let translator = AppExternalRouteTranslator()

        for alias in ["captures", "capture", "habits", "profile", "insights", "motion", "pulse", "plan"] {
            assertGenericExternalEntry(
                translator.route(fromNotification: AppNotificationRoutingPayload(action: "open", values: ["tab": alias])),
                expectedKind: "notification.open",
                expectedPayloadValue: ("tab", alias)
            )
            assertGenericExternalEntry(
                translator.route(fromWidget: AppWidgetRoutingPayload(action: "open", values: ["tab": alias])),
                expectedKind: "widget.open",
                expectedPayloadValue: ("tab", alias)
            )
        }
    }

    func testYouHistoryPayloadUsesYouSurface() {
        let translator = AppExternalRouteTranslator()

        let payload = translator.routePayload(for: .openYouRoute(.history))

        XCTAssertEqual(payload[ExternalSurfaceActionPayload.Key.tab], "you")
        XCTAssertEqual(AppTab.you.title, "You")
    }

    func testYouRoutesAndPayloadsUseCurrentYouSurface() throws {
        let translator = AppExternalRouteTranslator()

        let historyDeepLink = try XCTUnwrap(translator.deepLinkURL(for: .openYouRoute(.history)))
        let monthlyDeepLink = try XCTUnwrap(translator.deepLinkURL(for: .openYouRoute(.monthlyReview)))
        let historyPayload = translator.routePayload(for: .openYouRoute(.history))
        let monthlyPayload = translator.notificationPayload(for: .openYouRoute(.monthlyReview), action: "open")

        XCTAssertEqual(historyDeepLink.absoluteString, "ambitions://you/history")
        XCTAssertEqual(monthlyDeepLink.absoluteString, "ambitions://you/monthly-review")
        XCTAssertEqual(translator.route(fromDeepLink: historyDeepLink), .openYouRoute(.history))
        XCTAssertEqual(translator.route(fromDeepLink: monthlyDeepLink), .openYouRoute(.monthlyReview))
        XCTAssertEqual(historyPayload[ExternalSurfaceActionPayload.Key.tab], AppTab.you.rawValue)
        XCTAssertEqual(historyPayload[ExternalSurfaceActionPayload.Key.surface], YouRouteTarget.history.rawValue)
        XCTAssertEqual(monthlyPayload.values[ExternalSurfaceActionPayload.Key.tab], AppTab.you.rawValue)
        XCTAssertEqual(monthlyPayload.values["youRoute"], YouRouteTarget.monthlyReview.rawValue)
        XCTAssertEqual(AppTab.time.title, "Time")
    }

    func testCurrentTimeRoutesAndPayloadsUseTimeSurface() throws {
        let translator = AppExternalRouteTranslator()

        let routeURL = try XCTUnwrap(translator.deepLinkURL(for: .openTimeRoute(.rituals)))
        let routePayload = translator.routePayload(for: .openTimeRoute(.rituals))
        let notificationPayload = translator.notificationPayload(for: .openTimeRoute(.rituals), action: "open")
        let widgetPayload = translator.widgetPayload(for: .openTimeRoute(.rituals), action: "open")

        XCTAssertEqual(routeURL.absoluteString, "ambitions://time/rituals")
        XCTAssertEqual(translator.route(fromDeepLink: routeURL), .openTimeRoute(.rituals))
        XCTAssertEqual(routePayload[ExternalSurfaceActionPayload.Key.tab], AppTab.time.rawValue)
        XCTAssertEqual(routePayload["subroute"], TimeRouteTarget.rituals.rawValue)
        XCTAssertEqual(notificationPayload.values[ExternalSurfaceActionPayload.Key.tab], AppTab.time.rawValue)
        XCTAssertEqual(notificationPayload.values["subroute"], TimeRouteTarget.rituals.rawValue)
        XCTAssertEqual(widgetPayload.values[ExternalSurfaceActionPayload.Key.tab], AppTab.time.rawValue)
        XCTAssertEqual(widgetPayload.values["subroute"], TimeRouteTarget.rituals.rawValue)
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Time", "You"])
    }

    func testRetiredPulseRouteFallsBackInsteadOfMappingToToday() throws {
        let translator = AppExternalRouteTranslator()
        let pulseURL = try XCTUnwrap(URL(string: "ambitions://tab/pulse"))

        assertGenericExternalEntry(try XCTUnwrap(translator.route(fromDeepLink: pulseURL)), expectedKind: "deeplink.tab")
        assertGenericExternalEntry(
            translator.route(fromWidget: AppWidgetRoutingPayload(action: "open", values: ["tab": "pulse"])),
            expectedKind: "widget.open",
            expectedPayloadValue: ("tab", "pulse")
        )
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("pulse"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Pulse"))
    }

    func testRetiredMotionRouteFallsBackInsteadOfMappingToToday() throws {
        let translator = AppExternalRouteTranslator()
        let motionURL = try XCTUnwrap(URL(string: "ambitions://tab/motion"))

        assertGenericExternalEntry(try XCTUnwrap(translator.route(fromDeepLink: motionURL)), expectedKind: "deeplink.tab")
        assertGenericExternalEntry(
            translator.route(fromWidget: AppWidgetRoutingPayload(action: "open", values: ["tab": "motion"])),
            expectedKind: "widget.open",
            expectedPayloadValue: ("tab", "motion")
        )
        assertGenericExternalEntry(
            translator.route(fromNotification: AppNotificationRoutingPayload(action: "open", values: ["tab": "motion"])),
            expectedKind: "notification.open",
            expectedPayloadValue: ("tab", "motion")
        )
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("motion"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Motion"))
    }

    func testRouteTranslatorGeneratesDeterministicDeepLinks() throws {
        let translator = AppExternalRouteTranslator()

        let todayURL = try XCTUnwrap(translator.deepLinkURL(for: .openTab(.today)))
        let goalURL = try XCTUnwrap(translator.deepLinkURL(for: .openGoalDetail(goalID: "goal-123")))
        let captureComposerURL = try XCTUnwrap(translator.deepLinkURL(for: .openCaptureComposer))
        let memoryURL = try XCTUnwrap(translator.deepLinkURL(for: .presentOverlay(.memoryLens(entrySource: .deepLink))))

        XCTAssertEqual(todayURL.absoluteString, "ambitions://tab/today")
        XCTAssertEqual(goalURL.absoluteString, "ambitions://goal/goal-123")
        XCTAssertEqual(captureComposerURL.absoluteString, "ambitions://overlay/quiet-command-sheet?intent=quick_capture")
        XCTAssertEqual(memoryURL.absoluteString, "ambitions://overlay/memory-lens?intent=memory_lens")
        XCTAssertEqual(translator.route(fromDeepLink: todayURL), .openTab(.today))
        XCTAssertEqual(translator.route(fromDeepLink: goalURL), .openGoalDetail(goalID: "goal-123"))
        XCTAssertEqual(translator.route(fromDeepLink: captureComposerURL), .openCaptureComposer)
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

    func testNotificationAndWidgetPayloadsUseCanonicalActionPayloadShape() {
        let translator = AppExternalRouteTranslator()
        let route = AppExternalRoute.openGoalDetail(goalID: "goal-123")

        let notification = translator.notificationPayload(for: route, action: "complete")
        let widget = translator.widgetPayload(for: route, action: "complete")

        XCTAssertEqual(notification.values, widget.values)
        XCTAssertEqual(notification.values["action"], "complete")
        XCTAssertEqual(notification.values["surface"], "goal-detail")
        XCTAssertEqual(notification.values["goalID"], "goal-123")
        XCTAssertEqual(notification.values["tab"], AppTab.goals.rawValue)
        XCTAssertEqual(translator.route(fromNotification: notification), .openToday(.recovery))
        XCTAssertEqual(translator.route(fromWidget: widget), route)
    }

    func testAFRI031NotificationCompleteRoutesToTodayRecoveryInsteadOfMutatingStaleStep() {
        let translator = AppExternalRouteTranslator()
        let payload = AppNotificationRoutingPayload(
            action: "complete",
            values: [
                "goalID": "goal-123",
                "stepID": "step-456",
                "origin": ExternalSurfaceOrigin.notification.rawValue,
            ]
        )

        XCTAssertEqual(translator.route(fromNotification: payload), .openToday(.recovery))
    }

    func testMinimalPayloadsRouteAfterCanonicalPayloadNormalization() {
        let translator = AppExternalRouteTranslator()

        let goalPayload = AppWidgetRoutingPayload(
            action: "open",
            values: ["goalID": "goal-minimal", "tab": "goals"]
        )
        let composerPayload = AppNotificationRoutingPayload(
            action: "noop",
            values: ["surface": "capture-composer"]
        )

        XCTAssertEqual(translator.route(fromWidget: goalPayload), .openGoalDetail(goalID: "goal-minimal"))
        XCTAssertEqual(translator.route(fromNotification: composerPayload), .openCaptureComposer)
    }

    func testCaptureComposerPayloadUsesOverlayShape() {
        let translator = AppExternalRouteTranslator()

        let payload = translator.routePayload(for: .openCaptureComposer)
        let notificationPayload = translator.notificationPayload(for: .openCaptureComposer, action: "open")

        XCTAssertEqual(payload["surface"], "overlay")
        XCTAssertEqual(payload["overlay"], "quiet-command-sheet")
        XCTAssertEqual(payload["intent"], "quick_capture")
        XCTAssertEqual(payload["tab"], AppTab.today.rawValue)
        XCTAssertEqual(notificationPayload.values["surface"], "overlay")
        XCTAssertEqual(notificationPayload.values["overlay"], "quiet-command-sheet")
        XCTAssertEqual(notificationPayload.values["intent"], "quick_capture")
        XCTAssertEqual(notificationPayload.values["tab"], AppTab.today.rawValue)
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("capture"))
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
    func testRouterDispatchesCaptureComposerToGlobalCaptureOverlay() {
        let navigation = AppNavigationModel(selectedTab: .you)
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.openCaptureComposer, source: .widgetAction)

        XCTAssertEqual(navigation.selectedTab, .you)
        XCTAssertEqual(navigation.activeOverlay?.kind, .quietCommandSheet)
        XCTAssertEqual(navigation.activeOverlay?.intent, .quickCapture)
        XCTAssertEqual(navigation.activeOverlay?.entrySource, .widget)
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertEqual(navigation.lastExternalRoute, .openCaptureComposer)
        XCTAssertEqual(navigation.lastExternalRouteSource, .widgetAction)
        XCTAssertEqual(navigation.recentCommandHistory.first?.destinationLabel, "Capture")
    }

    @MainActor
    func testRouterDispatchesCaptureComposerAndTimeRouteIntoCanonicalDestinations() {
        let navigation = AppNavigationModel(selectedTab: .today)
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.openCaptureComposer, source: .deepLink)
        XCTAssertEqual(navigation.selectedTab, .today)
        XCTAssertEqual(navigation.activeOverlay?.kind, .quietCommandSheet)
        XCTAssertEqual(navigation.activeOverlay?.intent, .quickCapture)
        XCTAssertTrue(navigation.timePath.isEmpty)
        XCTAssertEqual(navigation.recentCommandHistory.first?.destinationLabel, "Capture")

        router.dispatch(.openTimeRoute(.rituals), source: .deepLink)
        XCTAssertEqual(navigation.selectedTab, .time)
        XCTAssertEqual(navigation.timePath, [.rituals])
    }

    @MainActor
    func testRouterDispatchesYouRootToYouSurface() {
        let navigation = AppNavigationModel(selectedTab: .today)
        let router = DefaultAppExternalRouter(navigation: navigation)

        router.dispatch(.openTab(.you), source: .deepLink)

        XCTAssertEqual(navigation.selectedTab, .you)
        XCTAssertEqual(navigation.lastExternalRoute, .openTab(.you))
        XCTAssertEqual(AppTab.you.title, "You")
    }

    @MainActor
    func testRouterDispatchesYouRoutesToYouHistorySupport() {
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
        navigation.openCaptureComposer()
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

    func testAFEP016ContinuationTokensRouteToExactProofOrCanonicalFallbackRoots() throws {
        let translator = AppExternalRouteTranslator()
        let goalToken = ExternalObjectContinuationToken(
            kind: .goal,
            root: .goals,
            goalID: "goal-123",
            stepID: nil,
            receiptID: nil,
            captureID: nil,
            metadataClass: .exactReopen,
            redaction: .safeSummary
        )
        let stepToken = ExternalObjectContinuationToken(
            kind: .currentStep,
            root: .goals,
            goalID: "goal-123",
            stepID: "step-456",
            receiptID: nil,
            captureID: nil,
            metadataClass: .exactReopen,
            redaction: .safeSummary
        )
        let receiptToken = ExternalObjectContinuationToken(
            kind: .receipt,
            root: .today,
            goalID: nil,
            stepID: nil,
            receiptID: "receipt-789",
            captureID: nil,
            metadataClass: .fallbackRoot,
            redaction: .redactedPrivate
        )
        let exactReceiptToken = ExternalObjectContinuationToken(
            kind: .receipt,
            root: .today,
            goalID: nil,
            stepID: nil,
            receiptID: "receipt-exact",
            captureID: nil,
            metadataClass: .exactReopen,
            redaction: .safeSummary
        )
        let captureToken = ExternalObjectContinuationToken(
            kind: .capture,
            root: .today,
            goalID: nil,
            stepID: nil,
            receiptID: nil,
            captureID: "capture-321",
            metadataClass: .exactReopen,
            redaction: .safeSummary
        )
        let fallbackGoal = ExternalObjectContinuationToken(
            kind: .goal,
            root: .goals,
            goalID: nil,
            stepID: nil,
            receiptID: nil,
            captureID: nil,
            metadataClass: .fallbackRoot,
            redaction: .redactedPrivate
        )
        let fallbackReceipt = ExternalObjectContinuationToken(
            kind: .receipt,
            root: .today,
            goalID: nil,
            stepID: nil,
            receiptID: nil,
            captureID: nil,
            metadataClass: .fallbackRoot,
            redaction: .redactedPrivate
        )
        let fallbackGoalWithIDs = ExternalObjectContinuationToken(
            kind: .goal,
            root: .goals,
            goalID: "goal-hidden",
            stepID: nil,
            receiptID: nil,
            captureID: nil,
            metadataClass: .fallbackRoot,
            redaction: .redactedPrivate
        )
        let fallbackReceiptWithIDs = ExternalObjectContinuationToken(
            kind: .receipt,
            root: .today,
            goalID: nil,
            stepID: nil,
            receiptID: "receipt-hidden",
            captureID: nil,
            metadataClass: .fallbackRoot,
            redaction: .redactedPrivate
        )

        XCTAssertEqual(translator.route(fromContinuation: goalToken), .openGoalDetail(goalID: "goal-123"))
        XCTAssertEqual(translator.route(fromContinuation: stepToken), .openGoalDetail(goalID: "goal-123"))
        XCTAssertEqual(translator.route(fromContinuation: receiptToken), .openTab(.today))
        XCTAssertEqual(
            translator.route(fromContinuation: exactReceiptToken),
            .presentOverlay(
                .memoryLens(
                    intent: .memoryLens,
                    entrySource: .external,
                    presentationContext: .recall,
                    query: "receipt:receipt-exact"
                )
            )
        )
        XCTAssertEqual(translator.route(fromContinuation: captureToken), .openCaptureComposer)
        XCTAssertEqual(translator.route(fromContinuation: fallbackGoal), .openTab(.goals))
        XCTAssertEqual(translator.route(fromContinuation: fallbackReceipt), .openTab(.today))
        XCTAssertEqual(translator.route(fromContinuation: fallbackGoalWithIDs), .openTab(.goals))
        XCTAssertEqual(translator.route(fromContinuation: fallbackReceiptWithIDs), .openTab(.today))

        XCTAssertEqual(translator.routePayload(for: goalToken)[ExternalSurfaceActionPayload.Key.kind], "goal")
        XCTAssertEqual(translator.routePayload(for: stepToken)[ExternalSurfaceActionPayload.Key.stepID], "step-456")
        XCTAssertEqual(translator.routePayload(for: receiptToken)[ExternalSurfaceActionPayload.Key.root], "today")
        XCTAssertEqual(translator.routePayload(for: exactReceiptToken)[ExternalSurfaceActionPayload.Key.receiptID], "receipt-exact")
        XCTAssertEqual(translator.routePayload(for: captureToken)[ExternalSurfaceActionPayload.Key.captureID], "capture-321")
        XCTAssertNil(translator.routePayload(for: fallbackGoalWithIDs)[ExternalSurfaceActionPayload.Key.goalID])
        XCTAssertNil(translator.routePayload(for: fallbackReceiptWithIDs)[ExternalSurfaceActionPayload.Key.receiptID])

        XCTAssertEqual(translator.deepLinkURL(for: goalToken)?.absoluteString, "ambitions://goal/goal-123?origin=spotlight")
        XCTAssertEqual(translator.deepLinkURL(for: stepToken)?.absoluteString, "ambitions://goal/goal-123?origin=spotlight&stepID=step-456")
        XCTAssertEqual(translator.deepLinkURL(for: receiptToken)?.absoluteString, "ambitions://tab/today?origin=spotlight")
        XCTAssertEqual(translator.deepLinkURL(for: exactReceiptToken)?.absoluteString, "ambitions://overlay/memory-lens?intent=memory_lens&q=receipt:receipt-exact&origin=spotlight")
        XCTAssertEqual(translator.deepLinkURL(for: captureToken)?.absoluteString, "ambitions://overlay/quiet-command-sheet?intent=quick_capture&origin=spotlight&captureID=capture-321")
        XCTAssertEqual(translator.deepLinkURL(for: fallbackGoal)?.absoluteString, "ambitions://tab/goals?origin=spotlight")
        XCTAssertEqual(translator.deepLinkURL(for: fallbackReceipt)?.absoluteString, "ambitions://tab/today?origin=spotlight")
        XCTAssertEqual(translator.deepLinkURL(for: fallbackGoalWithIDs)?.absoluteString, "ambitions://tab/goals?origin=spotlight")
        XCTAssertEqual(translator.deepLinkURL(for: fallbackReceiptWithIDs)?.absoluteString, "ambitions://tab/today?origin=spotlight")
    }

    func testDeepLinkRegistryDeclaresOnlySupportedAddressableRoutes() throws {
        let translator = AppExternalRouteTranslator()

        XCTAssertEqual(AppDeepLinkRegistry.validationIssues(translator: translator), [])
        XCTAssertEqual(AppNavigationGraph.nodes.map(\.id), AppDeepLinkRegistry.entries.map(\.id))
        XCTAssertFalse(AppDeepLinkRegistry.entries.contains { $0.objectKind == .rootTab && $0.deepLinkTemplate.localizedCaseInsensitiveContains("capture") })
        XCTAssertFalse(AppTab.allCases.map(\.rawValue).contains("capture"))

        for entry in AppDeepLinkRegistry.entries {
            let url = try XCTUnwrap(translator.deepLinkURL(for: entry.canonicalRoute), entry.id)
            let roundTripRoute = translator.route(fromDeepLink: url)

            switch entry.canonicalRoute {
            case .presentOverlay:
                XCTAssertNotNil(roundTripRoute, entry.id)
            default:
                XCTAssertEqual(roundTripRoute, entry.canonicalRoute, entry.id)
            }
            XCTAssertTrue(entry.opensWithoutDeadEnd, entry.id)
            XCTAssertTrue(entry.owner.isCanonical, entry.id)
            XCTAssertFalse(entry.allowedSources.isEmpty, entry.id)
            XCTAssertFalse(entry.privacyBoundary.isEmpty, entry.id)
        }
    }

    @MainActor
    func testNavigationGraphOpensWidgetNotificationAndShortcutObjectsWithoutDeadEnds() {
        let previews = AppDeepLinkPreviewRoutes.all

        for preview in previews {
            let previewRouter = AppDeepLinkPreviewRouter()

            previewRouter.open(preview)

            XCTAssertEqual(previewRouter.navigation.selectedTab, preview.expectedTab, preview.id)
            XCTAssertEqual(previewRouter.navigation.lastExternalRoute, preview.route, preview.id)
            XCTAssertEqual(previewRouter.navigation.lastExternalRouteSource, preview.source, preview.id)
            XCTAssertFalse(preview.privacyBoundary.isEmpty, preview.id)
        }
    }

    @MainActor
    func testRegistryPreviewRouterFallsBackInsteadOfInventingUnsupportedRoutes() {
        let previewRouter = AppDeepLinkPreviewRouter(initialTab: .time)

        previewRouter.openRegistryEntry(id: "missing.shared-prerequisite", source: .widgetAction)

        XCTAssertEqual(previewRouter.navigation.selectedTab, .today)
        XCTAssertEqual(previewRouter.navigation.lastExternalRouteSource, .widgetAction)
        XCTAssertTrue(previewRouter.navigation.goalsPath.isEmpty)
        XCTAssertTrue(previewRouter.navigation.timePath.isEmpty)
    }

    private func assertGenericExternalEntry(
        _ route: AppExternalRoute,
        expectedKind: String,
        expectedPayloadValue: (key: String, value: String)? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case let .genericExternalEntry(kind, payload) = route else {
            XCTFail("Expected generic external entry, received \(route)", file: file, line: line)
            return
        }
        XCTAssertEqual(kind, expectedKind, file: file, line: line)
        if let expectedPayloadValue {
            XCTAssertEqual(payload[expectedPayloadValue.key], expectedPayloadValue.value, file: file, line: line)
        }
    }
}
