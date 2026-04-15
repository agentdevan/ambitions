import Foundation

struct AppSession: Sendable {
    enum BootstrapSource: String, Sendable {
        case live
        case preview
        case demo
    }

    let source: BootstrapSource
    let userDisplayName: String
    let initialTab: AppTab
    let launchedAt: Date
    let startupNote: String
}

struct AppPreferences: Sendable {
    let preferredTab: AppTab
    let userDisplayName: String
}
