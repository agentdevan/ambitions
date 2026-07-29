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
            .title2.weight(.bold)
        case .truth:
            .title3.weight(.medium)
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
            : Color(red: 0.932, green: 0.938, blue: 0.939)
    }

    var relief: Color {
        colorScheme == .dark
            ? Color(red: 0.078, green: 0.085, blue: 0.096)
            : Color(red: 0.884, green: 0.896, blue: 0.899)
    }

    var inset: Color {
        colorScheme == .dark
            ? Color(red: 0.100, green: 0.107, blue: 0.120)
            : Color(red: 0.842, green: 0.858, blue: 0.862)
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

    var acceptedFoundation: Color {
        colorScheme == .dark
            ? Color(red: 0.150, green: 0.160, blue: 0.176)
            : Color(red: 0.770, green: 0.792, blue: 0.798)
    }

    var futurePossibility: Color {
        colorScheme == .dark
            ? Color(red: 0.112, green: 0.122, blue: 0.136)
            : Color(red: 0.823, green: 0.838, blue: 0.842)
    }

    var protectedBoundary: Color {
        colorScheme == .dark
            ? Color(red: 0.610, green: 0.555, blue: 0.425)
            : Color(red: 0.405, green: 0.350, blue: 0.250)
    }

    var opaqueChrome: Color {
        colorScheme == .dark
            ? Color(red: 0.125, green: 0.132, blue: 0.148)
            : Color(red: 0.865, green: 0.858, blue: 0.840)
    }

    var markerWidth: CGFloat { contrast == .increased ? 2.5 : 1.5 }
}

enum GoalsNativeCalibrationPursuitAnchorResolution {
    case compact
    case selected
    case focused
}

struct GoalsNativeCalibrationPursuitAnchor: View {
    let goalID: String
    let resolution: GoalsNativeCalibrationPursuitAnchorResolution
    let palette: GoalsNativeCalibrationPalette

    private var width: CGFloat {
        switch resolution {
        case .compact: 28
        case .selected: 34
        case .focused: 42
        }
    }

    private var height: CGFloat {
        switch resolution {
        case .compact: 34
        case .selected: 42
        case .focused: 50
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: resolution == .focused ? 5 : 4) {
            Capsule()
                .fill(resolution == .compact ? palette.secondaryInk : palette.primaryInk)
                .frame(width: width, height: resolution == .focused ? 5 : 4)
                .overlay(alignment: .leading) {
                    if resolution != .compact {
                        Circle()
                            .fill(palette.accent)
                            .frame(width: resolution == .focused ? 9 : 7)
                    }
                }
            Capsule()
                .fill(palette.acceptedFoundation)
                .frame(width: width * 0.72, height: resolution == .focused ? 6 : 5)
            Capsule()
                .fill(palette.acceptedFoundation.opacity(0.72))
                .frame(width: width * 0.46, height: resolution == .focused ? 7 : 6)
        }
        .frame(width: width, height: height, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Pursuit anchor")
        .accessibilityValue(resolution == .compact ? "Accepted Goal" : "Selected Goal")
        .accessibilityIdentifier("gnc-goal-anchor-\(goalID)")
    }
}

struct GoalsNativeCalibrationProofFoundation: View {
    let moments: [String]
    let palette: GoalsNativeCalibrationPalette
    let expanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: expanded ? 9 : 5) {
            ForEach(Array(moments.enumerated()), id: \.offset) { index, moment in
                HStack(spacing: 10) {
                    Capsule()
                        .fill(palette.acceptedFoundation.opacity(1 - Double(index) * 0.16))
                        .frame(width: expanded ? 26 : CGFloat(30 - index * 5), height: expanded ? 5 : 4)
                        .accessibilityHidden(true)
                    if expanded {
                        Text(moment)
                            .font(.subheadline)
                            .foregroundStyle(palette.secondaryInk)
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Recorded support. \(moments.joined(separator: ", "))")
        .accessibilityIdentifier("gnc-proof-foundation")
    }
}

struct GoalsNativeCalibrationLifeAreaPostureSignal: View {
    let lifeAreaID: String
    let kind: GoalsNativeCalibrationLifeAreaPostureKind
    let palette: GoalsNativeCalibrationPalette

    var body: some View {
        Group {
            switch kind {
            case .activeConstruction:
                VStack(alignment: .leading, spacing: 5) {
                    Capsule().fill(palette.primaryInk).frame(width: 42, height: 4)
                    Capsule().fill(palette.acceptedFoundation).frame(width: 30, height: 6)
                    Capsule().fill(palette.acceptedFoundation.opacity(0.68)).frame(width: 18, height: 7)
                }
            case .protectedBalance:
                HStack(spacing: 5) {
                    Capsule().fill(palette.protectedBoundary).frame(width: 4, height: 28)
                    Capsule().fill(palette.acceptedFoundation).frame(width: 25, height: 9)
                    Capsule().fill(palette.protectedBoundary).frame(width: 4, height: 28)
                }
            case .containedWork:
                VStack(alignment: .trailing, spacing: 4) {
                    Capsule().fill(palette.acceptedFoundation.opacity(0.62)).frame(width: 42, height: 4)
                    Capsule().fill(palette.primaryInk).frame(width: 28, height: 5)
                    Capsule().fill(palette.acceptedFoundation).frame(width: 18, height: 5)
                }
            }
        }
        .frame(width: 46, height: 40)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Life Area posture")
        .accessibilityIdentifier("gnc-life-area-posture-\(lifeAreaID)")
    }
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
