import SwiftUI

enum TodayVitalitySurfaceClass: CaseIterable {
    case openPlane
    case openRelief
    case functionalChrome

    var isOpaque: Bool {
        self != .functionalChrome
    }

    var allowsLiquidGlass: Bool {
        self == .functionalChrome
    }
}

enum TodayVitalityChromeTreatment: Equatable {
    case nativeGlass
    case opaque
}

enum TodayVitalityTypographyRole: CaseIterable {
    case objectIdentity
    case stateTruth
    case relationship
    case metadata
    case action

    var semanticName: String {
        switch self {
        case .objectIdentity:
            "Object identity"
        case .stateTruth:
            "State truth"
        case .relationship:
            "Relationship"
        case .metadata:
            "Metadata"
        case .action:
            "Action"
        }
    }

    var font: Font {
        switch self {
        case .objectIdentity:
            .title.weight(.semibold)
        case .stateTruth:
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

enum TodayVitalityNodeGeometry: String, CaseIterable {
    case openRingWithStableCenter
    case elapsedDot
    case pairedOffsetRings
    case activeConnector
    case resolvedDoubleRing
    case retainedBrokenRing
    case boundedShield
    case anchoredDiamond
    case openSquare
    case dashedOpenRing

    var accessibilityLabel: String {
        switch self {
        case .openRingWithStableCenter:
            "Open ring with stable center"
        case .elapsedDot:
            "Elapsed dot"
        case .pairedOffsetRings:
            "Paired offset rings"
        case .activeConnector:
            "Active connector"
        case .resolvedDoubleRing:
            "Resolved double ring"
        case .retainedBrokenRing:
            "Retained broken ring"
        case .boundedShield:
            "Bounded shield"
        case .anchoredDiamond:
            "Anchored diamond"
        case .openSquare:
            "Open square"
        case .dashedOpenRing:
            "Dashed open ring"
        }
    }
}

enum TodayVitalityNodeKind: String, CaseIterable {
    case current
    case elapsed
    case proposed
    case saving
    case settled
    case interrupted
    case protected
    case fixed
    case external
    case open

    var geometry: TodayVitalityNodeGeometry {
        switch self {
        case .current:
            .openRingWithStableCenter
        case .elapsed:
            .elapsedDot
        case .proposed:
            .pairedOffsetRings
        case .saving:
            .activeConnector
        case .settled:
            .resolvedDoubleRing
        case .interrupted:
            .retainedBrokenRing
        case .protected:
            .boundedShield
        case .fixed:
            .anchoredDiamond
        case .external:
            .openSquare
        case .open:
            .dashedOpenRing
        }
    }

    var nonColorShapeLabel: String {
        geometry.accessibilityLabel
    }
}

enum TodayVitalitySeamRole: String, CaseIterable {
    case neutral
    case violetProposal
    case mossSettlement
    case amberInterruption
}

enum TodayVitalitySeamGeometry: String, CaseIterable {
    case stableLine
    case pairedLine
    case resolvedDoubleLine
    case retainedBrokenLine
}

enum TodayVitalityTruthKind: String, CaseIterable {
    case current
    case proposed
    case settled
    case interrupted

    var seamRole: TodayVitalitySeamRole {
        switch self {
        case .current:
            .neutral
        case .proposed:
            .violetProposal
        case .settled:
            .mossSettlement
        case .interrupted:
            .amberInterruption
        }
    }

    var seamGeometry: TodayVitalitySeamGeometry {
        switch self {
        case .current:
            .stableLine
        case .proposed:
            .pairedLine
        case .settled:
            .resolvedDoubleLine
        case .interrupted:
            .retainedBrokenLine
        }
    }
}

enum TodayVitalityActionRole: CaseIterable {
    case continuation
    case outcomeSelection
    case commitment
    case secondary
    case navigationDisclosure

    var purposeLabel: String {
        switch self {
        case .continuation:
            "Continue"
        case .outcomeSelection:
            "Outcome selection"
        case .commitment:
            "Consequential commitment"
        case .secondary:
            "Secondary cancellation"
        case .navigationDisclosure:
            "Navigation and disclosure"
        }
    }

    var isCommitment: Bool {
        self == .commitment
    }
}

struct TodayVitalityPalette {
    let colorScheme: ColorScheme
    let contrast: ColorSchemeContrast
    let differentiateWithoutColor: Bool
    let reduceTransparency: Bool

    var chromeTreatment: TodayVitalityChromeTreatment {
        reduceTransparency ? .opaque : .nativeGlass
    }

    var nodeStrokeWidth: CGFloat {
        contrast == .increased ? 2.5 : 1.5
    }

    var separatorStrokeWidth: CGFloat {
        contrast == .increased ? 1.5 : 1
    }

    var canvas: Color {
        colorScheme == .dark
            ? Color(red: 0.055, green: 0.061, blue: 0.070)
            : Color(red: 0.948, green: 0.943, blue: 0.925)
    }

    var canvasElevated: Color {
        colorScheme == .dark
            ? Color(red: 0.083, green: 0.090, blue: 0.101)
            : Color(red: 0.916, green: 0.910, blue: 0.890)
    }

    var objectRelief: Color {
        colorScheme == .dark
            ? Color(red: 0.073, green: 0.080, blue: 0.091)
            : Color(red: 0.927, green: 0.921, blue: 0.902)
    }

    var objectInset: Color {
        colorScheme == .dark
            ? Color(red: 0.097, green: 0.104, blue: 0.116)
            : Color(red: 0.896, green: 0.890, blue: 0.871)
    }

    var labelPrimary: Color {
        colorScheme == .dark
            ? Color(red: 0.952, green: 0.948, blue: 0.934)
            : Color(red: 0.105, green: 0.108, blue: 0.116)
    }

    var labelSecondary: Color {
        colorScheme == .dark
            ? Color(red: 0.720, green: 0.718, blue: 0.704)
            : Color(red: 0.300, green: 0.303, blue: 0.310)
    }

    var labelTertiary: Color {
        colorScheme == .dark
            ? Color(red: 0.570, green: 0.568, blue: 0.558)
            : Color(red: 0.430, green: 0.428, blue: 0.418)
    }

    var separator: Color {
        labelPrimary.opacity(contrast == .increased ? 0.48 : colorScheme == .dark ? 0.22 : 0.16)
    }

    var ambitionsAccent: Color {
        colorScheme == .dark
            ? Color(red: 0.445, green: 0.375, blue: 0.770)
            : Color(red: 0.325, green: 0.245, blue: 0.590)
    }

    var ambitionsAccentMuted: Color {
        colorScheme == .dark
            ? Color(red: 0.665, green: 0.610, blue: 0.900)
            : Color(red: 0.420, green: 0.345, blue: 0.660)
    }

    var settledState: Color {
        colorScheme == .dark
            ? Color(red: 0.500, green: 0.685, blue: 0.545)
            : Color(red: 0.235, green: 0.440, blue: 0.285)
    }

    var interruptedState: Color {
        colorScheme == .dark
            ? Color(red: 0.790, green: 0.590, blue: 0.390)
            : Color(red: 0.535, green: 0.310, blue: 0.125)
    }

    var protectedState: Color {
        colorScheme == .dark
            ? Color(red: 0.730, green: 0.630, blue: 0.455)
            : Color(red: 0.455, green: 0.330, blue: 0.155)
    }

    var fixedState: Color {
        colorScheme == .dark
            ? Color(red: 0.450, green: 0.590, blue: 0.720)
            : Color(red: 0.240, green: 0.405, blue: 0.535)
    }

    var opaqueChrome: Color {
        colorScheme == .dark
            ? Color(red: 0.125, green: 0.132, blue: 0.148)
            : Color(red: 0.865, green: 0.858, blue: 0.840)
    }

    var actionInk: Color {
        .white
    }

    func nodeColor(for kind: TodayVitalityNodeKind) -> Color {
        switch kind {
        case .current, .external, .open:
            labelSecondary
        case .elapsed:
            labelTertiary
        case .proposed, .saving:
            ambitionsAccentMuted
        case .settled:
            settledState
        case .interrupted:
            interruptedState
        case .protected:
            protectedState
        case .fixed:
            fixedState
        }
    }

    func seamColor(for kind: TodayVitalityTruthKind) -> Color {
        switch kind.seamRole {
        case .neutral:
            labelSecondary
        case .violetProposal:
            ambitionsAccentMuted
        case .mossSettlement:
            settledState
        case .amberInterruption:
            interruptedState
        }
    }
}

struct TodayVitalityNode: View {
    let kind: TodayVitalityNodeKind
    let palette: TodayVitalityPalette

    var body: some View {
        node
            .frame(width: 28, height: 28)
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var node: some View {
        let color = palette.nodeColor(for: kind)
        let lineWidth = palette.nodeStrokeWidth

        switch kind.geometry {
        case .openRingWithStableCenter:
            Circle()
                .strokeBorder(color, lineWidth: lineWidth)
                .frame(width: 19, height: 19)
                .overlay {
                    Circle()
                        .fill(color)
                        .frame(width: 5, height: 5)
                }
        case .elapsedDot:
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
        case .pairedOffsetRings:
            ZStack {
                Circle()
                    .strokeBorder(color, lineWidth: lineWidth)
                    .frame(width: 13, height: 13)
                    .offset(x: -4, y: 3)
                Circle()
                    .strokeBorder(color, lineWidth: lineWidth)
                    .frame(width: 13, height: 13)
                    .offset(x: 4, y: -3)
            }
        case .activeConnector:
            ZStack {
                Capsule()
                    .fill(color)
                    .frame(width: lineWidth + 1, height: 26)
                Circle()
                    .fill(palette.canvas)
                    .frame(width: 10, height: 10)
                    .overlay {
                        Circle().stroke(color, lineWidth: lineWidth)
                    }
            }
        case .resolvedDoubleRing:
            Circle()
                .strokeBorder(color, lineWidth: lineWidth)
                .frame(width: 19, height: 19)
                .overlay {
                    Circle()
                        .strokeBorder(color, lineWidth: lineWidth)
                        .frame(width: 9, height: 9)
                }
        case .retainedBrokenRing:
            ZStack {
                Circle()
                    .trim(from: 0.05, to: 0.42)
                    .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-25))
                Circle()
                    .trim(from: 0.55, to: 0.92)
                    .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-25))
            }
            .frame(width: 19, height: 19)
        case .boundedShield:
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .strokeBorder(color, lineWidth: lineWidth)
                .frame(width: 22, height: 22)
                .overlay {
                    Image(systemName: "shield.fill")
                        .imageScale(.small)
                        .fontWeight(.semibold)
                        .foregroundStyle(color)
                }
        case .anchoredDiamond:
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .strokeBorder(color, lineWidth: lineWidth)
                .frame(width: 15, height: 15)
                .rotationEffect(.degrees(45))
                .overlay {
                    Circle()
                        .fill(color)
                        .frame(width: 4, height: 4)
                }
        case .openSquare:
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .strokeBorder(color, lineWidth: lineWidth)
                .frame(width: 17, height: 17)
        case .dashedOpenRing:
            Circle()
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round,
                        dash: [3, 3]
                    )
                )
                .frame(width: 20, height: 20)
        }
    }
}

private struct TodayVitalityTruthSeam: View {
    let kind: TodayVitalityTruthKind
    let palette: TodayVitalityPalette

    var body: some View {
        let color = palette.seamColor(for: kind)
        let width = palette.separatorStrokeWidth + 1

        switch kind.seamGeometry {
        case .stableLine:
            Capsule()
                .fill(color)
                .frame(width: width)
        case .pairedLine:
            HStack(spacing: 3) {
                Capsule().fill(color).frame(width: width)
                Capsule().fill(color).frame(width: width)
            }
        case .resolvedDoubleLine:
            ZStack {
                Capsule().fill(color).frame(width: width + 3)
                Capsule().fill(palette.objectRelief).frame(width: width)
            }
        case .retainedBrokenLine:
            VStack(spacing: 7) {
                Capsule().fill(color)
                Capsule().fill(color)
            }
            .frame(width: width)
        }
    }
}

struct TodayVitalityOpenRelief<Content: View>: View {
    let palette: TodayVitalityPalette
    let truthKind: TodayVitalityTruthKind
    let content: Content

    init(
        palette: TodayVitalityPalette,
        truthKind: TodayVitalityTruthKind,
        @ViewBuilder content: () -> Content
    ) {
        self.palette = palette
        self.truthKind = truthKind
        self.content = content()
    }

    var body: some View {
        content
            .padding(.vertical, 14)
            .padding(.leading, 18)
            .padding(.trailing, 12)
            .background {
                Rectangle().fill(palette.objectRelief)
            }
            .overlay(alignment: .leading) {
                TodayVitalityTruthSeam(kind: truthKind, palette: palette)
                    .padding(.vertical, 8)
                    .accessibilityHidden(true)
            }
    }
}

struct TodayVitalityActionStyle: ButtonStyle {
    let role: TodayVitalityActionRole
    let palette: TodayVitalityPalette
    var isSelected = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TodayVitalityTypographyRole.action.font)
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 48)
            .padding(.horizontal, 16)
            .background(backgroundColor, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            }
            .opacity(isEnabled ? (configuration.isPressed ? 0.76 : 1) : 0.48)
            .scaleEffect(reduceMotion ? 1 : configuration.isPressed ? 0.985 : 1)
            .contentShape(Rectangle())
    }

    private var foregroundColor: Color {
        switch role {
        case .continuation, .commitment:
            palette.actionInk
        case .outcomeSelection:
            isSelected ? palette.ambitionsAccentMuted : palette.labelPrimary
        case .secondary, .navigationDisclosure:
            palette.labelPrimary
        }
    }

    private var backgroundColor: Color {
        switch role {
        case .continuation:
            palette.ambitionsAccent.opacity(0.82)
        case .outcomeSelection:
            isSelected ? palette.objectInset : palette.canvas
        case .commitment:
            palette.ambitionsAccent
        case .secondary:
            palette.canvasElevated
        case .navigationDisclosure:
            .clear
        }
    }

    private var borderColor: Color {
        if palette.contrast == .increased {
            return palette.labelPrimary.opacity(0.88)
        }
        switch role {
        case .outcomeSelection:
            return isSelected ? palette.ambitionsAccentMuted : palette.separator
        case .navigationDisclosure:
            return palette.separator
        case .continuation, .commitment, .secondary:
            return .clear
        }
    }

    private var borderWidth: CGFloat {
        role == .navigationDisclosure ? palette.separatorStrokeWidth : palette.nodeStrokeWidth
    }

    private var cornerRadius: CGFloat {
        switch role {
        case .outcomeSelection, .navigationDisclosure:
            8
        case .continuation, .commitment, .secondary:
            12
        }
    }
}

struct TodayVitalityFunctionalChrome<Content: View>: View {
    let palette: TodayVitalityPalette
    let isInteractive: Bool
    let content: Content

    @Environment(\.accessibilityReduceTransparency) private var systemReduceTransparency

    init(
        palette: TodayVitalityPalette,
        isInteractive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.palette = palette
        self.isInteractive = isInteractive
        self.content = content()
    }

    var body: some View {
        if palette.chromeTreatment == .opaque || systemReduceTransparency {
            opaqueContent
        } else {
            nativeContent
        }
    }

    private var opaqueContent: some View {
        content
            .background(palette.opaqueChrome, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(palette.separator, lineWidth: palette.separatorStrokeWidth)
            }
    }

    @ViewBuilder
    private var nativeContent: some View {
        #if os(iOS)
        if #available(iOS 26.0, *) {
            content
                .glassEffect(
                    .regular.interactive(isInteractive),
                    in: .rect(cornerRadius: 16)
                )
        } else {
            opaqueContent
        }
        #else
        opaqueContent
        #endif
    }
}
