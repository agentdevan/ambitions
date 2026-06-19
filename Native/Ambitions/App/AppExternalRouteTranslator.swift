import Foundation

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
        case ExternalSurfaceOrigin.spotlight.rawValue:
            return .spotlight
        case ExternalSurfaceOrigin.handoff.rawValue:
            return .handoff
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
            if let rawTab, let tab = AppTab(rawValue: rawTab) {
                let context = query["context"].flatMap(TodayEntryContext.init(rawValue:))
                if tab == .today, let context, context != .standard {
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

        if host == "time", let first = pathSegments.first {
            switch first.lowercased() {
            case "habits":
                return .openTimeRoute(.habits)
            case "weekly-review":
                return .openTimeRoute(.weeklyReview)
            default:
                break
            }
        }

        if host == "you", let first = pathSegments.first {
            switch first.lowercased() {
            case "monthly-review":
                return .openYouRoute(.monthlyReview)
            case "history":
                return .openYouRoute(.history)
            default:
                break
            }
        }

        if host == "overlay" || host == "command" || host == "compose" || host == "memory" || host == "search" {
            if isCaptureComposerOverlay(host: host, pathSegments: pathSegments, query: query) {
                return .openCaptureComposer
            }
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
        if payload.action == "complete" {
            return .openToday(.recovery)
        }
        if let goalID = payload.values["goalID"], goalID.isEmpty == false {
            return .openGoalDetail(goalID: goalID)
        }
        if isCaptureComposerPayload(values: payload.values, fallbackAction: payload.action) {
            return .openCaptureComposer
        }
        if let tabRaw = payload.values["tab"]?.lowercased() {
            let context = payload.values["context"].flatMap(TodayEntryContext.init(rawValue:))
            if let tab = AppTab(rawValue: tabRaw) {
                if tab == .today, let context, context != .standard {
                    return .openToday(context)
                }
                return .openTab(tab)
            }
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
        if isCaptureComposerPayload(values: payload.values, fallbackAction: payload.action) {
            return .openCaptureComposer
        }
        if let tabRaw = payload.values["tab"]?.lowercased() {
            let context = payload.values["context"].flatMap(TodayEntryContext.init(rawValue:))
            if let tab = AppTab(rawValue: tabRaw) {
                if tab == .today, let context, context != .standard {
                    return .openToday(context)
                }
                return .openTab(tab)
            }
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
        case .openCaptureComposer:
            return deepLinkURL(
                for: .presentOverlay(
                    .commandSheet(
                        intent: .quickCapture,
                        entrySource: .deepLink,
                        presentationContext: .quickCapture
                    )
                )
            )
        case let .openToday(context):
            var components = URLComponents()
            components.scheme = "ambitions"
            components.host = "tab"
            components.path = "/today"
            components.queryItems = context == .standard ? nil : [URLQueryItem(name: "context", value: context.rawValue)]
            return components.url
        case let .openGoalDetail(goalID):
            return ExternalSurfaceActionPayload.deepLinkURL(surface: .goalDetail, goalID: goalID)
        case let .openTimeRoute(target):
            switch target {
            case .habits:
                return URL(string: "ambitions://time/habits")
            case .weeklyReview:
                return URL(string: "ambitions://time/weekly-review")
            }
        case let .openYouRoute(target):
            switch target {
            case .monthlyReview:
                return URL(string: "ambitions://you/monthly-review")
            case .history:
                return URL(string: "ambitions://you/history")
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

    func route(fromContinuation token: ExternalObjectContinuationToken) -> AppExternalRoute {
        let fallbackTab = (AppTab(rawValue: token.root.rawValue) ?? .today).canonicalTopLevelTab
        guard token.metadataClass == .exactReopen else {
            return .openTab(fallbackTab)
        }
        switch token.kind {
        case .goal:
            return token.goalID.map { .openGoalDetail(goalID: $0) } ?? .openTab(fallbackTab)
        case .currentStep:
            return token.goalID.map { .openGoalDetail(goalID: $0) } ?? .openTab(fallbackTab)
        case .receipt:
            if let receiptID = token.receiptID {
                return .presentOverlay(
                    .memoryLens(
                        intent: .memoryLens,
                        entrySource: .external,
                        presentationContext: .recall,
                        query: "receipt:\(receiptID)"
                    )
                )
            }
            return .openTab(fallbackTab)
        case .capture:
            return token.captureID == nil ? .openTab(fallbackTab) : .openCaptureComposer
        }
    }

    func routePayload(for token: ExternalObjectContinuationToken) -> [String: String] {
        var payload = token.routePayload
        payload[ExternalSurfaceActionPayload.Key.surface] = token.root.rawValue
        return payload
    }

    func deepLinkURL(for token: ExternalObjectContinuationToken) -> URL? {
        token.routeURL(origin: .spotlight)
    }

    func notificationPayload(for route: AppExternalRoute, action: String) -> AppNotificationRoutingPayload {
        AppNotificationRoutingPayload(action: action, values: commandPayload(for: route, action: action))
    }

    func widgetPayload(for route: AppExternalRoute, action: String) -> AppWidgetRoutingPayload {
        AppWidgetRoutingPayload(action: action, values: commandPayload(for: route, action: action))
    }
}
