import Foundation

extension AppExternalRouteTranslator {
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
        case let .openTimeRoute(target):
            switch target {
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
        case .openCaptureComposer:
            return routePayload(
                for: .presentOverlay(
                    .commandSheet(
                        intent: .quickCapture,
                        entrySource: .deepLink,
                        presentationContext: .quickCapture
                    )
                )
            )
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

    func commandPayload(for route: AppExternalRoute, action: String) -> [String: String] {
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
        case let .openTimeRoute(target):
            switch target {
            case .habits:
                var values = routePayload(for: route)
                values[ExternalSurfaceActionPayload.Key.action] = actionName.rawValue
                return values
            case .weeklyReview:
                var values = routePayload(for: route)
                values[ExternalSurfaceActionPayload.Key.action] = actionName.rawValue
                return values
            }
        case .openCaptureComposer:
            var values = routePayload(for: route)
            values[ExternalSurfaceActionPayload.Key.action] = actionName.rawValue
            return values
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

    func normalizedPayload(
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
