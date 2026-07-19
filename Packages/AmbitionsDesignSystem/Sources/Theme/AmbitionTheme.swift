#if canImport(SwiftUI)
    import SwiftUI

    public enum AmbitionThemeMode: String, CaseIterable, Codable, Sendable {
        case dark
        case light
    }

    public enum AmbitionThemePreference: String, CaseIterable, Codable, Sendable, Identifiable {
        case system
        case light
        case dark

        public var id: String {
            rawValue
        }

        public var title: String {
            switch self {
            case .system:
                return "System"
            case .light:
                return "Light"
            case .dark:
                return "Dark"
            }
        }

        public func resolvedMode(systemMode: AmbitionThemeMode) -> AmbitionThemeMode {
            switch self {
            case .system:
                return systemMode
            case .light:
                return .light
            case .dark:
                return .dark
            }
        }
    }

    public enum AmbitionAccentFamily: String, CaseIterable, Codable, Sendable, Identifiable {
        case sage
        case blueGray
        case mutedGold
        case copper
        case sand

        public var id: String {
            rawValue
        }

        public var title: String {
            switch self {
            case .sage: "Sage"
            case .blueGray: "Blue Gray"
            case .mutedGold: "Muted Gold"
            case .copper: "Copper"
            case .sand: "Sand"
            }
        }
    }

    // Shared theme surface for Ambitions SwiftUI UI.
    //
    // Inject a theme at the app shell with `.ambitionTheme(theme)` and read it
    // inside reusable primitives with `@Environment(\.ambitionTheme)`.
#endif
