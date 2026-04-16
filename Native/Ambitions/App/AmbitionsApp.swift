import SwiftUI

@main
@MainActor
struct AmbitionsApp: App {
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
                }
        }
    }
}
