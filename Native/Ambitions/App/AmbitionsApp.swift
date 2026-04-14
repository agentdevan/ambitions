import SwiftUI

@main
struct AmbitionsApp: App {
    @State private var bootstrapper = AppBootstrapper()

    var body: some Scene {
        WindowGroup {
            LaunchGateView(bootstrapper: bootstrapper)
                .preferredColorScheme(.dark)
        }
    }
}
