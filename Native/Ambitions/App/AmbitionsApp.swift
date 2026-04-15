import SwiftUI

@main
struct AmbitionsApp: App {
    @State private var bootstrapper = AppBootstrapper()

    var body: some Scene {
        WindowGroup {
            LaunchGateView(bootstrapper: bootstrapper)
                .onOpenURL { url in
                    bootstrapper.handleDeepLink(url)
                }
        }
    }
}
