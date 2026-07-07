import AmbitionsDesignSystem
import Foundation

enum AppAppearancePreference: String, CaseIterable, Codable, Sendable {
    case system
    case light
    case dark

    var title: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
}

struct AppSession: Sendable {
    enum BootstrapSource: String, Codable, Sendable {
        case live
        case preview
        case demo
    }

    let source: BootstrapSource
    let userDisplayName: String
    let initialTab: AmbitionsSurface
    let appearancePreference: AppAppearancePreference
    let accentFamily: AmbitionAccentFamily
    let launchedAt: Date
    let startupNote: String
    let shouldShowOnboarding: Bool
}

struct AppPreferences: Sendable {
    let preferredTab: AmbitionsSurface
    let userDisplayName: String
    let appearancePreference: AppAppearancePreference
    let accentFamily: AmbitionAccentFamily
}
