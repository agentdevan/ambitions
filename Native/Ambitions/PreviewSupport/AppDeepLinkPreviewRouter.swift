import Foundation

struct AppDeepLinkPreviewRoute: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let route: AppExternalRoute
    let source: AppExternalRouteSource
    let expectedTab: AmbitionsSurface
    let privacyBoundary: String
}

@MainActor
struct AppDeepLinkPreviewRouter {
    let navigation: AppNavigationModel
    let router: DefaultAppExternalRouter

    init(initialTab: AmbitionsSurface = .today) {
        let navigation = AppNavigationModel(selectedTab: initialTab)
        self.navigation = navigation
        router = DefaultAppExternalRouter(navigation: navigation)
    }

    func open(_ previewRoute: AppDeepLinkPreviewRoute) {
        router.dispatch(previewRoute.route, source: previewRoute.source)
    }

    func openRegistryEntry(id: String, source: AppExternalRouteSource = .widgetAction) {
        guard let entry = AppDeepLinkRegistry.entries.first(where: { $0.id == id }) else {
            router.dispatch(.genericExternalEntry(kind: "preview.missing-route", payload: ["id": id]), source: source)
            return
        }
        router.dispatch(entry.canonicalRoute, source: source)
    }
}

enum AppDeepLinkPreviewRoutes {
    static let widgetGoal = AppDeepLinkPreviewRoute(
        id: "preview.widget.goal",
        title: "Widget opens goal",
        route: .openGoalDetail(goalID: "preview-goal"),
        source: .widgetAction,
        expectedTab: .goals,
        privacyBoundary: "Preview goal identifier is preview and stays in-app."
    )

    static let notificationRecovery = AppDeepLinkPreviewRoute(
        id: "preview.notification.recovery",
        title: "Notification opens recovery",
        route: .openToday(.recovery),
        source: .notificationAction,
        expectedTab: .today,
        privacyBoundary: "Preview recovery opens confirmation context only; it does not complete a step."
    )

    static let shortcutCapture = AppDeepLinkPreviewRoute(
        id: "preview.shortcut.capture",
        title: "Shortcut opens Capture composer",
        route: .presentOverlay(.commandSheet(intent: .quickCapture, entrySource: .appIntent, presentationContext: .quickCapture)),
        source: .appIntent,
        expectedTab: .today,
        privacyBoundary: "Preview shortcut invokes the composer seam without making Capture a tab."
    )

    static let all: [AppDeepLinkPreviewRoute] = [
        widgetGoal,
        notificationRecovery,
        shortcutCapture
    ]
}
