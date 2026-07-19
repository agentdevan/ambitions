#if canImport(SwiftUI)
import SwiftUI

// accessibilityReduceMotion contract: callers pass the Reduce Motion environment into these animation and transition tokens.
public enum LivingTabContext: String, CaseIterable, Identifiable, Sendable {
    case today
    case goals
    case capture
    case time
    case plan
    case motion
    case you
    case memory
    case trust

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .capture: "Capture"
        case .time: "Time"
        case .plan: "Time"
        case .motion: "Motion"
        case .you: "You"
        case .memory: "Memory"
        case .trust: "Trust"
        }
    }

    public var symbolName: String {
        switch self {
        case .today: "sun.max"
        case .goals: "scope"
        case .capture: "plus.circle"
        case .time: "clock.badge.checkmark"
        case .plan: "clock"
        case .motion: "point.topleft.down.curvedto.point.bottomright.up"
        case .you: "person.crop.circle"
        case .memory: "sparkle.magnifyingglass"
        case .trust: "checkmark.shield"
        }
    }

    public func accent(in theme: AmbitionTheme) -> Color {
        switch self {
        case .today: theme.semanticColors.focus
        case .goals: theme.colors.accentPrimary
        case .capture: theme.semanticColors.capture
        case .time: theme.semanticColors.calendarDerived
        case .plan: theme.semanticColors.calendarDerived
        case .motion: theme.semanticColors.trust
        case .you: theme.semanticColors.review
        case .memory: theme.semanticColors.trust
        case .trust: theme.semanticColors.protected
        }
    }
}

public enum LivingVisualState: String, CaseIterable, Sendable {
    case calm
    case active
    case pressured
    case proof
    case recovery
    case sensitive
    case stale
    case empty

    public var title: String {
        switch self {
        case .calm: "Calm"
        case .active: "Active"
        case .pressured: "Pressure visible"
        case .proof: "Proof visible"
        case .recovery: "Recovery"
        case .sensitive: "Sensitive"
        case .stale: "Needs review"
        case .empty: "Ready"
        }
    }

    public var ambitionState: AmbitionVisualState {
        switch self {
        case .calm, .empty: .default
        case .active: .selected
        case .pressured, .stale: .warning
        case .proof: .success
        case .recovery: .celebration
        case .sensitive: .loading
        }
    }
}

public enum DAVMotionPreset: String, CaseIterable, Sendable {
    case subtlePulse
    case softReveal
    case railProgress
    case receiptConfirmation
    case heroExpansion
    case stateSettle

    public var stateMeaning: String {
        switch self {
        case .subtlePulse:
            return "A proof or attention state became visible."
        case .softReveal:
            return "A surface or module became available without changing ownership."
        case .railProgress:
            return "A timeline or ordered rail advanced to a new visible state."
        case .receiptConfirmation:
            return "A receipt, proof, or safety confirmation settled."
        case .heroExpansion:
            return "A primary visual object expanded into the working context."
        case .stateSettle:
            return "A module reached a stable state after data or selection changed."
        }
    }

    public var reduceMotionEquivalent: String {
        switch self {
        case .subtlePulse:
            return "Static state label with proof or attention icon."
        case .softReveal:
            return "Opacity-only or instant reveal with the same label and hierarchy."
        case .railProgress:
            return "Static rail position, progress label, and accessible value."
        case .receiptConfirmation:
            return "Static receipt/proof state with source and undo or correction labels."
        case .heroExpansion:
            return "Direct focus or navigation with the destination title preserved."
        case .stateSettle:
            return "Immediate stable module state with non-color label."
        }
    }

    public func animation(theme: AmbitionTheme, reduceMotion: Bool) -> Animation? {
        guard reduceMotion == false else { return nil }

        switch self {
        case .subtlePulse:
            return .easeInOut(duration: theme.timing.settle)
        case .softReveal:
            return theme.motion.animation(reduceMotion: false)
        case .railProgress:
            return .spring(response: theme.timing.regular, dampingFraction: 0.90)
        case .receiptConfirmation:
            return theme.motion.animation(reduceMotion: false, emphasis: true)
        case .heroExpansion:
            return .spring(response: theme.timing.emphasis, dampingFraction: 0.88)
        case .stateSettle:
            return theme.motion.settleAnimation(reduceMotion: false)
        }
    }

    public func transition(reduceMotion: Bool) -> AnyTransition {
        guard reduceMotion == false else { return .opacity }

        switch self {
        case .subtlePulse, .stateSettle:
            return .opacity
        case .softReveal:
            return .opacity.combined(with: .scale(scale: 0.985, anchor: .top))
        case .railProgress:
            return .opacity.combined(with: .move(edge: .leading))
        case .receiptConfirmation:
            return .opacity.combined(with: .scale(scale: 0.975, anchor: .center))
        case .heroExpansion:
            return .opacity.combined(with: .scale(scale: 0.98, anchor: .top))
        }
    }
}

public struct LivingSurfaceBackground: View {
    @Environment(\.ambitionTheme) private var theme

    let context: LivingTabContext
    let state: LivingVisualState
    let intensity: Double

    public init(
        context: LivingTabContext,
        state: LivingVisualState = .calm,
        intensity: Double = 1
    ) {
        self.context = context
        self.state = state
        self.intensity = max(0, min(intensity, 1))
    }

    public var body: some View {
        ZStack {
            theme.surfaces.canvasGradient
            ContextAtmosphereLayer(context: context, state: state, intensity: intensity)
        }
        .accessibilityHidden(true)
    }
}

public struct ContextAtmosphereLayer: View {
    @Environment(\.ambitionTheme) private var theme

    let context: LivingTabContext
    let state: LivingVisualState
    let intensity: Double

    public init(
        context: LivingTabContext,
        state: LivingVisualState = .calm,
        intensity: Double = 1
    ) {
        self.context = context
        self.state = state
        self.intensity = max(0, min(intensity, 1))
    }

    public var body: some View {
        let accent = context.accent(in: theme)
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                Circle()
                    .fill(accent.opacity(0.10 + 0.08 * intensity))
                    .frame(width: proxy.size.width * primaryScale, height: proxy.size.width * primaryScale)
                    .offset(x: proxy.size.width * primaryOffset.x, y: proxy.size.height * primaryOffset.y)
                    .blur(radius: 38)

                Circle()
                    .fill(theme.colors.canvas.opacity(0.03 + 0.02 * intensity))
                    .frame(width: proxy.size.width * secondaryScale, height: proxy.size.width * secondaryScale)
                    .offset(x: proxy.size.width * secondaryOffset.x, y: proxy.size.height * secondaryOffset.y)
                    .blur(radius: 48)

                LinearGradient(
                    colors: [
                        accent.opacity(0.08 * intensity),
                        theme.colors.canvas.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    var primaryScale: CGFloat {
        switch context {
        case .today: 0.88
        case .goals: 0.82
        case .capture: 0.84
        case .time: 0.90
        case .motion: 0.86
        case .plan: 0.90
        case .you: 0.80
        case .memory: 0.84
        case .trust: 0.78
        }
    }

    var secondaryScale: CGFloat {
        switch context {
        case .today: 0.34
        case .goals: 0.28
        case .capture: 0.26
        case .time: 0.30
        case .motion: 0.25
        case .plan: 0.30
        case .you: 0.24
        case .memory: 0.26
        case .trust: 0.22
        }
    }

    var primaryOffset: CGPoint {
        switch state {
        case .calm, .empty: baseOffset
        case .active, .proof: CGPoint(x: baseOffset.x - 0.10, y: baseOffset.y - 0.06)
        case .pressured, .stale: CGPoint(x: baseOffset.x - 0.16, y: baseOffset.y + 0.04)
        case .recovery: CGPoint(x: baseOffset.x - 0.04, y: baseOffset.y + 0.10)
        case .sensitive: CGPoint(x: baseOffset.x + 0.02, y: baseOffset.y + 0.06)
        }
    }

    var secondaryOffset: CGPoint {
        switch context {
        case .today: CGPoint(x: 0.08, y: 0.24)
        case .goals: CGPoint(x: 0.62, y: 0.18)
        case .capture: CGPoint(x: 0.14, y: 0.30)
        case .time: CGPoint(x: 0.66, y: 0.16)
        case .motion: CGPoint(x: 0.58, y: 0.20)
        case .plan: CGPoint(x: 0.66, y: 0.16)
        case .you: CGPoint(x: 0.50, y: 0.04)
        case .memory: CGPoint(x: 0.24, y: 0.10)
        case .trust: CGPoint(x: 0.56, y: 0.28)
        }
    }

    var baseOffset: CGPoint {
        switch context {
        case .today: CGPoint(x: 0.42, y: 0.02)
        case .goals: CGPoint(x: 0.24, y: 0.06)
        case .capture: CGPoint(x: 0.56, y: 0.03)
        case .time: CGPoint(x: 0.34, y: 0.10)
        case .motion: CGPoint(x: 0.48, y: 0.06)
        case .plan: CGPoint(x: 0.34, y: 0.10)
        case .you: CGPoint(x: 0.46, y: 0.12)
        case .memory: CGPoint(x: 0.36, y: 0.00)
        case .trust: CGPoint(x: 0.50, y: 0.14)
        }
    }
}

public struct PressureGlow: View {
    @Environment(\.ambitionTheme) private var theme

    let level: Double
    let context: LivingTabContext
    let label: String

    public init(level: Double, context: LivingTabContext = .today, label: String = "Pressure") {
        self.level = max(0, min(level, 1))
        self.context = context
        self.label = label
    }

    public var body: some View {
        let accent = level > 0.72 ? theme.semanticColors.risk : context.accent(in: theme)

        Capsule()
            .fill(accent.opacity(0.10 + level * 0.16))
            .overlay {
                Capsule()
                    .strokeBorder(accent.opacity(0.22 + level * 0.28), lineWidth: 1)
            }
            .frame(height: 8)
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(accent.opacity(0.72))
                    .frame(width: max(14, CGFloat(level) * 160), height: 8)
            }
            .accessibilityLabel(label)
            .accessibilityValue("\(Int(level * 100)) percent")
    }
}
#endif
