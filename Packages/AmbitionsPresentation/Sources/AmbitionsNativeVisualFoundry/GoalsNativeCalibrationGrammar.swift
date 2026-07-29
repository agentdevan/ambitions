import SwiftUI

private struct GoalsNativeCalibrationForceReduceMotionKey: EnvironmentKey {
    static let defaultValue = false
}

private struct GoalsNativeCalibrationForceReduceTransparencyKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var goalsNativeCalibrationForceReduceMotion: Bool {
        get { self[GoalsNativeCalibrationForceReduceMotionKey.self] }
        set { self[GoalsNativeCalibrationForceReduceMotionKey.self] = newValue }
    }

    var goalsNativeForceOpaqueChrome: Bool {
        get { self[GoalsNativeCalibrationForceReduceTransparencyKey.self] }
        set { self[GoalsNativeCalibrationForceReduceTransparencyKey.self] = newValue }
    }
}

public extension View {
    func goalsNativeCalibrationAccessibilityOverrides(
        reduceMotion: Bool = false,
        reduceTransparency: Bool = false
    ) -> some View {
        environment(\.goalsNativeCalibrationForceReduceMotion, reduceMotion)
            .environment(\.goalsNativeForceOpaqueChrome, reduceTransparency)
    }
}

enum GoalsNativeCalibrationTypographyRole {
    case objectIdentity
    case truth
    case relationship
    case metadata
    case action

    var font: Font {
        switch self {
        case .objectIdentity:
            .title2.weight(.semibold)
        case .truth:
            .body.weight(.medium)
        case .relationship:
            .body
        case .metadata:
            .subheadline
        case .action:
            .headline
        }
    }
}

struct GoalsNativeCalibrationPalette {
    let colorScheme: ColorScheme
    let contrast: ColorSchemeContrast

    var canvas: Color {
        colorScheme == .dark
            ? Color(red: 0.055, green: 0.061, blue: 0.070)
            : Color(red: 0.948, green: 0.943, blue: 0.925)
    }

    var relief: Color {
        colorScheme == .dark
            ? Color(red: 0.078, green: 0.085, blue: 0.096)
            : Color(red: 0.918, green: 0.911, blue: 0.891)
    }

    var inset: Color {
        colorScheme == .dark
            ? Color(red: 0.100, green: 0.107, blue: 0.120)
            : Color(red: 0.895, green: 0.887, blue: 0.866)
    }

    var primaryInk: Color {
        colorScheme == .dark
            ? Color(red: 0.952, green: 0.948, blue: 0.934)
            : Color(red: 0.105, green: 0.108, blue: 0.116)
    }

    var secondaryInk: Color {
        colorScheme == .dark
            ? Color(red: 0.720, green: 0.718, blue: 0.704)
            : Color(red: 0.300, green: 0.303, blue: 0.310)
    }

    var tertiaryInk: Color {
        colorScheme == .dark
            ? Color(red: 0.570, green: 0.568, blue: 0.558)
            : Color(red: 0.430, green: 0.428, blue: 0.418)
    }

    var separator: Color {
        primaryInk.opacity(contrast == .increased ? 0.48 : colorScheme == .dark ? 0.22 : 0.16)
    }

    var accent: Color {
        colorScheme == .dark
            ? Color(red: 0.665, green: 0.610, blue: 0.900)
            : Color(red: 0.355, green: 0.275, blue: 0.625)
    }

    var accentFill: Color {
        colorScheme == .dark
            ? Color(red: 0.385, green: 0.295, blue: 0.650)
            : Color(red: 0.325, green: 0.245, blue: 0.590)
    }

    var opaqueChrome: Color {
        colorScheme == .dark
            ? Color(red: 0.125, green: 0.132, blue: 0.148)
            : Color(red: 0.865, green: 0.858, blue: 0.840)
    }

    var markerWidth: CGFloat { contrast == .increased ? 2.5 : 1.5 }
}

enum GoalsNativeCalibrationMarkerKind {
    case lifeArea
    case selectedGoal
    case compactGoal
    case lens
    case proof
}

enum GoalsNativeCalibrationGoalSeamEmphasis {
    case quiet
    case selected
    case focused
}

struct GoalsNativeCalibrationGoalSeam: View {
    let palette: GoalsNativeCalibrationPalette
    let emphasis: GoalsNativeCalibrationGoalSeamEmphasis

    var body: some View {
        VStack(spacing: 0) {
            Circle()
                .strokeBorder(
                    emphasis == .quiet ? palette.secondaryInk : palette.primaryInk,
                    lineWidth: palette.markerWidth
                )
                .background {
                    if emphasis != .quiet {
                        Circle().fill(palette.accent).padding(5)
                    }
                }
                .frame(width: emphasis == .focused ? 24 : 20, height: emphasis == .focused ? 24 : 20)

            Rectangle()
                .fill(emphasis == .quiet ? palette.separator : palette.primaryInk.opacity(0.42))
                .frame(width: palette.markerWidth, height: emphasis == .focused ? 54 : 34)
        }
        .frame(width: 28)
        .accessibilityHidden(true)
    }
}

struct GoalsNativeCalibrationMarker: View {
    let kind: GoalsNativeCalibrationMarkerKind
    let palette: GoalsNativeCalibrationPalette

    var body: some View {
        Group {
            switch kind {
            case .lifeArea:
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .strokeBorder(palette.secondaryInk, lineWidth: palette.markerWidth)
                    .frame(width: 19, height: 19)
            case .selectedGoal:
                Circle()
                    .strokeBorder(palette.accent, lineWidth: palette.markerWidth)
                    .frame(width: 20, height: 20)
                    .overlay {
                        Circle().fill(palette.accent).frame(width: 6, height: 6)
                    }
            case .compactGoal:
                Circle()
                    .strokeBorder(palette.secondaryInk, lineWidth: palette.markerWidth)
                    .frame(width: 14, height: 14)
            case .lens:
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .strokeBorder(palette.accent, lineWidth: palette.markerWidth)
                    .frame(width: 19, height: 19)
                    .overlay {
                        Circle().fill(palette.accent).frame(width: 5, height: 5)
                    }
            case .proof:
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(palette.secondaryInk)
            }
        }
        .frame(width: 28, height: 28)
        .accessibilityHidden(true)
    }
}

struct GoalsNativeCalibrationNavigationButtonStyle: ButtonStyle {
    let palette: GoalsNativeCalibrationPalette
    var isProminent = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(GoalsNativeCalibrationTypographyRole.action.font)
            .foregroundStyle(isProminent ? Color.white : palette.primaryInk)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
            .padding(.horizontal, 15)
            .background(
                isProminent ? palette.accentFill : palette.inset,
                in: RoundedRectangle(cornerRadius: isProminent ? 12 : 8, style: .continuous)
            )
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(reduceMotion ? 1 : configuration.isPressed ? 0.985 : 1)
            .contentShape(Rectangle())
    }
}

struct GoalsNativeCalibrationOpenRelief<Content: View>: View {
    let palette: GoalsNativeCalibrationPalette
    let content: Content

    init(
        palette: GoalsNativeCalibrationPalette,
        @ViewBuilder content: () -> Content
    ) {
        self.palette = palette
        self.content = content()
    }

    var body: some View {
        content
            .padding(.vertical, 15)
            .padding(.leading, 18)
            .padding(.trailing, 12)
            .background(palette.relief)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(palette.accent)
                    .frame(width: 2)
                    .padding(.vertical, 8)
            }
    }
}

struct GoalsNativeCalibrationFunctionalChrome<Content: View>: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.goalsNativeForceOpaqueChrome) private var forceReduceTransparency

    let palette: GoalsNativeCalibrationPalette
    let content: Content

    init(
        palette: GoalsNativeCalibrationPalette,
        @ViewBuilder content: () -> Content
    ) {
        self.palette = palette
        self.content = content()
    }

    var body: some View {
        content
            .background {
                if reduceTransparency || forceReduceTransparency {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(palette.opaqueChrome)
                } else {
                    nativeGlass
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(palette.separator, lineWidth: 1)
            }
    }

    @ViewBuilder
    private var nativeGlass: some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(palette.opaqueChrome.opacity(0.82))
                .glassEffect(
                    .regular.tint(palette.opaqueChrome.opacity(0.34)).interactive(),
                    in: RoundedRectangle(cornerRadius: 13, style: .continuous)
                )
        } else {
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(palette.opaqueChrome)
        }
        #else
        RoundedRectangle(cornerRadius: 13, style: .continuous)
            .fill(palette.opaqueChrome)
        #endif
    }
}
