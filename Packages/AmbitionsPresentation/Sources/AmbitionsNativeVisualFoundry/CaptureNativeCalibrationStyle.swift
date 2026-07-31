import SwiftUI

#if os(iOS)
import UIKit
#endif

struct CaptureNativeCalibrationPalette {
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

    var editorRelief: Color {
        colorScheme == .dark
            ? Color(red: 0.072, green: 0.078, blue: 0.088)
            : Color(red: 0.914, green: 0.916, blue: 0.910)
    }

    var relief: Color {
        colorScheme == .dark
            ? Color(red: 0.082, green: 0.088, blue: 0.102)
            : Color(red: 0.898, green: 0.900, blue: 0.894)
    }

    var actionRegion: Color {
        colorScheme == .dark
            ? Color(red: 0.061, green: 0.067, blue: 0.077)
            : Color(red: 0.924, green: 0.926, blue: 0.920)
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

    var separator: Color {
        primary.opacity(contrast == .increased ? 0.48 : colorScheme == .dark ? 0.20 : 0.14)
    }

    var accent: Color {
        colorScheme == .dark
            ? Color(red: 0.665, green: 0.610, blue: 0.900)
            : Color(red: 0.355, green: 0.275, blue: 0.625)
    }

    var onAccent: Color {
        colorScheme == .dark
            ? Color(red: 0.075, green: 0.060, blue: 0.118)
            : Color.white
    }

    var reliefEdge: Color {
        primary.opacity(contrast == .increased ? 0.66 : 0.34)
    }
}

extension View {
    @ViewBuilder
    func captureNativeCalibrationHideNavigationBar() -> some View {
        #if os(iOS)
        toolbar(.hidden, for: .navigationBar)
        #else
        self
        #endif
    }

    @ViewBuilder
    func captureNativeCalibrationInlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    @ViewBuilder
    func captureNativeCalibrationNavigationBarBackground(_ color: Color) -> some View {
        #if os(iOS)
        toolbarBackground(color, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        #else
        self
        #endif
    }

    @ViewBuilder
    func captureNativeCalibrationNeverDismissesKeyboard() -> some View {
        #if os(iOS)
        scrollDismissesKeyboard(.never)
        #else
        self
        #endif
    }

    func captureNativeCalibrationPrimaryAction() -> some View {
        modifier(CaptureNativeCalibrationPrimaryActionModifier())
    }

    func captureNativeCalibrationSecondaryAction() -> some View {
        modifier(CaptureNativeCalibrationSecondaryActionModifier())
    }
}

private struct CaptureNativeCalibrationPrimaryActionModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast

    private var palette: CaptureNativeCalibrationPalette {
        CaptureNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundStyle(palette.onAccent)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 50)
            .padding(.horizontal, 14)
            .background(
                palette.accent,
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .contentShape(Rectangle())
    }
}

private struct CaptureNativeCalibrationSecondaryActionModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast

    private var palette: CaptureNativeCalibrationPalette {
        CaptureNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    func body(content: Content) -> some View {
        content
            .font(.body.weight(.semibold))
            .foregroundStyle(palette.accent)
            .multilineTextAlignment(.center)
            .frame(minHeight: 44)
            .padding(.horizontal, 10)
            .contentShape(Rectangle())
    }
}
