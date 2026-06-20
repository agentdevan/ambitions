import SwiftUI

@main
@MainActor
struct AmbitionsApp: App {
    @State private var bootstrapper = AppBootstrapper()

    init() {
        NotificationRuntime.shared.activate()
    }

    var body: some Scene {
        AmbitionsRootScene(bootstrapper: bootstrapper)
    }
}
