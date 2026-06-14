import Foundation

enum AppExternalRoute: Equatable, Sendable {
    case openTab(AppTab)
    case openToday(TodayEntryContext)
    case openGoalDetail(goalID: String)
    case openTimeRoute(TimeRouteTarget)
    case openYouRoute(YouRouteTarget)
    case presentOverlay(ShellOverlayState)
    case genericExternalEntry(kind: String, payload: [String: String])
}


struct AppDeepLinkRegistryEntry: Equatable, Identifiable, Sendable {
    enum ObjectKind: String, Sendable {
        case rootTab
        case todayContext
        case goal
        case timeRoute
        case youRoute
        case overlay
    }

    let id: String
    let objectKind: ObjectKind
    let owningTab: AppTab
    let canonicalRoute: AppExternalRoute
    let deepLinkTemplate: String
    let allowedSources: [AppExternalRouteSource]
    let privacyBoundary: String

    var opensWithoutDeadEnd: Bool {
        switch canonicalRoute {
        case let .openTab(tab):
            tab.canonicalTopLevelTab.isCanonicalTopLevel
        case let .openToday(context):
            context == .standard || owningTab == .today
        case let .openGoalDetail(goalID):
            owningTab == .goals && goalID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        case let .openTimeRoute(target):
            owningTab == (target == .captureInbox ? .today : .time)
        case .openYouRoute:
            owningTab == .you
        case .presentOverlay:
            owningTab == .today
        case .genericExternalEntry:
            false
        }
    }
}

enum AppDeepLinkRegistry {
    static let externalObjectSources: [AppExternalRouteSource] = [
        .deepLink,
        .notificationAction,
        .widgetAction,
        .liveActivity,
        .appIntent,
        .spotlight,
        .handoff,
        .relaunch
    ]

    static let entries: [AppDeepLinkRegistryEntry] = [
        AppDeepLinkRegistryEntry(
            id: "today.root",
            objectKind: .rootTab,
            owningTab: .today,
            canonicalRoute: .openTab(.today),
            deepLinkTemplate: "ambitions://tab/today",
            allowedSources: externalObjectSources,
            privacyBoundary: "Root route only; carries no private object identifier."
        ),
        AppDeepLinkRegistryEntry(
            id: "today.focus",
            objectKind: .todayContext,
            owningTab: .today,
            canonicalRoute: .openToday(.focus),
            deepLinkTemplate: "ambitions://tab/today?context=focus",
            allowedSources: externalObjectSources,
            privacyBoundary: "Context route only; opens Start here posture without mutating a step."
        ),
        AppDeepLinkRegistryEntry(
            id: "today.recovery",
            objectKind: .todayContext,
            owningTab: .today,
            canonicalRoute: .openToday(.recovery),
            deepLinkTemplate: "ambitions://tab/today?context=recovery",
            allowedSources: [.deepLink, .notificationAction, .widgetAction, .liveActivity, .appIntent, .relaunch],
            privacyBoundary: "Recovery route only; closure still requires in-app confirmation."
        ),
        AppDeepLinkRegistryEntry(
            id: "goals.root",
            objectKind: .rootTab,
            owningTab: .goals,
            canonicalRoute: .openTab(.goals),
            deepLinkTemplate: "ambitions://tab/goals",
            allowedSources: externalObjectSources,
            privacyBoundary: "Root route only; carries no private goal identifier."
        ),
        AppDeepLinkRegistryEntry(
            id: "goals.detail",
            objectKind: .goal,
            owningTab: .goals,
            canonicalRoute: .openGoalDetail(goalID: "preview-goal"),
            deepLinkTemplate: "ambitions://goal/{goalID}",
            allowedSources: externalObjectSources,
            privacyBoundary: "Requires an explicit goal identifier; unknown or missing IDs fall back instead of inventing a route."
        ),
        AppDeepLinkRegistryEntry(
            id: "time.root",
            objectKind: .rootTab,
            owningTab: .time,
            canonicalRoute: .openTab(.time),
            deepLinkTemplate: "ambitions://tab/time",
            allowedSources: externalObjectSources,
            privacyBoundary: "Root route only; opens LifeShape Field without schedule export."
        ),
        AppDeepLinkRegistryEntry(
            id: "time.habits",
            objectKind: .timeRoute,
            owningTab: .time,
            canonicalRoute: .openTimeRoute(.habits),
            deepLinkTemplate: "ambitions://time/habits",
            allowedSources: externalObjectSources,
            privacyBoundary: "Compatibility route under Time; no streak or score payload is supported."
        ),
        AppDeepLinkRegistryEntry(
            id: "time.weeklyReview",
            objectKind: .timeRoute,
            owningTab: .time,
            canonicalRoute: .openTimeRoute(.weeklyReview),
            deepLinkTemplate: "ambitions://time/weekly-review",
            allowedSources: externalObjectSources,
            privacyBoundary: "Review route under Time; does not claim completion or mutate history."
        ),
        AppDeepLinkRegistryEntry(
            id: "motion.root",
            objectKind: .rootTab,
            owningTab: .motion,
            canonicalRoute: .openTab(.motion),
            deepLinkTemplate: "ambitions://tab/motion",
            allowedSources: externalObjectSources,
            privacyBoundary: "Root route only; no analytics feed or score payload is supported."
        ),
        AppDeepLinkRegistryEntry(
            id: "you.root",
            objectKind: .rootTab,
            owningTab: .you,
            canonicalRoute: .openTab(.you),
            deepLinkTemplate: "ambitions://tab/you",
            allowedSources: externalObjectSources,
            privacyBoundary: "Root route only; opens user-owned controls without exposing profile data."
        ),
        AppDeepLinkRegistryEntry(
            id: "you.history",
            objectKind: .youRoute,
            owningTab: .you,
            canonicalRoute: .openYouRoute(.history),
            deepLinkTemplate: "ambitions://you/history",
            allowedSources: externalObjectSources,
            privacyBoundary: "History support route remains in-app and local; no export is implied."
        ),
        AppDeepLinkRegistryEntry(
            id: "you.monthlyReview",
            objectKind: .youRoute,
            owningTab: .you,
            canonicalRoute: .openYouRoute(.monthlyReview),
            deepLinkTemplate: "ambitions://you/monthly-review",
            allowedSources: externalObjectSources,
            privacyBoundary: "Review support route remains in-app and local; no readiness claim is implied."
        ),
        AppDeepLinkRegistryEntry(
            id: "capture.composer",
            objectKind: .overlay,
            owningTab: .today,
            canonicalRoute: .presentOverlay(.commandSheet(intent: .quickCapture, entrySource: .external, presentationContext: .quickCapture)),
            deepLinkTemplate: "ambitions://overlay/quiet-command-sheet?intent=quick_capture",
            allowedSources: externalObjectSources,
            privacyBoundary: "Opens the composer seam only after invocation; Capture is not a top-level tab."
        )
    ]

    static func validationIssues(translator: AppExternalRouteTranslator = AppExternalRouteTranslator()) -> [String] {
        var issues: [String] = []
        let ids = entries.map(\.id)
        if Set(ids).count != ids.count {
            issues.append("Deep-link registry entries must have unique IDs.")
        }
        for entry in entries {
            if entry.owningTab.isCanonicalTopLevel == false {
                issues.append("\(entry.id) must resolve to a canonical top-level owner.")
            }
            if entry.opensWithoutDeadEnd == false {
                issues.append("\(entry.id) does not resolve to an addressable in-app destination.")
            }
            if entry.allowedSources.isEmpty {
                issues.append("\(entry.id) must declare at least one supported external source.")
            }
            if entry.privacyBoundary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append("\(entry.id) must declare a no-claim privacy boundary.")
            }
            if translator.deepLinkURL(for: entry.canonicalRoute) == nil {
                issues.append("\(entry.id) must generate a canonical deep link.")
            }
        }
        return issues
    }
}

struct AppNavigationGraphNode: Equatable, Identifiable, Sendable {
    let id: String
    let owningTab: AppTab
    let route: AppExternalRoute
    let presentation: String
    let canOpenFromExternalSurface: Bool
}

enum AppNavigationGraph {
    static let nodes: [AppNavigationGraphNode] = AppDeepLinkRegistry.entries.map { entry in
        AppNavigationGraphNode(
            id: entry.id,
            owningTab: entry.owningTab,
            route: entry.canonicalRoute,
            presentation: entry.deepLinkTemplate,
            canOpenFromExternalSurface: entry.opensWithoutDeadEnd
        )
    }

    static func node(for route: AppExternalRoute) -> AppNavigationGraphNode? {
        nodes.first { $0.route == route }
    }
}

enum AppExternalRouteSource: String, Sendable {
    case deepLink
    case notificationAction
    case widgetAction
    case liveActivity
    case shareExtension
    case appIntent
    case spotlight
    case handoff
    case background
    case relaunch
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
            if let rawTab {
                let context = query["context"].flatMap(TodayEntryContext.init(rawValue:))
                return LegacyIARouteCompatibility.externalRoute(forRawTab: rawTab, todayContext: context)
            }
        }

        if host == "goal" || host == "goals" {
            if let goalID = pathSegments.first ?? query["id"] ?? query["goalID"], goalID.isEmpty == false {
                return .openGoalDetail(goalID: goalID)
            }
        }

        if host == "captures" || host == "inbox" {
            if pathSegments.isEmpty || pathSegments.first == "inbox" {
                return .openTimeRoute(.captureInbox)
            }
        }

        if (host == "plan" || host == "time"), let first = pathSegments.first {
            switch first.lowercased() {
            case "captures":
                return .openTimeRoute(.captureInbox)
            case "habits":
                return .openTimeRoute(.habits)
            case "weekly-review":
                return .openTimeRoute(.weeklyReview)
            default:
                break
            }
        }

        if (host == "you" || host == "insights"), let first = pathSegments.first {
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
        if let tabRaw = payload.values["tab"]?.lowercased() {
            let context = payload.values["context"].flatMap(TodayEntryContext.init(rawValue:))
            if let route = LegacyIARouteCompatibility.externalRoute(forRawTab: tabRaw, todayContext: context) {
                return route
            }
        }
        if payload.action == "open-captures-inbox" || payload.values["surface"] == "captures-inbox" {
            return .openTimeRoute(.captureInbox)
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
        if let tabRaw = payload.values["tab"]?.lowercased() {
            let context = payload.values["context"].flatMap(TodayEntryContext.init(rawValue:))
            if let route = LegacyIARouteCompatibility.externalRoute(forRawTab: tabRaw, todayContext: context) {
                return route
            }
        }
        if payload.action == "open-captures-inbox" || payload.values["surface"] == "captures-inbox" {
            return .openTimeRoute(.captureInbox)
        }
        if let overlay = overlayRoute(values: payload.values, fallbackAction: payload.action, source: .widget) {
            return .presentOverlay(overlay)
        }
        return .genericExternalEntry(kind: "widget.\(payload.action)", payload: payload.values)
    }

    func deepLinkURL(for route: AppExternalRoute) -> URL? {
        switch route {
        case let .openTab(tab):
            if tab == .capture {
                return deepLinkURL(for: .openTimeRoute(.captureInbox))
            }
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
        case let .openTimeRoute(target):
            switch target {
            case .captureInbox:
                return ExternalSurfaceActionPayload.deepLinkURL(surface: .captureInbox)
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
            return token.captureID == nil ? .openTab(fallbackTab) : .openTimeRoute(.captureInbox)
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

    func routePayload(for route: AppExternalRoute) -> [String: String] {
        switch route {
        case let .openTab(tab):
            if tab == .capture {
                return routePayload(for: .openTimeRoute(.captureInbox))
            }
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
        case let .openTimeRoute(target):
            switch target {
            case .captureInbox:
                return ExternalSurfaceActionPayload.routePayload(
                    surface: .captureInbox,
                    tab: AppTab.today.rawValue
                )
            case .habits:
                return [
                    ExternalSurfaceActionPayload.Key.surface: ExternalSurfacePayloadSurface.tab.rawValue,
                    ExternalSurfaceActionPayload.Key.tab: AppTab.time.rawValue,
                    "subroute": target.rawValue
                ]
            case .weeklyReview:
                return [
                    ExternalSurfaceActionPayload.Key.surface: "weekly-review",
                    ExternalSurfaceActionPayload.Key.tab: AppTab.time.rawValue
                ]
            }
        case let .openYouRoute(target):
            return [
                ExternalSurfaceActionPayload.Key.surface: target.rawValue,
                ExternalSurfaceActionPayload.Key.tab: AppTab.you.rawValue
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
            if tab == .capture {
                return commandPayload(for: .openTimeRoute(.captureInbox), action: action)
            }
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
        case let .openTimeRoute(target):
            switch target {
            case .captureInbox:
                return ExternalSurfaceActionPayload.commandPayload(
                    action: actionName,
                    surface: .captureInbox,
                    tab: AppTab.today.rawValue
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
        case let .openYouRoute(target):
            var values = routePayload(for: route)
            values[ExternalSurfaceActionPayload.Key.action] = actionName.rawValue
            values["youRoute"] = target.rawValue
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
            case .appIntent: .appIntent
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
            if tab == .capture {
                navigation.presentCaptureCompatibilityRoute(source: entrySource)
                return
            }
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
        case let .openTimeRoute(target):
            if target == .captureInbox {
                navigation.openCapturesInbox(source: entrySource)
                return
            }
            navigation.openTimeRoute(target)
            navigation.recordRoute(
                title: "Open \(ShellCommandDestination.timeRoute(target).displayLabel)",
                source: entrySource,
                presentationContext: .time,
                destination: .timeRoute(target),
                receiptBody: receiptBody(for: .timeRoute(target), source: entrySource)
            )
        case let .openYouRoute(target):
            navigation.openYouRoute(target)
            navigation.recordRoute(
                title: "Open \(ShellCommandDestination.youRoute(target).displayLabel)",
                source: entrySource,
                presentationContext: .recall,
                destination: .youRoute(target),
                receiptBody: receiptBody(for: .youRoute(target), source: entrySource)
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
        case .spotlight: .external
        case .handoff: .external
        case .background: .external
        case .relaunch: .external
        }
    }
}

private extension TodayEntryContext {
    var title: String {
        switch self {
        case .standard: "Open Today"
        case .recovery: "Quick recovery"
        case .stepSession: "Step Session"
        case .focus: "Quick focus"
        }
    }

    var presentationContext: ShellCommandPresentationContext {
        switch self {
        case .standard: .recall
        case .recovery: .recovery
        case .stepSession: .focus
        case .focus: .focus
        }
    }
}
