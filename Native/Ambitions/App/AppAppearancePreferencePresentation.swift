import AmbitionsDesignSystem
import SwiftUI

extension AppAppearancePreference {
    var themePreference: AmbitionThemePreference {
        switch self {
        case .system:
            return .system
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var preferredColorScheme: ColorScheme? {
        switch themePreference {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    func resolveTheme(
        systemColorScheme: ColorScheme,
        accentFamily: AmbitionAccentFamily
    ) -> AmbitionTheme {
        let systemMode: AmbitionThemeMode = systemColorScheme == .dark ? .dark : .light
        return .theme(
            for: themePreference.resolvedMode(systemMode: systemMode),
            accentFamily: accentFamily
        )
    }
}
