import Foundation

enum AppExternalRoute: Equatable, Sendable {
    case openTab(AppTab)
    case openGoalDetail(goalID: String)
    case openCapturesInbox
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
                return .openCapturesInbox
            }
        }

        return .genericExternalEntry(
            kind: "deeplink.\(host.isEmpty ? "unknown" : host)",
            payload: normalizedPayload(host: host, pathSegments: pathSegments, query: query)
        )
    }

    func route(fromNotification payload: AppNotificationRoutingPayload) -> AppExternalRoute {
        if let tabRaw = payload.values["tab"]?.lowercased(),
           let tab = AppTab(rawValue: tabRaw) {
            return .openTab(tab)
        }
        if let goalID = payload.values["goalID"], goalID.isEmpty == false {
            return .openGoalDetail(goalID: goalID)
        }
        if payload.action == "open-captures-inbox" || payload.values["surface"] == "captures-inbox" {
            return .openCapturesInbox
        }
        return .genericExternalEntry(kind: "notification.\(payload.action)", payload: payload.values)
    }

    func route(fromWidget payload: AppWidgetRoutingPayload) -> AppExternalRoute {
        if let tabRaw = payload.values["tab"]?.lowercased(),
           let tab = AppTab(rawValue: tabRaw) {
            return .openTab(tab)
        }
        if let goalID = payload.values["goalID"], goalID.isEmpty == false {
            return .openGoalDetail(goalID: goalID)
        }
        if payload.action == "open-captures-inbox" || payload.values["surface"] == "captures-inbox" {
            return .openCapturesInbox
        }
        return .genericExternalEntry(kind: "widget.\(payload.action)", payload: payload.values)
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
            navigation.selectedTab = tab
        case let .openGoalDetail(goalID):
            navigation.openGoalDetail(goalID: goalID)
        case .openCapturesInbox:
            navigation.selectedTab = .captures
        case .genericExternalEntry:
            navigation.selectedTab = .today
        }
    }
}
