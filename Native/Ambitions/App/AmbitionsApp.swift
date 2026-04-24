import SwiftUI

@main
@MainActor
struct AmbitionsApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var bootstrapper = AppBootstrapper()

    init() {
        NotificationRuntime.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            LaunchGateView(bootstrapper: bootstrapper)
                .onOpenURL { url in
                    bootstrapper.handleDeepLink(url)
                }
                .onAppear {
                    NotificationRuntime.shared.bootstrapper = bootstrapper
                    bootstrapper.consumePendingExternalCreationsIfNeeded()
                    bootstrapper.consumePendingAppIntentLaunchIfNeeded()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    guard newPhase == .active else { return }
                    NotificationRuntime.shared.bootstrapper = bootstrapper
                    bootstrapper.consumePendingExternalCreationsIfNeeded()
                    bootstrapper.consumePendingAppIntentLaunchIfNeeded()
                }
        }
    }
}
