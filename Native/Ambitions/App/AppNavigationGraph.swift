import Foundation

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
            owningTab: {
                if case let .tab(tab) = entry.owner {
                    return tab
                }
                return .today
            }(),
            route: entry.canonicalRoute,
            presentation: entry.deepLinkTemplate,
            canOpenFromExternalSurface: entry.opensWithoutDeadEnd
        )
    }

    static func node(for route: AppExternalRoute) -> AppNavigationGraphNode? {
        nodes.first { $0.route == route }
    }
}
