#if canImport(SwiftUI)
import SwiftUI

struct AmbitionThemeKey: EnvironmentKey {
    static let defaultValue: AmbitionTheme = .light
}

public extension EnvironmentValues {
    var ambitionTheme: AmbitionTheme {
        get { self[AmbitionThemeKey.self] }
        set { self[AmbitionThemeKey.self] = newValue }
    }
}

/// Applies the Ambitions theme to a subtree.
public struct AmbitionThemeModifier: ViewModifier {
    let theme: AmbitionTheme

    public init(theme: AmbitionTheme) {
        self.theme = theme
    }

    public func body(content: Content) -> some View {
        content
            .environment(\.ambitionTheme, theme)
            .tint(theme.colors.accentPrimary)
            .foregroundStyle(theme.colors.textPrimary)
            .background(theme.colors.canvas.ignoresSafeArea())
    }
}

public extension View {
    /// Injects a shared Ambitions theme into the current view subtree.
    func ambitionTheme(_ theme: AmbitionTheme) -> some View {
        modifier(AmbitionThemeModifier(theme: theme))
    }
}
#endif
