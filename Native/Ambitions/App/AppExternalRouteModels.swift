import Foundation

enum AppExternalRoute: Equatable, Sendable {
    case openTab(AmbitionsSurface)
    case openCaptureComposer
    case openToday(TodayEntryContext)
    case openGoalDetail(goalID: String)
    case openTimeRoute(TimeRouteTarget)
    case openYouRoute(YouRouteTarget)
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
