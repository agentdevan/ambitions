import Foundation

enum AppExternalRoute: Equatable, Sendable {
    case openTab(AppTab)
    case openGoalDetail(goalID: String)
    case openPlanRoute(PlanRouteTarget)
    case openInsightsRoute(InsightsRouteTarget)
    case presentOverlay(ShellOverlayRoute)
    case genericExternalEntry(kind: String, payload: [String: String])
}

enum AppExternalRouteSource: String, Sendable {
    case deepLink
    case notificationAction
    case widgetAction
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
        return .genericExternalEntry(kind: "widget.\(payload.action)", payload: payload.values)
    }

    func deepLinkURL(for route: AppExternalRoute) -> URL? {
        switch route {
        case let .openTab(tab):
            return ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: tab.rawValue)
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
            return URL(string: "ambitions://overlay/\(route.rawValue)")
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
                    tab: AppTab.plan.rawValue
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
                ExternalSurfaceActionPayload.Key.tab: AppTab.insights.rawValue
            ]
        case let .presentOverlay(route):
            return [
                ExternalSurfaceActionPayload.Key.surface: "overlay",
                "overlay": route.rawValue,
                ExternalSurfaceActionPayload.Key.tab: AppTab.today.rawValue
            ]
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
                    tab: AppTab.plan.rawValue
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
            values["overlay"] = overlay.rawValue
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
        dispatch(route, source: .deepLink)
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

        switch route {
        case let .openTab(tab):
            navigation.selectTab(tab)
        case let .openGoalDetail(goalID):
            navigation.openGoalDetail(goalID: goalID)
        case let .openPlanRoute(target):
            navigation.openPlanRoute(target)
        case let .openInsightsRoute(target):
            navigation.openInsightsRoute(target)
        case let .presentOverlay(route):
            navigation.presentOverlay(route)
        case .genericExternalEntry:
            navigation.fallbackExternalLanding()
        }
    }
}
