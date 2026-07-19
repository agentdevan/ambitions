import Foundation

@MainActor
struct AppDependencies {
    let container: AppContainer
    let featureFlags: AppFeatureFlags

    init(
        container: AppContainer,
        featureFlags: AppFeatureFlags = .current
    ) {
        self.container = container
        self.featureFlags = featureFlags
    }

    var initialSurface: AmbitionsSurface {
        container.navigation.selectedTab
    }
}
