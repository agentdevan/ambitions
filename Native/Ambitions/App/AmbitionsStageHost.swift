import AmbitionsDesignSystem
import SwiftUI

@MainActor
struct AmbitionsStageHost: View {
    private let dependencies: AppDependencies

    init(container: AppContainer) {
        dependencies = AppDependencies(container: container)
    }

    var body: some View {
        AmbitionsStage(
            container: dependencies.container,
            appFeatureFlags: dependencies.featureFlags
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Ambitions")
        .accessibilityIdentifier("app.stage-host")
    }
}
