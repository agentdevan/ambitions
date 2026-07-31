import SwiftUI

struct SearchNativeCalibrationPalette {
    let colorScheme: ColorScheme
    let contrast: ColorSchemeContrast

    var canvas: Color {
        colorScheme == .dark
            ? Color(red: 0.055, green: 0.061, blue: 0.070)
            : Color(red: 0.936, green: 0.938, blue: 0.932)
    }

    var field: Color {
        colorScheme == .dark
            ? Color(red: 0.095, green: 0.101, blue: 0.114)
            : Color(red: 0.890, green: 0.892, blue: 0.886)
    }

    var primary: Color {
        colorScheme == .dark
            ? Color(red: 0.952, green: 0.948, blue: 0.934)
            : Color(red: 0.105, green: 0.108, blue: 0.116)
    }

    var secondary: Color {
        colorScheme == .dark
            ? Color(red: 0.720, green: 0.718, blue: 0.704)
            : Color(red: 0.300, green: 0.303, blue: 0.310)
    }

    var tertiary: Color {
        colorScheme == .dark
            ? Color(red: 0.570, green: 0.568, blue: 0.558)
            : Color(red: 0.430, green: 0.428, blue: 0.418)
    }

    var separator: Color {
        primary.opacity(contrast == .increased ? 0.48 : colorScheme == .dark ? 0.20 : 0.14)
    }

    var accent: Color {
        colorScheme == .dark
            ? Color(red: 0.665, green: 0.610, blue: 0.900)
            : Color(red: 0.355, green: 0.275, blue: 0.625)
    }
}

extension View {
    @ViewBuilder
    func searchNativeCalibrationHideNavigationBar() -> some View {
        #if os(iOS)
        toolbar(.hidden, for: .navigationBar)
        #else
        self
        #endif
    }

    @ViewBuilder
    func searchNativeCalibrationInlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    @ViewBuilder
    func searchNativeCalibrationNeverDismissesKeyboard() -> some View {
        #if os(iOS)
        scrollDismissesKeyboard(.never)
        #else
        self
        #endif
    }
}
