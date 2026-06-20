import SwiftUI

@MainActor
struct AmbitionsRootScene: Scene {
    @Environment(\.scenePhase) private var scenePhase
    let bootstrapper: AppBootstrapper

    var body: some Scene {
        WindowGroup {
            LaunchGateView(bootstrapper: bootstrapper)
                .onOpenURL { url in
                    bootstrapper.handleDeepLink(url)
                }
                .onAppear {
                    reconcileActiveLaunchState()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    guard newPhase == .active else { return }
                    reconcileActiveLaunchState()
                }
        }
    }

    private func reconcileActiveLaunchState() {
        NotificationRuntime.shared.bootstrapper = bootstrapper
        bootstrapper.consumePendingExternalCreationsIfNeeded()
        bootstrapper.consumePendingAppIntentLaunchIfNeeded()
        bootstrapper.reconcileActiveLifecycle()
    }
}
