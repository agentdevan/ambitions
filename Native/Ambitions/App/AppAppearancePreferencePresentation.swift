import AmbitionsDesignSystem
import SwiftUI

extension AppAppearancePreference {
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

    func resolveTheme(
        systemColorScheme: ColorScheme,
        accentFamily: AmbitionAccentFamily
    ) -> AmbitionTheme {
        switch self {
        case .system:
            return .theme(for: systemColorScheme == .dark ? .dark : .light, accentFamily: accentFamily)
        case .light:
            return .theme(for: .light, accentFamily: accentFamily)
        case .dark:
            return .theme(for: .dark, accentFamily: accentFamily)
        }
    }
}
