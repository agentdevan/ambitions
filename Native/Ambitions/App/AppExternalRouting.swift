import Foundation

@MainActor
protocol AppExternalRouting: AnyObject {
    func handleDeepLink(_ url: URL)
    func handleNotificationPayload(_ payload: AppNotificationRoutingPayload)
    func handleWidgetPayload(_ payload: AppWidgetRoutingPayload)
    func dispatch(_ route: AppExternalRoute, source: AppExternalRouteSource)
}

@MainActor
final class DefaultAppExternalRouter: AppExternalRouting {
    private let navigation: StageStore
    private let translator: AppExternalRouteTranslator

    init(
        navigation: StageStore,
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
        case let .openTimeRoute(target):
            navigation.openTimeRoute(target)
            navigation.recordRoute(
                title: "Open \(ShellCommandDestination.timeRoute(target).displayLabel)",
                source: entrySource,
                presentationContext: .time,
                destination: .timeRoute(target),
                receiptBody: receiptBody(for: .timeRoute(target), source: entrySource)
            )
        case .openCaptureComposer:
            navigation.openCaptureComposer(source: entrySource)
            return
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
        case .stepSession: "Step session"
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
