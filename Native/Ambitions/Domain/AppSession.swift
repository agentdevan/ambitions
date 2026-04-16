import AmbitionsDesignSystem
import Foundation
import SwiftUI

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

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    func resolveTheme(systemColorScheme: ColorScheme) -> AmbitionTheme {
        switch self {
        case .system:
            return systemColorScheme == .dark ? .dark : .light
        case .light:
            return .light
        case .dark:
            return .dark
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
    let initialTab: AppTab
    let appearancePreference: AppAppearancePreference
    let launchedAt: Date
    let startupNote: String
}

struct AppPreferences: Sendable {
    let preferredTab: AppTab
    let userDisplayName: String
    let appearancePreference: AppAppearancePreference
}
