import SwiftUI

enum TodayOpenContinuityNodeKind: String, CaseIterable {
    case current
    case proposed
    case saving
    case settled
    case interrupted
    case protected
    case fixed
    case external
    case openLane

    var nonColorShapeLabel: String {
        switch self {
        case .current:
            "Open circle"
        case .proposed:
            "Paired offset circles"
        case .saving:
            "Active connector"
        case .settled:
            "Resolved inset circle"
        case .interrupted:
            "Retained broken seam"
        case .protected:
            "Shielded square with boundary bracket"
        case .fixed:
            "Anchored diamond"
        case .external:
            "Open square"
        case .openLane:
            "Parallel open-lane marks"
        }
    }
}

struct TodayOpenContinuityMotionPolicy {
    let reduceMotion: Bool

    var stateAnimation: Animation? {
        reduceMotion ? nil : .easeInOut(duration: 0.22)
    }
}

struct TodayOpenContinuityPalette {
    let colorScheme: ColorScheme
    let contrast: ColorSchemeContrast

    var canvas: Color {
        colorScheme == .dark
            ? Color(red: 0.070, green: 0.073, blue: 0.081)
            : Color(red: 0.945, green: 0.937, blue: 0.910)
    }

    var canvasElevated: Color {
        colorScheme == .dark
            ? Color(red: 0.105, green: 0.108, blue: 0.118)
            : Color(red: 0.918, green: 0.908, blue: 0.880)
    }

    var objectRelief: Color {
        colorScheme == .dark
            ? Color(red: 0.105, green: 0.108, blue: 0.121)
            : Color(red: 0.915, green: 0.906, blue: 0.879)
    }

    var objectInset: Color {
        colorScheme == .dark
            ? Color(red: 0.086, green: 0.090, blue: 0.101)
            : Color(red: 0.938, green: 0.928, blue: 0.900)
    }

    var labelPrimary: Color {
        colorScheme == .dark
            ? Color(red: 0.95, green: 0.94, blue: 0.91)
            : Color(red: 0.11, green: 0.11, blue: 0.12)
    }

    var labelSecondary: Color {
        colorScheme == .dark
            ? Color(red: 0.74, green: 0.73, blue: 0.70)
            : Color(red: 0.30, green: 0.29, blue: 0.28)
    }

    var labelTertiary: Color {
        colorScheme == .dark
            ? Color(red: 0.59, green: 0.58, blue: 0.56)
            : Color(red: 0.43, green: 0.42, blue: 0.40)
    }

    var separator: Color {
        labelPrimary.opacity(contrast == .increased ? 0.36 : colorScheme == .dark ? 0.20 : 0.14)
    }

    var ambitionsAccent: Color {
        colorScheme == .dark
            ? Color(red: 0.42, green: 0.40, blue: 0.67)
            : Color(red: 0.30, green: 0.27, blue: 0.55)
    }

    var ambitionsAccentMuted: Color {
        colorScheme == .dark
            ? Color(red: 0.69, green: 0.67, blue: 0.91)
            : Color(red: 0.35, green: 0.30, blue: 0.60)
    }

    var currentTruth: Color { objectInset }

    var proposedTruth: Color {
        colorScheme == .dark
            ? Color(red: 0.135, green: 0.126, blue: 0.188)
            : Color(red: 0.875, green: 0.852, blue: 0.925)
    }

    var settledTruth: Color {
        colorScheme == .dark
            ? Color(red: 0.100, green: 0.132, blue: 0.121)
            : Color(red: 0.870, green: 0.900, blue: 0.854)
    }

    var interruptedTruth: Color {
        colorScheme == .dark
            ? Color(red: 0.151, green: 0.126, blue: 0.112)
            : Color(red: 0.920, green: 0.875, blue: 0.792)
    }

    var protectedState: Color {
        colorScheme == .dark
            ? Color(red: 0.58, green: 0.76, blue: 0.66)
            : Color(red: 0.20, green: 0.45, blue: 0.31)
    }

    var fixedState: Color { ambitionsAccentMuted }

    var externalState: Color { labelSecondary }

    var interruptedState: Color {
        colorScheme == .dark
            ? Color(red: 0.82, green: 0.61, blue: 0.47)
            : Color(red: 0.53, green: 0.30, blue: 0.17)
    }

    var actionLabel: Color { .white }

    var reliefShadow: Color {
        colorScheme == .dark ? .black.opacity(0.20) : .black.opacity(0.08)
    }
}

enum TodayOpenContinuityTypographyRole {
    case objectIdentity
    case state
    case relationship
    case metadata
    case action

    var font: Font {
        switch self {
        case .objectIdentity:
            .title2.weight(.semibold)
        case .state:
            .body
        case .relationship:
            .subheadline
        case .metadata:
            .footnote
        case .action:
            .body.weight(.semibold)
        }
    }
}

struct TodayOpenContinuityPrimaryActionStyle: ButtonStyle {
    let palette: TodayOpenContinuityPalette

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TodayOpenContinuityTypographyRole.action.font)
            .foregroundStyle(palette.actionLabel)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 44)
            .padding(.horizontal, 16)
            .background {
                actionShape
                    .fill(palette.ambitionsAccent.opacity(isEnabled ? 1 : 0.42))
            }
            .overlay {
                if palette.contrast == .increased {
                    actionShape
                        .stroke(palette.labelPrimary.opacity(0.88), lineWidth: 1.5)
                }
            }
            .opacity(configuration.isPressed ? 0.78 : 1)
            .scaleEffect(reduceMotion ? 1 : configuration.isPressed ? 0.985 : 1)
            .contentShape(Rectangle())
    }

    private var actionShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: 12,
            bottomLeadingRadius: 4,
            bottomTrailingRadius: 12,
            topTrailingRadius: 4,
            style: .continuous
        )
    }
}

#if DEBUG
private struct TodayOpenContinuityGrammarPreview: View {
    let forcedContrast: ColorSchemeContrast?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor

    init(forcedContrast: ColorSchemeContrast? = nil) {
        self.forcedContrast = forcedContrast
    }

    private var palette: TodayOpenContinuityPalette {
        TodayOpenContinuityPalette(
            colorScheme: colorScheme,
            contrast: forcedContrast ?? contrast
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Open Continuity Field")
                    .font(TodayOpenContinuityTypographyRole.objectIdentity.font)
                    .foregroundStyle(palette.labelPrimary)

                if differentiateWithoutColor {
                    Label("Non-color distinctions active", systemImage: "circle.dashed")
                        .font(TodayOpenContinuityTypographyRole.metadata.font)
                        .foregroundStyle(palette.labelSecondary)
                }

                ForEach(TodayOpenContinuityNodeKind.allCases, id: \.self) { kind in
                    HStack(spacing: 12) {
                        TodayOpenContinuitySpine(
                            kind: kind,
                            palette: palette,
                            extendsBefore: false,
                            extendsAfter: false
                        )
                        .frame(height: 44)

                        Text(kind.nonColorShapeLabel)
                            .font(TodayOpenContinuityTypographyRole.relationship.font)
                            .foregroundStyle(palette.labelPrimary)
                    }
                }

                Button("Continue") {}
                    .buttonStyle(TodayOpenContinuityPrimaryActionStyle(palette: palette))
            }
            .padding(24)
        }
        .background(palette.canvas)
        .accessibilityValue(differentiateWithoutColor ? "Non-color distinctions active" : "")
    }
}

#Preview("B02 Grammar — Light") {
    TodayOpenContinuityGrammarPreview()
        .preferredColorScheme(.light)
}

#Preview("B02 Grammar — Dark") {
    TodayOpenContinuityGrammarPreview()
        .preferredColorScheme(.dark)
}

#Preview("B02 Grammar — Increased Contrast") {
    TodayOpenContinuityGrammarPreview(forcedContrast: .increased)
        .preferredColorScheme(.dark)
}

#Preview("B02 Grammar — Differentiate Without Color") {
    TodayOpenContinuityGrammarPreview()
        .preferredColorScheme(.dark)
        .environment(\._accessibilityDifferentiateWithoutColor, true)
}

#Preview("B02 Grammar — Dynamic Type") {
    TodayOpenContinuityGrammarPreview()
        .preferredColorScheme(.dark)
        .dynamicTypeSize(.accessibility3)
}
#endif
