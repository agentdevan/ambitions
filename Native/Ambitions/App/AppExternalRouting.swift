import Foundation

enum AppExternalRoute: Equatable, Sendable {
    case openTab(AppTab)
    case openToday(TodayEntryContext)
    case openGoalDetail(goalID: String)
    case openPlanRoute(PlanRouteTarget)
    case openInsightsRoute(InsightsRouteTarget)
    case presentOverlay(ShellOverlayState)
    case genericExternalEntry(kind: String, payload: [String: String])
}

enum AppExternalRouteSource: String, Sendable {
    case deepLink
    case notificationAction
    case widgetAction
    case liveActivity
    case shareExtension
    case appIntent
}

struct AppNotificationRoutingPayload: Equatable, Sendable {
    let action: String
    let values: [String: String]
}

struct AppWidgetRoutingPayload: Equatable, Sendable {
    let action: String
    let values: [String: String]
}

struct AppExternalRouteTranslator {
    func source(fromDeepLink url: URL) -> AppExternalRouteSource {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let origin = components.queryItems?.first(where: { $0.name == "origin" })?.value else {
            return .deepLink
        }

        switch origin {
        case "share_extension":
            return .shareExtension
        case "app_intent":
            return .appIntent
        case ExternalSurfaceOrigin.widget.rawValue:
            return .widgetAction
        case ExternalSurfaceOrigin.liveActivity.rawValue:
            return .liveActivity
        case ExternalSurfaceOrigin.notification.rawValue:
            return .notificationAction
        default:
            return .deepLink
        }
    }

    func route(fromDeepLink url: URL) -> AppExternalRoute? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        guard let scheme = components.scheme?.lowercased(), scheme == "ambitions" else {
            return nil
        }

        let host = (components.host ?? "").lowercased()
        let pathSegments = components.path
            .split(separator: "/")
            .map { String($0) }
        let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })

        if host == "tab" || host == "tabs" {
            let rawTab = pathSegments.first ?? query["name"] ?? query["tab"]
            if let rawTab, let tab = AppTab(rawValue: rawTab.lowercased()) {
                if tab == .today, let context = query["context"].flatMap(TodayEntryContext.init(rawValue:)) {
                    return .openToday(context)
                }
                return .openTab(tab)
            }
        }

        if host == "goal" || host == "goals" {
            if let goalID = pathSegments.first ?? query["id"] ?? query["goalID"], goalID.isEmpty == false {
                return .openGoalDetail(goalID: goalID)
            }
        }

        if host == "captures" || host == "inbox" {
            if pathSegments.isEmpty || pathSegments.first == "inbox" {
                return .openPlanRoute(.capturesInbox)
            }
        }

        if host == "plan", let first = pathSegments.first {
            switch first.lowercased() {
            case "captures":
                return .openPlanRoute(.capturesInbox)
            case "habits":
                return .openPlanRoute(.habits)
            case "weekly-review":
                return .openPlanRoute(.weeklyReview)
            default:
                break
            }
        }

        if host == "insights", let first = pathSegments.first {
            switch first.lowercased() {
            case "monthly-review":
                return .openInsightsRoute(.monthlyReview)
            case "history":
                return .openInsightsRoute(.history)
            default:
                break
            }
        }

        if host == "overlay" || host == "command" || host == "compose" || host == "memory" || host == "search" {
            if let overlay = overlayRoute(host: host, pathSegments: pathSegments, query: query) {
                return .presentOverlay(overlay)
            }
        }

        return .genericExternalEntry(
            kind: "deeplink.\(host.isEmpty ? "unknown" : host)",
            payload: normalizedPayload(host: host, pathSegments: pathSegments, query: query)
        )
    }

    func route(fromNotification payload: AppNotificationRoutingPayload) -> AppExternalRoute {
        if let goalID = payload.values["goalID"], goalID.isEmpty == false {
            return .openGoalDetail(goalID: goalID)
        }
        if let tabRaw = payload.values["tab"]?.lowercased(),
           let tab = AppTab(rawValue: tabRaw) {
            return .openTab(tab)
        }
        if payload.action == "open-captures-inbox" || payload.values["surface"] == "captures-inbox" {
            return .openPlanRoute(.capturesInbox)
        }
        if let overlay = overlayRoute(values: payload.values, fallbackAction: payload.action, source: .notification) {
            return .presentOverlay(overlay)
        }
        return .genericExternalEntry(kind: "notification.\(payload.action)", payload: payload.values)
    }

    func route(fromWidget payload: AppWidgetRoutingPayload) -> AppExternalRoute {
        if let goalID = payload.values["goalID"], goalID.isEmpty == false {
            return .openGoalDetail(goalID: goalID)
        }
        if let tabRaw = payload.values["tab"]?.lowercased(),
           let tab = AppTab(rawValue: tabRaw) {
            return .openTab(tab)
        }
        if payload.action == "open-captures-inbox" || payload.values["surface"] == "captures-inbox" {
            return .openPlanRoute(.capturesInbox)
        }
        if let overlay = overlayRoute(values: payload.values, fallbackAction: payload.action, source: .widget) {
            return .presentOverlay(overlay)
        }
        return .genericExternalEntry(kind: "widget.\(payload.action)", payload: payload.values)
    }

    func deepLinkURL(for route: AppExternalRoute) -> URL? {
        switch route {
        case let .openTab(tab):
            return ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: tab.rawValue)
        case let .openToday(context):
            var components = URLComponents()
            components.scheme = "ambitions"
            components.host = "tab"
            components.path = "/today"
            components.queryItems = context == .standard ? nil : [URLQueryItem(name: "context", value: context.rawValue)]
            return components.url
        case let .openGoalDetail(goalID):
            return ExternalSurfaceActionPayload.deepLinkURL(surface: .goalDetail, goalID: goalID)
        case let .openPlanRoute(target):
            switch target {
            case .capturesInbox:
                return ExternalSurfaceActionPayload.deepLinkURL(surface: .capturesInbox)
            case .habits:
                return URL(string: "ambitions://plan/habits")
            case .weeklyReview:
                return URL(string: "ambitions://plan/weekly-review")
            }
        case let .openInsightsRoute(target):
            switch target {
            case .monthlyReview:
                return URL(string: "ambitions://insights/monthly-review")
            case .history:
                return URL(string: "ambitions://insights/history")
            }
        case let .presentOverlay(route):
            var components = URLComponents()
            components.scheme = "ambitions"
            components.host = "overlay"
            components.path = "/\(route.kind.rawValue)"

            var queryItems: [URLQueryItem] = []
            if let intent = route.intent {
                queryItems.append(URLQueryItem(name: "intent", value: intent.rawValue))
            }
            if route.query.isEmpty == false {
                queryItems.append(URLQueryItem(name: "q", value: route.query))
            }
            if let goalID = route.goalID {
                queryItems.append(URLQueryItem(name: "goalID", value: goalID))
            }
            if let captureID = route.captureID {
                queryItems.append(URLQueryItem(name: "captureID", value: captureID))
            }
            components.queryItems = queryItems.isEmpty ? nil : queryItems
            return components.url
        case let .genericExternalEntry(kind, payload):
            var components = URLComponents()
            components.scheme = "ambitions"
            components.host = "external"
            components.path = "/\(kind)"
            components.queryItems = payload
                .sorted { $0.key < $1.key }
                .map { URLQueryItem(name: $0.key, value: $0.value) }
            return components.url
        }
    }

    func notificationPayload(for route: AppExternalRoute, action: String) -> AppNotificationRoutingPayload {
        AppNotificationRoutingPayload(action: action, values: commandPayload(for: route, action: action))
    }

    func widgetPayload(for route: AppExternalRoute, action: String) -> AppWidgetRoutingPayload {
        AppWidgetRoutingPayload(action: action, values: commandPayload(for: route, action: action))
    }

    func routePayload(for route: AppExternalRoute) -> [String: String] {
        switch route {
        case let .openTab(tab):
            return ExternalSurfaceActionPayload.routePayload(surface: .tab, tab: tab.rawValue)
        case let .openToday(context):
            var values = ExternalSurfaceActionPayload.routePayload(surface: .tab, tab: AppTab.today.rawValue)
            values["context"] = context.rawValue
            return values
        case let .openGoalDetail(goalID):
            return ExternalSurfaceActionPayload.routePayload(
                surface: .goalDetail,
                goalID: goalID,
                tab: AppTab.goals.rawValue
            )
        case let .openPlanRoute(target):
            switch target {
            case .capturesInbox:
                return ExternalSurfaceActionPayload.routePayload(
                    surface: .capturesInbox,
                    tab: AppTab.captures.rawValue
                )
            case .habits:
                return [
                    ExternalSurfaceActionPayload.Key.surface: ExternalSurfacePayloadSurface.tab.rawValue,
                    ExternalSurfaceActionPayload.Key.tab: AppTab.plan.rawValue,
                    "subroute": target.rawValue
                ]
            case .weeklyReview:
                return [
                    ExternalSurfaceActionPayload.Key.surface: "weekly-review",
                    ExternalSurfaceActionPayload.Key.tab: AppTab.plan.rawValue
                ]
            }
        case let .openInsightsRoute(target):
            return [
                ExternalSurfaceActionPayload.Key.surface: target.rawValue,
                ExternalSurfaceActionPayload.Key.tab: AppTab.profile.rawValue
            ]
        case let .presentOverlay(route):
            var values: [String: String] = [
                ExternalSurfaceActionPayload.Key.surface: "overlay",
                "overlay": route.kind.rawValue,
                ExternalSurfaceActionPayload.Key.tab: AppTab.today.rawValue
            ]
            if let intent = route.intent {
                values["intent"] = intent.rawValue
            }
            if route.query.isEmpty == false {
                values["query"] = route.query
            }
            if let goalID = route.goalID {
                values["goalID"] = goalID
            }
            if let captureID = route.captureID {
                values["captureID"] = captureID
            }
            return values
        case let .genericExternalEntry(kind, payload):
            var values = payload
            values["surface"] = kind
            return values
        }
    }

    private func commandPayload(for route: AppExternalRoute, action: String) -> [String: String] {
        let actionName = ExternalSurfaceActionName(rawAction: action)
        switch route {
        case let .openTab(tab):
            return ExternalSurfaceActionPayload.commandPayload(
                action: actionName,
                surface: .tab,
                tab: tab.rawValue
            )
        case let .openToday(context):
            var values = routePayload(for: route)
            values[ExternalSurfaceActionPayload.Key.action] = actionName.rawValue
            values["context"] = context.rawValue
            return values
        case let .openGoalDetail(goalID):
            return ExternalSurfaceActionPayload.commandPayload(
                action: actionName,
                surface: .goalDetail,
                goalID: goalID,
                tab: AppTab.goals.rawValue
            )
        case let .openPlanRoute(target):
            switch target {
            case .capturesInbox:
                return ExternalSurfaceActionPayload.commandPayload(
                    action: actionName,
                    surface: .capturesInbox,
                    tab: AppTab.captures.rawValue
                )
            case .habits:
                var values = routePayload(for: route)
                values[ExternalSurfaceActionPayload.Key.action] = actionName.rawValue
                return values
            case .weeklyReview:
                var values = routePayload(for: route)
                values[ExternalSurfaceActionPayload.Key.action] = actionName.rawValue
                return values
            }
        case let .openInsightsRoute(target):
            var values = routePayload(for: route)
            values[ExternalSurfaceActionPayload.Key.action] = actionName.rawValue
            values["insightsRoute"] = target.rawValue
            return values
        case let .presentOverlay(overlay):
            var values = routePayload(for: route)
            values[ExternalSurfaceActionPayload.Key.action] = actionName.rawValue
            values["overlay"] = overlay.kind.rawValue
            return values
        case .genericExternalEntry:
            var values = routePayload(for: route)
            values[ExternalSurfaceActionPayload.Key.action] = actionName.rawValue
            return values
        }
    }

    private func normalizedPayload(
        host: String,
        pathSegments: [String],
        query: [String: String]
    ) -> [String: String] {
        var payload = query
        payload["host"] = host
        if pathSegments.isEmpty == false {
            payload["path"] = pathSegments.joined(separator: "/")
        }
        return payload
    }

    private func overlayRoute(
        host: String,
        pathSegments: [String],
        query: [String: String]
    ) -> ShellOverlayState? {
        let source: ShellCommandEntrySource = {
            if query["origin"] == ExternalSurfaceOrigin.appIntent.rawValue {
                return .appIntent
            }
            if query["origin"] == ExternalSurfaceOrigin.shareExtension.rawValue {
                return .shareExtension
            }
            return host == "compose" ? .appIntent : .deepLink
        }()
        let first = (pathSegments.first ?? host).lowercased()
        let intent = query["intent"].flatMap(ShellCommandIntent.init(rawValue:))

        switch first {
        case "quiet-command-sheet", "command":
            return .commandSheet(
                intent: intent,
                entrySource: source
            )
        case "memory-lens", "memory", "search":
            return .memoryLens(
                intent: intent ?? .memoryLens,
                entrySource: source,
                presentationContext: .recall,
                query: query["q"] ?? query["query"] ?? "",
                goalID: query["goalID"],
                captureID: query["captureID"]
            )
        case "create-goal", "goal":
            return .createGoal(entrySource: source)
        case "capture":
            return .commandSheet(
                intent: .quickCapture,
                entrySource: source,
                presentationContext: .quickCapture
            )
        default:
            return nil
        }
    }

    private func overlayRoute(
        values: [String: String],
        fallbackAction: String,
        source: ExternalActionSource
    ) -> ShellOverlayState? {
        let entrySource: ShellCommandEntrySource = {
            switch source {
            case .notification: .notification
            case .widget: .widget
            case .deepLink: .deepLink
            case .futureExternalPayload: .external
            }
        }()
        let intent = values["intent"].flatMap(ShellCommandIntent.init(rawValue:))
        let overlayName = (values["overlay"] ?? fallbackAction).lowercased()

        switch overlayName {
        case "quiet-command-sheet", "open-command", "command":
            return .commandSheet(intent: intent, entrySource: entrySource)
        case "memory-lens", "open-memory-lens", "memory":
            return .memoryLens(
                intent: intent ?? .memoryLens,
                entrySource: entrySource,
                presentationContext: .recall,
                query: values["query"] ?? "",
                goalID: values["goalID"],
                captureID: values["captureID"]
            )
        case "create-goal":
            return .createGoal(entrySource: entrySource)
        case "quick-capture", "capture":
            return .commandSheet(
                intent: .quickCapture,
                entrySource: entrySource,
                presentationContext: .quickCapture
            )
        default:
            return nil
        }
    }
}

@MainActor
protocol AppExternalRouting: AnyObject {
    func handleDeepLink(_ url: URL)
    func handleNotificationPayload(_ payload: AppNotificationRoutingPayload)
    func handleWidgetPayload(_ payload: AppWidgetRoutingPayload)
    func dispatch(_ route: AppExternalRoute, source: AppExternalRouteSource)
}

@MainActor
final class DefaultAppExternalRouter: AppExternalRouting {
    private let navigation: AppNavigationModel
    private let translator: AppExternalRouteTranslator

    init(
        navigation: AppNavigationModel,
        translator: AppExternalRouteTranslator = AppExternalRouteTranslator()
    ) {
        self.navigation = navigation
        self.translator = translator
    }

    func handleDeepLink(_ url: URL) {
        guard let route = translator.route(fromDeepLink: url) else { return }
        dispatch(route, source: translator.source(fromDeepLink: url))
    }

    func handleNotificationPayload(_ payload: AppNotificationRoutingPayload) {
        dispatch(translator.route(fromNotification: payload), source: .notificationAction)
    }

    func handleWidgetPayload(_ payload: AppWidgetRoutingPayload) {
        dispatch(translator.route(fromWidget: payload), source: .widgetAction)
    }

    func dispatch(_ route: AppExternalRoute, source: AppExternalRouteSource) {
        navigation.lastExternalRoute = route
        navigation.lastExternalRouteSource = source
        let entrySource = source.entrySource

        switch route {
        case let .openTab(tab):
            navigation.selectTab(tab)
            navigation.recordRoute(
                title: "Open \(tab.title)",
                source: entrySource,
                presentationContext: .recall,
                destination: .tab(tab),
                receiptBody: receiptBody(for: .tab(tab), source: entrySource)
            )
        case let .openToday(context):
            navigation.selectToday(entryContext: context)
            navigation.recordRoute(
                title: context == .standard ? "Open Today" : context.title,
                source: entrySource,
                presentationContext: context.presentationContext,
                destination: .tab(.today),
                receiptBody: receiptBody(for: .tab(.today), source: entrySource)
            )
        case let .openGoalDetail(goalID):
            navigation.openGoalDetail(goalID: goalID)
            navigation.recordRoute(
                title: "Open goal",
                source: entrySource,
                presentationContext: .recall,
                destination: .goal(goalID),
                receiptBody: receiptBody(for: .goal(goalID), source: entrySource)
            )
        case let .openPlanRoute(target):
            navigation.openPlanRoute(target)
            navigation.recordRoute(
                title: "Open \(ShellCommandDestination.planRoute(target).displayLabel)",
                source: entrySource,
                presentationContext: .plan,
                destination: .planRoute(target),
                receiptBody: receiptBody(for: .planRoute(target), source: entrySource)
            )
        case let .openInsightsRoute(target):
            navigation.openInsightsRoute(target)
            navigation.recordRoute(
                title: "Open \(ShellCommandDestination.insightsRoute(target).displayLabel)",
                source: entrySource,
                presentationContext: .recall,
                destination: .insightsRoute(target),
                receiptBody: receiptBody(for: .insightsRoute(target), source: entrySource)
            )
        case let .presentOverlay(route):
            navigation.presentOverlay(route)
        case .genericExternalEntry:
            navigation.fallbackExternalLanding()
            navigation.recordRoute(
                title: "External entry",
                source: entrySource,
                presentationContext: .recall,
                destination: .tab(.today),
                receiptBody: "Opened Today from \(entrySource.displayTitle) because the incoming route was not specific enough."
            )
        }
    }

    private func receiptBody(for destination: ShellCommandDestination, source: ShellCommandEntrySource) -> String {
        "Opened \(destination.displayLabel) from \(source.displayTitle) with source context preserved."
    }
}

private extension AppExternalRouteSource {
    var entrySource: ShellCommandEntrySource {
        switch self {
        case .deepLink: .deepLink
        case .notificationAction: .notification
        case .widgetAction: .widget
        case .liveActivity: .external
        case .shareExtension: .shareExtension
        case .appIntent: .appIntent
        }
    }
}

private extension TodayEntryContext {
    var title: String {
        switch self {
        case .standard: "Open Today"
        case .recovery: "Quick recovery"
        case .focus: "Quick focus"
        }
    }

    var presentationContext: ShellCommandPresentationContext {
        switch self {
        case .standard: .recall
        case .recovery: .recovery
        case .focus: .focus
        }
    }
}
